# C1: the Tools rows, both stages

## Context
C1 is the last family of the Pregnancy and TTC tools pass (`00-MASTER.md`, rule C1 and M6). Every tool a door, a home card, Learn or search offers must also be a row on that stage's Tools tab, and a test per stage holds it, the way `test/pp_tools_tab_test.dart` does for Parenting. Every family plan handed C1 something; this file collects all of it.

The audit was read-only, on 2026-10-30. The lead read both Tools screens and every hand-over, and ran a throwaway test (deleted afterwards) that printed every tool id the doors offer in both stages, so the gaps below come from the door data, not from reading. Every claim was checked at its file:line. The user answered three questions the same day. Terminal A's Tools-tab order (2eb7a77) is committed, so nothing waits.

Files the build touches (all clean in git on 2026-10-30; **run `git status` before each edit**):
- Pregnancy: `lib/screens/tools_hub_screen.dart`, `lib/screens/global_search.dart`, `lib/ask_veda/pv_veda_links.dart`, `lib/screens/tools/contraction_tracker_screen.dart` (the three sub-screens), `lib/services/scans_store.dart`, `lib/screens/pregnancy/calendar/preg_cal_data.dart`, `lib/screens/brackets/scan_timeline_screen.dart`, `lib/screens/post_pregnancy/pp_child_profile.dart`, `lib/screens/post_pregnancy/multichild_sheet.dart`, `lib/screens/profile/pv_you_sheets.dart`
- TTC: `lib/screens/ttc/ttc_tools_screen.dart`, `lib/screens/ttc/ttc_tool_marks.dart`, `lib/screens/ttc/ttc_calendar_screen.dart` (header mark), `lib/screens/ttc/chats/` (the shared chat shell's header mark), `lib/screens/ttc/ttc_ready_plan_screen.dart`, `lib/screens/ttc/ttc_semen_report_screen.dart`, `lib/screens/ttc/ttc_cycle_report_screen.dart` (the `toolId` only)
- Tests: new `test/preg_c1_tools_test.dart` and `test/ttc_c1_tools_test.dart`; updated pins in `test/preg_tools_shell_test.dart`, `test/ttc_tool_marks_test.dart` and any test that counts rows
- Docs: this file, `README.md`, `00-MASTER.md` (the stale item-4 line)

## Out of scope, said plainly
- **Door files** (`pv_door_*.dart`, `pv_door_router.dart`, `lib/ttc/focus/*`) are Terminal A's. C1 only calls `pvDoorScreenFor`, which is public. Anything a door still needs goes on the hand-over list at the foot.
- **The order of each Tools tab** is Terminal A's. New rows sit inside existing groups and take part in A's rules (`orderPregToolsByWeek`, `leadsOnClinicCycle`); no ordering rule changes.
- **Hiding rows by age, week or phase:** never (M5). The father preview is not that kind of hiding. It is his side of the app, and the rule (her trackers are hers) predates this pass. C1 makes search and Ask Veda follow the rule the hub already follows.
- **Is it safe? on `PregToolScaffold`:** P1 left it as a door (`can_i_door.dart`), and it keeps the door look.
- **"PCOS check" in the doctor check's summary rows** (`ttc_fertility_help_screen.dart:306`, `ttc_fertility_help_summary.dart:278`): these label a result in a summary, not the tool. The tool's one name, "PCOS symptom check", is already on its row (`ttc_tools_screen.dart:338`) and its page. Not changed.
- **The full TTC, Pregnancy and contract suite** runs next, in its own pass. C1 runs its two new tests, the pins it changes, and `flutter analyze` on the touched files.
- **BEFORE-LAUNCH, the sync log, BACKEND-PATTERNS, STILL-OPEN:** on the user's word.

## Findings (checked)
### Already done by the families (verified, nothing to build)
- Pregnancy rows: Calendar (`tools_hub_screen.dart:266`, P3 D4), Baby names (`:375`, P2 N1), Shopping list (`:294`, P4), and the Check in group (`:212`, P5 D1).
- TTC: the PCOS row is already "PCOS symptom check" (`ttc_tools_screen.dart:338`).
- X5, Calendar side: in the father preview the Calendar is read-only. Its tracker rows (`preg_calendar_hub.dart:821`), add sheet (`:615`) and item actions (`preg_cal_sheets.dart:455`) are all gated. Only "Open week N" stays, and the week cards are his to read.

### Pregnancy: tools a door offers that Tools does not list
| # | Tool | Door id | Opens |
|---|---|---|---|
| R1 | Is it safe? | `can_i` (Nutrition) | `CanIScreen` |
| R2 | Find a condition | `conditions/find` (Complications, inline) | `ConditionsHomeScreen` |
| R3 | Ingredient checker | `belly_skin/checker` | `IngredientCheckerScreen` |
| R4 | Tests and reports library (M7 put it back) | router `tests_scans` | `TestsScansReportsScreen` |
| R5 | Questions for your doctor (three lists) | `scans/questions`, `conditions/questions`, `nutrition/questions` | `PvChecklistScreen` |
| R6 | My scans | `scans/timeline` (Scans, inline) | `ScanTimelineScreen` |
| R7 | My reports | `scans/reports` (Scans, inline) | `ScanReportsScreen` |
| R8 | Report decoder | `scans/decoder` (Scans, inline) | `ReportScreen` |

- **R9 Wrong:** `test/preg_tools_shell_test.dart` pins `_Tool('Is it safe?'` and `_Tool(s.tsrTitle` as "never a row" (written 2026-09-30). M7 (2026-10-27) put both back, so the pin now contradicts a decision.
- **R10:** no Pregnancy C1 test exists. Tools routes and door ids name one tool two ways (`tools/kegel` vs `move/kegel`, `tools/hospital_bag` vs `ready/bag` and `hospital_bag`, `tools/due_date` vs `first_weeks/due_date`), so the test needs a "same tool" table, proven by the screen each id builds.
- **R11 Weak (marks):** five pairs of rows draw the same glyph, because two intents resolve to one drawing in `ttcFamilyMarkForIntent` (`ttc_tool_marks.dart:465`):
  - Calendar and Due date (`calendarDay`, the window ring);
  - Symptoms and Bump (`bodyMark`, two hearts);
  - Baby names and Journal (`pageMark` and `bookMark`, both the open book);
  - Your plate and Product checklist (`checkMark` and `listMark`, both the clipboard);
  - Baby movement and Garbh Sanskar (`stepsMark` and `cuppedHands`, both the heart in a hand).

### TTC: tools a door offers that Tools does not list
| # | Tool | Door id | Where |
|---|---|---|---|
| T-R1 | Calendar | `ttc_calendar` (home and You only; T2 Q1 keeps it off `TtcToolScaffold`) | `TtcCalendarScreen` |
| T-R2 | Cycle report | `ttc_cycle_report` (PCOS door) | `TtcCycleReportScreen` |
| T-R3 | Should I test? | `ttc_chat/should_test` (Conceiving door) | `TtcShouldTestChatScreen` |
| T-R4 | Ready-to-Try plan | `ttc_ready_plan` (Preconception door) | `TtcReadyPlanScreen` |
| T-R5 | Read your semen report | `ttc_semen_report` (his door) | `TtcSemenReportScreen`, and missing from his set `kTtcHisToolIds` (`ttc_tools_screen.dart:952`) |

- **T-R6:** `test/ttc_tool_marks_test.dart` holds that no two rows share a mark (`:77`) and that every row's page shows `ttc_tool_header_mark_<id>` (section 6). So each new row needs its own mark and its page needs the header mark. Today `ttcToolMarkForSurface` (`ttc_tool_marks.dart:135`) sends `ttc_calendar` to Cycle Companion's mark, `ttc_semen_report` to Tests' and `ttc_ready_plan` to the checklist's, and the Ready plan's page is `toolId: 'precheck'` (`ttc_ready_plan_screen.dart:248, 633`). The only calendar drawing is Appointments' own.
- **T-R7 (T5):** his weight and BMI live inside his Partner health page (`TtcBmiScreen(forHim: true)`, T5 PH3), so they need no row of their own. But his Tools search reads names and lines, and his Partner health line, "Your sleep, drinks, smoking, heat and movement" (`kTtcHisToolWords`), never says weight. "weight" finds nothing for him.
- **T-R8:** no TTC C1 test. `ttc_tools_only_tools_test.dart` checks Tools against More, and `ttc_focus_page_test.dart:133` only checks that door ids resolve.

### Search, his side, and the rest (from P3 and P4)
- **X4 Wrong:** global search (`global_search.dart:104-158`) lists Movement (`:131`) but not Weight or Kegel. It also leaves out Blood pressure and sugar, Reminders, Birth plan, Contraction timer, Baby names, Shopping's siblings on Tools (Mood, Your plate) and every new row in this plan.
- **X5 Wrong:** in the father preview, Ask Veda's tool links open her trackers. `pvVedaToolStepsAside` (`pv_veda_links.dart:240`) only stops Bump; Movement, Weight, Medicines, Readings, Kegel, Reminders, Due date and Journal all open. Global search has no father check at all.
- **B1 Weak ("booked", two ways):** the Calendar matches an appointment to a check by exact title and skips completed appointments (`preg_cal_data.dart:239-245`). The Scans timeline matches by substring and does not skip completed ones (`scan_timeline_screen.dart:348-358`), so a finished appointment still reads as "booked". A substring match also finds a short name inside a longer word.
- **TW1 Wrong (twins):** the first twin is marked as a multiple birth at the birth sheet (`pv_you_sheets.dart:350`), but the second, added through Add a child (`multichild_sheet.dart:223`, `pv_you_sheets.dart:326`), never is: `ChildProfileStore.addChild` (`pp_child_profile.dart:644`) takes no `multiple`. Everything that reads `multiple` per child (PP 22) sees one twin.
- **P4-1 Weak:** the contraction timer's Summary, History and Session detail screens are a plain `Scaffold` with an empty `AppBar` (`contraction_tracker_screen.dart:2606, 2716, 2820`), not the tool shell the timer wears.
- **M1:** `00-MASTER.md`'s hand-over status line says item 4 is still open; Terminal A committed it in 2bf951f1.

## Decisions
| # | Question | Recommended | User's answer (2026-10-30) |
|---|---|---|---|
| Q1 | The Scans door's three inline tools (My scans, My reports, Report decoder): own rows? | Three rows, in a Records group with the Tests library and the question lists. A door may show a tool but must never be its only way in | **Three rows** |
| Q2 | Five pairs of Pregnancy rows share a glyph: apply Parenting's one-mark-per-row rule? | Yes: every row its own drawn mark, borrowed from the door art, and the C1 test fails on a repeat | **Yes, fix all, test it** |
| Q3 | Global search (X4): how far? | Every Pregnancy Tools row, held by a test | **Every Tools row** |
| — | Question checklists: one row or three? | One row, "Questions for your doctor", opening a short sheet of the three lists (scan, condition, diet), each saying how many are ticked. Three rows would be one tool listed three times | chosen and recorded |
| — | Where the new Pregnancy rows go | Ask: Is it safe?, Find a condition, Ingredient checker (beside Ask Veda). A new Records group: My scans, My reports, Report decoder, Tests and reports, Questions for your doctor (00-MASTER's proposed groups) | chosen and recorded |
| — | His side (father preview) | Records and Find a condition are hers (her scans, reports, ticks and conditions), so they sit with Track and Check in, off his list. Is it safe? and the Ingredient checker are look-ups and stay on his | chosen and recorded |
| — | Pregnancy marks | Each row names its drawing directly (`tab:` or `tool:`, Parenting's shape); `mark:` stays for revert. Calendar takes TTC's new calendar mark (below), Product checklist the wallet, Baby names the two circles, Garbh Sanskar the tulip, Symptoms the TTC symptoms face; new rows: Is it safe? the question bubble, Find a condition the signpost, Ingredient checker the jar with a leaf, My scans the timeline, My reports the form card, Report decoder the magnifier, Tests and reports the vial, Questions for your doctor the bubble with a plus | chosen and recorded |
| — | TTC rows and places | Your body: Calendar after Cycle Companion, Should I test? after Fertile window, Cycle report after PCOS symptom check. Care and medicines: Read your semen report after Medical tests. Plan and check: Ready-to-Try plan after the checklist. All her side; the semen report also joins his set | chosen and recorded |
| — | TTC marks | Calendar: a new drawn month page (a stretch of days filled), because the only calendar drawing is Appointments'. Should I test?: the clock ("is it time?"). Ready-to-Try plan: the path to a flag. Semen report: the magnifier over a page. Cycle report: its existing chart line. Each page's header shows the same mark | chosen and recorded |
| — | His weight (T5) | No row of its own; his Partner health line reads "Your weight, sleep, drinks, smoking, heat and movement", so search finds it | chosen and recorded |
| — | Father preview, search and Ask Veda | One set of her-only Ask Veda tool ids, matching what his Tools hides; the link says why ("This is her tracker. Your own journal is on your Tools tab."). Global search drops her-only rows in the preview, as his Tools does | chosen and recorded |
| — | One "booked" rule | `ScansStore.bookedFor(names)`: skips completed appointments; matches when a name's words appear as whole words in the title, in order. Both the Calendar and the timeline call it | chosen and recorded |
| — | The second twin | Derived, never asked: `addChild` marks the new child a multiple birth when a living sibling already marked as one was born within a day of them (twins can straddle midnight). The toast says so | chosen and recorded |

## Build waves (no stop between)
1. **Pregnancy rows and marks.** `_Tool` gains `route`, `tab` and `tool`; every row names its route and its drawing; `_row` keys each row `preg_tool_<route>`. The Ask rows (R1-R3) and the Records group (R4-R8 with the question-list sheet). The father preview keeps Records and Find a condition off his list. R9's pin. The timer's three sub-screens move onto `PregToolScaffold` (P4-1).
2. **TTC rows and marks.** Five `TtcTool`s, `kTtcToolKinds`, `kTtcToolMarks` (new `calendar`, `shouldTest`, `readyPlan`, `semenReport` marks; `cycleReport` joins the hub), `ttcToolMarkForSurface` repointed, the header marks (Calendar, the chat shell, Ready plan, Semen report, Cycle report), `'semen_report'` in his set, his Partner health line (T-R7).
3. **Search, his side and the rest.** X4 (every row in global search), X5 (search and Ask Veda), B1 (one booked rule), TW1 (the second twin), M1 (00-MASTER). The two C1 tests, the pins, `flutter analyze` on the touched files, the wiring grep, As built, README.

## Hand-over to Terminal A
None found. The door tiles already open the right screens; C1 adds ways in, not changes to doors.

## As built (2026-10-30)
**Wave 1, Pregnancy rows and marks** (`tools_hub_screen.dart`)
- `_Tool` gained `route`, `tab` and `tool`. Every row names the route its `_open` pushes and is keyed `preg_tool_<route>`; every row names its own drawing, and `mark:` stays for revert.
- Ask: **Is it safe?** (`can_i`, M7), **Find a condition** (`conditions/find`, hers only) and **Ingredient checker** (`belly_skin/checker`), beside Ask Veda.
- A new **Records** group, hers only like Track: **My scans**, **My reports**, **Report decoder** (the Scans door's three inline tools, Q1), **Tests and reports** (`tests_scans`, M7) and **Questions for your doctor**. The door tools open through `_openDoorTool(id)`: `pvDoorScreenFor` under the door's own route name, or a toast saying why not.
- Questions for your doctor opens `showPregQuestionLists` (new `lib/screens/pregnancy/preg_question_lists_sheet.dart`), a sheet of the three lists; each opens as its door opens it. It does not show a ticked count (the plan said it would): ticks are kept per subject for the scan list, so one honest number per list needs more than a store read. Recorded, not built.
- Q2, one mark per row: Calendar takes TTC's new month page, Product checklist the wallet, Baby names the two circles, Garbh Sanskar the tulip, Symptoms today the symptoms face; the five pairs are gone. New rows: question bubble, signpost, jar with a leaf, timeline, form card, magnifier, vial, bubble with a plus.
- R9: `preg_tools_shell_test.dart` no longer forbids Is it safe? and Tests and reports.
- P4's hand-over: the timer's Summary, History and Session detail are on `PregToolScaffold` (eyebrow "Contraction timer"; the session's date is its intro). `_pageTitle` is commented out, kept for revert.

**Wave 2, TTC rows and marks**
- Five `TtcTool`s: **Calendar** (after Cycle Companion), **Should I test?** (after Fertile window), **Cycle report** (after PCOS symptom check), **Read your semen report** (after Medical tests), **Ready-to-Try plan** (after the checklist). Each opens through `openTtcSurface`; all five are in `kTtcToolKinds`; `'semen_report'` joined his set.
- Marks: new `TtcToolMark.calendar` (drawn: a month page with a filled week), `shouldTest` (borrows the clock), `readyPlan` (the path to a flag), `semenReport` (the magnifier); Cycle report takes its existing `cycleReport`. `ttcToolMarkForSurface` repointed (`ttc_calendar`, `ttc_semen_report`, `ttc_ready_plan`, and `ttc_chat/should_test` matched whole). New `ttcMarkArtOf` says what a mark actually draws, so the Pregnancy test compares drawings, not names.
- Header marks: Ready plan, Cycle report and Semen report pass their own `toolId`; the chat shell (`TtcChatScreen`) takes an optional `toolId` and Should I test? passes it; the Calendar draws the mark over its title (it stays off the tool shell, T2 Q3).
- T5: his Partner health line reads "Your weight, sleep, drinks, smoking, heat and movement".
- **Found by listing it (Broken at 360dp, 1.5x):** the Calendar intro's action pill put its label in a Row with no `Flexible` and overflowed by 106px. The label wraps now. The marks test only opens a page once it is a Tools row, which is why it was never caught.

**Wave 3, search, his side and the rest**
- X4: global search lists every Pregnancy Tools row by its Tools name (Weight, Kegel, Blood pressure and sugar, Reminders, Mood, Your plate, Birth plan, Contraction timer, Baby names and every new row); "Can I" and "Symptoms" take the rows' names, the old words kept as keywords; up to 12 tool hits instead of 8.
- **Found by listing it:** search's Garbh Sanskar opened the retired pillar menu (`GarbhScreen`), which M7 forbids. It opens the door now, or toasts.
- X5: `_Dest.hers` marks the rows his Tools leaves off, and search drops them in the father preview. Ask Veda: `kPvVedaHerOnlyToolIds` (movement, weight, medicines, readings, shopping list, Kegel, reminders, due date, journal), and `pvVedaToolStepsAside` says "This is her tracker, so it stays hers…" for each.
- B1: `ScansStore.bookedFor(names)`: skips completed visits and matches whole words in order. The Calendar (`pregCheckStatus`) and the timeline (`_bookedFor`) both call it; the old loops are kept for revert. The Calendar's match is now whole words rather than the exact title, so "NT scan at Apollo" reads as booked.
- TW1: `ChildProfileStore.twinOf(child)` and `addChild` mark the new child a multiple birth when a living sibling marked as one was born within 36 hours. Both Add a child paths toast "…added, as a twin of …, born the same day".
- M1: 00-MASTER's item-4 status line now says 2bf951f1.

**Tests**
- New `test/preg_c1_tools_test.dart` (11) covers: every door tool is a row (with the "same tool" table proved by the screen each door id builds); the C1 rows open; one mark per row (bite-checked: a repeated glyph fails, naming the two rows); R9; search finds every row by its title; his side on Tools, search and Ask Veda; booked; twins; the timer's shell.
- New `test/ttc_c1_tools_test.dart` (5) covers: every door tool is one of her rows; his door's tools are on his tab; the five rows (screen, kind, mark, door card agrees); his weight line.
- Pins updated: `preg_tools_shell_test.dart` (R9), `ttc_tool_marks_test.dart` (the five surfaces; Should I test? is a tool), `ttc_tools_test.dart` (19 to 24 rows), `ttc_ready_plan_test.dart` (its own mark).
- The scoped run: both new files plus `preg_tools_shell`, `preg_tools_more_ttc_format`, `after_loss_tabs`, `p2_keep`, `pv_veda_links`, `preg_birth_prep` (and its contractions file), `contraction_tool_redesign`, `preg_calendar_hub`, `preg_her_week`, `preg_twins`, `pp_child_switch`, `pp_children_sync`, `pp_twin_links`, `ttc_calendar`, `ttc_chats`, `ttc_cycle_report`, `ttc_ready_plan`, `ttc_his_side`, `ttc_tool_marks`, `ttc_tools`, `ttc_tools_only_tools` and `ttc_tools_one_shell`. All pass.
- `flutter analyze` on every touched file: clean, apart from the unused `ttc_journey_map_screen.dart` import in `ttc_tools_screen.dart:118` (committed code, recorded by T5).

**Not done here, on purpose:** the full TTC, Pregnancy and contract suite (next pass); BEFORE-LAUNCH, the sync log, BACKEND-PATTERNS and STILL-OPEN (on the user's word; C1 adds no table or column); a ticked count on the question-lists sheet; a phone walk.
