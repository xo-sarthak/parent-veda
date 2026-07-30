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

## A-6 — half fixed (TTC only). The Ask Veda FAB collides with content on every scrollable screen

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

**The cause was arithmetic, not carelessness.** The FAB is mounted in
`MaterialApp.builder`, above every route, which makes it invisible to layout:
no screen reserves room for it and no `Scaffold` knows it is there.
`ttcBottomInset` was `108`, sized for the floating nav pill, and every *pushed*
screen — which has no pill — reasonably hardcoded `40`. Both numbers were right
about the chrome their author was thinking about. Neither knew about the FAB.

The failure is worse than it looks because it is **undiscoverable**: from where
she sits the button is not obscured, it is simply absent, and "scroll further"
is not a thing anyone tries when the list has visibly ended.

Fixed by deriving the reserve from the FAB's own geometry —
`kAskFabReserve` in `global_ask_fab.dart` — and pointing all twenty-two TTC
scroll views at it. A hand-picked `160` copied into thirty files is wrong the
first time anyone nudges the button. `test/ttc_fab_clearance_test.dart` fails if
a literal comes back.

One deliberate exception, named rather than exempted: **Ask Veda's own screen**,
where `FabRouteObserver` suppresses the FAB — it will not offer to open the
screen you are standing on — so its lists clear the pinned composer instead.

**Half, not all — verified on the device after the fix.** The reserve guarantees
that the END of a list clears the button, which is what unblocked the delete
`×`, the **Join** and the ₹599 price: those sit at the bottom of their lists and
could not be scrolled past. Confirmed working.

What it does **not** do is stop content passing *under* the FAB mid-scroll. On
the device it still sits over a Tools tile, over the "What you can do" paragraph
in Him mode, and over a cycle row. Nothing is unreachable — scrolling brings it
out — but the button is opaque and it is over prose.

Closing that half means changing the FAB itself, not the screens: hide it while
the user is scrolling and restore it when they stop, or give it a translucent
scrim. Both are one small change in `MaterialApp.builder` and both affect all
three stages at once, so it is a product call.

**Also still open, and not mine to close alone: pregnancy and parenting have the
identical collision.** Walked on the device 2026-07-29 so the decision has a
list behind it rather than a guess:

| Stage | What the FAB covers |
|---|---|
| Pregnancy | **Record Voice** in My Journal — a tap target, exactly like the delete `×` here |
| Pregnancy | the product name and part of **₹1,999** on Today's recommendation |
| Pregnancy | **the last card on the home** sits under it — end-of-list stranding |
| Parenting | the right end of the **Read more** button |
| Parenting | the **"On track"** status chip on the Nutrition row |

The two fixes are not alternatives — they close different halves.
`kAskFabReserve` clears the *end* of a list (Record Voice, the last card);
hide-on-scroll clears everything *mid-scroll* (the price, the status chip).
Neither alone is sufficient.

Adopting the reserve touches two shipped stages carrying real user data, and
hide-on-scroll changes all three at once, so both need your call rather than my
initiative. One landmine to respect if hide-on-scroll happens: the hidden state
must stay a `Positioned`. A bare zero-sized non-positioned child collapsed the
root `Stack` and blacked out the whole app once already — the comment in
`global_ask_fab.dart` records it.

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
> **A-50 closed 2026-07-29.** Read-next, save, font control and light/sepia/dark
> all shipped — see A-84 below. A-68's twenty-four explainers remain a writing
> commission, which is the half that was never an engineering problem.

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

* **A-55 — fixed.** His "Today's Learn" was two lines where hers is a full
  insight with a takeaway box. The asymmetry is backwards — he is the one who
  knows less. Both cards now render read time, the opening paragraph and the
  takeaway in a panel; his door was always there, it just looked like it had
  nothing behind it. Pinned by `test/ttc_partner_nav_test.dart`.

  Noticed while fixing it, **not** fixed: `TtcInsight.forPartner` defaults to
  `true` and nothing anywhere sets it `false`, so his `where((i) => i.forPartner)`
  filter selects all twenty-five. The flag is inert rather than broken. Left
  alone because the intent is documented on the field, but it is currently a
  config option expressing a state the product does not have.
* **A-56 — fixed.** **No biology at all for him.** He was told how to support
  her, beautifully, but nothing explained what a cycle is, what ovulation means,
  or what she is physically experiencing. Men are the audience with least prior
  knowledge here and they got the least explanation.

  Now a fifth field on `TtcPartnerBrief` — `herBody` — and a `_HerBodyCard`
  sitting **above** his own biology, because her body is what he came to
  understand. Five chapters: what a cycle actually is · why the fertile window
  is a stretch of days and not a date · what cervical fluid is doing · what
  progesterone does and why early pregnancy and an approaching period are
  genuinely indistinguishable · what a test detects and why she is "four weeks"
  on day one.

  Two rules constrain the copy and both are tested in
  `test/ttc_partner_biology_test.dart`:

  * **Chapter-level, never cycle-day level.** He holds no rows in `ttc_cycles`
    and receives only the chapter she publishes. Prose is a side channel like
    any other — "she is probably ovulating about now" would leak in text what
    the schema refuses to hand over. The card says so on its face, because a
    privacy rule nobody is told about reassures neither of them.
  * **Explains, never predicts.** No likelihood, no "she will feel", nothing
    that tells him whether she is pregnant. The waiting-days entry has to hold
    that line hardest, since its whole point is that the symptoms cannot answer
    the question.

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

**Not examined:** Care Circle (inside Community, excluded); the true first-run
empty state with nothing logged (would require deleting the test data —
**worth doing**, it is what every real user meets first).

The **transition-to-pregnancy flow** was originally in this list — skipped on the
device because it writes real data. Reading it instead found A-76, below. Worth
remembering: the one flow too consequential to walk was the one holding the worst
defect in the stage, and "too risky to test" is a reason to read it, not to leave
it.

---

# 8. Found after the device pass

## A-76 — fixed. Both doors out of TTC were dead ends

Not a UI defect. A woman who recorded a positive test could not get to the
pregnancy app, and the app already knew she was pregnant when it refused her.

* **The positive-test button showed a "coming soon" toast.** `ttcSoon(context,
  t.transitionNext)` — the single most important tap in the product. By the time
  she reached that screen the Transition Engine had *already* flipped her life
  stage, derived and written her due date, and added two timeline entries. Every
  write had landed. Only the door was missing.
* **"Go to pregnancy" in the Profile popped to the first route**, which for
  anyone booted into TTC by the splash *was* TTC. It set the stage correctly and
  never moved, so it read as a dead button.

**Why nobody built it, which is the interesting part.** `MainScaffold` needs
three long-lived controllers that live in `_ParentVedaAppState`, above every
route, and nothing in `lib/screens/ttc/` can reach them — nor should it. The
stages are deliberately code-isolated; handing TTC a `PregnancyController` is
exactly the coupling the folder layout exists to prevent. So the two halves never
met and the gap was papered over with a toast.

Fixed with `lib/services/app_shell.dart`: `main.dart` **registers** how to build
the pregnancy shell, TTC **asks** for it. Neither imports the other.

**The design choice worth keeping.** The obvious mirror is `DoctorSession` — flip
a flag, swap the whole app in `MaterialApp.builder`, keep the old shell offstage
so state survives. Right there, wrong here. A doctor bounces in and out many
times a day; a family crosses a life stage roughly once, ever. Keeping a TTC
shell alive offstage for the rest of a pregnancy costs a second widget tree, a
second Navigator, and a second source of truth for "which stage am I in" that the
Ask Veda FAB would have to reconcile — and routes inside a nested Navigator do
not reliably report their removal to the root observer, so a stale `inTtc` would
answer a pregnant woman's question with trying-to-conceive framing.

Replacing the stack instead means the old stage is genuinely gone, the observer
sees every route leave, and the FAB corrects itself for free. The cost is honest
and small: TTC's in-memory *screen* state is discarded. Her **data** is untouched
— every store is local-first and stage-agnostic, which is the whole reason the
Transition Engine has nothing to migrate.

> **How long a thing lives decides whether you preserve it or rebuild it.**
> Preserving state is not free, and "cheap to rebuild, rarely rebuilt" is the
> case where replacing wins.

Entering TTC through the door on the pregnancy Home is handled separately and
deliberately: the live shell is still at the bottom of the stack, so we pop back
to it rather than building a second one. Popping is not merely enough there, it
is better — her tab, her scroll position and three loaded controllers are all
still warm.

Pinned by `test/ttc_stage_exit_test.dart`, including that the new shell becomes
the *first* route. That last one guards a subtler bug than the dead button: if
TTC stayed underneath, a system back gesture from her new pregnancy home would
drop her into the stage she had just left, on the day she left it.

## A-77 — fixed. The cycle list printed one cycle's length beside another cycle's verdict

Found on the device, on the second pass, on a screen that had already been
audited once and "fixed" once. Cycle Companion showed:

> **8 May 2026 · 54 days** — *Not counted* — "Too close to the entry before it
> to be a separate cycle."

Fifty-four days is not too close. It is a perfectly ordinary — if long — cycle,
and comfortably inside the plausible window.

**Two sources for one fact.** `_PeriodRow` printed `length`, computed in the
list builder as `starts[i+1] - starts[i]` — the cycle that *began* on that date.
It took the "not counted" verdict from `CycleStore.gapBefore(start)`, which is
`starts[i] - starts[i-1]` — the cycle *before* it. Every row on the screen was
describing two different cycles at once. Both halves were individually true.
Together they were nonsense.

It failed in both directions, and the other one is worse:

* the **8 May** row printed 54 days (its own cycle) and was judged on 14 (the
  previous one), so a normal cycle was labelled discarded;
* the **1 July** row was a **4-day** cycle and was judged on the 54-day gap
  before it, so it displayed as **counted** — with the coral dot — while the
  average printed inches above it correctly excluded it. The list contradicting
  the statistic beside it is the exact defect the row's own code comment claims
  to have fixed. It had been fixed in the wrong direction.

The oldest entry inherited the same flaw for free: `gapBefore` returns null for
index 0, which rendered as "counted" regardless of what its cycle actually was.

**The fix is structural, not arithmetic.** One store method, `cycleFrom(start)`,
returns the length *and* the verdict together, and the row derives both from it.
Passing a length in from the list is what let them drift, so the widget no
longer accepts one.

> Two sources for one fact will disagree eventually. The bug is not that
> somebody subtracted in the wrong order — it is that the screen was in a
> position to be wrong at all.

**Copy fixed alongside it**, because the string was wrong twice over. It named
the wrong neighbour — a cycle shown on a row runs *forward*, so shortness is
about the **next** entry, not the previous one — and one string served both
exclusion reasons, so a 120-day gap was explained to her as "too close
together". A gap that long is almost always a period nobody logged, and telling
her otherwise is the app visibly not reading her own data. Two strings now,
chosen by direction.

Pinned by `test/ttc_data_chain_test.dart`, including a cross-check that the set
of rows marked counted is exactly `cycleLengths` — the one place the list and
the stats card meet.

**Worth noting for the next audit:** this screen was walked on the device in the
first pass and the row was read as correct, because 54 days *looks* plausible
next to a date. It only broke once the reasons were read against the numbers.
Neither reading the code nor the 1,610 tests caught it.

## A-78 — fixed. Cycle Companion printed statistics from a history Today refuses to trust

Same screen, one scroll up from A-77, and the same class of fault: two parts of
the app looking at one dataset and reaching opposite conclusions.

**Today** examined her history, decided a recorded gap was long enough to be a
cycle nobody logged, and said so — "Something in your dates looks off" — and
refused to print an ovulation estimate.

**Cycle Companion**, one tap away, printed from that same gap:

> **AVERAGE LENGTH** 54 days  ·  **RANGE** 54–54 days

in the largest type on the screen, with no caveat.

The confident one was the wrong one, which is the dangerous way round. Silence
would have been safer than a number, and a woman planning around a 54-day
average because the app told her so in bold is worse off than one told nothing.

Two faults, fixed together:

* **The statistics are now behind the same gate Today uses** —
  `engine.hasUnreliableHistory` — and when it closes, the card shows *Today's
  own strings* rather than inventing a second explanation. Sharing the copy is
  the point: it is what stops the two screens drifting back into disagreement.
* **One cycle is not an average, and never a range.** "Range 54–54 days" is a
  single observation wearing a spread's clothes. With one completed cycle the
  card now says **"Your first full cycle"** and shows no range at all.

> If the engine will not estimate from a history, no screen may present
> statistics derived from it. A refusal that one screen honours and another
> ignores is not a refusal.

Pinned by `test/ttc_rhythm_honesty_test.dart`.

## A-79 — fixed. The hero parity work was done on her side only

A-75 rebuilt her hero to answer three questions above the fold — where am I,
what is next, show me it all. His still read: a title, a tagline, and one flat
progress bar that could have been at any point of anything. The stage had a
first-class half and a second-class one.

His hero now carries the segmented chapter bar, the same `nextUp()` copy hers
uses — so the journey cannot be described differently to the two people on it —
and the Journey Map door. Structure is never personalised, so he reaches the map
too.

**One thing is deliberately missing and must stay missing.** Hers reads "Day 2
of 28 in this chapter". His does not. That number is her position in her own
cycle, and he receives only the chapter she publishes — his device holds no rows
in `ttc_cycles`. Copying the line across "for parity" would route around the
own-row rule in prose, which is precisely the leak the partner Ask Veda door is
careful to avoid. The segmented bar is chapter-level, and therefore safe.

Both the presence and the absence are pinned in
`test/ttc_partner_biology_test.dart`.

## A-80 — fixed. Four of his five nav tabs were tinted her purple

`ttcMuted` is `0xFFA99CBB` — a lavender grey. The active nav pill had been given
a slate variant for him; the four inactive tabs were left on `ttcMuted`, which
reads as neutral against her near-white background (`0xFFFBF9FE`) and
unmistakably as **her purple** against his warm cream one (`0xFFF4EFE8`). On
every screen of his half.

> A muted tone is never neutral in the abstract. It is neutral against the
> background it was chosen for.

Now `ttcSlateSoft` when slate. Pinned in `test/ttc_partner_nav_test.dart`.

## A-8 — still open, and it now lands on new content

The floating **Her | Him** pill sits in `TtcPage`'s overlay slot at `bottom: 96`
and covers whatever card is behind it. In Him mode it currently sits across the
title of the new biology card — *"What's happening in her bod…"* — which is the
one card on his screen written to be read.

It is the same shape of problem as A-6: a floating element that is in no
screen's layout. Two differences make it easier to settle:

* it is a **testing affordance**, not a feature. Real pairing (A-62) replaces
  it, and the pill disappears with it.
* it is TTC-only, so fixing it touches nothing shipped.

Cheapest honest fix until pairing exists: move it into the header row beside the
profile door, where it is chrome rather than an overlay. Left alone for now
because it is deliberately temporary — noted so that stays a decision rather
than an oversight.

## A-81 — fixed. The calendar legend advertised two colours the grid never drew

Third instance of the same family in one sitting, and the one that shows the
pattern clearly.

The legend already had the right principle written on it — *"A legend must
describe THIS calendar, not every calendar"* — and correctly hid **Fertile
days** and **Estimated ovulation** on a clinic path, where those markers are
deliberately suppressed.

But a marker can be absent for **two** reasons, and it knew one. When the engine
refuses to estimate from an unreliable history, the pathway is still `natural`,
so `showsFertilityWindow` stays true and the key kept promising a shading the
grid had not drawn — on the one screen she would go looking for it.

> Suppressing a marker and advertising it were decided in different places.
> That is how they came apart, and it is the same shape as A-77 (a length and a
> verdict from two sources) and A-78 (an estimate refused on one screen and
> printed on another).

The legend now asks the engine directly. Pinned in
`test/ttc_rhythm_honesty_test.dart`, including a guard that the engine really
does refuse on this history — otherwise the gate would be dead code and the test
would pass vacuously.

---

## What this second pass says about the first one

Four defects (A-77 to A-81) on screens that had already been walked once, and
three of them are the same fault wearing different clothes: **one fact computed
in two places, and the two disagreeing.**

* a cycle's length and whether it counted — two sources
* an estimate refused by the engine, printed by a screen
* a marker suppressed by the grid, advertised by the legend

None was catchable by reading code, because each half is correct on its own. None
was catchable by the 1,623 tests, because each half was tested on its own. They
were only visible with both halves on screen at the same time, which is what a
device pass is *for*.

The first pass missed them because it read each screen for what it said, not for
whether its parts agreed with each other. The check that would have caught all
three: **for every number on screen, find the other place that number is
derived, and ask whether they can ever differ.**

---

# 9. The UI-phase batch

Decided together: build the interface, add no backend. Every item here works
with the database switched off.

## A-41 — fixed. AMH read as a countdown of what is left

The card-level line was *"A rough estimate of how many eggs remain — the size of
the reserve."* That is the first thing an anxious person reads, and it invites
*"I am running out."*

The correction already existed, two fields below in the same entry: `whyEn` says
*"a planning number for a specialist, not a fertility score"*, `readingEn` says
it *"says almost nothing about egg QUALITY"*. Nothing new is claimed — the
vetted wording was moved to where the fear starts:

> *"How your ovaries are likely to respond to IVF stimulation — a planning
> number, not a count of what is left."*

The test that guarded this asserted `what(false)` contained the word
*"estimate"*, which was a proxy for hedging language and happened to pin the
exact sentence in place. It now asserts the intent — no "how many eggs", no
"remain", and "respond" present.

> A test written against a proxy will eventually defend the thing it was
> written to prevent.

## A-42 — fixed. She can write down what her clinic actually prescribed

The widest gap in the stage, and it sat directly under the most careful thinking
in it. The care pathway asks her, in these words, whether medication has taken
over *when* ovulation happens — and the answer decides whether we predict a
fertile window or defer to her clinic entirely. Then the Medication tile opened
a curated supplement list with `+` buttons and no text field anywhere. She could
add *folic acid, from our list*. She could not write *Letrozole 2.5mg, days 3
to 7*.

A woman on a stimulation protocol carries four drugs on a schedule, and the app
that had just asked her about her medication could hold none of them.

**No new store, no new table, no SQL.** `MedicineStore` lives in
`lib/services/`, not a stage folder, because a medication is not a pregnancy
concept or a TTC concept — it is a fact about a person. It already had the model
(name, dose, frequency, notes, start/end), per-day taken logs, and real OS
alarms with times and windows. Its tables already exist. This is a TTC-skinned
door onto infrastructure the app already had.

Local-first falls out for free: every cloud call in that store is gated on
`isLoggedIn`, so signed out it is a purely local record behaving identically.

**Two tiles now, not one.** "Supplements & medication" could only ever do one of
those jobs. A supplement is something *we suggested*, from a list, with a `+`. A
medication is something a *clinic prescribed* and she is reporting to us — free
text, her dose, her schedule. The tile count test moved 20 → 21, and the rule it
stands for did not change: a tile must lead somewhere genuinely its own.
Splitting when that becomes true is the same rule as merging when it is not.

**What it deliberately will not do:** no dose checking, no interaction warnings,
no inference from a drug name to a diagnosis. Seeing "Letrozole" does not let us
decide she has PCOS. A test asserts no conditional anywhere mentions a drug
name. `TruthSource.verifiedMedication` already sits above our own calculation
precisely so a schedule she reports outranks anything we derive.

## A-49 — fixed. Health Records holds the actual document

Fertility results in India arrive on paper and as PDFs. A text-only folder could
hold a number she retyped and never the report her clinic handed her — which
stayed in her gallery or her email, which is where she would go looking for it.
The folder was not the folder.

Cheaper than estimated, and I had said otherwise: `StorageService`,
`image_picker` and `file_picker` were all already in the app, with
`pp_attachments.dart` as a working reference. The storage decision had been made
and shipped; TTC had simply never used it.

**Local-first by construction.** `StorageService.upload()` returns the original
local path when signed out, and `resolve()` accepts either a local path or a
storage object path — so this behaves identically with no backend and starts
syncing files the day one exists.

The *list* of refs is deliberately local-only. `TtcRecord.toJson` is the
`shared_preferences` cache; the cloud row is written column by column in
`pushToCloud`. A field therefore reaches the database only when someone types
the column name out — which is what makes this safe rather than lucky. Adding a
column is a migration, and TTC is taking no new schema yet.

**Detaching is not deleting.** Removing a chip edits the list and leaves the
file alone. Wrong here is unrecoverable — she detaches a scan from the wrong
record and it is gone from her phone.

TTC got its own picker rather than importing the parenting one: the stages agree
on *values*, not widgets, and that file is pp-palette throughout. Sharing
happens one layer down, at the infrastructure.

## A-82 — fixed. His half had no profile door, and no header of its own

`TtcHeader` gained the profile door when A-2 / A-3 / A-61 were fixed — no
language control, no sign-out, no way to correct anything. His side had rolled
its own private `_Header`: a logo and nothing else. So the sealed room those
findings describe stayed sealed on his half. A paired partner had no route to
Hinglish and no way to sign out, on any screen.

> A private copy of a shared component looks harmless the day it is written and
> then silently stops receiving every fix the shared one gets.

One header with a `slate` flag now. The private one is commented out with that
note attached, because it is the clearest example of the rule in the codebase.

## A-83 — fixed. His hero rebuilt against the pregnancy Dad hero

Her TTC hero was built against the pregnancy *mother's* home. His was not built
against anything — a title, a tagline and one flat bar.

Now built element for element against `father_daily_screen.dart`'s
`_weeklySnapshot`: a muted eyebrow above the card, a clipped two-stop gradient,
one large white circle bleeding off the top right and one **amber** circle off
the bottom (amber is his accent exactly as coral is hers), a greeting, the serif
headline, the tagline, an onward link, the segmented bar, the "next" line, a
hairline divider, and three circular shortcuts.

The two products' father halves should look like each other, rather than one
looking like a plainer version of the same app.

The privacy omission from A-79 stands unchanged: no "Day N of 28".

## A-84 — fixed. The reader, and the home that feeds it

Two halves of one idea: **the content exists, you just have to tap.**

### The reader (A-50)

Was a title, a body and a takeaway on a fixed white page. Now carries reading
progress, font size, light/sepia/dark, save, and read-next.

**What was deliberately NOT copied from parenting's reader:** the table of
contents and the mid-article video slot. A TTC insight is a twenty-five to sixty
second read with no sections. A contents list on it is a control that exists to
look thorough and answers a question nobody has.

> Match the other stage's standard of care, not its component list. Copying a
> component because the other stage has it is how uniformity turns into clutter.

Progress is stored to **resume, never to score**. There is no "3 of 25 read"
anywhere and a test forbids a percentage on screen: on a health article a
percentage invites her to decide whether the rest is worth finishing. It also
only ever moves forward — scrolling back to re-read a paragraph is not losing
your place, and a value that fell on every upward flick would make the bar
jitter.

`TtcReadStore` is local-only. No mixin, no table. A reading position is the
least costly thing in this app to lose.

### The home (density)

Measured rather than guessed. Parenting's home caps text in **fourteen** places
and follows each with an explicit link — *"Explore Brain ›"*, *"Read more →"*.
TTC's Today capped in **five** across nine cards, and **five of nine printed
their body with no cap at all**: Rhythm, Video, Myth, Nutrition, Movement. That
is the whole reason one reads as a menu and the other as a wall.

**The constraint that shaped the fix: you can only hide what has somewhere to
go.** Rhythm has the Cycle Companion behind "Understand this" and can cap and
link. Movement and the Myth have no detail screen at all — capping those would
have deleted the second half of a paragraph nobody could then reach. So they
expand in place via `TtcExpandableText`, which only shows its control when the
text genuinely overflows. A "More" that reveals nothing is worse than no control.

### A note for whoever writes the next source-scanning test

Three tests in this batch failed by matching **their own explanation** — a check
for "no table of contents" tripped on the comment saying why there isn't one; a
check that a store carries no `TtcSyncedStore` tripped on the comment saying it
deliberately doesn't. `codeOf()` in `test/ttc_reader_test.dart` strips comments
before asserting.

> A test that greps source is reading prose as well as code, and prose about a
> thing contains the name of the thing. Assert against what executes.

## A-85 — fixed. Today was too many purposes, not too much text

Raised on the device: *"in comparison to pregnancy or parenting, TTC's home is
text heavy — less encapsulation. The content exists, you just have to click to
see it, rather than trying to show as much as we can."*

**The measurement contradicted the assumption behind it.** TTC's Today had
eleven sections; the parenting home has about eleven too. Identical. So "TTC
shows too much" was never about quantity, and the first fix — folding four card
bodies behind "More" — was aimed at the wrong axis.

The actual difference:

| | Structure |
|---|---|
| Parenting home | **six compact row builders** — `_domainRow`, `_win`, `_qa`, `_bigRow`, `_discoverCard`, `_aheadCard` |
| TTC Today | **nine full `TtcCard`s** |

> A row is a line you scan. A card is a small article you have to read.

Eleven cards feels like far more than eleven rows at the same word count. That is
structural, and no amount of capping paragraphs fixes it.

### The hero was trying to teach when its job is to orient

It had accumulated **four** attempts to explain the chapter, none with room to do
it — which is why all four read as vague:

| Was on the hero | Now |
|---|---|
| `nextUp()` — *"Next: Knowing Your Rhythm — from the day you log your next period"* | ⓘ sheet → **What moves you on** |
| `goal()` — *"WORTH DOING · Start folic acid and see a doctor once"* | ⓘ sheet → **Worth doing** |
| `focus()` — *"FOCUS · Health and habits"* | **dropped** |

`nextUp()` was mine, added in A-75. It named an internal chapter the reader has
no reason to recognise yet, so it cost two lines of the most valuable space in
the stage and explained nothing. `focus()` is the only one actually deleted: a
category label telling her which drawer she is in, which the title already does.

**A hero ORIENTS. A sheet EXPLAINS.** Separating those two jobs is the whole fix,
and it is the same principle as folding a paragraph behind "More".

The ⓘ sits **on the title**, because *"what does Preparing Together actually
mean?"* is a question about the title — so it is answered beside the thing that
raised it. That also means renaming the chapters can now be tested rather than
guessed at: read the sheet, then decide whether the name still needs changing.

**One thing added that was nowhere on the screen at all:** `reassurance()`, per
chapter — *"There is no falling behind in this part. It is measured in months,
not days, and what you start today is doing its work three months from now."*
Every chapter has a characteristic anxiety and in each case the honest answer has
the same shape: **the thing she is worried she is doing wrong is not a thing that
can be done wrong.** Probably the most useful sentence in each chapter, and it
had no home.

### Four cards became rows. Two did not.

Rows: the myth, today's nutrition, today's movement, today's pick. Each opens the
same content in a sheet — three of them had no detail screen anywhere, so
truncating them would have deleted content rather than folded it, which the whole
exercise was not allowed to do.

**The ritual and the journal keep their cards.** I had listed the ritual for
collapsing and was wrong: it has per-item checkboxes, a done/total and a streak.
Turning it into a row would remove the ability to tick things off from Today.

> Density work has to know the difference between something you **read** and
> something you **use**.

### The video card is gone

Its entire content was *"coming soon"*. It spent a section of the most valuable
screen in the stage advertising an absence, every day.

This is **not** the "a feature is never hidden" rule, and the distinction
matters: that rule is about **her** empty data — an empty journal renders an
invitation to write. This was **our** content gap. There is nothing she can do
about it and nothing to invite her into. Commented out, returns the day videos
exist.

**Twelve sections became eight.** Hero · rhythm · insight · the row list ·
ritual · journal · record-a-test · disclaimer.

### And a fourth test that defended a placement

`ttc_home_hero_test` asserted `Next:` inline on the hero — a test **I** wrote
when I put it there. It now asserts the answer is reachable in one tap, which is
what it should have asserted originally: the requirement was never "print it on
the hero", it was that a twenty-eight-day chapter must not read as the app having
stopped. The segmented bar and "Day N of 28" carry that.

Four times in two days. Worth stating as a rule:

> **Assert the requirement, not the layout.** A test that pins where something
> sits will block the next correct move; one that pins what the user can find
> out survives it.
