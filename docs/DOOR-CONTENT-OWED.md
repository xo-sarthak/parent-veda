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

### P2. Feeding — `lib/data/doors/pp_door_feeding.dart`

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| FD1 | `feeding/positions_demo` | Film · 8 min | Coming soon | Film for the new slot ("Positions that actually work"). |
| FD2 | `feeding/back_blows_demo` | Film · 5 min | Coming soon | Film for the new slot ("If he chokes: what to do"). The page's steps stand until it lands. |
| FD3 | Textures / cut-it-this-way / allergic reaction | Illustration | Built from data | Drawn in code (`pp_content_art.dart`); artwork can replace each painter via `PpIllustration.asset` without touching the pages. |
| FD4 | Introducing allergens safely (`solids_allergens`) | Interactive tracker | Built from data | The brief says "an allergen tracker: tick egg, peanut…". Built as a walk-through (introduced / not yet) that forgets on close. A tracker that REMEMBERS is a backend job: a `ChangeNotifier` store, a `pp_allergen_intros` table (child-scoped, RLS like `pp_sleep_logs`), local-first with `ChildSync.merge`, and the screen reading it. Decide, then build; the screen is already its front. |

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
| Feeding (parenting) | 4 | 2 | – | 2 | 1 (allergen tracker persistence) |
| Health (parenting) | 6 | 3 | – | 3 | 1 (dosing table sign-off) |
| Development (parenting) | 4 | 1 | – | 3 | – (DV2 is a data job, logged) |
| Behaviour (parenting) | 15 | 11 | – | 4 | – |
| Potty (parenting) | 6 | 4 | – | 2 | – |
| Early Learning (parenting) | 4 | 2 | – | 2 | – |
| First 40 Days (parenting) | 11 | 3 | – | 4 | 1 (the day spine, FF10); FF1–FF2 closed into You |
| You, Maa (parenting) | 6 | 2 | – | 3 | – |
| What to buy (parenting) | 10 | 8 | – | 2 | – (call 2: shelves owned as they are) |
| Traditions (parenting) | 10 | 8 | – | 2 | – (two sensitive pages, tone to sign off) |
| Coding (skilling) | 9 | 4 (33 slots: 12 lessons, 6 AI cards, 6 courses, 9 products, 1 note — the 36 activities are filled) | – | 2 (the consent adapter, the access rail) | 1 generic (resume marker — `SKILLING-DOOR-BUILD.md` §9) |
| Communication (skilling) | 10 | 5 (29 slots: 27 lessons, 12 courses, 12 products, 2 notes — the 36 activities are filled; the 11–14 twelve are repo-written copy owed a task-author review) | – | 1 (the voice keepsake) | 1 (cloud copy of recordings, behind a real consent) |
| Confidence (skilling) | 11 | 5 (36 slots: 18 lessons, 6 courses, 9 products, 2 notes, 1 coach — the 36 activities are filled) | – | 1 (the breath page) | 1 (the coach onboarded, then the booking wiring) |
| Thinking (skilling) | 11 | 8 (82 slots: 36 activities, 33 lessons, 4 courses, 9 products, 1 note) | – | 1 (the keepsake, renamed) | 1 (the one spotting-fake defence, authored with Coding) |

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
| DV2 | The four areas of growing as "a closer look inside the tracker" | Data | Built from data | The brief assumes one milestone list behind the tracker and the area pages. There are two: `MilestoneStore` (18 milestones, six domains) behind the tracker and `DevArea` skills (`pp_development_data.dart`) behind Brain / Physical / Language / Emotional. The join is a hand map (`_kAreaForDomain` in `milestone_journey_screen.dart`). Making them one dataset — so ticking a skill in either place updates both — is a data job: one list, one store, both screens reading it. |
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
| BH1 | `beh_scared_everything` — Why he is suddenly scared of everything | Article | Coming soon | Copy, house voice. |
| BH2 | `beh_fear_dark` — Fear of the dark, and the monster under the bed | Article | Coming soon | Copy; cross-link Sleep's bedtime pages. |
| BH3 | `beh_fear_doctor` — The doctor, the injection, the haircut | Step-list | Coming soon | Copy. |
| BH4 | `beh_fear_dogs` — Scared of dogs, lifts and loud noises | Short article | Coming soon | Copy. |
| BH5 | `beh_shy_child` — The shy child, and "say hello, beta" | Article | Coming soon | Copy. |
| BH6 | `beh_fear_worth_checking` — When fear or clinginess is worth checking | Flagged callout | Coming soon | Copy; calm, routes to a person. |
| BH7 | `beh_thumb_sucking` — Thumb-sucking, and when to just leave it | Article | Coming soon | Copy. |
| BH8 | `beh_head_banging` — Head-banging and rocking | Article | Coming soon | Copy. |
| BH9 | `beh_breath_holding` — Breath-holding spells | Article + flagged callout | Coming soon | Copy: "the reassurance parents need" plus the one doctor line. |
| BH10 | `beh_nail_biting` — Nail-biting and the other little habits | Short article | Coming soon | Copy. |
| BH11 | `beh_self_touching` — Touching himself, and what to do about it | Article | Coming soon | The brief's judgement call 3, included on the user's call (2026-09-13). Copy: normal, do not shame, redirect gently, when to actually mention it. |
| BH12 | `beh_calm_jar` — A calm jar | Film · 3 min | Built from data | Reformatted Activity > Video; slot `behaviour/calm_jar` needs the make-and-use film. Steps stay. |
| BH13 | `crying_too_much` — When the crying is too much | Interactive | Built from data | Rebuilt as the dark one-step-at-a-time story (Sleep's 3am pattern); the article is in a comment. Worth a clinical read of the eight screens. |
| BH14 | `beh_balloon_breathing` — Balloon breathing | Animation | Built from data | The shared breathing circle on a 3-in / 5-out pattern (`kPpBalloonBreath`). No asset owed. |
| BH15 | The fourteen films the brief marks | Film | Built from data | Every `behaviour/*` slot is a placeholder: ziddi, tantrums, five steps, no-year, throwing, anger, screens ×2, calm corner, filling the tank, no-hitting, big feelings, lying, crying curve. |

### P6. Potty — `lib/data/doors/pp_door_potty.dart`

Built to `Potty_Parenting.pdf`. "The content is lean and excellent, so this is
almost all adding, plus one important re-tagging. No real cuts." Four new
pieces as coming-soon cards, copy "written on your go"; one film.
`test/pp_potty_door_test.dart` fails if a coming-soon page is not here.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| PT1 | `no_star_charts` — Why there are no star charts here | Short article | Coming soon | Brand-defining: the words to hold the line when the family is pushing stickers and sweets. Same shape as Sleep's "where we stand". |
| PT2 | `three_day_method` — The three-day method, done safely | Article | Coming soon | Judgement call 2, the user's call: teach it. Who it suits, the shape, and the one risk built in (a child who starts holding it in). |
| PT3 | `pull_ups` — Do pull-ups help or hurt? | Cards | Coming soon | One honest card. |
| PT4 | `taking_longer` — If she is taking much longer than her friends | Cards | Coming soon | A calm pointer to Development and a paediatrician, without alarm. |
| PT5 | `indian_toilet` — The Indian toilet, and going out | Film · 6 min | Built from data | Slot `potty/indian_toilet`: the supported squat, the balance, the bucket-and-mug, front to back. "The clearest missing video in the section." The wiping page points here. |
| PT6 | The seven films the brief marks | Film | Built from data | Every `potty/*` slot is a placeholder: the timeline, cueing, readiness, the routine, accidents, the activities, dry nights. |

### P7. Early Learning — `lib/data/doors/pp_door_early_learning.dart`

Built to `Early_Learning_Parenting.pdf`. "Mostly an add and a re-front, not a
teardown." Two scaffolds; the big owed item is recording, not writing.
`test/pp_early_learning_door_test.dart` fails if a coming-soon page is not
here.

| # | Card | Kind | Outcome | Owed |
|---|---|---|---|---|
| EL1 | `rhymes_collection` — Rhymes and songs | Audio library | Coming soon | A whole collection, audio-first like the stories: Hindi, English and regional action rhymes, original or public-domain only, never copyrighted lyrics. Pairs with "Clapping and dancing to a song". |
| EL2 | `skills_language` — English or the mother tongue, and when to start letters | Article | Coming soon | The words to hold the line when the pressure to start ABCs at two starts. Copy supplied. |
| EL3 | The 58 story audios | Audio | Built from data | Every story has a "listen" button and no recording. "A story library with no narration is half-built, so recording the story audio is the first job." |
| EL4 | The 15 films | Film | Built from data | Every `early_learning/*` slot is a placeholder: tummy-time reach, pouring, spooning dal, the strokes before letters, brushing teeth, the Montessori corner, telling a story with no book, the six read-alouds, readiness, what comes before writing. |

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
| YM6 | The recipes in the shared library | Data | Not done | The six healing-kitchen recipes should also be tagged postpartum in `pp_food`'s recipe library; today they are pages here that link to `pp_food`. |

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
| TR10 | Seventeen films, 88 minutes | Film | Built from data | In the order worth shooting: kajal-honey-cord (watch with a grandmother), jhula, mundan, annaprashan, karnavedha, tahneek; the ceremony walk-throughs after. |

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
