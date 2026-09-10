# Screen unification audit — where the same thing is built four times

**Written:** 2026-08-28 · **Status:** analysis only, nothing implemented.

**The question asked:** *"I don't want 4 screens for the same thing on 4 sides of
the app. Where do we have non-uniformity, so we can write Claude Design prompts
to fix it?"*

This file answers that and nothing else. No structure is proposed and no screen
is redesigned here — the point is to find the spots, size them, and separate the
duplication that is a defect from the duplication that is correct.

---

## The finding that changes how the prompts should be written

**Almost every duplicated screen exists because there is a duplicated MODEL
underneath it.**

There are five reader screens because there are four read models. There are two
`ProductDetailScreen` classes — *the same class name, in two files* — because
there are three product models. Twenty-three commerce screens exist over seven
different content types describing one commerce object.

This matters for what you commission next:

> ⚠️ **A Claude Design prompt for "one product page" produces a beautiful screen
> that cannot be built, if `Product`, `PpProduct` and `TtcProduct` still have
> different fields.** The design will assume a shape, and two of the three data
> sources will not have it.

So each prompt below is scored on two things — the design work, and whether a
model convergence has to land first. Where it does, the honest order is:
**converge the model → then design one screen over it.** The paid-offering
family is the exception and the proof: `lib/booking/` was unified *first*, and
that is precisely why `docs/design-prompts/PAID-OFFERING-FLOW-PROMPT.md` could be written as a
straightforward six-screen brief.

---

## Three kinds of duplication, and only two are problems

| Kind | Example | Verdict |
|---|---|---|
| **Same object, many screens** | one product rendered by two `ProductDetailScreen`s | **Defect.** Unify. |
| **Same shape, different objects** | records vs. appointments vs. reports | **Maybe.** One component, not one screen. |
| **Deliberately separate** | TTC's tone vs. Parenting's tone; stage-isolated content | **Correct.** CLAUDE.md requires it — leave alone. |

The third row is load-bearing. CLAUDE.md says the stages are deliberately
isolated and shipped stages are extended additively, never rewritten. Nothing
below proposes merging *stages*; it proposes that a **product page is a product
page** whichever stage you reached it from.

---

# TIER 1 — the expensive ones

## 1.1 Paid offerings — 23 screens, 7 models, one engine

**The single biggest duplication in the app**, and the one already diagnosed.

| Stage | Screens | Lines |
|---|---|---|
| Parenting | `masterclasses` · `masterclass_funnel` · `courses` · `courses_explore` · `course_detail` · `course_funnel` · `course_lesson` · `cohort_funnel` · `cohort_courses` · `learning_home` · `learning_detail` · `yoga_home` · `yoga_class` | ~4,900 |
| Pregnancy | `prepare/masterclasses` · `masterclass_detail` · `cohorts` · `cohort_detail` · `consultations` · `consultation_detail` · `courses_cohorts` · `program_detail` · `prenatal_yoga` | ~2,300 |
| TTC | `ttc_prepare_screen` only — **`TtcOffering` carries an `expertId` and no detail screen exists at all** | ~340 |

**Seven content types for one commerce object:** `Masterclass`, `Cohort`,
`Specialist`, `PrepProgram`, `LearningProgram`, `YogaClass`, `TtcOffering`.

**Why this one is ready to design now:** the engine is already single.
`lib/booking/` sells all five kinds through `Offering → EntitlementGrant → Slot
→ Booking`, and `showBookingSheet` is the one buy flow. The screens are the only
thing that never converged.

**Prompt status: ALREADY WRITTEN** — `docs/design-prompts/PAID-OFFERING-FLOW-PROMPT.md`, six
screens, one template with four variant artboards. It has not been built.
Nothing else in this audit should be commissioned before it, because it is the
largest saving and the least blocked.

---

## 1.2 Reading — 5 readers, 4 models, ~4,500 lines

The clearest case of "same thing, four times", and the one a reader will notice
because the *typography and controls change* depending on which door they used.

| Screen | Lines | Model | Reached from |
|---|---|---|---|
| `reader/pv_reader_screen.dart` | 1,087 | `PvRead` | TTC reads, journeys, PCOS/precheck |
| `read_reader_screen.dart` | 970 | `ReadItem` | Pregnancy weekly reads |
| `book_companion_screen.dart` | 890 | its own | Book Companion |
| `post_pregnancy/reading_reader_screen.dart` | 568 | `ReadArticle` | Parenting "Learn" |
| `post_pregnancy/article_reader_screen.dart` | 320 | `Article` | Parenting articles |
| `father/father_reads_screen.dart` | 654 | father read data | Father mode |

**Four models for one thing:** `PvRead` (sections, tips, FAQs, next steps),
`ReadItem`, `ReadArticle` + `ReadCollection`, `Article`.

`PvRead` is the richest and was built as the premium reader — progress, TOC,
font control, light/sepia/dark, myth-vs-fact, read-next. The parenting
`article_reader` at 320 lines has almost none of that. **The same company's
reading experience is four different qualities of product.**

**Blocked on:** model convergence. `PvRead` is the obvious target shape; the
question is whether `ReadArticle`'s collections and `ReadItem`'s week-binding
survive as fields on it.

---

## 1.3 Products — two classes with the same name

| What | Where | Model |
|---|---|---|
| `ProductDetailScreen` | `lib/screens/products_screen.dart:720` | `Product`, takes a `controller` |
| `ProductDetailScreen` | `lib/screens/post_pregnancy/product_detail_screen.dart:20` | `PpProduct`, takes only the product |
| *(none)* | TTC — `ttc_products_screen` has cards and **no detail screen** | `TtcProduct` |

⚠️ **Two live classes with the identical name and different constructors.** Which
one a file gets depends on which it imported. That is not a naming nit — it is
the condition under which somebody "fixes the product page" and fixes one of
two, which is how the two drifted in the first place.

Around it, parenting alone has `products_category`, `products_subcategory`,
`products_discovery`, `products_compare`. Pregnancy has a category screen inside
`products_screen.dart`. TTC has a flat list.

Separately, `lib/screens/product_guide/` (6 files) is a *different* archetype —
the trust-first "understand in 10 seconds" guide — and should stay distinct. Do
not fold it in.

**Blocked on:** three product models converging. This is probably the cheapest
model merge in the audit — they are all "a thing you buy with a price, an image,
a category and a why".

---

## 1.4 Community — 5,400 lines, three screens, ONE model

| Screen | Lines |
|---|---|
| `community_screen.dart` (pregnancy) | 3,199 |
| `post_pregnancy/community_screen.dart` | 1,520 |
| `ttc/ttc_community_screen.dart` | 646 |

**Unusual and encouraging:** the data layer is already shared — all three import
`community_models.dart`, `community_data.dart` and `CommunityStore`. So this is
the one Tier-1 item that is **purely a presentation duplication and needs no
model work first.**

A single feed / thread / composer, themed per stage, retires ~3,000 lines. Rooms
and tone stay per-stage; that is content, not structure.

---

# TIER 2 — real, smaller, or partly justified

## 2.1 Recipes and food — 3 models

`Recipe` (`nutrition_data.dart`) · `RecipeItem` (`pp_recipes_data.dart`) ·
`FoodRecipe` (`pp_food_data.dart`).

Pregnancy has `nutrition/` (9 screens: charts, cravings, fasting, verdict,
nutrients, recipes). Parenting has `food_*` (9) plus `recipes_screen`,
`recipes_explore_screen`, `recipe_page_screen`. Note parenting has **two recipe
systems of its own** — the original Recipes and the newer Food Companion — which
is a duplication inside a single stage.

**The recipe detail page is the unifiable unit.** The surrounding hubs are
genuinely different products (a pregnancy diet chart is not a baby meal plan).

## 2.2 Records, reports and documents — same shape, three builds

`ttc_records_screen` (498) · `health_records_screen` (847) ·
`tests_scans_reports_screen` (810).

All three are "a list of uploaded documents with a type, a date and a
viewer". This is a **component** unification more than a screen one — the
surrounding context legitimately differs.

## 2.3 Appointments — three, and one is correct

`ttc_appointments` (454) · `scans_appointments` (962) · `doctor_appointments`
(573). The doctor one is a different user and should stay separate. The two
parent-side ones are the same object with different labels.

## 2.4 Saved — two hubs, 655 lines

`saved_hub_screen` (337) and `pp_saved_hub_screen` (318). Small, obvious, and
the kind of thing that is cheap to do while a bigger unification is in flight.

## 2.5 Video — parenting-only, and that is the gap

The Watch module (9 screens, `WatchVideo`) exists **only in parenting**.
Pregnancy has `prepare_video_screen` and `PvVideoPlaceholder`; TTC has
`ttc_videos_data` with no player at all. Models: `PvVideo`, `PvVideoSlot`,
`WatchVideo`.

⚠️ **This is a missing screen, not a duplicated one.** Worth naming here because
"where is it non-uniform" and "where is it absent" look the same to a user
walking the app.

## 2.6 Journal — five implementations

Pregnancy `journal_screen` + `journal_compose` + `journal_writer` · parenting
`journal_v2/` (6 files, the keepsake storybook) · `ttc_journal_screen` ·
`garbh_journal_screen` · `father_journal_screen`.

Partly justified — the parenting Journal V2 is deliberately a different product
(a printable keepsake). The **entry/compose moment** is the duplicated part.

## 2.7 Calendar, journey maps, tools hubs, Ask Veda

- **Calendar:** `calendar_screen` · `ttc_calendar_screen` · `leap_calendar_screen`.
- **Journey map:** `journey_map_screen` · `ttc_journey_map_screen` · parenting's
  `journeys_screen` + five domain journeys.
- **Tools hub:** `tools_screen` / `tools_hub_screen` (16 tools) vs
  `ttc_tools_screen` vs parenting's Explore drawer.
- **Ask Veda:** three screens — **deliberate**, one per stage, and the service is
  already single. Leave.

---

# TIER 3 — already solved, or correctly separate

- ✅ **Expert / doctor profile — UNIFIED 2026-08-27.** One `Expert` type
  (`lib/experts/`), one registry, one `ProviderProfileScreen`, one link widget.
  Every stage opens the same page. **This is the worked example of what the rest
  of this audit is asking for**, and it is worth reading the commit before
  writing the next prompt: the data moved first, the screen stayed put, and one
  seam file kept fifteen call sites from having to know.
- ✅ **Booking engine** — one engine for every paid thing, both stages.
- ✅ **Bottom navigation** — `PvNavBar`, after three stage-specific bars were
  merged.
- ⏸️ **The doctor app** — a separate audit already exists,
  `docs/design-prompts/DOCTOR-APP-DESIGN-PROMPT.md`. Its `doctor_profile_screen` is a
  *self*-profile and should not be folded into the expert profile.
- ⏸️ **Eight `*VersionStore` toggles** — Today, PP Home, TTC Home, Grow, Health
  Wallet, Scans Hub, Shravan, Baby Naming. Already logged in
  `docs/FLOW-INVENTORY.md` as ten deferred design decisions carried as code.
  **Unifying a screen family whose winner has not been picked doubles the work**,
  so closing the relevant toggle should be part of each prompt, not a follow-up.

---

# What to commission, in what order

| # | Prompt | Screens retired | Model work first? |
|---|---|---|---|
| 1 | **Paid offerings** — already written, not built | ~23 → 6 | **No** — engine is done |
| 2 | **Community** — feed, thread, composer | 3 → 1 | **No** — model already shared |
| 3 | **Product page** — one detail, one category, one compare | ~8 → 3 | **Yes**, small |
| 4 | **Reader** — one reading experience | 6 → 1 | **Yes**, largest |
| 5 | **Recipe detail** | 3 → 1 | **Yes**, medium |
| 6 | Saved hub · records viewer · appointments | 7 → 3 | components, not screens |

1 and 2 need no data work and together retire roughly **20 screens and 8,000
lines**. They are the right first two prompts.

**One caution for every prompt.** Ask for the **states**, not just the happy
screen — empty, one item, forty items, no image, no price, not-yet-published.
Most of the divergence in this codebase is not in the main layout; it is that one
stage drew the empty state as an invitation and another drew it as an apology.
