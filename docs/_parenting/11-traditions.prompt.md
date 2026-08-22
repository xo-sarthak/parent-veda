# S11 Traditions - VERBATIM build prompt from 'Feedback on parenting Section (3).xlsx', row 11
# Read this ONLY when the doc file for this section says to check the prompt.

# ParentVeda — "Traditions: Ceremonies & Milestones" Section: End-to-End Build Prompt

Build this section end to end. It is ONE focused thing done very well: a how-to library for the baby ceremonies and milestone rituals Indian families actually perform. It is NOT a scripture or devotional section (the data shows that audience is tiny), and it is NOT a bin of links. It is the practical "how do I actually do this ceremony, and what actually matters" guide that nothing else in the app covers. Do not build video files; use the existing player with placeholder entries.

The app is Flutter (653 Dart files, 104 stores). This bracket (`parenting_traditional`) has nuskhe and names already LIVE; the ceremony/ritual how-to content is notReady, which is why the section currently feels empty. Reconcile cells: LIVE = reuse; notReady = build; notApplicable = never render. Build to the new hub model.

Section name: **Traditions** (front label), sub-title "Ceremonies & Milestones." (Acceptable alternatives if preferred: "Sanskar & Celebrations", "Rituals & Milestones".)

---

## 0. Positioning and rules (apply to everything)
ParentVeda is India-first, calm, evidence-first, anti-anxiety, no-misinformation, inclusive.
- SECULAR AND INCLUSIVE FRAMING: serve Hindu-India without branding Hindu or religious. Present ceremonies as culture and rites of passage done practically, not as devotional instruction. (Validated by the data: secular/cultural framing has the demand; scripture-branded framing does not.)
- The honest, anti-pressure VOICE is the differentiator and must run through every page: baby's health and comfort come first; these ceremonies are flexible; you can delay or simplify any of them; do the ones meaningful to your family and skip the rest; a ritual done symbolically at home still counts. No source owns this voice well; ParentVeda should.
- Practical how-to, not preachy. Plain English and Hinglish where natural (the ceremony names are Hinglish by default). No jargon. No em dashes.
- No-misinformation: where a practice has a real safety angle (e.g. newborn exposure at a first outing, hygiene at ear-piercing), state it honestly and calmly; never fear-monger.
- Every ceremony has its own explainer VIDEO (existing player, placeholder entry). No ceremony is text-only.
- No filler: every page genuinely useful, or dropped. Name everything; no "e.g." stubs.
- FORMATS explicit in brackets. Each ceremony page uses the FIXED CEREMONY SKELETON below; never render it as one long paragraph.

## 0.1 The fixed ceremony-page skeleton (every ceremony page, same structure)
1. What it is and what it means [short intro]
2. The right age / when it's done [with regional and boy-vs-girl timing variations named]
3. What it's called in different regions [named regional variants]
4. How it's done, simply [STEP-LIST of the ritual]
5. What you need [samagri / items CHECKLIST]
6. What actually matters vs what's optional [the honest, anti-pressure callout]
7. Health-first note [where relevant: comfort, exposure, hygiene, flexibility to delay/simplify]
8. Its own explainer VIDEO [placeholder entry]
9. Links [where relevant: to the names tool, solids content, post-creator, essentials]

---

## 1. What exists (reuse) vs build
Bracket `parenting_traditional`: content LIVE -> `pp_nuskhe`; tools LIVE -> `pp_nuskhe`, `pp_names`; activities notReady (ritual/event how-tos); products notReady (ceremony essentials); course notApplicable; consult notCore.
- REUSE: `pp_names` (BabyNamingHomeScreen + finder/matches/swipe/astro) for the Namkaran link; the Feeding/solids content for the Annaprashan link; the `pp_watch` player for videos; products/reco + compare feature for essentials; `ChildProfileStore` for age-aware surfacing; `pp_nuskhe` stays in the bracket but is surfaced under Health, not rebuilt here.
- POST/INVITE CREATOR: link to the existing parent-facing card/post/invite creator if one exists in the codebase (check for a memories/card/announcement creator, e.g. around `MemoriesStore` / `photo_viewer`). If a parent-facing creator does NOT exist, do NOT invent a broken link: flag it as a NEW BUILD task (a simple ceremony announcement/invite card creator with templates per ceremony) and stub the entry point. Do NOT wire to `BrandStudio` (that is the monetization brand-collab tool, not a parent card maker).
- BUILD: all ceremony how-to pages, the multi-faith filter, the video placeholders, the essentials commerce, age-awareness, content tags.
- Known gaps: `PpProduct` has no image field (degrade gracefully, flag image seeding); shared placeholder component may need building once.

## 2. The multi-faith filter (top of section)
A simple filter/toggle at the section top: Hindu (default, leads by demand) / Muslim / Christian / Sikh / Show all. It swaps which ceremony set shows. Each faith's ceremonies are built to the SAME fixed skeleton and the same honest voice. Hindu leads because that is where the search demand is; the filter keeps the section inclusive and serves every family cleanly.

## 3. HINDU ceremonies (the default set, ordered by real demand)

### Lead tier (highest searched, build first)
- **Annaprashan (first rice / first solids)** [CEREMONY page] — the single biggest. Age: ~6 months to 1 year (boys often 6th/8th month, girls 5th/7th); note it aligns with the pediatric "start solids ~6 months" guidance. Regional names: Mukhe Bhaat (Bengal), Choroonu (Kerala), Bhath Khulai (Garhwal). Honest note: baby's readiness and comfort over perfect timing. LINK to the Feeding/starting-solids content (this ritual IS the first-solids milestone). Own video.
- **Mundan (first haircut)** [CEREMONY page] — Age: typically 1 or 3 years (odd years considered auspicious). Regional names: Chudakarana, Choula, Keshanta variants. How-to, what you need, hygiene/comfort honest note (clean blade, baby's comfort, don't force). Own video.
- **Namkaran (naming ceremony)** [CEREMONY page] — Age: traditionally ~11th day or within the first weeks. How-to, what you need, honest flexibility note. LINK directly to the `pp_names` baby-naming tool (names by meaning/origin, finder, swipe). LINK to the post/invite creator for a naming announcement card. Own video.

### Second tier (build after the lead tier)
- **Chhathi / Sava-mahina (sixth-day / early welcome)** [CEREMONY page] — the early post-birth welcome; regional variants named; honest note on keeping a newborn's gathering small and safe.
- **Nishkramana (first outing)** [CEREMONY page] — Age: traditionally ~40 days / when mother and baby are well. Honest, health-first note: many families now do it symbolically (open a window, a prayer at home) given pediatric advice on newborn exposure; both approaches are fine. This page is a strong ParentVeda-voice win.
- **Karnavedha (ear-piercing)** [CEREMONY page] — Age and regional variation; how-to; strong honest hygiene/safety note (sterile technique, aftercare, when to wait); comfort-first.
- **Aksharabhyasam (start of learning / first letters)** [CEREMONY page] — Age: ~2-5 years or at Vijayadashami; how-to; links to Early Learning as the "start of learning" moment.
- **First birthday (the modern milestone)** [CEREMONY page] — how families mark it, simple meaningful traditions, keeping it baby-comfortable; links to the post/invite creator for an invite card.

## 4. MUSLIM ceremonies (behind the filter, same skeleton, honest voice)
- **Aqiqah** [CEREMONY page] — the naming + first-haircut + charity/animal-sacrifice welcome; age (~7th day traditionally); how-to; honest flexibility note.
- **Tahneek** [CEREMONY page] — the early sweet-taste welcome; how-to; hygiene note.
- **Naming (Muslim)** [CEREMONY page] — naming conventions; LINK to `pp_names` (with Muslim-name filter if supported).
- **First haircut / head-shaving** [CEREMONY page] — where distinct from Aqiqah; how-to; hygiene note.

## 5. CHRISTIAN ceremonies (behind the filter, same skeleton)
- **Baptism / Christening** [CEREMONY page] — meaning, timing, how it's done, what you need, honest flexibility. LINK to the post/invite creator for a christening invite.
- **Naming / Cradle ceremony** [CEREMONY page] — where practiced; LINK to `pp_names`.
- **First birthday / dedication** [CEREMONY page] — as marked in the family's tradition.

## 6. SIKH ceremonies (behind the filter, same skeleton)
- **Naam Karan (naming at the Gurdwara)** [CEREMONY page] — the Hukamnama-first-letter naming; how-to; LINK to `pp_names`.
- **Dastar Bandi** [CEREMONY page] — noted as a later childhood milestone (age context set honestly).
- **First haircut / Kesh (context)** [CEREMONY page] — honest explanation of the Kesh tradition (hair kept uncut) as distinct from a mundan; respectful, informative.

## 7. Commerce: Ceremony essentials [PRODUCT + COMPARE, light]
Contextual on the matching ceremony page, never a wall: ceremony-essentials kits (Annaprashan thali/silver spoon set, Mundan kit, Namkaran items), traditional outfits, pooja/ceremony basics, invite stationery. Own-SKU potential in ceremony kits. For "which kit" use the existing compare feature. `PpProduct` image-gap handled gracefully. Keep it minor and honest; the value is the how-to, not the shop.

## 8. Videos [reuse pp_watch / player]
One explainer VIDEO per ceremony page (each ceremony its own), placeholder entry (title, length, slot id). Build the shared placeholder component once if needed.

## 9. Age-awareness
Read `ChildProfileStore` and surface the ceremonies relevant to the child's current age near the top (e.g. Namkaran/Chhathi/Nishkramana for a newborn; Annaprashan around 6 months; Mundan around 1 and 3 years; Aksharabhyasam 2-5; first birthday at ~1). Others stay browsable; the timely ones lead. Never show an empty or irrelevant lead.

## 10. Guardrails (recap)
- Secular, inclusive, multi-faith (filter); serve Hindu-India without branding religious.
- Honest, anti-pressure voice everywhere: health first, flexible, simplify or delay, do what's meaningful.
- Practical how-to, not preachy.
- No-misinformation on any real safety angle (exposure, hygiene), calmly.
- Every ceremony named and built to the fixed skeleton with its own video; no stubs, no filler.

## 11. Build vs reuse
- REUSE (LIVE): `pp_names` (Namkaran and all naming links), Feeding/solids content (Annaprashan link), `pp_watch` player, products/compare, `ChildProfileStore`; the post/invite creator IF it exists (else flag new).
- BUILD: all ceremony how-to pages (Hindu lead + second tier, Muslim, Christian, Sikh) on the fixed skeleton, the multi-faith filter, the per-ceremony video placeholders, ceremony-essentials commerce, age-awareness, content tags; the announcement/invite creator only if one does not already exist.

## 12. Build output expected
- The section built as a focused Ceremonies & Milestones how-to library, led by demand (Annaprashan, Mundan, Namkaran first), every ceremony a full page on the fixed skeleton with real warm placeholder copy, no filler, no stubs.
- The honest anti-pressure voice on every page (health first, flexible, meaningful-only).
- Multi-faith filter at the top; Hindu default; Muslim/Christian/Sikh sets each built to the same skeleton.
- Namkaran and all naming pages linked to `pp_names`; Annaprashan linked to solids content; naming/christening/first-birthday pages linked to the post/invite creator (reused if it exists, else flagged as a small new build, never a broken link).
- One explainer video per ceremony (placeholder via existing player).
- Age-aware surfacing via `ChildProfileStore`; timely ceremonies lead.
- Ceremony-essentials commerce, contextual and compare-backed, image-gap handled.
- Known gaps handled as explicit tasks; section built to the new hub model.

Build the Hindu lead tier first (Annaprashan, Mundan, Namkaran), then the Hindu second tier, then the other faiths behind the filter, then commerce and videos. Reconcile each cell: LIVE = reuse, notReady = build, notApplicable = never render.
