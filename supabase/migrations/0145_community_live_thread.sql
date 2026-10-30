-- =============================================================================
--  0145 - Community phase 3, C3-1: the live thread
-- -----------------------------------------------------------------------------
--  docs/COMMUNITY.md "Phase 3: plan and decisions" (C9, C13) and "As built
--  (phase 3) - C3-1". Needs 0121 and 0137. Nothing else depends on it.
--
--  WHAT IT DOES: while a post is open on her phone, a reply from another phone
--  shows as an "N new replies" pill. This file is the server half: a signal
--  that something changed, and a rule for who may hear it.
--
--  WHY BROADCAST AND NOT "SEND ME DATABASE CHANGES" (Postgres Changes):
--  that feature streams the changed ROW to every subscriber the table's RLS
--  admits. Two problems. The app has no table rights on community tables at
--  all (every read is a definer function, 0121), so it would admit nobody;
--  and if we granted them, the row carries user_id, which is exactly what
--  anonymity hides (BACKEND-PATTERNS §16zzd). So the signal carries ONLY the
--  post id, and the phone re-reads the replies through
--  community_comments_list, the same door as always. Blocks, holds, hidden
--  replies and the anonymous face all still apply, because nothing new was
--  opened: the signal says "look again", never "here is the data".
--
--  C13: hung on a TRIGGER. community_comment() and the moderation functions
--  are not rewritten, so none of 0137's lines can be dropped by a copy.
-- =============================================================================

-- -----------------------------------------------------------------------------
--  1. May she listen to a post's topic?
-- -----------------------------------------------------------------------------
-- Realtime checks a private channel's join against SELECT policies on
-- realtime.messages, run as HER (role authenticated). community_can_see is
-- revoked from authenticated (0121), so a policy cannot call it directly. This
-- wrapper is the one thing granted: yes or no, for the post named by the
-- topic, for whoever is asking. It answers nothing she could not learn by
-- opening the post.
create or replace function public.community_can_listen(p_topic text)
returns boolean language sql stable security definer set search_path = '' as $$
  select coalesce(p_topic like 'post:%' and exists (
    select 1 from public.community_posts p
     where p.id = substr(p_topic, 6)
       and public.community_can_see(p)), false)
$$;

revoke all on function public.community_can_listen(text) from public, anon;
grant execute on function public.community_can_listen(text) to authenticated;

-- SELECT only. There is deliberately NO insert policy: a phone cannot send on
-- a post topic, so nobody can fake "new replies" at someone else's thread.
-- Only this database (the trigger below) speaks on these topics.
drop policy if exists community_post_listen on realtime.messages;
create policy community_post_listen on realtime.messages
  for select to authenticated
  using (
    realtime.messages.extension = 'broadcast'
    and public.community_can_listen((select realtime.topic()))
  );

-- -----------------------------------------------------------------------------
--  2. The signal: a reply arrived, or a reply's status changed
-- -----------------------------------------------------------------------------
-- Insert of a live reply, a held reply approved, a reply removed or deleted.
-- A held reply's insert says nothing: no one but her can see it yet.
create or replace function public.community_comment_broadcast()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' and new.status <> 'live' then
    return null;
  end if;
  if tg_op = 'UPDATE'
     and new.status is not distinct from old.status
     and new.deleted_at is not distinct from old.deleted_at then
    return null;
  end if;

  -- ⚠️ THE PAYLOAD IS {post_id} AND NOTHING ELSE. No user id, no author, no
  -- body (test/community_live_thread_test.dart reads this line).
  --
  -- The inner BEGIN ... EXCEPTION is a savepoint. If Realtime is down or
  -- realtime.send is missing, only the signal is rolled back and her reply
  -- still saves. A missed signal costs a pill (pull to refresh still works);
  -- a failed reply would cost her words. The side channel never blocks the
  -- main write.
  begin
    perform realtime.send(
      jsonb_build_object('post_id', new.post_id),
      'reply',
      'post:' || new.post_id,
      true);
  exception when others then
    null;
  end;
  return null;
end $$;

revoke all on function public.community_comment_broadcast() from public, anon, authenticated;

drop trigger if exists community_comments_broadcast on public.community_comments;
create trigger community_comments_broadcast
  after insert or update of status, deleted_at on public.community_comments
  for each row execute function public.community_comment_broadcast();
