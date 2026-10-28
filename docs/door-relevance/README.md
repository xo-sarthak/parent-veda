# Relevance pass: read this first

**What this is:** making the whole app follow where she is: her pregnancy week, her cycle phase or clinic step, or her child's age. A user at week 20 never sees week-1 material. Irrelevant things never crowd out what she needs now.

**Status (update this line every time a batch lands):** analysis 395ee74, plan 52aa2d2. **Batch 1 COMMITTED fe1a831 for Pregnancy and TTC (2026-10-27)** (Parenting parked by the user until the very end). **Batch 2 COMMITTED ab21531 (Pregnancy doors open on her week).** **Batch 3 COMMITTED 0b5823e (TTC doors open on the right kind; two long explainers).** **Batch 4 BUILT 2026-10-28 for Pregnancy and TTC (homes and other screens), commit hash to add.** **Next: Batch 5 is Parenting (parked), so the next Pregnancy/TTC work is Batch 6 (content).** Terminal B: week-dependent tool builds are unblocked once Batch 1 is committed.

## How to resume (any new session)
1. Read `CLAUDE.md`, then this file, then the gap file for the stage you're working on:
   - `PREGNANCY-GAP.md`: the whole stage, including the 15 doors
   - `TTC-GAP.md`: the whole stage, including the 9 doors
   - `PARENTING-GAP.md`: everything except the doors (they were rebuilt in `docs/pp-door-plans/`)
2. Run `git status` before any edit. Other terminals share the tree; never touch their uncommitted files.
3. **Re-check a fault at its cited line before fixing it.** The gap files cite `file:line` as of 395ee74, and code moves. If a fault is already fixed, or the line has moved, correct the gap file in the same change.
4. Work one batch at a time. Explain the reasoning as you build (`CLAUDE.md`, Working agreements). The user runs git.

## Decisions already made (don't re-ask)

| Date | Decision | Where |
|---|---|---|
| 2026-10-26 | **Information doors explain first; action doors open on the activity.** IVF/IUI teaches what it is, how and why (video slot plus a simple read) before the journey. A yoga door opens on yoga, never on an article about yoga | GLOBAL-CHANGES #16 |
| 2026-10-26 | **Due date required** to be in Pregnancy; **child's date of birth required** to be in Parenting. The week-20 and born-today stand-ins are for developer mode only | Gap files §0 |
| 2026-10-26 | After a loss, the "trying a while" count does not restart. The doctor-check rule is in `lib/ttc/ttc_fertility_help_rules.dart:420-440`, which is the source of truth | TTC-GAP §0 |
| 2026-10-26 | Development content uses **corrected age** under 24 months; vaccines, growth and messages keep birthday age, and the screen says which | PARENTING-GAP §0 |
| 2026-10-26 | Labour changes kind at week 37: explain before, timer from 37 | PREGNANCY-GAP §0 |
| 2026-10-27 | Consent is **not** a blocker: `PpUseConsent` already covers feeds, nappies, development, foods and changes. New uses call `allows(kind)` | PARENTING-GAP §0 |
| 2026-10-28 | Pregnancy products: **rank by closeness to the one "have it by" week**, no invented `weekTo` (recommended; the user did not overrule) | PREGNANCY-GAP 14 |
| 2026-10-28 | The reports tile is called **"My reports"**, not "Report decoder" (user's choice). Handed to the tools terminal, whose P1 item 4 owns the door tile names | Tools terminal's P1 plan |
| 2026-10-28 | The dating-scan prompt is a **home rail card** (weeks 14 to 27), not a line in the hero: the hero line would replace her countdown for as long as the flag holds | PREGNANCY-GAP 13 |

## Who owns what: the relevance terminal and the tools terminal

Agreed 2026-10-27. The **relevance terminal** owns *where she is and what shows first*. The **tools terminal** owns *what happens inside each tool*.

| Seam | Relevance terminal | Tools terminal |
|---|---|---|
| Her week, due date, chapter vs clinic, child's age | **Owns it, and lands it first (Batch 1).** | Audits meanwhile; **holds any tool build that depends on her week** until Batch 1 is committed |
| Tools tab (`tools_hub_screen.dart`, `ttc_tools_screen.dart`, `pp_tools_tab.dart`) | Owns the **order**, written as a **rule on each row** (a week from which it lifts, or a lift on a clinic cycle), never fixed positions, so new rows slot in without another edit. **Landed in Batch 4 (2026-10-28):** Pregnancy rows take `fromWeek:` and groups `leadsFromWeek:` (`lib/services/preg_tool_order.dart`); TTC groups take `leadsOnClinicCycle:` and the lead rows are `kTtcClinicCycleLeadIds`. A new row needs none of them | Owns **which rows** show (C1), and adds rows after the order lands. **One terminal edits a tools-tab file at a time;** say so before touching it |
| Door tabs that open on a tool (Labour timer, TTC Getting ready checklist, Not yet doctor check) | Owns which tab or card opens first | Owns the tool. If it renames a tool or changes a surface id, it hands over the door row instead of editing door files |
| TTC doctor-check rules (`ttc_fertility_help_rules.dart`) | Only reads `firedRules` (e.g. the home "Time for a check" card) | Owns the engine and its gaps: losses asked rather than worked out from her record, the "under 36" label, the trying-again start date |
| Parenting activities per child | Takes the fix (Batch 1), recorded against Parenting tool 20 | — |
| Parenting tools hidden after 12 months (`pp_tools_tab.dart:117`) | — | Owns it (which rows show); the user is deciding |
| Report card on clinic cycles; "Your best days" copy; Move today at week 20 | **Relevance terminal's** (moved from "left to the tools terminal" on 2026-10-27) | — |

**A two-repo change:** anything new sent to Ask Veda (Parenting family context, any new field) needs the service repo `C:\Projects\parentveda-askveda`. Ask the user for access first. Never ship one side alone without writing down what the other side still needs.

## The build plan

Each batch: re-check the faults, fix them, add or extend tests, `flutter analyze` clean, run the touched stage's tests, update the gap file (strike the fault and add the commit), update this status line and GLOBAL-CHANGES, then give the user the git commands. **Grep the call site before calling anything done** (wiring gate).

| Batch | What | Faults | Notes / risks | Status |
|---|---|---|---|---|
| **1 · Foundation** | **Pregnancy:** `currentWeek` / `daysToDueDate` / `currentDay` worked out from today, not the frozen `_now` (`pregnancy_controller.dart:111`). Due date required on every way in: TTC "Yes I'm pregnant" asks for the date when the logged period is more than ~10 weeks old or missing; the developer chips' fall-through goes to the dating page; the old sign-in never sets the stage; an existing user with no date gets a required due-date sheet on open. "No week" passed wherever a stand-in could still appear. **TTC:** `TtcChapter` gives way to the round step when a clinic owns the cycle (Ask Veda suggestions, Sanskar); `ttcIsNewPeriodDayOne` counts from `currentPeriodStarts`; window messages held until the first period after a loss; the home check card reads `firedRules`. **Parenting:** activities keyed by child id plus age band; the developer chip and old "New parent" ask for a child | PREG 1, 2, 9, 19, 25 · TTC 1, 2, 6, 11, 19 · PP 1, 10 | **As built 2026-10-27 (Preg + TTC):** PREG 1, 25 done; 2 part (required date + Store header; other guards ride later batches); 9 and TTC 19 were already done (helpers misread them); 19 kept on purpose (developer chips); TTC 1, 2, 11 done; TTC 6 moved to Batch 4 after the tools terminal's losses fix. Tests: `relevance_batch1_test.dart` + the round sweep in `ttc_date_consistency_test.dart`. **PP 1, 10 parked by the user until the end.** Was: **Riskiest batch: it touches every Pregnancy reader of the week.** The tests that hold dating (`pregnancy_dating_test.dart`, `stage_transitions_test.dart`, `preg_door_relevance_test.dart`) must stay green. Inject the clock (`now:`) instead of reading `DateTime.now()` directly, so tests can move time. The tools terminal waits on this commit | **BUILT (Preg + TTC)**; PP parked |
| **2 · Pregnancy doors** | `tabOrder` by week for Labour, Getting ready, Complications and Scans (copy Parenting's `PpDoor.tabOrder` shape); Learn uses `sectionsFor`; tags for Belly and skin, Work and money, Twins (and Symptoms, Labour, Partner, owed in #13); Nutrition `lead` checks weekKnown; Mind uses `withTiles`; Is it safe? intro chip; "coming soon" tiles toast | PREG 3-6, 16-18, 20 | **As built:** `openingGroupFor` on six doors with the clinical source beside each; four section tags; Learn by week; Nutrition lead waits for a real week; Mind copy keeps tags; Is it safe? chip; door cards toast when coming soon. Not done: Symptoms tags (content, Batch 6), `PvShelfCard` toast (Batch 4). Test: `preg_door_first_view_test.dart` (weeks 6/14/24/34/40, data and screen) | **BUILT** |
| **3 · TTC doors** | IVF opens on a "what IVF and IUI are" explainer; Getting ready opens on the checklist; Not yet opens on the doctor check; Body and cycle opens on "how your cycle works"; Mind and body headings open practices; Conceiving made clinic-aware; `ttcDoorVideosFirst` uses `withTiles` | TTC 3, 5, 7-9, 21 | **As built:** two new long `PvRead`s (IVF/IUI from the beginning; the cycle phase by phase), IVF opens on Understand outside a round, Getting ready on the checklist, Not yet on the doctor check, Body and cycle on the explainer, Mind and body headings on practices, Conceiving card true on clinic cycles. Videos for the two explainers owed. TTC 21 (`ttcDoorVideosFirst` tags) left: it runs after ranking, harmless. Test: `relevance_batch3_test.dart`. Found and handed to the tools terminal: `ttc_data_chain_test` "most recent entry has no length yet" fails on its own (CycleStore, not touched here) | **BUILT** |
| **4 · Homes and other screens** | Tools tab order rules (Pregnancy by week; TTC on a clinic cycle), **after telling the tools terminal**; past-40 week on rails and in More; home tile lifts; due-date prompt on home; "Is it safe?" card by trimester; TTC Store needs during a round or after a loss; round panel main button; report card; Learn order; one start card on TTC day one; Parenting: one age for content, products rail from `PvCatalogStore`, Brain tab matches home; search ties broken by position | PREG 7, 8, 10, 12-15 · TTC 4, 10, 12-18 · PP 2, 3, 5, 12 | Order only: never hide a row (a feature is never hidden). **As built (Preg + TTC):** all fourteen Pregnancy and TTC faults, plus TTC 6 (the check card reads the doctor check, now that T1 is in) and the ride-alongs PREG 20, 22, 24 and TTC 23, 25 (part). Three handovers from the tools terminal's P1: the home's readings tile opens the readings log (after 305b5c6), the home medicine tick says what changed, and the ingredient checker stops promising product search. Found on the way: the Batch 3 cycle read had borrowed another read's photo (`ttc_no_repetition_test` failing on main); it has its own now. Cleared with the tools terminal before the Tools tabs. Choices: products ranked, no invented end week; the dating-scan prompt is a rail card for weeks 14 to 27, not a hero line. Test: `relevance_batch4_test.dart` (36 tests), plus `preg_tile_order_test.dart` updated. **PP 2, 3, 5, 12 parked by the user until the end** | **BUILT (Preg + TTC)**; PP parked |
| **5 · Parenting Today strip and signals** | The Today strip in PARENTING-GAP §2; "Something changed?" moves activities behind `allows(changes)`; Ask Veda family context (**two-repo**) | PP 4, 6, 7, 8, 9 | Prototype first (Artifact) per the house rule for flow changes | OWED |
| **6 · Content** | Demand gaps in each gap file §4: guidance in the door's voice, never Q&A; each new section also goes to the Ask Veda ingest | PREG §4 · TTC 20 | Write as `PvRead`s | OWED |
| **7 · Notifications** | Folded into GLOBAL-CHANGES #12 Phase 6: Pregnancy weeks 4-10, glucose test, growth scan; TTC after loss; Parenting double vaccine reminder | PREG 11 · TTC 19 · PP 11, 16 | Mobbin pass first, per #12 | OWED |

Polish items not named above ride along with the batch that touches the same file.

## Keeping this plan honest
- **This file goes stale as code changes.** When a batch lands, or another terminal's commit changes something here (a moved line, a fault fixed elsewhere, a changed ownership), update this file and the gap file in the same change. A stale plan is worse than none, because the next session trusts it.
- If you find a new fault while building, add it to the stage's gap file with severity, `file:line` and a one-line fix. Don't park it only in chat.
- Changes in ownership go in the seams table with a date.
