-- =====================================================================
-- 0058_sponsors_and_activation.sql -- who sponsors whom, and how an
--                                     employee proves they belong.
-- ---------------------------------------------------------------------
-- A sponsor buys a plan for its people. HR is the first kind; the
-- entitlement doc names insurers, hospitals, government programmes, NGOs,
-- universities and clinics as the next. So this models a SPONSOR, not an
-- employer, and `kind` is free text for the same reason
-- care_partners.type is: a new category must not need a release.
--
-- The employee never feels this. They activate, Premium appears, and the
-- only visible difference is an Employer Benefits section. The employer
-- owns the benefit; the employee owns the parenting journey.
--
-- WHAT ACTIVATION HAS TO PROVE
--
-- That the person controls an email address at a sponsoring domain. Not
-- that HR approved them -- the whole point is that HR does nothing. So:
--
--     work email -> one-time code to that address -> domain matches an
--     active sponsor -> a seat is free -> grant the plan
--
-- Skipping the code would mean anyone who types someone@google.com gets
-- Premium. It is the only thing standing between a domain list and free
-- access for the internet, so it is not optional and not deferred.
--
-- ⚠️ THE SENDER DOES NOT EXIST YET. This migration creates the code, the
-- expiry, the attempt limit and the verification. It does NOT send the
-- email -- there is no transactional email provider wired to this
-- project (WhatsApp via MSG91 is the only outbound channel that exists).
-- So request_sponsor_activation() writes a valid code that nothing
-- delivers. That is a stated gap, not an oversight: see STILL-OPEN 11.6.
-- The app half is inert until an edge function sends it.
--
-- PREREQ: 0050/0051 (_audit, _refuse, _allow), 0057 (entitlement engine).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The sponsor.
-- ---------------------------------------------------------------------
create table if not exists public.sponsors (
  id              text primary key,          -- 'acme'
  name            text not null,
  kind            text not null default 'employer',  -- employer|insurer|hospital|ngo|...
  plan_id         text not null references public.plans (id),
  seats_purchased int,                       -- null = unlimited
  status          text not null default 'pending'
                    check (status in ('pending', 'active', 'suspended', 'ended')),
  renewal_at      date,
  logo_url        text,
  support_contact text,                      -- shown to employees, not HR's inbox
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

comment on table public.sponsors is
  'An organisation sponsoring a plan for its people. kind is free text so insurers/hospitals/NGOs need no migration.';

-- Public read of ACTIVE sponsors only, and only the parts an employee is
-- shown: the name and logo on their "Premium, provided by Acme" line.
-- Seats, renewal date and status are commercial facts, so the app reads
-- them through a function, never off the row.
alter table public.sponsors enable row level security;

drop policy if exists "sponsors public read" on public.sponsors;
create policy "sponsors public read" on public.sponsors
  for select to anon, authenticated using (status = 'active');

grant select (id, name, kind, logo_url, support_contact)
  on public.sponsors to anon, authenticated;


-- ---------------------------------------------------------------------
-- 2. Approved domains -- the eligibility rule.
--
-- Stored lowercase without the '@'. A company may have several
-- (@acme.com, @acme.co.in), and a domain belongs to exactly one sponsor:
-- two sponsors claiming @acme.com is a billing dispute, and the database
-- should refuse it rather than pick one.
-- ---------------------------------------------------------------------
create table if not exists public.sponsor_domains (
  domain     text primary key,
  sponsor_id text not null references public.sponsors (id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint sponsor_domains_shape
    check (domain = lower(domain) and domain not like '@%' and domain like '%.%')
);

create index if not exists sponsor_domains_sponsor_idx
  on public.sponsor_domains (sponsor_id);

-- NOT public-read. The list of companies that bought ParentVeda is
-- commercially sensitive, and a public domain table is a customer list
-- anyone can download. Matching happens inside a function instead.
alter table public.sponsor_domains enable row level security;
revoke all on public.sponsor_domains from anon, authenticated;


-- ---------------------------------------------------------------------
-- 3. Membership -- the sensitive one.
--
-- A row here says "this user works at Acme". Joined to anything about
-- their pregnancy or their child, it de-anonymises them to their
-- employer. So it has no public read policy at all: the employee reads
-- their OWN row, the aggregation layer reads it as definer, and nothing
-- else can.
-- ---------------------------------------------------------------------
create table if not exists public.sponsor_members (
  user_id      uuid not null references auth.users (id) on delete cascade,
  sponsor_id   text not null references public.sponsors (id) on delete cascade,
  work_email   text not null,
  status       text not null default 'active'
                 check (status in ('active', 'removed')),
  activated_at timestamptz not null default now(),
  removed_at   timestamptz,
  primary key (user_id, sponsor_id)
);

create index if not exists sponsor_members_sponsor_idx
  on public.sponsor_members (sponsor_id, status);
-- One work email activates once, ever. Without this, forwarding an
-- invite around a WhatsApp group is a seat farm.
create unique index if not exists sponsor_members_email_idx
  on public.sponsor_members (lower(work_email));

alter table public.sponsor_members enable row level security;
grant select on public.sponsor_members to authenticated;

drop policy if exists "sponsor_members own read" on public.sponsor_members;
create policy "sponsor_members own read" on public.sponsor_members
  for select to authenticated using (auth.uid() = user_id);

-- No client write policy. Membership is granted by the activation
-- function, never by a client insert.


-- ---------------------------------------------------------------------
-- 4. One-time codes.
--
-- Stored in plain text, deliberately, and that is defensible here: the
-- table has NO grants to anon or authenticated and no read policy, so
-- only service_role sees it. Hashing would protect against a database
-- dump, which is a scenario where a six-digit code that expires in ten
-- minutes is the least of the problems. The real protections are the
-- short expiry, the attempt limit and single use -- and those are
-- enforced below rather than assumed.
-- ---------------------------------------------------------------------
create table if not exists public.sponsor_activation_codes (
  id         uuid primary key default gen_random_uuid(),
  work_email text not null,
  code       text not null,
  sponsor_id text not null references public.sponsors (id) on delete cascade,
  attempts   int not null default 0,
  expires_at timestamptz not null,
  consumed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists sponsor_activation_codes_email_idx
  on public.sponsor_activation_codes (lower(work_email), expires_at desc);

alter table public.sponsor_activation_codes enable row level security;
revoke all on public.sponsor_activation_codes from anon, authenticated;


-- ---------------------------------------------------------------------
-- 5. request_sponsor_activation -- step one.
--
-- Returns {ok, code, message}, never raises: a raise would abort the
-- transaction and discard the audit row written a line earlier, which is
-- the defect 0055 fixed.
--
-- NOTE what it does NOT reveal. Whether a domain belongs to a sponsor is
-- a customer list, so an unknown domain and a suspended sponsor return
-- the SAME generic answer. Otherwise this endpoint becomes a way to
-- enumerate which companies bought ParentVeda.
-- ---------------------------------------------------------------------
create or replace function public.request_sponsor_activation(p_work_email text)
returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_email   text := lower(trim(p_work_email));
  v_domain  text;
  v_sponsor record;
  v_used    int;
  v_recent  int;
  v_code    text;
  v_actor   text := coalesce(auth.uid()::text, 'anonymous');
begin
  if v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    return public._refuse(v_actor, 'request_sponsor_activation',
      'sponsor_activation_codes', null, 'invalid_email',
      'That does not look like an email address.');
  end if;

  v_domain := split_part(v_email, '@', 2);

  select s.* into v_sponsor
    from public.sponsor_domains d
    join public.sponsors s on s.id = d.sponsor_id
   where d.domain = v_domain;

  -- One vague answer for every eligibility failure. "Not recognised" for
  -- an unknown domain AND for a suspended customer, so this cannot be
  -- used to discover who our customers are.
  if v_sponsor.id is null or v_sponsor.status <> 'active' then
    return public._refuse(v_actor, 'request_sponsor_activation',
      'sponsor_activation_codes', null, 'not_eligible',
      'We could not find a benefit for that email address.',
      jsonb_build_object('domain', v_domain));
  end if;

  if exists (select 1 from public.sponsor_members
              where lower(work_email) = v_email and status = 'active') then
    return public._refuse(v_actor, 'request_sponsor_activation',
      'sponsor_activation_codes', v_sponsor.id, 'already_activated',
      'This work email has already been used to activate the benefit.');
  end if;

  if v_sponsor.seats_purchased is not null then
    select count(*) into v_used from public.sponsor_members
     where sponsor_id = v_sponsor.id and status = 'active';
    if v_used >= v_sponsor.seats_purchased then
      return public._refuse(v_actor, 'request_sponsor_activation',
        'sponsor_activation_codes', v_sponsor.id, 'no_seats_left',
        'All the seats your organisation purchased are in use.',
        jsonb_build_object('used', v_used, 'purchased', v_sponsor.seats_purchased));
    end if;
  end if;

  -- Rate limit: three codes per address per hour. Without it this is a
  -- free way to send mail to anyone at a customer's domain.
  select count(*) into v_recent from public.sponsor_activation_codes
   where lower(work_email) = v_email and created_at > now() - interval '1 hour';
  if v_recent >= 3 then
    return public._refuse(v_actor, 'request_sponsor_activation',
      'sponsor_activation_codes', v_sponsor.id, 'too_many_requests',
      'Too many codes requested. Try again in an hour.');
  end if;

  v_code := lpad((floor(random() * 1000000))::int::text, 6, '0');

  insert into public.sponsor_activation_codes
    (work_email, code, sponsor_id, expires_at)
  values (v_email, v_code, v_sponsor.id, now() + interval '10 minutes');

  -- The code is NOT returned. It goes to the address, which is the only
  -- thing that proves the person controls it. Returning it here would
  -- make the whole verification theatre.
  return public._allow(v_actor, 'request_sponsor_activation',
    'sponsor_activation_codes', v_sponsor.id, 'code_sent',
    format('We have sent a code to %s.', v_email),
    jsonb_build_object('sponsor', v_sponsor.id));
end;
$$;

grant execute on function public.request_sponsor_activation(text) to authenticated;


-- ---------------------------------------------------------------------
-- 6. confirm_sponsor_activation -- step two, and the grant.
-- ---------------------------------------------------------------------
create or replace function public.confirm_sponsor_activation(
  p_work_email text,
  p_code       text
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_email text := lower(trim(p_work_email));
  v_row   record;
  v_uid   uuid := auth.uid();
  v_plan  text;
  v_used  int;
  v_spons record;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'code', 'not_signed_in',
      'message', 'Sign in first, then activate your employer benefit.');
  end if;

  select * into v_row from public.sponsor_activation_codes
   where lower(work_email) = v_email and consumed_at is null
   order by created_at desc limit 1;

  if v_row.id is null then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', null, 'no_pending_code',
      'Request a new code.');
  end if;

  if v_row.expires_at < now() then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_row.sponsor_id, 'code_expired',
      'That code has expired. Request a new one.');
  end if;

  -- Count the attempt BEFORE comparing, so a wrong guess costs one
  -- regardless of what happens next. Five guesses at six digits is a
  -- 1-in-200,000 chance, which is the point of counting at all.
  update public.sponsor_activation_codes
     set attempts = attempts + 1 where id = v_row.id;

  if v_row.attempts + 1 > 5 then
    update public.sponsor_activation_codes
       set consumed_at = now() where id = v_row.id;
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_row.sponsor_id, 'too_many_attempts',
      'Too many incorrect codes. Request a new one.');
  end if;

  if v_row.code <> trim(p_code) then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_row.sponsor_id, 'wrong_code',
      'That code is not right.');
  end if;

  select * into v_spons from public.sponsors where id = v_row.sponsor_id;

  -- Re-check eligibility at the moment of granting. Ten minutes is long
  -- enough for the last seat to go, or for a subscription to lapse, and
  -- the check that mattered was the one at the time of the grant.
  if v_spons.status <> 'active' then
    return public._refuse(v_uid::text, 'confirm_sponsor_activation',
      'sponsor_members', v_spons.id, 'sponsor_inactive',
      'This benefit is no longer active.');
  end if;

  if v_spons.seats_purchased is not null then
    select count(*) into v_used from public.sponsor_members
     where sponsor_id = v_spons.id and status = 'active';
    if v_used >= v_spons.seats_purchased then
      return public._refuse(v_uid::text, 'confirm_sponsor_activation',
        'sponsor_members', v_spons.id, 'no_seats_left',
        'All the seats your organisation purchased are in use.');
    end if;
  end if;

  update public.sponsor_activation_codes
     set consumed_at = now() where id = v_row.id;

  insert into public.sponsor_members (user_id, sponsor_id, work_email)
  values (v_uid, v_spons.id, v_email)
  on conflict (user_id, sponsor_id) do update
    set status = 'active', activated_at = now(), removed_at = null;

  -- The plan comes from the sponsor, and the grant records its source so
  -- that losing the job later removes exactly this and nothing else.
  perform public.grant_plan(v_uid, v_spons.plan_id, 'sponsor', v_spons.id,
                            null, v_uid::text);

  return public._allow(v_uid::text, 'confirm_sponsor_activation',
    'sponsor_members', v_spons.id, 'activated',
    format('Welcome. Your benefit is provided by %s.', v_spons.name),
    jsonb_build_object('sponsor', v_spons.id, 'plan', v_spons.plan_id));
end;
$$;

grant execute on function
  public.confirm_sponsor_activation(text, text) to authenticated;


-- ---------------------------------------------------------------------
-- 7. What the employee sees about their own benefit.
--
-- A function rather than a view, so it answers only about the caller and
-- returns just the parts an employee is shown -- never seat counts,
-- never renewal dates, never anything commercial.
-- ---------------------------------------------------------------------
create or replace function public.my_sponsor()
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select coalesce(
    (select jsonb_build_object(
       'sponsor_id', s.id, 'name', s.name, 'kind', s.kind,
       'logo_url', s.logo_url, 'support_contact', s.support_contact,
       'activated_at', m.activated_at)
       from public.sponsor_members m
       join public.sponsors s on s.id = m.sponsor_id
      where m.user_id = auth.uid() and m.status = 'active'
        and s.status = 'active'
      order by m.activated_at desc limit 1),
    '{}'::jsonb);
$$;

grant execute on function public.my_sponsor() to authenticated;


-- ---------------------------------------------------------------------
-- 8. Removing someone -- the leaver case.
--
-- Soft, and it removes ONLY what this sponsor granted. Someone who
-- bought Premium themselves keeps it; someone sponsored by two
-- organisations keeps the other. That is what `source` in 0057 was for.
-- ---------------------------------------------------------------------
create or replace function public.remove_sponsor_member(
  p_sponsor_id text,
  p_user_id    uuid,
  p_actor      text
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare v_n int;
begin
  update public.sponsor_members
     set status = 'removed', removed_at = now()
   where sponsor_id = p_sponsor_id and user_id = p_user_id and status = 'active';
  get diagnostics v_n = row_count;

  if v_n = 0 then
    return public._refuse(p_actor, 'remove_sponsor_member', 'sponsor_members',
      p_sponsor_id, 'not_a_member', 'That person is not an active member.');
  end if;

  perform public.revoke_plan_by_source(p_user_id, 'sponsor', p_sponsor_id,
                                       p_actor);

  return public._allow(p_actor, 'remove_sponsor_member', 'sponsor_members',
    p_sponsor_id, 'removed', 'Member removed and their sponsored plan revoked.',
    jsonb_build_object('user', p_user_id));
end;
$$;

revoke execute on function
  public.remove_sponsor_member(text, uuid, text) from public;


-- ---------------------------------------------------------------------
-- 9. The panel manages sponsors. It does not manage members.
-- ---------------------------------------------------------------------
grant select, insert, update, delete on public.sponsors        to directus_cms;
grant select, insert, update, delete on public.sponsor_domains to directus_cms;

drop policy if exists "sponsors cms write" on public.sponsors;
create policy "sponsors cms write" on public.sponsors
  for all to directus_cms using (true) with check (true);
drop policy if exists "sponsor_domains cms write" on public.sponsor_domains;
create policy "sponsor_domains cms write" on public.sponsor_domains
  for all to directus_cms using (true) with check (true);

-- Deliberately NOT granted: sponsor_members, sponsor_activation_codes.
-- Membership says where a person works and is the row that de-anonymises
-- them; codes are credentials in flight. Neither is a form to edit.


-- ---------------------------------------------------------------------
-- 10. A sponsored plan, and one to sell.
-- ---------------------------------------------------------------------
insert into public.plans (id, name, kind) values
  ('employer_standard', 'ParentVeda Premium (provided by your employer)', 'sponsor')
on conflict (id) do nothing;

-- Grants everything free grants, plus the sponsor capabilities. Written
-- as a select so it stays correct as capabilities are added.
insert into public.plan_capabilities (plan_id, capability_id)
select 'employer_standard', id from public.capabilities
on conflict do nothing;


-- =====================================================================
-- VERIFY
--
--   insert into public.sponsors (id, name, plan_id, seats_purchased, status)
--   values ('zzv_acme', 'Acme', 'employer_standard', 2, 'active');
--   insert into public.sponsor_domains (domain, sponsor_id)
--   values ('acme-test.com', 'zzv_acme');
--
--   select public.request_sponsor_activation('nobody@unknown-domain.com');
--     -> ok:false, code:not_eligible   (same answer as a suspended customer)
--
--   select public.request_sponsor_activation('someone@acme-test.com');
--     -> ok:true, code_sent  -- and the code is NOT in the response
--
--   select code from public.sponsor_activation_codes
--    where work_email = 'someone@acme-test.com';   -- read it as postgres
--   select public.confirm_sponsor_activation('someone@acme-test.com', '<code>');
--     -> requires a signed-in session; from the SQL editor auth.uid() is
--        null, so expect not_signed_in. Test this path from the app.
--
--   delete from public.sponsors where id = 'zzv_acme';   -- cascades
-- =====================================================================
