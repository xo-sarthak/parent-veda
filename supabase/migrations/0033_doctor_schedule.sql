-- =====================================================================
-- 0033_doctor_schedule.sql -- a doctor's whole availability, one row each
-- ---------------------------------------------------------------------
-- SUPERSEDES 0031_doctor_availability, which stored one row per (weekday,
-- hour, minute). That shape could only express "free at 5pm on Mondays".
-- It had nowhere to put consultation length, buffers, per-day caps,
-- minimum notice, the advance window, vacations, single-date overrides or
-- pause -- so a doctor working 10:30-13:00 and 17:00-20:30 could not
-- describe their own working day at all.
--
-- The new shape is ONE ROW PER DOCTOR holding the schedule document:
-- the weekly session pattern, the rules, and the exceptions. That mirrors
-- how it is edited (the doctor saves a whole schedule, never a single
-- minute) and how it is read (slots are DERIVED from the whole thing at
-- once, by the same function on both sides).
--
-- Why jsonb rather than five normalised tables: nothing here is ever
-- queried BY its parts. The app always wants the entire schedule for one
-- doctor, computes slots from it in Dart, and writes it back whole. Five
-- tables would buy joins nobody performs and five chances to half-save a
-- schedule.
--
-- 0031 is intentionally NOT dropped here -- see the note at the bottom.
--
-- PREREQ: 0030 (expert_accounts).
-- =====================================================================

create table public.doctor_schedule (
  expert_id   text        primary key,
  schedule    jsonb       not null default '{}'::jsonb,
  updated_at  timestamptz not null default now()
);

comment on column public.doctor_schedule.schedule is
  'DoctorSchedule.toMap(): byWeekday, rules, timeOff, overrides, paused.';

grant select, insert, update, delete on public.doctor_schedule to authenticated;
alter table public.doctor_schedule enable row level security;

-- READ is open to any signed-in user: a parent cannot book a doctor
-- without seeing when that doctor is free. Nothing personal lives here --
-- it is working hours, which is exactly what a clinic puts on its door.
create policy "doctor_schedule read" on public.doctor_schedule
  for select using (true);

-- WRITE is the doctor themselves and nobody else. The caller must hold an
-- expert_accounts row mapping their auth uid to this expert_id, so one
-- doctor can never edit another's diary -- which would let them silently
-- close a colleague's calendar, or open one they do not staff.
create policy "doctor_schedule insert" on public.doctor_schedule
  for insert to authenticated
  with check (exists (
    select 1 from public.expert_accounts ea
    where ea.expert_id = doctor_schedule.expert_id
      and ea.user_id = auth.uid()
  ));

create policy "doctor_schedule update" on public.doctor_schedule
  for update to authenticated
  using (exists (
    select 1 from public.expert_accounts ea
    where ea.expert_id = doctor_schedule.expert_id
      and ea.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.expert_accounts ea
    where ea.expert_id = doctor_schedule.expert_id
      and ea.user_id = auth.uid()
  ));

create policy "doctor_schedule delete" on public.doctor_schedule
  for delete to authenticated
  using (exists (
    select 1 from public.expert_accounts ea
    where ea.expert_id = doctor_schedule.expert_id
      and ea.user_id = auth.uid()
  ));

-- ---------------------------------------------------------------------
-- 0031 is left in place ON PURPOSE.
--
-- Dropping it would destroy whatever windows a doctor has already saved
-- while the app still has a revert path to the old screen. It is no
-- longer written to; the app reads and writes doctor_schedule only.
--
-- When the old availability screen is deleted for good, drop it:
--     drop table if exists public.doctor_availability;
-- ---------------------------------------------------------------------
