# Male fertility door — rename + one gap (planned 2026-10-29)

**Status: PLANNED, decisions taken 2026-10-29, not built.** The TTC door
`ttc_male_fertility`, shown today as **"His side"**, becomes **"Male
fertility"**. It gains one new article for the largest uncovered question
cluster, and one existing article gets a short section on abstinence and
frequency.

## Out of scope, said plainly

- **No new door.** The door exists (`lib/ttc/focus/ttc_focus_his_side.dart`)
  and is already reachable for both partners (see "Where it is reached
  from"). This is a rename plus content.
- **Article prose keeps "his".** About 30 sentences say "his side" as ordinary
  English ("check his side early"). They stay. So do the code identifiers
  (`kTtcHisSideFocus`, `ttc_reads_his_side.dart`, image keys `his_side`):
  identity, not display.
- **No change to the Ask Veda service.** Only a corpus re-export and a
  re-ingest (the user runs it). The wire body is untouched.
- **Matching reads to doors by id instead of by kicker string** is the real
  fix for the coupling described below. It is a refactor across four call
  sites and is not part of this change. Recorded in STILL-OPEN when built.
- **Vasectomy reversal** (4 hits, already mentioned 3 times): no new piece.

## Decision record

| # | Question | Recommended | User's call (2026-10-29) |
|---|---|---|---|
| 1 | Rename scope | Every place the door is *named*; article prose keeps "his"; ids unchanged | Recommended |
| 2 | Build gap 1, "what are our options when it's on his side"? | Yes, one new read in Test and results | Recommended |
| 3 | Abstinence / how often / morning counts | A short section + FAQ in an existing read, not a new tile | Recommended |
| 4 | Hindi label (`'Unki taraf'`, Latin-script Hinglish) | Set `hi` to the same as `title.hi`, `'Male fertility'`; no translation | Chosen with 1 (not a separate ask: it is a defect, not a choice) |
| 5 | Tab "Understand his side", heading "How much does his side matter?", read "Why his side gets tested last" | Keep: these say *his*, they do not name the door, and pair with "Improve his health" | Chosen with 1 |

## Where it is reached from (checked 2026-10-29)

| Her | Him (partner view) |
|---|---|
| Home door grid, in `ttcHomeDoorOrderNow` order (`ttc_home_v3.dart:422`) | Same grid, his door first (`ttcHisDoorsFirst`, `ttc_partner_home.dart:598`) |
| Learn topics; stage search; door search | Learn, first (`kTtcHisLearnFirst`) |
| Getting ready's "More in His side" tile (`ttc_focus_conceiving.dart:817`) | Onboarding "health" answer (`kTtcHelpDoor`) |
| Fertile window, IVF and Getting ready reuse its reads by id | His door card (`ttc_partner_screen.dart:1373`) |

Nothing is hidden from either of them. The problem was the name: "His side"
reads as *his half of the app*, and the codebase itself uses the phrase that
way (~60 comments about the partner view).

## Step 1 — the rename

### ⚠️ The coupling that makes this more than a label change

A read belongs to a door because `read.kicker.en == bracket.label.en`. That
string match runs in four places: `ttc_learn_screen.dart:193/285/293`
(Learn shelves, marks, hues), `ttc_all_videos_screen.dart:121`,
`ttc_home_v3.dart:7280/7375`. Rename the label without the kickers and the
door's Learn shelf **silently empties**. It still compiles and nothing
crashes, so the label and all 12 kickers move in one commit, and a test pins
them together.

*The general lesson:* joining two records by a display string makes every
copy edit a schema migration. Ids are for joining, words are for people.

### Every place it changes

| File | Now | After |
|---|---|---|
| `lib/data/brackets/ttc_brackets.dart:226` | `label: _t(en: 'His side', hi: 'Unki taraf')` | `en: 'Male fertility', hi: 'Male fertility'` (old line commented, kept for revert) |
| `lib/ttc/reads/ttc_reads_his_side.dart` (10 kickers) | `kicker: _en('His side')` | `kicker: _en('Male fertility')` |
| `lib/ttc/reads/ttc_reads_extra.dart:44, 292` (2 kickers) | same | same |
| `lib/screens/ttc/ttc_partner_screen.dart:1373` | `'His side'` | `'Male fertility'` |
| `lib/screens/ttc/ttc_semen_report_screen.dart:253` | eyebrow `'His side'` | `'Male fertility'` |
| `lib/ttc/focus/ttc_focus_conceiving.dart:817` | `'More in His side'` | `'More in Male fertility'`; tile id unchanged |
| `lib/data/hubs/ttc_hubs.dart:302` | `'His side of it, in four minutes'` | `'Male fertility, in four minutes'` |
| `lib/ttc/focus/ttc_focus_his_side.dart` | heroTitle `'His side of trying, in plain words.'` | `'Male fertility, in plain words.'`; file header line updated |
| `test/ttc_focus_page_test.dart`, `test/ttc_his_side_test.dart` | assert `'His side'` | updated |

**Fits:** "Male fertility" is 14 characters in two words, so it wraps cleanly
in the 4-column grid ((memory: names-never-cut-off)).

**New test:** every read in `kTtcReadsHisSide` has a kicker equal to the
`ttc_male_fertility` bracket's label, and the door's Learn shelf is non-empty.

**Ask Veda:** `tool/export_ttc_corpus.dart:372` sends the kicker as a
keyword, so re-export the TTC corpus and re-ingest (the user). No service
code changes.

## Step 2 — new read: the options when it's on his side

**Demand:** about 15 clusters in `research/questions/ranked_ttc.csv`, long
tail but high intent. Examples: "how to get pregnant low sperm count", "does
IUI work for low sperm count", "does sperm count increase after varicocele
surgery", "what if sperm count is 1 million", "how IVF works for men", "how
much does male fertility treatment cost", "how to check male fertility
doctor". Today varicocele, ICSI and donor sperm appear only in passing, and
**sperm retrieval (TESA/PESA/micro-TESE) is mentioned nowhere.**

- **Id** `ttc_read_his_options`, kicker `Male fertility`, hue 186, in
  `kTtcReadsHisSide`. Author "ParentVeda team", `reviewed: false`
  ((memory: ttc-fake-reviewers)).
- **Tile** in Test and results, after "If no sperm is found". Working title:
  **"If it's his side: the options"**. Situational, not a question
  ((memory: doors-are-guides-not-faqs)).
- **Sections (draft):**
  1. Most male-factor results have a next step, and many don't need IVF.
  2. Finding a cause first: andrologist, examination, hormones (points to the
     existing azoospermia read for the full workup, not a copy).
  3. Things that can be fixed: varicocele repair (who it helps, the 3–6
     month wait for numbers to move), stopping a medicine
     (testosterone/steroids, already covered: link, not repeat), treating an
     infection.
  4. Matching treatment to numbers: IUI for mild problems, IVF with ICSI
     when counts or motility are low. Population ranges only, **never "your
     chance"** (`test/ttc_clinical_review_test.dart` scans for it).
  5. When no sperm is in the sample: surgical retrieval (PESA/TESA,
     micro-TESE) then ICSI, in plain words.
  6. Donor sperm, said calmly, as a choice couples make. Not a last resort.
  7. What it costs in India: ranges in INR, consistent with the figures
     `ttc_reads_ivf.dart` already uses (no second set of numbers).
  8. Who decides: the clinic. We explain, he and she prepare
     (clinical ownership).
- **FAQs** (each one becomes its own Ask Veda chunk): "Can we get pregnant with
  a low count?", "Does IUI work for low sperm count?", "Does varicocele
  surgery help?", "What does male fertility treatment cost?"
- **No repetition** with the IVF door: link to its ICSI/IVF reads by id;
  `test/ttc_doors_no_repetition_test.dart` must stay green.
- **Image:** `read_images.dart` needs a key and a credit. Picked by eye
  ((memory: store-category-tiles-images)); if none fits on the day, list it in
  `docs/DOOR-CONTENT-OWED.md`.
- Sources at the end: WHO 2021 manual, NICE CG156, ICMR ART guidance, EAU
  male infertility guidelines.

## Step 3 — abstinence and frequency, inside an existing read

**Demand:** about 25 hits ("does sperm count increase with abstinence", "why
is sperm count higher in the morning", "does sperm count decrease after first
ejaculation", "is it normal for sperm count to fluctuate").

Goes into `ttc_read_heat_habits` ("Heat, habits and time: what changes
sperm"): one section, **"Does saving it up help?"** (short abstinence raises
count a little but older sperm move less; every one to two days in the
fertile window is the usual advice; morning vs evening barely matters), plus
one FAQ. It points at the Getting ready door's timing read rather than
restating it. No new tile.

## Wiring gate (before "done")

- Grep: the new tile's `readId` resolves in `kTtcReads`; the tile shows on the
  door; the read is in the export.
- Learn shelf for `ttc_male_fertility` non-empty (new test).
- `flutter analyze` scoped to the touched files; TTC tests only
  ((memory: stage-tests-only)).

## Afterwards (the user)

- Re-export the TTC corpus and re-ingest Ask Veda.
- Phone walk: her home grid, his home grid, Learn, search, Getting ready tile.

## As built

*(written during the build)*
