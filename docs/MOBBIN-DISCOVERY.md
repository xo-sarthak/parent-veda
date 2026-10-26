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
| 1 | Onboarding | 2026-09-16 | `ONBOARDING.md` (History A) | Yes, 2026-09-17 (`lib/screens/auth/onboarding/`) |
| 2 | Reading | 2026-09-16 · 17 | `READER-AUDIT.md` · `DESIGN-SYSTEM.md` §4.0a | Five additions, then the whole app on one reader through adapters (guarded) |
| 3 | Saved / bookmarks | 2026-09-16 | `FAMILY-MODEL.md` §5–6 | Yes (`saved_items`, `SavedScreen`) |
| 4 | Family model — stage transitions, second child, partner | 2026-09-16 | `FAMILY-MODEL.md` §2–4 | Written down; `pregnancies` table owed |
| 5 | Onboarding questions, OTP length, invite-applied state | 2026-09-17 | this file §5 | Yes, inside the onboarding build |
| 6 | Base UI — page ground, buttons, chips, cards, sheets, type | 2026-09-17 | `DESIGN-SYSTEM.md` §4.0 · `BASE-UI-DECISIONS.md` | Ground, type (Newsreader + Manrope), button theme, transitions, callouts, sheets; §2 answered; sweep owed |
| 7 | Products — one store for three stages | 2026-09-17 | `PRODUCTS-AUDIT.md` | Yes, same day (`lib/screens/products/`, nine screens; old screens are facades) |
| 8 | ParentVeda+ (doctor app) — provider home, earnings ledger, payouts, availability, front door | 2026-09-18 | `DOCTOR-APP-AUDIT.md` | Yes, same day (`0084`, `doctor_chrome.dart`, five `*_tab.dart`); not walked — STILL-OPEN §5.4 |
| 10 | Profile — one *You* screen for four stages | 2026-09-19 | `PROFILE-AUDIT.md` | Yes, same day (`lib/screens/profile/`, nine files; `ProfileScreen` and `TtcProfileScreen` are facades); not walked — STILL-OPEN §67 |
| 11 | Learning — one funnel for courses, masterclasses, cohorts, 1:1 consults and class packs | 2026-09-20 | `LEARNING-AUDIT.md` | Yes, same day (`lib/screens/learn/`, ten files; twenty-five facades); not walked — STILL-OPEN §69 |
| 12 | Onboarding V3 — every answer used; the partner who sets up alone | 2026-10-17 | `ONBOARDING.md` §1–2 | Yes, 2026-10-17, after a clickable prototype was approved; not walked — STILL-OPEN §62.6. Flo (onboarding, TTC and pregnancy switches), Clue, Oura, Stardust. Partner pass: Flo is invite-only from her side and "you're always in control"; Stardust lets either start with a code. Adopted: either can start, she types his code, her data reaches him only after that. The library has no dad app and no baby tracker |

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

## 15. The pregnancy home's fold — the second round (2026-09-21)

Queries: "pregnancy app home week day strip daily insights cards baby this
week" and "your baby is the size of a fruit comparison length weight toggle"
(ios), on top of §PREG-HOME-HERO-PLAN's first round.

**Found, again, and it settled the plan.** Flo's pregnancy home is the
shape: month + calendar → a day strip (today ringed, dots on logged days)
→ one big disc with the week's baby and "2 weeks ⓘ" → a **Details** pill →
steps → **My daily insights** as a rail whose first card is a white
**Log your symptoms +** and the rest are illustrated reads. Flo's Details
is a full-bleed 3D baby with a week chip strip at its foot and a sheet
(what happens at 42 weeks · reviewed by · the baby beside a watermelon ·
length · weight). Clue's home has ‹ › with the week's date range and a
**Back to today** pill. Oura's card counts down ("Meet your baby in about
47 days"). The size-toggle query found nothing new — Flo's sheet is the
only in-library reference; Pregnancy+ and What to Expect (not in the
library) are the toggle's home.

**Adopted.** The day strip on the hero; the week and the size as the only
words on the photograph; a "This week ›" pill where Flo has Details; the
log card first on the rail, giving way to what she logged; the size sheet
with the object beside the baby and length · weight tiles; a persisted set
toggle (fruit & veg · kitchen · sweets) instead of Flo's single fruit.

**Declined.** Flo's disc (our photograph is the hero and the reason she
opens the app); forward days on the strip (her future weeks are the
reveal, and a dead cell is worse than none — TTC keeps its six); ‹ › on the
home (Clue's home IS the week screen; ours has doors under it); a steps
count (no source).

**Owed.** Comparison pictures (§72.1); the week chip strip on the week
stack (Tier 3).

## 16. Nutrition, the second walk — logs, recipe pages, swaps (2026-09-22)

Queries (ios): "water intake tracker glasses daily log nutrition tracking
pregnancy app"; "food diary daily calories protein progress ring meals
logged history week Lifesum Yazio MyFitnessPal"; "recipe detail page
ingredients steps nutrition per serving calories protein header photo";
"meal plan swap meal alternative replace dish button daily plan".

**Do they keep a log of water and nutrition? Yes, all of them.** Lifesum:
‹ TODAY, 17 JUL › over the ring, meals logged, water as eight glasses with
the litres. Yazio: the day's meals with a per-meal ring, Water Tracker
(glasses, 0.00 l of 2.00 l), a Dietary Intake history with daily / weekly /
monthly bars. MyFitnessPal: a week strip (S M T W T F S) with a tick on
every day she logged, Diary with Log per meal, Nutrients as Total · Goal ·
Left. Flo: a Today logging screen with ‹ › and a Water card (−/+, 16 / 72
fl oz, reminders). **What converges:** the day is navigable; the week is
visible as ticks or bars; water is glasses per day. Our store already keys
by date; the day strip and a week view are the missing surfaces. Not built
— the user asked to know, not to build ("not saying that we should be
taking a log").

**Recipe pages.** MyFitnessPal (photo · title · Serves · chips · Nutrition
Per Serving as ONE ring + three numbers · Ingredients · Log to diary),
Lifesum (photo · title · servings + meal · kcal + minutes · three rings ·
Ingredients · Track), Yazio (photo · title · Cal / minutes / Easy · prose ·
tags · Add to list / Add to diary), Noom (photo · title · minutes · calories
· servings · Save · Log · Ingredients), HelloFresh (Total · Calories ·
Protein · Difficulty on one line · Ingredients), Recime / Hers (steps, then
Nutrition at the very foot). **Adopted:** one facts line and the three marks
under the title, ingredients next, the six tiles and the fact at the foot;
"Strong in" retired as a heading. **Declined:** rings against a goal (our
reference is a number, never a bar).

**Swaps.** Centr's meal plan: a day strip, meal cards with a ⇄ on each; the
swap is a picker and the card changes in place. Chopt: "Swapping <item>" →
grid → SWAP. Instacart / Target / Walmart: "Replace with" as a sheet of
alternatives with Select on each. Lifesum: "Adjust my meal". **Adopted:**
the row's Swap opens its own sheet of alternatives (photo, glance, ±kcal),
one tap swaps, the row washes; the row itself opens the meal.

## 17. How the apps draw the baby (2026-09-22)

Query: "pregnancy baby illustration week home" (ios). **Flo**: a 3D
rendered fetus inside a large tinted disc on the home ("2 weeks", Details
pill), full-bleed 3D on the Details page, a line illustration on
onboarding. **Clue**: a flat 2D illustration inside a disc on a coloured
field, one line under it. **Stardust**: a small 2D sprite floating in
space. Nobody in the library runs a full-bleed photograph as the home
hero. **Adopted:** the disc on the field (`V3PregHero`); the photograph
inside it today, the repo's own 2D set (soft pink figure on pink, drawn to
be circle-clipped) when the user brings it back.

## 18. Symptoms — check-in grids, "is this normal?", the report (2026-09-22)

Queries: "pregnancy symptom log", "symptom tracker daily check in",
"is this normal pregnancy", "share health report doctor" (ios). **Flo**:
"How are you feeling today?" as a grid of round tinted discs with a drawn
mark and a one-word label, a tap selects, a second tap opens intensity;
a Symptoms report (date range → PDF preview → Share). **Clue**: a row per
symptom, a column per day, a dot whose size is the strength — the cycle
view every doctor can read at a glance. **Ovia / BabyCenter** (not in the
library; from the review datasets): "Is this normal?" as a list of
questions in the woman's own words, answered with a verdict first.
**Huckleberry**: a day strip over the log so a missed day can be filled in.
**What converges:** the log is discs, not checkboxes; the week is a grid,
not a chart; a report is a preview then Share; the urgent list is a fixed
five, never personalised. **Adopted:** the disc grid with the marks drawn
in the door's hand and a severity sheet on the second tap; a day strip over
the check-in (Huckleberry) so yesterday can be logged; Clue's dot grid as
Your week with a counted "pattern" line (counts, never a trend); Send my
week as plain text (Share / Copy) — a WhatsApp message reaches an Indian
doctor, a PDF sits in Downloads; the ten questions as rows wearing a
verdict pill, a Call round on the "now" rows. **Declined:** intensity
sliders (three words are what she can answer at 11 pm); a PDF report;
any "getting worse" arrow.

## 19. Movement in pregnancy — the day, the library, the player (2026-09-22)

Five passes for the **Fitness & yoga** door (the brief is
`docs/FITNESS-DOOR-BRIEF.md`, which holds the screen-by-screen detail and the
links). Queries: "prenatal or pregnancy workout home with a weekly plan and
short sessions", "yoga class library with duration, level and focus filters",
"exercise detail with steps, warnings or modifications", "guided yoga session
player with pose timer and next pose", "pelvic floor / kegel guided breathing
with contract and relax timer" (ios).

**What converges.** *Open*: a week strip with today underlined and ONE named
practice under it (Daily Movement → SLOW FLOW → 20 min) — a day, not a
library. *Equinox+ / Withings / Fitbit*: the library is filter chips over rows
and the row carries the minutes; dropdowns (Fitbit) hide their own state.
*Tempo*: filters as a sheet, time as clock discs, level as pips. *Open* again:
safety as a NAMED bordered block on the session page ("Breathwork Safety",
which itself says not to hold the breath in pregnancy); *pliability* ends its
cues with "back off if you feel any pinching"; *Finch* puts "listen to your
body and stop if you ever need to" under the Start button. *MyFitnessPal /
Centr / Peloton*: a player needs no video — the current move as a large title,
a countdown, a progress bar, the rest as rows, plus Centr's GET READY count and
UP NEXT strip. *Calm Sleep / TIDE / stoic*: breath work is a ring with one word
in it.

**Adopted:** the day-first card with the month's other sessions under it; chips
over rows for the library; the named safety block per session; Finch's line
under Start; the list-plus-timer player with GET READY and UP NEXT; the breath
ring for pelvic floor.

**Declined:** *levels* (a pregnant woman is not "advanced" — trimester and how
she feels are the axes); *streaks and n/6 counters* (a missed day in pregnancy
is usually a correct decision, and the TTC home already ruled counters out);
calories; equipment filters; a teacher's face on every card (we have no
teachers, and invented bylines are the fake-avatar problem).

## 20. Blinkit's Recipes — what a grocery app got right (2026-09-22)

The user sent the flow himself
([Explore all recipes](https://mobbin.com/flows/83fef0df-6b0f-4ee9-bdc1-4b269c6c82e0)):
*"our recipe section resonates very much with theirs... can we not do it the
way they have done it"*. Read alongside their
[Recipe detail](https://mobbin.com/flows/2cc74b69-06b3-4e7f-8044-0f45af8e80df).

**Their structure:** a photographic masthead (flat-lay ingredients, "Recipes"
in a heavy wordmark, back and search as rounds ON the photo) → **six meal-time
tiles as a 3x2 grid**, illustrated plates on peach, label under → *Bookmarked
Recipes · see all →* as a rail → *Today's Recommendations* (big cards) → *Cook
in minutes* (small 3-up) → **All Recipes** behind filter chips (Quick Recipes ·
Veg · Diet Type ▾ · Ingredients ▾), two-column photo cards. Every card: a
bookmark top-right ON the photo, category chips bottom-left ON the photo, the
title under, and the **time** (⏱ 30 mins). Their recipe page: ingredients as
ADD-to-cart product cards, numbered steps, nutrition as four plain tiles, and
"*This AI-generated recipe may contain inaccuracies."

**Adopted** (into the Nutrition door's Recipes tab):
- **The category tiles as a grid, not a rail.** Nine buckets were a horizontal
  rail that hid four behind a swipe — so "what are you after?" was answered
  with a question. Now 3-across, all nine on screen. The argument was already
  written above the recipe grid in the same file ("a rail hides all but two");
  the buckets were the one place it had not been applied.
- **The bookmark on the card.** Every Blinkit card carries one. Ours carried
  none — and `SavedKind.recipe` had existed since the saved-items build with
  `SavedScreen` rendering a Recipes section that **nothing could fill**. A
  wiring gap found by copying a competitor's affordance.
- **"Bookmarked Recipes" as the section above the browse.** Ours is "The ones
  you kept", and it renders only when she has some — an empty rail of hearts
  is an instruction, not an invitation.

**Declined, and why:**
- **Ingredients as ADD-to-cart cards.** That is Blinkit's business, not our
  promise. A pregnancy recipe page selling garlic is a different product.
- **Cuisine chips (Chinese / Thai / Main Course).** Our chips answer "what
  does this give me" — iron, calcium, protein — because that is the pregnancy
  question. Region exists in our data and stays secondary.
- **Chips ON the photo.** Tempting, and it is why their cards look dense and
  good. But the user ruled four hours earlier that a recipe card's marks are
  **bare, in their own colours, no tinted background** — over a photograph they
  would need white pills, which is that decision reversed. Left where he put
  them; offered as a separate change.
- **A photographic masthead.** Their Recipes is a standalone screen; ours is a
  tab inside a door whose hero is already a photograph. Two photo heroes on one
  scroll is the door-inside-a-door problem.
- **"AI-generated, may contain inaccuracies."** Our recipes are written.

**Owed:** the **time on the card** (⏱ 30 mins) is the one Blinkit signal we
cannot copy yet — `Recipe` has no minutes, and inventing forty numbers would be
inventing data. Forty times, written once, would also unlock "Cook in minutes".

### 20a. The second pass — the user revises three of the declines (2026-09-22)

He read the declined list and overturned two, confirmed one, and named the
real problem behind a third:

- **The time on the card: do it.** *"Telling the users how much time this
  recipe will take, especially to someone who's pregnant, that's a good
  thing."* `Recipe.minutes` is now **required**, which immediately caught a
  second recipe file (`nutrition_recipes_more.dart`) that a nullable field
  would have left silently timeless. 41 recipes, 41 times, active kitchen
  time only — soaking and fermenting stay in the steps, because "480 mins"
  on a dal she cooks in forty is a lie told by a data model.
- **Chips on the photo: do it if it looks better.** *"If it makes it look
  good, then I'm fine with it... the way we were doing it was looking bad,
  so there might be some sort of issues, right?"* — and the issue he named
  was not the marks but the PICTURES. So the marks moved onto the photo as
  white discs (Blinkit's chip position), the time took their old place under
  the title, and the photographs got audited.
- **Ingredients as ADD cards: half of it.** We already have the shopping list
  he remembered (`ShoppingListScreen`, recipe-grouped, shareable). What was
  missing was per-item control — it was all-or-nothing, and *"we don't decide
  the brand, we just say that you might need ketchup"* is exactly the line
  between their ADD and ours. Every ingredient now has an Add / On-list
  toggle; the button below adds everything.
- **Cuisine chips: he agreed with the decline.** *"Categorization can be a
  bit better the way they have done"* — which the bucket grid already is.

**The photo audit** (his rule: pick by eye, from a genuine place). Four of
the sixteen recipe dishes were not the dish:
| id | was | now |
|---|---|---|
| `nut_palak_paneer` | "Palak paneer **on rotini**, with curry powder and peanuts — Massachusetts" — pasta | palak paneer in spinach gravy |
| `nut_dal_rice` | a **fish curry** thali — on varan bhaat, the vegetarian Maharashtrian dal-rice | varan bhaat on a banana leaf |
| `nut_kadhi` | a whole Gujarati thali, kadhi one small bowl in it | a bowl of kadhi |
| `nut_shukto` | a generic StockSnap plate that was not shukto | shukto in its pan |

The fish one is worth keeping as the example: for a vegetarian or Jain
mother that is not a styling slip, it is the app getting her food wrong.
Credits moved with the pictures. **And the table alone would have changed
nothing** — `kReadImageBase` points at R2, so `readImageFor` serves the R2
copy; the four had to be re-fetched and re-uploaded (`fetch_read_images.py`
re-fetches on a changed source, `upload_to_r2.py` skips unchanged keys), then
read back from the live bucket to confirm. Commons is honest but plain for
regional home food: these are now CORRECT, not styled.

## 21. Parenting recipes — the page and the card, piloted on one dish (2026-10-15)

**Trigger.** REMAINING-CHANGES item 11, "Recipes screen (L). Study Mobbin
first, then build". At the same time the user dropped a Drive folder,
*Recipes (not reviewed)*, and asked for: a detailed recipe page, a look at
how the tab that opens it should look, and the design proven on ONE recipe
before it spreads ("if i like it then it can be applied elsewhere").

**Queries** (ios): "recipe detail page with hero photo, cook time, servings,
ingredients list and step by step method"; "recipe cooking steps list with
numbered method, step timers and tips"; "recipe browse list with photo cards
showing title, cook time and tags, filter chips at top"; "horizontal
carousel of recipe cards on a home screen with photo, title and time"; "baby
food recipe page with age suitability, texture stage, allergen notes and
nutrients". Solid Starts is not in the library, and nothing in it shows a
recipe page for a baby.

**Found: the page.**
- **The dish photo first, with back and save as rounds on it.** Lifesum,
  [MyFitnessPal](https://mobbin.com/screens/d7116fe0-5bed-4092-a095-78d6571ed3f4),
  [Instacart / NYT](https://mobbin.com/screens/0532323f-1c75-4311-be94-ef6890f7686f)
  and [Yazio](https://mobbin.com/screens/a8ca1a9b-dcc3-45f6-accc-1a4d36309636).
- **One facts strip.** [Postmates](https://mobbin.com/screens/8a91bdf8-1e0c-45e5-8c2d-951f1b101935):
  Servings | Prep time | Cook time. HelloFresh adds Difficulty.
- **The quantity in its own column.**
  [Apple News](https://mobbin.com/screens/2f5f45a8-5799-4de9-9f70-a5c77675de43)
  sets the amounts in a right-aligned column, and
  [Crouton](https://mobbin.com/screens/57fada57-d4f0-4519-a6ba-b7aaedb514f3)
  colours the amount.
- **The method as numbered cards, with the minutes picked out.**
  [Crouton](https://mobbin.com/screens/a1e36578-a1a5-434b-b191-95eb3ce53cae)
  and [Kitchen Stories](https://mobbin.com/screens/85a4ace6-390e-40b5-a231-14f134af1752).
- **A cook mode.** [HelloFresh](https://mobbin.com/screens/a8ce2bb8-cecc-423b-aaaf-53e3e00e333a)
  shows "Step 2 of 6", Recime has "Cook step-by-step", and Julienne has a step
  with its tip.
- **Swaps next to the ingredient.**
  [Withings](https://mobbin.com/screens/22c5973d-837a-46e0-b697-31fb4fc84a5c)
  writes "Ingredient swaps: …" and
  [Cherrypick](https://mobbin.com/screens/671ebdad-9d43-4387-8912-876466031535)
  has "Easy Swaps".
- **Nutrition low and plain.** Hers, Recime and MyFitnessPal put it near the
  foot. Lifesum and MyFitnessPal pin one main action at the foot.

**Found: the card.**
- [Blinkit](https://mobbin.com/screens/3b5dabc7-926d-49cc-a278-fdf4bd416355),
  [Noom](https://mobbin.com/screens/99817269-341f-4d2d-bf05-17162018a65b),
  [NYT Cooking](https://mobbin.com/screens/304d5760-05ce-487a-8604-4c4f3e45fc1b),
  [Kitchen Stories](https://mobbin.com/screens/9d70bed4-358d-4193-84b7-141143144964)
  and [Yazio](https://mobbin.com/screens/abfb6d8a-d5c7-4db9-93c2-3ffce333f345)
  all follow one layout:
  - a photo on top at roughly 4:3, with the bookmark on the photo, top right;
  - one mark on the photo, Blinkit's veg dot or Kitchen Stories' minutes;
  - the title under the photo, two lines at most;
  - one meta line: the time, then one fact.
- Libraries lay the cards out in two columns. Homes put them in a rail
  (CREME, Hers, Instacart).

**Adopted** (`FoodRecipeScreen._buildDocPage`, `FoodPhotoCard`):
- **The page, top to bottom:**
  1. The photo, with back and save on it, and no fade.
  2. The eyebrow ("7–8 MONTHS · LUNCH"), then the Newsreader title and its
     line.
  3. Diet, Serves and the meal role.
  4. **Prep | Cook | Level | Texture**.
  5. **The age-fit line, ours.** It sets the dish's age band against the
     child's own age: "Right for Aarav now, at 7 months". The app derives it
     and never asks.
  6. Why this is good for him.
  7. What you need: the amount in its own bold column, an Add / On-list
     toggle per row (water has none), then the equipment as chips.
  8. The method as numbered cards, with the minutes in bold.
  9. What's in it, as tiles of nutrient and source food.
  10. Good to know, as two tiles: How often and Storing.
  11. **Take care, ruled on the left, never red.**
  12. You can swap.
  13. More on ParentVeda.
  14. The byline.
  15. The foot: **Add all to list | Cook step by step**.
- **Cook mode is pregnancy's** `CookModeScreen`. It gained a `.steps`
  constructor, so it now has one implementation and two sources.
- **The card:**
  - the photo, with the bookmark and the diet mark as white discs on it
    (§20a);
  - the title in two lines;
  - "25 min · 7–8 months" under it.
- **Shown on the doc-format dish only** (`FoodRecipe.docFormat`). Every other
  dish keeps the shelf card in the same rail, so the two can be compared side
  by side until the user approves.

**Declined:**
- **Calories and macro rings.** The doc has none, and the Food companion
  does no calorie counting.
- **A servings stepper.** Baby portions are fixed, and "1 tiny pinch" of haldi
  does not scale.
- **Ratings.** We have none to show.
- **Ingredients as product cards.** §20 already declined these.
- **Cherrypick's Ingredients / Method / Nutrition tabs.** One scroll reads
  better with a baby on one arm, and Crouton, Hers and NYT use one scroll.

**Owed:**
- **The khichdi photo.** The user is making it in ChatGPT; the prompt is in
  REMAINING-CHANGES.
- **After approval:**
  - the other 27 dishes of the 7–8 month band;
  - the page and card on all 139 dishes;
  - a photo for each dish.

### 21a. The pilot's components, in the house look (2026-10-17)

**Why:** the user approved the pilot, with one complaint: "old UI hints, for example the lavender background
some places, pink purple". The page's own code was already in V2Palette, but the parts it borrowed were not:
- the shared "More on ParentVeda" rows (`_related`): a purple mark in a lilac well;
- the photo placeholder (`FoodThumb`), which rotates peach, lavender and blush stripes;
- the card's lavender-grey meta line (`ppMuted`);
- a Material SnackBar in the theme's purple;
- shelf hues in the rails that ran into lilac and pink.

**Queries:** "recipe detail bottom section with related articles and ingredient links as rows", "recipe grid
where some recipes have no photo", "recipe page with nutrition tiles, storage tips and a safety note".

**Found:**
- **The foot of a recipe:** Kitchen Stories ("More delicious ideas for you"), Alma (ingredient rows) and Yazio
  end on white rows with a grey hairline and ink icons. None tints the block.
- **Added to the list:** Recime's dark "6 items added · View groceries" bar and Kitchen Stories' "added to your
  shopping list · Undo" are the same notice as our pvToast with an action.
- **No photo yet:** Woolworths shows a pale neutral block. No app puts a coloured stripe where a photo goes.
- **Facts, steps, nutrition:** HelloFresh's facts row, Lifesum's numbered steps and Crouton's notes confirm
  what §21 already chose.

**Adopted (doc-format dishes only; the older dishes keep their look):**
- **`_docRelated`:** the same rows and taps, with an ink mark on the pale surface, the grey line and the third
  ink for labels.
- **A neutral placeholder:** `FoodPhoto` draws a plain surface block with a line bowl until the photo arrives.
- **The card's title and meta** are in the house palette.
- **"Add all to list"** confirms with pvToast and a View action.
- **Rail shelf hues** stay in the warm food range (orange to leaf green).
- **A test:** `test/pp_recipes_test.dart` fails if ppPurple, ppPanel, ppMuted, ppHair or ppBorder paints
  anywhere on a doc page or doc card.

**Declined:** a "More for 7–8 months" photo rail at the foot (Kitchen Stories). It is a new section, and the
ask was the look, not the layout.

## 22. The Dear Baby vault — read aloud, the opening at birth, the book (2026-10-15)

**Trigger.** REMAINING-CHANGES items 8 (Baby vault) and 12 (Keepsake PDF),
folded into one pass on the user's word (STILL-OPEN §83.2). The book
"unlocks at birth". The user asked for "a Mobbin pass on each screen to make
it look good" and said "it should feel responsive".

**Queries** (ios): "sealed envelope or time capsule letter reveal screen with
an open button, celebratory unlock moment"; "list of episodes where one row
is playing with an animated equalizer icon and a play all button at the
top"; "locked feature card with a lock icon and a line saying when it
unlocks, inside a journal or memories app"; "export journal as a printed
book or PDF preview screen with page thumbnails and a share or download
button".

**Found and adopted.**
- **The opening.** [Swiggy](https://mobbin.com/screens/a27f73a1-e50e-40ec-9d7a-3f1329e8320d):
  an envelope with sheets fanning up out of it. This is the shape of
  `DearBabyOpeningScreen`.
  [Tolan](https://mobbin.com/screens/434afe5a-4578-4531-a329-54663d478fcc)
  gave the rest: an "unlocked" paper card, one ink pill ("Read now"), and a
  quiet text link under it ("Continue"). Ours is "Read your letters" and
  "Later".
- **Reading aloud.** [Brink](https://mobbin.com/screens/a65bfc83-435f-431b-9bdc-995a03bc9aab):
  the row being played turns its pill into a waveform. Ours turns "Read
  aloud" into moving bars and "Reading · Stop".
  [Queue](https://mobbin.com/screens/7b1325f5-ad37-4594-9fa9-bb3e2435b218):
  a floating Play bar over the list. Ours is the "Reading letter 2 of 5 ·
  Stop" bar while "Read them all aloud" runs.
- **The sealed book.** [Substack](https://mobbin.com/screens/f80cc3bc-1256-4895-a146-6a42363672f3):
  the mark with a lock badge, a title, and one line saying what opens it.
  Ours: a book with a lock badge, "Your letters, as a book", and "It opens
  the day you meet". It stays visible, never hidden.
- **The book.** [Polarsteps](https://mobbin.com/screens/b7618c21-df09-46e5-99b5-62f2fa31498d)
  ("Voilà, your Travel Book is ready!") over the pages, and
  [Withings](https://mobbin.com/screens/dd65c67f-9b15-41fa-8e33-6c7fe30a70c6)'s
  single Close / Share pair at the foot instead of an app bar of icons.

**Declined.**
- **Confetti.** It was on almost every unlock screen: Swiggy, Locals,
  Trust Wallet, Ultrahuman. This is a mother's letters on the day she gave
  birth, not a level-up. Calm is the house voice.
- **Crouton's export settings** (paper size, text size, toggles). One book,
  one format. Settings would be choices nobody needs.

**Responsiveness, as built.**
- Every tap settles under the finger (`PvPress`).
- The seal and the download give a haptic.
- The envelope's words and button flip on the tap itself, not when the
  flap lands. A test caught the first version waiting for the animation.
- The read pill shows "Reading" before the TTS engine starts.
- The book card shows "Making your book…" with a spinner while the PDF
  builds.
- Reduced motion skips the flap and stills the bars.

## 23. Garbh Sanskar pillars — player, recorder, games, breathing (2026-10-15)

**Trigger.** The user on the Garbh daily screens: Shravan "looks off" and
should be "like the audio playing applications"; Samvad's big black record
button "does not look good" and "feels like wastage of space"; Buddhi's games
should use the drawn marks "inside each and every game as well"; Kriya's
breathing elevated if Mobbin shows better. Then: every screen "easy to use and
to understand", calm, responsive; and the same inside the Garbh door.

**Queries** (ios): "music player now playing screen with large album artwork,
track title, progress scrubber, and play pause skip controls"; "meditation or
sleep sounds library list with track rows, durations, and a persistent mini
player bar at the bottom"; "voice note recording inline in a card with a small
mic button, a prompt to read aloud, and a waveform while recording"; "brain
training puzzle games hub with tiles ... each with a simple drawn icon";
"sudoku game board screen with number pad"; "word search puzzle game grid";
"guided breathing exercise screen with an expanding circle".

**Adopted.**
- Player: [Spotify](https://mobbin.com/screens/6cb0a8f6-977e-4b9a-b137-04bc8f4b9d24),
  [Shazam](https://mobbin.com/screens/91f80d92-c604-4a43-8e86-3c1e90d2f1d8),
  [Deezer](https://mobbin.com/screens/263c3ff4-b773-4ff7-ad24-ac62c1d79f7e),
  [Calm](https://mobbin.com/screens/c79512c8-b63b-4807-913a-c09615ff69ee):
  the cover, title and artist, the scrubber with times, one big play disc.
- List and bar: [Calm](https://mobbin.com/screens/2deebcbc-5868-46ca-9142-39b5a38bfd28)
  and [Me+](https://mobbin.com/screens/a5eecade-e8f5-4ef0-9d3f-d3934a82a33f):
  rows with art, a pinned now-playing bar with play-pause and close.
- Recorder: [Hinge](https://mobbin.com/screens/3e9f1876-9de3-435d-bbdf-b7ec7b0eb8e5)
  (the time and waveform in a soft well),
  [ABY Journal](https://mobbin.com/screens/2d1b5587-06f3-4286-bebc-5fb625fe0cae)
  and [Bond](https://mobbin.com/screens/196ff693-5766-4457-86ed-372054338869)
  (a voice-note bar in place of a big control).
- Games: [Apple News Puzzles](https://mobbin.com/screens/a2319e2f-b25d-41ff-8b15-b0f9d35dc619)
  and [Duolingo](https://mobbin.com/screens/a01507b1-1677-4f3e-9a23-50cdf6807b44):
  each game its own drawn square mark.
  [Opal](https://mobbin.com/screens/5090f051-642d-454c-90cb-61406ceb6b6b):
  a minimal top, the way out as a text link ("Nevermind" → our "Close").
- Breathing: [Finch](https://mobbin.com/screens/170f6c9c-3e74-4f2f-b29c-58290c4002d7),
  [Life Reset](https://mobbin.com/screens/8cad3cd9-ead8-429c-8d48-a9fd14c76bc9),
  [stoic](https://mobbin.com/screens/ea4a9e85-b8fa-4116-89cf-097d614e9cb2):
  no app bar, the word inside the circle, a quiet count, one action at the
  foot.

**Declined.**
- Dark full-bleed players: the app is a white ground.
- Shuffle, repeat, queue editing, and previous / next on a screen that plays
  one track: choices she does not need (the calm rule).
- Two "different puzzle" buttons (New and Next): one remains.
- Scores, timers, streaks in games (already refused by tests).
- Confetti on finishing anything.

**Responsiveness, as built.**
- The play disc and the recorder answer the tap in the same frame
  ("Starting…" while the mic opens).
- Every tap is a `PvPress`.
- Moving bars and pulses stop under reduced motion.
- Leaving a list stops what it started.

## 24. The all-phases screen — a journey, not a list (2026-10-15)

**Why.** The user called `PhaseMapScreen` "very bland … random stuff listed, not intuitive": twenty
identical rows under a block of text. Asked for images, an easy layout, full responsiveness.
Decided with the user: a painting per phase, and the 20 phases grouped into five chapters.

**Found.**
- [Noom Course Map](https://mobbin.com/screens/7328d9ae-184b-4cbf-8941-d5ed2d74a1a4):
  an illustrated round disc per stop on a dotted path, title beside it.
- Alan journey ([1](https://mobbin.com/screens/6c47d7b0-f8a0-479b-9ea6-6b2f89693d0d),
  [2](https://mobbin.com/screens/df679b59-f12a-4b1a-bc95-de27f6388e29)): a picture per stop on a
  dashed rail; the current stop larger and ringed, done stops ticked, stops ahead quieter.
- [Duolingo](https://mobbin.com/screens/3cc1779f-ef61-4e0a-8b00-adecbd24aa6d): a section banner
  that says where you are in a long path.
- [Moonly Runes](https://mobbin.com/screens/3426c659-f2a7-4fe5-b687-136f731713d4): a chapter
  heading on the rail, its items under it.
- [Flo](https://mobbin.com/screens/347a171b-a63b-4c2f-b8cf-9b0377c8b255): a full-bleed image for
  the current stage.

**Adopted.**
- The screen opens on the child's own phase: a 4:3 painting card, "PHASE N · AGE · NOW", the name,
  the doc hero's first sentence, an "Open this phase" pill (Flo). Side by side on a wide screen.
- Five chapters with a header each (name, span, phase count) and a chip row that jumps to one
  (Duolingo, Moonly). The chapter is derived from each phase's start month.
- Each phase a round painting on a dashed rail with its age, name and one line from its doc; past
  phases ticked, the current one bigger and ringed in its accent (Noom, Alan).
- From 600 px wide, a 2-column grid of tiles; content capped at 720 px and centred.
- A phase with no painting yet shows its number in its own accent, so the screen ships complete.

**Declined.**
- Locks on phases ahead: a parent may read ahead; nothing is hidden.
- Coins, streaks, progress scores.
- A dark theme: the app is a white ground.

**Owed.** The 20 paintings (`docs/PHASE-PAINTING-PROMPTS.md`, saved as
`assets/phases/phase_NN.webp`).

## 25. Yoga & fitness hub — one library for three stages (2026-10-16)

**Question.** Do fitness apps keep stage content apart (Flo) or show one library (Peloton)?

**Found.**
- Peloton Classes: search, type chips with All, big cards, floating Filter pill (mobbin.com/screens/660faab6-e6a4-470a-b139-fda69e4bd2b6).
- Tonal Explore: For You beside Workouts, a count line, floating Filter (mobbin.com/screens/efb364af-d90c-4f41-a5a2-18edc1c9829a).
- Equinox+: active filter chips with Clear all, a result count (mobbin.com/screens/00ba8848-6018-4b9c-9d99-e01dfa59c012).
- Fitbit: titled rails with See all (mobbin.com/screens/3b31174e-5841-45df-a679-d85df702abf8).
- Centr: teacher avatars as a filter row; a grouped explore list (mobbin.com/screens/4b0f249a-e9a5-4cf5-8776-093604b1553f).
- Flo: a "Prepregnancy fitness" row inside the stage's own page, nothing from other stages (mobbin.com/screens/7a7ca385-7a01-4a1f-94a6-fe2c6fc80a93).

**Adopted.** Both: one library (Peloton) that opens on a stage's own view (Flo). For you / All, chips, the floating Filter pill and sheet, count + Clear all, rails with See all, a stage label on mixed cards.

**Declined.** Teacher avatar row (seven seed teachers, no real photos yet); sort menu (nothing worth sorting by yet).

**Owed.** Real class photos and videos.

## 26. Pregnancy calendar — one hub, Coming up, Whole journey (2026-10-17)

**Question.** The pregnancy calendar was three tabs of old UI. What do competitors put on one calendar screen, and how do they show what is next and the whole pregnancy? Asked screen by screen, the way the TTC cycle hub was done.

**Found.**
- Clue pregnancy home: "Your first trimester · 1 week + 5 days", "39 weeks until May 17 ✎", ‹ › by week, a Back to today pill (mobbin.com/screens/4109e86e-82be-4437-8709-fa3f54efcdda, mobbin.com/screens/e6d1a043-3433-4b1c-a1b5-8060482d9d4e).
- Oura Pregnancy Insights: three trimester rings, "33 weeks 2 days · Meet your baby in about 47 days", Trimester / Due date tiles (mobbin.com/screens/ee1f0724-69a9-4eaa-b2a4-b3e54e844051, mobbin.com/screens/4ccc949c-fa00-41db-a72e-67f4e19f214e).
- Apple Health cycle tracking: a pregnancy card with a start-to-due bar, then a "Log" list of rows with + (mobbin.com/screens/9710c735-c8a6-46aa-88bd-36edf8b8610b).
- Withings Cycle Logs: one row per kind, + to add (mobbin.com/screens/00c25e9d-8599-41e3-8c22-81ebfec69660).
- Weverse / Todoist / Asana months: dots under the date, the picked day's list under the grid, a friendly empty line (mobbin.com/screens/5d94bb1b-51b2-4765-b836-b9a3ff2f4148, mobbin.com/screens/a62d6a9f-94af-4e57-b0df-444edf90996f, mobbin.com/screens/74725910-5a3c-4ec9-917d-728e9b882bbd).
- Lex / Fixtured / Canopi / Binance upcoming: a date block left, an "In 3 days" eyebrow, day groups, "No more events today" (mobbin.com/screens/cb327064-1d9b-4275-a731-287cf1bf7ac0, mobbin.com/screens/11d10641-8ab2-4157-9269-eeadff8b16a6, mobbin.com/screens/d88f4063-64d0-4234-9afc-433ca89af1be, mobbin.com/screens/8339ece6-cfa5-4995-a7ab-e52de69fb419).
- Zocdoc Well Guide / CVS visit checklist: checks marked Due with an action (mobbin.com/screens/86529650-4ea4-42ec-ad0e-a1d14a9c9fb0, mobbin.com/screens/387b81ad-b6ed-483c-88d5-5cf2384388b5).
- CVS / Zocdoc / Fresha appointment pages: When, Where, With rows, then the actions (mobbin.com/screens/c3a9a7d5-a6bb-44a6-a76e-bf9339c78b2e, mobbin.com/screens/71930370-307b-4a90-9185-988981407a2f, mobbin.com/screens/5ef9f1bf-25b5-487c-b347-2dd30dc2d263).
- Runna / stoic. week cards, Flo week chips (mobbin.com/screens/9eb278de-d059-4726-b181-8ec7d161ba4c, mobbin.com/screens/5e124ffa-c154-4e2c-8faf-6bad200a3b81, mobbin.com/screens/347a171b-a63b-4c2f-b8cf-9b0377c8b255).

**Adopted.** Hero: weeks and days, a three-segment trimester bar (Oura's rings flattened for space), days to go with Change (Clue), and the due date's source (Apple Health). Month: dots, this week as a band, a Today pill off-month. Day: rows plus one Add; Add as a list of rows that says why a row waits (Apple Health, Withings). Coming up: date block plus countdown, day groups. Usual checks: a window, never a date, with "Add date" turning it into her booking (Zocdoc). Item sheet: When / Where / With / Notes, then actions (CVS). Whole journey: one card per week with counts, opening on "You are here" (Runna, stoic.).

**Declined.** Flo's full-screen baby bubble (b9868b90) — the home already carries the week film. Week and trimester tags inside month cells. A continuous week scroll (TTC tried and reverted it 2026-10-16). Icon-grid pickers for Add (FocusFlight, Craft). Cover images on upcoming rows (Meetup, Luma). Book buttons on checks (we do not book scans). Maps and directions. Stardust's hormone graph.

**Queries that worked.** Describe the content, not the gesture: "month calendar where each day has small coloured dots for logged entries, with selected day's entries listed in a card below and an add button"; "pregnancy app list of upcoming doctor appointments and prenatal tests by week"; "upcoming events agenda grouped by today, this week, later with countdown chips and date blocks on the left". App plus flow for flows: "Flo pregnancy mode monthly calendar, tapping a day to see and log symptoms".

**Library gaps.** No real pregnancy month-calendar screen: pregnancy apps lead with the week, not the month (which is why our hero leads too). Ovia, BabyCenter and What to Expect are not in the library.

**Built.** 94d0cf6. Record: `docs/PREG-CALENDAR.md`; prototype claude.ai/artifact/N6Y95pDA2i5dkQQbFaAF26.

## 27. Parenting recipes, ordered by the child (2026-10-21)

**Why:** Tools → Recipes opened on "When your baby is unwell" (the age chip
filtered every dish away under six months). The user also asked for every
screen one tap deeper to be in the same look, and one image per dish.

**Queries:** "recipes home screen with a featured recipe for you and
collections below"; "recipe browse screen with category tiles grid like
breakfast, lunch, snacks"; "baby food app screen showing foods by baby's age
with a starting solids guide" (the library has no baby-food app; Alma only).

**Adopted:**
- One featured dish before the lists: [NYT Cooking](https://mobbin.com/screens/7703a07f-d26b-4d1e-a5bd-660cc5df52af),
  [Kitchen Stories "Today's Recipe"](https://mobbin.com/screens/f7d9718f-2350-40cb-917a-4d59928c45a1).
- "Top picks for you" as the first rail: [Cherrypick](https://mobbin.com/screens/48b28392-c6b0-4f62-a327-7828f606bb1d).
- Six meal tiles: [Blinkit](https://mobbin.com/screens/c69b2710-70ee-46d4-b9bc-d221078385f1),
  [NYT Cooking search](https://mobbin.com/screens/f96b49e6-64c1-4bc3-92f2-f94635f7a4e7).
- Rails with an eyebrow over a short title: [Hims](https://mobbin.com/screens/484a4184-4fb0-4918-a290-4d7708edbf95).
- A saved rail: [CREME](https://mobbin.com/screens/715a96fa-90bc-4180-b8ba-1342b060bd0f).

**Declined:** photo meal tiles (one dish photo exists; drawn marks instead);
calories and ratings; CREME's dark look; creator rows.

**Built.** `pp_recipes_screen.dart` (`PpRecipesScreen`, `PpRecipeListScreen`,
`ppRankRecipes`). Prototype claude.ai/artifact/YERnPpDwamz3Qa7RNCX4AM.

## 28. Health record, Emergency card, Milestones (2026-10-21)

**Asked.** The user: these three parenting tools still had the old purple UI;
then, on the prototype, "i dont need lavender color background at all".

**Found.** Zocdoc "Medical history" (mobbin.com/screens/b6cc665f-d3b3-4386-a34a-667add12be3f):
a short list, each row a label, its current value and a chevron. Apple
Health "Medical ID" (mobbin.com/screens/b936f416-d47b-43f2-87b5-76949df7cff8):
named sections, each with Add. Lyft badge detail
(mobbin.com/screens/1a0be947-d27e-4639-8128-6ee0e81c35ad): one big mark, a
title, one line, a calm paragraph. Fitbit (mobbin.com/screens/318ef228-8f35-4782-9683-6ffe48870cd3):
plain grey cards on white, which set the neutral that replaced the lavender.

**Adopted.** Record rows that state what they hold; the card as sections with
Add on the empty ones; the detail sheet's big mark; one plain neutral grey.

**Declined.** Gamified badges, streaks and confetti (Finch, Runna, Kit,
Crypto.com): milestones are noticed, never scored. The 2x2 health tile grid
(Fitbit): rows carry the current value, tiles do not.

**Built.** `health_home_screen.dart`, `health_records_screen.dart`,
`health_emergency_screen.dart`, `wallet_v2_screens.dart`
(`WalletEmergencyCardScreen`), `milestone_journey_screen.dart`. Prototype
claude.ai/artifact/9RNbbpCofsYtvSCgehNbQd.

## 29. One format for reads, products and FAQs across three homes (2026-10-21)

**Asked.** The user: reads, products and FAQs look different on the three
homes; one ParentVeda.

**Found.** Reads as a short list with a picture, title and time: Lloyds
"Recommended reads" (mobbin.com/screens/258bba87-5578-4fe9-804c-2605bc7735f4),
Afterpay "Read more" (mobbin.com/screens/f5ca8b7b-f65a-4a1d-8270-2b313185fe26).
One short row of product cards: Hers (mobbin.com/screens/e2df5b43-0d78-47c4-aeb4-be8d9344583d).
FAQs as a plain list, one open at a time: Cash App
(mobbin.com/screens/4f22cda9-b112-4090-9aec-5911b367e667), Blue Apron
(mobbin.com/screens/4808f17e-e11d-4174-8130-fec441fc3445).

**Adopted.** Reads as three rows everywhere (TTC and Pregnancy already were;
Parenting moved). One product card, the user's pick B: no price on the home.
The FAQ accordion Parenting already draws is the shared shape.

**Declined.** Price on the home card (Hers shows it; the home is not a shop).
Large feature cards for reads (Finimize): rows carry more in less space.

**Built.** `pp_home_v3.dart` (`_DoorReadRow`, `_ProductRail`),
`pp_relevance.dart`. Prototype claude.ai/artifact/Hgfy82qx2TLA4S7MVeZE1S.

## 30. The phase screen: the painting as the film's poster (2026-10-21)

**Asked.** The user: the phase image does nothing; the film should start from
it.

**Found.** One cover, one play action on a content page: Insight Timer
(mobbin.com/screens/a2e7c7e5-314b-4dd0-a997-75e6c88ae152), Mindvalley
(mobbin.com/screens/e2bf8a14-07f5-464a-8929-1af51ee2e040). Apple TV and
Paramount+ put a white Play pill on the cover.

**Adopted.** The painting as the cover with a white "Play this phase" pill,
playing in place; a quiet "coming soon" pill when no film exists.

**Declined.** Full-bleed dark cinema heroes (Apple TV, Netflix): the app is
white ground and calm, and the painting is the art.

**Built.** `phase_detail_screen.dart`. Prototype
claude.ai/artifact/NYQX3ovZZR4Uxwympe7gCX.

## 31. The old screens behind the parenting home (2026-10-21)

**Asked.** The user: old UI screens are still wired from the parenting home;
use the app's latest marks, not icons.

**Found.** An activity as a short numbered page with no cards: Nike Training
Club "Three tips" (mobbin.com/screens/386ce592-c2a5-481f-9698-03c283ae2350),
Lifesum instructions (mobbin.com/screens/53bf5e52-aa94-47eb-bc76-690e8236afd9).
Experts as plain rows with one booking pill: Fresha services
(mobbin.com/screens/3206f2b1-cf79-4213-ab4a-7cb71e3d1bb8), Noom coaches
(mobbin.com/screens/f50b248f-3855-4a29-a8c5-9d7885340b15).

**Adopted.** The activity in the one reader with numbered steps; experts as
`PvListRow`s with an outline "Book" pill.

**Declined.** Ahead's lavender activity modal with a purple CTA
(mobbin.com/screens/2aea6bf7-4f98-4cdb-9719-52ac03034d71): lavender is out.

**Built.** `pp_activity_read.dart`, `provider_results_screen.dart`,
`development_all_activities_screen.dart`.

## 32. The 2026-10-20 walk: Cycle Companion, the plan, the temperature card (2026-10-21)

**Asked.** Label the cycle ring with dates; temperature logging with real
values and a real outcome; the plan's reminders at her own times. Later, the
user on the recorded rise row: "this kinda confused me".

**Found.**
- Ring and legend: WHOOP's cycle calendar legend, Bevel's cycle strip.
- Logging a value on a date: Fitbit "Add blood glucose", Stardust "Add daily
  temperature".
- Reminder times: Ahead's time wheel, Mindvalley "Set your time", Lifesum
  per-habit reminders.
- The marked day lives on the chart: Flo BBT and ovulation
  (mobbin.com/screens/0fd74099-e552-42ef-a439-b5bf63a1cb3d) shades it; Oura
  Cycle Insights (mobbin.com/screens/02bc9ee3-1c59-4141-a934-ef325fc0819d)
  pins a label on it.
- A saved entry is one card that says what it is, with clear edit and delete:
  Flo's Today log (mobbin.com/screens/129329ed-d141-4a94-b894-152a38b6e726),
  Bevel (mobbin.com/screens/2360b267-2be9-4656-981d-17ab33e136a5), Noom
  (mobbin.com/screens/b1907184-b955-4393-a6d5-fb923d89a99d).

**Adopted.** Date labels on every arc plus a legend; a 10-day date strip and a
°C/°F stepper; a time pill per habit (weight 600, not 800). The rise day: a
band and a "Rose · <date>" pin on the chart, and one card ("Your temperature
rose on …", what it usually means, "Cycle day n") with round pencil and bin
buttons.

**Declined.** Teal on controls: teal means fertile days and ovulation only;
switches and buttons stay ink. Stripes for estimated days: every date is an
estimate, so marking some twice was repetition (the user).

**Built.** `ttc_cycle_hub.dart`, `ttc_temp_parts.dart`,
`ttc_ovulation_screen.dart`, `ttc_ready_week.dart`.

## 33. The parenting hero and the one phase page (2026-10-22)

**Asked.** The user: the parenting hero is bland, and a phase tap should land
on the phase itself ("what the phase is about"), like Wonder Weeks' leaps,
not a list of twenty and then a third screen to read.

**Found.** Wonder Weeks is not in the library. Flo "What happens at 42 weeks"
(https://mobbin.com/screens/347a171b-a63b-4c2f-b8cf-9b0377c8b255): a big
picture, a strip of week pills, the article below. Clue
(https://mobbin.com/screens/e6d1a043-3433-4b1c-a1b5-8060482d9d4e): ‹ › between
weeks and "Back to today". Moonlitt
(https://mobbin.com/screens/109f55cc-1ae4-496a-b70d-a2940ebd4c17): a painting
card with page dots. Noom "Today's plan"
(https://mobbin.com/screens/726a894d-7bbb-4269-9e97-3007507cd4e4): short rows
with a mark, one line each.

**Adopted.** The phase pills, ‹ › on the painting and "Back to now"; the
article as the page; activities and changes as one-line rows with marks.

**Declined.** Oura's and Stardust's dark grounds; Me+ and Alan's coloured
cards and streaks.

**Built.** `pp_phase_page.dart`, `pp_home_v3.dart` (`_PaintedHero`,
`_ActivityRows`).

## 34. TTC batch 2: the new-chapter page and IVF step by step (2026-10-22)

**Found.**
- [Flo, pregnancy mode](https://mobbin.com/screens/9ed48daa-5725-478b-ad98-da3c004b9848):
  "Looks like you are 3 weeks pregnant", one line on how it is counted, a pill,
  and "Change pregnancy week" beside it.
- [Oura, due date](https://mobbin.com/screens/3cba3344-fda9-4c20-96a7-5ab7e94fd6da):
  "If your health care professional has provided a different date, you can
  edit it now".
- [Clue, last period sheet](https://mobbin.com/screens/23380986-8135-447b-a48c-95580a1613f5):
  "When did your last period start?" as one question.
- [MasterClass curriculum](https://mobbin.com/screens/72dcf33e-58e8-486f-a178-583a2d411f67),
  [Alan, step timeline](https://mobbin.com/screens/6c47d7b0-f8a0-479b-9ea6-6b2f89693d0d),
  [Acorns, numbered lessons](https://mobbin.com/screens/823d2426-7995-4546-8dda-ebe3414345ba):
  numbered steps on a line, each with its video.

**Adopted.** The week as the headline with one "How we counted" line and a
date change beside it (Flo, Oura); the last-period question asked alone
(Clue); a vertical numbered timeline with the video on top of every step card
(MasterClass, Alan).

**Declined.** Flo's pink pill (ours is ink). Celebration screens with confetti
(WHOOP's "Congratulations"): many couples reach this page after a loss.
Gamified path maps (Ahead, Noom): a treatment is not a game with locks.

## 34. What she told us, the phase video, activity photos (2026-10-23)

**Found.** Check-in chips: Noom "What might be contributing"
(https://mobbin.com/screens/425e978e-5f24-4546-b155-e491c41e0dbb), Insight
Timer (https://mobbin.com/screens/1e87a4d1-d014-4d85-b43f-e80ee410579e). Rows
with a photo: Alan "Exercises and content"
(https://mobbin.com/screens/2de2138e-2023-4b8c-bcc3-8bded31816d5), Polarsteps
"Places" (https://mobbin.com/screens/9e542264-c982-4e50-9cd6-774dc6fd9197). A
video on an article with its length: FotMob
(https://mobbin.com/screens/491c37b4-be1a-4a9f-8846-ef4c6834a9c9), NBA
(https://mobbin.com/screens/80959e6f-42bc-42c5-ba52-75c5a2b32a9b).

**Adopted.** The rounded-square picture on activity rows; the length badge on
the phase poster. The flow's chips already match; only a "kept" line was added.

**Declined.** How We Feel's dark ground; Pangea's emoji chips.

**Built.** `pp_changes_store.dart`, `pp_activity_paintings.dart`,
`lib/data/pp_phase_videos.dart`.

## 35. Stage transitions: loss, trying again, expecting again (2026-10-24)

**Queries.** Flow "pregnancy app changing pregnancy status after pregnancy loss"; screens "period tracker app
switching mode from pregnancy back to cycle tracking", "parenting app add a new pregnancy or another baby screen".
The third query found only kids-profile forms (SHEIN, YouTube Kids, Alexa): the library has no parenting app with an
"add a pregnancy" screen.

**Found.** Apple Health "Set Up Pregnancy" and "Add a Current Pregnancy", which dates by period, due date, weeks or
embryo transfer and offers "Log a Past Pregnancy"
(https://mobbin.com/screens/fed0b0c8-baa1-41ef-8683-fb54cd0c9570,
https://mobbin.com/flows/d0b0ae08-53d2-418e-9439-c7ace1f7dc31). Oura Women's Health: "Pregnancies · 1 logged"
and a quiet "My pregnancy ended" (https://mobbin.com/screens/a9ff1b84-a364-47b0-aa8f-101d28a0dce4). WHOOP: "Have
you delivered?" at week 40, and a mode switch that warns it "will reset the data"
(https://mobbin.com/flows/de10510d-1531-4905-8d3d-d89c5292e009). Clue's mode picker, "You can change this later at
any time" (https://mobbin.com/screens/ff343537-91bf-4235-a8ca-e667ee69f8bf); Flo's "You're going to switch to Get
Pregnant Mode" confirm (https://mobbin.com/screens/0313c72a-488f-4267-ab78-40616abab989).

**Adopted.** The "Expecting again?" guard takes Apple Health's intro-sheet shape (picture, two lines, one main
button) in our look. Each pregnancy as its own record confirms R1 (the `pregnancies` table).

**Declined.** WHOOP's reset on switching: our moves never wipe anything.

**Owed.** Say what changes before it changes (Clue, Flo) when the real moves are built (STAGE-TRANSITIONS R1).

## 36. Skilling doors 1 to 3 in the house look (2026-10-25)

**Why.** The user: "skilling right now doesn't look like it's from the ParentVeda app". The skilling shell
predated the house passes (violet eyebrows and buttons, pink and purple tabs, a 3D coverflow selector, tinted cards
with text on colour, grey boxes behind text). Mobbin set the UX; the other stages' doors set the look.

**Queries.** Screens "kids learning app skill topic overview screen with lessons by age", "learning app single activity
lesson screen with steps and done button", "parental gate screen in kids app", "Headspace course detail screen with
sessions list", "learning app progress collection screen showing completed activities without scores".

**Found.** Headspace's course page and Related shelf (https://mobbin.com/screens/3107561f-a33b-4e3f-bf65-2cd58ff0e99e,
https://mobbin.com/screens/c2893ded-d3e0-4c42-b7c3-571bc5ea8aea, https://mobbin.com/screens/3a435349-e9c8-4a37-8759-6abf32039ed9);
Duolingo ABC's level card and "Hi, grown ups!" gate (https://mobbin.com/screens/b06fe8bf-e3b9-44d2-9c7f-68f550e65b4d,
https://mobbin.com/screens/e6128e52-cdb4-42ed-9f4a-b489881650c2); Tiimo's lesson with one ink commit
(https://mobbin.com/screens/8e1d32ac-9eef-4110-8a22-37d8c0f2eaa5); Mindvalley's task list
(https://mobbin.com/screens/562375df-75dd-4056-8e47-e24192d1ad78); Quizlet's numbered steps
(https://mobbin.com/screens/0205337f-dbee-4a2e-aa43-43668ad2cdb7); Babbel's learning plan, colour in the picture
only (https://mobbin.com/screens/832f5742-a189-409a-8bb1-06f5ed82bb60); Amazon Alexa and Meta parental consent
(https://mobbin.com/screens/3f28566d-9464-4e52-a705-1c996b59f231, https://mobbin.com/screens/dd94dbd9-2e7f-4bfe-a54e-0b2779aeb112);
Greenlight's parent view (https://mobbin.com/screens/c7930268-5663-4943-b06c-867b37a7cd01); Bloom's day list
(https://mobbin.com/screens/a0fdac30-b299-4cea-9cbc-56148bf0956f).

**Adopted.** The flat tab rail and shelf card the other doors use (mirrored by value in `sk_door_chrome.dart`); one
ink commit per screen; numbered steps as ink rings; lists as rows on hairlines; consent as plain lines with ink ticks;
colour only in the picture and the mark's disc. Prototype: `claude.ai/artifact/GQdX4MLR4aCv4tSmqBVncb`.

**Declined.** Cartoon level maps, coins and streak counters (Kit, Duolingo, Mimo): skilling never scores a child.
Spotify Kids' dark purple ground.

**Owed.** The skilling home: built 2026-10-26, §37.

## 37. The skilling home and its bottom bar (2026-10-26)

**Why.** After doors 1 to 3 (§36), the home still read as a design preview: "SKILLING · DESIGN PREVIEW", a grey
banner, a compass card, two "Decided" cards, a violet field and four pink or purple tiles. The other three homes share
one shape: a hero about the person now, "My daily insights", "Explore by topic", rows.

**Found.** Babbel's Today home, today's card first (https://mobbin.com/screens/0fed600b-7bf0-4fe7-bcfd-d614d8a27c51);
Blinkist's daily shelf (https://mobbin.com/screens/e90fec6c-888d-458d-ab1b-984e0398127d); Atoms' daily lesson, then
the topic list (https://mobbin.com/screens/709913b3-cb23-4aa0-96b8-26dd73a932c7); GoHenry's Learn grid of topics for
a child (https://mobbin.com/screens/9bcd500f-f446-492e-8af1-1a50702b6db5).

**Adopted.** Today first, one thing per open door; the topic grid second with unbuilt topics labelled rather than
hidden; recent activity as plain rows; a five-tab bar whose thin tabs say what is coming and link to what exists.
Prototype: `claude.ai/artifact/1wkwCdtNts4X1z9FYi4tek`. As built: SKILLING-DOORS-REVIEW "The home and its bar".

**Declined.** Coins, streaks and XP (Duolingo, Nibble, Brilliant): skilling never scores a child.

**Owed.** Learn, Products and Tools with their own content (they point into the doors for now).
