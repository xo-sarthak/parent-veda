# My Child (Parenting Home) — complete record

**Screen:** `lib/screens/post_pregnancy/my_child_screen.dart` (route `pp/my_child`)
**Prepared for review · last updated 2026-07-17**

One document covering the My Child screen end to end: where the requirement came
from (§1), what was built and when (§2), the request-by-request detail of the
latest work (§3), the engineering appendix (§4), and what is still open against
the original plan (§5).

Quick map:

| Date | Milestone | Version |
|---|---|---|
| 9–10 Jul 2026 | **Planning notes** — the parenting build + the "make both apps feel identical" mandate | discussion notes (PDF) |
| 7 Jul 2026 | Screen **created** — a "living profile" page inside the Explore menu | `90871cc` (+4 same-day) |
| 10 Jul 2026 | **Promoted to the parenting home**, rebuilt around the developmental "leaps" | `8b57ff3` |
| 12 Jul 2026 | Real video playback wired into the leap video | `404cb1e` |
| 13 Jul 2026 | Growth linked to the Growth Journey tool | `652ef60` |
| 16–17 Jul 2026 | **Full UI harmonisation** — matched to the pregnancy app | *uncommitted* |

---

## 1 · Where this came from — the 9–10 July planning notes

The parenting build and the harmonisation both trace to a planning discussion
(the "9–10 July discussion notes"). The single directive that this session
executed, quoted verbatim:

> "UI of post pregnancy app has to be completely same as pregnancy app including
> section placement, format, font, emojis, style, look and feel, section by
> section division, box coloring, use same design language, font size, color
> combinations so that both the apps feel like same app. User shouldn't be able
> to differentiate bw 2 apps, the flow from pregnancy and post pregnancy should
> feel the same."

The notes also confirm My Child was being made the home ("…same as **my child
(i.e. Home now)**"). The items in those notes that concern the My Child home,
and their status today:

| From the 9–10 July notes | Status on the home |
|---|---|
| "…brain, physical, language, emotion same as my child → **child snapshot**" | **Done** — the Child snapshot carries Brain / Physical / Language / Emotional (+ Nutrition). |
| "**Ask veda bottom right floating button**" | **Done** — a global Ask Veda circle FAB now floats on every screen of both apps. |
| "**Search bar in all sections**" | **Partly** — search added to the My Child header; a full app-wide sweep is not done. |
| "…remove **that progress bar** from those cards" (development) | **Done for the home** — the storm→sun day-progress bar was removed from the hero. |
| "**Remove looking ahead section**" | **⚠ OPEN** — `_lookingAhead()` is still mounted on the home (`my_child_screen.dart:124`). See §5. |

(The notes are far broader — naming, compare, recipes, watch/read, community,
find-help, products, paid tiers, etc. — but only the rows above touch the My
Child home. The rest is tracked elsewhere.)

---

## 2 · Version history, by date

The screen's evolution, oldest first. It was **created as a menu page**, then
**became the parenting home**, then **harmonised with the pregnancy app**.

### 7 July — Created (a page inside the menu)
First version: a **"living profile" page** for the child, reached from the Explore
menu — not the home. Answered "who is my child today?" across seven sections.
Four same-day follow-ups (as the wider parenting app was stabilised): flow /
navigation / CRUD fixes, a first dash clean-up pass, and links into Vaccination,
Compare and Health. *(`90871cc`, `e31ff48`, `d2e4fa5`, `266b5f3`, `e1a6845`.)*

### 10 July — Promoted to the parenting home (leap overhaul) ★
The pivotal change: My Child **became the home**, rebuilt around the
**developmental "leaps"** model. A `home` mode was added and the app's doorway now
opens it directly (route `pp/my_child`). Reorganised into: leap header, identity
+ growth, daily tip, leap video + explanation, development snapshot, milestones,
journal, and leap-related watch/read. Biggest pre-session change (~1051-line
churn → 782 lines). *(`8b57ff3`.)*

### 12 July — Real video playback
The leap's recommended video was wired to the native video engine, so it plays a
real video instead of a placeholder. *(`404cb1e`.)*

### 13 July — Growth linked to the Growth Journey tool
The growth section's "full chart" now opens the dedicated Growth Journey tool —
a summary-here, detail-there pattern. *(`652ef60`.)*

### 16–17 July — Full UI harmonisation ★ (current, uncommitted)
**Problem:** side by side, the two apps *felt like different products*, though
they share the same colours; a parent crosses between them in one tap, so the
mismatch was very visible. **Finding:** the colours were identical — the divergence
was entirely in *form* (parenting cards floated on a purple glow vs the pregnancy
soft shadow; card sizes, headings, spacing, fonts differed), because the parenting
app had **no shared card component** and every screen re-invented its own.

What was built (all on the home): one shared card style copied from the pregnancy
app; the hero rebuilt (photo + name + leap + growth in one card, meaningless
labels removed); a **leap-journey bar** (the parenting trimester-bar equivalent);
every section turned into a proper card with its heading on top; the daily-tip and
video cards made identical to the pregnancy ones; the child switcher fixed; a
global Ask Veda button on every screen of both apps; and polish to match
(background tint, card widths, fonts, header, a 108-string dash clean-up).
**307 tests pass, analyze clean. Every replaced element commented, not deleted.**
Request-by-request detail in §3; engineering detail in §4.

---

## 3 · Request-by-request log (16–17 July session)

Each request reproduced faithfully (lightly tidied for reading); the changes are
the real edits.

**3.1 · Kickoff — "the two apps feel different."** Think like a senior UI/UX
person; the parenting side looks different from the polished pregnancy app; carry
the pregnancy look forward; confine the Leap-4 hero so the video shows without
scrolling; restore the missing child switcher; no content changes; comment out,
never delete. *(You chose "also make growth denser" when asked how far to go.)*
→ Shared card language in `pp_common` (`ppCardRadius=26`, `ppCardDecoration`,
`ppCard`, and the shadow changed from the **purple glow** to the pregnancy **ink
lift**); hero merged (`_leapHeader`+`_identity` → `_leapHero`, both commented);
growth compressed to a strip; section beat 34→26; child switcher rewired; new
`pp_ui_harmony_test.dart`.

**3.2 · Hero deep-rebuild — "put growth inside, cut the noise."** Extend the hero
and fold growth into it with Chart/Edit toggles; remove "Curious Explorer", "Past
the worst…", the day/night-looking progress bar, and "Live now"; the top row
(hamburger + "My Child") wastes space → a profile/brand header + a search bar;
Watch/Read waste space.
→ Growth folded into the hero (white-on-purple + Edit/Chart); removed LIVE NOW,
the character line, the storm→sun bar, the status sentence (all commented); brand
header + search bar; video moved under the hero; rails tightened; section titles
reduced.

**3.3 · Cards, texture, carousel, "jazz", dashes.** Search bar → just an icon
where the hamburger is, plus a profile icon; the Today's-tip card should look like
a tip; **every section should be inside a card** (the pregnancy app does); the
purple hero looks **bland** — add texture; the horizontal carousel wastes space —
use the pregnancy products-carousel design; headings all look the same — add
jazz; remove the "-" dashes (looks AI-made).
→ Header icons (search / profile / Explore); new `ppSectionCard`, `ppCarousel`,
`ppLead`, `ppRowDivider`; every section wrapped in a card; hero texture blooms;
heading accents varied; leads above hero/video; carousels rebuilt; dash cleanup
flagged (done in 3.5).

**3.4 · Tip card — "make it clearly a tip; copy the pregnancy one exactly."**
"Today's tip" became "One small thing to try", which no longer reads as *today's
tip*; pick the pregnancy "Today's Parenting Tip" card exactly; drop the golden
gradient.
→ `_dailyTip` rebuilt as a faithful copy of the pregnancy `GrowModule`: leaf
eyebrow "TODAY'S PARENTING TIP", quoted title, body, full-width "Read more".
Content unchanged.

**3.5 · Dashes + global Ask button + white-bg + header visibility.** Implement the
dash removal; the floating Ask button (bottom-right) should be on **every** screen
of both apps, above the pregnancy Mom|Dad toggle; the home looks too white — match
the pregnancy tint; the parent name in the header isn't fully visible. *(Leap-bar
idea held for discussion.)*
→ 108 dashes → commas via a quote-aware replacer (arithmetic + hyphenated words
spared); global Ask Veda FAB (`global_ask_fab.dart`); background `ppBg`→`ppPanel`;
header wordmark fixed (smaller icons, plain `Text`).

**3.6 · Ask button shape + font consistency.** The original parenting Ask button
was a plain circle with the sparkle — use that across the whole app; fix any
inconsistent fonts between the two homes.
→ FAB → 56px sparkle circle; fonts aligned (leads Jakarta 20 **w800**, eyebrows
11.5, section titles 19).

**3.7–3.9 · Leap-journey bar (discuss → build → compare → keep).** Like the
pregnancy trimester bar, but for the leap (the old day-progress one made no sense).
→ Discussed the axis tension; you chose the **segmented "Leap N of 10"** axis and
the **in-hero** placement. Built `_leapJourney` (10 dots; current dot amber-if-fussy
/ white-if-calm; chevron → Leap Calendar). Trialled a below-hero strip
(`_leapJourneyStrip`) for comparison, then reverted to in-hero (your preference).

**3.10 · Make the bar's tap obvious.** Added a "Leap 4 of 10 ›" chevron (a
"Timeline" label was added then later removed — 3.14).

**3.11 · Greeting into the card.** Like the pregnancy "Good morning", put "How
Aarav is today" **into** the hero to save space. → The lead above the hero moved in
as a greeting line.

**3.12 · Video card = the pregnancy "Today's Video".** → `_leapVideo` rebuilt to
that shape (header inside + "More videos" + thumbnail + title + meta + Watch
button). Content unchanged.

**3.13 · Match the card width.** The parenting cards looked narrower. → Confirmed:
24px side padding vs the pregnancy 18px; changed `_pad` to **18px**.

**3.14 · Remove the "Timeline" word** from below the leap-journey bar. → Removed;
the "Leap 4 of 10 ›" chevron still signals the tap.

---

## 4 · Engineering appendix (16–17 July)

### Files touched

| File | Change | Scale |
|---|---|---|
| `screens/post_pregnancy/my_child_screen.dart` | The home rebuild | ~+986 |
| `screens/post_pregnancy/pp_common.dart` | Shared card language + helpers | ~+210 |
| `screens/post_pregnancy/multichild_sheet.dart` | Orphaned child switcher made real | ~+278 |
| `widgets/global_ask_fab.dart` | **New** — global Ask Veda FAB (both apps) | new |
| `main.dart`, `screens/main_scaffold.dart`, `brand/premiere_screen.dart` | Wire the global FAB | small |
| `screens/post_pregnancy/pp_{development,watch,reading,daily_tips,leaps,milestones}_data.dart` | Dash cleanup | 108 strings |
| `test/pp_ui_harmony_test.dart` | **New** — pins the harmonisation | new |
| `test/post_pregnancy_smoke_test.dart` | Updated for the rebuilt hero | small |

### A · Shared card language (`pp_common.dart`)
Root cause: no card helper, so radii (16–26) and four shadows had drifted. Added
`ppCardRadius=26`; `ppCardShadow` changed from the purple glow (`#6A30B6 @15%`,
spread −12, y+14) to the pregnancy ink lift (`#0D2D144C`, spread 0, y+10) — old
value commented; `ppCardDecoration`, `ppCard`, `ppSectionCard` (port of the
pregnancy `HomeCard`), `ppRowDivider`, `ppCarousel` (port of the products
carousel), `ppLead`, `ppSectionEyebrow`. pp still never imports `AppTheme`.

### B · The home, section by section
Brand header (mark + wordmark + search/profile/Explore icons; wordmark full);
hero (`_leapHero` — greeting line + identity + leap-journey bar + folded-in growth
+ texture; removed LIVE NOW / Curious Explorer / storm-sun bar); leap-journey bar
(`_leapJourney`, in-hero, amber/white state, chevron → Leap Calendar; strip
`_leapJourneyStrip` commented); video (`_leapVideo` → pregnancy `TodaysVideoCard`
shape); daily tip (`_dailyTip` → pregnancy `GrowModule`); snapshot / milestones /
journal / leap-explained / watch / read → `ppSectionCard` or `ppCarousel` with
distinct accents; whole-screen: bg `ppPanel`, padding 24→18, beat 34→26, fonts
aligned.

### C · Child switcher (`multichild_sheet.dart`)
Was built but orphaned + hard-coded; now reads real `ChildProfileStore.children`,
calls `switchTo`, computes each child's age + leap, opens from the hero photo and
name▾.

### D · Global Ask Veda FAB (`global_ask_fab.dart`, new)
Sparkle circle via `MaterialApp.builder` over every route in both apps; a
`FabRouteObserver` opens the parenting Ask Veda in the `pp/my_child` stack, the
pregnancy one elsewhere; hides over sheets/dialogs/Premiere/splash; above the
pregnancy Mom|Dad pill. **Not covered by widget tests** — verify by hand.

### E · Dash cleanup
108 " - " → commas via a quote-aware replacer touching only string literals
(arithmetic and `6-month-old`/`high-contrast` untouched).

### F · Tests
New `pp_ui_harmony_test.dart` (shadow, radius, palette equality, card shell, hero
states the child once, switcher). `post_pregnancy_smoke_test.dart` updated. Suite:
**307 pass**; analyze clean.

### G · Kept for revert (commented, not deleted)
`pp_common`: old purple `ppCardShadow`. `my_child_screen`: `_leapHeader`,
`_identity`, `_growth`/`_growthOld`, `_leapJourneyStrip`.

### H · Full commit history
`git show <commit>:lib/screens/post_pregnancy/my_child_screen.dart` shows any past
version.

| # | Commit | Date | Lines | Note |
|---|---|---|---|---|
| 1 | `90871cc` | 07-07 | 639 | Created — Explore page, not home |
| 2 | `e31ff48` | 07-07 | 641 | Stabilization touches |
| 3 | `d2e4fa5` | 07-07 | — | Vaccination link |
| 4 | `266b5f3` | 07-07 | — | Compare edu + first dash pass |
| 5 | `e1a6845` | 07-07 | — | Compare engine / health CRUD |
| 6 | `8b57ff3` | 07-10 | 782 | ★ Became the home + leap overhaul |
| 7 | `404cb1e` | 07-12 | 782 | Native Watch video wiring |
| 8 | `652ef60` | 07-13 | 784 | Growth Journey routing |
| 9 | *uncommitted* | 07-16/17 | ~1030 | ★ UI harmonisation (this record) |

---

## 5 · Open items & flags

- **⚠ "Remove looking ahead section" (9–10 July notes) — not done.** `_lookingAhead()`
  still renders on the home (`my_child_screen.dart:124`). The note sits near the
  *development-section* items, so it may have meant the development page's Looking
  Ahead rather than the home's next-leap line — **needs a one-word confirm**: remove
  it from the home too, or leave it.
- **"Search bar in all sections"** — the home now has search; a full app-wide sweep
  (every parenting section) is not done.
- **This work is uncommitted** — versions 1–8 are in git; version 9 (all of §3)
  lives only in the working tree. It should be committed to be safe.
- **Parked by choice** (not loose ends): the other parenting tabs (Tools,
  Community, Recommendations, Products); the two deep tells (`PpStriped` image
  placeholders, Fraunces used as body copy); a pregnancy-side "My Profile".
