-- =====================================================================
-- 0136 -- PARTNERS APP: an admin without a seat, and one answer to
--         "which organisation is this login?"
-- (Partner Editions P1, 2026-10-30; docs/partner-editions/PARTNERS-APP.md)
-- ---------------------------------------------------------------------
-- ParentVeda Partners is the third flavour (employer, school, IVF centre).
-- Before it can show anything it has to know two things about the person
-- signing in, and until now the database could answer neither cleanly.
--
-- 1. AN ADMIN IS A ROLE, NOT A MEMBER (MASTER R1, STILL-OPEN §11.8).
--
--    0060 made an HR admin "an active member of the sponsor who also holds
--    the sponsor_admin capability". So to see the dashboard, HR had to
--    ACTIVATE the benefit with a work email, which spends a paid seat on
--    someone who may never be a parent. It also means an admin at a
--    school, who is not a parent there, cannot exist at all.
--
--    sponsor_admins is the role on its own: one row says "this login runs
--    this sponsor's programme", nothing about benefits. Written by
--    service_role only, like partner_accounts (0068): a client that could
--    insert here could attach itself to any company and read its roster.
--
--    my_sponsor_admin_id() reads it FIRST, then falls back to the 0060
--    rule, so every demo and every admin already set up keeps working.
--    The trade-off: two ways to be an admin for a while. Accepted, because
--    breaking the existing demo admin to tidy the model would be a
--    regression the day of a sales call. Drop the fallback once every
--    admin has a sponsor_admins row.
--
-- 2. ONE RESOLVER FOR BOTH KINDS OF ORGANISATION.
--
--    A sponsor (employer, school) and a care_org (an IVF centre with
--    several doctors) live in different tables with different gates. The
--    app should not ask two questions and reconcile the answers on the
--    phone, because the reconciling rule ("sponsor wins") would then live
--    in Dart where nothing else can see it. my_partner_org() asks both and
--    returns one flat object:
--
--      {ok, kind: 'sponsor'|'care_org', id, name, sponsor_kind, logo_url,
--       status}
--
--    or, when the login is no organisation, {ok:false, code} where code
--    says what it IS, so the sign-in screen can point to the right app:
--      'doctor'        has an expert_accounts row  -> use ParentVeda+
--      'parent'        has an onboarded profile    -> use ParentVeda
--      'not_an_admin'  neither
--
--    WHY status IS RETURNED, NOT FILTERED. my_sponsor_admin_id() keeps
--    answering only for ACTIVE sponsors, so a suspended programme's
--    dashboard shows nothing (R2). But "nothing" on the phone would read
--    as "you are not an admin", which is false and sends HR to the wrong
--    person. So the resolver reports the organisation whatever its status
--    and the app says "your programme is paused". Who you are and what
--    you may see are separate questions; this answers the first.
--
--    WHO COUNTS AS A care_org LOGIN. Only Route A of caller_owns_partner:
--    a partner_accounts row (one org per login, R7). Route B (an expert
--    who owns a care_partners row) is a DOCTOR and belongs in ParentVeda+,
--    and caller_owns_partner itself is unchanged (R4).
--
-- SAFE TO RUN TWICE. PREREQ: 0058, 0060, 0068, 0132.
-- ORDER TO RUN: before installing the partner flavour. The parent and
-- doctor apps do not call anything here.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The role.
-- ---------------------------------------------------------------------
create table if not exists public.sponsor_admins (
  user_id     uuid        not null references auth.users (id) on delete cascade,
  sponsor_id  text        not null references public.sponsors (id) on delete cascade,
  added_at    timestamptz not null default now(),
  -- Who granted it: an ops person's email or a ticket id. Free text; it
  -- exists so a wrong grant can be traced, not for any rule.
  added_by    text        not null default '',
  -- One organisation per login (R7). The PK is user_id alone for that
  -- reason, the same shape as partner_accounts: a second company for the
  -- same login is a refusal, not a second row the app has to choose from.
  primary key (user_id)
);

create index if not exists sponsor_admins_sponsor_idx
  on public.sponsor_admins (sponsor_id);

alter table public.sponsor_admins enable row level security;
grant select on public.sponsor_admins to authenticated;

-- A login reads only its own row. No write policy, on purpose.
drop policy if exists "sponsor_admins own read" on public.sponsor_admins;
create policy "sponsor_admins own read" on public.sponsor_admins
  for select using (user_id = auth.uid());


-- ---------------------------------------------------------------------
-- 2. my_sponsor_admin_id(): the role first, then the 0060 rule.
--
-- Same signature, same grant, so every RPC built on it (sponsor_dashboard,
-- sponsor_roster, sponsor_trend, sponsor_engagement, sponsor_remove_member)
-- accepts a seatless admin with no change of its own. That is the payoff
-- of 0060 resolving the company in ONE function: a new way in is one edit.
--
-- Still ACTIVE sponsors only, on both routes: a suspended programme hides
-- the admin's numbers (R2). The resolver below is what tells them why.
-- ---------------------------------------------------------------------
create or replace function public.my_sponsor_admin_id()
returns text
language sql stable security definer set search_path = ''
as $$
  select coalesce(
    -- (0136) The role. One row per login, so no ordering is needed.
    (select a.sponsor_id
       from public.sponsor_admins a
       join public.sponsors s on s.id = a.sponsor_id
      where a.user_id = auth.uid()
        and s.status = 'active'),
    -- 0060, unchanged: an active member who holds the capability.
    (select m.sponsor_id
       from public.sponsor_members m
       join public.sponsors s on s.id = m.sponsor_id
      where m.user_id = auth.uid()
        and m.status = 'active'
        and s.status = 'active'
        and public.has_capability('sponsor_admin')
      -- The oldest membership wins; sponsor_id breaks a tie between two
      -- rows written in one transaction (identical activated_at).
      order by m.activated_at, m.sponsor_id
      limit 1)
  );
$$;

grant execute on function public.my_sponsor_admin_id() to authenticated;


-- ---------------------------------------------------------------------
-- 3. my_partner_org(): which organisation is this login, if any?
--
-- Sponsor wins if both, because a sponsor admin row is the more specific
-- grant: it is written for exactly this app, while partner_accounts also
-- serves the web portal's care view. No partner has hit "both" yet; the
-- rule is written down so the answer never depends on query order.
--
-- Answers the caller only (auth.uid()); takes no parameter, so there is
-- no shape of this call that describes someone else's organisation.
-- ---------------------------------------------------------------------
create or replace function public.my_partner_org()
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_s   record;
  v_c   record;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'code', 'not_signed_in');
  end if;

  -- (a) Sponsor, by the role. Whatever its status: see the header.
  select s.id, s.name, s.kind, s.logo_url, s.status, s.support_contact
    into v_s
    from public.sponsor_admins a
    join public.sponsors s on s.id = a.sponsor_id
   where a.user_id = v_uid;

  -- (b) Sponsor, by the 0060 rule. Active only, because that rule has
  -- always been active-only and widening it here would make a suspended
  -- member-admin look like an admin of a paused company they never ran.
  if v_s.id is null then
    select s.id, s.name, s.kind, s.logo_url, s.status, s.support_contact
      into v_s
      from public.sponsors s
     where s.id = public.my_sponsor_admin_id();
  end if;

  if v_s.id is not null then
    return jsonb_build_object(
      'ok', true,
      'kind', 'sponsor',
      'id', v_s.id,
      'name', v_s.name,
      'sponsor_kind', v_s.kind,
      'logo_url', v_s.logo_url,
      'status', v_s.status,
      'support_contact', v_s.support_contact);
  end if;

  -- (c) A care organisation: Route A only (partner_accounts). Rejected and
  -- soft-deleted partners are not organisations any more.
  select cp.id, cp.name, cp.type, cp.logo_url, cp.status
    into v_c
    from public.partner_accounts pa
    join public.care_partners cp on cp.id = pa.partner_id
   where pa.user_id = v_uid
     and cp.deleted_at is null
     and cp.status <> 'rejected';

  if v_c.id is not null then
    return jsonb_build_object(
      'ok', true,
      'kind', 'care_org',
      'id', v_c.id,
      'name', v_c.name,
      'sponsor_kind', null,
      'partner_type', v_c.type,
      'logo_url', v_c.logo_url,
      'status', v_c.status,
      'support_contact', null);
  end if;

  -- (d) Not an organisation. Say what it is, so the app points to the
  -- right door rather than a dead end.
  if exists (select 1 from public.expert_accounts ea where ea.user_id = v_uid) then
    return jsonb_build_object('ok', false, 'code', 'doctor');
  end if;
  if exists (select 1 from public.profiles p
              where p.id = v_uid and (p.role is not null or p.due_date is not null)) then
    return jsonb_build_object('ok', false, 'code', 'parent');
  end if;
  return jsonb_build_object('ok', false, 'code', 'not_an_admin');
end;
$$;

revoke all on function public.my_partner_org() from public, anon;
grant execute on function public.my_partner_org() to authenticated;


-- ---------------------------------------------------------------------
-- 4. Granting the role (SQL editor, until Directus has a screen for it).
--
--   insert into public.sponsor_admins (user_id, sponsor_id, added_by)
--   values ((select id from auth.users where email = 'hr@acme.com'),
--           'acme', 'ops: <your name>')
--   on conflict (user_id) do update
--     set sponsor_id = excluded.sponsor_id, added_by = excluded.added_by;
--
-- The account must exist first (they sign in once, or ops creates it in
-- Authentication -> Users with a password, R6).
-- ---------------------------------------------------------------------
