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

### 5.3a APP references — driven on a real device, 2026-08-12

The website-only gap is now closed. Apps were **launched and driven on the user's Galaxy
S21 FE**, not read about. Personal data on screen was ignored by agreement; only layout,
hierarchy, navigation and type were recorded.

> **Mobbin was attempted first and abandoned.** The account is free tier: Flo has 310
> screens catalogued and **four are visible** — the splash and three onboarding screens.
> Everything past that is blurred behind Pro (**₹800/month ≈ $9.50/month**). Onboarding
> is the least useful part for our questions. The free tier *does* expose **flow names**
> across the whole library (for Flo: `Onboarding · Completing account · Today · Logging
> my symptoms · Subscribing to Flo pro · Logging my period`), which is genuine
> structural information at no cost.

**⭐ Flo — partner mode.** The closest analogue that exists to Father Mode, and to our
stage question.
- **The Today screen is one sentence.** *"Day 1 of her period"* then **"Ask if she'd like
  a hot-water bottle for cramps"** in large type on a soft gradient, nothing competing.
  One actionable thing per day.
- **`Her` / `You` / `Both`** — three folded-corner tagged cards segmenting a couple's
  content. ParentVeda's TTC stage independently arrived at the same idea
  (`Me · Us · What's next`).
- **No bottom nav at all** in partner mode — a single scrolling surface. Flo concluded
  the partner does not need a tab structure; ParentVeda's Father Mode currently has five
  tabs.
- **Reading time on every article** (7 min, 4 min, 10 min) — same courtesy as Aeon.
- ⭐ **The wedge, shipped by the category leader:** *"Your data is protected. We'll never
  sell your data and you can delete it at anytime"* — on the settings screen, with a
  shield, not buried in a policy. And **the whole app works with no account**; "add your
  email" is a dismissible card in settings, not a gate.
- **It did not interrupt on launch.**

**⭐⭐ Flo — female side. THE answer to the stage-transition question.**

The life-stage switcher lives in **Settings**, under the heading **"Your Flo
experience"**, as a 2×2 grid of illustrated tiles:

> **Track cycle · Get pregnant ✓ · Track pregnancy · Track perimenopause**

Three decisions worth copying:

1. **The stage is a SETTING, not a destination.** Not in the nav, not a card at the top
   of Today, not inferred from data. She chooses it; the choice carries a checkmark.
2. **The bottom nav never changes.** `Today · Insights · Secret Chats · Messages ·
   Partner` is identical across all four stages. **Only the contents of Today change.**
3. **The framing is "Your Flo *experience*"** — how the app behaves *for you*, not what
   stage you are *in*. Switching reads as a preference, not a life event to declare.

Flo spans **four** life stages — a longer arc than ParentVeda's three — with **one** nav
and **one** setting. ParentVeda currently has three stages, **three different bottom
navs**, and stage doors rendered as gradient promo cards at the top of Today.

**Reported against interest: Flo has no differentiated centre button.** Five equal tabs
across four life stages. Not proof the revamp's centre button is wrong — CRED's works,
and ParentVeda is more action-oriented — but the category leader in our exact space
solved this problem without one.

Other findings from the female side:
- **The Today screen is one number.** *"Best chances of conceiving are in **7 days**"* at
  enormous size, nothing competing. Same discipline as partner mode's one sentence.
- ⭐ **"Edit period dates"** sits directly under the prediction — *her observation
  outranks our calculation*, turned into a button. Directly relevant to the truth
  hierarchy in `lib/services/truth_hierarchy.dart`, where ParentVeda's own calculation
  sits second from the bottom by design.
- **"NOTE: Flo is not a diagnostic tool."** Stated inline, next to the symptom checker.
- **But Flo labels cycles `ABNORMAL` / `IRREGULAR` with warning triangles** — a boundary
  ParentVeda deliberately does not cross. A place where we are *more* conservative than
  the category leader, on purpose.
- **Content pattern worth stealing:** *"Up to 70% of people with PCOS don't know for sure
  that they have it… Check which symptoms need your attention in 5 minutes, not 2 years —
  the time it can take to get a diagnosis."* A number that reduces fear plus a time
  comparison that makes the value concrete.
- **Honest about the data exchange:** *"The more you share with us, the better Flo works.
  Log 2 or more periods to get personalized analysis."*
- **Price stated plainly:** Yearly ₹1,410 (₹117.50/mo) · Monthly ₹282 · "Not sure yet?
  Enable free trial." **But locked insights render as greyed placeholder rows** — showing
  the shape of what you cannot have. A tease pattern; note it as a choice we can decline.
- A **"Hide content"** setting — privacy feature for a shared or observed phone. Worth
  considering given the over-visibility finding (§3).

**⭐⭐ Flo — pregnancy mode. Seen 2026-08-13, and it corrects a claim made above.**

> **CORRECTION.** An earlier note in this file said Flo's bottom nav *never* changes
> across stages. **That is wrong.** Cycle/conceiving mode has **five** tabs
> (`Today · Insights · Secret Chats · Messages · Partner`); pregnancy mode has **four** —
> **Messages is dropped.**
>
> The accurate finding is better than either framing: **retained tabs keep their names,
> order and positions exactly; only a stage-irrelevant one disappears.** Muscle memory
> survives while the nav still adapts. **This partially validates the revamp's design** —
> four stable slots plus one that changes is close to what Flo actually ships.

⭐ **The whole palette changes per life stage.** Cycle mode is **pink**. Pregnancy mode is
**warm peach and terracotta**. The app re-skins entirely — while structure, type and
behaviour stay identical.

**This is a fourth option for the palette question (P03) that nobody had raised.** The
assumption so far has been one palette for all stages, with Father Mode's slate as a
deliberate exception for a *person*. **Flo differentiates by life stage, not by person** —
and it works *because* everything underneath is unchanged. TTC, pregnancy and parenting
could each carry their own warmth and remain unmistakably ParentVeda.

**The hero is photorealistic, not cute.** A 3D render of the embryo at actual scale,
glowing in a soft warm field. Not a fruit comparison, not a cartoon — it reads as
**reverent rather than adorable**, a different emotional register from the whole category.
Worth weighing against the existing per-week illustrations in `assets/baby/`.

⭐ **The pregnancy Today screen DOES NOT SCROLL.** Verified across three different swipe
origins. The entire daily surface is: week strip · photoreal hero · **one number**
(`2 days`) · a `Details` button · a three-card `My daily insights` rail · four-tab nav.
Everything else lives behind Details, Insights, Secret Chats or Partner.

**Set against ParentVeda's pregnancy Today**, which scrolls through a tip card, a
sponsored card, a referral banner, Today's Video, Garbh Sanskar, the journal, medication,
Today's Read, research summaries, book summaries, a second sponsored card, a second
referral, and product recommendations. **One screen versus a long scroll, for the same
job on the same day of the same pregnancy.** The sharpest single contrast in this whole
pass.

> ⚠️ **BUT — correcting my own praise. "Details" leads to a PAYWALL, not to details.**
> The button promises *"Get more expert info — each week you can learn how your baby and
> your body are developing, according to medical professionals"* and delivers a price
> (₹1,410/yr · ₹282/mo). The fruit-size comparisons (blueberry, corn) sit behind it as a
> teaser carousel.
>
> **So the one-screen Today may be a shop window, not editorial restraint.** It is short
> partly because most of the content is paid.
>
> **This reframes the comparison in ParentVeda's favour.** It is not "Flo is more
> disciplined"; it is **"Flo has less to show for free."** ParentVeda gives away far more
> — articles, videos, tools, community, Garbh Sanskar — which is exactly why its Today has
> more to hold.
>
> **The design lesson survives; the moral one does not.** One screen still beats a long
> scroll — but ParentVeda would achieve it by *choosing what leads*, not by locking the
> rest. And note the mechanic is the one the review corpus indicts (*"All it has a paid
> version only. But in ads they don't mention about it"*): a button labelled **Details**
> that opens a price is a small dishonesty, however elegantly executed.

Skeleton placeholder bars while loading. Launch animation is a pink splash with the
feather mark, then straight to content.

**Flo — pregnancy mode, remaining tabs (2026-08-13).**

**Insights = the free browse layer.** Horizontal rails by theme: *Most popular in
Pregnancy · Pregnancy sex and pleasure · Pregnancy body signs explained · Just added ·
Nutrition need to know · All about your baby.*
- ⭐ **The imagery IS the system.** Every card is visually unique — flat vector
  illustrations of pregnant bodies across skin tones, cut-out photographic objects
  (cheese, vegetables, a spoonful of pills, a smear of cream), photoreal renders. **No
  repeated icon, no template.** This is what stops a content grid reading as generic.
- ⭐ **Controlled pastel variety.** Each card sits on a different soft hue (mint, pink,
  lavender, peach, blue) with **saturation and lightness held constant**. Colour variety
  without chaos — directly applicable to ParentVeda's Tools grid, which currently carries
  ~7 accent hues at full strength.
- Frank about sex ("Pregnancy sex and pleasure" is a whole rail). Under-served territory;
  a real question for the Indian market, though ParentVeda's TTC stage already carries
  *"Do Sex Positions Matter?"*.
- **Sharpens the free-content thesis:** Flo's *browse* layer is free and rich; the
  paywall sits on **depth**. "Same quality for free" concretely means **open the
  articles.**

**Secret Chats adapts to stage** — categories become Postpartum · Beauty and wellness ·
Sleep; post tags read `2nd trimester`, `Postpartum`.

> ### ⚠️ The crisis post — anonymity's real argument, and its real obligation
>
> A post in pregnancy-mode Secret Chats:
> *"Please help me. I have really bad backaches. I'm 14 weeks pregnant with twins, 23
> years old. My husband got arrested for domestic violence. My family doesn't want me to
> keep my babies. I have nobody to help with back pain…"*
>
> **This is the strongest argument for anonymity that exists** — she could not write it
> under her real name, and nowhere else in her life is it sayable.
>
> **It is also a duty of care. The post has 3 likes and 1 comment.** The community did not
> respond adequately. A design that invites disclosure of this severity owes a response
> to it.
>
> **So the community proposal gains a third leg:** anonymous for the asker · verified for
> the answer · **and a safety route for crisis posts.** ParentVeda already has red-flag
> routing in Ask Veda and a clinical-escalation invariant; community is where such
> disclosures actually surface, and **no competitor examined connects the two.** Treat
> this as a differentiator *and* an obligation.

**Partner tab re-skins to the stage palette** — warm amber in pregnancy, teal in
conceiving. **The stage-temperature system runs through every tab, not just Today.**
Benefits are rewritten per stage too ("Celebrate your baby's weekly milestones", "Geek
out together on your body's biology").

> ⭐ **The disclosure nobody else makes.** Under the partner testimonial:
> *"Yasmin took part in Flo for Partners beta testing and **was paid for her time**."*
> They disclose that the testimonial was compensated — volunteer-the-unflattering-thing,
> executed on the exact surface where everyone else quietly does not. Rare, and cheap to
> copy.

**⭐⭐ Flo — Secret Chats. The community model to adopt.**

Nav: `Today · Insights · Secret Chats · Messages · Partner` — five equal tabs, **no
centre button**, unchanged across all four life stages.

- **Anonymity via generated identity.** Posts come from *"Yellow Coast"* with a llama
  avatar, a panda avatar — two-word pseudonyms and animal illustrations. No real names,
  no photographs.
- The top post states the value unprompted: *"Hey girl. Feels like this is the only place
  that I can be brutally honest and hope you guys won't judge me."*

> ⭐ **The synthesis that matters.** The strongest emotional finding in §3 is that the
> Indian maternal stressor is **over-visibility** — too many watchers, too much advice.
> **An anonymous community is that thesis expressed in social design.** Nobody is chasing
> you; nobody is watching *who you are*. It is the same position, one layer down.

**ParentVeda currently does the opposite:** named users (mum, Sneha, Aishwarya, Anjali),
initial avatars, and **view counts up to 56.4K**.

**But ParentVeda has something Flo does not: expert verification** — `Verified by Dr.
Meera +240 experts` and an `Experts only` filter. Combining them yields a position
neither has:

> **Anonymous for the asker, verified for the answer.**

She can ask the thing she is ashamed to ask and still get an answer that is not a
stranger's guess. **Strongest single product idea to come out of this whole reference
pass.**

Other Secret Chats mechanics: topic tags on every post · followable topics · a
photographic categories rail · **editorial prompt-posts** that seed discussion (*"Early
pregnancy signs can be similar to PMS: What's your experience?"* — 165K comments) ·
likes and comments shown but **no view counts** · a persistent `New post` pill.

**Flo — Messages.** Not human messages: **content delivered as chat** from the app
(*"Period support — It's that time, I've got some period topics you might find
helpful."*). A conversational delivery channel, in-app — close to ParentVeda's WhatsApp
concept.

**⭐ Flo — Partner. "What your partner sees."**
Before linking, Flo shows a **phone mockup of his actual screen** — the same Her/You/Both
cards observed in partner mode. **Consent by preview.** For a product built on nobody
watching you, showing exactly what will be shared *before* sharing it is precisely right.
**ParentVeda's father pairing-code flow should adopt this.**
Their testimonial names the benefit well: *"My partner now understands my fertile days
without me telling him"* — the value is emotional labour removed, not data shared.

**Noted and declined:** Flo's Insights tab is largely paywalled, and **locked content
renders as greyed placeholder rows** — showing the shape of what you cannot have. The
paywall card also sits **inline in the Today feed** with a `Continue` button. Prices are
stated plainly (₹1,410/yr ≈ ₹117.50/mo · ₹282/mo), which is good, but the tease pattern
is one we can decline.

**Duolingo — the anti-model, and a precise one.** A notification nag banner (*"You're
missing out on Duo's reminders!"*), four counters permanently on screen (language, flame,
gems, energy), a **streak reading 0**, and a path of greyed locked nodes.
**The dominant message the design communicates is *you have lapsed*.**
Directly sharpens R02: for a child working at a skill, visible progress motivates; for a
mother, "you have lapsed" is cruel, and that is exactly what a streak says on the days she
could not manage it.

**Strava.** Opened **straight into a full-screen subscription modal** over the map.

**Swiggy / Zomato — density calibration and Indian craft.**
- Swiggy opened with a **coach-mark overlay** ("Okay, Got It!"); a six-item bottom nav
  with `NEW` badges and a `Win ₹1000` tile.
- Zomato: a **circular photographic category rail** (All · Cake · Pizza · Biryani · Butter
  Chicken) — the Indian pattern for dense category navigation, same shape language as
  CRED's More grid but photographic rather than iconic. An `EXPLORE MORE` **rail** of
  larger illustrated cards (Offers · Food on train · Plan a party · Collections) — a
  "more" surface done as a rail rather than a grid.
- ⭐ **Zomato's bottom bar switches *modes*, not sections** — `Home · Under ₹250 · Dining ·
  Healthy Mode` are lenses on the same content. Relevant to R03: a centre control can
  change *how* the content is filtered rather than *where* you are.
- Both are far denser and more commercial than ParentVeda should be. Useful as
  calibration and as an anti-model, not a target.

### 5.3b ⭐ The interruption tally, now across websites AND apps

**Thirteen references opened. Ten interrupted on arrival.**

Did **not** interrupt: **Aeon** (built for reading) · **Nicobar** (one thin festival
banner) · **Flo partner mode**.

Interrupted: Lovevery · Maven · Aesop · Good Earth · Kinfolk · iMumz · Duolingo · Strava ·
Swiggy · Zomato. *(ParentVeda's own parenting stage fires two consecutive modals — see
`APP-AUDIT.md`.)*

**Not interrupting remains unoccupied across both media, among companies with far more
money and taste than ParentVeda has.** It is not a compromise forced by being small.

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
