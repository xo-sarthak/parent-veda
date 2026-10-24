-- 0112 — the WhatsApp weekly guide stops after a loss (2026-10-24)
--
-- WHY: 0111 made the guide follow the life stage, which stops it after a
-- birth and after a move back to trying. But reporting a loss does not change
-- the stage: the app keeps her in pregnancy, on the After a loss page, with
-- `profiles.pregnancy_ended_at` set (0110). So a mother who reported a loss
-- and has not yet chosen to try again still got "you are now in week N".
-- docs/STAGE-TRANSITIONS.md B1.
--
-- WHAT: the same function, one more condition: a recorded loss stops the
-- guide UNLESS the pregnancy stage began after it.
--
-- WHY A COMPARISON AND NOT A CLEARED FLAG (derive, don't mutate): the loss is
-- never erased - its date is part of her story - and nothing has to remember
-- to clear it when she is pregnant again. A loss speaks only for the
-- pregnancy it ended: a new pregnancy has a newer `life_stage_at` (the app
-- sends it with every stage change), so the guide returns on its own. The app
-- reads the same two facts (`PregnancyEndedStore.ended`), and
-- test/stage_transitions_test.dart pins both sides.
--
-- No stage date at all (an older row) with a loss recorded: stay silent. The
-- cost of a missing week is small; the cost of the wrong message is not.
--
-- Re-creating it is safe: the signature is unchanged, so the pg_cron job from
-- 0018 keeps calling it.

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
    -- 0112: and not after a loss, unless this pregnancy began after it.
    and (p.pregnancy_ended_at is null
         or (p.life_stage_at is not null
             and p.pregnancy_ended_at < p.life_stage_at))
    and wk.week between 4 and 40                      -- only genuine content weeks
  on conflict (user_id, dedupe_key) where dedupe_key is not null do nothing;  -- matches the partial unique index

  get diagnostics enqueued = row_count;
  return enqueued;
end;
$$;

grant execute on function public.wa_enqueue_weekly_guide(date) to service_role;
