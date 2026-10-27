# Door 3: You, Maa, the plan

Written 2026-10-24. **Status: final. M1 to M9 answered yes by the user 2026-10-24 (§ Decisions).** **Built 2026-10-25; see §13 As built.** The new and deepened page copy is in `03-you-maa-content.md` (M7). Nothing in `lib/` changes until step 0 and the user's go. The master plan is in `README.md`.

## Context
You, Maa is the one door about the mother. It holds 110 pages in 11 areas across 5 tabs, with 31 video slots (all placeholders) and 20 consult blocks.
- Files: `lib/data/doors/pp_door_you_maa.dart` and `lib/screens/post_pregnancy/pp_you_maa_content.dart`.
- Her bands measure her time since birth: `kPpPostpartumBands`, `pp_age_bands.dart:173`.

Its problems:
1. **The exercises are buried.** They sit in Body (pelvic-floor area, 2nd area) and in Moving and eating (tab 3). Of the 14 exercise pages, 6 have no demo, and no movement action shows on the opening tab.
2. **Her bands are wrong.** The first band, "The first 6 weeks", is `fromMonths 0, toMonths 2` with weeks/4.345, so it runs to about week 8.7. The next band, "6 weeks to 3 months", lasts about 4 weeks. Stitches and lochia pages show past 8 weeks. The band also follows whichever child is selected.
3. **The Body tab has no red flag.** `body_red_flags` (bleeding, BP, clots) is just a card in a rail.
4. **Some links land in the wrong place:**
   - 4 "food for you" links open `pp_food`, which is **baby** recipes.
   - 2 links are dead (`surfaceId: null`, content L931, L1557).
   - `move_after_csection` promises a "recovery programme" that does not exist.
   - Shop links promise belts, a sitz bath and cooler bags, none of which are stocked.
5. **There are two crisis screens.** The mood check opens the pregnancy `MmCrisisPathScreen` (`pp_mood_check_screen.dart:70`); the router opens `PpCrisisPathScreen`.
6. **Consults go to the wrong people.** The closing and every mind consult go to 2 *seeded* counsellors, and physio has 2 seeded people. The one category with real people, Gynaecologist (3), is never offered. Nutritionist is never used.
7. **Some bands are wrong for the content:**
   - `body_hair_fall` and `body_wrist_neck` stop at 6 months.
   - `move_running` shows only after 6 months.
   - `people_intimacy` (contraception) is hidden in the first band, though ovulation can return before 6 weeks.
   - `you_route_stiff` is hidden in the first band.
   - `you_route_work` starts at 3 months, though the Going back tab opens at 2.
8. **18 pages are thin:**
   - 6 route pages
   - `body_afterpains`, `body_thyroid`, `mind_birth_trauma`, `people_separated`
   - 7 "Can I…?" pages
9. **India gaps (grep 0):**
   - contraception methods (Copper-T/PPIUCD, Antara, Chhaya)
   - spacing
   - the GDM and BP follow-up after birth
   - Pap and breast checks
   - domestic violence
   - PMMVY/JSY
   - partner depression (1 mention)
10. **The video slot ids are messy.** They use three prefixes (`you/`, `you_maa/`, `youmaa/`), and there is no door intro.

## 1. Tab order: Today always first (decision M1)
The frightening-thoughts route must stay pinned at the very top of the landing tab (a door rule, `pp_door_you_maa.dart:17`). So "How are you today?" opens in every band, as Something's wrong does in Health. The rest of the order follows her band, using `PpDoor.tabOrder` from the Feeding plan:

| Her band | Order after Today |
|---|---|
| 0–6 weeks | Your body, Moving and eating, People, Going back (locked) |
| 6 weeks–3 months | Moving and eating, Your body, People, Going back |
| 3–6 months | Moving and eating, Going back, Your body, People |
| 6 months+ | Going back, Moving and eating, Your body, People |

**Action on the first screen (M1):** a second tool card on Today, after the mood check, called **"10 minutes for you today"**. It is banded with `PpDoorTool.bands` and opens one session picked for her week:

| Her band | Session |
|---|---|
| 0–6 weeks | breathing and a first walk (`pf_ex_breathing`) |
| 6 weeks–3 months | `co_pelvic_rec` Pelvic-Floor Daily Ten |
| 3–6 months | `co_deepcore_rec` |
| 6 months+ | `move_getting_stronger` |

This is not a tracker: no score and nothing is saved, so the door's no-tracker rule holds.

Order on Today:
1. The pinned scary-thoughts route.
2. The tools.
3. The first rail.
4. The counsellor row, **after** the first rail, never stacked under the red route (the user's rule from Health, 2026-10-23).
5. The other rails.

## 2. Her bands in weeks (decision M2, a shell change for this band set only)
- Add optional `fromWeeks`/`toWeeks` to `PpBand`, used by the band lookup when set.
- Set the bands to 0–6, 6–13, 13–26 and 26+ weeks.
- Her clock follows the **youngest** child's birth (her latest recovery), not whichever child is selected.
- Labels stay. Add `test/pp_postpartum_bands_test.dart` with these checks: week 7 falls in the second band, week 12 in the second, week 14 in the third, and with two children the younger one sets her band.

## 3. Body tab red flag, and age shelves (M3)
- **Body gets `redFlagPageId: 'body_red_flags'`.** Today keeps its own, so each tab has one red row, never two on one screen.
- **Age shelves first**, using the H-M1 `ageRail` from Health and the look approved 2026-10-24, so no new prototype is needed:

| Her band | Body: "Right now for you" | Moving: "Your movement this week" |
|---|---|---|
| 0–6 w | lochia, perineum / C-section early (by birth type if known), afterpains, breasts, rest, sweats | pf_ex_breathing, move_first_weeks, move_walking, move_bounce_back |
| 6 w–3 m | six-week check, scar care, back and posture, constipation, pf_leaks, hair fall | move_six_week_check, pf_ex_kegels, move_core_reconnect, move_after_csection, move_walking |
| 3–6 m | diastasis, core recovery, wrist and neck, hair fall, periods returning, thyroid | pf_ex_progression, pf_ex_connect, move_diastasis_training, move_getting_stronger, move_running |
| 6 m+ | periods returning, energy, skin, hair fall, thyroid, pf_sex_pain | move_getting_stronger, pf_ex_functional, move_running, move_diastasis_training |

- The Moving shelf pulls the `pf_ex_*` pages in through `PpDoorTab.extraPageIds` (from the Feeding plan). There is one copy of each page; area rails skip what a shelf already shows.
- **Moving and eating tools**, each banded:
  - "Kegel Care" (`pp_kegel`), all bands
  - "Classes for after birth" (`pp_yoga`), all bands; the After-check classes are gated by `kYogaAfterCheckIds`
  - "Can I eat or take this?" (`pp_maa_can_i`), all bands; this replaces the `cani_search` card

## 4. Band tag fixes
- `body_hair_fall` and `body_wrist_neck`: 6 weeks onward (b1–b3).
- `move_running`: from 3 months (b2+b3), with "after your physio or doctor's OK" in the copy. The UK return-to-running guidance is not before 12 weeks; marked REQUIRED_REVIEW.
- `people_intimacy`: all bands.
- `you_route_stiff`: all bands. In the first band it routes to `move_first_weeks`.
- `you_route_work`: from 6 weeks (b1–b3).
- The 13 mind pages stay in every band; that rule is unchanged.

## 5. Links that land right (M4)
- **`PpLink` gains `pageId`.** A route opens the page itself, one tap; the content header names this limitation (L143). Then:
  - The 4 `pp_food` links go to the healing kitchen pages, not baby recipes.
  - The route pages become one tap shorter.
- **Small fixes:**
  - The 2 dead links (L931, L1557) are pointed at real pages.
  - `move_after_csection`'s "recovery programme" link goes to `po_gentle_rec` / `co_deepcore_rec`.
  - The mood check opens `PpCrisisPathScreen`; the pregnancy screen is not touched.
  - The stale header comments are updated (crisis is routed, the door has tools).

## 6. Experts, classes, products next to the worry
**Mind safety rule (M5).** On every mind page, the free route (Tele-MANAS 14416 and the crisis path) sits **above** any paid counsellor card. No paid card goes on `you_route_scary`, `mind_psychosis` or `circle_safe`. The existing counsellor cards on the other mind pages stay, below the free line.

**Expert row per tab** (S3), placed after the first rail on every tab:

| Tab | Row | Category |
|---|---|---|
| Today | "Not feeling like yourself? Talk to a perinatal counsellor" | Maternal mental health |
| Your body | "Something not healing right? See a gynaecologist" | Gynaecologist (3 real) |
| Moving and eating | "Leaks, heaviness, a gap in your tummy? A women's health physio" | Physiotherapist |
| People | "Talk it through with a counsellor" | Maternal mental health (a couples or family counsellor is owed) |
| Going back | "Pumping at work? A lactation expert" | Lactation (3 real) |

**Gynaecologist in pages (M6):** `people_intimacy`, `body_when_normal`, `body_thyroid` and the new contraception, after-GDM and after-BP pages. One pitch per page, in the D2 offer-card pattern.

**Owed people before launch (BEFORE-LAUNCH):**
- real physio and maternal mental health people (each category has 2 seeded today)
- new categories: an adult postpartum nutritionist and a couples or family counsellor

**Classes next to the skill:**

| Class | Pages |
|---|---|
| `po_gentle_rec` (free) | `move_first_weeks`, `move_walking` |
| `co_pelvic_rec` | `pf_ex_kegels` |
| `co_group` | `move_core_reconnect` |
| `co_1to1` | `body_diastasis`, `move_diastasis_training` |
| `po_1to1` | `move_after_csection` |

None of these goes on a page in the first band if the class is after-check.

**Products (M8):** shop links go only to categories in stock: pads, peri bottles, nursing bras, pumps, feeding pillows, loungewear. They go nowhere near mind or crisis pages. The promised items not stocked (postpartum belt/binder, sitz bath, milk cooler bags, more nursing pads) go to `DOOR-CONTENT-OWED.md`; until stocked, the copy stops promising them.

## 7. Videos (M9)
- **Door intro:** `you_maa/door_intro`, a real-human counsellor or gynaecologist welcome (video plan rule).
- **Slot ids:** all 31 move to the `you_maa/` prefix; the old ids are kept in comments.
- **6 new demo films:**
  - `move_first_weeks`
  - `move_diastasis_training`
  - `move_getting_stronger`
  - `pf_ex_functional`
  - `body_back_posture`
  - `body_wrist_neck`

  The pelvic-floor and diastasis demos are filmed or reviewed by a physio.
- All of them are listed in `DOOR-CONTENT-OWED.md` with a brief and a length.

## 8. Depth
**Thin pages deepened:** `body_afterpains`, `body_thyroid`, `mind_birth_trauma`, `people_separated` and the 7 "Can I…?" pages. Each gets an intro, the body, a when-line, an India note, and a doctor callout where clinical. The 6 route pages stay short by design (triage), but each ends in a one-tap page link (M4).

**8 new India pages (M7)**, written in `03-you-maa-content.md`. All are REQUIRED_REVIEW and never give a dose:

| Page | Area | Covers |
|---|---|---|
| `body_contraception` | your_body | LAM's three conditions; PPIUCD/Copper-T, Antara, Chhaya, free at government hospitals; sterilisation |
| `body_after_gdm` | your_body | the sugar test 6–12 weeks after birth if she had GDM; yearly after |
| `body_after_bp` | your_body | BP checks after pre-eclampsia; the warning signs |
| `body_screening` | your_body | Pap test, breast self-check, the Hb check |
| `people_partner_low` | people | when the father is low too |
| `people_safe_at_home` | people | domestic violence: 181 and 112; **no pitch** |
| `people_spacing` | people | the next baby, spacing; a bridge to TTC |
| `work_schemes` | back_to_work | PMMVY, JSY, Maternity Benefit Act; points to the Papers and money door |

**Overlaps, recorded:**
- First 40 Days keeps its own copies (rest and food, recovery red flags, not yourself, folk practices). They become windows into these pages in the First 40 plan (door 6).
- Feeding's `bf_diet`, `bf_supply` and `bf_pumping` link here, as one source, at the Feeding build.

## 9. Build order (after step 0 and the user's go)
1. The M2 bands in weeks, and their test.
2. `PpLink.pageId` (M4), with the router and reader changes.
3. The door file:
   - tabOrder
   - Body's red flag
   - the ageRails
   - the tools with bands
   - the expert rows
4. Content:
   - band fixes
   - link fixes
   - consult and class placement
   - shop clean-up
   - slot-id rename
   - thin pages
   - the 8 new pages
5. The mood check's crisis screen.

Reuse:
- `ppRelevanceOrder`
- the `PvVideoSlot` placeholder
- `pvReadOfferFor`, which gets the parenting aliases from S6
- the `PpDoorTab.expert` / `ageRail` / `extraPageIds` and `PpDoorTool.bands` built for Feeding and Health

## 10. Verification
- Tests:
  - `flutter test` on the You, Maa door test (updated to the new map)
  - `pp_doors_sanity_test`, `pp_relevance_test`, `pp_doors_first_view_test`
  - the new bands test
  - `flutter analyze` on touched files only
- First-view checks:
  - Today opens in every band.
  - The second tool is the banded movement card.
  - No first-band page shows at week 7.
  - No paid card sits on the three crisis pages, and the free line sits above every counsellor card.
- Wiring gate: grep the call sites for `pageId`, `fromWeeks`, the new tool and every expert row.
- Phone walk only on the user's word.

## 11. Docs in the same change
- `DOOR-CONTENT-OWED.md`: 7 films, 4 SKUs, 3 expert categories
- `BEFORE-LAUNCH.md`: real physio and counsellor people
- `STILL-OPEN.md`: the two crisis screens; First 40 single-source
- `GLOBAL-CHANGES.md`: #5 and #15
- `PARENTING-DOORS-REVIEW.md`
- the README row

### What parents actually ask (the demand re-check, 2026-10-25)
From `research/questions/ranked_parenting.csv`. Her own topic is small (102 hits); the postpartum questions sit under First 40's topic.

| Question | Hits | Where it is answered |
|---|---|---|
| when should postpartum hair loss stop | 54 | You, Maa, Body |
| how long postpartum depression lasts; why it happens; how it feels | 96 | You, Maa, Mind, with Tele-MANAS first (M5) |
| when should postpartum bleeding stop | 28 | You, Maa, Body |
| should I take postpartum vitamins | 18 | the iron pages |
| when should you wear a postpartum belt | 16 | You, Maa, Moving |

## Decisions (answered by the user 2026-10-24: "yes for all")

| # | Question | We recommended | Your answer |
|---|---|---|---|
| M1 | "How are you today?" opens first at every age, plus a "10 minutes for you today" card picked for her week? | Yes | **Yes** (2026-10-24) |
| M2 | Her age groups in weeks (0–6, 6–13, 13–26, 26+), following her youngest child? | Yes | **Yes** (2026-10-24) |
| M3 | Body gets its own red flag; shelves for her week first on Body and Moving, in the approved Health look (no new mockup)? | Yes | **Yes** (2026-10-24) |
| M4 | A link can open a page directly (fixes food links landing on baby recipes; routes one tap)? | Yes | **Yes** (2026-10-24) |
| M5 | Free help (Tele-MANAS 14416) always above a paid counsellor card; no paid card on the 3 crisis pages? | Yes | **Yes** (2026-10-24) |
| M6 | Gynaecologist cards on the related pages; real physios and counsellors owed before launch? | Yes | **Yes** (2026-10-24) |
| M7 | 8 new pages for Indian mothers, written now in `03-you-maa-content.md`? | Yes | **Yes** (2026-10-24) |
| M8 | Shop links only to stocked items; copy stops promising the rest? | Yes | **Yes** (2026-10-24), and: *"if some action is not able to take place due to unavailability like here product situation, then make sure user gets a toast notification, so that the user can understand why a tap didn't work"*. That became shell rule S8 (§12). |
| M9 | One naming scheme for video ids, plus a door intro and 6 exercise demo films? | Yes | **Yes** (2026-10-24) |
| M10 | Re-checked against what parents search: no change | Every top question has a page | **No change.** Added by the demand re-check, 2026-10-25 |

Note: the plan as a whole was accepted earlier on 2026-10-24, but M1–M9 were only marked answered after the user answered them one by one ("yes for all").

## 12. Taps that can't happen yet (S8): the toast for each
| Target | When | Toast (`PvToastKind.info`) |
|---|---|---|
| Postpartum belt or binder, sitz bath, milk cooler bags, nursing pads | Until stocked (M8) | "[Item] isn't in the Store yet. We're adding it." |
| Physiotherapist / maternal mental health, while only placeholder profiles exist | Until real people join (M6) | "Our [physios] are joining soon. A gynaecologist can help today." Action pill: "See one". On mind pages it also names Tele-MANAS 14416, free. |
| Couples or family counsellor, adult nutritionist (new categories) | Until they exist | Same pattern, pointing to the nearest category that has people |
| Every video slot (31 + intro + 6 demos) | Until filmed | "This film is being made. The page has everything in it for now." |
| After-check classes for a mother under 6 weeks | Her first band | "This class opens after your six-week check. Gentle Return to Movement is free and safe now." |
| Going back tab, locked under 6 weeks | Her first band | Already says "From 6 weeks"; a tap shows the same words as a toast |

## 13. As built (2026-10-25)
Held by `test/pp_you_maa_door_test.dart` ("door 3: the plan, held", 18 tests) and `test/pp_postpartum_bands_test.dart` (5): the tab order per band, the "10 minutes" target per band, Body's red flag, both shelves row by row (real pages, in band, six at most), an expert on every tab to the right people, the movement tools, every §4 band tag, no first-band page at week 7, every link landing and none on `pp_food`, no paid card on the four crisis pages and the free line above every paid card on a mind page (read through the reader, where the card is drawn), no shop link on a mind page and none promising an unstocked item, a gynaecologist on eight pages, the seven classes, the after-check notice, the eight new pages in place with `REQUIRED_REVIEW`, one film prefix and the six demos, the mood check's crisis screen, and the first view at 3 weeks, 7 weeks, 4 months and 8 months.

**The shell, new for this door and open to every door:**
- `PpBand.fromWeeks` / `toWeeks` and `PpBandSet.youngestClock` (M2, `pp_age_bands.dart`). `active` now reads a weeks clock; for a months-only set it is the same band as before (a test walks six years of days to hold that). Her clock is `ChildProfileStore.youngestAgeInWeeks`.
- The door screen's "for later" timing runs on that clock, in weeks (`_unlockWeeks`), so Going back says "about 6 weeks after the birth", not "about 1 months". The age rail's line on her door reads "Picked for you, 3 weeks after the birth".
- The router: `pp_yoga/<classId>` opens one class (which also closes the route half of Feeding's FD13); `pp_maa_ten_minutes` opens the session for her band; an after-check class before six weeks says so (S8); a placeholder-only physio or counsellor roster says "joining soon" with a pill to the gynaecologists (`kPpJoiningSoon`), the counsellor line naming Tele-MANAS first.
- The reader: the after-BP page's consult carries the "not for an emergency" line (`pvReadConsultNote`).
- Relevance: two signals from her pregnancy record, `sugarInPregnancy` and `bpInPregnancy`, lift the after-GDM and after-BP pages in the first year.
- `kPpConsultRoleToCategory` gains `gynaecologist`.

**A mechanism worth keeping:** M5 said "free help above the paid card", and the block order already put the crisis link above most consults. It was not enough, because since Feeding's D2 the reader draws a page's consult as a grey card **under the first doctor box**, and turns every link into a foot tile. So the order a mother sees is decided by the reader, not by the list of blocks. The free line had to go *into* that doctor box (three pages) or *be* it (four pages got a "Free help, any hour" box). The general point: when a renderer moves blocks, a rule about order has to be tested on the rendered result, which is what the M5 test does (`ppPageAsRead`, then `pvReadOwnConsultAfter`).

**Differences from the plan, and why:**
| Plan | Built | Why |
|---|---|---|
| §1: "10 minutes" banded with `PpDoorTool.bands` | One card in every band; the router picks the session for her band | Four banded cards of one name would leave three folded at the foot of Today ("Earlier", "Coming up next"), the same card three more times |
| §3: the Moving shelf pulls `pf_ex_*` in through `extraPageIds` | Through the age rail itself | An age rail resolves any page of the section by id. `extraPageIds` as well would draw the same pages twice on one tab |
| §3 table plus the content file's additions: shelves of up to 8 | Six a shelf, as the content file's own cap says. 0–6 w: rest and night sweats ride the area rail (after-BP takes a place). 6 w–3 m: hair fall to the rail, the six-week check is on the Moving shelf. 3–6 m: wrist and neck to the rail, after-GDM is on the 6 w–3 m shelf (its window is 6–12 weeks) | The cap |
| §3: "perineum / C-section early (by birth type if known)" | Both pages on the shelf | The age rail keeps its plan's order on purpose (Health). STILL-OPEN §102.7 |
| §5 / M4: "`PpLink` gains `pageId`" | Already there (added for Potty), and the reader already opened it. Used, not built | The header comment saying otherwise was stale; corrected |
| §5: the 2 dead links | "Your first 40 days" opens the First 40 section; "Iron and recovery" opens `eat_iron` | |
| §5: "recovery programme" → `po_gentle_rec` / `co_deepcore_rec` | Both, as two class links, plus `po_1to1` (§6) | |
| §6: the gynaecologist offer card "from ₹900 ($11)" | No price | Prices are server-side and no expert is live (as Feeding and Health) |
| §6: expert row "Pumping at work? A lactation expert" | "Talk to a lactation expert", with "Pumping at work, or a plan for the switch?" as its line | The label/blurb shape every expert row uses |
| M8 + §12: unstocked items toast "[Item] isn't in the Store yet" | The links that promised them are commented out; the stocked ones open their own shelf | M8's words: "the copy stops promising them". A link whose whole promise is an unstocked item has nothing to say but no. Owed YM14 |
| §12: the after-check toast "Gentle Return to Movement is free and safe now" | "Breathing and short walks are the right start for now", with a Breathing pill | That class's own description says "once your doctor clears you". Calling it safe at week 2 would contradict it |
| §12: the Going back tap under six weeks | No toast | Since S9 no tab locks: it opens, with its "For later" line |
| Part A §8: `work_schemes` "bands all, overrides the area's `_cleared`" | Tagged all; the area stays `_cleared` | The shell reads the area band first. Before six weeks the page still shows, on the Going back tab for later, which opens on the six-week band |
| §7: door intro video | Not built | S4: no chip until a film exists. Owed YM13 |
| §10: a Mobbin check and a prototype | Not run | The shelf and expert-row look is Health's approved H2 (v4); nothing new was laid out |
| The wiring gate (`pp_doors_first_view_test`): every door closing opens a screen | Accepts the "joining soon" answer for a placeholder-only roster, and a new test holds that its pill opens real people | Opening two made-up profiles for a mother asking for help is worse than saying who is coming (§12) |

**Owed, not in this build:** the films YM7 to YM13; the shelves, the BP monitor and the people YM14 to YM17; a gynaecologist's read of every `REQUIRED_REVIEW` line and the scheme and law lines against the current government text (`BEFORE-LAUNCH.md`); First 40's windows into these pages (door 6) and Feeding's links here (STILL-OPEN §102.5); the two crisis screens (§102.4).

**Final review, item 4 (2026-10-27): one figure per fact.** Soaking a pad in an hour or a clot bigger than a lemon is go-now on `body_lochia` and both red-flag pages, as First 40's table says (4h). Held by `test/pp_one_figure_test.dart`; the figures are on the BEFORE-LAUNCH clinical read.
