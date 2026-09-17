// =============================================================================
//  phone-otp-send — issue a six-digit code to the CALLER'S phone number
// -----------------------------------------------------------------------------
//  Half of verifying a phone as an ATTRIBUTE of a Google-signed-in user (the
//  other half is phone-otp-verify). Not Supabase phone auth, on purpose: see
//  the header of migration 0080 — a number that can only be attached to a
//  session that already exists cannot become a second identity.
//
//  WHO: the user id comes from the verified JWT, never from the body
//  (BACKEND-PATTERNS §14d). The body carries exactly one thing, the phone,
//  and even that is re-normalised here — a client's idea of E.164 is a
//  suggestion.
//
//  WHAT THIS FUNCTION DOES NOT DECIDE: the rate limits, the expiry, the
//  attempt cap. Those are in `phone_otp_issue()` in SQL, in one transaction
//  with the insert, so two racing requests cannot both pass a check. This
//  file generates a code, hashes it, asks SQL for permission, and carries
//  the code to MSG91. If it ever grows a limit check of its own it has gone wrong.
//
//  THE CONTRACT THAT LIVES OUTSIDE THIS REPO — read before touching:
//    The MSG91 template body must be, character for character:
//        <#> Your ParentVeda code is ##OTP##. It expires in 5 minutes.
//        {APP_HASH}
//    where {APP_HASH} is the 11-character Android app signature (see
//    PhoneOtp.appSignature() in lib/services/auth/phone_otp.dart — it differs
//    between the debug and release keystores, so there are TWO of them and the
//    release one is what the template must carry). Google's SMS Retriever
//    only hands an SMS to the app if the hash is on the last line. Leave it
//    out and the code arrives, the boxes stay empty, and nothing logs on
//    either side. Same failure shape as the Ask Veda request body.
//    In India the template is also DLT-registered; changing a word means
//    re-registering it. Budget days, not minutes.
//
//  SECRETS (supabase secrets set ...):
//    MSG91_AUTHKEY            the account auth key
//    MSG91_OTP_TEMPLATE_ID    the approved OTP template
//    PHONE_OTP_MOCK           "true" to skip MSG91 and log the code (dev only)
//
//  DEPLOY (JWT verification ON — this function holds the service_role key):
//    supabase functions deploy phone-otp-send
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { hashCode, normalizePhone, sixDigits } from "../_shared/phone_otp.ts";

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
  const authkey = Deno.env.get("MSG91_AUTHKEY") ?? "";
  const templateId = Deno.env.get("MSG91_OTP_TEMPLATE_ID") ?? "";
  const mock = (Deno.env.get("PHONE_OTP_MOCK") ?? "") === "true";
  if (!url || !anonKey || !serviceKey) {
    return json({ error: "function not configured" }, 500);
  }
  if (!mock && (!authkey || !templateId)) {
    return json({ error: "sms provider not configured" }, 500);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing authorization" }, 401);

  try {
    // 1. WHO — from the token.
    const caller = createClient(url, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user }, error: whoErr } = await caller.auth.getUser();
    if (whoErr || !user) return json({ error: "not signed in" }, 401);

    // 2. WHICH NUMBER — the only thing the body is consulted for.
    const body = await req.json().catch(() => ({}));
    const phone = normalizePhone(body?.phone);
    if (!phone) return json({ error: "invalid_phone" }, 400);

    // 3. MAY WE — SQL decides, atomically with the insert.
    const admin = createClient(url, serviceKey);
    const code = sixDigits();
    const codeHash = await hashCode(user.id, code);
    const { data: otpId, error: issueErr } = await admin.rpc("phone_otp_issue", {
      p_user_id: user.id,
      p_phone: phone,
      p_code_hash: codeHash,
    });
    if (issueErr) {
      const msg = issueErr.message ?? "";
      if (msg.includes("rate_limited:phone")) {
        return json({ error: "rate_limited", scope: "phone", retry_after_seconds: 600 }, 429);
      }
      if (msg.includes("rate_limited:user")) {
        return json({ error: "rate_limited", scope: "user", retry_after_seconds: 86400 }, 429);
      }
      if (msg.includes("invalid_phone")) return json({ error: "invalid_phone" }, 400);
      console.error("[phone-otp-send] issue failed", user.id, msg);
      return json({ error: "could not issue code" }, 500);
    }

    // 4. CARRY IT. The provider only ever sees the code in transit; we keep
    //    the hash. In mock mode the code goes to the function log and no SMS
    //    is sent — the emulator has no SIM to receive one anyway.
    let providerId: string | null = null;
    if (mock) {
      console.log(`[phone-otp-send] MOCK code for ${phone}: ${code}`);
    } else {
      // MSG91 SendOTP v5. `mobile` is digits with country code and no plus;
      // passing `otp` makes MSG91 send OUR code instead of minting its own,
      // which is what keeps verification on this side.
      const q = new URLSearchParams({
        template_id: templateId,
        mobile: phone.slice(1),
        otp: code,
        otp_expiry: "5",
      });
      const res = await fetch(`https://control.msg91.com/api/v5/otp?${q}`, {
        method: "POST",
        headers: { authkey, "Content-Type": "application/json" },
      });
      const out = await res.json().catch(() => ({}));
      if (!res.ok || out?.type !== "success") {
        console.error("[phone-otp-send] msg91 refused", res.status, out);
        return json({ error: "sms_failed" }, 502);
      }
      providerId = typeof out?.request_id === "string" ? out.request_id : null;
    }
    await admin.rpc("phone_otp_sent", {
      p_id: otpId,
      p_provider: mock ? "mock" : "msg91",
      p_provider_message_id: providerId,
    });

    // The code is never in the response — not even in mock. A response body
    // is one debugPrint away from a log line on the phone.
    return json({ sent: true, phone, expires_in_seconds: 300, mock });
  } catch (e) {
    console.error("[phone-otp-send] unexpected", e);
    return json({ error: "unexpected" }, 500);
  }
});
