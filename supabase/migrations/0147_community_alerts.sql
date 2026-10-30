-- 0147 — Community phase 3, C3-2: reply alerts (2026-10-30).
-- docs/COMMUNITY.md, "Phase 3: plan and decisions" (C2 to C8, C13) and
-- "As built (phase 3) — C3-2". The sender is 6b's (0144, B4) and is not
-- touched: Community adds a branch to the functions it reads.
--
-- WHY: a parent who posts wants to hear back, and today she only finds out
-- by opening the app. Three kinds of alert, each with its own switch:
--   reply       someone replied to her post or to her reply   (off until she says yes, C8)
--   booking     a session she booked has moved                (on once she books, C3)
--   moderation  a post may need a moderator now               (moderators, on, any hour: P0-3, C7)
--
-- WHAT:
--   community_replied_to / community_reply_recipient
--                        THE "replied to you" rule. community_activity,
--                        community_me's unread count and the reply trigger
--                        all read it, so the three can never disagree.
--   community_push_consent   her switches, per kind. Community's OWN, beside
--                            6b's push_consent (per stage), which stays as is.
--   community_post_mutes     "Turn off replies for this post".
--   community_push_queue     Community's OWN queue (beside push_sends).
--   community_push_enqueue   C4's limits, in one place.
--   three triggers           replies, moved sessions, crisis. TRIGGERS ONLY:
--                            community_comment and _community_timetable_notice
--                            are not rewritten (C13, §16zzi).
--   community_push_due       the branch pv_push_due appends.
--   pv_push_due / pv_push_mark / pv_push_any_due / pv_push_link_needs
--                            each gains Community's branch. push-send is not
--                            edited.
--   community_alerts_get / _set / community_post_mute   what the phone calls.
--
-- ⚠️ THE LOCK SCREEN SHOWS NO CONTENT (C2). No room, title, words or name in
-- any title or body below: phones are shared, and room names say "loss" or
-- "IVF". The text is fixed here, never built from a post.
--
-- ⚠️ AN ALERT NEVER BLOCKS THE WRITE IT FOLLOWS. Each trigger's work sits in
-- its own BEGIN ... EXCEPTION block (a savepoint). If queuing fails, her
-- reply, the timetable notice or the crisis flag still saves; only the alert
-- is lost, and Replies to you still shows the reply. The verify file counts
-- the rows each trigger should have written, because a swallowed error is
-- otherwise invisible (the C3-1 lesson).
--
-- PREREQ: 0121, 0137, 0140, 0143, 0144, 0146 (B5's pv_push_due, which this
-- file extends; a copy of 0144's would put the campaign channel back to
-- null). Safe to re-run.
-- =====================================================================

-- 1) The "replied to you" rule, once ----------------------------------

-- Who a reply is addressed to: the author of the reply it answers, or, for a
-- top-level reply, the author of the post. Null for a team post (no author).
create or replace function public.community_reply_recipient(
  c public.community_comments, p public.community_posts, p_parent_user uuid)
returns uuid language sql stable security definer set search_path = '' as $$
  select case when c.parent_id is not null then p_parent_user else p.user_id end
$$;

-- Is reply c "a reply to" p_me? The rule community_activity has used since
-- 0121, moved here word for word:
--   not her own, live, not deleted, on a post that is not deleted,
--   addressed to her (above), and nobody blocked between the two.
-- ⚠️ ONE RULE, THREE READERS. Before 0147, community_me counted a reply under
-- someone else's comment on her post as "to her" (p.user_id = me or
-- pc.user_id = me) while community_activity did not list it: the dot said
-- "new" and the list had nothing. Both now read this function.
create or replace function public.community_replied_to(
  c public.community_comments, p public.community_posts, p_parent_user uuid, p_me uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select p_me is not null
     and c.user_id <> p_me
     and c.status = 'live' and c.deleted_at is null and p.deleted_at is null
     and public.community_reply_recipient(c, p, p_parent_user) = p_me
     and not public.community_blocked_between(p_me, c.user_id)
$$;

revoke all on function public.community_reply_recipient(public.community_comments, public.community_posts, uuid) from public, anon, authenticated;
revoke all on function public.community_replied_to(public.community_comments, public.community_posts, uuid, uuid) from public, anon, authenticated;

-- community_activity (0121), now through the rule. Only the WHERE changed.
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
     -- (0147) The shared rule. Kept for revert, 0121's own copy:
     --   where c.user_id <> auth.uid() and c.status = 'live' and c.deleted_at is null and p.deleted_at is null
     --     and (pc.user_id = auth.uid() or (c.parent_id is null and p.user_id = auth.uid()))
     --     and not public.community_blocked_between(auth.uid(), c.user_id)
     where public.community_replied_to(c, p, pc.user_id, auth.uid())
       -- A NARROWING, NOT A SECOND RULE. Every reply the rule accepts is on
       -- her post or under her reply, so this line removes nothing the rule
       -- would keep. It is here for the planner: a function with its own
       -- search_path is not inlined, so without an indexable condition it
       -- would run once for every reply in the community.
       and (p.user_id = auth.uid() or pc.user_id = auth.uid())
     order by c.created_at desc limit least(100, greatest(1, p_limit))) t
$$;

-- community_me (0137), now through the rule. Only the unread count changed.
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
    -- (0147) The shared rule. Kept for revert, 0137's own copy:
    --   left join public.community_posts p on p.id = c.post_id
    --   where c.user_id <> me and c.status = 'live' and c.deleted_at is null
    --     and c.created_at > pr.activity_seen_at
    --     and (p.user_id = me or pc.user_id = me)
    --     and not public.community_blocked_between(me, c.user_id);
    select count(*) into unread from public.community_comments c
      join public.community_posts p on p.id = c.post_id
      left join public.community_comments pc on pc.id = c.parent_id
     where c.created_at > pr.activity_seen_at
       and public.community_replied_to(c, p, pc.user_id, me)
       -- The narrowing community_activity has, for the same reason.
       and (p.user_id = me or pc.user_id = me);
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

-- 2) Her switches, and muted posts -------------------------------------

-- One row per kind she has decided. NO ROW IS A DEFAULT, and the defaults
-- differ on purpose (the "missing means" choice, §16zzz-a):
--   replies     missing = OFF. She is asked once, after her first post (C8).
--   bookings    missing = ON. She booked; a moved session is news she needs (C3).
--   moderation  missing = ON, moderators only (P0-3).
create table if not exists public.community_push_consent (
  user_id     uuid        not null references auth.users (id) on delete cascade,
  kind        text        not null check (kind in ('replies', 'bookings', 'moderation')),
  allowed     boolean     not null,
  decided_at  timestamptz not null default now(),
  primary key (user_id, kind)
);

create table if not exists public.community_post_mutes (
  user_id     uuid        not null references auth.users (id) on delete cascade,
  post_id     text        not null references public.community_posts (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (user_id, post_id)
);

alter table public.community_push_consent enable row level security;
alter table public.community_post_mutes   enable row level security;
revoke all on public.community_push_consent, public.community_post_mutes from anon, authenticated;

-- 3) The queue ----------------------------------------------------------

-- One row = one buzz on her phone. Replies to one post that arrive before it
-- goes MERGE into it (n counts them), so three replies are one alert saying
-- "3 new replies". Readable by nobody but the definer functions.
create table if not exists public.community_push_queue (
  id           uuid        primary key default gen_random_uuid(),
  user_id      uuid        not null references auth.users (id) on delete cascade,
  kind         text        not null check (kind in ('reply', 'booking', 'moderation')),
  -- reply: the post replied on. booking: the timetable notice. moderation:
  -- the post at risk (or the post a reply at risk is on).
  post_id      text        not null references public.community_posts (id) on delete cascade,
  -- booking: which of her bookings the alert opens.
  booking_id   text,
  n            int         not null default 1 check (n >= 1),
  -- Queued inside quiet hours: the text says "overnight".
  overnight    boolean     not null default false,
  -- The IST day it rings on, which C4's "3 a day" counts against.
  ring_day     date        not null,
  due_at       timestamptz not null default now(),
  send_before  timestamptz not null,
  status       text        not null default 'queued'
               check (status in ('queued', 'sent', 'failed', 'skipped')),
  error        text,
  devices_sent int         not null default 0,
  sent_at      timestamptz,
  claimed_at   timestamptz,
  created_at   timestamptz not null default now()
);

-- ⚠️ THE MERGE IS A RULE OF THE TABLE. Two replies inserted at the same
-- moment could each read "nothing queued" and queue two buzzes. One queued
-- row per person, kind and post is a unique index, and the insert merges on
-- conflict (§16zzz-c: a rule a race can break needs a constraint).
create unique index if not exists community_push_queue_merge
  on public.community_push_queue (user_id, kind, post_id) where status = 'queued';
create index if not exists community_push_queue_due
  on public.community_push_queue (due_at) where status = 'queued';
create index if not exists community_push_queue_day
  on public.community_push_queue (user_id, ring_day) where kind = 'reply';

alter table public.community_push_queue enable row level security;
revoke all on public.community_push_queue from anon, authenticated;

-- 4) Time: quiet hours and the day a buzz counts against ----------------

-- 21:00 to 08:00 India time (C4). Fixed, not a setting.
create or replace function public.community_quiet_at(p_at timestamptz)
returns boolean language sql immutable set search_path = '' as $$
  select (p_at at time zone 'Asia/Kolkata')::time >= time '21:00'
      or (p_at at time zone 'Asia/Kolkata')::time <  time '08:00'
$$;

-- The IST date a buzz due at p_at actually rings: after 21:00 it waits for
-- tomorrow's 08:00, so it counts against tomorrow.
create or replace function public.community_ring_day(p_at timestamptz)
returns date language sql immutable set search_path = '' as $$
  select (p_at at time zone 'Asia/Kolkata')::date
       + case when (p_at at time zone 'Asia/Kolkata')::time >= time '21:00' then 1 else 0 end
$$;

-- Is row q due at p_at? Takes the time as an argument so the verify can ask
-- about 10:00 and 22:00 without waiting for them.
--   reply, booking  not in quiet hours: an overnight row rings at 08:00
--   moderation      any hour (P0-3)
create or replace function public.community_push_is_due(
  q public.community_push_queue, p_at timestamptz)
returns boolean language sql stable set search_path = '' as $$
  select q.status = 'queued'
     and p_at >= q.due_at
     and p_at <  q.send_before
     and (q.claimed_at is null or q.claimed_at < p_at - interval '5 minutes')
     and (q.kind = 'moderation' or not public.community_quiet_at(p_at))
$$;

-- 5) May this alert reach her? Her switch, her mutes, her role ---------

-- Asked when queuing AND again when sending: a switch turned off, or a post
-- muted, after the row was queued still stops it.
create or replace function public.community_push_allowed(p_user uuid, p_kind text, p_post text)
returns boolean language sql stable security definer set search_path = '' as $$
  select case p_kind
    when 'reply' then
      coalesce((select allowed from public.community_push_consent
                 where user_id = p_user and kind = 'replies'), false)
      and not exists (select 1 from public.community_post_mutes
                       where user_id = p_user and post_id = p_post)
    when 'booking' then
      coalesce((select allowed from public.community_push_consent
                 where user_id = p_user and kind = 'bookings'), true)
    when 'moderation' then
      exists (select 1 from public.community_moderators where user_id = p_user)
      and coalesce((select allowed from public.community_push_consent
                     where user_id = p_user and kind = 'moderation'), true)
    else false
  end
$$;

-- The 0112 loss condition, word for word as 0143 checks it (decision 8):
-- a pregnancy ended, and she has not since moved to a new stage.
create or replace function public.community_after_loss(p_user uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.profiles pp
     where pp.id = p_user
       and pp.pregnancy_ended_at is not null
       and not (pp.life_stage_at is not null
                and pp.pregnancy_ended_at < pp.life_stage_at))
$$;

-- 6) Queue one alert: C4's limits, in one place -------------------------

-- Returns what happened, so the verify can check each limit by name:
--   'off'     her switch, a mute, or not a moderator
--   'merged'  joined the alert already waiting for this post (no new buzz)
--   'capped'  a 4th reply alert today: Replies to you only (C4)
--   'queued'  a new buzz
--
-- ⚠️ REPLIES WAIT 3 MINUTES before they are due. Replies come in bursts; a
-- short wait lets a burst become one "3 new replies" instead of three buzzes.
-- The cost is a 3-minute delay on the first one, which for a community reply
-- is nothing. Bookings and moderation go at once.
-- ⚠️ THE CAP IS SOFT UNDER A RACE. Two replies to two different posts at the
-- same instant can both read "2 today" and both queue: 4, once. The merge is
-- a unique index because a race there would double-buzz every time; the cap
-- being off by one on a rare race is accepted.
create or replace function public.community_push_enqueue(
  p_user uuid, p_kind text, p_post text, p_booking text default null)
returns text language plpgsql security definer set search_path = '' as $$
declare
  k_daily  constant int      := 3;                     -- C4
  k_wait   constant interval := interval '3 minutes';  -- the burst window
  v_due    timestamptz;
  v_day    date;
  v_before timestamptz;
  v_id     uuid;
begin
  if p_user is null or p_post is null then return 'off'; end if;
  if not public.community_push_allowed(p_user, p_kind, p_post) then return 'off'; end if;

  -- A queued row past its cutoff would hold the merge index forever (new
  -- replies merging into a row that will never send). End it first.
  update public.community_push_queue q
     set status = 'skipped', error = 'past_cutoff', claimed_at = null
   where q.user_id = p_user and q.kind = p_kind and q.post_id = p_post
     and q.status = 'queued' and now() >= q.send_before;

  -- Merge into the alert already waiting for this post.
  update public.community_push_queue q
     set n = q.n + 1
   where q.user_id = p_user and q.kind = p_kind and q.post_id = p_post
     and q.status = 'queued'
  returning q.id into v_id;
  if v_id is not null then return 'merged'; end if;

  v_due := now() + case when p_kind = 'reply' then k_wait else interval '0' end;
  if p_kind = 'moderation' then
    v_day    := (v_due at time zone 'Asia/Kolkata')::date;
    v_before := v_due + interval '24 hours';
  else
    v_day    := public.community_ring_day(v_due);
    -- Its own day's 21:00: a buzz that could not go by then is stale.
    v_before := (v_day + time '21:00') at time zone 'Asia/Kolkata';
  end if;

  if p_kind = 'reply' and (
       select count(*) from public.community_push_queue q
        where q.user_id = p_user and q.kind = 'reply' and q.ring_day = v_day
          and q.status in ('queued', 'sent')) >= k_daily then
    return 'capped';
  end if;

  insert into public.community_push_queue as q
    (user_id, kind, post_id, booking_id, overnight, ring_day, due_at, send_before)
  values (p_user, p_kind, p_post, p_booking,
          p_kind <> 'moderation' and public.community_quiet_at(v_due),
          v_day, v_due, v_before)
  on conflict (user_id, kind, post_id) where status = 'queued'
  do update set n = q.n + 1;
  return 'queued';
end $$;

revoke all on function public.community_push_enqueue(uuid, text, text, text) from public, anon, authenticated;
revoke all on function public.community_push_allowed(uuid, text, text) from public, anon, authenticated;
revoke all on function public.community_after_loss(uuid) from public, anon, authenticated;

-- 7) The triggers (C13: triggers, never a rewrite) ----------------------

-- A reply: when it goes live. On insert if it is live at once; on the update
-- that approves a HELD reply (held -> live). Not on hidden -> live: that is a
-- reply restored after reports, and it already rang when it first went live.
create or replace function public.community_reply_alert()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  p      public.community_posts;
  v_par  uuid;
  v_to   uuid;
begin
  if new.status <> 'live' then return null; end if;
  if tg_op = 'UPDATE' then
    if old.status <> 'held' then return null; end if;
  end if;
  begin
    select * into p from public.community_posts where id = new.post_id;
    if new.parent_id is not null then
      select user_id into v_par from public.community_comments where id = new.parent_id;
    end if;
    v_to := public.community_reply_recipient(new, p, v_par);
    if v_to is not null and public.community_replied_to(new, p, v_par, v_to) then
      perform public.community_push_enqueue(v_to, 'reply', new.post_id);
    end if;
  exception when others then
    raise warning 'community_reply_alert: % (reply % still saved)', sqlerrm, new.id;
  end;
  return null;
end $$;

drop trigger if exists community_comments_reply_alert on public.community_comments;
create trigger community_comments_reply_alert
  after insert or update of status on public.community_comments
  for each row execute function public.community_reply_alert();

-- A moved session (C3, C6): the pinned team notice 0137's
-- _community_timetable_notice writes, recognised by moved_from. Everyone
-- holding a seat on that slot, minus a pregnancy-stage class for someone
-- after a loss (the notice in the room still shows; only the buzz is held).
create or replace function public.community_moved_alert()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  b record;
begin
  if new.identity <> 'team' or new.moved_from is null
     or new.about_kind is distinct from 'session' or new.about_id is null then
    return null;
  end if;
  begin
    for b in
      select distinct on (bb.user_id) bb.user_id, bb.id,
             coalesce(pr.stage, bb.stage) as stage
        from public.booking_bookings bb
        left join public.programme_sessions s on s.id = new.about_id
        left join public.programmes pr on pr.id = s.programme_id
       where bb.slot_id = 'ps_' || new.about_id
         and bb.status <> 'cancelled'
       order by bb.user_id, bb.created_at desc
    loop
      if b.stage = 'pregnancy' and public.community_after_loss(b.user_id) then
        continue;
      end if;
      perform public.community_push_enqueue(b.user_id, 'booking', new.id, b.id);
    end loop;
  exception when others then
    raise warning 'community_moved_alert: % (notice % still saved)', sqlerrm, new.id;
  end;
  return null;
end $$;

drop trigger if exists community_posts_moved_alert on public.community_posts;
create trigger community_posts_moved_alert
  after insert on public.community_posts
  for each row execute function public.community_moved_alert();

-- At risk (C7): a post or reply the screen marks crisis, or a member reports
-- as at risk (0121 sets crisis then), reaches every moderator but its author.
-- Moderators only, never an expert (W20).
create or replace function public.community_crisis_alert()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_post text;
  m      record;
begin
  if not new.crisis then return null; end if;
  if tg_op = 'UPDATE' then
    if old.crisis then return null; end if;   -- already rang
  end if;
  begin
    -- Two statements, not one CASE: PL/pgSQL plans a statement when it first
    -- runs it, and new.post_id does not exist on a post.
    if tg_table_name = 'community_comments' then
      v_post := new.post_id;
    else
      v_post := new.id;
    end if;
    for m in select cm.user_id from public.community_moderators cm
              where cm.user_id is distinct from new.user_id loop
      perform public.community_push_enqueue(m.user_id, 'moderation', v_post);
    end loop;
  exception when others then
    raise warning 'community_crisis_alert: % (% % still saved)', sqlerrm, tg_table_name, new.id;
  end;
  return null;
end $$;

drop trigger if exists community_posts_crisis_alert on public.community_posts;
create trigger community_posts_crisis_alert
  after insert or update of crisis on public.community_posts
  for each row execute function public.community_crisis_alert();
drop trigger if exists community_comments_crisis_alert on public.community_comments;
create trigger community_comments_crisis_alert
  after insert or update of crisis on public.community_comments
  for each row execute function public.community_crisis_alert();

-- 8) The text (C2, P0-2, C3). Fixed words, nothing from the post --------

create or replace function public.community_push_text(q public.community_push_queue)
returns table (title text, body text)
language sql immutable set search_path = '' as $$
  select case q.kind
           when 'reply'      then 'New reply in ParentVeda Community'
           when 'booking'    then 'A session you booked has moved'
           else                   'A post may need a moderator now'
         end,
         case q.kind
           when 'reply' then
             case when q.n = 1 then 'Someone replied to your post.'
                  when q.overnight then q.n || ' new replies to your post overnight.'
                  else q.n || ' new replies to your post.' end
           when 'booking' then 'Tap to see the new time.'
           else 'Open Moderation to see it.'
         end
$$;

-- 9) Community's branch of the sender ----------------------------------

-- The same shape as pv_push_due. Ends what can no longer go, claims what is
-- due, hands it over. The Android channel per kind is one the app creates
-- (CommunityAlerts.channels): "Replies", "Your bookings", "Moderation", so
-- she can silence one kind from the phone's own settings too.
create or replace function public.community_push_due(p_limit int default 500)
returns table (
  queue        text,
  row_id       uuid,
  user_id      uuid,
  tokens       text[],
  title        text,
  body         text,
  data         jsonb,
  collapse_key text,
  priority     text,
  channel      text
)
language plpgsql
security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  lease interval := interval '5 minutes';
  -- NOT `n`: the queue has a column n (merged replies), and with
  -- use_column a variable that shares a column's name reads as the column.
  -- `limit n` then fails: "argument of LIMIT must not contain variables".
  v_limit int := greatest(coalesce(p_limit, 500), 1);
begin
  update public.community_push_queue q
     set status = 'skipped', error = 'past_cutoff', claimed_at = null
   where q.status = 'queued' and now() >= q.send_before;

  -- Her switch went off, or she muted the post, after it was queued.
  update public.community_push_queue q
     set status = 'skipped', error = 'off', claimed_at = null
   where q.status = 'queued' and now() >= q.due_at
     and not public.community_push_allowed(q.user_id, q.kind, q.post_id);

  -- No device that can open a community link (linkVersion 2).
  update public.community_push_queue q
     set status = 'skipped', error = 'no_device', claimed_at = null
   where q.status = 'queued' and now() >= q.due_at
     and not exists (
           select 1 from public.push_devices d
            where d.user_id = q.user_id
              and d.link_version >= public.pv_push_link_needs(
                    case q.kind when 'reply' then 'community_post'
                                when 'booking' then 'booking'
                                else 'community_moderation' end));

  return query
  with due as (
    select q.id
      from public.community_push_queue q
     where q.status = 'queued' and now() >= q.due_at
       and public.community_push_is_due(q, now())
     -- A moderator's alert first.
     order by (q.kind = 'moderation') desc, q.due_at, q.id
     limit v_limit
     for update of q skip locked
  ),
  claimed as (
    update public.community_push_queue q
       set claimed_at = now()
      from due
     where q.id = due.id
    returning q.*
  ),
  linked as (
    select k.*,
           case k.kind when 'reply' then 'community_post'
                       when 'booking' then 'booking'
                       else 'community_moderation' end as link_kind,
           case k.kind when 'booking' then coalesce(k.booking_id, '') else k.post_id end as link_id
      from claimed k
  )
  select 'community_push_queue'::text,
         l.id,
         l.user_id,
         array(select d.token from public.push_devices d
                where d.user_id = l.user_id
                  and d.link_version >= public.pv_push_link_needs(l.link_kind)
                order by d.last_seen_at desc),
         t.title,
         t.body,
         jsonb_build_object('link_kind', l.link_kind, 'link_id', l.link_id,
                            'queue', 'community_push_queue', 'row_id', l.id::text),
         -- Replies to one post replace each other on her phone.
         case l.kind when 'reply' then 'community-post-' || l.post_id
                     when 'booking' then 'community-booking-' || l.post_id
                     else 'community-moderation' end,
         case l.kind when 'moderation' then 'high' else 'normal' end,
         case l.kind when 'reply' then 'community_replies'
                     when 'booking' then 'community_bookings'
                     else 'community_moderation' end
    from linked l
    cross join lateral public.community_push_text(
      (select q from public.community_push_queue q where q.id = l.id)) t;
end;
$$;

revoke all on function public.community_push_due(int) from public, anon, authenticated;
grant execute on function public.community_push_due(int) to service_role;

-- 10) The sender's functions, each with Community's branch ---------------

-- Which build opens a link kind. 0143's four, plus Community's three at 2
-- (PushService.linkVersion 2). An older phone is skipped as 'no_device'.
create or replace function public.pv_push_link_needs(p_kind text)
returns int
language sql
immutable
set search_path = ''
as $$
  select case p_kind
           when 'course'  then 1
           when 'product' then 1
           when 'expert'  then 1
           when 'read'    then 1
           -- (0147) Community C3-2.
           when 'community_post'       then 2
           when 'booking'              then 2
           when 'community_moderation' then 2
           else 2147483647            -- an unknown kind reaches no build
         end;
$$;
revoke all on function public.pv_push_link_needs(text) from public, anon, authenticated;

-- ⚠️ pv_push_due IS 0146's TEXT PLUS ONE LINE at the end. Copied from 0146
-- (B5), not 0144: B5 set the campaign channel to 'offers_news'.
-- test/community_alerts_test.dart holds that every line of the latest earlier
-- definition is still here (§16zzi: a rewrite can quietly drop one).
create or replace function public.pv_push_due(p_limit int default 500)
returns table (
  queue        text,
  row_id       uuid,
  user_id      uuid,
  tokens       text[],
  title        text,
  body         text,
  data         jsonb,
  collapse_key text,
  priority     text,
  channel      text
)
language plpgsql
security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  -- A claim older than this belongs to a sender that died.
  lease interval := interval '5 minutes';
  n     int := greatest(coalesce(p_limit, 500), 1);
begin
  -- -- push_sends: tonight's campaign bookings (0143) --------------------
  -- 0146 (B5): channel 'offers_news', which the app creates
  -- (PushService.offersChannel). Nothing else in this branch changed.

  -- Past the cutoff: never a night buzz (row 20).
  update public.push_sends s
     set status = 'skipped', error = 'past_cutoff', claimed_at = null
   where s.status = 'queued' and now() >= s.send_before;

  -- No device left that can open the link (signed out, uninstalled).
  update public.push_sends s
     set status = 'skipped', error = 'no_device', claimed_at = null
    from public.push_campaigns c
   where c.id = s.campaign_id
     and s.status = 'queued'
     and now() >= (s.send_on + time '19:00') at time zone 'Asia/Kolkata'
     and not exists (
           select 1 from public.push_devices d
            where d.user_id = s.user_id
              and d.link_version >= public.pv_push_link_needs(c.link_kind));

  return query
  with due as (
    select s.id
      from public.push_sends s
     where s.status = 'queued'
       -- 19:00 IST on its evening, or later, and before its cutoff.
       and now() >= (s.send_on + time '19:00') at time zone 'Asia/Kolkata'
       and now() <  s.send_before
       and (s.claimed_at is null or s.claimed_at < now() - lease)
     order by s.send_on, s.id
     limit n
     -- Two senders at once each take different rows, never the same one.
     for update of s skip locked
  ),
  claimed as (
    update public.push_sends s
       set claimed_at = now()
      from due
     where s.id = due.id
    returning s.id, s.campaign_id, s.user_id
  )
  select 'push_sends'::text,
         k.id,
         k.user_id,
         array(select d.token from public.push_devices d
                where d.user_id = k.user_id
                  and d.link_version >= public.pv_push_link_needs(c.link_kind)
                order by d.last_seen_at desc),
         c.title,
         c.body,
         jsonb_build_object('link_kind', c.link_kind, 'link_id', c.link_id,
                            'queue', 'push_sends', 'row_id', k.id::text),
         'campaign-' || c.id,
         'normal'::text,
         'offers_news'::text
    from claimed k
    join public.push_campaigns c on c.id = k.campaign_id;

  -- -- push_tests: pv_campaign_test, now, your own devices ---------------
  -- 0146 (B5): the same channel, so a test looks exactly like the real send.

  update public.push_tests t
     set status = 'skipped', error = 'past_cutoff', claimed_at = null
   where t.status = 'queued' and now() >= t.send_before;

  update public.push_tests t
     set status = 'skipped', error = 'no_device', claimed_at = null
    from public.push_campaigns c
   where c.id = t.campaign_id
     and t.status = 'queued'
     and not exists (
           select 1 from public.push_devices d
            where d.user_id = t.user_id
              and d.link_version >= public.pv_push_link_needs(c.link_kind));

  return query
  with due as (
    select t.id
      from public.push_tests t
     where t.status = 'queued'
       and now() < t.send_before
       and (t.claimed_at is null or t.claimed_at < now() - lease)
     order by t.created_at
     limit n
     for update of t skip locked
  ),
  claimed as (
    update public.push_tests t
       set claimed_at = now()
      from due
     where t.id = due.id
    returning t.id, t.campaign_id, t.user_id
  )
  select 'push_tests'::text,
         k.id,
         k.user_id,
         array(select d.token from public.push_devices d
                where d.user_id = k.user_id
                  and d.link_version >= public.pv_push_link_needs(c.link_kind)
                order by d.last_seen_at desc),
         c.title,
         c.body,
         jsonb_build_object('link_kind', c.link_kind, 'link_id', c.link_id,
                            'queue', 'push_tests', 'row_id', k.id::text),
         'campaign-' || c.id,
         'normal'::text,
         'offers_news'::text
    from claimed k
    join public.push_campaigns c on c.id = k.campaign_id;

  -- -- community_push_queue: replies, moved sessions, at risk (0147) -----
  return query select * from public.community_push_due(n);
end;
$$;

revoke all on function public.pv_push_due(int) from public, anon, authenticated;
grant execute on function public.pv_push_due(int) to service_role;

-- 0144's pv_push_mark, plus the community branch (the same five columns).
create or replace function public.pv_push_mark(
  p_queue        text,
  p_row_id       uuid,
  p_status       text,
  p_devices_sent int  default 0,
  p_error        text default null,
  p_dead_tokens  text[] default '{}'
)
returns void
language plpgsql
security definer set search_path = ''
as $$
begin
  if p_status not in ('sent', 'failed', 'skipped', 'queued') then
    raise exception 'pv_push_mark: unknown status %', p_status;
  end if;

  if coalesce(cardinality(p_dead_tokens), 0) > 0 then
    delete from public.push_devices d where d.token = any (p_dead_tokens);
  end if;

  if p_queue = 'push_sends' then
    update public.push_sends s
       set status       = p_status,
           devices_sent = coalesce(p_devices_sent, 0),
           error        = left(p_error, 500),
           sent_at      = case when p_status = 'sent' then now() else s.sent_at end,
           claimed_at   = null
     where s.id = p_row_id and s.status = 'queued';
  elsif p_queue = 'push_tests' then
    update public.push_tests t
       set status       = p_status,
           devices_sent = coalesce(p_devices_sent, 0),
           error        = left(p_error, 500),
           sent_at      = case when p_status = 'sent' then now() else t.sent_at end,
           claimed_at   = null
     where t.id = p_row_id and t.status = 'queued';
  -- (0147) Community C3-2.
  elsif p_queue = 'community_push_queue' then
    update public.community_push_queue q
       set status       = p_status,
           devices_sent = coalesce(p_devices_sent, 0),
           error        = left(p_error, 500),
           sent_at      = case when p_status = 'sent' then now() else q.sent_at end,
           claimed_at   = null
     where q.id = p_row_id and q.status = 'queued';
  else
    raise exception 'pv_push_mark: unknown queue %', p_queue;
  end if;
end;
$$;

revoke all on function public.pv_push_mark(text, uuid, text, int, text, text[]) from public, anon, authenticated;
grant execute on function public.pv_push_mark(text, uuid, text, int, text, text[]) to service_role;

-- 0144's pv_push_any_due, plus the community queue. The cron calls the
-- sender only when this is true, so without it a reply would wait for the
-- next campaign evening.
create or replace function public.pv_push_any_due()
returns boolean
language sql
stable
security definer set search_path = ''
as $$
  select exists (
           select 1 from public.push_sends s
            where s.status = 'queued'
              and now() >= (s.send_on + time '19:00') at time zone 'Asia/Kolkata'
              and now() <  s.send_before
              and (s.claimed_at is null or s.claimed_at < now() - interval '5 minutes'))
      or exists (
           select 1 from public.push_tests t
            where t.status = 'queued'
              and now() < t.send_before
              and (t.claimed_at is null or t.claimed_at < now() - interval '5 minutes'))
      -- (0147) Community C3-2.
      or exists (
           select 1 from public.community_push_queue q
            where q.status = 'queued' and now() >= q.due_at
              and public.community_push_is_due(q, now()));
$$;

revoke all on function public.pv_push_any_due() from public, anon, authenticated;
grant execute on function public.pv_push_any_due() to service_role;

revoke all on function public.community_push_is_due(public.community_push_queue, timestamptz) from public, anon, authenticated;
revoke all on function public.community_push_text(public.community_push_queue) from public, anon, authenticated;

-- 11) What the phone calls ----------------------------------------------

-- Her switches, whether she has been asked, and her muted posts.
--   moderation is null for a member: the switch is not drawn at all.
--   asked: a 'replies' row exists, so the sheet after her first post is
--   never shown again, on any phone (C8, P0-1).
create or replace function public.community_alerts_get()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  v_mod boolean;
begin
  if me is null then return jsonb_build_object('signed_in', false); end if;
  v_mod := exists (select 1 from public.community_moderators where user_id = me);
  return jsonb_build_object(
    'signed_in', true,
    'replies', coalesce((select allowed from public.community_push_consent
                          where user_id = me and kind = 'replies'), false),
    'asked', exists (select 1 from public.community_push_consent
                      where user_id = me and kind = 'replies'),
    'bookings', coalesce((select allowed from public.community_push_consent
                           where user_id = me and kind = 'bookings'), true),
    'moderation', case when v_mod then coalesce((select allowed from public.community_push_consent
                                                  where user_id = me and kind = 'moderation'), true) end,
    'muted', coalesce((
      select jsonb_agg(jsonb_build_object(
               'post_id', p.id, 'title', p.title,
               'room', (select r.title from public.community_rooms r where r.id = p.room_id),
               'mine', p.user_id = me)
             order by m.created_at desc)
        from public.community_post_mutes m
        join public.community_posts p on p.id = m.post_id
       where m.user_id = me and p.deleted_at is null), '[]'::jsonb));
end $$;

-- One switch. A moderator switch for a member is refused, not stored.
create or replace function public.community_alerts_set(p_kind text, p_on boolean)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
begin
  if me is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  if p_kind not in ('replies', 'bookings', 'moderation') or p_on is null then
    return jsonb_build_object('ok', false, 'reason', 'kind');
  end if;
  if p_kind = 'moderation' and not exists (select 1 from public.community_moderators where user_id = me) then
    return jsonb_build_object('ok', false, 'reason', 'not_mod');
  end if;
  insert into public.community_push_consent (user_id, kind, allowed, decided_at)
  values (me, p_kind, p_on, now())
  on conflict (user_id, kind) do update set allowed = excluded.allowed, decided_at = excluded.decided_at;
  return jsonb_build_object('ok', true);
end $$;

-- "Turn off replies for this post", and back on. Any post she can see; the
-- menu offers it on her own posts and the ones she replied to.
create or replace function public.community_post_mute(p_post text, p_on boolean)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  p  public.community_posts;
begin
  if me is null then return jsonb_build_object('ok', false, 'reason', 'signed_out'); end if;
  if p_on then
    select * into p from public.community_posts where id = p_post;
    if p.id is null or not (p.user_id = me or public.community_can_see(p)) then
      return jsonb_build_object('ok', false, 'reason', 'not_found');
    end if;
    insert into public.community_post_mutes (user_id, post_id) values (me, p_post)
    on conflict do nothing;
  else
    delete from public.community_post_mutes where user_id = me and post_id = p_post;
  end if;
  return jsonb_build_object('ok', true, 'muted', p_on);
end $$;

revoke all on function public.community_alerts_get() from public, anon;
revoke all on function public.community_alerts_set(text, boolean) from public, anon;
revoke all on function public.community_post_mute(text, boolean) from public, anon;
grant execute on function public.community_alerts_get() to authenticated;
grant execute on function public.community_alerts_set(text, boolean) to authenticated;
grant execute on function public.community_post_mute(text, boolean) to authenticated;

-- =====================================================================
-- USEFUL COMMANDS (SQL editor)
-- =====================================================================
--   select kind, status, error, n, overnight, ring_day, due_at, sent_at
--     from public.community_push_queue order by created_at desc limit 20;
--   select kind, status, error, count(*) from public.community_push_queue
--    where created_at > now() - interval '1 day' group by 1, 2, 3;
--   select * from public.community_push_consent where user_id = '<uid>';
-- Make someone a moderator (and so a "Moderation" alert receiver):
--   insert into public.community_moderators (user_id) values ('<uid>');
-- Verify: supabase/seed/verify_community_alerts.sql
-- =====================================================================
