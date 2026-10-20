-- =============================================================================
--  0105 — the child profile and the name votes sync "newer wins"
--  (2026-10-20, sync log step 7)
-- -----------------------------------------------------------------------------
--  The last two Parenting tables still syncing the old way.
--
--  children (ChildProfileStore):
--   · the pull took the cloud copy whole, so an offline edit was lost;
--   · a removed child came back: the other parent's phone still held it and
--     inserted it again, now under their own name;
--   · the removal was a hard delete, and that took the id out of
--     public.my_child_ids() (0021). Every pp_* policy gates on that function,
--     and no pp_* table has a foreign key to children, so the child's feeds,
--     vaccines and records stayed in the database where NEITHER parent could
--     read them any more.
--
--  pp_name_votes (NameMatchStore):
--   · the pull adopted only "liked" rows, and re-uploaded every name the phone
--     still listed as liked. A skip made offline, or on the other phone, was
--     turned back into a like.
--
--  Decisions (the user, 2026-10-20): the child profile is whole row, latest
--  edit wins, and the growth figures (weight_kg, height_cm, head_cm) do NOT
--  count as an edit: they mirror the growth log, which syncs on its own, so a
--  weight logged on one phone cannot undo a rename made on the other.
--  Removing a child is a SOFT delete, and the child can be restored.
--
--  This adds:
--   · updated_at (the edit time on the phone; no trigger stamps now(), see
--     0097) and removed_at (a soft delete) on children;
--   · updated_at on pp_name_votes. A vote is state, not a list item: a skip
--     is liked = false, so it needs no removed_at (as pp_vaccine_doses, 0104);
--   · 0100's guard (skip an older update, clamp a future clock) on both.
--
--  ⚠️ public.my_child_ids() IS DELIBERATELY UNCHANGED. A removed child still
--  counts as "my child", so its records stay reachable for both parents and a
--  restore brings everything back. Filtering removed_at there would orphan the
--  records exactly as the hard delete did. For the same reason children must
--  stay OUT of any purge of old soft-deleted rows (STILL-OPEN-BACKEND §5).
--
--  RLS is unchanged. Insert stays "only as yourself", so the app sends a
--  child the other parent created as a plain UPDATE, and never sends user_id:
--  the owner is what my_child_ids() reads, so it must never move.
--
--  Additive and safe to re-run.
-- =============================================================================

alter table public.children
  add column if not exists updated_at timestamptz not null default now();
alter table public.children
  add column if not exists removed_at timestamptz;

alter table public.pp_name_votes
  add column if not exists updated_at timestamptz not null default now();

-- The server-side guard (0100's function). `test/sync_guard_contract_test.dart`
-- reads this list.
do $$
declare
  t text;
begin
  foreach t in array array[
    'children',
    'pp_name_votes'
  ]
  loop
    execute format('drop trigger if exists %I on public.%I',
                   t || '_newer_wins', t);
    execute format(
      'create trigger %I before insert or update on public.%I '
      'for each row execute function public.pv_sync_newer_wins()',
      t || '_newer_wins', t);
  end loop;
end $$;

notify pgrst, 'reload schema';

-- -----------------------------------------------------------------------------
--  CHECK IT (optional): 2 rows. has_clock and guarded should be true on both;
--  has_removed_at is true for children only.
-- -----------------------------------------------------------------------------
-- select c.table_name,
--        bool_or(c.column_name = 'updated_at') as has_clock,
--        bool_or(c.column_name = 'removed_at') as has_removed_at,
--        exists (select 1 from pg_trigger g
--                 where g.tgname = c.table_name || '_newer_wins') as guarded
--   from information_schema.columns c
--  where c.table_schema = 'public'
--    and c.table_name in ('children', 'pp_name_votes')
--  group by c.table_name order by c.table_name;
