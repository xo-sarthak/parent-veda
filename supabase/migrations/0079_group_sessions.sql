-- =====================================================================
-- 0079_group_sessions.sql -- a masterclass that can actually be taught.
-- ---------------------------------------------------------------------
-- WHAT WAS TRUE BEFORE THIS FILE, and it is worth stating baldly:
--
--     A masterclass could be bought. It could be joined. It could not
--     be HOSTED.
--
-- Every route into a LiveKit room resolved it FROM A BOOKING --
-- join_room_for_booking (0075), join_context_for_booking (0076). A host
-- has no booking. They did not buy a seat at their own class. So the
-- teacher was the one person in the product who could not get in, and
-- the only workaround would have been handing them one of their
-- attendees' booking ids.
--
-- And everyone who COULD get in arrived publishing. The token granted
-- `canPublish: true` unconditionally, and the client turned camera and
-- microphone on at connect, so fifty mothers joining a masterclass were
-- fifty live video feeds in one room. That is a privacy incident with a
-- bandwidth bill attached.
--
-- This migration adds the two things those need:
--
--   1. open_session_room()  -- a host's own way in, with no booking.
--   2. a ROLE that distinguishes host from attendee, and a publish
--      right derived from it rather than granted to everyone.
--
-- ---------------------------------------------------------------------
-- FOUR ROLES, NOT TWO
-- ---------------------------------------------------------------------
--
-- 0076 answered 'parent' or 'expert'. That was enough while only 1:1
-- worked. A class needs the same distinction to mean something
-- different, because what a doctor may DO differs between the two:
--
--   capacity = 1   parent    | expert     -- both publish. A consult is
--                                            a conversation.
--   capacity > 1   attendee  | host       -- only the host publishes.
--                                            A class is a broadcast.
--
-- The role therefore carries both facts at once -- who you are, and
-- which product you are in -- and the client can switch on it directly
-- instead of pairing a role with a capacity check at every call site.
--
-- `can_publish` is returned SEPARATELY rather than being re-derived on
-- the client, because it is a permission and permissions are the
-- server's to state. The client uses it to lay out the screen; the
-- TOKEN is what actually enforces it, and the media server enforces the
-- token. A modified client can lie to itself and still not publish.
--
-- ---------------------------------------------------------------------
-- THE WINDOW NOW APPLIES TO CLASSES TOO, WITH A LONGER LEAD FOR THE HOST
-- ---------------------------------------------------------------------
--
-- 0076 gated only consults, deliberately, because group behaviour was
-- not being touched in that pass. It is being touched now.
--
-- A host gets THIRTY minutes of lead where an attendee gets ten. That
-- asymmetry is the point: a teacher wants to be in the empty room
-- first, checking their camera and their slides, before anyone arrives.
-- A teacher who can only enter when their students can is a teacher who
-- is always setting up in public.
--
-- PREREQ: 0029 (booking_bookings, booking_slots), 0073 (my_expert_ids),
--         0076 (the shape this extends), 0072 (expert_profiles), 0001.
-- =====================================================================


-- ---------------------------------------------------------------------
-- join_context_for_booking -- REPLACED, to know a class from a consult.
--
-- The consult half is byte-for-byte the behaviour 0076 shipped: same
-- roles, same window, same refusals. Only the capacity > 1 branch is
-- new, and before this migration that branch had no rules at all.
-- ---------------------------------------------------------------------
create or replace function public.join_context_for_booking(p_booking_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid        uuid := auth.uid();
  v_now        timestamptz := now();

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

  v_is_group   boolean;
  v_role       text;
  v_publish    boolean;
  v_counter    text := '';
begin
  if v_uid is null then
    return null;
  end if;

  select b.slot_id, b.user_id, b.status, b.duration_min
    into v_slot, v_owner, v_status, v_dur
    from public.booking_bookings b
   where b.id = p_booking_id;

  if v_slot is null or v_status = 'cancelled' then
    return null;
  end if;

  select s.expert_id, s.capacity, s.starts_utc
    into v_expert, v_capacity, v_starts
    from public.booking_slots s
   where s.id = v_slot;

  v_ends     := v_starts + make_interval(mins => coalesce(v_dur, 30));
  v_is_group := coalesce(v_capacity, 1) > 1;

  -- ---- WHO IS THIS, AND WHAT MAY THEY DO? --------------------------
  if v_owner = v_uid then
    -- They hold a seat. In a consult that makes them the patient and an
    -- equal party; in a class it makes them one of the audience.
    v_role    := case when v_is_group then 'attendee' else 'parent' end;
    v_publish := not v_is_group;
  elsif v_expert is not null
        and v_expert in (select public.my_expert_ids()) then
    v_role    := case when v_is_group then 'host' else 'expert' end;
    v_publish := true;
    -- A host reaching the room through an attendee's booking id is an
    -- accident of how they got here, not a different kind of entry.
    -- open_session_room() below is the front door; this is the side one,
    -- and it grants the same thing.
    v_lead := interval '30 minutes';
  else
    return null;                      -- not yours. Same answer as absent.
  end if;

  -- ---- THE CLOCK ---------------------------------------------------
  -- Now applied to classes as well. Before 0079 a class had no window at
  -- all, which is how a masterclass booked for next Thursday could be
  -- "joined" today, alone, forever.
  if v_now < (v_starts - v_lead) then
    return jsonb_build_object(
      'ok',         false,
      'reason',     'too_early',
      'opens_utc',  to_char(v_starts - v_lead,
                            'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
      'starts_utc', to_char(v_starts, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
    );
  end if;
  if v_now > (v_ends + v_tail) then
    return jsonb_build_object(
      'ok',       false,
      'reason',   'ended',
      'ends_utc', to_char(v_ends, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
    );
  end if;

  -- ---- WHO IS ON THE OTHER SIDE ------------------------------------
  -- Only meaningful in a consult, where there IS one other side. A class
  -- has forty, and the name that matters there is the host's, which the
  -- attendee already has from the catalogue.
  if not v_is_group then
    if v_role = 'parent' then
      select coalesce(ep.name, '') into v_counter
        from public.expert_profiles ep
       where ep.expert_id = v_expert;
    else
      select coalesce(p.name, '') into v_counter
        from public.profiles p
       where p.id = v_owner;
    end if;
  end if;

  return jsonb_build_object(
    'ok',          true,
    'slot_id',     v_slot,
    'role',        v_role,
    'can_publish', v_publish,
    'capacity',    v_capacity,
    'starts_utc',  to_char(v_starts, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    'ends_utc',    to_char(v_ends,   'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    'counterpart', coalesce(v_counter, '')
  );
end;
$$;


-- ---------------------------------------------------------------------
-- open_session_room() -- the HOST's front door.
--
-- A host has no booking, so there is no booking id to resolve a room
-- from. They have something better: they are the expert on the slot.
--
-- THE SLOT MAY NOT EXIST YET, and that is normal rather than an error.
-- booking_slots self-seeds (0029): the client generates slots and the
-- FIRST BOOKER creates the row. A host opening a room for a class
-- nobody has booked would find nothing to point at. So this function
-- upserts the slot the same way book_slot does, from the descriptor the
-- host's own catalogue produced -- after checking they may host it.
--
-- The check is on the EXPERT ID, not on the slot: an unseeded slot has
-- no expert_id to verify against, so the caller supplies who they claim
-- to be and my_expert_ids() decides whether that claim holds. A caller
-- can therefore only ever open a room for an expert they already are.
-- ---------------------------------------------------------------------
create or replace function public.open_session_room(
  p_slot_id      text,
  p_offering_id  text,
  p_expert_id    text,
  p_starts_utc   timestamptz,
  p_duration_min int,
  p_capacity     int
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid      uuid := auth.uid();
  v_now      timestamptz := now();
  v_lead     interval := interval '30 minutes';
  v_tail     interval := interval '15 minutes';
  v_ends     timestamptz;
  v_capacity int;
  v_starts   timestamptz;
begin
  if v_uid is null then
    return null;
  end if;

  -- May this login act as this expert? One condition, as everywhere
  -- else: my_expert_ids() (0073) already resolves a solo doctor, a
  -- clinician under a hospital and an organisation account to the same
  -- list, so a hospital admin opening their own clinician's class works
  -- here without a special case.
  if p_expert_id is null
     or p_expert_id not in (select public.my_expert_ids()) then
    return null;
  end if;

  -- Seed the slot if this class has no bookings yet. `do nothing` rather
  -- than `do update`: once a row exists it is the seat-count authority
  -- and a host must not be able to reset `booked` by re-entering.
  insert into public.booking_slots
    (id, offering_id, expert_id, starts_utc, duration_min, capacity, booked)
  values
    (p_slot_id, p_offering_id, p_expert_id, p_starts_utc,
     greatest(coalesce(p_duration_min, 60), 1),
     greatest(coalesce(p_capacity, 1), 1), 0)
  on conflict (id) do nothing;

  -- Read back what is actually stored, which may differ from what was
  -- passed if the slot already existed. The STORED row wins: it is what
  -- every attendee was sold.
  select s.capacity, s.starts_utc
    into v_capacity, v_starts
    from public.booking_slots s
   where s.id = p_slot_id;

  if v_starts is null then
    return null;                      -- the insert did not take
  end if;

  v_ends := v_starts + make_interval(mins => coalesce(p_duration_min, 60));

  if v_now < (v_starts - v_lead) then
    return jsonb_build_object(
      'ok',         false,
      'reason',     'too_early',
      'opens_utc',  to_char(v_starts - v_lead,
                            'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
      'starts_utc', to_char(v_starts, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
    );
  end if;
  if v_now > (v_ends + v_tail) then
    return jsonb_build_object(
      'ok',       false,
      'reason',   'ended',
      'ends_utc', to_char(v_ends, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
    );
  end if;

  return jsonb_build_object(
    'ok',          true,
    'slot_id',     p_slot_id,
    'role',        case when v_capacity > 1 then 'host' else 'expert' end,
    'can_publish', true,
    'capacity',    v_capacity,
    'starts_utc',  to_char(v_starts, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    'ends_utc',    to_char(v_ends,   'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    'counterpart', ''
  );
end;
$$;


-- ---------------------------------------------------------------------
-- can_moderate_slot() -- may this caller mute, remove or promote in
-- this room?
--
-- Its own function because the MODERATION edge function needs to ask
-- exactly this and nothing else. Same reasoning as 0075's return type:
-- the narrowest possible answer to the only question being asked. A
-- boolean cannot leak a name, a time or a seat count.
-- ---------------------------------------------------------------------
create or replace function public.can_moderate_slot(p_slot_id text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
      from public.booking_slots s
     where s.id = p_slot_id
       and s.expert_id in (select public.my_expert_ids())
  );
$$;

revoke all on function public.open_session_room(
  text, text, text, timestamptz, int, int) from public;
grant execute on function public.open_session_room(
  text, text, text, timestamptz, int, int) to authenticated;

revoke all on function public.can_moderate_slot(text) from public;
grant execute on function public.can_moderate_slot(text) to authenticated;

comment on function public.open_session_room(
  text, text, text, timestamptz, int, int) is
  'The HOST route into a group session room. A host holds no booking - they did not buy a seat at their own class - so the booking-based join functions could never let them in. Verifies the caller may act as p_expert_id via my_expert_ids(), self-seeds the slot if the class has no bookings yet (same pattern as book_slot in 0029), and returns the same join-context shape as join_context_for_booking with role=host. Opens 30 minutes early so a teacher can set up before anyone arrives.';

comment on function public.can_moderate_slot(text) is
  'True when the caller hosts this slot and may therefore mute, remove or promote participants in its room. A boolean and nothing else: the moderation edge function asks only this.';


-- =====================================================================
-- VERIFY
--
--   -- An ATTENDEE of a class, inside the window:
--   select public.join_context_for_booking('bkg_class');
--     -> {"ok": true, "role": "attendee", "can_publish": false,
--         "capacity": 100, ...}
--
--   -- A PARENT in a consult is unchanged from 0076:
--   select public.join_context_for_booking('bkg_consult');
--     -> {"ok": true, "role": "parent", "can_publish": true,
--         "capacity": 1, "counterpart": "Dr ...", ...}
--
--   -- The HOST, with no booking at all:
--   select public.open_session_room('slot_x', 'off_x', 'exp_neha',
--            now() + interval '20 minutes', 75, 100);
--     -> {"ok": true, "role": "host", "can_publish": true, ...}
--        (and booking_slots now has slot_x, booked = 0)
--
--   -- The same call by someone who is not that expert:
--     -> null
--
--   -- Re-opening an existing room does not reset the seat count:
--   select booked from public.booking_slots where id = 'slot_x';
--     -> unchanged
--
--   -- Moderation:
--   select public.can_moderate_slot('slot_x');   -> true  (as the host)
--                                                -> false (as anyone else)
-- =====================================================================
