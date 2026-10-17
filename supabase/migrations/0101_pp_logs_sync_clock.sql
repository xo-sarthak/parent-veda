-- =============================================================================
--  0101 — Parenting logs: removals that stay removed, edits where the newer
--  one wins, and the server guard from 0100 (2026-10-17, sync log step 5)
-- -----------------------------------------------------------------------------
--  The six child-scoped log tables (feeds, sleeps, nappies, pumping, tummy
--  time, growth) synced the way the TTC tables did before 0097:
--
--   · A PULL WAS A UNION. Whatever the phone lacked was added, whatever it
--     held was kept, so a feed one parent deleted came back from the other
--     parent's phone, which still had it.
--   · A DELETE WAS ONE HARD DELETE, fired once. Offline, or racing an
--     upload, it was simply lost, and the row reappeared on the next pull.
--   · AN UPSERT WROTE `user_id = me` ON EVERY ROW, so correcting the feed
--     your partner logged rewrote "logged by" to you.
--
--  This adds the same two columns as 0097-0099 and attaches 0100's trigger:
--
--   · updated_at: when the change was made ON THE PHONE. No trigger sets it
--     to now() on write, on purpose (0097): that would stamp the upload time.
--   · removed_at: a removal is a row with a time, like any other change
--     (a soft delete), so it can win over an older live copy.
--
--  Merge rule (STILL-OPEN-BACKEND §6, decided 2026-10-17 for these tables):
--  row-level, newer wins. These are append-only logs: two parents almost
--  never edit the same feed, so per-field merging would buy nothing.
--
--  RLS is unchanged, and stays strict: a parent may only INSERT as themself
--  (`auth.uid() = user_id`), and may UPDATE any row of their child.
--
--  ⚠️ SO THE PHONE MUST NOT UPSERT THE PARTNER'S ROWS. Postgres checks the
--  INSERT policy's WITH CHECK on every row an `insert ... on conflict do
--  update` proposes, even when the row ends up taking the UPDATE path
--  (CREATE POLICY docs). An upsert that keeps his user_id is refused; one
--  that sends hers passes and rewrites "logged by". The app therefore sends
--  a plain UPDATE (no user_id in it) for a row whose owner is the partner,
--  and an upsert only for its own rows. 0100's trigger guards both.
--
--  Additive and safe to re-run.
-- =============================================================================

alter table public.pp_feed_logs
  add column if not exists updated_at timestamptz not null default now();
alter table public.pp_feed_logs
  add column if not exists removed_at timestamptz;

alter table public.pp_sleep_logs
  add column if not exists updated_at timestamptz not null default now();
alter table public.pp_sleep_logs
  add column if not exists removed_at timestamptz;

alter table public.pp_nappy_logs
  add column if not exists updated_at timestamptz not null default now();
alter table public.pp_nappy_logs
  add column if not exists removed_at timestamptz;

alter table public.pp_pump_logs
  add column if not exists updated_at timestamptz not null default now();
alter table public.pp_pump_logs
  add column if not exists removed_at timestamptz;

alter table public.pp_tummy_logs
  add column if not exists updated_at timestamptz not null default now();
alter table public.pp_tummy_logs
  add column if not exists removed_at timestamptz;

alter table public.pp_growth_measurements
  add column if not exists updated_at timestamptz not null default now();
alter table public.pp_growth_measurements
  add column if not exists removed_at timestamptz;

-- The server-side guard (0100's function): skip an older update, clamp a
-- clock from the future. `test/sync_guard_contract_test.dart` reads this list.
do $$
declare
  t text;
begin
  foreach t in array array[
    'pp_feed_logs',
    'pp_sleep_logs',
    'pp_nappy_logs',
    'pp_pump_logs',
    'pp_tummy_logs',
    'pp_growth_measurements'
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
--  CHECK IT (optional): every one of the six should list both columns and
--  the trigger.
-- -----------------------------------------------------------------------------
-- select c.table_name,
--        bool_or(c.column_name = 'updated_at') as has_updated_at,
--        bool_or(c.column_name = 'removed_at') as has_removed_at,
--        exists (select 1 from pg_trigger g
--                 where g.tgname = c.table_name || '_newer_wins') as guarded
--   from information_schema.columns c
--  where c.table_schema = 'public'
--    and c.table_name in ('pp_feed_logs','pp_sleep_logs','pp_nappy_logs',
--                         'pp_pump_logs','pp_tummy_logs','pp_growth_measurements')
--  group by c.table_name order by c.table_name;
-- -- expect six rows, all true
