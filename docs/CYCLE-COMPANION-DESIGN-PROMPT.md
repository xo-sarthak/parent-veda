# Cycle Companion — design brief

For the Claude Design project. Paste from **The prompt** down; everything above
it is context for you, not for the designer.

---

## What this screen is

> *"Cycle Companion. Not called Cycle Tracker. Purpose: understand patterns.
> Not predict perfection."* — TTC master spec §3.4

That sentence is the whole product and it is already in the code header. A
tracker collects; a companion gives back. Every decision below resolves that
way when it is close.

## Where it lives, and why that constrains the design

`TtcCycleScreen`, surface id `ttc_cycle`, in `lib/screens/ttc/ttc_cycle_screens.dart`
(1,009 lines, shared with the Ovulation and Fertility Window screens).

**It is opened from twelve places** — the TTC V3 home (4), the fertility-help
screen, the PCOS door's Track group, a hub, two journey steps, and two brackets.
So this is a **new front on an existing screen**, not a new screen: whatever is
designed has to be the thing all twelve of those already open. Nothing is
renamed, nothing moves.

---

## What is on it TODAY, honestly

Four things, in this order, on a plain scroll:

1. **A hero** — cycle day, or an empty state inviting her to log a period.
2. **"Your rhythm"** — a card with average length and range as two numbers.
   Degrades correctly: one cycle says "your first full cycle" rather than
   calling it an average; a single observation shows no range; an irregular
   history gets a plain brown note rather than a red flag; and an
   *untrustworthy* history (a 54-day gap that was really an unlogged month)
   refuses to show numbers at all and says so in the same words the home does.
3. **"Cycle history"** — a reverse-chronological list of logged period start
   dates, each with its length and a "not counted" chip where the gap was
   implausible, plus a **×** to delete.
4. **The disclaimer.**

**There is no picture of a cycle anywhere on it.** It is two numbers and a list.

---

## What the app already knows and this screen never shows

This is the important half of the brief. None of the below needs new plumbing —
it is all sitting in stores this screen can already reach.

| Already stored | Currently shown here |
|---|---|
| Symptoms logged per day (`TtcLogStore`) | ✗ never |
| Morning temperature, weight | ✗ never |
| LH-positive day, temperature-shift day (`CycleStore`) | ✗ never — they only appear on the Ovulation screen |
| The four cycle stretches with real dates (`ttcCyclePhaseSpans`) | ✗ never |
| The projected fertile window (`ttcFertileWindowNow`) | ✗ never — a separate screen |
| The month's findings (`ttcBuildCycleReport`) | ✗ **not even linked** |

That last one is the sharpest. The cycle report is the payoff for logging, and
from here there is no way to reach it — it is only on the home's daily rail and
at the foot of the symptom logger. Someone who came to the Companion to
understand her pattern is standing next to the answer and cannot see it.

---

## The gaps worth designing for

**1. No picture.** Two numbers and a list is a spreadsheet. The stretches exist
now (period / before your window / fertile days / the waiting days, with real
dates and lengths) and nothing draws them here.

**2. Period END is not captured at all.** `CycleStore` stores start dates and
nothing else — no end date, no bleed length, no flow. Consequences:

* "How long is my period?" is unanswerable, and it is one of the first things
  anyone asks a cycle app.
* The cycle report **assumes five bleeding days** (`kTtcAssumedBleedDays`) to
  draw its first band. That is a working assumption standing in for data.
* PCOS specifically cares about bleed length, and the PCOS door links here.

⚠️ **This is a data decision, not only a design one.** Adding it changes what
logging asks for. Decide before designing: does she log an end date, a number of
days, or tap days on a calendar?

**3. Deleting a cycle is one unguarded tap.** The **×** calls
`removePeriodStart` immediately — no confirm, no undo — on the store that drives
the chapter engine, the fertile window, the report and the home. A mis-tap
silently changes what the whole stage says.

**4. No way to correct a date.** Only delete and re-add.

**5. Nothing says when the next period is expected**, though the engine knows.

---

## Rules that do not relax

Carry these into the design; they are enforced by tests that scan source text.

* **Never a personalised probability.** No "your chance this month", no score,
  no percentage, no match label. Population statistics are allowed only where
  they reduce pressure rather than set a target.
* **Never a diagnosis.** "Irregular cycles are common and are not a failing" is
  the register. Symptoms have many causes; every clinical path ends at a doctor.
* **A timing estimate is allowed; a probability is not.** Dates and lengths,
  yes. Odds, never.
* **Refusals are structural and must be designed, not hidden.** When a clinic
  owns the cycle, or the history cannot carry an estimate, the screen shows
  *no* phases and says why in plain words. It must not look like an error or a
  gap — it is a deliberate deferral, and it is the state a real user hits often.
* **Do not contradict her clinician.** Where a doctor owns a decision we
  explain, remind or help her prepare — never recreate.

---

## The house style, so the design is implementable as drawn

* **Fraunces** for headings, **Manrope** for everything else.
* **Hue 288** is this area's colour. Tinted blocks come from one function at a
  fixed pale saturation; the four cycle stretches have their own stronger
  palette already built (`ttc_phase_colours.dart`).
* **One button treatment on this stage: white, a hairline, ink label.** No
  filled purple bars. The accent is spent at decision points, never as a
  surface.
* **Hairlines, not shadows,** on anything inside a sheet.
* **Drawn marks, not stock icons,** for anything decorative.
* **No decorative emoji.**
* **Design at 360pt.** Every overflow this stage has shipped was found at phone
  width or not at all.
* A number scales down; a label ellipsises.

---

# The prompt

*(paste this into the design project)*

---

Design the **Cycle Companion** screen for ParentVeda's Trying-to-Conceive stage.

**What it is:** a calm screen that helps someone *understand her own cycle
pattern*. It is explicitly not a predictor and not a scoreboard. Its own spec
line is "understand patterns, not predict perfection." Most people who open it
are trying to conceive, some suspect PCOS, and many are anxious. The tone is
steady and never urgent.

**Audience:** Indian women, mostly reading English as a second or third
language. One idea per sentence, the common word over the precise-sounding one.

**Design these, at 390pt phone width:**

**1 · The screen with a healthy history** — the main case.
Include, in whatever order you think reads best:

* Where she is right now in the cycle.
* **A picture of the whole cycle.** Four stretches, with real dates and lengths:
  Period · Before your window · Fertile days · The waiting days. A ring, a
  calendar row, a bar — your call, but the picture is the point of the redesign.
* Her rhythm: usual length, and the spread across recent cycles.
* When the next period is expected.
* Her logged history, with a way to correct a wrong date and a way to remove one
  **that cannot happen by accident.**
* A way through to the fuller month-by-month report.
* One way to log a new period, always reachable.

**2 · Logging a period, including its end.** Today only the start date is
captured. Design how she records that it has finished — an end date, a number of
days, or days tapped on a calendar. Show the shape you would build.

**3 · The empty state.** Nothing logged at all. This is what most people see
first, so it is a real screen and not a shrug. It should make the first log feel
worth doing.

**4 · The refusal state.** Either a clinic is running her cycle, or her history
is too broken to estimate from (for example one 54-day gap that was really an
unlogged month). **We may not draw phases at all here.** Her logged data still
shows; the estimate does not. This must read as a deliberate, calm deferral —
not as an error, not as a warning, not as something missing.

**5 · One cycle in detail**, if you think it earns a screen — what a single past
cycle looked like, with the symptoms and any temperature or weight readings
logged during it.

**Hard rules — the design is rejected if it breaks one:**

* No score, no percentage, no "chance this month", no match or verdict label.
* No diagnosis and no red alarm states. Irregular cycles are common and are not
  a failing.
* Nothing may contradict a doctor.
* Every clinical path ends at a real doctor.
* Numbers are dates and day-counts only — never odds.

**Style:** Fraunces for headings, Manrope for body. Calm, generous spacing,
white cards with hairlines rather than shadows. Buttons are white with a
hairline and an ink label — no filled coloured bars. Line icons or drawn marks,
never emoji. The area's accent is a violet-magenta at hue 288, used sparingly;
the four cycle stretches carry their own colour coding and should be
distinguishable at a glance in a small diagram.

---

## When the designs come back

Implementation order, so nothing ships half-wired:

1. **The period-end decision first**, because it changes `CycleStore`, the
   logging flow, and lets the report stop assuming five days.
2. The screen itself, as a new front on `TtcCycleScreen` — surface id and all
   twelve callers unchanged.
3. The guarded delete and the date correction.
4. The link through to the report.

Recorded alongside `docs/STILL-OPEN.md` §18.5, which lists Cycle Companion, the
calendar and the tests library as the three designs owed.
