-- 0121_community.sql — the community, for real (2026-10-28)
--
-- Until now the community was a front-end prototype: her posts synced only to
-- her own `user_state` row, so nobody ever saw anybody else's. This is the
-- shared, moderated version. Plan: docs/COMMUNITY.md.
--
-- ⚠️ THE ONE IDEA THIS FILE IS BUILT ON: ANONYMITY IS A COLUMN PROBLEM.
-- Row-level security answers "may you see this ROW". An anonymous post is a
-- row everyone may see, with ONE column (user_id) nobody may see. RLS cannot
-- say that. A `select` policy that lets B read A's anonymous post hands B the
-- `user_id` too, and the post is anonymous only in the UI. So:
--   · the app's roles get NO table privileges on any community table at all;
--   · every read is a `security definer` function that returns a resolved
--     author (community name or first name) and an `is_mine` flag — never
--     `user_id`;
--   · every write is a function too, so the server pins the author, checks
--     mutes and rate limits, runs the safety check, and RETURNS the outcome
--     ("live" / "held") so the app can tell her what happened (no save is
--     silent). Trade-off: we give up PostgREST's free filtering; we get an
--     anonymity that cannot leak through a forgotten column.
--     test/community_anonymity_test.dart scans this file for that shape.
--
-- Two faces, never joined: a member has ONE community name (pseudonym) used
-- on anonymous posts, and her first name on named posts. Nothing returned
-- here ever puts both on one object. A profile shows one face only.
--
-- Safety words are CODE, not content (CLAUDE.md: rules are not a dropdown).
-- `community_check_text` holds the lists; lib/services/community_safety.dart
-- mirrors them so the helpline shows while she types, and
-- test/community_safety_parity_test.dart keeps the two equal.

-- ---------------------------------------------------------------------------
--  Tables
-- ---------------------------------------------------------------------------

create table if not exists public.community_profiles (
  user_id               uuid        primary key references auth.users (id) on delete cascade,
  pseudonym             text        not null unique
                                    check (char_length(pseudonym) between 3 and 40),
  avatar_seed           int         not null default 0 check (avatar_seed between 0 and 63),
  rules_accepted_at     timestamptz,
  pseudonym_changed_at  timestamptz not null default now(),
  muted_until           timestamptz,
  banned_at             timestamptz,
  activity_seen_at      timestamptz not null default now(),
  created_at            timestamptz not null default now()
);

create table if not exists public.community_rooms (
  id           text        primary key,
  title        text        not null,
  blurb        text        not null default '',
  stage_tag    text        not null default 'all'
                           check (stage_tag in ('trying', 'pregnancy', 'parenting', 'all')),
  kind         text        not null default 'room'
                           check (kind in ('room', 'birth_club', 'offering', 'session')),
  offering_id  text,
  mark         text        not null default '',   -- 'tab:<TtcTabMark>' / 'tool:<TtcToolMark>'
  hue          real        not null default 210,
  sort         int         not null default 100,
  is_open      boolean     not null default true,
  created_at   timestamptz not null default now()
);

create table if not exists public.community_room_members (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  room_id    text        not null references public.community_rooms (id) on delete cascade,
  muted      boolean     not null default false,
  joined_at  timestamptz not null default now(),
  primary key (user_id, room_id)
);
create index if not exists community_room_members_room on public.community_room_members (room_id);

create table if not exists public.community_posts (
  id              text        primary key check (char_length(id) between 8 and 64),
  room_id         text        not null references public.community_rooms (id),
  user_id         uuid        not null references auth.users (id) on delete cascade,
  identity        text        not null check (identity in ('anon', 'named')),
  author_label    text        not null default '',  -- her first name, for a named post
  title           text        not null check (char_length(title) between 4 and 160),
  body            text        not null default '' check (char_length(body) <= 4000),
  kind            text        not null default 'text' check (kind in ('text', 'poll')),
  poll_options    jsonb,
  poll_closes_at  timestamptz,
  hashtags        text[]      not null default '{}',
  status          text        not null default 'live'
                              check (status in ('live', 'held', 'hidden', 'removed')),
  hold_reason     text,
  crisis          boolean     not null default false,
  crisis_handled  boolean     not null default false,
  like_count      int         not null default 0,
  comment_count   int         not null default 0,
  report_count    int         not null default 0,
  created_at      timestamptz not null default now(),
  deleted_at      timestamptz
);
create index if not exists community_posts_room_new on public.community_posts (room_id, created_at desc);
create index if not exists community_posts_new on public.community_posts (created_at desc);
create index if not exists community_posts_user on public.community_posts (user_id, created_at desc);
create index if not exists community_posts_queue on public.community_posts (status, crisis) where status <> 'live' or crisis;

create table if not exists public.community_comments (
  id             text        primary key check (char_length(id) between 8 and 64),
  post_id        text        not null references public.community_posts (id) on delete cascade,
  parent_id      text        references public.community_comments (id) on delete cascade,
  user_id        uuid        not null references auth.users (id) on delete cascade,
  identity       text        not null check (identity in ('anon', 'named')),
  author_label   text        not null default '',
  body           text        not null check (char_length(body) between 1 and 2000),
  status         text        not null default 'live'
                             check (status in ('live', 'held', 'hidden', 'removed')),
  hold_reason    text,
  crisis         boolean     not null default false,
  crisis_handled boolean     not null default false,
  like_count     int         not null default 0,
  report_count   int         not null default 0,
  created_at     timestamptz not null default now(),
  deleted_at     timestamptz
);
create index if not exists community_comments_post on public.community_comments (post_id, created_at);
create index if not exists community_comments_user on public.community_comments (user_id, created_at desc);

-- Photos. The object path is '<postId>/<random>.jpg' — NEVER the user id,
-- which would put her identity in every URL of an anonymous post.
create table if not exists public.community_media (
  id          text        primary key,
  post_id     text        not null references public.community_posts (id) on delete cascade,
  path        text        not null unique,
  position    int         not null default 0,
  status      text        not null default 'pending'
                          check (status in ('pending', 'approved', 'rejected')),
  created_at  timestamptz not null default now()
);
create index if not exists community_media_post on public.community_media (post_id, position);

create table if not exists public.community_reactions (
  user_id      uuid        not null references auth.users (id) on delete cascade,
  target_kind  text        not null check (target_kind in ('post', 'comment')),
  target_id    text        not null,
  created_at   timestamptz not null default now(),
  primary key (user_id, target_kind, target_id)
);
create index if not exists community_reactions_target on public.community_reactions (target_kind, target_id);

create table if not exists public.community_poll_votes (
  post_id     text        not null references public.community_posts (id) on delete cascade,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  option_idx  int         not null check (option_idx between 0 and 3),
  created_at  timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table if not exists public.community_reports (
  id           uuid        primary key default gen_random_uuid(),
  reporter     uuid        not null references auth.users (id) on delete cascade,
  target_kind  text        not null check (target_kind in ('post', 'comment')),
  target_id    text        not null,
  reason       text        not null check (reason in
                 ('harassment', 'explicit', 'misinformation', 'spam', 'at_risk', 'other')),
  note         text        not null default '' check (char_length(note) <= 500),
  created_at   timestamptz not null default now(),
  resolved_at  timestamptz,
  resolution   text,
  unique (reporter, target_kind, target_id)
);
create index if not exists community_reports_open on public.community_reports (target_kind, target_id) where resolved_at is null;

-- A block stores the LABEL she saw when she blocked, so her blocked list can
-- name people without ever joining a community name to a real name.
create table if not exists public.community_blocks (
  id          uuid        primary key default gen_random_uuid(),
  blocker     uuid        not null references auth.users (id) on delete cascade,
  blocked     uuid        not null references auth.users (id) on delete cascade,
  label       text        not null default '',
  created_at  timestamptz not null default now(),
  unique (blocker, blocked)
);

create table if not exists public.community_hidden (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  post_id    text        not null references public.community_posts (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, post_id)
);

-- Written by service_role only (the dashboard): `insert into
-- public.community_moderators (user_id, role) values ('<uid>', 'admin');`
create table if not exists public.community_moderators (
  user_id   uuid        primary key references auth.users (id) on delete cascade,
  role      text        not null default 'moderator' check (role in ('moderator', 'admin')),
  added_at  timestamptz not null default now()
);

-- The audit trail. Every moderator action writes one row, with a reason.
create table if not exists public.community_mod_actions (
  id           uuid        primary key default gen_random_uuid(),
  actor        uuid        references auth.users (id) on delete set null,
  action       text        not null,
  target_kind  text        not null,
  target_id    text        not null,
  reason       text        not null default '',
  created_at   timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
--  Lock every table. No policies = no direct access for the app's roles; the
--  functions below run as their owner and are the only door.
-- ---------------------------------------------------------------------------

alter table public.community_profiles     enable row level security;
alter table public.community_rooms        enable row level security;
alter table public.community_room_members enable row level security;
alter table public.community_posts        enable row level security;
alter table public.community_comments     enable row level security;
alter table public.community_media        enable row level security;
alter table public.community_reactions    enable row level security;
alter table public.community_poll_votes   enable row level security;
alter table public.community_reports      enable row level security;
alter table public.community_blocks       enable row level security;
alter table public.community_hidden       enable row level security;
alter table public.community_moderators   enable row level security;
alter table public.community_mod_actions  enable row level security;

revoke all on public.community_profiles, public.community_rooms,
  public.community_room_members, public.community_posts,
  public.community_comments, public.community_media,
  public.community_reactions, public.community_poll_votes,
  public.community_reports, public.community_blocks, public.community_hidden,
  public.community_moderators, public.community_mod_actions
  from anon, authenticated;

-- ---------------------------------------------------------------------------
--  Counters, kept by triggers. A feed card reads one row; it never counts.
--  Every write path (the functions below, the dashboard, a future Directus)
--  goes through the same trigger, so the number cannot drift.
-- ---------------------------------------------------------------------------

create or replace function public.community_count_reaction()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  d int := case when tg_op = 'INSERT' then 1 else -1 end;
  k text;
  t text;
begin
  if tg_op = 'INSERT' then k := new.target_kind; t := new.target_id;
  else k := old.target_kind; t := old.target_id; end if;
  if k = 'post' then
    update public.community_posts set like_count = greatest(0, like_count + d) where id = t;
  else
    update public.community_comments set like_count = greatest(0, like_count + d) where id = t;
  end if;
  return null;
end $$;

drop trigger if exists community_reactions_count on public.community_reactions;
create trigger community_reactions_count after insert or delete on public.community_reactions
  for each row execute function public.community_count_reaction();

-- comment_count = live, undeleted comments. Recomputed (not +1/-1) because a
-- comment moves between live / held / removed, and a recount cannot drift.
create or replace function public.community_count_comments()
returns trigger language plpgsql security definer set search_path = '' as $$
declare pid text := coalesce(new.post_id, old.post_id);
begin
  update public.community_posts p set comment_count = (
    select count(*) from public.community_comments c
     where c.post_id = pid and c.status = 'live' and c.deleted_at is null)
  where p.id = pid;
  return null;
end $$;

drop trigger if exists community_comments_count on public.community_comments;
create trigger community_comments_count after insert or delete or update of status, deleted_at
  on public.community_comments for each row execute function public.community_count_comments();

-- ---------------------------------------------------------------------------
--  Internal helpers (not callable by the app)
-- ---------------------------------------------------------------------------

create or replace function public.community_is_mod()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.community_moderators where user_id = auth.uid())
$$;

-- 'crisis' / 'hold:<why>' / null. Lowercased, word-bounded matching.
-- ⚠️ KEEP IN STEP WITH lib/services/community_safety.dart (parity test).
create or replace function public.community_check_text(t text)
returns text language plpgsql immutable set search_path = '' as $$
declare
  s text := replace(replace(lower(coalesce(t, '')), '’', ''''), '‘', '''');
  -- CRISIS-PHRASES-START
  crisis text[] := array[
    'kill myself', 'killing myself', 'end my life', 'end it all', 'want to die',
    'wish i was dead', 'wish i were dead', 'suicide', 'suicidal',
    'hurt myself', 'harm myself', 'self harm', 'self-harm', 'cut myself',
    'no reason to live', 'can''t go on', 'cant go on', 'better off without me',
    'hurt my baby', 'harm my baby', 'mar jaungi', 'mar jaun', 'jeena nahi chahti'
  ];
  -- CRISIS-PHRASES-END
  -- HOLD-WORDS-START
  hold text[] := array[
    'fuck', 'fucking', 'bitch', 'bastard', 'slut', 'whore', 'cunt', 'dick',
    'motherfucker', 'retard', 'chutiya', 'chutiye', 'madarchod', 'behenchod',
    'bhenchod', 'bhosdi', 'randi', 'harami', 'kamini', 'gandu', 'lauda', 'lund',
    'porn', 'nude', 'nudes', 'sexting'
  ];
  -- HOLD-WORDS-END
  w text;
begin
  foreach w in array crisis loop
    if position(w in s) > 0 then return 'crisis'; end if;
  end loop;
  foreach w in array hold loop
    if s ~ ('(^|[^a-z])' || w || '([^a-z]|$)') then return 'hold:language'; end if;
  end loop;
  -- Links and phone numbers: the two shapes spam and "DM me" selling take.
  if s ~ '(https?://|www\.|wa\.me/|t\.me/|bit\.ly/)' then return 'hold:link'; end if;
  if s ~ '(\+?91[ -]?)?[6-9][0-9]{9}' then return 'hold:phone'; end if;
  return null;
end $$;

-- The author as the app may see it. Never the user id.
create or replace function public.community_author(
  p_identity text, p_user uuid, p_label text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select case when p_identity = 'anon' then jsonb_build_object(
      'label', coalesce((select pseudonym from public.community_profiles where user_id = p_user), 'A member'),
      'anon', true,
      'seed', coalesce((select avatar_seed from public.community_profiles where user_id = p_user), 0),
      'team', false,
      'is_mine', p_user = auth.uid())
    else jsonb_build_object(
      'label', p_label, 'anon', false, 'seed', 0,
      'team', exists (select 1 from public.community_moderators m where m.user_id = p_user),
      'is_mine', p_user = auth.uid())
  end
$$;

-- Blocks run both ways: she does not see them, they do not see her.
create or replace function public.community_blocked_between(a uuid, b uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.community_blocks
                  where (blocker = a and blocked = b) or (blocker = b and blocked = a))
$$;

-- Approved photo paths for a post; her own post also shows its pending ones.
create or replace function public.community_post_media(p_post text, p_owner uuid)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object('path', m.path, 'status', m.status)
                            order by m.position), '[]'::jsonb)
    from public.community_media m
   where m.post_id = p_post
     and (m.status = 'approved' or (p_owner = auth.uid() and m.status = 'pending'))
$$;

create or replace function public.community_post_json(p public.community_posts)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  poll jsonb := null;
  r public.community_rooms;
begin
  select * into r from public.community_rooms where id = p.room_id;
  if p.kind = 'poll' then
    poll := jsonb_build_object(
      'options', p.poll_options,
      'counts', (select coalesce(jsonb_agg(coalesce(cnt, 0) order by i), '[]'::jsonb)
                   from generate_series(0, jsonb_array_length(p.poll_options) - 1) i
                   left join (select option_idx, count(*) cnt from public.community_poll_votes
                               where post_id = p.id group by option_idx) v on v.option_idx = i),
      'mine', (select option_idx from public.community_poll_votes where post_id = p.id and user_id = me),
      'closes_at', p.poll_closes_at);
  end if;
  return jsonb_build_object(
    'id', p.id,
    'room_id', p.room_id,
    'room_title', r.title,
    'room_mark', r.mark,
    'room_hue', r.hue,
    'author', public.community_author(p.identity, p.user_id, p.author_label),
    'title', p.title,
    'body', p.body,
    'kind', p.kind,
    'poll', poll,
    'hashtags', to_jsonb(p.hashtags),
    'media', public.community_post_media(p.id, p.user_id),
    'like_count', p.like_count,
    'comment_count', p.comment_count,
    'liked', exists (select 1 from public.community_reactions x
                      where x.user_id = me and x.target_kind = 'post' and x.target_id = p.id),
    -- The author learns her post is waiting; nobody else learns anything.
    'status', case when p.user_id = me then p.status else 'live' end,
    'created_at', p.created_at);
end $$;

-- May the caller see this post? Live, not deleted, not hidden by her, no
-- block either way — or it is her own (she always sees her own, with status).
create or replace function public.community_can_see(p public.community_posts)
returns boolean language sql stable security definer set search_path = '' as $$
  select p.deleted_at is null and (
    p.user_id = auth.uid() or (
      p.status = 'live'
      and not exists (select 1 from public.community_hidden h where h.user_id = auth.uid() and h.post_id = p.id)
      and not public.community_blocked_between(auth.uid(), p.user_id)))
$$;

revoke all on function public.community_is_mod(), public.community_check_text(text),
  public.community_author(text, uuid, text), public.community_blocked_between(uuid, uuid),
  public.community_post_media(text, uuid), public.community_post_json(public.community_posts),
  public.community_can_see(public.community_posts),
  public.community_count_reaction(), public.community_count_comments()
  from public, anon, authenticated;

-- ---------------------------------------------------------------------------
--  Her standing: profile, rules, whether she moderates, unread replies
-- ---------------------------------------------------------------------------

create or replace function public.community_me()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  pr public.community_profiles;
  has boolean;
  unread int := 0;
begin
  if me is null then return jsonb_build_object('signed_in', false); end if;
  select * into pr from public.community_profiles where user_id = me;
  has := found;
  if has then
    select count(*) into unread from public.community_comments c
      left join public.community_posts p on p.id = c.post_id
      left join public.community_comments pc on pc.id = c.parent_id
     where c.user_id <> me and c.status = 'live' and c.deleted_at is null
       and c.created_at > pr.activity_seen_at
       and (p.user_id = me or pc.user_id = me)
       and not public.community_blocked_between(me, c.user_id);
  end if;
  return jsonb_build_object(
    'signed_in', true,
    'joined', has and pr.rules_accepted_at is not null,
    'pseudonym', pr.pseudonym,
    'seed', coalesce(pr.avatar_seed, 0),
    'first_name', (select nullif(split_part(trim(coalesce(name, '')), ' ', 1), '')
                     from public.profiles where id = me),
    'can_rename_at', case when pr.user_id is null then null else pr.pseudonym_changed_at + interval '30 days' end,
    'muted_until', case when pr.muted_until > now() then pr.muted_until end,
    'banned', pr.banned_at is not null,
    'is_mod', public.community_is_mod(),
    'unread', unread);
end $$;

-- Join (first time: rules + name), or rename (once every 30 days).
create or replace function public.community_join(p_pseudonym text, p_seed int)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  nm text := trim(regexp_replace(coalesce(p_pseudonym, ''), '\s+', ' ', 'g'));
  pr public.community_profiles;
begin
  if me is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  if char_length(nm) < 3 or char_length(nm) > 40 or nm !~ '^[A-Za-z][A-Za-z ]*$' then
    return jsonb_build_object('ok', false, 'reason', 'invalid');
  end if;
  if public.community_check_text(nm) is not null then
    return jsonb_build_object('ok', false, 'reason', 'invalid');
  end if;
  select * into pr from public.community_profiles where user_id = me;
  if found and lower(pr.pseudonym) <> lower(nm)
     and pr.rules_accepted_at is not null
     and pr.pseudonym_changed_at > now() - interval '30 days' then
    return jsonb_build_object('ok', false, 'reason', 'too_soon',
                              'can_rename_at', pr.pseudonym_changed_at + interval '30 days');
  end if;
  if exists (select 1 from public.community_profiles
              where lower(pseudonym) = lower(nm) and user_id <> me) then
    return jsonb_build_object('ok', false, 'reason', 'taken');
  end if;
  insert into public.community_profiles (user_id, pseudonym, avatar_seed, rules_accepted_at)
  values (me, nm, greatest(0, least(63, coalesce(p_seed, 0))), now())
  on conflict (user_id) do update set
    pseudonym = excluded.pseudonym,
    avatar_seed = excluded.avatar_seed,
    rules_accepted_at = coalesce(public.community_profiles.rules_accepted_at, now()),
    pseudonym_changed_at = case when lower(public.community_profiles.pseudonym) <> lower(excluded.pseudonym)
                                then now() else public.community_profiles.pseudonym_changed_at end;
  return jsonb_build_object('ok', true, 'pseudonym', nm);
end $$;

create or replace function public.community_mark_seen()
returns void language sql security definer set search_path = '' as $$
  update public.community_profiles set activity_seen_at = now() where user_id = auth.uid()
$$;

-- ---------------------------------------------------------------------------
--  Rooms
-- ---------------------------------------------------------------------------

create or replace function public.community_rooms_list()
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object(
      'id', r.id, 'title', r.title, 'blurb', r.blurb, 'stage', r.stage_tag,
      'kind', r.kind, 'mark', r.mark, 'hue', r.hue, 'sort', r.sort,
      'members', (select count(*) from public.community_room_members m where m.room_id = r.id),
      'joined', m.user_id is not null,
      'muted', coalesce(m.muted, false)) order by r.sort, r.title), '[]'::jsonb)
    from public.community_rooms r
    left join public.community_room_members m on m.room_id = r.id and m.user_id = auth.uid()
   where r.is_open and r.kind in ('room', 'birth_club')
$$;

create or replace function public.community_set_room(p_room text, p_join boolean, p_mute boolean default false)
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  if not exists (select 1 from public.community_rooms where id = p_room and is_open) then
    return jsonb_build_object('ok', false, 'reason', 'no_room');
  end if;
  if p_join then
    insert into public.community_room_members (user_id, room_id, muted)
    values (auth.uid(), p_room, coalesce(p_mute, false))
    on conflict (user_id, room_id) do update set muted = coalesce(p_mute, false);
  else
    delete from public.community_room_members where user_id = auth.uid() and room_id = p_room;
  end if;
  return jsonb_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------------
--  Reading
-- ---------------------------------------------------------------------------

-- p_scope: 'for_you' | 'rooms' (joined) | 'room' (p_room) | 'mine' | 'ids'
-- p_sort:  'top' | 'new'. p_stage ranks her stage's rooms first ('trying' …).
create or replace function public.community_feed(
  p_scope text default 'for_you',
  p_sort text default 'top',
  p_room text default null,
  p_stage text default null,
  p_ids text[] default null,
  p_offset int default 0,
  p_limit int default 20)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then return '[]'::jsonb; end if;
  return coalesce((
    select jsonb_agg(public.community_post_json(q.post) order by q.rank desc, (q.post).created_at desc)
      from (
        select p as post,
          case when p_sort = 'new' or p_scope in ('mine', 'ids') then 0
          else (p.like_count + 2 * p.comment_count + 1)
               / power(extract(epoch from (now() - p.created_at)) / 3600 + 2, 1.4)
               * case when p_stage is not null and r.stage_tag in (p_stage, 'all') then 1.6 else 1 end
               * case when m.user_id is not null then 1.4 else 1 end
          end as rank
          from public.community_posts p
          join public.community_rooms r on r.id = p.room_id
          left join public.community_room_members m on m.room_id = p.room_id and m.user_id = me
         where public.community_can_see(p)
           and case p_scope
                 when 'room'  then p.room_id = p_room
                 when 'rooms' then m.user_id is not null
                 when 'mine'  then p.user_id = me
                 when 'ids'   then p.id = any (coalesce(p_ids, '{}'))
                 else coalesce(m.muted, false) = false
               end
         order by rank desc, p.created_at desc
         offset greatest(0, p_offset) limit least(50, greatest(1, p_limit))
      ) q), '[]'::jsonb);
end $$;

create or replace function public.community_post(p_id text)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare p public.community_posts;
begin
  select * into p from public.community_posts where id = p_id;
  if not found or not public.community_can_see(p) then return null; end if;
  return public.community_post_json(p);
end $$;

-- Flat list; the app nests replies under parent_id. Top = most liked first.
create or replace function public.community_comments_list(p_post text, p_sort text default 'top')
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  p public.community_posts;
begin
  select * into p from public.community_posts where id = p_post;
  if not found or not public.community_can_see(p) then return '[]'::jsonb; end if;
  return coalesce((
    select jsonb_agg(jsonb_build_object(
        'id', c.id, 'post_id', c.post_id, 'parent_id', c.parent_id,
        'author', public.community_author(c.identity, c.user_id, c.author_label),
        'body', c.body, 'like_count', c.like_count,
        'liked', exists (select 1 from public.community_reactions x
                          where x.user_id = me and x.target_kind = 'comment' and x.target_id = c.id),
        'status', case when c.user_id = me then c.status else 'live' end,
        'is_op', c.user_id = p.user_id and c.identity = p.identity,
        'created_at', c.created_at)
      order by case when p_sort = 'top' and c.parent_id is null then c.like_count end desc nulls last,
               c.created_at)
      from public.community_comments c
     where c.post_id = p_post and c.deleted_at is null
       and (c.user_id = me or (c.status = 'live' and not public.community_blocked_between(me, c.user_id)))
  ), '[]'::jsonb);
end $$;

-- Replies to her posts and to her comments, newest first.
create or replace function public.community_activity(p_limit int default 40)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(x order by (x->>'created_at') desc), '[]'::jsonb) from (
    select jsonb_build_object(
      'comment_id', c.id, 'post_id', p.id, 'post_title', p.title,
      'to', case when pc.user_id = auth.uid() then 'comment' else 'post' end,
      'author', public.community_author(c.identity, c.user_id, c.author_label),
      'body', c.body, 'created_at', c.created_at,
      'unread', c.created_at > coalesce((select activity_seen_at from public.community_profiles where user_id = auth.uid()), now())) x
      from public.community_comments c
      join public.community_posts p on p.id = c.post_id
      left join public.community_comments pc on pc.id = c.parent_id
     where c.user_id <> auth.uid() and c.status = 'live' and c.deleted_at is null and p.deleted_at is null
       and (pc.user_id = auth.uid() or (c.parent_id is null and p.user_id = auth.uid()))
       and not public.community_blocked_between(auth.uid(), c.user_id)
     order by c.created_at desc limit least(100, greatest(1, p_limit))) t
$$;

-- One face of a member. From a post or comment she taps (p_from), or her
-- own face (p_from null, p_face given). The answer never names the other face.
create or replace function public.community_face(p_from text default null, p_face text default 'anon')
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  who uuid; face text; lbl text;
begin
  if auth.uid() is null then return null; end if;
  if p_from is null then
    who := auth.uid(); face := case when p_face = 'named' then 'named' else 'anon' end;
  else
    select user_id, identity, author_label into who, face, lbl from public.community_posts where id = p_from;
    if not found then
      select user_id, identity, author_label into who, face, lbl from public.community_comments where id = p_from;
    end if;
    if who is null or public.community_blocked_between(auth.uid(), who) then return null; end if;
  end if;
  if lbl is null and face = 'named' then
    select author_label into lbl from public.community_posts
     where user_id = who and identity = 'named' order by created_at desc limit 1;
    lbl := coalesce(lbl, (select nullif(split_part(trim(coalesce(name, '')), ' ', 1), '')
                            from public.profiles where id = who), 'You');
  end if;
  return jsonb_build_object(
    'author', public.community_author(face, who, coalesce(lbl, '')),
    'joined_at', (select created_at from public.community_profiles where user_id = who),
    'posts', coalesce((
      select jsonb_agg(public.community_post_json(s.post) order by (s.post).created_at desc)
        from (select p as post from public.community_posts p
               where p.user_id = who and p.identity = face and public.community_can_see(p)
               order by p.created_at desc limit 30) s), '[]'::jsonb));
end $$;

-- ---------------------------------------------------------------------------
--  Writing. Every write returns what happened to it.
-- ---------------------------------------------------------------------------

-- Who may write, and as whom. Null = fine; otherwise the reason.
create or replace function public.community_gate()
returns text language plpgsql stable security definer set search_path = '' as $$
declare pr public.community_profiles;
begin
  if auth.uid() is null then return 'signed_out'; end if;
  select * into pr from public.community_profiles where user_id = auth.uid();
  if not found or pr.rules_accepted_at is null then return 'not_joined'; end if;
  if pr.banned_at is not null then return 'banned'; end if;
  if pr.muted_until > now() then return 'muted'; end if;
  return null;
end $$;
revoke all on function public.community_gate() from public, anon, authenticated;

create or replace function public.community_first_name()
returns text language sql stable security definer set search_path = '' as $$
  select nullif(split_part(trim(coalesce(name, '')), ' ', 1), '') from public.profiles where id = auth.uid()
$$;
revoke all on function public.community_first_name() from public, anon, authenticated;

create or replace function public.community_create_post(
  p_id text, p_room text, p_identity text, p_title text, p_body text default '',
  p_poll_options jsonb default null, p_poll_days int default 3)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  gate text := public.community_gate();
  existing public.community_posts;
  verdict text;
  fname text;
  st text := 'live';
  tags text[];
  opts jsonb := null;
begin
  -- Idempotent: a retry of a post that already landed returns its outcome.
  select * into existing from public.community_posts where id = p_id;
  if found then
    if existing.user_id <> me then return jsonb_build_object('ok', false, 'reason', 'conflict'); end if;
    return jsonb_build_object('ok', true, 'status', existing.status, 'crisis', existing.crisis);
  end if;
  if gate is not null then
    return jsonb_build_object('ok', false, 'reason', gate,
      'muted_until', (select muted_until from public.community_profiles where user_id = me));
  end if;
  if not exists (select 1 from public.community_rooms where id = p_room and is_open) then
    return jsonb_build_object('ok', false, 'reason', 'no_room');
  end if;
  if char_length(trim(coalesce(p_title, ''))) < 4 then
    return jsonb_build_object('ok', false, 'reason', 'too_short');
  end if;
  -- Rate limit: 5 posts an hour. Real mothers never hit it; a spammer does.
  if (select count(*) from public.community_posts where user_id = me and created_at > now() - interval '1 hour') >= 5 then
    return jsonb_build_object('ok', false, 'reason', 'rate');
  end if;
  if p_identity = 'named' then
    fname := public.community_first_name();
    if fname is null then return jsonb_build_object('ok', false, 'reason', 'no_name'); end if;
  end if;
  if p_poll_options is not null and jsonb_typeof(p_poll_options) = 'array' then
    select jsonb_agg(left(trim(v), 60)) into opts
      from jsonb_array_elements_text(p_poll_options) v where trim(v) <> '';
    if opts is null or jsonb_array_length(opts) < 2 or jsonb_array_length(opts) > 4 then
      return jsonb_build_object('ok', false, 'reason', 'poll');
    end if;
  end if;
  verdict := public.community_check_text(p_title || ' ' || coalesce(p_body, '') || ' ' || coalesce(opts::text, ''));
  if verdict like 'hold:%' then st := 'held'; end if;
  select coalesce(array_agg(distinct lower(m[1])), '{}') into tags
    from regexp_matches(coalesce(p_body, '') || ' ' || p_title, '#([A-Za-z][A-Za-z0-9_]{1,30})', 'g') m;
  insert into public.community_posts (id, room_id, user_id, identity, author_label, title, body,
                                      kind, poll_options, poll_closes_at, hashtags, status, hold_reason, crisis)
  values (p_id, p_room, me, case when p_identity = 'named' then 'named' else 'anon' end,
          coalesce(fname, ''), trim(p_title), trim(coalesce(p_body, '')),
          case when opts is null then 'text' else 'poll' end, opts,
          case when opts is null then null else now() + make_interval(days => greatest(1, least(7, coalesce(p_poll_days, 3)))) end,
          tags, st, case when st = 'held' then substr(verdict, 6) end, coalesce(verdict = 'crisis', false));
  -- Posting in a room joins it, so its replies reach "My rooms".
  insert into public.community_room_members (user_id, room_id) values (me, p_room)
  on conflict do nothing;
  return jsonb_build_object('ok', true, 'status', st, 'crisis', coalesce(verdict = 'crisis', false));
end $$;

-- Called once per photo, after the upload. The path's first segment is the
-- post id; the post must be hers.
create or replace function public.community_add_media(p_post text, p_path text, p_position int)
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  if not exists (select 1 from public.community_posts where id = p_post and user_id = auth.uid()) then
    return jsonb_build_object('ok', false, 'reason', 'not_yours');
  end if;
  if split_part(p_path, '/', 1) <> p_post then
    return jsonb_build_object('ok', false, 'reason', 'bad_path');
  end if;
  if (select count(*) from public.community_media where post_id = p_post) >= 4 then
    return jsonb_build_object('ok', false, 'reason', 'too_many');
  end if;
  insert into public.community_media (id, post_id, path, position)
  values (p_path, p_post, p_path, greatest(0, least(3, coalesce(p_position, 0))))
  on conflict (path) do nothing;
  return jsonb_build_object('ok', true, 'status', 'pending');
end $$;

create or replace function public.community_comment(
  p_id text, p_post text, p_parent text, p_identity text, p_body text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  gate text := public.community_gate();
  p public.community_posts;
  parent text := p_parent;
  verdict text;
  fname text;
  st text := 'live';
begin
  if exists (select 1 from public.community_comments where id = p_id and user_id = me) then
    return jsonb_build_object('ok', true, 'status',
      (select status from public.community_comments where id = p_id));
  end if;
  if gate is not null then return jsonb_build_object('ok', false, 'reason', gate); end if;
  select * into p from public.community_posts where id = p_post;
  if not found or not public.community_can_see(p) or p.status <> 'live' then
    return jsonb_build_object('ok', false, 'reason', 'gone');
  end if;
  if char_length(trim(coalesce(p_body, ''))) < 1 then
    return jsonb_build_object('ok', false, 'reason', 'too_short');
  end if;
  if (select count(*) from public.community_comments where user_id = me and created_at > now() - interval '10 minutes') >= 15 then
    return jsonb_build_object('ok', false, 'reason', 'rate');
  end if;
  -- Replies are one level deep: a reply to a reply joins its thread.
  if parent is not null then
    select coalesce(c.parent_id, c.id) into parent from public.community_comments c
     where c.id = p_parent and c.post_id = p_post;
  end if;
  if p_identity = 'named' then
    fname := public.community_first_name();
    if fname is null then return jsonb_build_object('ok', false, 'reason', 'no_name'); end if;
  end if;
  verdict := public.community_check_text(p_body);
  if verdict like 'hold:%' then st := 'held'; end if;
  insert into public.community_comments (id, post_id, parent_id, user_id, identity, author_label,
                                         body, status, hold_reason, crisis)
  values (p_id, p_post, parent, me, case when p_identity = 'named' then 'named' else 'anon' end,
          coalesce(fname, ''), trim(p_body), st, case when st = 'held' then substr(verdict, 6) end,
          coalesce(verdict = 'crisis', false));
  return jsonb_build_object('ok', true, 'status', st, 'crisis', coalesce(verdict = 'crisis', false));
end $$;

create or replace function public.community_react(p_kind text, p_id text, p_on boolean)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare n int;
begin
  if auth.uid() is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  if p_kind not in ('post', 'comment') then return jsonb_build_object('ok', false, 'reason', 'invalid'); end if;
  if p_on then
    insert into public.community_reactions (user_id, target_kind, target_id)
    values (auth.uid(), p_kind, p_id) on conflict do nothing;
  else
    delete from public.community_reactions
     where user_id = auth.uid() and target_kind = p_kind and target_id = p_id;
  end if;
  if p_kind = 'post' then select like_count into n from public.community_posts where id = p_id;
  else select like_count into n from public.community_comments where id = p_id; end if;
  return jsonb_build_object('ok', true, 'count', coalesce(n, 0));
end $$;

create or replace function public.community_vote(p_post text, p_option int)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare p public.community_posts;
begin
  if auth.uid() is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  select * into p from public.community_posts where id = p_post;
  if not found or p.kind <> 'poll' or not public.community_can_see(p) then
    return jsonb_build_object('ok', false, 'reason', 'gone');
  end if;
  if p.poll_closes_at < now() then return jsonb_build_object('ok', false, 'reason', 'closed'); end if;
  if p_option < 0 or p_option >= jsonb_array_length(p.poll_options) then
    return jsonb_build_object('ok', false, 'reason', 'invalid');
  end if;
  insert into public.community_poll_votes (post_id, user_id, option_idx)
  values (p_post, auth.uid(), p_option) on conflict (post_id, user_id) do nothing;
  return jsonb_build_object('ok', true, 'post', public.community_post_json(
    (select x from public.community_posts x where x.id = p_post)));
end $$;

-- A report hides the thing for the reporter at once. Three different
-- reporters hide it for everyone until a moderator decides.
create or replace function public.community_report(p_kind text, p_id text, p_reason text, p_note text default '')
returns jsonb language plpgsql security definer set search_path = '' as $$
declare n int;
begin
  if auth.uid() is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  if p_kind not in ('post', 'comment') then return jsonb_build_object('ok', false, 'reason', 'invalid'); end if;
  insert into public.community_reports (reporter, target_kind, target_id, reason, note)
  values (auth.uid(), p_kind, p_id,
          case when p_reason in ('harassment', 'explicit', 'misinformation', 'spam', 'at_risk') then p_reason else 'other' end,
          left(coalesce(p_note, ''), 500))
  on conflict (reporter, target_kind, target_id) do nothing;
  select count(*) into n from public.community_reports
   where target_kind = p_kind and target_id = p_id and resolved_at is null;
  if p_kind = 'post' then
    insert into public.community_hidden (user_id, post_id)
    select auth.uid(), p_id where exists (select 1 from public.community_posts where id = p_id)
    on conflict do nothing;
    update public.community_posts set report_count = n,
      status = case when n >= 3 and status = 'live' then 'hidden' else status end,
      crisis = crisis or p_reason = 'at_risk'
     where id = p_id;
  else
    update public.community_comments set report_count = n,
      status = case when n >= 3 and status = 'live' then 'hidden' else status end,
      crisis = crisis or p_reason = 'at_risk'
     where id = p_id;
  end if;
  return jsonb_build_object('ok', true);
end $$;

create or replace function public.community_hide(p_post text)
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  insert into public.community_hidden (user_id, post_id)
  select auth.uid(), p_post where exists (select 1 from public.community_posts where id = p_post)
  on conflict do nothing;
  return jsonb_build_object('ok', true);
end $$;

-- Block the author of a post or comment. She never sees whose account it is.
create or replace function public.community_block(p_kind text, p_id text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare who uuid; idn text; lbl text;
begin
  if auth.uid() is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  if p_kind = 'post' then
    select user_id, identity, author_label into who, idn, lbl from public.community_posts where id = p_id;
  else
    select user_id, identity, author_label into who, idn, lbl from public.community_comments where id = p_id;
  end if;
  if who is null then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;
  if who = auth.uid() then return jsonb_build_object('ok', false, 'reason', 'self'); end if;
  insert into public.community_blocks (blocker, blocked, label)
  values (auth.uid(), who, public.community_author(idn, who, lbl)->>'label')
  on conflict (blocker, blocked) do nothing;
  return jsonb_build_object('ok', true);
end $$;

create or replace function public.community_blocked_list()
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', id, 'label', label, 'created_at', created_at)
                            order by created_at desc), '[]'::jsonb)
    from public.community_blocks where blocker = auth.uid()
$$;

create or replace function public.community_unblock(p_block uuid)
returns jsonb language sql security definer set search_path = '' as $$
  delete from public.community_blocks where id = p_block and blocker = auth.uid();
  select jsonb_build_object('ok', true);
$$;

create or replace function public.community_delete(p_kind text, p_id text)
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  if p_kind = 'post' then
    update public.community_posts set deleted_at = now() where id = p_id and user_id = auth.uid();
  else
    update public.community_comments set deleted_at = now() where id = p_id and user_id = auth.uid();
  end if;
  return jsonb_build_object('ok', found);
end $$;

-- ---------------------------------------------------------------------------
--  Moderation. Every function checks the moderators list itself.
-- ---------------------------------------------------------------------------

-- p_queue: 'crisis' | 'reported' | 'held' | 'photos'. Returns the counts too.
create or replace function public.community_mod_queue(p_queue text default 'crisis')
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare items jsonb;
begin
  if not public.community_is_mod() then return null; end if;
  select coalesce(jsonb_agg(x order by (x->>'created_at')), '[]'::jsonb) into items from (
    -- posts
    select jsonb_build_object(
      'kind', 'post', 'id', p.id, 'post_id', p.id, 'room_title', r.title,
      'author', jsonb_build_object('label', public.community_author(p.identity, p.user_id, p.author_label)->>'label',
                                   'anon', p.identity = 'anon'),
      'title', p.title, 'body', p.body, 'status', p.status, 'hold_reason', p.hold_reason,
      'crisis', p.crisis, 'report_count', p.report_count,
      'reasons', (select coalesce(jsonb_agg(distinct rp.reason), '[]'::jsonb) from public.community_reports rp
                   where rp.target_kind = 'post' and rp.target_id = p.id and rp.resolved_at is null),
      'media', (select coalesce(jsonb_agg(jsonb_build_object('path', m.path, 'status', m.status)), '[]'::jsonb)
                  from public.community_media m where m.post_id = p.id and (p_queue <> 'photos' or m.status = 'pending')),
      'created_at', p.created_at) x
      from public.community_posts p join public.community_rooms r on r.id = p.room_id
     where p.deleted_at is null and case p_queue
       when 'crisis'   then p.crisis and not p.crisis_handled
       when 'reported' then exists (select 1 from public.community_reports rp where rp.target_kind = 'post'
                                      and rp.target_id = p.id and rp.resolved_at is null)
       when 'held'     then p.status = 'held'
       when 'photos'   then exists (select 1 from public.community_media m where m.post_id = p.id and m.status = 'pending')
       else false end
    union all
    -- comments
    select jsonb_build_object(
      'kind', 'comment', 'id', c.id, 'post_id', c.post_id, 'room_title', r.title,
      'author', jsonb_build_object('label', public.community_author(c.identity, c.user_id, c.author_label)->>'label',
                                   'anon', c.identity = 'anon'),
      'title', 'Reply on: ' || p.title, 'body', c.body, 'status', c.status, 'hold_reason', c.hold_reason,
      'crisis', c.crisis, 'report_count', c.report_count,
      'reasons', (select coalesce(jsonb_agg(distinct rp.reason), '[]'::jsonb) from public.community_reports rp
                   where rp.target_kind = 'comment' and rp.target_id = c.id and rp.resolved_at is null),
      'media', '[]'::jsonb, 'created_at', c.created_at) x
      from public.community_comments c
      join public.community_posts p on p.id = c.post_id
      join public.community_rooms r on r.id = p.room_id
     where c.deleted_at is null and p_queue <> 'photos' and case p_queue
       when 'crisis'   then c.crisis and not c.crisis_handled
       when 'reported' then exists (select 1 from public.community_reports rp where rp.target_kind = 'comment'
                                      and rp.target_id = c.id and rp.resolved_at is null)
       when 'held'     then c.status = 'held'
       else false end
  ) t;
  return jsonb_build_object(
    'items', items,
    'counts', jsonb_build_object(
      'crisis', (select count(*) from public.community_posts where crisis and not crisis_handled and deleted_at is null)
              + (select count(*) from public.community_comments where crisis and not crisis_handled and deleted_at is null),
      'reported', (select count(distinct (target_kind, target_id)) from public.community_reports where resolved_at is null),
      'held', (select count(*) from public.community_posts where status = 'held' and deleted_at is null)
            + (select count(*) from public.community_comments where status = 'held' and deleted_at is null),
      'photos', (select count(distinct m.post_id) from public.community_media m
                   join public.community_posts p on p.id = m.post_id
                  where m.status = 'pending' and p.deleted_at is null)));
end $$;

-- p_action: 'approve' (live + reports resolved) | 'remove' | 'handled' (crisis
-- seen and acted on) | 'approve_media' | 'reject_media' | 'mute' | 'ban'.
-- A reason is required: the audit row is the point.
create or replace function public.community_mod_act(
  p_kind text, p_id text, p_action text, p_reason text, p_mute_hours int default 24)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare author uuid;
begin
  if not public.community_is_mod() then return jsonb_build_object('ok', false, 'reason', 'not_mod'); end if;
  if char_length(trim(coalesce(p_reason, ''))) < 3 then
    return jsonb_build_object('ok', false, 'reason', 'reason_required');
  end if;
  if p_kind = 'post' then select user_id into author from public.community_posts where id = p_id;
  else select user_id into author from public.community_comments where id = p_id; end if;
  if author is null then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;

  if p_action in ('approve', 'remove') then
    if p_kind = 'post' then
      update public.community_posts set status = case when p_action = 'approve' then 'live' else 'removed' end,
        hold_reason = null where id = p_id;
    else
      update public.community_comments set status = case when p_action = 'approve' then 'live' else 'removed' end,
        hold_reason = null where id = p_id;
    end if;
    update public.community_reports set resolved_at = now(), resolution = p_action
     where target_kind = p_kind and target_id = p_id and resolved_at is null;
  elsif p_action = 'handled' then
    if p_kind = 'post' then update public.community_posts set crisis_handled = true where id = p_id;
    else update public.community_comments set crisis_handled = true where id = p_id; end if;
  elsif p_action in ('approve_media', 'reject_media') then
    update public.community_media set status = case when p_action = 'approve_media' then 'approved' else 'rejected' end
     where post_id = p_id and status = 'pending';
  elsif p_action = 'mute' then
    update public.community_profiles
       set muted_until = now() + make_interval(hours => greatest(1, least(24 * 30, coalesce(p_mute_hours, 24))))
     where user_id = author;
  elsif p_action = 'ban' then
    update public.community_profiles set banned_at = now() where user_id = author;
  else
    return jsonb_build_object('ok', false, 'reason', 'invalid');
  end if;

  insert into public.community_mod_actions (actor, action, target_kind, target_id, reason)
  values (auth.uid(), p_action, p_kind, p_id, trim(p_reason));
  return jsonb_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------------
--  Who may call what
-- ---------------------------------------------------------------------------

revoke all on function
  public.community_me(), public.community_join(text, int), public.community_mark_seen(),
  public.community_rooms_list(), public.community_set_room(text, boolean, boolean),
  public.community_feed(text, text, text, text, text[], int, int), public.community_post(text),
  public.community_comments_list(text, text), public.community_activity(int),
  public.community_face(text, text),
  public.community_create_post(text, text, text, text, text, jsonb, int),
  public.community_add_media(text, text, int),
  public.community_comment(text, text, text, text, text),
  public.community_react(text, text, boolean), public.community_vote(text, int),
  public.community_report(text, text, text, text), public.community_hide(text),
  public.community_block(text, text), public.community_blocked_list(), public.community_unblock(uuid),
  public.community_delete(text, text),
  public.community_mod_queue(text), public.community_mod_act(text, text, text, text, int)
  from public, anon;

grant execute on function
  public.community_me(), public.community_join(text, int), public.community_mark_seen(),
  public.community_rooms_list(), public.community_set_room(text, boolean, boolean),
  public.community_feed(text, text, text, text, text[], int, int), public.community_post(text),
  public.community_comments_list(text, text), public.community_activity(int),
  public.community_face(text, text),
  public.community_create_post(text, text, text, text, text, jsonb, int),
  public.community_add_media(text, text, int),
  public.community_comment(text, text, text, text, text),
  public.community_react(text, text, boolean), public.community_vote(text, int),
  public.community_report(text, text, text, text), public.community_hide(text),
  public.community_block(text, text), public.community_blocked_list(), public.community_unblock(uuid),
  public.community_delete(text, text),
  public.community_mod_queue(text), public.community_mod_act(text, text, text, text, int)
  to authenticated;

-- ---------------------------------------------------------------------------
--  The rooms. Ids that existed in the prototype keep their ids, so the room
--  links already sitting in doors and reads (`pp_community/potty`,
--  `pp_community/mothers_4th_trimester`) land in the right room. Each room
--  draws its own mark from the app's drawn family; none is shared.
-- ---------------------------------------------------------------------------

insert into public.community_rooms (id, title, blurb, stage_tag, mark, hue, sort) values
  ('ttc_naturally',        'Trying to conceive',          'Month one or month twenty. Company for the trying, and no "just relax".',                 'trying',    'tab:sprout',        104, 10),
  ('ttc_two_week_wait',    'The two-week wait',           'Counting days, testing early, and keeping each other company until the test.',            'trying',    'tab:clock',         262, 11),
  ('ttc_pcos',             'PCOS and trying',             'Cycles that do not follow the book, and what actually helped.',                            'trying',    'tool:cycle',        330, 12),
  ('ttc_ivf',              'IVF and IUI',                 'Injections, transfers, waiting rooms and the costs nobody quotes upfront.',               'trying',    'tab:vialReport',    206, 13),
  ('ttc_loss',             'After a loss',                'A quiet room, held gently. No timelines and no advice unless it is asked for.',           'trying',    'tab:cloudRain',     220, 14),
  ('ttc_emotional',        'On the hard days',            'For the days that are simply heavy, and the family questions that make them heavier.',    'trying',    'tab:heartHand',     344, 15),
  ('preg_first_trimester', 'First trimester',             'Nausea, tiredness, the first scan and all the waiting.',                                   'pregnancy', 'tab:sunrise',        26, 20),
  ('second_tri',           'Second trimester',            'The bump shows, the energy returns, and the anomaly scan arrives.',                        'pregnancy', 'tab:tulip',         344, 21),
  ('preg_third_trimester', 'Third trimester',             'Hospital bags, sleepless nights and the countdown.',                                       'pregnancy', 'tool:hospitalBag',  262, 22),
  ('high_risk',            'High-risk pregnancy',         'BP, sugar, twins, bed rest. Living with more scans and more worry.',                       'pregnancy', 'tab:doctorChat',    206, 23),
  ('preg_nutrition',       'Food, nausea and cravings',   'What you can keep down, what you crave, and Indian kitchens that help.',                  'pregnancy', 'tab:bowl',           42, 24),
  ('working_moms',         'Working while pregnant',      'Telling your manager, commutes, leave and the tiredness at the desk.',                    'pregnancy', 'tab:checklist',     104, 25),
  ('mothers_4th_trimester','The fourth trimester',        'Recovery, visitors and the first six weeks, for the part nobody in the house asks about.','parenting', 'tab:lotus',         344, 30),
  ('feeding',              'Breast and bottle',           'Latching, supply, formula and combination feeding. No judgement here.',                   'parenting', 'tab:hotBottle',      26, 31),
  ('baby_sleep',           'Baby sleep',                  'Naps, nights and regressions, with gentle, no-judgement support.',                        'parenting', 'tab:windowRing',    262, 32),
  ('first_foods',          'Starting solids',             'First foods, weaning and fussy eating.',                                                   'parenting', 'tab:jarLeaf',        42, 33),
  ('milestones',           'Milestones and development',  'Rolling, sitting, crawling, talking. Celebrate, compare notes, ask early.',               'parenting', 'tab:flagPath',      104, 34),
  ('toddlers',             'Toddler days',                'Tantrums, big feelings and tiny triumphs, from one to three.',                            'parenting', 'tab:windingPath',   206, 35),
  ('potty',                'Potty training',              'When to start, what worked, and surviving the accidents.',                                 'parenting', 'tab:bigSmallHearts', 330, 36),
  ('working_parents',      'Back to work',                'Daycare, help at home, pumping at the office and the guilt that comes along.',            'parenting', 'tab:twoFigures',    220, 37),
  ('anything',             'Anything on your mind',       'For whatever does not fit a room. Every stage welcome.',                                   'all',       'tab:twoBubbles',    300, 90)
on conflict (id) do update set
  title = excluded.title, blurb = excluded.blurb, stage_tag = excluded.stage_tag,
  mark = excluded.mark, hue = excluded.hue, sort = excluded.sort;
