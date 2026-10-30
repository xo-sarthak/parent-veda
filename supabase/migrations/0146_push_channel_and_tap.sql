-- 0146 — Phase 6b, B5: the channel, and the tap (2026-10-30).
-- docs/NOTIFICATIONS-6B-PLAN.md, "As built: B5".
--
-- WHY: two small things the phone needs from the server.
--   1. A campaign arrived on FCM's default channel ("Miscellaneous"), so she
--      could not turn offers off on their own in Android's settings without
--      turning off everything else that lands there. The app now creates an
--      "Offers and news" channel (id 'offers_news'); pv_push_due names it.
--   2. push_sends.tapped_at (0143, row 16) had nothing that could fill it.
--      The phone has SELECT on its own push_sends rows and nothing more, on
--      purpose: an update grant would let it rewrite status or sent_at too.
--      So one narrow function, pv_push_tapped(row_id), writes the one column,
--      on her own row only.
--
-- WHAT:
--   pv_push_due(limit)     REPLACED. 0144's text with one change per branch:
--                          channel 'offers_news' instead of null.
--   pv_push_tapped(row_id) NEW. The phone calls it when she taps a campaign.
--
-- ⚠️ COMMUNITY (C3-2) ADDS A BRANCH TO pv_push_due. Start from THIS file's
-- definition, not 0144's: a copy of 0144 would put the channel back to null.
-- Re-read the latest `create or replace function public.pv_push_due` in
-- supabase/migrations before replacing it, every time.
--
-- PREREQ: 0143, 0144. Safe to re-run.
-- =====================================================================

-- 1) pv_push_due: the same rows, now on the "Offers and news" channel ---

create or replace function public.pv_push_due(p_limit int default 500)
returns table (
  queue        text,
  row_id       uuid,
  user_id      uuid,
  tokens       text[],
  title        text,
  body         text,
  data         jsonb,
  collapse_key text,
  priority     text,
  channel      text
)
language plpgsql
security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  -- A claim older than this belongs to a sender that died.
  lease interval := interval '5 minutes';
  n     int := greatest(coalesce(p_limit, 500), 1);
begin
  -- -- push_sends: tonight's campaign bookings (0143) --------------------
  -- 0146 (B5): channel 'offers_news', which the app creates
  -- (PushService.offersChannel). Nothing else in this branch changed.

  -- Past the cutoff: never a night buzz (row 20).
  update public.push_sends s
     set status = 'skipped', error = 'past_cutoff', claimed_at = null
   where s.status = 'queued' and now() >= s.send_before;

  -- No device left that can open the link (signed out, uninstalled).
  update public.push_sends s
     set status = 'skipped', error = 'no_device', claimed_at = null
    from public.push_campaigns c
   where c.id = s.campaign_id
     and s.status = 'queued'
     and now() >= (s.send_on + time '19:00') at time zone 'Asia/Kolkata'
     and not exists (
           select 1 from public.push_devices d
            where d.user_id = s.user_id
              and d.link_version >= public.pv_push_link_needs(c.link_kind));

  return query
  with due as (
    select s.id
      from public.push_sends s
     where s.status = 'queued'
       -- 19:00 IST on its evening, or later, and before its cutoff.
       and now() >= (s.send_on + time '19:00') at time zone 'Asia/Kolkata'
       and now() <  s.send_before
       and (s.claimed_at is null or s.claimed_at < now() - lease)
     order by s.send_on, s.id
     limit n
     -- Two senders at once each take different rows, never the same one.
     for update of s skip locked
  ),
  claimed as (
    update public.push_sends s
       set claimed_at = now()
      from due
     where s.id = due.id
    returning s.id, s.campaign_id, s.user_id
  )
  select 'push_sends'::text,
         k.id,
         k.user_id,
         array(select d.token from public.push_devices d
                where d.user_id = k.user_id
                  and d.link_version >= public.pv_push_link_needs(c.link_kind)
                order by d.last_seen_at desc),
         c.title,
         c.body,
         jsonb_build_object('link_kind', c.link_kind, 'link_id', c.link_id,
                            'queue', 'push_sends', 'row_id', k.id::text),
         'campaign-' || c.id,
         'normal'::text,
         'offers_news'::text
    from claimed k
    join public.push_campaigns c on c.id = k.campaign_id;

  -- -- push_tests: pv_campaign_test, now, your own devices ---------------
  -- 0146 (B5): the same channel, so a test looks exactly like the real send.

  update public.push_tests t
     set status = 'skipped', error = 'past_cutoff', claimed_at = null
   where t.status = 'queued' and now() >= t.send_before;

  update public.push_tests t
     set status = 'skipped', error = 'no_device', claimed_at = null
    from public.push_campaigns c
   where c.id = t.campaign_id
     and t.status = 'queued'
     and not exists (
           select 1 from public.push_devices d
            where d.user_id = t.user_id
              and d.link_version >= public.pv_push_link_needs(c.link_kind));

  return query
  with due as (
    select t.id
      from public.push_tests t
     where t.status = 'queued'
       and now() < t.send_before
       and (t.claimed_at is null or t.claimed_at < now() - lease)
     order by t.created_at
     limit n
     for update of t skip locked
  ),
  claimed as (
    update public.push_tests t
       set claimed_at = now()
      from due
     where t.id = due.id
    returning t.id, t.campaign_id, t.user_id
  )
  select 'push_tests'::text,
         k.id,
         k.user_id,
         array(select d.token from public.push_devices d
                where d.user_id = k.user_id
                  and d.link_version >= public.pv_push_link_needs(c.link_kind)
                order by d.last_seen_at desc),
         c.title,
         c.body,
         jsonb_build_object('link_kind', c.link_kind, 'link_id', c.link_id,
                            'queue', 'push_tests', 'row_id', k.id::text),
         'campaign-' || c.id,
         'normal'::text,
         'offers_news'::text
    from claimed k
    join public.push_campaigns c on c.id = k.campaign_id;
end;
$$;

-- Granted as in 0144: the sender's role only. `create or replace` keeps the
-- grants of the function it replaces; restated so this file stands alone.
revoke all on function public.pv_push_due(int) from public, anon, authenticated;
grant execute on function public.pv_push_due(int) to service_role;

-- 2) pv_push_tapped: she tapped a campaign ------------------------------

-- Fills tapped_at on HER OWN push_sends row, once. Returns true when this
-- call recorded the tap, false when there was nothing to record (not hers,
-- not a row, or already tapped).
--
-- ⚠️ A FUNCTION, NOT AN UPDATE GRANT. A grant is per column at best and has
-- no idea which value is sensible; this writes one column, to now(), on a
-- row whose user_id is the caller. The phone cannot backdate a tap, mark a
-- row sent, or touch anyone else's.
-- ⚠️ THE FIRST TAP WINS (coalesce). A second tap on the same notification,
-- or the same push tapped on her second phone, keeps the first time: the
-- measurement is "did she open it", and the first answer is the honest one.
-- ⚠️ NO STATUS CHECK. A tap can reach us before the sender's pv_push_mark
-- does (FCM delivers, she taps, the sender is still finishing its batch), so
-- requiring status = 'sent' would lose exactly the fastest taps.
-- push_tests is not recorded: a test is you checking the text.
create or replace function public.pv_push_tapped(p_row_id uuid)
returns boolean
language plpgsql
security definer set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null or p_row_id is null then
    return false;
  end if;
  update public.push_sends s
     set tapped_at = now()
   where s.id = p_row_id
     and s.user_id = v_uid
     and s.tapped_at is null;
  return found;
end;
$$;

revoke all on function public.pv_push_tapped(uuid) from public, anon;
grant execute on function public.pv_push_tapped(uuid) to authenticated;

-- =====================================================================
-- USEFUL COMMANDS (SQL editor)
-- =====================================================================
--   select count(*) filter (where tapped_at is not null) as tapped,
--          count(*) filter (where status = 'sent')        as sent
--     from public.push_sends where campaign_id = '<id>';
-- Verify: supabase/seed/verify_push_b5.sql
-- =====================================================================
