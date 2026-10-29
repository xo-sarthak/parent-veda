-- =============================================================================
--  0127 — ttc_records: the scans travel, and each partner writes only their own
--  (T4 B3 + Q2, 2026-10-29; docs/preg-ttc-tool-plans/T4-treatment-records.md)
-- -----------------------------------------------------------------------------
--  1. `files jsonb`, nullable. The photos and PDFs of a result were cached in
--     shared_preferences only. A sign-out runs `LocalWipe` (`prefs.clear()`),
--     the next pull rebuilt each row with no files, and the scans sat in the
--     `media` bucket with nothing pointing at them. A cache is not a record.
--     The column makes the cloud the record's memory: the app sends the
--     storage refs (a JSON array of object paths) and reads them back. Null
--     means "a row from before this column", and the app then keeps whatever
--     the phone holds, so old rows lose nothing.
--
--  2. Update and delete narrowed to the row's own user. 0042 gave this table
--     one `for all` policy, "mine or my partner's", so his phone could change
--     or soft-remove her results (a removal is an UPDATE of `removed_at`).
--     The product rule (Q2, the user, 2026-10-29): "he changes his own results
--     and only reads her results". The app gates it in the UI; RLS is the rule
--     that holds when the app is not the one asking. Read stays couple-wide,
--     and insert is own-row.
--
--     ⚠️ An upsert is INSERT ... ON CONFLICT DO UPDATE. Postgres checks the
--     insert's `with check` on the proposed row first, then the update's
--     `using` on the existing row. Both are own-row now, so an upsert of the
--     partner's row is refused on either path, which is what is meant.
--
--  ORDER: run this BEFORE installing the build that sends `files`. A build
--  that sends a column the table lacks has every ttc_records upsert refused
--  (PostgREST rejects unknown columns); the rows wait on the phone and upload
--  once this has run, so nothing is lost, but nothing syncs until then.
--
--  Untouched: the 0100 newer-wins trigger (it compares updated_at only), the
--  0109/0110 purge (it deletes by removed_at), the (id) key.
--
--  Safe to re-run: `add column if not exists`, `drop policy if exists` first.
-- =============================================================================

alter table public.ttc_records
  add column if not exists files jsonb;

comment on column public.ttc_records.files is
  'Storage refs (media bucket object paths) of the scans and photos for this '
  'result, as a JSON array. Null = a row from before 0127; the app keeps its '
  'local list then.';

-- one policy per command (the 0102/0103 shape) ---------------------------------
drop policy if exists ttc_records_couple on public.ttc_records;

drop policy if exists ttc_records_select on public.ttc_records;
create policy ttc_records_select on public.ttc_records
  for select using (auth.uid() = user_id or user_id = public.my_partner_id());

drop policy if exists ttc_records_insert on public.ttc_records;
create policy ttc_records_insert on public.ttc_records
  for insert with check (auth.uid() = user_id);

drop policy if exists ttc_records_update on public.ttc_records;
create policy ttc_records_update on public.ttc_records
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists ttc_records_delete on public.ttc_records;
create policy ttc_records_delete on public.ttc_records
  for delete using (auth.uid() = user_id);

-- -----------------------------------------------------------------------------
--  CHECK IT (optional): one `files jsonb` column, and four policies, no ALL.
-- -----------------------------------------------------------------------------
-- select column_name, data_type from information_schema.columns
--  where table_name = 'ttc_records' and column_name = 'files';
-- select policyname, cmd from pg_policies
--  where tablename = 'ttc_records' order by cmd;
