-- =====================================================================
-- 0148_partner_offers.sql -- a family's own partner offers, read by the
-- phone
-- ---------------------------------------------------------------------
-- Partner Editions A3 (docs/partner-editions/MASTER.md, "A3 as built").
-- 0142 gave programme_coupons an audience (audience_sponsor_id /
-- audience_partner_id), but nothing on the phone could READ a coupon by
-- audience: the table is closed to the API on purpose (0054: "a readable
-- coupon table is a published discount list"), and the only door,
-- preview_programme_coupon(), needs the code already typed. So the
-- "Offer" card in the exclusive rail and the offers on Benefits had
-- nothing to draw from.
--
-- WHAT:
--   programme_coupons.label   a short phrase ops writes ("the back-to-
--                             work masterclass"). Null falls back to the
--                             programme's title, then to any programme.
--   my_partner_offers()       the CALLER's own audience offers. No
--                             arguments, so it can only ever mean
--                             auth.uid(): there is no "whose offers"
--                             question to ask about somebody else.
--
-- WHAT IT NEVER RETURNS, AND WHY.
--   * A coupon for everyone. Only coupons with an audience are listed.
--     A public code is still found by typing it, exactly as 0054 says;
--     listing those would be the discount list 0054 refused to publish.
--   * Another family's coupon. _audience_ok(auth.uid(), ...) is the same
--     one rule the view, the policies, the receipt doors and the
--     validator use (0142's header): one rule, one place to fix it.
--   * Usage counts. A used-up coupon is FILTERED OUT, but `redeemed` and
--     `max_redemptions` are never in the answer. A member could notice an
--     offer vanish when it runs out, which she would learn at checkout
--     anyway; the count itself is a partner's uptake, which is behaviour,
--     and behaviour is what R3 hides from everyone below the cohort rule.
--   * A coupon tied to a programme the caller cannot see (unpublished, or
--     another organisation's exclusive): the offer names the programme,
--     so offering it would leak the programme.
--
-- ⚠️ NOTHING APPLIES THESE YET. price_offering / open_payment_order
-- (0126) ignore coupons, and no screen calls preview_programme_coupon.
-- So the phone says what the offer IS and until when, never "Auto-
-- applied" (the user, 2026-10-31: true words now; auto-apply at checkout
-- is its own money phase, A4, in BEFORE-LAUNCH).
--
-- PREREQ: 0054, 0142.
-- ORDER TO RUN: any time after 0147, BEFORE installing the A3 build.
-- Safe to run twice. Then supabase/seed/verify_partner_offers.sql.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. The label.
-- ---------------------------------------------------------------------
alter table public.programme_coupons
  add column if not exists label text;

alter table public.programme_coupons drop constraint if exists programme_coupons_label_len;
alter table public.programme_coupons add constraint programme_coupons_label_len
  check (label is null or char_length(btrim(label)) between 1 and 60);

comment on column public.programme_coupons.label is
  'What the offer is for, as the phone shows it after "15% off": "the back-to-work masterclass". Null = the programme''s title, or any programme. Audience coupons only reach the phone (my_partner_offers, 0148).';


-- ---------------------------------------------------------------------
-- 2. my_partner_offers() -- the caller's own, and nothing else.
-- ---------------------------------------------------------------------
create or replace function public.my_partner_offers()
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_out jsonb;
begin
  if v_uid is null then
    return '[]'::jsonb;
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
           'code',         c.code,
           'kind',         c.kind,
           'value',        c.value,
           'label',        coalesce(nullif(btrim(c.label), ''), p.title),
           'programme_id', c.programme_id,
           'ends_at',      c.ends_at,
           'audience',     case when c.audience_sponsor_id is not null
                                then 'sponsor' else 'partner' end,
           'audience_id',  coalesce(c.audience_sponsor_id, c.audience_partner_id))
         order by c.ends_at asc nulls last, c.created_at desc), '[]'::jsonb)
    into v_out
    from public.programme_coupons c
    left join public.programmes p
      on p.id = c.programme_id and p.status = 'published'
   where (c.audience_sponsor_id is not null or c.audience_partner_id is not null)
     and c.active
     and (c.starts_at is null or c.starts_at <= now())
     and (c.ends_at   is null or c.ends_at   >= now())
     and (c.max_redemptions is null or c.redeemed < c.max_redemptions)
     and public._audience_ok(v_uid, c.audience_sponsor_id, c.audience_partner_id)
     -- a coupon for one programme only when she can see that programme
     and (c.programme_id is null
          or (p.id is not null and public._programme_open_to(p.id, v_uid)));

  return v_out;
end;
$$;

revoke all on function public.my_partner_offers() from public, anon, authenticated;
grant execute on function public.my_partner_offers() to authenticated;

comment on function public.my_partner_offers() is
  'Partner Editions A3: the caller''s own audience coupons (code, kind, value, label, programme_id, ends_at, audience, audience_id). Never public coupons, never another family''s, never usage counts. verify_partner_offers.sql.';
