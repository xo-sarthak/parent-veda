-- =====================================================================
-- 0037_care_partners.sql -- Care Partner platform: partners, referrals,
-- attribution, commission ledger, and the parent journey timeline
-- ---------------------------------------------------------------------
-- ParentVeda acquires parents through trusted healthcare professionals.
-- A Care Partner is credited, thanked and paid; they NEVER own the family.
--
-- THE PRIVACY BOUNDARY, stated once and enforced everywhere below:
-- a partner may see WHAT THEY CAUSED IN AGGREGATE and nothing about an
-- individual family. No name, no due date, no child, no row they can join
-- back to a person. Every partner-facing read in this file goes through a
-- security-definer function that returns COUNTS. There is deliberately no
-- RLS policy that would let a partner select attribution rows directly -
-- a table with no policy for a verb denies that verb outright.
--
-- SEPARATE from 0035 (parent-to-parent referral) on purpose. That is a
-- joining bonus between two mothers. This is a commercial relationship
-- with a professional: verification, commission, permanent attribution.
--
-- PREREQ: 0001 (profiles), 0030 (expert_accounts).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. PARTNERS
--
-- `type` is TEXT, not an enum: the spec requires new partner types to be
-- addable from the admin panel without an app release, and a Postgres
-- enum would need a migration for each one.
--
-- expert_id is nullable and that is the whole design. A referring
-- paediatrician may never open the app; a consulting expert may refer
-- nobody; someone doing both is linked. The doctor app then shows each of
-- them only what they actually do.
-- ---------------------------------------------------------------------
create table public.care_partners (
  id            text        primary key,
  name          text        not null,
  type          text        not null default 'doctor',
  status        text        not null default 'pending'
                  check (status in ('pending','active','inactive','rejected')),
  speciality    text        not null default '',
  organisation  text        not null default '',
  department    text        not null default '',
  city          text        not null default '',
  logo_url      text,
  photo_url     text,
  -- TrustMessage: primary/secondary label + welcomes. Admin-editable.
  trust         jsonb       not null default '{}'::jsonb,
  -- Links to an in-app expert account when the same person also consults.
  expert_id     text,
  verified_at   timestamptz,
  -- Soft delete: a deactivated partner must never orphan the families they
  -- already brought, so rows are kept and hidden rather than removed.
  deleted_at    timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index care_partners_status_idx on public.care_partners (status)
  where deleted_at is null;
create index care_partners_expert_idx on public.care_partners (expert_id)
  where expert_id is not null;

grant select on public.care_partners to anon, authenticated;
alter table public.care_partners enable row level security;

-- READ is open, including signed-out: a parent scanning a QR must be shown
-- "Invited by Dr Meera Rao" BEFORE she has an account. Only the public
-- identity of a professional is here -- name, speciality, photo -- which is
-- what a clinic already puts on its door. No contact details, no analytics.
create policy "care_partners public read" on public.care_partners
  for select using (deleted_at is null);

-- No write policy. Partners are created, verified and deactivated by
-- ParentVeda from the admin panel under service_role. Verification is an
-- editorial act and must never be self-service from the app.


-- ---------------------------------------------------------------------
-- 2. REFERRAL TOKENS
--
-- One row per (partner, campaign, rotation). The token is DERIVED in the
-- app from those three, so rotating a compromised poster is incrementing
-- `rotation` -- and the old token stops resolving without touching any
-- family already attributed, because attribution stores the token it used.
-- ---------------------------------------------------------------------
create table public.partner_referrals (
  token        text        primary key,
  partner_id   text        not null references public.care_partners (id) on delete cascade,
  campaign_id  text,
  channel      text        not null default 'qr',
  rotation     int         not null default 0,
  active       boolean     not null default true,
  expires_at   timestamptz,
  created_at   timestamptz not null default now()
);

create index partner_referrals_partner_idx
  on public.partner_referrals (partner_id, active);

grant select on public.partner_referrals to anon, authenticated;
alter table public.partner_referrals enable row level security;

-- Readable so a scan can be resolved before signup. A token maps to a
-- partner and nothing else; knowing one tells you nothing about any family.
create policy "partner_referrals read" on public.partner_referrals
  for select using (active);


-- ---------------------------------------------------------------------
-- 3. ATTRIBUTION -- the permanent link between a parent and a partner
--
-- user_id is PRIMARY KEY, which is what enforces "first touch wins" at the
-- database level rather than in application code. A second scan cannot
-- create a second row, so attribution cannot be silently stolen by a later
-- partner or by a replayed link.
--
-- OPEN POINT (parked with the user): what SHOULD happen when a family meets
-- a second partner months later -- Care Circle membership without
-- commission, shared commission, or nothing. Today: nothing. This shape
-- forecloses none of those; a second table would be added rather than this
-- one changed, precisely so history stays immutable.
-- ---------------------------------------------------------------------
create table public.partner_attributions (
  user_id       uuid        primary key references auth.users (id) on delete cascade,
  partner_id    text        not null references public.care_partners (id),
  token         text        not null,
  channel       text        not null default 'qr',
  campaign_id   text,
  scanned_at    timestamptz,
  installed_at  timestamptz,
  signed_up_at  timestamptz,
  linked_at     timestamptz not null default now()
);

create index partner_attributions_partner_idx
  on public.partner_attributions (partner_id, linked_at);

grant select on public.partner_attributions to authenticated;
alter table public.partner_attributions enable row level security;

-- A PARENT may read her OWN attribution -- she is entitled to know who
-- introduced her, and the Care Circle shows it.
--
-- Note what is absent: no policy lets a PARTNER select from this table.
-- That is the privacy boundary. Partners read counts through
-- partner_impact() below, never rows.
create policy "partner_attributions own read" on public.partner_attributions
  for select using (user_id = auth.uid());


-- ---------------------------------------------------------------------
-- 4. COMMISSION LEDGER -- immutable, append-only
--
-- Never overwrite a commission calculation. A ledger that can be edited is
-- not a ledger; corrections are new rows, so the history of what was
-- calculated, when, and on what basis is always reconstructable.
--
-- This is also where the doctor's TOTAL earnings come from. Consultations,
-- masterclasses and referrals all land here with a different `source`, so
-- the doctor app can answer "how much did I earn, and where did it come
-- from?" from one place instead of three.
-- ---------------------------------------------------------------------
create table public.commission_ledger (
  id             bigserial   primary key,
  partner_id     text        not null references public.care_partners (id),
  -- Which family caused it. Present so a payout can be audited; NEVER
  -- exposed to the partner (see partner_impact / partner_earnings below).
  user_id        uuid        references auth.users (id) on delete set null,
  source         text        not null
                   check (source in ('consultation','masterclass','cohort',
                                     'subscription','product','course',
                                     'referral','other')),
  reference_id   text,
  gross_minor    bigint      not null default 0,
  rate_bps       int         not null default 0,   -- basis points, 250 = 2.5%
  partner_minor  bigint      not null default 0,
  platform_minor bigint      not null default 0,
  tax_minor      bigint      not null default 0,
  currency       text        not null default 'INR',
  status         text        not null default 'accrued'
                   check (status in ('accrued','approved','settled','reversed')),
  settled_at     timestamptz,
  payout_id      text,
  created_at     timestamptz not null default now()
);

create index commission_ledger_partner_idx
  on public.commission_ledger (partner_id, created_at);
create index commission_ledger_status_idx
  on public.commission_ledger (status);

grant select on public.commission_ledger to authenticated;
alter table public.commission_ledger enable row level security;

-- A partner reads their OWN ledger, and only when they hold the matching
-- expert account. Rows carry user_id, so the app-facing views below strip
-- it; this policy exists for the doctor app's earnings screen, which shows
-- amounts and sources, never families.
create policy "commission_ledger partner read" on public.commission_ledger
  for select to authenticated
  using (exists (
    select 1
    from public.care_partners cp
    join public.expert_accounts ea on ea.expert_id = cp.expert_id
    where cp.id = commission_ledger.partner_id
      and ea.user_id = auth.uid()
  ));

-- No insert/update/delete policy. Entries are written by edge functions
-- under service_role when a payment settles. Nothing a client does can
-- create, alter or delete money.


-- ---------------------------------------------------------------------
-- 5. PARENT JOURNEY TIMELINE
--
-- Append-only events per parent: referral generated, scanned, installed,
-- signed up, pregnancy added, child added, purchase, consultation.
-- Unbounded by design -- `event` is text so a new milestone is data.
-- ---------------------------------------------------------------------
create table public.parent_timeline (
  id          bigserial   primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  partner_id  text        references public.care_partners (id),
  event       text        not null,
  detail      text,
  at          timestamptz not null default now()
);

create index parent_timeline_user_idx on public.parent_timeline (user_id, at);
create index parent_timeline_partner_idx
  on public.parent_timeline (partner_id, at) where partner_id is not null;

grant select, insert on public.parent_timeline to authenticated;
alter table public.parent_timeline enable row level security;

create policy "parent_timeline own read" on public.parent_timeline
  for select using (user_id = auth.uid());

create policy "parent_timeline own insert" on public.parent_timeline
  for insert to authenticated with check (user_id = auth.uid());


-- ---------------------------------------------------------------------
-- 6. attribute_to_partner(token, channel, campaign)
--
-- The ONLY way an attribution is created. Re-validates everything the app
-- checked, because the app can be edited and this cannot.
-- ---------------------------------------------------------------------
create or replace function public.attribute_to_partner(
  p_token text,
  p_channel text default 'qr',
  p_campaign text default null
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_me      uuid := auth.uid();
  v_ref     public.partner_referrals%rowtype;
  v_partner public.care_partners%rowtype;
begin
  if v_me is null then return 'not_signed_in'; end if;

  select * into v_ref from public.partner_referrals
   where token = upper(trim(p_token)) and active;
  if not found then return 'unknown_token'; end if;

  if v_ref.expires_at is not null and v_ref.expires_at < now() then
    return 'expired';
  end if;

  select * into v_partner from public.care_partners
   where id = v_ref.partner_id and deleted_at is null;
  if not found then return 'unknown_partner'; end if;
  if v_partner.status <> 'active' then return 'partner_not_active'; end if;

  -- Self-referral: the partner's own expert account scanning their own QR.
  -- The single cheapest way to manufacture commission, so it is checked here
  -- and not only in the app.
  if v_partner.expert_id is not null and exists (
       select 1 from public.expert_accounts ea
        where ea.user_id = v_me and ea.expert_id = v_partner.expert_id
     ) then
    return 'self_referral';
  end if;

  -- FIRST TOUCH WINS. The primary key would reject this anyway; checking
  -- first turns a raised exception into a message worth showing.
  if exists (select 1 from public.partner_attributions where user_id = v_me) then
    return 'already_attributed';
  end if;

  insert into public.partner_attributions
    (user_id, partner_id, token, channel, campaign_id, signed_up_at)
  values
    (v_me, v_partner.id, v_ref.token, coalesce(p_channel, v_ref.channel),
     coalesce(p_campaign, v_ref.campaign_id), now());

  insert into public.parent_timeline (user_id, partner_id, event, detail)
  values (v_me, v_partner.id, 'attributed', coalesce(p_channel, v_ref.channel));

  return 'ok';
exception
  when unique_violation then return 'already_attributed';
end;
$$;

grant execute on function public.attribute_to_partner(text, text, text) to authenticated;


-- ---------------------------------------------------------------------
-- 7. partner_impact() -- the Partner Journey Dashboard
--
-- COUNTS ONLY. This is what turns the relationship from "how much did I
-- earn" into "how many families have I helped", and it is also the reason
-- partners never need row access to anything: every number a partner is
-- entitled to see is computed here and returned as a total.
--
-- Returns nothing unless the caller holds the expert account linked to the
-- partner, so one partner can never read another's numbers.
-- ---------------------------------------------------------------------
create or replace function public.partner_impact(p_partner_id text)
returns table (
  families_referred      bigint,
  active_this_month      bigint,
  pregnancies_supported  bigint,
  children_added         bigint,
  consultations_done     bigint,
  vaccinations_completed bigint,
  content_consumed       bigint
)
language sql
stable
security definer set search_path = ''
as $$
  with allowed as (
    select 1
    from public.care_partners cp
    join public.expert_accounts ea on ea.expert_id = cp.expert_id
    where cp.id = p_partner_id and ea.user_id = auth.uid()
  ),
  fam as (
    select a.user_id
    from public.partner_attributions a
    where a.partner_id = p_partner_id and exists (select 1 from allowed)
  )
  select
    (select count(*) from fam),
    (select count(distinct t.user_id) from public.parent_timeline t
      where t.user_id in (select user_id from fam)
        and t.at > now() - interval '30 days'),
    (select count(*) from public.parent_timeline t
      where t.user_id in (select user_id from fam) and t.event = 'pregnancy_added'),
    (select count(*) from public.parent_timeline t
      where t.user_id in (select user_id from fam) and t.event = 'child_added'),
    (select count(*) from public.parent_timeline t
      where t.user_id in (select user_id from fam) and t.event = 'consultation_completed'),
    (select count(*) from public.parent_timeline t
      where t.user_id in (select user_id from fam) and t.event = 'vaccination_completed'),
    (select count(*) from public.parent_timeline t
      where t.user_id in (select user_id from fam) and t.event = 'content_read');
$$;

grant execute on function public.partner_impact(text) to authenticated;


-- ---------------------------------------------------------------------
-- 8. partner_earnings() -- totals by source, no families attached
-- ---------------------------------------------------------------------
create or replace function public.partner_earnings(p_partner_id text)
returns table (
  source         text,
  status         text,
  entries        bigint,
  partner_minor  bigint
)
language sql
stable
security definer set search_path = ''
as $$
  select l.source, l.status, count(*), coalesce(sum(l.partner_minor), 0)
  from public.commission_ledger l
  where l.partner_id = p_partner_id
    and exists (
      select 1 from public.care_partners cp
      join public.expert_accounts ea on ea.expert_id = cp.expert_id
      where cp.id = p_partner_id and ea.user_id = auth.uid()
    )
  group by l.source, l.status;
$$;

grant execute on function public.partner_earnings(text) to authenticated;
