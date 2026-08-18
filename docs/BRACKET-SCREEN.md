# The bracket screen — what you see when you open a door

Companion to `BRACKET-AUDIT.md` (what exists) and `BRACKET-BUILD-CHECKLIST.md` (order of
work). This defines **the screen itself**.

---

## The one rule that shapes everything

**She never sees our vocabulary.** *Content · Activities · Tools · Products · Course ·
Consult · Extras* are the workbook's words — a taxonomy for us to build against, not
headings for her to read. A section called "Consult" is a filing cabinet; a section called
**"Talk to someone"** is a door.

Two of these are already shipped and should be reused rather than reinvented — the brand
Premiere page already uses **"WHAT IT ACTUALLY IS"** and **"LEARN THIS PROPERLY"**, and
V3's home uses **"THINGS THAT HELP · PRICES SHOWN"**.

| Layer (ours) | Section heading (hers) |
|---|---|
| Content | **What this actually is** |
| Activities | **What you can do** |
| Tools | **What you can track** |
| Extras | *names itself* — "When to call someone", "Understand your report" |
| Products | **Things that help** · PRICES SHOWN |
| Course | **Learn this properly** |
| Consult | **Talk to someone** |

## The order, and why it is not negotiable

Workbook order, which happens to be **free first, paid last**: understand → do → track →
then, only then, buy / learn / book. That is the wedge (*you always know the price before
the pitch*) expressed as layout rather than as copy. A bracket that opens with a product
is the thing 24.3% of Mylo's critical reviews are about.

---

## Worked example — Scans & tests

The highest-demand bracket, and the one with the most live layers. Everything below
resolves to a file that exists today.

```
 ←                                            ⤓ save

 ┌────┐   SCANS & TESTS
 │mark│   Every scan explained — what it is,
 └────┘   why it is done, and what the result means


 WHAT THIS ACTUALLY IS
 ┌──────────────────────────────────────────┐
 │ Dating scan          6–9 weeks           │
 │ NT scan              11–13 weeks         │
 │ Anomaly scan         18–22 weeks     ▸   │
 │ OGTT                 24–28 weeks         │
 │ Growth scan          30–34 weeks         │
 │                        9 in the library →│
 └──────────────────────────────────────────┘

 WHAT YOU CAN TRACK
 ┌──────────────────────────────────────────┐
 │ ⌗  Your scan schedule                    │
 │    next: anomaly scan, week 20       ▸   │
 ├──────────────────────────────────────────┤
 │ ⌗  Appointments                      ▸   │
 ├──────────────────────────────────────────┤
 │ ⌗  Due date calculator               ▸   │
 └──────────────────────────────────────────┘

 WHEN THE REPORT COMES BACK
 ┌──────────────────────────────────────────┐
 │ Upload it and see what the terms mean.   │
 │ Low-lying placenta, AFI, EFW — in plain  │
 │ words, before you can reach your doctor. │
 │                              [ Open → ]  │
 └──────────────────────────────────────────┘

 TALK TO SOMEONE
 ┌──────────────────────────────────────────┐
 │ ◍  Dr. Ananya Rao                        │
 │    Obstetrician · 15 years               │
 │    "Reading and understanding your scan  │
 │     reports"                             │
 │    from ₹899 · next: today 6pm  [ Book ] │
 └──────────────────────────────────────────┘


 ── and nothing else. ──────────────────────
 No products section. No course section.
 The workbook says Not a fit for both, so the
 screen renders neither — not an empty state,
 not an invitation, nothing at all.
```

### What each block resolves to

| Section | Source |
|---|---|
| What this actually is | `lib/data/tests_scans_reports_data.dart` (9) → `tools/tests_scans_reports_screen.dart` |
| What you can track | `tools/scans_appointments_screen.dart` · `calendar_screen.dart` · `tools/due_date_calculator_screen.dart` |
| When the report comes back | `report_findings_data.dart` (~11) → `report_screen.dart` |
| Talk to someone | `kSpecialists[0]` in `prepare_data.dart` |

---

## The absent sections are the design

Scans & tests renders **four** sections. Belly & skin care renders **two** — a
products rail and nothing else, because its content is unwritten and four of its layers
are "Not a fit".

**That unevenness is correct and must not be smoothed over.** The instinct to give every
bracket the same six sections is exactly what produces filler, which the workbook's own
Read Me names as *"the thing that sinks Mylo and iMumz on trust."*

Three distinct absences, one appearance:

- `notApplicable` → nothing. No heading, no empty state, no "coming soon".
- `notReady` → nothing. Same as above; a flag flips it on later.
- `notCore` → nothing **here**, because it lives on another surface. The bracket's blurb
  may mention where.

⚠️ This is the one place the repo's *"a feature is never hidden; empty sections render an
invitation"* rule is deliberately suspended, and it needs a test, because the first
person to see a two-section bracket will want to fill it.

---

## Header treatment

**No photography.** Ten brackets, no shot list, and a stock photo per bracket is the
generic look the whole brief exists to avoid. The header is the bracket's **drawn mark**
— the same language as the doors it was opened from, at a larger size — on its own hue,
with the title and the workbook's one-line Content description underneath.

That also gives continuity: the tile she tapped and the screen she landed on are visibly
the same object, which is the cheapest way to say "you are where you meant to be".

---

## Open, before this is built

- **A "your saved" strip** would be empty for every existing user on day one, because
  Saved has no bracket dimension. Leave it out of v1.
- **Mock consult slots.** Six of ten brackets will show a Talk-to-someone card with a
  "next: today 6pm" that is not real. This screen makes that visible in a way the Prepare
  tab currently does not — it needs a real answer before P2 ships, not after.
- **Deep links.** `RouteSettings(name: 'bracket')` must be chosen before anything pushes
  it, since notifications, referral and the Premiere all navigate by name.
