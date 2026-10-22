-- 0111 — the WhatsApp weekly guide follows the life stage (2026-10-23)
--
-- WHY: 0016's wa_enqueue_weekly_guide picked mothers by due_date alone. A
-- family whose pregnancy ended (a loss, or a birth before the due date) keeps
-- a due_date on the profile, so the cron kept queuing "you are now in week N
-- of your pregnancy" to her - to a mother after a loss, the worst message the
-- product could send. The app's own pregnancy messages already stop when the
-- stage moves; the server never looked.
--
-- WHAT: the same function, one extra condition. Re-creating it is safe: the
-- signature is unchanged, so the pg_cron job from 0018 keeps calling it.
--
-- The general lesson: when a fact (stage) supersedes another (due date), every
-- reader of the old fact needs the new guard - including the ones that run on
-- a schedule where nobody is watching.

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
    -- 0111: only while she is actually pregnant. A row with no stage is an
    -- older sign-up and is treated as pregnant, the same rule the app's own
    -- pregnancy messages follow (preg_messages_store).
    and coalesce(p.life_stage, 'pregnancy') = 'pregnancy'
    and wk.week between 4 and 40                      -- only genuine content weeks
  on conflict (user_id, dedupe_key) where dedupe_key is not null do nothing;  -- matches the partial unique index

  get diagnostics enqueued = row_count;
  return enqueued;
end;
$$;

grant execute on function public.wa_enqueue_weekly_guide(date) to service_role;
