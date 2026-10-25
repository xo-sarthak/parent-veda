# Door 5: Potty, the plan

Written 2026-10-24. **Status: final. PT1 to PT8 and PT10 answered by the user 2026-10-24 (PT5 and PT6 after plain-words re-asks; PT10 raised by the user).** The new copy is in `05-potty-content.md`. Nothing in `lib/` changes until step 0 and the user's go. Shell rule S8 (no silent tap) is in `00-MASTER.md`; this plan proposes S9.

## Context
Potty is an action door, but it opens like a lecture.
- **Files:** the door is `lib/data/doors/pp_door_potty.dart`. The content is `lib/screens/post_pregnancy/pp_potty_content.dart`: 27 pages, mostly deep and warm, India-aware (su-su, the Indian toilet, grandmothers).
- **Age bands** (`kPpPottyBands`): only three, 0–12 months, 1–3 years and 3–6 years.
- **A rule we keep:** the door file deliberately has "no tools, no quiz, no star charts", and the app keeps no streak or "days dry" number. **This plan keeps all of that.** Doing something is not the same as keeping score.

What a parent meets today:
1. **Every age opens on "How long this takes"**, one chart card. A baby's parent, a 2-year-old's and a 5-year-old's all land on the same timeline.
2. **One band covers 12 to 36 months.** A 13-month-old sees the 3-day method and "starting out, day by day", while pages say "from about 18 months" and "usually over two and a half". The 3–6 band shows "Bedwetting at five and older" to a 3-year-old.
3. **The things to do are buried.** The only 3 activities (routine_chart, sit_and_read, teach_the_toy) are the last area of the third tab, and fold away after 3.
4. **The paediatrician never shows.** The closing card isn't drawn (S3). Only 3 of 12 doctor-flag pages carry a consult.
5. **Every shop and course link is a dead end:**
   - 4 `pp_products` links open the unfiltered shop, which has 0 potty items. It has 1 mattress protector and 5 dry sheets.
   - `pp_product_guide` has no potty guide.
   - The "Short potty masterclass", described as paid, doesn't exist (`pp_courses` opens Learn home).
6. **8 film slots are all placeholders, and the door has no intro film.** The ledger (`DOOR-CONTENT-OWED.md:260-265`) is stale: it lists PT1–PT4 as owed though they were written 2026-10-02, and counts "seven films".
7. **Safety gaps:**
   - night_dryness has no doctor callout and no link to the bedwetting page.
   - indian_toilet's warning about constipation while travelling is a plain callout.
8. **Thin or repeated content:**
   - pull_ups is thin (~570 characters).
   - The no-stars message repeats 4 times, and the dry-nights timeline twice.
   - what_is_su_su says "Read next" in plain text instead of a link.
   - regressions links to the whole Behaviour door.
9. **Good things that aren't linked:**
   - the parents' room `potty` (`community_data.dart:855`)
   - 9 potty picture books (`kids_books_list.dart:254-285`)
10. **India gaps (grep, 0 hits):**
    - health faucet and lota (bucket and mug are there)
    - nursery admission ("is he toilet trained?")
    - the words enuresis and encopresis (the soiling idea is there as "leaks")
    - what a bedwetting alarm and medicine actually are
    - pinworms
11. **Home links land on a locked tab.** Home deep links to Starting out (`pp_home_v3.dart:1469`), which is locked "From 1 year" for a baby. A later-age tab cannot be opened at all, though parents read ahead and potty stage follows age loosely.

## PT1. Opening tab by stage (`PpDoor.tabOrder`)
| Band | Tab order |
|---|---|
| 0–12 months | Catching the wee early, How long this takes, then Starting out, Accidents and Dry nights ("for later") |
| 1–2 years | Starting out (readiness first), How long, Accidents, then Dry nights ("for later") |
| 2–3 years | Starting out (day by day first), Accidents, How long, then Dry nights ("for later") |
| 3–6 years | Accidents and going backwards, Dry nights, Starting out, How long |

The honest timeline stays one tab away. It reassures, but it's no longer the front door.

## PT2. Bands that match potty stages
| Band | Was | Now |
|---|---|---|
| 0–12 months | 0–12 months | unchanged |
| 1–2 years ("Getting ready") | 1–3 years | new split |
| 2–3 years ("Learning") | 1–3 years | new split |
| 3–4 years | 3–6 years | new split |
| 4–6 years | 3–6 years | new split |

Pages get their own bands where the text already names an age:
- three_day_method: 2 years and up
- bedwetting: 4–6 years
- taking_longer: 3 years and up

**Check at build:** grep whether any band id is persisted (read history, deep links), and keep the old ids where one is.

## PT3. "Try this today": the activities are the first thing on screen
- **The shelf:** an inline shelf at the top of the opening tab, with **4 to 6 activity cards for his stage**, one tap each.
- **Cards and look:** each card shows a picture and the time ("5 min"). It uses the Development shelf you approved (D2: same widget, `kPvDoorSelfPaddedTools`), so I don't plan a new mockup.
- **No scoring:** no ticking, no counts, no "done" state. A fresh pick each day, seeded by date.
- **Content:** the 3 existing activities, plus new ones written in `05-potty-content.md`:
  - **0–12 months:** "Cue at waking" (hold over the potty after a nap, make the su-su sound); "Nappy-off time on the floor"; "Say it as it happens" (name the wee and poo you see).
  - **1–2 years:** "Let him choose the potty"; "Pants down, pants up" (dressing practice); "Flush and wave bye-bye"; "Say it as it happens".
  - **2–3 years:** "The after-waking sit" (daily_routine as an activity); "Wash at the low tap" (hands, with a mug and a stool); "Big-kid pants day"; "The picture routine" (routine_chart); "A book on the potty" (sit_and_read); "Teach the toy" (teach_the_toy, which says "from about 2.5 years").
  - **3–6 years:** "Wiping practice with a doll"; "Last wee before bed, together"; "Public toilet practice run"; "Pack the spare-clothes bag together".
- **On the 3–6 opening tab** (Accidents), the shelf leads with the calm-reset activities, then the pages.

## PT4. Things to buy, next to the step that needs them (one per page, never on a doctor-flag page)
| Page | Link | Target today | What the tap does |
|---|---|---|---|
| introducing_potty | "A potty, or a seat and a step stool" | 0 items | S8c toast: "We haven't picked potties yet. Look for a wide, stable base and no splash guard edge that pinches." |
| indian_toilet | "A travel potty and a step stool" | 0 | S8c toast with the page's tip |
| night_dryness | "Waterproof sheets" | 1 mattress protector + 5 dry sheets **exist** | Filtered shop, no toast |
| sit_and_read | "Potty picture books" | 9 in the kids' books list | Kids' books filtered to potty. If there's no filtered route, S8c toast plus a pill to the books |
| introducing_potty (replaces the generic `pp_product_guide`) | "How to choose a potty" | no guide | S8c toast; the guide goes on the owed list |

**Owed:** a "Potty and toilet" shop subcategory (potty, seat insert, step stool, travel potty, cloth trainer pants) goes in BEFORE-LAUNCH next to the products-on-hold item.

## PT5. Experts and classes next to the worry
- **Expert row per tab, after the first shelf, never stacked with a red flag** (rule c):
  - **Accidents:** "Withholding, a regression that won't lift? A paediatrician".
  - **Dry nights:** "Wet past five? A paediatrician". A paediatric urologist category is missing, so S8b points to a paediatrician.
  - **Starting out:** "Refusal and fear? A child psychologist" (the category exists in Behaviour).
  - **0–12 months:** none. It's a light stage.
- **Consult blocks** go on the doctor-flag pages that lack one: accidents_are_normal, potty_refusal, taking_longer and wiping_and_washing. One pitch per page; no product on those pages.
- **The masterclass:** the "Short potty masterclass" link becomes S8d: "This class isn't open yet. Tap Tell me and we'll let you know." The class goes on the owed list. **Its paid wording is commented out** until it exists.
- **Parents' room:** a "Parents in the middle of this" link to the `potty` room at the foot of Accidents.

## PT6. Depth, safety and India (copy goes in `05-potty-content.md`; everything clinical is REQUIRED_REVIEW)
- **Rewrite pull_ups** (thin): cloth trainer pants versus pull-ups, the Indian choice of cotton chaddi plus a towel, and when pull-ups help (travel, nights).
- **night_dryness:** add a doctor callout (wetting after six months dry, pain, thirst) and a link to bedwetting.
- **indian_toilet:**
  - The constipation-while-travelling warning becomes a doctor callout.
  - Add the health faucet and lota by name, next to bucket and mug.
- **bedwetting:**
  - Name "enuresis" once.
  - Explain plainly what an alarm is and when doctors suggest it (6 years and up).
  - Name the prescription medicine (desmopressin) as "a doctor's choice, never from a chemist on a friend's advice".
- **withholding_constipation:** add a block, "Leaks in his pants can be constipation", explaining soiling (encopresis) so it isn't read as naughtiness.
- **wiping_and_washing:** add a pinworm card (night itch, worms in the stool, the whole family treated by a doctor).
- **school_and_public:**
  - Add "When the nursery asks 'is he toilet trained?'", with words for the admission conversation.
  - Drop the duplicate spare-clothes card (commented out).
- **Links:**
  - what_is_su_su's "Read next" becomes a real link to reading_signals.
  - regressions links to Family's `fam_sibling_jealousy` ("When a new baby arrives"), not the whole Behaviour door.
- **One source for repeats:**
  - The no-stars message lives on no_star_charts. The other three become one line with a link.
  - The dry-nights timeline lives on honest_timeline; night_dryness links to it.

## PT7. Films (S8a until made)
- The 8 slots stay.
- Add a door intro, `potty/door_intro` (AI scenes, 30–45 s).
- Add 3 demos for the shelf: the after-waking sit, hand washing at a low tap, and the Indian toilet seat-and-stool set-up.
- Fix the stale ledger in `DOOR-CONTENT-OWED.md`: PT1–4 are written, and the slot count is 8.

## PT8 and PT10. No tab is ever locked; a later-age tab opens, last, with a "for later" line
**PT10 (the user's question, 2026-10-24: "should we lock the content???"):** no lock, in any door.
- **Later-age tabs open normally.** They sit last in the tab order, and the tab opens with one quiet line on top: "For later. This usually starts from 1 year." No lock icon, no misted card. The card shows "For later" where it said "From 1 year".
- **Outgrown tabs:** tabs he has outgrown still drop away, as today.
- **PT8, a link from home or a page into a later-age tab:** it opens that tab with the same line, never a locked panel and never a redirect.
- **Step 0:** this is shell rule **S9** for every door. It replaces the lock in `pp_door_screen.dart` (the locked-card path is commented out, "kept for revert").
- **Other plans:** the Feeding plan's "locked 'From 6 months'" tabs read as "for later" under S9.

## PT9. Taps that can't happen yet (S8)
| Target | Toast |
|---|---|
| 8 slots, the intro, 3 demos | S8a |
| Potty, seat, step stool, travel potty | S8c 0-item toast with the page's tip |
| Potty buying guide | S8c: "We haven't written the potty guide yet. The three things to check are on this page." |
| Potty masterclass | S8d (Tell me) |
| Paediatric urologist | S8b → Paediatrician |
| Every consult | the existing "experts joining" page (roster gated) |
| A later-age tab, opened by a link | S9: opens with the "for later" line |

## Names
All tab names already pass `door_names_fit_test`. The new activity names are kept to two card lines.

## Build order (after step 0, plus S9, and your go)
1. Bands and page bands
2. tabOrder
3. The shelf and the new activities
4. Expert rows, consults and the class S8d
5. Product links and toasts
6. Content edits
7. Films and the ledger

**Reuse:**
- `PpDoor.tabOrder`
- `PpDoorTool.bands`
- the Development activity shelf (D2)
- `PpDoorTab.expert`
- M4 `PpLink.pageId`
- `pvToast`
- `ppRelevanceOrder`

## Verification
- **Tests:**
  - `test/pp_potty_door_test.dart` updated: band split, tabOrder per band, shelf first at every band, no scoring state on any activity
  - `pp_potty_doors_test`
  - `door_names_fit_test`
  - `pp_doors_first_view_test`: the opening tab per band and the S8 tap check
  - an S9 test: no door draws a lock; a later-age tab opens with the "for later" line, from a tap and from a link
- `flutter analyze` on touched files only.
- **Wiring gate:** grep the call sites.
- A phone walk only on your word.

## PT11. What his poo tells you (the demand re-check)
The su-su tab (0–1) gets a link: "What his poo tells you" → First 40 `f40_nappy_poop` (M4 pageId). That page is widened and tagged 0–12 months (copy in `06-first40-content.md` §R1). One page, linked from Potty, Health (H8) and First 40.

### What parents actually ask (the demand re-check, 2026-10-25)
From `research/questions/ranked_parenting.csv`. PT1 to PT10 stand. The poo questions are about babies' nappies, not training (PT11).

| Question | Hits | Where it is answered |
|---|---|---|
| when should potty training start | 107 | Starting out, readiness |
| why is baby poop green; does it smell; how many times a day; what it should look like; watery; colour | ≈290 | **Only a newborn page** (`f40_nappy_poop`). PT11 |
| should 3 year olds be potty trained | 31 | Starting out |
| regression | 18 | Accidents |
| which potty training pants is best | 20 | PT4, products next to the step |

## Decisions
| # | Question | We recommended | Your answer |
|---|---|---|---|
| PT1 | Open on the tab that fits his stage (su-su for babies, Starting out 1–3, Accidents 3–6), timeline one tab away? | Yes | **Yes** (2026-10-24) |
| PT2 | Split the bands into 0–1, 1–2, 2–3, 3–4 and 4–6, with page bands where the text names an age? | Yes | **Yes** (2026-10-24) |
| PT3 | A "Try this today" shelf of 4–6 activities first on screen, no ticks or counts, using the approved Development shelf look (no new mockup)? | Yes | **Yes** (2026-10-24) |
| PT4 | Potty products and books next to the step, with honest toasts until the shop has them, and a Potty shop category owed? | Yes | **Yes** (2026-10-24) |
| PT5 | Expert rows per tab, consults on 4 more flag pages, the masterclass as "Tell me", a link to the parents' room? | Yes | **Yes** (2026-10-24), after asking "what does a tell me toast means??????" and getting it in plain words |
| PT6 | The content changes: pull_ups rewrite, two new doctor callouts, bedwetting alarm and medicine, soiling, pinworms, nursery admission, one source for repeats? | Yes | **Yes** (2026-10-24), after saying "i am not able to understand this ques at all" and getting it in plain words |
| PT7 | A door intro film and 3 demo films, and the ledger fixed? | Yes | **Yes** (2026-10-24) |
| PT8 | A tab locked for her age never opens from a link (new shell rule S9 for all doors)? | Yes | **Yes** (2026-10-24). Reshaped by PT10: no tab is locked, so a link opens the later-age tab with the "for later" line |
| PT10 | Should tabs for a later age stay locked? (raised by the user: "should we lock the content???") | Unlock, every door | **Unlock, every door** (2026-10-24): later-age tabs open, sit last, carry "For later, usually from …"; outgrown tabs still drop |
| PT11 | Widen First 40's `f40_nappy_poop` to 0–12 months with "After the first weeks, and after solids", and link it from the su-su tab | "Why is baby poop green" (87), "how many times should a baby poop" (59) and the rest have no page after 40 days | **Yes**, chosen and recorded. Copy in `06-first40-content.md` §R1. Added by the demand re-check, 2026-10-25 |
