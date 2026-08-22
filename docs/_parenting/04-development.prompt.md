# S04 Development - VERBATIM build prompt from 'Feedback on parenting Section (3).xlsx', row 4
# Read this ONLY when the doc file for this section says to check the prompt.

I dont like what you ahev built: So udpate as per below: 
ParentVeda — Development Section (Parenting App): End-to-End Build Prompt

Build the Development section end to end. This bracket is heavily LIVE, so the rule is: build the full content and experience defined below, and wherever the app already has the right screen, store, or feature, use that real one instead of a parallel version. Inventory notes tell you what to reuse; they never shrink what a door must contain. Do not build video files; use the existing player with placeholder entries.

The app is Flutter (653 Dart files, 104 stores). Reconcile every cell: LIVE = map and reuse, do not rebuild; notReady = genuinely new, build it; notCore = lives elsewhere, link don't build; notApplicable = never render. Development is one of the 39 brackets still opening the generic layer-ordered screen; build it to the new hub model (like Scans & tests, the only bracket already migrated).

SCOPE BOUNDARY (hard): Development covers on-track (milestones) + activities + speech/language ONLY. Behaviour (tantrums, discipline, biting, screen time) and Early Learning (montessori-at-home, moral stories, activity boxes) are their OWN separate sections and are NOT built here. Physical growth (weight/height) lives in Health, not here.

0. Context and rules (apply to everything)

ParentVeda is India-first, calm, evidence-first, anti-anxiety, no misinformation.

Simple, warm, plain-English and Hinglish where noted. No jargon. No em dashes.
THE core guardrail for this section: wide normal ranges, reassurance-first, ALWAYS. Never a rigid "your baby is behind" verdict or a scary score. Milestone content that fuels comparison-anxiety is harmful and off-brand. Every milestone is framed as a range (for example "most babies walk between 9 and 15 months"), never a deadline.
Honest red flags per skill/domain that route to a real expert, never a self-diagnosis.
India-first: bilingual households, everyday-object play (no expensive-toy dependence), joint-family comparison pressure ("cousin's baby already walks"), the "is my baby behind" anxiety this culture amplifies.
Free: all content, all activities, the milestone views, what_changed. Paid: only the human consult (speech therapist, developmental consult) and the optional masterclass.
Every major door has its own explainer video (existing player + placeholder entry). No door is text-only.
No filler: every page genuinely useful on its own, or dropped, not padded.
Each page renders in the FORMAT in brackets (article, short article, chart, cards, step-list, flagged callout, activity, flow, tool), never one long paragraph. Page template: short warm intro, content in its format, a callout for the key point, a practical "what age / normal range" line, an India note where relevant, soft links to the related activity, skill page, or consult.
1. What already exists for Development (reuse, do not rebuild)

The parenting_development bracket:

content LIVE -> pp_development (DevelopmentHomeScreen + DevStore: 8 development areas, 8 activities)
activities LIVE -> pp_activities (DevelopmentHomeScreen) + pp_grow_activities (GrowStore: 39 extra grow activities)
tools LIVE -> pp_milestones (MilestoneJourneyScreen + MilestoneStore: 18 milestones across 6 domains), pp_development
products notApplicable (not a fit as a primary layer; use pp_recos only where an item genuinely helps)
course LIVE -> pp_courses (LearningHomeScreen)
consult LIVE -> pp_experts (ProviderResultsScreen, 6 experts)
Leaps LIVE -> pp_leaps_data (10 leaps), leap_calendar, leap_definition, wonder_week screens
What changed LIVE -> pp_what_changed (WhatChangedScreen, 29 concerns; Development subset: "babbling less than before", "suddenly shy around new people")
Recos LIVE -> pp_recos (ProductsDiscoveryScreen) for the rare genuinely-helpful item
Screens present: development_home, area, activity, checkin, map, dev_stage, grow x3

Reuse: MilestoneStore, DevStore, GrowStore, the development/activity/leap screens, pp_what_changed, pp_courses, pp_experts, pp_recos, the pp_watch player, the booking engine (entitlement -> slots) + BookingStore.

Known gaps to handle as explicit tasks, not silent assumptions: assets have no problem/intent/format tags yet (hub-model blocker; add tag fields as a data change); consult supply is mock (seed real supply); the shared placeholder component does not exist (build once, reuse); the "development screener" is a named-but-unbuilt tool (build only per section 6, framed gently).

2. Door 1: Is my baby on track? [reassurance-led, reuse pp_milestones]

The comparison-anxiety front door. Lead with wide normal ranges, never a rigid verdict.

Milestones by age band [reuse pp_milestones MilestoneJourney, 18 milestones / 6 domains] — age-band views (2m, 4m, 6m, 9m, 12m, 18m, 2y, 3y) framed as ranges, not deadlines. Present as reassurance, not a scoring tracker.
The 6 domains explained [CARDS] — gross motor, fine motor, language, social/emotional, cognitive, self-help. What each means, in plain language.
"Normal range is wide" reassurance [ARTICLE] — the anti-comparison-anxiety piece and the retention core of this door. Directly addresses the "cousin's baby already does X" pressure.
Delay red flags by domain [FLAGGED CALLOUT, one per domain] — the honest "when late is worth checking" line, routing to the consult, never a scary label.
Video placeholder: expert on "every baby's timeline is different."
3. Door 2: When will my baby [specific skill]? [highest-volume content door]

The biggest search cluster (crawling 5,400/mo, when do babies walk 2,400 + 1,900, talking 1,900, sitting). One page per skill, same template: normal range, signs it's coming, how to gently help, when late needs a doctor.

Skill pages [ARTICLE each]: sitting, crawling, standing, walking, talking / first words, self-feeding, pointing, waving, rolling over.
Each links to its domain in Door 1 and to the matching activities in Door 3.
Products via pp_recos ONLY where genuinely helpful. IMPORTANT: on walking, do NOT recommend baby walkers; state the honest safety guidance (walkers are a recognized hazard) instead.
Video placeholders: gentle "helping baby crawl / walk" follow-alongs.
4. Door 3: Help my baby develop [proactive engine, reuse pp_development + pp_activities + grow + leaps]

The engagement and retention layer.

Activities by domain [reuse pp_activities / DevelopmentHome: 8 areas + 8 activities + 39 grow activities] — age-appropriate things to do, filterable by domain and age.
What to do this week [reuse the grow engine] — the proactive weekly nudge.
Leap-linked activities [reuse pp_leaps (10 leaps) + leap_calendar + leap_definition] — "your baby may be in a leap, here's what helps." Keep the honest evidence note: fixed-week leap timing is not strongly evidenced (the Wonder Weeks limitation), so frame leaps as a helpful lens, not a law.
Play and brain development [ARTICLE + activities] — how play builds the brain, tummy time, sensory play, talking-to-your-baby. India-real: everyday-object play, no expensive-toy dependence.
Video placeholders: activity demos per domain.
5. Door 4: Speech and language [own door, strong funnel]

Speech-delay anxiety is a distinct, monetizable cluster with a clear India angle.

Speech milestones month by month [CHART / ARTICLE] — 6 months to 3 years, wide ranges.
Will two languages confuse my baby? [ARTICLE] — the bilingual-India question, reassuring: growing up bilingual does not cause delay.
How to help my baby talk [STEP-LIST / activities] — narrating the day, reading aloud, naming objects, responding to babble.
Signs of speech delay [FLAGGED CALLOUT] — honest red flags by age, routing to the speech therapist.
Paid: speech therapist consult (the clearest funnel; bilingual-India context is the differentiator) via pp_experts. Seed real supply, wire to booking engine.
Video placeholder: speech-therapist explainer on the normal range.
6. Tools
Milestone view [reuse pp_milestones] — present as reassurance, not a scoring tracker. Your own product finding: a rigid milestone tracker does not retain; the reassurance content and framing do. So the milestone data surfaces as wide-range views and reassurance, not a pass/fail checklist.
Development screener [notReady, BUILD ONLY IF DESIRED] — listed as a named-but-unbuilt tool. If built, it must be a gentle check that lands on "everything looks on track, keep enjoying" OR "worth a chat with an expert," never a score, never a "your baby failed" outcome. Flag for Ishaan/Deepti's decision rather than assuming; default to NOT building it until confirmed, given the anxiety risk.
7. What changed? [LIVE, reuse pp_what_changed — one door]

Surface only the Development subset of the existing feature: "babbling less than before", "suddenly shy around new people". Each walks the parent through likely cause and links into the relevant milestone or speech page. Keep the existing honest footer ("A guided starting point, not a diagnosis. If something worries you, always check with a doctor."). Do not rebuild or invent new concerns.

8. Videos [reuse pp_watch / player]

One explainer per major door via the existing player, each a placeholder entry (title, length, slot id): on-track reassurance, per-skill helping demos, activity demos by domain, speech-therapist explainer. Build the shared placeholder component once if any content is notReady.

9. Paid layer [reuse pp_experts + pp_courses]
Speech therapist consult (anchor funnel) via pp_experts, surfaced on the speech pages and the speech-delay red-flag callout.
Developmental / milestone masterclass via pp_courses (LIVE), surfaced on Door 1 and Door 3.
General developmental consult via pp_experts, surfaced on the delay red flags. Seed real consult supply (currently mock) and wire to the existing booking engine and BookingStore. Short "who this is for" line, 2-tap booking. All reassurance content and activities stay free; the delay-worried parent converts to the expert.
10. Build vs reuse summary

NEW build:

Door 2 per-skill content pages (sitting, crawling, standing, walking, talking, self-feeding, pointing, waving, rolling).
Door 4 speech/language content (speech milestones, bilingual reassurance, how-to-help-talk, delay red flags).
The "normal range is wide" reassurance framing across Door 1, and the per-domain delay red flags.
Play-and-brain-development content.
Content problem/intent/format tags (hub-model blocker).
The development screener ONLY if confirmed, framed gently.

REUSE (LIVE): milestones (18 / 6 domains), development areas + activities, 39 grow activities, 10 leaps + leap screens, courses, experts, recos, what_changed, watch/player, booking engine.

BOUNDARY (do not build here): Behaviour (tantrums, discipline, biting, screen time) and Early Learning (montessori-at-home, moral stories, activity boxes) are their own sections.

Hub note: build Development to the new hub model so the four doors surface cleanly instead of a generic layer-ordered screen.

11. Build output expected
All four doors built in full as defined: on-track (milestones, reassurance-led), when-will-my-baby (per-skill pages), help-my-baby-develop (activities + leaps engine), speech and language (with therapist funnel).
Every page in its specified FORMAT, real warm placeholder copy, no filler, no lorem ipsum, dropped rather than padded where thin.
Everything surfaced through the LIVE screens; nothing rebuilt that already lives; milestones, activities, grow, leaps, and what_changed reused, not reinvented.
The core guardrail enforced everywhere: wide normal ranges, reassurance-first, honest red flags to an expert, never a rigid "behind" verdict or score. No baby walkers recommended.
Speech therapist and developmental consult seeded with real supply and wired to the existing booking engine.
Known gaps (no content tags, mock consult slots, no placeholder component, screener unbuilt) handled as explicit tasks.
Development built to the new hub model, scoped to on-track + activities + speech only.

Build door by door, reconciling each cell: LIVE = map and reuse, notReady = build, notCore = link, notApplicable = never render.
