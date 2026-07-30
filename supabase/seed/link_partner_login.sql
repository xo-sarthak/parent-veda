-- =====================================================================
-- link_partner_login.sql -- attach YOUR login to a partner, so the
-- partner view has an identity to resolve
-- ---------------------------------------------------------------------
-- NOT a migration. Run by hand in the Supabase SQL editor, which runs as
-- postgres/service_role -- which is the point: link_partner_account() is
-- revoked from clients on purpose. Attaching a login to a partner grants
-- sight of that partner's numbers, so it is an editorial act, the same
-- class as verifying one.
--
-- WITHOUT THIS the partner view still opens, and correctly finds nothing:
-- my_care_partner() returns no row, the dashboard shows no numbers and the
-- referral kit says "not set up yet". That is the honest failure. The old
-- behaviour was worse — it resolved the FIRST doctor in the catalogue and
-- presented a stranger's name as yours.
--
-- THIS IS A MENU, NOT A SCRIPT. Do not run the whole file: steps 1 and 2
-- are queries, and steps 3a/3b are alternatives, so running everything
-- top-to-bottom either links the wrong account or fails on a placeholder
-- address. Run step 1, then UNCOMMENT exactly one of 3a / 3b.
--
-- PREREQ: 0037, 0040, 0068, and care_partner_demo_orgs.sql for the demo
-- organisations.
-- =====================================================================

-- 1. Who am I? Find your own auth user.
select id, email, created_at
  from auth.users
 order by created_at desc
 limit 10;


-- 2. Which partners can I sign in as?
--    expert_id null = an organisation, i.e. the case that needed 0068.
select id,
       name,
       type,
       status,
       coalesce(expert_id, '(no expert record)') as expert_id
  from public.care_partners
 where deleted_at is null
 order by (expert_id is null) desc, name;


-- 3. Link them. Two ways; pick one.
--
-- 3a. BY EMAIL -- the one to use. Uncomment, and replace the address with one
--     step 1 actually printed. A sub-select matching nothing returns NULL
--     rather than erroring, so a wrong address yields a null user_id; 0068
--     raises a readable exception for that rather than a not-null constraint
--     violation. If it complains, the login does not exist yet -- sign in
--     once in the app first.
-- select public.link_partner_account(
--   (select id from auth.users where email = 'you@example.com'),
--   'demo_org_ivf',              -- Nova IVF Fertility
--   'testing'
-- );


-- 3b. THE MOST RECENT LOGIN, whatever its address. It cannot miss, but it also
--     does not ask -- it will happily link a throwaway test account, so check
--     step 4 afterwards to see WHICH email it chose. Use INSTEAD of 3a.
-- select public.link_partner_account(
--   (select id from auth.users order by created_at desc limit 1),
--   'demo_org_ivf',
--   'testing'
-- );


-- 4. Confirm. This is what the app will resolve on sign-in.
--    NOTE: run as your OWN user for a true check — in the SQL editor
--    auth.uid() is null, so my_care_partner() returns nothing here even
--    when the link is correct. The row below is the direct proof instead.
select pa.user_id, pa.partner_id, pa.label, cp.name, cp.type, cp.status
  from public.partner_accounts pa
  join public.care_partners cp on cp.id = pa.partner_id;


-- 5. To move your login to a different partner, re-run step 3 with another
--    id — it upserts on user_id, so one login maps to one partner at a time.
--    Swap 'demo_org_ivf' for:
--       demo_org_lab    Aarogya Diagnostics    (diagnostic_lab)
--       demo_org_corp   Infosys Wellbeing      (corporate)
--       demo_hospital   Rainbow Children's     (hospital)
--       demo_meera      Dr Meera Rao           (doctor, has no expert link
--                                               either — so this tests a
--                                               PERSON on the direct route)


-- 6. Unlink, when you are done testing.
-- delete from public.partner_accounts where user_id =
--   (select id from auth.users where email = 'ishaansingh2512@gmail.com');
