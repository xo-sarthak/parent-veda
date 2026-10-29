# Pregnancy and TTC tools: master plan, one family at a time

## Context
The Parenting tools pass is finished (`docs/pp-tool-plans/`, 33 tools, last commit a224492, plus e04466b: no tool is hidden by age). The user wants the same pass for **Pregnancy, then TTC**: every tool relevant, working end to end (frontend and backend), and using what it learns only after asking. Step 0 below was done read-only on 2026-10-27. Two helpers read the code, and the lead checked each Broken or Wrong claim at its file:line.

The method is the Parenting one: `docs/pp-tool-plans/00-MASTER.md` (the 8-point audit, severities, T0 consent, the C1 rule, the "backend done" rule, the per-tool loop). This file records only what is different for these two stages.

## Out of scope (Terminal A, the relevance pass)
Terminal A (`docs/door-relevance/*-GAP.md`, commit 395ee74) owns:
- how her week, phase and clinic round are worked out;
- the due date (and a child's date of birth) being required, with week 20 for developers only;
- which tab each door opens on;
- the homes, Learn, notifications;
- the **order** of each Tools tab.

This pass owns what happens **inside** each tool and **which rows** each Tools tab lists. Terminal A also owns three items its TTC-GAP first left to us: the report card on clinic cycles, the "Your best days" copy (`ttc_focus_conceiving.dart:185`), and Move today at week 20 (`pv_door_router.dart:487`).

Working agreement with A:
- Only one terminal edits `tools_hub_screen.dart` or `ttc_tools_screen.dart` at a time. A goes first: its foundation fixes, then the order. Our rows come after A's commit.
- We have asked A to make the order a rule carried on each row (for example "lift from week 28", "lift on a clinic cycle"), so that new rows fall into place without A editing again.
- We never edit door files (`lib/data/doors/pv_door_*.dart`, `lib/ttc/focus/ttc_focus_*.dart`, `pv_door_router.dart`). A door change goes on the hand-over list below.
- Tool builds that read her week wait for A's foundation commit (her week worked out from today's date; `pregnancy_controller.dart:111` today freezes `_now` at launch).

## Decisions (the user)
| # | Question | Recommended | User's answer |
|---|---|---|---|
| M1 | Run alongside the relevance pass? | Yes, with the split above | **Yes, in parallel** (2026-10-27) |
| M2 | Which stage first? | Pregnancy (smaller hub, clear C1 gaps) | **Pregnancy first** (2026-10-26) |
| M3 | TTC: redo the audit, or resume it? | Resume. The 09-27/28 rebuild and the 09-30 review already cover points 3, 4 and 7. Sweep points 1, 2, 5 and 6 per tool, and spot-check every variant of a shared control | **Resume, no redo** (2026-10-26) |
| M4 | Consent across stages | Each stage asks its own; she can keep earlier answers or change some | **The user's shape** (2026-10-26). See T1 below |
| M5 | Hide a tool by age, week or phase? | Show Breastfeed timer to 24 months | **"dont hide tools tbh.. let them stay."** No Tools row is ever hidden by age, week or phase; relevance changes the order only (2026-10-27, built e04466b) |
| M6 | What counts as a tool for C1 | TTC's rule (`kTtcToolKinds`): records, tracks, calculates, checks or plans her own data. Practices, players and reading stay in their doors | **TTC's rule, both stages** (2026-10-27) |
| M7 | The four Pregnancy rows removed on 09-30 as "it's on the home" | Put them back | **Is it safe?, Symptoms, Tests and reports go back.** Garbh *daily* stays on the home ("homescreen specific"). A **Garbh Sanskar** row goes on Tools, a named exception to M6 (2026-10-27) |
| M8 | After a loss, how does "time trying" count? | Option A: every month spent trying, leaving out the months she was pregnant; show the number and let her change it | **Option A**, "be precise… show an option like want to edit… handle the wording" (2026-10-27). Spec in TT1 below |

## Shared piece T1: consent across stages (extends Parenting's T0)
- Parenting's `PpUseConsent` (`lib/services/pp_use_consent.dart`) stays as it is. Its kinds are `feeds`, `nappies`, `development`, `foods`, `changes`. Terminal A's two Parenting fixes gate on these now and wait on nothing.
- Pregnancy and TTC get their own kinds. Each is asked once, after the first save of that kind in that stage (the T0 pattern).
- **Moving into a new stage:** when a kind has the same meaning in the old stage (for example `medicines`, `symptoms`, `mood`), the card shows her earlier answer: "Last time you said yes to using your symptoms. Keep it here too?" It offers **Keep** / **Change**. Kinds new to the stage are asked fresh.
- Storage: one person-scoped answer per (stage, kind), so a stage never silently inherits an answer. "Keep" writes the answer for the new stage too. **To decide in the first family that needs a kind:** whether this generalises `PpUseConsent` additively (Parenting rows keep stage = parenting) or adds a sibling store. Answers sync only once consent sync is approved (Parenting's are still on the phone).
- The "What ParentVeda uses" section in You lists every kind, grouped by stage.
- A "no" changes ordering, reminders and suggestions only. **No feature is ever hidden.**

## Rule C1, both stages
Every tool (as defined in M6) that a door, a home card, Learn or search offers is also a row in that stage's Tools tab. A test holds it, per stage, the way `test/pp_tools_tab_test.dart` does for Parenting: it walks the door data and asserts that every tool's surface id is a Tools row, apart from a short named allow-list. **TTC has no such test today.** `test/ttc_tools_only_tools_test.dart` checks Tools against More but never reads `kTtcFocusPages`; `test/ttc_focus_page_test.dart:133` only checks that the ids resolve.

## Step 0 findings: Pregnancy (41 tool-like screens; 15 on Tools)
Hub = `lib/screens/tools_hub_screen.dart`. Every hub row opens a direct constructor through `_open` (hub:143), not `screenForSurface`.

### On Tools today
Baby movement, Weight, Medication and supplements, Blood pressure and sugar, Kegel Care, Reminders, Hospital bag (opens Ready for Birth), Birth plan, Contraction timer, Due date calculator, Product checklist, Journal, Bump, Spiritual reading, Ask Veda.

The hub already hides some rows by state:
- in the father preview, the Track group and Due date (hub:164, 236);
- after a loss, Get ready, Movement and Weight (hub:166, 173, 217).

These state-hidden rows are checked against M5 in their family. A loss is a different case from age: the rows may stay but move, and the plan decides.

### C1 misses (tools under M6 that are not on Tools)
| Tool | Where it is offered | Proposed group | Family |
|---|---|---|---|
| Is it safe? `can_i` | home row, Learn `preg_learn_screen.dart:290`, Nutrition door | Ask | P1 |
| Symptom check-in, your week, send my week | Symptoms door (inline) | Check in | P5 |
| Calendar and appointments `calendar` | home hero `home_v3_screen.dart:575`, home row, More | Your week | P3 |
| Scans timeline, report decoder, reports locker, tests library `tests_scans` | Scans door (inline); `screenForSurface` | Records | P1 / P3 |
| Question checklists (scan, diet, condition) | Scans, Nutrition, Complications doors | Records | P1 |
| Find a condition | Complications door (inline) | Ask | P1 |
| Ingredient safety checker | Belly and skin door | Ask | P1 |
| Shopping list | Nutrition door | Get ready | P4 |
| Mood track, gentle check-in | Mind door | Check in | P5 |
| Nutrition today (plate, ticks) | Nutrition door (inline) | Check in | P5 |
| Name finder (Parenting's screen) | Getting ready door | Get ready | P2 |
| Your due date (setter) | home hero, You | merge with the calculator | P3 |
| Garbh Sanskar (M7 exception) | home, door | Keep | P2 |

Not tools under M6, so they stay in their doors and the C1 test allow-lists them:
- Garbh practices: listen, read, story, play, relaxation, kriya, ritual;
- Mind audio and breathing, the helplines;
- Move today, which is the Move door's activity under GLOBAL-CHANGES #16.

### Broken / Wrong (checked)
| # | Finding | Severity | Where | Owner |
|---|---|---|---|---|
| PG1 | "Track my readings" → "Log it now" opens the **Weight** tracker, not the blood pressure and sugar log | Wrong | `lib/data/journeys/pregnancy_journeys.dart:251` | us, P1 |
| PG2 | `screenForSurface('appointments')` opens the retired Scans and appointments screen; the hub calls it merged and retired | Wrong | `lib/services/surface_router.dart:80`, reached from `pregnancy_journeys.dart:296` | us, P3 |
| PG3 | "Choose something else to read" on Garbh's passage and story does nothing: `onOpenLibrary: () {}`, while the row still draws (`garbh_samvad_daily.dart:619`) | Broken (silent tap) | `pv_door_router.dart:455, 461` | **A** (door router) |
| PG4 | Labour and Complications consult tiles open the Scans version ("Talk it through", about reading a report) | Wrong | `pv_door_router.dart:325-332`; `pv_door_labour.dart:684`, `pv_door_complications.dart:486` | **A** |
| PG5 | "What to say when you call" opens with "How many weeks you are" but is a const with no controller, so it never shows her week | Weak | `symptoms_screens.dart:244-250` | us, P5 |
| PG6 | The home `_open` returns silently for a community surface | Check (does any home tile still reach it?) | `home_v3_screen.dart:2027` | A (home), we report |

### Repeats and labels
- **Two due-date screens:** `DueDateCalculatorScreen` and `PregDueDateScreen`, sharing the maths (`preg_due_date_screen.dart:14-17`). Settled at P3: one tool.
- **Two journals:** "My Journal" (`JournalScreen`) and Garbh's "My Journal" (`GarbhJournalScreen`, `pv_door_garbh.dart:346`). Settled at P2.
- **Mood, three ways:** Mind's track tab, the gentle check-in, the symptom check-in. Settled at P5.
- **"Reports" means two screens:** the home row opens the Scans door's Reports tab; `screenForSurface('reports')` opens the decoder (`surface_router.dart:82`). Settled at P1.
- **Names drift:**
  - "Contraction Timer" / "Contraction Tracker" / "Contraction timer";
  - the home row's "Can I…?" (`services/app_structure.dart:127`) vs "Is it safe?";
  - "My Hospital Bag" opens "Ready for Birth".

  One name per tool, settled in its family. Door-tile names go to A.
- **Tiles that promise one thing and open another:**
  - "Shop the list" opens a checklist (`pv_door_getting_ready.dart:214`);
  - "Your partner as birth support" opens a course (`pv_door_labour.dart:571`).

  Both are door files, so they go to A.

### Not on the shared tool look (`PregToolScaffold`)
Birth plan (`PvDoorToolScaffold`), Journal, Ask Veda, Is it safe?, Calendar, the due-date setter, the tests library, the contraction timer's live phases (`contraction_tracker_screen.dart:366`), and every door-only tool in the C1 list. Each one moves at its family's turn, and a Pregnancy one-look test (like `test/pp_tools_one_look_test.dart`, with an `_owedShell` list that can only shrink) holds it. Live hub rows already draw their marks (`IntentMark` → `ttcFamilyMarkForIntent`); only the two debug rows use icons.

### Shared with other stages
- Kegel Care: Parenting opens it too (`pp_surface_router.dart:834`; postpartum mode at `kegel_care_screen.dart:177`).
- Name finder: a Parenting screen.
- `MedicineStore`: shared with TTC's Medication.

**A change to any of these keeps the other stage working.** Each family's tests include the other stage's tests for those files.

## Step 0 findings: TTC (25 tools)
Tools = `lib/screens/ttc/ttc_tools_screen.dart`; classification `kTtcToolKinds` (:755).

### Clinical (checked)
| # | Finding | Severity | Where |
|---|---|---|---|
| TC1 | After a loss, "I'm ready, move to trying" keeps her old start date, so `daysTrying` counts the months she was pregnant as trying. The "should we see a doctor" check prefills from that number | **Wrong, clinical** | `lib/services/stage_moves.dart:143-158`; `ttc_store.dart:247`; `ttc_ivf_readiness_screen.dart:193` |
| TC2 | The live check (`TtcIvfReadinessScreen`, `ttc_surface_router.dart:338`) asks "A previous miscarriage" as a yes/no condition (`ttc_ivf_readiness.dart:141`) and never sets the count (:193). One loss fires `known_condition`, a **"don't wait"** result whose reason reads "endometriosis, tubal factor, reduced reserve, previous ectopic" (`ttc_fertility_help_rules.dart:323`). The two-or-more rule (:314, :426) **can never fire.** Losses the app has recorded (`PregnancyRecords`, outcome `loss`) are never read | **Wrong, clinical** | as listed |
| TC3 | The 12-month rule's trigger reads "under 36", but it fires under 35 | Wrong (label) | `ttc_fertility_help_rules.dart:400` |
| TC4 | The fertile window is correctly replaced by a treatment card whenever a clinic owns timing (`ttc_window_screen.dart:373`; `ttc_care_pathway.dart:205`), but its header still says "Today is day N of your cycle" | Weak | `ttc_window_screen.dart:324-329` |
| TC5 | Coming back to trying from the family side runs the intro again (`stage_moves.dart:354`). If she skips "how long", the old start stays, counting the pregnancy and the parenting years | Wrong | `ttc_intro_flow.dart:285` |

### C1 misses
Read your semen report (`ttc_focus_his_side.dart:295`, and not in his list `kTtcHisToolIds`), Ready-to-Try plan (`ttc_focus_getting_ready.dart:609`), Cycle report (`ttc_focus_pcos.dart:730`), "Should I test?" (`ttc_focus_conceiving.dart:525`). Calendar is on neither a door nor Tools (home and You open it). Treatment start is covered by the Treatment row.

### Repeats and labels
- Ready-to-Try plan is a view over the checklist (`ttc_surface_router.dart:273`): keep both or fold, settled in its family.
- Cycle Companion and Calendar both show her cycle: settled in its family.
- Ovulation tests are logged in two places but into the same keys (`ttc_ovulation_screen.dart:24`). This is fine, one store, like Parenting's R5.
- Door labels that contradict the tool: "Plan your own week of meals" vs "A week of ideas, not a plan"; "The four habit trackers" vs one merged tracker. Both are door files, so they go to A.
- Medical tests and Can I…? are look-ups. They stay tools under M6 (look-ups check her question).

### Not on `TtcToolScaffold`
Cycle Companion (`ttc_cycle_companion.dart:159`), Fertile window (`ttc_window_screen.dart:232`), Calendar (`ttc_calendar_screen.dart:207`, `TtcPage`), the "Should I test?" chat (`chats/ttc_chat.dart:274`). `test/ttc_tools_one_shell_test.dart` pins only 9 screens; it grows to every Tools row.

## TT1: "time trying" after a loss (M8, option A), the full spec
**The rule.** Time trying = days from her trying start to today, minus every day she was pregnant inside that range. Her original start date is never overwritten.

**Where the pregnant days come from.** `PregnancyRecords` (`lib/services/pregnancy_records.dart`): each ended pregnancy is a span from its start (due date − 280 days) to `endedOn`. All outcomes count as pregnant time (`loss`, `birth`, `ended`), because she was not trying while pregnant. Only `loss` counts toward the loss rule (TT2).

**What she sees.** The "Should we see a doctor?" check, and every screen that shows how long she has been trying (the TTC Today hero `ttc_today_screen.dart:102` among them), all read one getter, so the number is the same everywhere:
> **About 7 months of trying**
> Counted from January 2025, leaving out April to June, when you were pregnant.
> **Change**

The number uses the existing `tryingLabel` (`ttc_fertility_help_rules.dart:160`), never a raw day count. If no pregnancy falls inside the range, the second line is just "Counted from January 2025."

**Change opens a sheet:**
> **How long have you been trying?**
> ◉ Since I first started, January 2025, leaving out my pregnancy *(about 7 months)*
> ○ Since I started again, July 2025 *(about 3 months)*
> ○ From a different date
>
> Doctors usually ask how long you've been trying in all, so the first one is what we count unless you change it.

On save, a `pvToast` says what changed, and the check re-runs:
> Now counting about 3 months of trying, from July 2025. The doctor check uses this.

If the result itself changes, the toast says so too: "…The check now says it's worth talking to a doctor."

**Edge cases, each with its answer**
1. **No pregnancy in the range:** no "leaving out" text. The sheet offers only "Since I first started" and "From a different date".
2. **Several pregnancies:** each is left out, overlapping spans are merged, and the line names each gap ("leaving out April to June 2025 and February to March 2026").
3. **A pregnancy that began before her start date** (she set the start later): only the overlap is left out.
4. **A pregnancy whose start is unknown** (no due date on the record): we can't say when it began, so nothing is subtracted. That gives the higher number, which leans toward the doctor conversation, the existing principle at `ttc_fertility_help_rules.dart:74`. The line says so: "We couldn't tell when your pregnancy began, so it isn't left out. Change." Change offers "From a different date". Once A's due-date-required fix lands this becomes rare, but old records can still have no due date.
5. **She never said when she started:** `journeyStart` (`ttc_store.dart:91-96`) always falls back, in this order: her Ready-to-Try planned start, her stated start, her onboarding "how long" answer, then the day she entered the stage. So the number is never unknown, but the line has to say which of these it came from. For the last two: "Counted from [date], when you told us / when you joined. Add when you really started", which opens the date picker. A planned start in the future shows "You plan to start in [month]" and no count (today it already reads as day 0).
6. **"Since I started again":** the date is the day she moved back to trying after the latest loss. That date is **stored with the choice**, because `LifeStageStore.enteredAt` moves on any later stage change.
7. **"From a different date":** no date in the future, and none more than 15 years back. Pregnancy months inside her own range are still left out, and the line says which ones.
8. **The loss is undone** ("go back to my pregnancy view", `stage_moves.dart:121`): she is in Pregnancy again and the number isn't shown. If she moves back later, it is worked out again from the records.
9. **She comes back to trying from the family side and skips "how long" (TC5):** her start becomes the day of that move, not the old one. The line reads "Counted from [date], when you started trying again. Change."
10. **Crossing a threshold** (6 months at 35 or older, 12 months under 35) because of a change: the check re-runs and the toast names the new result.
11. **Partner's phone:** he sees the same number. The choice syncs in the same row as `journey_start` (`TtcTables.journeys`, `ttc_store.dart:455`), with the same sharing rules. His device never computes from her `ttc_cycles`.
12. **Sign-out, or another account:** the choice is cleared locally with the store's `resetLocal` and comes back from the cloud.
13. **Ask Veda and messages:** they already read `daysTrying` (as `months_trying`), so they follow the same getter. No new wire field, so no two-repo change. A's "trying a while" message reads the same getter. A will be told.
14. **Never a probability:** the line states time only, never a chance.

**Data.**
- One new column on `ttc_journeys`: `trying_count_from` (`first` | `again` | `own`), plus `trying_count_date` for `again` and `own`.
- A migration (the user runs it), a sync contract test in `test/ttc_schema_contract_test.dart`, a sync log step, a STILL-OPEN-BACKEND row.
- BACKEND-PATTERNS gets a short "derived value with a stated basis" note: the stored fact stays, the shown number is derived, and her override is stored as a basis, not as a rewritten fact.

**BEFORE-LAUNCH clinical line:** a doctor confirms that "all months trying, minus pregnancy" is the right default after a loss.

## TT2: losses come from her records (TC2)
- The loss count = `PregnancyRecords` with outcome `loss` (an undone loss drops out). `ended` and `birth` are never counted as losses.
- Losses from before she used the app: the check asks only what we can't know. "We have 1 loss on record. Any others before you used ParentVeda?" offers None / One more / Two or more. That is derive first, ask only for the unknowable.
- **Two or more losses** (recorded plus told): the two-loss rule fires (ASRM and ESHRE define recurrent loss as two or more). The result is calm, with the disclaimer, and routes to a doctor.
- **One loss:** it no longer fires `known_condition`. "A previous miscarriage" leaves `kIvfKnownConditions`; it is commented out with a "kept for revert" note. The result says something like "One loss on its own isn't a sign anything is wrong, and it's always fine to talk to a doctor." The exact copy goes on a BEFORE-LAUNCH clinical line.
- TC3, the "under 36" label, is fixed in the same family.
- Tests:
  - one loss doesn't fire "don't wait";
  - two losses do;
  - an undone loss drops out;
  - a loss recorded in the app is not asked about again.

## Families and order
Each family runs the same loop: read-only audit against the 8 points (severity on every finding, file:line checked), one Mobbin search per tool when its UX changes, the backend done, the plan for the user's approval, the build in waves with tests, the wiring grep and docs.

| # | Family | Tools | Waits on A? |
|---|---|---|---|
| P1 | **Look-ups and records** | Is it safe?, Find a condition, Ingredient checker, Report decoder, Reports locker, Tests library, Question checklists, Medication, Blood pressure and sugar (PG1), Reminders | No. **First** |
| P2 | **Keep** | Journal (and the Garbh journal repeat), Spiritual reading (tool or reading, under M6), Birth plan, Name finder, Bump, the Garbh Sanskar row (M7) | Only Bump |
| P3 | **Her week** | Due date (one tool from two), Calendar and appointments (PG2), Scans timeline, Weight, Baby movement, Kegel Care | Yes |
| P4 | **Birth prep** | Hospital bag, Product checklist, Shopping list, Contraction timer | Yes |
| P5 | **Daily check-ins** | Symptom check-in and your week (PG5), Mood track, Gentle check-in, Nutrition today | Partly (the check-in reads her week) |
| T1 | **TTC: the doctor check** | TT1, TT2, TC3, TC5 | A's chapter fix only for its Today hero line |
| T2 | **TTC: cycle tools** | Cycle Companion, Calendar, Fertile window (TC4), Ovulation tests, Cycle report, "Should I test?" | Yes (phase and clinic) |
| T3 | **TTC: getting ready** | Checklist, Ready-to-Try plan, Supplements, Tests, Vaccinations, Food ideas, Can I…?, Habits | No |
| T4 | **TTC: treatment and records** | Treatment cycle, Medication (shared `MedicineStore`), Records, Appointments, Semen report | No |
| T5 | **TTC: body checks** | Symptoms and mood, Weight and BMI, PCOS check, Partner health | No |

Each Pregnancy family starts with its C1 rows and the one-look move. C1 for the whole stage, with its test, lands as one small build after A's Tools-tab order commit, the way Parenting's C1 did. T1 can run alongside the Pregnancy families because it touches no Tools-tab or door file.

## Hand-over list for Terminal A (door, home and router files)
**Status (2026-10-29):** Terminal A did items 1, 2, 3 and 5, plus the owed after-loss hero lines, the bag-on-Partner tile, the "Contraction timer" name and the router's `afterLossNote` and pregnancy pass, in **29077918** (PREGNANCY-GAP 35). **Item 4 (labels that over-promise and tile-name drift) is still open**; T2 adds its own lines to it below.

1. PG3: the Garbh "Choose something else to read" silent tap (`pv_door_router.dart:455, 461`).
2. PG4: the Labour and Complications consult tiles land on the Scans version.
3. PG6: does any home tile still reach the silent community return (`home_v3_screen.dart:2027`)?
4. Door labels that over-promise: "Shop the list", "Your partner as birth support", "Plan your own week of meals", "The four habit trackers", plus the door-tile name drift (Contraction Tracker, Track this treatment cycle, and so on). Each tool's family sends its one name.
5. TT1 changes the `daysTrying` getter that A's "trying a while" message reads. That needs no change on A's side; this is a heads-up.

## Verification, per family
- `flutter analyze` on the touched files; the stage's tests (`test/preg_*`, `test/ttc_*`, plus Parenting's for shared screens); the new tests (reachability, store round-trip, sync contract, C1, one look).
- The wiring grep on every new reader and row.
- A phone walk only on the user's word.
