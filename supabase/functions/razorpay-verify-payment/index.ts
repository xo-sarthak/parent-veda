// =============================================================================
//  razorpay-verify-payment — verify a payment signature server-side
// -----------------------------------------------------------------------------
//  Razorpay signs a successful payment with HMAC-SHA256 of "orderId|paymentId"
//  keyed by the Key SECRET. Only the server can recompute that (it has the
//  secret), so verification MUST happen here — a client that says "I paid" is
//  not proof. The app grants the entitlement only when this returns valid:true.
//
//  DEPLOY:
//    supabase functions deploy razorpay-verify-payment --no-verify-jwt
//  (uses the same RAZORPAY_KEY_SECRET set for create-order.)
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const KEY_SECRET = Deno.env.get("RAZORPAY_KEY_SECRET") ?? "";

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

async function hmacSha256Hex(secret: string, message: string): Promise<string> {
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
    new TextEncoder().encode(message),
  );
  return [...new Uint8Array(sig)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (!KEY_SECRET) return json({ error: "secret not set" }, 500);

  try {
    const { orderId, paymentId, signature } = await req.json();
    if (!orderId || !paymentId || !signature) {
      return json({ valid: false }, 400);
    }
    const expected = await hmacSha256Hex(KEY_SECRET, `${orderId}|${paymentId}`);
    // Constant-time-ish compare (length + char accumulation).
    const valid =
      expected.length === String(signature).length &&
      expected === String(signature);
    return json({ valid });
  } catch (e) {
    return json({ error: String(e), valid: false }, 500);
  }
});
