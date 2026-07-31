-- =====================================================================
-- 0073_one_partner_no_exceptions.sql -- an organisation is a partner,
--                                       not a special case.
-- ---------------------------------------------------------------------
-- THE RULE THIS FILE ENFORCES, stated once so no later migration
-- reintroduces the exception:
--
--     A doctor with their own clinic and a 400-bed hospital are the same
--     kind of thing. Same dashboard, same capabilities, same functions.
--     No gate anywhere branches on whether the caller is a person or an
--     organisation.
--
-- The only real difference is a LAYER: an organisation has doctors under
-- it. A solo practitioner is the same shape with one member -- themself.
-- That is the freelancer-versus-employee distinction: the work is
-- identical, and "who they came from" is one extra fact, not a different
-- species.
--
-- ---------------------------------------------------------------------
-- WHAT WAS ACTUALLY BROKEN
-- ---------------------------------------------------------------------
--
-- Two login routes existed -- expert_accounts (a person) and
-- partner_accounts (an organisation, 0068) -- and almost every gate
-- resolved the caller through the FIRST one only:
--
--   respond_to_programme_assignment   raise 'not an expert account'
--   expert_roster()                   returns zero rows
--   doctor_availability RLS           cannot write
--   doctor_schedule RLS               cannot write
--   prescriptions RLS                 cannot write
--
-- So Apollo could sign in, see a dashboard, be invited to teach a
-- masterclass -- and then accept nothing, see no bookings, set no hours
-- and write no prescriptions. Every one of those failures is silent or
-- reads as an unrelated error.
--
-- 0068 already fixed HALF of it: caller_owns_partner() resolves both
-- routes, and the three partner-facing functions use it. What was never
-- done is the CONSULTING half, which is where the exceptions lived.
--
-- ---------------------------------------------------------------------
-- THE FIX: ONE QUESTION, ASKED EVERYWHERE
-- ---------------------------------------------------------------------
--
-- my_expert_ids() -- "which experts may this login act as?"
--
--     a solo doctor   -> their own id
--     an organisation -> every doctor under it
--
-- Every gate becomes `expert_id in (select my_expert_ids())` instead of
-- `expert_id = (select ... from expert_accounts)`. The branch is gone,
-- and it is gone from ONE place, so the next feature cannot forget it.
--
-- Note this also IS the depth, arriving for free: an organisation reads
-- its doctors' rosters because they are its experts, and expert_roster()
-- now returns which doctor each booking belongs to. Apollo sees its own
-- numbers broken down by clinician without a second system -- exactly
-- what sponsor_dashboard/sponsor_roster do for an employer and its
-- staff.
--
-- PREREQ: 0030 (expert_accounts), 0068 (partner_accounts,
--         caller_owns_partner), 0072 (expert_profiles).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The one resolver.
--
-- security definer because it reads two mapping tables the caller has no
-- direct rights over, stable so a policy calls it once per query rather
-- than once per row, and it takes NO ARGUMENT -- there is no shape of
-- this call that answers about somebody else.
-- ---------------------------------------------------------------------
create or replace function public.my_expert_ids()
returns setof text
language sql stable security definer set search_path = ''
as $$
  -- Route A: a person. Their own expert record.
  select ea.expert_id
    from public.expert_accounts ea
   where ea.user_id = auth.uid()

  union

  -- Route B: an organisation. Every consulting doctor under it.
  --
  -- Reads expert_profiles rather than care_partners.expert_id, because
  -- that column holds at most ONE expert -- fine for a solo practitioner
  -- whose clinic and self are the same record, useless for a hospital
  -- with forty clinicians. expert_profiles.partner_id is the many side.
  select ep.expert_id
    from public.partner_accounts pa
    join public.expert_profiles ep on ep.partner_id = pa.partner_id
   where pa.user_id = auth.uid()
     and ep.status = 'published'

  union

  -- Route C: the legacy single link. care_partners.expert_id predates
  -- expert_profiles and a solo doctor signed in before 0072 still has
  -- only this. Dropped once the catalogue is fully migrated; until then
  -- removing it would sign working doctors out of their own dashboards.
  select cp.expert_id
    from public.partner_accounts pa
    join public.care_partners cp on cp.id = pa.partner_id
   where pa.user_id = auth.uid()
     and cp.expert_id is not null;
$$;

grant execute on function public.my_expert_ids() to authenticated;

comment on function public.my_expert_ids() is
  'Which experts this login may act as. A solo doctor gets their own id; an organisation gets every doctor under it. THE single identity question - every consulting gate uses it, so no function branches on person-versus-organisation.';


-- ---------------------------------------------------------------------
-- 2. Accepting a programme -- for anybody who was asked.
--
-- It resolved the caller through expert_accounts alone and raised
-- 'not an expert account' for everybody else -- so an organisation with
-- a perfectly good deliverer row could be invited and never answer.
-- An invitation nobody can accept is worse than no invitation, because
-- publish_programme() then refuses forever with a message about a
-- missing acceptance while the host swears they were never asked.
--
-- Still raises rather than returning a refusal, per 0055's note: these
-- failure paths never wrote an audit row, so a raise loses nothing and
-- the app is better served by an exception it can catch.
-- ---------------------------------------------------------------------
create or replace function public.respond_to_programme_assignment(
  p_programme_id text,
  p_accept       boolean,
  p_note         text default null
) returns text
language plpgsql security definer set search_path = ''
as $$
declare
  v_n     int;
  v_who   text;
begin
  if auth.uid() is null then
    raise exception 'not signed in';
  end if;

  update public.programme_experts pe
     set status = case when p_accept then 'accepted' else 'declined' end,
         responded_at = now(),
         note = p_note
   where pe.programme_id = p_programme_id
     and pe.status = 'invited'
     -- ONE CONDITION, not a branch on entity type. my_expert_ids()
     -- returns the caller's own id for a person and every doctor under
     -- it for an organisation -- including the organisation's own
     -- deliverer row, since that row's partner_id points at itself.
     and pe.expert_id in (select public.my_expert_ids());
  get diagnostics v_n = row_count;

  if v_n = 0 then
    raise exception 'no open invitation for this programme';
  end if;

  -- Audit as whoever actually answered, so "who accepted this" survives.
  select coalesce(
           (select ea.expert_id from public.expert_accounts ea
             where ea.user_id = auth.uid()),
           (select pa.partner_id from public.partner_accounts pa
             where pa.user_id = auth.uid()),
           auth.uid()::text)
    into v_who;

  perform public._audit(v_who, 'respond_to_programme_assignment',
    'programmes', p_programme_id,
    jsonb_build_object('accepted', p_accept), 'ok', p_note);

  return case when p_accept then 'accepted' else 'declined' end;
end;
$$;

grant execute on function
  public.respond_to_programme_assignment(text, boolean, text) to authenticated;


-- ---------------------------------------------------------------------
-- 3. The roster -- an organisation sees its doctors' bookings.
--
-- Return type changes (expert_id is added), so the old signature has to
-- go first.
--
-- WHY expert_id IS NOW RETURNED. A solo doctor never needed it: every
-- row was theirs. A hospital does -- "which of our clinicians has this
-- appointment" is the first question anyone at Apollo will ask, and
-- without it the screen is a pile of strangers' bookings. This is the
-- depth arriving for free: same rows, one more column, and the app can
-- group by it whenever it wants to.
-- ---------------------------------------------------------------------
drop function if exists public.expert_roster();

create or replace function public.expert_roster()
returns table (
  id           text,
  user_id      uuid,
  offering_id  text,
  slot_id      text,
  stage        text,
  title        text,
  starts_utc   timestamptz,
  duration_min int,
  status       text,
  created_at   timestamptz,
  patient_name text,
  patient_due  date,
  expert_id    text
)
language sql
stable
security definer set search_path = ''
as $$
  select
    b.id, b.user_id, b.offering_id, b.slot_id, b.stage, b.title,
    b.starts_utc, b.duration_min, b.status, b.created_at,
    p.name      as patient_name,
    p.due_date  as patient_due,
    s.expert_id
  from public.booking_bookings b
  join public.booking_slots s on s.id = b.slot_id
  left join public.profiles  p on p.id = b.user_id
  where b.status <> 'cancelled'
    and s.expert_id in (select public.my_expert_ids())
  order by b.starts_utc;
$$;

grant execute on function public.expert_roster() to authenticated;


-- ---------------------------------------------------------------------
-- 4. The remaining gates, re-pointed at the one question.
--
-- Each of these read expert_accounts directly, so an organisation could
-- not set hours, write a prescription, or open a schedule for any of its
-- own doctors. Same rewrite, five times: `= (select from expert_accounts)`
-- becomes `in (select my_expert_ids())`.
-- ---------------------------------------------------------------------

-- doctor_availability (0031) — one "write" policy covering all verbs.
drop policy if exists "doctor_availability write" on public.doctor_availability;
create policy "doctor_availability write" on public.doctor_availability
  for all to authenticated
  using (expert_id in (select public.my_expert_ids()))
  with check (expert_id in (select public.my_expert_ids()));

-- doctor_schedule (0033) — three separate policies, kept separate rather
-- than collapsed into `for all`. Splitting them was the original author's
-- choice and it is the better one: a `for all` policy hides which verb a
-- refusal came from, and a diary is a thing people delete rows from by
-- accident.
drop policy if exists "doctor_schedule insert" on public.doctor_schedule;
create policy "doctor_schedule insert" on public.doctor_schedule
  for insert to authenticated
  with check (expert_id in (select public.my_expert_ids()));

drop policy if exists "doctor_schedule update" on public.doctor_schedule;
create policy "doctor_schedule update" on public.doctor_schedule
  for update to authenticated
  using (expert_id in (select public.my_expert_ids()))
  with check (expert_id in (select public.my_expert_ids()));

drop policy if exists "doctor_schedule delete" on public.doctor_schedule;
create policy "doctor_schedule delete" on public.doctor_schedule
  for delete to authenticated
  using (expert_id in (select public.my_expert_ids()));

-- prescriptions (0032) — READ, and the write function below it.
--
-- A hospital reading its own clinicians' prescriptions is the same fact
-- as the roster: they are its doctors. It is worth being explicit that
-- this widens who can see a prescription, and that it is intended --
-- Apollo's records are Apollo's. It does NOT widen it to any other
-- partner, because my_expert_ids() only ever returns doctors under the
-- caller's own organisation.
drop policy if exists "prescriptions read" on public.prescriptions;
create policy "prescriptions read" on public.prescriptions
  for select using (
    patient_user_id = auth.uid()
    or exists (
      select 1
      from public.booking_bookings b
      join public.booking_slots s on s.id = b.slot_id
      where b.id = prescriptions.booking_id
        and s.expert_id in (select public.my_expert_ids())
    )
  );

-- write_prescription() (0032) — same rewrite, in the function's guard.
create or replace function public.write_prescription(
  p_id         text,
  p_booking_id text,
  p_items      jsonb,
  p_advice     text
) returns void
language plpgsql
security definer set search_path = ''
as $$
declare
  v_booking public.booking_bookings;
  v_slot    public.booking_slots;
begin
  select * into v_booking from public.booking_bookings where id = p_booking_id;
  if not found then raise exception 'no such booking'; end if;

  select * into v_slot from public.booking_slots where id = v_booking.slot_id;

  if v_slot.expert_id not in (select public.my_expert_ids()) then
    raise exception 'not your patient';
  end if;

  -- 0032 verbatim. The ONLY change in this function is the guard above:
  -- an upsert would be a behaviour change smuggled into a migration about
  -- identity, and the next person debugging a duplicate prescription
  -- would have no reason to look here.
  insert into public.prescriptions
    (id, booking_id, expert_id, patient_user_id, items, advice)
  values
    (p_id, p_booking_id, v_slot.expert_id, v_booking.user_id, p_items, p_advice);
end;
$$;

grant execute on function
  public.write_prescription(text, text, jsonb, text) to authenticated;

-- programme_experts (0054). Unchanged shape -- one host column -- and
-- an organisation sees both its OWN invitations and those of every
-- clinician under it, because my_expert_ids() returns both.
drop policy if exists "programme_experts own" on public.programme_experts;
create policy "programme_experts own" on public.programme_experts
  for select to authenticated
  using (expert_id in (select public.my_expert_ids()));


-- ---------------------------------------------------------------------
-- 5. A REFERRAL KNOWS WHO HANDED IT OVER.
--
-- The same layer, applied to referrals instead of consulting.
--
-- WHAT WAS MISSING, and what was NOT. It is tempting to conclude that a
-- doctor inside a hospital needs their own care_partners row, their own
-- KYC and their own QR. They do not:
--
--   * the QR goes out under the hospital, because the hospital is who we
--     partnered with;
--   * the KYC is the hospital's problem, not ours -- our approval step
--     records a decision we made, it does not verify a government id;
--   * and "where does this person come from" is ALREADY answered by
--     expert_profiles.partner_id. Meera's points at herself, Arjun's
--     points at Apollo. A second link on care_partners would have been a
--     second answer to a question that already has one.
--
-- The one real gap is narrower than all of that: a token records WHICH
-- PARTNER but not WHICH PERSON handed it over. So Apollo can see forty
-- families arrived and never which of its clinicians brought them --
-- the school knowing its average and not its students.
--
-- Both columns are NULLABLE, and that is the whole design: a solo
-- doctor's token has no person layer because the partner IS the person,
-- and nothing about the existing flow changes for them.
-- ---------------------------------------------------------------------
alter table public.partner_referrals
  add column if not exists expert_id text;
alter table public.partner_attributions
  add column if not exists expert_id text;

comment on column public.partner_referrals.expert_id is
  'WHO handed this code over, when the partner is an organisation. Null for a solo practitioner, whose partner_id already is them. Deliberately NOT a foreign key to expert_profiles: a doctor may leave the hospital and their profile be archived, and that must never invalidate a poster already on a wall or rewrite who introduced a family.';
comment on column public.partner_attributions.expert_id is
  'Copied from the token at attribution time. Frozen: it records who introduced this family, which does not change afterwards even if the clinician moves on.';

create index if not exists partner_referrals_expert_idx
  on public.partner_referrals (expert_id) where expert_id is not null;
create index if not exists partner_attributions_expert_idx
  on public.partner_attributions (partner_id, expert_id);

-- ---------------------------------------------------------------------
-- Minting, with the person layer. 0040 verbatim apart from the new
-- argument, added LAST and defaulted so every existing call site keeps
-- working unchanged.
--
-- ⚠️ THE OLD SIGNATURE MUST BE DROPPED FIRST. `create or replace` with a
-- different parameter count does not replace anything -- it creates an
-- OVERLOAD. Both would then accept mint_partner_token('cp_apollo'), and
-- Postgres would refuse the call as ambiguous. Every existing caller
-- (0051, 0052, 0055, 0069) would break at once, with an error about
-- function resolution rather than about anything anyone changed.
--
-- 0052 hit exactly this when create_care_partner gained p_actor. Same
-- fix: drop, then create.
-- ---------------------------------------------------------------------
drop function if exists public.mint_partner_token(
  text, text, text, timestamptz);

create or replace function public.mint_partner_token(
  p_partner_id  text,
  p_channel     text default 'qr',
  p_campaign    text default null,
  p_expires_at  timestamptz default null,
  p_expert_id   text default null
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_alphabet constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  v_token    text;
  v_try      int := 0;
begin
  if not exists (
    select 1 from public.care_partners
     where id = p_partner_id and deleted_at is null
  ) then
    raise exception 'no such care partner: %', p_partner_id;
  end if;

  -- If a person is named, they must actually belong to this partner.
  -- Otherwise a typo credits one hospital's families to another's doctor,
  -- and the number would look plausible forever.
  if p_expert_id is not null and not exists (
    select 1 from public.expert_profiles
     where expert_id = p_expert_id and partner_id = p_partner_id
  ) then
    raise exception '% does not belong to %', p_expert_id, p_partner_id;
  end if;

  loop
    v_try := v_try + 1;
    v_token := '';
    for i in 1..10 loop
      v_token := v_token ||
        substr(v_alphabet, 1 + floor(random() * length(v_alphabet))::int, 1);
    end loop;

    exit when not exists (
      select 1 from public.partner_referrals where token = v_token
    );

    if v_try > 20 then
      raise exception 'could not mint a unique token after % attempts', v_try;
    end if;
  end loop;

  insert into public.partner_referrals
    (token, partner_id, campaign_id, channel, expires_at, expert_id)
  values
    (v_token, p_partner_id, p_campaign, coalesce(p_channel, 'qr'),
     p_expires_at, p_expert_id);

  return v_token;
end;
$$;

revoke execute on function public.mint_partner_token(
  text, text, text, timestamptz, text) from public;

-- ⚠️ ROTATION DROPS THE PERSON LAYER, and that is worth knowing before
-- per-doctor codes are printed. rotate_partner_token() (0069) mints ONE
-- replacement for the partner, so a hospital that had a code per
-- clinician comes back from a rotation with a single organisation-wide
-- code and the per-doctor split stops growing.
--
-- Not fixed here, deliberately: rotation is a gate with its own grace
-- window and its own verification, and widening it to remint N tokens is
-- a change to how posters are invalidated rather than to how they are
-- attributed. Recorded in STILL-OPEN. Until then, rotate before handing
-- out per-doctor codes rather than after.


-- ---------------------------------------------------------------------
-- What Apollo can ask. The school and its students, from one table.
--
-- Aggregate for the organisation, breakdown by clinician beside it --
-- the same shape sponsor_dashboard/sponsor_roster give an employer and
-- its staff, and deliberately the same shape, because it is the same
-- question asked of a different kind of customer.
--
-- Note what it does NOT return: no family, no user id, no name. A
-- hospital learns how many it introduced and by whom, never who they
-- are. Same line as the sponsor roster, drawn for the same reason.
-- ---------------------------------------------------------------------
create or replace function public.partner_referral_breakdown()
returns table (
  expert_id     text,
  expert_name   text,
  families      int,
  first_at      timestamptz,
  latest_at     timestamptz
)
language sql stable security definer set search_path = ''
as $$
  select
    a.expert_id,
    coalesce(ep.name, '(the organisation)') as expert_name,
    count(*)::int                            as families,
    min(a.linked_at)                         as first_at,
    max(a.linked_at)                         as latest_at
  from public.partner_attributions a
  left join public.expert_profiles ep on ep.expert_id = a.expert_id
  where public.caller_owns_partner(a.partner_id)
  group by a.expert_id, ep.name
  order by count(*) desc;
$$;

grant execute on function public.partner_referral_breakdown() to authenticated;


-- =====================================================================
-- VERIFY
--
--   -- As a solo doctor: exactly their own id.
--   select * from public.my_expert_ids();
--
--   -- As an organisation with three published doctors: three ids.
--   -- (Link the login first: link_partner_account(uid, 'cp_apollo', 'front desk'))
--
--   -- The roster now says WHICH doctor:
--   select expert_id, title, starts_utc from public.expert_roster();
--
--   -- And an organisation can answer an invitation:
--   -- Apollo has a deliverer row of its own (takes_consults = false):
--   insert into public.programme_experts (programme_id, expert_id, role)
--   values ('<prog>', 'apollo', 'host');
--   select public.respond_to_programme_assignment('<prog>', true);
--     -> accepted
--
--   -- A signed-in PARENT gets nothing from any of it:
--   select count(*) from public.my_expert_ids();     -> 0
--   select count(*) from public.expert_roster();     -> 0
--
-- STILL LAYER TWO, and deliberately not here: per-doctor performance for
-- an organisation -- how many masterclasses, consultations and referrals
-- each of its clinicians delivered. expert_roster() now carries the
-- expert_id that makes it possible, and the shape to copy is
-- sponsor_dashboard/sponsor_roster (0060): aggregates for the
-- organisation, a per-member list beside them. Not built until the base
-- case has been used.
-- =====================================================================
