-- =====================================================================
-- verify_community_alerts.sql -- prove 0147 (Community C3-2, reply
--                                alerts) against the real tables.
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0146 and 0147, paste the whole file into the
-- Supabase SQL editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls everything back: the five test
-- accounts, their posts, replies, bookings, devices and queue rows.
--
-- SELF-SUFFICIENT: it makes its own accounts, posts, slot and bookings,
-- so it runs on an empty community. Nothing is sent: pv_push_due is
-- called inside this transaction and its claims roll back with it.
--
-- Every trigger in 0147 swallows its own errors (an alert must never
-- block the write it follows). So each check below COUNTS THE ROWS a
-- trigger should have written: a swallowed failure shows up as 0.
--
-- The "done when" of the plan, as checks:
--   one reply rings once ........ 6
--   three combine ............... 7, 8
--   a muted post is silent ...... 10
--   a moved session rings everyone booked ... 13, 14
--   a crisis post reaches moderators ........ 16, 17
-- =====================================================================

do $$
declare
  a uuid := gen_random_uuid();  -- author
  b uuid := gen_random_uuid();  -- replier
  m uuid := gen_random_uuid();  -- moderator
  l uuid := gen_random_uuid();  -- booked, after a loss
  o uuid := gen_random_uuid();  -- booked, bookings switched off
  tag    text := substr(md5(random()::text), 1, 10);
  v_room text;
  p1 text := 'zzva1' || tag;  p2 text := 'zzva2' || tag;
  p3 text := 'zzva3' || tag;  p4 text := 'zzva4' || tag;
  p5 text := 'zzva5' || tag;
  v_sess text := 'zzvs' || tag;
  v_slot text;
  v_row  public.community_push_queue;
  v_n    int;
  v_txt  record;
  v_out  text;
  v_ids  text[];
  v_rule text[];
  v_ok   boolean;
  v_report text := '';
  v_pass int := 0;
  v_fail int := 0;
begin
  -- -- Setup: five accounts, an open room, posts by A ----------------------
  insert into auth.users (id, email, aud, role, created_at)
  select x, 'zzverify-' || tag || '-' || i || '@example.invalid', 'authenticated', 'authenticated', now()
    from unnest(array[a, b, m, l, o]) with ordinality as t(x, i);
  insert into public.community_profiles (user_id, pseudonym, rules_accepted_at)
  select x, 'zzv' || i || tag, now()
    from unnest(array[a, b, m]) with ordinality as t(x, i);
  insert into public.community_moderators (user_id) values (m);

  select r.id into v_room from public.community_rooms r where r.kind = 'room' order by r.id limit 1;
  if v_room is null then
    raise exception 'VERIFY 0147: needs one open room (0121 seeds the rooms).';
  end if;
  insert into public.community_posts (id, room_id, user_id, identity, title)
  select pid, v_room, a, 'anon', 'verify 0147, rolled back'
    from unnest(array[p1, p2, p3, p4]) pid;

  -- 1. The pieces exist.
  if to_regclass('public.community_push_queue') is not null
     and to_regclass('public.community_push_consent') is not null
     and to_regclass('public.community_post_mutes') is not null then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL a 0147 table is missing'; end if;

  select count(*) into v_n from pg_trigger
   where not tgisinternal and tgname in ('community_comments_reply_alert', 'community_posts_moved_alert',
                                         'community_posts_crisis_alert', 'community_comments_crisis_alert');
  if v_n = 4 then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL %s of 4 triggers', v_n); end if;

  -- 2. Nothing for the app but its three doors.
  if not has_function_privilege('authenticated', 'public.community_push_due(int)', 'execute')
     and not has_function_privilege('authenticated', 'public.community_push_enqueue(uuid,text,text,text)', 'execute')
     and has_function_privilege('authenticated', 'public.community_alerts_set(text,boolean)', 'execute')
     and not has_function_privilege('anon', 'public.community_alerts_get()', 'execute') then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL grants are wrong'; end if;

  -- 3. The sender's branch is in: pv_push_due calls community_push_due, and
  -- B5's campaign channel survived the rewrite.
  if pg_get_functiondef('public.pv_push_due(int)'::regprocedure) like '%community_push_due(n)%'
     and pg_get_functiondef('public.pv_push_due(int)'::regprocedure) like '%offers_news%'
     and pg_get_functiondef('public.pv_push_mark(text,uuid,text,int,text,text[])'::regprocedure) like '%community_push_queue%'
     and public.pv_push_link_needs('community_post') = 2 then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL pv_push_due / pv_push_mark / link_needs lack the community branch'; end if;

  -- 4. Replies are OFF until she says yes (C8): B replies, nothing queues.
  insert into public.community_comments (id, post_id, user_id, identity, body)
  values ('zzvc0' || tag, p1, b, 'anon', 'verify 0147');
  select count(*) into v_n from public.community_push_queue where user_id = a;
  if v_n = 0 then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL %s alert(s) before she said yes', v_n); end if;

  -- 5. She says yes, through the app's own door.
  perform set_config('request.jwt.claims', json_build_object('sub', a, 'role', 'authenticated')::text, true);
  perform public.community_alerts_set('replies', true);
  if (public.community_alerts_get()->>'replies')::boolean and (public.community_alerts_get()->>'asked')::boolean
     and public.community_alerts_get()->'moderation' = 'null'::jsonb then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL alerts_get after yes: ' || public.community_alerts_get()::text; end if;
  perform set_config('request.jwt.claims', '', true);

  -- 6. One reply rings once: one row, n = 1, 3 minutes out, the neutral words.
  insert into public.community_comments (id, post_id, user_id, identity, body)
  values ('zzvc1' || tag, p1, b, 'anon', 'verify 0147');
  select * into v_row from public.community_push_queue where user_id = a and post_id = p1 and status = 'queued';
  select * into v_txt from public.community_push_text(v_row);
  if v_row.id is not null and v_row.n = 1 and v_row.due_at > now() + interval '2 minutes'
     and v_txt.title = 'New reply in ParentVeda Community' and v_txt.body = 'Someone replied to your post.' then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL one reply: row %s n %s text %s / %s', v_row.id, v_row.n, v_txt.title, v_txt.body); end if;

  -- 7. Three combine: two more replies merge into the same row.
  insert into public.community_comments (id, post_id, user_id, identity, body)
  values ('zzvc2' || tag, p1, b, 'anon', 'verify 0147'), ('zzvc3' || tag, p1, b, 'anon', 'verify 0147');
  select count(*) into v_n from public.community_push_queue where user_id = a and post_id = p1;
  select * into v_row from public.community_push_queue where user_id = a and post_id = p1 and status = 'queued';
  select * into v_txt from public.community_push_text(v_row);
  if v_n = 1 and v_row.n = 3 and v_txt.body in ('3 new replies to your post.', '3 new replies to your post overnight.') then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL three combine: %s row(s), n %s, "%s"', v_n, v_row.n, v_txt.body); end if;

  -- 8. ...and her own reply on her own post rings nothing.
  insert into public.community_comments (id, post_id, user_id, identity, body)
  values ('zzvcs' || tag, p1, a, 'anon', 'verify 0147');
  if (select n from public.community_push_queue where user_id = a and post_id = p1 and status = 'queued') = 3 then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL her own reply counted as a reply to her'; end if;

  -- 9. A held reply rings only when approved (held -> live), once.
  insert into public.community_comments (id, post_id, user_id, identity, body, status, hold_reason)
  values ('zzvch' || tag, p2, b, 'anon', 'verify 0147', 'held', 'verify');
  select count(*) into v_n from public.community_push_queue where user_id = a and post_id = p2;
  update public.community_comments set status = 'live', hold_reason = null where id = 'zzvch' || tag;
  if v_n = 0 and (select count(*) from public.community_push_queue where user_id = a and post_id = p2) = 1 then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL a held reply rang on insert, or not on approval'; end if;

  -- 10. A muted post is silent: mute p3, B replies, nothing.
  perform set_config('request.jwt.claims', json_build_object('sub', a, 'role', 'authenticated')::text, true);
  perform public.community_post_mute(p3, true);
  v_ok := jsonb_array_length(public.community_alerts_get()->'muted') = 1;
  perform set_config('request.jwt.claims', '', true);
  insert into public.community_comments (id, post_id, user_id, identity, body)
  values ('zzvcm' || tag, p3, b, 'anon', 'verify 0147');
  if v_ok and not exists (select 1 from public.community_push_queue where user_id = a and post_id = p3) then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL a muted post rang (or is not listed as muted)'; end if;

  -- 11. 3 a day (C4): p1 and p2 hold two; p4 is the third; a fifth post's
  -- reply is Activity only. p5 is A's, made now.
  insert into public.community_comments (id, post_id, user_id, identity, body)
  values ('zzvc4' || tag, p4, b, 'anon', 'verify 0147');
  insert into public.community_posts (id, room_id, user_id, identity, title)
  values (p5, v_room, a, 'anon', 'verify 0147, rolled back');
  v_out := public.community_push_enqueue(a, 'reply', p5);
  select count(*) into v_n from public.community_push_queue where user_id = a and kind = 'reply';
  if v_out = 'capped' and v_n = 3 then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL the cap: 4th said %s, %s rows', v_out, v_n); end if;

  -- 12. THE RULE AGREES: every test reply the queue counted for A is in her
  -- Replies to you, and nothing else of the test's is.
  perform set_config('request.jwt.claims', json_build_object('sub', a, 'role', 'authenticated')::text, true);
  select coalesce(array_agg(x->>'comment_id' order by x->>'comment_id'), '{}') into v_ids
    from jsonb_array_elements(public.community_activity(100)) x
   where x->>'post_id' in (p1, p2, p3, p4);
  perform set_config('request.jwt.claims', '', true);
  select coalesce(array_agg(c.id order by c.id), '{}') into v_rule
    from public.community_comments c
    join public.community_posts p on p.id = c.post_id
    left join public.community_comments pc on pc.id = c.parent_id
   where c.post_id in (p1, p2, p3, p4)
     and public.community_replied_to(c, p, pc.user_id, a);
  -- B's seven: zzvc0 (before she said yes: Activity has it, the queue
  -- rightly does not), c1 to c3, the approved held one, the muted one, c4.
  if v_ids = v_rule and cardinality(v_rule) = 7 then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL activity %s vs rule %s', v_ids, v_rule); end if;

  -- 13. A moved session rings everyone booked: A (bookings on by default)
  -- and nobody else. L is after a loss on a pregnancy class; O turned
  -- bookings off. The earnings trigger is paused for the fake slot
  -- (rolled back): it would look for an expert this test does not have.
  v_slot := 'ps_' || v_sess;
  insert into public.booking_slots (id, offering_id, expert_id, starts_utc, duration_min, capacity)
  values (v_slot, 'zzv-offering', 'zzv-expert', now() + interval '3 days', 60, 10);
  update public.profiles set pregnancy_ended_at = now() - interval '5 days', life_stage_at = now() - interval '60 days'
   where id = l;
  insert into public.community_push_consent (user_id, kind, allowed) values (o, 'bookings', false);
  alter table public.booking_bookings disable trigger booking_bookings_earnings_trg;
  insert into public.booking_bookings (id, user_id, offering_id, slot_id, stage, title, starts_utc, duration_min)
  select 'zzvb' || i || tag, x, 'zzv-offering', v_slot, 'pregnancy', 'verify', now() + interval '3 days', 60
    from unnest(array[a, l, o]) with ordinality as t(x, i);
  alter table public.booking_bookings enable trigger booking_bookings_earnings_trg;
  insert into public.community_posts (id, room_id, user_id, identity, author_label, title, body,
                                      status, about_kind, about_id, moved_from)
  values ('zzvtn' || tag, v_room, null, 'team', '', 'Session moved: verify', 'verify 0147',
          'live', 'session', v_sess, now() + interval '2 days');
  select count(*) into v_n from public.community_push_queue where kind = 'booking' and post_id = 'zzvtn' || tag;
  select * into v_row from public.community_push_queue where kind = 'booking' and post_id = 'zzvtn' || tag and user_id = a;
  if v_n = 1 and v_row.booking_id = 'zzvb1' || tag then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL moved session: %s row(s) (expected 1, A only), booking %s', v_n, v_row.booking_id); end if;

  -- 14. ...with its words, and not delayed.
  select * into v_txt from public.community_push_text(v_row);
  if v_txt.title = 'A session you booked has moved' and v_txt.body = 'Tap to see the new time.'
     and v_row.due_at <= now() then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL moved text: %s / %s', v_txt.title, v_txt.body); end if;

  -- 15. Quiet hours (C4): a reply is not due at 22:00 IST, is at 10:00;
  -- the moved row likewise. Asked of the helper at fixed times, so the
  -- check does not depend on when you run it.
  select * into v_row from public.community_push_queue where user_id = a and post_id = p1 and status = 'queued';
  if not public.community_push_is_due(v_row, ((current_date + 1) + time '22:00') at time zone 'Asia/Kolkata')
     and not public.community_push_is_due(v_row, ((current_date + 1) + time '07:59') at time zone 'Asia/Kolkata')
     and public.community_quiet_at(((current_date + 1) + time '21:00') at time zone 'Asia/Kolkata')
     and not public.community_quiet_at(((current_date + 1) + time '08:00') at time zone 'Asia/Kolkata')
     and public.community_ring_day(((current_date) + time '21:30') at time zone 'Asia/Kolkata') = current_date + 1 then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || E'\nFAIL quiet hours'; end if;

  -- 16. A crisis post reaches moderators: M, and not A or B.
  insert into public.community_posts (id, room_id, user_id, identity, title, crisis)
  values ('zzvcr' || tag, v_room, b, 'anon', 'verify 0147, rolled back', true);
  select count(*) into v_n from public.community_push_queue where kind = 'moderation' and post_id = 'zzvcr' || tag;
  select * into v_row from public.community_push_queue where kind = 'moderation' and post_id = 'zzvcr' || tag and user_id = m;
  if v_row.id is not null and not exists (
       select 1 from public.community_push_queue where kind = 'moderation' and post_id = 'zzvcr' || tag and user_id in (a, b)) then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL crisis: moderator row %s, %s row(s) in all', v_row.id, v_n); end if;

  -- 17. ...at any hour, on the Moderation channel, high priority, through
  -- the real pv_push_due (M has a device on a linkVersion 2 build).
  insert into public.push_devices (user_id, device_id, token, platform, link_version)
  values (m, 'zzvdev' || tag, 'zzverify-token-' || tag || '-0000000000', 'android', 2);
  v_ok := public.community_push_is_due(v_row, ((current_date + 1) + time '03:00') at time zone 'Asia/Kolkata');
  select count(*) into v_n from public.pv_push_due(500) d
   where d.queue = 'community_push_queue' and d.row_id = v_row.id
     and d.channel = 'community_moderation' and d.priority = 'high'
     and d.title = 'A post may need a moderator now' and d.body = 'Open Moderation to see it.'
     and d.data->>'link_kind' = 'community_moderation' and d.collapse_key = 'community-moderation'
     and cardinality(d.tokens) = 1;
  if v_ok and v_n = 1 then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL crisis through pv_push_due: due at 03:00 %s, %s matching row(s)', v_ok, v_n); end if;

  -- 18. pv_push_mark takes it back: sent, once.
  perform public.pv_push_mark('community_push_queue', v_row.id, 'sent', 1);
  perform public.pv_push_mark('community_push_queue', v_row.id, 'failed', 0, 'late');
  select * into v_row from public.community_push_queue where id = v_row.id;
  if v_row.status = 'sent' and v_row.sent_at is not null and v_row.claimed_at is null then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL mark: %s', v_row.status); end if;

  -- 19. A crisis reply flagged later (report at risk) also reaches M, once.
  update public.community_comments set crisis = true where id = 'zzvc4' || tag;
  update public.community_comments set crisis = true where id = 'zzvc4' || tag;
  select count(*) into v_n from public.community_push_queue where kind = 'moderation' and post_id = p4 and user_id = m;
  if v_n = 1 then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL a reply flagged at risk: %s row(s)', v_n); end if;

  -- 20. A switch turned off after queuing still stops the alert: A turns
  -- replies off; her waiting rows end as 'off' when the sender looks.
  insert into public.community_push_consent (user_id, kind, allowed) values (a, 'replies', false)
  on conflict (user_id, kind) do update set allowed = false;
  update public.community_push_queue set due_at = now() - interval '1 minute' where user_id = a and kind = 'reply';
  perform count(*) from public.community_push_due(500);
  select count(*) into v_n from public.community_push_queue where user_id = a and kind = 'reply' and status = 'queued';
  if v_n = 0 and exists (select 1 from public.community_push_queue where user_id = a and kind = 'reply' and error = 'off') then v_pass := v_pass + 1;
  else v_fail := v_fail + 1; v_report := v_report || format(E'\nFAIL switch off after queuing: %s still queued', v_n); end if;

  raise exception E'VERIFY 0147: % passed, % failed.%\n(Everything above is rolled back.)',
    v_pass, v_fail, v_report;
end $$;
