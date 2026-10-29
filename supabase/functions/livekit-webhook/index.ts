// =============================================================================
//  livekit-webhook — what LiveKit saw, written by the server (L3, 0128)
// -----------------------------------------------------------------------------
//  LiveKit calls this when someone joins or leaves a room, when a room ends,
//  and when a recording (egress) ends. Three jobs:
//
//   1. ATTENDANCE (LA-16). participant_joined / participant_left become rows
//      in consult_sessions with source 'livekit' (record_room_event, 0128).
//      Since money depends on attendance, the media server's word replaces
//      the phone's; the phone's report stays only as the fallback for a room
//      LiveKit said nothing about.
//
//   2. RECORDING START (D1). When the HOST of a class joins, start a
//      room-composite egress into the private `recordings` bucket.
//      begin_recording() decides whether to (never a consult, once per
//      session) so a host who reconnects does not start a second one.
//
//   3. RECORDING HAND-OFF (LA-19). egress_ended -> a 24-hour signed URL to
//      the file -> a Mux asset with a SIGNED playback policy. Mux fetches it,
//      and mux-webhook writes the playback id when it is ready.
//
//  WHO MAY CALL. Anyone can reach this URL, so the first thing it does is
//  prove the request came from LiveKit. LiveKit signs every delivery with a
//  JWT in the Authorization header, HS256 with our API secret, carrying a
//  `sha256` claim: the base64 SHA-256 of the exact body. We recompute both.
//  A request that fails either check is refused before anything is parsed
//  into the database. Same discipline as razorpay-webhook: hash the RAW
//  body, never a re-serialised parse of it.
//
//  DEPLOY:
//    supabase functions deploy livekit-webhook --no-verify-jwt
//    (no Supabase JWT: LiveKit cannot send one; the LiveKit signature is
//    the authentication.)
//  THEN in LiveKit Cloud > Settings > Webhooks: URL
//    https://<project>.supabase.co/functions/v1/livekit-webhook
//    signed with the SAME API key livekit-token uses.
//  SECRETS:
//    LIVEKIT_URL, LIVEKIT_API_KEY, LIVEKIT_API_SECRET   (already set)
//    RECORDINGS_S3_KEY, RECORDINGS_S3_SECRET            (Supabase > Storage >
//    RECORDINGS_S3_REGION                                 S3 access keys)
//    RECORDINGS_S3_ENDPOINT  optional; defaults to <SUPABASE_URL>/storage/v1/s3
//    MUX_TOKEN_ID, MUX_TOKEN_SECRET                     (Mux > Access Tokens)
//  Without the S3 keys no recording starts; without Mux a finished file
//  waits in the bucket as 'uploaded' (mux-webhook can import it later).
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const LK_URL = Deno.env.get("LIVEKIT_URL") ?? "";
const LK_KEY = Deno.env.get("LIVEKIT_API_KEY") ?? "";
const LK_SECRET = Deno.env.get("LIVEKIT_API_SECRET") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const S3_KEY = Deno.env.get("RECORDINGS_S3_KEY") ?? "";
const S3_SECRET = Deno.env.get("RECORDINGS_S3_SECRET") ?? "";
const S3_REGION = Deno.env.get("RECORDINGS_S3_REGION") ?? "";
const S3_ENDPOINT = Deno.env.get("RECORDINGS_S3_ENDPOINT") ??
  `${SUPABASE_URL}/storage/v1/s3`;
const MUX_ID = Deno.env.get("MUX_TOKEN_ID") ?? "";
const MUX_SECRET = Deno.env.get("MUX_TOKEN_SECRET") ?? "";

const BUCKET = "recordings";

const json = (body: unknown, status = 200) => {
  if (status >= 400) console.error("livekit-webhook refused", status, body);
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
};

// --- signatures -------------------------------------------------------------

function b64url(input: Uint8Array | string): string {
  const bytes =
    typeof input === "string" ? new TextEncoder().encode(input) : input;
  let bin = "";
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function b64urlDecode(s: string): string {
  const pad = s.replace(/-/g, "+").replace(/_/g, "/") +
    "===".slice((s.length + 3) % 4);
  return atob(pad);
}

async function hmac(secret: string, data: string): Promise<Uint8Array> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  return new Uint8Array(
    await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(data)),
  );
}

async function signJwt(payload: object): Promise<string> {
  const header = b64url(JSON.stringify({ alg: "HS256", typ: "JWT" }));
  const body = b64url(JSON.stringify(payload));
  const data = `${header}.${body}`;
  return `${data}.${b64url(await hmac(LK_SECRET, data))}`;
}

/// Constant-time string compare, so the check does not leak how many leading
/// characters of a forged signature were right.
function sameText(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let d = 0;
  for (let i = 0; i < a.length; i++) d |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return d === 0;
}

/// Is this delivery from LiveKit, and is the body the one it signed?
async function verifiedByLiveKit(auth: string, raw: string): Promise<boolean> {
  const token = auth.replace(/^Bearer\s+/i, "").trim();
  const parts = token.split(".");
  if (parts.length !== 3) return false;
  const expected = b64url(await hmac(LK_SECRET, `${parts[0]}.${parts[1]}`));
  if (!sameText(expected, parts[2])) return false;

  let claims: Record<string, unknown>;
  try {
    claims = JSON.parse(b64urlDecode(parts[1]));
  } catch {
    return false;
  }
  const now = Math.floor(Date.now() / 1000);
  if (claims.iss !== LK_KEY) return false;
  if (typeof claims.exp === "number" && claims.exp < now - 60) return false;
  if (typeof claims.nbf === "number" && claims.nbf > now + 60) return false;

  // The body hash: standard base64 of SHA-256 over the raw bytes.
  const digest = new Uint8Array(
    await crypto.subtle.digest("SHA-256", new TextEncoder().encode(raw)),
  );
  let bin = "";
  for (const b of digest) bin += String.fromCharCode(b);
  return sameText(btoa(bin), String(claims.sha256 ?? ""));
}

// --- LiveKit Egress ---------------------------------------------------------

async function startEgress(room: string, recId: string): Promise<
  { ok: true; egressId: string } | { ok: false; error: string }
> {
  if (!S3_KEY || !S3_SECRET || !S3_REGION) {
    return { ok: false, error: "recording storage keys not set" };
  }
  const now = Math.floor(Date.now() / 1000);
  const token = await signJwt({
    exp: now + 60,
    iss: LK_KEY,
    nbf: now,
    sub: "recorder",
    video: { room, roomRecord: true },
  });
  const base = LK_URL.replace(/^wss:/, "https:").replace(/^ws:/, "http:")
    .replace(/\/+$/, "");
  const res = await fetch(`${base}/twirp/livekit.Egress/StartRoomCompositeEgress`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      room_name: room,
      // The speaker layout: the teacher large. Attendees publish nothing
      // unless the host lets one speak, so a class records as the host.
      layout: "speaker",
      file_outputs: [{
        file_type: "MP4",
        filepath: `${recId}.mp4`,
        s3: {
          access_key: S3_KEY,
          secret: S3_SECRET,
          region: S3_REGION,
          endpoint: S3_ENDPOINT,
          bucket: BUCKET,
          // Supabase's S3 API addresses buckets by path, not by subdomain.
          force_path_style: true,
        },
      }],
    }),
  });
  const text = await res.text();
  if (!res.ok) return { ok: false, error: `${res.status} ${text}` };
  const info = JSON.parse(text || "{}");
  const egressId = info.egress_id ?? info.egressId;
  return egressId ? { ok: true, egressId } : { ok: false, error: "no egress id" };
}

// --- Mux ---------------------------------------------------------------------

// deno-lint-ignore no-explicit-any
async function importToMux(admin: any, recId: string, path: string) {
  if (!MUX_ID || !MUX_SECRET) return; // stays 'uploaded' until Mux is set
  const { data: signed, error } = await admin.storage.from(BUCKET)
    .createSignedUrl(path, 24 * 3600);
  if (error || !signed?.signedUrl) {
    await fail(admin, recId, `signed url: ${error?.message ?? "none"}`);
    return;
  }
  const res = await fetch("https://api.mux.com/video/v1/assets", {
    method: "POST",
    headers: {
      "Authorization": `Basic ${btoa(`${MUX_ID}:${MUX_SECRET}`)}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      input: [{ url: signed.signedUrl }],
      // SIGNED: a playback id is useless without a token we mint per viewer
      // (recording-playback). A public policy would make every link a key.
      playback_policy: ["signed"],
      video_quality: "basic", // free encoding (§6)
      passthrough: recId,
    }),
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) {
    await fail(admin, recId, `mux ${res.status}: ${JSON.stringify(body)}`);
    return;
  }
  await admin.from("programme_recordings").update({
    status: "importing",
    mux_asset_id: body.data?.id ?? null,
    mux_playback_id: body.data?.playback_ids?.[0]?.id ?? null,
    updated_at: new Date().toISOString(),
  }).eq("id", recId);
}

// deno-lint-ignore no-explicit-any
async function fail(admin: any, recId: string, error: string) {
  console.error("livekit-webhook: recording", recId, error);
  await admin.from("programme_recordings").update({
    status: "failed",
    error: error.slice(0, 1000),
    updated_at: new Date().toISOString(),
  }).eq("id", recId);
  await admin.from("ops_alerts").insert({
    kind: "recording_failed",
    ref_id: recId,
    title: "A class recording failed",
    detail: { line: error.slice(0, 300) },
  });
}

// --- the handler ------------------------------------------------------------

serve(async (req) => {
  if (req.method !== "POST") return json({ error: "POST only" }, 405);
  if (!LK_KEY || !LK_SECRET || !SERVICE_KEY) {
    return json({ error: "keys not set" }, 500);
  }

  const raw = await req.text();
  const ok = await verifiedByLiveKit(req.headers.get("Authorization") ?? "", raw);
  if (!ok) return json({ error: "bad signature" }, 401);

  // deno-lint-ignore no-explicit-any
  let event: Record<string, any>;
  try {
    event = JSON.parse(raw);
  } catch {
    return json({ error: "bad json" }, 400);
  }

  const admin = createClient(SUPABASE_URL, SERVICE_KEY);

  try {
    // 1. Attendance, and settling a finished room. Every event is passed in;
    //    the database keeps one copy per event id and ignores the rest.
    const { data: outcome, error } = await admin
      .rpc("record_room_event", { p: event });
    if (error) {
      // A 500 makes LiveKit retry, which is what we want for a transient
      // database failure. The event id makes the retry safe.
      return json({ error: "record_room_event failed", detail: error.message }, 500);
    }

    const room: string = event.room?.name ?? event.egressInfo?.roomName ?? "";

    // 2. The host of a class arrived: start the recording, once.
    if (event.event === "participant_joined" && room.startsWith("bkroom_")) {
      let role = "";
      try {
        role = JSON.parse(event.participant?.metadata || "{}").role ?? "";
      } catch { /* not ours */ }
      if (role === "host") {
        const slotId = room.slice("bkroom_".length);
        const { data: claim } = await admin
          .rpc("begin_recording", { p_slot_id: slotId });
        if (claim?.id) {
          const started = await startEgress(room, claim.id);
          if (started.ok) {
            await admin.from("programme_recordings").update({
              status: "recording",
              egress_id: started.egressId,
              storage_path: `${claim.id}.mp4`,
              updated_at: new Date().toISOString(),
            }).eq("id", claim.id);
          } else {
            await fail(admin, claim.id, `egress start: ${started.error}`);
          }
        }
      }
    }

    // 3. The recording is in the bucket: hand it to Mux.
    if (event.event === "egress_ended") {
      const info = event.egressInfo ?? {};
      const egressId = info.egressId ?? info.egress_id;
      const { data: rec } = await admin.from("programme_recordings")
        .select("id, storage_path").eq("egress_id", egressId).maybeSingle();
      if (rec) {
        const file = (info.fileResults ?? info.file_results ?? [])[0] ?? {};
        const complete = String(info.status ?? "").includes("COMPLETE");
        if (!complete || !file.filename) {
          await fail(admin, rec.id, `egress ${info.status}: ${info.error ?? ""}`);
        } else {
          // Duration arrives in nanoseconds (int64, as a string).
          const ns = Number(file.duration ?? 0);
          const path = String(file.filename);
          await admin.from("programme_recordings").update({
            status: "uploaded",
            storage_path: path,
            duration_s: ns > 0 ? Math.round(ns / 1e9) : null,
            updated_at: new Date().toISOString(),
          }).eq("id", rec.id);
          await importToMux(admin, rec.id, path);
        }
      }
    }

    return json({ ok: true, outcome });
  } catch (e) {
    console.error("livekit-webhook threw", e);
    return json({ error: String(e) }, 500);
  }
});
