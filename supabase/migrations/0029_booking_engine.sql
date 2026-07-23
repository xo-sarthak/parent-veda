-- =====================================================================
-- 0029_booking_engine.sql -- the one booking engine, server side
-- ---------------------------------------------------------------------
-- Paid services (masterclasses, 1:1 consults, cohorts, yoga packs) share
-- one client engine (lib/booking/). Almost all of it is fine local-first
-- -- the mother's entitlements and her booking history live in her
-- user_state blob like every other light store. ONE thing cannot: the
-- seat count on a shared slot. If two mothers claim the last seat of a
-- 50-cap class at the same moment, only a single authority can say who
-- got it. That authority is here.
--
-- This migration owns exactly that: the slot seat-count, a durable record
-- of who booked what, and two SECURITY DEFINER functions that change them
-- atomically. Offerings and credits stay client-side for now (catalogue
-- display and per-user credit math are not concurrency-sensitive); a later
-- migration can move credit checks server-side if we ever need to.
--
-- SELF-SEEDING SLOTS. The client generates slots (real upcoming DateTimes)
-- rather than reading them from here, so a slot may not exist in the table
-- until its first booking. book_slot() therefore UPSERTS the slot on first
-- claim -- the first booker creates it with its capacity, everyone after
-- increments it. No seed step, and the caps still hold across users.
--
-- PREREQ: none beyond auth.users. No co-parent read yet: a booking is
-- personal, so RLS is own-rows-only (a family-shared calendar can widen
-- this later, deliberately).
-- =====================================================================


-- ---------------------------------------------------------------------
-- booking_slots -- the seat-count source of truth.
--
-- booked is NEVER written by a client; the grant is select-only and every
-- mutation goes through the definer functions below. Read is open to any
-- authenticated user (a seat count is not private).
-- ---------------------------------------------------------------------
create table public.booking_slots (
  id           text        primary key,
  offering_id  text        not null,
  expert_id    text        not null,
  starts_utc   timestamptz not null,
  duration_min int         not null,
  capacity     int         not null check (capacity > 0),
  booked       int         not null default 0 check (booked >= 0),
  join_url     text,
  created_at   timestamptz not null default now()
);

grant select on public.booking_slots to authenticated;
alter table public.booking_slots enable row level security;

create policy "booking_slots read" on public.booking_slots
  for select using (true);


-- ---------------------------------------------------------------------
-- booking_bookings -- the durable "who claimed what" record.
--
-- The client also keeps its own copy in the user_state blob (so history
-- renders offline); this table is the authoritative seat-claim ledger the
-- caps are reconstructed from, and the row cancel() frees a seat against.
-- Own-rows-only in every direction. Inserts/updates happen ONLY inside the
-- definer functions, so there is no client write policy at all.
-- ---------------------------------------------------------------------
create table public.booking_bookings (
  id           text        primary key,
  user_id      uuid        not null references auth.users (id) on delete cascade,
  offering_id  text        not null,
  slot_id      text        not null references public.booking_slots (id),
  stage        text        not null,          -- 'pregnancy' | 'parenting'
  title        text        not null,
  starts_utc   timestamptz not null,
  duration_min int         not null,
  status       text        not null default 'upcoming',
  created_at   timestamptz not null default now()
);

create index booking_bookings_user_idx on public.booking_bookings (user_id);

grant select on public.booking_bookings to authenticated;
alter table public.booking_bookings enable row level security;

create policy "booking_bookings own select" on public.booking_bookings
  for select using (auth.uid() = user_id);


-- ---------------------------------------------------------------------
-- book_slot() -- claim a seat atomically, creating the slot if needed.
--
-- The whole point of the engine touching the server. The row lock
-- (FOR UPDATE) serialises concurrent bookers on the same slot, so the
-- capacity check and the increment cannot interleave -- the last seat goes
-- to exactly one mother. The booking id is minted by the CLIENT and passed
-- in, so the local optimistic row and the server row share an identity and
-- there is no reconciliation to do.
--
-- Raises 'slot full' / 'already booked' / 'not authenticated'; the client
-- treats any raise as "booking failed" and rolls its optimistic write back.
-- ---------------------------------------------------------------------
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
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  -- First claim on this slot creates it; later claims are no-ops here.
  insert into public.booking_slots
    (id, offering_id, expert_id, starts_utc, duration_min, capacity, join_url)
  values
    (p_slot_id, p_offering_id, p_expert_id, p_starts_utc,
     p_duration_min, p_capacity, p_join_url)
  on conflict (id) do nothing;

  -- Serialise everyone competing for this slot's seats.
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
     duration_min, status)
  values
    (p_booking_id, v_uid, p_offering_id, p_slot_id, p_stage, p_title,
     p_starts_utc, p_duration_min, 'upcoming')
  returning * into v_booking;

  return v_booking;
end;
$$;

grant execute on function public.book_slot(
  text, text, text, text, timestamptz, int, int, text, text, text
) to authenticated;


-- ---------------------------------------------------------------------
-- cancel_booking() -- mark cancelled and free the seat, atomically.
--
-- Only the owner may cancel (the where-clause on user_id enforces it under
-- definer rights). Idempotent: cancelling an already-cancelled booking is a
-- no-op, never a double seat-refund.
-- ---------------------------------------------------------------------
create or replace function public.cancel_booking(p_booking_id text)
returns void
language plpgsql
security definer set search_path = ''
as $$
declare
  v_booking public.booking_bookings;
  v_uid     uuid := auth.uid();
begin
  select * into v_booking from public.booking_bookings
    where id = p_booking_id and user_id = v_uid for update;

  if not found then
    raise exception 'no such booking';
  end if;

  if v_booking.status = 'cancelled' then
    return; -- idempotent; do not refund a seat twice
  end if;

  update public.booking_bookings set status = 'cancelled'
    where id = p_booking_id;
  update public.booking_slots set booked = greatest(booked - 1, 0)
    where id = v_booking.slot_id;
end;
$$;

grant execute on function public.cancel_booking(text) to authenticated;
