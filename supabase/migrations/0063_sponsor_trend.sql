-- =====================================================================
-- 0063_sponsor_trend.sql -- "35%" is a number. "35%, up from 22%" is an
--                           argument.
-- ---------------------------------------------------------------------
-- The dashboard shows a snapshot, and a snapshot cannot answer the only
-- question that decides a renewal: is this working better than it was?
-- HR is not judged on take-up, they are judged on take-up MOVING.
--
-- NO NEW TABLES, AND THAT IS THE POINT OF THIS FILE. The obvious design
-- is a nightly snapshot table -- sponsor_stats_daily, a cron job, a
-- backfill. It would have been the wrong instinct: every fact needed
-- here is already stamped with the moment it happened.
--
--     sponsor_members.activated_at        when someone started
--     booking_bookings.created_at         when a consultation was booked
--
-- So the trend is a date_trunc away, computed from the same rows the
-- snapshot uses. A snapshot table would have been a SECOND copy of a
-- fact that already has an owner -- the thing that has gone wrong here
-- before (an app deriving referral tokens the database already minted)
-- and the thing "one authority per fact" exists to stop.
--
-- > Before adding a table that records what a number WAS, check whether
-- > the underlying rows already carry a timestamp. If they do, history
-- > is a query, not storage -- and a query cannot drift from the truth
-- > the way a copy can.
--
-- Snapshots earn their place when the source is destructive (a row that
-- gets overwritten, a counter that decrements). Neither applies here:
-- activation and booking are append-shaped. If a "removed" member were
-- ever hard-deleted rather than soft-marked, this would stop being true
-- -- which is one more reason remove_sponsor_member() is a soft delete.
--
-- SUPPRESSION APPLIES PER MONTH, and harder than on the dashboard. See
-- the note in section 2: a whole-programme cohort of 40 can still have a
-- month with two active people in it.
--
-- PREREQ: 0060 (my_sponsor_admin_id, sponsor_analytics_config), 0061.
-- =====================================================================

create or replace function public.sponsor_trend(p_months int default 12)
returns table (
  month                 date,   -- first day of the month, UTC
  activated_in_month    int,    -- new activations that month
  activated_cumulative  int,    -- everyone active by the END of that month
  consultations_booked  int     -- null when that month's cohort is too small
)
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_id  text := public.my_sponsor_admin_id();
  v_min int;
  v_n   int := least(greatest(coalesce(p_months, 12), 1), 36);
begin
  if v_id is null then
    return;             -- not an admin: zero rows, not an error
  end if;

  select min_cohort into v_min from public.sponsor_analytics_config
   where id = 'default';
  v_min := coalesce(v_min, 5);

  return query
  with months as (
    -- Generated rather than derived from the data, so a month in which
    -- nothing happened appears as a zero instead of vanishing. A gap in
    -- a chart reads as "no data"; a zero reads as "nothing happened",
    -- and only one of those is what we mean.
    select generate_series(
             date_trunc('month', now()) - ((v_n - 1) || ' months')::interval,
             date_trunc('month', now()),
             '1 month'::interval
           )::date as m
  ),
  mem as (
    select date_trunc('month', sm.activated_at)::date as m, count(*) as n
      from public.sponsor_members sm
     where sm.sponsor_id = v_id
     group by 1
  ),
  -- Cumulative counts everyone who had activated BY that month, including
  -- people later removed. A leaver does not un-happen: showing them
  -- dropping out of history would make last quarter's number change
  -- retroactively, and a report HR already forwarded would stop matching.
  bk as (
    select date_trunc('month', b.created_at)::date as m,
           count(*) filter (where b.status <> 'cancelled') as n,
           count(distinct b.user_id)                        as people
      from public.booking_bookings b
      join public.sponsor_members sm
        on sm.user_id = b.user_id and sm.sponsor_id = v_id
     group by 1
  )
  select
    months.m,
    coalesce(mem.n, 0)::int,
    (select coalesce(sum(m2.n), 0)::int
       from mem m2 where m2.m <= months.m),
    -- PER-MONTH SUPPRESSION, and it is stricter than the dashboard's on
    -- purpose. A programme with 40 activated people passes the
    -- whole-cohort threshold, but a single month in which 2 of them
    -- booked is still 2 identifiable people. The cohort that matters is
    -- the one the number is computed over, not the one on the contract.
    case when coalesce(bk.people, 0) < v_min then null
         else coalesce(bk.n, 0)::int end
  from months
  left join mem on mem.m = months.m
  left join bk  on bk.m  = months.m
  order by months.m;
end;
$$;

grant execute on function public.sponsor_trend(int) to authenticated;

comment on function public.sponsor_trend(int) is
  'Monthly take-up history for the calling admin''s organisation. Derived from activated_at / created_at rather than a snapshot table, so it cannot drift. Behavioural figures are null when that MONTH had fewer than min_cohort distinct people, which is stricter than the dashboard''s whole-programme test.';


-- =====================================================================
-- VERIFY
--
--   -- As a non-admin, zero rows rather than an error:
--   select count(*) from public.sponsor_trend();     -> 0
--
--   -- As an admin, exactly p_months rows, oldest first, no gaps:
--   select * from public.sponsor_trend(6);
--
--   -- Cumulative must never decrease:
--   select bool_and(activated_cumulative >= lag)
--     from (select activated_cumulative,
--                  lag(activated_cumulative) over (order by month) as lag
--             from public.sponsor_trend()) t
--    where lag is not null;                          -> true
--
--   -- And a small month withholds rather than showing a countable one:
--   select month, consultations_booked from public.sponsor_trend(3);
-- =====================================================================
