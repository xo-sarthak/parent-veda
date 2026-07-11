-- =====================================================================
-- 0015_whatsapp.sql — WhatsApp notifications: opt-in/consent + send log + template registry
-- Adds messaging columns to profiles (phone, language, timezone, baby_dob,
-- opt-in + consent), a server-written send log, and a local template registry.
-- Follows the project conventions in BACKEND-PLAN.md.
-- Run AFTER the earlier migrations. Safe to run once (idempotent).
-- =====================================================================


-- 1) New columns on profiles ------------------------------------------
--    profiles' PK is `id` (= auth.users.id); its RLS (own + partner select,
--    own-only writes) already covers these new columns, so no new policies here.
alter table public.profiles
  add column if not exists phone               text,          -- E.164, e.g. +919876543210
  add column if not exists language            text,          -- 'en' | 'hi' (persist for template language)
  add column if not exists timezone            text        not null default 'Asia/Kolkata',
  add column if not exists baby_dob            date,          -- null until birth; drives post-birth triggers
  add column if not exists wa_opt_in           boolean     not null default false,  -- master WhatsApp consent
  add column if not exists wa_marketing_opt_in boolean     not null default false,  -- separate: marketing is legally distinct
  add column if not exists wa_consent_at       timestamptz,   -- WHEN they consented (DPDP audit)
  add column if not exists wa_consent_source   text;          -- e.g. 'signup_toggle' | 'profile_screen'


-- 2) wa_message_log  — one row per message we attempt to send ----------
--    Server-written ONLY (the daily engine uses the service_role key).
--    The app may READ its own rows (future "message history"), never write them.
create table if not exists public.wa_message_log (
  id                  uuid        primary key default gen_random_uuid(),
  user_id             uuid        not null references auth.users (id) on delete cascade,
  template_name       text        not null,
  category            text        not null default 'utility'
                        check (category in ('utility','marketing','authentication','service')),
  language            text,
  variables           jsonb       not null default '{}'::jsonb,   -- values slotted into the template
  status              text        not null default 'queued'
                        check (status in ('queued','sent','delivered','read','failed','mock')),
  provider            text,                                       -- 'mock' | 'msg91'
  provider_message_id text,                                       -- id returned by the provider
  error               text,                                       -- failure reason, if any
  dedupe_key          text,                                       -- e.g. 'weekly_guide:2026-W28' → one send per trigger/period
  cost_paise          int,                                        -- optional: store the charge
  created_at          timestamptz not null default now(),
  sent_at             timestamptz,
  updated_at          timestamptz not null default now()
);

-- Idempotency: at most one send per (user, dedupe_key). A re-run the same
-- period hits this and is skipped, so a cron double-fire never double-sends.
create unique index if not exists wa_message_log_dedupe
  on public.wa_message_log (user_id, dedupe_key)
  where dedupe_key is not null;

grant select on public.wa_message_log to authenticated;                       -- app: read own logs only
grant select, insert, update, delete on public.wa_message_log to service_role; -- engine: full access
alter table public.wa_message_log enable row level security;
create policy "wa_message_log own select" on public.wa_message_log
  for select using (auth.uid() = user_id);
--  (no insert/update/delete policy for authenticated: only the server writes here)


-- 3) wa_message_templates — local registry of our Meta templates ------
--    Global config (not per-user). The code reads this to know a template's
--    variables/shape; Meta holds the actual approved template. Not secret.
create table if not exists public.wa_message_templates (
  name         text        primary key,                          -- e.g. 'weekly_guide_en'
  category     text        not null default 'utility'
                 check (category in ('utility','marketing','authentication','service')),
  language     text        not null default 'en',
  variables    jsonb       not null default '[]'::jsonb,          -- ordered names: ["name","week","fruit"]
  body         text        not null default '',                  -- reference copy with {{1}} placeholders
  meta_status  text        not null default 'draft'
                 check (meta_status in ('draft','submitted','approved','rejected')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

grant select on public.wa_message_templates to authenticated;                       -- app: read-only
grant select, insert, update, delete on public.wa_message_templates to service_role; -- engine + dashboard
alter table public.wa_message_templates enable row level security;
create policy "wa_message_templates read all" on public.wa_message_templates
  for select using (true);   -- templates are not user-scoped or secret


-- 4) Seed the first template shapes (documentation + gives the mock sender
--    something real to fill). These are DRAFTs until submitted to Meta.
insert into public.wa_message_templates (name, category, language, variables, body, meta_status)
values
  ('weekly_guide_en', 'marketing', 'en', '["name","week","fruit"]'::jsonb,
   'Hi {{1}}, you are in week {{2}} of your pregnancy. Your baby is now about the size of a {{3}}.', 'draft'),
  ('weekly_guide_hi', 'marketing', 'hi', '["name","week","fruit"]'::jsonb,
   'Namaste {{1}}, aap pregnancy ke {{2}} week mein hain. Aapka baby ab lagbhag {{3}} jitna bada hai.', 'draft')
on conflict (name) do nothing;
