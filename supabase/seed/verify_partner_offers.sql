-- =====================================================================
-- verify_partner_offers.sql -- prove 0148 against real tables:
--   my_partner_offers() answers the caller only, and says no more than
--   the phone needs.
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0148, paste the whole file into the Supabase SQL
-- editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls the whole transaction back: the
-- fixture sponsor, centre, programmes and coupons, and every change to
-- the borrowed users' rows, never reach your data.
--
-- IMPERSONATION, as verify_exclusive_content.sql: borrows the THREE
-- oldest auth users -- a member of the employer, a family of the centre,
-- and somebody who is neither. Their memberships and attributions are
-- cleared INSIDE the transaction, so the rollback restores them. Says
-- SKIPPED with fewer than three users.
-- =====================================================================

do $$
declare
  r        text := '';
  pass     int  := 0;
  fail     int  := 0;
  js       jsonb;
  n        int;
  u        uuid[];
  v_member uuid;
  v_family uuid;
  v_other  uuid;
begin
  select array_agg(id order by created_at) into u
    from (select id, created_at from auth.users order by created_at limit 3) x;
  if coalesce(array_length(u, 1), 0) < 3 then
    raise exception E'\n\n=== PARTNER OFFERS VERIFICATION (0148) ===\n\nSKIPPED: needs 3 auth.users rows to borrow.\n';
  end if;
  v_member := u[1]; v_family := u[2]; v_other := u[3];

  -- ---- 0. the door's own settings ---------------------------------
  select count(*) into n
    from pg_proc f join pg_namespace s on s.oid = f.pronamespace
   where s.nspname = 'public' and f.proname = 'my_partner_offers'
     and f.prosecdef
     and f.proconfig @> array['search_path=""'];
  if n = 1
    then pass := pass + 1; r := r || E'\nok    security definer, search_path = ''''';
    else fail := fail + 1; r := r || E'\nFAIL  my_partner_offers is not security definer with an empty search_path';
  end if;

  if has_function_privilege('authenticated', 'public.my_partner_offers()', 'execute')
     and not has_function_privilege('anon', 'public.my_partner_offers()', 'execute')
    then pass := pass + 1; r := r || E'\nok    authenticated may call, anon may not';
    else fail := fail + 1; r := r || E'\nFAIL  grants: authenticated must call, anon must not';
  end if;

  -- ---- fixtures ---------------------------------------------------
  insert into public.sponsors (id, name, kind, plan_id, status)
  values ('zzy_sp', 'Verify Employer', 'employer', 'employer_standard', 'active');
  insert into public.care_partners (id, name, type, status)
  values ('zzy_doc', 'Dr Verify', 'doctor', 'active');

  delete from public.sponsor_members      where user_id = any (u);
  delete from public.partner_attributions where user_id = any (u);

  insert into public.sponsor_members (user_id, sponsor_id, work_email)
  values (v_member, 'zzy_sp', 'zzy-member@verify.invalid');
  insert into public.partner_attributions (user_id, partner_id, token)
  values (v_family, 'zzy_doc', 'ZZY-1');

  insert into public.programmes (id, title, kind, status, price_paise, display_source)
  values ('zzy_open', 'Verify: open session', 'masterclass', 'published', 50000, 'server');
  insert into public.programmes (id, title, kind, status, price_paise, display_source)
  values ('zzy_draft', 'Verify: draft', 'masterclass', 'draft', 50000, 'server');

  -- the member's: one with a label, one falling back to the title
  insert into public.programme_coupons (code, programme_id, kind, value, audience_sponsor_id, label)
  values ('ZZYSP15', null, 'percent', 15, 'zzy_sp', 'any masterclass');
  insert into public.programme_coupons (code, programme_id, kind, value, audience_sponsor_id)
  values ('ZZYSPOPEN', 'zzy_open', 'flat', 10000, 'zzy_sp');
  -- the member's, but must NOT show: used up, expired, inactive, a draft programme
  insert into public.programme_coupons (code, kind, value, audience_sponsor_id, max_redemptions, redeemed)
  values ('ZZYUSED', 'percent', 10, 'zzy_sp', 3, 3);
  insert into public.programme_coupons (code, kind, value, audience_sponsor_id, ends_at)
  values ('ZZYOLD', 'percent', 10, 'zzy_sp', now() - interval '1 day');
  insert into public.programme_coupons (code, kind, value, audience_sponsor_id, active)
  values ('ZZYOFF', 'percent', 10, 'zzy_sp', false);
  insert into public.programme_coupons (code, programme_id, kind, value, audience_sponsor_id)
  values ('ZZYDRAFT', 'zzy_draft', 'percent', 10, 'zzy_sp');
  -- the doctor's family's
  insert into public.programme_coupons (code, kind, value, audience_partner_id)
  values ('ZZYDOC10', 'percent', 10, 'zzy_doc');
  -- everyone's: never listed
  insert into public.programme_coupons (code, kind, value)
  values ('ZZYPUBLIC', 'percent', 5);

  -- ---- 1. a label longer than 60 is refused ------------------------
  begin
    update public.programme_coupons set label = repeat('x', 61) where code = 'ZZYSP15';
    fail := fail + 1; r := r || E'\nFAIL  a 61-character label was accepted';
  exception when check_violation then
    pass := pass + 1; r := r || E'\nok    label over 60                 -> refused';
  end;

  -- ---- 2. signed out ----------------------------------------------
  perform set_config('request.jwt.claims', null, true);
  js := public.my_partner_offers();
  if js = '[]'::jsonb
    then pass := pass + 1; r := r || E'\nok    no caller                     -> []';
    else fail := fail + 1; r := r || format(E'\nFAIL  no caller got %s', js);
  end if;

  -- ---- 3. the member ----------------------------------------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_member::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  js := public.my_partner_offers();
  execute 'reset role';
  select count(*) into n from jsonb_array_elements(js) e where e->>'code' like 'ZZY%';
  if n = 2
     and js @> '[{"code":"ZZYSP15","label":"any masterclass","audience":"sponsor","audience_id":"zzy_sp"}]'
     and js @> '[{"code":"ZZYSPOPEN","label":"Verify: open session","kind":"flat","value":10000}]'
    then pass := pass + 1; r := r || E'\nok    member                        -> her 2 (label, then title)';
    else fail := fail + 1; r := r || format(E'\nFAIL  member got %s', js);
  end if;

  select count(*) into n from jsonb_array_elements(js) e
   where e ? 'redeemed' or e ? 'max_redemptions';
  if n = 0
    then pass := pass + 1; r := r || E'\nok    no usage counts in the answer';
    else fail := fail + 1; r := r || E'\nFAIL  the answer carries usage counts';
  end if;

  if not js @> '[{"code":"ZZYUSED"}]' and not js @> '[{"code":"ZZYOLD"}]'
     and not js @> '[{"code":"ZZYOFF"}]' and not js @> '[{"code":"ZZYDRAFT"}]'
    then pass := pass + 1; r := r || E'\nok    used up, expired, off, draft  -> not listed';
    else fail := fail + 1; r := r || E'\nFAIL  a dead offer was listed';
  end if;

  if not js @> '[{"code":"ZZYPUBLIC"}]' and not js @> '[{"code":"ZZYDOC10"}]'
    then pass := pass + 1; r := r || E'\nok    everyone''s and the doctor''s -> not listed';
    else fail := fail + 1; r := r || E'\nFAIL  member saw a public or another audience''s coupon';
  end if;

  -- ---- 4. the doctor's family -------------------------------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_family::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  js := public.my_partner_offers();
  execute 'reset role';
  select count(*) into n from jsonb_array_elements(js) e where e->>'code' like 'ZZY%';
  if n = 1 and js @> '[{"code":"ZZYDOC10","audience":"partner","audience_id":"zzy_doc"}]'
    then pass := pass + 1; r := r || E'\nok    doctor''s family               -> the doctor''s 1 only';
    else fail := fail + 1; r := r || format(E'\nFAIL  family got %s', js);
  end if;

  -- ---- 5. somebody who is neither -----------------------------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_other::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  js := public.my_partner_offers();
  execute 'reset role';
  select count(*) into n from jsonb_array_elements(js) e where e->>'code' like 'ZZY%';
  if n = 0
    then pass := pass + 1; r := r || E'\nok    neither                       -> none';
    else fail := fail + 1; r := r || format(E'\nFAIL  neither got %s', js);
  end if;

  -- ---- 6. an ended sponsor's offer goes with the contract ------------
  update public.sponsors set status = 'ended' where id = 'zzy_sp';
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_member::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  js := public.my_partner_offers();
  execute 'reset role';
  select count(*) into n from jsonb_array_elements(js) e where e->>'code' like 'ZZY%';
  if n = 0
    then pass := pass + 1; r := r || E'\nok    sponsor ended                 -> member''s offers gone';
    else fail := fail + 1; r := r || format(E'\nFAIL  ended sponsor still offers %s', js);
  end if;

  perform set_config('request.jwt.claims', null, true);

  raise exception E'\n\n=== PARTNER OFFERS VERIFICATION (0148) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
