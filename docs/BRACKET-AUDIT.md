# Bracket audit — Pregnancy

**P0 of the Level Map build. No code. This document is the gate.**

The rule it enforces: **no layer may be declared `live` without a named resolver** — an
actual file or screen that satisfies it. A hand-maintained availability enum drifts
within a sprint, and the failure is worse than a missing feature: a door that promises
six layers and opens to two.

Source: `parentveda-level-map-checklist.xlsx`, sheet `L1 + L2 Master`, the ten
PREGNANCY rows.

---

## How the workbook was read

⚠️ **Text is authoritative; the red fill is a hint.** They disagree in 38 places across
the whole sheet, and the disagreements run both ways:

- **4 cells carry negative text with no red fill** — all in pregnancy:
  `Scans & tests → Products` ("Not a fit"), `Scans & tests → Course` ("Not standalone,
  module of childbirth prep"), `Is it safe → Products` ("Not a fit"),
  `Is it safe → Course` ("Not a fit"). Reading fill alone would have shipped a shopping
  prompt under a scan explainer.
- **34 cells are red-filled but name a real offer or a demand judgement** — "Mood check",
  "Peer support circle", "Short conception-basics masterclass", and a long tail of
  "Optional" / "Rare" across skilling. These are *not yet*, not *never*.

Which is the whole reason the state is a four-way enum rather than a boolean.

| State | Means | Renders |
|---|---|---|
| `live` | Ships now, resolver named below | The section |
| `notReady` | Real, planned, not built — one flag flips it | Nothing |
| `notCore` | Real, but belongs on another surface | Nothing here |
| `notApplicable` | Never. The workbook refused it, with a reason | **Nothing, ever — no empty state, no CTA** |

---

## The audit

Legend: **L**ive · **NR** notReady · **NC** notCore · **NA** notApplicable

### 1. Scans & tests
*Highest-volume bracket in the product — anomaly scan ~135,000, ectopic ~74,000.*

| Layer | State | Resolver / reason |
|---|---|---|
| Content | **L** | `lib/data/tests_scans_reports_data.dart` (9 tests/scans) · `report_findings_data.dart` (~11 findings) · `scan_guide_data.dart` · `scan_schedule.dart` |
| Activities | **NC** | "Not core (rides week spine)" |
| Tools | **L** | `lib/screens/tools/tests_scans_reports_screen.dart` · `tools/scans_appointments_screen.dart` · `tools/due_date_calculator_screen.dart` |
| Products | **NA** | Workbook: "Not a fit". ⚠️ Not red-filled — text wins |
| Course | **NC** | "Not standalone (module of childbirth prep)" → lives under Labour prep |
| Consult | **L** | Dr. Ananya Rao (OB-GYN) in `kSpecialists` (`lib/data/prepare_data.dart`) lists **"Reading and understanding your scan reports"** as her first topic |

### 2. Complications & conditions

| Layer | State | Resolver / reason |
|---|---|---|
| Content | **L** | `kFindings` in `tests_scans_reports_data.dart` + `report_findings_data.dart` — ~11 conditions; 5 urgent symptoms in `symptom_data.dart` |
| Activities | **NC** | "Not core" |
| Tools | **NR** | Workbook wants a sugar & BP log. Kick counter exists (`tools/baby_movement_screen.dart`); **no BP or glucose log exists** |
| Products | **NR** | Workbook wants glucometer / BP monitor. No such category in `product_data.dart` |
| Course | **NC** | "Modules, not standalone" |
| Consult | **L** | Ritu Malhotra (RD) lists **"Gestational-diabetes-friendly eating"**; Dr. Ananya Rao (OB-GYN) lists **"Third-trimester aches, movements and warning signs"**. GDM is the most common complication and it is explicitly covered. *(Corrected during P0 — first pass marked this NR on the assumption of a general OB only, without reading the specialists' stated topics.)* |

### 3. Is it safe in pregnancy?

| Layer | State | Resolver / reason |
|---|---|---|
| Content | **L** | `lib/data/can_i_data.dart` — 193 entries, bilingual, across Eat / Drink / Take / Do |
| Activities | **NC** | "Not core" |
| Tools | **L** | `lib/screens/can_i_screen.dart` (the flagship free checker) · `tools/ask_veda_screen.dart` |
| Products | **NA** | "Not a fit". ⚠️ Not red-filled — text wins |
| Course | **NA** | "Not a fit". ⚠️ Not red-filled — text wins |
| Consult | **NR** | Workbook wants a light quick-query consult. No such product exists |

### 4. Nutrition & diet

| Layer | State | Resolver / reason |
|---|---|---|
| Content | **L** | `nutrition` block in all 37 weeks of `lib/data/weekContent.json` · `kNutritionPlans` in `prepare_data.dart` |
| Activities | **NC** | "Not core" |
| Tools | **L** | `lib/screens/prepare/nutrition_screen.dart` (trimester × goal × diet → plan) · `tools/weight_tracker_screen.dart` |
| Products | **NR** | ⚠️ **The clearest gap in the stage.** Workbook wants prenatal supplements and protein; `product_data.dart` has **zero** nutrition category |
| Course | **NR** | Workbook wants a trimester nutrition masterclass. `kMasterclasses` has 4, none nutrition |
| Consult | **L** | Prenatal Nutritionist in `kSpecialists` |

### 5. Symptoms & discomforts

| Layer | State | Resolver / reason |
|---|---|---|
| Content | **L** | `lib/data/symptom_data.dart` — 17 symptoms incl. 5 urgent · `body_changes.dart` · `trimester_tips.dart` |
| Activities | **L** | Relief stretches — `pp_yoga_data.dart` sessions tagged nausea / back relief, filtered by `kPregnancyYogaCategories` |
| Tools | **L** | `lib/screens/tools/symptom_companion_screen.dart` |
| Products | **L** | `product_data.dart` — pregnancy_pillow, compression_socks, belly_band, maternity_wear |
| Course | **NA** | "Not a fit" |
| Consult | **NA** | "Not a fit" |

### 6. Labour & childbirth prep
*The only bracket where every applicable layer is already live.*

| Layer | State | Resolver / reason |
|---|---|---|
| Content | **L** | `ready_for_birth_data.dart` · `hospital_bag_catalog.dart` · labour articles in `read_next_data.dart` · `VideoCategory.birth` |
| Activities | **L** | Breathing / positions — yoga months 7–9 in `prepare_data.dart` |
| Tools | **L** | `tools/contraction_tracker_screen.dart` · `tools/hospital_bag_v2_screen.dart` · `tools/ready_for_birth_screen.dart` · `tools/kegel_care_screen.dart` |
| Products | **L** | Hospital-bag catalogue + `tools/product_checklist_screen.dart` |
| Course | **L** | Birth Confidence Masterclass · Birth Prep Essentials · Birth-Ready Bootcamp cohort · `kBirthingClasses` (6) |
| Consult | **L** | Dr. Ananya Rao (OB-GYN) lists **"Birth-plan questions and delivery options"**. Not the doula the workbook imagined, but a real named person answering this bracket's question. *(Corrected during P0.)* |

### 7. Garbh sanskar & bonding

| Layer | State | Resolver / reason |
|---|---|---|
| Content | **L** | `lib/data/garbh_data.dart` · `garbhSanskar` block in every week · `read_to_baby_data.dart` · `spiritual_reading_data.dart` |
| Activities | **L** | Daily practice — `garbh_screen.dart` (Shravan / Samvad / Kriya) |
| Tools | **L** | `garbh_screen.dart` · `tools/garbh_games.dart` · `tools/spiritual_reading_screen.dart` |
| Products | **NR** | Workbook wants music / books affiliate. No category exists |
| Course | **NR** | ⚠️ Workbook names this the **FREE differentiated hero course**. It does not exist — and this is the deepest content asset in the app |
| Consult | **NC** | "Not core" |

### 8. Fitness & yoga

| Layer | State | Resolver / reason |
|---|---|---|
| Content | **L** | `pp_yoga_data.dart` (28 classes) filtered by `kPregnancyYogaCategories` |
| Activities | **L** | Guided prenatal yoga — `post_pregnancy/yoga_home_screen.dart` |
| Tools | **NC** | "Not core" |
| Products | **NR** | Mat / ball — minor, no category |
| Course | **L** | Trimester-Safe Fitness course · Fit & Strong Pregnancy cohort |
| Consult | **L** | Kavya Menon (women's-health physiotherapist) — "Back, hip and pelvic-girdle pain", "Pelvic-floor prep", "Safe posture and movement day to day" |

### 9. Pregnancy mental health
*Thinnest bracket with real demand, and high willingness-to-pay.*

| Layer | State | Resolver / reason |
|---|---|---|
| Content | **NR** | ⚠️ Scattered across `reflectAndRemember` in weekContent and `grow` in `lib/data/home/week_*.json`, plus 2–3 Read Next pieces. **No owned data file.** Needs creation |
| Activities | **L** | Relaxation practices — meditation category in the yoga data |
| Tools | **NR** | Workbook says "Mood check" (red-filled, but it names a real thing). **No mood tracker, no check-in, no breathing tool outside yoga** |
| Products | **NA** | "Not a fit" |
| Course | **NA** | "Not a fit" |
| Consult | **L** | Prenatal Counsellor in `kSpecialists` — the one solid asset in this bracket |

### 10. Belly & skin care

| Layer | State | Resolver / reason |
|---|---|---|
| Content | **NR** | ⚠️ Essentially nothing owned. No stretch-mark, melasma, itching or pigmentation set — `grep` for "melasma" returns nothing. Needs creation |
| Activities | **NA** | "Not a fit" |
| Tools | **NA** | "Not a fit" — `bump_journey_screen.dart` is belly *memory*, not belly *care*, and must not be mapped here |
| Products | **L** | `product_data.dart` — stretch_care, belly_band, maternity_wear, pregnancy_pillow |
| Course | **NA** | "Not a fit" |
| Consult | **NA** | "Not a fit" — no dermatologist in `kSpecialists` |

---

## Totals

⚠️ **These totals were written when the grid was 6 layers × 10 brackets = 60 cells. It
is now 70** — Extras was settled as a real seventh layer after this audit was first
drafted. The live figure moved from 30 to **34**:

- **+3** — three Extras entries already exist: the report explainer
  (`report_screen.dart`), the urgent-symptom set (`symptom_data.dart`) and the
  safe/not-safe database (`can_i_screen.dart`).
- **+1** — `Complications → Tools` upgraded from `notReady`. The workbook asks for
  "kick counter, sugar & BP log"; the kick counter exists and reduced movement is this
  bracket's own red flag, so the layer resolves. The missing logs are a listed gap, not
  an absent layer.

| State | Count | Share of 70 cells |
|---|---|---|
| `live` | 34 | 49% |
| `notReady` | 12 | 17% |
| `notCore` | 8 | 11% |
| `notApplicable` | 16 | 23% |

**The gate passes: every one of the 34 `live` cells names a resolver.**
`test/bracket_model_test.dart` asserts this count — **if it changes, this table changes
with it.** They are one claim in two places, and a document that drifts from its test is
worse than no document.

### The consult layer, corrected

The plan's default was *`notReady` wherever no named specialist covers the bracket*, and
on the first pass that produced four demotions. **Reading the specialists' own stated
topics rather than their job titles moved two of them back to `live`**, and the
correction is worth recording because it is the same mistake in miniature that this whole
audit exists to prevent: I judged the layer from the label rather than from the data.

`kSpecialists` holds five people, and between them they name topics covering **six of the
ten brackets**: Dr. Ananya Rao (OB-GYN) — scan reports, birth-plan and delivery options,
third-trimester warning signs · Ritu Malhotra (RD) — trimester diet, nausea and acidity,
GDM-friendly eating · Kavya Menon (women's-health physio) — back and pelvic-girdle pain,
pelvic-floor prep · Dr. Neha Verma (clinical psychologist) — anxiety and mood · Sana Khan
(IBCLC) — breastfeeding prep, which is a *parenting* bracket and correctly maps to none
of these ten.

⚠️ Separate and pre-existing: **the slots are mock.** That is a booking-supply problem,
not a bracket problem, and it is not this document's to solve — but shipping six brackets
that offer a consult against mock availability is a promise, so it needs a real answer
before P2 puts those sections on screen.

### What P0 demoted, and why that is the phase working

The workbook proposes an offer in far more cells than the app can currently serve. Held
against real files, **11 cells demote to `notReady`** — concentrated exactly where the
inventory predicted: **Products 4 · Course 2 · Tools 2 · Content 2 · Consult 1.**
Content demotes in only two of ten brackets. **The "90% of the content already exists"
claim holds for content and does not extend to the other five layers.**

### The five gaps worth naming

1. **Nutrition → Products.** No supplement or protein category exists at all, in the
   bracket with the highest commerce intent and the least commerce discomfort.
2. **Garbh sanskar → Course.** The workbook calls this the free differentiated hero
   course. We have the deepest content asset in the app and no course built on it.
3. **Mental health → Content + Tools.** Real demand, high WTP, nothing owned.
4. **Belly & skin → Content.** Products without the article set that earns the sale —
   the exact shape the wedge warns against.
5. **Complications → Tools.** No BP or glucose log, in the bracket where logging is the
   clinical routine.

### Silent decay found while auditing

`body_changes.dart`, `trimester_tips.dart` and `week_articles_data.dart` are seeded for
**one or two preview weeks only**. Both of the first two are cited as resolvers above for
Symptoms → Content, so that cell is honest at weeks 4–5 and thins out afterwards. Not a
blocker for P1, but it must not be discovered later as a bracket failure when it is a
content-seeding failure.

---

## What P1 takes from this

The table above is the input to `lib/data/brackets/pregnancy_brackets.dart`. Every
`live` cell carries its resolver into `surfaceIds`; every other cell carries its state
and the workbook's reason verbatim, so the screen never has to guess and the next person
can see why a section is absent.
