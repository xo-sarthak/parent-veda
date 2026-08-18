# Session: Weekly Flow V2 & Daily-Screen Overhaul + Continuation (22–26 June 2026)

> A complete, detailed record of the ParentVeda work done across 22–24 June 2026:
> the new **Weekly "V2" vertical flow** for Week 20, a full **Daily/Home screen
> overhaul**, the **Daily Journal** feature (with real voice recording), a
> **Calendar** rework, and a long tail of UX refinements. Every change kept
> `flutter analyze` clean and followed the repo's "comment‑out, never delete"
> rule.
>
> **§9 (added 25 June) extends this** with the rest of the session: Community
> (Pro + test Doctor mode), the Product‑Checklist flow rework + Cart/affiliate
> products + the Saved hub, Read‑to‑baby + the full Spiritual‑reading content
> expansion, the Journal grouped/booklet views, the Journey‑map direction +
> animation work, Calendar markers, and the big **AskVeda** build (offline
> whole‑app retrieval + 5 structured web‑researched showcase answers +
> stage‑wise rotating suggestions).
>
> **§10 (added 26 June)** continues further: the **Journey/Journal refinements**
> (weekly landing, milestone dates + edit, per‑entry date, booklet backdrop), the
> full **Twitter/X‑style Community revamp** (cards, feeds, follow‑experts,
> profiles, compose FAB), and the **"Ask Veda Results" redesign** (a
> search→structured‑result page pulled from Claude Design). **Read §9–§10 for
> everything after the Calendar — §10 is the newest.**

---

## 0. Overview & working agreements

ParentVeda is a Flutter pregnancy‑companion app (Warm‑Nest / "Direction B" visual
language). This session reshaped two big surfaces — the **weekly card view** and
the **daily/home screen** — plus added the **Journal** and reworked the
**Calendar**.

**Standing rules honoured throughout:**

- **Comment out, never delete.** Removed features/code are commented or gated
  (`if (!daily)`, `// ignore: unused_element`), never deleted — for easy revert.
- **`flutter analyze` must be clean** after every change ("No issues found!").
- **Bilingual** everywhere: English + Hinglish (Roman script, no Devanagari) via
  the `S` class (`_p('English','Hinglish')`) in `lib/localization/app_language.dart`.
- **Theme tokens only** (`AppTheme`): primary #6A30B6, coral/secondary #FF5A79,
  tertiary, lavender surfaces, fonts Fraunces / Plus Jakarta Sans / Manrope.
- **User runs all `git` and `flutter run`** themselves; assistant only edits + analyzes.
- **Testing pin:** the whole app is pinned to **Week 20** (see §2.1) so Home and
  "View week" land on the new flow.

**Two background "fork" agents** were used for large, well‑specified builds (the
daily Garbh and the Journal); everything they produced was verified with a fresh
`flutter analyze` and spot‑checks.

---

## 1. Weekly Flow "V2" (Week 20)

The weekly view was a **horizontal carousel of cards** (`WeeklyCardStackScreen`).
For Week 20 we built an alternative **single vertical scroll of sections** ("V2"),
kept **side‑by‑side** with the classic carousel via a toggle so they can be
compared before committing.

### 1.1 The Classic ⟷ New toggle
`lib/screens/weekly_card_stack_screen.dart`
- `bool _v2 = true` (defaults to **New**).
- `_v2Toggle()` — a small segmented pill shown in the AppBar **actions only when
  `selectedWeek == 20`**.
- `_buildBody` keeps the scrolling trimester/week **header** (`_WeekHeaderDelegate`,
  not pinned) and **only swaps the NestedScrollView body** to `WeekFlowView` when
  `selectedWeek == 20 && _v2`. The classic carousel path is byte‑for‑byte intact.

### 1.2 The vertical flow — `lib/screens/week_flow_screen.dart`
`WeekFlowView` is a vertical `ListView` of 7 sections. Info sections show a brief
and open a **full‑screen pop‑up** (`_PopupScaffold` = purple AppBar + close X).

1. **Size hero** — reuses `WeekSizeHero` (extracted/renamed from the private
   `_Hero` in `week_overview_card.dart`).
2. **Weekly video** — reuses `WeekVideoCard` ("Watch this week").
3. **About your baby** → `_SectionBrief` → `_BabyDetailScreen`.
4. **For you, mum** → `_MotherDetailScreen`.
5. **What's next** → `_WhatsNextScreen`.
6. **This week's videos** → `_VideoFeed` (the only genuinely NEW feature — an
   Instagram‑reels‑style feed; placeholder thumbnails).
7. **Share with your partner** → `_PartnerSection` (rich WhatsApp summary).

Shared helpers: `_swipeOverlay` (swipe‑hint pill + page dots, used by the
read‑first pop‑ups), `_popupTitle`. All copy lives in the `wf*` string block.

### 1.3 Section‑by‑section refinements (the bulk of the iteration)

**Section 2 — Watch this week**
- Bookmark moved into the title row (compact, top‑right).
- **"Why this matters" accordion removed** (commented) — just the video now.

**Section 3 — About your baby** (`_BabyDetailScreen`, Stateful + `PageView`)
- Opens **read‑first**: page 0 = the rich **`_babyArticle`** (You're halfway · How
  big · Movements · Baby can hear you · Tasting · Skin/vernix · Sleeping) +
  medical disclaimer. ("Milestones around now" was later **removed** — milestones
  live in What's‑next.)
- Swipe → **Baby Science**: a **persistent bold "Baby Science" heading** overlay
  (shows on `_page >= 1`, so "the page stays, only the slides change") + each
  fact a centred hero `_factSlide` (big emoji disc + title + desc + "n / N").
- **De‑duplicated**: `_babyScience` re‑authored as distinct "did‑you‑know"
  trivia (busy brain, tiny grip, hiccups, prints, strong heartbeat, senses
  light) so it no longer mirrors the article.
- Strings: `wfBabySection`, `wfBabyScience`, `wfSwipeHint`, `wfDisclaimer`.

**Section 4 — For you, mum** (`_MotherDetailScreen`, Stateful + `PageView`, 4 pages)
- **Mother this week** — curated **`_motherTopics`** (Hormones · Your bump · First
  movements · Skin & body · Heart & breath · Aches & twinges), each a **clickable**
  `_topicCard` (teaser + "Read about it ›") → centred `_showTopicDialog`. Plus
  tinted **self‑care** + **gentle‑reminder** cards.
- **Health this week** — `kSymptoms` (non‑urgent, trimester 2). Each symptom card
  is **tappable** → `_showSymptomSheet` (DraggableScrollableSheet: How common /
  Why / What helps / When to call your doctor — via `sym*` strings).
- **What to eat** — curated **`_eatFoods`** cards with a per‑food "why" (paneer,
  rajma, spinach, curd, eggs, citrus) + **What to avoid** as `_avoidFoods` cards
  (coral accent, with reasons) — `_foodCard(accent)` shared.
- **What to do** — warm descriptive **`_toDos`** (not blank commands).
- Strings: `wf{MotherThisWeek,HealthThisWeek,EatThisWeek,DoThisWeek,SwipeMore,
  HealthIntro,TapToRead,Avoid}`.

**Section 5 — What's next** (`_WhatsNextScreen`, Stateful + 3‑page `PageView`)
- **Overview read**: `wfNextIntro` + a **journey‑progress card** (Trimester N ·
  weeks‑to‑go · `LinearProgressIndicator` · "% there", all from `selectedWeek`) +
  "On your radar" **icon cards** (`_nextRadar`).
- **Upcoming milestones**: a **per‑week dataset** `_WeekMs`/`_weekMilestones`
  (weeks 20–40, ≥1 happy milestone each) replacing the old sparse `_upcoming`.
  Filtered to `week >= selectedWeek` and **windowed to `cw..cw+6` `.take(8)`**;
  the current week gets a **cluster of 3** (halfway+kicks · banana size · can hear
  you) tagged "This week". Cards are **tappable → `_showMilestoneDialog`** (emoji
  + title + detail + "Got it"), with a trailing chevron.
- **Scans & appointments** (order: milestones BEFORE scans, per request) —
  `kJourneyMilestones` medical, `anchorWeek` in `[cw‑6, cw+10]`, tappable →
  `_showScanDialog` (scrollable, all `CardSection`s).
- Strings: `wf{MilestonesTitle,ScansTitle,NextIntro,NextRadar,GotIt,
  TrimesterLabel,WeeksToGo,PercentThere}`.

**Section 6 — This week's videos** (`_VideoFeed`)
- Redone as a **reels/shorts feed**: dropped the flat‑purple block; a dark heading
  over the page bg + a horizontal `ListView` of **uniform 9:16 tiles** (`_reel`,
  width 141): gradient thumbnail (`_Vid.c1/c2` + `tag` duration), title on a
  bottom black scrim, centred play button, **NEW** badge, duration badge.
  (Placeholders; real thumbnails later.)

**Section 7 — Share with partner** (`_PartnerSection`)
- Rich, **father‑personalised** WhatsApp message: Baby this week · How she's
  feeling · **actual upcoming scans** (pulled from `kJourneyMilestones`) ·
  father‑focused `_partnerHelp` bullets · "you're in this together" sign‑off.
- A **WhatsApp‑style preview bubble** (#E7FBD6) shows the message before sharing.
- Strings: `wfPartner{Section,Blurb,Cta,Header,Help,ScansHeader,Signoff}`.

### 1.4 The week bar — made scrollable
`_WeekBar` → Stateful `_WeekBarState` (shared header, affects Classic + V2):
horizontal `SingleChildScrollView` of **all** weeks (40px cells + 16px gap dots),
a `ScrollController` that **auto‑centres the selected week** (jump on init,
animate on controller change). Replaced the fixed ±2 window.

### 1.5 Cross‑cutting fix — the "Week 4" leak
`_WhatsNextScreen` had used `controller.currentWeek` (the real current week) while
the user views Week 20 → it showed early scans / "Week 4" titles. **All V2
sections now key off `selectedWeek` (the viewed week), never `currentWeek`.**

---

## 2. Daily / Home screen overhaul (`home_screen_b.dart`)

The daily screen was reordered into the user's target shape and several sections
were rebuilt.

### 2.1 App pinned to Week 20 (testing)
`lib/services/pregnancy_controller.dart` `load()` — the prefs **due‑date restore is
commented out** (the `_placeholderDueDate` already targets `demoCurrentWeek = 20`).
So `currentWeek == 20` everywhere; Home + "View week" land on V2.
**RE‑ENABLE that restore block when V2 testing ends.**

### 2.2 Final daily order
hero → **Mother/Baby row** → Today's Video → **Daily parenting tip** → **Read to
your baby** → **My Journal** → **Daily Garbh** → **Daily medication** → Read Next
(kept, flagged) → **Daily products**.
**Commented out:** the "Today's Moment" rituals row (`_ritualsSection`, which held
Talk + Nurture) and `_affirmationCard` — calls removed from `_build`, methods kept
with `// ignore: unused_element`.

### 2.3 Pieces
- **Mother/Baby shortcut row** (`_motherBabyRow`/`_mbCard`) → `openWeekMotherDetail`
  / `openWeekBabyDetail` (new public fns in `week_flow_screen.dart`) push the V2
  Baby/Mother detail screens.
- **Daily parenting tip** = `GrowModule` inline; the `growEyebrow` string renamed
  **"Grow" → "Daily parenting tip"**.
- **Read to your baby** = `ReadModule` inline.
- **Daily medication** = `_medicationSection`, elevated to a full **`HomeCard`**
  (eyebrow + body + **"Track today →"** button `medTrackCta`) → `MedicineTrackerScreen`.
- **Garbh full 5‑pillar screen → Tools** (`tools_hub_screen.dart`, first tile,
  spa icon, gold #BE9C4E, `garbhToolTitle`).
- **Daily Garbh** (`_garbhDailySection`/`_garbhPillarRow`) — see §2.4 — elevated to
  HomeCard weight (radius 26 + border + deeper shadow).

### 2.4 Daily Garbh — single‑item, day‑rotating (built via fork)
`lib/data/garbh_data.dart` got **day‑rotation pickers**: `shravanForDay`,
`insightForDay`, `vicharaStoryForDay`, `kriyaForDay`, `nutritionForDay`
(`promptForDay` already existed). A `bool daily=false` was added to
`ShravanScreen` / `VicharaScreen` (+ `_SacredTab`/`_UpliftingTab`) / `KriyaScreen`
/ `AharaScreen` in `garbh_screen.dart`. When `daily`:
- item = the **day‑picker** (rotates daily) instead of the trimester picker;
- in‑pillar **recommendation lists hidden** (`if (!daily)`): Shravan "more" list;
  Vichara renders **one** `vicharaStoryForDay` (not the list), keeps the **4 fixed
  Brain‑Fitness games**; Samvad unchanged (already daily, no recs).
- **Tools Garbh is byte‑for‑byte unchanged** (constructs pillars without the flag
  → defaults `false`).
The Home section = a Warm‑Nest card: header + **N/5 progress + 🔥 streak**
(`GarbhStore`), 5 pillar rows (today's rotating item + done‑check), tap → pillar
in `daily: true`.

### 2.5 Daily products
- Resurfaced the **orphaned** `ProductsScreen` as a **horizontal carousel** at the
  bottom of the daily (`_productsCarousel`/`_productCard`/`_badgeMeta`).
- Renamed **"Daily products"** (`prodSectionTitle`).
- **Rotate by day**: `ps[currentDay % len]` per category, so the picks change
  day‑to‑day.
- **Tapping a card opens that product's own page** (`ProductDetailScreen`), not
  the generic recommended list. **"See all →"** opens the full shop.
- Card **image fills the card** (Expanded) so there's no wasted white space.

---

## 3. Daily Journal (built via fork)

User decisions: **real voice recording** (not a stub); **kick sessions removed
from the journal entirely**.

### 3.1 Native foundation
- `record: ^7.1.0` added (voice recording). `audioplayers`/`image_picker`/
  `path_provider`/`speech_to_text` already present.
- Permissions: Android `RECORD_AUDIO` already declared; **iOS Info.plist** gained
  `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`,
  `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`.

### 3.2 Model — `lib/models/journal_entry.dart`
- Added `JournalEntryType.custom`; new `imageUrls`/`audioUrls` **lists** +
  `customTag`; legacy single `imageUrl`/`audioUrl` kept; `images`/`audios`
  getters; `copyWith` (bumps `updatedAt`); back‑compat `toJson`/`fromJson`;
  `kJournalMeta` entry for `custom`.

### 3.3 Store — `lib/services/journal_store.dart`
- `updateEntry`, `saveAudio`; `deleteEntry` removes **all** media files; the
  **kick auto‑entries are commented out** (`_autoHealth`).

### 3.4 Flows — `lib/widgets/journal/journal_create.dart` (NEW, shared)
- `openJournalText` (memory / note for baby / custom), `openJournalAddPhoto`,
  `openJournalRecordVoice` (real `AudioRecorder` start/stop, **multiple clips →
  one entry**, audioplayers playback), `editJournalEntry`.
- **Add photo now offers a chooser**: **Take a photo** (camera,
  `pickImage(source: camera)`) or **Choose from gallery** (`pickMultiImage`).

### 3.5 Home daily section + My Journal screen
- `_journalDailySection` (Home): white card, header + date, 5 round tiles —
  **Write memory · Note for baby · Add photo · Record voice · Custom** + "View My
  Journal Timeline" → `JournalScreen`. Placed between Read‑to‑baby & Garbh.
- `journal_screen.dart`: entries show the **time** (createdAt), photo + voice
  **carousels** (multi‑media → one carousel), manual entries **tap‑to‑edit** +
  **long‑press delete**, custom shows a `#tag`. The FAB is now a **plain "+"**
  (the extended "Create memory" label was overflowing). Each entry also shows a
  **week badge** + groups by **date**.
- Strings: `jc*`, `jrTakePhoto`, `jrChooseGallery`.

---

## 4. Calendar overhaul (`lib/screens/calendar_screen.dart`)

- **Opens on the Calendar tab** now (`_tab = 1`; was 0/Timeline). Timeline &
  Upcoming still switchable.
- **Descriptive grid** (`_dayCell`): labels each **pregnancy week‑start** ("21w",
  orange), marks the **due date** ("Birth" = `calChildbirth`), **highlights the
  current week**, today circled.
- **Smooth current‑week band**: rounded **only at the ends of each calendar‑row
  segment** (not per‑cell rounded squares), and **widened to wrap the day number
  *and* its event dots** so the dots belong to the date. `GridView childAspectRatio
  0.72`.
- **Selected‑day panel** (`_selectedDayPanel`) below the grid: date + "N WEEKS" +
  **the notes you add** (only `CalEventCategory.personal`; milestones/scans/etc.
  intentionally excluded — they live in the dots/Timeline) + **Add Note**
  (`_addPersonal(s, date)` now accepts a date). Event rows are tidy
  `_panelEventRow`s (icon + title + chevron → detail). `_daySheet` kept
  `// ignore: unused_element`.
- Strings: `calChildbirth`, `calAddNote`, `calWeeksUpper`, `calNoNotesDay`.

---

## 5. Other small fixes (chronological highlights)

- **Selected‑week disc shadow** (compact week bar): softened (blur 14→10, offset
  y6→4, alpha .40→.30, disc 40→38) + header strip height bumped so the shadow
  isn't clipped — fixed the "straightened bottom".
- **Weekly Snapshot for Daily**: first built as a separate card, then **folded
  into the hero** per the user — the hero's "your baby is a banana" line became a
  1–2 line "this week" brief + **"View week ›"**, whole hero taps → weekly.
- **Bottom nav pill white sliver**: the page‑dots pill was peeking behind the nav
  pill; lifted the dots above it.
- **Milestone card** (Week 20, classic): a "Baby's journey" **timeline** (reached
  ✓ / this‑week ★ / upcoming) added after "Watch this week".

---

## 6. Files touched

**Created**
- `lib/screens/week_flow_screen.dart` — the entire V2 vertical flow + pop‑ups.
- `lib/widgets/journal/journal_create.dart` — shared journal create/edit flows.
- `SESSION-Weekly-Flow-V2-and-Daily-Overhaul (22-24 June 2026).md` — this file.

**Modified (key)**
- `lib/screens/weekly_card_stack_screen.dart` — V2 toggle, body swap, scrollable
  `_WeekBar`, week‑disc shadow.
- `lib/widgets/week_cards/week_overview_card.dart` — `WeekSizeHero`, `WeekVideoCard`
  (bookmark + "Why this matters" removed), `WeekMilestoneCard`.
- `lib/screens/home_screen_b.dart` — full daily reorder, Mother/Baby row, daily
  Garbh, medication HomeCard, products carousel/rotation/detail, journal section.
- `lib/screens/garbh_screen.dart` — `daily` flag on the 4 pillar screens.
- `lib/data/garbh_data.dart` — day‑rotation pickers.
- `lib/screens/tools_hub_screen.dart` — Garbh tool tile.
- `lib/models/journal_entry.dart`, `lib/services/journal_store.dart`,
  `lib/screens/journal_screen.dart` — Journal model/store/UI.
- `lib/screens/calendar_screen.dart` — calendar rework.
- `lib/services/pregnancy_controller.dart` — week‑20 pin.
- `lib/localization/app_language.dart` — `wf*`, `jc*`, `gs*`, `med*`, `prod*`,
  `cal*`, `jr*` strings.
- `pubspec.yaml` (+ `record`), `ios/Runner/Info.plist`,
  `android/.../AndroidManifest.xml` (already had mic).

---

## 7. Open items / TODOs (carry‑forward)

- **Decide V2 vs Classic** for the weekly view, and whether to **roll V2 out to
  all weeks** (content is currently Week‑20‑curated; other weeks fall back to
  `w.*` data).
- **Re‑enable the due‑date restore** in `pregnancy_controller.load()` when Week‑20
  testing ends (un‑pin the app).
- **Real assets**: video thumbnails (V2 §6 + daily), product photos.
- **Smooth/modern animation polish pass** (page transitions, dialog scale‑ins,
  card taps) — requested, pending.
- **Read Next** on the daily screen is kept but isn't in the user's target list —
  remove on request.
- Journal: cross‑session same‑day photo/voice **merge** not done (per‑entry
  carousels cover the "5 of each = 2 items" case); speech‑to‑text not wired
  (package present).
- Parked: white‑bar‑behind‑nav fine‑tuning; optional concise weekly header.

---

## 8. Key rules to remember next time

1. **V2 weekly sections key off `selectedWeek`, not `currentWeek`.**
2. **Comment‑out / gate, never delete** (the Tools Garbh, the `_ritualsSection`,
   the "Why this matters" card, etc. are all preserved this way).
3. **The full Tools Garbh must stay byte‑for‑byte unchanged** — the daily variant
   is driven entirely by the `daily` flag defaulting to `false`.
4. **Calendar notes are calendar‑only** (not journal‑integrated) for now.
5. Keep **`flutter analyze` clean** and copy **bilingual (Roman Hinglish)**.

---

## 9. Continuation (24–25 June 2026) — Community, Checklist, Saved, Journal, Journey, Products & the AskVeda build

> The session continued well past the Weekly‑V2 / Daily / Calendar work above.
> Everything below kept `flutter analyze` clean, stayed **bilingual (Roman
> Hinglish, no Devanagari)**, used `AppTheme`, and followed **comment‑out, never
> delete**. Large cohesive builds were done with background **fork agents
> partitioned by file** (to avoid `app_language.dart` collisions), each verified
> with a fresh full‑project analyze. The app is **still pinned to Week 20** —
> re‑enable the due‑date restore in `pregnancy_controller.load()` before release.

### 9.1 Home hero, nav pill, AskVeda input polish
- **Weekly‑snapshot hero** (`home_screen_b.dart`): the Baby / Mother / What's‑next shortcuts were merged **into** the gradient hero card as glassy translucent‑white circles (`_heroShortcut`) below a divider. `_heroCard` now takes `context`; the old standalone `_snapshotShortcuts` is commented (`// ignore: unused_element`).
- **Nav pill** (`widgets/pv_tab_bar.dart`): inactive tabs now show a **small label under the icon** (active stays the horizontal purple pill) so Journey / Tools / Calendar / Community are named.
- **AskVeda input bar**: rebuilt to an **all‑white** full‑width bar; TextField flush (`filled:false`, all borders none) — text types on plain white with no box/border; autofocus + purple cursor + mic + send + "Ask AskVeda" hint.
- **Home header**: a **bookmark icon beside search** (`_brandHeader`) → `SavedHubScreen`.

### 9.2 Community — Pro design + test Doctor mode
- **Community Pro** (earlier): expert endorsements shown to build trust; rebuilt Community Pulse; expert posts (no thumbs‑up); joined communities are post‑able with photos; bigger "Walking together".
- **Expert‑count credibility** (`community_models.dart`, `community_data.dart`, `community_screen.dart`): `CommunityPost.expertEndorseCount` (seeded p2=240, p15=320, p5=180); new `kCommunityExperts` (24 **original fictional** doctors {name, cred, specialty}). The endorsement banner shows a Facebook‑style tappable **"+N other experts"** → `_showExpertsSheet` (seal‑avatar rows + "…and N more").
- **Test Doctor mode** (`community_store.dart`): persisted `doctorMode`/`setDoctorMode`, a `_doctorEndorsed` set + `toggle/isDoctorEndorse`, `kTestDoctorName`/`kTestDoctorCred`, helpers `isEndorsed(post)`/`endorseCount(post)`. A **stethoscope toggle** in the top‑icons row + a slim "viewing as a verified doctor · test mode" banner (`_doctorModeBanner`, Exit). `_PostCard` reads `store.isEndorsed`.
- **Doctor endorse animation** (`_DoctorEndorseButton`): tap an unverified post → `HapticFeedback.mediumImpact` + a ~760ms flourish (gold seal elastic pop+rotate, expanding purple ring + 8 gold/purple sparkles via `_EndorseBurstPainter`, count +1, pill → "You verified this ✓"); tap again un‑verifies. Hidden out of doctor mode.
- **Doctor posting + overflow fix**: fixed an 18px RenderFlex overflow on the Sneha card in doctor mode (the DoctorEndorse button moved to its own line below the action row). The bottom‑right FAB becomes **"Post as doctor"** (purple) in doctor mode; `CreatePostScreen._share` branches on `doctorMode` → author=`kTestDoctorName`, cred=`kTestDoctorCred`, 🩺 → renders as a **verified‑expert** post; composer banner + snackbar. Strings `cm{PlusExperts, ExpertsWhoVerified, AndMoreExperts, DoctorMode, DoctorBanner, EndorseThis, YouVerified, PostAsDoctor, PostedAsDoctor, PostingAsDoctor, …}`.

### 9.3 Product Checklist — tool + flow rework
- **The tool** (`services/product_checklist_store.dart`, `screens/tools/product_checklist_screen.dart`): user‑built named lists over the product catalogue; each item carries a custom "when/for" note + a "got it" tick; curated starters (`kCuratedChecklists`); `showAddToChecklistSheet` opens from the product page.
- **Flow rework** (confirmed UX): creating a checklist now pushes the **Add‑products screen directly** (no empty middle screen); that screen has a **Save list + Add to cart** bottom bar. **Add your own (custom) product** — `ChecklistItem` gained `id`/`name`/`link`/`price`/`isCustom` (productId '' = custom); `addCustomItem`; json back‑compat. **"Already got this?" prompt** on ticking an un‑got item → checked = struck/dimmed.
- **Cart only for un‑got items**: detail button "Add remaining to cart" = un‑ticked + catalogue + non‑affiliate; per‑item actions in a ⋮ menu only on un‑got items.
- **Overview polish**: progress chip now "2/3" (tick glyph removed, `pclGotChip`); each list card redesigned (single `fact_check` icon · name · "5 items · 2/5 got" `pclListSummary` · progress bar · ⋮); **delete** via Dismissible swipe + ⋮ menu (`_confirmDeleteList`); lists newest‑first.
- **Bought → checklist** (`services/bought_store.dart` NEW, prefs `bought_products`): placing an order in the preview checkout marks the product ids bought; checklist items then show a locked green **"Bought ✓"** tag, struck, no buy actions, skipped by Add‑remaining.

### 9.4 Cart + Products (affiliate vs ParentVeda)
- **Cart** (`services/cart_store.dart`, `screens/cart_screen.dart`): separate Products vs Hospital‑bag carts; preview checkout `_CheckoutScreen` (deliver‑to → order summary → "payment coming soon" → "Order placed 🎉, no payment taken"). Single‑item buy = `showSingleItemBuyNow` (throwaway `kBuyNowCartId`).
- **Affiliate split** (`models/product_models.dart`, `data/product_data.dart`): `Product.isAffiliate` + `productIsAffiliate(p)` (`_kAffiliateProductIds`, **12 of 24**; the `_overall` hero pick of each category stays ParentVeda). Affiliate → amber "Affiliate" badge + **"Buy on Amazon"** only (`amazonSearchUrl(p)` via url_launcher); ParentVeda → **Add to cart + Buy now → mock checkout**. Applied on `ProductDetailScreen` + related‑products rows (removed the old "buying coming soon").
- **Home products** = a horizontal **carousel** (`_productsCarousel`, `Image.network` + emoji fallback + affiliate badge) under "Today's product recommendation".

### 9.5 Read Next / Daily Reads + the Saved hub
- **Daily Reads home** (`read_next_screen.dart` `DailyReadsHomeCard`): 3 day‑rotating articles + books, check‑off via `ReadDoneStore`; Read Next full screen lives in Tools.
- **Mark‑complete sync**: the reader's "Mark completed" routes through `ReadDoneStore.toggle` (same store as the Home checkbox) → completing in the article auto‑ticks Home. **Completed vs reading**: once Completed, "Mark reading" is hidden + the reading status cleared (mutually exclusive — fixed the confusion).
- **Bookmarks**: `_SaveHeart` on the reader + DailyReads rows (→ `ReadNextStore`); a bookmark on the read‑to‑baby piece (→ new `ReadToBabySavedStore`).
- **Saved hub** (`screens/saved_hub_screen.dart` NEW): the Profile "Saved" card opens it — 3 groups (Saved read‑to‑baby / Saved reads / Saved videos), **newest‑first with save dates**, empty groups hidden, a discover‑more row. `ReadNextStore` refactored (bookmark map vs status map + `savedIdsRecent`/`savedAt`); `VideoStore` gained `_savedAt`.

### 9.6 Read to your baby + Spiritual reading
- **Read‑to‑baby** (`data/read_to_baby_data.dart`, `services/read_to_baby_store.dart`, `widgets/home/home_modules.dart`): 4 categories (stories / rhymes / affirmations / spiritual; spiritual OFF by default), day‑seeded pick, Customize sheet. **Per‑religion sub‑section picker** (`enabledSections` keyed `tradId|idx`, default all‑on when a religion is enabled; FilterChips; `_todaysPiece` filters the spiritual pool by enabled sections). **Baby‑directed tone** — 16 stories + 16 rhymes rewritten to speak **to the baby** ("Little one…", all original); affirmations already baby‑toned. The listen button stays commented.
- **Spiritual reading tool** (`data/spiritual_reading_data.dart`): `SpiritualTradition{id,name,sections:[SpiritualSection{title,reads:[SpiritualRead{title,body}]}]}`; 5 traditions (Hinduism, Islam, Sikhism, Christianity, **Others** = Jainism + Buddhism); sub‑headings; View‑all. **Content expanded to ~20 ORIGINAL reflections PER SUBCATEGORY for every tradition** (Hinduism 100, Islam/Sikh/Christian 80 each, Others 100 — ~440 total). All IP‑safe (no scripture/verse/translation reproduced). *(Read‑to‑baby's spiritual feed draws from this same data.)*

### 9.7 Journal — grouped + booklet views
(`screens/journal_screen.dart`) A `_JournalView{list,booklet}` toggle in the AppBar.
- **List view**: kept type filters + search; added **Group by Month / Week**; collapsible period groups (`_expanded`, only the most‑recent open by default). **Month view sub‑groups by week** (`_monthWeekSections`/`_weekSubHeader`); "Week N" bold/prominent, **date range small + muted**.
- **Booklet view**: a horizontal `PageView` — a cover page ("{name}'s Pregnancy Journal" + week span), then one cream paper page per date (chronological) with date header + the photo/voice carousels; **page‑turn animation** (perspective rotateY + scale + fade via AnimatedBuilder on the PageController) + ‹›arrows + "x/n".
- Earlier: **"entry saved" popup** on save; **custom tag removed** (create option gone; existing custom entries kept); speech‑to‑text where the user writes.

### 9.8 Journey map — direction, milestones, animations
(`screens/journey_map_screen.dart`, `widgets/journey/*`)
- Earlier: MapB replica → refinements → reverted to the clean reference look (no depth/emojis, subtle colour milestone dots, white "Birth" disc).
- **Direction un‑flipped**: was Birth‑top / Start‑bottom (`_nodes.reversed`); now **Start / Week 4 at TOP, Birth at BOTTOM** (`display=_nodes`; `_currentDisplayIndex`=asc; `_node`/`_pill` isDestination=`di==count-1`). *(User may still want it flipped back — confirm on device.)*
- **Richer milestones** (`JourneyColors.iconForType`): a Material type‑icon inside each marker (30→36px; reached = fill+white‑ring+white‑icon, upcoming = white+colour‑ring) — no emoji swarm.
- **"You are here"** (`journey_node.dart` `JourneyNodeMarker` current): two staggered ping rings (coral halo + expanding ring via `OverflowBox`) + a breathing core — clearly distinct from completed/future.
- **Birth radiates by lock state** (`_markerFor` dest): `unlocked = posDay <= currentDay` → LOCKED faint `secondary300` (small), UNLOCKED bright `arrivalGold` (wide).
- **Opens on the current week** (auto‑scroll align ~0.45).

### 9.9 Week‑20 flow pop‑ups + content
(`week_flow_screen.dart`) Earlier batch: baby section first‑person; clickable swipe arrows; "1/6" page numbers; mother popup read‑page‑first; "Daily medication and supplements"; a **Trimester Tips** section (between videos and partner; 3 tips → small popup; bulb icon, no tinted bg).
- **Baby Science loops science‑only**: page 0 = the article (NOT looped); i≥1 = `science[(i-1)%6]` so slide 6 → science slide 1 (never the article); counter `((i-1)%6)+1/6`.
- **"About your baby" page**: a fork redesigned it (gradient hero + numbered cards) but the user **REVERTED it** to the plain content‑dense Mother‑style layout (`_popupTitle` + heading/body per `_babyArticle` section) for more content space; `_articleCard` kept `// ignore: unused_element`. Mother NOT mirrored.
- **Swipe hint fades** (~3.5s, then a 0.7s fade in the shared `_swipeOverlay`; applies to Mother / What's‑next too).
- **What's‑next deep link**: added public `openWeekWhatsNext(ctx,ctrl,lang)`; the Home hero shortcut now calls it (was `goWeekly()`).

### 9.10 Calendar — trimester markers, dot meanings, legend
(`calendar_screen.dart`) Trimester‑start pills in `_dayCell` (wk 4/14/28 → 1st/2nd/3rd tri, `_triColor`); `_selectedDayPanel` now lists EVERY event on the tapped day with a colour‑chip + title + "Category · meaning"; a collapsible **"What the dots mean"** legend (`_legend`) — swatch+name+meaning for all categories + the week/trimester/birth markers. Strings `cal{TrimesterTag, OnThisDay, LegendTitle, Mean*}`.

### 9.11 Smaller fixes
- **Profile black screen FIXED**: `ProfileScreen` had no `Scaffold` → black when pushed from the home avatar; now wrapped in `Scaffold(bg surfaceContainer, AppBar title)`. A "Saved" card routes to `SavedHubScreen`.
- **Splash**: transparent background‑removed logo; Weekly→Daily back nav.
- **Bump journey FAB**: clipped extended FAB → plain circular FAB + tooltip.
- **Home bell → working app‑wide search** (`screens/global_search.dart`).

### 9.12 AskVeda — the big build (offline, no backend)
- **The PDF** (`C:\Users\sarth\Downloads\Ask veda (1).pdf`, extracted to `…/scratchpad/askveda.txt`, 397 lines): AskVeda as the "Universal Parent Companion AI / front door / OS of ParentVeda" — 8 pillars (context‑awareness, a home screen with quick‑question cards + voice + image, a **FIXED 7‑section result page**, labour/postpartum/child‑dev domain logic, memory, proactive suggestions, 17 retrieval sources, primary navigation).
- **Whole‑app retrieval (Phase A)** — NEW `services/veda_index.dart`: `VedaKind` (13 kinds), `VedaDoc`, `VedaIndex` lazily‑built cached corpus (**~700+ docs**) over Can‑I, Symptoms, weekly baby+mother (74, from the controller), Products (24), Reads, Trimester tips, **Spiritual (~440)**, Read‑to‑baby (48), Garbh, Body changes, Tools (11 hand‑written), Community insights. `vedaSearch(query,p,{limit})` tokenizes (drops stopwords + <3‑char, **keeps numbers** so "week 20" pins), scores by weighted overlap (title 6 ≫ keyword 4 ≫ body 1.5, +8 full‑query‑in‑title), **threshold 4.0** else nothing. `vedaAnswer` now returns `VedaResult{answer, sources, showcase}` (Can‑I/Symptom keep their rich verdict/why/tips formatting when top hit; else title+body; +disclaimer); `vedaAnswerText()` back‑compat shim. `ask_veda_screen.dart` renders the answer + **"From your ParentVeda"** tappable source cards → a `DraggableScrollableSheet` content view.
- **5 structured showcase answers** — NEW `data/veda_showcase.dart` (`VedaShowcase` model + `kVedaShowcase`): hand‑authored, **web‑researched** (NHS / Tommy's / Mayo / APA) answers in the doc's **fixed 7‑section format** (Veda Answer → What this means → Recommended actions → ParentVeda content → Community insights → Products → Services): (1) anomaly scan timing, (2) labour signs, (3) iron foods, (4) sleep on back, (5) reduced movements **[URGENT red banner]**. `matchShowcase(query)` runs BEFORE retrieval; keywords are **English + Roman‑Hinglish** (so taps hit in both languages). The UI renders the full 7‑section card + urgent banner (`vedaUrgentBanner`).
- **Stage‑wise suggested questions** — NEW `data/veda_suggestions.dart` (`kVedaSuggestions`): Pregnancy 🤰 (active, 8 Qs worded to hit showcase/retrieval), Newborn 👶 / Toddler 🧒 / Parenting 👪 (inactive, "as your journey grows"). Shown on the AskVeda empty state; tap → `_send`. **Rotating** — a shuffled subset per section per visit (Pregnancy 4 of 8, others 3) via `_rollSuggestions` in `initState` + a **shuffle button** (`vedaShuffle`).
- **Phase A is substantially built**; **Phase B (LLM/RAG)** plugs into the same `VedaIndex` docs later.
- **Personalization flow (DISCUSSED, not built):** recommended a **`VedaContext`** seam — gather user‑type / week / trimester / due date / logged symptoms / meds / journal / memory from the existing local stores now; when real login + profiles land, only the data source changes (one‑file rewire), not the AskVeda logic. Enables context‑aware answers + AskVeda memory (recent Qs) + proactive stage cards — all buildable offline now; only auth / cloud‑sync / LLM need a backend. **Awaiting user go.**

### 9.13 New files created this continuation (key)
- AskVeda: `lib/services/veda_index.dart`, `lib/data/veda_showcase.dart`, `lib/data/veda_suggestions.dart`, `lib/services/veda_answer.dart` (rewritten), `lib/screens/tools/ask_veda_screen.dart`.
- Saved / reads: `lib/screens/saved_hub_screen.dart`, `lib/services/read_to_baby_saved_store.dart`, `lib/data/read_next_data.dart`, `lib/screens/read_next_screen.dart`.
- Checklist / cart / products: `lib/services/product_checklist_store.dart`, `lib/screens/tools/product_checklist_screen.dart`, `lib/services/cart_store.dart`, `lib/screens/cart_screen.dart`, `lib/services/bought_store.dart`.
- Spiritual / read‑to‑baby: `lib/data/spiritual_reading_data.dart`, `lib/data/read_to_baby_data.dart`, `lib/services/read_to_baby_store.dart`.
- (Plus models from the broader UI revamp: `bump_photo`, `calendar_event`, `journal_entry`, `medication`, `pv_video`, `scan_appointment`, `symptom` — see `git status`. `main.dart` registers the new stores' `init()`.)

### 9.14 Updated open items / carry‑forward
- **AskVeda personalization scaffold** (`VedaContext` + memory + proactive cards) — offered, **awaiting user go**.
- **AskVeda Phase B** (LLM/RAG) — future; plugs into `VedaIndex`.
- **More showcase questions** (labour / newborn / feeding / sleep) + a **wider rotation pool** — optional.
- **Custom‑item link unfurl** (OG fetch → auto‑fill name/image/price; needs the `html` pkg; best‑effort + graceful fallback) — explained, **awaiting user go**.
- **Read‑to‑baby stories/rhymes/affirmations** still 16 each — offered to take to 20. **Read‑to‑baby categories doc** — user will send (it's more than lullaby/story).
- **Journey direction** — un‑flipped per my read; user may want it flipped back. **Checklist detail** still reads "X of Y ticked" (no glyph) — reword offered.
- Re‑enable the **due‑date restore** before release (Week‑20 pin). **Real assets** (video thumbnails, product photos) still pending.

### 9.15 Rules reinforced
1. Large builds via **fork agents partitioned by file** (avoid `app_language.dart` collisions); always verify with a fresh full‑project `flutter analyze`.
2. **IP guardrail:** all spiritual / story / rhyme / showcase content is **ORIGINAL** — no scripture, copyrighted translation, nursery rhyme, or verbatim source reproduced.
3. **AskVeda is grounded:** retrieval surfaces only vetted app content; showcase answers cite web research + always carry the doctor disclaimer; the reduced‑movements answer is **emergency‑aware** (urgent banner).
4. **Showcase keyword matching needs both English + Hinglish** terms (taps send the active‑language text).
5. `Math.random()`/`DateTime.now()` are fine in the **app** (used for suggestion rotation) — that restriction is only for workflow scripts.

---

## 10. Continuation (25–26 June 2026) — Journey/Journal refinements, the Twitter‑style Community, and the Ask Veda Results redesign

> Everything below kept `flutter analyze` clean, stayed bilingual (Roman Hinglish, no Devanagari), used `AppTheme`, and followed comment‑out‑never‑delete. Large cohesive builds used background **fork agents partitioned by file**, each verified with a fresh full‑project analyze. The app is **still pinned to Week 20** — re‑enable the due‑date restore in `pregnancy_controller.load()` before a real release (flagged again at the APK build, §10.10).

### 10.1 Journey map — weekly landing + milestone dates + "when did this happen?"
(`journey_map_screen.dart`, `widgets/journey/node_cards.dart`, NEW `services/journey_dates_store.dart`, `pregnancy_controller.dart`)
- **Weekly landing (bug fix):** `_maybeLandOnCurrent` scrolled to `_hereKey` placed at the *fractional* current‑day point → mid‑week it settled between two week nodes (e.g. day 7 of week 20 landed nearer week 21, hiding week 20). Added `_currentWeekNodeIndex(display)` and anchored `_hereKey` on the **current‑week checkpoint node**, so opening always lands squarely on the current week regardless of day‑within‑week.
- **Milestone dates on the trail:** each milestone caption pill now reads "&lt;title&gt; · &lt;date&gt;" (e.g. "Anomaly scan · 25 Jun"), via new `PregnancyController.dateForDay(day)` (= `dueDate − (280 − day)`) + `S.jmShortDate`.
- **Edit "when did this happen":** NEW `journey_dates_store.dart` (ChangeNotifier, prefs `journey_dates`, `Map<String,DateTime>` milestoneId→date; `setDate`/`dateFor`/`isEdited`/`clear`; `init()` in `main.dart`). The milestone card (`showJourneyNodeCard` → `_timingAndEdit`, in an `AnimatedBuilder` on the store) shows the override if set ("Happened on …" + "edited by you" hint) else the computed date, with a **"When did this happen? / Edit date"** button → `showDatePicker` → save; the map listens, so the pill updates live. **Trail position stays at the default week** (only the shown date changes). Strings `jm{ShortDate,EditDate,WhenHappened,HappenedOn,EditedHint}`.

### 10.2 Journal — per‑entry date+time + booklet backdrop
(`journal_screen.dart`)
- **Per‑entry date + time:** `_card` now shows the **date** (`s.formatShortDate(e.date)`) above the time, under the week badge (she could see week/time/group‑range but not the per‑entry date). Booklet pages keep just the time (they already carry a date header).
- **Booklet backdrop / textures** (so a sparse one‑entry page doesn't feel empty): `_BookletBackdrop` (warm linen gradient `#EFE7D8→#E2D4BD` + faint top glow behind the pages), `_paperShadow` (real‑paper drop shadow on page + cover), and ON the page — `_PaperLinesPainter` (faint ruled lines), a low‑opacity `spa_rounded` botanical watermark (coral 5%), a coral **ribbon bookmark** (`_BookmarkRibbon`/`_RibbonPainter`), and a richer cover frame. Low‑opacity + on‑brand; page‑turn animation + carousels untouched.

### 10.3 Read‑to‑baby customize — selected state made obvious
(`widgets/home/home_modules.dart`) In the ReadModule Customize sheet, the selected **category tiles** + **religion chips** + **sub‑section chips** now show a clear **2px primary border + checkmark + stronger fill** (was only a faint colour change).

### 10.4 Community — composer button, then the full Twitter/X revamp
- **Composer button moved into the text box** (first): the Share/Post action left the extreme top‑right for a **circular send button inside the TextField** (greys out when empty); doctor‑mode authoring intact.
- **Structural cleanup:** **Community Pulse removed** (commented out); **Recommended communities** now sits directly below "Your communities" and above the For You/Following toggle (it was already in code — Pulse was hiding it).
- **The Twitter/X revamp** (`community_screen.dart`, `community_store.dart`, `community_data.dart`, NEW `services/expert_follow_store.dart`, NEW `screens/community_profile_screen.dart`) — Twitter's LAYOUT/elements, our LIGHT purple palette, from the user's X screenshot:
  - **`CommunityPostCard`** (was `_PostCard`, now public): avatar + Name + verified seal (experts) + @handle + ·time + ⋯; body; engagement row **reply · repost · like · views · bookmark · share** (counts; like/repost/bookmark stateful, views cosmetic ≈likes×250); hairline divider between posts. KEEPS the endorsement banner + `_DoctorEndorseButton`.
  - **⋯ menu** (`_showPostMenu`): **Follow/Unfollow** (experts only, real) + **Not interested** (session‑hides the post) + **Mute / Block / Report** (snackbar stubs).
  - **Feeds:** **For You** = `store.feed()` blend (your posts + joined communities + general feed + engagement); **Following** = STRICT — only joined communities + followed experts (`isJoined || ef.isFollowing(author)`), friendly empty state.
  - **Follow‑experts store** (NEW): prefs `followed_experts`, `toggleFollow`/`isFollowing`/`count`, **experts‑only** (members can't be followed); `init()` in `main.dart`.
  - **Profiles** (NEW `community_profile_screen.dart`): tap an avatar/name → an X‑style profile (avatar + seal + @handle + cred + bio `cmExpertBio` + Posts/Followers/Following stats); **Follow button for experts**, a **"Member" chip** for users; then that author's posts via `CommunityPostCard`.
  - **Compose FAB:** a round **+ FAB** (purple; medical icon in doctor mode) → `CreatePostScreen` with a **destination selector — "🏠 Your feed" vs a joined community** (default feed). **Both users and experts post**; doctor‑mode still authors as the verified expert. Store gained persisted **reposts** + a session **hidden** set + general‑feed seeds `g1`–`g3`.
  - **User‑confirmed model:** both users + experts post (to feed or community), both have profiles, **follow = experts‑only**.
  - **Stubs to deepen:** Mute/Block/Report not persisted; reply uses a simple `PostDetailScreen` (not full threads); per‑expert bios are one generic line; card spacing wants on‑device tuning vs the screenshot.

### 10.5 Ask Veda — welcome removed + the "Ask Veda Results" design
- **Initial welcome message removed:** the `s.vedaWelcome` seed in `build()` is commented (the `_seeded` field too); Ask Veda opens straight to the suggestion cards (`_msgs.isEmpty` / `_query==null` gates them).
- **Stage‑wise suggestions** (built just before): `data/veda_suggestions.dart` (`kVedaSuggestions` — Pregnancy active, Newborn/Toddler/Parenting "as your journey grows"), **rotating** (shuffled subset per visit + a shuffle button). Showcase keywords gained **Hinglish** terms so taps hit in both languages.
- **"Ask Veda Results" design implemented** (`ask_veda_screen.dart` REWRITTEN) — pulled from **Claude Design** via the **DesignSync MCP** (`get_file`, projectId `531911be-a36a-415a-8e9d-1eefc52926bd`, file `Ask Veda Results.dc.html`; the MCP works — the claude.ai login was upgraded with design scopes). Ask Veda is now a **search → structured‑result page, NOT a chat**:
  - **Chrome:** lavender vertical gradient (`#F8F4FD→#F2EBF9→#EFE7F6`); top bar = logo · centered **"Ask Veda"** Fraunces wordmark ("Ask" purple `#6D28D9` + "Veda" coral `#F0476A` + `auto_awesome`) · gradient profile avatar → ProfileScreen.
  - **Bottom→top input:** one white search pill via **`AnimatedAlign`** (bottomCenter↔topCenter, 380ms) — *initial* = suggestion cards with the pill editable at the **bottom**; *after a question* the pill **glides to the top** showing the query (search · query · **×** clear · mic), the structured result fades in below; **×** resets.
  - **The 7 sections** (showcase, mapping `VedaShowcase`): **Veda Answer** (`_vedaAnswerCard` + a "Week N · {trimester}" `_contextChip` + `volume_up` speaker stub; `urgent` → red banner) → **What this means** (+ coral "When to get checked" when urgent) → **Recommended next actions** (icon rows) → **More information** (pvContent cards by type) → **Community insights** (avatar stack) → **Products** (carousel, matched to real `kProducts` by name) → **Services** (Book/Call rows) → shield **disclaimer**.
  - **Retrieval fallback** (`showcase == null`): Veda Answer card + a **"More information"** list from `result.sources` (tap → content sheet) + disclaimer.
  - Design palette consts `_v*` (design hexes ≈ our brand). **Stubs:** speaker/TTS, Book/Call, mic = snackbars; product star‑ratings omitted (only real catalog price shown).

### 10.6 Amazon product embed — feasibility (answered, NOT built)
No YouTube‑style free embed exists for Amazon. Options: **PA‑API 5.0** (proper real product card; needs an approved Associates account + API keys + a small backend) · **in‑app WebView** of the affiliate URL (embeds the page now; heavier) · **OG/scrape unfurl** (best‑effort; Amazon often bot‑blocks). Reco: affiliate **"Buy on Amazon"** deep link for launch → PA‑API when the Associates account exists.

### 10.7 Ask Veda personalization — feasibility (discussed, NOT built)
Recommended a **`VedaContext`** seam: gather user‑type / week / trimester / due date / logged symptoms / meds / journal / memory from the existing local stores now; AskVeda reads only `VedaContext`. When real **login + profiles** land, only the data source changes (a one‑file rewire), not the AskVeda logic. Enables context‑aware answers + AskVeda memory (recent Qs) + proactive stage cards — all buildable offline now; only auth / cloud‑sync / LLM need a backend. **Awaiting user go.**

### 10.8 New files (this stretch)
`lib/services/journey_dates_store.dart`, `lib/services/expert_follow_store.dart`, `lib/screens/community_profile_screen.dart`, `lib/data/veda_suggestions.dart` (plus `lib/services/bought_store.dart` from the bought→checklist work in §9.3). `ask_veda_screen.dart` was rewritten; `main.dart` registers the new stores' `init()`.

### 10.9 Open items / carry‑forward (current)
- **Re‑enable the due‑date restore** in `pregnancy_controller.load()` before any real release (Week‑20 pin; flagged at the APK build).
- **Ask Veda personalization scaffold** (`VedaContext` + memory + proactive cards) — awaiting go. **Phase B** (LLM/RAG) plugs into `VedaIndex`. More showcase questions / wider rotation pool — optional. Speaker/TTS, Book/Call, mic — stubs to wire.
- **Community deepen:** persist Mute/Block/Report; real reply **threads** (not the simple `PostDetailScreen`); per‑expert bios; on‑device card‑spacing tune vs the X screenshot.
- **Amazon:** affiliate deep‑link now → **PA‑API** (Associates account + backend) for real product cards; **custom‑item link unfurl** (OG fetch, needs `html` pkg) still optional/awaiting go.
- **Read‑to‑baby** stories/rhymes/affirmations still 16 each (offer → 20); the **read‑to‑baby categories doc** is still awaited from the user.
- **Journey direction** un‑flipped per my read — confirm on device. **Real assets** (video thumbnails, product photos) pending.

### 10.10 Build / release note
- A **release APK** was built clean: `build/app/outputs/flutter-apk/app-release.apk` (~69 MB). Share **that** one (NOT `app-debug.apk`, NOT the `.sha1`). WhatsApp may strip `.apk` — rename to `.apk.txt` (receiver renames back) or share via Drive.
- App is still **Week‑20 pinned** — fine for a demo APK; un‑pin (re‑enable the due‑date restore) for a real release.
- **DesignSync MCP works** — Claude Design `.dc.html` files can be pulled directly with `DesignSync get_file` (login now has design scopes).
