-- =====================================================================
-- verify_push_quiet_evenings.sql -- prove 0151 (6b leftover L3: the
--                                   phone's quiet, as dates).
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0151, paste the whole file into the Supabase SQL
-- editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls everything back: her consent,
-- device and audience rows, the test campaign, and her profile changes.
--
-- Borrows the OLDEST profile outside the holdout, makes her eligible for one approved test
-- campaign (as verify_push_campaigns.sql does), then changes only her
-- push_audience row and reads pv_push_check's reason. The uploads run as
-- her (JWT claims + the `authenticated` role), the way the phone calls.
-- =====================================================================

do $$
declare
  v_u     uuid;
  v_today date := (now() at time zone 'Asia/Kolkata')::date;
  v_n     int;
  s       text;
  r       text := '';
  pass    int := 0;
  fail    int := 0;
  x       record;
begin
  select p.id into v_u
    from public.profiles p
    join auth.users u on u.id = p.id
   where u.created_at < now() - interval '8 days'
     -- Not in the 10% holdout: for them pv_push_check stops at 'holdout'
     -- and never reaches phone_quiet (found on the first run, 2026-10-31).
     and not public.pv_push_holdout(p.id)
   order by u.created_at
   limit 1;
  if v_u is null then
    raise exception E'\n\n=== PUSH QUIET EVENINGS VERIFICATION (0151) ===\n\nSKIPPED: needs one profile older than 8 days and outside the 10%% holdout.\n';
  end if;

  create temp table _r (seq serial, label text, ok boolean, got text) on commit drop;
  create function pg_temp.expect(p_label text, p_got text, p_want text)
  returns void language sql as $f$
    insert into pg_temp._r (label, ok, got)
    values (p_label, p_got is not distinct from p_want, p_got);
  $f$;

  -- Why she would not get the test campaign on p_on, or 'eligible'.
  create function pg_temp.why(p_on date, p_user uuid)
  returns text language sql as $f$
    select coalesce(
      (select coalesce(c.reason, 'eligible')
         from public.pv_push_check(p_on, 'zz-verify-quiet') c
        where c.user_id = p_user),
      'no_row');
  $f$;

  -- ---- fixtures: she passes every rule before phone_quiet --------------
  update public.profiles
     set life_stage = 'trying', life_stage_at = now(), pregnancy_ended_at = null
   where id = v_u;
  delete from public.push_consent  where user_id = v_u;
  delete from public.push_devices  where user_id = v_u;
  delete from public.push_audience where user_id = v_u;
  delete from public.push_sends    where user_id = v_u;
  update public.children
     set removed_at = now(), updated_at = now()
   where user_id = v_u and removed_at is null;
  insert into public.push_consent (user_id, stage, granted, decided_at, source)
  values (v_u, 'trying', true, now(), 'messages_switch');
  insert into public.push_devices (user_id, device_id, token, platform, link_version)
  values (v_u, 'zz-verify-quiet-device', 'zz-verify-quiet-token-' || md5(random()::text), 'android', 1);
  insert into public.push_campaigns
    (id, kind, title, body, link_kind, link_id, stages, starts_on, ends_on, status, approved_at)
  values ('zz-verify-quiet', 'offer', 'A calm class', 'Tap to see it.', 'read', 'zz-verify',
          array['trying'], date '2000-01-01', date '2999-12-31', 'approved', now());

  if public.pv_push_holdout(v_u) then
    raise exception E'\n\n=== PUSH QUIET EVENINGS VERIFICATION (0151) ===\n\nSKIPPED: the borrowed profile is in the 10%% holdout, so phone_quiet is never reached. Edit the select to borrow another.\n';
  end if;

  perform pg_temp.expect('1  no audience row: eligible (missing is not quiet)', pg_temp.why(v_today, v_u), 'eligible');

  -- ---- the upload, as the phone makes it ------------------------------
  perform set_config('request.jwt.claims',
                     json_build_object('sub', v_u::text, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', v_u::text, true);
  set local role authenticated;

  -- An older build: two arguments. Must still land (the ambiguity check).
  perform public.pv_push_audience(p_busy_evenings => '{}', p_quiet => false);
  -- A new build: quiet on day 3 and day 5, plus junk outside the fortnight.
  perform public.pv_push_audience(
    p_busy_evenings  => '{}',
    p_quiet          => false,
    p_quiet_evenings => array[v_today + 3, v_today + 5, v_today + 5, v_today - 1, v_today + 20]);
  reset role;

  select array_to_string(quiet_evenings, ',') into s
    from public.push_audience where user_id = v_u;
  perform pg_temp.expect('2  stored: in the fortnight, once each, in order', s,
    (v_today + 3)::text || ',' || (v_today + 5)::text);

  perform pg_temp.expect('3  a quiet date is phone_quiet', pg_temp.why(v_today + 3, v_u), 'phone_quiet');
  perform pg_temp.expect('4  a date between is not', pg_temp.why(v_today + 4, v_u), 'eligible');
  perform pg_temp.expect('5  today, not in the list, is not', pg_temp.why(v_today, v_u), 'eligible');

  -- ---- the yes/no is the fallback --------------------------------------
  update public.push_audience set quiet = true where user_id = v_u;
  perform pg_temp.expect('6  inside the fortnight the DATES win over a yes', pg_temp.why(v_today + 4, v_u), 'eligible');
  perform pg_temp.expect('7  past the fortnight the yes decides', pg_temp.why(v_today + 15, v_u), 'phone_quiet');
  update public.push_audience set quiet = false where user_id = v_u;
  perform pg_temp.expect('8  ...and a no', pg_temp.why(v_today + 15, v_u), 'eligible');

  update public.push_audience set quiet_evenings = null, quiet = true where user_id = v_u;
  perform pg_temp.expect('9  an older build (null): the yes decides', pg_temp.why(v_today + 4, v_u), 'phone_quiet');
  update public.push_audience set quiet = false where user_id = v_u;
  perform pg_temp.expect('10 ...and a no', pg_temp.why(v_today + 3, v_u), 'eligible');

  update public.push_audience set quiet_evenings = '{}', quiet = false where user_id = v_u;
  perform pg_temp.expect('11 an empty list is "no quiet evening"', pg_temp.why(v_today + 3, v_u), 'eligible');

  -- An upload five days ago: its fortnight ends 9 days from now.
  update public.push_audience
     set quiet_evenings = array[v_today + 9], quiet = true,
         planned_at = now() - interval '5 days'
   where user_id = v_u;
  perform pg_temp.expect('12 the fortnight is counted from the upload', pg_temp.why(v_today + 8, v_u), 'eligible');
  perform pg_temp.expect('13 ...its last day still reads the dates', pg_temp.why(v_today + 9, v_u), 'phone_quiet');
  perform pg_temp.expect('14 ...and the day after falls back to the yes', pg_temp.why(v_today + 10, v_u), 'phone_quiet');

  -- ---- signatures and grants -------------------------------------------
  select count(*) into v_n
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public' and p.proname = 'pv_push_audience';
  perform pg_temp.expect('15 one pv_push_audience (the old one dropped)', v_n::text, '1');
  select string_agg(ro || '=' || has_function_privilege(ro, 'public.pv_push_audience(date[], boolean, date[])', 'execute')::text,
                    ',' order by ro) into s
    from unnest(array['anon', 'authenticated']) ro;
  perform pg_temp.expect('16 the app may upload, anon may not', s, 'anon=false,authenticated=true');
  select count(*) into v_n
    from unnest(array['anon', 'authenticated']) ro
   where has_function_privilege(ro, 'public.pv_push_check(date, text)', 'execute');
  perform pg_temp.expect('17 pv_push_check is still not callable by the app', v_n::text, '0');
  select count(*) into v_n
    from unnest(array['anon', 'authenticated']) ro
   where has_table_privilege(ro, 'public.push_audience', 'select');
  perform pg_temp.expect('18 the app still cannot read push_audience', v_n::text, '0');

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

  raise exception E'\n\n=== PUSH QUIET EVENINGS VERIFICATION (0151) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
