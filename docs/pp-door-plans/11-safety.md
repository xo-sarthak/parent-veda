# Door 11: Safety, the plan

Written 2026-10-25. **Status: final. The plan was accepted 2026-10-25, and SF1 to SF8 are chosen and recorded under the user's rule (obvious decisions aren't asked). Nothing here needed the user's call.** The new copy is in `11-safety-content.md`. Nothing in `lib/` changes until step 0 (S1 to S11) and the user's go.

## Context
**Where it lives.**
- The door: `lib/data/doors/pp_door_safety.dart`
- The content: `pp_safety_content.dart`, 29 pages, all in steps or cards, with no prose blobs

**Tabs:**
- Around the house
- Bath time and water
- On the road, and in the heat
- First aid
- My body is mine

**Kept on purpose:**
- "First aid is not triage": Health's "Get help now" stays the one emergency list in the app, and this door links to it
- the calm-day tone
- the room-by-room checklist
- the AIIMS poison line and Childline 1098

### What parents actually ask
From `research/questions/ranked_parenting.csv`:

| Topic | Hits | Top questions | What it means |
|---|---|---|---|
| Travel: flights, car seats, front seat | 193 | can a 3-month-old fly; does a 1-year-old need a ticket; can a 5-year-old sit in front | **The biggest need.** The travel page is short on flights and seats |
| Head bumps, falls | 51 | do toddlers hit their head | Falls page exists. The "what to watch for after a bump" part sits in Health; link it |
| Swallowed something | ~20 | — | Covered (poisons, batteries, magnets) |
| Choking, burns, drowning, CPR, babyproofing | 0–16 each | — | **Barely searched before an accident.** Parents search after it, in panic, which is Health's job |

So this door's job is prevention, and the hard moment. It doesn't need more reading. It needs the emergency within one tap, the right pages for his age, and the travel questions answered.

### What a parent meets today
1. **No emergency action up front.** The only one is a grey line on the 4th tab: "In an emergency, call 112". Every number is plain text with no call button, though the app has tap-to-call code (`pp_crisis_path_screen.dart:96`, `TtcDoorCallButton`). Ambulance 102 isn't mentioned.
2. **CPR is text only.** `safety_cpr` has both halves, under 1 and over 1, but always shows the baby half first. (The first audit said the child half was missing. A read of the page showed it's there, corrected 2026-10-25.) There are no pictures, films or images anywhere in the door, and no hero photo.
3. **Every page shows at every age** (26 of 29 untagged).
   - A 4-year-old's parent sees baby bath rings, nappy-change falls and infant CPR first.
   - A newborn's parent sees school vans, bunk beds and kites.
   - The motion-sickness page says "from about two" but shows from 1.
4. **Gaps:**
   - electric shock and open sockets (1 mention)
   - curtain and blind cords as a strangling risk (0)
   - mosquitoes and dengue (0)
   - makhana and whole nuts (0)
   - toilet cleaner by its common name
   - the diya
   - flights with a baby
   - the front seat
5. **Shop and classes:**
   - 21 car seats in stock, and none linked.
   - The shop has no gates, socket covers, corner guards, cabinet locks or child helmets.
   - A class exists, "Baby-proofing for joint families" (`mc_babyproof`), and nothing links it.
   - No first aid or CPR class exists.
6. **Help:** the "Talk to a paediatrician" closing is never drawn (S3).
7. **Links:**
   - nothing to Sleep's safe sleep, or to Traditions' unsafe customs (kajal and lead)
   - four links from other doors into Safety land on the whole section
8. **Names:**
   - "On the road, and in the heat" (28) is too long for two lines.
   - "Thin" is only motion sickness (about 600 characters).

## SF1. The emergency, one tap from every tab
- **A small "In an emergency" strip at the top of every tab** replaces the grey note. It shows:
  - **Call 112** · **Ambulance 108 / 102** · **Poison help 1800-116-117**
  - each as a tap-to-call button, reusing `pp_crisis_path_screen.dart`'s dial
  - the number written next to it, since a call link may do nothing on some phones
- **Under it, two cards:** "Choking: what to do now" (Health `health_choking_response`) and "CPR: baby or child" (`safety_cpr`).
- **"Get help now" (Health `health_go_now`) is pinned on First aid**, the way Health pins it. It's still one emergency list in the app.
- The strip and the pinned card never sit stacked as two callouts (rule c). On First aid, the pin takes the strip's place.

## SF2. The right pages for his age
**Tag every page** (S2):
- **Under 1:** bath ring and tub, nappy-change falls, walkers
- **1 and up:** tip-overs, poisons, small things, cords, sockets
- **3 and up:** crowds, road sense, bunk beds, kites and rooftops, screens online
- **Every age:** burns, heat, sun, car seat, hot car, travel, first aid kit, minor injuries, bites
- **Motion sickness:** from 2, as its own words say

**Tab order by age:**

| Age | Order |
|---|---|
| 0–12 months | Around the house, First aid, Bath and water, Travel and heat, My body |
| 1–3 years | Around the house, Bath and water, First aid, Travel and heat, My body |
| 3–6 years | Travel and heat (road sense, crowds), My body, Around the house, Bath and water, First aid |

**CPR shows the right half first for his age.** The page already has "For a baby under one" and "For a child over one". From 1 year, the child half comes first and the baby half follows. No new CPR copy.

## SF3. Travel, the top question
`safety_travel` gets a part on **flights**:
- the age most airlines allow and what to ask your doctor
- a ticket or lap seat under 2
- feeding or a dummy at take-off and landing for the ears
- the documents
- the car seat on board

**A "front seat" part:**
- back seat until about 12
- never a rear-facing seat in front of an airbag
- **two-wheelers:** the 2022 rule for children under 4 (helmet, a harness to the rider, 40 km/h)

REQUIRED_REVIEW (rules checked before release). The tab is renamed "Travel and heat".

## SF4. Pictures and films where words aren't enough
- **Three film slots:**
  - baby CPR
  - child CPR
  - choking, which links Health's existing slot so it isn't repeated
- **The door intro:** `safety/door_intro`
- These films are real people, per the video plan rules: first aid has to be demonstrated, not animated. Until each one exists, a tap says "This film is still being made. The steps below work now" (S8a).
- **Line drawings for CPR and choking** (where the hands go, the back blows) go on the illustration list. Until they exist, the steps stay as numbered text.
- **A hero photo** (Unsplash, free): a toddler at a safety gate, or a parent holding a child's hand on a pavement. Nothing on it a page argues with.

## SF5. The gaps, written in (copy in `11-safety-content.md`; REQUIRED_REVIEW)
- **Electric safety:**
  - socket covers, or furniture in front
  - extension boards off the floor
  - what to do after a shock: switch off first, never touch him while he's still on the current
- **Cords:** curtain and blind cords tied up high, and no cot near a window cord.
- **Mosquitoes and dengue:**
  - a net over the cot
  - covered water containers
  - repellent: what's safe at which age
  - **the fever signs to call about**, linked to Health
- **Choking foods:** whole nuts and makhana join grapes, peanuts and chana. Plus how to cut each one.
- **Poisons, by the names on Indian shelves:** toilet cleaner (Harpic), phenyl, kerosene, naphthalene balls, mosquito liquid, camphor.
- **Burns:** the diya at floor level, and hot tea passed over a child's head.
- **Ambulance 102** is added to the numbers, free in many states for mothers and babies.
- **Heat stroke** is named on the heat page.
- **Motion sickness** is written out.

## SF6. Things to buy, and a class
- **Car seats:** linked on `safety_car_seat`, the 21 in stock, filtered by age.
- **Owed to the shop list:** baby gates, socket covers, corner guards, cabinet locks and child helmets, with a dated note. Until then, the pages say what to look for, with no dead link.
- **"Baby-proofing for joint families" (`mc_babyproof`)** linked on `safety_room_by_room` by its id, with the real price in INR and USD, and "Tell me" if it isn't open yet.
- **Owed:** a first aid and CPR class. It is the class this door most needs, and none exists.

## SF7. Links and help
- **The closing "Talk to a paediatrician"** is drawn (S3). Experts aren't live, so a tap opens "experts joining" (S8e).
- **New links:**
  - `safety_falls` → Health's head-injury signs
  - `safety_room_by_room` → Sleep's safe sleep
  - `safety_poisons` → Traditions `newborn_customs` (kajal and lead)
  - dengue → Health fever
- **The four whole-section links into Safety** (Health `:635`, Development `:2094` and `:2348`, `parenting_hubs.dart:636`) go to the exact page.

## SF8. Names and a test that holds the emergency
- "On the road, and in the heat" → "Travel and heat". The old label stays commented out.
- **A new door test** that fails if:
  - any tab loses the emergency strip
  - 112, 108 and the poison line go missing
  - the call buttons aren't wired (grep the dial call)
  - CPR loses either half

## Taps that can't happen yet (S8)

| Target | What she sees |
|---|---|
| CPR, choking and intro films | "still being made; the steps below work now" |
| Paediatrician | the "experts joining" page |
| Babyproofing class, if not open | "Tell me" |
| A call button on a phone that can't dial | the number stays written next to it, ready to copy |

## Build order (after step 0 and your go)
1. Emergency strip and pin
2. Tags, tab order and the CPR split
3. Travel
4. Gaps
5. Shop and class
6. Links and closing
7. Films, drawings and hero
8. Names and test

**Reuse:**
- `pp_crisis_path_screen.dart` dial
- `kEmergencyNumber` and `kAmbulanceNumber` (`mind_mood_data.dart:109,117`)
- Health's `redFlagPageId` pattern
- the S1 tab order
- M4 `PpLink.pageId`
- `pvToast` S8a/e

## Verification
- **A new `test/pp_safety_door_test.dart`:**
  - the strip is on every tab
  - the numbers are present
  - the dial is wired
  - the first tab and first page at each age
  - no under-1 page first for a 3–6 child
  - CPR has both halves, and the child half comes first from 1 year
- `pp_gap_doors_test`
- `door_names_fit_test`
- `pp_tile_order_test`
- `flutter analyze` on touched files
- grep call sites
- a phone walk only on your word, to check a call button really opens the dialer

## Decisions
These stay here on purpose. When a problem turns up later, check this table first: if an answer covers it, the fix follows that answer.


| # | Decision | Why (what parents want) | Answer |
|---|---|---|---|
| SF1 | Emergency strip with call buttons on every tab; Get help now pinned on First aid | In the bad moment nobody reads; one tap must do it | **Yes**, chosen and recorded (2026-10-25) |
| SF2 | Pages tagged by age; tab order by age; CPR for baby and child | A 4-year-old's parent reads the baby steps first today | **Yes**, chosen and recorded (2026-10-25) |
| SF3 | Flights, front seat, two-wheeler rule | Travel is the top safety question (193) | **Yes**, chosen and recorded (2026-10-25) |
| SF4 | CPR and choking films (real people), drawings owed, hero photo | First aid must be seen, not just read | **Yes**, chosen and recorded (2026-10-25) |
| SF5 | Shocks, cords, dengue, makhana, Indian poison names, 102, heat stroke | Real hazards in Indian homes with 0 lines today | **Yes**, chosen and recorded (2026-10-25) |
| SF6 | Car seats linked; babyproofing class linked; missing stock and a CPR class owed | Things that exist get used; things that don't get listed | **Yes**, chosen and recorded (2026-10-25) |
| SF7 | Closing drawn; cross-door links | Plain fixes | **Yes**, chosen and recorded (2026-10-25) |
| SF8 | "Travel and heat"; a test that guards the emergency | A safety line must never silently disappear | **Yes**, chosen and recorded (2026-10-25) |

## As built (2026-10-26)
Held by `test/pp_safety_door_test.dart` (16 tests): the strip on every tab at 3, 18, 30 and 48 months, with all three call buttons, the numbers written out, the pin on First aid only and the heading everywhere else (one callout, never two); each button dialling its own number (the dial swapped in the test); the dial wired in the source; no emergency number typed in the door or its content (the four constants only); every page's age, and none outside its area's; the tab order per band; the first view at 3 and 48 months, and no baby page leading a four-year-old's tab; CPR's two halves in the right order at 6, 18 and 48 months; flights and the front seat, with the two-wheeler rule agreeing with the car seat page; the gaps; heat stroke, dengue and choking linked to Health's pages, not rewritten; the two CPR films and a film's tap; the one shop link, exactly, and stocked; the guide, the babyproofing class and the CPR class; every link landing, the four whole-door links now naming a page; the closing; the tab names. `door_names_fit_test` measures "Travel and heat" (fits at 1.0 and 1.3; off `_kOwedShorterNames`). The parenting stage (`test/pp_*`, `post_pregnancy*`, `phases_test`, `door_names_fit_test`: 129 files, 1,416 tests) passes, and so do the ten tests outside it that read the dial, the constants or the reader (172 tests).

**The shell, new for this door and open to every door:**
- **`PpDoor.emergency`** (`PpDoorEmergency`, `pp_door_data.dart`): a strip drawn by the shared door screen at the top of every tab, above a tab-for-later's line too, at every age. It has the buttons (`PpDoorCall`), the numbers line (`SelectableText`, for a phone that cannot dial), rows to the steps (`PpDoorEmergencyLink`), and an optional pin (`PpDoorEmergencyPin`) that leads the same block on one tab in place of the "In an emergency" heading. A row to a page the tab already shows on its rails is not drawn on that tab (the CPR row on First aid). A door that sets nothing draws nothing, so doors 1 to 10 are unchanged.
- **`ppDialNumber`** (`pp_crisis_path_screen.dart`): the crisis path's own `_dial`, lifted out as the one parenting dial; the crisis screen now calls it. The strip calls it through `ppDoorDial`, a test seam. `TtcDoorCallButton` was not reused: it is a TTC widget (its ink is `ttcTitleInk`), it draws two full-width pills, and the parenting shell deliberately imports nothing from another stage's door engine (the header of `pp_door_data.dart`). The dial is the shared part; the pill is drawn in the strip.
- **`PpPage.ageLead`** (`PpAgeLead`, `pp_content.dart`): from an age on the active child's clock, `orderedBlocks` moves one headed step group to where the first headed step group stood. The authored list is untouched.
- **Two constants** (`mind_mood_data.dart`, beside 112 and 108): `kMotherBabyAmbulanceNumber` (102) and `kPoisonsHelplineNumber` (AIIMS), both REQUIRED_TO_CONFIRM.

**What was built, by decision:**
- **SF1.** The strip: Call 112 (filled), Ambulance 108 and Poison help (outlined), "Emergency 112 · Ambulance 108 or 102 · Poison line 1800-116-117 (AIIMS)", then "Choking: what to do now" (Health's `health_choking_response`) and "CPR: baby or child". On First aid, "Get help now" (Health's `health_go_now`) leads the block; the grey note is commented out, kept for revert.
- **SF2.** Six pages tagged (table below); the tab order per band as the plan's table; CPR's child half first from 12 months.
- **SF3.** "Flying with a baby or toddler" (six cards, links to Papers' birth certificate and passport pages) and "The front seat" (three cards, link to the car seat page) on `safety_travel`. The old "By plane" card is commented out.
- **SF4.** Two CPR films on `safety_cpr`: the baby one is Health's slot `health/infant_cpr` (the same film, the same title), the child one `safety/child_cpr`; choking links Health's page and its film. Hero photo: Unsplash, free (ONUR KURT), a toddler walking on a pavement holding an adult's hand, checked by eye. No intro film slotted (S4).
- **SF5.** Sockets, boards, chargers and gates on room by room; "After an electric shock" on burns; cords and loops on tip-overs; makhana, whole nuts and jelly cubes on small things; the poisons by the names on Indian shelves; the diya at puja and hot tea over a child's head; 102 on the first aid kit; motion sickness written out (about 600 to 1,090 characters). Every number in the content now reads its constant.
- **SF6.** The car seat guide (`pp_buying_guides/car_seat`) and the one stocked shelf (`pp_products/pvs_rear_facing_car_seats`) on the car seat page; "Baby-proofing for joint families" (`pp_learn/mc_babyproof`) on room by room; the first aid and CPR class as First aid's closing.
- **SF7.** The closing card "Talk to a paediatrician" was already drawn by the shell since step 0 (S3); its tap opens "Our first experts are joining". Falls link Health's `ill_head_bump`, room by room Sleep's `sleep_surface`, poisons Traditions' `newborn_customs`, heat Health's `ill_dengue`. Health's two and Development's two whole-door links now open `safety_room_by_room` or `safety_falls`.
- **SF8.** "Travel and heat", the old label commented out; the test above.

**Ages (SF2), as built:**
| Page | Plan | Built |
|---|---|---|
| `safety_walkers` | under 1 | under 1 (was 0 to 2) |
| `safety_bath` | under 1 | under 1 |
| `safety_motion_sickness` | from 2 | from 2 (was from 1) |
| `safety_crowds` | from 3 | from 3 |
| `safety_road_sense` | from 3 | **from 1** |
| `safety_screens_online` | from 3 | **from 2**, as it was |
| `safety_tip_overs`, `safety_poisons`, `safety_choking_objects` | from 1 | **every age** |
| `safety_bunk_quake`, `safety_festivals` | from 3 | **every age** |
| the rest | every age | every age |

**A mechanism worth keeping: a Wrap wraps between its children, never inside one.** The call pills sat in a `Wrap` so they would flow to a second line on a small phone, and at 360 points and 1.5x text one pill still ran 21 points off the card. A `Row(mainAxisSize: min)` reports its whole label as its minimum width; the Wrap can move it to a new run but cannot make it narrower than that. The label inside each pill is `Flexible` now, so it wraps inside the pill. The shell-wide overflow tests (`pp_door_ttc_format_test`, `pp_doors_first_view_test`) caught it, not this door's test, which runs wide.

**A second one: two gates, two meanings of "lands".** A page link to the CPR class (`pp_class/...`) passes the door's own rule (the router answers it with "Tell me" before any screen) and fails `pp_gap_doors_test`, which asks every page link for a screen. Health met the same thing and put the class on Get help now as the tab's closing, which asks the router's notice first. So the class is First aid's closing here too, and the page link is commented out. The general point: when two checks guard the same link with different definitions of success, the link belongs where both definitions hold, not where one can be argued around.

**And a trade-off, named.** CPR's order could have been two pages (baby first, child first) or one page with a rule. Two pages are twins that drift, and every link to "the CPR page" would have to pick one. The rule costs something too: the same page reads in a different order for two parents, and anything that reads `orderedBlocks` (the reader, the Ask Veda corpus export) gets the active child's order. The words are identical either way, so for search it is harmless; for a reviewer it means the authored list (`blocks`) is the one to read.

**Differences from the plan, and why:**
| Plan | Built | Why |
|---|---|---|
| SF2: tip-overs, poisons, small things "1 and up" | Every age | Mouthing and swallowing peak in the second half of the first year, and pulling up on furniture starts about nine months. The app's own 3- and 9-month tips (`m3_mouthing`, `m9_coins`, `m9_furniture`) open these pages. Tagged 1+, a nine-month-old's parent would meet them under "1 to 2 years" |
| SF2: bunk beds, kites and rooftops "3 and up" | Every age | Each sits on a mixed page: the bunk bed cards share a page with the earthquake plan and the emergency bag ("your baby held close"), the kites with Diwali and Holi; Traditions' baby's-first-festivals page links the festivals page |
| SF2: road sense "3 and up" | From 1 | Reversing cars and the lane outside the gate are a walking toddler's risk; the year-two tip (`y2_road`) opens this page |
| SF2: screens online "3 and up" | From 2, unchanged | The page's own when line speaks to "two to five" |
| SF1: buttons through `TtcDoorCallButton` | The crisis path's dial, lifted to `ppDialNumber`; pills drawn in the strip | See the shell above: TTC styling, two full-width pills, and no cross-stage import |
| SF1: "On First aid, the pin takes the strip's place" | The pin takes the strip's heading; the buttons and numbers stay under it | First aid is where the numbers matter most. One block, never two stacked |
| SF4: a third film slot for choking | Linked, not slotted | Health's `health_choking_response` holds the film (`feeding/back_blows_demo`); a slot here would be one film twice |
| SF5: mosquitoes and dengue as a new card group, page renamed "Heat, sun and mosquitoes" | A link to Health's `ill_dengue`; the page keeps its name | Health's page already has the nets, the standing water, repellents by age and the fever signs (single source, the user's brief) |
| SF5: heat stroke "named on the heat page" | A link titled "Heat stroke: the signs, and what to do" to Health's `prev_heat` | The same: Health's page owns the signs and what to do |
| SF5: "how to cut each one" | Makhana, nuts and jelly cubes added to the list; the cutting stays on Feeding's page, already linked | Feeding's `safety_choking` owns the shapes (grapes quartered, nuts ground) |
| SF5: 102 on `safety_cpr` | On the first aid kit and in the strip, not in the CPR callout | The CPR callout is the one block read with hands full; the strip above it on every tab already shows 102 |
| SF5 copy: "he", "him" | "your child", "your baby" | The section's own voice |
| SF6: the babyproofing class "with the real price in INR and USD" | The link opens the course's page, which carries the price | Prices are server-side (every door so far); an unpublished course says "Tell me" |
| SF6: the CPR class "owed" | Owed, and drawn as First aid's closing ("Tell me") | Health's Get help now already ends on the same class; one class, two ways in. The mechanism above |
| SF6: car seats "filtered by age" | The guide, and the rear-facing shelf for the first years | The shop holds rear-facing seats only (SFO2) |
| SF7: `parenting_hubs.dart:636` to an exact page | Unchanged | It is the home tile's one need, and it opens the door itself, which is right |
| SF4: line drawings | Owed (SFO4); the steps stay numbered text | As the plan says |
| Verification: a phone walk | Not run | Only on the user's word; on `BEFORE-LAUNCH.md` as a CHECK |

**Owed, not in this build:** the child CPR film and the intro (`DOOR-CONTENT-OWED` SFO1; the baby film is HD4), the shop's gates, socket covers, corner guards, cabinet locks, child helmets and older children's seats (SFO2), the first aid and CPR class (SFO3, HD9), the drawings (SFO4). On `BEFORE-LAUNCH.md`: a paediatrician's read of every new line, the CPR page read by a certified paediatric CPR and first aid instructor against IAP and AHA, the airline and road rules, the two new numbers; and a phone check that a call button opens the dialler. The new parts reach Ask Veda through the incremental ingest, which the user runs after all the doors.
