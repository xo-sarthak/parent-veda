// =============================================================================
//  recording-playback — a signed, two-hour link to a recording (L3, LA-9)
// -----------------------------------------------------------------------------
//  THE RULE (LA-9): a paid video is never public. Mux holds it with a SIGNED
//  playback policy, so a playback id alone plays nothing; it needs a token
//  signed with our Mux signing key. This function is the only place that key
//  is used, and it signs only after the database says yes:
//    { recordingId }            -> recording_for_playback (a class recording)
//    { programmeId, lessonId }  -> lesson_video           (a course lesson)
//  Both run as the CALLER (her JWT), and both end in has_course_access
//  (0126), the one access rule, so a refunded parent is refused on her next
//  request.
//
//  WHY TWO HOURS. The token is the copyable part. Two hours covers a class
//  recording watched in one go; the app asks again when it opens the player,
//  so nobody is cut off by expiry, and a link pasted into a group chat is
//  dead by the evening. The trade-off: shorter would be tighter, but a token
//  that expires mid-video needs a player that refreshes it, which is more
//  machinery than this risk is worth today.
//
//  DEPLOY:
//    supabase functions deploy recording-playback
//  SECRETS (Mux > Settings > Signing Keys):
//    MUX_SIGNING_KEY_ID
//    MUX_SIGNING_KEY_PRIVATE   the base64 text exactly as Mux shows it
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const KEY_ID = Deno.env.get("MUX_SIGNING_KEY_ID") ?? "";
const KEY_B64 = Deno.env.get("MUX_SIGNING_KEY_PRIVATE") ?? "";
const TTL_S = 2 * 3600;

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const json = (body: unknown, status = 200) => {
  if (status >= 400) console.error("recording-playback refused", status, body);
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
};

function b64url(input: Uint8Array | string): string {
  const bytes =
    typeof input === "string" ? new TextEncoder().encode(input) : input;
  let bin = "";
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

// --- the Mux key ---------------------------------------------------------------
// Mux hands out an RSA key as base64 of a PEM. Older keys are PKCS#1 ("BEGIN
// RSA PRIVATE KEY"); WebCrypto imports only PKCS#8. PKCS#8 is PKCS#1 wrapped
// in a small ASN.1 envelope naming the algorithm, so we add the envelope.

function derLength(n: number): number[] {
  if (n < 0x80) return [n];
  const out: number[] = [];
  while (n > 0) {
    out.unshift(n & 0xff);
    n >>= 8;
  }
  return [0x80 | out.length, ...out];
}

function pkcs1ToPkcs8(pkcs1: Uint8Array): Uint8Array {
  const version = [0x02, 0x01, 0x00];
  // SEQUENCE { OID rsaEncryption 1.2.840.113549.1.1.1, NULL }
  const algorithm = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7,
    0x0d, 0x01, 0x01, 0x01, 0x05, 0x00];
  const octet = [0x04, ...derLength(pkcs1.length), ...pkcs1];
  const inner = [...version, ...algorithm, ...octet];
  return new Uint8Array([0x30, ...derLength(inner.length), ...inner]);
}

let cachedKey: CryptoKey | null = null;

async function signingKey(): Promise<CryptoKey> {
  if (cachedKey) return cachedKey;
  const pem = atob(KEY_B64.trim());
  const isPkcs1 = pem.includes("BEGIN RSA PRIVATE KEY");
  const body = pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const der = Uint8Array.from(atob(body), (c) => c.charCodeAt(0));
  const bytes = isPkcs1 ? pkcs1ToPkcs8(der) : der;
  // A plain ArrayBuffer: WebCrypto's types refuse a view that might be
  // backed by shared memory.
  const keyData = new ArrayBuffer(bytes.length);
  new Uint8Array(keyData).set(bytes);
  cachedKey = await crypto.subtle.importKey(
    "pkcs8",
    keyData,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  return cachedKey;
}

/// A Mux playback token: RS256, `sub` = the playback id, `aud` = what it
/// unlocks ("v" video, "t" thumbnail), `kid` = which of our keys signed it.
async function muxToken(playbackId: string, aud: "v" | "t", exp: number) {
  const header = b64url(JSON.stringify({ alg: "RS256", typ: "JWT", kid: KEY_ID }));
  const body = b64url(JSON.stringify({ sub: playbackId, aud, exp, kid: KEY_ID }));
  const data = `${header}.${body}`;
  const sig = new Uint8Array(await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    await signingKey(),
    new TextEncoder().encode(data),
  ));
  return `${data}.${b64url(sig)}`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (!KEY_ID || !KEY_B64) return json({ error: "Mux signing key not set" }, 500);

  try {
    const { recordingId, programmeId, lessonId } = await req.json() ?? {};
    const authClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } },
    );
    const { data: { user } } = await authClient.auth.getUser();
    if (!user) return json({ error: "not authenticated" }, 401);

    const { data, error } = recordingId
      ? await authClient.rpc("recording_for_playback", {
        p_recording_id: String(recordingId),
      })
      : await authClient.rpc("lesson_video", {
        p_programme_id: String(programmeId ?? ""),
        p_lesson_id: String(lessonId ?? ""),
      });
    if (error) return json({ error: "lookup failed", detail: error.message }, 500);
    // One answer for "no such video", "not ready" and "not yours": the
    // database returns null for all three, so ids cannot be probed.
    if (!data?.playback_id) return json({ error: "not available" }, 404);

    const exp = Math.floor(Date.now() / 1000) + TTL_S;
    const pb = data.playback_id as string;
    const [v, t] = await Promise.all([muxToken(pb, "v", exp), muxToken(pb, "t", exp)]);
    return json({
      url: `https://stream.mux.com/${pb}.m3u8?token=${v}`,
      thumbnail: `https://image.mux.com/${pb}/thumbnail.jpg?token=${t}`,
      expiresAt: new Date(exp * 1000).toISOString(),
      title: data.title ?? "",
      durationS: data.duration_s ?? null,
      recordingId: data.recording_id,
    });
  } catch (e) {
    console.error("recording-playback threw", e);
    return json({ error: String(e) }, 500);
  }
});
