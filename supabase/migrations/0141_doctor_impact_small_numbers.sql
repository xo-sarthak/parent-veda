-- =====================================================================
-- 0141_doctor_impact_small_numbers.sql -- a solo doctor's Impact screen
-- holds back what families DID below the same threshold as everyone else
-- ---------------------------------------------------------------------
-- Partner Editions R3 says small numbers are hidden "for clinics and
-- doctors". P2 did it for employers and schools (sponsor_dashboard), P3
-- for IVF centres (care_org_dashboard, 0139). ParentVeda+'s Impact screen
-- reads partner_impact and partner_funnel (0068), which had no threshold:
-- a fertility doctor with two families who joined through her code saw
-- "Pregnancies supported: 1" and could tell which patient had conceived,
-- possibly before the patient chose to tell her. Decided by the user
-- 2026-10-30 (STILL-OPEN §5.1e, option A).
--
-- THE RULE, the same as 0139:
--   * referral facts are never held back: families referred, active in
--     the last 30 days, scanned, installed, signed up. She handed the code
--     over; that they arrived is hers to know.
--   * behaviour is null while the partner's families are fewer than
--     min_cohort: pregnancies, children, consultations, vaccinations,
--     reads, and the funnel's "activated" (told us a pregnancy or a child).
--   * the threshold is the ONE row sponsors and centres use
--     (sponsor_analytics_config), so tightening it is one update for all.
--
-- ON THE SERVER, NOT IN THE APP, for the reason 0139 gives: the doctor
-- signs in, and anyone signed in can call the function directly. A number
-- the app hides but the server sends is not hidden.
--
-- WHY partner_impact IS DROPPED AND RECREATED. It gains two columns
-- (suppressed, min_cohort) so the screen can say "shown once 5 families
-- join" with the server's number. `create or replace` cannot change a
-- function's return type; it errors. Dropping also drops its grant, so the
-- grant is restated below. The parameter list is unchanged, so every
-- caller's `rpc('partner_impact', {p_partner_id})` resolves as before; an
-- old app build simply ignores the two new keys and reads null as 0 until
-- it updates (it showed 0 for "none yet" anyway).
--
-- partner_funnel keeps its exact return type (activated was always a
-- nullable bigint on the wire), so it is a plain create-or-replace.
--
-- Everything else is 0068 verbatim: caller_owns_partner() as the only
-- gate, the same counting definitions word for word (my_doctor_referrals
-- and care_org_dashboard rely on them matching), counts only, no user id.
--
-- PREREQ: 0037, 0039, 0060, 0068. ORDER TO RUN: any time. Safe to run
-- twice.
-- =====================================================================

drop function if exists public.partner_impact(text);

create function public.partner_impact(p_partner_id text)
returns table (
  families_referred      bigint,
  active_this_month      bigint,
  pregnancies_supported  bigint,
  children_added         bigint,
  consultations_done     bigint,
  vaccinations_completed bigint,
  content_consumed       bigint,
  suppressed             boolean,
  min_cohort             int
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
  ),
  cfg as (
    select coalesce(
      (select c.min_cohort from public.sponsor_analytics_config c
        where c.id = 'default'), 5) as m
  ),
  held as (
    -- A caller who does not own the partner has no families, so this is
    -- true for them and every behaviour figure is null: zeros, never rows.
    select (select count(*) from fam) < (select m from cfg) as h
  )
  select
    (select count(*) from fam),
    (select count(distinct t.user_id) from public.parent_timeline t
      where t.user_id in (select user_id from fam)
        and t.at > now() - interval '30 days'),
    case when (select h from held) then null else
      (select count(*) from public.parent_timeline t
        where t.user_id in (select user_id from fam) and t.event = 'pregnancy_added') end,
    case when (select h from held) then null else
      (select count(*) from public.parent_timeline t
        where t.user_id in (select user_id from fam) and t.event = 'child_added') end,
    case when (select h from held) then null else
      (select count(*) from public.parent_timeline t
        where t.user_id in (select user_id from fam) and t.event = 'consultation_completed') end,
    case when (select h from held) then null else
      (select count(*) from public.parent_timeline t
        where t.user_id in (select user_id from fam) and t.event = 'vaccination_completed') end,
    case when (select h from held) then null else
      (select count(*) from public.parent_timeline t
        where t.user_id in (select user_id from fam) and t.event = 'content_read') end,
    (select h from held),
    (select m from cfg);
$$;

revoke execute on function public.partner_impact(text) from public, anon;
grant execute on function public.partner_impact(text) to authenticated;


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
  ),
  cfg as (
    select coalesce(
      (select c.min_cohort from public.sponsor_analytics_config c
        where c.id = 'default'), 5) as m
  )
  select
    (select count(*) from fam where scanned_at is not null),
    (select count(*) from fam where installed_at is not null),
    (select count(*) from fam where signed_up_at is not null),
    -- Behaviour: held back below the threshold, as partner_impact.
    case when (select count(*) from fam) < (select m from cfg) then null else
      (select count(distinct t.user_id) from public.parent_timeline t
        where t.user_id in (select user_id from fam)
          and t.event in ('pregnancy_added','child_added')) end;
$$;

grant execute on function public.partner_funnel(text) to authenticated;


-- =====================================================================
-- VERIFY (SQL editor, acting as a doctor whose partner has < 5 families:
--   select set_config('request.jwt.claims',
--     json_build_object('sub', '<uid>', 'role', 'authenticated')::text, true);)
--
--   select * from public.partner_impact('<her partner id>');
--     -> families_referred and active_this_month set; the five behaviour
--        columns null; suppressed true; min_cohort 5.
--   select activated from public.partner_funnel('<her partner id>');
--     -> null.
--
--   -- A partner with 5+ families: every column set, suppressed false.
--   -- Someone else's partner id: families 0, behaviour null.
-- =====================================================================
