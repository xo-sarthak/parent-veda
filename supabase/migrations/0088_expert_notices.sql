-- =====================================================================
-- 0088_expert_notices.sql -- one card from ParentVeda on the doctor Home
-- ---------------------------------------------------------------------
-- Every seller home carries one editorial card from the platform (Shopee's
-- "Seller announcement", Whatnot's banner). Ours is a row an admin writes
-- in the panel: a title, a line or two, an optional link, a window, and an
-- audience -- everyone, or one expert. The app shows the newest one in
-- window as "From ParentVeda" and nothing when there is none. Content is
-- editable; the rule (one card, newest wins) is not -- CLAUDE.md.
--
-- Public-read to signed-in doctors; RLS narrows a per-expert notice to its
-- expert through my_expert_ids(). CMS writes.
-- =====================================================================

create table if not exists public.expert_notices (
  id         text        primary key default ('ntc_' || replace(gen_random_uuid()::text, '-', '')),
  title      text        not null,
  body       text        not null default '',
  url        text,
  expert_id  text,                                   -- null = everyone
  starts_at  timestamptz not null default now(),
  ends_at    timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists expert_notices_window_idx
  on public.expert_notices (starts_at desc);

grant select on public.expert_notices to authenticated;
grant select, insert, update, delete on public.expert_notices to directus_cms;
alter table public.expert_notices enable row level security;

drop policy if exists "notices read" on public.expert_notices;
create policy "notices read" on public.expert_notices
  for select to authenticated
  using (
    starts_at <= now()
    and (ends_at is null or ends_at > now())
    and (expert_id is null or expert_id in (select public.my_expert_ids()))
  );

drop policy if exists "notices cms" on public.expert_notices;
create policy "notices cms" on public.expert_notices
  for all to directus_cms using (true) with check (true);

-- A first one, so the card exists on day one. Replace it in the panel.
insert into public.expert_notices (id, title, body)
values ('ntc_welcome',
        'Welcome to ParentVeda+',
        'Your hours, your bookings and every rupee you earn, in one place. Questions? partners@parentveda.com.')
on conflict (id) do nothing;
