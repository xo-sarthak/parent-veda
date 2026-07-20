-- =====================================================================
-- 0025_pp_milestones.sql — milestones observed
-- ---------------------------------------------------------------------
-- MilestoneStore (pp_milestones_data.dart). CHILD-SCOPED + CO-PARENTED —
-- if one parent saw the first steps, the other should not have to be
-- told twice, and either may add the note.
--
-- These are MEMORIES, not checkboxes: `note` is where "he did it holding
-- the sofa, then looked straight at me" lives. Losing that is not the
-- same as losing a tick — treat this table as keepsake data.
--
-- The milestone CATALOGUE (kMilestones) stays bundled in the app as
-- content. Only what a parent OBSERVED is user data, so only that is
-- stored here — one row per (child, milestone).
--
-- Composite PK (child_id, milestone_id): a milestone happens once per
-- child, so recording it is an idempotent upsert.
--
-- PREREQ: 0021_children.sql. Run AFTER 0021.
-- =====================================================================

create table public.pp_milestone_observations (
  child_id     text        not null,
  milestone_id text        not null,
  user_id      uuid        not null references auth.users (id) on delete cascade,

  observed_on  timestamptz not null,
  note         text,

  created_at   timestamptz not null default now(),
  primary key (child_id, milestone_id)
);

grant select, insert, update, delete on public.pp_milestone_observations to authenticated;
alter table public.pp_milestone_observations enable row level security;

create policy "pp_milestone_observations child select" on public.pp_milestone_observations for select
  using (child_id in (select public.my_child_ids()));
create policy "pp_milestone_observations child insert" on public.pp_milestone_observations for insert
  with check (child_id in (select public.my_child_ids()) and auth.uid() = user_id);
create policy "pp_milestone_observations child update" on public.pp_milestone_observations for update
  using (child_id in (select public.my_child_ids()));
create policy "pp_milestone_observations child delete" on public.pp_milestone_observations for delete
  using (child_id in (select public.my_child_ids()));
