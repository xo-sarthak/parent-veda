-- =====================================================================
-- verify_push_b5.sql -- prove 0146 (6b B5: the "Offers and news" channel
--                       and the tap) against the real tables.
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0146, paste the whole file into the Supabase SQL
-- editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls everything back: the test
-- campaigns, the booking, the test row, the borrowed user's device row,
-- the tap, and every claim pv_push_due made on real rows.
--
-- Borrows the OLDEST profile, and acts as her the way the phone does: her
-- id in the JWT claims, then the `authenticated` role, so RLS and the
-- grants are the real ones. The booking is dated 2000-01-01 (19:00 long
-- past) with send_before set by hand, so every check passes at any hour.
-- =====================================================================

do $$
declare
  v_u     uuid;
  v_other uuid := gen_random_uuid();
  v_tok   text := 'zz-verify-b5-token-' || md5(random()::text);
  v_a     uuid;   -- her booking
  v_t     uuid;   -- a test
  v_first timestamptz;
  v_ok    boolean;
  n       int;
  s       text;
  r       text := '';
  pass    int := 0;
  fail    int := 0;
  x       record;
begin
  select p.id into v_u
    from public.profiles p
    join auth.users u on u.id = p.id
   order by u.created_at
   limit 1;
  if v_u is null then
    raise exception E'\n\n=== PUSH B5 VERIFICATION (0146) ===\n\nSKIPPED: needs one profile.\n';
  end if;

  create temp table _r (seq serial, label text, ok boolean, got text) on commit drop;
  create function pg_temp.expect(p_label text, p_got text, p_want text)
  returns void language sql as $f$
    insert into pg_temp._r (label, ok, got)
    values (p_label, p_got is not distinct from p_want, p_got);
  $f$;

  -- ---- fixtures ------------------------------------------------------
  insert into public.push_devices (user_id, device_id, token, platform, link_version)
  values (v_u, 'zz-verify-b5-device', v_tok, 'android', 1)
  on conflict (user_id, device_id) do update set token = excluded.token, link_version = 1;

  insert into public.push_campaigns
    (id, kind, title, body, link_kind, link_id, stages, starts_on, ends_on, status, approved_at)
  select 'zz-verify-b5-' || k, 'offer', 'A calm class', 'Tap to see it.', 'read', 'zz-verify',
         array['pregnancy'], date '2000-01-01', date '2999-12-31', 'approved', now()
    from unnest(array['a', 'unbooked']) k;

  insert into public.push_sends (campaign_id, user_id, send_on, send_before)
  values ('zz-verify-b5-a', v_u, date '2000-01-01', now() + interval '1 hour')
  returning id into v_a;
  insert into public.push_tests (campaign_id, user_id)
  values ('zz-verify-b5-a', v_u)
  returning id into v_t;

  -- ---- 1. the channel ------------------------------------------------
  create temp table _d on commit drop as select * from public.pv_push_due(500);
  select d.channel into s from _d d where d.row_id = v_a;
  perform pg_temp.expect('01 a campaign goes on the offers_news channel', s, 'offers_news');
  select d.channel into s from _d d where d.row_id = v_t;
  perform pg_temp.expect('02 ...and so does a test of it', s, 'offers_news');
  select d.data ->> 'queue' || '|' || (d.data ->> 'row_id') into s from _d d where d.row_id = v_a;
  perform pg_temp.expect('03 the push data still names its queue and row (the tap needs both)',
                         s, 'push_sends|' || v_a::text);
  select count(*) into n from _d d where d.channel is null and d.queue in ('push_sends', 'push_tests');
  perform pg_temp.expect('04 no campaign row is left on the default channel', n::text, '0');

  -- ---- 2. the tap, as her ------------------------------------------
  perform set_config('request.jwt.claims',
                     json_build_object('sub', v_u::text, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', v_u::text, true);
  set local role authenticated;

  -- What the phone reads for B5 (PushBookings): her booking, and its text.
  select count(*) into n from public.push_sends where id = v_a;
  s := n::text;
  select count(*) into n from public.push_campaigns where id = 'zz-verify-b5-a';
  s := s || '|' || n::text;
  select count(*) into n from public.push_campaigns where id = 'zz-verify-b5-unbooked';
  s := s || '|' || n::text;
  reset role;
  perform pg_temp.expect('05 as her: own booking 1, its campaign 1, an unbooked campaign 0', s, '1|1|0');

  set local role authenticated;
  begin
    update public.push_sends set tapped_at = now() where id = v_a;
    s := 'allowed';
  exception when insufficient_privilege then
    s := 'denied';
  end;
  reset role;
  perform pg_temp.expect('06 as her: a direct update of push_sends is refused', s, 'denied');

  set local role authenticated;
  v_ok := public.pv_push_tapped(v_a);
  reset role;
  select tapped_at into v_first from public.push_sends where id = v_a;
  perform pg_temp.expect('07 her tap is recorded', v_ok::text || '|' || (v_first is not null)::text, 'true|true');

  set local role authenticated;
  v_ok := public.pv_push_tapped(v_a);
  reset role;
  select (tapped_at = v_first)::text into s from public.push_sends where id = v_a;
  perform pg_temp.expect('08 a second tap keeps the first time', v_ok::text || '|' || s, 'false|true');

  set local role authenticated;
  v_ok := public.pv_push_tapped(gen_random_uuid());
  reset role;
  perform pg_temp.expect('09 a row that does not exist: nothing recorded', v_ok::text, 'false');

  -- Someone else: a different id in the claims, the same row.
  update public.push_sends set tapped_at = null where id = v_a;
  perform set_config('request.jwt.claims',
                     json_build_object('sub', v_other::text, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', v_other::text, true);
  set local role authenticated;
  v_ok := public.pv_push_tapped(v_a);
  reset role;
  select (tapped_at is null)::text into s from public.push_sends where id = v_a;
  perform pg_temp.expect('10 someone else cannot tap her row', v_ok::text || '|' || s, 'false|true');

  perform set_config('request.jwt.claims', '', true);
  perform set_config('request.jwt.claim.sub', '', true);
  v_ok := public.pv_push_tapped(v_a);
  perform pg_temp.expect('11 no one signed in: nothing recorded', v_ok::text, 'false');

  -- ---- 3. grants -----------------------------------------------------
  select string_agg(ro || '=' || has_function_privilege(ro, 'public.pv_push_tapped(uuid)', 'execute')::text,
                    ',' order by ro) into s
    from unnest(array['anon', 'authenticated']) ro;
  perform pg_temp.expect('12 pv_push_tapped: the app yes, anon no', s, 'anon=false,authenticated=true');
  select count(*) into n
    from unnest(array['anon', 'authenticated']) ro
   where has_function_privilege(ro, 'public.pv_push_due(int)', 'execute');
  perform pg_temp.expect('13 pv_push_due is still not callable by the app', n::text, '0');
  perform pg_temp.expect('14 ...and still callable by the sender',
                         has_function_privilege('service_role', 'public.pv_push_due(int)', 'execute')::text,
                         'true');
  select count(*) into n
    from unnest(array['anon', 'authenticated']) ro
   where has_table_privilege(ro, 'public.push_sends', 'update');
  perform pg_temp.expect('15 the app has no update grant on push_sends', n::text, '0');

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

  raise exception E'\n\n=== PUSH B5 VERIFICATION (0146) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
