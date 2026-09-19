-- =============================================================================
--  0086 — Is it safe?: what she asked that we could not answer
-- -----------------------------------------------------------------------------
--  2026-09-19. One table, and the reason it is a table and not a blob.
--
--  Her recents and her "my doctor said" notes are a per-user JSON blob in
--  `user_state` (key `can_i_activity`, via CloudSyncedStore) — only she ever
--  reads them, they are a few hundred bytes, one row per user is right.
--
--  A MISS is different: "lauki" typed, a barcode that came back as "Haldiram
--  Aloo Bhujia", a photo the model called "jalebi" — none of these had an
--  answer, and the point of keeping them is that the CONTENT DESK counts
--  them across every user and writes the ten most-missed next. A per-user
--  blob cannot be counted across users without pulling every blob down;
--  rows can be counted with one query. Same data, a different reader, a
--  different home. (docs/BACKEND-PATTERNS.md §14.)
--
--  RLS: a user may INSERT her own rows and nothing else — not read them
--  back (the app never shows them), not read anyone else's. The desk reads
--  with the service role from the dashboard. A table nobody can SELECT
--  through the API is a write-only log, which is exactly what it is.
--
--  The id is APP-GENERATED (`<user_id>_<millis>`), so the client's upsert is
--  idempotent: a retry after a dropped connection merges instead of
--  duplicating.
--
--  The columns the client writes are pinned by test/can_i_door_test.dart
--  against this file — a fire-and-forget write cannot report a mismatch.
-- =============================================================================

create table if not exists public.can_i_misses (
  id          text        primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  query       text        not null,
  source      text        not null,    -- 'typed' | 'barcode' | 'photo'
  product     text,                    -- what the barcode or the model said it was
  created_at  timestamptz not null default now(),
  constraint can_i_misses_source_check check (source in ('typed', 'barcode', 'photo'))
);

create index if not exists can_i_misses_created
  on public.can_i_misses (created_at desc);

alter table public.can_i_misses enable row level security;

drop policy if exists can_i_misses_insert on public.can_i_misses;
create policy can_i_misses_insert on public.can_i_misses
  for insert with check (auth.uid() = user_id);

-- The client upserts (insert ... on conflict do update), which needs UPDATE
-- on the conflicting row too. Scoped to her own rows; there is nothing to
-- change on a miss but the retry must not be refused.
drop policy if exists can_i_misses_update on public.can_i_misses;
create policy can_i_misses_update on public.can_i_misses
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- No SELECT policy on purpose: write-only from the app.

-- The desk's view: what is missed most, last 30 days.
create or replace view public.can_i_misses_top as
  select lower(coalesce(product, query)) as asked, source, count(*) as n
  from public.can_i_misses
  where created_at > now() - interval '30 days'
  group by 1, 2
  order by n desc;

revoke all on public.can_i_misses_top from anon, authenticated;
