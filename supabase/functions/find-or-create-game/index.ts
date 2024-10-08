import { createClient } from "jsr:@supabase/supabase-js@2";

const player = "id, username, avatar_url, is_bot";
const playerNumber = `id, player(${player}), number, time_left, is_turn, started_time, attempts_to_win`;
const gameStatus = "id, status";
const gameColumns = `
      id, status!inner(${gameStatus}), player_number1!inner(${playerNumber}), player_number2!inner(${playerNumber}), winner(${player})
    `;

// Servidor
Deno.serve(async (req) => {
  const supabase = createSupabaseClient(req);
  const { playerId } = await req.json(); // Suponemos que el ID del jugador se envía en el cuerpo de la solicitud
  console.log("Player ID received:", playerId);

  try {
    const game = await findOrCreateGame(supabase, playerId);
    console.log("Game found or created:", game);
    return new Response(JSON.stringify(game), { status: 200 });
  } catch (error) {
    console.error("Error in handler:", error);
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});

// Función para esperar un tiempo específico en milisegundos
function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getRandomNumberToAttemptsWin() {
  return Math.floor(Math.random() * (10 - 6 + 1)) + 6;
}

// Función para crear el cliente de Supabase
function createSupabaseClient(req: Request) {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

  console.log("Creating Supabase client with URL:", supabaseUrl);

  return createClient(supabaseUrl, supabaseKey, {
    global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
}

async function pairPlayerWithBot(supabase: any, gameId: number) {
  console.log("Pairing player with bot for game ID:", gameId);
  const { data: success, error } = await supabase.rpc("pair_player_with_bot", { game_id: gameId });

  if (error || !success) {
    console.error("Error pairing player with bot:", error ?? "No success response");
    throw new Error(`Error pairing player with bot: ${error?.message ?? "No success response"}`);
  }
  console.log("Player paired with bot: ", success);
}

// Función para encontrar o crear un juego
async function findOrCreateGame(supabase: any, playerId: string) {
  console.log("Finding or creating game for player ID:", playerId);

  const { data: searchingStatus } = await supabase.from("game_status").select("id").eq("status", "searching").single();

  if (!searchingStatus) {
    console.error('No status with value "searching" found');
    throw new Error('No status with value "searching" found');
  }

  const { data: selectingSecretNumberStatus } = await supabase.from("game_status").select("id").eq("status", "selecting_secret_numbers").single();

  if (!selectingSecretNumberStatus) {
    console.error('No status with value "selecting_secret_numbers" found');
    throw new Error('No status with value "selecting_secret_numbers" found');
  }
  console.log("Searching game...", searchingStatus.id);

  // Buscar un juego existente
  const { data: foundGame } = await supabase.from("game").select("id, player_number1, player_number2").eq("status", searchingStatus.id).single();

  console.log("Found game:", foundGame);

  const playerNumberId = await createPlayerNumber(supabase, playerId, null, null);

  let newGameId: number;

  if (foundGame) {
    console.log("Updating existing game...");
    await updateGame(supabase, foundGame.id, playerNumberId, selectingSecretNumberStatus.id);
  } else {
    console.log("Creating new game...");
    newGameId = await createNewGame(supabase, playerNumberId, searchingStatus.id);

    await wait(5000); // Esperar 5 segundos para que otro jugador se una al juego

    const isSearching = await verifyIfGameIsSearching(supabase, newGameId, searchingStatus.id);
    console.log("Is searching yet?", isSearching);

    if (isSearching) {
      console.log("Updating new game with bot player...");

      await pairPlayerWithBot(supabase, newGameId);
    }
  }
  return supabase
    .from("game")
    .select(gameColumns)
    .eq("id", foundGame ? foundGame.id : newGameId!)
    .single();
}

//  Función para verificar si el juego está en progreso
async function verifyIfGameIsSearching(supabase: any, gameId: number, searchingStatusId: number) {
  console.log("Verifying if game is in progress for game ID:", gameId);

  const { data: foundGame, error } = await supabase.from("game").select("id, status").eq("id", gameId).single();

  if (error) {
    console.error("Error searching game:", error);
    throw new Error(`Error searching game: ${error.message}`);
  }

  console.log("Game status:", foundGame.status);
  if (foundGame.status === searchingStatusId) return true;

  return false;
}

// Función para crear un nuevo juego con el jugador utilizando RPC
async function createNewGame(supabase: any, playerNumberId: number, searchingStatusId: number) {
  console.log("Creating new game...");

  const { data, error } = await supabase.from("game").insert({ player_number1: playerNumberId, status: searchingStatusId }).select("id").single();

  if (error) {
    console.error("Error creating game:", error);
    throw new Error(`Error creating game: ${error.message}`);
  }

  console.log("New game created with ID:", data);
  return data.id; // Devuelve el resultado de la función RPC
}

// Función para actualizar el juego con el jugador encontrado
async function updateGame(supabase: any, gameId: number, playerNumberId: number, selectingSecretNumberStatusId: number) {
  console.log("Updating game ID:", gameId, "with player number ID:", playerNumberId);

  // Actualizar el juego
  const { game, error } = await supabase
    .from("game")
    .update({ player_number2: playerNumberId, status: selectingSecretNumberStatusId })
    .eq("id", gameId)
    .select(gameColumns)
    .single();

  if (error) {
    throw new Error("Error inserting player number");
  }

  console.log("Game updated:", game);
}

// Función para crear un nuevo player_number
async function createPlayerNumber(supabase: any, playerId: string | null, botNumbers: number[] | null, attemptsToWin: number | null) {
  console.log("Creating player number for player ID:", playerId);

  // Insertar player_number para el nuevo jugador
  const { data: playerNumber } = await supabase
    .from("player_number")
    .insert({ player: playerId, number: botNumbers, attempts_to_win: attemptsToWin })
    .select("id")
    .single();

  if (!playerNumber) {
    console.error("Error inserting player number");
    throw new Error("Error inserting player number");
  }

  console.log("Player number created with ID:", playerNumber.id);
  return playerNumber.id;
}

// Función para obtener números únicos aleatorios
function getUniqueRandomDigits() {
  const uniqueNumbers = new Set<number>();

  while (uniqueNumbers.size < 4) {
    const randomNumber = Math.floor(Math.random() * 10);
    uniqueNumbers.add(randomNumber);
  }

  return Array.from(uniqueNumbers);
}
