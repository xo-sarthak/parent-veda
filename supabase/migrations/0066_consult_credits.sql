-- =====================================================================
-- 0066_consult_credits.sql -- credits stop being a number on a phone.
-- ---------------------------------------------------------------------
-- WHAT WAS WRONG. Since 0035, a consultation credit has lived in
-- SharedPreferences. BookingStore said "you have one", book_slot()
-- checked whether the SLOT had room and never asked whether the person
-- had a right to it. So the credit was honour-system: fine for every
-- real parent, and free consultations for anyone willing to edit a JSON
-- blob on their own device.
--
-- That was survivable while credits came from referrals. It stopped
-- being survivable when an employer started paying for them.
--
-- ---------------------------------------------------------------------
-- THE DESIGN DECISIONS, AND WHY EACH ONE
-- ---------------------------------------------------------------------
--
-- (a) A LEDGER, NOT A COUNTER. `credits_left int` is the obvious shape
--     and it is the one that cannot answer questions. Why do I have
--     two? Which one paid for that booking? What happens if a refund
--     and a cancellation land together? A counter answers none of it,
--     and every bug in it is silent arithmetic.
--
--     So ONE ROW IS ONE CREDIT. Granting three credits inserts three
--     rows. Nothing anywhere adds or subtracts, which means there is no
--     race to lose: spending is attaching a row to a booking, and a
--     unique index makes attaching it twice impossible.
--
--     > Where a number represents a right rather than a measurement,
--     > store the rights. Counters are for things that are genuinely
--     > quantities; entitlements are things you can be asked to justify
--     > one at a time.
--
-- (b) IDEMPOTENT BY CONSTRUCTION. Every grant carries a grant_key
--     (source + reference) and a sequence number, unique per user. Re-
--     syncing the same referral, re-running the same sponsor activation
--     or replaying a webhook lands on the same rows. This is the exact
--     failure 0035's client-side id-derivation existed to prevent, now
--     enforced by the database instead of by remembering.
--
-- (c) book_slot() ATTACHES A CREDIT, IT DOES NOT YET DEMAND ONE.
--     Payments are stubbed, so refusing an unpaid consult today would
--     break every existing booking. Instead the booking records HOW it
--     was paid for -- 'credit' or 'unpaid' -- so the server now knows
--     what it previously could not, and turning "unpaid is refused" on
--     is one condition rather than a rewrite. Shipping the enforcement
--     switch in the off position beats shipping nothing and calling the
--     hole known.
--
-- (d) CANCELLATION RETURNS THE CREDIT, WITHIN A WINDOW. Four hours by
--     default, in a config row because this is a policy and policies
--     change. Cancel in time and the credit comes back; cancel twenty
--     minutes before and it is spent -- the clinician's hour is gone
--     either way, and a no-show that costs nothing is a no-show that
--     happens.
--
-- (e) REVOKING A SOURCE VOIDS ONLY WHAT IS UNSPENT. An employee who
--     leaves loses the consultation they had not booked. The one they
--     already attended is not un-attended, and the one they have
--     BOOKED stays booked -- taking an appointment away from someone
--     because payroll changed is not a database operation, it is
--     something happening to a person.
--
-- OPEN, AND RECORDED IN STILL-OPEN 12: no money moves here. When
-- Razorpay lands, a purchase becomes grant_consult_credits(..., source
-- 'purchase', source_ref <payment id>), and this table is already the
-- right shape for it -- which is the reason to build it now rather than
-- twice.
--
-- PREREQ: 0029 (booking engine), 0050/0055 (_audit/_refuse/_allow).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. Policy, as a row.
-- ---------------------------------------------------------------------
create table if not exists public.booking_policy (
  id                  text primary key default 'default'
                        check (id = 'default'),
  -- Cancel at least this long before the start and the credit returns.
  credit_return_hours int not null default 4 check (credit_return_hours >= 0),
  -- Default life of a granted credit. Overridable per grant.
  default_validity_days int not null default 365,
  updated_at          timestamptz not null default now()
);

insert into public.booking_policy (id) values ('default')
on conflict (id) do nothing;

alter table public.booking_policy enable row level security;
revoke all on public.booking_policy from anon, authenticated;
grant select, update on public.booking_policy to directus_cms;
drop policy if exists "booking_policy cms" on public.booking_policy;
create policy "booking_policy cms" on public.booking_policy
  for all to directus_cms using (true) with check (true);


-- ---------------------------------------------------------------------
-- 2. The ledger. One row is one credit.
-- ---------------------------------------------------------------------
create table if not exists public.consult_credits (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,

  -- purchase | referral | sponsor | goodwill. Free text for the same
  -- reason sponsors.kind is: a new way of acquiring a credit must not
  -- need a migration.
  source      text not null,
  source_ref  text,
  -- source + ':' + source_ref. Stored rather than derived so the unique
  -- index below is plain and fast.
  grant_key   text not null,
  -- 1..n within one grant. Three credits from one referral are three
  -- rows sharing a key and differing here.
  seq         int  not null,

  -- '*any_consult' (see kAnyConsultOffering) or a specific offering id.
  -- A referral reward is "a free consultation", not a promise about who
  -- with; a bought package may be narrower.
  offering_scope text not null default '*any_consult',

  granted_at  timestamptz not null default now(),
  expires_at  timestamptz,

  -- Spent: attached to exactly one booking.
  booking_id  text references public.booking_bookings (id) on delete set null,
  spent_at    timestamptz,

  -- Voided: withdrawn before it was spent.
  voided_at   timestamptz,
  void_reason text
);

comment on table public.consult_credits is
  'One row is ONE consultation credit. Never a counter: nothing adds or subtracts, so there is no race to lose. Spending attaches a booking; the unique index makes double-spending impossible rather than unlikely.';

-- IDEMPOTENCE. Re-running an activation, re-syncing a referral or
-- replaying a webhook lands on the same rows.
create unique index if not exists consult_credits_grant_idx
  on public.consult_credits (user_id, grant_key, seq);

-- NO DOUBLE SPEND. One booking can consume at most one credit, and a
-- credit can be attached to at most one booking. This is the whole
-- concurrency story: two simultaneous bookings cannot both take the
-- same credit because the second insert simply fails.
create unique index if not exists consult_credits_booking_idx
  on public.consult_credits (booking_id) where booking_id is not null;

create index if not exists consult_credits_user_idx
  on public.consult_credits (user_id, spent_at, voided_at);

alter table public.consult_credits enable row level security;

-- OWN-ROW READ ONLY, and no write policy at all. A client that could
-- insert here could mint free consultations, which is the entire thing
-- this migration exists to stop. Granting is a server act.
grant select on public.consult_credits to authenticated;
drop policy if exists "consult_credits own read" on public.consult_credits;
create policy "consult_credits own read" on public.consult_credits
  for select to authenticated using (auth.uid() = user_id);

-- Never the CMS. A form that mints consultations is a form that will.


-- ---------------------------------------------------------------------
-- 3. Granting.
--
-- security definer and revoked from public: the app asks for credits it
-- has earned by doing something the server witnessed (activating a
-- benefit, a referral qualifying, paying), never by saying so.
-- ---------------------------------------------------------------------
create or replace function public.grant_consult_credits(
  p_user_id    uuid,
  p_count      int,
  p_source     text,
  p_source_ref text,
  p_actor      text default 'system',
  p_scope      text default '*any_consult',
  p_valid_days int  default null
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_key  text := p_source || ':' || coalesce(p_source_ref, '');
  v_days int;
  v_new  int := 0;
  i      int;
begin
  if p_user_id is null or coalesce(p_count, 0) < 1 then
    return public._refuse(p_actor, 'grant_consult_credits', 'consult_credits',
      p_source_ref, 'bad_request', 'A user and a positive count are required.');
  end if;

  -- A cap, because this is the money path and a loop bound by a
  -- parameter is a loop bound by whoever calls it.
  if p_count > 50 then
    return public._refuse(p_actor, 'grant_consult_credits', 'consult_credits',
      p_source_ref, 'too_many', 'That is more credits than any real grant.');
  end if;

  select coalesce(p_valid_days, default_validity_days) into v_days
    from public.booking_policy where id = 'default';
  v_days := coalesce(v_days, 365);

  for i in 1..p_count loop
    insert into public.consult_credits
      (user_id, source, source_ref, grant_key, seq, offering_scope, expires_at)
    values
      (p_user_id, p_source, p_source_ref, v_key, i, p_scope,
       now() + (v_days || ' days')::interval)
    on conflict (user_id, grant_key, seq) do nothing;
    if found then v_new := v_new + 1; end if;
  end loop;

  return public._allow(p_actor, 'grant_consult_credits', 'consult_credits',
    p_source_ref,
    case when v_new = 0 then 'already_granted' else 'granted' end,
    format('%s credit(s) granted.', v_new),
    jsonb_build_object('user', p_user_id, 'new', v_new, 'requested', p_count));
end;
$$;

revoke execute on function public.grant_consult_credits(
  uuid, int, text, text, text, text, int) from public;


-- ---------------------------------------------------------------------
-- 4. Withdrawing a source's UNSPENT credits.
-- ---------------------------------------------------------------------
create or replace function public.void_consult_credits(
  p_user_id    uuid,
  p_source     text,
  p_source_ref text,
  p_actor      text,
  p_reason     text default 'source revoked'
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare v_n int;
begin
  update public.consult_credits
     set voided_at = now(), void_reason = p_reason
   where user_id = p_user_id
     and source = p_source
     and coalesce(source_ref, '') = coalesce(p_source_ref, '')
     -- UNSPENT ONLY. A consultation already attended is not un-attended,
     -- and one already booked stays booked: taking an appointment away
     -- because payroll changed is not a database operation.
     and booking_id is null
     and voided_at is null;
  get diagnostics v_n = row_count;

  return public._allow(p_actor, 'void_consult_credits', 'consult_credits',
    p_source_ref, 'voided',
    format('%s unspent credit(s) withdrawn.', v_n),
    jsonb_build_object('user', p_user_id, 'voided', v_n));
end;
$$;

revoke execute on function
  public.void_consult_credits(uuid, text, text, text, text) from public;


-- ---------------------------------------------------------------------
-- 5. What the app may ask about itself.
--
-- Returns a summary, not the rows, because a screen needs a number and
-- a date and nothing else. The rows are readable under RLS if a future
-- screen wants a history; this is the cheap path.
-- ---------------------------------------------------------------------
-- ⚠️ FILTER DOES NOT ATTACH TO A WINDOW FUNCTION. The first version of
-- this used `count(*) over (partition by source) filter (where ...)`,
-- which Postgres refuses outright: FILTER is part of aggregate-call
-- syntax, and `count(*) OVER (...)` is a window call, not an aggregate
-- one. The two look identical and are parsed differently.
--
-- The fix is not a workaround -- it is the shape this wanted anyway.
-- "Usable" is one predicate used three times, so it is computed once in
-- a CTE and everything else is a plain aggregate over it. Repeating
-- `booking_id is null and voided_at is null and not expired` at each
-- call site would have been three chances to change two of them.
create or replace function public.my_consult_credits()
returns jsonb
language sql stable security definer set search_path = ''
as $$
  with mine as (
    select c.source,
           c.booking_id,
           c.expires_at,
           (c.booking_id is null
            and c.voided_at is null
            and (c.expires_at is null or c.expires_at > now())) as usable
      from public.consult_credits c
     where c.user_id = auth.uid()
  ),
  totals as (
    select count(*) filter (where usable)                      as available,
           count(*) filter (where booking_id is not null)      as spent,
           min(expires_at) filter (where usable
                                     and expires_at is not null) as expiring_next
      from mine
  ),
  by_src as (
    -- jsonb_object_agg over no rows returns NULL, not '{}', so a user
    -- with no credits would otherwise get a null the client has to
    -- special-case. Coalesced here instead.
    select coalesce(jsonb_object_agg(source, n), '{}'::jsonb) as j
      from (select source, count(*) as n
              from mine where usable group by source) s
  )
  select jsonb_build_object(
    'available',     coalesce((select available from totals), 0),
    'spent',         coalesce((select spent from totals), 0),
    'expiring_next', (select expiring_next from totals),
    'by_source',     (select j from by_src)
  );
$$;

grant execute on function public.my_consult_credits() to authenticated;


-- ---------------------------------------------------------------------
-- 6. Spending, inside book_slot().
--
-- Replaced whole rather than diffed, so the file reads as the current
-- truth. The ONLY changes are the paid_by column and the credit claim
-- at the end -- everything else is 0029 verbatim, including every
-- raise, because those ARE the failure path the client rolls back on.
-- ---------------------------------------------------------------------
alter table public.booking_bookings
  add column if not exists paid_by text;

comment on column public.booking_bookings.paid_by is
  'credit | unpaid. How this booking was covered. NOT an enforcement point yet -- payments are stubbed, so an unpaid consult is still allowed and merely recorded. Turning that off is one condition in book_slot(); see STILL-OPEN 12.';

create or replace function public.book_slot(
  p_booking_id  text,
  p_slot_id     text,
  p_offering_id text,
  p_expert_id   text,
  p_starts_utc  timestamptz,
  p_duration_min int,
  p_capacity    int,
  p_stage       text,
  p_title       text,
  p_join_url    text default null
) returns public.booking_bookings
language plpgsql
security definer set search_path = ''
as $$
declare
  v_slot    public.booking_slots;
  v_booking public.booking_bookings;
  v_uid     uuid := auth.uid();
  v_credit  uuid;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  insert into public.booking_slots
    (id, offering_id, expert_id, starts_utc, duration_min, capacity, join_url)
  values
    (p_slot_id, p_offering_id, p_expert_id, p_starts_utc,
     p_duration_min, p_capacity, p_join_url)
  on conflict (id) do nothing;

  select * into v_slot from public.booking_slots
    where id = p_slot_id for update;

  if v_slot.booked >= v_slot.capacity then
    raise exception 'slot full';
  end if;

  if exists (
    select 1 from public.booking_bookings
    where slot_id = p_slot_id and user_id = v_uid and status <> 'cancelled'
  ) then
    raise exception 'already booked';
  end if;

  update public.booking_slots set booked = booked + 1 where id = p_slot_id;

  insert into public.booking_bookings
    (id, user_id, offering_id, slot_id, stage, title, starts_utc,
     duration_min, status, paid_by)
  values
    (p_booking_id, v_uid, p_offering_id, p_slot_id, p_stage, p_title,
     p_starts_utc, p_duration_min, 'upcoming', 'unpaid')
  returning * into v_booking;

  -- CLAIM A CREDIT, oldest-expiring first so nothing is wasted. FOR
  -- UPDATE SKIP LOCKED because two simultaneous bookings by the same
  -- person must not queue behind each other for the same row -- the
  -- second should take the next credit, not wait for the first.
  --
  -- ⚠️ capacity = 1 IS HOW THE SERVER KNOWS THIS IS A CONSULTATION.
  -- The offering catalogue lives in Dart (booking_catalog.dart), so the
  -- database cannot ask "is off_pg_47 a masterclass or a one-to-one?".
  -- The obvious fixes are both worse: a `kind` parameter is supplied by
  -- the client, and a mirrored offerings table is a second copy of the
  -- catalogue to keep in step.
  --
  -- Capacity is neither -- it is a number the server already holds and
  -- already trusts, because it is what stops a slot being oversold. A
  -- one-to-one has exactly one seat; a class, cohort or masterclass has
  -- more. So the seat count doubles as the answer, with no new surface
  -- to drift.
  --
  -- The limit, stated: a scoped credit for a specific multi-seat
  -- offering cannot be spent yet. Nothing grants one today. When
  -- something does -- a bought class pack -- this condition needs the
  -- exact-scope case exempting.
  select c.id into v_credit
    from public.consult_credits c
   where c.user_id = v_uid
     and c.booking_id is null
     and c.voided_at is null
     and (c.expires_at is null or c.expires_at > now())
     and ((c.offering_scope = '*any_consult' and v_slot.capacity = 1)
          or c.offering_scope = p_offering_id)
   order by c.expires_at nulls last, c.granted_at
   limit 1
   for update skip locked;

  if v_credit is not null then
    update public.consult_credits
       set booking_id = v_booking.id, spent_at = now()
     where id = v_credit;
    update public.booking_bookings set paid_by = 'credit'
     where id = v_booking.id
    returning * into v_booking;
  end if;

  return v_booking;
end;
$$;

grant execute on function public.book_slot(
  text, text, text, text, timestamptz, int, int, text, text, text
) to authenticated;


-- ---------------------------------------------------------------------
-- 7. Cancelling gives it back -- if there was time to fill the slot.
-- ---------------------------------------------------------------------
create or replace function public.cancel_booking(p_booking_id text)
returns void
language plpgsql
security definer set search_path = ''
as $$
declare
  v_booking public.booking_bookings;
  v_uid     uuid := auth.uid();
  v_hours   int;
begin
  select * into v_booking from public.booking_bookings
    where id = p_booking_id and user_id = v_uid for update;

  if not found then
    raise exception 'no such booking';
  end if;

  if v_booking.status = 'cancelled' then
    return; -- idempotent; never refund a seat, or a credit, twice
  end if;

  update public.booking_bookings set status = 'cancelled'
    where id = p_booking_id;
  update public.booking_slots set booked = greatest(booked - 1, 0)
    where id = v_booking.slot_id;

  select credit_return_hours into v_hours
    from public.booking_policy where id = 'default';
  v_hours := coalesce(v_hours, 4);

  -- Cancel in time and the credit returns to the pool. Cancel twenty
  -- minutes before and it is spent: the clinician's hour is gone either
  -- way, and a no-show that costs nothing is a no-show that happens.
  if v_booking.starts_utc > now() + (v_hours || ' hours')::interval then
    update public.consult_credits
       set booking_id = null, spent_at = null
     where booking_id = p_booking_id;
  end if;
end;
$$;

grant execute on function public.cancel_booking(text) to authenticated;


-- =====================================================================
-- VERIFY
--
--   -- A client cannot mint one:
--   insert into public.consult_credits (user_id, source, grant_key, seq)
--   values (auth.uid(), 'purchase', 'x:1', 1);
--     -> new row violates row-level security policy
--
--   -- Granting twice grants once:
--   select public.grant_consult_credits('<uid>'::uuid, 1, 'sponsor', 'acme');
--   select public.grant_consult_credits('<uid>'::uuid, 1, 'sponsor', 'acme');
--     -> second returns code 'already_granted', new: 0
--
--   -- The summary the app reads:
--   select public.my_consult_credits();
--
--   -- Booking spends one and says so:
--   select paid_by from public.booking_bookings order by created_at desc limit 1;
--     -> credit
--
--   -- Cancelling in time returns it; cancelling late does not.
--
--   -- Leaving a company loses the unbooked one, keeps the booked one:
--   select public.void_consult_credits('<uid>'::uuid, 'sponsor', 'acme', 'test');
-- =====================================================================
