# Pregnancy → Trying to Conceive: what the pregnancy pass wants from TTC

Started 2026-09-29 during the pregnancy warmth and gap-analysis pass (branch `claude/magical-ritchie-ynob3a`).
The user's rule for that pass: **work on the pregnancy side only; anything that needs a change on the TTC side is
written here instead of done**, so it can be picked up when TTC is next open.

Each item says what pregnancy did, what TTC would need, and why. Nothing below has been changed in TTC code.

---

## 1. One switch for sex and intimacy content, in both stages

**Pregnancy has:** a new "Sex and closeness" tab in Mind & mood (six reads), and two intimate Is it safe? answers
(Masturbation and orgasm; Breastfeeding while pregnant). `lib/data/doors/pv_door_mind.dart` already carries the
filter helper `mindDoorVisiblePage(page, hideIntimate: ...)` and `kMindIntimateReadIds`.

**TTC has:** the switch, `TtcContentPrefs.instance.hideIntimate` (key `ttc_hide_intimate`), shown in You › Your app
as "What you see · Hide sex and intimacy content" (`lib/screens/ttc/ttc_content_prefs_sheet.dart`).

**What TTC would need:** make the switch stage-neutral (one choice about a shared phone, not a TTC setting), so the
pregnancy door screen and pregnancy You can read and show it. Until then the pregnancy intimate content shows for
everyone, which is the same as TTC's default ("shown").

## 2. Arriving from pregnancy after a loss

**Pregnancy has (building now):** "If your pregnancy has ended" in You › Details, the After a loss door, and in its
Trying again tab a button that moves her to the Trying to Conceive stage when she chooses, using the existing stage
switch (`LifeStageStore.instance.setStage(LifeStage.ttc)`). No TTC code is changed.

**What TTC would need:**
- A first screen that knows she came from a loss (not the ordinary TTC onboarding): no "congratulations on starting
  your journey", gentle, and it can ask whether her periods have come back.
- TTC's own After a loss door (loss reads already exist in `lib/ttc/reads/ttc_reads_after_loss.dart` and
  `ttc_reads_loss_more.dart`) should lead for her, and her cycle day should start from her first period after the
  loss, not from an old last-period date.
- Carry over what matters (her name, partner pairing, conditions) the way the pregnancy-to-parenting move does.

## 3. The reader's Hinglish frame

`lib/data/reads/read_adapters.dart` (shared) has `kConditionFrame` with `hi: 'Padhne se pehle'`, Hindi in Latin
script, which the bilingual rules call a defect. It is used by pregnancy condition reads; if TTC reads use the same
frame, fix it once for both.

## 4. Real experts on pregnancy reads

The user (2026-09-29): "doctors used in TTC are real, you can use them." TTC shows a roster expert only once they
have signed a piece off (`lib/ttc/ttc_expert_signoff.dart`, `docs/TTC-EXPERT-SIGNOFF.md`). Pregnancy will follow the
same rule with its own sign-off list. If the sign-off mechanism moves to a shared file, pregnancy should use it
rather than copy it.

## 5. An "opening soon" state on the shared course page

**Pregnancy has (2026-09-29, the structure pass):** the gap analysis's P1 "Do not sell courses that do not exist yet".
The three recorded pregnancy courses with no lesson made are listed in `kPrepOpeningSoon`
(`lib/data/prepare_data.dart`). On the pregnancy Learn and More tabs they show "Opening soon" where the price was, and a
tap opens a pregnancy sheet with "Tell me when it opens" instead of Buy. Their seed review, the made-up "1,240 mothers"
counts and "reviewed by obstetricians" are commented out.

**What is shared and was not touched:** `PvOfferingScreen` and `PvLearnScreen` (`lib/screens/learn/`) render every
stage's courses, TTC's included, and `lib/booking/booking_catalog.dart` prices them. A course reached through Prepare ›
Courses still shows its price and Buy.

**What it would need:** an `openingSoon` (or "no lessons yet") state on `PvOfferingView` that the shared page reads:
no price, no Buy, the "Tell me when it opens" button, and the booking catalogue refusing to sell it. TTC has the same
question for any TTC course listed before its lessons exist.

## 6. The TTC More screen in the user's screenshot is not in this repository

**What pregnancy did:** built its own More tab (`lib/screens/pregnancy/preg_more_screen.dart`) to the screenshot's
headings and order: Talk to an expert, Courses and masterclasses, Groups, Read and watch, Your journey, Benefits, All
programmes and sessions. The bar is now Today · Learn · Products · Tools · More.

**What was found:** the TTC code on this branch has Today · Learn · Products · Tools · **You** (`ttc_common.dart`,
`_iconsV3`), and its More screen (`ttc_more_screen.dart`) is marked retired. The screenshot's More must be in the
user's unpushed TTC work. When that lands: the two More screens should share one set of rows (they are built from the
same `PvYouSection` / `PvYouRow` parts, so this is a merge of data, not of design), and the icon for More should
match (pregnancy uses `Icons.grid_view_outlined`, the four squares in the screenshot).

## 7. Two small shared-file follow-ups from the new pregnancy bar

- `AppNav.journeyTab` (`lib/services/app_nav.dart`) is 1, which is Journey in the partner's bar and now Learn in hers.
  Going to tab 1 snaps the selected week to this week; harmless on Learn, but the constant's name is now half true.
- `UsageSurface` (`lib/services/usage_events.dart`) has no `more`; pregnancy logs More as `prepare` (STILL-OPEN §81.7).

## 8. One inbox for both stages

**Pregnancy has (2026-09-30):** its own messages, computed from her due date (`lib/services/preg_messages_store.dart`),
with its own inbox (`lib/screens/pregnancy/preg_messages_screen.dart`, reached from More › Your journey › Messages)
and its switches in Reminders. The store follows `TtcMessagesStore` line for line where it can; the one designed
difference (what the id carries) is BACKEND-PATTERNS §16s.

**What the gap analysis asked for:** "Reuse the trying-to-conceive inbox for pregnancy, so every computed message is
also kept there. One ParentVeda: the same inbox in both stages." That means touching `TtcMessagesStore` and
`ttc_messages_screen.dart`, so it was not done in this pass.

**What it would need:** a stage-neutral message model (id, kind, at, title, body, read, destination) and one inbox
screen that lists a stage's messages, with TTC and pregnancy each keeping their own rules for *what* to say. The two
phone-id blocks (918xxx TTC, 919xxx pregnancy) already do not overlap.

## 9. Shared screens still in the old violet (the pregnancy restyle left them alone)

**Pregnancy has (2026-09-30):** every live pregnancy-only screen moved to the one-ParentVeda look (the one ink
#2F2C30, no violet, serif section headings), and while the stage is pregnancy the app theme swaps its violet for the
ink (`lib/screens/pregnancy/preg_theme.dart`, picked in `main.dart`). Held by `test/preg_one_parentveda_test.dart`.

**What was left, because another stage opens it too:**
- `lib/screens/reader/pv_reader_screen.dart`: the one reader, every stage.
- `lib/screens/product_guide/*`: opened from parenting's tools hub and surface router.
- `lib/screens/brackets/hub/problem_hub_screen.dart` and `hub_owed_screen.dart`: parenting's and TTC's V3 homes open them.
- `lib/screens/memories/memories_home_screen.dart` and `memory_personalize_screen.dart`: parenting's More and surfaces.
- `lib/screens/referral/invite_nudge_card.dart`: parenting's My child.
- `lib/screens/prepare/prepare_common.dart`: its `showPrepareBooking` sheet is shown in parenting.
- `lib/screens/v2/v3_daily.dart`, `lib/screens/nutrition/nutrition_recipes_screen.dart`: imported by parenting.
- `lib/widgets/journey/journey_palette.dart`: the journey map's completed week nodes, `arrivalGold` and
  `typeMedical` are violet (0xFF6A30B6 / 0xFF7A4FC2), painted inside the shared `JourneyNodeMarker` and
  `JourneyProgressCard`. The pregnancy map swapped what it sets itself; the completed weeks still show violet.
- `lib/models/journal_entry.dart` (`_jPurple = AppTheme.primary500`): the journal kind colour, also read by the
  father's journal and the parenting journal.
- `lib/models/pv_video.dart` (`kVideoMeta`, the recommended shelf in `primary500`): the parenting video config reads
  it too. The pregnancy Watch & Learn no longer paints thumbnails from it (a drawn mark per category instead).
- `lib/data/product_data.dart` `productImageUrl()`: returns loremflickr placeholder photos, against the "no
  placeholder images" rule. The pregnancy V3 home no longer wires it (its shelf shows the product's own picture or
  a quiet tile); the shared products screen still calls it. The fix belongs in the data file (a real image or
  empty, and every caller falls back to a tile or a drawn mark), so it is one change for all stages.
- `lib/localization/app_language.dart` `prComingSoon` still ends in a heart; it is read by the shared products
  screen. The pregnancy-only keys (`med*`, `ddc*`, `vid*`, `jm*`, `rnBuyComingSoon`, `bodySupportingTitle`) lost
  theirs in this pass, on both the English and Hindi sides.

**What it would need:** whoever owns the other stage decides the look once, for all stages, in these files. The
pregnancy theme already covers the Material defaults in them while the stage is pregnancy; only their hand-set
violets remain.

## 10. A trying-to-conceive test that failed on main (found 2026-10-01, not caused by this branch) — DONE

**Status: fixed on main in 666b348** (the day cell no longer shows "Now" under a month label), and brought into this
branch by the merge of origin/main on 2026-10-01. Nothing further is owed. The note below is kept as the record.

`test/ttc_cycle_companion_test.dart`, "the four states render at phone width: the picture can be switched to days",
fails with **"A RenderFlex overflowed by 8.2 pixels on the bottom"**, raised at line 199 (`expect(tester.takeException(),
isNull)`) after the test taps **Calendar** in the cycle companion.

- **Not from the pregnancy branch.** It fails identically on `origin/main` (54778fd) with none of this branch's
  changes, and nothing in `lib/screens/ttc/` or `lib/ttc/` was edited here. It was the one failure in an otherwise
  green full suite (6,922 passed, 17 skipped).
- **Likely date-dependent.** The test builds its cycle from `DateTime.now()` (`DateTime.now().subtract(...)`, lines 43
  and 212), and it passed in the full runs on 2026-09-30 and failed on the first run on 2026-10-01, so the Calendar
  view probably gets one more row (a sixth week of the month, or a taller month label) on some dates than the test's
  phone-width fixture has room for. A test that depends on the day it runs, plus a fixed-height layout, would do this.
- **Who fixes it:** the trying-to-conceive owner. Either the Calendar picture needs to be allowed to grow (a scrollable
  or a `Flexible` month grid) or the test needs a fixed `now`. It was left alone here because that folder is not ours.
- **Reproduce:** `flutter test test/ttc_cycle_companion_test.dart` on any date that triggers it.
