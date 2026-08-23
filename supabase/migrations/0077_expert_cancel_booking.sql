-- =====================================================================
-- 0077_expert_cancel_booking.sql -- the doctor's side of cancelling.
-- ---------------------------------------------------------------------
-- THE BUG. The doctor app has had two buttons on an appointment for a
-- while: "Cancel this consultation" and "Mark as no-show". Both showed a
-- confirmation naming the money consequence, and both then called
--
--     BookingStore.instance.cancel(bookingId)
--
-- which is the LOCAL method. It looks the booking up in the on-device
-- `_bookings` map and returns false if it is not there:
--
--     final b = _bookings[bookingId];
--     if (b == null || b.status != BookingStatus.upcoming) return false;
--
-- A booking made on the PARENT's phone is never in that map. The doctor
-- app only ever learns about it through expert_roster(), which does not
-- write to BookingStore. So for every real booking the method returned
-- false immediately, wrote nothing anywhere -- and the screen showed
--
--     "Cancelled. The parent has their credit back."
--
-- The parent still had the appointment. The seat was still taken. No
-- credit came back. Nobody found out until the mother sat waiting.
--
-- THE GENERAL LESSON, which is worth more than this fix: a success
-- message must be produced by the thing that succeeded. Here the toast
-- was written next to the CALL rather than derived from its RESULT, so
-- it kept being true about an intention while the action underneath it
-- had quietly become a no-op. The Dart side of this change makes the
-- message conditional on what the server returns; this file gives it
-- something real to return.
--
-- ---------------------------------------------------------------------
-- WHY A NEW FUNCTION RATHER THAN WIDENING cancel_booking()
-- ---------------------------------------------------------------------
--
-- cancel_booking (0029, extended in 0066) is deliberately own-rows-only:
-- `where id = p_booking_id and user_id = auth.uid()`. A doctor is not the
-- owner, so it cannot serve them, and loosening that where-clause would
-- make one function answer two different authorisation questions -- the
-- shape that produced the service-role mess 0075 had to undo.
--
-- Two functions, two audiences, one shared rule about seats and credits.
--
-- ---------------------------------------------------------------------
-- CANCELLED IS NOT THE SAME AS NO-SHOW, AND THE MONEY KNOWS IT
-- ---------------------------------------------------------------------
--
--   * The DOCTOR cancels -> the parent did nothing wrong. The credit
--     comes back regardless of how close to the start it is. The
--     credit_return_hours window in booking_policy exists to stop a
--     PARENT freeing a clinician's hour too late to refill it; it has no
--     business punishing her for a cancellation she did not make.
--
--   * The parent NO-SHOWS -> the hour is gone and the credit is spent.
--     A no-show that costs nothing is a no-show that keeps happening.
--
-- That asymmetry is the entire reason this takes an outcome argument
-- instead of being one "cancel" for both.
--
-- The seat is freed in both cases: the slot is over either way, and a
-- seat left claimed by a session nobody attended is just a wrong number.
--
-- ---------------------------------------------------------------------
-- STATUS VALUES. booking_bookings.status is free text at the database
-- level, and the client enum (BookingStatus) already declares `missed`
-- -- it has simply never been written by anything. This is what finally
-- writes it.
--
-- PREREQ: 0029 (booking_bookings, booking_slots), 0066 (consult_credits,
--         booking_policy), 0073 (my_expert_ids).
-- =====================================================================

create or replace function public.expert_cancel_booking(
  p_booking_id text,
  p_outcome    text default 'cancelled'   -- 'cancelled' | 'missed'
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid     uuid := auth.uid();
  v_booking public.booking_bookings;
  v_expert  text;
begin
  if v_uid is null then
    return 'not_authenticated';
  end if;

  if p_outcome not in ('cancelled', 'missed') then
    return 'bad_outcome';
  end if;

  select * into v_booking
    from public.booking_bookings
   where id = p_booking_id
     for update;

  if not found then
    return 'no_such_booking';
  end if;

  -- May THIS login act for the expert hosting this slot? One condition,
  -- not a branch on entity type: my_expert_ids() (0073) already resolves a
  -- solo doctor, a clinician under a hospital, and an organisation account
  -- to the same list of expert ids. A hospital admin cancelling their own
  -- clinician's consult works here for free.
  select s.expert_id into v_expert
    from public.booking_slots s
   where s.id = v_booking.slot_id;

  if v_expert is null
     or v_expert not in (select public.my_expert_ids()) then
    -- Not "no such booking". The caller is a verified clinician asking
    -- about a booking that is not theirs; there is nothing to probe here
    -- that expert_roster() does not already answer, and a distinct code
    -- is the difference between a fixable message and a mystery.
    return 'not_your_patient';
  end if;

  -- Idempotent. Two taps, one cancellation, one credit.
  if v_booking.status in ('cancelled', 'missed') then
    return 'already_' || v_booking.status;
  end if;

  update public.booking_bookings
     set status = p_outcome
   where id = p_booking_id;

  update public.booking_slots
     set booked = greatest(booked - 1, 0)
   where id = v_booking.slot_id;

  -- The credit returns ONLY when the clinician cancelled. See the note
  -- above on why the parent-facing time window does not apply here.
  if p_outcome = 'cancelled' then
    update public.consult_credits
       set booking_id = null, spent_at = null
     where booking_id = p_booking_id;
  end if;

  return 'ok';
end;
$$;

revoke all on function public.expert_cancel_booking(text, text) from public;
grant execute on function public.expert_cancel_booking(text, text)
  to authenticated;

comment on function public.expert_cancel_booking(text, text) is
  'Lets the hosting expert (via my_expert_ids) cancel a booking or mark it a no-show. Frees the seat in both cases; returns the consult credit ONLY on a doctor-side cancellation, because the parent-facing credit_return_hours window exists to protect a clinician hour from a late parent cancellation and must not penalise her for the clinician cancelling. Returns a status string rather than raising, so the caller can tell the outcomes apart and only claim success when it succeeded. Idempotent.';


-- =====================================================================
-- VERIFY
--
--   -- As the hosting doctor, on a live booking:
--   select public.expert_cancel_booking('bkg_...', 'cancelled');
--     -> ok
--   select status from public.booking_bookings where id = 'bkg_...';
--     -> cancelled
--   select booking_id, spent_at from public.consult_credits
--    where booking_id = 'bkg_...';
--     -> no rows (the credit went back to the pool)
--
--   -- Twice is once:
--   select public.expert_cancel_booking('bkg_...', 'cancelled');
--     -> already_cancelled
--
--   -- A no-show keeps the credit spent:
--   select public.expert_cancel_booking('bkg_other', 'missed');
--     -> ok
--   select spent_at from public.consult_credits where booking_id = 'bkg_other';
--     -> still set
--
--   -- Somebody else's patient:
--     -> not_your_patient
--
--   -- anon cannot execute it at all:
--   select has_function_privilege('anon',
--            'public.expert_cancel_booking(text, text)', 'execute');
--     -> false
-- =====================================================================
