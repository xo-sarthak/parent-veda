# S08 First 40 Days  - VERBATIM build prompt from 'Feedback on parenting Section (3).xlsx', row 8
# Read this ONLY when the doc file for this section says to check the prompt.

# ParentVeda — "Jaapa: Your First 40 Days" Section: End-to-End Build Prompt

Build this section end to end. It is the newborn-stage HERO and is currently the poorest-built bracket in the app (almost entirely notReady; only the course slot is live), so this is a genuine ground-up content + tool build, not a mapping job. Reuse the trackers, course, consult, and commerce systems that already exist; do not rebuild them. Do not build video files; use the existing player with placeholder entries.

The app is Flutter (653 Dart files, 104 stores). The section reads days-since-birth and the child's age (`ChildProfileStore`) to drive a 0-to-40-day spine. Reconcile cells: notReady = build; LIVE = reuse; notApplicable = never render. Build to the new hub model (only Scans & tests exists in it today).

---

## 0. Naming principle (important)
Label everything by the MOTHER'S QUESTION or the thing she DOES, not by the mechanism. Never ship an engineer label like "activities," "tracker," or "module" as a user-facing name. Use Hinglish where it is the natural word (jaapa, malish, jhula). The section's front label is **"Jaapa: Your First 40 Days."**

## 0.1 Context and rules (apply to everything)
ParentVeda is India-first, calm, evidence-first, anti-anxiety, no misinformation. This section lands on the peak-fear moment of the whole journey (a scared parent at day 3), so the calm, reassuring voice matters here more than anywhere.
- Simple, warm, plain-English and Hinglish where noted. No jargon. No em dashes.
- Myth-vs-evidence honesty on jaapa practices: honour the tradition, be honest about what genuinely helps vs folk practices that don't or can harm (for example certain traditional cord or eye applications). This is the no-misinformation pillar.
- The newborn safety red-flag reference and the never-shake / cope-with-crying safety layer are mandatory and must be prominent, never buried, never carrying commerce.
- Never diagnose; route real red flags to a doctor.
- Free: all content, the light check, the trackers, the activities. Paid: only the Jaapa course and the newborn-care + lactation consult.
- Every major door has its own explainer video via the existing player (placeholder entry). No door is text-only.
- No filler: every page genuinely useful on its own, or dropped, not padded.
- FORMATS are explicit in brackets and mandatory. Each article uses the skeleton: what it is / what to do (steps) / what to watch (flagged where relevant) / which day-range it fits. Each how-to (malish etc.) is named with full steps. Never render a page as one long paragraph.

## 0.2 Boundary
This section = the BABY + the mother's IMMEDIATE first-weeks recovery essentials. The mother's DEEPER / ongoing recovery (postpartum depression, pelvic floor, return to work, ongoing healing) lives in the separate "You" section; link across to it, do not build it here.

---

## 1. What exists (reuse) vs build
Bracket `parenting_first_40`: content notReady, activities notReady, tools notReady, products notReady, consult notReady; course LIVE -> `pp_courses`.
- REUSE (do not rebuild): the feed tracker (`feeding_tracker` + `FeedingStore`), sleep tracker (`sleep_tracker` + `SleepStore`), weight/growth tracker (`pp_growth` + `GrowthStore`), the course system (`pp_courses`), the booking engine (entitlement -> slots) + `BookingStore`, products/reco (`pp_products`/`ProductStore`/`RecoStore`) + compare feature (`compare` + `PpCompareStore`), the `pp_watch` player, Ask Veda, `ChildProfileStore` for the day-spine.
- BUILD: all content, the named how-tos, the light newborn check + escalate logic, the newborn-care + lactation consult supply, commerce surfaces, the own-SKU jaapa kit, the 0-40 day-spine logic, content tags.
- Known gaps to handle, not assume: `PpProduct` has no image field (degrade gracefully, flag image seeding); consult supply is mock (seed real); shared placeholder component does not exist (build once).

---

## 2. The spine: "Din by Din: Your 40-Day Guide" [DAY-SPINE of short ARTICLE cards]
A 0-to-40 companion that reads days-since-birth and meets the parent where they are (day 3 differs from day 30). Group into phases so it is not 40 empty slots:
- Days 1-7 (the first week): what's normal now, cord, first feeds, sleep-wake chaos, the mother's early bleeding and rest.
- Days 8-15: feeding rhythm, jaundice window, malish begins, visitors and rest.
- Days 16-30: settling, cluster feeding, day-night, mother's healing.
- Days 31-40: finding a rhythm, what's next, the 40-day mark.
Each phase = short reassuring cards (what's normal / what to do / what to watch), linking into the topic pages below. Video placeholder: a warm "your first 40 days" intro.

## 3. "Samjho Your Newborn" [ARTICLE library, each a structured page]
Understand your baby. One page each, skeleton (what it is / what to do / what to watch / day-range):
- Cord care (and the honest "keep it dry, no haldi/oil/ash on it" myth-bust)
- First bath: when and how
- Nappy changing and newborn poop (meconium to normal, what's normal, what's not)
- Swaddling and dressing (and how warm is too warm)
- Newborn skin: peeling, milia, birthmarks, rashes
- Jaundice: what to watch, when it's fine, when it's not [FLAGGED]
- Cluster feeding and growth spurts
- Hiccups, sneezing, grunting and other normal newborn noises
- Sleep-wake chaos and day-night confusion
- Safe sleep (harm-reduction framed for co-sleeping, consistent with the Sleep section)
- Temperature and how to dress baby for Indian weather
- Umbilical, eyes, and the folk practices to avoid [FLAGGED, myth-vs-evidence]

## 4. "When to Rush to the Doctor" [FLAGGED quick-reference, always-visible] — SAFETY CORE
A scannable red-flag card, not prose: trouble breathing, not feeding / refusing feeds, far fewer wet nappies (dehydration), fever or too cold, deep or spreading jaundice, very floppy or hard to wake, fits, persistent vomiting, blood in stool. Each line: what to do (go now / call now). Prominent, fast to reach, never carries a product. Routes to the newborn/lactation consult and the emergency path.

## 5. "Feeding & Sleep in the Early Days" [ARTICLE cards + links out]
The newborn slice only; link to the full Feeding and Sleep sections rather than duplicating:
- Latch basics [STEP-LIST]
- Feeding on demand and how often [SHORT ARTICLE]
- "Is my baby getting enough?" (leads into the tool in section 7) [ARTICLE]
- Burping [SHORT ARTICLE]
- Newborn sleep reality: why they wake, no routine yet [ARTICLE]
Video placeholder: latch demo (shared with Feeding).

## 6. "Malish, Jhula & Soothing" [how-to STEP guides; VIDEO on malish and jhula]
Named for what she actually does. Each a full step-by-step how-to (what it is / steps / when / any caution):
- **Malish (oil massage)** [STEP how-to + VIDEO] — which oil, warming, stroke sequence (legs, arms, tummy clockwise, back), timing (not right after a feed), how long. Caution: gentle, watch baby's cues.
- **Soothing your baby** [STEP how-to] — the calming sequence: swaddle, hold/side, shush, sway, skin-to-skin; what to try in what order.
- **Baby-wearing / jhula** [STEP how-to + VIDEO] — safe wrapping/carrier basics, airway safety (the TICKS check), the traditional cloth jhula done safely.
- **Skin-to-skin** [STEP how-to] — how, why (warmth, feeding, bonding), especially early days.

## 7. "Is My Baby OK?" [TOOL — light check by default; escalates to the reused feed + weight trackers]
This is the India-fit answer to the real anxiety (is baby getting enough / gaining / okay), NOT a Western feed/sleep/diaper logger.
- Default light check: wet-nappy count (are there enough a day), a simple weight check-in, jaundice watch, and a gentle feed reminder for a sleepy newborn who needs waking to feed. Non-gamified, no ml logging, no caregiver dashboard.
- Escalate when there is a concern (baby not feeding well, poor weight gain, jaundice, prematurity): open the EXISTING full feed tracker (`feeding_tracker` / `FeedingStore`) and weight/growth tracker (`pp_growth` / `GrowthStore`). Do not rebuild these; reuse them.
- Wire feed-tracker data into the lactation consult so the expert has real data.
- Full logging is an OPTIONAL, off-by-default deeper mode for the parents who want it.

## 8. "Maa Ki Dekhbhaal: Healing After Birth" [ARTICLE cards; deeper stuff -> You]
The mother's immediate first-weeks essentials only:
- Bleeding / lochia: what's normal, what's not [ARTICLE + FLAGGED]
- After a normal delivery: stitches, soreness, early care [ARTICLE]
- After a C-section: early healing, what to avoid [ARTICLE]
- Rest, hydration, and jaapa foods [ARTICLE] — includes the useful sliver of protecting your own rest and eating
- Recovery red flags: when to call a doctor [FLAGGED]
Deeper/ongoing recovery (postpartum depression, pelvic floor, return to work) links to the "You" section; do not build it here.
Video placeholder: gentle post-birth recovery basics.

## 9. "Puchho ParentVeda" [reuse Ask Veda]
Surface Ask Veda here for the 2am "is this normal" question, always routing anything serious to the red-flag card and a human.

## 10. "The Jaapa Course" [COURSE, reuse pp_courses — the hero]
"The First 40 Days" digital jaapa course: broad, trust-building newborn dos and don'ts at the myth-vs-evidence level, with the brain-development module inside (framed as what the science supports vs flashcard/genius-baby nonsense, not a standalone). Price ₹1,499 anchored at ₹2,999 against the ₹20,000-35,000 a live jaapa costs. Surface prominently but honestly; the free content captures, the course deepens. Tease Infant Sleep (lives in the Sleep section) as the fast-follow flagship.

## 11. "Talk to a Newborn Expert" [CONSULT — build supply, reuse booking]
Newborn-care + lactation consult. Surface on the feed-tracker escalation, the feeding-basics pages, the red-flag card ("not sure? talk to an expert now"), and the "Is My Baby OK?" tool. Seed real consult supply (currently mock) and wire to the existing booking engine + `BookingStore`. Short "who this is for" line, 2-tap booking.

## 12. "Jaapa Essentials" [PRODUCT surfaces + COMPARE feature]
Contextual commerce via `pp_products`/`ProductStore`/`RecoStore`, on the matching page, never a wall, never on the red-flag or recovery-red-flag cards: postpartum care kit, malish oil (own-SKU opportunity), newborn essentials, swaddles, nursing basics. For "which" choices (which swaddle, which oil) use the existing compare feature; check existing compare guides first. `PpProduct` has no image field yet: degrade gracefully, flag image seeding.

---

## 13. Guardrails (recap)
- Calm at the peak-fear moment; this is where the anti-anxiety voice differentiates hardest.
- Myth-vs-evidence honesty on jaapa (honour tradition, flag harmful folk practices: cord/eye applications, over-bundling, etc.).
- The red-flag safety card and never-shake / cope-with-crying layer are mandatory, prominent, upsell-free.
- Trackers: default light, reuse existing, escalate only when clinically needed; do not impose Western ml-logging as the default.
- Boundary: baby + immediate recovery here; deeper maternal recovery in "You."

## 14. Build vs reuse
- REUSE (LIVE): feed/sleep/weight trackers (`feeding_tracker`, `sleep_tracker`, `pp_growth`), course (`pp_courses`), booking engine, products/compare, player, Ask Veda, `ChildProfileStore`.
- BUILD: the 0-40 day-spine and its phase cards, "Samjho Your Newborn" article library, the red-flag safety card, the early feeding/sleep pages, the malish/soothing/jhula/skin-to-skin how-tos, the "Is My Baby OK?" light-check tool + escalate logic, the newborn-care + lactation consult supply, the "Maa Ki Dekhbhaal" recovery pages, the own-SKU jaapa kit + commerce surfaces, content tags, day-spine logic.
- This is a heavy ground-up build on a nearly-empty bracket; it is the poorest section in V3 and the highest-value to fix.

## 15. Build output expected
- The full section built with all user-facing names as written above (Jaapa: Your First 40 Days; Din by Din; Samjho Your Newborn; When to Rush to the Doctor; Feeding & Sleep in the Early Days; Malish, Jhula & Soothing; Is My Baby OK?; Maa Ki Dekhbhaal; Puchho ParentVeda; The Jaapa Course; Talk to a Newborn Expert; Jaapa Essentials).
- Every piece in its specified FORM (day-spine cards, article library, flagged safety card, step how-tos, tool, course, consult, product/compare), real warm placeholder copy, no filler, no lorem ipsum.
- The 0-40 day-spine reading days-since-birth; phase cards that meet the parent where they are.
- The safety red-flag card and never-shake layer prominent and upsell-free.
- Trackers reused (feed/sleep/weight), default light check, escalate-when-concerned logic, feed data wired to lactation consult.
- Jaapa course surfaced as the hero (₹1,499 anchored ₹2,999), brain-dev module inside; newborn+lactation consult seeded and wired to booking; commerce contextual and compare-backed with image-gap handled.
- Boundary respected: deeper maternal recovery links to "You," not built here.
- Known gaps handled as explicit tasks; section built to the new hub model.

Build door by door in order, reconciling each cell: notReady = build, LIVE = reuse, notApplicable = never render.
