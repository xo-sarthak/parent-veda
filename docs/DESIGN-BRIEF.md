# ParentVeda — the design brief

> **What this is.** The evidence layer for the design work: why the current website and
> app read as generic, what the buyer actually hates, where the differentiator is, and
> what to look at instead. Written 2026-08-12.
>
> **What this is not.** A design system — that is `DESIGN-LAYER.md`. A record of what is
> settled — that is `DESIGN-DECISIONS.md`.
>
> **Status: in flux.** Deliberately kept out of `memory/` and `CLAUDE.md` so the
> auto-loaded brain is not churned while this is still moving. Settled points graduate
> there later.

---

## 1. The problem, stated precisely

The website reads as AI slop — generic enough to belong to any product, carrying no
evidence that a specific team with a specific opinion built it. The app is further along
but on the same road.

**The strategic frame that governs everything:**

IMDb survives a plain interface because it has a moat — data nobody else holds. The
plainness is *survivable*, not free.

ParentVeda has no such moat. Nothing in "what happens in week 22" is unavailable from
Mylo, BabyChakra, FirstCry or theAsianparent. **Content is table stakes.**

Therefore the differentiator is not "content plus attractive design." It is that the
**felt experience is the product** — calm not alarmist, respectful not infantilising,
Indian without kitsch. Design is the only channel that differentiator travels through.

**This work makes the differentiator visible. It does not decorate a finished thing.**

---

## 2. Why the previous attempt produced blandness

`C:\parentveda-web2` — a full ten-phase, approval-gated build with ~97,000 words of
research. The output read as bland. Four causes, all of which must be designed around.

### 2.1 It never actually looked

`design/01-research/07-firsthand-browser-notes.md` covers **one site: Oura.** Its own
header states the other researchers *"worked from fetched markup, which cannot see
rendered typography, spacing, colour in context, or motion."*

Forty-plus sites "researched", one seen. An LLM designing from memory emits the
statistical average of every site it has seen — which *is* AI slop. **Skipping the
looking is not a process slip; it is the mechanism.**

Three compounding errors:

- **The reference set was self-defeating.** Apple/Stripe/Linear/Notion are the most
  imitated sites in existence; their aesthetic has been absorbed until it *is* the
  model's unprompted default. The research even documents this (Tailwind's co-creator
  apologising for `bg-indigo-500` becoming every AI UI on earth) — then studies them.
- **They don't transfer.** apple.com works on a photography budget in the millions and
  brand equity that makes 70% empty screen read as confidence rather than unfinished.
- **Wireframes-first, colour-later is broken.** Photography, typographic scale, texture,
  asymmetry and rhythm are invisible in a wireframe and cannot be applied afterwards as
  paint. Freezing structure first sets the ceiling before any of them are considered.

> ### ⚠️ STANDING RULE
> **When studying references, produce per-site evidence — what was opened, what was
> observed, what is being taken. If a site was not opened, say so rather than writing
> from memory.** This failure is invisible from outside, so proving it is the
> assistant's job, not the user's to catch.

### 2.2 The design system was purely subtractive

Measured on the shipped CSS:

| Metric | Value |
|---|---|
| Total CSS | 490 lines |
| Easing curves | 1 |
| `transition` declarations | **7, whole site** |
| `box-shadow` | 3 |
| Gradients | 2 (one is the logo) |
| Photographs of people | 0, by law |
| Scroll animation | none, by law |

**Every rule was a removal.** The research was an *anti-pattern* study, so it produced an
**anti-design**: a site that successfully avoids every slop tell and puts nothing in
their place.

**Removing every cliché does not leave you distinctive. It leaves you with nothing** —
which reads as austere and unfinished. Individual laws were defensible; the *set* had no
additive counterweight anywhere in it.

### 2.3 Its warmth layer was never built

Its own critique, §10.5: *"On structure and restraint: yes. On finish: no, and not close
— grey circles where faces belong, placeholder prose in article bodies."*

Verified: `PHOTO` placeholders in four files, `[Full Name]` / `[Institution]` /
`[registration number]` brackets in the content layer, unwritten article bodies, a
waitlist that does not persist.

**Consequence: the blandness was never fixable by better prompting, better skills, or
animation libraries.** It needed roughly four real assets — a named reviewing clinician
with a photograph, real article bodies, an illustration set, real photography.

### 2.4 Its strategic wedge was never load-bearing

The site's centre was *"Hinglish in Latin script is empirically unoccupied — 57.8% of
Indian users prefer it."* Decision D015 kept Hinglish and deferred Devanagari.

**The app is English by default** (Hindi is an option). So the site made a language
positioning the strategic centre of a product that opens in English. Independently
corroborated below: language complaints are **0–1.6%** of critical reviews.

---

## 3. What the buyer actually hates — 227,934 reviews

Mined from `research/competitors/` — five apps, both stores, 35,272 reviews at 1–2★.
Method: `scratchpad/mine.py` (theme regex) and `mine2.py` (open-ended term and phrase
extraction, so the data could name themes rather than only confirm priors).

### 3.1 Data quality — read before trusting any number

- **theAsianparent is not an India proxy.** Its critical-review corpus is dominated by
  Indonesian/Malay/Thai (`bisa`, `saya`, `aplikasi`, `tidak`, `iklan`). Useful for
  product-failure patterns, not Indian sentiment. The previous research treated it as a
  category competitor without this caveat.
- **BabyChakra: n=20 total. Unusable.** Any claim from it is noise.
- **FirstCry is e-commerce** — 31.5% of its reviews are 1–2★ and 48.6% of those concern
  orders and delivery. Excluded from content findings.
- **Reviews capture post-adoption anger, not pre-adoption trust.** A mother who never
  installed leaves no review. Strong on *why people leave*, silent on *why people
  choose*. Do not use one for the other.

Volume: theAsianparent 87,979 (2,485 low) · FirstCry 93,313 (29,409) · Mylo 44,278
(2,915) · iMumz 2,144 (458) · BabyChakra 20 (5).

### 3.2 The headline: what she hates is not aesthetic

Ranked across the three content apps:

| # | What she says | Evidence |
|---|---|---|
| 1 | **It doesn't work.** Can't log in, blank after update, *"loading loading loading"* | iMumz **20.1%**, FirstCry 12.7%, theAsianparent **11.5%**, Mylo 8.7% |
| 2 | **It took my money and hid the terms.** | iMumz **22.1%**, FirstCry 21.2%, Mylo 10.4% |
| 3 | **It hunts me.** Sales calls after install; can't delete the account | FirstCry 8.5%, iMumz 5.2%, Mylo 3.5% |
| 4 | **It ignores me.** Questions unanswered for days | throughout verbatims |
| 5 | **It sells at me.** | Mylo **24.3%**, FirstCry 48.6% |

**What she does *not* complain about:**

| Expected theme | Actual share of 1–2★ |
|---|---|
| Wrong or unsafe advice | **0.3–0.6%** |
| Thin / generic / repeated content | **1–2%** |
| Language / no Hindi | **0–1.6%** |
| Doctors and credentials | **0.1–3.7%** |

The previous strategy rested on a language wedge, calm-versus-optimisation, and a
credentials architecture. **The buyer complains about none of the three.**

> **Honest qualifier.** Absence of complaint ≠ absence of importance. Nobody writes a
> review praising credentials they never had to think about, and reviews only capture
> people who installed. The trust architecture is not refuted — it is simply not what
> makes her furious, and should stop being treated as the centre.

---

## 4. ⭐ The wedge — *nobody is chasing you*

The repeated, visceral, unoccupied complaint is not surveillance. It is **pursuit**:

> *"The moment you install their app, you will keep getting calls from them. I got so
> pissed off after blocking their numbers multiple times, that finally I had to uninstall
> their app."* — iMumz
>
> *"Instead of telling hundred times they won't stop calling me. I am not even able to
> delete my account."* — iMumz
>
> *"Don't buy membership, it is total waste of money. You get nothing extra. It's a
> scam."* — iMumz
>
> *"All it has a paid version only. But in ads they don't mention about it."* — iMumz

### 4.1 It is NOT an anti-monetisation position

**Critical, and easy to get wrong.** ParentVeda will promote, sponsor and sell (Prepare
tab, Brand Studio, commerce). The data does not show mothers objecting to products being
*paid*. It shows them objecting to being pursued.

> **Operative form: *you can always leave, and you always know the price before the
> pitch.***

A promo bar is fine. An offer that **blocks the content, demands a phone number, or
cannot be dismissed** is not.

### 4.2 Why it beats its predecessor

- **Evidenced**, not inferred
- **Script-independent** — unaffected by the English/Devanagari question
- **Demonstrable on the page** rather than merely asserted
- **Structurally unavailable to competitors** — Mylo and FirstCry cannot claim it because
  revenue is per-order; iMumz cannot because its funnel *is* a call centre

---

## 5. The reference set — seen firsthand, 2026-08-12

Every site opened in Chrome at 1440×900 and scrolled. Per the standing rule (§2.1).

### 5.1 ⭐ The cross-site finding, worth more than any single site

**Of eight sites opened, six blocked their own content within seconds.**

| Site | Interrupted on arrival? |
|---|---|
| Lovevery | **Yes** — promo bar + 10%-off modal demanding email *and* child's DOB + chat widget |
| Maven | **Yes** — promo bar + full cookie wall over the content |
| Aesop | **Yes** — geo modal (stuck through the whole scroll) + cookie bar + shipping promo |
| iMumz | **Yes** — "WhatsApp us" / "Talk to us" pinned in the nav |
| Good Earth | **Yes** — cookie modal stuck through the scroll + chat widget |
| Kinfolk | **Yes** — cookie modal + bottom subscribe bar |
| **Aeon** | **No** |
| **Nicobar** | **No** — one thin festival banner, relevant rather than a discount chase |

**Not interrupting is unoccupied even among brands with vastly more money and taste than
ParentVeda.** It is not a compromise forced by being small. Strongest available evidence
for §4.

### 5.2 Per-site

**Lovevery** — *closest structural analogue: content that changes as the child grows.*
TAKE: stage-based organisation ("Shop by Age"); photography of real children in real
rooms (natural light, a rug, toys on the floor); concrete checkable claims ("delivered
every 2–3 months", "week-by-week developmental tips") where competitors write vagueness;
video-led hero.
REJECT: the 10%-off modal demanding a child's date of birth.

**Maven Clinic** — *spans fertility → pregnancy → postpartum → paediatrics; our span.*
TAKE: **deep forest green on warm bone paper** — neither clinical blue nor pastel pink,
warmth from *temperature*; **register-switching typography** — *"Lowering costs by
**improving care**"* moves from sans to italic serif mid-headline so the human word
carries a different voice; dark, low-key, intimate photography (a father and child on a
sofa, faces half-turned, shot in shadow).
REJECT: it is B2B — "Book a demo", "Employers". Take the surface, not the structure.

**Aeon** — ⭐ *strongest structural reference for an SEO-first build.*
TAKE: every card is exactly four elements — small-caps mono category label
(`Essay / Knowledge`), serif headline, one sentence, author name. No "Read more" button,
no engagement counts; **reading time as a courtesy** ("20 minutes") — a small true number
telling her what she is committing to; **an author name on every piece**; commissioned
illustration where a concept has no photograph; **unequal card heights, some with images
and some without** — the asymmetry that stops a grid reading as a template, and it is
free.
REJECT: the hero is a flat grey gradient block, the least finished thing on the page.

**Nicobar** — ⭐ *the answer to "Indian without kitsch".*
A real woman photographed **inside a hand-painted Mughal-miniature set** — painted
architecture, cypresses, sky — framed in a circular *jharokha*. The reference is
art-historical and compositional, not decorative. Palette inherited from miniature
painting: dusty sage-teal, ochre, deep crimson, warm cream stone. Second scroll:
slow-motion film, shallow focus, one line of type. Nav is a hamburger, four words, three
icons.

**Good Earth** — ⭐ *second Indian data point; confirms rather than repeats Nicobar.*
TAKE: **the headline used as a frame, not a banner** — "Lounge" far left, "Away" far
right, photography between them; **ornament confined to the margins at low opacity** — a
hand-painted green parakeet and grey cloud-flowers bleeding in at the page edges;
petrol-blue and maroon; copy with literary seasonal cadence (*"The rainy days are here to
stay, linger in the finest bedspreads as you listen in on their tinkering
conversation"*); **material texture photographed close in natural light** — kantha
stitch, block print, cane.

**Kinfolk** — *editorial confidence and the quiet index.*
TAKE: all-caps wide-tracked high-contrast serif; **whitespace as the dominant material** —
first screen is a logo, two lines, a cover, "Buy | Read"; ⭐ **the quiet index** — "Latest
Stories" as a two-column list (category left, title right) mostly at low opacity with the
active row raised. Dense without being loud; far more elegant than cards and directly
usable for `/reads`; environmental portraiture where **the subject's name IS the
headline**; no colour beyond what the photograph brings.
REJECT: hamburger-only nav is too austere for a site that needs SEO discoverability.

**Aesop** — *material restraint, partly obscured by its own modal.*
TAKE: warm amber and sepia, brown glass, brass, low interior light; typography kept
deliberately **small** everywhere; copy with a voice ("a long-awaited homecoming").

**iMumz** — ⚠️ *the contrast case; nearest Indian competitor.*
Almost a complete checklist of the tells: **lavender-violet gradient wash**; **three
identical feature cards** (Fertility / Pregnancy / Parenting — title, one line, "Discover
More →"); **cut-out stock couples with white halos** on the gradient; generic rounded
sans; an unverifiable superlative ("the strongest support system"); a half-empty card
never finished. And **the pursuit is in the chrome** — green "WhatsApp us" / "Talk to us"
pinned to every screen. That is the call centre the reviews describe, visible before a
single scroll.

### 5.3 ⭐ The twice-sourced rule for "Indian without kitsch"

From Nicobar **and** Good Earth independently:

> **Be Indian in composition, palette, material and cadence — never in applied motif.**

- **Composition** from miniature painting (a contained aperture, not a full-bleed rectangle)
- **Ornament** in the margins at low opacity, never centred as a banner
- **Palette** from textile and painting — dusty teal, ochre, crimson, petrol, maroon,
  warm cream — not from flags and spices
- **Cadence** literary and seasonal in the copy
- **Material texture** photographed close, in natural light

### 5.4 Not seen — recorded, not inferred

- **Raw Mango** — `Page.captureScreenshot` timed out (30s) and wedged the renderer.
  **The identical CDP bug the previous attempt hit** (four times on parentveda.in, once
  on ouraring.com, once on a static local page). Its retraction of that critique section
  was correct: the bug is environmental to Chrome/CDP on this machine.
- **Frida** — `frida.com` is **hard-blocked at the extension level, not
  permission-gated**. The extension's approved-sites list is empty while all eight other
  sites browsed fine. No toggle exists. **Closed — do not re-attempt.**
- Note: the Chrome extension can sit in a **"Paused"** state; check the toolbar before a
  browsing pass.

---

## 6. Rejected classes and tools, with reasons

### 6.1 Reference classes rejected

- **Designer portfolios and award showcases** (pacomepertant, aikawakenichi,
  podium-studios, hirotosato0127, vshslv, awwwards, igloo.inc, Oryzo, terminal-industries,
  Shopify Editions) — built to impress other designers: heavy motion, experimental
  navigation. The user is a frightened woman at 2am. Importing this class repeats the
  previous failure in a new costume.
- **The premium SaaS cluster** (Apple / Stripe / Linear) — the most-imitated aesthetic on
  earth, therefore the model's unprompted default. Studying it to escape generic is
  circular.

### 6.2 Tools rejected

- **Haikei** — generates SVG blob/wave backgrounds: literally the number-one AI-slop
  tell. Self-defeating.
- **Manus** — a describe-it-and-it-builds-it agent. `docs/WEBSITE-MANUS-PROMPT.md`
  suggests this may be how the current live site was made.
- **ShaderGradient / liquid-glass-js / react-three-fiber / liquid-logo** — impressive and
  free; wrong here. ShaderGradient *is* an animated gradient blob; liquid glass is
  Apple's current language (so copying it is the circularity again, and dates the site);
  and glassmorphism reads tech/crypto/AI-startup, not companion-for-a-frightened-mother.
- **Component kits** (21st.dev, Kokonut, Bklit, Origin, Motion Primitives) — fine for
  speed, but every AI-built site uses them, so they push toward generic.

### 6.3 Tools worth taking

- ⭐ **Playwright MCP** — highest-value item available. Makes the §2.1 failure
  *impossible*: the agent can screenshot and verify what it actually looked at and built.
- **frontend-design** (`anthropics/claude-code` → `plugins/frontend-design`) — official,
  free. Commits to an aesthetic direction *before* code: the additive step that was
  missing.
- **Vercel Web Design Guidelines** (`vercel-labs/agent-skills`) — 100+ rule post-build
  audit.
- **design-loop** (`jezweb/claude-skills`) — a "baton" file passing design decisions
  between pages; relevant to a multi-page SEO build.
- **taste-skill** (`Leonxlnx/taste-skill`) — three dials: experimental, motion, density.
- **Mobbin**, **Pinterest moodboards**, **Real Time Colors** — real, cheap, and Pinterest
  is *additive*, which is what the previous system lacked.

### 6.4 ⚠️ The filter to apply to all future inbound

Nearly all material arriving from Instagram/YouTube is **effects** — shaders, glass,
blobs, motion libraries, component kits — and the "$10,000 website in 21 minutes" genre
has a shared title template across dozens of channels. One video in that rail is called
*"Claude Design AI Slop (FIXED in 9 Minutes)"*: **the genre has spawned its own
counter-genre**, which is the proof its method produces slop.

> **The source optimises for impressive-in-a-reel. This product needs
> trustworthy-at-2am.** These diverge far more often than they overlap.

Also worth knowing: recommendations sometimes arrive via paid placement. Higgsfield —
item 4 on page 1 of the user's notebook — is an affiliate link in the first video's
description.

### 6.5 What the videos did teach, stripped of the funnel

Transcripts pulled in full via Supadata and read.

1. **Reference-fed, never "make it beautiful."** Every successful test in the
   DesignCourse video supplied a screenshot, URL or video. The best-rated result came
   from the *most constrained* prompt.
2. **"Check your work in DevTools"** — one line, and it is the verification loop §2.1
   lacked.
3. **Adversarial review *before* building** — attack the concept while it is still a
   sentence.
4. **Intent first**: *"when someone leaves this page, what is the one thing she should
   feel or do?"*
5. ⭐ **The "$10,000" look is generated video, not design craft.** *"This whole website
   cost about $10. Most of it actually is all the individual videos that blend
   together."* Three of eight reference sites get their expensive feel from moving image.
6. **Both creators, with opposite incentives, say the model is not the differentiator.**

---

## 7. Open

- Whether the previous research's precise measurements (Headspace "one curve used 210
  times", Calm 150% leading, WHOOP 80%, "four text tints") are real or from memory.
  **Do not reuse until spot-checked.**
- First-party evidence not yet reviewed: `ParentVeda app review - July 18.docx`,
  `ParentVeda_Pregnancy_App_Review_Chat.md`, `Dev review 1.pdf` in Downloads. Confirm
  with the user whether these are real user reactions before treating them as user data.
- Semrush content architecture — **paused at the user's instruction**, to run in a
  dedicated session, with permission asked first.
