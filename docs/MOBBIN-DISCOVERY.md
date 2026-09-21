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
| 2 | Reading | 2026-09-16 · 17 | `READER-AUDIT.md` · `DESIGN-SYSTEM.md` §4.0a | Five additions, then the whole app on one reader through adapters (guarded) |
| 3 | Saved / bookmarks | 2026-09-16 | `FAMILY-MODEL.md` §5–6 | Yes (`saved_items`, `SavedScreen`) |
| 4 | Family model — stage transitions, second child, partner | 2026-09-16 | `FAMILY-MODEL.md` §2–4 | Written down; `pregnancies` table owed |
| 5 | Onboarding questions, OTP length, invite-applied state | 2026-09-17 | this file §5 | Yes, inside the onboarding build |
| 6 | Base UI — page ground, buttons, chips, cards, sheets, type | 2026-09-17 | `DESIGN-SYSTEM.md` §4.0 · `BASE-UI-DECISIONS.md` | Ground, type (Newsreader + Manrope), button theme, transitions, callouts, sheets; §2 answered; sweep owed |
| 7 | Products — one store for three stages | 2026-09-17 | `PRODUCTS-AUDIT.md` | Yes, same day (`lib/screens/products/`, nine screens; old screens are facades) |
| 8 | ParentVeda+ (doctor app) — provider home, earnings ledger, payouts, availability, front door | 2026-09-18 | `DOCTOR-APP-AUDIT.md` | Yes, same day (`0084`, `doctor_chrome.dart`, five `*_tab.dart`); not walked — STILL-OPEN §5.4 |
| 10 | Profile — one *You* screen for four stages | 2026-09-19 | `PROFILE-AUDIT.md` | Yes, same day (`lib/screens/profile/`, nine files; `ProfileScreen` and `TtcProfileScreen` are facades); not walked — STILL-OPEN §67 |
| 11 | Learning — one funnel for courses, masterclasses, cohorts, 1:1 consults and class packs | 2026-09-20 | `LEARNING-AUDIT.md` | Yes, same day (`lib/screens/learn/`, ten files; twenty-five facades); not walked — STILL-OPEN §69 |

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

**Applied 2026-09-17.** §60.1 (adapters — every reading model in the app
converges on `PvRead`; the guard test keeps it so), §60.2 ("Article"), the
picture frame on every article, Read next on the tool tile. A second pass
asked how readers set tables, steps and scripts *inside* a piece (Alan,
Withings Health Mate, Lovi, Clue, Keeta): hairline rows, quiet numbered
circles, no filled cells — the parenting blocks already did this, so they
render inside the reader unchanged.

**Owed.** §60.3 (the card format, owed to the home rail not the reader),
§60.4 (father reads), §62.2 (a server column for "helpful").

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

## 7. Products — one store for three stages

**Asked.** Fourteen flow queries across ~20 apps: storefronts (Amazon Haul,
Target, H&M, Blinkit Kids, Walmart nursery, SHEIN, Tabby), the department
switch (H&M's `WOMEN +`, Zara's menu, H&M search with counts), listings (Etsy,
Zara, Sephora), product pages (Amazon's 20 screens, Sephora, CRED Store),
gallery/zoom (H&M, SSENSE), reviews (Best Buy, Target, Etsy, Amazon), experts
(Lovi, Liven, Klarna, Swiggy), compare (Best Buy, Walmart, lululemon),
variant sheets (Yami, UNIQLO, Etsy), cart → checkout → placed (foodpanda,
7-Eleven, adidas, CRED's address sheet), orders (Apple Store, Starlink).

**Found.** The storefront is a menu of ways in (search · department · category
glyphs · for-you · editorial · shelves). The department switch is one word at
the top, and search is cross-department with counts. The listing card is a
contract users already read. The product page is a funnel in one scroll with a
sticky commit bar. Reviews lead with a number and pros/cons chips; experts are
named with credentials. Checkout is one spine everywhere.

**Adopted.** All of it as-is, in our type and on the base-UI rule; one store
with three storefronts and the stage switch in the second slot; Products in
slot 2 of every bar; our two blocks — *ParentVeda recommends* (a signed
reason, on some products) and *What experts say* — and the honest empties.

**Declined.** Distribution bars we cannot back, AI review summaries, sponsored
storefront rows, a score /100, per-stage product screens, the Guide chooser.

**Owed.** STILL-OPEN §65.

---

## 8. ParentVeda+ — the doctor app

**Asked.** Nine queries, provider-side only: the host home (Airbnb host
Today, Future Pro), earnings overviews (Turo Business, Cash App, Fiverr,
Revolut Business, Shopify, TikTok monetisation), the per-item receipt (Turo
host receipt, alias), payouts and statements (Turo transaction history,
DoorDash Dasher, Upwork, Airtasker, Gusto, StubHub), working hours
(OpenPhone, Swarm, Linktree, Beside, Tripadvisor), the working day (Jobber,
Apple Store), the class host view (Posh, Luma), the front door (Slack).

**Found.** A provider home leads with ONE blocker card, then the next
thing as a card with its two actions. Money is one big number, a legend of
sources with an amount each, and a printed-receipt grammar for any line
(price → fee with a sentence → you earned). "We owe you ₹X · next payout
<date>" is the plainest copy in the set. Hours are seven rows, one per day,
with a master switch. A host manages a class from one page with seats sold
of capacity. Sign-in is email → code, password as the fallback.

**Adopted.** All of it, in our type and on the base-UI rule, with type and
targets tightened for a 40+ audience (`doctor_chrome.dart`); the by-source
legend became rows so every source renders even when empty.

**Declined.** Charts as the primary view, dark money screens, gamified
rewards, provider ratings/performance tabs (we do not rank doctors),
attendee names on a class.

**Owed.** STILL-OPEN §5.4. Full write-up `DOCTOR-APP-AUDIT.md`.

**8b — the Home hero (2026-09-19).** Two more queries on provider homes
with imagery: Calm / Air NZ (photo band, first card overlapping), Zopa,
Jobber (the work's context behind the greeting), Airbnb host / Bloom (a
place, no faces), pliability / Fiverr (the person's own photo large).
Adopted as `DcHero` with three CC0 photographs by hour and the doctor's own
`photo_url`. Declined dark full-bleed homes and promotional heroes.
`DOCTOR-APP-AUDIT.md` §7.

---

## 9. The door walk — Scans & tests (2026-09-18/19)

The user's standing instruction for this pass: *"keep using the Mobbin MCP…
I don't want you to just pick one and keep building on it."* So every
pattern touched on a door gets its own query, and what it produced is
logged here so the next door starts from it rather than from the chat.

| Pattern | Query (screens, iOS) | Found | Adopted |
|---|---|---|---|
| Search entry on a page | "search bar pinned at the bottom…", "Flo category page with a search bar below the heading" | Bottom bar = iOS 26 search-SCREEN pattern (Apple Games, Podcasts, Linear, Wabi); the entry is at the top everywhere (Flo topic page: title · line · field · card rail) | A bar under every door's blurb; a search screen with the field on top — DESIGN-SYSTEM §4.0e |
| Search screen | "health app search screen with the field focused, recent searches and suggestions" | Flo, Bloom, CVS, Apple Health, Yazio, GoodRx: field top, keyboard up, recents + suggestions, grey/white field | `PvSearchScreen` |
| Warning list | "when to see a doctor section, plain text list, no coloured box" | **Flo**: bold lead sentence, coral-dot list, on white. Clue: a grey box (what the user hates) | The red-flag form: rule · display heading · coral dots · grey foot. Pinned flag, reader callout, urgent screen |
| Library list | (from the search pass) GoodRx, Apple Health, CVS | Rows: icon well, bold title, one grey line, chevron, hairline | `PvDoorRow` compact row |
| Date + time | "choose an appointment date and time in a bottom sheet…" | **Rodeo, Todoist, Alta, Freenow**: month grid INLINE in the sheet, chosen day a filled disc. **Instacart, Agoda, Future Pro**: time as tappable slots. Nobody opens a dialog over a sheet | `showScanDateSheet`: `CalendarDatePicker` inline + `_TimeSlots` |
| Checklist | "checklist of questions to ask your doctor with tick boxes and share" | Withings, Reminders: hairline rows, ink box, no fill on tick | `PvChecklistScreen` rows |
| Specialists to book | "telehealth app listing specialists… photo, specialty, rating, fee" | **Zocdoc** (avatar · name · specialty · ★ · reviews · next-available bar), **Preply** (price + reviews + one line), **Alan** (specialty tabs on top) | `ConsultationsScreen`: specialty pills, three-line block, next slot as a slim pill, no inline Book |
| Documents empty state | "medical records screen empty state inviting to add a document" | Docusign / Grab / Cleo: full-width hairline "Add" box; Fi / Zocdoc: illustration + pill | Looked at, NOT applied — the locker's single add tile was the user's own 2026-09-12 call |

**Declined this pass:** Clue's boxed "When to get medical advice" (the
box); Zocdoc's yellow availability bar (colour as container); Material's
`showDatePicker` dialog (lavender surface, violet day — and a dialog over a
sheet).

## 10. Profile — one You screen (2026-09-19)

The full audit is `PROFILE-AUDIT.md`. What the library settled, in one
line each, so the next profile question starts here:

| Question | Who answered it | Taken |
|---|---|---|
| Where does the stage live? | **Flo** — the goal (period / conceive / pregnancy) is a row on the profile, changed with intent | *Your journey*: four chapters, one forward action, no free switch |
| Profile vs settings? | **Oura** — profile is who you are, settings is how the app behaves, two pages | One page, two halves: A–E about her, F–H about the app |
| How are rows grouped? | **Clue** *More* — grouped rows, eyebrow headers, hairlines, no cards inside cards | `PvYouSection` + `PvYouRow` |
| Adult and children? | **Fitbit Family**, **Garmin child account** — the adult at the root, children beneath as chips | *Family*: partner card, then child chips → `PvChildScreen` |
| The partner's view? | **Flo Partner** — "what he can see" stated as a list | `PvPartnerScreen`: what they see / never, one switch |
| Switching who you are? | **Airbnb** "Switch to hosting", **Netflix** profiles — a floating pill, not a tab | *View as* pill, only when a partner is paired |
| Data rights? | **Apple Health** privacy sentence, **Urban Company** privacy centre, **Zalando** request/delete | `PvDataPrivacyScreen`: what we store · download (coming) · delete |
| A report for the doctor? | **Flo** "Report for a doctor" | `PvDoctorNotesScreen`: read-only, her own entries, disclaimer |

**Declined:** Netflix-style full-screen profile picker (a family is not a
list of equals); Zomato's gold/points band; per-thing sharing toggles in
v1 (the user's call — one switch until the server owns the rule).

## 11. Is it safe? — a lookup that is not a list (2026-09-19)

Seven passes, two of them after the user asked for *features*, not a
layout ("instead of just being a static section that just displays text
for a single click"). What each one settled:

| Question | Who answered it | Taken |
|---|---|---|
| What is the first thing on the page? | **GoodRx**, **Noom Food Lookup** — the field; you came to ask a thing | The field in the hero, live results as she types |
| Where does the camera live? | **Yuka**, **Noom**, **Lifesum**, **Bevel** — scan beside search, never a separate mode; **PhonePe / GPay / Paytm** — scan at the bottom centre, under the thumb | Both built behind `kCanIScanAtFoot`; bottom-centre pill by default, the user judges on the device |
| How does a verdict read at a glance? | **Yuka** — an 8pt dot and one word per row, no painted tile | `CanIVerdictDot` + word; a corner pill on photo tiles |
| How does food look appealing? | **Uber Eats / Safeway**, **Shipt / Target**, **Thrive Market** — cut-out photos on white, name under, tight grid | `CanICutoutTile`, 3 across |
| Big photo or cut-out? | **Uber Eats Browse**, **Panera** — photography for the *category*, cut-outs for the *item* | Photo shelves (Eat / Drink / Take / Do), cut-out items |
| What does a "no" end in? | **Amazon Fresh** "Replace with:" rail, **Uber Eats** swap sheet, **Instacart** "If out of stock…" | *Instead, try* — a rail of safe swaps on every non-safe answer |
| How does the answer page open? | **Vivino**, **Yami**, **HelloFresh** — the photo edge to edge, the judgement in the first line under it | The reader with a photo hero; verdict block first |
| What makes it come back? | **Yuka History** tab, **Noom** recents | *Asked recently* chips; Saved surfaced on the door |
| A barcode's unknown-product state? | **Yuka** "Unknown product · Fill in the information", **Lifesum** "Barcode not found" | "Not in our list yet" sheet → Ask Veda / Scan another; the miss logged |

| The answer page, once "not an article" | **Yuka** product page (thumbnail, name, score line, dotted list, recommendations), **State Farm** driving verdict (hero, verdict headline, one reason, ticked tips), **Vivino** (photo, the judgement in the first line) | `CanIVerdictScreen`: photo → name → verdict + short answer → For you → Why → swaps → T1/T2/T3 rows → doctor → two buttons → cut-outs |

**Not in the library:** any pregnancy food-safety app (Ovia, BabyCenter
are absent, as noted in §"What the library does not carry"); the pattern
was assembled from grocery, nutrition and payments apps instead.

**Declined:** Yuka's numeric score (a number invites comparison and a
personalised probability, which the clinical rule forbids); Bumble's
safety hub (tiles of static reading — the thing this door replaces);
Bevel's radial action menu (nine actions where we have two).

## 11. Learning — one page for five kinds (2026-09-20)

The audit is `LEARNING-AUDIT.md`. The one finding, and who settled each
part of it:

| Question | Who answered it | Taken |
|---|---|---|
| Is a course page and a cohort page one design? | **Udemy, MasterClass, Peloton, Airbnb, Alan** — the same ten sections with a different fact strip | `PvOfferingScreen`: one order; the kind fills B, C, E, J |
| What is the structure block? | Udemy's curriculum · MasterClass's lessons · pliability's week cards · Alan's "how it works" | `pvStructureTitle` + lessons / week cards / steps |
| Where do dates live? | **Airbnb** cards on the page with seats left; **Alan, Preply** a slot sheet from one button | Slots in a sheet; group = date cards, 1:1 = week strip + times by part of day |
| Pay before or after picking? | **Alan**: time, then money | `pvLearnCommit`: slot → review → pay → reserve |
| What does "booked" look like? | **Peloton** scheduled class, **Zocdoc** upcoming visit | `PvSessionScreen`: big time, countdown → Join, prepare, partner line, reschedule / cancel with the rule |
| The learning home? | **Skillshare** Continue watching, **Udemy** My learning, **Noom** pinned current course | *Yours first* strip, then the kind filter, then rails |
| The player? | **MasterClass** lesson page, **Udemy** lectures list | `PvLessonScreen`: film · title · Up next · the list with ticks |

**Declined:** the "sales page" vocabulary (guarantee bands, testimonial
carousels), seat urgency in colour, progress rings and badges, a chat
button to the expert, a separate detail screen for the slot picker.

## 12. Nutrition — a door that is a day (2026-09-20)

Seven passes before a line of code, on the user's instruction to research
"UI, UX, flow, user psychology and effects" first. What each settled:

| Question | Who answered it | Taken |
|---|---|---|
| What is a meal plan, really? | **Crouton**, **Recime**, **Cherrypick** — a *day*: breakfast · lunch · dinner as rows, each swappable, "what you'll need" one tap away. Nobody reads a chart | *Your plate*: today's meals from the chart that fits her, photo rows, Swap, "not today"; Tomorrow a chip away |
| What brings people back daily? | **MyFitnessPal**, **MacroFactor** rings; **Alma**'s nutrient page ("contributing foods") | *Did you get…*: five ticks (iron, calcium, protein, folate, fibre), no numbers; long-press → the foods that count. Alma inverted: we show what would count, we never measure |
| Water? | **Noom**, **Yazio**, **Lifesum** — a row of glasses, tap to fill | Eight tumblers, tap to fill up to, tap the last to empty |
| A recipe? | **Woolworths** (servings stepper, Shop ingredients), **Crouton** (scale, method), **CREME** (photo, Cook button) | Servings stepper scaling every quantity, *Add to my list*, numbered method, **Cook** |
| Cook mode? | **Recime** (Step N of M, segmented bar, one instruction, Next/Finish, ingredients button), **HelloFresh** ("Enjoy your meal" over the photo) | `CookModeScreen`: exactly that, screen kept awake |
| The tick's feel? | **Noom** ("Did it today!" → soft squiggles → "Done for today"), **Atoms** (a deliberate press), **Finch** (confetti — declined, too much) | Ring fills, six ink strokes fly out, medium haptic; the line under the ticks celebrates, never counts a miss |
| Diet preference? | **Kitchen Stories**, **Blue Apron** — set once, every list respects it | Onboarding's answer steers plate, swaps, recipes; region added; one row to change |

**User-psychology rules for this door** (the reader may be nauseous, tired,
not hungry): no red anywhere; no streaks, fire icons or "days missed";
"not today" is one tap and as easy as a swap; the only numbers are
glasses; every line under a section is a celebration or an invitation.

**Declined:** calorie/macro targets (a personal target she can fail —
against the clinical and calm rules); Finch's pet and confetti; weekly
calendar grids of empty days (Crouton's Meal Plan when empty — a wall of
"No recipes").

## What the library does not carry

Searching these by name returns junk (Mindvalley, an HR app): **Ovia, Glow,
Huckleberry, BabyCenter, What to Expect.** Search parenting patterns by
description instead. In: Flo, Clue, Headspace, Oura, Apple Health, Swiggy,
Zomato, CRED, and the general-purpose apps above.

Provider apps (2026-09-18): **Uber Driver, Practo, Doctolib, Fresha, Booksy,
Square Appointments, Calendly are NOT in.** In: Airbnb host, Turo host,
DoorDash Dasher, Fiverr, Upwork, Airtasker, Jobber, Future Pro, Posh, Luma,
OpenPhone, Swarm, Linktree.

Shopping (2026-09-17): **Myntra, Nykaa, Flipkart, FirstCry are NOT in** — the
queries fall through to Shopee, Instagram shops and CRED. In: Amazon, Zara,
H&M, Sephora, Etsy, Target, Walmart, Blinkit, CRED Store, Tabby, SHEIN,
adidas, UNIQLO, Best Buy, lululemon.

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
- The day-2 return: what the first notification says, what visibly changes.
- The story-card format for the home's daily rail (§60.3).

## 13. The search bar's flow — one template for every door (2026-09-20)

**Trigger.** On the phone the user looked at Is it safe?'s "Yours" row — Saved
· N and her last look-ups as chips under the field — and said it read as
"my history displayed at the very top … static … I don't see any use of it",
that Asked most deserved the top, and to "figure out a way, use the Mobbin
MCP". Then: "create this flow as a template so it can be reused for every
door wherever the search bar is."

**Query.** `search_screens` "food scanner search screen recent searches
popular products" (ios). Twenty screens: Thrive Market, Yazio, Fitbit,
Woolworths, Noom, MyFitnessPal, Ultrahuman, MacroFactor, Cal AI, Garmin,
Alma, Lifesum, Swiggy, Keeta, Grubhub, Gojek, Kitchen Stories, Vivino,
Instacart, Under Armour.

**Found.**
- Nobody shows history on the idle screen. Recent searches appear only once
  the field has FOCUS and is still empty (Yazio, Keeta, Swiggy, Kitchen
  Stories, Ultrahuman), or behind a Recent / Favourites tab (Fitbit, Garmin,
  Lifesum).
- The idle screen leads with Popular / categories (Woolworths, Grubhub,
  Gojek, Instacart).
- The one idle nod to "yours" is Woolworths' Buy Again: a single row with a
  meaning line and a chevron, not a section of chips.
- On focus the field rides to the top so the keyboard sits under the recents
  (Swiggy, Keeta); a miss always ends in a way on.

**Adopted** (`lib/screens/doors/pv_live_search.dart`, on Is it safe? and
every shell door):
- Three states — idle (the page), focused-and-empty (Recent + Saved as rows,
  Clear), typing (rows; last row a way on: "Search everywhere" / "Ask Veda
  about …").
- On focus: the field scrolls to 4% from the top (`Scrollable.ensureVisible`
  after the frame), the hero's words fade (200ms), the sheet grows a floor
  of screen + keyboard so a short result list still gives the field room to
  rise.
- Back twice — the user's call: the first drops the keyboard and leaves the
  rows readable ("some people would want to see what's happening below"), the
  second releases the field (PopScope), never leaves the door.
- Is it safe?: Yours retired from the top; Asked most first; one "Saved
  answers" row at the foot (Buy Again).
- The doors: the bar that pushed `PvSearchScreen` is live now; the pushed
  screen remains as "Search everywhere" with the words carried over.

**Declined.** A Recent / Saved tab pair (Fitbit) — a third control on a door
that already has a rail.

## 14. Nutrition, the deep dive — plans, recipe tiles, a number under every meal (2026-09-20)

**Trigger.** The user walked the door click by click: the chart was "text
thrown at me" in grey boxes at 13pt; "The chart" sat as a stray button in
the Today / Tomorrow chip row; the nutrients rail ended in a tool that
listed the same nutrients again; "can I ask for a breakfast, a sweet, a
soup?" — no; and then: "it's a nutrition door with zero nutritional values
… people care about nutritional value so much."

**Queries.** `search_screens` (ios): "meal plan day breakfast lunch dinner
recipes plan week"; "recipes browse filter by meal type breakfast dinner
dessert snack category"; "dish calories protein macros per meal healthy
mode food delivery nutrition info". Zomato's Healthy Mode is not in the
library; the delivery and meal-kit apps stood in.

**Found.**
- A plan is a DAY STRIP + that day's MEALS WITH PHOTOS (Centr, Crouton,
  Wabi, Cherrypick) — never a week of text.
- A recipe library leads with MEAL-TYPE TILES — Breakfast · Lunch · Dinner ·
  Snacks · Sweets · Drinks (Lifesum, Yazio, Blinkit, Woolworths, Withings),
  with a filter sheet by category behind (Kitchen Stories). Blinkit's tiles
  are 3D illustrations in one style; Yazio's are 2D.
- Nutrition on a dish: TWO OR THREE NUMBERS ON THE CARD (HelloFresh "35 min
  · 1020 Cal · 46 g", Chipotle "210 cal", Chick-fil-A "650 cal · 31 g
  protein"), a PER-SERVING BLOCK on the page (Cherrypick's grid, Bevel's
  tiles, Ultrahuman's rings), and an honest caveat ("industry-average data;
  your portions vary").

**Adopted.**
- `DietChartPlanScreen`: day strip, the plate's own photo rows, "Make this
  my chart" (pins it — Today follows), Swaps / Go easy on in the reader's
  16pt, the doctor's note as a rule-left block, a six-tile day total.
- Today: one "Your plate" heading with the date; no Today / Tomorrow chips
  (three Todays down one screen, and "why not the day after?"); the chart
  as a quiet line under the plate; the whole plate as the six tiles.
- Recipes: `meals` + `kind` on every recipe, seven bucket tiles with counts
  (first recipe's photo — no second set of pictures), 24 recipes written to
  make the tiles real (40 total).
- `food_values.dart`: a ~150-food table (IFCT-scale, per 100 g with typical
  servings); `estimateMeal` for prose, `estimateRecipe` from ingredients;
  the glance line under every plate row, chart row and recipe card
  (energy · protein · the one strength); `NutritionValuesGrid` on the meal
  sheet, the recipe page, the chart day and the whole plate; the caveat on
  each; the day's reference once, by the ticks, in "roughly", no bars.
- The five bigger questions as reads; the one-nutritionist Talk tab reads
  the merged expert catalogue.

**Declined.** Percentage-of-need bars (Yazio, Ultrahuman) — a bar against a
target is the pressure this door exists to reduce, and the clinical rule
forbids it. A Σ sign for the day total — "not everyone is mathematically
sound"; the six tiles instead. The photo-to-surface fade under a hero photo
("no white mist, no fading").

**Owed.** 3D category illustrations in one style (Blinkit) — generated
(Higgsfield) on the user's go; charts extended from three days to seven
(the user's question; his call on order); photos for 14 of the 24 new
recipes (Openverse's general index is thin; the dish-word fallback holds).

### 14a. The chart browser (same evening)
Query: "browse meal plans list filter chips plan cards diet programs" (ios).
**Found:** Tempo's Training plans (search · one chip row · full-width cards
with image, title, one line, three facts), Blue Apron / HelloFresh (a
Filters chip row over vertical cards), Blinkit (facet tags on each card).
Nobody browses with a form. **Adopted:** `DietChartBrowseScreen` — two
edge-to-edge chip rails, full-width cards, each with a distinct dish photo
from the chart's own days, facts line, "Your chart" mark. The door's rail
caps at eight with "View all ›" (`PvDoorSection.moreSurfaceId`).
**Declined:** a filter sheet (Kitchen Stories) — nineteen charts do not
need one; the chips are the filter.
