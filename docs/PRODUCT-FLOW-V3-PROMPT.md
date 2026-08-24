# Claude Design prompt — the ParentVeda product flow (V3)

> **Supersedes `PRODUCT-PAGE-PROMPT.md` and `PRODUCTS-PAGE-PROMPT.md`.** Those
> two briefed one page each and were generated separately, which is exactly how
> the app ended up with parallel product surfaces that disagree. This prompt
> asks for **all three screens in one generation** so they cannot drift.

## Why this exists (context — do not paste)

The app currently ships **five** product detail pages and **four** browse
surfaces:

| Surface | File |
|---|---|
| Guide hub — "What do I actually need?" | `product_guide/product_guide_hub_screen.dart` |
| Guide detail — **the page we are keeping the bones of** | `product_guide/product_guide_screen.dart` |
| Marketplace home / categories | `post_pregnancy/products_discovery_screen.dart` |
| Marketplace category | `post_pregnancy/products_category_screen.dart` |
| Marketplace subcategory | `post_pregnancy/products_subcategory_screen.dart` |
| Marketplace detail | `post_pregnancy/product_detail_screen.dart` |
| Recommendations detail | `post_pregnancy/reco_detail_screen.dart` |
| Pregnancy picks | `screens/products_screen.dart` |
| TTC products | `screens/ttc/ttc_products_screen.dart` |

**Three screens replace all nine — as a design, not as one widget tree.**

⚠️ `STILL-OPEN.md` §"The product template across both apps" already settled the
code question the other way, and it stands: the pregnancy and parenting product
pages are **deliberately not the same code**. The pregnancy one carries a cart,
a checklist, affiliate rules and a week timeline that mean nothing after birth;
merging them would be a rewrite of a shipped stage. What a parent experiences as
"a different template" is the **section names and their order**, and those are
already aligned.

So this prompt produces **one visual language and one component set**, adopted
by each stage's existing screens. Pregnancy keeps its week timeline and its
cart — a page losing something useful in order to match another page is
consistency bought at the wrong price.

**Taxonomy decision made for this prompt:** the six categories in
`pp_products_data.dart` win, because they are the only ones with a real second
level. The four Guide categories (`Baby skincare`, `Diapering`, `Feeding`,
`Baby gear`) fold in as subs. A product may carry a Guide; a Guide is not a
separate place.

**Data that must survive unchanged** — the screens wire to these field names, so
the design must not invent a field that has no source:

| Field | From |
|---|---|
| `name · brand · category · sub · rating · reviews · price · retailer` | `PpProduct` |
| `verified · parentVeda · bestseller · badge · bestFor · summary · pros[] · cons[] · specs{}` | `PpProduct` |
| `pvScore · parentsPct · expertsPct` | `PpProduct` / derived on `ProductGuide` |
| `reco` band + `signal` (STRONG BUY · BUY · CONSIDER · SITUATIONAL · SKIP) | `PgRecoX` |
| `verdict · beforeYouBuy · bestFor[] · whyLike[] · watchOut[]` | `ProductGuide` |
| `experts[] · experiences[] (starred, named, context) · ingredients[] (note + caution) · studies[] (summary + meaning + source + byMaker)` | `ProductGuide` |
| compare tray, **max 2** | `PpCompareStore` |

---

# PROMPT STARTS HERE

## What you are designing

**Three connected mobile screens, 390pt wide**, for ParentVeda — an India-first,
bilingual (English + Hindi) companion app for parents.

1. **Categories** — what are we shopping for?
2. **Subcategory** — the shelf: real options, ranked, filterable.
3. **Product** — the decision page.

Design them as **one flow on one canvas**, left to right, so the shared
components are literally the same components. Then the states listed at the end.

Some sections already have fixed names, in use across the app. **Use these
exact names** rather than inventing better ones — they are what makes two
different stages read as one product: *At a glance · ParentVeda's take · From
verified parents · Compare with alternatives · How ParentVeda reviews this*.

Audience: mostly women 24–36, mid-range Android, one-handed, often at 11pm,
often tired. They already shop on Amazon, Flipkart, Nykaa, Zepto and Myntra.

## The one idea

**A shopping app's craft and its manipulation are separable. Take the craft.
Refuse the manipulation.**

Their instincts are already set, and fighting those instincts to look principled
only makes the app slow to use. So the *skeleton* must be boringly familiar —
breadcrumb, image, price, rating, filter and sort, sticky buy bar, "related".
A parent should never have to learn where anything is.

What we refuse, visibly: countdown timers · "only 2 left" · "18 people are
viewing this" · inflated strikethrough prices · a total you learn at checkout ·
an infinite related-product tail.

What we add that no marketplace can:

1. **We can say "don't buy this."** Every product carries honest caveats, and a
   whole recommendation band reads **SKIP**. That band is a first-class element,
   not fine print — it is visible on the shelf, not one tap deeper.
2. **A "before you buy" line above the sell.** One sentence, e.g. *"Not every
   baby needs a daily moisturiser — this is most useful for dry or sensitive
   skin, or in winter."* It sits **between the hero and everything else**, and
   it is the single most ParentVeda thing on the page.
3. **Provenance on every claim.** Reviews are named parents with the child's age
   and the season, never anonymous. Research is summarised in plain language
   with its source shown, and a manufacturer's own trial is *labelled as such*
   and ranked below independent work.

---

# SCREEN 1 — Categories

The answer to "what am I shopping for?", not a storefront.

Top to bottom:

- **Search bar** — full width, radius 14, placeholder *"Search lotion, diapers,
  stroller"*. Tapping search is a moment of intent: show recent searches and a
  few popular items. Never a blank box.
- **One personalised strip**, if and only if we know the child's age:
  *"For a 7-month-old"* → three real product cards, horizontal. Not a banner
  that must be tapped — show the actual products.
- **The six categories** as **fully tinted rows** (one hue each, from a single
  controlled wheel — fixed saturation and lightness, only the hue varies):
  Sleep · Skincare · Feeding · Play & Development · Health & Safety · On the
  move. Each row carries a **drawn mark** in its hue (not a photo, not a stock
  icon), the category name, a one-line promise, and the sub names as quiet text
  — *"Soothers · Sleepwear · Bedding"*. Chevron in a white circle.
- **One quiet entry to Compare** — a row, not a hero card. Comparing is a step
  inside researching, not a separate tool you go and find.

**No heading that says "Categories".** Name a section for what she gets, never
for our filing system.

---

# SCREEN 2 — Subcategory (the shelf)

Reached from a category row, or straight from search.

- **Breadcrumb**, tappable: `Sleep › Soothers & white noise`.
- **What to look for** — two or three lines, `surfaceAlt`, radius 16, no border.
  This is the shelf's guidance and it sits **above** the products. It may
  include what to skip entirely.
- **Filter + Sort bar** — a **Filters button that opens a full sheet** (brand,
  price, rating, age), plus a sort control. Marketplace convention, exactly as
  they expect it. Active filters appear beneath as removable chips.
- **The product grid**, two columns. Each card:
  - product photo, radius 14, with an honest hatch block when no photo exists;
  - **name** (Manrope, two lines max) and brand;
  - **price, always visible**, tabular numerals;
  - rating + review count;
  - **one badge at most** — `PARENTVEDA PICK` · `VERIFIED` · `BESTSELLER`;
  - a **recommendation dot + band** wherever a Guide exists, so *"Generally not
    needed"* is readable on the shelf;
  - a **compare tick** in the corner. Two ticks raise a bottom "Compare 2" bar.
- **Show the count and the ranking**: *"9 products · ranked by how well they
  suit a 7-month-old"*. Say what the order is. Never a hidden sponsored order.

Design the **no-results** case too: acknowledge the query, suggest a fix, offer
a way out.

---

# SCREEN 3 — Product page

**Keep this page's existing anatomy — it is the part of the app the team likes.
The job is to re-dress it in V3, not to reorganise it.** Above the fold answers
one question in about ten seconds: *is this right for my child?*

### Above the fold
1. **Breadcrumb** `Skincare › Lotions`, then the **product image** (230pt tall,
   radius 22), with a thumbnail rail *only when more than one shot exists*.
2. **Brand, then name** — the name in Fraunces, the largest type on the page.
3. **Recommendation band** — a coloured dot plus its label (`Highly
   recommended` … `Generally not needed`).
4. **Verdict** — twenty words at most, one sentence.
5. **At a glance** — the score card: `pvScore /100` as the large fact, with two supporting
   percentages — *% of parents who would recommend it* and *% of experts who say
   buy* — plus a small up/down vote pair. Label small and above, value large and
   below, never the reverse.
6. **Best-for chips.** A chip matching something we already know about her child
   (eczema, winter, 6-month-old) is marked — a soft hue fill and a tick, never a
   different shape.
7. **Buttons**: `Compare` (outlined pill) and `Buy now` (the one permitted
   filled pill, `ink1`, never violet). The price sits with them, always visible.

### Then, in this order
8. **Before you buy** — one honest sentence in a tinted block under an eyebrow.
   Nothing may come between the hero and this.
9. **ParentVeda's take** — two blocks: **What's good** (success hue) and
   **Worth considering** (amber). When there is genuinely no caveat, say so in words —
   never leave an empty column.
10. **A progressive-disclosure divider** — a hairline with `EXPLORE MORE, IF YOU
    WANT TO` set into it. Everything below is optional.
11. **An expert explains** — one or two cards: role, name, a one-line hook,
    duration, play affordance. A card with no video says so plainly and is not
    tappable.
12. **From verified parents** — the average, two or three quotes, each with a
    name, a star count and *context* (`Winter · 4-month-old`), then `See all 12
    ratings →`. Design the **all-ratings sheet** with sentiment and star filters.
13. **What's inside** — each key ingredient: name, purpose, why it is good, and
    an honest caution where a real one exists. Never a full INCI dump.
14. **The research, in plain language** — per study: topic, plain summary,
    *"what this means for you"*, the source, and a `read more`. A manufacturer's
    own trial carries a visible label.
15. **Specs** — a plain label/value sheet, category-appropriate, `surfaceAlt`
    rows, no card around each row.
16. **Compare with alternatives** — three, horizontal. Never an infinite tail.
17. **How ParentVeda reviews this** — a collapsed row that opens our method:
    what we test, what we refuse, and who pays. It belongs on every product page
    in the app, and it is the section a sceptical parent opens first.
18. **Ask Veda row** — *"Still deciding?"* One row in our accent, opening the
    assistant pre-loaded with this product.
19. **The disclaimer line**, centred, `ink3`, small.

### Two overlays to design
- **The buy interstitial.** We say plainly that this is an affiliate link, that
  we may earn a small commission at no extra cost, **and that it never changes
  what we recommend or how we rate a product.** Two actions: continue, or stay
  here. That last sentence is the whole reason a trust-first page is allowed to
  carry a Buy button at all.
- **Sponsorship disclosure**, where a section is funded: *"Cetaphil funded this.
  They did not write it."* Quiet, never hidden.

### Sticky element
A **bottom bar that appears on scroll** carrying price + Buy — the one
marketplace convention we keep wholesale. It sits above the home indicator and
must not collide with the floating assistant button.

---

# THE DESIGN LANGUAGE — V3

This is a real, shipped system. Follow it exactly, and **show your type scale on
the canvas** so drift is visible before it becomes code.

### The four structural ideas
1. **The background belongs to the page, not to a section.** The tinted field
   fills the screen and does **not** scroll; content is a sheet that slides over
   it, radius 28 at the top, with one soft upward shadow. A hero is never a
   coloured box at the top of the page.
2. **You overlap, you do not fade.** Depth is a card edge, never a gradient —
   two flat regions meeting always shows a seam.
3. **Information is the hero, not decoration.** The top of a screen carries one
   large true fact — a score, a count, a price — not an illustration.
4. **Colour is spent, not sprinkled.** One accent, one hue per meaning, and
   pastel wells carry the variety.

### Colour

| Token | Hex | Use |
|---|---|---|
| `ground` | `#F5F3F6` | the page. Near-neutral, cool-leaning, **never cream** |
| `surface` | `#FFFFFF` | cards |
| `surfaceAlt` | `#EDEAF0` | quiet blocks, spec rows, facts |
| `line` | `rgba(0,0,0,0.08)` | hairlines |
| `ink1` | `#201C24` | product names, prices, headings |
| `ink2` | `#5B5464` | body |
| `ink3` | `#8B8494` | metadata, chevrons |
| `action` | `#6A30B6` | **section eyebrows and links only** |
| `success` | `#2E6B4F` | a passed check, what's good |
| `danger` | `#B3261E` | destructive confirmation only — never urgency |

The rules that get ignored, and must not be:
- **No filled violet buttons, anywhere.** Buttons are outlined pills:
  transparent fill, `line` border 1.2, height 44, radius 999. The border is what
  says "button". Exactly one filled pill is permitted per flow, for a genuine
  commit action, and it is **`ink1`, not violet**.
- **`action` is the only saturated colour**, spent on section eyebrows and
  links. Never a background, never a card fill, never a chevron.
- **Chevrons and row affordances are `ink3`.**
- **Anything sitting on the tinted field moves one ink tier darker** — a grey
  loses contrast against a chromatic ground far faster than a neutral one.
- **Shadows are tinted to the ground — `#D0C8DC`, never black.** Soft, low
  opacity, high blur. If the shadow is the first thing you notice, it is wrong.
- **Cards do not nest.** A bordered card inside a bordered card is padding on
  padding. Group with white space instead.
- **60/30/10**: `ground` + `surface` are the 60, `surfaceAlt` and the pastel
  wells are the 30, `action` is the 10.

### Type — two families, nine sizes, nothing between them

**Fraunces** (display serif) for headings, card titles and the one big fact.
**Manrope** for everything else — body, labels, eyebrows, buttons, prices.

| Role | Family | Size | Weight | Tracking | Line height |
|---|---|---|---|---|---|
| `display` | Fraunces | 42 | 600 | −1.3 | 1.05 |
| `title1` | Fraunces | 27 | 600 | −0.6 | 1.15 |
| `title2` | Fraunces | 22 | 600 | −0.5 | 1.20 |
| `title3` | Fraunces | 20 | 600 | −0.45 | 1.22 |
| `cardTitle` | Fraunces | 16.5 | 600 | −0.35 | 1.25 |
| `body` | Manrope | 14 | 400 | — | 1.55 |
| `bodySm` | Manrope | 13 | 400 | — | 1.45 |
| `label` | Manrope | 12.5 | 600 | — | 1.35 |
| `eyebrow` | Manrope | 11 | 800 | +1.4 | 1.0 |
| `chip` | Manrope | 9.5 | 800 | +1.1 | 1.0 |

Body never below 13. Prices use tabular numerals. Negative tracking on anything
above 20px is not a preference — it is what makes large type look professional.

### Spacing and radius

4-point base, **six steps only**: 4 · 8 · 12 · 20 · 28 · 40.
Page padding **18 horizontal, everywhere, no exceptions.**
Radius: 28 sheets · 20 cards · 18 rows · 16 blocks · 14 wells · 999 pills.
Nothing small goes below 14.

### The signature
A small uppercase **section eyebrow in `#6A30B6`** above each section heading
(Manrope 11/800, +1.4 tracking). It is the most recognisable thing in the app
and it must never be grey. Name sections for what she gets — **"WHAT WE'D
SKIP"**, not "PRODUCTS".

### Art
Category marks are **drawn**: one filled shape in the category's hue with the
detail knocked out in white — not stock photos, not a mixed icon set. Product
photography is real product photography on a plain field. **No decorative emoji
anywhere.** Icons are Material rounded, one weight, sized to the line-height of
the text beside them (16–20).

---

# ALSO DESIGN THESE STATES

- Subcategory: **loading** (skeletons, not spinners) and **no results**.
- Product: **no photo yet** (an honest hatch block, never a broken image), **no
  research yet**, **no reviews yet** — each stating what it will hold rather
  than saying "coming soon", and none of them tappable.
- Product: the **all-ratings sheet** with its filters.
- The **buy interstitial**.
- The **compare tray** holding two items, with its "Compare" bar.
- Every button in **default · pressed · disabled · loading**.

---

# THE CHECK, BEFORE YOU HAND THIS BACK

- [ ] The tinted field fills the page and does not scroll; content is a sheet over it
- [ ] Every type size is on the list of nine, and the scale is shown on the canvas
- [ ] Every gap is one of the six
- [ ] No filled violet button anywhere; the one filled pill is `ink1`
- [ ] Section eyebrows are `#6A30B6`
- [ ] Chevrons are `ink3`; shadows are tinted, never black
- [ ] No card inside a card
- [ ] No section named after our filing system
- [ ] Price is visible on the shelf, on the card, and on the sticky bar
- [ ] A product we would not recommend is visibly not recommended on the shelf
- [ ] No countdown, no scarcity, no view counter, no inflated strikethrough
- [ ] The three screens share one card, one chip, one button, one eyebrow
- [ ] It would still be right if she were tired, and it were 11pm

# PROMPT ENDS HERE
