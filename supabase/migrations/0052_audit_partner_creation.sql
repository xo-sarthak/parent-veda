-- =====================================================================
-- 0052_audit_partner_creation.sql -- close the one unaudited admin act.
-- ---------------------------------------------------------------------
-- 0051 made every admin action write admin_audit. create_care_partner
-- was not one of them: it predates the audit table (0040), so the log
-- could answer "who APPROVED this doctor" but not "who ADDED them".
--
-- That asymmetry is the wrong way round. Adding a partner is the moment
-- someone enters ParentVeda's system at all; approving them is the
-- second decision about someone already there. A log that records the
-- second and not the first cannot reconstruct how a partner came to
-- exist.
--
-- WHY DROP AND RECREATE RATHER THAN OVERLOAD
--
-- The function needs an actor parameter, and adding one with a default
-- creates a SECOND function rather than replacing the first. Two
-- overloads that differ only by a defaulted trailing parameter make
-- every short call ambiguous -- Postgres refuses with "function is not
-- unique", at the moment someone is trying to add a doctor.
--
-- Dropping is safe: this is service_role-only and no app calls it. The
-- body is otherwise unchanged from 0040.
--
-- mint_partner_token is deliberately NOT touched. Every path that
-- reaches it from the panel already audits -- create_care_partner below
-- and create_partner_campaign in 0051 -- and rewriting a working
-- token-minting function to add a log line is a poor trade against the
-- defect 0040 exists to prevent.
--
-- PREREQ: 0040, 0050, 0051.
-- =====================================================================

drop function if exists public.create_care_partner(
  text, text, text, text, text, text, text, text);

create or replace function public.create_care_partner(
  p_id           text,
  p_name         text,
  p_type         text default 'doctor',
  p_speciality   text default '',
  p_organisation text default '',
  p_city         text default '',
  p_expert_id    text default null,
  p_status       text default 'pending',
  p_actor        text default 'unknown'
)
returns text
language plpgsql
security definer set search_path = ''
as $$
declare
  v_token text;
begin
  -- Defaults to 'pending', still. Creating a partner is not approving
  -- one, and 0051's approve_care_partner is the only way to become
  -- active -- it reads the paperwork and refuses without it.
  insert into public.care_partners
    (id, name, type, status, speciality, organisation, city, expert_id)
  values
    (p_id, p_name, p_type, p_status, p_speciality, p_organisation,
     p_city, p_expert_id);

  v_token := public.mint_partner_token(p_id);

  perform public._audit(
    p_actor, 'create_care_partner', 'care_partners', p_id,
    jsonb_build_object(
      'name', p_name, 'type', p_type, 'status', p_status,
      'organisation', p_organisation, 'city', p_city,
      'token', v_token),
    'ok', null);

  return v_token;
end;
$$;

revoke execute on function public.create_care_partner(
  text, text, text, text, text, text, text, text, text) from public;


-- =====================================================================
-- VERIFY
--
--   select public.create_care_partner('demo_audittest', 'Dr Audit',
--                                     'doctor', '', '', '', null,
--                                     'pending', 'sarthak');
--   select actor, action, target_id, outcome
--     from public.admin_audit_log where target_id = 'demo_audittest';
--   -- expect one row, actor = 'sarthak'
--
-- Note the argument order: p_actor is LAST, after p_status, so an
-- existing 3-argument call still works unchanged and simply records
-- 'unknown' -- which is itself worth seeing in the log.
-- =====================================================================
