-- =====================================================================
-- 0133_my_doctor_referrals.sql -- a doctor sees the families SHE brought,
-- and her kit carries HER code
-- ---------------------------------------------------------------------
-- Partner Editions D2 (docs/partner-editions/DOCTOR-APP.md). Three fixes,
-- one theme: the person layer 0073 added to referrals was written down and
-- then never used.
--
-- 1. ATTRIBUTION NEVER COPIED THE PERSON. 0073 added expert_id to both
--    partner_referrals (who handed this code over) and
--    partner_attributions (who introduced this family), and documented the
--    second as "copied from the token at attribution time". Nothing copied
--    it: attribute_to_partner (0039) was never touched again, so every
--    attribution row has expert_id null and partner_referral_breakdown()
--    files every family under "(the organisation)". A per-doctor count
--    built on that column would have read zero forever, and looked right.
--    Fixed below, plus a backfill -- attribution stores the token it used,
--    so who handed it over is recoverable for every family already here.
--
-- 2. my_doctor_referrals() -- the doctor's own slice (R4). A doctor inside
--    a clinic sees families from HER code, never the whole clinic's.
--    caller_owns_partner() is deliberately left alone: widening it would
--    hand every member doctor the clinic's totals and earnings.
--
-- 3. my_partner_token() returns the caller's OWN code. Before this, an
--    organisation login whose partner row happened to carry a doctor's
--    per-doctor token could be shown that doctor's code as "your code", and
--    a member doctor was shown nothing at all.
--
-- PREREQ: 0029 (bookings), 0037, 0039, 0069, 0073.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. attribute_to_partner -- now records who handed the code over
--
-- 0039's body verbatim except for three lines, each marked D2. Same
-- five-argument signature, so `create or replace` REPLACES it rather than
-- adding an overload (the trap 0073 describes for mint_partner_token).
-- ---------------------------------------------------------------------
create or replace function public.attribute_to_partner(
  p_token text,
  p_channel text default 'qr',
  p_campaign text default null,
  p_scanned_at timestamptz default null,
  p_installed_at timestamptz default null
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_me        uuid := auth.uid();
  v_ref       public.partner_referrals%rowtype;
  v_partner   public.care_partners%rowtype;
  v_now       timestamptz := now();
  v_scanned   timestamptz;
  v_installed timestamptz;
begin
  if v_me is null then return 'not_signed_in'; end if;

  select * into v_ref from public.partner_referrals
   where token = upper(trim(p_token)) and active;
  if not found then return 'unknown_token'; end if;

  if v_ref.expires_at is not null and v_ref.expires_at < now() then
    return 'expired';
  end if;

  select * into v_partner from public.care_partners
   where id = v_ref.partner_id and deleted_at is null;
  if not found then return 'unknown_partner'; end if;
  if v_partner.status <> 'active' then return 'partner_not_active'; end if;

  -- Self-referral: the partner's own expert account scanning their own QR.
  -- D2: or a member doctor scanning the per-doctor code that names her --
  -- the partner row is the clinic's, so the first check alone missed her.
  if exists (
       select 1 from public.expert_accounts ea
        where ea.user_id = v_me
          and ea.expert_id in (v_partner.expert_id, v_ref.expert_id)
     ) then
    return 'self_referral';
  end if;

  if exists (select 1 from public.partner_attributions where user_id = v_me) then
    return 'already_attributed';
  end if;

  v_scanned := least(greatest(p_scanned_at, v_ref.created_at), v_now);
  v_installed := least(greatest(p_installed_at, v_scanned, v_ref.created_at), v_now);

  insert into public.partner_attributions
    (user_id, partner_id, token, channel, campaign_id,
     scanned_at, installed_at, signed_up_at,
     expert_id)                                              -- D2
  values
    (v_me, v_partner.id, v_ref.token, coalesce(p_channel, v_ref.channel),
     coalesce(p_campaign, v_ref.campaign_id),
     v_scanned, v_installed, v_now,
     v_ref.expert_id);                                       -- D2

  if v_scanned is not null then
    insert into public.parent_timeline (user_id, partner_id, event, detail, at)
    values (v_me, v_partner.id, 'referral_scanned',
            coalesce(p_channel, v_ref.channel), v_scanned);
  end if;
  if v_installed is not null then
    insert into public.parent_timeline (user_id, partner_id, event, detail, at)
    values (v_me, v_partner.id, 'app_installed', null, v_installed);
  end if;
  insert into public.parent_timeline (user_id, partner_id, event, detail, at)
  values (v_me, v_partner.id, 'signup_completed', null, v_now);

  insert into public.parent_timeline (user_id, partner_id, event, detail)
  values (v_me, v_partner.id, 'attributed', coalesce(p_channel, v_ref.channel));

  return 'ok';
exception
  when unique_violation then return 'already_attributed';
end;
$$;

grant execute on function
  public.attribute_to_partner(text, text, text, timestamptz, timestamptz)
  to authenticated;

-- The three-argument form from 0037 is still callable by an older build, and
-- its own body writes the attribution WITHOUT the person. Rather than keep two
-- copies of the rule, it now forwards to the five-argument form. The two nulls
-- are typed and all five are passed, so the call names one function. The
-- defaults stay exactly as 0037 declared them: `create or replace` refuses to
-- remove a parameter default ("cannot remove parameter defaults from existing
-- function"), so dropping them would fail the whole migration.
create or replace function public.attribute_to_partner(
  p_token text,
  p_channel text default 'qr',
  p_campaign text default null
)
returns text
language sql
security definer set search_path = ''
as $$
  select public.attribute_to_partner(
    p_token, p_channel, p_campaign, null::timestamptz, null::timestamptz);
$$;

grant execute on function public.attribute_to_partner(text, text, text)
  to authenticated;


-- Backfill. Every attribution stores the token it used, and every token
-- stores who handed it over, so the missing column is a join away. Only
-- fills nulls: an attribution is frozen history and is never rewritten.
update public.partner_attributions a
   set expert_id = r.expert_id
  from public.partner_referrals r
 where r.token = a.token
   and r.expert_id is not null
   and a.expert_id is null;


-- ---------------------------------------------------------------------
-- 2. my_doctor_referrals() -- "families you brought", the doctor's slice
--
-- WHO counts as "me": the caller's own expert account (expert_accounts),
-- and ONLY that. Not my_expert_ids(), whose route B hands an organisation
-- login every doctor under it -- R4 says an org login gets nothing here; the
-- clinic's view is partner_impact and, later, the Partners app.
--
-- WHICH families are hers:
--   * a family whose attribution names her (her per-doctor code), or
--   * a family who came through her OWN practice's org-wide code
--     (care_partners.expert_id = her, token with no person on it).
-- For a solo doctor that is every family of her partner row, so the
-- numbers equal partner_impact / partner_funnel. For a founder whose
-- practice row also carries colleagues' per-doctor codes, it is hers plus
-- the practice-wide code, never the colleagues'.
--
-- COUNTS ONLY, as every partner read since 0037: no user id leaves this
-- function, and a caller with no expert account gets one row of zeros.
-- These are referral facts (R3), so they are not hidden below 5.
-- ---------------------------------------------------------------------
create or replace function public.my_doctor_referrals()
returns table (
  scanned     bigint,
  installed   bigint,
  signed_up   bigint,
  active_30d  bigint,
  booked_me   bigint
)
language sql
stable
security definer set search_path = ''
as $$
  with me as (
    select ea.expert_id
      from public.expert_accounts ea
     where ea.user_id = auth.uid()
  ),
  fam as (
    select a.user_id, a.scanned_at, a.installed_at, a.signed_up_at
      from public.partner_attributions a
      left join public.care_partners cp on cp.id = a.partner_id
     where a.expert_id in (select expert_id from me)
        or (a.expert_id is null and cp.expert_id in (select expert_id from me))
  )
  select
    (select count(*) from fam where scanned_at is not null),
    (select count(*) from fam where installed_at is not null),
    (select count(*) from fam where signed_up_at is not null),
    -- The same definition as partner_impact.active_this_month, so a solo
    -- doctor reads one number in both places.
    (select count(distinct t.user_id) from public.parent_timeline t
      where t.user_id in (select user_id from fam)
        and t.at > now() - interval '30 days'),
    -- Families she brought who went on to book HER. A cancelled booking is
    -- not a booking.
    (select count(distinct b.user_id)
       from public.booking_bookings b
       join public.booking_slots s on s.id = b.slot_id
      where b.user_id in (select user_id from fam)
        and s.expert_id in (select expert_id from me)
        and b.status <> 'cancelled');
$$;

revoke execute on function public.my_doctor_referrals() from public, anon;
grant execute on function public.my_doctor_referrals() to authenticated;


-- ---------------------------------------------------------------------
-- 3. my_partner_token() -- the caller's OWN current code (R4)
--
-- Three candidates, best first:
--   1. a doctor's per-doctor code (expert_id = her), but only while she
--      still belongs to the partner it was minted under -- a code from a
--      clinic she has left credits that clinic, not her;
--   2. a doctor's own-practice code (partner.expert_id = her, no person);
--   3. an organisation login's org-wide code (expert_id is null).
-- An organisation login never reaches 1 or 2, because it has no expert
-- account. "Current" is unchanged from 0069: active, never retired, not
-- past its expiry -- a retired code in its grace window still resolves for
-- a patient, but is never handed out again.
-- ---------------------------------------------------------------------
create or replace function public.my_partner_token()
returns text
language sql
stable
security definer set search_path = ''
as $$
  with me as (
    select ea.expert_id
      from public.expert_accounts ea
     where ea.user_id = auth.uid()
  ),
  cur as (
    select pr.token, pr.partner_id, pr.expert_id, pr.created_at,
           cp.expert_id as partner_expert_id
      from public.partner_referrals pr
      join public.care_partners cp on cp.id = pr.partner_id
     where cp.deleted_at is null
       and pr.active
       and pr.retired_at is null
       and (pr.expires_at is null or pr.expires_at > now())
  )
  select x.token from (
    select c.token, 1 as rank, c.created_at
      from cur c
      join public.expert_profiles ep
        on ep.expert_id = c.expert_id and ep.partner_id = c.partner_id
     where c.expert_id in (select expert_id from me)
    union all
    select c.token, 2, c.created_at
      from cur c
     where c.expert_id is null
       and c.partner_expert_id in (select expert_id from me)
    union all
    select c.token, 3, c.created_at
      from cur c
      join public.partner_accounts pa
        on pa.partner_id = c.partner_id and pa.user_id = auth.uid()
     where c.expert_id is null
  ) x
  order by x.rank, x.created_at desc
  limit 1;
$$;

grant execute on function public.my_partner_token() to authenticated;


-- =====================================================================
-- VERIFY (run in the SQL editor; `set request.jwt.claims` to act as a user)
--
--   -- 1. Nothing left to backfill:
--   select count(*) from public.partner_attributions a
--     join public.partner_referrals r on r.token = a.token
--    where r.expert_id is not null and a.expert_id is null;      -- 0
--
--   -- 2. Parity for a SOLO doctor (as her):
--   select signed_up, active_30d from public.my_doctor_referrals();
--   select signed_up from public.partner_funnel('<her partner id>');
--   select active_this_month from public.partner_impact('<her partner id>');
--   -- signed_up = signed_up, active_30d = active_this_month.
--
--   -- 3. As an organisation login: one row of zeros, and a token whose
--   --    partner_referrals.expert_id is null.
--   select * from public.my_doctor_referrals();
--   select r.expert_id from public.partner_referrals r
--    where r.token = public.my_partner_token();                  -- null
-- =====================================================================
