# Trying to Conceive: relevance gap analysis

**Written 2026-10-27.** Read-only audit; no code was changed. The question for every TTC screen: **does it follow where she is (her cycle phase, or her clinic's round step, and whether she recently had a loss)? Does it lead with one thing to do when one fits? Does it explain first when the subject is complicated?**

How it was done: read-only helpers went through the code, and I checked the key claims by hand at the cited line. Those are marked **(checked)**. Nothing was walked on a device. GLOBAL-CHANGES #13 also says the TTC phase tags were never walked on one. **NEW** means not recorded before; **REC** means already recorded somewhere.

Out of scope: **the tools themselves** (Terminal B reviews them). A tool problem gets one line here. This terminal owns the **order** of the Tools tab; Terminal B owns **which rows** it lists.

Siblings: `PREGNANCY-GAP.md`, `PARENTING-GAP.md`.

---

## 0. Decisions already made (2026-10-26)

| Question | Decision |
|---|---|
| Information door vs action door | **Confirmed.** An information door teaches first, in simple terms: what it is, how it happens, why it works. A video can lead each rail. Only then does it go into detail. Action doors open on the activity itself. **The IVF door is the worked example.** Many couples don't know what IVF or IUI stand for, so the door opens on a plain explainer (a video slot plus a simple read), not on the step-by-step journey. |
| After a loss, does the "trying a while" count restart? | **No.** The rule **already exists in code**: `lib/ttc/ttc_fertility_help_rules.dart:420-440` (`firedRules`). Its triggers include 12 months under 35, 6 months at 35 or older, 40 or older, two miscarriages and a known condition, and the count does not restart after a loss (confirmed by Terminal B 2026-10-27; matches ACOG/ASRM Committee Opinion 781, ASRM 2023 and ESHRE). That file is the source of truth, so don't restate the rule elsewhere. Terminal B owns its open tool gaps: losses are asked rather than worked out from her record, the "under 36" label, and checking that the trying-again path doesn't reset the start date. |

---

## 1. How the app decides where she is

| Signal | Source | Who reads it |
|---|---|---|
| Who owns her timing | `ttcTimingOwnershipFromEvidence` (`ttc_care_pathway.dart:282-293`). A clinic owns it only when clinic dates are entered | Hero, daily insights (`ttc_daily_insights.dart:215`), window tool (`ttc_window_screen.dart:373`), messages (`ttc_messages_store.dart:555,588,682`) |
| Cycle phase | `ttcHomePhaseOn` (`ttc_home_situation.dart:114`); returns `any` on a clinic cycle | Home (`ttc_home_v3.dart:407`), door moment (`ttc_phase_rank.dart:60`), Mind today, partner, yoga |
| Clinic round step | `ttcHomeRoundPhaseOn` (`ttc_home_situation.dart:229-245`); wins over phase | Door moment (`ttc_phase_rank.dart:58`), home insight and reads, Ask Veda (`ttc_askveda_screen.dart:158`) |
| After a loss | `lossRecentlyClosed` / `followsLoss`, `CycleStore.currentPeriodStarts` (`cycle_store.dart:174`) | Home door order (`ttc_home_situation.dart:349,376`), the home's "why" line, Ask Veda, messages (`ttc_messages_store.dart:440`). **Nothing else.** |
| Door order on home | `ttcHomeDoorOrderNow` (`ttc_home_situation.dart:366-378`) | Home only |

### Copies that disagree
1. **`TtcChapter`, a second "phase".** It works out a phase from a raw ovulation estimate even when a clinic runs the cycle, on purpose (`ttc_chapter.dart:582-587`, `:638-680`). It drives the home accent, the Sanskar block (`ttc_home_v3.dart:767`) and **Ask Veda's suggested questions** (`ttc_askveda_screen.dart:334`, **checked**). So in the middle of IVF she can be offered "How often should we try during the fertile window?" (`ttc_chapter_data.dart:382-388`). NEW
2. **`ttcIsNewPeriodDayOne`** counts every period she has ever logged (`ttc_home_situation.dart:93-98`, **checked**; live at `ttc_home_v3.dart:4163`). The day logic (`ttc_day_context.dart:344-347`) and messages only count periods since the loss. So her first period after a loss shows a "YOUR PERIOD CAME" card on home, while the message is correctly held back. NEW
3. **`ttcIvfRoundLeads`** reads the round store directly (`ttc_treatment_round_screens.dart:2395`), not the round step. A *planned* round moves the IVF tabs and nothing else. NEW, minor
4. **Learn** uses a fixed order of topics (`ttc_learn_screen.dart:332-344`), not the home's door order. NEW
5. **Store:** `fitsNow` returns null for TTC on purpose (`pv_catalog_store.dart:89-102`, `:130-147`). REC
6. **After a loss, "trying a while"** counts from the old `journeyStart` (`stage_moves.dart:143-158`, `ttc_store.dart:91-96`). That is correct per `ttc_fertility_help_rules.dart`. *Check during the build:* does the home's "Time for a check" card (`ttcTryingLongReached`, `ttc_home_v3.dart:571`) read `firedRules`, or only months? If only months, it should read the engine.

PERSONALIZATION.md layers: ordering is wired (`ttcAgeOrder`, `ttc_phase_rank`). There is no TTC profile vocabulary yet (PERSONALIZATION §9).

---

## 2. Home (`ttc_home_v3.dart`), top to bottom

| # | Block | What picks it | Follows her moment? |
|---|---|---|---|
| 1 | Header: date, week strip, window line, Period / Symptoms / Sex / Test (`:1706`, `:1790-1874`) | Hero state; Sex and Test give way to a blood-test line in an IVF-type round (`:1822`, `:1871`) | Yes, and safe on a clinic cycle |
| 2 | Round notice (`:502`) | `ttcRoundNoticeNow` | Round |
| 3 | Visit today (`:513`) | A clinic visit on that day | Round |
| 4 | Daily insights (`:543`; list `~:4074-4330`) | Intro film, ready plan, period came, blood test, should I test, chance, cycle day, logs, companion, **report**, next step, insight, then **myth, nutrition, movement, pick** | Partly. The last four rotate by date |
| 5 | Started trying sooner? (`:558`) | Ready plan | Plan |
| 6 | Time for a check (`:571`) | `ttcTryingLongReached` | Months trying (no loss trigger) |
| 7 | 101 card (`:592`) | First course steps not yet opened | No |
| 8 | Doors (`:607-653`) | `ttcHomeDoorOrderNow` | Yes |
| 9 | Sanskar block (`:767`) | **Chapter** | Wrong source on a clinic cycle |
| 10 | Products (`:845-882`) | `forYou`, the same for everyone trying | No |
| 11 | Reads (`:953`) | Phase or round | Yes |
| 12 | Experts, the way to Pregnancy, disclaimer | Fixed | No |

### First view at real moments

| Moment | Hero | First rail card | One thing to do? | What's off |
|---|---|---|---|---|
| Just started, no data | "Start here" | Intro film, a "coming soon" placeholder (`ttc_intro_flow.dart:816-822`) | **No.** Start here, intro film, next step and the 101 card all compete | Report card with no data; product rail |
| Fertile window | Fertile days today | Chance card (kept by decision, REC STILL-OPEN §83.1a) | Yes: the Sex quick button | Myth, nutrition and pick cards rotate in |
| Two-week wait | Period may start in N days | Should I test? (`:4207`) | Yes | Products |
| Clinic round step | Round copy, blood-test date | Blood test or round insight | Mostly | **Report card** (the message is held back on clinic cycles, `ttc_messages_store.dart:652-655`, but the card isn't); Sanskar and Ask Veda follow the chapter; products may include LH strips (`pv_product_extras.dart:46`) |
| After a loss | Depends on the restart | Nothing about the loss; **"period came" card on her first period** | **No** | Test kits and strips in products; "Month after month" reads lead on period days (`ttc_phase_reads.dart:24-31`) |

Good: no home card shows a prediction on a clinic cycle. The chance card is gated (`ttc_daily_insights.dart:236`).

---

## 3. The other screens

| Screen | Finding |
|---|---|
| Tab bar | Today · Learn · Products · Tools · More (`ttc_tab_host.dart:243-262`). Fixed, which is correct |
| **Learn** | Fixed order: topics, your reading, start here, videos, shelves, stories, courses, questions (`ttc_learn_screen.dart:855-864`). **Nothing follows her phase or round**, and the topic order differs from the home. NEW |
| **Products** | `fitsNow` is null for TTC, and `forYou` only removes partner items (`pv_catalog_store.dart:146-147`). The same at every moment. **"Shop by need" always puts folic acid, ovulation kits and a pregnancy test first** (`pv_store_screen.dart:672-703`), including during an IVF-type round and after a loss. The home already hides its own Test row in such a round, because a home test can mislead (`ttc_home_situation.dart:254-258`). The Store doesn't follow that rule. NEW |
| **Tools tab order** (`ttc_tools_screen.dart:1302-1309`) | Fixed `ttcToolGroups` order. **Cycle, Ovulation tests and Fertile window are rows 1-3 even when a clinic owns the cycle, and after a loss.** "Treatment cycle" is the last row of the third group (`:556`); during a round it only gets a small note (`:1529`). NEW |
| **More** | Consults, courses, groups, reads and benefits come in a fixed order, free course first. The **Yoga row** "Gentle movement that follows your cycle" (`ttc_more_tab.dart:430-443`) does read `ttcHomePhaseOn` (`yoga_home_screen.dart:359-388`). During a round the phase is `any`, so she gets a general practice plus a "Fertility yoga" rail; the round step and the after-loss state are ignored. NEW |
| **Search** (`ttc_stage_search.dart:88-196`) | Text score 2/1/0, max 4 per kind. No phase, round or loss. Tools and Products search are text only too. NEW |
| **Ask Veda** | Sends ownership, round step, cycle day and previous loss (`ttc_askveda_screen.dart:151-173`), which is good. **Suggestions come from the chapter** (section 1). TTC-AUDIT A-53 already noted they are all preparation-flavoured (REC) |
| **Treatment-round screens** | Ways in: the IVF door panel, the TTC calendar, `ttc_round_home_card`, `ttc_today_screen`, and Tools > Treatment cycle. The round screen (`ttc_treatment_screen.dart:1586-1797`) leads with `_TodayCard` and shows no cycle predictions (good). "Tell result" is the main button only when a result is possible (`:1640-1649`). **On injection or trigger days there is no single action for the day**; medication is an info row lower down (`:1663-1669`). The title never changes (`:1591`). **The door panel's main button is always "See plan"; on test day "Tell result" is only the second button**, and "Update dates" opens the same screen as the main button (`ttc_treatment_round_screens.dart:2437-2447`). NEW |
| **Notifications** (`ttc_messages_store.dart`) | Window opens 08:00 (own cycle only, `:555-576`); period came 19:00 (not on clinic cycles, `:588-618`); late 09:00 the day after it's due, needs a reliable history (`:628-647`); cycle report 09:00 (`:652-673`); trying long 10:00 at 6 or 12 months (`:679-700`); treatment messages (`:703`). **After a loss, window messages restart straight away.** No two-week-wait or round-step nudges, no quiet hours (REC GLOBAL #12) |

---

## 4. The doors

Tags exist (`TtcFocusSection.phases` / `.steps`, read by `ttc_phase_rank.dart`). The door opens on the tab for her moment, her sections lead, and inside a section the reads for her phase (`kTtcPhaseReadIds`) lead. Untagged **on purpose**: PCOS, His side, Getting ready, Not yet and After loss. Their subject doesn't change with the cycle (GLOBAL-CHANGES #13), and that reason holds.

| Door | Kind (recommended) | Opens on today | Tags: have / missing | First view at the five moments | Global-change gaps | Fix in one line |
|---|---|---|---|---|---|---|
| Conceiving | ACTION | When and how to try > "Your best days this month" (`ttc_focus_conceiving.dart:182-187`) | Have: tabs (`:132`, `:139`); sections `:177,282,491,519,557`. **Missing:** period-day tab opening; round steps | No data → window tool. Window → window tool. Two-week wait → Waiting, but articles (`:491`) come before the test tool (`:519`). **Clinic round → "Your own dates, from the period you logged"** (wrong). Loss → as by phase | #14 holds (product tile at the end, `:268`) | Clinic-aware card copy; test tool first in Waiting |
| **IVF / IUI** | **INFORMATION: teach first** (user's example) | Step by step journey plus round panel (`ttc_focus_ivf.dart:135-141`) | Have: sections by round step (`:674,776,877`) | Always Step by step; during a round the round's steps lead | #5: `heroVideoSlot` never drawn (REC) | **Open on a plain "What IVF and IUI are, how and why" explainer: a video slot plus a simple read. Then the journey** |
| Mind and body | ACTION | Today's practice (`ttc_focus_mind_body.dart:127-134`) | Have: period (`:213`, `:270`). **Missing:** two-week wait | Today's practice at every moment | **#10:** "Start a daily practice" opens guides (`:438-463`); "Sleep better" leads with guides (`:627-636`). The test only checks for "?" (`test/action_doors_first_test.dart:34-42`) | Put a practice first under every action heading; the test checks the first tile's type |
| Body and cycle | **INFORMATION** ("is this normal?") | Tracker tools (`ttc_focus_body_cycle.dart:83-107`) | Have: period (`:141`), period/window (`:168`) | Period day → bleeding reads lead; otherwise tools | — | Open on a plain "how your cycle works" explainer (also covers demand #1, the luteal phase) |
| PCOS (untagged on purpose) | INFORMATION | Understand > video (sinks while unmade) > article (`ttc_focus_pcos.dart:159-186`) | — | The same at every moment | — | Fine. Check the possible lavender hero (hue 288, `ttc_brackets.dart`) on a device |
| His side (on purpose) | INFORMATION | Understand > article (`ttc_focus_his_side.dart:178-202`) | — | The same | — | Fine |
| **Getting ready** (on purpose) | **ACTION** | Food > article (`ttc_focus_getting_ready.dart:164-184`); **the checklist is the last tab** (`:596-617`) | — | The same | Not action-first, unlike Pregnancy's Getting Ready | Open on the checklist / ready plan |
| **Not yet** (on purpose) | **ACTION** | Articles first (`ttc_focus_not_yet.dart:95-110`); the "Should we see a doctor now?" check is section 2 (`:121`) | — | The same | — | Lead with the doctor check (the tool and its rules are Terminal B's) |
| After loss (on purpose) | INFORMATION | Your body > article (`ttc_focus_after_loss.dart:149-195`) | — | The same | — | Fine |

### Global changes across the doors
- **#2 article links to a service:** `pv_read_offer.dart` never checks whether a clinic runs the cycle, so a read can pitch a fertility-doctor consult in the middle of a round. NEW. The two-week wait now maps to the psychologist (`:81`, REC)
- **#5 intro video:** the "coming soon" chip is drawn (`ttc_door_screen.dart:2035`). `heroVideoSlot` is copied (`:563`) and commented out in every door (REC)
- **#7:** null for TTC on purpose (REC)
- **#10:** Mind and body's headings (above)
- **#14:** holds

### Shell faults
- `ttcDoorVideosFirst` rebuilds sections without their tags (`ttc_door_screen.dart:714-726`). It runs after ranking, so nothing breaks today, but it is the same kind of bug #13 fixed. Polish.
- No silent taps found in the door code. Cut-off names and lavender tab tints need a device walk. A label-fit test already exists (`ttc_doors_explicit_names_test.dart:160`).

**Ownership note (agreed with Terminal B 2026-10-27):** the report card on clinic cycles (fault 14) and the "Your best days" copy (`ttc_focus_conceiving.dart:185`, fault 3) are **this terminal's**: they are about where she is, not tool internals. The IVF fertile-window item (STILL-OPEN:2152) was closed on 2026-07-27 with a guard in the engine; Terminal B will check the tool in its audit.

### What women ask that we don't cover well (`research/questions/ranked_ttc.csv`, top 50)
The fix is guidance in each door's own voice, never a Q&A list.

| Rank | Worry | Today | Door that should own it |
|---|---|---|---|
| **1** | When is the luteal phase | **No section** | Body and cycle |
| 10, 23, 49 | Cervical mucus as a sign of ovulation | Only "Is my discharge normal?" | Conceiving > When and how |
| 13, 18, 29, 36 | Basal body temperature | One carousel card (`ttc_focus_conceiving.dart:222`) | Body and cycle |
| 17, 19, 28, 40 | Ovulation tests: positive if pregnant? how many days? | Only "Do ovulation kits help?" | Conceiving |
| 15, 45 | Low AMH | A glossary line (`ttc_focus_ivf.dart:377-379`) | IVF > Understand |
| 35, 41, 48, 51 | IUI / IVF success, failure, timing | Partial | IVF |
| 39, 46 | Twins, IVF twins | **None** | IVF |
| 4 | Conceiving after 35 | Hidden in IVF > Age | Conceiving / Getting ready |
| 33 | Sperm count and age | Partial | His side |

Already covered: miscarriage and trying again (2, 7, 9), folic acid (3), PCOS (5, 37), implantation bleeding (8, 11), when to see a doctor (26).

---

## 5. Faults by severity

**Broken:** none found.

**Wrong**
1. ~~Ask Veda suggests fertile-window questions while a clinic runs the cycle~~ **DONE (Batch 1, 2026-10-27):** `ttcScreenChapter` (`ttc_home_situation.dart`) follows the round step; held day by day in `ttc_date_consistency_test.dart`. Was: (`ttc_askveda_screen.dart:334`). *Fix:* when `ownership != parentveda`, pick suggestions by round step.
2. ~~A "Your period came" card shows on her first period after a loss~~ **DONE (Batch 1, 2026-10-27):** counts `currentPeriodStarts`. Was: (`ttc_home_situation.dart:93`). *Fix:* count from `currentPeriodStarts`.
3. ~~Conceiving opens a clinic-cycle user on "Your own dates"~~ **DONE (Batch 3, 2026-10-27):** the card line is true on both kinds of cycle ("or your clinic's dates when a clinic is guiding this cycle"). Was: (`ttc_focus_conceiving.dart:185`). *Fix:* clinic-aware copy, or tag a clinic-safe tab with round steps.
4. ~~The Store puts kits and a test first in a round and after a loss.~~ **DONE (Batch 4, 2eb7a77):** `pvTtcNeedsInOrder`: with `ttcHomeHidesQuickRow` or `lossRecentlyClosed`, "Finding your fertile days" and "Taking a pregnancy test" go last. The home's product rail reads the same rule (23). Was: (`pv_store_screen.dart:672-703`).
5. ~~The IVF door opens on the journey, not on what IVF and IUI are.~~ **DONE (Batch 3, 2026-10-27):** outside a round it opens on Understand treatment, led by the new read "IVF and IUI, from the very beginning" (`ttc_read_ivf_iui_beginning`, about 1,560 words: what the letters mean, the natural journey, where it gets stuck, how each helps, how a clinic chooses, the words, what they can promise, questions to ask). During a round Step by step still leads (the 2026-10-22 decision). Video for it still owed. Was: *Fix:* an explainer first (decision, section 0).

**Weak**
6. **DONE (Batch 4, 2eb7a77):** the card reads the doctor check (`ttcHomeCheckNow` / `ttcHomeCheckFrom`, `ttc_home_situation.dart`): it shows when the engine says "may see someone" or "don't wait", with the engine's headline and first reason, so two losses, over 40 or varying cycles bring it up, not months alone. Same gates: not pregnant, not in care, not on a clinic cycle. The months still count, from T1's worked-out start (00b3cc5). Was **MOVED TO BATCH 4 (decided in Batch 1):** confirmed it counts months only (`ttcTryingLongReached`, `ttc_messages_store.dart:526`; 6 or 12 by age). Its words are about months, and the losses input is changing in the tools terminal (losses to be worked out, not asked), so it is wired after that lands, with a reason-based line. Was: The home's "Time for a check" card may count months only (`ttcTryingLongReached`). *Fix:* if so, read `firedRules` (`ttc_fertility_help_rules.dart:420`). The rules engine itself and the "losses asked rather than worked out" gap are Terminal B's.
7. ~~Getting ready and Not yet bury their tool.~~ **DONE (Batch 3, 2026-10-27):** Getting ready's checklist is the first tab; Not yet opens on "Should we see a doctor now?". Was: *Fix:* the checklist / doctor check as the first card.
8. ~~Body and cycle opens on trackers.~~ **DONE (Batch 3, 2026-10-27):** its Your cycle tab opens on the new read "Reading your cycle, phase by phase" (`ttc_read_cycle_phase_by_phase`, about 1,330 words), which also answers demand #1 (the luteal phase), cervical mucus, morning temperature and what an ovulation test can and cannot tell you. Was: *Fix:* a "how your cycle works" explainer first.
9. ~~Mind and body's action headings open articles.~~ **DONE (Batch 3, 2026-10-27):** "Start a daily practice" opens Today's practice; "Sleep better while trying" opens the calming breath. Other headings that open guidance ("Handle family questions and news") are guidance by nature and stay. Was: *Fix:* a practice first; tighten the test.
10. ~~The Tools tab leads with the window on a clinic cycle.~~ **DONE (Batch 4, 2eb7a77):** `ttcToolsInOrder`: a group marked `leadsOnClinicCycle` (Care and medicines) leads while a clinic owns the cycle, with Treatment cycle, Medication and Appointments first (`kTtcClinicCycleLeadIds`). Cleared with Terminal B first. Was: (`ttc_tools_screen.dart:1302`).
11. ~~Sanskar follows the chapter~~ **DONE (Batch 1, 2026-10-27):** the home's chapter is `ttcScreenChapter(today.chapter)`. Was: (`ttc_home_v3.dart:767`). *Fix:* use the round step or phase; stay general when `any`.
12. ~~Day one shows four "start" prompts.~~ **DONE (Batch 4, 2eb7a77):** the checklist's "Your next step" waits for her first logged period, and the 101 card waits while the intro film card shows. Both stay where they live (Tools, Learn).
13. ~~Learn ignores her moment.~~ **DONE (Batch 4, 2eb7a77):** `ttcLearnTopics` orders her topics with `ttcHomeDoorOrderNow`; his side unchanged.
14. ~~The report card shows on clinic cycles.~~ **DONE (Batch 4, 2eb7a77):** shown only on her own cycle; the report stays in the Cycle Companion.
15. ~~A read can pitch a fertility doctor mid-round.~~ **DONE (Batch 4, 2eb7a77):** `pvReadOfferFor(clinicOwnsCycle:)` drops clinician consults (fertility, gynaecologist, andrologist) for TTC reads while a clinic owns the cycle; courses, psychologist and nutrition stay.
16. ~~On test day the main button is "See plan".~~ **DONE (Batch 4, 2eb7a77):** "Tell result" is the main button on `testDay`, "See the whole plan" second.
17. ~~Yoga ignores a round and a loss.~~ **DONE (Batch 4, 2eb7a77):** during a running round or after a recent loss: the waiting days' gentle practice, a line saying why, no Fertility yoga rail.
18. ~~No search ranks by phase.~~ **DONE (Batch 4, 2eb7a77):** `ttcStageSearch`: on a tie, hits come in the order of their doors on her home (`ttcHomeDoorOrderNow`), and the sort is now stable.
19. ~~Window messages restart straight after a loss.~~ **ALREADY DONE (found in Batch 1):** `lastPeriodStart` is null after a loss until her first new period (`cycle_store.dart:161-166`, 2026-10-24), so the window and its message stay quiet. The helper misread it. *Fix:* hold them until the first period after the loss.
20. **PART DONE (Batch 3, 2026-10-27):** the cycle read covers ranks 1, 10/23/49, 13/18/29/36 and 17/19/28/40. Still owed (Batch 6): low AMH, IVF twins, IUI or IVF failure, conceiving after 35, sperm and age. Was: The demand gaps in section 4. *Fix:* one section each in the door that owns it.

**Polish**
21. `ttcDoorVideosFirst` drops tags. *Fix:* use `s.withTiles`.
22. `ttcIvfRoundLeads` keeps its own copy of the round. *Fix:* read `ttcHomeRoundPhaseOn`.
23. ~~Home products don't change after a loss or in a round.~~ **DONE (Batch 4, 2eb7a77):** kits and tests go last then (`pvTtcNeedsInOrder`), ordered rather than removed.
24. Possible lavender on the PCOS hero and the hue-268 tab shelves. *Fix:* check on a device.
25. **PART DONE (Batch 4, 2eb7a77):** the duplicate "Update dates" button is gone. The panel title already names today's step; the round screen's own title (`ttc_treatment_screen.dart:1591`) is still fixed. Was: The round panel's "Update dates" duplicates the main button, and the round screen's title never changes.
26. **NEW (found in Batch 4, 2026-10-28):** the Batch 3 read "Reading your cycle, phase by phase" had borrowed "How conception works"'s calendar photo, so All articles drew it twice (`ttc_no_repetition_test` failed on main since 0b5823e). **DONE:** it has its own photo now, an open month planner (Commons, CC0, Giulia Bertelli), in `read_images.dart` under its id, picked by eye.

---

## 6. Order of work
1. **Foundation (this terminal, first):** the chapter gives way to the clinic step (1, 11); the period count after a loss (2); messages after a loss (19); the home check card reads the rules engine (6).
2. **Doors:** IVF teaches first (5); Getting ready, Not yet and Body and cycle open on the right kind (7, 8); Mind and body practices (9); Conceiving made clinic-aware (3).
3. **Other screens:** Store needs during a round or after a loss (4); Tools order on a clinic cycle (10, coordinated with Terminal B: one terminal edits the file at a time); round panel (16); report card (14); Learn order (13).
4. **Content:** the demand gaps (20), each also sent to Ask Veda's ingest.
5. **Notifications:** with GLOBAL-CHANGES #12 Phase 6.

## 7. Decisions still yours
- None blocking. The two decisions answered on 2026-10-26 are recorded in section 0.
