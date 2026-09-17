-- =====================================================================
-- 0081_saved_items.sql -- every bookmark in the app, in one table
-- ---------------------------------------------------------------------
-- Before this there were seven saved-sets in seven stores (videos, daily
-- reads, products, Can-I questions, read-to-baby pieces, community posts,
-- the TTC reader), six of them as blobs in user_state and one local-only.
-- Two Saved hubs read three of them. A bookmark made in one stage was
-- invisible from the next, and the reader the user likes best never saved
-- to the cloud at all.
--
-- THE RULE THIS TABLE ENFORCES (docs/FAMILY-MODEL.md):
--   the PERSON owns a bookmark. Stage and child are TAGS on it, never owners.
-- So "she saved it while trying, and now she is pregnant" is not an edge
-- case, it is a row with stage = 'trying' in a list that shows everything.
--
-- WHY ROWS AND NOT A BLOB. The blob pattern (user_state, CloudSyncedStore) is
-- "cloud wins on startup, push whole on change". Two phones with the same
-- account: she unsaves on the tablet, the phone was offline with the old
-- set, the phone comes back and pushes -- the unsave is undone. Rows keyed by
-- (user, kind, item) merge item by item, a tombstone records the unsave, and
-- the later updated_at wins. The app-generates-the-id rule holds without a
-- uuid: the natural key IS the identity, on every device, deterministically.
--
-- WHY A TITLE SNAPSHOT. Content gets edited. A bookmark that finds its
-- content by comparing a live title orphans on every edit --
-- read_to_baby_saved_store's own header records that happening. The row
-- carries what it needs to render itself; the live content is looked up by
-- id and, when it is gone, the row says so instead of vanishing.
--
-- PREREQ: 0001 (profiles), 0021 (children).
-- =====================================================================

create table if not exists public.saved_items (
  user_id     uuid        not null references auth.users (id) on delete cascade,
  kind        text        not null,
  item_id     text        not null,
  stage       text,                     -- tag: where she was when she saved it
  child_id    text        references public.children (id) on delete set null,
  title       text        not null default '',
  subtitle    text,
  saved_at    timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  removed_at  timestamptz,              -- tombstone; null = live
  primary key (user_id, kind, item_id),
  constraint saved_items_kind_check check (kind in (
    'article', 'video', 'recipe', 'product', 'question',
    'read_to_baby', 'post', 'tool', 'activity', 'tip'
  )),
  constraint saved_items_stage_check check (
    stage is null or stage in ('trying', 'pregnancy', 'parenting', 'skilling')
  )
);

-- The Saved screen lists one user's live rows newest-first; the sync pulls
-- one user's rows changed since a time. One index serves both.
create index if not exists saved_items_user_updated
  on public.saved_items (user_id, updated_at desc);

-- Own rows only, all four verbs. NOT readable by the partner: a bookmark is
-- personal (FAMILY-MODEL §5). Sharing, if ever wanted, is a column and a
-- policy, not a change to this one.
alter table public.saved_items enable row level security;

drop policy if exists saved_items_select on public.saved_items;
create policy saved_items_select on public.saved_items
  for select using (auth.uid() = user_id);

drop policy if exists saved_items_insert on public.saved_items;
create policy saved_items_insert on public.saved_items
  for insert with check (auth.uid() = user_id);

drop policy if exists saved_items_update on public.saved_items;
create policy saved_items_update on public.saved_items
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists saved_items_delete on public.saved_items;
create policy saved_items_delete on public.saved_items
  for delete using (auth.uid() = user_id);

grant select, insert, update, delete on public.saved_items to authenticated;
grant select, insert, update, delete on public.saved_items to service_role;

-- Tombstones are useful for as long as a device might still be offline with
-- the old row; after 30 days they are only weight. Harmless to run by hand.
create or replace function public.saved_items_prune()
returns int
language plpgsql
security definer set search_path = ''
as $$
declare v_n int;
begin
  delete from public.saved_items
   where removed_at is not null
     and removed_at < now() - interval '30 days';
  get diagnostics v_n = row_count;
  return v_n;
end;
$$;

revoke execute on function public.saved_items_prune() from public;
