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

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The nutrition bracket's hue.
const double _hue = 104;

final List<PvRead> kPregnancyReadsNutrition = [
  PvRead(
    id: 'preg_diet_read_add_now',
    hue: _hue,
    kicker: _en('Nutrition & diet'),
    title: _en('Add this to your plate now'),
    teaser: _en('One short list per stage. Not a diet — just what is worth '
        'adding to the food you already eat.'),

    scaleSetter: _en('You do not need to eat differently in pregnancy so much '
        'as eat a little more of a few things. Nothing below asks you to give '
        'anything up or to cook separately, and none of it needs a shop you do '
        'not already go to.'),

    author: _en('ParentVeda editorial'),
    authorRole: _en('Reviewed by Dr. Anita Desai, Obstetrician · September '
        '2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('The advice that reaches most pregnant women in India is a list '
              'of things to stop. This is the other list, and it is shorter '
              'than you would think: at each stage there are two or three '
              'things genuinely worth adding, and the rest of your plate can '
              'carry on as it is.'),
          _en('Find your stage below. Each one takes about a minute, and none '
              'of it replaces what your own doctor or dietician has told you — '
              'if they have given you a plan, theirs is the one that counts.'),
        ],
      ),

      PvReadSection(
        heading: _en('Before you are pregnant'),
        paragraphs: [
          _en('One thing matters more than everything else here, and it has to '
              'start early.'),
        ],
        bullets: [
          _en('Folic acid, every day, ideally from at least a month before you '
              'conceive. It works in the first few weeks — often before a '
              'pregnancy is confirmed — which is the whole reason it is worth '
              'starting in advance.'),
          _en('Iron-rich food, so you begin with stores rather than building '
              'them under pressure later. Dal, ragi, jaggery, greens, and meat '
              'if you eat it.'),
          _en('Iodised salt, if you are not already using it.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('This is the one with a deadline'),
          body: _en('Folic acid is the only item on any of these lists whose '
              'timing genuinely cannot be made up later. If you are trying, '
              'start it now.'),
        ),
      ),

      PvReadSection(
        heading: _en('First three months'),
        paragraphs: [
          _en('This is the stage where eating at all can be the difficulty, so '
              'the honest advice is small and forgiving.'),
        ],
        bullets: [
          _en('Whatever you can keep down, in small amounts, often. A day of '
              'toast and curd is not a failure; the baby is tiny and your '
              'stores are doing the work.'),
          _en('Keep the folic acid going, and keep whatever your doctor has '
              'prescribed going, even on the bad days.'),
          _en('Something salty and dry first thing, before you sit up — a '
              'biscuit or a piece of toast by the bed. It helps more people '
              'than it does not.'),
          _en('Fluids in sips through the day rather than a glass at once. '
              'Nimbu pani, coconut water, thin buttermilk.'),
        ],
        tip: PvReadTip(
          title: _en('If you cannot face it, do not force it'),
          body: _en('Appetite comes back. What matters in these weeks is '
              'fluids and your tablets, not a balanced plate — and if you '
              'cannot keep fluids down at all, that is a phone call rather '
              'than a diet problem.'),
        ),
      ),

      PvReadSection(
        heading: _en('Middle three months'),
        paragraphs: [
          _en('Appetite usually returns here, and this is the stretch where '
              'adding things actually works. Your blood volume is climbing and '
              'the baby is laying down bone.'),
        ],
        bullets: [
          _en('Add a second helping of dal, or an egg, or curd — protein is '
              'the thing most Indian pregnancy plates are short of, and it is '
              'the easiest to fix.'),
          _en('Calcium every day: curd, milk, paneer, ragi, sesame, or the '
              'tablet your doctor has given you. Keep it away from your iron '
              'tablet.'),
          _en('Iron with something sour in the same meal — lemon over the dal, '
              'tomato in the sabzi, amla or guava after. It changes how much '
              'you absorb far more than swapping foods does.'),
          _en('Fibre, before constipation starts rather than after. Fruit with '
              'the skin, whole dals, and enough water to make the fibre work.'),
        ],
      ),

      PvReadSection(
        heading: _en('Last three months'),
        paragraphs: [
          _en('The baby grows fastest now and your stomach has least room, so '
              'this stage is about frequency more than quantity.'),
        ],
        bullets: [
          _en('Smaller plates, more often. Five or six small meals sit far '
              'better than three large ones once there is no space left.'),
          _en('Keep the calcium and the iron going — this is the stretch that '
              'draws hardest on both, and it is also when tablets are most '
              'often quietly abandoned.'),
          _en('Something with omega-3 if you eat fish, twice a week; the '
              'baby\'s brain is doing its fastest growing. If you do not, ask '
              'about a supplement rather than assuming.'),
          _en('Water, more than feels necessary. Low fluid and constipation '
              'both track it, and heartburn is worse when you are dry.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Weight gain slows at the very end, and that is normal'),
          body: _en('Putting on little or nothing in the last week or two is '
              'ordinary. Your growth scans are how the baby is watched, not '
              'the bathroom scale.'),
        ),
      ),

      PvReadSection(
        heading: _en('After the birth, briefly'),
        collapsible: true,
        summary: _en('The one stage nobody prepares for, and the tablets '
            'usually continue.'),
        paragraphs: [
          _en('Most women are asked to keep taking iron and calcium for some '
              'months after delivery. A birth involves real blood loss and '
              'rebuilding stores takes far longer than losing them did.'),
          _en('If you are feeding, you need more of everything and noticeably '
              'more fluid — thirst is usually a reliable guide. This is not '
              'the moment for a restrictive diet, whatever anyone at home '
              'says about getting your figure back.'),
          _en('The diet charts in this section include an After-birth stage, '
              'which is the practical version of this paragraph.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor if'),
      body: _en('You cannot keep food or fluids down for more than a day, you '
          'are losing weight, you feel faint when you stand, or you are '
          'breathless at rest. Also call before starting any supplement '
          'nobody prescribed — more is not safer, and a few are genuinely '
          'risky in pregnancy.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Do I need to eat for two?'),
        answer: _en('No. The extra energy a pregnancy needs is closer to one '
            'small snack a day than a second plate, and almost none of it is '
            'needed in the first three months. What changes more than the '
            'amount is what is in it.'),
      ),
      PvReadFaq(
        question: _en('I am vegetarian. Am I missing something?'),
        answer: _en('Protein and B12 are the two worth watching, and both are '
            'manageable — dal, curd, paneer, sprouts and nuts for the first, '
            'and a supplement for the second, because B12 is genuinely hard to '
            'get without animal foods. The nutrient pages in this section go '
            'into both.'),
      ),
      PvReadFaq(
        question: _en('Can I follow this if my doctor gave me a diet chart?'),
        answer: _en('Follow theirs. A chart written for your reports and your '
            'readings beats any general list, including this one.'),
      ),
    ],

    evidence: _en('Indian Council of Medical Research dietary guidelines for '
        'Indians · Ministry of Health and Family Welfare Anemia Mukt Bharat '
        'and antenatal care guidance · WHO recommendations on antenatal '
        'nutrition · Reviewed September 2026.'),

    readNext: ['preg_cond_read_iron', 'preg_cond_read_sugar_india'],
  ),
];
