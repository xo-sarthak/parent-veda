-- =====================================================================
-- 0067_employer_benefit_contents.sql -- deciding what an employee
--                                       actually gets.
-- ---------------------------------------------------------------------
-- The engine has been able to express any benefit since 0057, and
-- nothing had decided which one. So an activated employee got "Premium"
-- that unlocked nothing, because the `free` plan grants every capability
-- and always has.
--
-- Decided here, as data, so changing it later is a row rather than a
-- release. That was the point of building it this way -- but an
-- architecture that can express anything and currently expresses
-- nothing is not flexibility, it is an unfinished product.
--
-- ---------------------------------------------------------------------
-- WHAT AN EMPLOYEE GETS: three things, deliberately.
-- ---------------------------------------------------------------------
--
--   1. TWO one-to-one consultations a year.
--   2. Every masterclass, included.
--   3. Nothing else that is bounded.
--
-- WHY TWO CONSULTATIONS, not one and not unlimited. One is a sample and
-- gets saved "for when something is really wrong" -- which means the
-- benefit is never used and HR sees a take-up number with nothing
-- behind it. Unlimited is unbudgetable: a consultation is a real hour
-- of a real clinician, so the cost is linear and the sales conversation
-- becomes about risk rather than value. Two is enough that the first
-- one gets spent on something ordinary, which is when someone learns
-- the benefit is real.
--
-- WHY MASTERCLASSES ARE UNLIMITED. They are recorded and one-to-many:
-- the marginal cost of the tenth attendee is nothing, while the
-- perceived value per person is high. Anything whose cost does not
-- scale with use should be unlimited, because metering it buys nothing
-- and makes the benefit feel mean.
--
-- > The general rule, worth keeping for the next tier: METER WHAT COSTS
-- > YOU PER USE, INCLUDE WHAT DOES NOT. Credits for clinician hours,
-- > open access to recordings. A pricing model that ignores this either
-- > bleeds on the hours or insults people over the recordings.
--
-- WHAT IS DELIBERATELY REMOVED. `sponsor_events` and
-- `sponsor_resources` were seeded into the plan in 0058 and there is
-- nothing behind either: `programmes` has no sponsor audience scope, so
-- the Employer Benefits screen rendered two sections saying "nothing
-- scheduled yet". A capability that grants access to an empty set is a
-- promise the product does not keep, and it is worse than an absent
-- feature because someone reads it as a feature. Removed from the plan
-- here; re-add the row the day a sponsor actually runs a session.
-- (STILL-OPEN 11.9.)
--
-- PREREQ: 0057, 0058, 0066 (consult_credits).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The employer plan says exactly what it grants.
--
-- 0058 seeded it with `select id from public.capabilities`, which was
-- the right move for a plan nobody had decided yet and the wrong shape
-- to keep: it silently meant "everything, forever, including whatever
-- gets registered next". Replaced with an explicit list.
-- ---------------------------------------------------------------------
delete from public.plan_capabilities where plan_id = 'employer_standard';

insert into public.plan_capabilities (plan_id, capability_id) values
  ('employer_standard', 'consultation_credit'),
  ('employer_standard', 'masterclass_access'),
  -- Kept: an employer that pays for this may tell its people so. It
  -- costs nothing and there IS something behind it -- the benefits
  -- screen itself.
  ('employer_standard', 'sponsor_announcements')
on conflict do nothing;

-- Same reasoning applied to `free`. 0057 granted it every capability so
-- the migration would change nothing on the day it ran, which was
-- correct then and is now the thing making Premium meaningless: a
-- capability every plan grants answers no question. Made explicit, and
-- consultation credits are removed from it -- a free user has never had
-- one, because nothing grants them any.
delete from public.plan_capabilities where plan_id = 'free';

insert into public.plan_capabilities (plan_id, capability_id) values
  ('free', 'masterclass_access')
on conflict do nothing;

-- ⚠️ NOTE WHAT THIS DOES NOT DO. It does not put masterclasses behind a
-- paywall for free users -- they keep them. Nothing in the app is newly
-- locked by this migration, which is the property that makes it safe to
-- run on a live database. The DIFFERENCE the employer plan buys is the
-- consultations, which is a thing free users never had rather than a
-- thing being taken away. Deciding to meter masterclasses later is
-- deleting the 'free' row above; doing it here would be a product
-- decision smuggled into a plumbing migration.


-- ---------------------------------------------------------------------
-- 2. Activating grants the consultations.
--
-- Replaces 0061's version. The only change is the grant_consult_credits
-- call after grant_plan; everything else is verbatim, kept whole so the
-- newest file is the readable truth.
-- ---------------------------------------------------------------------
create or replace function public.confirm_sponsor_activation(
  p_work_email text,
  p_code       text
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_email  text := lower(trim(p_work_email));
  v_row    record;
  v_uid    uuid := auth.uid();
  v_used   int;
  v_spons  public.sponsors;
  v_now    public.sponsors;
  v_given  text := trim(p_code);
  v_bypass boolean := false;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'code', 'not_signed_in',
      'message', 'Sign in first, then activate your employer benefit.');
  end if;

  select * into v_row from public.sponsor_activation_codes
   where lower(work_email) = v_email and consumed_at is null
   order by created_at desc limit 1;

  if v_row.id is null then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', null, 'no_pending_code', 'Request a new code.');
  end if;

  if v_row.expires_at < now() then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_row.sponsor_id, 'code_expired',
      'That code has expired. Request a new one.');
  end if;

  select * into v_spons from public.sponsors where id = v_row.sponsor_id;

  update public.sponsor_activation_codes
     set attempts = attempts + 1 where id = v_row.id;

  if v_row.attempts + 1 > 5 then
    update public.sponsor_activation_codes
       set consumed_at = now() where id = v_row.id;
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_row.sponsor_id, 'too_many_attempts',
      'Too many incorrect codes. Request a new one.');
  end if;

  v_bypass := v_spons.dev_bypass_code is not null
              and v_given = v_spons.dev_bypass_code;

  if v_row.code <> v_given and not v_bypass then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_row.sponsor_id, 'wrong_code',
      'That code is not right.');
  end if;

  if v_spons.status <> 'active' then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_spons.id, 'sponsor_inactive',
      'This benefit is no longer active.');
  end if;

  v_now := public.sponsor_for_work_email(v_email);
  if v_now.id is null or v_now.id <> v_spons.id then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_spons.id, 'not_eligible',
      'We could not find a benefit for that email address.');
  end if;

  if v_spons.seats_purchased is not null then
    select count(*) into v_used from public.sponsor_members
     where sponsor_id = v_spons.id and status = 'active';
    if v_used >= v_spons.seats_purchased then
      return public._refuse(v_uid::text, 'confirm_sponsor_activation',
        'sponsor_members', v_spons.id, 'no_seats_left',
        'All the seats your organisation purchased are in use.');
    end if;
  end if;

  update public.sponsor_activation_codes
     set consumed_at = now() where id = v_row.id;

  insert into public.sponsor_members (user_id, sponsor_id, work_email)
  values (v_uid, v_spons.id, v_email)
  on conflict (user_id, sponsor_id) do update
    set status = 'active', activated_at = now(), removed_at = null;

  perform public.grant_plan(v_uid, v_spons.plan_id, 'sponsor', v_spons.id,
                            null, v_uid::text);

  -- THE CONSULTATIONS. Idempotent by (user, 'sponsor:<id>', seq), so
  -- re-activating after leaving and rejoining does not mint a second
  -- pair -- and re-running this whole function cannot either.
  perform public.grant_consult_credits(
    v_uid, 2, 'sponsor', v_spons.id, v_uid::text);

  return public._allow(v_uid::text, 'confirm_sponsor_activation',
    'sponsor_members', v_spons.id,
    case when v_bypass then 'activated_dev_bypass' else 'activated' end,
    format('Welcome. Your benefit is provided by %s.', v_spons.name),
    jsonb_build_object('sponsor', v_spons.id, 'plan', v_spons.plan_id,
                       'bypass', v_bypass, 'credits', 2));
end;
$$;

grant execute on function
  public.confirm_sponsor_activation(text, text) to authenticated;


-- ---------------------------------------------------------------------
-- 3. Leaving takes back the unspent one.
--
-- Replaces 0058's remove_sponsor_member. It already revoked the plan;
-- now it also withdraws unspent credits, because a consultation nobody
-- is paying for should not stay bookable. A booked one survives -- see
-- void_consult_credits.
-- ---------------------------------------------------------------------
create or replace function public.remove_sponsor_member(
  p_sponsor_id text,
  p_user_id    uuid,
  p_actor      text
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare v_n int;
begin
  update public.sponsor_members
     set status = 'removed', removed_at = now()
   where sponsor_id = p_sponsor_id and user_id = p_user_id and status = 'active';
  get diagnostics v_n = row_count;

  if v_n = 0 then
    return public._refuse(p_actor, 'remove_sponsor_member', 'sponsor_members',
      p_sponsor_id, 'not_a_member', 'That person is not an active member.');
  end if;

  perform public.revoke_plan_by_source(p_user_id, 'sponsor', p_sponsor_id,
                                       p_actor);
  perform public.void_consult_credits(p_user_id, 'sponsor', p_sponsor_id,
                                      p_actor, 'no longer covered');

  return public._allow(p_actor, 'remove_sponsor_member', 'sponsor_members',
    p_sponsor_id, 'removed',
    'Member removed. Their sponsored plan and any unbooked consultation are '
    'withdrawn; anything already booked stands.',
    jsonb_build_object('user', p_user_id));
end;
$$;

revoke execute on function
  public.remove_sponsor_member(text, uuid, text) from public;


-- =====================================================================
-- VERIFY
--
--   -- The employer plan grants exactly three things:
--   select capability_id from public.plan_capabilities
--    where plan_id = 'employer_standard' order by 1;
--     -> consultation_credit, masterclass_access, sponsor_announcements
--
--   -- Nothing is newly locked for a free user:
--   select capability_id from public.plan_capabilities where plan_id = 'free';
--     -> masterclass_access
--
--   -- Activating grants two, and twice grants two:
--   select public.my_consult_credits();   -- as the activated user
--     -> available: 2
-- =====================================================================
