alter table "public"."player_number" alter column "time_left" set default '600'::smallint;

alter table "public"."ranking" add column "points" smallint not null default '0'::smallint;

alter table "public"."ranking" add column "position" smallint not null default '0'::smallint;

alter table "public"."ranking" alter column "minimum_attempts" set default 0;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_points()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE ranking
  SET points = (games_won * 3) + (games_loss * 0) + 
               (CASE 
                  WHEN minimum_attempts > 0 THEN FLOOR((100.0 / (minimum_attempts + 5)))
                  ELSE 0 
                END)
  WHERE minimum_attempts > 0;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_positions()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Primero, calcular y actualizar los puntos
  PERFORM update_points();

  -- Luego, actualizar las posiciones basado en los nuevos puntos y criterios de desempate
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
  -- Si el juego ha terminado, obtener el id del estado "finished"
  IF NEW.status = (SELECT id FROM game_status WHERE status = 'finished' LIMIT 1) THEN
    
    -- Actualizar el jugador ganador
    UPDATE ranking
    SET games_won = games_won + 1
    WHERE player = NEW.winner;
    
    -- Determinar el perdedor
    IF NEW.winner = (SELECT player FROM player_number WHERE id = NEW.player_number1) THEN
      SELECT player INTO loser FROM player_number WHERE id = NEW.player_number2;
    ELSE
      SELECT player INTO loser FROM player_number WHERE id = NEW.player_number1;
    END IF;

    -- Actualizar el jugador perdedor
    UPDATE ranking
    SET games_loss = games_loss + 1
    WHERE player = loser;

    -- Contar los intentos del ganador en la tabla "attempt"
    SELECT COUNT(*) INTO attempts_count
    FROM attempt
    WHERE game = NEW.id AND player = NEW.winner;
    
    -- Obtener el valor actual de "minimum_attempts" del ganador
    SELECT minimum_attempts INTO current_min_attempts
    FROM ranking
    WHERE player = NEW.winner;
    
    -- Si "minimum_attempts" es 0 o los intentos actuales son menores, actualizar
    IF current_min_attempts = 0 OR attempts_count < current_min_attempts THEN
      UPDATE ranking
      SET minimum_attempts = attempts_count
      WHERE player = NEW.winner;
    END IF;
    
    PERFORM update_positions();
  END IF;
  
  RETURN NEW;
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

  insert into public.ranking (player) values (new.id);
  return new;
end;
$function$
;

create policy "Enable insert for authenticated users only"
on "public"."ranking"
as permissive
for insert
to authenticated
with check (true);


create policy "update_ranking"
on "public"."ranking"
as permissive
for update
to authenticated
using (true);


CREATE TRIGGER update_ranking_trigger AFTER UPDATE ON public.game FOR EACH ROW EXECUTE FUNCTION update_ranking();


