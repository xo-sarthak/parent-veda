// =============================================================================
//  push-send — hand every due push to Firebase Cloud Messaging (6b, B4)
// -----------------------------------------------------------------------------
//  WHAT IT KNOWS, AND WHAT IT DOES NOT
//  It reads rows ONLY from `pv_push_due()` and writes results ONLY through
//  `pv_push_mark()` (migration 0144). It knows no table. Which rows are due,
//  the 19:00 start, the 21:00 cutoff, which devices can open the link: all of
//  that is the queue's branch in SQL. Community (phase 3) adds its queue there
//  and never edits this file. docs/NOTIFICATIONS-6B-PLAN.md, "As built: B4".
//
//  WHO CALLS IT
//  `pv_push_tick()`, from pg_cron every minute through pg_net, and only when
//  something is due. It sends `Authorization: Bearer <PUSH_SEND_SECRET>`.
//  A dedicated secret, not the service-role key: leaked, it lets someone make
//  due rows go out a minute early, and nothing else.
//
//  FCM HTTP v1
//  One request per device token (v1 has no multicast). A Google OAuth token
//  is minted from the service account (an RS256-signed JWT, exchanged at
//  Google's token endpoint) and kept for the life of this warm instance.
//    UNREGISTERED          the app is gone from that phone: the token is
//                          dropped (pv_push_mark's dead_tokens)
//    429, 5xx, network     short: the row goes back to `queued` and the next
//                          minute tries again, until its cutoff ends it
//    anything else         permanent for that device
//  A row is `sent` when at least one device took it.
//
//  SECRETS (Edge Functions → Secrets in the dashboard):
//    FCM_SERVICE_ACCOUNT   the whole service-account JSON (firebase-adminsdk)
//    PUSH_SEND_SECRET      any long random string; the same value in Vault
//                          as 'push_send_secret' (0144's SETUP)
//  SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are injected automatically.
//
//  DEPLOY (a cron calls it, there is no user JWT, so verify-jwt is off and
//  the function checks its own secret):
//    supabase functions deploy push-send --no-verify-jwt
//
//  COST: FCM is free. One invocation per minute that has something due:
//  a handful an evening, inside the plan, about $0 / ₹0.
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Rows claimed per run. The rest wait for the next minute, so one run stays
// well inside the edge function's time limit and the 5-minute claim.
const BATCH = 500;
// Requests to FCM in flight at once.
const PARALLEL = 20;

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

type Due = {
  queue: string;
  row_id: string;
  user_id: string;
  tokens: string[] | null;
  title: string;
  body: string;
  data: Record<string, string> | null;
  collapse_key: string | null;
  priority: string | null;
  channel: string | null;
};

type ServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
  token_uri?: string;
};

// ---- Google OAuth, from the service account -----------------------------

let cached: { token: string; until: number } | null = null;

const b64url = (bytes: Uint8Array) =>
  btoa(String.fromCharCode(...bytes))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

const b64urlText = (s: string) => b64url(new TextEncoder().encode(s));

async function googleToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cached && cached.until > now + 60) return cached.token;

  const tokenUri = sa.token_uri ?? "https://oauth2.googleapis.com/token";
  const head = b64urlText(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = b64urlText(JSON.stringify({
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: tokenUri,
    iat: now,
    exp: now + 3600,
  }));
  const pem = sa.private_key
    .replace(/-----[^-]+-----/g, "")
    .replace(/\s+/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = new Uint8Array(await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(`${head}.${claims}`),
  ));

  const res = await fetch(tokenUri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${head}.${claims}.${b64url(sig)}`,
    }),
  });
  if (!res.ok) throw new Error(`google token ${res.status}: ${await res.text()}`);
  const out = await res.json();
  cached = { token: out.access_token, until: now + (out.expires_in ?? 3600) };
  return cached.token;
}

// ---- One device ----------------------------------------------------------

type Outcome = "sent" | "dead" | "retry" | "failed";

async function sendOne(
  sa: ServiceAccount,
  bearer: string,
  row: Due,
  token: string,
): Promise<{ outcome: Outcome; error?: string }> {
  // FCM data values must all be strings.
  const data: Record<string, string> = {};
  for (const [k, v] of Object.entries(row.data ?? {})) data[k] = String(v);

  const notification: Record<string, string> = {};
  if (row.collapse_key) notification.tag = row.collapse_key;
  if (row.channel) notification.channel_id = row.channel;

  const message = {
    token,
    notification: { title: row.title, body: row.body },
    data,
    android: {
      priority: row.priority === "high" ? "HIGH" : "NORMAL",
      ...(row.collapse_key ? { collapse_key: row.collapse_key } : {}),
      notification,
    },
  };

  let res: Response;
  try {
    res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${bearer}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ message }),
      },
    );
  } catch (e) {
    return { outcome: "retry", error: `network: ${e}` };
  }
  if (res.ok) return { outcome: "sent" };

  const text = await res.text();
  // FCM v1 names the reason in error.details[].errorCode.
  if (text.includes("UNREGISTERED")) return { outcome: "dead", error: "UNREGISTERED" };
  if (res.status === 429 || res.status >= 500) {
    return { outcome: "retry", error: `fcm ${res.status}` };
  }
  return { outcome: "failed", error: `fcm ${res.status}: ${text.slice(0, 200)}` };
}

// ---- A small pool, so 500 rows do not open 500 sockets -------------------

async function pool<T>(items: T[], n: number, run: (t: T) => Promise<void>) {
  let i = 0;
  const workers = Array.from({ length: Math.min(n, items.length) }, async () => {
    while (i < items.length) {
      const t = items[i++];
      await run(t);
    }
  });
  await Promise.all(workers);
}

// ---- The run -------------------------------------------------------------

serve(async (req) => {
  const secret = Deno.env.get("PUSH_SEND_SECRET") ?? "";
  if (!secret || req.headers.get("Authorization") !== `Bearer ${secret}`) {
    return json({ error: "forbidden" }, 403);
  }

  let sa: ServiceAccount;
  try {
    sa = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT") ?? "");
  } catch {
    // Claim nothing: the rows stay queued until the secret is set, and the
    // cutoff ends them if it never is.
    return json({ skipped: true, reason: "FCM_SERVICE_ACCOUNT not set" });
  }

  const db = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    { auth: { persistSession: false } },
  );

  const { data: rows, error } = await db.rpc("pv_push_due", { p_limit: BATCH });
  if (error) return json({ error: error.message }, 500);
  const due = (rows ?? []) as Due[];
  if (due.length === 0) return json({ rows: 0 });

  let bearer: string;
  try {
    bearer = await googleToken(sa);
  } catch (e) {
    // Hand every claimed row back: the next minute tries again.
    for (const row of due) {
      await db.rpc("pv_push_mark", {
        p_queue: row.queue, p_row_id: row.row_id, p_status: "queued",
        p_devices_sent: 0, p_error: `auth: ${e}`.slice(0, 500), p_dead_tokens: [],
      });
    }
    return json({ error: `auth: ${e}` }, 500);
  }

  const tally = { sent: 0, failed: 0, skipped: 0, retry: 0, dead: 0 };

  await pool(due, PARALLEL, async (row) => {
    const tokens = row.tokens ?? [];
    let sent = 0;
    let retry = false;
    const dead: string[] = [];
    const errors: string[] = [];
    for (const token of tokens) {
      const r = await sendOne(sa, bearer, row, token);
      if (r.outcome === "sent") sent++;
      else if (r.outcome === "dead") dead.push(token);
      else if (r.outcome === "retry") retry = true;
      if (r.error) errors.push(r.error);
    }

    const status = sent > 0
      ? "sent"
      : retry
      ? "queued"
      : dead.length === tokens.length
      ? "skipped"
      : "failed";
    const err = sent > 0 && errors.length === 0
      ? null
      : (status === "skipped" ? "no_device" : errors.join("; ")) || null;

    const { error: markError } = await db.rpc("pv_push_mark", {
      p_queue: row.queue,
      p_row_id: row.row_id,
      p_status: status,
      p_devices_sent: sent,
      p_error: err,
      p_dead_tokens: dead,
    });
    if (markError) console.error(`[push-send] mark ${row.queue}/${row.row_id}: ${markError.message}`);

    tally.dead += dead.length;
    if (status === "sent") tally.sent++;
    else if (status === "queued") tally.retry++;
    else if (status === "skipped") tally.skipped++;
    else tally.failed++;
  });

  return json({ rows: due.length, ...tally });
});
