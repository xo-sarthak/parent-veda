# Door 14: Papers and money, the plan

Written 2026-10-25. **Status: final. PM1 to PM7 are chosen and recorded under the user's rule (obvious decisions aren't asked). Nothing here needed the user's call.** The new copy is in `14-papers-content.md`. Nothing in `lib/` changes until step 0 (S1 to S11) and the user's go.

**Built 2026-10-26.** See "As built" at the end for what was built and where it differs from this plan.

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

## As built (2026-10-26)
Held by `test/pp_papers_door_test.dart` (28 tests): the tab order for every band; every page's age (a new page fails until it has a row; all seven are for every age) and no area tagged; Baal Aadhaar first in Documents from three, and the authored list untouched; the first view at 3 months (the birth certificate first) and at 40 (Baal Aadhaar first, the vault after every page, no closing card), on screen; **every link in the door, listed exactly, page by page**, each landing on a real page whose title is its label, and none to a whole section; `pm_schemes` not a story deck; the pages that link here (Family, Safety, Traditions) still do; the insurance cards, the passport additions, the corrections and single-parent steps, PMMVY's instalments, the disability card and tax; NALSA and 15100 nowhere in the door; no leave page; no provider named and no dollar sign; no when-line; "Checked October 2026" and where to confirm right after the intro on all seven pages; the vault route (`ppScreenForSurface('pp_baby_documents')` is `BabyDocumentsScreen`), its tool last on Documents at every age, and the call sites; the reminder's date (one month before the fifth birthday, January and 31 March included), a tap that sets it and says so, no birth date (nothing set, the toast and its "Add the date"), five already and the last month (the due-now line, no button), and the button at 360dp and 1.5x; the tab names; no film; the hero; off the home rail. `door_names_fit_test` measures both new names (fit at 1.0 and 1.3; both off `_kOwedShorterNames`, the old entries commented out). The parenting stage passes (`test/pp_*`, `post_pregnancy*`, `phases_test`, `door_names_fit_test`, plus `reader_unification_test` and `consult_call_test`, and the tests outside it that read a file touched here: `bracket_model_test`, `kegel_care_redesign_test`, `tap_feedback_guard_test`, `yoga_fitness_hub_test`, `ask_veda_mark_test`: 1,599 tests). The first run caught one failure this door's test could not: `pp_tools_tab_test` (C1, below).

**The shell: one new block, one route, one Tools row.** `tabOrder` (S1), `ageRail`, `PpDoorTool.atEnd` and `pp_page/<section>/<page>` covered the order, the links and the vault's place. Two things were new:
- **`pp_baby_documents`** in `pp_surface_router.dart`, to `BabyDocumentsScreen`, which only Health home opened. Nothing else in the vault changed.
- **Document vault on the Tools tab** (`pp_tools_tab.dart`, Plan and keep). The user's rule C1: a door may show a tool, never be the only way to it, and `pp_tools_tab_test` failed the stage run until it was listed. Its own drawn mark (the form card, `TtcToolMark.pcosCheck`; the folder is Health record's). Listing it showed it does not wear the tool shell (now on `_owedShell`, its own tools-pass turn) and that its "Add another document" button overflowed by 111px at 360dp and 1.5x; that overflow is fixed (a `Flexible` round the label), logged in `docs/pp-tool-plans/00-MASTER.md`.
- **`PpAadhaarReminder`**, a block in `pp_content.dart` that the reader carries as a custom section, drawn by `PpAadhaarReminderView` (`pp_aadhaar_reminder.dart`). A block of its own rather than a link, because the tap sets something instead of opening a screen, and a link is a next step at the foot of the reader, far from the callout it answers.

**What was built, by decision:**
- **PM1.** The tab order per band as the plan's table. From three, Documents opens on an age rail of its own three pages with `pm_aadhaar` first (`PpDoorTab.ageRail`, "Your child's documents"); the area rail then has nothing left and drops, so nothing shows twice and the authored list is not reordered. Every page stays untagged (every age), as the plan says: a correction or a late registration can happen at any age. Family, Safety and Traditions link three of these pages, and none needed a tag checked.
- **PM2.** Every page links the page that answers the next step, by page: the birth certificate to Baal Aadhaar, Early learning's `school_admission`, You, Maa's `people_separated` and Family's `fam_on_your_own`; Baal Aadhaar to the vault; the passport to the birth certificate (the single parent's forms) and Safety's `safety_travel`; the schemes to Health's `vax_schedule`, `school_admission`, Special care's `sc_nicu` and `sc_help_india`, and You, Maa's `work_schemes`; insurance to `vax_schedule` and `sc_therapies`; planning ahead to `work_your_entitlement` (the old section link commented out) and `fam_on_your_own`.
- **PM3.** Insurance gains "Vaccines, doctor visits and therapy" (vaccines, OPD, therapy, who to ask: the TPA). The passport opens on "Yes, even a newborn needs a passport of their own", and gains the name check, the photo under four, how long it takes and Tatkal, the fee, and "If one parent signs".
- **PM4.** The birth certificate gains "If something is wrong, or the name comes late" (three steps) and "If you're raising your child on your own" (three steps: registering alone, Aadhaar with one parent, the passport with Annexure C in place of D). PMMVY gives both instalments and their conditions; "If your child has a disability" is one card, with Special care linked for the steps. Saving gains "Tax, if you file under the old regime" (80C, 80D, the new regime). Five tabs kept.
- **PM5.** "Document vault", last on the Documents rail at every age (`atEnd`, no bands). "Remind me before your child turns five" under the Aadhaar safety callout (the old callout commented out). No closing card.
- **PM6.** Hero: Unsplash, free (Ashwini Chaudhary, `awkngZALcVw`, Badarkha, Uttar Pradesh), a child on an elder's lap at home, looking straight at the camera, checked by eye. No intro film slotted (S4).
- **PM7.** "Checked October 2026. Rules change, so confirm at …" as a titled callout right after the intro on all seven pages, from one constant (`kPpPapersChecked`), each naming its own place to check.

**A mechanism worth keeping: a story deck keeps no link to another door.** A CARDS page opens as the story deck (`ppCardsAsSlides`), and the deck turns a link into its closing slide only when the link is a `pageId` in the same section. A `surfaceId` link, which is every link to another door, is matched and then dropped, with no error and nothing on screen. `pm_schemes` was CARDS, so PM2's four links would have been written, tested and never seen. It is an ARTICLE page now (`format: 'CARDS'` commented out): the reader shows the same cards and the links. **This is not only this door's problem.** About forty CARDS pages in other doors (a rough scan) carry a cross-door link the deck drops (Safety's `safety_travel`, Family's `fam_you_two` and `fam_choosing_childcare`, Special care's `sc_hearing`, You, Maa's `work_schemes` and more). The general fix is one line in `ppCardsAsSlides` (return null for a `surfaceId` link, so the page opens in the reader), but it moves every one of those pages from the deck to the reader, so it is the user's call and was not made here (BEFORE-LAUNCH, DECIDE). The general point: a renderer that matches a case and returns nothing is a silent drop; a test that only proves the link resolves cannot see it.

**A second one: a when-line is a doctor line.** The reader draws `PpWhenLine` under "When to see a doctor" in the urgent tone. Papers used it for "A minor's passport is valid for five years" and "Ask your ASHA worker or the anganwadi first", so the passport's validity sat in a doctor box. Both are titled callouts now ("How long it lasts", "Who to ask"), the old lines commented out, and the door test fails on a when-line here. Other doors may use the block the same way; not swept here.

**A third: the store could not do what the plan said.** The plan reused `ReminderStore`. A `Reminder` is a time of day and a repeat with no date, so `once` rings at the next 9:00, not in 2031. Asked before building (the user, 2026-10-26: reuse `PpApptReminders`). That store is the child calendar's dated reminder: on this phone only, like the vaccine alarms, re-armed after the launch wipe (main.dart), reset on sign-out. It rings at 7 pm the evening before the day it is given, so it is given the next day and rings on the day itself.

**Single source, checked by idea, not id.** A grep of every door for each new idea found: PMMVY's amounts already on You, Maa's `work_schemes` (and named without amounts on First 40's money card); a single parent applying alone on Family's `fam_on_your_own`; legal aid and NALSA on You, Maa's `people_separated`; the name added after the ceremony on Traditions' `namkaran` (which links here); Niramaya, UDID and 80DD on Special care's `sc_help_india`. So Papers writes PMMVY's instalments and links `work_schemes` for the rest, writes only the how of a single parent's papers and links Family and You, Maa, never writes NALSA, and names the disability help in one card that links Special care. Insurance's vaccines, OPD and therapy, the passport details, the corrections and tax had no twin.

**Differences from the plan, and why:**
| Plan | Built | Why |
|---|---|---|
| "Every name fits two lines" | "Child's documents" and "Schemes to claim" (old labels commented out) | `door_names_fit_test` had both on `_kOwedShorterNames`. Measured (Manrope 700, 100pt line, 1.0 and 1.3): "Documents" and "Government" are each wider than the line at 1.3 and break mid-word. The user's words, 2026-10-26 |
| PM5 tool "Keep his papers" | "Document vault" | "his" breaks the page voice, and "papers" was vague; the user's word, 2026-10-26. Blurb: "A photo or PDF of the birth certificate, Aadhaar, passport and policy, ready when someone asks" |
| PM5 reminder through `ReminderStore` | `PpApptReminders`, phone-only | The store has no date (above). The user's choice, 2026-10-26. Not in her Reminders list; does not follow her to a second phone |
| Reminder re-derived "from his profile" | Re-derived from today's birth date whenever the page is drawn | Not at launch: `ChildProfileStore.init` runs after the alarm chain starts (`main.dart`), so a launch-time re-derive would race the profiles. The stored date still rings; an edited birthday moves it the next time the page opens |
| Reminder copy "he", "his", "Add his birth date first" | "your child", "Add your child's birth date first" | The section's voice |
| Child over five: the due-now line | Also inside the last month before five | There is nothing left to set once the reminder's day has come |
| No-date toast "a button to add it" | The toast's "Add the date" opens My Child, whose sheet holds the birth date | The place a birth date is saved |
| PM1 "Aadhaar first from 3 years" | An age rail of the three Documents pages for `preschool` | The bands are infant, toddler_1, toddler_2, preschool, so "from three" is preschool. `ageRail` keeps the authored list; `PpPage.ageLead` orders blocks inside a page, not pages |
| PM2 "M4 `PpLink.pageId`" | Every link, own pages included, is a `pp_page/parenting_papers/<id>` surface | `pp_gap_doors_test` asks every link for a screen through `surfaceId!`; door 12 crashed on this |
| PM2 `pm_schemes` keeps CARDS | ARTICLE | The deck drops cross-door links (above) |
| §1 / PM7: "one quiet line at the top" | A titled callout right after the intro | `pp_section_test`: every page opens with a `PpIntro`. A callout titled with the date is the quietest block the reader has that is not a doctor line |
| §2 single parent: "Maintenance and custody … free legal aid … 15100" | Left out; You, Maa's `people_separated` linked ("Maintenance, custody and free legal aid") | Single source: NALSA is written once, there |
| §2 the passport: "a declaration form for a single parent" | "Annexure C, the declaration for a single parent, in place of Annexure D, which both parents sign" | The user's brief: which form. Checked against Passport Seva's minors FAQ; REQUIRED_REVIEW, and the page says the portal lists which fits |
| §2 link labels "Next: Baal Aadhaar", "Papers for nursery admission" | "Baal Aadhaar for your child", "Nursery admission, step by step" | A link label that is another page's title keeps that title. The blurbs say why |
| §4 the photo "for very young children" | "For a child under four" | The Passport Seva rule names under four |
| §4 the single parent card | A callout "If one parent signs", linking the birth certificate page | The forms are on the birth certificate page; one place |
| §5 PMMVY "₹5,000 ($60)", "₹6,000 ($72)" | Rupees only | The user (door 12): money in rupees only |
| §5 "Free vaccines → The vaccine schedule", "Anganwadi → …", "JSSK → If your baby is in the NICU" | "What's due, and when", "Nursery admission, step by step", "If your baby goes to the NICU" | The pages' own titles; the blurbs carry the plan's words |
| §5 PMMVY only on Papers | Papers states the instalments and links You, Maa's `work_schemes` | You, Maa already states the amounts; both are on one BEFORE-LAUNCH line so a correction reaches both |
| §6 "Link: Therapies, explained" | "Speech therapy and the other therapies, explained" | The page's title |
| §8 "If you're parenting on your own" | "Doing it on your own" | The page's title; the blurb keeps the plan's words |
| PM6 hero "a parent at a table with a folder of papers and a baby on their lap" | A child on an elder's lap at home | Unsplash's free photos for papers, desks and passports are a tablet advert, a dark desk or no child. Owed PMO2 |
| PM6 door intro `papers/door_intro` | Not slotted | S4: no chip until a film exists. Owed PMO1 |
| PM5 "Nothing is new except the route" | Also a Tools tab row, and the vault's button overflow fixed | Rule C1 (`pp_tools_tab_test`); the overflow showed the moment the one-look test opened it at 1.5x |
| Verification: a Mobbin check, a prototype | Not run | The user's brief for this build; the one new control is a button in the house style |
| Verification: a phone walk | Not run | Only on the user's word. The reminder's date on a phone is on BEFORE-LAUNCH |

**Owed, not in this build:** the intro film (`DOOR-CONTENT-OWED` PMO1) and a closer hero (PMO2). No adviser, product or class is promised: the pages send her to a fee-only adviser, her insurer, the TPA and the government offices, none of which the app sells. On `BEFORE-LAUNCH.md`: a legal and money check of every scheme, document, insurance and tax line against current government notices, a phone check that the Aadhaar reminder rings on the right day, and the user's call on the story deck dropping cross-door links. The door's pages reach Ask Veda through the incremental ingest, which the user runs now that all fourteen doors are built.
