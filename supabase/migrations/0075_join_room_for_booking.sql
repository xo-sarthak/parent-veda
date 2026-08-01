-- =====================================================================
-- 0075_join_room_for_booking.sql -- who may enter a consultation room.
-- ---------------------------------------------------------------------
-- THE BUG THIS FIXES, and it is worth stating precisely because the
-- error message pointed at the wrong thing for an entire evening.
--
-- The livekit-token edge function answered every join with
--
--     403 { error: "no such booking" }
--
-- while the booking sat in booking_bookings, status 'upcoming', owned by
-- the exact uid that was calling. The row was there. The function could
-- not see it.
--
-- It read the row with a SERVICE-ROLE client:
--
--     const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
--     const { data: booking } = await admin.from("booking_bookings")...
--     if (!booking) return json({ error: "no such booking" }, 403);
--
-- Two defects, and the second is what cost the time:
--
--   1. The service-role credential was not usable in that environment,
--      so the query returned nothing.
--   2. The destructure takes `data` and DISCARDS `error`. Every possible
--      failure -- missing key, wrong project, typo'd table, network --
--      collapses into `data === null`, and the code reports the single
--      cause that was not happening. A caller reading "no such booking"
--      goes and looks at the booking. The booking was fine.
--
-- The general lesson, which travels well beyond this function: when a
-- lookup can fail for several reasons and you keep only its result, you
-- have thrown away the diagnosis and kept the symptom.
--
-- ---------------------------------------------------------------------
-- WHY THE FIX IS A DATABASE FUNCTION RATHER THAN A BETTER CLIENT
-- ---------------------------------------------------------------------
--
-- The service-role key existed to solve a real problem: the EXPERT does
-- not own the mother's booking row, so RLS hides it from them, and the
-- expert legitimately needs to join. Elevating to service-role gets past
-- RLS -- and past everything else too. A key that can read every row in
-- every table, living in an edge function, to answer one yes/no question,
-- is a large amount of authority for a small amount of work.
--
-- This codebase already answers "may this login act as this expert?" in
-- Postgres -- my_expert_ids() (0073), expert_roster(), and the RLS
-- policies across 0030-0073. The edge function was the one place that
-- authorisation had leaked into TypeScript, and it was the one place it
-- broke.
--
-- So authorisation moves back where it lives, and the edge function is
-- left with the single job only it can do: sign a JWT with the LiveKit
-- secret. It now needs nothing but the CALLER'S OWN token -- the same
-- credential that already worked, which is why this cannot fail the way
-- the old path did.
--
-- ---------------------------------------------------------------------
-- RETURN TYPE AS PRIVACY POLICY
-- ---------------------------------------------------------------------
--
-- This returns the SLOT ID and nothing else. Not the booking, not the
-- mother's user_id, not the title. The edge function's only remaining
-- question is "which room?", so that is the only fact it gets. A caller
-- cannot select a column a function does not return -- the same reasoning
-- as the sponsor analytics functions in 0060/0063, where the aggregate
-- shape IS the promise rather than a policy sitting on top of one.
--
-- NULL means "no". Both refusals -- the booking does not exist, and it
-- exists but is not yours -- return NULL, deliberately. Distinguishing
-- them would let anyone probe which booking ids are real.
--
-- ---------------------------------------------------------------------
-- WHY NOT RAISE ON REFUSAL
-- ---------------------------------------------------------------------
--
-- Same reason as 0055 and activate_sponsor_benefit: a raise unwinds the
-- transaction. Nothing here writes yet, so it would be harmless today --
-- but the moment someone adds a "joined at" audit row above the guard,
-- a raise would silently discard it. Returning the answer keeps that
-- door closed before anyone walks through it.
--
-- PREREQ: 0029 (booking_bookings, booking_slots), 0073 (my_expert_ids).
-- =====================================================================

create or replace function public.join_room_for_booking(p_booking_id text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid     uuid := auth.uid();
  v_slot    text;
  v_owner   uuid;
  v_status  text;
  v_expert  text;
begin
  if v_uid is null then
    return null;              -- not signed in: no room, no reason given
  end if;

  select b.slot_id, b.user_id, b.status
    into v_slot, v_owner, v_status
    from public.booking_bookings b
   where b.id = p_booking_id;

  if v_slot is null or v_status = 'cancelled' then
    return null;              -- gone, or never was
  end if;

  -- The parent who booked it.
  if v_owner = v_uid then
    return v_slot;
  end if;

  -- Or the expert who hosts the slot. ONE CONDITION, not a branch on
  -- entity type: my_expert_ids() already resolves a solo doctor, a
  -- clinician under a hospital, and an organisation account to the same
  -- list of expert ids (0073). A hospital admin joining their own
  -- clinician's consult works here for free, and needed no case added.
  select s.expert_id into v_expert
    from public.booking_slots s
   where s.id = v_slot;

  if v_expert is not null
     and v_expert in (select public.my_expert_ids()) then
    return v_slot;
  end if;

  return null;
end;
$$;

revoke all on function public.join_room_for_booking(text) from public;
grant execute on function public.join_room_for_booking(text) to authenticated;

comment on function public.join_room_for_booking(text) is
  'Returns the slot id of a booking the CALLER may join (the parent who booked it, or the expert hosting it via my_expert_ids), else null. Replaces the service-role lookup the livekit-token edge function used to do: authorisation belongs in the database, and the room name is the only fact the token signer needs. Null for every refusal, so booking ids cannot be probed.';


-- =====================================================================
-- VERIFY
--
--   -- As the parent who owns it (run from the app, or set the JWT):
--   select public.join_room_for_booking('bkg_...');
--     -> off_exp_neha_s1785566700000
--
--   -- As the hosting expert's login:
--   select public.join_room_for_booking('bkg_...');
--     -> the same slot id, so both land in the same LiveKit room
--
--   -- As an unrelated signed-in user, or for an id that does not exist:
--   select public.join_room_for_booking('bkg_nonsense');
--     -> null   (the same answer for both, on purpose)
--
--   -- The grant is narrow: anon cannot execute it at all.
--   select has_function_privilege('anon',
--            'public.join_room_for_booking(text)', 'execute');
--     -> false
-- =====================================================================
