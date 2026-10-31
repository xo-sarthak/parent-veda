// =============================================================================
//  razorpay-create-order — create a Razorpay order server-side
// -----------------------------------------------------------------------------
//  The app never talks to Razorpay's order API directly, because doing so needs
//  the Key SECRET, which must never ship in a client. This function holds the
//  secret (as a Supabase env var) and returns only the order id + amount.
//
//  SINCE 0126 (L2b) THE SERVER DECIDES THE AMOUNT, for everything.
//
//    * It knows WHO is paying. The caller's JWT is read (getUser) and the
//      order is recorded against that user in `payment_orders` BEFORE
//      Razorpay hears of it (LA-8). An order with no owner cannot be turned
//      into a receipt by verify, so an anonymous caller gets nothing.
//    * An OFFERING is priced by `open_payment_order` -> `price_offering()`,
//      the same function book_slot reads, from an offering id alone. The
//      `amountMinor` the app sends is IGNORED for anything the server knows
//      (LA-4: "pay ₹1 for a ₹2,499 course" is gone).
//    * SHOP `lines` are priced from `public.products`, as since 2026-09-17.
//
//  THE ONE ALLOWANCE, and it is stub-only. Today's app still sends offerings
//  the server cannot price (the 20 bundled consults, LA-30). In payment_mode
//  'stub' those are charged at the phone's figure and the order row says
//  priced_by = 'client', visible rather than silent. In 'live' they are
//  refused with 400. That is how the old app keeps working while the contract
//  moves server-first.
//
//  DEPLOY (no --no-verify-jwt since 0126: the gateway checks the JWT, and the
//  code below reads it):
//    supabase functions deploy razorpay-create-order
//  SECRETS (set once):
//    supabase secrets set RAZORPAY_KEY_ID=rzp_test_...
//    supabase secrets set RAZORPAY_KEY_SECRET=<your test key secret>
//  (SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY are injected.)
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const KEY_ID = Deno.env.get("RAZORPAY_KEY_ID") ?? "";
const KEY_SECRET = Deno.env.get("RAZORPAY_KEY_SECRET") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

type Line = { productId: string; variantId?: string; qty: number };

/// Sum the lines from the products table, in paise. Null = could not price
/// every line (a product missing, or no service key). What happens next is
/// open_payment_order's decision: the client figure in stub mode, a refusal
/// in live mode.
async function priceLines(lines: Line[]): Promise<number | null> {
  if (!SUPABASE_URL || !SERVICE_KEY || lines.length === 0) return null;
  const admin = createClient(SUPABASE_URL, SERVICE_KEY);
  const ids = lines.map((l) => String(l.productId));
  const { data, error } = await admin
    .from("products")
    .select("source_key, price_inr, variants")
    .in("source_key", ids);
  if (error || !data) return null;
  let total = 0;
  for (const l of lines) {
    const row = data.find((r) => r.source_key === l.productId);
    if (!row) return null;
    let unit = Number(row.price_inr ?? 0);
    if (l.variantId && Array.isArray(row.variants)) {
      const v = row.variants.find((x: { id: string }) => x.id === l.variantId);
      if (v && typeof v.price === "number") unit = v.price;
    }
    const qty = Math.max(1, Math.floor(Number(l.qty ?? 1)));
    if (!(unit > 0)) return null;
    total += unit * 100 * qty;
  }
  return total;
}

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
  if (!SUPABASE_URL || !SERVICE_KEY) return json({ error: "server not set" }, 500);

  try {
    // 1) Who is paying. The caller's own token, validated by Auth.
    const authClient = createClient(SUPABASE_URL, ANON_KEY, {
      global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
    });
    const { data: { user } } = await authClient.auth.getUser();
    if (!user) return json({ error: "not signed in" }, 401);

    // couponCode (A4, 0149): the offer she picked at checkout. A preference,
    // not an authority: open_payment_order re-checks it against her own
    // offers and falls back to the best one, so a forged code buys nothing.
    const { amountMinor, offeringId, lines, couponCode } = await req.json();
    const isShop = Array.isArray(lines) && lines.length > 0;
    const clientAmount =
      typeof amountMinor === "number" && amountMinor > 0 ? Math.floor(amountMinor) : null;

    // 2) What it costs: the server's figure, recorded before Razorpay is asked.
    const admin = createClient(SUPABASE_URL, SERVICE_KEY);
    const { data: po, error: poErr } = await admin.rpc("open_payment_order", {
      p_user_id: user.id,
      p_purpose: isShop ? "shop" : "offering",
      p_offering_id: isShop ? null : String(offeringId ?? ""),
      p_server_amount: isShop ? await priceLines(lines as Line[]) : null,
      p_client_amount: clientAmount,
      p_coupon_code:
        !isShop && typeof couponCode === "string" && couponCode.trim() !== ""
          ? couponCode.trim()
          : null,
    });
    if (poErr) return json({ error: poErr.message }, 500);
    if (!po?.ok) return json({ error: po?.reason ?? "refused" }, 400);

    // 3) The Razorpay order, tied back to our row by `receipt` and notes, so
    //    the webhook can find it even if the phone never calls verify.
    const auth = "Basic " + btoa(`${KEY_ID}:${KEY_SECRET}`);
    const res = await fetch("https://api.razorpay.com/v1/orders", {
      method: "POST",
      headers: { Authorization: auth, "Content-Type": "application/json" },
      body: JSON.stringify({
        amount: po.amount_paise, // paise
        currency: "INR",
        receipt: po.payment_order_id,
        notes: {
          payment_order_id: po.payment_order_id,
          offeringId: String(offeringId ?? ""),
          priced_by: po.priced_by,
          mode: po.mode,
        },
      }),
    });

    const order = await res.json();
    if (!res.ok) return json({ error: order }, 400);

    const { error: linkErr } = await admin
      .from("payment_orders")
      .update({ razorpay_order_id: order.id })
      .eq("id", po.payment_order_id);
    // Without the link, verify cannot find whose order this is and would
    // refuse a real payment. Better to fail now, before any money moves.
    if (linkErr) return json({ error: linkErr.message }, 500);

    return json({
      orderId: order.id,
      amount: order.amount,
      paymentOrderId: po.payment_order_id,
    });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
