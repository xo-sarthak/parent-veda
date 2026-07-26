-- =====================================================================
-- 0036_referral_config.sql -- referral campaign settings, editable live
-- ---------------------------------------------------------------------
-- ReferralConfig was a hardcoded Dart default, so changing a reward, a
-- cap or the campaign dates meant a release and an app-store review. For
-- a growth feature -- the whole point of which is to be tuned -- that is
-- the wrong shape.
--
-- This does NOT need Directus to be useful. Directus sits on top of
-- Supabase tables in this project, so the table is the real thing and
-- Directus later becomes a UI over rows that already exist. Until then a
-- single SQL update changes the offer.
--
-- ONE ACTIVE ROW at a time, enforced by a partial unique index: two live
-- campaigns would mean two different answers to "what do I get?", and the
-- app would silently pick whichever sorted first.
--
-- PUBLIC-READ, NOBODY-WRITES. Every parent needs to read the terms; no
-- app session may change them. Writes happen from the dashboard or
-- Directus under service_role, which bypasses RLS.
--
-- SECURITY NOTE: this table is CONFIG, not a security boundary. The caps
-- here are re-clamped inside qualify_referral (0035) precisely because a
-- client could ask for a generous cap. Read it as "what the business
-- wants", never as "what the server will allow".
--
-- PREREQ: none.
-- =====================================================================

create table public.referral_config (
  campaign_id   text        primary key,
  active        boolean     not null default false,
  starts_at     timestamptz,
  ends_at       timestamptz,
  config        jsonb       not null default '{}'::jsonb,
  updated_at    timestamptz not null default now()
);

comment on column public.referral_config.config is
  'ReferralConfig.toMap(): inviterReward, inviteeReward, rules, caps, enabled.';

-- Exactly one active campaign.
create unique index referral_config_one_active
  on public.referral_config ((active)) where active;

grant select on public.referral_config to anon, authenticated;
alter table public.referral_config enable row level security;

-- Readable by everyone, including signed-out users: the invite screen shows
-- the terms before a parent has an account.
create policy "referral_config read" on public.referral_config
  for select using (true);

-- No insert/update/delete policy, deliberately. With RLS enabled, a verb
-- with no policy is denied outright, so no app session can rewrite the
-- terms of its own reward.


-- ---------------------------------------------------------------------
-- The starting campaign. Matches the Dart defaults exactly, so turning
-- this table on changes nothing until someone edits it -- which is what
-- makes it safe to ship.
-- ---------------------------------------------------------------------
insert into public.referral_config (campaign_id, active, config)
values (
  'launch',
  true,
  jsonb_build_object(
    'campaignId', 'launch',
    'enabled', true,
    'inviterReward', jsonb_build_object(
      'kind', 'consultCredit', 'value', 1,
      'label', '1 free consultation',
      'description', 'Yours when a friend joins and finishes setting up.'
    ),
    'inviteeReward', jsonb_build_object(
      'kind', 'consultCredit', 'value', 1,
      'label', '1 free consultation',
      'description', 'A welcome gift for joining through a friend.'
    ),
    'rules', jsonb_build_object(
      'requireRegistration', true,
      'requireOtpVerified', true,
      'requireOnboardingComplete', true,
      'requirePregnancyConfirmed', true,
      'withinDays', 30
    ),
    'maxRewardsPerUser', 10,
    'maxInvitesPerDay', 20,
    'maxInvitesPerMonth', 100
  )
)
on conflict (campaign_id) do nothing;


-- ---------------------------------------------------------------------
-- Changing the offer, without a release:
--
--   update public.referral_config
--      set config = jsonb_set(config, '{inviterReward,value}', '2'),
--          updated_at = now()
--    where campaign_id = 'launch';
--
-- Stopping it entirely:
--
--   update public.referral_config set active = false where campaign_id = 'launch';
--
-- Note the app also honours config->>'enabled'; `active` decides WHICH row
-- is the campaign, `enabled` is the kill switch inside it.
-- ---------------------------------------------------------------------
