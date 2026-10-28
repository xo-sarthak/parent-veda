// =============================================================================
//  affiliate-refresh — read each affiliate listing's price and star rating
//  from Amazon and store them with the time they were read (migration 0108).
// -----------------------------------------------------------------------------
//  WHY A SERVER, NOT THE APP
//  The Amazon credential is a secret, and the price must be the same for
//  every phone. A phone calling Amazon would ship the secret in the APK and
//  spend the API's request allowance per user instead of once a day.
//  Server-side, never scraped (decided with the user 2026-10-20).
//
//  WHICH API — ⚠️ NOT PA-API 5
//  Amazon retired the Product Advertising API 5.0 in 2026; calls now get a
//  403 AccessDeniedException. Its successor is the CREATORS API: OAuth 2.0
//  client-credentials (a bearer token valid ~1 hour, cached here for the run)
//  instead of per-request AWS signatures, endpoints under
//  https://creatorsapi.amazon/catalog/v1/, lowerCamelCase fields, and an
//  `x-marketplace` header. Credentials come from Associates Central →
//  Creators API → "Manage Credentials" (old PA-API keys do not work).
//  Docs: affiliate-program.amazon.com/creatorsapi/docs/en-us/introduction
//
//  INERT UNTIL SWITCHED ON
//  With any secret missing it returns {skipped: true} and writes nothing.
//  Amazon only grants API access once the Associates account has qualifying
//  sales, so this is expected to sit inert for a while. That is the design:
//  the app shows "our guide price · check today's price on Amazon" until a
//  row carries price_checked_at.
//
//  SAFE BY CONSTRUCTION ON AN UNKNOWN RESPONSE
//  The response field paths below follow the PA-API names in lowerCamelCase,
//  as the migration guide says. If Amazon's shape differs, a field reads as
//  missing and that row is LEFT ALONE (a stale price with its old date is
//  honest; a zero is not). The run reports how many it could not read, so
//  the first live run shows at once whether the paths need adjusting.
//
//  SECRETS (supabase secrets set …):
//    AMAZON_CREATORS_CREDENTIAL_ID
//    AMAZON_CREATORS_CREDENTIAL_SECRET
//    AMAZON_CREATORS_TOKEN_URL     -- per credential version, from the docs
//    AMAZON_PARTNER_TAG            -- e.g. parentveda-21
//  SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are injected automatically.
//
//  DEPLOY + SCHEDULE (no user JWT: a cron calls it, so verify-jwt is off and
//  the function checks the service-role bearer itself):
//    supabase functions deploy affiliate-refresh --no-verify-jwt
//    then a daily pg_cron + pg_net call with the service-role key.
//
//  COST: the Creators API is free to Associates; one call per 10 items, once
//  a day, inside the Supabase plan — about $0 / ₹0.
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const API = "https://creatorsapi.amazon/catalog/v1";
const MARKETPLACE = "www.amazon.in";
const BATCH = 10; // getItems takes up to 10 ids

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

// deno-lint-ignore no-explicit-any
const at = (o: any, path: string[]): any =>
  path.reduce((v, k) => (v == null ? undefined : v[k]), o);

serve(async (req) => {
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  // Only the scheduler (holding the service key) may run this.
  if (req.headers.get("Authorization") !== `Bearer ${serviceKey}`) {
    return json({ error: "forbidden" }, 403);
  }

  const id = Deno.env.get("AMAZON_CREATORS_CREDENTIAL_ID") ?? "";
  const secret = Deno.env.get("AMAZON_CREATORS_CREDENTIAL_SECRET") ?? "";
  const tokenUrl = Deno.env.get("AMAZON_CREATORS_TOKEN_URL") ?? "";
  const tag = Deno.env.get("AMAZON_PARTNER_TAG") ?? "";
  if (!id || !secret || !tokenUrl || !tag) {
    return json({ skipped: true, reason: "Creators API secrets not set" });
  }

  const db = createClient(Deno.env.get("SUPABASE_URL") ?? "", serviceKey);
  const { data: rows, error } = await db
    .from("products")
    .select("id, asin")
    .not("asin", "is", null);
  if (error) return json({ error: error.message }, 500);
  if (!rows?.length) return json({ updated: 0, unread: 0, items: 0 });

  // One token for the whole run (valid about an hour).
  const tok = await fetch(tokenUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      grant_type: "client_credentials",
      client_id: id,
      client_secret: secret,
      scope: "creatorsapi::default",
    }),
  });
  if (!tok.ok) return json({ error: `token ${tok.status}` }, 502);
  const token = (await tok.json()).access_token as string;

  const byAsin = new Map<string, string[]>();
  for (const r of rows) {
    byAsin.set(r.asin, [...(byAsin.get(r.asin) ?? []), r.id]);
  }
  const asins = [...byAsin.keys()];
  const now = new Date().toISOString();
  let updated = 0;
  let unread = 0;

  for (let i = 0; i < asins.length; i += BATCH) {
    const res = await fetch(`${API}/getItems`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
        "x-marketplace": MARKETPLACE,
      },
      body: JSON.stringify({
        itemIds: asins.slice(i, i + BATCH),
        partnerTag: tag,
        marketplace: MARKETPLACE,
        resources: [
          "offersV2.listings.price",
          "customerReviews.starRating",
          "customerReviews.count",
          // The listing itself (0120): title, "About this item", main photo.
          // Amazon allows these on our page only from this API.
          "itemInfo.title",
          "itemInfo.features",
          "images.primary.large",
        ],
      }),
    });
    if (!res.ok) {
      unread += Math.min(BATCH, asins.length - i);
      continue;
    }
    const body = await res.json();
    for (const item of at(body, ["itemsResult", "items"]) ?? []) {
      const price = at(item, ["offersV2", "listings", 0, "price", "money", "amount"]);
      if (typeof price !== "number" || price <= 0) {
        unread++;
        continue; // leave the row alone: an old dated price beats a wrong one
      }
      const star = at(item, ["customerReviews", "starRating", "value"]);
      const count = at(item, ["customerReviews", "count"]);
      const patch: Record<string, unknown> = {
        price_inr: Math.round(price),
        price_checked_at: now,
      };
      if (typeof star === "number") patch.ext_rating = star;
      if (typeof count === "number") patch.ext_review_count = count;
      // The listing's own words and photo (0120). Each is written only when
      // it read cleanly; a missing field leaves the last good value alone.
      const title = at(item, ["itemInfo", "title", "displayValue"]);
      if (typeof title === "string" && title) patch.ext_title = title;
      const feats = at(item, ["itemInfo", "features", "displayValues"]);
      if (Array.isArray(feats)) {
        patch.ext_features = feats.filter((f) => typeof f === "string").slice(0, 8);
      }
      const img = at(item, ["images", "primary", "large", "url"]);
      if (typeof img === "string" && img.startsWith("https://")) {
        patch.ext_image = img;
      }
      const { error: e } = await db
        .from("products")
        .update(patch)
        .in("id", byAsin.get(item.asin) ?? []);
      if (e) unread++;
      else updated++;
    }
  }
  return json({ updated, unread, items: asins.length });
});
