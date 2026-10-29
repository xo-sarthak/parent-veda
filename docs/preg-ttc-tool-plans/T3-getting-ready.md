# T3: TTC getting ready

## Context
Family T3 of the tools pass (`00-MASTER.md`): **Pre-pregnancy checklist, Ready-to-Try plan, Supplements, Medical tests, Vaccinations, This week's food ideas, Can I…?, Habits ("What you're working on")**. It waits on nothing from Terminal A.

The audit was read-only, on 2026-10-29. Three helpers read the code against the 8-point checklist (`docs/pp-tool-plans/00-MASTER.md:19-28`). The lead checked every Wrong claim at its file:line, downgraded four and dropped one. The user answered the two genuine questions the same day. **The build runs in a new terminal.** Read this whole file first, then "Build waves". Every file:line below was true on 2026-10-29; re-find by the quoted text if lines have moved.

Files the build touches (none were dirty on 2026-10-29, while other terminals had the male-fertility door, Learning and booking files open; **run `git status` before each edit**):
- Data: `lib/ttc/ttc_can_i_data.dart`, `ttc_meal_week_data.dart`, `ttc_ready_plan.dart`, `ttc_ready_habits_store.dart`, `ttc_precheck_data.dart`, `ttc_precheck_rules.dart`, `ttc_supplements_store.dart`, `ttc_tests_data.dart`, `ttc_vaccines_data.dart`, `ttc_vaccine_store.dart`, `ttc_daily_data.dart` (two idea lines)
- Reads and journeys (not door files): `lib/ttc/reads/ttc_reads_meal_plan.dart`, `lib/ttc/reads/ttc_reads_pcos.dart`, `lib/data/journeys/ttc_journeys.dart`
- Screens: `lib/screens/ttc/ttc_stage_search.dart`, `ttc_can_i_screen.dart`, `ttc_nutrition_screen.dart`, `ttc_today_screen.dart` (food card only), `ttc_ready_plan_screen.dart`, `ttc_ready_week.dart`, `ttc_precheck_screen.dart`, `ttc_supplements_screen.dart`, `ttc_vaccines_screen.dart`, `ttc_tracker_screen.dart` (one line), `ttc_tools_screen.dart` (**one entry in `kTtcHisToolIds` only**: Q1)
- Tests: new `test/ttc_t3_getting_ready_test.dart`, plus updates where an existing test pins old copy

## Out of scope, said plainly
- **The Ready-to-Try plan's Tools row** goes to **C1** with its test, like T2's rows (`00-MASTER.md`, rule C1). T3 does not add rows to `ttc_tools_screen.dart`. The only Tools edit is Q1's entry in his set.
- **Merging the Ready plan's habits into the habits tracker:** not done (user, Q2). They are linked, not merged.
- **New tests in the Medical tests library** (CBC, thalassaemia carrier, blood group and Rh, mid-luteal progesterone): recorded, not built. Adding them is new clinical content for a clinician pass.
- **Reminders on Supplements and Vaccinations:** recorded, not built. The Ready plan already reminds about folic acid; a second folic reminder would double up.
- **Zika travel advice, an after-loss Can I question, ashwagandha by name:** recorded, not built (new content).
- **The four known TTC test fails** (door photos and ids for the PCOS circle and Loss room, "Others who have been here" in the loss reads, "What you're working on" twice on the Tools tab, `ttc_tabs_v3_test.dart:421`) are not T3's. Do not fix them here.
- **Hinglish strings** (the `*Hi` fields): English is the policy for new work. When an English line changes, the Hindi side is left as it is, unless it states the same wrong fact (W1, W2, W3), in which case it is commented out with "kept for revert" and the English shown.
- **Door files** (`lib/ttc/focus/ttc_focus_*.dart`, `pv_door_*.dart`, `pv_door_router.dart`): Terminal A's. The audit found no T3 door label to change.

## Findings (checked)
### Broken
None. No save loses her data.

### Wrong
| # | Finding | Where |
|---|---|---|
| W1 | Can I, alcohol: `verdict: TtcVerdict.moderate`, "Now and then, yes"; the India line says "drinking as normal in the first half of the cycle". NHS: no alcohol while trying | `ttc_can_i_data.dart:135-137, 145` |
| W2 | Can I, fish: "Keep large surmai (king mackerel) and shark to now and then." FDA says avoid; the food tool says "Skip large fish like shark and swordfish" | `ttc_can_i_data.dart:384` vs `ttc_meal_week_data.dart:359-360` |
| W3 | Can I, vaping/tobacco: "Tele-MANAS (14416)…" is the mental-health line. Tobacco quitline: 1800-11-2356 | `ttc_can_i_data.dart:566` |
| W4 | Privacy: stage search lists every Can I answer, including `sex_frequency`, without checking `TtcContentPrefs.hideIntimate`; the tool hides it | `ttc_stage_search.dart:184` vs `ttc_can_i_screen.dart:245` |
| W5 | Food: the Jain kitchen shows "an onion and tomato salad". `ttcJainSwapFor` skips onion on purpose; a Jain kitchen eats no onion at all | `ttc_meal_week_data.dart:189, 350-352` |
| W6 | Food: other surfaces promise a plan the tool says it is not ("A week of ideas, not a plan.", `ttc_nutrition_screen.dart:376`): "Plan your own week" / "day-by-day plan", "Add the recipes to your meal plan" / "a meal plan you can follow day by day", "The meal planner", "A meal planner built around…" | `ttc_reads_meal_plan.dart:290-291, 581-582`; `ttc_reads_pcos.dart:1059`; `ttc_journeys.dart:396` |
| W7 | Ready plan: the "Folic acid" habit has `surfaceId: 'ttc_medication'`; Medication says folic acid goes in Supplements | `ttc_ready_plan.dart:847` vs `ttc_medication_screen.dart:350` |
| W8 | Ready plan: weekly reminder "Five small things this week." `readyHabitsFor` returns 3 to 5 (calm and garbh are conditional) | `ttc_ready_habits_store.dart:364`; `ttc_ready_plan.dart:883, 891` |
| W9 | Two age rules: plan "over 35, six months"; checklist "a year of trying if you're under 36, and no need to wait from 36". The doctor check (T1, TC3) uses 35 | `ttc_ready_plan.dart:986`; `ttc_precheck_data.dart:598-600`; `ttc_fertility_help_rules.dart:81, 440` |
| W10 | Checklist, caffeine: "Around two to three cups of coffee a day" is over 200 mg; the same item's question says "Within about 200 mg" | `ttc_precheck_data.dart:430` vs `:732` |
| W11 | Supplements: the author comes from the row's `for_partner` flag, so on HIS phone her items read "Yours" and his read "Your partner's"; an item he adds for himself lands on her side. Doctor questions do it right | `ttc_supplements_store.dart:520, 558` vs `ttc_doctor_questions_store.dart:733` |
| W12 | Folic acid in two stores: the checklist's `takesFolate` reads only Supplements, so a doctor's 5 mg in Medication is never seen. The comment says it "never" ticks the item, but `kPrecheckFromRecords` contains `'folate'` and does tick it on a name match | `ttc_precheck_rules.dart:150-156` vs `:285, 291` |
| W13 | Vaccines: during a live-vaccine wait the verdict says "Nothing else on this page needs a wait" even when varicella is still needed (`liveOutstanding` ignored once `until != null`) | `ttc_vaccines_screen.dart:356-363` |
| W14 | Vaccines: varicella is "Two doses, four weeks apart" but the store keeps one `_doneOn` date per vaccine; logging dose 1 shows clear-to-try 28 days later | `ttc_vaccines_data.dart:185, 188`; `ttc_vaccine_store.dart:50, 136` |
| W15 | Vaccines: Hep B "A hepatitis B surface antigen test" (HBsAg = infection). Immunity is anti-HBs | `ttc_vaccines_data.dart:234, 281` |
| W16 | Vaccines: the group header "Given at 27 to 36 weeks." covers Influenza too, which is any trimester | `ttc_vaccines_screen.dart:651` |
| W17 | Vaccines: "Most Indian women were vaccinated as children" (rubella). Rubella entered the national programme with the 2017 MR campaign, to age 15 | `ttc_vaccines_data.dart:170` |

### Weak and Polish (built where the wave says so; the rest recorded)
- **K1 Checklist age (built):** `tryingOverSixMonths` (`ttc_precheck_rules.dart:118`) is never used and `PrecheckContext` (`:78-116`) has no age, so 35+ after six months never surfaces "when to ask for help". Only `tryingOverAYear` fires (`:228, :374`).
- **K2 Checklist (built):** thalassaemia "advised for all couples" next to "Not everyone needs genetic testing" (`ttc_precheck_data.dart:504, 508`). Silent tap `if (screen == null) return;` (`ttc_precheck_screen.dart:1994`, latent: all 13 ids resolve today).
- **K3 Checklist (recorded):** screen title (`ttcPrecheckTitle()`, `ttc_precheck_screen.dart:112`) differs from the row name; the check-up item's chip opens the whole Prepare shelf (`:2258`, router `:412`); status chips save with only the visual selection.
- **K4 Ready plan (built):** the "Plan saved…" toast (`ttc_ready_plan_screen.dart:153-157`) shows even when nothing was written through and does not name the age band and diet it also writes (`ttc_ready_plan_store.dart:325-368`); the "already trying" path (`:129-141`) saves and clears `plannedStart` with no toast.
- **K5 Ready plan (built, light):** never reads `TtcCarePathway`; a clinic couple opening the door gets "Learn your fertile days" (`ttc_ready_plan.dart:614-622`).
- **K6 Ready plan and habits tracker (built, Q2):** movement is in both (`TtcReadyHabitsStore` and the `ttc_logs` tracker); neither sees the other.
- **K7 Supplements (built):** Vitamin D "Test before you start taking it" (`ttc_supplements_store.dart:98`; same claim `ttc_ready_plan.dart:701`, `ttc_tests_data.dart:172`). NHS: 10 mcg a day needs no test. The 400 mcg line (`store:88`) has no 5 mg higher-risk note in the tool. Remove has no Undo (`ttc_supplements_screen.dart:921-922`).
- **K8 Supplements (built, Q1):** not in `kTtcHisToolIds` (`ttc_tools_screen.dart:949-961`), though two seeded items are his (`store:140-163`).
- **K9 Supplements (recorded):** the transition says supplements "carried over" (`ttc_transition.dart:433`) but pregnancy never reads the store; unsupported lines on omega-3 "hormone production" (`store:122`) and roasted chana (`:162`); route name `ttc/supplements` vs `ttc_supplements`.
- **K10 Medical tests (built: copy only):** TSH "below 2.5" with no "guidelines differ" (`ttc_tests_data.dart:84`); semen abstinence "Fewer or more days… changes the result" too absolute, WHO is 2-7 days (`:147`); vitamin D "worth testing both of you" but `forHim: false` (`:164`). **Recorded:** the checklist names haemoglobin but the library has no CBC (`ttc_precheck_data.dart:341`); ultrasound "the most direct way to confirm ovulation" (`:221`).
- **K11 Vaccines (built):** "No vaccine is holding you back" (`ttc_vaccines_screen.dart:403`) fires with varicella unrecorded (downgraded from Wrong: its body says "based on what you've recorded"); MMR "One dose" (`ttc_vaccines_data.dart:166`), UK Green Book says two; "A clear memory of having had chickenpox… is also a fair guide" (`:184`), less reliable for people from tropical countries. **Polish (built):** unreachable first-open branch (`screen:392`, `_verdict` renders only when `!_firstOpen`, `:223`) commented out; header comment "NO CLOUD SYNC" (`ttc_vaccine_store.dart:13`) contradicts `:31`. **Recorded:** no reminder for the clear-to-try date; COVID and HPV absent.
- **K12 Food (built):** kitchen defaults to `TtcKitchen.vegEggs` (`ttc_nutrition_screen.dart:195`) though `FamilyProfileStore.diet` already knows her diet; kitchen and swaps are prefs-only, no sync (`:108, 123, 126`); the Today card ignores her swap (`ttc_today_screen.dart:1237`, header admits it at `ttc_nutrition_screen.dart:38`); the idea swap and unswap save silently (`:407-420`); the folate idea never says food is not a substitute for the tablet (`ttc_daily_data.dart`, `folate_greens`); B12 "pure vegetarian" next to "Dahi, paneer, milk and eggs".
- **K13 Food (recorded):** the idea line ignores her kitchen ("egg yolk", "a small portion of meat", `ttc_daily_data.dart:1411, 1426`): downgraded from Wrong, each line already offers a vegetarian option. Non-veg only adds a note (`:363`). No PCOS or phase read. Hindi build has three names for the tool.
- **K14 Can I (built, light):** answers never read a clinic cycle or the two-week wait; workouts say "Yes, with a limit" during stimulation (`ttc_can_i_data.dart:231-245`). "A little plain coconut oil is another option" (`:473`). Short answers cut with an ellipsis (`ttc_can_i_parts.dart:210-211`). Route name `ttc/canI` (`ttc_stage_search.dart:191`) vs `ttc/can_i` (`ttc_can_i_screen.dart:83`).
- **K15 Habits (built):** tracker line "Sleep, movement and what you cut down." (`ttc_tracker_screen.dart:1484`) vs row "Sleep, movement, stress and lifestyle" (tools `:309`).
- **K16 Tests (built):** no test that search honours `hideIntimate`; no clinical-content pins (alcohol, fish, quitline); no `TtcVaccineStore` cloud round-trip; nothing checks the reminder count copy. The TTC C1 test stays with C1.

### Clean, as checked
- No personalised probability or readiness score anywhere (`ttc_precheck_rules.dart:45-49`). A disclaimer on every clinical page; Can I medicines all route to a doctor or pharmacist.
- Caffeine 200 mg in Can I (`ttc_can_i_data.dart:113-121`); smoking and vaping `avoid`; hair dye, papaya, pineapple myths; isotretinoin a month before trying; MMR and varicella one-month wait; AMH "not a fertility score"; FSH/LH day 2-3; Tdap 27-36 weeks (FOGSI).
- Can I with no match offers Ask Veda with `initialQuery` only: no wire field.
- Habits: reachable, partner voice branches (`ttc_tracker_screen.dart:1475-1486`), saves visible, `ttc_logs` columns pinned.
- Backend: checklist (`CloudMergedStore`, `ttc_precheck`, key pinned in `ttc_precheck_home_test.dart:253`), Ready plan (`ttc_ready_plans`, pinned in `onboarding_schema_contract_test.dart:60-66`), Supplements (`ttcs_<micros>` ids, pinned in `ttc_schema_contract_test.dart:61-65, 120-121`), Vaccines (`CloudMergedStore`, `ttc_vaccines`) are local-first, do nothing without a user id, and wipe on sign-out.
- **Dropped claim:** "the meal-plan next step is a read": it is `PvNextKind.tool` (`ttc_reads_meal_plan.dart:579`).

## Decisions
| # | Question | Recommended | User's answer |
|---|---|---|---|
| Q1 | Supplements on his Tools tab? | Yes: add `'supplements'` to `kTtcHisToolIds`. With W11 fixed he ticks his own items (CoQ10, zinc) | **Recommended** (2026-10-29) |
| Q2 | Ready plan "Your week" and the habits tracker both hold movement | Link, don't merge: the plan's movement habit gets a "Log it" link into "What you're working on"; each keeps its own data | **Recommended** (2026-10-29) |
| — | W1 alcohol | `verdict: avoid`. Short: "Best to stop while you're trying. No amount is known to be safe once you might be pregnant." Why: keep the heavy-drinking and two-week-wait reasons. India line: "Many couples stop from the start of trying, because a pregnancy shows up two weeks after it begins." Check `ttc_can_i_polarity_test.dart` still passes for an `avoid` verdict | chosen and recorded |
| — | W2 fish | "Rohu, pomfret, sardines (mathi), Indian mackerel (bangda) and prawns are good choices. Avoid shark, swordfish and large king mackerel (surmai)." One list, the same as the food tool's note | chosen and recorded |
| — | W3 quitline | "The National Tobacco Quitline (1800-11-2356) and your doctor can help if stopping is hard." | chosen and recorded |
| — | W4 search | Stage search skips Can I answers that the screen hides when `hideIntimate` is on: the same rule, one helper, used by both | chosen and recorded |
| — | W5 Jain onion | `ttcJainSwapFor` returns a swap for a dish naming onion ("cucumber and tomato salad with lemon"); the comment's reasoning is replaced, the old comment kept for revert | chosen and recorded |
| — | W6 labels | "This week's food ideas" (the tool's one name) / "See a week of food ideas that fits your kitchen."; recipes step: "See these in this week's food ideas"; PCOS read and journey: "Food ideas built around…" | chosen and recorded |
| — | W7 | Folic acid habit opens `ttc_supplements` | chosen and recorded |
| — | W8 | "Your small things for this week. Open your Ready-to-Try plan." | chosen and recorded |
| — | W9 / K1 one age rule | The doctor check's rule app-wide: under 35, twelve months; 35 or over, six months; over 40, talk to a doctor before trying. `PrecheckContext` gains the age band from `TtcFertilityHelpStore` (the Ready plan already writes it there) and uses `tryingOverSixMonths` for 35+ | chosen and recorded |
| — | W10 caffeine | "You don't need to give up chai. Keep caffeine under 200 mg a day: about two mugs of instant coffee, or one of filter coffee and a cup of chai." | chosen and recorded |
| — | W11 | Author from `row['user_id'] == me`, as doctor questions do. `for_partner` stays written (old phones read it) | chosen and recorded |
| — | W12 | `takesFolate` also matches `MedicineStore` names. The item shows the evidence ("Folic acid is on your list") and **never ticks itself**: `'folate'` leaves `kPrecheckFromRecords`, commented out with "kept for revert" (the comment's rule wins: a core medical item is not auto-completed by a name match) | chosen and recorded |
| — | W13 | The wait line names what is still needed: "…counted from your live vaccine. Varicella still needs doing." When nothing else is needed, the old line stays | chosen and recorded |
| — | W14 | A second dose date for two-dose live vaccines (varicella; MMR when a doctor gives two): stored under id `<id>_2` in the same merged store, so no table or column change. The wait counts from the last dose logged; with dose 1 only, the verdict says "Dose 2 is due from <date>", not clear-to-try | chosen and recorded |
| — | W15 | "A hepatitis B surface antibody test (anti-HBs) shows whether you're protected. The surface antigen test (HBsAg) in the pregnancy bloods checks for infection." Ask-list line to match | chosen and recorded |
| — | W16 | The header loses the week range ("Given in pregnancy. Good to know now, so you can ask then."); each card's own schedule line already states its timing | chosen and recorded |
| — | W17 | "Many women in India were never vaccinated against rubella, and few have the record. What counts is being immune, not the card…" | chosen and recorded |
| — | K7 vitamin D | "10 mcg a day is a safe everyday dose without a test. A test decides whether you need more." Same idea in the plan and the tests library | chosen and recorded |
| — | K7 folic acid | Under the 400 mcg dose: "Some women need 5 mg on a doctor's advice, for example with diabetes, a BMI of 30 or more, or a past pregnancy affected by a neural tube defect." | chosen and recorded |
| — | K11 MMR | "Usually one dose if you're not immune. Some doctors advise two, a month apart." | chosen and recorded |
| — | K12 kitchen | The default kitchen comes from `FamilyProfileStore.diet` (derive, never ask); her pick on the screen still wins and writes back to the profile, so it syncs through the profile's existing row. Swaps stay prefs-only (recorded) | chosen and recorded |
| — | K14 clinic line | On a clinic cycle (`TtcCarePathway` timing owned by the clinic), the exercise, sauna and medicine answers show one line first: "On a clinic cycle, your clinic's advice comes first." No other answer changes | chosen and recorded |
| — | K14 lubricant | Coconut oil line commented out (kept for revert); "Look for 'sperm-friendly' on the pack" stays | chosen and recorded |

## Clinical calls (each one on a BEFORE-LAUNCH clinician CHECK line, written on the user's word)
1. Alcohol: none while trying (NHS).
2. Fish to avoid: shark, swordfish, king mackerel (FDA; NHS for women trying).
3. Tobacco quitline 1800-11-2356.
4. Caffeine under 200 mg, and the mug equivalents (NHS: instant ~100 mg, filter ~140 mg).
5. Age rule: under 35 twelve months, 35+ six months, 40+ before trying (ACOG/ASRM; matches T1).
6. Vitamin D 10 mcg a day without a test (NHS).
7. Folic acid 400 mcg, 5 mg for the higher-risk list (NHS/RCOG).
8. Varicella two doses four weeks apart, the one-month wait from the last dose; MMR one or two doses (Green Book/CDC).
9. Hep B: anti-HBs for immunity, HBsAg for infection.
10. Tdap 27-36 weeks (FOGSI), flu any trimester.
11. Rubella coverage line (2017 MR campaign).
12. TSH and semen abstinence wording (K10).

**LAUNCH line** (beside "Relevance Batch 6 Ask Veda refresh"): re-ingest the corrected Can I answers, vaccine data and the meal-plan and PCOS reads. Nothing in `parentveda-askveda` hard-codes this advice (checked 2026-10-29), so no service code changes.

## Build waves (no stop between waves; tests after each)
**Wave 1: clinical and data**
- W1, W2, W3, W10, W15, W17, K7, K10, K11 copy (data files only).
- W9 and K1: one age rule; `PrecheckContext` reads the age band; `tryingOverSixMonths` used.
- W12: `takesFolate` reads both stores; `'folate'` out of `kPrecheckFromRecords`; the evidence line.
- W14: the second dose date and the wait from the last dose (store, then the screen's date picker for dose 2).
- W11: author from `user_id`.

**Wave 2: screens**
- W4 (search helper), W5, W6, W7, W8, W13, W16.
- K4 toasts, K5 clinic couple line on the plan (no "Learn your fertile days" when the clinic owns timing; show the clinic's line instead), K6 "Log it" link (Q2).
- K8: `'supplements'` into `kTtcHisToolIds` (Q1); check his supplements screen shows "Yours" for his own items.
- K12: kitchen from the profile, Today card reads the swap, toast with Undo on the idea swap, the folate tablet line, B12 wording.
- K14: the clinic line, coconut oil, the short-answer ellipsis (let it wrap to three lines, then the reader), one route name (`ttc/can_i`).
- K2, K15, the K11 verdict wording when something is unrecorded ("Nothing you've recorded is holding you back. Varicella isn't recorded yet.").

**Wave 3: polish**
- K11 Polish (unreachable branch commented out, stale header). Superseded UI commented out with "kept for revert".

**Tests** (new `test/ttc_t3_getting_ready_test.dart`, plus updates to tests that pin old copy):
- W1/W2/W3: alcohol verdict `avoid`; the fish list names king mackerel to avoid; no "Tele-MANAS" in the vaping answer; one fish list across Can I and food.
- W4: with `hideIntimate` on, stage search finds no `sex_frequency`.
- W5: no Jain dish contains "onion".
- W6: no TTC read or journey line says "meal plan" or "meal planner" for `ttc_nutrition`.
- W7: the folic habit's surface is `ttc_supplements`. W8: the reminder copy names no number.
- W9: one age rule: plan, checklist and doctor check agree at 34, 35 and 41 (source check on the strings plus the rule functions); K1: 35+ after 182 days surfaces "when to ask for help".
- W10: the caffeine line mentions 200 mg.
- W11: a row written by her reads `partner` on his phone (user ids differ).
- W12: folic acid in Medication shows the evidence; the item is never auto-ticked.
- W13/W14: dose 1 only gives "dose 2 due", not clear-to-try; the wait counts from dose 2; the wait line names an outstanding varicella. `TtcVaccineStore` cloud round-trip including `<id>_2`.
- K8: `kTtcHisToolIds` contains `supplements`. K12: a vegetarian profile opens on the veg kitchen; Today shows the swapped idea.
- K14: on a clinic cycle the exercise answer shows the clinic line.

**Verification:** `flutter analyze` on the touched files; the TTC tests (`test/ttc_*`), the onboarding contract test and the new file only, as the machine is short on memory; the wiring grep on every new reader (the search helper, the age band in `PrecheckContext`, `<id>_2`, the kitchen default, the "Log it" link, his supplements row). Phone walk later, on the user's word.

## Backend
- No new table, column or migration.
- W11 changes how `ttc_supplements` rows are read, not how they are written (`for_partner` keeps being written).
- W14's second dose rides the existing `ttc_vaccines` merged store as one more id; add the round-trip test.
- K12's kitchen syncs through `FamilyProfileStore`'s existing row; the food tool's prefs key stays as a local cache.
- If any of this changes sync behaviour, add a step to `docs/BACKEND-SYNC-LOG.md` on the user's word (check `git status` first).

## Owed and hand-over
- **Terminal A (door files):** none new from T3.
- **C1:** the Ready-to-Try plan's Tools row (with the C1 test).
- **BEFORE-LAUNCH:** the 12 CHECK lines and the LAUNCH line above, on the user's word. T2's four CHECK lines are still owed too.
- **Recorded for later:** new tests in the library (CBC, thalassaemia, blood group and Rh, mid-luteal progesterone), Supplements and Vaccinations reminders, Zika, an after-loss Can I question, ashwagandha by name, COVID and HPV, pregnancy reading the supplements list, PCOS-aware food ideas.

## As built
Built 2026-10-29, all three waves, in one terminal. Every superseded line is commented out with "kept for revert".

**Wave 1: clinical and data**
- **W1** `ttc_can_i_data.dart`: alcohol is `avoid`, no limit chip; short, why and India line as decided. The Hindi side said the same wrong thing, so it is commented out and the English shows. `ttc_can_i_polarity_test.dart` now pins `alcohol: avoid`, with a note saying why the one verdict moved.
- **W2** One fish list, `kTtcFishLine` in `ttc_meal_week_data.dart`. Can I's fish answer IS that constant, and the non-veg kitchen note interpolates it, so the two cannot drift.
- **W3** Vaping answer: the National Tobacco Quitline 1800-11-2356.
- **W10, K2** Checklist caffeine under 200 mg with the mug equivalents; thalassaemia "for everyone, beyond it not everyone needs genetic testing".
- **W9, K1** One age rule. `PrecheckContext` gains `ageBand` (from `TtcFertilityHelpStore`, which the Ready plan already writes) and `pastTimeToAsk`: over 40 at once, 35+ at 182 days, under 35 at 365, the same thresholds as `kFertilityHelpRules`. Evidence and priorities read it; the checklist text and its `medicalReview` say the same three numbers; the plan's note says "35 or over" and adds an over-40 line. The checklist screen now loads that store and listens to it.
- **W12** `takesFolate` matches Supplements AND Medication names. `'folate'` left `kPrecheckFromRecords` (the D12 decision is reversed, on the plan's call: a name match is evidence, not a tick; **the user confirmed it 2026-10-29: "Keep: she ticks it"**). The evidence line is "Folic acid is on your list. Check the dose…, then tick this yourself." `ttc_precheck_rebuild_test.dart` updated to match; the 360dp test ticks folate itself so Done still has a row to fold.
- **W14** `TtcVaccine.doses` (varicella 2) and `secondDoseOptional` (MMR). Dose two is the id `<id>_2` in the same status and date maps, so the merged cloud item set carries it with no format change. `secondDoseDueFrom`, `secondDoseOwed`, `lastDoseOn`, `setSecondDose`; `clearToTryFrom` skips a course with dose two owed and counts from the last dose; clearing dose one clears dose two. The checklist counts dose two owed as a live vaccine outstanding, so the vaccines item cannot tick early.
- **W11** Supplements' `for_partner` is relative to the row's OWNER, not to the phone. Reading: `authorOf(row, me)`: owner is me → the flag as written; owner is the partner → the flag flipped. Writing: `_cloudColumns` writes the flag from the owner's side (`_book.owners`). **This differs from the plan's one-liner** ("author from `user_id == me`, as doctor questions do"): a doctor question is always its writer's, but a supplement can be added FOR the other person, so the owner alone would put "CoQ10 for him", written on her phone, on her side on his. With no signed-in id (tests, signed out) the flag reads as before. `for_partner` is still written, as the plan required.
- **K7, K10, K11 copy**: vitamin D 10 mcg a day needs no test (supplements, plan, tests library); folic acid 5 mg line; TSH "guidelines differ"; semen 2 to 7 days; vitamin D "your partner may want it checked too" (it is on her list only); MMR "usually one dose, some doctors advise two"; chickenpox memory is a weaker guide in India; W15 anti-HBs and its ask line; W17 rubella line.

**Wave 2: screens**
- **W4** `ttcCanIShown(e, hideIntimate:)` in `ttc_can_i_screen.dart`, read by the tool's list and by `ttcStageSearch`.
- **W5** `ttcJainSwapFor` swaps a dish naming onion (`kTtcJainOnionSwap`); the old reasoning kept as a comment.
- **W6** Meal-plan read steps, PCOS read and the TTC journey use "This week's food ideas" / "Food ideas built around…".
- **W7, W8** The folic habit opens `ttc_supplements`; the weekly reminder names no number.
- **W13, K11 verdict** The wait line names an outstanding live vaccine; dose two owed is its own verdict ("Dose 2 of Varicella is due from…"); "Nothing you've recorded is holding you back" plus the unrecorded live vaccine's name when one is unanswered. **W16** header without the week range. The answered card: "Had dose 1 on…", "I've had dose 2" / "Change dose 2 date" (its picker cannot go before dose one), and Undo on Clear brings dose two back.
- **K4** The plan's save toast names only what her answers wrote (age band, kitchen, folic acid); the already-trying path now has a toast too.
- **K5** `buildReadyPlan(clinicTiming:)`: "Your clinic times this" (opens Appointments) replaces "Learn your fertile days"; `TtcReadyPlanStore.planFor` passes `TtcStore.ownership != parentveda`.
- **K6 (Q2)** "Log it" on the plan's movement habit opens `ttc_habits` ("What you're working on"). Linked, not merged.
- **K8 (Q1)** `'supplements'` in `kTtcHisToolIds`. On his phone a suggestion's side flips with partner mode (`ttcSuggestionAuthor`), so his CoQ10 and zinc land under "Yours". Remove now has Undo (`removeWithUndo`, the ticks come back too).
- **K12** The kitchen comes from `FamilyProfileStore.diet` (`ttcKitchenForDiet`), and a pick writes back (`ttcDietForKitchen`; a vegan profile is not narrowed). The prefs key stays as a local cache. Today's food row reads her kept swap (`TtcFoodIdeaToday` / `ttcFoodIdeaToday`). The idea swap and unswap toast with Undo. The folate idea says food does not replace the tablet; B12 wording no longer says "pure vegetarian" beside dahi and paneer (same in Supplements).
- **K14** On a clinic cycle the exercise, heat and medicine answers open with "On a clinic cycle, your clinic's advice comes first." (`kTtcCanIClinicFirstIds`, `ttcCanIAsRead(clinicCycle:)`). No answer's words changed. Coconut oil commented out. Short answers wrap instead of an ellipsis (longest is about 100 characters; the test holds them at 130 or fewer). One route name `ttc/can_i` (search and the Ask Veda pointer).
- **K15** Tracker line "Sleep, movement, stress and lifestyle."
- **K2** The checklist's silent tap now toasts.

**Wave 3: polish**
- The vaccines verdict's unreachable first-open branch is commented out; the vaccine store's header no longer says "NO CLOUD SYNC".

**Tests.** New `test/ttc_t3_getting_ready_test.dart`, 42 tests, all pass. Updated, each with a kept-for-revert note: `ttc_can_i_polarity_test.dart` and `ttc_care_test.dart` (alcohol is `avoid`; the care test now names the avoid set, smoking, vaping and alcohol, instead of capping it at two), `ttc_precheck_rebuild_test.dart` and `ttc_precheck_test.dart` (folic acid never self-ticks; caffeine's 200 mg is a limit, not a supplement dose), `ttc_appointments_vaccines_rebuild_test.dart` (varicella after dose one shows "Dose 2 is due from"). Two fixes came from the suite: the plan's vitamin D line names no figure (the plan's "no dose, anywhere" rule), and the link reads "Log movement" (explicit labels). The meal-plan read's non-veg FAQ uses `kTtcFishLine`, so it stays word for word with the tool's note.

**Suite (2026-10-29).** The full TTC run ended at 3231 passed, 14 failed. A second full run was stopped by Claude Code for low memory, so the failures were run file by file instead: every T3-related file (21 files) now passes, plus the care test. `ttc_can_i_rebuild_test` and `ttc_all_reads_videos_test` failed in the full run and pass on their own (run-order flakiness, not T3). The four known fails listed under Out of scope are not T3's. That accounts for 13 of the 14; **one failure was not identified** before the re-run was stopped. **Owed:** one full TTC run when memory allows.

**Wiring grep (2026-10-29).** Every new reader has its call site: `ttcCanIShown` (screen + search), `ageBand` (gather + the screen's load), `setSecondDose` / `_askWhenSecond` (the card), `ttcKitchenForDiet` / `_saveKitchenToProfile` (load + pick), `ttc_ready_habit_log_move`, `'supplements'` in his set, `TtcFoodIdeaToday` (Today), `clinicTiming` (store), `clinicCycle` (`openTtcCanIRead`), `removeWithUndo` (Remove), `ttcSuggestionAuthor` (list, add, toast), `authorOf` (cloud merge).

**Backend.** No table, column or migration. Two sync behaviours changed, both on existing rows: supplements' `for_partner` is now written and read relative to the row's owner (W11), and `ttc_vaccines` items may now include `v|<id>_2` (W14). Written as BACKEND-SYNC-LOG step 28 and BACKEND-PATTERNS §16zzl (2026-10-29, the user's word).

**Still owed.** ~~The 12 BEFORE-LAUNCH CHECK lines and the LAUNCH line~~: written 2026-10-29, with a two-phone CHECK for sync step 28; the Ask Veda re-ingest itself is the user's, in the one-time ingest. One full TTC test run. C1: the Ready-to-Try plan's Tools row. Terminal A: the food tool's one name is "This week's food ideas" (hand-over item 4). Phone walk later.
