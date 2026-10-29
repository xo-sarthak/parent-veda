# T5: TTC body checks

## Context
Family T5 of the tools pass (`00-MASTER.md`) covers four tools: **Symptoms and mood, Weight and BMI, PCOS check, Partner health**. T5 waits on nothing from Terminal A.

The audit was read-only, on 2026-10-29. Three helpers read the code against the 8-point checklist (`docs/pp-tool-plans/00-MASTER.md:19-28`), one per tool group. The lead checked every Wrong claim at its file:line. The user answered the two genuine questions the same day, after one round of discussion on Q1.

**Nothing is Broken.** Every tool opens, saves locally, syncs and has Undo. The work is clinical gaps (no red-flag route in the logger, a wrong NICE attribution, a PCOS safeguard that cannot fire), numbers saved that she never typed, and one promise of sharing that the database never kept.

**The build runs in a new terminal.** Read this whole file first, then "Build waves". Every file:line below was true on 2026-10-29; if lines have moved, find them by the quoted text.

Files the build touches. **Run `git status` before each edit.** On 2026-10-29 other terminals had `ttc_kind_cards.dart`, `ttc_focus_ivf.dart`, `family_profile.dart`, `pp_child_profile.dart`, `TTC-GAP.md` and migration 0130 open. None of those is on this list apart from a read of `FamilyProfileStore.age`.
- **Symptoms and mood:** `lib/screens/ttc/ttc_symptom_log_screen.dart`, `lib/ttc/ttc_symptom_data.dart` (read only), `lib/ttc/ttc_logging_extras.dart`, a new `lib/ttc/ttc_symptom_flags.dart` (the rules, pure), `lib/screens/ttc/ttc_strings.dart` (English side only).
- **Weight and BMI:** `lib/screens/ttc/ttc_tracker_screen.dart`, `lib/ttc/ttc_trackers_data.dart`, `lib/screens/ttc/ttc_bmi_screen.dart`, `lib/ttc/ttc_bmi_rules.dart`, `lib/ttc/ttc_bmi_store.dart` (header comment only).
- **PCOS check:** `lib/ttc/ttc_pcos_stand.dart`, `lib/screens/ttc/ttc_pcos_stand_screen.dart`, `lib/ttc/ttc_pcos_check_store.dart` (a reset/remove it may need), `lib/ttc/ttc_bmi_rules.dart` (PC5's copy).
- **Partner health and sharing:** `lib/ttc/ttc_trackers_data.dart`, `lib/screens/ttc/ttc_tracker_screen.dart`, `lib/screens/ttc/ttc_tools_screen.dart` (**the two `descEn` strings only**, PH2; rows are C1's), a new `lib/ttc/ttc_log_share_store.dart`, a new `lib/screens/ttc/ttc_partner_log_view.dart`, the You screen's "What ParentVeda uses" section (find it by that heading), `lib/services/remote/supabase_repo.dart` (no change expected; `fetchByUser` exists at `:83`).
- **Router:** `lib/screens/ttc/ttc_surface_router.dart` (the partner gate, S4/A9, and `focusGroup`, S5).
- **Migration:** `supabase/migrations/0131_ttc_log_shares.sql`, **written 2026-10-29 with this plan**.
- **Tests:** a new `test/ttc_t5_body_checks_test.dart`, plus `test/ttc_schema_contract_test.dart` (the new table) and wherever an existing test pins old copy. `test/ttc_pcos_stand_test.dart:279` pins the skip-null write-through that PC3 changes.

## Out of scope, said plainly
- **Tools rows** (his Weight and BMI entry, any rename) go to **C1** with its test. The only Tools edits in T5 are PH2's two descriptions.
- **Ask Veda context** (symptoms, mood, BMI band, PCOS check answers) is **not built**. It is a two-repo change and needs access to `C:\Projects\parentveda-askveda`. Handover, if it is ever wanted: a `ttc_body` object on the wire with `bmi_band` (`under|within|over|obese`, South Asian standard), `pcos_check_done` (bool), `pcos_signs` (list of domain ids, never a level) and `recent_symptoms` (ids from the last 7 days); the service would use them only for framing, never to name a condition. Each needs a consent kind first (T1).
- **S7, the Hindi disclaimer** (`ttc_strings.dart:491-493`): it drops the two-week-wait sentence and is Hindi in Latin script. Hindi is only on the user's word, so it is recorded here and on nobody's build list. The English side stays correct.
- **A shared view of her body data.** Q1 settled it: symptoms, mood, weight, BMI and the PCOS check stay private to her account. Only the two habit trackers can be shared.
- **A cycle-report share or PDF** (S-K6, the copy promises "something you can show your doctor"): recorded, not built. It belongs to the cycle report, T2's tool.
- **His BMI in the doctor check's `partnerConcern`:** not done. Our own reading must not move a clinical route (the T4 rule), so the check keeps asking her.
- **The known TTC test fails** are not T5's (listed in the T4 plan's Out of scope, plus `ttc_can_i_rebuild_test` "No, best to stop" x3, T3's).
- **Door files** (`lib/ttc/focus/ttc_focus_*.dart`, `pv_door_*.dart`, `pv_door_router.dart`) belong to Terminal A. Their lines are on the hand-over list below.

## Findings (checked)
### Wrong
| # | Tool | Finding | Where |
|---|---|---|---|
| S1 | Symptoms | **No red-flag route.** She can log pelvic pain, spotting and a positive test on one day (the NHS/RCOG pattern to be checked for an ectopic pregnancy), or bloating, nausea and pain on an IVF round (OHSS). The only reaction to a tap is the ovulation-positive toast. No chip records severity or one side. | `ttc_symptom_log_screen.dart:436-460`; chips `ttc_symptom_data.dart:263` (pelvic_pain), `:303` (disch_spotting), `:387` (pt_positive), `:430` (illness) |
| BW1 | BMI | Switching kg to lb changes the label only. A prefilled "62.0" is then read as 62 lb (28.1 kg), passes the 25 kg plausibility floor, and shows BMI about 10, "below the standard range". The "From your Weight log" line stays. | `ttc_bmi_screen.dart:592-593` (toggle), `:657-663` (`_submit`) |
| BW2 | BMI | The ft/in prefill can round the inches to "12" (182 cm = 71.65 in prefills 5 ft "12"), which trips the screen's own "Inches should be between 0 and 11". The display helper rounds total inches first and is right. | `ttc_bmi_screen.dart:139, 177` vs `:294-295` |
| BW3 | BMI | The pregnancy and under-18 guards can never fire: `_context` never passes `isPregnant` or `isMinor`, though `TtcStore.pregnancyConfirmed` (`ttc_store.dart:343`) and `FamilyProfileStore.age` exist. The rules test pins a path the screen cannot reach. | `ttc_bmi_screen.dart:236-247`; rules `:326, 338` |
| BW4 | Weight | Malformed text ("62..5", ".") fails to parse and **silently clears** the day's saved weight. | `ttc_tracker_screen.dart:2531-2535` |
| BW5 | Weight | Out-of-range input is saved as something she did not type, with no word: 250 becomes 200, 25 becomes 30. | `ttc_tracker_screen.dart:2537-2538`; `ttc_trackers_data.dart:312-313` |
| BW6 | Weight | The first tap on − or + logs **30 kg** (weight has no `start`). That number then prefills BMI ("From your Weight log") and ticks the `tests_done` milestone. | `ttc_tracker_screen.dart:2214-2217`; `ttc_milestones.dart:211` |
| BW7 | BMI | **Clinical attribution wrong, on screen.** "ICMR, the WHO Asia-Pacific classification and NICE all set overweight at 23 and obesity at 25." NICE (PH46, and the NHS BMI page) uses **23 and 27.5** for South Asian people. 25 is WHO Asia-Pacific (2000) and the Indian consensus (2009). The review register already calls it "NOT SETTLED". | `ttc_bmi_rules.dart:473-477`; comment `:20-21`; register `:501-503` |
| PC1 | PCOS | Her own "yes, 3 months or more without a period" never reaches her result. `_cycleLine` and `_nudge` read only `facts.hasLongGap` from her logs; with no logs the nudge never fires and the checklist prints "Longest gap: Not known yet". The answer is still written to `q_gap`, so the doctor check sees what her own result ignores. | `ttc_pcos_stand.dart:92, 145` (written), `:328, 411` (read from logs only) |
| PC2 | PCOS | "Clear my answers" clears the saved form only. The answers and `completedAt` written through to `TtcPcosCheckStore` stay, so BMI, the precheck and the doctor check keep reading a check she believes she cleared. | `ttc_pcos_stand_screen.dart:231-243` |
| PC3 | PCOS | Un-ticking an answer on a retake leaves the old value in the shared store, because the write-through skips nulls (`if (option != null)`). | `ttc_pcos_stand.dart:130-132` |
| PC4 | PCOS | **The pill safeguard cannot fire.** The engine caps the level when `q_contraception` is yes or recently stopped, because pill bleeds are regular by construction and read as false reassurance. The short check never asks it and the write-through never sets it. | `ttc_pcos_check_rules.dart:270-273, 309`; `ttc_pcos_stand.dart:124-160` |
| PH1 | Partner | On her phone: "You can fill this in together, or your partner can fill it in from his side of the app." `ttc_logs` is own-row only (`0041_ttc.sql:170-171`; no later migration adds a partner policy), so her entries sit under her account and his under his: two half-filled logs that never meet. His door already says "his own log, on his own account". | `ttc_tracker_screen.dart:1369-1371` vs `ttc_focus_his_side.dart:528-529` |
| PH2 | Partner | The row promises "His health, tests and habits" (his side: "Your health, tests and habits"). The tracker logs sleep, drinks, smoking, heat and movement; there are no tests on it. | `ttc_tools_screen.dart:390, 987`; `ttc_trackers_data.dart:370-420` |

### Weak and Polish (built where the wave says so; the rest recorded)
- **S2 Low mood (built).** The gentle line needs 3 days of guilt-type thoughts (`kTtcHardThoughtIds`, `ttc_logging_extras.dart:40-47`). Two weeks of "Low" or "Tearful" bring nothing; 14416 sits at the end of a read (`ttc_reads_hard_days.dart:945-947`).
- **S3 Fever on a round (built).** Temperature takes up to 40 °C (`:943-944`) and says nothing at 38.5 on a clinic round.
- **S4 + PC-A9 His phone reaches her private tools (built, router side).** Door tiles open `ttc_symptom_log` and `ttc_pcos_check` with no partner check (`ttc_focus_body_cycle.dart:117-124`, `ttc_focus_pcos.dart:714`), so he lands in her logger and writes to his own rows.
- **S5 Labels land at the top (built).** "Log your weight" (`ttc_journey_map_screen.dart:86`) and "Log the test for today" (`ttc_should_test_chat.dart:178`) open the logger with no `focusGroup` (router `:363`).
- **S6 Done says the total (built).** "5 things saved for today" (`:404-411`), and nothing when she only removed things.
- **S-K2 One logger for every phase (recorded).** No round-specific chips. Nothing is hidden after a loss, by the standing rule; S1's card covers the round's safety.
- **BW8 Two sources of truth (built).** A BMI save never reaches the Weight log; the Weight page's BMI row shows the last saved BMI after a newer weight (`ttc_tracker_screen.dart:2785-2788`).
- **BW9 Saves that say little (built).** The Weight type sheet pops with no toast (`:2539`); BMI's toast is "Measurement saved." (`ttc_bmi_screen.dart:765`).
- **BW10 (built).** The BMI store header says "NO CLOUD SYNC" against "IN THE CLOUD SINCE STEP 13" (`ttc_bmi_store.dart:16-18` vs `:58`). The height toggle drops a typed cm value (`bmi_screen:550-565`). The brackets comment says "no calculator" while listing `ttc_bmi` (`ttc_brackets.dart:202-205`).
- **BW11 Units differ across three entries (recorded).** Weight tracker kg only, 30-200; BMI kg/lb, 25-300; the symptom-log weight card kg/lb, 30-200. Left as is: each range is a mis-tap guard, not a judgement.
- **PC5 "Told us about a PCOS pattern" (built).** The screen promises "No score and no verdict" (`stand_screen:121-125`), but BMI says "You've already told us about a PCOS pattern" (`ttc_bmi_rules.dart:378-381`).
- **PC6 No red flag for fast change (built).** Nothing says that hair growth, a deeper voice or acne coming on over a few months needs a doctor soon.
- **PC7 An old gap keeps the nudge on (built).** `hasLongGap` uses the longest gap ever logged (`ttc_pcos_stand.dart:231`); Q2 asks about "the last year".
- **PC8 Three names (built where ours).** "Check the signs of PCOS" (`ttc_reads_body_cycle.dart:466`), "PCOS check" (`ttc_reads_waiting.dart:1636`), "PCOS symptom checker" (`ttc_surfaces.dart:66`). The one name is **"PCOS symptom check"**, the Tools row and the eyebrow.
- **PC11 (built).** Family history shows in the result but not in the appointment checklist (`stand.dart:382` vs `:452-458`). "See my pattern" saves without saying so (`stand_screen:540-541`).
- **PH3 His weight and BMI (built, Q2).** No weight item on his tracker; NHS and NICE link a male BMI over 30 with lower sperm quality.
- **PH4 Alcohol with no guide (built).** Drinks a day (`ttc_trackers_data.dart:390`), no 14-units line.
- **PH7 (built).** Her title "His sleep, drinks, smoke and heat." leaves out movement (`ttc_tracker_screen.dart:1487-1489`).

### Clean, as checked
- **Reachable, no silent taps.** Every way in was grepped (Tools rows, doors, reads, home, journeys, brackets, kind cards, messages). The old 20-question PCOS screen is commented out, kept for revert.
- **Never a diagnosis, no probability, anywhere.** "It's a record, never a diagnosis." (`:3105`), the English two-week-wait fold, the BMI disclaimer on every result, the PCOS check's "every path ends at a doctor".
- **Backend.** `TtcLogStore`: local-first, natural key `(user_id, tracker, field, logged_on)` upserts, soft `removed_at`, newer wins, debounced pushes, nothing pushed while logged out, sign-out reset registered, columns pinned in `test/ttc_schema_contract_test.dart`. BMI and PCOS stores are `CloudMergedStore`s.
- **Privacy at the database.** He cannot read her logs (`0041:170-171`), and 0131 keeps it that way for every tracker except the two habit ones.
- **House look.** No rendered emoji, drawn faces, white sheets, ink pills, line icons, no lavender.

## Decisions
| # | Question | Recommended | The user's answer |
|---|---|---|---|
| Q1 | Partner health: one shared log or two private ones? | First offered: private with honest copy. After the user's push ("shouldn't they be able to see what each other does... accountability check"): **habits shared, body data private, each person switches on sharing for their own log** | **Habits shared, each by their own choice with Share first; body data private** ("go", 2026-10-29). The two shareable trackers are his `partner_health` and her `habits`. Read-only for the other person: no edit, no streak, no alert about the other's entries |
| Q2 | Does he get his own weight and BMI? | Yes, in his voice, on his own account | **"yes he should get his own"** (2026-10-29). His weight stays private to him; it is not one of the shared trackers |
| D1 | S1: what fires a red-flag card? | The lead's clinical call, below | Taken as recommended |
| D2 | PC4: ask about contraception in a short check? | Yes, one question; the only way the shipped safeguard works | Taken as recommended (the lead's call; it adds a ninth question, the trade-off is recorded in W1) |
| D3 | BW7: which South Asian obesity cut-off? | Keep **25** as the India-first default (ICMR and Indian consensus, WHO Asia-Pacific) and correct the attribution: NICE and NHS use 27.5 | Taken as recommended; a BEFORE-LAUNCH clinician CHECK line |
| D4 | Where is the share answer stored? | Its own table, `ttc_log_shares`, enforced by RLS. Not the T1 use-consent store: that answers "may the app use this", this answers "may my partner see this", two different people asking | Taken as recommended |
| D5 | What his phone shows for her private tools | A calm card, "This is her private log. It stays on her account.", with a link to his own tracker. No silent tap, no hiding | Taken as recommended |

## Clinical calls (each goes on a BEFORE-LAUNCH clinician CHECK line, written on the user's word)
- **S1, ectopic pattern.** Same day: pelvic or one-sided pain **and** spotting or bleeding, **with** a positive pregnancy test logged in the last 14 days or a period 7 or more days late (from `CycleStore`). Card: "Pain with bleeding after a positive test needs checking the same day. Call your doctor or go to an early pregnancy unit today. If the pain is severe, or you feel faint or dizzy, call 112." NHS ectopic pregnancy page; RCOG GTG 21.
- **S1, OHSS pattern.** Only while a round is open and after egg collection (`TtcTreatmentStore` round step), same day: bloating **and** nausea or vomiting **and** pain. Card: "Bloating with sickness and pain after egg collection is something your clinic wants to hear about today. If you are short of breath, passing very little urine, or the pain is severe, get urgent help (112)." Matches T4 K3's wording and links `ttc_read_ivf_ohss`. RCOG GTG 5, NHS IVF page.
- **S3, fever.** A logged temperature of **38.0 °C or above** on an open round, or "Unwell" with that temperature at any time in the two-week wait after a transfer: "A temperature of 38 or above during treatment is worth a call to your clinic today." Otherwise a plain temperature stays a record (BBT is her normal use).
- **S2, low mood.** "Low", "Tearful" or "Anxious" on **8 or more of the last 14 days** (the PHQ-2 "more than half the days in two weeks" window): one gentle line under the mood row: "It's been a heavy couple of weeks. Talking helps, and it doesn't have to wait for a bad day. Tele-MANAS is free on 14416, day and night." Never a score, never "you may be depressed". Shown at most once every 7 days.
- **D3 / BW7.** The explainer reads: "We use the South Asian cut-offs: overweight from 23, and obesity from 25, as Indian guidance and the WHO Asia-Pacific classification set them. The NHS uses 27.5 for obesity in South Asian adults, so you may see that number too." The register line records the choice.
- **BMI on a clinic path.** Only when she is on a clinic path (`TtcCarePathway`), under the result, never as a target: "Many clinics ask for a BMI between 19 and 30 before IVF, because treatment is safer in that range. Your clinic will tell you what it uses." NICE CG156 1.2.2; HFEA.
- **PC4.** The question: "In the last 3 months, have you used the pill, patch, ring, injection, implant or hormonal coil?" (Yes / Stopped in the last 3 months / No). Writes `q_contraception` as `yes` / `stopped` / `no`, so the shipped `capped` copy runs.
- **PC6.** One fixed line on every result: "If hair growth, a deeper voice or acne came on quickly, over a few months, see a doctor soon rather than waiting for your next visit." (2023 International PCOS Guideline: rapid virilisation needs other causes ruled out.)
- **PH3, his BMI.** His voice, under his result: "A BMI over 30 is linked with lower sperm quality. Small changes count, and sperm take about three months to show them." NHS male infertility page; NICE CG156 1.2.3. The South Asian cut-offs apply to him too. No pregnancy guard on his side.
- **PH4.** Under the alcohol row: "The NHS guide is no more than 14 units a week, spread over 3 or more days. A pint of beer is about 2 to 3 units." Drinks-a-day logging stays.

## Build waves (no stop between waves; tests after each)
**Wave 1: clinical safety**
1. `lib/ttc/ttc_symptom_flags.dart`: pure functions `ttcSymptomFlag(day, logs, cycle, round) -> TtcSymptomFlag?` (ectopic, ohss, fever) and `ttcLowMoodDue(logs, now, lastShown)`. No widgets, so the test drives them directly.
2. `ttc_symptom_log_screen.dart`: after `_toggle` and after a temperature save, compute the flag for the day and show one calm card at the top of the day (reuse `TtcDoorRedFlag`'s look, `ttc_door_screen.dart:2618`, or its parts; never a modal). It stays while the pattern stands and goes when a chip is cleared. The low-mood line sits under the mood row.
3. PC4: the contraception question in `ttc_pcos_stand_screen.dart` (one row, after Q2), a `contraception` field on `PcosStandAnswers`, written through as `q_contraception`; the result shows the `capped` sentence when set.
4. PC6 line on every result; BW7 explainer and register; the clinic-path BMI line; BW3 `_context` passes `isPregnant: TtcStore.instance.pregnancyConfirmed` and `isMinor: (FamilyProfileStore.instance.age ?? 99) < 18`; PH4 line.

**Wave 2: numbers she typed, and saves that say what changed**
1. BW1: the kg/lb toggle converts the number in the box (and the cm/ft-in toggle converts too, BW10). Test: 62.0 kg toggled reads 136.7 lb, and BMI is unchanged.
2. BW2: the prefill rounds total inches first (`(m / 0.0254).round()`), the way `_heightText` does. Test at 182 cm: 5 ft 12 in never appears.
3. BW4 / BW5: the Weight sheet shows an inline error for text that will not parse and for a number outside 30-200 ("That looks like a mis-tap: weights here are 30 to 200 kg"), and saves nothing until it is fixed. A blank still clears, and the toast says "Weight removed for {day}" with Undo.
4. BW6: the first stepper tap starts from her latest logged weight, else her last BMI weight, else opens the type sheet. It never writes 30.
5. BW8: a BMI save also logs that weight in the Weight log for the save's day (one weight truth), and the toast says "Saved. 62.0 kg added to your Weight log for today." The Weight page's BMI row works its number out from the latest weight and the saved height when the weight is newer, and says "from your latest weight".
6. BW9: the Weight sheet toasts "62.5 kg saved for today" (or "changed from 62.0").
7. PC1: her "yes" counts. `_cycleLine`, `_nudge` and the checklist read `facts.hasLongGap || a.longGaps == PcosYesNo.yes`; the checklist line reads "You said: 3 months or more without a period".
8. PC2: "Clear my answers" also clears the T5-written ids in `TtcPcosCheckStore` and its `completedAt`; Undo restores both.
9. PC3: un-ticking removes the old value (a `remove(qid)` on the store); update the test at `ttc_pcos_stand_test.dart:279`.
10. PC5: BMI's note reads "Your PCOS check noted some signs worth raising. That makes a check-up before pregnancy more useful than usual…". PC7: `hasLongGap` counts gaps that ended in the last 365 days. PC8 names in the two reads and `ttc_surfaces.dart:66`. PC11 both.
11. S5: the router passes `focusGroup` for the two labelled entries (a `ttc_symptom_log#measurements` style id, or a named surface; pick the smaller change). S6: "Done" reports what changed this visit ("2 added, 1 removed"), and says it when only removals happened.
12. PH2: both descriptions become "His sleep, drinks, smoking, heat and movement" / "Your sleep, drinks, smoking, heat and movement". PH7: her title adds movement. BW10 comments.

**Wave 3: the couple (Q1, Q2, migration 0131)**
1. `lib/ttc/ttc_log_share_store.dart`: singleton `ChangeNotifier`, `TtcLogShareStore.instance`, a map tracker -> `true | false | null` (null = not asked). Local-first in `shared_preferences`, pushed as one row per tracker to `ttc_log_shares` (fire-and-forget), pulled on sign-in; it also reads the partner's two rows to say whether they share. Registered for the sign-out reset.
2. The ask card, once, after the first save to `partner_health` (on his phone) or `habits` (on hers): "Share your habits with her? She'll see what you log here, and nothing else. You can change this in You." Buttons **Share** (first, ink) and **Keep to myself**. The answer toasts what it changed. No card on a phone with no partner linked: the switch waits until there is someone to share with.
3. `lib/screens/ttc/ttc_partner_log_view.dart`: a read-only view of the partner's shared tracker, last 4 weeks, fetched with `SupabaseRepo.fetchByUser(TtcTables.logs, partnerId)`, filtered to that tracker (and the four folded habit ids, through `ttcMergedTracker`) and `removed_at == null`. Never merged into `TtcLogStore`. Empty states: "He hasn't shared his habits" / "Nothing logged in the last 4 weeks". It never says the partner chose not to share in a way that blames.
4. Entry points: on her phone, Partner health opens his shared view when he shares, and an honest invitation when he does not ("This is his log, on his phone. When he joins and shares it, you'll see it here."). Her old entries on this tracker stay, under a "Your notes" fold, **not deleted**. On his phone, the Habits tracker gets "See hers" when she shares.
5. PH1 copy: `kTtcTrackerPartnerWho` is commented out, kept for revert, and replaced by the two states above.
6. You, "What ParentVeda uses": a "Shared with your partner" group with the two switches, each saying what changes.
7. S4 / D5: the router, under `TtcPartnerMode`, sends `ttc_symptom_log` and `ttc_pcos_check` to a small `TtcHerPrivateNote` screen with a button to his own Partner health.
8. Q2 / PH3: his Partner health page gets a "Weight and BMI" row that opens `TtcBmiScreen(forHim: true)`: his wording (no oestrogen line, no pregnancy guard, PH3's line), his own account, `TtcLogStore` `weight` under his user id.
9. `test/ttc_schema_contract_test.dart` reads 0131 and pins `ttc_log_shares (user_id, tracker, shared, updated_at)`.

**Tests: `test/ttc_t5_body_checks_test.dart`**
- S1: each flag fires on its pattern and not on its near-misses (pain alone; spotting alone; a positive test with no pain; OHSS chips with no open round).
- S2: 8 of 14 days fires, 7 does not; once a week only.
- BW1, BW2, BW4-BW6, BW8 as listed in Wave 2.
- PC1-PC4: her yes reaches the result; clear resets the shared store; un-tick removes; contraception writes `q_contraception` and the engine caps.
- Q1: the share store round-trip; `TtcLogStore.pullFromCloud` still calls `SupabaseRepo.fetch` (own-user), never `fetchShared` (a source scan, as the migration header says); the partner view filters removed rows and the tracker set.
- Reachability: the partner view, the ask card, the You switches, the private-note gate and his BMI row each have a call site (source scan).
- Then `flutter analyze` on the touched files. The full TTC, Pregnancy and contract suite runs once, after C1.

## Backend
- **Migration 0131** (`supabase/migrations/0131_ttc_log_shares.sql`, written with this plan, **run by the user 2026-10-29**): the `ttc_log_shares` table, the `ttc_log_is_shared` security-definer function, and a second, read-only SELECT policy on `ttc_logs`. **Run it before installing the T5 build.** Without it the share answer cannot be saved in the cloud and the partner view reads nothing; nothing on the phone is lost.
- **The design, for BACKEND-PATTERNS** (on the user's word): consent that RLS enforces. The switch lives in the database, not only in the app, because a rule held only by the client is a rule any client can skip. Postgres ORs permissive policies, so a new read policy widens access without touching the old own-row write policy. Unpairing revokes it for free (`my_partner_id()` is null). The trap it avoids: widening RLS on a table is safe only while the store's query still pins its own user (`fetch`, not `fetchShared`), so the test pins the query, not just the policy.
- **Sync log:** one step for 0131 and the share store, on the user's word.

## Owed and hand-over
- **Terminal A (door files):**
  1. `ttc_focus_his_side.dart:528-529` "What he can track": "his own log, on his own account" becomes "his own log; he can choose to share it with you".
  2. PC8: any door tile naming the PCOS tool uses "PCOS symptom check".
  3. S4: the door tiles to her logger and PCOS check may stay; the router now catches his phone (D5). Heads-up only.
- **BEFORE-LAUNCH (on the user's word):** CHECK lines for every clinical call above (S1 ectopic, S1 OHSS, S3, S2, D3, the clinic-path BMI line, PC4, PC6, PH3, PH4); a LAUNCH line that 0131 is run; a two-phone CHECK for sharing on, off, and unpairing.
- **C1:** his Weight and BMI entry in his Tools set if it needs a row of its own; the one PCOS name on the row.
- **Ask Veda:** the handover in Out of scope, only if the user wants it.

## As built
(Written during the build.)
