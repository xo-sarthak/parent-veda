-- =============================================================================
--  0043 — TTC treatment cycles
-- -----------------------------------------------------------------------------
--  The dates a clinic gave a couple on IVF, IUI or ovulation induction: stim
--  start, trigger shot, retrieval, transfer, beta test.
--
--  These are FACTS, not estimates. ParentVeda cannot derive any of them - a
--  doctor chose them after a scan - which is exactly why the app stopped
--  publishing a calendar fertility window on these paths (0041's `clinicLed`
--  behaviour) and carries the clinic's dates instead.
--
--  COUPLE-SCOPED, and firmly so. A retrieval date is not one person's
--  appointment; he needs it as much as she does, and a treatment cycle where
--  only she can see the dates rebuilds exactly the asymmetry this stage exists
--  to correct.
--
--  Runs after 0009 (public.my_partner_id) and 0041.
-- =============================================================================

create table if not exists public.ttc_treatment (
  user_id     uuid primary key references auth.users (id) on delete cascade,

  -- The whole cycle as one jsonb blob rather than five columns.
  --
  -- Deliberate: the set of milestones differs by protocol (an IUI has no
  -- transfer; a frozen transfer has no retrieval; a natural-modified cycle has
  -- neither), and a column-per-step schema would need a migration every time a
  -- protocol we had not thought about turned up. The client owns the shape, and
  -- there is exactly one row per person, so there is nothing to query across.
  cycle       jsonb not null default '{}'::jsonb,

  updated_at  timestamptz not null default now()
);

alter table public.ttc_treatment enable row level security;

drop policy if exists ttc_treatment_couple on public.ttc_treatment;
create policy ttc_treatment_couple on public.ttc_treatment
  for all
  using (auth.uid() = user_id or user_id = public.my_partner_id())
  -- Read your partner's cycle, but only ever write your own row.
  with check (auth.uid() = user_id);

grant select, insert, update, delete on public.ttc_treatment to authenticated;

comment on table public.ttc_treatment is
  'Clinic-given treatment dates (IVF/IUI/OI). Facts from a clinic, never derived by the app - which is why the calendar fertility window is suppressed on these paths.';
