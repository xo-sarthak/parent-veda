-- =============================================================================
--  0044 — TTC care pathway: who owns the timing
-- -----------------------------------------------------------------------------
--  Three columns on the existing ttc_journeys row. No new tables, and nothing
--  is dropped or rewritten.
--
--  ---------------------------------------------------------------------------
--  WHY THE PATHWAY ALONE WAS NOT ENOUGH
--
--  0041 stored `path` (natural / ovulation induction / IUI / IVF / FET) and the
--  app branched on it. That turned out to be the wrong abstraction, because the
--  same treatment behaves in opposite ways:
--
--    letrozole, no monitoring, no trigger → her body decides when
--    letrozole, follicular scans, trigger → the clinic decides when
--
--  Both are "ovulation induction". So the two facts below are what actually
--  decide behaviour, and `timing_ownership` is the derived answer every feature
--  reads.
--
--  ---------------------------------------------------------------------------
--  WHY THE ANSWERS ARE NULLABLE
--
--  NULL means "she has not told us", which is a real third state distinct from
--  "no" — the app falls back to the pathway's default, which is deliberately
--  set to the safer side. Storing a false here instead of a null would silently
--  turn her fertile window off on an assumption we never confirmed.
--
--  ---------------------------------------------------------------------------
--  WHY OWNERSHIP IS STORED AT ALL, GIVEN IT IS DERIVED
--
--  Because the PARTNER reads it. His account cannot see her cycle (ttc_cycles
--  is own-row with no partner policy), so he cannot derive this himself — the
--  same reason `current_chapter` is published on this table. He reads the
--  answer; he never reads the inputs.
--
--  The client remains the only writer, and the profiles themselves live in
--  versioned Dart rather than in a table: there are a handful, they are
--  identical for every user, and a clinical safety rule should not acquire a
--  network dependency or become editable from a CMS.
--
--  Runs after 0041.
-- =============================================================================

alter table public.ttc_journeys
  add column if not exists clinic_monitors     boolean,
  add column if not exists medication_controls boolean,
  add column if not exists timing_ownership    text;

alter table public.ttc_journeys
  drop constraint if exists ttc_journeys_ownership_check;

alter table public.ttc_journeys
  add constraint ttc_journeys_ownership_check
  check (
    timing_ownership is null
    or timing_ownership in ('parentveda', 'clinic_guided', 'clinic_controlled')
  );

comment on column public.ttc_journeys.clinic_monitors is
  'Is a clinic tracking this cycle with scans or bloods? NULL = not asked; the pathway default applies.';
comment on column public.ttc_journeys.medication_controls is
  'Does medication decide WHEN ovulation happens (trigger shot, or a fully medicated cycle)? NULL = not asked.';
comment on column public.ttc_journeys.timing_ownership is
  'Derived: parentveda | clinic_guided | clinic_controlled. Published so the partner can render it without reading her cycle.';
