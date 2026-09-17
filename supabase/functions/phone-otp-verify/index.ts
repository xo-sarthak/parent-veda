// =============================================================================
//  phone-otp-verify — check a code against the CALLER'S latest issued one
// -----------------------------------------------------------------------------
//  The second half of phone-otp-send. Hashes the guess the same way, hands it
//  to `phone_otp_consume()` in SQL, and returns the word SQL returned:
//
//      verified | wrong | expired | too_many | none
//
//  A word rather than a boolean because each one is a different sentence on
//  screen (BACKEND-PATTERNS §15b). "Expired — send another" and "Wrong — try
//  again" and "Too many tries — send another" are three different buttons.
//
//  On `verified`, SQL has ALREADY stamped profiles.phone and
//  profiles.phone_verified_at inside the same transaction that consumed the
//  code. This function writes nothing to the profile, deliberately: two
//  writes in two places can disagree, one write in one place cannot.
//
//  WHO: from the token, never the body. The body carries the phone (so the
//  guess is checked against the right number when she changed it mid-flow)
//  and the six digits. Nothing else is read.
//
//  DEPLOY (JWT verification ON — this function holds the service_role key):
//    supabase functions deploy phone-otp-verify
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { hashCode, normalizePhone } from "../_shared/phone_otp.ts";

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

  const url = Deno.env.get("SUPABASE_URL") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!url || !anonKey || !serviceKey) {
    return json({ error: "function not configured" }, 500);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing authorization" }, 401);

  try {
    const caller = createClient(url, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user }, error: whoErr } = await caller.auth.getUser();
    if (whoErr || !user) return json({ error: "not signed in" }, 401);

    const body = await req.json().catch(() => ({}));
    const phone = normalizePhone(body?.phone);
    const code = typeof body?.code === "string" ? body.code.replace(/\D/g, "") : "";
    if (!phone) return json({ error: "invalid_phone" }, 400);
    // Six digits or nothing. A five-digit guess is not "wrong", it is not a
    // guess, and it must not count against the attempt cap.
    if (!/^\d{6}$/.test(code)) return json({ error: "invalid_code" }, 400);

    const admin = createClient(url, serviceKey);
    const { data: outcome, error } = await admin.rpc("phone_otp_consume", {
      p_user_id: user.id,
      p_phone: phone,
      p_code_hash: await hashCode(user.id, code),
    });
    if (error) {
      console.error("[phone-otp-verify] consume failed", user.id, error.message);
      return json({ error: "could not verify" }, 500);
    }

    // 200 for every outcome SQL could name. They are answers, not failures —
    // the HTTP layer is for "could not reach the database", not for "wrong".
    return json({ outcome, verified: outcome === "verified" });
  } catch (e) {
    console.error("[phone-otp-verify] unexpected", e);
    return json({ error: "unexpected" }, 500);
  }
});
