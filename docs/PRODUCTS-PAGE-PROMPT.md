# Claude Design prompt — the unified ParentVeda products page

> **Paste everything between PROMPT STARTS and PROMPT ENDS, plus the appendix.**
>
> Companion to `docs/PRODUCT-PAGE-PROMPT.md`, which covers a **single product**.
> This one covers the **shop** — browse, search, decide, compare.
>
> It exists because the app currently has **seven** product surfaces
> (`products_screen`, `products_discovery_screen`, `products_category_screen`,
> `products_subcategory_screen`, `products_compare_screen`, `product_guide/`,
> `pp_products_data`) answering about three questions. This is the one page that
> replaces them.

---

# PROMPT STARTS HERE

## What you are designing

**One mobile page, 390pt wide, that is ParentVeda's entire shop.** Browse,
search, guidance, and the way into comparing two things. Indian audience,
mostly women aged 24–36, on a mid-range Android phone, often one-handed, often
tired, often at 11pm.

They already shop on Amazon, Flipkart, Myntra, Nykaa, Zepto. **Their instincts
are set.** Fighting those instincts to look principled would just make the page
slow to use. So this page must feel *immediately* familiar — and behave
differently in the two or three places where it counts.

---

## The one idea

**A shopping app's craft and its manipulation are separable. Take the craft.
Refuse the manipulation.**

What makes Myntra and Zara feel good: speed, confident photography, filtering
that never makes you think, a price you can always see, and getting out of the
way.

What makes them feel bad: countdown timers, "only 2 left", "18 people are
viewing this", an inflated strikethrough price, and a total you don't learn
until checkout.

Those are not the same thing. **The first list is 90% of why those apps convert.
The second list is why people don't trust them.** Build the first. Refuse the
second, visibly.

---

## Three things we can do that no marketplace can

Lean on all three. They are the page's whole reason to exist, and each one is
already in our data.

### 1. We can say **"don't buy this"**

Amazon structurally cannot. Every product in our data carries `consider[]` — up
to two honest caveats — and every category carries `avoid[]`. There is real
copy in the app already: *"We mostly breastfeed, so it sat unused — would skip
it."*

**Put a caveat on the card itself, not buried in the detail page.** A grid where
some cards say "skip this if…" is unlike anything she has used, and it is the
fastest possible proof that we are not just another shelf.

### 2. We can say **"not yet"**

The app knows her week, or her child's age. Categories carry `fromWeek` and
`relevantAt(week)`. A marketplace shows everyone the same shelf.

So the page can separate **useful now** from **not yet** — and "not yet" is a
kindness, not a hidden product. A first-time mother in week 12 being told *"a
breast pump is a week-32 decision, come back"* saves her money and buys more
trust than any recommendation.

### 3. We can say **"nothing here is worth buying"**

If a category has no product we would stand behind, say so, and give her the
`lookFor` / `avoid` list anyway so she buys well elsewhere. **Design this state
deliberately** — it is the single most trust-building screen in the whole shop,
and no competitor can copy it.

---

## What to take, and from where

Be specific. These are the patterns that work, and why.

**Myntra / Ajio — filtering.** A sort-and-filter bar that **sticks to the top
once she scrolls**, and a filter sheet with a count beside every option so she
never taps into an empty result. Best-in-class for a large catalogue. Also their
**two-column grid with tall cards** — the right density for a phone.

**Zara / H&M — restraint and imagery.** Full-bleed product photography,
generous whitespace, almost no chrome, product as hero. Zara is the closest
commercial cousin to our design language: quiet, confident, editorial.

**Amazon — density done well.** Price, rating count and the decisive fact all
above the fold, no hunting. And **search as a real field at the top**, not an
icon — because "I need a specific thing" is the most common arrival.

**Nykaa / Sephora — reviews with a filter.** "Show me reviews from people like
me." Our review model already carries `role` ("Mother of Aarav", "First-time
mother") and `usedDuring` ("Week 22 → Delivery"), which is *better* raw material
than a star count.

**Zepto / Blinkit — the sticky bottom bar.** Cart total always visible, no
surprise at the end. Speed as a feature.

**IKEA — guidance before purchase.** Their "measure your space first" is exactly
our `lookFor` / `avoid` per category. Guidance is not a blog post bolted on; it
is part of buying well.

---

## What to refuse — and let the refusal show

Do not draw any of these, at all:

- countdown timers, "sale ends in", "only 2 left", "18 people viewing"
- an inflated MRP strikethrough to fake a discount
- a pop-up or interstitial on open
- infinite scroll with no sense of how much is left
- "You might also like" that is just more of everything
- any login wall before browsing
- a star rating with no substance behind it

**One place to make the refusal visible:** where a competitor would put urgency,
put honesty. A small line under the price that says what it usually costs
elsewhere, or nothing at all. Empty space is better than manufactured pressure.

---

## The anatomy, in order down the page

### 1. Search, first and real

A proper input field, full width, at the top. Placeholder names a real thing
("bottle steriliser", "stretch mark oil"), not "Search products". Recent and
common searches below it when focused.

### 2. "Useful for you now" — one horizontal rail

3–4 cards, keyed to her week or her child's age, each with **one line saying why
this, now** ("Week 34 — most mothers pack this"). This is the only
personalisation on the page, and it changes *ranking*, never what exists.

### 3. Browse — the guidance layer

Category tiles, but each one carries a **decision line**, not just a name:
*"Prams — the two things that decide it are boot size and kerb weight."* Tapping
a category opens its guidance sheet (`lookFor` ✓ / `avoid` ✗) **before** the
grid, with a clear way straight through to the products for someone who already
knows.

### 4. The shelf — two-column grid

The main body. Tall cards, generous image, and **the sticky filter/sort bar
appears here** as she scrolls in.

### 5. "What we would skip" — a real section

Not a footnote. Products or whole categories we do not think are worth it, with
one line each. Some of it should be funny-honest rather than clinical.

### 6. Compare — floating, contextual

A small floating button, bottom-right, that **only appears once two items are
selected** and says "Compare 2". Max two. Never a permanent bar.

### 7. Cart bar — sticky, only when there is something in it

Item count and running total, always visible, never a surprise.

---

## The card — design this hardest

The grid card is the page. Everything above is scaffolding for it. It carries,
in this order:

1. **Photo**, filling the card's width, ~4:5. Real product photography, plain
   background, no lifestyle clutter.
2. **Name**, two lines maximum, Manrope 13.5/600.
3. **Price**, always. Never "see price", never "from". Tabular numerals.
4. **One decisive line** — from `why[0]` or `bestFor`. Not a category, not
   marketing. *"Fits a 4-door hatchback boot."*
5. **A quiet trust mark** — either the badge or the ParentVeda score. **Not a
   star row.** A score out of 10 with our name on it means we stand behind it;
   stars mean strangers averaged their moods.
6. ⚠️ **The caveat, when there is one.** From `consider[0]`. Small, in `ink3`,
   prefixed plainly: *"Skip if you already have a sling."* **This is the single
   most distinctive element on the page. Do not hide it, and do not make it
   look like a warning** — it is helpfulness, not an alarm.
7. **A select control for compare**, quiet until used.

Design three states of this card side by side: **recommended · has a caveat ·
not yet relevant.** The third should look calm and unavailable-for-now, never
greyed-out-broken.

---

## The affiliate fork — design it, don't hide it

Products carry `isAffiliate`. Affiliate items open Amazon or Flipkart and have
no in-app cart; ours have Add to cart and Buy now.

**Say so on the card and on the button.** "Buy on Amazon ↗" is more trustworthy
than a generic Buy that surprises her, and disclosing that we earn a commission
is exactly the promise that we do not pitch before we price. Make it a small,
matter-of-fact line — not a legal disclaimer, and not hidden in a footer.

---

## Rules that are not negotiable

1. **The price is always visible.** On every card, every rail, every state.
2. **Nothing is hidden behind a login.**
3. **No urgency, ever.** Not a timer, not a stock count, not a viewer count.
4. **The caveat is as prominent as the praise.** If a design decision makes
   `consider[]` smaller than `why[]`, the decision is wrong.
5. **Never a card inside a card.**
6. **Empty and no-recommendation states are designed, not omitted.**
7. **No decorative emoji.** Line icons only.
8. **A product never appears near a loss, infertility or IVF context.** If you
   are designing a cross-link, it does not go there.

---

## ⚠️ The one place a filled violet button is correct

Our design system bans filled violet buttons everywhere. Its stated reason is:
*"a filled button is the loudest thing on a page, so it decides what the page is
for — and ParentVeda screens are almost never about their button; the content
is."*

**On a product page, the page IS about the button.** So the rule's own logic
permits it here, and this is the only place in the app where it does.

- **Buy / Add to cart: filled `#6A30B6`, white label, radius 999, height 48.**
- **Everything else on the page stays an outlined pill.** Filter, sort, compare,
  "see guidance" — all outlined.

If two filled violet buttons ever appear on one screen, one of them is wrong.

## Semantic colour, and what it is not

A shop needs good/caution/avoid, and **none of them may be the brand violet** —
violet means "you can act on this", and re-using it for "this is good" destroys
both meanings.

- `#2E6B4F` — recommended, in stock, would-buy-again
- `#B3261E` — **avoid, and only avoid.** Never for urgency, never for a sale.
- `ink3` `#8B8494` — the caveat. Deliberately not red. A caveat is information,
  not a warning.

---

## The register

Plain, specific, unhurried. Never breathless.

| Write this | Not this |
|---|---|
| "84% would buy it again" | "Loved by thousands!" |
| "Skip if you already have a carrier" | "Not recommended" |
| "₹1,899 · usually ₹1,900–2,400 elsewhere" | "₹1,899 ~~₹3,499~~ 46% OFF" |
| "A week-32 decision. Come back nearer." | "Coming soon" |
| "We have not found one worth recommending." | (silence, or a weak pick) |
| "Fits a 4-door hatchback boot." | "Premium travel system" |

Short sentences. No exclamation marks. Never tell her she deserves something.

---

## Deliver

Mobile, **390pt**, our palette and type from the appendix:

1. **The page, top to bottom** — search, "useful now" rail, guidance-led
   categories, the grid.
2. **The same page mid-scroll**, with the sticky filter/sort bar engaged and the
   cart bar showing.
3. **The card, three states, enlarged side by side** — recommended · has a
   caveat · not yet relevant.
4. **The filter sheet**, with per-option counts.
5. **The category guidance sheet** — `lookFor` ✓ / `avoid` ✗ — and the route
   straight to products.
6. **The "nothing here is worth buying" state.**
7. **A short note on your type scale and spacing**, so drift is visible before
   it becomes code.

Show your reasoning for anything you deliberately took from a named app, and
anything you refused.

# PROMPT ENDS HERE

---

# APPENDIX — the house palette and type. PASTE THIS TOO.

## Colour

| Token | Hex | Use |
|---|---|---|
| `ground` | `#F5F3F6` | the page. Near-neutral, cool-leaning. **Never cream.** |
| `surface` | `#FFFFFF` | cards |
| `surfaceAlt` | `#EDEAF0` | quiet blocks, spec rows, guidance sheets |
| `line` | `rgba(0,0,0,0.08)` | hairlines |
| `ink1` | `#201C24` | product names, prices, headings |
| `ink2` | `#5B5464` | body |
| `ink3` | `#8B8494` | metadata, **caveats** |
| `action` | `#6A30B6` | section eyebrows, links, **and the buy button** |
| `success` | `#2E6B4F` | recommended / in stock |
| `danger` | `#B3261E` | avoid only. Never urgency. |

⚠️ **A brand colour is not an interface colour.** The ground carries the brand
hue at ink-level saturation (16%), not brand saturation. It reads as neutral.
Do not warm it, do not saturate it, do not make it cream.

Category tints come from one controlled wheel: **fixed saturation 32%,
lightness 91%, only the hue varies.** Never hand-pick a tint.

## Type — two families

**Fraunces** (display serif) — section headings, the product name on a detail
page, the one big fact.
**Manrope** — everything else: card names, prices, body, labels, eyebrows,
buttons.

| Role | Family | Size | Weight | Tracking |
|---|---|---|---|---|
| `title1` | Fraunces | 27 | 600 | −0.6 |
| `title2` | Fraunces | 22 | 600 | −0.5 |
| `cardTitle` | Fraunces | 16.5 | 600 | −0.35 |
| `body` | Manrope | 14 | 400 | — |
| `bodySm` | Manrope | 13 | 400 | — |
| `label` | Manrope | 12.5 | 600 | — |
| `eyebrow` | Manrope | 11 | 800 | +1.4 |
| `chip` | Manrope | 9.5 | 800 | +1.1 |

Nothing between these sizes. Prices use tabular numerals. Body never below 13.

## Spacing, radius, shadow

- **4-point base, six steps only:** 4 · 8 · 12 · 20 · 28 · 40
- **Page padding 18 horizontal, everywhere.**
- **Radius:** 28 sheets · 20 cards · 18 rows · 16 blocks · 14 wells · 999 pills
- **Shadow tinted to the ground — `#D0C8DC`, never black.** Soft, low opacity,
  high blur. If the shadow is the first thing you notice, it is wrong.

## The signature

A small upper-case **section eyebrow in `#6A30B6`** above each section heading,
Manrope 11/800, +1.4 tracking. It is the most recognisable thing in the app.
Name sections for what she gets — **"WHAT WE WOULD SKIP"**, not "PRODUCTS".
