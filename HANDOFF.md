# ParentVeda — Session Handoff

_Last updated: 2026-06-18 (session 3 — 7-fix pass: toggle, audio scoping, emoji audit, speakers, journaling, PDF booklet)_

A Flutter pregnancy-companion app. The core feature is the **Week-on-Week Card Stack**: a horizontal, swipeable set of cards per week (weeks 4–40), bilingual (English / Hinglish), with a calm "premium baby" aesthetic.

---

## 0a. Session 3 — what changed (read this first)

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
- Windows desktop target needs Developer Mode (symlinks) — the "enable Developer Mode" message on `pub get` is desktop-only; **Android is unaffected**.

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

> **⚠️ Session 3 pending verification & approval:**
> - **Not yet run on the physical device.** Connect serial `RZCX50ZKLBA` (USB) and run `flutter run -d RZCX50ZKLBA`, then verify: weeks 4 & 5 (Fix 1 toggle, Fix 5 "Your Week" UI), all weeks (Fix 2 audio-stop, Fix 3 emoji↔text, Fix 4 speakers, Fix 5 data/migration), and week 40 (Fix 6 confetti-every-time + PDF booklet incl. missing-weeks pre-screen, in-app preview, share). First run does a Gradle rebuild for the new `printing` plugin.
> - **Awaiting approval before rollout:** the **Fix 1 toggle reposition** and the **Fix 5 "Your Week" UI** are scoped to **weeks 4 & 5 only**. Once approved, roll both out to weeks 6–40 (the Fix 5 data layer is already global, so 6–40 entries already work). Fix 2/3/4/6 are already global.

1. **Approve weeks 4–5 preview**, then roll the size-card redesign (floating figure, no circles, toggle-below) + gradient + the new "Your Week" journaling UI to weeks 6–40, and design per-stage baby art for later weeks (fetus → baby) à la the reference images.
2. **Due-date picker** to replace the placeholder (drives current week + date ranges; persist in prefs).
3. **Real per-week raga** recordings; **illustrated fruit/baby art** to replace emoji/painter.
4. Human **Hinglish review** pass.
5. Polish ideas: tune float speed / image size / ambient glow / toggle placement per user feedback; consider suppressing post-settle voice auto-play entirely if still felt noisy.

---

## 7. Constraints (keep)

- Don't change `app_theme.dart` ColorScheme / hex values.
- Don't change card order (Reflect & Remember second-last, Share Your Journey last).
- Don't change the Raga player behavior.
- Keep animations subtle/performant (mid-range Android).
- All new user-facing text must be bilingual.
- Big visual experiments go to **weeks 4 & 5 first** for review before rolling out to all weeks (saves tokens / lets the user vet the look).
