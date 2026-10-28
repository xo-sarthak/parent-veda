# Door content owed — the "STOP and list it" ledger

Every door brief carries the same rule: *"Use that copy VERBATIM. If a
referenced page is missing, STOP and list it in your output rather than
creating a new one."* This file is where those lists live, across every door,
so they can be worked through **once, at the very end**, instead of hunted out
of eight STILL-OPEN sections.

**The split, in one line: this file holds ROWS, STILL-OPEN holds STORIES.**
A row is here when the brief pointed at a page, a film, a track or a card and
it did not exist — the thing that gets written, recorded, sourced or decided
at the end. Everything else about a door (why a call was made, what the
engine grew, phone-walk notes, clinical reviews, hero photographs) is
STILL-OPEN's, and its "Still owed" lists POINT here rather than repeat a row.
A content item written in both places is the failure this file exists to
prevent.

**How each row was handled on the door.** There are only three outcomes, and
the Outcome column names which:

| Outcome | Meaning |
|---|---|
| **Coming soon** | The card holds its place on the rail at full size and does not tap. Nothing on the rail moves the day the piece lands. This is the default — CLAUDE.md: aspirational copy stays; the gap is recorded. |
| **Omitted** | The brief marked it optional and gave no copy. Not on the door. |
| **Built from data** | The brief gave no prose because none was needed — the "page" is a list the app already held as constants. Built, but flagged where those constants are themselves unconfirmed. |
| **Built, placeholder inside** | The card opens a screen that exists and works; what the screen holds is a stand-in (a drone for every raga, a 4×4 Sudoku). Not a coming-soon card — the screen's honesty about its content is the screen's job. Garbh Sanskar only. |

**Rules for this file:**

* Append-only, one section per door, in build order, **under the stage
  heading of the terminal that built it.** The pregnancy terminal writes under
  Pregnancy; the parenting terminal writes under Parenting; neither writes the
  other's rows.
* A row leaves this file only when the thing exists **and the card taps**. Tick
  it with `~~strikethrough~~` and the commit that closed it; do not delete
  the row.
* Each row names the file and the exact card so the closing edit is a lookup.
  The card titles below are the brief's, verbatim, and the coming-soon cards
  already carry them — writing the piece and pointing the card at it is the
  whole job.

---

## Pregnancy

### 1. Scans & tests — `lib/data/doors/pv_door_scans.dart`

| # | Card (brief's title) | Kind | Tab / section | Outcome | Owed |
|---|---|---|---|---|---|
| S1 | ~~What the scan person can and cannot tell you~~ | Read | **Filled** | Closed 2026-09-14, the fill commit: all twelve mapped verbatim into `SkActivity`, ids kept. Materials lines and no-supplies fallbacks are the task's. | | A four-minute read: why they go quiet, why they will not discuss the sex, who gives you the result. Two thirds of it is already inside `preg_scan_read_sex_law`; `content_slots.dart` has declared the slot for months. |

STILL-OPEN §33.6.

### 2. Complications & conditions — `lib/data/doors/pv_door_complications.dart`

Nothing owed. Every page the brief referenced existed; the one thing it did not
know about (an eleventh condition guide) was surplus, not missing. STILL-OPEN
§34.5 holds the clinical reviews only.

### 3. Nutrition & diet — `lib/data/doors/pv_door_nutrition.dart`

| # | Card (brief's title) | Kind | Tab / section | Outcome | Owed |
|---|---|---|---|---|---|
| N1 | Do I actually need supplements? | Video | Nutrients · "What your body needs" | Coming soon | A dietician on what food covers and what it usually does not. The brief marked it `[Video, COMING SOON]` itself. |
| N2 | Eight fasting pages | Read ×8 | Charts · "Fasting, done safely" | **Not built — one card instead** | The brief listed eight fasting topics as pages to reuse. They are not pages: all eight are title-and-paragraph rows rendered inline on `FastingScreen`, not tappable, no detail screen. The door carries ONE fasting card. **This is the item the brief asked to have listed.** Each `FastingTopic` already has a title and body and would make a small page easily; the brief forbade building them, so it is a decision, not a writing job. |

STILL-OPEN §35.2, §35.6.

### 4. Belly & skin — `lib/data/doors/pv_door_belly_skin.dart`

Nothing owed. Eighteen `BsPage`s and the itching read cover every card the
brief named. STILL-OPEN §36.5 holds device-walk notes only.

### 5. Labour prep — `lib/data/doors/pv_door_labour.dart`

The first door where most of a tab is owed. The area itself declares these in
`kPgBirthPrep` as `owed: true` elements or as `JourneyRead`s whose `surfaceId`
is *"Null until a real article exists behind it"* — so the door did not invent
the debt, it made it visible.

| # | Card (brief's title) | Kind | Tab / section | Outcome | Owed |
|---|---|---|---|---|---|
| L1 | The contraction timer, in two minutes | Video · 2 min | Prepare · "Before you need it" | Coming soon | When to start timing, what the numbers mean, the one pattern that means leave for the hospital. |
| L2 | Labour, start to finish | Video · 12 min | Birth · "What actually happens" | Coming soon | The stages, how long each usually takes, what it feels like. |
| L3 | If it becomes a C-section | Read · 6 min | Birth · "What actually happens" | Coming soon | What the operation involves, what you will feel, what recovery is actually like. |
| L4 | The first hour after birth | Read · 5 min | Birth · "What actually happens" | Coming soon | What happens to you and the baby in the hour nobody describes. |
| L5 | What labour is actually like, and your options | Read · 5 min | Birth · "Your choices to make now" | Coming soon | Pain relief, positions, who is in the room. Sits beside the birth plan tool; the plan asks the questions, this read is meant to inform the answers. |
| L6 | What your partner should actually do | Read · 5 min | Partner · "What your partner can actually do" | Coming soon | The practical jobs, in order, for somebody who has never done this either. |

Not owed, and worth knowing before somebody "fixes" it: the course card on the
Partner tab opens the course rather than playing a film — that is class 5 of
`kBirthingClasses`, behind the paywall, and the card says so by opening the page
where it is bought. STILL-OPEN §37.4, §37.5, §37.6.

### 6. Mind & mood — `lib/data/doors/pv_door_mind.dart`

Three `[new]` cards had no copy in the brief's section 3.

| # | Card (brief's title) | Kind | Tab / section | Outcome | Owed |
|---|---|---|---|---|---|
| M1 | Tell your doctor | Guide `[new]` · 3 min | When it is more than this · "Reaching out" | Coming soon | "How to raise it, with Ask Veda to word it." No prose in the brief. The words for a woman who cannot find them — owed by whoever writes the briefs. |
| M2 | Your partner can feel this too | Read `[new · optional]` | Understand | Omitted | No copy, marked optional. The existing partner piece (`kMmPartnerArticle`) is linked from "Bringing him in" instead, which is where the brief points at it. If the piece is written, it is a `PvDoorEntryTile` on the Understand rail. |
| M3 | Helpline numbers | Guide `[new]` | When it is more than this | Built from data | `MmHelplinesScreen` lists the constants `mind_mood_data.dart` already held — Tele-MANAS 14416 / 1800-891-4416, emergency 112. **Those constants are still marked `REQUIRED_TO_CONFIRM`** in the data file. Confirming them is the owed step, not writing. |
| M4 | Guided breathing, watch-along ×3 | Video · 3 min each | Feel · "Breathe" | Coming soon | "Watch-along versions (coming soon)" — one per `kMmBreathingExercises` entry. The interactive circle behind each is live; the film is not. |
| M5 | Calming audio ×4 | Audio | Feel · "Calming audio" | Coming soon | The four `kMmCalmAudio` tracks. The brief says reference Garbh Sanskar's Shravan assets — a wiring job once those assets are in the repo. |
| M6 | Meditations ×5 | Video | Feel · "Longer, when there is time" | Coming soon | The `kMmMeditations` entries other than `hard_day_reset`, which the brief rebuilt as a guided screen precisely so it would stop being a coming-soon. |

STILL-OPEN §40.2, §40.4.

### 7. Garbh Sanskar — `lib/data/doors/pv_door_garbh.dart`

Two coupled briefs. The door (built 2026-09-12) reuses every screen as it
is; the pillars brief builds what is BEHIND those screens to final. Nothing
on the door is coming-soon — every card opens a screen that exists — so
these rows are a fourth outcome, **built, placeholder inside**: the card
taps, the screen works, and what it holds is a stand-in. Each row closes
when its pillar is built to final (the pillars brief, pillar by pillar).

| # | Card (brief's title) | Kind | Tab / section | Outcome | Owed |
|---|---|---|---|---|---|
| ~~G1~~ | ~~Ragas ×5~~ | Audio ×5 | Listen · "Ragas" | **Built to final** (Shravan, 2026-09-12) | Five Carnatic veena recordings (L. Ramakrishnan ×2, Veena Kinhal ×3), public-domain dedications on archive.org, via `assets/audio/shravan_manifest.json`; streamed then cached. On **Cloudflare R2** since 2026-09-13. STILL-OPEN §46. |
| ~~G2~~ | ~~Nature sounds ×4~~ | Audio ×4 | Listen · "Nature sounds" | **Built to final** (Shravan, 2026-09-12) | Four radio-aporee field recordings incl. Prakrti temple bells, New Delhi. Same manifest, on R2. |
| ~~G3~~ | ~~Body Awareness Journey~~ | Guided · 9 min | Listen · "Guided" | **Built to final** (Shravan, 2026-09-12) | A nine-minute script (`kKriyaBodyAwareness`) on the relaxation screen, TTS via `GarbhNarrator`; recording owed as manifest entries under `kriya.body_awareness.<step>`. |
| ~~G4~~ | ~~Today's passage — the narrator~~ | Read + Record | Talk and read · "Today's pick" | **Built to final** (Samvad, 2026-09-12) | `GarbhNarrator`: manifest recording else calm TTS. Recordings owed as manifest entries under `samvad.<piece id>` — no code. STILL-OPEN §45. |
| ~~G5~~ | ~~Affirmations and blessings, ~20~~ | Read | Talk and read · "Affirmations and blessings" | **Built to final** (Samvad, 2026-09-12) | Twenty in the library (four new, English-only). |
| ~~G6~~ | ~~Stories and fables, 6–8~~ | Read library | Talk and read · "More to read aloud" | **Built** (verified, Samvad) | Sixteen original stories, 40–400 words each, tested. |
| ~~G7~~ | ~~Mantras and lullabies~~ | Read + Audio library | Talk and read · "More to read aloud" | **Built to final** (Samvad, 2026-09-12) | Eleven public-domain mantras/blessings + one folk lullaby with script, transliteration, meaning, source (`samvad_mantras_data.dart`); sixteen original lullabies alongside. Audio side stays G1's. |
| ~~G8~~ | ~~Spiritual reading, by tradition~~ | Read library | Talk and read · "More to read aloud" | **Built** (verified, Samvad) | Seven traditions of original reflection, none on by default — the file's own decision, which the brief allows. |
| ~~G9~~ | ~~Sudoku~~ | Game | For you · "A few quiet minutes" | **Built to final** (Buddhi, 2026-09-12) | 9×9 easy / 6×6 gentle, unique-solution generator, pencil, Check, Hint. STILL-OPEN §44. |
| ~~G10~~ | ~~Logic Puzzle~~ | Game | For you · "A few quiet minutes" | **Built to final** (Buddhi, 2026-09-12) | A nonogram, ten hand-drawn pictures, hints. Was a four-question quiz. STILL-OPEN §44. |
| ~~G11~~ | ~~Guided Relaxation~~ | Guided audio · 8 min | For you · "Breath and relaxation" | **Built to final** (Kriya, 2026-09-12) | `GarbhRelaxationScreen` + `kKriyaRelaxation`: 13-step script, TTS via `GarbhNarrator`, figure highlight, optional Shravan raga. Still owed for the recording only: thirteen manifest entries under `kriya.relax.<step>` — no code. STILL-OPEN §43.2. |
| ~~G12~~ | ~~Breathing practices~~ | Tool | For you · "Breath and relaxation" | **Built to final** (Kriya, 2026-09-12) | One `PvBreathingCircle` behind Garbh, Mind & mood and TTC; each area converts its model with `toBreathPattern()`. STILL-OPEN §43.1. |

Not owed: the affirmation rail's six pieces, the recording flow, the ritual
picker, Word Search and Memory Match, the journal and the invite flow — all
real. STILL-OPEN §42.

### 8. (folded into 7 — the pair is one area)

---

## Parenting

Built in a separate terminal. That terminal writes its own door sections
here, under this heading, from its own STILL-OPEN entries — nothing is
transcribed on its behalf. Sleep (STILL-OPEN §39.3) and Feeding are its first
two.

### P1. Sleep — `lib/data/doors/pp_door_sleep.dart`

**Added by the door 7 build (2026-10-25, `docs/pp-door-plans/07-sleep.md` SL1 to SL10, §12).** Nothing here is a coming-soon card: every item answers a tap with a notice, or shows a drawn mark.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| SLO1 | `sleep/door_intro` | Film · 30–45 s | Not slotted | S4: no chip until the film exists (SL8) |
| SLO2 | The 11 sleep slots: `sleep/needs_by_age`, `real_parents_night_waking`, `settling_demo`, `regressions_explainer`, `where_we_stand`, `bedtime_malish_followalong`, `malish_demo`, `safe_sleep_setup`, `swaddle_demo`, `drowsy_transfer`, `sound_volume` | Film | Slotted | A tap says the film is being made (S8a). The swaddle, malish and settling demos are shared with First 40, so one shoot each. Reviewed by a paediatrician or paediatric nurse |
| SLO3 | 23 of the 24 Sleep Sounds tracks | Audio | Rows, honest | Only the tanpura plays (Shravan's file). A tap on any other says "This lullaby (sound, story) is still being recorded. The tanpura plays now." with a Play it pill (SL4). The lullabies are to be recorded as real lori, in Hindi, Tamil and Bengali |
| SLO4 | Night lights, room thermometers, mosquito nets on the shop | Catalogue | S8c | `pp_products/Night lights` and `Room thermometers` carry the page's tip (`kPpShelfNotYet`); `Mosquito nets` says a chemist has one |
| SLO5 | A painting for each Tonight card (14 across the bands) | Painting | Built from data | Each card shows a line icon on the night-blue tint until then (`kPpSleepTonightCards`) |
| SLO6 | Shorter names for 18 tab names (17 since Behaviour's, BHO8, 2026-10-26; 15 since Early learning's two, ELO7, 2026-10-26) that take three lines, or break a word, on the rail card at normal or large text | Names | Listed | `test/door_names_fit_test.dart` `_kOwedShorterNames`, a proposal for each. Three are cut at the normal size today: Potty "Accidents and going backwards", First 40 "Understanding your newborn", Family "Who looks after your child". The words are the user's call, door by door |

### P2. Feeding — `lib/data/doors/pp_door_feeding.dart`

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| FD1 | `feeding/positions_demo` | Film · 8 min | Coming soon | Film for the new slot ("Positions that actually work"). |
| FD2 | `feeding/back_blows_demo` | Film · 5 min | Coming soon | Film for the new slot ("If he chokes: what to do"). The page's steps stand until it lands. |
| FD3 | Textures / cut-it-this-way / allergic reaction | Illustration | Built from data | Drawn in code (`pp_content_art.dart`); artwork can replace each painter via `PpIllustration.asset` without touching the pages. |
| FD4 | Introducing allergens safely (`solids_allergens`) | Interactive tracker | Built from data | The brief says "an allergen tracker: tick egg, peanut…". Built as a walk-through (introduced / not yet) that forgets on close. A tracker that REMEMBERS is a backend job: a `ChangeNotifier` store, a `pp_allergen_intros` table (child-scoped, RLS like `pp_sleep_logs`), local-first with `ChildSync.merge`, and the screen reading it. Decide, then build; the screen is already its front. **D4 (2026-10-23): yes, as its own later step.** |

**Added by the door 1 build (2026-10-25, `docs/pp-door-plans/01-feeding.md` §4, §11).** Films (each slot shows the placeholder and answers a tap, S8a):

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| FD5 | `feeding/paced_bottle_demo` on `formula_mixed` | Film · 3 min | Coming soon | Bottle held nearly level, a pause every few sips, a baby who also breastfeeds never flooded. A real parent and baby, no brand visible (IMS Act). |
| FD6 | `feeding/finger_foods_9m_demo` on `solids_textures` | Film · 3 min | Coming soon | Soft sticks, flattened peas, quartered grapes: the size, the squish test between finger and thumb, a nine-month-old eating them. |
| FD7 | `feeding/open_cup_demo` on `formula_weaning` | Film · 2 min | Coming soon | Small sips from a steel cup or a paladai at six to nine months, and the spills that are part of it. |
| FD8 | `feeding/ragi_porridge_textures` on `recipes_staples` | Film · 4 min | Coming soon | One pot of sprouted ragi porridge in an Indian kitchen, ladled into three bowls: smooth (6m), thicker (8m), lumpy (10m). |
| FD9 | `feeding/door_intro` | Film · 0:50 | Not built | The door intro chip (GLOBAL-CHANGES #5) waits for its first film; this is Feeding's. "How this door works": the five tabs, which one opens for his age. |

Catalogue items the door links to that do not exist yet (each tap says why, S8c/S8d; a catalogue entry, its price and coach are server-side decisions):

| # | Target | Where | Today's tap |
|---|---|---|---|
| FD10 | Shelves: `High chairs` (and floor boosters), `Steamers and freezer trays`, `Insulated food jars`, `Tiffin boxes`, `Open cups`, `Milk storage bags` | solids_setup, recipes_batch, recipes_tiffin_snacks, safety_water, bf_pumping | "We're still choosing good …" (S8c). The other 20 product rows of `01-feeding-content.md` A2 are owed with them. |
| FD11 | Classes: Breastfeeding Basics after birth (D3), Back to work: pumping and storage, Baby first aid and choking, Finger foods and self-feeding, The fussy eater workshop, Tiffin and toddler nutrition | bf_latch, bf_supply, bf_pumping, solids_textures, solids_spoon_or_blw, picky_battles, recipes_tiffin_snacks | "This class isn't open yet. Tap Tell me" (S8d) |
| FD12 | Paediatric feeding therapist (expert category) | picky_not_eating | Names a speech therapist, with a pill (S8b) |
| ~~FD13~~ | ~~A link that opens one programme (`co_weaning`, Confident Weaning)~~ | solids_when | **Closed 2026-10-27** (final review item 7, 574b99a): the router has a `pp_learn/<programId>` route now, and `solids_when` links `pp_learn/co_weaning`. Was: not linked, no per-programme route |
| FD14 | A week's meal planner | 'Recipes and your shopping list' (was 'Meal plan and shopping list', `pp_feeding_content.dart`) | Renamed to what opens (tools pass, Food, 2026-10-25): Recipes and its shopping list. A planner is not built |
| FD15 | A "food from three to five" chart page (`age_charts`) | What to feed at this age, past 36 months | An honest "From three years" block on the tool, linking Recipes and the checker. The pages stop at the toddler chart |

**Added by the door 2 build (2026-10-25, `docs/pp-door-plans/02-health.md` §4, §11).** Films (each slot shows the placeholder and answers a tap, S8a; on a go-now page, no pill):

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| HD1 | `health/temp_underarm` on `fever_reading` | Film · 1 min | Coming soon | Where the tip goes, how long, a squirming baby. Real parent and baby |
| HD2 | `health/glass_test` on `skin_which_rash` | Film · 40 s | Coming soon | A glass pressed on a rash that fades, and one that does not. The same test is inside `health/when_to_rush` |
| HD3 | `health/first_teeth_brushing` on `teeth_brushing` | Film · 1 min | Coming soon | A rice-grain smear, the lap position, twice a day |
| HD4 | `health/infant_cpr` on `health_choking_response` | Film · 3 min | Coming soon | **Expert-filmed only**, by the CPR instructor, on a mannequin. Never AI-generated |
| HD5 | `health/door_intro` | Film · 0:55 | Not built | A real paediatrician: the three speeds, where the go-now list is, and that the app never gives a dose. The chip waits for it (GLOBAL-CHANGES #5) |
| HD6 | `health/when_to_rush`, now on `health_go_now` | Film · 5 min | Coming soon | Unchanged slot, moved onto the red-flag page (§2g). Breathing trouble, a fit, the glass test, shown on real children |

Catalogue items and people the door points at that do not exist yet (each tap says why, S8b to S8d):

| # | Target | Where | Today's tap |
|---|---|---|---|
| HD7 | Shelves: `Underarm thermometers`, `Nasal aspirators`, `Oral syringes`, `Mosquito nets`, `Finger toothbrushes`, `Baby nail clippers`, `Lice combs`, `Sun hats and sunscreen`, `Health record folders` | fever_reading, cold_blocked_nose, prev_medicine, prev_medicine_box, prev_monsoon, ill_dengue, ill_insect_bites, teeth_brushing, prev_nails_ears, prev_head_lice, prev_heat, rec_abha | "Not in our shop yet. A chemist will have one." (the thermometer: "Any digital one with a flexible tip works."). A fragrance-free emollient for `skin_eczema` is held until one is checked |
| HD8 | Specialists: paediatric dentist, children's eye doctor, children's ENT, audiologist, children's allergy, chest and hormone doctors | teeth_when, teeth_brushing, teeth_dentist, eyes_checks, eyes_screens, ears_hearing | "We're adding … A paediatrician can check this first." with a pill (S8b). Real profiles arrive through onboarding (`ADMIN-PANEL.md`), never invented |
| HD9 | Classes: Baby first aid and CPR (Get help now's closing, H3; also Feeding FD11), and owed with it: Fever, colds and tummy bugs evening; The home medicine box; First tooth to first dentist; Monsoon season; Vaccines, the first year | help tab foot; the other five have no link yet | "This class isn't open yet. Tap Tell me" (S8d). The CPR instructor exists in the roster (`pp_experts_data.dart`), with no class row |

---

## The count, for the end

| Door | Rows | Coming soon | Omitted | Built from data | Decision |
|---|---|---|---|---|---|
| Scans & tests | 1 | 1 | – | – | – |
| Complications | 0 | – | – | – | – |
| Nutrition | 2 | 1 | – | – | 1 (fasting pages) |
| Belly & skin | 0 | – | – | – | – |
| Labour prep | 6 | 6 | – | – | – |
| Mind & mood | 6 | 4 (M1, M4–M6) | 1 | 1 | – |
| Garbh Sanskar | 12 | – | – | – | all twelve closed; owed now = recordings (manifest entries) and R2 hosting (nine URLs) |
| Sleep (parenting) | 6 | – | – | 1 | 1 (the tab names, 15 left, SLO6); SLO1–SLO5 answer a tap, see the door 7 table |
| Feeding (parenting) | 4 | 2 | – | 2 | 1 (allergen tracker persistence) |
| Health (parenting) | 6 | 3 | – | 3 | 1 (dosing table sign-off) |
| Development (parenting) | 4 | 1 | – | 3 | – (DV2 is a data job, logged) |
| Behaviour (parenting) | 23 | – (BH1–BH11 filled 2026-10-02, corrected 2026-10-26) | – | 6 | – (the tab name, BHO8, done 2026-10-26); BHO1–BHO7 answer a tap or wait on data, see the door 8 table |
| Potty (parenting) | 13 | – (PT1–PT4 written 2026-10-02) | – | 3 | – (PT7–PT13 answer a tap; see the door 5 table) |
| Early Learning (parenting) | 12 | – (EL1 filled 2026-10-26, EL2 2026-10-02) | – | 2 | – (the two tab names, ELO7, done 2026-10-26); ELO1–ELO6 answer a tap or wait on review, see the door 9 table |
| First 40 Days (parenting) | 18 | – (FF3–FF5 filled 2026-10-02) | – | 5 | 1 (the day spine, FF10); FF1–FF2 closed into You; FF12–FF18 answer a tap, see the door 6 table |
| You, Maa (parenting) | 6 | 2 | – | 3 | – |
| What to buy (parenting) | 10 | 8 | – | 2 | – (call 2: shelves owned as they are) |
| Traditions (parenting) | 13 | – (TR1–TR8 written 2026-10-02) | – | 2 | – (two sensitive pages, the user's phone read); TRO1–TRO3 wait on a film or the shop, see the door 10 table |
| Safety (parenting) | 4 | – | – | – | – ; SFO1–SFO4 answer a tap or link nothing, see the door 11 table |
| Coding (skilling) | 9 | 4 (33 slots: 12 lessons, 6 AI cards, 6 courses, 9 products, 1 note — the 36 activities are filled) | – | 2 (the consent adapter, the access rail) | 1 generic (resume marker — `SKILLING-DOOR-BUILD.md` §9) |
| Communication (skilling) | 10 | 5 (29 slots: 27 lessons, 12 courses, 12 products, 2 notes — the 36 activities are filled; the 11–14 twelve are repo-written copy owed a task-author review) | – | 1 (the voice keepsake) | 1 (cloud copy of recordings, behind a real consent) |
| Confidence (skilling) | 11 | 5 (36 slots: 18 lessons, 6 courses, 9 products, 2 notes, 1 coach — the 36 activities are filled) | – | 1 (the breath page) | 1 (the coach onboarded, then the booking wiring) |
| Thinking (skilling) | 11 | 8 (82 slots: 36 activities, 33 lessons, 4 courses, 9 products, 1 note) | – | 1 (the keepsake, renamed) | 1 (the one spotting-fake defence, authored with Coding) |
| Stillness (skilling) | 12 | 8 (73 slots: 36 practices, 24 sessions, 3 courses, 9 products, 1 note) | – | 2 (the settle breath, the keepsake with its invitation) | 1 (the borrowers — Focus, Feelings, Memory — pointing here, not rebuilding) |
| Feelings (skilling) | 14 | 8 (67 slots: 36 activities, 18 lessons, 3 courses, 9 products, 1 note — all marked for clinical review) | – | 3 (the calm window, the journal, the off-ramp) | 3 (legal review of child-private; key custody; the helplines verified) + 1 STOPPED (the crisis pathway, for the experts) |
| Making (skilling) | 10 | 8 (82 slots: 36 activities, 27 prompts, 6 courses, 12 products, 1 note) | – | 1 (the portfolio with photos and its private show mode) | – |

Pregnancy, six doors: written pieces owed, in prose — **S1, L3, L4, L5, L6,
M1**, six reads. Films — **N1, L1, L2, M4 ×3, M6 ×5**, eleven. Audio — **M5
×4**. One decision: N2. One confirmation: M3's numbers. Garbh Sanskar: all
twelve rows closed by the four pillars (2026-09-12); what remains there is
recordings by manifest entry.
Parenting's totals are its terminal's to keep.

### P3. Health — `lib/data/doors/pp_door_health.dart`

The brief says the [NEW] copy will be supplied for verbatim drop-in ("do not
AI-generate it; build the scaffolding"), so these are `comingSoon` cards that
hold their place and do not tap. `test/pp_health_door_test.dart` fails if a
coming-soon page is not in this table.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| HL1 | `health_choking_response` — If he chokes or can't breathe | Film · 5 min + steps | Built from data | Moved from Feeding (copy written there, REQUIRED_REVIEW); slot `feeding/back_blows_demo` still needs the film. Canonical here; Feeding's card opens it. |
| HL2 | `health_fit` — If he has a fit | Video / illustrated | Coming soon | Copy: on his side, nothing in the mouth, time it, ambulance-if. |
| HL3 | `health_accidents` — Common accidents, fast | Cards | Coming soon | Copy: swallowed something (button battery / magnet = go now), a burn, a bad fall or head bump, something in the eye. First minutes only. |
| HL4 | `ill_teething_fever` — Teething, and why it does not cause a high fever | Carousel | Coming soon | Copy: a short myth-vs-fact carousel. |
| HL5 | `fever_dosing` — Paracetamol and ibuprofen | Reframe | Built from data | The mg-by-weight table and the gaps card are in a comment. Restoring them needs paediatric + legal sign-off and a weight calculator the medical board owns. |
| HL6 | Thermometer routes / dehydration signs / rash grid | Illustration | Built from data | Drawn in code; artwork can replace each painter via `PpIllustration.asset`. The rash grid especially wants photographs ("this is HFMD"). |

### P4. Development — `lib/data/doors/pp_door_development.dart`

Built to `Development_Parenting.pdf` (the reissue of 31 Aug 2026, which
replaces `ParentVeda_Development_rebuild.pdf`). Almost everything was reuse,
reslot or merge; the owed pieces are one write and one data job.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| DV1 | `dev_feelings_activities` — Activities for feelings and getting on with others | Article | Coming soon | Copy: co-regulation, connection, face-to-face, naming-feelings play, matched to his age. "That corner of the app is blank today." Supplied for drop-in, not auto-written. |
| DV2 | The four areas of growing as "a closer look inside the tracker" | Data | **Built 2026-10-26 (R10)**; the "a milestone" painting has its slot and prompt (2026-10-26: `PvMoment.milestone` in `lib/screens/v2/pv_moment_paintings.dart`, prompt in `docs/MOMENT-PAINTING-PROMPTS.md`); the painting LANDED 2026-10-26 (`assets/moments/milestone.webp`), the child's phase painting kept as the fallback | **R10 made it one list:** `kMilestones` (37 with the three R10 added) is the identity; the phase snapshots (`kSnapshotMilestone`), the area stages (`kDevStageMilestone`) and the Development Map point at its ids, and every save is `openMilestoneSave`. Before: the brief assumes one milestone list behind the tracker and the area pages. There are two: `MilestoneStore` (34 milestones, not 18 as written here first; six domains) behind the tracker and `DevArea` skills (`pp_development_data.dart`) behind Brain / Physical / Language / Emotional. The join is a hand map (`_kAreaForDomain` in `milestone_journey_screen.dart`). Making them one dataset — so ticking a skill in either place updates both — is a data job: one list, one store, both screens reading it. |
| DV3 | `dev_tummy_time` — Tummy time without the tears | Film · 4 min | Built from data | Reformatted step-list > video; slot `development/tummy_time` needs the film. The steps stay under it. |
| DV4 | The "done together" activity films | Film | Built from data | Every activity page's video is a placeholder today. The brief: "the thing to actually shoot, the 'doing it together' activity clips first." Seven explainer films on the reads likewise (`development/*` slots). |

### P5. Behaviour — `lib/data/doors/pp_door_behaviour.dart`

Built to `Behaviour_Parenting.pdf` (31 Aug 2026). "The verdict is mostly add,
not cut": two new areas fill the section's missing half, and their copy "is
being written separately in the same house voice and will be dropped in. Do
not AI-generate placeholder copy." So eleven coming-soon cards hold their
places. `test/pp_behaviour_door_test.dart` fails if one is not in this table.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| BH1 | `beh_scared_everything` — Why he is suddenly scared of everything | Article | **Filled 2026-10-02** | Copy, house voice. |
| BH2 | `beh_fear_dark` — Fear of the dark, and the monster under the bed | Article | **Filled 2026-10-02** | Copy; cross-link Sleep's bedtime pages. |
| BH3 | `beh_fear_doctor` — The doctor, the injection, the haircut | Step-list | **Filled 2026-10-02** | Copy. |
| BH4 | `beh_fear_dogs` — Scared of dogs, lifts and loud noises | Short article | **Filled 2026-10-02** | Copy. |
| BH5 | `beh_shy_child` — The shy child, and "say hello, beta" | Article | **Filled 2026-10-02** | Copy. |
| BH6 | `beh_fear_worth_checking` — When fear or clinginess is worth checking | Flagged callout | **Filled 2026-10-02** | Copy; calm, routes to a person. |
| BH7 | `beh_thumb_sucking` — Thumb-sucking, and when to just leave it | Article | **Filled 2026-10-02** | Copy. |
| BH8 | `beh_head_banging` — Head-banging and rocking | Article | **Filled 2026-10-02** | Copy. |
| BH9 | `beh_breath_holding` — Breath-holding spells | Article + flagged callout | **Filled 2026-10-02** | Copy: "the reassurance parents need" plus the one doctor line. |
| BH10 | `beh_nail_biting` — Nail-biting and the other little habits | Short article | **Filled 2026-10-02** | Copy. |
| BH11 | `beh_self_touching` — Touching himself, and what to do about it | Article | **Filled 2026-10-02** | The brief's judgement call 3, included on the user's call (2026-09-13). Copy: normal, do not shame, redirect gently, when to actually mention it. |
| BH12 | `beh_calm_jar` — A calm jar | Film · 3 min | Built from data | Reformatted Activity > Video; slot `behaviour/calm_jar` needs the make-and-use film. Steps stay. |
| BH13 | `crying_too_much` — When the crying is too much | Interactive | Built from data | Rebuilt as the dark one-step-at-a-time story (Sleep's 3am pattern); the article is in a comment. Worth a clinical read of the eight screens. |
| BH14 | `beh_balloon_breathing` — Balloon breathing | Animation | Built from data | The shared breathing circle on a 3-in / 5-out pattern (`kPpBalloonBreath`). No asset owed. |
| BH15 | The fifteen films the brief marks (was "fourteen"; the calm jar, BH12, is the fifteenth) | Film | Built from data | Every `behaviour/*` slot is a placeholder: ziddi, tantrums, five steps, no-year, throwing, anger, screens ×2, calm corner, calm jar, filling the tank, no-hitting, big feelings, lying, crying curve. A tap says the film is being made (S8a). |

**Corrected by the door 8 build (2026-10-26):** BH1 to BH11 said "Coming soon", but their copy was written on 2026-10-02 (the parenting gap analysis) and every one renders. The rows stay as the record; the outcome is now "Filled".

**Added by the door 8 build (2026-10-26, `docs/pp-door-plans/08-behaviour.md` BH1 to BH8, §12).** Nothing here is a coming-soon card: every item answers a tap with a notice, or shows a drawn mark.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| BHO1 | `behaviour/door_intro` | Film · 30–45 s | Not slotted | S4: no chip until the film exists (BH8) |
| BHO2 | A painting for each Right now card (20 across the four bands) | Painting | Built from data | Each card shows a line icon on the door's rose tint until then (`kPpBehRightNowCards`) |
| BHO3 | Picture books about feelings, for `beh_name_the_feeling` (BH5) | Data | Not linked | The kids list has no feelings book worth naming: the one "Emotions" goal entry is a placeholder, "Emotions Candidate Book 203" (`kids_books_list.dart`). Worry and new-baby books are linked; feelings waits for a real title in the list |
| BHO4 | ~~A books screen, so `pp_books/Worry` and `pp_books/New sibling` open a shelf~~ | Screen | **Done 2026-10-26** (door 9 build) | `pp_books/<name>` opens `PpKidsBooksScreen`: the children's picture books on their own screen, that goal's chip chosen, every age, each book's age on its row (`ppKidsBooksScreenFor`, `pp_kids_books_shelf.dart`). The toasts are commented out. Shared with Potty's `pp_books/Potty` (PT13) |
| BHO5 | Calm-down items on the shop: feelings cards, a visual timer, a calm-down kit | Catalogue | Not linked | None is stocked, so no page links one (BH5). For the shop list |
| BHO6 | A behaviour class or course | Class | Not linked | None exists; nothing is linked or invented (BH5) |
| BHO7 | A real child psychologist on Find help | People | S8e | The He keeps doing this row and the closing card open "Our first experts are joining" until one joins (BH4) |
| BHO8 | ~~A shorter name for "Scared, shy or clingy"~~ | Name | **Done 2026-10-26** | The user's word: "Shy and clingy". Off `_kOwedShorterNames`; fits two lines at 1.0 and 1.3. SLO6 is now 17 names |

### P6. Potty — `lib/data/doors/pp_door_potty.dart`

Built to `Potty_Parenting.pdf`. "The content is lean and excellent, so this is
almost all adding, plus one important re-tagging. No real cuts." Four new
pieces as coming-soon cards, copy "written on your go"; one film.
`test/pp_potty_door_test.dart` fails if a coming-soon page is not here.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| PT1 | `no_star_charts` — Why there are no star charts here | Short article | Written 2026-10-02 | Brand-defining: the words to hold the line when the family is pushing stickers and sweets. Since door 5 (2026-10-25) it is the one source; three pages link to it. `REQUIRED_REVIEW`. |
| PT2 | `three_day_method` — The three-day method, done safely | Article | Written 2026-10-02 | Who it suits, the shape, and the one risk built in (a child who starts holding it in). Banded from 2 years (door 5, PT2). `REQUIRED_REVIEW`. |
| PT3 | `pull_ups` — Pull-ups, cloth pants or a chaddi? (was "Do pull-ups help or hurt?") | Cards | Written 2026-10-02, rewritten 2026-10-25 | Door 5 PT6: chaddi and towel, cloth trainer pants, pull-ups for nights and travel. `REQUIRED_REVIEW`. |
| PT4 | `taking_longer` — If it is taking your child a long time | Cards | Written 2026-10-02 | A calm pointer to Development and a paediatrician, now with a consult (door 5, PT5). `REQUIRED_REVIEW`. |
| PT5 | `indian_toilet` — The Indian toilet, and going out | Film · 6 min | Built from data | Slot `potty/indian_toilet`: the supported squat, the balance, the bucket-and-mug, front to back. "The clearest missing video in the section." The wiping page points here. |
| PT6 | The eight films the brief marks | Film | Built from data | Every `potty/*` slot is a placeholder: the timeline, cueing, readiness, the routine, the Indian toilet (PT5), accidents, the activities, dry nights. (Was "seven"; there are eight slots, corrected 2026-10-25.) |

**Added by the door 5 build (2026-10-25, `docs/pp-door-plans/05-potty.md` PT3 to PT7, §12).** Nothing here is a coming-soon card: every item answers a tap with a notice, or shows a drawn mark.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| PT7 | Three shelf demos: `potty/after_waking_sit`, `potty/hand_washing_low_tap`, `potty/seat_and_stool` | Film · 1–2 min | Slotted | On `after_waking_sit`, `wash_low_tap` and `introducing_potty`. A tap says the film is coming (S8a) |
| PT8 | `potty/door_intro` | Film · 30–45 s, AI scenes | Not slotted | S4: no chip until the film exists |
| PT9 | A painting for each of the 16 Try this today cards | Painting | Built from data | Each card shows a line icon on the activity tint until then (`_kPottyActivityIcons`) |
| PT10 | A "Potty and toilet" shop subcategory: potty, seat insert, step stool, travel potty, cloth trainer pants | Catalogue | S8c | `pp_products/Potties` and `pp_products/Travel potties` answer with the page's tip (`kPpShelfNotYet`). Also in `BEFORE-LAUNCH.md` |
| PT11 | A potty buying guide | Guide | S8c | `pp_product_guide/Potties`: "We haven't written the potty guide yet. What to check is on this page" (`kPpNotYetWords`) |
| PT12 | The short potty masterclass (one fortnight, step by step) | Class | S8d | `pp_class/potty_masterclass`: "This class isn't open yet. Tap Tell me". Its paid wording is commented out until it exists |
| PT13 | ~~A screen for the picture books (`kKidsBooks` has 9 potty books and no screen)~~ | Screen | **Done 2026-10-26** (door 9 build, BHO4) | `pp_books/Potty` opens the shelf on the list's "Potty Training" goal, all nine books, every age |

### P7. Early Learning — `lib/data/doors/pp_door_early_learning.dart`

Built to `Early_Learning_Parenting.pdf`. "Mostly an add and a re-front, not a
teardown." Two scaffolds; the big owed item is recording, not writing.
`test/pp_early_learning_door_test.dart` fails if a coming-soon page is not
here.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| EL1 | `rhymes_collection` — Rhymes and songs | Audio library | **Filled 2026-10-26** (door 9 build, EL3): "Rhymes to say together", ten rhymes written out with actions; the recording is ELO2 | A whole collection, audio-first like the stories: Hindi, English and regional action rhymes, original or public-domain only, never copyrighted lyrics. Pairs with "Clapping and dancing to a song". |
| EL2 | `skills_language` — English or the mother tongue, and when to start letters | Article | **Filled 2026-10-02**; now "Help him talk" (door 9 build, EL1) | The words to hold the line when the pressure to start ABCs at two starts. Copy supplied. |
| EL3 | The 58 story audios | Audio | Built from data | Every story has a "listen" button and no recording. "A story library with no narration is half-built, so recording the story audio is the first job." |
| EL4 | The 15 films | Film | Built from data | Every `early_learning/*` slot is a placeholder: tummy-time reach, pouring, spooning dal, the strokes before letters, brushing teeth, the Montessori corner, telling a story with no book, the six read-alouds, readiness, what comes before writing. Since the door 9 build every id has the one `early_learning/` prefix (seven were `learning/...`), and a tap says the film is being made (S8a) |

**Added by the door 9 build (2026-10-26, `docs/pp-door-plans/09-early-learning.md` EL1 to EL9, §12).** Nothing here is a coming-soon card: every item answers a tap with a notice, or waits on a review.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| ELO1 | `early_learning/door_intro` | Film · 30–45 s | Not slotted | S4: no chip until the film exists (EL9) |
| ELO2 | Recordings: the 58 stories and the rhymes page | Audio | S8a | A story row says "This story is still being recorded. You can read it aloud now; it works even better in your voice" (`kPpStoryAudioNote`); the rhymes row says the recording is being made. Demand is low (about 6 searches), so not now (EL3). The Hindi rhymes are in English letters, so the phone's hi-IN voice cannot read them meanwhile |
| ELO3 | An early learning class or course | Class | Not linked | None exists. The two "masterclass" cards and the section tool are now "Talk to an early learning expert" (EL7); nothing invents a class |
| ELO4 | A real early learning expert on Find help | People | S8e | Both "Early learning expert" profiles are seeded placeholders; the closing card, the two consult cards and the section tool open the roster until one joins |
| ELO5 | A dough activity and a puzzle activity, for EL7's one item a page | Content | Placed nearby | No activity page is about play dough or puzzles. Play dough sits on "What comes before writing" (whose hand step is kneading dough), puzzles on "Matching lids to their containers" (the same shape-and-size problem); crayons are on the prewriting activity as planned |
| ELO6 | The exact folk words of "Ek, do, teen, chaar" | Copy | Written plainly | The content file asked for the folk words to be checked at build. No version could be confirmed, so the card says the numbers one to ten on fingers, nothing invented. REQUIRED_REVIEW with the other rhymes |
| ELO7 | ~~Shorter names for "Do something today" and "Before letters and numbers"~~ | Name | **Done 2026-10-26** | The user's word: "Ideas for today" and "Letters, numbers". Off `_kOwedShorterNames`; SLO6 is now 15 names |

### P8. First 40 Days — `lib/data/doors/pp_door_first40.dart`

Built to `First_40_Days_Prompt.pdf`. "The built content is strong and dense,
so this is mostly adding, not cutting." Five scaffolds, one new film, one
drawn strip; the photographs for the skin slides.
`test/pp_first40_door_test.dart` fails if a coming-soon page is not here.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| ~~FF1~~ | `f40_breasts` — Your breasts in the early weeks | Window | Built from data | Opens You, Maa's "Sore, rock hard breasts" (YM3), on the You brief's consolidation. The cracked-nipples and blocked-duct copy is owed there. |
| ~~FF2~~ | `f40_pregnant_again` — When your body can get pregnant again | Window | Built from data | Opens You, Maa's "Sex, contraception, and the two of you", which already says it. |
| FF3 | `f40_small_or_early` — Bringing home a small or early baby | Article | Coming soon | Temperature, feeding, kangaroo care, when to worry. |
| FF4 | `f40_for_husband` — For your husband, in the first 40 days | Article | Coming soon | Guard the door, protect her rest and food, a night shift, skin to skin, watch her mood. |
| FF5 | `f40_ceremonies` — The ceremonies, and keeping him safe through them | Article | Coming soon | Chhati, naamkaran, the first outing: crowds, kissing his face, infection, when it is safe to go out. |
| FF6 | `f40_first_bath` — His first bath | Film · 5 min | Built from data | Slot `first40/first_bath`: the hold, the water, the five minutes. |
| FF7 | `f40_newborn_skin` — the illustrated carousel | Photographs | Built from data | Eight slides of text; the brief wants "a photo of each (milia, stork mark, the grey-blue patch, cradle cap, newborn acne)". The sticky-eye slide is one line written here, REQUIRED_REVIEW. |
| FF8 | `f40_nappy_poop` — the colour strip | Illustration | Built from data | Drawn in code (`poopColours`); artwork can replace via `PpIllustration.asset`. |
| FF9 | `f40_jaundice` — how far the yellow has spread | Illustration | Not built | "A small picture (face, chest, palms) would help; light touch." Not drawn yet. |
| FF10 | The day-by-day spine | Build | Not built | Judgement call 1: the real "you are on day 12" screen. Four fixed day-range pages stand in. See PARENTING-DOORS-REVIEW.md. |
| FF11 | The eleven films the brief marks | Film | Built from data | `first40/*` slots are placeholders; latch, malish, swaddle and settling now share Feeding's and Sleep's slots, so four fewer to shoot. |

**Added by the door 6 build (2026-10-25, `docs/pp-door-plans/06-first40.md` FD1 to FD9, §12).** Nothing here is a coming-soon card: every item answers a tap with a notice, or shows a drawn mark. (FF3 to FF5 above were filled 2026-10-02; the test holds that.)

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| FF12 | `first40/door_intro` | Film · 30–45 s | Not slotted | S4: no chip until the film exists |
| FF13 | `first40/recovery_basics`, "Your body in the first weeks" | Film · 9 min | Slotted | Back on Your recovery, on `f40_rest_and_food` (FD9). A tap says the film is being made (S8a). Reviewed by a gynaecologist or midwife |
| FF14 | The 13 newborn slots: `first40/welcome_intro`, `red_flags`, `cord_care`, `first_bath`, `jhula_demo`, `quick_check`, `common_questions`, `course_preview`, `essentials`, and the four shared with Feeding and Sleep | Film | Slotted | FD9: the baby-care demos are reviewed by a paediatric nurse or midwife before they ship |
| FF15 | Baby massage oil on the shop | Catalogue | S8c | `pp_products/Baby massage oils`: "We haven't picked oils yet. A plain, fragrance-free coconut or sunflower oil from your kitchen is fine" (`kPpShelfNotYet`). Traditions owes the same |
| FF16 | A plain cradle; a postpartum binder | Catalogue | S8c / partial | "A cradle or bassinet" opens the Smart Cribs and Bassinets shelf, mostly smart bassinets. `pp_products/Postpartum belts` says "Not in our shop yet. Ask your doctor first after a C-section" |
| FF17 | An underarm digital thermometer | Catalogue | S8c | `what_you_need` links it, as Health does; the stocked shelf is infrared forehead ones |
| FF18 | A painting for each of the 11 Try this today cards | Painting | Built from data | Each card shows a line icon on the Day by day tint until then (`_kFirst40CardIcons`) |

### P9. You, Maa — `lib/data/doors/pp_door_you_maa.dart`

Built to `You_Parenting_Maa_rebuild.pdf`. "Close to complete on content. The
real work is connecting the many links that currently go nowhere." Two
scaffolds; the owed work is the films and the breast-health copy the
consolidation now expects here. `test/pp_you_maa_door_test.dart` fails if a
coming-soon page is not here.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| YM1 | `body_your_sleep` — Getting sleep when she will not let you | Article | Coming soon | "The one real content gap": splitting the nights, one block of unbroken sleep, broken vs short sleep, the line where exhaustion needs the mind area. |
| YM2 | `body_thyroid` — Your thyroid after birth | Short article | Coming soon | Common, often missed, mimics depression and hair loss. A card the brief would accept; a page holds the place. |
| YM3 | `body_breasts` — Sore, rock hard breasts | Copy | Built from data | Judgement call 1: this is now THE breast-health page; First 40 Days' card and Feeding's mastitis flag open it. It covers engorgement and mastitis; cracked nipples and the blocked duct are owed here (First 40 Days' scaffold FF1 is closed into this row). |
| YM4 | The 11 feeling-films on the shelf | Film · ~55 min | Built from data | "The highest-value video set in the section: a mother needs to hear 'I feel nothing at all' said aloud by someone who has been there. Prioritise filming these." |
| YM5 | The remaining 20 film slots | Film / animation | Built from data | The five pelvic-floor exercises (and "finding the right muscle" as an animation of the internal muscle, not a filmed body), six movement sessions, six recipes, two work films, one for the frightening thoughts route. |
| YM6 | The recipes in the shared library | Data | Not done | The six healing-kitchen recipes should also be tagged postpartum in `pp_food`'s recipe library; today they are pages here that link to `pp_food`. **Door 3 (2026-10-25):** the four "food for you" links now open the healing-kitchen pages themselves, since `pp_food` is the baby's library (M4). The tagging is still owed. |

**Added by the door 3 build (2026-10-25, `docs/pp-door-plans/03-you-maa.md` §6, §7, §12).** Films (each slot shows the placeholder and answers a tap, S8a). All 31 older slots moved to the `you_maa/` prefix; their old ids are in comments beside them:

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| YM7 | `you_maa/demo_first_weeks` on `move_first_weeks` | Film · 4 min | Coming soon | Breathing, getting out of bed on her side, the first short walk. Slow, real mother, no gym clothes |
| YM8 | `you_maa/demo_diastasis_training` on `move_diastasis_training` | Film · 6 min | Coming soon | **Filmed or reviewed by a women's health physio.** The order of the exercises and what to stop |
| YM9 | `you_maa/demo_getting_stronger` on `move_getting_stronger` | Film · 10 min | Coming soon | A follow-along: squats, lifts, carries, with the baby nearby |
| YM10 | `you_maa/demo_pf_functional` on `pf_ex_functional` | Film · 4 min | Coming soon | **Filmed or reviewed by a pelvic-floor physio.** The brace before a lift, a cough, a carry |
| YM11 | `you_maa/demo_back_posture` on `body_back_posture` | Film · 4 min | Coming soon | Three changes to how she sits to feed, lifts and stands |
| YM12 | `you_maa/demo_wrist_neck` on `body_wrist_neck` | Film · 3 min | Coming soon | Holds that rest the thumb and wrist (de Quervain's), and the neck while feeding |
| YM13 | `you_maa/door_intro` | Film · 0:50 | Not built | A real perinatal counsellor or gynaecologist: "this door is about you". The chip waits for it (S4, GLOBAL-CHANGES #5) |

Products, people and a device the door would point at, not stocked or not real yet. The links that promised them were commented out (M8), so no tap reaches them today:

| # | Target | Where it would go | Today |
|---|---|---|---|
| YM14 | Shelves: postpartum belt or binder, sitz bath, silicone scar sheets, milk cooler bags, more nursing pads | body_perineum, body_csection_early, body_scar_care, body_diastasis, move_getting_stronger, work_milk_stash | Not linked. The pages explain each in their own words. When a shelf is stocked, uncomment its link and point it at the shelf (`pp_products/pvs_…`) |
| YM15 | A home BP monitor | `body_after_bp`, at the foot only, never beside the go-now cards | Not linked |
| YM16 | Real people: women's health physios, perinatal counsellors (each category has two `Expert.seeded` placeholders) | Moving and eating, Today and People expert rows; every physio and counsellor consult | "Our … are joining soon." with the free helpline on the counsellor line, and a pill to the gynaecologists (`kPpJoiningSoon`, S8) |
| YM17 | New categories: an adult postpartum nutritionist; a couples or family counsellor | `body_after_gdm` (nutritionist), the People row (couples) | The gynaecologist and the perinatal counsellors stand in. A category with nobody in it would put an empty need on Find help (`pp_consult_filter_test`) |

### P10. What to buy — the shop, not a door

Built to `What_to_buy_parenting.pdf`, which says in plain words: do not
rebuild, do not restructure, no tabs. So this is three link fixes, one
single-source, a soft age default, and eight placeholder guides. The rows
below are the placeholders; `test/pp_what_to_buy_test.dart` holds them.

| # | Guide (`product_guide_data.dart`) | Kind | Outcome | Owed |
|---|---|---|---|---|
| WB1 | `before_baby_essentials` — What you actually need, and what can wait | Guide | Coming soon | The single most searched buying question; the honest short list. |
| WB2 | `things_to_skip` — The things everyone buys that you can skip | Guide | Coming soon | The walker, the changing table, shoes before walking, the wipe warmer, baby powder, the top-and-tail set. |
| WB3 | `car_seat` — Infant Car Seat | Guide | Coming soon | The India version: never second-hand, rearward as long as possible. |
| WB4 | `cot_mattress` — Cot, mattress and safe sleep | Guide | Coming soon | Firm and flat; in a co-sleeping home, do you need a cot at all. |
| WB5 | `cloth_or_disposable` — Cloth or disposable, and the langot question | Guide | Coming soon | Money, environment, and where the langot still fits. |
| WB6 | `mosquito_protection` — Keeping mosquitoes off a baby, safely | Guide | Coming soon | Nets vs plug-ins vs patches, and the ages each is alright from. |
| WB7 | `second_hand` — Second-hand and hand-me-downs | Guide | Coming soon | The safety line: car seat, mattress, teats new; clothes, toys, cot frame fine. |
| WB8 | `season_born` — Buying for the season she is born in | Guide | Coming soon | Light: a summer baby vs a winter one. |
| WB9 | Four expert films on the nine guides | Film | Built from data | The card says "still being filmed" honestly; this is sponsored inventory, so a stub is a paid slot over nothing. |
| WB10 | Three "compare" links with no true shelf | Catalogue | Built from data | Nasal aspirators and cough-and-cold products land on First aid; malish oils on Lotions. Real shelves would make the links honest. |

**Added by the door 4 build (2026-10-25, `docs/pp-door-plans/04-development.md` D5, §12).** Nothing here is a coming-soon card: every item below answers a tap or shows a drawn mark today.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| DV1 | A painting for every activity in the merged pool | Painting | Built from data | The house painting pipeline (`pp_activity_paintings.dart`): drop `assets/activities/<id>.webp`, add the id to `kActivityPaintings`. Until then the Play today card and the Activities row show the area's line mark, never an empty frame |
| DV2 | Twelve demo films, 30 to 60 s: tummy time x2, reach and grasp, rolling help, sitting play, crawling games, cruising, first steps, pretend play, turn-taking talk, finger rhymes, stacking | Film | Not slotted | No slot is drawn until a film exists (S4). A paediatric physio reviews the movement films, a speech therapist the talking ones |
| DV3 | `development/door_intro` | Film | Not slotted | S4: no chip until the film exists |
| DV4 | A paediatric physio (expert category) | Expert | S8b | The Sit, crawl, walk row and `dev_movement_signs` say "We're adding paediatric physios. A paediatrician can check this first." with a pill |
| DV5 | Real developmental paediatricians (`Development expert` is placeholders only) | Expert | Joining soon | On track's row says they are joining and offers a paediatrician (`kPpJoiningSoon`) |
| DV6 | Times for the 102 phase-doc activities | Data | Shown without | Their cards read "MOVING", not "5 MIN · MOVING": the docs give no duration and none is invented. The doc owner adds them |
| ~~DV7~~ | ~~DV10's speech links: Special care's "Not talking yet" and "Speech therapy and the other therapies, explained" (SC2), Early learning's "Help him talk" (EL1)~~ | Link | **Closed 2026-10-27** (final review item 7, 574b99a): `dev_speech_flags` links Special care's `sc_therapies`, and `dev_help_talk` and `skills_language` link each other both ways. Was half done | **Early learning's half is in (door 9 build, 2026-10-26):** `dev_speech_by_age` and `dev_speech_flags` link `skills_language`. Special care's two wait for door 12 |

### P11. Traditions — `lib/data/doors/pp_door_traditions.dart`

Built to `Traditions_Parenting.pdf`. "The build for this one is unusually
finished, so most of the work below is the editorial." Eight placeholders,
one drawn illustration, and seventeen films none of which is shot.
`test/pp_traditions_door_test.dart` fails if a coming-soon page is not here.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| TR1 | `how_date_chosen` — How the date gets chosen, and what to do when it does not suit the baby | Article | Coming soon | The biggest gap: the panchang, the muhurat, the pandit, the birth-star, and the conversation when the date is wrong for the baby. |
| TR2 | `how_name_chosen` — How Indian families choose the name | Article | Coming soon | Rashi and nakshatra letters, gotra, numerology, and a name that survives school. Strengthens Find a name. |
| TR3 | `first_festivals` — The baby's first festivals, done safely | Cards | Coming soon | Its own small area (call 2). First Diwali, Holi, Eid, Christmas, Raksha Bandhan: diyas, cracker noise, colours on skin, fasting while nursing. |
| TR4 | `skip_it` — If you would rather not do a ceremony at all | Short article | Coming soon | Sensitive (call 1). Yes, it is alright; how to hold that line kindly. The user reads it before it ships. |
| TR5 | `someone_elses_ceremony` — Going to someone else's baby's ceremony | Cards | Coming soon | A light card: the gift, the shagun, what to wear, your own baby. |
| TR6 | `twins_adopted_second` — Twins, an adopted baby, or the second child | Cards | Coming soon | "There is no rule and no debt." |
| TR7 | `interfaith_far_from_home` — Interfaith families, and doing this far from home | Article | Coming soon | Two traditions in one house; no pandit, agiary or gurdwara nearby. |
| TR8 | `mother_kept_apart` — When the mother is kept apart | Article | Coming soon | The most sensitive (call 1): jaapa seclusion and the not-to-be-touched custom. Us-not-shame; tone signed off by the user before it ships. |
| TR9 | `newborn_customs` — the four visual customs | Illustration | Built from data | Drawn in code (`newbornCustoms`): the kajal dot on the sole, the bare cord, the frog-leg swaddle, the unbound head. Artwork can replace via `PpIllustration.asset`. |
| TR10 | Seventeen films, 88 minutes | Film | Built from data | In the order worth shooting: kajal-honey-cord (watch with a grandmother), jhula, mundan, annaprashan, karnavedha, tahneek; the ceremony walk-throughs after. A tap says the film is being made (S8a, held by the door 10 test). |

TR1 to TR8 were written 2026-10-02 (parenting gap analysis); `skip_it` and `mother_kept_apart` were approved as text 2026-10-25 with two changes, made in the door 10 build, and wait on the user's read on the phone (BEFORE-LAUNCH).

**Added by the door 10 build (2026-10-26, `docs/pp-door-plans/10-traditions.md` TR1 to TR6, "As built").** Nothing here is a coming-soon card.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| TRO1 | `traditions/door_intro` | Film · 30–45 s | Not slotted | S4: no chip until the film exists (TR6) |
| TRO2 | Baby massage oil on the shop | Catalogue | Not linked | The most searched item in this door (491 on massage and oil). Traditions links First 40's "Which massage oil?" instead of a shelf; the shelf notice is FF15's (`kPpShelfNotYet`) |
| TRO3 | A ceremony shelf (thali sets, silver spoon and bowl sets, ceremony outfits) | Catalogue | Links removed | Two links opened the whole shop and promised these; the catalogue has none, so both are commented out (TR4). Naamkaran keeps one link, to the clothes shelf. Add a shelf only if the shop decides to stock ceremony items |

### Safety (parenting), door 11

**Added by the door 11 build (2026-10-26, `docs/pp-door-plans/11-safety.md` SF1 to SF8, "As built").** Nothing here is a coming-soon card; every row answers a tap or links nothing. (The `SFO` ids are this door's; Skilling's Confidence rows above use `SF`.)

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| SFO1 | Films: `safety/child_cpr` on `safety_cpr` (child CPR, 3 min), and `safety/door_intro` | Film | Child CPR: built from data, a tap says the film is being made (S8a). Intro: not slotted (S4) | **Real people only**, by the CPR instructor, on a mannequin; never animated or AI-generated. The baby CPR film on the same page is Health's slot `health/infant_cpr` (HD4): one film, two places, shoot it once. Choking is Health's `feeding/back_blows_demo`, linked |
| SFO2 | Shop: baby gates, socket covers, corner guards, cabinet and drawer locks, child helmets; and forward-facing seats and boosters | Catalogue | Not linked | The catalogue has none. The pages say what to look for instead ("Sockets, boards and chargers", "What to look for in a gate"), with no dead link. The car seat page links the one stocked shelf, rear-facing seats (`pp_products/pvs_rear_facing_car_seats`), so an older child has no seat to buy yet |
| SFO3 | A first aid and CPR class | Class | "Tell me" | The class this door most needs. It is HD9's "Baby first aid and CPR": Health's Get help now ends on it, and now First aid does too (its tab closing). One class, two ways in |
| SFO4 | Line drawings: CPR hands for a baby (two fingers) and a child (heel of the hand); the choking holds (baby along the forearm, back blows) | Illustration | Not drawn | Until they exist the steps stay as numbered text. The choking drawing belongs on Health's `health_choking_response` too |

### Special care (parenting), door 12

**Added by the door 12 build (2026-10-26, `docs/pp-door-plans/12-special-care.md` SC1 to SC7, "As built").** Nothing here is a coming-soon card; every row answers a tap or links nothing. (The `SPO` ids are this door's; Skilling's Communication rows above use `SC`.)

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| SPO1 | Films: `special_care/speech_session` on `sc_therapies` ("What a speech therapy session looks like"), `special_care/kangaroo_care` on `sc_nicu` ("Kangaroo care in the NICU"), and `special_care/door_intro` | Film | The two: built from data, a tap says the film is being made (S8a). Intro: not slotted (S4) | **Real people only**: an RCI-registered speech therapist with a real child and parent in the room; a NICU nurse with a parent doing kangaroo care (with the family's consent for a NICU baby on film). The intro from a developmental paediatrician. Never animated or AI-generated |
| SPO2 | A real developmental paediatrician | Expert | "Joining" | `pp_experts/Development expert` is two `Expert.seeded` placeholders, so the Extra support row and the diagnosis-from-birth consult say "Our developmental paediatricians are joining soon" and offer a paediatrician (`kPpJoiningSoon`). The same category as Development's On track row (DV7) |
| SPO3 | Real speech therapists | Expert | Opens the speech therapist list | `pp_experts/Speech therapist` (the "Not talking yet" consult) opens its own filtered list. The three profiles there are not flagged seeded but are not signed people either; owed real RCI-registered therapists before launch, ideally ones who take a family's home programme seriously (the page's own test of a good one) |
| SPO4 | Real child psychologists | Expert | Opens the child psychologist list | `pp_experts/Child psychologist` (the attention page's consult) opens its own filtered list. The same owed people as Behaviour's BHO7 |
| SPO5 | A therapy shelf (picture cards, chewy tools, sensory toys) | Catalogue | Not promised | No page links a shop: the therapies page says to ask the centre for a home programme, which costs nothing. Add a shelf only if a therapist picks what goes on it |

### Family (parenting), door 13

**Added by the door 13 build (2026-10-26, `docs/pp-door-plans/13-family.md` FM1 to FM6, "As built").** Nothing here is a coming-soon card; every row answers a tap or links nothing. (`FMO` is this door's prefix; no Skilling door uses `FM`.)

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| FMO1 | The door intro film `family/door_intro` | Film | Not slotted (S4) | **Real people only**: a child psychologist, or a real family (an older child meeting the new baby, a father on the night shift), with consent. Never animated or AI-generated. Slot it on the door when it exists |
| FMO2 | Real child psychologists | Expert | Opens the child psychologist list | The door's closing card ("Talk to a child psychologist", `pp_experts/Child psychologist`) opens its own filtered list. The same owed people as Behaviour's BHO7 and Special care's SPO4: one set of people, three doors |

No book, shop or class is promised: the one book link is the kids shelf (`pp_books/New sibling`, ten books, built), and no page links a shop or a class.

### Papers and money (parenting), door 14

**Added by the door 14 build (2026-10-26, `docs/pp-door-plans/14-papers.md` PM1 to PM7, "As built").** Nothing here is a coming-soon card; every row answers a tap or links nothing. (`PMO` is this door's prefix; no other stage or Skilling door uses `PM`.)

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| PMO1 | The door intro film `papers/door_intro` | Film | Not slotted (S4) | **Real people only**: a parent at a municipal office or an Aadhaar centre with a baby, or someone who helps families with these forms (an anganwadi or ASHA worker), with consent. Never animated or AI-generated. Slot it on the door when it exists |
| PMO2 | A closer hero photo | Photo | Built with a stand-in (a child on an elder's lap at home, Unsplash `awkngZALcVw`) | The plan's picture: a parent at a table with a folder of papers and a baby on their lap. Unsplash's free search found only a tablet advert, a dark desk and passports with no family. Commission or license one, Indian, warm, no brand or screen in frame |

No adviser, product or class is promised: the pages send her to a fee-only adviser, her insurer or the TPA, and the government offices, none of which the app sells. The vault (`pp_baby_documents`) and the Aadhaar reminder are built.

---

## Skilling

Built in its own terminal, on its own shell (`lib/screens/skilling/doors/`,
`lib/data/doors/sk_door_*.dart`, content in `lib/data/skilling/`). Every
skill brief has two halves — a STRUCTURE PDF that says "placeholders only,
do not author lesson, activity, course or product copy", and per-band TASK
PDFs ("Task N of 36") that supply the real activities verbatim — so a
skilling door's rows are of a kind the other stages do not have: **whole
sets of slots that a named task PDF will fill.** A row here closes when the
task is mapped in; the ids are the ids the fill takes over, so nothing on
the rail moves. `test/sk_doors_sanity_test.dart` fails if a coming-soon slot
on any skill door is not here.

Rows carry an `S` prefix per door: S1… for Coding, then the next door's
letters after it.

**Door intro videos (2026-10-25, GLOBAL-CHANGES #5).** Every skilling door's
header now shows "How this door works" with a Coming soon tag; a tap says the
video is being made. One film per built door is owed, slot `<door>/door_intro`:
**S-V1** Coding, **S-V2** Communication, **S-V3** Confidence, **S-V4** Thinking,
**S-V5** Stillness, **S-V6** Feelings (clinical review first, like the door's
content), **S-V7** Making. Who is on camera (AI scenes, a real teacher, or
both) is the user's call per `video-plan-rules`. When a film lands, the door
passes its length and player to `PvDoorIntroChip` and the tag becomes "0:50".

### S. Coding & AI literacy — `lib/data/doors/sk_door_coding.dart`

Built to `ParentVeda_Coding_structure_v2.pdf` (11 Sep 2026), the first
skill door and the one that lays the shell. Every slot below is a real card
at full size, "Coming soon", no tap.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| S1 | The Unplugged activity set, 6 to 8 — `cd_68_01` … `cd_68_12` (`cd_68_01`, `cd_68_02`, `cd_68_03`, `cd_68_04`, `cd_68_05`, `cd_68_06`, `cd_68_07`, `cd_68_08`, `cd_68_09`, `cd_68_10`, `cd_68_11`, `cd_68_12`) | Activity ×12 | Coming soon | **The fill exists:** `tasks/coding/ParentVeda Coding 6-8 activities prompt Coding Age Bracket 1.pdf`, twelve activities, two per thinking skill, mapped verbatim into `SkActivity` in the next pass. Slots are ordered sequencing ×2, pattern ×2, debugging ×2, decomposition ×2, logic ×2, persistence ×2 — the task's own order. |
| S2 | ~~The Blocks activity set, 8 to 11 — `cd_811_01` … `cd_811_12` (`cd_811_01`, `cd_811_02`, `cd_811_03`, `cd_811_04`, `cd_811_05`, `cd_811_06`, `cd_811_07`, `cd_811_08`, `cd_811_09`, `cd_811_10`, `cd_811_11`, `cd_811_12`)~~ | Activity ×12 | **Filled** | Closed 2026-09-14, the fill commit: all twelve mapped verbatim. The **access rail** the task asked for is built (S9). One builder note inside activity 12's parent line ("point to the Stillness door") was dropped from the copy and is an owed cross-link (review file). |
| S3 | ~~The Projects activity set, 11 to 14 — `cd_1114_01` … `cd_1114_12` (`cd_1114_01`, `cd_1114_02`, `cd_1114_03`, `cd_1114_04`, `cd_1114_05`, `cd_1114_06`, `cd_1114_07`, `cd_1114_08`, `cd_1114_09`, `cd_1114_10`, `cd_1114_11`, `cd_1114_12`)~~ | Activity ×12 | **Filled** | Closed 2026-09-14, the fill commit: all twelve mapped verbatim. Two AI-literacy projects carry `withGrownUp`; seven that span sittings carry `multiSession`. The **resume marker** the task asks to flag is flagged, not built (`SKILLING-DOOR-BUILD.md` §9). "Make a Quiz Game" says score by the task's own rule (the game keeps its players' points) and is the one allow-listed id. |
| S4 | The lesson library — Unplugged `cd_unp_l1`–`cd_unp_l4`, Blocks `cd_blk_l1`–`cd_blk_l4`, Projects `cd_prj_l1`–`cd_prj_l4` (`cd_unp_l1`, `cd_unp_l2`, `cd_unp_l3`, `cd_unp_l4`, `cd_blk_l1`, `cd_blk_l2`, `cd_blk_l3`, `cd_blk_l4`, `cd_prj_l1`, `cd_prj_l2`, `cd_prj_l3`, `cd_prj_l4`) and the AI set `cd_ai_68_1`, `cd_ai_68_2`, `cd_ai_811_1`, `cd_ai_811_2`, `cd_ai_1114_1`, `cd_ai_1114_2` | Lesson ×12, Article ×6 | Coming soon | No task PDF yet. The structure brief: "the actual lessons … the AI cards … are job two, the writing and sourcing, done band by band." Four per set and two AI cards per band are the scaffold's shape, not a count the brief gave. |
| S5 | The course shelf — `cd_course_68_live`, `cd_course_68_rec`, `cd_course_811_live`, `cd_course_811_rec`, `cd_course_1114_live`, `cd_course_1114_rec` | Course ×6 | Coming soon | Real programmes, one live and one recorded per level. Placeholder prices (₹2,999 / $36 live; ₹999 / $12 recorded) are display only; money is server-side. Enrol is a stub sheet until the booking engine is wired (the user's call, question 7). Every entry carries `noOutcomeClaims`. |
| S6 | The product shelf — `cd_prod_68_kit`, `cd_prod_68_robot`, `cd_prod_68_book`, `cd_prod_811_kit`, `cd_prod_811_robot`, `cd_prod_811_book`, `cd_prod_1114_kit`, `cd_prod_1114_robot`, `cd_prod_1114_book` | Product ×9 | Coming soon | Real, sourced kits, robotics sets and books per band. Skilling's own shelf (question 6); the product engines are to be unified in one later pass, and this list is that pass's input. |
| S7 | `cd_parent_note` — For the grown-up: why it helps her thinking, and how to help | Parent note | Coming soon | The authored half of the note. The built half — "what she has been doing" — already draws from the keepsake in words. |
| S9 | The access rail — the free tools per band, `kSkCodingAccess` | Rail (gated) | Built from data | Task 2's "build once, parent-gated, reused by all 12", extended by task 3: ScratchJr, Scratch offline, code.org, Blockly Games (8–11); Scratch, Python turtle, Machine Learning for Kids, a supervised AI tool (11–14). Links open behind the grown-up gate. Owed: nothing — unless a tool's URL moves. |
| S8 | Consent verification | Adapter | Built from data | `SkConsentVerifier` is an interface with a stub that passes and says so. The real adapter (DigiLocker or equivalent) waits on legal review. Not a card; listed so it is worked through with the rest. |

### SC. Communication & articulation — `lib/data/doors/sk_door_communication.dart`

Built to `ParentVeda_Communication_structure.pdf` (11 Sep 2026), door two,
on 2026-09-15. Frame only, on the brief's own instruction ("new copy stays
unwritten until you say go"). Rows carry `SC`.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| SC1 | ~~Say it out loud, 6 to 8 — `cm_68_01` … `cm_68_12` (`cm_68_01`, `cm_68_02`, `cm_68_03`, `cm_68_04`, `cm_68_05`, `cm_68_06`, `cm_68_07`, `cm_68_08`, `cm_68_09`, `cm_68_10`, `cm_68_11`, `cm_68_12`)~~ | Activity ×12 | **Filled** | Closed 2026-09-15, the fill commit: all twelve mapped verbatim from Task 7 of 36. `offersRecording` on Tell Me What Happened and Once Upon a Time. |
| SC2 | ~~Tell it and explain it, 8 to 11 — `cm_811_01` … `cm_811_12` (`cm_811_01`, `cm_811_02`, `cm_811_03`, `cm_811_04`, `cm_811_05`, `cm_811_06`, `cm_811_07`, `cm_811_08`, `cm_811_09`, `cm_811_10`, `cm_811_11`, `cm_811_12`)~~ | Activity ×12 | **Filled** | Closed 2026-09-15, the fill commit: all twelve mapped verbatim from Task 8 of 36. `offersRecording` on Retell the Movie and Make It Exciting. |
| SC3 | ~~Say what you think, 11 to 14 — `cm_1114_01` … `cm_1114_12` (`cm_1114_01`, `cm_1114_02`, `cm_1114_03`, `cm_1114_04`, `cm_1114_05`, `cm_1114_06`, `cm_1114_07`, `cm_1114_08`, `cm_1114_09`, `cm_1114_10`, `cm_1114_11`, `cm_1114_12`)~~ | Activity ×12 | **Filled** | Closed 2026-09-17: no task PDF existed, so on the user's instruction the task was **written by Claude Code, not by the task author** — `tasks/communication/ParentVeda Communication 11-14 activities prompt.pdf` (the editable `.md` beside it), in Tasks 7 and 8's shape and rules — and the Dart generated from it verbatim. **The first activity copy authored by Claude Code rather than received; owed a review by whoever writes the tasks.** `offersRecording` on Tell It So It Lands and Short Version, Long Version. |
| SC4 | The lesson library — speaking prompts, story frames, describe-it and explain-it; three per band per set (`cm_prm_68_1`, `cm_prm_68_2`, `cm_prm_68_3`, `cm_prm_811_1`, `cm_prm_811_2`, `cm_prm_811_3`, `cm_prm_1114_1`, `cm_prm_1114_2`, `cm_prm_1114_3`, `cm_stf_68_1`, `cm_stf_68_2`, `cm_stf_68_3`, `cm_stf_811_1`, `cm_stf_811_2`, `cm_stf_811_3`, `cm_stf_1114_1`, `cm_stf_1114_2`, `cm_stf_1114_3`, `cm_dex_68_1`, `cm_dex_68_2`, `cm_dex_68_3`, `cm_dex_811_1`, `cm_dex_811_2`, `cm_dex_811_3`, `cm_dex_1114_1`, `cm_dex_1114_2`, `cm_dex_1114_3`) | Lesson ×27 | Coming soon | No task PDF. The brief: "prompt, story and describe-or-explain sets per band, each tied to one of the six skills. Works in her own language and in English, mother tongue first." Three per band per set is the scaffold's count. |
| SC5 | The course shelf — the brief's three per level plus "Speaking in English, too" (`cm_course_68_expression`, `cm_course_68_storytelling`, `cm_course_68_speaking_up`, `cm_course_68_english`, `cm_course_811_expression`, `cm_course_811_storytelling`, `cm_course_811_speaking_up`, `cm_course_811_english`, `cm_course_1114_expression`, `cm_course_1114_storytelling`, `cm_course_1114_speaking_up`, `cm_course_1114_english`) | Course ×12 | Coming soon | Real programmes. The English slot is the user's call (question 4, a): serves the demand, sells no fluency; every string under the no-outcome scan. Placeholder prices ₹2,999 / $36 live, ₹999 / $12 recorded. |
| SC6 | The product shelf — a story deck, a picture book, a conversation game, a puppet per band (`cm_prod_68_deck`, `cm_prod_68_book`, `cm_prod_68_game`, `cm_prod_68_puppet`, `cm_prod_811_deck`, `cm_prod_811_book`, `cm_prod_811_game`, `cm_prod_811_puppet`, `cm_prod_1114_deck`, `cm_prod_1114_book`, `cm_prod_1114_game`, `cm_prod_1114_puppet`) | Product ×12 | Coming soon | Real, sourced items. Skilling's own shelf (question 5, a); the shop unification later takes this list. |
| SC7 | `cm_parent_note` — For the grown-up: why saying what you mean is a real skill | Parent note | Coming soon | The authored half; the keepsake's words already draw. |
| SC8 | `cm_boundary_note` — If speech itself is the worry | Parent note | Coming soon | The brief's held call: one honest line to a speech professional, never a course, never a "fix her speech" product. The card stands on the grown-up screen; the line is unwritten. |
| SC9 | "Your voice, saved" — the recorder and the clips | Keepsake | Built from data | On this phone only (`sk_voice_keepsake.dart`). **Off by default** (the tasks' rule): a parent turns it on under For the grown-up (`SkChildStore.voiceAllowed`), and the record row shows only on the four `offersRecording` activities. **Owed, for the day the consent adapter is real:** a cloud copy behind a separate consent line — child-scoped bucket, RLS, retention, a delete that deletes. `BACKEND-PATTERNS.md` §16a. |
| SC10 | Cross-links to Confidence, Reading and Feelings | Windows | Owed | Those doors do not exist; the brief's "cross-link, do not duplicate" becomes `sk_page/<door>/<page>` windows when each lands. Review file, cross-door table. |

### SF. Confidence & public speaking — `lib/data/doors/sk_door_confidence.dart`

Built to `ParentVeda_Confidence_structure.pdf` (11 Sep 2026), door three,
on 2026-09-16; the three activity bands filled from Tasks 4, 5 and 6 of 36
on 2026-09-17. Rows carry `SF`.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| SF1 | ~~Use your voice, 6 to 8 — (`cf_68_01`, `cf_68_02`, `cf_68_03`, `cf_68_04`, `cf_68_05`, `cf_68_06`, `cf_68_07`, `cf_68_08`, `cf_68_09`, `cf_68_10`, `cf_68_11`, `cf_68_12`)~~ | Activity ×12 | **Filled** | Closed 2026-09-17, the fill commit: all twelve mapped verbatim from Task 4 of 36. `offersRecording` on Loud and Proud Name, Show and Tell at Home, Your Own Way; Butterflies Breath opens `cf_breath`. |
| SF2 | ~~Stand up and say it, 8 to 11 — (`cf_811_01`, `cf_811_02`, `cf_811_03`, `cf_811_04`, `cf_811_05`, `cf_811_06`, `cf_811_07`, `cf_811_08`, `cf_811_09`, `cf_811_10`, `cf_811_11`, `cf_811_12`)~~ | Activity ×12 | **Filled** | Closed 2026-09-17, the fill commit: all twelve mapped verbatim from Task 5 of 36. `offersRecording` on Answer in Class, Two-Minute Talk, Read it Out Loud; Your Calm-Down Routine opens `cf_breath`. |
| SF3 | ~~Give a real talk, 11 to 14 — (`cf_1114_01`, `cf_1114_02`, `cf_1114_03`, `cf_1114_04`, `cf_1114_05`, `cf_1114_06`, `cf_1114_07`, `cf_1114_08`, `cf_1114_09`, `cf_1114_10`, `cf_1114_11`, `cf_1114_12`)~~ | Activity ×12 | **Filled** | Closed 2026-09-17, the fill commit: all twelve mapped verbatim from Task 6 of 36. `offersRecording` on Give the Real Talk; The Big-Day Routine opens `cf_breath`. Two things the task names that do not exist, listed not built: the Thinking door's "question ideas, not elders" line (Speak Up to a Grown-Up cross-links to it) and "the door's help line" (After a Rough One) — the door's nearest thing is the parent-facing boundary note, SF8. |
| SF4 | The lesson sets — speaking prompts and stage exercises, three per band per set (`cf_prm_68_1`, `cf_prm_68_2`, `cf_prm_68_3`, `cf_prm_811_1`, `cf_prm_811_2`, `cf_prm_811_3`, `cf_prm_1114_1`, `cf_prm_1114_2`, `cf_prm_1114_3`, `cf_stg_68_1`, `cf_stg_68_2`, `cf_stg_68_3`, `cf_stg_811_1`, `cf_stg_811_2`, `cf_stg_811_3`, `cf_stg_1114_1`, `cf_stg_1114_2`, `cf_stg_1114_3`) | Lesson ×18 | Coming soon | No task PDF. "Prompt and stage-exercise sets per band, each tied to one of the six skills. Small low-stakes turns first, a real talk last." The one built page in the set is `cf_breath` (SF9). |
| SF5 | The course shelf — with a coach (live) and at her own pace (recorded), per level (`cf_course_68_live`, `cf_course_68_rec`, `cf_course_811_live`, `cf_course_811_rec`, `cf_course_1114_live`, `cf_course_1114_rec`) | Course ×6 | Coming soon | Real programmes with a real coach. Placeholders behind the gate (question 1a); the booking engine is the named next pass. Every string under the no-outcome scan: no "confident child", no rank. |
| SF6 | The product shelf — a toy mic, prompt cards, a little stage timer, per band (`cf_prod_68_mic`, `cf_prod_68_cards`, `cf_prod_68_timer`, `cf_prod_811_mic`, `cf_prod_811_cards`, `cf_prod_811_timer`, `cf_prod_1114_mic`, `cf_prod_1114_cards`, `cf_prod_1114_timer`) | Product ×9 | Coming soon | Real, sourced items. Skilling's own shelf; the timer is a prop she holds, never something the app reads. |
| SF7 | `cf_parent_note` — For the grown-up: why daring to speak is a real skill, and why a quiet child is not a problem to fix | Parent note | Coming soon | The authored half. |
| SF8 | `cf_boundary_note` — If it is more than shyness | Parent note | Coming soon | The brief's held boundary: a real fear of speaking or a stammer is not a confidence gap and not a course. One honest line to a professional, unwritten; its card stands on the grown-up screen. |
| SF9 | `cf_breath` — Steady your nerves | Tool | Built from data | The one built lesson: the app's one breathing circle (`PvBreathingCircle`, in for three, out for five) as an `SkBreath` block. The brief: "Confidence references that breath for the moment before you speak, it does not build its own." Copy on the page is two lines of mine — say if it should wait for the fill. |
| SF10 | `cf_coach` — A speaking coach, one to one | Consult | Coming soon | The brief's un-held Consult: a placeholder row under the classes (question 2a), stub sheet on tap, ₹799 / $10 placeholder. **Owed:** a real coach onboarded, then the row wired to `lib/booking/` as a 1:1 Offering (capacity 1) — the named next pass. |
| SF11 | Cross-links to Communication, Stillness and Feelings | Windows | Owed | Communication exists (`sk_page/skilling_communication/…` when its lessons are filled); Stillness and Feelings do not. Review file, cross-door table. |

### ST. Critical thinking & first principles — `lib/data/doors/sk_door_thinking.dart`

Built to `ParentVeda_Thinking_structure.pdf`, door four, on 2026-09-17, on
the user's calls 1a (the careful framing), 2a (spotting-fake as a headline
strand), 3a (a "Just for fun" set for the extras reshape). Frame only.
Rows carry `ST`.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| ST1 | Ask lots of whys, 6 to 8 — (`th_68_01`, `th_68_02`, `th_68_03`, `th_68_04`, `th_68_05`, `th_68_06`, `th_68_07`, `th_68_08`, `th_68_09`, `th_68_10`, `th_68_11`, `th_68_12`) | Activity ×12 | Coming soon | No task PDF yet. "Riddles, guessing games, why-is-the-sky questions, and the first 'is this real or pretend?'." Two per move in the door's move order. |
| ST2 | Work out how it works, 8 to 11 — (`th_811_01`, `th_811_02`, `th_811_03`, `th_811_04`, `th_811_05`, `th_811_06`, `th_811_07`, `th_811_08`, `th_811_09`, `th_811_10`, `th_811_11`, `th_811_12`) | Activity ×12 | Coming soon | No task PDF yet. "Reasoning puzzles, why-chains, breaking a thing down, and spotting a silly or too-good-to-be-true claim." |
| ST3 | Think for yourself, 11 to 14 — (`th_1114_01`, `th_1114_02`, `th_1114_03`, `th_1114_04`, `th_1114_05`, `th_1114_06`, `th_1114_07`, `th_1114_08`, `th_1114_09`, `th_1114_10`, `th_1114_11`, `th_1114_12`) | Activity ×12 | Coming soon | No task PDF yet. "Checking if something is true, seeing the other side, light debate, and the real skill: changing your mind." |
| ST4 | The lesson sets — puzzles, why-chains, and "Is this true?", three per band per set (`th_pzl_68_1`, `th_pzl_68_2`, `th_pzl_68_3`, `th_pzl_811_1`, `th_pzl_811_2`, `th_pzl_811_3`, `th_pzl_1114_1`, `th_pzl_1114_2`, `th_pzl_1114_3`, `th_why_68_1`, `th_why_68_2`, `th_why_68_3`, `th_why_811_1`, `th_why_811_2`, `th_why_811_3`, `th_why_1114_1`, `th_why_1114_2`, `th_why_1114_3`, `th_tru_68_1`, `th_tru_68_2`, `th_tru_68_3`, `th_tru_811_1`, `th_tru_811_2`, `th_tru_811_3`, `th_tru_1114_1`, `th_tru_1114_2`, `th_tru_1114_3`) | Lesson ×27 | Coming soon | No task PDF. "Puzzles, why-chains, reasoning and light debate per band, on real content not abstract drills." A logic puzzle lives here; a number puzzle is Maths's. **The "Is this true?" strand is the door's headline piece (2a)** and is built once with Coding: it owns the reasoning (is this true, who says so, how would I know); Coding's AI literacy (`cd_ai_*`, itself coming soon) owns the mechanism. The page that links across is authored when both halves exist — the cross-link slot, as the brief's prompt says. |
| ST5 | "Just for fun" — a riddle and a friendly debate per band (`th_fun_68_1`, `th_fun_68_2`, `th_fun_811_1`, `th_fun_811_2`, `th_fun_1114_1`, `th_fun_1114_2`) | Lesson ×6 | Coming soon | The extras reshape (3a): "Challenges become optional fun (a riddle, a friendly debate)." Optional; nothing counts; no streak. |
| ST6 | The course shelf — reasoning classes per level, light debate for the top band (`th_course_68_reasoning`, `th_course_811_reasoning`, `th_course_1114_reasoning`, `th_course_1114_debate`) | Course ×4 | Coming soon | Real programmes. Placeholders behind the gate at ₹2499 / $30; every string under the no-outcome scan — nothing says "critical thinker", "smarter" or "sharper". The brief's guardrail: it teaches reasoning on what is in front of her, never a general upgrade. |
| ST7 | The product shelf — a puzzle book, a logic game, brain-teaser cards, per band (`th_prod_68_book`, `th_prod_68_game`, `th_prod_68_cards`, `th_prod_811_book`, `th_prod_811_game`, `th_prod_811_cards`, `th_prod_1114_book`, `th_prod_1114_game`, `th_prod_1114_cards`) | Product ×9 | Coming soon | Real, sourced items. Skilling's own shelf; optional, never a gate. |
| ST8 | `th_parent_note` — How to raise a questioner without raising an arguer | Parent note | Coming soon | The brief's own title. The authored half: enjoying being wrong, the good question over the right answer, and questioning an idea versus respecting a person kept as two different things. |
| ST9 | "You kept thinking" — the keepsake | Keepsake | Built from data | The shared no-score keepsake under this door's name (`SkDoorContent.keepsakeTitle`), which is what the extras reshape says: "The certificate becomes a 'you kept thinking' keepsake." The progress report is dropped. The rubric tracker is refused into it. Nothing owed. |
| ST10 | Cross-links to Coding, Maths and Communication | Windows | Owed | Coding (AI literacy — the other half of the one defence; and breaking-down as computational thinking) exists with its AI pages coming soon; Maths does not exist; Communication exists (light debate: it says the point, this door reasons it). Review file, cross-door table. |
| ST11 | A reasoning or debate coach | Consult | Held | "Rarely. Held." No row on the door. |

### SL. Meditation, yoga & mindfulness — `lib/data/doors/sk_door_stillness.dart`

Built to `ParentVeda_Stillness_structure.pdf`, door five, on 2026-09-17, on
the user's calls 1a (the streak refused, on the record), 2a (engines
reused, sessions kid-authored), 3a (the invitation as one line on the
keepsake, never a notification), 4a (the settle breath built as the
source). Frame only. Rows carry `SL`.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| SL1 | Breathe and wiggle, 6 to 8 — (`sl_68_01`, `sl_68_02`, `sl_68_03`, `sl_68_04`, `sl_68_05`, `sl_68_06`, `sl_68_07`, `sl_68_08`, `sl_68_09`, `sl_68_10`, `sl_68_11`, `sl_68_12`) | Practice ×12 | Coming soon | No task PDF yet. "Tiny playful breath games and animal poses, a minute or two. Movement first, then a moment of quiet." Two per practice in the door's order. Every session ends on a soft line, never a score. |
| SL2 | Sit and settle, 8 to 11 — (`sl_811_01`, `sl_811_02`, `sl_811_03`, `sl_811_04`, `sl_811_05`, `sl_811_06`, `sl_811_07`, `sl_811_08`, `sl_811_09`, `sl_811_10`, `sl_811_11`, `sl_811_12`) | Practice ×12 | Coming soon | No task PDF yet. "Short guided sits, noticing, simple yoga, and a real way to calm down when wound up." |
| SL3 | Find your calm, 11 to 14 — (`sl_1114_01`, `sl_1114_02`, `sl_1114_03`, `sl_1114_04`, `sl_1114_05`, `sl_1114_06`, `sl_1114_07`, `sl_1114_08`, `sl_1114_09`, `sl_1114_10`, `sl_1114_11`, `sl_1114_12`) | Practice ×12 | Coming soon | No task PDF yet. "Longer practices, yoga, and using stillness for stress, sleep and the harder days of the pre-teen years." |
| SL4 | Guided sits, three per band — KID-NATIVE (`sl_sit_68_1`, `sl_sit_68_2`, `sl_sit_68_3`, `sl_sit_811_1`, `sl_sit_811_2`, `sl_sit_811_3`, `sl_sit_1114_1`, `sl_sit_1114_2`, `sl_sit_1114_3`) | Session ×9 | Coming soon | Written for a child (2a): "adult and pregnancy meditation adapted lazily fails a child, who needs short, playful, movement-first practices, not a ten-minute sit." Run on the app's one audio player when they exist. |
| SL5 | Gentle moving, three per band, and Resting, two per band — ADAPT (`sl_mov_68_1`, `sl_mov_68_2`, `sl_mov_68_3`, `sl_mov_811_1`, `sl_mov_811_2`, `sl_mov_811_3`, `sl_mov_1114_1`, `sl_mov_1114_2`, `sl_mov_1114_3`, `sl_rst_68_1`, `sl_rst_68_2`, `sl_rst_811_1`, `sl_rst_811_2`, `sl_rst_1114_1`, `sl_rst_1114_2`) | Session ×15 | Coming soon | Adapted (2a) from what the app already has: Garbh Sanskar's yoga as animal poses and short stretches; the Kriya body-scan (`lib/data/kriya_relaxation_data.dart`) re-timed and re-voiced for a child. The card says "Adapted". |
| SL6 | The course shelf — a longer guided series per level (`sl_course_68_series`, `sl_course_811_series`, `sl_course_1114_series`) | Course ×3 | Coming soon | Real recordings. Placeholders behind the gate at ₹699 / $8; recorded only, "small, reuse-first"; every string under the no-outcome scan — nothing says "calmer child", "cures", "anxiety", "focus" or "sleep better". |
| SL7 | The product shelf — a cushion, a kids' mat, calm cards, per band (`sl_prod_68_cushion`, `sl_prod_68_mat`, `sl_prod_68_cards`, `sl_prod_811_cushion`, `sl_prod_811_mat`, `sl_prod_811_cards`, `sl_prod_1114_cushion`, `sl_prod_1114_mat`, `sl_prod_1114_cards`) | Product ×9 | Coming soon | Real, sourced items. Skilling's own shelf; optional, never a gate. |
| SL8 | `sl_parent_note` — How stillness helps, without over-selling it | Parent note | Coming soon | The brief's own title. The authored half: a practice, not a treatment; why there is no streak, on purpose; where real distress goes instead (the emotional doors and a professional). |
| SL9 | `sl_settle` — Settle | Practice | Built from data | The one built page (4a): the app's one breathing circle in an `SkBreath` block with the brief's own line under it. **The source** Focus, Feelings and Memory reference; Confidence's `cf_breath` already borrows it. Nothing owed. |
| SL10 | "Quiet moments taken" — the keepsake and the invitation | Keepsake | Built from data | The shared no-score keepsake under this door's name, with one gentle line ("Want to sit again? … no chain to keep and no day to miss") — the brief's reshape of the streak, and the user's decision on the record (1a). Two shell slots for it (`keepsakeTitle` from Thinking, `keepsakeInvite` new). Nothing owed. |
| SL11 | Cross-links to Focus, Feelings and Memory (borrowers) and Confidence (already borrowing) | Windows | Owed | Focus, Feelings, Memory do not exist; when they do, they reference `sk_page/skilling_stillness/sl_settle` and the calming/resting sessions, never their own. Confidence's `cf_breath` is the same circle today; whether it becomes a window onto `sl_settle` is a review-list call. |
| SL12 | A kids' yoga or meditation teacher | Consult | Held | "Rarely. Held. Real distress is not a meditation gap." No row. |

### FE. Emotional intelligence & resilience — `lib/data/doors/sk_door_feelings.dart`

Built to `ParentVeda_Feelings_structure.pdf`, the brief's door 12 of 12
and the sixth built, on 2026-09-18, on the user's calls 1a (the journal
child-private by default; legal review owed), 2a (real helpline numbers,
flagged VERIFY), 3a (AES at rest via `pointycastle`; key custody owed to
the platform keystore), 4a (the off-ramp as a bar on every child screen).
Frame only. **This door's content is marked "care": nothing is authored
until a child psychologist has reviewed it.** Rows carry `FE`.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| FE1 | Name what you feel, 6 to 8 — (`fe_68_01`, `fe_68_02`, `fe_68_03`, `fe_68_04`, `fe_68_05`, `fe_68_06`, `fe_68_07`, `fe_68_08`, `fe_68_09`, `fe_68_10`, `fe_68_11`, `fe_68_12`) | Activity ×12 | Coming soon — **clinical review first** | No task PDF yet, and when one comes it goes to a child psychologist before it comes here. "Naming feelings with faces and colours, learning it is okay to feel them, a first way to calm down, simple situations." Two per skill in the door's order. |
| FE2 | Handle the big feelings, 8 to 11 — (`fe_811_01`, `fe_811_02`, `fe_811_03`, `fe_811_04`, `fe_811_05`, `fe_811_06`, `fe_811_07`, `fe_811_08`, `fe_811_09`, `fe_811_10`, `fe_811_11`, `fe_811_12`) | Activity ×12 | Coming soon — **clinical review first** | As FE1. "Bigger feelings, empathy, bouncing back from losing or failing, real situations like a friendship fight or feeling left out." |
| FE3 | Find your way through, 11 to 14 — (`fe_1114_01`, `fe_1114_02`, `fe_1114_03`, `fe_1114_04`, `fe_1114_05`, `fe_1114_06`, `fe_1114_07`, `fe_1114_08`, `fe_1114_09`, `fe_1114_10`, `fe_1114_11`, `fe_1114_12`) | Activity ×12 | Coming soon — **clinical review first** | As FE1. "Worry and stress, friendship and belonging, recovering from real setbacks, and knowing when and how to ask for help." |
| FE4 | Scenarios to think through, three per band (`fe_scn_68_1`, `fe_scn_68_2`, `fe_scn_68_3`, `fe_scn_811_1`, `fe_scn_811_2`, `fe_scn_811_3`, `fe_scn_1114_1`, `fe_scn_1114_2`, `fe_scn_1114_3`) | Lesson ×9 | Coming soon — **clinical review first** | "Think through a real situation, safer, external." Every card's chip says "Needs review" so a fill cannot land quietly. |
| FE5 | Journal prompts, three per band (`fe_prm_68_1`, `fe_prm_68_2`, `fe_prm_68_3`, `fe_prm_811_1`, `fe_prm_811_2`, `fe_prm_811_3`, `fe_prm_1114_1`, `fe_prm_1114_2`, `fe_prm_1114_3`) | Lesson ×9 | Coming soon — **clinical review first** | "Gentle questions for the harder feelings." Written with a clinician; the prompt a page was written from is kept as an id only. |
| FE6 | `fe_calm` — A calm-down breath | Window | Built from data | A page with no blocks and a `toolSurfaceId` onto `sk_page/skilling_stillness/sl_settle` — Stillness's source page. "This door reuses Stillness's calm-down practices, it does not rebuild breathing." The first cross-door window in the stage. Nothing owed. |
| FE7 | The course shelf — a short emotional-skills series per level (`fe_course_68_series`, `fe_course_811_series`, `fe_course_1114_series`) | Course ×3 | Coming soon | Real recordings. Placeholders behind the gate at ₹699 / $8, recorded only, "small"; every string under the no-outcome scan — nothing says "fix", "cure", "therapy", "anxiety" or "resilient child". |
| FE8 | The product shelf — feelings cards, a paper journal, a picture book, per band (`fe_prod_68_cards`, `fe_prod_68_journal`, `fe_prod_68_book`, `fe_prod_811_cards`, `fe_prod_811_journal`, `fe_prod_811_book`, `fe_prod_1114_cards`, `fe_prod_1114_journal`, `fe_prod_1114_book`) | Product ×9 | Coming soon | Real, sourced items. Skilling's own shelf; optional, never a gate. |
| FE9 | `fe_parent_note` — How to help a child with big feelings, and when to seek help | Parent note | Coming soon — **clinical review first** | The brief's own title. A skill door, never therapy; why naming and feeling beats "be strong"; the plain signs it is time for a professional. Written with a child psychologist. |
| FE10 | Her private journal — `sk_journal/skilling_emotional`, `SkJournalStore` | Journal | Built from data — **legal review owed** | On this phone, AES-256-GCM at rest, never uploaded, never analysed, never read by any AI; child-private by default (the parent can delete it, not read it — call 1a, flagged for legal review against DPDP's parental-consent rules). **Owed before ship:** key custody in the platform keystore (Android Keystore / iOS Keychain) — today the key sits in `shared_preferences` beside the data behind the `SkJournalKeyStore` seam. |
| FE11 | "Talk to someone" — the safety off-ramp, `SkTalkToSomeoneBar` | Off-ramp | Built from data — **VERIFY before ship** | A bar at the foot of every child screen of the door; a sheet with the trusted-adult line and two real Indian helplines with tap-to-call, ungated on purpose (the one ungated way out of a child screen, on the record). **Childline 1098 and Tele-MANAS 14416 are marked `verify: true`** — a lawyer and a clinician confirm the numbers and the wording; a release build shows nothing still marked verify. |
| FE12 | The crisis pathway — `sk_crisis_pathway.dart` | Stub | **STOPPED, by design** | "Do NOT build any automated distress/self-harm scanning of the journal. The crisis pathway is a clinical + legal design task, not a code task; leave a clearly-marked stub and STOP." The stub does nothing, reads nothing, and is not wired to the journal. What a child psychologist and a lawyer decide is listed in the file. |
| FE13 | Cross-links to Stillness (calm), Values (empathy), Communication (put a feeling in words), parenting Behaviour, Memory and Focus (the anxiety threads) | Windows | Part built | Stillness: built (FE6). Communication: built; its right-word activities already hand feeling-words here. Values, Memory, Focus: not built. Parenting Behaviour: exists on the parent side; any scenario that genuinely matches is single-sourced at fill time. Review file, cross-door table. |
| FE14 | A paid counsellor booking | Consult | Held | "Held. What comes first, and free, is the safety off-ramp. Help is not an upsell here." No row. |

### MK. Creativity & expression (the Making door) — `lib/data/doors/sk_door_making.dart`

Built to `ParentVeda_Creativity_structure.pdf`, door seven built, on
2026-09-18, on the user's calls 1a (the showcase private), 2a (the least
commercial door, kept that way), 3a (the showcase as a show mode on this
phone — the journal's invite is a link whose other half does not exist),
4a (photo capture built now, on-device, same posture as voice). Frame
only. Rows carry `MK`.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| MK1 | Just make it, 6 to 8 — (`mk_68_01`, `mk_68_02`, `mk_68_03`, `mk_68_04`, `mk_68_05`, `mk_68_06`, `mk_68_07`, `mk_68_08`, `mk_68_09`, `mk_68_10`, `mk_68_11`, `mk_68_12`) | Activity ×12 | Coming soon | No task PDF yet. "First marks and first sounds. Scribble, colour past the lines, bang a rhythm, glue scraps into a thing. There is no wrong." Two per move in the door's order; no supplies to begin; India first. |
| MK2 | Make it yours, 8 to 11 — (`mk_811_01`, `mk_811_02`, `mk_811_03`, `mk_811_04`, `mk_811_05`, `mk_811_06`, `mk_811_07`, `mk_811_08`, `mk_811_09`, `mk_811_10`, `mk_811_11`, `mk_811_12`) | Activity ×12 | Coming soon | No task PDF yet. "Your own version, not the example. Mixing art, music and making, and taking an idea a bit further." |
| MK3 | Make something real, 11 to 14 — (`mk_1114_01`, `mk_1114_02`, `mk_1114_03`, `mk_1114_04`, `mk_1114_05`, `mk_1114_06`, `mk_1114_07`, `mk_1114_08`, `mk_1114_09`, `mk_1114_10`, `mk_1114_11`, `mk_1114_12`) | Activity ×12 | Coming soon | No task PDF yet. "A piece you meant: a drawing, a tune, a thing you built. Keep it, and share it if you want to." |
| MK4 | The prompt sets — art, music, making, three per band per set (`mk_art_68_1`, `mk_art_68_2`, `mk_art_68_3`, `mk_art_811_1`, `mk_art_811_2`, `mk_art_811_3`, `mk_art_1114_1`, `mk_art_1114_2`, `mk_art_1114_3`, `mk_mus_68_1`, `mk_mus_68_2`, `mk_mus_68_3`, `mk_mus_811_1`, `mk_mus_811_2`, `mk_mus_811_3`, `mk_mus_1114_1`, `mk_mus_1114_2`, `mk_mus_1114_3`, `mk_mak_68_1`, `mk_mak_68_2`, `mk_mak_68_3`, `mk_mak_811_1`, `mk_mak_811_2`, `mk_mak_811_3`, `mk_mak_1114_1`, `mk_mak_1114_2`, `mk_mak_1114_3`) | Prompt ×27 | Coming soon | No task PDF. "India-first, and doable with what is in an ordinary home. No supplies required to start." All three honoured because "'creativity for kids' quietly means colouring". |
| MK5 | Her portfolio — `sk_portfolio/skilling_creativity`, `SkPortfolioStore` | Portfolio | Built from data | The brief's own tool, "untouched": a gallery that keeps what she made and cannot return a score. **Photos are the one new capability** (camera or gallery, copied into documents, index in prefs, behind the parent's photos switch, off by default, parent-deletable, never analysed — no "how good is this drawing", ever). Recordings are the voice keepsake and words the shared keepsake, both reused. The showcase is inside it as **Show it**: a full-screen pager to hand to family in the room; nothing leaves the phone; no likes, no ranking, no featured wall. Nothing owed. |
| MK6 | The course shelf — an art class and a music class per level (`mk_course_68_art`, `mk_course_68_music`, `mk_course_811_art`, `mk_course_811_music`, `mk_course_1114_art`, `mk_course_1114_music`) | Course ×6 | Coming soon | Real classes, "deliberately small" (2a). Placeholders behind the gate at ₹999 / $12; no ladder, no promise; every string under the no-outcome scan — nothing says "artist", "talent" or "level". |
| MK7 | The product shelf — crayons, clay, a cheap instrument, a craft kit, per band (`mk_prod_68_crayons`, `mk_prod_68_clay`, `mk_prod_68_instrument`, `mk_prod_68_kit`, `mk_prod_811_crayons`, `mk_prod_811_clay`, `mk_prod_811_instrument`, `mk_prod_811_kit`, `mk_prod_1114_crayons`, `mk_prod_1114_clay`, `mk_prod_1114_instrument`, `mk_prod_1114_kit`) | Product ×12 | Coming soon | Real, sourced items. Skilling's own shelf; every blurb names the no-supplies path because the shelf is "never a gate on an activity". |
| MK8 | `mk_parent_note` — Why this is a real skill, in plain words | Parent note | Coming soon | The brief's own title. The authored half: process not product; never graded or compared to an example; the way back in for the child who has decided she cannot draw. |
| MK9 | Cross-links to parenting Early Learning (the 6 to 8 edge), Confidence and Communication (sharing is not speaking), Coding (`cd_1114_12`'s private-showcase posture) | Windows | Part built | Coding's window is now real: this door's Show it is the "private, family-only showcase posture" it named. Early Learning exists on the parent side; the 6 to 8 fill cross-links, does not duplicate. Confidence and Communication built; sharing here is a made thing, not a speech. Review file, cross-door table. |
| MK10 | An art or music teacher | Consult | Held | "Rarely. Held." No row. |

## Trying to conceive

Added 2026-09-26 by the door data pass (TTC gap plan). Both new doors ship with `heroImageUrl: null`, which the door screen handles: the hero draws the V3 field and the bracket's own mark, the same thing every door shows offline. Nothing is broken; a photograph is owed.

| # | What | Format | State | Notes |
|---|---|---|---|---|
| TTC1 | Hero photograph for **Body and cycle** (`ttc_body_cycle`, `lib/ttc/focus/ttc_focus_body_cycle.dart`) | Photo | Owed | Calm and warm, dark enough at the edges for white type under the scrim. Never a body, never someone in pain. Something like a folded towel and a cup of tea, or morning light on a bedside table. |
| TTC2 | Hero photograph for **Trying, but not pregnant yet?** (`ttc_not_yet`, `lib/ttc/focus/ttc_focus_not_yet.dart`) | Photo | Owed | Patience rather than sadness. Never a crying person, never a pregnancy test, never a baby. Something like a window at dusk, or two cups on a table. |

- 2026-09-27: the TTC door hero photos are DONE for all nine doors (our own images, generated to the brief, checked by eye, mirrored to R2 as ttc_door_*.jpg). Possible redo: His side (the running shoes carry a swoosh-like mark).



## Garbh Sanskar — Shravan audio (2026-10-13)

The user's Garbh Sanskar.xlsx names 45 tracks for Shravan (Listen) and no recordings exist. The brief —
ID, weeks, kind, raga, instrument, time of day, the mother's cue — is generated into
`docs/GARBH-AUDIO-OWED.md` by `tools/garbh_content/xlsx_to_dart.py`. Nothing from that sheet is in the app.

## IVF and IUI, step by step — 16 films (2026-10-22)

The IVF door's first tab (`lib/ttc/ttc_treatment_journey.dart`) puts a film on
top of every step. All 16 slots are in `kTtcVideos` as `ttc_vid_step_*`, with
chapters and takeaways, so each opens its notes today. Doctor-led, so a real
clinician on camera (video plan rule); scenes may be illustrated. 60 to 110
seconds each. Explain, remind, prepare: no doses, no dates given as hers, no
chances.

| # | Slot | Film | Covers |
|---|---|---|---|
| TTC3.1 | `ttc_vid_step_iui_medicine` | Tablets or injections before an IUI | letrozole or injections; which day they start |
| TTC3.2 | `ttc_vid_step_scans` | Follicle and monitoring scans | what an internal scan is like; what is measured |
| TTC3.3 | `ttc_vid_step_trigger` | The trigger injection | why the exact hour matters; if you are late |
| TTC3.4 | `ttc_vid_step_iui_day` | IUI day, minute by minute | his sample and washing; the 5 minutes; after |
| TTC3.5 | `ttc_vid_step_progesterone` | Progesterone support | pessaries, gels, injections; when it stops |
| TTC3.6 | `ttc_vid_step_beta` | The blood test after treatment | beta hCG; why a home test can mislead |
| TTC3.7 | `ttc_vid_step_review` | Your review appointment | what is looked back at; what to bring |
| TTC3.8 | `ttc_vid_step_ivf_ready` | Getting ready for IVF | why some clinics quieten the cycle; protocols |
| TTC3.9 | `ttc_vid_step_baseline` | The baseline scan | when, and what it checks |
| TTC3.10 | `ttc_vid_step_ivf_injections` | Giving your own IVF injections | the pen; bloating and what is normal |
| TTC3.11 | `ttc_vid_step_collection` | Egg collection day | sedation; resting after |
| TTC3.12 | `ttc_vid_step_lab` | The lab, and the phone calls | day 1, 3 and 5; freezing |
| TTC3.13 | `ttc_vid_step_transfer` | Embryo transfer | the day; fresh or frozen |
| TTC3.14 | `ttc_vid_step_fet_lining` | Building the lining | medicated or natural cycle |
| TTC3.15 | `ttc_vid_step_fet_scans` | Lining scans | what is measured before a transfer is set |
| TTC3.16 | `ttc_vid_step_fet_transfer` | Thaw and transfer | the thaw; the transfer |
