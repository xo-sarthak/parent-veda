-- 0150 — Phase 6b leftover L1: an approved campaign's words are locked
-- (2026-10-31). docs/NOTIFICATIONS-6B-PLAN.md, "As built: leftovers", L1.
--
-- WHY: approval is a promise about WHAT goes out. pv_campaign_create already
-- rewrites a draft only, but that rule lives in a function, and Directus
-- (decision 5) will write push_campaigns directly and skip every function.
-- One direct UPDATE could change the text of a campaign that is already
-- booked for tonight, after the dry run was read and after someone said yes.
-- Worse, a changed link_kind or stages would reach people the rules were
-- never checked for. A trigger holds the rule for every writer.
--
-- WHAT, once status = 'approved':
--   locked   id, kind, title, body, link_kind, link_id, stages, week_from,
--            week_to, child_months_from, child_months_to, starts_on, ends_on,
--            priority.
--   allowed  status -> 'cancelled' (with cancelled_at), approved_at, and an
--            update that changes nothing locked.
--   refused  status -> 'draft' (a back door: unapprove, edit, approve again).
-- And once status = 'cancelled', it stays cancelled: otherwise cancel, edit,
-- then set 'approved' by hand would be the same back door.
--
-- To change an approved campaign: cancel it, and create a new one with a new
-- id. Its bookings are skipped by the cancel, and the new one goes through
-- the dry run and approval like any other.
--
-- PREREQ: 0143 (push_campaigns). Safe to re-run.
-- =====================================================================

create or replace function public.pv_push_campaign_lock()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.status = 'cancelled' and new.status <> 'cancelled' then
    raise exception 'push_campaigns: % is cancelled, and a cancelled campaign stays cancelled. Create a new one with a new id.', old.id
      using errcode = 'check_violation';
  end if;

  if old.status = 'approved' then
    if new.status not in ('approved', 'cancelled') then
      raise exception 'push_campaigns: % is approved; it can only be cancelled, not set back to %.', old.id, new.status
        using errcode = 'check_violation';
    end if;
    -- One row comparison: a column added to the lock later is one more
    -- pair here, and the contract test holds the list.
    if (new.id, new.kind, new.title, new.body, new.link_kind, new.link_id,
        new.stages, new.week_from, new.week_to,
        new.child_months_from, new.child_months_to,
        new.starts_on, new.ends_on, new.priority)
       is distinct from
       (old.id, old.kind, old.title, old.body, old.link_kind, old.link_id,
        old.stages, old.week_from, old.week_to,
        old.child_months_from, old.child_months_to,
        old.starts_on, old.ends_on, old.priority)
    then
      raise exception 'push_campaigns: % is approved, so its words, link, targeting, dates, kind and priority are locked. Cancel it (pv_campaign_cancel) and create a new one with a new id.', old.id
        using errcode = 'check_violation';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists push_campaigns_lock on public.push_campaigns;
create trigger push_campaigns_lock
  before update on public.push_campaigns
  for each row execute function public.pv_push_campaign_lock();

-- A trigger function cannot be called on its own, but Supabase grants every
-- new function to anon and authenticated; take it back, as 0143 does.
revoke all on function public.pv_push_campaign_lock() from public, anon, authenticated;

-- =====================================================================
-- Verify: supabase/seed/verify_push_campaign_lock.sql
-- =====================================================================
