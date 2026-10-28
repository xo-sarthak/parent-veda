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
  - **what it costs in India:** a range per session in rupees only (the user, 2026-10-26), private versus free at a DEIC or government hospital
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

## As built (2026-10-26)
Held by `test/pp_special_care_door_test.dart` (20 tests): the tab order for every band; every page's age (a new page fails until it has a row) and none outside its area's; Not talking yet first in its area; the first view at 3 months (the NICU, no speech page) and at 18 and 40 months (Extra support opens, Not talking yet drawn before the therapies and autism pages, the NICU tab last); the four new pages in Extra support, each opening on its intro; every page with a doctor callout, a consult, or a link to a page that has one; Not talking yet linking Development's two speech pages and Early learning's Help him talk, with no by-age cards of its own, and both Development pages linking back; the therapies' four kinds, the cost in rupees and no dollar sign; hearing checks linking Health's two pages without repeating its signs, and Health linking back; the diagnosis-from-birth steps and links; Help in India's seven steps by title, the old cards below; the assessment questions; **no page names a cure** (the word appears once, in the warning about centres, and "outgrow" nowhere); the expert row and each consult opening the specialist it names, checked by the list that opens (`ProviderResultsScreen.need.category`), never the whole roster, and the row's tap on screen; the closing card on the other tabs; every link landing on a page, the SC5 pages exactly, Behaviour's BH6 links and First 40's still in place; Tele-MANAS its own card, from the constant, in no doctor box, and 14416 typed nowhere in the live source; the two film slots, a film's tap, the hero; the tab names. `door_names_fit_test` measures both new names (fit at 1.0 and 1.3; both off `_kOwedShorterNames`, the old entries commented out). The parenting stage passes (`test/pp_*`, `post_pregnancy*`, `phases_test`, `door_names_fit_test`, plus `reader_unification_test` and `consult_call_test`, which read the reader and the consult routes: 130 files, 1,479 tests).

**Caught by the stage run, not this door's test:** `pp_gap_doors_test` asks every link in this door for a screen through `l.surfaceId!`, so the six in-door links first written as `PpLink(pageId:)` crashed it (the door's own test passed, because it resolved them against the section). They are `pp_page/parenting_special_care/<id>` surfaces now, as `sc_late_bloomer` already wrote its link to Help in India, and the door test reads both.

**The shell: nothing new.** `tabOrder` (S1), `PpDoorTab.expert`, the closing card (S3), `pp_page/<section>/<page>`, `PpConsult` and `kPpJoiningSoon` (S8b) covered everything. The door is data plus copy.

**What was built, by decision:**
- **SC1.** The tab order per band as the plan's table. `sc_nicu` is tagged 0 to 12 months; `sc_sensory` and `sc_late_bloomer` from one. Not talking yet is the area's first page, so it leads Extra support from one; a baby's parent sees the two untagged new pages there (hearing checks, a diagnosis from birth).
- **SC2.** Four new pages in `additional_needs`: "Not talking yet: what to do next" (from one; five steps, Development's two speech pages, Hearing checks and Help him talk linked, the doctor line, a speech therapist consult, the India note); "Speech therapy and the other therapies, explained" (from one; the four therapies, how often as its when line, the cost in rupees, how to find a good one ending on the cure warning); "Hearing checks" (every age; where to get tested, linking Health); "If your child has a diagnosis from birth" (every age; six steps, feeding help, Help in India and the parent page linked, a developmental paediatrician consult). `sc_late_bloomer` gains "Questions to ask at the assessment".
- **SC3.** `sc_help_india` is STEPS: seven steps (the DEIC, the UDID card with what to carry, Niramaya, 80DD, pensions and scholarships, school with the IEP and the shadow teacher, the RCI), then Early learning's nursery admission and acting early, then the old cards under "The names, in short", as the content file says. `format: 'CARDS'` is commented out, kept for revert.
- **SC4.** "A developmental paediatrician" ("Worried about talking, moving or playing?") on Extra support, after its first rail; the tab ends on the doctor sentence, the other four on the door's closing card (drawn since step 0; checked, not rebuilt). Three consults: the speech therapist on Not talking yet, the child psychologist on the attention page (whose doctor line already named one), the developmental paediatrician on the diagnosis-from-birth page.
- **SC5.** `dev_autism_signs` links Behaviour's `beh_head_banging` and `beh_eating_nonfood` (BH6 reversed) and Not talking yet; `sc_nicu` links Feeding's `bf_exclusive_pumping` and `bf_special_situations` and First 40's `f40_small_or_early`; `sc_preemie_home` links the First 40 page and the pumping page; `sc_parent_wellbeing` links You, Maa's `mind_rage` and `mind_love_but_not_okay`. DV10's Special care half: `dev_speech_by_age` and `dev_speech_flags` link Not talking yet. Health's `ears_hearing` links Hearing checks.
- **SC6.** Two film slots: `special_care/kangaroo_care` on `sc_nicu`, `special_care/speech_session` on `sc_therapies`; each tap says "still being made" (S8a). Hero: Unsplash, free (Vitaly Gariev, `IGnXUcRKZzQ`), a parent and a toddler building block towers on the floor, checked by eye.
- **SC7.** "Preemies and NICU" and "Looking after you" (the user's words, 2026-10-26); the door comment lists the five areas and the new pages; the content file's header says 15 pages and the no-cure rule.
- **Tele-MANAS, fixed in passing.** `sc_parent_wellbeing` had "call Tele-MANAS on 14416" typed inside its doctor box. The doctor line now names the doctor only, and "If there is nobody to talk to" is its own card from `kCrisisHelplineName` / `kCrisisHelplineNumber`, as Behaviour and Traditions draw it. The old callout is commented out, kept for revert.

**A mechanism worth keeping: a twin can hide in another door's name for the same thing.** The plan asked for a new "Hearing checks" page with the newborn screen, the signs at 3, 6 and 12 months and glue ear. Health already had all three on `ears_hearing` ("Hearing, from the newborn test onwards"), filed under Keeping well, which no grep for "Hearing checks" or `ill_ear` finds. Writing the plan's page would have put two sets of age signs in the app, which drift the first time a reviewer corrects one. So the new page holds only what Health's does not (where to get tested in India, the DEIC, tests that need no answers) and links Health for the rest. The general point: before writing a page, search for the *idea* in every door's titles and subtitles, not for the page id a plan happens to name.

**A second one, about which list a consult opens.** The plan routed the developmental paediatrician through `pp_experts/Developmental paediatrician`. That category is not in `kFindHelpNeeds`, so S8b would answer it with "We're adding developmental paediatricians" and a paediatrician, which is honest. But the same people already exist under `Development expert` (two seeded developmental paediatricians, with their own joining words), and Development's On track row uses it. Two names for one specialist would mean the day a real developmental paediatrician signs up, one door shows her and the other still says "we're adding". One category, every door. The test checks the category of the list that opens, not only that a screen opened, because a screen with the wrong list passes every wiring gate.

**Differences from the plan, and why:**
| Plan | Built | Why |
|---|---|---|
| SC7: "all five tab names fit, so no renames" | Two renamed: "Preemies and NICU", "Looking after you" (old labels commented out, kept for revert) | `door_names_fit_test` had both on `_kOwedShorterNames` (three lines at 1.3). Measured with Manrope's widths at 1.0 and 1.3; the names are the user's choice, 2026-10-26 |
| SC2: "Hearing checks" with the newborn screen, the signs by age, glue ear | Where to get tested, the DEIC, tests that need no answers; Health's `ears_hearing` (the newborn test, the signs) and `ill_ear` (infections, fluid) linked | Health owns them (single source). See the mechanism above |
| SC2 copy: "he", "him", "his" | "your child", "your baby", "theirs" | The section's own voice. "Help him talk" stays as a link label: it is the Early learning page's title |
| SC2: "a diagnosis from birth", bands "0–12 months and up" | Untagged (every age) | In this section an untagged page reads as every band; the steps (the papers, school later, parent groups) serve any age |
| SC2: Not talking yet step "Link: Hearing checks (§3)" | Links this door's `sc_hearing` | The page where to get tested; it links Health's signs in turn |
| SC2 India note: "he's just lazy to talk" | "the child is just lazy to talk" | The page's voice |
| SC2: "Feeding help early ... Link: Feeding" | Feeding's `bf_lactation_help` | The page about getting a lactation consultant, which is what the step asks for |
| SC4: `pp_experts/Developmental paediatrician` | `pp_experts/Development expert` | The same people under the category Development already uses. See the second mechanism |
| SC4: "Roles that don't exist yet are added to the expert list" | No categories added | Health H5: an empty category puts a need with nobody in it on Find help, which `pp_consult_filter_test` forbids. Speech therapist and Child psychologist already exist and open filtered; Development expert says "joining" (`kPpJoiningSoon`) |
| SC4: "a tap opens 'experts joining'" for all three | The developmental paediatrician says "joining" and offers a paediatrician; the speech therapist and child psychologist open their own lists | Those two categories have profiles not flagged seeded, so the router lists them. Real people are owed for all three (SPO2–SPO4) |
| SC4: one row naming three specialists | One row, the developmental paediatrician; the other two as consults on the pages that name them | One row opens one list. The developmental paediatrician is the one who looks at the whole picture and refers on; a row naming three and opening one would promise what the tap does not do |
| SC5: `sc_nicu` → "Feeding's premature-baby feeding page" | `bf_exclusive_pumping` and `bf_special_situations` (donor milk) | Feeding has no premature-baby page; these are its two pages for a baby in the NICU. First 40's `f40_small_or_early` holds feeding a small baby at home |
| SC5: "`sc_parent_wellbeing` → You, Maa `mind_rage` and the low-mood pages" | `mind_rage` and `mind_love_but_not_okay` | The low-mood page that is not about the first weeks (`mind_blues_vs_ppd` is postpartum) |
| SC5: the hearing row one way | Both ways: `ears_hearing` links Hearing checks | The section heading says "both ways" |
| Verification: "every page has a doctor callout or a link to one" | Two twins pages gained a doctor line (pumping: a hot or red patch, or fever, the same day, and a lactation consultant for low supply; daily life: twins months apart, ask at the next check); Help in India links acting early | They had none. REQUIRED_REVIEW |
| SC6: door intro `special_care/door_intro` | Not slotted | S4: no chip until a film exists. Owed SPO1 |
| Verification: a Mobbin check, a prototype | Not run | The user's brief for this build; no new layout |
| Verification: a phone walk | Not run | Only on the user's word |

**Owed, not in this build:** the two films and the intro (`DOOR-CONTENT-OWED` SPO1), real developmental paediatricians (SPO2), speech therapists (SPO3) and child psychologists (SPO4), a therapy shelf only if a therapist picks it (SPO5). On `BEFORE-LAUNCH.md`: a developmental paediatrician's read of every clinical line, a speech therapist's of the speech and therapy pages, the costs dated, and every scheme and its steps checked against current government notices. The new pages reach Ask Veda through the incremental ingest, which the user runs after all the doors.

**Final review, item 4 (2026-10-27): one figure per fact.** Twin pumping gives Feeding's storage figures (four hours in a cool room, two on a hot day) and links `bf_pumping` (4m). Held by `test/pp_one_figure_test.dart`; the figures are on the BEFORE-LAUNCH clinical read.

**Final review, item 5 (2026-10-27): pages written twice.** `sc_preemie_home` repeated First 40's `f40_small_or_early` (warmth, feeds, infections, go-now). It is now "After the NICU: eye checks and corrected age": ROP screening, hearing and growth checks, corrected age and vaccines by birth date, with links to `dev_born_early` and back to First 40. The old blocks are commented out. Held in `test/pp_special_care_door_test.dart`.

**Final review, item 12 (2026-10-28): her own history picks the opening tab.** A twins mother lands on Twins, a born-early baby's on Preemies and NICU, and a family-profile delay, hearing or vision answer on Extra support, each with "First here, because ..." when it moved the tab (none when age already put it first). Order only; the six Extra support pages lead their rail. Held by `test/pp_history_lift_test.dart`.
