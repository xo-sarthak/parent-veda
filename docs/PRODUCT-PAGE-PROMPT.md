# Claude Design prompt — the ParentVeda product page

Paste everything below the line into Claude Design. Everything above it is context
for whoever is running the prompt.

## Why this exists

The app already has **several different product pages** — `product_detail_screen.dart`
(parenting, trust-first), the Product Guide module, the pregnancy picks in
`product_data.dart` (best overall / budget / premium), the Recommendations engine's
detail, and the book detail. They disagree about what a product page is for. This
prompt is the brief for **one canonical page** that all of them become.

What already exists and must be honoured rather than redesigned:

| Thing | Where |
|---|---|
| `PpProduct` — name, brand, category, sub, rating, reviews, price, retailer, `verified`, `parentVeda`, `bestseller`, `summary`, `badge`, `bestFor` | `pp_products_data.dart` |
| `PpCompareStore` — compare tray, **max 2** | `pp_products_data.dart:1080` |
| The compare table, verdict last | `products_compare_screen.dart` |
| "The ParentVeda take", good / consider, "choose this if…", provenance-tagged reviews | `product_detail_screen.dart` |
| Sponsorship disclosure — *"Cetaphil funded this. They did not write it."* | `lib/brand/` |

---

# PROMPT STARTS HERE

## What you are designing

A **product page** for ParentVeda — an India-first, bilingual (English + Hindi)
companion app for parents, spanning trying-to-conceive → pregnancy → parenting.

Design **one mobile screen** (scrolling, full page) plus the states listed at the end.

## The one idea that makes this page different

**We are not a marketplace. We are the friend who already owns one.**

A marketplace's product page exists to reduce the friction between wanting and buying.
Ours exists to answer a different question, and it is the question a tired parent at
1am is actually asking:

> **"Do I need this, and is this one any good?"**

So the page carries everything a marketplace page carries — what it is made of, how to
use it, what is in the box, dimensions, age range, care instructions — **and then it
does the thing a marketplace will never do: it tells her not to buy it.**

That single capability is the whole product. Design the page so that a parent who lands
on it and reads only the first screenful has already got our answer.

## The anatomy, in order

Design it in exactly this order. The order is the argument.

### 1. The image, and the ribbon above it

The product photograph, edge to edge or near it, in a gallery she can swipe.

**Above the photograph** — in the position Amazon uses for "Amazon's Choice", and
deliberately borrowing that placement because parents already know what it means — sits
the ParentVeda mark. It is a small horizontal ribbon, **not** a floating sticker on the
image.

Three possible ribbons, and **exactly one always shows**:

- **`PARENTVEDA RECOMMENDS`** — our warm accent. Confident, not loud.
- **`PARENTVEDA SUGGESTS SOMETHING ELSE`** — a neutral, serious tone. **Not red, not a
  warning triangle, no alarm.** We are not condemning a product; we have a different
  answer.
- **`WE HAVE NOT LOOKED AT THIS ONE`** — quiet grey.

⚠️ **The third state is not optional and is the most important one to get right.**
Without it, the absence of a green ribbon reads as a silent "no" — and we would be
implying a judgement on every product we simply have not assessed. Design it so it reads
as *honest incompleteness*, not as disapproval.

### 2. The identity block

Name, brand, price (**always visible — never behind a tap, never "see price"**), the
star rating with review count, and the retailer with the affiliate relationship stated
plainly inline. Small, factual, unglamorous. This is the part that is allowed to look
like every other shopping app, because it is the part where she is checking facts.

### 3. THE VERDICT — the first real block on the page

Immediately under the identity block, before any specification, before any tab, before
anything she has to scroll for.

This is the largest, most confident block on the screen. Treat it as an editorial
callout — the way a good magazine sets a pull quote — not as a card in a stack of cards.

It contains:

- **The verdict in a sentence a person would actually say.** "Worth it, if she is a hot
  sleeper." "Skip it — a rolled towel does the same job."
- **Why.** Two or three short lines. The reasoning, not a score.
- **Who it is for and who it is not for.** ParentVeda's answers are conditional far more
  often than they are absolute, and the design must make a conditional answer look like
  a *confident* answer rather than a hedge.

**When the verdict is "something else":** the alternative appears **inside this block**,
as a small inline product row — image, name, price, one line of why-instead. Not a link,
not a "see alternatives" button, not a section further down.

⚠️ A page that says "we don't recommend this" and then leaves her to search again has
helped nobody. **The redirect is the recommendation.** Show one alternative, two at
most; a list of five is a marketplace again.

### 4. Everything a marketplace would tell her

Now, and only now, the specification. This is where the page becomes complete, and it
should feel like a reference section — dense, scannable, quiet.

Design a pattern that handles all of these without becoming a wall:

- **What it is made of** — materials, and for anything a baby mouths or wears, what it
  is *free of*
- **What is in the box** — components, parts, what you have to buy separately
- **How to use it** — real steps, and the mistake people make
- **Care** — washing, sterilising, replacing parts, how long parts last
- **Fit** — age range, weight range, dimensions, what it does not fit
- **The claims, checked** — where a brand makes a claim, whether there is anything
  behind it. This section is a large part of why she trusts the page. If a claim is
  marketing, say so.

Use collapsed sections or a spec table — your call — but the *first* line of each must
be readable without opening it. A parent who opens nothing should still leave informed.

### 5. Reviews — text and video, in one stream

Reviews are **provenance-tagged**: each one shows whether it is from a ParentVeda
parent, a verified purchaser, or aggregated from the retailer. That tag is not fine
print; it is how she weighs what she is reading.

**Video reviews are first-class, not an attachment.** Design them as a horizontal rail
of portrait thumbnails above the text reviews, each showing:

- a still with a duration
- who the parent is (first name, child's age at the time)
- **how long they used it** — this is the field that makes our reviews different from a
  marketplace's, where almost every review is written in week one

A video review card and a text review card must read as **the same class of object** in
two formats. Do not let the video rail look like an ad break.

Also design: what a review looks like when it disagrees with our verdict. **It must not
be buried or de-emphasised.** A page that only shows agreement is an advertisement, and
parents recognise one instantly.

### 6. Compare — a small floating button, bottom right

A compact FAB, bottom right, above the bottom nav. Tapping it adds this product to the
compare tray.

- It has **two states**: not-added, and added-with-a-count.
- **The tray holds a maximum of two.** When two are already in it, the button must say
  what will happen — replace, or go to the comparison — rather than failing silently.
- When one product is waiting, the button should quietly say so, so she knows a
  comparison is half-built.

Keep it small. It is a utility, not the page's call to action.

### 7. Buying, last

The buy row sits at the end, not pinned, not shouting. Price, retailer, and the
affiliate disclosure repeated where the money actually happens.

⚠️ **This is the deliberate inversion of a marketplace page and the thing most likely to
get "fixed" later.** On Amazon the buy button is pinned and permanent because the page
exists to sell. Ours exists to advise, and a pinned buy button would contradict every
word above it. **The verdict is the top of the page; the transaction is the bottom.**

## Rules that are not negotiable

These come from the product and are not style preferences:

1. **Prices are always visible.** Never behind a tap.
2. **Affiliate relationships are stated inline**, in plain words, at every point money is
   mentioned.
3. **Sponsored content is disclosed in the sponsor's own words** — the existing pattern
   is *"Cetaphil funded this. They did not write it."* A sponsored product must be
   visually indistinguishable from an unsponsored one **except** for that disclosure,
   and **sponsorship must never change the verdict ribbon.** Design the disclosure so it
   cannot be mistaken for a ParentVeda endorsement.
4. **No decorative emoji anywhere.** Line icons only.
5. **Never a diagnosis.** For anything safety-adjacent — car seats, sleep products,
   feeding equipment, anything medical — the page ends that section by routing calmly to
   a clinician, and never contradicts one.
6. **Bilingual from the first string.** English in Latin, Hindi in Devanagari. Long words
   in Devanagari run wider than their English equivalents — **every label, ribbon and
   button must survive roughly 30% more text without reflowing into something ugly.**
   Show at least the ribbon and the verdict block in both languages.
7. **No score out of ten, no percentage match, no "97% of parents".** We give reasoning,
   not ratings. The star rating in the identity block is the retailer's number, clearly
   attributed as theirs — it is a fact about the market, not our opinion.

## The register

Calm, plain, specific. Warm without being cute. The voice of someone who has used the
thing, is not being paid to like it, and respects the reader's time and intelligence.
This audience is an Indian parent who is being marketed at constantly and is very good
at spotting it.

Avoid entirely: urgency, scarcity, "trending", "must-have", badges that imply a
leaderboard, anything that turns caring for a child into a competition.

## Deliver

1. **The full page**, top to bottom, in the `PARENTVEDA RECOMMENDS` state.
2. **The verdict block in the other two states** — "suggests something else" (with its
   inline alternative) and "we have not looked at this one".
3. **The compare FAB** in all three of its states.
4. **The video review rail**, with one card open.
5. **A dense-specification section** as it looks fully expanded.
6. **The ribbon and verdict block in Hindi (Devanagari)** at the same widths.

Mobile first, 390pt wide. Show your type scale and palette.

# PROMPT ENDS HERE

---

# APPENDIX — the house palette and type. PASTE THIS TOO.

The first run came back in **warm cream, terracotta, Public Sans and Newsreader**. The
structure was right; the skin was not ours, and it is also the single most common
AI-generated design look there is — warm cream ground, serif display, terracotta accent
is a recognisable default, not a choice.

ParentVeda's palette is **already decided** (decision D8, 2026-08-15) and is not open in
this exercise. Use exactly this.

## Palette — use these values, do not reinterpret them

| Token | Hex | Use |
|---|---|---|
| `ground` | `#F3EEF7` | the page. A cool lavender-tinted neutral, **not** cream |
| `surface` | `#FFFFFF` | cards |
| `surfaceAlt` | `#ECE5F2` | quiet blocks, spec rows, disclosure strips |
| `line` | `#00000014` | hairlines (8% black) |
| `ink1` | `#201C24` | headings and the verdict sentence |
| `ink2` | `#5B5464` | body |
| `ink3` | `#8B8494` | labels and metadata — **never on a tinted ground** |
| `action` | `#6A30B6` | the one accent. Violet |

⚠️ **`action` is the ONLY saturated colour on the page.** No second accent, no terracotta,
no gradient. Section eyebrows are `action`; that is what makes the page ours at a glance.

**The three verdict ribbons** derive from this palette rather than introducing colours:

- **Recommends** — `action` at full strength, white text.
- **Suggests something else** — `ink2` on `surfaceAlt`. Serious, not alarmed. **No red, no
  orange, no warning glyph.** We are not condemning the product.
- **Not looked at** — `ink3` on `surfaceAlt`, hairline border, no fill.

## Type — three families, and Hindi is a fourth

| Role | Family | Notes |
|---|---|---|
| Display | **Fraunces** | the verdict sentence, product name, section titles. Weight 600, tight tracking (about −0.5) |
| Labels | **Manrope** | eyebrows, ribbons, prices, metadata. Weight 700–800, letter-spacing about 1.4 on uppercase |
| UI | **Plus Jakarta Sans** | buttons, chips, dense specification rows |
| Hindi | **Noto Sans Devanagari** | not Mukta, not Tiro — the app renders Hindi in Devanagari and this is the face it uses |

No other families. Body copy is Manrope at 13.5–14 with line-height about 1.5.

## Shapes

Rounded, generous: **20px** on cards, **999px** on chips, pills and the ribbon, **12–16px**
on thumbnails. Borders are one hairline of `line`, never two. One soft shadow at most, and
only where something genuinely overlaps something else.

## What to keep from the first run

The anatomy was right and should not be re-litigated: ribbon above the photograph,
identity block, **verdict as the first real block with the alternative inline**, the
specification, reviews with provenance and duration-of-use, compare FAB, buy row last.
Keep the dissent tag, the sponsor disclosure wording, and the clinician line.

**Only the skin changes.** Re-render the same page in the palette and type above.
