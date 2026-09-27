# TTC treatment flow: when her clinic runs the cycle

Written 2026-09-26 by helper TF. **Design only, nothing built.** For the user to read and approve before any code.
Another helper (K2) is changing the date resolver (`lib/ttc/ttc_day_context.dart`) at the same time; this document
is written to sit on top of K2's rule, not to change it.

**The requirement, in the user's words (condensed):** consistency. If she is following her clinic's cycle, the whole
app follows the clinic cycle. If she hasn't started with a clinic yet, she follows her own cycle. Once she starts
IVF there is one obvious place to go. Later, partner IVF centres will send the dates themselves. Say "you logged
your IVF situation, here is the process". When the round is done, let her change it. Don't show what doesn't apply:
during IVF, fertile days are irrelevant.

**The one-line proposal:** a treatment **round** becomes a real thing the app knows about. While a round is running,
every surface (home, calendar, daily cards, reads, messages, the IVF door) follows the round's step, taken from her
clinic's dates. Before a round starts and after it ends, she is on her own cycle, exactly as today.

Four rules hold everything below, and none are new:

1. **We mirror the clinic, never compute for it.** Every date in a round is one her clinic gave her. We explain,
   remind and help her prepare (CLAUDE.md, clinical ownership). We never suggest a date, a dose or a step.
2. **No chance, ever.** No success rate, no "good number of eggs", no reading of her beta value.
3. **Content changes, structure doesn't.** The round changes what the home, calendar and cards say, and the order
   of the IVF door's tabs. Every tab, door and screen stays where it is. Nothing is locked. We stop *predicting*
   fertile days; we don't hide the Fertile window door.
4. **The trap gets a way out.** Today, one tap on "IVF" switches her window off with no route back
   (STILL-OPEN §29, the note on `TtcStore.ownership`). In this design, clinic mode comes from real dates in a round,
   and every round has a clear end.

---

## 1. How treatment actually unfolds (India, typical)

Everything timing-related below is set by her clinic. Day ranges are typical, not rules; clinics differ. The app
never states these as her dates. It uses them only to explain what usually comes next. Facts marked **(confirm)**
go to Dr Surbhi Sharma (IVF gynaecologist, Bloom IVF) before any copy ships.

Words Indian clinics use, which the app should recognise and gloss: **follicular study** (follicle scans),
**stims** (stimulation injections), **HCG injection / trigger**, **OPU** (ovum pick-up, egg collection), **ET**
(embryo transfer), **blasto** (day-5 embryo), **FET**, **beta report**.

### 1a. Ovulation induction (the lighter path)

Tablets that help her ovulate, with scans to watch it.

| Step | Typical timing |
|---|---|
| Tablets: letrozole or clomiphene, once a day for 5 days | From period day 2 or 3 (sometimes day 5) |
| Follicle scans ("follicular study") | From about day 9 to 11, every 2 to 3 days, until a follicle is about 18 to 20 mm |
| Either her own LH surge (home LH tests, if the clinic asks) or a trigger injection | Clinic decides from the scan |
| Timed sex | The day of the surge or trigger and the next day, as the clinic says (about 24 to 36 hours after a trigger) |
| Sometimes progesterone support | From a few days after ovulation |
| Pregnancy test | About 14 to 16 days after the trigger, or when the period is due |
| Usually repeated | Up to about 3 to 6 cycles before the plan is reviewed **(confirm)** |

Who owns the timing: if a trigger is used, the clinic (`clinicControlled`). If she ovulates on her own under scans,
her body with the clinic watching (`clinicGuided`), and her LH tests still matter.

### 1b. IUI

The same start as 1a (tablets or low-dose injections, then follicle scans), then:

| Step | Typical timing |
|---|---|
| Trigger injection | When a follicle is about 18 to 20 mm |
| His sample | The morning of the IUI, produced at the clinic or brought within the hour; washed in the lab for 1 to 2 hours |
| IUI | About 24 to 40 hours after the trigger, often around 36 **(confirm)**. A few minutes, like a smear test. Normal day after. |
| Progesterone support | Often, from the IUI day or soon after |
| Pregnancy test | About 14 days after the IUI (blood or urine, as the clinic says) |
| Usually repeated | Often 3 to 4 attempts before moving to IVF **(confirm)** |

### 1c. IVF with a fresh transfer (antagonist protocol, the most common)

| Step | Typical timing |
|---|---|
| Sometimes a pill cycle first | Some clinics give birth control pills the month before to time the start |
| Baseline scan (and sometimes a blood test) | Period day 2 or 3. Checks the ovaries are quiet and counts small follicles |
| Stimulation injections ("stims") | Start the same or next day. Daily, about the same time each evening, for about 8 to 12 days |
| A second daily injection to stop early release (antagonist) | Added from about stim day 5 or 6 until the trigger |
| Monitoring scans and blood tests | From about stim day 5 to 7, then every 1 to 3 days. Doses may change after each |
| Trigger injection | When the lead follicles are about 17 to 20 mm. Usually late evening, at an exact time |
| **Egg collection (OPU)** | **34 to 36 hours after the trigger.** 15 to 30 minutes under short sedation. No food or drink from the time the clinic gives. Home the same day with someone. His sample the same morning. |
| Fertilisation: IVF or ICSI | The same day in the lab |
| Embryo days | Day 1: the lab checks fertilisation, often a phone call. Day 3: cleavage embryos. Day 5 (or 6): blastocysts |
| Progesterone support | From the collection day or the day after, until the test, and for weeks more if positive |
| Fresh transfer (ET) | Day 3 or day 5 after collection. A few minutes, often with a full bladder, no sedation |
| The wait | From transfer to the blood test |
| Beta hCG blood test | Usually 9 to 14 days after the transfer, on the date the clinic gives. Sometimes repeated 48 hours later |
| If positive | First scan about 2 to 3 weeks later (around 6 to 7 weeks pregnant). Progesterone often continues to about 10 to 12 weeks **(confirm)** |

From the period that starts it to the blood test, a fresh round is about 4 to 5 weeks.

**Why 34 to 36 hours.** The trigger does the last ripening of the eggs, which takes about a day and a half. The
eggs would be released on their own soon after that, so the clinic books collection just before. Too early and
the eggs may not be ready; too late and some may already have been released. That is why the trigger time is
exact, and why the app treats it differently from every other date. If she is late or unsure, the only right
advice is: call the clinic now. The app never tells her what a delay means.

**Other shapes of the same round, all normal:**
- **Long protocol:** a down-regulation injection from about day 21 of the cycle before, for about 10 to 14 days,
  then stims.
- **Freeze-all:** no fresh transfer. All good embryos are frozen (common with a risk of OHSS, high progesterone,
  or embryo testing, PGT). The round ends at collection plus freezing; a frozen transfer comes later.
- **Round stopped or changed:** too few or too many follicles, or early ovulation. The clinic may stop the round,
  convert it to an IUI, or freeze all. The app needs a kind "the plan changed" path, not an error.
- **ICSI** is a lab step (one sperm placed into each egg). Her days are the same. We have
  `ttc_read_ivf_icsi`.

### 1d. Frozen embryo transfer (FET)

| Kind | Steps |
|---|---|
| **Medicated FET (most common)** | Estrogen tablets from period day 2 or 3 for about 10 to 14 days. 1 to 3 scans to check the lining. Then progesterone starts; a day-5 embryo is usually transferred on the sixth day of progesterone **(confirm)**. Both medicines continue. Blood test about 9 to 11 days after transfer. |
| **Natural-cycle FET** | Follicle scans watch her own ovulation (home LH tests or a trigger). Transfer about 6 to 7 days after the surge or trigger for a day-5 embryo **(confirm)**. Progesterone often added. Blood test as the clinic says. |

Timing owner: medicated FET is `clinicControlled`; natural-cycle FET is `clinicGuided` (her LH still matters).

### 1e. The result, and after

| Result | What usually happens |
|---|---|
| **Positive beta** | The clinic may repeat it in 48 hours to see it rising. Keep all medicines until told otherwise. First scan at about 6 to 7 weeks. She moves into the Pregnancy stage, **dated by her clinic** (from the transfer day and embryo age), never by us. |
| **Negative beta** | The clinic says when to stop progesterone. A period usually follows within a few days to a week of stopping **(confirm)**. A review appointment ("follow-up consult") to talk about next steps. |
| **Unclear / low beta** | The clinic repeats the test. We never read the number. |
| **Next steps after a negative** | Frozen embryos: an FET, often after one full period. No frozen embryos: a new stimulation, often after 1 to 2 cycles' break. Or a pause. Or trying on her own between rounds, if her clinic agrees. |

India-specific context the content already carries: ART (Regulation) Act 2021 and registered clinics
(`ttc_read_donor_eggs_sperm`, door checklist "Are you registered under the ART Act?"), costs and packages
(`ttc_read_ivf_costs`, `ttc_read_ivf_package`), working through a cycle (`ttc_read_ivf_working`).

---

## 2. The states, and how she moves between them

### 2a. The states

| # | State | What it means | Timing owner |
|---|---|---|---|
| S0 | **Own cycle** | No round, or a round that hasn't started yet. Everything as today. | `parentveda` |
| S1 | **Round planned** | She has told us a round is coming, with at least one date, but its first treatment date is still ahead. Own cycle continues; the round shows as upcoming. | `parentveda` |
| S2 | **Getting ready** | Pill cycle, down-regulation, or estrogen tablets (FET) have started. | clinic |
| S3 | **Stimulation** (IVF) / **Tablets and scans** (OI, IUI) | From the first injection or tablet to the trigger. Day N counted from her first-dose date. | clinic |
| S4 | **Trigger** | Trigger day, then the day and a half before collection or IUI. | clinic |
| S5 | **Collection / IUI day** | The procedure day. | clinic |
| S6 | **Embryo days** (IVF) | Collection +1 to transfer, or to "embryos frozen" on a freeze-all. | clinic |
| S7 | **Transfer day** | The ET day (fresh or frozen). | clinic |
| S8 | **The wait** | Transfer (or IUI, or trigger for OI) to the blood test. Day N after transfer. | clinic |
| S9 | **Test day, then waiting to hear** | Beta day, until she records a result. | clinic |
| S10 | **Result** | Positive → Pregnancy stage. Negative → S11. Repeat test → back to S9 with a new date. | clinic until closed |
| S11 | **Between rounds** | The round is closed. Her own cycle again (see decision 5). The IVF door leads with next steps. | `parentveda` |

S1 to S9 are **derived from dates, never asked** (CLAUDE.md, "derive, never ask"): the step is simply the latest
clinic date on or before today and the next one after it. She never picks "I'm in stimulation". The only things
we ask are genuinely unknowable: what kind of round, the dates, the embryo's day (for dating a pregnancy), and the
result.

**The switch (sits on K2's rule).** K2's user decision: clinic mode only when real clinic dates exist in the
tracker; a label alone ("IVF" chosen, no dates) stays on her own cycle. This design adds one refinement: clinic
mode runs **from the round's first treatment date** (pill, down-regulation, estrogen, first tablet or first
injection, or baseline scan, whichever is earliest) **until the round is closed**. Dates entered for next month
don't switch off this month's cycle, because she may well be trying on her own this month (decision 1).

**Who owns the timing, from the round itself** (replaces the two questions on the treatment screen, decision 2):

| Round kind | Tier |
|---|---|
| IVF (fresh or freeze-all), medicated FET | `clinicControlled` |
| IUI or tablets with a trigger date | `clinicControlled` |
| IUI or tablets without a trigger (her own surge), natural-cycle FET | `clinicGuided` (LH logging stays on) |

### 2b. How she gets in

"You logged your IVF situation, now here is the process":

1. **IVF door** (primary, the "obvious place"). While no round is running, the top of the door carries one card:
   *"Starting treatment? Tell us your clinic's plan and we'll follow it with you."* The Track tab keeps "Track this
   treatment cycle".
2. **Home.** A clinic pathway already puts the IVF door first (`ttcDoorOrderedGroups`). Plus the "Taking a while"
   check card and the "trying for a while" message both lead to the IVF door.
3. **You › Details › Treatment** (exists) and the "My clinic dates" choices in the period-came and should-test
   chats (exist).

The **start flow** is three short screens, one question each:

1. *"What kind of treatment is this?"* IVF with a fresh transfer · IVF, freezing the embryos · Frozen embryo
   transfer · IUI · Tablets with scans · Not sure yet. (Not sure yet = the IVF shape, all steps optional.)
2. *"What's the first date your clinic gave you?"* The rows for that kind, first one open (baseline scan, first
   tablet or injection, estrogen start). "I'll add it later" is fine; with no date the round is S0 with an
   invitation, never clinic mode.
3. *"Which clinic? (optional)"* and one line: *"Your partner will see these dates too."* (The table is
   couple-scoped already.)

Then **"Here's how your round usually goes"**: a vertical timeline for that kind, her dates filled in, the rest
shown as *"Your clinic will tell you"*. Each row has one plain sentence of what happens and a link to its read.
This is the screen the user described.

### 2c. Editing, pausing, ending

- **Edit:** every row is tappable at any time. "The plan changed" is normal: moving the trigger already unticks
  it (`withDate`). Adding a monitoring scan is one tap ("Add another scan").
- **The round stopped or changed:** a row at the foot, *"The plan changed"*: stopped early, turned into an IUI,
  or freezing all the embryos. Each keeps her dates and changes the steps still ahead. Copy: *"Plans change
  often in treatment. It doesn't say anything about the next round."*
- **Result:** from test day, the home and the round show *"When you're ready, tell us how the test went."*
  Choices: Positive · Not this time · My clinic wants to repeat it · I'd rather not say now.
- **Pause:** *"Taking a break from treatment"* closes the round as paused. She is on her own cycle.
- **End:** closing any round moves it to her round history (kept, visible on the calendar and in the round
  screen as "Round 1, Sep to Oct"). Nothing is deleted. `clearCycle()` stays, as "Remove these dates" for a
  round entered by mistake.
- **Undo:** closing a round can be undone for 7 days, the same reversibility the pregnancy transition has.

### 2d. If she stops entering dates

A round with nothing ahead and no result doesn't hold her in clinic mode forever (the current trap). Recommended
(decision 3): 7 days after the last date passes with nothing ahead, the home asks once: *"Your clinic dates have
all passed. Is this round finished?"* If there's still no answer 21 days after the last date, the round closes
quietly as "ended, no result recorded" and the home says one line: *"We're following your own cycle again. Starting
a new round? Add your clinic's dates."* Logging a period after the test date also offers *"Mark this round as
finished?"*

---

## 3. What each state shows

### 3a. The home's top line (hero)

Built on the existing treatment hero states (`TtcHeroState.treatmentToday/Soon/Beta` in `ttc_home_hero.dart`),
extended additively. Existing rule kept: **count down to things she does, name the date of things that judge**
(the beta is never counted down).

| State | Eyebrow · big line · small line (examples) |
|---|---|
| S1 Round planned | Cycle day 12 (own cycle, as today) · small: *"IVF starts with a scan on Tue 14 Oct."* |
| S2 Getting ready | *"FET · Getting ready"* · *"Estrogen day 6"* · *"Lining scan on Thursday."* |
| S3 Stimulation | *"IVF · Stimulation"* · *"Injection day 6"* · *"Next scan Thursday, 9 Oct."* (the user's example) |
| S3 Tablets (OI/IUI) | *"IUI · Tablets and scans"* · *"Tablet day 3 of 5"* · *"First scan on Friday."* |
| S4 Trigger day | *"IVF · Trigger"* · *"Trigger shot tonight at 10:15pm"* · *"Egg collection is booked for Sunday morning."* |
| S4 After trigger | *"IVF · Egg collection tomorrow"* · *"No food or drink after the time your clinic gave you."* |
| S5 | *"Egg collection today"* · *"Rest after. Someone should take you home."* / *"IUI today"* · *"It takes a few minutes. You can go about your day after."* |
| S6 | *"IVF · Embryo day 3"* · *"The lab may call with an update. Transfer planned for Friday."* (freeze-all: *"Your embryos are with the lab"* · *"Your clinic will tell you about freezing."*) |
| S7 | *"Transfer day"* · *"Keep taking your progesterone as your clinic said."* |
| S8 | *"The wait · Day 4 after transfer"* · big: *"Blood test on Fri 24 Oct"* · *"Keep taking your medicines until your clinic says."* |
| S9 | *"Blood test today"* · *"Your clinic will share the result. We're here either way."* then *"Waiting to hear"* |
| S11 | *"Between rounds"* until a period is logged, then her own cycle day. Small: *"Review with your clinic on 3 Nov"* if she added it. |

No hero line ever shows a fertile day, "late", "period due", or a number about her chances.

### 3b. Daily cards and reads per state

Today, a clinic cycle gets the broad `TtcDayPhase.any` set (`kTtcPhaseReadIds[any]`). Proposed: a treatment-phase
set, the same shape as `ttcInsightsForPhase` / `ttcReadIdsForPhase` (about 20 short cards, 1 to 3 per state).

| State | Existing reads to use | Gaps (new reads) |
|---|---|---|
| S1, S2 | `ttc_read_ivf_explained`, `ttc_read_ivf_workup`, `ttc_read_clinic_glossary`, `ttc_read_ivf_working`, `ttc_read_ivf_costs`, `ttc_read_ivf_package` | **G1** "Your first treatment visit: the baseline scan" · **G2** "Frozen embryo transfer, step by step" |
| S3 | `ttc_read_ivf_injections`, `ttc_read_follicle_scans`, `ttc_read_ovulation_tablets`, `ttc_read_pcos_meds`, `ttc_read_ivf_ohss` | **G3** "Monitoring scans during IVF: what they're checking" (follicle scans read is OI/IUI-shaped) |
| S4 | `ttc_read_ivf_injections` (has "the trigger time is the one to set an alarm for") | **G4** "The trigger shot: why the time is exact" (the 34 to 36 hour rule, what to do if late: call) |
| S5 | `ttc_read_ivf_retrieval`, `ttc_read_ivf_ohss`, `ttc_read_semen_analysis` | **G5** "IUI day: what happens" · a short section in G4 or G5 on his sample |
| S6 | `ttc_read_ivf_icsi`, `ttc_read_clinic_glossary` | **G6** "Day 1, day 3, day 5: the words the lab uses" (words only, no grading of her embryos) · **G7** "Fresh or frozen transfer: how clinics decide" |
| S7 | door myth "Does bed rest after transfer help?" | **G8** "Transfer day, and the progesterone after it" |
| S8 | `ttc_read_when_to_test` (has "If you had a trigger injection"), `ttc_read_faint_line`, `ttc_read_implantation_bleeding`, `ttc_read_early_signs`, `ttc_read_stress_fertility`, `ttc_read_ivf_working` | **G9** "The two-week wait after IVF or IUI" (`ttc_read_two_week_wait` is natural-cycle shaped); the door's film slot `ttc_ivf_two_week_wait` stays |
| S9 | `ttc_read_when_to_test`, `ttc_read_faint_line` | **G10** "The beta test: what it is and why it's sometimes repeated" (never how to read her number) |
| S10/S11 negative | `ttc_read_period_came`, `ttc_read_month_after_month`, `ttc_read_chemical_pregnancy`, `ttc_read_others_news`, `ttc_read_good_news_answers`, `ttc_read_trying_again` | **G11** "When the test is negative after treatment: the next few weeks" · **G12** "Your review appointment: questions to take" |
| S10 positive | handed to Pregnancy | Pregnancy side: "after IVF" early weeks (progesterone, first scan). A handover, not TTC work |

Twelve gaps; G4, G8, G9, G10 and G11 are the P1 set. All by Dr Surbhi Sharma, through `docs/TTC-VOICE.md` and the
plagiarism check, like every other TTC read.

### 3c. The calendar

- **Shows:** her clinic dates as named markers (exists), plus soft bands: *"Injection days"* from first dose to
  trigger, *"Waiting for your blood test"* from transfer to beta. Her logged period days (facts). The "Upcoming"
  card names the **next clinic date**, not only the beta (today it shows only the beta countdown). Past rounds'
  dates stay visible.
- **Hidden during S2 to S10:** fertile shading, ovulation marker, "period expected", "next period in N days",
  "Period expected" and "if this cycle works, your due date would be around" lines.

### 3d. Messages and reminders

Built into `TtcMessagesStore` the same way as the five existing messages: **computed, not queued**
(BACKEND-PATTERNS §16m), ids carry the date they're about (`treat:collection:2026-10-12`), so a moved date moves the
message. One switch in You › Messages: *"Treatment reminders"*. New notification ids 918201 onwards.

| When | Title · body (examples) |
|---|---|
| Evening before the baseline scan | *"Your first scan is tomorrow"* · *"It's usually quick. Your clinic will tell you if they want a blood test too."* |
| Daily injections | Not a new reminder. The round links to the existing **Medication schedule** (`TtcMedicationScreen`, `MedicineStore`, which already has times and a taken tick): *"Add your injection time so we can remind you."* (decision 4) |
| Evening before each scan | *"Scan tomorrow"* · *"Most clinics see you early, so plan the morning if you can."* |
| Trigger, 4 hours and 15 minutes before (exist) | Keep both. Improve the body: *"Your clinic set this for 10:15pm. Egg collection is timed from it, about 34 to 36 hours later. If anything is unclear, call them now."* |
| Evening before collection | *"Egg collection tomorrow"* · *"No food or drink after the time your clinic gave you. Bring someone to take you home."* |
| Day after collection | *"Rest today"* · *"Some cramping and bloating is common. If you feel very bloated, pass much less urine or find it hard to breathe, call your clinic."* (OHSS signs, calm) |
| Evening before transfer | *"Transfer tomorrow"* · *"Take your medicines as usual. Check whether your clinic wants a full bladder."* |
| Transfer + 5 days | *"The middle of the wait"* · *"This is often the hardest stretch. Here's what helps, whenever you want it."* |
| Evening before the blood test | *"Your blood test is tomorrow"* · *"Plan something gentle for after, whatever the day brings."* |
| Test day + 2, no result recorded | **In-app only**, no phone alert: *"When you're ready, tell us how it went. We'll show you what comes next."* |
| After she records "Not this time" | In-app only, 2 days later: *"When you're ready: what happens after a negative test"* → G11 |

**Silenced during a round (S2 to S10):** window opens (already off), late by a day (already off), trying for a while
(already off), and two that are **not gated today**: *period came* (on a treatment cycle a period after the test
is expected, and "if you were hoping this month" is the wrong frame) and *cycle report* (a stimulated cycle's length
means nothing). After a negative result, the first period she logs gets a treatment-shaped message instead.

### 3e. Hidden because it doesn't apply (S2 to S10)

Fertile days and the window card; ovulation estimate; "period due", "late", "Time to test", the "Should I test?"
rail card (replaced by *"Your blood test is on Fri 24 Oct"*); the Sex and Test one-tap buttons on IVF and medicated
FET (a clinic often asks for no sex before his sample); ovulation-test logging and the temperature chart prompt in
`clinicControlled` (kept in `clinicGuided`, where her LH is what the clinic times around); the natural-phase daily
cards; the cycle report for the treatment cycle. All of these come back the day the round closes.

**Not hidden:** every door, tab, read and tool. The Fertile window door still opens; its hero says *"Your clinic
is timing this round, so we're not estimating fertile days right now."* (reuses `TimingOwnership.body`).

### 3f. The IVF door, first thing

| When | What sits on top of the door |
|---|---|
| No round | *"Starting treatment?"* card → start flow. Tabs as today (age tab second for 35+). |
| S1 to S9 | **"Your round"** panel: the kind, today's step, the next date, *"See the whole plan"* and *"Update dates"*. Tab order moves "Going through it" and "Track" first (order only, same tabs). |
| After a negative | **"Between rounds"** panel: G11, G12, `ttc_read_month_after_month`, *"Start the next round"*. |

### 3g. His side

The table is couple-scoped already. His home shows the same round line, from his side: *"Egg collection on Sunday.
Your sample is needed that morning."* He never sees her cycle details, only the round (the same privacy rule as
`partnerChapter`).

### 3h. Mobbin (what exists, and what it lacks)

- **Lacks:** no IVF or fertility-clinic app is in the library (Kindbody, Maven, Carrot, Progyny searched: none).
  Flo appears only in cycle mode and has no treatment mode; What to Expect isn't in Mobbin. So there's no
  competitor screen to copy; the patterns below are borrowed from nearby health apps.
- **Apple Health "Factors"** ([screen](https://mobbin.com/screens/c3439197-4c96-49b8-b62e-1deaa3a550c6),
  [list](https://mobbin.com/screens/1ce28edf-90a8-4f33-bec3-6188e9b8cb1c)): a declared state that changes the
  predictions, shown as one row with its own date ("Pregnancy · Due Jul 2"). The closest thing to our round: one
  row, one date, one place to end it.
- **Apple Health Medications** ([flow](https://mobbin.com/flows/d89c713f-1647-495c-b85e-f86757025158)): today's
  doses, a time, a "Taken" tick. Our medication schedule already has this shape, so injections go there.
- **Superpower's "72 hours before, 24 hours before, 10 hours before"**
  ([screen](https://mobbin.com/screens/27a88f09-3f73-420f-bd57-135aaaaa605a)): a prep timeline counted back from an
  appointment. Right for collection and transfer prep inside G4, G8 and the round plan.
- **Dated vertical timelines** (Marcus, [screen](https://mobbin.com/screens/726179c1-f0b8-4da5-afdd-5169852bb283);
  Deepstash, [screen](https://mobbin.com/screens/a276b33b-25f4-4af8-a600-4813a2501089)): done, today, next, with
  dates. The model for "Here's how your round usually goes".
- **Flo's goal pills** (Track cycle · Get pregnant · Track pregnancy,
  [screen](https://mobbin.com/screens/a89d9b0a-4c2e-4ec3-a121-a5c48655c6b2)): confirms the mode lives in one
  obvious place and is easy to change back.

---

## 4. Partner IVF centres (a future seam, not built now)

**The idea.** A partner clinic sends her round's dates to the app, so she doesn't type them. The app shows *"Your
plan from Bloom IVF"* (any linked clinic's name) and follows it.

**How it plugs in:**
- **Ranking.** Clinic-sent dates are `TruthSource.treatingClinician`, rank 1. Her own entries are
  `userObservation`, rank 5. `TruthHierarchy.resolveFor` already picks the winner per fact; a new `Inferable`
  entry, `treatmentSchedule`, is added and permitted in code (Inferable is default-deny).
- **Storage.** A new table, e.g. `clinic_treatment_events` (round id, step, date and time, clinic id, sent at,
  version), written only by the clinic's side (the doctor app, `--flavor doctor`, and the partner model in
  BACKEND-PATTERNS §12, or a server function for a clinic's own system). RLS: a clinic writes only for a patient
  who has linked it; she reads her own; her partner reads through `my_partner_id()`. Her own `ttc_treatment` row is
  untouched, so everything built before this keeps working. Pinned by a schema contract test, like
  `test/ttc_schema_contract_test.dart`.
- **When the two disagree.** The clinic's date leads on every surface and drives the reminders. Her own entry isn't
  deleted; it shows small underneath: *"Your clinic's plan says Sunday 8:30am. You had noted Saturday. If that
  doesn't match what they told you, give them a call."* We never pick for her by guessing, and we never average.
  (Decision 6.)
- **Consent.** Linking is her act: a code or QR from the clinic, like the partner pairing code. Before linking she
  sees in plain words what the clinic will send (dates and times for her rounds) and what it will see (nothing
  from the app, unless a later, separate consent adds something). She can unlink at any time; past clinic dates
  stay, labelled. This follows India's DPDP Act 2023 (clear purpose, withdrawable consent).
- **Attribution.** Showing a clinic's name is the open attribution question (STILL-OPEN §2.1). Proposed: only for
  a clinic she linked herself, never as an advert.

---

## 5. What exists and what must be built

### 5a. Exists today

| Piece | Where |
|---|---|
| Round dates (5 steps), clinic name, trigger time + taken tick, 2 trigger reminders, couple sync, re-arm on launch | `lib/ttc/ttc_treatment_store.dart`, table `ttc_treatment` (jsonb, `0043`) |
| Treatment screen: path chooser, the two questions, date rows, clear | `lib/screens/ttc/ttc_treatment_screen.dart` (route `ttc/treatment`) |
| "Your clinic runs this cycle" card | `TtcTreatmentEntryCard` (Today, window, cycle screens) |
| Timing tiers and behaviour flags | `lib/ttc/ttc_care_pathway.dart` |
| Clinic cycle refuses window, due, late | `ttcDayContext` rule 2 (K2 changing now) |
| Hero treatment lines (today, soon, beta by date) | `lib/ttc/ttc_home_hero.dart` |
| Calendar markers, beta card | `lib/screens/ttc/ttc_calendar_screen.dart` |
| Messages gated by ownership | `lib/ttc/ttc_messages_store.dart` |
| IVF door with Track tab, OHSS tile | `lib/ttc/focus/ttc_focus_ivf.dart` |
| Medication schedule with reminders | `TtcMedicationScreen` + `MedicineStore` |
| Appointments, records, doctor notes | `TtcAppointmentsStore`, `TtcRecordsStore`, `pv_doctor_notes_screen.dart` |
| Positive test → pregnancy | `lib/ttc/ttc_transition.dart` (**dates from last period only**) |
| Clinic-owned due date type and IVF maths | `DueDateSource.ivfTransfer`, `due_date_calculator_screen.dart` (transfer + 266 − embryo day) |
| Truth ranking | `lib/services/truth_hierarchy.dart` |
| Reads | 11 IVF, 10 age/second baby, 8 waiting, loss and hard-days reads (listed in 3b) |

### 5b. To build, in order (all additive; old code commented out with a kept-for-revert note)

| # | What | Size | Tests that hold it |
|---|---|---|---|
| B1 | **The round model.** Add to the existing jsonb blob (no migration): round `id` (app-generated), `kind`, new optional steps (pill start, down-regulation, estrogen start, baseline scan, monitoring scans as a list, IUI separate from collection, progesterone start, embryo day 3 or 5, freeze-all, repeat beta, review appointment), `outcome` + `closedOn`, and `history`. Old five-step JSON loads unchanged. A pure function `ttcTreatmentPhase(round, date)` gives S1 to S11. | M | `test/ttc_treatment_phase_test.dart`: every kind walked day by day, partial dates, a rescheduled trigger, old JSON loads |
| B2 | **The switch**, with K2: `ttcTreatmentActive` (first treatment date reached, round not closed), tier from kind + trigger date, the stale rule (2d). `ttcDayContext` reads it. | S | `test/ttc_date_consistency_test.dart` gains round scenarios: no window, due or late on any surface, any day of any round; label-only stays own cycle |
| B3 | **Start, plan, result, pause.** Start flow (3 screens), "how your round usually goes" timeline at the top of the treatment screen, "the plan changed", result sheet, pause, 7-day undo. The path chooser and two questions commented out (decision 2). Routes `ttc/treatment`, `ttc/treatment/start`, `ttc/treatment/result`. | M | widget tests for each screen; a reachability test that greps the call sites (IVF door, home, You row, chats) |
| B4 | **Home.** Hero states per 3a (additive `TtcHeroState` values), treatment daily cards + `kTtcTreatmentPhaseReadIds`, hide Sex/Test buttons, blood-test line in place of "Should I test?" | M | hero tests for a clinic-pathway account on every state (the §29.7 lesson: test as the clinic account, not the default) |
| B5 | **Calendar.** Bands, next clinic date card, past rounds | S | calendar facts test per state |
| B6 | **Messages.** Treatment messages (3d), the switch, gate period-came and cycle report during a round, link to the medication schedule | M | messages test: computed per date, move a date and the message moves, nothing natural fires in a round, ids stable |
| B7 | **IVF door.** Your round panel, Starting treatment card, Between rounds panel, tab order | S | `test/ttc_door_screen_test.dart` additions |
| B8 | **Positive → Pregnancy, dated by the clinic.** IVF and FET: due date from transfer day and embryo day, `DueDateSource.ivfTransfer`; ask the embryo day if missing; offer "My clinic gave me a due date". IUI and OI: last period, with the IUI or trigger date as a fallback. | M | `test/pregnancy_dating_test.dart`: day-5 transfer gives transfer + 261 and a clinic-owned source; nothing recalculates it after |
| B9 | **Content.** G1 to G12, P1 first (G4, G8, G9, G10, G11) | L | `pv_read_shape_test`, `ttc_clinical_review_test` (scans for chance language), plagiarism check, expert sign-off list |
| B10 | **His side.** Round line on his view | S | partner view test: round visible, her cycle not |
| B11 | **Ask Veda.** Send `treatment_step` so answers are framed to where she is. **Two-repo change:** this side is inert until `C:\Projects\parentveda-askveda` declares and uses the field. Needs the user's go-ahead to open that repo. | S here + service | request-body test on this side; service-side test there |
| B12 | **Partner clinics** (section 4). Later, not in this build. | L | schema contract test, RLS test, consent test |

B1 and B2 first (everything reads them), then B3 and B4 (what she sees), then B5 to B8, content in parallel from
the start. Every batch ends with `flutter analyze` clean and the full suite green, as usual.

**Facts to confirm with Dr Surbhi Sharma before copy ships:** OI and IUI repeat counts; IUI timing after trigger;
FET transfer timing (medicated P+5 or P+6 wording, natural LH or hCG + days); how long after stopping progesterone a
period usually comes; progesterone continuation after a positive; how long a trigger can show on a home test
(`ttc_read_faint_line` already says "up to", keep it consistent); OHSS warning wording.

---

## 6. Decisions for you

1. **When does the app switch to the clinic's cycle?**
   - **A (recommended):** from the round's first treatment date (first pill, tablet, injection or baseline scan).
     Dates for next month don't switch off this month.
   - B: as soon as any clinic date is saved.
2. **The two questions on the treatment screen** ("Is your clinic scanning you?", "Does medicine decide when you
   ovulate?"):
   - **A (recommended):** work it out from the kind of round and whether there's a trigger date; comment the
     questions out (kept for revert).
   - B: keep asking them.
3. **If she stops entering dates:**
   - **A (recommended):** ask once 7 days after the last date; if no answer by 21 days, close the round quietly and
     go back to her own cycle with a one-line note.
   - B: stay in clinic mode until she closes it herself.
4. **Daily injection reminders:**
   - **A (recommended):** use the existing Medication schedule, linked from the round.
   - B: build injection times into the round itself.
5. **After a round ends (negative or paused), before the next one starts:**
   - **A (recommended):** fully back to her own cycle, fertile days included, as soon as she logs a period. Many
     couples try on their own between rounds, and it matches your rule that clinic mode needs real dates.
   - B: keep fertile days hidden until she says she's trying on her own again.
6. **Later, when a partner clinic's date differs from hers:**
   - **A (recommended):** the clinic's date leads and drives reminders; hers stays visible underneath with "give
     them a call".
   - B: ask her to choose each time.

## 7. Decided (the user, 2026-09-26) — BUILD APPROVED
1. **Treatment mode starts on the round's first treatment date** (not when a date is saved).
2. **The step comes from her dates; the two old questions are worked out from the round** (lead's call, as recommended).
3. **If she stops entering dates (changed from the proposal):** at 7 days with nothing new, a gentle, VISIBLE check-in ("Is your round still going?") with clear answers (Still going / Paused / It's over). The round is **never closed quietly**: it stays until she answers. The check-in stays reachable and repeats gently (not a nag: at most once every few days). **If she comes back after 30 days or more and logs anything** (a period, a symptom, a date), ASK her first ("Is your round still going, or are you back on your own cycle?") instead of resetting or assuming. Every edge case follows the same rule: ask, never assume, never delete.
4. **Daily injection reminders reuse the Medication schedule** (lead's call, as recommended).
5. **After a round ends without a pregnancy, fertile days come back once she logs her next period.**
6. **Partner clinics (later):** the clinic's date leads, hers stays visible (lead's call, as recommended).
Also from the resolver pass (K2), decided by the lead for consistency and relevance: pre-treatment earlier cycles KEEP their look-back fertile days (only cycles holding clinic dates hide them); a treatment-labelled account with no dates sees an "Add your clinic's dates" card (the obvious way in); `pathwayQuestionsWhy` copy updated. Ask Veda (B11) needs `C:\Projects\parentveda-askveda`: ask the user for access at the end.
7. **Firm rule (the user, 2026-09-26):** "the options should serve the user well and explicitly tell them before
   anything happens; industry-standard performance and handling instead of creating ambiguity." So: nothing changes
   silently (every mode change announced before or at the moment it happens, with what changes and how to undo);
   every sheet has 2 to 3 clearly labelled choices that say exactly what they do, a safe default and a 7-day undo;
   mode-changing actions confirm and restate the consequence; nothing is deleted; full loading/empty/error states,
   date validation, date-only keys, accessibility labels, 360dp, persistence across restarts; tested.
   **Also (the user):** use the Mobbin MCP for every design and structure decision, especially new screens; cite the references.

## 8. Build status (2026-09-26)
B1 round model · B2 switch · B3 start/plan/result/check-in · B4 home · B5 calendar · B6 messages · B7 IVF door ·
B8 positive → pregnancy dated by transfer · B9 content (G1 to G12, `lib/ttc/reads/ttc_reads_treatment.dart`) ·
B10 his side: **BUILT**, full suite green (4992). **B11 Ask Veda: owed** (needs the user's go-ahead to open
`C:\Projects\parentveda-askveda`). **B12 partner clinics: later.** Lead calls on the builder's questions: tabs reorder
during a round (Going through it, Track first; order only); the between-rounds panel stays 90 days; recording a
positive with a round open closes it as positive on confirm; IUI dating without a logged period goes to Dr Surbhi
Sharma to confirm.
