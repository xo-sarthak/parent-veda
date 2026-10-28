# P5: Pregnancy, daily check-ins

## Context
Pregnancy and TTC tools pass (`00-MASTER.md`), family P5, Terminal B. Audit read-only on 2026-10-28; the lead read every file and checked every Broken and Wrong claim at its file:line. Findings were shown in chat first, then the user decided.

| # | Tool | Surface | Screen and store |
|---|---|---|---|
| 1 | Symptom check-in, Your week, Send my week, What to say when you call | `symptoms/today`, `symptoms/week`, `symptoms/send`, `symptoms/calling` | `screens/symptoms/door/*`; `SymptomStore` (synced, `symptom_logs`) |
| 2 | Mood check-in (Mind's Track tab: mood words, trend, worry journal) | `mind/track` | `mind_mood/mm_track_tab.dart`; `MindMoodStore` (phone only today) |
| 3 | Gentle check-in (the screener) | `mind/check_in` | `MmScreenerScreen`, `mind_mood/mm_talk_tab.dart`; nothing saved |
| 4 | Nutrition today (plate, five ticks, water, cravings) | `nutrition/today` | `nutrition/door/nutrition_today_body.dart`; `NutritionDayStore` (synced) |

## Out of scope, said plainly
- **Door files go to Terminal A:** the "11 questions" tab label is right but the door comments say "ten" (`pv_door_symptoms.dart:12, 98`). That is a comment fix only; A can do it any time.
- **The Mind door's other tabs** (Calm down now, Why moods change, the crisis path, the helplines, breathing) are not tools under M6 and are not audited here.
- **The old `SymptomCompanionScreen`** stays (kept for revert). Only the Calendar stops opening it.
- **Mood in Ask Veda context or the doctor-visit note** (M4) is parked: it would need the consent seam, and nobody has asked for it. It is listed under STILL-OPEN on the user's word.
- **Tools rows** are added here (D1), but the stage-wide C1 test still lands with C1.

## Findings (checked)
**Symptom check-in:**
- S1 Wrong (clinical): a logged symptom's row shows only its first self-care tip (`symptoms_today_body.dart:621`). Headache gets "Rest in a quiet, dark room"; blurred vision gets "Rest your eyes often". The call-now line for pre-eclampsia and the same-day test for cholestasis itching sit a tap deeper (`symptom_library.dart:325, 561`). Headache, swelling and blurred vision on one day give three comfort tips.
- S2 Weak (PG5): "What to say when you call" is a const with no controller, so "How many weeks you are" never shows her week (`symptoms_screens.dart:244-250`, router `:424`). "Whether the baby has moved today" never shows her last movement count.
- S3 Wrong: the Calendar's Symptoms row opens the old companion, not the door (`preg_cal_sheets.dart:64-65`; reached from `preg_calendar_hub.dart:827`, `preg_cal_sheets.dart:165, 481`).
- S4 Weak: the week grid draws 8 rows and drops the rest (`symptoms_week_body.dart:302`).
- S5 Weak (after loss): "COMMON IN WEEK n" (`:339`) and "(week n of pregnancy)" in the note she sends (`symptoms_week_body.dart:218`).
- S6 Polish: no word when a log saves; Send is disabled with no reason when the week is empty.

**Mood check-in:**
- M1 Broken: `MindMoodStore.init()` runs only in `MindMoodHomeScreen` (`mind_mood_home_screen.dart:81`), and its factory has no callers. The door draws the tab directly, so history never loads, and the first mood she logs writes the empty in-memory list over the saved key (`mind_mood_data.dart:2584-2590, 2626`). Journal entries go the same way. This is the same bug P4 S1/S2 found in the shopping list.
- M2 Weak: phone only, and not keyed per person. A new phone loses everything, and a second account on the same phone sees her journal (`mind_mood_data.dart:2460-2466, 2535`).
- M3 Weak: a journal delete is instant with no Undo (`mm_track_tab.dart:312-323`); a mood tap says nothing (`:116`).
- M4 Polish: the trend feeds nothing else (parked, above).

**Gentle check-in:**
- G1 Wrong (clinical): only the top answer to the self-harm question opens the crisis path (`mm_talk_tab.dart:273`, `severity >= 3`). "A fleeting thought" and "Yes, more than once" add to the total and end on ordinary advice.
- G2 Weak: the guidance names "the Feel tab", now "Calm down now" (`mind_mood_data.dart:2383-2397`). The top tier says "a counsellor and your doctor" but offers only a counsellor button (`mm_talk_tab.dart:375`).
- G3 Weak (after loss): "you or your baby would be better off without you" (`:2370`) and "an ordinary hard stretch of pregnancy" (`:2384`).
- G4 Weak: the question set is REQUIRED_REVIEW with no Pregnancy BEFORE-LAUNCH line.

**Nutrition today:**
- N1 Weak: a craving chip logs and opens the page in one tap, silently (`nutrition_today_body.dart:344-345`), so reading inflates "come up 3 times this week".
- N2 Weak (after loss): "That's a good day for your baby" (`:316`); the plate keys off her pregnancy week (`:102`).
- N3 Polish: the ICMR-NIN day references need a clinician line (`:276`).

**All four:** none is on Tools; all four use the door's own tool frame (inline bodies, so there is no shell to move). There are door tests (`symptoms_door_test`, `pv_door_mind_test`, `mind_mood_audit_test`, `nutrition_*`), but nothing covers M1, G1 or S1.

## Decisions
| # | Question | Recommended | User's answer (2026-10-28) |
|---|---|---|---|
| D1 | Mood, three ways | Mood check-in is the one mood log. The grid keeps "Mood swings" (something she would tell a doctor) and its row points to Mood check-in. The gentle check-in stays a one-off, saves nothing, and opens from inside Mood check-in. Tools gets a "Check in" group: Symptoms today, Mood check-in, Your plate today | **One mood log (recommended)** |
| D2 | Where the mood log and worry journal live | Phone only, keyed per person | **Cloud sync**: "what if the person wants to change the device ... they just lose access to the essential sensitive stuff that they wrote" |
| D3 | May a co-parent read them? | No. Owner-only; the screen promises "No one reads this but you" | **"your recommendation is right ... its personal and private"** |
| D4 | Clinical calls | Make them to NHS / RCOG / NICE standard; every number on a BEFORE-LAUNCH line | **Standing rule** (the user, 2026-10-27) |
| D5 | After a loss | Every P5 tool stays, the baby wording is dropped, and a calm `PregAfterLossNote` is shown | **Standing rule** (P3 D5) |

Obvious calls, recorded:
- A craving tap still logs and now says "Logged. Here's what helps."
- A journal delete gets Undo, using `pvToast` with an action.
- A mood tap says "Saved for today. Only you can see this."
- Send my week, when the week is empty, explains why instead of sitting disabled.
- The week grid shows every row.
- The Calendar opens the Symptoms door on Today.

## Clinical calls (each on a BEFORE-LAUNCH clinician CHECK line)
- **Self-harm question (G1):** any answer but "Not at all" opens the crisis path once she finishes (EPDS item 10 practice; NICE CG192). Calm, no label, and the crisis screen stays as it is.
- **Top screener tier:** adds "Tell your doctor or midwife at your next visit, or sooner" and the helplines row beside the counsellor button.
- **When-to-call rows (S1):** a symptom with a call condition shows a short when-to-call line in place of its tip:
  - headache from 20 weeks;
  - blurred vision;
  - itching of palms or soles;
  - sudden swelling of face or hands;
  - spotting (already "call now");
  - cramps with bleeding or on one side.

  The words come from each symptom's own `doctorGuidance`, shortened, never new advice.
- **One fixed rule (S1):** from 20 weeks, a headache logged on the same day as blurred vision or swelling shows "Together, these are a reason to call your maternity unit now", with the dialler. This is NHS's pre-eclampsia when-to-call card, a rule and not a calculated risk. It lives in code (`symptom_call_rules.dart`), never in the CMS.
- **What to say when you call (S2):** line 1 shows "You're 24 weeks (due 3 Jan)", or her clinic-owned date as given. Line 4, from 24 weeks, shows the last movement session from `BabyMovementStore` if there is one today. It is shown as her own observation, never "normal".
- **ICMR-NIN references (N3):** 60 g protein, 27 mg iron, 1000 mg calcium, 30 g fibre, 8 glasses. Dietitian check.

## Backend (D2, D3): `mind_mood_entries`, owner-only
- **Table:** one table, two kinds, `kind in ('mood','journal')`. Columns: `id` (app-generated text), `user_id`, `kind`, `date_key` (mood), `mood_id`, `body` (journal text), `prompt_id`, `created_at_iso`, `updated_at`, `deleted`. Mood ids are `mood_<date_key>`, so one mood per day stays one row on every phone. Journal ids keep today's microsecond id.
- **Access rules:** shape (a), own-row, on all four policies, `auth.uid() = user_id`. **Not** widened to the partner, unlike `0012_share_scans.sql`, and no `security definer` reach-across. This is the reverse of §7's name votes: there a function combines two private rows; here nothing ever does.
- **Client:**
  - `MindMoodStore` gets the `SymptomStore` shape: load-before-write guard, `SyncRowBook` per row, soft deletes that travel, merge on init, logged out behaves like local only.
  - Keys are per person, as in sync step 14.
  - The first sign-in uploads what is already on the phone, so nothing written before this build is lost.
  - `init()` is called from the tab itself, which fixes M1.
- **Migration:** `0124_mind_mood_entries.sql` (0123 is Community phase 2's; take the next free number at build time). The user runs it. Contract test: `test/mind_mood_schema_contract_test.dart`.
- **Privacy note on screen:** the empty-journal line changes from "stays on this phone" to "Saved to your account so it follows you to a new phone. Only you can read it, not a partner and not us." Check before writing it: if the team can read rows with the service role, the line drops "not us" and says "never shared".
- **Docs:** `BACKEND-PATTERNS.md` §3(a) gains this table as the worked case of "own-row even inside a shared family"; sync log step and STILL-OPEN-BACKEND on the user's word.

## Build, three waves, no stop between
1. **Safety and data:**
   - G1, S1 (rows and the one rule), S2, the screener tiers;
   - M1, plus the `MindMoodStore` sync and the migration file;
   - S3, the Calendar.
2. **Check in on Tools and the one mood log (D1):**
   - the "Check in" group with three rows (after-loss lines per D5);
   - the grid's "Mood swings" row points to Mood check-in;
   - the gentle check-in opens from Mood check-in (its door tile stays);
   - the after-loss wording across the four tools (S5, G3, N2);
   - the tab-name fixes (G2).
3. **Polish and tests:**
   - S4, S6, M3, N1;
   - tests: `MindMoodStore` loads through the door and never writes before loading; a round trip with a soft delete; the column contract; G1 (each non-zero answer reaches the crisis path); the S1 rule (headache plus vision from 20 weeks only); the Tools rows reachable; after-loss wording;
   - the wiring grep; the As built section; README row; BEFORE-LAUNCH lines (clinician checks, migration run, the Ask Veda ingest note) on the user's word.

Verification: `flutter analyze` on touched files; `symptoms_door_test`, `pv_door_mind_test`, `mind_mood_audit_test`, `nutrition_*`, `preg_*` and the new tests. No full suite, no phone walk (later, once).

## As built (2026-10-28)
Three waves, one pass. The migration is **0125**, not 0124: another terminal took 0124 (`0124_programme_age_window.sql`, PP 8) while this was planned. Column `deleted` in the plan became the house sync clock, `updated_at` + `removed_at`, like every other synced table.

**Gentle check-in** (`mind_mood_data.dart`, `mm_talk_tab.dart`)
- G1: `mmScreenerOpensCrisis` (any answer above "Not at all" to the safety question). The top answer still opens the crisis path at once; the other two open it over her result when she finishes. The crisis screen is unchanged and never says why it opened.
- Top tier: "Tell your doctor or midwife at your next visit, or sooner." and a Tele-MANAS 14416 call button with its hours beside "Talk to a counsellor"; a phone that cannot dial says so with the number.
- G2: "The Feel tab" is now "Calm down now". G3: after a loss the safety question reads "...or that others would be better off without you?" (same answers, same routing, REQUIRED_REVIEW) and the guidance drops "pregnancy" and "most mothers". The old guidance is kept for revert.

**Mood check-in** (`mind_mood_data.dart` `MindMoodStore`, `mm_track_tab.dart`, `0125_mind_mood_entries.sql`)
- M1: the tab calls `init()`; `init()` is one shared future; an edit before the read is held and replayed (`_change`, P4's shape). Edit and delete before the read return nothing, because nothing is on screen yet.
- D2: `OwnRowLedger('mind_mood_entries')`, newer wins per row, soft deletes travel, `_resetLocal` on sign-out and account switch, `hasPending` for the sign-out sheet. Mood ids `mood_<date>`, so one day is one row on every phone. Rows the phone held before this build upload on the first signed-in sync.
- D3: 0125 is own-row on all four policies, key `(user_id, id)`, guarded by 0100's trigger, added to the purge list. No partner policy, no `security definer`.
- M3: a mood tap says "Saved for today. Only you can see this."; a journal delete gives Undo (`restoreJournalEntry`, same id and date). The empty journal says the entry follows her to a new phone and is "never shared" (not "not us": the service role can read rows); logged out it still says "stays on this phone", plus "Sign in and it follows you to a new phone".
- D1: a card under the trend opens the gentle check-in (`mind/check_in`); its door tile stays.

**Symptoms** (`symptom_call_rules.dart` new, `symptoms_today_body.dart`, `symptoms_screens.dart`, `symptoms_week_body.dart`)
- S1: a logged symptom with a call condition shows its when-to-call line in place of the tip (headache from 20 weeks, blurred vision, itching and red palms, swelling, spotting, cramps), cut from its own `doctorGuidance`. The one rule, `symptomTogetherRule`: from 20 weeks, headache with blurred vision or swelling on one day shows "Together, these are a reason to call your maternity unit now." with a Call button (the dialler, no number, as `_CallRound`). In code, never the CMS.
- S2: "What to say when you call" reads `PregnancyController.current` (the router is Terminal A's and still builds it as a const): line 1 "You're 24 weeks (due 3 Jan)", ", the date your clinic gave" when clinic-owned; line 4 from 24 weeks "Today you logged 7 movements, the last at 3:40 pm." from the kick counter. Neither line after a loss.
- S3: the Calendar's Symptoms row opens the Symptoms door (`openPvDoorPage`), first tab; the old companion stays for revert.
- S4: the week grid draws every row. S5: "COMMON ONES" and no "week n of pregnancy" in the sent note after a loss. S6: a tap says "Headache logged. What helps is below."; Send on an empty week explains itself.
- D1: when "Mood swings" is logged, a line under What helps opens Mood check-in.

**Your plate** (`nutrition_today_body.dart`)
- N1: a craving tap still logs and now says "Logged. Here's what helps." before the page. N2: after a loss "All five today. That's a good day." and a note that the amounts are pregnancy amounts and to ask her doctor; the plate itself is unchanged (the postpartum chart assumes a birth and feeding, so it was not swapped in).

**Tools** (`tools_hub_screen.dart`): a first group, "Check in", with Symptoms today, Mood check-in, Your plate today, each opening its door's tool under the door's route name; after-loss lines on the two that mention a baby. Hidden in the partner preview, like Track.

**After a loss** (`preg_after_loss_note.dart`): `kAfterLossSymptoms`, `kAfterLossMood`, `kAfterLossPlate`, shown at the top of each tool.

**Tests:** `preg_p5_daily_checkins_test.dart` (35): M1 replay and the tab loading, the sync round trip with soft delete and Undo, a new phone pulling, the first upload, the 0125 column and owner-only contract, G1 per answer (widget), G2, S1 rule and lines, S2 lines, the Tools rows and every new link, after-loss wording. `mind_mood_audit_test.dart` reads the store before its journal tests. Docs: BACKEND-PATTERNS 16zzg.

**Left, said plainly**
- **The user runs 0125** in the Supabase SQL editor. Until then the mood log behaves as before (phone only): uploads wait in the ledger and go up once the table exists.
- Clinician CHECK lines for BEFORE-LAUNCH (on the user's word): the G1 routing, the top-tier doctor line, the six when-to-call lines, the 20-week rule, the after-loss safety question wording, the ICMR-NIN numbers (N3).
- Ask Veda: nothing new to ingest beyond the Tools row names; add to the one-time refresh line.
- Terminal A (door files): the door comment "ten" vs "11 questions" (`pv_door_symptoms.dart:12, 98`); the router could pass `pregnancy:` to `SymptomsCallingScreen` (it reads the live controller meanwhile).
- New lines show in English in the Hindi build (new work is English).
- Mood in Ask Veda's context or the doctor-visit note (M4) stays parked.
