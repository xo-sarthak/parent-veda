# Parenting doors: one plan per door

The doors are worked one at a time. For each door: a full audit, then a written plan, then the user's go, then the build.
Read `00-MASTER.md` first. It holds the shared shell fixes (step 0 · S1–S9) that every door plan depends on, the per-door checklist, the door order, and the list of thin and missing doors.

| # | Door | Plan | Status |
|---|---|---|---|
| 0 | Shared shell fixes (S1–S11) | `00-MASTER.md` | Approved 2026-10-23, not built (waits for the other terminal's Wave 8 commit) |
| 1 | Feeding | `01-feeding.md` + `01-feeding-content.md` (offerings and new copy) | All decisions D1–D6 answered 2026-10-23 (D2 look: `claude.ai/artifact/6Kgs3uNdKsbyKybfbdzdRB`). Plan final; build waits on step 0 |
| 2 | Health | `02-health.md` + `02-health-content.md` (15 new pages) | H1–H7 all yes 2026-10-23. H2 look approved 2026-10-24 (`claude.ai/artifact/1fMmpwSHeQwwaUjEWjQ89Q`, v4). Plan final; build waits on step 0 |
| 3 | You, Maa | `03-you-maa.md` + `03-you-maa-content.md` (8 new pages, 11 deepened) | M1–M9 all yes 2026-10-24. Plan final; build waits on step 0 |
| 4 | Development | `04-development.md` + `04-development-content.md` | DV1–DV8 all yes 2026-10-24; DV2 look approved (…1bsFmZ4i5SRg8oiQFyeHHR, v2) with the tab renamed "Sit, crawl, walk" (DV9). Plan final; build waits on step 0 |
| — | No silent tap (S8) for Feeding and Health | `01-feeding.md` §11, `02-health.md` §11, `00-MASTER.md` S8 | Written 2026-10-24 |
| 5 | Potty | `05-potty.md` + `05-potty-content.md` | PT1–PT8 + PT10 answered 2026-10-24. Plan final; build waits on step 0 |
| 6 | First 40 Days | `06-first40.md` + `06-first40-content.md` | FD1–FD9 all yes 2026-10-24 (rows mockup `claude.ai/artifact/2BEwbvkimGDbUpNSe987fh`). Plan final; build waits on step 0 |
| 7 | Sleep | `07-sleep.md` + `07-sleep-content.md` | SL1–SL9 all yes 2026-10-24 (SL9: keep the tab width). Plan final; build waits on step 0. Owed to BEFORE-LAUNCH: the shop sells nests and swings under Sleep |
| 8 | Behaviour | `08-behaviour.md` + `08-behaviour-content.md` | BH1–BH8 all yes 2026-10-25, recommendations checked against what parents search (colic, hitting, tantrums, screens). Plan final; build waits on step 0 |
| 9 | Early learning | `09-early-learning.md` + `09-early-learning-content.md` | EL1–EL9 yes 2026-10-25; obvious ones chosen and recorded without a question (the user's call). Hindi rhymes in English letters, folk rhymes only. Plan final; build waits on step 0 |
| 10 | Traditions | `10-traditions.md` + `10-traditions-content.md` | TR1–TR6 chosen and recorded 2026-10-25 (jhula fixed to match Sleep SL7; malish and which oil, the top search). TR-Q (tone of two pages) approved with two small changes. Plan final; build waits on step 0. Owed to the shop list: baby massage oil is not stocked |
| 11 | Safety | — | |
| 12 | Special care | — | |
| 13 | Family | — | |
| 14 | Papers and money | — | |
| — | Thin and missing doors | `00-MASTER.md` § Thin and missing | after the doors |
| — | Home "Today" strip | — | after the doors |

**Owed after all fourteen plans (the user, 2026-10-25):** re-check the plans for doors 1 to 7 against what parents actually search (`research/questions/ranked_parenting.csv`), as doors 8 and 9 were. Change only a recommendation the numbers contradict.

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
