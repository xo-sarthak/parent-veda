# ParentVeda — Session Handoff

_Last updated: 2026-06-19 (session 6 — Father Mode: full Daily Moment built, week-20/day-143 prototype, slate accent)_

A Flutter pregnancy-companion app. The core feature is the **Week-on-Week Card Stack**: a horizontal, swipeable set of cards per week (weeks 4–40), bilingual (English / Hinglish), with a calm "premium baby" aesthetic.

---

## 0. Session 6 — what changed (read this first)

Built the **Father Mode "Daily Moment"** end to end (replacing the session-5 "coming soon" placeholder). `flutter analyze` clean throughout. Git rule unchanged: **user runs git themselves; no `Co-Authored-By` trailer** (I slipped one into a proposed commit message mid-session — ignore it; keep the no-trailer rule).

### ⭐ Git state & tomorrow's flow (read this — supersedes any "everything uncommitted on ui-redesign" wording below)
- The **UI redesign (session 4) is committed on `ui-redesign` and already MERGED to `main` on GitHub.** So that work is done/shipped.
- **Still uncommitted in the working tree:** ONLY the **Home Screen (session 5) + Father Mode (session 6)** feature — its new files plus shared edits to `main.dart`, `app_theme.dart`, `pregnancy_controller.dart`, `week_cards.dart`, `app_language.dart`, `pubspec.yaml`. (The lone `- assets/baby/` line in `pubspec.yaml` is the "one file" from session 4 that rides along here and reaches `main` via this branch.)
- ⚠️ **Local `main` is stale** (shows the initial commit `16ef80d`) because the merge happened on GitHub and this clone hasn't fetched it. So **don't branch from local `main`.** The current branch **`ui-redesign` = the merged main content** — branch from there.
- **Tomorrow's flow** (you're already on `ui-redesign`; the uncommitted home/father work travels with you):
  ```bash
  git checkout -b feature/home-father   # branch from ui-redesign (NOT local main)
  git add -A
  git commit -m "Home Screen + Father Mode (Daily Moment) feature"
  git push -u origin feature/home-father
  ```
  Then merge to `main` (PR on GitHub, or locally: `git checkout main && git pull && git merge feature/home-father`). Expect one tiny `pubspec.yaml` `assets:`-block conflict → keep all the asset lines.

**Source of truth:** the **Father master content prompt** the user pasted in chat (NOT a file in the repo — capture it if needed) + a reference UI screenshot. Father Mode is a **fatherhood-transformation** app, NOT pregnancy education — no medical/baby-size/fetal-development content (those stay mother-side). **Hard rule:** every Father week/day is authored against the **matching Mother week** so milestones never contradict.

**Palette differentiation (user's explicit call):** same four-colour app palette, but the Father signature accent shifts from purple to the grounded **slate `#2D3436`** (new `AppTheme.fatherSlate*` ramp). **Coral** (`secondary500`) stays for warmth (Talk card + the ❤️ in the greeting); **amber** (`AppTheme.fatherAmber` = `#E0921C`) marks the Mission card; purple steps back. (User showed a palette board: Primary `#7029B3`, Secondary `#FF5E78`, Tertiary `#2D3436`, Neutral `#F8F9FA` — "same scheme, slightly different.")

**The screen (`father_home_screen.dart`, reached via the Mother/Father `ModeToggle` on Home):**
- **Header** (`FatherHeader`): "Fatherhood" wordmark + bell + EN/Hi `LangToggle`, then **"Good Morning, Dad ❤️"** + "Week 20 · Day 143". **No baby-size callout** (spec forbids). Father name = `pregnancy.fatherName` (placeholder `'Dad'`).
- **Today's Moment** invite card (`FatherMomentCard`): `~4 min`, intro line, slate **Start Moment** button (currently a no-op stub).
- **3 modules** (vs mother's 6): **Learn** (slate; eyebrow = curriculum `module`, 3 layers card→`FatherLearnReaderScreen` expanded+deepDive→remember) → **Talk To Your Baby** (coral; reuses `TalkComposerScreen` → saves to Dear Baby via `DailyStore`) → **Mission** (amber, left accent bar, **Done** toggle persisted via new `DailyStore.toggleMissionDone`/`isMissionDone`).
- **Completion** banner + **Emotional Check-In** (`FatherEmotionalCheckIn`): "How are you feeling today?" as **wrap chips** (10 father moods; reuses `DailyStore` moods per day). Chip style is the subtle father differentiator vs the mother's grid tiles.
- **`_FatherPreviewBar`** (prototype-only, mirrors the mother's) steps ±day/±week with a "today" reset via `FatherContentController.previewDay`.

**New/changed files:** `models/father_day.dart` (`FatherDay`: `module`/`learn`/`talk`/`mission`), `data/father/fatherDailyContent.json` (day 143 / week 20 prototype, bilingual — Presence Over Provision / Your Biggest Life Lesson / The Quiet Support, from the reference image), `services/father_content_controller.dart` (per-week `week_NN.json` + legacy fallback + `previewDay` + `FatherModule` enum; mirrors `HomeContentController`), `widgets/father/father_modules.dart`, `screens/father_home_screen.dart`, `+FatherLearnReaderScreen` in `home_detail_screens.dart`. Edits: `daily_store.dart` (mission persistence), `app_language.dart` (Father chrome `S` strings + `fatherMoodLabel`), `pregnancy_controller.dart` (`fatherName`), `app_theme.dart` (`fatherSlate*` + `fatherAmber`), `pubspec.yaml` (`- lib/data/father/`), `main.dart`/`main_scaffold.dart`/`home_screen.dart` (construct + thread `FatherContentController`). **`_LangToggle` → `LangToggle`** (made public in `home_modules.dart`) so Father reuses it.

**Bug found on device + fixed:** `FatherMissionModule`'s left accent bar used a `Row(crossAxisAlignment: stretch)` inside the unbounded `ListView` → "BoxConstraints forces an infinite height" render crash. **Fixed by wrapping the Row in `IntrinsicHeight`.** `analyze` clean after.

**⚠️ On-device verification of the fix is PENDING.** Sequence: pre-fix run reproduced the crash; I fixed it; then `flutter clean` + `flutter run` failed because **clean wiped the plugin symlinks and Windows needed Developer Mode** (see §3 correction). User enabled Developer Mode and re-ran `flutter run`, but I didn't get to confirm the rebuilt screen renders clean before the session ended. **Next session: confirm the Father screen (esp. the Mission card) renders with no exceptions.**

**TODO (Father):** only the **week-20 / day-143** prototype day exists. Still to author: weeks 4–40 daily content (Learn/Talk/Mission) **and** the separate **Weekly Journey** (4 sections × 37 weeks: Father Insight / Supporting Your Partner / Connecting With Baby / Mission). Total target ≈ **877 assets**. Apply the same week-20-first, author-against-mother-week, Devanagari-QA approach as the mother content.

---

## 0. Session 5 — what changed (read this first)

Built the **Mother Home Screen / Daily Moment** feature and started rolling its content out across weeks 4–40. Still on the **`ui-redesign`** branch; **everything is uncommitted** in the working tree (continuation of session 4's home work). `flutter analyze` clean throughout; app verified running on the device (SM G990B2). **A `home-screen` branch was discussed but NOT created** — the user chose to hold off; provide `git checkout -b home-screen` when they ask (no push yet). Git rule still applies: **user runs git themselves; no `Co-Authored-By` trailer.**

**Source of truth:** `lib/data/prompts/ParentVeda_Mother_Home_Screen_Spec_v2.md` (the prompt — NOT the attached reference screenshot). **Design language = the existing app** (AppTheme tokens, soft cards, SoftPill, Fraunces/Jakarta/Manrope) — deliberately NOT the reference image's styling.

**The feature (mother side — built this session):**
- **App now boots into `MainScaffold`** (`main.dart`) — a 5-tab bottom nav: **Home** (daily moment), **My Baby**, **Dear Baby**, **Explore**, **Profile**. (Committed `main.dart` on a fresh checkout previously booted `WeeklyCardStackScreen`; this is the uncommitted change.)
- **Home (`home_screen.dart`)** = the daily moment: warm header (greeting + journey line + baby-size callout that **reuses the week's `weekContent.json` snapshot**), then 6 modules in spec order — 🌱 Grow → 📖 Read To Your Baby → 💬 Talk To Your Baby → 🕉️ Garbh Sanskar → 🌸 A Moment For You → 🤍 Baby Movement (week 28+ only) → warm completion banner → ❤️ Emotional Check-In (8 mood tiles). Modules in `widgets/home/home_modules.dart`; detail surfaces (Grow reader, Story reader, Talk composer, Garbh "i" info sheet) in `home_detail_screens.dart`.
- **My Baby tab (`my_baby_screen.dart`)** is the entry into the existing **Week Card Stack** — a tap-card that pushes `WeeklyCardStackScreen`, and **always re-opens at the mother's current week** (`selectWeek(currentWeek)` before push, no matter where she last browsed). Dear Baby / Explore / Profile are gentle "coming soon" stubs.
- **Locked behaviours/decisions:** Talk "Record" reuses `speech_to_text` (speak→transcribed→saved to Dear Baby via new `DailyStore`); audio is placeholder (drone `RagaPlayer` for raga/meditation, TTS for story "Listen"); Garbh card has a small **"i" info button** beside the raga → bottom sheet explaining ragas/affirmations + how to use them; **demo lands on week 20** (`_placeholderDueDate` demoCurrentWeek 24→20; added `currentDay`/`termDays`/`motherName` to `PregnancyController`).

**Content model + rollout (4–40, in progress, batched week-by-week):**
- Content = **one file per week**: `lib/data/home/week_NN.json` (array of 7 day-objects; `day` of pregnancy = `(week-1)*7+1 .. week*7`). `HomeContentController` loads weeks 4–40, **skipping any not yet authored**; Home matches by **exact `currentDay`** (nearest-in-week fallback). Model: `models/home_day.dart`.
- Legacy `lib/data/homeDailyContent.json` (the approved week-20 day) is kept as a **fallback** so the week-20 demo stays alive until `week_20.json` is authored.
- **Spine / arc / no-duplicate ledger:** `lib/data/prompts/home_content_plan.md` (Grow 10 modules×28d; Talk 10-act; story-category rotation; Garbh/Nurture trimester type ratios). Append the ledger each batch.
- **Stories: short (~120–180 words) but complete/meaningful** (user: don't cut them to save tokens). All content bilingual `{en, hi}`, EN pure English / Hi pure Hinglish.
- **DONE:** `week_04.json` (days 22–28, full, trimester-1 reassurance tone). **TODO:** weeks 5–40 (next batch ≈ weeks 5–7, pending user's tone sign-off on week 4).
- **QA after every batch:** grep new files for Devanagari `[ऀ-ॿ]` (hand-authored Hinglish tends to slip stray Devanagari letters, e.g. `narम`→`naram`) and fix; then validate JSON (`ConvertFrom-Json`). week_04 + homeDailyContent already cleaned.

**Review tool — PROTOTYPE-ONLY (remove before launch):** a `_PreviewBar` at the top of the Home feed steps ±1 day / ±1 week with a "today" reset, driven by `HomeContentController.previewDay` (Home shows `previewDay ?? currentDay`). It flags days not yet authored ("showing nearest"). This is how to view any authored day in-app.

**Father Mode (present in tree — added outside the mother-side work this session):** a Mother/Father `ModeToggle` on Home; `screens/father_home_screen.dart`, `services/father_content_controller.dart`, `models/father_day.dart`, `data/father/`, `widgets/father/`, and `AppTheme.fatherSlate*` colors. `main.dart` constructs a `FatherContentController` and passes it through `MainScaffold` → `HomeScreen`. Treat as an in-progress parallel feature; leave intact.

---

## 0. Session 4 — what changed (read this first)

All work this session is on the **`ui-redesign`** branch (pushed to GitHub). `flutter analyze` clean throughout; verified on the physical device over **wireless** ADB (USB kept dropping → wireless via `adb connect <ip:port>`; wireless also drops often, the handoff §3 dance applies).

**Git / repo (NEW this session):**
- Repo initialized and pushed to **https://github.com/xo-sarthak/parent-veda**. Branches: **`main`** (baseline) and **`ui-redesign`** (all session-4 UI work).
- `.gitignore` additions: `.claude/settings.local.json`, `/voice_samples/`, `/lib/data/reference-images/`, `/lib/data/Week on Week Pregnancy Tracker.pdf` (these stay local-only, not pushed).
- **The user runs all git commands themselves** — provide commands + commit messages, don't execute git. **No `Co-Authored-By` trailer** in commit messages (scrubbed from history once already).

**Global UI redesign (rolled out to ALL weeks — the session-3 wk4–5 preview is now approved + global):**
- **Fruit/Baby toggle**: single centered segmented pill below the image on every week (rebuilt as two equal halves, content perfectly centered). `_FruitBabyToggle` in `week_cards.dart`.
- **Size-card header**: purple filled icon chip (white icon), muted "THIS WEEK" eyebrow, purple title, calm neutral speaker — via optional `iconChipColor`/`eyebrowColor`/`titleColor` hooks on `CardShell` (only the Size card opts in; other cards' headers unchanged).
- **Size-card image container**: one calm soft concentric-ring container with a gentle float, all weeks (dropped the pulsing rings + rotating shimmer + bottom "Week X" pill). `LivingHalo` rewritten.
- **Top section** (`weekly_card_stack_screen.dart`): purple logo badge + purple "ParentVeda" wordmark (Flexible → no overflow); "Week X of 40" centered below; **coral** progress bar; week strip selected pill **coral** with a layered round glow (strip height raised to 88 + `clipBehavior: Clip.none` so the glow isn't clipped square); unselected pills neutral grey; "WEEKS" label coral; bigger "Trimester" heading (20px); weight metric uses an hourglass icon.
- **Gradient card background** flipped ON for **all weeks** (`kEnableGradientCards = true` in `app_constants.dart`).

**Baby art (committed; needs real images):**
- Replaced the single scaled-bean `_BabyBumpPainter` with **`_GrowingBabyPainter`** (curled, week-driven proportions). BUT the user found vector art still reads as "same shape" — so the real plan is **drop-in image assets**.
- Added a **per-week image pipeline**: Baby mode loads `assets/baby/week_NN.png` (`_BabyFigure` in `living_halo.dart`), falling back to the vector figure when an image is absent. `assets/baby/` declared in pubspec; **`assets/baby/README.md` documents the spec** (transparent PNG, ~600², `week_04`..`week_40`). **User is sourcing licensed artwork** (NOT the competitor reference images — copyright). Weeks 4–5 also route through this (their embryo art is "factually off" per the user and will be replaced by the assets).
- ⚠️ The `- assets/baby/` line in `pubspec.yaml` is **NOT committed on `ui-redesign`** (Option-B commit skipped it to avoid bundling the in-progress home feature's pubspec lines). It currently rides with the uncommitted home work and will reach `main` via the home branch. So baby **images won't bundle on a fresh `main`** until that pubspec line lands (works locally; vector fallback otherwise).

**Week-40 celebration redesign** (`celebration_card.dart`): removed the three emojis and the on-card memories/photos/journal section; button renamed **"Download your Keepsake Booklet"** (download icon; flow unchanged). Calmer blush→white scheme, elegant Fraunces "Welcome, little one." title, soft baby orb, gentle **bokeh** instead of confetti (still re-fires every visit), subtle wordmark.

**⚠️ Uncommitted in the working tree (NOT session-4 UI work):** a separate in-progress **"Home Screen / Daily Moment" + "Father"** feature (new files: `main_scaffold.dart`, `home_screen.dart`, `home_detail_screens.dart`, `my_baby_screen.dart`, `father_home_screen.dart`, `daily_store.dart`, `home_content_controller.dart`, `father_content_controller.dart`, `home_day.dart`, `father_day.dart`, `widgets/home/`, `widgets/father/`, `data/home/`, `data/father/`, `data/prompts/`, `homeDailyContent.json`; plus uncommitted edits to `main.dart` (boots `MainScaffold`), `app_theme.dart`, `pregnancy_controller.dart`, `week_cards.dart`, `app_language.dart`, `pubspec.yaml`). Plan: move it onto **`feature/home-screen`** (branch from `ui-redesign`, then `git add -A` + commit there). Committed `main.dart` on `ui-redesign` still boots `WeeklyCardStackScreen`.

---

## 0a. Session 3 — what changed

`flutter analyze` clean after every fix; `flutter build apk --debug` succeeds (native `printing` plugin compiles). **NOT yet run on the physical device** — serial `RZCX50ZKLBA` was not connected this session, so on-device visual verification is still pending (see §6).

- **Fix 1 (weeks 4–5 ONLY):** Fruit/Baby toggle moved from side-stacked pills to a single **horizontal segmented pill centred directly below the floating image**, with a sliding animated thumb. Weeks 6–40 toggle layout untouched. `_FruitBabyToggle` in `week_cards.dart`.
- **Fix 2 (global):** Baby audio now **stops on any navigation** — `BabyVoiceService.stop()` is called in `PageView.onPageChanged` (card swipe) and on week change in `_onControllerChanged`. (Week-strip scroll already muted.) Auto-play still once/card/session.
- **Fix 3 (global, weeks 4–40):** Audited every week's `babySnapshot.size.fruit` (en+hi, both agree) against the PDF and rewrote the **emoji map in `food_emoji.dart`** to match the text. The old map was built from a different size scale (the Hindi comments) → ~15 contradictions fixed (e.g. wk5 apple-seed was 🌾, wk18 sweet-potato was 🫑 capsicum, wk38 pumpkin was 🍉). No JSON text changes needed. Audit table is in the session log.
- **Fix 4 (global):** `SpeakerButton` is now the single shared helper (added a `size` param; hides itself if text is empty). The **non-functional speaker on the Bonding card** was a *decorative* `volume_up` icon in the body — replaced with a real `SpeakerButton` sharing the header's card key (both stay in sync, respect mute, stop-others). Audit: speakers live only on Size Reveal / Baby's Update / Bonding; the mother/partner/info cards have none by design.
- **Fix 5 — data layer (global):** `memory_store.dart` now keeps **one entry per week, ≤2 photos**; added `journalForWeek(week)`, `addJournal` upserts, photo counts capped, and a **migration** on load that collapses any old multi-entry weeks into one (merging text + photos, deleting overflow files) — no data lost on upgrade.
- **Fix 5 — UI (weeks 4–5 ONLY):** Reflect & Remember on wk 4–5 shows the new **"Your Week / Aapka Hafta"** inline view (`WeekEntryView` in `memories_section.dart`): this week's single entry + up to 2 photos, editable + deletable, no cross-week contamination. Weeks 6–40 keep the existing CTA + memory-book list (its CTA now opens the week's existing entry so the 1-per-week rule holds).
- **Fix 6 (week 40):** Confetti is now an **animated, looping fall that re-fires every time** the card becomes visible (controller started in `initState`, restarted in `didChangeDependencies`); emojis + baby orb pop in each time. The PNG poster download is **replaced by a real multi-page PDF keepsake booklet** (`services/journey_pdf.dart` using `pdf` + `printing`): cover → one page per week-with-content (big serif week number + date range, journal body, 1 photo centred / 2 side-by-side, blush-cream bg + botanical corner accents) → closing page. A **missing-weeks pre-screen** (`screens/journey_booklet_screen.dart`) lists weeks with no memory + "Add memory" buttons before generating; output saved to docs as `parentveda_journey_<timestamp>.pdf`, previewed in-app (`PdfPreview`) and shareable (share_plus).

**Packages added:** `pdf ^3.11.1` (resolved 3.13.0), `printing ^5.13.4` (resolved 5.15.0). `printing` has native Android code → a **full `flutter run` is required** (Gradle rebuild; debug APK already built OK).

---

## 0. Session 2 — what changed

This session reworked the look & feel and the journaling flow. **Several big visual changes are intentionally scoped to weeks 4 & 5 only** (a preview to approve before rolling out to all weeks). Verified building + running on the physical device (Samsung SM G990B2, USB); `flutter analyze` clean.

**Scoped to weeks 4 & 5 (preview — not yet on weeks 6–40):**
- **Stage-distinct baby growth** (not zoom): week 4 = blastocyst (cells in a membrane), week 5 = curled C-embryo with head/eye-spot/limb-bud. See `_EmbryoStagePainter` in `living_halo.dart`. Weeks 6–40 still use the old growing-silhouette `_BabyBumpPainter`.
- **Size-card centerpiece redesign**: removed the concentric pink circles + rotating shimmer; big image that **slowly floats** with a faint ambient glow (no hard ring); Fruit/Baby toggle moved to **stacked pills on the right**. Gated by `week <= 5` in `LivingHalo` + `SizeRevealCard`.
- **Gradient card background** now on weeks 4 **and** 5 (`gradientForWeek`), with a smoother 3-stop blush in `CardShell`.

**Global (all weeks):**
- **Journaling fully reworked** → one prompt everywhere: **"How was your last week?"**. One merged composer (`journal_writer_screen.dart`): **write OR speak** (speech-to-text dictation) + attach **up to 2 photos**, **1 text** per note. Entries are **editable + deletable** (deleting a note also deletes its photo files). The old 3-prompt layout + separate photo flow on Reflect & Remember is gone; Bonding/Garbh Sanskar card no longer has a journaling section or the "a moment to reflect" note.
- **Week strip redesigned** to reference-style **circular number-only pills**, with the selected week's **date range as one line above** and a "weeks" label below. **Scroll-snaps**: the centered week becomes active live (cards update); tap still works. **Baby voice mutes while scrolling** the strip.
- **Card chrome**: the header now **scrolls with content** (no longer pinned) and there's a **soft top/bottom fade** so images never look hard-cut (`_FadeScroll` in `card_shell.dart`).
- **Week-40 celebration** is now festive: confetti (`_ConfettiPainter`), 🎉🥳🎊 emojis, baby orb, and a **structured downloadable poster** (photo grid + journal quotes) — captured full-height via a RepaintBoundary inside a scroll view.
- **Watermelon fix**: week 40 size emoji 🎃 → 🍉 (matches "a small watermelon").
- **"Wk" → "Week"/"Hafta"** everywhere (entry badges, trimester line).

**Native (one-time rebuild already done):** added `speech_to_text ^7.0.0` (resolved 7.4.0) + `RECORD_AUDIO` permission + `android.speech.RecognitionService` query in `AndroidManifest.xml`.

**Open follow-ups from this session:** see §6. The user is reviewing weeks 4 & 5; if approved, roll the size-card redesign + gradient + (eventually) per-stage baby art out to weeks 6–40.

---

## 1. Current state — what's done & working

Deployed and verified on a physical Android device (Samsung SM G990B2, USB). `flutter analyze` is clean.

**Data**
- All 37 weeks (4–40) in the **rich PDF schema**, **fully bilingual** (`{en, hi}` on every text leaf) → `lib/data/weekContent.json`.
- Source of truth: `lib/data/Week on Week Pregnancy Tracker.pdf` (English). Hinglish generated + zipped by index (see §4).
- **Reference design images** live in `lib/data/reference-images/` (42 screenshots of a polished competitor pregnancy app, weeks ~0–40) — used to guide the floating-figure, week-pill and toggle design. Not app assets (they include the other app's chrome).

**Cards (fixed order, every week)** — built by `buildWeekCards()`:
1. Size Reveal → 2. Baby's Update → 3. Mom's Journey → 4. Nourishment → 5. Action Plan → 6. Bonding Ritual → 7. **Reflect & Remember** → 8. **Share Your Journey (always last)**.
Week 40 appends a 9th **Celebration** card.

**Features (all 11 prompt sections + extras)**
- **Bilingual toggle** (EN ⇄ Hi) — content + UI chrome, instant.
- **All weeks unlocked** to 40 (`PregnancyController.unlockAllWeeks = true`).
- **Week-40 celebration** — festive confetti finale + downloadable poster (RepaintBoundary → PNG → share) compiling photos + journal.
- **Baby-voice TTS** (`flutter_tts`): auto-play once/card/session (Size + Baby's Update), per-card speaker buttons, global mute in AppBar (persisted), **auto-mutes while scrolling weeks**. Raga player separate.
- **Cute cartoon baby** (CustomPainter) on Baby's Update — blinks + bounces while voice plays.
- **Size card**: Fruit/Baby toggle (persisted); weeks 4–5 use the new floating stage figure, weeks 6+ the classic halo + growing silhouette.
- **Week strip**: trimester label + progress bar; circular number pills with date-range line; scroll-snap selects the centered week; haptics.
- **Journaling ("memory book")**: single "How was your last week?" composer — write or **speak** (speech-to-text), up to 2 photos + 1 text per note, editable + deletable. Stored in `shared_preferences` (+ photo files in docs dir).
- **Photo memories**: captured via camera within the composer and attached to a note (max 2); full-screen viewer; per-note + per-photo delete.
- **Raga audio**: synthesized tanpura-style drone (`assets/audio/raga_drone.wav`), looped.

---

## 2. Architecture / key files

```
lib/
  main.dart                         # boots app; inits controller + 3 services
  app_constants.dart                # kEnableGradientCards, gradientForWeek(week) → weeks 4 & 5
  theme/app_theme.dart              # ⚠️ DO NOT change colors/ColorScheme (fonts: Fraunces/Plus Jakarta/Manrope)
  localization/app_language.dart    # AppLanguage, LocalizedText, S (all UI strings, bilingual)
  models/
    week_content.dart               # WeekContent + sub-objects (rich schema)
    memory_models.dart              # JournalEntry (now incl. photoPaths, max 2), PhotoMemory
  services/
    pregnancy_controller.dart       # ChangeNotifier: loads weekContent.json, language, unlockAllWeeks, weekDates()
    baby_voice_service.dart         # flutter_tts singleton (ChangeNotifier); stop() used for scroll-mute
    size_view_pref.dart             # Fruit/Baby toggle (ValueNotifier + prefs)
    memory_store.dart               # journal + photos; addJournal/updateJournal(photoPaths), deleteJournal (deletes files), capturePhotoFile()
  screens/
    weekly_card_stack_screen.dart   # main screen: appbar, trimester bar, circular week strip (scroll-snap + mute), PageView
    journal_writer_screen.dart      # merged composer: prompt + write/speak (speech_to_text) + up to 2 photos
    photo_viewer_screen.dart        # full-screen photo (route)
  widgets/
    cards/card_shell.dart           # CardShell (scrolling header + _FadeScroll edges), CardChrome (gradient), SoftPill
    cards/food_emoji.dart           # week → produce emoji (week 40 = 🍉)
    cards/raga_player.dart          # reusable looping drone player + equalizer
    baby_voice/baby_avatar.dart     # cartoon baby face painter (blink + bounce)
    baby_voice/speaker_button.dart  # per-card TTS speaker
    week_cards/week_cards.dart      # the 8 cards + buildWeekCards(); SizeRevealCard branches week<=5; Reflect&Remember = CTA + memory book
    week_cards/living_halo.dart     # _buildFloating (weeks<=5) vs _buildClassic; _EmbryoStagePainter, _BabyBumpPainter, _ShimmerPainter
    week_cards/celebration_card.dart# festive week-40 finale + _ConfettiPainter + download
    memories/memories_section.dart  # MemoriesSection (deletable entry list) + MemoryCollage (structured read-only)
    locked_week_view.dart           # UNUSED (kept; isLocked is always false now)
assets/audio/raga_drone.wav
lib/data/reference-images/          # 42 competitor-app screenshots used as design references
```

State management is plain `ChangeNotifier`/`ValueNotifier` singletons — no extra packages.

**Packages**: google_fonts, share_plus ^10.1.4, audioplayers ^6.1.0, path_provider ^2.1.3, flutter_tts ^4.0.2, image_picker ^1.1.2, shared_preferences ^2.3.2, **speech_to_text ^7.0.0** (7.4.0).

---

## 3. Running / deploying (Android)

Prefer **USB** (serial `RZCX50ZKLBA`) — far more stable than wireless for builds:
```bash
flutter run -d RZCX50ZKLBA
```

Wireless ADB still works but **drops frequently** (Android closes Wireless debugging on lock/inactivity; the port changes each time). Reconnect dance:
```bash
ADB="$HOME/AppData/Local/Android/Sdk/platform-tools/adb.exe"
# Enable: Settings → Developer options → Wireless debugging ON (keep screen open), then:
line=$("$ADB" mdns services | grep adb-RZCX50ZKLBA-OzrzHP | grep _adb-tls-connect | head -1)
hostport=$(echo "$line" | grep -oE "[0-9.]+:[0-9]+")
"$ADB" connect "$hostport"
flutter run -d "$hostport"
```
- First build after adding native plugins re-runs Gradle (~slow); incremental builds ~20s. The `speech_to_text` native build is **already done**.
- Adding/removing **assets** requires a full `flutter run` (not hot reload). New AnimationControllers/state fields need a **hot restart (R)**, not just reload.
- **⚠️ `flutter clean` on Windows triggers a Developer-Mode requirement even for Android builds** (corrected session 6). Clean deletes the plugin symlinks, and regenerating them needs Windows **Developer Mode** ON (`start ms-settings:developers` → toggle on) — otherwise the next `flutter run` fails with "Building with plugins requires symlink support". **Avoid `flutter clean` unless you actually suspect stale artifacts**; a plain `flutter run` reuses the existing symlinks and is fine. (The old "Android is unaffected" note was wrong in the post-clean case.)

---

## 4. Data pipeline (how weekContent.json was made)

Use **Python 3.11** (`~/AppData/Local/Programs/Python/Python311/python.exe`) — the `python` on PATH is 3.12 **without pip**.
1. `pypdf` extracts text from the PDF; regex `\{\s*"week"\s*:` + brace-matching + whitespace-normalize → parse each week's JSON.
2. Flatten translatable leaves per week; agents translate each chunk to Hinglish (array length preserved → zip back by index).
3. Merge English (PDF) + Hinglish (agents) → `{en, hi}` per leaf; `garbhSanskar.spokenLine = {hi, en}`; `raga`/`phase` stay plain.

JSON note: top-level is a JSON **array**; per-week keys are `babySnapshot` (with `size.{fruit,length,weight}`), `babyDevelopment`, `momJourney`, `nutrition`, `actionPlan`, `garbhSanskar`, `reflectAndRemember`, `partnerCorner`, `specialMessageFromBaby`, `audioEnabled`. The model (`week_content.dart`) maps these to `snapshot`, `development`, etc.

---

## 5. Known placeholders / caveats

- **Due date is a placeholder** (`_placeholderDueDate`, ~week 24). Date ranges + "current week" derive from it. **No real due-date picker yet.**
- **Raga audio** is a synthesized drone (not real per-week ragas). Drop files in `assets/audio` + set `RagaPlayer.asset` to wire real recordings.
- **Baby art**: weeks 4–5 = new `_EmbryoStagePainter`; weeks 6–40 = old `_BabyBumpPainter` (growing silhouette). Original CustomPainters (Lottie intentionally skipped). Food = curated emoji.
- **Size-card redesign + gradient are weeks 4–5 only** by design — pending approval to roll out to 6–40.
- **Speech-to-text** uses the on-device recognizer; needs `RECORD_AUDIO` (declared). Gracefully shows a message if mic/permission unavailable. iOS would also need `NSMicrophoneUsageDescription`/`NSSpeechRecognitionUsageDescription` if ever targeted.
- **Camera** uses the system intent (no `CAMERA` permission declared) — graceful if declined.
- **Hinglish** was agent-generated + spot-checked; a full human review is worthwhile before launch.
- `locked_week_view.dart` is dead code (unlock-all). `pregnancyWeeks (2).js` is the old data source, unused. Legacy standalone `PhotoMemory` list (`MemoryStore.photos`, `capturePhoto`) is kept only so the week-40 collage still shows any pre-existing photos; new captures attach to journal notes.

---

## 6. Suggested next steps

> **⚠️ Open from session 6 (do these first):**
> - **Confirm the Father screen renders on device** — verification was pending at session end (Mission-card `IntrinsicHeight` fix; see §0 session 6). Run, switch to Father mode, check no render exceptions.
> - **Author Father content** beyond the week-20/day-143 prototype: weeks 4–40 Daily Moment (Learn/Talk/Mission) + the **Weekly Journey** (4 sections × 37 weeks). ≈877 assets total. Author each against the **matching Mother week**; bilingual; Devanagari-QA each batch.
> - The Father **"Start Moment"** button is a no-op stub — wire it (e.g. scroll to / expand the first module) when desired.
>
> **⚠️ Open from session 4 (do these next):**
> - **Baby illustration assets** — the per-week image pipeline is wired (`assets/baby/week_NN.png` → vector fallback). The user is sourcing **licensed** artwork (transparent PNG ~600², `week_04`..`week_40`; see `assets/baby/README.md`). Do **not** use the competitor reference images. When images land, run on device to confirm they show; also confirm the `- assets/baby/` pubspec line is committed on whatever branch reaches `main` (see §0 ⚠️ — it currently isn't on `ui-redesign`).
> - **Move the Home Screen / Daily Moment + Father feature off the working tree** onto `feature/home-screen` (branch from `ui-redesign`, `git add -A`, commit, push) — it's currently uncommitted (see §0).
> - **Merge `ui-redesign → main`** once the user is happy with the UI. Expect a tiny `pubspec.yaml` `assets:`-block merge conflict when `feature/home-screen` later merges (keep all asset lines).
> - A new feature is queued (user will specify).

1. **Due-date picker** to replace the placeholder (drives current week + date ranges; persist in prefs).
2. **Real per-week raga** recordings.
3. Human **Hinglish review** pass.
4. Polish ideas: tune ring size / float speed / glow; per-week baby image sizing once real assets are in.

---

## 7. Constraints (keep)

- Don't change `app_theme.dart` ColorScheme / hex values.
- Don't change card order (Reflect & Remember second-last, Share Your Journey last).
- Don't change the Raga player behavior.
- Keep animations subtle/performant (mid-range Android).
- All new user-facing text must be bilingual.
- Big visual experiments go to **weeks 4 & 5 first** for review before rolling out to all weeks (saves tokens / lets the user vet the look).
