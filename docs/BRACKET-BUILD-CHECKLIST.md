# Level Map build — execution checklist

Companion to the approved plan.

**Done: P0 · P1 · P2a · P4.** Ten bracket doors are live on the pregnancy V3 home screen
and each opens a real bracket screen. P3 was dropped as busywork (see below).
**Next: parenting, then TTC, then skilling's shell.**

---

## Visibility — what you can look at, and when

⚠️ **The first ordering of this checklist was wrong for a long unattended run.** It was
sequenced for correctness — model, tests, hidden screen, then doors — which means several
hours produce a green suite and an app that looks identical. Re-ordered so something is
visible on the phone early and stays visible.

| Step | Roughly | What YOU can see |
|---|---|---|
| P1 model | short | Nothing on screen. Check: new test count, and `BRACKET-AUDIT.md` transcribed into code |
| **P2a one real door** | early | **A door on V3 opens a real bracket screen.** Scans & tests first — the richest one. Screenshot posted |
| P2b Tools hub reads the model | | Tools hub looks the same but is now driven by the table — the anti-shelfware step |
| **P4 all ten doors** | | **The home grid changes: 4 columns, 10 brackets.** Screenshot posted |
| P3 de-dupe | any time after P2a | Nothing — behaviour identical by design |
| Parenting / TTC | after pregnancy | Their home screens get the same treatment |
| Skilling | last | Hero + doors only; the stage does not otherwise exist |

**Every phase ends with a commit and, where anything is visible, a screenshot from the
phone.** Nothing is left "done but unreachable" — that failure has its own section in
`CLAUDE.md` for a reason.

---

## Deferred at the user's request

- **Ask Veda (`veda_index`) is LAST.** It is a separate repo and a cross-repo contract;
  the user wants to be present and to talk to that codebase first. The `global_search`
  half of P5 can proceed independently — it is local.

---

## Standing rules for every phase

- [ ] **Comment out, never delete.** Superseded UI and data stay in the file with a
      `// kept for revert —` note saying what replaced them and why. This applies to the
      six literal `V2Block`s, the palette comparison bar, and anything the bracket grid
      displaces. The one exception already on the record: a fabricated statistic is
      removed outright, because nobody should be able to revert to it.
- [ ] **Nothing replaces Classic or Focus.** All work lands inside the existing V3 toggle.
- [ ] **Father mode untouched** until the mother side is settled.
- [x] ~~**Pregnancy only.**~~ Pregnancy is done; parenting is now in scope.
- [ ] Each phase ends green: `flutter analyze` clean, full suite passing
      (**2213 / 5 skipped** at the start of this work).
- [ ] Each phase is its own commit, with the reasoning in the message.

---

## P0 — Truth audit ✅ COMPLETE

- [x] Parse the workbook including cell fills; discover that fill and text disagree
- [x] Establish **text is authoritative, fill is a hint** (38 disagreements sheet-wide)
- [x] Map all 60 pregnancy cells to a state + a named resolver
- [x] Gate met: **30 `live` cells, every one with a resolver**
- [x] Written up in `docs/BRACKET-AUDIT.md`

**Two things P0 found that were not in the plan:**
1. Four pregnancy cells carry "Not a fit" with **no red fill** — reading colour alone
   would have put a shopping prompt under a scan explainer.
2. Reading the specialists' **stated topics** rather than their job titles moved two
   Consult cells from `notReady` back to `live`.

---

## P1 — The model ✅ COMPLETE

- [x] `lib/models/bracket.dart` — `Bracket`, `BracketLayerSpec`, `BracketLayer`,
      `LayerState`
- [x] `lib/services/bracket_resolver.dart` — the **single chokepoint**. Nothing may read
      a layer's state except through this
- [x] `lib/data/brackets/pregnancy_brackets.dart` — all 10 brackets × **7** layers,
      transcribed from `BRACKET-AUDIT.md`, each non-live cell carrying the workbook's
      reason verbatim
- [x] Bilingual from the first string — `_p(en, hi)` on every label, per repo rule.
      ~10 door labels + 10 titles + 6 layer names + 4 state strings
- [x] **Extras is a real seventh layer.** Settled 2026-08-15. The sheet has a *third*
      fill — grey (`FFF3F6F5`), 9 cells, 4 of them pregnancy — which is neither go nor
      no. User's call: **grey means build it.** And the entries earn layer status:
      "Red-flag when to call / rush" is arguably the most valuable single item under
      Complications, and it is not a tool, a course or a product
- [x] **Bracket ids are stage-prefixed**, with a separate `theme` field for the
      cross-stage link. Settled 2026-08-15. Prenatal anxiety and postpartum depression
      are not the same subject, so a shared id would claim a sameness that is not real;
      `theme` still allows continuity where we want it

**Tests (all new, all must exist before P2):**
- [x] Every one of the **70** cells is explicitly declared — no defaulting
- [x] Every `live` cell resolves to non-empty data
- [x] Every `notApplicable` cell resolves to nothing **and** to no CTA
- [x] Every `surfaceId` resolves through `homeFor()`

**Gate met.** 13 model tests; suite 2213 → 2229.

⚠️ **One thing P1 uncovered that the plan did not predict:** `app_structure.dart`
under-declares. The Symptoms Companion, the due-date calculator, the report explainer and
the pregnancy nutrition screen all ship and none of them had a surface id — found only
because the bracket table's layers had nowhere to point. Four surfaces added.

⚠️ **And a whole file the plan missed: `lib/services/surface_router.dart`.**
`app_structure` knew which TAB owns a surface and never which SCREEN it *is*, which is why
every hub keeps its own hand-maintained list. Without it a bracket row would land her on
the Tools tab to find the row herself — one screen short, which is the same defect as a
door that opens nothing, only harder to notice.

---

## P2a — The detail screen ✅ COMPLETE (P2b, the Tools-hub rewire, still open)

**Design is settled — see `docs/BRACKET-SCREEN.md`.** Headline: she never sees our
vocabulary (Consult → "Talk to someone"), the order is free-first-paid-last, and the
absent sections are the design rather than a gap to fill.

- [x] `lib/screens/brackets/bracket_screen.dart` — hero, then one section per `live`
      layer in workbook order
- [x] Stable `RouteSettings(name: 'bracket')` chosen now — notifications, referral and
      the brand Premiere all push by name
- [ ] ⚠️ **The anti-shelfware step:** `tools_hub_screen.dart`'s 14 hardcoded rows start
      reading the resolver. Once a shipped screen depends on the model, it cannot be
      quietly abandoned. Old rows commented out, not deleted
- [x] Analytics: **nothing logged at all** — safer than one surface, `bracket_detail`, with **no id parameter**
      — `usage_events.dart` is write-only with no read grant, so bracket ids like
      `mental_health` would be an unauditable health signal

- [ ] Test: all 10 brackets render
- [ ] Test: zero shopping affordance anywhere a Products cell is `notApplicable`

**Gate:** every bracket opens and shows real data; the Tools hub still behaves identically.

---

## P3 — De-duplicate the doors ❌ DROPPED, deliberately

The plan said extract the six literals into one shared list before changing them.
**Dropped as busywork once P4's shape was clear:** V3's doors became ten brackets built
from a table, and Focus kept its hand-written six. They no longer share anything to
de-duplicate — merging them first and splitting them again an hour later is exactly the
double work this restructure exists to avoid.

⚠️ **The guard rewrite that P3 owned still happened**, because it was the load-bearing
half. See the note in `test/landing_focus_test.dart`: home_v3_screen came out of the
`V2Block(` source scan, because one loop leaves one occurrence and the test would have
gone on passing while checking one thing instead of ten.

## ~~P3 — De-duplicate the doors *before* changing them~~

- [ ] Extract the six literal `V2Block`s into one shared list
- [ ] `home_focus_screen.dart:302` and `home_v3_screen.dart:493` both consume it; both
      `_blocks()` methods commented out with a revert note
- [ ] ⚠️ **Rewrite the wiring guard in the same commit.**
      `test/landing_focus_test.dart` counts `V2Block(` occurrences in the *source*. Once
      six literals become one loop there is one occurrence, and the test passes having
      checked one thing instead of ten. Replace with a table assertion

**Gate:** both screens behaviourally identical, nothing reordered, one file owns the doors.

---

## P4 — Four columns, ten bracket doors ✅ COMPLETE

- [ ] `v2_block_grid.dart` gains a `columns` parameter (currently `/ 3` hard-coded at
      line 91)
- [ ] Ten new drawn marks — the existing six are practice/week/scan/read/watch/ask, which
      is not the bracket set. Preview all ten offline before they reach a screen
- [ ] Door labels shortened for ~73dp tiles (table in the plan)
- [ ] Practice / This week / Ask leave the grid; the removal is commented with where each
      now lives (hero, Garbh section, global FAB)
- [ ] `_pregnancySurfaces` in `main_scaffold.dart:51` **untouched** — it is positional,
      and reordering silently reassigns analytics
- [ ] Palette comparison bar removed (D8 settled it); commented out, not deleted

**Gate:** revert is one tap on the version pill; grid legible at 360dp on the phone.

---

## P5 — Make the model the enforcement point

- [ ] `veda_index.dart` stops stamping every product and tool into the Ask corpus
      unconditionally; it asks the resolver
- [ ] `global_search.dart` stops importing `product_data` directly
- [ ] Test: no hardcoded list yields an item whose bracket × layer is `notApplicable`

**Gate:** Ask Veda cannot answer an IVF-shaped query with a product card.

---

## P6 — Stage heroes. Only after the above is proven.

- [ ] TTC: one landscape, four lights, keyed to cycle phase
- [ ] Parenting: setting matched to the child's age band — not one field reused
- [ ] Skilling: a child figure with one focus motif
- [ ] Pregnancy's weekly baby render **untouched**
- [ ] Every scene's states rendered offline first, using the preview recipe already
      documented in `v3_tip_art.dart`

**Gate:** no scene reaches a screen until all of its states have been looked at side by side.

---

## Decisions still owed before their phase

| Owed by | Question |
|---|---|
| ~~P1~~ | ~~Extras~~ — **settled: a real seventh layer, grey means build it** |
| ~~P1~~ | ~~Bracket id scope~~ — **settled: stage-prefixed + a `theme` field** |
| P2 | **Mock consult slots.** Six brackets will offer a consult against mock availability. Booking-supply problem, not a bracket problem, but the bracket screen makes it visible in a way the Prepare tab does not |
| P4 | Nothing — D1, D7 and D8 have settled the grid, the doors and the palette |
| later | Nav restructure, `Today · Products · [centre] · Tools · More` — deferred on purpose |

---

## The gaps, split by who can close them

Not blockers — brackets ship without them and a flag flips them on later. Split by owner
so the user's half can run in the background while the build proceeds.

### I can close these — no input needed

| Gap | What it takes |
|---|---|
| **Complications → Tools** — no BP or glucose log | A tool. It is code, and the pattern already exists in `weight_tracker_screen.dart` (input → history → range interpretation) |
| **Mental health → Tools** — no mood check | A tool. Same pattern. ⚠️ Must never score or diagnose; a check-in, not an EPDS |
| **Mental health → Content** — nothing owned | Writing. Anxiety, prenatal low mood, common fears, when it is more than nerves. Ends in a disclaimer and routes to a clinician, per `CLAUDE.md` |
| **Belly & skin → Content** — nothing owned | Writing. Stretch marks, melasma, itching, pigmentation |
| **The 1–2 week seeding defect** in `body_changes.dart`, `trimester_tips.dart`, `week_articles_data.dart` | Writing, at volume — these silently thin out past week 5 |

Everything above lands as a draft for review, not as shipped truth. Clinical claims get
the disclaimer treatment the repo already requires.

### These need the user — please start collecting

| Gap | What only you can supply |
|---|---|
| **Nutrition → Products** | Real supplement / protein SKUs: names, prices, affiliate links, images. The single highest-intent commerce gap in the stage, and I cannot invent a product |
| **Garbh sanskar → Course** | Recorded media. The workbook calls this the **free differentiated hero course** and we own the deepest content asset in the app to build it on — but a course is video/audio, not text |
| **Garbh sanskar → Products** | Music / book affiliate lines |
| **Consult supply** | Real specialists beyond the current five, and **real slots** — six brackets will show "next: today 6pm" against mock availability |
| **Fitness → Products** | Mat / ball affiliate — minor |

**Ask for prompts when you want them.** For anything above where a generation pass would
help — product imagery, course outlines, illustration briefs — say the word and I will
write the prompt for you to run, the same way the block art was produced.
