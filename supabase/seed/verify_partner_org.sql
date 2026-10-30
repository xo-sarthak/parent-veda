-- =====================================================================
-- verify_partner_org.sql -- prove my_partner_org() and the seatless
--                           admin (0136) against real tables.
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0136, paste the whole file into the Supabase SQL
-- editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls the whole transaction back: the
-- fixture sponsor and clinic, and every change to the borrowed user's
-- rows below, never reach your data.
--
-- IMPERSONATION, as verify_sponsor_gates.sql: my_partner_org() reads
-- auth.uid(), so this borrows the OLDEST existing auth user and sets the
-- JWT claim for the transaction. To test each answer from a clean start
-- it first clears that user's expert, partner, sponsor and profile role
-- rows -- INSIDE the transaction, so the rollback restores them.
--
-- Each step adds one grant and checks the answer moves the way the
-- header of 0136 says: nothing -> parent -> doctor -> care_org ->
-- sponsor (sponsor wins) -> paused -> ended.
-- =====================================================================

do $$
declare
  r      text := '';
  pass   int  := 0;
  fail   int  := 0;
  js     jsonb;
  v_uid  uuid;
begin
  select id into v_uid from auth.users order by created_at limit 1;
  if v_uid is null then
    raise exception E'\n\n=== PARTNER ORG VERIFICATION (0136) ===\n\nSKIPPED: no auth.users rows to borrow.\n';
  end if;

  -- ---- fixtures ---------------------------------------------------
  insert into public.sponsors (id, name, kind, plan_id, status)
  values ('zzp_sponsor', 'Verify School', 'school', 'employer_standard', 'active');

  insert into public.care_partners (id, name, type, status)
  values ('zzp_ivf', 'Verify IVF Centre', 'ivf_centre', 'active');

  -- A clean start for the borrowed user (rolled back at the end).
  delete from public.sponsor_admins   where user_id = v_uid;
  delete from public.sponsor_members  where user_id = v_uid;
  delete from public.partner_accounts where user_id = v_uid;
  delete from public.expert_accounts  where user_id = v_uid;
  update public.profiles set role = null, due_date = null where id = v_uid;

  -- ---- 0. nobody signed in ----------------------------------------
  perform set_config('request.jwt.claims', null, true);
  js := public.my_partner_org();
  if (js ->> 'code') = 'not_signed_in'
    then pass := pass + 1; r := r || E'\nok    nobody signed in               -> not_signed_in';
    else fail := fail + 1; r := r || E'\nFAIL  nobody signed in               -> ' || js::text;
  end if;

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_uid::text, 'role', 'authenticated')::text, true);

  -- ---- 1. a login with nothing ------------------------------------
  js := public.my_partner_org();
  if (js ->> 'ok') = 'false' and (js ->> 'code') = 'not_an_admin'
    then pass := pass + 1; r := r || E'\nok    no grant at all                -> not_an_admin';
    else fail := fail + 1; r := r || E'\nFAIL  no grant at all                -> ' || js::text;
  end if;

  -- ---- 2. a parent ------------------------------------------------
  insert into public.profiles (id, role) values (v_uid, 'mother')
  on conflict (id) do update set role = 'mother';
  js := public.my_partner_org();
  if (js ->> 'code') = 'parent'
    then pass := pass + 1; r := r || E'\nok    onboarded parent               -> parent';
    else fail := fail + 1; r := r || E'\nFAIL  onboarded parent               -> ' || js::text;
  end if;

  -- ---- 3. a doctor (outranks parent: the doctor app is the door) ---
  insert into public.expert_accounts (user_id, expert_id) values (v_uid, 'zzp_expert');
  js := public.my_partner_org();
  if (js ->> 'code') = 'doctor'
    then pass := pass + 1; r := r || E'\nok    expert account                 -> doctor';
    else fail := fail + 1; r := r || E'\nFAIL  expert account                 -> ' || js::text;
  end if;

  -- ---- 4. an IVF centre login (Route A) ----------------------------
  insert into public.partner_accounts (user_id, partner_id, label)
  values (v_uid, 'zzp_ivf', 'verify');
  js := public.my_partner_org();
  if (js ->> 'ok') = 'true' and (js ->> 'kind') = 'care_org' and (js ->> 'id') = 'zzp_ivf'
    then pass := pass + 1; r := r || E'\nok    partner_accounts row           -> care_org';
    else fail := fail + 1; r := r || E'\nFAIL  partner_accounts row           -> ' || js::text;
  end if;

  -- ---- 5. a seatless sponsor admin: sponsor wins -------------------
  insert into public.sponsor_admins (user_id, sponsor_id, added_by)
  values (v_uid, 'zzp_sponsor', 'verify');
  js := public.my_partner_org();
  if (js ->> 'kind') = 'sponsor' and (js ->> 'sponsor_kind') = 'school'
     and (js ->> 'status') = 'active'
    then pass := pass + 1; r := r || E'\nok    sponsor_admins + care_org      -> sponsor wins';
    else fail := fail + 1; r := r || E'\nFAIL  sponsor_admins + care_org      -> ' || js::text;
  end if;

  if public.my_sponsor_admin_id() = 'zzp_sponsor'
    then pass := pass + 1; r := r || E'\nok    my_sponsor_admin_id, no seat    -> the sponsor';
    else fail := fail + 1; r := r || E'\nFAIL  my_sponsor_admin_id, no seat    -> ' || coalesce(public.my_sponsor_admin_id(), 'null');
  end if;

  js := public.sponsor_dashboard();
  if (js ->> 'ok') is distinct from 'false'
    then pass := pass + 1; r := r || E'\nok    sponsor_dashboard, no seat      -> answers';
    else fail := fail + 1; r := r || E'\nFAIL  sponsor_dashboard, no seat      -> ' || js::text;
  end if;

  if not exists (select 1 from public.sponsor_members where user_id = v_uid)
    then pass := pass + 1; r := r || E'\nok    the admin took no seat';
    else fail := fail + 1; r := r || E'\nFAIL  the admin has a sponsor_members row';
  end if;

  -- ---- 6. paused: still named, numbers hidden (R2) -----------------
  update public.sponsors set status = 'suspended' where id = 'zzp_sponsor';
  js := public.my_partner_org();
  if (js ->> 'ok') = 'true' and (js ->> 'status') = 'suspended'
    then pass := pass + 1; r := r || E'\nok    suspended sponsor              -> named, status suspended';
    else fail := fail + 1; r := r || E'\nFAIL  suspended sponsor              -> ' || js::text;
  end if;

  if public.my_sponsor_admin_id() is null
     and (public.sponsor_dashboard() ->> 'code') = 'not_a_sponsor_admin'
    then pass := pass + 1; r := r || E'\nok    suspended sponsor              -> dashboard hidden';
    else fail := fail + 1; r := r || E'\nFAIL  suspended sponsor              -> dashboard still answers';
  end if;

  -- ---- 7. ended -----------------------------------------------------
  update public.sponsors set status = 'ended' where id = 'zzp_sponsor';
  js := public.my_partner_org();
  if (js ->> 'status') = 'ended'
    then pass := pass + 1; r := r || E'\nok    ended sponsor                  -> status ended';
    else fail := fail + 1; r := r || E'\nFAIL  ended sponsor                  -> ' || js::text;
  end if;

  -- ---- 8. no client writes to the role ------------------------------
  if not exists (
    select 1 from pg_policies
     where schemaname = 'public' and tablename = 'sponsor_admins'
       and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL'))
    then pass := pass + 1; r := r || E'\nok    sponsor_admins has no write policy';
    else fail := fail + 1; r := r || E'\nFAIL  sponsor_admins has a write policy';
  end if;

  perform set_config('request.jwt.claims', null, true);

  raise exception E'\n\n=== PARTNER ORG VERIFICATION (0136) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
