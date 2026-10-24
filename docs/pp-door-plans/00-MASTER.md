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

**Reuse:**
- `ppRelevanceOrder` (`pp_relevance.dart:160`)
- `PvVideoSlot` / `PvVideoPlaceholder`
- `pvReadOfferFor`
- `PvGoFurtherRail` (`pv_go_further.dart:206`; needs a stage parameter for the parenting age line)

**Clash note:** `pp_relevance.dart` and the home files have uncommitted Wave 8 changes from another terminal. Before touching anything, run `git status` and wait for that commit to land.

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
| 6 | First 40 Days | Action | Identical at every age. "Recovery" is links only. |
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
1. **Everyday care:** bath, nails, nappies, clothes, teeth. Today this lives only in First 40, which is gone after 40 days.
2. **Travel and outings with a child**
3. **Play and active movement for the child:** motor play, outdoor. Development and Early learning don't own it.
4. **Childcare and back to work:** daycare and nanny choice. Today it is 2 pages in Family and 9 in You, Maa.
5. **Allergies, eczema and long-term conditions:** today scattered inside Health.
6. **Screen time and digital life:** today an area in Behaviour.
7. **The next baby:** spacing, trying again. Bridges to TTC.

A new door = a section + content + door file + test. Each one is its own plan.

## How we proceed
1. **The user approves this master plan.**
2. **Step 0, shared shell fixes S1–S8.** One small batch with Parenting tests. This comes first because every door depends on it.
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
