# The Symptoms door — proposal (given 2026-09-20, kept here for the build)

**Status: PROPOSAL, accepted in principle; not built.** Order of work
(the user, 2026-09-21): pregnancy home first (docs/PREG-HOME-HERO-PLAN.md),
then this door. Build it **in the door language** — photo hero (eyebrow ·
title · blurb · live search), the swipeable rail of tab cards with drawn
`IntentMark`s, sections as rails/lists, ink, no violet, no white mist, rails
edge to edge (`kPvDoorSelfPaddedTools` if the tab is a self-padded tool),
concept marks drawn, chrome Material.

## What it is, in tiers

### Tier 1 — the check-in (the first tab IS a tool, like Nutrition's Today)
- **A grid check-in**, Visible-style: the common symptoms of her week as
  tappable tiles (nausea, tiredness, heartburn, back pain, swelling,
  headache, cramps, spotting, constipation, mood, sleep, movement), tap =
  logged today, hold = a severity/note. Drawn marks, tinted wells when
  logged. "Common this week" pre-sorts the grid by her week.
- **What helps, after logging** — under the grid, one card per logged
  symptom: the read for it (the door's library), a nutrition or movement
  line, and where it points ("this is common in week 14; it eases by 16").
- **A week strip** (`PvDayStrip`, shared with the homes): seven days, dots
  on logged days; tap a day to see/edit it.
- **"Is this normal?" rows** — yes/no answers for the ten questions she
  actually asks (bleeding, less movement, sudden swelling, a headache that
  will not lift, fever, leaking fluid, pain when passing urine, itching,
  contractions before 37 weeks, a fall). A "no" row ends in **Call now**
  with her hospital number (from the profile / care circle).
- **Five urgent** — one pinned red-flag row on the Talk tab (the door
  rule: the pinned flag lives on Talk and nowhere else), whole list, untrimmed.
- **Send my week** — a text/PDF of the logged week for her doctor (the
  chart-PDF pattern; `DietChartPdf` is the model).

### Tier 2
- **Evening reminder** ("How was today?") via `NotificationService`, off by
  default, one toggle on the check-in tab.
- The logged symptoms feed the **home's daily insights** ("You logged
  heartburn — what helps") and Nutrition ("cravings"/"heartburn" swaps).

### Tier 3
- Twelve more symptoms (rarer: carpal tunnel, nosebleeds, restless legs,
  vivid dreams, metallic taste, rib pain, pelvic girdle pain, varicose
  veins, dizziness, breathlessness, gums, hair/skin) as reads. **No photos**
  on this door (symptom photography is either stock-fake or clinical); the
  hero is a photo, the rows wear drawn marks.

## Data and clinical rules
- A symptom log is **her observation** (`TruthSource`: her own observation
  outranks our calculation); never a diagnosis; every "is this normal?"
  answer ends with the doctor line; a "no" routes to Call now, not to a
  read. `Inferable` stays default-deny for anything derived from the log.
- Store: `SymptomLogStore` (CloudSyncedStore blob `symptom_log`, days keyed
  by local date string — BACKEND-PATTERNS §16h), prunes to 90 days.
- Route names carry `symptoms/...` so the Ask Veda FAB reads the stage.

## Mobbin to run before building (not yet run)
`search_screens`: "symptom tracker check-in grid daily log" (Visible, Flo
symptom logging, Clue, Bearable), "pregnancy symptoms is this normal call
doctor" (Flo, Oura pregnancy insights), "send report to doctor week summary"
(Clue's report, Flo's "Report for a doctor").
