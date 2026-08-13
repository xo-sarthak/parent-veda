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

## 0a. The logo, actually looked at

`assets/brand/pv-lockup.png`, `pv-mark.png`, `pv-mark-transparent.png`.

**The mark is a parent and child forming a heart** — a violet adult figure (head and
curved arm) embracing a coral child figure. Soft rounded terminals throughout. The
wordmark "ParentVeda" is a heavy geometric **rounded sans**, one weight.

Colours sampled from the lockup (not eyeballed):

| | Sampled from logo | Code constant | Verdict |
|---|---|---|---|
| Violet | **`#6830B0`** — 45.5% of opaque pixels | `#6A30B6` | Faithful ✓ |
| Coral | **`#F05070`** — 19.1% | `#FF5A79` | Faithful; logo's is slightly deeper ✓ |

Three consequences that only became visible by looking:

1. ⭐ **The coral is not decoration — it is the child.** Violet is the parent, coral is
   the child, and the mark's whole meaning is one holding the other. This **supersedes**
   the earlier "demote coral to the logo mark only" rule, which was written without
   seeing the mark. A better rule falls out of the logo's own logic — see §2.
2. ⚠️ **The wordmark and the type proposal disagree.** The lockup speaks in a friendly
   geometric rounded sans; §3 proposes Fraunces, an editorial serif with a wonk axis.
   Two different voices. Either the wordmark is eventually redrawn, or the system
   knowingly carries a logo that speaks differently from the pages. **Named rather than
   papered over; unresolved.**
3. **Shape language is soft and rounded** — generous corner radii and rounded stroke
   terminals, not sharp ones. An input the code constants could not provide.

---

## 1. Palette — DIRECTIONS, not a settled answer

> ⚠️ **This section holds one worked direction and three alternatives. It is not
> decided.** Keeping the brand colours (W05) does not determine what they sit *on*, and
> the ground changes the feeling far more than the hue does. To be resolved by building
> comparable swatches and looking, not by argument.

| | Direction | Feeling | Risk |
|---|---|---|---|
| **A** | **Violet on warm paper** — unbleached bone and clay. Worked out below. | Editorial, calm, rooted. Furthest from the category. | Warm neutrals can drift towards "wellness brand" if the violet is not held firmly. |
| **B** | **Violet on dark ground** — `#2D144C` as the *default* surface, not just inverted sections. | Premium, cinematic; the violet glows rather than sits. Spotify's model. | Harder for long-form reading, which matters for an SEO-first build. |
| **C** | **Cool and clean** — essentially the current app, tightened. | Familiar, safe, ships fastest. | Least differentiation; nearest to iMumz. |
| **D** | **Warm, hotter** — clay and terracotta rather than bone and cream. | Earthier, more Indian, more assertive. | Can fight the violet; a narrower path to get right. |

**Direction A is worked out below because it is the current recommendation, not because
the others were dismissed.** B is genuinely interesting for the marketing site paired
with A for `/reads`.

### ⭐ Direction A — and it is already built, in Father Mode

> **Updated 2026-08-12 after the first firsthand look at the app** (`APP-AUDIT.md`).
> Direction A stopped being a proposal the moment anyone opened the product.
> **Father Mode already runs warm cream ground + serif display + one restrained accent
> + circular line icons + calm empty states.** The mother's Prepare tab does the same.
> The two best-looking surfaces in the app are already Direction A; only the mother's
> Today screen is still lavender card-soup.
>
> So the recommendation is not "adopt a new direction" — it is **"bring the mother's
> Today to the direction the product already found."** Cheaper, lower-risk, and
> evidenced from inside the product rather than argued from outside it.
>
> Confirming tell: the Ask Veda FAB stays violet in Father Mode and is the one jarring
> element on those screens — never re-themed, because a colour that means *important*
> rather than *actionable* has nowhere to sit on a considered surface.

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

## 2. Colour discipline — ⭐ ONE LOUD, MANY QUIET

> **Decided 2026-08-14 (Q4). This is the governing rule; the job table below sits under
> it.** The question is not *how many colours* but **how many are allowed to be LOUD.**

**Exactly one loud colour: violet `#6A30B6`.** It means *"you can act on this"* and
nothing else. Every other hue lives **quiet** — as soft card backgrounds in a controlled
band where **saturation and lightness are held constant** and only the hue varies (Flo's
technique, `FLO-TEARDOWN.md` §1).

That buys visual variety without noise: a content grid can carry a dozen different soft
grounds and still read as one system, because only one thing on screen is ever shouting.

**It also fixes the measured defect:** the Tools hub currently carries ~7 accent hues at
full strength in one 2-column grid (`APP-AUDIT.md` §3.5). Under this rule those become
quiet grounds, and the only strong colour left is the one that tells her where to tap.

The constraint behind it: enhance usability, do not dilute identity, do not add so many
colours that nothing is ownable. The per-colour jobs below still hold — they say *what a
hue means when it appears*; the rule above says *how loudly it is allowed to say it.*

| Colour | Its ONE job | Never |
|---|---|---|
| **violet `#6A30B6`** | *You can act on this.* Links, buttons, active state. | Never "this is important". Never a gradient. Never a background wash. |
| **ink-deep `#2D144C`** | The dark ground for inverted passages. | Not a text colour. |
| **coral `#FF5A79`** | ⭐ **The child.** Wherever the content is about the baby rather than the mother — the size card, the growth line, the child's own profile. **Revised after looking at the mark** (§0a): the logo *is* a violet parent holding a coral child, so coral already carries meaning and should not be exiled to the logo. | Never a generic second accent — that is what makes a palette read as generic. Never used because a section "needs some colour". If it is not about the child, it is not coral. |
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
- **LOUD colours on any screen: 1** (violet). Quiet grounds are unlimited, provided they
  stay inside the controlled saturation/lightness band.
- **Dark-mode variants: 0** — light only, by decision (§7a)

---

## 3. Type — commit to Fraunces

Fraunces is variable with `SOFT` and `WONK` axes — genuine character a competitor using
Poppins cannot imitate. It is currently restricted to "hero moments only", which is why
the identity is not carrying.

| Face | Role |
|---|---|
| **Fraunces** | **Display and headline only.** `WONK` on at display sizes — the quirk is the signature. *(Decided 2026-08-14, Q3 — supersedes the earlier proposal to set article body in Fraunces.)* |
| **Plus Jakarta Sans** | **UI *and* long-form body** — labels, buttons, navigation, and article text. |
| **Manrope** | Data and metadata — reading time, dates, category labels. |

**Why body went to sans.** This is what Prepare and the whole TTC stage already do, and
they are the two best mother-side surfaces in the app. Fraunces carries the identity where
it is seen at size; Plus Jakarta Sans stays legible one-handed at 2am on a mid-range
Android. Serif body was unproven at small sizes and a real risk in exactly the reading
condition the product exists for.

⚠️ **Coupling worth knowing:** the Devanagari pairing follows the Latin choice —
`pv_fonts.dart` maps Fraunces → **Noto Serif Devanagari** and Plus Jakarta Sans → **Mukta**.
Deciding the Latin display face decided the Hindi one too, and Hindi body text follows
Mukta for the same legibility reason.

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
| **Ornament** | ⭐ **NONE.** Richness comes from imagery instead. *(Decided 2026-08-14, Q6 — supersedes the Good Earth margin-whisper proposal.)* | Flo; and TTC + Prepare already do this |
| **Palette** | The warm ground in §1 *is* the textile palette. Add petrol/teal only if a real need appears. | Nicobar, Good Earth |
| **Cadence** | Literary and seasonal in copy, in both languages. | Good Earth |
| **Material** | Photograph texture close, in natural light — weave, block print, cane, paper. | both |
| **Composition** | Full-bleed with one floating subject *(Q8 — see §4b)*. | Flo |

**Why ornament went to zero.** The margin-whisper was a good idea with a real source, but
three things beat it: Flo achieves richness with **no ornament at all**, purely through
imagery; ParentVeda's two best mother-side surfaces (TTC, Prepare) already carry none; and
ornament is the single highest kitsch risk in the system and needs an illustrator to get
right. **Indian-ness comes from palette, composition, material and cadence — never from
applied decoration.**

**Never:** marigolds in corners, paisley borders, saffron gradients, rangoli dividers,
mandala backgrounds. *(Now enforced trivially, since there is no ornament layer at all.)*

## 4b. Hero composition — full-bleed, one floating subject

*(Decided 2026-08-14, Q8 — supersedes the Nicobar contained-aperture proposal.)*

A soft gradient field, **one subject floating in it, one number.** Nothing competing.
Flo's pregnancy hero is the reference (photoreal embryo, `2 days`, a Details button), and
ParentVeda's parenting stage already does a version of it with its dark card.

Chosen over the contained aperture because it **scales across every stage and content
type**, and because putting the subject alone in a field is what makes it feel considered
rather than arranged.

## 4c. Photography of people — faces, cropped and softly lit

*(Decided 2026-08-14, Q9 — supersedes the earlier "face is not the subject" rule.)*

**Faces are allowed and encouraged**, on three conditions: **cropped tight**, **softly
lit**, and **mid-experience rather than smiling at camera**. Flo uses faces heavily and it
reads as warm rather than stock precisely because of those three.

The earlier faces-not-the-subject rule was over-cautious — it protected against the
AI-uncanny problem but risked reading as evasive on a product about people.

**Assignment still governs** (§4a): faces for **emotion and symptom**; faceless for
**objects and process**.

---

## 4a. ⭐ The image system — medium chosen by subject, not by taste

Derived from Flo (`DESIGN-BRIEF.md` §5.3a), which runs **six distinct image modes** and
still reads as one system. This is the most directly copyable thing found in the whole
reference pass, and it answers W09 ("fill every image hole") properly: **the answer is not
"get images", it is "assign a medium to each content type, then produce within that."**

### What holds six modes together

1. **One background family.** Every image sits on a flat pastel field — mint, blush,
   lavender, peach, sky, cream — all within a narrow lightness and saturation band.
   Whatever technique sits on top, **the ground is constant.**
2. **Everything is isolated on that ground.** No environmental scenes. Objects cut out,
   people cropped tight, renders floating. One subject, one field.
3. **Soft diffuse light everywhere.** Photos, renders and vectors share a lighting
   temperature. Nothing dramatic or high-contrast.
4. **Warm, skin-adjacent tones dominate**, including inside the vector illustrations.

### The assignment table — the actual rule

| Mode | Used for | Why that mode |
|---|---|---|
| **Flat vector illustration** | Bodies, positions, behaviours | Abstract enough not to embarrass; shows diverse skin tones without casting |
| **Cut-out photography** | Objects she must recognise — food, supplements, kit | You cannot illustrate food she needs to identify |
| **Photoreal 3D render** | The baby | Reverence + anatomical accuracy. A cartoon trivialises; a photo is impossible |
| **Documentary photography** | Emotion and symptom — pain, touch, holding a newborn | Real feeling needs real faces |
| **Ultrasound / clinical imagery** | Clinical truth | Nothing else can stand in |
| **Conceptual 3D props** | Abstract ideas (a gold "0" balloon for *The Zero Symptoms Club*) | Gives an unpicturable concept a physical object |

**Two traps this dodges by construction:** never draw a realistic baby *cutely*
(trivialising), never photograph an intimate body part (embarrassing). The assignment
avoids both without anyone having to exercise taste in the moment.

**Label the medium on the card** — `▶ Video`, `▶ Video Course`, `▶ Animation`. Part of the
visual variety is honest format signalling.

### Where ParentVeda stands today

**One mode for nearly everything: tinted icon squares in ~7 accent hues** (see
`APP-AUDIT.md` §3.5). That is why the Tools grid reads flat while Flo's reads considered.

**Production note:** six pipelines sounds expensive; three are cheap — cut-out object
photography, generated 3D renders, and a vector system commissioned once as a set. The
costly ones (documentary photography, clinical imagery) are also the ones needed least
often.

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

## 6a. ⭐ The content card — rich image, stripped metadata

*(Decided 2026-08-14, Q2. This dissolves the contradiction between W01 (SEO-first) and the
earlier austere-editorial proposal — we get both.)*

**A card carries: a distinctive image, a title, and optionally a format badge.** That is
all.

**In the browse layer, never:** view counts · like counts · author avatars · dates ·
"Read more" buttons · progress rings · anything that accrues.

- The **image** does the pulling — which is what wins a tap from someone arriving from
  search, and it is why the SEO-first decision does not force clutter.
- The **stripped metadata** does the calming — which is what stops a grid reading as a
  pile.
- **Every image is visually distinct** (§4a). No repeated icon, no template.
- Cards live in **named rails, two visible at a time**, titled in plain language a mother
  would use — never a taxonomy label (`FLO-TEARDOWN.md` §2).

**Author name and reading time still appear — inside the article, not on the card.**
Accountability at the point of consumption, not decoration at the point of browsing.

**Measured contrast:** ParentVeda's community currently shows view counts to 56.4K and its
Tools cards repeat "Open →" 24 times (`APP-AUDIT.md` §3.5, §3.7). Both go.

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

## 7a. Dark mode — light only, deliberately

*(Decided 2026-08-14, Q5.)*

**There is no dark mode, and that is a decision rather than an omission.**

Warm paper (§1) **is** the identity. A dark variant halves its distinctiveness and doubles
every palette, image and contrast decision — six image modes would each need to work on
two grounds.

The counter-argument is real and worth recording: the product's stated use case is a
frightened woman reading at 2am, one-handed, which is the strongest possible case for a
dark surface. It was weighed and declined. **Revisit only if users actually ask** — not
because it feels like a gap.

**Consequence for the countable invariants (§2): dark-mode variants = 0.**

## 7b. ⭐ Positional consistency — the rule habit depends on

The user's stated goal is that navigation becomes subconscious: *"you just know the
clicks… it's on your fingers."* The mechanism is **positional consistency: the same thing
is always in the same place, and the same gesture always does the same thing.**

**Three measured violations to fix in the revamp:**

1. **Three stages, three different bottom navs** — `Today · Prepare · Tools · Calendar ·
   Community` (TTC and pregnancy) vs `My Child · Brain · Tools · Community · Products`
   (parenting). She re-learns the app at the moment a newborn arrives.
2. ⚠️ **The nav pill re-flows when the active tab changes.** Measured: "Today" sits at
   x≈188 when active and x≈120 when not — **the target physically moves under her thumb.**
3. **Floating chrome covers content**, so what sits under her thumb is not stable either.

**Habit cannot form on a surface that moves.** This is not an aesthetic concern; it is the
direct enemy of the quality the product is trying to have.

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
