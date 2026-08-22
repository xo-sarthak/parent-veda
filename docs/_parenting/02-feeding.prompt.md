# S02 Feeding - VERBATIM build prompt from 'Feedback on parenting Section (3).xlsx', row 2
# Read this ONLY when the doc file for this section says to check the prompt.

Here's the full prompt to copy:

---

# ParentVeda — Feeding Section (Parenting App): End-to-End Build Prompt (v3)

Build the Feeding section end to end. This section is content-rich and mostly maps onto screens and features that already exist, so the rule is: build the full content and experience described below, and wherever the app already has the right screen, store, or feature, use that real one instead of creating a parallel version. The inventory notes tell you what to reuse; they never shrink what an area must contain. Do not build video files; use the existing player with placeholder entries.

The app is Flutter (653 Dart files, 104 stores). Reconcile every cell: LIVE means map and reuse, do not rebuild; notReady means genuinely new, build it; notCore means it lives elsewhere, link don't build; notApplicable means never render.

---

## 0. Context and rules (apply to everything)

ParentVeda is India-first, calm, evidence-first, anti-anxiety, no misinformation.
- Simple, warm, plain-English and Hinglish where noted. No jargon. No em dashes.
- Never diagnose; route real red flags to a doctor.
- No breastfeeding guilt: present formula and combination feeding honestly (fed is fine). This matters given real Indian guilt around not exclusively breastfeeding.
- No dogma on solids: spoon-feeding and baby-led weaning both valid.
- India-first throughout: ragi, khichdi, dalia, sooji, dal water, idli/dosa for baby, Annaprashan, joint-family food pressure, the "too thin / mota" pressure, and the parent's own search language ("baby not eating food," not "picky eater").
- No gamification on any tracker.
- Free: all content, all charts, all recipes, all tools. Paid: only the human lactation and pediatric-nutrition consult.
- Every major area has its own explainer video (existing player + a placeholder entry). No area is text-only.
- No filler: every page must be genuinely useful on its own, or it is dropped, not padded.
- Each page renders in the FORMAT in brackets (recipe, chart, comparison, step-list, cards, short article, flagged callout, checker), never one long paragraph. Each page follows the template: short warm intro, the content in its format, a callout for the key point, a practical "when/how much/what age" line, an India note where relevant, and soft links to the related tool, recipe, or product.

---

## 1. What already exists for Feeding (reuse, do not rebuild)

The `parenting_feeding` bracket is almost entirely LIVE:
- content  LIVE  -> `pp_food` (FoodHomeScreen: category, recipe, mealplan, builder, shopping, saved, nutrition, sick_days) and `pp_read` (ReadingHomeScreen)
- tools    LIVE  -> `pp_feeding` (FeedingJourneyScreen + FeedingStore + feeding_tracker), `pp_growth` (GrowthJourneyScreen), `pp_what_changed` (WhatChangedScreen)
- products LIVE  -> `pp_products` (ProductsDiscoveryScreen), `pp_product_guide` (ProductGuideHubScreen), and the compare feature: `compare` screen + `PpCompareStore` with 6 existing compare guides
- course   LIVE  -> `pp_courses` (LearningHomeScreen)
- extras   LIVE  -> `pp_food`
- consult  notReady -> NEW: lactation (paid, most certain sale) + pediatric nutrition

Reuse: the 28 existing recipes (`pp_food_data.dart`) and recipe/mealplan/builder screens; the `sick_days` screen; 23 products, 18 product guides, 6 compare guides, 23 deals; `ProductStore`, `RecoStore`, `PpCompareStore`, `FeedingStore`, `GrowthStore`; the booking engine (entitlement -> slots) and `BookingStore`; the `can_i` / `CanIStore` pattern to mirror for the baby-food checker.

Known gaps to handle as explicit tasks, not silent assumptions: `PpProduct` has no image field (degrade gracefully, flag image seeding); consult supply is mock (seed real supply); no problem/intent/format tags on assets (add as data change where grouping is needed); the shared placeholder component does not exist yet (build once, reuse).

Where an area below says "use the compare feature" or "surface via pp_food," that is the mapping. The full content described in the area is still required in full.

---

## 2. The content areas (build all of this; map onto the live screens above)

### Area 1: Breastfeeding
Full basics and full problems set.
- Basics: latch, positions, how often to feed, supply (building and maintaining), foods to avoid while nursing, and pumping for working moms.
  Formats: latch and positions [STEP-LIST + diagram]; how often / how much / supply [SHORT ARTICLE]; foods to avoid while nursing [CARDS]; pumping for working moms [ARTICLE].
- Problems: low supply, oversupply, mastitis, painful or cracked nipples, biting, and baby refusing the breast.
  Format: [ARTICLE, one page per problem].
- Products via `pp_products`: breast pumps, nursing pads, nursing pillow, nipple cream (on the cracked-nipple page), nursing bras, milk storage bags. Breast pump manual vs electric vs brand -> use the EXISTING compare feature; check the 6 existing compare guides first and extend rather than duplicate.
- Paid lactation consult (the most certain sale) is surfaced here. This is the NEW consult build: seed real supply, wire to the existing booking engine.
- Video: lactation-expert latch demo, via existing player.

### Area 2: Formula and combination feeding
How to choose and prepare formula, Indian brands honestly compared, switching brands, mixed feeding, bottle refusal, and weaning off the breast when the family is ready. Honest and non-judgmental throughout (fed is fine), because Indian guilt around not exclusively breastfeeding is real and the tone must relieve it, not add to it.
- Formats: how to choose and prepare formula [ARTICLE]; Indian formula brands compared -> EXISTING compare feature, REVIEW-ONLY, not monetized (IMS Act, section 5); switching brands [SHORT ARTICLE]; mixed / combination feeding [ARTICLE]; bottle refusal [SHORT ARTICLE]; weaning off the breast [ARTICLE].
- Products: sterilizers, warmers, bottle brushes (allowed). Bottles and formula flagged REVIEW-ONLY / REQUIRES-LEGAL-SIGNOFF.

### Area 3: Starting solids (the 6-month gateway, major top-of-funnel)
When and how to start, first foods, traditional spoon-feeding vs baby-led weaning presented as both valid with no dogma, how to introduce allergens safely, textures by stage, and Annaprashan (the first-food ceremony) as the Indian cultural anchor.
- Formats: when and how to start [ARTICLE]; first foods [CARDS]; spoon-feeding vs baby-led weaning [COMPARISON card, concept comparison, both valid]; introducing allergens safely [STEP-LIST + callout]; textures by stage [CHART]; Annaprashan [SHORT ARTICLE].
- Products: feeding bowls, soft-tip spoons, suction plates, high chair, bibs, BLW plates, storage trays. High chairs across brands -> existing compare feature.
- Video: starting-solids demo.

### Area 4: Age food charts (the highest-volume driver)
Month-by-month charts for 6, 7, 8, 9, 10, 12 months, then toddler, with veg and non-veg variants and regional adaptations, as free downloadable PDFs. This is the cheapest-to-rank, highest-search content, so build it as a proper chart library surfaced in FoodHome, not buried.
- Format: [CHART, one per age], modeled as structured data the chart quick-view tool reads.

### Area 5: Recipes (existing strength, reuse the engine)
Reuse the existing recipe engine. Organize baby recipes three ways, filterable: by age (6-8m purees, 9-12m mashes, finger foods, toddler meals), by Indian staple (ragi, khichdi, sooji/suji, dalia, dal water, idli/dosa for baby, vegetable and fruit purees), and by need (weight-gain, iron-rich, immunity). Every recipe carries its cook-along video, age suitability, texture, and allergen flags.
- Format: [RECIPE], reusing the 28 existing recipes and the recipe/mealplan/builder screens; add age/texture/allergen/video fields to the recipe data model if absent. Link the existing `sick_days` screen for foods-when-baby-is-sick rather than building new.
- Products: baby food steamer/processor, portion/freezer storage trays, ragi and millet packs. Steamer/processor across brands -> existing compare feature.

### Area 6: Weight gain and growth feeding
Foods to help healthy weight gain, healthy fats (ghee, nuts as age-appropriate), calorie-dense Indian options, and honest reassurance against the constant Indian pressure that a baby is "too thin," while tying real growth concerns to a doctor.
- Formats: foods for healthy weight gain [CARDS -> recipe links]; healthy fats and calorie-dense Indian foods [ARTICLE]; "is my baby too thin?" reassurance [ARTICLE + see-a-doctor CALLOUT]. Link the existing `pp_growth` GrowthJourney tracker here for real growth tracking; do not build a new one.

### Area 7: Picky eating and not eating
The 1-year-plus refusal, food jags, mealtime battles, and practical calm strategies. Build it in the parent's own language: Indian parents search "baby not eating food," not "picky eater."
- Formats: "baby not eating food" [ARTICLE]; food jags, mealtime battles, and why not to force-feed [ARTICLE]. Empathy-first. Tie to `pp_what_changed` where relevant. Optional real-parent video.

### Area 8: Feeding safety and specifics (short, high-trust safety layer)
Iron and key nutrients with Indian food sources, allergens and how to introduce them, foods to avoid under one (honey, whole nuts, salt, sugar), choking hazards and safe textures, and water (when to start).
- Formats: iron and key nutrients [CARDS, Indian sources]; foods to avoid under one [FLAGGED CARDS]; choking hazards and safe textures [ARTICLE + callout]; when to start water [SHORT ARTICLE].
- This is the one area with real physical-harm stakes: keep it clear, prominent, and never softened for flow. Video: safe-textures / choking-safety demo, built prominently.

---

## 3. Tools

- **"Can my baby eat this?" checker** [CHECKER, NEW] — food + baby's age -> SAFE / NOT YET / AVOID with a one-line reason (honey not before 1, cow milk as main drink not before 1, whole nuts choking risk, etc.). Mirror the existing pregnancy `can_i` / `CanIStore` pattern; do not invent a new one.
- **Age food chart quick-view** [TOOL, NEW] — age -> chart, reads Area 4 data.
- **Feeding tracker** [LIVE] — reuse `pp_feeding` + `FeedingStore` + `feeding_tracker`, non-gamified. Do not rebuild.

---

## 4. Videos
One explainer per major area via the existing player, each a placeholder entry with title, length, slot id: latch demo (Area 1), starting-solids demo (Area 3), cook-alongs on recipes (Area 5), safe-textures/choking demo (Area 8), optional picky-eating clip (Area 7). Build the shared placeholder component once if any content is notReady.

---

## 5. Commerce, compare feature, and the legal flag

Surface products contextually via `pp_products` / `ProductStore` / `RecoStore` on the page they belong to, never in a wall, never on a safety-warning page. Use the EXISTING compare feature (`compare` + `PpCompareStore`, 6 guides already) for every "which one should I buy" moment: breast pumps, formula brands (review-only), high chairs, sterilizers, steamers, baby cereals. Check existing compare guides first and extend where one already fits. `PpProduct` has no image field yet: degrade gracefully and flag image seeding as a data task.

LEGAL FLAG (do not bypass): India's IMS Act and the WHO code restrict advertising and promotion of infant formula, feeding bottles, and infant foods marketed as breast-milk substitutes. Do NOT wire affiliate or promotional commerce on infant formula or infant bottles. Keep them as free honest review content only (the compare feature is fine for review), marked REVIEW-ONLY / REQUIRES-LEGAL-SIGNOFF so they can never become monetized surfaces. Pumps, bowls, high chairs, bibs, storage, tiffin, steamers are fine to monetize.

---

## 6. Paid layer (the one genuinely new build)

Consult is the only notReady cell: lactation (paid, most certain sale) + pediatric nutrition. Seed real consult supply (currently mock) and wire to the existing booking engine and `BookingStore`. Surface lactation on Area 1 (problems pages) and pediatric nutrition on Areas 6 and 8. Short "who this is for" line, 2-tap booking. Everything else stays free.

---

## 7. Build output expected

- All eight areas authored in FULL as defined in section 2, in their specified formats, real warm placeholder copy, no filler, no lorem ipsum.
- Everything surfaced through the LIVE screens (`pp_food`, `pp_read`, `pp_feeding`, `pp_growth`, `pp_what_changed`, `pp_products`, `pp_courses`); nothing rebuilt that already lives.
- Recipe engine reused (28 recipes extended with age/texture/allergen/video fields), `sick_days` linked, age-chart library added to FoodHome as data.
- Every "which to buy" moment routed through the existing compare feature; existing guides checked and extended before any new one.
- Two new tools built (baby-food checker mirroring `CanIStore`, chart quick-view); feeding tracker reused.
- Commerce via existing stores, contextual, image-field gap handled gracefully, infant formula + bottles REVIEW-ONLY / REQUIRES-LEGAL-SIGNOFF and never monetized.
- The one new consult (lactation + pediatric nutrition) seeded with real supply and wired to the existing booking engine.
- Known gaps (no product images, mock consult slots, no content tags, no placeholder component) handled as explicit tasks.

Build area by area in order, reconciling each cell: LIVE = map and reuse, notReady = build, notCore = link, notApplicable = never render.

---

That's the complete prompt. The file version is also attached above if you'd rather download it. Want Health next?
