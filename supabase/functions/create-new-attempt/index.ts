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
  const player = "id, username, avatar_url, is_bot";
  const playerNumber = `id, player(${player}), number, time_left, is_turn, started_time, attempts_to_win`;
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

  // Intercambiar el turno de los jugadores
  swapTurns(supabase, ownPlayerNumber, opponent, gameId);
}

// Función para intercambiar turnos y verificar si el oponente es un bot
async function swapTurns(supabase: any, ownPlayerNumber: any, opponent: any, gameId: number) {
  console.log("Starting turn swap...");

  if (ownPlayerNumber && opponent) {
    console.log("Updating own player number...");

    // Asegúrate de que started_time sea un timestamp válido
    const startedTimeInMillis = new Date(ownPlayerNumber.started_time).getTime();
    const elapsedTime = Math.floor((Date.now() - startedTimeInMillis) / 1000); // Convertir a segundos
    const newTimeLeft = Math.max(ownPlayerNumber.time_left - elapsedTime, 0);

    console.log(`Elapsed time: ${elapsedTime}, New time left for own player: ${newTimeLeft}`);

    const { error: updateTimeLeftOwnPlayerError } = await supabase
      .from("player_number")
      .update({
        is_turn: false,
        started_time: new Date().toISOString(),
      })
      .eq("id", ownPlayerNumber.id);

    // Manejar el error para el propio jugador
    if (updateTimeLeftOwnPlayerError) {
      throw new Error(`Error updating own player time left: ${updateTimeLeftOwnPlayerError.message}`);
    }
    console.log("Own player time left updated successfully.");
  } else {
    throw new Error("Invalid started_time value.");
  }

  console.log("Updating opponent player number...");

  const { error: updateTimeLeftOpponentError } = await supabase
    .from("player_number")
    .update({
      is_turn: true,
    })
    .eq("id", opponent.id);

  // Manejar el error para el oponente
  if (updateTimeLeftOpponentError) {
    throw new Error(`Error updating opponent time left: ${updateTimeLeftOpponentError.message}`);
  }
  console.log("Opponent player time left updated successfully.");

  // Verificar si el oponente es un bot
  if (opponent.player.is_bot) {

    // Esperar un tiempo aleatorio entre 10 y 30 segundos
    const randomDelay = Math.floor(Math.random() * (30000 - 10000 + 1)) + 10000; // Entre 10 y 30 segundos
    console.log(`Waiting for ${randomDelay / 1000} seconds for the bot's turn...`);
    await new Promise((resolve) => setTimeout(resolve, randomDelay));

    console.log("Opponent is a bot, waiting for the bot's turn...");

    // Generar un número aleatorio sin repeticiones entre 0 y 9
    const botNumber = generateUniqueRandomNumbers(4);

    // Contar "Toros" y "Vacas" con el número generado para el bot
    const { bulls, cows } = countBullsAndCows(botNumber, ownPlayerNumber.number);

    // Insertar intento para el bot
    const { error: botAttemptError } = await supabase.from("attempt").insert({
      player: opponent.player.id,
      game: gameId,
      number: botNumber,
      bulls,
      cows,
    });

    if (botAttemptError) {
      throw new Error(`Error inserting bot attempt: ${botAttemptError.message}`);
    }
    console.log("Bot attempt inserted successfully with generated number:", botNumber);

    console.log("Reverting opponent turn...");
    const { error: revertTurnError } = await supabase
      .from("player_number")
      .update({
        is_turn: false,
        started_time: new Date().toISOString(),
        attempts_to_win: opponent.attempts_to_win - 1
      })
      .eq("id", opponent.id);

    if (revertTurnError) {
      throw new Error(`Error reverting opponent turn: ${revertTurnError.message}`);
    }
    console.log("Opponent turn reverted successfully.");

    console.log("Updating own turn after bot's turn...");

    const { error: revertOwnTurnError } = await supabase
      .from("player_number")
      .update({
        is_turn: true,
      })
      .eq("id", ownPlayerNumber.id);

    if (revertOwnTurnError) {
      throw new Error(`Error reverting own turn: ${revertOwnTurnError.message}`);
    }
    console.log("Own turn updated successfully after bot's turn.");
  }
}

// Función para generar números aleatorios únicos entre 0 y 9
function generateUniqueRandomNumbers(count) {
  const numbers = new Set();

  while (numbers.size < count) {
    const randomNum = Math.floor(Math.random() * 10); // Generar un número entre 0 y 9
    numbers.add(randomNum);
  }

  return Array.from(numbers);
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