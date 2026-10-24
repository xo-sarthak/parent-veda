# Door 6: First 40 Days, the plan

Written 2026-10-24. **Status: final. FD1 to FD9 answered yes by the user 2026-10-24 (FD1 after the rows mockup).** The new copy is in `06-first40-content.md`. Nothing in `lib/` changes until step 0 and the user's go. Proposes shell rule S10 (red-flag pages never sink).

## Context
- **Files:** the door is `lib/data/doors/pp_door_first40.dart`. The content is `pp_first40_content.dart`: 46 pages, warm and very India-aware (jaapa, chhathi, kohl, janam ghutti, the sunlight myth).
- **Tabs, five:** Day by day · When to rush · Your recovery · Understanding your newborn · Feeding, sleep and the rest.
- **Deliberate choices this plan keeps:**
  - no red strip on the front
  - no closing "book someone" under tired-mother content
  - the mother's tab is third, not last
  - no "you missed a day"
  - no product near a red-flag page
  - the mood page is not a questionnaire and carries no paid block

What a parent meets today:
1. **The things to do are text.**
   - Cord care, first bath, malish, burping, swaddling, latch and skin-to-skin are all here as step-lists, spread over three tabs.
   - Nothing on the opening screen is a "do this today" card. Day by day opens on a daily line and an article.
2. **Only Day by day changes with age.** 41 of 46 pages look the same on day 3 and at 3 months.
3. **After the forty days.** The door stays on home (last after 3 months), opening on "The forty-day mark" with nothing pointing her onward. The master plan's "gone after 40 days" is wrong. I'll correct it.
4. **The red-flag list can stop being first.** A page she has read sinks to the end of its row (`pp_relevance.dart:175`). After one read, "Go now" is no longer the first card on When to rush. The same goes for her own warning signs on Your recovery.
5. **Links that land in the wrong place:**
   - Three "full safe sleep guide" links open the sleep *tracker*.
   - "Not yourself" opens the You, Maa door home, not its baby-blues page.
   - days_1_7 says the danger list is "on the section home", which no longer exists.
   - Both shop links open the unfiltered shop.
   - The course link opens Learn home.
6. **The course page is wrong about the course.** It says ₹1,499 (usually ₹2,999), Hindi and English, free first lesson. The real one is `mc_first40`: an 80-minute recorded masterclass, ₹1,199 ($14), "opening soon".
7. **Consults:**
   - 3 lactation consult cards (gated: they open the "experts joining" page).
   - No paediatrician anywhere, though the hub comment says jaundice has one.
   - "Not yourself" lacks the free Tele-MANAS line (14416) that You, Maa has.
8. **Products:** the swaddles, maternity pads, breast pads, thermometers, cradle, nursing pillows and peri bottles the shop *does* stock are never linked. Massage oils and a postpartum belt are not stocked.
9. **India gaps (0 hits):**
   - registering the birth (the certificate, within 21 days)
   - the birth vaccines (BCG, OPV, Hep B)
   - JSY, JSSK and PMMVY money she may be owed
   - Tele-MANAS
   - the mother's own taboos (cold water, washing hair, the belt)
10. **No birth date.** With no date of birth saved, the door says "Day 1 of 40" forever.
11. **Films:** 13 placeholder slots, and no door intro.

## FD1. "Try this today": hands-on cards first, by week
Day by day opens with the Day card (unchanged), then a shelf of **4 to 6 how-to cards for this week**, one tap each.
- **Look and rules:** the same shelf look you approved for Development and Potty. Nothing to tick.
- **Cards** (all existing pages):

| Week | Cards |
|---|---|
| Days 1–7 | Skin to skin · Latch · Cord care · Nappies: what's normal · Burping |
| Days 8–20 | First bath · Swaddle · Soothing · Day and night · Burping |
| Days 21–40 | Malish · Jhula · Soothing · Skin to skin · First bath |
| After 40 | Malish · Soothing · and a card to Development's Play today |

## FD2. The warning lists never sink
- On When to rush, "Go now" (red_flags) stays the first card, always, even after she has read it.
- On Your recovery, her own warning signs (recovery_red_flags) do the same.
- **Shell:** red-flag pages are exempt from the "read pages sink" rule in every door. This is added to step 0 as **S10**.
- days_1_7's "on the section home" becomes a real link to Go now.

## FD3. After the forty days, the door points onward
- **From day 41:** the forty-day mark page leads, as today. Above it goes one line with three links: "Your forty days are done. Carry on in Feeding, Sleep and Development."
- **From 2 months:** the door opens on **Your recovery**, because a mother's recovery runs for months. The newborn pages stay, unchanged, for a parent who wants them (no locks, S9).
- **The home tile:** it moves to last after 3 months, as now.

## FD4. Links go where they say
- **Safe sleep (×3):** the Sleep door's safe-sleep page (exact id found at build), not the tracker.
- **Not yourself:**
  - links You, Maa's `mind_blues_vs_ppd`
  - adds Tele-MANAS 14416, free, any hour (above any paid help; no paid block, as decided)
- **Forty-day mark:** links You, Maa's recovery pages, not the door home.
- **Newborn pages:** each also gets a "As he grows" link to the long-term page:
  - jaundice → Health `ill_jaundice`
  - latch → Feeding `bf_latch`
  - swaddle and malish → Sleep
  - folk_practices and ceremonies → Traditions
  - First 40 keeps its own newborn version; the other door holds the longer story.

## FD5. Things to buy, from the shelf that has them (one per page, never on a red-flag page)
| Page | Link | Stock | What a tap does |
|---|---|---|---|
| what_you_need | Swaddles, maternity pads, breast pads, a thermometer, a cradle, a peri bottle (one row each) | in stock | Shop filtered to each item |
| malish | "Massage oil" | none | A small message: "We haven't picked oils yet. Plain coconut or til oil from your kitchen is fine." |
| which_swaddle | Compare swaddles | 0 swaddles in the compare shelf | Shop filtered to muslin swaddles instead |
| rest_and_food | "A postpartum belt" | none | Message: "Not in our shop yet. Ask your doctor first after a C-section." |

## FD6. Help next to the worry
- **Paediatrician:**
  - one row on Understanding your newborn, after the first shelf ("Jaundice, cord, skin: ask a paediatrician")
  - a consult card on the jaundice page, after its doctor box
  - **When to rush stays free of any pitch.**
- **Your recovery:** one gynaecologist row after the first shelf.
- **Feeding tab:** the lactation row moves up, after the tools.
- **No closing card,** as decided.
- **Course page:**
  - rewritten to the real masterclass: 80 minutes, ₹1,199 ($14), English, opening soon
  - links by its id; the wrong price and the Hindi promise are commented out
  - while it's not open, a tap shows "This class isn't open yet", with a Tell me button that tells her when it opens

## FD7. Birth date honesty
With no date of birth saved, the Day card says "Tell us when he was born to see your day", with a button to add it. No more "Day 1 of 40" forever.

## FD8. New India content (in `06-first40-content.md`; clinical lines REQUIRED_REVIEW)
- **days_8_15** (new card), "Register the birth": free within 21 days at the municipality or panchayat, usually done by the hospital. Ask for the certificate. It's needed for the Aadhaar and school later. Link to Papers.
- **days_1_7** (new card), "His first vaccines": BCG, OPV-0 and Hep B at birth, usually before discharge. Check the card. Link to the vaccine tool.
- **rest_and_food** (new card), "Money you may be owed": JSY, JSSK and PMMVY, in one line each, with a link to Papers.
- **after_csection / rest_and_food** (new card), "The old rules for you", in myth-versus-evidence style:
  - cold water and washing hair are safe once you feel up to it
  - the belt: what it does and doesn't do, with the doctor-first line
- **not_yourself:** Tele-MANAS (FD4).

## FD9. Films (a "being made" message until made)
- The 13 slots stay.
- Add the door intro `first40/door_intro`.
- Restore `first40/recovery_basics` to Your recovery.
- All of them go in DOOR-CONTENT-OWED. The baby-care demos are reviewed by a paediatric nurse or midwife.

## FD10. Taps that can't happen yet (S8)
| Target | What she sees |
|---|---|
| 13 slots, the intro, recovery_basics | "This film is still being made. The steps are written just below." |
| Massage oil, postpartum belt | the shop messages in FD5 |
| Masterclass | "This class isn't open yet" + Tell me |
| Lactation, paediatrician, gynaecologist | the existing "experts joining" page |

## Housekeeping (no decision needed)
- Correct the stale comments: four tools, "eight times", the hub comment, the Hindi promise.
- Fix `00-MASTER.md` row 6 and the "gone after 40 days" line.

## Build order (after step 0, plus S9 and S10, and your go)
1. Red-flag pin (S10)
2. Week shelf
3. After-40 opening
4. Link fixes
5. Shop links
6. Expert rows and the course page
7. Birth-date card
8. New content
9. Films

**Reuse:**
- the D2 shelf
- `pp_din_by_din.dart` (the day logic)
- `PpDoor.tabOrder`
- M4 `PpLink.pageId`
- `PpDoorTab.expert`
- `pvToast`
- S8a–d

## Verification
- **Tests:**
  - `test/pp_first40_door_test.dart` updated:
    - week shelf per age
    - red_flags first after being read
    - opening tab after 2 months
    - no pitch on When to rush
    - no-closing assert kept
  - `door_names_fit_test`
  - `pp_doors_first_view_test`
  - `flutter analyze` on touched files only
- **Wiring gate:** grep call sites.
- A phone walk only on your word.

## Decisions
| # | Question | We recommended | Your answer |
|---|---|---|---|
| FD1 | Day by day opens with 4–6 "do this today" cards for this week (cord care, first bath, malish, burping), nothing to tick | Yes | **Yes** (2026-10-24), after seeing the rows mockup `claude.ai/artifact/2BEwbvkimGDbUpNSe987fh` (asked for: "an artifact so then i will be able to get the idea of what have we done in potty and development rows") |
| FD2 | The danger lists stay first even after she has read them, in every door (S10) | Yes | **Yes** (2026-10-24) |
| FD3 | After day 40, a line pointing on to Feeding, Sleep and Development; from 2 months the door opens on her recovery | Yes | **Yes** (2026-10-24) |
| FD4 | Fix the links that open the wrong screen, add the free mental health line, and "as he grows" links to the other doors | Yes | **Yes** (2026-10-24) |
| FD5 | Link the newborn things the shop already has; a short message for oils and the belt | Yes | **Yes** (2026-10-24) |
| FD6 | A paediatrician near jaundice and skin, a gynaecologist on her recovery, the course page corrected to the real class | Yes | **Yes** (2026-10-24) |
| FD7 | With no birth date, ask for it instead of showing "Day 1" forever | Yes | **Yes** (2026-10-24) |
| FD8 | New bits: register the birth, birth vaccines, government money she may be owed, the old rules for the mother | Yes | **Yes** (2026-10-24) |
| FD9 | A door intro film, plus the recovery film back | Yes | **Yes** (2026-10-24) |
