-- =====================================================================
-- 0011_user_state.sql — a generic per-user key/value store
-- ---------------------------------------------------------------------
-- The many small "saved / liked / preference" stores (saved videos,
-- followed experts, reading progress, cart, checklists, hospital bag,
-- community toggles, Garbh favourites, …) don't each need a bespoke
-- relational table. They're really just "shared_preferences, but in the
-- cloud, per user": each one syncs the SAME serialized JSON blob it
-- already writes locally, under its own store_key.
--
-- The heavy feature data (journal, trackers, health, scans, reminders)
-- keeps its own proper per-feature tables — this is only for the light
-- collection/preference stores (batch A).
-- =====================================================================
create table public.user_state (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  store_key  text        not null,
  data       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, store_key)
);
grant select, insert, update, delete on public.user_state to authenticated;
alter table public.user_state enable row level security;
create policy "user_state own select" on public.user_state for select using (auth.uid() = user_id);
create policy "user_state own insert" on public.user_state for insert with check (auth.uid() = user_id);
create policy "user_state own update" on public.user_state for update using (auth.uid() = user_id);
create policy "user_state own delete" on public.user_state for delete using (auth.uid() = user_id);
