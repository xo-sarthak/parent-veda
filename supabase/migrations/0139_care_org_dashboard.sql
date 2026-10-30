-- =====================================================================
-- 0139_care_org_dashboard.sql -- what an IVF centre sees in ParentVeda
-- Partners, from ONE call that finds the centre the same way the app does
-- ---------------------------------------------------------------------
-- Partner Editions P3 (docs/partner-editions/PARTNERS-APP.md).
--
-- WHY NOT THE FOUR CALLS THE PLAN NAMED. P3 was planned on partner_impact,
-- partner_funnel, partner_earnings (0068) and partner_referral_breakdown
-- (0073). Checked against my_partner_org() (0136) before building:
--
--   * The first three take a partner id and let it through
--     caller_owns_partner(), Route A OR Route B. The app would pass the id
--     my_partner_org() returned, which is always a Route A partner, so
--     those three DO agree on which centre. Not the problem.
--   * partner_referral_breakdown() takes NO id. It sums every partner the
--     login owns by EITHER route and groups by doctor only. A centre
--     manager who is also a doctor with her own practice (Route A for the
--     centre, Route B for herself -- the dual case R5 talks about) would
--     get the centre's families and her own practice's families in one
--     table, with nothing to tell them apart.
--   * partner_impact returns behaviour (pregnancies, children, consults,
--     vaccinations, reads) and partner_funnel returns "activated", none of
--     it held back for small numbers. Hiding them in the app is not hiding
--     them: the admin has a password and the public key, and can call the
--     RPC directly. For an IVF centre "pregnancies supported: 1" after two
--     referrals says which patient conceived. R3 needs the server to hold
--     it back, as sponsor_dashboard does.
--
-- Changing partner_impact itself would also change ParentVeda+, whose
-- impact screen reads it for solo doctors. So the four stay exactly as
-- they are, and this is a new function, shaped like sponsor_dashboard:
-- no parameter, one jsonb answer, the threshold reported beside the
-- numbers.
--
-- THE RESOLVER IS my_partner_org() ITSELF, not a copy of its join. Two
-- copies of "which centre is this login" is two chances to fix one; here
-- there is one, and this function only reads its answer. A login that
-- my_partner_org() calls a sponsor (sponsor wins) gets no care numbers
-- here either, which is what the app shows them anyway.
--
-- TWO KINDS OF NUMBER (R3):
--   * referral facts, never held back: families joined, scanned,
--     installed, signed up, active in the last 30 days, families per
--     doctor, and money (contract facts);
--   * behaviour, null below min_cohort: activated (told us a pregnancy or
--     a child), pregnancies, children, consultations, vaccinations, reads.
--     The base is the centre's families. The threshold is the SAME row
--     sponsors use (sponsor_analytics_config): one privacy dial, not two
--     that drift.
--
-- NO FAMILY LEAVES THIS FUNCTION. No user id, no token, no name of a
-- parent. The per-doctor rows carry the doctor's name (the centre's own
-- staff) and a DAY, not a timestamp: a time to the minute can be laid
-- next to an appointment book and names a family; a day is all "latest"
-- needs.
--
-- partner_referral_breakdown() is left alone and still has no caller.
-- Recorded in STILL-OPEN: give it an id or drop it before anyone wires it.
--
-- PREREQ: 0037, 0039, 0060, 0068, 0072, 0073, 0133, 0136.
-- ORDER TO RUN: any time after 0136. Safe to run twice.
-- =====================================================================

create or replace function public.care_org_dashboard()
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_org        jsonb := public.my_partner_org();
  v_id         text;
  v_min        int;
  v_families   int;
  v_scanned    int;
  v_installed  int;
  v_signed_up  int;
  v_active     int;
  v_activated  int;
  v_preg       int;
  v_children   int;
  v_consults   int;
  v_vacc       int;
  v_reads      int;
  v_suppress   boolean;
  v_earnings   jsonb;
  v_doctors    jsonb;
begin
  -- Zeros or {ok:false, code}, never someone else's rows.
  if coalesce(v_org->>'kind', '') <> 'care_org' then
    return jsonb_build_object('ok', false, 'code', 'not_a_care_org');
  end if;
  -- A paused centre's numbers are hidden, as a suspended sponsor's are
  -- (R2). my_partner_org() reports the status so the app can say why.
  if coalesce(v_org->>'status', '') <> 'active' then
    return jsonb_build_object('ok', false, 'code', 'not_live');
  end if;
  v_id := v_org->>'id';

  select min_cohort into v_min from public.sponsor_analytics_config
   where id = 'default';
  v_min := coalesce(v_min, 5);

  -- Referral facts. The same definitions as partner_funnel and
  -- partner_impact, so a number reads the same in both apps.
  select count(*),
         count(*) filter (where a.scanned_at is not null),
         count(*) filter (where a.installed_at is not null),
         count(*) filter (where a.signed_up_at is not null)
    into v_families, v_scanned, v_installed, v_signed_up
    from public.partner_attributions a
   where a.partner_id = v_id;

  select count(distinct t.user_id) into v_active
    from public.parent_timeline t
   where t.user_id in (select a.user_id from public.partner_attributions a
                        where a.partner_id = v_id)
     and t.at > now() - interval '30 days';

  -- Behaviour. Counted, then withheld below the threshold: the counting
  -- is cheap and keeps one code path whatever the size.
  select count(distinct t.user_id)
           filter (where t.event in ('pregnancy_added','child_added')),
         count(*) filter (where t.event = 'pregnancy_added'),
         count(*) filter (where t.event = 'child_added'),
         count(*) filter (where t.event = 'consultation_completed'),
         count(*) filter (where t.event = 'vaccination_completed'),
         count(*) filter (where t.event = 'content_read')
    into v_activated, v_preg, v_children, v_consults, v_vacc, v_reads
    from public.parent_timeline t
   where t.user_id in (select a.user_id from public.partner_attributions a
                        where a.partner_id = v_id);

  v_suppress := v_families < v_min;

  -- Money: the same grouping partner_earnings returns, biggest first.
  select coalesce(jsonb_agg(jsonb_build_object(
           'source', e.source, 'status', e.status,
           'entries', e.entries, 'partner_minor', e.partner_minor)
           order by e.partner_minor desc), '[]'::jsonb)
    into v_earnings
    from (select l.source, l.status, count(*) as entries,
                 coalesce(sum(l.partner_minor), 0) as partner_minor
            from public.commission_ledger l
           where l.partner_id = v_id
           group by l.source, l.status) e;

  -- Per doctor. Three kinds of row, so every family is filed somewhere
  -- and every doctor shows, even with none yet (the empty row is the
  -- nudge to hand a code out):
  --   'doctor'  a published doctor of this centre, families from her code;
  --   'former'  a code that names a doctor no longer listed here (left,
  --             archived, moved). Attribution is history and is never
  --             rewritten (0073), so her families stay hers;
  --   'centre'  families from the centre's own code (no doctor on it).
  with fam as (
    select a.expert_id, count(*)::int as families,
           max(a.linked_at)::date as latest_on
      from public.partner_attributions a
     where a.partner_id = v_id
     group by a.expert_id
  ),
  team as (
    select ep.expert_id, ep.name
      from public.expert_profiles ep
     where ep.partner_id = v_id
       and ep.status = 'published'
  ),
  r as (
    select 'doctor' as who, t.name, coalesce(f.families, 0) as families,
           f.latest_on
      from team t
      left join fam f on f.expert_id = t.expert_id
    union all
    select 'former', coalesce(ep.name, ''), f.families, f.latest_on
      from fam f
      left join public.expert_profiles ep on ep.expert_id = f.expert_id
     where f.expert_id is not null
       and not exists (select 1 from team t where t.expert_id = f.expert_id)
    union all
    select 'centre', '', f.families, f.latest_on
      from fam f
     where f.expert_id is null
  )
  select coalesce(jsonb_agg(jsonb_build_object(
           'who', r.who, 'name', r.name,
           'families', r.families, 'latest_on', r.latest_on)
           order by r.families desc, r.name), '[]'::jsonb)
    into v_doctors
    from r;

  return jsonb_build_object(
    'ok', true,
    'partner_id', v_id,
    'min_cohort', v_min,
    'suppressed', v_suppress,
    'families',   v_families,
    'scanned',    v_scanned,
    'installed',  v_installed,
    'signed_up',  v_signed_up,
    'active_30d', v_active,
    'activated',     case when v_suppress then null else v_activated end,
    'pregnancies',   case when v_suppress then null else v_preg end,
    'children',      case when v_suppress then null else v_children end,
    'consultations', case when v_suppress then null else v_consults end,
    'vaccinations',  case when v_suppress then null else v_vacc end,
    'content_read',  case when v_suppress then null else v_reads end,
    'earnings', v_earnings,
    'doctors',  v_doctors
  );
end;
$$;

revoke all on function public.care_org_dashboard() from public, anon;
grant execute on function public.care_org_dashboard() to authenticated;


-- =====================================================================
-- VERIFY (SQL editor; act as a user with
--   select set_config('request.jwt.claims',
--     json_build_object('sub', '<uid>', 'role', 'authenticated')::text, true);)
--
--   -- As the centre's login (a partner_accounts row):
--   select public.care_org_dashboard();
--     -> ok true; 'families' equals
--   select count(*) from public.partner_attributions where partner_id = '<id>';
--     -> and the per-doctor 'families' add up to the same number.
--
--   -- As a parent, a doctor, or a sponsor admin:
--   select public.care_org_dashboard();   -> {ok:false, code:not_a_care_org}
--
--   -- Below the threshold (a demo centre with < 5 families):
--     -> 'suppressed' true and every behaviour key null; referral counts set.
-- =====================================================================
