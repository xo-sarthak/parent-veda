# Parenting doors, one at a time: master plan

## Context
The user finds the parenting doors text-heavy and badly ordered:
- Action doors lead with articles instead of things to do or watch.
- Complicated doors have little that explains them.
- Content is not ordered for the child's age. A 3-year-old's parent still lands on newborn material.
- Consults, classes and products sit at the very end, or are not shown at all.

The goal is to make every door user-first. We work one door at a time: a full audit, a per-door plan, approval, then the build. After that, we check which doors are thin or missing.

A side concern, not part of the door work: the parenting home's "My daily insights · Today" strip shows only 20–60-word tips (`ppHomeInsights()`, `pp_home_reads.dart:152`). It gets its own plan after the doors.

## What the audit found: problems every door shares
These need one shell fix each, not 14 separate fixes.

| # | Problem | Where | Fix (built once, before door 1) |
|---|---|---|---|
| S1 | The door opens on the first tab in file order. Age only removes tabs or locks them; it never picks the opening tab. | `pp_door_screen.dart:160-251` | Open on the tab with the most pages for her band, as TTC does with `ttcDoorOpeningGroup` (`ttc_phase_rank.dart:74`) |
| S2 | A page with no band tag is treated as matching every band, so newborn pages show for toddlers (Feeding, Sleep, First 40, Traditions) | `area.pagesFor`, `pp_section_screen.dart:280` | Each door's pass tags its pages. The shell stays the same. |
| S3 | The "Talk to an expert" closing is never drawn: it is commented out, and every door shows the same doctor sentence | `pp_door_screen.dart:672-719` | One expert row, placed early on help-type tabs (just under the red flag) and as the closing elsewhere. It uses the existing `PpDoorClosing` data. |
| S4 | No door intro video in any stage. TTC's `heroVideoSlot` exists but is never drawn. | GLOBAL-CHANGES #5 (Option A chip, already approved) | Add `introVideoSlot` to `PpDoor` and the chip to `_QuietHero`. Shows "coming soon" until a video exists. It matches the approved design, so all stages look the same. |
| S5 | A page card with format VIDEO is labelled "Article". All ~190 parenting videos are placeholders. | `pp_door_screen.dart:~1622` | Label it Video, with an honest "coming soon". List every video owed in `DOOR-CONTENT-OWED.md`. |
| S6 | No parenting words in the article-to-service matcher, and a page can show its own consult block plus the reader's offer (two pitches) | `pv_read_offer.dart:49-96` | Add parenting aliases (lactation, speech, sleep, child psychologist, physio). One pitch per page. Add a parenting case to `read_offer_coverage_test.dart`. |
| S7 | No test covers what a parent sees first | — | `test/pp_doors_first_view_test.dart`: for each door and each age, the opening tab and first card fit the child, and action doors lead with an action. This is GLOBAL-CHANGES #15, owed for parenting. |
| S8 | A tap that can't do anything says nothing. A shop link to a category we don't stock, a consult category with no people yet, a film still "coming soon", or a class not open for her week either does nothing or opens an empty screen, and she can't tell why. (User, 2026-10-24: "if some action is not able to take place due to unavailability, the user gets a toast, so the user can understand why a tap didn't work.") | every door's links, tools, offer cards, video slots | **No silent tap, anywhere.** Before opening, the tap checks the target is there. If it isn't, it shows one `pvToast` (`lib/widgets/pv_toast.dart`, `PvToastKind.info`) saying why, in plain words, and what happens next. Examples: "Postpartum belts aren't in the Store yet. We'll add them soon." "Our physios are joining soon. A gynaecologist can help today" with an action pill. "This film is being made." "This class opens after your six-week check." Each door's plan lists its unavailable targets and their toast words. Test: `pp_doors_first_view_test` taps every link, tool and offer on each door and fails if a tap produces neither a new route nor a toast. |
| S9 | A tab for a later age is locked ("From 1 year") and cannot be opened, even from a link on home. Parents read ahead, and stage follows age loosely. (User, 2026-10-24: "should we lock the content???", answered "Unlock, every door".) | `pp_door_screen.dart:214-252` (lock and sort) | **No lock, anywhere.** Later-age tabs open, sit last, and open with one line: "For later. This usually starts from {age}." The card says "For later". Outgrown tabs still drop. A link into such a tab opens it with the same line. The locked path is commented out, "kept for revert". Test: no door draws a lock icon. |
| S10 | A page she has read sinks to the end of its row (`pp_relevance.dart:175`), so a red-flag list ("Go now") stops being the first card after one read. | `ppRelevanceOrder` | Red-flag pages (format RED FLAG or FLAGGED, and any page a door pins) are exempt from read-sinking in every door. Proposed by the First 40 plan; the user answered FD2 "Yes, always first" 2026-10-24. Test: a read red-flag page is still first. |
| S11 | At a large phone text size the tab card cuts every name to one line with dots ("Getting to…"), in every door of every stage. | `pv_door_rail.dart:222-228` | Keep 2 lines at every text size and let the card grow, not the name shrink; the one-line rule is commented out, "kept for revert". `door_names_fit_test` gains a large-text render check. The width stays 150 (user, SL9: "make sure of tab width"): only the height grows, and a name that won't fit two lines at that width at large text is renamed. Answered yes 2026-10-24. |

### Step 0, as built (2026-10-25)
Held by `test/pp_doors_first_view_test.dart` (28 checks: every door at every age, at 1x and 1.5x text, on a 360dp phone).

| # | Built as | Note |
|---|---|---|
| S1 | `PpDoor.tabOrder`: band id → tab ids, first one opens | **The "most pages" guess is not used.** Every door plan now names its order by age, and the guess moved action doors off their action tab (First 40 at day 12 left Day by day; Potty left its timeline). With no order the door's own order stands. Each door's build fills `tabOrder` from its plan |
| S2 | Per door, as planned | No shell change |
| S3 | The consult card at the foot of every door with a `closing` (key `pp_door_closing_card`) | Doors without one (First 40, Traditions, Papers) keep the doctor sentence. The early placement on help tabs comes with each door's build |
| S4 | **Not built, on purpose** | The approved design (GLOBAL-CHANGES #5, Option A) is "no chip until the video exists", and no door film exists yet, so a field would have no reader. Built with the first film |
| S5 | **Kept as it is** | A film page with no film already shows as an Article with its reading time (gap analysis P1: a Video chip on a page with no film is an untruth). Says Video when its film lands |
| S6 | Parenting words in `kPvOfferAliases`, pointing at the courses Parenting has (sleep, weaning, language, motor, play, special needs, baby-proofing, the fussy stretches); one pitch per parenting page | Parenting has no consults in the catalogue yet (experts gated until Directus), so words point at courses. "delay" and "safe" left out: a late talker is not an autism course, a safe-sleep page is not baby-proofing. When paediatric consults arrive, add them to the same words |
| S7 | `test/pp_doors_first_view_test.dart` | |
| S8 | **One opener, `ppPushSurface`** (`pp_surface_router.dart`), with `ppSurfaceUnavailable` saying why | Nine parenting openers ended `if (screen == null) return;`: a link to anything not built did nothing. All call the one opener now. S8a: films and recordings not made yet answer a tap (`PvVideoPlaceholder`, `PvAudioPlaceholder`, every stage). S8b: an expert type we don't have names the nearest, with a pill. S8c: `pp_products/<shelf>` opens that shelf, or says we're still choosing. S8d: `pp_class/<name>` says it isn't open, with Tell me. S8e: six bare "Coming soon" notices say why and what's next; the other two (health guide, remedy detail) were already commented out by the other terminal |
| S9 | No lock anywhere. A later tab sits last, says "For later", opens on the first band where it has pages, with "For later. This usually starts from 1 year." | The lock panel is kept for revert |
| S10 | `alwaysFirst` on `ppRelevanceOrder`; `ppIsRedFlagPage` (RED FLAG, FLAGGED, pinned) | A read red-flag list stays first, ahead of anything a signal lifts Door 6 found the match is exact: First 40's two lists are `FLAGGED QUICK-REFERENCE` and were not covered. They are `pinned` instead (the "any page a door pins" clause), so the shared format test and every other door's order stay as they are (`06-first40.md` §12) |
| S11 | `PvDoorRail.heightFor`: the card grows with the text size, two lines always, width 150 | Shared with the pregnancy doors, so both stages got it. The card is keyed by its height so a text-size change never animates it shorter than its words. The `door_names_fit_test` large-text check came with door 7 (2026-10-25): measured in Manrope's own widths at the card's 100-point name width, at 1.0 and 1.3. It found 18 parenting tab names that take three lines or break a word, three of them at the normal size; they wait for the user's words (`07-sleep.md` §12, `DOOR-CONTENT-OWED` SLO6) |

**Reuse:**
- `ppRelevanceOrder` (`pp_relevance.dart:160`)
- `PvVideoSlot` / `PvVideoPlaceholder`
- `pvReadOfferFor`
- `PvGoFurtherRail` (`pv_go_further.dart:206`; needs a stage parameter for the parenting age line)

**Clash note:** `pp_relevance.dart` and the home files have uncommitted Wave 8 changes from another terminal. Before touching anything, run `git status` and wait for that commit to land.

## S8 in detail: no silent tap (added 2026-10-24)

1. **No parenting expert can be booked today.** `ppExpertIsPlaceholder` (`pp_expert_honesty.dart:36-42`) gates the whole bundled roster, so every `pp_experts/...` tap opens the full "Our first experts are joining" page. That page isn't silent, so it stays. The S8 toasts are for the two cases it doesn't cover:
   - **A category that doesn't exist** (feeding therapist, paediatric dentist, eye, ENT, audiologist, allergist, chest, hormone). Today it falls back to the unfiltered list (`pp_surface_router.dart:127`). With real experts, that becomes the wrong list.
   - The CPR instructor has no `category` (`pp_experts_data.dart:207`).
2. **Video placeholders can't be tapped** (`pp_content.dart:1490` passes no onTap). The placeholder rule (`pv_placeholders.dart:26-29`) says one must not *look* tappable, so a mother who taps one gets nothing back.
3. **Shop links open the unfiltered shop** (`pp_surface_router.dart:465`). The link works but lands on something unrelated, against the cakes-not-pizza rule.
4. **Classes:** every bundled programme opens `ppProgramOpeningSoon`. This is honest, so it stays. Many named classes don't exist at all.
5. **Existing "Coming soon" toasts give no reason and no next step.** There are 8 screens: article archive, article reader, cohort and course funnels, guides tools, health guide, and journal ×3. One journal toast is still a raw SnackBar.

**The shell changes, S8a to S8e:**
- **S8a, video slots answer a tap.** The look stays the same: no play button, still not tappable-looking. A tap shows "This film is still being made. The steps are written just below." with a **Read it** pill that scrolls to the first section. On go-now pages, no pill and the words "follow the steps below now". This changes the placeholder rule from "must not look tappable" to "must not look tappable, and answers a tap honestly".
- **S8b, unknown expert category.** The router checks the category exists *and has people* before opening. If it doesn't, a toast: "We're adding paediatric {role}s. A {nearest} can check this first." with a pill to the nearest category that has people. Nearest map:
  - dentist, eye, ENT, audiologist, allergist, chest, hormone → Paediatrician
  - feeding therapist → Speech therapist
- **S8c, shop links filtered.** `pp_products/<subcategory>` opens the shop filtered to that subcategory. If the subcategory has 0 items, a toast: "We're still choosing a good {item}. {one-line buying tip from the page}." No pill, or a pill to the closest stocked item.
- **S8d, class names that don't exist.** The link checks the programme id first. If there is none: "This class isn't open yet. Tap Tell me and we'll let you know." The **Tell me** pill records interest the same way `pp_opening_soon.dart` does. On a page with steps, the pill goes to the steps instead (choking → "If he chokes").
- **S8e, reword the 8 bare "Coming soon" toasts** to say why and what's next, and replace the raw SnackBar with `pvToast`.
- **Test:** `pp_doors_first_view_test` taps every link, tool, offer and video slot on each door, and fails if a tap neither pushes a route nor shows a toast.

**No parenting consult can be booked today:** the whole bundled roster is gated until Directus serves real experts. That is already on the before-launch path (Directus). The door plans put consults next to the worry, but they open the "joining soon" page until then.

## The per-door audit (same checklist each time)
1. **List every element:** tab, rail, page, tool, video slot, activity, consult, product. For each: what it is, how deep it goes, and the age band.
2. **Door type:**
   - **Action** doors lead with something to do or watch: a session, an activity, a tool.
   - **Explain** doors lead with "how this works": a carousel or steps, then the red flag, then the expert.
3. **Order by age and situation:**
   - Opening tab, first rail and first card for each band.
   - Untagged pages get a band tag.
   - Outgrown material sinks or folds.
4. **Pitches in context:**
   - Consult next to the worry (not at the end).
   - Class or course next to the skill.
   - Product next to the activity that needs it. Never on urgent or loss pages. One per page.
5. **Depth:** thin pages (<600 characters) are rewritten. Single-page tabs are merged or filled. Duplicates point to one source.
6. **Owed media:** every video, demo or audio the door needs, listed in `DOOR-CONTENT-OWED.md` (film brief, length).
7. **Output:** the door test is updated to the new map, plus a Mobbin check for any new pattern. If a layout changes, an Artifact prototype comes first (light mode only).

## Door order (worst fit for the user first)

| # | Door | Type | Main problem |
|---|---|---|---|
| 1 | **Feeding** | Action | Worst age mismatch: a toddler gets 5 newborn tools, mastitis pinned on top and 20 untagged milk pages. 10 consults, all buried. |
| 2 | Health | Explain | Unwell → expert is at the end. 7 tabs. The emergency card is duplicated. A video page with no content. |
| 3 | You, Maa | Action (movement) | Exercises are buried in tab 2 and tab 3, with no demos. 20 consults. |
| 4 | Development | Action | Opens on checklists. "What to do" is tab 4 with 5 pages. The activities are hidden behind a tool. |
| 5 | Potty | Action | Opens on one chart card. No tools. |
| 6 | First 40 Days | Action | Only Day by day changes with age; the other 4 tabs (41 of 46 pages) are the same on day 3 and at 3 months. "Your recovery" is 5 windows into You, Maa plus 3 real pages. (Corrected 2026-10-24 by the door audit.) **Built 2026-10-25** (`06-first40.md` §12): a week shelf on Day by day, Your recovery first from two months. |
| 7 | Sleep | Routine | Safe sleep and waking framed for infants, shown to toddlers |
| 8 | Behaviour | Mixed | Calming activities are in tab 5. Dead code. Thin pages. |
| 9 | Early learning | Action | Best fit already. Needs activity demos and rhymes. |
| 10 | Traditions | Explain | Newborn ceremonies stay tab 2 for older children |
| 11 | Safety | Explain | No visuals at all; even CPR is text. No pitches, no hero photo. |
| 12 | Special care | Explain | 11 pages. Opens on NICU for everyone. |
| 13 | Family | Explain | 16 pages. Father signal unused. |
| 14 | Papers and money | Explain | 7 pages, 4 single-page tabs |

## Thin and missing doors (for the user to decide, after the door work)
**Thin, needs breadth:**
- **Special care:** missing autism, ADHD, speech or hearing delay, cerebral palsy, Down syndrome, therapies (OT, speech, physio), RBSK/DEIC early intervention, UDID card and schemes, school inclusion.
- **Papers and money**
- **Family:** single parents, adoption, couple after baby
- **Safety**

**Candidates for missing doors:**
1. **Everyday care:** bath, nails, nappies, clothes, teeth. Today this lives only in First 40, which stays on home but moves to last after 3 months and is written for the newborn weeks. (Corrected 2026-10-24: the door is never removed.)
2. **Travel and outings with a child**
3. **Play and active movement for the child:** motor play, outdoor. Development and Early learning don't own it.
4. **Childcare and back to work:** daycare and nanny choice. Today it is 2 pages in Family and 9 in You, Maa.
5. **Allergies, eczema and long-term conditions:** today scattered inside Health.
6. **Screen time and digital life:** today an area in Behaviour.
7. **The next baby:** spacing, trying again. Bridges to TTC.

A new door = a section + content + door file + test. Each one is its own plan.

## How we proceed
1. **The user approves this master plan.**
2. **Step 0, shared shell fixes S1–S11.** One small batch with Parenting tests. This comes first because every door depends on it.
3. **Door 1, Feeding.** A full audit using the checklist above, then a written per-door plan, then the user's approval, then the build.
4. **Doors 2–14**, the same way, one at a time.
5. **Thin and missing doors:** the user decides.
6. **The home Today strip:** its own plan.

## Verification (each step)
- Tests:
  - `flutter test` on that door's test, plus `pp_doors_sanity_test`, `pp_relevance_test` and the new first-view test
  - `flutter analyze` on the touched files only (stage tests only, per memory)
- Wiring gate: grep the call site of each new widget or field.
- Phone walk only on the user's word. Build only when asked.
- Update docs in the same change: `docs/GLOBAL-CHANGES.md` (#5 and #15, parenting), `docs/PARENTING-DOORS-REVIEW.md`, `DOOR-CONTENT-OWED.md`, and a STILL-OPEN entry.
