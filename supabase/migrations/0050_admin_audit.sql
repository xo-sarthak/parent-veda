-- =====================================================================
-- 0050_admin_audit.sql -- what the panel did, and what it checked first.
-- ---------------------------------------------------------------------
-- Two tables that exist because of ONE decision: approving a doctor is an
-- editorial act, not a status dropdown.
--
--   admin_audit                 -- every privileged act, append-only
--   care_partner_verification   -- what was actually checked before one
--
-- WHY VERIFICATION IS NOT A COLUMN ON care_partners
--
-- care_partners is PUBLIC-READ, deliberately: a parent scanning a poster
-- must see "Invited by Dr Meera Rao" before she has an account. Its
-- policy is `using (deleted_at is null)` with no role restriction, so
-- ANY column added to that table is world-readable.
--
-- A medical council registration number and a KYC document reference are
-- not public identity - they are the professional's paperwork. Putting
-- them beside a photo and a speciality would publish them to every
-- anonymous visitor, silently, the moment the column was added.
--
-- So verification lives here, with RLS on and NO policy at all: with RLS
-- enabled a verb without a policy is denied outright, so nothing but
-- service_role can read a row. The panel writes it; nobody else sees it.
--
-- WHY AUDIT IS A TABLE AND NOT DIRECTUS ACTIVITY
--
-- directus_activity records that a Flow ran. It does not record what the
-- Flow asked the database to do, whether the database agreed, or what it
-- checked first. For content edits that is enough. For "who approved this
-- doctor, when, and on the strength of what" it is not - and that is
-- exactly the question anyone will ask after something goes wrong.
--
-- The audit row is written INSIDE each function (0051), so it cannot be
-- skipped by calling the function a different way.
--
-- PREREQ: 0037 (care_partners), 0045 (directus_cms).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The audit log.
--
-- Append-only by construction: service_role gets insert and select, and
-- nothing anywhere gets update or delete. An audit log you can edit is a
-- diary, not a record.
-- ---------------------------------------------------------------------
create table if not exists public.admin_audit (
  id           bigint generated always as identity primary key,
  actor        text        not null default 'unknown',
  action       text        not null,
  target_table text,
  target_id    text,
  args         jsonb       not null default '{}'::jsonb,
  outcome      text        not null default 'ok',   -- ok | refused
  detail       text,
  at           timestamptz not null default now()
);

comment on table public.admin_audit is
  'Append-only record of privileged admin acts. Written inside the 0051 functions so it cannot be bypassed. Never grant update or delete.';
comment on column public.admin_audit.actor is
  'The human. Directus Flows pass $accountability.user; a raw SQL call passes whatever it likes, which is itself worth seeing.';
comment on column public.admin_audit.outcome is
  'ok | refused. Refusals are the interesting rows - they are attempts to do something the rules stopped.';

create index if not exists admin_audit_at_idx
  on public.admin_audit (at desc);
create index if not exists admin_audit_target_idx
  on public.admin_audit (target_table, target_id, at desc);

alter table public.admin_audit enable row level security;

-- No policies. service_role bypasses RLS and is the only writer; the
-- panel reads it through a view (below) rather than directly, so an
-- editor cannot be handed the table by accident.
revoke all on public.admin_audit from anon, authenticated;


-- ---------------------------------------------------------------------
-- 2. Verification paperwork -- private.
--
-- One row per partner, created when they submit and updated when someone
-- reviews. `registration_expires_at` is here because licence renewal
-- tracking is in the spec and has nowhere else to live; a partner whose
-- registration has lapsed is not a partner in good standing, and the
-- approval function checks it.
-- ---------------------------------------------------------------------
create table if not exists public.care_partner_verification (
  partner_id             text primary key
                           references public.care_partners (id) on delete cascade,
  council                text,          -- e.g. 'Telangana State Medical Council'
  registration_number    text,
  registration_expires_at date,
  kyc_reference          text,          -- a reference, never the document itself
  qualification_doc      text,          -- storage path / external reference
  submitted_at           timestamptz,
  reviewed_by            text,
  reviewed_at            timestamptz,
  review_note            text,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

comment on table public.care_partner_verification is
  'PRIVATE. Professional paperwork behind an approval. RLS on with no policy = service_role only. Never move these columns onto care_partners, which is public-read.';
comment on column public.care_partner_verification.kyc_reference is
  'A REFERENCE to a document, not the document and not an identity number. Nothing here should be worth stealing on its own.';

alter table public.care_partner_verification enable row level security;
revoke all on public.care_partner_verification from anon, authenticated;

-- The panel needs to fill this in before it can approve anyone.
grant select, insert, update on public.care_partner_verification to directus_cms;

drop policy if exists "care_partner_verification cms" on public.care_partner_verification;
create policy "care_partner_verification cms"
  on public.care_partner_verification for all
  to directus_cms using (true) with check (true);


-- ---------------------------------------------------------------------
-- 3. A read-only window on the audit log for the panel.
--
-- A view rather than a grant on the table, so there is no path by which
-- the panel acquires insert/update on the record of its own actions.
-- ---------------------------------------------------------------------
create or replace view public.admin_audit_log as
  select id, actor, action, target_table, target_id, outcome, detail, at
    from public.admin_audit
   order by at desc;

grant select on public.admin_audit_log to directus_cms;

comment on view public.admin_audit_log is
  'Read-only view of admin_audit for Directus. Register THIS, never the table.';


-- =====================================================================
-- VERIFY
--
--   -- nothing public can see the paperwork
--   set role anon;
--   select count(*) from public.care_partner_verification;  -- permission denied
--   reset role;
--
--   -- the panel can read the log but not write it
--   set role directus_cms;
--   select count(*) from public.admin_audit_log;            -- a number
--   insert into public.admin_audit (action) values ('x');   -- permission denied
--   reset role;
-- =====================================================================
