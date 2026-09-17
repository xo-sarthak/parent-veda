# Products audit — one store for three stages (Mobbin audit #7)

**Date:** 2026-09-17. **Asked by the user, in their words:** *"I want to retire
the mall. One unified product system, with the stage the user is in as the
default view, but she can easily navigate to trying-to-conceive or parenting.
Every functionality a marketplace has. Pick from the best out there — the flows
users are habitual of. ParentVeda recommends on some products, honest and
upfront. Expert reviews, community ratings, compare, images, zoom, Razorpay."*

**Built the same day:** `lib/screens/products/` (nine screens), one model
(`lib/models/pv_product.dart`), one catalogue (`PvCatalogStore`), the cart
that already existed, an order/address store, a migration (0083) and a change
to the create-order edge function. Every old product screen is a facade over
the new one; every old body is kept as `…Classic` for revert.

---

## 1. What we had

Three product systems, one per stage, each built alone:

| Stage | Model | Screens | What it had that the others lacked |
|---|---|---|---|
| Pregnancy | `Product` (LocalizedText, score /10, badge) | `products_screen.dart` — 3 tabs, category, detail | week-window relevance, "would buy again %" from real review structs |
| Parenting | `PpProduct` + `ProductGuide` | discovery · category · subcategory · detail · compare · Guide hub · Guide page · a "which view?" chooser | subcategories, compare specs, IMS review-only flag, age window, the Guide's experts/ingredients/studies |
| TTC | `TtcProduct` | shop · shelf · product · compare (V3), plus the flat research list | the recommendation **band** as an enum with `skip` on the shelf, the evidence grade, parent voices |

Three ideas of a price (`'₹1,899'`, `1499`, `'₹80 – ₹250 a month'`), three
compare trays, two "ParentVeda score" derivations, a `thermometer` id on two
sides, and a Products tab on one bar out of three.

## 2. Asked (the Mobbin pass)

Fourteen queries, ~20 apps, by flow not by screen:

- **Storefront home:** [Amazon Haul](https://mobbin.com/flows/e70a24f7-b8b5-4bde-8410-04d197a87604), [Target](https://mobbin.com/flows/2507e05c-65f0-4a63-b311-5ebeadcc9898), [H&M home](https://mobbin.com/flows/052160bb-ac20-4266-8533-eb12fc820c0b), [Blinkit · Kids](https://mobbin.com/screens/6d6daf65-f660-45ee-9784-24a23cbc9d11), [Walmart · nursery](https://mobbin.com/screens/148ccb61-a3a6-4bb3-9935-c6bc119d5765), [SHEIN category](https://mobbin.com/screens/46dadfbd-af5d-4116-82bf-eb5ea1640a78), [Tabby](https://mobbin.com/screens/9a757869-ee97-4559-a3e1-701829d36545)
- **Department switch (their Women/Men/Kids = our stages):** [H&M "WOMEN +"](https://mobbin.com/flows/51ec4be1-cd06-41b6-84c2-6b738d41df4f), [Zara menu](https://mobbin.com/flows/97c2e4b7-b78c-4273-8431-a88285f092b7), [H&M search with counts](https://mobbin.com/screens/e52d2cf2-297b-4893-9325-b899680f98c5)
- **Browse / listing:** [Etsy categories → listing](https://mobbin.com/flows/fd37d43f-1d4b-4eeb-8cae-8af561bec476), [Zara listing](https://mobbin.com/flows/b06c1497-d994-410b-aa65-6d3325ccd442), Sephora results
- **Product page:** [Amazon (20 screens)](https://mobbin.com/flows/c92e6887-0bc6-4cdc-8c79-c5b576532e90), [Sephora](https://mobbin.com/flows/da9c31e2-6444-473f-a92e-acc10fb7bb07), [CRED Store](https://mobbin.com/flows/52b2cbc8-3d00-4313-9da2-f1ed0ce486d3), Zara, Etsy
- **Gallery / zoom:** [H&M](https://mobbin.com/flows/742c98a3-a587-4524-b843-fc072f322044), SSENSE
- **Reviews:** [Best Buy](https://mobbin.com/screens/9a2632aa-2e39-47d2-93fb-57e66dfea3c7), [Target](https://mobbin.com/screens/a325e04d-0a18-46e4-888d-ee77627fc9bc), [Etsy](https://mobbin.com/screens/b6b32fbd-e879-440c-a41e-4db104038d97), Amazon, Sephora, Urban Company, Shopee
- **Experts / editorial:** [Lovi "Approved by"](https://mobbin.com/screens/c9c5c231-b96f-4686-826d-176f94ecdd1d), [Liven "Expert reviewed"](https://mobbin.com/screens/e51a2af2-bb7d-4314-b291-061965b5ea92), [Klarna expert reviews](https://mobbin.com/screens/b0215a38-27eb-433f-b3c8-e7c2b2a651ae), [Swiggy Dineout expert](https://mobbin.com/screens/67d0c6f4-c01e-4f38-88fb-9b9bfc446692), Shop's AI answer
- **Compare:** [Best Buy](https://mobbin.com/screens/8c8deebf-ad84-4b1b-b54f-bd665f92ab5d), [Walmart inline](https://mobbin.com/screens/3d603cda-c05b-41f8-911a-a0e2548e8a59), [lululemon](https://mobbin.com/screens/fd35da56-a8c1-4988-9392-91a8117bb79a)
- **Variants / add-to-bag sheets:** [Yami](https://mobbin.com/screens/7f10da88-7a2e-4a20-8ad3-0e89df9ffcbd), [UNIQLO](https://mobbin.com/screens/5807f5b2-f5eb-4faa-b6c0-7beaa1726c5b), [Etsy](https://mobbin.com/screens/41411aa0-54d6-45c8-b283-ddf4d1583391), [Sephora add to basket](https://mobbin.com/flows/e20195a2-001d-4b99-a4c8-feabece3c90e)
- **Cart → checkout → placed:** [foodpanda](https://mobbin.com/flows/815f35d3-bc4a-4d28-858e-6ff6444f6186), [7-Eleven](https://mobbin.com/flows/9d58631e-f3b3-4265-af24-29601761c998), [adidas](https://mobbin.com/flows/8c0f2773-3d21-410b-99c6-acf2e17d85a2), CRED's address sheet
- **Orders:** [Apple Store](https://mobbin.com/flows/64cc1e86-518f-4504-92ec-61e7da29af15), [Starlink](https://mobbin.com/flows/ca294b24-b7af-4ff2-a768-eeac3c79b49b)

**Not in the library:** Myntra, Nykaa, Flipkart, FirstCry (fall through to
Shopee / Instagram / CRED). In: Amazon, Zara, H&M, Sephora, Etsy, Target,
Walmart, Blinkit, CRED, Swiggy, Tabby, SHEIN.

## 3. Found — the decisions, not the looks

| Surface | What every one of them does | What that told us |
|---|---|---|
| Storefront | search bar first; a department row; category shortcuts with a picture or glyph; a "for you" rail; editorial rails; shelves | the first screen is a **menu of ways in**, not a grid |
| Department | H&M: one word in the corner, tap → the whole home changes, remembered. Zara/Tabby: three words in a row, the active one in ink. Search: `ALL [507] · WOMEN [271] · BABY [21]` | the switch is **one word at the top**, never a wall; search is cross-department with counts |
| Listing | 2-col square photos, heart top-right, brand small, name two lines, stars + count, price + struck MRP + % off; filter chips + sort chip + result count; filters in a sheet with an ink "Show N" | the card is a **contract users already read**; do not redesign it |
| Product page | full-bleed gallery, `1/5`, dots, tap → zoom; brand · name · stars · count; price; variants; **sticky commit bar**; details as `+` accordions (CRED: "notes from our experts +"); reviews with a summary above them; "compare with similar" inline (Walmart); related rails | the page is a **funnel in one scroll**; everything after the price is there to convince |
| Reviews | big number, distribution bars, "95% would recommend" (Best Buy), **pros/cons chips with counts**, reviewer attributes under each review (Sephora: "Combination skin"), verified purchase, helpful | "what's good / worth considering" already has a shape users know |
| Experts | a named person with credentials and an *Expert reviewed* mark (Liven, Lovi); an "Expert reviews" list of ✓ / − lines with a quote (Klarna); a person page with "X's top recommendations" (Swiggy) | "ParentVeda recommends" = **a reason, signed** |
| Compare | two or three columns, product heads pinned with a button under each, rows of facts | the first row should be the one a marketplace cannot print |
| Cart → checkout | bag with stepper and a free-delivery nudge → **address (radio list, + Add new)** → payment + order summary with breakdown → `Place order` → "Thanks" + `View order` | one spine, no invention needed |
| Orders | card per order: photo, reference, date, status word, total → the receipt | status is a **word**, not a progress bar we cannot back |

## 4. Adopted

- **One store, three storefronts.** `PvStoreScreen` opens on her stage; the
  stage switch is three display words (Tabby's line in Newsreader); the other
  two are always one tap away. Search is cross-stage with count chips (H&M).
- **Slot 2 on every bar, same word, same icon** — the user's call. Pregnancy's
  Prepare and TTC's Courses moved to the first tile of their Tools hubs.
- The listing card, the filter sheet, the sort chip, the gallery with `1/3`
  and zoom, the sticky bar, the `+` accordions, the review block, the compare
  table, the cart/checkout/placed/orders spine — **as they are**, in our type
  and on the base-UI rule (white ground, ink pills, brand violet on the
  eyebrow and the verified mark only).
- **Ours, where it earns its place:**
  - *ParentVeda recommends* on SOME products: a reason, a "before you buy"
    sentence, and *Reviewed by <name> · <role>* with the verified mark — the
    Liven/Lovi shape. The band is an enum; "Generally not needed" renders at
    the same weight.
  - *What experts say* — named, with credentials, a quote, a film when we have
    one; the measured "% of experts" only when a source supplied it.
  - Honest empties: no rating bars we cannot back, no percentage derived from
    a star, "Representative photo" under the gallery.
  - The affiliate interstitial: "Leaving ParentVeda · we may earn a commission
    · it never changes what we recommend".
  - IMS Act: a review-only product has no buy control anywhere and says why.
  - A "How ParentVeda sells" strip at the foot of the storefront.

## 5. Declined

- Rating distribution bars (Best Buy, Target) — we hold no per-star counts;
  bars drawn from three reviews would look like a measurement of the whole.
- Amazon's AI "Customers say" summary — a sentence nobody wrote.
- Sponsored rows on the storefront (Blinkit's `Ad`) — Brand Studio's rank-floor
  rule is the only way a brand reaches a shelf here, and it is not wired in yet.
- A score out of 100 (the old Guide's `parentScore`) — replaced by the band +
  the measured percentages, or nothing.
- Per-stage product screens with different features — the whole point.
- The "Guide or quick page?" chooser sheet — one page now carries both.

## 6. The architecture, and why

```
lib/models/pv_product.dart          one shape; stage is a TAG (FAMILY-MODEL)
lib/data/products/
  pv_catalog_adapters.dart          three old catalogues → PvProduct; Guide merged by id
  pv_product_extras.dart            photos · variants · the recommends (overlay)
lib/services/
  pv_catalog_store.dart             the one catalogue; forStage/forYou/recommended/search
  pv_compare_store.dart             one tray, two at a time, one category
  pv_order_store.dart               addresses + orders; user_state blob + `orders` rows
  cart_store.dart                   (existing) + an image per line
lib/booking/payment_service.dart    pay() shared by bookings and the store
lib/screens/products/               store · shelf · product · gallery · reviews ·
                                    search · compare · cart · checkout · placed · orders
supabase/migrations/0083_…          products: stage[] + the unified columns; orders ledger
supabase/functions/razorpay-create-order   prices `lines` from products; `priced_by` note
```

**Adapters, not a rewrite.** ~3,000 lines of authored copy stay where they
are; the adapters fold them into one shape and the overlay adds what none of
them had. The trade: two files to read for one product, and the unified model
cannot carry a field its sources lack without the overlay. Accepted, because
the alternative was a fourth catalogue beside three live ones — the drift this
build exists to end. When the `products` table carries all rows, the adapters
are the import script.

**Facades, not deletions.** `ProductsScreen`, `ProductsDiscoveryScreen`,
`ProductDetailScreen` (both), `ProductsCompareScreen`, `Products(Sub)CategoryScreen`,
`ProductGuideHubScreen`, `ProductGuideScreen`, `openProductWithGuideCheck`,
`TtcShopScreen`, `TtcShelfScreen`, `TtcProductPage`, `TtcCompareScreen`,
`TtcProductsScreen` — each public name now builds the unified screen, so ~30
call sites landed without an edit; each body is `…Classic`, kept for revert.
The old widget tests are pinned to the `…Classic` names; the shipped path has
its own tests in `test/pv_store_test.dart`, including reachability by grep.

**Money.** `PaymentService.pay()` is the general three-step flow (order →
Razorpay sheet → verify). The store sends its cart `lines` and the edge
function **re-prices them from the `products` table**; when it cannot (the
unified rows are not loaded yet) it charges the phone's figure and writes
`priced_by: client` on the Razorpay order — auditable, never silent. An order's
status is the payment's: `paid` only after the signature verified; `preview`
when the stack was unreachable, and the copy says so.

## 7. Owed

See STILL-OPEN §65. Headlines: deploy 0083 and reload the catalogue into
`products`; a device walk of all three storefronts; real photography and real
reviewer names (the overlay's are seed); an Ask Veda row on the product page;
the order-status webhook (nothing moves an order past `paid` today);
Brand Studio's rank-floor on the shelf.

## 8. After the walk (same day)

Walked on a Galaxy S21 FE in versus format; thirteen defects fixed on the
phone and a real Razorpay test payment verified end to end (STILL-OPEN §65.2).
Two things the walk added: the **hero band** (`pv_hero_band.dart` — the
swipeable cards every marketplace opens with, built from the catalogue until
banners exist) and the **motion pass** (`PRODUCTS-MOTION-AND-ASSETS.md`).
The honest list of what the engine still lacks is STILL-OPEN §65.9.
