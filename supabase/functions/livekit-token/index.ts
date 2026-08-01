// =============================================================================
//  livekit-token — mint a LiveKit join token for a booked session
// -----------------------------------------------------------------------------
//  A LiveKit token is a JWT signed with the API Secret that says "this person
//  may join this room." Signing needs the Secret, so it MUST happen server-side
//  — never in the app. This is the LiveKit cousin of the Razorpay functions.
//
//  THE SECURITY GATE: it only issues a token if the caller actually holds the
//  booking they're asking to join. The room name is derived from the booking's
//  SLOT, so the mother and the expert of the same session land in the same room
//  automatically.
//
//  That gate lives in POSTGRES, not here — join_room_for_booking() in 0075.
//  This file signs a JWT and nothing else, which is the only thing that has to
//  happen outside the database. It holds no service-role credential; read 0075
//  for why it used to, and what that cost.
//
//  DEPLOY:
//    supabase functions deploy livekit-token
//  SECRETS (already set by you):
//    LIVEKIT_URL, LIVEKIT_API_KEY, LIVEKIT_API_SECRET
//  (SUPABASE_URL / SUPABASE_ANON_KEY are injected automatically.)
//  SUPABASE_SERVICE_ROLE_KEY is deliberately NOT used.
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const LK_URL = Deno.env.get("LIVEKIT_URL") ?? "";
const LK_KEY = Deno.env.get("LIVEKIT_API_KEY") ?? "";
const LK_SECRET = Deno.env.get("LIVEKIT_API_SECRET") ?? "";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const json = (body: unknown, status = 200) => {
  // LOG EVERY REFUSAL. Without this the function returns an error object and
  // says nothing, the Dart client throws the body away (invokeEdge returns
  // null on any 4xx/5xx), and the app shows one generic message for six
  // different causes. Debugging that means guessing.
  if (status >= 400) console.error("livekit-token refused", status, body);
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
};

// --- minimal JWT (HS256), the format LiveKit expects -----------------------

function b64url(input: Uint8Array | string): string {
  const bytes =
    typeof input === "string" ? new TextEncoder().encode(input) : input;
  let bin = "";
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function signJwt(payload: object, secret: string): Promise<string> {
  const header = b64url(JSON.stringify({ alg: "HS256", typ: "JWT" }));
  const body = b64url(JSON.stringify(payload));
  const data = `${header}.${body}`;
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(data),
  );
  return `${data}.${b64url(new Uint8Array(sig))}`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (!LK_URL || !LK_KEY || !LK_SECRET) {
    // Which one is missing, not just that one is. Says whether a value is
    // PRESENT, never what it is.
    return json({
      error: "livekit keys not set",
      has: { url: !!LK_URL, key: !!LK_KEY, secret: !!LK_SECRET },
      urlLooksRight: LK_URL.startsWith("wss://"),
    }, 500);
  }

  try {
    const { bookingId, name } = await req.json();
    if (!bookingId) return json({ error: "bookingId required" }, 400);

    // Who is calling? (their JWT identifies them)
    const authClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } },
    );
    const { data: { user } } = await authClient.auth.getUser();
    if (!user) return json({ error: "not authenticated" }, 401);

    // AUTHORISE — in the database, not here. join_room_for_booking (0075) is
    // security definer and answers with the SLOT ID if this caller may join
    // (the parent who booked it, or the expert hosting it via my_expert_ids),
    // and null otherwise.
    //
    // THIS USED TO USE A SERVICE-ROLE CLIENT and it is why joining was broken:
    // the elevated client could not read the table, the `error` was discarded
    // by the destructure, and every failure surfaced as "no such booking" —
    // pointing at the one thing that was fine. Now the only credential in play
    // is the caller's own token, the same one getUser() just validated, so
    // there is no second way to be unauthenticated here.
    //
    // It is also less authority: this function can no longer read any row in
    // any table, only ask one yes/no question about one booking.
    const { data: slotId, error: authErr } = await authClient
      .rpc("join_room_for_booking", { p_booking_id: bookingId });

    // Keep the error. A failed CALL and a refused ANSWER are different facts
    // and must not share a message — conflating them is the exact bug above.
    if (authErr) {
      return json({
        error: "authorisation lookup failed",
        detail: authErr.message,
        hint: "is migration 0075 applied?",
      }, 500);
    }
    if (!slotId) {
      // Deliberately one message for "no such booking" and "not yours": the
      // database returns null for both so ids cannot be probed from here.
      return json({ error: "not your session", bookingId }, 403);
    }

    // Same slot -> same room, so both parties meet.
    const room = `bkroom_${slotId}`;
    const now = Math.floor(Date.now() / 1000);
    const token = await signJwt(
      {
        exp: now + 4 * 3600, // good for the session
        iss: LK_KEY,
        nbf: now,
        sub: user.id, // participant identity
        name: (name ?? "Guest").toString().slice(0, 40),
        video: {
          room,
          roomJoin: true,
          canPublish: true,
          canSubscribe: true,
          canPublishData: true,
        },
      },
      LK_SECRET,
    );

    return json({ url: LK_URL, token, room });
  } catch (e) {
    console.error("livekit-token threw", e);
    return json({ error: String(e) }, 500);
  }
});
