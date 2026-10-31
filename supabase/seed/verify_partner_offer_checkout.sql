-- =====================================================================
-- verify_partner_offer_checkout.sql -- prove 0149 against real tables:
--   a partner offer comes off the price on the server, the quote equals
--   the charge, the order freezes the price, and a use counts once.
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0149, paste the whole file into the Supabase SQL
-- editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls the whole transaction back: the
-- fixture sponsor, doctor, programmes, coupons, orders and receipts, and
-- every change to the borrowed users' rows and to payment_settings,
-- never reach your data.
--
-- IMPERSONATION, as verify_partner_offers.sql: borrows the THREE oldest
-- auth users -- a member of the employer, a family of the doctor, and
-- somebody who is neither. Their memberships and attributions are
-- cleared INSIDE the transaction, so the rollback restores them. Says
-- SKIPPED with fewer than three users.
-- =====================================================================

do $$
declare
  r        text := '';
  pass     int  := 0;
  fail     int  := 0;
  js       jsonb;
  q        jsonb;
  n        int;
  u        uuid[];
  v_member uuid;
  v_family uuid;
  v_other  uuid;
  v_po1    text;   -- member, no pick        -> the best (ZZV10K)
  v_po2    text;   -- member, picks ZZV15    -> fails later
  v_po3    text;   -- member, picks another family's code -> the best
  cp       public.course_purchases;
begin
  select array_agg(id order by created_at) into u
    from (select id, created_at from auth.users order by created_at limit 3) x;
  if coalesce(array_length(u, 1), 0) < 3 then
    raise exception E'\n\n=== PARTNER OFFER CHECKOUT VERIFICATION (0149) ===\n\nSKIPPED: needs 3 auth.users rows to borrow.\n';
  end if;
  v_member := u[1]; v_family := u[2]; v_other := u[3];

  -- ---- 0. the doors' own settings ---------------------------------
  select count(*) into n
    from pg_proc f join pg_namespace s on s.oid = f.pronamespace
   where s.nspname = 'public' and f.proname = 'my_offer_quote'
     and f.prosecdef and f.proconfig @> array['search_path=""']
     and f.pronargs = 1 and f.proargtypes[0] = 'text'::regtype;
  if n = 1
    then pass := pass + 1; r := r || E'\nok    my_offer_quote(text): definer, empty path, no user argument';
    else fail := fail + 1; r := r || E'\nFAIL  my_offer_quote must be one text argument, definer, search_path ''''';
  end if;

  if has_function_privilege('authenticated', 'public.my_offer_quote(text)', 'execute')
     and not has_function_privilege('anon', 'public.my_offer_quote(text)', 'execute')
     and not has_function_privilege('authenticated', 'public._offers_for(uuid, text)', 'execute')
     and not has_function_privilege('anon', 'public._offers_for(uuid, text)', 'execute')
     and not has_function_privilege('authenticated',
           'public._write_purchase(uuid, text, int, text, text, text, text, text, int, int, text)', 'execute')
    then pass := pass + 1; r := r || E'\nok    quote open to authenticated; _offers_for and _write_purchase closed';
    else fail := fail + 1; r := r || E'\nFAIL  grants: quote for authenticated only, the helpers closed';
  end if;

  select count(*) into n
    from pg_proc f join pg_namespace s on s.oid = f.pronamespace
   where s.nspname = 'public'
     and f.proname in ('open_payment_order', 'record_stub_purchase', '_write_purchase');
  if n = 3
     and not has_function_privilege('authenticated',
           'public.open_payment_order(uuid, text, text, int, int, text)', 'execute')
    then pass := pass + 1; r := r || E'\nok    one signature each; open_payment_order service-only';
    else fail := fail + 1; r := r || format(E'\nFAIL  %s overloads of the three doors (want 3), or open_payment_order is callable', n);
  end if;

  -- ---- fixtures ---------------------------------------------------
  update public.payment_settings set mode = 'stub' where id = 'default';

  insert into public.sponsors (id, name, kind, plan_id, status)
  values ('zzv_sp', 'Verify Employer', 'employer', 'employer_standard', 'active');
  insert into public.care_partners (id, name, type, status)
  values ('zzv_doc', 'Dr Verify', 'doctor', 'active');

  delete from public.sponsor_members      where user_id = any (u);
  delete from public.partner_attributions where user_id = any (u);

  insert into public.sponsor_members (user_id, sponsor_id, work_email)
  values (v_member, 'zzv_sp', 'zzv-member@verify.invalid');
  insert into public.partner_attributions (user_id, partner_id, token)
  values (v_family, 'zzv_doc', 'ZZV-1');

  insert into public.programmes (id, title, kind, status, price_paise, display_source)
  values ('zzv_a', 'Verify: masterclass A', 'masterclass', 'published', 50000, 'server');
  insert into public.programmes (id, title, kind, status, price_paise, display_source)
  values ('zzv_b', 'Verify: masterclass B', 'masterclass', 'published', 30000, 'server');
  insert into public.programmes (id, title, kind, status, price_paise, display_source)
  values ('zzv_free', 'Verify: free', 'masterclass', 'published', 0, 'server');

  -- the member's two live offers for A: 15% (Rs 75) and Rs 100 flat
  insert into public.programme_coupons (code, programme_id, kind, value, audience_sponsor_id, label)
  values ('ZZV15', null, 'percent', 15, 'zzv_sp', 'any masterclass');
  insert into public.programme_coupons (code, programme_id, kind, value, audience_sponsor_id)
  values ('ZZV10K', 'zzv_a', 'flat', 10000, 'zzv_sp');
  -- the member's, never applied: used up, expired, inactive, leaves < Rs 1
  insert into public.programme_coupons (code, kind, value, audience_sponsor_id, max_redemptions, redeemed)
  values ('ZZVUSED', 'percent', 50, 'zzv_sp', 1, 1);
  insert into public.programme_coupons (code, kind, value, audience_sponsor_id, ends_at)
  values ('ZZVOLD', 'percent', 50, 'zzv_sp', now() - interval '1 day');
  insert into public.programme_coupons (code, kind, value, audience_sponsor_id, active)
  values ('ZZVOFF', 'percent', 50, 'zzv_sp', false);
  insert into public.programme_coupons (code, programme_id, kind, value, audience_sponsor_id)
  values ('ZZVBIG', 'zzv_a', 'flat', 49950, 'zzv_sp');
  -- another family's, and everyone's
  insert into public.programme_coupons (code, kind, value, audience_partner_id)
  values ('ZZVDOC', 'percent', 20, 'zzv_doc');
  insert into public.programme_coupons (code, kind, value)
  values ('ZZVPUB', 'percent', 50);

  -- ---- 1. percent 100 is refused ----------------------------------
  begin
    insert into public.programme_coupons (code, kind, value, audience_sponsor_id)
    values ('ZZV100', 'percent', 100, 'zzv_sp');
    fail := fail + 1; r := r || E'\nFAIL  a 100% offer was accepted';
  exception when check_violation then
    pass := pass + 1; r := r || E'\nok    percent 100                   -> refused';
  end;

  -- ---- 2. the member's quote --------------------------------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_member::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  q := public.my_offer_quote('off_zzv_a');
  execute 'reset role';
  if (q->>'list_paise')::int = 50000
     and jsonb_array_length(q->'offers') = 2
     and q->'offers'->0->>'code' = 'ZZV10K' and (q->'offers'->0->>'price_paise')::int = 40000
     and q->'offers'->1->>'code' = 'ZZV15'  and (q->'offers'->1->>'saving_paise')::int = 7500
     and q->>'best_code' = 'ZZV10K' and (q->>'best_price_paise')::int = 40000
    then pass := pass + 1; r := r || E'\nok    member quote                  -> 2 offers, best of two wins (Rs 400)';
    else fail := fail + 1; r := r || format(E'\nFAIL  member quote %s', q);
  end if;

  select count(*) into n from jsonb_array_elements(q->'offers') e
   where e ? 'redeemed' or e ? 'max_redemptions';
  if n = 0 and not (q ? 'redeemed')
    then pass := pass + 1; r := r || E'\nok    no usage counts in the quote';
    else fail := fail + 1; r := r || E'\nFAIL  the quote carries usage counts';
  end if;

  if not q->'offers' @> '[{"code":"ZZVUSED"}]' and not q->'offers' @> '[{"code":"ZZVOLD"}]'
     and not q->'offers' @> '[{"code":"ZZVOFF"}]' and not q->'offers' @> '[{"code":"ZZVBIG"}]'
     and not q->'offers' @> '[{"code":"ZZVDOC"}]' and not q->'offers' @> '[{"code":"ZZVPUB"}]'
    then pass := pass + 1; r := r || E'\nok    used up, expired, off, < Rs 1, other family, public -> not applied';
    else fail := fail + 1; r := r || E'\nFAIL  a dead, foreign or public offer reached the quote';
  end if;

  -- a free programme stays free and uses none
  execute 'set local role authenticated';
  js := public.my_offer_quote('off_zzv_free');
  execute 'reset role';
  if jsonb_array_length(js->'offers') = 0 and (js->>'list_paise')::int = 0
    then pass := pass + 1; r := r || E'\nok    free programme                -> no offer used';
    else fail := fail + 1; r := r || format(E'\nFAIL  free programme quote %s', js);
  end if;

  -- ---- 3. somebody who is neither -----------------------------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_other::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  js := public.my_offer_quote('off_zzv_a');
  execute 'reset role';
  if jsonb_array_length(js->'offers') = 0 and (js->>'best_price_paise')::int = 50000
    then pass := pass + 1; r := r || E'\nok    non-member quote              -> full price';
    else fail := fail + 1; r := r || format(E'\nFAIL  non-member quote %s', js);
  end if;
  perform set_config('request.jwt.claims', null, true);

  -- ---- 4. orders (as the Edge Function calls them) ------------------
  js := public.open_payment_order(v_member, 'offering', 'off_zzv_a', null, 1);
  v_po1 := js->>'payment_order_id';
  if (js->>'amount_paise')::int = 40000 and (js->>'discount_paise')::int = 10000
     and js->>'coupon_code' = 'ZZV10K'
     and (js->>'amount_paise')::int = (q->>'best_price_paise')::int
    then pass := pass + 1; r := r || E'\nok    member order                  -> discounted; quote = charge';
    else fail := fail + 1; r := r || format(E'\nFAIL  member order %s (quote %s)', js, q->>'best_price_paise');
  end if;

  select count(*) into n from public.payment_orders po
   where po.id = v_po1 and po.list_paise = 50000 and po.discount_paise = 10000
     and po.coupon_code = 'ZZV10K' and po.amount_paise = 40000;
  if n = 1
    then pass := pass + 1; r := r || E'\nok    the order freezes list, discount and code';
    else fail := fail + 1; r := r || E'\nFAIL  the order row did not freeze its price';
  end if;

  js := public.open_payment_order(v_member, 'offering', 'off_zzv_a', null, null, 'zzv15');
  v_po2 := js->>'payment_order_id';
  if (js->>'amount_paise')::int = 42500 and js->>'coupon_code' = 'ZZV15'
    then pass := pass + 1; r := r || E'\nok    her pick (lower case)         -> wins when valid';
    else fail := fail + 1; r := r || format(E'\nFAIL  her pick %s', js);
  end if;

  js := public.open_payment_order(v_member, 'offering', 'off_zzv_a', null, null, 'ZZVDOC');
  v_po3 := js->>'payment_order_id';
  if (js->>'amount_paise')::int = 40000 and js->>'coupon_code' = 'ZZV10K'
    then pass := pass + 1; r := r || E'\nok    another family''s code         -> refused, falls back to her best';
    else fail := fail + 1; r := r || format(E'\nFAIL  another family''s code %s', js);
  end if;

  js := public.open_payment_order(v_member, 'offering', 'off_zzv_a', null, null, 'ZZVOLD');
  if (js->>'amount_paise')::int = 40000 and js->>'coupon_code' = 'ZZV10K'
    then pass := pass + 1; r := r || E'\nok    an expired pick               -> falls back to her best';
    else fail := fail + 1; r := r || format(E'\nFAIL  expired pick %s', js);
  end if;

  js := public.open_payment_order(v_other, 'offering', 'off_zzv_a', null, null, 'ZZV10K');
  if (js->>'amount_paise')::int = 50000 and (js->>'discount_paise')::int = 0
     and js->>'coupon_code' is null
    then pass := pass + 1; r := r || E'\nok    non-member sending a code     -> full price';
    else fail := fail + 1; r := r || format(E'\nFAIL  non-member order %s', js);
  end if;

  -- a consult is never discounted (ZZV15 is for ANY programme)
  begin
    insert into public.expert_profiles (expert_id, name, status, takes_consults, fee_inr)
    values ('zzv_exp', 'Verify Expert', 'published', true, 800);
    js := public.open_payment_order(v_member, 'offering', 'off_exp_zzv_exp', null, null, 'ZZV15');
    if (js->>'amount_paise')::int = 80000 and (js->>'discount_paise')::int = 0
       and js->>'coupon_code' is null
      then pass := pass + 1; r := r || E'\nok    consult                       -> never discounted';
      else fail := fail + 1; r := r || format(E'\nFAIL  consult order %s', js);
    end if;
  exception when others then
    r := r || format(E'\nSKIP  consult check: could not seed an expert (%s)', sqlerrm);
  end;

  -- ---- 5. capture: the receipt copies the order; one use ------------
  update public.payment_orders set razorpay_order_id = 'order_zzv_1' where id = v_po1;
  js := public.record_course_purchase('order_zzv_1', 'pay_zzv_1', 'verify');
  select * into cp from public.course_purchases where razorpay_payment_id = 'pay_zzv_1';
  if cp.amount_paise = 40000 and cp.list_paise = 50000 and cp.discount_paise = 10000
     and cp.coupon_code = 'ZZV10K'
    then pass := pass + 1; r := r || E'\nok    capture copies list, discount and code to the receipt';
    else fail := fail + 1; r := r || format(E'\nFAIL  receipt %s / %s / %s / %s',
                                       cp.amount_paise, cp.list_paise, cp.discount_paise, cp.coupon_code);
  end if;

  js := public.record_course_purchase('order_zzv_1', 'pay_zzv_1', 'webhook');
  select redeemed into n from public.programme_coupons where code = 'ZZV10K';
  if n = 1 and (select count(*) from public.course_purchases where payment_order_id = v_po1) = 1
    then pass := pass + 1; r := r || E'\nok    replayed capture (webhook)    -> counted once';
    else fail := fail + 1; r := r || format(E'\nFAIL  replay: redeemed = %s', n);
  end if;

  -- ---- 6. a failed order counts nothing ----------------------------
  update public.payment_orders set razorpay_order_id = 'order_zzv_2' where id = v_po2;
  perform public.record_payment_failed('order_zzv_2');
  select redeemed into n from public.programme_coupons where code = 'ZZV15';
  if n = 0
    then pass := pass + 1; r := r || E'\nok    failed order                  -> 0 uses';
    else fail := fail + 1; r := r || format(E'\nFAIL  failed order counted %s', n);
  end if;

  -- ---- 7. an offer ending mid-payment is honoured --------------------
  update public.programme_coupons
     set ends_at = now() - interval '1 minute', active = false where code = 'ZZV10K';
  update public.payment_orders set razorpay_order_id = 'order_zzv_3' where id = v_po3;
  js := public.record_course_purchase('order_zzv_3', 'pay_zzv_3', 'verify');
  select * into cp from public.course_purchases where razorpay_payment_id = 'pay_zzv_3';
  select redeemed into n from public.programme_coupons where code = 'ZZV10K';
  if cp.amount_paise = 40000 and cp.discount_paise = 10000 and n = 2
    then pass := pass + 1; r := r || E'\nok    offer ended before capture    -> the order''s price stands';
    else fail := fail + 1; r := r || format(E'\nFAIL  ended mid-payment: %s paise, %s uses', cp.amount_paise, n);
  end if;

  -- ---- 8. a refund leaves the count --------------------------------
  perform public._revoke_purchase(cp.id, 'refunded');
  select redeemed into n from public.programme_coupons where code = 'ZZV10K';
  if n = 2
    then pass := pass + 1; r := r || E'\nok    refund                        -> the use stays counted';
    else fail := fail + 1; r := r || format(E'\nFAIL  refund changed redeemed to %s', n);
  end if;

  -- ---- 9. the stub path applies the same offer -----------------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_member::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  q  := public.my_offer_quote('off_zzv_b');
  js := public.record_stub_purchase('off_zzv_b', null);
  perform public.record_stub_purchase('off_zzv_b', null);   -- a double tap
  execute 'reset role';
  perform set_config('request.jwt.claims', null, true);
  select * into cp from public.course_purchases
   where user_id = v_member and offering_id = 'off_zzv_b' and provider = 'stub';
  select redeemed into n from public.programme_coupons where code = 'ZZV15';
  if cp.amount_paise = 25500 and cp.discount_paise = 4500 and cp.coupon_code = 'ZZV15'
     and cp.amount_paise = (q->>'best_price_paise')::int and n = 1
    then pass := pass + 1; r := r || E'\nok    stub path                     -> same offer, quote = receipt, counted once';
    else fail := fail + 1; r := r || format(E'\nFAIL  stub %s paise, %s off, %s, %s uses (quote %s)',
                                       cp.amount_paise, cp.discount_paise, cp.coupon_code, n, q->>'best_price_paise');
  end if;

  -- ---- 10. her receipts say what came off --------------------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_member::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  js := public.my_purchases();
  execute 'reset role';
  perform set_config('request.jwt.claims', null, true);
  if js @> '[{"offering_id":"off_zzv_b","list_paise":30000,"discount_paise":4500}]'
     and not (js->0 ? 'coupon_code')
    then pass := pass + 1; r := r || E'\nok    my_purchases                  -> list and discount, no code';
    else fail := fail + 1; r := r || E'\nFAIL  my_purchases is missing list/discount, or shows the code';
  end if;

  -- ---- 11. the expert is paid on the list price ---------------------
  if (public.price_offering('off_zzv_a')->>'seat_paise')::int = 50000
     and not exists (select 1 from pg_proc f
                      where f.proname in ('book_slot', 'expert_earning_from_booking')
                        and f.prosrc ilike '%_offers_for%')
    then pass := pass + 1; r := r || E'\nok    seat value (booking, earnings) -> list price';
    else fail := fail + 1; r := r || E'\nFAIL  the booking value moved with the discount';
  end if;

  raise exception E'\n\n=== PARTNER OFFER CHECKOUT VERIFICATION (0149) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
