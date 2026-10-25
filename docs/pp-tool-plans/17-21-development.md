# Tools 17-21: the Development family

## Context
Parenting tools pass (`docs/pp-tool-plans/00-MASTER.md`). 01-07 committed b11b2ec; Health 08-16 committed 66a1610 (README rows + sync step still say BUILT: record it now). The user: "do the Development family (17-21) the same way as Health, with a Mobbin pass for each tool and the backend done." This plan was approved on 2026-10-25 and copied here.

Tools: This month's checklist (`pp_month_checklist`), Milestones (`pp_milestones`), A gentle check-in (`pp_dev_checkin`), Activities (`pp_activities`), Your child's phases (`pp_leaps`).

## Mobbin pass (2026-10-25)
| Tool | Reference | Adopt | Decline |
|---|---|---|---|
| This month's checklist | Angi month to-dos https://mobbin.com/screens/dd38004b-eb0f-448e-804b-0861b92a461f ; Walmart checklist chips with counts https://mobbin.com/screens/3409c219-306c-4f9e-ac95-3e79dea946fe | A tick per row that stays ticked (with Undo); "See all in Milestones" | — |
| Milestones | Walmart chip counts (above); Tiimo "0/7" https://mobbin.com/screens/99dab3c1-f5f5-4cb2-88b9-fea41d8c3e8d ; Saturn "Mark as done" sheet with date https://mobbin.com/screens/c1c6d90c-bcf2-4334-b936-630a87738d1e | A search result opens the save sheet directly; a date row on save; a "Seen" count per area, never a score | Progress % rings |
| Gentle check-in | Apple Health questionnaire "Next steps / not a diagnosis / take it again in two weeks" https://mobbin.com/screens/3c8ad2b2-26b9-4931-b8ab-d08688e05b31 | Result = next steps + not-a-diagnosis + "Check again in a few weeks" (Start again) | Hers / Finch / BitePal score bars and severity labels (forbidden) |
| Activities | foodpanda chips + "That's all" https://mobbin.com/screens/28fee3ea-cf93-47a5-8eaa-5ea289a82822 ; Saturn "Mark as done" (above) | Area chips that a link can preselect; a "We tried this" tick | Streaks |
| Your child's phases | Bumble done/now/next timeline https://mobbin.com/screens/09426d05-9e3c-4a74-b206-da7d04e07ba4 | (only if kept as a tool) | Dated fussy-week predictions |

## Audit (three read-only audits; key claims checked against the code)
| Tool | Broken / Wrong (summary) |
|---|---|
| **Checklist** | **Wrong:** a ticked row vanishes at once (`emerging` drops ticked ids, `pp_milestones_data.dart:577`), so untick/Undo can never run; only the first 6 skills show (movement first) with no "see all"; "the milestone journey" stale name as plain text; no disclaimer under "Call the doctor if"; no widget test |
| **Milestones** | **Wrong:** saving says nothing (`ppLogSheet`, `pp_tools_kit.dart:250`), Undo silent; date seen always today; a ticked current skill moves under "Usually settled by now… windows already passed"; quick log is 5 taps; "he" hard-coded in the sheet (`milestone_journey_screen.dart:374`); age label uses real age while the list uses corrected; 0-12 month items unsourced, not REQUIRED_REVIEW; no disclaimer; door says "Where your baby is right now" / "His milestones". Backend OK (per child since c70a791, table `pp_milestone_observations`, contract-tested) |
| **Check-in** | **Wrong (high):** a newborn is told "Worth a word with your doctor": smile-back and turn-to-voice are red flags from month 0 (`pp_development_data.dart:592`). Ages disagree with the milestones data (sit / babble flagged from 6 m vs mention-at 9 m; words from 12 m vs 16 m). Uses birthday age, not corrected. **Answers not per child** (`q|<text>` in `DevStore`, a sibling inherits them). A "yes" to lost skills hidden until all answered; answers never expire, no start again; "Questions to take to the visit" opens a generic Ask Veda |
| **Activities** | **Wrong:** five "today" labels land on the full list (R3: door, `parenting_surfaces.dart:69`, early learning, hub, journey); area links ("Talking activities…") open the top, not that area; **`DevStore` seeds every install with fake `peekaboo` saved and `tummy_play` done**, nothing live writes to it, yet recommendations read it (`pp_reco_data.dart:1116`); can't mark done; birthday age; no redraw on child switch |
| **Phases** | Reading pages in the shared reader (`PpPhasePage`), not a tool. Weak: no redraw on child switch (`late final _current`); a 6-year-old sees "This phase · 4–5 years"; "A new stage" message uses birthday not corrected age (`pp_messages_store.dart:348`); on `_owedShell` |
| **Cross-cutting** | No `PpUseKind` for development; nothing reads milestones / check-in in relevance, the doctor visit or reminders |

## Decisions (user, 2026-10-25)
| # | Question | Recommended | User's answer |
|---|---|---|---|
| D1 | R3 "today" links that open all activities | Rename to match | **Rename to match** |
| D2 | A "We tried this" mark | Yes, per child, synced | **Yes, per child, synced** |
| D3 | Milestones + check-in into Before you see the doctor | Yes, ask once | **Yes, ask once** |
| D4 | Phases in the Tools tab | Take it out (reading, not a tool) | Asked "why do we need to include phases screens for tools?" → mock https://claude.ai/artifact/LSoTj7yHkitozcMyBJi4Aa → **Take it out of Tools** |
| D5 | Check-in vs milestones ages (chosen, obvious) | One source of ages | Recorded: each question asked from, and flagged from, the milestones data's "mention at" month |

## Build, in three waves (each ends green, backend closed)

### Wave 1: backend (per child, honest state, consent)
- **`DevStore` check-in answers per child.** New items `q|<childId>|<text>` holding `{yes, at}` (the date answered). Reads go through the active child; legacy `q|<text>` items stay untouched and are read only when the family has exactly one child (the 16mm lazy fallback, nothing deleted). `kCheckInRenames` still applies inside the key.
- **`DevStore` tried activities per child.** `c|<childId>|<activityId>` holding the date tried. The fake starter `{'peekaboo'}` / `{'tummy_play'}` commented out (kept for revert). Saved activities: recommendations read the reader's bookmarks (`PvReadStore`) instead of `DevStore.savedActivities` (`pp_reco_data.dart:1116`, `pp_grow_data.dart:523` checked the same way).
- Redraw on child switch: Activities, check-in and phase page listen to `ChildProfileStore`.
- **Consent kind `development`** in `PpUseKind` ("Milestones and check-in answers": why "so Before you see the doctor can list them"). Ask card on the first milestone save or first check-in result.
- No migration (`user_state` per-item merge takes any key). Sync log **step 19**, STILL-OPEN-BACKEND row 19 (R1 took 18 the same day), BACKEND-PATTERNS §16pp "a keyed answer store per child: put the owner in the item key, and an unowned legacy item is read only when it can belong to one child". Also record 66a1610 in README + step 17 commit line.
- Tests `test/pp_development_tools_test.dart`: two children's check-in answers and tried activities stay apart; legacy answer read with one child, not with two; no fake starter rows; merged-store item keys pinned (server played as in `pp_use_consent_sync_test`).

### Wave 2: the check-in is safe (clinical)
- `CheckInQ` gains `fromMonths` (asked from) and `flagFrom` (counts as a red flag from), taken from the milestones data's mention-at months: smile back from 2 m (flag from 3 m), turn to voice from 4 m (flag 6 m), sit from 6 m (flag 9 m), babble from 6 m (flag 9 m), few words from 12 m (flag 16 m), lost-skill question from 6 m. A question not yet due is not asked; under about 6 weeks the screen says "It's early for a check-in. Questions start around 2 months" with Milestones linked (shown, not hidden).
- Corrected age (`devAgeInMonths`), pronouns from the profile.
- A "yes" to lost skills shows the result at once; answers older than 6 weeks show as "answered <date>" with **Start again**; result keeps "This is not a diagnosis".
- "Questions to take to the visit" opens Before you see the doctor with the "not yet" items added as questions (with the `development` yes; without it, it opens the visit screen empty-handed and says so).
- All REQUIRED_REVIEW; BEFORE-LAUNCH clinical review gets the check-in ages and the 0-12 month milestone windows.
- Tests: newborn gets no red-flag result; ages agree with milestones for every flagged question; corrected age; early lost-skill result; start again.

### Wave 3: each tool's UX (Mobbin above)
- **Checklist:** a ticked row stays, ticked, with a toast + Undo (`emerging` gains an include-ticked variant for this screen); all emerging skills grouped by area or a "See all in Milestones" row; "Milestones" as a link; disclaimer line under "Call the doctor if". Widget test.
- **Milestones:** save toast "Saved: <skill>, seen <date>" with Undo; a date row on the save sheet (today by default); a search result opens the save sheet directly (2 taps + optional note); a ticked skill stays in its own group with a tick, not under "already passed"; pronoun from the profile; `ageLabelWithCorrection`; empty "Up next" says what to do; REQUIRED_REVIEW + source line on 0-12 m items; disclaimer line. Door rows renamed "Milestones" with the blurb filled for the child (doors' label passes through `ppFillChild`).
- **Activities:** "We tried this" on each row and in the activity reader (toast + Undo, per child); area chips; `pp_activities/<area>` alias so "Talking activities…" links land on that area; corrected age. R3: the five "today" labels become "Activities for <age>" / "Play ideas for this age"; the Tools tab comment marking the door label owed is closed.
- **Phases:** redraws on child switch; past 5 years the kicker says "Earlier · 4–5 years" with a "Past five: the learning space has your child's age now" line; "A new stage" message uses corrected age. **Out of Tools (D4):** the Tools tab row commented out (kept for revert, dated); `test/pp_tools_tab_test.dart` C1 allow-list gains `pp_leaps` ("reading in the reader, not a tool"); `pp_leaps` off `_owedShell`; README row 21 reads "Not a tool: reading (D4)". Home, My Child, door Phases tab and Is my baby OK? still open it.
- **Doctor visit:** with the `development` yes, a "Development" block: milestones seen in the last 3 months and check-in "not yet" items as questions.

## Files (main)
`pp_development_data.dart` (CheckInQ, DevStore), `development_checkin_screen.dart`, `development_all_activities_screen.dart`, `development_activity_screen.dart`, `pp_month_checklist_screen.dart`, `milestone_journey_screen.dart`, `pp_milestones_data.dart`, `pp_tools_kit.dart` (ppLogSheet toast), `pp_phase_page.dart`, `pp_phases_data.dart`, `pp_messages_store.dart`, `health_doctor_visit_screen.dart`, `pp_reco_data.dart`, `pp_grow_data.dart`, `lib/services/pp_use_consent.dart`, `pp_tools_tab.dart`, `pp_surface_router.dart`, `parenting_surfaces.dart`, `pp_door_development.dart`, `pp_door_early_learning.dart`, `pp_early_learning_content.dart`, `parenting_hubs.dart`, `parenting_journeys.dart`, `pp_development_content.dart`. Tests: new `pp_development_tools_test.dart`, `pp_checkin_safety_test.dart`; updated `pp_tools_tab_test.dart`, `pp_tools_one_look_test.dart`, `pp_checkin_escalation_test.dart`, `pp_development_door_test.dart`. Docs: `docs/pp-tool-plans/17-21-development.md`, README, BACKEND-PATTERNS §16pp, sync log step 19, STILL-OPEN-BACKEND row 19, BEFORE-LAUNCH.

## Verification
- `git status` before edits (other terminals share the tree; only our files).
- After each wave: `flutter analyze` on touched files; new tests plus neighbours (development door, early learning door, checkin escalation/rename, age aware, child records, records merge, sync guard, cloud merged store, tools tab, one look, phase page, care screens, health screens, wave8, use consent sync).
- Wiring gate: grep every route into the five surfaces, every renamed "today" label, every `allows(PpUseKind.development)` reader.
- Phone walk only on the user's word; give git commands at the end (explicit paths).

## Added mid-pass: one drawn mark per Tools row (the user, 2026-10-25)
The user: "make sure the tools section the UI is consistent with marks/glyphs tbh, for icons i mean".
- **Found:** rows took their glyph from the shared `ttcFamilyMarkForIntent`. Five of its marks had no drawing (Sleep Sounds, Fever check, Home remedies, Activities, What to feed), so those rows showed a Material icon in a square. Thirteen rows shared a glyph with another row: three bowls (Feeding, Can my baby eat this?, Recipes), three checklists (Nappies, Pumping, Before you see the doctor), three lotuses (Can I...?, Kegel Care, Yoga), two open books, two heart-hands. Vaccines drew a pill, and Emergency card drew two speech bubbles.
- **Fixed:** each `PpTool` names its own drawn mark (`tab:` or `tool:`), chosen by eye from a rendered sheet of every mark. The shared mapping is untouched, so doors and pregnancy don't change. Before/after, rendered from the app's widgets: https://claude.ai/artifact/SzB521H7bV2tPqmht3Ftkv
- **Held by** `test/pp_tools_tab_test.dart`: every row has a drawn mark, no two rows share one, and on screen every row draws a `TtcMarkLeading`.
- **Owed art:** a moon (Sleep uses the clock for now) and a nappy (Nappies uses the drops). **Not in scope:** door tool cards still draw Material icons (`pp_door_screen.dart`, the doors pass's file); they can reuse these marks by surface id.

## Built (2026-10-25)
- **Wave 1 (backend):** `DevStore` per child in the item key (`q|<childId>|<text>` holds `{yes, at}`; `c|<childId>|<id>` holds the day tried). Unowned items are kept and read only with one child. Fake starter rows are commented out. Recommendations read reader bookmarks. New consent kind `development`. Sync step 19, STILL-OPEN-BACKEND row 19, BACKEND-PATTERNS §16pp. The Health commit `66a1610` is recorded in step 17 and row 17.
- **Wave 2 (check-in safe):**
  - `CheckInQ.askFrom` / `flagFrom` / `countsFrom`. A question is asked only from its month, and a "not yet" counts only once due.
  - Under 2 months the screen shows "It's early for a check-in" (with a link to Milestones) instead of questions.
  - Corrected age.
  - A lost-skill "yes" shows the result at once.
  - Start again (with Undo); answers dated, with a line once they are older than 6 weeks.
  - "Not a diagnosis" on every result. Drawn marks replace the result's Material icons.
  - "Questions to take to the visit" adds the "not yet" items to Before you see the doctor with the `development` yes; without it, the visit screen opens and says how to turn it on.
- **Wave 3 (UX):**
  - **Checklist:** a ticked skill stays, ticked, with Undo both ways (`MilestoneStore.inWindow`); one skill from each area in turn, 8 shown, "See all N in Milestones" link; a not-a-diagnosis line; a drawn mark.
  - **Milestones:** save toast with the day and Undo; a "Seen today · Change" date row; a search result opens the save sheet directly; a seen skill stays in its window (only truly passed windows go under "Usually settled"); the corrected-age label; pronoun filled; the empty "Up next" says so; a not-a-diagnosis line; the ask-once card after the first save; detail-sheet Undo says what it did. Door rows renamed "Milestones" (Development and Early learning), without the fixed "His".
  - **Activities:**
    - Area chips, and `pp_activities/<area>` (five "Talking / Movement activities" links now land on their area).
    - "We tried this" on every row and on the activity's page (per child, toast and Undo, "Tried today" meta).
    - Corrected age; redraws on a child switch.
    - **R3 settled:** seven links that opened the full list ("Things to do together today", "Something to do today", "Something to try today", "Today's activity") now say "Activities for this age" / "Activities". Three of the four `pp_development` links that looped back to the door now open Activities (two on movement); the fourth sat beside "More activities, by area" and is commented out.
  - **Phases:** out of the Tools tab (D4; C1 allows `pp_leaps` by name; off `_owedShell`); the page follows a child switch; past five, no phase says "This phase" and the last one says so; "A new stage" reminders use corrected age (applied to the child on screen, since `bornWeeks` is per family).
  - **Doctor visit:** a "Development" row (milestones seen in the last 3 months), with the yes only, on screen and in the shared text.

## Verified
- New: `test/pp_development_tools_test.dart` (7), `test/pp_checkin_safety_test.dart` (7), `test/pp_development_screens_test.dart` (10). Updated: `pp_tools_tab_test` (marks + C1 allow-list), `pp_tools_one_look_test` (`pp_leaps` off owed), `pp_checkin_escalation_test` (lost skill from 6 months), `pp_age_aware_test` (bands checked where all are due), `pp_development_door_test` (door label "Milestones").
- Analyze clean on every touched file (four notes in `pp_home_v3.dart` predate this change).
- **Every parenting test file (136): 1630 tests pass.**
- **Found by that run, and fixed:** `test/pp_care_logs_tool_test.dart` failed on the last commit too. The cause was real: child ids were the clock alone (`child_<microseconds>`), so two children added back to back could share one id, and every store treated twins as one child. Ids now carry a counter, as feed ids do (`ChildProfileStore._newChildId`, `pp_child_profile.dart`); saved ids keep their shape. Pinned in `pp_development_screens_test.dart`.

## Found, not in this scope (recorded)
- Door tool cards draw Material icons (`pp_door_screen.dart` `tool.icon`); the Tools tab marks could be reused by surface id once the doors pass is done.
- `PpHomeActivitiesStore` (home's three picks a day) is device-local and not per child; its "done" writes through to `DevStore` (now per child), but the picks themselves are shared between twins.
- `bornWeeks` is one value per family, so corrected age (and now the stage reminder) can only be right for one child of a family with a premature twin or sibling.
- The quick-log search rows in Milestones still draw the domain's Material icon.
