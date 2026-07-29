-- =====================================================================
-- 0062_public_domains_blocked.sql -- one row away from giving the
--                                    internet free Premium.
-- ---------------------------------------------------------------------
-- WHERE THIS CAME FROM. Plenty of Indian companies -- especially the
-- 30-to-200-person ones this is being sold to first -- do not issue
-- company email addresses at all. Their staff use Gmail. So the roster
-- (0061) is the primary eligibility path, and it handles that fine: it
-- matches an EXACT address, so priya.sharma@gmail.com on a sheet makes
-- exactly one person eligible.
--
-- The danger is the OTHER table. sponsor_domains matches a whole domain.
-- The day somebody helpfully adds 'gmail.com' to it for a customer whose
-- staff all use Gmail, every Gmail address on earth becomes eligible for
-- that sponsor. One row. No error, no alarm, and it would look like the
-- product working.
--
-- 0061 already makes it survivable in the common case -- once a sponsor
-- has a roster, their domains are ignored entirely -- but "survivable
-- because of an unrelated rule" is not a safeguard. A sponsor with no
-- roster and a public domain is still wide open, and that is precisely
-- the sponsor most likely to have one added.
--
-- WHY A TRIGGER THAT RAISES, WHEN 0055 SAID GATES MUST NOT RAISE
--
-- Because this is a CONSTRAINT, not a gate, and the distinction is the
-- point rather than an exception to it:
--
--   A GATE is asked "may I do this?" and must answer. Raising there
--   discards the audit row written a line earlier, so the refusal
--   leaves no trace -- the defect 0055 fixed.
--
--   A CONSTRAINT's whole job is to make the write NOT HAPPEN. There is
--   nothing to audit and nothing to return to; aborting the statement
--   IS the correct outcome, and Directus renders the message.
--
-- A CHECK constraint cannot do it, because a CHECK may not read another
-- table -- hence a trigger.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The list, as data.
--
-- A table rather than a hardcoded array because it will be wrong: the
-- next provider a customer's staff use is not on it yet, and finding
-- that out should cost a row rather than a release.
-- ---------------------------------------------------------------------
create table if not exists public.public_email_domains (
  domain     text primary key,
  note       text not null default '',
  created_at timestamptz not null default now(),
  constraint public_email_domains_lower check (domain = lower(domain))
);

comment on table public.public_email_domains is
  'Consumer email providers. A sponsor domain matching one of these would make every account at that provider eligible, so sponsor_domains refuses them. Use the roster (sponsor_eligible_people) for a company whose staff have no company email.';

insert into public.public_email_domains (domain, note) values
  ('gmail.com',       'Google'),
  ('googlemail.com',  'Google, legacy'),
  ('yahoo.com',       'Yahoo'),
  ('yahoo.in',        'Yahoo India'),
  ('yahoo.co.in',     'Yahoo India'),
  ('ymail.com',       'Yahoo'),
  ('rocketmail.com',  'Yahoo, legacy'),
  ('outlook.com',     'Microsoft'),
  ('hotmail.com',     'Microsoft'),
  ('hotmail.co.in',   'Microsoft India'),
  ('live.com',        'Microsoft'),
  ('live.in',         'Microsoft India'),
  ('msn.com',         'Microsoft'),
  ('icloud.com',      'Apple'),
  ('me.com',          'Apple'),
  ('mac.com',         'Apple'),
  ('rediffmail.com',  'Rediff -- common in Indian SMEs'),
  ('rediff.com',      'Rediff'),
  ('protonmail.com',  'Proton'),
  ('proton.me',       'Proton'),
  ('zoho.com',        'Zoho consumer -- note Zoho ALSO hosts company domains, which are fine'),
  ('zohomail.com',    'Zoho consumer'),
  ('aol.com',         'AOL'),
  ('gmx.com',         'GMX'),
  ('mail.com',        'mail.com'),
  ('yandex.com',      'Yandex'),
  ('inbox.com',       'inbox.com'),
  ('sify.com',        'Sify -- Indian ISP mail'),
  ('vsnl.net',        'VSNL -- Indian ISP mail, legacy'),
  ('bsnl.in',         'BSNL -- Indian ISP mail'),
  ('airtelmail.com',  'Airtel -- Indian ISP mail')
on conflict (domain) do nothing;

alter table public.public_email_domains enable row level security;
revoke all on public.public_email_domains from anon, authenticated;

-- Ops may add to it -- the next consumer provider is not on this list
-- and finding out should not need me. Deliberately no DELETE: removing
-- 'gmail.com' from here is the exact move that reopens the hole, and it
-- should take a migration and a conversation.
grant select, insert, update on public.public_email_domains to directus_cms;
drop policy if exists "public_email_domains cms" on public.public_email_domains;
create policy "public_email_domains cms" on public.public_email_domains
  for all to directus_cms using (true) with check (true);


-- ---------------------------------------------------------------------
-- 2. The guard.
-- ---------------------------------------------------------------------
create or replace function public.sponsor_domains_reject_public()
returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  if exists (select 1 from public.public_email_domains p
              where p.domain = lower(new.domain)) then
    raise exception
      'Refused: % is a consumer email provider. Adding it would make every account there eligible for this sponsor. For a company whose staff have no company email, load their addresses into sponsor_eligible_people instead.',
      new.domain
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

drop trigger if exists sponsor_domains_reject_public_trg on public.sponsor_domains;
create trigger sponsor_domains_reject_public_trg
  before insert or update on public.sponsor_domains
  for each row execute function public.sponsor_domains_reject_public();


-- ---------------------------------------------------------------------
-- 3. Anything already in there.
--
-- Nothing should be, but a guard added after the fact that ignores
-- existing rows guards nothing -- the row it was written for is the one
-- already sitting in the table.
-- ---------------------------------------------------------------------
do $$
declare v_bad text;
begin
  select string_agg(d.domain, ', ') into v_bad
    from public.sponsor_domains d
    join public.public_email_domains p on p.domain = lower(d.domain);
  if v_bad is not null then
    raise warning
      'sponsor_domains ALREADY CONTAINS consumer providers: %. Every account at those providers is eligible right now. Remove them and use sponsor_eligible_people.',
      v_bad;
  end if;
end $$;


-- =====================================================================
-- VERIFY
--
--   insert into public.sponsors (id, name, plan_id, status)
--     values ('zz_g', 'Gmail Co', 'employer_standard', 'active');
--
--   insert into public.sponsor_domains values ('gmail.com', 'zz_g');
--     -> ERROR: Refused: gmail.com is a consumer email provider...
--
--   insert into public.sponsor_domains values ('acme-real.test', 'zz_g');
--     -> ok
--
--   delete from public.sponsors where id = 'zz_g';
-- =====================================================================
