# ParentVeda — the design layer

> **What this is.** The design system: palette, type, the Indian rules, motion, and the
> behavioural laws. The document to reference while building.
>
> **Why it exists.** `DESIGN-BRIEF.md` holds the evidence behind every decision here —
> read it once, then work from this file. `DESIGN-DECISIONS.md` records what is settled
> and what is parked.
>
> **Scope: app and website together.** One ParentVeda, not two products sharing a logo.
>
> **Status: in flux, deliberately outside `memory/` and `CLAUDE.md`** so the auto-loaded
> brain is not churned while this moves. Settled points graduate there later.

---

## 0. What already exists — read from the app, not invented

`lib/theme/app_theme.dart`:

| Role | Value | Ramp |
|---|---|---|
| primary | `#6A30B6` violet | 50–900 (`#F3EFF9` → `#2D144C`) |
| secondary | `#FF5A79` coral | 50–900 |
| tertiary | `#7A4600` earthy brown | 50–900 |
| neutral | `#7B757F` warm grey | — |
| accents | green `#1F8A5B` · amber `#C98A2B` · blue `#3E6DA6` · rose `#C6295A` | one each |
| father | slate `#2D3436` | — |

Type (`lib/theme/pv_fonts.dart`): **Fraunces** (warm editorial serif, currently hero
moments only) · **Plus Jakarta Sans** · **Manrope**. Devanagari: **Noto Serif
Devanagari** + **Mukta**.

**This is a good foundation. The work is re-tempering and disciplining it, not replacing
it.** Brand colours stay — app and website remain in sync.

---

## 1. ⭐ The one move that buys the most identity, and costs no new colour

**The neutrals are lavender-tinted:** `#FBF9FE`, `#F3EEF7`, `#ECE5F2`, `#C7BBD6`,
`#5B5070`. Cool purple-greys — the same material iMumz's background wash is made of.

> **The violet is not the problem. The paper under it is.**

Put the identical `#6A30B6` on **warm** ground and the two products stop resembling each
other at the same hue. Warmth comes from **temperature, not from hue** — the mechanism
behind Maven's bone paper, Aesop's amber and Good Earth's cream.

It also answers ownability. Instantly-identifiable brands rarely own a *hue*; they own a
*combination*. Spotify is green **on near-black**. Duolingo is green **with heavy rounded
shape**. ParentVeda becomes:

> ### that violet, on warm paper, set in Fraunces.

Nobody in this category has warm paper. They are all on cool white and lavender.

### Warm ground — replaces the lavender neutrals

```
--paper-0  #FDFBF7   unbleached white — default page
--paper-1  #F8F4ED   raised surfaces, cards
--paper-2  #F1EBE0   inset / quiet blocks
--paper-3  #E7DFD1   strong fill
--line     #DDD3C2   hairlines
--line-2   #EDE5D8   quiet hairlines
```

### Ink — warm-dark carrying a violet undertone, so darkness is still brand

```
--ink-1    #241E2B   primary text (near-black, violet undertone)
--ink-2    #4A4351   secondary text
--ink-3    #726A78   tertiary / metadata
--ink-4    #9A929F   disabled, placeholder
--ink-deep #2D144C   primary900 — the dark GROUND for inverted sections
```

Using `primary900 #2D144C` as the dark ground rather than a neutral black means even
inverted sections read as ParentVeda.

---

## 2. Colour discipline — one job each

The constraint: enhance usability, do not dilute identity, do not add so many colours
that nothing is ownable. Seven hues are already in play. The fix is not deletion — it is
**one stated job each, never decorative.**

| Colour | Its ONE job | Never |
|---|---|---|
| **violet `#6A30B6`** | *You can act on this.* Links, buttons, active state. | Never "this is important". Never a gradient. Never a background wash. |
| **ink-deep `#2D144C`** | The dark ground for inverted passages. | Not a text colour. |
| **coral `#FF5A79`** | **Demoted — the logo mark, nothing else.** | Never a second accent. An undefined second accent is what makes a palette read as generic. |
| **brown `#7A4600`** | Structural warmth — rules, frames, margin ornament. | Never a button. |
| green `#1F8A5B` | Done / safe / complete. | Never decorative. |
| amber `#C98A2B` | Food, nutrition, warmth. | Never "warning" — we do not alarm. |
| blue `#3E6DA6` | Sleep, calm, learning. | Never a link — violet owns action. |
| rose `#C6295A` | Health attention that is *not* alarm. | Never marketing. |

### Countable invariants

Restraint should be **verifiable by grep**, not asserted:

- gradients in shipped CSS: **1** (the logo mark only)
- easing curves: **1**
- typefaces: **3 Latin + 2 Devanagari**, no more
- accent hues on any single screen: **≤ 2**

---

## 3. Type — commit to Fraunces

Fraunces is variable with `SOFT` and `WONK` axes — genuine character a competitor using
Poppins cannot imitate. It is currently restricted to "hero moments only", which is why
the identity is not carrying.

| Face | Role |
|---|---|
| **Fraunces** | All display and headline, **and article body on `/reads`**. `WONK` on at display sizes — the quirk is the signature. `WONK` off for body. |
| **Plus Jakarta Sans** | UI — labels, buttons, navigation. |
| **Manrope** | Data and metadata — reading time, dates, category labels. |

- **Small-caps, wide-tracked metadata label** (Aeon's device): marks metadata without a
  pill, a box, or a colour.
- Body weight **400**, leading **1.6–1.7**. **No hairline weights** — weight-300 body
  inverts on a mid-range Android in Indian daylight.
- **Register-switching headlines** (Maven's device): sans for the functional half, italic
  serif for the human word, within one headline.

### Devanagari — the two corrections are not optional

Carried from `lib/theme/pv_fonts.dart`:

1. **Line height.** Matras hang above the shirorekha and vowel signs below the baseline.
   Latin display runs as tight as `1.06`, which at 52px clips matras outright. Hindi
   relaxes to ~`1.35`+.
2. **Letter spacing.** Devanagari is connected; negative tracking pulls conjuncts into
   each other. All negative spacing clamps to `0`.

Anything rendering Hindi goes through `PvType`, or it silently loses both.

---

## 4. Being Indian — the twice-sourced rule

> ### Indian in composition, palette, material and cadence — never in applied motif.

| Dimension | Rule | Source |
|---|---|---|
| **Composition** | Borrow miniature painting's framing logic — a contained aperture (a *jharokha* circle) rather than a full-bleed rectangle, for hero imagery. | Nicobar |
| **Ornament** | A small hand-drawn botanical motif set living **in the margins at low opacity**, bleeding off the edge. Never centred, never a banner, never a section divider. | Good Earth |
| **Palette** | The warm ground in §1 *is* the textile palette. Add petrol/teal only if a real need appears. | both |
| **Cadence** | Literary and seasonal in copy, in both languages. | Good Earth |
| **Material** | Photograph texture close, in natural light — weave, block print, cane, paper. | both |

**Never:** marigolds in corners, paisley borders, saffron gradients, rangoli dividers,
mandala backgrounds.

---

## 5. Motion — unconstrained, with intent

The previous ban is **removed**. Its argument — that a page reacting to scroll performs
surveillance — did not survive scrutiny: it treated scroll as passive observation and tap
as active input, and that distinction does not hold. Scrolling *is* an action she takes.

Performance is **out of scope** by the user's instruction: build unconstrained, optimise
later.

Direction rather than restriction:

- Motion of **light, cloth, water, hands** — slow, out of focus. Never shader, never
  glass, never blob.
- ⭐ **Film is the highest-leverage media.** Three of eight reference sites get their
  expensive feel from moving image, not CSS. Roughly $10 / ₹850 per site in generation
  credits.
- **Interaction feedback is encouraged** — it is what makes an interface feel alive and
  expensive. Seven `transition` declarations across a whole site was the fingerprint of
  the old over-correction.
- **Scroll motion is allowed.**

> **Deferred-performance list.** Record anything here that would need revisiting if
> optimisation happens later — heavy libraries, large media, animation counts. Recording
> only; it must not shape decisions now.

---

## 6. The behavioural laws — the wedge, made checkable

The strategic centre is ***nobody is chasing you***, in its operative form:

> **You can always leave, and you always know the price before the pitch.**

**This is not an anti-monetisation position.** ParentVeda will promote, sponsor and sell.
Mothers do not complain about products being *paid* — they complain about being pursued.

These are design law, not preference. Each is a **visible absence**, verifiable in
seconds without reading a word:

- No interstitial, no modal, no "sign up to continue", no countdown, no exit-intent
- No phone number required to read anything
- Delete-account and unsubscribe **visible**, not buried
- **Price stated before the pitch**, never after
- Nothing on screen *waiting to be cleared* — no badge, no count, no streak
- A promo bar is fine. A promo that **blocks content, demands a phone number, or cannot
  be dismissed** is not.

**Benchmark: six of eight world-class reference sites fail this.** Aeon and Nicobar pass.

---

## 7. The aesthetic vocabulary

The additive counterweight the previous system never had. Eight terms, to be quoted in
briefs:

1. **Unhurried** — nothing on screen is racing her or counting down.
2. **Handled** — the surface reads as *someone has already done the worrying*. Relief,
   not excitement.
3. **Warm-neutral, not sweet** — warmth from temperature (unbleached paper, clay,
   sandalwood, brass), never from pink or lavender.
4. **Editorial, not app-like** — the register of a well-set book, not a dashboard.
5. **Quietly alive** — motion of light, cloth, water, hands. Slow, out of focus.
6. **Rooted, not costumed** — Indian in material and type, not motif and marigold.
7. **Uncrowded** — one idea per screen. Not empty; unhurried.
8. **Legible at arm's length, at 2am, one-handed** — the actual reading condition.

---

## 8. Patterns lifted from the reference set

| Pattern | Source | Use |
|---|---|---|
| **The four-element card** — mono category label / serif headline / one sentence / author name. No "Read more", no counts. | Aeon | `/reads` index |
| **Reading time as courtesy** — "20 minutes". A small true number telling her what she is committing to. | Aeon | every article |
| **Author name on every piece** — accountability at the point of consumption. | Aeon | every article |
| **Unequal card heights**, some with images and some without | Aeon | any grid — the asymmetry that stops a grid reading as a template, and it is free |
| ⭐ **The quiet index** — two-column list, category left / title right, low opacity with the active row raised. Dense without being loud; more elegant than cards. | Kinfolk | `/reads`, section landing pages |
| **Headline as frame, not banner** — a word at each edge with imagery between them. | Good Earth | section openers |
| **Register-switching headline** — sans → italic serif mid-sentence. | Maven | hero, section heads |
| **Environmental portraiture** — a real person in a real room; the subject's name IS the headline. | Kinfolk | reviewer, founder, expert pages |
| **Stage-based organisation** — content that changes as she and the child move. | Lovevery | the whole product |
| **Concrete checkable claims** over vague benefit copy. | Lovevery | everywhere |

---

## 9. The working method

Drawn from what actually produced good results, not from what was advertised:

1. **Reference-fed, never "make it beautiful."** Supply real artefacts — screenshots,
   URLs, video.
2. **Constrain hard.** The best results came from the most restrictive prompts.
3. **Adversarial review *before* building** — attack the concept while it is still a
   sentence, not after it is code.
4. **Intent first**: *"When someone leaves this page, what is the one thing she should
   feel or do?"*
5. **Verify by looking.** Screenshot what was built and what was referenced. If a site
   was not opened, say so.
6. **Brief structure** (the user's own, and better than what the previous attempt used):
   **Aesthetic** (5–8 vocabulary terms) → **Reference** → **Intent** (what this should
   feel like and why) → **Guardrails** (constants and bans).

---

## 10. Sequencing — nothing is built yet

1. **The revamp lands first.** Structure, naming and component placement move; content is
   re-ordered, not added or removed. The user holds the spec.
2. **Design is applied over the revamp**, not before it.
3. **Everything gets a V2 — never mutate the original.** Consistent with the repo's
   *comment out, never delete* rule.
4. **The user calls the moment** for Semrush and for execution.
5. **Owed on request:** a V1/V2 homepage toggle on localhost — V1 on the recommended path,
   V2 carrying the full effects layer (shader gradients, glass, WebGL) — so the effects
   question is settled by looking rather than by argument. Front-end only, homepage only.
