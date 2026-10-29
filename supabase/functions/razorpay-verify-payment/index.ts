// =============================================================================
//  razorpay-verify-payment — verify a payment signature server-side
// -----------------------------------------------------------------------------
//  Razorpay signs a successful payment with HMAC-SHA256 of "orderId|paymentId"
//  keyed by the Key SECRET. Only the server can recompute that (it has the
//  secret), so verification MUST happen here — a client that says "I paid" is
//  not proof.
//
//  SINCE 0126 (L2b) A VALID SIGNATURE WRITES THE RECEIPT (LA-5). Before, this
//  returned `{valid}` and the PHONE decided what the payment bought — edit the
//  prefs and you owned any course. Now:
//
//    1. the caller's JWT names the user (LA-8);
//    2. the signature is checked, as before;
//    3. the order is looked up in `payment_orders` and must be THIS user's —
//       someone else's valid signature does not buy you their course (L.21);
//    4. record_course_purchase() writes the receipt, idempotent on the
//       payment id, so this and the webhook can both arrive and the second
//       does nothing.
//
//  If step 4 fails after a valid signature, it still answers valid: the money
//  has moved, and the webhook (razorpay-webhook) writes the receipt on its
//  retry. Saying "invalid" would tell her the payment failed when it did not.
//
//  Today's app reads only `valid`. `purchaseId` is for L2c.
//
//  DEPLOY (no --no-verify-jwt since 0126):
//    supabase functions deploy razorpay-verify-payment
//  (uses the same RAZORPAY_KEY_SECRET set for create-order.)
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const KEY_SECRET = Deno.env.get("RAZORPAY_KEY_SECRET") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

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

/// Compare every character, whatever the first mismatch: an early return
/// leaks, through timing, how much of a forged signature was right.
function safeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (!KEY_SECRET) return json({ error: "secret not set" }, 500);
  if (!SUPABASE_URL || !SERVICE_KEY) return json({ error: "server not set" }, 500);

  try {
    const authClient = createClient(SUPABASE_URL, ANON_KEY, {
      global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
    });
    const { data: { user } } = await authClient.auth.getUser();
    if (!user) return json({ valid: false, error: "not signed in" }, 401);

    const { orderId, paymentId, signature } = await req.json();
    if (!orderId || !paymentId || !signature) {
      return json({ valid: false }, 400);
    }
    const expected = await hmacSha256Hex(KEY_SECRET, `${orderId}|${paymentId}`);
    if (!safeEqual(expected, String(signature))) return json({ valid: false });

    const admin = createClient(SUPABASE_URL, SERVICE_KEY);
    const { data: po } = await admin
      .from("payment_orders")
      .select("id, user_id")
      .eq("razorpay_order_id", String(orderId))
      .maybeSingle();
    if (!po) return json({ valid: false, error: "unknown order" }, 404);
    if (po.user_id !== user.id) return json({ valid: false, error: "not your order" }, 403);

    const { data: rec, error: recErr } = await admin.rpc("record_course_purchase", {
      p_razorpay_order_id: String(orderId),
      p_razorpay_payment_id: String(paymentId),
      p_via: "verify",
    });
    if (recErr || !rec?.ok) {
      console.error("[verify] receipt not written", recErr?.message ?? rec?.reason);
      return json({ valid: true, receipt: false });
    }
    return json({ valid: true, receipt: true, purchaseId: rec.purchase_id ?? null });
  } catch (e) {
    return json({ error: String(e), valid: false }, 500);
  }
});
