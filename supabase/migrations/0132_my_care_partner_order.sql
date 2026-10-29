-- =============================================================================
--  0132 — my_care_partner(): the same answer every time
--  (Partner Editions D1, item 5, 2026-10-29; docs/partner-editions/DOCTOR-APP.md)
-- -----------------------------------------------------------------------------
--  0068 ended the function with `limit 1` and no ORDER BY. Postgres promises
--  nothing about which row a LIMIT keeps without an ORDER BY: it is whichever
--  the plan reaches first, and that can change after a vacuum, an index or
--  simply more rows. One account CAN own several partners:
--
--    * Route B (expert_accounts -> care_partners.expert_id): a doctor's own
--      solo partner row, AND a clinic row that names her as its lead doctor.
--    * Route A (partner_accounts): one organisation login, on top of the above.
--
--  So "which partner am I?" could flip between launches, and every number the
--  doctor app shows (impact, funnel, earnings, the QR code in the kit) would
--  flip with it. No error, no log: a different partner's numbers.
--
--  THE ORDER, and why:
--    1. Her OWN partner row first: the one whose expert_id is the expert this
--       account consults as. ParentVeda+ is opened by a person, and the
--       person's own practice is what she means by "my numbers". An
--       organisation she also manages is a separate login (Partners app, P1).
--       A clinic row that names her as its lead doctor matches this too;
--       between such rows, rule 2 decides. Telling those apart needs a
--       column care_partners does not have, and no partner has hit it yet.
--    2. Then oldest first (created_at): the relationship that came first is
--       the one every existing kit was printed for.
--    3. Then id, so two rows created in the same instant still order the
--       same way. Without a unique last key, "deterministic" is only likely.
--
--  Same columns, same grant, same rule (caller_owns_partner is unchanged, per
--  MASTER R4). Only the choice among rows the caller already owns changes.
--
--  ORDER TO RUN: any time; the D1 app build does not depend on it, it only
--  stops the answer drifting. Safe to run twice (create or replace).
-- =============================================================================

create or replace function public.my_care_partner()
returns table (
  id            text,
  name          text,
  type          text,
  status        text,
  speciality    text,
  organisation  text,
  department    text,
  city          text,
  logo_url      text,
  photo_url     text,
  trust         jsonb,
  expert_id     text,
  verified_at   timestamptz
)
language sql
stable
security definer set search_path = ''
as $$
  select cp.id, cp.name, cp.type, cp.status, cp.speciality, cp.organisation,
         cp.department, cp.city, cp.logo_url, cp.photo_url, cp.trust,
         cp.expert_id, cp.verified_at
  from public.care_partners cp
  where cp.deleted_at is null
    and public.caller_owns_partner(cp.id)
  order by
    -- 1. her own practice: this partner IS the expert she signs in as
    exists (
      select 1 from public.expert_accounts ea
       where ea.user_id = auth.uid()
         and cp.expert_id is not null
         and ea.expert_id = cp.expert_id
    ) desc,
    -- 2. the oldest relationship, 3. a unique last key
    cp.created_at asc,
    cp.id asc
  limit 1;
$$;

grant execute on function public.my_care_partner() to authenticated;
