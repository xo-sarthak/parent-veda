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
