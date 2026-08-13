# V2 build plan — pregnancy Today, inside the Focus toggle

> **Status: APPROVED, NOT STARTED.** Do not begin until the user says go. When he does,
> run the whole thing in **one continuous pass** — he will not review step by step.
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

## 7. What happens after

- User picks a palette → `AppTheme` migration becomes its own piece of work.
- User approves the block structure → real block art gets generated from written prompts.
- The revamp spec lands → structure moves, and design is applied over it (W13/P02).
- Then, and only then, the same treatment spreads to TTC and parenting.
