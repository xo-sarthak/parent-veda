# The eleven parenting sections — state

> Built from `Feedback on parenting Section (1).xlsx`, one sheet per section, each
> sheet a full end-to-end build spec (~12,000 to 16,000 characters each).
> **Read `docs/PP-SECTION-PATTERN.md` before touching any of them** — it is the
> mechanism; this file is the state.

---

## What was built, and why it is shaped this way

Eleven specs arrived at once. Every one of them independently mandated the same
short list of page formats ("chart-card, comparison table, step-list, cards, short
article, flagged callout... not as generic prose"), the same age-banding behaviour,
the same India-first rules, and the same "no filler" instruction.

That shared surface is the whole design decision. Eleven sections built
independently would each grow their own step-list and their own callout, and they
would not match — which is not a hypothesis, because this repo already shipped
**three different bottom navigation bars** for exactly that reason, each fixed once
by a different pass, and it took a shared `PvNavBar` to end it.

So a **content-block model** went in first:

| File | What it owns |
|---|---|
| `pp_content.dart` | The block types (`PpIntro`, `PpArticle`, `PpSteps`, `PpCards`, `PpTable`, `PpChartCard`, `PpCallout`, `PpScript`, `PpWhenLine`, `PpIndiaNote`, `PpVideoSlot`, `PpAudioSlot`, `PpLink`, `PpConsult`) and the **one** renderer. |
| `pp_age_bands.dart` | `PpBand` / `PpBandSet`, plus the shared band sets. One mechanism, per-section band definitions. |
| `pp_section_screen.dart` | `PpSection` / `PpArea`, the landing screen and the area screen. |
| `pp_section_registry.dart` | `kPpSections` — the one list, so reachability is a data question. |

**A section author writes data, never layout.** No `Scaffold`, no `TextStyle`, no
`SizedBox` in a section file. What that buys, concretely:

- Fix the step-list's spacing once and every step-list in the parenting app moves.
- "Every page opens with an intro", "no em dashes anywhere", "every band shows at
  least one area", "no two slots share an id" become **tests over data**
  (`test/pp_section_test.dart`), not a reading of eleven screens.
- Content can move to Directus later without touching a code path.

The cost, stated plainly: a page needing a bespoke layout must either add a block
type or drop out of the model. That friction is deliberate — it makes "I'll just
hand-build this one" a visible decision rather than the easy path.

---

## An area is her question; a layer is our inventory

The parenting app opens **39 of its 40 doors** onto a generic layer-ordered screen:
Articles · Videos · Products · Consult, whatever the door was about. Four of the
eleven specs name this as the thing to fix, in almost the same words — *"Health is
one of the 39 brackets still opening the generic layer-ordered screen; build it to
the new hub model."*

An **area** is a question a parent has ("She keeps waking at night"). A **layer** is
a content type we happen to own. Ordering a screen by layer is the supply-side
thinking the whole door audit was against, and it is why `PpArea` titles are
tested against a banned list of mechanism words (`module`, `tracker`, `content`,
`articles`, `library`, `engine`).

---

## Age banding narrows what leads, never what exists

Four specs described the same failure independently:

- Behaviour: *"so a parent of a 3-month-old never sees an empty tantrum library"*
- Potty: *"a newborn parent sees the gentle su-su intro, a 2-year parent sees the
  real training content"*
- You, Maa: *"a mother 4 months in must not see day-1 healing content"*
- Early Learning: *"heavily age-gated so it never reads as a placeholder"*

`PpBandSet.ordered` puts the child's own band first and keeps every other band
reachable. That is the repo's existing rule — `test/landing_focus_test.dart`
enforces *personalisation changes ranking and order, never structure* — and all
four specs arrived at it on their own.

Two band-set decisions worth knowing:

- **`kPpPostpartumBands` is separate from `kPpChildBands` even though the numbers
  match.** "0 to 6 weeks" for the mother means her healing, not her baby's newborn
  stage. Sharing the set would mean a boundary moved for a reason about babies
  silently moves her six-week check.
- **Sleep gets finer bands in the first year** (`kPpSleepBands`), because a newborn
  and a nine-month-old have almost nothing in common on that subject and one
  "0 to 12 months" band would have to describe both.

---

## Audio: one player, a new library

The Sleep spec flagged a decision and asked for the recommended default:

> build the Sleep Sounds player as a REUSABLE app-wide ParentVeda Audio player
> component... Also decide whether its library is fresh or extends the existing
> Garbh Sanskar audio library.

Both halves are implemented, and both halves matter:

- **The player is `RagaAudioStore`** — which already existed, already owns the
  one-player-app-wide invariant, and was written days earlier to fix a report that
  Garbh Sanskar music had no pause. (It did have one. There were four independent
  `AudioPlayer`s, so pause paused the wrong one.) Building a second player for baby
  sleep would have recreated that exact bug.
- **The library is separate** (`pp_sounds_data.dart`, `kPpSoundsLibrarySource =
  'baby_sleep_v1'`, marked REQUIRED-CONFIRM as the spec asked). Garbh Sanskar audio
  is a mother connecting to a baby she has not met; this is a baby who will not
  sleep. Merging them puts a bedtime story in a prenatal practice.

The **sleep timer lives in the store, not the player screen**, and it **survives a
track change**. Both are the same lesson: she puts the phone down, so a timer owned
by a widget dies with the widget and the audio plays on. And a timer cancelled by
switching track means she taps a different lullaby and silently plays all night —
the precise harm the timer exists to prevent.

⚠️ **Volume is not an in-app slider.** Both platforms own volume at the OS level, so
an in-app slider multiplies against hardware volume and the same "40%" is a
different loudness on every phone. That is the wrong property for the one control
with a safety story. The screen states the true thing plainly instead. **Open point:
if a genuine in-app cap is wanted, it needs platform work.**

---

## ⚠️ A defect found while wiring: six unreachable `owed()` blocks

`pp_home_v3.dart`'s `_hubAction` checks `journeyFor(action)` and **returns** before
the `switch`. Seven parenting doors have journeys:

`kPpActPottyReadiness` · `kPpActPottyTraining` · `kPpActSchoolReadiness` ·
`kPpActFirst40Days` · `kPpActMaternalConcern` · `kPpActMaternalRecovery` ·
`kPpActTradition`

So their `case` arms in the switch — six carefully written `owed(...)` calls, each
with its own copy and a "meanwhile" fallback — **can never run**. They compile, they
read as live code, and nothing fails.

This is the same trap the pregnancy side hit when three doors gained real sections,
and the fix is the same: the section switch goes **before** the journey guard. The
journeys are kept in the data as the record of what each door promised, not deleted.

Also noted: **`kPpActTradition` is declared twice** — `parenting_hubs.dart:42` and
`parenting_journeys.dart:54`, both `'pp_tradition'`. It works because the values
agree, and two constants holding one identity is a hazard waiting for someone to
edit one of them.

---

## Per-section state

Filled in as each section lands. `pages` counts `PpPage`s; `blocks` counts content
blocks across them.

| # | Section | Bracket | Areas | Pages | Blocks | Note |
|---|---|---|---|---|---|---|
| 1 | Sleep | `parenting_sleep` | 7 | 37 | 281 | no sleep training anywhere; safe sleep is harm-reduction |
| 2 | Feeding | `parenting_feeding` | 8 | 53 | 358 | fed is fine; no solids dogma; Area 2 flagged for legal sign-off (IMS Act) |
| 3 | Health | `parenting_health` | 11 | 54 | 368 | rebuild; triage first; 47 clinical figures flagged |
| 4 | Development | `parenting_development` | 5 | 23 | 198 | rebuild; milestones + activities + speech only |
| 5 | Behaviour | `parenting_behaviour` | 4 | 14 | 107 | band A landed from the batch, bands B to D written by hand |
| 6 | Potty | `parenting_potty` | 7 | 23 | 161 | su-su cueing is the frame, not the Western blitz |
| 7 | Early Learning | `parenting_early_learning` | 12 | 125 | 706 | rebuild; 58 written story pages; secular values, no drilling |
| 8 | Jaapa: First 40 Days | `parenting_first_40` | 10 | 41 | 283 | peak-fear moment; every label is her question |
| 9 | You, Maa | `parenting_maternal` | 10 | 98 | 621 | no tracker anywhere; bounce-back refused outright |
| 10 | Traditions | `parenting_traditional` | 7 | 24 | 270 | secular framing; 25 harmful-practice callouts |
| — | What to Buy | `parenting_buying` | — | — | — | **deliberately sectionless** — see below |

**Totals: 10 sections, 81 areas, 492 pages, 3,353 blocks, 224 doctor callouts,
172 flagged clinical items.** All ten are registered in `kPpSections`, every door
is wired, and `kPpSectionsOwed` is empty.

### The tools these sections needed

Eight surfaces were referenced by real, tappable links before anything existed
behind them. Found by the link resolver in `test/pp_sleep_check_test.dart`, which
walks every `PpLink` in every section — the only way to find a dead link short of
tapping all of them.

| surface | what it became |
|---|---|
| `pp_crisis_path` | **new screen.** Seven You, Maa pages about intrusive thoughts, rage and psychosis linked to nothing. Emergency first, then a person, then what to say, reassurance last. Every number `REQUIRED_TO_CONFIRM`. |
| `pp_fever_check` | **new screen.** The one tool in the app that gives a directive answer, because under three months a 38 C fever is not a judgement call. Red flags are asked *before* the thermometer. |
| `pp_baby_ok_check` | **new screen.** Four newborn checks that resolve individually and are never totalled. |
| `pp_baby_food_check` | **new screen.** Verdict is a function of (food, age); "not yet" always says when. Searches Hindi aliases. |
| `pp_sleep_check` + `pp_food_chart` | **one generic screen** (`PpChartBrowserScreen`) reading each section's own `PpChartCard`s. Two bespoke screens would have drifted. |
| `pp_health_home`, `pp_emergency_card`, `pp_doctor_visit` | already shipped, reachable from Explore, but **unaddressable** — no surface id. Reachable from one place is not the same as routable. |
| `pp_memories`, `pp_leaps`, `pp_ask_veda`, `pp_compare` | same: real screens with no id. |

### Why What to Buy has no `PpSection`

It was the one spec of the eleven that opened *"This is NOT a ground-up build...
do NOT restructure it."* Its section is the existing commerce IA
(`ProductsDiscoveryScreen` and the screens around it), which is richer than a
content section and already reachable. Wrapping it in a `PpSection` to make the
registry look complete would be filler of exactly the kind the specs forbid, and it
would put a second, worse front door on a shop that already has one.

`kPpSectionlessBrackets` names it, so `test/pp_section_test.dart` can tell
"deliberately elsewhere" apart from "forgotten" — the same distinction the bracket
model's four-state enum exists to preserve.

---

## Open points

Carried here rather than left in eleven agent reports. See also
`docs/STILL-OPEN.md`.

1. **Every `REQUIRED_REVIEW` clinical figure needs a human.** Health, First 40 Days
   and You, Maa all contain thresholds (temperatures, nappy counts, bleeding,
   dosing) that were written to be useful and must be confirmed before ship. They
   are greppable: `grep -rn "REQUIRED_REVIEW" lib/screens/post_pregnancy/`.
2. **`REQUIRED_TO_CONFIRM` helplines.** No crisis number is invented anywhere; where
   one belongs it is marked. Confirm before ship.
3. **Hindi.** Every section is plain `String`, per the standing instruction. When
   Hindi arrives this is a type change on the block classes — a compile error at
   every construction site, which is the good version of the problem (it cannot be
   half-done). The bad version would be an optional `hi` field that compiles
   immediately and renders English forever wherever someone forgot.
4. **The sleep-need quick check** reads `PpChartCard` rows as structured data, which
   is why the spec said to model them that way. If a chart card's row labels change,
   that tool changes with it.
5. **In-app volume cap** — see the audio note above.
6. **Video and audio files.** Every slot carries a title, length and `slotId`;
   nothing carries a file. `test/pp_section_test.dart` asserts slot ids are unique
   app-wide so a real file cannot land in two places.
