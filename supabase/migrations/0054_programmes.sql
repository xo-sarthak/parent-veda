-- =====================================================================
-- 0054_programmes.sql -- one-to-many, the half the panel owns.
-- ---------------------------------------------------------------------
-- The single biggest thing blocked on the admin panel: masterclasses,
-- cohorts, workshops, yoga and meditation sessions, webinars.
--
-- THE PRINCIPLE, FROM THE BACKEND SPEC:
--   "ParentVeda owns the products. Experts DO NOT create products.
--    Experts only deliver them."
--
-- That is why this module needs a panel and 1:1 consultations did not.
-- For 1:1, the product IS the doctor's time and the doctor defines it by
-- setting availability; ParentVeda only decides whether they may sell it
-- and at what price. For one-to-many, nobody's calendar defines the
-- product -- we invent it -- so title, schedule, capacity, price,
-- coupons and certificates have to be authored somewhere.
--
-- SCOPE: this is GROUP A -- creating and selling. Delivery (LiveKit
-- rooms, attendance capture, recording processing) is a separate build
-- against the app and Edge Functions, and no part of it is a panel
-- screen. The seam is deliberate and narrow: a session row carries
-- join_url and recording_url, empty here, filled there. Neither half
-- needs the other's schema to change.
--
-- PREREQ: 0029 (booking engine), 0030 (expert_accounts), 0045, 0046,
--         0050 (admin_audit), 0051 (_audit).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The product.
-- ---------------------------------------------------------------------
create table if not exists public.programmes (
  id           text        primary key,          -- 'mc_sleep_101' — human, printable
  status       varchar(32) not null default 'draft',
  -- TEXT, not an enum, for the same reason care_partners.type is: the
  -- spec asks for "future scalable program types", and a new kind must
  -- not need a release.
  kind         text        not null default 'masterclass',
  stage        text        not null default 'parenting',  -- trying|pregnancy|parenting

  title        text        not null,
  title_hi     text,
  subtitle     text        not null default '',
  summary      text        not null default '',
  summary_hi   text,
  body         text        not null default '',   -- the landing page
  body_hi      text,

  hero_image   text,
  hero_file    uuid,
  trailer_url  text,

  -- ---- money. PAISE, because this one is actually charged ----------
  -- Deliberately NOT the products table's whole-rupee convention: that
  -- is a display price linking out to a retailer, this is a sum taken
  -- from a parent. Integer paise, never float.
  price_paise      int     not null default 0 check (price_paise >= 0),
  compare_at_paise int     check (compare_at_paise is null or compare_at_paise >= 0),
  currency         text    not null default 'INR',

  capacity     int         check (capacity is null or capacity > 0),

  -- ---- certificates: the RULE lives here, issuance is Group B ------
  certificate_enabled       boolean not null default false,
  -- Per programme, not per session — the standard for a masterclass or
  -- cohort. Issued on completion, and completion is an attendance bar
  -- rather than merely having paid.
  certificate_min_attendance_pct int not null default 80
    check (certificate_min_attendance_pct between 0 and 100),
  certificate_title         text,

  -- ---- refunds: the MECHANISM here, the numbers configurable -------
  -- The policy is not settled. Rather than hold the module for it, the
  -- shape is stored per programme so it can change per product without
  -- a migration — the 0036 pattern. Defaults match what live-session
  -- platforms typically do; edit the row, not the schema.
  refund_window_hours int not null default 24 check (refund_window_hours >= 0),
  -- Watching the recording is consumption. Without this, someone
  -- watches and then refunds, and the product has been given away.
  refund_void_on_recording boolean not null default true,

  published_at timestamptz,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  -- The publishing workflow from the spec, in full. Medical review sits
  -- here even though article content has no reviewer role yet: a
  -- masterclass is an hour of a clinician talking to a room of parents,
  -- which deserves a check that a blog post arguably does not.
  constraint programmes_status_check check (status in (
    'draft', 'medical_review', 'marketing_review',
    'scheduled', 'published', 'completed', 'archived'))
);

comment on table public.programmes is
  'ParentVeda-owned one-to-many products. Experts deliver, never create. Delivery (LiveKit/attendance/recordings) is a separate build.';
comment on column public.programmes.price_paise is
  'PAISE — money actually charged. Not the products table convention, which is whole rupees for display-only prices.';

create index if not exists programmes_published_idx
  on public.programmes (status, stage, kind);


-- ---------------------------------------------------------------------
-- 2. Sessions -- when it actually happens.
-- ---------------------------------------------------------------------
create table if not exists public.programme_sessions (
  id            text        primary key,
  programme_id  text        not null references public.programmes (id) on delete cascade,
  seq           int         not null default 1,
  title         text        not null default '',
  title_hi      text,
  -- timestamptz, so a cohort spanning a DST change or a parent in a
  -- different timezone still sees the same instant.
  starts_utc    timestamptz not null,
  duration_min  int         not null default 60 check (duration_min > 0),
  capacity      int         check (capacity is null or capacity > 0),

  -- The Group B seam. Written by the delivery build, empty until then.
  join_url      text,
  recording_url text,

  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (programme_id, seq)
);

create index if not exists programme_sessions_time_idx
  on public.programme_sessions (programme_id, starts_utc);


-- ---------------------------------------------------------------------
-- 3. Expert assignment -- offered, then ACCEPTED.
--
-- The spec's flow is "Assign Expert → Expert accepts → Admin publishes",
-- and the acceptance is not ceremonial: publishing a masterclass a
-- doctor has not agreed to deliver means selling seats to a session
-- nobody is committed to running.
-- ---------------------------------------------------------------------
create table if not exists public.programme_experts (
  programme_id text not null references public.programmes (id) on delete cascade,
  expert_id    text not null,
  role         text not null default 'host',      -- host | co_host | moderator
  status       text not null default 'invited'
                 check (status in ('invited', 'accepted', 'declined', 'withdrawn')),
  invited_at   timestamptz not null default now(),
  responded_at timestamptz,
  note         text,
  primary key (programme_id, expert_id)
);

grant select on public.programme_experts to authenticated;
alter table public.programme_experts enable row level security;

-- An expert sees their own assignments — that is their inbox in the Pro
-- app. They cannot see who else was invited to what.
drop policy if exists "programme_experts own" on public.programme_experts;
create policy "programme_experts own" on public.programme_experts
  for select to authenticated
  using (expert_id in (
    select expert_id from public.expert_accounts where user_id = auth.uid()
  ));

-- No client write policy: accepting goes through the function below, so
-- an expert cannot accept on someone else's behalf by writing a row.


-- ---------------------------------------------------------------------
-- 4. Coupons -- and why these are NOT public-read.
--
-- Every other config table in this project is public-read, and that is
-- right for terms a parent must be able to see before signing up. It is
-- exactly wrong here: a readable coupon table is a published list of
-- discounts. Validation happens through preview_programme_coupon()
-- below, which returns a verdict and an amount, never the row.
-- ---------------------------------------------------------------------
create table if not exists public.programme_coupons (
  code            text primary key,
  programme_id    text references public.programmes (id) on delete cascade,  -- null = any
  kind            text not null default 'percent' check (kind in ('percent', 'flat')),
  value           int  not null check (value > 0),   -- percent, or paise
  max_redemptions int,
  redeemed        int  not null default 0 check (redeemed >= 0),
  starts_at       timestamptz,
  ends_at         timestamptz,
  active          boolean not null default true,
  created_at      timestamptz not null default now()
);

alter table public.programme_coupons enable row level security;
revoke all on public.programme_coupons from anon, authenticated;
comment on table public.programme_coupons is
  'NOT public-read, unlike every other config table here: a readable coupon table is a published discount list. Validate through preview_programme_coupon().';


-- ---------------------------------------------------------------------
-- 5. Access -- the app reads published programmes and their sessions.
-- ---------------------------------------------------------------------
alter table public.programmes enable row level security;
alter table public.programme_sessions enable row level security;

drop policy if exists "programmes public read" on public.programmes;
create policy "programmes public read" on public.programmes
  for select to anon, authenticated using (status = 'published');

drop policy if exists "programme_sessions public read" on public.programme_sessions;
create policy "programme_sessions public read" on public.programme_sessions
  for select to anon, authenticated
  using (exists (
    select 1 from public.programmes p
     where p.id = programme_id and p.status = 'published'
  ));

grant select on public.programmes         to anon, authenticated;
grant select on public.programme_sessions to anon, authenticated;

-- The CMS owns creation. Step 2 of the add-a-type recipe.
grant select, insert, update, delete on public.programmes         to directus_cms;
grant select, insert, update, delete on public.programme_sessions to directus_cms;
grant select, insert, update, delete on public.programme_experts  to directus_cms;
grant select, insert, update, delete on public.programme_coupons  to directus_cms;

drop policy if exists "programmes cms write" on public.programmes;
create policy "programmes cms write" on public.programmes
  for all to directus_cms using (true) with check (true);
drop policy if exists "programme_sessions cms write" on public.programme_sessions;
create policy "programme_sessions cms write" on public.programme_sessions
  for all to directus_cms using (true) with check (true);
drop policy if exists "programme_experts cms write" on public.programme_experts;
create policy "programme_experts cms write" on public.programme_experts
  for all to directus_cms using (true) with check (true);
drop policy if exists "programme_coupons cms write" on public.programme_coupons;
create policy "programme_coupons cms write" on public.programme_coupons
  for all to directus_cms using (true) with check (true);

drop trigger if exists programmes_media_sync on public.programmes;
create trigger programmes_media_sync
  before insert or update of hero_file on public.programmes
  for each row execute function public.cms_sync_media('hero_file', 'hero_image');


-- ---------------------------------------------------------------------
-- 6. assign_programme_expert -- an offer, not an assignment.
-- ---------------------------------------------------------------------
create or replace function public.assign_programme_expert(
  p_programme_id text,
  p_expert_id    text,
  p_actor        text,
  p_role         text default 'host'
) returns text
language plpgsql security definer set search_path = ''
as $$
begin
  if not exists (select 1 from public.programmes where id = p_programme_id) then
    perform public._audit(p_actor, 'assign_programme_expert', 'programmes',
      p_programme_id, jsonb_build_object('expert', p_expert_id), 'refused',
      'no such programme');
    raise exception 'no such programme: %', p_programme_id;
  end if;

  insert into public.programme_experts (programme_id, expert_id, role)
  values (p_programme_id, p_expert_id, coalesce(p_role, 'host'))
  on conflict (programme_id, expert_id) do update
    set role = excluded.role,
        status = 'invited',
        invited_at = now(),
        responded_at = null;

  perform public._audit(p_actor, 'assign_programme_expert', 'programmes',
    p_programme_id, jsonb_build_object('expert', p_expert_id, 'role', p_role),
    'ok', null);
  return 'invited';
end;
$$;

revoke execute on function
  public.assign_programme_expert(text, text, text, text) from public;


-- ---------------------------------------------------------------------
-- 7. respond_to_programme_assignment -- the EXPERT's act, not admin's.
--
-- Granted to authenticated, unlike everything else in the admin set,
-- because accepting is the expert's decision. The expert id is derived
-- from auth.uid() through expert_accounts and never passed in, so a
-- caller cannot accept on somebody else's behalf.
-- ---------------------------------------------------------------------
create or replace function public.respond_to_programme_assignment(
  p_programme_id text,
  p_accept       boolean,
  p_note         text default null
) returns text
language plpgsql security definer set search_path = ''
as $$
declare
  v_expert text;
  v_n      int;
begin
  select expert_id into v_expert
    from public.expert_accounts where user_id = auth.uid();

  if v_expert is null then
    raise exception 'not an expert account';
  end if;

  update public.programme_experts
     set status = case when p_accept then 'accepted' else 'declined' end,
         responded_at = now(),
         note = p_note
   where programme_id = p_programme_id
     and expert_id = v_expert
     and status = 'invited';
  get diagnostics v_n = row_count;

  if v_n = 0 then
    raise exception 'no open invitation for this programme';
  end if;

  perform public._audit(v_expert, 'respond_to_programme_assignment',
    'programmes', p_programme_id,
    jsonb_build_object('accepted', p_accept), 'ok', p_note);

  return case when p_accept then 'accepted' else 'declined' end;
end;
$$;

grant execute on function
  public.respond_to_programme_assignment(text, boolean, text) to authenticated;


-- ---------------------------------------------------------------------
-- 8. publish_programme -- the gate, in the mould of approve_care_partner.
--
-- Publishing puts a programme in front of parents and lets them pay for
-- it. So it refuses unless the thing is actually deliverable:
--   * it has at least one session
--   * every session is in the future
--   * an expert has ACCEPTED — not merely been invited
--   * it has been through review
-- A free programme is allowed (price 0); an unstaffed one is not.
-- ---------------------------------------------------------------------
create or replace function public.publish_programme(
  p_programme_id text,
  p_actor        text
) returns text
language plpgsql security definer set search_path = ''
as $$
declare
  v_status   text;
  v_sessions int;
  v_past     int;
  v_accepted int;
begin
  select status into v_status from public.programmes where id = p_programme_id;
  if v_status is null then
    raise exception 'no such programme: %', p_programme_id;
  end if;

  if v_status = 'published' then
    perform public._audit(p_actor, 'publish_programme', 'programmes',
      p_programme_id, '{}'::jsonb, 'ok', 'already published');
    return 'already published';
  end if;

  select count(*), count(*) filter (where starts_utc <= now())
    into v_sessions, v_past
    from public.programme_sessions where programme_id = p_programme_id;

  select count(*) into v_accepted
    from public.programme_experts
   where programme_id = p_programme_id and status = 'accepted';

  if v_sessions = 0 then
    perform public._audit(p_actor, 'publish_programme', 'programmes',
      p_programme_id, '{}'::jsonb, 'refused', 'no sessions');
    raise exception 'cannot publish %: it has no sessions.', p_programme_id;
  end if;

  if v_past > 0 then
    perform public._audit(p_actor, 'publish_programme', 'programmes',
      p_programme_id, '{}'::jsonb, 'refused', 'session in the past');
    raise exception
      'cannot publish %: % session(s) start in the past.', p_programme_id, v_past;
  end if;

  if v_accepted = 0 then
    perform public._audit(p_actor, 'publish_programme', 'programmes',
      p_programme_id, '{}'::jsonb, 'refused', 'no expert has accepted');
    raise exception
      'cannot publish %: no expert has accepted. Selling seats to a session '
      'nobody agreed to run is the failure this check exists for.',
      p_programme_id;
  end if;

  if v_status not in ('marketing_review', 'scheduled') then
    perform public._audit(p_actor, 'publish_programme', 'programmes',
      p_programme_id, jsonb_build_object('status', v_status), 'refused',
      'has not been through review');
    raise exception
      'cannot publish % from status "%": it must pass medical_review and '
      'marketing_review first.', p_programme_id, v_status;
  end if;

  update public.programmes
     set status = 'published', published_at = now(), updated_at = now()
   where id = p_programme_id;

  -- Mirror every session into booking_slots so book_slot() (0029) stays
  -- the ONE seat authority, with its FOR UPDATE lock intact. Inventing a
  -- second counter here is how two things end up disagreeing about
  -- whether a seat is free.
  insert into public.booking_slots
    (id, offering_id, expert_id, starts_utc, duration_min, capacity, join_url)
  select 'ps_' || s.id,
         p_programme_id,
         (select expert_id from public.programme_experts
           where programme_id = p_programme_id and status = 'accepted'
           order by invited_at limit 1),
         s.starts_utc,
         s.duration_min,
         coalesce(s.capacity, (select capacity from public.programmes
                                where id = p_programme_id), 100),
         s.join_url
    from public.programme_sessions s
   where s.programme_id = p_programme_id
  on conflict (id) do nothing;

  perform public._audit(p_actor, 'publish_programme', 'programmes',
    p_programme_id, jsonb_build_object('sessions', v_sessions), 'ok', null);
  return 'published';
end;
$$;

revoke execute on function public.publish_programme(text, text) from public;


-- ---------------------------------------------------------------------
-- 9. preview_programme_coupon -- a verdict, never the row.
-- ---------------------------------------------------------------------
create or replace function public.preview_programme_coupon(
  p_code         text,
  p_programme_id text
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  c      record;
  v_price int;
  v_off   int;
begin
  select price_paise into v_price
    from public.programmes where id = p_programme_id and status = 'published';
  if v_price is null then
    return jsonb_build_object('valid', false, 'reason', 'unknown programme');
  end if;

  select * into c from public.programme_coupons
   where code = upper(trim(p_code)) and active
     and (programme_id is null or programme_id = p_programme_id)
     and (starts_at is null or starts_at <= now())
     and (ends_at   is null or ends_at   >= now());

  -- One deliberately vague answer for every failure: a specific reason
  -- ("expired", "wrong programme") tells someone probing that the code
  -- EXISTS, which turns this into a discovery oracle.
  if c.code is null
     or (c.max_redemptions is not null and c.redeemed >= c.max_redemptions) then
    return jsonb_build_object('valid', false, 'reason', 'not applicable');
  end if;

  v_off := case when c.kind = 'percent'
                then (v_price * c.value) / 100
                else c.value end;
  v_off := least(v_off, v_price);   -- never negative, never a payout

  return jsonb_build_object(
    'valid', true, 'discount_paise', v_off, 'payable_paise', v_price - v_off);
end;
$$;

grant execute on function
  public.preview_programme_coupon(text, text) to authenticated;


-- =====================================================================
-- TRY IT
--
-- RUN ONE STATEMENT AT A TIME. Steps 2 and 4 are SUPPOSED to raise, and
-- the SQL editor abandons everything after the first error -- so pasting
-- the whole block gets you one refusal and nothing else.
--
-- Every line below is a comment; the expectation is stated after the
-- statement rather than on it, so copying a step cannot drag an
-- annotation into the query.
--
-- STEP 1 -- create a draft
--   insert into public.programmes (id, title, kind, stage, price_paise, capacity)
--   values ('mc_sleep_101', 'Sleep in the first year', 'masterclass',
--           'parenting', 49900, 100);
--
-- STEP 2 -- expect ERROR: cannot publish ... it has no sessions
--   select public.publish_programme('mc_sleep_101', 'sarthak');
--
-- STEP 3 -- give it one
--   insert into public.programme_sessions (id, programme_id, seq, title, starts_utc)
--   values ('mc_sleep_101_s1', 'mc_sleep_101', 1, 'Live session',
--           now() + interval '7 days');
--
-- STEP 4 -- expect ERROR: cannot publish ... no expert has accepted
--   select public.publish_programme('mc_sleep_101', 'sarthak');
--
-- STEP 5 -- invite one. In production the expert accepts from their own
-- app via respond_to_programme_assignment(); the update simulates that.
--   select public.assign_programme_expert('mc_sleep_101', 'exp_meera', 'sarthak');
--   update public.programme_experts set status = 'accepted'
--    where programme_id = 'mc_sleep_101';
--   update public.programmes set status = 'marketing_review'
--    where id = 'mc_sleep_101';
--
-- STEP 6 -- expect: published
--   select public.publish_programme('mc_sleep_101', 'sarthak');
--
-- STEP 7 -- the seats exist, and every attempt was logged
--   select * from public.booking_slots where offering_id = 'mc_sleep_101';
--   select actor, action, target_id, outcome, detail
--     from public.admin_audit_log order by at desc limit 10;
-- =====================================================================
