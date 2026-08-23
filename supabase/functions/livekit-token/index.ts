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
//  TWO WAYS IN, because a room has two kinds of person in it:
//    bookingId -> someone holding a seat  (a patient, or a class attendee)
//    slotId    -> the HOST, who holds no seat at their own class and therefore
//                 has no booking id to offer. open_session_room (0079).
//
//  And two kinds of PERMISSION. `canPublish` is no longer an unconditional
//  true: an attendee at a masterclass may subscribe and send data, not
//  publish. That is decided in Postgres and enforced by the media server, so
//  a modified client cannot grant itself a camera in someone's class.
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
  // 1:1 -> parent | expert.  Class -> attendee | host.  The role carries both
  // facts at once: who you are, and which product you are in.
  role?: "parent" | "expert" | "attendee" | "host";
  // Stated by the server, never re-derived here. An attendee at a masterclass
  // is false; everyone else is true. See 0079.
  can_publish?: boolean;
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

// ---------------------------------------------------------------------------
//  mintAndReturn — sign the token, and answer.
//
//  Extracted because there are now TWO ways to arrive at a join context: an
//  attendee or patient via their booking, and a HOST via their slot. They
//  differ entirely in how authorisation is decided and not at all in what
//  happens afterwards — so the "afterwards" is written once. Duplicating it
//  would mean two places to forget to stamp the role.
// ---------------------------------------------------------------------------
async function mintAndReturn(
  ctx: JoinContext,
  user: { id: string },
  // deno-lint-ignore no-explicit-any
  authClient: any,
  name: unknown,
): Promise<Response> {

    // Belt and braces: an `ok: true` with no slot id cannot happen — 0076
    // builds them in the same jsonb_build_object — but the room name is the
    // one value where being wrong is silent. `bkroom_undefined` is a VALID
    // LiveKit room, so the two parties would each sit alone in it, connected,
    // waiting for someone who is in the identical room on the other device.
    const slotId = ctx.slot_id;
    if (!slotId) {
      return json({ error: "no room for this session" }, 500);
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
    // Applies to a class as well now. It was consult-only while group calls
    // were deliberately untouched; 0079 owns them, so a masterclass token also
    // stops being valid long after the masterclass.
    let exp = now + 4 * 3600;
    if (ctx.ends_utc) {
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
    // The role is now four-valued — parent | expert for a consult, attendee |
    // host for a class — so a client can tell not only WHO the other person is
    // but which product it is rendering, without a second lookup.
    const token = await signJwt(
      {
        exp,
        iss: LK_KEY,
        nbf: now,
        sub: user.id, // participant identity
        name: display.slice(0, 40),
        metadata: JSON.stringify({
          role: ctx.role ?? "",
          canPublish: ctx.can_publish !== false,
          capacity: ctx.capacity ?? 0,
          startsUtc: ctx.starts_utc ?? "",
          endsUtc: ctx.ends_utc ?? "",
        }),
        video: {
          room,
          roomJoin: true,
          // THE LINE THAT USED TO PUT FIFTY LIVE CAMERAS IN ONE ROOM.
          //
          // It was an unconditional `true`, so every attendee at a masterclass
          // arrived with permission to publish video and audio — and the client
          // then exercised it at connect. The server decides this now
          // (`can_publish`, 0079): true for a consult's two parties and for a
          // class host, false for an attendee.
          //
          // Enforced HERE rather than by the client politely not publishing,
          // because a permission a client grants itself is not a permission.
          // The media server honours the token; a modified app cannot argue
          // with it.
          //
          // Defaults to TRUE when the field is absent, which is the pre-0079
          // fallback path — degrading to old behaviour beats locking everyone
          // out of a room because a migration has not been applied.
          canPublish: ctx.can_publish !== false,
          canSubscribe: true,
          // Left on for everyone, deliberately: this is the data channel, and
          // it is how an attendee raises a hand or asks a question without
          // being able to speak over the class.
          canPublishData: true,
        },
      },
      LK_SECRET,
    );

    return json({
      url: LK_URL,
      token,
      room,
      // The slot, by name. Moderation is addressed to a slot (a host has no
      // booking), and making the client parse it back out of `bkroom_<id>`
      // would be re-deriving a fact the server is already holding.
      slotId,
      // Echoed for the app: it needs the role and the window to lay the call
      // screen out BEFORE the room connects, and reading its own JWT to find
      // out would mean parsing a credential to learn a fact we already know.
      role: ctx.role ?? "",
      canPublish: ctx.can_publish !== false,
      capacity: ctx.capacity ?? 0,
      startsUtc: ctx.starts_utc ?? "",
      endsUtc: ctx.ends_utc ?? "",
      counterpart: ctx.counterpart ?? "",
    });
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
    // TWO WAYS IN, because there are two kinds of person in a room.
    //
    //   bookingId -> someone who holds a seat. A patient, or an attendee.
    //   slotId    -> the HOST, who holds no seat at their own class and so
    //                has no booking id to offer. See open_session_room (0079)
    //                for why that route needs the slot descriptor too.
    //
    // A caller may not supply both; that would be asking two questions and
    // taking whichever answer it preferred.
    const body = await req.json();
    const { bookingId, slotId, name } = body ?? {};
    if (!bookingId && !slotId) {
      return json({ error: "bookingId or slotId required" }, 400);
    }
    if (bookingId && slotId) {
      return json({ error: "send bookingId or slotId, not both" }, 400);
    }

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

    // ---- THE HOST ROUTE -------------------------------------------------
    // No booking to resolve, so the slot descriptor comes from the host's own
    // catalogue and open_session_room decides whether they may host it. It
    // self-seeds the slot for a class nobody has booked yet — otherwise the
    // teacher of an empty class would have nothing to point a room at.
    //
    // There is deliberately NO fallback for this path: it is new in 0079, and
    // if 0079 is not applied the honest answer is "hosting is not deployed
    // yet", not a silently different kind of join.
    if (slotId) {
      const { data: hostRaw, error: hostErr } = await authClient
        .rpc("open_session_room", {
          p_slot_id: String(slotId),
          p_offering_id: String(body.offeringId ?? ""),
          p_expert_id: String(body.expertId ?? ""),
          p_starts_utc: String(body.startsUtc ?? ""),
          p_duration_min: Number(body.durationMin ?? 60),
          p_capacity: Number(body.capacity ?? 1),
        });
      if (hostErr) {
        return json({
          error: "could not open the session room",
          detail: hostErr.message,
          hint: "is migration 0079 applied?",
        }, 500);
      }
      if (!hostRaw) return json({ error: "not your session", slotId }, 403);
      ctx = hostRaw as JoinContext;
      if (ctx.ok === false) {
        return json({
          error: "outside session window",
          reason: ctx.reason,
          opensUtc: ctx.opens_utc,
          startsUtc: ctx.starts_utc,
          endsUtc: ctx.ends_utc,
        }, 403);
      }
      return await mintAndReturn(ctx, user, authClient, name);
    }

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
    return await mintAndReturn(ctx, user, authClient, name);
  } catch (e) {
    console.error("livekit-token threw", e);
    return json({ error: String(e) }, 500);
  }
});
