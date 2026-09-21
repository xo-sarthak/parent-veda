// =============================================================================
//  What a diet chart actually contains
// -----------------------------------------------------------------------------
//  ⚠️ BEFORE THIS FILE, A DIET CHART HAD NO CONTENT AT ALL. `DietChart` held a
//  title, a description and a category. The detail screen showed the
//  description, then a grey box *describing* what the chart would contain — "a
//  breakfast, lunch, one or two snacks and a dinner for each day" — and then a
//  Download button that called an empty function and raised a snackbar saying
//  "Download starting shortly. It will also be saved in your account."
//
//  ⚠️ THE BUTTON WAS NOT DEAD. IT LIED. That distinction is the whole reason
//  this was worth doing first: a dead button teaches her the app is unfinished,
//  and she tries something else. A button that confirms teaches her the app
//  works, and she goes looking in a Downloads folder for a file that was never
//  created. The second costs her time and costs us the belief that our
//  confirmations mean anything. It is the same shape as the Mind & Mood booking
//  sheet, in a different section, written by different hands — which is what
//  makes it worth naming rather than just fixing.
//
//  ---------------------------------------------------------------------------
//  WHY THREE DAYS AND NOT SEVEN
//  ---------------------------------------------------------------------------
//  The old grey box promised a week. Seven distinct days per chart, across
//  fifteen charts, is a hundred and five days of invented Indian meal plans —
//  and the invention is the problem, not the volume. Days four through seven
//  would be days one through three with the vegetables swapped, which is
//  padding a mother has to read through to discover it is padding.
//
//  What a dietitian actually hands over is a *pattern*: a few worked days, the
//  swaps that keep it from getting boring, and the short list of what to hold
//  back on. So that is the shape — `days` (three, genuinely different),
//  `swaps`, and `limits`. It is smaller than the promise and larger than the
//  delivery, and it is honest about being a pattern rather than a prescription.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE SIDE-TABLE PATTERN, AND WHY IT IS USED AGAIN HERE
//  ---------------------------------------------------------------------------
//  Keyed by chart id, exactly like `kChartFacets` in `diet_chart_facets.dart`,
//  and for the reason stated there: `kDietCharts` lives in `nutrition_data.dart`
//  beside six other sections, and adding four fields to `DietChart` would touch
//  all fifteen of its literals in a 2,000-line file. It also keeps the gap
//  visible — a chart with no entry here has no content, and a test fails on it
//  rather than letting the screen quietly render a heading with nothing under
//  it, which is the failure this file exists to end.
//
//  ---------------------------------------------------------------------------
//  ⚠️ HINDI IS OWED, NOT CLAIMED — AND NOTHING HERE CLAIMS IT
//  ---------------------------------------------------------------------------
//  Fourteen of these are `_en(...)`: English now, Hindi owed, greppable. One —
//  `hindi_chart` — is written in Devanagari, because it is the one chart whose
//  entire point is the language.
//
//  That is not a note for a human to keep in sync. `hasHindiContent()` below
//  DERIVES the answer from the text, so the "In Hindi" filter cannot claim a
//  chart the translator has not reached. See its comment for why a derived flag
//  was the actual fix here and a corrected boolean would not have been.
// =============================================================================

import '../localization/app_language.dart';
import 'diet_chart_days_more.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);
LocalizedText _t(String en, String hi) => LocalizedText(en: en, hi: hi);

/// One meal on one day.
class ChartMeal {
  const ChartMeal(this.meal, this.items);

  /// "Breakfast", "Mid-morning". Short, because it sits in a narrow column.
  final LocalizedText meal;

  /// What to eat, in the plain everyday style the rest of Nutrition uses —
  /// named dishes a mother already cooks, not grams of macronutrients.
  final LocalizedText items;
}

/// A worked day.
class ChartDay {
  const ChartDay({required this.label, required this.meals});

  /// ⚠️ "DAY 1", NOT "MONDAY". A chart that starts on Monday is wrong six days
  /// out of seven, and a mother who reads it on a Thursday either waits or
  /// feels behind before she has begun.
  final LocalizedText label;
  final List<ChartMeal> meals;
}

/// Everything a chart holds beyond its title.
class ChartContent {
  const ChartContent({
    required this.focus,
    required this.days,
    required this.swaps,
    required this.limits,
    this.doctorNote,
  });

  /// One paragraph: what this chart is optimising for, so she can tell in five
  /// seconds whether it is hers.
  final LocalizedText focus;

  final List<ChartDay> days;

  /// What to substitute — the thing that turns three days into a month.
  final List<LocalizedText> swaps;

  /// What to hold back on. Deliberately "limits" and not "avoid": almost
  /// nothing in an Indian kitchen is forbidden in pregnancy, and a forbidden
  /// list invites the guilt this section exists to reduce.
  final List<LocalizedText> limits;

  /// ⚠️ ONLY WHERE A CLINICIAN OWNS THE DECISION. Present on the gestational
  /// diabetes and weight charts because both are managed to numbers a doctor
  /// sets, and a chart that reads as a substitute for that is the app competing
  /// with her clinician — which `CLAUDE.md`'s clinical-ownership rule forbids.
  /// Null on the rest, rather than a generic disclaimer stamped everywhere: a
  /// disclaimer on every screen is a disclaimer nobody reads on the one screen
  /// that needed it.
  final LocalizedText? doctorNote;
}

/// Whether this chart's body genuinely exists in Hindi.
///
/// ⚠️ DERIVED, NEVER DECLARED, AND THAT IS THE ENTIRE FIX. The "In Hindi"
/// filter used to read a hand-set boolean, and eight charts carried
/// `inHindi: true` while not one word of Hindi existed anywhere in the section.
/// Nothing failed. The filter worked perfectly — it returned eight charts, as
/// asked, and every one of them was in English.
///
/// ⚠️ THE GENERAL LESSON, WHICH IS WORTH MORE THAN THE FIX: **a flag that
/// describes data should be computed from that data, not typed beside it.** A
/// typed flag is a claim, and a claim can be true when written and false three
/// commits later with nobody in a position to notice — there is no compiler for
/// "this is still accurate". Correcting the eight booleans would have fixed
/// today and left the mechanism intact for the next person to translate a chart
/// and forget to flip its flag, or flip a flag and never translate.
///
/// ⚠️ AND IT FAILS IN THE RIGHT DIRECTION NOW. Translate a chart and its Hindi
/// row appears on its own; the filter can under-report while a translation is
/// half-done, and under-reporting shows a mother one chart fewer, where
/// over-reporting hands a Hindi-speaking mother a page of English.
///
/// ⚠️ THE ONE LIMITATION, STATED SO IT IS NOT DISCOVERED LATER: `_en(s)` and
/// `_same(s)` both produce `hi == en`, so a chart written entirely in strings
/// that are identical by nature would read as untranslated. For prose this is
/// not a real case — a day of meals cannot be a proper noun — but if this
/// heuristic is ever moved to a surface made of short labels, it needs a real
/// marker on `LocalizedText` instead.
bool hasHindiContent(String chartId) {
  final c = kChartContent[chartId];
  if (c == null) return false;
  bool translated(LocalizedText t) => t.hi.trim() != t.en.trim();
  if (!translated(c.focus)) return false;
  // Every day must be translated, not just the first. A chart that switches to
  // English on day two is worse than one that never claimed Hindi.
  for (final d in c.days) {
    for (final m in d.meals) {
      if (!translated(m.items)) return false;
    }
  }
  return true;
}

// =============================================================================
//  The charts
// =============================================================================
//  ⚠️ EVERY DISH HERE IS ONE SOMEBODY ACTUALLY COOKS. The temptation with a
//  chart like this is a nutritionally tidy day nobody eats — sprouts at 11am,
//  quinoa at 8pm. A chart she cannot follow is a chart she abandons on day two
//  and feels worse for having abandoned, which is the opposite of what this
//  section is for.
// =============================================================================

/// The charts as written — three days each. `kChartContent` is this with
/// days four to seven spliced in where they exist (diet_chart_days_more.dart).
final Map<String, ChartContent> _kChartContentAsWritten = {
  // ---------------------------------------------------------------------------
  'full_month_indian': ChartContent(
    focus: _en('A general, all-round chart for an ordinary Indian kitchen, '
        'usable at any stage. If you are not sure which chart is yours, start '
        'here and move to a trimester chart when something specific changes.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'),
            _en('Vegetable poha with peanuts, a glass of milk')),
        ChartMeal(_en('Mid-morning'), _en('A seasonal fruit — banana, papaya '
            'is best avoided, so orange, apple or chikoo')),
        ChartMeal(_en('Lunch'),
            _en('Dal, one sabzi, two rotis, curd, a small salad')),
        ChartMeal(_en('Evening'), _en('Roasted chana or a handful of nuts, tea '
            'if you take it')),
        ChartMeal(_en('Dinner'),
            _en('Khichdi with a vegetable, a spoon of ghee')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Besan chilla with grated vegetables, '
            'curd on the side')),
        ChartMeal(_en('Mid-morning'), _en('Coconut water or buttermilk')),
        ChartMeal(_en('Lunch'),
            _en('Rajma or chana with rice, a green sabzi')),
        ChartMeal(_en('Evening'), _en('A boiled egg, or paneer cubes if you '
            'are vegetarian')),
        ChartMeal(_en('Dinner'),
            _en('Roti with palak paneer or a dal of your choice')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Idli or dosa with sambar')),
        ChartMeal(_en('Mid-morning'), _en('A glass of milk with a date or two')),
        ChartMeal(_en('Lunch'),
            _en('Curd rice with a vegetable poriyal, or roti with lauki sabzi')),
        ChartMeal(_en('Evening'), _en('Sprouts chaat or a fruit')),
        ChartMeal(_en('Dinner'),
            _en('Vegetable pulao with raita')),
      ]),
    ],
    swaps: [
      _en('Roti, rice, poha, upma and idli are interchangeable — pick what is '
          'already cooking at home.'),
      _en('Any dal works in place of any other. Variety across the week '
          'matters more than which one on a given day.'),
      _en('Milk, curd, paneer and buttermilk all count as your dairy for the '
          'day. One of them is enough.'),
      _en('Vegetarian and non-vegetarian versions of this chart differ in one '
          'meal a day, not in the whole plan.'),
    ],
    limits: [
      _en('Raw or undercooked egg and meat, and unpasteurised milk or the '
          'cheeses made from it.'),
      _en('Papaya, especially raw or semi-ripe, and large amounts of '
          'pineapple.'),
      _en('Very high-caffeine days — around two cups of tea or coffee is the '
          'usual guidance, not zero.'),
      _en('Outside cut fruit and salads, where the water and handling are the '
          'risk rather than the food.'),
    ],
  ),

  // ---------------------------------------------------------------------------
  't1_chart': ChartContent(
    focus: _en('Built for a queasy stomach. The first trimester needs very '
        'little extra food and a great deal of folate, so this chart is about '
        'keeping something down rather than eating more.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('On waking'),
            _en('Two dry toast or a plain biscuit, before you sit up')),
        ChartMeal(_en('Breakfast'), _en('Upma or plain poha, small portion')),
        ChartMeal(_en('Mid-morning'), _en('Coconut water, or lemon water with '
            'a pinch of salt')),
        ChartMeal(_en('Lunch'), _en('Soft khichdi with curd')),
        ChartMeal(_en('Evening'), _en('A few salted crackers, ginger tea')),
        ChartMeal(_en('Dinner'), _en('Dal with rice, one light sabzi')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('On waking'), _en('A handful of roasted chana or makhana')),
        ChartMeal(_en('Breakfast'), _en('Idli with a little chutney — steamed '
            'food usually sits better than fried')),
        ChartMeal(_en('Mid-morning'), _en('Buttermilk with jeera')),
        ChartMeal(_en('Lunch'), _en('Curd rice, a small piece of pickle if it '
            'helps you eat')),
        ChartMeal(_en('Evening'), _en('An apple or a pear, sliced')),
        ChartMeal(_en('Dinner'), _en('Moong dal with one roti')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('On waking'), _en('Dry cornflakes, no milk yet')),
        ChartMeal(_en('Breakfast'), _en('Vegetable dalia')),
        ChartMeal(_en('Mid-morning'), _en('Milk if you can take it, otherwise '
            'a fruit')),
        ChartMeal(_en('Lunch'), _en('Roti with lauki or tori sabzi, dal')),
        ChartMeal(_en('Evening'), _en('Ginger-lemon tea and two biscuits')),
        ChartMeal(_en('Dinner'), _en('Vegetable soup with toast, or light '
            'khichdi again')),
      ]),
    ],
    swaps: [
      _en('If a meal will not stay down, eat the next thing on the list an '
          'hour later. Skipping and waiting usually makes the nausea worse.'),
      _en('Cold food often smells less than hot food, and smell is what '
          'triggers most first-trimester nausea. Room temperature is fine.'),
      _en('Sour helps many women — lemon, imli, amchur, curd. Sweet often does '
          'not.'),
      _en('Folate is the one thing worth chasing: leafy greens, dal, citrus, '
          'and the Folate tablet your doctor has prescribed.'),
    ],
    limits: [
      _en('Long gaps between meals. An empty stomach is the most common '
          'trigger.'),
      _en('Deep-fried and very oily food, which sits heavily when digestion '
          'has already slowed.'),
      _en('Strong-smelling cooking if you can avoid being in the kitchen for '
          'it. This is not fussiness; it is the main trigger.'),
      _en('Papaya and large amounts of pineapple.'),
    ],
  ),

  // ---------------------------------------------------------------------------
  't2_chart': ChartContent(
    focus: _en('The stage appetite usually returns. This chart is '
        'protein-and-iron-forward, because the second trimester is when your '
        'blood volume rises fastest and anaemia is most often picked up.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Two besan chilla with paneer, milk')),
        ChartMeal(_en('Mid-morning'), _en('Orange or amla — vitamin C with '
            'the day\'s iron helps you absorb it')),
        ChartMeal(_en('Lunch'),
            _en('Rajma with rice, palak sabzi, curd, salad')),
        ChartMeal(_en('Evening'), _en('Sprouts chaat with lemon')),
        ChartMeal(_en('Dinner'), _en('Two rotis, dal, a green vegetable')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Vegetable oats or dalia with milk, '
            'and a boiled egg if you eat them')),
        ChartMeal(_en('Mid-morning'), _en('A glass of milk with two dates')),
        ChartMeal(_en('Lunch'), _en('Chole with roti, beetroot and carrot '
            'salad')),
        ChartMeal(_en('Evening'), _en('Peanut chikki or a handful of roasted '
            'peanuts and jaggery')),
        ChartMeal(_en('Dinner'), _en('Methi thepla or roti with dal, curd')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Paneer or egg bhurji with toast')),
        ChartMeal(_en('Mid-morning'), _en('Guava or pomegranate')),
        ChartMeal(_en('Lunch'), _en('Fish or chicken curry with rice, or soya '
            'chunk curry if vegetarian, with a green sabzi')),
        ChartMeal(_en('Evening'), _en('Makhana roasted in a little ghee')),
        ChartMeal(_en('Dinner'), _en('Khichdi with mixed vegetables and a '
            'spoon of ghee')),
      ]),
    ],
    swaps: [
      _en('Iron sits in dal, dark greens, jaggery, dates, ragi and — if you '
          'eat them — eggs, chicken liver and fish.'),
      _en('Pair iron with something sour or citrus in the same meal, and keep '
          'tea and coffee an hour away from it. Tea with a meal blocks a real '
          'share of the iron in it.'),
      _en('Any two of paneer, egg, dal, chana, rajma or soya across the day '
          'covers your protein without counting anything.'),
      _en('Calcium: milk, curd, ragi, sesame, or a paneer meal. One good '
          'source a day.'),
    ],
    limits: [
      _en('Tea and coffee alongside meals rather than between them.'),
      _en('Skipping the mid-morning and evening — this is the stage where '
          'three large meals start becoming uncomfortable.'),
      _en('Raw or runny egg, and undercooked meat and fish.'),
      _en('Very salty pickles and packaged snacks if your blood pressure has '
          'been mentioned at all.'),
    ],
  ),

  // ---------------------------------------------------------------------------
  't3_chart': ChartContent(
    focus: _en('Smaller, more frequent meals, because there is less room for '
        'your stomach and heartburn is common. Calcium, iron and fibre matter '
        'most here, and constipation is the complaint this chart is quietly '
        'designed around.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Ragi porridge with milk and jaggery')),
        ChartMeal(_en('Mid-morning'), _en('A pear or two figs soaked '
            'overnight')),
        ChartMeal(_en('Lunch'), _en('One roti, dal, palak sabzi, curd — a '
            'smaller plate than you would have eaten last month')),
        ChartMeal(_en('Evening'), _en('Milk with a date, or a small bowl of '
            'poha')),
        ChartMeal(_en('Dinner'), _en('Soft khichdi with lauki, eaten early — '
            'two hours before you lie down')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Vegetable upma, a glass of milk')),
        ChartMeal(_en('Mid-morning'), _en('Papaya-free fruit bowl — apple, '
            'pear, pomegranate')),
        ChartMeal(_en('Lunch'), _en('Curd rice with a vegetable, or roti with '
            'moong dal')),
        ChartMeal(_en('Evening'), _en('Roasted makhana, buttermilk')),
        ChartMeal(_en('Dinner'), _en('Dal with one roti, a light sabzi')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Idli with sambar — easy on a full '
            'chest')),
        ChartMeal(_en('Mid-morning'), _en('A glass of milk, or a fruit')),
        ChartMeal(_en('Lunch'), _en('Rice with dal, bhindi or tori, curd')),
        ChartMeal(_en('Evening'), _en('Sweet potato chaat or a banana')),
        ChartMeal(_en('Dinner'), _en('Vegetable dalia, early')),
      ]),
    ],
    swaps: [
      _en('Five or six small meals instead of three. This is the single change '
          'that helps most with third-trimester heartburn.'),
      _en('For constipation: soaked figs or raisins, ragi, oats, plenty of '
          'water, and a fruit with skin where you can.'),
      _en('Eat dinner two to three hours before lying down, and prop your '
          'upper body if reflux wakes you.'),
      _en('Keep the calcium going daily — this is the stage your baby lays '
          'down most of their bone.'),
    ],
    limits: [
      _en('Large, late dinners. The meal itself is rarely the problem; the '
          'timing is.'),
      _en('Very spicy and fried food if heartburn has started.'),
      _en('Long gaps without water, even though it means more trips to the '
          'bathroom.'),
      _en('Papaya, and cutting salt drastically on your own — if salt has been '
          'raised with you, that is a conversation for your doctor.'),
    ],
  ),

  // ---------------------------------------------------------------------------
  //  ⚠️ THE ONE CHART WRITTEN IN HINDI, AND THE REASON IT IS WRITTEN THAT WAY.
  //  `hasHindiContent()` derives the "In Hindi" filter from the text, so this
  //  chart is not tagged as Hindi anywhere — it simply IS in Hindi, and the
  //  filter finds it. When the other fourteen are translated, they will appear
  //  in that filter the same way, with nobody flipping anything.
  //
  //  Devanagari throughout, per CLAUDE.md: everyday food words take Devanagari
  //  (दाल, रोटी, दही) because the hi-IN narration voice cannot read Latin at
  //  all. `Folate` stays Latin — it is what the tablet strip says.
  'hindi_chart': ChartContent(
    focus: _t(
        'The same all-round chart, written in Hindi.',
        'रोज़ के भारतीय खाने पर बना एक आम चार्ट, जो किसी भी तिमाही में काम आता '
        'है। अगर समझ न आए कि कौन सा चार्ट आपका है, यहीं से शुरू कीजिए।'),
    days: [
      ChartDay(label: _t('Day 1', 'पहला दिन'), meals: [
        ChartMeal(_t('Breakfast', 'नाश्ता'),
            _t('Vegetable poha, a glass of milk', 'सब्ज़ी वाला पोहा, एक गिलास दूध')),
        ChartMeal(_t('Mid-morning', 'दिन चढ़े'),
            _t('A seasonal fruit', 'मौसम का एक फल — सेब, संतरा या चीकू')),
        ChartMeal(_t('Lunch', 'दोपहर का खाना'),
            _t('Dal, sabzi, two rotis, curd', 'दाल, एक सब्ज़ी, दो रोटी, दही, थोड़ा सलाद')),
        ChartMeal(_t('Evening', 'शाम'),
            _t('Roasted chana or nuts', 'भुना चना या मुट्ठी भर मेवे')),
        ChartMeal(_t('Dinner', 'रात का खाना'),
            _t('Khichdi with a vegetable', 'सब्ज़ी वाली खिचड़ी, एक चम्मच घी')),
      ]),
      ChartDay(label: _t('Day 2', 'दूसरा दिन'), meals: [
        ChartMeal(_t('Breakfast', 'नाश्ता'),
            _t('Besan chilla with curd', 'बेसन का चीला और साथ में दही')),
        ChartMeal(_t('Mid-morning', 'दिन चढ़े'),
            _t('Coconut water or buttermilk', 'नारियल पानी या छाछ')),
        ChartMeal(_t('Lunch', 'दोपहर का खाना'),
            _t('Rajma or chana with rice', 'राजमा या छोले चावल के साथ, एक हरी सब्ज़ी')),
        ChartMeal(_t('Evening', 'शाम'),
            _t('Paneer cubes or a boiled egg', 'पनीर के टुकड़े, या उबला अंडा')),
        ChartMeal(_t('Dinner', 'रात का खाना'),
            _t('Roti with palak paneer', 'रोटी के साथ पालक पनीर या मनपसंद दाल')),
      ]),
      ChartDay(label: _t('Day 3', 'तीसरा दिन'), meals: [
        ChartMeal(_t('Breakfast', 'नाश्ता'),
            _t('Idli or dosa with sambar', 'इडली या डोसा, सांभर के साथ')),
        ChartMeal(_t('Mid-morning', 'दिन चढ़े'),
            _t('Milk with a date', 'एक गिलास दूध और दो खजूर')),
        ChartMeal(_t('Lunch', 'दोपहर का खाना'),
            _t('Curd rice with a vegetable', 'दही चावल और एक सब्ज़ी, या रोटी और लौकी')),
        ChartMeal(_t('Evening', 'शाम'),
            _t('Sprouts chaat or a fruit', 'अंकुरित चाट या एक फल')),
        ChartMeal(_t('Dinner', 'रात का खाना'),
            _t('Vegetable pulao with raita', 'सब्ज़ी वाला पुलाव और रायता')),
      ]),
    ],
    swaps: [
      _t('Roti, rice, poha and idli are interchangeable.',
          'रोटी, चावल, पोहा, उपमा और इडली — जो घर में बन रहा हो, वही ठीक है।'),
      _t('Any dal works in place of any other.',
          'कोई भी दाल चलेगी। हफ़्ते भर में बदलती रहे, यह ज़्यादा ज़रूरी है।'),
      _t('Milk, curd, paneer and buttermilk all count as dairy.',
          'दूध, दही, पनीर, छाछ — दिन में इनमें से कोई एक काफ़ी है।'),
      _t('Iron with something sour helps absorption.',
          'आयरन वाली चीज़ के साथ कुछ खट्टा लीजिए, और चाय खाने के साथ नहीं।'),
    ],
    limits: [
      _t('Raw or undercooked egg and meat.',
          'कच्चा या अधपका अंडा और मांस, और बिना उबाला दूध।'),
      _t('Papaya, and large amounts of pineapple.',
          'पपीता, ख़ासकर कच्चा, और बहुत सारा अनानास।'),
      _t('Too much caffeine.',
          'दिन में दो कप से ज़्यादा चाय या कॉफ़ी।'),
      _t('Cut fruit and salad from outside.',
          'बाहर का कटा फल और सलाद — ख़तरा खाने से नहीं, पानी और हाथ से है।'),
    ],
  ),

  // ---------------------------------------------------------------------------
  'vegetarian_chart': ChartContent(
    focus: _en('A fully vegetarian chart that does not quietly fall short on '
        'protein, iron or B12 — the three a vegetarian pregnancy plan most '
        'often misses.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Paneer paratha with curd')),
        ChartMeal(_en('Mid-morning'), _en('Milk with soaked almonds')),
        ChartMeal(_en('Lunch'), _en('Rajma with rice, palak sabzi, salad')),
        ChartMeal(_en('Evening'), _en('Sprouts chaat with lemon')),
        ChartMeal(_en('Dinner'), _en('Moong dal with roti, a green sabzi')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Besan chilla with mint chutney')),
        ChartMeal(_en('Mid-morning'), _en('Guava or orange')),
        ChartMeal(_en('Lunch'), _en('Chole with rice, beetroot salad, curd')),
        ChartMeal(_en('Evening'), _en('Peanut chikki and buttermilk')),
        ChartMeal(_en('Dinner'), _en('Soya chunk curry with roti')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Ragi dosa with sambar')),
        ChartMeal(_en('Mid-morning'), _en('Curd with flaxseed')),
        ChartMeal(_en('Lunch'), _en('Dal, methi sabzi, two rotis, salad')),
        ChartMeal(_en('Evening'), _en('Roasted chana and jaggery')),
        ChartMeal(_en('Dinner'), _en('Paneer bhurji with roti')),
      ]),
    ],
    swaps: [
      _en('Protein without meat: paneer, dal, chana, rajma, soya, curd, milk, '
          'peanuts, sesame. Two good sources a day is the target.'),
      _en('Iron: palak, methi, jaggery, dates, ragi, sesame — and something '
          'sour in the same meal.'),
      _en('B12 is the genuinely hard one on a vegetarian plate. Milk and curd '
          'help, and most doctors add a supplement. Ask at your next visit '
          'rather than deciding alone.'),
      _en('Soya chunks stand in for chicken in almost any curry, at similar '
          'protein.'),
    ],
    limits: [
      _en('Filling up on rice and roti and treating dal as a side. Reverse the '
          'proportions.'),
      _en('Relying on paneer alone for protein — it is high in fat as well.'),
      _en('Tea with meals, which costs a vegetarian plate more iron than it '
          'costs a mixed one.'),
      _en('Unpasteurised milk and the soft cheeses made from it.'),
    ],
  ),

  // ---------------------------------------------------------------------------
  'non_vegetarian_chart': ChartContent(
    focus: _en('A mixed plate, built so the non-vegetarian portion does the '
        'work it is good at — protein, iron and B12 — without the plan '
        'becoming meat at every meal.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Two boiled eggs, toast, milk')),
        ChartMeal(_en('Mid-morning'), _en('Orange or sweet lime')),
        ChartMeal(_en('Lunch'), _en('Chicken curry with rice, a green sabzi, '
            'salad')),
        ChartMeal(_en('Evening'), _en('Roasted chana, buttermilk')),
        ChartMeal(_en('Dinner'), _en('Dal with two rotis, lauki sabzi')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Egg bhurji with roti')),
        ChartMeal(_en('Mid-morning'), _en('Milk with two dates')),
        ChartMeal(_en('Lunch'), _en('Fish curry with rice — well cooked, and a '
            'low-mercury fish like rohu, surmai or pomfret')),
        ChartMeal(_en('Evening'), _en('Fruit and a handful of nuts')),
        ChartMeal(_en('Dinner'), _en('Rajma with roti, curd')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Vegetable oats with milk')),
        ChartMeal(_en('Mid-morning'), _en('Pomegranate')),
        ChartMeal(_en('Lunch'), _en('Chicken or egg curry with roti, palak '
            'sabzi')),
        ChartMeal(_en('Evening'), _en('Sprouts chaat')),
        ChartMeal(_en('Dinner'), _en('Khichdi with vegetables, curd')),
      ]),
    ],
    swaps: [
      _en('Egg is the cheapest complete protein on this list and the easiest '
          'to keep down early on.'),
      _en('Chicken, fish and egg are interchangeable across the week — the '
          'point is two to four non-vegetarian meals, not one every day.'),
      _en('Stick to low-mercury fish: rohu, katla, surmai, pomfret, small '
          'prawns. King mackerel, shark and swordfish are the ones to skip.'),
      _en('A vegetarian day or two a week is not a gap. Dal and rajma cover '
          'it.'),
    ],
    limits: [
      _en('Runny yolks, half-cooked kebabs and rare meat. Cooked through is '
          'the whole rule.'),
      _en('High-mercury fish, and very large portions of any fish daily.'),
      _en('Cold cuts, salami and ready-to-eat meats unless heated through.'),
      _en('Meat left out or reheated more than once.'),
    ],
  ),

  // ---------------------------------------------------------------------------
  'gestational_diabetes_chart': ChartContent(
    focus: _en('Built around steady sugars rather than low ones: smaller '
        'portions of carbohydrate, always eaten with protein or fat, and never '
        'a long gap. This is a chart to take to your doctor, not to replace '
        'what they have told you.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Besan chilla with paneer — protein '
            'first thing steadies the whole morning')),
        ChartMeal(_en('Mid-morning'), _en('A handful of nuts, buttermilk')),
        ChartMeal(_en('Lunch'), _en('One roti, dal, a large green sabzi, '
            'curd, salad before the meal')),
        ChartMeal(_en('Evening'), _en('Roasted chana or paneer cubes')),
        ChartMeal(_en('Dinner'), _en('Vegetable and dal soup with one roti, '
            'early')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Two eggs or paneer bhurji, one slice '
            'of multigrain toast')),
        ChartMeal(_en('Mid-morning'), _en('Cucumber and carrot sticks, a few '
            'peanuts')),
        ChartMeal(_en('Lunch'), _en('Half a bowl of rice with rajma, a green '
            'sabzi, curd')),
        ChartMeal(_en('Evening'), _en('Sprouts chaat with lemon')),
        ChartMeal(_en('Dinner'), _en('Two small rotis with methi sabzi and '
            'dal')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Vegetable oats with milk, no sugar')),
        ChartMeal(_en('Mid-morning'), _en('A guava or an apple with skin')),
        ChartMeal(_en('Lunch'), _en('Ragi roti with dal and sabzi, salad')),
        ChartMeal(_en('Evening'), _en('Makhana roasted in ghee')),
        ChartMeal(_en('Dinner'), _en('Khichdi with plenty of vegetables, curd')),
      ]),
    ],
    swaps: [
      _en('Eat salad or a protein before the carbohydrate in the same meal. '
          'The order genuinely changes the reading.'),
      _en('Ragi, jowar, bajra and multigrain roti in place of maida and white '
          'rice. Brown rice in a small portion is usually fine.'),
      _en('Fruit whole rather than as juice, with the skin where you can, and '
          'not on an empty stomach.'),
      _en('Never leave more than three hours between eating. A long gap is '
          'followed by a spike, not by a good reading.'),
    ],
    limits: [
      _en('Sugar, jaggery, honey and sweets — including the "healthy" ones. '
          'Jaggery is sugar.'),
      _en('Fruit juice, packaged or fresh.'),
      _en('Large portions of rice, potato and maida at one sitting.'),
      _en('Skipping a meal to bring a reading down. It usually raises the '
          'next one.'),
    ],
    doctorNote: _en('Your doctor sets your targets, your medication and your '
        'testing times, and those come before anything on this page. If '
        'something here conflicts with what they told you, follow them and '
        'ask about the difference at your next visit.'),
  ),

  // ---------------------------------------------------------------------------
  'weight_gain_chart': ChartContent(
    focus: _en('For when weight gain has been raised with you — in either '
        'direction. The food is ordinary; what changes is portion size and how '
        'often you eat, and both are things your doctor should be setting.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Vegetable dalia with milk')),
        ChartMeal(_en('Mid-morning'), _en('A fruit and a few nuts')),
        ChartMeal(_en('Lunch'), _en('Dal, sabzi, roti, curd, salad first')),
        ChartMeal(_en('Evening'), _en('Buttermilk, roasted chana')),
        ChartMeal(_en('Dinner'), _en('Khichdi with vegetables')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Idli with sambar')),
        ChartMeal(_en('Mid-morning'), _en('Milk, or a fruit if milk feels '
            'heavy')),
        ChartMeal(_en('Lunch'), _en('Rajma with a small bowl of rice, green '
            'sabzi')),
        ChartMeal(_en('Evening'), _en('Sprouts chaat')),
        ChartMeal(_en('Dinner'), _en('Roti with dal and lauki sabzi')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Besan chilla, curd')),
        ChartMeal(_en('Mid-morning'), _en('Pear or apple')),
        ChartMeal(_en('Lunch'), _en('Curd rice with vegetables, or roti and '
            'moong dal')),
        ChartMeal(_en('Evening'), _en('Makhana, a glass of milk')),
        ChartMeal(_en('Dinner'), _en('Vegetable soup with one roti')),
      ]),
    ],
    swaps: [
      _en('To gain more steadily: add ghee, nuts, milk, dates and paneer '
          'rather than more rice and roti.'),
      _en('To slow the gain: keep the same food, shrink the carbohydrate '
          'portion, and start every meal with salad or dal.'),
      _en('Neither direction is helped by skipping meals. Both are helped by '
          'eating at regular times.'),
      _en('Weight in pregnancy is not a straight line, and one week is not a '
          'trend.'),
    ],
    limits: [
      _en('Fried food and sweets as the way to gain — they add weight without '
          'adding much your baby can use.'),
      _en('Cutting meals or skipping dinner to lose. In pregnancy this is not '
          'a safe way to manage weight.'),
      _en('Comparing your gain to another mother\'s. The healthy range differs '
          'with the weight you started at.'),
    ],
    doctorNote: _en('The healthy range depends on the weight you began at, and '
        'only your doctor can tell you yours. Bring this chart to a visit and '
        'ask them to mark what to change, rather than adjusting portions on '
        'your own.'),
  ),

  // ---------------------------------------------------------------------------
  //  ⚠️ THE REGIONAL CHARTS ARE NOT THE GENERAL CHART WITH LOCAL NAMES. That
  //  version would be the generic one wearing a costume, which is worse than
  //  not offering it: a mother recognises immediately that nobody who cooks
  //  this food wrote it. Each of these is built from what that kitchen actually
  //  produces, and the swaps are the ones a family there would already make.
  // ---------------------------------------------------------------------------
  'regional_bengali': ChartContent(
    focus: _en('Built around a Bengali kitchen — rice at the centre, fish for '
        'protein, and the greens and dal that come with them.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Luchi is a treat, not a daily — start '
            'with muri with milk and a banana, or chirer polao')),
        ChartMeal(_en('Mid-morning'), _en('Green coconut water')),
        ChartMeal(_en('Lunch'), _en('Bhat with musur dal, aloo posto, and rui '
            'maach jhol')),
        ChartMeal(_en('Evening'), _en('Chana chaat or a fruit')),
        ChartMeal(_en('Dinner'), _en('Rice with sukto or a light vegetable '
            'ghonto, doi')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Vegetable khichuri, small portion')),
        ChartMeal(_en('Mid-morning'), _en('Doi with gur')),
        ChartMeal(_en('Lunch'), _en('Bhat, cholar dal, palong shaak, and an '
            'egg curry')),
        ChartMeal(_en('Evening'), _en('Muri with chana and mustard oil')),
        ChartMeal(_en('Dinner'), _en('Roti with a light chorchori')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Roti with a vegetable, or dalia')),
        ChartMeal(_en('Mid-morning'), _en('Seasonal fruit')),
        ChartMeal(_en('Lunch'), _en('Bhat with dal, begun bhaja in a little '
            'oil, and maacher jhol')),
        ChartMeal(_en('Evening'), _en('Doi and a handful of nuts')),
        ChartMeal(_en('Dinner'), _en('Khichuri with vegetables')),
      ]),
    ],
    swaps: [
      _en('Rui, katla and small freshwater fish are the safe everyday choices. '
          'Keep large sea fish occasional.'),
      _en('Shaak — palong, lal, methi — is where most of the iron in this '
          'chart sits. Aim for it most days.'),
      _en('Doi after a meal helps with the heaviness that rice can bring.'),
      _en('Vegetarian days: cholar dal, chhana and paneer stand in for the '
          'fish.'),
    ],
    limits: [
      _en('Deep-fried bhaja and luchi as daily items rather than occasional '
          'ones.'),
      _en('Shutki and any fermented or dried fish through pregnancy.'),
      _en('Very large rice portions at a single meal — split across the day '
          'instead.'),
    ],
  ),

  // ---------------------------------------------------------------------------
  'regional_tamil': ChartContent(
    focus: _en('A Tamil kitchen — idli, dosa, sambar, rasam and curd rice — '
        'arranged so the fermented breakfasts and the dal do the nutritional '
        'work.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Two idli with sambar and a little '
            'chutney')),
        ChartMeal(_en('Mid-morning'), _en('Tender coconut water')),
        ChartMeal(_en('Lunch'), _en('Rice with sambar, a poriyal, and curd')),
        ChartMeal(_en('Evening'), _en('Sundal — chana or peanut')),
        ChartMeal(_en('Dinner'), _en('Ragi kali or two dosa with sambar')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Pongal with a spoon of ghee')),
        ChartMeal(_en('Mid-morning'), _en('Milk with dates')),
        ChartMeal(_en('Lunch'), _en('Rice with rasam, keerai poriyal, and '
            'fish or egg curry')),
        ChartMeal(_en('Evening'), _en('Buttermilk and a fruit')),
        ChartMeal(_en('Dinner'), _en('Curd rice with a vegetable')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Adai with avial — the highest-protein '
            'breakfast in this kitchen')),
        ChartMeal(_en('Mid-morning'), _en('Guava or banana')),
        ChartMeal(_en('Lunch'), _en('Rice with kootu, a poriyal, and curd')),
        ChartMeal(_en('Evening'), _en('Ragi porridge')),
        ChartMeal(_en('Dinner'), _en('Idiyappam with vegetable stew')),
      ]),
    ],
    swaps: [
      _en('Keerai — any of the greens — most days. This is the iron in a '
          'largely rice-based plate.'),
      _en('Ragi in place of rice at one meal adds calcium without changing '
          'how the meal is eaten.'),
      _en('Sundal in the evening is the easiest protein to add to this chart.'),
      _en('Adai and pongal carry more protein than idli and dosa — rotate them '
          'in.'),
    ],
    limits: [
      _en('Rice at every one of three meals. Swap at least one for ragi, '
          'millet or idiyappam.'),
      _en('Very tangy tamarind rasam daily if you have heartburn.'),
      _en('Coffee with meals — it costs you iron from the greens.'),
    ],
  ),

  // ---------------------------------------------------------------------------
  'regional_punjabi': ChartContent(
    focus: _en('A Punjabi kitchen has no protein problem — dal, rajma, chana, '
        'paneer and curd are already there. This chart is mostly about the '
        'ghee, the portion size and getting greens in daily.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Stuffed paratha with curd — one, and '
            'less ghee than usual')),
        ChartMeal(_en('Mid-morning'), _en('Lassi, unsweetened')),
        ChartMeal(_en('Lunch'), _en('Rajma with rice, salad, curd')),
        ChartMeal(_en('Evening'), _en('Roasted chana and tea')),
        ChartMeal(_en('Dinner'), _en('Roti with sarson or palak saag, a little '
            'butter')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Daliya or vegetable poha, milk')),
        ChartMeal(_en('Mid-morning'), _en('Orange or seasonal fruit')),
        ChartMeal(_en('Lunch'), _en('Chole with roti, kachumber salad')),
        ChartMeal(_en('Evening'), _en('Paneer tikka or a boiled egg')),
        ChartMeal(_en('Dinner'), _en('Dal with roti and a green sabzi')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Besan chilla with curd')),
        ChartMeal(_en('Mid-morning'), _en('Milk with soaked almonds')),
        ChartMeal(_en('Lunch'), _en('Kadhi with rice, a dry sabzi')),
        ChartMeal(_en('Evening'), _en('Fruit chaat')),
        ChartMeal(_en('Dinner'), _en('Khichdi with vegetables and curd')),
      ]),
    ],
    swaps: [
      _en('Saag — sarson, palak, methi, bathua — most days through winter. '
          'This is the strongest iron source in the kitchen.'),
      _en('Curd or lassi with the heavier meals, which helps more than it '
          'sounds.'),
      _en('Half the usual ghee is still a Punjabi meal. This is the single '
          'change worth making.'),
      _en('Two rotis is a portion in pregnancy; four is habit.'),
    ],
    limits: [
      _en('Butter chicken, malai dishes and cream-based gravies as everyday '
          'food.'),
      _en('Paratha at breakfast every day — rotate with daliya and poha.'),
      _en('Achar in quantity if blood pressure has been mentioned.'),
    ],
  ),

  // ---------------------------------------------------------------------------
  'regional_gujarati': ChartContent(
    focus: _en('A Gujarati kitchen is largely vegetarian and often steamed '
        'rather than fried, which suits pregnancy well. The two things to '
        'watch are the sugar in everyday dishes and getting enough iron.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Dhokla with green chutney, a glass of '
            'milk')),
        ChartMeal(_en('Mid-morning'), _en('Chaas with jeera')),
        ChartMeal(_en('Lunch'), _en('Rotli, dal, a shaak, bhaat, and salad')),
        ChartMeal(_en('Evening'), _en('Khakhra with a little ghee, or roasted '
            'chana')),
        ChartMeal(_en('Dinner'), _en('Khichdi with kadhi')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Thepla with curd')),
        ChartMeal(_en('Mid-morning'), _en('A seasonal fruit')),
        ChartMeal(_en('Lunch'), _en('Undhiyu or a mixed shaak with rotli and '
            'dal')),
        ChartMeal(_en('Evening'), _en('Handvo, a small piece')),
        ChartMeal(_en('Dinner'), _en('Muthiya with vegetable soup, or rotli '
            'and shaak')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Idada or steamed muthiya')),
        ChartMeal(_en('Mid-morning'), _en('Milk with dates')),
        ChartMeal(_en('Lunch'), _en('Rotli with methi shaak, dal, bhaat, '
            'chaas')),
        ChartMeal(_en('Evening'), _en('Sprouts or a fruit')),
        ChartMeal(_en('Dinner'), _en('Vegetable khichdi with curd')),
      ]),
    ],
    swaps: [
      _en('Steamed over fried is already the Gujarati habit — dhokla, handvo, '
          'muthiya, idada. Lean on it.'),
      _en('Methi, palak and bathua shaak carry the iron. Aim for a green '
          'shaak most days.'),
      _en('Skip or halve the jaggery in dal and shaak. Gujarati food carries a '
          'lot of sugar without tasting sweet.'),
      _en('Chaas after lunch instead of a sweet.'),
    ],
    limits: [
      _en('Gathiya, fafda and farsan as daily snacks.'),
      _en('The everyday sugar in dal, kadhi and shaak — worth reducing '
          'especially if sugars have been raised with you.'),
      _en('Very large rotli-and-bhaat lunches; split some into the evening.'),
    ],
  ),

  // ---------------------------------------------------------------------------
  'regional_south_indian': ChartContent(
    focus: _en('A broader South Indian chart across Kerala, Karnataka and '
        'Andhra — rice, coconut, sambar and plenty of vegetables — arranged so '
        'the protein does not fall behind.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Appam with vegetable stew')),
        ChartMeal(_en('Mid-morning'), _en('Tender coconut water')),
        ChartMeal(_en('Lunch'), _en('Rice with sambar, thoran, and curd')),
        ChartMeal(_en('Evening'), _en('Sundal or steamed banana')),
        ChartMeal(_en('Dinner'), _en('Ragi mudde with a light curry, or two '
            'dosa')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Upma with vegetables, or set dosa')),
        ChartMeal(_en('Mid-morning'), _en('Buttermilk')),
        ChartMeal(_en('Lunch'), _en('Rice with fish curry or egg curry, an '
            'avial, and curd')),
        ChartMeal(_en('Evening'), _en('Peanut sundal')),
        ChartMeal(_en('Dinner'), _en('Idiyappam with kadala curry')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Puttu with kadala curry — one of the '
            'better protein breakfasts here')),
        ChartMeal(_en('Mid-morning'), _en('Papaya-free fruit — banana, guava')),
        ChartMeal(_en('Lunch'), _en('Rice with rasam, a poriyal, curd')),
        ChartMeal(_en('Evening'), _en('Ragi porridge with jaggery')),
        ChartMeal(_en('Dinner'), _en('Vegetable stew with appam')),
      ]),
    ],
    swaps: [
      _en('Kadala, sundal and dal are where the protein sits in a rice-heavy '
          'plate. One of them daily.'),
      _en('Ragi at one meal for calcium — mudde, porridge or dosa.'),
      _en('Coconut is fine in ordinary cooking amounts; it is the fried '
          'accompaniments that add up.'),
      _en('Low-mercury fish two or three times a week if you eat fish.'),
    ],
    limits: [
      _en('Very spicy Andhra-style pickles and curries if heartburn has '
          'started.'),
      _en('Rice at all three meals — swap one for ragi, puttu or idiyappam.'),
      _en('Coffee with meals rather than between them.'),
    ],
  ),

  // ---------------------------------------------------------------------------
  'regional_jain': ChartContent(
    focus: _en('A Jain kitchen without onion, garlic or root vegetables. The '
        'real work here is iron and B12, because the usual sources — palak, '
        'beetroot, meat — are either restricted or absent, and this is the '
        'chart most likely to need a supplement alongside it.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Moong dal chilla with curd')),
        ChartMeal(_en('Mid-morning'), _en('Milk with soaked almonds and '
            'raisins')),
        ChartMeal(_en('Lunch'), _en('Rotli, toor dal, lauki shaak, bhaat, '
            'chaas')),
        ChartMeal(_en('Evening'), _en('Roasted chana and jaggery')),
        ChartMeal(_en('Dinner'), _en('Khichdi with kadhi')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Dhokla with green chutney')),
        ChartMeal(_en('Mid-morning'), _en('A seasonal fruit')),
        ChartMeal(_en('Lunch'), _en('Paneer shaak with rotli, moong dal, '
            'salad')),
        ChartMeal(_en('Evening'), _en('Sprouted moong chaat with lemon')),
        ChartMeal(_en('Dinner'), _en('Vegetable khichdi with curd')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Ragi porridge with milk and jaggery')),
        ChartMeal(_en('Mid-morning'), _en('Buttermilk')),
        ChartMeal(_en('Lunch'), _en('Chana shaak with rotli, dal, bhaat')),
        ChartMeal(_en('Evening'), _en('Sesame or peanut chikki')),
        ChartMeal(_en('Dinner'), _en('Moong dal khichdi, chaas')),
      ]),
    ],
    swaps: [
      _en('Sprouted moong and chana are the most useful iron in a Jain plate, '
          'and sprouting raises what your body can absorb.'),
      _en('Sesame, jaggery, ragi and dates carry iron and calcium without any '
          'root vegetable.'),
      _en('Paneer, curd, milk and dal cover protein comfortably.'),
      _en('Pair every iron meal with lemon, amla or a citrus fruit.'),
    ],
    limits: [
      _en('Long gaps and light meals during Paryushan or other fasts — please '
          'read the Fasting section and speak to your doctor first.'),
      _en('Relying on rotli and bhaat for volume while the dal portion stays '
          'small.'),
      _en('Assuming iron will come from food alone here. It often does not, '
          'and a supplement is a normal answer rather than a failure.'),
    ],
    doctorNote: _en('Iron and B12 are genuinely harder on a Jain plate, and '
        'this is one of the few charts where a supplement is commonly needed '
        'rather than optional. Ask your doctor to check your levels rather '
        'than assuming the food has covered it.'),
  ),

  // ---------------------------------------------------------------------------
  //  The four written to stand behind filter values that had nothing behind
  //  them — see the note in `nutrition_data.dart`.
  // ---------------------------------------------------------------------------
  'anaemia_chart': ChartContent(
    focus: _en('For low haemoglobin. The trap with an anaemia chart is that '
        'eating iron and absorbing iron are different things — so this is '
        'built as much around what you eat WITH the iron, and what you keep '
        'away from it, as around the iron itself.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'),
            _en('Ragi porridge with jaggery, and an orange alongside')),
        ChartMeal(_en('Mid-morning'), _en('Amla juice or a guava')),
        ChartMeal(_en('Lunch'),
            _en('Palak dal with rice, beetroot salad with lemon, curd')),
        ChartMeal(_en('Evening'),
            _en('Roasted chana with jaggery — no tea with it')),
        ChartMeal(_en('Dinner'), _en('Methi roti with dal, a green sabzi')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Poha with peanuts and lemon — poha '
            'is iron-fortified more often than people realise')),
        ChartMeal(_en('Mid-morning'), _en('Two soaked dates and a few raisins')),
        ChartMeal(_en('Lunch'), _en('Rajma with rice, tomato salad, and a '
            'citrus fruit after')),
        ChartMeal(_en('Evening'), _en('Sesame or peanut chikki')),
        ChartMeal(_en('Dinner'),
            _en('Chicken or egg curry with roti, or soya chunk curry')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'),
            _en('Besan chilla with mint chutney, a glass of orange juice')),
        ChartMeal(_en('Mid-morning'), _en('Pomegranate')),
        ChartMeal(_en('Lunch'),
            _en('Bathua or sarson saag with makki roti, curd')),
        ChartMeal(_en('Evening'),
            _en('Sprouted moong chaat with plenty of lemon')),
        ChartMeal(_en('Dinner'), _en('Moong dal khichdi with a spoon of ghee')),
      ]),
    ],
    swaps: [
      _en('Vitamin C in the same meal is the single biggest lever: lemon, '
          'amla, orange, guava, tomato. It can multiply how much iron you '
          'absorb.'),
      _en('Keep tea and coffee an hour away from meals. Tea with a meal blocks '
          'a large share of the iron in it, and this is the most common reason '
          'a good diet still shows a low reading.'),
      _en('Cook in an iron kadhai where you can — especially anything sour.'),
      _en('Sprouting and soaking dals and grains raises what your body can '
          'take from them.'),
      _en('Milk and calcium tablets compete with iron. Take them at a '
          'different time of day from your iron tablet.'),
    ],
    limits: [
      _en('Tea and coffee with or just after meals.'),
      _en('Taking your iron and calcium tablets together.'),
      _en('Assuming food alone will correct a low haemoglobin. It usually '
          'cannot, and a tablet is the normal answer rather than a failure.'),
    ],
    doctorNote: _en('Anaemia is diagnosed and treated by your doctor, and the '
        'iron tablet they prescribe does most of the work — this chart '
        'supports it, it does not replace it. If your haemoglobin has been low '
        'at two visits, that is a conversation to have rather than a diet to '
        'try harder at.'),
  ),

  'postpartum_chart': ChartContent(
    focus: _en('The first three months after birth. Recovery, milk supply, and '
        'the real problem nobody names: eating at all, with one hand, when the '
        'food has gone cold twice. Everything here can be eaten one-handed or '
        'left out for an hour.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Early'),
            _en('Warm water with ajwain, a few soaked almonds')),
        ChartMeal(_en('Breakfast'), _en('Panjiri or gond ka laddu, milk')),
        ChartMeal(_en('Mid-morning'), _en('Dalia with milk, or a fruit')),
        ChartMeal(_en('Lunch'), _en('Dal, rice, lauki sabzi, ghee, curd')),
        ChartMeal(_en('Evening'), _en('Milk with haldi, roasted makhana')),
        ChartMeal(_en('Dinner'),
            _en('Khichdi with ghee — soft, warm and early')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Early'), _en('Methi water or jeera water')),
        ChartMeal(_en('Breakfast'), _en('Besan chilla with curd')),
        ChartMeal(_en('Mid-morning'), _en('A glass of milk with dates')),
        ChartMeal(_en('Lunch'),
            _en('Palak dal with roti, curd, a little ghee')),
        ChartMeal(_en('Evening'), _en('Peanut chikki, buttermilk')),
        ChartMeal(_en('Dinner'), _en('Moong dal with rice, tori sabzi')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Early'), _en('Soaked figs or raisins')),
        ChartMeal(_en('Breakfast'), _en('Ragi porridge with jaggery')),
        ChartMeal(_en('Mid-morning'), _en('Fruit and nuts')),
        ChartMeal(_en('Lunch'),
            _en('Chicken or paneer curry with rice, a green sabzi')),
        ChartMeal(_en('Evening'), _en('Milk, or a bowl of dalia')),
        ChartMeal(_en('Dinner'), _en('Vegetable khichdi with curd')),
      ]),
    ],
    swaps: [
      _en('If you are feeding, you need more water than food — keep a bottle '
          'wherever you sit to feed, and drink at every feed.'),
      _en('Methi, ajwain, jeera, gond, sonth and garden cress are the '
          'traditional supply foods, and there is reasonable sense behind most '
          'of them. None of them replace feeding often.'),
      _en('Constipation is very common in the first weeks, especially after a '
          'C-section. Figs, ragi, oats, ghee and water do more than any '
          'medicine.'),
      _en('Eat when the baby sleeps, not when the meal is ready. Cold poha '
          'eaten is better than hot poha skipped.'),
    ],
    limits: [
      _en('Cutting food to lose the weight. The first three months is the '
          'wrong time, and it shows up in your supply and your recovery.'),
      _en('Very long gaps — feeding on an empty stomach is where the '
          'lightheadedness comes from.'),
      _en('Being talked into or out of foods by whoever visits. Almost '
          'everything ordinary is fine.'),
    ],
  ),

  'eggetarian_chart': ChartContent(
    focus: _en('Vegetarian plus egg — which quietly solves most of what a '
        'vegetarian pregnancy plate struggles with. Egg carries complete '
        'protein, B12, choline and iron in one cheap, everyday item.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'),
            _en('Two boiled eggs, toast, a glass of milk')),
        ChartMeal(_en('Mid-morning'), _en('Orange or guava')),
        ChartMeal(_en('Lunch'), _en('Rajma with rice, palak sabzi, curd')),
        ChartMeal(_en('Evening'), _en('Roasted chana, buttermilk')),
        ChartMeal(_en('Dinner'), _en('Dal with two rotis, a green sabzi')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'), _en('Egg bhurji with roti')),
        ChartMeal(_en('Mid-morning'), _en('Milk with soaked almonds')),
        ChartMeal(_en('Lunch'), _en('Chole with rice, beetroot salad')),
        ChartMeal(_en('Evening'), _en('Sprouts chaat with lemon')),
        ChartMeal(_en('Dinner'), _en('Paneer bhurji with roti, curd')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'),
            _en('Vegetable oats with milk, one boiled egg')),
        ChartMeal(_en('Mid-morning'), _en('Pomegranate')),
        ChartMeal(_en('Lunch'), _en('Egg curry with rice, methi sabzi, curd')),
        ChartMeal(_en('Evening'), _en('Peanut chikki')),
        ChartMeal(_en('Dinner'), _en('Moong dal khichdi with vegetables')),
      ]),
    ],
    swaps: [
      _en('One or two eggs a day covers a great deal — protein, B12 and '
          'choline, which a vegetarian plate is usually short of.'),
      _en('Boiled travels, keeps and can be eaten one-handed. Bhurji and '
          'omelette are the same egg with more oil.'),
      _en('On days without egg, lean on paneer, dal and chana as the '
          'vegetarian chart does.'),
      _en('Pair the iron in a meal with something sour, and keep tea away '
          'from meals.'),
    ],
    limits: [
      _en('Runny yolks, half-set omelettes and anything with raw egg — '
          'mayonnaise, mousse, uncooked batter. Cooked through is the rule.'),
      _en('Cracked or long-unrefrigerated eggs.'),
      _en('Relying on egg alone and letting the dal portion shrink.'),
    ],
  ),

  'regional_north_indian': ChartContent(
    focus: _en('Roti, dal, sabzi and curd as they are eaten across UP, Bihar, '
        'Rajasthan and Delhi. Kept separate from the Punjabi chart because the '
        'ghee, the dairy and the saag habit are genuinely different.'),
    days: [
      ChartDay(label: _en('Day 1'), meals: [
        ChartMeal(_en('Breakfast'), _en('Vegetable poha or daliya, milk')),
        ChartMeal(_en('Mid-morning'), _en('A seasonal fruit')),
        ChartMeal(_en('Lunch'), _en('Arhar dal, roti, aloo-methi, curd, salad')),
        ChartMeal(_en('Evening'),
            _en('Roasted chana or a bhuna sweet potato')),
        ChartMeal(_en('Dinner'), _en('Khichdi with ghee and curd')),
      ]),
      ChartDay(label: _en('Day 2'), meals: [
        ChartMeal(_en('Breakfast'),
            _en('Besan chilla, or one paratha with curd')),
        ChartMeal(_en('Mid-morning'), _en('Milk with two dates')),
        ChartMeal(_en('Lunch'),
            _en('Chana dal with rice, lauki sabzi, kachumber')),
        ChartMeal(_en('Evening'), _en('Sattu drink with lemon and salt — one '
            'of the best protein drinks in this kitchen')),
        ChartMeal(_en('Dinner'), _en('Roti with palak or sarson saag')),
      ]),
      ChartDay(label: _en('Day 3'), meals: [
        ChartMeal(_en('Breakfast'), _en('Sattu paratha with curd')),
        ChartMeal(_en('Mid-morning'), _en('Guava or orange')),
        ChartMeal(_en('Lunch'), _en('Rajma or kadhi with rice, a dry sabzi')),
        ChartMeal(_en('Evening'),
            _en('Fruit chaat, or makhana roasted in ghee')),
        ChartMeal(_en('Dinner'), _en('Moong dal with roti and a green sabzi')),
      ]),
    ],
    swaps: [
      _en('Sattu is the most underrated thing on this list — as a drink or in '
          'a paratha, it carries real protein and costs very little.'),
      _en('Saag through winter — palak, sarson, bathua, chaulai. This is where '
          'the iron is.'),
      _en('Curd or chaas with the heavier meals.'),
      _en('Bajra and makki roti in winter add iron that wheat does not.'),
    ],
    limits: [
      _en('Puri, kachori and samosa as everyday food rather than occasional.'),
      _en('Very large roti counts. Two is a portion in pregnancy.'),
      _en('Achar and papad in quantity if blood pressure has been mentioned.'),
    ],
  ),
};

/// Every chart, with the extra days spliced in. Nothing else about a chart
/// changes — focus, swaps, limits and the doctor's note are the writer's.
final Map<String, ChartContent> kChartContent = {
  for (final e in _kChartContentAsWritten.entries)
    e.key: kChartDaysMore.containsKey(e.key)
        ? ChartContent(
            focus: e.value.focus,
            days: [...e.value.days, ...kChartDaysMore[e.key]!],
            swaps: e.value.swaps,
            limits: e.value.limits,
            doctorNote: e.value.doctorNote,
          )
        : e.value,
};

