# ParentVeda — design decision log

> **What this is.** The running record of what is settled, what is parked, and what is
> owed for the design layer. Append as decisions are taken; do not rewrite history.
>
> **Companions.** `DESIGN-BRIEF.md` holds the evidence. `DESIGN-LAYER.md` holds the
> system.
>
> **Deliberately outside `memory/` and `CLAUDE.md`** while this is in flux, so the
> auto-loaded brain is not churned. Settled entries graduate there once stable.

---

## Settled

| # | Decision | Reasoning | Date |
|---|---|---|---|
| **W01** | **Website's job: both conversion and SEO, SEO engine first.** | Content architecture is the backbone; conversion woven through. Makes topic clusters a *structural* input — they determine which pages exist — rather than a later step. | 2026-08-11 |
| **W02** | **`C:\parentveda-web2` is research, not the base.** | Strong thinking and technical laws worth keeping; the visual layer was purely subtractive and must be rebuilt additively. | 2026-08-11 |
| **W03** | **Strategic centre: *nobody is chasing you*.** Operative form: **you can always leave, and you always know the price before the pitch.** | Evidenced by 35,272 critical reviews; script-independent; demonstrable rather than asserted; structurally unavailable to competitors whose revenue is per-order or whose funnel is a call centre. Replaces *"nobody is watching"*, which was an unevidenced guess. | 2026-08-11 |
| **W04** | **W03 is NOT an anti-monetisation position.** | ParentVeda will promote, sponsor and sell. The data shows objection to *pursuit*, not to products being paid. A promo bar is fine; one that blocks content, demands a phone number, or cannot be dismissed is not. | 2026-08-12 |
| **W05** | **Brand colours stay. Violet is not changed.** | App and website must be in sync, and the app is built on it. Differentiation is behavioural, not chromatic. Colour similarity to iMumz does not matter if the *behaviour* differs — iMumz has violet **and** a WhatsApp-us button pinned to every screen. | 2026-08-12 |
| **W06** | **Re-temper the neutrals from lavender to warm paper.** | The current neutrals (`#FBF9FE`, `#F3EEF7`, `#ECE5F2`) are cool purple-greys — the same material as iMumz's wash. Same violet on *warm* ground reads completely differently at identical hue. Highest-leverage move available, costs no new colour. | 2026-08-12 |
| **W07** | **Animation ban removed. Motion is unconstrained.** | The surveillance argument treated scroll as passive observation and tap as active input; that distinction does not hold — scrolling *is* an action she takes. Once it collapses nothing supports the chain. A rationalisation wearing the costume of a principle. | 2026-08-12 |
| **W08** | **Performance / connection-speed constraints deferred.** | User's explicit instruction, stated twice: build unconstrained, optimise later. Keep a *deferred-performance list* for later revisiting; it must not shape decisions now. Also removes the last surviving fragment of W07's ban. | 2026-08-12 |
| **W09** | **Fill every image hole. "Complete" beats "pure".** | A site with grey placeholder circles reads as abandoned, not as principled restraint. The previous blanket ban on non-ParentVeda photography was one of the removals that produced the emptiness. | 2026-08-12 |
| **W10** | **Reference set: audit and push back, not take-as-given.** | Widely-loved and widely-copied are the same property; the second is what poisoned the previous attempt. Portfolio and award classes rejected; editorial, Indian, and calm-healthcare classes adopted. | 2026-08-11 |
| **W11** | **Design docs live outside `memory/` and `CLAUDE.md`.** | `memory/` is the auto-loaded brain every session boots with. In-flux design decisions there mean every future session starts with moving material. Graduate settled points later. | 2026-08-12 |
| **W12** | **Semrush paused.** To run in a dedicated session during the user's zero-usage window, **with permission asked first.** | High token cost. Gates nothing now — it feeds content architecture, which comes after the local analysis. | 2026-08-11 |
| **W13** | **Everything gets a V2; never mutate the original.** | e.g. the pregnancy home screen keeps its current version and gains a V2 alongside. Consistent with the repo's existing *comment out, never delete* rule. | 2026-08-12 |

---

| **W14** | **Adopt Flo's image system and content architecture.** Full teardown in `FLO-TEARDOWN.md`; the rule lives in `DESIGN-LAYER.md` §4a. | User's instruction 2026-08-13: study, analyse and **legitimately adopt** — method, not assets. The de-cluttered, segregated, well-labelled structure is the single most transferable thing found in the whole reference pass. Six image modes assigned **by subject, not by taste**; horizontal rails named in plain language; two cards visible per rail; no engagement counts in the browse layer. | 2026-08-13 |
| **W15** | **Onboarding: short AND give-back.** 5–7 questions where **each answer returns something genuinely useful**, not 35 questions and not 5 extractive ones. | The user wants a basic onboarding, not an intensive one — correct, but the reason Flo's 35-question flow is tolerable is not brevity. It is that every answer is repaid immediately with real content, it explains why it asks, it carries content warnings with a real skip, and it breaks up question blocks with reassurance. **A long form is tolerable when it is a conversation that answers back; a short form is required when it is an interrogation.** Take the mechanic, not the length. | 2026-08-13 |
| **W16** | **Sex and pleasure content: integrate via opt-in-by-asking, inside couple-bonding.** | The Indian market is becoming more vocal and the category is under-served, **but ParentVeda's audience differs from Flo's** — more mother→child than broad women's health, so **content regulation is the key**. Flo's mechanic solves this: it *asks* (*"Is there anything you'd like to know about conception sex?"*), multi-select, answers inline. **She opts in by asking** — nothing is pushed, and it is framed as her question rather than our content. Natural home: the planned couple-bonding content during and after pregnancy. | 2026-08-13 |
| **W17** | **Mark the stage transition as a life event, not a settings toggle.** | Flo gates entry to pregnancy mode behind a benefits screen, then a **"Congratulations!"** confetti moment that plainly states what changes, with Cancel / Activate. The *switcher* lives in Settings; the *first* transition is a moment. Directly informs R03. | 2026-08-13 |

---

## ⭐ The eight design questions — ALL RESOLVED 2026-08-14

These were the places where the first draft had quietly collapsed to one option. The user
raised it; all are now decided, informed by the full reference pass.

| # | Decision | Note |
|---|---|---|
| **Q1** Media identity | **Dissolved by W14** — not film *or* photo *or* illustration, but **all six modes assigned by subject.** | Nothing left to decide |
| **Q2** Content cards | ⭐ **Rich image, stripped metadata.** Distinctive image + title + optional format badge. **No view counts, likes, avatars, dates or "Read more" in the browse layer.** Named rails, two visible. | **Dissolves the W01 SEO-first vs austere-editorial contradiction** — we get both. `DESIGN-LAYER.md` §6a |
| **Q3** Body type | **Fraunces display only; Plus Jakarta Sans for UI *and* long-form body.** | Already what Prepare and TTC do. **Also settles the Hindi display face** via the `pv_fonts.dart` coupling |
| **Q4** Accents | ⭐ **ONE LOUD, MANY QUIET.** Violet is the only strong colour; all other hues live as soft grounds in a fixed saturation/lightness band. | Fixes the Tools grid's 7-hue chaos. `DESIGN-LAYER.md` §2 |
| **Q5** Dark mode | **Light only — deliberately, not by omission.** | Warm paper *is* the identity. Revisit only if users ask. `DESIGN-LAYER.md` §7a |
| **Q6** Ornament | **NONE.** Richness from imagery. | Indian-ness from palette, composition, material, cadence — never applied decoration |
| **Q7** Nav | **Centre button — but only because it is an ACTION.** See below; **this closes R03.** | |
| **Q8** Hero | **Full-bleed, one floating subject, one number.** | Scales across stages |
| **Q9** Photography | **Faces allowed — cropped tight, softly lit, mid-experience.** | Assignment still governs: faces for emotion/symptom |

### ⭐ Q7 closes R03 — the centre button is an action

The user's condition: *a raised centre is right **if it is a thing you DO**; if it is
merely another destination it is decoration, and Flo's equal tabs win.*

**The workbook already satisfies it.** Every `L3 Constants` spine carries a practice
riding it — *this week's fertility action · this week's nutrition, movement, bonding ·
today's age-appropriate activity · today's skill exercise.* So the centre button is
**"today's practice"** — a thing she does.

**Resolution:** constant label and constant position across every stage and child age;
**only the contents change**. ⚠️ **It must be positionally fixed regardless of active
tab** — the nav currently re-flows ("Today" at x≈188 active, x≈120 inactive), moving the
target under her thumb. `DESIGN-LAYER.md` §7b.

### What these answers SUPERSEDE

- Good Earth **margin-whisper ornament** → **none** (Q6)
- Nicobar **contained-aperture hero** → **full-bleed** (Q8)
- **"Face is not the subject"** → **faces, cropped** (Q9)
- **Four accents at equal strength** → **one loud, many quiet** (Q4)
- **Fraunces for article body** → **sans body** (Q3)
- The **austere-vs-image-rich card tension** → dissolved (Q2)

> **Pattern worth recording: five of the nine answers moved *away* from the website
> references and *toward* what the app already does well, or what Flo proved at scale.**
> The website pass produced vocabulary; **the app pass produced the decisions.** Weight
> future research accordingly — this is an app-first product.

---

## Round 2 decisions — 2026-08-14

| # | Decision | Reasoning |
|---|---|---|
| **W18** | **P03 resolved by RENDERING, not describing.** Build the same screen four times — warm paper · cool/clean · clay/terracotta · stage-temperature — and choose by looking. Doubles as the V1/V2 prototype (O05). | The user has been choosing palette directions from prose descriptions. Four rendered screens settle it in seconds, and the code is throwaway so it costs nothing to be wrong. |
| **W19** | **R04 — Products moves LATER in the nav**, not slot 2. Slot 4 or 5, where parenting already has it. | **Nav placement is a promise made before anyone reads the copy.** Slot 2 says shopping is the second thing this app is for. Mylo's largest complaint category is commerce push at 24.3%; the rest of ParentVeda's commerce discipline (criteria teaching, price before pitch) shouldn't be undercut by position. |
| **W20** | ⭐ **Community identity: HER CHOICE PER POST, plus crisis routing.** Anonymous or her real name, chosen each time. Anonymous crisis posts route to the expert layer rather than being left to the crowd. | Better than Flo, which forces anonymity. The routing is the necessary counterweight: Flo's domestic-violence disclosure got **3 likes and 1 comment** — the anonymity worked, the response didn't. A design that invites disclosure of that severity owes a response to it. |
| **W21** | **R01 (Stage 4, child-facing) — DEFERRED.** Record the constraint, decide when it is real. | It does not exist yet. Deciding its visual system now means deciding for a product nobody has designed. **Constraint to carry: it is a second system that must still feel like ParentVeda** — Father Mode proves the codebase supports that cleanly. |
| **W22** | **Fix the six revamp-independent defects now.** | All wrong under any structure, all survive the revamp. The two debug tools reachable by a mother are arguably shipping-blockers. |
| **W23** | ⚠️ **R06 REVERSED — do NOT unify slot 4.** The label adapts per stage. | The user's correction, and it is right: the app spans preconception → pregnancy → after birth → the child's years, and forcing one word makes it wrong somewhere. **My "unify" push over-applied the positional-consistency rule.** <br><br>**The refinement that keeps both properties: what stays constant is the POSITION and the JOB, not the word.** Slot 4 is always "the hub of things you do in this stage." Habit forms on *where it is* and *what kind of thing lives there*. Flo proves it — it drops "Messages" entirely in pregnancy mode while every other tab holds position. <br><br>⚠️ **Safe boundary:** slot 4 keeps its **position and icon family**; only the word adapts. If label *and* icon *and* destination all change, it is a different button and habit breaks. |

## Parked — do not re-raise until the user unparks

| # | Item | Why parked |
|---|---|---|
| **P01** | **The app↔website identity relationship** (new identity on web / website extends app / deliberately different registers). | The product idea itself is changing and affects both together. Deciding now would be thrown away. **Constraint that holds regardless: app and website are one thing called ParentVeda, not two products sharing a logo.** |
| **P02** | **The revamp itself** — structure, naming, component placement. | The user holds the spec (an Excel of ideas). Content is re-ordered, not added or removed. **Design is applied over the revamp, so the revamp lands first.** |
| **P03** | ⚠️ **Which palette direction — NARROWED 2026-08-14.** **B (violet on dark ground as the default surface) is eliminated by Q5** (light only, deliberately). A fifth option arrived from Flo: **E — temperature shifts per life stage, structure unchanged.** Live options are now **A** warm paper · **C** cool and clean · **D** clay/terracotta · **E** stage-temperature. | A is the current recommendation and is worked out in full, but **the choice is open**. Resolve by building comparable swatches and looking, not by argument. User explicitly asked that multiple directions stay open — correctly, since the first draft had collapsed to one. |
| **P05** | **Broader content scope, for future expansion only.** Flo carries rails ParentVeda does not: *Happy relationships know-how · Navigating relationships · LGBTQ+ · Beauty and wellness · Sleep.* | User flagged these as worth noting for later growth, not building now. Several overlap the workbook's 40 brackets. **Park; do not scope in.** |
| **P06** | ⚠️ **The UX / interaction layer — what each tap does.** | Raised by the user 2026-08-13 and **not yet designed**: what each nav slot opens, what the centre button does per stage, how a card behaves on tap (expand vs navigate vs play), how deep a journey goes before a back-out, and where the app returns her tomorrow. Not answerable from references alone — needs its own pass once the revamp structure lands. Recorded in `FLO-TEARDOWN.md` §8. |
| **P04** | ⚠️ **The wordmark vs the type system.** The lockup is a heavy geometric rounded sans; the proposed system voice is Fraunces, an editorial serif. | Two different voices. Either the wordmark is eventually redrawn, or the system knowingly carries a logo that speaks differently from the pages. Named, not resolved. |

---

## Superseded

| # | Was | Now | Why |
|---|---|---|---|
| **S01** | D015 — keep Hinglish in Latin script; defer Devanagari. Hinglish as the strategic wedge, "best-evidenced gap in the research". | Dead. | **The app is English by default**; Hindi is an option. The wedge was never load-bearing — it made a language positioning the centre of a site for an English-first product. Corroborated: language complaints are **0–1.6%** of critical reviews. |
| **S02** | *"Nobody is watching"* as the strategic centre. | **W03**, *nobody is chasing you*. | The original was an unevidenced guess. The data shows the visceral complaint is pursuit, not surveillance. |
| **S03** | "No scroll-triggered animation anywhere." | **W07**. | See reasoning in W07. |
| **S04** | "No photograph of a pregnant woman, baby or doctor who is not a real person connected to ParentVeda." | **W09**, with one carve-out below (O01). | The blanket ban produced visible emptiness that read as abandonment. |
| **S05** | "Coral `#FF5A79` demoted to the logo mark and nothing else." | **Coral = the child.** Used wherever content concerns the baby rather than the mother. | Written before anyone opened the logo file. The mark *is* a violet parent holding a coral child — coral already carries meaning, so exiling it discarded a semantic the brand already owns. A reminder that reading hex out of `app_theme.dart` is not the same as looking at the asset. |

---

## Owed / open

| # | Item | Notes |
|---|---|---|
| **O01** | **A real reviewing clinician** — name, specialty, certifying body, institution, registration number, portrait. | The previous handoff calls this *"the single highest-return asset ParentVeda can commission"*, and it is right — every trust element is inert without it. **Hard line: this one slot is never fabricated.** A generated portrait with an invented name and registration number is a fabricated medical credential on a health site. Either a real doctor, or a designed state that reads as deliberate rather than broken. |
| **O02** | **Real article bodies.** | Costs writing time, not money. The trust architecture exists; the prose does not. |
| **O03** | **Illustration set** — including the nine fruits. One illustrator, one sitting, or generated. | The main warmth layer currently missing. No misrepresentation risk in a drawing. |
| **O04** | **Photography of people.** | Prefer real free-licensed photography over AI generation — AI-generated people have a recognisable look this audience will feel. Strongest and easiest-to-convince move: **photography where the face is not the subject** — hands, a plate, light through a window, a doorway. |
| **O05** | **V1/V2 homepage toggle on localhost.** | V1 on the recommended path; V2 carrying the full effects layer (shader gradients, glass, WebGL) so the effects question is settled by looking rather than argument. Front-end only, homepage only. Requested by the user. |
| **O06** | **Verify the previous research's precise measurements.** | Headspace "one curve used 210 times", Calm 150% leading, WHOOP 80%, "four text tints". Sourced from fetched markup or memory, never verified by eye. **Do not reuse until spot-checked** — the project's own thesis is that checkable beats vague. |
| **O07** | ~~First-party evidence not yet reviewed.~~ **CLOSED 2026-08-12.** | The user confirms `ParentVeda app review - July 18.docx`, `ParentVeda_Pregnancy_App_Review_Chat.md` and `Dev review 1.pdf` are **the three-person team's own internal review notes, not user feedback.** Consequence worth stating plainly: **there is still zero direct evidence from real ParentVeda users.** Everything in `DESIGN-BRIEF.md` §3 is competitor evidence. Do not let internal review notes be mistaken for user research. |
| **O08** | **Semrush content architecture.** | Blocked on W12 — the user calls the moment. |
| **O09** | **Skills not yet read directly.** | `frontend-design` (`anthropics/claude-code`) and `vercel-labs/agent-skills` are the two worth adopting; both currently known only from a secondary source. |

---

---

## The revamp (P02) — analysed 2026-08-12

Source: `parentveda-level-map-checklist.xlsx` (Read Me · L1+L2 Master · L3 Constants ·
Hubs & Engine), plus CRED screenshots supplied as structural reference.

### What it defines

- **40 problem brackets (L1)** across four stages, each checked against **six layers**
  (Content · Activities · Tools · Products · Course/Masterclass · Consult) plus per-bracket
  Extras. A layer is either filled or marked **"Not a fit" with a reason** — explicitly to
  avoid manufacturing filler, *"the thing that sinks Mylo and iMumz on trust."*
  **This discipline independently reproduces the review finding in `DESIGN-BRIEF.md` §3 and
  must be protected.**
- **L3 — one persistent spine per stage**, occupying the centre tab: cycle & fertility
  timeline → week-by-week (4–40) → leaps + age activity engine → child capability compass.
- **Five hubs**: Shop · Courses library · Tools hub · Expert Connect · Age-based activity
  engine.
- **Bottom nav, five slots, CRED-style differentiated centre:**
  - Preconception — `Today · Products · [centre] · Learn · More`
  - Pregnancy — `Today · Products · [centre] · Tools · More`
  - After birth — `Today · Products · [centre] · Tools · More`
  - Centre mutates by stage and by child age (Activities ≈2y, Skills ≈7y).
- **More** = a CRED-style grid of circular line icons — how 40 brackets stay reachable
  without 40 nav items.
- **V1/V2**: content is reused; a new interface is built alongside. Consistent with W13.

### Design consequences and new open points

| # | Finding | Status |
|---|---|---|
| **R01** | ⭐ **Stage 4 (Skilling) speaks to the CHILD, not the parent.** An audience switch inside one product. Type size, reading level, tone, density, motion and the whole trust architecture change. `CLAUDE.md`'s clinical invariants were written for a parent at 2am, not a seven-year-old doing a drill. **This is a second system that must still feel like the same brand.** | **Open — biggest design consequence in the workbook.** |
| **R02** | ⚠️ **Gamification conflict.** The workbook specifies challenges, certificates, streaks and progress reports across skilling, reading and kids' meditation. `DESIGN-LAYER.md` §6 bans anything "waiting to be cleared". **Proposed resolution: gamification permitted ONLY in Stage 4 (child-facing), never in the parent stages.** A pregnant woman is never given a streak; a child sees honest rubric-based progress, which is feedback, not pursuit. Keeps the workbook's own "no outcome promises" rule. | **Proposed, needs the user's call.** |
| **R03** | **The centre button's learnability.** CRED's centre is *always* UPI — that is why it is learnable. Ours mutates by stage and child age. But all four L3 spines share one shape: *"where am I, and what do I do about it now."* **Proposed: keep the button visually and verbally constant ("today's practice") and change only its contents.** Muscle memory then survives fifteen years; otherwise the nav must be re-learned at every life transition — the worst moment to make anyone re-learn anything. | **Proposed, needs the user's call.** |
| **R04** | **Products occupies slot 2 on all three parent stages** — the most prominent non-centre position. Mylo's largest complaint category is commerce push at **24.3%**, against our *nobody is chasing you*. The workbook's intent is sound (*"criteria teaching sits next to the buy"*, *"no pushing"*), but **nav placement is a promise made before anyone reads the copy.** | **Open: Products in slot 2, or Tools/Learn in slot 2 with Products in More?** |
| **R05** | ⚠️ **"Not a fit" ≠ "empty".** `CLAUDE.md` says a feature is never hidden and empty sections render an invitation. A layer marked *not a fit* must render **nothing** — "Infertility & IVF → Products: Not a fit (clinical)" must never surface a shopping prompt. A data-model distinction (`absent` vs `not-applicable`); getting it wrong puts commerce exactly where the workbook deliberately refused it. | **Must be encoded, not left to UI judgement.** |
| **R06** | **Slot 4 differs by stage** — "Learn" in preconception, "Tools" in pregnancy and after-birth. Both hubs exist. Deliberate, or a slip? Positional inconsistency costs learnability. | **Question for the user.** |
| **R07** | **The SEO doors are already named** by existing Semrush pulls: anomaly scan ~135,000 · due-date calculator ~110,000 · ectopic ~74,000 · vedic maths ~33,100 · moral stories ~27,100 · kids activities ~27,100 · montessori ~18,100. The highest-volume entry point is **Scans & tests plus the due-date calculator**, not "week by week" generally. The workbook is honest that **preconception and the toddler–preschool band are thin zones** built from category knowledge. | **Shapes the website page inventory; the thin zones are where the paused Semrush work should point.** |

---

## App audit — closed 2026-08-12

The app was walked on a real device (Samsung SM-G990B2). Full findings in
**`APP-AUDIT.md`** — read it before `DESIGN-LAYER.md` §1, which it changes.

**Headline: the app already contains two design systems.** The mother's Today is
lavender card-soup; **Father Mode and the Prepare tab already run warm cream ground +
serif display + one restrained accent + calm empty states.** Direction A was never a
proposal — it is built, it is better, and only the mother's Today screen missed it.

Defects worth carrying into the revamp: floating chrome (Classic|Focus, Mom|Dad, FAB,
nav) **covers content on every Today screen**, including the Focus view's own ALSO TODAY
chips · violet means "important" rather than "actionable" · **"Buy Book" is solid violet
while "Read summary" is a pale tint**, so commerce out-weighs free content · two debug
tools ship in the user-facing Tools hub · ~7 accent hues in one grid · decorative emoji
against the repo's own rule · social metrics (view counts to 56.4K) in Community.

Must survive the revamp: ⭐ **"ALSO TODAY — Still here, just not first today."** (solves
*a feature is never hidden* in one sentence) · ⭐ **expert-verified community**
(`Verified by Dr. Meera +240 experts`, an `Experts only` filter — no competitor examined
has this, and it answers the trust deficit directly) · the writing · honest affiliate and
sponsor disclosure · Father Mode's calm empty states · Ask Veda's *"As your journey
grows"* honesty · the real **"Not now"** dismissal · and `Classic | Focus` as the
already-built V1/V2 mechanism.

**Not seen:** TTC and Parenting stages (switching mutates profile state — needs
permission or a test account), profile/settings.

---

## App-side references — GAP CLOSED 2026-08-12

Apps were **launched and driven on the user's device**, not read about. Full notes in
`DESIGN-BRIEF.md` §5.3a. Personal data ignored by agreement; financial apps not opened.

**Mobbin abandoned** — free tier shows 4 of Flo's 310 screens, all onboarding. Pro is
**₹800/mo (~$9.50/mo)**; user's spend rule stands, so it was not bought. Free tier's
**flow names** are still useful and cost nothing.

Answers to the questions the pass was run for:

- **R03 (mutating centre).** Two usable models found. **Flo partner mode drops the tab
  bar entirely** — a single scrolling surface, because the partner does not need one.
  **Zomato's bottom bar switches *modes*, not sections** (`Home · Under ₹250 · Dining ·
  Healthy Mode`) — lenses on the same content. Both support the proposal in R03: keep the
  control constant, change what it filters.
- **R02 (gamification).** **Duolingo settles it.** Nag banner, four permanent counters,
  a **streak reading 0**, locked greyed nodes — the design's dominant message is *you
  have lapsed*. Fine for a child at a skill; cruel for a mother on the day she could not
  manage it. **Confirms the boundary: Stage 4 only.**
- **Stage transitions.** Flo's partner mode is the closest analogue to Father Mode and is
  radically simpler than the main app — worth weighing against ParentVeda's five-tab
  father nav.
- **More-grid density.** Zomato's circular photographic category rail and its
  `EXPLORE MORE` rail-not-grid are the Indian reference points.

⭐ **The interruption tally now spans both media: 13 references, 10 interrupted.** Only
Aeon, Nicobar and Flo's partner mode did not. **Not interrupting is unoccupied among
companies with far more money and taste than ParentVeda has.**

⭐ **Flo ships our wedge already:** *"we'll never sell your data and you can delete it at
anytime"* on the settings screen with a shield, and **the whole app works with no
account** — email is a dismissible card, not a gate. Proof the position is buildable at
scale.

**Flo female side — walked in full 2026-08-13.** It answers R03 outright.

⭐ **R03 ANSWERED. The stage is a SETTING, not a destination.** Flo's life-stage switcher
lives in **Settings** under *"Your Flo experience"* as a 2×2 grid — **Track cycle · Get
pregnant · Track pregnancy · Track perimenopause** — with the active one checkmarked.
**The bottom nav never changes across any of the four.** Only the contents of Today do.
Flo covers *four* life stages with **one** nav and **one** setting; ParentVeda covers
three with **three different navs** plus gradient promo cards at the top of Today.
Framing it as *"your experience"* rather than *"your stage"* makes switching read as a
preference rather than a life event to declare.

**Reported against interest:** Flo has **no differentiated centre button** — five equal
tabs across four life stages. Not proof the revamp's centre button is wrong, but the
category leader in our exact space solved this problem without one. **R04/R03 should be
decided knowing that.**

⭐ **NEW — the strongest product idea from the whole reference pass.**
Flo's Secret Chats is **anonymous by generated identity** (two-word pseudonyms, animal
avatars, no real names, no photos), and a top post states why unprompted: *"the only
place that I can be brutally honest."* **An anonymous community is the over-visibility
finding (§3) expressed in social design** — nobody is chasing you; nobody is watching
*who you are*.
ParentVeda currently does the opposite (real names, initial avatars, **view counts to
56.4K**) — **but it has what Flo lacks: expert verification.** Combined:

> **Anonymous for the asker, verified for the answer.**

Neither Flo nor any competitor examined has both. **Candidate for the community's
defining decision.**

⭐ **Adopt outright: "What your partner sees."** Before linking, Flo shows a mockup of the
partner's *actual* screen. Consent by preview — the right pattern for ParentVeda's father
pairing-code flow, and the right pattern for a product built on nobody watching you.

**Also:** Flo's Messages tab is **content delivered as chat** from the app, not human
messages — close to the WhatsApp concept, done in-app. And **"Edit period dates" sits
directly under the prediction** — *her observation outranks our calculation*, as a button
(cf. `lib/services/truth_hierarchy.dart`).

**Declined:** locked content rendered as **greyed placeholder rows**, and a paywall card
**inline in the Today feed** with a `Continue` button. Prices are stated plainly, which is
good; the tease pattern is not.

> **Incident note, 2026-08-13.** A blind scroll-then-tap during this pass landed on that
> inline paywall's `Continue` and Android opened the Google Play purchase sheet. **Nothing
> was subscribed or charged**; it was dismissed immediately and the user was told. Lesson
> recorded: **do not chain blind taps after a scroll on someone's real device — capture
> between steps.**

---

## ⚠️ Superseded gap note — app-side references

**The reference set in `DESIGN-BRIEF.md` §5 is eight sites, and all eight are websites.
Zero apps.** For a product defined by a bottom nav, a differentiated centre button, a
More grid and stage mutation, website references teach nothing about tab-bar behaviour,
gesture affordances, list density on a 6-inch screen, or how a "Today" screen paces.

The CRED screenshots are currently the only app reference in the entire body of work.

**Fix: an app-side reference pass via Mobbin** (already on the user's notebook list) — real
screenshots of real shipped flows. Priority questions to answer by looking:

- How do long-relationship apps handle a **mutating** centre tab (CRED's does not mutate)?
- How is a stage/life-transition handled without forcing re-learning?
- "Today" screens: what paces them, what density works one-handed?
- More-grids: how many items before a grid stops being scannable?

Raised by the user, 2026-08-12. He was right.

---

## Standing rules

1. ⭐ **Reference work requires per-site evidence.** What was opened, what was observed,
   what is being taken. If a site was not opened, say so rather than writing from memory.
   The previous attempt's blandness came from studying forty sites and looking at one —
   and that failure is invisible from outside, so proving it is the assistant's job.
2. **The inbound filter.** Material arriving from Instagram/YouTube optimises for
   *impressive-in-a-reel*; this product needs *trustworthy-at-2am*. These diverge more
   often than they overlap. Check also for affiliate placement.
3. **Never fabricate a trust signal.** No invented clinician, credential, registration
   number, testimonial or statistic. Missing trust elements fail visibly and
   deliberately.
4. **Restraint must be countable**, not asserted — gradients `1`, easing curves `1`,
   typefaces `3+2`, accent hues per screen `≤2`.

---

## Environment notes

- **Chrome/CDP `Page.captureScreenshot` times out (30s) and wedges the renderer** on this
  machine. It is environmental, not a property of the site being viewed. It cost the
  previous attempt a retracted critique section and cost this pass Raw Mango. Recovery:
  close the tab and open a fresh one.
- The Claude Chrome extension can sit in a **"Paused"** state — check the toolbar before
  a browsing pass.
- **`frida.com` is hard-blocked at the extension level**, not permission-gated. No toggle
  exists. Closed; do not re-attempt.
- **PDF tooling:** `pdftoppm` is not installed, so the Read tool cannot render PDF pages.
  Workarounds that work: `pdftotext -layout` for text PDFs, and `pypdf`'s `page.images`
  to extract embedded scans for image-reading.
- `pandas` is not installed; the review mining uses stdlib `csv` + `collections`.
  Scripts: `mine.py` (theme regex) and `mine2.py` (open-ended extraction).
