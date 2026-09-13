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
| S1 | What the scan person can and cannot tell you | Read | Understand · "Before any scan" | Coming soon | A four-minute read: why they go quiet, why they will not discuss the sex, who gives you the result. Two thirds of it is already inside `preg_scan_read_sex_law`; `content_slots.dart` has declared the slot for months. |

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
