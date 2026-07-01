-- =====================================================================
-- 0010_father.sql — the father's own data
--   * father_journal_entries: the father's journal (mirrors journal_entries).
--     The paired MOTHER can READ it (for her merged view); writes own-only.
--   * father_missions: which days' father-mode mission is marked done.
-- Run after 0009 (needs public.my_partner_id from the pairing migration).
-- =====================================================================

-- ---- father_journal_entries -----------------------------------------
create table public.father_journal_entries (
  id            text        primary key,
  user_id       uuid        not null references auth.users (id) on delete cascade,
  type          text,
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
grant select, insert, update, delete on public.father_journal_entries to authenticated;
alter table public.father_journal_entries enable row level security;
-- read: own OR your partner's (so the mother sees the father's entries)
create policy "father_journal own or partner select"
  on public.father_journal_entries for select
  using (auth.uid() = user_id or user_id = public.my_partner_id());
create policy "father_journal own insert" on public.father_journal_entries for insert with check (auth.uid() = user_id);
create policy "father_journal own update" on public.father_journal_entries for update using (auth.uid() = user_id);
create policy "father_journal own delete" on public.father_journal_entries for delete using (auth.uid() = user_id);


-- ---- father_missions  (one row per done day; PK = user_id + day) -----
create table public.father_missions (
  user_id     uuid        not null references auth.users (id) on delete cascade,
  day         int         not null,
  created_at  timestamptz not null default now(),
  primary key (user_id, day)
);
grant select, insert, update, delete on public.father_missions to authenticated;
alter table public.father_missions enable row level security;
create policy "father_missions own select" on public.father_missions for select using (auth.uid() = user_id);
create policy "father_missions own insert" on public.father_missions for insert with check (auth.uid() = user_id);
create policy "father_missions own delete" on public.father_missions for delete using (auth.uid() = user_id);
