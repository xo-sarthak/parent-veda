# Father Mode
_ParentVeda Pregnancy App - Feature & Screen Reference_

## Overview
Father Mode is a distinct, Slate-coloured "skin" of the same pregnancy app, built for the paired partner (the father) rather than the pregnant mother. It is not a separate download: the exact same 5-tab shell (`MainScaffold`) renders either the mother pages or the father pages depending on one flag. In the shipped product, a father reaches this mode by going through a pairing-code flow (his role is fixed at pairing, so there is no user-facing Mom/Dad toggle). For team testing there is a small "Mom | Dad" pill on the Today tab (bottom-right, above the tab bar) backed by a global `FatherPreview` singleton; tapping it flips the entire shell between mother and father at runtime, and it is meant to be stripped before launch. When Father Mode is on, the 5 bottom tabs become: Today (father daily briefing), Journey (the SAME shared weekly card-stack the mother uses), Reads (father articles), Read (read-aloud to the baby), and Journal (father's own memory journal). This maps onto the mother tabs (Today, Prepare, Tools, Calendar, Community) by keeping Today and Journey shared and replacing the other three with father-only sections. The visual identity is the "Slate" palette: warm off-white background (`0xFFF4EFE8`), deep slate-blue accent (`0xFF2E5266`), and a warm terracotta secondary (`0xFFE0915B`), with Fraunces serif headings and Plus Jakarta Sans body text. Father content is generated against the SAME pregnancy timeline as the mother: it reads her due-date-derived current week/day from the shared `PregnancyController`, and where the father should see the same thing she does (read-aloud pieces, scans, weekly journey), it mirrors her live stage and her choices rather than having its own controls. Some father content is bilingual English + Hindi (the weekly journey data, the parked "Daily Moment" data, scan detail); the father articles and original tales are English only.

Screens covered:
- Father Today / Daily (`father/father_daily_screen.dart`) - the live father home tab.
- Father Home "Daily Moment" (`father_home_screen.dart`) - an older, now-superseded father home.
- Father Journal (`father/father_journal_screen.dart`) - photo carousel + week grouping.
- Father Read / Read to your baby (`father/father_read_aloud_screen.dart`).
- Father Reads / articles (`father/father_reads_screen.dart`).
- Father Stories, Fables & Mythology (`father/father_stories_screen.dart`).

## Screen: Father Today / Daily (`father/father_daily_screen.dart`)
**Status:** Live. This is the actual "Today" tab in Father Mode (wired in `MainScaffold` as `FatherDailyScreen(..., embedded: true)`). It supersedes the older `FatherHomeScreen`. Several sub-blocks are commented-out or parked (see below) but the screen itself ships.

**Reached from:** The first (Today) tab of the father bottom nav. Also usable standalone (the pairing flow) where it shows its own internal bottom tab bar; when embedded in the app shell that internal bar is hidden and the app's floating pill tab bar is used instead.

**Purpose:** The father's daily space - "grounded, warm, getting ready to meet my baby." A single scrolling briefing of a weekly snapshot plus the day's father-focused cards (a tip, how to support her, a read, read-to-baby, scans, journal).

**Sections & UI:**
- **Top bar:** "P" logo tile + "ParentVeda" wordmark; a developer-only Slate/Teal palette toggle (two coloured dots) that swaps the whole screen between the default Slate palette and an alternate Teal palette; and a top-right circular profile avatar showing the dad's initial ("A" for the placeholder name "Arjun").
- **Weekly snapshot hero:** A large slate-gradient card mirroring the mother's home hero. Shows "Good morning/afternoon/evening, Arjun", "Week 20", a one-line week headline (pulled from the shared week data), a circular percentage progress ring with "N weeks to go", an "Open her week" link, and three round shortcuts: Baby, Mother, What's next.
- **"TODAY FOR YOU" section** with these cards in order:
  - **Daily tip for Dad (hero tip):** A dark slate card, e.g. "Tonight, don't fix it. Just sit with her." with a "Read today's tip - 2 min" pill.
  - **Support your partner:** White card, "Week 20 - what she's carrying", a "DO THIS TODAY" warm box, and a "Read more" link.
  - **Daily read:** White card. If the day has more than one read it is a looping swipeable carousel (Instagram-style dots); each slide shows the read title, reading time - category, and an animated "sound ripple" thumbnail. Single read = a static card.
  - **Read to your baby (talk):** White card showing tonight's read-aloud line in italic serif, pulled live from the mother's Samvad; a "Read it aloud" link.
  - **Scans & appointments:** White card, "Coming up for her", listing scans due at the current week (not yet completed) and any upcoming saved appointments, plus a "View all scans" link.
  - **Journal card:** White card, "A note to your baby", four quick-add circles (Memory, For baby, Photo, Voice), a live preview of the most recent father journal entry, and a "See all entries" link.
- **Detail overlay:** Tapping most cards slides up a full-screen slate detail view (eyebrow, title, meta, body paragraphs, lists, and a bottom CTA button that closes with a confirming toast).
- **Toast pill:** A dark rounded pill that briefly confirms actions (e.g. "Saved to your journal").
- **Internal bottom tab bar (standalone only):** Today, Reads, Read, Journal, You. "You" shows a "coming soon" toast. Hidden when embedded in the app shell.

**Features & interactions:**
- Palette toggle flips Slate <-> Teal for the whole screen (dev affordance).
- Profile avatar opens `ProfileScreen(father: true)`.
- Weekly snapshot: tapping the card jumps to the weekly view (`AppNav.goWeekly`); Baby / Mother / What's-next shortcuts open the father-skinned week-20 detail screens (`openWeekBabyDetail`, `openWeekMotherDetail`, `openWeekWhatsNext(father: true)`).
- Tip, Support-partner, Daily-read, Talk cards each open the slide-up detail overlay; the CTA button confirms with a toast.
- Daily read carousel: swipe to loop through the day's reads; tapping the visible slide opens that read's detail.
- Scans card: each scan row opens a rich father-voiced scan detail (`_FatherScanDetail`, Slate skin, same what-is / sections / bullets / "how to read the report" content the mother gets, read-only); an "Already done" pill marks the scan complete in the SHARED `ScansStore` (so it reflects on her side too). "View all scans" opens a draggable sheet listing every medical scan with a done toggle (so a late-joining couple can tick older ones).
- Journal quick-add circles open the shared journal compose sheets with `father: true`, saving into the separate `FatherJournalStore`; "See all entries" / the recent-entry preview open `FatherJournalScreen`.
- An "(i)" info tap on the journal card explains what the journal is.
- A "Switch to Mom's view" bottom sheet (`_momSheet`) is defined in code but is NOT currently triggered by any control in this build - effectively dormant.

**Data:** Reads her live week/day from the shared `PregnancyController` (fixed framing week = 20 for the snapshot copy, real `currentWeek`/`currentDay` for read-aloud and scans). "Read to your baby" pulls from the shared Samvad pool via `ReadToBabyStore` and `samvadDailyPool(...)`, honouring whatever the MOTHER enabled (the father has no read-aloud controls of his own) - these pieces can be bilingual. "Daily read" comes from `father_read_data.dart` (`fatherDailyReads` / `kFatherReadItems`, English only). Scans come from `scan_schedule.dart` / `ScansStore` / `scan_guide_data.dart` (scan detail uses bilingual `LocalizedText`). Journal entries come from `FatherJournalStore`. Parked/commented in this file: the "Stories, Fables & Myth" daily card (`_storiesMyth`), the read-aloud record/playback control, the old `_quickCircles` and `_greeting` blocks, and a local-only "recent entries" journal body - all kept commented for easy revert. There is also a daily-tale customize sheet (`_showTaleCustomize`) that persists chosen tale kinds to `SharedPreferences`, retained even though the tale card is hidden.

## Screen: Father Home "Daily Moment" (`father_home_screen.dart`)
**Status:** Parked / superseded. This is the ORIGINAL Father Mode home (a 3-module "Daily Moment") reached only through the older `home_screen.dart`. The live app shell (`MainScaffold`) now uses `HomeScreenB` for the mother and `FatherDailyScreen` for the father, so this screen is not in the shipping navigation. Its supporting model/controller/data still load, so it is documented for completeness and possible revival.

**Reached from:** `home_screen.dart` (the earlier home) when `fatherMode` is true. Not reachable in the current live nav.

**Purpose:** A calm daily "becoming a father" ritual (not pregnancy education): a warm greeting, a "Today's Moment" line, then exactly three modules - Learn, Talk To Your Baby, Mission - with a soft completion banner.

**Sections & UI:**
- A `ModeToggle` (Mom/Dad) at the top.
- A PROTOTYPE preview bar (`_FatherPreviewBar`) to step across days/weeks (single, double, and "back to today" arrows) so authored father content can be reviewed; shows "PREVIEW - Wk N - Day N" and whether the day is authored.
- `FatherHeader` (name, week, day, greeting by hour, language switch).
- `FatherSectionToggle` flipping between "Today" (Daily Moment) and "This Week" (Weekly Journey).
- Today view: `FatherMomentCard` (intro line) then three module cards - `FatherLearnModule`, `FatherTalkModule`, `FatherMissionModule` - and a `FatherCompletionBanner`.
- This Week view: `FatherWeeklyView` showing four short sections (Father Insight, Supporting Your Partner, Connecting With Your Baby, This Week's Mission).

**Features & interactions:**
- Mode toggle switches back to the mother home.
- Preview bar steps the `previewDay` on `FatherContentController` (prototype review tool, to be removed before launch).
- Section toggle swaps Today <-> This Week.
- Language switch (in the header) changes English/Hindi app-wide.
- The three module widgets (in `widgets/father/father_modules.dart`) expand their layered content (card -> expanded -> deep dive) and mark engagement in-session.

**Data:** `FatherContentController` loads per-week files (`lib/data/father/week_NN.json`) plus a legacy single-day fallback (`fatherDailyContent.json`, the week-20 / day-143 prototype) and weekly-journey files (`journey_week_NN.json`). Models: `FatherDay` (intro + Learn lesson with module/title/insight/expanded/deepDive/remember, Talk prompt with title/prompt/motivation, Mission with title/action/durationMinutes) and `FatherWeek` (four `FatherWeekSection`s). Every text leaf is bilingual English + Hindi (`LocalizedText`). Each father day/week is authored against the matching mother week so milestones never contradict. Nearest-day / nearest-week fallback keeps the prototype visible while the rollout grows.

## Screen: Father Journal (`father/father_journal_screen.dart`)
**Status:** Live. The "Journal" tab in Father Mode (also pushable full-screen from the daily screen's journal card).

**Reached from:** The Journal (5th) tab of the father nav; or the "See all entries" / recent-entry preview on the Father Daily screen.

**Purpose:** A deliberately small, low-clutter cousin of the mother's My Journal: four quick actions and a newest-first feed of what the father has saved. No filters, milestones, health, scans, or booklet.

**Sections & UI:**
- Header: "YOUR MEMORIES" eyebrow + "Father's Journal" title; a back button when pushed standalone (hidden when shown as a tab).
- Four quick-action circles: Memory, For baby, Photo, Voice.
- Feed grouped by pregnancy week. Each group has a Slate week header ("Week N" + the week's date range + a count badge). Newest week first.
- Entry card: type icon + timestamp + delete button; then (if present) a photo, the title, the description, and any voice notes.
- Photos: one photo = a single banner image; multiple photos = an Instagram-style swipeable carousel (`_FatherPhotoCarousel`) with a "1/N" counter chip and animated dots.
- Empty state: a friendly "Start your journal" card.

**Features & interactions:**
- Each quick-action circle opens the shared journal compose sheet (`openJournalText` for memory / note-for-baby, `openJournalAddPhoto`, `openJournalRecordVoice`) with `father: true`, saving into `FatherJournalStore`.
- Photo carousel: swipe between photos; counter and dots update.
- Voice notes: tap to play/stop via `AudioPlayer` (resolves the stored file through `StorageService`); only one plays at a time.
- Delete button removes the entry (and cleans up its local media files).
- Feed rebuilds live via `AnimatedBuilder` on `FatherJournalStore`.

**Data:** `FatherJournalStore` (a SEPARATE store from the mother's `JournalStore`, prefs key `father_journal_entries`), holding only manual entries of the shared `JournalEntry` model. Entries persist to `SharedPreferences` and sync to Supabase (`father_journal_entries` table) when logged in; media backfills to cloud storage. Entries are grouped by `weekNumber`. Text is whatever the father typed (not pre-authored, so no fixed bilingual content here).

## Screen: Father Read / Read to your baby (`father/father_read_aloud_screen.dart`)
**Status:** Live. The "Read" tab in Father Mode.

**Reached from:** The Read (4th) tab of the father nav.

**Purpose:** The father's read-aloud-to-the-baby space. Same four-section structure as the mother's Samvad, in the Slate skin, framed around "the same words she's reading - say them aloud to the bump."

**Sections & UI:**
- Header: "READ TO YOUR BABY" eyebrow, "Read to your baby" title, and a supporting line.
- A scrollable 4-tab bar: Affirmations & Blessings, Stories & Fables, Mantras & Lullabies, Spiritual Reading.
- Each tab is a list of cards. A card shows an optional title, the read-aloud body in italic serif quotes, and a "Save" bookmark toggle.
- Spiritual Reading tab, when nothing is chosen, shows an explanatory card ("she picks the spiritual reading in her app, and it shows up here for you").

**Features & interactions:**
- Switch tabs to browse each category.
- "Save" bookmarks a piece into the shared `ReadToBabySavedStore` (so saved pieces are shared with the mother side); the icon toggles filled/outline.
- The father CANNOT customize. The Spiritual Reading tab is READ-ONLY and simply mirrors whichever traditions and sections the MOTHER enabled in `ReadToBabyStore`.

**Data:** Affirmations & Blessings draws from a distinct father slice (`readAloudFatherAffirmations()` in `read_to_baby_data.dart`). Stories & Fables uses shared `readAloudByCategory(kRtbStories)`. Mantras & Lullabies uses `samvadForTrimester(trimester)` plus `readAloudByCategory(kRtbRhymes)`. Spiritual mirrors `kSpiritualTraditions` filtered by the mother's `ReadToBabyStore` choices. Trimester derives from her live `currentWeek`. Note: this "Stories & Fables" tab is the SHARED mother Samvad story pool, which is separate from the original father tales in `father_tales.dart` used by the Reads-tab Stories screen. Content can be bilingual where the underlying Samvad data is.

## Screen: Father Reads / articles (`father/father_reads_screen.dart`)
**Status:** Live. The "Reads" tab in Father Mode.

**Reached from:** The Reads (3rd) tab of the father nav.

**Purpose:** Short read articles written for the dad - about her, the baby, and how to show up - plus the doorway into the Stories, Fables & Mythology tales.

**Sections & UI:**
- Header: "FOR YOU, DAD" eyebrow, "Reads" title, subtitle.
- A prominent slate "Stories, Fables & Mythology" card ("Tales to read aloud to the bump").
- "ARTICLES" section: a list of father read cards, each with an emoji tile, title, and "reading time - category".

**Features & interactions:**
- Tapping the tales card opens `FatherStoriesScreen`.
- Tapping an article card opens `_FatherReadReader` - a calm Slate reader showing the title, meta, and the body split into paragraphs.

**Data:** Articles come from `kFatherReadItems` (`father_read_data.dart`): five week-aware pieces (e.g. "What Your Baby Can Hear at 20 Weeks", "She's Halfway - What's Changing for Her", "The 20-Week Scan - How to Be There for Her", "Why Her Back Aches Now", "Feeling the First Kicks Together"), each with weekStart/weekEnd, category, emoji, and multi-paragraph body. English only.

## Screen: Father Stories, Fables & Mythology (`father/father_stories_screen.dart`)
**Status:** Live as a library screen, reached from the Reads tab. Note the related daily-home "Stories, Fables & Myth" card and a former Tools-section entry were REMOVED (kept commented in `father_daily_screen.dart` for revert). So the tales content still ships, just via the Reads tab only.

**Reached from:** The "Stories, Fables & Mythology" card on the Father Reads screen.

**Purpose:** A Slate-palette library of original, read-aloud tales the dad reads to the bump, each with a short "From Dad" framing note.

**Sections & UI:**
- Header: "FOR YOU TO READ ALOUD" eyebrow + "Stories, Fables & Mythology" title, with a back button.
- A segmented control: Stories / Fables / Mythology.
- A list of tale cards (kind tag chip, title, 2-line preview).
- Reading view (`FatherTaleReadScreen`): kind tag, title, a "Read it aloud" hint, the full body, an optional "THE LESSON" box (for fables), and a "FROM DAD" italic note box.

**Features & interactions:**
- Segmented control filters the list by kind.
- Tapping a tale opens the full reading view.
- Back button pops.

**Data:** `father_tales.dart` (`kFatherTales`): 60 original, IP-safe pieces - 20 stories, 20 fables, 20 mythology retellings - each with `title`, `body`, an optional one-line `moral` (fables), and a `dadNote`. `fatherTaleForDay(...)` (used by the parked daily card) rotates one piece per day across enabled kinds. English only. These original tales are distinct from the shared mother Samvad "Stories & Fables" used on the Read tab.
