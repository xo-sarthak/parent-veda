-- =====================================================================
-- verify_push_campaigns.sql -- prove 0143 (6b B3: campaigns, bookings,
--                              every rule) against the real tables.
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0143, paste the whole file into the Supabase SQL
-- editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls everything back: the test
-- campaigns, the bookings, and every change to the borrowed user's rows
-- (profile, consent, device, audience, children).
--
-- Borrows the OLDEST profile that is not in the 10% holdout. Works on
-- "tomorrow or later" (and at least 8 days after that user signed up), so
-- it passes at any hour, even after tonight's 21:00 cutoff.
-- Every rule in pv_push_check is walked in order, then the enqueue, the
-- tie-break, the weekly cap, cancel, the text checks, the grants, RLS and
-- the cron job.
-- =====================================================================

do $$
declare
  v_u       uuid;
  v_partner uuid;
  v_other   uuid;
  v_hold    uuid;
  v_created date;
  v_day     date;
  v_con     text;
  n         int;
  r         text := '';
  pass      int := 0;
  fail      int := 0;
  x         record;
begin
  select p.id, p.partner_id, (u.created_at at time zone 'Asia/Kolkata')::date
    into v_u, v_partner, v_created
    from public.profiles p
    join auth.users u on u.id = p.id
   where not public.pv_push_holdout(p.id)
   order by u.created_at
   limit 1;
  if v_u is null then
    raise exception E'\n\n=== PUSH CAMPAIGNS VERIFICATION (0143) ===\n\nSKIPPED: needs one profile outside the holdout.\n';
  end if;
  v_day := greatest((now() at time zone 'Asia/Kolkata')::date + 1, v_created + 8);

  -- The report: one row per check.
  create temp table _r (seq serial, label text, ok boolean, got text) on commit drop;
  create function pg_temp.expect(p_label text, p_got text, p_want text)
  returns void language sql as $f$
    insert into pg_temp._r (label, ok, got)
    values (p_label, p_got is not distinct from p_want, p_got);
  $f$;
  -- Why this person would not get this campaign on this evening.
  create function pg_temp.why(p_c text, p_on date, p_user uuid)
  returns text language sql as $f$
    select coalesce(
      (select coalesce(c.reason, 'eligible')
         from public.pv_push_check(p_on, p_c) c
        where c.user_id = p_user),
      'no_row');
  $f$;

  -- ---- fixtures (rolled back) ---------------------------------------
  update public.push_campaigns set status = 'cancelled' where status = 'approved';
  delete from public.push_sends    where user_id = v_u;
  delete from public.push_consent  where user_id = v_u;
  delete from public.push_devices  where user_id = v_u;
  delete from public.push_audience where user_id = v_u;
  update public.profiles
     set life_stage = 'pregnancy', life_stage_at = now(),
         pregnancy_ended_at = null, due_date = v_day + 140      -- week 20
   where id = v_u;
  update public.children
     set removed_at = now(), updated_at = now()
   where (user_id = v_u or user_id = v_partner) and removed_at is null;

  perform public.pv_campaign_create('zz-verify-a', 'offer',
    'A calm class this Sunday', 'Tap to see the class and book a seat.',
    'course', 'zz-course', array['pregnancy'], v_created, v_day + 30);
  perform public.pv_campaign_approve('zz-verify-a');

  -- ---- 1. the rules, in order ---------------------------------------
  perform pg_temp.expect('1  no consent yet', pg_temp.why('zz-verify-a', v_day, v_u), 'no_consent');
  insert into public.push_consent (user_id, stage, granted, decided_at, source)
  values (v_u, 'pregnancy', true, now(), 'messages_switch');

  perform pg_temp.expect('2  no device', pg_temp.why('zz-verify-a', v_day, v_u), 'no_device');
  insert into public.push_devices (user_id, device_id, token, platform, link_version)
  values (v_u, 'zz-verify-device', 'zz-verify-token-0000000000000000', 'android', 1);

  perform pg_temp.expect('3  new_user in her first 7 days', pg_temp.why('zz-verify-a', v_created + 2, v_u), 'new_user');
  perform pg_temp.expect('4  every rule passes', pg_temp.why('zz-verify-a', v_day, v_u), 'eligible');

  update public.profiles
     set pregnancy_ended_at = now() - interval '1 day', life_stage_at = now() - interval '2 days'
   where id = v_u;
  perform pg_temp.expect('5  pregnancy_loss (0112)', pg_temp.why('zz-verify-a', v_day, v_u), 'pregnancy_loss');
  update public.profiles set life_stage_at = now() where id = v_u;
  perform pg_temp.expect('6  a pregnancy after the loss speaks again', pg_temp.why('zz-verify-a', v_day, v_u), 'eligible');
  update public.profiles set pregnancy_ended_at = null where id = v_u;

  insert into public.push_audience (user_id, busy_evenings, quiet) values (v_u, '{}', true);
  perform pg_temp.expect('7  phone_quiet', pg_temp.why('zz-verify-a', v_day, v_u), 'phone_quiet');
  update public.push_audience set quiet = false where user_id = v_u;

  insert into public.children (id, user_id, name, dob)
  values ('zz-verify-baby1', v_u, 'Verify', v_day - 3);
  perform pg_temp.expect('8  new_baby, born 3 days ago', pg_temp.why('zz-verify-a', v_day, v_u), 'new_baby');
  update public.children set removed_at = now(), updated_at = now() where id = 'zz-verify-baby1';
  perform pg_temp.expect('9  a removed child counts for nothing', pg_temp.why('zz-verify-a', v_day, v_u), 'eligible');

  perform public.pv_campaign_create('zz-verify-wk', 'offer',
    'For the last stretch', 'A class for the final weeks. Tap to see it.',
    'course', 'zz-course', array['pregnancy'], v_created, v_day + 30,
    p_week_from => 30, p_week_to => 40);
  perform pg_temp.expect('10 not_targeted, week 20 vs 30-40 (a draft is judged too)', pg_temp.why('zz-verify-wk', v_day, v_u), 'not_targeted');
  perform public.pv_campaign_create('zz-verify-wk2', 'offer',
    'For the middle weeks', 'A class for the middle of pregnancy. Tap to see it.',
    'course', 'zz-course', array['pregnancy'], v_created, v_day + 30,
    p_week_from => 18, p_week_to => 22);
  perform pg_temp.expect('11 week 20 inside 18-22', pg_temp.why('zz-verify-wk2', v_day, v_u), 'eligible');

  update public.profiles set life_stage = 'parenting', life_stage_at = now() where id = v_u;
  insert into public.push_consent (user_id, stage, granted, decided_at, source)
  values (v_u, 'parenting', true, now(), 'messages_switch');
  perform public.pv_campaign_create('zz-verify-mo', 'offer',
    'Sleep in the first months', 'A short course for new parents. Tap to see it.',
    'course', 'zz-course', array['parenting'], v_created, v_day + 30,
    p_child_months_from => 0, p_child_months_to => 3);
  insert into public.children (id, user_id, name, dob)
  values ('zz-verify-baby2', v_u, 'Verify', v_day - 200);
  perform pg_temp.expect('12 not_targeted, a 6-month-old vs 0-3 months', pg_temp.why('zz-verify-mo', v_day, v_u), 'not_targeted');
  insert into public.children (id, user_id, name, dob)
  values ('zz-verify-baby3', v_u, 'Verify', v_day - 60);
  perform pg_temp.expect('13 a 2-month-old is inside 0-3', pg_temp.why('zz-verify-mo', v_day, v_u), 'eligible');
  perform pg_temp.expect('14 a pregnancy campaign has no row in parenting', pg_temp.why('zz-verify-a', v_day, v_u), 'no_row');
  update public.children set removed_at = now(), updated_at = now() where id in ('zz-verify-baby2', 'zz-verify-baby3');
  update public.profiles set life_stage = 'pregnancy', life_stage_at = now() where id = v_u;

  update public.push_audience set busy_evenings = array[v_day] where user_id = v_u;
  perform pg_temp.expect('15 busy_evening', pg_temp.why('zz-verify-a', v_day, v_u), 'busy_evening');
  update public.push_audience set busy_evenings = '{}' where user_id = v_u;

  -- holdout: the share, and the rule on a real person when one exists.
  select avg(case when public.pv_push_holdout(md5(i::text)::uuid) then 1.0 else 0 end)
    into x
    from generate_series(1, 2000) i;
  perform pg_temp.expect('16 holdout share of 2000 ids is 7-13%',
    case when x.avg between 0.07 and 0.13 then 'ok' else x.avg::text end, 'ok');
  perform pg_temp.expect('17 holdout is fixed per person',
    (public.pv_push_holdout(v_u) = public.pv_push_holdout(v_u))::text, 'true');
  select p.id into v_hold from public.profiles p where public.pv_push_holdout(p.id) limit 1;
  if v_hold is not null then
    update public.profiles set life_stage = 'pregnancy', pregnancy_ended_at = null where id = v_hold;
    delete from public.push_consent where user_id = v_hold;
    insert into public.push_consent (user_id, stage, granted, decided_at, source)
    values (v_hold, 'pregnancy', true, now(), 'messages_switch');
    insert into public.push_devices (user_id, device_id, token, platform)
    values (v_hold, 'zz-verify-hold', 'zz-verify-token-hold-000000000000', 'android')
    on conflict do nothing;
    perform pg_temp.expect('18 holdout, a real person in the 10%', pg_temp.why('zz-verify-a', v_day, v_hold), 'holdout');
  else
    perform pg_temp.expect('18 holdout (skipped: nobody in the 10% yet)', 'skipped', 'skipped');
  end if;

  -- ---- 2. the enqueue, the tie-break, already_reached, booked_tonight --
  perform public.pv_campaign_create('zz-verify-b', 'announcement',
    'Something new in Messages', 'A calmer way to see your week. Tap to have a look.',
    'read', 'zz-read', array['pregnancy'], v_created, v_day + 5);
  perform public.pv_campaign_approve('zz-verify-b');
  perform public.pv_push_enqueue(v_day);
  select string_agg(s.campaign_id || ':' || s.status, ',') into v_con
    from public.push_sends s where s.user_id = v_u;
  perform pg_temp.expect('19 one booking; equal priority, the sooner end (b) wins', v_con, 'zz-verify-b:queued');
  select count(*) into n from public.push_sends s
   where s.user_id = v_u
     and s.send_before = (v_day + time '21:00') at time zone 'Asia/Kolkata';
  perform pg_temp.expect('20 the cutoff is 21:00 IST that evening', n::text, '1');
  perform public.pv_push_enqueue(v_day);
  select count(*) into n from public.push_sends s where s.user_id = v_u;
  perform pg_temp.expect('21 a second run books nothing twice', n::text, '1');
  perform pg_temp.expect('22 already_reached', pg_temp.why('zz-verify-b', v_day, v_u), 'already_reached');
  perform pg_temp.expect('23 booked_tonight', pg_temp.why('zz-verify-a', v_day, v_u), 'booked_tonight');
  perform pg_temp.expect('24 weekly_cap three days later', pg_temp.why('zz-verify-a', v_day + 3, v_u), 'weekly_cap');
  perform pg_temp.expect('25 seven days later the week is clear', pg_temp.why('zz-verify-a', v_day + 7, v_u), 'eligible');

  -- ---- 3. priority, the dry run, cancel ------------------------------
  perform public.pv_campaign_create('zz-verify-c', 'offer',
    'A live session with a doctor', 'Ask your questions in a small group. Tap to book.',
    'expert', 'zz-expert', array['pregnancy'], v_created, v_day + 30, p_priority => 5);
  perform public.pv_campaign_approve('zz-verify-c');
  select coalesce(sum(d.people) filter (where d.outcome = 'another_campaign_wins'), 0) into n
    from public.pv_campaign_dry_run('zz-verify-a', v_day + 7) d;
  perform pg_temp.expect('26 dry run: another_campaign_wins (priority 5 beats 0)',
    case when n >= 1 then 'ok' else n::text end, 'ok');
  select coalesce(sum(d.people) filter (where d.outcome = 'would_send'), 0) into n
    from public.pv_campaign_dry_run('zz-verify-c', v_day + 7) d;
  perform pg_temp.expect('27 dry run: would_send for the winner',
    case when n >= 1 then 'ok' else n::text end, 'ok');
  perform public.pv_push_enqueue(v_day + 7);
  select s.campaign_id into v_con from public.push_sends s
   where s.user_id = v_u and s.send_on = v_day + 7;
  perform pg_temp.expect('28 enqueue books the higher priority', v_con, 'zz-verify-c');

  n := public.pv_campaign_cancel('zz-verify-c');
  perform pg_temp.expect('29 cancel stops its queued bookings', case when n >= 1 then 'ok' else n::text end, 'ok');
  select s.status || '/' || coalesce(s.error, '') into v_con from public.push_sends s
   where s.user_id = v_u and s.campaign_id = 'zz-verify-c';
  perform pg_temp.expect('30 the booking is skipped/cancelled', v_con, 'skipped/cancelled');
  perform pg_temp.expect('31 and the evening is free again', pg_temp.why('zz-verify-a', v_day + 7, v_u), 'eligible');
  select status into v_con from public.push_sends where user_id = v_u and campaign_id = 'zz-verify-b';
  perform pg_temp.expect('32 another campaign''s booking is untouched', v_con, 'queued');

  -- ---- 4. the text and shape checks, on the table ---------------------
  begin
    perform public.pv_campaign_create('zz-verify-bad1', 'offer', repeat('a', 51), 'Body.',
      'course', 'x', array['pregnancy'], v_day, v_day + 1);
    v_con := 'accepted';
  exception when check_violation then get stacked diagnostics v_con = constraint_name;
  end;
  perform pg_temp.expect('33 a 51-character title', v_con, 'push_campaigns_title_length');
  begin
    perform public.pv_campaign_create('zz-verify-bad2', 'offer', 'Title', repeat('b', 151),
      'course', 'x', array['pregnancy'], v_day, v_day + 1);
    v_con := 'accepted';
  exception when check_violation then get stacked diagnostics v_con = constraint_name;
  end;
  perform pg_temp.expect('34 a 151-character body', v_con, 'push_campaigns_body_length');
  begin
    perform public.pv_campaign_create('zz-verify-bad3', 'offer', 'Hi {{name}}', 'Body.',
      'course', 'x', array['pregnancy'], v_day, v_day + 1);
    v_con := 'accepted';
  exception when check_violation then get stacked diagnostics v_con = constraint_name;
  end;
  perform pg_temp.expect('35 a placeholder', v_con, 'push_campaigns_no_placeholders');
  begin
    perform public.pv_campaign_create('zz-verify-bad4', 'offer', 'You are in week 20', 'Body.',
      'course', 'x', array['pregnancy'], v_day, v_day + 1);
    v_con := 'accepted';
  exception when check_violation then get stacked diagnostics v_con = constraint_name;
  end;
  perform pg_temp.expect('36 "week 20"', v_con, 'push_campaigns_no_week_or_day_number');
  begin
    perform public.pv_campaign_create('zz-verify-bad5', 'offer', 'Hurry', 'Only 3 days left.',
      'course', 'x', array['pregnancy'], v_day, v_day + 1);
    v_con := 'accepted';
  exception when check_violation then get stacked diagnostics v_con = constraint_name;
  end;
  perform pg_temp.expect('37 "3 days left"', v_con, 'push_campaigns_no_week_or_day_number');
  begin
    perform public.pv_campaign_create('zz-verify-ok7', 'offer', 'Try the course', 'A 7-day free trial, then decide.',
      'course', 'x', array['pregnancy'], v_day, v_day + 1);
    v_con := 'accepted';
  exception when check_violation then get stacked diagnostics v_con = constraint_name;
  end;
  perform pg_temp.expect('38 "7-day trial" is allowed', v_con, 'accepted');
  begin
    perform public.pv_campaign_create('zz-verify-bad6', 'offer', 'Title', 'Body.',
      'course', 'x', array['ttc'], v_day, v_day + 1);
    v_con := 'accepted';
  exception when check_violation then get stacked diagnostics v_con = constraint_name;
  end;
  perform pg_temp.expect('39 stage word "ttc" (it is "trying")', v_con, 'push_campaigns_stages');
  begin
    perform public.pv_campaign_create('zz-verify-bad7', 'offer', 'Title', 'Body.',
      'course', 'x', array['pregnancy'], v_day + 2, v_day + 1);
    v_con := 'accepted';
  exception when check_violation then get stacked diagnostics v_con = constraint_name;
  end;
  perform pg_temp.expect('40 ends before it starts', v_con, 'push_campaigns_dates');
  begin
    perform public.pv_campaign_create('zz-verify-bad8', 'offer', 'Title', 'Body.',
      'course', 'x', array['parenting'], v_day, v_day + 1, p_week_from => 10);
    v_con := 'accepted';
  exception when check_violation then get stacked diagnostics v_con = constraint_name;
  end;
  perform pg_temp.expect('41 weeks on a parenting-only campaign', v_con, 'push_campaigns_weeks');
  begin
    perform public.pv_campaign_create('zz-verify-bad9', 'offer', 'Title', 'Body.',
      'video', 'x', array['pregnancy'], v_day, v_day + 1);
    v_con := 'accepted';
  exception when check_violation then get stacked diagnostics v_con = constraint_name;
  end;
  perform pg_temp.expect('42 a link kind the phone cannot open', v_con, 'push_campaigns_link_kind_check');
  begin
    perform public.pv_campaign_create('zz-verify-a', 'offer', 'Rewrite', 'Body.',
      'course', 'x', array['pregnancy'], v_day, v_day + 1);
    v_con := 'accepted';
  exception when raise_exception then v_con := 'refused';
  end;
  perform pg_temp.expect('43 an approved campaign cannot be rewritten', v_con, 'refused');
  begin
    perform public.pv_campaign_approve('zz-verify-a');
    v_con := 'accepted';
  exception when raise_exception then v_con := 'refused';
  end;
  perform pg_temp.expect('44 approve twice is refused', v_con, 'refused');

  -- ---- 5. after the cutoff, nothing is booked -------------------------
  perform pg_temp.expect('45 enqueue for yesterday books 0',
    public.pv_push_enqueue((now() at time zone 'Asia/Kolkata')::date - 1)::text, '0');

  -- ---- 6. grants, RLS, cron ------------------------------------------
  select count(*) into n
    from unnest(array[
      'public.pv_push_holdout(uuid)',
      'public.pv_push_link_needs(text)',
      'public.pv_push_check(date,text)',
      'public.pv_push_enqueue(date)',
      'public.pv_campaign_create(text,text,text,text,text,text,text[],date,date,int,int,int,int,int)',
      'public.pv_campaign_dry_run(text,date)',
      'public.pv_campaign_approve(text)',
      'public.pv_campaign_cancel(text)'
    ]) f
    cross join unnest(array['anon', 'authenticated']) ro
   where has_function_privilege(ro, f, 'execute');
  perform pg_temp.expect('46 no push function is callable by anon or authenticated', n::text, '0');

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_u::text, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  select count(*) into n from public.push_sends;
  select string_agg(id, ',' order by id) into v_con from public.push_campaigns;
  execute 'reset role';
  perform pg_temp.expect('47 she sees her own bookings (b, c)', n::text, '2');
  perform pg_temp.expect('48 she sees only approved campaigns booked for her', v_con, 'zz-verify-b');

  select p.id into v_other from public.profiles p where p.id <> v_u limit 1;
  if v_other is not null then
    perform set_config('request.jwt.claims',
      json_build_object('sub', v_other::text, 'role', 'authenticated')::text, true);
    execute 'set local role authenticated';
    select count(*) into n from public.push_sends where user_id = v_u;
    execute 'reset role';
    perform pg_temp.expect('49 someone else sees none of hers', n::text, '0');
  else
    perform pg_temp.expect('49 someone else (skipped: one profile only)', 'skipped', 'skipped');
  end if;
  perform set_config('request.jwt.claims', null, true);

  select count(*) into n from cron.job
   where jobname = 'push-enqueue-daily' and schedule = '30 4 * * *' and active;
  perform pg_temp.expect('50 the 10:00 IST cron is scheduled', n::text, '1');

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

  raise exception E'\n\n=== PUSH CAMPAIGNS VERIFICATION (0143) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
