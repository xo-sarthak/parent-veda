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
-- Re-run it after any change to 0050-0054. It is the cheap version of
-- the integration test this project has no harness for.
--
-- WHAT IT DOES NOT COVER: respond_to_programme_assignment(), which
-- derives the expert from auth.uid() and therefore needs a real signed-in
-- session. The script simulates acceptance with a direct update instead.
-- =====================================================================

do $$
declare
  r     text := '';
  pass  int  := 0;
  fail  int  := 0;
  v_txt text;
  v_js  jsonb;
  v_n   int;
begin
  -- ---- fixtures --------------------------------------------------
  insert into public.care_partners (id, name, type, status)
  values ('zzv_partner', 'Verify Fixture', 'doctor', 'pending');

  insert into public.programmes (id, title, kind, stage, price_paise, capacity)
  values ('zzv_prog', 'Verify Programme', 'masterclass', 'parenting', 100000, 50);

  -- =================================================================
  -- A. approve_care_partner -- the doctor verification gate
  -- =================================================================
  begin
    perform public.approve_care_partner('zzv_partner', 'verifier');
    fail := fail + 1;
    r := r || E'\nFAIL  approve with NO paperwork        -> was allowed';
  exception when others then
    pass := pass + 1;
    r := r || E'\nok    approve with NO paperwork        -> refused';
  end;

  insert into public.care_partner_verification (partner_id, council)
  values ('zzv_partner', 'TS Medical Council');

  begin
    perform public.approve_care_partner('zzv_partner', 'verifier');
    fail := fail + 1;
    r := r || E'\nFAIL  approve with PARTIAL paperwork   -> was allowed';
  exception when others then
    pass := pass + 1;
    r := r || E'\nok    approve with PARTIAL paperwork   -> refused';
  end;

  update public.care_partner_verification
     set registration_number = 'TSMC-1', kyc_reference = 'kyc-1',
         registration_expires_at = current_date - 1
   where partner_id = 'zzv_partner';

  begin
    perform public.approve_care_partner('zzv_partner', 'verifier');
    fail := fail + 1;
    r := r || E'\nFAIL  approve with EXPIRED licence     -> was allowed';
  exception when others then
    pass := pass + 1;
    r := r || E'\nok    approve with EXPIRED licence     -> refused';
  end;

  update public.care_partner_verification
     set registration_expires_at = current_date + 365
   where partner_id = 'zzv_partner';

  begin
    v_txt := public.approve_care_partner('zzv_partner', 'verifier');
    if v_txt = 'approved' then
      pass := pass + 1;
      r := r || E'\nok    approve with FULL paperwork      -> approved';
    else
      fail := fail + 1;
      r := r || E'\nFAIL  approve with FULL paperwork      -> ' || v_txt;
    end if;
  exception when others then
    fail := fail + 1;
    r := r || E'\nFAIL  approve with FULL paperwork      -> refused: ' || left(sqlerrm, 50);
  end;

  -- =================================================================
  -- B. rotate_partner_tokens -- the physical-world confirmation
  -- =================================================================
  begin
    perform public.rotate_partner_tokens('zzv_partner', 'wrong', 'verifier');
    fail := fail + 1;
    r := r || E'\nFAIL  rotate with WRONG confirmation   -> was allowed';
  exception when others then
    pass := pass + 1;
    r := r || E'\nok    rotate with WRONG confirmation   -> refused';
  end;

  -- =================================================================
  -- C. create_partner_campaign -- refuses for a non-active partner
  -- =================================================================
  update public.care_partners set status = 'pending' where id = 'zzv_partner';
  begin
    perform public.create_partner_campaign('zzv_partner', 'spring', 'qr', null, 'verifier');
    fail := fail + 1;
    r := r || E'\nFAIL  campaign for PENDING partner     -> was allowed';
  exception when others then
    pass := pass + 1;
    r := r || E'\nok    campaign for PENDING partner     -> refused';
  end;
  update public.care_partners set status = 'active' where id = 'zzv_partner';

  -- =================================================================
  -- D. publish_programme -- four gates
  -- =================================================================
  begin
    perform public.publish_programme('zzv_prog', 'verifier');
    fail := fail + 1;
    r := r || E'\nFAIL  publish with NO sessions         -> was allowed';
  exception when others then
    pass := pass + 1;
    r := r || E'\nok    publish with NO sessions         -> refused';
  end;

  insert into public.programme_sessions (id, programme_id, seq, title, starts_utc)
  values ('zzv_sess_past', 'zzv_prog', 1, 'Past', now() - interval '2 days');

  begin
    perform public.publish_programme('zzv_prog', 'verifier');
    fail := fail + 1;
    r := r || E'\nFAIL  publish with a PAST session      -> was allowed';
  exception when others then
    pass := pass + 1;
    r := r || E'\nok    publish with a PAST session      -> refused';
  end;

  update public.programme_sessions
     set starts_utc = now() + interval '7 days' where id = 'zzv_sess_past';

  begin
    perform public.publish_programme('zzv_prog', 'verifier');
    fail := fail + 1;
    r := r || E'\nFAIL  publish with NO accepted expert  -> was allowed';
  exception when others then
    pass := pass + 1;
    r := r || E'\nok    publish with NO accepted expert  -> refused';
  end;

  -- Invited but NOT accepted: an invitation must not be enough.
  perform public.assign_programme_expert('zzv_prog', 'zzv_expert', 'verifier');
  begin
    perform public.publish_programme('zzv_prog', 'verifier');
    fail := fail + 1;
    r := r || E'\nFAIL  publish with INVITED-only expert -> was allowed';
  exception when others then
    pass := pass + 1;
    r := r || E'\nok    publish with INVITED-only expert -> refused';
  end;

  update public.programme_experts set status = 'accepted'
   where programme_id = 'zzv_prog';

  -- Still in draft: must not skip review.
  begin
    perform public.publish_programme('zzv_prog', 'verifier');
    fail := fail + 1;
    r := r || E'\nFAIL  publish SKIPPING review          -> was allowed';
  exception when others then
    pass := pass + 1;
    r := r || E'\nok    publish SKIPPING review          -> refused';
  end;

  update public.programmes set status = 'marketing_review' where id = 'zzv_prog';

  begin
    v_txt := public.publish_programme('zzv_prog', 'verifier');
    if v_txt = 'published' then
      pass := pass + 1;
      r := r || E'\nok    publish when ALL conditions met -> published';
    else
      fail := fail + 1;
      r := r || E'\nFAIL  publish when ALL conditions met -> ' || v_txt;
    end if;
  exception when others then
    fail := fail + 1;
    r := r || E'\nFAIL  publish when ALL conditions met -> refused: ' || left(sqlerrm, 50);
  end;

  -- The seat mirror: book_slot() must be the one authority.
  select count(*) into v_n from public.booking_slots where offering_id = 'zzv_prog';
  if v_n > 0 then
    pass := pass + 1;
    r := r || E'\nok    sessions mirrored to booking_slots (' || v_n || ')';
  else
    fail := fail + 1;
    r := r || E'\nFAIL  sessions NOT mirrored to booking_slots';
  end if;

  -- =================================================================
  -- E. preview_programme_coupon -- a verdict, never the row
  -- =================================================================
  v_js := public.preview_programme_coupon('NOPE', 'zzv_prog');
  if (v_js ->> 'valid') = 'false' then
    pass := pass + 1;
    r := r || E'\nok    unknown coupon                   -> not applicable';
  else
    fail := fail + 1;
    r := r || E'\nFAIL  unknown coupon                   -> ' || v_js::text;
  end if;

  insert into public.programme_coupons (code, programme_id, kind, value)
  values ('ZZVTEST', 'zzv_prog', 'percent', 25);

  v_js := public.preview_programme_coupon('ZZVTEST', 'zzv_prog');
  if (v_js ->> 'valid') = 'true' and (v_js ->> 'discount_paise') = '25000' then
    pass := pass + 1;
    r := r || E'\nok    25% of 100000 paise              -> 25000 off';
  else
    fail := fail + 1;
    r := r || E'\nFAIL  coupon maths                     -> ' || v_js::text;
  end if;

  -- A discount larger than the price must clamp, never pay out.
  update public.programme_coupons set kind = 'flat', value = 999999
   where code = 'ZZVTEST';
  v_js := public.preview_programme_coupon('ZZVTEST', 'zzv_prog');
  if (v_js ->> 'payable_paise')::int >= 0 then
    pass := pass + 1;
    r := r || E'\nok    oversized discount clamps        -> payable '
           || (v_js ->> 'payable_paise');
  else
    fail := fail + 1;
    r := r || E'\nFAIL  oversized discount went NEGATIVE -> ' || v_js::text;
  end if;

  -- =================================================================
  -- F. THE AUDIT TRAIL -- the check I expect to FAIL
  --
  -- Every gate does `perform _audit(...)` and then `raise exception`.
  -- Raising aborts the transaction, which rolls back the audit insert
  -- made moments earlier. So a refusal probably records NOTHING, and the
  -- rows the log most needs -- the attempts that were stopped -- are the
  -- ones it silently drops.
  --
  -- If this reports FAIL, the design is wrong and the fix is for the
  -- functions to RETURN a refusal rather than raise one, with the
  -- Directus Flow asserting on the result.
  -- =================================================================
  select count(*) into v_n from public.admin_audit
   where target_id in ('zzv_partner', 'zzv_prog') and outcome = 'refused';
  if v_n > 0 then
    pass := pass + 1;
    r := r || E'\nok    refusals recorded in admin_audit (' || v_n || ')';
  else
    fail := fail + 1;
    r := r || E'\nFAIL  refusals NOT recorded -- raise rolls back the audit row';
  end if;

  select count(*) into v_n from public.admin_audit
   where target_id in ('zzv_partner', 'zzv_prog') and outcome = 'ok';
  if v_n > 0 then
    pass := pass + 1;
    r := r || E'\nok    successes recorded in admin_audit (' || v_n || ')';
  else
    fail := fail + 1;
    r := r || E'\nFAIL  successes NOT recorded either';
  end if;

  -- =================================================================
  -- Report, and roll everything back by raising.
  -- =================================================================
  raise exception E'\n\n=== ADMIN GATE VERIFICATION ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
