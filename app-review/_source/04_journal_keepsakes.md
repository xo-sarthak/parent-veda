# Journal, Keepsakes & Journey Map
_ParentVeda Pregnancy App - Feature & Screen Reference_

## Overview
This area holds the app's memory-keeping and milestone features: a rich diary ("My Journal"), a week-by-week belly-photo timeline ("My Bump Journey"), a read-only vault of saved "Dear Baby" messages, a keepsake PDF booklet built at the end of pregnancy, and a stylized "map" of the whole pregnancy as a winding trail of milestone stops. Most of these are reached from the Profile tab's keepsake cards and from the Tools hub; the Journey Map also appears in the Tools screen and global search. Two separate note systems exist and must not be confused: the full "My Journal" (rich, filterable timeline, `JournalStore`) and a lighter per-week note used inside the weekly card flow and the finale booklet (`MemoryStore`, one entry per week with up to two photos). Key concepts a tester should know: the "Combined" (you + Dad) booklet is a distinct mode toggled by its own app-bar icon; the milestone map computes each stop's date from the mother's due date and lets her override a few personal dates; and photos captured in the Bump Journey are automatically mirrored into My Journal and the Calendar. Content is bilingual (English + Hindi) throughout. Note that the father-side journal (`father_journal_store`, `FatherJournalScreen`) is out of scope here and is documented in the Father Mode reference; it surfaces in this area only as read-only entries inside the mother's Combined view.

Screens covered:

- My Journal (`journal_screen.dart`)
- Weekly Note Composer / Journal Writer (`journal_writer_screen.dart`)
- Journey Booklet + PDF Export (`journey_booklet_screen.dart`)
- Dear Baby Vault (`dear_baby_vault_screen.dart`)
- My Bump Journey (`bump_journey_screen.dart`)
- Pregnancy Journey Map (`journey_map_screen.dart`)
- My Baby (`my_baby_screen.dart`)
- Photo Viewer (`photo_viewer_screen.dart`)

## Screen: My Journal (`journal_screen.dart`)
**Status:** Live. Fully interactive with local persistence and cloud sync. Voice-memory playback works; the app-bar "export/share" action is a placeholder that only shows a "coming soon" snackbar.
**Reached from:** Profile tab -> "My Journal" keepsake card; Tools hub -> "My Journal" tile; the Warm Nest Home screen; the Calendar screen; and global search. All push `JournalScreen(controller:)`.
**Purpose:** A chronological, emotional memory feed (newest first) that mixes the mother's own entries with auto-generated milestones and health logs, so the journal feels alive without double-logging.

**Sections & UI:**
- App bar with the title "My Journal" and action icons: view toggle (list vs booklet), a "Combined - you + Dad" toggle (people icon), search, an info button, and a share/export button.
- Filter chips row: All, Memories, Photos, Milestones, Health, Scans, Baby. Selecting a chip filters the feed.
- A "Group by" control (Month or Week), shown in list view for every filter except Photos.
- List view: collapsible group headers (month name, or "Week N" with a date range) each showing an entry count and a chevron. Only the most recent group is expanded by default. Inside a month, entries are further split into per-week sub-sections.
- Entry cards: colour-coded left border by category, a category icon, title, description, an optional week badge, per-entry date and time, an optional photo (single banner) or photo carousel, and a voice-note carousel of play chips. Partner (father) entries show a "From [father name]" tag.
- Photos filter: replaces the list with a 3-column photo grid pulled from all entries' images.
- Booklet view: a flip-through "diary" with a cream cover page (mother's name, week range) and one cream, ruled-paper page per day, with page-flip animation and previous/next arrows plus a "page X / N" counter.
- Empty state: filter-aware icon and text explaining where that category fills from, plus an "info" button.
- Floating "+" button opens the create sheet.

**Features & interactions:**
- Create (via the "+" sheet): Write a memory, Note for baby, Add photo, or Record voice. (A "custom tag" entry type exists in code but its create option is commented out; existing custom entries still display.) These open shared composer flows in `widgets/journal/journal_create.dart`.
- Add photo: choose camera or gallery; gallery allows multiple images (a carousel).
- Record voice: real on-device recording (via the `record` package), multiple clips per entry, each playable and deletable before saving.
- Edit: tap a manual entry to edit (text entries re-open the composer; photo/voice entries open a caption editor). Auto entries and partner entries are read-only (no tap, no long-press).
- Delete: long-press a manual entry -> confirm dialog. Deleting also removes the entry's photo/voice files.
- Search: app-bar search filters by title and description.
- Combined (you + Dad): the people icon toggles a merged booklet that interleaves the mother's full timeline with the father's manual entries, each entry tagged "You" or "Dad", newest first. This is the only place father entries appear in her journal; her own List/Booklet stay hers alone.
- Info sheet: a bottom sheet explaining what feeds each category (memories, notes for baby, photos, milestones, health, scans).

**Data:** `JournalStore` (singleton, `ChangeNotifier`). Manual entries persist to `shared_preferences` (key `journal_entries`) and sync to the Supabase `journal_entries` table when logged in; photo/voice files are copied into the app documents `journal/` folder and uploaded to Storage. The timeline merges manual entries with auto entries derived at runtime: milestones from `data/journey_milestones.dart` (achievement, baby-development, ParentVeda-journey, and mother types, dated back from the due date) and health logs (weight entries from `ToolsStore`). Kick sessions and scans are intentionally excluded (kicks are commented out; scans are planned from real logs). Partner entries are fetched read-only from the cloud `father_journal_entries` table. Model: `models/journal_entry.dart` (`JournalEntry` with type, title, description, date, weekNumber, image/audio lists, `isAutomatic`, transient `isPartner`); per-type colour/icon in `kJournalMeta`.

## Screen: Weekly Note Composer / Journal Writer (`journal_writer_screen.dart`)
**Status:** Live. Write and speech-to-text both functional; photo capture is camera-only.
**Reached from:** The weekly card stack's "Memories"/"Your Week" section (`memories_section.dart`) for a given week; the Journey Booklet screen's "Add memory" buttons; not reached from the main "My Journal" screen above (this is a different, per-week note system).
**Purpose:** A single gentle composer for one weekly reflection: one prompt ("How was your last week?") that the mother can type or speak, plus up to two photos kept with the note. Creates a new weekly entry or edits the existing one.

**Sections & UI:**
- App bar titled "My Journal" with a "Save to journal" text action (check icon).
- A "Week N" pill (English "Week"/Hindi "Hafta").
- The prompt text as a heading.
- A photo strip: existing photos (up to two) with a remove "x" badge each, plus an "Add up to two photos" tile (shows a spinner while capturing).
- A large multi-line text field (expands to fill the screen) with a placeholder that switches to "Listening..." while dictating.
- A full-width mic bar at the bottom that toggles voice dictation; it turns solid/coloured while listening.

**Features & interactions:**
- Type freely in the text area.
- Mic bar: starts/stops on-device speech-to-text (via `speech_to_text`); recognized words append to whatever is already typed. If permission is missing, a snackbar prompts for it.
- Add photo: captures via the camera (`MemoryStore.capturePhotoFile`); enforces a max of two (over-limit shows "photo limit reached").
- Remove photo: tap the "x" on a thumbnail.
- Save: if the entry already exists it updates in place, otherwise it creates one; empty text with no photos just exits without creating an empty note. A "saved" snackbar confirms.

**Data:** `MemoryStore` (singleton, `ChangeNotifier`), a per-week note store separate from `JournalStore`. Notes persist to `shared_preferences` and sync to the Supabase `weekly_journal_notes` table; photo files live in the app documents dir and upload to Storage. Model: `models/memory_models.dart` (`JournalEntry` with week, source, prompt, text, up to two `photoPaths` - a different class from the timeline's `JournalEntry`). One entry per week is enforced (a migration collapses any legacy duplicates and keeps at most two photos). Note for testers: `MemoryStore` and `JournalStore` both use the local `shared_preferences` key `journal_entries`, so these are architecturally distinct systems that happen to share a local key name.

## Screen: Journey Booklet + PDF Export (`journey_booklet_screen.dart`)
**Status:** Live. Builds and previews a real multi-page PDF; sharing/printing work through the system share sheet.
**Reached from:** The week-40 celebration card (`week_cards/celebration_card.dart`) -> "create keepsake" action, which pushes `JourneyBookletScreen` with per-week date ranges and a completion date.
**Purpose:** The end-of-pregnancy keepsake flow. It first lists weeks that still have no memory so the mother can fill gaps, then generates a warm, blush-and-cream PDF booklet of her journey and opens an in-app preview with share.

**Sections & UI:**
- App bar titled "Booklet preview".
- A heading and intro: if any weeks lack content, "some weeks are missing" plus a count; if all weeks have content, "no missing weeks".
- A list of "missing week" rows (weeks 4-40 that have no note or photo), each with the week label, its date range, and an "Add memory" button.
- A full-width bottom button: "Create now" (shows a spinner and "Building booklet..." while working).
- After creation, a second screen (`_BookletPreviewScreen`) shows the rendered PDF with a share action and the printing/sharing controls of the PDF preview widget.

**Features & interactions:**
- "Add memory" on a missing week opens the Weekly Note Composer for that week (pre-loading any existing entry), then returns and refreshes the missing-week list.
- "Create now" gathers every week that has content, builds the PDF, saves it to the app documents dir as `parentveda_journey_<timestamp>.pdf`, and opens the preview. Failure shows a "booklet failed" snackbar.
- In the preview: share the PDF file (system share sheet; the tooltip references forwarding to WhatsApp), or use the built-in print/share controls.

**Data:** Reads weekly notes from `MemoryStore` (`journalForWeek`). The PDF is built by `services/journey_pdf.dart` (`JourneyPdf.build`): a decorated cover page, one page per week that has content (big serif week number, date range, the note text, and one or two framed photos), and a closing page, all on cream pages with botanical corner art and the Fraunces/Nunito fonts. Uses the `pdf`, `printing`, `share_plus`, and `path_provider` packages.

## Screen: Dear Baby Vault (`dear_baby_vault_screen.dart`)
**Status:** Live but read-only (no create/edit/delete here). Entries originate elsewhere (the "Talk to your baby" / Samvad flows).
**Reached from:** Profile tab -> "Dear Baby" keepsake card, which shows a live entry count.
**Purpose:** A gentle vault surfacing every "Talk to your baby" message the mother has saved, so she can revisit them.

**Sections & UI:**
- App bar with the "Dear Baby" vault title.
- A scrollable list of cards, each showing: a "Week N" pill, the date, the prompt (if any), the message body, and a "Spoken" or "Written" tag with a small heart icon.
- Empty state: a heart icon and an encouraging message when nothing has been saved yet.

**Features & interactions:**
- Read-only scrolling and reading. There are no create, edit, delete, or share actions on this screen.
- The list updates live as new talk entries are saved elsewhere in the app.

**Data:** `DailyStore` (singleton). It reads `DailyStore.talkEntries` (each has week, date, prompt, text, and a `spoken` flag). No local writes happen here.

## Screen: My Bump Journey (`bump_journey_screen.dart`)
**Status:** Live. Photo capture, captions, favourites, compare, and filters all work. The app-bar "export" action and a "replay/memory-book export" are placeholders (export shows a "coming soon" snackbar).
**Reached from:** Profile tab -> "My Bump Journey" keepsake card (with a photo count); Tools hub -> "My Bump Journey" tile; global search.
**Purpose:** A warm, editorial belly-photo timeline (a keepsake, not a gallery): one photo per week with milestone markers woven in, gentle "capture this week" nudges, captions, favourites, and a Then-and-Now compare.

**Sections & UI:**
- App bar titled "My Bump Journey" with a compare action (only when there are 2+ photos) and an export action.
- A progress card: current week of 40, photos-added count, and percent complete, with a "Then & Now" button when 2+ photos exist.
- Filter chips: All, 1st/2nd/3rd trimester, Captioned, Favourites.
- A "capture this week" prompt card when the current week has no photo yet.
- A vertical timeline of photo cards, each with the week label, date, trimester name, a favourite (heart) toggle, and an overflow menu. Milestone divider badges are inserted at weeks 12, 20, 28, and 37 ("first trimester done", "halfway", "third trimester starts", "full term").
- Each photo card: a large image, plus a caption (or a tap-to-add caption hint in italics).
- Empty state: a pregnant-woman icon, intro text, and an "add your first" button.
- Floating action button to add a photo.

**Features & interactions:**
- Add photo: bottom sheet to take a photo (camera) or upload (gallery). After picking, a sheet lets the mother set the week (a stepper clamped to 4-40), type a caption, tap suggested captions, and save.
- Favourite: heart toggle on each card.
- Overflow menu per photo: "Edit caption" (a bottom-sheet editor) or "Delete" (confirm dialog).
- Then & Now compare: opens a side-by-side screen with a heart between two photos and two pickers to choose which weeks to compare (defaults to first vs latest).
- Every added photo is mirrored into My Journal as a Photo entry and therefore into the Calendar.

**Data:** `BumpStore` (singleton, `ChangeNotifier`). Metadata persists to `shared_preferences` (key `bump_photos`) and syncs to the Supabase `bump_photos` table; image files live in the app documents dir and upload to Storage. Model: `models/bump_photo.dart` (`BumpPhoto` with id, imageUrl, weekNumber, date, caption, isFavorite; trimester derived from week). On add, `BumpStore` also creates a mirrored `JournalStore` photo entry with id `bump_<id>` (its own file copy), and deleting the bump photo removes that mirror.

## Screen: Pregnancy Journey Map (`journey_map_screen.dart`)
**Status:** Live. The trail, node cards, celebrations, date editing, and catch-up flow all work. Some milestone "feature" nodes launch real tools; a few (for example the hospital-bag feature node) fall back to a "coming soon" dialog.
**Reached from:** Tools screen; Tools hub -> Journey Map tile; global search. All push `JourneyMapScreen(controller:)`.
**Purpose:** A Google-Maps-style winding trail from Week 4 to Birth. Week checkpoints open the weekly card stack; milestone nodes open their own cards. A progress header and a pulsing "you are here" marker anchor the mother in her journey.

**Sections & UI:**
- App bar titled "Your Pregnancy Journey".
- A fixed header trail card: a kicker, "N weeks to go" (or "now"), and a circular percent-complete ring.
- Optional banners under the header: an "overdue" note past the due date, and a late-joiner "catch up" banner (dismissable) inviting her to set real dates for moments already behind her.
- The trail itself: a single scrolling, winding path drawn top (start / Week 4) to bottom (Birth). Path colour shows progress (behind "now" is coloured, ahead is lighter/dotted).
- Nodes along the trail:
  - Week checkpoints (weeks 4, 8, 12, ... 40): numbered circles sized/coloured by state.
  - Milestone nodes: small coloured discs with a type icon (achievement, medical, baby-development, mother, ParentVeda-journey, feature), each carrying a small emoji.
  - The final "Birth" node: a white disc with a radiating glow that is faint while locked and bright once reached.
- Caption pills below nodes: "Start", "You're here" (on the current week), "Welcome" (Birth), and each milestone's title with its date (or a "Set date" nudge for undated personal moments).

**Features & interactions:**
- On first open, the map auto-scrolls so the current-week checkpoint sits near the upper-middle of the screen. Landing is always on the whole week node, not the fractional day between weeks.
- Node states: week checkpoints are "completed" (before current week), "current" (this week, pulsing), or "future". Milestones are "reached" when their pregnancy-day position is at or before the current day.
- Tap a week checkpoint (circle or pill): selects that week and opens the Weekly Card Stack.
- Tap a milestone: a major milestone already reached (achievement or ParentVeda-journey) shows a full-screen celebration; otherwise an adaptive bottom-sheet card opens (info/preview) with type-specific content, a timing line, sections/bullets, a medical disclaimer for medical nodes, and an action button ("View Week N", "Launch" a tool, or "Continue"). Future milestones show an "expected in N weeks" note.
- Date editing: only two kinds of milestone can be dated by the mother - clinic appointments (medical nodes) and the two witnessed moments (first movements felt, and the bump's first kicks). Their card shows an edit-date button (a date picker); the map then displays her chosen date. Other milestones are read-only, dated from the due date.
- Catch-up sheet: lists undated personal moments already behind "now" so a late joiner can set when each actually happened. "All caught up" shows when none remain.

**Data:** Nodes are assembled by `services/journey_nodes.dart` (`buildJourneyNodes`), merging the ten week checkpoints (`kWeekCheckpoints`) with every authored milestone from `data/journey_milestones.dart` (`kJourneyMilestones`, bilingual content), sorted by pregnancy day. Model: `models/journey_node.dart` (`MapNode`, `JourneyMilestone`, `JourneyNodeType`; `posDay` from anchor week or explicit anchor day; `isDatable` gates the edit button). Dates are computed from the mother's due date via the `PregnancyController` (`currentDay`, `currentWeek`, `dueDate`, `dateForDay`, `progress`, `isOverdue`, `daysPastDue`). Personal date overrides persist in `JourneyDatesStore` (`shared_preferences` key `journey_dates`, cloud-synced), which changes only the displayed date, not the node's trail position. Trail geometry/painting and node/card widgets live in `lib/widgets/journey/` (`journey_geometry.dart`, `journey_path.dart`, `journey_node.dart`, `node_cards.dart`, `journey_celebration.dart`, `journey_palette.dart`).

## Screen: My Baby (`my_baby_screen.dart`)
**Status:** Orphaned / not currently wired. The class exists and is complete, but `MyBabyScreen` is not referenced or instantiated anywhere in the current codebase (a repo-wide search finds only its own definition). Its header comment describes it as "the My Baby tab", but the live navigation reaches the weekly journey through other entry points (for example the My Baby/My Child cards and the Journey Map week nodes). Treat it as retained-for-revert code, not a reachable screen. A tester will not encounter it through normal navigation.
**Reached from:** Not reachable in the current build (no navigation references it).
**Purpose:** A calm landing page for the "My Baby" concept: a single hero card the mother taps to open her current week's full journey.

**Sections & UI:**
- A large heading ("My Baby").
- One gradient hero card: an icon, a "Week N" pill, a title and subtitle, and an "Open weekly journey" call to action with an arrow.

**Features & interactions:**
- Tapping the hero card selects the current week and opens the Weekly Card Stack (`WeeklyCardStackScreen`), always starting at the mother's current week regardless of where she last browsed.

**Data:** Reads only from the `PregnancyController` (current week, language). No store or persistence of its own.

## Screen: Photo Viewer (`photo_viewer_screen.dart`)
**Status:** Live utility.
**Reached from:** Tapping a photo thumbnail inside the weekly "Memories"/"Your Week" cards (`memories_section.dart`). It is a shared full-screen image viewer for weekly-note photos.
**Purpose:** A full-screen, zoomable viewer for a single memory photo, with a small week and date label.

**Sections & UI:**
- Full-screen black background with a transparent app bar and a white back button.
- The image, centered and zoomable.
- A rounded label pill at the bottom-left showing "Week N" (English "Week"/Hindi "Hafta") and the entry's date.

**Features & interactions:**
- Pinch/drag to zoom and pan (scale 1x to 4x via `InteractiveViewer`).
- Back button to dismiss. No edit, delete, or share here.

**Data:** Takes a `PhotoMemory` (from `models/memory_models.dart`) and the language. It only displays the passed-in photo path (rendered via `StorageImage`, which resolves local or cloud paths); it does not read or write any store.
