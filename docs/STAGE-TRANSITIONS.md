# Stage transitions: what is left

**Resume here (2026-10-24):** B1–B7 and B10 LIVE (04847a5; B7 in c237e83) and the matrix is green (38 tests, `test/stage_transitions_test.dart`).
G1 (the "Expecting again?" guard) is RECORDED, not owed: the user caught that the parenting avatar opens You, so the
avatar menu the prototype drew is one no parent sees. Waiting on the user for two things:
1. A call on the Developer stage chips, which ship in every build (BEFORE-LAUNCH §6).
2. (0112 run by the user, 2026-10-24.)
3. B9, the cloud id collision: BUILT 2026-10-24 (sync log step 14, migration 0113); 0113 RUN 2026-10-25 (check query: 17 rows of `user_id,id`). Left: install the next build.
Next (2026-10-25): the F table under Tasks; the celebration pages are F4. B11 (child records read per child) LIVE c70a791, sync step 16.
**F2 LIVE 2290cce** (Add a pregnancy from the family; plan file `tingly-stirring-rain.md` in the user's plans folder); before it the full suite was re-run after R1 and its 8 failures fixed. Next: install a build and walk F2 + R1 on the phone (user's word), then F5's one learning space per child.

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
| R1: what happens to a lost pregnancy's records? (2026-10-25) | Sealed as that pregnancy's, a new one starts clean; she can look at it (view only, no reminders or weeks) or delete it, never asked at the moment of the loss | The user's idea: "let them take control of it and delete it permanently if they want tht, why decide for them?" Agreed |
| R1: where does she find it? (2026-10-25) | A quiet "Kept for you" line at the foot of the Your family sheet, and in You under her pregnancies; never in the header switch beside her children | "what u suggested is fine" |
| R1: how permanent is delete? (2026-10-25) | Gone from the cloud at once, with a 7-day Undo on the phone | "lets keep it 90 days for now": the house soft delete, purged after 90 days (`pv_purge_removed`), so the copy must say when it is gone |
| F2: where does "Add a pregnancy" live? (2026-10-25, plan approved) | The family sheet under Add a child, Parenting You ("Expecting again?"), and the drawer's "Yes, I am pregnant" | Approved with the plan |
| F2: what happens to the stage? (2026-10-25, plan approved) | It moves to pregnancy: the state a pregnant mother with older children already has, so the children open over the pregnancy home from the switch | Approved with the plan |
| F2: "the test was wrong" after adding one? (2026-10-25, plan approved) | Back to her children, the stage dated from the birthday again, the old due date and bag back; never to trying | Approved with the plan |
| Milestones in Parenting (2026-10-25) | Record as R10, analyse now, decide when built | The user: "we need to be very specific with milestones as an individual section page screen ... right now its hidden also the naming is also not correct like a checklist ... unify milestone thing and display it as an individial tht parents can easily access and we keep UI UX considring the human psychology tht its a milestone!!" Questions answered at build time |

## Switching profiles (analysis 2026-10-25; DECIDED the same day, the user: "i guess ttht is the optimal approach so do tht")
Prototype v1 2026-10-25: https://claude.ai/artifact/FihDtL3HmxuHvzYVDQ8iB4 (switcher chip on every home, Add a pregnancy, three celebration pages). The user (2026-10-25): not in the hero, "due to over clutterning"; asked for the four real homes to judge it. Placement comparison: https://claude.ai/artifact/Ed9MnG58VTuzdd3VifyKwU (A chip in the hero, B name in the header centre, C top of the sheet, D avatar badge with the list in You; recommended B). DECIDED 2026-10-25: B, the name in the header centre, the user: "option B name in header, but also make sure to unify the header as in parenting its a bit missing". One header on every home: avatar + Talk left, "Name ▾" over the date centre, Messages + Calendar right (artifact v2 shows it beside today's). F1 (the header and the switch) BUILT 2026-10-25; the rest is the F table below. Calendar slots DECIDED 2026-10-25 (the user: "I like the screens now ... you can implement them", taking both recommendations): Parenting's Calendar opens the vaccination schedule until a child calendar exists (that calendar is OWED, a follow-up); the Learning space keeps Saved on the right and shows no Calendar until it has one. Next: the build plan, starting with R1. Found on the way: the Learning space field is hue 258 (violet), against the no-lavender rule.
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
| B11 | **Found 2026-10-25 building F3.** A child's records are not READ per child. Parenting stores keep every child's rows in one list, and their getters do not ask whose a row is, so with twins or two children both children's rows show on each child's page. Uploads are right: the child ledger records each row's child when it is written (`ChildLogLedger.childOf`). Vaccines are worse: `VaxStore` keeps one `done` set keyed by visit, not by child, so one child's 6-week dose reads as done for the other. The other terminal's tools pass (sync step 15, 2026-10-25) is making the care logs read by child (`ChildLogLedger.belongsTo`: feeds, sleep and the other care logs). Left for B11: growth, milestones, health, documents and vaccines | Reads ask `belongsTo` and listen to the child switch; vaccines keep `done` per child. Sync work (STILL-OPEN-BACKEND), written only on the user's word, after the tools pass lands | LIVE c70a791 (sync step 16; growth, documents, health, milestones, vaccines and the emergency card per child; every child pulled; each child's dose alarms) | `child_scoped_store.dart` (`PerChild`, `pullEvery`) · `test/pp_child_records_test.dart` |

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
| M42 | F2: the move (stage today, birth record sealed, new record, due date and source, dated story entry, messages from today, letters closed until the next birth) | LIVE 2290cce |
| M43 | F2: the undo (parenting at the birthday, old due date and bag back, keys forgotten; derived on a phone without the key; a TTC-confirmed pregnancy is TTC's) | LIVE 2290cce |
| M44 | F2: offered only to her in Parenting or the learning space with none going; dates refused; every way in opens the one screen | LIVE 2290cce (M40 holds the callers) |
| M41 | Every home's avatar opens You, never the stage menu (source scan of `V3HeroChrome` / `V3PregHero` callers; parenting's `onProfile`) | LIVE 04847a5 (B10) |

### F · Family profiles (decided 2026-10-25; see "Switching profiles" above)
What the code can and cannot say today (read 2026-10-25): a pregnant mother with an older child is supported (the
pregnancy You adds one, and the parenting home opens over the pregnancy home with no stage change). But after a birth
the due date is kept and nothing marks that pregnancy as over, so the app cannot tell a second pregnancy from the
first one while the stage is parenting. Anything that needs both at once waits on R1.

| Id | Task | Status | Where |
|---|---|---|---|
| F1 | One header on every home: avatar + Talk left, the family switch ("Name ▾" over the date, the date alone with one profile) centre, Messages + Calendar right. Parenting gains Messages and Calendar (vaccines until a child calendar exists) and Saved moves to You; the learning space gains the date row, Talk and the switch, keeps Saved, no Calendar. The child switch under the parenting age is folded into the header | LIVE 1dd3b3e | `lib/screens/v2/pv_family_switch.dart`, the four heroes · `test/family_switch_test.dart` |
| F2 | "Add a pregnancy" from Parenting, so a pregnancy sits beside the children. BUILT 2026-10-25: `startPregnancyFromFamily` (new record first, which seals the birth pregnancy's bag and birth plan; then the due date; the stage to pregnancy today; a dated story entry) and `undoPregnancyFromFamily` (back to the stage she came from, dated as it was, the old due date and bag back). One page, four dating ways plus "Not sure yet" (about 4 weeks), a refusal for a date before her youngest's birthday, the calm page, then the pregnancy home; Undo on the notice. Ways in: the family sheet (under Add a child; the sheet opens from "Name ▾", so with one child it is You), Parenting You "Expecting again?", the drawer's "Yes, I am pregnant" (was "coming soon"). Hers only (`FatherPreview`), and only while no pregnancy is going. "Not pregnant after all?" on an added pregnancy goes back to the child. Closed on the way: the Dear Baby letters read as opened during the new pregnancy (a birth before the current pregnancy no longer counts). Not done: trying again from Parenting; his phone (R2); open on the last profile (F6) | LIVE 2290cce | `lib/screens/v2/pv_add_pregnancy.dart`, `stage_moves.dart` · `test/add_pregnancy_test.dart` |
| F3 | Messages from every profile. Parenting messages spoke only in the parenting stage and only for the active child (switching child dropped the other's waiting reminders). Now every real child has its own, in any stage, never on the partner's side; with two or more each title names the child, and the pronouns are that child's. A tapped message opens its own child, over whatever home is the root. Settings on Pregnancy and TTC gains "Your children's messages" while there is a child. Pregnancy messages were already right (switching never changes the stage); the first version of this row said otherwise. Vaccine reminders reach every child since B11 (`VaxStore.isDoneFor`) | LIVE 3b5940e | `pp_messages_store.dart`, `pp_messages_screen.dart`, `ppFillChildFor` · `test/pp_messages_family_test.dart` |
| F4 | The celebration pages, calm (painting, name, one line, what changes and what stays, one ink button). Positive test: keeps its own "A beautiful new chapter begins" page (the user, 2026-10-25). Birth: `openBirthCelebration` after all three "Baby has arrived" paths (You, the arrival card, the pregnancy message), phase 1's painting. Turning six: see F5, phase 20's painting. Dedicated paintings still owed | LIVE adae4d5 | `lib/screens/v2/pv_celebration.dart` · `test/celebrations_test.dart` |
| F5 | Turning 6. BUILT 2026-10-25 (the user: ask the parent, keep prompting without irritating, start at the real age): from the sixth birthday a card on that child's parenting home asks; "Not now" rests it 7, then 14, then 30 days; the sixth-birthday message says the space is ready; "Take a look" opens the celebration, the grown-up gate, then the learning space; the family switch keeps the child on Parenting ("learning space ready") until a grown-up says yes. The space reads her age from her date of birth, so a yes at seven opens seven's content. LEFT: `SkChildStore` holds one child, so a second child of 6+ shares the first one's space, and the gate pre-fills the first 6+ child | PART LIVE adae4d5 (one space per child owed) | `lib/screens/skilling/sk_turning_six.dart` · `test/celebrations_test.dart` |
| F6 | Open on the last profile used, and a tapped reminder opens its own profile. Today launch opens the stage's home | OWED | `splash_screen.dart` `_homeFor` |
| F7 | A child calendar (vaccines, check-ups, appointments) behind Parenting's Calendar button | OWED | — |
| F8 | Ask Veda answers for the open profile (a service-repo change: ask for access first) | OWED | `ask_veda_service.dart` + the service |

### R · Recorded, not built (STILL-OPEN §101)
| Id | Gap | Status |
|---|---|---|
| R1 | Real moves: parent pregnant again (F2 BUILT 2026-10-25), parent trying again, parenting → skilling; per-pregnancy records (bump photos, scans, bag, birth plan, garbh are single records, so a pregnancy after a loss shows the lost pregnancy's bump photos). **Per-pregnancy records BUILT 2026-10-25 (sync step 18, 0114):** one `pregnancies` row each; dated records belong to the pregnancy whose window holds their date; the bag, birth plan, scans ticked and day-keyed moods are sealed into the old pregnancy's archive when the next begins; "Kept for you" in the family sheet and in You, view only, with Delete (90-day soft delete). The moves themselves (pregnant again from Parenting) are F2 | PART LIVE 656bbb3 (records; 0114 run 2026-10-25); F2 next |
| R2 | The partner's phone never sees her stage change or her loss (`fetchMyProfile` reads his own row) | RECORDED · BEFORE-LAUNCH |
| R3 | After a loss, still in pregnancy: Learn, Tools, More and the Ask Veda context speak in weeks (Ask Veda part is a service-repo change) | RECORDED |
| R4 | Her own reminders are not paused after a loss | LIVE 00a6ae7: `recordLoss` / `undoLoss` (`stage_moves.dart`) pause her pregnancy-only reminders (hospital bag, evening check-in) and bring back exactly those on the undo; medicines and her own stay on; the loss page says so · `test/loss_and_post_term_test.dart` |
| R5 | `FamilyProfileStore` stage drifts (nothing reads it) | RECORDED |
| R6 | "Replay onboarding" rewrites the stage and stores (developer only) | RECORDED |
| R7 | No prompt past 42 weeks | LIVE 00a6ae7: from 42 weeks the arrival card says how far past the date she is, to tell us if the baby is here, to call her doctor or hospital today if she is still pregnant, and offers "My due date changed"; "Not yet" rests a day, not three; his side speaks of her · `test/loss_and_post_term_test.dart` |
| R8 | Pregnancy door from TTC shows the week-20 placeholder | RECORDED (user's call later) |
| R9 | Celebration pages: birth → parenting, parenting → skilling (Mobbin and prototype first) | LIVE adae4d5 as F4 and F5 |
| R10 | **Milestones: one place to find and celebrate (the user, 2026-10-25).** Hidden: no entry on Home or the tabs; reached only via Tools → Growing and learning, Brain activities, the Development door's "On track" tab (about 3 taps) or search. Named like a checklist: "This month's checklist", "On track", "A gentle check-in", "Tap the circle", "A box you have not ticked". Split: five screens (Milestones, the monthly checklist, the check-in on `DevStore`, the Development Map with its own hard-coded skills and a "you are here" stuck on band 1, the doctor-visit page) over four unjoined lists (`kMilestones`, `DevArea` skills, `AgePhase.milestones`, the Map's), plus journal "Milestones" and "A first" memories apart. Thin record: date and note only, no photo, no link to the journal. Direction: one Milestones place per child, one tap from the parenting home; one list behind it (DV2); saving one is a moment (the calm F4 style, date, optional photo and note, one journal memory with it); "might appear soon", never overdue; the checklist words renamed; a photo column on `pp_milestone_observations`; Mobbin and a prototype first. Keep: no score (a Seen count per area allowed), D3 doctor visit, DV1 Play today first (door data does not set the tab order, so "On track" opens first: a small bug). Ask at build: where the one-tap entry lives, whether "A first" becomes the milestone save, the name (Milestones / Firsts / {name}'s firsts) | RECORDED · STILL-OPEN §101.10 |

## Mobbin pass (2026-10-24)
| App · screen | What it shows | What we take |
|---|---|---|
| [Apple Health · Set Up Pregnancy](https://mobbin.com/screens/fed0b0c8-baa1-41ef-8683-fb54cd0c9570), [Add a Current Pregnancy](https://mobbin.com/flows/d0b0ae08-53d2-418e-9439-c7ace1f7dc31) | Intro sheet: picture, one line, Begin. Dating by period, due date, weeks or embryo transfer; "Log a Past Pregnancy" | The guard's shape: picture, two lines, one main button. Each pregnancy is its own record (R1) |
| [Oura · Women's Health](https://mobbin.com/screens/a9ff1b84-a364-47b0-aa8f-101d28a0dce4) | "Pregnancies · 1 logged"; a quiet "My pregnancy ended" | A loss is a quiet text action; past pregnancies are kept, never erased |
| [WHOOP · "Have you delivered?"](https://mobbin.com/flows/de10510d-1531-4905-8d3d-d89c5292e009) | Arrival card at week 40; mode switch "will reset the data" | Same arrival pattern as ours (M39). We decline the reset: nothing is wiped |
| [Clue · mode picker](https://mobbin.com/screens/ff343537-91bf-4235-a8ca-e667ee69f8bf), [Flo · switch confirm](https://mobbin.com/screens/0313c72a-488f-4267-ab78-40616abab989) | "You can change this later"; a confirm saying what changes | For R1: say what changes before it changes |
