# ParentVeda website — Manus build prompt

> **How to use this file.** Everything under "THE PROMPT" is written to be pasted
> into Manus as-is. The section above it is for you, not for Manus.
>
> Manus does better with a big, specific, single brief than with a vague one it
> has to interview you about — but it still degrades on very long single-shot
> builds. So: **paste Phase 1 first, let it ship, then paste Phase 2 and Phase 3
> as follow-ups.** The phase split is at the bottom of the prompt and Manus is
> told to expect it.
>
> **The one tension to watch.** You asked for "new age, high tech, parallax,
> amazing." ParentVeda's product voice is calm, warm, clinical-safe, India-first.
> Those pull in opposite directions, and if you don't resolve the tension in the
> brief, the model resolves it for you — usually toward neon-gradient SaaS, which
> would make a pregnancy product feel untrustworthy. The prompt below resolves it
> explicitly with a rule ("cinematic, not arcade") and a banned-patterns list.
> That single constraint is the highest-leverage thing in the whole document.

---

## THE PROMPT

You are building the public marketing website for **ParentVeda**. Read this
entire brief before writing any code. Do not ask me clarifying questions —
where something is unspecified, make the choice a senior product designer at a
top-tier studio would make, and note the assumption in a `DECISIONS.md`.

---

### 1. What ParentVeda is

ParentVeda is an India-first, bilingual (English + Hindi) family companion app
that walks a family through three life stages in one continuous product:

1. **Trying to Conceive** — cycle and fertility understanding, IVF/IUI
   companionship, care pathways, clinical explainers.
2. **Pregnancy** — week-by-week journey (weeks 4–40), Garbh Sanskar practices,
   scans and appointments, tools, journal, community.
3. **Parenting (0–12 years)** — daily briefing, development leaps, vaccination,
   health record, feeding/sleep/growth, food, video learning, reading.

Running through all three:

- **Ask Veda** — an AI companion that answers pregnancy and parenting questions
  in a structured, sourced, 7-section format. Available in-app **and on
  WhatsApp** — "one brain, two doors." It refuses to guess. It never diagnoses.
- **Bilingual by design** — every string exists in English and in warm spoken
  **Hindi in Devanagari** (आप, not textbook Hindi). Not a translation layer
  bolted on; the second language is a first-class citizen.
- **Father Mode** — a genuine second product for fathers, in its own visual
  skin, reached through a pairing code from the mother's app.
- **ParentVeda+** — a separate app for doctors and clinics.
- **Employer-sponsored access** — companies can sponsor the app for their staff.

**Positioning line to design around:** most apps in this category are a tracker
with content stapled on. ParentVeda is a *companion that stays* — it does not
end at delivery, it does not end at year one, and it speaks the language the
family actually speaks at home.

**What the website is for**, in priority order:
1. Get an app install (Play Store / App Store).
2. Make a first-time visitor trust it within 8 seconds — this is a health
   product for pregnant women in India; trust beats cleverness every time.
3. Serve three secondary audiences with their own pages: doctors/clinics,
   employers/HR, and brands/sponsors.

---

### 2. Tech stack — build it exactly this way

- **Next.js (App Router, latest stable), TypeScript, React Server Components**
  where possible. Static export friendly.
- **Tailwind CSS** with a custom design-token layer (see §3). No component
  library that imposes its own look — no MUI, no Chakra, no shadcn defaults left
  visually untouched. shadcn/ui is allowed only as unstyled primitives you then
  restyle completely.
- **Motion:** `framer-motion` for component-level and layout motion,
  **GSAP + ScrollTrigger** for scroll-driven timelines and pinning, and
  **Lenis** for smooth scrolling. Use all three; they do different jobs.
- **3D / WebGL:** only where §5 explicitly calls for it, via `@react-three/fiber`
  + `drei`, lazy-loaded and code-split so it never blocks first paint. If a
  section can be done convincingly with SVG + CSS instead of WebGL, do that.
- **i18n:** `next-intl`. Two locales, `en` and `hi`, routed as `/` and `/hi`.
  Do not use machine translation for the Hindi — write it properly (see §7).
- **Icons:** `lucide-react` only. **No emoji anywhere in the interface chrome.**
- **Forms:** react-hook-form + zod. Submissions POST to a stubbed
  `/api/contact` route handler that logs and returns 200 — leave a clearly
  marked TODO for the real endpoint.
- **Deploy target:** Vercel. Include `vercel.json` if anything needs it.
- **Analytics:** a thin `track(event, props)` wrapper in `lib/analytics.ts` that
  currently console-logs, so a real provider is a one-file swap. Instrument
  every CTA.

Deliver a real repository: sensible folder structure, typed content in
`content/` as TS objects (not hardcoded in components), `README.md` explaining
how to run it, and `DECISIONS.md` listing every assumption you made.

---

### 3. Brand tokens — use these exact values

These are lifted from the shipping app. Do not invent a new palette.

**Core**
| Token | Hex | Use |
|---|---|---|
| `primary` | `#6A30B6` | ParentVeda purple — the brand |
| `secondary` | `#FF5A79` | coral/pink — warmth, hearts, accents |
| `tertiary` | `#7A4600` | earthy brown — grounding, Ayurvedic notes |
| `ink` | `#2D144C` | deepest purple, used as near-black for text |
| `neutral` | `#7B757F` | warm grey — secondary text |

**Purple ramp:** `50 #F3EFF9`, `100 #E4DAF2`, `200 #CBB6E5`, `300 #AD8DD7`,
`400 #8F64C8`, `500 #6A30B6`, `600 #5D2AA0`, `700 #502489`, `800 #401D6D`,
`900 #2D144C`

**Coral ramp:** `50 #FFEFF2`, `100 #FFDBE2`, `200 #FFBDCA`, `300 #FF9CAF`,
`400 #FF7B94`, `500 #FF5A79`, `600 #E04F6A`, `700 #BF435B`, `800 #993649`,
`900 #6B2633`

**Earth ramp:** `50 #F3EFEA`, `100 #E4DACC`, `200 #CCB99E`, `300 #B2946B`,
`400 #976F38`, `500 #7A4600`

**Surfaces:** `#FFFFFF`, `#FBF9FE`, `#F3EEF7`, `#ECE5F2`, `#E6DEED`

**Stage accents** (used to tint each stage's section — see the colour-temperature
rule in §5): TTC = `#3E6DA6` (calm blue) · Pregnancy = `#6A30B6` (purple) ·
Parenting = `#C98A2B` (warm amber) · Father Mode = `#2D3436` (slate) ·
Success/growth = `#1F8A5B` · Attention/health = `#C6295A`

**Type**
- Display / headings (English): **Fraunces** — variable, use optical size and a
  slight `wght` shift on scroll-reveal. This serif is the brand's voice; do not
  swap it for Inter.
- Body (English): **Plus Jakarta Sans**
- UI / labels / numbers: **Manrope**
- Hindi display: **Noto Serif Devanagari**
- Hindi body & UI: **Mukta**

Hindi glyphs sit differently — when the locale is `hi`, bump line-height by
~0.15 and reduce letter-spacing to 0. Devanagari must never be letter-spaced.

**Radii:** 12 / 16 / 24 / 32px, plus full-round pills. **Shadows:** long, soft,
low-opacity purple-tinted (`0 24px 60px -20px rgba(45,20,76,0.18)`) — never
grey, never harsh.

---

### 4. Sitemap and page-by-page content

Write **real copy**, in ParentVeda's voice — warm, plain, specific, never
markety, never exclamatory. No lorem ipsum anywhere. No fabricated statistics,
no invented testimonials attributed to named real-sounding doctors, no fake
press logos. Where a number or quote is needed, use a clearly-marked placeholder
component (`<Placeholder kind="testimonial" />`) that renders a tasteful
"coming soon" state and is listed in `DECISIONS.md`.

**`/` — Home**
1. Hero — headline, one-line subhead, two CTAs (Get the app / See how it works),
   the ambient hero scene (§5.1).
2. Trust strip — "Written with clinicians. Never a diagnosis. Your data stays
   yours." Three line-icons, no logos.
3. **The Journey** — the signature scroll section (§5.2). TTC → Pregnancy →
   Parenting, one continuous ribbon.
4. **Ask Veda** — the live-answer demo (§5.3).
5. **Bilingual** — the language-switch showpiece (§5.4).
6. Feature bento — 8–10 tiles: Week-by-week, Garbh Sanskar, Tools, Community,
   Journal, Vaccination, Development leaps, Food, Watch, Father Mode.
7. Father Mode — a dark, slate-skinned band that visually breaks the page.
8. WhatsApp — "Ask a question at 3am without opening an app."
9. Privacy & safety — plain-language, India DPDP-aware.
10. Download CTA + footer (§5.7).

**`/journey`** — the three stages in depth, one long page with sticky stage nav.
**`/ask-veda`** — how the answer engine works, what it will and won't do, the
7-section anatomy of an answer, the WhatsApp door, the refusal policy.
**`/fathers`** — entirely in the slate skin. Different tone: direct, practical.
**`/community`** — rooms, moderation stance, the rule that community is never
treated as a medical source.
**`/for-doctors`** — ParentVeda+; what a clinic gets; waitlist form.
**`/for-employers`** — sponsored access; the pitch is retention and return-to-work,
not "wellness perks"; enquiry form.
**`/for-brands`** — partnership formats, and the disclosure principle (every
sponsored placement is labelled). Lead with the ethics; it is the differentiator.
**`/pricing`** — free tier vs ParentVeda Plus. Prices in **₹ with USD in
parentheses**. Mark the actual numbers as placeholders.
**`/about`** — why this exists, the India-first thesis, the clinical-safety stance.
**`/learn`** — blog index + article template with a proper reading experience
(progress bar, TOC, generous measure). Seed with 3 real long-form articles.
**`/download`**, **`/privacy`**, **`/terms`**, **`/contact`**.

Every page must have its `/hi` twin.

---

### 5. The motion system — this is the part I care most about

**The governing rule: cinematic, not arcade.** This is a website a woman may
open at 2am, 30 weeks pregnant, worried. Motion should feel like a slow camera
move in a well-shot film — deliberate, weighted, unhurried. It must never feel
like a crypto landing page. Concretely:

**Banned outright:** neon-on-black; glassmorphism cards over busy gradients;
bouncy spring overshoot on anything; confetti; horizontal auto-scrolling logo
walls that never stop; anything that hijacks scroll velocity so the user can't
control the page; text that only appears after a long delay; cursor trails;
tilt above 4°; more than one thing animating in the viewport at a time; any
animation that repeats forever in a user's peripheral vision.

**Required foundations:**
- **Lenis smooth scroll**, `lerp: 0.085`, `duration: 1.2`. Wire GSAP
  ScrollTrigger to Lenis's raf loop properly.
- **One easing family.** `cubic-bezier(0.16, 1, 0.3, 1)` for entrances,
  `cubic-bezier(0.7, 0, 0.84, 0)` for exits. Durations: 400ms micro, 700ms
  section, 1200ms hero. Never `ease-in-out` defaults.
- **Reveal grammar.** Headings reveal word-by-word via a `clip-path` mask rising
  from below, 0.03s stagger. Body copy fades + rises 12px. Images reveal by an
  expanding clip-path, never by opacity alone. Every reveal fires once, at 25%
  in view, and never re-fires on scroll-back.
- **Colour temperature travel.** The page background is a CSS custom property
  animated by ScrollTrigger as you descend: cool near-white at the top →
  faint purple wash through Pregnancy → warm cream through Parenting → deep
  ink at the footer. The shift must be so slow it's felt, not seen.
- **Grain.** A fixed, 4–6% opacity film-grain overlay across the whole site,
  and one very slowly drifting blurred aurora blob per section (60s+ cycles,
  `filter: blur(80px)`, low opacity). This is what makes a calm palette feel
  expensive.

**5.1 — Hero: the ambient scene.**
Four parallax depth planes moving at different rates on scroll AND on subtle
pointer movement (max 12px travel, heavily damped, disabled on touch): a soft
gradient field at the back; slow-drifting light motes; a floating phone frame at
a gentle 3D perspective showing a real app screen; foreground vignette. The
phone must be a real, rendered UI mock — not a stock image. On scroll, the phone
rotates from perspective toward flat while the headline masks away upward.

**5.2 — The Journey ribbon (the signature moment).**
A single continuous SVG path — think a soft, hand-drawn trail, not a straight
line — that draws itself via `stroke-dashoffset` tied to scroll progress,
travelling down the page through three pinned acts:

- *Act 1 — Trying to Conceive.* Blue accent. The trail passes a cycle ring that
  fills as you scroll.
- *Act 2 — Pregnancy.* Purple. **A pinned horizontal scrub:** the section pins,
  and continued vertical scrolling moves a week counter from 4 → 40 while the
  illustration inside a phone frame morphs and the caption changes ("the size of
  a blueberry" → "the size of a papaya"). This is the single most impressive
  interaction on the site — invest in it. Use ~8 keyframe illustrations with
  cross-dissolve, not 37.
- *Act 3 — Parenting.* Amber. The trail branches into small nodes — first smile,
  first steps, first words — that pop in on a stagger.

The trail never breaks between acts. That unbroken line *is* the product thesis
rendered as motion: one companion, not three apps.

**5.3 — Ask Veda live answer.**
A terminal-calm demo: a question types itself in (respecting reduced motion), a
thinking state pulses once, then the seven answer sections assemble in sequence
— each sliding up and settling, with a sources row appearing last. Then it
loops to a second question after a long pause. Include, deliberately, one
demo where Ask Veda **declines** to answer and routes to a doctor — showing the
refusal is a feature, not a gap, and it will out-sell any clever animation.

**5.4 — The bilingual showpiece.**
A live EN ⇄ हिंदी toggle that re-types the visible sentence in Devanagari with a
character-level crossfade and a genuine font swap. Both scripts must look
beautiful — this is where most Indian products get lazy, and getting it right
is a trust signal to exactly the user you want.

**5.5 — Sticky phone feature walk.**
A phone frame pins on one side while feature copy scrolls past on the other; the
screen inside swaps as each block hits centre. Screens cross-dissolve with a
2px scale nudge. Standard pattern, executed immaculately.

**5.6 — Micro-interactions.**
Magnetic pull on primary CTAs (max 6px, damped). Buttons: a fill that wipes in
from the pointer's entry edge. Cards: 3° max tilt, shadow deepening, image
scaling to 1.03. Links: an underline that draws left-to-right. Counters that
count up once. All fast — 200–400ms.

**5.7 — Footer.**
A giant `PARENTVEDA` wordmark in Fraunces that reveals from below as you hit the
bottom, with the trail from §5.2 terminating into it. Deep ink background.

---

### 6. Performance, accessibility, and the constraints that make it real

Your primary user is on a **mid-range Android phone on Indian 4G**. A beautiful
site that takes six seconds to paint is a failed site. Hard budgets:

- **LCP < 2.5s** and **INP < 200ms** on a simulated Moto-G-class device / Fast 3G.
- **Initial JS < 200KB gzipped.** GSAP plugins, WebGL and the week-scrub assets
  are all dynamically imported and never in the first bundle.
- Images: AVIF with WebP fallback, `next/image`, explicit dimensions, blur
  placeholders. **No layout shift — CLS under 0.05.**
- Every scroll-driven animation is `transform`/`opacity` only. No animating
  `width`, `height`, `top` or `box-shadow`. `will-change` applied on approach
  and removed after.
- Animations pause when offscreen (IntersectionObserver) and when the tab is
  hidden.
- **`prefers-reduced-motion: reduce` must produce a genuinely good static
  site** — not a broken one. Pinning disabled, reveals become instant, the
  week-scrub becomes a swipeable/clickable stepper, the Ask Veda demo shows a
  complete answer immediately. Test this path as seriously as the animated one.
- **WCAG 2.2 AA.** 4.5:1 body contrast (check `#7B757F` on white and fix it if
  it fails — do not ship a token that fails). Visible focus rings on everything,
  full keyboard operability, skip-to-content, correct heading order, alt text on
  every image, `aria-hidden` on decorative motion layers.
- Semantic HTML. Metadata, Open Graph and Twitter cards per page, JSON-LD
  (`Organization`, `SoftwareApplication`, `FAQPage`, `Article` on blog posts),
  `hreflang` linking each `en`/`hi` pair, `sitemap.xml`, `robots.txt`.
- Mobile-first. Build the 390px layout properly before the desktop one; over
  half this traffic will be mobile.

---

### 7. Content rules that are non-negotiable

These come from the product's clinical stance. Breaking one is a defect, not a
style choice.

1. **Never state or imply a diagnosis.** Any clinical sentence ends by routing
   calmly to a doctor. The site never contradicts a user's own clinician.
2. **No personalised probability claims.** Never "know your chance of conceiving
   this month." Population-level statements are fine where they reduce anxiety
   rather than set a target.
3. **No fabricated social proof.** No invented user counts, ratings, doctor
   endorsements, hospital partnerships, or press logos. Placeholders instead.
4. **Hindi is written, not machine-translated.** Warm spoken Hindi in
   Devanagari, आप for the mother. Clinical terms a woman reads off a bottle or
   prescription stay in Latin script (Folate, Omega-3, Braxton Hicks, anomaly
   scan); everyday words go Devanagari (पालक, आयरन). **Never Hinglish in Roman
   script** — that house style was deliberately dropped.
5. **No decorative emoji.** Line icons only.
6. Sponsored/partner content is always visibly labelled. Say so on `/for-brands`.
7. Privacy copy must be specific and true to a local-first architecture: data
   lives on her device first, sync is optional, nothing is sold.

---

### 8. Build phases

Build **Phase 1 only** and stop. I will review, then send you Phase 2.

**Phase 1 — foundation + Home.** Repo, design tokens, typography, i18n
scaffolding with both locales wired, Lenis + GSAP + Framer set up correctly,
reduced-motion path, the shared layout/nav/footer, and the complete Home page
including §5.1, §5.2 (all three acts, including the pinned week scrub), §5.3 and
§5.7. Ship it deployable.

**Phase 2 — depth pages.** `/journey`, `/ask-veda`, `/fathers` (slate skin),
`/community`, `/pricing`, `/download`.

**Phase 3 — B2B, content and polish.** `/for-doctors`, `/for-employers`,
`/for-brands`, `/about`, `/learn` + article template + 3 seeded articles, legal
pages, forms, full Hindi pass, Lighthouse tuning to the §6 budgets.

---

### 9. Before you say it's done

Self-check and report results honestly, including failures:

- [ ] Lighthouse mobile: Performance ≥ 90, Accessibility ≥ 95, SEO 100. Paste
      the actual scores.
- [ ] Every page renders correctly at 390px, 768px, 1440px and 1920px.
- [ ] `prefers-reduced-motion` produces a complete, attractive, fully usable site.
- [ ] Full keyboard traverse of the Home page with visible focus at every stop.
- [ ] `/hi` is complete for everything built — no English fallback strings
      leaking through, correct Devanagari fonts, no letter-spacing on Devanagari.
- [ ] Zero console errors or warnings.
- [ ] No emoji in chrome. No fabricated statistics, logos, or testimonials.
- [ ] `DECISIONS.md` lists every assumption, every placeholder, and anything you
      could not achieve within the performance budget.

If any constraint in §6 forced you to cut an effect from §5, say so plainly and
tell me what you cut. I would rather have a fast site with three great moments
than a slow one with ten mediocre ones.
