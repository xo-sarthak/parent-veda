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
- `UsageSurface` (`lib/services/usage_events.dart`) has no `more`; pregnancy logs More as `prepare` (STILL-OPEN §80.7).
