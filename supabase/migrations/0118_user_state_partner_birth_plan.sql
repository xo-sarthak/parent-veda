-- =============================================================================
--  0118 · Her partner can read her birth plan, and nothing else in user_state
--  (P2 O2, 2026-10-28; docs/preg-ttc-tool-plans/P2-keep.md)
-- -----------------------------------------------------------------------------
--  The birth plan is one row of `user_state` (store_key = 'birth_plan', kept
--  per item by pv_state_merge, 0110). Her partner's phone used to open its own
--  empty plan; the user chose (O2) that he sees HERS, read-only.
--
--  ⚠️ SHARE A ROW, NOT THE TABLE. `user_state` holds every store she has, one
--  row per store_key. The usual partner policy shape
--  (`user_id = my_partner_id()`, as 0009/0012) would hand him all of it. So
--  the partner clause is narrowed by the row's key as well as its owner.
--
--  ⚠️ A SECOND SELECT POLICY, NOT A REPLACEMENT. Permissive policies for the
--  same command are OR-ed, so "user_state own select" (0011) keeps working
--  untouched and this one only adds his one row. No insert, update or delete
--  policy is added: only she writes her plan.
--
--  Runs after 0009 (my_partner_id), 0011 and 0110.
-- =============================================================================

drop policy if exists "user_state partner birth plan select" on public.user_state;
create policy "user_state partner birth plan select"
  on public.user_state for select
  using (store_key = 'birth_plan' and user_id = public.my_partner_id());
