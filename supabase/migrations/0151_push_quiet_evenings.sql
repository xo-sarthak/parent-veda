-- 0151 — Phase 6b leftover L3: the phone's quiet, as dates (2026-10-31).
-- docs/NOTIFICATIONS-6B-PLAN.md, "As built: leftovers", L3; decision row 25.
--
-- WHY: push_audience.quiet is one yes/no, as fresh as her last app open.
-- She opens the app on day 12 of her cycle (fertile window: not quiet) and
-- not again for five days. On day 15 she is in her two-week wait, and the
-- server still reads "not quiet" and can book an offer. That is the
-- sensitive case, and a one-session phone walk cannot catch it. So the
-- phone now sends WHICH evenings in the next 14 days are quiet, worked out
-- on the phone from what it already knows (the same shape as busy_evenings,
-- B2), and pv_push_check reads the date.
--
-- ⚠️ THE SERVER STILL NEVER READS HER TTC DATA. It gets dates, nothing
-- else: no phase, no reason, no cycle day. Which of the three reasons
-- (after a loss, the two-week wait or late, a treatment round) made an
-- evening quiet stays on the phone (decision 8, row 18; data minimisation).
--
-- WHAT:
--   push_audience.quiet_evenings  date[], NULL until a phone sends it. Null
--                                 is "this build does not know", not "never
--                                 quiet": an older build keeps the yes/no.
--   pv_push_audience              gains p_quiet_evenings (default null, so an
--                                 older build's two-argument call still lands).
--   pv_push_check                 the phone_quiet line reads the dates; the
--                                 yes/no stays the fallback. Every other line
--                                 is 0143's, unchanged.
--
-- PREREQ: 0140, 0143. Run before installing a build with L3. Safe to re-run.
-- ⚠️ Do NOT re-run 0140 after this file: it would create the two-argument
-- pv_push_audience again beside this one (the ambiguity explained in 2).
-- =====================================================================

-- 1) the column --------------------------------------------------------

alter table public.push_audience
  add column if not exists quiet_evenings date[];

comment on column public.push_audience.quiet_evenings is
  'IST evenings, today to 14 days on at upload, the phone calls quiet (TTC: after a loss, two-week wait or late, a treatment round). Null = an older build that sends only the quiet yes/no.';

-- 2) pv_push_audience gains the dates ----------------------------------

-- ⚠️ DROP THE OLD SIGNATURE FIRST. "create or replace" with one more
-- parameter does not replace, it adds a second function beside the first.
-- PostgREST would then find two candidates for a call naming only the old
-- two parameters, and refuse it as ambiguous: every phone on the old build
-- would stop uploading, silently (the call is fire-and-forget).
drop function if exists public.pv_push_audience(date[], boolean);

create or replace function public.pv_push_audience(
  p_busy_evenings  date[],
  p_quiet          boolean,
  p_quiet_evenings date[] default null
)
returns void
language plpgsql
security definer set search_path = ''
as $$
declare
  uid   uuid := auth.uid();
  today date := (now() at time zone 'Asia/Kolkata')::date;
  busy  date[];
  quiet date[];
begin
  if uid is null then
    raise exception 'pv_push_audience: not signed in';
  end if;
  select coalesce(array_agg(distinct d order by d), '{}')
    into busy
    from unnest(coalesce(p_busy_evenings, '{}')) as d
   where d between today and today + 14;

  -- The same window as busy. Null stays null: an older build said nothing.
  if p_quiet_evenings is not null then
    select coalesce(array_agg(distinct d order by d), '{}')
      into quiet
      from unnest(p_quiet_evenings) as d
     where d between today and today + 14;
  end if;

  insert into public.push_audience (user_id, busy_evenings, quiet, quiet_evenings, planned_at)
  values (uid, busy, coalesce(p_quiet, false), quiet, now())
  on conflict (user_id) do update
    set busy_evenings  = excluded.busy_evenings,
        quiet          = excluded.quiet,
        quiet_evenings = excluded.quiet_evenings,
        planned_at     = now();
end;
$$;

revoke all on function public.pv_push_audience(date[], boolean, date[]) from public, anon;
grant execute on function public.pv_push_audience(date[], boolean, date[]) to authenticated;

-- 3) pv_push_check reads the dates --------------------------------------

-- Copied from 0143 (the only definition before this one), with ONE rule
-- changed (phone_quiet) and one constant added (quiet_days). Rule order,
-- reasons and every other line are 0143's.
create or replace function public.pv_push_check(p_on date, p_campaign text default null)
returns table (campaign_id text, user_id uuid, reason text, priority int, ends_on date)
language sql
stable
security definer set search_path = ''
as $$
  with k as (
    select 1  as weekly_cap,          -- row 22: ONE a week at launch. The one constant.
           7  as grace_days,          -- row 17
           14 as birth_quiet_days,    -- row 18
           14 as quiet_days           -- L3: the phone's horizon, = pv_push_audience's
  ),
  camp as (
    select c.*
      from public.push_campaigns c
     where (p_campaign is null and c.status = 'approved')
        or c.id = p_campaign
  ),
  people as (
    select p.id, p.partner_id, p.due_date, p.pregnancy_ended_at, p.life_stage_at,
           -- No stage is an older sign-up, read as pregnant: the rule the
           -- app's messages and WhatsApp (0111) follow.
           coalesce(p.life_stage, 'pregnancy') as stage
      from public.profiles p
  )
  select
    c.id,
    pp.id,
    case
      when c.status = 'cancelled' or p_on < c.starts_on or p_on > c.ends_on
        then 'not_live'
      when not exists (
             select 1 from public.push_consent pc
              where pc.user_id = pp.id and pc.stage = pp.stage and pc.granted)
        then 'no_consent'
      when not exists (
             select 1 from public.push_devices d
              where d.user_id = pp.id
                and d.link_version >= public.pv_push_link_needs(c.link_kind))
        then 'no_device'
      when public.pv_push_holdout(pp.id)
        then 'holdout'
      when u.created_at is null
        or (u.created_at at time zone 'Asia/Kolkata')::date > p_on - k.grace_days
        then 'new_user'
      when pp.pregnancy_ended_at is not null
       and not (pp.life_stage_at is not null
                and pp.pregnancy_ended_at < pp.life_stage_at)
        then 'pregnancy_loss'
      -- A missing row is NOT quiet: a phone that never uploaded has had no
      -- loss recorded on it either (decision 8).
      -- Kept for revert (0143): when coalesce(a.quiet, false) then 'phone_quiet'
      --
      -- L3 (0151): the DATES decide inside what the phone could see when it
      -- uploaded (its IST today to 14 days on). The yes/no decides where the
      -- dates cannot: a build that never sends them (null), and an evening
      -- past that fortnight. Both are exactly what 0143 did before.
      when case
             when a.quiet_evenings is null
               then coalesce(a.quiet, false)
             when p_on between (a.planned_at at time zone 'Asia/Kolkata')::date
                           and (a.planned_at at time zone 'Asia/Kolkata')::date + k.quiet_days
               then p_on = any (a.quiet_evenings)
             else coalesce(a.quiet, false)
           end
        then 'phone_quiet'
      when exists (
             select 1 from public.children ch
              where (ch.user_id = pp.id or ch.user_id = pp.partner_id)
                and ch.removed_at is null
                and ch.dob is not null
                and ch.dob >  p_on - k.birth_quiet_days
                and ch.dob <= p_on)
        then 'new_baby'
      -- The week is read from the stored due date exactly as WhatsApp reads
      -- it. When a clinic dated her, that stored date already is theirs; we
      -- never recompute it.
      when pp.stage = 'pregnancy'
       and (c.week_from is not null or c.week_to is not null)
       and (pp.due_date is null
            or public.wa_pregnancy_week(pp.due_date, p_on)
               not between coalesce(c.week_from, 0) and coalesce(c.week_to, 42))
        then 'not_targeted'
      when pp.stage = 'parenting'
       and (c.child_months_from is not null or c.child_months_to is not null)
       and not exists (
             select 1 from public.children ch
              cross join lateral (
                select (extract(year from age(p_on, ch.dob)) * 12
                        + extract(month from age(p_on, ch.dob)))::int as months
              ) m
              where (ch.user_id = pp.id or ch.user_id = pp.partner_id)
                and ch.removed_at is null
                and ch.dob is not null
                and ch.dob <= p_on
                and m.months between coalesce(c.child_months_from, 0)
                                 and coalesce(c.child_months_to, 72))
        then 'not_targeted'
      when exists (
             select 1 from public.push_sends s
              where s.campaign_id = c.id and s.user_id = pp.id)
        then 'already_reached'
      when p_on = any (coalesce(a.busy_evenings, '{}'))
        then 'busy_evening'
      when exists (
             select 1 from public.push_sends s
              where s.user_id = pp.id and s.send_on = p_on and s.status <> 'skipped')
        then 'booked_tonight'
      -- Seven rolling days, not the calendar week: a Sunday and the Monday
      -- after would be "one a week" twice in two days.
      when (select count(*) from public.push_sends s
             where s.user_id = pp.id
               and s.send_on between p_on - 6 and p_on
               and s.status in ('queued', 'sent')) >= k.weekly_cap
        then 'weekly_cap'
      else null
    end,
    c.priority,
    c.ends_on
  from camp c
  join people pp on pp.stage = any (c.stages)
  cross join k
  left join auth.users u on u.id = pp.id
  left join public.push_audience a on a.user_id = pp.id;
$$;

revoke all on function public.pv_push_check(date, text) from public, anon, authenticated;
grant execute on function public.pv_push_check(date, text) to service_role;

-- =====================================================================
-- Verify: supabase/seed/verify_push_quiet_evenings.sql
-- =====================================================================
