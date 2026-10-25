# Global changes — what's live, what's built, what's owed

The app-wide pass the user started on 2026-10-23: fifteen changes that cut
across every stage (TTC, Pregnancy, Parenting, Skilling). This file is the one
place that says, for each, **what is live, what is built but not committed,
what still has to be done, and what is waiting on someone.**

**How to keep it:** update the item's status in the same change that moves it.
A commit hash means it is in `main`. "Built" means it is in the working tree
and tested, waiting for the user's commit. Never tick an item that is only
half done across stages — say which stages are left. Dates are absolute.

Status words: **LIVE** (committed) · **BUILT** (tested, not committed) ·
**OWED** (agreed, not started) · **WAITING** (blocked on the user or on
content) · **PARKED** (decided to do later).

Plan of record: `~/.claude/plans/in-this-chat-i-swift-hearth.md` (phases 0–7).

---

## At a glance

| # | Change | Status | Where |
|---|---|---|---|
| 1 | Life-moment welcome video (pop-up, blurred) | OWED — design approved | Phase 3 |
| 2 | Every article links to a service | LIVE for Pregnancy + TTC (aa1fe9e); Parenting OWED | Phase 2 |
| 3 | Universal search + Ask Veda mark | ON HOLD (user, 2026-10-24): mark built as Aurora (COMMITTED c237e83, final design H vs K still open); search placement study done, choice on hold | Phase 4 |
| 4 | "Films" → "Videos" | LIVE (faf0f04) | Phase 0 |
| 5 | Door intro video (Option A chip) | OWED — design approved | Phase 3 |
| 6 | Real products replace dummy products | WAITING — product master sheet | Phase 7 |
| 7 | Store and services follow her week / child's age | Store LIVE (aa1fe9e); services OWED | Phase 2 |
| 8 | Expert onboarding feed | Half LIVE (faf0f04: domain read); feed OWED | Phase 7 |
| 9 | Stage transitions: solid + celebratory | Fixes LIVE (faf0f04); matrix + B1–B7, B10 LIVE (04847a5), see `docs/STAGE-TRANSITIONS.md`; family switch F1/F3, celebration pages F4 and turning six LIVE (adae4d5); B9 and B11 LIVE; per-pregnancy records and Kept for you LIVE (R1, 656bbb3, 0114 run); F2 Add a pregnancy from the family LIVE (2290cce); F5 one learning space per child LIVE (5fa51e2); F6 open on the last profile used, and taps open their own profile, BUILT 2026-10-25 (commit pending) | Phase 5 |
| 10 | Verb cards open actions, then pitch | LIVE (aa1fe9e, 7df4711) | Phase 2 |
| 11 | "Talk to someone" → "Talk to an expert" | LIVE (faf0f04), labels only | Phase 0 |
| 12 | Position-aware notifications | OWED | Phase 6 |
| 13 | Relevance inside doors | Pregnancy LIVE (19078db); TTC phase tags LIVE (2d3a07f) | Phase 1 |
| 14 | Nutrition door pitches | LIVE (7df4711); supplements WAITING on sheet | Phase 2 |
| 15 | Action doors lead with an action | LIVE (aa1fe9e) | Phase 2 |

---

## Commits so far

| Commit | Date | What |
|---|---|---|
| faf0f04 | 2026-10-23 | Phase 0: Skilling relaunch, birth sheet, expert domain, WhatsApp 0111, films → videos, Talk to an expert |
| 19078db | 2026-10-23 | Phase 1: pregnancy doors open on her weeks |
| aa1fe9e | 2026-10-23 | Phase 2a: action doors, articles → services, store by her week |
| 7df4711 | 2026-10-23 | Phase 2b: What you need + Go further, Nutrition For your week; this tracker |
| 2d3a07f | 2026-10-23 | TTC phase tags: doors open on her cycle phase / round step |

---

## Item by item

### 1 · Life-moment welcome video — OWED (Phase 3)

**What the user asked:** at each meaningful first arrival (start TTC by intent
incl. IVF/IUI start, became pregnant, joined pregnant, birth → parenting,
joined as a parent, Skilling), the home opens with that moment's video as a
centred pop-up, everything else blurred, skip/close. Once per moment. Stays
findable in the stage's video hub.

**Decided:**
- Design approved: artifact `claude.ai/artifact/72vDaiGE93GV1ZniLA6YPh`.
- Shows only once a real video URL exists; until then switched off (no
  "coming soon" frame in her face).
- Muted autoplay with captions + sound toggle; one main button (Keep
  watching) + Skip + ✕ (Mobbin pass 2026-10-23).
- One pop-up per screen; never stacks on the first-home welcome, the TTC
  new-chapter page or a door intro.

**Exists today:** TTC only — a show-once dialog (no blur, placeholder video)
and a 7-day rail card (`TtcIntroGate`, `lib/screens/ttc/ttc_intro_flow.dart`).
Pregnancy, Parenting, Skilling: nothing.

**To build:** `lib/widgets/pv_first_video.dart` (gate + blurred pop-up +
arbiter), the moment keys set where each moment happens, the TTC dialog
migrated onto it (its flag honoured), a pinned "Start here" row in each
stage's Videos screen.

**Waiting on:** the videos themselves (list them in `DOOR-CONTENT-OWED.md`).

### 2 · Every article links to a service — LIVE for Pregnancy + TTC

- LIVE aa1fe9e: `pv_read_offer.dart` maps a read's topic to the expert who
  helps (scan → obstetrician, iron → nutritionist, OHSS → fertility doctor),
  with the stage's own doctor as the last resort. Pregnancy 69 → 132 of 152
  reads, TTC 74 → 125 of 135. Loss and urgent reads never pitch.
  Held by `test/read_offer_coverage_test.dart`.
- **OWED:** Parenting reads (they live in `pp_*_content.dart`, mostly not
  `PvRead`), and a check that the per-stage clinical fallback exists in the
  Parenting catalogue (a paediatrician consult).
- **Known small mismatches:** "vaccines in pregnancy" lands on a newborn
  masterclass; the two-week wait lands on the fertility doctor rather than the
  psychologist. Tune the word map when walking.

### 3 · Universal search — mark LIVE, search OWED (Phase 4)

**Asked:** one search bar visible on every home, searching everything we
have, a good "no result" state, the Ask Veda mark at the right end.

**Found:** ~25 separate search screens, no cross-content search
(`PvCatalogStore.search` is the only cross-stage one). Reusable pieces:
`PvLiveSearch`, `pvSearchIndex`, `ttc_stage_search`, `pp_search`, the Ask
Veda corpora (`lib/ask_veda/*_corpus.dart`).

**To do:** Mobbin pass → prototype → index (`lib/services/search/`) →
the bar on every stage home → no-result screen → an Ask Veda logo mark
(today it is a generic sparkle icon).

**Done 2026-10-24, the mark:** Aurora (option H in the prototype,
claude.ai/artifact/3372duZQUunNEUxbC2ZWTV) is `AskVedaMark`
(`lib/ask_veda/ask_veda_mark.dart`), now on every Ask Veda surface, the FAB
included. H or K is still the user's call (STILL-OPEN §100). **Search:** the
prototype's four screens wait for the user's OK.

### 4 · Films → Videos — LIVE (faf0f04)

23 strings. Scan prints, cinema, "cling film" and idioms untouched on
purpose. Headings were already "Videos".

### 5 · Door intro video — OWED (Phase 3), design approved

**Decided — Option A:** a white "▶ How this door works · 0:50" chip in the
door's photo header, under the title and blurb, above search. First open
plays it as the centred pop-up (muted, captions). After a skip, the chip says
NEW until watched; then a plain pill. No chip until the video exists.
Artifacts: `claude.ai/artifact/4hEyPYTGgcXcPLhTx7VgaG` (door) and
`claude.ai/artifact/RAJsHJcLXYpJ6DrXyjfR9S` (Nutrition door with the chip).

**To build:** an optional `introVideoSlot` on `PvDoorPage`, `PpDoor`,
`SkDoor`, `TtcFocusPage` (reuse its commented-out `heroVideoSlot`); the chip
in each door hero; one video per door listed in `DOOR-CONTENT-OWED.md`.

**Parenting, checked 2026-10-25 (step 0, S4):** nothing to build yet. With no
chip until the video exists and no door film made, a field would have nothing to
read it. The field and the chip go in with the first door film. Every parenting
door plan names its film (for example `family/door_intro`).
Health's is `health/door_intro` (a real paediatrician), owed as
`DOOR-CONTENT-OWED` HD5; still no chip (door 2 build, 2026-10-25).
You, Maa's is `you_maa/door_intro` (a real perinatal counsellor or
gynaecologist), owed as `DOOR-CONTENT-OWED` YM13; still no chip (door 3 build,
2026-10-25).

### 6 · Real products — WAITING (user's product master sheet)

When the sheet arrives: a converter like `pv_sheet_products.dart`, with week
/ age bands from the sheet. **This also switches on** the mat chip on the
yoga session and the supplement card on Nutrition (item 14) — no code change
needed for those, they match by name / category.

### 7 · Store and services by her position

- LIVE aa1fe9e: every store shelf (category, Recommended, Popular) ranks what
  fits her real week or her child's real age first; nothing is removed.
  `PvCatalogStore.fitsNow` / `_hersFirst`. Bug fixed: "For you" used to treat
  the week-20 placeholder as her week. Held by `test/store_hers_first_test.dart`.
- **OWED:** paid services by position — `BookingCatalog` / Learn catalogue
  offerings have only a stage, no week band (yoga has `month`; prep
  programmes only mention trimesters in text). Rank Learn by her week.

### 8 · Expert onboarding — half LIVE

- LIVE faf0f04: `expert_profiles.domain` is read, so a panel-published
  obstetrician lands in Pregnancy and a fertility doctor in TTC (it all went
  to Parenting before). Test: `test/expert_domain_test.dart`.
- **OWED:** `universal` experts still show under Parenting only (one offering
  carries one stage). The feed itself (a sheet or the Directus publish) and a
  checklist of what a new expert needs (photo, domain, schedule, price) —
  decide with the user.

### 9 · Stage transitions — fixes LIVE, the rest OWED (Phase 5)

- LIVE 9b53483 (before this pass): Yes I'm pregnant no longer lands on week 20.
- LIVE faf0f04: Skilling was lost on relaunch (`LifeStage.fromId` had no
  case); the birth sheet saved a skipped sex as a boy, had no born-early
  weeks, no timeline event, a stage starting "now" not on the birthday, and
  an 18-year date picker. All fixed.
- **LIVE 04847a5 (2026-10-24):** the transition matrix,
  `test/stage_transitions_test.dart` (37 tests), and fixes B1–B7: the loss →
  trying → pregnant-again path, the WhatsApp guide after a loss (migration
  0112, run by the user 2026-10-24), timeline ids per pregnancy and per baby, onboarding
  parents dated to the birthday, messages for a second pregnancy and a second
  child, and the Ask Veda button off the skilling home. One place for the
  moves: `lib/services/stage_moves.dart`.
- **The running list is `docs/STAGE-TRANSITIONS.md`** (ids, statuses, Mobbin,
  what is recorded). It is long; read it, not this entry, for what is left.
- **B10 (2026-10-24):** the Skilling avatar opened the stage menu, not You;
  fixed, and M41 holds every home's avatar. The "Expecting again?" guard (G1)
  is RECORDED: no parent reaches a Pregnancy door from Parenting (the avatar
  opens You), only the Developer stage chips, which ship in every build.
- **B9 BUILT 2026-10-24** (sync log step 14): 0113 keys 17 tables per
  person. 0113 RUN 2026-10-25 (check query: 17 rows of `user_id,id`). WAITING: the next build; the user's call on the Developer chips
  (BEFORE-LAUNCH §6).
- **OWED:** celebration pages for birth → parenting and parenting → skilling
  mirroring the TTC new-chapter page (a loss path stays quiet, never
  celebratory); hand-off to the item-1 video. Prototype first (R9).
  Kept for revert, the entry before 2026-10-24: "OWED: a transition test
  matrix (`test/stage_transitions_test.dart`) for every move and every mid-way
  join; celebration pages ... Prototype first."

### 10 · Verb cards open actions — LIVE

- LIVE aa1fe9e: the home's Move card never falls back to an article (an
  overdue week takes the nearest earlier month's session). TTC daily movement
  cards were already practices.
- LIVE 7df4711: What you need + Go further on the session page (item 14).

### 11 · Talk to an expert — LIVE (faf0f04)

26 buttons and headings. Crisis lines and "someone you trust" prose
unchanged, by decision.

### 12 · Position-aware notifications — OWED (Phase 6)

**Asked:** notifications relevant to where she stands (phase / week / child
age), milestone days (baby turns 2 months), offers and product pitches.
Goal: daily active users first, sales second.

**Found:** three local stores (`ttc_messages_store`, `preg_messages_store`,
`pp_messages_store`), all local, no push server (no FCM).

**To do:** Mobbin pass → 6a local (daily relevance nudges, milestone eves, a
product or service in the payload, frequency cap, quiet hours, never on loss
paths) → 6b server push for offers (FCM + edge function + campaigns table;
quote cost in USD and INR first).

### 13 · Relevance inside doors

- LIVE 19078db: pregnancy doors open on her weeks — `PregBand` +
  `pregRelevanceOrder` (`lib/data/doors/preg_band.dart`). Tagged: Scans
  (understand a scan by trimester), Complications (by month, cards by week),
  Move (month by month), Getting Ready (the last months). Nothing moves on the
  week-20 placeholder. Test: `test/preg_door_relevance_test.dart`.
- Parenting already opens on the child's band (`ppRelevanceOrder`).
- **LIVE 2d3a07f (2026-10-23) — TTC doors open on where she is.** `TtcFocusSection`
  and `TtcFocusGroup` carry `phases` (cycle phase) and `steps` (clinic round
  step); `lib/ttc/ttc_phase_rank.dart` reads them.
  - The door opens on the tab for her moment (Conceiving: Trying around the
    window, Waiting and testing in the wait or late). A named tab still wins;
    tab order never changes.
  - Inside a tab, her sections lead, and inside a section the reads the home's
    read rail picks for her phase (`kTtcPhaseReadIds`) lead. Her moment
    outranks her age; the age order holds among the rest.
  - Her moment = the home's own readings: a clinic's round step
    (`ttcHomeRoundPhaseOn`) wins, else her cycle phase (`ttcHomePhaseOn`).
    Unknown (`any`) moves nothing.
  - Tagged: Conceiving (2 tabs, 5 sections), IVF / treatment (3 sections by
    round step), Mind & body (2, period), Body & cycle (2). PCOS, His side,
    Getting ready, Not yet and After loss are untagged on purpose.
  - Found on the way: three hand-built section copies (age order, the
    hide-intimate switch) would have dropped the tags; they now use
    `TtcFocusSection.withTiles`.
  - Test: `test/ttc_door_phase_rank_test.dart`. Not walked on a device.
- **OWED:** tag more pregnancy doors as content is reviewed (Symptoms, Labour,
  Partner "Week by week").

### 14 · Nutrition door pitches — LIVE (7df4711)

- LIVE: "For your week" row on the Nutrition Today tab, under the plate —
  dietitian, a course, and a supplement when the store carries one, with
  "your doctor decides the dose" whenever a supplement shows.
  `lib/screens/pitch/pv_go_further.dart`, `PvNutritionForWeek`.
- WAITING: supplements are not in the catalogue (item 6).

### 15 · Action doors lead with an action — LIVE (aa1fe9e)

Move door opens on "Move today" (session, all videos and classes, Kegel);
Getting Ready opens on the name finder; TTC Mind & body headings are actions
(12 rewritten). Held by `test/action_doors_first_test.dart`.
**Parenting, 2026-10-25 (fbb6fae):** `test/pp_doors_first_view_test.dart` opens every
door at every age, at 1x and 1.5x text, and holds no lock, no overflow, and no
silent tap. Which tab each door opens on comes from its plan's `tabOrder`, set in
that door's build, and the action-first check for that door is added then.
**Feeding, 2026-10-25 (door 1 build):** `tabOrder` by band (Milk feeds to 6
months, Starting solids 6 to 12, Cooking from one), tools with ages, and
`test/pp_feeding_door_test.dart` holds the first view at 2, 7, 10, 18 and 30
months: the opening tab, the first card (an action every time: the feed timer,
then "What to feed at this age"), and the expert row.
**Health, 2026-10-25 (door 2 build):** Something's wrong opens at every age
and Get help now is always second (the plan's exception to "most pages"); the
calm tabs follow his age. The first card is Fever check every time, and the
first rail is picked for his age. `test/pp_health_door_test.dart` holds the
first view at 3 weeks, 7 months, 2 years and 4 years.
**You, Maa, 2026-10-25 (door 3 build):** How are you today opens at every band
(the frightening-thoughts route is pinned on it); the tabs after it follow her
weeks since the birth, on her youngest child's clock. Its second card is an
action, "10 minutes for you today", which opens the one session for her week.
Body and Moving open on a shelf for her week. `test/pp_you_maa_door_test.dart`
("door 3: the plan, held") holds the first view at 3 weeks, 7 weeks, 4 months
and 8 months.
**OWED:** Skilling action doors; parenting doors 4 to 14, each in its own build.

---

## Also found, not one of the fifteen

| What | Status |
|---|---|
| WhatsApp weekly guide kept going after a loss / early birth (read `due_date` only) | Migration `0111_wa_weekly_guide_stage.sql` RUN by the user 2026-10-24. It misses a loss (stage stays pregnancy): 0112, RUN 2026-10-24, see `docs/STAGE-TRANSITIONS.md` B1 |
| 4 test failures already on main: `explore_redesign`, `shravan_library`, `tap_feedback_guard`, `ttc_tools_pass_trackers` | PARKED by the user 2026-10-23 |
| STILL-OPEN entry for this pass | OWED — `docs/STILL-OPEN.md` was held by the other terminal; point it here |

## Decisions log

| Date | Decision |
|---|---|
| 2026-10-23 | Pop-ups appear only when the real video exists |
| 2026-10-23 | Door intro = Option A, header chip (after a Mobbin pass) |
| 2026-10-23 | "Talk to someone": labels only, crisis prose stays |
| 2026-10-23 | Go further: below the action, store links marked, max three cards |
| 2026-10-23 | Prototypes copy the real screen's header from the code |
| 2026-10-23 | TTC phase tags right after Phase 2 |
| 2026-10-23 | TTC doors open on her phase's tab and order inside it; her moment outranks her age; a clinic round outranks our cycle estimate |
