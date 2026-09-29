// =============================================================================
//  Nutrition & diet — the ONE read this door adds
// -----------------------------------------------------------------------------
//  ⚠️ ONE FILE, ONE ARTICLE, AND THAT IS THE WHOLE POINT OF THIS DOOR.
//
//  The Nutrition brief opens with a box headed *"Read this first: nothing here
//  is a new page to build"* and it is right. Every food page, craving page,
//  condition-diet page, nutrient page, recipe, diet chart and fasting topic
//  already ships. Walking the code confirmed all of it:
//
//    · 4 trimester guides, 11 condition guides, 12 nutrients, 5 whole-diet
//      cards, 16 recipes, 19 diet charts, 8 fasting topics, 6 craving cards,
//      the food checker with its Safe/Limit/Avoid list, the paid dietician
//      tiers, and the supplements video placeholder
//
//  So this door writes exactly TWO things, and only one of them is prose: the
//  trimester "add this now" guide below, and the appointment checklist in
//  `lib/data/checklists/pv_checklist_nutrition.dart`.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY THIS IS AN ARTICLE AND NOT FOUR CARDS
//  ---------------------------------------------------------------------------
//
//  The brief says *"'Add this to your plate now' [Guide] NEW (one short card
//  per trimester)"* — which reads as four cards on a rail.
//
//  It is one read with four sections instead, and the reasoning is about what
//  she is asking. "One short card per trimester" means she sees the card for
//  the stage she is IN; the other three are noise on a rail and would sit there
//  competing with the four existing stage guides right beside them. As one
//  read, the contents lists all four, the reader opens at the top, and she
//  scrolls one screen to hers.
//
//  It also keeps the chip honest. The brief marks it [Guide], and a Guide in
//  this engine opens `PvReaderScreen` — the same object every other guide on
//  every other door opens.
//
//  ⚠️ AND IT DOES NOT RESTATE THE STAGE GUIDES BESIDE IT. `kTrimesterGuides`
//  already covers what to eat in each third, at length. This answers a narrower
//  question — what is NEW this month, what to add to the plate you already
//  have — which is why every section below is a short list of additions rather
//  than a diet.
// =============================================================================

//
//  ---------------------------------------------------------------------------
//  2026-09-29, the pregnancy warmth pass (docs/PREG-VOICE.md, and the
//  pregnancy gap analysis as the source of truth)
//  ---------------------------------------------------------------------------
//  The "one read" rule above belonged to the rebuild brief. The gap analysis
//  asks this door for two more, so there are now three:
//
//    · `preg_diet_read_weight`: "How much weight is right for me?", P1. It
//      uses the Asian BMI cut-offs (18.5 / 23 / 25), the ones the TTC weight
//      read already uses, and gives gain ranges only as ranges her doctor may
//      use, never as her target.
//    · `preg_diet_read_food_myths`: the food beliefs she hears at home, P2
//      (Appendix A, "3 common pregnancy food myths debunked", our own version).
//
//  The first read was rewritten to the voice, and its byline no longer names
//  a reviewer nobody can vouch for: it is `reviewed: false`, ParentVeda
//  editorial, until a real doctor has read it.

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The nutrition bracket's hue.
const double _hue = 104;

/// The byline every read here carries until a real doctor has read it.
final LocalizedText _desk = _en('ParentVeda editorial');
final LocalizedText _role = _en('Nutrition');

final List<PvRead> kPregnancyReadsNutrition = [
  PvRead(
    id: 'preg_diet_read_add_now',
    hue: _hue,
    kicker: _en('Nutrition & diet'),
    title: _en('Add this to your plate now'),
    teaser: _en('One short list for each stage. Not a diet, just what to add '
        'to the food you already eat.'),

    shortAnswer: _en("You don't need a new diet in pregnancy. At each stage, "
        "two or three things are worth adding to the plate you already have: "
        "folic acid early, then protein, iron and calcium, then smaller meals "
        "more often."),

    scaleSetter: _en("Pregnancy asks you to eat a little more of a few things, "
        "not to eat differently. Nothing below asks you to give anything up or "
        "cook separately, and you'll find all of it at the shops you already "
        "use."),

    author: _desk,
    authorRole: _role,
    reviewed: false,

    sections: [
      PvReadSection(
        paragraphs: [
          _en("Most of the food advice you'll hear in India is a list of things "
              "to stop. This is the other list, and it's shorter than you'd "
              "think. At each stage there are two or three things worth adding. "
              "The rest of your plate can stay as it is."),
          _en("Find your stage below. Each one takes about a minute. None of it "
              "replaces what your own doctor or dietician has told you. If "
              "they've given you a plan, follow theirs."),
        ],
      ),

      PvReadSection(
        heading: _en('Before you are pregnant'),
        paragraphs: [
          _en('One thing matters more than the rest here, and it has to start '
              'early.'),
        ],
        bullets: [
          _en("Folic acid, every day, ideally from at least a month before you "
              "conceive. It does its work in the first few weeks, often before "
              "you know you're pregnant. That's why it's worth starting early."),
          _en('Iron-rich food, so you start with good stores instead of '
              'building them in a hurry later. Dal, ragi, jaggery, greens, and '
              'meat if you eat it.'),
          _en("Iodised salt, if you aren't using it already."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('This is the one with a deadline'),
          body: _en("Folic acid is the only thing on these lists whose timing "
              "can't be made up later. If you're trying, start it now."),
        ),
      ),

      PvReadSection(
        heading: _en('First three months'),
        paragraphs: [
          _en('At this stage, eating at all can be the hard part. So the advice '
              'is small and forgiving.'),
        ],
        bullets: [
          _en("Whatever you can keep down, in small amounts, often. A day of "
              "toast and curd isn't a failure. Your baby is tiny and your "
              "stores are doing the work."),
          _en("Keep taking folic acid and whatever your doctor has prescribed, "
              "even on the bad days."),
          _en("Something dry and salty first thing, before you sit up. Keep a "
              "biscuit or a piece of toast by the bed. It helps most people."),
          _en('Sip fluids through the day instead of a full glass at once. '
              'Nimbu pani, coconut water, thin buttermilk.'),
        ],
        tip: PvReadTip(
          title: _en("If you can't face food, don't force it"),
          body: _en("Your appetite will come back. What matters in these weeks "
              "is fluids and your tablets, not a balanced plate. If you can't "
              "keep fluids down at all, call your doctor. That's a medical "
              "problem, not a diet problem."),
        ),
      ),

      PvReadSection(
        heading: _en('Middle three months'),
        paragraphs: [
          _en('Appetite usually comes back now, and this is when adding things '
              "works best. Your blood volume is rising and your baby's bones "
              'are forming.'),
        ],
        bullets: [
          _en('Add a second helping of dal, an egg, or a bowl of curd. Protein '
              'is what most Indian pregnancy plates are short of, and it is '
              'the easiest gap to fill.'),
          _en('Calcium every day: curd, milk, paneer, ragi, sesame, or the '
              'tablet your doctor gave you. Take it at a different time from '
              'your iron tablet.'),
          _en("Have iron with something sour in the same meal: lemon on the "
              "dal, tomato in the sabzi, amla or guava after. It changes how "
              "much iron you absorb far more than swapping foods does."),
          _en('Fibre, before constipation starts. Fruit with the skin on, whole '
              'dals, and enough water to help the fibre work.'),
        ],
      ),

      PvReadSection(
        heading: _en('Last three months'),
        paragraphs: [
          _en('Your baby grows fastest now and your stomach has the least room. '
              'So this stage is about eating more often, not more at once.'),
        ],
        bullets: [
          _en('Smaller plates, more often. Five or six small meals sit much '
              'better than three big ones once space runs out.'),
          _en("Keep taking your calcium and iron. These months draw hardest on "
              "both, and it's also when many women stop their tablets without "
              "meaning to."),
          _en("Fish twice a week for omega-3, if you eat it. Your baby's brain "
              "is growing fastest now. If you don't eat fish, ask your doctor "
              "about a supplement."),
          _en("More water than feels necessary. Low fluid makes constipation "
              "worse, and heartburn is worse when you're dry."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Weight gain slows at the very end, and that is normal'),
          body: _en("Putting on little or nothing in the last week or two is "
              "ordinary. Your baby's growth is watched on scans, not on the "
              "bathroom scale."),
        ),
      ),

      PvReadSection(
        heading: _en('After the birth, briefly'),
        collapsible: true,
        summary: _en('The stage nobody prepares for. The tablets usually carry '
            'on.'),
        paragraphs: [
          _en('Most women are asked to keep taking iron and calcium for some '
              'months after delivery. Birth means real blood loss, and '
              'rebuilding your stores takes far longer than losing them did.'),
          _en("If you're breastfeeding, you need more of everything and a lot "
              "more fluid. Your thirst is usually a good guide. This isn't the "
              "time for a strict diet, whatever anyone at home says about "
              "getting your figure back."),
          _en('The diet charts in this section include an After delivery chart. '
              "It's the practical version of this paragraph."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor if'),
      body: _en("You can't keep food or fluids down for more than a day, you're "
          "losing weight, you feel faint when you stand, or you're breathless "
          "at rest. Also ask before starting any supplement nobody prescribed. "
          "More isn't safer, and a few are risky in pregnancy."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Do I need to eat for two?'),
        answer: _en("No. The extra energy you need is closer to one small snack "
            "a day than a second plate, and you need almost none of it in the "
            "first three months. What's on the plate changes more than how "
            "much."),
      ),
      PvReadFaq(
        question: _en("I'm vegetarian. Am I missing something?"),
        answer: _en("Protein and B12 are the two to watch, and you can manage "
            "both. Dal, curd, paneer, sprouts and nuts cover protein. B12 is "
            "hard to get without animal foods, so a supplement usually helps. "
            "The nutrient pages in this section cover both."),
      ),
      PvReadFaq(
        question: _en('Can I follow this if my doctor gave me a diet chart?'),
        answer: _en('Follow theirs. A chart written for your own reports and '
            'readings is better than any general list, including this one.'),
      ),
    ],

    evidence: _en('Indian Council of Medical Research dietary guidelines for '
        'Indians · Ministry of Health and Family Welfare Anemia Mukt Bharat '
        'and antenatal care guidance · WHO recommendations on antenatal '
        'nutrition.'),

    readNext: ['preg_diet_read_weight', 'preg_cond_read_iron', 'preg_cond_read_sugar_india'],
  ),

  // ---------------------------------------------------------------------------
  //  How much weight is right for me? (gap analysis P1, 2026-09-29)
  // ---------------------------------------------------------------------------
  //  ⚠️ ASIAN CUT-OFFS, AND RANGES THAT ARE HER DOCTOR'S. The BMI groups are
  //  the ones ICMR and the WHO Asia-Pacific consultation use for South Asian
  //  bodies (see `lib/ttc/ttc_bmi_rules.dart`, which the TTC weight read
  //  already follows). The gain ranges are the Institute of Medicine's, put
  //  against those groups, and are stated as ranges a doctor may use, never
  //  as her number: the target is clinician-owned (CLAUDE.md, clinical
  //  ownership). The app's weight tracker still uses the Western cut-offs
  //  (`ToolsStore.recommendedGain`); the lead owns that change.
  PvRead(
    id: 'preg_diet_read_weight',
    hue: _hue,
    kicker: _en('Nutrition & diet'),
    title: _en('How much weight is right for me?'),
    teaser: _en('Weight gain in plain words, with the BMI groups used for '
        'Indian women.'),

    shortAnswer: _en("There's no one right number. Your doctor works out a "
        "healthy range from your weight and height before pregnancy (your "
        "BMI), then checks that you gain steadily within it. For Indian women "
        "the BMI groups are lower than on Western charts, and your doctor sets "
        "your own range."),

    scaleSetter: _en("Healthy gains range from about 5 kg to 18 kg, depending "
        "on where you started. A steady gain matters more than the exact "
        "total. Most of it isn't fat: it's your baby, the placenta, and extra "
        "blood and fluid."),

    author: _desk,
    authorRole: _role,
    reviewed: false,

    sections: [
      PvReadSection(
        heading: _en("Why is my range different from my friend's?"),
        paragraphs: [
          _en("Because it depends on where each of you started. Doctors use "
              "your BMI from before pregnancy: your weight in kilos divided by "
              "your height in metres, squared."),
          _en("For example, 55 kg at 1.58 m is a BMI of about 22. If you don't "
              "know your weight from before, your first antenatal visit is "
              "usually the starting point."),
        ],
      ),

      PvReadSection(
        heading: _en('Which BMI groups are used for Indian women?'),
        paragraphs: [
          _en('South Asian bodies tend to carry more fat around the middle at '
              'the same weight, so health risks start at a lower BMI. That is '
              'why ICMR and the WHO Asia-Pacific guidance use lower cut-offs '
              'for us:'),
        ],
        bullets: [
          _en('Below 18.5: underweight'),
          _en('18.5 to 22.9: normal'),
          _en('23 to 24.9: overweight'),
          _en('25 and above: obese'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Western charts draw the lines higher'),
          body: _en('Many charts and apps count "normal" up to 24.9 and obese '
              'from 30. Those lines were set for European bodies. If a chart '
              'online puts you in a different group, the Asian groups above '
              'are the ones that fit you better.'),
        ),
      ),

      PvReadSection(
        heading: _en('What range might my doctor use?'),
        paragraphs: [
          _en('Many doctors use the gain ranges from the US Institute of '
              'Medicine, matched to your BMI group. For a single baby, they '
              'are roughly:'),
        ],
        bullets: [
          _en('Underweight: about 12.5 to 18 kg'),
          _en('Normal: about 11.5 to 16 kg'),
          _en('Overweight: about 7 to 11.5 kg'),
          _en('Obese: about 5 to 9 kg'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('These are ranges, not your target'),
          body: _en("Some doctors in India use slightly different numbers, and "
              "twins have ranges of their own. Your doctor sets yours. If "
              "their number is different from this list, follow theirs."),
        ),
      ),

      PvReadSection(
        heading: _en('How fast does it usually go on?'),
        paragraphs: [
          _en("Slowly at first. Many women gain only 0.5 to 2 kg in the first "
              "three months, and some lose a little with nausea. That's common "
              "and usually made up later."),
          _en("From the fourth month the gain gets steadier. For a woman who "
              "started in the normal range, that's often around 350 to 500 g "
              "a week. It's rarely an even line: a heavy week and a flat week "
              "often balance out."),
        ],
      ),

      PvReadSection(
        heading: _en('Where does the weight go?'),
        paragraphs: [
          _en("It helps to know what the number is made of. For a gain of "
              "about 12 kg, it's roughly:"),
        ],
        bullets: [
          _en('Your baby: about 3 to 3.5 kg'),
          _en('The placenta: about 0.7 kg'),
          _en('The water around your baby (amniotic fluid): about 0.8 kg'),
          _en('Your growing womb: about 1 kg'),
          _en('Your breasts: about 0.5 kg'),
          _en('Extra blood: about 1.2 to 1.5 kg'),
          _en('Extra fluid in your body: about 1.5 kg'),
          _en('Stores of fat for breastfeeding: about 3 kg'),
        ],
        tip: PvReadTip(
          title: _en("Most of it isn't fat"),
          body: _en("Less than a third of a healthy gain is fat, and your body "
              "lays it down on purpose, to feed your baby after birth. Much "
              "of the rest leaves in the first weeks after delivery."),
        ),
      ),

      PvReadSection(
        heading: _en('How much more should I eat?'),
        paragraphs: [
          _en("Less than you'd think. In the first three months you need no "
              "extra food. From the fourth month, ICMR-NIN suggests about 350 "
              "extra calories a day."),
          _en("That's about one small extra meal: a glass of milk with a "
              "handful of peanuts, or a bowl of dal with a roti. It isn't a "
              "second plate at every meal."),
        ],
      ),

      PvReadSection(
        heading: _en("What if I'm gaining faster or slower?"),
        paragraphs: [
          _en("First, don't judge it by one week. Clothes, salt, a heavy meal "
              "and the time of day can move the scale by a kilo."),
          _en("If the pattern over a month sits above or below your range, "
              "your doctor will usually look at your food, your blood sugar "
              "and your baby's growth on scans before suggesting any change. "
              "A change is almost always small: a snack swapped, a walk "
              "added, an extra glass of milk. It isn't a sign you've done "
              "anything wrong."),
        ],
      ),

      PvReadSection(
        heading: _en('Should I diet if I started heavier?'),
        paragraphs: [
          _en("No. Pregnancy isn't the time to lose weight, and it isn't the "
              "time for keto, low-carb or crash diets either. Your baby needs "
              "a steady supply of food every day."),
          _en("What helps is a gentler gain inside the range your doctor sets: "
              "a balanced plate, fewer fried and packaged snacks, and a daily "
              "walk if your doctor says it's fine. The diet page for starting "
              "pregnancy heavier has more."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When should I call my doctor?'),
      body: _en("Call your doctor today if you gain weight suddenly along with "
          "swelling in your face or hands, a bad headache or blurred vision. "
          "These can be signs of high blood pressure in pregnancy. Also tell "
          "your doctor if you keep losing weight after the first three months, "
          "or can't keep food down."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Why does my doctor weigh me at every visit?'),
        answer: _en("To see the pattern. One reading means little. A steady "
            "line tells your doctor things are on track, and a sudden jump or "
            "a long flat stretch tells them to look a little closer."),
      ),
      PvReadFaq(
        question: _en('I lost weight in the first trimester. Is that okay?'),
        answer: _en("A small drop from nausea is common and usually made up in "
            "the middle months. If you can't keep food or fluids down, or keep "
            "losing weight, tell your doctor."),
      ),
      PvReadFaq(
        question: _en("I'm carrying twins. Is my range different?"),
        answer: _en('Yes, it is higher than for one baby. Your doctor will give '
            'you the range for twins, and the Carrying twins diet page has more '
            'on eating for two babies.'),
      ),
      PvReadFaq(
        question: _en('Will I be able to lose it after the birth?'),
        answer: _en("Most women lose a good part of it in the first weeks, as "
            "the baby, placenta and extra fluid go. The rest usually comes off "
            "slowly over the following months, and breastfeeding can help. "
            "There's no rush."),
      ),
    ],

    evidence: _en('ICMR-NIN, Nutrient Requirements for Indians (2020) and '
        'Dietary Guidelines for Indians (2024) · WHO Expert Consultation on '
        'BMI in Asian populations (2004) · Institute of Medicine, Weight Gain '
        'During Pregnancy (2009).'),

    readNext: ['preg_diet_read_add_now', 'preg_diet_read_food_myths'],
  ),

  // ---------------------------------------------------------------------------
  //  What they say at home, and what's true (gap analysis Appendix A, P2)
  // ---------------------------------------------------------------------------
  //  ⚠️ EVERY ANSWER HERE AGREES WITH IS IT SAFE?. Papaya, pineapple, saffron,
  //  ghee and tea are all answered in `can_i_data.dart`; this read says the
  //  same thing in the same direction, because two answers to one question is
  //  the defect the gap analysis names first. Nothing here touches the baby's
  //  sex (PCPNDT Act).
  PvRead(
    id: 'preg_diet_read_food_myths',
    hue: _hue,
    kicker: _en('Nutrition & diet'),
    title: _en("What they say at home, and what's true"),
    teaser: _en('The food beliefs you hear most, answered kindly, so you can '
        'answer them too.'),

    shortAnswer: _en("Most family food advice comes from love, and some of it "
        "is sound. Ghee won't make labour easier, saffron won't change your "
        "baby's skin colour, and a little ripe papaya or a few slices of "
        "pineapple are generally considered fine. Raw papaya is still worth "
        "skipping."),

    scaleSetter: _en("Your mother and mother-in-law want the best for you and "
        "your baby. Where their advice is kind to your body, keep it. Where "
        "it isn't true, here's what is, in words you can use at the table."),

    author: _desk,
    authorRole: _role,
    reviewed: false,

    sections: [
      PvReadSection(
        paragraphs: [
          _en("Most of these beliefs began as care. When there were no scans "
              "or blood tests, families watched what a pregnant woman ate and "
              "remembered what seemed to go well. Some of that wisdom holds "
              "up: dal, curd, greens and ghee in small amounts are good food."),
          _en("Other beliefs have been checked since and don't hold up. Below "
              "are the ones you're most likely to hear, with what's true and "
              "what you can do instead."),
        ],
      ),
      PvReadSection(
        heading: _en('Will extra ghee make the birth easier?'),
        mythFact: PvMythFact(
          myth: _en('Eat lots of ghee in the last months and the baby will slip '
              'out easily.'),
          fact: _en("Ghee doesn't loosen anything or make labour shorter. A "
              "spoon or two a day in your cooking is fine. Bowls of it add "
              "weight without helping the birth."),
        ),
      ),
      PvReadSection(
        heading: _en("Will kesar milk change my baby's skin colour?"),
        mythFact: PvMythFact(
          myth: _en('Saffron milk every night will make the baby fair.'),
          fact: _en("Your baby's skin colour comes from your family's genes, "
              "and no food changes it. A pinch of kesar in warm milk is fine "
              "and can be a nice way to wind down. Keep it to a pinch, not "
              "more."),
        ),
      ),
      PvReadSection(
        heading: _en('Do papaya and pineapple cause a miscarriage?'),
        mythFact: PvMythFact(
          myth: _en('One bite of papaya or pineapple can end a pregnancy.'),
          fact: _en("Ripe papaya in small amounts is generally considered fine. "
              "Raw or unripe papaya is the kind to skip, because it has more "
              "latex. A few slices of pineapple are fine too. You'd have to "
              "eat a very large amount for its enzyme to matter."),
        ),
      ),
      PvReadSection(
        heading: _en('Are "hot" foods like eggs and mango harmful?'),
        mythFact: PvMythFact(
          myth: _en('Eggs, mango and other "garam" foods heat the womb and '
              'harm the baby.'),
          fact: _en("There's no evidence that any food heats the womb. "
              "Well-cooked eggs are one of the best proteins you can eat. "
              "Mango is a good fruit too, in sensible amounts, especially if "
              "your blood sugar is being watched."),
        ),
      ),
      PvReadSection(
        heading: _en('Will tea make my baby dark?'),
        mythFact: PvMythFact(
          myth: _en('Drinking tea or coffee in pregnancy makes the baby dark.'),
          fact: _en("Tea has nothing to do with skin colour. What matters is the "
              "caffeine: keep it under about 200 mg a day, which is roughly two "
              "to three cups of normal chai."),
        ),
      ),
      PvReadSection(
        heading: _en('Should I eat for two now?'),
        mythFact: PvMythFact(
          myth: _en("You're eating for two, so eat double."),
          fact: _en("You need no extra food in the first three months, and "
              "about one small extra meal a day after that. What's on the "
              "plate matters more than how much."),
        ),
      ),
      PvReadSection(
        heading: _en('Will curd or banana give my baby a cold?'),
        mythFact: PvMythFact(
          myth: _en('Curd, banana and other "thanda" foods will give the baby '
              'a cold or a cough.'),
          fact: _en("Your baby can't catch a cold from what you eat. Colds come "
              "from viruses. Curd and banana are both good foods in "
              "pregnancy. If curd at night bothers your own throat or "
              "stomach, have it at lunch instead."),
        ),
      ),
      PvReadSection(
        heading: _en('Should I drink less water so my feet swell less?'),
        mythFact: PvMythFact(
          myth: _en('Drink less water in the last months, or your feet will '
              'swell.'),
          fact: _en("Swelling in the feet comes from the weight of your womb and "
              "the extra fluid pregnancy brings, not from the water you drink. "
              "Cutting water makes constipation and tiredness worse. Keep "
              "drinking, and put your feet up when you can. Sudden swelling of "
              "your face or hands is different: call your doctor today."),
        ),
      ),
      PvReadSection(
        heading: _en("Will coconut water make my baby's skin clear?"),
        mythFact: PvMythFact(
          myth: _en('Drink coconut water every day and the baby will be born '
              'clean and clear.'),
          fact: _en("Nothing you drink changes your baby's skin. Coconut water "
              "is still a good drink: it keeps you hydrated and is gentle on "
              "a queasy stomach. Fresh from a tender coconut is best."),
        ),
      ),
      PvReadSection(
        heading: _en('Is a bigger baby a healthier baby?'),
        mythFact: PvMythFact(
          myth: _en('Eat more, so the baby is born big and strong.'),
          fact: _en("Bigger isn't always better. Your baby's size depends on "
              "your genes, the placenta and your health, not only on how much "
              "you eat. A very large baby can make the birth harder. Steady, "
              "varied meals help your baby grow at the pace that's right for "
              "them, and your scans show how that's going."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I say this at home?'),
        paragraphs: [
          _en("Gently, and with something to agree on. \"My doctor says a "
              "spoon of ghee is enough, but I'd love your dal every day\" "
              "lands better than \"that's a myth\"."),
          _en('If it helps, show them this page, or ask them to come to your '
              'next visit and ask the doctor together.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When should I call my doctor?'),
      body: _en("Call your doctor today if, after eating something, you get a "
          "fever, or vomiting or diarrhoea that won't stop, or you can't keep "
          "fluids down. For everyday questions about a food, check Is it "
          "safe? or ask at your next visit. If your doctor has told you "
          "something different about a food, follow your doctor."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('My mother-in-law insists on something I am unsure about. '
            'What do I do?'),
        answer: _en("Look it up in Is it safe? first. If it's fine, eating it "
            "may keep the peace. If it isn't, a line from your doctor is "
            "usually easier for her to accept than a line from an app."),
      ),
      PvReadFaq(
        question: _en('Should I eat only home-cooked food?'),
        answer: _en("Home food is the safest, because you know the water and "
            "how it was made. Outside food is fine now and then if it's "
            "freshly cooked and served hot. The ones to skip are roadside "
            "foods made with water, like pani puri, and cut fruit or salad "
            "that has been standing."),
      ),
      PvReadFaq(
        question: _en('Are traditional foods like panjiri and gond laddoo okay?'),
        answer: _en("In small amounts, usually yes. They're rich in ghee, sugar "
            "and nuts, so one piece is a treat, not a meal. If your blood "
            "sugar or weight is being watched, ask your doctor first."),
      ),
    ],

    evidence: _en('ICMR-NIN, Dietary Guidelines for Indians (2024) · WHO '
        'recommendations on antenatal care (2016) · ParentVeda Is it safe? '
        'answers, kept in step with this page.'),

    readNext: ['preg_diet_read_add_now', 'preg_diet_read_weight'],
  ),
];
