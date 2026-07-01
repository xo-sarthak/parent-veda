-- =====================================================================
-- 0004_daily.sql — moods, baby-talk, affirmations, movement responses
-- (DailyStore). Run AFTER 0001.
-- =====================================================================

-- ---- daily_moods  (one mood per day; PK = user_id + day) ----
create table public.daily_moods (
  user_id     uuid        not null references auth.users (id) on delete cascade,
  day         int         not null,
  mood_id     text        not null,
  updated_at  timestamptz not null default now(),
  primary key (user_id, day)
);
grant select, insert, update, delete on public.daily_moods to authenticated;
alter table public.daily_moods enable row level security;
create policy "daily_moods own select" on public.daily_moods for select using (auth.uid() = user_id);
create policy "daily_moods own insert" on public.daily_moods for insert with check (auth.uid() = user_id);
create policy "daily_moods own update" on public.daily_moods for update using (auth.uid() = user_id);
create policy "daily_moods own delete" on public.daily_moods for delete using (auth.uid() = user_id);


-- ---- baby_talk  ("Dear Baby" messages) ----
create table public.baby_talk (
  id          text        primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  day         int         not null default 0,
  week        int         not null default 0,
  prompt      text        not null default '',
  text        text        not null default '',
  date_iso    date,
  spoken      boolean     not null default false,
  created_at  timestamptz not null default now()
);
grant select, insert, update, delete on public.baby_talk to authenticated;
alter table public.baby_talk enable row level security;
create policy "baby_talk own select" on public.baby_talk for select using (auth.uid() = user_id);
create policy "baby_talk own insert" on public.baby_talk for insert with check (auth.uid() = user_id);
create policy "baby_talk own update" on public.baby_talk for update using (auth.uid() = user_id);
create policy "baby_talk own delete" on public.baby_talk for delete using (auth.uid() = user_id);


-- ---- kept_affirmations  (the text IS the identity; PK = user_id + text) ----
create table public.kept_affirmations (
  user_id     uuid        not null references auth.users (id) on delete cascade,
  text        text        not null,
  created_at  timestamptz not null default now(),
  primary key (user_id, text)
);
grant select, insert, update, delete on public.kept_affirmations to authenticated;
alter table public.kept_affirmations enable row level security;
create policy "kept_affirmations own select" on public.kept_affirmations for select using (auth.uid() = user_id);
create policy "kept_affirmations own insert" on public.kept_affirmations for insert with check (auth.uid() = user_id);
create policy "kept_affirmations own update" on public.kept_affirmations for update using (auth.uid() = user_id);
create policy "kept_affirmations own delete" on public.kept_affirmations for delete using (auth.uid() = user_id);


-- ---- daily_movement_responses  (one response per day; PK = user_id + day) ----
create table public.daily_movement_responses (
  user_id     uuid        not null references auth.users (id) on delete cascade,
  day         int         not null,
  response    text        check (response in ('yes','not_yet')),
  updated_at  timestamptz not null default now(),
  primary key (user_id, day)
);
grant select, insert, update, delete on public.daily_movement_responses to authenticated;
alter table public.daily_movement_responses enable row level security;
create policy "daily_movement_responses own select" on public.daily_movement_responses for select using (auth.uid() = user_id);
create policy "daily_movement_responses own insert" on public.daily_movement_responses for insert with check (auth.uid() = user_id);
create policy "daily_movement_responses own update" on public.daily_movement_responses for update using (auth.uid() = user_id);
create policy "daily_movement_responses own delete" on public.daily_movement_responses for delete using (auth.uid() = user_id);
