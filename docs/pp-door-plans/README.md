# Parenting doors: one plan per door

The doors are worked one at a time. For each door: a full audit, then a written plan, then the user's go, then the build.
Read `00-MASTER.md` first. It holds the shared shell fixes (step 0 · S1–S9) that every door plan depends on, the per-door checklist, the door order, and the list of thin and missing doors.

| # | Door | Plan | Status |
|---|---|---|---|
| 0 | Shared shell fixes (S1–S11) | `00-MASTER.md` § Step 0, as built | **Built 2026-10-25**, uncommitted. S4 waits for the first door film (the approved design shows no chip until one exists); S5 kept as it is. Held by `test/pp_doors_first_view_test.dart`. The door builds can start |
| 1 | Feeding | `01-feeding.md` + `01-feeding-content.md` (offerings and new copy) | All decisions D1–D7 answered 2026-10-23 (D2 look: `claude.ai/artifact/6Kgs3uNdKsbyKybfbdzdRB`). **Built 2026-10-25**, committed 8f34124: tab order by age, tools with ages, an expert row per help tab, the choking response and gagging on Starting solids, every page tagged, the D2 consult card in the reader (all parenting pages), the D6 copy, 7 pages deepened, 4 demo slots. Differences from the plan in `01-feeding.md` §12. Held by `test/pp_feeding_door_test.dart` |
| 2 | Health | `02-health.md` + `02-health-content.md` (15 new pages) | H1–H8 all yes (H8 2026-10-25). H2 look approved 2026-10-24 (`claude.ai/artifact/1fMmpwSHeQwwaUjEWjQ89Q`, v4). **Built 2026-10-25**, committed f24fa90: Something's wrong and Get help now lead every age, a first rail for his age, an expert on every calm tab (none on Get help now, which ends on the CPR class), "Due in N days" on Vaccines, every page tagged, 15 new pages, 29 more consults (23 on old pages, 6 on new), equipment-only shelves, 4 demo slots, 15 pages deepened. Differences in `02-health.md` §12. Held by `test/pp_health_door_test.dart` |
| 3 | You, Maa | `03-you-maa.md` + `03-you-maa-content.md` (8 new pages, 11 deepened) | M1–M9 all yes 2026-10-24. **Built 2026-10-25**, committed a2426c3: How are you today opens at every age with "10 minutes for you today" second, her bands in weeks on her youngest child's clock, Body's own red flag, a shelf for her week on Body and Moving, an expert on every tab (physio and counsellor say "joining soon" until real people join), free help above every paid card on a mind page, links that land (none on the baby's recipes), shop links only to stocked shelves, 8 new pages, 11 deepened, one film prefix and 6 demo slots, and the mood check on her crisis screen. Differences in `03-you-maa.md` §13. Held by `test/pp_you_maa_door_test.dart` and `test/pp_postpartum_bands_test.dart` |
| 4 | Development | `04-development.md` + `04-development-content.md` | DV1–DV10 yes; DV2 look approved (…1bsFmZ4i5SRg8oiQFyeHHR, v2) with the tab renamed "Sit, crawl, walk" (DV9). **Built 2026-10-25**, committed 5d0857e: four tabs with Play today first at every age, six activities for his age on its first screen (a new pick each day, `PpDoorTab.inlineSurfaceId`), one activity pool of 12 or more per band, corrected age for a baby born early, an expert or class on every tab, toys last with "you don't need to buy anything" first, the movement-signs page, the M-CHAT line, the phases rewrite, and four loops fixed. Differences in `04-development.md` §12. Held by `test/pp_development_door_test.dart` |
| — | No silent tap (S8) for Feeding and Health | `01-feeding.md` §11, `02-health.md` §11, `00-MASTER.md` S8 | Written 2026-10-24 |
| 5 | Potty | `05-potty.md` + `05-potty-content.md` | PT1–PT8 + PT10 answered 2026-10-24, PT11 chosen and recorded 2026-10-25. **Built 2026-10-25**, committed e2c30df: five bands that follow potty stages, the tab for his stage first (su-su, then Starting out, then Accidents from three), "Try this today" on that tab (his stage's activities, 13 new, a fresh order each day, nothing to tick), an expert on every worry tab, consults on four more flag pages, the masterclass as Tell me, potty, travel potty, sheet and book links with honest notices, the pull-ups rewrite and the PT6 safety and India additions, three demo slots, and the poo pointer. Differences in `05-potty.md` §12. Held by `test/pp_potty_door_test.dart` |
| 6 | First 40 Days | `06-first40.md` + `06-first40-content.md` | FD1–FD9 all yes 2026-10-24 (rows mockup `claude.ai/artifact/2BEwbvkimGDbUpNSe987fh`). Plan final; build waits on step 0 |
| 7 | Sleep | `07-sleep.md` + `07-sleep-content.md` | SL1–SL9 all yes 2026-10-24 (SL9: keep the tab width). Plan final; build waits on step 0. Owed to BEFORE-LAUNCH: the shop sells nests and swings under Sleep |
| 8 | Behaviour | `08-behaviour.md` + `08-behaviour-content.md` | BH1–BH8 all yes 2026-10-25, recommendations checked against what parents search (colic, hitting, tantrums, screens). Plan final; build waits on step 0 |
| 9 | Early learning | `09-early-learning.md` + `09-early-learning-content.md` | EL1–EL9 yes 2026-10-25; obvious ones chosen and recorded without a question (the user's call). Hindi rhymes in English letters, folk rhymes only. Plan final; build waits on step 0 |
| 10 | Traditions | `10-traditions.md` + `10-traditions-content.md` | TR1–TR6 chosen and recorded 2026-10-25 (jhula fixed to match Sleep SL7; malish and which oil, the top search). TR-Q (tone of two pages) approved with two small changes. Plan final; build waits on step 0. Owed to the shop list: baby massage oil is not stocked |
| 11 | Safety | `11-safety.md` + `11-safety-content.md` | SF1–SF8 chosen and recorded 2026-10-25: emergency call strip on every tab, CPR for baby and child, flights and front seat (the top search). Plan final; build waits on step 0. Owed to the shop list: gates, socket covers, corner guards, cabinet locks, child helmets. Owed: a first aid and CPR class |
| 12 | Special care | `12-special-care.md` + `12-special-care-content.md` | SC1–SC7 chosen and recorded 2026-10-25: 1–6 open on Extra support; new speech, therapies (with costs), hearing and diagnosis-from-birth pages (speech is the top search); Help in India as steps. Plan final; build waits on step 0. Owed: developmental paediatrician and speech therapist experts |
| 13 | Family | `13-family.md` + `13-family-content.md` | FM1–FM5 chosen and recorded 2026-10-25: babies open on Grandparents; the section goes from 0 links to linking every page; new you-two and on-your-own pages; "Care while you work". FM6 (found by the Papers audit): the back-to-work page is withdrawn, and the Care tab links to You, Maa's seven work pages instead. Plan final; build waits on step 0 |
| 14 | Papers and money | `14-papers.md` + `14-papers-content.md` | PM1–PM7 chosen and recorded 2026-10-25: order by age; every page linked (it had 1 link); "is vaccination covered by insurance" (the top search) answered; passport details; corrections, single parent and legal aid 15100, tax; the document vault reachable from the door; a real Aadhaar five-year reminder; a "Checked" date on every page. Plan final; build waits on step 0 |
| — | Thin and missing doors | `00-MASTER.md` § Thin and missing | after the doors |
| — | Home "Today" strip | — | after the doors |

**Done 2026-10-25 (was owed after all fourteen plans):** re-checked the plans for doors 1 to 7 against what parents actually search (`research/questions/ranked_parenting.csv`), as doors 8 and 9 were. Change only a recommendation the numbers contradict.
- No approved decision was contradicted. Each plan now has a "What parents actually ask" table.
- **Feeding** D7 and **You, Maa** M10: no change.
- **Health** H8: the tummy rail links `f40_nappy_poop`.
- **Development** DV10: the speech pages link Special care and Early learning.
- **Potty** PT11 and **First 40** FD13: `f40_nappy_poop` widened to 0–12 months (≈290 hits on baby poo, only a newborn page).
- **First 40** FD11 "What he can see" (69, no page) and FD12: one source for the oil, matching Traditions TR3.
- **Sleep** SL10: "When he's sick, or after a bump on the head" (99, no page), and "not on his side" named.
- **Behaviour** §3a links Health `tummy_colic`.

**Doors are guides, not FAQs (the user, 2026-10-25):** search demand decides what a door covers, never how it reads. A gap becomes part of the door's topic, written as guidance in its voice: situational titles ("Sleep when he's unwell"), never question titles or Q&A blocks. A door covers everything its name promises, searched or not. The "What parents actually ask" tables are planning evidence and never reach the UI. **Ask Veda covers the same ground:** every new door page reaches the service through the incremental ingest (the user runs it). Turning the question pool into an Ask Veda answer check needs the service repo, so it is a handover, not done here.

**How decisions are asked from door 9 on (the user, 2026-10-25):** obvious recommendations are chosen and recorded in the plan without a question. Only what is genuinely the user's gets asked.

Update the Status column in the same change that moves a door.

## How every door plan records the user's decisions
Each plan ends with a **Decisions** table with four columns: the number, the question, what we recommended, and **the user's answer, with the date and the user's own words** where they said more than yes or no. Open questions read "waiting". A plan is final only when no row is waiting. A decision is never marked answered because a whole plan was accepted.

## A rule every door plan carries (S8)
No silent tap. Each plan lists the targets that are not available yet (an unstocked product, an expert category with no people, a film not made, a class gated by her week) and the toast each one shows. See `00-MASTER.md` S8.

## Names are never cut off
Every tab, tool card and shelf name is complete and clear at a glance. It never ends in "..." or "…", and it fits its card in two lines (the tab card holds about 15 characters a line). The user asked for this on 2026-10-24, after "When will my baby..." was cut off on its card. `test/door_names_fit_test.dart` holds it: it fails on a door `label:` ending in dots, and on a parenting tab name that wraps past two lines.

Fixed 2026-10-24 (old names commented out in place, "kept for revert"):
| Door | Was | Now | Why |
|---|---|---|---|
| Development | When will my baby... | Sit, crawl, walk | ended in dots |
| Behaviour (tool, two tabs) | What to say when… | What to say | ended in dots |
| Behaviour | Tantrums and the stubborn years | Tantrums | three lines on the card |
| Family | Grandparents and the joint family | Grandparents | three lines on the card |
| Potty | Dry nights, doing it herself | Dry nights | three lines on the card |
| Special care | When your child needs a little more | Extra support | three lines on the card |

Left alone: Garbh's red-flag heading "Stop and call your doctor today if..." leads into its list, so it is a sentence, not a name; and its twin in `garbh_screen.dart` is in another terminal's open work.
