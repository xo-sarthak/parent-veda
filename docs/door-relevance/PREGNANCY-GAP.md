# Pregnancy: relevance gap analysis

**Written 2026-10-27.** This audit only reads the code; no code was changed. It asks one question of every Pregnancy screen: **does it follow her real week? Does it lead with one thing to do when one fits? Does it explain first when the subject is complicated?**

Method: read-only helpers went through the code. The main claims were then checked by hand at the cited line, and those are marked **(checked)**. Nothing was walked on a device. **NEW** means the problem was not recorded anywhere before. **REC** means it is already recorded, and the entry says where.

Out of scope: **tools themselves.** Terminal B is reviewing every Pregnancy and TTC tool. A tool problem gets one line here and is left to them. This file owns the **order** of the Tools tab. Terminal B owns **which rows** it lists.

Siblings: `TTC-GAP.md`, `PARENTING-GAP.md`. Tracker: `docs/GLOBAL-CHANGES.md` (item 16 is the information-door rule below).

---

## 0. Decisions already made (2026-10-26)

| Question | Decision |
|---|---|
| Information doors versus action doors | **Confirmed.** An *information* door is about a complicated subject. It teaches first, in simple terms: what it is, how it happens, why. A video can lead each rail. Only after that does it go into detail. An *action* door opens on the activity itself, never on an article *about* the activity. A door may change kind by week: Labour explains before week 36 and leads with the timer from week 37. |
| No due date | **The due date is required.** Users never see a week-20 stand-in. The stand-in is for developer mode only (the stage chips). The week-20 faults below become guards in case it still happens, not features. |
| Corrected age, Labour's switch week | Chosen and recorded: Labour changes kind at week 37. |

---

## 1. How the app decides her week

| Piece | Where | Rule |
|---|---|---|
| Single source | `PregnancyController` (`lib/services/pregnancy_controller.dart`) | Due date → `currentWeek`, kept between 4 and 40 (`:228-231`). With no due date it uses `_placeholderDueDate`, which is week 20 (`:79`, `:668`). `isDueDateSet` (`:159`) |
| **Her week stops moving after launch** | `final DateTime _now` (`:111`, **checked**), set once in the constructor (`:78`) | `currentWeek`, `daysToDueDate` and `currentDay` never move forward while the app stays in memory. The home works out its week from `DateTime.now()` (`home_v3_screen.dart:349-360`). If she leaves the app open past a week boundary, the home says week N+1 while doors, Learn, tile order and Ask Veda still say week N. **NEW, Broken** |
| Door ranking | `PregBand` + `pregRelevanceOrder` (`lib/data/doors/preg_band.dart`) | With a null week it leaves the order as it is (`:63`), so the stand-in is safe here |

### Who reads it, and whether week 20 is safe there

| Reader | Week used | Safe with week 20? |
|---|---|---|
| Door sections `sectionsFor` | `_knownWeek` (`pv_door_screen.dart:313-315`, `:745-749`) | Yes |
| Door rails | `tilesFor(currentWeek, weekKnown)` (`pv_door_data.dart:793-799`) | Yes |
| Door `lead` hook (Nutrition "Food by trimester", `pv_door_nutrition.dart:329`) | `_leadFor(week)` runs before the weekKnown check (`pv_door_data.dart:794`, `:803`) | **No.** NEW |
| Store `fitsNow` / `_hersFirst` | `pv_catalog_store.dart:89-94` | Yes |
| Store header "For you · Week N" | `clockLabel` (`pv_catalog_store.dart:167`, **checked**) | **No:** shows "Week 20". NEW |
| Go further, NeedScreen, Move pitch | `pv_go_further.dart:314`, `need_screen.dart:76`, `pv_move_today_screen.dart:224` | Yes |
| Move today session | `pv_door_router.dart:487` | **No.** NEW |
| Home rails | the selected day's week (`home_v3_screen.dart:358-360`) | **No.** REC §97.9 fixed the hero line only |
| Home products "Picked for week N" | `home_v3_screen.dart:1278`, `v2_sections.dart:650-655` | **No.** NEW |
| Scans "My scans" timeline | `scan_timeline_screen.dart:180`, `:635` | **No:** puts the anomaly scan next. NEW |
| Learn "Videos for week N" | `preg_learn_screen.dart:575-579` | **No.** NEW |
| Ask Veda | sends `week: p.currentWeek` (`ask_veda_screen.dart:206`); "Finding what fits week N" (`:738`) | **No.** NEW |
| You screen hero, Due date row | `pv_you_content.dart:1219`, `:1243-1257` | **No.** NEW |
| Messages | `preg_messages_store.dart:46`, `:224` | Yes |

### Copies that disagree
- **Home and the rest of the app:** the home works out the week from today's date; everything else uses the frozen `currentWeek`.
- **The Mind door** rebuilds each section for its hide-intimate switch and drops `weeks`, `tilesByWeek` and `forAfterLoss` (`pv_door_mind.dart:205-215`). Mind has no week tags yet, so nothing breaks today. It is the same kind of bug GLOBAL-CHANGES #13 found in TTC. NEW
- **PERSONALIZATION.md layers:** ordering is wired (`pregRelevanceOrder`, `orderByPregPriority` in `tools_hub_screen.dart:402`). The content layer's `personalizedFocus` has **no callers**.

### Every way into Pregnancy, and whether it asks for the date

| Way in | Date required? |
|---|---|
| Onboarding (`onboarding_flow.dart:2098`) | **Yes:** Continue is disabled without a date |
| Add a pregnancy (`stage_moves.dart:183`) | Yes |
| Family switch (`pv_family_switch.dart:126`) | Not a way in: it only lists Pregnancy when she is already pregnant |
| Phone message tap (`preg_messages_screen.dart:100`) | Not a way in |
| TTC "Yes I'm pregnant" (`ttc_transition.dart:327-341`) | Always sets a date. **But** with no logged period it assumes week 4 with source `unknown`, so `dueDateMayBeStale` never asks her to update it. With an **old logged period it does not check the date**: a period logged six months ago gives about week 26. NEW |
| You "Stage · testing" chips (`pv_you_screen.dart:2835-2862`) | **Falls through to `setStage(pregnancy)` with no date** when `addPregnancyOffered()` is false (father view, a record still open, or no stage). Developer chips, but they ship in every build (REC BEFORE-LAUNCH §6). NEW |
| Old `AuthFlowScreen` sign-in (`auth_flow_screen.dart:273`, `:1009`) | It asks for a date, but a sign-in prompt can change her stage. NEW |
| You sheet | **Cannot clear the date**, which already fits the decision. `clearDueDate` is called only when she leaves Pregnancy (`stage_moves.dart:147,296`, `ttc_transition.dart:513`) |

---

## 2. Home (`home_v3_screen.dart`), top to bottom

| # | Card or rail | What picks it | Changes by week? |
|---|---|---|---|
| 0 | Daily tip pop-up | `pregDailyTipFor(week, day)` (`:404`) | Yes |
| 1 | Hero: Week · Day, countdown, arrival card from week 37 | `:466-554` | Yes |
| 2 | My daily insights | `pregInsightsFor` (`preg_daily_insights.dart:211-493`) | Partly. "Log how today feels" always leads (`:256-265`), then the scan window (`:288-306`). The "Is it safe?" card is chosen by day of year, not trimester (`:386-397`) |
| 3 | Explore by topic, 13 tiles | `orderPregnancyTiles` (`preg_tile_order.dart:62-71`) | Up to week 13 it lifts Symptoms, Is it safe? and Scans; from week 32 it lifts Labour. **Never lifts "Your first weeks" early or "Getting ready" late.** NEW |
| 4 | Your week, explained (video) | `v2VideoFor(week)` | Barely: 5 videos cover 37 weeks (REC §98.2) |
| 5 | Garbh Sanskar band | day and trimester | Yes |
| 6 | Medicines, journal | stores | No |
| 7 | Videos for this week | `v3ShelfVideosFor` | Barely |
| 8 | Reads for week N | `dailyArticleReads` (`read_next_data.dart:774-787`, **checked**) | Pulls in articles from other weeks when **fewer than 3** fit her week |
| 9 | Picked for week N | `v2ProductsFor` | Yes, but it treats week 20 as real |
| 10 | Tools for this week | her history first, else `recommendedToolsForWeek` | The title says "this week" even when the row is her own history |
| 11 | Talk to an expert, invite, disclaimer | fixed | No |

### First view at real weeks

| Week | Tiles lead with | One thing to do today | What's off |
|---|---|---|---|
| 6 | Symptoms, Is it safe?, Scans, Complications | "Log how today feels", then "Blood tests, weeks 6-10, add my date" | "Your first weeks" is in row 3 |
| 14 | the table's default order | Logging only (no scan window between weeks 14 and 17) | Nothing to do for this week; the "update your due date" prompt only lives in Tools |
| 24 | default order | Log, then the glucose test window | Fine |
| 34 | Labour first | Log, then the growth scan window | "Getting ready" (hospital bag, what to buy) is the 12th tile |
| 40+ | Labour | Arrival card (good) | The hero says "Week 41" (`:474`) but the rails are capped at 40 (`:360`). NEW |

---

## 3. The other screens

| Screen | Finding |
|---|---|
| Tab bar | Today · Learn · Products · Tools · More (`main_scaffold.dart:226-257`). Fixed, which is correct |
| **Learn** (`preg_learn_screen.dart:413-429`) | Topic order is fixed, not by week (`:157-171`). Pregnancy 101 is a fixed list (`:175-183`). **Door shelves use `sectionsOf`, not `sectionsFor`, so week tags are ignored** (`:136-155`): at week 34 the Scans shelf leads with first-trimester reads. NEW. Courses are not ranked by week (REC GLOBAL #7). The Partner door is missing from Learn and reachable only from More (`preg_more_screen.dart:353`) |
| **Products** (`pv_store_screen.dart:133-259`) | Weeks 6, 14 and 24 work: items for later weeks are held back (`suitsWeek`, `pv_product.dart:425`). **From about week 34 every item "fits"**: almost every sheet item is tagged weeks 32-36 and none has a `weekTo`, so `_hersFirst` changes nothing (`pv_catalog_store.dart:110`) and first-trimester items never drop off. NEW. The header says "Week 20" with no due date (section 1) |
| **Tools tab order** (`tools_hub_screen.dart:163-304`) | Fixed groups (Track, Get ready, Keep, Ask). Only her chosen priorities reorder within a group (`:401-402`). **Her week is never read: at week 8 the kick counter is the first row** (`:170`, **checked**), and the contraction timer and hospital bag come before week 28 (`:218-235`). The after-loss case is handled (`:161`). NEW |
| **More** | "Week by week" opens `currentWeek` (`preg_more_screen.dart:340`), which is capped at 40, so **once she is past her due date it opens week 40**. The home already maps that to the week 41/42 pages (`home_v3_screen.dart:1914-1917`). NEW. Experts, courses and groups are in catalogue order (REC GLOBAL #7) |
| **Week page** (`preg_week_screen.dart`) | Opens on whatever week it is given (`:74`). No "estimate" notice when there is no due date. The comment at `:18-19` says later weeks are locked, but `unlockAllWeeks = true` (`pregnancy_controller.dart:146`) |
| **Calendar hub** (`preg_calendar_hub.dart`) | Fine: opens on today (`:87-89`), says "An estimate" when there is no due date (`:279`), and handles past 40 weeks (`:300-314`) |
| **Search** | No search on the home, by decision (`home_v3_screen.dart:773-782`). Door/Learn search `pvSearch` (`search/pv_search_screen.dart:273-296`), Tools search and Products search (`pv_catalog_store.dart:210-233`) all match **text only**; none ranks by week. NEW |
| **Ask Veda** | Reached from the FAB, Learn's "Ask Veda about…" and door search. It sends week 20 as if it were real |
| **Notifications** (`preg_messages_store.dart:15-21`) | New week at 9am, NT scan at week 11, anomaly scan 18, Tdap 27, movements 28, bag 34, "has baby arrived?" 37. Safe with week 20. **Nothing for weeks 4-10** (first visit, dating scan, bloods), **nothing for the glucose test at 24 or the growth scan.** NEW. No daily nudges, quiet hours or offers (REC GLOBAL #12, Phase 6) |

---

## 4. The doors

**Shell finding that affects every door:** each door opens on **tab 0** unless the caller names a tab (`pv_door_screen.dart:330-335`). So the week tags only reorder things *inside* tabs she has to open herself. Parenting fixed this with `PpDoor.tabOrder` (`docs/pp-door-plans/00-MASTER.md` S1 as built). Pregnancy has nothing like it. NEW

| Door | Kind (recommended) | Opens on (tab → first card) | Week tags: have / missing | First view at 6 · 14 · 24 · 34 · 40+ | Global-change gaps | Fix in one line |
|---|---|---|---|---|---|---|
| Scans | ACTION: her next scan | My scans → timeline (`pv_door_scans.dart:156-163`) | Have: the "Understand a scan" tab only | Right at every week; **wrong with week 20** | — | Pass no week when there is no due date |
| Complications | **INFORMATION** (frightening subject) | Find a condition → search (`pv_door_complications.dart:140-147`) | Have: the "By month" tab | The same search at every week | #14: no expert early on | Open on By month at her trimester, with a calm explainer first |
| Is it safe? | ACTION: look it up | `CanIScreen` | n/a | Same at every week | **#5: no intro chip** | Add `PvDoorIntroChip` to `CanIScreen` |
| Nutrition | ACTION | Today → plate, then "For your week" | Have: `lead` only | Fine | `lead` fires on week 20 | Check weekKnown before `_leadFor` |
| Symptoms | ACTION | Today → check-in | **Missing:** Is this normal / By symptom by trimester (REC #13) | Check-in at every week | — | Tag by trimester |
| **Labour prep** | **INFORMATION before 36, ACTION from 37** | **Contraction timer** (`pv_door_labour.dart:186-188`) | Missing (REC #13) | **Timer at weeks 6, 14 and 24** | — | A `tabOrder` by week: signs and stages until 36, timer from 37 |
| Garbh Sanskar | ACTION | Today → four practices | Have: day and trimester | Fine | — | — |
| Move | ACTION | Move today → session | Have: month by month | Fine | The session uses week 20 | Pass no week when there is no due date |
| Mind | ACTION | Calm down now | None (no week content needed yet) | Same at every week | Latent: the tag-dropping copy | Use a `withTiles` copy, as TTC does |
| Belly and skin | INFORMATION | Skin changes → stretch marks | **Missing** (NEW) | Same at every week | — | Lead with itching late in pregnancy (cholestasis warning sign) |
| Your first weeks | INFORMATION | Just found out → "what to do this week" | Have: after-loss lift | Right early on | The home tile is not lifted before week 13 | Add to `pregTrimesterLeads` |
| **Getting ready** | ACTION | **Name finder** (`pv_door_getting_ready.dart:97-133`) | Have: "The last months", but it is tab 3 (`:283-285`) | **Name finder even at week 34** | — | `tabOrder`: Home and help or What to buy from week 28 |
| Work and money | INFORMATION | Work → working while pregnant | **Missing** (NEW) | Same at every week | — | Tag leave notice and rights by week |
| Partner | ACTION | Week by week → week guide | Missing (REC #13), though the guide itself follows her week | Fine | Not in Learn | Add to Learn's shelves |
| Twins | INFORMATION | Finding out | **Missing** (NEW) | The same at week 30 | — | Lead with care and birth late in pregnancy |
| After a loss | INFORMATION | Your body → first days | n/a | n/a | — | Correct as it is |

### Global changes across the doors
- **#2 every article links to a service:** 132 of 152 reads carry an offer (`pv_read_offer.dart`). The match is by topic, not week (REC).
- **#5 intro video chip:** present on the doors, missing on Is it safe?.
- **#7 store by her week:** LIVE, with the late-pregnancy weakness in section 3.
- **#10 verb cards:** fine on the home's Move card.
- **#14 pitch after the help:** only Nutrition and Move have one. The other doors have only a final "Experts" tab.

### Shell faults
- **S8 silent taps:** "Coming soon" video tiles do nothing when tapped (`pv_door_chrome.dart:368`, `pv_shelf_card.dart:288`, `pv_door_router.dart:652`), unlike the intro chip. NEW. The home's `_open` returns silently when no target is found (`home_v3_screen.dart:1980-1984`). NEW
- **S11 names cut off (likely, not checked on a device):** tab cards are 176pt wide, with about 100pt for the label (`pv_door_carousel.dart:170`, `:1003`, `:1048`). Names at risk: "Talk and read to baby", "Why you feel this way", "Feeding and first days", "Getting ready for two", "Classes and experts". Pregnancy has no label-fit test; TTC does (`ttc_doors_explicit_names_test.dart:160`).
- **Lavender:** none found.

### What mothers ask that we don't cover well (`research/questions/ranked_pregnancy.csv`, top 51)
The fix is guidance in each door's own voice, never a Q&A list.

| Worry (rank) | Today | Door that should own it |
|---|---|---|
| What trimester or month is week N (2, 5-7, 13-15, 23) | Only on the week page | Home hero line, Learn |
| Discharge, normal or not (8, 28) | Symptom library only, no read | Symptoms |
| Cramps after the first weeks (4, 17, 40) | Only "first weeks" cramps | Symptoms / Complications |
| Travel and flying by trimester (22, 30, 38) | Is it safe? entries only | Is it safe? / Work and money |
| When movement starts (24, 26, 34) | One line in a weekly read (`pregnancy_reads_weekly_b.dart:38`) | Scans / Symptoms |

Already covered: back pain (1), side sleeping (35).

---

## 5. Faults by severity

**Broken**
1. ~~Her week stops moving after launch~~ **DONE (Batch 1, 2026-10-27):** `_now` is a getter; the shell calls `refreshClock()` on resume so screens repaint on a new day. Was: (`pregnancy_controller.dart:111`). *Fix:* work out `currentWeek`, `daysToDueDate` and `currentDay` from `DateTime.now()`.

**Wrong**
2. **PART DONE (Batch 1, 2026-10-27):** the due date is now required: the home opens a locked due-date page (`pregNeedsDueDate`, `preg_due_date_screen.dart`) once loading has settled, never for him; developer builds keep a close button. The Store header names no week without a date. The other surfaces below become developer-only guards, fixed as their batches touch them. Was: Week 20 is treated as real on the home rails, scan card, Scans timeline, Ask Veda, Learn videos, Nutrition `lead`, the Move session, the Store header and the You screen. *Fix:* make the due date required (decision); pass `isDueDateSet ? week : null` everywhere as a guard.
3. ~~Doors always open on tab 0.~~ **DONE (Batch 2, 2026-10-27):** `PvDoorPage.openingGroupFor(week)`, read by `pv_door_screen.dart` only with a real week; a named tab still wins. Was: *Fix:* add a `tabOrder` by week, like Parenting's.
4. ~~Labour opens on the contraction timer at weeks 6 to 24.~~ **DONE (Batch 2, 2026-10-27):** Understand the birth to 27, Signs and stages 28-36, the timer from 37 (NICE NG201, NICE NG25, WHO, ACOG CO 579). Was: *Fix:* signs and stages until 36, timer from 37.
5. ~~Getting ready opens on the name finder at week 34.~~ **DONE (Batch 2, 2026-10-27):** names to 19, What to buy 20-31, Home and help from 32 (NHS). Also by week now: Complications always opens on By month (information door); Work and money on Leave and rights from 28 (Maternity Benefit Act); Twins on Your care 20-31 and The birth from 32 (NICE NG137); Partner on Labour and birth from 36 (NICE NG201). Scans already opened right. Was: *Fix:* What to buy / Home and help from week 28.
6. ~~Learn's door shelves ignore week tags~~ **DONE (Batch 2, 2026-10-27):** `pregLearnPiecesOf(page, week:)` uses `sectionsFor` and `tilesFor`. Was: (`preg_learn_screen.dart:140`). *Fix:* use `sectionsFor(g.id, knownWeek)`.
7. Past 40 weeks the hero says 41 but the rails say 40, and More > Week by week opens week 40. *Fix:* use `pregPastDueWeek` / `_pageWeek` in both.
8. The Tools tab has the kick counter first at week 8 (`tools_hub_screen.dart:170`). *Fix:* order by week (kicks, Get ready and the timer from 28). Order only; rows stay with Terminal B.
9. ~~"Yes I'm pregnant" accepts an old logged period without checking.~~ **ALREADY DONE (found in Batch 1):** `ttcDatingCheck` (`ttc_transition.dart:146-156`, 2026-10-22) asks when the period is over 70 days old (`stale`) or missing (`guessed`). The helper misread it. *Fix:* if that period is more than ~10 weeks old, ask for the date.

**Weak**
10. The home never lifts "Your first weeks" (up to 13) or "Getting ready" (from 28). *Fix:* add both to `pregTrimesterLeads`.
11. No messages for weeks 4-10, the glucose test or the growth scan. *Fix:* add first-visit, dating, glucose test and growth scan messages.
12. The "Is it safe?" card is chosen at random by day. *Fix:* pick from entries with a note for her trimester.
13. The "update your due date" prompt is only in Tools. *Fix:* also show it on the home hero from week 14.
14. Late-pregnancy products all "fit". *Fix:* rank by closeness to `weekFrom`; add `weekTo` to the sheet.
15. No search ranks by week. *Fix:* when text scores tie, put items for her week first.
16. **PART DONE (Batch 2, 2026-10-27):** tagged Itching 28-42 (RCOG GTG 43), Telling work 12-27, Your maternity leave 28-42, Twins Finding out 1-13. **Symptoms not tagged on purpose:** its sections are by body area, not time; trimester-specific symptom guidance is content (Batch 6). Labour and Partner now open by week instead. Was: Belly and skin, Work and money, and Twins are untagged. *Fix:* tag them as their content is reviewed.
17. ~~Mind's copy drops tags~~ **DONE (Batch 2, 2026-10-27):** `mindDoorVisiblePage` carries weeks, tilesByWeek, forAfterLoss and openingGroupFor. Was: *Fix:* use `withTiles`.
18. ~~Is it safe? has no intro chip.~~ **DONE (Batch 2, 2026-10-27):** `PvDoorIntroChip` in the `CanIScreen` hero. Was: *Fix:* add the chip.
19. **KEPT ON PURPOSE (Batch 1):** the developer chips are the one place the week-20 stand-in is allowed (decision §0); in a store build the home now asks for the date anyway. Was: The developer chips can enter Pregnancy with no date. *Fix:* route those cases to the dating page.

**Polish**
20. **PART DONE (Batch 2, 2026-10-27):** a dimmed door card now answers its tap with a toast (`pv_door_chrome.dart`, `openPvDoorTile`). Still silent: `PvShelfCard` (Learn and other shelves, 14 callers across stages) — left for Batch 4 because a shared card change needs every caller checked. Was: "Coming soon" video tiles are silent taps. *Fix:* the same toast as the intro chip.
21. Tab names are probably cut off. *Fix:* two lines plus a label-fit test like TTC's.
22. "Tools for this week" shows over her own history. *Fix:* change the title when it shows history.
23. The week page has a stale lock comment and no estimate notice. *Fix:* correct the comment; add the notice (only a guard once the date is required).
24. "Reads for week N" pads with other weeks when fewer than 3 fit. *Fix:* pad with reads that suit any week.
25. ~~The old sign-in can change her stage.~~ **DONE (Batch 1, 2026-10-27):** it records a stage only when she has none (`auth_flow_screen.dart`). *Fix:* never set the stage from a sign-in prompt.

**Ownership note (agreed with Terminal B 2026-10-27):** the Move today session picking for week 20 (`pv_door_router.dart:487`) is **this terminal's**, as part of fault 2.

---

## 6. Order of work
1. **Foundation (this terminal, first, because Terminal B's week-based tool builds wait on it):** her week keeps moving (1); the due date is required at every way in, with week 20 for developers only (2, 9, 19, 25); "no week" passed as a guard.
2. **Doors:** `tabOrder` by week for Labour, Getting ready, Complications and Scans (3-5); Learn reads the tags (6); tags for the six untagged doors.
3. **Home and other screens:** Tools tab order (8, coordinated with Terminal B: one terminal edits the file at a time); past-40 week (7); tile lifts (10); the "update your due date" prompt (13); "Is it safe?" by trimester (12).
4. **Content:** the demand gaps in section 4. Each new section also goes to Ask Veda's ingest.
5. **Notifications** (11), with GLOBAL-CHANGES #12 Phase 6.

## 7. Decisions still yours
- None blocking. The three answered on 2026-10-26 are recorded in section 0. Any new decision raised during a build will be asked simply, with the recommendation first.
