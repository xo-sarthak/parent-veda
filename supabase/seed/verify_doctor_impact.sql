-- =====================================================================
-- verify_doctor_impact.sql -- prove 0141 (a solo doctor's small numbers
--                             held back) against real tables.
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0141, paste the whole file into the Supabase SQL
-- editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls everything back: the fixture
-- practice, the attributions, the threshold change, and every change to
-- the borrowed users' rows.
--
-- Borrows the OLDEST auth user as a solo doctor (Route B: expert_accounts
-- -> care_partners.expert_id) and the next TWO as families. Needs three
-- auth users; says SKIPPED otherwise.
-- =====================================================================

do $$
declare
  r      text := '';
  pass   int  := 0;
  fail   int  := 0;
  v_doc  uuid;
  v_fam  uuid[];
  i      record;
  f      record;
begin
  select id into v_doc from auth.users order by created_at limit 1;
  select array_agg(id order by created_at) into v_fam
    from (select id, created_at from auth.users
           order by created_at offset 1 limit 2) u;
  if v_doc is null or coalesce(array_length(v_fam, 1), 0) < 2 then
    raise exception E'\n\n=== DOCTOR IMPACT VERIFICATION (0141) ===\n\nSKIPPED: needs 3 auth.users rows to borrow.\n';
  end if;

  -- ---- fixtures (rolled back) ---------------------------------------
  insert into public.care_partners (id, name, type, status, expert_id)
  values ('zzd_solo', 'Verify Solo Doctor', 'doctor', 'active', 'zzd_me');
  delete from public.partner_accounts where user_id = v_doc;
  delete from public.expert_accounts  where user_id = v_doc;
  insert into public.expert_accounts (user_id, expert_id) values (v_doc, 'zzd_me');

  delete from public.partner_attributions where user_id = any (v_fam);
  insert into public.partner_attributions
    (user_id, partner_id, token, signed_up_at)
  values (v_fam[1], 'zzd_solo', 'ZZD-1', now()),
         (v_fam[2], 'zzd_solo', 'ZZD-2', now());
  insert into public.parent_timeline (user_id, event)
  values (v_fam[1], 'pregnancy_added');

  update public.sponsor_analytics_config set min_cohort = 5 where id = 'default';

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_doc::text, 'role', 'authenticated')::text, true);

  -- ---- 1. two families, threshold 5: held back -----------------------
  select * into i from public.partner_impact('zzd_solo');
  select * into f from public.partner_funnel('zzd_solo');
  if i.families_referred = 2 and i.suppressed and i.min_cohort = 5
     and i.pregnancies_supported is null and i.children_added is null
     and i.consultations_done is null and i.vaccinations_completed is null
     and i.content_consumed is null
    then pass := pass + 1; r := r || E'\nok    2 families, min 5             -> behaviour held back, families shown';
    else fail := fail + 1; r := r || E'\nFAIL  2 families, min 5             -> ' || row_to_json(i)::text;
  end if;
  if f.signed_up = 2 and f.activated is null
    then pass := pass + 1; r := r || E'\nok    funnel, min 5                 -> signed up shown, activated held back';
    else fail := fail + 1; r := r || E'\nFAIL  funnel, min 5                 -> ' || row_to_json(f)::text;
  end if;

  -- ---- 2. threshold 2: shown ------------------------------------------
  update public.sponsor_analytics_config set min_cohort = 2 where id = 'default';
  select * into i from public.partner_impact('zzd_solo');
  select * into f from public.partner_funnel('zzd_solo');
  if not i.suppressed and i.pregnancies_supported >= 1 and f.activated >= 1
    then pass := pass + 1; r := r || E'\nok    min 2                         -> behaviour shown';
    else fail := fail + 1; r := r || E'\nFAIL  min 2                         -> ' || row_to_json(i)::text;
  end if;

  -- ---- 3. someone else's partner: nothing -----------------------------
  delete from public.expert_accounts where user_id = v_doc;
  select * into i from public.partner_impact('zzd_solo');
  if i.families_referred = 0 and i.pregnancies_supported is null and i.suppressed
    then pass := pass + 1; r := r || E'\nok    not her partner               -> 0 families, nothing else';
    else fail := fail + 1; r := r || E'\nFAIL  not her partner               -> ' || row_to_json(i)::text;
  end if;

  perform set_config('request.jwt.claims', null, true);

  raise exception E'\n\n=== DOCTOR IMPACT VERIFICATION (0141) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
