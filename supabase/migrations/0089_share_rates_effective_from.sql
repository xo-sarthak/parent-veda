-- =====================================================================
-- 0089_share_rates_effective_from.sql -- the rates are in force from
-- the start of the year, not from the day 0085 ran
-- ---------------------------------------------------------------------
-- Found by the demo seed (2026-09-21). resolve_share_bps() picks the rule
-- in force ON THE EVENT'S DATE -- correct: a statement records the rate
-- that applied when the thing happened. 0085 seeded the real rates with
-- the column default, effective_from = current_date, i.e. the day it ran.
-- Every consultation the seed backdated to August landed BEFORE that
-- date, found no rule, and froze 0% -- "To be paid · ₹0", which is the
-- ledger being honest about a rule that did not exist yet.
--
-- A rate table's first rows should be in force from before the first
-- event they could ever be asked about. Moving effective_from EARLIER on
-- a platform-default row changes nothing already frozen (rows that found
-- the rule keep their bps; rows that found nothing keep their 0 -- see
-- the note below), so this is safe, and it is an edit rather than a new
-- row precisely because it widens a window instead of changing a number.
--
-- ⚠️ Rows already frozen at 0 are NOT rewritten by this migration. The
-- ledger does not edit amounts. For the demo, run the seed's cleanup
-- block and the seed again; for anything real (there is nothing real
-- yet), it would be a reversal row and a re-accrual, by hand, on purpose.
--
-- PREREQ: 0085.
-- =====================================================================

update public.expert_share_rules
   set effective_from = date '2026-01-01'
 where expert_id is null
   and effective_to is null
   and effective_from > date '2026-01-01';

-- The column default stays current_date: a NEW row is a rate change, and a
-- rate change starts when it is added. Only the founding rows reach back.
