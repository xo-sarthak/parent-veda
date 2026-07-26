-- =====================================================================
-- 0038_care_partner_config.sql -- the admin-editable half of the
-- Care Partner platform
-- ---------------------------------------------------------------------
-- 0037 built the machine. This holds the knobs a business person will
-- want to turn without an app release: where a partner appears, what the
-- credit line says, and what a referral is worth.
--
-- SAME PATTERN AS 0036 (referral_config), for the same reason:
--
--   public read, NO write policy, seeded to match the values already
--   compiled into the app.
--
-- Which means: nothing changes behaviour today, the app keeps working
-- offline and on old builds, and when Directus arrives it is a form over
-- rows that already exist rather than a new backend. Editing is SQL (or
-- service_role) until then.
--
-- CONFIG IS NOT A SECURITY BOUNDARY. Anything here that touches money is
-- re-derived server-side when a payment settles; these rows describe
-- intent, they do not authorise a payout.
--
-- PREREQ: 0037.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. VISIBILITY RULES -- where a partner may appear
--
-- Rows are matched most-specific-first: a rule naming a partner beats a
-- rule naming their type. That is what lets one hospital be configured
-- differently without forking the defaults for every hospital.
--
-- `topics` and `surfaces` are text arrays rather than enums so the admin
-- panel can introduce 'sleep_regression' -- or a surface a future build
-- adds -- without a migration. The app ignores names it does not know
-- (CareVisibilityRule.fromMap falls back to the Care Circle), so a newer
-- panel can never break an older build.
-- ---------------------------------------------------------------------
create table public.care_visibility_rules (
  id            bigserial   primary key,
  -- Exactly one of these is set. partner_id wins when both match.
  partner_id    text        references public.care_partners (id) on delete cascade,
  partner_type  text,
  topics        text[]      not null default '{}',
  surfaces      text[]      not null default '{care_circle}',
  priority      int         not null default 0,
  frequency     text        not null default 'daily'
                  check (frequency in ('once','daily','always')),
  dismissible   boolean     not null default true,
  expires_at    timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint care_visibility_scope
    check (num_nonnulls(partner_id, partner_type) = 1)
);

create unique index care_visibility_type_idx
  on public.care_visibility_rules (partner_type) where partner_type is not null;
create unique index care_visibility_partner_idx
  on public.care_visibility_rules (partner_id) where partner_id is not null;

grant select on public.care_visibility_rules to anon, authenticated;
alter table public.care_visibility_rules enable row level security;

-- Read is open, including signed-out: the welcome card after a QR scan is
-- rendered before there is an account. These rows describe placements, not
-- people -- there is nothing here about any family.
create policy "care_visibility_rules public read"
  on public.care_visibility_rules for select using (true);

-- No write policy. Placements are an editorial decision.


-- Seeded to match CareTopic.defaultsFor / CareVisibilityRule.defaultsFor
-- in lib/care_partner/care_visibility.dart. If you change one, change both
-- -- care_partner_config_test.dart fails when they drift.
--
-- NOTE 'home' is absent from every seed. The daily home is the most
-- valuable space in the app; a partner appears there only when someone
-- decides so, never by default.
insert into public.care_visibility_rules (partner_type, topics, surfaces) values
  ('lactation_consultant',
     '{breastfeeding,latching,milk_supply,pumping}',
     '{welcome,care_circle,topic,profile}'),
  ('doctor',
     '{vaccination,growth,nutrition,milestones}',
     '{welcome,care_circle,topic,profile}'),
  ('physiotherapist',
     '{exercises,recovery,pelvic_floor}',
     '{welcome,care_circle,topic,profile}'),
  ('nutritionist',
     '{nutrition,growth}',
     '{welcome,care_circle,topic,profile}'),
  ('psychologist',
     '{mental_health,sleep}',
     '{welcome,care_circle,topic,profile}'),
  ('ivf_centre',
     '{fertility,scans}',
     '{welcome,care_circle,topic,profile}'),
  ('diagnostic_lab',
     '{scans}',
     '{welcome,care_circle,topic,profile}'),
  -- Organisations with no topical specialism. Still reachable in the Care
  -- Circle, which is the rule that "a partner is never silently erased".
  ('hospital',   '{}', '{welcome,care_circle,profile}'),
  ('clinic',     '{}', '{welcome,care_circle,profile}'),
  ('corporate',  '{}', '{welcome,care_circle,profile}'),
  ('insurance',  '{}', '{welcome,care_circle,profile}')
on conflict do nothing;


-- ---------------------------------------------------------------------
-- 2. TRUST MESSAGING -- what the credit line says
--
-- Held apart from care_partners so that editing copy is not editing a
-- professional's identity record, and so a default exists per type.
--
-- THE BANNED WORDS ARE ENFORCED IN THREE PLACES and that is deliberate:
-- here (a check constraint), in TrustMessage.isAllowed (which fails
-- closed to "Invited by"), and in CarePartnerCard (which only ever renders
-- safePrimary). A doctor's name must never appear under an advertising
-- label, and no single edit anywhere should be able to make it happen.
-- ---------------------------------------------------------------------
create table public.care_trust_messages (
  id             bigserial   primary key,
  partner_id     text        references public.care_partners (id) on delete cascade,
  partner_type   text,
  primary_label  text        not null default 'Invited by',
  secondary_label text       not null default '',
  short_welcome  text        not null default '',
  long_welcome   text        not null default '',
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint care_trust_scope
    check (num_nonnulls(partner_id, partner_type) = 1),
  constraint care_trust_not_an_advert check (
    lower(primary_label)   !~ '(sponsor|advert|promot|ad by)' and
    lower(secondary_label) !~ '(sponsor|advert|promot|ad by)'
  )
);

create unique index care_trust_type_idx
  on public.care_trust_messages (partner_type) where partner_type is not null;
create unique index care_trust_partner_idx
  on public.care_trust_messages (partner_id) where partner_id is not null;

grant select on public.care_trust_messages to anon, authenticated;
alter table public.care_trust_messages enable row level security;

create policy "care_trust_messages public read"
  on public.care_trust_messages for select using (true);

insert into public.care_trust_messages (partner_type, primary_label) values
  ('doctor',               'Invited by'),
  ('hospital',             'Recommended by'),
  ('clinic',               'Recommended by'),
  ('lactation_consultant', 'Invited by'),
  ('physiotherapist',      'Invited by'),
  ('nutritionist',         'Invited by'),
  ('psychologist',         'Invited by'),
  ('ivf_centre',           'Recommended by'),
  ('diagnostic_lab',       'Recommended by'),
  ('corporate',            'Provided by'),
  ('insurance',            'Provided by')
on conflict do nothing;


-- ---------------------------------------------------------------------
-- 3. COMMISSION RULES -- what a referral is worth
--
-- Basis points, matching commission_ledger.rate_bps in 0037 (250 = 2.5%).
-- Integers, because a float rate applied to money produces amounts that do
-- not reconcile.
--
-- A NULL partner_id is the default for that source; a row naming a partner
-- overrides it. Nothing here pays anybody: the settling edge function
-- reads these to compute a ledger entry, and a rate that is missing means
-- zero rather than "guess".
-- ---------------------------------------------------------------------
create table public.care_commission_rules (
  id          bigserial   primary key,
  partner_id  text        references public.care_partners (id) on delete cascade,
  source      text        not null
                check (source in ('consultation','masterclass','cohort',
                                  'subscription','product','course',
                                  'referral','other')),
  rate_bps    int         not null default 0 check (rate_bps between 0 and 5000),
  -- A window after attribution during which the partner earns on a
  -- purchase. Null = for as long as the attribution stands.
  valid_days  int,
  active      boolean     not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create unique index care_commission_default_idx
  on public.care_commission_rules (source) where partner_id is null;
create unique index care_commission_partner_idx
  on public.care_commission_rules (partner_id, source)
  where partner_id is not null;

grant select on public.care_commission_rules to authenticated;
alter table public.care_commission_rules enable row level security;

-- Authenticated read only, unlike the two tables above: commercial terms
-- are not something a signed-out visitor needs, and a parent has no reason
-- to see them at all. A partner reading the default rates is fine and
-- honest; a partner reading ANOTHER partner's negotiated rate is not, so
-- partner-specific rows stay invisible to everyone but their owner.
create policy "care_commission_defaults read"
  on public.care_commission_rules for select to authenticated
  using (partner_id is null);

create policy "care_commission_own read"
  on public.care_commission_rules for select to authenticated
  using (partner_id is not null and exists (
    select 1
    from public.care_partners cp
    join public.expert_accounts ea on ea.expert_id = cp.expert_id
    where cp.id = care_commission_rules.partner_id
      and ea.user_id = auth.uid()
  ));

-- Zero everywhere, on purpose. Real rates are a commercial decision that
-- has not been made; seeding an invented 2.5% would put a number in front
-- of a doctor that nobody at ParentVeda has agreed to.
insert into public.care_commission_rules (source, rate_bps) values
  ('consultation', 0),
  ('masterclass',  0),
  ('cohort',       0),
  ('subscription', 0),
  ('product',      0),
  ('course',       0),
  ('referral',     0),
  ('other',        0)
on conflict do nothing;


-- ---------------------------------------------------------------------
-- 4. PLATFORM CONFIG -- the few global knobs
--
-- One row, keyed, so adding a knob is an insert. Mirrors 0036's shape.
-- ---------------------------------------------------------------------
create table public.care_partner_config (
  key         text        primary key,
  value       jsonb       not null,
  note        text        not null default '',
  updated_at  timestamptz not null default now()
);

grant select on public.care_partner_config to anon, authenticated;
alter table public.care_partner_config enable row level security;

create policy "care_partner_config public read"
  on public.care_partner_config for select using (true);

insert into public.care_partner_config (key, value, note) values
  ('attribution_window_days', '90'::jsonb,
   'How long after a scan a signup still credits the partner.'),
  ('attribution_model', '"first_touch"'::jsonb,
   'first_touch | last_touch. OPEN POINT: multi-partner ownership is '
   'undecided. Until it is, the first professional to introduce a family '
   'keeps the credit -- changing this later re-writes history, so it must '
   'be a deliberate decision, not a default nobody chose.'),
  ('welcome_moment_enabled', 'true'::jsonb,
   'The one-time "Dr Rao invited you" card after onboarding.'),
  ('token_rotation', '0'::jsonb,
   'Bump to invalidate every printed QR and issue new ones.')
on conflict (key) do nothing;
