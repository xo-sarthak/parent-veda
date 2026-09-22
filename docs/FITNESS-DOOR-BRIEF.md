# Fitness & yoga — the next pregnancy door

**Status: material, not a build.** Written 2026-09-22 while the device was with
another terminal. Nothing here has been coded. Read
`docs/PREGNANCY-DOOR-BUILD.md` for the door engine's rules first; this is the
door-specific brief that sits under it.

---

## Why this door, and why now

Ten pregnancy brackets, eight doors built. The two without one are **Is it
safe?** and **Fitness & yoga**, and only one of them is actually missing a door:

- **Is it safe?** already has a purpose-built search-first screen
  (`lib/screens/can_i/can_i_door.dart`, 951 lines, five Mobbin passes, logged
  as MOBBIN-DISCOVERY §10). It is *deliberately* not a `PvDoorPage`: the whole
  surface is one field and a lookup, and tabs would bury the field. **Leave
  it.** If it is ever migrated, that is a decision about the field, not a
  tidy-up.
- **Fitness & yoga** has content and no door. That is the gap.

---

## What already exists (do not rebuild any of it)

| Thing | Where | State |
|---|---|---|
| 27 yoga sessions, month-tagged 1–9 | `kYogaSessions`, `lib/data/prepare_data.dart` | **Bilingual, shipped Hindi (Devanagari).** Never strip it. |
| `YogaSession(id, title, duration, focus, blurb, month)` | same file | Thin. Needs extending — see below. |
| Month-tab screen | `lib/screens/prepare/prenatal_yoga_screen.dart` (231 lines) | ⚠️ **DEAD CODE — checked 2026-09-22.** Its only call site is a commented-out line in `prepare_hub_screen.dart`, so its hardcoded `_kCurrentMonth = 7` harms nobody today. Read it for the month-tab idea, not as the thing being replaced. |
| The screen the door actually replaces | `YogaHomeScreen` (`lib/screens/post_pregnancy/`), opened by surface `yoga` | Correctly parameterised for pregnancy — `kPregnancyYogaCategories`, hero "Prenatal yoga & movement". It is a parenting screen wearing pregnancy clothes; the door is what gives pregnancy its own. |
| Activity safety verdicts | `lib/data/can_i_data.dart` — `yoga`, `walking`, `swimming`, `cycling`, `running`, `dancing`, `gym`, `trekking`, `lifting`, `sex`, `sleeping_back` | Verdict + short + why + **per-trimester notes** + Indian context. Already written. |
| Activity group | `kCanIGroups`, `lib/data/can_i_groups.dart` | The eight activities are already one group. |
| Kegel / pelvic floor | `lib/screens/tools/kegel_care_screen.dart` | A real staged tool (`kegelStage1..3`). |
| Bracket | `pregnancy_fitness`, hue **160** (mint), `IntentMark.lotusMark` | Layers: content + activities + course + consult live; tools `notCore`; products `notReady` (mat, ball). |
| Hub (to be replaced) | `kPgFitness`, `lib/data/hubs/pregnancy_hubs.dart` | One need, "Practise safely today" → surface `yoga`. |
| Surface `yoga` | `surface_router.dart:137` → `YogaHomeScreen` | The door replaces what this opens; keep the surface id. |

**The reuse rule applies** (`reuse-only-the-thing-itself`): the sessions, the
verdicts and the Kegel tool ARE the thing. Everything else here is a build.

---

## Mobbin, 2026-09-22 — five passes

Queries: "prenatal or pregnancy workout home with a weekly plan and short
sessions", "yoga class library with duration, level and focus filters",
"exercise detail with steps, warnings or modifications", "guided yoga session
player with pose timer and next pose", "pelvic floor / kegel guided breathing
with contract and relax timer" (all ios).

### What converges

**1. One practice a day, named, over a week strip.**
[Open](https://mobbin.com/screens/05693914-1ca8-48d9-8fb9-016526fbac35) — a
week strip `S M T W T F S` with today underlined, then one card: *Daily
Movement · 08/27* → **SLOW FLOW** → *Renee N. · 20 min*, with segmented
Meditate / Breathe / **Move** / Sound. Not a library first. A day first.
[Runna](https://mobbin.com/screens/9eb278de-d059-4726-b181-8ec7d161ba4c) and
[Garmin](https://mobbin.com/screens/dea2e107-ceb1-41c0-aaf8-f5d24d3d2aef) do
the same at week granularity (week cards with 5/6 done; a row of day squares).

**2. The library is chips over rows, and the row carries the minutes.**
[Equinox+](https://mobbin.com/screens/874621d9-28e1-496e-a673-912a63d8ccbb):
filter pills (*Yoga · 30 to 60 mins · Hide Completed · Clear all*), "287
Classes · Sort By", rows = thumb with a duration badge, title, `category ·
level · teacher`.
[Withings](https://mobbin.com/screens/8e7c5081-14b4-4155-8e14-9ebc6b371ad1) is
the plainest version and the closest to our hand: chip row, then thumb + title
+ "14 min".
[Fitbit](https://mobbin.com/screens/dbe6b36f-315d-407f-917e-f6863325cbe9) uses
dropdowns (Duration / Workout type / Equipment) — worse: a dropdown hides its
own state.

**3. Filters as a sheet, with time as discs and level as pips.**
[Tempo](https://mobbin.com/screens/5a83a6fb-37b4-45dd-a9e5-a36af58e73e5):
Activity icons, **Time** as 10/20/30/40+ clock discs, **Level** as ●/●●/●●●,
Coaches as avatars, one Apply.

**4. Safety is a named block on the session page, not a footnote.**
[Open's](https://mobbin.com/screens/cd9836a8-bcae-49b4-aa67-fbcf5d409cdc)
session page runs DESCRIPTION → TEACHER → WHAT TO BRING → a bordered ⓘ
**"Breathwork Safety"** block that says, in as many words, *"If you are
pregnant, we do not recommend practicing any breath holds or fast-paced
breathing."* Somebody else's app carries our disclaimer better than most
pregnancy apps do.
[pliability](https://mobbin.com/screens/ca9b44fa-654f-46d7-8aad-acc49237244e)
ends its cues with *"back off if you feel any pinching"*.
[Finch](https://mobbin.com/screens/4308bf7e-6d7a-4696-8ce7-32ce5b0bfa7e) puts
*"Remember to listen to your body and stop if you ever need to"* under the
Start button — the tone we want, at the moment it matters.

**5. A player does not need video.**
[MyFitnessPal](https://mobbin.com/screens/6c72735b-463f-4f57-9cd4-57a66745722b):
the current move as a large title, its countdown at the right, a progress bar,
and the remaining moves as rows under it ending in "End of Workout". The LIST
is the player.
[Centr](https://mobbin.com/screens/37aba777-a6f4-4428-904c-ca962cc72167) adds
the two pieces that make it feel guided: a **GET READY 00:04** countdown before
each move, and a "WORKOUT OVERVIEW · **UP NEXT**" strip at the foot.
[Peloton](https://mobbin.com/screens/13b72660-0413-4115-a7d3-e523007785e1)
shows the pose name + "30 sec" + a huge numeral.
Breath work is a ring that grows and shrinks with one word in it —
[Calm Sleep](https://mobbin.com/screens/4b10f392-5449-4ca2-9bf5-ddb966adba99),
[TIDE](https://mobbin.com/screens/327e1587-5d15-496b-9a20-223bbaf1d866),
[stoic](https://mobbin.com/screens/ea4a9e85-b8fa-4116-89cf-097d614e9cb2).

### Declined, and why

- **Levels (Beginner / Intermediate / Advanced).** A pregnant woman is not
  "advanced"; the axis that matters is *how far along* and *how she feels
  today*. Trimester and month replace level everywhere.
- **Streaks, rings, "workouts 5/6".** Runna and Garmin lean on them. A missed
  day in pregnancy is usually a correct decision — rewarding consistency here
  would be the app telling a woman who is bleeding that she broke her streak.
  (Same call already made on the TTC home: no counters, no streak.)
- **Calories, and anything scored.** Not a pregnancy measure.
- **Equipment filters.** Our sessions are mat-or-nothing.
- **A teacher's face on every card.** We have no teachers yet; inventing
  bylines would be the fake-avatar problem again.

---

## The proposed door

`pregnancy_fitness` · hue 160 · rail (`kPvDoorRailDoors`) · five tabs.

### 1 · Today — the inline tool

One practice, chosen for her month, the way Open does it.

- The month, derived from `PregnancyController`. (The `_kCurrentMonth = 7`
  hardcode lives in a screen nothing opens — see the table. It is a warning
  about the pattern, not a bug to fix.)
- The card: focus eyebrow (*grounding*, *breath*, *relief*), the session title,
  `12 min`, and one line of blurb. **Start.**
- Under it: *Something shorter* / *Something else this month* — the rest of that
  month's sessions as a short rail.
- **"How are you today?"** — three plain choices (*fine* / *tired* / *not
  today*) that REORDER, never lock: tired swaps the flow for breath work, "not
  today" replaces the card with rest and a walk. This is the personalisation
  rule (`content and ordering, never structure`), and it is the honest version
  of a rest day.
- Finch's line under Start, verbatim in spirit: *listen to your body and stop
  whenever you need to.*

### 2 · Practise — the library

Chips over rows (Withings/Equinox+), no dropdowns:
`All · Breath · Grounding · Relief · Opening · Strength` + a duration chip
(`Under 10 · 10–20 · 20+`). Rows: the session mark, title, `focus · n min`.
27 sessions is enough that this is a real list and small enough that it needs
no search of its own — the door's search bar already covers it.

### 3 · Is it safe to…? — the eight activities, in place

`can_i_data`'s activity entries rendered as verdict rows (the door's own
`NormalRow` geometry from Symptoms, reused: a verdict pill + the short line),
each opening the existing Can I verdict page. **This is the door's
differentiator** and it costs almost nothing: walking, swimming, cycling,
running, dancing, gym, trekking, lifting — each with its per-trimester note
already written.

⚠️ **One source.** These rows read `can_i_data`; they never restate a verdict
in this door's own words. Two copies of a safety verdict is the mistake the
Symptoms door just fixed (STILL-OPEN §73.3).

### 4 · Pelvic floor

The Kegel tool, inline, plus the three reads that explain what it is for.
Breath ring for the hold (Calm/TIDE), the staged programme that already exists.

### 5 · Talk

The pinned red flag — **stop and call** signs during movement: bleeding,
tightening that keeps coming, fluid, dizziness or faintness, chest pain, calf
pain or swelling on one side. Then the consult tile.

---

## What the data needs

`YogaSession` gains, without breaking the 27:

```dart
final List<PoseStep> steps;   // name · seconds · one cue · one modification
final String? avoid;          // "Not after week 16 — no lying flat on the back"
final List<String> props;     // "a wall", "a cushion" — never equipment SKUs
```

`PoseStep` is what makes a player possible with no video: a name, a duration, a
cue, and the pregnancy modification. Thirty-odd steps written once cover most
sessions, because the same poses recur.

**Owed content, to be listed before building** (the `docs/DOOR-CONTENT-OWED.md`
rule): step lists for 27 sessions; the `avoid` line per session; photography or
drawn marks per pose; three pelvic-floor reads. Sessions are bilingual today,
so **new steps are English** (`english-only-new-work`) and the existing Hindi
stays untouched.

---

## Open questions for the user

1. **Video, or a no-video player?** Recommendation: **no video.** The current
   screen plays into a placeholder, MyFitnessPal/Centr prove a list-plus-timer
   player reads as guided, and shooting 27 prenatal sessions is a production
   project, not a sprint. Video can be added to the same player later.
2. **Pose art:** drawn marks in the TTC/Symptoms hand (consistent, free) or
   photographs (needs a shoot or licensed stock — prenatal yoga stock is mostly
   white-studio and off-brand for an India-first app)?
3. **Does "how are you today?" belong here at all,** or is that the Symptoms
   check-in doing double duty? It could read the Symptoms log instead of asking
   — *derive, never ask* would say: if she logged "tired" today, lead with
   breath work and do not ask again.
