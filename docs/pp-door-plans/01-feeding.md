# Door 1: Feeding, the plan

**Status:** plan written 2026-10-23. Not approved, not built.
**Master plan:** `00-MASTER.md`. Build only after the master plan's step 0 (the shell fixes) lands, and after the user says go.
**Files this door touches:**
- `lib/data/doors/pp_door_feeding.dart` (the door map)
- `lib/screens/post_pregnancy/pp_feeding_content.dart` (4,369 lines, 60 pages)
- `test/pp_feeding_door_test.dart`
- the step 0 shell files, `pp_door_data.dart` and `pp_door_screen.dart`

None of these had uncommitted changes from another terminal on 2026-10-23. Check `git status` again before starting.

---

## 1. What a parent sees today, and why it is wrong

The door has 5 tabs: Milk feeds, Starting solids, Cooking for your child, Growing well, and Keeping it safe. One area (`age_charts`) is hidden because it is merged into the food-chart tool.

The age bands are Feeding's own: milk 0–6m, first foods 6–8m, 8–12m, toddler 12–24m, and 2 years and up.

| Her child | What opens today | What she should see first |
|---|---|---|
| 2 months | Milk feeds. 5 tools in a row, the mastitis pin, then ~20 milk pages | Right tab. But 5 tools stand before any help, and the lactation expert never appears. |
| 7 months | **Milk feeds**, with the newborn timer, nappies and pumping | Starting solids: the first spoon, what to feed today, can he eat this, gagging vs choking |
| 10 months | **Milk feeds** | Starting solids and Cooking: textures, finger food, recipes |
| 18 months | **Milk feeds**, with 5 newborn tools, mastitis and 20 untagged pages | Meals and recipes, fussy eating, cow milk, bottle to cup |
| 3 years | **Milk feeds** (the same) | Meals, tiffin, "he won't eat", sweets and packets |

**Why it happens:**
1. The door always opens on the first tab in file order (`pp_door_screen.dart:160`).
2. 41 of the 60 pages have no age tag. An untagged page counts as fitting every band (`PpPage.inBand`, `pp_section_screen.dart:274`).
3. The tools have no age at all.
4. The consults are foot tiles at the end of each read, because of a 2026-09-18 decision: "a consult is a foot tile, not a purple button mid-piece" (`pp_page_read.dart:211`). The door's "Talk to a lactation expert" closing is never drawn.

**Door type: action**, with an explain side.
- Feeding is something she does several times a day: feed, log, cook, serve. So an action leads each tab: a tool, a demo video, a recipe.
- Then the explanation: the problem pages (supply, mastitis, refusal, not eating). Each problem page gets an expert placed **next to the worry**, not at the end.

---

## 2. The new door, band by band

### 2a. Tab order per band (new `PpDoor.tabOrder`, step 0 · S1)

| Band | Tab order (the first one opens) |
|---|---|
| milk 0–6m | Milk feeds · Growing well · Keeping it safe · (Starting solids, locked "From 6 months") · (Cooking, locked) |
| first_foods 6–8m | **Starting solids** · Milk feeds · Keeping it safe · Cooking · Growing well |
| m8_12 | **Starting solids** · Cooking · Keeping it safe · Milk feeds · Growing well |
| tod 12–24m | **Cooking** · Growing well · Keeping it safe · Starting solids · Milk feeds |
| big 24m+ | **Cooking** · Growing well · Keeping it safe · Milk feeds (Starting solids has dropped: past) |

- **Mechanism:** `PpDoor.tabOrder: Map<String bandId, List<String tabId>>`, read in `_tabs`.
  - A band missing from the map keeps the file order.
  - Locked tabs still go last and past tabs still drop (the current rules).
- It is explicit data, not a score, so the test can hold it row by row.

### 2b. Tab labels (one label change, **user decision D1**)
- "Growing well" holds weight gain **and** "my child isn't eating". For a toddler's parent, not eating is the number one worry, and the label hides it.
- Proposal: **"Eating and growing"**. The other four labels stay.

### 2c. Tools get ages (new `PpDoorTool.bands`, null = every band)
- A tool outside her band leaves the first rail and moves into the folded "earlier" band block on that tab. It is still reachable, never deleted.
- Tab order is changed in step 0. The tool ages, and where each tool sits, are new in this door.

| Tool | Bands | Placement |
|---|---|---|
| Breastfeed timer | milk, first_foods | Leads the Milk rail |
| Log a feed | milk → tod | Second on the Milk rail |
| Nappies | milk | After `bf_how_often` ("is he getting enough" → count the nappies), using `afterPageId` |
| Pumping | milk → m8_12 | After `bf_pumping` |
| The last 7 days | milk → m8_12 | `atEnd` |
| What to feed at this age | first_foods → big | Leads Starting solids. **Also leads Cooking for tod and big**, where Starting solids is gone or sunk. This means a tool can sit on two tabs, and the test allows it. |
| Can my baby eat this? | first_foods → big | Second on Starting solids. Also on Cooking for tod and big (whole nuts and grapes stay a risk until 5). |
| Recipes by age | first_foods → big | Leads Cooking |
| Track growth | every band | Leads Growing well |

### 2d. Every page's age tag (the core of this door)

Codes: M = milk 0–6m, F = first foods 6–8m, E = 8–12m, T = toddler 12–24m, B = 2y+.
"was —" means the page had no tag and was shown at every age.
The next band always shows open as "Coming up next". So a 5-month-old's parent still sees "When to start solids" without it being tagged M.

**Area tags** (these lock or drop whole tabs):
- `starting_solids` → F, E, T. Locked for M, past for B.
- `cooking` → F, E, T, B. Locked for M.
- `not_eating` → E, T, B.
- `breastfeeding`, `formula`, `weight_gain`, `safety` → untagged (every band). Their pages carry the tags.

**Feeding at the breast:**

| Page | Was | New |
|---|---|---|
| bf_latch | M F | M F (unchanged) |
| bf_positions | M F | M F (unchanged) |
| bf_how_often | — | M F |
| bf_supply | — | M F E |
| bf_diet | — | M F E T |
| bf_pumping | — | M F E T |
| bf_low_supply | — | M F E |
| bf_oversupply | — | M F |
| bf_mastitis (red flag) | — | M F E T. The pin only shows when the page is in her band. |
| bf_cracked | — | M F |
| bf_biting | E T B | **F** E T (teeth arrive around 6 months) |
| bf_refusing | — | M F E |
| bf_benefits | M F E | unchanged |
| bf_lactation_help | — | M F E |
| bf_toddler | T B | unchanged |
| bf_relactation | — | M F |
| bf_exclusive_pumping | M F E | unchanged |
| bf_special_situations | — | M F |

**Formula, bottles and doing both:**

| Page | Was | New |
|---|---|---|
| formula_fed_is_fine | — | M F |
| formula_choose | — | M F E |
| formula_prepare | — | M F E |
| formula_brands | — | M F E |
| formula_switching | — | M F E |
| formula_mixed | — | M F |
| formula_bottle_refusal | — | M F E |
| formula_weaning | — | F E T B |
| formula_amounts | M F E | unchanged |

**Starting solids:**

| Page | Was | New |
|---|---|---|
| solids_when | — | F |
| solids_first_foods | — | F E |
| solids_spoon_or_blw | — | F E |
| solids_allergens | — | F E T |
| solids_textures | — | F E T |
| solids_annaprashan | — | F |
| solids_setup | M F | F (M sees it as "Coming up next") |
| solids_constipation | F E | unchanged |

**Cooking for your child:**

| Page | Was | New |
|---|---|---|
| recipes_by_age | — | F E T B |
| recipes_staples | — | F E T B |
| recipes_by_need | — | F E T B |
| recipes_sick_days | — | F E T B |
| recipes_batch | — | F E T B |
| recipes_meal_ideas | — | F E T B |
| recipes_tiffin_snacks | T B | unchanged |

**Weight gain:**

| Page | Was | New |
|---|---|---|
| weight_foods | — | F E T B |
| weight_fats | — | F E T B |
| weight_too_thin | — | every band (stays untagged) |
| weight_chart_reading | — | every band (stays untagged) |

**Not eating:**

| Page | Was | New |
|---|---|---|
| picky_not_eating | — | E T B |
| picky_who_decides | — | E T B |
| picky_food_jags | — | T B |
| picky_battles | — | E T B |
| picky_sweet_packet | T B | unchanged |

**Keeping feeding safe:**

| Page | Was | New |
|---|---|---|
| safety_choking | — | F E T B |
| safety_avoid_under_one | — | F E |
| safety_allergy | — | F E T |
| safety_iron | — | F E T B |
| safety_water | — | M F E T |
| safety_choking_response (red flag) | — | F E T B |
| safety_gagging | — | F E T |
| safety_vitamin_d | — | M F E T |

**One tagging rule to write down:** a page about the **mother's** body while breastfeeding (diet, pumping, mastitis) is tagged by how long she may still be feeding, not by the baby's stage. That is why those pages run to T.

### 2e. Red flags across tabs
- **Milk feeds:** mastitis stays pinned while the page is in her band (M → T).
- **Starting solids:** pins "If he chokes: what to do" too.
  - `pageById` reads the whole section (`pp_door_screen.dart:453`), so this works with no shell change.
  - Reason: a 7-month-old's parent opens on Starting solids, and choking must be one tap away from the first spoon, not on tab 3.
- **Keeping it safe:** keeps the same pin.
- **Gagging vs choking** (a carousel) is added to Starting solids as a `PpLink` card. One source, two doors in.
  - Needs: a door tab may name a page from another area. Proposal: `PpDoorTab.extraPageIds`, drawn in the first rail, after the tools.

---

## 3. Experts, classes and products next to the worry

### 3a. Consults: where they sit
- Today: 10 `PpConsult` blocks, all drawn as foot tiles at the end of the read.
- The user's ask (2026-10-23) is that a consult sits next to the worry. That **reverses part of the 2026-09-18 call**, which was a reaction to a *purple button in the middle of a piece*.
- The reconciliation (**user decision D2**):
  - The consult moves to the shared reader's **existing offer slot**: the calm offer card the reader already places after the second section for Pregnancy and TTC reads (`pv_reader_screen.dart:586`). It is not a purple button.
  - It also stays in the foot tiles.
  - On a page that has its own `PpConsult`, the slot uses that consult instead of the generic matcher. So one page gets one pitch, never two (step 0 · S6).
  - The slot sits after the "when it needs a doctor" callout. On these pages that callout comes in the first three blocks.
- The 10 pages and their expert:

| Page | Expert |
|---|---|
| bf_latch | Lactation |
| bf_low_supply | Lactation |
| bf_oversupply | Lactation |
| bf_mastitis | Lactation, under the same-day doctor line, never above it |
| bf_cracked | Lactation |
| bf_refusing | Lactation |
| formula_mixed | Lactation |
| weight_too_thin | Paediatric nutritionist |
| picky_battles | Paediatric nutritionist |
| safety_iron | Paediatric nutritionist |

- **Add a consult to 4 problem pages that have none:**
  - `bf_supply`, `bf_lactation_help` (lactation)
  - `picky_not_eating`, `solids_allergens` (nutritionist; for allergy, the paediatrician line comes first)
- **Never on:** the choking response, gagging, or allergy-reaction pages. Those are urgent pages: they route to 112 or a doctor and are not sold to.

### 3b. An expert row on the tab itself (step 0 · S3, per tab)
- New `PpDoorTab.expert` (a `PpDoorClosing`). It is drawn right after the red flag and the first rail.
- **Milk feeds:** "Talk to a lactation expert · 1:1, video". Goes to `pp_experts/Lactation expert` (3 seeded IBCLC and CLC experts).
- **Starting solids, Cooking and Eating and growing:** "Talk to a child nutritionist". Goes to `pp_experts/Nutritionist` (2 seeded).
- **Keeping it safe:** none. The door's closing line stays as the foot.

### 3c. Classes and courses

| Offer | Exists? | Where it goes |
|---|---|---|
| Breastfeeding Basics masterclass (`mc_bf`, ₹699 / ~$8.40) | Yes, but its copy is **written for before birth** ("before baby arrives") | Milk feeds, M band. **Decision D3:** add postnatal copy, or leave it off parenting. |
| Lactation service (`sp_lactation`) and nutrition service (`sp_nutrition`) | Yes | Behind the expert rows above |
| A "Starting solids" live class or course | **No** | **Owed.** A catalogue entry (price, coach, date) is a server-side money decision. Listed for the user, not invented. |
| A "Fussy eater" toddler workshop | **No** | Owed, same as above |

### 3d. Products (the IMS Act rule holds: never formula, bottles or teats)

| Page | Product slot | In the catalogue today? |
|---|---|---|
| bf_positions | Nursing pillow | Linked today (`pp_products`). Check it resolves. |
| bf_pumping | Breast pump, storage bags | Linked today |
| bf_cracked | Nipple cream | Linked today |
| solids_setup | High chair, bibs, first spoons | `spoons` (First Spoons Weaning Set) exists. High chair and bibs **owed** in the catalogue. |
| solids_first_foods | First spoons, suction bowl | spoons yes, bowl **owed** |
| recipes_batch | Food steamer, freezer trays | Linked today (`pp_products`). Steamer **owed** as a named product. |
| recipes_tiffin_snacks | Tiffin box, sippy or open cup | **Owed** |

- **Compliance flag (outside this door, goes to `docs/BEFORE-LAUNCH.md`):**
  - `kPpProducts` sells an **"Anti-Colic Feeding Bottle"** (`pp_products_data.dart:581`). The Feeding file's own IMS Act rule says bottles are never promoted.
  - The "Steam Steriliser" (`:633`) is a bottle accessory and needs the same legal read.
  - These products are not linked from this door. They can still surface on the home "Useful at this age" rail.

---

## 4. Videos and demos
- **Door intro video:** the Option A chip ("▶ How this door works · 0:50"), slot `feeding/door_intro`. The chip is built in step 0 · S4. The film is owed.
- **The 11 video pages already in the door** stop saying "Article" and show "Video · coming soon" (step 0 · S5):
  - latch, positions, pumping, "three mothers on formula", making a bottle
  - first spoon, safe textures, khichdi cook-along, the too-thin paediatrician
  - four parents on not eating, cut-it-this-way
  - Plus the back-blows film, which lives on Health's page.
- **New demos the action side needs.** Each is a `PpVideoSlot` on an existing page, with no new pages:
  1. Paced bottle feeding (`formula_mixed`, `formula_bottle_refusal`)
  2. Finger foods at 9 months, cut and served (`solids_textures`, E band)
  3. Moving to an open cup (`recipes_tiffin_snacks` or a new section on `formula_weaning`)
  4. Making ragi porridge, 3 textures (`recipes_staples`)
- **Every film is listed in `DOOR-CONTENT-OWED.md` P2:** slot id, page, length and a one-line brief. Rows FD5 onward.

---

## 5. Depth: thin pages, missing topics, duplicates

**Thin pages (under ~1,000 characters of text) to deepen**, keeping the same voice and REQUIRED_REVIEW on every clinical number:

| Page | Length | What to add |
|---|---|---|
| bf_benefits | 705 | Keep it short, it is a card page. Add the "without guilt" line and a link to "fed is fine". |
| bf_exclusive_pumping | 701 | Schedule by age, how to keep supply up, when to see lactation |
| bf_toddler | 874 | Night feeds, the opinions of relatives, gentle weaning steps |
| bf_lactation_help | 940 | Who is who (IBCLC vs counsellor vs doctor), what a session costs (₹ and $) |
| bf_special_situations | 949 | Donor milk banks in India, what to ask the surgeon |
| bf_relactation | 1,051 | Steps, how long it takes |
| recipes_tiffin_snacks | 1,058 | 10 tiffin ideas, packaged-snack labels |

**Topics the door does not cover** (searched the file 2026-10-23):
- **"Health drinks" (Horlicks, Bournvita, malt powders): zero mentions.** This is a big Indian marketing pressure on toddler parents. New page `picky_health_drinks`, T B, in the not-eating area: what is in them, sugar, when not to bother.
- **Feeding at daycare or with a nanny:** 4 passing mentions. New section on `bf_pumping` and on `recipes_batch`.
- **Fasting and festival food with small children:** 1 mention. A section on `recipes_meal_ideas`. Tradition-aware, never prescriptive.
- Already covered, no action: cow milk at 1 (18 mentions), cups (12), reflux and spit-up (23, mostly in Health), teething (12).

**Duplicates:**
- "Getting the latch right" exists in Feeding (`bf_latch`) and in First 40 (`f40_latch`, a full STEP-LIST). Two texts will drift.
  - Proposal: First 40's card becomes a `toolSurfaceId` reference to `pp_page/parenting_feeding/bf_latch`, kept as a comment for revert. Done in **this** door's pass, because Feeding is the canonical source.
- `weight_chart_reading` and `safety_choking_response` each have a commented-out older body. Leave them; that is the comment-out rule.

**Open from earlier passes (STILL-OPEN §41 and PARENTING-DOORS-REVIEW):**
- **FD4:** the allergen walk-through forgets everything when closed. Persisting it needs a `pp_allergen_intros` table (child-scoped, RLS) plus a store. That is backend work: **decision D4**, and if yes, it is its own step that also gets logged in the sync docs.
- **Keep `picky_sweet_packet` and `bf_biting`?** Recommend **keep**. Both are real worries, and both are now tagged to the right band.
- **Clinical read** of the choking sequence and the formula-amounts chart. Still owed. It goes to `BEFORE-LAUNCH.md`.
- **`PpChartBrowserScreen` retirement:** not this door's job. Leave it.

---

## 6. The build, in order (after the user's go)
1. **Data, door map** (`pp_door_feeding.dart`): `tabOrder`, tool `bands` and placement, Starting solids' second red flag and gagging card, per-tab `expert`, the D1 label, `introVideoSlot`.
2. **Data, content** (`pp_feeding_content.dart`):
   - the area and page tags from §2d
   - 4 new consult blocks
   - the product slots from §3d
   - 4 new video slots
   - 7 deepened pages
   - 1 new page (health drinks) and 3 new sections
   - REQUIRED_REVIEW on every new clinical line
3. **First 40:** the latch card points to Feeding's page (old body commented out, "kept for revert").
4. **Test** (`test/pp_feeding_door_test.dart`), kept up to date, holding:
   - the tab order per band (5 rows)
   - every page's band tags (the §2d table as data)
   - tool bands and positions
   - both red flags on Starting solids
   - expert rows per tab
   - no consult on an urgent page
   - no `pp_products` link from the formula or bottle pages (the IMS Act rule, scanned from source)
5. **First-view test** (step 0 · S7): Feeding at 2m, 7m, 10m, 18m and 30m. For each: opening tab, first rail's first card, and expert row present.
6. **Mobbin check** before the build, for the per-tab expert row and the tool-on-two-tabs pattern.
7. **Prototype** (Artifact, light mode) for the 7-month and 18-month first views. **The user approves it before any `lib/` edit**, because the layout order changes.

## 7. Verification
- Run:
  - `flutter test test/pp_feeding_door_test.dart test/pp_doors_sanity_test.dart test/pp_relevance_test.dart test/pp_doors_first_view_test.dart test/pp_care_screens_test.dart test/read_offer_coverage_test.dart`
  - `flutter analyze` on the touched files
- **Wiring gate:** grep `tabOrder`, `bands:` on `PpDoorTool`, `expert:` and `extraPageIds`, each in the screen, and confirm they are read, not just declared.
- Phone walk, on the user's word only: set the child's age to 2m, 7m, 10m, 18m and 3y in turn (the Developer card), open Feeding, and check the first view against §2a.

## 8. Docs in the same change
- `DOOR-CONTENT-OWED.md` P2: the new film rows and the owed catalogue items.
- `PARENTING-DOORS-REVIEW.md` §41: the new checklist.
- `STILL-OPEN.md` §41: the 2026-10-23 rework.
- `GLOBAL-CHANGES.md` #15: Parenting Feeding done.
- `BEFORE-LAUNCH.md`: the bottle and steriliser IMS Act check, and the clinical read.

## 9. Decisions (answered by the user 2026-10-23)

The user's own words, where recorded: D2, *"yes, D2 approved, go for Health"*, after asking for a plain phone-mockup look instead of a design canvas.

| # | Question | Answer |
|---|---|---|
| D1 | Rename "Growing well" to "Eating and growing" | **Yes.** It must read at a single glance. |
| D2 | A consult sits next to the worry (the reader's calm offer card) as well as at the foot | **APPROVED 2026-10-23.** Look approved on `claude.ai/artifact/6Kgs3uNdKsbyKybfbdzdRB` (replaces the canvas TYhefJDisNSxic3cmaqPet): the grey offer card under the doctor box on the read, the foot tile kept, and one "Talk to a lactation expert" row after the first rail on Milk feeds (none on Safe). The door header order is back, title, headline, age line, intro chip, then search. |
| D3 | Breastfeeding Basics after birth | **Yes**, a postnatal copy. See `01-feeding-content.md` A3. |
| D4 | Allergen tracker that remembers | **Yes, as its own later step** (store + `pp_allergen_intros` table, RLS, local-first) |
| D5 | Missing offerings | **Yes, researched for India, every age:** `01-feeding-content.md` Part A. That covers the IMS Act rule, 26 products, and 8 classes/workshops/courses plus a new feeding therapist. No prices invented. |
| D6 | Health drinks page, daycare and festival sections | **Yes, fully.** Copy is written in `01-feeding-content.md` Part B, ready to go into the code. |

## 10. Costs
None. No paid API or service is used. The films are owed content, and their cost is quoted when they are briefed (USD + INR).
