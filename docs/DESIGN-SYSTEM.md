# ParentVeda Design System — V3

**This file is the design language. Every new screen inherits it. When this file
and a screen disagree, the screen is wrong.**

It exists because the app currently contains **four** design systems and reads as
three different products wearing one logo. V3 is the one we keep. Everything else
migrates to it.

> **The one rule:** a user should never be able to tell which part of the app was
> built when.

**Companion file: `UX-PRINCIPLES.md`** — the reasoning, the audience, and what we
learned from the reference material. *That* file is why these values are what
they are. Read it first in a fresh session; build from this one.

---

## 0. How to use this

| You are… | Read |
|---|---|
| building a new screen | §2 Foundations · §4 Components · §6 Anti-patterns |
| reviewing a screen | §6 Anti-patterns, then §5 Patterns |
| deciding a layout | §5 Patterns |
| drawing an icon | §3 The art system |
| migrating an old screen | §7 Migration |

**Nothing here is decorative.** Every rule below is either a decision with a cost
attached or a defect we have already shipped once.

---

# 1. WHAT V3 IS

V3 is not a colour scheme. It is four structural ideas, and a screen that keeps
the colours but drops these is not V3.

### 1.1 The background belongs to the page, not to a section

A hero is not a coloured box at the top. The tinted field **fills the screen and
does not scroll**; content is a sheet that slides over it.

This is the single highest-leverage idea in the system, and it was learned the
expensive way: three attempts to "blend" a hero into the page all failed, because
**two flat regions meeting always show a seam** — edge detection is the thing
human vision is best at. Real apps do not blend. They use one surface and overlap.

It also fixes a bug nobody diagnosed for weeks: colour "disappearing on scroll"
was a 302px box scrolling away.

```
Stack
 ├ Positioned.fill  → V3HeroField        (does not scroll)
 └ ListView
    ├ hero type     (no background of its own)
    └ Sheet         (ground, radius 28 top, shadow up)
```

### 1.2 You overlap, you do not fade

Depth comes from a card edge, never a gradient. The sheet's rounded top plus one
soft upward shadow is what reads as "smooth".

### 1.3 Information is the hero, not decoration

The top of a screen carries **one large true fact** — a week, an age, a cycle
day, a count — plus one short forward line. A drawing is identical every morning;
a number is not.

⚠️ **Never start at zero.** "0 weeks" shipped for a fortnight and was the same
failure as a mood: a unit that does not move. The unit follows the value — days
while days are what she counts, weeks once weeks are, months after. *(Research
calls this the goal-gradient effect: people move faster the closer the finish
feels, and a progress display that starts at zero reads as "you have not
started".)*

### 1.4 Colour is spent, not sprinkled

One accent (`action`), one hue per meaning, and pastel wells carry the variety.
A screen that has spent its budget on hue wells must not also have violet
buttons.

---

# 2. FOUNDATIONS

## 2.1 Colour

The palette is `_baseline` in `v2_palette.dart`. **Settled 2026-08-15. Not open.**

| Token | Hex | Use |
|---|---|---|
| `ground` | `#F5F3F6` | the page. Near-neutral, cool-leaning, **never cream** |
| `surface` | `#FFFFFF` | cards |
| `surfaceAlt` | `#EDEAF0` | quiet blocks, facts, placeholders |
| `line` | `#00000014` | hairlines — 8% black |
| `ink1` | `#201C24` | headings, the one fact |
| `ink2` | `#5B5464` | body |
| `ink3` | `#8B8494` | metadata, chevrons |
| `action` | `#6A30B6` | **section eyebrows, and links.** The only saturated colour |

### ⚠️ (0) BRAND COLOUR IS NOT INTERFACE COLOUR — SETTLED 2026-08-16, SHIPPED

Full reasoning in `UX-PRINCIPLES.md` §5.0. Short version: Zepto is a purple
company with an almost colourless app. That is the correct answer, not a
compromise — a painted page kills the accent's signalling power, contaminates
every photograph, and locks you out of category hues and semantic colour.

**Our inks already did this correctly. Our surfaces did not.**

| Token | Hue | Saturation | |
|---|---|---|---|
| `ink1` / `ink2` / `ink3` | 266–270 | **12 / 9 / 7%** | ✅ a genuine whisper |
| `ground` (was) | 273 | **36%** | ❌ 3–5× the inks. Read as lilac |
| `surfaceAlt` (was) | 272 | **33%** | ❌ same |

**Applied — hue held, saturation brought down to the ink family:**

| Token | Was | **Now** |
|---|---|---|
| `ground` | `#F3EEF7` (S36 L95) | **`#F5F3F6`** (S16 L96) |
| `surfaceAlt` | `#ECE5F2` (S33 L92) | **`#EDEAF0`** (S16 L93) |

Everything else unchanged. Two lines in `v2_palette.dart`, reverting is the same
two lines — the old hex sits in a comment beside each.

#### Why S16 and not S12, and why lightness did not move

Three candidates were rendered offline and compared side by side against the
real hero gradient, a white card, the hue wells and the type ramp:

| | `ground` | `surfaceAlt` | verdict |
|---|---|---|---|
| A — whisper | `#F7F6F8` S12 L97 | `#F0EEF2` S12 L94 | correct in theory; at L97 the white card stops reading as a card |
| **B — chosen** | **`#F5F3F6` S16 L96** | **`#EDEAF0` S16 L93** | neutral enough to stop tinting, dark enough to hold a card |
| C — present | `#F2F0F5` S20 L95 | `#EBE7EF` S20 L92 | still visibly lilac at the top of a long scroll |

The instinct when told "don't make it dull" is to raise lightness. **That is the
one move that would have broken it.** This system draws elevation as a *line, not
a blur* — so the only thing separating a white card from the page is the four
lightness points between `surface` (L100) and `ground` (L96). Spend those on
brightness and every card in the app goes flat. Dullness and flatness look
similar in a screenshot and are opposite problems: dullness is too little colour,
flatness is too little separation. We fixed the first without buying the second.

Brightness in this app was never the ground's job. It comes from the hero field,
the twelve category hues, the photography and `action` — all four untouched.

⚠️ **This does not make the app less colourful — it makes it more.** The V3 hero
field is a saturated violet gradient that was sitting on a lilac page, competing
with its own background. On a near-neutral page the same field reads as more
vivid, and the twelve category hues separate properly instead of all sitting in
one violet wash.

#### What this does NOT yet cover

`_baseline` is V3's palette only. The same two hex values are hardcoded in **~35
other places** across the three older token systems — `AppTheme.surfaceContainer`,
`ppPanel`, `ttcPanel`, `pgPanel`, `kPanel`, and a long tail of inline
`Color(0xFFECE5F2)` borders. Those still ship the lilac. Sweeping them is part of
the four-systems-to-one migration in §7, and doing it piecemeal would leave the
app visibly two-toned mid-scroll — so it happens in one pass, not opportunistically.

### The four colour rules

**(a) `action` is spent at decision points, never as a surface.**

Permitted: section eyebrows *(our signature)* · links · the active nav tab · a
focus ring · a single primary commit button.

**Never:** a page background · a card fill · a chevron on every row · a default
icon colour. An icon's job is recognition; colour is reserved for status.

**(b) ⚠️ On a tinted ground, every ink tier moves one step darker.**

`ink3` is calibrated to sit on `ground`, a near-neutral. On the hero field —
saturated and chromatic — it vanishes. **A grey loses contrast against a
chromatic ground faster than against a neutral one of the same lightness,**
because the eye is separating two signals rather than one.

> On the sheet: `ink3`. On the field: `ink2`. Same type, one tier in.

This shipped wrong twice (the parenting hero, then TTC's eyebrows in grey).

**(c) Chevrons and row affordances are `ink3`, never `action`.** A violet
chevron on every row makes violet mean "row" rather than "the one thing worth
doing".

**(d) Hues are meaning, not decoration.** A hue belongs to a subject and stays
with it everywhere: sleep is 232, feeding 104, health 186, scans 206. Two doors
never share a hue on one screen.

### ⚠️ The gap: we have no semantic colour

Red and green belong in a palette **even when they are not brand colours**. A
destructive action rendered in violet does not communicate that it destroys
anything.

| Token | Hex | Use |
|---|---|---|
| `danger` | `#B3261E` | **destructive confirmation only** — delete, remove, discard |
| `success` | `#2E6B4F` | a completed action, a passed check |

⚠️ **`danger` IS NOT for medical urgency.** The urgent strip stays calm and
uncoloured — see `UX-PRINCIPLES.md` §5.5. Red is for "this will delete
something", never for "you may be bleeding". Conflating them is how a calm
product becomes an alarming one.

### 60 / 30 / 10

`ground` + `surface` are the **60**. `surfaceAlt` and the pastel wells are the
**30**. `action` is the **10**. If a screen exceeds that, something is competing.

### The controlled-pastel wheel

All tints come from `v2BlockTint(hue, palette)` — **fixed saturation and
lightness, only hue varies**. That is what lets twelve colours read as one
family. Never hand-pick a tint.

## 2.2 Type — **THE DECISION**

Extracted from the V3 screens as built: **14 Fraunces sizes and 10 Manrope
sizes.** That is not a scale, it is an accumulation, and it happened one screen
at a time.

### (a) Two families, not three

The guidance is "you will rarely need more than one font". We keep two, and that
is defensible: **a display serif against a text sans is a classic editorial
pairing and it is a large part of why V3 reads as premium rather than as a
template.**

But we currently ship **three**. `pvJakarta` and `pvManrope` are both sans —
that is the redundant one.

> **Fraunces** — display: headings, the one fact, card titles, questions.
> **Manrope** — everything else: body, labels, eyebrows, metadata, buttons.
> **~~Plus Jakarta Sans~~ — retire.** Replace with Manrope at the same size.

### (b) The scale — nine roles, and nothing between them

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

**Nothing between these. If a size is not on this list it does not exist.**

⚠️ **Negative tracking on large type is not a preference — it is the single
cheapest thing that makes type look professional.** Tighten letter-spacing about
−2% to −3% and drop line-height to 105–120% on anything above 20px. Body copy
does the opposite: it wants 1.45–1.55.

### (c) Mobile type is BIGGER, not smaller

iOS base is 17px; macOS base is 13px. The instinct to shrink type because the
screen is small is exactly backwards. **Body copy never goes below 13.**

## 2.3 Spacing — **THE DECISION**

Currently **eighteen** distinct vertical gaps are in use. A system needs five.

**4-point base. Six steps. Nothing else.**

| Token | px | Use |
|---|---|---|
| `xs` | 4 | inside a line — label to value |
| `sm` | 8 | tight pairs — title to subtitle |
| `md` | 12 | between rows in a group |
| `lg` | 20 | between a heading and its content |
| `xl` | 28 | **between sections** |
| `xxl` | 40 | major breaks only |

Page padding is **18 horizontal**, everywhere, no exceptions.
Bottom clearance for the floating nav is **110–150**, and it belongs **inside the
opaque sheet** — see §6.

Why multiples of four rather than "it looks better": you can always halve them,
which is what keeps a design consistent as it grows.

## 2.4 Radius

| Value | Use |
|---|---|
| `28` | the content sheet's top, the bottom nav |
| `20` | cards |
| `18` | rows, list items, facts |
| `16` | small blocks, strips |
| `14` | icon wells, tiles |
| `999` | pills, chips, buttons |

Small components are **never** below 14. Inconsistent corner radii are one of the
fastest ways a design reads as amateur.

## 2.5 Shadow — **and one correction we owe**

Three rules:

1. **Soft, not strong.** Low opacity, high blur. *If the shadow is the first
   thing you notice, it is wrong.*
2. **⚠️ TINT THE SHADOW TO THE BACKGROUND BEHIND IT.** A grey or black shadow on
   a coloured ground clashes and reads as jarring; a shadow carrying the ground's
   hue blends.
3. **More elevation for things that float over content** (sheets, popovers), less
   for cards.

> **We are currently wrong on (2).** Our shadows are
> `Colors.black.withValues(alpha: 0.10)` on a **violet-leaning** ground.
> Desaturating the ground (§2.1(0)) narrowed this gap but did not close it — a
> pure-black shadow is wrong on any tinted ground, and ours is still tinted, just
> quietly.

The reference shows the fix precisely, and the useful part is that **only the
colour changes** — same offset, same blur:

| | bad | good |
|---|---|---|
| offset | X 0 · Y 19 | X 0 · Y 19 |
| blur | 48 | 48 |
| **colour** | **`#C7C7C7`** neutral grey | **`#CFC9DD`** tinted to the ground |

> **Our shadow token: `#D0C8DC`** — the ground's hue, desaturated and darkened.
> Never `Colors.black`.

| Role | Spec |
|---|---|
| card | none — a `line` border instead |
| content sheet | `#D0C8DC` @ 55%, blur 24, offset `(0, −6)` |
| floating nav | `#D0C8DC` @ 70%, blur 28, offset `(0, 8)` |
| bottom sheet / popover | `#D0C8DC` @ 80%, blur 40, offset `(0, −8)` |

---

# 3. THE ART SYSTEM

We draw our own marks in `CustomPainter`. **We do not use stock photography for
categories and we do not mix icon libraries.**

That is not purity — it is the same conclusion good category-screen design
reaches independently: *colour-coded cards with a soft solid background and a
clean, stylistically unified image beat photo overlays*, because mixed photos
have inconsistent light and mood and "don't feel like they belong to the same
product". Drawn marks are unified by construction.

## 3.1 The six families

| Family | Size | Where |
|---|---|---|
| `V2Mark` | 110dp | the original home doors |
| `BracketMark` | 73dp | problem-bracket doors (21 marks) |
| `SkillMark` | 73dp | skilling doors (12) |
| `DevMark` | 34dp | development areas (6) |
| `IntentMark` | 64dp | hub intent doors (4) |
| `V3DailyMark` | 28dp | journal quick actions (5) |

⚠️ **A family is authored for its size. It is not a scale factor.** At 34dp a
brain with folds is a smudge; at 110dp the same shape is bare. Redraw, never
resize.

## 3.2 The drawing rules

1. **One filled focal shape** in the tile's own hue at ~92%.
2. **Detail knocked out in WHITE**, never a second colour on top.
3. **Every tone derived from the tint**, never passed as a constant. *(Passing a
   flat ink colour instead is what produced "six grey lumps" once.)*
4. **One idea per mark.** No interior detail at small sizes.
5. **⚠️ ONE PATH, NOT SEVERAL OVERLAPPING SHAPES.** At 92% alpha every overlap
   composites twice and shows as a seam — the brain mark came out "quilted", the
   book came out folded. Sub-paths in a single `Path` fill once.
6. **A halo only where the mark is an open silhouette.** Behind a closed shape it
   is a second, blurrier copy of the same object — twelve of those in a grid is
   twelve smudges.

## 3.3 What a mark may never show

- **No score, ever.** No bar chart, gauge, target, medal, filled progress ring.
  A bar chart of a child's abilities *is* a score, and this product does not
  score children. (The Development mark shipped as a bar chart and was redrawn.)
- **Not the shape of the fear.** Frightening brackets — complications, mental
  health, loss — show the **shape of the help**: a steady pulse rather than a
  warning, a calm sky rather than a sad face.
- **No decorative emoji anywhere in chrome.** Line icons and drawn marks only.

## 3.4 Icons, where we use them

Material rounded, one weight, sized to the **line-height of the text beside
them** — usually 16–20. Different icon families may coexist **only if they are in
visually separate areas** doing different jobs; never side by side.

## 3.5 Verify offline before shipping

Rasterise a mark set with `PictureRecorder` + `tester.runAsync` and **look at it
at its real size** before it reaches a screen. This has caught, every single
time: a leaf that should have been a brain, a settings-slider that should have
been an abacus, a dial that should have been an eye, a wifi symbol that should
have been a figure, a buried thumb, and a YouTube logo.

---

# 4. COMPONENTS

## 4.1 Page structure

```dart
Scaffold(backgroundColor: p.ground, body: Stack(children: [
  Positioned.fill(child: V3HeroField(accent: tint, ground: p.ground, variant: n)),
  ListView(padding: EdgeInsets.zero, children: [
    _Hero(...),                    // type only, no background
    _Sheet(p: p, children: [...]), // radius 28 top, upward shadow, owns bottom clearance
  ]),
]))
```

**`V3HeroField`** — two hues 34° apart (a gradient needs somewhere to travel
*to*; one hue at three lightnesses is a wash), off-canvas arcs for depth, and a
3% white dot grid for tooth. *Tooth is the difference between "a colour" and "a
surface".*

## 4.2 Section head

```
EYEBROW        Manrope 11 / w800 / +1.4 / p.action
Title          Fraunces 22 / w600 / −0.5 / p.ink1
```

The eyebrow is `action`. **This is load-bearing** — it shipped grey on two
screens and drained the colour out of everything below it.

## 4.3 Button — **there is one**

**Outlined pill. Transparent fill. `p.line` border 1.2. Height 44. Radius 999.
Icon 16 + label Manrope 13.5/w700, both `ink2`.**

⚠️ **No filled violet buttons. Anywhere.** Two reasons, both real:

- on a screen that has already spent its colour on hue wells, a violet fill is a
  third violet doing nothing in particular;
- and a filled button is the single loudest element on a page, so it decides what
  the page is *for*. Ours are almost never the point — the content is.

> A third reason applied until 2026-08-16 and no longer does: the neutrals were
> saturated enough that a "grey" fill landed as a pale purple wash. §2.1(0) fixed
> that. **The rule does not relax** — the two reasons above stand on their own,
> and this is exactly the kind of rule that gets quietly re-opened once its
> weakest justification expires.

**The border is what says "button".** The fill was never carrying that job.

A filled button is permitted **only** for a single primary commit action in a
flow (checkout, submit) — never for navigation.

### Every button needs four states

`default · pressed · disabled · loading`. **This is a current gap** — we have
default and an ink ripple and nothing else. *A screen that takes a moment to load
after a tap looks like the tap did not register.*

## 4.4 Cards

| Kind | Spec |
|---|---|
| standard | `surface`, radius 20, `line` border, no shadow |
| row | `surface`, radius 18, `line` border |
| quiet fact | `surfaceAlt`, radius 16, **no border**, not tappable |
| placeholder | `surfaceAlt`, radius 18, no border, **not tappable** |

⚠️ **Do not double-nest cards.** A bordered card inside a bordered card is
padding on padding — it eats the space you have and shows the least for it. Group
with white space instead. *(This is why the journal's action tiles have a fill
and no border: the card around them already said "these belong together".)*

## 4.5 Door tile — the V3 signature

A gradient well in the door's hue (±0.045 lightness), radius 14, a drawn mark
inset 8–9, label under or beside it.

- **Grid** (4 columns, 73dp): one- or two-word labels. `V2BlockGrid`.
- **Row** (56dp well, label beside): sentence labels plus a promise line.

Same well, same gradient, same mark treatment. Only the arrangement changes.

### ⚠️ 4.5b The open question: tint the well, or tint the whole card?

Watching the reference material rather than reading it surfaced one real
difference between what we build and what the best category screens do.

**We tint the icon well and keep the card white.** The strongest reference
version tints **the entire row** in the category's hue, sits an isolated image on
that tint, and puts the chevron in a white circle. Its selected state is a
stronger tint plus a border.

Both are defensible and the trade is honest:

| | ours (white card, tinted well) | theirs (fully tinted row) |
|---|---|---|
| Scanning | slower — colour is a small patch | **faster — the whole row is the signal** |
| Calm | **calmer, more editorial** | busier, more app-like |
| Long lists | holds up | 12 tinted rows becomes a lot |
| Selected state | needs inventing | free — deepen the tint |

**Recommendation: keep white cards for lists of five or more, and use the fully
tinted row where a screen shows three or four doors.** The Scans hub's four
intent doors are the natural place to try it.

⚠️ **Do not mix the two on one screen.** That is the version of this that looks
broken.

## 4.6 Solution card — the seven types

`READ · WATCH · TOOL · DO · THING · PROGRAMME · TALK`

**⚠️ ONE HUE AND ONE ICON PER TYPE, ACROSS THE ENTIRE APP.** Every READ is the
same blue on every screen; every TALK the same teal. She learns it once.

Structure: type well (52dp) · title `cardTitle` · one-line value · type chip.

**The value line is required.** A card with a title and no reason is a link, and
a list of links is a catalogue.

`WATCH` ships its shell whether or not media exists — same card, `surfaceAlt`,
chip reads `WATCH · 5 MIN · COMING SOON`, not tappable.

## 4.7 Placeholder

**"Coming soon" alone is banned.** A placeholder states its future value:

> **Build your sleep plan**
> Create a bedtime routine based on your child's age and current sleep pattern.
> `TOOL COMING SOON`

Rules: same size and position as the live row it will become · `surfaceAlt`, no
dashed borders or grey blocks · **never tappable** (a dead end wearing a gesture
teaches her that rows here may do nothing, and that doubt spreads) · **max two
visible per screen** · **never on an urgent or grief path.**

## 4.8 Urgent strip

`surface`, radius 16, `ink3` border at 34%, outline icon, `ink1` text, chevron.

⚠️ **Calm, not alarming, and never dismissible.** A red banner frightens the
frightened and numbs everyone else, so by the time it matters nobody reads it.
**The urgency lives in the POSITION** — first, above everything — not the colour.

Only where the problem has genuine red flags. One that appears because the
component exists trains people to ignore the ones that matter.

## 4.9 Bottom navigation

**On nearly every screen, and the most-tapped area in the app. Full reasoning in
`UX-PRINCIPLES.md` Part 4.**

| Property | Value |
|---|---|
| Shape | floating pill, radius 28, `surface` |
| Separation | soft shadow above (§2.5) — the nav must be visually distinct from content |
| Tabs | **3–5**, max 6 |
| Icon | **24px**, outline, one family, one weight |
| Label | **11px**, single line, short — never wraps |
| Tap target | **≥ 44 × 44** |
| Safe area | sit **above** the home indicator (~34px). Never overlap it |
| Colour | **neutral.** Never a colour per tab |

### The active state

**Two visual changes, no container:**

> **filled icon + `action` colour + label w700 in `ink1`.**
> Every other tab: outline icon, `ink3`, label w500.

The filled selected icon is **the one permitted exception** to "one icon style
throughout".

⚠️ **No container behind the active tab — and the reason is ours, not borrowed.**
Material 3 ships a pill indicator and that is not a defect. It is wrong *here*
because (a) our labels are always on, so a container is a redundant third signal,
and (b) `action` is the only saturated colour we spend, and a filled violet pill
is a third violet on a screen that has already spent its budget on hue wells.
Full reasoning in `UX-PRINCIPLES.md` §4.3.

> **Both stages ship a filled violet pill/circle today. Both change.** If an
> indicator is ever wanted, it is a soft tint — never a saturated fill.

### ⚠️ No centre action button

The nav holds destinations only. Our one floating action is the Ask Veda FAB, and
it already owns that region — `global_fab_layout_test` and
`ttc_fab_clearance_test` hold its clearance.

### Inactive state

**Reduce opacity**, do not switch colour. Minimum contrast **3:1**.

### ⚠️ Labels are always on

Not a style choice. Our audience spans a very wide range of digital literacy,
and the guidance is explicit: users less familiar with apps need labels to
navigate confidently. **Icon-only navigation is not available to us.**

### Badges — narrowly permitted

**Only** a clinician reply, an appointment today, or a partner message. **Never**
new content, articles, products, or anything whose purpose is to bring her back.
A badge on a parenting app is an anxiety mechanic more often than an information
one — `UX-PRINCIPLES.md` §6.3.

When one appears: small, top-right of the icon, `surface` outline, readable
numeral.

### Micro-interactions

Tap feedback (scale or ripple) · the indicator slides between tabs rather than
snapping · a soft cross-fade between screens.

### Tab sets differ by stage; treatment never does

Pregnancy, parenting and TTC legitimately have different destinations. They must
be visually identical in every other respect.

## 4.10 Stat pair

Label **small and above**, value **large and below** — never the reverse. A
common failure is styling the label at 24 and the number at 14, which puts the
emphasis on the word "Sales" rather than on 591.

```
PROJECTS          ← Manrope 10 / w800 / +1.1 / ink3
12                ← Fraunces 22 / w600 / ink1
```

## 4.11 Button pair

Primary and secondary side by side, **equal width**, 44 high, radius 999.
Primary is a filled `ink1` pill with white label; secondary is our standard
outlined pill.

⚠️ **The filled one is `ink1`, not `action`.** A filled violet primary is the
thing §4.3 bans; a filled near-black reads as "commit" without spending the
accent. Reserved for genuine commit actions — never navigation.

## 4.12 Empty state

Four parts, in order:

1. **A drawn mark in a hue well**, 96dp, centred *(not a stock illustration)*
2. **A statement of value, never of absence.** "Start keeping a journal — the
   small things are the ones you forget." Never "You have no entries."
3. **Two or three actionable lines**, each with a small `ink3` icon
4. **One outlined pill** — the single next action

The same anatomy serves the no-results case: acknowledge the query, suggest a
fix, offer a way out.

## 4.13 Input

| State | Spec |
|---|---|
| default | `surface`, radius 14, `line` border 1 |
| **focus** | `action` border **2px** plus a soft `action` @ 12% ring |
| error | `danger` border 2px, message below in `danger` at 12.5 |
| disabled | `surfaceAlt` fill, no border, `ink3` text |

Label above in `eyebrow` style. **Sliders and wheels for one-time setup; text
fields and steppers for anything repeated or precise.**

## 4.14 Chips

Radius 999, `surface`, `line` border, Manrope 13/w600 `ink1`. Selected: hue well
fill, no border.

---

# 5. PATTERNS

## 5.1 One screen does one thing

Settings is settings. The notes editor is notes. **The only exception is a home
screen.** When you need to add something, reach for a different page — not a
denser layout.

## 5.2 One direction per section

Desktop lays out in two directions at once. Mobile picks one **per section**:
either a vertical stack or a horizontal rail, never a grid of both.

## 5.3 Expose the content, do not announce it

A banner saying "Discover 100+ recipes" that must be tapped is an **interaction
cost** between her and the value. Show three actual recipes instead.

## 5.4 Progressive disclosure

```
Primary need → answer → likely next question → useful next action → optional deeper help
```

Not everything relevant at once. A person who wants to understand a scan does not
need five articles, three videos, three tools, a product and a consult on one
screen.

## 5.5 Adapt to where she is

A new user, a returning user and a deeply engaged user should not get the same
screen. We already hold the state to do this — what is booked, which week, what
she logged — so use `if` statements over real state. **Do not build an intent
engine**; three conditions get most of the value.

## 5.6 Search is never a blank box

Tapping search is a moment of intent. Offer recent searches, popular items, and
personalised suggestions. She can ignore them and type.

## 5.7 Empty states are the feature's advertisement

A feature is never hidden; an empty section renders an invitation. Two kinds:

- **nothing yet** — say what this will hold, and give one action;
- **no results** — acknowledge the query, suggest a fix, offer a way out.

## 5.8 Feedback for every action

Press states, loading states, and a confirmation when something completes. **If
she does something and nothing changes on screen, the app looks broken.**

## 5.9 The thumb zone

Primary actions live in the lower third. We accept the platform convention of a
top-left back button, but **no primary action goes in a top corner.**

## 5.10 Input method follows frequency

Sliders and wheels for one-time, low-precision setup. Text fields and steppers
for anything repeated or precise. *Logging food every day with a slider is
punishment.*

## 5.11 Signifiers over instructions

A container means "these belong together". A filled container means "selected".
Grey means inactive. Get these right and you never write instructions.

---

# 6. ANTI-PATTERNS

Each of these is a defect we have actually shipped.

| Never | Because |
|---|---|
| **Filled violet buttons** | third violet on a screen that spent its budget; the border says "button" |
| **`ink3` on a tinted field** | greys collapse faster on chromatic grounds — shipped twice |
| **A gradient that ends** | a section-height gradient washes out at its own seam; the field must fill the page |
| **Blending two sections** | edge detection always wins. Overlap instead |
| **Padding below an opaque sheet** | once the field belongs to the page, scroll-view padding is a window onto it |
| **`const` on a widget showing store state** | Dart canonicalises it, Flutter short-circuits the rebuild, the UI silently stales. **Five occurrences.** A widget that shows store state subscribes itself |
| **A "0" for a first day/week** | nobody is 0 weeks old; a unit that does not move is a mood |
| **Reusing an `onTap` because it points "roughly" somewhere right** | a callback named after a gesture says nothing about destination — WEEK 40 opened the classic home |
| **A category heading — Content, Tools, Products** | that is our filing system. She has never thought "I need the tools layer" |
| **A section because a component exists** | show it only if it helps the current job |
| **A tappable placeholder** | dead end wearing a gesture |
| **Stock photos as category art** | mixed light and mood; reads as assembled from parts |
| **Two shapes for one idea** | the point at which an icon language stops being one |
| **A wrong photograph over an honest tint** | a photo is read as being about the thing beside it. A duffel bag shipped under "Drowsy but awake" |
| **A bar chart of a child's ability** | it is a score |
| **Double-nested cards** | padding on padding |
| **A hue picked by index** | `(26 + i * 53) % 360` means the colour changes with whatever happened to be in the list |
| **More than 5 bottom-nav items** | and never below 44dp |
| **A box or pill behind the active nav tab** | the reference marks this as the wrong version outright — it is visual noise. Two changes on the icon and label instead |
| **Icon-only navigation** | our audience spans wide digital literacy; labels are always on |
| **A colour per nav tab** | navigation becomes a guessing game and pulls attention from content |
| **A black shadow on a tinted ground** | it clashes. Tint the shadow to the ground — `#C7C7C7` → `#CFC9DD` |
| **Violet for a destructive action** | it does not communicate destruction. That is what `danger` is for |
| **Red for medical urgency** | frightens the frightened, numbs everyone else. Urgent is calm and positional |
| **Loss-aversion framing** | "you will lose X" is fear-based marketing at an audience whose baseline is anxiety |
| **Colouring icons by default** | an icon's job is recognition; colour is reserved for status |

---

# 7. MIGRATION — four systems into one

| System | Files | Status |
|---|---|---|
| **`V2Palette`** — V3 | 22 | **the target** |
| `AppTheme` | 103 | migrate |
| `pp_common` (`ppBg`, `ppCoral`, `ppFraunces`…) | 155 | migrate |
| `ttc_common` (`ttcBg`, `ttcPurple`…) | 29 | migrate |

**This is why the app feels like three products.** Parenting and TTC each grew a
complete parallel palette and type helper.

### Order

1. **Free wins, whole-app** — tint the shadows (§2.5), retire `pvJakarta`
   (§2.2a), unify the bottom-nav active state (§4.9).
2. **The token bridge** — map `ppBg`/`ttcBg` → `ground`, `ppInk` → `ink1`, and so
   on, so a file migrates by changing imports rather than every literal.
3. **By traffic, not by folder** — the screens a bracket door opens first, since
   those are where the seam is visible today.
4. **Type and spacing pass** — collapse to §2.2b and §2.3 as each file is touched.

⚠️ **Do not migrate a screen and stop.** A half-migrated screen is worse than an
unmigrated one: the seam moves from between screens to inside one.

---

# 8. USING THIS WITH CLAUDE DESIGN

A design-system project holds these tokens and components so generated screens
come back in our language instead of the generic default (warm cream, serif
display, terracotta accent — the look you get when nothing is specified).

## 8.1 How the project actually gets created

**The `/design-sync` command is yours to run, not mine.** It is marked
user-invocation-only, so I cannot start it, and I am specifically not allowed to
hand-roll the same thing through the underlying API. What I *can* do is make sure
that when it runs, it reads a house style that is already written down — which is
what this file is.

The division, stated plainly so it is not rediscovered:

| | who |
|---|---|
| Write and keep §2–§6 true | me |
| Type `/design-sync` | you |
| Answer its questions (which project, which components) | you |
| Build the component bundle it uploads | me, inside that command |
| Review the diff before it writes | you |

As of 2026-08-16 the account has **zero** design-system projects, so the first
run creates one. It is incremental by design — one component at a time, never a
wholesale replace — so a first pass covering only §2 foundations plus the four
components in §4 is a complete, useful state, not a half-finished one.

## 8.2 What to send with any prompt, sync or not

**Always paste §2** — palette hexes, the type scale, radii — plus the four rules
most likely to be ignored:

1. **No filled violet buttons.** Outlined pills, transparent fill.
2. **`action` is the only saturated colour**, and it is spent on section eyebrows
   and links. Nothing else.
3. **The ground is near-neutral (`#F5F3F6`), never cream.** Cream plus a serif
   plus a terracotta accent is the generic AI-design default, and the whole point
   of §2.1(0) is that our page is quiet so our content is not.
4. **Shadows are tinted to the ground, never black.**

Ask for **mobile, 390pt**, and ask it to show its type scale so drift is visible
before it is code.

⚠️ **Sync direction is one-way: this repo is the source.** If a generated
component disagrees with §2, §2 wins and the component is wrong — otherwise the
design system becomes a fifth token system (§7 already has four) and we have made
the exact problem we are trying to close.

---

# 9. THE CHECK

Before any screen ships:

- [ ] Field fills the page and does not scroll; content is a sheet over it
- [ ] Every type size is on the §2.2b list
- [ ] Every gap is one of the six in §2.3
- [ ] No filled violet button
- [ ] Section eyebrows are `action`
- [ ] Anything on the tinted field is one ink tier darker
- [ ] Chevrons are `ink3`
- [ ] Shadows are tinted to the ground, soft, and not the first thing you notice
- [ ] No card inside a card
- [ ] No heading named after a content type
- [ ] Marks are drawn, from the right family, verified at real size
- [ ] Nothing shows a score
- [ ] Placeholders state their value and are not tappable
- [ ] Primary actions are in the lower third
- [ ] Empty and loading states exist
- [ ] Bottom clearance sits inside the opaque sheet
- [ ] Nav: two changes on the active tab, no box, labels visible
- [ ] Shadows are tinted, never black
- [ ] Destructive actions use `danger`; urgent paths stay calm
- [ ] It would still be right if she were frightened
- [ ] It could not be told apart from the V3 home
