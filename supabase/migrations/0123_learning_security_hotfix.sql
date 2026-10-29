-- =====================================================================
-- 0123_learning_security_hotfix.sql -- L2a: three holes closed before
-- anything is sold (docs/LEARNING-ARCHITECTURE.md §5, LA-1, LA-2, LA-3)
-- ---------------------------------------------------------------------
--   1. LA-1  expert_accounts is written ONLY by functions. The table
--            grant from 0030 let any signed-in account name itself any
--            expert. Development keeps its picker through
--            dev_claim_expert(), which only an allowlisted tester can use.
--   2. LA-2  book_slot() claims a consult credit again. 0084 rewrote the
--            function to add price_paise and the 0066 credit claim did
--            not come with it.
--   3. LA-3  open_session_room() reads an existing server slot and never
--            creates one from what the phone sends.
--
-- PREREQ: 0030 (expert_accounts), 0066 (consult_credits, paid_by),
-- 0073 (my_expert_ids), 0079 (open_session_room), 0084 (book_slot with
-- price_paise, claim_expert_invite).
--
-- The general facts each fix rests on are in docs/BACKEND-PATTERNS.md
-- §16zzi. Contract test: test/learning_security_contract_test.dart,
-- which reads the LAST definition of each function across the whole
-- migration set, not this file.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. LA-1 -- nobody writes their own expert identity.
--
-- THE BUG. 0030 granted `insert, update` on expert_accounts to every
-- signed-in user, guarded by an own-row policy: `auth.uid() = user_id`.
-- That policy checks WHOSE ROW it is. It cannot check WHAT IS IN IT --
-- and the value in the row (expert_id) is the privilege. So any account
-- could write (me, 'exp_neha') and, from then on, my_expert_ids() said
-- it was Dr Neha: her roster, her consult rooms with publish rights, her
-- moderation controls.
--
-- claim_expert_invite() (0084) was the careful door -- email proven by
-- a code, matched against an admin-written invite. The grant was a
-- second door beside it, and a table grant beats every function built
-- on top of the table, because PostgREST exposes the table directly.
--
-- THE FIX. Revoke the write grant. SELECT stays (resolveFromServer reads
-- its own row back). claim_expert_invite() is `security definer`, so it
-- writes as the function's owner and does not need the caller's grant --
-- which is exactly the property we want: the function is the only door.
-- ---------------------------------------------------------------------
revoke insert, update, delete on public.expert_accounts from authenticated;
revoke insert, update, delete on public.expert_accounts from anon;


-- ---------------------------------------------------------------------
-- dev_testers -- who may use the testing picker.
--
-- The picker (DoctorSession.enter) still has to work on a developer's
-- phone. The tempting gate is the build flag (PV_DEV / kDebugMode), and
-- it is the wrong one: a flag compiled into the app is a claim the phone
-- makes about itself, and anyone holding the anon key can call the RPC
-- without the app at all. A server-side gate has to be a fact the server
-- holds. So: an allowlist of user ids, written only from the SQL editor
-- (no grant to authenticated or anon, RLS on, no policy).
--
-- ⚠️ BEFORE LAUNCH: this table should be empty, or hold only staff
-- accounts. docs/BEFORE-LAUNCH.md carries the row.
-- ---------------------------------------------------------------------
create table if not exists public.dev_testers (
  user_id  uuid        primary key references auth.users (id) on delete cascade,
  note     text,
  added_at timestamptz not null default now()
);

alter table public.dev_testers enable row level security;
revoke all on public.dev_testers from anon, authenticated;

comment on table public.dev_testers is
  'Accounts allowed to use the testing expert picker (dev_claim_expert). Written only from the SQL editor. Should be empty, or staff only, before launch.';


-- ---------------------------------------------------------------------
-- dev_claim_expert(p_expert_id) -- the picker, behind the allowlist.
--
-- RETURNS NULL rather than raising for a non-tester. Trade-off: a raise
-- is louder, and a developer who forgot to add themselves would see it
-- at once. A null keeps the caller's fire-and-forget contract (the
-- picker switches the local session either way), and tells a stranger
-- probing the RPC nothing beyond "no". The app logs the null, so the
-- developer still finds out.
-- ---------------------------------------------------------------------
create or replace function public.dev_claim_expert(p_expert_id text)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then return null; end if;
  if p_expert_id is null or btrim(p_expert_id) = '' then return null; end if;
  if not exists (select 1 from public.dev_testers where user_id = v_uid) then
    return null;
  end if;

  insert into public.expert_accounts (user_id, expert_id)
  values (v_uid, p_expert_id)
  on conflict (user_id) do update set expert_id = excluded.expert_id;

  return p_expert_id;
end;
$$;

revoke all on function public.dev_claim_expert(text) from public;
grant execute on function public.dev_claim_expert(text) to authenticated;

comment on function public.dev_claim_expert(text) is
  'TESTING ONLY. Links the caller to any expert id, but only when the caller is in dev_testers. The real path is claim_expert_invite(). Returns the expert id, or null when refused.';


-- ---------------------------------------------------------------------
-- 2. LA-2 -- book_slot() claims a credit again.
--
-- THE BUG. `create or replace function` swaps the WHOLE body. 0084
-- needed one new argument (price_paise) and rewrote book_slot from the
-- 0029 text, not from 0066's -- so 0066's credit claim and its paid_by
-- write silently disappeared. Nothing failed: bookings still succeeded.
-- What stopped was credits being attached to bookings, so:
--   * my_consult_credits() kept counting a spent credit as available,
--     and the same credit covered every consult after it;
--   * sponsor credits (0067) were never spent at all;
--   * cancel_booking()'s "give the credit back" found no row to return;
--   * paid_by has been NULL on every booking since 0084.
--
-- THE FIX. This body is 0084's, verbatim, plus 0066's claim, verbatim.
-- Same 11-argument signature, so `create or replace` REPLACES rather
-- than adding an overload (BACKEND-PATTERNS 12f), and the grant carries
-- over -- it is restated below only so this file reads complete.
--
-- THE GUARD. The contract test reads the last definition of book_slot
-- in the whole migration set and fails if the claim is missing. The
-- next rewrite (L2b, which makes book_slot read server prices) will
-- trip it unless it copies the claim forward. That is the point.
--
-- NOT CHANGED HERE, on purpose: the slot is still created on demand
-- from client values and unpaid is still allowed (LA-6). That is L2b.
-- ---------------------------------------------------------------------
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
     duration_min, status, paid_by, price_paise)
  values
    (p_booking_id, v_uid, p_offering_id, p_slot_id, p_stage, p_title,
     p_starts_utc, p_duration_min, 'upcoming', 'unpaid', p_price_paise)
  returning * into v_booking;

  -- CLAIM A CREDIT (0066, restored). Oldest-expiring first so nothing is
  -- wasted. FOR UPDATE SKIP LOCKED because two simultaneous bookings by
  -- the same person must not queue behind each other for the same row:
  -- the second takes the next credit instead of waiting for the first.
  --
  -- capacity = 1 is how the server knows this is a consultation; 0066
  -- explains why the seat count, not a client-sent `kind`, is the
  -- signal.
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
  text, text, text, text, timestamptz, int, int, text, text, text, int)
  to authenticated;


-- ---------------------------------------------------------------------
-- 3. LA-3 -- open_session_room() reads a slot; it never makes one.
--
-- THE BUG. 0079 let a host open a room for a class nobody had booked by
-- UPSERTING the slot from the descriptor the phone sent: id, offering,
-- expert, start, duration, capacity. The only check was "may you act as
-- p_expert_id". So a real expert could invent a slot id with any start
-- time (always "now") and any capacity, and receive a publishing host
-- token for it -- a free, unlisted, unlimited broadcast room on our
-- LiveKit bill. And even for an existing slot, the room's END time came
-- from the phone's p_duration_min, so a host could keep it open forever.
--
-- THE FIX. Look up the slot. No row -> null. The authority check moves
-- from the CLAIMED expert (p_expert_id) to the STORED one (the slot's
-- expert_id), and every time -- start, duration, capacity -- is the
-- stored row's.
--
-- THE COST, stated: a host can no longer open a room for a class with
-- zero bookings, because that slot has no row yet. Nobody is waiting in
-- that room, so the loss is a rehearsal, not a class. L2b closes it the
-- right way: published programme sessions already have server slots
-- (ps_<id>, written by publish_programme), and the app moves onto them
-- in L2c.
--
-- WHY THE SIGNATURE KEEPS SIX ARGUMENTS it no longer reads. The
-- livekit-token edge function calls this RPC by NAMED arguments. Drop
-- them and PostgREST finds no function matching the call, and every host
-- join fails until the edge function is redeployed too -- two deploys
-- that must land together, run by hand. Keeping the signature means this
-- migration is safe on its own. This is expand/contract: the unused
-- arguments are dropped later, in the same change that stops the edge
-- function sending them (L3, which rewrites that function anyway).
--
-- The unknown-slot answer is NULL, the same as "not yours", so slot ids
-- cannot be probed by comparing answers.
-- ---------------------------------------------------------------------
create or replace function public.open_session_room(
  p_slot_id      text,
  p_offering_id  text,          -- ignored since 0123; see above
  p_expert_id    text,          -- ignored since 0123; see above
  p_starts_utc   timestamptz,   -- ignored since 0123; see above
  p_duration_min int,           -- ignored since 0123; see above
  p_capacity     int            -- ignored since 0123; see above
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := auth.uid();
  v_now  timestamptz := now();
  v_lead interval := interval '30 minutes';
  v_tail interval := interval '15 minutes';
  v_slot public.booking_slots;
  v_ends timestamptz;
begin
  if v_uid is null then
    return null;
  end if;

  select * into v_slot from public.booking_slots s where s.id = p_slot_id;
  if v_slot.id is null then
    return null;                      -- no such slot: never created here
  end if;

  -- The STORED expert decides, not the one the caller names.
  if v_slot.expert_id is null
     or v_slot.expert_id not in (select public.my_expert_ids()) then
    return null;
  end if;

  v_ends := v_slot.starts_utc
            + make_interval(mins => greatest(coalesce(v_slot.duration_min, 60), 1));

  if v_now < (v_slot.starts_utc - v_lead) then
    return jsonb_build_object(
      'ok',         false,
      'reason',     'too_early',
      'opens_utc',  to_char(v_slot.starts_utc - v_lead,
                            'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
      'starts_utc', to_char(v_slot.starts_utc, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
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
    'slot_id',     v_slot.id,
    'role',        case when v_slot.capacity > 1 then 'host' else 'expert' end,
    'can_publish', true,
    'capacity',    v_slot.capacity,
    'starts_utc',  to_char(v_slot.starts_utc, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    'ends_utc',    to_char(v_ends, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    'counterpart', ''
  );
end;
$$;

revoke all on function public.open_session_room(
  text, text, text, timestamptz, int, int) from public;
grant execute on function public.open_session_room(
  text, text, text, timestamptz, int, int) to authenticated;

comment on function public.open_session_room(
  text, text, text, timestamptz, int, int) is
  'The HOST route into a session room. Since 0123 it reads an EXISTING booking_slots row only: no row, or a slot whose stored expert_id is not one of my_expert_ids(), returns null. Start, duration and capacity are the stored row''s. Only p_slot_id is read; the other five arguments are kept so the livekit-token call still resolves, and are dropped in L3. Opens 30 minutes early.';


-- =====================================================================
-- VERIFY (SQL editor). Each block simulates a signed-in user and rolls
-- back, so nothing is left behind. Replace <uid> with a real auth user.
--
--   -- LA-1: an ordinary user cannot write their expert identity.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"<uid>","role":"authenticated"}', true);
--   insert into public.expert_accounts (user_id, expert_id)
--   values ('<uid>', 'exp_neha');
--     -> ERROR: permission denied for table expert_accounts
--   rollback;
--
--   -- LA-1: the picker refuses a non-tester and accepts a tester.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"<uid>","role":"authenticated"}', true);
--   select public.dev_claim_expert('exp_neha');      -> null
--   rollback;
--   insert into public.dev_testers (user_id, note) values ('<uid>', 'me');
--   -- ...repeat the block above                     -> exp_neha
--
--   -- LA-2: the last book_slot carries the claim.
--   select prosrc like '%for update skip locked%'
--     from pg_proc where proname = 'book_slot';      -> true (one row)
--
--   -- LA-3: an invented slot gets nothing.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"<an expert uid>","role":"authenticated"}', true);
--   select public.open_session_room('slot_made_up', 'x', '<their expert id>',
--            now(), 600, 1000);                      -> null
--   rollback;
--   select count(*) from public.booking_slots where id = 'slot_made_up';
--                                                    -> 0
-- =====================================================================
