-- =============================================================================
--  0103 — the partner can read her row but never delete it (2026-10-17)
-- -----------------------------------------------------------------------------
--  `ttc_journeys` (0041) and `ttc_treatment` (0043) were meant as "the couple
--  reads both rows, each writes only their own". Each had ONE policy:
--
--      for all
--      using      (mine or my partner's)
--      with check (mine)
--
--  `with check` guards the row being WRITTEN, by insert or update. A DELETE
--  writes no row, so only `using` applies to it, and `using` says "mine or my
--  partner's". So his phone could delete her journey row or her treatment
--  cycle. Nothing in the app does that today, but RLS is the rule that holds
--  when the app is not the one asking (BACKEND-PATTERNS §16jj-b).
--
--  The fix is the shape 0102 gave `ttc_ready_plans`: one policy per command.
--  Read is couple-scoped; insert, update and delete are own-row.
--
--  NOT CHANGED, ON PURPOSE: the tables BOTH partners may write by design
--  (`ttc_supplements`, `ttc_supplement_taken`, `ttc_ritual`, `ttc_records`,
--  `ttc_appointments`, the retired `ttc_journal`). There, deleting is no wider
--  than editing, so their single policy says what is meant.
--
--  Safe to re-run: `drop policy if exists` before each create.
-- =============================================================================

-- ttc_journeys -----------------------------------------------------------------
drop policy if exists ttc_journeys_rw on public.ttc_journeys;

drop policy if exists ttc_journeys_select on public.ttc_journeys;
create policy ttc_journeys_select on public.ttc_journeys
  for select using (auth.uid() = user_id or user_id = public.my_partner_id());

drop policy if exists ttc_journeys_insert on public.ttc_journeys;
create policy ttc_journeys_insert on public.ttc_journeys
  for insert with check (auth.uid() = user_id);

drop policy if exists ttc_journeys_update on public.ttc_journeys;
create policy ttc_journeys_update on public.ttc_journeys
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists ttc_journeys_delete on public.ttc_journeys;
create policy ttc_journeys_delete on public.ttc_journeys
  for delete using (auth.uid() = user_id);

-- ttc_treatment ----------------------------------------------------------------
drop policy if exists ttc_treatment_couple on public.ttc_treatment;

drop policy if exists ttc_treatment_select on public.ttc_treatment;
create policy ttc_treatment_select on public.ttc_treatment
  for select using (auth.uid() = user_id or user_id = public.my_partner_id());

drop policy if exists ttc_treatment_insert on public.ttc_treatment;
create policy ttc_treatment_insert on public.ttc_treatment
  for insert with check (auth.uid() = user_id);

drop policy if exists ttc_treatment_update on public.ttc_treatment;
create policy ttc_treatment_update on public.ttc_treatment
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists ttc_treatment_delete on public.ttc_treatment;
create policy ttc_treatment_delete on public.ttc_treatment
  for delete using (auth.uid() = user_id);

-- -----------------------------------------------------------------------------
--  CHECK IT (optional): eight rows, and no `ALL` left on either table.
-- -----------------------------------------------------------------------------
-- select tablename, policyname, cmd from pg_policies
--  where tablename in ('ttc_journeys', 'ttc_treatment') order by 1, 3;
