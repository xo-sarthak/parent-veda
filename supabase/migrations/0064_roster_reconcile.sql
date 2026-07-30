-- =====================================================================
-- 0064_roster_reconcile.sql -- what a re-uploaded sheet MEANS, and why
--                              it must never be obeyed automatically.
-- ---------------------------------------------------------------------
-- HR sends an updated staff list every so often. Importing it adds the
-- new people and updates the ones already there. It does NOT touch the
-- people who quietly disappeared from the file -- so today, taking
-- someone off the sheet does nothing at all until a human notices.
--
-- THE OBVIOUS FIX IS THE DANGEROUS ONE
--
-- "After an import, revoke anyone not in the file." That is one line and
-- it is a loaded gun, because these two uploads are IDENTICAL from
-- inside the database:
--
--     * 40 people left the company
--     * the CSV was truncated / filtered / saved from the wrong sheet
--
-- Both arrive as "these 38 addresses are missing". One is a fact and the
-- other is an accident, and only a person can tell which. An automatic
-- reconcile would cheerfully revoke a whole company's benefit because
-- someone exported with a filter still applied -- and every one of those
-- people would find out by opening the app and losing something.
--
-- > The general rule: when two very different intentions produce
-- > identical input, do not infer the intention. Report what you would
-- > do and make someone say yes. Automation is for actions whose input
-- > is unambiguous.
--
-- So this is TWO functions, deliberately:
--
--     sponsor_roster_stale(...)      -> what would be revoked. Reads only.
--     sponsor_roster_revoke(...)     -> does it, for an explicit list.
--
-- And note what "revoke" does and does not mean here. It marks roster
-- eligibility revoked, which stops FUTURE activations. It does not take
-- away Premium somebody is already using -- that is
-- remove_sponsor_member(), a separate act, because a live benefit should
-- not evaporate because a spreadsheet was edited. Losing access
-- mid-pregnancy is not a row change to the person it happens to.
--
-- PREREQ: 0058 (remove_sponsor_member), 0060 (my_sponsor_admin_id),
--         0061 (sponsor_eligible_people).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. A batch marker on the roster.
--
-- Without it there is no way to tell "was in the last upload" from
-- "has been there since March", and the diff has nothing to diff
-- against. Set it on import; everything still carrying an older batch
-- is what went missing.
-- ---------------------------------------------------------------------
alter table public.sponsor_eligible_people
  add column if not exists import_batch text;

comment on column public.sponsor_eligible_people.import_batch is
  'Free-text label for the upload this row last appeared in (e.g. "2026-08 headcount"). Set it on every CSV import; sponsor_roster_stale() then reports who is NOT in the newest batch. Never used for access decisions -- only for the diff.';

create index if not exists sponsor_eligible_people_batch_idx
  on public.sponsor_eligible_people (sponsor_id, import_batch);


-- ---------------------------------------------------------------------
-- 2. What WOULD be revoked. Reads nothing else, changes nothing.
--
-- Returns whether each person is currently USING the benefit, because
-- that is the number that decides whether the operator should hesitate.
-- "3 people would be revoked, 0 of them active" is routine housekeeping.
-- "38 would be revoked, 22 of them active" is a truncated CSV, and the
-- shape of the answer should make that obvious at a glance.
-- ---------------------------------------------------------------------
create or replace function public.sponsor_roster_stale(
  p_sponsor_id   text,
  p_latest_batch text
) returns table (
  work_email  text,
  full_name   text,
  last_batch  text,
  is_active   boolean       -- currently holding the benefit
)
language sql stable security definer set search_path = ''
as $$
  select e.work_email,
         e.full_name,
         e.import_batch,
         coalesce(m.status, '') = 'active'
    from public.sponsor_eligible_people e
    left join public.sponsor_members m
      on m.sponsor_id = e.sponsor_id
     and lower(m.work_email) = e.work_email
   where e.sponsor_id = p_sponsor_id
     and e.status = 'eligible'
     and coalesce(e.import_batch, '') <> p_latest_batch
   order by 4 desc, 1;      -- active people first: they are the warning
$$;

-- Ops-facing, called from a Directus Flow or the SQL editor. Not granted
-- to app sessions: an employee has no reason to enumerate their
-- colleagues, and this takes a sponsor id rather than deriving one.
revoke execute on function
  public.sponsor_roster_stale(text, text) from public;


-- ---------------------------------------------------------------------
-- 3. Do it -- for an EXPLICIT list of addresses.
--
-- Takes the addresses rather than re-running the diff, and that is the
-- safety property rather than an inconvenience. If this recomputed
-- "everyone not in the latest batch", then whatever changed between
-- looking and confirming would be silently included -- the operator
-- would have approved a number and applied a different one. Passing the
-- list makes the thing approved and the thing done the same thing.
--
-- Refuses rather than raising: it is a gate, it writes an audit row, and
-- 0055 is the reason those two facts go together.
-- ---------------------------------------------------------------------
create or replace function public.sponsor_roster_revoke(
  p_sponsor_id text,
  p_emails     text[],
  p_actor      text
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_list  text[];
  v_n     int;
  v_live  int;
begin
  if p_emails is null or array_length(p_emails, 1) is null then
    return public._refuse(p_actor, 'sponsor_roster_revoke',
      'sponsor_eligible_people', p_sponsor_id, 'nothing_to_do',
      'No addresses were given.');
  end if;

  select array_agg(lower(trim(e))) into v_list
    from unnest(p_emails) as e where coalesce(trim(e), '') <> '';

  update public.sponsor_eligible_people
     set status = 'revoked', revoked_at = now()
   where sponsor_id = p_sponsor_id
     and work_email = any (v_list)
     and status = 'eligible';
  get diagnostics v_n = row_count;

  -- Counted AFTER the update and reported back, because this is the
  -- number the operator most needs to see and the one they are least
  -- likely to have asked about: how many of these people are using the
  -- benefit right now. Their access is untouched (see the header) and
  -- somebody has to decide about them.
  select count(*) into v_live
    from public.sponsor_members m
   where m.sponsor_id = p_sponsor_id
     and m.status = 'active'
     and lower(m.work_email) = any (v_list);

  if v_n = 0 then
    return public._refuse(p_actor, 'sponsor_roster_revoke',
      'sponsor_eligible_people', p_sponsor_id, 'nothing_to_do',
      'None of those addresses were eligible.');
  end if;

  return public._allow(p_actor, 'sponsor_roster_revoke',
    'sponsor_eligible_people', p_sponsor_id, 'revoked',
    format('%s removed from the eligibility list. %s of them are currently '
           'using the benefit and keep it until removed individually.',
           v_n, v_live),
    jsonb_build_object('revoked', v_n, 'still_active', v_live,
                       'emails', v_list));
end;
$$;

revoke execute on function
  public.sponsor_roster_revoke(text, text[], text) from public;


-- =====================================================================
-- HOW AN UPDATED SHEET IS ACTUALLY PROCESSED
--
--   1. In Directus, import the CSV into sponsor_eligible_people with
--      import_batch set to a label for this upload, e.g. '2026-08'.
--      (Existing rows are updated, so their batch moves forward.)
--
--   2. LOOK BEFORE ACTING:
--
--      select * from public.sponsor_roster_stale('demo_northwind', '2026-08');
--
--      Read the is_active column. A handful of inactive leavers is
--      routine. A long list with many active people means the file was
--      wrong -- stop, and ask HR.
--
--   3. Only then, and with the list you just read:
--
--      select public.sponsor_roster_revoke(
--        'demo_northwind',
--        array['someone@acme.com', 'other@acme.com'],
--        'your-name');
--
--   4. Anyone in that list still USING the benefit keeps it. Deciding
--      about them is deliberate and individual:
--
--      select public.remove_sponsor_member('demo_northwind',
--               '<their-uid>'::uuid, 'your-name');
--
-- VERIFY
--
--   -- A batch label nobody has means everybody is stale, which is the
--   -- truncated-CSV case. It must be reported, never acted on:
--   select count(*) from public.sponsor_roster_stale('demo_northwind', 'nope');
--
--   -- Revoking an address that is not eligible changes nothing:
--   select public.sponsor_roster_revoke('demo_northwind',
--            array['nobody@nowhere.test'], 'verify');
--     -> ok:false, nothing_to_do
-- =====================================================================
