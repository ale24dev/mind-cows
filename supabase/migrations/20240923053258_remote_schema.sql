create table "public"."current_min_attempts" (
    "attempts_count" bigint
);


set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_points(player_id uuid, game_id bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  attempts_count INT;
  current_min_attempts INT;
BEGIN
  -- Count the attempts for the specific player in the last game
  SELECT COUNT(*) INTO attempts_count
  FROM attempt
  WHERE game = game_id AND player = player_id;
  
  -- Get the current minimum attempts for the player
  SELECT minimum_attempts INTO current_min_attempts
  FROM ranking
  WHERE player = player_id;

  -- Update points and ensure they're not negative
  UPDATE ranking
  SET points = GREATEST(
                  (games_won * 3) - (games_loss * 3) + 
                  (CASE 
                    WHEN current_min_attempts > 0 THEN FLOOR((100.0 / (current_min_attempts + 5)))
                    ELSE 0 
                  END), 
                  0) -- Ensure points are not negative
  WHERE player = player_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_points(player_id uuid, game_id bigint, is_winner boolean)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  attempts_count INT;
  current_min_attempts INT;
BEGIN
  -- Count attempts for the specific player in the current game
  SELECT COUNT(*) INTO attempts_count
  FROM attempt
  WHERE player = player_id AND game = game_id;

  -- Set current_min_attempts to attempts_count (this could be 0 if no attempts)
  current_min_attempts := attempts_count;

  -- Update points based on whether the player is a winner
  UPDATE ranking
  SET points = GREATEST(
                  points + 
                  CASE 
                    WHEN is_winner THEN 
                      (3 + 
                      (CASE 
                        WHEN current_min_attempts > 0 THEN FLOOR((100.0 / (current_min_attempts + 5)))
                        ELSE 0 
                      END))
                    ELSE 
                      -3
                  END,
                  0) -- Ensure points are not negative
  WHERE player = player_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_points(player_id uuid, game_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  last_attempts INT;
BEGIN
  -- Get the number of attempts for the last game for the specific player
  SELECT COUNT(*) INTO last_attempts
  FROM attempt
  WHERE player_id = player_id AND game_id = game_id;

  -- Update points based on games won, games lost, and the attempts from the last game
  UPDATE ranking
  SET points = (games_won * 3) + (games_loss * -3) +  -- subtracting points for losses
               (CASE 
                  WHEN last_attempts > 0 THEN FLOOR((100.0 / (last_attempts + 5)))
                  ELSE 0 
                END)
  WHERE player = player_id;  -- Assuming player is a UUID in the ranking table
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_positions(winner uuid, loser uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Update points for the winner
  PERFORM update_points(winner);

  -- Update points for the loser
  PERFORM update_points(loser);

  -- Update positions based on points and tie-breaking criteria
  WITH ranked AS (
    SELECT id, 
           ROW_NUMBER() OVER (
             ORDER BY points DESC, 
                      (games_won::FLOAT / NULLIF(games_won + games_loss, 0)) DESC,
                      minimum_attempts ASC,
                      RANDOM()
           ) AS position
    FROM ranking
  )
  UPDATE ranking
  SET position = ranked.position
  FROM ranked
  WHERE ranking.id = ranked.id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_positions(winner uuid, loser uuid, game_id bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Update points for the winner
  PERFORM update_points(winner, game_id, true);

  -- Update points for the loser
  PERFORM update_points(loser, game_id, false);

  -- Update positions based on points and tie-breaking criteria
  WITH ranked AS (
    SELECT id, 
           ROW_NUMBER() OVER (
             ORDER BY points DESC, 
                      (games_won::FLOAT / NULLIF(games_won + games_loss, 0)) DESC,
                      minimum_attempts ASC,
                      RANDOM()
           ) AS position
    FROM ranking
  )
  UPDATE ranking
  SET position = ranked.position
  FROM ranked
  WHERE ranking.id = ranked.id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_ranking()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  loser UUID;
  attempts_count INT;
  current_min_attempts INT;
BEGIN
  -- If the game has finished, get the status ID for "finished"
  IF NEW.status = (SELECT id FROM game_status WHERE status = 'finished' LIMIT 1) THEN
    
    -- Update the winner's games won
    UPDATE ranking
    SET games_won = games_won + 1
    WHERE player = NEW.winner;
    
    -- Determine the loser
    IF NEW.winner = (SELECT player FROM player_number WHERE id = NEW.player_number1) THEN
      SELECT player INTO loser FROM player_number WHERE id = NEW.player_number2;
    ELSE
      SELECT player INTO loser FROM player_number WHERE id = NEW.player_number1;
    END IF;

    -- Update the loser's games lost
    UPDATE ranking
    SET games_loss = games_loss + 1
    WHERE player = loser;

    -- Count the attempts for the winner
    SELECT COUNT(*) INTO attempts_count
    FROM attempt
    WHERE game = NEW.id AND player = NEW.winner;
    
    -- Get the current minimum attempts for the winner
    SELECT minimum_attempts INTO current_min_attempts
    FROM ranking
    WHERE player = NEW.winner;
    
    -- Update minimum attempts if the new count is lower
    IF current_min_attempts = 0 OR attempts_count < current_min_attempts THEN
      UPDATE ranking
      SET minimum_attempts = attempts_count
      WHERE player = NEW.winner;
    END IF;
    
    -- Call update_positions with the winner and loser
    PERFORM update_positions(NEW.winner, loser, NEW.id);
  END IF;
  
  RETURN NEW;
END;
$function$
;

grant delete on table "public"."current_min_attempts" to "anon";

grant insert on table "public"."current_min_attempts" to "anon";

grant references on table "public"."current_min_attempts" to "anon";

grant select on table "public"."current_min_attempts" to "anon";

grant trigger on table "public"."current_min_attempts" to "anon";

grant truncate on table "public"."current_min_attempts" to "anon";

grant update on table "public"."current_min_attempts" to "anon";

grant delete on table "public"."current_min_attempts" to "authenticated";

grant insert on table "public"."current_min_attempts" to "authenticated";

grant references on table "public"."current_min_attempts" to "authenticated";

grant select on table "public"."current_min_attempts" to "authenticated";

grant trigger on table "public"."current_min_attempts" to "authenticated";

grant truncate on table "public"."current_min_attempts" to "authenticated";

grant update on table "public"."current_min_attempts" to "authenticated";

grant delete on table "public"."current_min_attempts" to "service_role";

grant insert on table "public"."current_min_attempts" to "service_role";

grant references on table "public"."current_min_attempts" to "service_role";

grant select on table "public"."current_min_attempts" to "service_role";

grant trigger on table "public"."current_min_attempts" to "service_role";

grant truncate on table "public"."current_min_attempts" to "service_role";

grant update on table "public"."current_min_attempts" to "service_role";


