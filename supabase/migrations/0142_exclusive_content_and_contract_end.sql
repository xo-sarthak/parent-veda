-- =====================================================================
-- 0142_exclusive_content_and_contract_end.sql -- sessions and offers only
-- an organisation's own people see, and what happens when a contract ends
-- ---------------------------------------------------------------------
-- Partner Editions P4 (docs/partner-editions/PARTNERS-APP.md). Closes
-- STILL-OPEN §11.9 and the "nothing revokes" half of §11.4 (MASTER R2).
--
-- PART A. AN AUDIENCE ON A PROGRAMME, AND ON A COUPON.
--
--   programmes.audience_sponsor_id   only members of that employer/school
--   programmes.audience_partner_id   only families attributed to that centre
--   (both null = everyone, exactly as today; never both)
--
-- WHERE THE RULE LIVES. "Who may see this" is checked in FOUR kinds of
-- place: the view the app reads, the table's own read policy (the
-- website and anyone with the public key can select from `programmes`
-- directly, so filtering only the view hides nothing), the doors that
-- write a receipt, and the coupon validator. Four copies of the rule is
-- four chances to fix one, so there is ONE function, _audience_ok(), and
-- every place calls it.
--
-- ⚠️ A VIEW AND A POLICY RUN FUNCTIONS WITH THE VIEWER'S RIGHTS (0126
-- learned this the hard way with _programme_lead_host). _audience_ok is
-- internal and takes a user id, so it is closed to the API: granting it
-- would let anyone ask "is user X a member of sponsor Y", which is the
-- membership table by another name. The view and the policy call a thin
-- public wrapper, in_programme_audience(), that only ever asks about the
-- CALLER (auth.uid()). It tells you whether YOU are in an audience, which
-- you already know.
--
-- THE GENERAL FACT ABOUT RLS IN SUBQUERIES. programme_sessions' and
-- programme_runs' read policies say "exists (select 1 from programmes
-- where status = 'published')". That inner select is itself filtered by
-- programmes' policy for the same caller, so an exclusive programme's
-- sessions and runs vanish for a non-member with no change to either
-- policy. verify_exclusive_content.sql proves it rather than trusting it.
--
-- WHO IS IN AN AUDIENCE.
--   * sponsor: an ACTIVE sponsor_members row, and the sponsor is active
--     OR SUSPENDED. A suspension is usually a late invoice; it hides the
--     admin's view and blocks new activations (both already true since
--     0060/0136) but keeps members' benefits (R2), and an exclusive
--     session is a benefit. ENDED hides it from everyone.
--   * centre: an attribution to that partner, and the partner is active
--     or inactive (paused). Rejected or deleted ends it.
--
-- WHY THE FOREIGN KEYS ARE `on delete restrict`, not `set null`. Deleting
-- a sponsor with `set null` would turn its private session into a PUBLIC
-- one, silently. A delete that widens access must be refused, and an
-- operator who means it clears the column first.
--
-- PART B. REFUSE BEFORE MONEY MOVES, NEVER AFTER.
--
-- A non-member who knows an exclusive programme's id could still try to
-- buy it. The receipt is written in three doors: open_payment_order (a
-- paid order, before Razorpay is asked for anything), claim_free_offering
-- and record_stub_purchase. Each gains one check. NOT _write_purchase:
-- by the time a paid receipt is written the money has been taken, and
-- refusing then is taking money for nothing. Live mode books only against
-- a receipt (book_slot, LA-4), so these three doors cover booking too.
-- Copied verbatim from 0126 with the check added; nothing else changes.
--
-- PART C. partner_exclusive_content() -- the Partners app's Content tab.
-- Zero arguments, resolves the organisation through my_partner_org() as
-- 0139 does, read-only (R9: we author an organisation's sessions, not
-- them). Booked and redeemed counts are behaviour: each is null below the
-- shared min_cohort, so "1 booked the fertility session" in a team of 12
-- is never shown. Zero is held back too: if 0 were shown and 1..4 were
-- not, a blank would mean "someone did".
--
-- "VIEWED" IS NOT HERE, ON PURPOSE. The plan asked for viewed counts.
-- usage_events (0065) records which ROOM, never what was in it, so no
-- table knows who opened which programme. Adding that is a privacy
-- decision, not a column (STILL-OPEN §11.9).
--
-- PART D. CONTRACT END (R2). A trigger on sponsors: status -> 'ended'
-- withdraws every sponsored plan and every UNSPENT sponsored consultation
-- credit, through the same two functions remove_sponsor_member uses.
-- 'suspended' does nothing. A TRIGGER, not a function an operator has to
-- remember: the status is edited in SQL today and in Directus later, and
-- a rule that holds only if every editor remembers to call something is
-- not a rule. Booked consultations stand (void_consult_credits only
-- touches unspent credits).
--
-- PREREQ: 0054, 0057, 0058, 0060, 0066, 0067, 0126, 0136, 0139.
-- ORDER TO RUN: any time after 0141. Safe to run twice.
-- =====================================================================


-- ---------------------------------------------------------------------
-- A1. The columns.
-- ---------------------------------------------------------------------
alter table public.programmes
  add column if not exists audience_sponsor_id text
    references public.sponsors (id) on delete restrict,
  add column if not exists audience_partner_id text
    references public.care_partners (id) on delete restrict;

alter table public.programmes drop constraint if exists programmes_one_audience;
alter table public.programmes add constraint programmes_one_audience
  check (num_nonnulls(audience_sponsor_id, audience_partner_id) <= 1);

create index if not exists programmes_audience_sponsor_idx
  on public.programmes (audience_sponsor_id) where audience_sponsor_id is not null;
create index if not exists programmes_audience_partner_idx
  on public.programmes (audience_partner_id) where audience_partner_id is not null;

comment on column public.programmes.audience_sponsor_id is
  'Null = everyone. Set = only active members of this sponsor (active or suspended). See _audience_ok().';
comment on column public.programmes.audience_partner_id is
  'Null = everyone. Set = only families attributed to this care partner. See _audience_ok().';

-- Coupons: the same audience, and whose code it is (STILL-OPEN §13.0
-- item 1). expert_id is recorded only; paying a coupon share per sale is
-- §13.0 item 2 and is not built.
alter table public.programme_coupons
  add column if not exists audience_sponsor_id text
    references public.sponsors (id) on delete restrict,
  add column if not exists audience_partner_id text
    references public.care_partners (id) on delete restrict,
  add column if not exists expert_id text;

alter table public.programme_coupons drop constraint if exists programme_coupons_one_audience;
alter table public.programme_coupons add constraint programme_coupons_one_audience
  check (num_nonnulls(audience_sponsor_id, audience_partner_id) <= 1);

comment on column public.programme_coupons.expert_id is
  'Whose code this is (STILL-OPEN 13.0). Recorded only: the per-sale coupon share is not built.';


-- ---------------------------------------------------------------------
-- A2. The one rule.
-- ---------------------------------------------------------------------
create or replace function public._audience_ok(
  p_uid     uuid,
  p_sponsor text,
  p_partner text
) returns boolean
language sql stable security definer set search_path = ''
as $$
  select case
    when p_sponsor is null and p_partner is null then true
    when p_uid is null then false
    when p_sponsor is not null then exists (
      select 1
        from public.sponsor_members m
        join public.sponsors s on s.id = m.sponsor_id
       where m.user_id = p_uid
         and m.sponsor_id = p_sponsor
         and m.status = 'active'
         and s.status in ('active', 'suspended'))
    else exists (
      select 1
        from public.partner_attributions a
        join public.care_partners cp on cp.id = a.partner_id
       where a.user_id = p_uid
         and a.partner_id = p_partner
         and cp.deleted_at is null
         and cp.status in ('active', 'inactive'))
  end;
$$;

revoke all on function public._audience_ok(uuid, text, text) from public, anon, authenticated;

-- The caller-only door the view and the policies use.
create or replace function public.in_programme_audience(
  p_sponsor text,
  p_partner text
) returns boolean
language sql stable security definer set search_path = ''
as $$
  select public._audience_ok(auth.uid(), p_sponsor, p_partner);
$$;

revoke all on function public.in_programme_audience(text, text) from public, anon, authenticated;
grant execute on function public.in_programme_audience(text, text) to anon, authenticated;

-- A programme by id, for the receipt doors. A null id (a consultation,
-- which is not a programme) is open to everyone, as before.
create or replace function public._programme_open_to(
  p_programme_id text,
  p_uid          uuid
) returns boolean
language sql stable security definer set search_path = ''
as $$
  select p_programme_id is null or coalesce((
    select public._audience_ok(p_uid, p.audience_sponsor_id, p.audience_partner_id)
      from public.programmes p
     where p.id = p_programme_id), true);
$$;

revoke all on function public._programme_open_to(text, uuid) from public, anon, authenticated;


-- ---------------------------------------------------------------------
-- A3. The table's own read policy. sessions and runs follow through
-- their subqueries (see the header).
-- ---------------------------------------------------------------------
drop policy if exists "programmes public read" on public.programmes;
create policy "programmes public read" on public.programmes
  for select to anon, authenticated
  using (status = 'published'
         and public.in_programme_audience(audience_sponsor_id, audience_partner_id));


-- ---------------------------------------------------------------------
-- A4. The view the app reads: 0126's, verbatim, with the audience last
-- (create or replace view may only ADD columns, at the end) and the
-- audience in the where.
-- ---------------------------------------------------------------------
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
  p.refund_max_lessons,

  -- 0142: who it is for. A member's app reads these to say "for Acme
  -- people" (Partner Editions A2); everyone else never receives the row.
  p.audience_sponsor_id,
  p.audience_partner_id

from public.programmes p
where p.status = 'published'
  and p.display_source = 'server'
  -- in_programme_audience, not _audience_ok: see the header.
  and public.in_programme_audience(p.audience_sponsor_id, p.audience_partner_id);

grant select on public.programmes_published to anon, authenticated;


-- ---------------------------------------------------------------------
-- B. The three receipt doors (0126, verbatim, plus one check each).
-- ---------------------------------------------------------------------
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
      -- 0142: an exclusive programme is sold only to its audience. The
      -- same answer as an unknown offering: a specific "not for you"
      -- would confirm the programme exists.
      if not public._programme_open_to(v_price->>'programme_id', p_user_id) then
        return jsonb_build_object('ok', false, 'reason', 'unknown_offering');
      end if;
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
  if not coalesce((v_price->>'known')::boolean, false)
     -- 0142: not for this caller reads as not there at all.
     or not public._programme_open_to(v_price->>'programme_id', v_uid) then
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
  if not coalesce((v_price->>'known')::boolean, false)
     -- 0142: not for this caller reads as not there at all.
     or not public._programme_open_to(v_price->>'programme_id', v_uid) then
    return jsonb_build_object('ok', false, 'reason', 'unknown_offering');
  end if;
  cp := public._write_purchase(v_uid, p_offering_id,
          (v_price->>'price_paise')::int, 'stub', null, null, null, 'stub');
  return jsonb_build_object('ok', true, 'purchase_id', cp.id);
end;
$$;

revoke all on function public.record_stub_purchase(text) from public, anon, authenticated;
grant execute on function public.record_stub_purchase(text) to authenticated;


-- ---------------------------------------------------------------------
-- B2. The coupon validator (0054, verbatim, plus the audience). The same
-- vague answer for "not for you" as for every other failure: a specific
-- reason makes this a discovery oracle (0054's own rule).
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
  if v_price is null
     -- 0142: an exclusive programme does not exist for a non-member.
     or not public._programme_open_to(p_programme_id, auth.uid()) then
    return jsonb_build_object('valid', false, 'reason', 'unknown programme');
  end if;

  select * into c from public.programme_coupons
   where code = upper(trim(p_code)) and active
     and (programme_id is null or programme_id = p_programme_id)
     and (starts_at is null or starts_at <= now())
     and (ends_at   is null or ends_at   >= now())
     -- 0142: an organisation's offer works only for its people.
     and public._audience_ok(auth.uid(), audience_sponsor_id, audience_partner_id);

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

revoke all on function public.preview_programme_coupon(text, text) from public, anon;
grant execute on function
  public.preview_programme_coupon(text, text) to authenticated;


-- ---------------------------------------------------------------------
-- C. partner_exclusive_content() -- the Content tab.
-- ---------------------------------------------------------------------
create or replace function public.partner_exclusive_content()
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_org     jsonb := public.my_partner_org();
  v_kind    text;
  v_id      text;
  v_min     int;
  v_mode    text := public.payment_mode();
  v_progs   jsonb;
  v_offers  jsonb;
begin
  -- Zeros or {ok:false, code}, never someone else's rows.
  if coalesce((v_org->>'ok')::boolean, false) is not true then
    return jsonb_build_object('ok', false,
      'code', coalesce(v_org->>'code', 'not_an_admin'));
  end if;
  -- Not live (suspended, ended, paused): hidden, as every other admin
  -- view is (R2). my_partner_org() said why; the app's hold screen says it.
  if coalesce(v_org->>'status', '') <> 'active' then
    return jsonb_build_object('ok', false, 'code', 'not_live');
  end if;
  v_kind := v_org->>'kind';
  v_id   := v_org->>'id';

  select min_cohort into v_min from public.sponsor_analytics_config
   where id = 'default';
  v_min := coalesce(v_min, 5);

  -- Sessions written for this organisation. Workflow states before
  -- 'scheduled' are ours (drafts, reviews) and archived is withdrawn, so
  -- the admin sees what their people can see, will see, or saw.
  select coalesce(jsonb_agg(jsonb_build_object(
           'id', x.id,
           'title', x.title,
           'kind', x.kind,
           'stage', x.stage,
           'status', x.status,
           'first_session_utc', x.first_utc,
           'last_session_utc', x.last_utc,
           -- Behaviour: null below min_cohort, zero included (header).
           'booked', case when x.booked < v_min then null else x.booked end)
         order by x.first_utc nulls last, x.title), '[]'::jsonb)
    into v_progs
    from (select p.id, p.title, p.kind, p.stage, p.status,
                 (select min(s.starts_utc) from public.programme_sessions s
                   where s.programme_id = p.id) as first_utc,
                 (select max(s.starts_utc) from public.programme_sessions s
                   where s.programme_id = p.id) as last_utc,
                 (select count(distinct cp.user_id)::int
                    from public.course_purchases cp
                   where cp.programme_id = p.id
                     and cp.status = 'active'
                     and (v_mode = 'stub' or cp.mode = 'live')) as booked
            from public.programmes p
           where p.status in ('scheduled', 'published', 'completed')
             and ((v_kind = 'sponsor'  and p.audience_sponsor_id = v_id)
               or (v_kind = 'care_org' and p.audience_partner_id = v_id))) x;

  -- Offers. The code is shown: it is this organisation's own offer, it
  -- works only for its people, and the admin is the one who passes it on.
  select coalesce(jsonb_agg(jsonb_build_object(
           'code', c.code,
           'kind', c.kind,
           'value', c.value,
           'programme_title', p.title,
           'starts_at', c.starts_at,
           'ends_at', c.ends_at,
           'active', c.active
             and (c.ends_at is null or c.ends_at >= now())
             and (c.max_redemptions is null or c.redeemed < c.max_redemptions),
           'redeemed', case when c.redeemed < v_min then null else c.redeemed end)
         order by c.created_at desc), '[]'::jsonb)
    into v_offers
    from public.programme_coupons c
    left join public.programmes p on p.id = c.programme_id
   where (v_kind = 'sponsor'  and c.audience_sponsor_id = v_id)
      or (v_kind = 'care_org' and c.audience_partner_id = v_id);

  return jsonb_build_object(
    'ok', true,
    'kind', v_kind,
    'id', v_id,
    'min_cohort', v_min,
    'programmes', v_progs,
    'offers', v_offers);
end;
$$;

revoke all on function public.partner_exclusive_content() from public, anon;
grant execute on function public.partner_exclusive_content() to authenticated;


-- ---------------------------------------------------------------------
-- D. Contract end (R2).
--
-- Everyone who holds a plan or a credit FROM this sponsor, not only the
-- active sponsor_members rows: a grant is what has to be withdrawn, and
-- reading the grants themselves cannot miss one. sponsor_members is left
-- as it is: it records who activated, which is history, and the audience
-- rule already ignores an ended sponsor.
--
-- Not automatic in reverse. Setting an ended sponsor back to active does
-- not re-grant anything: a renewal is a new decision (seats, plan), and
-- STILL-OPEN §11.4 says how ops re-grants.
-- ---------------------------------------------------------------------
create or replace function public._sponsor_contract_end_trg()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  r       record;
  v_actor text := 'system: contract ended';
begin
  for r in
    select e.user_id from public.user_entitlements e
     where e.source = 'sponsor' and e.source_ref = new.id
    union
    select c.user_id from public.consult_credits c
     where c.source = 'sponsor' and c.source_ref = new.id
       and c.booking_id is null and c.voided_at is null
  loop
    perform public.revoke_plan_by_source(r.user_id, 'sponsor', new.id, v_actor);
    perform public.void_consult_credits(r.user_id, 'sponsor', new.id, v_actor,
                                        'contract ended');
  end loop;
  return new;
end;
$$;

revoke all on function public._sponsor_contract_end_trg() from public, anon, authenticated;

drop trigger if exists sponsors_contract_end on public.sponsors;
create trigger sponsors_contract_end
  after update of status on public.sponsors
  for each row
  when (new.status = 'ended' and old.status is distinct from 'ended')
  execute function public._sponsor_contract_end_trg();


-- =====================================================================
-- VERIFY: supabase/seed/verify_exclusive_content.sql (expect PASSED, FAILED 0).
--
-- Quick read-only checks:
--   select column_name from information_schema.columns
--    where table_name = 'programmes_published'
--      and column_name like 'audience_%';                       -- 2 rows
--   select tgname from pg_trigger where tgname = 'sponsors_contract_end';
--
-- Making a session exclusive (SQL, until Directus has a screen, R9):
--   update public.programmes set audience_sponsor_id = 'demo_northwind'
--    where id = '<programme id>';
-- =====================================================================
