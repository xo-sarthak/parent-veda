# S03 Health - VERBATIM build prompt from 'Feedback on parenting Section (3).xlsx', row 3
# Read this ONLY when the doc file for this section says to check the prompt.

I don’t like current section, rebuild: 
Here's the full Health prompt to copy:

---

# ParentVeda — Health Section (Parenting App): End-to-End Build Prompt

Build the Health section end to end. This bracket is mostly LIVE, so the rule is: build the full content and experience defined below, and wherever the app already has the right screen, store, or feature, use that real one instead of a parallel version. Inventory notes tell you what to reuse; they never shrink what an area must contain. Do not build video files; use the existing player with placeholder entries.

The app is Flutter (653 Dart files, 104 stores). Reconcile every cell: LIVE = map and reuse, do not rebuild; notReady = genuinely new, build it; notCore = lives elsewhere, link don't build; notApplicable = never render. Health is one of the 39 brackets still opening the generic layer-ordered screen; build it to the new hub model (like Scans & tests, the only bracket already migrated).

---

## 0. Context and rules (apply to everything)

ParentVeda is India-first, calm, evidence-first, anti-anxiety, no misinformation.
- Simple, warm, plain-English and Hinglish where noted. No jargon. No em dashes.
- NEVER diagnose. NEVER give a firm drug dose as a prescription. Illness content informs and triages; the doctor decides. Any dosing (paracetamol, etc.) is framed "typical, confirm with your doctor," never an instruction.
- India-first: IAP (not Western) vaccine schedule, govt-hospital and cost angle, HFMD as the top illness, monsoon and seasonal illness, air-pollution and baby lungs, honest nuskhe, the parent's own language.
- Free: all content, all tools, growth, vaccines, records, what_changed. Paid: only the human pediatric teleconsult.
- Every major area has its own explainer video (existing player + placeholder entry). No area is text-only.
- No filler: every page genuinely useful on its own, or dropped, not padded.
- Each page renders in the FORMAT in brackets (tool, checker, article, short article, chart, cards, comparison, flagged callout, flow, records), never one long paragraph. Page template: short warm intro, content in its format, a callout for the key point, a practical "when/how much/what age" line, an India note where relevant, soft links to the related tool, page, or consult.

The section has TWO halves: a reactive half (something's wrong) and a reassurance/tracking half (is my baby healthy and on track). Development milestones are NOT in Health; they live in the Development section. Physical growth (weight/height/percentiles) IS in Health.

---

## 1. What already exists for Health (reuse, do not rebuild)

The `parenting_health` bracket:
- content  LIVE  -> `pp_read` (ReadingHomeScreen, 10 articles), `pp_watch` (WatchHomeScreen, 21 videos, 5 podcasts)
- tools    LIVE  -> `pp_vaccines` (VaxTrackerScreen + VaxStore: 12 vaccines, 10 visits, vax_timeline), `pp_health` (WhatChangedScreen + HealthStore: timeline 9, meds 3, reports 2, prescriptions 1; screens: health_home, records, timeline, growth, doctor_visit, emergency, guide, prescription, wallet x3), `pp_what_changed` (WhatChangedScreen, 29 concerns), `pp_growth` (GrowthJourneyScreen + GrowthStore)
- products LIVE  -> `pp_products` (ProductsDiscoveryScreen), `pp_product_guide` (ProductGuideHubScreen), compare feature (`compare` + `PpCompareStore`, 6 guides)
- course   notApplicable (Health is reactive: content + consult, no course)
- consult  LIVE  -> `pp_experts` (ProviderResultsScreen, 6 experts), `pp_find_help` (ProblemSolverScreen, 7 find-help needs)
- extras   LIVE  -> `pp_health`
- Nuskhe   LIVE  -> `pp_nuskhe` (NuskheScreen, 22 remedies, 6 categories)

Reuse: VaxStore, HealthStore, GrowthStore, the health wallet/records/timeline/prescription/doctor_visit/emergency screens, `pp_what_changed`, `pp_find_help`, `pp_nuskhe`, `ProductStore`/`RecoStore`/`PpCompareStore`, the booking engine (entitlement -> slots) + `BookingStore`, the `pp_watch` player.

Known gaps to handle as explicit tasks, not silent assumptions: assets have no problem/intent/format tags yet (the blocker on the hub auto-populating; add tag fields as a data change); `PpProduct` has no image field (degrade gracefully, flag image seeding); consult supply is mock (seed real supply); the shared placeholder component does not exist (build once, reuse).

---

## 2. THE REACTIVE HALF (something's wrong) — four peer doors

### Door 1: Fever check [primary reactive door]
Data treats fever as a decision, not a read (baby fever temperature 3,600/mo, fever when to worry 1,300, how to bring down 720, paracetamol dose 590+, fever syrup safe dose 1,000 KD 17, home remedies 1,300). So the flagship is a tool, and this is the main NEW build.

- **Fever check** [TOOL, NEW] — baby age + temperature in -> "see a doctor now / safe paracetamol range / watch and watch" out. Non-diagnostic, dosing framed as "typical, confirm with your doctor." Routes to teleconsult on the "see a doctor" result. This is the tool you previously validated and specifically did not want left as an article.
- **Reading a baby's temperature** [SHORT ARTICLE].
- **Paracetamol / ibuprofen dosing by weight** [FLAGGED CALLOUT + table] — typical ranges, confirm-with-doctor, never a prescription.
- **How to bring a fever down, and sponging myths** [ARTICLE].
- **Fever red flags: when to go now** [FLAGGED CALLOUT].
- **Home remedies for fever** [CARDS] — honest, comfort-not-cure, links to nuskhe.
- Video placeholder: fever explainer (existing player).

### Door 2: Named illness pages [content -> pp_read / pp_watch]
The search-volume majority; parents search these by name, so they are direct pages reached by browse/search. Each illness [ARTICLE, same template: what it is, home care, red flags, how long].

- **HFMD** [ARTICLE + visual symptom card] — build the sub-cluster (HFMD Hindi, HFMD cream, homeopathic), since the head term is KD 71 but sub-terms are KD 25-32. Commerce/compare: HFMD cream.
- **Cough and cold** [ARTICLE]. Compare: cough syrups (safety/review). **Home remedies for cough/cold** [CARDS] — data shows heavy remedy-first search.
- **Rashes** [ARTICLE + VISUAL IDENTIFIER: eczema vs baby acne vs heat rash vs cradle cap vs HFMD]. Compare: rash cream, diaper cream. Ties to the ParentVeda lotion SKU.
- **Diaper rash** [ARTICLE]. Compare: diaper rash cream.
- Then one ARTICLE each: **colic, teething, newborn jaundice, diarrhoea / loose motion, vomiting, constipation, ear infection, eye discharge, allergies, eczema, chickenpox.**
- Video placeholders via existing player where useful (giving-medicine-safely demo, reading warning signs).

### Door 3: What changed? [LIVE, reuse pp_what_changed — one door]
Reuse the existing "Something suddenly different?" feature. In Health, surface its Health-relevant subset as one reactive door; do NOT rebuild it or invent a new symptom list.
- **Health-relevant concerns to surface here** [FLOW, existing]: Illness (warm/low-grade fever, runny nose and congestion, tugging at his ears), Skin (a new rash appeared, dry rough skin patches, sore red nappy area), Tummy (hasn't pooped in a few days, runnier more frequent poops, gassy and pulling legs up).
- Each concern walks the parent through likely cause, then links into the matching named illness page and, for fever, the fever tool.
- Keep the existing honest footer: "A guided starting point, not a diagnosis. If something worries you, always check with a doctor."
- Handoff: when a concern is beyond self-serve, hand off to Door 4 (ProblemSolver) or the teleconsult. Wire this handoff; do not treat what_changed and ProblemSolver as unrelated.

### Door 4: ProblemSolver [LIVE, reuse pp_find_help] + Emergency [LIVE, reuse emergency]
- **ProblemSolver** [FLOW, existing] — for the can't-name-it worry ("off feeds, not himself, crying"). Answer questions -> likely cause -> what to do -> which expert. Extend the 7 find-help needs with the illness set as a data change. Valuable in India because it solves "which doctor do I even see." Do not rebuild.
- **Emergency triage** [FLAGGED REFERENCE / quick-check, reuse `emergency` screen] — always-visible. Red flags across illnesses (breathing trouble, high fever in a young infant, dehydration, unresponsiveness, fits, blue lips), "go now vs can wait." Prominent and fast; never buried under home-care tips. Make it interactive if the live screen is static.

---

## 3. THE REASSURANCE / TRACKING HALF (is my baby okay)

### Vaccines [LIVE, reuse pp_vaccines / VaxTracker]
Large, planned, India-specific (vaccination chart 9,900/mo, schedule 2,400, govt-hospital 2,900, with-price 880 KD 17, schedule India 1,000 KD 23).
- **Vaccine tracker + schedule** [TOOL / TIMELINE, existing] — IAP schedule, next-due reminders.
- **What each vaccine is for, essential vs optional** [CARDS].
- **Side effects and what's normal after a shot** [ARTICLE].
- **Catch-up if delayed** [SHORT ARTICLE].
- **Vaccination chart, govt-hospital and with-price** [CHART, downloadable] — the cost-conscious angle the data clearly shows.

### Growth [LIVE, reuse pp_growth / GrowthJourney] — physical growth stays in Health
- **Growth tracker** [TOOL, existing] — weight, height, head circumference, percentiles.
- **"Is my baby growing normally?" reassurance** [ARTICLE] — honest counter to the "too thin / mota" pressure; ties to Feeding.
- **Growth red flags** [FLAGGED CALLOUT] — what needs a doctor.
- (Developmental milestones are NOT here; they live in the Development section.)

### Health records [LIVE, reuse wallet / records / timeline / prescription / doctor_visit]
- **Health wallet** [RECORDS, existing] — vaccine records, prescriptions, reports, doctor visits, meds, in one place. The quiet organizing door.

---

## 4. Threaded: Nuskhe / home remedies [LIVE, reuse pp_nuskhe]
Data is loud that Indian parents search remedy-first (cold/cough remedies 2,400, fever remedies 1,300, ayurvedic KD 16, Indian home remedies 590).
- **Home remedies** [CARDS, existing 22 remedies] — reuse, but apply the no-misinformation pillar: mark each safe / myth / harmful, call out the dangerous ones plainly (no honey under one, kajal/surma risk, ghutti caution), and always "comfort not cure, see a doctor if X." Surface relevant nuskhe on the matching illness page (cough remedies on the cough page, etc.).

---

## 5. Everyday care and prevention [content -> pp_read]
Short, useful pages, no filler: hygiene basics, immunity-building (food ties to Feeding), monsoon and seasonal illness, air-pollution and baby lungs (very Indian), when to keep a sick child home, and how to give medicine to a baby safely. [SHORT ARTICLE each; the give-medicine one gets a video placeholder.]

---

## 6. Videos [reuse pp_watch]
One explainer per major area via the existing player, each a placeholder entry (title, length, slot id): fever explainer, reading warning signs, giving-medicine-safely demo, when-to-rush-to-hospital clip. Build the shared placeholder component once if any content is notReady.

---

## 7. Commerce, compare feature, and products [reuse pp_products]
Surface products contextually on the page they belong to, never in a wall, never on the emergency screen or a red-flag callout. Use the EXISTING compare feature (`compare` + `PpCompareStore`, 6 guides) for every "which one" moment: cough syrups (safety/review), rash creams, diaper creams, thermometers, humidifiers, nasal aspirators. Check existing compare guides first and extend before adding new. `PpProduct` has no image field yet: degrade gracefully, flag image seeding as a data task. Data flags real commercial intent here (rash cream 4,400, cough syrup 4,400 KD 18, diaper rash cream 1,600), so these pages carry products honestly, but medicine safety content leads and product follows, never the reverse.

---

## 8. Paid layer [LIVE, reuse pp_experts / pp_find_help]
Pediatric teleconsult, with the nighttime-urgent-concern consult as the anchor. Surface it on: the fever tool "see a doctor" result, the illness pages, the ProblemSolver handoff, and the emergency screen ("not sure? talk to a pediatrician now"). Seed real consult supply (currently mock) and wire to the existing booking engine and `BookingStore`. Short "who this is for" line, 2-tap booking. A WhatsApp-pediatrician subscription (~Rs 399/mo, Babynama model) is a tested option worth flagging for Ishaan/Deepti, but the per-consult teleconsult is the anchor build. Everything content stays free.

---

## 9. Build vs reuse summary

NEW build:
- The fever check tool (primary).
- Illness content authored into `pp_read` / `pp_watch` (HFMD sub-cluster, cough/cold, rashes + visual identifier, diaper rash, colic, teething, jaundice, diarrhoea, vomiting, constipation, ear infection, eye discharge, allergies, eczema, chickenpox).
- The visual rash identifier and the downloadable vaccination chart.
- The everyday-care/prevention pages.
- Content problem/intent/format tags (the hub-model blocker).
- The emergency quick-check interactivity if the live screen is static.
- Extending the 7 find-help needs and the 29 what_changed concerns' links into the new illness pages (data change, not rebuild).

REUSE (LIVE): vaccines, growth, records/wallet, what_changed, ProblemSolver, nuskhe, experts/consult, products, compare feature, watch/player, booking engine.

Hub note: build Health to the new hub model (only Scans & tests exists in it today) so the four reactive doors and the reassurance doors surface cleanly instead of a generic layer-ordered screen.

---

## 10. Build output expected
- Both halves built in full as defined: four reactive doors (fever tool, named illness pages, what_changed reused, ProblemSolver + emergency) and three reassurance doors (vaccines, growth, records), with nuskhe threaded and prevention pages added.
- Every page in its specified FORMAT, real warm placeholder copy, no filler, no lorem ipsum, dropped rather than padded where thin.
- Everything surfaced through the LIVE screens; nothing rebuilt that already lives; what_changed and ProblemSolver reused (not reinvented) and wired to hand off to each other and to consult.
- The one primary new tool (fever check) built, non-diagnostic, dosing as confirm-with-doctor, routing to teleconsult.
- Emergency triage prominent and always-visible; never a product surface.
- Commerce via existing stores and compare feature, contextual, image-gap handled, medicine-safety-leads-product-follows.
- Teleconsult seeded with real supply and wired to the existing booking engine.
- Known gaps (no content tags, no product images, mock consult slots, no placeholder component) handled as explicit tasks.
- Health built to the new hub model.

Build door by door, half by half, reconciling each cell: LIVE = map and reuse, notReady = build, notCore = link, notApplicable = never render.

---

That's the complete prompt. The downloadable file is also attached above. Development is the natural next section, and it'll pair cleanly with Health since we deliberately kept milestones there. Want Development next?
