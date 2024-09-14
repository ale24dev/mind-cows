import { createClient } from "jsr:@supabase/supabase-js@2";

// Función para crear el cliente de Supabase
function createSupabaseClient(req: Request) {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

  return createClient(supabaseUrl, supabaseKey, {
    global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
}

async function createNewAttempt(supabase: any, gameId: number, playerId: number, p_number: number[]) {
  const { error: attemptError } = await supabase.from("attempt").insert({
    player: playerId,
    game: gameId,
    number: p_number,
  });

  if (attemptError) throw new Error(`Error inserting a new attempt ${attemptError.message}`);
}

// Servidor
Deno.serve(async (req) => {
  try {
    const supabase = createSupabaseClient(req);
    const { gameId, playerId, p_number } = await req.json();
    await createNewAttempt(supabase, gameId, playerId, p_number);
    console.log("Attempt created successfully");
    return new Response("success", { status: 200 });
  } catch (err) {
    return new Response(String(err?.message ?? err), { status: 500 });
  }
});
