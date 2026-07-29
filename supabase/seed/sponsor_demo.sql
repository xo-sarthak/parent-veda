-- =====================================================================
-- sponsor_demo.sql -- one working sponsor, so activation can be shown
--                     to a person rather than described to them.
-- ---------------------------------------------------------------------
-- NOT a migration. Migrations run everywhere including production; this
-- creates a sponsor with a bypass code and must be run deliberately,
-- once, by someone who intends it.
--
-- Run it, then in the app: Profile -> Employer Benefits -> Activate,
-- type any address at @parentveda-demo.com, and when it asks for the
-- code, type the bypass string below.
--
-- Everything else on the path is real: the domain is matched, the
-- sponsor must be active, the seat count is enforced, the rate limit
-- applies, and the code row is consumed so it is single-use. Only the
-- inbox is skipped -- see 0059 for why that is the honest way to do it.
--
-- ⚠️ Two seats on purpose. A demo where the third person is refused is
-- a better demo than one where nothing ever says no, and it exercises
-- the no_seats_left path in front of the audience rather than in a test.
-- =====================================================================

insert into public.sponsors
  (id, name, kind, plan_id, seats_purchased, status, renewal_at,
   support_contact, dev_bypass_code)
values
  ('demo_northwind', 'Northwind Technologies', 'employer',
   'employer_standard', 2, 'active', (current_date + interval '11 months')::date,
   'people@parentveda-demo.com', 'DEMO-ACTIVATE-2026')
on conflict (id) do update set
  status          = 'active',
  seats_purchased = 2,
  dev_bypass_code = 'DEMO-ACTIVATE-2026';

insert into public.sponsor_domains (domain, sponsor_id) values
  ('parentveda-demo.com', 'demo_northwind')
on conflict (domain) do nothing;


-- ---------------------------------------------------------------------
-- Making yourself the HR admin.
--
-- Deliberately a separate, manual step. An admin must ALSO be an active
-- member (0060 resolves the sponsor from membership), so activate in
-- the app first, then run this with your own auth uid:
--
--   select id, email from auth.users order by created_at desc limit 5;
--
--   select public.grant_plan(
--     '<your-auth-uid>'::uuid, 'sponsor_admin', 'internal',
--     'demo_northwind', null, 'demo setup');
--
-- Then pull to refresh in the app: a Programme card appears in Profile.
-- ---------------------------------------------------------------------


-- =====================================================================
-- CLEANUP -- removes the sponsor, its domain, its members and their
-- codes by cascade. It does NOT remove the entitlement rows those
-- activations granted, because deleting a grant is a different act from
-- deleting a customer; revoke those explicitly first if you mean to.
--
--   select public.revoke_plan_by_source(m.user_id, 'sponsor',
--            'demo_northwind', 'demo cleanup')
--     from public.sponsor_members m where m.sponsor_id = 'demo_northwind';
--   delete from public.sponsors where id = 'demo_northwind';
-- =====================================================================
