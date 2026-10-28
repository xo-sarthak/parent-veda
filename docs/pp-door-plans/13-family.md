# Door 13: Family, the plan

Written 2026-10-25. **Status: final. The plan was accepted 2026-10-25, and FM1 to FM5 are chosen and recorded under the user's rule (obvious decisions aren't asked). FM6 (2026-10-25, found by the Papers audit) withdraws the back-to-work page in favour of links to You, Maa.** The new copy is in `13-family-content.md`. Nothing in `lib/` changes until step 0 (S1 to S11) and the user's go.

## Context
**Where it lives.**
- The door: `lib/data/doors/pp_door_family.dart`
- The content: `pp_family_content.dart`, 16 pages on 5 tabs, written 2026-10-02, warm and practical

**Tabs:** A second baby · For fathers · Grandparents · Brothers and sisters · Who looks after your child.

**Kept on purpose:**
- the fathers' pages (low mood, the night shift, paternity leave, a partner's anxiety)
- the safety callout on couple disagreements
- the "no best age gap" stance

### What parents actually ask
From `research/questions/ranked_parenting.csv`:

| Topic | Hits | Top questions | What it means |
|---|---|---|---|
| Daycare and creche, settling in | 34 | how much crying is too much at daycare; will this get better | `fam_settling_in` covers it, but links nothing |
| Back to work | 4, but specific | "I have to join office, she won't take a bottle"; how do working mothers keep breastfeeding | No page in Family. **Corrected 2026-10-25:** You, Maa's `back_to_work` area (7 pages) already answers it, so Family links there (FM6) |
| Fathers | 38 (noisy) | — | Covered |
| Siblings, second baby | 23 | toddler hitting a sibling | Covered; link Behaviour |
| Grandparents, MIL | 5 | how to tell my MIL you can't spoil a newborn | Covered; link Behaviour's scripts (BH2) |
| Couple after baby, single parent, adoption | 0–3 | sex drive while breastfeeding; "husband passed away, how do single parents do anything" | Rare, but deep when it is asked |

**Overall:** family topics are rare in search. The pool leans to health. So no big new tabs: fix the structure, add the links, and add a few short pages where the need is real.

### What a parent meets today
1. **Every age opens on "A second baby"**, including a mother of a 2-month-old. Only 1 of 16 pages has an age tag.
2. **0 links anywhere in the section.**
   - Sibling jealousy doesn't reach Behaviour.
   - The breastfeeding pages don't reach Feeding.
   - Paternity leave doesn't reach Papers.
   - Grandparents doesn't reach Behaviour's "When elders discipline differently" or the "What to say" scripts.
   - Fathers' low mood has no helpline.
3. **Missing:**
   - ~~going back to work~~: corrected 2026-10-25, You, Maa has it (FM6); the gap was the missing link
   - you two after the baby
   - a single parent
4. **"Who looks after your child"** (26 characters) runs to three lines on its card.
5. **Picture books:** 10 new-sibling picture books in the kids library, and none linked.
6. **No films, no hero photo, no intro.** The closing isn't drawn (S3).

## FM1. Each age opens on what fits
**Tab order by age** (S1):

| Age | Order |
|---|---|
| 0–12 months | Grandparents, Care while you work, For fathers, A second baby, Brothers and sisters |
| 1–6 years | A second baby, Brothers and sisters, Care while you work, Grandparents, For fathers |

**Tags** (S2):
- the fathers' newborn pages (night shift, bonding, breastfeeding help) go to 0–12 months
- tandem feeding goes to 1 year and up

## FM2. Links, the section's biggest gap

| From | To |
|---|---|
| `fam_sibling_jealousy` | Behaviour `siblings`, `beh_anger`, Potty's regressions page |
| `fam_telling_toddler`, `fam_getting_ready` | new-sibling picture books (kids library), Behaviour `separation` |
| `fam_tandem_feeding`, `fam_dad_breastfeeding` | Feeding's latch and supply pages |
| `fam_dad_depression` | **Tele-MANAS 14416** added to its callout; You, Maa `mind_rage` |
| `fam_dad_leave` | You, Maa `work_your_entitlement` (it covers paternity and child care leave too). Corrected 2026-10-25: Papers has no leave page and doesn't add one (Papers PM2) |
| `fam_grandparents_help` | Behaviour `beh_elders`, the "What to say" family scripts (BH2), Traditions `family_pressure` |
| `fam_couple_on_same_page` | the new "You two" page (FM3) |
| `fam_settling_in` | Behaviour `separation`; Health vaccines (a creche asks for the card) |

## FM3. Two short pages where the need is real (copy in `13-family-content.md`; REQUIRED_REVIEW)
- ~~**"Going back to work"** (0–12 months), on Care while you work~~ **Withdrawn 2026-10-25 (FM6).** It repeated You, Maa's `back_to_work` area. Kept below for the record:
  - getting him used to a bottle or cup, two to three weeks before
  - pumping and storing milk at work
  - the right to 26 weeks of paid maternity leave and a creche, under the Maternity Benefit Act
  - nursing breaks
  - the first-week plan with the carer
  - the guilt

  Links: Feeding's pumping and storage pages; Papers.
- **"You two, after the baby"** (every age), on Grandparents, next to the disagreements page:
  - less sleep, more arguments, and what helps
  - sex and intimacy when you're ready: low desire while breastfeeding is common
  - contraception (links You, Maa)
  - ten minutes a day just for you two
- **"Doing it on your own"** (every age), on For fathers (the tab keeps its name, FM4):
  - the single mother or father
  - asking for help without apology
  - the money and the papers (links Papers)
  - looking after yourself
  - the free helpline

## FM6. Back to work: link to You, Maa, don't repeat it (2026-10-25)
The Papers audit found that You, Maa's `back_to_work` area (`pp_you_maa_content.dart:6176`) already has seven pages: planning the return four weeks out, including the bottle given by someone else; the leave entitlement; the milk stash; pumping with no room; childcare; the guilt; and the first week back. A second page in Family would be two answers to one question, and they would drift apart.

So the Care while you work tab gets a link group, "Going back to work", on `fam_choosing_care`, linking to:
- `work_planning`
- `work_your_entitlement`
- `work_milk_stash`
- `work_pumping_no_room`
- `work_first_week`

They are linked by page (M4), so a father or a grandparent finds them too. The copy in `13-family-content.md` §1 is withdrawn. Its one extra, "many babies refuse the bottle from their mother", is already in `work_planning`.

## FM4. Names
- "Who looks after your child" becomes "Care while you work". The old label stays commented out.
- **"For fathers" stays.** "Fathers, and on your own" fits two lines at normal text but runs to three at a large text size (S11). The new page's own title carries "on your own", and the tab blurb mentions it.

## FM5. Help, films and the hero
- **The closing "Talk to a child psychologist"** is drawn (S3). Experts aren't live, so a tap opens "experts joining" (S8e).
- **The door intro film** `family/door_intro`; a tap says "still being made" (S8a).
- **A hero photo** (Unsplash, free): a family on the floor, an older child holding the baby's hand.

## Taps that can't happen yet (S8)

| Target | What she sees |
|---|---|
| The intro film | "still being made" |
| Child psychologist | the "experts joining" page |

## Build order (after step 0 and your go)
1. Tags and tab order
2. Links
3. The two pages, and the FM6 links
4. Names
5. Closing, film and hero

**Reuse:**
- the S1 tab order
- M4 `PpLink.pageId`
- the kids library (`kids_books_list.dart`, New Sibling)
- `pvToast` S8a/e
- the Tele-MANAS line used in First 40 and Behaviour

## Verification
- `test/pp_gap_doors_test.dart` for this door:
  - the opening tab at 0–12 months and 1–6 years
  - every link resolves
  - the two new pages are reachable, and the Care tab's links reach You, Maa's work pages
  - the dad-depression callout carries 14416
- `door_names_fit_test`
- `flutter analyze` on touched files
- grep call sites

## Decisions
These stay here on purpose. When a problem turns up later, check this table first: if an answer covers it, the fix follows that answer.


| # | Decision | Why (what parents want) | Answer |
|---|---|---|---|
| FM1 | Babies open on Grandparents; 1–6 open on A second baby | A 2-month-old's mother doesn't need the second-baby tab first | **Yes**, chosen and recorded (2026-10-25) |
| FM2 | Link every page to the door that answers the next question | The section has 0 links today | **Yes**, chosen and recorded (2026-10-25) |
| FM3 | Back to work, you two, and on your own | Real Indian questions (the bottle before office) with no page | **Yes**, chosen and recorded (2026-10-25) |
| FM4 | "Care while you work" | The old name runs to three lines | **Yes**, chosen and recorded (2026-10-25) |
| FM5 | Closing drawn, intro film, hero | Plain fixes | **Yes**, chosen and recorded (2026-10-25) |
| FM6 | Withdraw the back-to-work page; link the Care tab to You, Maa's seven work pages | One answer per question; the Papers audit found the duplicate | **Yes**, chosen and recorded (2026-10-25) |

## As built (2026-10-26)
Held by `test/pp_family_door_test.dart` (16 tests): the tab order for every band; every page's age (a new page fails until it has a row) and none outside its area's; the first view at 3 months (Grandma, grandpa, no second-baby page) and at 30 (A second baby); **every link in the door, listed exactly, page by page**, each landing on a real page whose title is its label; the three script links opening What to say on that script (`ScriptsLibraryScreen.initialScriptId`); the picture books opening the New Sibling shelf (`PpKidsBooksScreen.goal`), never the whole library; the Care tab holding no back-to-work page of its own (FM6); Behaviour's and Potty's links back to sibling jealousy; the two new pages, where they sit and what they leave to You, Maa; the pages kept on purpose; Tele-MANAS its own card after the doctor box on all three pages that carry it, from the constant, and 14416 typed nowhere in the live source; the tab names; the closing opening the child psychologists' own list (`ProviderResultsScreen.need.category`), drawn and tapped on screen; no film slot; the hero. `door_names_fit_test` measures both new names (fit at 1.0 and 1.3; both off `_kOwedShorterNames`, the old entries commented out). The parenting stage passes (`test/pp_*`, `post_pregnancy*`, `phases_test`, `door_names_fit_test`, plus `reader_unification_test` and `consult_call_test`: 133 files, 1,495 tests), and so does `bracket_model_test`, the one test outside it that reads the Family section.

**The shell: nothing new.** `tabOrder` (S1), the closing card (S3), `pp_page/<section>/<page>`, `pp_scripts/<id>` and `pp_books/<goal>` covered everything. The door is data plus copy, as doors 10 to 12 were.

**What was built, by decision:**
- **FM1.** The tab order per band as the plan's table. The fathers' night shift, bonding and breastfeeding-help pages are tagged 0 to 12 months; tandem feeding from one. Before tagging, the links into them were checked: the tips that open the night shift and bonding pages (`nb_dad_bath`, `w6_help_dad`) are newborn tips, and the father card's night-shift link opens the page directly, which a tag does not stop.
- **FM2.** Every page the plan names links on, by page: sibling jealousy to Behaviour's `siblings` and `beh_anger` and Potty's `regressions` (all three already linked back); telling your child to the New Sibling picture books; getting ready to Behaviour's `separation` and the books; tandem feeding and the father's breastfeeding page to Feeding's `bf_latch` and `bf_supply`; fathers' low mood to You, Maa's `mind_rage`; paternity leave to `work_your_entitlement`; grandparents to Behaviour's `beh_elders`, the `family_spoiling` and `family_honey` scripts and Traditions' `family_pressure`; the disagreements page to the new "You two"; settling in to Behaviour's `separation` and Health's `vax_uwin`, with a step "Keep the vaccination card ready".
- **FM3.** Two new pages, each holding only what was missing (below). Neither is tagged: in this section an untagged page reads as every band, which is what the plan asked.
- **FM6.** `fam_choosing_childcare` gains "Going back to work": one line, then the five You, Maa pages, linked by page.
- **FM4.** "Care while you work"; "For fathers" stays and its area blurb now ends "and parents on their own". "Grandparents" is "Grandma, grandpa" (below).
- **FM5.** The closing card was already drawn by the shell since step 0 (S3); checked, not rebuilt. Hero: Unsplash, free (Samar Ahmad, `qtlW4e80RAA`), an older brother smiling with his baby brother on his lap at home, checked by eye. No intro film slotted (S4).
- **Tele-MANAS, two doctor boxes fixed.** `fam_dad_depression` (as the plan asked) and `people_partner_anxiety` (found in passing) both had "call Tele-MANAS on 14416" typed inside a doctor box. Each doctor line now names the doctor and the hospital only, and "If there is nobody to talk to" is its own card after it, from `kCrisisHelplineName` / `kCrisisHelplineNumber`, as Behaviour, Traditions and Special care draw it. The fathers' card says "Fathers call too". The old callouts are commented out, kept for revert.

**A mechanism worth keeping: the twin was in another door, under a name the plan did not search.** The plan asked for "You two, after the baby" (the fights, dividing the jobs, ten minutes a day, sex and low desire, contraception, safety) and "Doing it on your own" (asking for help, the papers, maintenance). A grep of every door's titles found that You, Maa's "The people around you" area already had nearly all of it: `people_partner` (dividing the work out loud, "ten minutes a day that is not about logistics"), `people_intimacy` (sex, dryness while breastfeeding, closeness, and contraception with its three conditions), `people_safe_at_home`, `people_asking_for_help` ("Asking for help without apologising for it", the plan's own words) and `people_separated` (a mother on her own from the start: the back-up person, the birth certificate, maintenance, NALSA). Written as the plan had them, the two pages would have been a second answer to five questions, and the first reviewer's correction to one would never reach the other. So "You two" holds the fights (why there are more, one thing at a time, say what you need, make up out loud) and one card on low desire, then links You, Maa for the rest; "Doing it on your own" holds a father on his own, the small circle, the papers a single parent signs alone, one thing that's yours, and losing a partner, then links You, Maa and Papers. The general point, from door 12 again: search for the *idea* in every door, not for the page ids a plan names. The plan searched Family and Papers; the answer was in You, Maa.

**A second one: a link test that lists the links.** Doors 11 and 12 found that a fallback target (the whole shop, the whole roster) passes every link gate. This door's test goes one step further and lists every link in the door, page by page. A new link fails until it has a row, so nobody can add `pp_books` (the whole library) or `pp_experts` (the whole roster) and have it pass because "it lands". The cost is a row to write per link; the gain is that the list is the review.

**Differences from the plan, and why:**
| Plan | Built | Why |
|---|---|---|
| FM3 "You two": the fights, divide it out loud, ten minutes a day, sex and closeness, contraception, safety | The fights (four cards) and one card on low desire; `people_partner`, `people_intimacy` and `people_safe_at_home` linked; the safety line kept as this page's own callout | You, Maa owns the rest (single source). See the mechanism above |
| FM3 "Doing it on your own": ask for help, maintenance and scheme papers | Asking for help kept as one step, with You, Maa's page linked; maintenance and legal aid left to `people_separated`, linked; Papers' birth certificate and will pages linked for guardianship | The same: You, Maa's pages already say them, NALSA included |
| FM3 "Doing it on your own" callout: doctor and Tele-MANAS in one sentence | A doctor callout, then Tele-MANAS as its own card | BH4 rule c: a helpline is never inside a doctor box |
| FM2: "14416 added to fam_dad_depression's callout" | Its own card after the doctor box, from the constant | The user's brief, BH4 rule c. The page already had 14416 typed in the doctor box; that is commented out |
| FM2: `fam_telling_toddler` and `fam_getting_ready` both to the books and `separation` | Telling: the books. Getting ready: `separation` and the books | Telling has no step about being apart; getting ready has the days in hospital, which is when separation starts |
| FM2: `fam_settling_in` to "Health vaccines" | `vax_uwin` ("U-WIN: his vaccines, on the government record") | The page that gives the downloadable certificate a creche asks for. The label keeps the page's title |
| FM2: "Feeding's latch and supply pages" | `bf_latch` and `bf_supply` on both pages; also the `family_milk` script on the father's breastfeeding page | Its "Stand together" card quotes the exact words that script answers ("your milk is not enough") |
| FM2: "the What to say family scripts (BH2)" on the grandparents page | `family_spoiling` and `family_honey` | The two that match the page (a little indulgence; holding firm on honey and ghutti). `family_milk` sits on the father's page. Labels in the page's voice ("the baby", not "him") |
| Reuse: "M4 `PpLink.pageId`" | Every link, own pages included, is a `pp_page/parenting_family/<id>` surface | `pp_gap_doors_test` asks every link for a screen through `surfaceId!`; door 12 crashed on exactly this |
| FM6: link group on `fam_choosing_care` | On `fam_choosing_childcare`, under a one-line "Going back to work" | That is the page's id. A link block has no heading of its own, so a one-line article names the group |
| §4: "Most creches ask for his vaccination card" | "your child's" | The page's voice |
| FM4: "Grandparents" unchanged (not in the plan) | "Grandma, grandpa", the old label commented out | `door_names_fit_test` had it on `_kOwedShorterNames`: at 1.3 the one word is wider than the line and breaks mid-word. Measured (Manrope 700, 100pt line) against "The joint family", "Elders and you two" and "Living with elders"; the user's choice, 2026-10-26 |
| FM5: door intro `family/door_intro` | Not slotted | S4: no chip until a film exists. Owed FMO1 |
| Verification: "the dad-depression callout carries 14416" | The card carries `kCrisisHelplineNumber`; the doctor box carries neither the name nor the number | As above |
| Verification: a Mobbin check, a prototype | Not run | The user's brief for this build; no new layout |
| Verification: a phone walk | Not run | Only on the user's word |

**Owed, not in this build:** the intro film (`DOOR-CONTENT-OWED` FMO1) and real child psychologists (FMO2, the same people as BHO7 and SPO4). No book, shop or class is promised. On `BEFORE-LAUNCH.md`: a child psychologist's read of the family and fathers' pages, a gynaecologist's of the one sex line and the age-gap contraception callout, and a legal check of paternity leave, the creche rule, a single parent's papers and nanny verification against current government notices. The new pages reach Ask Veda through the incremental ingest, which the user runs after all the doors.

**Final review, item 7 (2026-10-27): twin pages link each other.** Five Family pages link their You, Maa twin, and each twin links back: `fam_age_gap`, `fam_choosing_childcare`, `fam_dad_depression`, `fam_grandparents_help`, `fam_you_two` and `people_partner_anxiety`. On `fam_age_gap` the caesarean line now says the two-year wait matters even more, with eighteen months as the shortest gap most doctors accept, not a target (it read as a shorter wait). `fam_dad_depression` is `aboutAdult`: it is written to the father, and its new link says "When he is struggling too". Held by `test/pp_twin_links_test.dart`.

**Final review, item 8 (2026-10-28): single-page fixes.** On `fam_grandparents_help`, honey left the "Nothing but milk before six months" card, where it read as fine after six months, and has its own: "No honey before one year. Not even a lick, and not in ghutti." Held by `test/pp_single_page_fixes_test.dart`.
