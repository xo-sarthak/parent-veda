-- =====================================================================
-- 0061_sponsor_eligibility_roster.sql -- the named list, and why it
--                                        outranks the domain rule.
-- ---------------------------------------------------------------------
-- 0058 decided eligibility by EMAIL DOMAIN: anyone at acme.com may take
-- a seat. That is the right rule at fifty customers, where nobody wants
-- to chase HR for a spreadsheet every quarter.
--
-- It is the wrong rule at one customer. Early on the deal is: a company
-- says yes and hands over a list of the people it is paying for. That
-- list is more precise than a domain in every way that matters --
-- contractors and the whole of a 4,000-person parent company are not on
-- it, leavers can be taken off it, and the seat count is simply how
-- long it is.
--
-- THE RULE, AND WHY IT IS NOT A SETTING
--
--     If a sponsor has a roster, the roster is the truth.
--     If they never gave us one, the domain is.
--
-- The obvious alternative is an eligibility_mode column with
-- 'roster' | 'domain' | 'either'. Rejected on CLAUDE.md's rule: a config
-- that can express more states than the product has is a bug surface,
-- not flexibility. Three modes means three code paths, two of which
-- nobody has ever chosen, and a support call the day someone picks the
-- wrong one. Deriving it from "is the list empty?" cannot be
-- misconfigured because there is nothing to configure.
--
-- A consequence worth stating rather than discovering: once a company
-- sends a list, a new joiner who is not on it is REFUSED. That is
-- correct -- they were not paid for -- and the fix is HR sending an
-- updated sheet, which is a conversation we want to be having anyway.
--
-- ELIGIBILITY IS NOT MEMBERSHIP, AND THIS IS THE WHOLE REASON THE PANEL
-- MAY TOUCH THIS TABLE
--
--   sponsor_eligible_people  "Acme is paying for priya@acme.com"
--                            -- an HR fact, true before she has heard
--                            of ParentVeda. Ops loads it from a sheet.
--
--   sponsor_members          "priya@acme.com uses ParentVeda"
--                            -- a fact about a person's health app.
--                            Ops must NEVER see it.
--
-- The two tables look almost identical and mean completely different
-- things. That distinction is what lets operations handle onboarding
-- without ever learning who actually signed up, so it is enforced by
-- grants: this table is writable by directus_cms, sponsor_members is
-- not, and 0058's comment about that still stands.
--
-- ⚠️ Still no email sender (STILL-OPEN 11.6). Being on the roster does
-- not grant anything by itself -- it only makes someone ELIGIBLE TO
-- PROVE they control the address. Skipping that proof would mean a
-- leaked spreadsheet is free Premium for whoever has it.
--
-- PREREQ: 0058, 0059.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The list HR sends us.
--
-- Keyed on the email because that is what the sheet is keyed on and
-- what the person will type. Lowercased by a CHECK rather than by
-- trusting the importer: a CSV out of Excel will contain
-- "Priya.Sharma@Acme.com" and it must match "priya.sharma@acme.com".
-- ---------------------------------------------------------------------
create table if not exists public.sponsor_eligible_people (
  work_email   text primary key,
  sponsor_id   text not null references public.sponsors (id) on delete cascade,
  -- Optional, and both come straight off the spreadsheet. full_name is
  -- for HR reconciling their own list; employee_ref is their payroll
  -- or HRMS id, so a re-upload can be matched to what is already here.
  full_name    text,
  employee_ref text,
  status       text not null default 'eligible'
                 check (status in ('eligible', 'revoked')),
  added_at     timestamptz not null default now(),
  revoked_at   timestamptz,
  constraint sponsor_eligible_people_lower
    check (work_email = lower(work_email) and work_email like '%@%.%')
);

create index if not exists sponsor_eligible_people_sponsor_idx
  on public.sponsor_eligible_people (sponsor_id, status);

comment on table public.sponsor_eligible_people is
  'WHO AN ORGANISATION IS PAYING FOR -- loaded from the sheet HR sends. Eligibility, not membership: a row here says nothing about whether the person uses ParentVeda. Contrast sponsor_members, which does and is never shown to the panel.';
comment on column public.sponsor_eligible_people.status is
  'eligible | revoked. Revoking stops FUTURE activations; it does not take away a benefit already granted -- that is remove_sponsor_member(), which is a separate and deliberate act.';

alter table public.sponsor_eligible_people enable row level security;

-- Not public-read, and not readable by app sessions at all. It is a
-- customer's staff list; the matching happens inside the definer
-- function, exactly as sponsor_domains does.
revoke all on public.sponsor_eligible_people from anon, authenticated;

-- The panel MAY write it -- this is the table the CSV lands in, and if
-- ops cannot load a sheet then onboarding a customer stays an
-- engineering ticket forever, which is the thing the panel exists to
-- stop.
grant select, insert, update, delete on public.sponsor_eligible_people
  to directus_cms;
drop policy if exists "sponsor_eligible_people cms write"
  on public.sponsor_eligible_people;
create policy "sponsor_eligible_people cms write"
  on public.sponsor_eligible_people
  for all to directus_cms using (true) with check (true);


-- ---------------------------------------------------------------------
-- 2. One place that answers "may this address take a seat?"
--
-- Extracted rather than written twice. request_ and confirm_ both need
-- it -- ten minutes is long enough for HR to revoke somebody -- and two
-- copies of an eligibility rule is how they end up disagreeing.
--
-- Returns the sponsor row, or nothing. Never explains WHY, because the
-- callers must not be able to tell an unknown address from a revoked
-- one from a suspended customer: that difference is a customer list.
-- ---------------------------------------------------------------------
create or replace function public.sponsor_for_work_email(p_work_email text)
returns public.sponsors
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_email  text := lower(trim(p_work_email));
  v_sponsor public.sponsors;
begin
  -- (a) THE ROSTER WINS. A named person is the strongest signal we have
  --     and the one the contract was written against.
  select s.* into v_sponsor
    from public.sponsor_eligible_people e
    join public.sponsors s on s.id = e.sponsor_id
   where e.work_email = v_email and e.status = 'eligible';

  if v_sponsor.id is not null then
    return v_sponsor;
  end if;

  -- (b) THE DOMAIN, but only for a sponsor who never sent a list. Once
  --     they have, the list is the whole answer -- otherwise a leaver
  --     removed from the sheet would simply fall through to their
  --     still-matching email domain, and the removal would be theatre.
  select s.* into v_sponsor
    from public.sponsor_domains d
    join public.sponsors s on s.id = d.sponsor_id
   where d.domain = split_part(v_email, '@', 2)
     and not exists (select 1 from public.sponsor_eligible_people e2
                      where e2.sponsor_id = s.id);

  return v_sponsor;
end;
$$;


-- ---------------------------------------------------------------------
-- 3. request_sponsor_activation -- replaced to use it.
--
-- Everything else is 0058 verbatim. The only change is where the
-- sponsor comes from.
-- ---------------------------------------------------------------------
create or replace function public.request_sponsor_activation(p_work_email text)
returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_email   text := lower(trim(p_work_email));
  v_sponsor public.sponsors;
  v_used    int;
  v_recent  int;
  v_code    text;
  v_actor   text := coalesce(auth.uid()::text, 'anonymous');
begin
  if v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    return public._refuse(v_actor, 'request_sponsor_activation',
      'sponsor_activation_codes', null, 'invalid_email',
      'That does not look like an email address.');
  end if;

  v_sponsor := public.sponsor_for_work_email(v_email);

  -- ONE VAGUE ANSWER for every eligibility failure: not on the roster,
  -- revoked from the roster, unknown domain, suspended customer. If
  -- these differed, this endpoint would enumerate both our customers
  -- and their staff lists.
  if v_sponsor.id is null or v_sponsor.status <> 'active' then
    return public._refuse(v_actor, 'request_sponsor_activation',
      'sponsor_activation_codes', null, 'not_eligible',
      'We could not find a benefit for that email address.',
      jsonb_build_object('domain', split_part(v_email, '@', 2)));
  end if;

  if exists (select 1 from public.sponsor_members
              where lower(work_email) = v_email and status = 'active') then
    return public._refuse(v_actor, 'request_sponsor_activation',
      'sponsor_activation_codes', v_sponsor.id, 'already_activated',
      'This work email has already been used to activate the benefit.');
  end if;

  if v_sponsor.seats_purchased is not null then
    select count(*) into v_used from public.sponsor_members
     where sponsor_id = v_sponsor.id and status = 'active';
    if v_used >= v_sponsor.seats_purchased then
      return public._refuse(v_actor, 'request_sponsor_activation',
        'sponsor_activation_codes', v_sponsor.id, 'no_seats_left',
        'All the seats your organisation purchased are in use.',
        jsonb_build_object('used', v_used, 'purchased', v_sponsor.seats_purchased));
    end if;
  end if;

  select count(*) into v_recent from public.sponsor_activation_codes
   where lower(work_email) = v_email and created_at > now() - interval '1 hour';
  if v_recent >= 3 then
    return public._refuse(v_actor, 'request_sponsor_activation',
      'sponsor_activation_codes', v_sponsor.id, 'too_many_requests',
      'Too many codes requested. Try again in an hour.');
  end if;

  v_code := lpad((floor(random() * 1000000))::int::text, 6, '0');

  insert into public.sponsor_activation_codes
    (work_email, code, sponsor_id, expires_at)
  values (v_email, v_code, v_sponsor.id, now() + interval '10 minutes');

  -- The code is NOT returned. Being on the roster proves a company said
  -- your name; it does not prove you are you. Returning the code here
  -- would mean a leaked spreadsheet is free Premium for whoever has it.
  return public._allow(v_actor, 'request_sponsor_activation',
    'sponsor_activation_codes', v_sponsor.id, 'code_sent',
    format('We have sent a code to %s.', v_email),
    jsonb_build_object('sponsor', v_sponsor.id));
end;
$$;

grant execute on function public.request_sponsor_activation(text) to authenticated;


-- ---------------------------------------------------------------------
-- 4. confirm_sponsor_activation -- the eligibility re-check.
--
-- 0059's version re-checked that the sponsor was still active and that
-- a seat was still free, on the principle that the check which matters
-- is the one at the moment of granting. Roster membership is now part
-- of that same question, so leaving it out would make the principle
-- half-true -- which is worse than not having it, because the comment
-- would still claim it.
-- ---------------------------------------------------------------------
create or replace function public.confirm_sponsor_activation(
  p_work_email text,
  p_code       text
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_email  text := lower(trim(p_work_email));
  v_row    record;
  v_uid    uuid := auth.uid();
  v_used   int;
  v_spons  public.sponsors;
  v_now    public.sponsors;
  v_given  text := trim(p_code);
  v_bypass boolean := false;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'code', 'not_signed_in',
      'message', 'Sign in first, then activate your employer benefit.');
  end if;

  select * into v_row from public.sponsor_activation_codes
   where lower(work_email) = v_email and consumed_at is null
   order by created_at desc limit 1;

  if v_row.id is null then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', null, 'no_pending_code', 'Request a new code.');
  end if;

  if v_row.expires_at < now() then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_row.sponsor_id, 'code_expired',
      'That code has expired. Request a new one.');
  end if;

  select * into v_spons from public.sponsors where id = v_row.sponsor_id;

  -- Count the attempt BEFORE comparing, so a wrong guess costs one
  -- regardless of what happens next. The bypass is not exempt.
  update public.sponsor_activation_codes
     set attempts = attempts + 1 where id = v_row.id;

  if v_row.attempts + 1 > 5 then
    update public.sponsor_activation_codes
       set consumed_at = now() where id = v_row.id;
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_row.sponsor_id, 'too_many_attempts',
      'Too many incorrect codes. Request a new one.');
  end if;

  -- THE DEMO DOOR (0059). Null for every real customer, so dead code
  -- for every real customer.
  v_bypass := v_spons.dev_bypass_code is not null
              and v_given = v_spons.dev_bypass_code;

  if v_row.code <> v_given and not v_bypass then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_row.sponsor_id, 'wrong_code',
      'That code is not right.');
  end if;

  -- RE-CHECK EVERYTHING THAT COULD HAVE CHANGED IN TEN MINUTES: the
  -- customer could have lapsed, the last seat could have gone, and HR
  -- could have taken this person off the list.
  if v_spons.status <> 'active' then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_spons.id, 'sponsor_inactive',
      'This benefit is no longer active.');
  end if;

  v_now := public.sponsor_for_work_email(v_email);
  if v_now.id is null or v_now.id <> v_spons.id then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_spons.id, 'not_eligible',
      'We could not find a benefit for that email address.');
  end if;

  if v_spons.seats_purchased is not null then
    select count(*) into v_used from public.sponsor_members
     where sponsor_id = v_spons.id and status = 'active';
    if v_used >= v_spons.seats_purchased then
      return public._refuse(v_uid::text, 'confirm_sponsor_activation',
        'sponsor_members', v_spons.id, 'no_seats_left',
        'All the seats your organisation purchased are in use.');
    end if;
  end if;

  update public.sponsor_activation_codes
     set consumed_at = now() where id = v_row.id;

  insert into public.sponsor_members (user_id, sponsor_id, work_email)
  values (v_uid, v_spons.id, v_email)
  on conflict (user_id, sponsor_id) do update
    set status = 'active', activated_at = now(), removed_at = null;

  perform public.grant_plan(v_uid, v_spons.plan_id, 'sponsor', v_spons.id,
                            null, v_uid::text);

  return public._allow(v_uid::text, 'confirm_sponsor_activation',
    'sponsor_members', v_spons.id,
    case when v_bypass then 'activated_dev_bypass' else 'activated' end,
    format('Welcome. Your benefit is provided by %s.', v_spons.name),
    jsonb_build_object('sponsor', v_spons.id, 'plan', v_spons.plan_id,
                       'bypass', v_bypass));
end;
$$;

grant execute on function
  public.confirm_sponsor_activation(text, text) to authenticated;


-- ---------------------------------------------------------------------
-- 5. What HR sees about their own list.
--
-- The dashboard counted ACTIVATED people. With a roster there is a
-- second, more useful denominator: how many we were told about. "14 of
-- 40 activated" is a sentence HR can act on; "14 activated" is not.
--
-- Added to sponsor_dashboard() rather than a new call, because it is
-- the same question and a second round trip for one number is a second
-- thing that can be out of step with the first.
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
  v_listed    int;
  v_suppress  boolean;
  v_denom     int;
begin
  if v_id is null then
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

  select count(*) into v_listed
    from public.sponsor_eligible_people
   where sponsor_id = v_id and status = 'eligible';

  select count(*) filter (where b.status <> 'cancelled'),
         count(*) filter (where b.status = 'attended'),
         count(*) filter (where b.status = 'upcoming'
                            and b.starts_utc > now())
    into v_booked, v_done, v_upcoming
    from public.booking_bookings b
    join public.sponsor_members m
      on m.user_id = b.user_id and m.sponsor_id = v_id and m.status = 'active';

  v_suppress := v_active < v_min;

  -- The roster is the better denominator when there is one: it is the
  -- number of people the company actually told us about. Seats are what
  -- they bought, which is not always the same thing.
  v_denom := case when v_listed > 0 then v_listed else v_s.seats_purchased end;

  return jsonb_build_object(
    'ok', true,
    'sponsor_id', v_s.id,
    'sponsor_name', v_s.name,
    'kind', v_s.kind,
    'renewal_at', v_s.renewal_at,
    'seats_purchased', v_s.seats_purchased,
    'eligible_listed', v_listed,
    'activated', v_active,
    'removed', v_removed,
    'activated_last_30d', v_last30,
    'seats_left', case when v_s.seats_purchased is null then null
                       else greatest(v_s.seats_purchased - v_active, 0) end,
    'activation_rate', case when coalesce(v_denom, 0) = 0 then null
                            else round(100.0 * v_active / v_denom) end,
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
-- 6. sponsor_roster() -- now the LIST, not just the members.
--
-- 0060's version returned activated people only, which answers "who is
-- using it" and not the question HR actually has: "who on the list I
-- sent you has not started yet". That second one is the whole reason
-- they open this screen -- it is the follow-up list.
--
-- full_name is added, and it is worth being clear about why that is not
-- a loosening of the privacy rule. HR SENT US THESE NAMES. The roster
-- is their own spreadsheet; returning it with one bit added
-- (activated / not yet) hands them their data back, not ours. The line
-- is unchanged and it is a different line: never anything about what a
-- person did. No bookings, no reading, no last-seen, still no user id.
--
-- Two sources, deliberately unioned rather than one being dropped:
--   (a) everyone on the roster, with their status;
--   (b) anyone who activated WITHOUT being on it -- which happens on
--       the domain path, and also when HR takes someone off the sheet
--       after they activated. Hiding (b) would mean the count and the
--       list disagreed, and the list would be the one that looked broken.
-- ---------------------------------------------------------------------
drop function if exists public.sponsor_roster();

create or replace function public.sponsor_roster()
returns table (
  work_email   text,
  full_name    text,
  status       text,          -- active | not_activated | removed
  activated_at timestamptz,
  removed_at   timestamptz
)
language sql stable security definer set search_path = ''
as $$
  select e.work_email,
         e.full_name,
         coalesce(m.status, 'not_activated'),
         m.activated_at,
         m.removed_at
    from public.sponsor_eligible_people e
    left join public.sponsor_members m
      on m.sponsor_id = e.sponsor_id
     and lower(m.work_email) = e.work_email
   where e.sponsor_id = public.my_sponsor_admin_id()
     and e.status = 'eligible'

  union all

  select m.work_email,
         null,
         m.status,
         m.activated_at,
         m.removed_at
    from public.sponsor_members m
   where m.sponsor_id = public.my_sponsor_admin_id()
     and not exists (select 1 from public.sponsor_eligible_people e2
                      where e2.sponsor_id = m.sponsor_id
                        and e2.work_email = lower(m.work_email)
                        and e2.status = 'eligible')

  -- 'active' < 'not_activated' < 'removed' alphabetically, which happens
  -- to be the order HR wants: what is working, then what to chase, then
  -- what is finished.
  order by 3, 1;
$$;

grant execute on function public.sponsor_roster() to authenticated;


-- =====================================================================
-- VERIFY
--
--   -- The roster wins, and a domain match stops working once a list
--   -- exists:
--   insert into public.sponsors (id, name, plan_id, status)
--     values ('zz_r', 'Roster Co', 'employer_standard', 'active');
--   insert into public.sponsor_domains values ('zz-roster.test', 'zz_r');
--
--   select (public.sponsor_for_work_email('anyone@zz-roster.test')).id;
--     -> zz_r        (no list yet, so the domain answers)
--
--   insert into public.sponsor_eligible_people (work_email, sponsor_id)
--     values ('priya@zz-roster.test', 'zz_r');
--
--   select (public.sponsor_for_work_email('anyone@zz-roster.test')).id;
--     -> null        (a list exists, and this person is not on it)
--   select (public.sponsor_for_work_email('priya@zz-roster.test')).id;
--     -> zz_r
--
--   delete from public.sponsors where id = 'zz_r';   -- cascades
--
-- LOADING A SHEET: register sponsor_eligible_people in Directus and use
-- its CSV import. Columns work_email, sponsor_id, full_name,
-- employee_ref. Lowercase the email column in the spreadsheet first --
-- the CHECK will reject "Priya@Acme.com" rather than silently store a
-- row that can never match.
-- =====================================================================
