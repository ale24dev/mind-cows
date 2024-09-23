alter table "public"."player_number" alter column "time_left" set default '30'::smallint;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_game_time()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    game RECORD;
    player1_time_left INT;
    player2_time_left INT;
BEGIN
  -- Iterar por cada juego en estado "in_progress"
  FOR game IN
    SELECT g.id, pn1.time_left AS player1_time_left, pn2.time_left AS player2_time_left,
           pn1.started_time AS player1_started_time, pn2.started_time AS player2_started_time,
           pn1.player AS player1_id, pn2.player AS player2_id
    FROM game g
    JOIN player_number pn1 ON pn1.id = g.player_number1
    JOIN player_number pn2 ON pn2.id = g.player_number2
    WHERE g.status = (
      SELECT id FROM game_status WHERE status = 'in_progress' LIMIT 1
    )
  LOOP
    -- Calcular el tiempo restante para el jugador 1
    player1_time_left := game.player1_time_left - EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - game.player1_started_time));
    
    -- Calcular el tiempo restante para el jugador 2
    player2_time_left := game.player2_time_left - EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - game.player2_started_time));

    -- Verificar si el tiempo del jugador 1 ha llegado a 0
    IF player1_time_left <= 0 THEN
      -- Llamar a la función para finalizar el juego y dar la victoria al jugador 2
      PERFORM finish_game_by_time(game.id, game.player2_id);
    END IF;

    -- Verificar si el tiempo del jugador 2 ha llegado a 0
    IF player2_time_left <= 0 THEN
      -- Llamar a la función para finalizar el juego y dar la victoria al jugador 1
      PERFORM finish_game_by_time(game.id, game.player1_id);
    END IF;
  END LOOP;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.finish_game_by_time(game_id bigint, winner_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE game
  SET status = (
    SELECT id
    FROM game_status
    WHERE status = 'finished'
    LIMIT 1
  ), winner = winner_id
  WHERE id = game_id;

END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_game_with_player(player_id uuid)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
  new_game_id BIGINT;
  player_number1_id BIGINT;
  in_progress_status_id BIGINT;
BEGIN

  SELECT id INTO in_progress_status_id
  FROM game_status
  WHERE status = 'searching'
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No status with value in_progress found';
  END IF;

  INSERT INTO player_number (player)
  VALUES (player_id)
  RETURNING id INTO player_number1_id;

  INSERT INTO game (status, player_number1, player_number2, winner)
  VALUES (in_progress_status_id, player_number1_id, NULL, NULL)
  RETURNING id INTO new_game_id;

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
        'is_turn', pn1.is_turn,
        'time_left', pn1.time_left,
        'player', json_build_object(
            'id', p1.id,
            'username', p1.username,
            'avatar_url', p1.avatar_url
        )
      ),
      'player_number2', NULL,  
      'winner', NULL
    )
    FROM game g
    LEFT JOIN game_status gs ON gs.id = g.status
    LEFT JOIN player_number pn1 ON pn1.id = g.player_number1
    LEFT JOIN player p1 ON p1.id = pn1.player
    WHERE g.id = new_game_id
  );
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
            'is_turn', pn1.is_turn,
            'time_left', pn1.time_left,
            'player', json_build_object(
              'id', p1.id,
              'username', p1.username,
              'avatar_url', p1.avatar_url
            )
          ),
          'player_number2', json_build_object(
            'id', pn2.id,
            'number', pn2.number,
            'is_turn', pn2.is_turn,
            'time_left', pn2.time_left,
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
          'is_turn', pn1.is_turn,
          'time_left', pn1.time_left,
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
          'is_turn', pn2.is_turn,
          'time_left', pn2.time_left,
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

CREATE OR REPLACE FUNCTION public.update_player_number(player_number_id bigint, new_number_text text)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
  new_number INT[];  -- Array para almacenar el valor convertido
  updated_player_number RECORD;
BEGIN
  -- Convertir el texto en un array de enteros
  new_number := array(
    SELECT unnest(
      -- Convertir cada carácter del texto en una fila y luego a entero
      array(
        SELECT regexp_split_to_array(new_number_text, '')::INT[]
      )
    )
  );

  -- Actualizar el número (array) del jugador en la tabla player_number
  UPDATE player_number
  SET number = new_number
  WHERE id = player_number_id;

  -- Comprobar si la actualización afectó alguna fila
  IF NOT FOUND THEN
    RETURN json_build_object(
      'error', 'No player number found with the given ID'
    ); -- Devolver un JSON con un mensaje de error si no se encontró el player_number
  END IF;

  -- Obtener el registro actualizado junto con el jugador
  SELECT pn.id AS player_number_id,
         pn.number,
         pn.is_turn,
         pn.time_left,
         json_build_object(
           'id', p.id,
           'username', p.username,
           'avatar_url', p.avatar_url
         ) AS player
  INTO updated_player_number
  FROM player_number pn
  LEFT JOIN player p ON p.id = pn.player
  WHERE pn.id = player_number_id;

  -- Devolver el resultado en formato JSON
  RETURN json_build_object(
    'id', updated_player_number.player_number_id,
    'number', updated_player_number.number,
    'is_turn', updated_player_number.is_turn,
    'time_left', updated_player_number.time_left,
    'player', updated_player_number.player
  );
END;
$function$
;


