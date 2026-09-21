-- =====================================================================
-- 0087_expert_earning_math.sql -- the split is computed in numeric
-- ---------------------------------------------------------------------
-- Found by the demo seed (2026-09-21): a video earning of ₹12,400 at 20%
-- raised `integer out of range` inside write_expert_earning(). The line:
--
--     v_expert int := round(p_gross_paise * p_share_bps / 10000.0);
--
-- p_gross_paise (1,240,000) x p_share_bps (2,000) = 2,480,000,000, and
-- Postgres evaluates int x int AS int -- which stops at 2,147,483,647 --
-- BEFORE the division by 10000.0 would have brought it back down. It never
-- showed on a consultation (80,000 x 8,000 = 640 million) and appeared on
-- the first realistic content figure. Rupees are small; paise x basis
-- points is the product of two four-figure scalings, and that is the
-- class of overflow to expect wherever minor units meet basis points.
--
-- The rule: do money arithmetic in numeric and narrow to the column type
-- at the end, once, where a real overflow would still be a real error.
-- Same signature as 0085, so `create or replace` is enough (no arity
-- change, no drop).
--
-- Also: record_expert_payout()'s running sum is held in a bigint now. A
-- month's payable rows summing past ₹2.1 crore is not this year's problem,
-- but the variable that would silently be the problem costs nothing to
-- widen.
--
-- PREREQ: 0085.
-- =====================================================================

create or replace function public.write_expert_earning(
  p_expert_id   text,
  p_source      text,
  p_ref_kind    text,
  p_ref_id      text,
  p_title       text,
  p_occurred_at timestamptz,
  p_gross_paise int,
  p_share_bps   int,
  p_status      text,
  p_note        text default null,
  p_reversal_of text default null,
  p_channel     text default 'platform'
) returns public.expert_earnings
language plpgsql
security definer set search_path = ''
as $$
declare
  -- numeric, not int: the product of paise and basis points overflows
  -- int32 at ₹2,147 x 100% -- or ₹10,737 x 20%. See the header.
  v_expert int := round((p_gross_paise::numeric * p_share_bps) / 10000)::int;
  v_row    public.expert_earnings;
begin
  insert into public.expert_earnings
    (expert_id, source, ref_kind, ref_id, title, occurred_at,
     gross_paise, share_bps, expert_paise, platform_paise,
     status, note, reversal_of, channel)
  values
    (p_expert_id, p_source, p_ref_kind, p_ref_id, p_title, p_occurred_at,
     p_gross_paise, p_share_bps, v_expert, p_gross_paise - v_expert,
     p_status, p_note, p_reversal_of, coalesce(p_channel, 'platform'))
  returning * into v_row;
  return v_row;
end;
$$;

revoke all on function public.write_expert_earning(
  text, text, text, text, text, timestamptz, int, int, text, text, text, text) from public;

create or replace function public.record_expert_payout(
  p_expert_id  text,
  p_period_to  date,
  p_reference  text,
  p_method     text default 'manual_neft',
  p_bank_last4 text default null,
  p_note       text default null
) returns public.expert_payouts
language plpgsql
security definer set search_path = ''
as $$
declare
  v_sum   bigint;
  v_from  date;
  v_pay   public.expert_payouts;
begin
  select coalesce(sum(expert_paise), 0), min(occurred_at)::date
    into v_sum, v_from
    from public.expert_earnings
   where expert_id = p_expert_id
     and status = 'payable'
     and occurred_at::date <= p_period_to;

  if v_sum <= 0 then
    raise exception 'nothing payable for % up to %', p_expert_id, p_period_to;
  end if;

  insert into public.expert_payouts
    (expert_id, period_from, period_to, amount_paise, status, method,
     reference, bank_last4, paid_at, note)
  values
    (p_expert_id, v_from, p_period_to, v_sum::int, 'paid', p_method,
     p_reference, p_bank_last4, now(), p_note)
  returning * into v_pay;

  update public.expert_earnings
     set status = 'paid', payout_id = v_pay.id
   where expert_id = p_expert_id
     and status = 'payable'
     and occurred_at::date <= p_period_to;

  return v_pay;
end;
$$;

revoke all on function public.record_expert_payout(
  text, date, text, text, text, text) from public;
grant execute on function public.record_expert_payout(
  text, date, text, text, text, text) to service_role, directus_cms;

-- VERIFY (rolls back):
--   begin;
--   select expert_paise from public.write_expert_earning(
--     'x', 'video', 'manual', null, 't', now(), 1240000, 2000, 'payable');  -- 248000
--   rollback;
