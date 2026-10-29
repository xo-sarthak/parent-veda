-- =====================================================================
-- 0126_learning_money_and_schedule.sql -- L2b: the server decides money
-- and schedule (docs/LEARNING-ARCHITECTURE.md §5: LA-4, LA-5, LA-6,
-- LA-7, LA-8, LA-10, LA-11, LA-12, LA-13, LA-15, the server half of
-- LA-27, and LA-28 found while building this).
-- ---------------------------------------------------------------------
-- WHAT CHANGES, IN ONE LINE: before this file the PHONE decided the
-- price, whether she paid and what she owns; after it the server does,
-- and the phone's copy is a cache of the server's answer.
--
--   1.  payment_mode           one switch, 'stub' | 'live' (L.17)
--   2.  programmes             gains offering_id, display_source, the
--                              refund rule and pack size; the bundled
--                              Dart programmes are seeded (L.1)
--   3.  programme_runs         a batch of an offering (L.3)
--   4.  the view (LA-15)       every host, not the first
--   5.  payment_orders,        the receipt pattern: an order the server
--       course_purchases,      priced, a receipt the server wrote, and
--       webhook events,        the facts a refund rule needs
--       lesson opens
--   6.  the expert's cut       per offering, by agreement (user, 2026-10-29)
--   7.  price_offering()       the ONE price, read by checkout and
--                              book_slot alike
--   8.  access + receipts      has_course_access, record_course_purchase,
--                              claim_free_offering, record_stub_purchase,
--                              my_purchases (L.22), refunds (L.12)
--   9.  book_slot()            server values only; unpaid refused live
--  10.  the timetable          sessions become slots, also after publish
--  11.  shop orders            paid is written by the server (LA-13)
--  12.  LA-28                  internal functions were callable by users
--
-- THE OLD APP KEEPS WORKING. The mode starts at 'stub', and in stub mode
-- every path today's app uses still works: create-order still prices
-- an offering the server does not know from the phone's amount (marked
-- priced_by = 'client'), and book_slot still accepts the phone's
-- generated slot ids. Those two allowances are the whole legacy surface
-- and both are gated on `payment_mode() = 'stub'`. Contract first,
-- client after: L2c moves the app, then the switch goes to 'live'.
--
-- PREREQ: 0029, 0054, 0056, 0066, 0067, 0072, 0083, 0084, 0123, 0124.
-- Safe to re-run. Patterns: docs/BACKEND-PATTERNS.md §16zzj.
-- Contract test: test/learning_money_contract_test.dart.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. payment_mode -- one row, one switch.
--
-- 'stub' = no money is charged on purpose: the development preview.
-- 'live' = every rupee and every seat must be backed by a receipt.
--
-- A row, not an environment variable, because three places must agree
-- on it -- two edge functions and book_slot -- and a row is the one
-- thing all three read from the same place. Written only from the SQL
-- editor: no grant to anyone, not even the CMS, because "stop taking
-- money" or "start taking money" is not a form field.
-- ---------------------------------------------------------------------
create table if not exists public.payment_settings (
  id         text        primary key default 'default' check (id = 'default'),
  mode       text        not null default 'stub' check (mode in ('stub', 'live')),
  note       text,
  updated_at timestamptz not null default now()
);

insert into public.payment_settings (id) values ('default')
on conflict (id) do nothing;

alter table public.payment_settings enable row level security;
revoke all on public.payment_settings from anon, authenticated;

comment on table public.payment_settings is
  'stub = the no-charge preview; live = everything needs a receipt. Changed only from the SQL editor. Read through payment_mode().';

create or replace function public.payment_mode()
returns text
language sql stable security definer set search_path = ''
as $$
  select coalesce(
    (select s.mode from public.payment_settings s where s.id = 'default'),
    'stub');
$$;

revoke all on function public.payment_mode() from public, anon, authenticated;
grant execute on function public.payment_mode() to anon, authenticated, service_role;


-- ---------------------------------------------------------------------
-- 2. programmes -- the offering, for every learning kind (L.1).
--
-- offering_id    The id the APP books and pays with ('off_mc_sleepreg',
--                'off_pg_prog_mc_birth', 'ttc_yoga_pack'). The app's
--                catalogue built these with five different prefixes, so
--                the server cannot derive one from the other -- it is
--                stored. A programme made in the panel defaults to
--                'off_' || id, the prefix the app gives every merged
--                programme (booking_catalog.dart _fromLearning).
--
-- display_source 'server' = the app shows this row (a panel programme).
--                'app'    = the app shows its bundled Dart copy, and this
--                           row is only the price and the rules.
--
--   ⚠️ WHY THAT COLUMN EXISTS. mergedLearningPrograms() lets a published
--   row REPLACE the bundled programme with the same id. The server row
--   has no topics, rating, lessons or instructor, so seeding 47 rows as
--   plain published programmes would have swapped every rich card in
--   today's app for a thin one, on the day this file runs. The seed is
--   the money authority; it must not also become the display authority
--   by accident. An editor who takes a programme over in the panel sets
--   display_source = 'server', and from then on the panel's copy shows.
--
-- refund_policy  L.12, as a rule name the refund function switches on:
--                  before_start          masterclass: until N hours before
--                  before_first_session  cohort
--                  course_unopened       course: N days, at most M lessons
--                  support_only          class packs (user, 2026-10-29)
--                The numbers stay per programme: refund_window_hours
--                (0054, default 24), refund_days, refund_max_lessons.
--
-- pack_credits / pack_valid_days   What a class pack grants: N seats,
--                spendable for D days. Read by the purchase writer.
-- ---------------------------------------------------------------------
alter table public.programmes
  add column if not exists offering_id        text,
  add column if not exists display_source     text not null default 'server',
  add column if not exists refund_policy      text,
  add column if not exists refund_days        int  not null default 7,
  add column if not exists refund_max_lessons int  not null default 1,
  add column if not exists pack_credits       int,
  add column if not exists pack_valid_days    int;

alter table public.programmes drop constraint if exists programmes_display_source_ok;
alter table public.programmes add constraint programmes_display_source_ok
  check (display_source in ('server', 'app'));

alter table public.programmes drop constraint if exists programmes_refund_policy_ok;
alter table public.programmes add constraint programmes_refund_policy_ok
  check (refund_policy is null or refund_policy in
    ('before_start', 'before_first_session', 'course_unopened', 'support_only'));

alter table public.programmes drop constraint if exists programmes_pack_ok;
alter table public.programmes add constraint programmes_pack_ok check (
  (pack_credits is null or pack_credits between 1 and 50) and
  (pack_valid_days is null or pack_valid_days > 0) and
  refund_days >= 0 and refund_max_lessons >= 0);

update public.programmes set offering_id = 'off_' || id where offering_id is null;

create unique index if not exists programmes_offering_id_key
  on public.programmes (offering_id);

-- A panel-made programme gets the app's id, and the rule its kind
-- implies, without anyone having to know either.
create or replace function public.programmes_defaults()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.offering_id is null then
    new.offering_id := 'off_' || new.id;
  end if;
  if new.refund_policy is null then
    new.refund_policy := case new.kind
      when 'cohort'     then 'before_first_session'
      when 'course'     then 'course_unopened'
      when 'class_pack' then 'support_only'
      else 'before_start' end;
  end if;
  return new;
end;
$$;

drop trigger if exists programmes_defaults_trg on public.programmes;
create trigger programmes_defaults_trg
  before insert or update on public.programmes
  for each row execute function public.programmes_defaults();

-- Fire it once for rows that predate it.
update public.programmes set refund_policy = null where refund_policy is null;

comment on column public.programmes.offering_id is
  'The id the app books and pays with. Defaults to off_<id>. Seeded rows carry the app''s exact ids (five prefixes, see 0126).';
comment on column public.programmes.display_source is
  'server = the app shows this row; app = the app shows its bundled copy and this row is only price and rules (0126 header).';

-- ---- The seed: every bundled programme the app sells (L.1) -----------
-- Generated from the app's own catalogue (BookingCatalog + the bundled
-- programme lists), not copied by hand. test/learning_money_contract_test
-- holds the two equal: change a bundled price and the build fails until
-- this list (or a later migration) moves with it.
--
-- Consults are NOT here: a consult's price is its expert's fee
-- (expert_profiles), L.1. The 20 bundled consults belong to bundled
-- experts, which have no server row -- see LA-30.
--
-- `on conflict do nothing` (any conflict, id or offering_id): if an
-- editor has already made a programme under one of these ids, their row
-- stands.
insert into public.programmes
  (id, offering_id, kind, stage, title, price_paise,
   age_from_months, age_to_months, pack_credits, pack_valid_days,
   status, published_at, display_source)
select v.id, v.offering_id, v.kind, v.stage, v.title, v.price_paise,
       v.age_from, v.age_to, v.pack_credits, v.pack_valid_days,
       'published', now(), 'app'
  from (values
  ('y_flow_am', 'off_y_flow_am', 'class_pack', 'parenting', 'Morning Sun Flow', 39900, null::int, null::int, 4, 30),
  ('y_strength_rec', 'off_y_strength_rec', 'course', 'parenting', 'Everyday Strength & Mobility', 29900, null, null, null, null),
  ('pn_group', 'off_pn_group', 'class_pack', 'pregnancy', 'Trimester-Safe Prenatal Flow', 49900, null, null, 4, 30),
  ('pn_back_rec', 'off_pn_back_rec', 'course', 'pregnancy', 'Relief for a Pregnancy Back', 29900, null, null, null, null),
  ('po_group', 'off_po_group', 'class_pack', 'parenting', 'Fourth-Trimester Reset', 39900, null, null, 4, 30),
  ('po_babywearing_rec', 'off_po_babywearing_rec', 'course', 'parenting', 'Baby-in-Arms Flow', 29900, null, null, null, null),
  ('iv_group', 'off_iv_group', 'class_pack', 'parenting', 'Two-Week-Wait Calm Circle', 59900, null, null, 4, 30),
  ('br_lamaze_group', 'off_br_lamaze_group', 'class_pack', 'pregnancy', 'Lamaze Breathing for Labour', 79900, null, null, 4, 30),
  ('md_group', 'off_md_group', 'class_pack', 'parenting', 'Guided Meditation Circle', 29900, null, null, 4, 30),
  ('md_newmum_rec', 'off_md_newmum_rec', 'course', 'parenting', 'Meditation for New Mothers', 29900, null, null, null, null),
  ('co_group', 'off_co_group', 'class_pack', 'parenting', 'Core & Pelvic-Floor Rebuild', 49900, null, null, 4, 30),
  ('co_pelvic_rec', 'off_co_pelvic_rec', 'course', 'parenting', 'Pelvic-Floor Daily Ten', 29900, null, null, null, null),
  ('mc_sleepreg', 'off_mc_sleepreg', 'masterclass', 'parenting', 'The 4-Month Sleep Regression, Solved', 149900, 3, 6, null, null),
  ('co_sleep', 'off_co_sleep', 'cohort', 'parenting', 'Sleep Bootcamp', 899900, 4, 24, null, null),
  ('co_weaning', 'off_co_weaning', 'cohort', 'parenting', 'Confident Weaning', 1299900, 5, 12, null, null),
  ('co_calm', 'off_co_calm', 'cohort', 'parenting', 'Calm Parent, Calm Baby', 2499900, 0, 3, null, null),
  ('co_gentlenights', 'off_co_gentlenights', 'cohort', 'parenting', 'Gentle Nights · July cohort', 899900, 4, 24, null, null),
  ('mc_solids', 'off_mc_solids', 'masterclass', 'parenting', 'Starting solids without the stress', 99900, 5, 12, null, null),
  ('mc_wonderweeks', 'off_mc_wonderweeks', 'masterclass', 'parenting', 'Understanding the fussy stretches', 249900, 0, 20, null, null),
  ('mc_babyproof', 'off_mc_babyproof', 'masterclass', 'parenting', 'Baby-proofing for joint families', 129900, 5, 36, null, null),
  ('mc_first40', 'off_mc_first40', 'masterclass', 'parenting', 'The First 40 Days', 119900, 0, 2, null, null),
  ('prog_mc_birth', 'off_pg_prog_mc_birth', 'masterclass', 'pregnancy', 'Birth Confidence Masterclass', 79900, null, null, null, null),
  ('prog_mc_playbook', 'off_pg_prog_mc_playbook', 'masterclass', 'pregnancy', 'Pregnancy Playbook Workshop', 69900, null, null, null, null),
  ('prog_mc_first100', 'off_pg_prog_mc_first100', 'masterclass', 'pregnancy', 'The First 100 Days with Baby', 99900, null, null, null, null),
  ('prog_mc_bf', 'off_pg_prog_mc_bf', 'masterclass', 'pregnancy', 'Breastfeeding Basics', 69900, null, null, null, null),
  ('prog_ch_birthready', 'off_pg_prog_ch_birthready', 'cohort', 'pregnancy', 'Birth-Ready Bootcamp', 699900, null, null, null, null),
  ('prog_ch_first_tri', 'off_pg_prog_ch_first_tri', 'cohort', 'pregnancy', 'First-Trimester Foundations', 499900, null, null, null, null),
  ('prog_ch_fit', 'off_pg_prog_ch_fit', 'cohort', 'pregnancy', 'Fit & Strong Pregnancy', 799900, null, null, null, null),
  ('prog_ch_fourth_tri', 'off_pg_prog_ch_fourth_tri', 'cohort', 'pregnancy', 'Fourth-Trimester Prep', 649900, null, null, null, null),
  ('ongoing_checkin', 'off_mm_ongoing_checkin', 'class_pack', 'pregnancy', 'Ongoing check-in package', 329900, null, null, 4, 120),
  ('ttc_course_basics', 'ttc_course_basics', 'masterclass', 'trying', 'Fertility, honestly', 29900, null, null, null, null),
  ('ttc_course_pcos', 'ttc_course_pcos', 'cohort', 'trying', 'The PCOS programme', 249900, null, null, null, null),
  ('ttc_yoga_pack', 'ttc_yoga_pack', 'class_pack', 'trying', 'Fertility yoga, eight classes', 199900, null, null, 8, 60),
  ('ttc_loss_support', 'ttc_loss_support', 'cohort', 'trying', 'After a loss', 149900, null, null, null, null),
  ('ttc_partner_workshop', 'ttc_partner_workshop', 'masterclass', 'trying', 'The half nobody talks about', 19900, null, null, null, null),
  ('ttc_ivf_prep', 'ttc_ivf_prep', 'cohort', 'trying', 'Preparing for IVF', 299900, null, null, null, null),
  ('ttc_lifestyle_90', 'ttc_lifestyle_90', 'cohort', 'trying', 'The ninety-day programme', 179900, null, null, null, null),
  ('ttc_course_garbh', 'ttc_course_garbh', 'masterclass', 'trying', 'Preconception garbh sanskar', 0, null, null, null, null),
  ('flagship', 'off_flagship', 'course', 'parenting', 'The Complete Parenting Guide', 499900, null, null, null, null),
  ('rc_playbrain', 'off_rc_playbrain', 'course', 'parenting', 'Play & Brain', 149900, 3, 6, null, null),
  ('rc_motor', 'off_rc_motor', 'course', 'parenting', 'Motor Skills', 149900, 2, 12, null, null),
  ('rc_language', 'off_rc_language', 'course', 'parenting', 'Language & Communication', 149900, 3, 12, null, null),
  ('rc_sleep', 'off_rc_sleep', 'course', 'parenting', 'Baby Sleep, Understood', 149900, 3, 6, null, null),
  ('rc_specialneeds', 'off_rc_specialneeds', 'course', 'parenting', 'Parenting a Child with Special Needs', 499900, null, null, null, null),
  ('course_pregnancy_guide', 'off_pg_course_pregnancy_guide', 'course', 'pregnancy', 'The Complete Pregnancy Guide', 299900, null, null, null, null),
  ('course_birthprep', 'off_pg_course_birthprep', 'course', 'pregnancy', 'Birth Prep Essentials', 149900, null, null, null, null),
  ('course_trimester_fit', 'off_pg_course_trimester_fit', 'course', 'pregnancy', 'Trimester-Safe Fitness', 129900, null, null, null, null)
  ) as v(id, offering_id, kind, stage, title, price_paise,
         age_from, age_to, pack_credits, pack_valid_days)
on conflict do nothing;


-- ---------------------------------------------------------------------
-- 3. programme_runs -- one batch of an offering (L.3).
--
-- A cohort that runs again is "Batch 2", a new run: its purchases, its
-- sessions and (L4) its discussion belong to it, so batch 2 does not
-- land in a room of strangers from batch 1. A recorded course has one
-- evergreen run with no dates.
--
-- Every seeded programme gets run 1, undated. Dates arrive with the
-- sessions, in the panel.
-- ---------------------------------------------------------------------
create table if not exists public.programme_runs (
  id           text        primary key,
  programme_id text        not null references public.programmes (id) on delete cascade,
  seq          int         not null default 1,
  label        text        not null default '',
  starts_utc   timestamptz,
  ends_utc     timestamptz,
  capacity     int         check (capacity is null or capacity > 0),
  status       text        not null default 'open'
                 check (status in ('draft', 'open', 'closed', 'completed', 'cancelled')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (programme_id, seq)
);

alter table public.programme_sessions
  add column if not exists run_id text references public.programme_runs (id) on delete set null;

alter table public.programme_runs enable row level security;
revoke all on public.programme_runs from anon, authenticated;
grant select on public.programme_runs to anon, authenticated;
grant select, insert, update, delete on public.programme_runs to directus_cms;

drop policy if exists "programme_runs public read" on public.programme_runs;
create policy "programme_runs public read" on public.programme_runs
  for select to anon, authenticated
  using (exists (select 1 from public.programmes p
                  where p.id = programme_id and p.status = 'published'));

drop policy if exists "programme_runs cms write" on public.programme_runs;
create policy "programme_runs cms write" on public.programme_runs
  for all to directus_cms using (true) with check (true);

insert into public.programme_runs (id, programme_id, seq, label)
select p.id || '_r1', p.id, 1, 'Batch 1'
  from public.programmes p
on conflict do nothing;

-- The run a NEW purchase joins: the soonest dated open run still ahead,
-- else an undated open run (evergreen), else none.
create or replace function public._current_run(p_programme_id text)
returns text
language sql stable security definer set search_path = ''
as $$
  select r.id
    from public.programme_runs r
   where r.programme_id = p_programme_id
     and r.status = 'open'
     and (r.starts_utc is null or r.starts_utc > now())
   order by (r.starts_utc is null), r.starts_utc, r.seq
   limit 1;
$$;

-- The run a server slot belongs to, through its session. Null for a
-- slot the old app generated (no session behind it).
create or replace function public._slot_run(p_slot_id text)
returns text
language sql stable security definer set search_path = ''
as $$
  select s.run_id from public.programme_sessions s
   where 'ps_' || s.id = p_slot_id;
$$;


-- ---------------------------------------------------------------------
-- 4. LA-15 -- every host is visible, not the first.
--
-- THE BUG. The view resolved "the host" as `limit 1` over accepted
-- experts. A panel of three showed one; the other two had no badge, no
-- page link, and (L4) no way for the app to know they may answer in
-- the discussion. `limit 1` in a scalar subquery is a rule about
-- display that quietly became a rule about who exists.
--
-- THE FIX. `hosts` is every accepted expert as [{expert_id, role}],
-- the lead first. `expert_id` stays -- today's app reads it -- and now
-- prefers role = 'host' over a co-host who happened to be invited first.
--
-- ALSO: rows whose display_source is 'app' are left out (§2), and the
-- refund rule and offering id are appended for L2c's copy. New columns
-- go at the END: `create or replace view` may add columns, never move
-- them (16zzf).
-- ---------------------------------------------------------------------
create or replace function public._programme_lead_host(p_programme_id text)
returns text
language sql stable security definer set search_path = ''
as $$
  select pe.expert_id
    from public.programme_experts pe
   where pe.programme_id = p_programme_id and pe.status = 'accepted'
   order by (pe.role = 'host') desc, pe.invited_at
   limit 1;
$$;

create or replace view public.programmes_published as
select
  p.id,
  p.status,
  p.kind,
  p.stage,
  p.title,
  p.title_hi,
  p.subtitle,
  p.summary,
  p.summary_hi,
  p.body,
  p.body_hi,
  p.hero_image,
  p.trailer_url,
  p.price_paise,
  p.compare_at_paise,
  p.currency,
  p.capacity,
  p.certificate_enabled,
  p.published_at,
  p.updated_at,

  -- The lead host: role 'host' first, then the earliest accepted. The
  -- same rule as _programme_lead_host(), INLINED: a view's functions are
  -- run with the VIEWER's execute rights (unlike its tables), and that
  -- helper is internal -- calling it here would break the view for
  -- every parent.
  (select pe.expert_id
     from public.programme_experts pe
    where pe.programme_id = p.id and pe.status = 'accepted'
    order by (pe.role = 'host') desc, pe.invited_at
    limit 1) as expert_id,

  (select count(*) from public.programme_sessions s
    where s.programme_id = p.id) as session_count,
  (select min(s.starts_utc) from public.programme_sessions s
    where s.programme_id = p.id) as first_session_utc,
  (select max(s.starts_utc) from public.programme_sessions s
    where s.programme_id = p.id) as last_session_utc,

  (select sum(greatest(b.capacity - b.booked, 0))
     from public.booking_slots b
    where b.offering_id in (p.id, p.offering_id)) as seats_left,

  -- 0124
  p.age_from_months,
  p.age_to_months,

  -- 0126 (LA-15): the whole panel, lead first. Only accepted experts --
  -- who declined or was merely invited is not public.
  coalesce((
    select jsonb_agg(jsonb_build_object('expert_id', pe.expert_id, 'role', pe.role)
                     order by (pe.role = 'host') desc, pe.invited_at)
      from public.programme_experts pe
     where pe.programme_id = p.id and pe.status = 'accepted'
  ), '[]'::jsonb) as hosts,
  p.offering_id,
  p.refund_policy,
  p.refund_window_hours,
  p.refund_days,
  p.refund_max_lessons

from public.programmes p
where p.status = 'published'
  and p.display_source = 'server';

grant select on public.programmes_published to anon, authenticated;


-- ---------------------------------------------------------------------
-- 5. The receipt pattern.
--
-- payment_orders     one row per attempt to take money: what the SERVER
--                    priced, for whom, against which Razorpay order.
--                    Written only by the create-order function.
-- course_purchases   the receipt: what she owns because a payment (or a
--                    free claim, or the stub) was proven. Written only by
--                    the functions below. The name is the brief's; it
--                    holds consults and packs too, so Your bookings has
--                    one payments history (L.22).
--
-- THE GENERAL FACT. "She paid" is not one event, it is two that can
-- arrive in either order and either can be lost: the phone's verify
-- call (fast, but the phone can die) and Razorpay's webhook (slow, but
-- retried for a day). So the receipt writer must be IDEMPOTENT on the
-- payment id -- whichever arrives second finds the receipt already
-- written and does nothing. A unique index makes "nothing" a fact the
-- database enforces rather than a check the code remembers.
--
-- MONEY ROWS OUTLIVE THE ACCOUNT. user_id is `on delete set null`, not
-- cascade: a deleted account must stop being identifiable, but the
-- record that ₹1,499 was taken (and perhaps refunded) is a tax and
-- dispute record, and deleting it with the person is how the books
-- stop adding up.
-- ---------------------------------------------------------------------
create table if not exists public.payment_orders (
  id                  text        primary key
                        default ('po_' || replace(gen_random_uuid()::text, '-', '')),
  user_id             uuid        references auth.users (id) on delete set null,
  purpose             text        not null check (purpose in ('offering', 'shop')),
  offering_id         text,
  programme_id        text        references public.programmes (id),
  run_id              text        references public.programme_runs (id),
  amount_paise        int         not null check (amount_paise > 0),
  currency            text        not null default 'INR',
  -- 'server' = we looked the price up. 'client' = stub mode only: an
  -- offering the server does not know yet, charged at the phone's figure
  -- and marked so the dashboard shows it. Never possible in live mode.
  priced_by           text        not null check (priced_by in ('server', 'client')),
  mode                text        not null check (mode in ('stub', 'live')),
  razorpay_order_id   text        unique,
  razorpay_payment_id text        unique,
  status              text        not null default 'created'
                        check (status in ('created', 'paid', 'failed', 'refunded')),
  confirmed_via       text        check (confirmed_via in ('verify', 'webhook')),
  created_at          timestamptz not null default now(),
  paid_at             timestamptz,
  refunded_at         timestamptz
);

create index if not exists payment_orders_user_idx
  on public.payment_orders (user_id, created_at desc);

alter table public.payment_orders enable row level security;
revoke all on public.payment_orders from anon, authenticated;
grant select on public.payment_orders to authenticated;
drop policy if exists "payment_orders own read" on public.payment_orders;
create policy "payment_orders own read" on public.payment_orders
  for select to authenticated using (user_id = auth.uid());

create table if not exists public.course_purchases (
  id                  text        primary key
                        default ('pur_' || replace(gen_random_uuid()::text, '-', '')),
  user_id             uuid        references auth.users (id) on delete set null,
  offering_id         text        not null,
  programme_id        text        references public.programmes (id),
  run_id              text        references public.programme_runs (id),
  kind                text        not null,       -- masterclass|cohort|course|class_pack|consult
  title               text        not null default '',
  stage               text,                       -- the app's ServiceStage name
  amount_paise        int         not null default 0 check (amount_paise >= 0),
  currency            text        not null default 'INR',
  provider            text        not null check (provider in ('razorpay', 'free', 'stub')),
  -- The payment mode the receipt was written under. A Razorpay TEST
  -- payment is provider 'razorpay' too, so the provider alone cannot
  -- tell a rehearsal from a sale; this can. Live mode honours only
  -- live receipts, so switching to live cannot leave every tester
  -- owning what they bought with a test card.
  mode                text        not null default 'stub' check (mode in ('stub', 'live')),
  razorpay_payment_id text        unique,
  payment_order_id    text        unique references public.payment_orders (id),
  status              text        not null default 'active'
                        check (status in ('active', 'refund_requested', 'refunded', 'revoked')),
  paid_at             timestamptz not null default now(),
  refund_requested_at timestamptz,
  refunded_at         timestamptz,
  refund_id           text,
  refund_paise        int,
  created_at          timestamptz not null default now()
);

create index if not exists course_purchases_user_idx
  on public.course_purchases (user_id, paid_at desc);
create index if not exists course_purchases_programme_idx
  on public.course_purchases (programme_id, user_id);

-- A free or stub claim is once per person per offering per run, so a
-- double tap is one receipt, not two.
create unique index if not exists course_purchases_claim_once
  on public.course_purchases (user_id, offering_id, coalesce(run_id, ''))
  where provider in ('free', 'stub') and status = 'active';

alter table public.course_purchases enable row level security;
revoke all on public.course_purchases from anon, authenticated;
grant select on public.course_purchases to authenticated;
drop policy if exists "course_purchases own read" on public.course_purchases;
create policy "course_purchases own read" on public.course_purchases
  for select to authenticated using (user_id = auth.uid());

comment on table public.course_purchases is
  'The receipt. Server-written only (verify, webhook, free claim, stub). Idempotent on razorpay_payment_id. A refund sets status; the row is never deleted.';

-- Razorpay retries a webhook until it gets a 2xx, for up to a day. The
-- event id makes a retry recognisable.
create table if not exists public.payment_webhook_events (
  event_id     text        primary key,
  event        text        not null,
  received_at  timestamptz not null default now(),
  processed_at timestamptz,
  payload      jsonb       not null default '{}'::jsonb
);

alter table public.payment_webhook_events enable row level security;
revoke all on public.payment_webhook_events from anon, authenticated;

-- What the course refund rule needs: which lessons she has opened. The
-- app starts writing it in L2c; until then every count is zero, so a
-- course refund within 7 days is always allowed -- the generous side.
create table if not exists public.programme_lesson_opens (
  user_id         uuid        not null references auth.users (id) on delete cascade,
  programme_id    text        not null references public.programmes (id) on delete cascade,
  lesson_id       text        not null,
  first_opened_at timestamptz not null default now(),
  primary key (user_id, programme_id, lesson_id)
);

alter table public.programme_lesson_opens enable row level security;
revoke all on public.programme_lesson_opens from anon, authenticated;
grant select on public.programme_lesson_opens to authenticated;
drop policy if exists "lesson_opens own read" on public.programme_lesson_opens;
create policy "lesson_opens own read" on public.programme_lesson_opens
  for select to authenticated using (user_id = auth.uid());


-- ---------------------------------------------------------------------
-- 6. The expert's cut, per offering (user, 2026-10-29).
--
-- "The cut is not decided. It might be variable according to the
-- course, or the format, and it will be an agreement with the expert."
-- So the AGREEMENT is where the number lives, and programme_experts --
-- one row per expert per programme, already accepted by the expert --
-- is exactly that agreement. It gains two optional terms:
--
--   share_bps         a percentage of what the seat was worth
--   share_flat_paise  a fixed amount per seat, whatever the price
--                     (the user's case: 10% of a ₹250 masterclass is
--                     ₹25, which no expert signs; ₹200 a seat might be)
--
-- Precedence, most specific first: this agreement -> the expert's own
-- rule in expert_share_rules -> the default rule for the format. Both
-- empty = today's behaviour exactly. Consults keep using
-- expert_share_rules, which is already per expert.
--
-- AND A CREDIT DOES NOT CHANGE IT. A seat covered by a sponsor,
-- referral or pack credit earns the expert the same cut of the same
-- server price as a seat paid in cash: the credit changes who paid
-- ParentVeda, not what the seat was worth (user, 2026-10-29).
-- ---------------------------------------------------------------------
alter table public.programme_experts
  add column if not exists share_bps        int,
  add column if not exists share_flat_paise int;

alter table public.programme_experts drop constraint if exists programme_experts_share_ok;
alter table public.programme_experts add constraint programme_experts_share_ok check (
  (share_bps is null or share_bps between 0 and 10000) and
  (share_flat_paise is null or share_flat_paise >= 0) and
  not (share_bps is not null and share_flat_paise is not null));

comment on column public.programme_experts.share_bps is
  'This expert''s agreed cut on THIS programme, in basis points of each seat''s value. Null = expert_share_rules decides.';
comment on column public.programme_experts.share_flat_paise is
  'Or a fixed amount per seat, in paise. At most one of the two is set.';

-- class_pack becomes its own format, so its cut can differ from a
-- masterclass's. The list is 0085's in full plus class_pack: 0085 widened
-- it after 0084 (article, affiliate, sponsorship, product), and a list
-- copied from 0084 is refused by Postgres because live rows already use
-- those values -- the constraint check is what caught this file copying
-- a stale definition.
alter table public.expert_share_rules drop constraint if exists expert_share_rules_source_check;
alter table public.expert_share_rules add constraint expert_share_rules_source_check
  check (source in ('consultation','masterclass','cohort','course','class_pack','video',
                    'article','affiliate','sponsorship','product','referral','other'));
alter table public.expert_earnings drop constraint if exists expert_earnings_source_check;
alter table public.expert_earnings add constraint expert_earnings_source_check
  check (source in ('consultation','masterclass','cohort','course','class_pack','video',
                    'article','affiliate','sponsorship','product','referral','other'));

-- The Commercial Terms workbook (0085) has no class-pack row. A pack is
-- live group teaching, so it takes the live-course rate, 55%, on both
-- channels -- an agreement on programme_experts overrides it. In force
-- from 2026-01-01 like 0085's founding rows (0089: a rate table's first
-- rows must predate every event they could be asked about).
insert into public.expert_share_rules
  (source, channel, min_monthly, share_bps, effective_from, note) values
  ('class_pack', 'platform', 0, 5500, date '2026-01-01',
   'Class pack: the live-course rate until the workbook names one. Override per expert on programme_experts.'),
  ('class_pack', 'own_code', 0, 5500, date '2026-01-01',
   'Class pack: the live-course rate until the workbook names one. Override per expert on programme_experts.')
on conflict do nothing;

-- A ledger row whose expert amount is GIVEN (a flat agreement) rather
-- than computed from a rate. share_bps is still recorded, as the rate
-- that amount works out to, so a statement can show a percentage.
create or replace function public.write_expert_earning_amount(
  p_expert_id    text,
  p_source       text,
  p_ref_kind     text,
  p_ref_id       text,
  p_title        text,
  p_occurred_at  timestamptz,
  p_gross_paise  int,
  p_expert_paise int,
  p_status       text,
  p_note         text default null
) returns public.expert_earnings
language plpgsql
security definer set search_path = ''
as $$
declare
  v_row public.expert_earnings;
  v_bps int := case when p_gross_paise > 0
                    then least(10000, round(p_expert_paise * 10000.0 / p_gross_paise))::int
                    else 0 end;
begin
  insert into public.expert_earnings
    (expert_id, source, ref_kind, ref_id, title, occurred_at,
     gross_paise, share_bps, expert_paise, platform_paise, status, note)
  values
    (p_expert_id, p_source, p_ref_kind, p_ref_id, p_title, p_occurred_at,
     p_gross_paise, v_bps, p_expert_paise, p_gross_paise - p_expert_paise,
     p_status, p_note)
  returning * into v_row;
  return v_row;
end;
$$;

revoke all on function public.write_expert_earning_amount(
  text, text, text, text, text, timestamptz, int, int, text, text)
  from public, anon, authenticated;

-- The booking writer, 0084's body with three changes, marked (0126):
--   * the programme is found by its offering_id as well as its id --
--     bookings carry the APP's id ('off_mc_sleepreg'), so 0084's
--     `p.id = new.offering_id` never matched and every class fell back;
--   * the format follows the programme's kind (class_pack, course);
--   * the agreement on programme_experts wins when it has terms.
create or replace function public.expert_earning_from_booking()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
declare
  v_expert    text;
  v_capacity  int;
  v_source    text;
  v_gross     int;
  v_monthly   int;
  v_bps       int;
  v_existing  public.expert_earnings;
  v_kind      text;
  v_programme text;
  v_agree_bps int;
  v_flat      int;
  v_title     text;
begin
  select s.expert_id, s.capacity into v_expert, v_capacity
    from public.booking_slots s where s.id = new.slot_id;
  if v_expert is null then return new; end if;

  if tg_op = 'INSERT' then
    if new.status <> 'upcoming' then return new; end if;

    if v_capacity = 1 then
      v_source := 'consultation';
      select coalesce(new.price_paise, ep.fee_inr * 100, 0) into v_gross
        from public.expert_profiles ep where ep.expert_id = v_expert;
      if v_gross is null then v_gross := coalesce(new.price_paise, 0); end if;
    else
      -- (0126) by offering_id too.
      select p.id, p.kind, coalesce(new.price_paise, p.price_paise, 0)
        into v_programme, v_kind, v_gross
        from public.programmes p
       where p.offering_id = new.offering_id or p.id = new.offering_id
       order by (p.offering_id = new.offering_id) desc
       limit 1;
      -- (0126) the format follows the kind.
      v_source := case v_kind
        when 'cohort'     then 'cohort'
        when 'course'     then 'course'
        when 'class_pack' then 'class_pack'
        else 'masterclass' end;
      if v_gross is null then v_gross := coalesce(new.price_paise, 0); end if;

      -- (0126) the agreement.
      if v_programme is not null then
        select pe.share_bps, pe.share_flat_paise into v_agree_bps, v_flat
          from public.programme_experts pe
         where pe.programme_id = v_programme
           and pe.expert_id = v_expert
           and pe.status = 'accepted';
      end if;
    end if;

    v_title := case when v_source = 'consultation' then 'Consultation' else new.title end;

    if v_flat is not null then
      perform public.write_expert_earning_amount(
        v_expert, v_source, 'booking', new.id, v_title,
        new.starts_utc, v_gross, v_flat, 'accrued', 'Agreed flat amount per seat');
      return new;
    end if;

    select count(*) into v_monthly
      from public.expert_earnings e
     where e.expert_id = v_expert
       and e.source = v_source
       and e.status in ('payable','paid')
       and date_trunc('month', e.occurred_at) = date_trunc('month', new.starts_utc);

    v_bps := coalesce(v_agree_bps, public.resolve_share_bps(
      v_expert, v_source, (new.starts_utc at time zone 'Asia/Kolkata')::date, v_monthly), 0);

    perform public.write_expert_earning(
      v_expert, v_source, 'booking', new.id, v_title,
      new.starts_utc, v_gross, v_bps, 'accrued');
    return new;
  end if;

  -- UPDATE (0084, unchanged)
  if new.status = old.status then return new; end if;

  select * into v_existing from public.expert_earnings e
   where e.ref_kind = 'booking' and e.ref_id = new.id and e.reversal_of is null
   order by e.created_at desc limit 1;
  if v_existing.id is null then return new; end if;

  if new.status in ('attended','missed') and v_existing.status = 'accrued' then
    update public.expert_earnings set status = 'payable' where id = v_existing.id;
  elsif new.status = 'cancelled' then
    perform public.write_booking_reversal(v_existing);
  end if;
  return new;
end;
$$;


-- ---------------------------------------------------------------------
-- 7. price_offering() -- the ONE price.
--
-- Checkout (create-order) and the seat (book_slot) both ask this, so
-- there is no second place for the price to differ. It also answers
-- what a SEAT is worth, which is not always the price:
--   masterclass  the price (one session)
--   cohort       the price over the run's sessions (one seat each)
--   class pack   the price over the pack's credits
--   consult      the expert's fee
-- The seat value is what book_slot records on the booking, and so what
-- the expert's cut is taken from: a 4-class pack must not pay the
-- teacher the whole pack price four times.
--
-- Unknown offering -> {known: false}. Never a guess.
-- ---------------------------------------------------------------------
create or replace function public.price_offering(p_offering_id text)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  p        public.programmes;
  ep       public.expert_profiles;
  v_run    text;
  v_n      int;
  v_seat   int;
  v_expert text;
begin
  select * into p from public.programmes x
   where x.offering_id = p_offering_id and x.status = 'published';

  if p.id is not null then
    v_run := public._current_run(p.id);
    if p.kind = 'cohort' then
      select count(*) into v_n from public.programme_sessions s
       where s.programme_id = p.id and (v_run is null or s.run_id = v_run or s.run_id is null);
      v_seat := p.price_paise / greatest(v_n, 1);
    elsif p.kind = 'class_pack' then
      v_seat := p.price_paise / greatest(coalesce(p.pack_credits, 1), 1);
    else
      v_seat := p.price_paise;
    end if;

    return jsonb_build_object(
      'known',           true,
      'source',          'programme',
      'offering_id',     p.offering_id,
      'programme_id',    p.id,
      'kind',            p.kind,
      'title',           p.title,
      'stage',           case p.stage when 'trying' then 'tryingToConceive' else p.stage end,
      'price_paise',     p.price_paise,
      'seat_paise',      v_seat,
      'run_id',          v_run,
      'expert_id',       public._programme_lead_host(p.id),
      'pack_credits',    p.pack_credits,
      'pack_valid_days', p.pack_valid_days);
  end if;

  -- A consult with a real expert: off_exp_<expert id> (booking_catalog
  -- _fromExpert), priced from expert_profiles.fee_inr.
  if p_offering_id like 'off\_exp\_%' then
    v_expert := substr(p_offering_id, 9);
    select * into ep from public.expert_profiles x
     where x.expert_id = v_expert and x.status = 'published' and x.takes_consults;
    if ep.expert_id is not null and ep.fee_inr > 0 then
      return jsonb_build_object(
        'known',        true,
        'source',       'consult',
        'offering_id',  p_offering_id,
        'programme_id', null,
        'kind',         'consult',
        'title',        'Consult · ' || ep.name,
        'stage',        case ep.domain when 'pregnancy' then 'pregnancy'
                                       when 'ttc' then 'tryingToConceive'
                                       else 'parenting' end,
        'price_paise',  ep.fee_inr * 100,
        'seat_paise',   ep.fee_inr * 100,
        'run_id',       null,
        'expert_id',    ep.expert_id,
        'duration_min', ep.duration_min,
        'pack_credits', 1);
    end if;
  end if;

  return jsonb_build_object('known', false, 'offering_id', p_offering_id);
end;
$$;

revoke all on function public.price_offering(text) from public, anon, authenticated;
grant execute on function public.price_offering(text) to authenticated, service_role;


-- ---------------------------------------------------------------------
-- 8. Access and receipts.
-- ---------------------------------------------------------------------

-- has_course_access(programme, what, run) -- THE access rule (§2).
-- Booking, playback and posting all ask this one function, so there is
-- no second place the answer could differ.
--   seat       masterclass / cohort: an active receipt for this run (or
--              an undated one). class pack: an unspent credit.
--   recording  any active receipt, any run -- recordings are for life
--              (L.13) -- or being one of its accepted hosts.
--   thread     an active receipt for this run, or a host (L.4).
-- A receipt (or credit) written in stub mode -- the no-charge preview
-- or a Razorpay TEST payment -- counts only while the mode is 'stub':
-- going live must not leave every tester owning every course.
create or replace function public.has_course_access(
  p_programme_id text,
  p_what         text,
  p_run_id       text default null
) returns boolean
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_uid  uuid := auth.uid();
  v_live boolean := public.payment_mode() = 'live';
  v_kind text;
  v_off  text;
begin
  if v_uid is null or p_programme_id is null then return false; end if;
  select p.kind, p.offering_id into v_kind, v_off
    from public.programmes p where p.id = p_programme_id;
  if v_kind is null then return false; end if;

  if p_what in ('recording', 'thread') and exists (
    select 1 from public.programme_experts pe
     where pe.programme_id = p_programme_id and pe.status = 'accepted'
       and pe.expert_id in (select public.my_expert_ids())
  ) then
    return true;
  end if;

  if p_what = 'seat' and v_kind = 'class_pack' then
    return exists (
      select 1 from public.consult_credits c
       where c.user_id = v_uid and c.offering_scope = v_off
         and c.booking_id is null and c.voided_at is null
         and (c.expires_at is null or c.expires_at > now())
         and (not v_live or c.source <> 'stub_purchase'));
  end if;

  return exists (
    select 1 from public.course_purchases cp
     where cp.user_id = v_uid
       and cp.programme_id = p_programme_id
       and cp.status = 'active'
       and (not v_live or cp.mode = 'live')
       and (p_what = 'recording'
            or p_run_id is null or cp.run_id is null or cp.run_id = p_run_id));
end;
$$;

revoke all on function public.has_course_access(text, text, text) from public, anon, authenticated;
grant execute on function public.has_course_access(text, text, text) to authenticated;

-- The one receipt writer. Every path that gives her something --
-- verify, webhook, free claim, stub -- ends here, so a receipt always
-- has the same shape and a pack always grants the same credits.
create or replace function public._write_purchase(
  p_uid              uuid,
  p_offering_id      text,
  p_amount_paise     int,
  p_provider         text,
  p_payment_id       text,
  p_payment_order_id text,
  p_run_id           text,
  p_mode             text
) returns public.course_purchases
language plpgsql
security definer set search_path = ''
as $$
declare
  v_price jsonb := public.price_offering(p_offering_id);
  v_row   public.course_purchases;
  v_kind  text  := coalesce(v_price->>'kind', 'unknown');
  v_n     int;
begin
  insert into public.course_purchases
    (user_id, offering_id, programme_id, run_id, kind, title, stage,
     amount_paise, provider, mode, razorpay_payment_id, payment_order_id)
  values
    (p_uid, p_offering_id, v_price->>'programme_id',
     coalesce(p_run_id, v_price->>'run_id'), v_kind,
     coalesce(v_price->>'title', ''), v_price->>'stage',
     coalesce(p_amount_paise, 0), p_provider, p_mode,
     p_payment_id, p_payment_order_id)
  on conflict do nothing
  returning * into v_row;

  if v_row.id is null then
    -- Already written (the second of verify and webhook, or a double
    -- tap): return the existing receipt, grant nothing again.
    select * into v_row from public.course_purchases cp
     where (p_payment_id is not null and cp.razorpay_payment_id = p_payment_id)
        or (p_payment_id is null and cp.user_id = p_uid
            and cp.offering_id = p_offering_id and cp.provider = p_provider
            and cp.status = 'active')
     order by cp.created_at desc limit 1;
    return v_row;
  end if;

  -- A consult or a pack is bought as credits (the 0066 ledger), scoped
  -- to this offering. The purchase id is the grant key, so a replay
  -- lands on the same rows.
  if v_kind in ('consult', 'class_pack') then
    v_n := coalesce((v_price->>'pack_credits')::int, 1);
    perform public.grant_consult_credits(
      p_uid, v_n,
      -- 'stub_purchase' for anything bought in stub mode, test cards
      -- included; book_slot will not spend those once live.
      case when p_mode = 'stub' then 'stub_purchase' else 'purchase' end,
      v_row.id, 'system', p_offering_id,
      (v_price->>'pack_valid_days')::int);
  end if;

  return v_row;
end;
$$;

revoke all on function public._write_purchase(uuid, text, int, text, text, text, text, text)
  from public, anon, authenticated;

-- Called by create-order (service role). Prices the order on the
-- server and records it BEFORE Razorpay hears of it, so every Razorpay
-- order we create has a row saying who it was for and what it cost.
create or replace function public.open_payment_order(
  p_user_id       uuid,
  p_purpose       text,
  p_offering_id   text,
  p_server_amount int,     -- shop: what the function priced from products
  p_client_amount int      -- what the phone sent; stub fallback only
) returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  v_mode   text := public.payment_mode();
  v_price  jsonb;
  v_amount int;
  v_by     text;
  v_row    public.payment_orders;
begin
  if p_user_id is null then
    return jsonb_build_object('ok', false, 'reason', 'not_signed_in');
  end if;

  if p_purpose = 'offering' then
    v_price := public.price_offering(p_offering_id);
    if (v_price->>'known')::boolean then
      v_amount := (v_price->>'price_paise')::int;
      v_by := 'server';
      if v_amount = 0 then
        return jsonb_build_object('ok', false, 'reason', 'free');
      end if;
      -- Do not take money twice for something she already owns.
      if v_price->>'kind' in ('masterclass', 'cohort', 'course') and exists (
        select 1 from public.course_purchases cp
         where cp.user_id = p_user_id
           and cp.programme_id = v_price->>'programme_id'
           and cp.status = 'active' and (v_mode = 'stub' or cp.mode = 'live')
           and (cp.run_id is null or v_price->>'run_id' is null
                or cp.run_id = v_price->>'run_id')
      ) then
        return jsonb_build_object('ok', false, 'reason', 'already_owned');
      end if;
    elsif v_mode = 'stub' and coalesce(p_client_amount, 0) > 0 then
      v_amount := p_client_amount;
      v_by := 'client';
    else
      return jsonb_build_object('ok', false, 'reason', 'unknown_offering');
    end if;
  elsif p_purpose = 'shop' then
    if coalesce(p_server_amount, 0) > 0 then
      v_amount := p_server_amount;
      v_by := 'server';
    elsif v_mode = 'stub' and coalesce(p_client_amount, 0) > 0 then
      v_amount := p_client_amount;
      v_by := 'client';
    else
      return jsonb_build_object('ok', false, 'reason', 'unpriced_lines');
    end if;
  else
    return jsonb_build_object('ok', false, 'reason', 'bad_purpose');
  end if;

  insert into public.payment_orders
    (user_id, purpose, offering_id, programme_id, run_id,
     amount_paise, priced_by, mode)
  values
    (p_user_id, p_purpose, p_offering_id, v_price->>'programme_id',
     v_price->>'run_id', v_amount, v_by, v_mode)
  returning * into v_row;

  return jsonb_build_object(
    'ok', true, 'payment_order_id', v_row.id,
    'amount_paise', v_amount, 'priced_by', v_by, 'mode', v_mode);
end;
$$;

revoke all on function public.open_payment_order(uuid, text, text, int, int)
  from public, anon, authenticated;
grant execute on function public.open_payment_order(uuid, text, text, int, int) to service_role;

-- Called by verify and by the webhook (service role). Idempotent: the
-- second caller gets the first caller's receipt.
create or replace function public.record_course_purchase(
  p_razorpay_order_id   text,
  p_razorpay_payment_id text,
  p_via                 text
) returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  po  public.payment_orders;
  cp  public.course_purchases;
begin
  select * into po from public.payment_orders
   where razorpay_order_id = p_razorpay_order_id for update;
  if po.id is null then
    return jsonb_build_object('ok', false, 'reason', 'unknown_order');
  end if;

  if po.status = 'paid' and po.razorpay_payment_id is distinct from p_razorpay_payment_id then
    -- Two payments against one order. Razorpay normally prevents it;
    -- if it happens, a human looks -- the second is not silently kept.
    return jsonb_build_object('ok', false, 'reason', 'order_paid_by_another_payment',
                              'payment_order_id', po.id);
  end if;

  if po.status = 'created' or po.status = 'failed' then
    update public.payment_orders
       set status = 'paid', razorpay_payment_id = p_razorpay_payment_id,
           paid_at = now(), confirmed_via = p_via
     where id = po.id
    returning * into po;
  end if;

  if po.purpose = 'shop' then
    return jsonb_build_object('ok', true, 'purpose', 'shop', 'payment_order_id', po.id);
  end if;

  -- The ORDER's mode, not today's: a test payment that settles after the
  -- switch to live is still a test payment.
  cp := public._write_purchase(po.user_id, po.offering_id, po.amount_paise,
          'razorpay', p_razorpay_payment_id, po.id, po.run_id, po.mode);

  return jsonb_build_object('ok', true, 'purpose', 'offering',
    'payment_order_id', po.id, 'purchase_id', cp.id);
end;
$$;

revoke all on function public.record_course_purchase(text, text, text)
  from public, anon, authenticated;
grant execute on function public.record_course_purchase(text, text, text) to service_role;

create or replace function public.record_payment_failed(p_razorpay_order_id text)
returns void
language sql
security definer set search_path = ''
as $$
  update public.payment_orders set status = 'failed'
   where razorpay_order_id = p_razorpay_order_id and status = 'created';
$$;

revoke all on function public.record_payment_failed(text) from public, anon, authenticated;
grant execute on function public.record_payment_failed(text) to service_role;

-- A free offering gets a REAL receipt (today the phone just mints one).
create or replace function public.claim_free_offering(p_offering_id text)
returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_price jsonb := public.price_offering(p_offering_id);
  cp      public.course_purchases;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_signed_in');
  end if;
  if not coalesce((v_price->>'known')::boolean, false) then
    return jsonb_build_object('ok', false, 'reason', 'unknown_offering');
  end if;
  if (v_price->>'price_paise')::int <> 0 then
    return jsonb_build_object('ok', false, 'reason', 'not_free');
  end if;
  cp := public._write_purchase(v_uid, p_offering_id, 0, 'free', null, null, null,
          public.payment_mode());
  return jsonb_build_object('ok', true, 'purchase_id', cp.id);
end;
$$;

revoke all on function public.claim_free_offering(text) from public, anon, authenticated;
grant execute on function public.claim_free_offering(text) to authenticated;

-- The no-charge preview, on the server, and ONLY in stub mode (L.17).
-- This is what the phone's `notConfigured` becomes in L2c. Switch the
-- mode to live and this door shuts for every build at once -- the fix
-- for LA-7 is that a release build no longer gets to decide.
create or replace function public.record_stub_purchase(p_offering_id text)
returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_price jsonb := public.price_offering(p_offering_id);
  cp      public.course_purchases;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'not_signed_in');
  end if;
  if public.payment_mode() <> 'stub' then
    return jsonb_build_object('ok', false, 'reason', 'live_mode');
  end if;
  if not coalesce((v_price->>'known')::boolean, false) then
    return jsonb_build_object('ok', false, 'reason', 'unknown_offering');
  end if;
  cp := public._write_purchase(v_uid, p_offering_id,
          (v_price->>'price_paise')::int, 'stub', null, null, null, 'stub');
  return jsonb_build_object('ok', true, 'purchase_id', cp.id);
end;
$$;

revoke all on function public.record_stub_purchase(text) from public, anon, authenticated;
grant execute on function public.record_stub_purchase(text) to authenticated;

-- L2c's lesson player calls this; the course refund rule counts it.
create or replace function public.record_lesson_open(p_programme_id text, p_lesson_id text)
returns boolean
language plpgsql
security definer set search_path = ''
as $$
begin
  if auth.uid() is null or not public.has_course_access(p_programme_id, 'recording') then
    return false;
  end if;
  insert into public.programme_lesson_opens (user_id, programme_id, lesson_id)
  values (auth.uid(), p_programme_id, p_lesson_id)
  on conflict do nothing;
  return true;
end;
$$;

revoke all on function public.record_lesson_open(text, text) from public, anon, authenticated;
grant execute on function public.record_lesson_open(text, text) to authenticated;

-- ---- Refunds (L.12) ----------------------------------------------------
-- The rule, in one place: my_purchases shows it, request_refund obeys it.
create or replace function public._refund_check(p_purchase public.course_purchases)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  p       public.programmes;
  v_start timestamptz;
  v_until timestamptz;
  v_opens int;
begin
  if p_purchase.status <> 'active' then
    return jsonb_build_object('eligible', false, 'reason', p_purchase.status);
  end if;
  if p_purchase.provider = 'free' then
    return jsonb_build_object('eligible', false, 'reason', 'nothing_paid');
  end if;
  if p_purchase.programme_id is null then
    return jsonb_build_object('eligible', false, 'reason', 'support_only');
  end if;
  select * into p from public.programmes where id = p_purchase.programme_id;

  if p.refund_policy in ('before_start', 'before_first_session') then
    select min(s.starts_utc) into v_start from public.programme_sessions s
     where s.programme_id = p.id
       and (p_purchase.run_id is null or s.run_id is null or s.run_id = p_purchase.run_id);
    -- No timetable yet means nothing has been delivered: refundable.
    if v_start is null then
      return jsonb_build_object('eligible', true, 'until', null, 'reason', 'not_scheduled');
    end if;
    v_until := v_start - case when p.refund_policy = 'before_start'
                              then make_interval(hours => p.refund_window_hours)
                              else interval '0' end;
    return jsonb_build_object('eligible', now() < v_until, 'until', v_until,
      'reason', case when now() < v_until then 'in_window' else 'window_closed' end);
  end if;

  if p.refund_policy = 'course_unopened' then
    v_until := p_purchase.paid_at + make_interval(days => p.refund_days);
    select count(*) into v_opens from public.programme_lesson_opens o
     where o.user_id = p_purchase.user_id and o.programme_id = p.id;
    return jsonb_build_object(
      'eligible', now() < v_until and v_opens <= p.refund_max_lessons,
      'until', v_until,
      'reason', case when now() >= v_until then 'window_closed'
                     when v_opens > p.refund_max_lessons then 'lessons_opened'
                     else 'in_window' end);
  end if;

  return jsonb_build_object('eligible', false, 'reason', 'support_only');
end;
$$;

revoke all on function public._refund_check(public.course_purchases) from public, anon, authenticated;

-- A refund revokes everything the purchase gave (L.12): the seat (her
-- upcoming bookings are cancelled, which frees them and reverses the
-- expert's accrual through the 0084 trigger), the recording and the
-- thread (has_course_access reads status = 'active'), and any unspent
-- credits the purchase granted.
create or replace function public._revoke_purchase(p_purchase_id text, p_status text)
returns void
language plpgsql
security definer set search_path = ''
as $$
declare
  cp public.course_purchases;
  b  record;
begin
  select * into cp from public.course_purchases where id = p_purchase_id for update;
  if cp.id is null then return; end if;

  update public.course_purchases
     set status = p_status,
         refund_requested_at = coalesce(refund_requested_at, now()),
         refunded_at = case when p_status = 'refunded' then now() else refunded_at end
   where id = cp.id;

  if cp.status <> 'active' then return; end if;   -- already revoked once

  for b in
    select bb.id, bb.slot_id from public.booking_bookings bb
     where bb.user_id = cp.user_id and bb.offering_id = cp.offering_id
       and bb.status = 'upcoming'
     for update
  loop
    update public.booking_bookings set status = 'cancelled' where id = b.id;
    update public.booking_slots set booked = greatest(booked - 1, 0) where id = b.slot_id;
  end loop;

  update public.consult_credits
     set voided_at = now(), void_reason = 'refunded'
   where user_id = cp.user_id and source_ref = cp.id
     and booking_id is null and voided_at is null;
end;
$$;

revoke all on function public._revoke_purchase(text, text) from public, anon, authenticated;

-- The parent asks. The rule answers. Eligible -> access is revoked now
-- and the money is returned by support from the Razorpay dashboard; the
-- webhook then marks it refunded. A stub purchase is "refunded" on the
-- spot, so the whole flow can be walked without money.
--
-- Trade-off, stated: revoking at REQUEST time means a parent briefly
-- has neither the course nor the money. Revoking at PROCESSED time
-- means she keeps watching while the refund is in flight -- the
-- "watch, then refund" hole 0054's refund_void_on_recording was worried
-- about. The industry (Udemy) revokes at request; so do we.
create or replace function public.request_refund(p_purchase_id text)
returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  cp      public.course_purchases;
  v_check jsonb;
begin
  select * into cp from public.course_purchases
   where id = p_purchase_id and user_id = auth.uid();
  if cp.id is null then
    return jsonb_build_object('ok', false, 'reason', 'no_such_purchase');
  end if;

  v_check := public._refund_check(cp);
  if not (v_check->>'eligible')::boolean then
    return jsonb_build_object('ok', false, 'reason', v_check->>'reason',
                              'until', v_check->'until');
  end if;

  perform public._revoke_purchase(cp.id,
    case when cp.provider = 'stub' then 'refunded' else 'refund_requested' end);

  return jsonb_build_object('ok', true,
    'status', case when cp.provider = 'stub' then 'refunded' else 'refund_requested' end);
end;
$$;

revoke all on function public.request_refund(text) from public, anon, authenticated;
grant execute on function public.request_refund(text) to authenticated;

-- The webhook's half: Razorpay says the money went back. Covers a
-- refund she asked for AND one support issued from the dashboard
-- (consults and packs, user 2026-10-29) -- either way access goes.
create or replace function public.record_refund(
  p_razorpay_payment_id text,
  p_refund_id           text,
  p_refund_paise        int
) returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  cp public.course_purchases;
begin
  update public.payment_orders
     set status = 'refunded', refunded_at = coalesce(refunded_at, now())
   where razorpay_payment_id = p_razorpay_payment_id;

  -- A refunded shop order is cancelled (written as the service role, so
  -- the 0126 orders guard does not apply).
  update public.orders set status = 'cancelled'
   where payment_id = p_razorpay_payment_id and status = 'paid';

  select * into cp from public.course_purchases
   where razorpay_payment_id = p_razorpay_payment_id;
  if cp.id is null then
    return jsonb_build_object('ok', true, 'purchase', null);
  end if;

  perform public._revoke_purchase(cp.id, 'refunded');
  update public.course_purchases
     set refund_id = p_refund_id, refund_paise = p_refund_paise
   where id = cp.id;

  return jsonb_build_object('ok', true, 'purchase_id', cp.id);
end;
$$;

revoke all on function public.record_refund(text, text, int) from public, anon, authenticated;
grant execute on function public.record_refund(text, text, int) to service_role;

-- Your bookings' Payments section (L.22, the server half of LA-27).
-- Every payment and refund she has made, in every stage, newest first,
-- with what the refund rule says about it today.
create or replace function public.my_purchases()
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
           'id',                  cp.id,
           'offering_id',         cp.offering_id,
           'programme_id',        cp.programme_id,
           'run_id',              cp.run_id,
           'kind',                cp.kind,
           'title',               cp.title,
           'stage',               cp.stage,
           'amount_paise',        cp.amount_paise,
           'currency',            cp.currency,
           'status',              cp.status,
           'provider',            cp.provider,
           'mode',                cp.mode,
           'payment_id',          cp.razorpay_payment_id,
           'paid_at',             cp.paid_at,
           'refund_requested_at', cp.refund_requested_at,
           'refunded_at',         cp.refunded_at,
           'refund_paise',        cp.refund_paise,
           'refund',              public._refund_check(cp))
         order by cp.paid_at desc), '[]'::jsonb)
    from public.course_purchases cp
   where cp.user_id = auth.uid();
$$;

revoke all on function public.my_purchases() from public, anon, authenticated;
grant execute on function public.my_purchases() to authenticated;


-- ---------------------------------------------------------------------
-- 9. LA-6 -- book_slot() reads only server values.
--
-- THE BUG. Every version since 0029 took the slot's expert, start,
-- duration and capacity from the caller and CREATED the slot on first
-- booking; 0084 added the caller's price, which then flowed into the
-- expert's earnings. And no version asked whether she had paid. So a
-- caller could book a 1,000-seat slot "starting now" with any expert,
-- at any price, for free.
--
-- THE FIX.
--   * The price is price_offering()'s seat value. p_price_paise is
--     read only in stub mode, for an offering the server does not know.
--   * An existing slot's expert, start, duration and capacity are the
--     stored row's, and the slot must belong to the offering named.
--   * A missing slot is created ONLY for a real-expert consult (expert,
--     duration and one seat from expert_profiles; the start is hers to
--     pick and must be in the future -- see LA-29), or in stub mode for
--     today's app. In live mode anything else is 'unknown slot': a
--     class is booked on the ps_<id> slots the timetable writes (§10).
--   * Paid means: a credit was claimed, or she holds a receipt for this
--     run, or the seat is free. In live mode anything else raises
--     'payment required', and the raise discards the whole transaction
--     -- the seat increment, the booking and the expert's accrual --
--     which is exactly the all-or-nothing a payment check wants.
--
-- KEPT FROM 0123, VERBATIM: the 11-argument signature (so `create or
-- replace` replaces, BACKEND-PATTERNS 12f) and 0066's credit claim
-- (LA-2; test/learning_security_contract_test.dart reads this, the
-- LAST definition). The claim gains one condition: a stub-purchase
-- credit is not spendable once the mode is live.
--
-- The other five slot arguments are still DECLARED, because today's
-- app sends them by name (supabase_repo.dart bookSlot). They are read
-- only in the stub branch. Expand/contract: L2c stops sending them.
-- ---------------------------------------------------------------------
create or replace function public.book_slot(
  p_booking_id   text,
  p_slot_id      text,
  p_offering_id  text,
  p_expert_id    text,
  p_starts_utc   timestamptz,
  p_duration_min int,
  p_capacity     int,
  p_stage        text,
  p_title        text,
  p_join_url     text default null,
  p_price_paise  int  default null
) returns public.booking_bookings
language plpgsql
security definer set search_path = ''
as $$
declare
  v_slot       public.booking_slots;
  v_booking    public.booking_bookings;
  v_uid        uuid := auth.uid();
  v_credit     uuid;
  v_mode       text := public.payment_mode();
  v_price      jsonb := public.price_offering(p_offering_id);
  v_known      boolean;
  v_seat_paise int;
  v_paid_by    text;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;
  v_known := coalesce((v_price->>'known')::boolean, false);

  select * into v_slot from public.booking_slots
    where id = p_slot_id for update;

  if v_slot.id is null then
    if v_known and v_price->>'kind' = 'consult' then
      if p_starts_utc is null or p_starts_utc <= now() then
        raise exception 'slot in the past';
      end if;
      insert into public.booking_slots
        (id, offering_id, expert_id, starts_utc, duration_min, capacity, join_url)
      values
        (p_slot_id, p_offering_id, v_price->>'expert_id', p_starts_utc,
         coalesce((v_price->>'duration_min')::int, 30), 1, null)
      on conflict (id) do nothing;
    elsif v_mode = 'stub' then
      -- LEGACY, STUB ONLY: today's app books slots it generated itself.
      insert into public.booking_slots
        (id, offering_id, expert_id, starts_utc, duration_min, capacity, join_url)
      values
        (p_slot_id, p_offering_id, p_expert_id, p_starts_utc,
         p_duration_min, p_capacity, p_join_url)
      on conflict (id) do nothing;
    else
      raise exception 'unknown slot';
    end if;

    select * into v_slot from public.booking_slots
      where id = p_slot_id for update;
  end if;

  if v_slot.offering_id <> p_offering_id then
    raise exception 'slot does not belong to this offering';
  end if;

  if v_slot.booked >= v_slot.capacity then
    raise exception 'slot full';
  end if;

  if exists (
    select 1 from public.booking_bookings
    where slot_id = p_slot_id and user_id = v_uid and status <> 'cancelled'
  ) then
    raise exception 'already booked';
  end if;

  -- What this seat is worth: the server's figure. The phone's only in
  -- stub mode, for an offering the server does not know.
  v_seat_paise := case
    when v_known then (v_price->>'seat_paise')::int
    when v_mode = 'stub' then p_price_paise
    else null end;

  update public.booking_slots set booked = booked + 1 where id = p_slot_id;

  insert into public.booking_bookings
    (id, user_id, offering_id, slot_id, stage, title, starts_utc,
     duration_min, status, paid_by, price_paise)
  values
    (p_booking_id, v_uid, p_offering_id, p_slot_id, p_stage,
     coalesce(v_price->>'title', p_title),
     v_slot.starts_utc, v_slot.duration_min, 'upcoming', 'unpaid', v_seat_paise)
  returning * into v_booking;

  -- CLAIM A CREDIT (0066, restored in 0123). Oldest-expiring first so
  -- nothing is wasted. FOR UPDATE SKIP LOCKED because two simultaneous
  -- bookings by the same person must not queue behind each other for the
  -- same row: the second takes the next credit instead of waiting.
  --
  -- capacity = 1 is how the server knows this is a consultation; 0066
  -- explains why the seat count, not a client-sent `kind`, is the
  -- signal. (0126) A stub-purchase credit is not spendable in live mode.
  select c.id into v_credit
    from public.consult_credits c
   where c.user_id = v_uid
     and c.booking_id is null
     and c.voided_at is null
     and (c.expires_at is null or c.expires_at > now())
     and ((c.offering_scope = '*any_consult' and v_slot.capacity = 1)
          or c.offering_scope = p_offering_id)
     and (v_mode = 'stub' or c.source <> 'stub_purchase')
   order by c.expires_at nulls last, c.granted_at
   limit 1
   for update skip locked;

  if v_credit is not null then
    update public.consult_credits
       set booking_id = v_booking.id, spent_at = now()
     where id = v_credit;
    update public.booking_bookings set paid_by = 'credit'
     where id = v_booking.id
    returning * into v_booking;
    return v_booking;
  end if;

  -- (0126) No credit: a receipt for this run, or a free seat, or nothing.
  v_paid_by := case
    when v_known and v_price->>'kind' in ('masterclass', 'cohort')
         and public.has_course_access(v_price->>'programme_id', 'seat',
                                      public._slot_run(v_slot.id))
      then 'purchase'
    when v_known and v_seat_paise = 0 then 'free'
    else 'unpaid' end;

  if v_paid_by = 'unpaid' and v_mode = 'live' then
    raise exception 'payment required';
  end if;

  if v_paid_by <> 'unpaid' then
    update public.booking_bookings set paid_by = v_paid_by
     where id = v_booking.id
    returning * into v_booking;
  end if;

  return v_booking;
end;
$$;

grant execute on function public.book_slot(
  text, text, text, text, timestamptz, int, int, text, text, text, int)
  to authenticated;

comment on column public.booking_bookings.paid_by is
  'credit | purchase | free | unpaid. unpaid is possible only in stub mode since 0126; in live mode book_slot raises "payment required".';


-- ---------------------------------------------------------------------
-- 10. LA-10 -- the timetable becomes the slots, and stays them.
--
-- TWO BUGS in the half that already existed.
--   * publish_programme wrote ps_<id> slots with offering_id = the
--     PROGRAMME id ('mc_sleep_101'), while every booking the app makes
--     carries the OFFERING id ('off_mc_sleep_101'). book_slot now
--     refuses a slot that does not belong to the offering named, so
--     those slots would have been unbookable.
--   * publish_programme mirrors sessions once, at publish, and returns
--     early for an already-published programme. A session added
--     afterwards -- a cohort's week 2, a masterclass rescheduled --
--     never became a slot. "Plug and play" needs a session row to be
--     enough, whenever it is written.
--
-- THE FIX. One function writes a session's slot, called by publish
-- and by a trigger on programme_sessions. A changed time moves the
-- slot AND the upcoming bookings' copies of it (booking_bookings keeps
-- its own starts_utc for history). Telling the people booked is LA-22,
-- L4. A capacity edit never drops below the seats already sold.
-- ---------------------------------------------------------------------
create or replace function public._mirror_session(p_session_id text)
returns void
language plpgsql
security definer set search_path = ''
as $$
declare
  s        public.programme_sessions;
  p        public.programmes;
  v_expert text;
begin
  select * into s from public.programme_sessions where id = p_session_id;
  if s.id is null then return; end if;
  select * into p from public.programmes where id = s.programme_id;
  if p.status <> 'published' then return; end if;
  v_expert := public._programme_lead_host(p.id);
  if v_expert is null then return; end if;   -- nobody to teach it: no seats

  insert into public.booking_slots as bs
    (id, offering_id, expert_id, starts_utc, duration_min, capacity, join_url)
  values
    ('ps_' || s.id, p.offering_id, v_expert, s.starts_utc, s.duration_min,
     coalesce(s.capacity, p.capacity, 100), s.join_url)
  on conflict (id) do update
    set offering_id  = excluded.offering_id,
        starts_utc   = excluded.starts_utc,
        duration_min = excluded.duration_min,
        capacity     = greatest(excluded.capacity, bs.booked);

  update public.booking_bookings
     set starts_utc = s.starts_utc, duration_min = s.duration_min
   where slot_id = 'ps_' || s.id and status = 'upcoming'
     and (starts_utc <> s.starts_utc or duration_min <> s.duration_min);
end;
$$;

revoke all on function public._mirror_session(text) from public, anon, authenticated;

create or replace function public.programme_session_mirror_trg()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  perform public._mirror_session(new.id);
  return new;
end;
$$;

drop trigger if exists programme_sessions_mirror on public.programme_sessions;
create trigger programme_sessions_mirror
  after insert or update of starts_utc, duration_min, capacity, join_url
  on public.programme_sessions
  for each row execute function public.programme_session_mirror_trg();

-- publish_programme: the LAST definition is 0055's (returns jsonb and
-- RETURNS its refusals, so their audit rows survive -- a raise would
-- roll them back). Copied verbatim from 0055; the only change is the
-- slot write, replaced by the shared mirror (0126). Copying 0054's
-- older text here would have changed the return type, which `create or
-- replace` refuses, and silently undone 0055's fix -- LA-2's mistake.
create or replace function public.publish_programme(
  p_programme_id text,
  p_actor        text
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_status   text;
  v_sessions int;
  v_past     int;
  v_accepted int;
  v_s        record;
begin
  select status into v_status from public.programmes where id = p_programme_id;

  if v_status is null then
    return public._refuse(p_actor, 'publish_programme', 'programmes',
      p_programme_id, 'no_such_programme',
      format('No programme %s.', p_programme_id));
  end if;

  if v_status = 'published' then
    return public._allow(p_actor, 'publish_programme', 'programmes',
      p_programme_id, 'already_published', 'Already published.');
  end if;

  select count(*), count(*) filter (where starts_utc <= now())
    into v_sessions, v_past
    from public.programme_sessions where programme_id = p_programme_id;

  select count(*) into v_accepted from public.programme_experts
   where programme_id = p_programme_id and status = 'accepted';

  if v_sessions = 0 then
    return public._refuse(p_actor, 'publish_programme', 'programmes',
      p_programme_id, 'no_sessions', 'It has no sessions.');
  end if;

  if v_past > 0 then
    return public._refuse(p_actor, 'publish_programme', 'programmes',
      p_programme_id, 'session_in_past',
      format('%s session(s) start in the past.', v_past));
  end if;

  if v_accepted = 0 then
    return public._refuse(p_actor, 'publish_programme', 'programmes',
      p_programme_id, 'no_accepted_expert',
      'No expert has accepted. Selling seats to a session nobody agreed to '
      'run is the failure this check exists for.');
  end if;

  if v_status not in ('marketing_review', 'scheduled') then
    return public._refuse(p_actor, 'publish_programme', 'programmes',
      p_programme_id, 'not_reviewed',
      format('Status is "%s"; it must pass medical_review and '
             'marketing_review first.', v_status),
      jsonb_build_object('status', v_status));
  end if;

  update public.programmes
     set status = 'published', published_at = now(), updated_at = now()
   where id = p_programme_id;

  -- (0126) The shared mirror: the offering id, the lead host, and the
  -- same code path a later session edit takes.
  for v_s in select id from public.programme_sessions
              where programme_id = p_programme_id loop
    perform public._mirror_session(v_s.id);
  end loop;

  return public._allow(p_actor, 'publish_programme', 'programmes',
    p_programme_id, 'published', format('Published with %s session(s).', v_sessions),
    jsonb_build_object('sessions', v_sessions));
end;
$$;

revoke all on function public.publish_programme(text, text) from public, anon, authenticated;

-- Repair slots 0054 already wrote under the programme id.
update public.booking_slots b
   set offering_id = p.offering_id
  from public.programmes p
 where b.id like 'ps\_%' and b.offering_id = p.id and p.offering_id <> p.id;


-- ---------------------------------------------------------------------
-- 11. LA-13 -- a shop order's paid status is the server's.
--
-- THE BUG. 0083 let the owner insert or update her order with
-- status = 'paid' and any payment_id: RLS checked whose row it was,
-- never whether the payment existed -- the 16zzi lesson again. And
-- nothing stopped two orders claiming one payment.
--
-- THE FIX, and why it is a trigger and not a revoked grant. The order
-- id is minted on the phone AFTER payment (pv_order_store.place), so
-- the server never knows the order at verify time and cannot write it
-- first. What it can do is refuse to believe the phone: a client write
-- of 'paid' must name a payment the server verified, for this user, for
-- the shop. Otherwise the row is kept but demoted to 'placed', with the
-- unproven payment id dropped.
--
-- Trade-off, stated: demoting instead of raising costs a loud failure;
-- it buys an order row that survives. The app's write is fire-and-
-- forget, so a raise would lose the order entirely -- an address and
-- a basket nobody can then look at. A demoted row is an honest record
-- of a real order whose payment is unproven.
--
-- current_user is the invoking role here (the function is NOT security
-- definer, deliberately): 'authenticated' for the app, 'service_role'
-- for the refund path, which the guard lets through.
-- ---------------------------------------------------------------------
do $$
begin
  if exists (select payment_id from public.orders where payment_id is not null
              group by payment_id having count(*) > 1) then
    raise exception 'orders has duplicate payment_id values; resolve them before 0126 (select payment_id, array_agg(id) from public.orders where payment_id is not null group by 1 having count(*) > 1)';
  end if;
end $$;

create unique index if not exists orders_payment_id_key
  on public.orders (payment_id) where payment_id is not null;

create or replace function public.orders_guard_paid()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user not in ('authenticated', 'anon') then
    return new;
  end if;

  -- A paid order is the server's from then on: its status, payment and
  -- money cannot be changed from the phone.
  if tg_op = 'UPDATE' and old.status = 'paid' then
    new.status       := old.status;
    new.payment_id   := old.payment_id;
    new.subtotal_inr := old.subtotal_inr;
    new.delivery_inr := old.delivery_inr;
    new.total_inr    := old.total_inr;
    new.items        := old.items;
    return new;
  end if;

  if new.payment_id is not null and not exists (
    select 1 from public.payment_orders po
     where po.razorpay_payment_id = new.payment_id
       and po.user_id = new.user_id
       and po.purpose = 'shop'
       and po.status = 'paid'
  ) then
    new.payment_id := null;
  end if;

  if new.status = 'paid' and new.payment_id is null then
    new.status := 'placed';
  end if;

  return new;
end;
$$;

drop trigger if exists orders_guard_paid on public.orders;
create trigger orders_guard_paid
  before insert or update on public.orders
  for each row execute function public.orders_guard_paid();


-- ---------------------------------------------------------------------
-- 12. LA-28 -- internal functions were callable by every user.
--
-- THE BUG. Thirty-one functions meant only for the server -- among
-- them grant_consult_credits, grant_plan, write_expert_earning,
-- void_consult_credits, publish_programme, approve_care_partner,
-- mint_partner_token and the phone_otp_* set -- were locked with
-- `revoke execute ... from public` and nothing else.
--
-- On plain Postgres that is enough. On Supabase it is not: the project
-- ships with
--     alter default privileges in schema public
--       grant all on functions to anon, authenticated, service_role;
-- so every function created by a migration is granted to `anon` and
-- `authenticated` BY NAME, not through PUBLIC. Revoking PUBLIC removes
-- a grant those roles were never relying on. Any signed-in account
-- could call `rpc('grant_consult_credits', {p_user_id: <me>, p_count:
-- 50, ...})` and give itself fifty consultations.
--
-- THE GENERAL FACT. A privilege can arrive by more than one path --
-- PUBLIC, a role, a default -- and a revoke removes exactly one path.
-- "Revoked" is only true when every path is closed, so revoke from
-- every role that can reach the API, and check the result with
-- has_function_privilege() rather than reading the migration.
--
-- THE FIX. Revoke from anon and authenticated for every overload of
-- each name. service_role keeps execute (the edge functions call the
-- OTP functions with it); directus_cms keeps the explicit grants 0084
-- gave it. Nothing in lib/ calls any of these (checked 2026-10-29).
-- test/learning_money_contract_test.dart now fails the build if a
-- function is revoked from public without anon and authenticated.
-- ---------------------------------------------------------------------
do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure as sig
      from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public'
       and p.proname = any (array[
         '_allow', '_audit', '_refuse', 'accrue_video_earning',
         'add_manual_expert_earning', 'approve_care_partner',
         'assign_programme_expert', 'create_care_partner',
         'create_partner_campaign', 'deactivate_care_partner',
         'grant_consult_credits', 'grant_plan', 'link_partner_account',
         'mint_partner_token', 'phone_otp_consume', 'phone_otp_issue',
         'phone_otp_prune', 'phone_otp_sent', 'prune_usage_events',
         'publish_programme', 'record_expert_payout', 'remove_demo_partners',
         'remove_sponsor_member', 'revoke_plan_by_source',
         'rotate_partner_token', 'rotate_partner_tokens', 'saved_items_prune',
         'sponsor_roster_revoke', 'sponsor_roster_stale',
         'void_consult_credits', 'write_expert_earning',
         -- and this file's internals
         'write_expert_earning_amount', '_write_purchase', '_revoke_purchase',
         '_refund_check', '_mirror_session', '_current_run', '_slot_run',
         '_programme_lead_host', 'programme_session_mirror_trg',
         'programmes_defaults', 'orders_guard_paid'])
  loop
    execute format('revoke execute on function %s from public, anon, authenticated', r.sig);
  end loop;
end $$;

-- The internals the view and the access rule need are executed by
-- their definer (postgres), so revoking them from users breaks nothing.


-- =====================================================================
-- VERIFY -- ONE read-only query (SQL editor). Every column should be
-- true. seeded_47 is false only if an editor had already made a
-- programme under one of the seeded ids, which is fine -- look first.
--
--   select
--     public.payment_mode() = 'stub'                                    as mode_is_stub,
--     (select count(*) = 47 from public.programmes
--       where display_source = 'app' and status = 'published')          as seeded_47,
--     not exists (select 1 from public.programmes_published v
--                   join public.programmes p using (id)
--                  where p.display_source = 'app')                       as seed_not_shown,
--     (public.price_offering('off_mc_sleepreg')->>'price_paise')::int
--       = 149900                                                         as server_prices,
--     (select bool_and(prosrc like '%for update skip locked%'
--                  and prosrc like '%payment required%')
--        from pg_proc where proname = 'book_slot')                       as book_slot_ok,
--     not has_function_privilege('authenticated',
--       'public.grant_consult_credits(uuid,int,text,text,text,text,int)',
--       'execute')                                                       as la28_closed,
--     not has_function_privilege('authenticated',
--       'public.open_payment_order(uuid,text,text,int,int)', 'execute')  as orders_server_only,
--     exists (select 1 from pg_indexes
--              where indexname = 'orders_payment_id_key')                as la13_unique,
--     exists (select 1 from information_schema.columns
--              where table_name = 'programmes_published'
--                and column_name = 'hosts')                              as la15_hosts;
--
-- OPTIONAL, NOT read-only (it rolls back): live mode refuses an unpaid
-- seat. Replace <uid> with a real auth user.
--   begin;
--   update public.payment_settings set mode = 'live';
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"<uid>","role":"authenticated"}', true);
--   select public.book_slot('bk_probe', 'off_mc_sleepreg_s0', 'off_mc_sleepreg',
--     'x', now() + interval '3 days', 60, 100, 'parenting', 'probe');
--     -> ERROR: unknown slot   (live mode makes no slot from phone values)
--   rollback;
-- =====================================================================
