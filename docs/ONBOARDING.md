# Onboarding: the one file

**V3 is built (2026-10-17).** Designed as a clickable prototype first and approved by the user before any
code changed: https://claude.ai/artifact/UPsKkkZ8Wo8x3F1XuDQgpt (local copy:
`C:\Projects\parentveda-onboarding-preview\index.html`). It has not been walked on a phone yet.

This file replaces `ONBOARDING-AUDIT.md`, `ONBOARDING-V2.md` and `design-prompts/ONBOARDING-DESIGN-PROMPT.md`.
The audit and V2 are kept below as History A and B, word for word. The design prompt is deleted: it
briefed the old `AuthFlowScreen`, which was replaced on 2026-09-22.

Code: `lib/screens/auth/onboarding/` (`onboarding_flow.dart`, `onboarding_questions.dart`,
`onboarding_chrome.dart`, `onboarding_art.dart`). Tests: `test/onboarding_flow_test.dart`,
`test/onboarding_schema_contract_test.dart`, `test/family_profile_bucket_test.dart`.

---

## 1. Why V3

The user, 2026-10-17: "our onboarding sucks… specifically the data user has provided. I don't think we are
using it", and "users should not feel like they wasted their time". Reading the code agreed:

- Several answers were saved and never read: regular periods, folic acid, the skilling interests and time,
  the care role, and the reminders switch (STILL-OPEN §79.4).
- **Bug B1:** the parenting feeding and sleep answers were wiped when the child was created. They were written
  to single-value fields, the per-child bucket stored only the sets, and `addChild` loaded an empty bucket for
  the new child. Fixed in `family_profile.dart` (`setFeeding`/`setSleep` fill the set; the `'_none'` bucket
  is carried onto the first child).
- Trying asked "how long have you been trying" twice (here and in the TTC intro) with different options, had
  no reveal, and asked a couple who had not started how long they had been trying.
- The due date's source never reached the cloud, so a new phone treated a clinic's date as our estimate.
- A father without her code had no way in.

**The rule V3 keeps:** every answer has a reader, and the reveal shows each one coming back.

## 2. The flow

- **Shared:** Welcome → Privacy → Who (Mother / Partner) → [Partner: "I have her code" → the old pairing
  screen, or "Set up on my own"] → Stage → Name → Hello.
- **Trying (her):** Where are you (Getting ready + month / On our own / With a clinic + kind) → Last period →
  Regular? → Promise → How long + her age band (not for Getting ready) → Folic acid → Building → Reveal (one
  per path) → Account → Reach.
- **Pregnancy:** Dates (4 ways in; scan weeks; embryo day; twins) → Week → First pregnancy? (+ optional
  "gentle") → Priorities → Promise → Diet → Building → Reveal → Account → Reach.
- **Parenting:** Child (+ twins, + another child) → Week → Feeding → Sleep → Promise → Priorities →
  Building → Reveal → Account → Reach.
- **Skilling:** Child (age + optional birthday) → Interests → Time → Building → Reveal → Account → Reach.
- **The partner on his own. The rule: never ask him about her body.** No period, cycle, loss history, birth
  mode or diet.
  - Trying: Where are you two → How long + her age → Promise → About him (his age, his habits) → What helps
    him → Building → his Reveal → Account → **Link with her** → Reach.
  - Pregnancy: the date page without "Last period" → Week → First baby? (his) → Promise → What helps him → …
    → Link with her → Reach.
  - Parenting: her child screen without the birth-mode and role rows.
- **The TTC intro is the film only.** Its language, period, how-long and path steps are commented out, kept
  for revert. **No language question anywhere (the user: "NO LANGUAGE QUES! It's only English").**

## 3. Every answer, where it is saved, and what reads it

| Answer | Saved | Read by |
|---|---|---|
| Where are you (trying) | `ttc_journeys.path` (on our own / clinic kind); Getting ready = `ttc_duration=planning` + `TtcReadyPlanStore.plannedStart` | `TtcStore.journeyStart`, the Ready-to-Try plan, You, the reveal |
| Last period | `CycleStore.logPeriodStart` | the cycle engine; the reveal's window comes from the same engine (`_ttcWindow`) |
| Regular? = no | `family_profile.other.ttc_cycles` | **New reader:** `TtcJourneyState.statedIrregular`, irregular until three cycles are logged |
| How long | `other.ttc_duration` + `TtcStore.setJourneyStart` (0/3/9/18 months, the intro's bands) | seek-help timing |
| Her age band | `TtcFertilityHelpStore.ageBand` | every TTC tool that asks; the give-back and reveal |
| Folic acid | `TtcSupplementsStore` ("Folic acid", ticked when yes) | her supplements list; the plan's prefill |
| Dates (pregnancy) | `profiles.due_date`, **`due_date_source`, `dating_date` (0102)** | the week; clinic-owned dates are never recalculated, now on a new phone too |
| Twins (pregnancy) | `ReadyBirthContextStore.setTwins` | `FamilyProfileStore.expectingTwins` |
| Gentle | `family_profile.gentle` (blob) | **New readers:** no "weeks to go" on the pregnancy hero; loss reads out of the home feed (`gentleHides`). Not sent to Ask Veda (the user, 2026-10-17). "A hard birth" has no reader yet |
| Child | `children` row, **`birth_mode`, `born_weeks` (0102, behind `kChildBirthColumns`)** | the family profile, which falls back to the child's copy on the other parent's phone |
| Feeding, sleep | family profile, per child | recommendations, Ask Veda context (bug B1 fixed) |
| Twins (child), second child | `setBirth(multiple:)`, a second `children` row | the child switcher |
| Care role = father | `profiles.role`, `user_role` | **New reader:** the splash routes him as the father |
| Skilling interests, time | `other.sk_interests`, `other.sk_time` | **New reader:** `skFirstActivity`, on the reveal and the skilling home |
| Skilling birthday | the real `dob` (was always "today, N years ago") | the age band |
| His age, habits | `TtcReadyPlanStore.setHisAnswers` | his part of the Ready-to-Try plan |
| What helps him | `family_profile.fatherHelp` (blob, his order) | **New readers:** `ttcHisDoorsFirst(help:)`, `pregPartnerOrder` |
| Reminders | the OS permission, and **`TtcMessagesStore.setPhoneOn`** (closes §79.4); Getting ready also turns on the plan's monthly note | phone messages |

## 4. Backend (migration 0102, `supabase/migrations/0102_onboarding_v3.sql`)

- `profiles.due_date_source`, `profiles.dating_date`. Written by `PregnancyController.setDueDate` as a
  **separate** update, so a database without 0102 loses only these and never the due date.
- `children.birth_mode`, `children.born_weeks`. The app sends them only once `kChildBirthColumns` is flipped
  to true, **after 0102 is run** (the `sex_given` pattern).
- `ttc_ready_plans`: one row per person, couple-readable, own-row writes, four policies (not one `for all`,
  which would let the partner delete her row), the 0100 newer-wins guard. `TtcReadyPlanStore` syncs to it
  with `TtcSyncedStore`; the edit time decides newer wins.
- `link_as_partner` refuses instead of re-pairing anyone already linked to someone else. Both directions use
  it now: her Partner screen has "Did he send you a code?", through `SupabaseRepo.linkAsPartner`.
- No columns for her age band, gentle, twins or what helps him: they ride in the family profile's
  `user_state` blob. The reason is in BACKEND-PATTERNS §16jj.

## 5. Look and motion

- **No lavender, onboarding only (the user's choice).** `kObPalette` in `onboarding_chrome.dart`: white
  ground, `#F2F2F1` surfaceAlt, neutral greys, ink for actions, underlined Terms/Privacy links. Onboarding has
  its own choice tile and progress bar in the same shape as the shared ones, because `PvChoiceTile` and
  `PvQuestionProgress` carry a violet cast and are app-wide. The lilac art hues became sage and sand.
  **The rest of the app is unchanged.**
- **Motion** (built-in widgets only, every one off when the phone asks for less motion): the tick draws on
  with a haptic; the give-back fades in after the tap; the progress bar grows from the last step; the week
  counts up on the week beat; building ticks follow their work; the reveal headline settles and its lines
  arrive one by one; the account rows tick in; the reminder preview arrives.

## 6. Open

- **The first arrival home** (the user's third ask): prototype it first, then build. Not in this build.
- **A planner who logs a period** gets the cycle chapter, because `preparingTogether` only shows with no cycle
  data (`ttc_chapter.dart`). Switching the chapter alone would bring back the "two clocks" bug of 2026-09-27
  (the hero showing fertile days while the chapter says preparing). It needs a getting-ready mode for the
  whole TTC home. That is a design decision.
- **"A hard birth"** is asked and saved but nothing reads it yet.
- **Editing the new answers later on You** (gentle, what helps him, the age band) is not built.
- **His plan card** reads his partner's `ttc_ready_plans` row: the table and sync exist, the card does not
  (§92.0).
- **The You screen's language switch** still exists (`pv_you_screen.dart` `_languageRow`). Onboarding no
  longer asks; whether You keeps it is the user's call.
- **Unpairing** from her side still goes through Help.
- The returning-user path, phone sign-in, and the stage-change flows (born, pregnant, loss) are unchanged.
- Run 0102, then flip `kChildBirthColumns`. Walk all paths on a phone (BEFORE-LAUNCH).

---


## History A: the Mobbin audit and the first decision (was `ONBOARDING-AUDIT.md`, 2026-09-16)

Kept word for word. Section numbers below are this history's own.

## Onboarding — the Mobbin audit, the decision, and the brief

**Written 2026-09-16.** First piece of work done with the Mobbin MCP. Read this
before touching `lib/screens/auth/auth_flow_screen.dart` or briefing Claude
Design on a first-run screen.

Three things live here, in order: what shipped apps actually do (§2–§3), what we
decided and why (§4–§5), and the paste-ready brief for Claude Design (§7). The
reference screenshots are in `research/mobbin/onboarding/` (gitignored — Mobbin
URLs expire in 30 days, so they were downloaded; the index at the end of this
file has the permanent Mobbin links).

---

### 1. What Mobbin can and cannot do for this

**How it was used.** Three tools: `search_flows` (a whole recorded walk through
an app, every screen in order), `search_screens` (single screens by
description), `search_sections` (web only, not used). A flow query returns
~9 low-res previews inline plus a high-res URL per screen; ~10k tokens a flow.
The whole audit below was 15 queries.

**What is in the library, and what is not.** Flo, Clue, Headspace, Oura and
Apple Health are in, with full pregnancy / cycle flows. **Ovia, Glow,
Huckleberry, BabyCenter and What to Expect are not** — searching their names
falls through to junk (Mindvalley, an HR app). So the audit is by *pattern*,
not by "the parenting apps", and the parenting-specific patterns (baby name +
birthday) came from adjacent apps (GoHenry's child setup) rather than a baby
tracker. Worth knowing before the next audit: **name the flow the way Mobbin
names it** ("onboarding", "logging in", "setting up") — "Clue onboarding
choosing a mode" returned the mode-switch flow, "Clue onboarding" returned the
first run.

**What it does not tell us.** Whether any of it works. Flo's onboarding is 46
screens and ends on a paywall; that is a decision Flo made with Flo's data. The
judgement below is ours, filtered through `UX-PRINCIPLES.md` Part 0 — anxious,
exhausted, first-timer, marketed-at, wide literacy — and the standing rules
(derive never ask, never a personalised probability, calm is a feature).

---

### 2. What we ask today

From `auth_flow_screen.dart` (2,708 lines, the "Soft solid" Claude Design of
2026-07, Plus Jakarta Sans and `#7C3FC4` — **both since retired by
`DESIGN-SYSTEM.md` §2.2**, so the screen is already off-system):

```
welcome ─► login | signup (email + password; Google / Apple / Facebook)
        ─► role (mother | father)
             father ─► pairCode ─► pairing ─► paired ─► home
             mother ─► profile ─► success ─► home
```

The `profile` step is one dense glass card: stage (three buttons — Trying /
Pregnant / New parent 0–2), a mandatory date with a "calculate" link, the
WhatsApp opt-in with a phone field, and *Finish setup*. Plus `employer`
(enterprise activation), `forgot → otp → reset`, `confirm` (email), and a
doctor entry. It writes `profiles` (name, role, due_date, phone, wa_opt_in) and
`LifeStageStore`.

What it asks that we could derive: her **name** (Google gives it) and her
**email** (Google gives it). What it asks in the wrong shape: **everything on
one card**, so the stage, the date and the WhatsApp consent compete for the
same tap. What it never does: **show her anything back** — the flow ends on a
"success" badge, not on the week she is in.

---

### 3. The comparison

Seven flows read screen by screen; the table holds the decisions, not the looks.

| | Flo | Clue | Headspace | Oura (pregnancy setup) | Apple Health (add pregnancy) | Postmates (login) | ParentVeda today |
|---|---|---|---|---|---|---|---|
| **Screens to home** | 12 + 34 | 27 | 21 | 10 (already signed in) | 13 (already signed in) | 4 | 5, one of them a form |
| **Sign-in sits** | "Log in" link on the first question; account made ~40 screens in | inside the flow ("Creating Account") | **first**, before any question — name, surname, email, password, or Apple / FB / Google | — | — | **first** — phone, with Google/Apple beneath | first, as a form |
| **Asked, one per screen** | terms · name (Skip) · *for yourself / partner code* · year of birth · *are you pregnant?* (3 pills) · goals (tiles, multi) · ~30 health Qs | terms · goals (6 illustrated tiles, multi) · … | *what's on your mind* (single, 6 rows) · mindfulness style quiz | intention (multi) · privacy · LMP date | dating method (4 radio rows) · date | phone · 4-digit OTP | stage + date + WhatsApp on one card |
| **Derived / offered** | "We started with a 5-day period — adjust" | — | — | "If you're not sure, you can estimate" | EDD = 40 weeks from LMP, computed | "Welcome back, Sam" from the number | nothing |
| **Notification ask** | **after** showing "Your next period will start around March 29", with the real notification drawn on screen | — | — | — | — | — | never in onboarding |
| **First thing shown back** | "Creating your personal program… 29%" → Today with the week ring | empty ring: *Track your period to get started* + "We're here to support you" preview | recommended course with **"Why this recommendation"** | **"11 weeks 3 days · 2nd trimester in 18 days"** | "0 days · First trimester · Due Jul 2" | home | a success badge |
| **Paywall** | end of onboarding | none seen | inside the flow | — | — | — | — |
| **Consent copy** | own screen, two pre-ticked rows, "Your body. Your data" | own screen, three ticked rows | one line under the form | own screen, long | one line under the date | one line under the phone field, names WhatsApp | one line |

**Where they disagree, and what the disagreement tells us:**

1. **Sign-in first vs. sign-in late.** Headspace and Postmates authenticate on
   screen one; Flo delays the account by 40 screens and lets you answer
   everything first. Flo can do that because its questions *are* the product
   (the teardown's "questionnaire is content delivery"). Ours are not — we
   have four questions, and the app's value is on the other side of them. So:
   **sign-in first, and make it one tap.** The Sesame / Wispr Flow / Saily
   welcome screens are the shape: one sentence, two buttons, one line of terms,
   nothing else.
2. **One question per screen, always.** Every app in the table does it,
   including the ones with 30 questions. Big targets, no chrome, the question
   in display type. Our one-card profile is the only exception in the set.
3. **The value beat before the permission beat.** Flo shows the computed date
   and *then* asks for notifications; MyFitnessPal shows "your daily goal is
   2,930" with the opt-ins beneath it; Oura ends setup on "11 weeks 3 days".
   Nobody asks for a permission before showing something that makes the
   permission worth granting. **This is our derive-never-ask rule applied to
   consent.**
4. **A named beat.** Flo's "Nice to meet you, jane!" is a screen with no
   question on it. It costs one tap and it is the moment the app stops being a
   form. We get her name from Google, so ours can be the first screen after
   sign-in — free.
5. **The escape hatch on the date.** Oura: "If you're not sure, you can
   estimate." Apple: four ways to date a pregnancy, including embryo transfer.
   Both map exactly onto `DueDateSource` and the TTC "I don't know" rule.
6. **Phone + OTP is a solved shape.** Postmates / Zip / Opal: a country-coded
   phone field, one line of consent that names the channels (Postmates says
   *WhatsApp* explicitly), then 4–6 boxes that fill themselves from the SMS.
   "Welcome back, Sam" on the OTP screen because the number already knew him.
7. **What we decline.** Flo's paywall at the end of onboarding, the 46-screen
   length, the "Creating your personal program… 29%" theatre (a fake loader on
   an anxious user), and pre-ticked consent boxes. Clue's empty-ring first home
   — the reveal must be full, never "add data to get started".

---

### 4. The decision — our flow

**Seven screens for a pregnant mother, five of them a single question, one a
beat, one a reveal.** Down from a form. Every ask names what it unlocks.

> The one-line version, agreed 2026-09-16: **Sesame's welcome, Flo's
> questions, Apple's date, Oura's reveal, Flo's permission ask, our home.**

```
 1  Welcome        one line · [Continue with Google] · terms line
                   footer: I'm a doctor · Have a code?
    (OS sheet)     Google account picker
 2  Hello          "Nice to meet you, Priya."  ← name from Google, small "not you? edit"
 3  Who            Which of you is this?   [ Mother ]  [ Partner ]     (two illustrated cards)
                   Partner ─► existing pairCode ─► pairing ─► paired ─► father home
 4  Stage          Where are you right now?  four tiles, one tap, no Continue
                   Trying to conceive · Pregnant · Parent (0–5) · Skilling (a child 6+)
 5  Date           varies by stage — see below
 6  Reveal         the one fact we can now compute, full-screen, in display type
 7  Reach          How should we reach you?  two rows: reminders on this phone · WhatsApp
                   WhatsApp row opens the phone field; Continue sends the OTP; OTP is a sheet
    ─► home
```

#### Screen by screen — what it asks, what it unlocks, where it writes

| # | Screen | Ask | Unlocks (said on screen) | Writes |
|---|---|---|---|---|
| 1 | Welcome | one tap | the account that keeps her data across phones | Supabase session |
| 2 | Hello | nothing (confirm) | — | `profiles.name` from `displayName` (§22.4: her name is hers) |
| 3 | Who | mother / partner | the partner's own shell and pairing | `user_role` |
| 4 | Stage | one of four | which home she lands on, which content | `LifeStageStore` |
| 5 | Date | one date, with the method | the week / the month / the band | `due_date` + `DueDateSource`, or `ChildProfileStore.dob`, or `SkChildStore` |
| 6 | Reveal | nothing | — | — |
| 7 | Reach | two optional consents | reminders; the week's guidance on WhatsApp | `NotificationService` permission; `phone`, `wa_opt_in`, `phone_verified_at` |

#### The Date screen, per stage

- **Pregnant** — one screen, Apple's four methods as a chip row above one date
  field: *Last period* (default) · *Due date from my doctor* · *Scan date* ·
  *IVF transfer*. The chip sets `DueDateSource`, so a clinic-owned date is
  recorded as clinic-owned from the first minute (`pregnancy_dating_test.dart`
  holds this). Oura's line under the field: *Not sure? Your last period is
  enough to start — you can change it any time.*
- **Parent** — baby's name and birthday on one screen (GoHenry's shape). Name
  optional, birthday required — the leap system and every door key off it.
- **Skilling** — child's name and age, once (`SkChildStore` already says a
  child who grew up in Parenting is never asked twice). ⚠️ see §5.1.
- **Trying to conceive** — **no date screen.** There is nothing honest to
  compute from one date without cycle context, and asking for cycle data here
  would duplicate `ttc_intro_flow.dart`, which already gates `TtcHomeScreen`.
  TTC goes Stage → Reach → home, and the intro flow takes over there.

#### The Reveal, per stage

The screen with no question on it. Display type, the baby image for the week
where we have one (`assets/baby/`), one line beneath, one button.

- Pregnant — **"Week 14, day 3."** *Second trimester. Due 2 March.* (The exact
  shape of Oura's "11 weeks 3 days · 2nd trimester in 18 days".)
- Parent — **"Aarav is 7 months, 2 weeks."** *Here's what's changing this month.*
- Skilling — **"Aarav, 6."** *Here's where we start.* (the band's name)
- TTC — none; see above.

No percentages, no "chance", no "on track" — the fact and nothing else.
`ttc_clinical_review_test.dart` scans for the language and will catch a slip.

#### The Reach screen

Two rows, both off, both optional, a quiet *Not now* beneath:

- **Reminders on this phone** — toggling it triggers the OS prompt. The row
  shows the actual first notification drawn as a card (Flo / *one year*
  pattern): *"Week 15 starts tomorrow — here's what to expect."* She sees the
  thing before she is asked for it.
- **This week's guidance on WhatsApp** — toggling it opens Android's **Phone
  Number Hint** sheet (Play Services): the SIM's number, one tap, the field
  fills. No typing. One line beneath: *We'll send a code to confirm it's you.
  No marketing.* Continue sends the OTP; the six boxes come up as a bottom
  sheet and fill themselves from the SMS (SMS Retriever). **The whole phone
  step is two taps and zero keystrokes.** `smart_auth` covers both halves —
  `requestPhoneNumberHint()` and `getSmsCode()`. Dual-SIM shows two numbers;
  no SIM (tablet, eSIM edge cases) falls back to the typed field.

Why one screen for two consents: MyFitnessPal bundles three on the reveal
screen and it reads as one decision — "how do you want to hear from us" — not
two interruptions. Two separate screens would put the eighth and ninth screen
in front of her for the same question.

#### What is derived rather than asked

- Her name and email — Google.
- Her stage's home — from the stage tile, never a second question.
- The due date — from LMP, with the method recorded.
- Whether she is the partner — the Who screen, then never again.
- **Not asked at all:** partner's name (see §5.4), year of birth, goals,
  language (English is the default; the Hindi switch lives in Profile), any
  health question. Those belong inside the stage, where an answer can give
  something back.

#### Sign-in: Google only, and what that costs

You asked for one button and the audit backs it: Sesame, Wispr, Saily,
Vocabulary all ship two buttons or fewer. Trade-offs, stated:

- **Email + password goes away** (commented out, kept for revert). Anyone who
  signed up with email before launch would be stranded — there are no such
  users yet, which is why now is the time.
- **Apple.** App Store guideline 4.8: an iOS app that offers any third-party
  sign-in must also offer Sign in with Apple. On Android this does not apply,
  and the app is Android-only for now (§5.5) — **one button.** If iOS ships,
  a second button lands with it; the shape survives.
- **Account linking.** Google's address is the identity; with one provider the
  duplicate-account trap in `AUTH-SETUP.md` closes by itself.
- **Shared phones.** `social_auth.dart` already notes the Google picker
  quirk; the Hello screen's "not you?" is the recovery.

#### Phone OTP — how, and why it is not the identity

The phone is a **verified attribute**, not the login. Google is the identity;
the phone exists for WhatsApp and, later, for pairing by number. That decides
the architecture: **not Supabase phone auth** (which would make the number a
second identity and reopen the linking problem), but an Edge Function pair —
`phone-otp/send` and `phone-otp/verify` — calling MSG91, writing
`profiles.phone_verified_at` on success. MSG91 is already wired for WhatsApp,
so the provider relationship exists.

- **Channel.** SMS now. WhatsApp-OTP later — it would prove the number *has*
  WhatsApp, which is the actual question, but it needs a Meta-approved
  authentication template and we are on Meta's test number.
- **Cost.** MSG91 OTP SMS ≈ ₹0.15–0.25 / $0.002–0.003 each; WhatsApp
  authentication ≈ ₹0.125 / $0.0015. At 10,000 sign-ups: ≈ ₹2,000 / $24.
- **Auto-fill on Android** is the SMS Retriever API (`smart_auth` or
  `sms_autofill`), and it only works if the SMS body carries the app's 11-char
  hash — **so the MSG91 template must include it.** A one-sided change fails
  silently: the code arrives, nothing fills. Same shape as the Ask Veda
  contract; recorded here for the same reason.
- **Rate limit** the send function server-side (per phone, per IP) — money and
  seats are decided server-side and so is spend on SMS.

---

### 5. Decisions — taken 2026-09-16

#### 5.1 Skilling as a fourth tile — DECIDED: show it; `SkillingPreviewScreen` is its home for now

`LifeStage.skilling` was a value and not a destination: nothing wrote it, the
splash never routed to it, the only screen was `skilling_preview_screen.dart`.
**Decision (user):** the tile is shown, it writes `LifeStage.skilling`, and the
splash routes that stage to `SkillingPreviewScreen` until a real skilling home
exists. `JourneyState` keeps refusing to infer from it — that is a separate
permit and nothing here needs it. The preview screen's class doc must be
updated to say it is now reachable, and its "design preview only" caveat goes.

#### 5.2 Filled button, or the outlined pill — taken on the recommendation

One filled `action` button per screen, read as §4.3's "single primary commit"
applied per step; choice tiles are outlined. Every reference in the set does
the same.

#### 5.3 "Have a code?" — taken on the recommendation: one link, one sheet

One footer link; the sheet routes by code format to the referral engine or the
enterprise activation flow.

#### 5.4 The partner's name — taken on the recommendation: at the pairing invite

**We only ever hold a name its owner gave.** Hers from Google on screen 2; his
from his own Google on his own device. The invite she sends may carry a
nickname for the pairing message; nothing leaving the phone uses it. Closes
STILL-OPEN §22.4's open point.

#### 5.5 iOS — DECIDED: Android only for now

One button on the welcome screen. Sign in with Apple lands with an iOS build,
if and when there is one.

#### 5.6 The phone — DECIDED: in onboarding, after the reveal, essential

The number is a business requirement (WhatsApp is the retention channel), so
it stays on screen 7, made as cheap as a tap by the Phone Number Hint sheet.
**Open point, recorded for after the app is done:** asking on day 3 — inside
the app, at the first moment there is something concrete to send — as an
A/B against the onboarding ask. Not now.

---

### 6. What the build touches — for after the design lands

- **New** `lib/screens/auth/onboarding_flow.dart` (or one file per screen
  under `lib/screens/auth/onboarding/`). The old `AuthFlowScreen` stays,
  commented at the call site in `splash_screen.dart` — kept for revert.
- **Kept and reused:** the father pairing screens, `PendingProfile`,
  `WhatsAppPrefs.fieldsFor`, `SocialAuth`, `DoctorSession`, the referral /
  activation sheets, the `kAuthCompletedKey` / `kUserRoleKey` contract the
  splash reads.
- **New service:** `phone-otp` Edge Function pair + migration adding
  `profiles.phone_verified_at` (+ rate-limit table). Pattern belongs in
  `BACKEND-PATTERNS.md` — "a verified attribute is not an identity".
- **New dependency:** `smart_auth` — Phone Number Hint + SMS Retriever;
  `google_sign_in ^7.2` is in.
- **Skilling route:** `LifeStageStore` may now write `skilling`; the splash
  routes it to `SkillingPreviewScreen`. Update that screen's class doc and the
  `LifeStage.skilling` comment in `life_stage_store.dart`, which currently
  says "nothing sets it".
- **Tests owed:** the stage→date→reveal mapping per stage; `DueDateSource`
  set from the chip; the TTC path having no date screen; the splash still
  routing on the same two keys; a reachability test that the new flow is what
  the splash pushes (the wiring gate).
- **Ask Veda:** nothing. No request-body change.

---

### 7. The brief for Claude Design — paste from here

> **ParentVeda — first-run onboarding, seven screens.** Mobile, 390×844.
> Use the ParentVeda design system already in the project: ground `#F5F3F6`,
> surface `#FFFFFF`, surfaceAlt `#EDEAF0`, line 8% black, ink1 `#201C24`,
> ink2 `#5B5464`, ink3 `#8B8494`, action `#6A30B6` for eyebrows, links and
> the single primary button per screen. Fraunces 600 for every question and
> the one fact; Manrope for everything else. Shadow `#D0C8DC`, never grey.
> No decorative emoji; line icons only. No gradients, no glass, no floating
> dots — this replaces the purple "Soft solid" auth screens.
>
> **Tone.** Calm, one thing per screen, generous whitespace, the question in
> display type in the upper third, the answers as large thumb-reachable
> targets. Nothing that counts, scores or hurries.
>
> **Screens.**
> 1. **Welcome** — the mark, one sentence ("For the whole journey — trying,
>    expecting, raising."), **one** filled button *Continue with Google* with
>    the Google mark (Android only — no Apple, no email), one line of terms in
>    ink3. Footer, two quiet links: *I'm a
>    doctor* · *Have a code?* Reference: Sesame / Wispr Flow welcome (two
>    buttons, nothing else).
> 2. **Hello** — "Nice to meet you, Priya." in Fraunces display, the name in
>    action colour, a small *Not Priya? Edit* beneath, one button *Continue*.
>    Reference: Flo's "Nice to meet you, jane!" beat.
> 3. **Who** — "Which of you is this?" Two illustrated cards side by side,
>    *Mother* / *Partner*, radio beneath each, drawn in the app's line-art
>    family. Reference: TikTok Family Pairing (Parent / Teen).
> 4. **Stage** — "Where are you right now?" Four tiles in a 2×2, each with a
>    line icon, a title and a two-word subtitle: *Trying to conceive* ·
>    *Pregnant* · *Parent — 0 to 5* · *Skilling — 6 and up*. Tapping advances;
>    no Continue, no progress bar anywhere in the flow. Reference: Clue's
>    goal tiles, Flo's three pills.
> 5. **Date (pregnant)** — "When is the baby due?" A chip row: *Last period*
>    (selected) · *Doctor's date* · *Scan date* · *IVF transfer*. One date
>    field. A line in ink3: *Not sure? Your last period is enough to start.*
>    Reference: Apple Health's dating methods, Oura's "you can estimate".
>    Also draw the **Parent** variant: "Tell us about your baby" — name
>    (optional) and birthday.
> 6. **Reveal** — no question. The week's baby image centred, "Week 14, day 3."
>    in display type, *Second trimester · Due 2 March* in ink2, one button
>    *Let's begin*. Reference: Oura "11 weeks 3 days · 2nd trimester in 18 days".
>    Also draw the Parent variant: "Aarav is 7 months, 2 weeks."
> 7. **Reach** — "How should we reach you?" Two rows as cards with a switch:
>    *Reminders on this phone* with the first notification drawn beneath it as
>    a real notification card; *This week's guidance on WhatsApp* which, when
>    on, reveals a +91 phone field already filled from the phone's SIM (draw
>    it filled, with a small *Use a different number* link) and the line
>    *We'll send a code to confirm it's you. No marketing.* Button *Continue*,
>    quiet link *Not now*.
>    Reference: Flo's "next period around March 29" notification screen,
>    *one year*'s "plant a memory everyday, can we remind you?".
>    Also draw the **OTP sheet**: six boxes, "We sent a code to +91 98••• ••210",
>    *Resend in 30s*, filling itself. Reference: Opal / Zip.
>
> Show all seven as one horizontal flow with the Partner branch (screen 3 →
> the existing pairing-code screen) drawn as a stub.

---

### 8. Reference index — permanent links

Local files in `research/mobbin/onboarding/` (gitignored). Each Mobbin link is
the canonical one and does not expire.

| File(s) | App · flow | Proves |
|---|---|---|
| `flo-onb-01..12` | [Flo · Onboarding](https://mobbin.com/flows/d64dd348-5de3-40d0-8e2a-1fa781dad065) | one question per screen; the name beat; *for yourself / partner code*; three-pill stage question |
| — (not downloaded; 34 screens) | [Flo · Completing account setup](https://mobbin.com/flows/541b7fd0-025b-417a-8d74-0185217879ff) | how long it really is; the notification-after-value screen; the paywall we decline |
| `clue-onb-01..08` | [Clue · Onboarding](https://mobbin.com/flows/81768b19-ba24-44c3-9846-8a46a78f6e0d) | consent as its own screen; illustrated goal tiles; the empty first home we decline |
| `headspace-onb-01..08` | [Headspace · Onboarding](https://mobbin.com/flows/31b21791-dec6-448a-8253-648f5ebbba3e) | sign-in first; "Why this recommendation" |
| `oura-preg-01..10` | [Oura · Setting up pregnancy](https://mobbin.com/flows/a4d79fae-9e02-4870-b2eb-48076280e99b) | "If you're not sure, you can estimate"; the "11 weeks 3 days" reveal |
| `apple-preg-01..10` | [Apple Health · Adding a pregnancy](https://mobbin.com/flows/d0b0ae08-53d2-418e-9439-c7ace1f7dc31) | four dating methods incl. embryo transfer = `DueDateSource` |
| `postmates-login-01..04` | [Postmates · Logging in](https://mobbin.com/flows/5b01b091-6714-422e-a1e4-4b244642774a) | phone first, Google/Apple beneath, consent names WhatsApp, "Welcome back, Sam" |
| `zip-otp-02`, `opal-otp-02` | [Zip](https://mobbin.com/flows/a08f720f-a5a0-4a66-affc-869ee511a45b) · [Opal](https://mobbin.com/flows/87656285-6f69-45e6-817f-febb1b52c342) | six-box OTP with auto-fill from Messages |
| `welcome-sesame`, `welcome-wispr`, `welcome-saily` | [Sesame](https://mobbin.com/screens/359eeff7-962b-49df-bda6-f3e68e6c094f) · [Wispr Flow](https://mobbin.com/screens/b13d07d8-9c54-4900-b67e-82b33b7fb1cd) · [Saily](https://mobbin.com/screens/c311826f-3415-4e3f-99ac-d53f0793799c) | the one-sentence, two-button welcome |
| `notif-wysa`, `notif-oneyear`, `notif-gentler` | [Wysa](https://mobbin.com/screens/ff59c484-845f-4eb0-a383-8be9c465b5fc) · [one year](https://mobbin.com/screens/c9f47bf4-f948-4353-b668-d6bfad31463e) · [Gentler Streak](https://mobbin.com/screens/40740abe-04b9-4d43-a601-e9c521f3d6f5) | the pre-permission screen with the notification drawn, and a real *Not now* |
| `role-tiktok`, `role-substack` | [TikTok Family Pairing](https://mobbin.com/screens/3ee374c7-be6d-4996-bdac-c2fa8047b92c) · [Substack](https://mobbin.com/screens/fbb0f72a-66db-4e8b-beb0-dd79ddf29a11) | two illustrated cards for a two-way role question |
| `reveal-mfp` | [MyFitnessPal](https://mobbin.com/screens/cc3afa32-4262-4b9d-b3c2-f898b59ac935) | the computed fact with the opt-ins beneath it |

**Queries that worked, for the next audit:** `"<App> onboarding"`,
`"<App> logging in"`, and pattern descriptions of one screen — "pre-permission
screen explaining why the app wants to send reminders", "onboarding result
screen revealing something computed from the answers". Queries that did not:
app names Mobbin does not carry, and two intents in one sentence.

---

## History B: V2, the research, the flow and the art prompts (was `ONBOARDING-V2.md`, 2026-09-22)

Kept word for word, including the art prompts.

## Onboarding V2 — the research, the flow, and the art it needs

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

### 0. First, a wiring fact that changes what "bland" means

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

### 1. What the good ones actually do

Fourteen flows read on Mobbin: Headspace, Flo, Noom, Lifesum, Yazio, Hers,
MyFitnessPal, Calm Sleep, pliability, Replika, BitePal, Superpower, Stardust,
Ten Percent Happier, Life Reset, Liven, Mimo, Speak, MacroFactor.

Seven patterns, ranked by how much they would change ours:

#### 1.1 ASK BEFORE YOU AUTHENTICATE — the structural one

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

#### 1.2 ONE QUESTION, ONE SCREEN, A BAR AT THE TOP

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

#### 1.3 THE ANSWER ANSWERS BACK

Headspace's *"That's great to hear"* is a whole screen after an answer.
BitePal ticks each choice green as you tap. Our `ObOption.giveBack` already
does the line version and the audit was right to build it — what is missing
is the **full beat**, two or three times across the flow, where the app stops
and says something back in its own voice.

#### 1.4 THE CURVED BAND — Headspace's actual signature

Look at any Headspace screen: a saturated colour field at the top holding one
simple illustration, its bottom edge a **curve**, white content below. That
curve is doing almost all of the warmth. It is one clip path and it is the
single highest-leverage visual change available to us.

#### 1.5 "BUILDING YOUR PLAN"

Flo (a ring counting to 100%), Noom (seven named sections cross-checking),
Lifesum, Life Reset, Liven, Ten Percent Happier, Mimo, Speak. All of them.

It is theatre — but it is **honest** theatre if the work named is work that
actually happens. Noom's version is the model: it names the sections rather
than spinning a generic loader. Ours can name the real things: the week, the
stage, her questions' answers, the reads chosen for her.

#### 1.6 THE REVEAL

Flo's *"Your personal pregnancy program"* — six lines of what she now gets.
MacroFactor's checklist. This is the payoff the questions bought, and we
already have a `reveal` step; it just needs to be built out of **her own
answers** rather than a fixed list.

#### 1.7 PRIVACY, SAID EARLY AND PLAINLY

Flo gives it a whole screen — *"Your body. Your data"* — with a shield and
two explicit consents. For an India-first family health app holding a due
date, a child's name and symptom logs, this is not boilerplate; it is one of
the few things we can say that a competitor cannot say as easily, because
local-first is genuinely how this app is built.

#### What we are NOT taking

| Seen | Why not |
|---|---|
| Noom's 30+ questions | Ours must stay short enough that nobody abandons. Two or three per stage, as the audit priced. |
| BitePal / Speak / Mimo mascots | A cartoon raccoon cannot hold a miscarriage conversation. This app talks to women at 2 a.m. |
| Stardust's astrology framing | Charming, and it is a horoscope. Clinical invariants. |
| A paywall in onboarding | Money is decided server-side and later. |
| Any invented statistic | See §0. |

---

### 2. The flow

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

### 3. The art — ten images, and the prompts for them

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

#### The ten

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

### 3b. What was built — 2026-09-22

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

### 4. Open, and owed

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
