# Door 1: Feeding, new copy and offerings (D5, D6)

Companion to `01-feeding.md`. Written 2026-10-23 and approved in principle by the user (D5, D6: "do it fully").
- The copy below goes into `pp_feeding_content.dart` as written, block by block, in the build.
- Voice: the house warm voice, English only, no emoji.
- Every clinical number carries `// REQUIRED_REVIEW:` in the code.

---

## Part A. Offerings by age (D5)

### A1. What the law allows us to sell (read this first)
India's **Infant Milk Substitutes Act** (1992, amended 2003) bars promoting:
- infant milk substitutes (formula)
- feeding bottles
- "infant food" (packaged food marketed for babies under two)

The definition of "advertisement" is broad: any notice, label or "visible representation".
- In September 2026, Maharashtra's FDA went further and applied the Act to **complementary and traditional infant foods** too.
- Sources: [Alive & Thrive IMS brief](https://www.aliveandthrive.org/sites/default/files/ims_act_advocacy_brief_for_health_care_providers.pdf), [BPNI, the Act](https://www.bpni.org/docments/IMS-act.pdf), [The Week, 2026-09-29](https://www.theweek.in/news/health/2026/09/29/no-formula-ads-free-samples-or-influencer-promotions-maharashtra-fda-tightens-infant-food-rules.html).

**So, the rule for every ParentVeda shelf, all stages:**
- **Never:** formula, bottles, teats, packaged baby cereals, purées, "first food" mixes or weaning powders for under-twos. This holds even as an affiliate link.
- **Ask before:** bottle sterilisers and bottle warmers. They are bottle accessories, and need a legal read.
- **Fine:** pumps, nursing wear, bowls, spoons, chairs, cups, cookware, storage and tiffins.
- **Already in the catalogue and in conflict:**
  - "Anti-Colic Feeding Bottle" (`pp_products_data.dart:581`): take it off every shelf.
  - "Steam Steriliser" (`:633`): needs the legal read.
  - Both go to `docs/BEFORE-LAUNCH.md`.
- This needs a legal sign-off before launch, by a person, not by this plan.

### A2. Products to add, by her child's age
Prices are set by the catalogue server-side. The ₹ ranges are typical Indian market prices for the brief only, never shown in the app.

| Age | Product | Why an Indian family needs it | Typical ₹ (USD) | Shown on |
|---|---|---|---|---|
| 0–6m | Nursing kurti / feeding top (zip or slit) | Feeding in front of relatives, at work and on visits | ₹600–1,500 ($7–18) | bf_positions, bf_pumping |
| 0–6m | Nursing bra (2–3) | Daily comfort, sized after milk comes in | ₹400–1,200 ($5–14) | bf_cracked |
| 0–6m | Feeding pillow | Positions without back pain | ₹800–2,000 ($10–24) | bf_positions (link exists, check it resolves) |
| 0–6m | Breast pads, washable | Leaks in heat; washable beats disposable here | ₹300–700 ($4–8) | bf_oversupply |
| 0–6m | Nipple cream (lanolin) | Already linked | — | bf_cracked |
| 0–6m | Manual pump · electric pump | Back to work, building supply | ₹1,000–3,000 / ₹4,000–15,000 ($12–36 / $48–180) | bf_pumping, bf_exclusive_pumping |
| 0–6m | Milk storage bags + insulated cooler bag with ice packs | Carrying milk home from work in heat | ₹400–1,200 ($5–14) | bf_pumping (daycare section) |
| 0–6m | Paladai (small steel or silver feeding cup) | Traditional cup feeding of expressed milk, which needs no bottle | ₹200–2,000 ($2–24) | bf_pumping (daycare section) |
| 6–8m | High chair, foldable | The setup page's whole point: upright, feet supported | ₹3,000–9,000 ($36–108) | solids_setup |
| 6–8m | **Floor booster seat** | Many Indian families eat on the floor. A booster puts the baby upright at the family's level. | ₹1,200–3,000 ($14–36) | solids_setup |
| 6–8m | Suction bowl (steel or silicone) + soft-tip spoons | First meals without the bowl flying | ₹300–900 ($4–11) | solids_first_foods |
| 6–8m | Small steel katori-chammach set | Many families' first-feeding set. It is also Annaprashan's. | ₹300–1,500 ($4–18) | solids_annaprashan |
| 6–8m | Long-sleeve weaning bibs / silicone bibs | Turmeric and dal stain | ₹250–600 ($3–7) | solids_setup |
| 6–8m | Splash mat for the floor | Floor eating, washable | ₹300–800 ($4–10) | solids_setup |
| 6–8m | Open cup / 360° cup | Water with meals from 6 months | ₹200–600 ($2–7) | safety_water |
| 6–8m | Silicone freezer trays with lids | Batch cooking purées and dal | ₹300–700 ($4–8) | recipes_batch |
| 6–8m | Steamer basket / small mixer jar | Soft textures at home | ₹400–2,500 ($5–30) | recipes_batch, solids_textures |
| 8–12m | Divided plate + toddler cutlery | Finger food, self-feeding | ₹300–900 ($4–11) | solids_spoon_or_blw |
| 8–12m | Straw cup | Next cup skill | ₹250–600 ($3–7) | safety_water |
| 8–12m | Insulated food jar | Hot food for outings and daycare | ₹600–1,500 ($7–18) | recipes_batch (daycare section) |
| 1–2y | Spill-proof snack cup | Travel, temples, long visits | ₹200–500 ($2–6) | recipes_tiffin_snacks |
| 1–2y | Kids' steel thali (sectioned) | Eating what the family eats, from her own plate | ₹400–1,200 ($5–14) | recipes_meal_ideas |
| 1–2y | Learning tower / kitchen helper | Cooking together, which helps fussy eaters | ₹4,000–9,000 ($48–108) | picky_who_decides |
| 2y+ | Steel tiffin box, 2–3 compartments | Playschool | ₹400–1,200 ($5–14) | recipes_tiffin_snacks |
| 2y+ | Insulated lunch box + lunch bag | Food safety in heat | ₹700–1,800 ($8–22) | recipes_tiffin_snacks |
| 2y+ | Water bottle with straw | School, outdoors | ₹300–900 ($4–11) | recipes_tiffin_snacks |
| 2y+ | Kids' apron + child-safe knife and board | Cooking together | ₹500–1,200 ($6–14) | picky_battles |

Every row needs a real product (an Amazon ASIN or a seller) in the catalogue. Memory notes that product entries are ON HOLD for the admin-panel work, so these go in as owed rows in `DOOR-CONTENT-OWED.md` P2. In the meantime, each page's product slot falls back to the category sheet.

### A3. Classes, workshops, courses and consults to add
Each one is a catalogue entry (title, coach, price, schedule), decided server-side. Prices are TBD by the user.

| Age | Offering | Kind | What it covers | Where it shows |
|---|---|---|---|---|
| 0–6w | **Breastfeeding Basics, after birth** (D3) | Masterclass, live + recording | The first weeks: latch, supply, night feeds, when to call. A second copy of `mc_bf`, written for after birth. | Milk feeds, M band; bf_latch, bf_supply |
| 3–6m | **Back to work: pumping and storage** | Live class | Pump choice, a building-up schedule, storage, the daycare handover, your workplace rights | bf_pumping, bf_exclusive_pumping |
| 5–6m | **Starting solids, the Indian way** | Live class with a paediatric nutritionist | When and how, first foods from an Indian kitchen, textures, allergens, gagging vs choking | Starting solids (opens for F, "Coming up next" for M at 5m); solids_when |
| 5–9m | **Baby first aid and choking** | Live class with a paediatric nurse or doctor | Back blows, chest thrusts, CPR on a doll; fever and falls basics | safety_gagging foot, solids_textures, Health door |
| 8–10m | **Finger foods and self-feeding, safely** | Live class | Cutting, shapes, BLW without fear, the move to family food | solids_spoon_or_blw, solids_textures |
| 1–5y | **The fussy eater workshop** | Workshop, live + recording | Who decides what, food jags, no force-feeding, the plate rules, relatives | picky_* pages, the Eating and growing tab |
| 2–5y | **Tiffin and toddler nutrition** | Live class | A week of tiffins, snacks, packaged-food labels, health drinks | recipes_tiffin_snacks, picky_health_drinks |
| 0–2y | **Your baby's first year of food** | Self-paced course | Milk to family food, month by month, with the recipes | Door foot; course shelf |
| any | Lactation consult (IBCLC) | 1:1 | Exists | Milk tab expert row and the problem pages |
| any | Paediatric nutritionist | 1:1 | Exists | Food tabs' expert row, weight and picky pages |
| any | **Paediatric feeding therapist** (speech or occupational therapist) | 1:1 | New. For gagging past 12 months, very few foods accepted, texture refusal | picky_not_eating, "when it needs help" callout |

---

## Part B. New copy (D6)

### B1. New page: `picky_health_drinks`
- Area: `not_eating`
- Format: ARTICLE
- Bands: tod, big
- Placed after `picky_sweet_packet`

**Title:** "Do I need a health drink in his milk?"
**Subtitle:** The malt and chocolate powders, honestly

**PpIntro**
> The ads promise taller, stronger, sharper. Grandparents swear by them. For most children they are mainly a way to add sugar to milk, and milk was already doing the work.

**PpArticle**
1. "Health drink" is not a food category in Indian law. In April 2024 the government told shopping sites to stop listing malt and chocolate drink powders under that name, and India's food regulator told them not to call dairy, cereal or malt drinks "health" or "energy" drinks. The powders did not change; only the label had been doing the selling. *(REQUIRED_REVIEW: dates and wording.)*
2. Look at the back of the jar. On most of these powders, sugar is one of the first ingredients, and often a large share of the jar. Maltodextrin, liquid glucose, malt extract and cocoa solids with sugar add more. A spoonful or two in each cup of milk, twice a day, adds up to a lot of sugar in a small child. *(REQUIRED_REVIEW: avoid exact figures unless confirmed per brand.)*
3. The vitamins on the label are real, but a child eating dal, roti or rice, vegetables, curd and fruit is already getting them. Nothing in a jar makes a healthy child taller. Height comes mostly from genes, from enough food overall, and from sleep.
4. They can make a fussy eater fussier. A big cup of sweet milk before a meal fills a small stomach, so the dal goes uneaten, and the cup gets bigger the next day. Most toddlers need no more than about two to three small cups of milk a day; more than that crowds out food and iron. *(REQUIRED_REVIEW: daily milk limit against IAP.)*

**PpCards**, heading "What's worth it, and what isn't":
- *Plain milk* · "Warm or cold, in a cup. This is the whole drink."
- *Haldi doodh, a pinch* · "Fine from one, no sugar needed. A little cardamom makes it sweet enough."
- *Home-made dry fruit powder* · "Almonds, cashews and pistachios ground very fine, a teaspoon in milk. Never whole nuts under five."
- *Ragi malt made at home* · "Sprouted ragi flour cooked in milk or water. Keep jaggery small, because jaggery is sugar too."
- *Malt and chocolate powders* · "A treat now and then, not a daily need. A small spoon, not a heaped one."
- *Doctor-prescribed nutrition drinks* · "Different thing. If your doctor prescribes one for weight, follow their plan."

**PpCallout**
> No added sugar before two is the simplest rule. After two, keep it small, and keep it with meals rather than in a bottle or sippy cup through the day, where it sits on new teeth.

*(REQUIRED_REVIEW: under-two sugar line, WHO/IAP.)*

**PpScript**, heading "When a relative brings a jar":
- "Thank you. We're keeping her milk plain for now, the doctor said so."
- "She gets a little on Sundays, it's our treat day."

**PpWhenLine**
> Read the label once, decide once, and stop thinking about it every morning.

**PpIndiaNote**
> Many of us grew up on these drinks, and that is part of their pull. It is fine to keep one as a treat. It is not a gap in your child's diet if you don't.

**PpCallout** (kind: doctor), title "When it's not a drink question":
> If you are reaching for a powder because you are worried about weight, check the growth chart with your paediatrician first. A child growing along their own curve does not need extra.

**PpLink**s:
- "Is my baby too thin?" → `weight_too_thin`
- "Track growth" → `pp_growth`
- "Only wants biscuits and chips" → `picky_sweet_packet`

**PpConsult**:
- title: "Paediatric nutrition consultation"
- whoFor: "If milk has become most of what your child takes, and you want a plan that brings food back without a fight."
- surfaceId: `pp_experts/Nutritionist`

### B2. New section on `bf_pumping`
Appended after the storage chart.

**PpArticle**, heading "Milk at the daycare, or with a nanny":
1. Label every bag or bottle with your child's name, the date and the time you expressed. Carry it in an insulated bag with ice packs, and ask the daycare where it will be kept. It should go in a fridge, not on a shelf.
2. Frozen milk thawed in the fridge is good for about 24 hours. Don't refreeze it. Warm it by standing the container in a bowl of warm water, never in a microwave, which heats unevenly and can burn. *(REQUIRED_REVIEW: thaw window.)*
3. Show whoever feeds your baby how to go slowly. With a paladai or a small cup, a baby sips at their own pace. With a bottle, hold it nearly level and pause often, so your baby isn't flooded. Many babies take about 25 to 30 ml for each hour you are away, but follow your baby rather than the number. *(REQUIRED_REVIEW: volume per hour.)*
4. Ask them to hold the last feed if you are due back soon, so you can feed when you walk in. That feed protects your supply.

**PpCards**, heading "Your rights at work":
- *Creche at work* · "Places with 50 or more employees must have a creche, and you may visit it four times a day, breaks included." *(REQUIRED_REVIEW: Maternity Benefit (Amendment) Act 2017, s.11A.)*
- *Time to pump* · "Ask for a clean, private place and short breaks. Write it down with HR before your first day back."

**PpIndiaNote**
> The paladai, the small spouted cup many grandmothers used, works well for expressed milk and needs no bottle at all.

**Product slot:** milk storage bags, cooler bag, paladai (A2 rows).
**Class slot:** "Back to work: pumping and storage" (A3).

### B3. New section on `recipes_batch`
Appended before its two rules.

**PpArticle**, heading "Packing food for daycare":
1. Hot food goes in an insulated jar, filled straight from the stove. Cold food goes with an ice pack. Cooked food shouldn't sit at room temperature for more than two hours, and in Indian summer heat, an hour. *(REQUIRED_REVIEW: 2 h / 1 h above 32 °C.)*
2. Cut it the way you would at home. Grapes quartered lengthwise, no whole nuts, no popcorn, no hard raw carrot rounds. Daycares get busy, so send food that is already safe.
3. Label the box with your child's name. If your child has an allergy, give the daycare a written note with what to avoid and what to do, and ask who has read it.
4. Ask for one line a day: what was eaten, roughly how much, and what came back. A full lunch box twice is information, not a crisis.

**PpCards**, heading "Five questions to ask the daycare":
- *Who feeds the younger ones?* · "One adult per few babies, sitting with them, not walking past."
- *Do they make children finish?* · "They shouldn't. Ask what they say when a child stops."
- *What do they serve, if they cook?* · "Ask for the week's menu, and how they handle sugar and fried snacks."
- *What's the allergy policy?* · "Nut-free tables, how sharing is handled, and who is trained in first aid."
- *Where do children wash hands?* · "Before every meal, with soap, not a wipe."

**Product slot:** insulated food jar, lunch box (A2).

### B4. New section on `recipes_meal_ideas`
Appended after the table.

**PpArticle**, heading "Festivals, fasts and the prasad plate":
1. Small children don't need to fast. If the family is eating vrat food, sabudana khichdi, rajgira, kuttu or singhara rotis, they can share it as an ordinary meal. Sabudana is sticky, so serve it soft and in small spoonfuls, and crush the peanuts in it to a powder for children under five.
2. Panchamrit and charnamrit are often made with honey, and honey is not safe before the first birthday. Skip it, or ask for a drop without honey. *(REQUIRED_REVIEW.)*
3. Prasad often comes as whole nuts, roasted chana, mishri crystals or hard sweets, which are the shapes young children choke on. Take the prasad, crush it or keep it for later, and offer a soft piece instead. Nobody minds.
4. Before one, skip mithai and added sugar. After one, a small taste of the festival sweet is part of the festival. Payasam, kheer and halwa in a small katori are fine; a third laddoo from a third aunty is where to step in.
5. Iftar dates: take the stone out and cut them lengthwise into thin pieces. Christmas plum cake is often soaked in rum, so give young children a plain slice of something else.

**PpScript**, heading "When everyone wants to feed her":
- "She's had her share, we'll save the rest for tomorrow."
- "Let's give it to her with dinner, she'll eat it better then."

**PpIndiaNote**
> Festivals are when children learn the family's food. A late, rich, happy meal once in a while undoes nothing. Go back to the usual rhythm the next day.

**PpLink**s:
- "Can my baby eat this?" → `pp_baby_food_check`
- "Choking, and how to cut food" → `safety_choking`

---

## Part C. The 7 thin pages
Deepened in the build, per `01-feeding.md` §5. Each keeps its id and format, gains the content listed there, and stays in house voice. Clinical lines are marked REQUIRED_REVIEW. They are not drafted here, to keep this file to what the user approved as new (D5 and D6).

Sources:
- [Alive & Thrive, IMS Act brief](https://www.aliveandthrive.org/sites/default/files/ims_act_advocacy_brief_for_health_care_providers.pdf)
- [BPNI, the IMS Act text](https://www.bpni.org/docments/IMS-act.pdf)
- [The Week, Maharashtra FDA order, 2026-09-29](https://www.theweek.in/news/health/2026/09/29/no-formula-ads-free-samples-or-influencer-promotions-maharashtra-fda-tightens-infant-food-rules.html)
- [Exchange4media, "health drinks" advisory](https://www.exchange4media.com/marketing-news/bournvita-to-be-removed-from-health-drinks-category-centre-tells-e-comm-companies-133755.html)
- [The Quint, health drink laws](https://www.thequint.com/fit/health-drink-food-safety-laws-india-bournvita)
- [Outlook Business, claims withdrawn](https://www.outlookbusiness.com/corporate/bournvita-maker-mondelez-drops-health-claims-following-fssai-action)
