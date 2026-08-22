# S10 What toi buy - VERBATIM build prompt from 'Feedback on parenting Section (3).xlsx', row 10
# Read this ONLY when the doc file for this section says to check the prompt.

Here's the full prompt to copy:

---

# ParentVeda — "What to Buy" Shop + Compare: Polish Prompt (features already built)

This is NOT a ground-up build. The commerce section is already well-built and trust-first is clearly intentional. Do NOT restructure it. The job is narrow polish plus one missing data field (product image), so that the only work left afterwards is dropping in real affiliate (Amazon etc.) or own-brand products as data.

The app is Flutter. Reuse these existing pieces by their real names, do not rebuild any of them:
- `pp_products` -> ProductsDiscoveryScreen ; `shop` -> ProductsScreen ; `pp_product_guide` -> ProductGuideHubScreen ; `pp_recos` -> ProductsDiscoveryScreen
- Commerce screens: products_discovery, category, subcategory, detail, compare, reco x6, deals, investments
- Stores: `ProductStore`, `RecoStore`, `PpCompareStore`, `ProductGuideVotes`, `CartStore`
- Data present: 23 products in 6 categories, 18 product guides, 70 reco items in 10 collections, 6 compare guides, 23 deals
- `ChildProfileStore` for age-aware surfacing

Trust-first is the deliberate identity of this shop. The dense trust signals (ParentVeda score, % parents like you, % experts, community rating, star rows) and the honest voice ("ParentVeda Guidance", "Before you compare", "the ParentVeda take", "evidence-based, neutral and never promotional") are the FEATURE, not clutter. Never strip them to look cleaner.

## 0. Rules
- India-first, calm, evidence-first, no-misinformation, honest, no em dashes.
- No fabricated products or fake data. Where real products are not added yet, render clean empty/placeholder states that look intentional, never broken.
- The only remaining human task after this is adding real products as data (fill entry fields); no layout or code work should be needed then.

## 1. The existing flow (reuse as-is, polish only, do NOT restructure)
The architecture is correct and stays:
- **Buying Guides entry** ("Buying for your child, without the overwhelm") with "What do I actually need?" and "Compare & choose". Keep.
- **Products shop**: search, Filters, Top rated, "Shop by category" with category rows (Sleep, Skincare, Feeding, Play & Development...) and subcategory tiles. Keep.
- **Category guide** (e.g. Lotions): the "ParentVeda Guidance" look-for / avoid box, brand filter (All brands / ParentVeda), ranked product cards with Best-overall / ParentVeda tags, "Why ParentVeda recommends", "Things to consider", price, Buy now, Compare tick. Keep, this is excellent trust-first work.
- **Compare page**: "Before you compare / what actually matters / often doesn't matter / common mistake", the honest one-liner, the sponsorship flag ("Presented by X, NEEDS A DECISION"), two product columns, the spec table (size, free from, skin type, suitable age, key ingredients, rating), "Parents rated", "The ParentVeda take: what's right / worth knowing", "evidence-based, neutral and never promotional", Buy buttons. Keep all of this structure.

## 2. The actual work (small, in priority order)

### 1. Product image field (the main fix, highest priority)
The empty diagonal-hatch tiles everywhere are because `PpProduct` has no image field. Add `imageUrl` (and optional `imageUrls[]` gallery) to the `PpProduct` model and product data schema. Render the image on: category/subcategory tiles, product cards, and both compare columns. When `imageUrl` is empty, show a clean branded placeholder tile, never a broken icon. This single fix removes the placeholder look across the whole section.

### 2. Age-aware "What you need now" band on the Products shop
Above "Shop by category", add a stage-tied row that reads `ChildProfileStore` and surfaces the matching reco collection (existing `RecoStore`, 70 items / 10 collections; tag collections to age bands). A newborn parent and a 2-year parent must not see the identical grid. Contextual and stage-tied, not a rotating offer carousel.

### 3. IMS Act compliance on BOTH the product/category pages AND the compare page (must, do not bypass)
India's IMS Act and the WHO code prohibit advertising or promoting infant formula, infant feeding bottles, and infant-food-marketed-as-breast-milk-substitute. For these products only: set a `reviewOnly` flag. On both the product/category card and the compare column, KEEP all trust signals, the honest guidance, the spec table, and the "ParentVeda take" (honest information is fine and on-brand), but REMOVE the "Buy now" / "Buy X" CTA and any affiliate link. The same `reviewOnly` flag drives both surfaces. Mark these entries `REVIEW-ONLY / REQUIRES-LEGAL-SIGNOFF` in data so they can never be flipped to a buy path without review. Everything else (pumps, bowls, swaddles, high chairs, skincare, mom recovery products, etc.) is a normal buyable product.

### 4. Sponsorship never overrides the verdict
The "Presented by X / sponsorship on the compare tool" flag is good and on-brand; keep it visible and honest. Ensure a sponsored product can never alter the neutral ranking, the recommendation, or the "ParentVeda take". Sponsorship = clearly labelled placement only, never a changed verdict.

### 5. Minor trust-consistency (optional, only if low-effort)
Reword self-referential recommend-reasons on ParentVeda's own products (e.g. "ParentVeda-made with verified reviews" reads self-serving); keep own-SKU labelling honest and neutral. Optionally align the richer signal stack (ParentVeda score, % parents like you, % experts) onto the category cards for consistency with the product-guide page.

## 3. Make "add a product later" a pure data drop
Structure so the only remaining task is filling product entries. An entry carries: name, category, age-band tag, own-SKU flag, `reviewOnly` flag, `imageUrl` (+ gallery), price, affiliate/own link, the trust signals (score, % recommend, % experts, ratings), best-for tags, honest blurb, what's-good / worth-knowing, compare-group, and the spec fields (size, free-from, skin type, suitable age, key ingredients). When filled, the product renders fully everywhere with no code change. Provide clean empty/placeholder states for unfilled products and empty categories.

## 4. Build vs reuse
- REUSE (do not rebuild): all the screens and stores listed at top, and all existing product/guide/reco/compare/deals data.
- BUILD/CHANGE (small): add the image field + placeholder tiles; add the age-aware "what you need now" band; add the `reviewOnly` flag and apply IMS handling on both product and compare surfaces; enforce sponsorship-never-overrides-verdict; age-band tags on reco collections; optional trust-consistency reword.
- Do NOT restructure the flow, the product page, or the compare page. The architecture is already right.

## 5. Priority order
Image field -> age-aware "what you need now" band -> IMS review-only on both product and compare pages -> sponsorship-never-overrides-verdict -> optional trust-consistency reword.

This prompt covers the complete product section including compare. No other commerce prompt is needed. Contextual product surfaces inside other sections (e.g. a rash cream shown on the Health rash page) reuse this same product system, so they need no separate build.
