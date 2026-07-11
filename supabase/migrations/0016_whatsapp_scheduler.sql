-- =====================================================================
-- 0016_whatsapp_scheduler.sql — WhatsApp notifications: the "who's due today" brain (B3)
-- Adds: a pregnancy-week helper (mirrors the app's formula), a reconciliation
-- of the seeded templates to the 2-variable MVP shape, and the daily enqueue
-- function that writes "queued" rows into wa_message_log (idempotent per ISO week).
-- This function DECIDES + ENQUEUES only — it does not send. The sender (B4) drains the queue.
-- Run AFTER 0015. Safe to run once (idempotent).
-- =====================================================================


-- 1) Pregnancy-week helper --------------------------------------------
--    Mirrors lib/services/pregnancy_controller.dart `currentWeek`:
--      week = 40 - floor((due_date - today) / 7)
--    Pure over its args (no side effects), so marked immutable.
create or replace function public.wa_pregnancy_week(due date, as_of date default current_date)
returns int
language sql
immutable
as $$
  select 40 - floor((due - as_of) / 7.0)::int;
$$;

grant execute on function public.wa_pregnancy_week(date, date) to authenticated, service_role;


-- 2) Reconcile the seeded templates to the 2-variable MVP shape --------
--    B3 enqueues {name, week} only (a complete, sendable message). Richer
--    "size of a fruit" content is deferred (it lives in the app's Week Stack;
--    we won't duplicate it into the DB yet). This UPDATE brings the registry
--    rows created in 0015 in line with what the scheduler actually fills.
update public.wa_message_templates
   set variables = '["name","week"]'::jsonb,
       body = case name
                when 'weekly_guide_en' then 'Hi {{1}}, you are now in week {{2}} of your pregnancy. - ParentVeda'
                when 'weekly_guide_hi' then 'Namaste {{1}}, aap ab pregnancy ke week {{2}} mein hain. - ParentVeda'
              end,
       updated_at = now()
 where name in ('weekly_guide_en', 'weekly_guide_hi');


-- 3) The daily enqueue function — the brain ---------------------------
--    Finds every opted-in mother, computes her week, and inserts one "queued"
--    row per (mother, ISO week) into wa_message_log. security definer so it can
--    read all profiles + write logs past RLS (like link_as_partner in 0009).
create or replace function public.wa_enqueue_weekly_guide(as_of date default current_date)
returns int                          -- how many messages were newly enqueued
language plpgsql
security definer set search_path = ''
as $$
declare
  enqueued int := 0;
begin
  insert into public.wa_message_log
    (user_id, template_name, category, language, variables, status, dedupe_key)
  select
    p.id,
    'weekly_guide_' || lang.code,
    'marketing',
    lang.code,
    jsonb_build_object(
      'name', coalesce(nullif(p.name, ''), 'there'),
      'week', wk.week
    ),
    'queued',
    'weekly_guide:' || to_char(as_of, 'IYYY') || '-W' || to_char(as_of, 'IW')  -- one per ISO week
  from public.profiles p
  cross join lateral (
    select public.wa_pregnancy_week(p.due_date, as_of) as week
  ) wk
  cross join lateral (
    select case
             when lower(coalesce(p.language, '')) in ('hi', 'hindi', 'hinglish') then 'hi'
             else 'en'
           end as code
  ) lang
  where p.wa_opt_in  = true
    and p.phone      is not null
    and p.role       = 'mother'
    and p.due_date   is not null
    and wk.week between 4 and 40                      -- only genuine content weeks
  on conflict (user_id, dedupe_key) where dedupe_key is not null do nothing;  -- matches the partial unique index

  get diagnostics enqueued = row_count;
  return enqueued;
end;
$$;

grant execute on function public.wa_enqueue_weekly_guide(date) to service_role;


-- =====================================================================
-- HOW TO TEST  (run these by hand in the SQL Editor — NOT part of the migration)
-- =====================================================================
-- Note: in the SQL Editor, auth.uid() is null, so filter your row by name/id.
--
-- 1) Make your own profile an opted-in mother due ~20 weeks out
--    (as_of 2026-07-10, due 2026-11-27 => exactly week 20):
--
--    update public.profiles
--       set phone = '+919999999999', wa_opt_in = true, due_date = '2026-11-27'
--     where name = 'Your Name';       -- pick your row
--
-- 2) Run the brain for a given day; it returns how many it enqueued:
--    select public.wa_enqueue_weekly_guide(date '2026-07-10');     -- e.g. 1
--
-- 3) See what it queued:
--    select user_id, template_name, category, variables, status, dedupe_key
--      from public.wa_message_log order by created_at desc;
--    -- expect variables = {"name":"Your Name","week":20}, status 'queued'
--
-- 4) Run it again for the same week -> 0 (dedupe: no double-send):
--    select public.wa_enqueue_weekly_guide(date '2026-07-10');     -- 0
-- =====================================================================
