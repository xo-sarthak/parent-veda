-- =====================================================================
-- 0002_journal.sql — journal entries, weekly notes, photo memories
-- Run AFTER 0001. Paste into Supabase SQL Editor -> Run.
-- (file_url / *_urls / photos / path columns hold Storage URLs in Phase 3;
--  for now they hold whatever the app has.)
-- =====================================================================

-- ---- journal_entries  (JournalStore / models/journal_entry.dart) ----
create table public.journal_entries (
  id            text        primary key,
  user_id       uuid        not null references auth.users (id) on delete cascade,
  type          text        check (type in (
                              'memory','noteForBaby','photo','voice','custom',
                              'symptom','weight','kick','scan','milestone')),
  title         text        not null default '',
  description   text        not null default '',
  date          timestamptz,
  week_number   int         not null default 0,
  image_url     text,
  audio_url     text,
  image_urls    jsonb       not null default '[]'::jsonb,
  audio_urls    jsonb       not null default '[]'::jsonb,
  custom_tag    text        not null default '',
  tags          jsonb       not null default '[]'::jsonb,
  is_automatic  boolean     not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
grant select, insert, update, delete on public.journal_entries to authenticated;
alter table public.journal_entries enable row level security;
create policy "journal_entries own select" on public.journal_entries for select using (auth.uid() = user_id);
create policy "journal_entries own insert" on public.journal_entries for insert with check (auth.uid() = user_id);
create policy "journal_entries own update" on public.journal_entries for update using (auth.uid() = user_id);
create policy "journal_entries own delete" on public.journal_entries for delete using (auth.uid() = user_id);


-- ---- weekly_journal_notes  (MemoryStore / models/memory_models.dart) ----
create table public.weekly_journal_notes (
  id          text        primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  week        int         not null default 0,
  date_iso    date,                          -- json key 'date'
  source      text,                          -- bonding_ritual | reflect_remember
  prompt      text        not null default '',
  text        text        not null default '',
  photos      jsonb       not null default '[]'::jsonb,
  created_at  timestamptz not null default now()
);
grant select, insert, update, delete on public.weekly_journal_notes to authenticated;
alter table public.weekly_journal_notes enable row level security;
create policy "weekly_journal_notes own select" on public.weekly_journal_notes for select using (auth.uid() = user_id);
create policy "weekly_journal_notes own insert" on public.weekly_journal_notes for insert with check (auth.uid() = user_id);
create policy "weekly_journal_notes own update" on public.weekly_journal_notes for update using (auth.uid() = user_id);
create policy "weekly_journal_notes own delete" on public.weekly_journal_notes for delete using (auth.uid() = user_id);


-- ---- photo_memories  (MemoryStore.PhotoMemory) ----
create table public.photo_memories (
  id          text        primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  week        int         not null default 0,
  date_iso    date,                          -- json key 'date'
  path        text,
  created_at  timestamptz not null default now()
);
grant select, insert, update, delete on public.photo_memories to authenticated;
alter table public.photo_memories enable row level security;
create policy "photo_memories own select" on public.photo_memories for select using (auth.uid() = user_id);
create policy "photo_memories own insert" on public.photo_memories for insert with check (auth.uid() = user_id);
create policy "photo_memories own update" on public.photo_memories for update using (auth.uid() = user_id);
create policy "photo_memories own delete" on public.photo_memories for delete using (auth.uid() = user_id);
