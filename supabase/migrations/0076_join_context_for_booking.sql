-- =====================================================================
-- 0076_join_context_for_booking.sql -- who is entering, and as whom.
-- ---------------------------------------------------------------------
-- 0075 answered ONE question for the livekit-token edge function:
-- "which room?" It returned the slot id and deliberately nothing else,
-- and the reasoning there is still right -- a caller cannot select a
-- column a function does not return.
--
-- This adds a second question, because the app could not answer it:
--
--     "which room, AND AS WHOM?"
--
-- THE DEFECT THIS FIXES. The LiveKit token carried `sub` (the user id)
-- and `name` (a display label) and no role. Doctor and parent received
-- BYTE-IDENTICAL tokens. So the call screen could not render "Dr." on a
-- tile, could not say "you are the host", could not order participants
-- by role, and could not restrict who publishes. Every one of those is
-- downstream of one missing fact, and the fact was never sent.
--
-- The app worked around it by passing role-ish strings as widget
-- arguments from whichever screen pushed the call -- so "who am I" lived
-- in a call site rather than in the session. Two devices side by side
-- genuinely looked the same.
--
-- ---------------------------------------------------------------------
-- WHY A WIDER RETURN IS NOT A WIDER LEAK
-- ---------------------------------------------------------------------
--
-- 0075 argued that the narrow return type WAS the privacy policy, so
-- widening it needs an argument rather than a shrug. Field by field:
--
--   role             a fact about the CALLER THEMSELF. They know it.
--   capacity         a property of the thing they booked, already shown
--                    in the booking UI ("50 seats", "1:1").
--   starts / ends    on their own booking row, already rendered.
--   counterpart      the parent already sees the expert name in the
--                    bundled catalogue; the expert already sees the
--                    patient name via expert_roster() (0034).
--
-- Nothing here is new to the caller. The return grew because the
-- QUESTION grew, not because the guard loosened. What is still refused
-- is refused identically: null, for both "no such booking" and "not
-- yours", so ids remain unprobeable.
--
-- ---------------------------------------------------------------------
-- WHERE THIS DELIBERATELY BREAKS 0075 PATTERN: THE TIME WINDOW
-- ---------------------------------------------------------------------
--
-- 0075 returns null for every refusal. That is right for OWNERSHIP
-- refusals -- distinguishing "does not exist" from "not yours" would let
-- anyone probe which booking ids are real.
--
-- It is WRONG for a time refusal, and the difference is worth stating:
-- by the time we are checking the clock we have ALREADY established that
-- the caller owns this booking. Telling them "it opens at 4:50 PM" leaks
-- nothing they do not own, and collapsing it into null would send the app
-- back to one message for six causes -- exactly the failure 0075 header
-- is about ("you have thrown away the diagnosis and kept the symptom").
--
-- So: null for ownership, a REASON for the clock.
--
-- ---------------------------------------------------------------------
-- THE WINDOW APPLIES TO CONSULTS ONLY, AND capacity IS HOW WE KNOW
-- ---------------------------------------------------------------------
--
-- A 1:1 consultation should not be enterable three weeks early -- the
-- room is empty, the timer runs, and the app tells her it is "waiting for
-- Dr. Neha" for an appointment that has not happened.
--
-- A group class is a different product and is NOT being changed in this
-- pass. The engine already distinguishes them with a number it holds and
-- already trusts (see book_slot in 0029, and STILL-OPEN 11.7):
--
--     capacity = 1  ->  a one-to-one consult
--     capacity > 1  ->  a class
--
-- Anything that is not capacity = 1 takes the old path: no window, no
-- refusal, same behaviour as before this migration existed.
--
-- PREREQ: 0029 (booking_bookings, booking_slots), 0073 (my_expert_ids),
--         0072 (expert_profiles, for the counterpart name), 0001
--         (profiles). 0075 is NOT replaced -- it stays as the fallback
--         the edge function degrades to if this is not yet applied.
-- =====================================================================

create or replace function public.join_context_for_booking(p_booking_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid        uuid := auth.uid();
  v_now        timestamptz := now();

  -- How long before the start a consult opens, and how long after the end
  -- it stays open. Named here rather than inlined three times: the client
  -- Booking.joinableAt() uses the same ten minutes and the two must not
  -- drift. The tail grace exists because consultations overrun -- cutting
  -- the room at the scheduled second would drop a doctor mid-sentence.
  v_lead       interval := interval '10 minutes';
  v_tail       interval := interval '15 minutes';

  v_slot       text;
  v_owner      uuid;
  v_status     text;
  v_dur        int;

  v_expert     text;
  v_capacity   int;
  v_starts     timestamptz;
  v_ends       timestamptz;

  v_role       text;
  v_counter    text := '';
begin
  if v_uid is null then
    return null;                      -- not signed in: no room, no reason
  end if;

  select b.slot_id, b.user_id, b.status, b.duration_min
    into v_slot, v_owner, v_status, v_dur
    from public.booking_bookings b
   where b.id = p_booking_id;

  if v_slot is null or v_status = 'cancelled' then
    return null;                      -- gone, or never was
  end if;

  -- The slot always exists: booking_bookings.slot_id is a foreign key to
  -- it, so a booking cannot outlive its slot even though slots self-seed.
  select s.expert_id, s.capacity, s.starts_utc
    into v_expert, v_capacity, v_starts
    from public.booking_slots s
   where s.id = v_slot;

  v_ends := v_starts + make_interval(mins => coalesce(v_dur, 30));

  -- ---- WHO IS THIS? ------------------------------------------------
  -- Same two routes as 0075, and the expert route is still ONE condition
  -- rather than a branch on entity type: my_expert_ids() already resolves
  -- a solo doctor, a clinician under a hospital, and an organisation
  -- account to the same list (0073). A hospital admin joining their own
  -- clinician consult keeps working, and needed no case added.
  if v_owner = v_uid then
    v_role := 'parent';
  elsif v_expert is not null
        and v_expert in (select public.my_expert_ids()) then
    v_role := 'expert';
  else
    return null;                      -- not yours. Same answer as absent.
  end if;

  -- ---- THE CLOCK, FOR CONSULTS ONLY --------------------------------
  if v_capacity = 1 then
    if v_now < (v_starts - v_lead) then
      return jsonb_build_object(
        'ok',         false,
        'reason',     'too_early',
        'opens_utc',  to_char(v_starts - v_lead,
                              'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
        'starts_utc', to_char(v_starts,
                              'YYYY-MM-DD"T"HH24:MI:SS"Z"')
      );
    end if;
    if v_now > (v_ends + v_tail) then
      return jsonb_build_object(
        'ok',       false,
        'reason',   'ended',
        'ends_utc', to_char(v_ends, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
      );
    end if;
  end if;

  -- ---- WHO IS ON THE OTHER SIDE ------------------------------------
  -- Best effort, and empty is fine. Both apps already carry a better
  -- local answer (the parent from the bundled expert catalogue, the
  -- doctor from expert_roster), so this only improves the label when the
  -- CMS happens to know the name. Never something the call depends on.
  if v_role = 'parent' then
    select coalesce(ep.name, '') into v_counter
      from public.expert_profiles ep
     where ep.expert_id = v_expert;
  else
    select coalesce(p.name, '') into v_counter
      from public.profiles p
     where p.id = v_owner;
  end if;

  return jsonb_build_object(
    'ok',          true,
    'slot_id',     v_slot,
    'role',        v_role,
    'capacity',    v_capacity,
    'starts_utc',  to_char(v_starts, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    'ends_utc',    to_char(v_ends,   'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    'counterpart', coalesce(v_counter, '')
  );
end;
$$;

revoke all on function public.join_context_for_booking(text) from public;
grant execute on function public.join_context_for_booking(text) to authenticated;

comment on function public.join_context_for_booking(text) is
  'Returns the join context for a booking the CALLER may join: slot id, their own role (parent|expert), the slot capacity, the session window and the counterpart name. Null for every ownership refusal, so booking ids cannot be probed; {ok:false, reason} for a CLOCK refusal, which is safe to explain because ownership is already established. The clock is enforced only when capacity = 1 (a 1:1 consult) -- group sessions keep the pre-0076 behaviour exactly. Used by the livekit-token edge function, which falls back to join_room_for_booking (0075) if this is not yet applied.';


-- =====================================================================
-- VERIFY
--
--   -- As the parent who owns it, inside the window:
--   select public.join_context_for_booking('bkg_...');
--     -> {"ok": true, "role": "parent", "capacity": 1, "slot_id": "...",
--         "starts_utc": "...", "ends_utc": "...", "counterpart": "..."}
--
--   -- As the hosting expert login, same booking:
--   select public.join_context_for_booking('bkg_...') ->> 'slot_id';
--     -> the SAME slot id, so both land in the same LiveKit room
--   select public.join_context_for_booking('bkg_...') ->> 'role';
--     -> expert
--
--   -- The same consult, three weeks early:
--     -> {"ok": false, "reason": "too_early", "opens_utc": "..."}
--
--   -- A GROUP booking (capacity > 1), three weeks early:
--     -> {"ok": true, ...}   -- unchanged on purpose. Not this pass.
--
--   -- An unrelated signed-in user, or an id that does not exist:
--     -> null   (the same answer for both, still)
--
--   -- The grant is narrow: anon cannot execute it at all.
--   select has_function_privilege('anon',
--            'public.join_context_for_booking(text)', 'execute');
--     -> false
-- =====================================================================
