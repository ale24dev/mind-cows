create table "public"."attempt" (
    "id" bigint generated by default as identity not null,
    "game" bigint not null,
    "bulls" integer not null default 0,
    "cows" integer not null default 0,
    "number" smallint[] not null,
    "player" uuid not null
);


alter table "public"."attempt" enable row level security;

create table "public"."game" (
    "id" bigint generated always as identity not null,
    "status" bigint not null,
    "winner" uuid,
    "player_number1" bigint,
    "player_number2" bigint
);


create table "public"."game_status" (
    "id" bigint generated always as identity not null,
    "status" text not null
);


alter table "public"."game_status" enable row level security;

create table "public"."player" (
    "username" text not null,
    "avatar_url" text not null default 'https://vtxedgyoqydehqzgcpwb.supabase.co/storage/v1/object/sign/avatars/40542.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJhdmF0YXJzLzQwNTQyLmpwZyIsImlhdCI6MTcyNjI4OTc3MCwiZXhwIjoyMDQxNjQ5NzcwfQ.j4g4h9sFSRbW-lgo17taavdsyXUq0E2uUE4vGlk5-Vs'::text,
    "id" uuid not null
);


alter table "public"."player" enable row level security;

create table "public"."player_number" (
    "id" bigint generated by default as identity not null,
    "player" uuid not null,
    "number" smallint[]
);


create table "public"."ranking" (
    "games_won" integer not null default 0,
    "minimum_attempts" integer not null,
    "games_loss" smallint not null default '0'::smallint,
    "id" smallint generated by default as identity not null,
    "player" uuid not null
);


alter table "public"."ranking" enable row level security;

CREATE UNIQUE INDEX game_status_pkey ON public.game_status USING btree (id);

CREATE UNIQUE INDEX intentos_pkey ON public.attempt USING btree (id);

CREATE UNIQUE INDEX partidas_pkey ON public.game USING btree (id);

CREATE UNIQUE INDEX player_number_pkey ON public.player_number USING btree (id);

CREATE UNIQUE INDEX player_pkey ON public.player USING btree (id);

CREATE UNIQUE INDEX ranking_pkey ON public.ranking USING btree (id);

alter table "public"."attempt" add constraint "intentos_pkey" PRIMARY KEY using index "intentos_pkey";

alter table "public"."game" add constraint "partidas_pkey" PRIMARY KEY using index "partidas_pkey";

alter table "public"."game_status" add constraint "game_status_pkey" PRIMARY KEY using index "game_status_pkey";

alter table "public"."player" add constraint "player_pkey" PRIMARY KEY using index "player_pkey";

alter table "public"."player_number" add constraint "player_number_pkey" PRIMARY KEY using index "player_number_pkey";

alter table "public"."ranking" add constraint "ranking_pkey" PRIMARY KEY using index "ranking_pkey";

alter table "public"."attempt" add constraint "attempt_player_fkey" FOREIGN KEY (player) REFERENCES player(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."attempt" validate constraint "attempt_player_fkey";

alter table "public"."attempt" add constraint "intentos_partida_id_fkey" FOREIGN KEY (game) REFERENCES game(id) not valid;

alter table "public"."attempt" validate constraint "intentos_partida_id_fkey";

alter table "public"."game" add constraint "game_player_number1_fkey" FOREIGN KEY (player_number1) REFERENCES player_number(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."game" validate constraint "game_player_number1_fkey";

alter table "public"."game" add constraint "game_player_number2_fkey" FOREIGN KEY (player_number2) REFERENCES player_number(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."game" validate constraint "game_player_number2_fkey";

alter table "public"."game" add constraint "game_status_fkey" FOREIGN KEY (status) REFERENCES game_status(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."game" validate constraint "game_status_fkey";

alter table "public"."game" add constraint "game_winner_fkey" FOREIGN KEY (winner) REFERENCES player(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."game" validate constraint "game_winner_fkey";

alter table "public"."player_number" add constraint "player_number_player_fkey" FOREIGN KEY (player) REFERENCES player(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."player_number" validate constraint "player_number_player_fkey";

alter table "public"."ranking" add constraint "ranking_player_fkey" FOREIGN KEY (player) REFERENCES player(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."ranking" validate constraint "ranking_player_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_game(player_id uuid)
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
  -- Get the ID of the 'searching' status
  SELECT id INTO searching_status_id
  FROM game_status
  WHERE status = 'searching'
  LIMIT 1;

  -- Get the ID of the 'selecting_secret_numbers' status
  SELECT id INTO selecting_secret_numbers_status_id
  FROM game_status
  WHERE status = 'selecting_secret_numbers'
  LIMIT 1;

  -- Check if 'searching' status exists
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No status with value searching found';
  END IF;

  -- Check if 'selecting_secret_numbers' status exists
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No status with value selecting_secret_numbers found';
  END IF;

  -- Start the timer
  start_time := clock_timestamp();

  -- Loop to search for an available game within 5 seconds
  LOOP
    -- Try to find a game with 'searching' status
    SELECT g.id INTO found_game_id
    FROM game g
    WHERE g.status = searching_status_id
    AND g.player_number2 IS NULL
    LIMIT 1;

    -- If a game is found, assign player_number2 and return the updated game
    IF FOUND THEN
      -- Insert new player_number for player_number2
      INSERT INTO player_number (player)
      VALUES (player_id)
      RETURNING id INTO player_number2_id;

      -- Update the game to assign player_number2 and change the status
      UPDATE game
      SET player_number2 = player_number2_id,
          status = selecting_secret_numbers_status_id
      WHERE id = found_game_id;

      -- Return the updated game in JSON format
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

    -- Check if 5 seconds have passed
    IF clock_timestamp() - start_time > interval '5 seconds' THEN
      -- If no game was found within 5 seconds, create a new game
      RETURN create_game_with_player(player_id);
    END IF;

    -- Pause briefly to avoid busy waiting (optional)
    PERFORM pg_sleep(0.1);
  END LOOP;
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
  -- Get the ID of the 'searching' status
  SELECT id INTO searching_status_id
  FROM game_status
  WHERE status = 'searching'
  LIMIT 1;

  -- Get the ID of the 'selecting_secret_numbers' status
  SELECT id INTO selecting_secret_numbers_status_id
  FROM game_status
  WHERE status = 'selecting_secret_numbers'
  LIMIT 1;

  -- Check if 'searching' status exists
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No status with value searching found';
  END IF;

  -- Check if 'selecting_secret_numbers' status exists
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No status with value selecting_secret_numbers found';
  END IF;

  -- Start the timer
  start_time := clock_timestamp();

  -- Loop to search for an available game within 5 seconds
  LOOP
    -- Try to find a game with 'searching' status
    SELECT g.id INTO found_game_id
    FROM game g
    WHERE g.status = searching_status_id
    AND g.player_number2 IS NULL
    LIMIT 1;

    -- If a game is found, assign player_number2 and return the updated game
    IF FOUND THEN
      -- Insert new player_number for player_number2
      INSERT INTO player_number (player)
      VALUES (player_id)
      RETURNING id INTO player_number2_id;

      -- Update the game to assign player_number2 and change the status
      UPDATE game
      SET player_number2 = player_number2_id,
          status = selecting_secret_numbers_status_id
      WHERE id = found_game_id;

      -- Return the updated game in JSON format
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

    -- Check if 5 seconds have passed
    IF clock_timestamp() - start_time > interval '5 seconds' THEN
      -- If no game was found within 5 seconds, create a new game
      RETURN create_game_with_player(player_id);
    END IF;

    -- Pause briefly to avoid busy waiting (optional)
    PERFORM pg_sleep(0.1);
  END LOOP;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_current_game(player_id uuid)
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
    WHERE gs.status != 'finished'
    AND (pn1.player = player_id OR pn2.player = player_id)
    LIMIT 1
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  insert into public.player (id, username)
  values (new.id, split_part(new.email, '@', 1));
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.update_games_to_in_progress()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
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
    'player', updated_player_number.player
  );
END;
$function$
;

grant delete on table "public"."attempt" to "anon";

grant insert on table "public"."attempt" to "anon";

grant references on table "public"."attempt" to "anon";

grant select on table "public"."attempt" to "anon";

grant trigger on table "public"."attempt" to "anon";

grant truncate on table "public"."attempt" to "anon";

grant update on table "public"."attempt" to "anon";

grant delete on table "public"."attempt" to "authenticated";

grant insert on table "public"."attempt" to "authenticated";

grant references on table "public"."attempt" to "authenticated";

grant select on table "public"."attempt" to "authenticated";

grant trigger on table "public"."attempt" to "authenticated";

grant truncate on table "public"."attempt" to "authenticated";

grant update on table "public"."attempt" to "authenticated";

grant delete on table "public"."attempt" to "service_role";

grant insert on table "public"."attempt" to "service_role";

grant references on table "public"."attempt" to "service_role";

grant select on table "public"."attempt" to "service_role";

grant trigger on table "public"."attempt" to "service_role";

grant truncate on table "public"."attempt" to "service_role";

grant update on table "public"."attempt" to "service_role";

grant delete on table "public"."game" to "anon";

grant insert on table "public"."game" to "anon";

grant references on table "public"."game" to "anon";

grant select on table "public"."game" to "anon";

grant trigger on table "public"."game" to "anon";

grant truncate on table "public"."game" to "anon";

grant update on table "public"."game" to "anon";

grant delete on table "public"."game" to "authenticated";

grant insert on table "public"."game" to "authenticated";

grant references on table "public"."game" to "authenticated";

grant select on table "public"."game" to "authenticated";

grant trigger on table "public"."game" to "authenticated";

grant truncate on table "public"."game" to "authenticated";

grant update on table "public"."game" to "authenticated";

grant delete on table "public"."game" to "service_role";

grant insert on table "public"."game" to "service_role";

grant references on table "public"."game" to "service_role";

grant select on table "public"."game" to "service_role";

grant trigger on table "public"."game" to "service_role";

grant truncate on table "public"."game" to "service_role";

grant update on table "public"."game" to "service_role";

grant delete on table "public"."game_status" to "anon";

grant insert on table "public"."game_status" to "anon";

grant references on table "public"."game_status" to "anon";

grant select on table "public"."game_status" to "anon";

grant trigger on table "public"."game_status" to "anon";

grant truncate on table "public"."game_status" to "anon";

grant update on table "public"."game_status" to "anon";

grant delete on table "public"."game_status" to "authenticated";

grant insert on table "public"."game_status" to "authenticated";

grant references on table "public"."game_status" to "authenticated";

grant select on table "public"."game_status" to "authenticated";

grant trigger on table "public"."game_status" to "authenticated";

grant truncate on table "public"."game_status" to "authenticated";

grant update on table "public"."game_status" to "authenticated";

grant delete on table "public"."game_status" to "service_role";

grant insert on table "public"."game_status" to "service_role";

grant references on table "public"."game_status" to "service_role";

grant select on table "public"."game_status" to "service_role";

grant trigger on table "public"."game_status" to "service_role";

grant truncate on table "public"."game_status" to "service_role";

grant update on table "public"."game_status" to "service_role";

grant delete on table "public"."player" to "anon";

grant insert on table "public"."player" to "anon";

grant references on table "public"."player" to "anon";

grant select on table "public"."player" to "anon";

grant trigger on table "public"."player" to "anon";

grant truncate on table "public"."player" to "anon";

grant update on table "public"."player" to "anon";

grant delete on table "public"."player" to "authenticated";

grant insert on table "public"."player" to "authenticated";

grant references on table "public"."player" to "authenticated";

grant select on table "public"."player" to "authenticated";

grant trigger on table "public"."player" to "authenticated";

grant truncate on table "public"."player" to "authenticated";

grant update on table "public"."player" to "authenticated";

grant delete on table "public"."player" to "service_role";

grant insert on table "public"."player" to "service_role";

grant references on table "public"."player" to "service_role";

grant select on table "public"."player" to "service_role";

grant trigger on table "public"."player" to "service_role";

grant truncate on table "public"."player" to "service_role";

grant update on table "public"."player" to "service_role";

grant delete on table "public"."player_number" to "anon";

grant insert on table "public"."player_number" to "anon";

grant references on table "public"."player_number" to "anon";

grant select on table "public"."player_number" to "anon";

grant trigger on table "public"."player_number" to "anon";

grant truncate on table "public"."player_number" to "anon";

grant update on table "public"."player_number" to "anon";

grant delete on table "public"."player_number" to "authenticated";

grant insert on table "public"."player_number" to "authenticated";

grant references on table "public"."player_number" to "authenticated";

grant select on table "public"."player_number" to "authenticated";

grant trigger on table "public"."player_number" to "authenticated";

grant truncate on table "public"."player_number" to "authenticated";

grant update on table "public"."player_number" to "authenticated";

grant delete on table "public"."player_number" to "service_role";

grant insert on table "public"."player_number" to "service_role";

grant references on table "public"."player_number" to "service_role";

grant select on table "public"."player_number" to "service_role";

grant trigger on table "public"."player_number" to "service_role";

grant truncate on table "public"."player_number" to "service_role";

grant update on table "public"."player_number" to "service_role";

grant delete on table "public"."ranking" to "anon";

grant insert on table "public"."ranking" to "anon";

grant references on table "public"."ranking" to "anon";

grant select on table "public"."ranking" to "anon";

grant trigger on table "public"."ranking" to "anon";

grant truncate on table "public"."ranking" to "anon";

grant update on table "public"."ranking" to "anon";

grant delete on table "public"."ranking" to "authenticated";

grant insert on table "public"."ranking" to "authenticated";

grant references on table "public"."ranking" to "authenticated";

grant select on table "public"."ranking" to "authenticated";

grant trigger on table "public"."ranking" to "authenticated";

grant truncate on table "public"."ranking" to "authenticated";

grant update on table "public"."ranking" to "authenticated";

grant delete on table "public"."ranking" to "service_role";

grant insert on table "public"."ranking" to "service_role";

grant references on table "public"."ranking" to "service_role";

grant select on table "public"."ranking" to "service_role";

grant trigger on table "public"."ranking" to "service_role";

grant truncate on table "public"."ranking" to "service_role";

grant update on table "public"."ranking" to "service_role";

create policy "Enable insert for authenticated users only"
on "public"."attempt"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for all users"
on "public"."attempt"
as permissive
for select
to public
using (true);


create policy "Enable insert for authenticated users only"
on "public"."game"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for all users"
on "public"."game"
as permissive
for select
to public
using (true);


create policy "update_game_policy"
on "public"."game"
as permissive
for update
to public
using (((EXISTS ( SELECT 1
   FROM player_number
  WHERE ((player_number.id = game.player_number1) AND (player_number.player = auth.uid())))) OR (EXISTS ( SELECT 1
   FROM player_number
  WHERE ((player_number.id = game.player_number2) AND (player_number.player = auth.uid()))))));


create policy "Enable read access for all users"
on "public"."game_status"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."player"
as permissive
for select
to public
using (true);


create policy "Enable insert for authenticated users only"
on "public"."player_number"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for all users"
on "public"."player_number"
as permissive
for select
to public
using (true);


create policy "update_player_number"
on "public"."player_number"
as permissive
for update
to public
using ((player = auth.uid()));


create policy "Enable read access for all users"
on "public"."ranking"
as permissive
for select
to public
using (true);



