-- =====================================================================
-- 0069_token_rotation.sql -- retiring a code that is printed on a wall
-- ---------------------------------------------------------------------
-- A referral token is not a database row. It is ink on paper in a clinic
-- waiting room, on a prescription pad, possibly on a banner nobody
-- remembers ordering. That changes what "revoke" means: the moment a token
-- stops resolving, every physical copy of it becomes a dead end for a real
-- patient standing in front of it.
--
-- So rotation here is deliberately NOT a delete and NOT an update.
--
--   * The old row stays, with active = false and retired_at set. Attribution
--     records the token it used, so deleting one would orphan the families it
--     already brought.
--   * A NEW row is minted. One partner, several tokens over time, exactly one
--     of them current.
--   * Nothing that already attributed is touched. A family stays with the
--     partner who introduced them, whatever happened to the paper.
--
-- WHY A REASON IS REQUIRED: the only honest ways to answer "why did this
-- stop working" a year later are a reason string or a guess. Retiring a code
-- is rare and consequential, so the caller is made to say.
--
-- Still service_role only. A partner cannot retire their own code — that
-- would let them invalidate posters ParentVeda paid to print.
--
-- PREREQ: 0037, 0040.
-- =====================================================================


-- retired_at: distinguishes "switched off deliberately" from "never active".
alter table public.partner_referrals
  add column if not exists retired_at timestamptz;

alter table public.partner_referrals
  add column if not exists retired_reason text;


-- ---------------------------------------------------------------------
-- rotate_partner_token(partner, reason, grace)
--
-- Returns the NEW token.
--
-- The grace window is the part worth understanding. Retiring instantly
-- means a patient who scanned the old poster ten minutes ago, then walked
-- to the pharmacy and opened the app, is refused — and refused with
-- "expired", which reads to her as the doctor's code being wrong. So the
-- old token keeps resolving for [p_grace_days] and only then stops.
--
-- Default 30 days: long enough to cover a scan-then-install gap and a
-- poster still on the wall for a fortnight, short enough that a code
-- retired for a real reason (a partner left, a printed run was wrong) is
-- actually gone in a month.
-- ---------------------------------------------------------------------
create or replace function public.rotate_partner_token(
  p_partner_id  text,
  p_reason      text,
  p_grace_days  int default 30
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_new text;
begin
  if coalesce(trim(p_reason), '') = '' then
    raise exception 'a reason is required: a retired code has to be explainable';
  end if;

  if not exists (
    select 1 from public.care_partners
     where id = p_partner_id and deleted_at is null
  ) then
    raise exception 'no such care partner: %', p_partner_id;
  end if;

  -- Retire the current ones. Kept, never deleted: partner_attributions
  -- records the token it used, and history has to stay reconstructable.
  update public.partner_referrals
     set expires_at     = now() + make_interval(days => greatest(p_grace_days, 0)),
         retired_at     = now(),
         retired_reason = p_reason
   where partner_id = p_partner_id
     and active
     and retired_at is null;

  -- Mint the replacement.
  v_new := public.mint_partner_token(p_partner_id);

  -- NOTHING is written to parent_timeline, and that is a decision rather
  -- than an omission. Rotation is OUR administrative act, not an event in a
  -- family's journey: a row there would put our paperwork into a mother's
  -- history, and it would inflate "active families" on the partner's own
  -- dashboard, which counts distinct users with recent timeline rows. If
  -- rotation ever needs an audit trail it belongs in its own table.

  return v_new;
end;
$$;

revoke execute on function
  public.rotate_partner_token(text, text, int) from public;


-- ---------------------------------------------------------------------
-- partner_token_history(partner) -- what is live, what was retired, why
--
-- Readable by the partner, because "why did my code stop working" is a
-- question they are entitled to an answer to. Carries no family data.
-- ---------------------------------------------------------------------
create or replace function public.partner_token_history(p_partner_id text)
returns table (
  token          text,
  channel        text,
  active         boolean,
  is_current     boolean,
  expires_at     timestamptz,
  retired_at     timestamptz,
  retired_reason text,
  created_at     timestamptz
)
language sql
stable
security definer set search_path = ''
as $$
  select pr.token,
         pr.channel,
         pr.active,
         -- Current = active, never retired, and not past its expiry.
         (pr.active
            and pr.retired_at is null
            and (pr.expires_at is null or pr.expires_at > now())) as is_current,
         pr.expires_at,
         pr.retired_at,
         pr.retired_reason,
         pr.created_at
    from public.partner_referrals pr
   where pr.partner_id = p_partner_id
     and public.caller_owns_partner(p_partner_id)
   order by pr.created_at desc;
$$;

grant execute on function public.partner_token_history(text) to authenticated;


-- ---------------------------------------------------------------------
-- The app reads its CURRENT token through this, rather than sorting rows
-- client-side and hoping. "Newest active row" was the app's own guess; a
-- retired-with-grace token is still active and would have won it.
-- ---------------------------------------------------------------------
create or replace function public.my_partner_token()
returns text
language sql
stable
security definer set search_path = ''
as $$
  select pr.token
    from public.partner_referrals pr
    join public.care_partners cp on cp.id = pr.partner_id
   where cp.deleted_at is null
     and public.caller_owns_partner(cp.id)
     and pr.active
     and pr.retired_at is null
     and (pr.expires_at is null or pr.expires_at > now())
   order by pr.created_at desc
   limit 1;
$$;

grant execute on function public.my_partner_token() to authenticated;
