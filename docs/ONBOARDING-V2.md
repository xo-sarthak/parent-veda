# Onboarding V2 — the research, the flow, and the art it needs

**2026-09-22.** The user, on the phone: *"this particular screen for the
onboarding flow does not look good and what we created before is very bland
… I have seen really good applications having very creative onboarding flows
like Headspace. Do a very deep research to create a really good onboarding
flow for us. The onboarding flow consists of questions, personalization and
everything, because we need deep personalization — that is what we are
offering in our application."*

This is the research it was built on, the flow that came out of it, and the
list of images it needs with the prompts to generate them.

---

## 0. First, a wiring fact that changes what "bland" means

The screen in the user's screenshot — heavy violet, *"Care that grows with
your family"*, *"Loved by 50,000+ parents"*, Create account / Log in /
Google — **is not the onboarding we built.** It is the old
`AuthFlowScreen` (`lib/screens/auth/auth_flow_screen.dart`).

`SplashScreen` pushes `OnboardingFlow` and the old push beside it is
commented out, so a **fresh install** gets the new flow. But three other
doors still open the old one:

| Where | Line |
|---|---|
| Sign out | `lib/screens/profile/pv_account_actions.dart:53` |
| "Sign in to see your bookings" | `lib/screens/post_pregnancy/my_bookings_screen.dart:654` |
| The old profile screen | `lib/screens/profile_screen.dart:749` |

So the most likely way to see that screenshot today is to **sign out** — and
the second-worst outcome of this whole piece of work would be to build a
beautiful onboarding that half the doors do not open. The wiring gate
applies: every entry point lands on one flow.

⚠️ **"Loved by 50,000+ parents" has to go regardless.** This app refuses to
draw a distribution bar it cannot measure (`pv_reviews_screen.dart`) and
refuses to state a personalised probability (`ttc_clinical_review_test.dart`).
A founder-invented user count on the very first screen contradicts both. If
the number is real it can stay with a source; if it is aspirational it is a
number we made up, on the screen where trust is cheapest to lose.

---

## 1. What the good ones actually do

Fourteen flows read on Mobbin: Headspace, Flo, Noom, Lifesum, Yazio, Hers,
MyFitnessPal, Calm Sleep, pliability, Replika, BitePal, Superpower, Stardust,
Ten Percent Happier, Life Reset, Liven, Mimo, Speak, MacroFactor.

Seven patterns, ranked by how much they would change ours:

### 1.1 ASK BEFORE YOU AUTHENTICATE — the structural one

**Every single question-led app puts account creation at the END.** Flo asks
"Are you pregnant?" as its *first* screen, before anything. Noom runs seven
sections of questions first. Lifesum, Yazio, Hers, BitePal, MacroFactor,
Superpower — all of them ask first, sign up last.

Ours opens on Google sign-in. That is backwards, and the reason is not
fashion: a person who has answered nine questions about her pregnancy has
built something she does not want to lose, and *that* is what makes the
account worth creating. BitePal names it on the screen — **"Now let's create
account / Save your progress & reach your goals."**

We can do this without touching the backend: the app is local-first by
constitution, answers already land in `FamilyProfileStore`, and
`PendingProfile` already exists to stash a profile write that cannot reach
the cloud and replay it at the next login. The session simply happens later.

### 1.2 ONE QUESTION, ONE SCREEN, A BAR AT THE TOP

Universal. Replika, Lifesum, Superpower, BitePal, Yazio, Noom, Calm Sleep,
pliability, Hers, MyFitnessPal — every one is a single question, a stack of
full-width tappable options, and a progress bar. Nobody asks two things at
once and nobody uses a dropdown.

Two refinements worth stealing:

- **Noom labels the bar with the SECTION** ("DEMOGRAPHIC PROFILE") and shows
  seven dots, so the length is honest and the person knows which part they
  are in.
- **MyFitnessPal splits the options into "Recommended for you" and "More"** —
  personalisation visible *inside* the question, before any answer.

### 1.3 THE ANSWER ANSWERS BACK

Headspace's *"That's great to hear"* is a whole screen after an answer.
BitePal ticks each choice green as you tap. Our `ObOption.giveBack` already
does the line version and the audit was right to build it — what is missing
is the **full beat**, two or three times across the flow, where the app stops
and says something back in its own voice.

### 1.4 THE CURVED BAND — Headspace's actual signature

Look at any Headspace screen: a saturated colour field at the top holding one
simple illustration, its bottom edge a **curve**, white content below. That
curve is doing almost all of the warmth. It is one clip path and it is the
single highest-leverage visual change available to us.

### 1.5 "BUILDING YOUR PLAN"

Flo (a ring counting to 100%), Noom (seven named sections cross-checking),
Lifesum, Life Reset, Liven, Ten Percent Happier, Mimo, Speak. All of them.

It is theatre — but it is **honest** theatre if the work named is work that
actually happens. Noom's version is the model: it names the sections rather
than spinning a generic loader. Ours can name the real things: the week, the
stage, her questions' answers, the reads chosen for her.

### 1.6 THE REVEAL

Flo's *"Your personal pregnancy program"* — six lines of what she now gets.
MacroFactor's checklist. This is the payoff the questions bought, and we
already have a `reveal` step; it just needs to be built out of **her own
answers** rather than a fixed list.

### 1.7 PRIVACY, SAID EARLY AND PLAINLY

Flo gives it a whole screen — *"Your body. Your data"* — with a shield and
two explicit consents. For an India-first family health app holding a due
date, a child's name and symptom logs, this is not boilerplate; it is one of
the few things we can say that a competitor cannot say as easily, because
local-first is genuinely how this app is built.

### What we are NOT taking

| Seen | Why not |
|---|---|
| Noom's 30+ questions | Ours must stay short enough that nobody abandons. Two or three per stage, as the audit priced. |
| BitePal / Speak / Mimo mascots | A cartoon raccoon cannot hold a miscarriage conversation. This app talks to women at 2 a.m. |
| Stardust's astrology framing | Charming, and it is a horoscope. Clinical invariants. |
| A paywall in onboarding | Money is decided server-side and later. |
| Any invented statistic | See §0. |

---

## 2. The flow

Mother, pregnancy. Trying and Parenting take the same spine with their own
date step, questions and reveal.

```
 1  WELCOME          art band · "For the whole journey" · Get started / I have an account
 2  PRIVACY          art band · three plain lines · Continue
 3  WHO              Mother · Father or partner · Trying together
 4  STAGE            Trying · Pregnant · Parenting · Skilling   (four small arts)
 5  NAME             one soft field, skippable
    → BEAT 1         "Nice to meet you, Priya."
 6  DATE             method chips + date wheel   (unchanged — it works)
    → BEAT 2         "Week 14. Most women find the tiredness lifts around now."
 7  QUESTION 1       progress bar · give-back line
 8  QUESTION 2
    → BEAT 3         "What we will never do" — the no-diagnosis promise
 9  QUESTION 3
10  BUILDING         named steps, real work
11  REVEAL           built from HER answers
12  ACCOUNT          Google / phone — now there is a reason
13  REACH            notifications · WhatsApp
```

Thirteen screens. Headspace is twelve, Flo is twelve, Noom is over thirty.

**What each step writes** is unchanged from V1 (`onboarding_flow.dart`
header): the stage on `profiles`, the due date + `DueDateSource` on the
pregnancy controller, a `children` row where relevant, the answers on
`FamilyProfileStore`, the reach choices. Only the **order** moves, so the
account arrives at 12 instead of 1 and everything before it is local.

---

## 3. The art — ten images, and the prompts for them

⚠️ **This is a deliberate departure from DESIGN-SYSTEM §3.** The app's rule is
drawn marks and line icons, no illustration, because chrome should be quiet.
Onboarding is not chrome — it is the one surface whose whole job is a first
impression, and the drawn-mark family is a 100×100 utility glyph set that
cannot carry a full-bleed hero. The illustration lives in the curved band and
**stops at the app's front door**; nothing past the reveal uses it.

**House style for every prompt below** — paste this block with each one:

> Soft, warm, hand-painted editorial illustration. Flat shapes with gentle
> gouache texture, no outlines, no gradients meshes, no 3D, no photorealism.
> Calm and quiet, never cute or cartoonish — no mascots, no big-eyed
> characters, no emoji. Indian family, South Asian skin tones, contemporary
> Indian clothing (kurta, salwar, saree, plain modern wear), never sari-and-
> temple cliché. Palette: dusty rose #E8C4CE, sage #C5D6C4, warm sand
> #E8D9C0, soft lilac #D8CCE8, muted terracotta #D9A08A, off-white #F5F3F6.
> No saturated primaries, no neon. Faces simplified and serene or turned
> away; never a clinical or medical setting; never a stethoscope, chart or
> hospital. Square 1:1, subject centred with generous breathing room, plain
> flat background in one of the palette colours, no text anywhere in the
> image.

### The ten

| # | Where | Prompt (append the house style) |
|---|---|---|
| **A1** | Welcome | A woman resting one hand on a rounded pregnant belly while a man beside her rests his hand over hers, both seated close, seen from the side at a calm distance. Behind them a soft arc of warm light. Dusty rose and warm sand background. |
| **A2** | Privacy | A simple house shape drawn as a soft rounded form, with a warm light glowing inside it and two small figures visible through the window as gentle silhouettes. A softly drawn ring encircles the house like a protective boundary. Sage green background. |
| **A3** | Stage · Trying | A small seedling with two leaves in cupped open hands, seen from above. Warm sand background. Simple, small, centred. |
| **A4** | Stage · Pregnant | A rounded pregnant silhouette in profile, drawn as one soft filled shape with no facial detail, a small crescent curve inside suggesting the baby. Dusty rose background. |
| **A5** | Stage · Parenting | Two hands holding a swaddled baby bundle, seen from the side, the baby drawn as a simple wrapped form. Soft lilac background. |
| **A6** | Stage · Skilling | A child's hands stacking three wooden blocks, seen from the side. Muted terracotta background. |
| **A7** | Beat 1 · the name | A single open hand raised in a small greeting, warm and unhurried, with two soft floating shapes near it like a quiet hello. Warm sand background. |
| **A8** | Beat 2 · the week | A crescent-shaped curled form suggesting a very small baby at rest, surrounded by a soft glowing halo, abstract and gentle rather than anatomical. Dusty rose background. |
| **A9** | Beat 3 · the promise | Two open hands held palm-up side by side, offering rather than instructing, with a small steady light resting above them. Sage green background. |
| **A10** | Building · the reveal | A woman seated cross-legged and calm, reading, with several soft rounded shapes arranged around her like cards settling into place. Soft lilac background. |

**Delivery:** PNG, 1:1, at least 1200×1200, transparent OR flat background
(either works — the band supplies its own colour). Drop them in
`assets/onboarding/` named `ob_a1.png` … `ob_a10.png`.

**If a generated image is wrong, it is wrong on the subject, not the style** —
that is the lesson from the learn covers (STILL-OPEN §69.10). Look at it
before it ships.

---

## 3b. What was built — 2026-09-22

| Piece | Where |
|---|---|
| The twelve paintings and the curved band | `lib/screens/auth/onboarding/onboarding_art.dart` |
| `ObProgress` (the named bar) and `ObBeat` (the full-screen reply) | `onboarding_chrome.dart` |
| The reordered flow, six new screens | `onboarding_flow.dart` |
| A card that can wear a painting | `ObGridCard.art` / `.artHeight` |
| "Replay onboarding · testing" | the You screen's Developer section |

Three findings worth keeping:

- **Two steps were born unreachable.** The stage card still jumped straight
  to the date, so `name` and `beatHello` were built, analysed clean, and
  never once rendered. Found by reading the test that walks the path, not by
  the compiler — the wiring gate exactly. The test now asserts the name
  screen by name so it cannot happen twice.
- **The "no progress bar anywhere" rule was NARROWED, not deleted.** It is
  right for a flow of unlike screens and wrong for a contiguous run of like
  ones; `onboarding_chrome.dart`'s header carries the whole argument.
- **The who-screen was the one that did not get the treatment.** Two Material
  glyphs in pale wells between two illustrated screens — invisible in code,
  obvious on the phone, in order. Found on the device walk (§0's lesson,
  again).

Also fixed from §0: **sign out lands on `OnboardingFlow`**, not the retired
`AuthFlowScreen`. That was the single most common way to see the first-run
experience, and it was showing the old screen.

## 4. Open, and owed

- **Two of §0's three doors remain.** Sign out is done. Still on the old
  screen: `my_bookings_screen.dart:654` (the "sign in to see your bookings"
  prompt) and `profile_screen.dart:749` (the old profile). Both are
  sign-in-only prompts rather than first runs, so the right answer may be a
  sign-in SHEET rather than either flow — decide, then wire.
- **The account step has only Google.** Phone/OTP exists in the app
  (`PhoneOtp`, used by the reach step) and for this market it should be on
  this screen too.
- **The 50,000 number** needs a decision: real with a source, or gone.
- Trying and Parenting need their own **beat copy** — the pregnancy beats are
  written above, the other two stages are not.
- The reveal is currently a fixed list; building it from her answers is the
  part that makes the questions worth asking.
