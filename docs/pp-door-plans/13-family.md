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
