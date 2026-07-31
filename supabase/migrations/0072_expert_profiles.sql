-- =====================================================================
-- 0072_expert_profiles.sql -- a doctor stops being a Dart file.
-- ---------------------------------------------------------------------
-- WHAT WAS WRONG. Everything about onboarding a clinician was already
-- panel-driven -- care_partners holds the identity, care_partner_verification
-- holds the KYC, approve_care_partner() refuses without complete paperwork --
-- right up to the moment they wanted to CONSULT. The consulting catalogue
-- (kExperts, kSpecialists) is a compiled Dart list, so adding a doctor who
-- takes appointments meant editing code and shipping a release.
--
-- That also made "who is teaching this masterclass?" untypeable in Directus:
-- programme_experts.expert_id pointed at nothing the database could see, so
-- the panel could only offer a free-text box to type an id into.
--
-- ---------------------------------------------------------------------
-- THE MODEL, AND THE MISTAKE IT CORRECTS
-- ---------------------------------------------------------------------
--
-- The first design split people by ACTIVITY: care_partners for "refers
-- families", experts for "takes consultations". That is wrong, and it is
-- wrong in a way that would have hurt later. One doctor may refer families,
-- take consults, teach a masterclass and review articles. Splitting the
-- identity by what they happen to do means the same person exists twice and
-- the two copies drift.
--
-- The right shape is the one 0057 already established for users:
--
--     Never ask "is this user Premium?" -- ask "does this user hold
--     capability X?"
--
-- Applied here: never ask "is this a partner or an expert?" -- ask "what may
-- this person do?". So there is ONE identity and OPTIONAL capability records
-- hanging off it, none of them required:
--
--     care_partners        WHO THEY ARE. One row, forever. KYC lives here.
--       ├── partner_referrals   they refer families        (0037)
--       ├── expert_profiles     they deliver something     (this file)
--       ├── programme_experts   they teach THIS programme  (0054)
--       └── partner_accounts    they can sign in           (0068)
--
-- A hospital has an identity and no fee. A ParentVeda staff counsellor may
-- consult without ever being a referral partner. Neither forecloses the
-- other, which was the explicit product constraint.
--
-- ---------------------------------------------------------------------
-- WHY expert_id IS THE PRIMARY KEY AND NOT A SERIAL
-- ---------------------------------------------------------------------
--
-- Because it already exists in three places that cannot be renamed without
-- orphaning live data:
--
--     expert_accounts.expert_id   which login IS this doctor      (0030)
--     booking_slots.expert_id     whose hour was booked           (0029)
--     care_partners.expert_id     the link 0037 already reserved
--
-- So the compiled ids ('neha', 'sp_ob') become the keys of real rows, every
-- existing reference keeps resolving, and nothing needs a data migration.
--
-- partner_id is NULLABLE and that is the whole point: it is the JOIN to an
-- identity, not a requirement to have one.
--
-- ⚠️ NOT SEEDED. The bundled Dart list stays the app's offline floor and a
-- published row WINS over a bundled one with the same id (mergedExperts()),
-- so this migration changes nothing on the day it runs and a bundled stub
-- can be superseded by a real, editable version without deleting the Dart.
-- Same trick as 0054/mergedLearningPrograms.
--
-- PREREQ: 0037 (care_partners), 0045 (directus_cms), 0046 (cms media).
-- =====================================================================


create table if not exists public.expert_profiles (
  -- Matches the compiled catalogue id. See the header.
  expert_id     text        primary key,

  -- THE JOIN TO AN IDENTITY, and nullable on purpose. A ParentVeda staff
  -- counsellor consults without being someone we onboarded from outside; a
  -- hospital is onboarded without ever consulting.
  partner_id    text        references public.care_partners (id),

  status        varchar(32) not null default 'published',
  -- pregnancy | parenting | ttc | universal. Which stage's Prepare tab
  -- offers them.
  domain        text        not null default 'universal',

  -- ---- who a parent is looking at ----------------------------------
  name          text        not null,
  credential    text        not null default '',   -- 'MBBS, MD (Obs & Gyn)'
  category      text        not null default '',   -- Obstetrician | Nutritionist | ...
  location      text        not null default '',
  photo_url     text,
  photo_file    uuid,                              -- Directus picker (0046)
  blurb         text        not null default '',

  -- ---- what they deliver, and on what terms ------------------------
  -- None of this belongs on an identity record, because an entity has an
  -- identity whether or not it charges for anything.
  --
  -- DOES THIS ENTITY TAKE 1:1 APPOINTMENTS? False for an organisation
  -- that only teaches, and for a person who only refers.
  --
  -- This one boolean is what stopped programme_experts needing a second
  -- host column. An organisation HAS an entry here -- that is not
  -- pretending to consult, it is having a row in the deliverer
  -- catalogue, the same as everybody else -- and consulting is one
  -- optional capability inside it rather than the reason it exists.
  takes_consults boolean    not null default true,

  fee_paise     int         not null default 0,
  duration_min  int         not null default 30,
  languages     text[]      not null default '{}',
  video_consult boolean     not null default true,

  -- ---- the trust half ----------------------------------------------
  why_heading   text        not null default '',
  why           text        not null default '',
  tags          text[]      not null default '{}',
  rating        numeric(2,1) not null default 0,
  reviews_count int         not null default 0,
  top_pick      boolean     not null default false,

  sort          int         not null default 0,
  published_at  timestamptz not null default now(),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),

  constraint expert_profiles_status_check
    check (status in ('draft', 'published', 'archived')),
  constraint expert_profiles_rating_check
    check (rating >= 0 and rating <= 5),
  -- A negative fee is not a discount, it is a typo that renders as
  -- "₹-800" on a card nobody proofread.
  constraint expert_profiles_fee_check
    check (fee_paise >= 0),
  constraint expert_profiles_duration_check
    check (duration_min > 0 and duration_min <= 240)
);

comment on table public.expert_profiles is
  'The DELIVERER catalogue: anyone who appears in the app as someone who gives something - a consultation, a masterclass, a cohort. A person and an organisation both get a row, identically; takes_consults says whether 1:1 appointments are among what they offer. Not an identity - that is care_partners, joined by partner_id (nullable). Keyed on the compiled expert id so expert_accounts, booking_slots and care_partners.expert_id keep resolving.';
comment on column public.expert_profiles.partner_id is
  'The care_partners row this expert IS, when they are also someone we onboarded. Null for ParentVeda staff. Never required: consulting and referring are separate capabilities of one person, not two kinds of person.';

create index if not exists expert_profiles_partner_idx
  on public.expert_profiles (partner_id) where partner_id is not null;
create index if not exists expert_profiles_domain_idx
  on public.expert_profiles (domain, status);


-- ---------------------------------------------------------------------
-- Reading: published only, by anyone. The app shows these on a booking
-- screen before sign-in, so anon needs it too.
-- ---------------------------------------------------------------------
alter table public.expert_profiles enable row level security;

grant select on public.expert_profiles to anon, authenticated;

drop policy if exists "expert_profiles public read" on public.expert_profiles;
create policy "expert_profiles public read" on public.expert_profiles
  for select to anon, authenticated using (status = 'published');

-- No client write policy. A row here sets a price and puts a clinician's
-- name in front of a pregnant woman; it is an editorial act.


-- ---------------------------------------------------------------------
-- The panel owns it.
-- ---------------------------------------------------------------------
grant select, insert, update, delete on public.expert_profiles to directus_cms;

drop policy if exists "expert_profiles cms write" on public.expert_profiles;
create policy "expert_profiles cms write" on public.expert_profiles
  for all to directus_cms using (true) with check (true);


-- ---------------------------------------------------------------------
-- Media sync, matching every other content table (0046).
-- ---------------------------------------------------------------------
drop trigger if exists expert_profiles_media_trg on public.expert_profiles;
create trigger expert_profiles_media_trg
  before insert or update on public.expert_profiles
  for each row execute function public.cms_sync_media();


-- ---------------------------------------------------------------------
-- WHO DELIVERS A PROGRAMME -- and why programme_experts is UNCHANGED.
--
-- This was got wrong twice, so the reasoning is worth keeping.
--
-- First attempt: FK programme_experts.expert_id -> expert_profiles.
-- Wrong, because expert_profiles then meant "takes 1:1 appointments at
-- this fee", and an IVF centre would have had to invent a consulting
-- profile it does not offer in order to teach.
--
-- Second attempt: add programme_experts.partner_id alongside expert_id,
-- exactly one set. Also wrong, and wrong in the same way one level down:
-- TWO HOST COLUMNS IS ITSELF AN EXCEPTION IN THE SCHEMA. Every query
-- about "who is hosting" would carry a branch, which is the thing the
-- rule forbids. It also could not be built: expert_id is half of the
-- primary key, and Postgres will not let a primary-key column be
-- nullable (42P16).
--
-- The right answer was smaller than both. An organisation gets an
-- expert_profiles row like anybody else, with takes_consults = false.
-- So:
--
--     programme_experts       unchanged. One host column. Composite key
--                             intact, so assign_programme_expert()'s
--                             ON CONFLICT keeps working.
--     Apollo                  expert_profiles row, partner_id = its own
--                             care_partners id, takes_consults = false.
--     Dr Meera                the same row shape, takes_consults = true.
--
-- No branch anywhere. The booking catalogue simply does not derive a
-- consult offering for a row where takes_consults is false, which is
-- the same check it already made on whether a doctor had hours.
--
-- The identity half -- an organisation being able to SEE and ACCEPT an
-- assignment -- is 0073, because it is one question asked by five
-- different gates and belongs in one place.
-- ---------------------------------------------------------------------


-- =====================================================================
-- ADDING A DOCTOR, END TO END, WITH NO CODE CHANGE
--
--   1. Directus -> Care Partners -> Create
--        id 'cp_meera', name 'Dr Meera Rao', type 'doctor', status 'pending'
--      (or the 0051 function, which audits the act)
--
--   2. Directus -> Care Partner Verification -> Create
--        partner_id 'cp_meera', council, registration_number, kyc_reference,
--        registration_expires_at
--
--   3. select public.approve_care_partner('cp_meera', 'your-name');
--        -> refuses unless the paperwork above is complete and unexpired
--
--   4. IF they also consult -- Directus -> Expert Profiles -> Create
--        expert_id 'meera', partner_id 'cp_meera', name, credential,
--        fee_paise 80000, duration_min 30, status 'published'
--
--   5. They sign in to ParentVeda+ with their own email. Link it once:
--        insert into public.expert_accounts (user_id, expert_id)
--        values ((select id from auth.users where email = '...'), 'meera')
--        on conflict (user_id) do update set expert_id = excluded.expert_id;
--
--   6. They set their own availability in the app. Their schedule IS the
--      slot list -- no second source of truth to drift.
--
-- Steps 1, 2 and 4 are forms. Only 3 and 5 are SQL, and both are audited
-- acts that should stay deliberate.
--
-- VERIFY
--   select e.expert_id, e.name, e.fee_paise, c.name as partner
--     from public.expert_profiles e
--     left join public.care_partners c on c.id = e.partner_id;
-- =====================================================================
