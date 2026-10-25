# Tools 25-28: the You, Maa family

## Context
This is the parenting tools pass (`docs/pp-tool-plans/00-MASTER.md`). Food 22-24 is committed (03976a1, c0edeb7, e446cb2), and migration 0115 is run.

The user asked (2026-10-25) for the You, Maa family to be done the same way as Food: read-only audits, a Mobbin pass per tool, the backend done, and the plan approved in plan mode before building.

The You, Maa door was built in a2426c3 (`docs/pp-door-plans/03-you-maa.md` §13). The audits skip what that build already fixed:
- the banded door tool rows
- the mood check's crisis screen (now `PpCrisisPathScreen`)
- `pp_yoga/<classId>` and the after-check toast on the **router** path
- `pp_maa_ten_minutes`
- the deepened "Can I…?" door pages

The four tools:
| # | Tool | Surface | Screen |
|---|---|---|---|
| 25 | How have you been? | `pp_mood_check` | `pp_mood_check_screen.dart` |
| 26 | Can I...? | `pp_maa_can_i` | `pp_maa_can_i_screen.dart` |
| 27 | Kegel Care | `pp_kegel` | `lib/screens/tools/kegel_care_screen.dart`, **shared with pregnancy**, so changes stay additive behind `_kgPostpartum` |
| 28 | Yoga & fitness | `pp_yoga` | `yoga_home_screen.dart`, `yoga_class_screen.dart`, `pp_yoga_data.dart`, and via `booking_catalog.dart` / `pv_learn_*` |

Approved plan: `C:\Users\sarth\.claude\plans\continue-the-parenting-tools-effervescent-sundae.md` (copied here). **Built 2026-10-25, committed `96eef2d`; see "As built" at the foot.** The two held blocks below are now in STILL-OPEN §102.9 and BEFORE-LAUNCH.

## Out of scope, said plainly
- **App-wide search does not index Can I answers.** `ppSearch` lives in another file. Recorded in STILL-OPEN.
- **Kegel daily reminders.** The pregnancy reminder preset is not linked here, and it was not asked for.
- **The pregnancy and TTC Can I copies** (`can_i_data.dart`, `ttc_can_i_screen.dart`) are separate sources that can drift. Unifying them is a cross-stage job, recorded in STILL-OPEN.
- **The pelvic-floor start date stays as it is.** Squeezes start at six weeks; that is clinical-review work. The tools are only made to agree (see D6).
- **The dead `YogaStore._booked` set and the unreachable Classic yoga page** are left as they are (kept for revert).
- **Ask Veda's pregnancy wording for Kegel** (`veda_index.dart:63`) is pregnancy-side, so it is left.

## Mobbin pass (2026-10-25)
| Tool | Reference | Adopt | Decline |
|---|---|---|---|
| How have you been? | Me+ result: one "Ask for help" button above "Retake test" https://mobbin.com/screens/130988c9-87a4-43dd-a606-f056970ef0ac<br>Calm check-in, then "Recommended for you" https://mobbin.com/screens/b8cc948c-a5d1-434d-994d-40120c48a96a | One main "Find someone to talk to" button; "Start again" as the secondary; two mind pages under the result | The severity labels and scores in Me+, Hers and Finch. No score, ever |
| Can I...? | Apple Health medication: a "Lactation" row and a "discuss with your care team" line https://mobbin.com/screens/33b2f646-ff7d-4682-a4a5-b0c8f4103346<br>Clue numbered sources https://mobbin.com/screens/847d80b2-3060-4410-898e-07b372049cbc | A sources line on screen; a "talk to your doctor" line on every Ask | A "None found" verdict for things we did not check |
| Kegel Care | Alan "Hold · 2" with one pause button https://mobbin.com/screens/df3673b3-6c2a-43c3-ba6e-258b530213a0<br>stoic. progress bar and "Finish earlier" https://mobbin.com/screens/ea4a9e85-b8fa-4116-89cf-097d614e9cb2 | Closing a session early still saves what was done ("Finish earlier") | Streaks and day counts |
| Yoga & fitness | Future Pro filter chips with a star to save https://mobbin.com/screens/b25c23cf-e0ba-4753-bd98-f7191c7ef99a<br>Centr minutes and equipment line, plus a saved bookmark https://mobbin.com/screens/73ec1395-67ac-496b-8233-56f95570253e | A "Saved" chip in the existing chip row; the save toast with Undo | Gymshark's intensity and level framing for early weeks |

## Audit (inline for the mood check, three read-only audits for the others; key claims checked against the code)
| Tool | Findings (summary) |
|---|---|
| **How have you been?** | **Weak:** a "yes" result is a dead end. It is words only, with no tap to a doctor, a counsellor or Tele-MANAS (`:140`).<br>**Weak (clinical):** it asks about low mood only; worry after birth is never asked.<br>**Polish:** the header says "Whooley" (past month), but the questions use the PHQ-2 two-week window (`:12`). It uses `Icons.call_outlined` (`:106`). The eyebrow is "You, the mother" even in the father's view.<br>**Good:** the crisis line is pinned first; there is no score; nothing is stored (exempt from T0); it is on the shell; 4 tests. |
| **Can I...?** | **Wrong (clinical):** <br>- The red-flag rows (fever, heavy bleeding, headache or blurred vision, one swollen leg) wear the same grey "Ask" as cetirizine, with no urgent look and no call route (`:586-597`). <br>- Heavy bleeding is limited to "after the first weeks", though it is urgent at any time. <br>- Alcohol is labelled "Yes, with care" while its text says "Best avoided" (`:119`). <br>- Blood pressure is a blanket Yes, with telmisartan as an alias (`:916`). <br>- One word gives two verdicts: bp tablets, metformin and insulin; benadryl and cough syrup; shatavari. <br>- Fasting disagrees with the door. <br>- Strength training says Yes at week 1 (`:993`). <br>- Pelvic floor says "Yes, from the first days" (`:394`) while Kegel Care holds squeezes to six weeks. <br>- No sources line.<br>**Wrong:** the intro says "English or Hindi", but nothing typed in Devanagari is found.<br>**Weak:** <br>- The search matches any alias inside the typed text (`:1163`): "infant" finds the AC, "pillow" finds the pill, "until" finds til laddoo. <br>- No result is a dead end, with no Ask Veda. <br>- It assumes she breastfeeds. <br>- "In the first six weeks:" shows to a mother 10 months in (`:1453`). <br>- About 25 places say "he/his". <br>- `ppMaaCanISearch` has no callers. <br>- The door's "Search more" link lands on an unfiltered list. <br>- No entries for weight-loss pills or chickenpox near the birth. <br>- The mood row has no helpline.<br>**Polish:** Material search icon; the door says straightening is "Fine" while the tool cautions about formaldehyde; the pillion line; awkward double negatives; no Ask Veda or "read more" on the sheet.<br>**Good:** on the shell; 337 answers with brand aliases; the four-verdict model; doses stay with the doctor; a disclaimer. Nothing is stored, which is right. |
| **Kegel Care** | **Wrong:** <br>- Weeks since birth follow the child on screen (`ppDaysSinceBirth`), not her youngest, so a toddler selected gives kegels at week 3. <br>- After six weeks a saved custom routine (even one from pregnancy) gets past the 5 s × 10 cap (`:174`, `:926`, `:939`). <br>- "Easy" on a *breathing* session nudges the squeeze hold (`tools_store.dart:1081`). <br>- In breathe-first, the "How to do Kegel?" fold shows the squeeze instructions (`:488`). <br>- It disagrees with Can I (see above).<br>**Weak:** <br>- The blurb says "after your check", but only the date decides. <br>- The caesarean line is a fragment, and only in breathe-first. <br>- Its numbers differ from `pf_ex_kegels` (relax 6 s for a 3 s hold; ten breaths). <br>- The physio note has no button. <br>- Back without picking a feeling loses the session. <br>- The journey shows a breathing session as "4s · 5 reps" (`KegelRecord` has no kind). <br>- The toast doesn't say what changed.<br>**Polish:** Material icons; the pregnancy "Track" eyebrow and hue; "Animated guide - coming soon"; the file header.<br>**Good:** the stage split is additive and tested; no streaks; a safety list; local-first `ToolsStore`, per person, synced (`kegel_state` row plus the `tool_kegel_history` blob). |
| **Yoga & fitness** | **Wrong:** <br>- The six-week gate is on the router only. A hub tap (`yoga_home_screen.dart:155`) and three other push sites open after-check classes at week 1. <br>- `po_gentle_rec`, the early-weeks class, says "start once your doctor clears you" (`pp_yoga_data.dart:527`). <br>- A new user starts with two saves she never made (`:1081`). <br>- Saved classes are listed nowhere: nothing reads `YogaStore.saved`, and the save shows no toast. <br>- Five recorded classes at ₹299 play with no purchase (`booking_catalog.dart:226`). <br>- The class page shows seeded "4.9 · 214 parents" (`pv_learn_catalog.dart:439`).<br>**Weak:** <br>- Her weeks drive only a note, not the order. <br>- No stop signs and no disclaimer after birth. <br>- Three names for one surface. <br>- Purchases are a mock (known, payments not live).<br>**Polish:** Material icons; lavender card tints (hue 280/250 at lightness 0.9).<br>**Good:** on the shell; after-check classes labelled, never hidden; live booking through the engine with server seats; per-item merge; no "bounce back" framing. |

## Decisions
| # | Question | Recommended | User's answer |
|---|---|---|---|
| D1 | Add the two worry questions (GAD-2) to How have you been?, still no score and nothing saved | Yes | **Yes** (2026-10-25) |
| D2 | "Remind me in two weeks" after the result (only the date kept, never the answers) | Yes, an opt-in button | **Yes, opt-in** (2026-10-25) |
| D3 | Paid recorded yoga classes | Through booking, as a bought-once offering | **Through booking** (2026-10-25) |
| D4 | One verdict per search word in Can I (chosen, obvious) | Remove the clashing aliases; a test holds that each alias has one verdict | Recorded |
| D5 | Red flags in Can I (chosen, obvious) | A fifth verdict, **"See a doctor today"**, in the red-flag look with a call pill; the "harm" row opens the crisis screen | Recorded |
| D6 | Can I and Kegel disagree on pelvic floor (chosen, obvious) | Can I follows Kegel Care and the door: breathing first, squeezes from six weeks or sooner if her physio says so. REQUIRED_REVIEW, in BEFORE-LAUNCH | Recorded |
| D7 | The six-week gate (chosen, obvious) | One rule: every push into a class asks `ppSurfaceUnavailable('pp_yoga/<id>')`, the router's own check | Recorded |
| D8 | One name (chosen, obvious) | "Yoga & fitness" in the surface list as in Tools. The door keeps its situational "Classes for after birth" | Recorded |
| D9 | No new consent kind in this family (chosen, obvious) | Mood: exempt (nothing saved). Can I: stores nothing. Kegel and Yoga: hers, and read nowhere else. Said in the plan, not built | Recorded |

## Build, in three waves (each ends green, backend closed)

### Wave 1: backend
- **Mood reminder (D2):**
  - `NotificationService.scheduleOneOff` (`notification_service.dart:222`) with one fixed id. It is cancelled and replaced on each tap.
  - The title is "How have you been?". The body says nothing about her answers.
  - One prefs key `pp_mood_remind_at` (the date) lets the screen say "We'll ask again on <day>", with a Cancel.
  - It is **local to this phone and not synced**. A reminder belongs to the phone it rings on; a co-parent's phone must never ask her this. That trade-off goes into BACKEND-PATTERNS as a new entry: "a device-local record: what is never synced, and why".
- **Kegel history (`ToolsStore`):**
  - `KegelRecord` gains `kind` (`breath` | `kegel`). The read is lenient, so a missing kind means `kegel`; the lenient read *is* the migration for a JSON blob.
  - The `tool_kegel_history` blob shape is otherwise unchanged.
  - Feedback on a `breath` session never touches `_kegelHoldAdjust` / `_kegelRepAdjust`.
  - Closing a finished session without a feeling still saves it, with `feedback: null`.
  - Tests: an old record reads as `kegel`; a breath "easy" leaves the offsets alone; it round-trips.
- **YogaStore:**
  - The seeded `{'pn_group','md_sleep_rec'}` is commented out (kept for revert), so new users start empty. Existing synced saves are untouched.
  - A contract test pins the cloud item shape (`saved|<id>`, `booked|<id>`).
- **Paid recorded classes (D3):** `booking_catalog._fromYoga`
  - `YogaMode.recorded` with a price that isn't Free → `Offering(kind: masterclass, format: SessionFormat.recorded, grant: recordingAccess)`. Free recorded classes still return null and play.
  - `pv_learn_flow` already routes an offering to the buy step.
  - Play is gated on the entitlement, using the no-slot purchase path that `classPack` uses.
  - No migration: the catalogue lives in Dart (0066 comment), and the price is server-checked at payment time once payments go live.
  - A test holds that every priced class has an offering, and a free one plays.
- **Docs:** sync log step 21 and STILL-OPEN-BACKEND row 21 (the kegel `kind` field, the yoga seed, the recorded offering); BACKEND-PATTERNS (the device-local entry); BEFORE-LAUNCH (clinical review lines, below).

### Wave 2: clinical
- **Can I:**
  - D5's "See a doctor today" verdict on fever, heavy bleeding (reworded: "at any time"), bad headache or blurred vision, and one swollen leg. Each gets a pill to call (108 / the emergency card).
  - New rows: chest pain or breathlessness; wound redness, pus or opening; thoughts of harming yourself or the baby → `PpCrisisPathScreen`.
  - The mood row names Tele-MANAS 14416.
  - Alcohol becomes "Best avoided", matching the door.
  - BP: telmisartan comes out of the Yes row into its own Ask row.
  - D4: clashing aliases removed.
  - Fasting matches the door: no full or waterless fast under six months.
  - Strength training gets `firstWeeks: 'Not yet.'`.
  - D6 pelvic floor.
  - The door's straightening line follows the tool's formaldehyde caution.
  - The pillion line is fixed.
  - Two entries added: weight-loss and fat-burner pills (avoid); chickenpox near the birth (ask).
  - A sources line (LactMed, NHS, IAP/FOGSI). Every changed line is marked REQUIRED_REVIEW and goes in BEFORE-LAUNCH.
- **Kegel:**
  - Her clock is the youngest child: a local `_kgDaysSinceBirth` = `youngestAgeInWeeks`-based days. `ppDaysSinceBirth` itself is not changed (other readers).
  - After birth, a custom routine is clamped to 5 s × 10.
  - In breathe-first, the "how" fold shows the breathing how, never the squeeze.
  - The caesarean line is a full sentence, in both phases.
  - The numbers follow `pf_ex_kegels`: relax twice the hold, ten breaths. Pregnancy is unchanged.
- **Yoga:**
  - D7 at all four push sites (`yoga_home_screen.dart:155`, `provider_profile_screen.dart:614`, `pv_move_today_screen.dart:356`, `prenatal_yoga_screen.dart:255`) through one helper. The S8 toast carries its Breathing pill.
  - `po_gentle_rec`'s copy: "gentle enough for the first weeks; after a caesarean or a hard birth, ask your doctor first" (REQUIRED_REVIEW).
  - A "When to stop and call your doctor" block (bleeding, pain, leaking, heaviness) in the parenting For you.
  - A disclaimer on the class page.

### Wave 3: each tool's UX (Mobbin above)
- **How have you been?:**
  - Four questions (D1: GAD-2 in plain words, REQUIRED_REVIEW).
  - Any yes gives a main **"Find someone to talk to"** button → `pp_experts/Maternal mental health`. The router already gives the "joining soon, Tele-MANAS free, see a gynaecologist" answer until real counsellors join.
  - Two mind pages under the result: `mind_getting_help` and `mind_blues_vs_ppd`, or `mind_anxiety` when a worry answer is yes.
  - "Remind me in two weeks" (D2).
  - A drawn call mark.
  - The header comment corrected (PHQ-2 / GAD-2).
  - In the father's view the eyebrow is "For you" and the result also links `people_partner_low`.
  - Tools blurb: "Four questions. No score, nothing saved."
- **Can I...?:**
  - Search through `ppMaaCanISearch` (so it gets its callers): a 2-character minimum, word-start first, no reverse-substring.
  - No result → "Ask Veda about …" with the query typed, the same pattern as `pp_baby_food_check_screen.dart:2296`.
  - The `firstWeeks` line shows only while she is under six weeks.
  - Breastfeeding-only notes say so when `FamilyProfile.feedings` has no breastfeeding.
  - Caesarean notes show only for a C-section or an unknown birth.
  - Pronouns via `ppFillChild`.
  - `pp_maa_can_i/<category>` opens on a chip; the door's Medicines "Search more" uses it.
  - The intro drops "or Hindi".
  - The sheet gets an Ask Veda row and a "Read more" link to the door page where one exists.
  - A drawn search mark.
  - Tools blurb: "Quick answers for after the birth."
- **Kegel Care (postpartum only):**
  - Blurb: "Breathing first, then kegels from six weeks."
  - The toast says what changed ("Logged. Next time: hold 4 seconds").
  - The journey shows "Breathing · 10 breaths".
  - A physio pill → `pp_experts/Physiotherapist`.
  - "Animated guide - coming soon" → a link to `pf_find_muscle` (it has a film slot).
  - Drawn marks.
  - The eyebrow "For you" after birth.
- **Yoga & fitness:**
  - "For you" ordered by her band, using the same band map as `ppMaaTenMinutesTarget`: breath and gentle first under six weeks, pelvic floor at 6 weeks to 3 months, then deep core, then strength.
  - A "Saved" chip in the chip row, and a save toast with Undo; the class page can save too.
  - Seeded ratings off the class page.
  - Drawn marks.
  - Lavender tints → neutral grey.
  - D8.

## Files (main)
- **Screens:**
  - `lib/screens/post_pregnancy/`: `pp_mood_check_screen.dart`, `pp_maa_can_i_screen.dart`, `yoga_home_screen.dart`, `yoga_class_screen.dart`, `pp_yoga_data.dart`, `provider_profile_screen.dart`, `pp_surface_router.dart`, `pp_tools_tab.dart`, `pp_you_maa_content.dart` (straightening line, the Search more link)
  - `lib/screens/tools/kegel_care_screen.dart`
- **Services and booking:** `lib/services/tools_store.dart`, `lib/services/parenting_surfaces.dart`, `lib/booking/booking_catalog.dart`, `pv_learn_flow.dart` / `pv_learn_catalog.dart`, plus the two other class push sites.
- **Tests:**
  - New: `test/pp_maa_tools_test.dart` (backend) and `test/pp_maa_safety_test.dart` (clinical and UX).
  - Updated: `pp_mood_check_test`, `kegel_care_redesign_test` (pregnancy path still unchanged), `yoga_fitness_hub_test`, `pp_yoga_home_look_test`, `pp_maa_can_i_look_test`, `pp_you_maa_door_test`, `pp_tools_tab_test`.
- **Docs:** `docs/pp-tool-plans/25-28-you-maa.md`, README rows 25-28, BACKEND-PATTERNS, sync log step 21, STILL-OPEN-BACKEND row 21, BEFORE-LAUNCH, STILL-OPEN.

## Verification
- Run `git status` before edits. `pp_potty_content.dart` is another terminal's file and is not touched.
- After each wave:
  - `flutter analyze` on the touched files
  - the new tests plus neighbours: the you-maa door, postpartum bands, tools tab, one look, mood check, kegel, yoga hub and look, can-i look, gap doors, sync guard, cloud merged store, own row ledger, preg part2 sync, booking tests, pregnancy `can_i_*`
- The tests hold:
  - every red-flag row is urgent
  - one verdict per alias
  - "infant" finds no AC
  - no result shows Ask Veda
  - `firstWeeks` only under six weeks
  - Kegel at week 3 with an older child selected is breathe-first
  - the custom routine is capped
  - breath feedback leaves the offsets alone
  - an old record reads as `kegel`
  - a hub tap on an after-check class at week 2 toasts at every push site
  - new users have no saves
  - every priced class has an offering
  - the class page has no rating
  - the mood check has four questions, a help button after a yes, and a reminder that holds only a date
- Wiring gate: grep every `pp_maa_can_i/` link, every caller of the yoga gate helper, `ppMaaCanISearch`, and `scheduleOneOff` from the mood check.
- A phone walk only on the user's word. Git commands at the end, with explicit paths.

## As built (2026-10-25)
**Wave 1, backend:**
- **The mood reminder (D2).** One prefs key, `pp_mood_remind_at` (a date), and notification `920101` through `scheduleOneOff`, cancelled with `cancel`. The words are "How have you been? / Two minutes, just for you." It is on this phone only and never synced.
- **Kegel history.**
  - `KegelRecord.kind` (`kegel` | `breath`). A missing kind reads as `kegel`.
  - A breath session never nudges the offsets.
  - Leaving a finished session by back or Exit saves it with feeling `none` (the "Finish earlier" pattern). The journey shows no tag for it.
- **YogaStore** starts empty; the seed is commented out.
- **D3: paid recorded classes.** A priced recorded class is a masterclass-kind offering, format `recorded`, `recordingAccess`, with no credits and no slots. `_generate` returns none for a recorded offering. The commit bar's existing `buyThenPlay` / `ownsRecording` does the rest.
- **Docs:** sync log step 21, STILL-OPEN-BACKEND row 21, BACKEND-PATTERNS §16tt.

**Wave 2, clinical:**
- **Can I:**
  - `_Ans.urgent` ("See a doctor today") on the four red flags, plus three new ones: chest pain or breathlessness, a red or oozing wound, and thoughts of harm.
  - Heavy bleeding is now "at any time".
  - The harm row's sheet opens `PpCrisisPathScreen`. The other urgent rows open the emergency card.
  - Alcohol is "Best avoided", fasting follows the door, telmisartan and losartan have their own Ask row, and there are new rows for weight-loss pills and chickenpox.
  - D4: drug names leave the generic rows.
  - Pelvic floor is "Yes, with care": breathing first, squeezes from about six weeks.
  - Strength training gets "Not yet" for the first six weeks. The two-wheeler line is fixed. The bathing question is reworded.
  - The door's straightening card carries the keratin caution.
  - The sources line.
- **Kegel:**
  - Her clock is `ppMotherDaysSinceBirth`, new in `pp_age_bands.dart`: the youngest child's birth.
  - After birth a custom routine is clamped to 5 s x 10.
  - Breathe-first shows the breath "how" and a link to its page.
  - The caesarean line is a full sentence, in both phases.
  - The numbers follow the pages: ten breaths; relax twice the hold.
- **Yoga:**
  - `openYogaClass` (`yoga_class_screen.dart`) is the one way into a class. In Parenting it asks the router's own `ppSurfaceUnavailable`. It is called from the hub, the teacher's profile, Move today and Prenatal yoga.
  - `po_gentle_rec` is "gentle enough for the first weeks".
  - Every class page has a "When should I stop?" FAQ with the disclaimer.

**Wave 3, UX:**
- **How have you been?:**
  - Four questions.
  - After any yes, "Find someone to talk to" opens `pp_experts/Maternal mental health` (the "joining soon" answer names Tele-MANAS first).
  - Pages that fit the answers: getting help always; blues or PPD after a low-mood yes; anxiety after a worry yes; the partner page in the father's view.
  - "Remind me in two weeks", with Cancel and Undo.
  - A drawn phone mark. The eyebrow "For you" for the father. The header comment corrected.
- **Can I...?:**
  - One whole-word matcher, `_canIMatches`, for the screen and `ppMaaCanISearch`.
  - No result gives "Ask Veda about ...".
  - "In the first six weeks" shows only in her first six weeks.
  - A line for a mother who isn't breastfeeding.
  - `ppFillChild` on questions and answers.
  - `pp_maa_can_i/<category>`; the door's medicines "Search more" uses `/medicines`.
  - The sheet has the urgent pill, "Read more about this" (alcohol, fasting, medicines, travel, beauty pages) and "Ask Veda a follow-up".
  - The intro drops "or Hindi".
- **Kegel Care (after birth):**
  - The physio pill.
  - The toast says what changed ("Logged. Next time: hold 4 seconds"; "Logged: 10 slow breaths").
  - The journey says "Breathing · 10 breaths".
  - The eyebrow "For you".
  - The Tools blurb gives the date.
- **Yoga & fitness:**
  - "For you" rails follow her band (`ppYogaRailOrder`).
  - A "When to stop and call your doctor" row opens `body_red_flags`.
  - The Saved chip, with an invitation when empty. The save toast with Undo and View.
  - No seeded ratings or reviews on a class page.
  - A grey ground for the lavender hues.
  - The surface is named "Yoga & fitness".

**Differences from the plan, and why:**
| Plan | Built | Why |
|---|---|---|
| D4: "a test holds that each alias has one verdict" | Held for the names of things she takes (14 words) | A full sweep found 16 shared words. Most are different questions with rightly different answers ("fever" while breastfeeding: Yes; a fever after birth: urgent). The medicine and drink names were real drift and are fixed; the rest are listed for the clinical review |
| Can I: caesarean notes only after a C-section | Not built | They are sentences inside about a dozen answers, not a field; harmless as written. Held for STILL-OPEN |
| Drawn marks in Kegel Care and the Can I search field | Not built | They come from pregnancy's shared `PregNote` / `PregFoldRow` and the field glyph, used by every pregnancy tool, and no drawn search mark exists. That is a shell change |
| "The class page can save too" | Saving is from the hub cards; the class page is the shared offering page | The offering page serves every course and consult; a save there is a Learn change |
| STILL-OPEN and BEFORE-LAUNCH lines | Written below, not yet in those files | Another terminal has both files open (First 40). Add the two blocks below once that work is committed |

**Held for `docs/STILL-OPEN.md` (§102.9, after §102.8):**
> **§102.9 You, Maa tools (tools pass 25-28, 2026-10-25).**
> - App-wide search (`ppSearch`) does not index Can I's 340 answers.
> - Three copies of "Can I" can drift: pregnancy `can_i_data.dart`, TTC `ttc_can_i_screen.dart`, and this one. Fasting, alcohol and hair now agree with the door.
> - Shared words kept with different verdicts on purpose: contraception, crying, navratri, kajal, nazar, malaria, zumba, phone, mall. They go to the clinical review.
> - Caesarean notes inside answers show to everyone.
> - Kegel Care and the Can I field keep the shared chrome's Material icons.

**Held for `docs/BEFORE-LAUNCH.md` (after the Food tools line):**
> - [ ] **LAUNCH** · You, Maa tools (tools pass, 2026-10-25), all `REQUIRED_REVIEW`. Reviewers: perinatal counsellor, obstetrician, pharmacist, lactation consultant, women's health physio. Lines to review:
>   - the four mood questions and their two answers
>   - Can I's seven "See a doctor today" red flags
>   - alcohol, fasting under six months, telmisartan and losartan, weight-loss pills, chickenpox, the two-wheeler line
>   - every answer against its sources line
>   - pelvic floor squeezes from six weeks (Can I, Kegel Care, `pf_ex_kegels`)
>   - Kegel's numbers
>   - `po_gentle_rec` as "gentle enough for the first weeks"
>
>   docs/pp-tool-plans/25-28-you-maa.md · added 2026-10-25

## Verified
- New:
  - `test/pp_maa_tools_test.dart` (14):
    - Kegel: the youngest clock with the toddler on screen; the custom cap; the breath "how"; breath feedback; an old record; round-trip; leaving saves.
    - Yoga: no seeded saves; the cloud shape; priced recorded offerings with no slots; the gate at every push site; the band rails; no class rating plus the stop FAQ; no lavender.
  - `test/pp_maa_safety_test.dart` (11): urgent red flags; one verdict for what she takes; agreement with Kegel and the door; whole-word search; Ask Veda on no result; sources and no Hindi promise; first-six-weeks lines at week 3 and month 10; the emergency and crisis pills; `pp_maa_can_i/<category>`.
- Updated:
  - `test/pp_mood_check_test.dart` (6): four questions, the help row and pages per answer, the reminder keeps one date and cancels.
  - `test/kegel_care_redesign_test.dart`: the caesarean line's new words.
- Neighbours green:
  - Can I and doors: 121 (can-i look, gap doors, you-maa door, pregnancy can-i door and body, one look, tools tab).
  - Wider: 340 (cloud merged store, expert links, mind mood audit, own row ledger, consult filter, doors first view and sanity, postpartum bands, records merge, relevance, use consent sync, preg part2 sync, preg tools shell, purge, reader unification, sync guard, the new files, mood, kegel, yoga hub and look, learn, booking catalog and engine, preg move today).
- Analyze is clean on every touched file. The two infos in `pp_yoga_data.dart` (lines 1147, 1152) were there before.
- Wiring gate: `openYogaClass` has 4 callers; `pp_maa_can_i/medicines` is linked from the door; `_canIMatches` has 3 callers; `scheduleOneOff` is called from the mood check; `ppMotherDaysSinceBirth` is read by Kegel, Can I and Yoga; `ppYogaRailOrder` is read by the hub.
