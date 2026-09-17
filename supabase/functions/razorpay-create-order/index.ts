// =============================================================================
//  razorpay-create-order — create a Razorpay order server-side
// -----------------------------------------------------------------------------
//  The app never talks to Razorpay's order API directly, because doing so needs
//  the Key SECRET, which must never ship in a client. This function holds the
//  secret (as a Supabase env var) and returns only the order id + amount.
//
//  TWO CALLERS SINCE 2026-09-17. A booking sends `amountMinor` + `offeringId`
//  as before. The product store ALSO sends `lines: [{productId, variantId?,
//  qty}]`, and then THE SERVER PRICES THE ORDER from `public.products` —
//  "money is decided server-side, always". A phone can be edited; a price
//  the server looked up cannot. If a line's product is not in the table yet
//  (the unified catalogue is still seed-only until 0083 is loaded), the
//  function falls back to the client's amount and writes
//  `notes.priced_by = "client"` on the Razorpay order, so the fallback is
//  visible in the dashboard rather than silent. Never refuse: a shop that
//  cannot take money because the catalogue table is behind is a worse
//  failure than an auditable one.
//
//  DEPLOY:
//    supabase functions deploy razorpay-create-order --no-verify-jwt
//  SECRETS (set once):
//    supabase secrets set RAZORPAY_KEY_ID=rzp_test_TGxRqeBTGuJAzQ
//    supabase secrets set RAZORPAY_KEY_SECRET=<your test key secret>
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const KEY_ID = Deno.env.get("RAZORPAY_KEY_ID") ?? "";
const KEY_SECRET = Deno.env.get("RAZORPAY_KEY_SECRET") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

type Line = { productId: string; variantId?: string; qty: number };

/// Sum the lines from the products table, in paise. Null = could not price
/// every line (a product missing, or no service key), so the caller falls
/// back to the client amount and says so.
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

  try {
    const { amountMinor, offeringId, lines } = await req.json();
    if (typeof amountMinor !== "number" || amountMinor <= 0) {
      return json({ error: "bad amount" }, 400);
    }

    // Server pricing for product orders; the client's figure only as the
    // audited fallback.
    let chargeMinor = amountMinor;
    let pricedBy = "client";
    if (Array.isArray(lines) && lines.length > 0) {
      const priced = await priceLines(lines as Line[]);
      if (priced !== null && priced > 0) {
        chargeMinor = priced;
        pricedBy = "server";
      }
    } else {
      pricedBy = "offering";
    }

    const auth = "Basic " + btoa(`${KEY_ID}:${KEY_SECRET}`);
    const res = await fetch("https://api.razorpay.com/v1/orders", {
      method: "POST",
      headers: { Authorization: auth, "Content-Type": "application/json" },
      body: JSON.stringify({
        amount: chargeMinor, // paise
        currency: "INR",
        notes: { offeringId: String(offeringId ?? ""), priced_by: pricedBy },
      }),
    });

    const order = await res.json();
    if (!res.ok) return json({ error: order }, 400);
    return json({ orderId: order.id, amount: order.amount });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
