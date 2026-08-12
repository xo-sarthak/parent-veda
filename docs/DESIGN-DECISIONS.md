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

## Parked — do not re-raise until the user unparks

| # | Item | Why parked |
|---|---|---|
| **P01** | **The app↔website identity relationship** (new identity on web / website extends app / deliberately different registers). | The product idea itself is changing and affects both together. Deciding now would be thrown away. **Constraint that holds regardless: app and website are one thing called ParentVeda, not two products sharing a logo.** |
| **P02** | **The revamp itself** — structure, naming, component placement. | The user holds the spec (an Excel of ideas). Content is re-ordered, not added or removed. **Design is applied over the revamp, so the revamp lands first.** |

---

## Superseded

| # | Was | Now | Why |
|---|---|---|---|
| **S01** | D015 — keep Hinglish in Latin script; defer Devanagari. Hinglish as the strategic wedge, "best-evidenced gap in the research". | Dead. | **The app is English by default**; Hindi is an option. The wedge was never load-bearing — it made a language positioning the centre of a site for an English-first product. Corroborated: language complaints are **0–1.6%** of critical reviews. |
| **S02** | *"Nobody is watching"* as the strategic centre. | **W03**, *nobody is chasing you*. | The original was an unevidenced guess. The data shows the visceral complaint is pursuit, not surveillance. |
| **S03** | "No scroll-triggered animation anywhere." | **W07**. | See reasoning in W07. |
| **S04** | "No photograph of a pregnant woman, baby or doctor who is not a real person connected to ParentVeda." | **W09**, with one carve-out below (O01). | The blanket ban produced visible emptiness that read as abandonment. |

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
| **O07** | **First-party evidence not yet reviewed.** | `ParentVeda app review - July 18.docx`, `ParentVeda_Pregnancy_App_Review_Chat.md`, `Dev review 1.pdf` in Downloads. **Confirm with the user whether these are real user reactions** before treating them as user data. |
| **O08** | **Semrush content architecture.** | Blocked on W12 — the user calls the moment. |
| **O09** | **Skills not yet read directly.** | `frontend-design` (`anthropics/claude-code`) and `vercel-labs/agent-skills` are the two worth adopting; both currently known only from a secondary source. |

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
