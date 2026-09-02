# Building a TTC door — the playbook

**Read this before touching a bracket.** It exists because five doors are being
rebuilt in parallel, in separate sessions, and the failure mode of parallel work
is not conflicts — it is five people quietly inventing five different versions of
the same decision.

Everything here was settled while rebuilding **Conceiving** and **PCOS**. Neither
is a suggestion.

---

## 0. Before you write anything

**List what already exists for this bracket and say what it is wired to.**

This is not politeness, it is the step that cost the most time when it was
skipped. Rebuilding PCOS, a 20-question PCOS checker was discovered *mid-build* —
2,738 lines, already shipped, with its store read by five other surfaces (the BMI
screen, precheck rules, fertility-help, Tools and a journey). A brief that calls
a tool "NEW" is describing what the author wants, not what the repo has.

So, first:

```
grep -rln "<bracket keyword>" lib/ --include=*.dart
grep -rn "<TheStoreYouFound>" lib/ --include=*.dart | grep -v <its own file>
```

Then report: what exists, who reads it, and whether the brief is asking you to
extend it or replace it. **If replacing it would strand a downstream reader, say
so and ask** — the answer on PCOS was "new front, same store", and it may well be
the answer again.

---

## 1. The structure is one scrolling page. Always.

A door is a `TtcFocusPage`: an intro, a hero video slot, and a list of
`TtcFocusSection`s, each with a heading and a horizontal rail of tiles. That is
it. Rendered by `TtcFocusScreen`, which you do not need to modify.

**Do not build sub-tabs**, even when a brief specifies them. Both briefs so far
asked for a tab bar inside the focus area and both were overruled for the same
reason: a tab is a decision she has to make *before she is allowed to see
anything*, on a subject where most people arriving do not yet know which tab
their question belongs to. Tab names become **section headings**, which is where
they were doing their real work anyway.

> ⚠️ **AMENDED 2026-09-02, FOR PCOS ONLY.** The PCOS door now opens on a
> photograph and a **horizontal rail of five selector cards**, and shows one
> group at a time. Asked for directly, after Flo.
>
> This is not the tab bar the rule forbids, and the distinction is the whole
> point of keeping both sentences. A tab bar lights one word, hides four, and
> tells you nothing about what is behind them — you choose blind, which is what
> the objection above is actually about. The selector is a rail of picture cards
> in the same language as every other rail on the page, sitting first under the
> hero: she reads all five, then picks. The choice is made *after* seeing the
> options.
>
> **The rule still stands for a tab bar, and still stands for the other four
> doors.** PCOS is being checked on a device first. Do not roll this out, and do
> not revert it — `test/ttc_focus_groups_test.dart` asserts both halves.
>
> Mechanically: `TtcFocusGroup` on the page, `group:` on each section, and
> `TtcFocusGroup.toolSurfaceId` for a group that renders a tool inline instead
> of a rail of tiles. A page with `groups: null` renders exactly as before.

**Do not build an intermediate menu.** The conceiving door used to open a
three-card chooser; it was removed. A door opens onto content.

**Sections are plain questions where they can be** — "When should we have sex?",
"Is it PCOS, or something else?" — not taxonomy. And **the format never becomes a
heading**: no "Videos" section, no "Articles" group. The format is a chip on the
tile, because she chooses a question and then wants to know whether the answer is
thirty seconds of reading or a four-minute film.

---

## 2. Where your files go

The reads and focus data were split per bracket **specifically so that doors can
be built at once**. Stay inside your own files.

| What | Where |
|---|---|
| Your articles | `lib/ttc/reads/ttc_reads_<door>.dart` |
| Your focus page | `lib/ttc/focus/ttc_focus_<door>.dart` |
| New tool logic | `lib/ttc/ttc_<door>_<tool>.dart` |
| New tool screens | `lib/screens/ttc/ttc_<door>_<tool>_screen.dart` |
| Your tests | `test/ttc_<door>_*.dart` |

**Shared, and the only lines you may touch in them:**

- `lib/ttc/ttc_reads_data.dart` — one `import`, one `...kTtcReads<Door>,`
- `lib/ttc/ttc_focus_data.dart` — one `import`, one entry in `kTtcFocusPages`
- `lib/screens/ttc/ttc_surface_router.dart` — one `case` if you add a tool
- `lib/ttc/ttc_products_data.dart` — append only, if your door needs a product

Everything else is off limits. If you think you need to change
`ttc_focus_screen.dart`, `pv_reader_screen.dart`, `ttc_home_v3.dart` or
`ttc_common.dart`, **stop and say so** — those are shared with four other
sessions and a change there is a change to everyone's door.

`test/ttc_focus_page_test.dart` already iterates `kTtcFocusPages`, so your page
inherits every reachability gate the moment you register it. You do not edit it.

---

## 3. The wiring gate — every tile must open something real

This repo's repeated failure is correct-but-unreachable code, and a content page
is the worst place for it: a tile is a title, a blurb and a chip, and **none of
that fails to render if the id underneath it is wrong.** Two dead ids shipped in
the PCOS draft before the test caught them.

Before you call a page done:

- **`TtcArticleTile.readId`** must exist in `kTtcReads`. It is required on the
  model precisely so an article tile cannot exist without content.
- **`TtcToolTile.surfaceId`** must resolve in `ttcScreenForSurface`. A surface id
  the router does not know returns null and the tile does nothing, silently.
- **`TtcProductTile.productId`** must exist in `ttcProducts`.
- **`TtcMasterclassTile.offeringId`** must exist in `ttcOfferingById` *and cost
  money* — a "paid" tile pointing at a free item is a worse lie than the reverse.
- **`TtcBookingTile.action`** is `kTtcActConsult`. Not a new booking flow.
- **Video slots do not need a catalogue entry.** `PvVideoPlaceholder` renders
  real 16:9 geometry, a real title and an honest "coming soon", and is not
  tappable. Pass `flat: true` at the head of a page — the diagonal gradient
  belongs on a hub, not on the largest object on a page.

---

## 4. Articles

Written into your `reads/` file, to `PvRead`. `assertShape()` enforces the floor
and `test/pv_read_shape_test.dart` runs it over every read:

- **≥ 4 sections**, **≥ 3 headings**, **≥ 1 FAQ**
- **≥ 600 words** — this counts *section paragraphs only*, not the teaser, the
  scale-setter, callouts or FAQs. **Aim for 700.** Every article written so far
  landed at 515–591 on the first pass and needed a real paragraph added.
- **`evidence` is required** — named sources, never "studies show"
- **`whenToSeeSomeone` must carry `PvCalloutTone.urgent`**
- No more than half the sections may fold

When you come up short, **add substance, not padding**. The five paragraphs added
to hit the floor were all things the article was worse for missing.

---

## 5. Clinical rules that do not relax

From CLAUDE.md, enforced by `test/ttc_clinical_review_test.dart`, which **scans
source text including comments**:

- **Never a personalised probability.** No number attached to her. Population
  statistics stay allowed where they reduce pressure rather than set a target.
  The brief's "Your realistic odds with PCOS" was renamed to "Conceiving with
  PCOS, realistically" for exactly this reason — a possessive plus a probability
  word is the banned construction.
- **Never a diagnosis.** Symptoms are "can have many causes", never stated as a
  condition. Every path ends at a doctor.
- **Never contradict her clinician.** Where a doctor owns a decision we explain
  it, remind about it or help her prepare for it — we do not recreate it.
- **No weight numbers, targets or plans** anywhere in a self-assessment flow.

⚠️ **Do not spell a banned phrase out as a counter-example, even in a comment
saying never to write it.** The scanner cannot tell a prohibition from an
instance, which is correct — a phrase sitting in a file is one copy-paste from
being a string. This tripped the suite twice in one session. Describe the shape;
do not assemble the words.

---

## 6. Tools get the V3 treatment. This is not optional.

**Standing instruction: when you wire a tool into a door, enhance it.** Not just
reachable — brought up to the design language, and made legible enough that
someone understands what it is for before they tap it.

`lib/screens/ttc/ttc_pcos_stand_screen.dart` is the reference implementation.
Copy its shape:

**Chrome**
- `V3HeroField(accent: v2BlockTint(<door hue>, p), ground: p.ground, variant: n)`
  as a `Positioned.fill` behind everything
- a `_Sheet` — `p.ground`, 28pt top radius, upward shadow — sliding over it
- a round translucent close button, top-left, not an `AppBar`
- hero: small letterspaced eyebrow, then a Fraunces line at ~26pt, then one
  Manrope sentence saying what this is and is not

**Inside**
- white cards with a **hairline, not a shadow** — eight stacked shadows on one
  scroll is a page that looks like it is hovering
- tinted round index chips on repeated items, so a long scroll has a spine
- `v2BlockTint(hue % 360, p)` for every tint. The `% 360` is not defensive
  padding: the function asserts, and a hue from a data file has already tripped
  it once
- drawn `CustomPainter` marks, not Material icons, for anything decorative — see
  `ttc_symptom_mark.dart` and `ttc_mood_face.dart`. Scale stroke width off the
  box and floor it at ~1.1
- purple is the interactive colour and marks **one** thing worth touching. Coral
  is the period marker and belongs to nothing else

**Comprehension — the part that is actually being asked for**
- say what the tool is for, and what it will not do, *before* the first input
- show what the app already knows from her logs, so it does not ask twice and so
  the screen does not feel like starting from nothing
- progress as a **filling hairline, not "3 of 8"** — a counter on a health
  questionnaire is a debt statement
- every input optional, and the output honest about being thinner as a result
- end on a real action, and label private state clearly ("stays on your phone,
  not a medical record")

**Do not** copy a competitor's verdict, score, match percentage or dial. If the
tool reads her data back, that is the whole product.

---

## 7. Layout traps that have already cost time

- **`CrossAxisAlignment.stretch` on a `Row` inside a `ListView` crashes** —
  `BoxConstraints forces an infinite height`. Use `IntrinsicHeight` when children
  genuinely must match, or fixed-height children and default alignment.
- **`Spacer` needs a bounded box.** It cannot live in a column that sizes to its
  children.
- **Test at 360pt, never 1200.** Every overflow this stage has shipped was found
  at phone width or not at all. Widget tests also render with a fallback font far
  wider than Manrope, which is a feature here — it surfaces missing `Flexible`.
- **A number scales down (`FittedBox`), a label ellipsises.** "36.6…" is not a
  smaller reading, it is a wrong one.
- **Rail arithmetic includes both gaps.** `gutter + card + gap + card + gap` is
  what decides how much of the third card shows; leaving out the second gap left
  4pt visible and read as a clipping bug. See `test/ttc_rail_peek_test.dart`.
- **Never cache "today".** Read it once into state and refresh on
  `AppLifecycleState.resumed`. A screen that reads the clock in one place and
  caches it in another disagrees with itself, and only ever after midnight.

---

## 8. Finishing

- `flutter analyze` clean of **new** issues (there is a standing baseline of
  pre-existing ones — count before you start)
- full suite green
- **do not run git.** Provide the commands with explicit file paths; the user
  runs them. No `Co-Authored-By`.
- **do not build or install.** The user says when.
- Report: files changed, what was reused vs newly written, and **every tile that
  has no content behind it yet** — named, not summarised.
