-- =====================================================================
-- diagnose_realtime_send.sql -- why did 0145's broadcast write no row?
-- ---------------------------------------------------------------------
-- HOW TO RUN: paste the whole file into the Supabase SQL editor and Run.
-- It ends in a red ERROR on purpose: that is the report, and raising
-- rolls back the probe rows. Send a screenshot of the message.
--
-- verify_community_live.sql passed 8 of 10: the trigger and realtime.send
-- exist, but no row reached realtime.messages. realtime.send catches its
-- own errors and only raises a WARNING (the editor hides warnings), so
-- this does the same insert by hand to see the real error.
-- =====================================================================

do $$
declare
  v_report text := '';
  v_n      int;
  v_parts  text;
  v_src    text;
begin
  -- 1. Which days does realtime.messages have partitions for?
  select string_agg(c.relname, ', ' order by c.relname) into v_parts
    from pg_inherits i join pg_class c on c.oid = i.inhrelid
   where i.inhparent = 'realtime.messages'::regclass;
  v_report := v_report || E'\nPartitions: ' || coalesce(v_parts, 'NONE');

  -- 2. Does realtime.send catch its own errors?
  select pg_get_functiondef(p.oid) into v_src
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'realtime' and p.proname = 'send' limit 1;
  v_report := v_report || E'\nsend() swallows errors: ' || (v_src ilike '%exception%')::text;

  -- 3. realtime.send, then count.
  perform realtime.send(jsonb_build_object('probe', 1), 'probe', 'zz-diag-send', true);
  select count(*) into v_n from realtime.messages where topic = 'zz-diag-send';
  v_report := v_report || E'\nrealtime.send wrote rows: ' || v_n;

  -- 4. The same insert by hand, with the error shown.
  begin
    insert into realtime.messages (payload, event, topic, private, extension)
    values (jsonb_build_object('probe', 2), 'probe', 'zz-diag-hand', true, 'broadcast');
    v_report := v_report || E'\nHand insert: OK';
  exception when others then
    v_report := v_report || E'\nHand insert FAILED: ' || sqlstate || ' ' || sqlerrm;
  end;

  raise exception E'DIAGNOSE 0145:%\n(Rolled back.)', v_report;
end $$;
