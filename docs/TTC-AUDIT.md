# TTC — device audit

**Run:** 2026-07-27, on a physical device (Samsung, debug build), driving the app
over adb.
**Scope:** the whole Trying-to-Conceive stage. 17 screens walked, both Her and
Him modes.
**Excluded:** Community — it has its own revamp coming.

Nothing here was found by reading code. Every item was seen on a screen, with
the code consulted afterwards to explain it.

---

## How to use this file

* **Tiers are severity, not effort.** Tier 1 items are things that do not work
  at all; Tier 4 items are polish. Fix downward.
* **Numbers are stable.** Refer to them in commits and conversation — "fixes
  A-12" — so nothing gets half-fixed twice.
* **§5 is not optional.** It records what must survive the fixing. The writing
  in this stage is the product; several changes below are *only* about moving it.
* `docs/STILL-OPEN.md` remains the home for parked decisions. This file is for
  defects found in a built thing.

---

# 1. Tier 1 — broken

## A-1. The care-pathway system is unreachable

`TtcStore.setPath()` has **no caller anywhere in the app** — only tests.
`TtcPath` appears in zero screens. `TtcTreatmentEntryCard` renders only
`if (today.clinicInvolved)`, which is only true once a path other than
`natural` is set. **The card that leads to the pathway questions can only
appear after answering a question that cannot be reached.**

Every user is permanently `natural`. Dead in a shipped build:

* `TimingOwnership` and all seven `TtcPathwayBehaviour` flags
* both pathway questions
* the entire Treatment Cycle screen — stim start, trigger, retrieval, transfer,
  beta
* the two trigger reminders and the "Taken" tick
* the beta countdown that replaces the period countdown
* the clinic-led card and `clinicGuidingTiming`

A woman on IVF therefore still gets a fertile window, an ovulation estimate and
a countdown to a period her progesterone is delaying — **the original defect the
whole care-pathway design was built to fix.**

This is exactly the failure the **wiring gate** in `CLAUDE.md` exists to
prevent: *"Test counts are not evidence that a feature is reachable."* Forty-seven
tests pass on a subsystem nobody can switch on.

**Needs:** a real entry point where she declares her path. Probably on Today
(near the rhythm card) and in Prepare, not buried in Tools.

## A-2. Hinglish is unreachable for anyone who signs up as TTC

Every TTC screen listens to `TtcLang`. The only thing that ever **sets** it is
`lib/screens/home_screen_b.dart:282` — the door on the pregnancy home:

```dart
TtcLang.instance.hinglish = pregnancy.language.isHinglish;
openTtc(context);
```

Land in TTC from the splash and that line never runs. `TtcLang` stays English
forever with no control anywhere. **Every `_p(english, hinglish)` Hinglish string
in the stage is unreachable by the users it was written for.**

## A-3. The TTC shell has no account surface

Five tabs, a logo header with no actions. No Profile, no Settings, no sign-out,
no way to correct a name or a journey start. Combined with A-4, the stage is a
sealed room.

## A-4. The door into TTC is one-way

The TTC entry lives on the pregnancy home. Once `pv_life_stage = trying`, the
splash makes `ttc/today` the root and nothing routes back — one system-back
press exits the app to the launcher.

**For a real user this is correct**: she is not pregnant, and her way out is the
positive-test transition. **For testing it is a hard block**, and a claim in
`STILL-OPEN.md` that "testing is unaffected" was wrong.

## A-5. Him mode has no bottom navigation

Scrolled to the end: the page simply stops. No Today / Prepare / Tools /
Calendar / Community. His only exit is toggling back to Her.

## A-6. The Ask Veda FAB collides with content on every scrollable screen

Pinned mid-right at roughly 73% of viewport height, over scrolling content, with
no offset. **Sixteen screens affected.** It is not a polish issue — it blocks
real tap targets:

| Screen | What it blocks |
|---|---|
| Cycle Companion | the **×** delete on a row — that entry cannot be removed without scrolling |
| Him mode | the **"How today felt"** journal shortcut — one of four, permanently |
| Community | a room's **Join** button |
| Prepare | the **₹599** price on a consultation card |
| Prepare (deep) | the description on the ₹199 partner workshop |
| Appointments | the footnote about what we do *not* pull from your clinic |

Plus text on Today, Tools, Journey Map, Can I…?, Symptom, Weight, Medical Tests,
Nutrition, Supplements, Product Guide.

## A-7. Content scrolls under the bottom nav

No bottom padding on any tab root. The last row is always clipped.

## A-8. The "Her | Him" toggle floats over card text

Fixed position, no backdrop, content passes underneath it at every scroll
position.

---

# 2. Tier 2 — the data chain

One bad derived value reaches five screens.

## A-9. A logging gap becomes a 54-day "cycle"

Test data logged eleven period starts. Gaps: **7, 14, 54, 4, 2, 1, 5, 3, 6, 3**.

`cycle_store.dart:66` keeps only clinically plausible cycles
(`len >= 15 && len <= 90`). Exactly one survives — **54** — and it is not a cycle
at all, but the eight-week hole between 8 May and 1 July where nothing was
logged.

Everything downstream is then arithmetically correct and humanly absurd:

* "Ovulation around day 40" (54 − 14)
* "Low · Chance of conceiving"
* "Next period expected in 51 days"
* a 54-row fertility list

**The guard protects the average. It does not protect the conclusion.**

## A-10. We know the number is unreliable and print it anyway

`hasUnreliableHistory` fires correctly (54 > 45) and drops confidence to `low`.
The estimate is then displayed regardless. Lowering confidence and stating the
figure anyway is the failure the truth hierarchy exists to prevent, one layer
below where it was applied.

## A-11. Cycle Companion contradicts itself on one screen

Stats read **"Average 54 days · Range 54–54 days"**. The list directly beneath
shows gaps of 3, 6, 3, 5, 1, 2, 4, 54, 14, 7. Stats use the filtered set; the
list shows raw gaps. A user can count and see we are wrong.

## A-12. Ten of eleven entries silently do nothing

No warning at input when a start is implausibly close to the last one, and no
"not counted" marker on the discarded rows. **This is why testing felt like
"having to do a lot"** — the app never acknowledged what had already been done.

## A-13. ~~The Weight tracker uses a −/+ stepper~~ — **WRONG, withdrawn**

I claimed you would tap **+** fifty-five times from zero. Both halves were
false, and I should have read the code before writing it down:

* **"Tap to add" opens a numeric keypad.** `_typeIn()` in
  `ttc_tracker_screen.dart` — a text field with a decimal keyboard and the
  unit as a suffix.
* **The stepper never starts at zero.** `_sensibleStart()` begins weight at 60
  kg, sleep at 7 hours, movement at 30 minutes — with the stated reason that
  *"add" should not mean "record that you slept 0.5 hours"*.

The real finding, much smaller: **"Tap to add" does not look like a text field**,
so the keypad is discoverable only by trying. A unit hint or a caret would fix
it. Recorded here rather than deleted, because a withdrawn finding is worth as
much as a confirmed one.

---

# 3. Tier 3 — the architecture of attention

**This is the deepest problem and it is not a bug anywhere.** Every explanation
the persona needs already exists, written well. Almost none of it is on the
screen she opens.

## A-14. The answers are one or two taps from where she looks

| What she asks | Where the answer already lives |
|---|---|
| *"Why does nothing change?"* | Chapter → What's next: *"it needs nothing from you except logging the first day of your period when it arrives"* |
| *"Isn't this going backwards?"* | Journey Map: *"Chapters two to four come round again with each cycle — that is the shape of this, not a step backwards"* |
| *"What does 'chance of conceiving' mean?"* | Fertility Window: *"The width is the point — no single day has to be right"* |
| *"Is this symptom pregnancy?"* | Symptom Companion: *"early pregnancy and an approaching period feel identical, because they are the same hormone"* |
| *"Why bother logging?"* | Ovulation Companion: *"A recorded signal from your own body always beats our calendar estimate"* |

None of those sentences is on Today.

## A-15. The hero's Me / Us / What's next buttons hide the teaching

Behind them sit the ninety-day egg-and-sperm explanation, the folic-acid
neural-tube reasoning, and the answer to "why does nothing change". They read as
decorative quick-actions.

## A-16. The rhythm card is a dead end

`_RhythmCard` is a plain `StatelessWidget`. The one card that raises the question
routes nowhere, while three screens that answer it sit in Tools.

## A-17. The chapter never says when it ends

"Preparing Together" holds for `preparingChapterDays = 28` with a 0% bar.
Telling her the next chapter begins with her next period would answer the
stagnation directly — and that sentence is already written, in What's next.

## A-18. Today has no disclaimer

Every tool carries *"These are estimates, never guarantees…"*. The screen with
the highest traffic and the least reliable number carries none.

## A-19. The Journal empty state offers no prompt

`ttcJournalPrompts` holds 16 seeded prompts; none surface. For someone anxious or
low, a blank page is the hardest possible ask — and the answer is already in
data.

## A-20. Empty states waste 40–60% of the viewport

Journal, Health Records, Appointments, Ovulation Companion: a small card at the
top and a void beneath.

---

# 4. Tier 4 — screen-level

## Fertility Window

* **A-21.** 54 rows, of which 7 carry information. Days 1–34 are identical
  "Low". For an anxious reader that is a scrollable list of failure. Even a
  normal 28-day cycle gives 22 rows of "Low" to find 6 that matter.
* **A-22.** Medium bars are visually identical to Low — the fill is
  imperceptible until "High", so the bar carries no information across
  two-thirds of its range.
* **A-23.** No summary. *"Your fertile days are the 35th to the 41st"* is never
  stated; she must scroll and hunt.
* **A-24.** It is a spreadsheet where pregnancy has a journey map — the least
  uniform screen in the stage.

## Calendar

* **A-25.** Fertile-day tints are a hair off white — the most important days of
  the month are the least visible thing on screen.
* **A-26.** The "Estimated ovulation" legend swatch is **dark brown** against an
  all-pink/purple palette. Reads as a rendering error.
* **A-27.** The legend has no entry for **Today**, which is the boldest circle
  drawn. Purple is listed as "you logged something".
* **A-28.** The legend is collapsed by default — a first-time user sees eight
  coloured circles and no key.
* **A-29.** The fertile window splits across a month boundary with no signal.
  Viewing August you see four faint circles trailing off the edge and no
  indication the peak is in September.
* **A-30.** "Your command centre" is cold, and out of key with every other
  headline in the stage.

## Ovulation Companion

* **A-31.** *"Mark as done"* is the wrong verb on both signals. It reads as a
  checklist item; it means *"I got a positive result today."*
* **A-32.** No day picker. Remember two days later and the correct day cannot be
  recorded.
* **A-33.** Nothing explains that a **temperature rise confirms ovulation after
  it has happened** rather than predicting it — nor how to take a BBT (on
  waking, before standing, same time, basal thermometer). Without that the
  reading is noise.
* **A-34.** It is the emptiest page in the stage — two buttons and white space —
  and it is the tool that should teach the most.

## Symptom Companion

* **A-35.** Chip rows wrap **4 + 1** — "None / A little / Some / A lot" fills the
  row and "Severe" drops alone, for every symptom. Eight orphaned chips and
  roughly 2,800px of scroll to log one day.
* **A-36.** Selecting **"Severe" cramping does nothing**, while Ask Veda's
  guardrails treat "severe pain" as a red flag and route to a doctor. Two parts
  of the product disagree about what severe pain means.

## Can I…?

* **A-37.** The smoking card contradicts itself. Title: *"Does smoking really
  matter?"* Verdict chip: *"Better not."* Answer: *"Yes."* The verdict answers a
  different question than the title asks — and *"Better not"* is far too soft for
  the one item the card itself calls *"genuinely clear evidence."* Should be
  **Avoid**, and it should agree with What's next, which says *"cut smoking to
  zero — passive counts too."*
* **A-38.** *"one of the two things"* — the other is never named without
  expanding.

## Medical Tests

* **A-39.** Nothing says **when in the cycle** to take each test. FSH/LH being
  early-follicular is the single most important fact and it is collapsed behind
  "Read more".
* **A-40.** No prioritisation. Ten tests, no "start with these" — so an anxious
  person does all of them (₹10,000+) or none.
* **A-41.** AMH reads as *"how many eggs remain"*, which invites *"I am running
  out."* The reviewer's correction — AMH predicts ovarian **response**, not egg
  quality — is not surfaced at card level.

## Supplements / Medication

* **A-42.** **You cannot record an actual medication.** The screen is a curated
  supplement list with **+** buttons — no name, dose or schedule. Given the whole
  care-pathway design assumes medicated cycles, the "Medication" tile leads
  somewhere that cannot do the job.
* **A-43.** No doses on this screen — the one place you would act on them.
* **A-44.** Folic acid appears in **three** places at three levels of detail:
  Product Guide (400mcg + the prenatal-bundle warning), What's next (400mcg),
  Supplements (neither).

## Tools hub

* **A-45.** Four tiles, two destinations — *Medication* → Supplements,
  *Reports* → Health Records filtered. Deliberate in code, unexplained in UI, so
  it reads as broken routing. If it is one thing it should be one tile.
* **A-46.** No descriptions on any tile. Nothing distinguishes Mood from Stress
  from Lifestyle — and the whitespace for a one-line description is already
  there.
* **A-47.** *Journal* and *Product Guide* are each orphaned alone on the last row
  of a two-column group.
* **A-48.** The tile says **"Product Guide"**; the screen says **"Worth knowing
  about"**. Nobody looking for one will recognise the other.

## Health Records

* **A-49.** No visible attachment affordance. Fertility results are PDFs and
  printouts; a text-only folder cannot hold what people actually have.

## The Insight reader

* **A-50.** It is a plain page — no progress, no font control, no theme, no
  read-next, no save. The parenting stage has a full reader with all of it. The
  clearest uniformity gap in the stage.
* **A-51 — fixed.** *"45 sec read"* was a flat default every insight inherited,
  so a sixty-word piece and a three-hundred-word one claimed the same length.
  Now counted from the words actually written, floored at fifteen seconds.

> **A-50 / A-68 status: half done, and the other half is a commission.**
>
> `TtcInsight` carries title, body and takeaway — there is **no field** for
> pregnancy's *"A little deeper"* layer. Adding one means authoring
> **twenty-four new explainers about fertility**: content commissioning, not a
> UI change, and not something to invent unreviewed. Left open deliberately.
>
> What pregnancy's **REMEMBER** panel does, *"Today's takeaway"* already did
> here — that half was satisfied before the audit started.
>
> Still open from A-50: read-next, save, font control, themes.

## Ask Veda in TTC

* **A-52.** The three-way routing fix **works** — TTC-specific questions, correct
  framing. Verified live.
* **A-53.** Only three suggested questions, all "preparation" flavoured. Nothing
  emotional (*"is it normal to feel this way?"*, *"how long is too long?"*),
  nothing for him, nothing for PCOS or irregular cycles. For an anxious user the
  suggestions define what feels askable, and nothing hard is on the list.
* **A-54.** Its header breaks the TTC pattern — a bare back arrow instead of the
  circular chip every other screen uses.

## Him mode

* **A-55.** His "Today's Learn" is two lines where hers is a full insight with a
  takeaway box. The asymmetry is backwards — he is the one who knows less.
* **A-56.** **No biology at all for him.** He is told how to support her,
  beautifully, but nothing explains what a cycle is, what ovulation means, or
  what she is physically experiencing. Men are the audience with least prior
  knowledge here and they get the least explanation.

## Copy and grammar

* **A-57.** "1 days" — Cycle Companion list.
* **A-58.** Care Circle description truncates mid-word: *"every recommendation
  you see c…"*.
* **A-59.** Nutrition chips wrap **4 + 2 + 1** across three ragged rows.
* **A-60.** Nutrition mixes relative and absolute day naming — "Today" then
  "Tuesday".

---

# 5. What must not change

The writing is the product. Several fixes above are *only* about moving it.

> *"A number on a screen telling you that you are wrong has never helped anyone."*
> — Weight
>
> *"There is no timetable for this and nobody will give you one."*
> — Prepare, After a loss
>
> *"Chapters two to four come round again with each cycle — that is the shape of
> this, not a step backwards."* — Journey Map
>
> *"early pregnancy and an approaching period feel identical, because they are the
> same hormone."* — Symptom Companion
>
> *"Make the first appointment yourself. Book both your tests at the same time,
> not hers first. That one act sets the tone for the next year."* — Him
>
> *"rather than her being investigated first while his half waits."*
> — Prepare, Couple assessment
>
> *"Write questions down when they occur to you, not in the waiting room.
> Walking in with the ones you thought of at 2am is most of what makes a short
> consultation useful."* — Appointments
>
> *"Expensive 'prenatal' combinations often bundle things you may not need and
> cost several times more than plain folic acid."* — Product Guide
>
> *"Small changes held for three months beat heroic changes held for three days."*
> — Chapter
>
> *"Log whenever you feel like it. There is no streak to keep and no gap that
> counts against you."* — Weight
>
> *"just relax is not a treatment."* — Prepare

Also worth protecting: the ₹199 partner workshop being the cheapest item in the
catalogue, aimed at the person least likely to turn up; rupee pricing
everywhere; and the Him palette being recognisably the same app rather than a
different one.

---

# 6. Uniformity with pregnancy

Walked 2026-07-27 on the same device. Pregnancy is the reference: where the two
differ, TTC should move.

## First — four of my findings are NOT TTC bugs

They reproduce identically on the pregnancy side, so they are **app-wide** and
fixing them fixes all three stages:

| Finding | Status |
|---|---|
| **A-6** Ask Veda FAB overlapping content | Same position, same collisions on pregnancy |
| **A-8** floating Her/Him pill over cards | Pregnancy's Mom/Dad pill does exactly the same |
| **A-7** content under the bottom nav | Same |
| **A-59** ragged chip wrapping | Pregnancy's Tools chips wrap 3 + 2 + 2 |

## A-61. TTC has no Profile; pregnancy has a complete one

Pregnancy Today's header carries **bookmark · search · avatar**, and the avatar
opens a full Profile: name and week, **partner pairing code with Share/Copy**,
My Journal, Bump Journey, Dear Baby, Saved, Personalization analytics,
**Language (Hinglish | English)**, Invite a friend, Memories, WhatsApp updates,
**"Reset to Week 20 · testing"**, **"Enter doctor mode · testing"**, and
**Sign out**.

TTC's header is a logo with no actions, on every tab.

**This is the fix for A-2, A-3 and A-4 in one place**, and the pattern already
exists — including the precedent for a labelled testing affordance, used twice.

## A-62. TTC has no partner pairing at all

Pregnancy issues a real pairing code so a partner's device joins the journey.
TTC's "Him" is a **view toggle on the same phone** — there is no way for an
actual partner to pair in.

Meanwhile the backend is fully couple-scoped: `my_partner_id()`, RLS on shared
tables, and the deliberate rule that his door never receives `cycle_day`. All
built, tested, and unreachable — **the same shape of failure as A-1.**

## A-63. Pregnancy Tools does three things TTC's does not

* a **hero card** — "Your Pregnancy Journey · See your whole journey, week by
  week". TTC's equivalent (Journey Map) is a small tile in "Plan and learn",
  despite holding the best sentence in the stage.
* a **personalisation strip** — "What would you most like help with?" with seven
  chips and *"The tools you pick move to the top of this page"*, plus "Not now".
  TTC's grid is static.
* **tiles that say what they do** — each icon sits in a per-tool coloured chip
  (gold, purple, pink) with an explicit **"Open →"**. TTC's are flat, uniformly
  purple, and offer no affordance.

That last point is the answer to **A-46**: pregnancy already solved "a tile needs
more than a label."

## A-64. Pregnancy's calendar is far richer, and solves two TTC problems

* **Three views** — Timeline | Calendar | Upcoming. TTC has one.
* **Row markers** — "38w", "39w", "40w", "Birth" in amber beside the weeks. TTC
  could mark "Day 1", "Fertile", "Ovulation" the same way.
* **Spanning range capsules** for multi-day periods (the birth window runs as one
  soft pill across 21–25 and 26–31). **This is exactly what the fertile window
  needs** — it fixes A-25 (invisible tints) and A-29 (split across months) at a
  stroke.
* **Two distinct day states** — today filled, selected outlined. TTC has one.
* **Small dots** under days for logged events, so the day number stays readable.
  TTC fills the whole circle solid red, which is why eight logged days looked
  alarming.
* A **+ button in the header** to add. TTC has none.

## A-65. The two stages start the week on different days

Pregnancy: **S M T W T F S**. TTC: **M T W T F S S**. Same app, two
conventions.

## A-66. Header treatment is inconsistent within pregnancy too

Today shows the logo; Tools shows a bare "Tools" title with no logo; Calendar
shows "My Calendar" with actions. TTC uses the logo on all five tabs. Whatever
rule is chosen, all three stages should follow it.

## A-67. Journey: pregnancy draws a *winding* trail — **overstated, softened**

I wrote that TTC's Journey Map is "five stacked cards with a thin connector",
implying a flat list. Re-reading the code: it is already a **trail** — numbered
nodes, a connecting rail, a "You are here" pill, and a "Comes round each cycle"
marker on the three chapters that repeat.

The real gap is decoration, not comprehension: pregnancy's path winds, uses
coloured milestone nodes and a progress ring. Converting TTC's would be a
custom-painter rewrite of a screen that already communicates well and holds the
best copy in the stage, for a modest gain and real regression risk.

**What was actually missing is A-40** — no chapter said what brings it. That is
now fixed using the same `nextUp()` copy the hero uses, so the two cannot drift.

The winding-path treatment stays available as a later polish pass, deliberately
unbooked.

## A-67b. The original text, kept

Pregnancy's "Your Pregnancy Journey" is a **winding dotted trail** — a progress
ring, milestone nodes as coloured circles (teal star, gold trophy), labelled
chips beside each (*"Full Term · 6 Jul"*), a large filled node for the current
position with a **"You're here"** pill, and a destination node at the end. Plus a
dismissible **"Joined along the way? Catch up →"** nudge for back-filling dates.

TTC's Journey Map is five stacked cards with a thin connector.

**Same concept, two visual languages.** This is also the model for **A-24** —
Fertility Window's 54-row list is the same "table where a map belongs" problem.

## A-68. Reader structure differs

Pregnancy's reader has **two structured panels** after the body:

* **"A LITTLE DEEPER"** — a flask icon and an optional depth layer
* **"REMEMBER"** — an italic pull-quote

TTC's insight reader has one ("Today's takeaway") and no depth layer.

*(Correcting A-50: the premium reader — progress, TOC, font size, themes,
read-next — belongs to the **parenting** stage, not pregnancy. Pregnancy's is a
step above TTC's, not a different class. TTC should match pregnancy first.)*

## A-69. TTC invented a back button the app does not use

Pregnancy uses a **bare back arrow** with the title beside it — on the Journey,
Profile, and the reader. TTC wraps its back arrow in a **circular grey chip** on
every inner screen.

*(This also reframes **A-54**: Ask Veda's bare arrow isn't the odd one out — it
matches pregnancy. TTC's chip is the divergence.)*

## A-70. Pregnancy gives cards an explicit action; TTC relies on tapping

Today's tip card ends with a **full-width filled "Read More →" button**. TTC's
insight card has no button — the whole card is the target, with no affordance
saying so. Same for Tools tiles, which carry an explicit **"Open →"**.

## A-71. Prepare is structurally richer

| | Pregnancy | TTC |
|---|---|---|
| Eyebrow | "30 WEEKS · THIRD TRIMESTER" | "PREPARE" |
| Headline | large Fraunces serif, two lines | smaller sans |
| Sponsor | "Presented by Himalaya" strip with ⓘ | none |
| Offerings | **horizontal carousel** with image placeholders, category eyebrow, "90 min live · ₹799" | **vertical text list** |
| Browse | category rows with icon chip and a count | section headers only |

## A-72. The language control exists twice on pregnancy, differently labelled

Profile shows **"Hinglish | English"**. Prepare's header shows **"EN · हिं"**.
Two controls, two labels, one in Devanagari. TTC has neither — and whichever is
chosen should be the one TTC copies.

## A-73. Hero action buttons

Pregnancy: three **circular** icon buttons with the label beneath (Baby /
Mother / What's next), plus a **"View week ›"** link at the top of the hero.
TTC: three **rounded-square** buttons (Me / Us / What's next), no link.

## A-74. Sponsored cards look different

Pregnancy's launch card is blue-tinted with a brand avatar, "A PARENTVEDA
LAUNCH" eyebrow and "Presented by Cetaphil". TTC's "Today's Pick" is a plain
white card. Brand Studio should render identically in both.

---

## A-75. The home screen — the headline uniformity item

Pregnancy and parenting are **two independent data points that agree**, which
makes their shared shape the house standard rather than one stage's opinion. TTC
breaks it in the same three places on the screen everyone opens daily.

| | Pregnancy | Parenting | TTC |
|---|---|---|---|
| Header actions | bookmark · search · **avatar** | search · **person** · hamburger | **none** — logo only |
| Eyebrow above hero | "WEEKLY SNAPSHOT" | "HOW YOUR BABY IS TODAY" | **none** |
| Position | "Week 40, Day 7" | "PHASE 1 OF 20" | chapter name only |
| Progress | segmented **T1 / T2 / T3**, labelled | tick-marked rail, **Birth → 5 years** | flat unlabelled bar at 0% |
| Forward link | **"View week ›"** | **"Phase map ›"** | none |
| What's coming | *"Baby's almost here"* | *"Next: the peak, and the first smile, around 1 month."* | none |
| Tip card CTA | full-width **"Read More →"** | full-width **"Read more →"** | no button — tap the card |

### The three things both stages do and TTC does not

1. **State position inside a numbered, bounded structure.** "Week 40 of 40",
   "Phase 1 of 20", "Birth → 5 years". TTC says "Preparing Together" with a bar
   at zero and no denominator, so there is no sense of a journey with a shape.
2. **Name what is next, and roughly when.** Parenting's *"Next: the peak, and
   the first smile, around 1 month"* is one line and it does all the work.
3. **Link to the whole map from the hero.** "View week ›" and "Phase map ›" are
   both one tap from the top of the screen.

**This is the precise diagnosis of A-17 (stagnation).** It is not that TTC's
chapter lasts 28 days — pregnancy weeks and parenting phases last a while too.
It is that TTC never says *how far through*, *what is next*, or *where this
sits in the whole*. The other two stages answer all three above the fold.

TTC already has the words. `Chapter → What's next` says *"it needs nothing from
you except logging the first day of your period when it arrives"*, and the
Journey Map says *"chapters two to four come round again with each cycle."*
Both belong in the hero.

### Also worth noting

* **AskVeda is a nav tab in parenting**, a FAB in the other two. Three stages,
  two navigation models for the same feature.
* **Parenting has a hamburger** (the Explore drawer) — a third header pattern
  again. Whatever is chosen, all three should agree.
* Parenting's hero carries **inline data entry** — GROWTH with *Edit* and
  *Chart* actions. TTC's hero has no equivalent, though "Log a new period" is
  exactly that kind of action and currently sits in a card below.

---

## Found on the pregnancy side, outside this audit's scope

**Today says "Week 40, Day 7". Prepare says "30 WEEKS · THIRD TRIMESTER"** and
"RECOMMENDED AT 30 WEEKS". Two screens in the same stage disagreeing about her
week. Worth someone checking — it is not a TTC issue but it is a real one.

Also: the pregnancy greeting carries a decorative emoji (*"Good Evening, haha
🌸"*) and the Journey uses 💜, against the no-decorative-emoji rule in
`CLAUDE.md`.

---

## What already matches, and should stay

The five-tab floating nav pill, the section-eyebrow pattern, the accordion for a
colour legend, card radii and shadow, Fraunces for headlines with Manrope for
body, and the doorway cards between stages. TTC's shell genuinely reads as the
same app — the divergences above are depth, not identity.

---

## Execution order for the UI pass

Cheapest first, and each one lands independently.

0. **The home hero** (A-75) — do this first, not last. Position in a numbered
   structure, a "next, and roughly when" line, a forward link to the Journey
   Map, and header actions. It is the most-seen screen in the stage, it is where
   the stagnation is felt, and the copy it needs is already written two taps
   away.
1. **Back button** → bare arrow, drop the circular chip (A-69). One shared
   widget, every inner screen.
2. **Explicit affordances** → "Open →" on Tools tiles, a "Read more" button on
   the insight card (A-70, A-46).
3. **Calendar** → spanning capsules for the fertile window, row markers in the
   margin, two day-states, dots for logged days, Sunday-first (A-25, A-27, A-29,
   A-64, A-65).
4. **Profile** → the whole of A-61 in one screen: language, sign out, pairing,
   stage switch `· testing`. Closes A-2, A-3, A-4, A-62.
5. **Tools hub** → hero card promoting Journey Map, coloured icon chips, and the
   "what would you most like help with?" strip (A-63).
6. **Journey Map** → trail treatment (A-67), and reuse it for Fertility Window
   (A-24).
7. **Reader** → add "A little deeper" and "Remember" panels (A-68).
8. **Prepare** → eyebrow with chapter context, serif headline, carousel (A-71).

---

# 7. Coverage

**Walked:** Today (Her and Him), Prepare, Tools, Calendar, Community, Cycle
Companion, Ovulation Companion, Fertility Window, Symptom Companion, Weight,
Journey Map, Can I…?, Medical Tests, Nutrition Planner, the Chapter screen
(Me / What's next), Journal, Appointments, Supplements, Health Records, Product
Guide, Ask Veda.

**Covered by inference:** Movement, Sleep, Mood, Stress, Lifestyle and Partner
Health all run the same tracker engine as Weight and Symptom, so A-35, A-13 and
A-20 apply. *Reports* and *Medication* are the same screens as Health Records
and Supplements.

**Not examined:** Care Circle (inside Community, excluded); the
transition-to-pregnancy flow (writes real data); the true first-run empty state
with nothing logged (would require deleting the test data — **worth doing**, it
is what every real user meets first).
