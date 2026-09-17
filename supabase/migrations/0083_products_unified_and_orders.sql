-- =====================================================================
-- 0083_products_unified_and_orders.sql -- one catalogue, one ledger
-- ---------------------------------------------------------------------
-- Two things, both decided 2026-09-17 with the unified product store
-- (docs/PRODUCTS-AUDIT.md, STILL-OPEN §61.2):
--
--   1. `products` grows from "the parenting catalogue" into THE catalogue.
--      Stage becomes a TAG on the row (docs/FAMILY-MODEL.md: stage is
--      never an owner) — the same move `saved_items` made in 0081. Every
--      column added here is nullable or defaulted, so the 23 parenting
--      rows already loaded keep working and `ProductCatalogStore.fromMap`
--      keeps reading them. The unified store's adapters are the import
--      script for the rest.
--
--   2. `orders` — a LEDGER, not a state blob. Addresses and the order list
--      also sync as a `user_state` blob (PvOrderStore, like CartStore) so a
--      new phone gets them back; but an order is something support, the
--      fulfilment side and an accountant must be able to QUERY, and a JSON
--      blob keyed by user is not that. So each order is a row the app
--      upserts on its own minted id (idempotent retry), owned by the
--      person, readable only by her.
--
-- ⚠️ STATUS IS THE PAYMENT'S. `paid` is written only after the Razorpay
-- signature verified server-side (razorpay-verify-payment). `preview`
-- means the payment stack was unreachable and the order is a rehearsal.
-- The app never promotes an order on its own; a later hardening step is
-- a trigger that refuses `paid` unless `payment_id` is set — noted, not
-- built, because the verify function does not yet write to this table.
--
-- ⚠️ MONEY IS INTEGER RUPEES here (display + audit), matching
-- `products.price_inr`. The paise figure lives on the Razorpay order.
--
-- PREREQ: 0049 (products), 0081 (the stage-as-tag precedent).
-- =====================================================================

-- ---- 1. products: stage as a tag, plus what the unified page needs ----

alter table public.products
  add column if not exists stage         text[]  not null default '{parenting}',
  add column if not exists sub_id        text    not null default '',
  add column if not exists images        text[]  not null default '{}',
  add column if not exists mrp_inr       int,
  add column if not exists price_note    text    not null default '',
  add column if not exists buy_url       text,
  add column if not exists sold_here     boolean not null default false,
  add column if not exists review_only   boolean not null default false,
  add column if not exists reco_band     text,
  add column if not exists reco_reason   text    not null default '',
  add column if not exists reco_before   text    not null default '',
  add column if not exists reco_reviewer text    not null default '',
  add column if not exists reco_reviewer_role text not null default '',
  add column if not exists evidence      text,
  add column if not exists variants      jsonb   not null default '[]'::jsonb,
  add column if not exists reviews_list  jsonb   not null default '[]'::jsonb,
  add column if not exists experts       jsonb   not null default '[]'::jsonb,
  add column if not exists ingredients   jsonb   not null default '[]'::jsonb,
  add column if not exists studies       jsonb   not null default '[]'::jsonb,
  add column if not exists compare       jsonb   not null default '{}'::jsonb,
  add column if not exists parents_pct   int,
  add column if not exists experts_pct   int,
  add column if not exists week_from     int,
  add column if not exists week_to       int,
  add column if not exists age_min_months int   not null default 0,
  add column if not exists age_max_months int   not null default 72,
  add column if not exists for_partner   boolean not null default false,
  add column if not exists hue           numeric(5,1) not null default 268;

alter table public.products
  drop constraint if exists products_reco_band_check,
  add  constraint products_reco_band_check
    check (reco_band is null or reco_band in ('strong','buy','consider','situational','skip')),
  drop constraint if exists products_evidence_check,
  add  constraint products_evidence_check
    check (evidence is null or evidence in ('strong','mixed','thin')),
  drop constraint if exists products_stage_check,
  add  constraint products_stage_check
    check (stage <@ array['tryingToConceive','pregnancy','parenting']::text[]),
  drop constraint if exists products_mrp_check,
  add  constraint products_mrp_check
    check (mrp_inr is null or mrp_inr >= 0);

comment on column public.products.stage is
  'A TAG: which stage(s) this leads on. Never a wall - search and byId see every row. Values are LifeStage.id.';
comment on column public.products.reco_band is
  'The ParentVeda band. An enum on purpose, not a score: "skip" renders with the same weight as "strong".';
comment on column public.products.parents_pct is
  'MEASURED or NULL. Never derive from rating: a percentage computed from a star looks measured and is not.';
comment on column public.products.variants is
  'JSON [{id,label,price}] - absolute rupees per variant; razorpay-create-order prices lines from here.';

create index if not exists products_stage_idx on public.products using gin (stage);

-- ---- 2. orders: the ledger --------------------------------------------

create table if not exists public.orders (
  id            text        primary key,                 -- app-minted: ord_<micros>
  user_id       uuid        not null references auth.users(id) on delete cascade,
  status        text        not null default 'placed',
  subtotal_inr  int         not null default 0,
  delivery_inr  int         not null default 0,
  total_inr     int         not null default 0,
  payment_id    text,                                    -- Razorpay pay_… once verified
  address       jsonb       not null default '{}'::jsonb, -- snapshot at order time
  items         jsonb       not null default '[]'::jsonb, -- [{product_id,name,variant,qty,unit_inr}]
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint orders_status_check
    check (status in ('placed','paid','preview','cancelled')),
  constraint orders_money_check
    check (subtotal_inr >= 0 and delivery_inr >= 0 and total_inr >= 0)
);

comment on table public.orders is
  'One row per order, app-minted id, owned by the person. Address and items are SNAPSHOTS - a later address edit must not rewrite history.';
comment on column public.orders.status is
  'placed = tapped; paid = signature verified server-side; preview = payment stack unreachable, a rehearsal; cancelled.';

create index if not exists orders_user_created_idx on public.orders (user_id, created_at desc);

alter table public.orders enable row level security;

drop policy if exists orders_select on public.orders;
create policy orders_select on public.orders
  for select to authenticated using (user_id = auth.uid());

drop policy if exists orders_insert on public.orders;
create policy orders_insert on public.orders
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists orders_update on public.orders;
create policy orders_update on public.orders
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- No delete policy: a ledger keeps its rows. Cancel is a status.

grant select, insert, update on public.orders to authenticated;

-- updated_at on every write, the house trigger shape.
create or replace function public.orders_touch() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists orders_touch on public.orders;
create trigger orders_touch before update on public.orders
  for each row execute function public.orders_touch();
