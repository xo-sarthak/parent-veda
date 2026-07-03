-- =====================================================================
-- 0012_share_scans.sql — share scan-done state + appointments across a
--   paired couple. A scan counts as "done" if EITHER partner marked it,
--   and both partners see all appointments. Only the READ policies widen
--   to own-OR-partner; writes stay own-only (each records their own row,
--   nobody writes to the other's). Needs public.my_partner_id (0009).
-- =====================================================================

drop policy if exists "completed_scans own select" on public.completed_scans;
create policy "completed_scans own or partner select"
  on public.completed_scans for select
  using (auth.uid() = user_id or user_id = public.my_partner_id());

drop policy if exists "appointments own select" on public.appointments;
create policy "appointments own or partner select"
  on public.appointments for select
  using (auth.uid() = user_id or user_id = public.my_partner_id());
