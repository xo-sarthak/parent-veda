# Journeys — what happens inside a door

Built 2026-08-17. Engine: `lib/screens/brackets/hub/journey_config.dart` +
`journey_screen.dart`. Configs: `lib/data/journeys/`. Rules as tests:
`test/journey_test.dart`.

---

## 1. What exists

| Stage | Journeys | Steps | Elements | Owed |
|---|---|---|---|---|
| Pregnancy | 7 | 25 | 27 | 12 |
| TTC | 6 | 27 | 30 | 16 |
| Parenting | 7 | 21 | 21 | 16 |
| **Total** | **20** | **73** | **78** | **44** |

**A door only gets a journey when its destination does not finish the job.**
25 doors go straight through — the fertile-window screen states the dates and
the peak day, the can-I checker answers and stops. Wrapping a journey around a
complete screen is the same tax as a hub screen in front of a single door.

---

## 2. ⚠️ How we know there is no template

The first attempt at this work stamped "do the thing → understand → what next →
consult" across every door. It was rejected, and the tell was that **every
journey came out the same length**.

Two tests now hold the line, and they are the point of the file:

- **`journeys differ in length`** — step counts run 2 · 3 · 4 · 5 · 6 · 7.
- **`no two journeys have the same sequence of element types`** — the shape of
  each (`read>watch+read>tool>...`) must be unique across all 20. If two match,
  one of them was not designed for its own problem.

Lengths are not a style choice; they track how deep the problem actually is.

| Journey | Steps | Why that length |
|---|---|---|
| Understand recovery & trying again | **2** | After a loss. Padding it is the injury, not the care. |
| Check how I am feeling | **2** | Every extra step is a reason to close the screen. |
| Follow my First 40 Days | **2** | It is a programme. Resisting padding IS the design. |
| Manage a skin concern | 3 | Normal? Safe? What helps. Then it ends. |
| Track my readings | 4 | It loops — a habit, not a walk. |
| Understand my condition | 5 | Frightened reader, and it must end at a person. |
| Understand my PCOS | **7** | Highest-demand bracket with genuinely distinct sub-questions. |

---

## 3. Rules the journeys hold

- **Every step heading is HER question**, never our category. "How worried
  should I be?" — not "Content".
- **Every journey declares `closesWhen`.** A journey with no closure is how a
  hub grows a step that exists only because we needed another screen.
- **An owed element is not tappable.** It states what it will hold and cannot be
  pressed — a placeholder that looks tappable and does nothing teaches her that
  taps do nothing, everywhere in the app.
- **No personalised probability**, tested against the copy itself. Population
  statistics are allowed where they reduce pressure ("roughly 1 in 5 women"),
  never a computed chance for her.
- ⚠️ **After a loss: no product, no course, no consult.** Tested. The journey is
  two reads and a line saying there is no clock she has to beat.

### Where commerce appears, and why

Three journeys carry a product. Each earns it by a need established in an
earlier step:

- **Manage a skin concern** — she is buying a cream today either way; the useful
  thing we can do is say what is safe and what is a waste of money.
- **Track my readings** — she has been *asked* to measure something and needs
  the device. ⚠️ The same card is deliberately ABSENT from "Understand my
  condition", where it would be selling into fear.
- **Understand my PCOS** — ovulation strips, at the step about keeping an
  irregular cycle readable.

**Understand my PCOS is the most commercially dense journey in the app**
(product + course + consult). Each placement is defensible; the density is
worth a human eye.

---

## 4. ⚠️ Eight defects the destination audit found

Every door's destination was read and asked one question: *does this finish the
job the door promised?* These are the answers that were "no".

| # | Defect | Fix |
|---|---|---|
| 1 | **After a pregnancy loss, "Get emotional support" opened Community unfiltered.** A "Loss & Recovery" room exists and is written exactly right, but is not auto-joined — while the two rooms that ARE auto-joined are "Trying Naturally" and "First Month". A grieving woman was shown IVF costs, ovulation strips, and two rooms about actively trying. | Opens in the loss room. |
| 2 | **"Understand my recovery" opened an article about the baby's sleep regression.** The reading library's hero is hardcoded and only 2 of its 10 articles are about the mother. | Opens the one collection about her. |
| 3 | **"Explore a tradition" opened home remedies for colic.** `pp_nuskhe` is illness remedies, not Annaprashan or mundan. Nothing looked broken — the screen is real and good — which is why it slipped through. | Re-pointed to a journey; content owed. |
| 4 | **"Handle a behaviour" surfaced 2 of the concerns it named.** It pre-filtered on the word "behaviour"; tantrums and clinginess are filed under "Mood". The filter looked like it worked. | Filters by category. |
| 5 | **"Understand sperm health" opened the partner's whole daily dashboard**, where sperm content is one card among many and in one chapter reads "nothing special is required of you this week". | Re-pointed to a journey. |
| 6 | **Three consult doors opened the same nine-category page** and asked her to scroll past yoga and nutrition to reach the card she had just tapped a button about. | Scoped to a category. |
| 7 | ⚠️ **A comment claimed a resolver existed that picked the right consult per hub. It did not exist.** A comment describing behaviour the code does not have is worse than none: it stops the next person checking. | Comment corrected; scoping actually implemented. |
| 8 | **`pp_food` is wired to a screen the codebase itself marks RETIRED** ("do not wire this back as a live screen"). Still works; still stale. | ⚠️ NOT FIXED — logged below. |

---

## 5. Still owed

- **44 owed elements.** Real promises with no content yet. Each names what it
  will hold and is not tappable.
- **`pp_food` → retired `FoodHomeScreen`.** The rest of the app moved to
  `RecipesScreen`. One router line, not done in this pass because it affects
  surfaces beyond the hubs.
- **Hindi.** Every journey string is `_en(...)`.
- **The doors are still reasoned, not evidenced** — 35,000+ competitor reviews
  remain unchecked against them.
- **Journeys have not been seen on a device.** Structure is verified offline;
  text and feel are not.
