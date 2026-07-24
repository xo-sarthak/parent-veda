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
//  DEPLOY:
//    supabase functions deploy livekit-token
//  SECRETS (already set by you):
//    LIVEKIT_URL, LIVEKIT_API_KEY, LIVEKIT_API_SECRET
//  (SUPABASE_URL / SUPABASE_ANON_KEY are injected automatically.)
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

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

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
    return json({ error: "livekit keys not set" }, 500);
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

    // Service-role client to look the booking up regardless of who owns it —
    // needed because the EXPERT does not own the mother's booking row.
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: booking } = await admin
      .from("booking_bookings")
      .select("user_id, slot_id, status")
      .eq("id", bookingId)
      .maybeSingle();
    if (!booking || booking.status === "cancelled") {
      return json({ error: "no such booking" }, 403);
    }

    // AUTHORISE: the mother who booked it, OR the expert who hosts the slot.
    let allowed = booking.user_id === user.id;
    if (!allowed) {
      const { data: slot } = await admin
        .from("booking_slots")
        .select("expert_id")
        .eq("id", booking.slot_id)
        .maybeSingle();
      if (slot) {
        const { data: ea } = await admin
          .from("expert_accounts")
          .select("expert_id")
          .eq("user_id", user.id)
          .maybeSingle();
        allowed = !!ea && ea.expert_id === slot.expert_id;
      }
    }
    if (!allowed) return json({ error: "not your session" }, 403);

    // Same slot -> same room, so both parties meet.
    const room = `bkroom_${booking.slot_id}`;
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
    return json({ error: String(e) }, 500);
  }
});
