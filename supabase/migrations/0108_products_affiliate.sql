-- =============================================================================
--  0108 — the retailer's own price and rating on a product (2026-10-21,
--  walk 2026-10-20: "real prices and real reviews ... plug and play")
-- -----------------------------------------------------------------------------
--  An affiliate product names its ONE exact listing (asin) and carries the
--  price and star rating read from that listing, with the time they were
--  read. Filled by the `affiliate-refresh` edge function (service_role), or
--  by an editor through the CMS write policy of 0049 for an asin chosen by
--  hand; the app reads them like every other product column (public read,
--  0049). No new policy: the two writers that exist are the right ones.
--
--  Why a time column and not just a price: a cached retailer price without
--  its "as of" moment is a promise we cannot keep, and Amazon's terms ask
--  for that time on any price that is not fetched live. The app prints it.
--
--  ext_ = external. Kept apart from rating / reviews on purpose: those are
--  parents on ParentVeda, these are Amazon's, and the page labels them so.
--  Review TEXT is never stored: we link to it.
--
--  Additive and idempotent; safe to run twice.
-- =============================================================================

alter table public.products
  add column if not exists asin             text,
  add column if not exists price_checked_at timestamptz,
  add column if not exists ext_rating       numeric(2,1),
  add column if not exists ext_review_count int;

alter table public.products
  drop constraint if exists products_ext_rating_check,
  add  constraint products_ext_rating_check
    check (ext_rating is null or (ext_rating >= 0 and ext_rating <= 5)),
  drop constraint if exists products_ext_review_count_check,
  add  constraint products_ext_review_count_check
    check (ext_review_count is null or ext_review_count >= 0),
  drop constraint if exists products_asin_check,
  add  constraint products_asin_check
    check (asin is null or asin ~ '^[A-Z0-9]{10}$');

-- The refresh job reads only rows with an asin.
create index if not exists products_asin_idx
  on public.products (asin) where asin is not null;
