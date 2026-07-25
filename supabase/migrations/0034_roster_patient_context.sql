-- =====================================================================
-- 0034_roster_patient_context.sql -- the doctor must see WHO they are seeing
-- ---------------------------------------------------------------------
-- DEFECT FIX. expert_roster() returned raw booking_bookings rows, which
-- carry no parent identity at all. The doctor app therefore fell back to
-- booking.title -- which for a consult is 'Consult · <doctor's name>'.
--
-- So a doctor opened their day and saw their OWN name on every row, five
-- times over, with no idea who they were about to see or how far along
-- that mother was. That is not a missing nicety; it is a doctor walking
-- into a medical call blind.
--
-- This returns the same rows plus the minimum a clinician needs to open a
-- consultation: the parent's name and their stage context (due date, so
-- the app can say "Week 24"). Nothing more.
--
-- PRIVACY. This is the one place a doctor reads another user's row, so
-- the boundary is drawn tightly:
--   * security definer, so it can read profiles at all;
--   * the expert_id is derived from auth.uid() via expert_accounts and is
--     NEVER passed in, so a doctor cannot ask about someone else's list;
--   * only bookings whose SLOT belongs to that expert are returned;
--   * exactly three columns of parent data leave the table: name, due
--     date, created_at. No email, no phone, no auth row, no other
--     bookings, nothing from any other doctor's consultations.
-- A doctor sees their own patients, at the moment of care, and no further.
--
-- PREREQ: 0001 (profiles), 0029 (booking engine), 0030 (expert_accounts).
-- =====================================================================

-- Return type changes, so the old signature has to go first.
drop function if exists public.expert_roster();

create or replace function public.expert_roster()
returns table (
  id           text,
  user_id      uuid,
  offering_id  text,
  slot_id      text,
  stage        text,
  title        text,
  starts_utc   timestamptz,
  duration_min int,
  status       text,
  created_at   timestamptz,
  patient_name text,
  patient_due  date
)
language sql
stable
security definer set search_path = ''
as $$
  select
    b.id, b.user_id, b.offering_id, b.slot_id, b.stage, b.title,
    b.starts_utc, b.duration_min, b.status, b.created_at,
    p.name      as patient_name,
    p.due_date  as patient_due
  from public.booking_bookings b
  join public.booking_slots s on s.id = b.slot_id
  left join public.profiles  p on p.id = b.user_id
  where b.status <> 'cancelled'
    and s.expert_id = (
      select ea.expert_id
      from public.expert_accounts ea
      where ea.user_id = auth.uid()
    )
  order by b.starts_utc;
$$;

grant execute on function public.expert_roster() to authenticated;
