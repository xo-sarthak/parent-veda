# Door 6: First 40 Days, the plan

Written 2026-10-24. **Status: built 2026-10-25** (§12). FD1 to FD9 answered yes by the user 2026-10-24 (FD1 after the rows mockup). The new copy is in `06-first40-content.md`. Proposed shell rule S10 (red-flag pages never sink).

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

### What parents actually ask (the demand re-check, 2026-10-25)
From `research/questions/ranked_parenting.csv`. FD1 to FD10 stand. Three additions.

| Question | Hits | Where it is answered |
|---|---|---|
| why 40 days after delivery | 164 | answered (the forty days, explained) |
| when can a newborn see; can newborns see colour | 69 | **No page.** FD11 |
| which baby massage oil is good | 65 (491 across the pool) | `f40_which_oil`, made the one source (FD12) |
| why newborns get jaundice; how it's treated | 40 | the jaundice pages |
| how many newborn clothes | 20 | a shop question |
| newborn poop | see Potty PT11 | `f40_nappy_poop`, widened (§R1) |

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
| FD11 | A "What he can see" card on Day by day | "When can a newborn see" (55) and "can newborns see colour" (14) have no page anywhere | **Yes**, chosen and recorded. Copy in `06-first40-content.md` §R2. Added by the demand re-check, 2026-10-25 |
| FD12 | `f40_which_oil` is the one source for the oil; its mustard row and the FD5 toast match Traditions TR3 | Three doors would have given three answers to a top question | **Yes**, chosen and recorded. Copy in §R3. Added by the demand re-check, 2026-10-25 |
| FD13 | `f40_nappy_poop` widened to 0–12 months, linked from Potty and Health | Potty PT11, Health H8 | **Yes**, chosen and recorded. Copy in §R1. Added by the demand re-check, 2026-10-25 |

## 12. As built (2026-10-25)
Held by `test/pp_first40_door_test.dart` ("door 6: the plan, held", 11 new tests, 20 in the file): the week shelf for every day range and after forty (real pages, 4 to 6 a week, names whole), the shelf on Day by day and nowhere else, both warning lists pinned and Go now still first after it has been read (rendered), Your recovery opening from two months, the after-forty line and its three doors, the birthday ask with no child saved (no "OF 40", the pages still readable), every FD4 link landing, no safe-sleep link on the tracker, Tele-MANAS and no paid block on the mood page, the six shop rows and that the stocked ones are stocked, the two honest notices word for word, no unfiltered shop or Learn home anywhere in the section, no product near a red-flag page, the three expert rows and none on When to rush, no consult on any When to rush page, the jaundice consult, the course page against `mc_first40`, and every FD8 / FD11 / R1 / R3 change with its `REQUIRED_REVIEW` marker in the source.

**The shell: nothing new in the shared door screen.** Everything for this door lives in its own files:
- `PpFirst40TodayShelf` (`doors/pp_door_inline_tools.dart`), the inline tool `pp_f40_today` on Day by day. It holds three states: no birthday saved (the FD7 ask), the week's how-tos (FD1, the D2 card look, shared `_ShelfCard`), and after day 40 the FD3 line above the shelf, with Play today as the shelf's last card.
- `pp_din_by_din.dart`: `ppDinKnown` (a real child is saved), `ppDinAfter`, `kPpDinOnward`, and the two cards. `ppDinToday` returns null with no birthday, so "Day 1 of 40" no longer shows for ever.
- `showAddChildForm` (`multichild_sheet.dart`): the switcher's add-a-child form, opened straight from the door. It no longer pops the screen behind it when it is not inside the switcher (it would have closed the door).
- The router's `kPpShelfNotYet` gains Baby massage oils and Postpartum belts.

**A mechanism worth keeping.** S10 was built at step 0 as "format is `RED FLAG` or `FLAGGED`, or the page is pinned". First 40's two lists are `FLAGGED QUICK-REFERENCE`, so neither was covered, and Go now still sank after one read. An exact match on a free-text label quietly misses its variants (there are six spellings of a flag format across the parenting content). The fix is the clause that was built for this: both pages are `pinned`, which the shell already reads as "lead the rail, read or not". Widening the format match instead would have reordered every door that uses `FLAGGED CALLOUT`, including four already built.

**Differences from the plan, and why:**
| Plan | Built | Why |
|---|---|---|
| FD2: "Go now stays first ... her own warning signs do the same" | Both pinned. Her warning signs now lead Your recovery on the first view too (they were fifth) | A pinned page leads its rail; that is what "stays the first card, always" asks for |
| FD7: the ask in the Day card's place | In Day by day's own block, under the tab's note | The shared door screen holds another terminal's open edit (the door intro chip); keeping First 40's logic in its own two files means one commit never carries the other's work. The button opens the add-a-child form (name and birthday): with no child saved there is no profile to edit |
| FD3: "one line with three links" | A card, the line and three door buttons, above Try this today | Three tappable names in a sentence are small targets; the buttons are the same words |
| FD4: the forty-day mark "links You, Maa's recovery pages" | `pp_section/parenting_maternal/your_body`, You, Maa's Body tab | The tab that holds the recovery pages, not one page of them |
| FD5: a thermometer to the stocked shelf | `pp_products/Underarm thermometers`, which says "we haven't picked one yet. Any digital one with a flexible tip works" | The stocked shelf is infrared forehead thermometers, and Health's own page says a digital underarm reading for a newborn. Linking the shelf would contradict the Health door |
| FD5: "a cradle" | The Smart Cribs and Bassinets shelf | The only shelf with a cradle in it. Most of it is smart bassinets; a plain cradle shelf is owed (FF16) |
| FD6: the class "opening soon", a tap shows "This class isn't open yet" + Tell me | The link opens the class's own page (`pp_learn/mc_first40`); the copy gives the price and length, not "opening soon" | In the data the class is a finished recording with a "Buy recorded" button, not opening soon. The page says what it is; a Tell me notice would have been untrue |
| FD6: "When to rush stays free of any pitch" | Also: the lactation consult on "When to start logging properly" (on When to rush) is commented out, kept for revert | Found on the way. The lactation expert is the feeding tab's row now |
| FD8: "The old rules for you" on `after_csection` and `rest_and_food` | On `rest_and_food` only, as a myth carousel | `after_csection` is a window into You, Maa's C-section page and has no blocks of its own. A carousel of four myths mid-page has a precedent (Health's `fever_bringing_down`) |
| FD8 copy "his card", "he was born" | "your baby" | The voice of the pages the cards sit on |
| FD9: restore `first40/recovery_basics` | Slotted on `rest_and_food`, after its intro | Its old page, the bleeding page, is a window into You, Maa now |
| FD9: door intro `first40/door_intro` | Not slotted | S4: no chip until a film exists (GLOBAL-CHANGES #5). Owed FF12 |
| FD11: a Day by day card "What he can see" | A page, "What your baby can see", on the Day by day rail, first-month and forty-day bands | The plan's "card" is a page of the area; the shelf is for how-tos |
| R1 / FD13: "tagged 0 to 12 months" | No tag change: the page had no bands, which in this section is every band | The widening is the copy (the new part, its doctor box, the diarrhoea link). Potty's and Health's pointer pages already open it |
| R3: Traditions TR3 links "Which massage oil?" | Not here | Door 10's build |
| Housekeeping: "eight times" | Not found in First 40's files | The phrase is CLAUDE.md's `.en` / `.now` note. The four-tools header, the hub's jaundice comment and the course's Hindi promise are corrected |
| Verification: a Mobbin check | Not run | The shelf is the approved D2 look, seen on the rows mockup before FD1 was answered |

**Owed, not in this build:** the films (FF12 to FF14) and the shelf paintings (FF18), the oil, the belt and a plain cradle on the shop (FF15 to FF17), Traditions' link to the one oil page (door 10), and a paediatrician's, gynaecologist's and lawyer's read of every `REQUIRED_REVIEW` line, the scheme lines against the current government pages first (`BEFORE-LAUNCH.md`). The new page and the new copy reach Ask Veda through the incremental ingest, which the user runs.

**Final review, item 4 (2026-10-27): one figure per fact.** Fever under three months is go-now (4b); too cold is below 36.5 C / 97.7 F (4c); the Health jaundice link is retitled "Newborn jaundice, in the Health door" (4d); "the six-week vaccines" (4e); the room is 20 to 24 C for sleep, warmer while awake, with the reason (4f); the jhula follows Sleep's rule, rock then move to a flat surface, on all three lines (4g). Held by `test/pp_one_figure_test.dart`; the figures are on the BEFORE-LAUNCH clinical read.

**Final review, item 5 (2026-10-27): pages written twice.** `f40_small_or_early`'s "If your baby went to the NICU" opens `sc_nicu` (was `sc_preemie_home`, which repeated this page), and a second link opens the cut-down eye checks and corrected age page.

**Final review, item 6 (2026-10-27): no link opens a whole door.** `f40_days_8_15` opens `pm_birth_certificate` and `f40_rest_and_food` opens `pm_schemes` (both were the whole Papers door); `f40_red_flags`'s "Not an emergency, but you're not sure" opens the lactation experts (was the whole roster). Held across every door by `test/pp_no_whole_door_links_test.dart`.
