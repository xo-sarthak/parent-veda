-- =====================================================================
-- 0085_expert_share_rates.sql -- the REAL split, from the Commercial
-- Terms workbook (the user's table, 2026-09-19)
-- ---------------------------------------------------------------------
-- 0084 seeded placeholders and said so on every row. The workbook arrived
-- the next day and corrected two of them the wrong way round from what
-- STILL-OPEN 13.0 remembered:
--
--   recorded courses through our channels   30% to the doctor (not 70)
--   consultations                           a FLAT 80%, no 85% tier
--
-- It also names four ways of earning 0084 had no source for -- affiliate
-- income, brand sponsorship, product endorsement, articles -- and one
-- dimension it had no column for: WHICH CHANNEL brought the sale (a
-- recorded course pays 30% through ours and 55% through the doctor's own
-- code). So this migration does four things and nothing else:
--
--   1. widens `source` on the rules and the ledger
--   2. adds `channel` (platform | own_code) to both, default 'platform'
--   3. retires the placeholders, adds the real rows
--   4. teaches resolve_share_bps() and my_share_rates() about the channel
--
-- WHAT IS NOT MODELLED YET, on purpose (written up in STILL-OPEN 5.4a):
--   * a live course with several experts -- "55% pool, split by time
--     devoted" -- needs the time weights, which programme_experts does not
--     hold. Until it does, a multi-expert sale is a MANUAL row per expert.
--   * "additional 10% for a multi-expert sale through your own code" --
--     rides on the coupon attribution 13.0 items 1-3 still owe.
--   * brand sponsorship on the BRAND's own channels is a licensing fee, not
--     a share -- a manual row with share_bps = 10000 and the fee as gross.
--   * "20% of margin" on a co-developed product -- margin is not a column
--     anywhere; a manual row with the margin as gross.
-- Manual rows are not a workaround: add_manual_expert_earning() refuses a
-- row without a note the doctor can read, so every one of these lands on
-- her statement with its reason.
--
-- PREREQ: 0084, which must have RUN (this alters its tables).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. Sources. The CHECK constraints were auto-named by 0084's inline
-- `check (...)`; Postgres names them <table>_<column>_check.
-- ---------------------------------------------------------------------
alter table public.expert_share_rules
  drop constraint if exists expert_share_rules_source_check;
alter table public.expert_share_rules
  add constraint expert_share_rules_source_check
  check (source in ('consultation','masterclass','cohort','course','video',
                    'article','affiliate','sponsorship','product','referral','other'));

alter table public.expert_earnings
  drop constraint if exists expert_earnings_source_check;
alter table public.expert_earnings
  add constraint expert_earnings_source_check
  check (source in ('consultation','masterclass','cohort','course','video',
                    'article','affiliate','sponsorship','product','referral','other'));


-- ---------------------------------------------------------------------
-- 2. The channel. 'platform' is a sale ParentVeda brought; 'own_code' is
-- one the doctor's own coupon or link brought (13.0: a coupon is a claim
-- about THIS SALE, never about the parent's standing attribution). The
-- ledger freezes it like everything else, so a statement says which.
-- ---------------------------------------------------------------------
alter table public.expert_share_rules
  add column if not exists channel text not null default 'platform'
    check (channel in ('platform','own_code'));

alter table public.expert_earnings
  add column if not exists channel text not null default 'platform'
    check (channel in ('platform','own_code'));

-- The uniqueness key now includes the channel.
drop index if exists public.expert_share_rules_key;
create unique index if not exists expert_share_rules_key
  on public.expert_share_rules
     (source, channel, coalesce(expert_id, ''), min_monthly, effective_from);


-- ---------------------------------------------------------------------
-- 3. Retire the placeholders, seed the real rows.
--
-- Placeholders are DELETED if the ledger is still empty (nothing was ever
-- frozen from them, so nothing refers to them) and CLOSED (effective_to =
-- yesterday) if it is not -- a rate that has earned against it is history
-- and history is not edited. Either way, from today the real rows apply.
-- ---------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from public.expert_earnings) then
    delete from public.expert_share_rules where note like 'PLACEHOLDER%';
  else
    update public.expert_share_rules
       set effective_to = current_date - 1
     where note like 'PLACEHOLDER%' and effective_to is null;
  end if;
end $$;

insert into public.expert_share_rules (source, channel, min_monthly, share_bps, note) values
  -- Consultations: every 1:1 session; ParentVeda keeps a flat 20%.
  ('consultation', 'platform', 0, 8000, 'Every 1:1 session. ParentVeda keeps a flat 20%.'),
  -- Courses (live): every sale, whatever the source.
  ('masterclass',  'platform', 0, 5500, 'Live course: every sale, whatever the source.'),
  ('masterclass',  'own_code', 0, 5500, 'Live course: every sale, whatever the source.'),
  ('cohort',       'platform', 0, 5500, 'Live course: every sale, whatever the source.'),
  ('cohort',       'own_code', 0, 5500, 'Live course: every sale, whatever the source.'),
  -- Courses (recorded): 30% through our channels, 55% through the doctor's own code.
  ('course',       'platform', 0, 3000, 'Recorded course sold through ParentVeda''s own channels.'),
  ('course',       'own_code', 0, 5500, 'Recorded course sale the doctor sent us through their own code.'),
  -- Content: ad revenue on videos and validated articles, and affiliate income.
  ('video',        'platform', 0, 2000, 'Ad revenue from social payouts on videos that feature the doctor.'),
  ('article',      'platform', 0, 2000, 'Ad revenue on articles validated under the doctor''s name.'),
  ('affiliate',    'platform', 0, 2000, 'Affiliate income earned on the doctor''s content.'),
  -- Brand sponsorship where the doctor is the named face and ParentVeda owns
  -- the distribution. (On the brand's own channels it is a licensing fee: a
  -- manual row, share 100%, the fee as gross.)
  ('sponsorship',  'platform', 0, 3500, 'Brand sponsorship, doctor as the named face, ParentVeda owns distribution.'),
  -- Products (future): endorsement is 10% to 15% per deal -- 10% here, the
  -- deal's rate as a per-expert override row. Co-developed = 20% of margin,
  -- a manual row with the margin as gross.
  ('product',      'platform', 0, 1000, 'Endorsing a ParentVeda product: 10% to 15% per deal; override per expert.'),
  ('other',        'platform', 0,    0, 'Manual rows carry their own rate.')
on conflict do nothing;


-- ---------------------------------------------------------------------
-- 4. The resolver learns the channel. A different arity is a NEW overload,
-- so the 0084 signature is dropped first (BACKEND-PATTERNS 12f).
-- ---------------------------------------------------------------------
drop function if exists public.resolve_share_bps(text, text, date, int);

create or replace function public.resolve_share_bps(
  p_expert_id text, p_source text, p_at date, p_monthly int, p_channel text default 'platform'
) returns int
language sql stable security definer set search_path = ''
as $$
  select r.share_bps
    from public.expert_share_rules r
   where r.source = p_source
     and r.channel = coalesce(p_channel, 'platform')
     and (r.expert_id = p_expert_id or r.expert_id is null)
     and r.min_monthly <= coalesce(p_monthly, 0)
     and r.effective_from <= p_at
     and (r.effective_to is null or r.effective_to >= p_at)
   order by (r.expert_id is not null) desc, r.min_monthly desc, r.effective_from desc
   limit 1;
$$;

-- The booking trigger calls resolve_share_bps with four arguments and gets
-- the platform channel by default -- a booking made in the app is a sale
-- ParentVeda brought. When coupon attribution lands (13.0), the writer
-- passes 'own_code' for a redeemed sale; nothing else changes.

-- write_expert_earning gains the channel too, defaulted, same drop-first.
drop function if exists public.write_expert_earning(
  text, text, text, text, text, timestamptz, int, int, text, text, text);

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
  v_expert int := round(p_gross_paise * p_share_bps / 10000.0);
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

-- my_earnings() returns the row shape explicitly; the channel joins it.
drop function if exists public.my_earnings(timestamptz, timestamptz, text);

create or replace function public.my_earnings(
  p_from timestamptz, p_to timestamptz, p_source text default null
) returns table (
  id             text,
  expert_id      text,
  source         text,
  ref_kind       text,
  ref_id         text,
  title          text,
  counterparty   text,
  occurred_at    timestamptz,
  gross_paise    int,
  share_bps      int,
  expert_paise   int,
  platform_paise int,
  status         text,
  payout_id      text,
  reversal_of    text,
  note           text,
  channel        text
)
language sql stable security definer set search_path = ''
as $$
  select e.id, e.expert_id, e.source, e.ref_kind, e.ref_id, e.title,
         case when e.ref_kind = 'booking' then p.name else null end as counterparty,
         e.occurred_at, e.gross_paise, e.share_bps, e.expert_paise,
         e.platform_paise, e.status, e.payout_id, e.reversal_of, e.note, e.channel
    from public.expert_earnings e
    left join public.booking_bookings b
      on e.ref_kind = 'booking' and b.id = e.ref_id
    left join public.profiles p on p.id = b.user_id
   where e.expert_id in (select public.my_expert_ids())
     and e.occurred_at >= p_from and e.occurred_at < p_to
     and (p_source is null or e.source = p_source)
   order by e.occurred_at desc;
$$;
grant execute on function public.my_earnings(timestamptz, timestamptz, text) to authenticated;

-- Today's rates, one row per source AND channel, so the app can say
-- "30% through ParentVeda, 55% through your own code" on the Courses row.
drop function if exists public.my_share_rates();

create or replace function public.my_share_rates()
returns table (source text, channel text, share_bps int)
language sql stable security definer set search_path = ''
as $$
  select s.source, c.channel,
         coalesce(public.resolve_share_bps(
           (select min(x) from public.my_expert_ids() x), s.source, current_date, 0, c.channel), 0)
    from unnest(array['consultation','masterclass','cohort','course','video',
                      'article','affiliate','sponsorship','product']) as s(source)
   cross join unnest(array['platform','own_code']) as c(channel);
$$;
grant execute on function public.my_share_rates() to authenticated;

-- The manual writer passes the channel through (defaulted).
drop function if exists public.add_manual_expert_earning(
  text, text, text, timestamptz, int, int, text);

create or replace function public.add_manual_expert_earning(
  p_expert_id   text,
  p_source      text,
  p_title       text,
  p_occurred_at timestamptz,
  p_gross_paise int,
  p_share_bps   int,
  p_note        text,
  p_channel     text default 'platform'
) returns public.expert_earnings
language plpgsql
security definer set search_path = ''
as $$
begin
  if p_note is null or length(trim(p_note)) = 0 then
    raise exception 'a manual earning must carry a note the doctor can read';
  end if;
  return public.write_expert_earning(
    p_expert_id, p_source, 'manual', null, p_title, p_occurred_at,
    p_gross_paise, p_share_bps, 'payable', p_note, null, p_channel);
end;
$$;

revoke all on function public.add_manual_expert_earning(
  text, text, text, timestamptz, int, int, text, text) from public;
grant execute on function public.add_manual_expert_earning(
  text, text, text, timestamptz, int, int, text, text) to service_role, directus_cms;


-- ---------------------------------------------------------------------
-- VERIFY (rolls back):
--   begin;
--   select public.resolve_share_bps('meera','consultation',current_date,0);            -- 8000
--   select public.resolve_share_bps('meera','course',current_date,0);                  -- 3000
--   select public.resolve_share_bps('meera','course',current_date,0,'own_code');       -- 5500
--   select count(*) from public.expert_share_rules where note like 'PLACEHOLDER%'
--     and effective_to is null;                                                         -- 0
--   rollback;
-- =====================================================================
