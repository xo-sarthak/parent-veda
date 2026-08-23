// =============================================================================
//  livekit-moderate — the host controls, done where they can actually work
// -----------------------------------------------------------------------------
//  WHY THIS IS A SERVER FUNCTION AND NOT A BUTTON.
//
//  "Mute all", "remove this person", "let her speak" cannot be implemented on
//  the host's phone, and it is worth being precise about why, because the
//  client-side version LOOKS like it works.
//
//  A LiveKit client controls its OWN tracks and nobody else's. A host tapping
//  "mute everyone" in their app can, at most, send a message asking forty
//  clients to mute themselves — which a modified client ignores, and an
//  offline one never receives. The host would see a muted-looking list while
//  someone's kitchen carried on being broadcast to the class. That is worse
//  than no button: it is a promise the product cannot keep, in the one moment
//  a teacher needs to be sure.
//
//  Real moderation is a SERVER capability. LiveKit exposes it through the
//  RoomService API, authenticated with an admin token signed by the same API
//  Secret this project already holds — the secret that must never reach a
//  phone. So the only place these three actions can honestly live is here.
//
// -----------------------------------------------------------------------------
//  AUTHORISATION IS ONE QUESTION, ASKED IN POSTGRES
// -----------------------------------------------------------------------------
//  `can_moderate_slot(slot_id)` (0079) returns a boolean and nothing else:
//  does this caller host this slot? Same discipline as 0075 — the narrowest
//  answer to the only question being asked — and the same authorisation
//  primitive as everywhere else, `my_expert_ids()`, so a hospital admin
//  moderating their own clinician's class works without a special case.
//
//  This function holds NO service-role credential. It authenticates the caller
//  with the caller's own token, asks the database one yes/no question, and
//  only then mints a LiveKit admin token — which is scoped to the single room
//  it was granted for, never to the whole server.
//
//  DEPLOY:
//    supabase functions deploy livekit-moderate
//  SECRETS (shared with livekit-token, already set):
//    LIVEKIT_URL, LIVEKIT_API_KEY, LIVEKIT_API_SECRET
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
  if (status >= 400) console.error("livekit-moderate refused", status, body);
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
};

// --- the same minimal HS256 signer livekit-token uses ----------------------
// Duplicated rather than shared: Deno edge functions are deployed per folder,
// and a `_shared` import would couple two independently deployable units for
// twenty lines. If a third function needs it, that is the moment to extract.

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

/// An admin token SCOPED TO ONE ROOM. `roomAdmin` without `room` would be a
/// key to every room on the server; naming the room makes the blast radius of
/// this credential exactly the class it was issued for, and it lives 60
/// seconds.
async function adminToken(room: string): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  return await signJwt({
    exp: now + 60,
    iss: LK_KEY,
    nbf: now,
    sub: "moderator",
    video: { room, roomAdmin: true },
  }, LK_SECRET);
}

/// LiveKit's RoomService speaks Twirp — plain POST, JSON in, JSON out.
async function roomService(
  method: string,
  room: string,
  payload: Record<string, unknown>,
): Promise<{ ok: boolean; status: number; body: string }> {
  // The signalling URL is wss://…; the HTTP API is the same host over https.
  const base = LK_URL.replace(/^wss:/, "https:").replace(/^ws:/, "http:")
    .replace(/\/+$/, "");
  const res = await fetch(`${base}/twirp/livekit.RoomService/${method}`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${await adminToken(room)}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });
  return { ok: res.ok, status: res.status, body: await res.text() };
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (!LK_URL || !LK_KEY || !LK_SECRET) {
    return json({
      error: "livekit keys not set",
      has: { url: !!LK_URL, key: !!LK_KEY, secret: !!LK_SECRET },
    }, 500);
  }

  try {
    const { slotId, action, identity } = await req.json() ?? {};
    if (!slotId) return json({ error: "slotId required" }, 400);
    if (!action) return json({ error: "action required" }, 400);

    const authClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization")! },
        },
      },
    );
    const { data: { user } } = await authClient.auth.getUser();
    if (!user) return json({ error: "not authenticated" }, 401);

    // ONE QUESTION, ASKED IN POSTGRES.
    const { data: mayModerate, error: authErr } = await authClient
      .rpc("can_moderate_slot", { p_slot_id: String(slotId) });

    if (authErr) {
      return json({
        error: "authorisation lookup failed",
        detail: authErr.message,
        hint: "is migration 0079 applied?",
      }, 500);
    }
    if (mayModerate !== true) {
      return json({ error: "not your session" }, 403);
    }

    const room = `bkroom_${slotId}`;

    switch (action) {
      // Silence one person's microphone AT THE SERVER. The participant's own
      // client is not consulted and cannot decline.
      case "muteAll": {
        const list = await roomService("ListParticipants", room, { room });
        if (!list.ok) {
          return json({ error: "could not list the room", detail: list.body },
            502);
        }
        const parsed = JSON.parse(list.body || "{}");
        const participants: Array<Record<string, unknown>> =
          parsed.participants ?? [];

        let muted = 0;
        for (const p of participants) {
          // Never mute the host who asked. A teacher muting themselves mid
          // sentence is the most obvious way this could feel broken.
          if (p.identity === user.id) continue;
          const tracks: Array<Record<string, unknown>> =
            (p.tracks as Array<Record<string, unknown>>) ?? [];
          for (const t of tracks) {
            if (t.type !== "AUDIO" || t.muted === true) continue;
            const r = await roomService("MutePublishedTrack", room, {
              room,
              identity: p.identity,
              track_sid: t.sid,
              muted: true,
            });
            if (r.ok) muted++;
          }
        }
        return json({ ok: true, muted });
      }

      // Grant or revoke the right to publish, live, without the participant
      // reconnecting. This is what makes "let her ask her question out loud"
      // possible: the alternative is issuing a new token and rejoining, which
      // drops someone out of the class to let them speak in it.
      case "allowSpeak":
      case "denySpeak": {
        if (!identity) return json({ error: "identity required" }, 400);
        const allow = action === "allowSpeak";
        const r = await roomService("UpdateParticipant", room, {
          room,
          identity,
          permission: {
            can_subscribe: true,
            can_publish: allow,
            can_publish_data: true,
          },
        });
        if (!r.ok) {
          return json({ error: "could not update permissions",
            detail: r.body }, 502);
        }
        return json({ ok: true, identity, canPublish: allow });
      }

      // Remove someone from the room entirely.
      case "remove": {
        if (!identity) return json({ error: "identity required" }, 400);
        const r = await roomService("RemoveParticipant", room, {
          room,
          identity,
        });
        if (!r.ok) {
          return json({ error: "could not remove", detail: r.body }, 502);
        }
        return json({ ok: true, identity });
      }

      // End the class for everyone, rather than leaving forty people in a room
      // with nobody teaching.
      case "endRoom": {
        const r = await roomService("DeleteRoom", room, { room });
        if (!r.ok) {
          return json({ error: "could not end the room", detail: r.body }, 502);
        }
        return json({ ok: true });
      }

      default:
        return json({ error: "unknown action", action }, 400);
    }
  } catch (e) {
    console.error("livekit-moderate threw", e);
    return json({ error: String(e) }, 500);
  }
});
