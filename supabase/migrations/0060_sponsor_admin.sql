-- =====================================================================
-- 0060_sponsor_admin.sql -- what HR may see, and the wall that stops
--                           them seeing anything else.
-- ---------------------------------------------------------------------
-- HR IS A USER WITH A CAPABILITY, NOT A SEPARATE SYSTEM.
--
-- Someone from a customer's People team signs in with their work email
-- like every other employee. A `sponsor_admin` capability on their
-- entitlement reveals a Programme section nothing else can see. No
-- second auth system, no middleware, no third codebase -- which is the
-- entitlement architecture from 0057 doing the job it was built for.
--
-- THE PROMISE THIS FILE HAS TO KEEP
--
-- We sell a parenting benefit to an employer and tell the employee
-- their employer cannot see their pregnancy, their child, their
-- journal, their Ask Veda questions or their searches. That promise is
-- worth exactly as much as the code enforcing it, so it is enforced
-- STRUCTURALLY rather than by remembering:
--
--   * The dashboard is a function returning pre-aggregated numbers. It
--     never returns rows about a person.
--   * The roster returns eligibility ONLY -- work email, status,
--     activation date. NOT user_id, and nothing behavioural. HR needs
--     to know who took up the benefit they paid for; they do not need
--     to know what anybody did with it.
--   * Everything is resolved from auth.uid(). The sponsor id is never
--     a parameter, so there is no shape of these calls that answers
--     about a different company. Same reasoning as expert_roster().
--
-- SUPPRESSION, AND WHY IT IS NOT PARANOIA
--
-- In a thirty-person company, "3 consultations booked this month" plus
-- who is visibly pregnant is not anonymous -- it is a name. So
-- behavioural aggregates are withheld below a cohort of n (default 5)
-- and the app says so rather than showing a zero. A withheld number
-- reads as a policy; a zero reads as a fact, and it would be the wrong
-- one.
--
-- Note what is NOT suppressed: seats and activations. Those are
-- commercial facts about a contract the sponsor signed, they are not
-- behaviour, and refusing to tell a customer how many of their seats
-- are used would be absurd. The line is behaviour, not headcount.
--
-- WHAT IS DELIBERATELY ABSENT
--
-- "Average time spent in the app" is not here and cannot be. It needs a
-- per-user usage event stream this product does not have -- profile_events
-- is anonymous by construction (install_id, no user_id) -- and building
-- one to answer an HR slide would mean starting to collect exactly the
-- data we promise not to. Say so to a sponsor rather than promise it.
--
-- Company events are absent too, for a duller reason: programmes have no
-- sponsor audience scope yet (Phase 3 of the plan). A count would have
-- to be invented, so there is none.
--
-- PREREQ: 0050 (_audit/_refuse/_allow), 0057 (entitlements), 0058
--         (sponsors), 0029 (booking_bookings).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The capability, and a plan that carries it.
--
-- A SEPARATE plan, not a capability added to employer_standard --
-- otherwise every employee at the company would see their colleagues'
-- take-up. Note also that 0057's `free` plan and 0058's
-- `employer_standard` were seeded with `select ... from capabilities`
-- AT THAT TIME, so a capability registered now is granted by neither.
-- That is why those seeds ran once instead of being a trigger.
-- ---------------------------------------------------------------------
insert into public.capabilities (id, name, description, category) values
  ('sponsor_admin',
   'Sponsor programme dashboard',
   'See take-up of the benefit this organisation sponsors. Aggregates and eligibility only -- never individual usage.',
   'sponsor')
on conflict (id) do nothing;

insert into public.plans (id, name, kind) values
  ('sponsor_admin', 'Sponsor administrator', 'internal')
on conflict (id) do nothing;

insert into public.plan_capabilities (plan_id, capability_id) values
  ('sponsor_admin', 'sponsor_admin')
on conflict do nothing;


-- ---------------------------------------------------------------------
-- 2. The suppression threshold -- a row, not a constant.
--
-- Early customers may be small enough that 5 is too low. Raising it
-- must not be a release: the whole point of a config row is that a
-- privacy decision can be tightened the day it needs to be.
-- ---------------------------------------------------------------------
create table if not exists public.sponsor_analytics_config (
  id         text primary key default 'default' check (id = 'default'),
  min_cohort int  not null default 5 check (min_cohort >= 1),
  updated_at timestamptz not null default now()
);

insert into public.sponsor_analytics_config (id) values ('default')
on conflict (id) do nothing;

alter table public.sponsor_analytics_config enable row level security;
-- Not readable by app sessions: the threshold is applied server-side and
-- reported alongside the numbers, so nobody needs to read the table to
-- know it. Directus may edit it; that is the point of a config row.
revoke all on public.sponsor_analytics_config from anon, authenticated;
grant select, update on public.sponsor_analytics_config to directus_cms;
drop policy if exists "sponsor_analytics_config cms" on public.sponsor_analytics_config;
create policy "sponsor_analytics_config cms" on public.sponsor_analytics_config
  for all to directus_cms using (true) with check (true);


-- ---------------------------------------------------------------------
-- 3. Which sponsor does the caller administer?
--
-- Two conditions, both required: they hold the capability, AND they are
-- an active member of that sponsor. The membership is what supplies the
-- sponsor id -- so an admin is always someone inside the organisation,
-- and granting the plan to the wrong person still shows them nothing
-- unless they also activated with that company's domain.
--
-- Returns null rather than raising, so callers can branch on "not an
-- admin" without exception handling.
-- ---------------------------------------------------------------------
create or replace function public.my_sponsor_admin_id()
returns text
language sql stable security definer set search_path = ''
as $$
  select m.sponsor_id
    from public.sponsor_members m
    join public.sponsors s on s.id = m.sponsor_id
   where m.user_id = auth.uid()
     and m.status = 'active'
     and s.status = 'active'
     and public.has_capability('sponsor_admin')
   -- Someone can belong to two sponsors (0057 exists so a second grant
   -- is a second row, not a conflict). The oldest membership wins, and
   -- sponsor_id is a tie-break rather than decoration: two rows written
   -- in one transaction carry an IDENTICAL activated_at, because now()
   -- is the transaction timestamp. Without a second key the answer
   -- would be whatever order the planner returned.
   order by m.activated_at, m.sponsor_id
   limit 1;
$$;

grant execute on function public.my_sponsor_admin_id() to authenticated;


-- ---------------------------------------------------------------------
-- 4. The dashboard.
--
-- One round trip, one flat object. The screen is a thin renderer over
-- this -- which is what makes a web portal later a front-end job rather
-- than a rebuild, and is the reason the aggregation lives here at all.
--
-- Behavioural fields come back as null, not zero, when the cohort is
-- too small, and `suppressed` says so explicitly so the UI never has to
-- infer why a number is missing.
-- ---------------------------------------------------------------------
create or replace function public.sponsor_dashboard()
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_id        text := public.my_sponsor_admin_id();
  v_s         record;
  v_min       int;
  v_active    int;
  v_removed   int;
  v_last30    int;
  v_booked    int;
  v_done      int;
  v_upcoming  int;
  v_suppress  boolean;
begin
  if v_id is null then
    -- Not an admin. Not an error either -- the app asks this of every
    -- signed-in user and the honest answer for almost all of them is no.
    return jsonb_build_object('ok', false, 'code', 'not_a_sponsor_admin');
  end if;

  select * into v_s from public.sponsors where id = v_id;
  select min_cohort into v_min from public.sponsor_analytics_config
   where id = 'default';
  v_min := coalesce(v_min, 5);

  select count(*) filter (where status = 'active'),
         count(*) filter (where status = 'removed'),
         count(*) filter (where status = 'active'
                            and activated_at > now() - interval '30 days')
    into v_active, v_removed, v_last30
    from public.sponsor_members where sponsor_id = v_id;

  -- BEHAVIOUR. Counted across the sponsor's active members as a whole
  -- and never per person -- the query cannot return a row about anyone
  -- because it aggregates before it returns.
  -- The vocabulary is the app's: upcoming | attended | missed |
  -- cancelled (BookingStatus in booking_models.dart). "Attended" is the
  -- one HR cares about -- a booked-but-missed consultation is not value
  -- delivered, and reporting it as one would flatter the number.
  select count(*) filter (where b.status <> 'cancelled'),
         count(*) filter (where b.status = 'attended'),
         count(*) filter (where b.status = 'upcoming'
                            and b.starts_utc > now())
    into v_booked, v_done, v_upcoming
    from public.booking_bookings b
    join public.sponsor_members m
      on m.user_id = b.user_id and m.sponsor_id = v_id and m.status = 'active';

  v_suppress := v_active < v_min;

  return jsonb_build_object(
    'ok', true,
    'sponsor_id', v_s.id,
    'sponsor_name', v_s.name,
    'kind', v_s.kind,
    'renewal_at', v_s.renewal_at,
    -- Commercial facts: never suppressed.
    'seats_purchased', v_s.seats_purchased,
    'activated', v_active,
    'removed', v_removed,
    'activated_last_30d', v_last30,
    'seats_left', case when v_s.seats_purchased is null then null
                       else greatest(v_s.seats_purchased - v_active, 0) end,
    'activation_rate', case when v_s.seats_purchased is null or v_s.seats_purchased = 0
                            then null
                            else round(100.0 * v_active / v_s.seats_purchased) end,
    -- Behavioural facts: withheld below the threshold.
    'suppressed', v_suppress,
    'min_cohort', v_min,
    'consultations_booked',    case when v_suppress then null else v_booked end,
    'consultations_completed', case when v_suppress then null else v_done end,
    'consultations_upcoming',  case when v_suppress then null else v_upcoming end
  );
end;
$$;

grant execute on function public.sponsor_dashboard() to authenticated;


-- ---------------------------------------------------------------------
-- 5. The roster -- the screen where the promise is kept or broken.
--
-- Eligibility only. Note what the return type does NOT contain: no
-- user_id, no name, no due date, no child, no booking, no last-seen.
-- The columns are the whole security model here, because a caller
-- cannot select what the function does not return -- so the promise is
-- a signature rather than a habit.
--
-- The work email is included because it is the thing HR supplied and
-- the thing they reconcile against their own headcount. It says nothing
-- about the person's pregnancy or their child.
-- ---------------------------------------------------------------------
create or replace function public.sponsor_roster()
returns table (
  work_email   text,
  status       text,
  activated_at timestamptz,
  removed_at   timestamptz
)
language sql stable security definer set search_path = ''
as $$
  select m.work_email, m.status, m.activated_at, m.removed_at
    from public.sponsor_members m
   where m.sponsor_id = public.my_sponsor_admin_id()
   order by m.activated_at desc;
$$;

grant execute on function public.sponsor_roster() to authenticated;


-- ---------------------------------------------------------------------
-- 6. Removing a leaver, from inside the app.
--
-- 0058's remove_sponsor_member() is service_role only and takes the
-- sponsor id as a parameter -- correct for a back-office call, wrong to
-- hand an app session, because a parameter is something a client can
-- change. This wrapper takes only the work email and resolves the
-- sponsor from the caller, so an admin at company A cannot spell their
-- way into company B.
-- ---------------------------------------------------------------------
create or replace function public.sponsor_remove_member(p_work_email text)
returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_id    text := public.my_sponsor_admin_id();
  v_email text := lower(trim(p_work_email));
  v_uid   uuid;
begin
  if v_id is null then
    return public._refuse(coalesce(auth.uid()::text, 'anonymous'),
      'sponsor_remove_member', 'sponsor_members', null,
      'not_a_sponsor_admin', 'You do not administer a programme.');
  end if;

  select user_id into v_uid from public.sponsor_members
   where sponsor_id = v_id and lower(work_email) = v_email and status = 'active';

  if v_uid is null then
    return public._refuse(auth.uid()::text, 'sponsor_remove_member',
      'sponsor_members', v_id, 'not_a_member',
      'That person is not an active member.');
  end if;

  return public.remove_sponsor_member(v_id, v_uid, auth.uid()::text);
end;
$$;

grant execute on function public.sponsor_remove_member(text) to authenticated;


-- =====================================================================
-- VERIFY
--
--   -- As an ordinary signed-in user, every door is shut:
--   select public.my_sponsor_admin_id();     -> null
--   select public.sponsor_dashboard();       -> {"ok":false,"code":"not_a_sponsor_admin"}
--   select * from public.sponsor_roster();   -> 0 rows
--
--   -- Make someone an admin (they must already be an active member):
--   select public.grant_plan(
--     '<their-auth-uid>'::uuid, 'sponsor_admin', 'internal',
--     '<sponsor-id>', null, 'setup');
--
--   -- The roster can never leak an id. This must list four columns and
--   -- no user_id:
--   select column_name from information_schema.columns
--    where table_name = 'sponsor_roster';       -- (via the function's
--                                               --  return type)
--
--   -- Cross-tenant: as A's admin, the roster returns zero of B's rows
--   -- because my_sponsor_admin_id() cannot resolve to B.
-- =====================================================================
