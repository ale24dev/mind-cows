import { createClient } from "jsr:@supabase/supabase-js@2";

// Función para crear el cliente de Supabase
function createSupabaseClient(req: Request) {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

  return createClient(supabaseUrl, supabaseKey, {
    global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
}

// Función para contar toros (bulls) y vacas (cows)
function countBullsAndCows(playerNumber: number[], opponentNumber: number[]) {
  let bulls = 0;
  let cows = 0;

  // Convertimos a string para facilitar la comparación
  const opponentNumberStr = opponentNumber.map(String);
  const playerNumberStr = playerNumber.map(String);

  // Crear un array para marcar las posiciones ya contadas como "Toros"
  const checkedPositions = Array(4).fill(false);

  // Contar los "Toros" (coincidencias exactas en posición y número)
  for (let i = 0; i < 4; i++) {
    if (playerNumberStr[i] === opponentNumberStr[i]) {
      bulls++;
      checkedPositions[i] = true; // Marcar la posición como "Toro"
    }
  }

  // Contar las "Vacas" (número correcto pero en posición diferente)
  for (let i = 0; i < 4; i++) {
    if (playerNumberStr[i] !== opponentNumberStr[i]) {
      // Buscar si el número aparece en otra posición no marcada como "Toro"
      const cowIndex = opponentNumberStr.findIndex((num, idx) => num === playerNumberStr[i] && !checkedPositions[idx]);
      if (cowIndex !== -1) {
        cows++;
        checkedPositions[cowIndex] = true; // Marcar la posición para evitar contar de nuevo
      }
    }
  }

  return { bulls, cows };
}

// Función para verificar el game, player numbers, y actualizar el intento
async function verifyAndInsertAttempt(supabase: any, gameId: number, playerId: number, p_number: number[]) {
  // Variables estáticas que representan las columnas en las consultas
  const player = "id, username, avatar_url";
  const playerNumber = `id, player(${player}), number, time_left, is_turn, started_time`;
  const gameStatus = "id, status";
  const gameColumns = `
  id, status!inner(${gameStatus}), player_number1!inner(${playerNumber}), player_number2!inner(${playerNumber}), winner(${player})
`;

  // Buscar el game con el player asociado
  const { data: game, error: gameError } = await supabase.from("game").select(gameColumns).eq("id", gameId).limit(1).single();

  if (gameError || !game) throw new Error(`Game not found or error: ${gameError?.message}`);

  // Determinar si el jugador es player_number1 o player_number2
  let opponent;
  let ownPlayerNumber;
  if (game.player_number1.player.id === playerId) {
    opponent = game.player_number2 ?? null;
    ownPlayerNumber = game.player_number1 ?? null;
  } else if (game.player_number2.player.id === playerId) {
    opponent = game.player_number1 ?? null;
    ownPlayerNumber = game.player_number2 ?? null;
  } else {
    throw new Error("Player is not part of this game");
  }

  // Si el oponente tiene un número, verificar que no sea null
  if (!opponent.number) throw new Error("Opponent does not have a valid number");

  // Contar "Toros" y "Vacas"
  const { bulls, cows } = countBullsAndCows(p_number, opponent.number);

  // Insertar el intento con el resultado de "Toros" y "Vacas"
  const { error: attemptError } = await supabase.from("attempt").insert({
    player: playerId,
    game: gameId,
    number: p_number,
    bulls, // Número de toros
    cows, // Número de vacas
  });
  console.log("Opponent Player Number:", opponent);
  console.log("Own Player Number:", ownPlayerNumber);

  // Intercambiar el turno de los jugadores
  if (ownPlayerNumber && opponent) {
    // Asegúrate de que started_time sea un timestamp válido
    console.log("ownPlayerNumber.started_time:", ownPlayerNumber.started_time);
    const startedTimeInMillis = new Date(ownPlayerNumber.started_time).getTime();
    console.log("startedTimeInMillis:", startedTimeInMillis);
    const elapsedTime = Math.floor((Date.now() - startedTimeInMillis) / 1000); // Convertir a segundos
    const newTimeLeft = Math.max(ownPlayerNumber.time_left - elapsedTime, 0);

    console.log("Elapsed Time:", elapsedTime);
    console.log("newTimeLeft:", newTimeLeft);

    const { error: updateTimeLeftOwnPlayerError } = await supabase
      .from("player_number")
      .update({
        is_turn: false,
        started_time: null,
        time_left: newTimeLeft, // Asegurarse de que no sea null
      })
      .eq("id", ownPlayerNumber.id);

    // Manejar el error para el propio jugador
    if (updateTimeLeftOwnPlayerError) {
      throw new Error(`Error updating own player time left: ${updateTimeLeftOwnPlayerError.message}`);
    }
  } else {
    console.error("started_time is not valid:", ownPlayerNumber.started_time);
    throw new Error("Invalid started_time value.");
  }
  const { error: updateTimeLeftOpponentError } = await supabase
    .from("player_number")
    .update({
      is_turn: true,
      started_time: new Date().toISOString(),
    })
    .eq("id", opponent.id);

  // Manejar el error para el oponente
  if (updateTimeLeftOpponentError) {
    throw new Error(`Error updating opponent time left: ${updateTimeLeftOpponentError.message}`);
  }
}
// Servidor
Deno.serve(async (req) => {
  try {
    const supabase = createSupabaseClient(req);
    const { gameId, playerId, p_number } = await req.json();
    await verifyAndInsertAttempt(supabase, gameId, playerId, p_number);
    console.log("Attempt created successfully with bulls and cows");
    return new Response("success", { status: 200 });
  } catch (err) {
    return new Response(String(err?.message ?? err), { status: 500 });
  }
});
