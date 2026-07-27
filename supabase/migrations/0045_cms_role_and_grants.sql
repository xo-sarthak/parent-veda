-- =====================================================================
-- 0045_cms_role_and_grants.sql -- a database role Directus cannot
--                                 escape from.
-- ---------------------------------------------------------------------
-- WHY THIS EXISTS, AND WHY IT IS FIRST
--
-- Directus connects to Supabase today with a broadly privileged pooler
-- user. That was fine while exactly one person -- the owner -- had a
-- login. It stops being fine the moment a content editor gets an
-- account, because Directus's own permission screens are a CONVENIENCE
-- layer, not a boundary: they are rows in directus_permissions, edited
-- through the same admin UI they are supposed to restrain. One
-- mis-click in Settings -> Data Model registering `profiles` or
-- `journal_entries` as a collection, and every mother's data is one
-- click further from private.
--
-- The boundary has to live where the UI cannot reach it: in Postgres
-- grants. After this migration Directus logs in as `directus_cms`,
-- which has been granted, table by table, ONLY what an editor and an
-- ops person legitimately need. Everything else is not "hidden" -- it
-- is unreadable, at the database, regardless of what any panel says.
--
-- A useful side effect: information_schema filters by privilege, and
-- Directus's schema inspector reads information_schema. So the
-- user-data tables should not even APPEAR in the "register a
-- collection" list. Verify that rather than trust it -- see the
-- checks at the bottom.
--
-- ---------------------------------------------------------------------
-- THE SHAPE
--
--   content  (articles, content_posts, content_categories)  -> full CRUD
--   config   (the six seeded settings tables)               -> select + update
--   records  (care_partners, partner_referrals)             -> select only;
--                                                              writes go through
--                                                              security-definer
--                                                              functions (0040)
--   askveda  (veda_drafts, veda_content_gaps)               -> the editorial inbox
--   everything else                                          -> NO GRANT AT ALL
--
-- "No grant at all" is the default in Postgres -- a newly created role
-- has no privileges on existing tables, and this repo grants only to
-- `anon`, `authenticated` and `service_role`, never to PUBLIC. So the
-- deny list is not enumerated here on purpose: enumerating it would
-- rot the day someone adds table 77 and forgets to add it to a list.
-- Default-deny does not rot.
--
-- ---------------------------------------------------------------------
-- RLS: WHY GRANTS ALONE ARE NOT ENOUGH
--
-- Every content and config table has RLS enabled with a policy shaped
-- `using (status = 'published')` or `using (true)` for reading. A grant
-- gets `directus_cms` past the privilege check; the POLICY still
-- applies, because it does not own these tables. Without a policy of
-- its own, Directus would connect successfully, list the collection,
-- and show an editor everything except their own drafts -- which is
-- the single most confusing failure this could ship with.
--
-- So each granted table gets one explicit permissive policy for this
-- role. They are deliberately verbose rather than clever: a reader
-- should be able to answer "what can the CMS touch?" by grepping for
-- `to directus_cms` and reading the list.
--
-- ---------------------------------------------------------------------
-- THE PASSWORD IS NOT IN THIS FILE, AND MUST NOT BE
--
-- This file is committed to git. The role is created WITHOUT a
-- password; set it once, by hand, in the Supabase SQL editor:
--
--     alter role directus_cms with password '<generate a long random one>';
--
-- Then put that value in Render's environment for the Directus service.
-- If the password ever lands in a commit, rotate it -- git history is
-- not a place secrets can be deleted from.
--
-- PREREQ: none. Safe to re-run (every statement is guarded).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The role.
--
-- NOINHERIT matters: without it, any role membership granted later
-- (deliberately or by a tool) would silently widen what Directus can
-- reach. NOINHERIT means privileges have to be requested explicitly
-- with SET ROLE, which the Directus connection never does.
-- ---------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'directus_cms') then
    create role directus_cms with login noinherit;
  end if;
end $$;

comment on role directus_cms is
  'Directus CMS connection. Allow-list grants only -- see 0045_cms_role_and_grants.sql. Never grant this role membership of authenticated/service_role.';

-- Postgres will not let you hand a table to a role you are not a member
-- of ("must be able to SET ROLE"), and creating a role does not make you
-- one. Section 3 transfers the directus_* tables, so grant the
-- membership first or that transfer fails and the whole migration rolls
-- back.
--
-- This widens `postgres`, not `directus_cms` -- role membership only
-- flows one way. The admin gains the CMS role's privileges (it already
-- had them all); the CMS gains nothing. NOINHERIT above is what keeps
-- that true in the other direction.
do $$
begin
  execute format('grant directus_cms to %I', current_user);
end $$;


-- ---------------------------------------------------------------------
-- 2. Schema access.
--
-- CREATE is required, not optional: Directus keeps its OWN system
-- tables (directus_users, directus_fields, directus_flows, ...) in this
-- same `public` schema, and creates or alters them during version
-- upgrades. Take CREATE away and Directus boots until the next upgrade,
-- then fails in a way that looks like a Directus bug rather than a
-- permission problem.
--
-- This does mean the role can create tables. It still cannot read a
-- single row of anyone's journal, which is the property that matters.
-- ---------------------------------------------------------------------
grant usage, create on schema public to directus_cms;


-- ---------------------------------------------------------------------
-- 3. Directus's own system tables.
--
-- They exist already, created by the previous connection user, so the
-- new role would not be able to alter them on upgrade. Hand them over.
-- Ownership (rather than a pile of grants) is deliberate: Directus
-- issues DDL against these, and DDL needs ownership.
--
-- Table owners bypass RLS -- which is correct and harmless here,
-- because these tables hold Directus's own users and settings, not
-- ParentVeda data.
-- ---------------------------------------------------------------------
-- If ownership cannot be transferred (a managed platform may refuse it),
-- fall back to full privileges rather than aborting: full privileges are
-- enough for every day-to-day operation, and only a future Directus
-- version upgrade that runs DDL would notice the difference. A migration
-- that rolls back entirely over this would be a far worse outcome than
-- one that degrades and says so.
do $$
declare
  obj record;
begin
  for obj in
    select tablename as name from pg_tables
     where schemaname = 'public' and tablename like 'directus\_%'
  loop
    begin
      execute format('alter table public.%I owner to directus_cms', obj.name);
    exception when insufficient_privilege then
      execute format(
        'grant all privileges on table public.%I to directus_cms', obj.name);
      raise notice
        'Could not transfer ownership of %; granted all privileges instead. '
        'Directus will work, but a future version upgrade may need this run '
        'as a more privileged user.', obj.name;
    end;
  end loop;

  for obj in
    select sequencename as name from pg_sequences
     where schemaname = 'public' and sequencename like 'directus\_%'
  loop
    begin
      execute format('alter sequence public.%I owner to directus_cms', obj.name);
    exception when insufficient_privilege then
      execute format(
        'grant all privileges on sequence public.%I to directus_cms', obj.name);
    end;
  end loop;
end $$;


-- ---------------------------------------------------------------------
-- 4. CONTENT -- full CRUD. This is the editor's desk.
--
-- The `for all ... using (true) with check (true)` policy is what lets
-- an editor see and edit DRAFTS. The public-read policies added by
-- 0019/0020 are untouched and still govern anon/authenticated, so the
-- app and website continue to see published rows only.
-- ---------------------------------------------------------------------
grant select, insert, update, delete on public.articles           to directus_cms;
grant select, insert, update, delete on public.content_posts      to directus_cms;
grant select, insert, update, delete on public.content_categories to directus_cms;

drop policy if exists "articles cms write"           on public.articles;
drop policy if exists "content_posts cms write"      on public.content_posts;
drop policy if exists "content_categories cms write" on public.content_categories;

create policy "articles cms write" on public.articles
  for all to directus_cms using (true) with check (true);
create policy "content_posts cms write" on public.content_posts
  for all to directus_cms using (true) with check (true);
create policy "content_categories cms write" on public.content_categories
  for all to directus_cms using (true) with check (true);


-- ---------------------------------------------------------------------
-- 5. CONFIG -- select + update only. No insert, no delete.
--
-- These tables are seeded to match the values compiled into the app,
-- and a parity test (test/care_partner_config_test.dart) fails if they
-- drift. The rows are therefore not the panel's to create or destroy --
-- only to change. Withholding insert/delete is what turns "please
-- don't add rows here" from a note in a doc into a database rule.
--
-- referral_config is the one exception worth understanding: it has a
-- partial unique index allowing exactly one active campaign, so even
-- an accidental second row could not become live.
-- ---------------------------------------------------------------------
grant select, update on public.referral_config       to directus_cms;
grant select, update on public.care_visibility_rules to directus_cms;
grant select, update on public.care_trust_messages   to directus_cms;
grant select, update on public.care_commission_rules to directus_cms;
grant select, update on public.care_partner_config   to directus_cms;
grant select, update on public.wa_message_templates  to directus_cms;

drop policy if exists "referral_config cms edit"       on public.referral_config;
drop policy if exists "care_visibility_rules cms edit" on public.care_visibility_rules;
drop policy if exists "care_trust_messages cms edit"   on public.care_trust_messages;
drop policy if exists "care_commission_rules cms edit" on public.care_commission_rules;
drop policy if exists "care_partner_config cms edit"   on public.care_partner_config;
drop policy if exists "wa_message_templates cms edit"  on public.wa_message_templates;

create policy "referral_config cms edit" on public.referral_config
  for all to directus_cms using (true) with check (true);
create policy "care_visibility_rules cms edit" on public.care_visibility_rules
  for all to directus_cms using (true) with check (true);
create policy "care_trust_messages cms edit" on public.care_trust_messages
  for all to directus_cms using (true) with check (true);
create policy "care_commission_rules cms edit" on public.care_commission_rules
  for all to directus_cms using (true) with check (true);
create policy "care_partner_config cms edit" on public.care_partner_config
  for all to directus_cms using (true) with check (true);
create policy "wa_message_templates cms edit" on public.wa_message_templates
  for all to directus_cms using (true) with check (true);

-- Note for whoever builds the config forms: the CHECK constraint on
-- care_trust_messages rejects sponsor/advert/promot/"ad by" wording.
-- The panel must SURFACE that error to the editor. Working around it --
-- by editing care_partners.trust instead, which is unconstrained jsonb --
-- would defeat the only thing enforcing "never Sponsored by".


-- ---------------------------------------------------------------------
-- 6. RECORDS -- read only, on purpose.
--
-- A partner is created by create_care_partner() and a token by
-- mint_partner_token() (0040), both security-definer, both granted to
-- service_role alone. The panel calls those functions; it does not
-- insert here.
--
-- The reason is written on a clinic wall somewhere: the app used to
-- DERIVE a printed token while the website resolved it against
-- partner_referrals. A missing row produced a QR that scanned, looked
-- correct, and credited nobody -- on something printed and stuck up for
-- two years. One writer, one way. Granting insert here would quietly
-- recreate the second way.
-- ---------------------------------------------------------------------
grant select on public.care_partners     to directus_cms;
grant select on public.partner_referrals to directus_cms;

drop policy if exists "care_partners cms read"     on public.care_partners;
drop policy if exists "partner_referrals cms read" on public.partner_referrals;

create policy "care_partners cms read" on public.care_partners
  for select to directus_cms using (true);
create policy "partner_referrals cms read" on public.partner_referrals
  for select to directus_cms using (true);


-- ---------------------------------------------------------------------
-- 7. Ask Veda's editorial inbox -- if those tables exist yet.
--
-- veda_drafts  = answers the RAG service drafted from a trusted-web
--                fallback, waiting for a human to approve or bin them.
-- veda_content_gaps = questions mothers asked that we had no good answer
--                for, with an ask_count. Sorted desc, it is literally
--                the "what should we write next" board.
--
-- Both live in the AskVeda repo's sql/ and may not have been run yet,
-- so this is guarded rather than assumed. Status changes only -- the
-- panel reviews these, it does not author into them.
-- ---------------------------------------------------------------------
do $$
begin
  if to_regclass('public.veda_drafts') is not null then
    grant select, update on public.veda_drafts to directus_cms;
    drop policy if exists "veda_drafts cms review" on public.veda_drafts;
    create policy "veda_drafts cms review" on public.veda_drafts
      for all to directus_cms using (true) with check (true);
  end if;

  if to_regclass('public.veda_content_gaps') is not null then
    grant select, update on public.veda_content_gaps to directus_cms;
    drop policy if exists "veda_content_gaps cms review" on public.veda_content_gaps;
    create policy "veda_content_gaps cms review" on public.veda_content_gaps
      for all to directus_cms using (true) with check (true);
  end if;
end $$;

-- Deliberately NOT granted: veda_content_chunks, veda_cache,
-- veda_usage_log, veda_knowledge. The first three are machine state
-- (embeddings, cache, cost log) and editing them by hand corrupts
-- retrieval. veda_knowledge is the app's exported Dart corpus -- an
-- edit there is overwritten by the next export, so offering it to an
-- editor would be offering them work that silently disappears.


-- ---------------------------------------------------------------------
-- 8. Belt and braces on anything created later.
--
-- Supabase sets default privileges that auto-grant new tables to anon /
-- authenticated / service_role. None of those defaults name this role,
-- so a future table is already unreachable by it -- but stating the
-- intent means a future `alter default privileges` cannot widen the CMS
-- by accident.
--
-- Consequence to remember: every NEW content table must add its own
-- grant + policy for directus_cms, or it will not appear in Directus.
-- That is the intended friction. Step 4 of the add-a-type recipe in
-- docs/CONTENT-BACKEND.md.
-- ---------------------------------------------------------------------
alter default privileges in schema public revoke all on tables    from directus_cms;
alter default privileges in schema public revoke all on sequences from directus_cms;


-- =====================================================================
-- VERIFY -- run these after switching Directus over.
-- ---------------------------------------------------------------------
-- (a) What can the CMS role actually touch? Should be ~13 rows, all of
--     them content/config/records. If a pp_*, ttc_*, journal or profile
--     table appears here, stop and fix it before letting anyone log in.
--
--     select table_name, string_agg(privilege_type, ', ' order by privilege_type)
--       from information_schema.role_table_grants
--      where grantee = 'directus_cms'
--        and table_name not like 'directus\_%'
--      group by table_name
--      order by table_name;
--
-- (b) Prove a user-data table is unreachable, rather than assuming it:
--
--     set role directus_cms;
--     select count(*) from public.journal_entries;   -- expect: permission denied
--     select count(*) from public.profiles;          -- expect: permission denied
--     select count(*) from public.articles;          -- expect: a number
--     reset role;
--
-- (c) Prove drafts are visible to the CMS but not to the app:
--
--     set role directus_cms;   select count(*) from public.articles;  -- all rows
--     set role anon;           select count(*) from public.articles;  -- published only
--     reset role;
--
-- ---------------------------------------------------------------------
-- SWITCHING DIRECTUS OVER (Render)
--
-- 1. alter role directus_cms with password '<long random>';   -- SQL editor, once
-- 2. Render -> parentveda-cms -> Environment:
--      DB_USER     = directus_cms.<project-ref>   -- the pooler wants role.ref
--      DB_PASSWORD = <the value from step 1>
--    Leave DB_HOST / DB_PORT / DB_DATABASE alone -- still the Session pooler.
-- 3. Redeploy, then run check (a) above.
-- 4. If Directus fails to boot, it is almost always the pooler username
--    format in step 2, not the grants.
--
-- ROLLING BACK: put the old DB_USER/DB_PASSWORD back and redeploy.
-- Nothing in this migration changes how the app, the website or Ask Veda
-- reach Supabase -- they use PostgREST with the anon and service_role
-- keys and are untouched by any of it.
-- =====================================================================
