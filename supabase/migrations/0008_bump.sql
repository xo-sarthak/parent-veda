-- =====================================================================
-- 0008_bump.sql — bump journey photos (BumpStore)
-- Run AFTER 0001. (image_url holds a Storage URL in Phase 3.)
-- =====================================================================

create table public.bump_photos (
  id          text        primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  image_url   text,                          -- file -> Storage URL (Phase 3)
  week_number int         not null default 0,
  date        timestamptz,
  caption     text        not null default '',
  is_favorite boolean     not null default false,
  created_at  timestamptz not null default now()
);
grant select, insert, update, delete on public.bump_photos to authenticated;
alter table public.bump_photos enable row level security;
create policy "bump_photos own select" on public.bump_photos for select using (auth.uid() = user_id);
create policy "bump_photos own insert" on public.bump_photos for insert with check (auth.uid() = user_id);
create policy "bump_photos own update" on public.bump_photos for update using (auth.uid() = user_id);
create policy "bump_photos own delete" on public.bump_photos for delete using (auth.uid() = user_id);
