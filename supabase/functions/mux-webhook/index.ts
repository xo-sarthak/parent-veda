// =============================================================================
//  mux-webhook — Mux says a recording is ready (L3, 0128)
// -----------------------------------------------------------------------------
//  livekit-webhook hands Mux a finished class recording; Mux transcodes it
//  and calls this when the asset is ready (or has failed). We write the
//  playback id and status onto programme_recordings. From then on a parent
//  with access can ask recording-playback for a signed, two-hour link.
//
//  WHO MAY CALL. Mux signs each delivery: header `mux-signature:
//  t=<unix seconds>,v1=<hex HMAC-SHA256 of "<t>.<raw body>">` with the
//  webhook's secret. We recompute it over the RAW body and refuse anything
//  older than five minutes, so a captured delivery cannot be replayed later.
//
//  A SECOND DOOR, for the team: POST {"action":"import_pending"} with the
//  service-role key as the bearer imports every recording still waiting in
//  the bucket as 'uploaded' -- the ones that finished before Mux was set up.
//    curl -X POST <project>/functions/v1/mux-webhook \
//      -H "Authorization: Bearer <service role key>" \
//      -d '{"action":"import_pending"}'
//
//  DEPLOY:
//    supabase functions deploy mux-webhook --no-verify-jwt
//  THEN in Mux > Settings > Webhooks: URL
//    https://<project>.supabase.co/functions/v1/mux-webhook
//  SECRETS:
//    MUX_WEBHOOK_SECRET                 (shown on that webhook in Mux)
//    MUX_TOKEN_ID, MUX_TOKEN_SECRET     (for import_pending)
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const WEBHOOK_SECRET = Deno.env.get("MUX_WEBHOOK_SECRET") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const MUX_ID = Deno.env.get("MUX_TOKEN_ID") ?? "";
const MUX_SECRET = Deno.env.get("MUX_TOKEN_SECRET") ?? "";

const json = (body: unknown, status = 200) => {
  if (status >= 400) console.error("mux-webhook refused", status, body);
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
};

async function hmacHex(secret: string, message: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = new Uint8Array(
    await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(message)),
  );
  return Array.from(sig).map((b) => b.toString(16).padStart(2, "0")).join("");
}

function sameText(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let d = 0;
  for (let i = 0; i < a.length; i++) d |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return d === 0;
}

async function verifiedByMux(header: string, raw: string): Promise<boolean> {
  const parts = Object.fromEntries(
    header.split(",").map((p) => p.trim().split("=") as [string, string]),
  );
  const t = Number(parts.t);
  if (!t || !parts.v1) return false;
  if (Math.abs(Date.now() / 1000 - t) > 300) return false; // no replays
  return sameText(await hmacHex(WEBHOOK_SECRET, `${parts.t}.${raw}`), parts.v1);
}

// deno-lint-ignore no-explicit-any
async function importPending(admin: any): Promise<number> {
  const { data: rows } = await admin.from("programme_recordings")
    .select("id, storage_path").eq("status", "uploaded");
  let n = 0;
  for (const r of rows ?? []) {
    const { data: signed } = await admin.storage.from("recordings")
      .createSignedUrl(r.storage_path, 24 * 3600);
    if (!signed?.signedUrl) continue;
    const res = await fetch("https://api.mux.com/video/v1/assets", {
      method: "POST",
      headers: {
        "Authorization": `Basic ${btoa(`${MUX_ID}:${MUX_SECRET}`)}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        input: [{ url: signed.signedUrl }],
        playback_policy: ["signed"],
        video_quality: "basic",
        passthrough: r.id,
      }),
    });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) continue;
    await admin.from("programme_recordings").update({
      status: "importing",
      mux_asset_id: body.data?.id ?? null,
      mux_playback_id: body.data?.playback_ids?.[0]?.id ?? null,
      updated_at: new Date().toISOString(),
    }).eq("id", r.id);
    n++;
  }
  return n;
}

serve(async (req) => {
  if (req.method !== "POST") return json({ error: "POST only" }, 405);
  const admin = createClient(SUPABASE_URL, SERVICE_KEY);
  const raw = await req.text();

  // The team's door.
  const bearer = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  if (bearer && SERVICE_KEY && sameText(bearer, SERVICE_KEY)) {
    if (!MUX_ID || !MUX_SECRET) return json({ error: "Mux keys not set" }, 500);
    const action = (() => {
      try {
        return JSON.parse(raw || "{}").action;
      } catch {
        return null;
      }
    })();
    if (action !== "import_pending") return json({ error: "unknown action" }, 400);
    return json({ ok: true, imported: await importPending(admin) });
  }

  // Mux's door.
  if (!WEBHOOK_SECRET) return json({ error: "MUX_WEBHOOK_SECRET not set" }, 500);
  if (!await verifiedByMux(req.headers.get("mux-signature") ?? "", raw)) {
    return json({ error: "bad signature" }, 401);
  }

  // deno-lint-ignore no-explicit-any
  let event: Record<string, any>;
  try {
    event = JSON.parse(raw);
  } catch {
    return json({ error: "bad json" }, 400);
  }

  const asset = event.data ?? {};
  // passthrough is our recording id; the asset id is the fallback key.
  const recId: string | undefined = asset.passthrough;

  const patch: Record<string, unknown> = { updated_at: new Date().toISOString() };
  if (event.type === "video.asset.ready") {
    patch.status = "ready";
    patch.mux_asset_id = asset.id ?? null;
    if (asset.playback_ids?.[0]?.id) patch.mux_playback_id = asset.playback_ids[0].id;
    if (asset.duration) patch.duration_s = Math.round(Number(asset.duration));
  } else if (event.type === "video.asset.errored") {
    patch.status = "failed";
    patch.error = JSON.stringify(asset.errors ?? {}).slice(0, 1000);
  } else {
    return json({ ok: true, ignored: event.type });
  }

  const q = admin.from("programme_recordings").update(patch);
  const { error } = recId
    ? await q.eq("id", recId)
    : await q.eq("mux_asset_id", asset.id ?? "");
  if (error) return json({ error: error.message }, 500); // Mux retries

  if (patch.status === "failed") {
    await admin.from("ops_alerts").insert({
      kind: "recording_failed",
      ref_id: recId ?? asset.id,
      title: "Mux could not process a class recording",
      detail: { line: String(patch.error).slice(0, 300) },
    });
  }
  return json({ ok: true });
});
