-- =====================================================================
-- verify_community_live.sql -- prove 0145 (Community C3-1, the live
--                              thread) against the real tables.
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0145, paste the whole file into the Supabase SQL
-- editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls everything back: the test
-- replies and the broadcast rows they wrote.
--
-- Writes its own post as the OLDEST account, in an open room, so it
-- runs on an empty community too. All of it rolls back.
-- This proves the SQL half. The phone half is the two-phone walk: a
-- reply from phone B shows the pill on phone A.
-- =====================================================================

do $$
declare
  v_post   text;
  v_owner  uuid;
  v_cid    text := 'zzverifylive' || substr(md5(random()::text), 1, 12);
  v_hid    text := 'zzverifyheld' || substr(md5(random()::text), 1, 12);
  v_n      int;
  v_keys   text;
  v_report text := '';
  v_pass   int := 0;
  v_fail   int := 0;

  procedure_ok boolean;
begin
  -- A post of its own, in an open room, written as the oldest account.
  -- Rolled back with everything else, so the live database keeps no trace.
  select u.id into v_owner from auth.users u order by u.created_at limit 1;
  select r.id into v_post from public.community_rooms r where r.kind = 'room' order by r.id limit 1;
  if v_owner is null or v_post is null then
    raise exception 'VERIFY 0145: needs one account and one open room (0121 seeds the rooms).';
  end if;
  insert into public.community_posts (id, room_id, user_id, identity, title)
  values ('zzverifypost' || substr(md5(random()::text), 1, 12), v_post, v_owner, 'anon', 'verify 0145, rolled back')
  returning id into v_post;

  -- 0. Realtime stores broadcasts in realtime.messages, split into one
  -- partition per day, which the Realtime SERVER creates once something
  -- has connected to it. A project nothing has connected to yet has none,
  -- every send fails silently, and checks 5 and 7 would fail for that
  -- reason alone. Say so instead (found 2026-10-30, diagnose_realtime_send.sql).
  if not exists (select 1 from pg_inherits i where i.inhparent = 'realtime.messages'::regclass) then
    raise exception E'VERIFY 0145: Realtime has not woken up on this project yet (realtime.messages has no daily partitions).\nOpen Dashboard > Realtime > Inspector, join any channel (for example post:test), wait 10 seconds, then run this again.';
  end if;

  -- 1. The pieces exist.
  procedure_ok := to_regprocedure('realtime.send(jsonb,text,text,boolean)') is not null;
  if procedure_ok then v_pass := v_pass + 1; else v_fail := v_fail + 1;
    v_report := v_report || E'\nFAIL realtime.send(jsonb,text,text,boolean) is missing on this project'; end if;

  if exists (select 1 from pg_policies where schemaname = 'realtime' and tablename = 'messages'
              and policyname = 'community_post_listen' and cmd = 'SELECT') then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL policy community_post_listen missing'; end if;

  if not exists (select 1 from pg_policies where schemaname = 'realtime' and tablename = 'messages'
              and cmd in ('INSERT', 'ALL') and qual ilike '%community%') then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL a phone may SEND on community topics'; end if;

  if exists (select 1 from pg_trigger where tgname = 'community_comments_broadcast' and not tgisinternal) then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL trigger community_comments_broadcast missing'; end if;

  -- 2. A live reply sends one signal on post:<id>, carrying the post id and no user id.
  insert into public.community_comments (id, post_id, user_id, identity, body)
  values (v_cid, v_post, v_owner, 'anon', 'verify 0145, rolled back');

  select count(*), string_agg(k, ',') into v_n, v_keys
    from realtime.messages m, lateral jsonb_object_keys(m.payload) k
   where m.topic = 'post:' || v_post and m.event = 'reply'
     and m.inserted_at > now() - interval '1 minute';
  if v_n >= 1 and v_keys like '%post_id%' and v_keys not like '%user%' then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL live reply: %s key(s) on the topic: %s', v_n, coalesce(v_keys, 'none')); end if;

  -- 3. A held reply says nothing on insert...
  select count(*) into v_n from realtime.messages m where m.topic = 'post:' || v_post and m.event = 'reply';
  insert into public.community_comments (id, post_id, user_id, identity, body, status, hold_reason)
  values (v_hid, v_post, v_owner, 'anon', 'verify 0145 held, rolled back', 'held', 'verify');
  if (select count(*) from realtime.messages m where m.topic = 'post:' || v_post and m.event = 'reply') = v_n then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL a held reply broadcast on insert'; end if;

  -- 4. ...and speaks once a moderator approves it.
  update public.community_comments set status = 'live', hold_reason = null where id = v_hid;
  if (select count(*) from realtime.messages m where m.topic = 'post:' || v_post and m.event = 'reply') = v_n + 1 then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL approving a held reply sent no signal'; end if;

  -- 5. Who may listen: the post's author yes, a made-up topic no, nobody signed in no.
  perform set_config('request.jwt.claims', json_build_object('sub', v_owner, 'role', 'authenticated')::text, true);
  if public.community_can_listen('post:' || v_post) then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL the author may not listen to her own post'; end if;
  if not public.community_can_listen('post:zz-no-such-post') and not public.community_can_listen('room:' || v_post) then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL a made-up topic is allowed'; end if;
  perform set_config('request.jwt.claims', '', true);
  -- Signed out is shut at the door, not inside the function: anon cannot
  -- run it, and the policy is `to authenticated`.
  if not has_function_privilege('anon', 'public.community_can_listen(text)', 'execute') then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL a signed-out caller may listen'; end if;

  raise exception E'VERIFY 0145: % passed, % failed (post %).%\n(Everything above is rolled back.)',
    v_pass, v_fail, v_post, v_report;
end $$;
