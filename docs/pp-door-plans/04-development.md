# Door 4: Development, the plan

Written 2026-10-24. **Status: final. DV1 to DV8 answered yes by the user 2026-10-24. DV2's look approved 2026-10-24 (`claude.ai/artifact/1bsFmZ4i5SRg8oiQFyeHHR`, v2), with one change: the tab "When will my baby..." is renamed "Sit, crawl, walk", which says at a glance what the tab holds and is never cut off (DV9). Built 2026-10-24 with the other cut-off names.** **Door built 2026-10-25; what differs from this plan, and why, is in §12.** The new page copy is in `04-development-content.md`. Nothing in `lib/` changes until step 0 and the user's go. Shell rule S8 (no silent tap) is in `00-MASTER.md`.

## Context
Development is an action door, but it opens like a test. The door definition is `lib/data/doors/pp_door_development.dart` and its content is `pp_development_content.dart`, with 33 pages, none thin and all tagged. The age groups are `kPpDevelopmentBands`: 0–6 months, 6–12 months, 1–2 years, 2–3 years and 3–5 years.

What a parent meets today:
1. **Every child opens on "On track".** The first card is the month's checklist, then the reassurance page.
2. **Play is far away.** "What to do" is tab 3 or 4, and the activities are 4 taps away: door, tab, tool card, activity.
3. **Six tabs.** `PpDoor` says five. Two of them, "Phases" and "Talk and check", hold only a tool card each.
4. **Links that loop back.** Five "Things to do together today" links (`pp_development` → `DevelopmentHomeScreen`, which returns the door) reopen the door instead of the activities. The milestones "Explore by area" button loops back too. `dev_born_early`'s NICU-papers link opens "What changed".
5. **The activities are thin for some ages and have no pictures.**
   - The activity screen holds 47 activities.
   - The 102 activities from the phase docs (`kPhaseDocActivities`) never reach it.
   - A 2–3-year-old sees just 4.
   - No activity has a picture (`kActivityPaintings = {}`) or a video.
   - The tool's blurb promises "Today's pick", which doesn't exist.
6. **Corrected age is used in some places, not all.** The milestones and checklist use corrected age for a premature baby; the door's age groups, the activities and the check-in use actual age.
7. **Specialists aren't where the worry is.**
   - The closing card is never drawn (S3).
   - The developmental paediatrician has placeholder profiles only.
   - The real Special needs roster is never linked from this door.
   - There is no paediatric physio.
   - The two course links open the general Learn home, though Play and Brain, Motor Skills and Language and Communication courses exist.
8. **No toys.** `toys.dart` has 136 age-labelled toys, and none are linked.
9. **Leftovers and odd ages:**
   - `something_changed` sits on no tab.
   - `dev_leaps_lens` still talks about the retired leaps.
   - The tummy-time tool shows up for 3–5-year-olds.
   - 8 video slots, all placeholders.
10. **India gaps (grep):**
    - RBSK/DEIC: 0 here. It lives in Special care's `sc_help_india`, which isn't linked.
    - M-CHAT (the autism questionnaire doctors use): 0
    - Cerebral palsy and movement signs: 0
    - Anganwadi: 0. This belongs to Early learning; noted for that plan.

### D1. Four tabs, play first (DV1)
| Tab | Holds |
|---|---|
| **Play today** (renamed "What to do") | the age shelf of activities, then the play pages, then the tummy-time tool (0–12 months only) |
| **On track** | the checklist, where your baby is (milestones), the phase map (from Phases), "Something has changed" (the tool from Talk and check, plus the orphan area), the age-by-age pages, the worth-checking page |
| **Sit, crawl, walk** (renamed from "When will my baby...", DV9) | unchanged content; 0–2 years |
| **Talking** | unchanged |

Order by age (`PpDoor.tabOrder`): Play today is always first.
- 0–6 months: Play today, On track, Sit, crawl, walk, Talking
- 6–12 months: Play today, Sit, crawl, walk, Talking, On track
- 1–2 years: Play today, Talking, Sit, crawl, walk, On track
- 2–3 and 3–5 years: Play today, Talking, On track

"On track" stops being the landing tab, but the worry is never hidden: the worth-checking page stays one tab away with its flag treatment.

### D2. The activities are the first thing on screen (DV2, prototype first)
Play today opens on a shelf called **"Play with him today"**: 6 activity cards for his exact age, opened in one tap. Each card shows a picture, the time it takes ("5 min") and what it builds ("Talking"). "All activities" goes at the end of the shelf.
- It is built as an inline tool, the existing `kPvDoorSelfPaddedTools` pattern that runs edge to edge.
- A fresh pick comes each day, seeded by date, so "Today's pick" becomes true.
- Mockup: a plain HTML phone page with a Today/Proposed switch, before any `lib/` edit.

### D3. One activity pool, every age covered (DV3)
- Merge `kPhaseDocActivities` (102) into the pool behind `pp_activities`, with duplicates removed by title and skill. That gives about 140, each with an age range.
- Check that every age group has at least 12. 2–3 years is filled from the phase docs.
- The loops are fixed: the 5 `pp_development` links point to the activities (or to the page itself, with M4 `pageId`), and milestones "Explore by area" opens On track. `dev_born_early`'s NICU link goes to Health's records page (M4).

### D4. Corrected age for a baby born early (DV4)
For a baby born before 37 weeks, under 2 years old, the door's age groups, the activities and the check-in use corrected age, the same rule the milestones and checklist already use (`pp_milestones_data.dart:521`). A line on the hero says so: "Using his corrected age, 3 months". Test: a baby born at 32 weeks, at 4 months actual, gets the 0–6-month shelf, with the line showing.

### D5. Pictures and films (DV5)
- **A painting for every activity,** in the house painting pipeline (the journal and onboarding paintings). Until a painting exists, the card shows the skill's line mark, never an empty frame.
- **12 demo films** for the core moves, 30–60 s each:
  - tummy time ×2
  - reach and grasp
  - rolling help
  - sitting play
  - crawling games
  - cruising
  - first steps
  - pretend play
  - turn-taking talk
  - finger rhymes
  - stacking

  A paediatric physio or a speech therapist reviews the ones in their field.
- **Door intro:** `development/door_intro`.
- All of this goes in `DOOR-CONTENT-OWED.md`.

### D6. Toys next to play, without pressure (DV6)
- One **"Toys for this age"** card at the foot of Play today. The copy comes first: "You don't need to buy anything. A steel bowl and a spoon are a toy." The card opens the shop filtered to his age (S8c, `toys.dart`).
- One toy link on each of `dev_sensory_play`, `dev_walking` (replacing the generic guide) and `dev_help_talk` (books). One pitch per page.
- Never on `dev_worth_checking`, `dev_speech_flags` or the new movement-signs page.

### D7. Specialists and classes next to the worry (DV7)
**Expert row per tab,** after the first shelf:

| Tab | Row |
|---|---|
| On track | "Something worrying you? A developmental paediatrician". The profiles are placeholders until real people join, so S8b points to a paediatrician. |
| Talking | "A speech therapist" (3 real) |
| Sit, crawl, walk | "A paediatric physio" (new category, owed; S8b → Paediatrician) |
| Play today | no expert. The class card for Play and Brain instead. |

**In pages:** `dev_worth_checking` adds the Special needs roster (OT, special educator, 3 real) and links Special care's `sc_help_india` for RBSK and DEIC (M4 pageId; one source, no copy).

**Courses linked by id** (S8d checks each one exists):
- Play and Brain → `dev_play_builds_brain`
- Motor Skills → `dev_crawling` and `dev_walking`
- Language and Communication → `dev_help_talk`

### D8. Depth (DV8)
- **New page `dev_movement_signs`,** "Movement signs worth showing a doctor", in On track, all ages:
  - a body very stiff or very floppy
  - still fisting after 4 months
  - using one hand only before 12 months
  - not sitting by 9 months
  - losing a skill

  A doctor callout, a link to the DEIC page, and a paediatric physio row. Written in `04-development-content.md`, marked REQUIRED_REVIEW, never a diagnosis.
- **Additions:**
  - `dev_age_1_2` gets one line: "At 18 and 24 months your doctor may ask a short set of questions about his play and talking (often called M-CHAT). It is a routine check, not a test he can fail."
  - `dev_leaps_lens` is rewritten to talk about phases (the shipped text is commented out).
- **Tool ages:** tummy time 0–12 months; check-in by its five age groups.

### D9. Taps that can't happen yet (S8)
| Target | Toast |
|---|---|
| 8 video slots + intro + 12 demos | S8a |
| Developmental paediatrician (placeholder profiles), paediatric physio (missing) | S8b → Paediatrician |
| Toys of an age group with 0 items | S8c: "We're still choosing toys for this age. Everyday things at home work just as well." |
| Parenting a Child with Special Needs (opening soon) | the existing opening-soon page |
| An activity without a painting | not a tap problem; the line mark shows |

### D10. Build order (after step 0 and the go)
1. Corrected-age banding and its test
2. The tab merge and tabOrder
3. The inline activity shelf
4. The activity pool merge
5. The link fixes
6. The expert rows and course links
7. The toy links
8. The new page and additions
9. The S8 list

Reuse:
- `ppRelevanceOrder`
- `kPvDoorSelfPaddedTools`
- `DevelopmentAllActivitiesScreen`
- `PpDoorTab.expert` / `ageRail` / `PpDoorTool.bands`
- `pvToast`

### D11. Verification
- Tests:
  - the Development door test, updated to 4 tabs
  - `pp_doors_first_view_test`: Play today opens at every age; the first item is an activity card of his age; the S8 tap check
  - a corrected-age test
  - an activity pool test: every age group has 12 or more, with no duplicate titles
  - `flutter analyze` on touched files only
- Wiring gate: grep the call sites.
- Phone walk only on the user's word.

### What parents actually ask (the demand re-check, 2026-10-25)
From `research/questions/ranked_parenting.csv`. DV1 stands: Play today first, milestones one tab away.

| Question | Hits | Where it is answered |
|---|---|---|
| what are baby milestones | 127 | Sit, crawl, walk, and the milestone pages |
| speech: what delays it, when toddlers talk, when to worry, does he need therapy, what it costs | ≈400 | `dev_speech_by_age`, `dev_speech_flags`, now linked onward (DV10) |
| can a 5 year old sit in the front seat; a booster seat | 50 | Safety SF3 |
| autistic toddlers not responding to their name | 11 | the M-CHAT line (DV8) |

## Decisions (answered by the user 2026-10-24: "yes to all")
| # | Question | We recommended | Your answer |
|---|---|---|---|
| DV1 | Six tabs become four, with Play today first at every age? | Yes | **Yes** (2026-10-24) |
| DV2 | Activities shown straight on the first screen, 6 for his age, one tap? (mockup first) | Yes | **Yes** (2026-10-24). Look approved 2026-10-24 on mockup v1: "make sure to keep names in such a way that this ... doesn't happen, rest i approve" (about the cut-off "When will my baby..." card) |
| DV3 | Merge the 102 phase-doc activities into one pool, at least 12 per age? | Yes | **Yes** (2026-10-24) |
| DV4 | Corrected age for babies born early, under 2 years, everywhere in the door? | Yes | **Yes** (2026-10-24) |
| DV5 | A painting for every activity, plus 12 demo films and a door intro? | Yes | **Yes** (2026-10-24) |
| DV6 | "Toys for this age", household things first, one toy link on 3 pages? | Yes | **Yes** (2026-10-24) |
| DV7 | Specialist rows per tab, the Special needs roster, courses by id, a paediatric physio category owed? | Yes | **Yes** (2026-10-24) |
| DV8 | A new movement-signs page, the M-CHAT line, the phases rewrite? | Yes | **Yes** (2026-10-24) |
| DV9 | Rename "When will my baby..." so it is never cut off? | "Sit, crawl, walk", then "Sit, crawl, walk" | **Asked for by the user** (2026-10-24, on the DV2 look). "Sit, crawl, walk" was offered; the user: "swap the name ... something that is understandable in the very first glance and does not get the dotted situation". Now "Sit, crawl, walk" (mockup v3, built in `pp_door_development.dart`). Rule for every door: a tab or card name is complete, never ends in "...", and fits the tool card in two lines (about 14 characters) |
| DV10 | Link `dev_speech_by_age` and `dev_speech_flags` to Special care's "Not talking yet" and "Speech therapy and the other therapies, explained" (SC2), and Early learning's "Help him talk" (EL1), by page (M4) | Speech is this topic's biggest worry (≈400), and the next steps live in two other doors | **Yes**, chosen and recorded. Added by the demand re-check, 2026-10-25 |

## 12. As built (2026-10-25)
Held by `test/pp_development_door_test.dart` (23 tests, "door 4: the plan, held" among them): the four tabs and their order per band, every area placed, On track's reads and tools in order, the shelf on Play today, tummy time for the first year, an expert or class on every tab and each one answered, the toy links (three pages, one each, never on a worry page), the movement-signs page and its order (doctor box, then the specialist), the M-CHAT line, the phases rewrite with no "leap" in it, no link that reopens the door, the NICU papers on the records page, 12 or more activities per band and a full shelf every month, today's six (his age only, the same all day, new tomorrow), corrected age, and the first view at 1, 7, 15, 30 and 48 months.

**The shell, new for this door and open to every door:**
- `PpDoorTab.inlineSurfaceId` draws a tool in place as the tab's first block, resolved by `ppDoorInlineToolFor` (`doors/pp_door_inline_tools.dart`, the parenting twin of the pregnancy door's). It pads itself, so its rail runs edge to edge. The tab card's count includes its things (`ppDoorInlineCount`).
- `PpDoorTab.shop` is the tab's one shop card, at the foot after every free thing, copy first, in an outlined card so it never reads as a second consult.
- `PpBandSet.correctedClock` (DV4): a band set that reads `ChildProfileStore.devAgeInWeeks`. Development's set only; vaccines, growth and every other section stay on the birthday. The hero reads "Using his corrected age, 3 months" when it applies.

**The router:** `pp_toys` and `pp_toys/<sheet category>` open the toy shelf ranked for his age (S8c says "We're still choosing toys for this age. Everyday things at home work just as well." for an age or kind with nothing picked; `ppToysForAge` counts only toys the sheet gave an age). `pp_learn/<programId>` opens one course (S8d for an unknown id; an opening-soon course opens its own Reserve page). `Development expert` joins `kPpJoiningSoon` (placeholders only, pill to a paediatrician), and a `Paediatric physio` now points at a paediatrician, not her postnatal physio, with its own plural.

**The pool (DV3):** `kDevActivityPool` is the three stores in one list, a phase-doc activity with the same title and area as an older one dropped. `activitiesForAge` reads it, so the Activities screen and the shelf share it.

**A bug found and fixed on the way:** Milestones' "Look closer at ..." pushed `DevelopmentAreaScreen`, which since Wave 5b is the whole Development door, and Milestones is opened from that door. So the tap stacked the door on itself. The general point: a facade that turns an old screen into a new one is right for every caller except one that the new screen itself opens. It opens that area's activities now.

**Differences from the plan, and why:**
| Plan | Built | Why |
|---|---|---|
| D1: On track holds "Something has changed (the tool, plus the orphan area)" | The tool only | The area was not orphaned: the user deleted it as a duplicate of the tool ("please delete, it is anyways there as tool"), and it is commented out in the content file. Bringing it back would undo that call |
| D3: milestones "Explore by area" opens On track | It opens that area's activities | Milestones is opened from On track, so On track would still be the door opening itself. The button's own line promises "small things that help" |
| D3: "every age group has at least 12" | Every band has 12 or more; every month has at least 7, so the six-card shelf is always full | Month 14 has 10. The rule is per age group, and the test holds both |
| D2 mockup note: "the build adds a time to each" phase-doc activity | Shown without a time ("MOVING") | The docs give no duration, and the pool's rule is that nothing is invented. Owed DV6 |
| D5: a painting for every activity, 12 demo films, a door intro | None made; logged as owed DV1 to DV3 | Paintings are the user's pipeline; films show no slot until one exists (S4). The cards show the area's line mark meanwhile |
| D7: the developmental paediatrician row | "Joining soon", pill to a paediatrician | Placeholder profiles only, the You, Maa rule (M6) |
| DV10: speech pages link Special care and Early learning by page | Not linked; owed DV7 | Those pages are built with doors 12 and 9 and do not exist yet. A link now would land on a notice |
| D9: S8b toast "See one" | The router's "See them" pill | One words list for every owed expert |
| §10 / D11: a Mobbin check and a prototype | Not run again | The DV2 look (v2, renamed v3) is the approved layout; nothing was laid out beyond it |
| D11: Play today checks in `pp_doors_first_view_test` | In `pp_development_door_test` | Each built door holds its own first view, as Feeding, Health and You, Maa do |

**Owed, not in this build:** the paintings and films (DOOR-CONTENT-OWED DV1 to DV3), the two people (DV4, DV5), phase-doc times (DV6), the DV10 links (DV7), and a developmental paediatrician's or paediatric physio's read of every `REQUIRED_REVIEW` line (`BEFORE-LAUNCH.md`).
