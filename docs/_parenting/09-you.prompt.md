# S09 You - VERBATIM build prompt from 'Feedback on parenting Section (3).xlsx', row 9
# Read this ONLY when the doc file for this section says to check the prompt.

# ParentVeda — "You, Maa" Section: Full Named, Age-Banded, End-to-End Build Prompt

Section name: **You, Maa** — tagline "Because you matter too."
The whole mother after birth: her body, mind, pelvic floor, movement, nourishment, and return to work and self. It opens by asking how she is and routes her to the right video, article, activity, or recipe. NO tracker anywhere. This bracket is partly live (content, yoga, course) and partly notReady (consults, community, products, the tools).

The app is Flutter (653 Dart files, 104 stores). The section is AGE-BANDED by the mother's time since birth (`ChildProfileStore` gives days/weeks since birth): a mother 4 months in must not see day-1 healing content, so each band shows only what fits where she is. Reconcile cells: LIVE = reuse; notReady = build; notApplicable = never render. Build to the new hub model.

Postpartum bands used throughout: **0-6 weeks / 6 weeks-3 months / 3-6 months / 6+ months (back-to-work)**. Every content page, activity, recipe, and program is tagged to the band(s) it belongs to and surfaces only in those bands.

---

## 0. Rules (apply to everything)
ParentVeda is India-first, calm, evidence-first, anti-anxiety, no misinformation.
- Simple, warm, plain-English and Hinglish where noted. No jargon. No em dashes.
- REJECT the "bounce back" narrative everywhere: your body took a year to make a baby, it does not bounce back in six weeks; healing takes time; this is not vanity.
- De-stigmatize maternal mental health (critical in India, where postpartum depression is hidden and dismissed).
- MANDATORY crisis path on all Mind pages: serious distress or any thought of self-harm surfaces real help immediately (helpline config value, REQUIRED-TO-CONFIRM), never an article, never an upsell. Build once, reuse (same pattern as pregnancy Mind & Mood).
- Never diagnose; route real red flags to a doctor.
- Free: all content, videos, activities, recipes, the one self-check, the community circle. Paid: only the consults and the recovery program/course.
- Never surface commerce on the mental-health or crisis pages.
- FORMATS explicit in brackets and mandatory. Articles use the skeleton: what's happening / what helps / what to watch / band it fits. Activities and exercises are named with full steps. No filler; drop a page rather than pad it. Name everything; no "e.g." stubs.

## 1. What exists (reuse) vs build
Bracket `parenting_maternal` [You]: content LIVE -> `pp_read`/`pp_watch`; activities LIVE -> `pp_yoga` (27 yoga classes, 7 categories); course LIVE -> `pp_courses`; tools notReady; products notReady (postpartum belt, nursing essentials); consult notReady (maternal mental-health counselling; pelvic-floor physio); extras notReady (4th-trimester peer circle / community).
- REUSE: `pp_read`/`pp_watch` (content + player), `pp_yoga` (filter to postpartum-safe), `pp_courses`, the community system, the Mind & Mood self-check + crisis-path pattern, the recipe engine (`pp_food` / recipes) filtered to postpartum, the booking engine + `BookingStore`, products/reco + compare feature, `ChildProfileStore` for banding.
- BUILD: all body/mind/pelvic/nourishment/work content, the feeling-led entry and video shelf, the named pelvic-floor and postpartum exercises, the maternal-mental-health and pelvic-floor consults (1-on-1 AND group), the 4th-trimester circle, commerce, postpartum recipes, content tags, banding logic.
- Known gaps: `PpProduct` has no image field (degrade gracefully, flag image seeding); consult supply is mock (seed real); shared placeholder component does not exist (build once).

## 2. The section entry: "How are you today, Maa?" [feeling-led router]
The section opens by asking how she feels and routes her: low or teary -> Mind; sore or healing -> Your Body; heavy or leaking -> Pelvic Floor; stiff or wanting to move -> Movement; drained or weak -> Feeding Yourself; lonely -> the Circle. Age-banded: only shows routes relevant to her band. This is what makes it feel for HER, not a library.

---

## 3. "Your Body Healing" [content + video + commerce] — age-banded

### Articles (each ARTICLE, skeleton, band-tagged)
0-6 weeks: Bleeding and lochia, what's normal; Perineal and stitches healing; After a C-section, early healing and what to avoid; Afterpains and cramping; Swelling and night sweats; Sore breasts and engorgement; Rest and why it matters.
6 weeks-3 months: C-section scar care and numbness; Back and posture recovery; Wrist and neck pain from feeding; Hair fall (telogen effluvium); Ab separation (diastasis recti), what it is and safe steps; Constipation and piles after birth.
3-6 months: Ongoing scar and core recovery; Persistent back pain; Skin and hair changes settling; "When will I feel normal", the honest timeline.
6+ months: Long-term core and posture; Lingering issues worth checking; Getting your energy back.

### Videos [VIDEO, reuse player]
Gentle recovery basics (0-6 wk); C-section scar-care demo (6 wk-3 mo); safe first-movement demo (band-appropriate). Feeling-led shelf: "I'm sore," "my scar worries me," "my back hurts" -> the right clip.

### Commerce [PRODUCT + COMPARE]
Postpartum belt/binder, perineal spray and sitz-bath care, C-section scar care, comfort cushions, cotton postpartum underwear, maternity pads. Compare for "which belt / which pad." Band-tagged (binders early, scar care 6wk+).

## 4. "Your Mind" [content + feeling-led video + self-check + crisis path + consult] — age-banded, the emotional core

### Feeling-led video shelf [VIDEO — the front door]
She taps how she feels and gets the right short expert or real-mother video. Named feelings: "I feel low"; "I can't stop crying"; "I feel nothing / numb"; "I'm so angry / full of rage"; "I'm anxious all the time"; "I don't feel like myself"; "I feel guilty"; "I feel alone"; "I have scary thoughts"; "I resent my baby / partner". Each opens a warm, de-stigmatizing clip.

### Articles [ARTICLE each, skeleton, band-tagged]
Baby blues vs postpartum depression (the difference); Postpartum anxiety; Intrusive/scary thoughts (postpartum OCD), reassuring and honest; Postpartum rage; The identity shift ("who am I now"); Loneliness and isolation; "I love my baby but I'm not okay"; Guilt and the comparison trap; Postpartum psychosis (rare, red-flag, know the signs); Intimacy and your relationship after birth (emotional side); When it's more than blues and how to get help.
Band note: baby blues and early distress lead 0-6 weeks; PPD/anxiety across all bands (PPD can begin months in), so Mind content is available in every band, not just early.

### Tool: "How are you, really?" [CHECK — the only tool, not a tracker]
A one-tap, optional, gentle self-check she takes when she wants. Non-diagnostic, no score shown, no logging. Lands on reassurance or a soft nudge to counselling; serious answers route to the crisis path. Reuse the Mind & Mood self-check pattern. Question wording flagged REQUIRED-REVIEW for the counsellor.

### Crisis path [mandatory, reuse]
Any serious-distress or self-harm signal (self-check, video shelf, or consult flow) surfaces the crisis screen: real help first, helpline (REQUIRED-TO-CONFIRM config), never an article or upsell.

### Consult: Postpartum mental-health support [CONSULT — 1-on-1 AND group]
- 1-on-1: maternal mental-health counselling (anonymous option), the strong intimate funnel.
- Group: a facilitated postpartum mental-health support circle (a small paid group session) for mothers who want shared support at a lower price point.
Surface both on the Mind pages and after the self-check; never as an upsell on the crisis screen. Seed real supply, wire to booking.

## 5. "Pelvic Floor" [content + named exercises + video + consult] — age-banded

### Articles [ARTICLE each]
What the pelvic floor is and why it matters; Bladder leaks (stress incontinence) after birth; Heaviness or a dragging feeling (prolapse awareness); Pain during sex after birth; Bowel changes and control; When leaks/heaviness need a physio (red flags).

### Exercises [ACTIVITY each, named, full steps + VIDEO on the how-to]
Band-tagged, safe-start guidance:
- Diaphragmatic (belly) breathing, the foundation, from ~0-6 weeks.
- Gentle kegels done correctly (find the muscle, squeeze-lift-release, don't clench glutes/hold breath), from cleared time.
- Kegel progression (holds, quick flicks), 6 weeks+.
- Connecting breath + pelvic floor + core, 6 weeks+.
- Functional integration (using it when you lift/cough/carry baby), 3 months+.
Each: what it is / how to do it (steps) / how often / when to start / caution. Video on finding-the-muscle and the progression.

### Consult: Pelvic-floor physio [CONSULT — 1-on-1 AND group]
- 1-on-1 pelvic-floor physiotherapy assessment.
- Group: a guided pelvic-floor recovery class (small group, follow-along with a physio).
Surface on the pelvic-floor pages. Seed supply, wire to booking.

## 6. "Getting Back to Movement" [activities + video + consult/program] — age-banded

### Activities [ACTIVITY, reuse pp_yoga postpartum-safe, named, band-tagged]
- Gentle breathing and stretching, 0-6 weeks (cleared).
- Postpartum core reconnection (TVA activation, pelvic tilts), 6 weeks+.
- Post-C-section safe movement (scar-aware, no crunches), banded to C-section mothers 6 weeks+.
- Rebuilding core safely (no crunches/planks too early), 6 weeks-3 months.
- Postpartum yoga flow (gentle), 6 weeks-3 months.
- Strength and return to exercise, 3 months+.
- Return to running/higher impact (only after pelvic-floor cleared), 6 months+.

### Videos [VIDEO, reuse yoga library]
Follow-along sessions per band; a dedicated post-C-section follow-along.

### Article
Rejecting the "bounce back" pressure, honestly. [ARTICLE]

### Consult/Program: Post-C-section recovery [CONSULT + COURSE — 1-on-1 AND group]
- 1-on-1: a post-C-section recovery consult (physio-led).
- Group: a post-C-section recovery program/class (small group, guided) — the named group layer you asked for.
Surface to C-section mothers. Reuse `pp_courses` for the program; booking for the 1-on-1.

## 7. "Feeding Yourself" [articles + RECIPES + commerce] — age-banded

### Articles [ARTICLE, links to Nutrition, don't duplicate]
Postpartum nutrition basics; Jaapa foods for healing; Foods that support milk supply; Iron and recovery (anemia is common); Hydration; Eating well when you have no time.

### Recipes [RECIPE, reuse the recipe engine, postpartum-filtered — the fix you asked for]
A postpartum recipe set, each a real recipe page (ingredients, steps, why-it-helps, band):
- Healing/jaapa recipes: panjiri, gond ke laddoo, methi laddoo, ajwain water, harira/halwa, dry-fruit laddoo.
- Milk-supply-supporting: methi/fenugreek dishes, oats porridge, sabudana, garlic dishes, shatavari-based drinks (honestly framed).
- Iron-rich recovery: dates, beetroot, palak dishes, jaggery preparations.
- Quick one-handed meals for a new mother: khichdi, dalia, one-pot meals, energy snacks.
- Hydrating drinks: jeera water, coconut water, ajwain/saunf water.
Each recipe band-tagged (jaapa/healing recipes lead 0-6 weeks; supply and quick meals across bands). Cook-along video slot per recipe.

### Commerce [PRODUCT]
Lactation support foods, recovery nutrition basics, jaapa food ingredients/kits. Contextual, honest.

## 8. "Back to Work / Back to You" [content + video + commerce] — age-banded (mostly 3-6 mo, 6+ mo)

### Articles [ARTICLE each]
Planning your return to work; End-of-maternity-leave anxiety; Pumping and storing milk at work; Building a milk stash before you return; Weaning if you choose to; Talking to your employer / your rights; Childcare and who will care for baby; Rediscovering yourself and your interests; Friendships after baby; Intimacy and your relationship after birth; Managing guilt about working.

### Videos [VIDEO]
A real-mother "going back to work" story; a "finding yourself again" talk.

### Commerce [PRODUCT + COMPARE]
Breast pump (compare for "which pump"), milk storage bags, cooler bag, work-pumping essentials, nursing wear. (Respect: pumps fine; no infant-formula promotion per IMS Act, review-only if it ever appears.)

## 9. "The 4th-Trimester Circle" [community, build, reuse community system]
A moderated peer circle of other new mothers, "you're not alone." Grouped so she finds mothers at a similar stage (band-aware: newborn-stage mothers, few-months mothers, back-to-work mothers). The inventory-flagged gap and a real India differentiator. Moderated for safety; the crisis path applies if distress surfaces here.

---

## 10. Paid layer (recap)
- Postpartum mental-health counselling: 1-on-1 (strong) + group circle. [CONSULT]
- Pelvic-floor physio: 1-on-1 + group class. [CONSULT]
- Post-C-section recovery: 1-on-1 consult + group program. [CONSULT + COURSE]
- Postpartum recovery / 4th-trimester program (the decided live program). [COURSE, reuse pp_courses]
All content, videos, activities, recipes, the self-check, and the community circle stay free.

## 11. Commerce (recap)
Postpartum belt/binder, perineal and C-section scar care, maternity pads, cotton postpartum underwear, nursing bras and pads, nipple cream, breast pump and storage, lactation and recovery foods/kits. Contextual, compare-backed, band-tagged, never on mental-health/crisis pages. `PpProduct` image-gap handled gracefully.

## 12. Age-banding summary (the core requirement)
The section reads weeks-since-birth and shows only band-relevant content:
- 0-6 weeks: bleeding/stitches/C-section early care, afterpains, engorgement, rest, baby blues, breathing + gentle pelvic breath, jaapa/healing recipes, the circle.
- 6 weeks-3 months: scar care, diastasis, back/wrist pain, PPD/anxiety, kegel progression, core reconnection, post-C-section safe movement, supply recipes.
- 3-6 months: ongoing recovery, "when will I feel normal," strength return, back-to-work planning begins, self/relationship content.
- 6+ months: long-term core, energy, full return to exercise, back-to-work in full, rediscovering self.
Mind content and the crisis path are available in EVERY band (PPD can begin months in). A mother 4 months in never sees day-1 healing as her lead.

## 13. Build vs reuse
- REUSE (LIVE): `pp_read`/`pp_watch` + player, `pp_yoga` (postpartum-safe filter), `pp_courses`, community system, recipe engine (postpartum filter), Mind & Mood self-check + crisis-path pattern, booking engine, products/compare, `ChildProfileStore`.
- BUILD: all body/mind/pelvic/nourishment/work content, the feeling-led entry + video shelves, the named pelvic-floor and postpartum exercises, the postpartum recipe set, the maternal-mental-health and pelvic-floor and post-C-section consults (1-on-1 AND group), the 4th-trimester circle, commerce, the crisis path wiring, content tags, banding logic. No tracker built; the only tool is the optional "How are you, really?" self-check.

## 14. Build output expected
- The full section with all named doors: How are you today Maa (entry); Your Body Healing; Your Mind; Pelvic Floor; Getting Back to Movement; Feeding Yourself (with recipes); Back to Work / Back to You; The 4th-Trimester Circle.
- Every piece in its specified FORM, every item named (no example stubs), real warm placeholder copy, no filler.
- Age-banded by weeks-since-birth so a 4-month-postpartum mother sees only relevant content; Mind and crisis path in every band.
- Feeling-led entry and video shelves working.
- Recipes reused from the engine, postpartum-filtered, each a real recipe page with cook-along video slot.
- Consults built with BOTH 1-on-1 and group layers (mental health, pelvic floor, post-C-section), seeded with real supply, wired to booking; crisis path mandatory and upsell-free on Mind.
- Yoga and post-C-section movement reused/filtered from the yoga library, banded.
- Community circle built on the existing system, stage-grouped and moderated.
- Commerce contextual, compare-backed, band-tagged, image-gap handled, never on mental-health/crisis pages.
- No tracker. The only tool is the optional self-check.
- Known gaps handled as explicit tasks; section built to the new hub model.

Build door by door, band by band, reconciling each cell: LIVE = reuse, notReady = build, notApplicable = never render.
