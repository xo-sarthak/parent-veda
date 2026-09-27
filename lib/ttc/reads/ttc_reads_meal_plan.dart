// =============================================================================
//  Getting ready › Meal plan — the reads for this tab
// -----------------------------------------------------------------------------
//  ⚠️ WRITTEN 2026-09-26 FROM THE TTC GAP ANALYSIS (Flo / What to Expect vs
//  ParentVeda), stream A, "Getting ready › Meal plan". The gap analysis found
//  one P1 (a preconception eating plan built round an Indian plate) and a set
//  of P2/P3 pieces (a vegetarian meal plan, recipes, snacks, iron, vitamin A,
//  honest supplement evidence). None of the competitor text was read or used;
//  only their titles and our own summaries of them.
//
//  ⚠️ THREE RULES CARRIED OVER FROM `ttc_reads_getting_ready.dart`, SO THE
//  DOOR NEVER CONTRADICTS ITSELF:
//    · there is no "fertility diet", and every piece here says so;
//    · no food is banned (papaya and pineapple are fine in normal amounts);
//      the one clear caution is high-dose vitamin A as retinol;
//    · folic acid is 400 to 500 micrograms a day, from before trying.
//  And three of this tab's own: no calorie targets, no weight-loss framing,
//  and no supplement is sold or named by brand.
//
//  ⚠️ THE AGGREGATOR IS STILL THE ONLY PUBLIC ENTRY POINT. Nothing outside
//  `ttc_reads_data.dart` should import this file.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// Private and duplicated per file, on purpose. See the note in
// `ttc_reads_getting_ready.dart`.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsMealPlan = [
  // ===========================================================================
  //  A week of meals — the P1 of this tab
  // ===========================================================================
  //  A plan, not a prescription. Vegetarian because most Indian homes are, with
  //  eggs twice so the eggless swap has something to swap, and a Jain section
  //  because onion, garlic and potato run through half of the week otherwise.
  PvRead(
    id: 'ttc_read_meal_plan_week',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('A week of fertility-friendly Indian meals'),
    teaser: _en('Seven days of everyday vegetarian home food, with swaps for '
        'eggless and Jain kitchens and one shopping list for the week.'),
    shortAnswer: _en("There's no special fertility diet. This plan is ordinary "
        'Indian vegetarian food, with protein, a whole grain and vegetables at '
        'each meal, and iron and folate foods spread through the week. Use it '
        'for ideas, swap dishes freely, and keep taking your folic acid.'),
    scaleSetter: _en("You don't need to follow this exactly, and a missed day "
        "changes nothing. It's here to save you planning, not to set rules. No "
        'food on it is a medicine, and no food left off it is banned.'),
    author: _en('Akanksha Srivastava'),
    authorRole: _en('Maternal and child nutritionist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Deciding what to cook every day is tiring, especially when your '
              "head is already full of cycles and tests. So here's a week that's "
              'already planned. It uses the food most Indian homes cook anyway, '
              'with a few small changes that help before pregnancy.'),
          _en('Every day follows the same shape. Change the dishes to suit your '
              "region, your family and what's in season. The shape matters "
              'more than the menu.'),
        ],
      ),
      PvReadSection(
        heading: _en('How is each day put together?'),
        paragraphs: [
          _en('Each main meal has three things on the plate. A protein, like '
              'dal, curd, paneer, chana, sprouts or eggs. A whole grain, like '
              'roti, a millet, brown rice or poha. And at least one vegetable, '
              'ideally two.'),
          _en('Iron foods sit next to something with vitamin C, like lemon, '
              'tomato, amla or guava, because it helps your body take the iron '
              'in. Tea and coffee go between meals, not with them.'),
        ],
        tip: PvReadTip(
          title: _en('Your appetite sets the portions'),
          body: _en("This plan doesn't count calories or measure plates. Eat "
              'until you feel satisfied. If you have PCOS, diabetes or a diet '
              "plan from your own doctor, follow that and borrow dishes from "
              'here.'),
        ),
      ),
      PvReadSection(
        heading: _en('Days 1 and 2'),
        paragraphs: [
          _en('Start with dishes you probably make already. The one change on '
              'day 1 is adding protein to breakfast.'),
        ],
        bullets: [
          _en('Day 1 breakfast: vegetable poha with peanuts, and a bowl of '
              'curd.'),
          _en('Day 1 lunch: palak dal, two rotis, and a cucumber and tomato '
              'salad with lemon.'),
          _en('Day 1 evening: roasted chana and a guava or an orange.'),
          _en('Day 1 dinner: rice, rajma and a mixed vegetable sabzi.'),
          _en('Day 2 breakfast: two besan chillas with grated vegetables, and '
              'mint chutney.'),
          _en('Day 2 lunch: jowar or wheat roti, lauki chana dal, and curd.'),
          _en('Day 2 evening: a small handful of walnuts or peanuts and two '
              'dates.'),
          _en('Day 2 dinner: moong dal khichdi with vegetables, a spoon of '
              'ghee, and kachumber.'),
        ],
      ),
      PvReadSection(
        heading: _en('Days 3 and 4'),
        paragraphs: [
          _en('Two millet meals come in here. Ragi and bajra carry more iron and '
              "calcium than white rice, and they're easy to rotate in."),
        ],
        bullets: [
          _en('Day 3 breakfast: ragi dosa, or ragi porridge made with milk, and '
              'a banana.'),
          _en('Day 3 lunch: chole with two rotis, and an onion and tomato salad '
              'with lemon.'),
          _en('Day 3 evening: sprouted moong chaat with tomato and lemon.'),
          _en('Day 3 dinner: paneer and peas sabzi, rice and a bowl of dal.'),
          _en('Day 4 breakfast: egg bhurji with two multigrain rotis.'),
          _en('Day 4 lunch: bajra roti, methi aloo, and curd.'),
          _en('Day 4 evening: roasted makhana and a glass of buttermilk.'),
          _en('Day 4 dinner: vegetable pulao with soya chunks, and cucumber '
              'raita.'),
        ],
      ),
      PvReadSection(
        heading: _en('Days 5 and 6'),
        paragraphs: [
          _en('By now the pattern should feel familiar. These two days bring in '
              "south and west Indian dishes, so the week doesn't feel "
              'repetitive.'),
        ],
        bullets: [
          _en('Day 5 breakfast: vegetable upma with peas, and a glass of milk.'),
          _en('Day 5 lunch: sambar with red or brown rice, beans poriyal, and '
              'curd.'),
          _en('Day 5 evening: curd with chopped fruit and a spoon of ground '
              'flaxseed.'),
          _en('Day 5 dinner: two methi theplas, kadhi, and a vegetable.'),
          _en('Day 6 breakfast: a two-egg vegetable omelette with a multigrain '
              'roti.'),
          _en('Day 6 lunch: lobia or rajma, rice, and a carrot and beetroot '
              'salad with lemon.'),
          _en('Day 6 evening: an orange and a small handful of roasted '
              'peanuts.'),
          _en('Day 6 dinner: paneer or tofu tikka with vegetables, two rotis, '
              'and dal.'),
        ],
      ),
      PvReadSection(
        heading: _en('Day 7, and what to do with leftovers'),
        paragraphs: [
          _en('Day 7 is lighter to cook, because most people want a slower day. '
              'Leftover dal becomes dal paratha. Leftover rice becomes curd rice '
              'with a tadka.'),
        ],
        bullets: [
          _en('Day 7 breakfast: dal paratha with curd.'),
          _en('Day 7 lunch: curd rice, and a vegetable kootu or sabzi.'),
          _en('Day 7 evening: two dates and a few almonds.'),
          _en('Day 7 dinner: palak paneer, two rotis, and a steamed sprout '
              'salad.'),
        ],
      ),
      PvReadSection(
        heading: _en("What if you don't eat eggs?"),
        paragraphs: [
          _en("Eggs appear twice in the week, as easy protein. If your home "
              "doesn't cook them, nothing is lost. These swaps fit the same "
              'meal and give a similar amount of protein.'),
        ],
        bullets: [
          _en('Egg bhurji on day 4 becomes paneer bhurji or tofu bhurji.'),
          _en('The omelette on day 6 becomes a moong dal chilla or a besan '
              'chilla with paneer inside.'),
        ],
      ),
      PvReadSection(
        heading: _en('What changes in a Jain kitchen?'),
        paragraphs: [
          _en('A Jain plate leaves out onion, garlic, potatoes and other root '
              'vegetables. Almost every meal here still works. The dals, '
              'millets, curd, paneer and most vegetables stay exactly as they '
              'are.'),
        ],
        bullets: [
          _en('Use hing and a little dry ginger powder (sonth) in your tadka in '
              'place of onion, garlic and fresh ginger.'),
          _en('Swap potatoes for raw banana, and carrot or beetroot for cabbage, '
              'capsicum or cucumber.'),
          _en('Some Jain families avoid sprouts. Boiled whole moong or kala '
              'chana does the same job.'),
          _en('Tomato, lemon, amla and guava still bring the vitamin C, so the '
              'iron pairing stays.'),
          _en("If you don't eat after sunset, move the evening snack earlier "
              'and make lunch the bigger meal.'),
        ],
      ),
      PvReadSection(
        heading: _en('Six snacks to keep at home'),
        paragraphs: [
          _en('Hunger between meals is when packaged snacks creep in. Keeping a '
              'few of these ready makes the easy choice a good one.'),
        ],
        bullets: [
          _en('Roasted chana, plain or with a little masala.'),
          _en('Roasted makhana with a pinch of salt and pepper.'),
          _en('Peanut chikki, or a small handful of peanuts.'),
          _en('Curd with fruit and a spoon of seeds.'),
          _en('A steamed sprout chaat with lemon.'),
          _en('Fruit you can eat whole, like a guava, a banana or an orange.'),
        ],
      ),
      PvReadSection(
        // ⚠️ FOLDS. A list she comes back to, not part of the argument.
        collapsible: true,
        summary: _en('Everything the week uses, grouped the way a kirana or '
            'sabzi shop sells it.'),
        heading: _en('What goes on the shopping list?'),
        paragraphs: [
          _en('Most of this is already in an Indian kitchen. Buy vegetables '
              'twice in the week so they stay fresh.'),
        ],
        bullets: [
          _en('Grains: wheat atta, jowar or bajra atta, ragi flour, rice, poha '
              'and rava.'),
          _en('Pulses: toor, moong (whole and split), chana dal, rajma, kabuli '
              'chana, kala chana, lobia, besan and soya chunks.'),
          _en('Dairy and protein: milk, curd, paneer, tofu, and eggs if you eat '
              'them.'),
          _en('Vegetables: spinach, methi, lauki, beans, peas, tomatoes, '
              'cucumber, capsicum, cabbage, carrot, beetroot, onions and '
              'potatoes (the last four skipped in a Jain kitchen).'),
          _en('Fruit: guavas, oranges, bananas, amla, dates and whatever is in '
              'season.'),
          _en('Nuts and seeds: peanuts, walnuts, almonds, flaxseed, makhana and '
              'roasted chana.'),
          _en('Kitchen basics: iodised salt, lemons, ghee, two cooking oils to '
              'mix, hing, jeera, mustard seeds and turmeric.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is this food enough, or do I still need folic acid?'),
        answer: _en('You still need folic acid. Food folate helps, but almost '
            'nobody gets the protective amount from food alone. The usual dose '
            'is 400 to 500 micrograms a day, started before you begin trying.'),
      ),
      PvReadFaq(
        question: _en('Do I have to eat millets?'),
        answer: _en("No. They're useful, not required. If your family eats "
            'wheat and rice, carry on. Adding a millet roti or dosa once or '
            'twice a week is an easy extra if you like the taste.'),
      ),
      PvReadFaq(
        question: _en('We eat chicken and fish at home. Can I still use this?'),
        answer: _en('Yes. Swap a dal or paneer dish for chicken, fish or eggs '
            'whenever you like, and cook them all the way through. Fish like '
            'sardines, mackerel, rohu or pomfret are good choices. Skip large '
            'fish like shark and swordfish.'),
      ),
      PvReadFaq(
        question: _en("Some days I'm too tired to cook. Is that a problem?"),
        answer: _en('Not at all. Khichdi with curd, dal and roti, or curd rice '
            'with a fruit is a perfectly good meal. One easy day, or several, '
            "doesn't undo anything."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When food is a question for a doctor'),
      body: _en("If you're tired all the time, breathless on stairs or look "
          'pale, ask for a haemoglobin test in the next few weeks. Talk to a '
          'doctor before changing how you eat if you have diabetes, PCOS, '
          'thyroid disease, coeliac disease or a past eating disorder. If '
          "you're losing weight without trying, book a visit soon."),
    ),
    evidence: _en('ICMR-NIN Dietary Guidelines for Indians (2024), including '
        'keeping tea and coffee an hour away from meals and using a mix of '
        'cooking oils; ICMR-NIN Indian Food Composition Tables (2017) for iron '
        'and calcium in millets and pulses; FOGSI Good Clinical Practice '
        'Recommendations on Preconception Care for folic acid at 400 to 500 '
        'micrograms a day; NHS advice on eating fish when trying for a baby. '
        'Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Plan your own week'),
        value: _en('Turn these ideas into a day-by-day plan that fits your '
            'kitchen.'),
        surfaceId: 'ttc_nutrition',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Next: ten everyday recipes'),
        value: _en('How to cook the dishes in this plan, with Jain and eggless '
            'notes.'),
        surfaceId: 'ttc_read/ttc_read_everyday_recipes',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Talk to a nutritionist'),
        value: _en('A plan built around how your family eats, your tests and '
            'your health.'),
        surfaceId: 'ttc_prepare',
      ),
    ],
    readNext: [
      'ttc_read_everyday_recipes',
      'ttc_read_iron_before_pregnancy',
      'ttc_read_three_months_before',
    ],
  ),

  // ===========================================================================
  //  Ten recipes
  // ===========================================================================
  //  Each serves two and is written for a home cook: katoris and spoons, not
  //  grams. Two safety lines live inside the steps rather than in a warning
  //  box, because that is where she will be looking: sprouts are steamed, and
  //  rajma is cooked until fully soft (raw kidney beans upset the stomach).
  PvRead(
    id: 'ttc_read_everyday_recipes',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Ten everyday recipes for the months before pregnancy'),
    teaser: _en('Home-style Indian dishes that cook in under 40 minutes, each '
        'one adding protein, iron, folate or calcium to an ordinary day.'),
    shortAnswer: _en('These are ten ordinary Indian dishes, not special '
        'fertility recipes. Each one adds protein, iron, folate or calcium to a '
        'normal day, and each serves two. Every recipe has a note for Jain '
        'kitchens, and the egg dish has a paneer version.'),
    scaleSetter: _en("None of these will help you conceive faster, and you "
        "don't need to cook them all. They're for the days you want a new idea "
        'that also does some good. Cook what your family already enjoys.'),
    author: _en('Akanksha Srivastava'),
    authorRole: _en('Maternal and child nutritionist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('These recipes use what most Indian kitchens already have. Each '
              'serves two, and measures are in katoris and spoons, the way home '
              'cooks measure.'),
          _en('Where a recipe uses onion, garlic or potato, the Jain note says '
              'what to use instead. All ten fit into the week-long meal plan.'),
        ],
      ),
      PvReadSection(
        heading: _en('1. Palak dal'),
        paragraphs: [
          _en('Spinach and dal in one pot give you folate, iron and protein. '
              'The lemon at the end helps your body use the iron.'),
        ],
        bullets: [
          _en('You need: half a katori toor or moong dal, a bunch of spinach, '
              'one tomato, one small onion, two garlic cloves, jeera, turmeric, '
              'a green chilli, salt, ghee and half a lemon.'),
          _en('1. Pressure cook the washed dal with two katoris of water and a '
              'pinch of turmeric for three whistles.'),
          _en('2. Heat the ghee, add jeera, then garlic, onion, chilli and '
              'tomato. Cook until soft.'),
          _en('3. Add the chopped spinach and stir for three to four minutes.'),
          _en('4. Add the dal and salt, simmer for five minutes, and squeeze in '
              'the lemon just before serving.'),
          _en('Jain: leave out onion and garlic, and add a pinch of hing.'),
        ],
      ),
      PvReadSection(
        heading: _en('2. Instant ragi dosa'),
        paragraphs: [
          _en('Ragi is rich in calcium and has more iron than rice. This '
              'version needs no fermenting.'),
        ],
        bullets: [
          _en('You need: one katori ragi flour, a quarter katori each of rice '
              'flour and curd, a small onion, a green chilli, coriander, salt '
              'and oil.'),
          _en('1. Mix the flours, curd and salt with water into a thin batter. '
              'Rest it for 15 minutes.'),
          _en('2. Stir in the chopped onion, chilli and coriander.'),
          _en('3. Pour a ladle onto a hot tawa from the edge inwards, like rava '
              'dosa, drizzle oil, and cook until crisp.'),
          _en('4. Serve with peanut or coconut chutney.'),
          _en('Jain: skip the onion and add finely chopped capsicum.'),
        ],
      ),
      PvReadSection(
        heading: _en('3. Besan chilla with paneer'),
        paragraphs: [
          _en('A quick breakfast with protein from two sources. It also takes '
              'the place of an omelette in an eggless home.'),
        ],
        bullets: [
          _en('You need: one katori besan, a quarter katori grated paneer, a '
              'tomato, half a capsicum, a small onion, ajwain, turmeric, salt '
              'and oil.'),
          _en('1. Whisk the besan with water, salt, turmeric and ajwain into a '
              'smooth batter, a little thicker than dosa batter.'),
          _en('2. Add the chopped vegetables.'),
          _en('3. Spread a ladle on a hot tawa, sprinkle paneer on top, and '
              'cook both sides with a little oil.'),
          _en('Jain: leave out the onion. Everything else stays.'),
        ],
      ),
      PvReadSection(
        heading: _en('4. Sprouted moong chaat'),
        paragraphs: [
          _en('Sprouting makes the iron in moong easier to absorb, and the '
              'lemon helps even more.'),
        ],
        bullets: [
          _en('You need: one katori sprouted moong, a tomato, a small onion, '
              'half a cucumber, lemon, chaat masala and roasted jeera powder.'),
          _en('1. Steam the sprouts for five minutes, so they soften a little '
              'but stay crunchy.'),
          _en('2. Let them cool, then mix in the chopped vegetables.'),
          _en('3. Add lemon juice, chaat masala, jeera powder and salt just '
              'before eating.'),
          _en('Jain: use boiled whole moong or kala chana, without the onion.'),
        ],
        tip: PvReadTip(
          title: _en('Why steam the sprouts?'),
          body: _en('Raw sprouts can carry germs that are harder on you if you '
              'become pregnant. A few minutes of steam deals with that, and '
              'most people find the taste better too.'),
        ),
      ),
      PvReadSection(
        heading: _en('5. Curd, fruit and seed bowl'),
        paragraphs: [
          _en('An Indian take on a fruit and yoghurt bowl, ready in five '
              'minutes.'),
        ],
        bullets: [
          _en('You need: a katori of thick curd, one chopped seasonal fruit, a '
              'teaspoon of ground flaxseed, and a few walnuts or almonds.'),
          _en('1. Spoon the curd into a bowl and add the fruit on top.'),
          _en('2. Sprinkle over the flaxseed and chopped nuts, with a pinch of '
              'cinnamon if you like.'),
          _en('Jain: sweeten with a chopped date rather than honey.'),
        ],
      ),
      PvReadSection(
        heading: _en('6. Vegetable millet khichdi'),
        paragraphs: [
          _en("One pot, with a millet in place of rice. It's gentle on tired "
              'days.'),
        ],
        bullets: [
          _en('You need: half a katori foxtail millet or broken bajra, a '
              'quarter katori moong dal, a katori of mixed chopped vegetables, '
              'jeera, turmeric, ginger, ghee and salt.'),
          _en('1. Wash and soak the millet and dal for 20 minutes.'),
          _en('2. In a pressure cooker, heat the ghee, add jeera and grated '
              'ginger, then the vegetables.'),
          _en('3. Add the millet, dal, turmeric, salt and three katoris of '
              'water. Cook for three to four whistles.'),
          _en('Jain: use sonth in place of fresh ginger, and leave out any root '
              'vegetables.'),
        ],
      ),
      PvReadSection(
        heading: _en('7. Dry kala chana'),
        paragraphs: [
          _en('Black chana is one of the better plant sources of iron and '
              'protein.'),
        ],
        bullets: [
          _en('You need: one katori kala chana soaked overnight, an onion, a '
              'tomato, ginger-garlic paste, jeera, coriander powder, amchur, '
              'salt and oil.'),
          _en('1. Pressure cook the soaked chana with salt for five to six '
              'whistles, until soft.'),
          _en('2. Fry jeera, onion and ginger-garlic paste, then add the '
              'tomato and coriander powder.'),
          _en('3. Add the drained chana and cook for five minutes. Finish with '
              'amchur, and serve with roti.'),
          _en('Jain: make the base with tomato and hing only.'),
        ],
      ),
      PvReadSection(
        heading: _en('8. Methi thepla'),
        paragraphs: [
          _en('Methi adds folate and iron, and theplas keep well for a packed '
              'lunch or travel.'),
        ],
        bullets: [
          _en('You need: one katori wheat atta, a quarter katori besan, a '
              'katori of chopped fresh methi, two spoons of curd, turmeric, '
              'ajwain, sesame seeds, salt and oil.'),
          _en('1. Mix everything into a soft dough, adding water a little at a '
              'time. Rest it for 10 minutes.'),
          _en('2. Roll into thin rounds and cook on a hot tawa with a little '
              'oil until both sides have brown spots.'),
          _en('Jain: already Jain-friendly as written.'),
        ],
      ),
      PvReadSection(
        heading: _en('9. Paneer or egg bhurji with peas'),
        paragraphs: [
          _en('A fast protein dinner. Use eggs if you eat them, paneer if you '
              "don't."),
        ],
        bullets: [
          _en('You need: 150 grams of paneer or three eggs, half a katori of '
              'peas, an onion, a tomato, a green chilli, turmeric, garam masala '
              'and oil.'),
          _en('1. Fry the onion and chilli until soft, then add the tomato, '
              'turmeric and peas.'),
          _en('2. Crumble in the paneer, or pour in the beaten eggs.'),
          _en('3. Stir on medium heat for three to four minutes. Cook eggs '
              'until fully set, with nothing runny left.'),
          _en('Jain: paneer, with capsicum in place of the onion.'),
        ],
      ),
      PvReadSection(
        heading: _en('10. Rajma with lemon salad'),
        paragraphs: [
          _en('Rajma gives iron and protein, and the lemon salad on the side '
              'helps the iron.'),
        ],
        bullets: [
          _en('You need: one katori rajma soaked overnight, an onion, two '
              'tomatoes, ginger-garlic paste, jeera, garam masala, salt and oil. '
              'For the salad: cucumber, tomato and lemon.'),
          _en('1. Pressure cook the rajma with salt until fully soft, usually '
              'six to eight whistles. Undercooked rajma can upset the stomach, '
              'so check a bean squashes easily.'),
          _en('2. Fry jeera, onion and ginger-garlic, then add pureed tomato '
              'and the masala. Cook until the oil separates.'),
          _en('3. Add the rajma with its water and simmer for 15 minutes.'),
          _en('Jain: a tomato and hing gravy, without onion or ginger-garlic.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can I use store-bought ready mixes for these?'),
        answer: _en('Yes, on busy days. Check the label for a lot of salt or '
            "sugar, and add fresh vegetables and lemon yourself. A ready mix "
            'you cook is better than skipping a meal.'),
      ),
      PvReadFaq(
        question: _en('Is it okay to eat the same few dishes over and over?'),
        answer: _en('Mostly, yes. Rotating grains, dals and vegetables over the '
            "week gives you a wider spread of nutrients, but you don't need a "
            'new dish every day.'),
      ),
      PvReadFaq(
        question: _en('Are these safe to keep eating once I get pregnant?'),
        answer: _en('Yes. Keep steaming sprouts, cooking eggs through and using '
            'boiled or pasteurised milk for curd and paneer. Your doctor may '
            'add advice for your own pregnancy.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When a meal leaves you unwell'),
      body: _en('If you get vomiting or diarrhoea with a fever, or it lasts '
          'more than a day, see a doctor within the day, sooner if you might '
          'be pregnant. If certain foods leave you bloated or with loose stools '
          'every time, mention it at your next visit. It can point to things '
          'like coeliac disease, which also affect iron and folate.'),
    ),
    evidence: _en('ICMR-NIN Indian Food Composition Tables (2017) for iron, '
        'folate and calcium in millets, pulses and greens; ICMR-NIN Dietary '
        'Guidelines for Indians (2024); NHS and CDC food safety advice for '
        'pregnancy on cooking sprouts and eggs thoroughly and using pasteurised '
        'or boiled milk. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Put them into your week'),
        value: _en('Add these dishes to a meal plan you can follow day by '
            'day.'),
        surfaceId: 'ttc_nutrition',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Next: iron before pregnancy'),
        value: _en('Why several of these recipes end with a squeeze of '
            'lemon.'),
        surfaceId: 'ttc_read/ttc_read_iron_before_pregnancy',
      ),
    ],
    readNext: [
      'ttc_read_meal_plan_week',
      'ttc_read_iron_before_pregnancy',
    ],
  ),

  // ===========================================================================
  //  Ask a dietitian — the questions she would ask in a consult
  // ===========================================================================
  //  Also where the Diet-and-supplements pack's P2s land that this file may
  //  not add to the existing supplement-timing read: vegetarian gaps (B12,
  //  iron), the one-line vitamin A warning, and an honest evidence list for
  //  fertility supplements.
  PvRead(
    id: 'ttc_read_ask_dietitian',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Ask a dietitian: ten questions answered'),
    teaser: _en('The food questions people ask most while trying, answered '
        'plainly and without banning anything.'),
    shortAnswer: _en("There's no special fertility diet and no food you have "
        'to give up. What helps is a balanced Indian plate, folic acid every '
        'day, and checking for gaps that are common here, like iron, vitamin '
        'B12 and vitamin D. The one clear caution is high-dose vitamin A.'),
    scaleSetter: _en("Most of what you've heard about food and fertility is "
        "either harmless or untrue. Very little here needs changing fast. The "
        "things that matter are few, and they're mostly easy."),
    author: _en('Akanksha Srivastava'),
    authorRole: _en('Maternal and child nutritionist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Everyone has food advice for someone trying for a baby. Some of '
              'it comes from love and none of it comes with sources. These are '
              'the questions dietitians hear most, with the answers the '
              'evidence supports.'),
          _en('None of this replaces advice from someone who knows your '
              'history. If you have PCOS, diabetes or thyroid disease, the plan '
              'from your own doctor comes first.'),
        ],
      ),
      PvReadSection(
        heading: _en('1. Is there a special fertility diet?'),
        paragraphs: [
          _en('No. Nothing you eat has been shown to make you conceive, and '
              'anything sold as a fertility diet is selling hope. What the '
              'evidence does support is a general way of eating that suits '
              'your whole body.'),
          _en('In an Indian kitchen, that looks like dal, sabzi, roti or rice, '
              'curd, fruit and some nuts, with not much fried or packaged food. '
              'It is probably close to what your mother cooks.'),
        ],
      ),
      PvReadSection(
        heading: _en('2. Can a vegetarian diet give me everything I need?'),
        paragraphs: [
          _en('Yes, with two things to watch. Protein is easy: dal with a grain, '
              'curd, paneer, milk and soya cover it well.'),
          _en('The first gap is vitamin B12, found mainly in animal foods. Milk '
              'and curd give some, but many vegetarians run low. The second is '
              'iron, because plant iron is absorbed less easily. A blood test '
              'settles both.'),
        ],
      ),
      PvReadSection(
        heading: _en('3. Do I need to give up chai and coffee?'),
        paragraphs: [
          _en('No. The usual advice is to keep caffeine under about 200 mg a '
              "day. That's roughly two mugs of instant coffee. Tea has less "
              'caffeine than coffee, so a couple of cups of chai fit easily.'),
          _en('The one change worth making is timing. Keep tea and coffee about '
              'an hour away from meals, because they block iron.'),
          _en('Cola, energy drinks, green tea and dark chocolate also contain '
              'caffeine, so count them in the day too.'),
        ],
      ),
      PvReadSection(
        heading: _en('4. Are papaya, pineapple and "heat" foods safe?'),
        paragraphs: [
          _en('Ripe papaya and pineapple in normal amounts are fine while '
              'trying. The worries come from concentrated extracts tested in '
              "labs, not from a bowl of fruit. Once you're pregnant, some "
              'doctors suggest going easy on raw green papaya, and your doctor '
              'can guide you then.'),
          _en('The idea of "hot" and "cold" foods comes from tradition. There is '
              'no evidence it affects conceiving. Eat what agrees with you.'),
        ],
      ),
      PvReadSection(
        heading: _en('5. Is ghee good or bad for fertility?'),
        paragraphs: [
          _en("Neither. A spoon of ghee on dal or roti is fine, and it won't "
              'make you more fertile. ICMR-NIN advises keeping total fat '
              'moderate and using a mix of cooking oils, rather than one fat '
              'for everything.'),
          _en('If you like ghee, a spoon or two a day in cooking is plenty. Let '
              'the rest of your fat come from oils, nuts and seeds. That balance '
              'matters more than any single fat.'),
        ],
      ),
      PvReadSection(
        heading: _en('6. Should I take a fertility supplement?'),
        paragraphs: [
          _en('Here is an honest list, sorted by how much evidence there is. '
              'Tell your doctor about everything you take, including ayurvedic '
              'and herbal products.'),
        ],
        bullets: [
          _en('Strong evidence: folic acid, 400 to 500 micrograms a day, from '
              'before you start trying.'),
          _en('Worth it if a test shows you are low: iron, vitamin B12 and '
              'vitamin D.'),
          _en('Covered by food for most people: iodine, from iodised salt.'),
          _en('Some evidence, but only in specific situations: inositol in '
              'PCOS, and only with your doctor.'),
          _en('Weak or no good evidence: most fertility blends, antioxidant '
              'mixes, royal jelly and herbal mixes.'),
          _en('Only if a fertility clinic prescribes it: DHEA, which some '
              'clinics use in specific IVF cases.'),
        ],
      ),
      PvReadSection(
        heading: _en("7. What's the one thing to be careful with?"),
        paragraphs: [
          _en('Vitamin A in the form called retinol. Too much of it can harm a '
              "baby in early pregnancy, and you may be pregnant before you "
              'know.'),
          _en('It turns up in liver, cod liver oil and some general '
              'multivitamins. The vitamin A in carrots, mango, papaya and '
              'spinach is a different form, and it is safe.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('One line to check on every label'),
          body: _en('If a multivitamin lists vitamin A as retinol or retinyl, '
              'ask your doctor before taking it while trying. Keep liver and '
              'cod liver oil off the menu until after pregnancy.'),
        ),
      ),
      PvReadSection(
        heading: _en('8. Is soya safe while trying?'),
        paragraphs: [
          _en('Yes, as food. Soya chunks, tofu and soy milk a few times a week '
              "haven't been shown to harm fertility. The worries mostly come "
              'from concentrated soy isoflavone pills, which are best left '
              'alone.'),
          _en('Soya chunks and tofu are among the most protein-rich foods a '
              'vegetarian kitchen has. That makes them useful in homes that '
              "don't cook eggs."),
        ],
      ),
      PvReadSection(
        heading: _en('9. Does sugar or packaged food matter?'),
        paragraphs: [
          _en('Some large studies have linked a lot of sugary drinks with '
              'taking longer to conceive, in both partners. They can\'t prove '
              'the drinks were the cause, but cutting sweet drinks is an easy '
              'change.'),
          _en("A piece of mithai at a wedding isn't a problem. What helps is "
              'making home food the everyday choice and packaged snacks the '
              'occasional one.'),
        ],
      ),
      PvReadSection(
        heading: _en('10. Does what he eats matter too?'),
        paragraphs: [
          _en('Yes. Sperm take about eleven weeks to make, so his food and '
              'habits now shape the sperm of a few months from now. The same '
              'plate works for him.'),
          _en("For him, stopping tobacco and cutting alcohol matter more than "
              "any single food. The evidence for men's fertility supplements is "
              'weak, so food comes first.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('I have PCOS. Is the advice different for me?'),
        answer: _en('Mostly the same, with more attention to steady meals, '
            'protein and fibre, because PCOS often affects how your body '
            'handles insulin. Our PCOS food read goes into it, and your own '
            "doctor's plan comes first."),
      ),
      PvReadFaq(
        question: _en('Can I keep fasting for religious reasons while trying?'),
        answer: _en('Occasional fasts are fine for most healthy women. Eat well '
            'before and after, and drink water where your fast allows. If you '
            'have diabetes, take regular medicine or are having fertility '
            'treatment, ask your doctor first.'),
      ),
      PvReadFaq(
        question: _en('Should I think about food safety already?'),
        answer: _en('A little. Boil milk or use pasteurised milk, make curd '
            'and paneer from it, wash fruit and vegetables well, and cook '
            'eggs and sprouts through. These habits carry into pregnancy.'),
      ),
      PvReadFaq(
        question: _en('My mother-in-law says to eat lots of ghee and dry fruit. '
            'Should I?'),
        answer: _en('Some is lovely, and it comes from care. You just don\'t '
            'need large amounts. A spoon of ghee and a small handful of nuts '
            'a day is plenty, and it keeps everyone happy.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to ask a doctor about food'),
      body: _en('Ask for a blood test in the next few weeks if you feel tired '
          'all the time, breathless or dizzy, or look pale. See a doctor soon '
          "if you're losing weight without trying, or have ongoing diarrhoea "
          'or bloating. If you have had an eating disorder, talk to a doctor '
          'before changing how you eat.'),
    ),
    evidence: _en('FOGSI Good Clinical Practice Recommendations on '
        'Preconception Care (folic acid 400 to 500 micrograms a day); ICMR-NIN '
        'Dietary Guidelines for Indians (2024); NHS guidance on vitamin A, '
        'liver and caffeine when trying and in pregnancy; ACOG guidance on '
        'caffeine in pregnancy (under 200 mg a day); NICE CG156 fertility '
        'guideline; Cochrane review of antioxidants for female subfertility '
        '(2020). Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("Record what you're taking"),
        value: _en('What you started and when, ready to show your doctor.'),
        surfaceId: 'ttc_supplements',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('See the blood tests'),
        value: _en('Haemoglobin, B12 and vitamin D explained, with what they '
            'cost in India.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.consult,
        title: _en('Ask your own questions'),
        value: _en('A nutritionist who can look at your tests and your '
            'kitchen.'),
        surfaceId: 'ttc_prepare',
      ),
    ],
    readNext: [
      'ttc_read_supplement_timing',
      'ttc_read_pcos_food',
      'ttc_read_iron_before_pregnancy',
    ],
  ),

  // ===========================================================================
  //  Iron before pregnancy
  // ===========================================================================
  //  ⚠️ TEST FIRST, THEN TREAT, the line `ttc_read_supplement_timing` already
  //  takes. The piece never tells her to start tablets on her own, and it
  //  carries the thalassaemia-trait caution because small red cells in India
  //  are not always low iron.
  PvRead(
    id: 'ttc_read_iron_before_pregnancy',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Iron before pregnancy: Indian foods, vitamin C and tea timing'),
    teaser: _en('Why low iron is worth fixing now, which everyday foods help '
        'most, and the small timing change that lets your body use them.'),
    shortAnswer: _en('Low iron is very common in Indian women, and pregnancy '
        'raises how much you need. Get your haemoglobin checked, eat iron foods '
        'with something sour like lemon or amla, and keep tea and coffee an hour '
        'away from meals. Take iron tablets only if a doctor advises them.'),
    scaleSetter: _en("Low iron is common and fixable, and it isn't why you "
        "haven't conceived. As far as we know, extra iron doesn't help you get "
        'pregnant if your levels are fine. The reason to check now is that '
        "it's much easier to correct before pregnancy than during it."),
    author: _en('Akanksha Srivastava'),
    authorRole: _en('Maternal and child nutritionist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('If you\'ve been told you\'re "a little anaemic" and nobody did '
              "anything about it, you're far from alone. In India's last "
              'national survey, NFHS-5 (2019 to 2021), about 57 per cent of '
              'women aged 15 to 49 had anaemia.'),
          _en("That's not a personal failing. It comes from meals built mostly "
              'on grains, plant iron that is harder to absorb, tea with food, '
              'and blood lost every month.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why does iron matter before pregnancy?'),
        paragraphs: [
          _en('Your red blood cells use iron to carry oxygen. When you\'re low '
              'you may feel tired, breathless on stairs, dizzy or cold. Many '
              'people feel nothing at all.'),
          _en('In pregnancy your blood volume rises by around half, and the '
              'baby builds its own iron store, mostly in the last months. That '
              'extra demand is hard to meet from a low start.'),
          _en('Anaemia in pregnancy is linked to babies born early or small, '
              'and to more trouble with blood loss around birth. Starting with '
              'good iron stores makes those problems less likely.'),
        ],
      ),
      PvReadSection(
        heading: _en('How do I know if my iron is low?'),
        paragraphs: [
          _en('A blood test, not a guess. Haemoglobin (Hb) is the usual first '
              "test. WHO counts anaemia in women who aren't pregnant as a "
              'haemoglobin below 12 grams per decilitre.'),
          _en('Ferritin shows how much iron you have stored. It can be low '
              'while your haemoglobin still looks normal, so your doctor may '
              'add it. Both tests are inexpensive and easy to get.'),
          _en("If you're already planning a check-up before trying, add both to "
              "the same visit. There's no need for a separate trip."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("Small red cells aren't always low iron"),
          body: _en('Thalassaemia trait also makes red cells small, and it can '
              "look like low iron on a blood count. Iron tablets won't change "
              'it. If your report shows small cells but your ferritin is '
              'normal, ask your doctor about the Hb HPLC test.'),
        ),
      ),
      PvReadSection(
        heading: _en('Which Indian foods have the most iron?'),
        paragraphs: [
          _en('Vegetarian food has plenty of iron. The catch is that plant iron '
              'is absorbed less easily than the iron in meat. So how you eat it '
              'matters as much as what you eat.'),
          _en('An easy rule: one iron food and one vitamin C food on the same '
              'plate at each main meal. Rajma with a lemon salad, palak dal with '
              'tomato, or chana chaat with lemon all count.'),
        ],
        bullets: [
          _en('Pulses: rajma, kala chana, kabuli chana, lobia, masoor and '
              'moong. A katori of dal at two meals a day adds up.'),
          _en('Soya: soya chunks and tofu.'),
          _en('Millets: bajra most of all, with ragi and jowar behind it.'),
          _en('Greens: chaulai (amaranth), methi, sarson, palak and drumstick '
              'leaves.'),
          _en('Seeds and nuts: til (sesame), pumpkin seeds and peanuts.'),
          _en('Dried fruit in small amounts: dates, raisins and dried figs.'),
          _en('If you eat them: eggs, chicken, fish and mutton, where iron is '
              'absorbed best. Liver is rich in iron but also very high in '
              "vitamin A, so it's best left out while trying."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I help my body absorb more?'),
        paragraphs: [
          _en('A few small habits help the same food give you more iron.'),
        ],
        bullets: [
          _en('Add vitamin C to iron meals: lemon on your dal, amla or guava on '
              'the side, tomato in the sabzi, or an orange after lunch.'),
          _en('Keep tea and coffee an hour away from meals, before and after. '
              "The tannins in them hold iron back. ICMR-NIN's dietary "
              'guidelines advise this gap.'),
          _en("If you take calcium tablets, take them at a different time from "
              'iron-rich meals or iron tablets.'),
          _en('Soak, sprout and ferment. Sprouted moong, idli, dosa and dhokla '
              'give up their iron more easily than the raw grain or dal.'),
          _en('Cook in an iron kadhai now and then. Some iron passes into the '
              'food, especially sour dishes cooked for a while.'),
        ],
        tip: PvReadTip(
          title: _en('The easiest change on this page'),
          body: _en('Move your chai. If you have it with breakfast, have it '
              "mid-morning instead. It's the same cup of tea, and your "
              'breakfast gives you more iron.'),
        ),
      ),
      PvReadSection(
        heading: _en('Which iron beliefs can I let go of?'),
        paragraphs: [
          _en('Spinach has iron, but it also has oxalates that hold on to it. '
              "Eat it gladly with other iron foods, and don't rely on it alone."),
          _en("Another belief is that you can't have curd or milk with iron "
              'foods at all. You can. The calcium effect matters most for '
              'tablets, so keep calcium tablets apart from iron and enjoy your '
              'curd.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Beetroot, pomegranate and jaggery will fix anaemia.'),
          fact: _en("They're good foods, but none is a strong source of iron in "
              "the amounts people eat. Beetroot's red colour isn't iron. Dal, "
              'chana, rajma, greens and millets eaten with lemon do much more.'),
        ),
      ),
      PvReadSection(
        heading: _en('Should I take iron tablets?'),
        paragraphs: [
          _en('Only if a blood test shows you need them and a doctor advises '
              "it. More iron isn't better when your levels are fine, and iron "
              "you don't need brings side effects for no benefit."),
          _en("Under the government's Anaemia Mukt Bharat programme, women of "
              'reproductive age can get weekly iron and folic acid tablets free '
              'at government health centres. If you are low, your doctor may '
              'suggest a different dose.'),
          _en('If you are prescribed iron, these help:'),
        ],
        bullets: [
          _en('Take it with water or lemon water, not with tea, coffee, milk or '
              'calcium.'),
          _en('Black stools are normal on iron and nothing to worry about.'),
          _en('If it causes constipation or nausea, tell your doctor. A '
              'different dose, a different form, or taking it with food can '
              'help.'),
          _en('Keep the strip out of reach of children. Iron tablets are '
              'dangerous if a child swallows several.'),
          _en('Recheck your haemoglobin when your doctor suggests, often after '
              'a month or two.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can iron help me get pregnant faster?'),
        answer: _en("Not as far as good evidence shows, if your levels are "
            'normal. Fixing anaemia matters for your health and for a '
            "pregnancy. It isn't a fertility treatment."),
      ),
      PvReadFaq(
        question: _en("I'm vegetarian. Will I always be low?"),
        answer: _en('No. Plenty of vegetarians have healthy iron levels. Pair '
            'iron foods with vitamin C, move your tea away from meals, and let '
            'a blood test tell you where you stand.'),
      ),
      PvReadFaq(
        question: _en('Do heavy periods make it worse?'),
        answer: _en('They can. Losing a lot of blood each month is a common '
            'reason for low iron. Tell your doctor, because heavy periods are '
            'worth looking into on their own.'),
      ),
      PvReadFaq(
        question: _en('Should my husband take iron too?'),
        answer: _en("Usually not. Men don't lose blood every month, so they "
            'rarely need extra iron unless a test shows it. Too much iron '
            'builds up more easily in men.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When low iron needs a doctor'),
      body: _en('Book a visit in the next few weeks if you feel tired all the '
          'time, get breathless on stairs, look pale, or crave ice, chalk or '
          'mitti. Book sooner if your periods soak a pad every hour or you pass '
          'large clots. Go to a doctor the same day if you have chest pain, a '
          'racing heart at rest, or you faint.'),
    ),
    evidence: _en('Ministry of Health and Family Welfare, National Family '
        'Health Survey (NFHS-5, 2019 to 2021), for anaemia in women aged 15 '
        'to 49; WHO guideline on haemoglobin cut-offs to define anaemia (2024) '
        'and on using ferritin to assess iron status (2020); ICMR-NIN Dietary '
        'Guidelines for Indians (2024), including avoiding tea and coffee an '
        'hour before and after meals; ICMR-NIN Indian Food Composition Tables '
        '(2017); Anaemia Mukt Bharat operational guidelines (Ministry of '
        'Health and Family Welfare); FOGSI preconception care recommendations. '
        'Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Find the blood tests'),
        value: _en('Haemoglobin, ferritin and Hb HPLC, with when to take them '
            'and what they cost.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Log a prescribed iron course'),
        value: _en('What you take and when, so your recheck has a date to '
            'measure from.'),
        surfaceId: 'ttc_supplements',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Cook for iron'),
        value: _en('Ten everyday recipes, several built around dal, chana and '
            'greens.'),
        surfaceId: 'ttc_read/ttc_read_everyday_recipes',
      ),
    ],
    readNext: [
      'ttc_read_everyday_recipes',
      'ttc_read_preconception_tests',
      'ttc_read_omega3_without_fish',
    ],
  ),

  // ===========================================================================
  //  Omega-3 without fish
  // ===========================================================================
  //  ⚠️ NO FERTILITY CLAIM. The evidence for omega-3 helping conception is
  //  small and mixed, so the piece says so and points to pregnancy, where the
  //  case is stronger. Cod liver oil gets its own line because it is the
  //  omega-3 product most Indian homes already have, and it carries retinol.
  PvRead(
    id: 'ttc_read_omega3_without_fish',
    hue: 104,
    kicker: _en('Getting ready'),
    title: _en('Omega-3 without fish: what vegetarians can eat'),
    teaser: _en('What omega-3 does, where a vegetarian kitchen finds it, and '
        'when a supplement is worth asking about.'),
    shortAnswer: _en('Omega-3 fats matter most once you\'re pregnant, for the '
        "baby's brain and eyes. Vegetarians get the plant form from ground "
        'flaxseed, walnuts, chia seeds, mustard oil and soya. There\'s no good '
        'evidence capsules help you conceive, so ask your doctor before buying '
        'one.'),
    scaleSetter: _en("This isn't urgent, and you haven't missed anything by not "
        'thinking about it. Omega-3 matters more in pregnancy than before it, '
        'and a few everyday foods cover the basics. Nothing here needs buying '
        'today.'),
    author: _en('Akanksha Srivastava'),
    authorRole: _en('Maternal and child nutritionist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Omega-3s are fats your body can't make on its own, so they have "
              'to come from food. You mostly hear about them with fish, which '
              'leaves many vegetarian families unsure what to do.'),
          _en('The good news is that your kitchen already has some. A few small '
              'habits cover the rest.'),
        ],
      ),
      PvReadSection(
        heading: _en('What are the different kinds?'),
        paragraphs: [
          _en('There are three worth knowing. ALA comes from plants. EPA and DHA '
              'come mainly from fish and seafood. DHA is the one that helps '
              'build the brain and the back of the eye.'),
          _en('Your body can turn some ALA into EPA and DHA, but only a small '
              "share, and very little becomes DHA. That's the main catch for "
              'vegetarians, and the reason this is worth a few minutes.'),
          _en('There is also omega-6, a different fat found in oils like '
              'sunflower, safflower and corn. You need some, but most Indian '
              'diets have far more omega-6 than omega-3. Mixing in oils that '
              'carry omega-3 helps even out that balance.'),
        ],
      ),
      PvReadSection(
        heading: _en('Does omega-3 help me get pregnant?'),
        paragraphs: [
          _en("There's no good evidence that omega-3 capsules help you "
              'conceive. Some studies have looked, but the results are small '
              'and mixed, and not enough to act on.'),
          _en("Where omega-3 matters more is pregnancy. The baby's brain and "
              'eyes grow fast in the last months, and DHA is a big part of '
              'both. A Cochrane review found that omega-3 in pregnancy lowered '
              'the rate of babies born early.'),
          _en("So getting used to omega-3 foods now means they're already part "
              'of your week when it counts. New habits are also easier to start '
              'before pregnancy nausea arrives than during it.'),
        ],
      ),
      PvReadSection(
        heading: _en('Where do vegetarians find omega-3?'),
        paragraphs: [
          _en('These are the richest plant sources that fit an Indian kitchen.'),
        ],
        bullets: [
          _en('Flaxseed (alsi). Grind it first, because whole seeds pass '
              'through without being digested. A spoon goes into atta, raita, '
              'chutney or curd.'),
          _en("Chia seeds. Soak them in water or milk. They don't need "
              'grinding.'),
          _en('Walnuts. A small handful a few times a week.'),
          _en('Mustard oil and soybean oil. Both carry ALA, so they earn a '
              'place in your mix of cooking oils.'),
          _en('Soya, tofu and rajma, which add a little alongside their '
              'protein.'),
          _en('Green leafy vegetables like methi and palak, in smaller '
              'amounts.'),
          _en("Til and peanuts are good foods, but their fat is mostly other "
              "kinds, so they don't add much omega-3."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I make it part of my week?'),
        paragraphs: [
          _en("You don't need a separate plan. Pick two or three of these and "
              'let them become habits.'),
        ],
        bullets: [
          _en('Keep ground flaxseed in the fridge and add a spoon to roti dough '
              'or curd most days.'),
          _en('Make alsi chutney, the dry Maharashtrian chutney, to eat with '
              'bhakri, roti or rice.'),
          _en('Add walnuts to your evening snack a few times a week.'),
          _en('Mix or rotate your cooking oils instead of using one oil for '
              "everything. ICMR-NIN's dietary guidelines recommend a mix."),
          _en('Add a spoon of soaked chia seeds to buttermilk, lemon water or '
              'a glass of milk.'),
        ],
        tip: PvReadTip(
          title: _en('Why keep flaxseed in the fridge?'),
          body: _en('The same fats that make ground flaxseed useful also go '
              'stale and bitter quickly at room temperature. Grind a small '
              'batch, keep it in an airtight jar in the fridge, and use it up '
              'within a few weeks.'),
        ),
      ),
      PvReadSection(
        heading: _en('What about eggs?'),
        paragraphs: [
          _en('If you eat eggs, they add a small amount of DHA. Some brands '
              'sell eggs from hens fed flaxseed, labelled as omega-3 eggs, which '
              "carry more. They're a helpful extra, not a must."),
          _en('Cook eggs until the white and the yolk are both firm, now and '
              'once you are pregnant.'),
          _en("If your home doesn't cook eggs, the seeds and oils above do the "
              'same job, and nothing is missing.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('If your family eats fish'),
          body: _en('Eating sardines (mathi) or mackerel (bangda) once or '
              'twice a week covers most of what this read is about. Skip large '
              'fish like shark and swordfish, which can carry more mercury.'),
        ),
      ),
      PvReadSection(
        heading: _en('Should I take a supplement?'),
        paragraphs: [
          _en('Not to help you conceive. If your doctor suggests DHA for '
              "pregnancy, there's a vegetarian option: DHA made from algae, "
              'which is where fish get theirs in the first place.'),
          _en("Fish oil capsules aren't vegetarian. And skip cod liver oil while "
              'trying and in pregnancy. It contains retinol, the form of '
              'vitamin A that can harm a baby in high amounts.'),
          _en('On the label, vegetarian DHA is usually called algal oil. If '
              'the capsule shell is gelatin, it may not be vegetarian even when '
              'the oil is, so check that too.'),
          _en("Check any capsule's label for vitamin A, and show the box to your "
              'doctor before you start. A supplement adds to good food. It '
              "doesn't replace it."),
        ],
      ),
      PvReadSection(
        heading: _en('Is it different for Jain or vegan kitchens?'),
        paragraphs: [
          _en('For a Jain kitchen, very little changes. Flaxseed, chia, walnuts, '
              'mustard oil and soya all fit, because none of them is a root '
              'vegetable. Alsi chutney can be made without garlic.'),
          _en('For a vegan kitchen, the plant sources are the same, and algal '
              'DHA is the one supplement that fits if your doctor suggests it. '
              'It is also worth asking for a vitamin B12 test, since B12 comes '
              'mainly from animal foods.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is flaxseed safe while trying?'),
        answer: _en('Yes, as food. A spoon or two of ground flaxseed a day is a '
            'normal amount. Flaxseed oil capsules and very large amounts are '
            'different, so ask your doctor before taking those.'),
      ),
      PvReadFaq(
        question: _en('Does my husband need omega-3 too?'),
        answer: _en('The same foods are good for him. Studies of omega-3 '
            'capsules for sperm are small and not clear, so food is the '
            'sensible place to start.'),
      ),
      PvReadFaq(
        question: _en('Is ghee a source of omega-3?'),
        answer: _en("Only a tiny amount. Ghee is fine in moderation, but it "
            "won't cover your omega-3. The seeds, nuts and oils above do much "
            'more.'),
      ),
      PvReadFaq(
        question: _en('Can I get too much omega-3?'),
        answer: _en("From food, it's very unlikely. High-dose capsules can thin "
            'the blood a little, so tell your doctor if you take one, '
            'especially before any procedure.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Check before starting a capsule'),
      body: _en('Talk to your doctor before any omega-3 capsule if you take a '
          'blood thinner such as aspirin or heparin, which some fertility '
          'clinics prescribe, or you have a bleeding disorder or a fish '
          'allergy. If your lips or face swell, or breathing gets hard after a '
          'new food or supplement, go to a hospital straight away.'),
    ),
    evidence: _en('WHO and FAO expert consultation on fats and fatty acids in '
        'human nutrition (2010); ICMR-NIN Dietary Guidelines for Indians (2024) '
        'on mixing cooking oils; NHS guidance on oily fish, fish liver oil and '
        'vitamin A when trying for a baby and in pregnancy; Cochrane review of '
        'omega-3 fatty acid supplementation in pregnancy (2018). Sources '
        'checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en("Record what you're taking"),
        value: _en('If your doctor suggests DHA, note when you started.'),
        surfaceId: 'ttc_supplements',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Back to: a week of meals'),
        value: _en('Where flaxseed, walnuts and the oil mix fit into an '
            'ordinary week.'),
        surfaceId: 'ttc_read/ttc_read_meal_plan_week',
      ),
    ],
    readNext: [
      'ttc_read_meal_plan_week',
      'ttc_read_ask_dietitian',
    ],
  ),
];
