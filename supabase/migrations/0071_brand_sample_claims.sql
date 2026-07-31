-- =====================================================================
-- 0071_brand_sample_claims.sql -- a claimed sample reaches somebody
-- ---------------------------------------------------------------------
-- The sampling screen asks a parent for her postal address, makes her tick
-- an unticked consent box, promises "ParentVeda posts it", and then shows a
-- confirmation. Until this migration, `_register()` wrote a local flag and
-- DISCARDED the address. Nothing left the phone. She believed a parcel was
-- coming, and no parcel could ever have been sent.
--
-- That is the only place in the Brand Studio where the app told a user
-- something untrue, and it is worse than a missing feature: a missing
-- feature looks missing.
--
-- THE THREE PROMISES ON THAT SCREEN, and how each is kept here:
--
--   "ParentVeda posts it. Your address is used to send this one parcel and
--    nothing else."
--      -> the address lives in THIS table and nowhere else. Not in
--         profiles, not in an analytics event, not in the ledger.
--
--   "<Brand> receives a COUNT of how many were claimed. Not your name, not
--    your address, not your baby's age."
--      -> there is NO brand-facing read of this table at all. The only
--         thing a brand can ever be given is brand_sample_counts(), which
--         returns one integer per campaign. Not a view with columns hidden
--         — a function that has no access to a row to begin with.
--
--   "No card, no subscription."
--      -> nothing here touches entitlements, plans or the ledger.
--
-- PREREQ: 0045 (the directus_cms role).
-- =====================================================================

create table if not exists public.brand_sample_claims (
  id           bigserial   primary key,
  campaign_id  text        not null,
  user_id      uuid        not null references auth.users (id) on delete cascade,

  -- One free-text block, exactly as she typed it. Deliberately NOT parsed
  -- into house/street/city/pin: an Indian address that does not fit a form
  -- is the normal case, not an edge case, and a parcel is addressed by a
  -- human reading a label.
  address      text        not null,

  -- When she ticked the box. Stored rather than assumed, because consent
  -- given at a moment is the thing that has to be evidenced later.
  consent_at   timestamptz not null default now(),

  status       text        not null default 'claimed'
                 check (status in ('claimed','posted','cancelled')),
  posted_at    timestamptz,

  -- ParentVeda's question, asked after the parcel — not the brand's survey.
  rating       int check (rating between 1 and 5),
  feedback     text,

  created_at   timestamptz not null default now(),

  -- One claim per campaign per parent. A sampling run has finite stock, and
  -- "claim twice by tapping twice" is how that stock disappears.
  unique (campaign_id, user_id)
);

create index if not exists brand_sample_claims_campaign_idx
  on public.brand_sample_claims (campaign_id, status);

grant select, insert, update on public.brand_sample_claims to authenticated;
alter table public.brand_sample_claims enable row level security;

-- A parent reads and writes HER OWN claim, and nobody else's.
drop policy if exists "brand_sample_claims own" on public.brand_sample_claims;
create policy "brand_sample_claims own" on public.brand_sample_claims
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- No delete grant. A claim is a promise ParentVeda made to post something;
-- withdrawing it is a status change with a record, not a vanished row.


-- ---------------------------------------------------------------------
-- The fulfilment desk
--
-- Staff need the address, because "ParentVeda posts it" is the promise and
-- a parcel cannot be addressed without one. So this IS granted to Directus,
-- unlike partner_attributions and parent_timeline (0070) which are not —
-- the difference is that reading this address is the stated mechanism, and
-- reading a mother's timeline is not.
--
-- select + update only: mark a claim posted, never create or destroy one.
-- ---------------------------------------------------------------------
grant select, update on public.brand_sample_claims to directus_cms;

drop policy if exists "brand_sample_claims cms" on public.brand_sample_claims;
create policy "brand_sample_claims cms" on public.brand_sample_claims
  for all to directus_cms using (true) with check (true);


-- ---------------------------------------------------------------------
-- brand_sample_counts() -- the ONLY thing a brand is ever given
--
-- One row per campaign, integers only. There is no signature here that
-- could carry a name, an address or a user id, which is the point: the
-- promise is kept by there being nothing else to hand over.
--
-- Deliberately callable by `authenticated` so the count can be shown back
-- to a parent ("312 parents have claimed this") without any new plumbing.
-- A count of claims is not personal data about anyone.
-- ---------------------------------------------------------------------
create or replace function public.brand_sample_counts(p_campaign_id text default null)
returns table (
  campaign_id text,
  claimed     bigint,
  posted      bigint
)
language sql
stable
security definer set search_path = ''
as $$
  select c.campaign_id,
         count(*) filter (where c.status in ('claimed','posted')),
         count(*) filter (where c.status = 'posted')
    from public.brand_sample_claims c
   where p_campaign_id is null or c.campaign_id = p_campaign_id
   group by c.campaign_id;
$$;

grant execute on function public.brand_sample_counts(text) to authenticated;
grant execute on function public.brand_sample_counts(text) to directus_cms;
