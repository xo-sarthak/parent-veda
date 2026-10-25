# Door 12: Special care, the plan

Written 2026-10-25. **Status: final. The plan was accepted 2026-10-25, and SC1 to SC7 are chosen and recorded under the user's rule (obvious decisions aren't asked).** The new copy is in `12-special-care-content.md`. Nothing in `lib/` changes until step 0 (S1 to S11) and the user's go.

## Context
**Where it lives.**
- The door: `lib/data/doors/pp_door_special_care.dart`
- The content: `pp_special_care_content.dart`, the thinnest door, with 11 pages on 5 tabs (one page each on two tabs)
- The writing is warm and careful: "wondering doesn't mean anything is wrong", "nothing you did caused this", and Tele-MANAS is already on the parent page

**Tabs:** Born early, and the NICU · Twins · Extra support · Help in India · Looking after yourself.

**Kept on purpose:**
- never a diagnosis
- "only a trained professional can say"
- the early-help stance: "waiting and watching isn't always the kind choice"

### What parents actually ask
From `research/questions/ranked_parenting.csv`:

| Topic | Hits | Top questions | What it means |
|---|---|---|---|
| Speech delay, not talking | 458 | what delays speech; when to worry about toddler speech | **The biggest need.** This door has no speech page. Development has the "by age" side, but nobody covers what to do next |
| Speech therapy, other therapies | 117 | does my toddler need speech therapy; **how much does child speech therapy cost** | **0 pages.** "Speech therapist" appears once, in a list |
| Developmental delay | 259 (noisy) | not walking, regression | `sc_late_bloomer` covers it, briefly |
| Autism | 58 | why autistic toddlers don't respond to their name | `dev_autism_signs` is good |
| ADHD | 31 | can a 4-year-old be diagnosed with ADHD | `sc_attention` is good |
| Hearing | 26 | newborn screening | 3 mentions, no page |
| Premature or NICU, twins, Down syndrome, CP, disability papers | 0–14 each | — | Low in the pool. These parents are few, and the need is deep. Keep the depth, add no breadth |

### What a parent meets today
1. **Every age opens on "Born early, and the NICU"**, so a 3-year-old's parent worried about speech starts on NICU and twins. Only 5 of 11 pages have an age tag.
2. **Speech and therapies are missing.** These are the top two questions, so a parent who has heard "he needs speech therapy" finds nothing on:
   - what it is
   - what it costs
   - how to find a good therapist
   - that the DEIC gives it free
3. **"Help in India" is one card page.** It names RBSK, DEIC, UDID, the RPwD Act and RTE, with no steps. Missing:
   - how to apply for UDID
   - Niramaya health insurance
   - the 80DD tax deduction
   - state disability pensions and scholarships
   - what a shadow teacher or an IEP is
   - RCI-registered therapists
4. **Missing pages:**
   - hearing checks
   - a child who has a diagnosis from birth (Down syndrome, cerebral palsy, a heart condition): first steps
5. **Help:**
   - The "Talk to a paediatrician" closing isn't drawn (S3).
   - No expert sits next to the worry: no developmental paediatrician, speech therapist or child psychologist.
6. **Links:**
   - Development's speech pages aren't linked.
   - Behaviour's head-banging and eating-mud pages point here (BH6), but nothing points back.
   - NICU feeding doesn't link Feeding.
7. **No films, no hero photo, no door intro.**

## SC1. Each age opens on what fits
**Tab order by age** (S1):

| Age | Order |
|---|---|
| 0–12 months | Born early, Twins, Extra support, Help in India, Looking after yourself |
| 1–6 years | Extra support, Help in India, Looking after yourself, Twins, Born early |

**Tags** (S2):
- `sc_nicu` → 0–12 months
- `sc_sensory`, `sc_late_bloomer` → 1 year and up
- twins pages stay as they are

**First page on Extra support from 1 year:** the new "Not talking yet" page (SC2).

## SC2. Speech, therapies, hearing, and a diagnosis from birth (copy in `12-special-care-content.md`)
**New pages:**
- **"Not talking yet: what to do next"** (1 year and up)
  - the by-age signs, linked from Development (not repeated here)
  - the hearing check first
  - what a speech assessment is
  - what to do at home
  - where to go: the DEIC, free, or a private therapist
- **"Speech therapy and the other therapies, explained"**
  - speech therapy, OT, physiotherapy and a special educator: what each does and a session in plain words
  - how often, and that home practice is what counts
  - **what it costs in India:** a range per session in INR and USD, private versus free at a DEIC or government hospital
  - **how to find a good one:** RCI-registered, works with you in the room, sets goals you can see
  - a caution on centres promising a "cure"

  REQUIRED_REVIEW.
- **"Hearing checks"**
  - the newborn hearing screen (OAE)
  - signs at each age
  - ear infections and glue ear
  - where to get tested
  - links Health
- **"If your child has a diagnosis from birth"**
  - Down syndrome, cerebral palsy, a heart condition: the first weeks, in steps
  - early intervention at the DEIC
  - feeding help
  - parent groups
  - "you are still his parent first"
  - the parent page linked

**Deepened:** `sc_late_bloomer` gets "Questions to ask at the assessment".

## SC3. Help in India, step by step
`sc_help_india` becomes steps, not names. REQUIRED_REVIEW, schemes checked before release.
- **The UDID card:** apply on the portal, then the medical board at a district hospital, then the card. Say what to carry.
- **Niramaya** (National Trust) health insurance for autism, CP and intellectual disability.
- **Income tax 80DD** for a parent caring for a dependant with a disability.
- **State disability pensions and scholarships:** "ask at the district social welfare office"; amounts vary by state.
- **School:**
  - the RPwD Act and RTE
  - what a shadow teacher and an IEP are
  - CBSE exemptions, later
- **The professionals:** check RCI registration, for therapists and special educators.

## SC4. Help next to the worry
- **An expert row on Extra support,** below the first row: "Worried? A developmental paediatrician, speech therapist or child psychologist". Experts aren't live yet, so a tap opens "experts joining" (S8e).
- **The closing is drawn** (S3).
- **Consult roles open the right specialist:**
  - `pp_experts/Developmental paediatrician`
  - `/Speech therapist`
  - `/Child psychologist`

  Roles that don't exist yet are added to the expert list, and the experts are still owed.

## SC5. Links both ways
| From | To |
|---|---|
| "Not talking yet" | Development `dev_speech_by_age`, `dev_speech_flags` |
| `dev_autism_signs` | Behaviour `beh_head_banging`, `beh_eating_nonfood` (the reverse of BH6) |
| `sc_nicu` and `sc_preemie_home` | Feeding's premature-baby feeding page; First 40 |
| `sc_parent_wellbeing` | You, Maa `mind_rage` and the low-mood pages |
| "Hearing checks" | Health's ear pages |

## SC6. Films and the hero
- **Film slots,** each tapping to "This film is still being made" (S8a) until it exists:
  - door intro `special_care/door_intro`
  - "What a speech therapy session looks like"
  - "Kangaroo care in the NICU"
- **The doctor and therapist films are real people,** per the video plan rules.
- **A hero photo** (Unsplash, free): a parent and child playing together on the floor, calm, nothing clinical.

## SC7. Names
- All five tab names fit two lines at the card width, including at large text, so no renames.
- **The door comment is fixed:** five areas, plus the new pages listed.

## Taps that can't happen yet (S8)

| Target | What she sees |
|---|---|
| 3 films | "still being made" |
| Developmental paediatrician, speech therapist, child psychologist | "experts joining" |

## Build order (after step 0 and your go)
1. Tags and tab order
2. The four new pages
3. Help in India steps
4. Expert row and roles
5. Links
6. Films and hero

**Reuse:**
- the S1 tab order
- `PpDoorTab.expert`
- M4 `PpLink.pageId`
- `pvToast` S8a/e
- the Tele-MANAS line already on `sc_parent_wellbeing`

## Verification
- A new `test/pp_special_care_door_test.dart`:
  - the opening tab at 0–12 months and at 1–6 years
  - the first page on Extra support from 1 year
  - the four new pages are reachable
  - every page has a doctor callout or a link to one
  - no page names a cure
- `pp_gap_doors_test`
- `door_names_fit_test`
- `flutter analyze` on touched files
- grep call sites

## Decisions
These stay here on purpose. When a problem turns up later, check this table first: if an answer covers it, the fix follows that answer.


| # | Decision | Why (what parents want) | Answer |
|---|---|---|---|
| SC1 | Babies open on NICU; 1–6 open on Extra support | A 3-year-old's parent worried about speech starts on NICU today | **Yes**, chosen and recorded (2026-10-25) |
| SC2 | New pages: not talking yet, the therapies and their cost, hearing, a diagnosis from birth | Speech (458) and speech therapy (117) are the top questions, with 0 pages | **Yes**, chosen and recorded (2026-10-25) |
| SC3 | Help in India as steps: UDID, Niramaya, 80DD, pensions, school | Names alone don't help a parent act | **Yes**, chosen and recorded (2026-10-25) |
| SC4 | The right specialists next to the worry | The paediatrician alone isn't who she needs | **Yes**, chosen and recorded (2026-10-25) |
| SC5 | Links both ways with Development, Behaviour, Feeding, You Maa, Health | Plain fixes | **Yes**, chosen and recorded (2026-10-25) |
| SC6 | Films (real people) and a hero photo | Every door gets an intro | **Yes**, chosen and recorded (2026-10-25) |
| SC7 | Names fit; comment fixed | Plain fixes | **Yes**, chosen and recorded (2026-10-25) |
