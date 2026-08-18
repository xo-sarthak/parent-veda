# Level Map build — where it stands

Written at high context so the next session resumes without re-deriving anything.
Companions: `BRACKET-AUDIT.md` (the truth audit) · `BRACKET-SCREEN.md` (screen spec) ·
`BRACKET-BUILD-CHECKLIST.md` (phases). Plan file:
`C:\Users\sarth\.claude\plans\ok-so-let-s-have-fluffy-twilight.md`.

## Nothing is committed

The whole tree is uncommitted at the user's instruction — *"i will commit all in the
end"*. Files added or changed this session:

```
lib/models/bracket.dart                         NEW  the 4-state model
lib/services/bracket_resolver.dart              NEW  the chokepoint
lib/services/surface_router.dart                NEW  pregnancy id -> screen
lib/services/parenting_surfaces.dart            NEW  pp_ surface list
lib/data/brackets/pregnancy_brackets.dart       NEW  10 brackets x 7 layers
lib/data/brackets/parenting_brackets.dart       NEW  11 brackets x 7 layers
lib/screens/brackets/bracket_screen.dart        NEW  one screen, every stage
lib/screens/v2/v3_bracket_art.dart              NEW  21 drawn bracket marks
lib/screens/post_pregnancy/pp_home_v3.dart      NEW  parenting V3
lib/screens/post_pregnancy/pp_home_version.dart NEW  Current|V3 toggle
lib/screens/post_pregnancy/pp_hero_field.dart   NEW  the page field
lib/screens/post_pregnancy/pp_surface_router.dart NEW pp id -> screen
test/bracket_model_test.dart                    NEW  16 tests
lib/services/app_structure.dart                 +4 surfaces
lib/screens/home_v3_screen.dart                 10 bracket doors
lib/screens/v2/v2_block_grid.dart               columns param, gradient wells
lib/screens/home_screen_b.dart                  pushes PpHomeScreen
test/landing_focus_test.dart                    guard rewritten
docs/BRACKET-*.md                               NEW
lib/screens/post_pregnancy/pp_hero_art.dart     DELETED (five drawn scenes)

--- added in the TTC + symmetry pass ---
lib/screens/v2/v3_dev_mark.dart                 NEW  6 drawn development marks
lib/screens/v2/v3_hero_field.dart               NEW  the field, now shared
lib/data/brackets/ttc_brackets.dart             NEW  7 brackets x 7 layers
lib/services/ttc_surfaces.dart                  NEW  ttc_ surface list
lib/screens/ttc/ttc_surface_router.dart         NEW  ttc id -> screen
lib/screens/ttc/ttc_home_v3.dart                NEW  TTC V3
lib/screens/ttc/ttc_home_version.dart           NEW  Current|V3 toggle

--- added in the skilling-UI pass ---
lib/data/brackets/skilling_brackets.dart        NEW  12 brackets x 7, ZERO live
lib/screens/v2/v3_skill_art.dart                NEW  12 drawn skill marks
lib/screens/skilling/skilling_preview_screen.dart NEW the preview (debug only)
lib/services/life_stage_store.dart              +LifeStage.skilling
lib/services/journey_state.dart                 skilling infers nothing
lib/services/landing_focus.dart                 skilling has no focus
lib/screens/v2/v2_block_grid.dart               +skillMark slot
lib/screens/post_pregnancy/explore_drawer.dart  +kDebugMode preview row
lib/screens/post_pregnancy/pp_hero_field.dart   now a forward to v3_hero_field
lib/screens/v2/v2_sections.dart                 +v2PpReadCover (7 collections)
lib/screens/ttc/ttc_common.dart                 openTtc -> TtcHomeScreen
lib/screens/splash_screen.dart                  _ttcRoute -> TtcHomeScreen
```

Suite: **2245 passing, 5 skipped.** Analyze clean (12 pre-existing info lints in
`ask_veda_service.dart` only).

## Decisions, settled

| # | Decision |
|---|---|
| D1 | Grid is **4 columns × up to 3 rows** = 12 slots; covers every stage |
| D2 | **4-state enum**: `live · notReady · notCore · notApplicable` |
| D7 | **The doors ARE the L1 brackets**, nothing else. Names from the workbook |
| D8 | **Palette = what V3 runs today** (`_baseline`). No AppTheme migration |
| — | **Extras is a real 7th layer.** Grey fill = build it |
| — | **Bracket ids are stage-prefixed** + a `theme` field for cross-stage links |
| — | **Text beats fill** in the workbook — they disagree in 38 places |
| — | **No illustration in heroes.** Information + an abstract field |
| — | **You overlap, you do not blend.** Field = page, content = sheet |
| — | **Ask Veda / `veda_index` is LAST** — separate repo, user wants to be present |

## What is on the phone

**Pregnancy V3** — 10 bracket doors → bracket screens → real existing tools via
`surface_router`. Hero keeps its photoreal weekly render and its **hard cut** (three
dissolve attempts failed; see the note in `v3_sections.dart`).

**Parenting V3** — behind a `Current | V3` pill at the `pp/my_child` push site. Order:
information hero → 11 doors → Right now → One thing to try → To read → Watch → Things
that help → Keep today → Asked a lot → Looking ahead.

## TTC V3 — built this pass

Seven brackets (`lib/data/brackets/ttc_brackets.dart`), a surface list, a router, a
home, a `Current | V3` toggle wired into **both** entry points (`splash_screen`'s
`_ttcRoute` and `ttc_common.dart`'s `openTtc`).

**The finding worth keeping: TTC's Course and Consult layers are the STRONGEST in the
product.** Pregnancy and parenting have five specialists with mock slots against forty
brackets; TTC has **thirteen priced offerings with named experts** in
`ttc_prepare_data.dart`, and they match the workbook's asks nearly cell for cell — "The
PCOS programme", "The half nobody talks about", "After a loss", "Preparing for IVF",
"Fertility, honestly". This stage's grid is genuinely a different shape, from data.

**One new rule the other two tables did not need.** Four cells put the workbook's
refusal against something that demonstrably ships. Resolved as: **a refusal colliding
with shipped inventory becomes `notCore`, not `notApplicable`.** It exists, and it
belongs on Prepare rather than in the explainer. `notApplicable` stays reserved for
refusals with nothing behind them. **The four ⚑ cells are the user's to re-rule.**

## Open, in priority order

1. **Parenting SKUs have no image field at all.** The rail now shows drawn category
   marks reusing the bracket set — ours, offline, right by construction. Real product
   photography replaces it; that is catalogue data, not wiring.
2. ~~No gateway to the spine~~ — **closed.** See "The eyebrow is the door" below.
3. **FAQ answers truncate at 3 lines** with no expand.
4. **Skilling: UI built, nothing behind it.** See its own section below.
5. **The three near-miss read photos** — `sleep`, `health`, `play` in
   `_kPpCollectionPhoto` carry an on-register but off-subject image, because an
   unverifiable Unsplash id 404s into a blank. First to replace with real art.
6. `test/landing_focus_test.dart` no longer scans `home_v3_screen` — the guarantee moved
   to `bracket_model_test.dart`. Do not "restore" it.

## Closed this pass

- Snapshot icons → `v3_dev_mark.dart`, six drawn marks (brain, language, physical,
  hands, emotional, social). Rendered offline before shipping; the brain came out as a
  leaf and the thumb was buried on the first pass, both fixed.
- Parenting to-read rows → 74dp covers, pregnancy's `V3ReadRow` shape exactly.
- The field bleeding below the last section → **the sheet owns the bottom clearance
  now.** Once a background belongs to the page, every piece of scroll-view padding is a
  window onto it.
- Hero sub-lines → `ink2`, not `ink3`. **A grey calibrated for a neutral ground loses
  contrast on a tinted one faster than it loses lightness.** Anything on the field takes
  one tier darker than the same type on the sheet.
- `PpHeroField` → `lib/screens/v2/v3_hero_field.dart` as `V3HeroField`, shared by
  parenting and TTC. `phaseNumber` → `variant`, because a parameter named after one
  stage is why the next stage copies the file instead of calling it.

## Content gaps, by owner

**Mine:** BP/glucose log · mood check · mental-health content · belly & skin content ·
the 1–2 week seeding defect in `body_changes.dart`, `trimester_tips.dart`,
`week_articles_data.dart`.

**The user's:** nutrition SKUs · the garbh-sanskar hero course (recorded media) ·
consult supply and real slots · parenting product images.

---

## The TTC audit — seven brackets, forty-nine cells

Source: `parentveda-level-map-checklist.xlsx`, the seven PRECONCEPTION rows.
Legend: **L**ive · **NR** notReady · **NC** notCore · **NA** notApplicable · ⚑ conflict

| Bracket | Content | Activities | Tools | Products | Course | Consult | Extras |
|---|---|---|---|---|---|---|---|
| Fertile window | L | NC | L | L | L | L | NA |
| PCOS | L | NC | L | L | L | L | NA |
| IVF & IUI | L | NC | NR | **NA** | ⚑ NC | L | L |
| Getting ready | L | NR | NR | L | NC | L | NA |
| His side | L | NA | NA | NR | ⚑ L | L | NA |
| After a loss | NR | **NA** | **NA** | **NA** | ⚑ NC | L | L |
| Mind & body | L | L | NC | NC | NR | NC | NA |

**Resolvers behind the live cells** — every one is a screen that already ships:

- Cycle spine → `ttc_cycle_screens.dart` (cycle · ovulation · fertile window) ·
  `ttc_calendar_screen.dart`
- Content → `ttc_chapter_data.dart` (563 lines) · `ttc_can_i_data.dart` ·
  `ttc_treatment_screen.dart` · `ttc_partner_data.dart`
- Body → `ttc_nutrition_screen.dart` · `ttc_supplements_screen.dart` ·
  `ttc_tests_data.dart`
- Paid → `ttc_prepare_data.dart`, **13 offerings**
- Extras → `ttc_records_screen.dart` (report explainer) · `ttc_community_screen.dart`
  (peer support circle)

**Gaps the workbook names and we do not have:** a PCOS symptom checker · a "see a
specialist?" readiness checklist · a pre-pregnancy checklist and BMI · light
habit-building · after-loss content · male-fertility supplements · **a FREE
preconception garbh sanskar** (the paid eight-class yoga pack is not it, and marking it
live would let a door promise free and open a price).

## The clinical rules the TTC hero had to obey

Worth restating, because the obvious big numbers are all forbidden:

- **Never a personalised probability** — no "your chance this month".
- **Never a countdown to an outcome** — `nextUp` names a *trigger*, not a date.
- **No denominator across the stage** — chapters recur every cycle, so "Chapter 2 of 5"
  draws a finish line across something that loops. Parenting says "PHASE 1 OF 20"; TTC
  must not.
- **We may not always compute at all** — when a clinic owns the timing the card defers
  instead of estimating.

So the big fact is **day in this chapter** — true on a clinic cycle, true with no
history, never a prediction — and with nothing logged the hero shows the invitation
rather than a zero.


---

## Skilling — UI only, and built to stay that way

**Reached from Explore → "Skilling (preview)", behind `kDebugMode`**, beside the Brand
Studio debug row that set the precedent. Not on the pregnancy home beside the TTC and
Parenting gateways: those are stages, this is a mock-up, and the difference has to be
visible in where it is reachable from.

**Eighty-four cells, not one of them `live`** — and `test/bracket_model_test.dart` now
asserts that. The other three stages had content waiting before their doors existed
(TTC's grid mostly *wired* screens that already shipped). Skilling has no content file,
no tool, no course, no expert, no screen.

**So the doors do not open bracket screens.** A bracket screen with zero live layers
renders a header and nothing; twelve doors onto twelve empty rooms is worse than no
doors. Tapping a door opens a sheet showing **the workbook's plan for that bracket,
layer by layer, in its own words** — which is what makes the preview reviewable.

### The hero could not be the compass

The workbook's L3 spine here is the **child capability profile — "the compass"**. Every
other stage's hero shows a position on its spine, so symmetry says show one here.

It cannot, and not because the data is missing — **the obvious rendering is banned.**
"Where the child stands across twelve skills" as filled arcs, a radar chart or bars **is
a score for a child.** Development already refused a progress bar for this, and its door
mark had to be redrawn from a bar chart to stepping stones.

So the compass is drawn **unfilled**: twelve points, evenly spaced, none emphasised, no
polygon. The big number in the hero is a **count of skills**, not a measurement. What
stays honest once data exists is marking which skills have been *practised* — never how
well. **That is a product decision, flagged not taken.**

### Two conflicts, on screen, unresolved

Both are rendered as cards in the preview so they are decided rather than forgotten:

1. **Who does this stage talk to?** The workbook header says skilling *"speaks to the
   child"*; every other stage says *"speaks to the parent"*, and so does every
   disclaimer, consent screen and safety line in the app. That is a product decision,
   not a change of tone — it moves consent and data handling at once. **The shell is
   written to the parent** until it is made.
2. **Do we score children here?** The workbook asks for challenges, streaks,
   certificates and progress reports on nearly every bracket's Extras. The product
   refuses to score a child anywhere else. Ten Extras cells carry the workbook's words
   and sit `notReady`, so neither answer is pre-empted.

### Notes

- **Twelve new marks**, not reuse. TTC took all seven of its marks from the existing set
  because each was the same idea in a third stage; skilling shares nothing — there is no
  mark that means "mental arithmetic". Two failed offline and were redrawn: the abacus
  came out as **the settings-sliders glyph** (three rails, one knob each), and focus came
  out as **a dial**. Marks are `SkillMark`, a third slot on `V2Block`, not more cases in
  `BracketMark` — folding them in would make a 29-case switch serving four stages that
  each use a disjoint third.
- **Hindi is Devanagari here**, unlike TTC. TTC is Hinglish because its whole shell is;
  skilling has no legacy to be consistent with, so it starts where the house style is
  going.
- `LifeStage.skilling` exists but **is not selectable** — nothing sets it, the splash
  never routes to it, `JourneyState` infers nothing from it (default-deny), and
  `landing_focus` gives it no focus of its own.


---

## The eyebrow is the door — spine gateways and hero chrome

`lib/screens/v2/v3_hero_chrome.dart`, shared by all three stage homes.

### The spine gateway

None of the three V3 homes could reach its stage's spine — the weekly stack, the phase
map, the chapter journey. Both obvious fixes were wrong:

- **A button in the hero.** The hero already carries exactly one forward line. A second
  invitation beside it makes the reader choose, and the usual result is neither.
- **A row below the fold.** The spine is the stage's backbone; a link to it under the
  fold says it is a feature among features.

**The answer was already on the screen.** The eyebrow states her position on the spine —
"PHASE 1 OF 20", "WEEK 40 · DAY 7" — and *1 of 20 already implies nineteen others*. The
information IS the invitation; it only needed to look like the control it should have
been. So the eyebrow became an outlined chip with a chevron: no new element, no second
CTA, no extra height, same place on all three stages.

| Stage | Chip label | Opens |
|---|---|---|
| Pregnancy | `WEEK 40 · DAY 7` | the weekly snapshot |
| Parenting | `PHASE 1 OF 20 · 0–4 WEEKS` | `PhaseMapScreen` |
| TTC | the chapter name (**no denominator** — chapters recur) | `TtcJourneyMapScreen` |

⚠️ **On pregnancy this made an invisible feature visible rather than adding one.** The
hero photograph was ALREADY wired through to the weekly stack — the whole 302px image was
one hit target with no affordance at all. Perfectly wired, perfectly invisible, and it
survived every review because nothing was *missing*, only unfindable. The photograph
stays tappable; the chip just admits the route exists.

### Hero chrome

Pregnancy had a bookmark and an avatar in its hero; **parenting and TTC had none** — no
way to reach saved or profile from their homes at all. Three stage homes disagreeing
about whether an account exists reads as an app that is half-finished, because it was.

`V3HeroChrome` is now the shared widget, and pregnancy's local `_HeroIcon` / `_Avatar`
are commented out beneath it (kept for revert — they are the originals it was derived
from). Callbacks are **nullable, and null hides the button**: a stage with nowhere to
send her shows no bookmark, because a greyed icon still reads as a feature and one that
never responds reads as broken. TTC has no saved hub, so its bookmark opens the chapter
reader, where saving actually happens.

**Two tones, not a colour parameter** — `onPhoto` (white on pregnancy's dark image) and
`onField` (ink on the pale gradient). A caller that can pass any colour eventually passes
the wrong one, which is exactly how the section eyebrow shipped grey on TTC and purple on
parenting.

---

## Scans & tests — the first bracket to graduate

`docs/SCANS-BRACKET-FLOW.md` (why) · `docs/SCANS-FLOW-SCREENS.md` (what) · built.

**New files:** `data/scan_extras.dart` · `screens/brackets/scans_hub_screen.dart` ·
`scan_schedule_screen.dart` · `scan_detail_screen.dart` · `scan_urgent_screen.dart` ·
`test/scans_hub_test.dart`. Routed from `home_v3_screen._openBracket` on
`kScansBracketId`; every other bracket still opens `BracketScreen`.

**The layers moved rather than disappeared.** Content → the library door *and* every scan
page. Tools → the smart card and the quiet foot rows. Extras → **its own door**. Consult →
**no section**, it appears after a scan page and after a decoder term.

**Products stays refused and the test proves it** — including that no `₹` appears anywhere
on the urgent path.

**Still owed:** the ₹ ranges in `scan_extras.dart` are researched public figures and
**need review before launch** — a wrong number is worse than none, because she will quote
it at a counter.
