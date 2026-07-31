-- =====================================================================
-- 0074_expert_fee_in_rupees.sql -- an editor types ₹800, not 80000.
-- ---------------------------------------------------------------------
-- 0072 stored the consult fee in PAISE, following the usual rule for
-- money: minor units, integers, no floating point. Razorpay takes paise
-- too, so it looked consistent.
--
-- It is the wrong convention HERE, and the reason is about people rather
-- than about money. This column is typed by a human in a form. The
-- failure mode is silent and expensive:
--
--     they mean ₹800, they type 800, the doctor is listed at ₹8.
--
-- Nothing errors. The constraint passes -- 800 is a valid non-negative
-- integer. The card renders "₹8" and looks like a bargain, and the first
-- person to notice is a parent who booked expecting it.
--
-- ---------------------------------------------------------------------
-- WHY NOT JUST LABEL THE FIELD BETTER
-- ---------------------------------------------------------------------
--
-- A field note saying "paise, not rupees" is what the runbook had, and
-- it is the weakest kind of safeguard: it protects whoever read the
-- documentation. A convention that needs a warning label is a convention
-- fighting the person using it.
--
-- Indian consultation fees are whole rupees -- ₹500, ₹800, ₹1500. Nobody
-- charges ₹800.50. So the sub-rupee precision paise buys is precision
-- this column has no use for, paid for with a 100x error waiting to
-- happen.
--
-- ---------------------------------------------------------------------
-- THE CONVENTION, STATED SO THE NEXT COLUMN GETS IT RIGHT
-- ---------------------------------------------------------------------
--
--     _inr    whole rupees. Typed by a person, read by a person.
--             products.price_inr (0049), expert_profiles.fee_inr (here).
--
--     _paise  minor units. Handed to a payment gateway.
--             programmes.price_paise (0054).
--
-- Both exist on purpose. The conversion happens ONCE, at the Razorpay
-- boundary, which is the only place that needs minor units -- rather
-- than in the head of everyone who touches the form.
--
-- programmes.price_paise is deliberately NOT changed here: it may
-- already hold live rows, and a rename with a conversion is a data
-- migration rather than a rename. Recorded in STILL-OPEN as a known
-- inconsistency instead of half-fixed today.
--
-- PREREQ: 0072.
-- =====================================================================

-- Convert rather than rename, so this is correct whether the table is
-- empty (it is today) or not (it will not be next month). round() not
-- truncate: a fee of 79999 paise was meant to be ₹800, and floor would
-- silently make it ₹799.
alter table public.expert_profiles
  add column if not exists fee_inr int not null default 0;

do $$
begin
  if exists (select 1 from information_schema.columns
              where table_name = 'expert_profiles'
                and column_name = 'fee_paise') then
    execute 'update public.expert_profiles
                set fee_inr = round(fee_paise / 100.0)
              where fee_paise > 0 and fee_inr = 0';
    execute 'alter table public.expert_profiles drop column fee_paise';
  end if;
end $$;

-- The old CHECK went with the column it named. Same rule, new name.
alter table public.expert_profiles
  drop constraint if exists expert_profiles_fee_check;
alter table public.expert_profiles
  add constraint expert_profiles_fee_check check (fee_inr >= 0);

comment on column public.expert_profiles.fee_inr is
  'WHOLE RUPEES. 800 means eight hundred rupees. Converted to paise once, at the Razorpay boundary - see PaymentService. Named _inr rather than _paise so an editor types what they mean; a field note saying "paise" only protects whoever read it.';


-- =====================================================================
-- VERIFY
--
--   select expert_id, name, fee_inr from public.expert_profiles;
--     -> 800 means eight hundred rupees
--
--   -- The old column is gone, so nothing can read it by accident:
--   select column_name from information_schema.columns
--    where table_name = 'expert_profiles' and column_name like 'fee%';
--     -> fee_inr, and nothing else
--
--   update public.expert_profiles set fee_inr = -1;
--     -> new row violates check constraint "expert_profiles_fee_check"
-- =====================================================================
