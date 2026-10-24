# Stage transitions: what is left

**Resume here (2026-10-24):** B1–B7 and B10 LIVE (04847a5; B7 in c237e83) and the matrix is green (38 tests, `test/stage_transitions_test.dart`).
G1 (the "Expecting again?" guard) is RECORDED, not owed: the user caught that the parenting avatar opens You, so the
avatar menu the prototype drew is one no parent sees. Waiting on the user for two things:
1. A call on the Developer stage chips, which ship in every build (BEFORE-LAUNCH §6).
2. (0112 run by the user, 2026-10-24.)
3. B9, the cloud id collision: BUILT 2026-10-24 (sync log step 14, migration 0113); 0113 RUN 2026-10-25 (check query: 17 rows of `user_id,id`). Left: install the next build.
R9 (celebration pages) is next.

This file is the one list of what is left for GLOBAL-CHANGES item 9: every stage move, every mid-way join, and the
bugs found on them. It is a long series of tasks, so **move a row in the same change that moves the task**. Never
delete a row; a finished row becomes LIVE with its commit.

| Status | Meaning |
|---|---|
| OWED | Not started |
| LIVE 04847a5 | In the tree, tests green, not committed |
| LIVE `<hash>` | Committed |
| WAITING `<on what>` | Blocked on something outside the code |
| RECORDED | A product gap, written down, not being built in this pass |

Plan: `C:\Users\sarth\.claude\plans\read-docs-global-changes-md-and-the-noble-sparrow.md` (approved 2026-10-24).

## Decision record
| Question | Recommended | The user's answer (2026-10-24) |
|---|---|---|
| What does this pass do about the bugs the tests find? | Tests + fix the clear bugs; product gaps recorded | Tests + fix clear bugs |
| After a loss, "Move to trying to conceive" resets what? | Clean restart, loss kept | Clean restart, loss kept |
| Moves that don't exist (parent pregnant again, parent trying again, parenting → skilling)? | Guard now, build later | Guard now, build later |
| Mobbin pass and a running list? | — | "make sure to do a mobbin pass and keep them maintained in the md file so tht we know what all is left … as it will be a long series of tasks" |
| A parent taps "Expecting again": what happens to the parenting home? (asked 2026-10-25) | Move the app to pregnancy, the child kept under Family | Not answered as asked. The user: "analyze what to expect for this, it offers like swtiching accounts thing so all data is intact and one dosent affect the other.. we might have tht in competitor walks folder". Analysis below (§ Switching profiles) |
| When is "Moving on" at 6+ offered? (2026-10-25) | When every child is 6+ | "if we are having switch acc functionality then x can stay where they are, u can be in skiiling when they are 6 years old ukwim" |
| A "Back to parenting" row in the learning space? (2026-10-25) | Yes | "need to discuss the pros n cons for it.. i mean does coming back makes sense?" Discussed below |
| What do the celebration pages feel like? (2026-10-25) | Calm: painting, line, one button | Calm, "but it should be for like TTC -> preg, preg -> parenting, parenitng -> skilling.." (all three moves) |

## Switching profiles (analysis, 2026-10-25, not yet decided)
What the competitor walks show (`Downloads/competitor-walks`):
- **What to Expect** (`wte-parent/shots/030_stage_dropdown.png`): a dropdown at the top of Today lists "Baby-To-Be · Due Feb 15 2027" and "Baby · Birthday Jun 29 2026", each with a pencil, and "+ Add Another Child". Picking one changes Today, Tools and the tips to that profile's stage. Both live on one account.
- **theAsianparent** (`asianparent-parent/shots/065_profile_dropdown.png`): the header dropdown groups "Pregnancy" (due date) and "Kids" (each with a date of birth, plus "Add kid's profile"). The centre Tracker button changes to a pregnancy icon when the pregnancy is picked. The app remembers the active profile between launches.

What it would mean here: the home is chosen by **whose profile is open** (her trying, a pregnancy, a child 0 to 5, a child 6+), not by one stage the whole account is in. `docs/FAMILY-MODEL.md` already says stage is a tag and a pregnancy is a record with a start and an end. This makes the tag the thing that picks the home. Its "forward is the only direction" line would change: switching is looking at another profile, not moving back.

## Where the stage changes (read 2026-10-24)
| Move | Where |
|---|---|
| TTC → Pregnancy | `TtcTransitionEngine.confirmPregnancy`, `lib/ttc/ttc_transition.dart` (undo in the same file) |
| Birth (Pregnancy → Parenting) | `recordBirth`, `lib/services/stage_moves.dart` (was `_recordBirth` in `pv_you_sheets.dart`) |
| Loss | `PregnancyEndedStore.markEnded` (a flag; the stage stays `pregnancy`) |
| Loss → TTC | `moveToTtcAfterLoss`, `lib/services/stage_moves.dart` |
| Onboarding joins | `OnboardingFlow._finish`, `lib/screens/auth/onboarding/onboarding_flow.dart` |
| Developer switches | `pv_you_screen.dart` (`_switchStage`, `_switchToSkilling`), `ttc_profile_screen.dart` (`_toPregnancy`) |

## Tasks
### T · Housekeeping
| Id | Task | Status | Where |
|---|---|---|---|
| T0 | 0111 run by the user; ticked in BEFORE-LAUNCH and GLOBAL-CHANGES; this file created | LIVE 04847a5 | docs |

### B · Bugs with one obvious fix
| Id | Bug | Fix | Status | Test |
|---|---|---|---|---|
| B1 | The WhatsApp weekly guide keeps sending after a loss (0111 reads `life_stage`; a loss leaves it `pregnancy`) | Migration 0112: `pregnancy_ended_at is null or pregnancy_ended_at < life_stage_at`. **The user runs it** | LIVE 04847a5 · 0112 run by the user 2026-10-24 | M23, M24 |
| B1b | A new pregnancy after a loss opens on the loss page; its messages stay silent | `PregnancyEndedStore.ended` counts only when `endedAt` ≥ the pregnancy stage's `enteredAt` | LIVE 04847a5 | M22 |
| B2 | "Move to trying to conceive" after a loss changes only the stage: TTC stuck on "A new beginning", messages silent, old due date, the period "90 days late" | `moveToTtcAfterLoss()`: clear the TTC pregnant flag and the due date, set `cycleRestartOn`, set the stage | LIVE 04847a5 | M20, M21 |
| B3 | A second pregnancy's timeline is dropped (fixed ids); undo deletes the first pregnancy's entries | Dated ids for new events; undo removes only the ids it wrote | LIVE 04847a5 | M9, M10, M22 |
| B4 | Onboarding as a parent dates the stage from sign-up, no `baby_born`, no `markBorn` | Onboarding calls `recordBirth` and `markBorn` | LIVE 04847a5 | M29 |
| B5 | A second pregnancy gets no weekly messages (sent ids never repeat) | Sent ledger scoped to the current pregnancy | LIVE 04847a5 | M22 |
| B6 | A second child's parenting messages are silenced (ids not per child) | New sends prefixed with the child id; legacy ids belong to the oldest child | LIVE 04847a5 | M36 |
| B7 | Ask Veda button on the skilling home opens pregnancy Ask Veda | Hide on route `skilling` | LIVE c237e83 (rode with the Ask Veda mark commit) | M35 |
| B8 | TTC profile "Go to pregnancy" sets the stage with no due date (week-20 placeholder) | If release-reachable: route through `recordPositiveTest`; else note it | RECORDED: the button is in `TtcProfileScreenClassic`, which nothing opens (facade since 2026-09-19). No change | M34 |
| B9 | **Found 2026-10-24, wider than stage moves.** `journey_timeline`, `ttc_cycles` and `ttc_cycle_signals` have `id text primary key` across ALL users, and the app builds those ids from a date or a fixed name (`ttc_positive_test`, `ttcc_<date>`, `ttcs_<date>_<kind>`). After the first account writes an id, every other account's upsert of it hits that row, RLS refuses the update, and her row never reaches the cloud: two women who log a period on the same day cannot both sync it | A key per person: `primary key (user_id, id)` and the app's upserts on `user_id,id` (`family_timeline.dart`, `cycle_store.dart`, and `ttc_schema_contract_test.dart`'s conflict targets). It belongs to the sync work (STILL-OPEN-BACKEND), which is written only on the user's word | BUILT 2026-10-24 (user's word "start with b9"). 0113 re-keys 17 tables to `(user_id, id)`; the ledger, cycles, timeline and journals conflict on `user_id,id`; the shared timeline keeps her own row over the partner's copy of an event. Wider than first found: `symptom_logs`, `journal_entries`, `reminders` and two legacy tool tables collided too. 0113 RUN 2026-10-25 (check query: 17 rows of `user_id,id`); left: install the next build | `test/rows_keyed_per_person_test.dart` |
| B10 | **Found 2026-10-24 by the user.** The Skilling home's avatar opened the three-stage menu, not You. `V3HeroChrome` falls back to the menu unless `avatarOpensProfile: true`, and `skilling_preview_screen.dart` passed `onProfile` without it, though its own comment says the avatar is the one door to You | `avatarOpensProfile: true` | LIVE 04847a5 | M41 |

Fixes that came with B2 (same rule, more readers): the TTC messages' period list (`ttc_messages_store.dart`, the
"late, time to test" message), the day context (`ttc_day_context.dart`) and the Cycle Companion's empty state all read
`CycleStore.currentPeriodStarts` / `lastPeriodStart`. A loss therefore never makes a pre-pregnancy period "late".

### G · Guard
| Id | Task | Status |
|---|---|---|
| G1 | Pregnancy door from Parenting opens a calm "Expecting again?" page, not the old pregnancy at week 40 overdue | RECORDED 2026-10-24: there is no such door. The user caught it on the prototype: every home's avatar opens You (pp_home_v3 `onProfile`, Pregnancy `onAvatar`, Skilling after B10), so the three-stage menu (`showStageDoorMenu`) is reached by no parent. The only way from Parenting to Pregnancy is the Developer "Stage · testing" chips in Settings, which ship in every build (`kPvShipDeveloperSection`); that is a BEFORE-LAUNCH call, not a guard page. The page returns as the front of R1 if the real move is built |
| G1p | The "Expecting again?" prototype artifact: https://claude.ai/artifact/22FeLHfy2SHckLzVYt9uuE | SUPERSEDED: screen 1 drew a menu no parent sees. Kept as the starting shape for R1 |

### M · The test matrix (`test/stage_transitions_test.dart`, groups start with `stage:`)
| Id | Case | Status |
|---|---|---|
| M1 | Every `LifeStage` round-trips through `pv_life_stage` (skilling too) | LIVE 04847a5 |
| M2 | Same stage keeps `enteredAt`; `at:` is honoured | LIVE 04847a5 |
| M3 | Waiting push beats a cloud pull; else the cloud wins | COVERED by `ttc_transition_test.dart` (the pending-push guard, source scan) |
| M4 | Unknown, empty, `'new'`, `'pregnant'` ids | LIVE 04847a5 |
| M5 | Splash `_homeFor` for every stage × mother/father | LIVE 04847a5 |
| M6 | Each positive-test dating route gives the right due date and source | LIVE 04847a5 |
| M7 | A treatment round closing positive dates through `ttcRoundDating` | COVERED by `pregnancy_dating_test.dart` (`ttcRoundDating`) |
| M8 | A positive test with a round open goes to the round flow; stage unchanged | LIVE 04847a5 |
| M9 | Confirm twice: one set of timeline entries | LIVE 04847a5 |
| M10 | Undo: TTC again, due date cleared, only this pregnancy's entries removed | LIVE 04847a5 |
| M11 | Dating-check bands | COVERED by `ttc_transition_dating_test.dart` (`ttcDatingCheck`) |
| M12 | `recordBirth`: stage on the birthday, `baby_born` entry, real child | LIVE 04847a5 |
| M13 | `_bornWeeksFor` edges (36+6, 37, 19 weeks, no due date, after the due date) | LIVE 04847a5 |
| M14 | Skipped sex saved as not given | LIVE 04847a5 |
| M15 | Birth after week 42 records correctly | LIVE 04847a5 |
| M16 | Due date kept after birth | LIVE 04847a5 |
| M17 | Pregnancy messages stop, parenting messages start | LIVE 04847a5 |
| M18 | Loss: stage stays, loss page, pregnancy messages silent | LIVE 04847a5 |
| M19 | Undo the loss | LIVE 04847a5 |
| M20 | Loss → TTC: clean restart, loss kept | LIVE 04847a5 |
| M21 | First period logged after the restart drives the cycle | LIVE 04847a5 |
| M22 | Loss → TTC → new positive: pregnancy home, messages again, both timelines | LIVE 04847a5 |
| M23 | WhatsApp rule excludes a loss still in pregnancy (SQL contract) | LIVE 04847a5 |
| M24 | WhatsApp rule includes a new pregnancy after a loss | LIVE 04847a5 |
| M25 | Onboarding trying, every intent | LIVE 04847a5 |
| M26 | Onboarding pregnant, every dating method | LIVE 04847a5 |
| M27 | Onboarding pregnant at the edges (past due, far ahead) | LIVE 04847a5 |
| M28 | Twins flag; pregnancy after a loss sets `gentle` | LIVE 04847a5 |
| M29 | Onboarding parent: stage on the birthday, `baby_born`, `markBorn`, born early, second child | LIVE 04847a5 |
| M30 | Onboarding skilling: age clamp, stage saved | LIVE 04847a5 |
| M31 | Family-profile stage maps skilling to parenting (pinned) | LIVE 04847a5 |
| M32 | Pregnancy door from Parenting opens the guard; stage unchanged | RECORDED with G1 (no door to guard); M41 holds the avatar instead |
| M33 | The avatar door menu never writes the stage | LIVE 04847a5 |
| M34 | Developer switches change only the stage | LIVE 04847a5 |
| M35 | FAB hidden on skilling and `sk_`/`sk/`; stage detection from the route stack | LIVE 04847a5 |
| M36 | Two children: each gets its own parenting messages, no repeats | LIVE 04847a5 |
| M37 | Each message store cancels only its own id range | LIVE 04847a5 |
| M38 | Placeholder due date moves a week per 7 days, stops at 40 | LIVE 04847a5 |
| M39 | Past the due date: week 40, `daysPastDue` grows, arrival card from 37, 3-day snooze | LIVE 04847a5 |
| M40 | Wiring gate: every move goes through `stage_moves.dart` / `confirmPregnancy`; setStage allow-list | LIVE 04847a5 |
| M41 | Every home's avatar opens You, never the stage menu (source scan of `V3HeroChrome` / `V3PregHero` callers; parenting's `onProfile`) | LIVE 04847a5 (B10) |

### R · Recorded, not built (STILL-OPEN §101)
| Id | Gap | Status |
|---|---|---|
| R1 | Real moves: parent pregnant again, parent trying again, parenting → skilling; per-pregnancy records (bump photos, scans, bag, birth plan, garbh are single records, so a pregnancy after a loss shows the lost pregnancy's bump photos) | RECORDED · BEFORE-LAUNCH decision |
| R2 | The partner's phone never sees her stage change or her loss (`fetchMyProfile` reads his own row) | RECORDED · BEFORE-LAUNCH |
| R3 | After a loss, still in pregnancy: Learn, Tools, More and the Ask Veda context speak in weeks (Ask Veda part is a service-repo change) | RECORDED |
| R4 | Her own reminders are not paused after a loss | RECORDED |
| R5 | `FamilyProfileStore` stage drifts (nothing reads it) | RECORDED |
| R6 | "Replay onboarding" rewrites the stage and stores (developer only) | RECORDED |
| R7 | No prompt past 42 weeks | RECORDED |
| R8 | Pregnancy door from TTC shows the week-20 placeholder | RECORDED (user's call later) |
| R9 | Celebration pages: birth → parenting, parenting → skilling (Mobbin and prototype first) | OWED, next after this pass |

## Mobbin pass (2026-10-24)
| App · screen | What it shows | What we take |
|---|---|---|
| [Apple Health · Set Up Pregnancy](https://mobbin.com/screens/fed0b0c8-baa1-41ef-8683-fb54cd0c9570), [Add a Current Pregnancy](https://mobbin.com/flows/d0b0ae08-53d2-418e-9439-c7ace1f7dc31) | Intro sheet: picture, one line, Begin. Dating by period, due date, weeks or embryo transfer; "Log a Past Pregnancy" | The guard's shape: picture, two lines, one main button. Each pregnancy is its own record (R1) |
| [Oura · Women's Health](https://mobbin.com/screens/a9ff1b84-a364-47b0-aa8f-101d28a0dce4) | "Pregnancies · 1 logged"; a quiet "My pregnancy ended" | A loss is a quiet text action; past pregnancies are kept, never erased |
| [WHOOP · "Have you delivered?"](https://mobbin.com/flows/de10510d-1531-4905-8d3d-d89c5292e009) | Arrival card at week 40; mode switch "will reset the data" | Same arrival pattern as ours (M39). We decline the reset: nothing is wiped |
| [Clue · mode picker](https://mobbin.com/screens/ff343537-91bf-4235-a8ca-e667ee69f8bf), [Flo · switch confirm](https://mobbin.com/screens/0313c72a-488f-4267-ab78-40616abab989) | "You can change this later"; a confirm saying what changes | For R1: say what changes before it changes |
