# Door 7: Sleep, the plan

**Also (2026-10-26):** the tools pass (`docs/pp-tool-plans/29-33-other.md`) moved Sleep Sounds onto the tool shell, made its timer count from play and survive a stop, put the 2-metre white-noise line on the player and the library page, and made the library's tanpura play.

Written 2026-10-24. **Status: built 2026-10-25, see §12.** SL1 to SL9 answered yes by the user 2026-10-24 (SL9 with "make sure of tab width"), SL10 chosen and recorded 2026-10-25. The new copy is in `07-sleep-content.md`. Proposed shell rule S11 (names never cut at a large text size), built at step 0; its measured test was built with this door.

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

## SL10. Sick nights, head bumps and side sleeping (the demand re-check)
- **A new short page** "When he's sick, or after a bump on the head". Area: the night-waking area. Bands: 6 months and up.
  - It links Health's fever rail and first aid, and Safety `safety_falls`.
  - Its red-flag list sits first and never sinks (S10).
- **`safe_sleep`'s first line** names the side.

### What parents actually ask (the demand re-check, 2026-10-25)
From `research/questions/ranked_parenting.csv`. SL1 to SL9 stand. Two questions have no page (SL10).

| Question | Hits | Where it is answered |
|---|---|---|
| how long a toddler, a 1, 3 or 5 year old, a newborn sleeps | ≈480 | `how_much` |
| should 3 and 4 year olds nap | 146 | `dropping_naps` |
| is it ok for a newborn to sleep on its side; on its stomach | 102 | `safe_sleep`, but "side" is never named. SL10 |
| should I let my toddler sleep when sick | 52 | **No page.** SL10 |
| should a toddler sleep after hitting his head | 47 | **Nowhere in the app.** SL10 |
| can a newborn sleep with a pacifier | 35 | `dummy_soother` |
| pillow, blanket | 70 | safe sleep after one (SL7) |

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
| SL10 | A new page "When he's sick, or after a bump on the head", and "not on his side" named on `safe_sleep` | 52 + 47 + 78 hits with no answer | **Yes**, chosen and recorded. Copy in `07-sleep-content.md` §R. Added by the demand re-check, 2026-10-25 |

## 12. As built (2026-10-25)
Held by `test/pp_sleep_door_test.dart` ("door 7: the plan, held", 12 tests, and "door 7: on screen", 4; 57 in the file): the tab order for every band, the Tonight cards for each band exactly (pages in band, surfaces that open), the row on the opening tab and nowhere else, the band split, the first-year tags and no infant safe-sleep page for one to five, the tracker against the door's own chart at every month to five, the tanpura first in every sounds offer and in the player, the honest word on a track not recorded, the eight shop links exactly (one a page, none on SIDS, bed-sharing, the red flag or the bump page, never a nest, swing or bouncer), the expert row and the three courses, the new pages with their doctor line and `REQUIRED_REVIEW`, every link landing, the eleven film slots, SL10, and the first view at 1, 4, 8, 18, 30 and 48 months. `test/door_names_fit_test.dart` gained the SL9 check (below).

**The shell: nothing new in the shared door screen.** Tonight is the fourth inline tool (`PpSleepTonightShelf`, `doors/pp_door_inline_tools.dart`), on the same `_ShelfCard` as Play today and Try this today, so the shelves cannot drift. Its cards are data in the door file (`kPpSleepTonightCards`): a page by id, or a surface (the tanpura, Early Learning's bedtime tales, the wake-windows tool). `ppDoorInlinePageIds` returns the row's pages, so a newborn's Safe sleep tab does not draw the sleep-space check and the swaddle twice.

**A mechanism worth keeping (SL9).** The names test held tab names to fifteen characters a line, which is the carousel card (156 wide, Fraunces 16). The tab card on the rail is narrower: 150 wide, padding 14 and 10, and a 6 gap and a 20 chevron beside the name, so the name has 100 points in Manrope 700 at 14. Measured with Manrope's own advance widths (from the font file in `design-kit/node_modules/@fontsource/manrope`, read with fontTools, stored in the test), three names already take three lines at the **normal** size and are cut with dots today: Potty "Accidents and going backwards", First 40 "Understanding your newborn", Family "Who looks after your child". At 1.3, eighteen do, two of them by a single word wider than the line ("Something's", "Grandparents"), which Flutter breaks mid-word. The general point: a check that measures a stand-in (characters) is only as good as the stand-in's match to the real thing, and here it was matched to the wrong card. The font cannot be laid out in a test (google_fonts loads at run time), so its widths are the next best thing.

**Differences from the plan, and why:**
| Plan | Built | Why |
|---|---|---|
| SL5: cribs and bassinets on `sleep_surface` | On the jhula page, beside "move them onto a flat, firm surface" | `sleep_surface` is an interactive page that is only its checklist (an existing test: "a carousel or interactive page is only its block"). The jhula page names the cot and bassinet |
| SL5: net, night light, room thermometer, "a short message with a tip" | Mosquito net on Safe sleep after one, night light on Nightmares and night terrors, room thermometer on Hot nights; one a page | Each where the page asks for it. Night lights and room thermometers join `kPpShelfNotYet` with a tip; mosquito nets already said "a chemist will have one" |
| SL6: courses "show their real price in INR and USD" | The link opens the course's own page, which carries the price | Prices are server-side (every door so far); an unpublished course opens its "Tell me" page (`ppProgramIsPlaceholder`) |
| SL6: "a tap opens the existing experts joining page" | Yes, through the category: Sleep expert is placeholders only, so `pp_experts/Sleep expert` opens "Our first experts are joining" | No new words needed |
| SL7: "Jhula, cradle or saree swing?" | "The cradle and the saree swing (jhula)" | `pp_doors_english_test`: an Indian word in a title sits in brackets after the English; and doors are guides, not FAQs (2026-10-25), so not a question |
| SL7 and SL10 copy: "he", "him" | "your baby", "your child" | Sleep's voice: the section has no "he" anywhere (195 "your baby", 25 "your child"). The SL10 title keeps the user's words |
| SL7 links: feeding_to_sleep to "Feeding's night-feeds page" | `bf_how_often`, "How often, and how much" | Feeding has no night-feeds page; this is the one that answers "is it hunger" |
| SL7: noisy_breathing to "Health's snoring and breathing page" | `ill_throat`, "Sore throat and tonsils" | Health has no snoring page; tonsils and the operation question is where loud snoring is answered |
| SL7: sids_calmly to "the breathing-and-colour red-flag page" | `health_go_now` | The one canonical go-now list, which has breathing and colour |
| SL1 card "Screens off, story on" | Opens Early Learning's "Little bedtime tales" | The screens advice is folded into the bedtime routine page, which is already the first card; the stories are where "story on" lands |
| SL1: "Night fears (3+)" | On the three-to-five row only; one to three has four cards | As the table says |
| SL2: "Toddlers on the Safe sleep tab: a new page" | Also "Hot nights and power cuts" (every age) on the same tab | SL7's page; one to five see both |
| SL3: the tracker's numbers | Total and naps follow the chart for her band; the wake window follows `kPpWakeWindows` past the first year too (4 to 5.5 h, 5 to 6.5 h, 6 to 12 h), and the test holds every month to five | One number in two places is the drift this test exists for |
| SL4: "Every card or link that shows sounds shows the tanpura first" | Every link's words lead with it (four links and both tool rows), and the player opens on a "Plays now" block above the library | The library page is generated from the player's data and its order stays the player's |
| SL9: "a name that doesn't fit gets a shorter name" | Sleep's "Worries and sounds" is "Worries, sounds". The other doors' 18 names are listed with a proposal each in `_kOwedShorterNames`; the test fails on a new one and on a fixed one still listed | New tab names are the user's call door by door (the Development and Potty renames were); changing ten other doors inside the Sleep build would mix doors. "Worries and lori" fitted too, but only the tanpura plays, so a tab named for lori would promise what isn't there |
| SL10: "its red-flag list sits first" | Pinned (leads the Waking rail from six months, and never sinks once read, S10), with a two-line intro before the list | `pp_section_test`: every page opens with an intro. Pinned is the clause First 40 used; a second pinned page in the section, after the stance |
| SL8: door intro `sleep/door_intro` | Not slotted | S4: no chip until a film exists. Owed SLO1 |
| Verification: a Mobbin check | Not run | The row is the approved D2 shelf look, reused |

**Owed, not in this build:** the films (`DOOR-CONTENT-OWED` SLO1, SLO2), 23 recordings as real lori (SLO3), three shelves (SLO4), the card paintings (SLO5), the 18 shorter tab names (SLO6, the user's words); Traditions' "a cloth swing is as good a place to sleep" line, which goes to the same reviewer as the jhula page (door 10, TR); and a paediatrician's read of every `REQUIRED_REVIEW` line. **Owed to `BEFORE-LAUNCH.md`, not written there because the file holds another terminal's uncommitted work:** (1) the shop question, "do we sell carry nests and swings under Sleep at all?" (SL5); (2) the paediatrician's read of Sleep's new and changed clinical lines (the three new pages, the SL10 page, the side line, the nests item, the tracker ranges). The new pages reach Ask Veda through the incremental ingest, which the user runs.
