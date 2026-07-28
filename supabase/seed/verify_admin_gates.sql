-- =====================================================================
-- verify_admin_gates.sql -- prove every refusal path, leave nothing behind.
-- ---------------------------------------------------------------------
-- HOW TO RUN: paste the whole file into the Supabase SQL editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end is what forces Postgres to roll the
-- whole thing back, so the fixtures this creates -- a partner, a
-- programme, sessions, a coupon -- never reach your data. Read the
-- message: it is a pass/fail table.
--
-- Re-run after any change to 0050-0055. It is the cheap version of the
-- integration test this project has no harness for.
--
-- UPDATED FOR 0055. The gates used to raise on refusal; they now RETURN
-- {ok:false, code, message} so the audit row survives the call (the
-- raise used to roll it back -- see STILL-OPEN 4.4a). So the checks below
-- read the returned `ok` rather than trapping an exception.
--
-- NOT COVERED: respond_to_programme_assignment(), which derives the
-- expert from auth.uid() and needs a real signed-in session. Acceptance
-- is simulated with a direct update.
-- =====================================================================

do $$
declare
  r     text := '';
  pass  int  := 0;
  fail  int  := 0;
  js    jsonb;
  v_n   int;
begin
  -- ---- fixtures --------------------------------------------------
  insert into public.care_partners (id, name, type, status)
  values ('zzv_partner', 'Verify Fixture', 'doctor', 'pending');

  insert into public.programmes (id, title, kind, stage, price_paise, capacity)
  values ('zzv_prog', 'Verify Programme', 'masterclass', 'parenting', 100000, 50);

  -- =================================================================
  -- A. approve_care_partner
  -- =================================================================
  js := public.approve_care_partner('zzv_partner', 'verifier');
  if (js ->> 'ok') = 'false' and (js ->> 'code') = 'no_verification_record'
    then pass := pass + 1; r := r || E'\nok    approve, NO paperwork          -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  approve, NO paperwork          -> ' || js::text;
  end if;

  insert into public.care_partner_verification (partner_id, council)
  values ('zzv_partner', 'TS Medical Council');

  js := public.approve_care_partner('zzv_partner', 'verifier');
  if (js ->> 'code') = 'incomplete_verification'
    then pass := pass + 1; r := r || E'\nok    approve, PARTIAL paperwork     -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  approve, PARTIAL paperwork     -> ' || js::text;
  end if;

  update public.care_partner_verification
     set registration_number = 'TSMC-1', kyc_reference = 'kyc-1',
         registration_expires_at = current_date - 1
   where partner_id = 'zzv_partner';

  js := public.approve_care_partner('zzv_partner', 'verifier');
  if (js ->> 'code') = 'registration_expired'
    then pass := pass + 1; r := r || E'\nok    approve, EXPIRED licence       -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  approve, EXPIRED licence       -> ' || js::text;
  end if;

  update public.care_partner_verification
     set registration_expires_at = current_date + 365
   where partner_id = 'zzv_partner';

  js := public.approve_care_partner('zzv_partner', 'verifier');
  if (js ->> 'ok') = 'true' and (js ->> 'code') = 'approved'
    then pass := pass + 1; r := r || E'\nok    approve, FULL paperwork        -> approved';
    else fail := fail + 1; r := r || E'\nFAIL  approve, FULL paperwork        -> ' || js::text;
  end if;

  -- =================================================================
  -- B. rotate_partner_tokens
  -- =================================================================
  js := public.rotate_partner_tokens('zzv_partner', 'wrong', 'verifier');
  if (js ->> 'code') = 'not_confirmed'
    then pass := pass + 1; r := r || E'\nok    rotate, WRONG confirmation     -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  rotate, WRONG confirmation     -> ' || js::text;
  end if;

  -- =================================================================
  -- C. create_partner_campaign
  -- =================================================================
  update public.care_partners set status = 'pending' where id = 'zzv_partner';
  js := public.create_partner_campaign('zzv_partner', 'spring', 'qr', null, 'verifier');
  if (js ->> 'code') = 'partner_not_active'
    then pass := pass + 1; r := r || E'\nok    campaign, PENDING partner      -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  campaign, PENDING partner      -> ' || js::text;
  end if;
  update public.care_partners set status = 'active' where id = 'zzv_partner';

  -- =================================================================
  -- D. publish_programme -- five gates
  -- =================================================================
  js := public.publish_programme('zzv_prog', 'verifier');
  if (js ->> 'code') = 'no_sessions'
    then pass := pass + 1; r := r || E'\nok    publish, NO sessions           -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  publish, NO sessions           -> ' || js::text;
  end if;

  insert into public.programme_sessions (id, programme_id, seq, title, starts_utc)
  values ('zzv_sess', 'zzv_prog', 1, 'Session', now() - interval '2 days');

  js := public.publish_programme('zzv_prog', 'verifier');
  if (js ->> 'code') = 'session_in_past'
    then pass := pass + 1; r := r || E'\nok    publish, a PAST session        -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  publish, a PAST session        -> ' || js::text;
  end if;

  update public.programme_sessions
     set starts_utc = now() + interval '7 days' where id = 'zzv_sess';

  js := public.publish_programme('zzv_prog', 'verifier');
  if (js ->> 'code') = 'no_accepted_expert'
    then pass := pass + 1; r := r || E'\nok    publish, NO expert             -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  publish, NO expert             -> ' || js::text;
  end if;

  -- Invited is not accepted.
  perform public.assign_programme_expert('zzv_prog', 'zzv_expert', 'verifier');
  js := public.publish_programme('zzv_prog', 'verifier');
  if (js ->> 'code') = 'no_accepted_expert'
    then pass := pass + 1; r := r || E'\nok    publish, INVITED-only expert   -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  publish, INVITED-only expert   -> ' || js::text;
  end if;

  update public.programme_experts set status = 'accepted'
   where programme_id = 'zzv_prog';

  js := public.publish_programme('zzv_prog', 'verifier');
  if (js ->> 'code') = 'not_reviewed'
    then pass := pass + 1; r := r || E'\nok    publish, SKIPPING review       -> refused';
    else fail := fail + 1; r := r || E'\nFAIL  publish, SKIPPING review       -> ' || js::text;
  end if;

  update public.programmes set status = 'marketing_review' where id = 'zzv_prog';

  js := public.publish_programme('zzv_prog', 'verifier');
  if (js ->> 'ok') = 'true' and (js ->> 'code') = 'published'
    then pass := pass + 1; r := r || E'\nok    publish, ALL conditions met    -> published';
    else fail := fail + 1; r := r || E'\nFAIL  publish, ALL conditions met    -> ' || js::text;
  end if;

  select count(*) into v_n from public.booking_slots where offering_id = 'zzv_prog';
  if v_n > 0
    then pass := pass + 1; r := r || E'\nok    sessions mirrored to slots (' || v_n || ')';
    else fail := fail + 1; r := r || E'\nFAIL  sessions NOT mirrored to booking_slots';
  end if;

  -- =================================================================
  -- E. preview_programme_coupon
  -- =================================================================
  js := public.preview_programme_coupon('NOPE', 'zzv_prog');
  if (js ->> 'valid') = 'false'
    then pass := pass + 1; r := r || E'\nok    unknown coupon                 -> not applicable';
    else fail := fail + 1; r := r || E'\nFAIL  unknown coupon                 -> ' || js::text;
  end if;

  insert into public.programme_coupons (code, programme_id, kind, value)
  values ('ZZVTEST', 'zzv_prog', 'percent', 25);

  js := public.preview_programme_coupon('ZZVTEST', 'zzv_prog');
  if (js ->> 'discount_paise') = '25000'
    then pass := pass + 1; r := r || E'\nok    25% of 100000 paise            -> 25000 off';
    else fail := fail + 1; r := r || E'\nFAIL  coupon maths                   -> ' || js::text;
  end if;

  update public.programme_coupons set kind = 'flat', value = 999999
   where code = 'ZZVTEST';
  js := public.preview_programme_coupon('ZZVTEST', 'zzv_prog');
  if (js ->> 'payable_paise')::int >= 0
    then pass := pass + 1; r := r || E'\nok    oversized discount clamps      -> payable '
                                   || (js ->> 'payable_paise');
    else fail := fail + 1; r := r || E'\nFAIL  oversized discount NEGATIVE    -> ' || js::text;
  end if;

  -- =================================================================
  -- F. THE AUDIT TRAIL -- what 0055 exists to fix.
  --
  -- Before 0055 this failed: each gate audited then raised, and the
  -- raise rolled the audit row back. Successes logged, refusals
  -- vanished -- backwards, since blocked attempts are the rows a log
  -- exists for.
  -- =================================================================
  select count(*) into v_n from public.admin_audit
   where target_id in ('zzv_partner', 'zzv_prog') and outcome = 'refused';
  if v_n >= 8
    then pass := pass + 1; r := r || E'\nok    REFUSALS recorded (' || v_n || ')';
    else fail := fail + 1; r := r || E'\nFAIL  refusals recorded: ' || v_n || ' (expected 8+)';
  end if;

  select count(*) into v_n from public.admin_audit
   where target_id in ('zzv_partner', 'zzv_prog') and outcome = 'ok';
  if v_n > 0
    then pass := pass + 1; r := r || E'\nok    successes recorded (' || v_n || ')';
    else fail := fail + 1; r := r || E'\nFAIL  successes NOT recorded';
  end if;

  -- Every refusal must carry a machine-readable code, or a Flow cannot
  -- branch on it and the message is all anyone has.
  select count(*) into v_n from public.admin_audit
   where target_id in ('zzv_partner', 'zzv_prog')
     and outcome = 'refused' and coalesce(detail, '') = '';
  if v_n = 0
    then pass := pass + 1; r := r || E'\nok    every refusal carries a code';
    else fail := fail + 1; r := r || E'\nFAIL  ' || v_n || ' refusal(s) with no code';
  end if;

  raise exception E'\n\n=== ADMIN GATE VERIFICATION ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
