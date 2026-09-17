# The store's motion, and the assets it is waiting for

**Written 2026-09-17, on the phone.** The user, mid-walk: *"the way it flows
and everything — smoothness. Images, motions, customisations can go to a
separate file and be discussed later, but what code can be doing, I need
that."* This is that file. Part 1 is what code did, that day. Part 2 is what
needs a designer, a photographer or a brand, parked here rather than faked.

---

## 1. Motion that is built (all code, no assets)

The principle: a marketplace feels smooth through **continuity and
response**, not decoration. Every item below is one of those two.

| Where | What moves | Why | Where in code |
|---|---|---|---|
| Card → product page | The tapped photo *is* the page's first frame (Hero), both directions | Zara / H&M's open: the thing you touched becomes the thing you read. Tags are scoped per rail (`pv_img_<scope>_<id>`) because one product can sit in two rails on one screen and two Heroes with one tag assert | `PvProductCard.heroTag`, `pvOpenProduct(heroTag:)`, `PvProductScreen.heroTag` |
| Product page → zoom | Frame 0 flies again into the viewer | same continuity, one more level | `PvGalleryScreen.frameZeroTag` |
| Any card | Scales to 0.98 under the thumb | the press is acknowledged before the route moves | `ObPress` around the card |
| Any photo | Fades in over the category-tinted well; cached decodes skip the fade | photos never pop; scrolling back is instant | `PvProductImage.frameBuilder` |
| Stage switch | The storefront cross-fades and slides 4 % in; header and switch stay put | H&M's department switch — the content changes, the control does not move under the thumb | `AnimatedSwitcher` keyed by stage in `PvStoreScreen` |
| Hero band | Peeking neighbours (viewport 0.9), 5-second advance, cancelled for good on first touch, dots | Myntra's carousel; a carousel that keeps moving under a thumb is the thing people hate | `PvHeroBand` |
| Product page commit bar | Rises into place 380 ms after the page lands | Sephora's basket bar: read the product first, the ask second | `_stickyBar` TweenAnimationBuilder |
| Product page top buttons | Float over the gallery; on a white hairlined bar once the gallery scrolls away | never on top of the page's own text | `_topButtons` + scroll listener |
| Bag count | Pops (0.6 → 1, elastic) when it changes | the thing you did had an effect, visibly | `_Pop` in `PvRoundIcon` |
| Compare bar | Slides up on the first tick, drops away on clear | it arrives; it does not appear | `AnimatedSwitcher` in `_CompareBar` |
| Notices | White card with a hairline, lifted above the commit bar and the Ask pill | the user's call: an ink snack on an ink bar "looks like one" | `pvSnack` |
| Ask pill | Hidden on bag, checkout, placed, zoom | a commit bar owns that corner there | `global_ask_fab.dart` |
| Page push | Cupertino slide, app-wide (unchanged) | one transition everywhere — base UI | theme |

Not built, and deliberately: skeleton shimmer (the tinted well *is* the
placeholder and reads calmer than a shimmer); parallax on the hero (a
photo that moves against its words reads as an advert); bounce on scroll
ends (Android's stretch is right for Android).

## 2. Parked — needs a designer, a photographer or a brand

Each of these was seen and not faked. They are listed so they can be
briefed, in the order they would change the most.

1. **Product photography.** Every photo today is a free-licence Unsplash
   shot of the *object type*, captioned "Representative photo". Real
   product shots — white ground, three angles, one in-use — drop into
   `pv_product_extras.dart` per id, and the caption goes. The first shot in
   a source file always wins, so the swap is one line per product.
2. **Category marks.** The user, on the phone: the Material glyphs in the
   category wells (bedtime, spa, local_drink, toys…) are *"generic, bland,
   not fun to look at"*. The V3 doors already draw their own marks
   (`lib/screens/v2/v2_block_art.dart`, `v3_bracket_art.dart`,
   `v3_skill_art.dart`) — the same treatment for the ~19 store categories
   is a drawing task, not a code one. `PvCategoryTile.iconFor` is the one
   seam to replace.
3. **Hero slides as designed banners.** `PvHeroSlide` takes an image and a
   destination; a campaign or a launch (Brand Studio) becomes a slide with
   a real banner. Today's three are built from the catalogue so the band is
   never empty.
4. **Reviewer photographs and names.** The "Reviewed by" line carries seed
   names; the expert cards draw a placeholder circle. Real clinicians, real
   headshots, and the expert films the cards already know how to open.
5. **A brand mark on the Razorpay sheet.** Razorpay shows "P" in a square;
   it takes an `image` URL in the checkout options.
6. **The placed screen's illustration.** 7-Eleven's basket, Etsy's confetti:
   one line drawing of a parcel in the house style, above "Thank you".
7. **Sound and haptics.** A light haptic on add-to-bag and on the compare
   tick (`HapticFeedback.lightImpact`) is a one-line addition each, held
   back until the user says haptics belong in this app at all.
