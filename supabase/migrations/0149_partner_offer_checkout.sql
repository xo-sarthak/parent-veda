-- =====================================================================
-- 0149_partner_offer_checkout.sql -- a partner offer comes off the price
-- at checkout, decided on the server
-- ---------------------------------------------------------------------
-- Partner Editions A4 (docs/partner-editions/MASTER.md, "A4"). 0148 let
-- the phone READ a family's own partner offers; nothing took one off.
-- price_offering / open_payment_order (0126, 0142) never looked at a
-- coupon, and programme_coupons.redeemed never moved.
--
-- THE SHAPE, AND WHY.
--
-- 1. ONE FUNCTION DECIDES THE DISCOUNT: _offers_for(uid, offering).
--    The phone's quote (my_offer_quote), the order (open_payment_order)
--    and the no-charge preview (record_stub_purchase) all ask it, so the
--    price she is shown and the price Razorpay is asked for cannot
--    differ: there is no second place to compute it. It sits BESIDE
--    price_offering, not inside it, because price_offering is also the
--    seat value book_slot records and the expert's earnings are taken
--    from (decision 8: experts are paid on the list price, ParentVeda
--    absorbs the discount), and every signed-in parent may call it.
--    Folding "her" into it would change those answers per caller.
--    _offers_for takes a user id, so it is CLOSED to the API; the phone's
--    door is my_offer_quote(), which takes no user (16zzz-j point 1).
--
-- 2. THE ORDER IS AN INVOICE, NOT A LOOKUP. payment_orders freezes
--    list_paise, discount_paise and coupon_code when it opens, and the
--    receipt copies them from the order at capture. Nothing re-asks the
--    coupon table later. So an offer that ends, runs out or is switched
--    off between "Pay" and Razorpay's capture is HONOURED (decision 4):
--    she was asked for that amount and paid it. The trade: a cap can be
--    exceeded by the orders already in flight when it fills. A cap is a
--    budget, not a seat count, and overshooting by one in-flight order
--    is cheaper than refusing a payment Razorpay already took.
--
-- 3. A USE IS COUNTED WHEN THE RECEIPT IS WRITTEN, ONCE. redeemed + 1
--    happens in _write_purchase's INSERT branch, in the same transaction
--    as the receipt. A replayed capture (verify and the webhook both
--    arrive) hits `on conflict do nothing`, writes no row and counts
--    nothing. An abandoned or failed order never reaches it: 0. The
--    UPDATE takes the coupon row's lock, so two captures at the same
--    moment count one after the other, never lose one. A refund does not
--    give the use back (decision 3): the partner's uptake happened.
--
-- 4. HER PICK, CHECKED AGAIN. The phone may send the code she chose in
--    "Apply offer". The server uses it only if _offers_for still returns
--    it for her; otherwise the best that does (decision 9). A code is
--    therefore a preference, never an authority: sending another
--    family's code, an expired one or a made-up one gets the best of her
--    OWN offers, or the list price. Same vague outcome for every failure,
--    so the order door is not a coupon oracle (0054's rule).
--
-- WHAT IS NOT DISCOUNTED, said plainly:
--   * Consults (source 'consult'). A coupon names a programme, never an
--     expert; consults are credits and the expert's cut comes from the
--     booking (decision 5).
--   * Public coupons (no audience). Typing a code stays unwired; the list
--     at checkout is her partner offers only, as 0148 lists them.
--   * A free programme. It stays free and uses no offer.
--   * Anything that would leave less than Rs 1: Razorpay cannot take Rs 0
--     ("free for our staff" is an exclusive programme priced at 0). So a
--     percent offer is 1 to 99 (a constraint), and any offer that would
--     leave under 100 paise for THIS price is skipped.
--
-- PREREQ: 0126, 0135, 0142, 0148.
-- ORDER TO RUN: after 0148. Then redeploy razorpay-create-order, THEN
-- install the A4 build (the phone sends p_coupon_code / couponCode).
-- Safe to run twice. Then supabase/seed/verify_partner_offer_checkout.sql.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The frozen price: on the order, and on the receipt.
-- Nullable: an old row (and every shop order) reads as "no offer".
-- ---------------------------------------------------------------------
alter table public.payment_orders
  add column if not exists list_paise     int check (list_paise is null or list_paise >= 0),
  add column if not exists discount_paise int check (discount_paise is null or discount_paise >= 0),
  add column if not exists coupon_code    text;

alter table public.course_purchases
  add column if not exists list_paise     int check (list_paise is null or list_paise >= 0),
  add column if not exists discount_paise int check (discount_paise is null or discount_paise >= 0),
  add column if not exists coupon_code    text;

comment on column public.payment_orders.discount_paise is
  'Frozen when the order opens (0149). amount_paise = list_paise - discount_paise. Never recomputed: an offer that ends mid-payment is honoured.';
comment on column public.course_purchases.discount_paise is
  'Copied from the order at capture (0149), or from the stub path. The receipt is an invoice, not a lookup.';


-- ---------------------------------------------------------------------
-- 2. A percent offer is 1 to 99.
-- ⚠️ 0126 learned that a constraint added over live rows fails the whole
-- migration on one bad row. So the live rows are read FIRST, and a bad
-- one stops here with its code named, rather than being silently
-- rewritten: what an offer is worth is ops' decision, not a migration's.
-- ---------------------------------------------------------------------
do $$
declare
  v_bad text;
begin
  select string_agg(code, ', ' order by code) into v_bad
    from public.programme_coupons
   where kind = 'percent' and value not between 1 and 99;
  if v_bad is not null then
    raise exception
      '0149 stopped: percent coupons outside 1-99: %. Fix their value (or set kind = ''flat''), then run 0149 again.',
      v_bad;
  end if;
end;
$$;

alter table public.programme_coupons drop constraint if exists programme_coupons_percent_range;
alter table public.programme_coupons add constraint programme_coupons_percent_range
  check (kind <> 'percent' or value between 1 and 99);


-- ---------------------------------------------------------------------
-- 3. _offers_for(uid, offering) -- THE rule. Closed.
-- Returns { known, offering_id, list_paise, offers: [...], best_code,
--           best_price_paise }. offers is best first: the biggest saving,
-- then the one ending soonest, then the code (so ties are stable). Each:
-- code, kind, value, label, ends_at, audience, saving_paise, price_paise.
-- Never redeemed or max_redemptions.
-- ---------------------------------------------------------------------
create or replace function public._offers_for(
  p_uid         uuid,
  p_offering_id text
) returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_price jsonb := public.price_offering(p_offering_id);
  v_list  int;
  v_prog  text;
  v_title text;
  v_offs  jsonb;
begin
  if not coalesce((v_price->>'known')::boolean, false)
     or not public._programme_open_to(v_price->>'programme_id', p_uid) then
    -- Not for this caller reads as not there at all (0142).
    return jsonb_build_object('known', false, 'offering_id', p_offering_id);
  end if;

  v_list  := (v_price->>'price_paise')::int;
  v_prog  := v_price->>'programme_id';
  v_title := v_price->>'title';

  if p_uid is null
     or v_price->>'source' <> 'programme'   -- a consult: never (decision 5)
     or v_list <= 0 then                    -- free stays free, uses none
    return jsonb_build_object(
      'known', true, 'offering_id', p_offering_id, 'list_paise', v_list,
      'offers', '[]'::jsonb, 'best_code', null, 'best_price_paise', v_list);
  end if;

  with live as (
    select c.code, c.kind, c.value, c.ends_at,
           coalesce(nullif(btrim(c.label), ''), v_title) as label,
           case when c.audience_sponsor_id is not null
                then 'sponsor' else 'partner' end as audience,
           case when c.kind = 'percent'
                then (v_list * c.value) / 100      -- floor: never over-discount
                else c.value end as saving
      from public.programme_coupons c
     where (c.audience_sponsor_id is not null or c.audience_partner_id is not null)
       and c.active
       and (c.programme_id is null or c.programme_id = v_prog)
       and (c.starts_at is null or c.starts_at <= now())
       and (c.ends_at   is null or c.ends_at   >= now())
       and (c.max_redemptions is null or c.redeemed < c.max_redemptions)
       and public._audience_ok(p_uid, c.audience_sponsor_id, c.audience_partner_id)
  )
  select coalesce(jsonb_agg(jsonb_build_object(
           'code',         l.code,
           'kind',         l.kind,
           'value',        l.value,
           'label',        l.label,
           'ends_at',      l.ends_at,
           'audience',     l.audience,
           'saving_paise', l.saving,
           'price_paise',  v_list - l.saving)
         order by l.saving desc, l.ends_at asc nulls last, l.code), '[]'::jsonb)
    into v_offs
    from live l
   -- Razorpay cannot take under Rs 1, so nothing may leave less.
   where l.saving > 0 and v_list - l.saving >= 100;

  return jsonb_build_object(
    'known',            true,
    'offering_id',      p_offering_id,
    'list_paise',       v_list,
    'offers',           v_offs,
    'best_code',        v_offs->0->>'code',
    'best_price_paise', coalesce((v_offs->0->>'price_paise')::int, v_list));
end;
$$;

revoke all on function public._offers_for(uuid, text) from public, anon, authenticated;


-- The pick: her code if the rule still offers it to her, else the best,
-- else null (list price). One place, used by the order and the stub.
create or replace function public._offer_pick(
  p_quote jsonb,
  p_code  text
) returns jsonb
language sql immutable set search_path = ''
as $$
  select coalesce(
    (select o from jsonb_array_elements(coalesce(p_quote->'offers', '[]'::jsonb)) o
      where p_code is not null
        and o->>'code' = upper(btrim(p_code))
      limit 1),
    coalesce(p_quote->'offers', '[]'::jsonb)->0);
$$;

revoke all on function public._offer_pick(jsonb, text) from public, anon, authenticated;


-- ---------------------------------------------------------------------
-- 4. my_offer_quote(offering) -- the phone's door. No user argument.
-- ---------------------------------------------------------------------
create or replace function public.my_offer_quote(p_offering_id text)
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select case when auth.uid() is null
              then jsonb_build_object('known', false, 'offering_id', p_offering_id)
              else public._offers_for(auth.uid(), p_offering_id) end;
$$;

revoke all on function public.my_offer_quote(text) from public, anon, authenticated;
grant execute on function public.my_offer_quote(text) to authenticated;

comment on function public.my_offer_quote(text) is
  'Partner Editions A4: list price, the caller''s own partner offers for this offering (each with its saving and price), and the best. The same _offers_for the order uses, so quote = charge. Never usage counts. verify_partner_offer_checkout.sql.';


-- ---------------------------------------------------------------------
-- 5. The receipt writer, now copying the frozen price and counting the
-- use. 0126's body line for line, plus the A4 lines (marked).
-- Dropped and re-created because the argument list grows; the callers
-- are plpgsql and bind by name at run time, so they keep working with
-- the new trailing defaults.
-- ---------------------------------------------------------------------
drop function if exists public._write_purchase(uuid, text, int, text, text, text, text, text);

create or replace function public._write_purchase(
  p_uid              uuid,
  p_offering_id      text,
  p_amount_paise     int,
  p_provider         text,
  p_payment_id       text,
  p_payment_order_id text,
  p_run_id           text,
  p_mode             text,
  -- A4: the stub path's frozen price. An order's own columns win.
  p_list_paise       int  default null,
  p_discount_paise   int  default null,
  p_coupon_code      text default null
) returns public.course_purchases
language plpgsql
security definer set search_path = ''
as $$
declare
  v_price jsonb := public.price_offering(p_offering_id);
  v_row   public.course_purchases;
  v_kind  text  := coalesce(v_price->>'kind', 'unknown');
  v_n     int;
  -- A4
  v_list  int  := p_list_paise;
  v_disc  int  := p_discount_paise;
  v_code  text := p_coupon_code;
begin
  -- A4: the order is the invoice. Copy it; never re-ask the coupon.
  if p_payment_order_id is not null then
    select po.list_paise, po.discount_paise, po.coupon_code
      into v_list, v_disc, v_code
      from public.payment_orders po where po.id = p_payment_order_id;
  end if;

  insert into public.course_purchases
    (user_id, offering_id, programme_id, run_id, kind, title, stage,
     amount_paise, provider, mode, razorpay_payment_id, payment_order_id,
     list_paise, discount_paise, coupon_code)
  values
    (p_uid, p_offering_id, v_price->>'programme_id',
     coalesce(p_run_id, v_price->>'run_id'), v_kind,
     coalesce(v_price->>'title', ''), v_price->>'stage',
     coalesce(p_amount_paise, 0), p_provider, p_mode,
     p_payment_id, p_payment_order_id,
     v_list, v_disc, v_code)
  on conflict do nothing
  returning * into v_row;

  if v_row.id is null then
    -- Already written (the second of verify and webhook, or a double
    -- tap): return the existing receipt, grant nothing again -- and,
    -- since A4, count nothing again.
    select * into v_row from public.course_purchases cp
     where (p_payment_id is not null and cp.razorpay_payment_id = p_payment_id)
        or (p_payment_id is null and cp.user_id = p_uid
            and cp.offering_id = p_offering_id and cp.provider = p_provider
            and cp.status = 'active')
     order by cp.created_at desc limit 1;
    return v_row;
  end if;

  -- A4: one use, in the same transaction as the receipt. The UPDATE's
  -- row lock serialises two captures at once. Not capped here: the
  -- order's price is honoured even if the cap filled meanwhile.
  if v_code is not null and coalesce(v_disc, 0) > 0 then
    update public.programme_coupons
       set redeemed = redeemed + 1
     where code = v_code;
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

revoke all on function public._write_purchase(uuid, text, int, text, text, text, text, text, int, int, text)
  from public, anon, authenticated;


-- ---------------------------------------------------------------------
-- 6. open_payment_order -- 0142's body, plus the offer. One signature:
-- the five-argument version is dropped so PostgREST never has to choose.
-- ---------------------------------------------------------------------
drop function if exists public.open_payment_order(uuid, text, text, int, int);

create or replace function public.open_payment_order(
  p_user_id       uuid,
  p_purpose       text,
  p_offering_id   text,
  p_server_amount int,     -- shop: what the function priced from products
  p_client_amount int,     -- what the phone sent; stub fallback only
  p_coupon_code   text default null   -- A4: her pick; a preference, re-checked
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
  -- A4
  v_list   int;
  v_offer  jsonb;
  v_disc   int;
  v_code   text;
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
      -- A4: the offer, from the one rule. Each tap on Pay re-prices.
      v_list  := v_amount;
      v_offer := public._offer_pick(public._offers_for(p_user_id, p_offering_id),
                                    p_coupon_code);
      v_disc  := coalesce((v_offer->>'saving_paise')::int, 0);
      v_code  := v_offer->>'code';
      v_amount := v_list - v_disc;
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
     amount_paise, priced_by, mode,
     list_paise, discount_paise, coupon_code)
  values
    (p_user_id, p_purpose, p_offering_id, v_price->>'programme_id',
     v_price->>'run_id', v_amount, v_by, v_mode,
     v_list, case when v_list is null then null else v_disc end, v_code)
  returning * into v_row;

  return jsonb_build_object(
    'ok', true, 'payment_order_id', v_row.id,
    'amount_paise', v_amount, 'priced_by', v_by, 'mode', v_mode,
    'list_paise', v_list, 'discount_paise', coalesce(v_disc, 0),
    'coupon_code', v_code);
end;
$$;

revoke all on function public.open_payment_order(uuid, text, text, int, int, text)
  from public, anon, authenticated;
grant execute on function public.open_payment_order(uuid, text, text, int, int, text) to service_role;


-- ---------------------------------------------------------------------
-- 7. record_stub_purchase -- 0142's body, plus the same offer rule, so a
-- stub walk shows (and counts) the discount exactly as a payment would.
-- ---------------------------------------------------------------------
drop function if exists public.record_stub_purchase(text);

create or replace function public.record_stub_purchase(
  p_offering_id text,
  p_coupon_code text default null
) returns jsonb
language plpgsql
security definer set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_price jsonb := public.price_offering(p_offering_id);
  cp      public.course_purchases;
  -- A4
  v_list  int;
  v_offer jsonb;
  v_disc  int;
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
  v_list  := (v_price->>'price_paise')::int;
  v_offer := public._offer_pick(public._offers_for(v_uid, p_offering_id), p_coupon_code);
  v_disc  := coalesce((v_offer->>'saving_paise')::int, 0);
  cp := public._write_purchase(v_uid, p_offering_id,
          v_list - v_disc, 'stub', null, null, null, 'stub',
          v_list, v_disc, v_offer->>'code');
  return jsonb_build_object('ok', true, 'purchase_id', cp.id,
    'amount_paise', cp.amount_paise, 'discount_paise', coalesce(cp.discount_paise, 0));
end;
$$;

revoke all on function public.record_stub_purchase(text, text) from public, anon, authenticated;
grant execute on function public.record_stub_purchase(text, text) to authenticated;


-- ---------------------------------------------------------------------
-- 8. my_purchases -- 0126's, plus what the receipt says came off.
-- ---------------------------------------------------------------------
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
           'refund',              public._refund_check(cp),
           -- A4
           'list_paise',          cp.list_paise,
           'discount_paise',      cp.discount_paise)
         order by cp.paid_at desc), '[]'::jsonb)
    from public.course_purchases cp
   where cp.user_id = auth.uid();
$$;

revoke all on function public.my_purchases() from public, anon, authenticated;
grant execute on function public.my_purchases() to authenticated;


-- ---------------------------------------------------------------------
-- 9. book_slot and the expert's earnings: UNCHANGED, on purpose
-- (decision 8). They read price_offering's seat value, which is the
-- list price, so an expert never earns less because a partner's family
-- paid less. ParentVeda absorbs the discount.
-- ---------------------------------------------------------------------


-- ---------------------------------------------------------------------
-- 10. For ops: how to write an offer (R9: SQL now, Directus later).
-- Commented out; copy, edit, run in the SQL editor. Codes are upper case
-- (the phone sends them back as they came; the server upper-cases).
--
-- -- 15% off one programme, for one employer's members, 200 uses, to 30 Nov:
-- insert into public.programme_coupons
--   (code, programme_id, kind, value, label, ends_at, max_redemptions,
--    audience_sponsor_id)
-- values
--   ('NWBACK15', '<programme id>', 'percent', 15,
--    'the back-to-work masterclass', '2026-11-30 23:59:59+05:30', 200,
--    '<sponsor id>');
--
-- -- Rs 300 off any programme, for one clinic's families, no cap, no end:
-- -- (flat values are PAISE: 30000 = Rs 300)
-- insert into public.programme_coupons
--   (code, programme_id, kind, value, label, audience_partner_id)
-- values
--   ('MEERA300', null, 'flat', 30000, 'any ParentVeda programme',
--    '<care partner id>');
-- ---------------------------------------------------------------------
