-- =====================================================================
-- verify_push_send.sql -- prove 0144 (6b B4: the sender's queue functions)
--                         against the real tables.
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0144, paste the whole file into the Supabase SQL
-- editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls everything back: the test
-- campaigns, bookings, tests, the borrowed user's device row, and every
-- claim pv_push_due made on real rows. pg_net's queued calls roll back too,
-- so nothing is sent.
--
-- Borrows the OLDEST profile. Bookings are dated 2000-01-0x (19:00 long
-- past) or 2999-01-01 (19:00 not yet), with send_before set by hand, so
-- every check passes at any hour.
-- This proves the SQL half. The FCM half is proved by
-- pv_campaign_test reaching your phone (docs/NOTIFICATIONS-6B-PLAN.md,
-- "As built: B4").
-- =====================================================================

do $$
declare
  v_u     uuid;
  v_email text;
  v_tok   text := 'zz-verify-b4-token-' || md5(random()::text);
  v_a     uuid;   -- due
  v_b     uuid;   -- before 19:00
  v_c     uuid;   -- past the cutoff
  v_d     uuid;   -- released, then a stale claim
  v_e     uuid;   -- no device left
  v_t     uuid;   -- a test
  v_t2    uuid;   -- a stale test
  n       int;
  s       text;
  r       text := '';
  pass    int := 0;
  fail    int := 0;
  x       record;
begin
  select p.id, u.email into v_u, v_email
    from public.profiles p
    join auth.users u on u.id = p.id
   where u.email is not null
   order by u.created_at
   limit 1;
  if v_u is null then
    raise exception E'\n\n=== PUSH SEND VERIFICATION (0144) ===\n\nSKIPPED: needs one profile with an email.\n';
  end if;

  create temp table _r (seq serial, label text, ok boolean, got text) on commit drop;
  create function pg_temp.expect(p_label text, p_got text, p_want text)
  returns void language sql as $f$
    insert into pg_temp._r (label, ok, got)
    values (p_label, p_got is not distinct from p_want, p_got);
  $f$;

  -- ---- 1. shape ------------------------------------------------------
  select count(*) into n from information_schema.columns
   where table_schema = 'public' and table_name = 'push_sends' and column_name = 'claimed_at';
  perform pg_temp.expect('01 push_sends has claimed_at', n::text, '1');
  select c.relrowsecurity::text into s from pg_class c
   where c.oid = 'public.push_tests'::regclass;
  perform pg_temp.expect('02 push_tests has RLS on', s, 'true');

  -- ---- fixtures ------------------------------------------------------
  insert into public.push_devices (user_id, device_id, token, platform, link_version)
  values (v_u, 'zz-verify-b4-device', v_tok, 'android', 1)
  on conflict (user_id, device_id) do update set token = excluded.token, link_version = 1;

  insert into public.push_campaigns
    (id, kind, title, body, link_kind, link_id, stages, starts_on, ends_on, status, approved_at)
  select 'zz-verify-b4-' || k, 'offer', 'A calm class', 'Tap to see it.', 'read', 'zz-verify',
         array['pregnancy'], date '2000-01-01', date '2999-12-31', 'approved', now()
    from unnest(array['a', 'b', 'c', 'd', 'e']) k;

  insert into public.push_sends (campaign_id, user_id, send_on, send_before)
  values ('zz-verify-b4-a', v_u, date '2000-01-01', now() + interval '1 hour')
  returning id into v_a;
  insert into public.push_sends (campaign_id, user_id, send_on, send_before)
  values ('zz-verify-b4-b', v_u, date '2999-01-01', timestamptz '2999-01-01 15:30+00')
  returning id into v_b;
  insert into public.push_sends (campaign_id, user_id, send_on, send_before)
  values ('zz-verify-b4-c', v_u, date '2000-01-02', now() - interval '1 minute')
  returning id into v_c;

  -- ---- 2. the push_sends branch ---------------------------------------
  create temp table _d1 on commit drop as select * from public.pv_push_due(500);

  select count(*) into n from _d1 where row_id = v_a and queue = 'push_sends';
  perform pg_temp.expect('03 a booking past 19:00 and before its cutoff is due', n::text, '1');
  select count(*) into n from _d1 where row_id = v_b;
  perform pg_temp.expect('04 a booking before 19:00 is not due', n::text, '0');
  select status into s from public.push_sends where id = v_b;
  perform pg_temp.expect('05 ...and stays queued', s, 'queued');
  select status || '/' || error into s from public.push_sends where id = v_c;
  perform pg_temp.expect('06 past the cutoff it is skipped, past_cutoff', s, 'skipped/past_cutoff');
  select count(*) into n from _d1 where row_id = v_c;
  perform pg_temp.expect('07 ...and never handed out', n::text, '0');

  select (v_tok = any (tokens))::text into s from _d1 where row_id = v_a;
  perform pg_temp.expect('08 her token comes with the row', s, 'true');
  select data->>'row_id' into s from _d1 where row_id = v_a;
  perform pg_temp.expect('09 the booking id is in the push data (B5 tap)', s, v_a::text);
  select data->>'queue' || '|' || (data->>'link_kind') || '|' || (data->>'link_id') into s
    from _d1 where row_id = v_a;
  perform pg_temp.expect('10 data carries queue and the link', s, 'push_sends|read|zz-verify');
  select title || '|' || body || '|' || collapse_key || '|' || priority into s
    from _d1 where row_id = v_a;
  perform pg_temp.expect('11 text, collapse key and priority',
    s, 'A calm class|Tap to see it.|campaign-zz-verify-b4-a|normal');

  select (claimed_at is not null)::text into s from public.push_sends where id = v_a;
  perform pg_temp.expect('12 a handed-out row is claimed', s, 'true');
  select count(*) into n from public.pv_push_due(500) where row_id = v_a;
  perform pg_temp.expect('13 a claimed row is not handed out twice', n::text, '0');

  -- ---- 3. pv_push_mark -------------------------------------------------
  perform public.pv_push_mark('push_sends', v_a, 'sent', 1, null, '{}');
  select status || '/' || devices_sent || '/' || (sent_at is not null) || '/' || (claimed_at is null)
    into s from public.push_sends where id = v_a;
  perform pg_temp.expect('14 sent fills status, devices, sent_at, frees the claim', s, 'sent/1/true/true');
  perform public.pv_push_mark('push_sends', v_a, 'failed', 0, 'late', '{}');
  select status into s from public.push_sends where id = v_a;
  perform pg_temp.expect('15 a late mark never overwrites a finished row', s, 'sent');
  perform public.pv_push_mark('push_sends', v_c, 'sent', 1, null, '{}');
  select status into s from public.push_sends where id = v_c;
  perform pg_temp.expect('16 ...nor a cutoff that came first', s, 'skipped');

  insert into public.push_sends (campaign_id, user_id, send_on, send_before)
  values ('zz-verify-b4-d', v_u, date '2000-01-03', now() + interval '1 hour')
  returning id into v_d;
  select count(*) into n from public.pv_push_due(500) where row_id = v_d;
  perform pg_temp.expect('17 a new due row is handed out', n::text, '1');
  perform public.pv_push_mark('push_sends', v_d, 'queued', 0, 'fcm 503', '{}');
  select status || '/' || (claimed_at is null) into s from public.push_sends where id = v_d;
  perform pg_temp.expect('18 a short failure goes back to queued, unclaimed', s, 'queued/true');
  select count(*) into n from public.pv_push_due(500) where row_id = v_d;
  perform pg_temp.expect('19 ...and the next run takes it again', n::text, '1');
  update public.push_sends set claimed_at = now() - interval '6 minutes' where id = v_d;
  select count(*) into n from public.pv_push_due(500) where row_id = v_d;
  perform pg_temp.expect('20 a claim older than 5 minutes (a dead sender) lapses', n::text, '1');

  begin
    perform public.pv_push_mark('push_sends', v_d, 'delivered', 0, null, '{}');
    s := 'accepted';
  exception when others then s := 'refused';
  end;
  perform pg_temp.expect('21 an unknown status is refused', s, 'refused');
  begin
    perform public.pv_push_mark('nope', v_d, 'sent', 0, null, '{}');
    s := 'accepted';
  exception when others then s := 'refused';
  end;
  perform pg_temp.expect('22 an unknown queue is refused', s, 'refused');

  -- ---- 4. pv_campaign_test and the push_tests branch -------------------
  begin
    perform public.pv_campaign_test('zz-verify-b4-a', 'zz-nobody@invalid.example');
    s := 'accepted';
  exception when others then s := 'refused';
  end;
  perform pg_temp.expect('23 a test to an unknown email is refused', s, 'refused');
  begin
    perform public.pv_campaign_test('zz-no-such-campaign', v_email);
    s := 'accepted';
  exception when others then s := 'refused';
  end;
  perform pg_temp.expect('24 a test of an unknown campaign is refused', s, 'refused');

  v_t := public.pv_campaign_test('zz-verify-b4-a', upper(v_email));
  select status || '/' || user_id::text into s from public.push_tests where id = v_t;
  perform pg_temp.expect('25 a test is queued for the named account (email any case)',
    s, 'queued/' || v_u::text);
  create temp table _d2 on commit drop as select * from public.pv_push_due(500);
  select data->>'queue' || '|' || (data->>'row_id') into s from _d2 where row_id = v_t;
  perform pg_temp.expect('26 the test is due at once, in its own queue', s, 'push_tests|' || v_t::text);
  select (v_tok = any (tokens))::text into s from _d2 where row_id = v_t;
  perform pg_temp.expect('27 ...to her own device', s, 'true');
  select count(*) into n from public.push_sends
   where user_id = v_u and campaign_id = 'zz-verify-b4-a';
  perform pg_temp.expect('28 a test books nothing in push_sends', n::text, '1');
  perform public.pv_push_mark('push_tests', v_t, 'sent', 1, null, '{}');
  select status into s from public.push_tests where id = v_t;
  perform pg_temp.expect('29 a test is marked through the same function', s, 'sent');

  insert into public.push_tests (campaign_id, user_id, send_before)
  values ('zz-verify-b4-b', v_u, now() - interval '1 second')
  returning id into v_t2;
  perform public.pv_push_tick();
  select status || '/' || error into s from public.push_tests where id = v_t2;
  perform pg_temp.expect('30 a stale test is ended by the tick, past_cutoff', s, 'skipped/past_cutoff');

  -- ---- 5. dead tokens and no device ------------------------------------
  insert into public.push_sends (campaign_id, user_id, send_on, send_before)
  values ('zz-verify-b4-e', v_u, date '2000-01-04', now() + interval '1 hour')
  returning id into v_e;
  perform public.pv_push_mark('push_sends', v_d, 'skipped', 0, 'no_device', array[v_tok]);
  select count(*) into n from public.push_devices where token = v_tok;
  perform pg_temp.expect('31 an UNREGISTERED token is deleted', n::text, '0');
  -- Only when she has no other device can the no_device rule be seen.
  if not exists (select 1 from public.push_devices where user_id = v_u) then
    perform public.pv_push_due(500);
    select status || '/' || error into s from public.push_sends where id = v_e;
    perform pg_temp.expect('32 a due row with no device left is skipped, no_device',
      s, 'skipped/no_device');
  else
    perform pg_temp.expect('32 no_device (skipped: she has other real devices)', 'skipped', 'skipped');
  end if;

  -- ---- 6. grants, RLS, cron --------------------------------------------
  select count(*) into n
    from unnest(array[
      'public.pv_push_due(int)',
      'public.pv_push_mark(text,uuid,text,int,text,text[])',
      'public.pv_campaign_test(text,text)',
      'public.pv_push_any_due()',
      'public.pv_push_tick()'
    ]) f
    cross join unnest(array['anon', 'authenticated']) ro
   where has_function_privilege(ro, f, 'execute');
  perform pg_temp.expect('33 no B4 function is callable by anon or authenticated', n::text, '0');
  select count(*) into n
    from unnest(array['anon', 'authenticated']) ro
   where has_table_privilege(ro, 'public.push_tests', 'select');
  perform pg_temp.expect('34 the app cannot read push_tests', n::text, '0');
  select count(*) into n
    from unnest(array[
      'public.pv_push_due(int)',
      'public.pv_push_mark(text,uuid,text,int,text,text[])'
    ]) f
   where has_function_privilege('service_role', f, 'execute');
  perform pg_temp.expect('35 the sender (service_role) can call due and mark', n::text, '2');

  select count(*) into n from cron.job
   where jobname = 'push-send-every-minute' and schedule = '* * * * *' and active;
  perform pg_temp.expect('36 the every-minute cron is scheduled', n::text, '1');
  select count(*) into n from cron.job
   where jobname = 'push-send-every-minute' and command like '%pv_push_tick()%';
  perform pg_temp.expect('37 ...and it runs only the tick', n::text, '1');
  select count(*) into n from vault.decrypted_secrets
   where name in ('push_send_url', 'push_send_secret') and coalesce(decrypted_secret, '') <> '';
  perform pg_temp.expect('38 Vault holds push_send_url and push_send_secret', n::text, '2');

  -- ---- the report -----------------------------------------------------
  for x in select * from pg_temp._r order by seq loop
    if x.ok then
      pass := pass + 1;
      r := r || E'\nok    ' || x.label;
    else
      fail := fail + 1;
      r := r || E'\nFAIL  ' || x.label || '  -> got ' || coalesce(x.got, 'null');
    end if;
  end loop;

  raise exception E'\n\n=== PUSH SEND VERIFICATION (0144) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
