# Flow inventory — what to design next, and why

**Written:** 2026-08-24
**Purpose:** the work queue for the Mobbin subscription. Every entry names a
*user moment*, not a code module, because the thing we are buying is sequencing
judgement and sequencing only makes sense from inside the user's head.

**Companion files.** `docs/UX-PRINCIPLES.md` is the understanding layer — who she
is and what that forbids. This file is the *backlog* layer: given those
principles, which flows are still undecided, in what order, and what to go and
look at. Where the two disagree, UX-PRINCIPLES wins.

---

## The finding that should set the agenda

The app currently ships **eight `*VersionStore` classes** — Today, PP Home, TTC
Home, Grow, Health Wallet, Scans Hub, Shravan, Baby Naming — plus a version pill
on Hospital Bag and a Standard|Full toggle on week 5.

A version toggle is what a team ships when it **cannot decide which design is
right**. Each one is a design question deferred to a runtime switch. Two are
already logged as open points (`STILL-OPEN.md` §5.9 Grow — *three* versions
behind one row; §5.10 Health Wallet — two).

That is roughly ten unresolved design decisions carried as code. They cost twice:
each is a second code path to maintain, and none of them is actually answered —
the user still gets whichever we defaulted to.

**This is precisely the debt a reference library retires.** It converts "which of
our two guesses is better?" into "here is what fifteen shipped products converged
on, and why the ones that diverged did." Closing toggles should be a first-class
outcome of the subscription, not a side effect.

---

## How entries are scored

| Axis | Values |
|---|---|
| **Reach** | Everyone / Most / Some / Few |
| **If it fails** | stated as a plain consequence, not a severity word |
| **Confidence** | Settled / Wobbling / Unknown |
| **Leverage** | how well-indexed the archetype is in a reference library |

Priority is roughly `Reach × cost-of-failure × (1 − confidence) × leverage`.
A flow we are confident about is not on this list however important it is —
**confidence is the thing we are buying.**

---

# TIER 1 — the front door

## 1.1 First run: splash → auth → onboarding

**Reach:** Everyone, exactly once, unrecoverable.
**Confidence:** Unknown. **Leverage:** High.

**Where it lives:** `lib/screens/auth/auth_flow_screen.dart` — **2,543 lines, one
file, ~13 states**: welcome, login, signup, profile, role, stage, pair code,
pairing, paired, employer, OTP, reset, success, confirm-email.

**The user, honestly.** She downloaded this at 11pm, either after a positive test
or after another month that did not work. She is not evaluating a product. She
wants one thing: *tell me it is going to be alright, and show me something about
my situation.* Every screen between the download and that moment is a screen she
might close the app on.

**What makes it genuinely hard, not merely long.** The role choice (mother /
father / doctor) crosses the stage choice (TTC / pregnancy / parenting), and
father additionally branches into a pairing sub-flow. That is up to nine distinct
paths through one file. Most apps have one. There is little prior art for a
*three-role, three-stage* first run — which is exactly why it is worth studying
hard how others handle even two.

**The tension to resolve.** `CLAUDE.md` says *derive, never ask* and *say what the
answer unlocks*. Thirteen states is in open tension with that. The question for
the reference pull is not "how do we make this prettier" but **how few of these
can be deferred past the first value moment**, and which can be inferred rather
than asked.

**Pull as:**
- "onboarding with a branching role or path selection"
- "progressive profiling — asking for profile data after first value, not before"
- "account creation with social auth, minimum fields"
- "apps that show something useful before asking who you are"

**Extract:** how many screens before first value; what is asked up front vs
deferred; where account creation sits relative to the value moment; how the
branch is presented (cards? a question? a skippable default?); what the back path
looks like when someone picks wrong.

---

## 1.2 Partner pairing

**Reach:** every couple that actually uses this as a couple — the stated core.
**Confidence:** Unknown. **Leverage:** High.

**Where:** `_pairCode()` / `_pairing()` / `_paired()`, same file.

**Why it earns its own entry.** This is a **two-person, two-device, asynchronous**
flow. He installs at a different hour than she does. One of them is waiting on
the other with no idea whether anything is happening. Nearly every failure here is
a *state-visibility* failure, not a layout failure.

`UX-PRINCIPLES.md` §0.1 says it outright: **"a couples product that acquires a
child, not a mother's app."** If pairing is friction, we are a mother's app in
practice regardless of what we built.

**Pull as:** "invite a partner via code", "join a shared plan / joint account",
"two-device linking with a pending state". The best prior art is outside our
vertical — joint fintech accounts, family subscription plans, shared calendars.

**Extract:** what the *inviter* sees while waiting; what the *joiner* sees before
they have anything of their own; how the code is delivered (share sheet? QR? deep
link?); the recovery path when the code expires or is mistyped.

---

# TIER 2 — the money

## 2.1 The full purchase chain

**Reach:** Some. **All revenue.** **Confidence:** Wobbling. **Leverage:** High.

**Where:** `lib/screens/prepare/` (14 screens) → `lib/booking/` (12 files).
Razorpay is real — `payment_service.dart` does create-order → checkout sheet →
server-side signature verify. Seat caps are enforced by RPC. This is built, not
stubbed.

**The chain, as she walks it:**
`Prepare hub → offering list → detail → buy entitlement → pick slot → confirm →
pre-join → call → outcome / prescription`

**Seven steps, with an unusual middle.** We use a **two-phase model** — you buy an
*entitlement*, then separately *spend* it on a slot. That is good architecture and
genuinely confusing if unexplained, because most consumer flows fuse "pay" and
"pick a time" into a single act. A user who has paid and does not yet have a time
in her calendar believes something went wrong.

**The user, honestly.** She is about to spend ₹1,500–5,000 (~$17–57) on advice
from a stranger, through an app she installed recently, in a category that has
been marketing at her relentlessly. `UX-PRINCIPLES.md` §0.1: *"good at spotting
it. One wrong-feeling upsell costs more trust than the paid layer earns."*

Everything she needs before paying is a trust question — **who is this person,
what actually happens on the call, what if I have to miss it, what if it is
useless.** Layout is downstream of all four.

**Pull as:**
- "book an appointment with a professional" (telehealth, therapy, legal, tutoring)
- "buy a package of sessions / credits, then redeem" ← the unusual half
- "practitioner profile before booking — how trust is established"
- "pre-call lobby / join screen"
- "one-to-one and group sessions in one catalogue"

**Extract:** where payment sits relative to slot choice and *how the gap is
explained*; what a practitioner card shows before you tap; how cancellation and
reschedule policy is surfaced *before* payment; what the confirmation actually
promises; the pre-join checklist pattern.

**Constraint:** per `one-to-one-before-group-calls` — finish 1:1 fully before
touching group, and guard every change on `capacity == 1`.

---

## 2.2 The upsell moment

**Reach:** Most, eventually. **Confidence:** Unknown. **Leverage:** High.

Locked / premium / upgrade language currently appears across **~20 files** with no
single owning component — courses, journal settings, name detail, reads, journey
map, community.

**The rule this must satisfy is stricter than normal commercial design.**
`UX-PRINCIPLES.md` §0.2(a) forbids urgency, scarcity, countdowns and streak-guilt.
That deletes most of the standard paywall playbook. So this pull is partly a
**negative** one: much of what a library returns for "paywall" is a pattern we
have already banned, and the job is to find the minority that persuade without
pressure.

**Pull as:** "soft paywall / value-first upgrade prompt", "locked content preview
that shows what you get", "non-urgent upgrade surface" — then filter hard against
§0.2.

**Extract:** how much of the paid thing is shown for free; where the prompt sits
(inline, sheet, full screen); how a decline is handled — whether it is asked
again, and how soon.

---

# TIER 3 — the daily return

## 3.1 The three Today homes

**Reach:** Everyone, most days. This screen *is* retention.
**Confidence:** Wobbling — **two live version toggles.** **Leverage:** High.

**Where:** `ttc_today_screen.dart`, `today_home_screen.dart` (+ `TodayVersionStore`),
`pp_home_v3.dart` (+ `PpHomeVersionStore`), and at the root `home_screen.dart`,
`home_screen_b.dart`, `home_v3_screen.dart`, `home_focus_screen.dart`,
`today_home_screen.dart` — five home variants at the root alone.

**The user, honestly.** 2am. One hand. The other arm holds a baby, or she is lying
down and cannot sit up. Exhausted, possibly worried, definitely not browsing. She
opens the app with **one** question: *what do I need to know today?* Everything on
that screen that is not an answer to that question is a tax.

**The design question to actually settle:** does Today *answer*, or does Today
*route*? Those are different screens and we appear to have built both. The version
toggles are the evidence that it was never decided.

**Pull as:** "daily briefing home", "today view for a health or habit app",
"personalised dashboard with one primary action", "home that changes by user
stage". `UX-PRINCIPLES.md` already banks 68 Flo screenshots and the conclusion
*"information is the hero, not an illustration"* — start from that rather than
re-deriving it.

**Extract:** how many distinct blocks before the fold; whether there is a single
hero action; how **"nothing notable today"** is handled — this is the common case
and usually the worst-designed one; how date and stage context is shown without
becoming a countdown.

**Required outcome:** pick one. Comment out the other. A closed toggle is the
deliverable, not a new screen.

---

## 3.2 Ask Veda — asking, and reading a long answer

**Reach:** Most. **Confidence:** Wobbling. **Leverage:** Medium.

**Where:** three screens (pregnancy / parenting / TTC) plus `global_ask_fab.dart`.
The answer is a **7-section structured response** and the brain lives in the
separate FastAPI repo — **this entry is presentation only.** Nothing here implies
or requires a service change.

**Two distinct problems; do not merge them.**

**(a) Asking.** A worried person at 2am does not know the right question. The
empty input is the hardest state on the screen. What we put *there* matters more
than the input styling.

**(b) Reading.** Seven sections is a lot of text for someone frightened, and this
is exactly where `UX-PRINCIPLES.md` §0.2(b) bites — *we are never the authority*.
The answer must be scannable, must surface the reassuring part first, and must
route to a clinician without that reading as a brush-off.

**Known open point:** §9.5 — the Ask Veda FAB still overlaps content on pregnancy
and parenting. Worth fixing regardless of this exercise.

**Pull as:** "AI assistant answer with sources and sections", "medical or legal
answer with a disclaimer that does not feel like a disclaimer", "long structured
response with progressive disclosure", "empty state with suggested prompts".

**Extract:** how sections are made skimmable (accordions? anchors? a summary
line?); where the disclaimer sits and how it is worded; how suggested questions
are chosen and shown; what happens when there is no confident answer.

---

# TIER 4 — structural, affects everything

## 4.1 Empty states — the highest-ratio item on this list

**Reach:** Everyone, constantly, especially in week one.
**Confidence:** Unknown. **Leverage:** High. **Effort:** the lowest here.

**The situation.** `CLAUDE.md` states the rule: *"A feature is never hidden. Empty
sections render an invitation; only the empty copy changes. The empty state is the
feature's advertisement."*

The implementation does not match the ambition. There are **20+ bespoke `_empty()`
helpers** — `cart_screen`, `community_screen` (three of them), `bump_book`,
`bump_journey`, `dear_baby_vault`, `global_search`, `father_journal`,
`doctor_home`, `doctor_appointments`, `launch_hub`, `scan_reports` — each
hand-rolled, each different. There is **no shared empty component and no house
anatomy.**

**Why this goes first.** A brand-new user sees *almost nothing but empty states.*
Day one of this app is a tour of blank sections. That is the first impression, and
right now it is twenty different first impressions.

One reference session produces one anatomy and one shared widget, and it lands on
twenty-plus screens at once. `UX-PRINCIPLES.md` already cites *"empty-state
anatomy"* (source 6) and *"turn empty states into opportunities"* — the principle
is banked; only the spec is missing.

**Pull as:** "empty state", as a batch — twenty across categories in one go.

**Extract into one house anatomy:** does it get an illustration or a drawn mark;
how many words; is there always an action; what the action says when the feature
is not yet usable; and how it differs from a *loading* state and from an *error*
state — three different things, frequently conflated.

**Deliverable:** `docs/flows/empty-states.md`, one shared widget, and a migration
list of the twenty screens.

---

## 4.2 Findability: the Explore drawer

**Reach:** Most, in the parenting stage. **Confidence:** Wobbling.
**Leverage:** Medium.

**Where:** `explore_drawer.dart`, fronting **237 files** of parenting surface — My
Child, Family Profile, Guided journeys, Watch, Health, Food, Recipes,
Recommendations, READ, Courses & Masterclasses, Yoga & Classes, My Bookings, and
more.

**The user, honestly.** She does not know these exist. A drawer is a list, and a
list of fifteen good things reads exactly like a list of fifteen mediocre ones.
Meanwhile `UX-PRINCIPLES.md` §0.1 warns of **very wide digital literacy** and
mandates **always label nav icons** — a drawer is already the weakest discovery
surface available for that audience.

**The real question:** is a drawer right at all, or is this a *category screen*?
UX-PRINCIPLES source 7 banks "category screens" as a studied idea, and the
endorsed treatment — drawn marks in tinted wells — is already what we do.

**Pull as:** "category / directory screen for a large app", "app with many
sub-products — how the second level is organised", "sectioned browse with visual
categories".

**Extract:** grid vs list; how many top-level groups before a second level is
needed; whether recently-used or stage-relevant items get promoted; how a new or
never-visited section is signalled.

---

## 4.3 Close the version toggles

**Reach:** varies. **Confidence:** Unknown *by construction.* **Leverage:** High.

Not a screen — a **standing agenda item**. Eight version stores plus two further
toggles. Every reference pull above should end by asking: *did this close a
toggle?*

Known: Grow (three versions — §5.9), Health Wallet (two — §5.10), Today, PP Home,
TTC Home, Scans Hub, Shravan, Baby Naming, Hospital Bag, week-5 Standard|Full.

Per `CLAUDE.md`: **comment out, never delete**, with a "kept for revert" note.
Closing a toggle means choosing and commenting the loser, not ripping it out.

---

# TIER 5 — emotionally hardest; design last, think first

Listed last because they need the most care, not because they matter least.
Reference libraries are **weakest** here and can actively mislead.

## 5.1 TTC — the month that did not work

`lib/screens/ttc/` — 42 screens. The recurring user moment is **a negative
result**, monthly, possibly for years.

Most fertility apps in any reference library will show the exact patterns we have
**banned**: a personalised chance-this-month, a score, a streak, a countdown.
`CLAUDE.md` forbids personalised probability outright, and
`test/ttc_clinical_review_test.dart` scans the source to keep it forbidden.

**Use the library as a negative reference here** — pull it to catalogue what to
avoid, and to find the rare screens that deliver a non-result with dignity.
Positive prior art is likelier in grief, recovery and chronic-illness apps than in
fertility ones.

## 5.2 Stage transitions, and the one that is missing

`ttc_transition_screen.dart` is the model for how to do this well. It shows
*counts read back from her own stores* rather than claims, and deliberately never
says "congratulations," because plenty of couples reach it carrying a previous
loss. That reasoning is worth preserving verbatim.

**The gap.** Pregnancy loss appears in *content* — community, conditions, mind &
mood, read-next — but there appears to be **no flow**: no path where the app's
state changes because a pregnancy ended. Today keeps counting weeks.

This is the most serious user-experience gap found in this pass, and it is not a
Mobbin problem — no library will have it. It is a product decision, and it belongs
in `STILL-OPEN.md` as an open point rather than in a design queue. **Flagged, not
scheduled.**

---

# The queue

Two months of subscription, sequenced so the cheap item teaches the workflow
before the expensive one needs it.

| Week | Flow | Why here |
|---|---|---|
| 1 | **4.1 Empty states** | Cheapest, lands on 20+ screens, low-risk way to learn the loop |
| 2–3 | **1.1 First run** | Highest stakes, hardest, needs the most reference |
| 3 | **1.2 Pairing** | Same file, same session — do not reopen it later |
| 4–5 | **2.1 Purchase chain** | Revenue. The two-phase gap is the specific thing to solve |
| 5 | **2.2 Upsell moment** | Falls out of 2.1; mostly a filtering exercise |
| 6–7 | **3.1 Today homes** | Retention. Deliverable is a *closed toggle*, not a new screen |
| 7 | **3.2 Ask Veda answer** | Presentation only — no service change implied |
| 8 | **4.2 Explore findability** | Benefits from everything above being settled first |
| ongoing | **4.3 Toggles** | Ask at the end of every pull |
| later | **5.1 / 5.2** | Think first. The library is weak or misleading here |

**Per-flow ritual**

1. Pull by *archetype*, never by vertical — comparison table first, no images.
2. Images for the best two only, and only for the one hard step.
3. Write `docs/flows/<name>-reference.md`: the convergent pattern, where they
   diverge and why, a recommended sequence for us, mapped onto our stores and
   routes.
4. Build in a **fresh session** against the markdown, not against the screenshots.
5. Ask: did this close a version toggle?

**Build note applying to every flow.** Devanagari runs ~30% wider than the same
English string and needs more line-height (`UX-PRINCIPLES.md` §0.1). A layout
traced tightly from a reference will overflow in Hindi. Give text containers slack
rather than fixed heights. A build detail — not a filter on which references are
worth studying.

**What this exercise cannot do.** It cannot tell us what is wrong with what we
already shipped. That is what the competitor 1–2★ review datasets in
`research/competitors/` are for. References for building; reviews for auditing.
Different instruments, not substitutes.
