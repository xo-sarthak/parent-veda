// =============================================================================
//  What to buy for a diet chart — meal text to ingredients (2026-09-30)
// -----------------------------------------------------------------------------
//  The PDF (Nutrition, "A 7-day plan she can follow, day by day") asked for a
//  shopping-list button on the chart. The Nutrition door already draws a chart
//  as a day-by-day plan and already has a shopping list, but the list filled
//  only from RECIPES (recipe to ingredients). A chart's meals are plain
//  sentences: "Rajma with rice, palak sabzi, curd, salad". This file is the
//  missing step: what a sentence means at the shop.
//
//  ⚠️ CONTENT FOR A NUTRITIONIST TO VERIFY (docs/STILL-OPEN.md §81.20). The
//  ingredient names and which dish implies which ingredients are our best
//  reading of an everyday Indian kitchen and follow the chart's own norms, but a
//  nutritionist owns them. Everything a reviewer would edit is the two tables
//  below (`_kRules` and the drop lists); the parsing code never needs to change.
//
//  HOW IT READS A MEAL. Every rule is a pattern on the lower-cased sentence and
//  the shop items it implies. All matching rules fire, then a few "generic gives
//  way to specific" drops run: "sabzi" alone means seasonal vegetables, but
//  "lauki sabzi" means lauki, not lauki AND vegetables; "fruit" alone is a
//  seasonal fruit, but "fruit: banana or orange" is bananas and oranges.
//
//  WHAT IT LEAVES OFF, ON PURPOSE: salt, oil, water, sugar, tea, common spices
//  (haldi, jeera in a tempering, mustard seeds) and anything she has in the
//  kitchen anyway. A list that says "salt" is a list she stops reading. The
//  spices that ARE the point of a line stay ("jeera water", "ajwain").
//
//  WHAT IT DOES NOT DO: quantities. A chart says "a handful" and "two rotis",
//  and a portion for one woman is not a purchase; she knows her household. It
//  names things, one line each, once per day or once per chart.
//
//  ⚠️ NEVER A PRESCRIPTION. This turns the words already on the chart into a list
//  and adds no food to a plan. Where the chart says "fish, well cooked, a
//  low-mercury kind like rohu, surmai or pomfret" the list says the same kinds.
// =============================================================================

import '../diet_chart_content.dart';

class _Rule {
  const _Rule(this.pattern, this.items);
  final String pattern;
  final List<String> items;
}

// ---- the tables -------------------------------------------------------------

const String _atta = 'Whole wheat flour (atta)';
const String _veg = 'Seasonal vegetables';
const String _fruit = 'Seasonal fruit';
const String _dal = 'Dal (toor or moong)';
const String _salad = 'Salad vegetables (cucumber, tomato, onion)';

/// Pattern on the lower-cased meal, and the items it implies. Word boundaries
/// are written into each pattern so "milk" does not fire inside "buttermilk".
const List<_Rule> _kRules = [
  // ---- grains and flours
  _Rule(r'\b(?<!ragi )(?<!makki )(rotis?|rotli|chapatis?|parathas?|thepla)\b', [_atta]),
  _Rule(r'\brice\b|\bbhat\b|\bbhaat\b|\bpulao\b|\bkhichdi\b|\bkhichuri\b|\bpongal\b', ['Rice']),
  _Rule(r'\bchirer polao\b', ['Chira (flattened rice)']),
  _Rule(r'\bmuri\b', ['Muri (puffed rice)']),
  _Rule(r'\bpoha\b', ['Poha (flattened rice)']),
  _Rule(r'\bupma\b', ['Rava (semolina)']),
  _Rule(r'\bdalia\b|\bdaliya\b', ['Dalia (broken wheat)']),
  _Rule(r'\boats\b', ['Oats']),
  _Rule(r'\bcornflakes\b', ['Cornflakes']),
  _Rule(r'\bragi\b', ['Ragi flour']),
  _Rule(r'\bmakki roti\b', ['Makki atta (maize flour)']),
  _Rule(r'\bmakhana\b', ['Makhana (fox nuts)']),
  _Rule(r'\bsattu\b', ['Sattu']),
  _Rule(r'\bbesan\b|\bdhokla\b|\bchilla\b', ['Besan (gram flour)']),
  _Rule(r'\btoast\b', ['Bread (whole wheat or multigrain)']),
  _Rule(r'\bbiscuits?\b', ['Plain biscuits']),
  _Rule(r'\bcrackers\b', ['Salted crackers']),
  _Rule(r'\bkhakhra\b', ['Khakhra']),
  _Rule(r'\bidli\b', ['Idli batter (or rice and urad dal)']),
  _Rule(r'\bdosas?\b', ['Dosa batter (or rice and urad dal)']),
  _Rule(r'\badai\b', ['Rice and mixed dals (for adai)']),
  _Rule(r'\bappam\b', ['Appam batter (or rice)']),
  _Rule(r'\bidiyappam\b', ['Idiyappam (rice noodles)']),
  _Rule(r'\bputtu\b', ['Puttu flour']),
  _Rule(r'\bhandvo\b|\bidada\b', ['Rice and dal batter (handvo or idada mix)']),
  _Rule(r'\bmuthiya\b', ['Besan (gram flour)', 'Bottle gourd (lauki)']),
  _Rule(r'\bundhiyu\b', ['Mixed undhiyu vegetables']),
  _Rule(r'\bpanjiri\b', ['Panjiri']),
  _Rule(r'\bgond ka laddu\b', ['Gond laddu']),

  // ---- dals and pulses
  _Rule(r'\bmoong dal\b|\bmoong\b(?! dal)(?= dal| chilla| khichdi)', ['Moong dal']),
  _Rule(r'\btoor dal\b|\barhar dal\b', ['Toor (arhar) dal']),
  _Rule(r'\bchana dal\b|\bcholar dal\b', ['Chana dal']),
  _Rule(r'\bmusur dal\b', ['Masoor dal']),
  _Rule(r'\bdal\b|\bpalak dal\b', [_dal]),
  _Rule(r'\bkhichdi\b|\bkhichuri\b|\bpongal\b', ['Moong dal']),
  _Rule(r'\bsambar\b', ['Toor (arhar) dal', 'Sambar powder', 'Sambar vegetables']),
  _Rule(r'\brasam\b', ['Tomatoes', 'Tamarind', 'Rasam powder']),
  _Rule(r'\bkadhi\b', ['Curd', 'Besan (gram flour)']),
  _Rule(r'\bkhandvi\b', ['Besan (gram flour)', 'Curd']),
  _Rule(r'\bpesarattu\b', ['Whole green moong (for pesarattu)']),
  _Rule(r'\bbisi bele bath\b', ['Rice', 'Toor (arhar) dal', 'Seasonal vegetables']),
  _Rule(r'\bkheer\b', ['Milk', 'Rice', 'Jaggery']),
  _Rule(r'\bshrikhand\b', ['Shrikhand (or hung curd)']),
  _Rule(r'\bdoodh\b|\bbadam milk\b', ['Milk']),
  _Rule(r'\bbadam\b', ['Almonds']),
  _Rule(r'\bwalnuts\b', ['Walnuts']),
  _Rule(r'\bcitrus\b', ['Oranges or sweet lime']),
  _Rule(r'\brajma\b', ['Rajma']),
  _Rule(r'\bchole\b', ['Chole (white chickpeas)']),
  _Rule(r'\bkadala\b', ['Kala chana (kadala)']),
  _Rule(r'\bsprouts?\b|\bsprouted moong\b', ['Sprouts (moong or mixed)']),
  _Rule(r'\broasted chana\b', ['Roasted chana']),
  _Rule(r'\bchana chaat\b|\bchana shaak\b|(?<!roasted )\bchana or\b|\bor chana\b|\bwith chana\b|\bsundal, chana\b', ['Chickpeas (chana)']),
  _Rule(r'\bsundal\b', ['Chickpeas (chana) or peanuts']),
  _Rule(r'\bsoya chunks?\b', ['Soya chunks']),
  _Rule(r'\bkootu\b', ['Dal (toor or moong)', 'Seasonal vegetables']),

  // ---- protein
  _Rule(r'\bpaneer\b', ['Paneer']),
  _Rule(r'\beggs?\b', ['Eggs']),
  _Rule(r'\bchicken\b', ['Chicken']),
  _Rule(r'\bfish\b|\bmaach\b|\bmaacher\b|\bmacher\b|\brui\b|\bpomfret\b|\brohu\b|\bsurmai\b',
      ['Fish (a low-mercury kind: rohu, surmai or pomfret)']),

  // ---- dairy
  _Rule(r'\bmilk\b', ['Milk']),
  _Rule(r'\bcurd\b|\bdoi\b|\bdahi\b|\braita\b|\blassi\b', ['Curd']),
  _Rule(r'\bbuttermilk\b|\bchaas\b', ['Buttermilk (chaas)']),
  _Rule(r'\bghee\b', ['Ghee']),
  _Rule(r'\bbutter\b', ['Butter']),

  // ---- vegetables and greens (specific)
  _Rule(r'\bpalak\b|\bpalong shaak\b|\bspinach\b', ['Spinach (palak)']),
  _Rule(r'\bmethi (sabzi|shaak|thepla|roti)\b|\baloo-methi\b', ['Fresh methi leaves']),
  _Rule(r'\bmethi water\b', ['Methi seeds']),
  _Rule(r'\blauki\b', ['Bottle gourd (lauki)']),
  _Rule(r'\btori\b', ['Ridge gourd (tori)']),
  _Rule(r'\bbhindi\b', ['Okra (bhindi)']),
  _Rule(r'\bbeetroot\b', ['Beetroot']),
  _Rule(r'\bcarrot\b', ['Carrots']),
  _Rule(r'\bcucumber\b', ['Cucumber']),
  _Rule(r'\btomato\b', ['Tomatoes']),
  _Rule(r'\bsweet potato\b', ['Sweet potatoes']),
  _Rule(r'\baloo\b', ['Potatoes']),
  _Rule(r'\bposto\b', ['Poppy seeds (posto)']),
  _Rule(r'\bsarson\b|\bbathua\b', ['Sarson (mustard greens) or bathua']),
  _Rule(r'\bkeerai\b', ['Keerai (leafy greens)']),
  _Rule(r'\bbegun\b', ['Brinjal (begun)']),
  _Rule(r'\bsukto\b|\bshukto\b|\bghonto\b|\bchorchori\b', [_veg]),
  _Rule(r'\bdrumstick\b', ['Drumsticks']),
  _Rule(r'\bgreen (sabzi|vegetable)\b', ['Leafy greens or a green vegetable']),
  _Rule(r'\bsabzi\b|\bshaak\b|\bvegetables?\b|\bporiyal\b|\bthoran\b|\bsoup\b|\bavial\b|\bstew\b|\bvegetable\b', [_veg]),
  _Rule(r'\bavial\b|\bstew\b', ['Coconut']),
  _Rule(r'\bsalad\b|\bkachumber\b', [_salad]),

  // ---- fruit and nuts
  _Rule(r'\bbanana\b', ['Bananas']),
  _Rule(r'\boranges?\b|\bsweet lime\b', ['Oranges or sweet lime']),
  _Rule(r'\bapples?\b', ['Apples']),
  _Rule(r'\bchikoo\b', ['Chikoo']),
  _Rule(r'\bpears?\b', ['Pears']),
  _Rule(r'\bguava\b', ['Guava']),
  _Rule(r'\bpomegranate\b', ['Pomegranate']),
  _Rule(r'\bamla\b', ['Amla']),
  _Rule(r'\bfigs?\b', ['Figs']),
  _Rule(r'\bdates?\b', ['Dates']),
  _Rule(r'\braisins\b', ['Raisins']),
  _Rule(r'\balmonds\b', ['Almonds']),
  _Rule(r'\bpeanuts?\b(?! chikki)', ['Peanuts']),
  _Rule(r'\bchikki\b', ['Chikki (peanut or sesame)']),
  _Rule(r'\bnuts\b', ['Mixed nuts']),
  _Rule(r'\bflaxseed\b', ['Flaxseeds']),
  _Rule(r'\bsesame\b', ['Sesame seeds']),
  _Rule(r'\bcoconut water\b', ['Coconut water (tender coconut)']),
  _Rule(r'\bfruit\b', [_fruit]),

  // ---- pantry things that are the point of a line
  _Rule(r'\bjaggery\b|\bgur\b', ['Jaggery']),
  _Rule(r'\blemon\b', ['Lemons']),
  _Rule(r'\bginger\b', ['Ginger']),
  _Rule(r'\bjeera\b', ['Jeera (cumin)']),
  _Rule(r'\bajwain\b', ['Ajwain']),
  _Rule(r'\bhaldi\b', ['Turmeric (haldi)']),
  _Rule(r'\bmint chutney\b', ['Fresh mint']),
  _Rule(r'\bgreen chutney\b', ['Fresh coriander and mint']),
  _Rule(r'\bchutney\b(?<!mint chutney)(?<!green chutney)', ['Coconut (for chutney)']),
  _Rule(r'\bpickle\b', ['Pickle']),
  _Rule(r'\bmustard oil\b', ['Mustard oil']),
];

/// A generic item and the specific ones that make it unnecessary.
const Map<String, Set<String>> _kGenericGivesWay = {
  _veg: {
    'Spinach (palak)', 'Fresh methi leaves', 'Bottle gourd (lauki)', 'Ridge gourd (tori)', 'Okra (bhindi)',
    'Beetroot', 'Carrots', 'Sweet potatoes', 'Potatoes', 'Sarson (mustard greens) or bathua',
    'Keerai (leafy greens)', 'Brinjal (begun)', 'Leafy greens or a green vegetable',
    'Mixed undhiyu vegetables', 'Sambar vegetables',
  },
  _fruit: {
    'Bananas', 'Oranges or sweet lime', 'Apples', 'Chikoo', 'Pears', 'Guava', 'Pomegranate', 'Amla', 'Figs',
  },
  _dal: {'Moong dal', 'Toor (arhar) dal', 'Chana dal', 'Masoor dal'},
  'Chickpeas (chana) or peanuts': {'Chickpeas (chana)', 'Peanuts'},
  'Peanuts': {'Chikki (peanut or sesame)'},
  'Sambar vegetables': {'Drumsticks'},
  _salad: {'Beetroot', 'Cucumber', 'Tomatoes', 'Carrots'},
  'Moong dal': {},
  _atta: {'Makki atta (maize flour)'},
};

// ---- the readers ------------------------------------------------------------

/// The things to buy for one meal sentence, in the order the rules list them,
/// once each. Empty for a sentence that is only water, tea or salt.
List<String> chartMealIngredients(String meal) {
  // "no milk yet", "no dates", "no tea with it": a food the chart says to leave
  // out is not a thing to buy.
  final text = meal.toLowerCase().replaceAll(RegExp(r'\bno \w+( yet)?'), '');
  final out = <String>[];
  for (final r in _kRules) {
    if (RegExp(r.pattern).hasMatch(text)) {
      for (final i in r.items) {
        if (!out.contains(i)) out.add(i);
      }
    }
  }
  // "makki roti" is a roti made of makki, not of atta.
  if (RegExp(r'\bmakki roti\b').hasMatch(text)) out.remove(_atta);
  if (RegExp(r'\bmakki roti\b').hasMatch(text) && !out.contains('Makki atta (maize flour)')) {
    out.add('Makki atta (maize flour)');
  }
  _kGenericGivesWay.forEach((generic, specifics) {
    if (specifics.any(out.contains)) out.remove(generic);
  });
  // A bare "Moong dal" rule also fires on khichdi; a named dal already covers it.
  return out;
}

/// The things to buy for one day of a chart, each once.
List<String> chartDayIngredients(ChartDay day) {
  final out = <String>[];
  for (final m in day.meals) {
    for (final i in chartMealIngredients(m.items.en)) {
      if (!out.contains(i)) out.add(i);
    }
  }
  return out;
}

/// The things to buy for every day of a chart, each once.
List<String> chartWeekIngredients(ChartContent c) {
  final out = <String>[];
  for (final d in c.days) {
    for (final i in chartDayIngredients(d)) {
      if (!out.contains(i)) out.add(i);
    }
  }
  return out;
}

/// The id a chart day files its items under on the shopping list. `dayIndex` null
/// is the whole chart ("Add every day"). The list screen reads this prefix to
/// name the group; a recipe id never starts with it.
String chartListId(String chartId, {int? dayIndex}) =>
    dayIndex == null ? 'chart:$chartId' : 'chart:$chartId:d${dayIndex + 1}';

bool isChartListId(String id) => id.startsWith('chart:');

/// "Vegetarian chart · Day 2", or "Vegetarian chart" for a whole chart, from a
/// list id and the chart's title. Null when [id] is not a chart id.
({String chartId, int? dayIndex})? parseChartListId(String id) {
  if (!isChartListId(id)) return null;
  final parts = id.split(':');
  if (parts.length < 2) return null;
  int? day;
  if (parts.length >= 3 && parts[2].startsWith('d')) {
    final n = int.tryParse(parts[2].substring(1));
    if (n != null) day = n - 1;
  }
  return (chartId: parts[1], dayIndex: day);
}
