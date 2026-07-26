-- =====================================================================
-- 0039_care_funnel.sql -- the acquisition funnel actually gets recorded
-- ---------------------------------------------------------------------
-- 0037 gave partner_attributions three timestamp columns -- scanned_at,
-- installed_at, signed_up_at -- and then only ever filled signed_up_at.
-- The spec (Module 2 "Database must track", Module 7 "Conversion Funnel")
-- asks for the whole chain, and a funnel missing its first two steps
-- cannot answer the one question worth asking about a printed poster:
-- how many people who scanned it actually arrived?
--
-- The scan happens BEFORE there is an account, so the app cannot write a
-- row for it. It carries the two timestamps it observed locally and hands
-- them over at binding time. Those are client-supplied and therefore
-- CLAMPED here: never in the future, never before the token existed, and
-- never after the signup they precede. A partner paid on a funnel should
-- not be able to improve it by changing a device clock.
--
-- Also adds the acquisition events to parent_timeline, so Module 8's
-- timeline starts where the journey actually starts rather than at
-- signup.
--
-- PREREQ: 0037.
-- =====================================================================

create or replace function public.attribute_to_partner(
  p_token text,
  p_channel text default 'qr',
  p_campaign text default null,
  p_scanned_at timestamptz default null,
  p_installed_at timestamptz default null
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_me        uuid := auth.uid();
  v_ref       public.partner_referrals%rowtype;
  v_partner   public.care_partners%rowtype;
  v_now       timestamptz := now();
  v_scanned   timestamptz;
  v_installed timestamptz;
begin
  if v_me is null then return 'not_signed_in'; end if;

  select * into v_ref from public.partner_referrals
   where token = upper(trim(p_token)) and active;
  if not found then return 'unknown_token'; end if;

  if v_ref.expires_at is not null and v_ref.expires_at < now() then
    return 'expired';
  end if;

  select * into v_partner from public.care_partners
   where id = v_ref.partner_id and deleted_at is null;
  if not found then return 'unknown_partner'; end if;
  if v_partner.status <> 'active' then return 'partner_not_active'; end if;

  -- Self-referral: the partner's own expert account scanning their own QR.
  -- The single cheapest way to manufacture commission, so it is checked here
  -- and not only in the app.
  if v_partner.expert_id is not null and exists (
       select 1 from public.expert_accounts ea
        where ea.user_id = v_me and ea.expert_id = v_partner.expert_id
     ) then
    return 'self_referral';
  end if;

  -- FIRST TOUCH WINS. The primary key would reject this anyway; checking
  -- first turns a raised exception into a message worth showing.
  if exists (select 1 from public.partner_attributions where user_id = v_me) then
    return 'already_attributed';
  end if;

  -- Clamp the client's timestamps into [token created, now]. A null stays
  -- null: "we do not know when she scanned" is honest, and inventing now()
  -- would make every funnel report an instant conversion.
  v_scanned := least(greatest(p_scanned_at, v_ref.created_at), v_now);
  v_installed := least(greatest(p_installed_at, v_scanned, v_ref.created_at), v_now);

  insert into public.partner_attributions
    (user_id, partner_id, token, channel, campaign_id,
     scanned_at, installed_at, signed_up_at)
  values
    (v_me, v_partner.id, v_ref.token, coalesce(p_channel, v_ref.channel),
     coalesce(p_campaign, v_ref.campaign_id),
     v_scanned, v_installed, v_now);

  -- The journey starts at the scan, not at the signup. Backdated to what
  -- actually happened so the timeline reads in the right order.
  if v_scanned is not null then
    insert into public.parent_timeline (user_id, partner_id, event, detail, at)
    values (v_me, v_partner.id, 'referral_scanned',
            coalesce(p_channel, v_ref.channel), v_scanned);
  end if;
  if v_installed is not null then
    insert into public.parent_timeline (user_id, partner_id, event, detail, at)
    values (v_me, v_partner.id, 'app_installed', null, v_installed);
  end if;
  insert into public.parent_timeline (user_id, partner_id, event, detail, at)
  values (v_me, v_partner.id, 'signup_completed', null, v_now);

  insert into public.parent_timeline (user_id, partner_id, event, detail)
  values (v_me, v_partner.id, 'attributed', coalesce(p_channel, v_ref.channel));

  return 'ok';
exception
  when unique_violation then return 'already_attributed';
end;
$$;

grant execute on function
  public.attribute_to_partner(text, text, text, timestamptz, timestamptz)
  to authenticated;

-- The 3-argument form from 0037 stays callable so an older build in the
-- wild keeps working; it simply records no scan or install time.


-- ---------------------------------------------------------------------
-- partner_funnel() -- the conversion funnel, still counts only
--
-- Same privacy rule as partner_impact: totals, scoped to the calling
-- expert account, no way to reach a family from any of it.
--
-- scans and installs count only the families who eventually signed up --
-- an anonymous scan that never became anybody is not recorded anywhere,
-- because recording it would mean tracking a person who has not yet
-- agreed to anything. So this measures "of the families you brought, how
-- far along the chain do we have evidence", not "how many people looked".
-- That is a narrower claim, and it is the honest one.
-- ---------------------------------------------------------------------
create or replace function public.partner_funnel(p_partner_id text)
returns table (
  scanned    bigint,
  installed  bigint,
  signed_up  bigint,
  activated  bigint
)
language sql
stable
security definer set search_path = ''
as $$
  with allowed as (
    select 1
    from public.care_partners cp
    join public.expert_accounts ea on ea.expert_id = cp.expert_id
    where cp.id = p_partner_id and ea.user_id = auth.uid()
  ),
  fam as (
    select a.*
    from public.partner_attributions a
    where a.partner_id = p_partner_id and exists (select 1 from allowed)
  )
  select
    (select count(*) from fam where scanned_at is not null),
    (select count(*) from fam where installed_at is not null),
    (select count(*) from fam where signed_up_at is not null),
    -- Activated = told us something real about her family, which is the
    -- first moment the app is of any use to her.
    (select count(distinct t.user_id) from public.parent_timeline t
      where t.user_id in (select user_id from fam)
        and t.event in ('pregnancy_added','child_added'));
$$;

grant execute on function public.partner_funnel(text) to authenticated;
