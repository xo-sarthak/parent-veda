-- =====================================================================
-- verify_push_campaign_lock.sql -- prove 0150 (6b leftover L1: an approved
--                                  campaign's words are locked).
-- ---------------------------------------------------------------------
-- HOW TO RUN: after 0150, paste the whole file into the Supabase SQL
-- editor and Run.
--
-- IT WILL FINISH WITH A RED "ERROR". THAT IS THE REPORT, AND IT IS
-- INTENTIONAL. Raising at the end rolls everything back: the test
-- campaigns and every change made to them.
--
-- Writes the table directly, as Directus will, not through the functions:
-- the lock exists for the writer who skips them.
-- =====================================================================

do $$
declare
  r    text := '';
  pass int := 0;
  fail int := 0;
  x    record;
  f    text;
  n    int;
begin
  create temp table _r (seq serial, label text, ok boolean, got text) on commit drop;
  create function pg_temp.expect(p_label text, p_got text, p_want text)
  returns void language sql as $f$
    insert into pg_temp._r (label, ok, got)
    values (p_label, p_got is not distinct from p_want, p_got);
  $f$;

  -- Runs one statement and answers 'ok', or 'refused' when THE LOCK stops
  -- it, or the error's text. A table check is a check_violation too, so the
  -- lock is told apart by its message, which starts with the table's name.
  create function pg_temp.try(p_sql text)
  returns text language plpgsql as $f$
  begin
    execute p_sql;
    return 'ok';
  exception
    when check_violation then
      return case when sqlerrm like 'push_campaigns: %' then 'refused' else sqlerrm end;
    when others then return sqlerrm;
  end;
  $f$;

  -- ---- fixtures ------------------------------------------------------
  insert into public.push_campaigns
    (id, kind, title, body, link_kind, link_id, stages, starts_on, ends_on, status, approved_at)
  values
    ('zz-verify-lock-a', 'offer', 'A calm class', 'Tap to see it.', 'read', 'zz-verify',
     array['pregnancy'], date '2000-01-01', date '2999-12-31', 'approved', now()),
    ('zz-verify-lock-p', 'offer', 'A calm class', 'Tap to see it.', 'read', 'zz-verify',
     array['parenting'], date '2000-01-01', date '2999-12-31', 'approved', now()),
    ('zz-verify-lock-c', 'offer', 'A calm class', 'Tap to see it.', 'read', 'zz-verify',
     array['pregnancy'], date '2000-01-01', date '2999-12-31', 'approved', now());
  perform public.pv_campaign_create('zz-verify-lock-d', 'offer',
    'A calm class', 'Tap to see it.', 'read', 'zz-verify', array['pregnancy'],
    date '2000-01-01', date '2999-12-31');

  -- ---- 1. every locked column, written directly ----------------------
  for x in select * from (values
      ('title',             $s$title = 'A different class'$s$, 'a'),
      ('body',              $s$body = 'Different words.'$s$, 'a'),
      ('kind',              $s$kind = 'announcement'$s$, 'a'),
      ('link_kind',         $s$link_kind = 'course'$s$, 'a'),
      ('link_id',           $s$link_id = 'zz-other'$s$, 'a'),
      ('stages',            $s$stages = array['pregnancy', 'parenting']$s$, 'a'),
      ('week_from',         $s$week_from = 10$s$, 'a'),
      ('week_to',           $s$week_to = 30$s$, 'a'),
      ('child_months_from', $s$child_months_from = 1$s$, 'p'),
      ('child_months_to',   $s$child_months_to = 6$s$, 'p'),
      ('starts_on',         $s$starts_on = date '2001-01-01'$s$, 'a'),
      ('ends_on',           $s$ends_on = date '2998-12-31'$s$, 'a'),
      ('priority',          $s$priority = 50$s$, 'a'),
      ('id',                $s$id = 'zz-verify-lock-renamed'$s$, 'a')
    ) t(col, change, target)
  loop
    perform pg_temp.expect('1  approved: ' || x.col || ' is refused',
      pg_temp.try(format('update public.push_campaigns set %s where id = %L', x.change, 'zz-verify-lock-' || x.target)),
      'refused');
  end loop;

  select title || '|' || body || '|' || priority into f
    from public.push_campaigns where id = 'zz-verify-lock-a';
  perform pg_temp.expect('2  nothing changed', f, 'A calm class|Tap to see it.|0');

  -- ---- 2. what stays allowed -----------------------------------------
  perform pg_temp.expect('3  approved_at can be written',
    pg_temp.try($s$update public.push_campaigns set approved_at = now() - interval '1 hour' where id = 'zz-verify-lock-a'$s$),
    'ok');
  perform pg_temp.expect('4  an update that changes nothing locked passes',
    pg_temp.try($s$update public.push_campaigns set title = title, status = 'approved' where id = 'zz-verify-lock-a'$s$),
    'ok');
  perform pg_temp.expect('5  back to draft is refused',
    pg_temp.try($s$update public.push_campaigns set status = 'draft' where id = 'zz-verify-lock-a'$s$),
    'refused');
  perform pg_temp.expect('6  cancel by a direct write is allowed',
    pg_temp.try($s$update public.push_campaigns set status = 'cancelled', cancelled_at = now() where id = 'zz-verify-lock-a'$s$),
    'ok');
  perform pg_temp.expect('7  pv_campaign_cancel still works',
    pg_temp.try($s$select public.pv_campaign_cancel('zz-verify-lock-c')$s$),
    'ok');

  -- ---- 3. cancelled stays cancelled -----------------------------------
  perform pg_temp.expect('8  cancelled -> approved is refused',
    pg_temp.try($s$update public.push_campaigns set status = 'approved' where id = 'zz-verify-lock-a'$s$),
    'refused');
  perform pg_temp.expect('9  cancelled -> draft is refused',
    pg_temp.try($s$update public.push_campaigns set status = 'draft' where id = 'zz-verify-lock-c'$s$),
    'refused');

  -- ---- 4. a draft is still free ----------------------------------------
  perform pg_temp.expect('10 a draft can be rewritten directly',
    pg_temp.try($s$update public.push_campaigns set title = 'A better title', priority = 5 where id = 'zz-verify-lock-d'$s$),
    'ok');
  perform pg_temp.expect('11 ...and through pv_campaign_create',
    pg_temp.try($s$select public.pv_campaign_create('zz-verify-lock-d', 'offer', 'Another title', 'Tap to see it.', 'read', 'zz-verify', array['pregnancy'], date '2000-01-01', date '2999-12-31')$s$),
    'ok');
  perform pg_temp.expect('12 pv_campaign_approve still works',
    pg_temp.try($s$select public.pv_campaign_approve('zz-verify-lock-d')$s$),
    'ok');
  perform pg_temp.expect('13 ...and then the draft is locked too',
    pg_temp.try($s$update public.push_campaigns set title = 'Too late' where id = 'zz-verify-lock-d'$s$),
    'refused');

  -- ---- 5. the trigger and its grants ----------------------------------
  select count(*) into n
    from pg_trigger t
   where t.tgrelid = 'public.push_campaigns'::regclass
     and t.tgname = 'push_campaigns_lock'
     and not t.tgisinternal
     and t.tgenabled <> 'D';
  perform pg_temp.expect('14 the trigger is on and enabled', n::text, '1');
  select count(*) into n
    from unnest(array['anon', 'authenticated']) ro
   where has_function_privilege(ro, 'public.pv_push_campaign_lock()', 'execute');
  perform pg_temp.expect('15 the app cannot call the lock function', n::text, '0');

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

  raise exception E'\n\n=== PUSH CAMPAIGN LOCK VERIFICATION (0150) ===%\n\nPASSED %  FAILED %\n\n(This "error" is the report. It forces the rollback -- no fixtures were kept.)\n',
    r, pass, fail;
end $$;
