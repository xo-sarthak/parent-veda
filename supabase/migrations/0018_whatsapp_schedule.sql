-- =====================================================================
-- 0018_whatsapp_schedule.sql — WhatsApp notifications: the daily timer (B5)
-- Puts the B3 brain (wa_enqueue_weekly_guide) on pg_cron so it runs itself
-- every day, no human needed. This ENQUEUES only; the sender still runs
-- separately (mock now / real Edge Function at B6).
-- Run AFTER 0016. Safe to run once (named job = upsert, no duplicates).
-- =====================================================================


-- 1) Enable pg_cron ---------------------------------------------------
--    If this line errors ("permission denied" / "must be superuser"), instead
--    enable it once via Dashboard -> Database -> Extensions -> search "pg_cron"
--    -> toggle ON, then re-run from section 2 below.
create extension if not exists pg_cron;


-- 2) Schedule the daily enqueue ---------------------------------------
--    03:30 UTC == 09:00 IST. Cron format: minute hour day month weekday.
--    Named job -> re-running this migration UPDATES the same job (no dupes).
--    Why DAILY (not weekly): the ISO-week dedupe_key guarantees at most one
--    guide per mother per week, so a daily run is safe AND better -- it picks
--    up mothers who newly opt in / set a due date mid-week, and self-heals if
--    a day's run is ever missed.
select cron.schedule(
  'wa-weekly-guide-daily',                       -- job name
  '30 3 * * *',                                  -- every day, 03:30 UTC (09:00 IST)
  $$ select public.wa_enqueue_weekly_guide(); $$ -- what it runs
);


-- =====================================================================
-- USEFUL COMMANDS (run by hand in the SQL Editor)
-- =====================================================================
-- Confirm the job is scheduled:
--   select jobid, jobname, schedule, command, active from cron.job;
--
-- See recent run history (after it has fired, or after a manual run):
--   select jobid, status, return_message, start_time, end_time
--     from cron.job_run_details order by start_time desc limit 20;
--
-- Fire the brain right now without waiting for 09:00 IST:
--   select public.wa_enqueue_weekly_guide();
--
-- Pause / remove the schedule:
--   select cron.unschedule('wa-weekly-guide-daily');
--
-- NOTE: until real mothers are opted in (phone + wa_opt_in + due_date, role
-- 'mother', week 4-40), the daily run simply enqueues 0 rows -- that's correct.
-- The automation is armed and waiting; it does nothing until there's data.
-- The SENDER is NOT scheduled here -- it stays manual (mock) until B6, where
-- the real Edge Function gets its own trigger.
-- =====================================================================
