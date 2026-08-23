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
//  That gate lives in POSTGRES, not here — join_context_for_booking() in 0076
//  (which succeeded join_room_for_booking() in 0075; that one is kept as the
//  fallback for a half-finished deploy). This file signs a JWT and nothing
//  else, which is the only thing that has to happen outside the database. It
//  holds no service-role credential; read 0075 for why it used to, and what
//  that cost.
//
//  0076 also gives it the caller's ROLE, which is stamped into the token as
//  `metadata` and echoed in the response. Before that, doctor and parent got
//  byte-identical tokens and neither app could tell you who was on the call.
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

// What join_context_for_booking (0076) answers with. `ok: false` is a CLOCK
// refusal and carries a reason; the ownership refusals never reach here at all
// because the database returns null for those.
type JoinContext = {
  ok: boolean;
  reason?: string;
  slot_id?: string;
  role?: "parent" | "expert";
  capacity?: number;
  starts_utc?: string;
  ends_utc?: string;
  counterpart?: string;
  opens_utc?: string;
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

    // AUTHORISE — in the database, not here. join_context_for_booking (0076)
    // is security definer and answers with the SLOT ID *and the caller's ROLE*
    // if this caller may join (the parent who booked it, or the expert hosting
    // it via my_expert_ids), and null otherwise.
    //
    // THIS USED TO USE A SERVICE-ROLE CLIENT and it is why joining was broken:
    // the elevated client could not read the table, the `error` was discarded
    // by the destructure, and every failure surfaced as "no such booking" —
    // pointing at the one thing that was fine. Now the only credential in play
    // is the caller's own token, the same one getUser() just validated, so
    // there is no second way to be unauthenticated here.
    //
    // It is also less authority: this function can no longer read any row in
    // any table, only ask one question about one booking.
    //
    // WHY THE FALLBACK BELOW EXISTS. A migration and an edge function deploy
    // are two commands, run by a human, in some order. If this function ships
    // first, `join_context_for_booking` does not exist yet and every join
    // would 500 — a self-inflicted outage on the one path that was working.
    // Falling back to 0075's narrower answer means the worst case of a
    // half-finished deploy is "no role metadata", which the app already
    // tolerates, rather than "nobody can join".
    let ctx: JoinContext | null = null;

    const { data: ctxRaw, error: ctxErr } = await authClient
      .rpc("join_context_for_booking", { p_booking_id: bookingId });

    if (ctxErr) {
      // Distinguish "not deployed yet" from "genuinely broken". Postgres
      // reports an unknown function as 42883; anything else is a real fault
      // and must not be silently papered over by the fallback.
      const undeployed = ctxErr.code === "42883" ||
        /join_context_for_booking/.test(ctxErr.message ?? "");
      if (!undeployed) {
        return json({
          error: "authorisation lookup failed",
          detail: ctxErr.message,
          hint: "is migration 0076 applied?",
        }, 500);
      }

      console.warn("livekit-token: 0076 not applied, falling back to 0075");
      const { data: slotId, error: legacyErr } = await authClient
        .rpc("join_room_for_booking", { p_booking_id: bookingId });

      // Keep the error. A failed CALL and a refused ANSWER are different facts
      // and must not share a message — conflating them is the exact bug above.
      if (legacyErr) {
        return json({
          error: "authorisation lookup failed",
          detail: legacyErr.message,
          hint: "is migration 0075 applied?",
        }, 500);
      }
      if (!slotId) return json({ error: "not your session", bookingId }, 403);

      // No role, no capacity, no window — exactly the pre-0076 behaviour.
      ctx = { ok: true, slot_id: String(slotId) };
    } else if (!ctxRaw) {
      // Deliberately one message for "no such booking" and "not yours": the
      // database returns null for both so ids cannot be probed from here.
      return json({ error: "not your session", bookingId }, 403);
    } else {
      ctx = ctxRaw as JoinContext;
    }

    // A CLOCK refusal, unlike an ownership refusal, is safe to explain — by
    // the time the database checked the time it had already established the
    // caller owns this booking. Pass the reason and the timestamp straight
    // through so the app can say "opens at 4:50 PM" instead of one generic
    // sentence covering six unrelated causes.
    if (ctx.ok === false) {
      return json({
        error: "outside session window",
        reason: ctx.reason,
        opensUtc: ctx.opens_utc,
        startsUtc: ctx.starts_utc,
        endsUtc: ctx.ends_utc,
      }, 403);
    }

    // Belt and braces: an `ok: true` with no slot id cannot happen — 0076
    // builds them in the same jsonb_build_object — but the room name is the
    // one value where being wrong is silent. `bkroom_undefined` is a VALID
    // LiveKit room, so the two parties would each sit alone in it, connected,
    // waiting for someone who is in the identical room on the other device.
    const slotId = ctx.slot_id;
    if (!slotId) {
      return json({ error: "no room for this booking", bookingId }, 500);
    }

    // WHOSE NAME GOES OVER THE VIDEO.
    //
    // The doctor app sends one (it knows its own expert). The parent app has
    // no name on the device — ChildProfileStore holds the CHILD's name, not the
    // parent's — so it sent nothing and every mother appeared to her doctor as
    // "Guest". Cold, and useless in a masterclass with forty of them.
    //
    // Read it here rather than plumbing a name through the app: `profiles` is
    // where onboarding already put it, this call is already authenticated as
    // that user, and RLS lets a caller read their OWN row and no one else's.
    // A client-supplied name would also be a client-supplied name — fine as a
    // label, but the server can do better for free.
    //
    // Falls back to "Parent", never to "Guest": an unfinished profile is not a
    // stranger, and ConsultPatient uses the same word for the same reason.
    let display = (name ?? "").toString().trim();
    if (!display) {
      const { data: profile } = await authClient
        .from("profiles")
        .select("name")
        .eq("id", user.id)
        .maybeSingle();
      display = (profile?.name ?? "").toString().trim();
    }
    if (!display) display = "Parent";

    // Same slot -> same room, so both parties meet.
    const room = `bkroom_${slotId}`;
    const now = Math.floor(Date.now() / 1000);

    // HOW LONG THE TOKEN IS GOOD FOR.
    //
    // It was a flat four hours for everything, which for a 30-minute consult
    // means a credential that outlives its session by seven times. Tie it to
    // the session the caller actually bought, plus a generous tail so an
    // overrunning consult and a mid-call reconnect both still work.
    //
    // Only for consults. A class keeps the old four hours, because narrowing
    // it would change group behaviour and that is a separate pass.
    const isConsult = ctx.capacity === 1;
    let exp = now + 4 * 3600;
    if (isConsult && ctx.ends_utc) {
      const endsSec = Math.floor(Date.parse(ctx.ends_utc) / 1000);
      // Never SHORTER than half an hour from now: a token that expires while
      // someone is still connecting is a worse failure than a slightly long one.
      if (Number.isFinite(endsSec)) {
        exp = Math.max(endsSec + 30 * 60, now + 30 * 60);
      }
    }

    // ROLE TRAVELS WITH THE SESSION, NOT WITH THE CALL SITE.
    //
    // Before this, the apps inferred "am I the doctor or the parent?" from
    // which screen happened to push the call and what strings it passed as
    // widget arguments. That is not an identity, it is a coincidence — and it
    // is why the two apps looked identical in a call.
    //
    // LiveKit hands `metadata` to every participant about every other
    // participant, so stamping it here means both sides learn each other's
    // role from the server that already verified it, with no extra round trip
    // and nothing the client can assert about itself.
    //
    // NOTE: canPublish stays true for everyone. Deriving publish rights from
    // role is the correct end state, but it would change what happens in a
    // group class — and group calls are deliberately untouched in this pass.
    const token = await signJwt(
      {
        exp,
        iss: LK_KEY,
        nbf: now,
        sub: user.id, // participant identity
        name: display.slice(0, 40),
        metadata: JSON.stringify({
          role: ctx.role ?? "",
          capacity: ctx.capacity ?? 0,
          startsUtc: ctx.starts_utc ?? "",
          endsUtc: ctx.ends_utc ?? "",
        }),
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

    return json({
      url: LK_URL,
      token,
      room,
      // Echoed for the app: it needs the role and the window to lay the call
      // screen out BEFORE the room connects, and reading its own JWT to find
      // out would mean parsing a credential to learn a fact we already know.
      role: ctx.role ?? "",
      capacity: ctx.capacity ?? 0,
      startsUtc: ctx.starts_utc ?? "",
      endsUtc: ctx.ends_utc ?? "",
      counterpart: ctx.counterpart ?? "",
    });
  } catch (e) {
    console.error("livekit-token threw", e);
    return json({ error: String(e) }, 500);
  }
});
