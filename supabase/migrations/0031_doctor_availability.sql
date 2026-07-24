-- =====================================================================
-- 0031_doctor_availability.sql -- a doctor's real weekly availability
-- ---------------------------------------------------------------------
-- The times a doctor marks themselves free become the slots parents can
-- book. Stored as a recurring weekly pattern (weekday + time), one row
-- per window. PUBLIC-READ, because a parent must see a doctor's real
-- availability to book them; EXPERT-WRITE, because only the doctor mapped
-- to that expert may edit it.
--
-- PREREQ: 0030 (expert_accounts).
-- =====================================================================

create table public.doctor_availability (
  expert_id text not null,
  weekday   int  not null check (weekday between 1 and 7), -- Mon..Sun
  hour      int  not null check (hour between 0 and 23),
  minute    int  not null default 0 check (minute between 0 and 59),
  primary key (expert_id, weekday, hour, minute)
);

grant select, insert, update, delete on public.doctor_availability to authenticated;
alter table public.doctor_availability enable row level security;

-- Anyone signed in can READ (parents need to see when a doctor is free).
create policy "doctor_availability read" on public.doctor_availability
  for select using (true);

-- Only the expert THEMSELVES may write their own availability: the caller
-- must hold an expert_accounts row mapping them to this expert_id.
create policy "doctor_availability write" on public.doctor_availability
  for all
  using (
    exists (
      select 1 from public.expert_accounts ea
      where ea.user_id = auth.uid()
        and ea.expert_id = doctor_availability.expert_id
    )
  )
  with check (
    exists (
      select 1 from public.expert_accounts ea
      where ea.user_id = auth.uid()
        and ea.expert_id = doctor_availability.expert_id
    )
  );
