
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE SCHEMA IF NOT EXISTS "public";

ALTER SCHEMA "public" OWNER TO "pg_database_owner";

CREATE OR REPLACE FUNCTION "public"."create_game"("player_id" "uuid") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
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
$$;

ALTER FUNCTION "public"."create_game"("player_id" "uuid") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."find_or_create_game"("player_id" "uuid") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  found_game_id BIGINT;
  player_number2_id BIGINT;
  searching_status_id BIGINT;
  in_progress_status_id BIGINT;
  start_time TIMESTAMP;
BEGIN
  -- Get the ID of the 'searching' status
  SELECT id INTO searching_status_id
  FROM game_status
  WHERE status = 'searching'
  LIMIT 1;

  -- Get the ID of the 'in_progress' status
  SELECT id INTO in_progress_status_id
  FROM game_status
  WHERE status = 'in_progress'
  LIMIT 1;

  -- Check if 'searching' and 'in_progress' statuses exist
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No status with value searching or in_progress found';
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

    -- If a game is found, assign player_number2 and update the status to 'in_progress'
    IF FOUND THEN
      -- Insert new player_number for player_number2
      INSERT INTO player_number (player)
      VALUES (player_id)
      RETURNING id INTO player_number2_id;

      -- Update the game to assign player_number2 and change status to 'in_progress'
      UPDATE game
      SET player_number2 = player_number2_id,
          status = in_progress_status_id
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
      RETURN create_game(player_id);
    END IF;

    -- Pause briefly to avoid busy waiting (optional)
    PERFORM pg_sleep(0.1);
  END LOOP;
END;
$$;

ALTER FUNCTION "public"."find_or_create_game"("player_id" "uuid") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_current_game"("player_id" "uuid") RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
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
$$;

ALTER FUNCTION "public"."get_current_game"("player_id" "uuid") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
  insert into public.player (id, username)
  values (new.id, split_part(new.email, '@', 1));
  return new;
end;
$$;

ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."attempt" (
    "id" bigint NOT NULL,
    "game" bigint NOT NULL,
    "bulls" integer DEFAULT 0 NOT NULL,
    "cows" integer DEFAULT 0 NOT NULL,
    "number" smallint[] NOT NULL,
    "player" "uuid" NOT NULL
);

ALTER TABLE "public"."attempt" OWNER TO "postgres";

ALTER TABLE "public"."attempt" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."attempt_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."game" (
    "id" bigint NOT NULL,
    "status" bigint NOT NULL,
    "winner" "uuid",
    "player_number1" bigint,
    "player_number2" bigint
);

ALTER TABLE "public"."game" OWNER TO "postgres";

ALTER TABLE "public"."game" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."game_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."game_status" (
    "id" bigint NOT NULL,
    "status" "text" NOT NULL
);

ALTER TABLE "public"."game_status" OWNER TO "postgres";

ALTER TABLE "public"."game_status" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."game_status_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."player" (
    "username" "text" NOT NULL,
    "avatar_url" "text" DEFAULT 'https://vtxedgyoqydehqzgcpwb.supabase.co/storage/v1/object/sign/avatars/40542.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJhdmF0YXJzLzQwNTQyLmpwZyIsImlhdCI6MTcyNjI4OTc3MCwiZXhwIjoyMDQxNjQ5NzcwfQ.j4g4h9sFSRbW-lgo17taavdsyXUq0E2uUE4vGlk5-Vs'::"text" NOT NULL,
    "id" "uuid" NOT NULL
);

ALTER TABLE "public"."player" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."player_number" (
    "id" bigint NOT NULL,
    "player" "uuid" NOT NULL,
    "number" smallint[]
);

ALTER TABLE "public"."player_number" OWNER TO "postgres";

ALTER TABLE "public"."player_number" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."player_number_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."ranking" (
    "games_won" integer DEFAULT 0 NOT NULL,
    "minimum_attempts" integer NOT NULL,
    "games_loss" smallint DEFAULT '0'::smallint NOT NULL,
    "id" smallint NOT NULL,
    "player" "uuid" NOT NULL
);

ALTER TABLE "public"."ranking" OWNER TO "postgres";

ALTER TABLE "public"."ranking" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."ranking_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE ONLY "public"."game_status"
    ADD CONSTRAINT "game_status_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."attempt"
    ADD CONSTRAINT "intentos_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."game"
    ADD CONSTRAINT "partidas_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."player_number"
    ADD CONSTRAINT "player_number_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."player"
    ADD CONSTRAINT "player_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."ranking"
    ADD CONSTRAINT "ranking_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."attempt"
    ADD CONSTRAINT "attempt_player_fkey" FOREIGN KEY ("player") REFERENCES "public"."player"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."game"
    ADD CONSTRAINT "game_player_number1_fkey" FOREIGN KEY ("player_number1") REFERENCES "public"."player_number"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."game"
    ADD CONSTRAINT "game_player_number2_fkey" FOREIGN KEY ("player_number2") REFERENCES "public"."player_number"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."game"
    ADD CONSTRAINT "game_status_fkey" FOREIGN KEY ("status") REFERENCES "public"."game_status"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."game"
    ADD CONSTRAINT "game_winner_fkey" FOREIGN KEY ("winner") REFERENCES "public"."player"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."attempt"
    ADD CONSTRAINT "intentos_partida_id_fkey" FOREIGN KEY ("game") REFERENCES "public"."game"("id");

ALTER TABLE ONLY "public"."player_number"
    ADD CONSTRAINT "player_number_player_fkey" FOREIGN KEY ("player") REFERENCES "public"."player"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."ranking"
    ADD CONSTRAINT "ranking_player_fkey" FOREIGN KEY ("player") REFERENCES "public"."player"("id") ON UPDATE CASCADE ON DELETE CASCADE;

CREATE POLICY "Enable insert for authenticated users only" ON "public"."game" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."player_number" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable read access for all users" ON "public"."attempt" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."game" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."game_status" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."player" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."player_number" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."ranking" FOR SELECT USING (true);

ALTER TABLE "public"."attempt" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."game" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."game_status" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."player" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."player_number" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."ranking" ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."create_game"("player_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."create_game"("player_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_game"("player_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."find_or_create_game"("player_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."find_or_create_game"("player_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."find_or_create_game"("player_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_current_game"("player_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_current_game"("player_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_current_game"("player_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";

GRANT ALL ON TABLE "public"."attempt" TO "anon";
GRANT ALL ON TABLE "public"."attempt" TO "authenticated";
GRANT ALL ON TABLE "public"."attempt" TO "service_role";

GRANT ALL ON SEQUENCE "public"."attempt_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."attempt_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."attempt_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."game" TO "anon";
GRANT ALL ON TABLE "public"."game" TO "authenticated";
GRANT ALL ON TABLE "public"."game" TO "service_role";

GRANT ALL ON SEQUENCE "public"."game_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."game_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."game_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."game_status" TO "anon";
GRANT ALL ON TABLE "public"."game_status" TO "authenticated";
GRANT ALL ON TABLE "public"."game_status" TO "service_role";

GRANT ALL ON SEQUENCE "public"."game_status_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."game_status_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."game_status_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."player" TO "anon";
GRANT ALL ON TABLE "public"."player" TO "authenticated";
GRANT ALL ON TABLE "public"."player" TO "service_role";

GRANT ALL ON TABLE "public"."player_number" TO "anon";
GRANT ALL ON TABLE "public"."player_number" TO "authenticated";
GRANT ALL ON TABLE "public"."player_number" TO "service_role";

GRANT ALL ON SEQUENCE "public"."player_number_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."player_number_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."player_number_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."ranking" TO "anon";
GRANT ALL ON TABLE "public"."ranking" TO "authenticated";
GRANT ALL ON TABLE "public"."ranking" TO "service_role";

GRANT ALL ON SEQUENCE "public"."ranking_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."ranking_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."ranking_id_seq" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
