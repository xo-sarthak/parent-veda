# Door 14: Papers and money, the plan

Written 2026-10-25. **Status: final. PM1 to PM7 are chosen and recorded under the user's rule (obvious decisions aren't asked). Nothing here needed the user's call.** The new copy is in `14-papers-content.md`. Nothing in `lib/` changes until step 0 (S1 to S11) and the user's go.

## Context
**Where it lives.**
- The door: `lib/data/doors/pp_door_papers.dart`
- The content: `lib/screens/post_pregnancy/pp_papers_content.dart`, 7 pages on 5 tabs, written 2026-10-02 for India
- **Not on the home rail on purpose:** `pp_home_reads.dart:48` (`_kNotForTheRail`). Kept.

**Tabs:** Your child's documents · Government schemes · Health insurance · Saving for your child · Planning ahead. Every name fits two lines on its card.

**Kept on purpose:**
- no product or provider is named anywhere
- "information, not financial advice", and "keep insurance and saving separate"
- each page says where to check, because rules change

### What parents actually ask
From `research/questions/ranked_parenting.csv`:

| Topic | Hits | Top questions | What it means |
|---|---|---|---|
| Insurance | 52 | **"is baby vaccination covered by insurance"** (24); "is child vaccination covered by Medi Assist insurance in India" (3); "is toddler speech therapy covered by insurance" (4) | The top question in the door, and no page answers it |
| Passport | 14 | "does a 3 month old baby need a passport" | The page says yes, but leaves out how long it takes, photos under 4, and single parents |
| Bank account, saving | 2 | "which child bank account is best" | Covered |
| Schemes | 1 | an education scheme a hospital told a parent about | Covered |
| Daycare costs | 1 | "we're drowning in daycare costs" | Not this door's job |
| Birth certificate, Aadhaar, tax, leave | 0 | — | Absent from the pool |

**Overall:** money and paper questions are almost absent. The pool is a health-question pool in English, so 0 means "not searched there", not "not needed". Every Indian parent needs a birth certificate. So nothing is removed and no big new pages are added: fix the order, add the links, answer the insurance question, and fill small gaps.

### What a parent meets today
1. **Every age opens on the same order**, and every page shows at every age. The Aadhaar update at 5 sits below the birth certificate for a 4-year-old.
2. **1 link in the section**, and it goes to the whole You, Maa section rather than the leave page.
   - Free vaccines doesn't reach Health's vaccine pages.
   - Anganwadi preschool doesn't reach Early learning's nursery admission page.
   - The passport doesn't reach Safety's flights page.
   - Nothing reaches Special care's disability papers (UDID, Niramaya, 80DD).
3. **The top question has no answer:** whether insurance pays for vaccines, OPD visits and therapy.
4. **Small gaps:**
   - birth certificate corrections and a name added late
   - a single parent's papers
   - legal aid for maintenance and custody
   - tax (80C and 80D)
5. **"Set a reminder for your child's fifth birthday"** (`pm_aadhaar`), with no way to set one.
6. **The document vault exists and the door never mentions it.** `BabyDocumentsScreen` (`pp_documents_data.dart`: birth certificate, Aadhaar, passport, insurance, medical) opens only from Health home (`health_home_screen.dart:110, 368`).
7. **No films, no hero photo, no closing.**

### A correction this audit made to door 13
You, Maa already has a full back-to-work area (`back_to_work`, `pp_you_maa_content.dart:6176`, 7 pages). It covers:
- the four-week countdown
- the bottle given by someone else
- what the leave entitles you to
- pumping at work
- childcare
- the guilt
- the first week back

Family's FM3 "Going back to work" page would have repeated it, so it is withdrawn and replaced by links (Family FM6). The leave rules live on `work_your_entitlement`. Papers doesn't add a leave page; it links there.

## PM1. Each age opens on what fits
**Tab order by age** (S1):

| Age | Order | Why |
|---|---|---|
| 0–12 months | Documents, Schemes, Insurance, Saving, Planning ahead | Today's order. The birth certificate has a 21-day window; PMMVY and adding him to insurance are first-year jobs |
| 1–6 years | Documents, Insurance, Saving, Schemes, Planning ahead | Schemes is mostly a first-year tab; insurance and saving matter more now |

**Within Documents:** from 3 years, `pm_aadhaar` comes first, because the free biometric update is due at 5. Nothing folds away: a late birth registration or a correction can happen at any age.

## PM2. Links, from 1 to every page

| From | To |
|---|---|
| `pm_birth_certificate` | `pm_aadhaar` (the next document); Early learning's nursery admission page |
| `pm_aadhaar` | the vault (PM5) |
| `pm_passport` | Safety `safety_travel` (flying with a baby, SF3) |
| `pm_schemes`, free vaccines | Health's vaccine schedule |
| `pm_schemes`, anganwadi | Early learning's nursery admission page (anganwadi preschool) |
| `pm_schemes`, JSSK | Special care's NICU page |
| `pm_schemes`, new card "If your child has a disability" | Special care `sc_help_india` |
| `pm_health_insurance`, vaccines | Health's vaccine schedule |
| `pm_health_insurance`, therapy | Special care's therapies page (SC2) |
| `pm_planning_ahead`, leave | You, Maa `work_your_entitlement`. The page, not the section (M4 `PpLink.pageId`). The old section link stays commented out |
| `pm_planning_ahead`, single parent | Family's "Doing it on your own" (FM3) |

**Back the other way**, already planned in other doors: Early learning EL ("Papers for your child"), Safety SF3, Special care, and Family FM2/FM3.

## PM3. Answer what parents ask (copy in `14-papers-content.md`; REQUIRED_REVIEW)
- **`pm_health_insurance` gains "Vaccines, doctor visits and therapy"**, the door's top question:
  - most policies don't pay for vaccines or OPD visits
  - some family policies with maternity cover pay for the first year's vaccines, up to a limit
  - therapy is usually outpatient, so it is often not covered
  - the TPA named on the card answers claim questions
- **`pm_passport` gains:**
  - "Yes, from birth"
  - how long it takes, and Tatkal
  - the photo under 4
  - the name must match the birth certificate
  - single parents

## PM4. The small gaps, filled where they belong
- **`pm_birth_certificate`:** "If something is wrong, or the name comes late": corrections, and adding the name after a year.
- **Documents, a new card on `pm_birth_certificate`, "If you're raising him on your own":**
  - the certificate, Aadhaar and passport with one parent
  - free legal aid, NALSA 15100, for maintenance and custody

  Family's "Doing it on your own" points here.
- **`pm_schemes`:** the PMMVY card made exact (PMMVY 2.0), and the disability card (PM2).
- **`pm_saving`:** a "Tax" card, 80C and 80D, old tax regime only.
- **Five tabs stay**, though four have one page. Each tab name is a word parents look for, and each page is a full step list, not an empty screen. Merging would hide "Health insurance" inside "Money".

## PM5. Tools that do what the page says
- **"Keep his papers"**, a tool at the end of the Documents rail (`atEnd`).
  - It opens `BabyDocumentsScreen` through a new surface id, `pp_baby_documents`, in `pp_surface_router.dart`.
  - Reuse: the vault and its store exist and sync. Nothing is new except the route.
- **"Remind me before he turns five"** on `pm_aadhaar`.
  - It sets one reminder through `ReminderStore` (`lib/services/reminder_store.dart`), one month before his fifth birthday, with the date taken from his profile (derive, never ask).
  - The button says what it did: "Reminder set for [date]".
  - With no birth date saved, a `pvToast` says why, and offers to add the date (S8).
  - For a child already over 5, the line reads "The five-year update is due now. It's free at any Aadhaar centre."
- **No closing card.** No expert fits this door: the pages tell parents to ask a fee-only adviser, and we don't sell one. The vault tool is the door's last offer.

## PM6. Help, films and the hero
- **The door intro film** `papers/door_intro`; a tap says "still being made" (S8a).
- **A hero photo** (Unsplash, free): a parent at a table with a folder of papers and a baby on their lap.

## PM7. Dates on every figure
Rules and amounts change. Each page gets one quiet line at the top: "Checked October 2026. Rules change, so confirm at [where]." The REQUIRED_REVIEW comments stay, and the line is updated whenever a page is re-checked.

## Taps that can't happen yet (S8)

| Target | What she sees |
|---|---|
| The intro film | "still being made" |
| Remind me, with no birth date saved | a toast: "Add his birth date first, so the reminder lands on the right day", plus a button to add it |

## Build order (after step 0 and your go)
1. Tab order and the Documents order (PM1)
2. Links (PM2)
3. Copy additions (PM3, PM4, PM7)
4. The vault route, the tool, and the Aadhaar reminder (PM5)
5. Film and hero (PM6)

**Reuse:**
- the S1 tab order
- M4 `PpLink.pageId`
- `BabyDocumentsScreen` and `BabyDocumentsStore`
- `ReminderStore`
- `pvToast` S8a

## Verification
- `test/pp_gap_doors_test.dart` for this door:
  - the opening tab and its order at 0–12 months and 1–6 years
  - `pm_aadhaar` comes first in Documents from 3 years
  - every link resolves
  - `pp_baby_documents` routes to `BabyDocumentsScreen`
  - the insurance page carries the vaccine card
- A reminder test: the date is one month before the fifth birthday, and with no birth date nothing is set and the toast shows
- `door_names_fit_test` ("Keep his papers")
- `flutter analyze` on touched files
- grep call sites: the new surface id, and the reminder button

## Decisions
These stay here on purpose. When a problem turns up later, check this table first: if an answer covers it, the fix follows that answer.

| # | Decision | Why (what parents want) | Answer |
|---|---|---|---|
| PM1 | 0–12m today's order; 1–6y Documents, Insurance, Saving, Schemes; Aadhaar first from 3y | Schemes are first-year; the Aadhaar update is due at 5 | **Yes**, chosen and recorded (2026-10-25) |
| PM2 | Link every page to the page that answers the next step | 1 section-level link today | **Yes**, chosen and recorded (2026-10-25) |
| PM3 | Answer "is vaccination covered by insurance", and the passport details | The door's two most-asked questions | **Yes**, chosen and recorded (2026-10-25) |
| PM4 | Corrections, single parent and legal aid, PMMVY exact, disability card, tax; five tabs kept | Small, real gaps; merging tabs hides words parents look for | **Yes**, chosen and recorded (2026-10-25) |
| PM5 | Vault tool on Documents; a real Aadhaar reminder; no closing card | The page says "set a reminder" with no way to; the vault is unreachable from here; no expert fits | **Yes**, chosen and recorded (2026-10-25) |
| PM6 | Intro film, hero photo | Plain fixes | **Yes**, chosen and recorded (2026-10-25) |
| PM7 | "Checked October 2026" line on every page | Figures change; she should see how fresh they are | **Yes**, chosen and recorded (2026-10-25) |
