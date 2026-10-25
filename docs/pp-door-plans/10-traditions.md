# Door 10: Traditions, the plan

Written 2026-10-25. **Status: plan accepted 2026-10-25. TR1 to TR6 are chosen and recorded (the user's rule: obvious decisions aren't asked). TR-Q approved by the user the same day.** The new copy is in `10-traditions-content.md`. Nothing in `lib/` changes until step 0 (S1 to S11) and the user's go.

## Context
**Where it lives.**
- The door: `lib/data/doors/pp_door_traditions.dart`
- The content: `pp_traditions_content.dart`, 32 pages
- Its own four ages: 0–4 months, 4–12 months, 1–3 years, 3–6 years

**Tabs:** Coming up now · Welcoming baby home · The first years · In every faith · Small, safe and honest.

**Kept on purpose:**
- "Coming up now" opens first with this age's chart, which is the right first thing
- no "book an expert" ("for this subject there is genuinely nobody to book")
- no red-flag strip; each warning sits on its own page, 18 pages with warnings
- the gentle "small is complete" stance, and the "Find a name" tool

### What parents actually ask
From `research/questions/ranked_parenting.csv`:

| Topic | Hits | Top questions | What it means |
|---|---|---|---|
| Baby massage, which oil | 491 | which baby massage oil is good; how to do baby massage | **The biggest need.** Traditions never mentions mustard oil, and no page says which oil is safe |
| The first 40 days | 207 | why 40 days; what to eat in the first 40 days | First 40 owns this. Traditions only needs to link it |
| Honey, gripe water | 30 | can a 1-year-old have honey; is gripe water safe | Already covered well (no honey before 1) |
| Swing or jhula for sleep | 5 | is it ok for baby to sleep in a swing | Traditions contradicts itself and Sleep (below) |
| Naming, kajal, ear piercing, ceremonies, festivals | 0–26 each | — | Low in this pool |

**A caveat:** the pool is mostly English, question-shaped searches. Ceremony planning ("annaprashan muhurat") is searched in Hindi, or not as a question at all. So low numbers here mean "don't add big new things", not "remove what's there".

### What a parent meets today
1. **Every page shows at every age.** Only the four charts have an age tag. A 4-year-old's parent sees chhathi (day 6), naamkaran (day 11), the jhula, aqiqah and christening in full. A newborn's parent sees mundan, ear piercing and the first birthday.
   - The 3–6 chart lists Navjote (7–11 years) and Dastar Bandi (about 11).
2. **The jhula contradiction, a safety issue.**
   - The page says "A cloth swing is as good a place to sleep as an imported cot" (`:813-816`).
   - Its own lines above say not to leave a baby asleep in a swing unwatched (`:798-800`).
   - First 40 says "supervised naps only". The "good old ways" list (`:2891`) praises co-sleeping and the cloth swing.
   - **Sleep's SL7 already decided this: one reviewer, and the doors must agree.**
3. **Massage and oil:** 0 mentions of mustard oil. Oil in the ears and nose appears only inside one callout. No page says which oil to use. The shop has no baby massage oil.
4. **Links:**
   - 3 "shop" links open the whole store, and the shop has no ceremony stock.
   - The birth certificate callout on naamkaran links nothing, though Papers has `pm_birth_certificate`.
   - First 40's ceremonies, folk practices and jhula pages are twins with no link either way.
5. **Communities:**
   - Hindu 9 pages; Muslim 2; Christian, Sikh and interfaith 1 each; Jain and Parsi share 1.
   - Buddhist has 0. Odisha, Assam, Kashmir, Sindhi and Konkani have 0.
6. **Festivals:** one page. Nothing on Holi colours in the eyes, kite string (manja) cuts, Lohri bonfires, or fasting in Ramzan while breastfeeding.
7. **Films:** 17 placeholders. There's an intro film only on the newborn chart, and no door intro.
8. **Names:**
   - The tool "Home remedies from the elders, checked" is 38 characters and gets cut.
   - The door comment says "Welcoming her home", but the label reads "Welcoming baby home".
9. **Thin pages:**
   - someone_elses_ceremony (about 660 characters)
   - two pages still waiting on your tone sign-off (skip_it, mother_kept_apart)

## TR1. Each age sees its own ceremonies first (S1 and S2)
- **Tag every page with its age:**
  - chhathi, naamkaran, jhula, nishkramana, aqiqah, tahneek and christening go to 0–4 months
  - annaprashan goes to 4–12 months
  - mundan, ear piercing and the first birthday go to 6 months–3 years
  - letters (aksharabhyasam) go to 2–6 years
  - the faith, family, money and safety pages stay for every age
- **Pages for an age already passed fold under "Earlier"**, which the shell already does. Nothing is hidden, so a parent with a second baby still finds them.
- **Tab order by age:**

  | Age | Order |
  |---|---|
  | 0–4 months | Coming up, Welcoming, In every faith, First years, Small safe |
  | 4 months–3 years | Coming up, First years, Small safe, In every faith, Welcoming |
  | 3–6 years | Coming up, Small safe (festivals), First years, In every faith, Welcoming |

- The 3–6 chart moves Navjote and Dastar Bandi to a line, "Later, at 7 to 11".

## TR2. The jhula says what Sleep says (follows SL7, no new question)
- The page and the "good old ways" list say:
  - the jhula is wonderful for rocking and for watched naps
  - for sleep without you, he goes flat on his back in a cot, a bassinet or a firm floor bed
- The old line stays commented out, "kept for revert".
- Same paediatric reviewer as Sleep's jhula page. The two doors link each other, and First 40's jhula page too.

## TR3. Malish, and which oil (the top question)
A new part of `newborn_customs`, "Malish and the oil". REQUIRED_REVIEW.
- Malish is good for bonding.
- **Mustard oil:** best avoided on a newborn's skin. It can irritate, and studies in India found it can weaken the skin barrier.
- **Gentler oils:** a plain, fragrance-free oil like cold-pressed coconut or sunflower, patch-tested first.
- **Never** in the ears, nose or eyes, and not on the cord until it has healed.

Links:
- "How to do malish" → Sleep `malish`
- First 40 `malish`

**Owed to the shop list:** baby massage oil is the top-searched item and isn't stocked.

## TR4. Links that land on the right page
- **Naamkaran's birth certificate line** → Papers `pm_birth_certificate`.
- **Twins link each other:**
  - chhathi and naamkaran ↔ First 40 `f40_ceremonies`
  - newborn_customs ↔ `f40_folk_practices`
  - jhula ↔ `f40_jhula` and Sleep's jhula page
- **The 3 shop links** go to the right shelf, or come off:
  - naamkaran's (clothes) goes to Clothing
  - the other two (`:1133`, `:2384`) are checked at build, and dropped if the shop has nothing for that step
- **"pp_feeding" ×3** go to Feeding's first-foods page.
- **The gentle festival list** links Safety's festivals page, as it already does. It's kept.

## TR5. Festivals and every community, small additions
- **Small additions to `first_festivals`,** not a new page. Demand is low, but each is a real safety point. REQUIRED_REVIEW.
  - **Holi:** colour in the eyes means rinse with clean water and see a doctor if it stays red.
  - **Makar Sankranti:** manja (glass-coated kite string) cuts on scooters, so keep children off rooftops while kites fly.
  - **Lohri:** the bonfire distance.
  - **Ramzan:** fasting while breastfeeding means talk to the doctor, and drink well at sehri and iftar.
- **The faith page becomes "Jain, Parsi and Buddhist welcomes"**, with a short Buddhist naming card.
- **A regional line** on how_date_chosen: "Families from Odisha, Assam, Kashmir, Sindh and the Konkan have their own versions; this door doesn't list every one."

## TR6. Names, films and loose ends
- **The tool becomes "Home remedies, checked".** The old name stays commented out.
- **The door comment is fixed.**
- **someone_elses_ceremony is written out:** what to bring, what to wear, how to hold someone else's baby, and saying no to feeding him.
- **Films:**
  - the 17 slots stay
  - the door intro `traditions/door_intro` is added
  - every tap says "This film is still being made" (S8a)

## TR-Q. The one question that is yours
`skip_it` and `mother_kept_apart` are written and live, but waiting on your tone sign-off:
- "skipping a ceremony is allowed"
- "the custom of keeping the mother apart"

Recommended: you read the two pages once at build, on the phone, and say "fine" or what to change. I'll ask this in plain words after the plan.

## Taps that can't happen yet (S8)

| Target | What she sees |
|---|---|
| 17 films and the intro | "still being made" |
| A shop link with nothing in stock | the link is removed, not left pointing at nothing |

## Build order (after step 0 and your go)
1. Tags and tab order
2. The jhula fix
3. Malish
4. Links
5. Festivals and faiths
6. Names, the thin page and films

**Reuse:**
- the S1 tab order
- the "Earlier" fold
- M4 `PpLink.pageId`
- `pvToast` S8a
- Sleep's jhula copy (`07-sleep-content.md` §2)

## Verification
- `test/pp_traditions_door_test.dart`:
  - first tab and first page at each age
  - newborn ceremonies are under "Earlier" at 3–6
  - no "as good a place to sleep" line
  - Traditions, Sleep and First 40 jhula pages link each other
- `door_names_fit_test`
- `pp_doors_sanity_test`
- `flutter analyze` on touched files
- grep call sites

## Decisions
These stay here on purpose. When a problem turns up later, check this table first: if an answer covers it, the fix follows that answer.


| # | Decision | Why (what parents want) | Answer |
|---|---|---|---|
| TR1 | Each age sees its ceremonies first; passed ones fold under "Earlier" | A 4-year-old's parent doesn't need day-6 rituals first | **Yes**, chosen and recorded (2026-10-25) |
| TR2 | Jhula: rocking and watched naps yes, unwatched sleep flat | Safety; follows your SL7 answer | **Yes**, chosen and recorded (2026-10-25) |
| TR3 | Malish and which oil | Top question (491); 0 lines today | **Yes**, chosen and recorded (2026-10-25) |
| TR4 | Links land on the exact page | Plain fixes | **Yes**, chosen and recorded (2026-10-25) |
| TR5 | Festival safety lines, Buddhist welcome, regional line | Low demand, so small additions only | **Yes**, chosen and recorded (2026-10-25) |
| TR6 | Tool name, thin page, films | Plain fixes | **Yes**, chosen and recorded (2026-10-25) |
| TR-Q | Read skip_it and mother_kept_apart for tone | Yours: it's your voice | **Approved** (2026-10-25), read as text, "Fine, with your two changes": the script says "my husband or my mother", and the doctor note adds Tele-MANAS 14416 |
