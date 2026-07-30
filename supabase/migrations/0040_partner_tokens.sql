-- =====================================================================
-- 0040_partner_tokens.sql -- the database mints tokens, and is the only
-- thing that knows one
-- ---------------------------------------------------------------------
-- FIXING A REAL DEFECT, raised by the website build.
--
-- Until now the doctor app DERIVED the token it printed
-- (CarePartnerEngine.tokenFor: a hash of partner id + rotation) while the
-- website RESOLVED a scan against partner_referrals. Two sources of truth
-- for the same string.
--
-- If nobody inserted the matching partner_referrals row, the doctor's
-- referral kit still rendered a perfectly well-formed QR code. It scans.
-- It looks right. It resolves to nothing, forever, on a poster that stays
-- on a wall for two years. Nothing errors anywhere.
--
-- So: the token now exists ONLY as a row. The app reads it; it never
-- computes it. No row means the kit says "not set up yet" instead of
-- printing a code that credits nobody. A token that cannot be printed is
-- a visible problem; a token that prints and does not work is not.
--
-- PREREQ: 0037.
-- =====================================================================


-- ---------------------------------------------------------------------
-- mint_partner_token(partner_id, channel, campaign_id, expires_at)
--
-- Random, not derived. A hash of the partner id would be reproducible by
-- anyone who learned the scheme, and reproducible tokens on a public
-- endpoint are guessable tokens.
--
-- The alphabet matches the app exactly -- no I, L, O, 0 or 1 -- because
-- these are read off printed posters by people who then type them in.
--
-- ADMIN ONLY. Issuing a referral token is an editorial act: it is the
-- moment ParentVeda says this professional may acquire families in our
-- name. There is deliberately no path to this from either app.
-- ---------------------------------------------------------------------
create or replace function public.mint_partner_token(
  p_partner_id  text,
  p_channel     text default 'qr',
  p_campaign    text default null,
  p_expires_at  timestamptz default null
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_alphabet constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  v_token    text;
  v_try      int := 0;
begin
  -- A token for a partner who does not exist would resolve to nothing,
  -- which is the exact failure this migration exists to remove.
  if not exists (
    select 1 from public.care_partners
     where id = p_partner_id and deleted_at is null
  ) then
    raise exception 'no such care partner: %', p_partner_id;
  end if;

  loop
    v_try := v_try + 1;
    v_token := '';
    for i in 1..10 loop
      v_token := v_token ||
        substr(v_alphabet, 1 + floor(random() * length(v_alphabet))::int, 1);
    end loop;

    exit when not exists (
      select 1 from public.partner_referrals where token = v_token
    );

    -- 31^10 is about 8.2e14. Twenty collisions in a row is not bad luck,
    -- it is a broken random source, and silently looping forever would
    -- hang the caller rather than tell anyone.
    if v_try > 20 then
      raise exception 'could not mint a unique token after % attempts', v_try;
    end if;
  end loop;

  insert into public.partner_referrals
    (token, partner_id, campaign_id, channel, expires_at)
  values
    (v_token, p_partner_id, p_campaign, coalesce(p_channel, 'qr'), p_expires_at);

  return v_token;
end;
$$;

-- Not granted to authenticated or anon. service_role only, which is what
-- the admin panel will use. A doctor cannot issue their own code.
revoke execute on function
  public.mint_partner_token(text, text, text, timestamptz) from public;


-- ---------------------------------------------------------------------
-- One convenience for the admin panel: create the partner and its first
-- token together, because a partner without a token cannot do anything
-- and forgetting the second step is precisely the defect above.
-- ---------------------------------------------------------------------
-- ⚠️ SUPERSEDED BY 0052_audit_partner_creation.sql, which adds a ninth
-- parameter (p_actor) so partner creation is audited.
--
-- DO NOT RE-RUN THIS FILE expecting it to be a no-op. Adding a parameter does
-- not replace a function in Postgres — it creates a SECOND one. Re-running
-- 0040 after 0052 resurrects this 8-argument version alongside the audited
-- 9-argument one, and then a caller supplying eight arguments silently gets
-- the version that writes no audit row. Happened on 2026-07-30.
--
-- If you have both, drop this one:
--   drop function public.create_care_partner(
--     text,text,text,text,text,text,text,text);
create or replace function public.create_care_partner(
  p_id           text,
  p_name         text,
  p_type         text default 'doctor',
  p_speciality   text default '',
  p_organisation text default '',
  p_city         text default '',
  p_expert_id    text default null,
  p_status       text default 'pending'
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_token text;
begin
  insert into public.care_partners
    (id, name, type, status, speciality, organisation, city, expert_id)
  values
    (p_id, p_name, p_type, p_status, p_speciality, p_organisation,
     p_city, p_expert_id);

  v_token := public.mint_partner_token(p_id);
  return v_token;
end;
$$;

revoke execute on function public.create_care_partner(
  text, text, text, text, text, text, text, text) from public;


-- ---------------------------------------------------------------------
-- Backfill: any partner that already exists without an active token gets
-- one. Safe to re-run; does nothing once every partner has one.
-- ---------------------------------------------------------------------
do $$
declare r record;
begin
  for r in
    select cp.id from public.care_partners cp
     where cp.deleted_at is null
       and not exists (
         select 1 from public.partner_referrals pr
          where pr.partner_id = cp.id and pr.active
       )
  loop
    perform public.mint_partner_token(r.id);
  end loop;
end $$;
