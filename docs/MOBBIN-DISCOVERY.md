# Mobbin discovery — what the research produced, audit by audit

**Why this file exists.** Mobbin is a paid subscription (quarterly, to
December 2026) used through its MCP. Its output is spread across audit docs,
the family model and STILL-OPEN sections, and nothing said "this came from
Mobbin". This ledger does: for every audit, what was searched, what was
found, what was adopted, what was declined and why, and what is still owed
from it. Owed items point at their STILL-OPEN section; they are not repeated
here. Read this before starting a new audit — the queries that worked are at
the bottom, and the apps the library does not carry are listed so nobody
searches for them twice.

**How an audit runs** (the recipe, proven three times): arrive with a
question → pull flows, not screens → read the decisions, not the looks →
one comparison table → decide against our own rules (UX-PRINCIPLES Part 0,
CLAUDE.md invariants) → brief → build → this ledger.

| # | Audit | Date | Doc | Built? |
|---|---|---|---|---|
| 1 | Onboarding | 2026-09-16 | `ONBOARDING-AUDIT.md` | Yes, 2026-09-17 (`lib/screens/auth/onboarding/`) |
| 2 | Reading | 2026-09-16 | `READER-AUDIT.md` | Five additions on `PvReaderScreen`; adapters pending the user's look |
| 3 | Saved / bookmarks | 2026-09-16 | `FAMILY-MODEL.md` §5–6 | Yes (`saved_items`, `SavedScreen`) |
| 4 | Family model — stage transitions, second child, partner | 2026-09-16 | `FAMILY-MODEL.md` §2–4 | Written down; `pregnancies` table owed |
| 5 | Onboarding questions, OTP length, invite-applied state | 2026-09-17 | this file §5 | Yes, inside the onboarding build |
| 6 | Base UI — page ground, buttons, chips, cards, sheets, type | 2026-09-17 | `DESIGN-SYSTEM.md` §4.0 · `BASE-UI-DECISIONS.md` | Ground, type (Newsreader + Manrope), button theme, transitions, callouts, sheets; §2 answered; sweep owed |

---

## 1. Onboarding

**Asked.** Seven flows: Flo (onboarding + account setup), Clue, Headspace,
Oura (pregnancy setup), Apple Health (add a pregnancy), Postmates / Zip / Opal
(phone login). Plus single screens: two-button welcomes (Sesame, Wispr Flow,
Saily), notification pre-prompts (Wysa, one year, Gentler Streak), role
questions (TikTok Family Pairing, Substack), computed-fact reveals
(MyFitnessPal, Oura).

**Found.** One question per screen, always. Sign-in first when the questions
are not the product. The computed fact shown *before* any permission is
asked (Flo's "next period around March 29", Oura's "11 weeks 3 days"). A named
beat ("Nice to meet you, jane!"). Four ways to date a pregnancy, including
embryo transfer. "If you're not sure, you can estimate."

**Adopted.** All of the above, as the seven-screen flow; Google as the only
button; the reveal as the payoff; the reach screen after it; `DueDateSource`
set from the dating chip; the hello beat from the Google name.

**Declined.** Flo's 46-screen length and end-of-onboarding paywall; the
"creating your personal program… 29%" theatre; pre-ticked consent; Clue's
empty first home; any progress bar.

**Owed.** STILL-OPEN §62.1 (device walk of sign-in → OTP), §62.3 (twins,
second child), §62.4 (reveal art by week).

## 2. Reading

**Asked.** Flo Insights + Daily insights, Matter, NYT, Blinkist, Finimize,
Zocdoc, GoHenry, Atoms, Superpower, Deepstash, Moonly, Pi; reader settings
sheets (Apple Books, Fable, Matter, Brave, Liven); article foots.

**Found.** Two objects, not one: the **article** (byline with a reviewer badge,
sections, collapsed references, read-next) and the **story card** (one idea,
segmented progress, the last card is a verb). Nobody distinguishes "read
through" from "look up" at the chip — Flo's chips name the format. References
are universal in health readers and always last. "Was this helpful?" at the
foot (GoHenry). The `Aa` sheet is size + theme, rarely more.

**Adopted.** One reader (`PvReaderScreen`, the user's benchmark) and five
additions: *Reviewed by* with the verified mark on the person, References
collapsed, helpful pills, the existing tile grid kept as the related rows,
Read next as a two-card rail. One chip word, "Article" (decided, not yet
applied). Four models converge on `PvRead` through adapters (decided).

**Declined.** Engagement counts, follow buttons, a bottom tab bar inside the
reader, font-family choice, share in the top bar.

**Owed.** STILL-OPEN §60.1 (adapters), §60.2 (chip word), §60.3 (the card
format, owed to the home rail not the reader), §60.4 (father reads), §62.2
(a server column for "helpful").

## 3. Saved / bookmarks

**Asked.** Saved screens: NYTimes, Withings Health Mate, Pocket, Mindvalley,
TIDE, Agoda, Rodeo, Places.

**Found.** "All" first, one chip per kind with a count, newest first, search
above the chips once the list is long. Withings groups by kind under All;
nobody segregates by *stage* on the chips — stage is a filter at most.

**Adopted.** Exactly that shape: All with grouped kinds and counts, chips,
a stage row only when she has saved from more than one stage, search from the
header, "No longer available · Remove" for withdrawn content. Every kind's
header renders even when empty (our rule, not theirs).

**Owed.** STILL-OPEN §61.3 (sharing a bookmark with the partner), §61.4
(retire the old hubs and store bodies after a release cycle).

## 4. Family model — transitions, second child, partner

**Asked.** Flo switching to pregnancy mode / to get-pregnant mode; Clue mode
switching; Apple Health add / log a past pregnancy; child-profile switching
(Fitbit Family; the streaming apps came back as noise).

**Found.** Every app puts the **person** at the root; a pregnancy is a record
under her with a start and an end (Apple Health can log a *past* one); modes
switch on one account with the previous mode's data intact; the partner links
to *her*. Nobody makes the baby the account.

**Adopted.** Written down as the rule (`FAMILY-MODEL.md`): the person owns
identity and bookmarks, the child owns what is logged about the child, stage
is a tag. `saved_items` is the first table built on it.

**Owed.** STILL-OPEN §61.1 (`pregnancies` table — the second baby and loss),
§61.2 (one product catalogue across stages, same shape).

## 5. Onboarding questions, OTP length, invite-applied state

**Asked.** Question screens that explain themselves (Monzo "Good to know",
Oura "Why we ask", Yazio); Indian OTP screens (Swiggy, Zomato, CRED); sign-up
screens showing a link-applied referral (Jobber, Blank Street, Venmo, Uber
Eats, Klarna, Atoms).

**Found.** A reason under the question and a well that answers back after the
tap. **Six** OTP digits at Swiggy and Zomato (CRED four). No app in the set
shows a link-applied invite at sign-up — they all show enter-code fields.

**Adopted.** Two or three give-back questions per stage
(`onboarding_questions.dart`) writing to `FamilyProfileStore`; six boxes on
the OTP sheet and a six-character pairing code (0082) so both code sheets are
one length; the welcome screen *tells* "Invited by a friend · code applied"
when the Play install referrer carried a code, and asks only when nothing
arrived — a pattern we shaped ourselves.

**Owed.** STILL-OPEN §62.5 (the question artboards are not in the Claude
Design project yet).

## 6. Base UI — the components that stay constant

**Asked.** Home screens of wellness apps for the page ground (Liven, Waking
Up, Wysa, Me+, Finch, Tolan, TIDE, Bears Gratitude); premium light-mode
buttons (Queue, Etsy, Airbnb, Whatnot, Sora, Mindvalley, Oura, Xbox); lists
and settings with one accent (Airbnb, Notion, Linear); forms, chips and
sheets (Etsy, Airwallex, Noom, Grab, Strava, Tinder, Base, Crouton).

**Found.** Nobody ships a flat lilac-grey page: white or near-white with the
colour in cards (Liven, Wysa, Notion, Airbnb), or a full-bleed illustration
(Finch, Tolan, TIDE). The apps that read premium for years use **ink** for
the commit button (Queue, Etsy, Airbnb) and keep the brand colour to one or
two accents; the apps that fill buttons with their brand colour (Airwallex
purple, Base blue, Grab green) are the ones that feel like the palette is
being thrown at you. Chips: hairline, black when selected (Etsy). Sheets:
24px top radius, actions pinned. Settings: white rows, hairlines, chevrons,
ink icons.

**Adopted.** The rule in DESIGN-SYSTEM §4.0 — *ink for actions, brand as a
small accent, colour only inside wells* — and its first three executions:
white ground everywhere, Plus Jakarta Sans retired into Manrope through the
`pvJakarta` seam, the ink pill as the theme's FilledButton so 228 buttons
changed at once. The onboarding chrome is the first screen built on it.

**Declined.** Brand-filled primaries; full-bleed illustrated pages (a
different product).

**Answered 2026-09-17.** The seven calls in `BASE-UI-DECISIONS.md` §2 — the
one that changed the app is §2.3: Fraunces out, Newsreader in, through the
`pvFraunces` seam.

**Owed.** `BASE-UI-DECISIONS.md` §3 (the sweep); STILL-OPEN §63.3's two
remaining walks.

---

## What the library does not carry

Searching these by name returns junk (Mindvalley, an HR app): **Ovia, Glow,
Huckleberry, BabyCenter, What to Expect.** Search parenting patterns by
description instead. In: Flo, Clue, Headspace, Oura, Apple Health, Swiggy,
Zomato, CRED, and the general-purpose apps above.

## Queries that worked

- Name the flow the way Mobbin names it: `"<App> onboarding"`, `"<App>
  logging in"`, `"<App> switching to pregnancy mode"`. A descriptive
  two-intent sentence returns the wrong flow.
- Search *parts* for screens: "reader display settings sheet", "end of
  article screen with related articles", "pre-permission screen explaining
  why the app wants to send reminders".
- Name the content, not the gesture: "one idea per card" found story cards;
  "swipeable" found dating apps.
- A flow query is ~9 preview images (~10k tokens); `limit` 1–2. Download
  references with a TLS-1.2 `WebClient` (curl is reset by the CDN) into
  `research/mobbin/<audit>/` (gitignored; permanent links in the audit doc).

## Candidate audits, not started

- The three "today" homes as one app (the habit question proper) — after the
  V3 homes settle.
- Product / commerce screens across stages (§61.2).
- The day-2 return: what the first notification says, what visibly changes.
- The story-card format for the home's daily rail (§60.3).
