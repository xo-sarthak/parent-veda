# P1: Pregnancy look-ups and records

## Context
This is the Pregnancy and TTC tools pass (`00-MASTER.md`), family P1, run by Terminal B. T1 is committed (00b3cc5, migration 0117 run 2026-10-28, docs ae9c878 and f7f4ef6). The read-only audit ran on 2026-10-27, and the lead checked the top claims at their file:line. They were spot-checked again on 2026-10-28 against the code after 7c26f32.

The ten tools:
| # | Tool | Surface id | Screen |
|---|---|---|---|
| 1 | Is it safe? | `can_i` | `can_i/can_i_door.dart`, `can_i_screen.dart`, `can_i_verdict_screen.dart` |
| 2 | Find a condition | `kCondSurfaceFind` | `conditions/conditions_home_screen.dart`, `condition_detail_screen.dart` |
| 3 | Ingredient checker | (Belly and skin door) | `belly_skin/ingredient_checker_screen.dart` |
| 4 | Report decoder | `reports` (router) | `report_screen.dart` |
| 5 | My reports (locker) | `reports` (home) | `brackets/scan_reports_screen.dart`, viewer, editor |
| 6 | Tests and reports library | `tests_scans` (router) | `tools/tests_scans_reports_screen.dart` |
| 7 | Question checklists | (Scans, Nutrition, Complications doors) | `brackets/pv_checklist_screen.dart`, `services/pv_checklist_store.dart` |
| 8 | Medication and supplements | `medication` | `tools/medicine_tracker_screen.dart`, `services/medicine_store.dart` (shared with TTC) |
| 9 | Blood pressure and sugar | `tools/readings` | `tools/readings_log_screen.dart`, `services/readings_store.dart` |
| 10 | Reminders | `reminders` | `reminders_screen.dart`, `services/reminder_store.dart` (shared by all stages) |

**Status: BUILT 2026-10-28 (approved "D5 your way, yes build P1"). See As built and Verified at the foot.**

## Out of scope, said plainly
- **Tools tab rows (C1).** Is it safe?, Find a condition, Ingredient checker, Tests library and Question checklists still need rows on Tools. Per 00-MASTER, C1 for the whole stage lands as one small build after Terminal A commits the Tools-tab order. P1 does not touch `tools_hub_screen.dart`.
- **Home and door files (Terminal A, Batch 4 is homes).** Three fixes here need a line in A's files, so they go on the hand-over list at the foot of this file and are not built by us:
  - PG1's home fallback (`home_v3_screen.dart:1759`);
  - the ingredient checker's door hint (`pv_door_belly_skin.dart:250`);
  - the door tile names for these tools.
- **Medicines in the doctor summary, and conditions in Ask Veda.** Both already use her data today (`pv_doctor_notes_screen.dart:225`, `veda_context.dart:63-123`). Putting them behind consent would change how live features behave, so it is a separate decision, recorded in STILL-OPEN and not made here.
- **The Ask Veda service.** No new wire field, so this is not a two-repo change.
- **Unifying the three test and report libraries** (findings repeated across three files). That is content work and is recorded in STILL-OPEN. P1 fixes only the AFI range and the "Diagnosis" heading.
- **The Pregnancy and TTC Can I copies drifting.** Already in STILL-OPEN from Parenting's family 25-28. Not repeated here.
- **Moving Is it safe? onto `PregToolScaffold`.** It is a door now (`can_i_door.dart`), so it keeps the door look. The dead `buildClassic` code (`can_i_screen.dart:81-241`) stays, kept for revert.
- **A phone walk.** Only on the user's word.

## Mobbin pass (2026-10-28)
Only tools whose screens change get a search. Is it safe? and Find a condition change only copy and logic.

| Tool | Reference | Adopt | Decline |
|---|---|---|---|
| Blood pressure and sugar | Garmin Connect "Add a Reading", with a range line under each field: https://mobbin.com/screens/52304000-0515-44dc-9d8f-bf33f7e071ff<br>Oura "Blood pressure and pregnancy" info row and "keep a log to share with your doctor": https://mobbin.com/screens/50c52b1a-c32f-4106-8d8b-23e1446f1353<br>Bevel result sheet after a save: https://mobbin.com/screens/a4629f7a-f55f-4aab-a0d2-1ae484005a8b | A plain range line under each field on the target sheet. After a save in the same-day range, a sheet that opens on its own (Bevel's shape) with one ink "Call your doctor" button and "Not now" | Bevel's coloured category label ("Hypertension Stage 1"). We never name a condition (D1) |
| Reminders | Perplexity "Paused" divider above greyed tasks: https://mobbin.com/screens/58f31058-af8f-47ce-bbcd-4bbd2426a8d0<br>Finch "PAUSED" pill with one calm line: https://mobbin.com/screens/a86fb86e-d3f7-49cc-9caa-2425306760b8<br>MyFitnessPal grouped list with switches: https://mobbin.com/screens/d21ec8df-4dac-40e6-b584-76e1c400cd52 | A "Paused after your loss" section with a divider label and one line saying why and how they come back. Rows are greyed, with no switch | Oportun's "Resume all" button. Resuming is tied to going back to the pregnancy view, not to a button here |
| Medication | Apple Health Medications week strip, where any past day can be opened and logged: https://mobbin.com/screens/19cc770b-a386-48a5-9d6b-7a46a8c98685<br>GoodRx Taken / Missed pair: https://mobbin.com/screens/95f9bc43-c218-4b83-b008-5a451404b138 | The existing week strip becomes tappable for past days. A tick on a past day toasts the date it was marked for | A future-day tick, and GoodRx's "Missed" button. We record taken only, never a miss score |
| Deletes everywhere (readings, locker, medicines, checklist Clear all) | X toast with Undo: https://mobbin.com/screens/ed4a0353-637c-44de-89b8-4b7f681ac94d<br>BitePal "Clear this meal" sheet: https://mobbin.com/screens/3b190043-0e69-479d-a003-69834c4dd664 | A single delete gives a `pvToast` with Undo. A bulk clear gives a confirm sheet ("Clear all ticks" / "Keep them") | The red alert dialog for a single row (Joi, Copilot). Undo is calmer and just as safe |
| Ingredient checker | BitePal "Hmm, I couldn't spot any food" with one next step: https://mobbin.com/screens/229c5792-8472-41f0-8255-e82917e6cbe5<br>Lifesum search hint "Food, meal or brand": https://mobbin.com/screens/57072cd0-febd-4ea1-97f1-4850243a1cab | A no-match result that names what to do next: Ask Veda, plus Is it safe?. A hint that promises only what the search does (ingredients) | The mascot |
| Doctor-visit summary | Google Health record tiles, each showing "No data": https://mobbin.com/screens/948430d4-5cfb-4065-b61f-d6deb95fbfb4<br>Stardust "Your data is private. Only used to…" line: https://mobbin.com/screens/7d25b2a5-03b3-4d62-914e-efa73c159f76 | A section per kind that is always drawn: data if she said yes, an invitation if she has not answered, one line if she said no. The ask card carries one line saying what a yes is used for | Tiles. The summary stays a readable list to show a doctor |
| Question checklists | WHOOP list with tick boxes and one Save: https://mobbin.com/screens/74e755b4-e8c0-460d-9984-bddbcdda18cc | No layout change. Only the Clear-all confirm (above) and a "for this scan" eyebrow | — |

## Audit (summary; the full findings with file:line are in the session's audit, condensed here)
| Tool | Findings |
|---|---|
| **1 Is it safe?** | **Wrong:** after a loss it still shows "For your weeks" (`can_i_door.dart:575-659`). **Weak:** "My doctor said" saves silently (`can_i_verdict_screen.dart:423, 429`). The home label "Can I…?" (`app_structure.dart:127`) does not match the "IS IT SAFE?" hero. Sunscreen is Safe here but Limit in the ingredient checker (`can_i_data.dart:1029` vs `belly_skin_data.dart:1152`). **Good:** `CanIStore` over `SavedStore`, merged `can_i_activity`, `can_i_misses`. |
| **2 Find a condition** | **Wrong:** the standalone screen still shows the retired "Has your doctor mentioned…" gate (`conditions_home_screen.dart:117-121, 307-308`), but the inline door copy doesn't (`:513-521`). **Weak:** adding a condition to her journey, or removing one, is silent, and remove has no undo (`condition_detail_screen.dart:116-118, 184-187`). The browse list has no disclaimer. **Good:** `ConditionsStore` merged `conditions_choices`. |
| **3 Ingredient checker** | **Weak:** emoji chips (`:181`; `belly_skin_data.dart:1460-1467`). A "coming soon" product card that does nothing (`:309-316`). The hint promises product search but only ingredients match (`:115`). The disclaimer shows on the verdict only (`:323-326`). No match is a dead end (`:369`). The sunscreen clash (see 1). **Polish:** a plain `Scaffold`. No store, no tests. |
| **4 Report decoder** | **Wrong:** `reports` means the locker on the home (`home_v3_screen.dart:1985-1993`) but the decoder in the router (`surface_router.dart:82`; reached from journeys `:104` and `scans_hub :156`). **Weak:** the list has no disclaimer. The locker's header comment says the decoder reads her stored reports, but it doesn't (`scan_reports_screen.dart:10-11`). |
| **5 My reports (locker)** | **Weak:** remove and the editor's save are silent (`:470`; `scan_report_viewer_screen.dart:263`; `scan_report_edit_screen.dart:373-380`). Add already toasts (`:290`). **Polish:** a stale "purple" comment (`:34-38`), two shells (`:81-97` vs `:830`). **Good:** `ScanReportsStore` merged `scan_reports`, attachments upload. |
| **6 Tests library** | **Wrong:** `tests_scans` means the Scans door on the home (`home_v3_screen.dart:1983`) but the library in the router (`surface_router.dart:79`). **Weak:** not on `PregToolScaffold` (`:136-140`). The trimester filter starts on All and ignores her week. The AFI range "8-18 cm" (`tests_scans_reports_data.dart:803-824, 912-913`) is narrower than the 5-25 cm Indian reports print. **Polish:** a "Diagnosis" heading (`:663`). Listed twice in search (`global_search.dart:123-131`). No tests. |
| **7 Question checklists** | **Weak:** the header says ticks are local-only, but they sync to `pv_checklists` (`pv_checklist_store.dart:10-26` vs `:38-45, 74`). There is one key per list, so ticks carry over into the next scan (`:53-54`; `pv_checklist_scans.dart:75-83`). "Clear all" has no confirm, toast or undo (`pv_checklist_screen.dart:183-191`). After a loss it still says "What to ask at your next scan". No tests. |
| **8 Medication** | **Weak:** untick, the alarm switch, add, edit, delete and the home toggle are all silent (`:376-379, 451-456, 648-679, 1259-1275`; `home_v3_screen.dart:1078`). An empty name closes the sheet without a word (`:649-652`). Pregnancy can't mark a past day: `toggleOn` exists for TTC (`medicine_store.dart:409-415`), but Pregnancy's week view is read-only (`:465-509`). TTC medicines carry into pregnancy with no word (D3). No column contract test for `medications` and `medication_logs`. |
| **9 Blood pressure and sugar** | **Wrong (PG1):** "Log it now" opens Weight (`pregnancy_journeys.dart:251`, and the condition journey `:116`). `readings` is missing from `screenForSurface` (`surface_router.dart:76-93`). **Weak:** add, edit, delete and the target save are silent, and delete has no confirm or undo (`:411-431, 535-538, 655-658`). The target sheet has no checks and loses typing on close. A severe reading gets no response (`readings_store.dart:85-95` checks plausibility only; the same-day signs are BP-only and unconditional, `:128-142`) = D1. The doctor summary has no readings = D4. **Good:** `readings_log_test` is strong; merged `readings`. |
| **10 Reminders** | **Wrong after a loss:** the presets "Take your prenatal vitamin" and "Read to your baby" (`:43-49`; `app_language.dart:2803-2806`). The screen never reads `ReminderStore.pausedForLoss` (`reminder_store.dart:42-45`), so paused reminders look "off" = D2. **Weak:** emoji in the preset titles, which are stored as titles. The switch, the medicine reminder delete and the empty-title tap are silent, and "Removed" has no undo (`:362, 1118-1121, 591, 621-625`). **Polish:** `store.init()` runs in `build` (`:182`); a stale header (`:6-7`). **Unverified:** whether the list shows other stages' reminders. No contract test for `reminders`, no widget test. |

**Cross-cutting.**
- None of the ten reads `PregnancyEndedStore` (only `tools_hub_screen.dart:161` does).
- Shared code that must keep other stages working:
  - `MedicineStore` (TTC, the doctor notes, Ask Veda);
  - `ReminderStore` and `NotificationService` (all three stages);
  - `PregToolScaffold` (about 50 Parenting screens, plus the pp look tests);
  - `pp_attachments.dart`;
  - `PpUseConsent`.

## Decisions
| # | Question | Recommended | User's answer |
|---|---|---|---|
| D1 | A high BP or sugar reading | A calm same-day prompt: "Call your doctor today" plus the warning signs. Never a diagnosis | **Yes** (2026-10-27). Thresholds and wording go on a BEFORE-LAUNCH clinician line. The proposed numbers are in Wave 2 |
| D2 | After a loss | The tools stay and the baby wording goes. The Reminders screen says the paused ones are paused, why, and how they come back | **Yes** (2026-10-27) |
| D3 | Medicines added while trying, on moving to pregnancy | One gentle card: "Check these with your doctor. Keep each or stop it." Nothing stops by itself | **Yes** (2026-10-27) |
| D4 | The doctor-visit summary | Add readings, conditions, reports and the Is it safe? doctor's calls, each after asking once (consent per stage, T1 model) | **Yes** (2026-10-27) |
| D5 | **Where the Pregnancy consent kinds live** (00-MASTER T1 left this "to the first family that needs a kind") | **Extend `PpUseConsent` additively.** Each kind carries its stage, and the Pregnancy kinds get their own names (`pregReadings`, `pregConditions`, `pregReports`, `pregDoctorCalls`). Parenting's five kinds keep their names, so their stored rows are untouched. This gives one ask card, one You section and one store. A sibling store would copy all three and drift | **Extend `PpUseConsent`** (2026-10-28, "D5 your way") |
| D6 | How do we know a medicine was added while trying? (chosen, obvious) | Derive it: the id is `med_<microseconds>` (`medicine_tracker_screen.dart:665`), so "added before this pregnancy began" = id time < `LifeStageStore` pregnancy start. No new column and no migration. An id that doesn't parse counts as "not known", and the card leaves it out | Recorded |
| D7 | `reports` and `tests_scans` each meaning two screens (chosen, obvious) | The home's meaning wins (the Scans door tabs), because that is what she taps most. The decoder and the library get their own ids (`report_decoder`, `tests_library`), and the journeys and Scans hub callers move to them. A test holds that each id means one screen in both routers | Recorded |
| D8 | Checklist ticks (chosen, obvious) | Ticks keep syncing (backup is the house norm, and T0 governs *using* data elsewhere, not backing it up), and the false header is corrected. Ticks are kept **per scan**: the old one-key ticks move to the current scan once. Clear all gets a confirm and an Undo toast | Recorded |
| D9 | The AFI range (clinical, chosen) | Show "Commonly 5 to 25 cm. The range printed on your report is the one your doctor reads." Clinician line in BEFORE-LAUNCH | Recorded |
| D10 | The sunscreen clash (chosen, obvious) | Is it safe? keeps Safe and adds one line: "Mineral sunscreen is the gentlest. Some women prefer to limit chemical filters like oxybenzone." The checker keeps Limit for chemical filters only. Then they agree | Recorded |
| D11 | The ingredient checker's "coming soon" product card (chosen, obvious) | Comment it out, kept for revert. It is a promise with no tap behind it, and the hint stops promising product search | Recorded |
| D12 | Build P1 as planned? | Yes | **Yes, build P1** (2026-10-28) |

## Build, in four waves (each ends green)

### Wave 1: backend, routing and contracts
1. **Contract tests** for `medications`, `medication_logs` and `reminders`: client columns against migrations, in the shape of `test/ttc_schema_contract_test.dart`. Any mismatch found is reported before it is fixed.
2. **PG1:** add `'readings' => ReadingsLogScreen(...)` to `screenForSurface`, and point both journey "Log it now" elements at `readings` (`pregnancy_journeys.dart:116, 251`). Correct the false comment at the home fallback in the hand-over to A. A test holds that every journey tool element named for readings opens the readings screen.
3. **D7:** add `report_decoder` and `tests_library` to `screenForSurface` and move the callers (journeys `:104`, `scans_hub :156`). The router's `reports` and `tests_scans` now open what the home opens. A test walks both routers for both ids.
4. **D5:** the Pregnancy consent kinds on `PpUseConsent`, each with `stage` and a one-line "what a yes changes". The You section groups the kinds by stage. Parenting's tests stay green.
5. **Before editing `surface_router.dart` and `app_structure.dart`:** run `git status`. If Terminal A holds either one, that step waits.

**No migration in P1.** D6 derives the stage from the id, D8 reuses the `pv_checklists` rows with a new key, and D5 reuses the consent store's rows.

### Wave 2: clinical (D1, D2, D3, D9, D10, the condition gate)
1. **D1, readings.** A pure `readingConcern(Reading)` in `readings_store.dart` returns `none`, `sameDay` or `urgent`. It is a function of the reading only, never a label for her. The proposed thresholds, all on a clinician line:
   - BP: 140/90 or above → `sameDay` ("Sit quietly for five minutes and measure again. If it is still 140/90 or higher, call your doctor today.");
   - BP: 160/110 or above → `urgent` ("Call your doctor now. If you can't reach them, go to your hospital.");
   - sugar: under 70 or 200 and above → `sameDay`.

   After a save in either range, the sheet opens on its own: one ink "Call your doctor" button (it opens the dialler with no number, or her saved doctor's number if T4 lands one), the warning signs (a bad headache, blurred vision, pain under the ribs, sudden swelling of the face or hands), and "Not now". It is the same after a loss, because blood pressure still matters in the weeks after. Her doctor's targets keep comparing nothing, as `ReadingTargets` says. The always-on same-day signs list (`:128-142`) becomes the sheet's content, not a fixed block.
2. **D2, after a loss** (`PregnancyEndedStore.isEnded`):
   - Is it safe? hides "For your weeks", and the trimester lines fall back to the general answer.
   - Reminders drops the two baby presets.
   - The checklists say "Questions to take to your doctor" in place of "your next scan".
   - The Reminders screen draws the paused ones as a section: **"Paused after your loss"**, with "They come back on if you go back to your pregnancy view." Rows are greyed and have no switch.
   - A test per tool holds each change.
3. **D3, medicines.** When the stage is Pregnancy and at least one medicine was added while trying (D6), and the card hasn't been dismissed for this pregnancy, the Medication screen opens with a card: "These were added while you were trying: Letrozole, Folic acid. Check them with your doctor. Keep each or stop it." Each row offers **Keep** / **Stop**. Stop asks once, then deactivates it with an Undo toast. Once every row has an answer, the card goes. Nothing changes by itself. The "seen" flag is local, keyed by the pregnancy's start.
4. **D9** AFI copy, and the "Diagnosis" heading becomes "What it can mean". **D10** the sunscreen line.
5. **The condition gate:** the standalone screen drops the retired "Has your doctor mentioned…" gate (commented out, kept for revert) and matches the inline copy. The browse list gets the disclaimer. A test holds that the gate is gone.

### Wave 3: each tool's UX (Mobbin above)
- **Silent saves end.** Every one gets a `pvToast` that says what changed, with Undo on removals:
  - readings: add, edit, delete, target;
  - medicines: add, edit, delete, untick, alarm switch, and the home toggle via A (its line is in `home_v3_screen.dart`, so it goes to A);
  - conditions: add and remove;
  - Is it safe?: "My doctor said";
  - the locker's remove and the editor's save;
  - the reminder switch, the medicine reminder delete, and "Removed" (with Undo).
- **Empty input says why:** the medicine name and the reminder title show "Add a name to save this" in place of closing silently.
- **Readings:**
  - the target sheet gets range lines and checks, and keeps her typing until she saves or discards;
  - a single delete uses Undo, not a dialog.
- **Medication:** past days on Pregnancy's week strip become tappable through `toggleOn`; future days stay locked. The toast reads "Marked as taken on Tue 21 Oct".
- **Ingredient checker:**
  - line icons in place of emoji;
  - the hint becomes "Type an ingredient, like retinol";
  - no match offers Ask Veda and Is it safe?;
  - the disclaimer moves under the list;
  - the screen moves onto `PregToolScaffold`.
- **Tests library:**
  - moves onto `PregToolScaffold`;
  - the trimester filter opens on her trimester (her week is reliable since A's fe1a831);
  - one search entry.
- **Locker:** one shell, and the stale comment goes.
- **Reminders:**
  - the presets lose their emoji (titles she already saved stay as they are);
  - `init()` moves out of `build`;
  - the header is updated;
  - **verify** whether other stages' reminders show here, and report it before changing anything.
- **Is it safe?** gets one name. "Is it safe?" goes in `app_structure.dart` if it is free; otherwise it goes to A.

### Wave 4: the doctor-visit summary (D4)
The Pregnancy block (`pv_doctor_notes_screen.dart:149-178`) gains four sections. Each one asks `PpUseConsent.allows(kind)`:
- **Readings:** the latest 8, BP and sugar with their context, and "your doctor's target" if set.
- **Conditions she follows:** from `ConditionsStore`.
- **Reports:** the latest 6 from `ScanReportsStore`, by title and date.
- **Your doctor's calls:** the Is it safe? "My doctor said" entries.

The ask card appears once, after her first save of each kind in Pregnancy (the T0 pattern), with one line: "Use your readings in the summary you can show your doctor?" A section is always drawn:
- her data, if she said yes;
- an invitation, if she hasn't answered;
- "You chose not to include these. Change in You", if she said no.

## Files (main)
- `lib/services/surface_router.dart`, `lib/data/journeys/pregnancy_journeys.dart`, `lib/screens/brackets/scans_hub*.dart` (the caller)
- `lib/services/readings_store.dart`, `lib/screens/tools/readings_log_screen.dart`
- `lib/services/medicine_store.dart`, `lib/screens/tools/medicine_tracker_screen.dart`
- `lib/screens/reminders_screen.dart`, `lib/services/app_language.dart` (the presets only)
- `lib/screens/can_i/can_i_door.dart`, `can_i_verdict_screen.dart`, `lib/data/can_i_data.dart` (sunscreen)
- `lib/screens/conditions/conditions_home_screen.dart`, `condition_detail_screen.dart`
- `lib/screens/belly_skin/ingredient_checker_screen.dart`, `belly_skin_data.dart`
- `lib/screens/report_screen.dart`, `lib/screens/brackets/scan_reports_screen.dart`, viewer, editor
- `lib/screens/tools/tests_scans_reports_screen.dart`, `tests_scans_reports_data.dart`, `lib/services/global_search.dart`
- `lib/screens/brackets/pv_checklist_screen.dart`, `lib/services/pv_checklist_store.dart`, `pv_checklist_scans.dart`
- `lib/services/pp_use_consent.dart`, the You consent section, `lib/screens/profile/pv_doctor_notes_screen.dart`
- `lib/services/app_structure.dart` (one label, if free)

None of these is in today's `git status` (another terminal holds Parenting door files only). Each is checked again before its wave.

## Verification
- **New tests:**
  - `test/preg_p1_routing_test.dart`: PG1, D7, both routers;
  - `test/preg_p1_after_loss_test.dart`: all ten tools;
  - `test/readings_concern_test.dart`: each threshold edge, and the sheet opens only in range;
  - `test/medicine_trying_carry_test.dart`: D6 derivation, the card, Keep / Stop, Undo;
  - widget tests for `RemindersScreen` (the paused section), `PvChecklistScreen` (per scan, confirm), `TestsScansReportsScreen`, `IngredientCheckerScreen`;
  - the no-gate test;
  - the contract tests for `medications`, `medication_logs` and `reminders`;
  - consent kinds round-trip.
- **Existing tests that must stay green:**
  - `readings_log_test`, `can_i_door_test`, `conditions_personalisation_test`, `pv_door_complications_test`, `scan_reports_edit_test`, `report_filter_test`, `scan_journey_wiring_test`;
  - for `MedicineStore`, TTC's medication tests;
  - for `PregToolScaffold`, the pp look tests;
  - for `PpUseConsent`, Parenting's consent tests.
- `flutter analyze` on the touched files. The wiring grep on every new reader (`readingConcern`, the D3 card, `pausedForLoss` on screen, each consent kind in the summary).
- **Docs at the end:**
  - BEFORE-LAUNCH clinician lines: D1 thresholds and wording, AFI, the sunscreen line;
  - BACKEND-PATTERNS:
    - "derive from the id, not a new column" (the trade-off: no migration, but the meaning is tied to the id format, so an unparseable id must mean unknown);
    - "consent per stage and kind in one store";
  - STILL-OPEN: the medicines-and-conditions consent question, the three libraries;
  - this file's As built and Verified;
  - the README row.

## Hand-over list for Terminal A
1. `home_v3_screen.dart:1759`: `kPgActTrackReadings` should open `'readings'` (exists after our Wave 1), and its comment is false.
2. `home_v3_screen.dart:1078`: the home medicine toggle should toast like the tool.
3. `pv_door_belly_skin.dart:250`: the checker's door hint promises product search.
4. Door tile names for these tools: Is it safe? (one name), and "Report decoder" / "My reports" wherever a door calls both "Reports".

## As built (2026-10-28)
**Where the build differs from the plan, said first:**
- **D7 changed shape.** The plan said the router's bare `reports` and `tests_scans` would open what the home opens. Reading the callers showed every non-home caller means the decoder or the library, including bracket layers drawn *inside* the Scans door. Repointing them would have opened the Scans door from within itself. So the bare ids keep their router meaning. The callers that mean the decoder now name it (`report_decoder`: the condition journey and the Scans hub). The home is the one place where a bare id means the door tab. `tests_library` was not added, because nothing would call it (wiring gate).
- **Stop on the "added while trying" card has no confirm dialog.** It stops at once with an Undo toast, the same rule as every single delete in P1 (Mobbin: Undo over a dialog).
- **Reminders and other stages (verified, not changed).** The only other writer to `ReminderStore` is Parenting's health wallet (`hw_` ids). Those are real reminders that fire, so they stay listed. Recorded in STILL-OPEN §103.
- **Names.** "Is it safe?" for `can_i`, and "My reports" for `reports` (the user, through the relevance terminal, 2026-10-28), in `app_structure.dart`. `readings` and `report_decoder` are declared there too.

**Wave 1.**
- `test/preg_records_schema_contract_test.dart` reads the columns from the stores' own row builders. `medications`, `medication_logs` and `reminders` all matched, with no mismatch to report.
- PG1: `'readings' => ReadingsLogScreen` in `surface_router.dart`, and journey "Log it now" → `readings`.
- `'report_decoder'`: added to the router, and the journey's "The words on your report" and the Scans hub's "Understand my report" now use it.
- D5: four Pregnancy kinds on `PpUseConsent`, each with a `stage` (an exhaustive switch) and its own yes/no toast lines (`saidYes`/`saidNo`). Data and privacy lists each stage's own kinds.

**Wave 2.**
- **D1:** `readingConcern` with the constants in `readings_store.dart`. A doctor's pressure target quiets the call-today tier, never the call-now one. `_ConcernSheet` opens after the save and offers "Call your doctor" (the dialler), all the same-day signs, "Not now", and the not-a-diagnosis line. The store's header records the exception and why.
- **D2, after a loss:**
  - Reminders: a "Paused after your loss" section, and the baby presets step aside.
  - Is it safe?: the door drops "For your weeks", and the answer page drops its "For you" trimester line.
  - Scan checklist: "Questions to take to your doctor", with no "your anomaly scan" subject.
- **D3:** `MedicineStore.addedBefore` and `addedAt`, read from the id: `ttcm_` means trying, otherwise made before the pregnancy began. An id that does not parse means not known. The card offers Keep or Stop (Stop has Undo). Answers are kept per pregnancy, on this phone only.
- **D9:** AFI "5 to 25 cm" in two entries; only the number changed on the Hindi side.
- **D10:** the sunscreen line.
- **Find a condition:** the standalone gate and its chip are commented out (kept for revert), and the browse list carries the disclaimer.

**Wave 3.**
- **Toasts instead of silent saves:**
  - Readings: save, edit, delete with Undo (`restore`, same id), target.
  - Medicines: add, edit, untick, alarm switch, delete with Undo (`restoreMed` brings back the medicine and its days).
  - Conditions: add, and remove with Undo.
  - Is it safe?: the "My doctor said" pick.
  - Locker: remove with Undo, in both the list and the viewer, and the editor's save.
  - Reminders: the switch, and remove with Undo in both editors.
- **Empty input says why:** a medicine or reminder with no name now gets a line asking for one, where it used to close or show a dead button. The reminder save button is always live.
- **Readings target sheet:** range checks, and a draft kept in memory when she closes it.
- **Medication:** a tappable 7-day strip per medicine in Weekly, through `toggleOn` (past days and today).
- **Ingredient checker:**
  - on `PregToolScaffold`;
  - no emoji;
  - hint "Type an ingredient, like retinol";
  - no match offers Ask Veda and Is it safe?;
  - disclaimer under the list;
  - the coming-soon card commented out.
- **Tests library:**
  - on `PregToolScaffold`;
  - opens on her trimester;
  - "How doctors find it" replaces "Diagnosis";
  - one search entry.
- **Locker:** one shell (`PvDoorToolScaffold`), and its stale comments corrected (the picker colour; "the decoder reads from").
- **Reminders:** `init()` runs in `initState`, the preset titles have no emoji (saved titles keep theirs), and the header is current.
- **Checklists (D8):** ticks keyed `<list>@<scan>`, with one `adopt` from the old key. Clear all asks, then offers Undo (`restore`). The store's false "local only" header is marked superseded.

**Wave 4 (D4).**
- **Four sections in the Pregnancy doctor summary:** readings with targets, conditions she follows, reports, and what her doctor said.
- **Each behind its kind, three states:** her data after a yes; "you chose to leave these out" after a no, with a link to Data and privacy; and, when she has data but was never asked, a line pointing to the tool.
- **Asked once on each tool:** readings, conditions (the browse list), the locker, and the Is it safe? answer.

**Handed to Terminal A:**
- the home's readings fallback (`home_v3_screen.dart:1759`), waiting on this commit;
- the home medicine toast and the checker's door hint (both done by A);
- the tile names (A's user picked "My reports").

## Verified (2026-10-28)
- **New tests:**
  - `test/preg_records_schema_contract_test.dart` (6);
  - `test/preg_p1_routing_test.dart` (8);
  - `test/readings_concern_test.dart` (8: each threshold edge, the target rule, the sheet, Undo, the target checks and draft);
  - `test/preg_p1_tools_test.dart` (17: Reminders before and after a loss as widgets, the switch toast, no emoji in presets, the D3 derivation, restoreMed, adopt and restore, D4 wiring, the gate, the checker, the library, the names, the toasts).
- **Wider run:** every test file P1 could reach (Pregnancy, Is it safe?, conditions, the Scans, Nutrition, Complications, Belly and skin and after-loss doors, reports, readings, loss, TTC medication and tools, Parenting consent and feed, landing focus, doctor notes, stage tests, sync guard, reader unification): **1,676 passed, 0 failed.** The Is it safe? tests and the P1 file were run again after the last change: 41 passed.
- **`flutter analyze` on every touched file:** clean. In `scan_reports_screen.dart`, warnings for unused declarations remain (`_openReport`, `_confirmDelete`, `_Empty`, and two shown names plus an import); they are older code kept for revert, not added by P1.
- **Wiring grep:** `readingConcern`, `addedBefore`, `restoreMed`, `pausedForLoss`, `_presetsFor`, `_openingFilter`, `adopt`, `doctorCalls`, `afterLossTitle`, `'readings'`, `'report_decoder'` each have a live caller.
- **Not done:** a phone walk (on the user's word).
