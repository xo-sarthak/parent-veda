# Door 2: Health, the plan

Written 2026-10-23. **Status: H1 to H7 all answered YES by the user 2026-10-23.** The new pages are written in `02-health-content.md` (H6). The H2 age-rail look is drawn at `claude.ai/artifact/1fMmpwSHeQwwaUjEWjQ89Q` and was APPROVED 2026-10-24 (version 4: emergency row on top, the age shelf next, the paediatrician row after that shelf). Plan final; build waits on step 0.
The build waits on step 0 (`00-MASTER.md`, S1 to S7) and on the user's go.

Files this plan touches:
- Door map: `lib/data/doors/pp_door_health.dart` (186 lines, 7 tabs)
- Content: `lib/screens/post_pregnancy/pp_health_content.dart` (5,202 lines, 15 areas, 77 pages)
- The one go-now list: `lib/screens/post_pregnancy/pp_health_red_flags.dart` (`kPpGoNowSigns`)
- Bands: `kPpHealthBands`, four of them
  - `hb_nb` 0 to 3 months
  - `hb_infant` 3 to 12 months
  - `hb_toddler` 1 to 3 years
  - `hb_child` 3 to 6 years

Health has its own newborn band because a fever under three months is an emergency and at eight months it usually isn't.

Mechanisms reused from the Feeding plan (`01-feeding.md` §2 and §3), with nothing new invented for them:
- `PpDoor.tabOrder`
- `PpDoorTool.bands`
- `PpDoorTab.expert`
- `PpDoorTab.extraPageIds`
- `PpDoor.introVideoSlot`
- the reader's offer slot, placed per D2 (approved 2026-10-23, `claude.ai/artifact/6Kgs3uNdKsbyKybfbdzdRB`)

Two new mechanisms are proposed in §2: **H-M1**, a lead rail for her age, and **H-M2**, an exact band match ranking first.

---

## 1. What a parent sees today, and why it is wrong

**Door type: an explain door with a triage front.** When her child is unwell, the first thing she needs is a fast, calm answer: watch at home, see a doctor today, or go now. When he is well, she needs the calm jobs: shots, growth, prevention, papers.

Today, at any age, she sees:

| What | Today | Problem |
|---|---|---|
| Opening tab | "Something's wrong" (tab 0) | The right tab. It stays the opener at every age (see §2a). |
| First things on that tab | "Is this an emergency?" jump row, then Fever check and "Something suddenly different" | Good: action first. |
| First rails | Fever, then Cough and cold, then Tummy, then Skin, then Other illness, the same order for a 2-week-old and a 4-year-old | A newborn's parent needs fever-under-3-months, jaundice, newborn skin and colic first. Those pages are spread across four rails and sit mid-rail. A toddler's parent needs the creche bugs (colds, hand-foot-mouth, tummy bugs, ears) first. |
| Expert | The "Talk to a paediatrician" closing exists in data and **is never drawn**. Four pages carry a consult, and all four are foot tiles at the end of the read. | This is the user's own example ("if your child is unwell… consult an expert is at the very end"). |
| Age tags | 11 of 77 pages tagged | Untagged pages show at every age (S2). For example, nappy rash, teething fever and blocked-nose suction still show for a 5-year-old. |
| Get help now | The red flag `health_go_now`, then a rail that starts with `health_signs_video`. That page is a 362-character stub: a video slot, a sentence and a link back to the red flag. | The film that matters most in the app is a separate, nearly empty page. It belongs inside the red-flag page. |
| Emergency card | The same tool on two tabs (Get help now and Records) | The same thing twice. |
| Tabs | 7: Something's wrong · Get help now · Vaccines · Growing well · Keeping your child well · Medicines, safely · Records and the visit | The file header says "six" and is stale since Medicines was added on 10-07. Seven is fine if the order follows age (§2a). |
| Videos | 13 `PpVideoSlot`s, all placeholders, all labelled "Article" on the rail card (S5) | No door intro. No demo of the four skills a parent needs by hand: taking a temperature, saline and suction for a blocked nose, giving medicine with a syringe, and the glass test. |
| Products | 4 Health shelves (`pp_compare/First aid`, `Lotions`, `Rash creams`, and the nuskhe tool) | The catalogue's **Forehead Thermometer** leads, while our own `fever_reading` page says forehead scanners "drift" and to confirm with a digital thermometer. The shelf disagrees with the page. |

---

## 2. The new door, band by band

### 2a. Tab order per band (`PpDoor.tabOrder`)

"Something's wrong" opens at every age, and "Get help now" is always second. This is an **explicit exception to S1's "most pages for her band" rule**. A sick child is the reason most parents open Health, and the triage tools live on that tab. The rest follow the age.

| Band | Tab order |
|---|---|
| hb_nb 0 to 3m | Something's wrong · Get help now · **Records and first checks** · Vaccines · Growing well · Medicines · Keeping well |
| hb_infant 3 to 12m | Something's wrong · Get help now · **Vaccines** · Growing well · Medicines · Keeping well · Records |
| hb_toddler 1 to 3y | Something's wrong · Get help now · **Medicines** · Keeping well · Vaccines · Growing well · Records |
| hb_child 3 to 6y | Something's wrong · Get help now · **Keeping well** · Medicines · Growing well · Vaccines · Records |

Why:
- **Newborn:** the first checks (screening, first visits) and the papers (birth certificate, records) are this band's real jobs. Vaccines come next because birth doses and the 6-week visit are close.
- **Infant:** the densest vaccine year. Growth is weighed at every visit.
- **Toddler:** the illness years. Giving medicine correctly and preventing the next bug matter most.
- **Child:** prevention, teeth, eyes, and screens.

**Over 6 years** (`hb_child` ends at 72 months): no band matches, so the file order stays. That is fine, because the app's parenting age runs to 216 months and Health's pages still apply. Recorded as a gap, not fixed here. When an older-child band is written, it gets its own row.

**Decision H1:** should the Vaccines tab card show a due line ("Due in 5 days") when a dose is within 14 days? The tab rail already has a one-line count slot; it is quiet today (`kPvDoorRailQuiet`). Recommended: **yes**. It is the one tab-card line worth showing, and it reads `PpVaccineStore`, which already holds the due dates.

### 2b. Tab labels
- "Keeping your child well" becomes **"Keeping well"**: shorter on a 128-wide card, same meaning. It is low-stakes, so it is not a decision; say no if you disagree.
- "Records and the visit" becomes **"Records and first checks"**, because it holds `newborn_checks`. The old label hid them.

### 2c. Tools get ages (`PpDoorTool.bands`)

| Tool | Tab | Bands | Placement |
|---|---|---|---|
| Fever check | Something's wrong | all | Leads |
| Something suddenly different | Something's wrong | all | Second |
| Emergency card, ready to show | Get help now | all | After the red flag. **Removed from Records** (commented out, "kept for revert"). The Records dashboard already links it. |
| Vaccines, and what is due next | Vaccines | all | Leads |
| Weight, height and head size | Growing well | all | Leads. Head size matters to 2y; the tool shows it anyway. |
| Home remedies, marked honestly | Keeping well | infant → child | Leads. **Not for hb_nb**: no home remedy is right for a baby under three months. The tool's own data should agree; verify in the build. |
| Health record and papers | Records | all | Leads |
| Before you see the doctor | Records | all | Second. **Also on Something's wrong, `atEnd`**, because "what to tell the doctor" is part of a sick-day visit. A tool on two tabs is allowed (Feeding set that precedent). |

### 2d. A rail for her age first (new mechanism H-M1, **decision H2**)

**Problem:** the illness pages are grouped by body part (fever, chest, tummy, skin, other), which is right for searching. But the pages a parent of *this* age needs are scattered across five rails.

**Proposal:** a new `PpDoorTab.ageRail: Map<bandId, PpAgeRail(title, pageIds)>`.
- It is drawn as the **first rail** on the tab, right after the tools and the expert row.
- The area rails below skip any page already shown in it, so nothing appears twice.
- It is plain data, not a score, so a test holds it row by row.
- It is generic, so later doors can use it: Sleep (4-month regression), Behaviour (tantrums at 2).

On "Something's wrong":

| Band | Rail title | Pages, in order |
|---|---|---|
| hb_nb | In the first three months | fever_under_3m · ill_jaundice · skin_newborn · tummy_colic · cold_blocked_nose · ill_thrush |
| hb_infant | Common at 3 to 12 months | ill_teething_fever · cold_common · tummy_diarrhoea · skin_nappy_rash · skin_eczema · ill_ear · *new* `ill_febrile_seizure` (see §5) |
| hb_toddler | The creche years | cold_common · skin_hfmd · tummy_diarrhoea · tummy_vomiting · ill_ear · cough_breathing · ill_eyes |
| hb_child | Common at 3 to 5 years | *new* `ill_throat` · cold_common · tummy_constipation · ill_ear · skin_chickenpox · *new* `ill_worms` |

Alternative if H2 is no: tag pages only (§2e) and lift exact-band pages (H-M2). That is weaker, because a newborn page still sits in the fourth rail.

**Prototype first:** this changes the layout order, so an Artifact of the 3-week and 2-year first views goes to the user before any `lib/` edit (light mode, the real chrome, same as D2).

### 2e. Every page's age tag

Codes: N = hb_nb, I = hb_infant, T = hb_toddler, C = hb_child. "all" = leave untagged (every band, by design).

| Area | Page | Today | New tag | Why |
|---|---|---|---|---|
| emergency | health_go_now | all | all | |
| emergency | health_signs_video | all | **folded** | Its video slot moves into `health_go_now` as the page's first block. The stub page is commented out, and `linkedOnly` keeps old links working (see §2f). |
| emergency | health_three_speeds | all | all | |
| emergency | health_choking_response | all | all | Infant and child steps are already split inside |
| emergency | health_fit | all | all | |
| emergency | health_accidents | all | all | |
| fever | fever_what_number | all | I T C | A newborn reads `fever_under_3m` instead. The number is the same, but the action is different. |
| fever | fever_reading | all | all | |
| fever | fever_under_3m | N | N | Pinned first for N (H-M2 makes it lead) |
| fever | fever_bringing_down | all | I T C | Under 3 months nothing is brought down at home; see a doctor. The page's own text should say so. Check it. |
| fever | fever_dosing | all | I T C | Same reason: no paracetamol for under 3 months without a doctor. |
| fever | fever_red_flags | all | all | |
| fever | fever_remedies | all | I T C | Remedies tool, not for N (as §2c) |
| fever | fever_long | all | I T C | |
| cough_cold | cold_common | all | all | |
| cough_cold | cold_blocked_nose | all | N I T | Suction is a baby skill. Older children blow. |
| cough_cold | cough_syrups | all | I T C | Under 2, no cough syrup at all. The page already says so. A newborn's parent should not be shown the choice. |
| cough_cold | cough_remedies | all | I T C | |
| cough_cold | cough_breathing | all | all | |
| tummy | tummy_diarrhoea | all | all | |
| tummy | tummy_ors | all | all | |
| tummy | tummy_dehydration | all | all | |
| tummy | tummy_vomiting | all | all | |
| tummy | tummy_constipation | all | I T C | Newborn stools are a First 40 and Feeding question |
| tummy | tummy_colic | N I | N I | Infant only to 5 months; the band is wider, which is fine |
| skin | skin_which_rash | all | all | |
| skin | skin_hfmd | all | I T C | |
| skin | skin_nappy_rash | all | N I T | |
| skin | skin_eczema | all | all | |
| skin | skin_heat_rash | all | all | |
| skin | skin_newborn | N | N | |
| skin | skin_chickenpox | all | I T C | |
| other_illness | ill_teething | I T | I T | |
| other_illness | ill_ear | all | I T C | |
| other_illness | ill_eyes | all | all | Sticky newborn eye is in it |
| other_illness | ill_jaundice | N | N | |
| other_illness | ill_allergies | all | I T C | |
| other_illness | ill_teething_fever | all | I T | |
| other_illness | ill_uti | all | all | |
| other_illness | ill_thrush | N I | N I | |
| not_sure | ns_what_changed, ns_problem_solver | hidden | hidden | Unchanged. The tools lead the tab. |
| vaccines | vax_schedule | linkedOnly | linkedOnly | |
| vaccines | vax_what_each | all | all | |
| vaccines | vax_after | all | all | |
| vaccines | vax_catch_up | all | I T C | A newborn cannot be behind yet |
| vaccines | vax_cost | all | all | |
| growth | growth_normal, growth_percentiles, growth_flags | all | all | |
| records | rec_doctor_visit | all | all | |
| records | rec_checkups_by_age | all | all | |
| records | rec_surgery | all | I T C | |
| records | health_emergency_card, rec_wallet | linkedOnly | linkedOnly | |
| newborn_checks | nb_screening, nb_first_visits | N I | N I | |
| prevention | prev_handwashing, prev_immunity, prev_monsoon, prev_pollution, prev_sick_home | all | all | |
| prevention | prev_private_parts | all | T C | Body safety starts with words at about 2 |
| prevention | prev_head_lice | T C | T C | |
| prevention | prev_nails_ears | all | all | |
| medicines | prev_medicine, prev_antibiotics | all | all | |
| medicines | prev_allergy_probiotics | all | all | |
| teeth_eyes_ears | teeth_when | all | I T | Eruption runs from 6 months to 3 years |
| teeth_eyes_ears | teeth_brushing | all | I T C | From the first tooth |
| teeth_eyes_ears | teeth_dentist | all | I T C | First visit by the first birthday |
| teeth_eyes_ears | eyes_checks, ears_hearing | all | all | |
| teeth_eyes_ears | eyes_screens | T C | T C | |
| long_term | lt_asthma, lt_weight, lt_coeliac | T C | T C | |

### 2f. New mechanism H-M2: an exact band match ranks first (a step 0 addition, every door)
- `ppRelevanceOrder` scores `PpBandDistance.now` as 0 for a page tagged with her band **and** for an untagged page, so they tie. File order then decides.
- Proposal: a page tagged for exactly her band scores `-10`, which lifts it above untagged pages in the same rail.
- Where it matters: `fever_under_3m` leading the Fever rail for a newborn; `ill_teething` leading Other illness for an infant.
- It is one line in `pp_relevance.dart` plus a test row. It belongs to step 0 because every door benefits.
- Trade-off: it costs a small rule every door now obeys, and it means writers no longer fully control the order in a rail. It buys correct age order without hand-pinning pages per band. Signals from what she told us still lift more (-30 and -40), so "what's on her mind" still wins.

### 2g. The Get help now tab
Order, top to bottom:
1. **Red flag** `health_go_now`. Its first block becomes the film "The signs that mean go now" (`health/when_to_rush`, 5 min). The film is the explanation; the list is the reference.
2. Emergency card tool.
3. Rail: three speeds (interactive), then choking, fit, accidents.
4. Footer: "If your child seems wrong to you and a screen says otherwise, believe yourself." (kept)
5. **No expert row and no pitch on this tab.** Emergencies go to 112 or a hospital, never to a video consult (the same rule as Feeding's Safe tab).
6. **Decision H3:** a "Learn it on a calm day: baby first aid and CPR" class card, *after* the footer, never above the rails. Recommended: **yes, at the very end of the tab only**. It is the one offer that makes the next emergency go better, and placing it last keeps the panic path clean.

### 2h. Help the parent find the right speed in two taps
No new tool; this records what already works. On Something's wrong, the jump row "Is this an emergency?" goes to Get help now, and Fever check gives "now, today or watch". The first-view test holds that these three stay first.

---

## 3. Experts, classes and products next to the worry

### 3a. The telemedicine safety rule (new, applies to every Health pitch)
A video consult must never delay an in-person visit when a sign is on the go-now list. So:
- **No pitch** on these pages: `health_go_now`, the choking response, `health_fit`, `health_accidents`, `fever_under_3m`, `tummy_dehydration` (a go-to-hospital page), `growth_flags` (that route is the paediatrician in person).
- **The two callouts are never stacked (user, 2026-10-23).** On Something's wrong, "Is this an emergency?" stays on top and the age shelf follows it directly; the paediatrician row sits after that first shelf, so the door content is not pushed down. Because the two are apart, the expert row keeps its quiet line: "Not for an emergency. For that, Get help now." Offer cards inside a page read carry the same line.
- The test scans the source and fails if a `PpConsult` or `PpDoorTab.expert` sits on any of these pages or on the help tab.

### 3b. The expert row per tab (`PpDoorTab.expert`, S3)
**Something's wrong** is the user's own example, so its row goes **higher than Feeding's**: right after the tools, before any rail.

| Tab | Row | Goes to | Place |
|---|---|---|---|
| Something's wrong | "Not an emergency, but not right? Talk to a paediatrician today · video" + the quiet safety line (§3a) | `pp_experts/Pediatrician` (4 seeded) | After the first rail (the age shelf), never directly under the emergency row |
| Get help now | none | | |
| Vaccines | "A missed or delayed dose? Ask a paediatrician" | `pp_experts/Pediatrician` | After the first rail |
| Growing well | "Worried about his weight or height? Talk to a paediatrician" | `pp_experts/Pediatrician` | After the first rail |
| Keeping well | "Teeth, eyes, skin: the right specialist" | `pp_experts` filtered to Child derma for now, plus the owed roles in §3d | After the first rail |
| Medicines | "Unsure about a medicine? Ask a paediatrician before you give it" | `pp_experts/Pediatrician` | After the first rail |
| Records | "Book his next check-up" | `pp_experts/Pediatrician` | After the tools |

### 3c. Consults inside pages (the D2 pattern: the offer card under the doctor box, plus the foot tile, one pitch per page)

Existing 4:

| Page | Expert | Note |
|---|---|---|
| fever_red_flags | Paediatrician | **Kept, after the go-now list.** The card reads "Not on this list, still worried?" The page lists go-now signs, so the safety line from §3a matters most here. |
| cough_breathing | Paediatrician | |
| ill_allergies | Paediatrician (paediatric allergist when the role exists) | |
| prev_antibiotics | Paediatrician | |

New, to be added (the worry is real and nothing is offered today):

| Page | Expert | Exists? |
|---|---|---|
| cold_common | Paediatrician ("still going after 10 days") | yes |
| fever_long | Paediatrician (fever over 3 days) | yes |
| tummy_diarrhoea | Paediatrician | yes |
| tummy_vomiting | Paediatrician | yes |
| tummy_constipation | Paediatrician | yes |
| skin_which_rash | **Child dermatologist** (sends a photo first) | yes, 2 seeded ("Child derma") |
| skin_eczema | Child dermatologist | yes |
| skin_nappy_rash | Child dermatologist (only when it won't clear in 3 days) | yes |
| skin_hfmd | Paediatrician | yes |
| ill_ear | Paediatrician (ENT once it exists) | yes / owed |
| ill_eyes | Paediatrician (paediatric ophthalmologist once it exists) | yes / owed |
| ill_uti | Paediatrician | yes |
| eyes_checks, eyes_screens | **Paediatric ophthalmologist** | **owed** |
| ears_hearing | **Audiologist**, plus Speech therapist for speech | owed / yes |
| teeth_brushing, teeth_dentist, teeth_when | **Paediatric dentist** | **owed** |
| growth_percentiles | Paediatric nutritionist | yes |
| lt_weight | Paediatric nutritionist | yes |
| lt_asthma | Paediatrician (paediatric pulmonologist once it exists) | yes / owed |
| lt_coeliac | Paediatrician, then a nutritionist for the diet | yes |
| vax_catch_up | Paediatrician | yes |

Never: the go-now pages (§3a), `prev_private_parts` (a body-safety page, never sold to), `ill_teething` (a comfort page; a consult there would read as alarm).

### 3d. Owed expert roles (new categories in `pp_experts_data.dart`, no invented people)
These are real specialities Indian parents are referred to. They are added as **empty categories with an invitation state** ("We're adding paediatric dentists; ask a paediatrician meanwhile"), never with made-up names. Real profiles arrive with onboarding (the admin panel, `docs/ADMIN-PANEL.md`).
- Paediatric dentist (pedodontist)
- Paediatric ophthalmologist
- Paediatric ENT
- Audiologist
- Paediatric allergist
- Paediatric pulmonologist (asthma)
- Paediatric endocrinologist (growth, early puberty), for `growth_flags`'s in-person referral, never sold on that page
- The "Paediatric first-aid and CPR instructor" already in the roster (`pp_experts_data.dart:212`) runs H3's class.

### 3e. Classes, workshops and courses

| Offer | Exists? | Where it goes |
|---|---|---|
| Baby first aid and CPR (choking, burns, falls, fits). Live, 2 hours, with a mannequin demo on video. | Instructor exists, no class row. Feeding's A3 also lists it, so **one class serves both doors**. | Get help now, at the very end (H3). `health_choking_response` foot tile. Keeping well. |
| Fever, colds and tummy bugs: a calm parent's evening. Live, paediatrician-led, monthly. | owed | Something's wrong, after the age rail |
| The home medicine box. Short self-paced course: what to keep, how to dose by weight, expiry, travel. | owed | Medicines tab, first rail end |
| First tooth to first dentist. Live, pedodontist. | owed | teeth pages |
| Monsoon season: dengue, malaria, typhoid and water. Live, seasonal, June. | owed | prev_monsoon, plus a seasonal lift in June to August via the existing signals |
| Vaccines, the first year, explained. Live, paediatrician, for new parents. | owed | Vaccines tab, hb_nb and hb_infant only |

### 3f. Products (equipment only; **Health never sells a medicine**)
**The rule (decision H4):** the app never sells or links to buy a medicine, supplement, cough syrup, ORS brand, or drops. Those come from a doctor or a chemist by name. This is the Health form of "never a dose from us". Medicines appear only in a **home medicine box checklist**, written generically ("ORS sachets, WHO formula"). Recommended: **yes.**

| Product | Exists in the catalogue? | Page | Band |
|---|---|---|---|
| Digital thermometer, flexible tip (underarm) | **owed**. Should lead the shelf ahead of the forehead scanner. | fever_reading, fever_what_number | all |
| Forehead Thermometer | yes (`pp_products_data.dart:737`) | Second on the same shelf, with our page's own line: "quick, then check with a digital one" | all |
| Baby First-Aid Kit | yes (`:787`) | Keeping well (the new medicine-box page); **not** on Get help now | all |
| Nasal aspirator (manual) | owed | cold_blocked_nose | N I T |
| Cool-mist humidifier (no steam; steam burns) | owed | cold_common, cough_breathing | all |
| Oral dosing syringe set | owed | prev_medicine | all |
| Calm Zinc Rash Cream | yes (`:514`) | skin_nappy_rash | N I T |
| Fragrance-free emollient | `Soothe Baby Lotion` exists (`:477`). **Check the claims**: an eczema page must not sell a scented lotion. | skin_eczema | all |
| Cot and pram mosquito net | owed | prev_monsoon, the new dengue page | all |
| Air purifier (HEPA) | owed | prev_pollution | all |
| Soft first toothbrush, finger brush | owed | teeth_brushing | I T C |
| Baby nail clipper and file | owed | prev_nails_ears | all |
| Fine-tooth lice comb | owed | prev_head_lice | T C |
| Sun hat, and mineral sunscreen for 6m+ | owed | the new heat page | I T C |
| Health record folder (paper) | owed | Records | all |

None on: any go-now page, `fever_under_3m`, or Get help now (§3a).

---

## 4. Videos and demos

- **Door intro** `health/door_intro`, 50 to 60 s, a real paediatrician (per the video-plan rule: doctor welcome videos are real people). It explains the three speeds, where the go-now list is, and that the app never gives a dose.
- **13 existing slots.** Keep all. The one fix is `health/when_to_rush`, which moves into `health_go_now` (§2g).
- **6 new demo films owed** (hands-on skills a parent can't learn from text):

| Slot | Page | Length | Why video |
|---|---|---|---|
| `health/temp_underarm` | fever_reading | 1 min | Where the tip goes, how long, a squirming baby |
| `health/saline_suction` | cold_blocked_nose | 1.5 min | Drops, wait, then suction, without hurting him |
| `health/give_medicine` | prev_medicine | 1.5 min | Syringe to the cheek, not the throat; a spat-out dose; never a kitchen spoon |
| `health/glass_test` | skin_which_rash | 40 s | The single most important rash check. It is also inside the go-now film; this one is short and on the rash page. |
| `health/first_teeth_brushing` | teeth_brushing | 1 min | Rice-grain smear, lap position |
| `health/infant_cpr` | health_choking_response (already holds the choking slot) | 3 min | **Expert-filmed only**, from the CPR instructor. Never AI-generated. |

- Every film row goes into `DOOR-CONTENT-OWED.md`, with its length and "real person / AI scenes" per the video-plan rule. Cost is quoted when briefed.

---

## 5. Depth: thin pages, missing topics, duplicates

### 5a. Thin pages, under about 1,200 characters (deepened in the build; each gets intro, body, a when-line, an India note, and a doctor callout where clinical)

| Page | Chars | What it lacks |
|---|---|---|
| health_signs_video | 362 | Folded into health_go_now (§2g) |
| ill_teething_fever | 797 | A carousel of myths only. Needs: what teething does cause (drool, gum rub, mild warmth under 38 C) and what it doesn't (high fever, diarrhoea). This myth is widely believed in Indian homes. |
| teeth_when | 783 | The table only. Needs: late teeth (no tooth by 13 months), gaps, a chipped milk tooth. |
| teeth_dentist | 666 | Needs: what a first visit is, fluoride varnish, bottle and night-feed caries. |
| eyes_screens | 787 | Needs: the 20-20-20 rule for older children, outdoor time and myopia, a squint seen on photos. |
| ill_thrush | 895 | Needs: treating mother and baby together, sterilising teats, when it is not thrush (milk tongue). |
| lt_coeliac | 901 | Needs: signs by age, that testing happens before cutting gluten, and the Indian diet. |
| ears_hearing | 913 | Needs: the newborn screen (OAE), signs at 6, 12 and 24 months, ear wax and oil myths. |
| prev_nails_ears | 967 | Needs: no ear buds, no oil in ears, cutting nails while he sleeps. |
| nb_screening | 1,049 | Needs: what each test is (hearing, heel prick, CCHD, hip). The state RBSK programme and DEIC. |
| nb_first_visits | 755 | Needs: what happens at 3 to 5 days and at 6 weeks, and what to bring. |
| ill_uti | 1,070 | Needs: "a fever with no cold can be a urine infection" (the key line), how a sample is taken, why it matters under 2. |
| rec_surgery | 1,074 | Needs: fasting, consent, the day itself, common childhood surgeries. |
| prev_private_parts | 1,121 | Needs: correct names, the "safe touch" script, POCSO in one calm line, who to call (1098 Childline). |
| prev_head_lice | 842 | Needs: wet-combing steps, school, no kerosene. |
| eyes_checks | 1,139 | Needs: the red reflex at birth, squint after 3 months, a check by 3 years. |
| prev_allergy_probiotics | 1,265 | Fine for its size; check it isn't a product sell. |
| lt_weight, lt_asthma | 1,238 / 1,361 | Asthma needs the inhaler-and-spacer basics (a video row is owed later) and the myth that inhalers are addictive, which is widely believed in India. |

### 5b. Missing topics, India-relevant, checked against the content (grep counts in brackets; 0 = nothing at all)
New pages, each with intro, body, when-line, India note and doctor callout, marked REQUIRED_REVIEW:

| New page id | Area | Band | Topic | Why it is needed |
|---|---|---|---|---|
| `ill_dengue` | other_illness | all | Dengue: the warning days (falling fever on days 3 to 5), the fluid plan, **no ibuprofen or aspirin, paracetamol only**, platelet panic | Dengue is mentioned 20 times, but only inside other pages. It has no page of its own, and it is the one fever Indian parents fear most. |
| `ill_febrile_seizure` | emergency (linked from fever) | I T C | A fit with fever, 6 months to 5 years: what to do, and what it isn't | `health_fit` covers fits generally ("febrile" 4 mentions); the fever link deserves its own calm page |
| `ill_throat` | other_illness | T C | Sore throat and tonsils: viral or strep, when antibiotics, and the tonsillectomy question | "tonsil" 0 |
| `ill_worms` | tummy | T C | Worms and deworming: **National Deworming Day** (10 Feb and 10 Aug, albendazole for 1 to 19 years, at schools and anganwadis) | "deworm" 0 |
| `ill_anaemia` | growth | I T C | Iron, anaemia and the Anemia Mukt Bharat IFA syrup (for 6 to 59 months; confirm the dose schedule at review) | 4 passing mentions |
| `prev_vitamin_a` | prevention | I T C | The free Vitamin A doses (9 months to 5 years, every 6 months, under the national programme) | "vitamin A" 0. Confirm the schedule at review. |
| `prev_heat` | prevention | all | Summer: heat stroke, heat exhaustion, sun, water, and what the car does | "heat stroke" 0 |
| `ill_bites` | emergency | all | **Dog bites and rabies**: wash for 15 minutes with soap and water, the same-day vaccine and RIG, free at government hospitals under the National Rabies Control Programme. Also monkey and cat bites, plus snake and scorpion bites: what *not* to do (no tourniquet, no cutting). | "rabies" 0, "snake" 0. A real and frequent Indian emergency. |
| `ill_insect_bites` | skin | all | Mosquito and insect bites, papular urticaria, and safe repellents by age | "insect" 0 |
| `nb_boys_girls` | newborn_checks | N I | Undescended testis, hernia, hydrocele, labial adhesion, phimosis myths (don't pull the foreskin back) | "hernia" 0 |
| `ill_nosebleed` | other_illness | T C | Nosebleeds: lean forward and pinch, never back | "nosebleed" 0 |
| `ill_head_bump` | emergency | all | Head bumps and falls (bed, stairs): the signs that mean a scan | "head injury" 0; `health_accidents` touches falls |
| `vax_uwin` | vaccines | all | **U-WIN**: the government's digital vaccination record and certificate (it can create an ABHA ID), and Mission Indradhanush catch-up | "U-WIN" 0. Confirm the current scope at review; sources differ on 0 to 5 versus 0 to 17 years. |
| `rec_abha` | records | all | ABHA, the health ID, and what to keep (birth certificate, vaccination card, discharge summary) | "ABHA" 0. Papers and money owns the money side; this page owns the health side. |
| `prev_medicine_box` | medicines | all | The home medicine box, generic (§3f), with expiry and travel notes | The Baby First-Aid Kit product needs a home page |

Topics checked and **already covered**: malaria, typhoid, croup, bronchiolitis, conjunctivitis, measles, mumps, squint, poisoning, burns, and jaundice. Their depth is reviewed in the build with no new page.

Hand-offs (not Health's to write):
- tongue tie → Feeding
- bedwetting → Potty
- stammer → Development
- RBSK and DEIC early intervention for delays → Special care. Health only mentions them in `nb_screening`.

### 5c. Duplicates
- Emergency card on two tabs: fixed (§2c).
- The choking response lives in Health (`health_choking_response`) and Feeding's red flag (`safety_choking_response`). **Two texts for one emergency will drift.** Proposal: Health's page is the one source. Feeding's Safe tab reaches it via `extraPageIds`, and Feeding's copy is commented out ("kept for revert"). This is the same single-source pattern as `kPpGoNowSigns`. It is recorded in the Feeding plan too and built with whichever door goes first.
- `prev_medicine` and `fever_dosing` both say how to give medicine. Fever dosing keeps the dose-by-weight rule; prev_medicine keeps the how-to. Each links to the other, and the overlap is removed in the build.

---

## 6. The build, in order (after the user's go, and after step 0)
1. **Data, door map** (`pp_door_health.dart`):
   - `tabOrder` (4 rows)
   - tool `bands` and placements (§2c); the emergency card removed from Records (commented out)
   - the two labels (§2b)
   - `ageRail` (if H2)
   - per-tab `expert` (§3b)
   - `introVideoSlot: 'health/door_intro'`
   - fix the stale "six tabs" header
2. **Mechanisms:**
   - `PpDoorTab.ageRail` and its drawing in `pp_door_screen.dart` `_railsFor`, with area rails skipping pages already shown (H-M1)
   - the exact-band lift in `pp_relevance.dart` (H-M2; step 0 if it lands before)
   - the expert safety line (§3a)
   - the Vaccines due line (if H1)
3. **Content** (`pp_health_content.dart`):
   - the tags from §2e
   - the go-now film folded in
   - 20 new consult blocks (§3c)
   - product slots (§3f)
   - 6 new video slots
   - 17 deepened pages (§5a)
   - 15 new pages (§5b)
   - the choking single source
   - REQUIRED_REVIEW on every clinical line
4. **Experts:** 7 owed categories with invitation states (§3d).
5. **Test** (`test/pp_health_door_test.dart`, new or extended), holding:
   - the tab order per band
   - every page's tags (§2e as data)
   - the age rails
   - tool bands
   - no expert or consult on the go-now pages or the help tab (source scan)
   - no `pp_products` link to a medicine (H4, source scan)
   - the go-now list still single-sourced
6. **First-view test** (S7): Health at 3 weeks, 7 months, 2 years and 4 years. For each: opening tab = Something's wrong, the first rail's first page, and the expert row present above the first rail.
7. **Mobbin check** before the build: the age rail as a lead shelf, and a due line on a tab card.
8. **Prototype** of the 3-week and 2-year first views, approved before any `lib/` edit.

## 7. Verification
- Run:
  - `flutter test test/pp_health_door_test.dart test/pp_doors_sanity_test.dart test/pp_relevance_test.dart test/pp_doors_first_view_test.dart test/read_offer_coverage_test.dart`, plus the existing go-now list test
  - `flutter analyze` on the touched files
- **Wiring gate:** grep `ageRail`, `expert:`, `tabOrder` and the due line, each in the screen, and confirm they are read, not just declared.
- Phone walk on the user's word only: set the age to 3 weeks, 7 months, 2 years and 4 years, open Health, and check the first view against §2a and §2d.

## 8. Docs in the same change
- `DOOR-CONTENT-OWED.md`: the 7 film rows, the owed products, the owed expert roles, and the 15 new pages until written
- `PARENTING-DOORS-REVIEW.md`: the Health checklist
- `STILL-OPEN.md`: the Health rework entry, and the older-than-6 band gap
- `GLOBAL-CHANGES.md` #5 and #15: Health done
- `BEFORE-LAUNCH.md`:
  - **a paediatrician's read of every Health page**, the go-now list first (already REQUIRED_REVIEW)
  - the forehead thermometer and emollient claims check
  - the H4 no-medicine rule

## 9. Decisions (answered by the user 2026-10-23: "h1-h7 yes on all as u suggested")

Every row was recommended Yes, and the user answered Yes.

| # | Question | Your answer |
|---|---|---|
| H1 | Show "Due in N days" on the Vaccines tab card when a dose is within 14 days? | **Yes** |
| H2 | A rail for her child's age first on "Something's wrong" (§2d)? | **Yes**, prototype first. On the look: *"dont u think 2 emergency call outs are repetitive"*, then *"instead of these 2 callouts, rather have one and put the other below, not one after the other, so that the actual door content doesn't all go below"*. Changed to: emergency row on top, age shelf, then the paediatrician row. Look approved 2026-10-24: *"yes its looking fine"* (artifact v4) |
| H3 | A "Baby first aid and CPR" class card at the very end of Get help now? | **Yes, at the end only** |
| H4 | Health never sells or links to buy a medicine, supplement or ORS brand; equipment only? | **Yes** |
| H5 | Add the 7 owed specialist categories with an invitation state, so pages can point at them before real profiles exist? | **Yes** |
| H6 | Write the 15 new India pages (§5b) in full now, the way Feeding's new copy was written (`02-health-content.md`), before the build? | **Yes. Done 2026-10-23:** `02-health-content.md`. |
| H7 | Make Health's choking page the one source and point Feeding at it (§5c)? | **Yes** |

## 10. Costs
None now. The films and the paediatrician's review are owed and quoted when briefed (USD + INR). No paid API or service is used.

## Sources (India facts used in §5b; every one REQUIRED_REVIEW at build)
- National Deworming Day: [Drishti IAS](https://drishtiias.com/pdf/1581412634-national-deworming-day.pdf), [The Quint](https://www.thequint.com/amp/story/fit/national-deworming-day-in-india-2024-check-date-theme-history-significance), [Krishnagiri district (NDD scheme)](https://krishnagiri.nic.in/scheme/national-deworming-day/)
- U-WIN and Mission Indradhanush: [PIB document](https://static.pib.gov.in/WriteReadData/specificdocs/documents/2024/nov/doc2024119432301.pdf), [MoHFW press release](https://mohfw.gov.in/press-info/7848), [Business Standard](https://www.business-standard.com/india-news/pan-india-rollout-of-u-win-to-track-routine-vaccinations-likely-by-aug-end-124071400270_1.html)
- Rabies PEP: [NHM Himachal Pradesh, NRCP](https://nhm.hp.gov.in/nrcp), [The Tribune](https://www.tribuneindia.com/news/ludhiana/ivory-tower-despite-vaccines-rabies-still-kills-thousands-in-country/amp)
- Anemia Mukt Bharat IFA syrup and the Vitamin A schedule: not confirmed by a source in this pass. Fetch the MoHFW guidelines when writing those two pages.
