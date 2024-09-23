drop function if exists "public"."get_current_game"(player_id uuid);

alter table "public"."attempt" disable row level security;

alter table "public"."player_number" add column "is_turn" boolean not null default false;

alter table "public"."player_number" add column "started_time" timestamp with time zone;

alter table "public"."player_number" add column "time_left" smallint not null default '600'::smallint;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.cancel_search_game(player_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
  found_game_id BIGINT;
  searching_status_id BIGINT;
BEGIN
  SELECT id INTO searching_status_id
  FROM game_status
  WHERE status = 'searching'
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No status with value searching found';
  END IF;

  SELECT g.id INTO found_game_id
  FROM game g
  LEFT JOIN player_number pn1 ON g.player_number1 = pn1.id
  WHERE g.status = searching_status_id
  AND pn1.player = player_id
  LIMIT 1;

  IF FOUND THEN
    DELETE FROM game WHERE id = found_game_id;
    RETURN TRUE; 
  ELSE
    RETURN FALSE; 
  END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.finish_game_by_win()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN

  
  IF NEW.bulls = 4 THEN
    UPDATE game g
    SET status = (
        SELECT id
        FROM game_status
        WHERE status = 'finished'
        LIMIT 1
      ), winner = NEW.player
    WHERE g.id = NEW.game;
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_last_game(player_id uuid)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN (
    SELECT json_build_object(
      'id', g.id,
      'status', json_build_object(
        'id', gs.id,
        'status', gs.status
      ),
      'player_number1', CASE
        WHEN pn1.id IS NOT NULL THEN json_build_object(
          'id', pn1.id,
          'number', pn1.number,
          'player', json_build_object(
              'id', p1.id,
              'username', p1.username,
              'avatar_url', p1.avatar_url
          )
        )
        ELSE NULL
      END,
      'player_number2', CASE
        WHEN pn2.id IS NOT NULL THEN json_build_object(
          'id', pn2.id,
          'number', pn2.number,
          'player', json_build_object(
              'id', p2.id,
              'username', p2.username,
              'avatar_url', p2.avatar_url
          )
        )
        ELSE NULL
      END,
      'winner', CASE
        WHEN g.winner IS NOT NULL THEN json_build_object(
          'id', p_winner.id,
          'username', p_winner.username,
          'avatar_url', p_winner.avatar_url
        )
        ELSE NULL
      END
    )
    FROM game g
    LEFT JOIN game_status gs ON gs.id = g.status
    LEFT JOIN player_number pn1 ON pn1.id = g.player_number1
    LEFT JOIN player_number pn2 ON pn2.id = g.player_number2
    LEFT JOIN player p1 ON p1.id = pn1.player
    LEFT JOIN player p2 ON p2.id = pn2.player
    LEFT JOIN player p_winner ON p_winner.id = g.winner
    WHERE (pn1.player = player_id OR pn2.player = player_id)
    ORDER BY g.id DESC -- Ordena por el partido más reciente
    LIMIT 1
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.set_random_starting_player()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    starting_player_id INT;
BEGIN
    -- Verificar si el nuevo estado es 'in_progress'
    IF NEW.status = (SELECT id FROM game_status WHERE status = 'in_progress' LIMIT 1) THEN
        -- Seleccionar aleatoriamente al jugador que empieza
        IF RANDOM() < 0.5 THEN
            starting_player_id := NEW.player_number1;
        ELSE
            starting_player_id := NEW.player_number2;
        END IF;

        -- Actualizar el estado de los jugadores
        UPDATE player_number
        SET is_turn = FALSE, started_time = NULL
        WHERE id IN (NEW.player_number1, NEW.player_number2);

        -- Actualizar el jugador que empieza su turno
        UPDATE player_number
        SET is_turn = TRUE, started_time = CURRENT_TIMESTAMP
        WHERE id = starting_player_id;
    END IF;

    RETURN NULL;  -- No devolver nada ya que es un trigger
END;
$function$
;

CREATE OR REPLACE FUNCTION public.find_or_create_game(player_id uuid)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
  found_game_id BIGINT;
  player_number2_id BIGINT;
  searching_status_id BIGINT;
  selecting_secret_numbers_status_id BIGINT;
  start_time TIMESTAMP;
BEGIN
  -- Obtener el ID del estado 'searching'
  SELECT id INTO searching_status_id
  FROM game_status
  WHERE status = 'searching'
  LIMIT 1;

  -- Obtener el ID del estado 'selecting_secret_numbers'
  SELECT id INTO selecting_secret_numbers_status_id
  FROM game_status
  WHERE status = 'selecting_secret_numbers'
  LIMIT 1;

  -- Verificar si existe el estado 'searching'
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No status with value searching found';
  END IF;

  -- Verificar si existe el estado 'selecting_secret_numbers'
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No status with value selecting_secret_numbers found';
  END IF;

  -- Iniciar el temporizador
  start_time := clock_timestamp();

  -- Bucle para buscar un juego disponible dentro de los 5 segundos
  LOOP
    -- Intentar encontrar un juego con el estado 'searching' y que el jugador no sea player_number1
    SELECT g.id INTO found_game_id
    FROM game g
    JOIN player_number pn1 ON g.player_number1 = pn1.id
    WHERE g.status = searching_status_id
    AND g.player_number2 IS NULL
    AND pn1.player != player_id -- Evitar que el jugador juegue contra sí mismo
    LIMIT 1;

    -- Si se encuentra un juego, asignar player_number2 y devolver el juego actualizado
    IF FOUND THEN
      -- Insertar un nuevo player_number para player_number2
      INSERT INTO player_number (player)
      VALUES (player_id)
      RETURNING id INTO player_number2_id;

      -- Actualizar el juego para asignar player_number2 y cambiar el estado
      UPDATE game
      SET player_number2 = player_number2_id,
          status = selecting_secret_numbers_status_id
      WHERE id = found_game_id;

      -- Devolver el juego actualizado en formato JSON
      RETURN (
        SELECT json_build_object(
          'id', g.id,
          'status', json_build_object(
            'id', gs.id,
            'status', gs.status
          ),
          'player_number1', json_build_object(
            'id', pn1.id,
            'number', pn1.number,
            'player', json_build_object(
              'id', p1.id,
              'username', p1.username,
              'avatar_url', p1.avatar_url
            )
          ),
          'player_number2', json_build_object(
            'id', pn2.id,
            'number', pn2.number,
            'player', json_build_object(
              'id', p2.id,
              'username', p2.username,
              'avatar_url', p2.avatar_url
            )
          ),
          'winner', NULL
        )
        FROM game g
        LEFT JOIN game_status gs ON gs.id = g.status
        LEFT JOIN player_number pn1 ON pn1.id = g.player_number1
        LEFT JOIN player_number pn2 ON pn2.id = g.player_number2
        LEFT JOIN player p1 ON p1.id = pn1.player
        LEFT JOIN player p2 ON p2.id = pn2.player
        WHERE g.id = found_game_id
      );
    END IF;

    -- Verificar si han pasado 5 segundos
    IF clock_timestamp() - start_time > interval '5 seconds' THEN
      -- Si no se encuentra un juego dentro de los 5 segundos, crear un nuevo juego
      RETURN create_game_with_player(player_id);
    END IF;

    -- Pausa breve para evitar el busy waiting (opcional)
    PERFORM pg_sleep(0.1);
  END LOOP;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_games_to_in_progress()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    starting_player_id INT;
    player_number1 INT;
    player_number2 INT;
BEGIN
  -- Actualizar el estado del juego
  UPDATE game g
  SET status = (
    SELECT id
    FROM game_status
    WHERE status = 'in_progress'
    LIMIT 1
  )
  WHERE g.status = (
    SELECT id
    FROM game_status
    WHERE status = 'selecting_secret_numbers'
    LIMIT 1
  )
  AND EXISTS (
    SELECT 1
    FROM player_number pn1
    WHERE pn1.id = g.player_number1
    AND pn1.number IS NOT NULL
  )
  AND EXISTS (
    SELECT 1
    FROM player_number pn2
    WHERE pn2.id = g.player_number2
    AND pn2.number IS NOT NULL
  );

  -- Obtener los números de los jugadores
  SELECT g.player_number1, g.player_number2
  INTO player_number1, player_number2
  FROM game g
  WHERE g.status = (
    SELECT id
    FROM game_status
    WHERE status = 'in_progress'
    LIMIT 1
  )
  LIMIT 1;

END;
$function$
;

CREATE TRIGGER trigger_update_game_status_on_bulls AFTER INSERT ON public.attempt FOR EACH ROW EXECUTE FUNCTION finish_game_by_win();

CREATE TRIGGER update_player_turn AFTER UPDATE ON public.game FOR EACH ROW EXECUTE FUNCTION set_random_starting_player();


