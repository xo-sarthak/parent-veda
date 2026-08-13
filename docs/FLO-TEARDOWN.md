# Flo — full teardown

> **Why this file exists.** Flo is the closest structural analogue to ParentVeda that
> exists at scale: one product spanning cycle → conceiving → pregnancy → perimenopause,
> with a partner mode. The user's assessment — *"the idea of Flo and ParentVeda match very
> well… no other Indian app tries to deliver this"* — is correct, and it is why this app
> gets its own document rather than a paragraph in `DESIGN-BRIEF.md`.
>
> **Sources.** All three modes driven firsthand on a real device (2026-08-12/13) plus 67
> onboarding screenshots captured by the user on first run.
>
> **Standing intent (user, 2026-08-13):** study, analyse and **legitimately adopt** the
> image system, content categorisation and de-cluttered segregation. Not copy assets —
> adopt method.

---

## 1. ⭐ The image system — medium chosen by subject

**Six distinct modes, one coherent result.** Full rule and assignment table in
`DESIGN-LAYER.md` §4a. Summary of why it coheres:

- **One background family** — flat pastel fields in a narrow lightness/saturation band
- **Everything isolated on that ground** — no environmental scenes; one subject, one field
- **Soft diffuse light everywhere** — photos, renders and vectors share a temperature
- **The medium is a function of the subject, not of taste**

| Mode | Subject |
|---|---|
| Flat vector illustration | Bodies, positions, behaviours |
| Cut-out photography | Objects she must recognise — food, supplements, kit |
| Photoreal 3D render | The baby |
| Documentary photography | Emotion and symptom |
| Ultrasound / clinical | Clinical truth |
| Conceptual 3D props | Abstract ideas (a gold "0" balloon for *The Zero Symptoms Club*) |

**Format labelled on the card** — `▶ Video`, `▶ Video Course`, `▶ Animation`.

**ParentVeda today:** one mode for nearly everything — tinted icon squares in ~7 accent
hues. That is why the Tools grid reads flat.

---

## 2. Content architecture — de-cluttered, segregated, labelled

The Insights tab is **horizontal rails by theme**, two cards visible per rail, each rail
titled in plain language:

> *Most popular in Pregnancy · Pregnancy sex and pleasure · Pregnancy body signs
> explained · Just added · Nutrition need to know · All about your baby · Pregnancy
> symptoms: Most popular · Bump-friendly self-care · Getting ready for labor and
> parenthood · Your birth options · Postpartum basics · Happy relationships know-how ·
> LGBTQ+*

**What makes it feel de-cluttered:**
- One idea per rail, named in words a mother would use
- Exactly two cards visible — never a wall
- No card carries more than an image, a title and (sometimes) a format badge
- No engagement counts, no author avatars, no dates in the browse layer
- **Rails adapt to stage** — Secret Chats categories change between conceiving and
  pregnancy; post tags read `2nd trimester`, `Postpartum`

**Adopt wholesale.** This is the single most directly transferable structure in the app.

### Scope worth noting for FUTURE expansion (user, 2026-08-13)

Rails that sit outside the obvious pregnancy remit and point at where ParentVeda could
grow: **Happy relationships know-how · Navigating relationships · LGBTQ+ · Beauty and
wellness · Postpartum basics · Sleep.** Park these; do not build now.

---

## 3. ⭐ Onboarding — 35 questions that do not feel like 35 questions

**The finding that matters:** Flo's onboarding is enormous and still tolerable. Five
mechanics do that, and only one is brevity.

1. ⭐ **Every answer gives something back immediately.** Answer *No* to prenatal
   supplements and you receive a real answer inline: *"That's okay. It's never too early
   to start preparing your body for pregnancy. Flo's doctors say taking at least 400mcg
   of folic acid before conception and during the first 12 weeks reduces the risk of
   problems in a baby's development."*
   **The questionnaire IS content delivery, not data extraction.**
2. **It explains why it asks** — *"Do you have any of these reproductive health
   conditions? **We're asking because we can support you with content about these
   conditions.**"*
3. ⭐ **Content warnings with a real skip** — *"The next question mentions pregnancy loss
   and termination which we know can be emotional to talk about. **You can answer it or
   skip to the next question — it's your choice.**"*
4. **Reassurance interstitials between question blocks** — social proof (*"Join 53
   million+"*, *"Over 7 million 5 star ratings"*), the medical board's real photographed
   faces, *"You're in the right place."*
5. **Progress theatre that sells while it loads** — *"Analyzing your answers… 18% … 49% …
   98%"*, each screen carrying a different value proposition.

> ### The principle
> **A long form is tolerable when it is a conversation that answers back. A short form is
> required when it is an interrogation.**

**Decision for ParentVeda (user wants a basic onboarding, not an intensive one):**
**short AND give-back**, not short and extractive. Five to seven questions where each
answer returns something genuinely useful. Most of Flo's benefit at a fraction of the
length.

### Smaller onboarding craft worth taking

- **Multi-select goals as illustrated tiles** — *"What are your goals? Choose as many as
  you'd like."*
- **Offer a default rather than asking from zero** — *"We started with a 5 day period.
  Adjust for smarter predictions."*
- **Pre-frame OS permission dialogs** — explain what reminders are for on the screen
  *before* triggering the system prompt.
- **Named, photographed clinicians inside onboarding** — Dr Renita White, *"I even used
  Flo myself when I was trying to conceive"*, labelled **Flo medical board member**.
- **A commitment ritual** — *"Tap and hold on the Flo logo to commit."*

---

## 4. ⭐ How Flo handles sex content — and why it solves ParentVeda's problem

It is **not** dumped in a library. It is **asked**:

> *"Is there anything you'd like to know about conception sex? Our sex experts have
> created articles, videos and audios to answer your most intimate questions."*

Multi-select: *Is there a best sex position for getting pregnant? · Do orgasms boost your
odds of conception? · Is it okay to pee or shower after sex? · Do some lubes have a
negative effect on sperm? · I'm not having sex for conception · No, I don't have any
questions.*

Each selection **answers immediately** — *"Nope! What's most important is that you're
comfortable."*

> **She opts in by asking.** Nothing is pushed at anyone, and it is framed as **her
> question**, not our content.

**Application to ParentVeda (user's steer, 2026-08-13):** relevant and integrable, but
**ParentVeda's audience differs** — more mother→child than Flo's broader women's health.
**Content regulation is the key.** Natural home: the **couple-bonding content during and
after pregnancy**, which is planned. The opt-in-by-asking mechanic is what makes it
safe for the Indian market.

---

## 5. The stage switch is celebrated, not silent — relevant to R03

Moving into pregnancy mode is **not** a quiet settings toggle:

1. **"Pregnancy Mode — Why log pregnancy in Flo?"** with three stated benefits (see the
   countdown to birth · daily insights on the baby's development · track weight,
   nutrition and lifestyle) and a `LOG PREGNANCY` button.
2. **"Congratulations!"** with confetti, and a plain explanation of what changes —
   *"a countdown to the birth of your baby will be shown instead of cycle predictions"* —
   then `CANCEL` / `ACTIVATE`.

**A life transition is marked as a life transition.** The switcher itself lives in
Settings under *"Your Flo experience"* (see `DESIGN-BRIEF.md` §5.3a), but the *first*
transition is a moment.

---

## 6. Two patterns to steal, one to decline

**Steal — the screenshot-triggered privacy prompt.** Taking a screenshot produced:
*"Sending this to someone? Keep your data private — forget screenshots, Flo for Partners
makes sharing insights with your partner easy and secure"*, with a **Your view / Partner
view** mockup. A privacy nudge and a feature pitch, triggered by real behaviour.

**Steal — "What your partner sees."** Consent by preview before linking (see
`DESIGN-BRIEF.md` §5.3a).

**Decline — "Tap to shake the tree and win 64% off Flo Premium. 1 shake left."** A
gamified discount with artificial scarcity, fired immediately after the paywall. **The one
moment in Flo's onboarding that contradicts everything else it does well** — and exactly
the pursuit pattern `DESIGN-LAYER.md` §6 forbids.

Also declined: the *Without Flo vs Flo users* comparison table (fear-based framing), and
the **"Details" button that opens a paywall** (see `DESIGN-BRIEF.md`).

---

## 7. Where ParentVeda already matches or beats Flo

- **Expert-verified community** — `Verified by Dr. Meera +240 experts`, `Experts only`
  filter. **Flo has no equivalent.**
- **Far more content given away free.** Flo's browse layer is free; its article depth is
  paid. ParentVeda opens the articles.
- **Price before the pitch, already shipped** — TTC's `TODAY'S PICK — ₹400–₹900` as a
  content row.
- **Named expert + duration on content** — `12 min · Dr. Ananya Rao`.
- **"ALSO TODAY — Still here, just not first today."** Flo has no equivalent demotion
  mechanic; it simply hides things behind a paywall.

---

## 8. Open — the UX layer the revamp still needs

Raised by the user, 2026-08-13: the revamp must address **UX, clicks and flow — what each
tap does — so the app is simple yet engaging.**

Not yet designed, and not answerable from Flo alone. Needs its own pass covering: what
each nav slot opens, what the centre button does per stage, how a card behaves on tap
(expand / navigate / play), how deep any journey goes before a back-out, and where the
app returns her when she comes back tomorrow.
