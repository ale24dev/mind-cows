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
  const playerNumber = `id, player(${player}), number`;
  const gameStatus = "id, status";
  const gameColumns = `
  id, status!inner(${gameStatus}), player_number1!inner(${playerNumber}), player_number2!inner(${playerNumber}), winner(${player})
`;

  // Buscar el game con el player asociado
  const { data: game, error: gameError } = await supabase.from("game").select(gameColumns).eq("id", gameId).limit(1).single();

  if (gameError || !game) throw new Error(`Game not found or error: ${gameError?.message}`);

  // Determinar si el jugador es player_number1 o player_number2
  let opponentNumber;
  console.log("player", playerId);
  console.log("player_number1", game.player_number1.player);
  console.log("player_number2", game.player_number2.player);
  if (game.player_number1.player.id === playerId) {
    opponentNumber = game.player_number2?.number ?? null;
  } else if (game.player_number2.player.id === playerId) {
    opponentNumber = game.player_number1?.number ?? null;
  } else {
    throw new Error("Player is not part of this game");
  }

  // Si el oponente tiene un número, verificar que no sea null
  if (!opponentNumber) throw new Error("Opponent does not have a valid number");

  // Contar "Toros" y "Vacas"
  const { bulls, cows } = countBullsAndCows(p_number, opponentNumber);

  // Insertar el intento con el resultado de "Toros" y "Vacas"
  const { error: attemptError } = await supabase.from("attempt").insert({
    player: playerId,
    game: gameId,
    number: p_number,
    bulls, // Número de toros
    cows, // Número de vacas
  });

  if (attemptError) throw new Error(`Error inserting a new attempt ${attemptError.message}`);
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
