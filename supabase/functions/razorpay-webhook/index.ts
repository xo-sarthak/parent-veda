// =============================================================================
//  razorpay-webhook — Razorpay tells the server what happened (LA-11)
// -----------------------------------------------------------------------------
//  THE BACKSTOP. Verify (razorpay-verify-payment) is called by the PHONE right
//  after checkout. A phone can die, lose signal or be killed between "paid" and
//  "verify", and then a parent has paid for something she does not own. Razorpay
//  calls this endpoint itself, and retries it until it gets a 2xx, so a receipt
//  written here does not depend on the phone at all.
//
//  WHY IT HAS NO JWT. Razorpay is not a Supabase user and cannot send one, so
//  this is deployed with --no-verify-jwt. Its authentication is the
//  X-Razorpay-Signature header: an HMAC-SHA256 of the RAW body, keyed by the
//  webhook secret set in the Razorpay dashboard. The body must be hashed
//  exactly as received — parse it first and re-serialise, and the bytes (key
//  order, spacing) change and every signature fails.
//
//  WHY IT IS SAFE TO RECEIVE TWICE. Every event carries X-Razorpay-Event-Id.
//  It is recorded in payment_webhook_events; an event already processed is
//  acknowledged and skipped. Underneath that, record_course_purchase and
//  record_refund are idempotent on the payment id anyway, so even a
//  half-processed retry lands on the same rows. Two layers, because the cheap
//  one (the event id) is the one that can be wrong.
//
//  EVENTS:
//    payment.captured, order.paid  -> record_course_purchase (via 'webhook')
//    payment.failed                -> the order is marked failed (history)
//    refund.processed              -> record_refund: access revoked, the
//                                     purchase and any shop order marked
//  Anything else is acknowledged and ignored.
//
//  DEPLOY:
//    supabase functions deploy razorpay-webhook --no-verify-jwt
//  SECRETS:
//    supabase secrets set RAZORPAY_WEBHOOK_SECRET=<the secret you type in the
//      Razorpay dashboard's webhook form; it is NOT the key secret>
//  RAZORPAY DASHBOARD (test mode) -> Settings -> Webhooks -> Add:
//    URL     https://<project-ref>.supabase.co/functions/v1/razorpay-webhook
//    Events  payment.captured, payment.failed, order.paid, refund.processed
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const WEBHOOK_SECRET = Deno.env.get("RAZORPAY_WEBHOOK_SECRET") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
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

function safeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

serve(async (req) => {
  if (req.method !== "POST") return json({ error: "POST only" }, 405);
  if (!WEBHOOK_SECRET || !SUPABASE_URL || !SERVICE_KEY) {
    return json({ error: "not configured" }, 500);
  }

  // The RAW body, hashed before anything parses it.
  const raw = await req.text();
  const given = req.headers.get("x-razorpay-signature") ?? "";
  const expected = await hmacSha256Hex(WEBHOOK_SECRET, raw);
  if (!safeEqual(expected, given)) return json({ error: "bad signature" }, 400);

  let body: any;
  try {
    body = JSON.parse(raw);
  } catch {
    return json({ error: "bad json" }, 400);
  }
  const event = String(body?.event ?? "");
  const eventId = req.headers.get("x-razorpay-event-id") ??
    `${event}:${body?.payload?.payment?.entity?.id ?? body?.payload?.refund?.entity?.id ?? ""}`;

  const admin = createClient(SUPABASE_URL, SERVICE_KEY);

  // Seen before and finished? Acknowledge and stop.
  await admin.from("payment_webhook_events")
    .upsert({ event_id: eventId, event, payload: body }, { onConflict: "event_id", ignoreDuplicates: true });
  const { data: seen } = await admin.from("payment_webhook_events")
    .select("processed_at").eq("event_id", eventId).maybeSingle();
  if (seen?.processed_at) return json({ ok: true, duplicate: true });

  try {
    if (event === "payment.captured" || event === "order.paid") {
      const p = body?.payload?.payment?.entity;
      if (p?.order_id && p?.id) {
        const { data, error } = await admin.rpc("record_course_purchase", {
          p_razorpay_order_id: String(p.order_id),
          p_razorpay_payment_id: String(p.id),
          p_via: "webhook",
        });
        if (error) throw new Error(error.message);
        // unknown_order is an order this system did not create (an old one, a
        // dashboard link). Acknowledge it: retrying will never make it ours.
        if (!data?.ok && data?.reason !== "unknown_order") {
          console.error("[webhook] purchase not recorded", data?.reason);
        }
      }
    } else if (event === "payment.failed") {
      const p = body?.payload?.payment?.entity;
      if (p?.order_id) {
        const { error } = await admin.rpc("record_payment_failed", {
          p_razorpay_order_id: String(p.order_id),
        });
        if (error) throw new Error(error.message);
      }
    } else if (event === "refund.processed") {
      const r = body?.payload?.refund?.entity;
      if (r?.payment_id) {
        const { error } = await admin.rpc("record_refund", {
          p_razorpay_payment_id: String(r.payment_id),
          p_refund_id: String(r.id ?? ""),
          p_refund_paise: Number(r.amount ?? 0),
        });
        if (error) throw new Error(error.message);
      }
    }

    await admin.from("payment_webhook_events")
      .update({ processed_at: new Date().toISOString() }).eq("event_id", eventId);
    return json({ ok: true });
  } catch (e) {
    // A 5xx makes Razorpay retry; processed_at stays empty so the retry runs.
    console.error("[webhook]", event, String(e));
    return json({ error: String(e) }, 500);
  }
});
