-- =====================================================================
-- 0134_rotation_keeps_doctor_codes.sql -- a rotation no longer drops the
-- per-doctor codes (STILL-OPEN 5.1b, Partner Editions D3)
-- ---------------------------------------------------------------------
-- THE BUG. Both ways of rotating a partner's codes were written when a
-- partner had exactly one code:
--
--   rotate_partner_token()   (0069, service_role + the panel's SQL)
--   rotate_partner_tokens()  (0055, the panel's confirm-by-retyping gate)
--
-- Each retires EVERY current code for the partner and mints ONE org-wide
-- replacement. A clinic with a code per doctor came back from a rotation
-- holding a single code with no person on it, so every family arriving
-- afterwards attributed with expert_id = NULL and each doctor's count
-- froze. Nothing errored; the number simply stopped moving.
--
-- THE FIX. Rotation now remembers which doctors held a current code it
-- just retired, and mints each of them a fresh one in the same call --
-- the same transaction, so a rotation is never half-done: either the old
-- codes are retired AND every replacement exists, or nothing changed.
--
-- WHO GETS A NEW CODE. A doctor whose code was retired by this rotation,
-- and who STILL belongs to the partner: expert_profiles.partner_id equals
-- it. That is the exact rule my_partner_token() (0133) uses to decide a
-- per-doctor code is hers to hand out, so the two can never disagree --
-- rotation will not mint a code the kit would then refuse to show.
--
-- This answers the question 5.1b left for a human: a doctor who has left
-- the clinic is NOT re-minted. Her old code keeps resolving through the
-- grace window (families still reach the clinic that printed it), then
-- stops. A doctor who never had a per-doctor code is not given one:
-- rotation replaces what was printed, it does not print new things.
--
-- An own-practice doctor's rotation is scoped by partner_id like every
-- other, so rotating her practice touches only her practice's codes --
-- never those of a clinic she also works in.
--
-- WHAT IS UNCHANGED, deliberately (read 0069's header first):
--   * the grace window and its 30-day default (rotate_partner_token);
--   * the required reason;
--   * service_role only -- a partner cannot rotate their own codes;
--   * no parent_timeline row: rotation is our paperwork, not her journey;
--   * the return types (text / jsonb). A changed return type cannot be
--     `create or replace`d, and the panel's Flows read these shapes.
--   * rotate_partner_tokens() still retires instantly (active = false),
--     as 0055 made it. Whether the panel's emergency rotation should get a
--     grace window is a separate decision, not this one.
--
-- A replacement carries channel 'qr' and no campaign, as the org-wide
-- replacement always has. A campaign code is its own artefact
-- (create_partner_campaign) and is minted again on purpose, not by a
-- rotation.
--
-- PREREQ: 0055, 0069, 0073, 0126, 0133.
-- =====================================================================


-- ---------------------------------------------------------------------
-- _remint_doctor_codes(partner, doctors) -- the one place the rule lives
--
-- Both rotations call this, so "who keeps a code" is written once. Two
-- copies of a membership rule is two chances to fix one of them.
--
-- Returns how many codes it minted. Internal: no client may call it.
-- ---------------------------------------------------------------------
create or replace function public._remint_doctor_codes(
  p_partner_id text,
  p_doctors    text[]
)
returns int
language plpgsql
security definer set search_path = ''
as $$
declare
  v_expert text;
  v_n      int := 0;
begin
  for v_expert in
    select distinct d
      from unnest(coalesce(p_doctors, '{}'::text[])) as d
      -- Still belongs here. 0133's my_partner_token() rule, verbatim.
      join public.expert_profiles ep
        on ep.expert_id = d and ep.partner_id = p_partner_id
     where d is not null
     order by d
  loop
    perform public.mint_partner_token(p_partner_id, 'qr', null, null, v_expert);
    v_n := v_n + 1;
  end loop;
  return v_n;
end;
$$;

revoke execute on function public._remint_doctor_codes(text, text[])
  from public, anon, authenticated;


-- ---------------------------------------------------------------------
-- rotate_partner_token(partner, reason, grace) -- 0069 verbatim apart
-- from the lines marked D3. Same signature and return type, so `create or
-- replace` REPLACES it and keeps 0070's directus_cms grant and 0126's
-- revokes.
-- ---------------------------------------------------------------------
create or replace function public.rotate_partner_token(
  p_partner_id  text,
  p_reason      text,
  p_grace_days  int default 30
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_new     text;
  v_doctors text[];                                     -- D3
begin
  if coalesce(trim(p_reason), '') = '' then
    raise exception 'a reason is required: a retired code has to be explainable';
  end if;

  if not exists (
    select 1 from public.care_partners
     where id = p_partner_id and deleted_at is null
  ) then
    raise exception 'no such care partner: %', p_partner_id;
  end if;

  -- D3: note which doctors hold a CURRENT code, before retiring it, so
  -- each gets a replacement. Read first rather than through `returning`,
  -- which would see the new expiry: a code that had already expired on its
  -- own was not on anyone's wall, and is not replaced.
  select array_agg(distinct expert_id) filter (where expert_id is not null)
    into v_doctors
    from public.partner_referrals
   where partner_id = p_partner_id
     and active
     and retired_at is null
     and (expires_at is null or expires_at > now());

  -- Retire the current ones. Kept, never deleted: partner_attributions
  -- records the token it used, and history has to stay reconstructable.
  update public.partner_referrals
     set expires_at     = now() + make_interval(days => greatest(p_grace_days, 0)),
         retired_at     = now(),
         retired_reason = p_reason
   where partner_id = p_partner_id
     and active
     and retired_at is null;

  -- Mint the replacement.
  v_new := public.mint_partner_token(p_partner_id);

  -- D3: and one per doctor who still belongs here.
  perform public._remint_doctor_codes(p_partner_id, v_doctors);

  -- NOTHING is written to parent_timeline, and that is a decision rather
  -- than an omission. Rotation is OUR administrative act, not an event in a
  -- family's journey: a row there would put our paperwork into a mother's
  -- history, and it would inflate "active families" on the partner's own
  -- dashboard, which counts distinct users with recent timeline rows. If
  -- rotation ever needs an audit trail it belongs in its own table.

  -- Still the ORG-WIDE token. The doctors' new codes are read through
  -- partner_token_history(), or by each doctor through my_partner_token().
  return v_new;
end;
$$;

revoke execute on function
  public.rotate_partner_token(text, text, int) from public, anon, authenticated;


-- ---------------------------------------------------------------------
-- rotate_partner_tokens -- 0055 verbatim apart from the lines marked D3.
-- The result gains `reminted`, an added key: a Flow reading `token` and
-- `retired` is unaffected.
-- ---------------------------------------------------------------------
create or replace function public.rotate_partner_tokens(
  p_partner_id text,
  p_confirm    text,
  p_actor      text,
  p_reason     text default null
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_old      int;
  v_new      text;
  v_doctors  text[];                                    -- D3
  v_reminted int;                                       -- D3
  v_args     jsonb := jsonb_build_object('reason', p_reason);
begin
  -- Typing the id IS the confirmation dialog. A boolean would be
  -- defaulted to true by the second caller who found it inconvenient.
  if p_confirm is distinct from p_partner_id then
    return public._refuse(p_actor, 'rotate_partner_tokens',
      'partner_referrals', p_partner_id, 'not_confirmed',
      format('Retype the partner id (%s) to confirm. This invalidates every '
             'printed code for this partner.', p_partner_id), v_args);
  end if;

  if not exists (select 1 from public.care_partners
                  where id = p_partner_id and deleted_at is null) then
    return public._refuse(p_actor, 'rotate_partner_tokens',
      'partner_referrals', p_partner_id, 'no_such_partner',
      format('No care partner %s.', p_partner_id), v_args);
  end if;

  -- D3: the doctors holding a CURRENT code, read before retiring. One
  -- already retired and in its grace window was replaced by an earlier
  -- rotation; one expired on its own was not on anyone's wall.
  select array_agg(distinct expert_id) filter (where expert_id is not null)
    into v_doctors
    from public.partner_referrals
   where partner_id = p_partner_id
     and active
     and retired_at is null
     and (expires_at is null or expires_at > now());

  update public.partner_referrals set active = false
   where partner_id = p_partner_id and active;
  get diagnostics v_old = row_count;

  v_new := public.mint_partner_token(p_partner_id);
  v_reminted := public._remint_doctor_codes(p_partner_id, v_doctors);  -- D3

  return public._allow(p_actor, 'rotate_partner_tokens', 'partner_referrals',
    p_partner_id, 'rotated',
    format('%s code(s) retired; new token %s; %s doctor code(s) reminted.',
           v_old, v_new, v_reminted),
    v_args || jsonb_build_object('retired', v_old, 'new_token', v_new,
                                 'reminted', v_reminted))
    || jsonb_build_object('token', v_new, 'retired', v_old,
                          'reminted', v_reminted);
end;
$$;

revoke execute on function
  public.rotate_partner_tokens(text, text, text, text) from public, anon, authenticated;


-- =====================================================================
-- VERIFY: supabase/seed/verify_rotation.sql. Paste it whole into the SQL
-- editor; it ends in a red "error" that IS the pass/fail report and rolls
-- every fixture back.
-- =====================================================================
