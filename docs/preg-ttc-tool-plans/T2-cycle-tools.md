# T2: TTC cycle tools

## Context
Family T2 of the tools pass (`00-MASTER.md`): **Cycle Companion, Calendar, Fertile window, Ovulation tests, Cycle report, "Should I test?"**. It waited on Terminal A's phase and clinic work, which is committed (Batch 1 fe1a831, Batch 4 2eb7a77), so it is unblocked.

The audit was read-only, on 2026-10-29. Three helpers read the code against the 8-point checklist (`docs/pp-tool-plans/00-MASTER.md`). The lead checked every Broken and Wrong claim at its file:line and downgraded the ones that did not hold. The user answered the two genuine questions the same day. **The build runs in a new terminal.** Read this whole file first, then "Build waves".

Files the build touches (none were open in another terminal on 2026-10-29; **run `git status` before each edit anyway**):
- `lib/ttc/cycle_store.dart`, `lib/ttc/ttc_cycle_report.dart`
- `lib/screens/ttc/ttc_cycle_companion.dart`, `lib/screens/ttc/ttc_calendar_screen.dart`, `lib/screens/ttc/ttc_window_screen.dart`, `lib/screens/ttc/ttc_ovulation_screen.dart`, `lib/screens/ttc/ttc_cycle_report_screen.dart`, `lib/screens/ttc/ttc_strings.dart` (one string)
- `lib/screens/ttc/chats/ttc_should_test_chat.dart`, `lib/screens/ttc/chats/ttc_cycle_report_chat.dart`
- `lib/screens/ttc/doors/ttc_kind_cards.dart` (one pill label; this is not a door data file)
- `test/ttc_data_chain_test.dart`, plus the new test `test/ttc_t2_cycle_tools_test.dart`

## Out of scope, said plainly
- **Tools rows for Calendar, Cycle report and "Should I test?"** stay with **C1**, the stage-wide rows build with its test, as `00-MASTER.md` says. T2 does not edit `ttc_tools_screen.dart`.
- **The partner reading her period dates:** not built (user, Q2). There is no new RLS policy and no migration. Only his copy changes.
- **Folding Calendar into Cycle Companion:** not done (user, Q1). They stay two tools.
- **Door data files** (`lib/ttc/focus/ttc_focus_*.dart`, `pv_door_*.dart`, `pv_door_router.dart`) belong to Terminal A. Label fixes there go on the hand-over list at the end.
- **The report card on clinic cycles** belongs to Terminal A (`00-MASTER.md`). The audit found the report already holds back correctly on clinic cycles (`ttc_cycle_report.dart:300-319`).
- **Ask Veda learning that an LH test moved her window.** Only `cycle_day` is sent (`ask_veda_service.dart:228`). Adding a field is a two-repo change, so it is recorded here as owed and not built.
- **Hinglish strings in the report** (`ttc_strings.dart:131, 491, 510`): TTC runs on its own language flag, and the policy is English for new work. They are not touched.
- **"Should I test?" using a logged LH day to count 14 days past ovulation:** recorded as Weak and not built. The period-due date stays on the calendar, shared with the home (`ttc_period_due.dart:98`), so the two screens keep agreeing.

## Findings (checked)
### Broken
| # | Finding | Where |
|---|---|---|
| B1 | Moving a period onto a day that already has one overwrites that other period. `movePeriodStart` returns silently when the target is taken, but the sheet still writes this period's bleed days onto the other one and says "Changed to …". The duplicate check skips edits (`!_isEdit`) | `cycle_store.dart:331`; `ttc_cycle_companion.dart:2178-2182, 2436-2440, 2461` |

### Wrong
| # | Finding | Where |
|---|---|---|
| W1 | Clinic cycle: Companion's `_RhythmCard` still prints "NEXT PERIOD EXPECTED", but `countsToPeriod` is false on every clinic cycle | `ttc_cycle_companion.dart:603-605, 671-675, 1325, 1370-1377`; `ttc_care_pathway.dart:227` |
| W2 | Period history ignores both refusals (clinic cycle, and a history that looks like a missed log) | `ttc_cycle_companion.dart:938` vs `:603` |
| W3 | TC4, extended: on a clinic cycle the window hero still says "Today is day N of your cycle", and the intro says the days are "coloured below" when nothing is | `ttc_window_screen.dart:320-329, 373` |
| W4 | First and irregular cycles: the window is drawn with full confidence. The engine says `low`, and the screen never reads `confidence` | `ttc_chapter.dart:499-504, 544`; `ttc_window_screen.dart` (no match) |
| W5 | On a clinic-guided cycle, saving a positive LH test toasts "Your fertile days now follow this test." No fertile days are shown there | `ttc_ovulation_screen.dart:165, 240-257`; `ttc_care_pathway.dart:217` |
| W6 | The LH explainer says a positive means "the window is opening". The surge comes 24-36h before ovulation, so a positive marks the last two, best days | `ttc_strings.dart:1057` |
| W7 | "Should I test?" after a loss: hCG can stay positive for weeks, yet the positive branch says "big news" and offers "I'm pregnant". `lossRecentlyClosed` is never read | `ttc_should_test_chat.dart:405-414`; `pregnancy_records.dart:345` |
| W8 | "Should I test?" has no partner voice: "Your period is due…" and an "I'm pregnant" button for him | `ttc_should_test_chat.dart:317, 356, 414` |
| W9 | The report chat describes the last completed cycle (index 1), but "See the full report" opens the current one (index 0) | `ttc_cycle_report_chat.dart:48, 164`; `ttc_cycle_report_screen.dart:72` |
| W10 | The report chat takes its fertile days from the period-wins spans. The report uses the whole window (decided 2026-10-16) | `ttc_cycle_report_chat.dart:52-54`; `ttc_cycle_report.dart:673-724` |
| W11 | The length note re-implements the engine's average and skips `hasUnreliableHistory` | `ttc_cycle_report.dart:456-464` vs `ttc_chapter.dart:381-386, 431` |
| W12 | After a loss, Companion falls to the empty state, which has no dates and no Period history. That breaks "nothing is hidden after a loss" | `ttc_cycle_companion.dart:129-130, 544-591` |
| W13 | After a loss, Calendar tests `periodStarts.isEmpty` (so the case counts as not empty), shows the no-estimate intro, and offers no "Add my period" action | `ttc_calendar_screen.dart:1699-1716` |
| W14 | His Companion promises "Her dates show here once she adds them". He has no read policy (0041) and never gets them | `ttc_cycle_companion.dart:3191`; `cycle_store.dart:528-530` |
| W15 | The door card's pill "Open the calendar" opens Cycle Companion | `doors/ttc_kind_cards.dart:443` |

### Test fault, traced
`ttc_data_chain_test` "most recent entry has no length yet" (`:264-269`) checks the fixed date `DateTime(2026, 7, 25)` against a fixture of days before today (`kDefectStarts`, `:47`, `ago()` `:60`). On most days it passes for the wrong reason, because the date is not logged. On days when 25 July lands on a non-last start, it fails: 27 Oct (`ago(94)`) failed, and 3 Nov is next. **Mechanism:** a test that mixes fixed dates with relative ones has a calendar of days when it fails.

### Weak and Polish (built in Wave 3 where listed; the rest are recorded)
- **K1** Logging a period takes 4+ taps. The hub has no period action, and "Log this day" opens the symptom log (`ttc_cycle_hub.dart:1743`). **Built.**
- **K2** Bleed choices are 3 to 7+ (`companion:1935`). 2 days can't be recorded, and more than 7 can't be told apart from 7. **Built.**
- **K3** No calm doctor line for cycles over 35 days, no period in 90 days, or more than 7 days of bleeding. Only under 21 days has one (`companion:2043`). The report chat checks one cycle only (`ttc_cycle_report_chat.dart:175-178`). **Built.**
- **K4** Silent saves: a Negative strip, a later positive, a positive outside this cycle (`ovulation:240, 246, 375`). **Built.** No Undo on plain-sheet saves (`companion:2458-2464`). **Built.**
- **K5** Silent taps: a future day in the picker (`companion:2842`), Calendar's greyed actions (`calendar:1472, 1548`). **Built** (a `pvToast` saying why).
- **K6** The window never shows its source line ("Based on your positive test on…", `ovulation:301`). **Built.**
- **K7** "Should I test?" saves the length she picks silently (`should_test:270`). **Built** (one line says it was saved).
- **K8** Not on `TtcToolScaffold`: Companion (`:159`), Calendar (`:207`), Window (`:232`). **Built** in Wave 3. Chats keep the shared chat shell and go on the one-shell test's allow-list.
- **K9** Polish, **built**: dead code in `_setResult` (`ovulation:380-413`), the TODAY marker drawn on future cycles (`window:1507`), the unreachable "+1" note (`window:965`), stale comments (`ttc_fertile_window.dart:106`, `ttc_chapter.dart:550`).
- **K10** Recorded only: two route names per tool (`ttc/ovulation` vs `ttc_ovulation`; `ttc/cycle_report` vs `ttc_cycle_report`). No code detects either name today, so they are left as they are. Undo of a positive clears the day instead of restoring an earlier Negative (`ovulation:262`). `_day` goes stale past midnight (`ovulation:347`). The Calendar's action labels are cut with an ellipsis (`calendar:1537`).
- **K11** Tests: every clinic-cycle window test pumps the retired `TtcFertilityWindowScreen` (`ttc_window_test.dart:56`, `ttc_treatment_test.dart:256`, `ttc_open_points_test.dart:168, 223`, `ttc_tools_test.dart:603`). The live screen has no clinic test. There are no loss tests for Companion, Calendar or "Should I test?".

### Clean, as checked
- No personalised probability anywhere. The window list says "They aren't percentages" (`window:678`).
- The window maths are standard: opens 5 days before ovulation and closes on it (`ttc_fertile_window.dart:60-61`); LH means ovulation the next day, a temperature rise means the day before (`ttc_chapter.dart:537-538`); the rise needs 3 readings above the 6 before (`ttc_temp_rise.dart`).
- "Should I test?" handles clinic cycles well: ownership is checked first, it names the clinic's blood-test date, and it warns about the trigger shot (`ttc_period_due.dart:113`; `should_test:295-300`).
- Calendar holds the due-date line to her own timing (`calendar:1775`). The retired window screen has no live caller.

## Decisions
| # | Question | Recommended | User's answer |
|---|---|---|---|
| Q1 | Calendar vs Cycle Companion: two month views | Keep both, separate jobs. Companion is logging and rhythm; Calendar is the month at a glance, clinic dates included. Calendar's Tools row lands in C1 | **Recommended** (2026-10-29) |
| Q2 | Does the partner see her period dates? | No. Fix his copy to what he really sees | **Recommended** (2026-10-29) |
| — | B1: a move onto a logged day | `movePeriodStart` returns `bool`. The sheet checks for a duplicate on edits too and offers "Merge into that period" / "Pick another day" | chosen and recorded |
| — | W1/W2: next period on clinic cycles and on poisoned histories | Rhythm and next period sit behind `countsToPeriod` and `hasUnreliableHistory` on the hub **and** in Period history. On a clinic cycle the lengths stay (they are her history) and the prediction goes | chosen and recorded |
| — | W3: window hero on a clinic cycle | Drop the cycle-day line and the intro, keep the treatment card and the disclaimer | chosen and recorded |
| — | W4: first and irregular cycles | Keep the window and state its basis. First cycle: "A first estimate from a 28-day cycle (or 'from the length you told us'). It sharpens after your next period." Irregular: "Your cycles vary, so these days are a wide guess. An ovulation test narrows them." This is what Flo and Clue do; withholding would hide the feature | chosen and recorded |
| — | W5: the LH toast on clinic cycles | "Saved. Your clinic times this cycle, so tell them about a positive test." | chosen and recorded |
| — | W6: LH copy | "…It turns positive a day or two before you ovulate, which makes today and tomorrow your best two days." | chosen and recorded |
| — | W7: "Should I test?" after a loss | Until her first period after the loss is logged (`CycleStore.restartOn` with no `lastPeriodStart`), or for 6 weeks after `endedAt`, whichever ends first: a calm first line, "After a loss, a test can stay positive for a few weeks while your body settles." A positive routes to "Your doctor can check with a blood test", with no "big news" and no "I'm pregnant" button. Negative and faint follow the same rule | chosen and recorded |
| — | W8: his voice | His lines through `ttcWindowForHim`-style swaps ("Her period is due…"); no record or log buttons for him | chosen and recorded |
| — | W9/W10/W11: one source each | The chat opens the report on the cycle it describes (`TtcCycleReportScreen(initialIndex:)`) and reads `ttcCycleWindowSpan`. The note calls `TtcChapterEngine().cycleLengthFor` and returns null on `hasUnreliableHistory` | chosen and recorded |
| — | W12/W13: after a loss | Both screens keep her history. One line: "Your cycle starts again from your first period after the loss. Log it when it comes." Action: "Log my period". No baby wording | chosen and recorded |
| — | W14: his Companion copy | "Only she sees her period dates. You see her fertile window and where she is in her cycle." | chosen and recorded (Q2) |
| — | W15: the pill | `'ttc_cycle' => 'Open Cycle Companion'`, `'ttc_calendar' => 'Open the calendar'` | chosen and recorded |
| — | K2: bleed choices | 2 to 7, plus "More than 7". "More than 7" shows the calm doctor line | chosen and recorded |
| — | K3: doctor lines | Cycles over 35 days (ACOG; NHS says up to 40, we take the earlier limit), no period for 90 days with a negative test, bleeding more than 7 days. Each is "worth mentioning to a doctor" plus the disclaimer. Never a verdict | chosen and recorded |

## Clinical calls (each one on a BEFORE-LAUNCH clinician CHECK line)
1. The "Should I test?" after-loss rule: until the first period after the loss, or 6 weeks, whichever ends first. Source: NHS and RCOG say hCG can take weeks to clear after a miscarriage.
2. The LH wording: a positive means the best two days, with ovulation 24-36h after the surge.
3. Doctor lines: cycles over 35 days, no period in 90 days, bleeding more than 7 days (with the under-21 line already there).
4. The first-cycle and irregular basis lines on the window.

On BEFORE-LAUNCH, write these when the user says to (check `git status` first; other terminals edit that file).

## Build waves (no stop between waves; tests after each)
**Wave 1: data and clinical (Broken and Wrong first)**
- B1: `movePeriodStart` returns `bool`; the sheet checks for a duplicate on edits; merge or pick again; the toast says what happened.
- W1/W2: one helper on the companion, `_mayPredictNext` (`countsToPeriod && !hasUnreliableHistory`), used by the hub's rhythm card and by Period history.
- W11: the length note calls the engine.
- The data-chain test: `cycleFrom(ago(2))`, with a comment on why fixed dates broke it.

**Wave 2: screens and voices**
- W3, W4, K6: the window hero on clinic cycles; the basis line from `confidence` and `whyNoEstimate`; the source line.
- W5, W6, K4: the ovulation toasts gated on ownership; the LH string; toasts for the silent saves.
- W7, W8, K7: "Should I test?" after a loss, his voice, the saved-length line.
- W9, W10: the report chat and screen share one cycle and one window.
- W12, W13, W14, W15: after-loss states on Companion and Calendar; his copy; the pill.
- K1: a "My period started" action on the healthy hub, opening the existing period sheet on today (one tap and Save).
- K2, K3: bleed choices; doctor lines on the Companion and in the report chat.

**Wave 3: look and polish**
- K8: Window, Companion and Calendar onto `TtcToolScaffold`, keeping each screen's content. Grow `test/ttc_tools_one_shell_test.dart` to pin all three; chats go on its allow-list with a reason.
- K5: toasts for the silent taps. K9: dead code and stale comments removed or fixed. Superseded UI is commented out with "kept for revert".

**Tests** (new `test/ttc_t2_cycle_tools_test.dart`, plus updates):
- B1: a move onto a logged day changes neither period until she merges.
- W1/W2: no "NEXT PERIOD EXPECTED" on a clinic cycle or a poisoned history, on the hub and in Period history.
- W3: the **live** `TtcWindowScreen` on a clinic cycle has no cycle-day line and no "coloured below". Repoint the five tests that pump the retired screen, or add live twins beside them.
- W4: first-cycle and irregular basis lines.
- W5: the clinic toast. W7: the after-loss branches of "Should I test?" (positive, negative, faint), and the window ending at the first period or 6 weeks.
- W8: the partner's lines in "Should I test?".
- W9/W10: the chat and the report on the same index and the same fertile days.
- W11: the note on a poisoned history returns null.
- W12/W13: after a loss, the history row is there and the action logs a period.
- W15: the pill label.
- K2: a 2-day bleed and the "More than 7" line. K3: the three doctor lines.

**Verification:** `flutter analyze` on the touched files; the TTC tests (`test/ttc_*`) and the new file only, as the machine is short on memory; the wiring grep on every new reader (`_mayPredictNext`, the after-loss rule, `initialIndex`, the hub period action). Phone walk later, on the user's word.

## Backend
Nothing new. `CycleStore` is already local-first with date-derived ids, soft deletes, and a contract test (`ttc_schema_contract_test.dart:44-49, 99, 117`). B1's merge writes through the existing `movePeriodStart` and `logBleedDays`, so sync is unchanged. Q2 keeps 0041's own-row rule.

## Owed and hand-over
- **Terminal A (door files):** any door tile that names Cycle Companion "calendar" (check `lib/ttc/focus/` for `ttc_cycle` tiles labelled as a calendar). The PCOS door tile "What your cycle shows… turned into a pattern" over-promises: the report shows one cycle at a time (`ttc_focus_pcos.dart:727-729`).
- **Ask Veda (two repos):** an LH or temperature move of her window is not sent; only `cycle_day` is. Recorded, not built.
- **C1:** Tools rows for Calendar, Cycle report and "Should I test?".
- **BEFORE-LAUNCH:** the four CHECK lines above, on the user's word.

## As built
(Written during the build, in the new terminal.)
