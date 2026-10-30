-- =====================================================================
-- verify_exclusive_content.sql -- prove 0142 against real tables:
--   exclusive programmes and offers, the Content tab's RPC, contract end.
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0142, paste the whole file into the Supabase SQL
-- editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls the whole transaction back: the
-- fixture sponsor, centre, programmes, coupons, grants and every change
-- to the borrowed users' rows never reach your data.
--
-- IMPERSONATION, as verify_care_org_dashboard.sql: borrows the FOUR
-- oldest auth users -- an HR admin, a member of the employer, a family
-- of the centre, and somebody who is neither. Their memberships,
-- attributions and admin roles are cleared INSIDE the transaction, so
-- the rollback restores them. Needs four auth users; says SKIPPED
-- otherwise.
--
-- THE RLS STEPS SWITCH ROLE. `set local role authenticated` makes the
-- reads below go through the policies exactly as the app's do (the SQL
-- editor's own role bypasses RLS, so a check without it proves nothing).
-- `reset role` goes back to write the next fixture.
-- =====================================================================

do $$
declare
  r        text := '';
  pass     int  := 0;
  fail     int  := 0;
  js       jsonb;
  n        int;
  u        uuid[];
  v_admin  uuid;
  v_member uuid;
  v_family uuid;
  v_other  uuid;
begin
  select array_agg(id order by created_at) into u
    from (select id, created_at from auth.users order by created_at limit 4) x;
  if coalesce(array_length(u, 1), 0) < 4 then
    raise exception E'\n\n=== EXCLUSIVE CONTENT VERIFICATION (0142) ===\n\nSKIPPED: needs 4 auth.users rows to borrow.\n';
  end if;
  v_admin := u[1]; v_member := u[2]; v_family := u[3]; v_other := u[4];

  -- ---- fixtures ---------------------------------------------------
  insert into public.sponsors (id, name, kind, plan_id, status)
  values ('zzx_sp', 'Verify Employer', 'employer', 'employer_standard', 'active');
  insert into public.care_partners (id, name, type, status)
  values ('zzx_ivf', 'Verify IVF Centre', 'ivf_centre', 'active');

  delete from public.sponsor_admins       where user_id = any (u);
  delete from public.sponsor_members      where user_id = any (u);
  delete from public.partner_accounts     where user_id = any (u);
  delete from public.partner_attributions where user_id = any (u);

  insert into public.sponsor_admins (user_id, sponsor_id, added_by)
  values (v_admin, 'zzx_sp', 'verify');
  insert into public.sponsor_members (user_id, sponsor_id, work_email)
  values (v_member, 'zzx_sp', 'zzx-member@verify.invalid');
  insert into public.partner_attributions (user_id, partner_id, token)
  values (v_family, 'zzx_ivf', 'ZZX-1');

  insert into public.programmes (id, title, kind, status, price_paise, display_source)
  values ('zzx_all', 'Verify: for everyone', 'masterclass', 'published', 0, 'server');
  insert into public.programmes (id, title, kind, status, price_paise, display_source,
                                 audience_sponsor_id)
  values ('zzx_sp_only', 'Verify: employer only', 'masterclass', 'published', 0, 'server',
          'zzx_sp');
  insert into public.programmes (id, title, kind, status, price_paise, display_source,
                                 audience_partner_id)
  values ('zzx_ivf_only', 'Verify: centre only', 'masterclass', 'published', 0, 'server',
          'zzx_ivf');
  insert into public.programme_sessions (id, programme_id, starts_utc)
  values ('zzx_sp_only_s1', 'zzx_sp_only', now() + interval '7 days');

  insert into public.programme_coupons (code, programme_id, kind, value, audience_sponsor_id)
  values ('ZZXSP50', null, 'percent', 50, 'zzx_sp');

  update public.sponsor_analytics_config set min_cohort = 5 where id = 'default';

  -- ---- 1. both audiences at once is refused ----------------------
  begin
    update public.programmes set audience_partner_id = 'zzx_ivf' where id = 'zzx_sp_only';
    fail := fail + 1; r := r || E'\nFAIL  two audiences on one programme was accepted';
  exception when check_violation then
    pass := pass + 1; r := r || E'\nok    two audiences on one programme  -> refused';
  end;

  -- ---- 2. deleting a sponsor cannot make its session public ------
  begin
    delete from public.sponsors where id = 'zzx_sp';
    fail := fail + 1; r := r || E'\nFAIL  sponsor with an exclusive session was deleted';
  exception when foreign_key_violation then
    pass := pass + 1; r := r || E'\nok    delete sponsor with a session   -> refused (restrict)';
  end;

  -- ---- 3. RLS, as each person --------------------------------------
  -- anon
  perform set_config('request.jwt.claims', null, true);
  execute 'set local role anon';
  select count(*) into n from public.programmes_published where id like 'zzx_%';
  execute 'reset role';
  if n = 1
    then pass := pass + 1; r := r || E'\nok    anon sees 1 of 3 (everyone''s only)';
    else fail := fail + 1; r := r || format(E'\nFAIL  anon sees %s of 3', n);
  end if;

  -- somebody who is neither: the view, the table, the sessions
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_other::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  select count(*) into n from public.programmes_published where id like 'zzx_%';
  select n * 10 + count(*) into n from public.programmes where id like 'zzx_%';
  select n * 10 + count(*) into n from public.programme_sessions where programme_id = 'zzx_sp_only';
  execute 'reset role';
  if n = 110
    then pass := pass + 1; r := r || E'\nok    non-member: view 1, table 1, sessions 0';
    else fail := fail + 1; r := r || format(E'\nFAIL  non-member view/table/sessions = %s (want 110)', n);
  end if;

  -- the employer's member
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_member::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  select count(*) into n from public.programmes_published
   where id in ('zzx_all', 'zzx_sp_only');
  select n * 10 + count(*) into n from public.programmes_published where id = 'zzx_ivf_only';
  select n * 10 + count(*) into n from public.programme_sessions where programme_id = 'zzx_sp_only';
  execute 'reset role';
  if n = 201
    then pass := pass + 1; r := r || E'\nok    member: own + everyone''s, not the centre''s, sessions 1';
    else fail := fail + 1; r := r || format(E'\nFAIL  member = %s (want 201)', n);
  end if;

  -- the centre's family
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_family::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  select count(*) into n from public.programmes_published
   where id in ('zzx_all', 'zzx_ivf_only');
  select n * 10 + count(*) into n from public.programmes_published where id = 'zzx_sp_only';
  execute 'reset role';
  if n = 20
    then pass := pass + 1; r := r || E'\nok    family: own + everyone''s, not the employer''s';
    else fail := fail + 1; r := r || format(E'\nFAIL  family = %s (want 20)', n);
  end if;

  -- ---- 4. the receipt doors ----------------------------------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_other::text, 'role', 'authenticated')::text, true);
  js := public.claim_free_offering('off_zzx_sp_only');
  if (js ->> 'reason') = 'unknown_offering'
    then pass := pass + 1; r := r || E'\nok    non-member claims it            -> unknown_offering';
    else fail := fail + 1; r := r || E'\nFAIL  non-member claim               -> ' || js::text;
  end if;
  js := public.open_payment_order(v_other, 'offering', 'off_zzx_sp_only', null, null);
  if (js ->> 'reason') = 'unknown_offering'
    then pass := pass + 1; r := r || E'\nok    non-member opens an order       -> unknown_offering';
    else fail := fail + 1; r := r || E'\nFAIL  non-member order               -> ' || js::text;
  end if;
  js := public.preview_programme_coupon('ZZXSP50', 'zzx_all');
  if (js ->> 'valid') = 'false'
    then pass := pass + 1; r := r || E'\nok    non-member uses the offer code  -> not applicable';
    else fail := fail + 1; r := r || E'\nFAIL  non-member coupon              -> ' || js::text;
  end if;

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_member::text, 'role', 'authenticated')::text, true);
  js := public.claim_free_offering('off_zzx_sp_only');
  if (js ->> 'ok') = 'true'
    then pass := pass + 1; r := r || E'\nok    member claims it                -> receipt';
    else fail := fail + 1; r := r || E'\nFAIL  member claim                   -> ' || js::text;
  end if;
  update public.programmes set price_paise = 10000 where id = 'zzx_all';
  js := public.preview_programme_coupon('ZZXSP50', 'zzx_all');
  if (js ->> 'valid') = 'true' and (js ->> 'discount_paise')::int = 5000
    then pass := pass + 1; r := r || E'\nok    member uses the offer code      -> 50% off';
    else fail := fail + 1; r := r || E'\nFAIL  member coupon                  -> ' || js::text;
  end if;

  -- ---- 5. the Content tab -----------------------------------------
  perform set_config('request.jwt.claims', null, true);
  js := public.partner_exclusive_content();
  if (js ->> 'ok') = 'false'
    then pass := pass + 1; r := r || E'\nok    nobody signed in                -> ok:false';
    else fail := fail + 1; r := r || E'\nFAIL  nobody signed in               -> ' || js::text;
  end if;

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_admin::text, 'role', 'authenticated')::text, true);
  js := public.partner_exclusive_content();
  if (js ->> 'ok') = 'true' and (js ->> 'kind') = 'sponsor'
     and jsonb_array_length(js -> 'programmes') = 1
     and (js -> 'programmes' -> 0 ->> 'id') = 'zzx_sp_only'
     and (js -> 'programmes' -> 0 -> 'booked') = 'null'::jsonb
     and jsonb_array_length(js -> 'offers') = 1
     and (js -> 'offers' -> 0 ->> 'code') = 'ZZXSP50'
    then pass := pass + 1; r := r || E'\nok    HR admin, min 5                 -> own session + offer, booked held back';
    else fail := fail + 1; r := r || E'\nFAIL  HR admin                       -> ' || js::text;
  end if;

  update public.sponsor_analytics_config set min_cohort = 1 where id = 'default';
  js := public.partner_exclusive_content();
  if (js -> 'programmes' -> 0 ->> 'booked')::int = 1
    then pass := pass + 1; r := r || E'\nok    HR admin, min 1                 -> booked 1';
    else fail := fail + 1; r := r || E'\nFAIL  HR admin min 1                 -> ' || js::text;
  end if;

  if js::text not like '%' || v_member::text || '%'
    then pass := pass + 1; r := r || E'\nok    no member id in the answer';
    else fail := fail + 1; r := r || E'\nFAIL  a member id leaked';
  end if;

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_other::text, 'role', 'authenticated')::text, true);
  js := public.partner_exclusive_content();
  if (js ->> 'ok') = 'false'
    then pass := pass + 1; r := r || E'\nok    not an admin                    -> ok:false';
    else fail := fail + 1; r := r || E'\nFAIL  not an admin                   -> ' || js::text;
  end if;

  -- ---- 6. contract end (R2) ---------------------------------------
  perform public.grant_plan(v_member, 'employer_standard', 'sponsor', 'zzx_sp',
                            null, 'verify');
  perform public.grant_consult_credits(v_member, 2, 'sponsor', 'zzx_sp', 'verify');

  update public.sponsors set status = 'suspended' where id = 'zzx_sp';
  select count(*) into n from public.user_entitlements
   where user_id = v_member and source = 'sponsor' and source_ref = 'zzx_sp';
  select n * 10 + count(*) into n from public.consult_credits
   where user_id = v_member and source = 'sponsor' and source_ref = 'zzx_sp'
     and voided_at is null;
  if n = 12
    then pass := pass + 1; r := r || E'\nok    suspended                       -> plan and 2 credits kept';
    else fail := fail + 1; r := r || format(E'\nFAIL  suspended plan/credits = %s (want 12)', n);
  end if;

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_member::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  select count(*) into n from public.programmes_published where id = 'zzx_sp_only';
  execute 'reset role';
  if n = 1
    then pass := pass + 1; r := r || E'\nok    suspended                       -> member still sees the session';
    else fail := fail + 1; r := r || E'\nFAIL  suspended hid the session from the member';
  end if;

  update public.sponsors set status = 'ended' where id = 'zzx_sp';
  select count(*) into n from public.user_entitlements
   where user_id = v_member and source = 'sponsor' and source_ref = 'zzx_sp';
  select n * 10 + count(*) into n from public.consult_credits
   where user_id = v_member and source = 'sponsor' and source_ref = 'zzx_sp'
     and voided_at is null;
  if n = 0
    then pass := pass + 1; r := r || E'\nok    ended                           -> plan and credits withdrawn';
    else fail := fail + 1; r := r || format(E'\nFAIL  ended plan/credits = %s (want 0)', n);
  end if;

  execute 'set local role authenticated';
  select count(*) into n from public.programmes_published where id = 'zzx_sp_only';
  execute 'reset role';
  if n = 0
    then pass := pass + 1; r := r || E'\nok    ended                           -> session hidden from the member';
    else fail := fail + 1; r := r || E'\nFAIL  ended still shows the session';
  end if;

  perform set_config('request.jwt.claims', null, true);

  raise exception E'\n\n=== EXCLUSIVE CONTENT VERIFICATION (0142) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
