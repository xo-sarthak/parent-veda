-- =====================================================================
-- 0022_pp_health.sql — the child's health record
-- ---------------------------------------------------------------------
-- HealthStore (pp_health_data.dart) split into per-feature tables:
-- medications, prescriptions, allergies, symptoms, reports, doctor
-- visits and the doctor-visit question list.
--
-- CHILD-SCOPED + CO-PARENTED. Every table here carries `child_id` and
-- gates on public.my_child_ids() (0021), so BOTH paired parents read
-- AND write the same child's health record. `user_id` is ATTRIBUTION
-- ("Dad logged this"), never the access key — see 0021 for the full
-- reasoning behind that deviation from the pregnancy side.
--
-- WHY TABLES AND NOT user_state (a deliberate divergence from
-- docs/BACKEND-PARENTING-BRIEF.md §2, which suggests the KV table for
-- most stores): user_state's RLS is own-only — all four policies are
-- `auth.uid() = user_id` (0011). Health rows in there would be private
-- to whichever parent typed them, so the mother could not see the
-- father's entries at all. That silently breaks the co-parenting
-- invariant the same brief states in §5. Child-shared data therefore
-- needs real tables. Tier-2 preference stores still belong in
-- user_state, where own-only is exactly right.
--
-- SEED DATA IS NOT USER DATA (brief §5): the app ships demo content
-- (Aarav's medications, allergies, reports). Those rows carry an EMPTY
-- id and are never written here — only parent-entered rows, which get a
-- real client-generated id, ever reach this database. Without that rule
-- every account would inherit a fictional four-month-old's medical
-- history.
--
-- PREREQ: 0021_children.sql (public.my_child_ids). Run AFTER 0021.
-- =====================================================================


-- ---------------------------------------------------------------------
-- Shared shape. Every table below is identical in its bones:
--   id         text  primary key   -- client-generated; local row and
--                                  -- cloud row share one id → sync is a
--                                  -- plain id-keyed merge (house rule)
--   child_id   text                -- WHO IT IS ABOUT = who may see it
--   user_id    uuid                -- who typed it (attribution only)
--   attachments jsonb              -- [{kind,path,name}] as the app
--                                  -- already serializes it; `path` holds
--                                  -- a Storage object path once uploads
--                                  -- land (flag #5), a device path today
--
-- No hard FK on child_id: the same local-first sync-order rule the
-- pregnancy side uses for medication_logs (0005) — a row may arrive
-- before the child it references.
-- ---------------------------------------------------------------------


-- ---- medications -----------------------------------------------------
create table public.pp_medications (
  id            text        primary key,
  child_id      text        not null,
  user_id       uuid        not null references auth.users (id) on delete cascade,

  name          text        not null default '',
  reason        text        not null default '',
  doctor        text        not null default '',
  dosage        text        not null default '',
  duration      text        not null default '',
  frequency     text        not null default '',
  completed     boolean     not null default false,
  date          text        not null default '',

  -- Local OS notification state. Persisted because it currently is NOT
  -- (flag #4): the reminder arms a real notification that survives a
  -- restart while the store forgets it, so the app and the OS disagree.
  reminder_on     boolean   not null default false,
  reminder_hour   int,
  reminder_minute int,
  reminder_id     int,

  created_at    timestamptz not null default now()
);


-- ---- prescriptions ---------------------------------------------------
create table public.pp_prescriptions (
  id            text        primary key,
  child_id      text        not null,
  user_id       uuid        not null references auth.users (id) on delete cascade,

  name          text        not null default '',
  doctor        text        not null default '',
  date          text        not null default '',
  notes         text        not null default '',
  attachments   jsonb       not null default '[]'::jsonb,

  created_at    timestamptz not null default now()
);


-- ---- allergies -------------------------------------------------------
create table public.pp_allergies (
  id            text        primary key,
  child_id      text        not null,
  user_id       uuid        not null references auth.users (id) on delete cascade,

  name          text        not null default '',
  status        text        not null default 'known'
                              check (status in ('known','suspected','resolved')),
  severity      text        not null default '',
  note          text        not null default '',

  created_at    timestamptz not null default now()
);


-- ---- symptoms --------------------------------------------------------
create table public.pp_symptoms (
  id            text        primary key,
  child_id      text        not null,
  user_id       uuid        not null references auth.users (id) on delete cascade,

  name          text        not null default '',
  date          text        not null default '',
  note          text        not null default '',

  created_at    timestamptz not null default now()
);


-- ---- medical reports -------------------------------------------------
-- `values` is the nested [{label,value,flag}] list → jsonb, exactly as
-- the app serializes it (house rule 4).
create table public.pp_reports (
  id            text        primary key,
  child_id      text        not null,
  user_id       uuid        not null references auth.users (id) on delete cascade,

  name          text        not null default '',
  date          text        not null default '',
  summary       text        not null default '',
  doctor        text,
  -- `report_values`, not `values`: the latter is a reserved SQL keyword and
  -- would need double-quoting at every use site.
  report_values jsonb       not null default '[]'::jsonb,
  attachments   jsonb       not null default '[]'::jsonb,

  created_at    timestamptz not null default now()
);


-- ---- doctor visits ---------------------------------------------------
-- Parent-recorded visits only. The seeded read-only health timeline
-- (kHealthTimeline) stays in the app as content, not user data.
create table public.pp_doctor_visits (
  id            text        primary key,
  child_id      text        not null,
  user_id       uuid        not null references auth.users (id) on delete cascade,

  type          text        not null default '',
  date          text        not null default '',
  title         text        not null default '',
  summary       text        not null default '',
  sort_key      int         not null default 0,
  doctor        text,
  notes         text,
  attachments   int         not null default 0,
  upcoming      boolean     not null default false,

  created_at    timestamptz not null default now()
);


-- ---- doctor-visit questions -----------------------------------------
-- "What to ask at the next visit". A plain list of strings in the app;
-- one row each here so either parent can add to the same list.
create table public.pp_doctor_questions (
  id            text        primary key,
  child_id      text        not null,
  user_id       uuid        not null references auth.users (id) on delete cascade,

  question      text        not null default '',

  created_at    timestamptz not null default now()
);


-- ---------------------------------------------------------------------
-- Indexes — every read is "this child's rows".
-- ---------------------------------------------------------------------
create index pp_medications_child_idx      on public.pp_medications (child_id);
create index pp_prescriptions_child_idx    on public.pp_prescriptions (child_id);
create index pp_allergies_child_idx        on public.pp_allergies (child_id);
create index pp_symptoms_child_idx         on public.pp_symptoms (child_id);
create index pp_reports_child_idx          on public.pp_reports (child_id);
create index pp_doctor_visits_child_idx    on public.pp_doctor_visits (child_id);
create index pp_doctor_questions_child_idx on public.pp_doctor_questions (child_id);


-- ---------------------------------------------------------------------
-- Privileges. Mandatory for SQL-created tables — RLS decides which rows,
-- but the GRANT decides whether the role may touch the table at all and
-- is checked first. Without it: "permission denied" (code 42501).
-- ---------------------------------------------------------------------
grant select, insert, update, delete on public.pp_medications      to authenticated;
grant select, insert, update, delete on public.pp_prescriptions    to authenticated;
grant select, insert, update, delete on public.pp_allergies        to authenticated;
grant select, insert, update, delete on public.pp_symptoms         to authenticated;
grant select, insert, update, delete on public.pp_reports          to authenticated;
grant select, insert, update, delete on public.pp_doctor_visits    to authenticated;
grant select, insert, update, delete on public.pp_doctor_questions to authenticated;


-- ---------------------------------------------------------------------
-- RLS — identical on all seven: you may touch a row if it is about a
-- child you parent. Co-parented, so UPDATE and DELETE are as open as
-- SELECT: either parent may correct or remove what the other logged.
--
-- INSERT additionally pins user_id to the caller (with check), so a row
-- always records who really typed it — attribution can't be forged even
-- though access doesn't depend on it.
-- ---------------------------------------------------------------------
alter table public.pp_medications      enable row level security;
alter table public.pp_prescriptions    enable row level security;
alter table public.pp_allergies        enable row level security;
alter table public.pp_symptoms         enable row level security;
alter table public.pp_reports          enable row level security;
alter table public.pp_doctor_visits    enable row level security;
alter table public.pp_doctor_questions enable row level security;

-- medications
create policy "pp_medications child select" on public.pp_medications for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_medications child insert" on public.pp_medications for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_medications child update" on public.pp_medications for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_medications child delete" on public.pp_medications for delete
  using (child_id in (select public.my_child_ids()));

-- prescriptions
create policy "pp_prescriptions child select" on public.pp_prescriptions for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_prescriptions child insert" on public.pp_prescriptions for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_prescriptions child update" on public.pp_prescriptions for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_prescriptions child delete" on public.pp_prescriptions for delete
  using (child_id in (select public.my_child_ids()));

-- allergies
create policy "pp_allergies child select" on public.pp_allergies for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_allergies child insert" on public.pp_allergies for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_allergies child update" on public.pp_allergies for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_allergies child delete" on public.pp_allergies for delete
  using (child_id in (select public.my_child_ids()));

-- symptoms
create policy "pp_symptoms child select" on public.pp_symptoms for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_symptoms child insert" on public.pp_symptoms for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_symptoms child update" on public.pp_symptoms for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_symptoms child delete" on public.pp_symptoms for delete
  using (child_id in (select public.my_child_ids()));

-- reports
create policy "pp_reports child select" on public.pp_reports for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_reports child insert" on public.pp_reports for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_reports child update" on public.pp_reports for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_reports child delete" on public.pp_reports for delete
  using (child_id in (select public.my_child_ids()));

-- doctor visits
create policy "pp_doctor_visits child select" on public.pp_doctor_visits for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_doctor_visits child insert" on public.pp_doctor_visits for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_doctor_visits child update" on public.pp_doctor_visits for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_doctor_visits child delete" on public.pp_doctor_visits for delete
  using (child_id in (select public.my_child_ids()));

-- doctor questions
create policy "pp_doctor_questions child select" on public.pp_doctor_questions for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_doctor_questions child insert" on public.pp_doctor_questions for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_doctor_questions child update" on public.pp_doctor_questions for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_doctor_questions child delete" on public.pp_doctor_questions for delete
  using (child_id in (select public.my_child_ids()));
