-- 0137_community_phase2.sql — Community phase 2 on the learning model (2026-10-30)
--
-- Plan: C:\Users\sarth\.claude\plans\l4-plan.md (approved 2026-10-30), which
-- executes sparkling-floating-seahorse.md with Part B's amendments. Decisions
-- D1-D4 are recorded there and in docs/COMMUNITY.md "As built (phase 2)".
--
-- What this file adds, in one run:
--   1. A discussion per offering RUN (LA-20): room `run_<run id>`, opened by
--      has_course_access(programme, 'thread', run). Posts can be tagged
--      "about" a lesson or a session.
--   2. Hosts (route A experts) read, post with their badge and pin (L.5).
--      Remove and mute stay with moderators.
--   3. "Post as ParentVeda team" + pin, in any room including an offering
--      room (L.6, B3).
--   4. A timetable change writes a pinned team notice in that run's room,
--      from the server, automatically (LA-22, D1). Push is phase 3.
--   5. The doctor's "Your offerings" list, read from the server (LA-21).
--   6. Experts: badge, endorsement, "ask an expert to look", a claimable queue.
--   7. Birth clubs, following, search, edit-within-15-minutes, Over-35 room.
--      The app half of 7 is L4b; the server half is here so the user runs
--      ONE file (D4).
--
-- ⚠️ THE 0121 RULES STILL HOLD, AND EVERY NEW TABLE FOLLOWS THEM: no table
-- rights for the app's roles, RLS on with no policies, every read and write
-- a security-definer function, and nothing returned ever carries a user id.
-- test/community_anonymity_test.dart reads every community migration.
--
-- Every replaced function copies its LAST definition forward first, then
-- changes it. The last definitions: every community function — 0121;
-- has_course_access and _mirror_session — 0126 (checked: 0128, 0135 and 0136
-- do not redefine them).
--
-- Two signatures change: community_feed and community_create_post gain
-- defaulted arguments at the END. `create or replace` with a different
-- argument list does NOT replace — it adds a second overload, and a call
-- that names only the old arguments then matches both and fails as
-- ambiguous. So each old signature is DROPPED explicitly first. Phones
-- already installed keep working: they name only the old arguments, and the
-- new function's defaults fill the rest.

-- ---------------------------------------------------------------------------
--  1. Tables
-- ---------------------------------------------------------------------------

-- A room can belong to a programme's run. Nullable: the open rooms do not.
alter table public.community_rooms
  add column if not exists programme_id text,
  add column if not exists run_id       text;
create unique index if not exists community_rooms_offering
  on public.community_rooms (programme_id, coalesce(run_id, ''))
  where kind = 'offering';

-- 'auto' = the app put her there (her birth club, her course's run room);
-- 'self' = she chose it. An automatic membership can be undone by the next
-- automatic decision without touching a room she joined herself.
alter table public.community_room_members
  add column if not exists via text not null default 'self';
alter table public.community_room_members
  drop constraint if exists community_room_members_via_check;
alter table public.community_room_members
  add constraint community_room_members_via_check check (via in ('self', 'auto'));

alter table public.community_posts
  add column if not exists edited_at    timestamptz,
  add column if not exists pinned_until timestamptz,
  add column if not exists about_kind   text,
  add column if not exists about_id     text,
  -- Set only on a server-written timetable notice: the time the session
  -- had before it moved, so the app can say "Moved from …" without parsing
  -- prose.
  add column if not exists moved_from   timestamptz;
alter table public.community_posts drop constraint if exists community_posts_about_check;
alter table public.community_posts add constraint community_posts_about_check
  check ((about_kind is null and about_id is null)
      or (about_kind in ('lesson', 'session') and char_length(about_id) between 1 and 80));

-- Search. A STORED generated column is computed by Postgres on every write,
-- so it can never drift from the text it indexes; nothing in the app or a
-- trigger has to remember to update it. The cost is one table rewrite now
-- (cheap at launch size) and a little more disk per row.
alter table public.community_posts
  add column if not exists search tsvector
  generated always as (to_tsvector('english'::regconfig,
                                   coalesce(title, '') || ' ' || coalesce(body, ''))) stored;
create index if not exists community_posts_search on public.community_posts using gin (search);
create index if not exists community_posts_pinned on public.community_posts (room_id, pinned_until)
  where pinned_until is not null;

-- 'team' = "ParentVeda team". The column constraint 0121 wrote inline is
-- named <table>_<column>_check by Postgres.
alter table public.community_posts drop constraint if exists community_posts_identity_check;
alter table public.community_posts add constraint community_posts_identity_check
  check (identity in ('anon', 'named', 'team'));

-- A notice the SERVER writes (a session moved) has no person behind it.
-- Only a team post may have no author; a member's post always has one.
alter table public.community_posts alter column user_id drop not null;
alter table public.community_posts drop constraint if exists community_posts_team_author;
alter table public.community_posts add constraint community_posts_team_author
  check (user_id is not null or identity = 'team');

-- An expert found a reply helpful. One per expert per reply.
create table if not exists public.community_endorsements (
  target_kind  text        not null check (target_kind in ('post', 'comment')),
  target_id    text        not null,
  expert_id    text        not null,
  user_id      uuid        not null references auth.users (id) on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (target_kind, target_id, expert_id)
);

-- She follows a #tag, or one FACE of a member (never both faces: following
-- a community name must not reveal the first name behind it). The label is
-- stored as she saw it, like community_blocks, so her list can name people
-- without a join. The person followed is never told; no counts anywhere.
create table if not exists public.community_follows (
  id          uuid        primary key default gen_random_uuid(),
  follower    uuid        not null references auth.users (id) on delete cascade,
  kind        text        not null check (kind in ('tag', 'member')),
  tag         text        check (tag is null or tag ~ '^[a-z][a-z0-9_]{1,30}$'),
  followee    uuid        references auth.users (id) on delete cascade,
  face        text        check (face is null or face in ('anon', 'named')),
  label       text        not null default '',
  created_at  timestamptz not null default now(),
  check ((kind = 'tag' and tag is not null and followee is null)
      or (kind = 'member' and followee is not null and face is not null and tag is null))
);
create unique index if not exists community_follows_tag
  on public.community_follows (follower, tag) where kind = 'tag';
create unique index if not exists community_follows_member
  on public.community_follows (follower, followee, face) where kind = 'member';

-- "Ask an expert to look." One per post. reason keeps 'crisis' allowed so
-- widening W20 later is one trigger and no table change (the user decided
-- 2026-10-28: crisis stays with moderators for now).
create table if not exists public.community_expert_requests (
  post_id         text        primary key references public.community_posts (id) on delete cascade,
  asked_by        uuid        references auth.users (id) on delete set null,
  reason          text        not null default 'asked' check (reason in ('asked', 'crisis')),
  claimed_expert  text,
  claimed_at      timestamptz,
  answered_at     timestamptz,
  created_at      timestamptz not null default now()
);

-- Unread, as a high-water mark: one row per person per room, "she last
-- looked at this room at T". Unread = posts after T. The trade-off: we can
-- count what is new but not say WHICH post she has read; a per-post read
-- table could, at one row per person per post. A count is all we show.
create table if not exists public.community_room_seen (
  user_id  uuid        not null references auth.users (id) on delete cascade,
  room_id  text        not null references public.community_rooms (id) on delete cascade,
  seen_at  timestamptz not null default now(),
  primary key (user_id, room_id)
);

alter table public.community_endorsements    enable row level security;
alter table public.community_follows         enable row level security;
alter table public.community_expert_requests enable row level security;
alter table public.community_room_seen       enable row level security;

revoke all on public.community_endorsements, public.community_follows,
  public.community_expert_requests, public.community_room_seen
  from anon, authenticated;

-- ---------------------------------------------------------------------------
--  2. The access rule, widened (copied from 0126, then changed)
--
--  thread now also opens for:
--   · a moderator (L.4) — moderators must be able to read what they moderate;
--   · a non-cancelled booking on a slot of that run (D3): a seat bought with
--     a sponsor's or a pack's credit is a receipt by another name;
--   · a host, but ROUTE A only (an expert_accounts row whose profile is
--     published) — the same rule as the badge. my_expert_ids() also returns
--     every id an organisation login manages, so a hospital login would
--     enter forty course rooms. Recordings keep my_expert_ids() unchanged.
-- ---------------------------------------------------------------------------

create or replace function public.has_course_access(
  p_programme_id text,
  p_what         text,
  p_run_id       text default null
) returns boolean
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_uid  uuid := auth.uid();
  v_live boolean := public.payment_mode() = 'live';
  v_kind text;
  v_off  text;
begin
  if v_uid is null or p_programme_id is null then return false; end if;
  select p.kind, p.offering_id into v_kind, v_off
    from public.programmes p where p.id = p_programme_id;
  if v_kind is null then return false; end if;

  if p_what = 'recording' and exists (
    select 1 from public.programme_experts pe
     where pe.programme_id = p_programme_id and pe.status = 'accepted'
       and pe.expert_id in (select public.my_expert_ids())
  ) then
    return true;
  end if;

  -- (0137) The discussion: moderators, route A hosts, and a booked seat.
  if p_what = 'thread' then
    if public.community_is_mod() then return true; end if;
    if exists (
      select 1 from public.programme_experts pe
        join public.expert_accounts ea on ea.expert_id = pe.expert_id and ea.user_id = v_uid
        join public.expert_profiles ep on ep.expert_id = pe.expert_id and ep.status = 'published'
       where pe.programme_id = p_programme_id and pe.status = 'accepted'
    ) then
      return true;
    end if;
    if exists (
      select 1 from public.booking_bookings b
        join public.programme_sessions s on b.slot_id = 'ps_' || s.id
       where b.user_id = v_uid and b.status <> 'cancelled'
         and s.programme_id = p_programme_id
         and (p_run_id is null or s.run_id = p_run_id)
         and case b.paid_by
               when 'credit' then exists (
                 select 1 from public.consult_credits c
                  where c.booking_id = b.id
                    and (not v_live or c.source <> 'stub_purchase'))
               when 'free' then true
               -- 'purchase' is answered by the receipt check below, so a
               -- refunded receipt closes the room even if the booking row
               -- has not been cancelled yet.
               when 'purchase' then false
               else not v_live
             end
    ) then
      return true;
    end if;
  end if;

  if p_what = 'seat' and v_kind = 'class_pack' then
    return exists (
      select 1 from public.consult_credits c
       where c.user_id = v_uid and c.offering_scope = v_off
         and c.booking_id is null and c.voided_at is null
         and (c.expires_at is null or c.expires_at > now())
         and (not v_live or c.source <> 'stub_purchase'));
  end if;

  return exists (
    select 1 from public.course_purchases cp
     where cp.user_id = v_uid
       and cp.programme_id = p_programme_id
       and cp.status = 'active'
       and (not v_live or cp.mode = 'live')
       and (p_what = 'recording'
            or p_run_id is null or cp.run_id is null or cp.run_id = p_run_id));
end;
$$;

revoke all on function public.has_course_access(text, text, text) from public, anon, authenticated;
grant execute on function public.has_course_access(text, text, text) to authenticated;

-- ---------------------------------------------------------------------------
--  3. Internal helpers (not callable by the app)
-- ---------------------------------------------------------------------------

-- The expert behind a person, or null. Route A + published only: the badge
-- must never land on an organisation login or an unpublished profile.
create or replace function public.community_expert_of(p_user uuid)
returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('name', ep.name, 'category', ep.category, 'photo', ep.photo_url)
    from public.expert_accounts ea
    join public.expert_profiles ep on ep.expert_id = ea.expert_id
   where p_user is not null and ea.user_id = p_user and ep.status = 'published'
   limit 1
$$;

-- The caller's own expert id (route A + published), or null.
create or replace function public.community_my_expert_id()
returns text language sql stable security definer set search_path = '' as $$
  select ea.expert_id
    from public.expert_accounts ea
    join public.expert_profiles ep on ep.expert_id = ea.expert_id
   where ea.user_id = auth.uid() and ep.status = 'published'
   limit 1
$$;

-- A person's role ('host' | 'co_host' | 'moderator') in an offering room's
-- programme, or null. Route A only, like the badge.
create or replace function public.community_host_role(p_room text, p_user uuid)
returns text language sql stable security definer set search_path = '' as $$
  select pe.role
    from public.community_rooms r
    join public.programme_experts pe on pe.programme_id = r.programme_id and pe.status = 'accepted'
    join public.expert_accounts ea on ea.expert_id = pe.expert_id
    join public.expert_profiles ep on ep.expert_id = pe.expert_id and ep.status = 'published'
   where p_user is not null and r.id = p_room and r.kind = 'offering' and ea.user_id = p_user
   order by (pe.role = 'host') desc
   limit 1
$$;

create or replace function public.community_is_host(p_room text)
returns boolean language sql stable security definer set search_path = '' as $$
  select public.community_host_role(p_room, auth.uid()) is not null
$$;

-- May the caller enter this room at all?
--   offering   → the access rule (receipt, booked seat, host, moderator);
--   birth club → only her own (a member), or a moderator;
--   any other  → yes.
create or replace function public.community_room_access(p_room text)
returns boolean language sql stable security definer set search_path = '' as $$
  select coalesce((
    select case r.kind
      when 'offering' then r.programme_id is not null
                       and public.has_course_access(r.programme_id, 'thread', r.run_id)
      when 'birth_club' then public.community_is_mod() or exists (
                         select 1 from public.community_room_members m
                          where m.room_id = r.id and m.user_id = auth.uid())
      else true
    end
      from public.community_rooms r where r.id = p_room), false)
$$;

-- Posts in a room she has not seen: after her high-water mark, else after
-- she joined; a room she never joined or opened has nothing "new".
create or replace function public.community_room_unread(p_room text)
returns int language sql stable security definer set search_path = '' as $$
  select count(*)::int from public.community_posts p
   where p.room_id = p_room and p.status = 'live' and p.deleted_at is null
     and p.user_id is distinct from auth.uid()
     and p.created_at > coalesce(
           (select s.seen_at from public.community_room_seen s
             where s.user_id = auth.uid() and s.room_id = p_room),
           (select m.joined_at from public.community_room_members m
             where m.user_id = auth.uid() and m.room_id = p_room),
           now())
     and not coalesce(public.community_blocked_between(auth.uid(), p.user_id), false)
$$;

-- The room id for a programme's run. A run-less programme gets one room.
create or replace function public.community_offering_room_id(p_programme text, p_run text)
returns text language sql immutable set search_path = '' as $$
  select case when p_run is null then 'prog_' || p_programme else 'run_' || p_run end
$$;

-- Creates the run's room if it is missing; returns its id. Title = the
-- programme; blurb = the run's label ("Batch 2"), shown quietly.
create or replace function public._community_ensure_offering_room(p_programme text, p_run text)
returns text language plpgsql security definer set search_path = '' as $$
declare
  v_id text := public.community_offering_room_id(p_programme, p_run);
  p public.programmes;
  v_label text;
begin
  if exists (select 1 from public.community_rooms where id = v_id) then return v_id; end if;
  select * into p from public.programmes where id = p_programme;
  if p.id is null then return null; end if;
  select label into v_label from public.programme_runs where id = p_run;
  insert into public.community_rooms (id, title, blurb, stage_tag, kind, offering_id,
                                      programme_id, run_id, mark, hue, sort)
  values (v_id, left(p.title, 120), coalesce(v_label, ''),
          case when p.stage in ('trying', 'pregnancy', 'parenting') then p.stage else 'all' end,
          'offering', p.offering_id, p.id, p_run, 'tab:openBook', 210, 500)
  on conflict (id) do nothing;
  return v_id;
end $$;

revoke all on function public.community_expert_of(uuid), public.community_my_expert_id(),
  public.community_host_role(text, uuid), public.community_is_host(text),
  public.community_room_access(text), public.community_room_unread(text),
  public.community_offering_room_id(text, text), public._community_ensure_offering_room(text, text)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------------
--  4. Replaced helpers (copied from 0121, then changed)
-- ---------------------------------------------------------------------------

-- The author as the app may see it. Never the user id.
--   team  → "ParentVeda team", the app's own mark. Never a person's name.
--   anon  → her community name. No badge: a badge on an anonymous post
--           would unmask one of a handful of experts.
--   named → her first name; `moderator` (D2: a "Moderator" chip, replacing
--           phase 1's "label · ParentVeda team") and `expert` (the badge).
-- `is_mine` is null-safe: a server notice has no author.
create or replace function public.community_author(
  p_identity text, p_user uuid, p_label text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select case when p_identity = 'team' then jsonb_build_object(
      'label', 'ParentVeda team', 'anon', false, 'seed', 0, 'team', true,
      'moderator', false,
      'is_mine', coalesce(p_user = auth.uid(), false))
    when p_identity = 'anon' then jsonb_build_object(
      'label', coalesce((select pseudonym from public.community_profiles where user_id = p_user), 'A member'),
      'anon', true,
      'seed', coalesce((select avatar_seed from public.community_profiles where user_id = p_user), 0),
      'team', false,
      'moderator', false,
      'is_mine', coalesce(p_user = auth.uid(), false))
    else jsonb_build_object(
      'label', p_label, 'anon', false, 'seed', 0, 'team', false,
      'moderator', exists (select 1 from public.community_moderators m where m.user_id = p_user),
      'expert', public.community_expert_of(p_user),
      'is_mine', coalesce(p_user = auth.uid(), false))
  end
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
    'room_kind', r.kind,
    'author', public.community_author(p.identity, p.user_id, p.author_label),
    -- (0137) a host's role in this course, on named posts only.
    'host_role', case when p.identity = 'named' then public.community_host_role(p.room_id, p.user_id) end,
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
    'status', case when coalesce(p.user_id = me, false) then p.status else 'live' end,
    'edited_at', p.edited_at,
    'pinned', coalesce(p.pinned_until > now(), false),
    'pinned_until', p.pinned_until,
    'about', case when p.about_kind is null then null
                  else jsonb_build_object('kind', p.about_kind, 'id', p.about_id) end,
    'moved_from', p.moved_from,
    'expert_asked', exists (select 1 from public.community_expert_requests e where e.post_id = p.id),
    'expert_answered', exists (select 1 from public.community_expert_requests e
                                where e.post_id = p.id and e.answered_at is not null),
    'created_at', p.created_at);
end $$;

-- May the caller see this post? The room first (this one line makes the
-- course and club privacy hold in EVERY read: feed, post, comments, face,
-- search, activity), then: live, not deleted, not hidden by her, no block
-- either way — or it is her own.
create or replace function public.community_can_see(p public.community_posts)
returns boolean language sql stable security definer set search_path = '' as $$
  select p.deleted_at is null
    and public.community_room_access(p.room_id)
    and (coalesce(p.user_id = auth.uid(), false) or (
      p.status = 'live'
      and not exists (select 1 from public.community_hidden h where h.user_id = auth.uid() and h.post_id = p.id)
      and not coalesce(public.community_blocked_between(auth.uid(), p.user_id), false)))
$$;

-- May she see this photo? (copied from 0122). (0137) Also the room: a
-- photo in a course room is for that batch, like the post it sits on.
create or replace function public.community_media_readable(p_name text)
returns boolean language sql stable security definer set search_path = '' as $$
  select public.community_is_mod() or exists (
    select 1 from public.community_media m
      join public.community_posts p on p.id = m.post_id
     where m.path = p_name and p.deleted_at is null
       and public.community_room_access(p.room_id)
       and (p.user_id = auth.uid()
            or (m.status = 'approved' and p.status = 'live'
                and not public.community_blocked_between(auth.uid(), p.user_id))))
$$;

-- ---------------------------------------------------------------------------
--  5. Her standing (copied from 0121; adds expert)
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
    'expert', public.community_expert_of(me),
    'unread', unread);
end $$;

-- ---------------------------------------------------------------------------
--  6. Rooms
-- ---------------------------------------------------------------------------

-- Open rooms, her own birth club, and the course rooms she is in.
-- Other months' clubs are not listed (decision 13).
create or replace function public.community_rooms_list()
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object(
      'id', r.id, 'title', r.title, 'blurb', r.blurb, 'stage', r.stage_tag,
      'kind', r.kind, 'mark', r.mark, 'hue', r.hue, 'sort', r.sort,
      'programme_id', r.programme_id, 'run_id', r.run_id,
      'members', (select count(*) from public.community_room_members x where x.room_id = r.id),
      'joined', m.user_id is not null,
      'via', m.via,
      'muted', coalesce(m.muted, false),
      'access', true,
      'unread', case when m.user_id is null then 0 else public.community_room_unread(r.id) end)
      order by r.sort, r.title), '[]'::jsonb)
    from public.community_rooms r
    left join public.community_room_members m on m.room_id = r.id and m.user_id = auth.uid()
   where r.is_open and (r.kind = 'room'
          or (r.kind = 'birth_club' and m.user_id is not null)
          or (r.kind = 'offering' and m.user_id is not null and public.community_room_access(r.id)))
$$;

-- Join, leave or mute. An offering room is entered by a seat, never by
-- Join. A birth club can be (re)joined only by a member — that is "Stay"
-- on the after-a-loss sheet, which turns 'auto' into her own choice.
create or replace function public.community_set_room(p_room text, p_join boolean, p_mute boolean default false)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare r public.community_rooms;
begin
  if auth.uid() is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  select * into r from public.community_rooms where id = p_room and is_open;
  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_room');
  end if;
  if p_join and r.kind = 'offering' then
    return jsonb_build_object('ok', false, 'reason', 'offering');
  end if;
  if p_join and r.kind = 'birth_club' and not exists (
      select 1 from public.community_room_members where user_id = auth.uid() and room_id = p_room) then
    return jsonb_build_object('ok', false, 'reason', 'no_room');
  end if;
  if p_join then
    insert into public.community_room_members (user_id, room_id, muted, via)
    values (auth.uid(), p_room, coalesce(p_mute, false), 'self')
    on conflict (user_id, room_id) do update set muted = coalesce(p_mute, false), via = 'self';
  else
    delete from public.community_room_members where user_id = auth.uid() and room_id = p_room;
  end if;
  return jsonb_build_object('ok', true);
end $$;

-- The discussion for a programme's run. Creates the room on first need and
-- answers whether she may enter.
--
-- p_run is a hint. The SERVER decides which run she belongs to (derive,
-- never ask): her receipt's run, else the run of a session she booked,
-- else the hint, else the run a new purchase would join. So a phone with a
-- stale run id still lands her in her own batch.
create or replace function public.community_offering_room(p_programme text, p_run text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_run text;
  v_room text;
  v_access boolean;
  r public.community_rooms;
  m public.community_room_members;
begin
  if me is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  if not exists (select 1 from public.programmes where id = p_programme) then
    return jsonb_build_object('ok', false, 'reason', 'no_room');
  end if;
  select cp.run_id into v_run from public.course_purchases cp
   where cp.user_id = me and cp.programme_id = p_programme and cp.status = 'active'
     and cp.run_id is not null
   order by cp.paid_at desc limit 1;
  if v_run is null then
    select s.run_id into v_run from public.booking_bookings b
      join public.programme_sessions s on b.slot_id = 'ps_' || s.id
     where b.user_id = me and b.status <> 'cancelled' and s.programme_id = p_programme
       and s.run_id is not null
     order by b.created_at desc limit 1;
  end if;
  if v_run is null and p_run is not null
     and exists (select 1 from public.programme_runs where id = p_run and programme_id = p_programme) then
    v_run := p_run;
  end if;
  if v_run is null then v_run := public._current_run(p_programme); end if;

  v_room := public._community_ensure_offering_room(p_programme, v_run);
  if v_room is null then return jsonb_build_object('ok', false, 'reason', 'no_room'); end if;
  v_access := public.community_room_access(v_room);
  if v_access then
    -- In the room from now on, so it reaches her rail and Following.
    insert into public.community_room_members (user_id, room_id, via)
    values (me, v_room, 'auto') on conflict (user_id, room_id) do nothing;
  end if;
  select * into r from public.community_rooms where id = v_room;
  select * into m from public.community_room_members where user_id = me and room_id = v_room;
  return jsonb_build_object(
    'ok', true,
    'access', v_access,
    -- Why not: 'refunded' reads "It closed with your refund"; else 'book'.
    'reason', case when v_access then null
                   when exists (select 1 from public.course_purchases cp
                                 where cp.user_id = me and cp.programme_id = p_programme
                                   and cp.status in ('refund_requested', 'refunded')) then 'refunded'
                   else 'book' end,
    'is_host', public.community_is_host(v_room),
    'is_mod', public.community_is_mod(),
    'posts', (select count(*) from public.community_posts p
               where p.room_id = v_room and p.status = 'live' and p.deleted_at is null),
    'room', jsonb_build_object(
      'id', r.id, 'title', r.title, 'blurb', r.blurb, 'stage', r.stage_tag,
      'kind', r.kind, 'mark', r.mark, 'hue', r.hue, 'sort', r.sort,
      'programme_id', r.programme_id, 'run_id', r.run_id,
      'members', (select count(*) from public.community_room_members x where x.room_id = r.id),
      'joined', m.user_id is not null, 'via', m.via, 'muted', coalesce(m.muted, false),
      'access', v_access,
      'unread', case when v_access then public.community_room_unread(r.id) else 0 end));
end $$;

-- She opened the room: move her high-water mark.
create or replace function public.community_room_seen(p_room text)
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  if not public.community_room_access(p_room) then
    return jsonb_build_object('ok', false, 'reason', 'no_access');
  end if;
  insert into public.community_room_seen (user_id, room_id, seen_at)
  values (auth.uid(), p_room, now())
  on conflict (user_id, room_id) do update set seen_at = now();
  return jsonb_build_object('ok', true);
end $$;

-- Her birth club, from the due month the PHONE knows (the server's copy of
-- a due date can lag and survives a loss; the phone already handles a
-- father and a set/unset flag). 'YYYY-MM', within -24..+10 months.
-- Joins as 'auto' and drops her OTHER 'auto' clubs — that happens only when
-- a new due month replaces an old one. A loss does not call this, so a loss
-- never removes her (the app asks her: decision 12).
create or replace function public.community_birth_club(p_month text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  d date;
  v_id text;
begin
  if me is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  if coalesce(p_month, '') !~ '^[0-9]{4}-(0[1-9]|1[0-2])$' then
    return jsonb_build_object('ok', false, 'reason', 'invalid');
  end if;
  d := to_date(p_month || '-01', 'YYYY-MM-DD');
  if d < date_trunc('month', now())::date - interval '24 months'
     or d > date_trunc('month', now())::date + interval '10 months' then
    return jsonb_build_object('ok', false, 'reason', 'invalid');
  end if;
  v_id := 'club_' || to_char(d, 'YYYY_MM');
  insert into public.community_rooms (id, title, blurb, stage_tag, kind, mark, hue, sort)
  values (v_id, to_char(d, 'FMMonth YYYY') || ' birth club',
          'Everyone due in ' || to_char(d, 'FMMonth YYYY') || '. Share your week, your month, your worries.',
          'all', 'birth_club', 'tab:twoCircles', 30, 5)
  on conflict (id) do nothing;
  insert into public.community_room_members (user_id, room_id, via)
  values (me, v_id, 'auto') on conflict (user_id, room_id) do nothing;
  delete from public.community_room_members m
   using public.community_rooms r
   where r.id = m.room_id and r.kind = 'birth_club' and m.user_id = me
     and m.via = 'auto' and m.room_id <> v_id;
  return jsonb_build_object('ok', true, 'room_id', v_id,
    'title', to_char(d, 'FMMonth YYYY') || ' birth club');
end $$;

-- ---------------------------------------------------------------------------
--  7. Reading
-- ---------------------------------------------------------------------------

drop function if exists public.community_feed(text, text, text, text, text[], int, int);

-- p_scope: 'for_you' | 'following' | 'rooms' (joined; old phones) | 'room'
--          (p_room) | 'tag' (p_tag) | 'mine' | 'ids'
-- p_sort:  'top' | 'new'. p_stage ranks her stage's rooms first.
-- p_about_kind / p_about_id: only posts about that lesson or session.
create or replace function public.community_feed(
  p_scope text default 'for_you',
  p_sort text default 'top',
  p_room text default null,
  p_stage text default null,
  p_ids text[] default null,
  p_offset int default 0,
  p_limit int default 20,
  p_tag text default null,
  p_about_kind text default null,
  p_about_id text default null)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_tag text := ltrim(lower(coalesce(p_tag, '')), '#');
  v_tags text[];
begin
  if me is null then return '[]'::jsonb; end if;
  if p_scope = 'following' then
    select coalesce(array_agg(f.tag), '{}') into v_tags
      from public.community_follows f where f.follower = me and f.kind = 'tag';
  end if;
  return coalesce((
    select jsonb_agg(public.community_post_json(q.post)
                     order by q.pin desc, q.rank desc, (q.post).created_at desc)
      from (
        select p as post,
          -- Pinned first, but only inside its own room.
          (p_scope = 'room' and coalesce(p.pinned_until > now(), false)) as pin,
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
           and (p_about_kind is null or (p.about_kind = p_about_kind and p.about_id = p_about_id))
           and case p_scope
                 when 'room'  then p.room_id = p_room
                 when 'rooms' then m.user_id is not null
                 when 'following' then coalesce(m.user_id is not null and not m.muted, false)
                   or p.hashtags && v_tags
                   or exists (select 1 from public.community_follows f
                               where f.follower = me and f.kind = 'member'
                                 and f.followee = p.user_id and f.face = p.identity)
                 when 'tag'   then v_tag <> '' and v_tag = any (p.hashtags)
                 when 'mine'  then coalesce(p.user_id = me, false)
                 when 'ids'   then p.id = any (coalesce(p_ids, '{}'))
                 -- For you: no course rooms, no other months' clubs.
                 else coalesce(m.muted, false) = false
                   and r.kind not in ('offering', 'session')
                   and (r.kind <> 'birth_club' or m.user_id is not null)
               end
         order by pin desc, rank desc, p.created_at desc
         offset greatest(0, p_offset) limit least(50, greatest(1, p_limit))
      ) q), '[]'::jsonb);
end $$;

-- Flat list; the app nests replies under parent_id. Top = most liked first,
-- and an expert's endorsement lifts a reply (it counts as five likes).
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
        'host_role', case when c.identity = 'named' then public.community_host_role(p.room_id, c.user_id) end,
        'body', c.body, 'like_count', c.like_count,
        'liked', exists (select 1 from public.community_reactions x
                          where x.user_id = me and x.target_kind = 'comment' and x.target_id = c.id),
        'endorsements', (select coalesce(jsonb_agg(jsonb_build_object('name', ep.name, 'category', ep.category)
                                                   order by e.created_at), '[]'::jsonb)
                           from public.community_endorsements e
                           join public.expert_profiles ep on ep.expert_id = e.expert_id
                          where e.target_kind = 'comment' and e.target_id = c.id),
        'endorsed', exists (select 1 from public.community_endorsements e
                             where e.target_kind = 'comment' and e.target_id = c.id and e.user_id = me),
        'status', case when c.user_id = me then c.status else 'live' end,
        'is_op', c.user_id = p.user_id and c.identity = p.identity,
        'created_at', c.created_at)
      order by case when p_sort = 'top' and c.parent_id is null then
                 c.like_count + 5 * (select count(*) from public.community_endorsements e
                                      where e.target_kind = 'comment' and e.target_id = c.id) end
               desc nulls last,
               c.created_at)
      from public.community_comments c
     where c.post_id = p_post and c.deleted_at is null
       and (c.user_id = me or (c.status = 'live' and not public.community_blocked_between(me, c.user_id)))
  ), '[]'::jsonb);
end $$;

-- One face of a member (copied from 0121). (0137) A team post has no face
-- to open: tapping "ParentVeda team" must not list one moderator's posts.
create or replace function public.community_face(p_from text default null, p_face text default 'anon')
returns jsonb language plpgsql stable security definer set search_path = '' as $$
#variable_conflict use_variable
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
    if face = 'team' then return null; end if;
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
    'following', exists (select 1 from public.community_follows f
                          where f.follower = auth.uid() and f.kind = 'member'
                            and f.followee = who and f.face = face),
    'posts', coalesce((
      select jsonb_agg(public.community_post_json(s.post) order by (s.post).created_at desc)
        from (select p as post from public.community_posts p
               where p.user_id = who and p.identity = face and public.community_can_see(p)
               order by p.created_at desc limit 30) s), '[]'::jsonb));
end $$;

-- Search: Postgres full text over live posts' title + body, ranked by text
-- rank x recency; plus rooms by title and #tags by prefix. `websearch_to_tsquery`
-- reads what people type ("baby sleep -regression", quoted phrases) and
-- never raises on odd input. Typos are not forgiven — pg_trgm can come later.
create or replace function public.community_search(p_q text, p_offset int default 0)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  q tsquery;
  t text := trim(coalesce(p_q, ''));
  v_tag text := ltrim(lower(trim(coalesce(p_q, ''))), '#');
begin
  if me is null or char_length(t) < 2 then
    return jsonb_build_object('posts', '[]'::jsonb, 'rooms', '[]'::jsonb, 'tags', '[]'::jsonb);
  end if;
  q := websearch_to_tsquery('english'::regconfig, left(t, 200));
  return jsonb_build_object(
    'posts', coalesce((
      select jsonb_agg(public.community_post_json(s.post) order by s.score desc)
        from (select p as post,
                     ts_rank(p.search, q)
                       / power(extract(epoch from (now() - p.created_at)) / 86400 + 1, 0.5) as score
                from public.community_posts p
               where p.search @@ q and public.community_can_see(p)
               order by score desc
               offset greatest(0, p_offset) limit 20) s), '[]'::jsonb),
    'rooms', case when p_offset > 0 then '[]'::jsonb else coalesce((
      select jsonb_agg(jsonb_build_object('id', r.id, 'title', r.title, 'mark', r.mark, 'hue', r.hue,
                                          'kind', r.kind) order by r.sort)
        from public.community_rooms r
       where r.is_open and r.title ilike '%' || replace(replace(t, '%', ''), '_', '') || '%'
         and (r.kind = 'room' or exists (select 1 from public.community_room_members m
                                          where m.room_id = r.id and m.user_id = me))
         and public.community_room_access(r.id)), '[]'::jsonb) end,
    'tags', case when p_offset > 0 or v_tag !~ '^[a-z][a-z0-9_]{0,30}$' then '[]'::jsonb else coalesce((
      select jsonb_agg(x.tag order by x.n desc)
        from (select h.tag, count(*) n
                from public.community_posts p, unnest(p.hashtags) h(tag)
               where h.tag like v_tag || '%' and p.status = 'live' and p.deleted_at is null
               group by h.tag order by count(*) desc limit 8) x), '[]'::jsonb) end);
end $$;

-- ---------------------------------------------------------------------------
--  8. Writing
-- ---------------------------------------------------------------------------

drop function if exists public.community_create_post(text, text, text, text, text, jsonb, int);

-- (0137) Room access is checked; a post may be "about" a lesson or a
-- session of the room's run; a verified expert's NAMED post does not need a
-- community name first (the doctor app has no join flow, and the expert
-- agreed to the partner terms), and falls back to the profile's FULL name
-- ("Dr Meera Shah" — a first-word split would print "Dr").
create or replace function public.community_create_post(
  p_id text, p_room text, p_identity text, p_title text, p_body text default '',
  p_poll_options jsonb default null, p_poll_days int default 3,
  p_about_kind text default null, p_about_id text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  gate text := public.community_gate();
  existing public.community_posts;
  r public.community_rooms;
  verdict text;
  fname text;
  st text := 'live';
  tags text[];
  opts jsonb := null;
  v_about_kind text;
  v_about_id text;
begin
  -- Idempotent: a retry of a post that already landed returns its outcome.
  select * into existing from public.community_posts where id = p_id;
  if found then
    if existing.user_id is distinct from me then return jsonb_build_object('ok', false, 'reason', 'conflict'); end if;
    return jsonb_build_object('ok', true, 'status', existing.status, 'crisis', existing.crisis);
  end if;
  if gate = 'not_joined' and p_identity = 'named' and public.community_expert_of(me) is not null then
    gate := null;
  end if;
  if gate is not null then
    return jsonb_build_object('ok', false, 'reason', gate,
      'muted_until', (select muted_until from public.community_profiles where user_id = me));
  end if;
  select * into r from public.community_rooms where id = p_room and is_open;
  if not found then
    return jsonb_build_object('ok', false, 'reason', 'no_room');
  end if;
  if not public.community_room_access(p_room) then
    return jsonb_build_object('ok', false, 'reason', 'no_access');
  end if;
  if char_length(trim(coalesce(p_title, ''))) < 4 then
    return jsonb_build_object('ok', false, 'reason', 'too_short');
  end if;
  -- Rate limit: 5 posts an hour. Real mothers never hit it; a spammer does.
  if (select count(*) from public.community_posts where user_id = me and created_at > now() - interval '1 hour') >= 5 then
    return jsonb_build_object('ok', false, 'reason', 'rate');
  end if;
  if p_identity = 'named' then
    fname := coalesce(public.community_first_name(),
                      left(public.community_expert_of(me)->>'name', 60));
    if fname is null or fname = '' then return jsonb_build_object('ok', false, 'reason', 'no_name'); end if;
  end if;
  -- About: only in a course room. A session must belong to this room's run
  -- (a slot id 'ps_<session>' is accepted too). A lesson id is an app
  -- string with no table behind it, so only its length is checked.
  if p_about_kind in ('lesson', 'session') and r.kind = 'offering'
     and char_length(coalesce(p_about_id, '')) between 1 and 80 then
    v_about_kind := p_about_kind;
    v_about_id := p_about_id;
    if p_about_kind = 'session' then
      v_about_id := regexp_replace(p_about_id, '^ps_', '');
      if not exists (select 1 from public.programme_sessions s
                      where s.id = v_about_id and s.programme_id = r.programme_id
                        and (r.run_id is null or s.run_id = r.run_id)) then
        return jsonb_build_object('ok', false, 'reason', 'invalid');
      end if;
    end if;
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
                                      kind, poll_options, poll_closes_at, hashtags, status, hold_reason, crisis,
                                      about_kind, about_id)
  values (p_id, p_room, me, case when p_identity = 'named' then 'named' else 'anon' end,
          coalesce(fname, ''), trim(p_title), trim(coalesce(p_body, '')),
          case when opts is null then 'text' else 'poll' end, opts,
          case when opts is null then null else now() + make_interval(days => greatest(1, least(7, coalesce(p_poll_days, 3)))) end,
          tags, st, case when st = 'held' then substr(verdict, 6) end, coalesce(verdict = 'crisis', false),
          v_about_kind, v_about_id);
  -- Posting in a room joins it, so its replies reach Following.
  insert into public.community_room_members (user_id, room_id, via)
  values (me, p_room, case when r.kind = 'room' then 'self' else 'auto' end)
  on conflict do nothing;
  return jsonb_build_object('ok', true, 'status', st, 'crisis', coalesce(verdict = 'crisis', false));
end $$;

-- (0137) An expert's reply marks an open "ask an expert" request answered,
-- and an expert's named reply needs no community name.
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
  if gate = 'not_joined' and p_identity = 'named' and public.community_expert_of(me) is not null then
    gate := null;
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
    fname := coalesce(public.community_first_name(),
                      left(public.community_expert_of(me)->>'name', 60));
    if fname is null or fname = '' then return jsonb_build_object('ok', false, 'reason', 'no_name'); end if;
  end if;
  verdict := public.community_check_text(p_body);
  if verdict like 'hold:%' then st := 'held'; end if;
  insert into public.community_comments (id, post_id, parent_id, user_id, identity, author_label,
                                         body, status, hold_reason, crisis)
  values (p_id, p_post, parent, me, case when p_identity = 'named' then 'named' else 'anon' end,
          coalesce(fname, ''), trim(p_body), st, case when st = 'held' then substr(verdict, 6) end,
          coalesce(verdict = 'crisis', false));
  if p_identity = 'named' and st = 'live' and public.community_expert_of(me) is not null then
    update public.community_expert_requests set answered_at = now()
     where post_id = p_post and answered_at is null;
  end if;
  return jsonb_build_object('ok', true, 'status', st, 'crisis', coalesce(verdict = 'crisis', false));
end $$;

-- Edit her own post within 15 minutes: title and body only. The safety
-- check runs again — an edit can move a post to held or raise crisis, and
-- never clears either. Online only on the phone: a queued edit could land
-- after the window and be refused, which would surprise her later.
create or replace function public.community_edit_post(p_id text, p_title text, p_body text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  gate text := public.community_gate();
  p public.community_posts;
  verdict text;
  st text;
  tags text[];
begin
  if me is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  select * into p from public.community_posts where id = p_id and deleted_at is null;
  if not found then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;
  if p.user_id is distinct from me then return jsonb_build_object('ok', false, 'reason', 'not_yours'); end if;
  if gate is not null and not (gate = 'not_joined' and p.identity = 'named') then
    return jsonb_build_object('ok', false, 'reason', gate);
  end if;
  if p.created_at < now() - interval '15 minutes' then
    return jsonb_build_object('ok', false, 'reason', 'too_late');
  end if;
  if char_length(trim(coalesce(p_title, ''))) < 4 then
    return jsonb_build_object('ok', false, 'reason', 'too_short');
  end if;
  verdict := public.community_check_text(p_title || ' ' || coalesce(p_body, ''));
  st := case when verdict like 'hold:%' and p.status = 'live' then 'held' else p.status end;
  select coalesce(array_agg(distinct lower(m[1])), '{}') into tags
    from regexp_matches(coalesce(p_body, '') || ' ' || p_title, '#([A-Za-z][A-Za-z0-9_]{1,30})', 'g') m;
  update public.community_posts
     set title = left(trim(p_title), 160), body = left(trim(coalesce(p_body, '')), 4000),
         hashtags = tags, status = st,
         hold_reason = case when st = 'held' and p.status = 'live' then substr(verdict, 6) else hold_reason end,
         crisis = crisis or coalesce(verdict = 'crisis', false),
         edited_at = now()
   where id = p_id;
  return jsonb_build_object('ok', true, 'status', st,
                            'crisis', p.crisis or coalesce(verdict = 'crisis', false));
end $$;

-- Block the author of a post or comment (copied from 0121). (0137) A team
-- post cannot be blocked: it is the house speaking, and blocking it would
-- hide a timetable notice from the person who most needs it.
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
  if idn = 'team' then return jsonb_build_object('ok', false, 'reason', 'team'); end if;
  if who is null then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;
  if who = auth.uid() then return jsonb_build_object('ok', false, 'reason', 'self'); end if;
  insert into public.community_blocks (blocker, blocked, label)
  values (auth.uid(), who, public.community_author(idn, who, lbl)->>'label')
  on conflict (blocker, blocked) do nothing;
  return jsonb_build_object('ok', true);
end $$;

-- Moderator actions (copied from 0121). (0137) A server-written notice has
-- no author, so "gone" now means the row is missing, not that its author
-- is null; mute and ban refuse a post with nobody behind it.
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
  if not found then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;

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
  elsif p_action in ('mute', 'ban') and author is null then
    return jsonb_build_object('ok', false, 'reason', 'team');
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
--  9. Following
-- ---------------------------------------------------------------------------

-- p_kind 'tag'    → p_target is the tag ('sleep' or '#sleep');
-- p_kind 'member' → p_target is a post or comment id: the face that wrote
--                   it is followed. Same trick as community_block, so the
--                   phone never sends (or learns) a user id;
-- p_kind 'follow' → p_target is a row id from community_following_list;
--                   unfollow only.
create or replace function public.community_follow(p_kind text, p_target text, p_on boolean)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_tag text;
  who uuid; idn text; lbl text;
begin
  if me is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  if p_kind = 'tag' then
    v_tag := ltrim(lower(trim(coalesce(p_target, ''))), '#');
    if v_tag !~ '^[a-z][a-z0-9_]{1,30}$' then return jsonb_build_object('ok', false, 'reason', 'invalid'); end if;
    if p_on then
      insert into public.community_follows (follower, kind, tag, label)
      values (me, 'tag', v_tag, '#' || v_tag) on conflict do nothing;
    else
      delete from public.community_follows where follower = me and kind = 'tag' and tag = v_tag;
    end if;
    return jsonb_build_object('ok', true);
  elsif p_kind = 'member' then
    select user_id, identity, author_label into who, idn, lbl from public.community_posts where id = p_target;
    if not found then
      select user_id, identity, author_label into who, idn, lbl from public.community_comments where id = p_target;
    end if;
    if idn = 'team' then return jsonb_build_object('ok', false, 'reason', 'team'); end if;
    if who is null then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;
    if who = me then return jsonb_build_object('ok', false, 'reason', 'self'); end if;
    if public.community_blocked_between(me, who) then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;
    if p_on then
      insert into public.community_follows (follower, kind, followee, face, label)
      values (me, 'member', who, idn, public.community_author(idn, who, lbl)->>'label')
      on conflict do nothing;
    else
      delete from public.community_follows
       where follower = me and kind = 'member' and followee = who and face = idn;
    end if;
    return jsonb_build_object('ok', true);
  elsif p_kind = 'follow' and not p_on then
    delete from public.community_follows
     where follower = me and id::text = coalesce(p_target, '');
    return jsonb_build_object('ok', true);
  end if;
  return jsonb_build_object('ok', false, 'reason', 'invalid');
end $$;

-- What she follows: rooms she is in, tags and faces. No ids of people.
create or replace function public.community_following_list()
returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'rooms', coalesce((select jsonb_agg(jsonb_build_object('id', r.id, 'title', r.title, 'kind', r.kind,
                                                           'mark', r.mark, 'hue', r.hue) order by r.sort, r.title)
                         from public.community_room_members m
                         join public.community_rooms r on r.id = m.room_id
                        where m.user_id = auth.uid() and r.is_open
                          and public.community_room_access(r.id)), '[]'::jsonb),
    'tags', coalesce((select jsonb_agg(f.tag order by f.created_at desc)
                        from public.community_follows f
                       where f.follower = auth.uid() and f.kind = 'tag'), '[]'::jsonb),
    'people', coalesce((select jsonb_agg(jsonb_build_object('id', f.id, 'label', f.label,
                                                            'anon', f.face = 'anon') order by f.created_at desc)
                          from public.community_follows f
                         where f.follower = auth.uid() and f.kind = 'member'
                           and not public.community_blocked_between(auth.uid(), f.followee)), '[]'::jsonb))
$$;

-- ---------------------------------------------------------------------------
--  10. Experts: ask, queue, claim, endorse
-- ---------------------------------------------------------------------------

-- The post's author asks, once per post. A crisis post is refused: the
-- moderators already have it, and the helplines are on her post (W20 —
-- crisis stays with moderators until the user widens it).
create or replace function public.community_ask_expert(p_post text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare p public.community_posts;
begin
  if auth.uid() is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  select * into p from public.community_posts where id = p_post and deleted_at is null;
  if not found then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;
  if p.user_id is distinct from auth.uid() or p.identity = 'team' then
    return jsonb_build_object('ok', false, 'reason', 'not_yours');
  end if;
  if p.crisis then return jsonb_build_object('ok', false, 'reason', 'crisis'); end if;
  if p.status <> 'live' then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;
  insert into public.community_expert_requests (post_id, asked_by, reason)
  values (p_post, auth.uid(), 'asked') on conflict (post_id) do nothing;
  return jsonb_build_object('ok', true);
end $$;

-- Open requests, oldest first, for a verified expert. Each says whether
-- another expert is already on it (a claim older than a day lapses).
create or replace function public.community_expert_queue()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v_me text := public.community_my_expert_id();
begin
  if v_me is null then return jsonb_build_object('ok', false, 'reason', 'not_expert'); end if;
  return jsonb_build_object('ok', true, 'items', coalesce((
    select jsonb_agg(jsonb_build_object(
        'post', public.community_post_json(p),
        'asked_at', e.created_at,
        'claimed_by_me', e.claimed_expert = v_me,
        'claimed_by', case when e.claimed_expert is not null and e.claimed_expert <> v_me
                            and e.claimed_at > now() - interval '1 day'
                           then (select ep.name from public.expert_profiles ep
                                  where ep.expert_id = e.claimed_expert) end)
      order by e.created_at)
      from public.community_expert_requests e
      join public.community_posts p on p.id = e.post_id
     where e.answered_at is null and e.reason = 'asked'
       and public.community_can_see(p)), '[]'::jsonb));
end $$;

-- Claim (or let go of) a question, so two experts do not answer the same one.
create or replace function public.community_expert_claim(p_post text, p_on boolean default true)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_me text := public.community_my_expert_id();
  e public.community_expert_requests;
begin
  if v_me is null then return jsonb_build_object('ok', false, 'reason', 'not_expert'); end if;
  select * into e from public.community_expert_requests where post_id = p_post for update;
  if not found or e.answered_at is not null then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;
  if not p_on then
    update public.community_expert_requests set claimed_expert = null, claimed_at = null
     where post_id = p_post and claimed_expert = v_me;
    return jsonb_build_object('ok', true);
  end if;
  if e.claimed_expert is not null and e.claimed_expert <> v_me
     and e.claimed_at > now() - interval '1 day' then
    return jsonb_build_object('ok', false, 'reason', 'taken');
  end if;
  update public.community_expert_requests set claimed_expert = v_me, claimed_at = now()
   where post_id = p_post;
  return jsonb_build_object('ok', true);
end $$;

-- "Found helpful by Dr X". Replies only, never one's own.
create or replace function public.community_endorse(p_kind text, p_id text, p_on boolean)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_me text := public.community_my_expert_id();
  c public.community_comments;
  p public.community_posts;
begin
  if v_me is null then return jsonb_build_object('ok', false, 'reason', 'not_expert'); end if;
  if p_kind <> 'comment' then return jsonb_build_object('ok', false, 'reason', 'invalid'); end if;
  select * into c from public.community_comments where id = p_id and deleted_at is null and status = 'live';
  if not found then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;
  if c.user_id = auth.uid() then return jsonb_build_object('ok', false, 'reason', 'self'); end if;
  select * into p from public.community_posts where id = c.post_id;
  if not public.community_can_see(p) then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;
  if p_on then
    insert into public.community_endorsements (target_kind, target_id, expert_id, user_id)
    values ('comment', p_id, v_me, auth.uid()) on conflict do nothing;
  else
    delete from public.community_endorsements
     where target_kind = 'comment' and target_id = p_id and expert_id = v_me;
  end if;
  return jsonb_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------------
--  11. The team voice and pinning
-- ---------------------------------------------------------------------------

-- "Post as ParentVeda team". Moderators only. The post shows the house
-- mark, never the moderator's name; the audit row records who. The author
-- column still holds the moderator (so she can delete her own prompt and
-- it reaches her replies), but no read ever prints it: community_author's
-- team branch does not look at the person, and community_face refuses a
-- team post. Hosts post with their badge instead, and may pin.
-- p_pin_days: 0 = not pinned, 1..14.
create or replace function public.community_create_prompt(
  p_id text, p_room text, p_title text, p_body text default '', p_pin_days int default 0)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  verdict text;
  tags text[];
  d int := greatest(0, least(14, coalesce(p_pin_days, 0)));
begin
  if not public.community_is_mod() then return jsonb_build_object('ok', false, 'reason', 'not_mod'); end if;
  if exists (select 1 from public.community_posts where id = p_id) then
    return jsonb_build_object('ok', true, 'status', 'live');
  end if;
  if not exists (select 1 from public.community_rooms
                  where id = p_room and is_open and kind in ('room', 'birth_club', 'offering')) then
    return jsonb_build_object('ok', false, 'reason', 'no_room');
  end if;
  if char_length(trim(coalesce(p_title, ''))) < 4 then
    return jsonb_build_object('ok', false, 'reason', 'too_short');
  end if;
  verdict := public.community_check_text(p_title || ' ' || coalesce(p_body, ''));
  if verdict is not null then
    -- The house never posts something its own check would hold.
    return jsonb_build_object('ok', false, 'reason', 'invalid');
  end if;
  select coalesce(array_agg(distinct lower(m[1])), '{}') into tags
    from regexp_matches(coalesce(p_body, '') || ' ' || p_title, '#([A-Za-z][A-Za-z0-9_]{1,30})', 'g') m;
  insert into public.community_posts (id, room_id, user_id, identity, author_label, title, body,
                                      hashtags, status, pinned_until)
  values (p_id, p_room, me, 'team', '', left(trim(p_title), 160), left(trim(coalesce(p_body, '')), 4000),
          tags, 'live', case when d > 0 then now() + make_interval(days => d) end);
  insert into public.community_mod_actions (actor, action, target_kind, target_id, reason)
  values (me, 'prompt', 'post', p_id, 'team post in ' || p_room
          || case when d > 0 then ', pinned ' || d || ' days' else '' end);
  return jsonb_build_object('ok', true, 'status', 'live');
end $$;

-- Pin a post to the top of its room for 1..14 days; 0 unpins. Moderators
-- anywhere; a course's hosts inside that course's room.
create or replace function public.community_pin(p_post text, p_days int)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  p public.community_posts;
  d int := greatest(0, least(14, coalesce(p_days, 0)));
begin
  if auth.uid() is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  select * into p from public.community_posts where id = p_post and deleted_at is null;
  if not found then return jsonb_build_object('ok', false, 'reason', 'gone'); end if;
  if not (public.community_is_mod() or public.community_is_host(p.room_id)) then
    return jsonb_build_object('ok', false, 'reason', 'not_mod');
  end if;
  update public.community_posts
     set pinned_until = case when d > 0 then now() + make_interval(days => d) end
   where id = p_post;
  insert into public.community_mod_actions (actor, action, target_kind, target_id, reason)
  values (auth.uid(), case when d > 0 then 'pin' else 'unpin' end, 'post', p_post,
          case when d > 0 then 'pinned ' || d || ' days' else 'unpinned' end);
  return jsonb_build_object('ok', true, 'pinned', d > 0);
end $$;

-- ---------------------------------------------------------------------------
--  12. The doctor's "Your offerings" (LA-21)
-- ---------------------------------------------------------------------------

-- Every run of every programme she is an ACCEPTED host of (route A), from
-- the server — not the phone's bundled catalogue, which never knew about
-- co-hosts or programmes the panel added later.
create or replace function public.expert_my_offerings()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v_me text := public.community_my_expert_id();
begin
  if v_me is null then return jsonb_build_object('ok', false, 'reason', 'not_expert'); end if;
  return jsonb_build_object('ok', true, 'items', coalesce((
    select jsonb_agg(x order by x->>'next_session' nulls last, x->>'title')
      from (
        select jsonb_build_object(
          'programme_id', p.id,
          'run_id', r.id,
          'title', p.title,
          'run_label', r.label,
          'kind', p.kind,
          'stage', p.stage,
          'role', pe.role,
          'seats_booked', (select count(distinct b.user_id) from public.booking_bookings b
                             join public.programme_sessions s on b.slot_id = 'ps_' || s.id
                            where s.run_id = r.id and b.status <> 'cancelled'),
          'capacity', coalesce(r.capacity, p.capacity),
          'next_session', (select min(s.starts_utc) from public.programme_sessions s
                            where s.run_id = r.id and s.starts_utc > now()),
          'room_id', cr.id,
          'unread', case when cr.id is null then 0 else (
                      select count(*) from public.community_posts cp
                       where cp.room_id = cr.id and cp.status = 'live' and cp.deleted_at is null
                         and cp.user_id is distinct from auth.uid()
                         and cp.created_at > coalesce(
                               (select s.seen_at from public.community_room_seen s
                                 where s.user_id = auth.uid() and s.room_id = cr.id),
                               '-infinity'::timestamptz)) end,
          'last_post_at', (select max(cp.created_at) from public.community_posts cp
                            where cp.room_id = cr.id and cp.status = 'live' and cp.deleted_at is null)) x
          from public.programme_experts pe
          join public.programmes p on p.id = pe.programme_id
          join public.programme_runs r on r.programme_id = p.id
                                      and r.status in ('open', 'closed', 'completed')
          left join public.community_rooms cr on cr.id = public.community_offering_room_id(p.id, r.id)
         where pe.expert_id = v_me and pe.status = 'accepted'
      ) t), '[]'::jsonb));
end $$;

-- ---------------------------------------------------------------------------
--  13. A timetable change tells the people booked (LA-22, D1)
--
--  _mirror_session copied from 0126; the slot's OLD start is read before the
--  upsert, and AFTER it — if the start moved and anyone holds an upcoming
--  seat — a pinned team notice is written in that run's room.
--
--  Why a trigger-driven notice and not "the panel remembers to post": the
--  timetable is edited in Directus, by a person, under time pressure. A rule
--  that lives in the write path cannot be forgotten, and every path that
--  moves a session (panel, SQL editor, a future API) passes through it.
--  The cost: the notice's wording is code, so changing it is a migration.
-- ---------------------------------------------------------------------------

create or replace function public._community_timetable_notice(
  p_session text, p_old timestamptz)
returns void language plpgsql security definer set search_path = '' as $$
declare
  s public.programme_sessions;
  v_room text;
  v_id text := 'tn_' || md5(p_session || clock_timestamp()::text);
  v_title text;
begin
  select * into s from public.programme_sessions where id = p_session;
  if s.id is null then return; end if;
  v_room := public._community_ensure_offering_room(s.programme_id, s.run_id);
  if v_room is null then return; end if;
  -- Only the newest notice for a session stays pinned.
  update public.community_posts set pinned_until = null
   where room_id = v_room and identity = 'team' and about_kind = 'session'
     and about_id = s.id and pinned_until is not null;
  v_title := left('Session moved: ' || coalesce(nullif(trim(s.title), ''), 'your session'), 160);
  insert into public.community_posts (id, room_id, user_id, identity, author_label, title, body,
                                      status, pinned_until, about_kind, about_id, moved_from)
  values (v_id, v_room, null, 'team', '', v_title,
          'This session has moved from '
            || to_char(p_old at time zone 'Asia/Kolkata', 'FMDy FMDD Mon, FMHH12:MI am')
            || ' to '
            || to_char(s.starts_utc at time zone 'Asia/Kolkata', 'FMDy FMDD Mon, FMHH12:MI am')
            || ' (India time). Your seat moves with it. If the new time does not work for you, '
            || 'open your booking to see your options.',
          'live', s.starts_utc, 'session', s.id, p_old);
  insert into public.community_mod_actions (actor, action, target_kind, target_id, reason)
  values (null, 'timetable_notice', 'post', v_id,
          'session ' || s.id || ' moved from ' || p_old || ' to ' || s.starts_utc);
end $$;

revoke all on function public._community_timetable_notice(text, timestamptz) from public, anon, authenticated;

create or replace function public._mirror_session(p_session_id text)
returns void
language plpgsql
security definer set search_path = ''
as $$
declare
  s        public.programme_sessions;
  p        public.programmes;
  v_expert text;
  v_old    timestamptz;
begin
  select * into s from public.programme_sessions where id = p_session_id;
  if s.id is null then return; end if;
  select * into p from public.programmes where id = s.programme_id;
  if p.status <> 'published' then return; end if;
  v_expert := public._programme_lead_host(p.id);
  if v_expert is null then return; end if;   -- nobody to teach it: no seats

  -- (0137) The start the people booked were told, before it changes.
  select starts_utc into v_old from public.booking_slots where id = 'ps_' || s.id;

  insert into public.booking_slots as bs
    (id, offering_id, expert_id, starts_utc, duration_min, capacity, join_url)
  values
    ('ps_' || s.id, p.offering_id, v_expert, s.starts_utc, s.duration_min,
     coalesce(s.capacity, p.capacity, 100), s.join_url)
  on conflict (id) do update
    set offering_id  = excluded.offering_id,
        starts_utc   = excluded.starts_utc,
        duration_min = excluded.duration_min,
        capacity     = greatest(excluded.capacity, bs.booked);

  update public.booking_bookings
     set starts_utc = s.starts_utc, duration_min = s.duration_min
   where slot_id = 'ps_' || s.id and status = 'upcoming'
     and (starts_utc <> s.starts_utc or duration_min <> s.duration_min);

  -- (0137) LA-22: a moved session with people booked gets a pinned notice.
  if v_old is not null and v_old <> s.starts_utc and exists (
      select 1 from public.booking_bookings
       where slot_id = 'ps_' || s.id and status = 'upcoming') then
    perform public._community_timetable_notice(s.id, v_old);
  end if;
end;
$$;

revoke all on function public._mirror_session(text) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
--  14. Who may call what (new and re-signed functions)
-- ---------------------------------------------------------------------------

revoke all on function
  public.community_feed(text, text, text, text, text[], int, int, text, text, text),
  public.community_create_post(text, text, text, text, text, jsonb, int, text, text),
  public.community_offering_room(text, text), public.community_room_seen(text),
  public.community_birth_club(text), public.community_search(text, int),
  public.community_edit_post(text, text, text),
  public.community_follow(text, text, boolean), public.community_following_list(),
  public.community_ask_expert(text), public.community_expert_queue(),
  public.community_expert_claim(text, boolean), public.community_endorse(text, text, boolean),
  public.community_create_prompt(text, text, text, text, int), public.community_pin(text, int),
  public.expert_my_offerings()
  from public, anon;

grant execute on function
  public.community_feed(text, text, text, text, text[], int, int, text, text, text),
  public.community_create_post(text, text, text, text, text, jsonb, int, text, text),
  public.community_offering_room(text, text), public.community_room_seen(text),
  public.community_birth_club(text), public.community_search(text, int),
  public.community_edit_post(text, text, text),
  public.community_follow(text, text, boolean), public.community_following_list(),
  public.community_ask_expert(text), public.community_expert_queue(),
  public.community_expert_claim(text, boolean), public.community_endorse(text, text, boolean),
  public.community_create_prompt(text, text, text, text, int), public.community_pin(text, int),
  public.expert_my_offerings()
  to authenticated;

-- ---------------------------------------------------------------------------
--  15. The Over-35 room (STILL-OPEN §79.5)
-- ---------------------------------------------------------------------------

insert into public.community_rooms (id, title, blurb, stage_tag, mark, hue, sort) values
  ('preg_over_35', 'Pregnant after 35', 'The extra scans, the screening talk, and everyone asking if it is "late". Company that gets it.', 'pregnancy', 'tab:timelineDots', 30, 26)
on conflict (id) do update set
  title = excluded.title, blurb = excluded.blurb, stage_tag = excluded.stage_tag,
  mark = excluded.mark, hue = excluded.hue, sort = excluded.sort;


-- =====================================================================
-- VERIFY (each should return true)
--
--   select exists (select 1 from information_schema.columns
--                   where table_name = 'community_posts' and column_name = 'search');
--   select exists (select 1 from pg_constraint where conname = 'community_posts_team_author');
--   select has_function_privilege('authenticated',
--     'public.community_offering_room(text, text)', 'execute');
--   select not has_function_privilege('anon',
--     'public.community_offering_room(text, text)', 'execute');
--   select not has_function_privilege('authenticated',
--     'public.community_room_access(text)', 'execute');
--   select (select count(*) from pg_proc where proname = 'community_feed') = 1;
--   select (select count(*) from pg_proc where proname = 'community_create_post') = 1;
--   select prosrc like '%_community_timetable_notice%' from pg_proc where proname = '_mirror_session';
--   select exists (select 1 from public.community_rooms where id = 'preg_over_35');
--   select public.community_search('sleep', 0) ? 'posts';
-- =====================================================================
