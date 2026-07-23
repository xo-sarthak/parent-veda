// =============================================================================
//  razorpay-create-order — create a Razorpay order server-side
// -----------------------------------------------------------------------------
//  The app never talks to Razorpay's order API directly, because doing so needs
//  the Key SECRET, which must never ship in a client. This function holds the
//  secret (as a Supabase env var) and returns only the order id + amount.
//
//  DEPLOY:
//    supabase functions deploy razorpay-create-order --no-verify-jwt
//  SECRETS (set once):
//    supabase secrets set RAZORPAY_KEY_ID=rzp_test_TGxRqeBTGuJAzQ
//    supabase secrets set RAZORPAY_KEY_SECRET=<your test key secret>
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const KEY_ID = Deno.env.get("RAZORPAY_KEY_ID") ?? "";
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

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (!KEY_ID || !KEY_SECRET) return json({ error: "keys not set" }, 500);

  try {
    const { amountMinor, offeringId } = await req.json();
    if (typeof amountMinor !== "number" || amountMinor <= 0) {
      return json({ error: "bad amount" }, 400);
    }

    const auth = "Basic " + btoa(`${KEY_ID}:${KEY_SECRET}`);
    const res = await fetch("https://api.razorpay.com/v1/orders", {
      method: "POST",
      headers: { Authorization: auth, "Content-Type": "application/json" },
      body: JSON.stringify({
        amount: amountMinor, // paise
        currency: "INR",
        notes: { offeringId: String(offeringId ?? "") },
      }),
    });

    const order = await res.json();
    if (!res.ok) return json({ error: order }, 400);
    return json({ orderId: order.id, amount: order.amount });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
