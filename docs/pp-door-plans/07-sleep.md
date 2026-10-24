# Door 7: Sleep, the plan

Written 2026-10-24. **Status: final. SL1 to SL9 answered yes by the user 2026-10-24 (SL9 with "make sure of tab width").** The new copy is in `07-sleep-content.md`. Nothing in `lib/` changes until step 0 and the user's go. Proposes shell rule S11 (names never cut at a large text size).

## Context
**Where it lives.** The door is `lib/data/doors/pp_door_sleep.dart`. The content is `pp_sleep_content.dart`: 44 pages, deep and warm, with a clear stance (safe sleep as harm reduction; where we stand on sleep training).

**Tabs:** How much sleep · Waking at night · Getting to sleep · Safe sleep · Worries and sounds.

**Ages:** 0–3m, 3–6m, 6–12m, 1–3y, 3–5y.

**Kept on purpose:**
- the tracker has no target to hit
- the red-flag page stays pinned on Waking
- Pampers "presented by" stays on the tracker
- harm reduction on bed-sharing

What a parent meets today:
1. **Every age opens on How much sleep.** First come two tracker rows, then a chart. Nothing to *do* tonight: no routine, no wind-down, no sounds. Sounds are a row on the 5th tab.
2. **26 of 44 pages have no age tag, so they show at every age.** A 4-year-old's parent sees SIDS ("one to four months"), back-to-sleep, the cot checklist, dream feeds and malish ("once the cord has healed").
3. **One band covers 1 to 3 years,** so a 13-month-old and a 35-month-old see the same pages.
4. **Safe sleep is the 4th tab for a newborn,** and nothing on the first tab points to it.
5. **The tracker gives toddlers baby numbers.** From 10 months up, "Typical for…" says 12–15 hours and 2 naps (`pp_sleep_data.dart:232-252`). The door's own toddler chart says 11–14 hours. A wrong number, shown to every parent of a 1- to 5-year-old.
6. **Sounds:** 24 tracks in the library. Only one plays (the tanpura drone). The other 23 say "coming soon". The word "lori" has gone from the live text.
7. **Links and items:**
   - 0 products linked, though the shop has cribs and bassinets, swaddles, sleep sacks, white-noise soothers and blackout curtains.
   - 4 sleep courses exist and none is linked (the 4-month regression course; Baby Sleep, Understood; Sleep Bootcamp; the Bootcamp cohort).
   - The sleep expert has only placeholder profiles.
8. **The shop sells "Muslin Carry Nests" and swings under Sleep & Bedding.** The Sleep content never says that nests, swings, bouncers and inclined sleepers are not for sleep.
9. **India gaps (0 hits):**
   - the jhula or saree cradle, as a sleep place. Traditions calls a cloth swing "as good a place to sleep as an imported cot", which needs checking against safe-sleep guidance.
   - mosquito coils and agarbatti on the Safe tab
   - power cuts and hot nights
10. **Vague links:**
    - feeding_to_sleep, sids_calmly and noisy_breathing link to whole sections.
    - Health's "gentle settling" opens Sleep's first tab.
    - The six First 40 newborn sleep pages are copies of Sleep pages, with no link either way.
11. **Thin page:** sleep_talk_walk (about 630 characters).
12. **Films:** 11 placeholders and no intro.
13. **A new "dots" case (all doors):** at a large phone text size the tab card cuts every label to one line (`pv_door_rail.dart:222-228`). "Getting to sleep" becomes "Getting to…". The same happens on locked tabs, which S9 removes.

## SL1. Each age opens on what fits, with "Tonight" first
**Tab order by age (`PpDoor.tabOrder`):**

| Age | Order |
|---|---|
| 0–3 months | Safe sleep, How much, Waking, Getting to sleep, Worries |
| 3–12 months | Getting to sleep, Waking, How much, Safe sleep, Worries |
| 1–5 years | Getting to sleep, Waking, Worries, How much, Safe sleep |

**A "Tonight" row of cards, first on the opening tab.** It uses the approved shelf look and has nothing to tick:

| Age | Cards |
|---|---|
| 0–3 months | Set up a safe sleep space · Swaddling · Day and night · Gentle settling · Tanpura to sleep |
| 3–12 months | The bedtime routine · Wake windows · Malish before bed · Gentle settling · Tanpura to sleep |
| 1–5 years | The bedtime routine · Screens off, story on · Night fears (3+) · Dropping naps · Tanpura to sleep |

## SL2. Age tags and a split toddler band
- **Split the toddler band:** 1–3 years becomes 1–2 and 2–3, the same split as Potty.
- **Tag the 26 untagged pages:**
  - Baby-only safe sleep goes to 0–12 months: sids_calmly, back_to_sleep, safer_bed_sharing, sleep_surface, overheating.
  - gentle_settling (dream feeds), malish, feeding_to_sleep and at_3am go to 0–12 months.
  - sleep_training_stance goes to 6 months and up.
- **Toddlers on the Safe sleep tab:** a new page, "Safe sleep after one", covers moving from cot to bed, falls, a pillow and blanket from 1 year, and keeping the room safe (SL7).

## SL3. The tracker's numbers match the door
Fix `ageContext` in `pp_sleep_data.dart` so it uses the same ranges as the door's charts at every age:
- 1–2 years: 11–14 hours, 1–2 naps
- 3–5 years: 10–13 hours

A test holds the tracker and the charts to the same ranges. Only the "Typical for" numbers change. Clinical numbers are REQUIRED_REVIEW.

## SL4. Sounds that play
- Every card or link that shows sounds shows the tanpura first, the one that plays.
- A tap on any other track shows "This lullaby is still being recorded. The tanpura plays now." (S8a).
- The 23 tracks go on the owed list. The lullabies are recorded as real lori in Hindi, Tamil and Bengali.
- The library's name goes back to "Lullabies and lori".

## SL5. Things to buy, next to the step that needs them
One per page, and never on SIDS, bed-sharing or the red-flag page.

| Page | Link | Stock |
|---|---|---|
| sleep_surface | Cribs and bassinets | 10, filtered |
| swaddling | Muslin swaddles | 10 |
| overheating | Sleep sacks and bags | 2 |
| does_music_help | White-noise soothers | 4 |
| early_waking | Blackout curtains | 1 |
| Mosquito net, night light, room thermometer | | 0 in stock. A tap shows a short message with a tip. |

**Never linked:** carry nests, swings and bouncers. They go in BEFORE-LAUNCH as a shop question: do we sell nests under "Sleep" at all?

## SL6. Help and classes next to the worry
- **Expert row on Waking, below the first row of cards.** It is never stacked with the pinned red flag (rule c). It reads "Nights wearing you down? A sleep expert". The experts aren't live yet, so a tap opens the existing "experts joining" page.
- **Courses, linked by id, one per page:**
  - The 4-Month Sleep Regression, Solved → on regression_4m
  - Baby Sleep, Understood → on sleep_training_stance
  - Sleep Bootcamp → on what_is_regression

  Each shows its real price in INR and USD, and a "Tell me" message if it isn't open yet.

## SL7. Content (copy in `07-sleep-content.md`; clinical lines REQUIRED_REVIEW)
**New pages:**
- **"Jhula, cradle or saree swing?"** What's safe for sleep and what's for soothing:
  - flat, firm and on his back is the rule
  - move him to a flat surface once asleep
  - never a swing or nest for unwatched sleep

  Traditions' line gets the same review, so the two doors agree.
- **"Safe sleep after one."** Cot to bed, falls, pillows and blankets from 1, and the room.
- **"Hot nights and power cuts."** Cotton, a damp cloth near (never on) him, no mosquito coil or agarbatti in the room, and a battery fan.

**Additions:**
- sleep_talk_walk is rewritten; it is thin.
- sleep_surface gets "nests, swings, bouncers and inclined sleepers are not for sleep".
- The word "lori" comes back.

**Links:**
- feeding_to_sleep, sids_calmly and noisy_breathing point to the exact Feeding and Health pages.
- Health's "gentle settling" opens Sleep's gentle_settling page.
- Sleep's swaddling, malish and day_night pages link "In the first weeks" → First 40 (First 40 links back, FD4).

## SL8. Films
- The 11 slots stay.
- Add the intro `sleep/door_intro`.
- Until each film exists, a tap says "This film is still being made" (S8a).

## SL9. Labels never cut at large text (new shell rule S11, all doors and stages)
- At a large text size, tab cards keep 2 lines and grow taller, rather than cutting the name to 1 line with dots (`pv_door_rail.dart:222`). The old one-line rule is commented out, "kept for revert".
- **The card's width does not change** (the user: "make sure of tab width"). It stays 150, so the next card still peeks in. Every name in every door must fit two lines at that width at a large text size; a name that doesn't gets a shorter name, never a smaller font.
- `door_names_fit_test` adds a large-text check, made at build with the rail widget.

## Taps that can't happen yet (S8)

| Target | What she sees |
|---|---|
| 11 films and the intro | "being made" |
| 23 sounds | "still being recorded; the tanpura plays now" |
| Net, night light, room thermometer | A shop message with a tip |
| Courses not open | "Tell me" |
| Sleep expert | The "experts joining" page |

## Build order (after step 0 incl. S9–S11, and your go)
1. Band split and tags
2. tabOrder and the Tonight row
3. Tracker numbers
4. Sounds
5. Shop links
6. Expert row and courses
7. Content and links
8. Films

**Reuse:**
- the D2 shelf
- `PpDoor.tabOrder`
- `PpDoorTab.expert`
- M4 `PpLink.pageId`
- `pvToast` and S8a–d
- `pp_wake_windows_screen.dart`

## Verification
- `test/pp_sleep_door_test.dart` updated:
  - opening tab and first card per age
  - no infant safe-sleep page for 1–5y
  - tracker and charts agree at every age
  - no product on SIDS, bed-sharing or the red flag
- `pp_sleep_check_test`
- `door_names_fit_test`, plus the large-text check
- `pp_doors_first_view_test`
- `flutter analyze` on touched files only
- grep call sites
- phone walk only on your word

## Decisions
| # | Question | We recommended | Your answer |
|---|---|---|---|
| SL1 | Each age opens on what fits (safe sleep for newborns, bedtime for older), with a "Tonight" row of cards first | Yes | **Yes** (2026-10-24) |
| SL2 | Age tags so toddlers stop seeing newborn safe-sleep pages; split 1–3 into 1–2 and 2–3 | Yes | **Yes** (2026-10-24) |
| SL3 | Fix the tracker's wrong toddler numbers | Yes | **Yes** (2026-10-24) |
| SL4 | Show the one sound that plays first; honest message on the rest; record real lori | Yes | **Yes** (2026-10-24) |
| SL5 | Link the sleep things the shop has; never nests or swings; flag nests to the shop | Yes | **Yes** (2026-10-24) |
| SL6 | A sleep expert below the danger list, and the 3 sleep courses on their pages | Yes | **Yes** (2026-10-24) |
| SL7 | New pages: jhula safety, safe sleep after one, hot nights and power cuts; fix vague links | Yes | **Yes** (2026-10-24) |
| SL8 | A door intro film | Yes | **Yes** (2026-10-24) |
| SL9 | Names never cut at large text size, every door | Yes | **Yes** (2026-10-24), the user: "option 1 but make sure of tab width..". So the card keeps its width (150, a fifth of the third card still showing) and grows only in height; at build every tab name in every door is checked to fit two lines at that width at a large text size, and a name that doesn't is shortened, not squeezed |
