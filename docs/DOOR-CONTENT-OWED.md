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
| G1 | Morning Calm Raga, Baby Bonding Raga, Evening Raga, Sleep Raga, Relaxation Raga | Audio ×5 | Listen · "Ragas" | Built, placeholder inside | All five play `assets/audio/raga_drone.wav`. Royalty-free tracks (Pixabay / archive.org, licence verified), hosted on **Cloudflare R2**, read from a manifest (id, title, category, duration, sourceUrl, licence, attribution); background + offline playback. |
| G2 | Gentle Rain, Ocean Waves, Forest Morning, Temple Bells | Audio ×4 | Listen · "Nature sounds" | Built, placeholder inside | Same drone. CC0 nature loops (Freesound / Pixabay), looped to length, same manifest. |
| G3 | Body Awareness Journey | Guided audio · 9 min | Listen · "Guided" | Built, placeholder inside | Same drone. A spoken body scan — TTS through `NarrationService` for now, a recorded voice later by manifest edit. Shares Kriya's script engine. |
| G4 | Today's passage — the narrator | Read + Record | Talk and read · "Today's pick" | Built, placeholder inside | Recording is real. "Or listen to the narrator" is a coming-soon line on `GarbhSamvadDailyScreen`; wire it to `NarrationService` (manifest → file, else on-device TTS). |
| G5 | Affirmations and blessings, ~20 | Read | Talk and read · "Affirmations and blessings" | Built, six on the door | The library holds the brief's six; the pillars brief asks for about twenty, spoken to the baby, in the existing style. Writing job, allowed by that brief. |
| G6 | Stories and fables, 6–8 | Read library | Talk and read · "More to read aloud" | Built | Check the shelf against the pillars brief: public-domain (Panchatantra, Aesop) or original, each readable aloud in a few minutes. Top up if short. |
| G7 | Mantras and lullabies | Read + Audio library | Talk and read · "More to read aloud" | Built, partly | Each needs text, a simple transliteration and a one-line meaning; plus two or three original lullabies. No copyrighted lyrics. Audio side is G1's manifest. |
| G8 | Spiritual reading, by tradition | Read library | Talk and read · "More to read aloud" | Built | Eight traditions exist. Verify every passage is a public-domain translation; default to none selected. |
| G9 | Sudoku | Game | For you · "A few quiet minutes" | Built, placeholder inside | A 4×4 with three fixed boards. Brief: 9×9 easy default and a gentle 6×6, generator, validator, pencil notes, check, hint, no timer. |
| G10 | Logic Puzzle | Game | For you · "A few quiet minutes" | Built | Check against the brief: a light nonogram or a small deduction grid, hints allowed. |
| G11 | Guided Relaxation | Guided audio · 8 min | For you · "Breath and relaxation" | Built, placeholder inside | Today a breathing pattern named `relax`. Brief: a written head-to-toe progressive-relaxation script, narrated by TTS synced to a timer and a calm visual, optional background audio from Shravan, the current body part highlighted on an outline figure. Data-driven so a recorded voice replaces TTS with no code change. |
| G12 | Breathing practices | Tool | For you · "Breath and relaxation" | Built, twice | `_BreathingScreen` (garbh) and `MmBreathingScreen` (Mind & mood) are two circles. Brief: one shared component, configured per practice (4-in 6-out; box 4-4-4-4), reused by Mind & mood and the TTC mind-body practice. |

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
| Garbh Sanskar | 12 | – | – | – | – (12 built-with-placeholder, the pillars brief) |
| Feeding (parenting) | 4 | 2 | – | 2 | 1 (allergen tracker persistence) |

Pregnancy, six doors: written pieces owed, in prose — **S1, L3, L4, L5, L6,
M1**, six reads. Films — **N1, L1, L2, M4 ×3, M6 ×5**, eleven. Audio — **M5
×4**. One decision: N2. One confirmation: M3's numbers. Garbh Sanskar: the
pillars brief, twelve rows, none of them a coming-soon card.
Parenting's totals are its terminal's to keep.
