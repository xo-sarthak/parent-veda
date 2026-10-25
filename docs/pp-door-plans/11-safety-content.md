# Door 11: Safety, the new copy (SF1, SF3, SF5)

Written 2026-10-25. This goes into `pp_safety_content.dart` at build. The house rules are the section's own:
- Calm-day reading, never frightening.
- Steps or cards, never a wall of prose.
- One emergency list in the app (Health `health_go_now`).
- English only. No emoji.
- Every clinical, legal and first aid line is REQUIRED_REVIEW by a paediatrician (first aid against current IAP/AHA guidance). Numbers and rules are checked before release.

---

## 1. The emergency strip (SF1), at the top of every tab
> **In an emergency**
> [ Call 112 ]  [ Ambulance 108 ]  [ Poison help ]
> 112 · 108 or 102 · 1800-116-117 (AIIMS)
> **Choking: what to do now ›**  **CPR: baby or child ›**

- Each button dials through the existing `pp_crisis_path_screen.dart` path.
- The numbers are always written underneath, selectable, because a call link may do nothing on some phones.
- On First aid, the pinned "Get help now" card takes the strip's place, so there are never two callouts stacked.

## 2. Flights and seats (SF3), new parts of `safety_travel`
REQUIRED_REVIEW (airline and road rules checked before release).

**Flying with a baby or toddler**
- **How young:** most Indian airlines accept babies from about 7 to 14 days old. Ask your airline, and ask your doctor if he was premature or has a heart or breathing condition.
- **Ticket:** under 2, he usually flies on your lap on an infant ticket, at a fraction of the fare. From 2, he needs his own seat.
- **Ears:** feed, or give a dummy or water (from 6 months) during take-off and landing. Swallowing eases the pressure.
- **Papers:** his birth certificate for domestic flights (some airlines ask for it), and his own passport abroad. Link: Papers door.
- **His car seat:** many airlines allow an approved seat if he has his own ticket. It's the safest way to fly.
- **Sick or a cold:** if his ears or chest are bad, ask your doctor before flying.

**The front seat**
- **The back seat is safest until about 12,** or until the seat belt fits him properly.
- **Never a rear-facing baby seat in front of an airbag.** An airbag opening can seriously hurt a baby.
- **On a two-wheeler:** since 2022 the rule for children under 4 is a crash helmet that fits, a safety harness that ties him to the rider, and no faster than 40 km/h. A baby too small for a helmet shouldn't ride on a two-wheeler at all.

## 3. The gaps (SF5)

### Electricity, on `safety_room_by_room` and `safety_burns_home`
- **Sockets:** use socket covers, or put heavy furniture in front of sockets at his height.
- **Extension boards:** keep them off the floor, unplug chargers, and never leave a phone charger hanging from a socket near the bed.
- **After a shock:** switch off the mains first. Don't touch him while he may still be on the current; use something dry and wooden to move the wire. Then check his breathing, and call 112 if he's hurt, burnt or not himself. Every electric shock needs a doctor's check the same day.

### Cords, on `safety_tip_overs`
- Tie curtain and blind cords up high, out of his reach, or cut loops into two.
- No cot, bed or sofa under a window with a cord.
- Phone and laptop chargers are cords too.

### Mosquitoes and dengue, a new card group on `safety_heat` (renamed "Heat, sun and mosquitoes")
- **A net over the cot or bed,** tucked in, for day naps as well. Dengue mosquitoes bite in the daytime.
- **No standing water:** cover tanks and buckets, change the water in coolers and plant trays every week.
- **Repellent:**
  - under 2 months, none; use nets and clothes
  - from 2 months, a children's repellent on clothes and exposed skin, never on his hands or face
  - mosquito coils and liquid vapourisers stay out of the room where he sleeps
- **Fever in the monsoon:** call the doctor the same day for a fever that lasts over two days, or one with vomiting, belly pain, a rash, bleeding gums or unusual sleepiness. Link: Health fever.

### Choking foods, on `safety_choking_objects`
- **Add:** whole nuts, makhana (fox nuts), popcorn, whole chana, hard sweets, and jelly cubes.
- **How to serve them:**
  - grapes and cherry tomatoes cut in quarters, lengthways
  - nuts ground or as smooth butter until about 5
  - makhana crushed or soaked soft
- **Never while he's running,** lying down or crying.

### Poisons, by the names on Indian shelves, on `safety_poisons`
- Toilet cleaner (Harpic and similar), phenyl, floor cleaners, kerosene, naphthalene balls, mosquito liquid refills, camphor (kapoor), and the iron and paracetamol syrups in the medicine box.
- All of them go up high, locked away, and in their own bottles, never in a water or cold drink bottle.
- **If he's swallowed something:** don't make him vomit. Call the poison line, 1800-116-117, or go to hospital with the bottle.

### Burns, on `safety_burns_home`
- **The diya and the agarbatti** at floor level, during puja and festivals: up on a stand, never where he can crawl.
- **Hot tea and dal** are never passed over his head or held while he's on your lap.
- **First aid:** cool running water for 20 minutes. No toothpaste, ghee, ice or butter. Link: Health accidents.

### Numbers, on `safety_cpr` and `safety_first_aid_kit`
- **Add 102:** in many states, the free ambulance for pregnant women and babies.

### Heat stroke, on `safety_heat`
- **Name it:**
  - very hot, dry or flushed skin
  - floppy or very sleepy
  - fast breathing
  - fewer wet nappies
- **What to do:** move him somewhere cool, sponge him with room-temperature water, offer feeds, and call 112 if he's floppy or won't wake easily.

### `safety_motion_sickness`, written out
- **What helps:**
  - a light snack before the trip, not an empty or full tummy
  - eyes on the horizon
  - fresh air
  - a stop every hour
  - a bag and a change of clothes in reach
- **Not under 2,** and not without the doctor: travel-sickness medicines, including the ones sold over the counter.
- **Ginger:** many families use a little ginger (in food, from about 2). It's gentle, and it's fine to try.

## 4. Links (SF7)

| From | To |
|---|---|
| `safety_falls` | Health's head-injury signs page (exact id at build) |
| `safety_room_by_room` | Sleep's safe-sleep page |
| `safety_poisons` | Traditions `newborn_customs` (kajal, lead) |
| `safety_heat` (dengue) | Health fever |
| Health `:635`, Development `:2094` and `:2348`, `parenting_hubs.dart:636` | the exact Safety page each one means |

## Sources (REQUIRED_REVIEW at build)
- IAP and AHA paediatric basic life support (CPR, choking).
- Central Motor Vehicles (Second Amendment) Rules, 2022, Rule 138(7) (children under 4 on two-wheelers).
- DGCA and airline infant travel rules.
- NCVBDC (the National Center for Vector Borne Diseases Control) dengue prevention guidance, and IAP on repellents in children.
- AIIMS National Poisons Information Centre.
- WHO burns first aid.
