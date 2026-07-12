# Today & Weekly Journey
_ParentVeda Pregnancy App - Feature & Screen Reference_

## Overview
"Today & Weekly Journey" is the daily home a mother lands on plus the week-by-week pregnancy experience it opens into. The bottom navigation "Today" tab (first tab) shows the Warm Nest daily home (`home_screen_b.dart`); its purple gradient hero card is the doorway into the weekly journey. Tapping the hero opens the Weekly Card Stack shell (`weekly_card_stack_screen.dart`), which now renders every week (4 to 40) as the vertical "Weekly Flow V2" (`week_flow_screen.dart`) with a fixed week strip, a collapsing trimester/progress header, and per-week content. Core concepts a tester should hold: pregnancy is tracked as weeks 4 to 40 (280 days) grouped into three trimesters; the app derives the current week/day from a due date; when no real due date is saved the app defaults to a week-20 "halfway" placeholder; and each week presents a selectable baby "size view" (Fruit vs Baby comparison). The Weekly Flow was formerly toggled between a "Classic" swipe carousel and a "New" (V2) vertical flow; that Classic/New toggle is now removed and V2 is the only weekly view (the classic carousel code is parked for revert). All week content is bilingual English + Hindi (Hinglish), stored as `{en, hi}` `LocalizedText`; the in-app English/Hindi toggle is currently hidden but the machinery is intact. Daily content is authored per week and gracefully falls back when a day is not yet authored. A testing-only Mom | Dad switch re-skins these screens into the father (Slate) preview.

Screens covered:
- `home_screen_b.dart` - the current Warm Nest "Today" home (Daily Moment)
- `home_screen.dart` - the older six-module daily home (legacy, no longer wired)
- `home_detail_screens.dart` - reader / story / talk-composer surfaces opened from the daily modules
- `weekly_card_stack_screen.dart` - the weekly journey shell (header, week strip, hosts the flow)
- `week_flow_screen.dart` - Weekly Flow V2, the vertical week sections and full-screen popups
- `week6_preview_screen.dart` - a static week-6 design prototype (not wired into the app)
- `watch_learn_screen.dart` - Today's Video card + the Watch & Learn video screen
- `read_next_screen.dart` - Read Next discovery, the Daily Reads home card, and the reader

## Screen: Warm Nest Today Home (`home_screen_b.dart`)
**Status:** Live - this is the mother's Home/"Today" tab, wired in `main_scaffold.dart` (`HomeScreenB(pregnancy, home)` at tab index 0). It replaced the older `home_screen.dart` (kept for revert).
**Reached from:** Bottom-nav "Today" tab (first tab). It is the app's landing screen for the mother.
**Purpose:** A warm daily briefing that gathers the day's rituals, this-week snapshot, and shortcuts into one scroll, and acts as the doorway into the weekly journey.

**Sections & UI (top to bottom in a scrolling list):**
- **Brand header** - ParentVeda logo/wordmark, plus three round buttons: a Saved/bookmark hub (opens `SavedHubScreen`), a Search icon (opens the global search sheet), and a gradient avatar showing the mother's initial (opens `ProfileScreen`; there is no separate Profile tab in this layout).
- **Post-Pregnancy doorway** - a coral/purple gradient banner "Post-Pregnancy / Baby's arrived? Step into the parenting app" that pushes the parenting app's My Child screen. This is a temporary preview doorway (the "40 weeks complete" hand-off is not wired yet).
- **Weekly Snapshot eyebrow + gradient hero card** - a purple gradient hero showing: a time-based greeting with the mother's name, "Week N - Day D", a one-to-two-line "this week" brief (the week headline, falling back to the reveal line), a "View week / open week" chevron affordance, and a circular progress ring showing percent complete plus a "weeks to go" line. Below a divider, three glassy shortcuts sit inside the hero: **Baby**, **Mother**, and **What's next**.
- **"Today's Journey" heading** - a sun icon plus the section title, under which all daily items live.
- **Today's Video card** - `TodaysVideoCard` (the week's recommended Watch & Learn pick; see the Watch & Learn screen).
- **Grow module** - the day's parenting insight (`GrowModule`).
- **Daily Garbh Sanskar** - a card listing the four live pillars, each with today's single rotating item: Shravan (listen), Vichara (thought), Samvad (speak), Kriya (action). Shows an N/5 done count and a streak. (Ahara/nourishment is commented out; the "5" goal is retained.)
- **Scans & appointments (due now)** - a teal card listing scans due around the current week (anchor week within a window) that are not yet completed, plus any upcoming saved appointments; each scan has an "Already done" button, and a "View all scans" link.
- **Trimester chart card** - `TrimesterChartCard`, a quick "where am I" reference.
- **My Journal (daily)** - four quick-entry tiles (Write memory, Note for baby, Add photo, Record voice) and a "View My Journal Timeline" link; all entries flow into the full `JournalScreen`.
- **Medication & supplements (daily)** - inline list of today's meds with a tick-to-take toggle; a bell action adds a personal reminder; her self-set reminders render below with edit/delete.
- **Daily Reads card** - `DailyReadsHomeCard` (rotating articles + books with a done tick; see Read Next).
- **Today's product recommendation** - a horizontal carousel of product cards (real photo, optional affiliate badge, name, price) that rotate by day; taps open the product page, and "See all" opens `ProductsScreen`.

**Features & interactions:**
- Tapping the hero card sets the selected week to the current week and pushes `WeeklyCardStackScreen` (the weekly journey). The hero "Baby", "Mother", and "What's next" shortcuts open the respective week detail popups directly (baby detail, mother detail, and the What's Next popup) without leaving Home.
- The progress ring and greeting are computed live: greeting varies by hour, progress is `currentDay / 280`, weeks-to-go is `40 - week`.
- Garbh Sanskar pillar rows each push their pillar screen in `daily: true` mode; done state and streak come from `GarbhStore`.
- Scan "Already done" calls `ScansStore.markCompleted` (also drops a journal entry); the list is driven by `scansDueAt(currentWeek)` filtered by completion.
- Medication tick calls `MedicineStore.toggleToday`; reminders are `ReminderStore` items edited via a reminder editor sheet.
- Journal tiles open text/photo/voice composers that save into the journal; the daily reads and product cards deep-link into their readers/pages.
- A number of older building blocks are present but commented out or parked for revert: a Daily/Weekly flow toggle, a standalone "rituals" strip (`_ritualsSection` opening `Grow/Read/Talk/GarbhSanskar/Nurture` modules in a draggable sheet), an affirmation card, and the "Read to your baby" `ReadModule` (folded into Garbh Sanskar's Samvad).
- The active day can be a preview day (`home.previewDay`) for content review, otherwise the real `pregnancy.currentDay`.

**Data:** `PregnancyController` (week/day/progress, names, language), `HomeContentController` (`dayFor`, `previewDay`, engagement), `HomeDay`/`GrowContent`/etc. from `lib/data/home/week_*.json` (bilingual), `WeekContent.snapshot` from `weekContent.json` for the hero brief, `GarbhStore`, `ScansStore` + `scan_schedule.dart`, `MedicineStore` + `ReminderStore`, `product_data.dart`. All text is English + Hindi via `LocalizedText`.

## Screen: Older Daily Home (`home_screen.dart`)
**Status:** Legacy / no longer wired - `HomeScreen` is not referenced by `main_scaffold.dart` (the mother now gets `HomeScreenB`, and the father gets `FatherDailyScreen`). It is kept intact in the codebase (it still imports and can delegate to `FatherHomeScreen` and `ReadNextHomeCard`) but is effectively unused in the shipping navigation. Treat it as a reference/earlier version.
**Reached from:** Not reachable through current navigation. (Historically it was the Home tab.)
**Purpose:** The original "Daily Moment" - a calm 4 to 6 minute arc of six modules rather than a dashboard.

**Sections & UI:**
- A `ModeToggle` (Mom/Dad) at the top; in father mode it returns `FatherHomeScreen`.
- A prototype `_PreviewBar` for stepping across days/weeks (buttons for +/- 1 day and +/- 7 days, a "today" reset, and a label flagging when the shown day is a not-yet-authored fallback).
- `HomeHeader` (greeting, week, snapshot, baby-learning, language toggle), `MomentSummary`, then the six daily modules in order: **Grow, Read (Read To Your Baby), Talk (Talk To Your Baby), Garbh Sanskar, A Moment For You (Nurture)**, and, from week 28+, **Baby Movement** (`MovementModule`).
- A `ReadNextHomeCard`, a `CompletionBanner`, and an `EmotionalCheckIn` at the end.

**Features & interactions:** The preview bar calls `home.setPreviewDay(...)`. The modules are the same widgets reused by the new home. Movement check-in appears only when `day.showsMovementCheckIn` (week >= 28). This screen carries the note "Remove before launch" on the preview bar.

**Data:** Same as the Warm Nest home - `PregnancyController`, `HomeContentController`, `FatherContentController`, `HomeDay` content (English + Hindi).

## Screen: Home Detail Screens (`home_detail_screens.dart`)
**Status:** Live - these are the reading/composing surfaces opened from the daily modules (Grow, Read, Talk) and the Garbh Sanskar info button. They are reached indirectly, not from a tab.
**Reached from:** The daily modules (`home_modules.dart`) on the Home screen open these: the Grow module's "Read more" opens `GrowReaderScreen`; the Read module opens `StoryReaderScreen`; the Talk module opens `TalkComposerScreen`; the Garbh module's "i" opens `showGarbhInfoSheet`. A father lesson variant (`FatherLearnReaderScreen`) exists for the father app.
**Purpose:** Full-text reading and message composition surfaces that back the daily moment.

**Sections & UI:**
- **`GrowReaderScreen`** - a full-page read of the day's parenting insight: quoted title, insight, expanded body, an optional "Deep dive" box (research/expert note, shown only when present), and a "Remember" gradient card.
- **`FatherLearnReaderScreen`** - the father equivalent (module label, title, insight, expanded, optional deep dive, remember) in the Slate palette.
- **`StoryReaderScreen`** - the "Read To Your Baby" story: quoted title, summary, and paragraphs. If the story allows audio, a "Listen" action in the app bar plays narration via `BabyVoiceService` (always narrates the English text because TTS cannot read Roman-script Hinglish, even when the UI is in Hindi).
- **`TalkComposerScreen`** - write or speak a message that saves into "Dear Baby": shows the prompt and its motivation, a full-height text field, and a mic button that dictates speech into the field via `speech_to_text`. Can auto-start with the mic (`startWithVoice`). Saving stores the entry in `DailyStore` (tagged as spoken if voice was used) and shows a confirmation.
- **`showGarbhInfoSheet`** - a draggable bottom sheet explaining a Garbh Sanskar ritual: "Why it matters" and "How to use it", with a "Got it" button.

**Features & interactions:** Audio play/stop toggles per card key; microphone permission is requested and a snackbar warns if unavailable; the composer pre-loads any existing message for the day. All are bilingual in UI text (English + Hindi), with narration forced to English audio.

**Data:** `GrowContent`, `ReadStory`, `TalkPrompt`, `GarbhSanskarDaily` (from `HomeDay`), `FatherLesson` (father), `DailyStore` (saved talk messages), `BabyVoiceService` (TTS), `speech_to_text` (dictation).

## Screen: Weekly Card Stack (`weekly_card_stack_screen.dart`)
**Status:** Live - the weekly journey shell. For the mother it is pushed from the Today home hero; for the father it is the "Journey" tab (tab index 1). It hosts the Weekly Flow V2 body.
**Reached from:** Mother: tap the Today home hero card (or its Baby/Mother/What's next shortcuts open the popups directly). Father: the "Journey" bottom-nav tab. Also reachable via `AppNav.goWeekly`.
**Purpose:** The frame around the per-week experience - app bar, a collapsing trimester/progress header, a scrollable week strip, and the week's content.

**Sections & UI:**
- **App bar** - ParentVeda logo/wordmark; a "‹ Daily" pill that hops back to the Today (Daily) tab (`AppNav.goToday`); and a round mute/unmute speaker button for the baby-voice narration (`BabyVoiceService`, journey scope). The English/Hindi language toggle (`_LanguageToggle`) is present in code but commented out (hidden for now).
- **Collapsing header** (`_WeekHeaderDelegate`) - a pinned compact row showing the trimester name, a "weeks to go" count, a purple progress bar, and "Week N - date range"; beneath it a collapsible week-dot strip that fades/shrinks as you scroll.
- **Week strip** (`_WeekBar`) - a horizontally scrollable single row of all weeks; the selected week is a filled purple disc (Slate in father mode), the current week gets a small accent dot, locked future weeks are greyed. Tapping a week selects it and auto-centers.
- **Body** - for an unlocked week it renders `WeekFlowView` (the V2 vertical flow). Week 40 appends a full-screen celebration finale (`CelebrationCard`, the keepsake booklet) at the bottom of the flow. Locked weeks render a `LockedWeekView` panel instead. Loading and error states are handled (spinner; a retry error state).

**Features & interactions:**
- Switching weeks snaps content back to the top and stops any playing baby voice; leaving the screen stops narration.
- Baby-voice can be muted/unmuted for the journey scope; the classic carousel had auto-play of the size-reveal and baby-update narration (that swipe carousel, `_pagerBody`/`_WeekStrip`/dots, is parked/commented for revert now that V2 is the only view).
- With `unlockAllWeeks` on (default true in the controller), no week is locked, so the whole 4 to 40 journey including the week-40 finale is reviewable.
- A testing Mom | Dad switch (`FatherPreview`) re-skins the whole shell into the Slate father look live.

**Data:** `PregnancyController` (`selectedWeek`, `availableWeeks`, `weekDates`, `isLocked`, `currentWeek`), `WeekContent` per week from `weekContent.json`, `BabyVoiceService`, `FatherPreview`, `buildWeekCards`/`CelebrationCard`. Bilingual English + Hindi throughout.

## Screen: Weekly Flow V2 (`week_flow_screen.dart`)
**Status:** Live - `WeekFlowView` is now the only weekly view, used for every week (4 to 40). The former Classic swipe carousel and the Classic/New toggle are removed from the UI (parked for revert). Week-20 content is the richest and is used as the fallback voice for the father preview; other weeks fall back to their per-week `WeekContent`. Several data blocks (facts, foods, videos) are curated in Dart and are prototype content.
**Reached from:** Rendered as the body of `WeeklyCardStackScreen` for the selected week.
**Purpose:** Re-flows a week as one vertical scroll of section "briefs"; tapping a brief opens a full-screen, descriptive popup (tabs/carousels/cards).

**Sections & UI (ordered down the scroll):**
- **S1 Size hero** (`WeekSizeHero`) - the "how big am I" hero: a circular progress ring (progress = week/40) around the comparison figure, a top milestone pill, a **selectable size view**, and three stat cards (**SIZE**, **LENGTH**, **WEIGHT**). The size view is a two-option segmented control offering exactly **Baby** and **Fruit** (no "everyday object" or "hand" options exist). It is backed by `SizeViewPref` (a single global boolean persisted in shared preferences under `size_baby_mode`; default is **Fruit**). In Baby mode it shows a real photo `assets/baby/week_NN.jpg` (falls back to the fruit emoji figure if that asset is missing); in Fruit mode it shows a food emoji. The size data (fruit, length, weight, milestone) comes from `WeekContent.snapshot` in `weekContent.json`, bilingual. (The week-6 static prototype shows the same Fruit/Baby toggle idea.)
- **S2 Weekly video** (`WeekVideoCard`) - the week's featured video tile: a 16:9 gradient placeholder thumbnail (no real media), a bookmark/save toggle (`VideoStore`), and a "why now" line. Tapping the thumbnail shows a "coming soon" snackbar - playback is not wired.
- **S3 About baby brief** - a `_SectionBrief` ("About your baby") showing `development.whatImDoing`; tap opens the **Baby Science popup** (`_BabyDetailScreen`).
- **S4 For you, mum brief** - a `_SectionBrief` showing `mom.emotionalState`; tap opens the **Mother detail popup** (`_MotherDetailScreen`). In father preview the title becomes "How she's doing".
- **S5 What's next brief** - a `_SectionBrief`; tap opens the **What's Next popup** (`_WhatsNextScreen`).
- **Daily moment bridge** (`_DailyMomentBridge`) - a subtle inline "your daily moment is waiting" link woven mid-flow that jumps back to the Today tab.
- **S6 This week's videos** (`_VideoFeed`) - a horizontal reels/shorts-style feed of vertical tiles built from a hardcoded list; every tile is a gradient placeholder with an always-on "NEW" badge and a placeholder duration. Taps show a "coming soon" snackbar (no real video).
- **This week's reads** (`_ArticleFeed`) - an articles carousel below the videos, shared by mother and father; it hides itself when the week has no articles. Tapping a card opens a full-screen `_ArticleReader` that splits the article body into paragraphs.
- **S6.5 Trimester tips** (`_TrimesterTips`) - three tips for the current trimester; tapping a tip opens a popup.
- **S7 Share with partner** (`_PartnerSection`) - a share card (hidden in father mode). Week 40 also appends the celebration finale passed in as `trailing`.

**Full-screen popups and their interactions:**
- **Baby Science popup (`_BabyDetailScreen`)** - opens from the "About baby" brief. It is one scrolling page: an "About your baby" article read (headings + body, with inline image/video placeholder frames where video frames tap to a "coming soon" snackbar), then a "Baby science" heading (`wfBabyScience`) with the "did you know" facts as vertical tap-to-read rows (emoji, title, two-line teaser); tapping a fact opens a centered dialog with the full fact. Content is bilingual (`_babyArticle` + `_babyScience`, with father-voiced variants in the preview).
- **Mother detail popup (`_MotherDetailScreen`)** - opens from the "For you, mum" brief. It has two top toggles (no swipe): **"You this week"** (index 0) and **"Health this week"** (index 1). The Health section has its own sub-toggle: **Symptoms** (0) and **Diet** (1). "You this week" is a woven article read (with inline image/video placeholder frames) plus this-week topic cards (each opening a centered dialog), a self-care tip, and a reassurance card, drawn from `mom` data and the curated `_motherTopics`/`_motherArticle` (with father-voiced variants for the preview). The **Symptoms** sub-tab lists common trimester symptoms; tapping one opens a draggable sheet (How common / Why / What helps / When to see a doctor). The **Diet** sub-tab ("Eat") shows the week's superfood, foods to favour, and foods to avoid. There is no separate "To-do" tab here - the old Actions/to-do cards were moved into the Trimester Tips section. In father preview only the "Her this week" read shows (no Health tab, since symptoms/diet are the mother's own voice).
- **What's Next popup (`_WhatsNextScreen`)** - opens from the "What's next" brief (and from the Home hero "What's next" shortcut). It is one page with a three-way tab row: **Scans (default, index 0)**, **For you (index 1)**, and **Milestones (index 2)**. The Scans tab lists week-relevant scans and appointments (tappable, from `kJourneyMilestones` medical items within a window around the current week) opening a scan detail dialog; the For you tab is a forward look at the next few weeks for the mother (physical-changes teaser per week, tap opens a Body/Feel/self-care dialog); the Milestones tab lists happy per-week milestones (from `_weekMilestones`), each opening a centered detail popup. In the father preview the What's Next popup collapses to a re-voiced Scans-and-appointments-only view with a "how to show up" help block.
- **Trimester tip popup** and **milestone/scan detail popups** open as centered dialogs from their lists.
- **Article reader (`_ArticleReader`)** - opens a full "This week's reads" article; the article feed is driven by `weekArticlesFor(week)`.
- **Partner share (`_PartnerSection`)** - composes a share message (scan reminders + partner-help lines) and shares it via the system share sheet (`share_plus`).

**Features & interactions:**
- There is no baby-voice narration or audio playback inside this vertical flow (audio lives in the weekly shell's mute button context and in the story reader, not in `WeekFlowView`). The word "voice" in this file refers to editorial tone (father re-voicing), not TTS.
- Tapping section briefs pushes full-screen popups (`_PopupScaffold`, close X in the app bar); popups use in-page toggles rather than swipe (`setState`, no `PageView`).
- The Baby/Fruit size toggle writes to `SizeViewPref` (global, persisted) and updates the hero live; the weekly video bookmark toggles `VideoStore`.
- The "daily moment bridge" jumps to the Today (Daily) tab; the "‹ Daily" hop in the shell app bar keeps the daily<->weekly loop two-way.
- Sharing (S7) uses the system share sheet (`share_plus`) with an assembled bilingual partner message; a failure shows a snackbar.
- **Father (Dad-preview) re-skin:** `_fatherSkin(week)` applies the Slate palette on every week; `_fatherWeek(week)` (true only on week 20 while the Dad switch is on) swaps in re-voiced, partner-facing copy. Per-week father briefs exist (`_fBabyBriefs`, `_fMotherBriefs`) for weeks 4 to 40; where a week is not yet re-voiced, the mother's per-week content shows in the Slate skin. This is a testing preview to be stripped before launch.

**Data:** `WeekContent` (`weekContent.json`, bilingual), curated Dart constants in this file (baby-science facts, foods to eat/avoid, to-dos, week videos, milestones, mother topics, partner-help lines), `journey_milestones.dart`/`kJourneyMilestones`, `symptom_data.dart`, `trimester_tips.dart`, `week_articles_data.dart` (`weekArticlesFor`), `SizeViewPref`, `BabyVoiceService`, `FatherPreview`, `AppNav`, `share_plus`. All primary content is English + Hindi; the "This week's reads" articles are currently English-only prototype text (week 20 and week 21 seeded).

## Screen: Week 6 Design Preview (`week6_preview_screen.dart`)
**Status:** Prototype / Preview - explicitly a temporary, self-contained visual mockup wired for week 6 only. It is not hooked into the real card-stack flow (all values are hard-coded and its buttons are inert). It is only shown if `main.dart` is pointed at it instead of the real home. Treat everything here as static.
**Reached from:** Not in normal navigation - only by manually pointing the app's `home:` at `Week6PreviewScreen`.
**Purpose:** To preview how a proposed week home layout looks, using week-6 numbers (pomegranate seed, 4 to 6 mm, under 1 g).

**Sections & UI:**
- A top bar (logo, static "EN" pill, "Week 6 of 40"), a "Trimester 1" progress bar (15%), a hard-coded "12 - 18 FEB" date range, and a week strip of 4,5,[6],7,8 with 6 selected.
- A **Size card** ("How big am I?") with a milestone pill ("THE BEATING HEART"), a decorative seed halo, a **FRUIT / BABY** toggle (visual only), the "a pomegranate seed" label, LENGTH and WEIGHT metric tiles, and a week-6 headline plus a first-person baby line.
- An **Upcoming Milestones** timeline (weeks 7, 8, 12) with a "VIEW FULL TIMELINE" button, a **Daily Read** card ("Surviving Morning Sickness"), page dots, and a bottom nav (MAIN/LIST/COUNTERS/SETTINGS).

**Features & interactions:** None are functional - the FRUIT/BABY toggle, "VIEW FULL TIMELINE", nav, and dots are static. This is purely a look-and-feel prototype.

**Data:** All values are hard-coded in Dart (no controller/JSON binding). Text is English only.

## Screen: Watch & Learn / Today's Video (`watch_learn_screen.dart`)
**Status:** Live UI, mock playback - the cards and screen are live, but real video playback is not wired: opening a video shows a calm detail sheet with a "coming soon" note. Thumbnails are gradient placeholders (no real media yet).
**Reached from:** `TodaysVideoCard` sits on the Today home (below the hero). Its "More videos" link and the Today video both open into the full `WatchLearnScreen`. `WeekVideoCard`/`_VideoFeed` in the weekly flow surface videos too.
**Purpose:** Contextual learning videos - "the right video at the right time", not a general library.

**Sections & UI:**
- **Today's Video card** (Home) - shows the week's recommended video: gradient thumbnail with a play glyph and duration chip, title, a "Why now" reason line, a "Watch" button, and a bookmark/save toggle.
- **Watch & Learn screen** - horizontal-scrolling rails by category: **Recommended, Learn a Skill, Expert Explains, Birth Prep, Newborn Prep**, and **Saved**. Each rail is filtered to videos matching the current week; empty rails hide themselves. Cards show a thumbnail, title, and reason.
- **Video detail sheet** - a bottom sheet with a large thumbnail, title, duration, a "Why now" reason, a "coming soon" playback note, and a Save/Saved toggle.

**Features & interactions:** Tapping a card or "Watch" opens the detail sheet (no actual playback). Bookmarking toggles `VideoStore.toggle(id)`; saved videos appear in the "Saved" rail and drive the card's bookmark state. The recommended pick is chosen by `matchesWeek`, falling back to the nearest-week recommended video.

**Data:** `PvVideo` items in `kVideos` (`pv_video.dart`), each bilingual (English + Hindi) with a title, "why now" reason, duration, category, and week range; `VideoStore` for saved state; category colors/icons from `kVideoMeta`. All durations/reasons are authored metadata; `videoUrl` playback is a later addition.

## Screen: Read Next & Daily Reads (`read_next_screen.dart`)
**Status:** Live - reading discovery and the reader are functional. Book "Buy now" is a "coming soon" snackbar (mock commerce); article bodies and status tracking are real.
**Reached from:** The **Daily Reads** card (`DailyReadsHomeCard`) and, in the legacy home, the **Read Next** card (`ReadNextHomeCard`) sit on Home; both push the full `ReadNextScreen`. Individual items open `ReadItemScreen`.
**Purpose:** A week-aware reading feed where recommendations are primary and every item explains "why this matters now".

**Sections & UI:**
- **`ReadNextScreen`** - a subtitle, a hero "This Week's Pick" card (emoji, title, category, reading time, a gold "Why now" box, "Read now"), then sections that appear when non-empty: **Recommended** (this week), **Looking ahead** (with a "coming up in week N" label), **Books** (a horizontal rail of book cards), **Research** (simplified), **Experts** (recommended-by cards), and **Saved**. A search icon opens a `SearchDelegate` over the reading catalog.
- **`DailyReadsHomeCard`** (Home) - a gradient-header card titled from `drTitle` with an **Articles** group (day-rotating) and a **Books** group; each row has an emoji thumbnail (category-tinted), title, category/reading-time (or rating/author for books), a done tick when completed, and a save heart; a "See all" link opens `ReadNextScreen`.
- **`ReadNextHomeCard`** (legacy home) - a compact "This Week's Pick" entry with "Read now" and "More reading".
- **`ReadItemScreen`** (reader) - centered emoji, title, author/category, the "Why now" box, an optional "recommended by" line, then either the article body (split into paragraphs) or a "why we recommend" card for books. Bottom actions: "Mark reading" (toggles a gold "reading" status) and "Mark done"/"Completed".

**Features & interactions:**
- Save/heart toggles `ReadNextStore.toggleSave`; saved items surface in the Saved section and the Profile saved hub.
- Status: "Mark reading" sets `reading`; "Mark done" toggles `ReadDoneStore` and sets/clears `completed` in `ReadNextStore` - completed and reading are mutually exclusive, and marking done in the reader also ticks the Home daily-reads checkbox (shared `ReadDoneStore`).
- Book "Buy now" shows a "coming soon" snackbar; "Know more" opens the item.
- Search runs `readSearch(query)` and opens results in the reader.
- Recommendations are computed from the current week: `heroForWeek`, `recommendedForWeek`, `lookingAhead`, and `readByType` for books/research/experts; daily reads use `dailyArticleReads(week, day)` and `dailyBookReads(day)`.

**Data:** `ReadItem` records from `read_next_data.dart` (title, emoji, category, reading time, "why now" reason, body, author/role, rating), `ReadNextStore` (saved + reading/completed status), `ReadDoneStore` (done ticks). Item metadata reasons are shown as "why now"; note the reading catalog text is largely English (the reader UI labels follow the selected language).
