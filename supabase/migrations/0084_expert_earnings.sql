-- =====================================================================
-- 0084_expert_earnings.sql -- the doctor's money, as a LEDGER
-- ---------------------------------------------------------------------
-- Until now a doctor's earnings were computed ON THE PHONE: every consult
-- booking x the catalogue price x a Dart constant (kDoctorSharePct = 0.80).
-- That is a report over a constant, not a record of anything. A price
-- change rewrote history, a negotiated 85% had nowhere to live, and
-- masterclasses, cohorts, courses and videos did not exist as money at all.
--
-- THE PRINCIPLE. A statement is a record of WHAT HAPPENED, not a
-- recomputation of what the rules say now. So every rupee a doctor is
-- shown comes from a row written when the event occurred, with the rate
-- that applied THEN frozen into it. Three tables, three lifetimes:
--
--   expert_share_rules   the deal.       Changes when a doctor negotiates.
--   expert_earnings      the ledger.     Append-only. Amounts never change.
--   expert_payouts       the settlement. One row per bank transfer.
--
-- plus two small capability records in the 0072 spirit (one identity,
-- optional capabilities hanging off it):
--
--   expert_videos            a film made with this doctor: a link and a %
--   expert_payout_accounts   where to send the money (private, own-row)
--   expert_invites           an email that may sign in as this expert
--
-- WHY THE SHARE IS NOT care_commission_rules. That table (0038) caps
-- rate_bps at 5000 because a REFERRAL commission above 50% is a data
-- entry error. A DELIVERY share is the opposite: the doctor did the work,
-- the platform keeps the minority. Consultations pay 80%. Two questions,
-- two tables -- STILL-OPEN 13.0 reached the same conclusion.
--
-- WHY PAYOUTS ARE MANUAL FIRST. No inbound money exists yet (booking
-- payment is stubbed), the rates are placeholders, and per-doctor KYC is
-- its own product. record_expert_payout() is what an admin calls after
-- making the NEFT; `method` already admits 'razorpay_route', so Route
-- later is a new WRITER (a webhook inserting the same row), not a
-- migration. Design the record for the eventual process; run the process
-- by hand until the automation is justified.
--
-- MONEY IS DECIDED SERVER-SIDE. Nothing here is computed by a client.
-- The app reads my_earnings_summary() and renders it.
--
-- PREREQ: 0029 (bookings), 0054 (programmes), 0072/0073 (expert_profiles,
-- my_expert_ids), 0045 (directus_cms), 0074 (fee_inr).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The price a parent paid, recorded ON the booking.
--
-- book_slot() never knew the price: offerings are a client-side catalogue.
-- Without it the ledger would have to look the fee up at accrual time,
-- which is the very "recompute later" this migration exists to stop. The
-- column is nullable so history is untouched; the trigger below falls
-- back to expert_profiles.fee_inr / programmes.price_paise for rows that
-- predate this.
--
-- The signature change: an 11-argument book_slot with the new argument
-- DEFAULTED, so the 10-argument call still resolves. The old signature is
-- dropped EXPLICITLY first -- `create or replace` with a different arity
-- adds an overload and every caller breaks as "ambiguous" (BACKEND-
-- PATTERNS 12f, hit twice already).
-- ---------------------------------------------------------------------
alter table public.booking_bookings
  add column if not exists price_paise int check (price_paise is null or price_paise >= 0);

comment on column public.booking_bookings.price_paise is
  'What the parent paid for this seat, in paise, recorded at booking time. The ledger (expert_earnings) reads this, never the catalogue. Null on rows older than 0084.';

drop function if exists public.book_slot(
  text, text, text, text, timestamptz, int, int, text, text, text);

create or replace function public.book_slot(
  p_booking_id   text,
  p_slot_id      text,
  p_offering_id  text,
  p_expert_id    text,
  p_starts_utc   timestamptz,
  p_duration_min int,
  p_capacity     int,
  p_stage        text,
  p_title        text,
  p_join_url     text default null,
  p_price_paise  int  default null
) returns public.booking_bookings
language plpgsql
security definer set search_path = ''
as $$
declare
  v_slot    public.booking_slots;
  v_booking public.booking_bookings;
  v_uid     uuid := auth.uid();
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
     duration_min, status, price_paise)
  values
    (p_booking_id, v_uid, p_offering_id, p_slot_id, p_stage, p_title,
     p_starts_utc, p_duration_min, 'upcoming', p_price_paise)
  returning * into v_booking;

  return v_booking;
end;
$$;

grant execute on function public.book_slot(
  text, text, text, text, timestamptz, int, int, text, text, text, int)
  to authenticated;


-- ---------------------------------------------------------------------
-- 2. expert_share_rules -- the deal
--
-- expert_id NULL is the platform default; a row with an expert_id is that
-- doctor's negotiated deal and wins. min_monthly is the volume tier: the
-- rule applies once the doctor has that many payable rows of that source
-- in the calendar month (85% above 20 consultations). effective_from/to
-- let a rate change on a date without editing history.
--
-- share_bps runs to 10000 on purpose -- see the header.
-- ---------------------------------------------------------------------
create table if not exists public.expert_share_rules (
  id             bigserial   primary key,
  source         text        not null
    check (source in ('consultation','masterclass','cohort','course','video','referral','other')),
  expert_id      text,
  min_monthly    int         not null default 0 check (min_monthly >= 0),
  share_bps      int         not null check (share_bps between 0 and 10000),
  effective_from date        not null default current_date,
  effective_to   date,
  note           text,
  created_at     timestamptz not null default now()
);

create unique index if not exists expert_share_rules_key
  on public.expert_share_rules (source, coalesce(expert_id, ''), min_monthly, effective_from);

grant select on public.expert_share_rules to authenticated;
grant select, insert, update, delete on public.expert_share_rules to directus_cms;
alter table public.expert_share_rules enable row level security;

drop policy if exists "share_rules defaults read" on public.expert_share_rules;
create policy "share_rules defaults read" on public.expert_share_rules
  for select to authenticated using (expert_id is null);

drop policy if exists "share_rules own read" on public.expert_share_rules;
create policy "share_rules own read" on public.expert_share_rules
  for select to authenticated
  using (expert_id in (select public.my_expert_ids()));

drop policy if exists "share_rules cms" on public.expert_share_rules;
create policy "share_rules cms" on public.expert_share_rules
  for all to directus_cms using (true) with check (true);

-- PLACEHOLDER SEED -- decided 2026-09-18. The Commercial Terms workbook is
-- not to hand; these are the numbers STILL-OPEN 13.0 remembers from it
-- plus two assumptions, so the build works end to end. Every row says so
-- in its note. Replace the numbers when the workbook arrives; do NOT edit
-- these rows in place once a real earning has been written against them --
-- add a new row with a later effective_from.
insert into public.expert_share_rules (source, min_monthly, share_bps, note) values
  ('consultation',  0, 8000, 'PLACEHOLDER - awaiting Commercial Terms workbook (13.0 remembers 80%)'),
  ('consultation', 20, 8500, 'PLACEHOLDER - awaiting Commercial Terms workbook (13.0 remembers 85% above 20/month)'),
  ('masterclass',   0, 7000, 'PLACEHOLDER - assumed equal to a course via our channels'),
  ('cohort',        0, 7000, 'PLACEHOLDER - assumed equal to a course via our channels'),
  ('course',        0, 7000, 'PLACEHOLDER - awaiting Commercial Terms workbook (13.0 remembers 70/30)'),
  ('video',         0, 5000, 'PLACEHOLDER - pure assumption, no channel exists yet'),
  ('other',         0,    0, 'PLACEHOLDER - manual rows carry their own rate')
on conflict do nothing;

-- Which rate applies to THIS expert, THIS source, on THIS date, at THIS
-- monthly volume. Expert-specific beats default; the highest tier the
-- volume reaches wins; the rule must be in force on the date.
create or replace function public.resolve_share_bps(
  p_expert_id text, p_source text, p_at date, p_monthly int
) returns int
language sql stable security definer set search_path = ''
as $$
  select r.share_bps
    from public.expert_share_rules r
   where r.source = p_source
     and (r.expert_id = p_expert_id or r.expert_id is null)
     and r.min_monthly <= coalesce(p_monthly, 0)
     and r.effective_from <= p_at
     and (r.effective_to is null or r.effective_to >= p_at)
   order by (r.expert_id is not null) desc, r.min_monthly desc, r.effective_from desc
   limit 1;
$$;


-- ---------------------------------------------------------------------
-- 3. expert_payouts -- the settlement. Created before the ledger because
-- the ledger points at it.
-- ---------------------------------------------------------------------
create table if not exists public.expert_payouts (
  id           text        primary key default ('pay_' || replace(gen_random_uuid()::text, '-', '')),
  expert_id    text        not null,
  period_from  date        not null,
  period_to    date        not null,
  amount_paise int         not null check (amount_paise >= 0),
  status       text        not null default 'paid'
    check (status in ('scheduled','processing','paid','failed')),
  method       text        not null default 'manual_neft'
    check (method in ('manual_neft','razorpay_route')),
  reference    text,                    -- UTR, or a Route transfer id
  bank_last4   text,
  paid_at      timestamptz,
  note         text,
  created_at   timestamptz not null default now()
);

create index if not exists expert_payouts_expert_idx
  on public.expert_payouts (expert_id, paid_at desc);

grant select on public.expert_payouts to authenticated;
grant select, insert, update on public.expert_payouts to directus_cms;
alter table public.expert_payouts enable row level security;

drop policy if exists "payouts own read" on public.expert_payouts;
create policy "payouts own read" on public.expert_payouts
  for select to authenticated
  using (expert_id in (select public.my_expert_ids()));

drop policy if exists "payouts cms" on public.expert_payouts;
create policy "payouts cms" on public.expert_payouts
  for all to directus_cms using (true) with check (true);


-- ---------------------------------------------------------------------
-- 4. expert_earnings -- the ledger
--
-- One row per money event. AMOUNTS NEVER CHANGE. Status moves along
--   accrued  -> payable -> paid
-- and a reversal is a NEW row (negative, reversal_of set) rather than an
-- edit -- so a statement from last month still adds up next month.
--
--   accrued   the booking exists; the session has not happened yet
--   payable   the doctor's time was spent (attended, or the parent
--             no-showed -- consult_policy.dart: the doctor is paid)
--   paid      inside a payout row
--   reversed  a cancellation before payment; excluded from every sum
--
-- Title is the human line ("Consultation", "Masterclass: Sleep basics");
-- the counterparty name is joined at read time from the booking, so a
-- name change does not strand the ledger and no parent name is copied
-- into a second table.
-- ---------------------------------------------------------------------
create table if not exists public.expert_earnings (
  id             text        primary key default ('ern_' || replace(gen_random_uuid()::text, '-', '')),
  expert_id      text        not null,
  source         text        not null
    check (source in ('consultation','masterclass','cohort','course','video','referral','other')),
  ref_kind       text        not null default 'manual'
    check (ref_kind in ('booking','order','programme','video','manual')),
  ref_id         text,
  title          text        not null default '',
  occurred_at    timestamptz not null,
  gross_paise    int         not null,
  share_bps      int         not null check (share_bps between 0 and 10000),
  expert_paise   int         not null,
  platform_paise int         not null,
  status         text        not null default 'accrued'
    check (status in ('accrued','payable','paid','reversed')),
  payout_id      text        references public.expert_payouts (id),
  reversal_of    text        references public.expert_earnings (id),
  note           text,
  created_at     timestamptz not null default now()
);

create index if not exists expert_earnings_expert_idx
  on public.expert_earnings (expert_id, occurred_at desc);
create index if not exists expert_earnings_ref_idx
  on public.expert_earnings (ref_kind, ref_id);

grant select on public.expert_earnings to authenticated;
grant select, insert, update on public.expert_earnings to directus_cms;
alter table public.expert_earnings enable row level security;

drop policy if exists "earnings own read" on public.expert_earnings;
create policy "earnings own read" on public.expert_earnings
  for select to authenticated
  using (expert_id in (select public.my_expert_ids()));

drop policy if exists "earnings cms" on public.expert_earnings;
create policy "earnings cms" on public.expert_earnings
  for all to directus_cms using (true) with check (true);

-- The one place the split is computed. Everything that writes a row goes
-- through here so rounding is identical everywhere: the doctor's share is
-- rounded, the platform takes the remainder, and the two always add up to
-- the gross -- a statement whose lines do not sum is worse than no
-- statement.
create or replace function public.write_expert_earning(
  p_expert_id   text,
  p_source      text,
  p_ref_kind    text,
  p_ref_id      text,
  p_title       text,
  p_occurred_at timestamptz,
  p_gross_paise int,
  p_share_bps   int,
  p_status      text,
  p_note        text default null,
  p_reversal_of text default null
) returns public.expert_earnings
language plpgsql
security definer set search_path = ''
as $$
declare
  v_expert int := round(p_gross_paise * p_share_bps / 10000.0);
  v_row    public.expert_earnings;
begin
  insert into public.expert_earnings
    (expert_id, source, ref_kind, ref_id, title, occurred_at,
     gross_paise, share_bps, expert_paise, platform_paise,
     status, note, reversal_of)
  values
    (p_expert_id, p_source, p_ref_kind, p_ref_id, p_title, p_occurred_at,
     p_gross_paise, p_share_bps, v_expert, p_gross_paise - v_expert,
     p_status, p_note, p_reversal_of)
  returning * into v_row;
  return v_row;
end;
$$;

-- Internal. Not granted to anyone but the definer functions that call it.
revoke all on function public.write_expert_earning(
  text, text, text, text, text, timestamptz, int, int, text, text, text) from public;


-- ---------------------------------------------------------------------
-- 5. The booking writer -- a trigger, so the ledger cannot be forgotten
--
-- INSERT (upcoming)         -> an `accrued` row
-- status -> attended/missed -> accrued becomes payable
-- status -> cancelled       -> reversal (see write_booking_reversal)
--
-- Source: a slot of capacity 1 is a consultation (the whole booking engine
-- rests on that guard). Otherwise the offering is looked up in programmes
-- for its kind; unknown -> masterclass. Gross: the price on the booking,
-- else the expert's fee / the programme's price -- the fallback for
-- pre-0084 rows, and for the compiled catalogue the server cannot see.
-- ---------------------------------------------------------------------
create or replace function public.expert_earning_from_booking()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
declare
  v_expert   text;
  v_capacity int;
  v_source   text;
  v_gross    int;
  v_monthly  int;
  v_bps      int;
  v_existing public.expert_earnings;
  v_kind     text;
begin
  select s.expert_id, s.capacity into v_expert, v_capacity
    from public.booking_slots s where s.id = new.slot_id;
  if v_expert is null then return new; end if;

  if tg_op = 'INSERT' then
    if new.status <> 'upcoming' then return new; end if;

    if v_capacity = 1 then
      v_source := 'consultation';
      select coalesce(new.price_paise, ep.fee_inr * 100, 0) into v_gross
        from public.expert_profiles ep where ep.expert_id = v_expert;
      if v_gross is null then v_gross := coalesce(new.price_paise, 0); end if;
    else
      select p.kind, coalesce(new.price_paise, p.price_paise, 0)
        into v_kind, v_gross
        from public.programmes p where p.id = new.offering_id;
      v_source := case when v_kind = 'cohort' then 'cohort' else 'masterclass' end;
      if v_gross is null then v_gross := coalesce(new.price_paise, 0); end if;
    end if;

    -- Volume tier: how many of this source this month are already earned.
    select count(*) into v_monthly
      from public.expert_earnings e
     where e.expert_id = v_expert
       and e.source = v_source
       and e.status in ('payable','paid')
       and date_trunc('month', e.occurred_at) = date_trunc('month', new.starts_utc);

    v_bps := coalesce(public.resolve_share_bps(
      v_expert, v_source, (new.starts_utc at time zone 'Asia/Kolkata')::date, v_monthly), 0);

    perform public.write_expert_earning(
      v_expert, v_source, 'booking', new.id,
      case when v_source = 'consultation' then 'Consultation' else new.title end,
      new.starts_utc, v_gross, v_bps, 'accrued');
    return new;
  end if;

  -- UPDATE
  if new.status = old.status then return new; end if;

  select * into v_existing from public.expert_earnings e
   where e.ref_kind = 'booking' and e.ref_id = new.id and e.reversal_of is null
   order by e.created_at desc limit 1;
  if v_existing.id is null then return new; end if;

  if new.status in ('attended','missed') and v_existing.status = 'accrued' then
    update public.expert_earnings set status = 'payable' where id = v_existing.id;
  elsif new.status = 'cancelled' then
    perform public.write_booking_reversal(v_existing);
  end if;
  return new;
end;
$$;

-- A cancellation. If the original is not yet paid it is marked reversed and
-- a mirror row records that (audit only, excluded from sums). If it WAS
-- paid, the money has left -- so a negative PAYABLE row nets it off the
-- next payout instead. Either way the original's amounts are untouched.
create or replace function public.write_booking_reversal(p_orig public.expert_earnings)
returns void
language plpgsql
security definer set search_path = ''
as $$
begin
  if p_orig.status = 'reversed' then return; end if;
  if p_orig.status = 'paid' then
    perform public.write_expert_earning(
      p_orig.expert_id, p_orig.source, p_orig.ref_kind, p_orig.ref_id,
      p_orig.title || ' (cancelled after payout)', now(),
      -p_orig.gross_paise, p_orig.share_bps, 'payable',
      'Deducted from the next payout', p_orig.id);
  else
    update public.expert_earnings set status = 'reversed' where id = p_orig.id;
    perform public.write_expert_earning(
      p_orig.expert_id, p_orig.source, p_orig.ref_kind, p_orig.ref_id,
      p_orig.title || ' (cancelled)', now(),
      -p_orig.gross_paise, p_orig.share_bps, 'reversed',
      'Cancelled before payout', p_orig.id);
  end if;
end;
$$;

drop trigger if exists booking_bookings_earnings_trg on public.booking_bookings;
create trigger booking_bookings_earnings_trg
  after insert or update of status on public.booking_bookings
  for each row execute function public.expert_earning_from_booking();


-- ---------------------------------------------------------------------
-- 6. expert_videos -- a film made with this doctor
--
-- The user's rule (2026-09-18): no channel exists yet, so the flow needs
-- ONLY a link and a percentage. Revenue arrives monthly, typed in by an
-- admin from the channel's own reporting -- there is no ad-revenue API
-- we should pay out against -- through accrue_video_earning(), which
-- freezes the video's share into the ledger row at that moment.
-- ---------------------------------------------------------------------
create table if not exists public.expert_videos (
  id         text        primary key default ('vid_' || replace(gen_random_uuid()::text, '-', '')),
  expert_id  text        not null,
  url        text        not null,
  title      text        not null default '',
  share_bps  int         not null check (share_bps between 0 and 10000),
  added_at   timestamptz not null default now(),
  retired_at timestamptz
);

grant select on public.expert_videos to authenticated;
grant select, insert, update, delete on public.expert_videos to directus_cms;
alter table public.expert_videos enable row level security;

drop policy if exists "videos own read" on public.expert_videos;
create policy "videos own read" on public.expert_videos
  for select to authenticated
  using (expert_id in (select public.my_expert_ids()));

drop policy if exists "videos cms" on public.expert_videos;
create policy "videos cms" on public.expert_videos
  for all to directus_cms using (true) with check (true);

create or replace function public.accrue_video_earning(
  p_video_id text, p_period date, p_gross_paise int, p_note text default null
) returns public.expert_earnings
language plpgsql
security definer set search_path = ''
as $$
declare
  v public.expert_videos;
begin
  select * into v from public.expert_videos where id = p_video_id;
  if v.id is null then raise exception 'unknown video %', p_video_id; end if;
  if p_gross_paise < 0 then raise exception 'gross must be >= 0'; end if;
  return public.write_expert_earning(
    v.expert_id, 'video', 'video', v.id,
    'Video: ' || coalesce(nullif(v.title, ''), v.url),
    (date_trunc('month', p_period) + interval '1 month' - interval '1 day')::timestamptz,
    p_gross_paise, v.share_bps, 'payable',
    coalesce(p_note, 'Revenue for ' || to_char(p_period, 'Mon YYYY')));
end;
$$;

revoke all on function public.accrue_video_earning(text, date, int, text) from public;
grant execute on function public.accrue_video_earning(text, date, int, text)
  to service_role, directus_cms;


-- ---------------------------------------------------------------------
-- 7. Admin writers: a manual row, and a payout
-- ---------------------------------------------------------------------
create or replace function public.add_manual_expert_earning(
  p_expert_id   text,
  p_source      text,
  p_title       text,
  p_occurred_at timestamptz,
  p_gross_paise int,
  p_share_bps   int,
  p_note        text
) returns public.expert_earnings
language plpgsql
security definer set search_path = ''
as $$
begin
  if p_note is null or length(trim(p_note)) = 0 then
    raise exception 'a manual earning must carry a note the doctor can read';
  end if;
  return public.write_expert_earning(
    p_expert_id, p_source, 'manual', null, p_title, p_occurred_at,
    p_gross_paise, p_share_bps, 'payable', p_note);
end;
$$;

revoke all on function public.add_manual_expert_earning(
  text, text, text, timestamptz, int, int, text) from public;
grant execute on function public.add_manual_expert_earning(
  text, text, text, timestamptz, int, int, text) to service_role, directus_cms;

-- Called AFTER the transfer is made. Gathers every payable row up to the
-- period end, creates the payout with their sum, marks them paid. The
-- amount is derived, never typed: an admin who types a different number
-- from what was transferred has made an error the app should not be able
-- to express. Returns the payout; raises if there is nothing to pay.
create or replace function public.record_expert_payout(
  p_expert_id  text,
  p_period_to  date,
  p_reference  text,
  p_method     text default 'manual_neft',
  p_bank_last4 text default null,
  p_note       text default null
) returns public.expert_payouts
language plpgsql
security definer set search_path = ''
as $$
declare
  v_sum   int;
  v_from  date;
  v_pay   public.expert_payouts;
begin
  select coalesce(sum(expert_paise), 0), min(occurred_at)::date
    into v_sum, v_from
    from public.expert_earnings
   where expert_id = p_expert_id
     and status = 'payable'
     and occurred_at::date <= p_period_to;

  if v_sum <= 0 then
    raise exception 'nothing payable for % up to %', p_expert_id, p_period_to;
  end if;

  insert into public.expert_payouts
    (expert_id, period_from, period_to, amount_paise, status, method,
     reference, bank_last4, paid_at, note)
  values
    (p_expert_id, v_from, p_period_to, v_sum, 'paid', p_method,
     p_reference, p_bank_last4, now(), p_note)
  returning * into v_pay;

  update public.expert_earnings
     set status = 'paid', payout_id = v_pay.id
   where expert_id = p_expert_id
     and status = 'payable'
     and occurred_at::date <= p_period_to;

  return v_pay;
end;
$$;

revoke all on function public.record_expert_payout(
  text, date, text, text, text, text) from public;
grant execute on function public.record_expert_payout(
  text, date, text, text, text, text) to service_role, directus_cms;

-- The payout calendar is a POLICY, so it lives here and the app reads it:
-- payable earnings are settled on the 7th of the following month.
create or replace function public.next_payout_date()
returns date
language sql stable
as $$
  select (date_trunc('month', current_date) + interval '1 month' + interval '6 days')::date;
$$;
grant execute on function public.next_payout_date() to authenticated;


-- ---------------------------------------------------------------------
-- 8. expert_payout_accounts -- where the money goes. PRIVATE.
--
-- A separate table for the same reason care_partner_verification is:
-- expert_profiles is public-read, and a bank account is not identity.
-- The doctor writes it; the status is ours. A client insert or update
-- can only ever produce 'pending' (the with-check), so re-editing a
-- verified account puts it back in the queue rather than silently
-- changing where money is sent.
-- ---------------------------------------------------------------------
create table if not exists public.expert_payout_accounts (
  expert_id      text        primary key,
  account_name   text        not null,
  account_number text        not null,
  ifsc           text        not null,
  pan            text,
  upi_id         text,
  status         text        not null default 'pending'
    check (status in ('pending','verified','rejected')),
  reason         text,
  submitted_at   timestamptz not null default now(),
  reviewed_at    timestamptz
);

grant select, insert, update on public.expert_payout_accounts to authenticated;
grant select, update on public.expert_payout_accounts to directus_cms;
alter table public.expert_payout_accounts enable row level security;

drop policy if exists "payout_accounts own read" on public.expert_payout_accounts;
create policy "payout_accounts own read" on public.expert_payout_accounts
  for select to authenticated
  using (expert_id in (select public.my_expert_ids()));

drop policy if exists "payout_accounts own insert" on public.expert_payout_accounts;
create policy "payout_accounts own insert" on public.expert_payout_accounts
  for insert to authenticated
  with check (expert_id in (select public.my_expert_ids()) and status = 'pending');

drop policy if exists "payout_accounts own update" on public.expert_payout_accounts;
create policy "payout_accounts own update" on public.expert_payout_accounts
  for update to authenticated
  using (expert_id in (select public.my_expert_ids()))
  with check (expert_id in (select public.my_expert_ids()) and status = 'pending');

drop policy if exists "payout_accounts cms" on public.expert_payout_accounts;
create policy "payout_accounts cms" on public.expert_payout_accounts
  for all to directus_cms using (true) with check (true);


-- ---------------------------------------------------------------------
-- 9. expert_invites -- an email that may sign in as this expert
--
-- Replaces the SQL step in main_doctor.dart's header. An admin writes
-- (email, expert_id) in the panel; the doctor signs in by email code; the
-- app calls claim_expert_invite(), which links expert_accounts for the
-- signed-in user IF their email matches an unclaimed invite. Idempotent,
-- so the app can call it on every sign-in.
--
-- Why a claim function rather than a trigger on auth.users: the doctor may
-- already have an auth user (they use the parent app with the same email),
-- in which case no insert ever fires. One mechanism that works in both
-- cases beats two that each cover half.
-- ---------------------------------------------------------------------
create table if not exists public.expert_invites (
  email           text        primary key,
  expert_id       text        not null,
  invited_at      timestamptz not null default now(),
  claimed_at      timestamptz,
  claimed_user_id uuid,
  note            text
);

grant select, insert, update, delete on public.expert_invites to directus_cms;
alter table public.expert_invites enable row level security;

drop policy if exists "invites cms" on public.expert_invites;
create policy "invites cms" on public.expert_invites
  for all to directus_cms using (true) with check (true);

create or replace function public.claim_expert_invite()
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_email text;
  v_inv   public.expert_invites;
begin
  if v_uid is null then return null; end if;
  select lower(email) into v_email from auth.users where id = v_uid;
  if v_email is null then return null; end if;

  select * into v_inv from public.expert_invites
   where lower(email) = v_email
     and (claimed_user_id is null or claimed_user_id = v_uid);
  if v_inv.email is null then return null; end if;

  insert into public.expert_accounts (user_id, expert_id)
  values (v_uid, v_inv.expert_id)
  on conflict (user_id) do update set expert_id = excluded.expert_id;

  update public.expert_invites
     set claimed_at = coalesce(claimed_at, now()), claimed_user_id = v_uid
   where email = v_inv.email;

  return v_inv.expert_id;
end;
$$;

grant execute on function public.claim_expert_invite() to authenticated;


-- ---------------------------------------------------------------------
-- 10. Readers. Every one goes through my_expert_ids(), so an organisation
-- sees its clinicians' rows and a doctor sees their own, with no branch.
-- ---------------------------------------------------------------------

-- The overview: what we owe, when, and the period's earnings by source.
-- Returns ONE json so the app renders a screen from a single round-trip
-- and cannot mix two moments in time.
create or replace function public.my_earnings_summary(
  p_from timestamptz, p_to timestamptz
) returns jsonb
language sql stable security definer set search_path = ''
as $$
  with mine as (
    select * from public.expert_earnings
     where expert_id in (select public.my_expert_ids())
  ),
  period as (
    select * from mine
     where occurred_at >= p_from and occurred_at < p_to
       and status <> 'reversed'
  ),
  by_source as (
    select source,
           coalesce(sum(expert_paise), 0)   as expert_paise,
           coalesce(sum(gross_paise), 0)    as gross_paise,
           count(*) filter (where expert_paise > 0) as items,
           max(share_bps)                   as share_bps
      from period group by source
  )
  select jsonb_build_object(
    'owed_paise',      (select coalesce(sum(expert_paise), 0) from mine where status = 'payable'),
    'accrued_paise',   (select coalesce(sum(expert_paise), 0) from mine where status = 'accrued'),
    'paid_paise',      (select coalesce(sum(expert_paise), 0) from mine where status = 'paid'),
    'lifetime_paise',  (select coalesce(sum(expert_paise), 0) from mine where status in ('payable','paid')),
    'period_paise',    (select coalesce(sum(expert_paise), 0) from period where status in ('payable','paid')),
    'period_upcoming', (select coalesce(sum(expert_paise), 0) from period where status = 'accrued'),
    'next_payout',     public.next_payout_date(),
    'by_source',       (select coalesce(jsonb_agg(to_jsonb(b) order by b.expert_paise desc), '[]'::jsonb) from by_source b)
  );
$$;
grant execute on function public.my_earnings_summary(timestamptz, timestamptz) to authenticated;

-- The itemised list for a period and (optionally) one source. The
-- counterparty is joined here, at read time: a parent's name from the
-- booking, never copied into the ledger.
create or replace function public.my_earnings(
  p_from timestamptz, p_to timestamptz, p_source text default null
) returns table (
  id             text,
  expert_id      text,
  source         text,
  ref_kind       text,
  ref_id         text,
  title          text,
  counterparty   text,
  occurred_at    timestamptz,
  gross_paise    int,
  share_bps      int,
  expert_paise   int,
  platform_paise int,
  status         text,
  payout_id      text,
  reversal_of    text,
  note           text
)
language sql stable security definer set search_path = ''
as $$
  select e.id, e.expert_id, e.source, e.ref_kind, e.ref_id, e.title,
         case when e.ref_kind = 'booking' then p.name else null end as counterparty,
         e.occurred_at, e.gross_paise, e.share_bps, e.expert_paise,
         e.platform_paise, e.status, e.payout_id, e.reversal_of, e.note
    from public.expert_earnings e
    left join public.booking_bookings b
      on e.ref_kind = 'booking' and b.id = e.ref_id
    left join public.profiles p on p.id = b.user_id
   where e.expert_id in (select public.my_expert_ids())
     and e.occurred_at >= p_from and e.occurred_at < p_to
     and (p_source is null or e.source = p_source)
   order by e.occurred_at desc;
$$;
grant execute on function public.my_earnings(timestamptz, timestamptz, text) to authenticated;

create or replace function public.my_payouts()
returns setof public.expert_payouts
language sql stable security definer set search_path = ''
as $$
  select * from public.expert_payouts
   where expert_id in (select public.my_expert_ids())
   order by coalesce(paid_at, created_at) desc;
$$;
grant execute on function public.my_payouts() to authenticated;

create or replace function public.my_payout_items(p_payout_id text)
returns setof public.expert_earnings
language sql stable security definer set search_path = ''
as $$
  select * from public.expert_earnings
   where payout_id = p_payout_id
     and expert_id in (select public.my_expert_ids())
   order by occurred_at;
$$;
grant execute on function public.my_payout_items(text) to authenticated;

create or replace function public.my_videos()
returns setof public.expert_videos
language sql stable security definer set search_path = ''
as $$
  select * from public.expert_videos
   where expert_id in (select public.my_expert_ids())
   order by added_at desc;
$$;
grant execute on function public.my_videos() to authenticated;

-- The rates in force for the caller today, one row per source, so the
-- Earnings screen can print "80% of what parents pay" for a source that
-- has earned nothing yet.
create or replace function public.my_share_rates()
returns table (source text, share_bps int)
language sql stable security definer set search_path = ''
as $$
  select s.source,
         coalesce(public.resolve_share_bps(
           (select min(x) from public.my_expert_ids() x), s.source, current_date, 0), 0)
    from unnest(array['consultation','masterclass','cohort','course','video']) as s(source);
$$;
grant execute on function public.my_share_rates() to authenticated;


-- ---------------------------------------------------------------------
-- VERIFY (paste into the SQL editor, rolls back):
--
--   begin;
--   select public.resolve_share_bps('meera', 'consultation', current_date, 0);   -- 8000
--   select public.resolve_share_bps('meera', 'consultation', current_date, 25);  -- 8500
--   select public.next_payout_date();
--   rollback;
--
-- and, signed in as a doctor in the app, my_earnings_summary(now() -
-- interval '30 days', now()) returns a jsonb with owed_paise etc.
-- =====================================================================
