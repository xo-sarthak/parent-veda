# Image generation prompts — hero block art

> **For the user to run through ChatGPT (or any image model).** Generated before the V2
> build so assets and layout land together.
>
> **Why these are safe to make before the palette is decided:** every asset is generated
> **isolated on a transparent background**, and the app composites it onto whatever ground
> wins. This is Flo's model — the image floats on the *app's* field and never carries its
> own (`FLO-TEARDOWN.md` §1). Nothing here is wasted by the P03 decision.

---

## Before you start — three things

**1. Generate image 1 first and get the style right.** Then for every following image,
say *"same style, lighting and finish as the previous image"* and paste only the subject
line. This is what makes six images look like **one system** instead of six pictures — the
single most important thing in this document.

**2. Week 30 needs nothing.** `assets/baby/week_30.jpg` already exists (weeks 04–40 are
all there). Skip it.

**3. Blocks are small — about 110dp square on a phone.** No faces, no text, no fine
detail. A face is illegible at that size; the label underneath carries the meaning, and
the image carries the *feeling*.

---

## THE HOUSE STYLE — paste this at the top of every prompt

```
Style: a single object, isolated on a fully transparent background. No scene,
no environment, no ground plane, no drop shadow.

Lighting: soft, diffuse, directionless. No hard shadows, no strong highlights,
no drama. Matte finish — no gloss, no reflections, no glass.

Colour: warm and muted. Skin-adjacent, clay, unbleached paper, brass, soft
sage. Avoid saturated primaries, avoid neon, avoid pure white and pure black.

Composition: one subject, centred, generous empty margin on all sides.
Square 1:1.

Do not include: text, numbers, letters, logos, watermarks, UI elements,
buttons, arrows, faces, people, borders, frames.

Output: square, transparent PNG, at least 1024x1024.
```

---

## The prompts

### 1 — Today's practice
*The daily ritual: breathing, sound, stillness, connection.*

```
Subject: a length of soft, unbleached linen cloth, caught mid-fold in gentle
motion, as if just released from a hand. Loose natural drape, visible weave
texture, warm oatmeal colour.
```

**Why this and not a lamp or a lotus:** the design rules forbid applied Indian motif
(`DESIGN-LAYER.md` §4). Cloth carries calm and care through **material**, which is how
this system is allowed to be Indian.

---

### 2 — This week
**Skip.** Use `assets/baby/week_30.jpg`.

---

### 3 — Next scan
*Clinical, but not cold.*

```
Subject: a single ultrasound printout strip, softly curled as if just handed
over, seen at a slight angle. Matte thermal paper, warm grey imagery, gently
worn edges.
```

Recognisable and honest. **Do not** substitute a stethoscope or a doctor — this block is
about her appointment, not about medicine as a category.

---

### 4 — Today's read
```
Subject: a small stack of loose paper sheets with soft, slightly uneven
edges, the top sheet lifting and curling gently as if mid-turn. Warm
off-white, matte, visible paper fibre.
```

**Ask for 2 variations.** Reading is abstract and this is the block most likely to need a
second attempt.

---

### 5 — Today's video
```
Subject: two smooth, softly rounded rectangular panels of translucent warm
amber material, overlapping at a slight offset, suggesting two frames of a
sequence. Thick, soft-edged, matte, like sea glass without the shine.
```

**Ask for 3 variations — this is the hardest of the six.** If none reads as "something to
watch", say so and I'll change the concept rather than have you keep generating.

---

### 6 — Ask a question
```
Subject: two soft, rounded, pebble-like forms in warm clay and pale sage, one
resting slightly behind and overlapping the other, as if in conversation.
Smooth matte ceramic, hand-thrown irregularity.
```

Deliberately **not** a question mark and **not** a speech bubble — both are the generic
default this system exists to avoid.

---

## When they come back — check these five

1. **Is the background genuinely transparent?** Not white. Open one on a dark surface to
   be sure — a white box will show up on every palette.
2. **Do all six look like one set?** Put them in a row. If one has different lighting or
   finish, regenerate that one referencing the others.
3. **Legible at thumbnail size?** Shrink to ~110px. If it becomes a blob, it fails.
4. **No text, no faces, no borders** — models add these unasked, especially numbers.
5. **Warm, not saturated.** If anything looks candy-coloured or neon, it will fight the
   one-loud-colour rule (`DESIGN-LAYER.md` §2).

**Naming:** `block_practice.png` · `block_scan.png` · `block_read.png` ·
`block_video.png` · `block_ask.png`. Drop them in `assets/blocks/` — I will add the
pubspec entry during the build.

---

## Still owed later, not now

The **content card imagery** (six modes, `DESIGN-LAYER.md` §4a) is a much larger set and
depends on which content rails survive the revamp. Prompts for that come after the block
structure is approved — generating them now risks producing art for rails that get
renamed or dropped.
