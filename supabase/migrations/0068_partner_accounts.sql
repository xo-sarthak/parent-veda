-- =====================================================================
-- 0068_partner_accounts.sql -- a partner is a partner, whether it is a
-- person or an institution
-- ---------------------------------------------------------------------
-- 0037 tied a partner's identity to an EXPERT record:
--
--     care_partners.expert_id -> expert_accounts.expert_id -> auth.uid()
--
-- and every partner-facing function authorised through that join. It works
-- for a doctor in solo practice, who is both the partner and the
-- consultant. It cannot work for a hospital, an IVF centre or a
-- diagnostic lab, because expert_id is nullable by design and kExperts is
-- a compiled catalogue an institution has no business being in.
--
-- The consequence was total, not cosmetic: an organisation could be
-- issued a referral token and be named correctly on /care/, and then
-- never see a single number, because partner_impact(), partner_earnings()
-- and partner_funnel() would all return nothing for it. Its referral kit
-- would read "not set up yet" forever.
--
-- THE MODEL, restated: one care_partners row is one partner is one
-- account. Whether it is a person or an institution is `type` and nothing
-- more. A hospital is an individual party to the arrangement — which
-- doctor inside it saw the patient is not something we track or need,
-- because the hospital is who we have the tie-up with. A doctor in solo
-- practice is the same shape with type='doctor'.
--
-- `expert_id` therefore stops meaning "who this partner is" and now means
-- only "this partner ALSO consults inside the app". Present: consults and
-- programmes light up against it. Absent: they simply go unused. Nothing
-- is hidden per partner type — the view is the same for everyone.
--
-- PREREQ: 0030 (expert_accounts), 0037.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. partner_accounts -- user <-> care_partner, directly
--
-- Deliberately NOT a column on care_partners: one institution can have
-- several logins (a marketing person and an administrator), and a login
-- should be revocable without editing the partner's identity record.
-- ---------------------------------------------------------------------
create table if not exists public.partner_accounts (
  user_id     uuid        primary key references auth.users (id) on delete cascade,
  partner_id  text        not null references public.care_partners (id) on delete cascade,
  -- Who at the organisation this login belongs to. Free text; nothing reads
  -- it yet, and it exists so revoking the right one later is possible.
  label       text        not null default '',
  created_at  timestamptz not null default now()
);

create index if not exists partner_accounts_partner_idx
  on public.partner_accounts (partner_id);

grant select on public.partner_accounts to authenticated;
alter table public.partner_accounts enable row level security;

-- A login reads only its own mapping. No write policy: which account
-- belongs to which partner is an editorial act, same as verification —
-- a client that could insert here could attach itself to any partner and
-- read that partner's numbers.
drop policy if exists "partner_accounts own read" on public.partner_accounts;
create policy "partner_accounts own read" on public.partner_accounts
  for select using (user_id = auth.uid());


-- ---------------------------------------------------------------------
-- 2. One authorisation rule, in one place
--
-- Both routes to a partner, so a solo doctor keeps working unchanged and
-- an institution starts working. Inlined into each function below via
-- this helper rather than repeated, because three copies of an
-- authorisation check is three chances to fix two of them.
-- ---------------------------------------------------------------------
create or replace function public.caller_owns_partner(p_partner_id text)
returns boolean
language sql
stable
security definer set search_path = ''
as $$
  select exists (
    -- Route A: a direct partner login. Institutions and anyone else.
    select 1 from public.partner_accounts pa
     where pa.partner_id = p_partner_id and pa.user_id = auth.uid()
  ) or exists (
    -- Route B: the original path — this partner is linked to an expert
    -- record and the caller holds that expert account. Kept so every
    -- doctor already signed in keeps working.
    select 1
    from public.care_partners cp
    join public.expert_accounts ea on ea.expert_id = cp.expert_id
    where cp.id = p_partner_id
      and cp.expert_id is not null
      and ea.user_id = auth.uid()
  );
$$;

grant execute on function public.caller_owns_partner(text) to authenticated;


-- ---------------------------------------------------------------------
-- 3. The three partner-facing functions, re-pointed at the helper
--
-- STILL COUNTS ONLY. Nothing here widens what a partner can see; it only
-- widens WHO can be a partner. There is still no policy anywhere that
-- lets a partner select a family row, and none of these returns one.
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
  with fam as (
    select a.user_id
    from public.partner_attributions a
    where a.partner_id = p_partner_id
      and public.caller_owns_partner(p_partner_id)
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
    and public.caller_owns_partner(p_partner_id)
  group by l.source, l.status;
$$;

grant execute on function public.partner_earnings(text) to authenticated;


create or replace function public.partner_funnel(p_partner_id text)
returns table (
  scanned    bigint,
  installed  bigint,
  signed_up  bigint,
  activated  bigint
)
language sql
stable
security definer set search_path = ''
as $$
  with fam as (
    select a.*
    from public.partner_attributions a
    where a.partner_id = p_partner_id
      and public.caller_owns_partner(p_partner_id)
  )
  select
    (select count(*) from fam where scanned_at is not null),
    (select count(*) from fam where installed_at is not null),
    (select count(*) from fam where signed_up_at is not null),
    (select count(distinct t.user_id) from public.parent_timeline t
      where t.user_id in (select user_id from fam)
        and t.event in ('pregnancy_added','child_added'));
$$;

grant execute on function public.partner_funnel(text) to authenticated;


-- ---------------------------------------------------------------------
-- 4. my_care_partner() -- "which partner am I?"
--
-- The app needs this to open the partner view at all. Returns at most one
-- row: the partner behind the caller's login, by either route.
--
-- Returns the partner's own public identity plus expert_id, so the app can
-- tell whether consults and programmes apply to this partner without
-- asking a second question.
-- ---------------------------------------------------------------------
create or replace function public.my_care_partner()
returns table (
  id            text,
  name          text,
  type          text,
  status        text,
  speciality    text,
  organisation  text,
  department    text,
  city          text,
  logo_url      text,
  photo_url     text,
  trust         jsonb,
  expert_id     text,
  verified_at   timestamptz
)
language sql
stable
security definer set search_path = ''
as $$
  select cp.id, cp.name, cp.type, cp.status, cp.speciality, cp.organisation,
         cp.department, cp.city, cp.logo_url, cp.photo_url, cp.trust,
         cp.expert_id, cp.verified_at
  from public.care_partners cp
  where cp.deleted_at is null
    and public.caller_owns_partner(cp.id)
  limit 1;
$$;

grant execute on function public.my_care_partner() to authenticated;


-- ---------------------------------------------------------------------
-- 5. link_partner_account() -- admin only
--
-- Attaching a login to a partner is the same class of act as verifying
-- one: it grants sight of that partner's numbers. service_role only.
-- ---------------------------------------------------------------------
create or replace function public.link_partner_account(
  p_user_id    uuid,
  p_partner_id text,
  p_label      text default ''
)
returns void
language plpgsql
security definer set search_path = ''
as $$
begin
  -- Callers reach this through a sub-select on auth.users, and a sub-select
  -- that matches nothing returns NULL rather than erroring. Without this
  -- check the not-null constraint fires instead, and the message is about a
  -- column rather than about the actual mistake: that email does not exist.
  if p_user_id is null then
    raise exception
      'user_id is null - no auth.users row matched. Run step 1 of '
      'supabase/seed/link_partner_login.sql to see the real addresses, and '
      'note that a login has to exist before it can be linked.';
  end if;

  if not exists (
    select 1 from public.care_partners
     where id = p_partner_id and deleted_at is null
  ) then
    raise exception 'no such care partner: %', p_partner_id;
  end if;

  insert into public.partner_accounts (user_id, partner_id, label)
  values (p_user_id, p_partner_id, coalesce(p_label, ''))
  on conflict (user_id) do update
    set partner_id = excluded.partner_id,
        label      = excluded.label;
end;
$$;

revoke execute on function
  public.link_partner_account(uuid, text, text) from public;
