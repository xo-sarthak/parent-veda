-- =====================================================================
-- 0051_admin_actions.sql -- the acts a panel performs, as functions the
--                           database will refuse.
-- ---------------------------------------------------------------------
-- Everything here is a `security definer` function with execute revoked
-- from public and granted to service_role alone. Directus Flows call
-- them over PostgREST; the doctor app and the parent app physically
-- cannot, regardless of what any panel is configured to allow.
--
-- THE POINT IS THE REFUSAL, NOT THE UPDATE.
--
-- Approving a doctor could be a status dropdown. It must not be. A
-- dropdown lets an unverified professional be approved in one click by
-- someone who assumed the checks happened elsewhere - and an approved
-- partner is one ParentVeda has told parents to trust, whose QR goes on
-- a clinic wall, and who acquires families in our name.
--
-- So the rules live in the function: it reads the paperwork, and it
-- raises rather than proceeds. The refusal is the feature. Every call,
-- allowed or refused, writes admin_audit before returning.
--
-- WHAT IS DELIBERATELY NOT HERE
--
--   * Commission writing. That belongs to an edge function on payment
--     settlement, and no rate has been agreed - 0038 seeds every rate at
--     zero. A payout run over an empty ledger would be theatre.
--   * A second way to mint a token. 0040 owns that, for a reason written
--     on a poster somewhere: a derived token that resolved to no row
--     scanned, looked correct, and credited nobody for two years.
--
-- PREREQ: 0037, 0040, 0045, 0050.
-- =====================================================================


-- ---------------------------------------------------------------------
-- Shared: write the audit row. Internal - not granted to anyone.
-- ---------------------------------------------------------------------
create or replace function public._audit(
  p_actor   text,
  p_action  text,
  p_table   text,
  p_target  text,
  p_args    jsonb default '{}'::jsonb,
  p_outcome text default 'ok',
  p_detail  text default null
) returns void
language sql security definer set search_path = ''
as $$
  insert into public.admin_audit
    (actor, action, target_table, target_id, args, outcome, detail)
  values
    (coalesce(nullif(p_actor, ''), 'unknown'), p_action, p_table, p_target,
     coalesce(p_args, '{}'::jsonb), p_outcome, p_detail);
$$;

revoke execute on function
  public._audit(text, text, text, text, jsonb, text, text) from public;


-- ---------------------------------------------------------------------
-- approve_care_partner -- the editorial act.
--
-- Refuses unless, at the moment of approval:
--   * the partner exists and is not soft-deleted
--   * a verification row exists
--   * council, registration number and KYC reference are all filled
--   * the registration has not expired
--
-- The expiry check is not pedantry: ADMIN-PANEL.md lists licence renewal
-- tracking as a requirement, and the only moment anyone reliably looks at
-- an expiry date is the moment they are about to rely on it.
--
-- Idempotent: approving an already-active partner is a no-op that still
-- audits, so a double-click does not look like two approvals.
-- ---------------------------------------------------------------------
create or replace function public.approve_care_partner(
  p_partner_id text,
  p_actor      text,
  p_note       text default null
) returns text
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
    perform public._audit(p_actor, 'approve_care_partner', 'care_partners',
      p_partner_id, v_args, 'refused', 'no such partner');
    raise exception 'no such care partner: %', p_partner_id;
  end if;

  if v_status = 'active' then
    perform public._audit(p_actor, 'approve_care_partner', 'care_partners',
      p_partner_id, v_args, 'ok', 'already active');
    return 'already active';
  end if;

  select * into v
    from public.care_partner_verification
   where partner_id = p_partner_id;

  if v.partner_id is null then
    perform public._audit(p_actor, 'approve_care_partner', 'care_partners',
      p_partner_id, v_args, 'refused', 'no verification record');
    raise exception
      'cannot approve %: no verification record. Capture the council, '
      'registration number and KYC reference first.', p_partner_id;
  end if;

  if coalesce(trim(v.council), '') = ''
     or coalesce(trim(v.registration_number), '') = ''
     or coalesce(trim(v.kyc_reference), '') = '' then
    perform public._audit(p_actor, 'approve_care_partner', 'care_partners',
      p_partner_id, v_args, 'refused', 'incomplete verification');
    raise exception
      'cannot approve %: verification is incomplete (council=%, registration=%, kyc=%).',
      p_partner_id,
      coalesce(nullif(trim(v.council), ''), 'MISSING'),
      coalesce(nullif(trim(v.registration_number), ''), 'MISSING'),
      coalesce(nullif(trim(v.kyc_reference), ''), 'MISSING');
  end if;

  if v.registration_expires_at is not null
     and v.registration_expires_at < current_date then
    perform public._audit(p_actor, 'approve_care_partner', 'care_partners',
      p_partner_id, v_args, 'refused', 'registration expired');
    raise exception
      'cannot approve %: medical registration expired on %.',
      p_partner_id, v.registration_expires_at;
  end if;

  update public.care_partners
     set status = 'active', verified_at = now(), updated_at = now()
   where id = p_partner_id;

  update public.care_partner_verification
     set reviewed_by = p_actor, reviewed_at = now(),
         review_note = p_note, updated_at = now()
   where partner_id = p_partner_id;

  perform public._audit(p_actor, 'approve_care_partner', 'care_partners',
    p_partner_id, v_args, 'ok', 'approved');
  return 'approved';
end;
$$;

revoke execute on function
  public.approve_care_partner(text, text, text) from public;


-- ---------------------------------------------------------------------
-- deactivate_care_partner -- soft, always.
--
-- Attribution and ledger history must survive: the families this partner
-- introduced are still their families, and 0037 built the whole model on
-- rows being hidden rather than removed. This flips status and stops the
-- tokens resolving; it never deletes.
-- ---------------------------------------------------------------------
create or replace function public.deactivate_care_partner(
  p_partner_id text,
  p_actor      text,
  p_reason     text default null
) returns text
language plpgsql security definer set search_path = ''
as $$
declare v_n int;
begin
  update public.care_partners
     set status = 'inactive', updated_at = now()
   where id = p_partner_id and deleted_at is null;
  get diagnostics v_n = row_count;

  if v_n = 0 then
    perform public._audit(p_actor, 'deactivate_care_partner', 'care_partners',
      p_partner_id, jsonb_build_object('reason', p_reason), 'refused',
      'no such partner');
    raise exception 'no such care partner: %', p_partner_id;
  end if;

  -- Their printed codes stop resolving. Attribution rows are untouched.
  update public.partner_referrals
     set active = false
   where partner_id = p_partner_id;

  perform public._audit(p_actor, 'deactivate_care_partner', 'care_partners',
    p_partner_id, jsonb_build_object('reason', p_reason), 'ok', null);
  return 'deactivated';
end;
$$;

revoke execute on function
  public.deactivate_care_partner(text, text, text) from public;


-- ---------------------------------------------------------------------
-- create_partner_campaign -- the row without which a partner is unusable.
--
-- partner_referrals carries campaign_id and, until now, nothing created
-- campaigns (STILL-OPEN §4.3). A campaign here is simply a token minted
-- with a campaign and channel attached, which is what the website reads
-- back when a scan arrives.
--
-- Returns the token, because the caller's next move is always to print it.
-- ---------------------------------------------------------------------
create or replace function public.create_partner_campaign(
  p_partner_id text,
  p_campaign   text,
  p_channel    text default 'qr',
  p_expires_at timestamptz default null,
  p_actor      text default 'unknown'
) returns text
language plpgsql security definer set search_path = ''
as $$
declare
  v_token  text;
  v_status text;
begin
  select status into v_status
    from public.care_partners
   where id = p_partner_id and deleted_at is null;

  -- A campaign for a partner nobody has approved yet would print a code
  -- that acquires families in our name before we vouched for them.
  if v_status is distinct from 'active' then
    perform public._audit(p_actor, 'create_partner_campaign', 'partner_referrals',
      p_partner_id, jsonb_build_object('campaign', p_campaign), 'refused',
      coalesce('partner status: ' || v_status, 'no such partner'));
    raise exception
      'cannot create a campaign for %: partner is not active (%).',
      p_partner_id, coalesce(v_status, 'missing');
  end if;

  v_token := public.mint_partner_token(
    p_partner_id, coalesce(p_channel, 'qr'), p_campaign, p_expires_at);

  perform public._audit(p_actor, 'create_partner_campaign', 'partner_referrals',
    v_token,
    jsonb_build_object('partner', p_partner_id, 'campaign', p_campaign,
                       'channel', p_channel),
    'ok', null);
  return v_token;
end;
$$;

revoke execute on function public.create_partner_campaign(
  text, text, text, timestamptz, text) from public;


-- ---------------------------------------------------------------------
-- rotate_partner_tokens -- a physical-world action.
--
-- Rotation invalidates every code this partner has ever printed. Posters
-- in a clinic stop working; a kit already couriered becomes waste paper.
-- That is not a toggle.
--
-- So it refuses unless the caller retypes the partner id as confirmation.
-- Typing it is the confirmation dialog; a boolean parameter would be
-- defaulted to true by the second caller who found it inconvenient.
-- ---------------------------------------------------------------------
create or replace function public.rotate_partner_tokens(
  p_partner_id text,
  p_confirm    text,
  p_actor      text,
  p_reason     text default null
) returns text
language plpgsql security definer set search_path = ''
as $$
declare
  v_old int;
  v_new text;
begin
  if p_confirm is distinct from p_partner_id then
    perform public._audit(p_actor, 'rotate_partner_tokens', 'partner_referrals',
      p_partner_id, jsonb_build_object('reason', p_reason), 'refused',
      'confirmation did not match');
    raise exception
      'rotation not confirmed: retype the partner id (%) to confirm. '
      'This invalidates every printed code for this partner.', p_partner_id;
  end if;

  if not exists (
    select 1 from public.care_partners
     where id = p_partner_id and deleted_at is null
  ) then
    raise exception 'no such care partner: %', p_partner_id;
  end if;

  update public.partner_referrals
     set active = false
   where partner_id = p_partner_id and active;
  get diagnostics v_old = row_count;

  v_new := public.mint_partner_token(p_partner_id);

  perform public._audit(p_actor, 'rotate_partner_tokens', 'partner_referrals',
    p_partner_id,
    jsonb_build_object('reason', p_reason, 'retired', v_old, 'new_token', v_new),
    'ok', format('%s code(s) retired', v_old));
  return v_new;
end;
$$;

revoke execute on function
  public.rotate_partner_tokens(text, text, text, text) from public;


-- ---------------------------------------------------------------------
-- remove_demo_partners -- one logged click.
--
-- The nine fictional partners seeded for UI review are live, and one of
-- them answers on the public internet. This is the same work as
-- supabase/seed/care_partner_demo_cleanup.sql, available to the panel and
-- audited, but it REFUSES if any demo partner has acquired a real family
-- or a ledger row - because at that point the row is no longer only demo
-- data, and deleting it would take a real attribution with it.
-- ---------------------------------------------------------------------
create or replace function public.remove_demo_partners(p_actor text)
returns text
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

  if v_attr > 0 or v_ledg > 0 then
    perform public._audit(p_actor, 'remove_demo_partners', 'care_partners',
      null, jsonb_build_object('attributions', v_attr, 'ledger', v_ledg),
      'refused', 'demo partners carry real history');
    raise exception
      'refusing: demo partners have % attribution(s) and % ledger row(s). '
      'Real history is attached to fictional partners - resolve that first.',
      v_attr, v_ledg;
  end if;

  delete from public.partner_referrals where partner_id like 'demo\_%';
  delete from public.care_partners     where id         like 'demo\_%';
  get diagnostics v_n = row_count;

  perform public._audit(p_actor, 'remove_demo_partners', 'care_partners',
    null, jsonb_build_object('deleted', v_n), 'ok', null);
  return format('%s demo partner(s) removed', v_n);
end;
$$;

revoke execute on function public.remove_demo_partners(text) from public;


-- =====================================================================
-- USING THESE FROM DIRECTUS
--
-- A Flow cannot call a Postgres function directly, and the sandboxed Run
-- Script operation has network restrictions. The working shape is a
-- manual-trigger Flow with a Webhook operation:
--
--   POST https://<project>.supabase.co/rest/v1/rpc/approve_care_partner
--   Headers: apikey: <service_role>, Authorization: Bearer <service_role>
--   Body:    {"p_partner_id":"{{$trigger.body.id}}",
--             "p_actor":"{{$accountability.user}}",
--             "p_note":"{{$trigger.body.note}}"}
--
-- Pass $accountability.user as p_actor so admin_audit records a human.
-- The Flow MUST assert on the response: a refusal comes back as a
-- PostgREST error, and a Flow that ignores it looks identical to success.
--
-- TRY IT (as service_role, in the SQL editor):
--
--   select public.approve_care_partner('demo_meera', 'sarthak');
--     -> refused: no verification record
--
--   insert into public.care_partner_verification
--     (partner_id, council, registration_number, kyc_reference, submitted_at)
--   values ('demo_meera', 'TS Medical Council', 'TSMC-12345', 'kyc_001', now());
--
--   select public.approve_care_partner('demo_meera', 'sarthak');
--     -> approved
--
--   select * from public.admin_audit_log limit 5;
-- =====================================================================
