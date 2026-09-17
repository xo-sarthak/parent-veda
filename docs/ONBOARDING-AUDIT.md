# Onboarding — the Mobbin audit, the decision, and the brief

**Written 2026-09-16.** First piece of work done with the Mobbin MCP. Read this
before touching `lib/screens/auth/auth_flow_screen.dart` or briefing Claude
Design on a first-run screen.

Three things live here, in order: what shipped apps actually do (§2–§3), what we
decided and why (§4–§5), and the paste-ready brief for Claude Design (§7). The
reference screenshots are in `research/mobbin/onboarding/` (gitignored — Mobbin
URLs expire in 30 days, so they were downloaded; the index at the end of this
file has the permanent Mobbin links).

---

## 1. What Mobbin can and cannot do for this

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

## 2. What we ask today

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

## 3. The comparison

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

## 4. The decision — our flow

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

### Screen by screen — what it asks, what it unlocks, where it writes

| # | Screen | Ask | Unlocks (said on screen) | Writes |
|---|---|---|---|---|
| 1 | Welcome | one tap | the account that keeps her data across phones | Supabase session |
| 2 | Hello | nothing (confirm) | — | `profiles.name` from `displayName` (§22.4: her name is hers) |
| 3 | Who | mother / partner | the partner's own shell and pairing | `user_role` |
| 4 | Stage | one of four | which home she lands on, which content | `LifeStageStore` |
| 5 | Date | one date, with the method | the week / the month / the band | `due_date` + `DueDateSource`, or `ChildProfileStore.dob`, or `SkChildStore` |
| 6 | Reveal | nothing | — | — |
| 7 | Reach | two optional consents | reminders; the week's guidance on WhatsApp | `NotificationService` permission; `phone`, `wa_opt_in`, `phone_verified_at` |

### The Date screen, per stage

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

### The Reveal, per stage

The screen with no question on it. Display type, the baby image for the week
where we have one (`assets/baby/`), one line beneath, one button.

- Pregnant — **"Week 14, day 3."** *Second trimester. Due 2 March.* (The exact
  shape of Oura's "11 weeks 3 days · 2nd trimester in 18 days".)
- Parent — **"Aarav is 7 months, 2 weeks."** *Here's what's changing this month.*
- Skilling — **"Aarav, 6."** *Here's where we start.* (the band's name)
- TTC — none; see above.

No percentages, no "chance", no "on track" — the fact and nothing else.
`ttc_clinical_review_test.dart` scans for the language and will catch a slip.

### The Reach screen

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

### What is derived rather than asked

- Her name and email — Google.
- Her stage's home — from the stage tile, never a second question.
- The due date — from LMP, with the method recorded.
- Whether she is the partner — the Who screen, then never again.
- **Not asked at all:** partner's name (see §5.4), year of birth, goals,
  language (English is the default; the Hindi switch lives in Profile), any
  health question. Those belong inside the stage, where an answer can give
  something back.

### Sign-in: Google only, and what that costs

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

### Phone OTP — how, and why it is not the identity

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

## 5. Decisions — taken 2026-09-16

### 5.1 Skilling as a fourth tile — DECIDED: show it; `SkillingPreviewScreen` is its home for now

`LifeStage.skilling` was a value and not a destination: nothing wrote it, the
splash never routed to it, the only screen was `skilling_preview_screen.dart`.
**Decision (user):** the tile is shown, it writes `LifeStage.skilling`, and the
splash routes that stage to `SkillingPreviewScreen` until a real skilling home
exists. `JourneyState` keeps refusing to infer from it — that is a separate
permit and nothing here needs it. The preview screen's class doc must be
updated to say it is now reachable, and its "design preview only" caveat goes.

### 5.2 Filled button, or the outlined pill — taken on the recommendation

One filled `action` button per screen, read as §4.3's "single primary commit"
applied per step; choice tiles are outlined. Every reference in the set does
the same.

### 5.3 "Have a code?" — taken on the recommendation: one link, one sheet

One footer link; the sheet routes by code format to the referral engine or the
enterprise activation flow.

### 5.4 The partner's name — taken on the recommendation: at the pairing invite

**We only ever hold a name its owner gave.** Hers from Google on screen 2; his
from his own Google on his own device. The invite she sends may carry a
nickname for the pairing message; nothing leaving the phone uses it. Closes
STILL-OPEN §22.4's open point.

### 5.5 iOS — DECIDED: Android only for now

One button on the welcome screen. Sign in with Apple lands with an iOS build,
if and when there is one.

### 5.6 The phone — DECIDED: in onboarding, after the reveal, essential

The number is a business requirement (WhatsApp is the retention channel), so
it stays on screen 7, made as cheap as a tap by the Phone Number Hint sheet.
**Open point, recorded for after the app is done:** asking on day 3 — inside
the app, at the first moment there is something concrete to send — as an
A/B against the onboarding ask. Not now.

---

## 6. What the build touches — for after the design lands

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

## 7. The brief for Claude Design — paste from here

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

## 8. Reference index — permanent links

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
