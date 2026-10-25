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
