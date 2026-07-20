-- =====================================================================
-- 0023_pp_growth_vax.sql — growth measurements + vaccination doses
-- ---------------------------------------------------------------------
-- GrowthStore (pp_growth_data.dart) and VaxStore (pp_vaccine_data.dart).
-- Both CHILD-SCOPED + CO-PARENTED, gating on public.my_child_ids()
-- (0021): either parent may record a measurement or mark a dose, and
-- both see the same record. `user_id` is attribution only.
--
-- PREREQ: 0021_children.sql. Run AFTER 0021.
-- =====================================================================


-- ---------------------------------------------------------------------
-- growth measurements — THE source of truth for the child's growth.
--
-- Flag #1 in this plan: the app currently reads growth from three places
-- that can disagree — My Child's scalars on `children`, GrowthStore's
-- series, and a hardcoded `const kGrowth` list in pp_health_data.dart
-- that no edit can ever change (so the Doctor Record still prints demo
-- numbers after a parent updates the weight). This table is the single
-- home. The `children.weight_kg/height_cm/head_cm` columns stay as a
-- mirror of the LATEST row here until that rewiring lands, then drop.
-- ---------------------------------------------------------------------
create table public.pp_growth_measurements (
  id         text        primary key,
  child_id   text        not null,
  user_id    uuid        not null references auth.users (id) on delete cascade,

  date       timestamptz not null,
  weight_kg  numeric     not null default 0,
  height_cm  numeric     not null default 0,
  head_cm    numeric,                        -- optional; not always measured
  note       text,

  created_at timestamptz not null default now()
);

create index pp_growth_measurements_child_idx
  on public.pp_growth_measurements (child_id, date desc);

grant select, insert, update, delete on public.pp_growth_measurements to authenticated;
alter table public.pp_growth_measurements enable row level security;

create policy "pp_growth_measurements child select" on public.pp_growth_measurements for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_growth_measurements child insert" on public.pp_growth_measurements for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_growth_measurements child update" on public.pp_growth_measurements for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_growth_measurements child delete" on public.pp_growth_measurements for delete
  using (child_id in (select public.my_child_ids()));


-- ---------------------------------------------------------------------
-- vaccination doses — one row per (child, vaccine dose).
--
-- VaxStore holds two sets: `_done` (dose ids marked given) and
-- `_reminders` (dose ids with an alarm armed). They're the same key
-- space, so one row carries both flags rather than two tables.
--
-- Composite PK (child_id, vaccine_id) per the house rule for
-- "one row per (owner, key)" tables — mark-done is then an idempotent
-- upsert, and a dose can never be recorded twice for one child.
--
-- `reminder` persisting fixes flag #4: today VaxStore arms a real OS
-- notification that survives a restart while the store forgets it, so
-- the app and the phone disagree about what is scheduled.
-- ---------------------------------------------------------------------
create table public.pp_vaccine_doses (
  child_id        text        not null,
  vaccine_id      text        not null,
  user_id         uuid        not null references auth.users (id) on delete cascade,

  done            boolean     not null default false,
  done_at         timestamptz,
  reminder        boolean     not null default false,
  reminder_hour   int,
  reminder_minute int,
  reminder_id     int,

  created_at      timestamptz not null default now(),
  primary key (child_id, vaccine_id)
);

grant select, insert, update, delete on public.pp_vaccine_doses to authenticated;
alter table public.pp_vaccine_doses enable row level security;

create policy "pp_vaccine_doses child select" on public.pp_vaccine_doses for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_vaccine_doses child insert" on public.pp_vaccine_doses for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_vaccine_doses child update" on public.pp_vaccine_doses for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_vaccine_doses child delete" on public.pp_vaccine_doses for delete
  using (child_id in (select public.my_child_ids()));
