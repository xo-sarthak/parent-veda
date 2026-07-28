-- =====================================================================
-- 0055_gates_return_refusals.sql -- make refusals survive being refused.
-- ---------------------------------------------------------------------
-- THE DEFECT (STILL-OPEN 4.4a, proved by verify_admin_gates.sql: 17
-- passed, 1 failed).
--
-- Every gate in 0051/0054 did:
--
--     perform public._audit(... 'refused' ...);
--     raise exception '...';
--
-- The raise aborts the transaction, which rolls back the audit insert
-- made one line earlier. So successes were logged and refusals were
-- not -- exactly backwards, because the blocked attempts are the rows an
-- audit log exists for. "Who approved this doctor" was answerable;
-- "who tried and was stopped" was not.
--
-- THE FIX: return the refusal instead of raising it. Nothing aborts, so
-- the audit row commits with the call.
--
--     { "ok": false, "code": "incomplete_verification", "message": "..." }
--     { "ok": true,  "code": "approved",  "message": "..." }
--
-- THE TRADE-OFF, STATED PLAINLY. A raise makes a careless caller fail
-- loudly: PostgREST returns 4xx and a Directus Flow errors on its own. A
-- returned `{ok:false}` is HTTP 200, so a Flow that ignores the body
-- will report success for an approval that never happened.
--
-- We accept that because the two failures are not equal. A Flow that
-- does not check its result is a Flow bug, visible the first time
-- somebody looks, and fixable in the Flow. Losing the audit row is a
-- design defect that no Flow can compensate for -- the evidence is
-- simply gone. docs/DIRECTUS-SETUP.md §5d already requires the Flow to
-- assert on the response; that requirement is now load-bearing.
--
-- Return type changes from text to jsonb, which CREATE OR REPLACE cannot
-- do, so each function is dropped and recreated. Nothing in either app
-- calls these -- they are service_role only -- so dropping is safe.
--
-- NOT CHANGED: respond_to_programme_assignment(). Its failure paths
-- ("not an expert account", "no open invitation") never wrote an audit
-- row in the first place, so raising loses nothing, and the app calling
-- it is better served by an exception.
--
-- PREREQ: 0050, 0051, 0052, 0054.
-- =====================================================================


-- ---------------------------------------------------------------------
-- Two helpers, so every gate reads the same way and no refusal can
-- forget to record itself.
-- ---------------------------------------------------------------------
create or replace function public._refuse(
  p_actor text, p_action text, p_table text, p_target text,
  p_code text, p_message text, p_args jsonb default '{}'::jsonb
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
begin
  perform public._audit(p_actor, p_action, p_table, p_target,
                        coalesce(p_args, '{}'::jsonb), 'refused', p_code);
  return jsonb_build_object('ok', false, 'code', p_code, 'message', p_message);
end;
$$;

create or replace function public._allow(
  p_actor text, p_action text, p_table text, p_target text,
  p_code text, p_message text, p_args jsonb default '{}'::jsonb
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
begin
  perform public._audit(p_actor, p_action, p_table, p_target,
                        coalesce(p_args, '{}'::jsonb), 'ok', p_code);
  return jsonb_build_object('ok', true, 'code', p_code, 'message', p_message);
end;
$$;

revoke execute on function
  public._refuse(text, text, text, text, text, text, jsonb) from public;
revoke execute on function
  public._allow(text, text, text, text, text, text, jsonb) from public;


-- ---------------------------------------------------------------------
-- approve_care_partner
-- ---------------------------------------------------------------------
drop function if exists public.approve_care_partner(text, text, text);

create or replace function public.approve_care_partner(
  p_partner_id text,
  p_actor      text,
  p_note       text default null
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_status text;
  v        record;
  v_args   jsonb := jsonb_build_object('note', p_note);
begin
  select status into v_status
    from public.care_partners
   where id = p_partner_id and deleted_at is null;

  if v_status is null then
    return public._refuse(p_actor, 'approve_care_partner', 'care_partners',
      p_partner_id, 'no_such_partner',
      format('No care partner %s.', p_partner_id), v_args);
  end if;

  if v_status = 'active' then
    return public._allow(p_actor, 'approve_care_partner', 'care_partners',
      p_partner_id, 'already_active',
      'Already active; nothing changed.', v_args);
  end if;

  select * into v from public.care_partner_verification
   where partner_id = p_partner_id;

  if v.partner_id is null then
    return public._refuse(p_actor, 'approve_care_partner', 'care_partners',
      p_partner_id, 'no_verification_record',
      'Capture the council, registration number and KYC reference first.',
      v_args);
  end if;

  if coalesce(trim(v.council), '') = ''
     or coalesce(trim(v.registration_number), '') = ''
     or coalesce(trim(v.kyc_reference), '') = '' then
    return public._refuse(p_actor, 'approve_care_partner', 'care_partners',
      p_partner_id, 'incomplete_verification',
      format('Verification incomplete (council=%s, registration=%s, kyc=%s).',
        coalesce(nullif(trim(v.council), ''), 'MISSING'),
        coalesce(nullif(trim(v.registration_number), ''), 'MISSING'),
        coalesce(nullif(trim(v.kyc_reference), ''), 'MISSING')), v_args);
  end if;

  if v.registration_expires_at is not null
     and v.registration_expires_at < current_date then
    return public._refuse(p_actor, 'approve_care_partner', 'care_partners',
      p_partner_id, 'registration_expired',
      format('Medical registration expired on %s.', v.registration_expires_at),
      v_args);
  end if;

  update public.care_partners
     set status = 'active', verified_at = now(), updated_at = now()
   where id = p_partner_id;

  update public.care_partner_verification
     set reviewed_by = p_actor, reviewed_at = now(),
         review_note = p_note, updated_at = now()
   where partner_id = p_partner_id;

  return public._allow(p_actor, 'approve_care_partner', 'care_partners',
    p_partner_id, 'approved', 'Partner approved.', v_args);
end;
$$;

revoke execute on function
  public.approve_care_partner(text, text, text) from public;


-- ---------------------------------------------------------------------
-- deactivate_care_partner -- soft, always.
-- ---------------------------------------------------------------------
drop function if exists public.deactivate_care_partner(text, text, text);

create or replace function public.deactivate_care_partner(
  p_partner_id text,
  p_actor      text,
  p_reason     text default null
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_n    int;
  v_args jsonb := jsonb_build_object('reason', p_reason);
begin
  update public.care_partners
     set status = 'inactive', updated_at = now()
   where id = p_partner_id and deleted_at is null;
  get diagnostics v_n = row_count;

  if v_n = 0 then
    return public._refuse(p_actor, 'deactivate_care_partner', 'care_partners',
      p_partner_id, 'no_such_partner',
      format('No care partner %s.', p_partner_id), v_args);
  end if;

  -- Printed codes stop resolving. Attribution rows are untouched: the
  -- families this partner introduced are still their families.
  update public.partner_referrals set active = false
   where partner_id = p_partner_id;

  return public._allow(p_actor, 'deactivate_care_partner', 'care_partners',
    p_partner_id, 'deactivated', 'Partner deactivated; history kept.', v_args);
end;
$$;

revoke execute on function
  public.deactivate_care_partner(text, text, text) from public;


-- ---------------------------------------------------------------------
-- create_partner_campaign
-- ---------------------------------------------------------------------
drop function if exists public.create_partner_campaign(
  text, text, text, timestamptz, text);

create or replace function public.create_partner_campaign(
  p_partner_id text,
  p_campaign   text,
  p_channel    text default 'qr',
  p_expires_at timestamptz default null,
  p_actor      text default 'unknown'
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_token  text;
  v_status text;
  v_args   jsonb := jsonb_build_object(
              'partner', p_partner_id, 'campaign', p_campaign,
              'channel', p_channel);
begin
  select status into v_status
    from public.care_partners
   where id = p_partner_id and deleted_at is null;

  -- A campaign for an unapproved partner prints a code that acquires
  -- families in our name before we vouched for them.
  if v_status is distinct from 'active' then
    return public._refuse(p_actor, 'create_partner_campaign',
      'partner_referrals', p_partner_id, 'partner_not_active',
      format('Partner is %s, not active.', coalesce(v_status, 'missing')),
      v_args);
  end if;

  v_token := public.mint_partner_token(
    p_partner_id, coalesce(p_channel, 'qr'), p_campaign, p_expires_at);

  return public._allow(p_actor, 'create_partner_campaign',
    'partner_referrals', v_token, 'campaign_created',
    format('Token %s minted.', v_token),
    v_args || jsonb_build_object('token', v_token))
    || jsonb_build_object('token', v_token);
end;
$$;

revoke execute on function public.create_partner_campaign(
  text, text, text, timestamptz, text) from public;


-- ---------------------------------------------------------------------
-- rotate_partner_tokens -- still requires the id to be retyped.
-- ---------------------------------------------------------------------
drop function if exists public.rotate_partner_tokens(text, text, text, text);

create or replace function public.rotate_partner_tokens(
  p_partner_id text,
  p_confirm    text,
  p_actor      text,
  p_reason     text default null
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_old  int;
  v_new  text;
  v_args jsonb := jsonb_build_object('reason', p_reason);
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

  update public.partner_referrals set active = false
   where partner_id = p_partner_id and active;
  get diagnostics v_old = row_count;

  v_new := public.mint_partner_token(p_partner_id);

  return public._allow(p_actor, 'rotate_partner_tokens', 'partner_referrals',
    p_partner_id, 'rotated',
    format('%s code(s) retired; new token %s.', v_old, v_new),
    v_args || jsonb_build_object('retired', v_old, 'new_token', v_new))
    || jsonb_build_object('token', v_new, 'retired', v_old);
end;
$$;

revoke execute on function
  public.rotate_partner_tokens(text, text, text, text) from public;


-- ---------------------------------------------------------------------
-- remove_demo_partners
-- ---------------------------------------------------------------------
drop function if exists public.remove_demo_partners(text);

create or replace function public.remove_demo_partners(p_actor text)
returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_attr int;
  v_ledg int;
  v_n    int;
begin
  select count(*) into v_attr from public.partner_attributions
   where partner_id like 'demo\_%';
  select count(*) into v_ledg from public.commission_ledger
   where partner_id like 'demo\_%';

  -- A demo partner carrying a real attribution is no longer only demo
  -- data, and deleting it would take a real attribution with it.
  if v_attr > 0 or v_ledg > 0 then
    return public._refuse(p_actor, 'remove_demo_partners', 'care_partners',
      null, 'demo_has_real_history',
      format('%s attribution(s) and %s ledger row(s) are attached to demo '
             'partners. Resolve that first.', v_attr, v_ledg),
      jsonb_build_object('attributions', v_attr, 'ledger', v_ledg));
  end if;

  delete from public.partner_referrals where partner_id like 'demo\_%';
  delete from public.care_partners     where id         like 'demo\_%';
  get diagnostics v_n = row_count;

  return public._allow(p_actor, 'remove_demo_partners', 'care_partners',
    null, 'removed', format('%s demo partner(s) removed.', v_n),
    jsonb_build_object('deleted', v_n));
end;
$$;

revoke execute on function public.remove_demo_partners(text) from public;


-- ---------------------------------------------------------------------
-- assign_programme_expert
-- ---------------------------------------------------------------------
drop function if exists public.assign_programme_expert(text, text, text, text);

create or replace function public.assign_programme_expert(
  p_programme_id text,
  p_expert_id    text,
  p_actor        text,
  p_role         text default 'host'
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_args jsonb := jsonb_build_object('expert', p_expert_id, 'role', p_role);
begin
  if not exists (select 1 from public.programmes where id = p_programme_id) then
    return public._refuse(p_actor, 'assign_programme_expert', 'programmes',
      p_programme_id, 'no_such_programme',
      format('No programme %s.', p_programme_id), v_args);
  end if;

  insert into public.programme_experts (programme_id, expert_id, role)
  values (p_programme_id, p_expert_id, coalesce(p_role, 'host'))
  on conflict (programme_id, expert_id) do update
    set role = excluded.role, status = 'invited',
        invited_at = now(), responded_at = null;

  return public._allow(p_actor, 'assign_programme_expert', 'programmes',
    p_programme_id, 'invited',
    'Invitation sent; the expert must accept before publishing.', v_args);
end;
$$;

revoke execute on function
  public.assign_programme_expert(text, text, text, text) from public;


-- ---------------------------------------------------------------------
-- publish_programme -- five gates, all now recorded when they fire.
-- ---------------------------------------------------------------------
drop function if exists public.publish_programme(text, text);

create or replace function public.publish_programme(
  p_programme_id text,
  p_actor        text
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_status   text;
  v_sessions int;
  v_past     int;
  v_accepted int;
begin
  select status into v_status from public.programmes where id = p_programme_id;

  if v_status is null then
    return public._refuse(p_actor, 'publish_programme', 'programmes',
      p_programme_id, 'no_such_programme',
      format('No programme %s.', p_programme_id));
  end if;

  if v_status = 'published' then
    return public._allow(p_actor, 'publish_programme', 'programmes',
      p_programme_id, 'already_published', 'Already published.');
  end if;

  select count(*), count(*) filter (where starts_utc <= now())
    into v_sessions, v_past
    from public.programme_sessions where programme_id = p_programme_id;

  select count(*) into v_accepted from public.programme_experts
   where programme_id = p_programme_id and status = 'accepted';

  if v_sessions = 0 then
    return public._refuse(p_actor, 'publish_programme', 'programmes',
      p_programme_id, 'no_sessions', 'It has no sessions.');
  end if;

  if v_past > 0 then
    return public._refuse(p_actor, 'publish_programme', 'programmes',
      p_programme_id, 'session_in_past',
      format('%s session(s) start in the past.', v_past));
  end if;

  if v_accepted = 0 then
    return public._refuse(p_actor, 'publish_programme', 'programmes',
      p_programme_id, 'no_accepted_expert',
      'No expert has accepted. Selling seats to a session nobody agreed to '
      'run is the failure this check exists for.');
  end if;

  if v_status not in ('marketing_review', 'scheduled') then
    return public._refuse(p_actor, 'publish_programme', 'programmes',
      p_programme_id, 'not_reviewed',
      format('Status is "%s"; it must pass medical_review and '
             'marketing_review first.', v_status),
      jsonb_build_object('status', v_status));
  end if;

  update public.programmes
     set status = 'published', published_at = now(), updated_at = now()
   where id = p_programme_id;

  -- book_slot() (0029) stays the ONE seat authority.
  insert into public.booking_slots
    (id, offering_id, expert_id, starts_utc, duration_min, capacity, join_url)
  select 'ps_' || s.id, p_programme_id,
         (select expert_id from public.programme_experts
           where programme_id = p_programme_id and status = 'accepted'
           order by invited_at limit 1),
         s.starts_utc, s.duration_min,
         coalesce(s.capacity, (select capacity from public.programmes
                                where id = p_programme_id), 100),
         s.join_url
    from public.programme_sessions s
   where s.programme_id = p_programme_id
  on conflict (id) do nothing;

  return public._allow(p_actor, 'publish_programme', 'programmes',
    p_programme_id, 'published', format('Published with %s session(s).', v_sessions),
    jsonb_build_object('sessions', v_sessions));
end;
$$;

revoke execute on function public.publish_programme(text, text) from public;


-- =====================================================================
-- THE CALLER'S CONTRACT HAS CHANGED
--
-- These no longer raise. A Directus Flow MUST branch on the result:
--
--     {{$last.ok}} === false   ->  treat as failure, surface $last.message
--
-- A Flow that ignores the body will report success for an approval that
-- never happened. That is now the only way this can go wrong, and it is
-- visible the first time anyone looks -- unlike the audit rows, which
-- were simply gone.
--
-- VERIFY: re-run supabase/seed/verify_admin_gates.sql. It should now
-- report 18 passed, 0 failed, including "refusals recorded in
-- admin_audit".
-- =====================================================================
