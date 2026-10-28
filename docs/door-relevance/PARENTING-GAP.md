# Parenting (not the doors): relevance gap analysis

**Written 2026-10-27.** This is a read-only audit; no code was changed. It asks the same three questions of every Parenting screen except the doors. **Does it follow the family: the active child's real age, which child is selected, and what she has told us? Does it lead with one thing to do when one fits? Does it explain first when the subject is complicated?**

**How it was done:** read-only helpers went through the code, and I checked their key claims by hand at the cited line, marked **(checked)**. Nothing was walked on a device. **NEW** means not recorded before; **REC** means already recorded elsewhere.

**Out of scope:**
- **The 14 doors.** They are being rebuilt one by one (`docs/pp-door-plans/`), so there is no doors section here.
- **The tools themselves.** Their own pass is finished (`docs/pp-tool-plans/`). A tool problem gets one line here.

Siblings: `PREGNANCY-GAP.md`, `TTC-GAP.md`.

---

## 0. Decisions already made (2026-10-26)

| Question | Decision |
|---|---|
| No child saved | **The child's date of birth is required**, matching the Pregnancy due-date rule. The stand-in child born today (`pp_child_profile.dart:434-442`) is for developer mode only |
| Which age drives content for a baby born early | Chosen and recorded: **corrected age for every development and content choice under 24 months**. Birthday age stays for vaccines, growth and messages, and the screen says which age it is using |
| Activities per child | This terminal takes it, recorded against Parenting tool 20 (agreed with the tools terminal) |
| Consent | **Not blocking** (Terminal B, 2026-10-27). `PpUseConsent` already has feeds, nappies, development, foods and changes. Any new use of tool data calls `PpUseConsent.allows(kind)` from the start. That covers signals sent to Ask Veda and "Something changed?" moving activities |

---

## 1. How the app decides the child's age

| Piece | Where | Rule |
|---|---|---|
| Active child | `pp_child_profile.dart:456-466` | The chosen child, else the first child, else a stand-in child born today (`:434-442`) |
| Switching child | header family switch (`pp_home_v3.dart:4548`), `pp_child_switch.dart:27,70`, You | `switchTo` notifies the stores that listen (`:483-488`) |
| Birthday age | `ageInWeeks` / `ageInDays` / `ageInMonths` (`:840-846`) | Counted from the date of birth |
| Corrected age | `correctionWeeks`, `devAgeInMonths` (`:873-885`) | For a baby born early, until 24 months |
| The mother's clock | `youngestAgeInWeeks` (`:854`) | Age of the youngest child, used by You, Maa |
| Door age band | `pp_age_bands.dart:113-117,147` | Each door picks its own clock |
| Phase | `pp_phases_data.dart:1543-1546` | Corrected age |
| Situation snapshot | `pp_relevance.dart:88-133` | Birthday age, plus signals and "Something changed?" answers |
| Ranker | `ppRelevanceOrder` (`:212-238`); `ppRelevanceWhy` (`:243`) | Stable sort; never drops an item |
| Consent to use tool data | `PpUseConsent` (`pp_use_consent.dart:135`) | Off until she says yes. Read for feeds, changes, foods, development and nappies |

### The disagreement: two ages on one screen (baby born early)

| Uses corrected age | Uses birthday age |
|---|---|
| Hero and phase (`pp_home_v3.dart:258`, `:1907`) | Today strip tips (`pp_home_reads.dart:159`) |
| Month note (`:483`) | Three activities (`pp_home_v3.dart:265`) |
| Brain tab (`pp_brain_tab.dart:82`) | Reads fallback and products (`:267`, `:274`) |
| Ask Veda "For this age" questions (`askveda_screen.dart:145`) | **What Ask Veda sends** (`askveda_screen.dart:189`) |
| "New stage" message (`pp_messages_store.dart:363`) | Store (`pv_catalog_store.dart:98`) |
| | Age and Monday messages (`:324`, `:382`); Tools (`pp_tools_tab.dart:116`) |

So the hero can say "2 months corrected" while the tips, activities and products under it are picked for 4 months. Ask Veda shows corrected-age questions but sends birthday age. NEW

### PERSONALIZATION.md's three layers, as wired in code (all stages)

| Stage | Content layer | Recommendation layer | Ordering layer | Ask Veda context |
|---|---|---|---|---|
| Pregnancy | Week content; `personalizedFocus` has **0 callers** | Read offers; Store puts her week first | `pregRelevanceOrder`, `orderByPregPriority` | Conditions (`veda_context.dart:100-119`) |
| TTC | Phase content | Read offers; ready-plan pitches | `ttcAgeOrder`, `ttc_phase_rank` | Ownership, round step, cycle day, previous loss |
| Parenting | Age tips, phase docs, month notes | `pp_reco_data.dart:1139` reads the `recoBoosts` **keys only and drops the weights**; Store age-first | `ppRelevanceOrder` (home reads, products, FAQs, activities); `ppTileOrder`; `ppRankRecipes` | **Age and family stage only.** `aiContext()` (`family_profile.dart:797`) has **0 callers** |

### Ways into Parenting without a real child
- The developer "Stage · testing" Parenting chip (`pv_you_screen.dart:2856`)
- The old `AuthFlowScreen` "New parent" (`auth_flow_screen.dart:995`, `:273`), which asks for a due date and no child

Onboarding (`onboarding_flow.dart:2136`) and "Baby has arrived" (`pv_you_content.dart:1229`, `preg_hero_extras.dart:267`, `preg_messages_screen.dart:78`) both need a real child.

---

## 2. Home (`PpHomeV3`, the default per `pp_home_version.dart:48`), top to bottom

| # | Card | What picks it | Changes with age? |
|---|---|---|---|
| 0 | Painted hero, "Open this phase" (`:337`, `~:4590`) | Phase (corrected age) | Yes. The button opens a reading page, not an action |
| 1 | Dear Baby letters (`:381`); learning space from age 6 (`:386`) | Store state | Conditional |
| 2 | **My daily insights · Today** (`:396-453`) | Feed and sleep tiles under 12 months, then 5 tips | Yes (birthday weeks) |
| 3 | Milestones row (`:460`) | Newest saved milestone | No |
| 4 | Father card (`:469`) | Father preview | — |
| 5 | Month note (`:483`) | 12 to 71 months only (`pp_month_notes.dart:48`) | Yes |
| 6 | Visit card (`:489`) | A visit due within 21 days (`pp_visit_card.dart:58`) | Yes |
| 7 | "You told us" rows (`:497`) | Active "Something changed?" answers | — |
| 8 | Explore by topic, 11 tiles (`:550`) | `ppTileOrder` by age, priorities and signals (`pp_tile_order.dart:40-85`) | Yes, but **no line says why** a tile moved |
| 9 | Three things to do today (`:588`) | `PpHomeActivitiesStore` | Should, but see Broken 1 |
| 10 | How {name} is growing (`:677`) | Phase snapshot | Yes |
| 11 | Continue reading, then 3 reads (`:770-846`) | `ppHomeDoorReads` (door bands) | Yes |
| 12 | Useful at this age (`:877`) | `_productsForAge` (`:1370`) | Partly (see Wrong 3) |
| 13 | Journal, FAQs by phase (`:1031`), Keep handy (`:1070`) | Phase | FAQs only |

### First view at real ages

| Age | First card | One thing to do today? | What's off |
|---|---|---|---|
| No child saved | Generic tip (`pp_home_reads.dart:177`) | No | The stand-in child (age 0) brings newborn activities and products. The Store stays neutral; the home does not |
| 3 weeks | "Log the last feed" tile | Yes (logging) | — (the 6-week visit card shows, First 40 tile leads) |
| 4 months | Feed tile | Logging only | Usually no month note and no visit card |
| 9 months | Feed tile | Logging only | 9-month visit card |
| 18 months | A tip title | **No.** The month note's "try this" is 5th; the activities sit below an 11-tile grid | — |
| 3 years | A tip title | No | — |
| 5 years | A tip title | No | **"Useful at this age" pads with baby items** (soothers, bottles) |

### Cards that promise more than they deliver
- The comment at `:495` says the reads and activities "move up for it" when she tells us something. **Activities ignore those answers** (`pp_home_activities_store.dart:200-224`). Reads only reshuffle the three already picked; pages matching what she said are never lifted into the set (`pp_home_reads.dart:99`). NEW

### More than one child
The switch works and most stores follow it. **Today's activities do not** (Broken 1). **Continue reading** is not kept per child (`pp_home_reads.dart:225-300`). NEW

### The Today strip (planned after the doors)
**Now** (`ppHomeInsights`, `pp_home_reads.dart:152-193`): feed and sleep tiles under 12 months, then 5 short tips (20-60 words) from the age pool, rotated by day of the year. It ignores her situation, what she told us, vaccines, milestones and phase changes.

**What it should hold** (at most 5, in this order):
1. A follow-up on something urgent she told us
2. A doctor visit due within 7 days
3. Under 1: last feed and sleep. Over 1: today's activity (one tap to mark done)
4. This week's new skill for the phase, or the month note's "try this"
5. One tip that matches her situation, with its `ppRelevanceWhy` reason line
6. The day's tip

---

## 3. The other screens

| Screen | Finding |
|---|---|
| Tab bar | Home, Products, Tools, Brain activities, More (`pp_common.dart:616-623`). The same at every age, which is correct. **There is no Learn tab in Parenting** |
| **Learn (inside More)** | Experts, courses and groups shown with `.take(6)` in catalogue order (`pp_more_screen.dart:81-95`, `:192-200`). Filtered by stage only (`pv_learn_catalog.dart:88-91`; `booking_catalog.dart:108`). **No age band.** It is `late final`, so it never rebuilds. REC GLOBAL #7 (services by position, OWED) |
| **Brain tab** | "One thing, today" by corrected age (`pp_brain_tab.dart:82-84`). A different pick from the home's three, so the two "today" activities disagree. NEW |
| **Search** (#3) | Not on the home (`pp_home_v3.dart:473`). `PpSearchScreen` is reached only from doors and the router (`pp_surface_router.dart:818`). Scoring ignores age (`pp_search.dart ~200-219`). REC #3 (search on hold) |
| **Ask Veda** | Global button, door search fallback (`pp_search.dart:300`), "For this age" questions. Sends birthday age and family stage only, with no signals (`askveda_screen.dart:185-197`). NEW |
| **Store** | Products tab is `PvStoreScreen` (`products_discovery_screen.dart:632`); `fitsNow` / `_hersFirst` use birthday age (`pv_catalog_store.dart:89-112`). **The home rail uses a separate catalogue** (`kPpProducts` → `ProductDetailScreen`, `pp_home_v3.dart:885-893`), so the home's products and the Store's differ. NEW |
| **Article → service (#2)** | Already wired for Parenting through the `pp_` id prefix (`pv_read_offer.dart:139,156`; `pv_reader_screen.dart:220`). GLOBAL-CHANGES #2 still says OWED (stale). The offer ignores age, so a newborn masterclass can show on a 5-year-old's read. NEW |
| **Notifications** (`pp_messages_store.dart:312-403`) | Per real child: "X weeks old" weekly to 8 weeks at 9am, then monthly to 36 months, then quarterly to 72 months. Vaccines 3 days before at 10am. New phase at 6pm (corrected age, active child only, `:252`). Monday activity at 10am. **No signals, no limit on how many, no quiet hours, no offers** (REC #12). The opt-in vaccine alarms (`pp_vaccine_data.dart:893-912`) can repeat the automatic 3-day reminder for the same visit. NEW. The header comment (`:50-56`) says vaccines go to the active child only, but the code covers every child (`:229-231`) |
| Tools tab | Fixed order with feeds and nappies first at every age (ordering is this terminal's). Two tools are hidden after 12 months (`pp_tools_tab.dart:117`). That is about **which rows show**, so it is Terminal B's, and the user is deciding |

---

## 4. Faults by severity

**Broken**
1. ~~**Today's activities don't follow the child.**~~ **DONE 2026-10-28 (Batch 1).** Re-checked first: still keyed by the date alone (`_rollover` returned early on "same day, three picks"). Now each day holds one slot per child id plus age in months (`PpHomeActivitiesStore.slotKey`), each with its own picks, ticks and swaps; the stand-in child is `none`; the fortnight history stays shared. The home passes `child.activeChildId`. A cache written before the change keeps its history and recomputes its picks. Recorded against Parenting tool 20. Test: `test/pp_relevance_batch1_test.dart`.

**Wrong**
2. **Two ages on one screen** for a baby born early. *Fix:* use corrected age for development and content under 24 months; keep birthday age for vaccines, growth and messages, and say which on screen (decision, section 0). **Part done 2026-10-28 (Batch 1):** the home's three activities now use `devAgeInMonths`, the same line as PP 1. Still owed: tips, reads fallback, products, what Ask Veda sends, and the "which age" line.
3. **A 5-year-old's "Useful at this age" pads with baby products** (`pp_home_v3.dart:1378-1389`, **checked**: the rail fills up with items that don't suit the age). *Fix:* show only items that fit; if fewer than 6, fill from the next band, or show an empty state that invites her to the Store.
4. **What she told us doesn't move activities, and only reshuffles reads.** *Fix:* feed `PpSituation.changes` into the activity picker and lift matching pages into the read set, gated on `PpUseConsent.allows(changes)`.
5. **The home and the Store use different product catalogues.** *Fix:* build the home rail from `PvCatalogStore.forYou(parenting)`.
6. **Ask Veda gets no family context.** *Fix:* call `FamilyProfileStore.aiContext()` plus `PpSituation` signals in `AskVedaService.ask`, each gated on `PpUseConsent.allows(kind)`. **It is a two-repo change:** the Ask Veda service (`C:\Projects\parentveda-askveda`) must declare the new fields, or they are silently dropped (CLAUDE.md, "The wire body is a contract"). Ask the user for access first.

**Weak**
7. **No single lead action, especially after 12 months.** *Fix:* the Today strip in section 2, with the activity first.
8. **Learn offerings and article offers ignore age.** *Fix:* add an age band to offerings and rank them with `_hersFirst`-style logic.
9. **Home tiles move without saying why** (`pp_tile_order.dart`; rule at PERSONALIZATION.md:143). *Fix:* one reason line under the grid when a signal or priority moved a tile.
10. ~~**With no child saved, the home serves newborn content.**~~ **DONE 2026-10-28 (Batch 1).** Re-checked first: the developer chip (`pv_you_screen.dart:2835-2864`) and the old sign-in's "New parent" (`auth_flow_screen.dart:1006`, writes only `profiles.due_date`) both still landed on the stand-in child, and nothing asked a mother already in Parenting with no child. **One gate at the destination** instead of a fix per entrance: `ChildProfileStore.needsChild` (loaded, no real child, not him) makes the Parenting home open the add-child form once, required outside developer builds, with a line saying what the answer unlocks, and no daily tip until then. `hasLoaded` waits for the first cloud pull, so a new phone is not asked before her account's children arrive. Known cost: someone on the old sign-in types the birthday twice (rare; not built). Found on the way: the add-child form overflowed a short screen and clipped Save; it scrolls now, and an incomplete Save says what is missing instead of doing nothing. Test: `test/pp_relevance_batch1_test.dart`.
11. **Messages have no situation awareness, no limit, no quiet hours and no offers** (#12). *Fix:* Phase 6a as planned.
12. **The Brain tab's pick and the home's three disagree.** *Fix:* the Brain tab shows `PpHomeActivitiesStore.todays()[0]`.
13. ~~Tools hides two tools after 12 months.~~ Moved to Terminal B (it is about which rows show); the user is deciding.

**Polish**
14. Stale comments: "OFF BY DEFAULT" (`pp_home_v3.dart:1258`, but the flag is true) and the vaccines header (`pp_messages_store.dart:50-56`). *Fix:* correct both.
15. Stale docs: STILL-OPEN:1107 ("tips are not personalised by age"), STILL-OPEN §95.6(3) ("Something changed? is not stored"), GLOBAL-CHANGES #2 (Parenting OWED). All three are done. *Fix:* mark them done.
16. Possible double vaccine reminder. *Fix:* skip the automatic message when the visit has an opt-in alarm.
17. Continue reading is not kept per child. *Fix:* key it per child.

---

## 5. Order of work
1. **Foundation (this terminal, first):** activities per child (1); one age for development content (2); the date of birth required (10); the products rail (3, 5).
2. **The Today strip** (7), after the door rebuild finishes. All 14 doors are committed as of 613c631, so it is unblocked.
3. **Signals, behind `PpUseConsent.allows`:** "Something changed?" moves activities (4); Ask Veda family context (6, two-repo, needs access to the service repo).
4. **Rankings:** Learn and offers by age (8); tile reason line (9); Brain tab (12).
5. **Notifications** (11, 16) with GLOBAL-CHANGES #12 Phase 6. Doc and comment cleanup (14, 15) rides along with any of the above.

## 6. Decisions still yours
- Nothing blocking. Consent is not a blocker (section 0). The hidden-tools question is with the user via Terminal B.
