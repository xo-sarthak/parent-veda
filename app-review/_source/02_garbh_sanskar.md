# Garbh Sanskar
_ParentVeda Pregnancy App - Feature & Screen Reference_

## Overview
Garbh Sanskar is ParentVeda's Indian prenatal-bonding and spiritual-wellbeing program: a calm, curated set of daily rituals a mother does with her growing baby. The canonical spec is five pillars, but Ahara (diet/nourishment) is currently commented out, leaving **four LIVE pillars**: **Shravan** (sacred listening / calming audio), **Vichara** (positive contemplation: reflective reads, sacred insights, and gentle brain-fitness games), **Samvad** (womb connection: speaking and reading aloud to the baby), and **Kriya** (breath and grounding practices). All content is trimester-aware: the pillar screens ask which trimester the mother is in (week 1 to 13 = T1, 14 to 27 = T2, 28+ = T3) and change what they recommend accordingly. The feature is reached as a tool: from the Tools tab, tap the **Garbh Sanskar** tile (gold, spa icon). In the Tools context every pillar opens as a calm browsable LIBRARY (no "today"/progress/streak framing); a separate daily "today's ritual" version of each pillar exists in code for a Home daily-Garbh section, which is largely parked in the current build. The old **"Read to your baby"** feature was folded into Samvad: it is now a single unified Customize experience, and the father's daily read simply mirrors whatever the mother enables. A companion tool, **Spiritual Reading**, is a separate, read-only Tools entry that surfaces the same faith-tradition content in a respectful, informational (non-instructional) frame. Note on language: the app chrome/labels are localized (English + Hindi via a language switch), but the Garbh seed content itself (audio titles, stories, insights, speaking cards, spiritual reflections) is currently English-only, with code comments stating "Hindi can be layered later."

Screens covered:

- Garbh Sanskar hub and its four pillars (`garbh_screen.dart`)
- Vichara Brain-Fitness mini-games (`tools/garbh_games.dart`)
- Spiritual Reading (`tools/spiritual_reading_screen.dart`)

## Screen: Garbh Sanskar Hub and Pillars (`garbh_screen.dart`)
**Status:** Live (Tools library mode). Justify: `GarbhScreen` is wired into the Tools hub and always renders as a library. The "daily/today" ritual variants (progress ring, streak, mark-complete buttons) exist in the same file but are only used by a Home daily-Garbh section; the Home entry point (`_garbhCard` in `home_screen_b.dart`) is flagged `// ignore: unused_element`, so in the current build the pillars are experienced as browsable libraries, not a daily 4/4 checklist. The fifth pillar **Ahara is commented out** (see below).

**Reached from:** Tools tab (Tools hub) -> "Garbh Sanskar" tile (gold accent, spa icon). Also reachable from Global Search. The hub then routes to each pillar sub-screen.

**Purpose:** A warm home for the four prenatal-bonding pillars; an intro explains what Garbh Sanskar is, then four tiles each open the full repository of one pillar.

**Sections & UI:**
- **Intro block:** large title "Garbh Sanskar", a body paragraph (what it is / why it matters), and an italic meaning line. No hero image, no raga "video" hero, no progress ring or streak, no "today's rituals" list in this Tools view.
- **Four pillar tiles** (gradient cards with an icon square, name, one-line description, and a chevron), in order: Shravan, Vichara, Samvad, Kriya. Each pillar has its own accent color: Shravan gold, Vichara muted green, Samvad warm rose, Kriya teal-green. Ahara (terracotta) is intentionally absent from this list.

### Pillar 1: Shravan (Sacred Listening)
- Library view lists all 10 audio pieces from `kShravan`: 5 ragas (Morning Calm, Baby Bonding, Evening, Sleep, Relaxation), 4 nature sounds (Gentle Rain, Ocean Waves, Forest Morning, Temple Bells), and 1 guided track (Body Awareness Journey). Each row shows an icon, title, subtitle, and duration in minutes.
- Tapping a track opens a detail screen with a large hero, title/subtitle/minutes, and a `RagaPlayer` widget. A caption reads that this is sample audio.
- **Important placeholder:** audio is not real recordings. Per the model and data comments, the player uses a bundled "drone" placeholder until real recordings are added.
- No mark-complete in the Tools library. In daily mode (parked Home use) it instead shows today's rotating raga, a "why this matters today" card, the player, and a Mark done button plus a Learn more link.

### Pillar 2: Vichara (Positive Contemplation)
Three tabs (scrollable tab bar), each a distinct sub-experience:
- **Sacred (Sacred Insights):** shows all insight cards (`garbhAllInsights()`, currently 3). Each card has a gentle line ("sloka"), then Meaning, Lesson, and a "A moment to reflect" prompt. There is no heavy religious language.
- **Brain (Brain Fitness):** intro line ("A few quiet minutes of focused calm"), then the 4 puzzle cards from `kPuzzles`: Word Search, Sudoku, Logic Puzzle, Memory Match. Each card has an icon, title, blurb, and a Start button that opens the real game (see `garbh_games.dart`). In the Tools library, finishing a game does NOT mark Vichara done (it is "just play"); only in daily mode does completion mark the pillar.
- **Uplifting:** in the Tools library, lists all 8 reflective reads (`kVichara`, themes such as Curiosity, Patience, Kindness, Gratitude, Courage, Wonder, Compassion, Resilience). Each card shows a theme chip, title, blurb, a Read link, and minutes. Tapping opens a reader that splits the body into paragraphs and ends with a reflection card. Daily mode shows one read per day plus a Mark done button.

### Pillar 3: Samvad (Womb Connection / Read to Your Baby)
This is the unified home of the old "Read to your baby" feature. It is a 4-tab screen (fixed tabs; the old on/off category feed was retired):
- **Affirmations tab:** the 16 "affirmations and blessings" pieces (spoken to the baby).
- **Stories tab:** the 16 original children's stories (read to the baby). Group label internally is "Stories & Fables"; the earlier "Myth" strand was removed.
- **Mantras tab:** this trimester's speaking cards (T1 = 6 affirmation lines, T2 = 5 expressive read-aloud scripts, T3 = 5 visualization prompts) plus the 16 rhymes/lullabies.
- **Spiritual tab:** shows only the traditions and sub-sections the mother has enabled. It carries a **Customize** button (tune icon) that opens the preferences sheet. If nothing is enabled, an empty hint invites her to tap Customize.
- Every content card is rose-tinted with an optional title and body, and each has a **Save** (bookmark) toggle that stores a copy in the Saved hub.
- Daily mode adds a "why this matters" card (per-trimester theme line) and a Mark done button; Tools mode shows the full list without mark-complete.
- **Customize sheet:** now spiritual-only. It shows FilterChips for the 5 traditions (Hinduism, Islam, Sikhism, Christianity, Others), each with its symbol; enabling a tradition default-enables all its sub-sections, and further chips let the mother pick which sub-sections to include. Turning a tradition off clears its sub-section selections. The old per-category on/off tile (`_catTile`) and the library-group helper (`_samvadGroup`) are kept commented for revert.
- **Parked/removed here:** the Samvad record/write composer (`TalkComposerScreen`) and its "memory saved" confirmation (`_MemorySavedScreen`) were removed when Read-to-baby folded in; both are commented/parked for revert.

### Pillar 4: Kriya (Breath & Grounding)
- Library view lists all 5 breathing practices (`kKriya`): Bhramari Breath, Deep Belly Breathing, Box Breathing, Calm Breathing, Guided Relaxation. Each row shows an icon, title, blurb, and minutes.
- Tapping opens a practice detail: large icon, title, a per-trimester **Safety notes** card, and a Start button.
- Start opens an animated **breathing screen**: a circle that expands and contracts through the practice's phases (for example "Breathe in / Hold / Breathe out / Rest"), with a per-phase countdown number and phase label, looping the breath cycle. A Finish button ends it.
- In daily mode, Finish marks Kriya done and shows a "well done" snackbar; in the Tools library there is no mark-complete.

### Pillar 5: Ahara (Nourishment) - COMMENTED OUT
- The `AharaScreen` class still exists (nutrition tip, why-it-matters, recipe, food swap, lifestyle habit, per-trimester) but Ahara is **removed from the pillar list**, so the hub never shows it and it cannot be reached from the four tiles.
- Confirming evidence: `GarbhStore.dailyGoal` was reduced from 5 to 4 "now that Ahara is commented out," with a code note to restore it to 5 if Ahara returns.

**Features & interactions:**
- Tap a pillar tile to open its library.
- Shravan: browse and open audio; play via `RagaPlayer` (placeholder/sample audio only).
- Vichara: switch among 3 tabs; read insights and reflective stories; launch any of 4 brain games.
- Samvad: switch among 4 tabs; read/save pieces; open the Customize sheet to pick faith traditions and sub-sections.
- Kriya: open a practice, read safety notes, run the animated breathing timer.
- Mark done / streak / progress and the daily rotation only appear in the daily (Home) mode, which is parked in the current build. Favorites, done-today set, and streak persist via `GarbhStore` (streak and favourites also cloud-sync).

**Data:** Models in `models/garbh_content.dart` (`GarbhAudio`, `GarbhStory`, `GarbhPractice`, `GarbhPrompt`, `GarbhInsight`, `GarbhPuzzle`, `GarbhNutrition`, `BreathPhase`). Seed content and trimester/day pickers in `data/garbh_data.dart`. Read-to-baby pool in `data/read_to_baby_data.dart` (stories, rhymes, affirmations; all original writing). Spiritual traditions in `data/spiritual_reading_data.dart`. Services: `GarbhStore` (done-today, streak, favourites), `ReadToBabyStore` (which categories/traditions/sub-sections are enabled; default is speaking cards + children's stories ON, everything else OFF), `ReadToBabySavedStore` (bookmarked pieces, cloud-synced), and `samvad_pool.dart` (the shared read-to-baby pool the mother's Samvad and the father's mirror card both draw from). Language: labels come from a localized `S(lang)` (English + Hindi); the Garbh seed content strings are currently English-only ("Hindi can be layered later").

## Screen: Vichara Brain-Fitness Mini-Games (`tools/garbh_games.dart`)
**Status:** Live. Justify: all four games are fully implemented and are launched from the Vichara "Brain" tab's Start buttons.

**Reached from:** Garbh Sanskar hub -> Vichara pillar -> Brain (Brain Fitness) tab -> tap Start on a puzzle card.

**Purpose:** Four gentle, calming mini-games for "a few quiet minutes of focused calm." Deliberately non-competitive: no countdown timers, no scores, no harsh fail states.

**Sections & UI:**
- Shared warm chrome (`_GameChrome`): a cream scaffold with the game title, a "how to play" hint card, and a completion state showing a calm message plus **Play again** and **Close** buttons.
- **Word Search:** a 9x9 letter grid with 6 hidden calming words drawn from a pool of 8 (CALM, PEACE, LOVE, REST, GENTLE, BLOOM, BREATHE, KIND). The grid is generated at runtime so words are always placeable/solvable. A found-count line and word chips (strike-through when found) sit below.
- **Sudoku:** a gentle 4x4 grid seeded from 3 preset puzzles, with a 1-to-4 number pad plus a clear button. Conflicting entries highlight in soft red; a fill wins when it is valid (any correct solution, not one fixed answer).
- **Logic Puzzle:** 5 one-screen brain-teasers (number sequences, odd-one-out, pattern-next, size comparison, letter sequence) as multiple choice, with a progress line. A wrong tap shows a gentle nudge; a right tap advances.
- **Memory Match:** a 4x4 board of 8 calming emoji pairs (flower, leaf, moon, star, and similar), flip two to find matches; matched tiles stay revealed.

**Features & interactions:**
- Tap cells/options to play; each game can be reset via Play again.
- **markComplete flag:** when a game is opened from the daily Home Vichara (`markComplete = true`), completing it marks the Vichara pillar done for the day via `GarbhStore`. When opened from the Tools library (`markComplete = false`), completion does not mark anything; it is play only.
- How-to text is localized via `S(lang)`.

**Data:** Self-contained hand-picked data inside `garbh_games.dart` (word pool, Sudoku puzzle sets, logic questions, memory faces). Completion writes to `GarbhStore.markDone('vichara')` only when `markComplete` is true. The four game entries are described in `garbh_data.dart` via `kPuzzles`. Localized labels via `S(lang)` (English + Hindi); game content is English/emoji.

## Screen: Spiritual Reading (`tools/spiritual_reading_screen.dart`)
**Status:** Live (labelled internally as a "testing" surface-level reading tool). Justify: it is wired into the Tools hub and Global Search and renders real content; the header comment marks it as a gentle testing feature.

**Reached from:** Tools tab (Tools hub) -> "Spiritual Reading" tile (purple accent, book icon). Also from Global Search. It is a separate tool from Garbh Sanskar, though it shares the same tradition data used by Samvad's Spiritual tab.

**Purpose:** A respectful, neutral look at how a few faith traditions approach calm, gratitude, family, and motherhood. Framed clearly as comfort and curiosity, NOT religious instruction and not promoting any belief.

**Sections & UI:**
- **Disclaimer banner** at the top (heart icon) stating the content is informational, not instruction.
- **One card per tradition**, for all 5 traditions in `kSpiritualTraditions`: Hinduism (Om symbol), Islam (star-and-crescent), Sikhism (Khanda), Christianity (cross), and "Others" (lotus; Jainism and Buddhism reflections). Each card shows the tradition's symbol, name, and a short blurb, then 3 preview reads (the first reads flattened across its sections), then a **"View all (N)"** row showing the total read count.
- **Tradition detail** (`_TraditionDetailScreen`, opened via View all): every read for that tradition, grouped under its section sub-headings (for example, for Hinduism: "Reflections inspired by the Gita", "Ramayan stories, simply retold", "The meaning behind common mantras", "Festivals & rituals", "Calm & wellbeing").
- **Single read** (`_SpiritualReadScreen`): the read's title, its body, and an italic footnote at the bottom.

**Features & interactions:**
- Tap a preview read to open it directly, or tap "View all" to see the full grouped list, then tap any read.
- Read-only: there is **no** save/bookmark, like, audio, or customize here. Saving and per-tradition customization exist only inside the Samvad Spiritual tab, which reuses this same data.
- Each tradition is seeded with roughly 20 reads organized as tradition -> section -> read; the design scales by adding reads/sections.

**Data:** `data/spiritual_reading_data.dart` (`SpiritualTradition` -> `SpiritualSection` -> `SpiritualRead`; `readCount` and `preview(n)` helpers). All reflections are original, plain-language writing; per the data comment, no scripture, verse, prayer, mantra, hymn, or copyrighted translation is quoted or paraphrased. The same `kSpiritualTraditions` list also powers the Samvad Customize sheet and the shared `samvad_pool`. Labels via `S(lang)` (English + Hindi); the reflection content is English-only.
