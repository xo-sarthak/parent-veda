# V2 build plan — pregnancy Today, inside the Focus toggle

> **Status: BUILT 2026-08-14.** `flutter analyze` clean of new issues (20 pre-existing,
> one introduced and fixed). **2,212 tests pass**, 5 skipped. Debug APK built and
> installed on the device.
>
> **Outcomes and corrections are in §8 at the foot of this file.**
>
> Decisions behind this: `DESIGN-DECISIONS.md` (W01–W23, Q1–Q9). Evidence:
> `DESIGN-BRIEF.md`, `APP-AUDIT.md`, `FLO-TEARDOWN.md`. System: `DESIGN-LAYER.md`.

---

## Context — why this build exists

The mother's pregnancy Today screen is the most-used surface in the product and, measured
against every other surface in it, the weakest (`APP-AUDIT.md`). The goal of the revamp is
stated plainly by the user: **when she opens the app, make her stay.**

This pass proves the new direction on one screen, behind the toggle that already exists,
without touching anything shipped.

---

## Hard boundaries — what this build must NOT touch

- `lib/screens/home_screen_b.dart` — **Classic. Frozen.**
- `lib/theme/app_theme.dart` — **71 `static const Color`s. Not converted.** See §2.
- The string tables · any route · any store · Father Mode · TTC · parenting.

**Zero changes to the shipped path.** If a change appears to require touching Classic or
AppTheme, stop and ask instead.

---

## 1. The sandbox already exists

`lib/screens/home_focus_screen.dart` is the target. It is already correct in three ways
the plan depends on:

- It **sits beside** the shipped Today rather than replacing it; the `Classic | Focus`
  pill in `today_home_screen.dart` chooses (`TodayVersion.focus => HomeFocusScreen`).
- It **reuses the real card widgets** (`GrowModule`, `TodaysVideoCard`,
  `DailyReadsHomeCard`, `LaunchSpotlight`, `InviteNudgeCard`) rather than copies — its own
  header explains why: a version built from copies drifts the moment anyone touches the
  original.
- It is **English-only on purpose**, which matches the user's instruction for this pass:
  *do not wire Hindi; the content exists, this pass is about how it is displayed.*

---

## 2. Palette comparison — local, not global

**The constraint:** `AppTheme` is **71 `static const Color` values**. Runtime switching
would mean converting the entire theme layer — unacceptable risk to a shipped app for the
sake of a comparison.

**The solution:** a **local palette object living inside the Focus screen only**, with a
chip row in the header to switch. Nothing outside this screen reads it. When a direction
wins, `AppTheme` migrates properly as separate work.

Five options:

| | Direction |
|---|---|
| **Baseline** | Current app unchanged — so the delta is visible |
| **A** | Warm paper — bone/clay ground, violet action |
| **C** | Cool and clean — today's direction, tightened |
| **D** | Clay and terracotta — warmer, earthier |
| **E** | Stage temperature — pregnancy's own warmth (Flo's model) |

Each palette supplies: page ground · card surface · ink ramp · line · the single loud
action colour. **One loud colour only** (Q4) — everything else stays quiet.

---

## 3. The hero — 3×2 personalised blocks

**Six blocks** (3 columns × 2 rows). At 360dp this gives ~110dp per block — enough for an
icon and a readable label; nine would push all existing content below the fold.

**Personalised, not a fixed menu** (W-round-2). The shape is constant across stages and
child ages; the contents are chosen for today:

`Today's practice` · `This week (30)` · `Next scan` · `Today's read` · `Today's video` ·
`Ask a question`

- Destinations resolve through the existing **`app_structure.dart`**, not hardcoded routes
  — the same reason the file already gives for its "also" row.
- **Line icons in this pass**, real art later (user's call). Structure is judgeable
  immediately; finish is not. Generation prompts for the real block art get written
  separately once the layout is approved.
- Blocks obey the card rule (`DESIGN-LAYER.md` §6a): image/icon + title, **no counts, no
  "Read more", nothing that accrues.**

**Below the hero:** existing content stays — `LaunchSpotlight`, `InviteNudgeCard`, the
"also" row — restructured to the new card rule.

---

## 4. The six defects — all revamp-independent

| # | Defect | Location | Fix |
|---|---|---|---|
| 1 | **Debug tools reachable by a mother** | `lib/screens/tools_hub_screen.dart:125,132` and `lib/screens/post_pregnancy/tools_hub_screen.dart` | Gate behind `kDebugMode` |
| 2 | **Commerce out-weighs content** — "Buy Book" solid violet, "Read summary" pale tint | `lib/screens/read_next_screen.dart`, `lib/screens/father/father_reads_screen.dart` | Swap emphasis: "Read summary" solid, "Buy Book" quiet |
| 3 | **View counts** (to 56.4K) | `lib/screens/community_screen.dart:180` `_viewsLabel`, used ~line 1843 | Remove |
| 4 | **Ask Veda FAB covers content** | callers of `kAskFabReserve` (`lib/widgets/global_ask_fab.dart:77`) | ⚠️ **Not a FAB bug — screens are not reserving.** Add the reserve where missing; scope the FAB to content screens only, absent from Calendar/Journal/forms |
| 5 | **"Open →" repeated ~24×** | `lib/screens/tools_hub_screen.dart` | Remove — the whole card is tappable |
| 6 | **Decorative emoji** against `CLAUDE.md` | grep; community cards, Ask Veda category headers, article row icons | Replace with line icons |

**Scope guard on #6:** if the emoji sweep proves sprawling, do the pregnancy side and
**list the rest** rather than silently expanding scope.

---

## 5. Verification

1. `flutter analyze` clean of new issues; full suite passing.
2. Build and install on the user's device (Samsung SM-G990B2).
3. **Screenshot every palette** on the real phone and send the comparison — do not
   describe it.
4. **Confirm Classic is byte-identical in behaviour** — open it, screenshot, compare.
5. Confirm the six defects are gone, each with a screenshot.

---

## 6. Known limitations to state up front, not discover

- **The block grid will look unfinished** in this pass — six blocks need six pieces of
  imagery and icons are placeholders. **Structure is judgeable; finish is not.** Say this
  when delivering so grey squares are not mistaken for a failed idea.
- **Palette E cannot fully demonstrate itself on one screen** — its point is that
  temperature *varies by stage*. On pregnancy Today it shows only pregnancy's assigned
  warmth.
- **English only.** Any Hindi wiring is deliberately deferred.

---

## 8. Outcomes and corrections — 2026-08-14

### ⚠️ The reversal: the Focus screen no longer reuses the shipped cards

**Planned (§1):** reuse `GrowModule`, `TodaysVideoCard`, `LaunchSpotlight` and the rest,
because a comparison against copies is dishonest and copies drift.

**Built first, and it was wrong.** The argument was sound and produced the wrong object: a
designed hero sitting on top of somebody else's screen. The user's words —
*"everything below that hero section feels so random… at least give me a complete looking
home screen."* He was right. **A home screen is judged whole**, and half a design reads
worse than none.

**Now:** `lib/screens/v2/v2_sections.dart` holds palette-aware presentations of the **same
real content** those cards read — `HomeDay.grow / garbhSanskar / story / talk`, and real
`ReadItem`s from `read_next_data`. **No copy is invented**; a section with empty content
renders nothing rather than filling itself in.

**The cost, stated rather than discovered later:** this screen no longer tracks changes to
the shipped cards. If `GrowModule` gains a field, this does not. Acceptable for an
experiment whose purpose is to look different; unacceptable the moment it graduates, at
which point these sections must become the real widgets rather than a parallel set.

### The screen as built

Header · **six-block grid** · **full-bleed week hero** · an italic insight line ·
**practice card** · **reads rail** (real articles, tinted covers, category + title +
reading time) · two prompt cards · ALSO TODAY chips · palette bar.

Ordering still answers to `LandingFocus` — the focus decides whether practice or reads
leads, and **nothing is ever removed by it**.

### ⭐ `.en`, not `.now` — and why that is right here

The user's complaint was Hindi and English mixed on one screen. The screen's own strings
were always English; the mixing came from the **reused shipped cards** reading the string
table, plus the nav, in an app set to Hindi.

Every string in the V2 sections now reads **`.en`**, the identity side of `LocalizedText`.
That forces English regardless of the app's language, which is correct for a screen that
is English **by decision** rather than by her setting.

⚠️ **Do not copy this habit into shipped screens** — there it would pin a mother to
English whatever she chose. When the experiment graduates it goes through the string
table and these become `.now`.

### The week tile — my error, twice corrected

`assets/baby/week_NN.jpg` was pointed at a 110dp grid tile. The week images are **dark,
full-frame photographs**; the other five tiles are objects isolated on transparency. It
was the only dark tile and the eye went to it for the wrong reason.

The photograph is good — it now runs **full-bleed as `V2WeekHero`**, at the size it earns.
The grid tile shows its icon and **still needs a sixth generated object** in the house
style (see `docs/IMAGE-PROMPTS.md`).

### Defects — 4 fixed, 1 retracted, 1 deferred

| Defect | Outcome |
|---|---|
| Buy Book vs Read summary | ✅ Emphasis swapped in both pregnancy and father reads |
| Fabricated view count | ✅ **Removed, not commented out.** It was `likes*247 + comments*90 + 503` — an invented statistic rendered as measurement |
| FAB overlap | ✅ `kAskFabReserve` is **218**; Tools and Calendar reserved **110**. Root cause: the parenting side reserves it in 17 screens, the pregnancy side in none |
| "Open →" ×24 | ✅ Removed — the card is the tap target |
| Debug tools | ❌ **RETRACTED — never a defect.** Already behind `if (kDebugMode)`. Visible only because the device runs a debug build. See `APP-AUDIT.md` §3.4 |
| Decorative emoji | ⏸️ **Deferred, mis-scoped.** 1,199 instances, 244 in chrome files; `CLAUDE.md` already exempts ✓★♥. The community ones are **author identity** (`🩺` doctor, `🙂` member) — the exact system W20 rebuilds. Half-doing it leaves the app inconsistently emoji'd |

### Green

`flutter analyze` — no issues in the changed files. **2,212 tests pass**, 5 skipped.

## 7. What happens after

- User picks a palette → `AppTheme` migration becomes its own piece of work.
- User approves the block structure → real block art gets generated from written prompts.
- The revamp spec lands → structure moves, and design is applied over it (W13/P02).
- Then, and only then, the same treatment spreads to TTC and parenting.
