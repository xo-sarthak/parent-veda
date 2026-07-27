# Trying to Conceive — build specification

The companion to `docs/TTC-Master.pdf`. That document is the **constitution**:
philosophy, emotional posture, the Chapters idea, the six pillars. It says of
itself (p.109) that it is *"an excellent product strategy and architecture
reference, but not yet a build specification"*, and puts itself at 90–92%
complete — the missing part being a screen inventory, a schema and a component
library.

This file is that missing part. **Every decision taken while building is
recorded here on the day it is taken**, with the reasoning, so nothing important
lives only in a commit message or in someone's head.

**Started:** 2026-07-27

---

## 0. Before proposing anything

**`CLAUDE.md` at the repo root is the architecture anchor.** It records what
this codebase actually uses and the things briefs repeatedly assume wrongly —
Riverpod, GoRouter, `/lib/features/`, config-driven profiles, rules in the CMS.

Decision 1.1 below is the origin of that file: the master document's own Part 6
prescribed a stack the app does not use, and the same assumption has arrived
twice more since in separate documents. Rather than correcting it each time, the
correction now lives in one place that loads automatically.

## 1. Standing decisions

Taken with the user before any code was written.

| # | Question | Decision | Why |
|---|---|---|---|
| 1.1 | Part 6 of the master doc prescribes **Riverpod + GoRouter + `/lib/features/`**; the app is singleton `ChangeNotifier` stores + `Navigator` + `lib/screens/` | **Existing patterns win** | Following the doc literally means rewriting 499 files, and would break its own Principle 2 (*"life stages change, architecture does not"*). Those sections read as greenfield advice written before the codebase was inspected. |
| 1.2 | The doc contains **no actual TTC content** — no chapter copy, insights, myths, ritual scripts | **Claude authors seed content** in ParentVeda's voice: bilingual, India-first, original, calm. Structurally marked as seed so it can never reach a real account. Replaced via Directus later. | Phases stay unblocked; the alternative is a visually hollow stage. |
| 1.3 | Own shell, or a branch inside `MainScaffold`? | **Own shell, pushed route**, anchored at `ttc/today` | Exactly the parenting precedent (`pp/my_child`). Pregnancy code stays untouched, and rule §12.1.4 asks for module isolation. Identical pill / card / typography carries the continuity instead. |
| 1.4 | Part 4's **Family Journey Graph** backend | **Additive, not a rewrite** | Re-modelling 56 live tables carrying real pregnancy and parenting data to build a third stage is the expensive kind of risk. `LifeStageStore` + a `journey_timeline` event table give the Family Timeline without destabilising two shipped stages. |

---

## 2. Module layout

```
lib/ttc/                    domain + engines (pure Dart where possible)
  ttc_chapter.dart          the Chapter Engine — biology + emotion, kept apart
  cycle_store.dart          observed cycle facts only
  ttc_store.dart            journey-level facts; THE call screens make
lib/screens/ttc/            screens, isolated like post_pregnancy/
  ttc_common.dart           palette, card shell, empty state, nav, page shell
  ttc_strings.dart          bilingual UI strings + the TtcLang mirror
  ttc_today_screen.dart     Today's Journey
  ttc_prepare_screen.dart   ttc_tools_screen.dart
  ttc_calendar_screen.dart  ttc_community_screen.dart
lib/services/
  life_stage_store.dart     app-wide, NOT TTC-owned — the first Journey piece
```

**Isolation rule, enforced by test** (`ttc_shell_test.dart` → *"the module stays
isolated"*): no file under `lib/screens/ttc/` may import a pregnancy or
parenting screen. Services are shared; screens never are.

---

## 3. The Chapter Engine

The spine. `lib/ttc/ttc_chapter.dart`, pure Dart, 33 tests.

### 3.1 The split that everything rests on

> *"Cycle Day remains the backend truth. The user experiences something
> different."* — master doc §10

- **Biology** — cycle day, estimated ovulation, graded fertility. Honest,
  conventional, never rendered raw in calm copy.
- **Emotion** — which Chapter the couple is living in today.

### 3.2 The numbers, and why they are those numbers

| Constant | Value | Reasoning |
|---|---|---|
| `lutealPhaseDays` | 14 | The luteal phase is far more stable across women than the follicular. Ovulation is estimated **backwards from the next expected period**, which is why a 26-day and a 34-day cycle both land somewhere sensible instead of everyone being told "day 14". |
| `defaultCycleLength` | 28 | Used only before anything is logged, and never presented as *her* cycle. |
| `preparingChapterDays` | 28 | Chapter 1 is about folic acid, lifestyle and first appointments — genuinely the opening stretch of a journey, not a phase of a cycle. |
| `irregularVarianceDays` | 8 | Beyond this, cycles are treated as irregular, which **lowers confidence** — it never hides the tool or invents a prediction. PCOS must feel equally understood. |
| Fertile window | ovulation −5 → +1 | Sperm survive ~5 days, the egg ~1. Graded `medium → high → peak → high`, never flagged. |

### 3.3 Confidence

`unknown` → `low` → `medium` → `high`. A recorded body signal beats calendar
arithmetic outright: a **positive LH** test puts ovulation the following day; a
**temperature shift** is read back one day, because it is seen *after* the fact.

When confidence is `unknown`, `fertilityFor()` returns **null** — the product
would rather show nothing than a level it cannot stand behind. The UI still
renders the card (a feature is never hidden); it just says so.

### 3.4 Decision: chapters loop, and progress never reverses

Chapters 2–4 ride the cycle, so a couple who did not conceive moves from *The
Waiting Days* back to *Knowing Your Rhythm*. That is the honest shape of trying
to conceive.

**It must never render as regression.** So the engine exposes
`chapterProgress` — position *within* the current chapter — and there is
**no global "Chapter 2 of 5" bar**. A bar that slid backwards every month would
be the single cruellest object in the product. Pinned by a test asserting
progress stays in `[0,1]` on every day of a long cycle, including an overdue
period.

### 3.5 Chapter resolution

```
pregnancyConfirmed          → 5  A New Beginning
journey < 28 days, or no cycle data
                            → 1  Preparing Together
cycle day < ovulation−5     → 2  Knowing Your Rhythm
ovulation−5 … ovulation+1   → 3  Trying Together
after that                  → 4  The Waiting Days
```

---

## 4. Design language

**The palette is identical to pregnancy and parenting, hex for hex.** Not
laziness — the requirement (§2.3: *"The difference lies only in content"*).

The parenting app learned the expensive lesson here: the colours were *already*
the same and the two apps still felt different, because every screen hand-rolled
its own card. So the parts that actually carry continuity are the shared
`TtcCard` shell, the **18px gutter**, the **26 radius**, and the **ink lift**
shadow (`0x142D144C`) — never a purple glow.

Fraunces is allowed in hero moments only. The floating pill nav is the same
component shape as `PvTabBar` and `PpBottomNav`: the active tab expands into a
filled pill with icon **and** label.

---

## 5. Known seams (deliberate, to be closed)

| Seam | Why it exists | Closes in |
|---|---|---|
| `TtcLang` mirrors the app language | The language lives on `PregnancyController`, which is constructed in `main.dart` and threaded down rather than exposed as a singleton — and TTC tabs are separate pushed routes, so an `InheritedWidget` cannot reach across them. The doorway syncs the mirror on the way in. | The day the app language becomes a proper app-wide store |
| `LifeStageStore` is device-local | The `profiles` table has no `life_stage` column yet; adding it to the update would fail the write. Written locally **before** the network call so a declared stage survives a failed profile save. | Phase 8 |
| Hero shortcuts (Me / Us / What's next) show "coming soon" | Chapter detail is Phase 2. An acknowledged tap beats a control that silently does nothing. | Phase 2 |

---

## 6. Phase status

All nine phases built. **37 files / ~11,800 lines** under `lib/ttc/` and
`lib/screens/ttc/`, plus **7 test files / ~2,100 lines**. Full suite **995
passing** (was 850); `flutter analyze` shows the same 6 pre-existing issues and
none from TTC.

| # | Phase | Status |
|---|---|---|
| 0 | Spine, shell, door | **Done** |
| 1 | Today's Journey | **Done** |
| 2 | Chapters | **Done** |
| 3 | Tools hub | **Done** — 18 of 22 tiles open real screens |
| 4 | Calendar · Journey Map · Milestones · Family Timeline | **Done** |
| 5 | Partner Mode | **Done** |
| 6 | Prepare · Community · Care Circle · Products | **Done** |
| 7 | Transition Engine | **Done** — Ask Veda door now wired (2026-07-27) |
| 8 | Backend + sync | **Done** |

### What each phase delivered

**0 — Spine.** `TtcChapterEngine` (pure Dart, 33 tests), `CycleStore`,
`TtcStore`, `LifeStageStore`, the design layer, the five-destination shell, the
doorway below the parenting doorway, and the auth stage answer finally persisted.

**1 — Today's Journey.** Chapter hero (Me / Us / What's next), rhythm card in
three honest states, Today's Insight + reader, video, the five-part Daily
Ritual with its own screen, Daily Myth, journal card + writer + journal screen,
nutrition with the India-first line, movement, and Today's pick.

**2 — Chapters.** All five chapters × three faces (Me / Us / Next), each with
sections, an action plan that is explicitly not a checklist, medical guidance,
Ask Veda suggestions and a journal prompt.

**3 — Tools.** One log engine + one tracker screen powering eight trackers;
Cycle Companion, Ovulation Companion and Fertility Window all reading the same
engine as the hero; supplements; the medical test library with real Indian
prices and cycle timing.

**4 — Journey.** Journey Map with looping chapters and derived milestones,
`FamilyTimeline` (append-only, cross-stage), and a real Calendar month grid
merging cycle, fertile window, logs, journal and milestones.

**5 — Partner Mode.** Slate-skinned Today: mission, supporting her, **his half
of this**, learn, shared journal. Dev-only Her|Him switch.

**6 — Commerce and people.** `ServiceStage` extended with
`tryingToConceive` so TTC bookings share one history; 13 real Offerings with
real slots; Care Circle; a research-first products library where the
"watch out" carries the same weight as the recommendation.

**7 — The Transition Engine.** Naegele-derived due date written to the key
`PregnancyController` already reads, life stage flipped, two timeline moments
written, and a result reporting **real counts** of what carried over. Idempotent
and reversible.

**8 — Backend and sync.** `0041_ttc.sql` (9 tables) and `0042_ttc_records.sql`
(2 more), plus `profiles.life_stage`, RLS and grants — and the Dart half:
`TtcSyncedStore` wires nine stores to real rows.

### How TTC sync differs from the house mixin

`CloudSyncedStore` syncs one JSON blob per user into `user_state`, which is
own-row. Right for a preferences store, wrong here — half the TTC data is
**couple-scoped by design**, and a blob keyed to one user cannot be read by the
partner. So these stores sync to the real tables and let RLS scope them:
`fetchShared` for couple-scoped, `fetch` for her own-row.

**Merge rule: union by id, never cloud-wins.** Cloud-wins is fine for a
preference blob and wrong for a journal — an entry written on a plane would be
silently deleted on reconnecting. Every row carries an app-generated id, which
makes the union trivial and idempotent. The one exception is `ttc_journeys`,
genuinely one row of settings, where last-write-wins is correct.

Because the merge is a union, **every delete pushes explicitly** — otherwise a
removed period, un-ticked ritual part or deleted journal entry returns on the
next pull. That is wired for all six deletable things.

### The partner mechanism, now real

She publishes her **derived chapter** to `ttc_journeys.current_chapter`. His app
reads that row (couple-scoped) and renders it. He never reads `ttc_cycles` —
0041 gives him no policy to, and a test asserts the policy contains no
`my_partner_id`. `TtcStore.displayChapter` is the seam.

### The privacy decision in the migration

Her raw cycle (`ttc_cycles`, `ttc_cycle_signals`) is **own-row** — her partner
cannot read it at all. But his Today shows the chapter, which is derived from
it. Rather than widening read access and *promising* the client will only show
the derived value, the derived chapter is written to `ttc_journeys`, which is
couple-scoped, and the raw dates stay private in both directions.

Same shape as the baby-name matches in `0009`: when an answer must come from
data one person should not see raw, keep the rows private and put the computed
answer in front. Anyone can write their own client.

`journey_timeline` has **no UPDATE policy and no UPDATE grant** — a life story
you can silently rewrite is not a record.

---

## 7. What is genuinely not built

Listed plainly so nothing reads as finished when it is not.

| Gap | State | Blocks |
|---|---|---|
| **Migrations not applied** | `0041` and `0042` are written and ready. Until they run against the project, every sync call fails and the stores stay local — which is the designed failure mode, not a bug. | Data surviving a phone change |
| **Ask Veda door** | **DONE (2026-07-27).** `TtcAskVedaScreen` + three-way FAB routing + chapter/partner entries; service gained `stage/chapter/cycle_day/ttc_path/months_trying/lang` (framing only, no gating), TTC red flags (ectopic/OHSS), and a 324-doc bilingual TTC corpus. Partner door never sends `cycle_day`. See `docs/TTC-ASKVEDA-HANDOFF.md` and STILL-OPEN §9.1. | — |
| **Payments** | Buying grants the entitlement; no money moves. Stated on screen, as everywhere else in the app. | Real revenue |
| **Care Circle breadth** | Holds ParentVeda and the partner. Doctors and clinics wait on the attribution question in `STILL-OPEN.md` §2.1. | Blocked, not forgotten |
| **Community posting** | Reading, joining, liking and saving are real and shared. Composing a TTC post is not wired to `CommunityStore.addPost` yet. | Nothing today |
| **Clinical copy review** | Authored seed content, medically conventional, **not reviewed by a doctor**. | Launch |

All 22 Tools tiles now open a real screen — `built: false` appears nowhere, and
a test asserts it.

## 8. Open questions for the user

Raised as they appear; nothing here blocks the current phase.

1. **Does the TTC door belong on the pregnancy Home permanently?** Today it sits
   beside the parenting door as a preview, which is right for testing. At launch
   the honest entry is the auth stage selector — a pregnant mother has little
   reason to see a TTC door, and a TTC user should not have to pass *through*
   the pregnancy home to reach her own stage. Needs a routing decision before
   launch.
2. **Should the fertile window be shown to a couple who has said they are on an
   IVF path?** Calendar fertility means something quite different mid-IVF, and
   showing it unchanged risks being actively misleading.
3. **Medical review of clinical copy.** The engine's arithmetic is conventional
   and defensible, but the seed content that explains AMH, PCOS, IVF and test
   interpretation should be read by a doctor before launch.
