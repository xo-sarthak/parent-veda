-- =====================================================================
-- verify_remove_self.sql -- 0138, run as a signed-in admin, kept nothing.
-- ---------------------------------------------------------------------
-- WHY THIS FILE EXISTS. 0138's VERIFY lines cannot be run as written in
-- the SQL editor: the editor is `postgres` with no signed-in user, so
-- auth.uid() is null, my_sponsor_admin_id() finds no admin, and every
-- call stops at the first gate with not_a_sponsor_admin. That answer is
-- correct, and it proves nothing about the new guard.
--
-- So this borrows two real logins, makes a throwaway sponsor, signs in
-- as one of them by setting request.jwt.claims (what auth.uid() reads),
-- and checks the four answers. It ends by RAISING the report, which
-- rolls everything back: no fixture, audit row or removal survives.
--
-- Run the whole file in the Supabase SQL editor. The "error" is the report.
-- =====================================================================

do $$
declare
  r        text := '';
  pass     int  := 0;
  fail     int  := 0;
  js       jsonb;
  v_admin  uuid;
  v_other  uuid;
  v_status text;
begin
  select id into v_admin from auth.users order by created_at limit 1;
  select id into v_other from auth.users order by created_at offset 1 limit 1;
  if v_other is null then
    raise exception E'\n\n=== REMOVE-SELF VERIFICATION (0138) ===\n\nSKIPPED: needs two auth.users rows to borrow.\n';
  end if;

  -- ---- fixtures (rolled back) --------------------------------------
  insert into public.sponsors (id, name, kind, plan_id, status)
  values ('zzr_sponsor', 'Verify Remove Co', 'employer', 'employer_standard', 'active');

  -- The borrowed admin runs only this sponsor while the test lasts.
  delete from public.sponsor_admins where user_id = v_admin;

  -- ---- 1. not an admin yet ------------------------------------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_admin::text, 'role', 'authenticated')::text, true);
  delete from public.sponsor_members where user_id = v_admin;
  js := public.sponsor_remove_member('nobody@nowhere.test');
  if (js ->> 'code') = 'not_a_sponsor_admin'
    then pass := pass + 1; r := r || E'\nok    no admin row                 -> not_a_sponsor_admin';
    else fail := fail + 1; r := r || E'\nFAIL  no admin row                 -> ' || js::text;
  end if;

  -- The admin, who is ALSO an active member, under a work address that
  -- is not their login email (the case only the server can catch).
  insert into public.sponsor_admins (user_id, sponsor_id) values (v_admin, 'zzr_sponsor');
  insert into public.sponsor_members (user_id, sponsor_id, work_email, status)
  values (v_admin, 'zzr_sponsor', 'zz-self@verify-remove.test', 'active');
  insert into public.sponsor_members (user_id, sponsor_id, work_email, status)
  values (v_other, 'zzr_sponsor', 'zz-other@verify-remove.test', 'active');

  -- ---- 2. removing yourself is refused, and nothing changes --------
  js := public.sponsor_remove_member('zz-self@verify-remove.test');
  select status into v_status from public.sponsor_members
   where user_id = v_admin and sponsor_id = 'zzr_sponsor';
  if (js ->> 'code') = 'cannot_remove_self' and v_status = 'active'
    then pass := pass + 1; r := r || E'\nok    remove yourself              -> cannot_remove_self, still active';
    else fail := fail + 1; r := r || E'\nFAIL  remove yourself              -> ' || js::text || ' / ' || coalesce(v_status, 'null');
  end if;

  -- ---- 3. someone else, as before ----------------------------------
  js := public.sponsor_remove_member('ZZ-Other@verify-remove.test');
  select status into v_status from public.sponsor_members
   where user_id = v_other and sponsor_id = 'zzr_sponsor';
  if (js ->> 'ok') = 'true' and v_status = 'removed'
    then pass := pass + 1; r := r || E'\nok    remove a colleague           -> ok, removed';
    else fail := fail + 1; r := r || E'\nFAIL  remove a colleague           -> ' || js::text || ' / ' || coalesce(v_status, 'null');
  end if;

  -- ---- 4. an address that is not a member ---------------------------
  js := public.sponsor_remove_member('nobody@nowhere.test');
  if (js ->> 'code') = 'not_a_member'
    then pass := pass + 1; r := r || E'\nok    unknown address              -> not_a_member';
    else fail := fail + 1; r := r || E'\nFAIL  unknown address              -> ' || js::text;
  end if;

  perform set_config('request.jwt.claims', null, true);
  raise exception E'\n\n=== REMOVE-SELF VERIFICATION (0138) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end;
$$;
