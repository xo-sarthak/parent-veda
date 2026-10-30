-- =====================================================================
-- verify_care_org_dashboard.sql -- prove care_org_dashboard() (0139)
--                                  against real tables.
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0139, paste the whole file into the Supabase SQL
-- editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls the whole transaction back: the
-- fixture centre, doctors and attributions, the threshold change, and
-- every change to the borrowed users' rows never reach your data.
--
-- IMPERSONATION, as verify_partner_org.sql: borrows the OLDEST auth user
-- as the centre's login and the next FOUR as families (an attribution is
-- keyed on a real auth user). Their own attributions and grants are
-- cleared INSIDE the transaction, so the rollback restores them. Needs
-- five auth users; says SKIPPED otherwise.
--
-- What it walks: nobody -> a login with nothing -> the centre's login
-- (held back below 5) -> threshold lowered (behaviour appears) -> the
-- dual login (her own practice's family is NOT counted) -> no family id
-- in the answer -> paused -> sponsor wins.
-- =====================================================================

do $$
declare
  r       text := '';
  pass    int  := 0;
  fail    int  := 0;
  js      jsonb;
  v_admin uuid;
  v_fam   uuid[];
  v_sum   int;
begin
  select id into v_admin from auth.users order by created_at limit 1;
  select array_agg(id order by created_at) into v_fam
    from (select id, created_at from auth.users
           order by created_at offset 1 limit 4) u;
  if v_admin is null or coalesce(array_length(v_fam, 1), 0) < 4 then
    raise exception E'\n\n=== CARE ORG DASHBOARD VERIFICATION (0139) ===\n\nSKIPPED: needs 5 auth.users rows to borrow.\n';
  end if;

  -- ---- fixtures ---------------------------------------------------
  insert into public.care_partners (id, name, type, status)
  values ('zzc_ivf', 'Verify IVF Centre', 'ivf_centre', 'active');
  -- The admin's OWN practice (Route B), for the dual-login step.
  insert into public.care_partners (id, name, type, status, expert_id)
  values ('zzc_solo', 'Verify Solo Practice', 'doctor', 'active', 'zzc_me');
  insert into public.sponsors (id, name, kind, plan_id, status)
  values ('zzc_sponsor', 'Verify Employer', 'employer', 'employer_standard', 'active');

  insert into public.expert_profiles (expert_id, partner_id, status, name)
  values ('zzc_doc1', 'zzc_ivf', 'published', 'Verify Doctor One'),
         ('zzc_doc2', 'zzc_ivf', 'published', 'Verify Doctor Two');

  -- A clean start for the borrowed users (rolled back at the end).
  delete from public.sponsor_admins   where user_id = v_admin;
  delete from public.sponsor_members  where user_id = v_admin;
  delete from public.partner_accounts where user_id = v_admin;
  delete from public.expert_accounts  where user_id = v_admin;
  delete from public.partner_attributions where user_id = any (v_fam);

  -- Three families of the centre: one by Doctor One's code, one by the
  -- centre's own code, one by a doctor no longer listed. The fourth is
  -- the admin's own practice's, and must never appear.
  insert into public.partner_attributions
    (user_id, partner_id, token, expert_id, signed_up_at)
  values (v_fam[1], 'zzc_ivf',  'ZZC-1', 'zzc_doc1', now()),
         (v_fam[2], 'zzc_ivf',  'ZZC-2', null,       now()),
         (v_fam[3], 'zzc_ivf',  'ZZC-3', 'zzc_gone', now()),
         (v_fam[4], 'zzc_solo', 'ZZC-4', null,       now());
  insert into public.parent_timeline (user_id, event)
  values (v_fam[1], 'pregnancy_added');

  update public.sponsor_analytics_config set min_cohort = 5 where id = 'default';

  -- ---- 0. nobody signed in ----------------------------------------
  perform set_config('request.jwt.claims', null, true);
  js := public.care_org_dashboard();
  if (js ->> 'code') = 'not_a_care_org'
    then pass := pass + 1; r := r || E'\nok    nobody signed in               -> not_a_care_org';
    else fail := fail + 1; r := r || E'\nFAIL  nobody signed in               -> ' || js::text;
  end if;

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_admin::text, 'role', 'authenticated')::text, true);

  -- ---- 1. a login with nothing ------------------------------------
  js := public.care_org_dashboard();
  if (js ->> 'ok') = 'false' and (js ->> 'code') = 'not_a_care_org'
    then pass := pass + 1; r := r || E'\nok    no grant at all                -> not_a_care_org';
    else fail := fail + 1; r := r || E'\nFAIL  no grant at all                -> ' || js::text;
  end if;

  -- ---- 2. the centre's login, below the threshold -------------------
  insert into public.partner_accounts (user_id, partner_id, label)
  values (v_admin, 'zzc_ivf', 'verify');
  js := public.care_org_dashboard();
  if (js ->> 'ok') = 'true' and (js ->> 'families')::int = 3
     and (js ->> 'suppressed') = 'true' and (js ->> 'min_cohort')::int = 5
     and js -> 'pregnancies' = 'null'::jsonb and js -> 'activated' = 'null'::jsonb
    then pass := pass + 1; r := r || E'\nok    centre, 3 families, min 5      -> behaviour held back';
    else fail := fail + 1; r := r || E'\nFAIL  centre below threshold         -> ' || js::text;
  end if;

  select sum((d ->> 'families')::int) into v_sum
    from jsonb_array_elements(js -> 'doctors') d;
  if v_sum = 3
     and exists (select 1 from jsonb_array_elements(js -> 'doctors') d
                  where d ->> 'who' = 'doctor' and d ->> 'name' = 'Verify Doctor One'
                    and (d ->> 'families')::int = 1)
     and exists (select 1 from jsonb_array_elements(js -> 'doctors') d
                  where d ->> 'who' = 'doctor' and d ->> 'name' = 'Verify Doctor Two'
                    and (d ->> 'families')::int = 0)
     and exists (select 1 from jsonb_array_elements(js -> 'doctors') d
                  where d ->> 'who' = 'centre' and (d ->> 'families')::int = 1)
     and exists (select 1 from jsonb_array_elements(js -> 'doctors') d
                  where d ->> 'who' = 'former' and (d ->> 'families')::int = 1)
    then pass := pass + 1; r := r || E'\nok    per doctor: one, none, centre, former, sum 3';
    else fail := fail + 1; r := r || E'\nFAIL  per doctor                     -> ' || (js -> 'doctors')::text;
  end if;

  -- ---- 3. threshold lowered: behaviour appears ----------------------
  update public.sponsor_analytics_config set min_cohort = 2 where id = 'default';
  js := public.care_org_dashboard();
  if (js ->> 'suppressed') = 'false' and (js ->> 'pregnancies')::int >= 1
     and (js ->> 'min_cohort')::int = 2
    then pass := pass + 1; r := r || E'\nok    min 2                          -> behaviour shown';
    else fail := fail + 1; r := r || E'\nFAIL  min 2                          -> ' || js::text;
  end if;

  -- ---- 4. the dual login: also a doctor with her own practice -------
  insert into public.expert_accounts (user_id, expert_id) values (v_admin, 'zzc_me');
  js := public.care_org_dashboard();
  if (js ->> 'families')::int = 3 and (js ->> 'partner_id') = 'zzc_ivf'
    then pass := pass + 1; r := r || E'\nok    dual login                     -> centre only, own practice not mixed in';
    else fail := fail + 1; r := r || E'\nFAIL  dual login                     -> ' || js::text;
  end if;

  -- ---- 5. no family identifier anywhere in the answer ---------------
  if js::text not like '%' || v_fam[1]::text || '%'
     and js::text not like '%' || v_fam[2]::text || '%'
     and js::text not like '%ZZC-%'
    then pass := pass + 1; r := r || E'\nok    no family id or token in the answer';
    else fail := fail + 1; r := r || E'\nFAIL  a family id or token leaked';
  end if;

  -- ---- 6. paused ----------------------------------------------------
  update public.care_partners set status = 'inactive' where id = 'zzc_ivf';
  js := public.care_org_dashboard();
  if (js ->> 'code') = 'not_live'
    then pass := pass + 1; r := r || E'\nok    paused centre                  -> not_live';
    else fail := fail + 1; r := r || E'\nFAIL  paused centre                  -> ' || js::text;
  end if;
  update public.care_partners set status = 'active' where id = 'zzc_ivf';

  -- ---- 7. sponsor wins, as in my_partner_org() ----------------------
  insert into public.sponsor_admins (user_id, sponsor_id, added_by)
  values (v_admin, 'zzc_sponsor', 'verify');
  js := public.care_org_dashboard();
  if (js ->> 'code') = 'not_a_care_org'
    then pass := pass + 1; r := r || E'\nok    sponsor admin too              -> not_a_care_org (sponsor wins)';
    else fail := fail + 1; r := r || E'\nFAIL  sponsor admin too              -> ' || js::text;
  end if;

  perform set_config('request.jwt.claims', null, true);

  raise exception E'\n\n=== CARE ORG DASHBOARD VERIFICATION (0139) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
