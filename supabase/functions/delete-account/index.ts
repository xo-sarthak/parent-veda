// =============================================================================
//  delete-account — erase the CALLER'S OWN account, permanently.
// -----------------------------------------------------------------------------
//  WHY THIS CANNOT LIVE IN THE APP
//  Removing a row from `auth.users` is an admin operation. It needs the
//  service_role key, which bypasses Row-Level Security entirely — a key that
//  can read and delete every user's data in the project. Shipping it inside an
//  APK would put that key on every phone, extractable in about a minute. So the
//  app asks a server it cannot impersonate, and the key never leaves Supabase.
//
//  THE SECURITY PROPERTY THAT MATTERS
//  The user id is taken from the caller's VERIFIED JWT, never from the request
//  body. That distinction is the whole function. If it accepted an id from the
//  body, anyone holding any valid session could delete any account by guessing
//  or reading a uuid — and this endpoint holds a key that would happily comply.
//  So: the token says who you are; the body is not consulted at all.
//
//  Two clients are created, deliberately, for two different jobs:
//    * `caller` — the ANON key plus the user's own Authorization header, used
//      only to ask "who is this?". It has no more power than the app does.
//    * `admin`  — the SERVICE_ROLE key, used only to delete the id the first
//      client just proved. It is never pointed at anything the caller chose.
//
//  WHAT ELSE GOES: everything. Every `user_id` in this schema is declared
//  `references auth.users (id) on delete cascade`, so Postgres removes journal
//  entries, trackers, health records, children, bookings and the profile row in
//  the same transaction. The one deliberate exception is `care_partners`, which
//  is `on delete set null` — a clinic's attribution record survives with the
//  person erased from it, which is the intent: aggregate counts stay honest and
//  no personal data remains.
//
//  DEPLOY (jwt verification ON — do NOT pass --no-verify-jwt here; an unsigned
//  request must never reach a function holding the service_role key):
//    supabase functions deploy delete-account
//
//  No secrets to set: SUPABASE_URL, SUPABASE_ANON_KEY and
//  SUPABASE_SERVICE_ROLE_KEY are injected into every function automatically.
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

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
    // 1. WHO IS ASKING — answered by the token, not by anything they sent us.
    const caller = createClient(url, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user }, error: whoErr } = await caller.auth.getUser();
    if (whoErr || !user) return json({ error: "not signed in" }, 401);

    // 2. DELETE THAT ID, and only that id.
    const admin = createClient(url, serviceKey);
    const { error: delErr } = await admin.auth.admin.deleteUser(user.id);
    if (delErr) {
      console.error("[delete-account] failed for", user.id, delErr.message);
      return json({ error: delErr.message }, 500);
    }

    // Logged deliberately: this is irreversible and unaudited otherwise. The id
    // is all that remains — the row it names no longer exists.
    console.log("[delete-account] deleted", user.id);
    return json({ deleted: true });
  } catch (e) {
    console.error("[delete-account] threw", e);
    return json({ error: "delete failed" }, 500);
  }
});
