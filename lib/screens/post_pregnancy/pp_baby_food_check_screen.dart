// =============================================================================
//  PpBabyFoodCheckScreen — "Can he eat this?"
// -----------------------------------------------------------------------------
//  The Feeding section's promise, verbatim:
//
//    "Type a food, get a straight answer for his age. Honey, cow milk, nuts,
//     salt, the lot."
//
//  ⚠️ THE ANSWER DEPENDS ON HIS AGE, AND THAT IS THE WHOLE POINT.
//
//  The pregnancy side has a food checker (`can_i`) where an answer is fixed: a
//  food is safe in pregnancy or it is not. Here almost nothing is simply banned
//  and almost nothing is simply allowed. Cow milk is dangerous as a drink at
//  eight months, fine in cooking at eight months, and fine as a drink at
//  thirteen. Honey is a hard no until one and unremarkable after.
//
//  So a verdict is a function of (food, age), and the screen refuses to show one
//  without both. That rules out the shape this normally takes -- a searchable
//  list of foods each with a green or red badge -- because such a list is either
//  wrong for most readers or hedged into uselessness.
//
//  ⚠️ IT NEVER RETURNS "NO" WHERE THE TRUTH IS "NOT YET".
//
//  Three verdicts, and the middle one carries most of the weight:
//
//    * `yes`     -- fine at this age.
//    * `notYet`  -- fine later, and it says WHEN. This is the common answer and
//                   it is the reason the tool exists: a parent told only "no"
//                   asks again next month, or never.
//    * `avoid`   -- genuinely not for young children at all, with the reason.
//
//  A flat red for everything not-yet-allowed would make the first year read as a
//  minefield, which is the anxiety this whole section is written against.
//
//  ⚠️ SEARCH IS BY ALIAS AS WELL AS NAME, because she will type "sahad" or
//  "gud", not "honey" or "jaggery". An Indian food checker that only matches
//  English names answers "no results" to the people it is for.
//
//  ⚠️ EVERY AGE THRESHOLD IS REQUIRED_REVIEW.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_age_bands.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_content.dart';

enum _Verdict { yes, notYet, avoid }

class _Food {
  const _Food({
    required this.name,
    required this.fromMonths,
    required this.why,
    this.avoidEntirely = false,
    this.aliases = const [],
    this.note,
  });

  final String name;

  /// The age it becomes fine. 0 means from the start of solids.
  final int fromMonths;

  /// Why, in one line. Present on every entry: an unexplained rule gets ignored
  /// by the grandmother who has fed six children.
  final String why;

  /// True for the handful that are not about age at all.
  final bool avoidEntirely;

  /// What she will actually type. Hindi and regional names included.
  final List<String> aliases;

  /// Extra practical detail where the yes-or-no hides something.
  final String? note;

  _Verdict verdictAt(int months) {
    if (avoidEntirely) return _Verdict.avoid;
    return months >= fromMonths ? _Verdict.yes : _Verdict.notYet;
  }
}

// REQUIRED_REVIEW: every `fromMonths` value in this list.
const List<_Food> _foods = [
  // ---- the hard rules -------------------------------------------------------
  _Food(
    name: 'Honey',
    aliases: ['sahad', 'shahad', 'madhu'],
    fromMonths: 12,
    why: 'Honey can carry spores that a baby under one cannot handle. It causes '
        'infant botulism, which is rare and serious.',
    note: 'This includes honey cooked into something, and honey on a dummy or '
        'given at a naming ceremony.',
  ),
  _Food(
    name: 'Cow milk as a drink',
    aliases: ['milk', 'doodh', 'buffalo milk', 'dairy milk'],
    fromMonths: 12,
    why: 'As a main drink before one it is hard on the gut and gets in the way '
        'of iron. Breast milk or formula stays the drink until then.',
    note: 'Cow milk COOKED INTO food, like in a kheer or a porridge, is fine '
        'from about six months. It is the drinking that waits.',
  ),
  _Food(
    name: 'Salt',
    aliases: ['namak', 'salty food'],
    fromMonths: 12,
    why: 'His kidneys cannot clear much salt in the first year, and food that '
        'tastes right to you is already too salty for him.',
    note: 'Take his portion out of the pot before you season the family one.',
  ),
  _Food(
    name: 'Sugar',
    aliases: ['cheeni', 'chini', 'sweets', 'mithai'],
    fromMonths: 12,
    why: 'Nothing in the first year needs it, and a sweet tooth learned now is '
        'hard to unlearn.',
    note: 'Fruit is sweet enough. Jaggery is still sugar.',
  ),
  _Food(
    name: 'Whole nuts',
    aliases: ['nuts', 'badam', 'almond', 'peanut', 'kaju', 'cashew'],
    fromMonths: 60,
    why: 'A whole nut is the classic choking food. The shape is exactly wrong '
        'for a small airway.',
    note: 'Ground or as a smooth paste, nuts are good for him from six months '
        'and early introduction helps prevent allergy. It is the WHOLE nut that '
        'waits until about five.',
  ),
  _Food(
    name: 'Whole grapes',
    aliases: ['grapes', 'angoor'],
    fromMonths: 0,
    why: 'Fine from the start of solids, but always quartered lengthways. Whole '
        'or halved, a grape is the right size and shape to block an airway.',
    note: 'Same for cherry tomatoes and small round sweets.',
  ),

  // ---- never for small children --------------------------------------------
  _Food(
    name: 'Tea and coffee',
    aliases: ['chai', 'coffee', 'kaapi'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'Caffeine is not for small children, and the tannins block the iron he '
        'is getting from everything else.',
    note: 'Giving a toddler sips of chai is common and is worth stopping.',
  ),
  _Food(
    name: 'Packaged juice and cold drinks',
    aliases: ['juice', 'soft drink', 'cola', 'frooti', 'soda'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'Sugar with the fibre taken out. It fills him up, spoils his appetite '
        'for real food, and is hard on new teeth.',
    note: 'Whole fruit instead. Even fresh juice is worth leaving until later.',
  ),
  _Food(
    name: 'Popcorn',
    aliases: ['popcorn'],
    avoidEntirely: true,
    fromMonths: 999,
    why: 'Choking risk, and the hulls are not something a small child can clear.',
    note: 'Usually advised against under about four or five.',
  ),

  // ---- the ordinary yeses ---------------------------------------------------
  _Food(
    name: 'Dal',
    aliases: ['lentils', 'daal', 'moong', 'toor', 'masoor'],
    fromMonths: 6,
    why: 'One of the best Indian first foods. Protein, iron, and it mashes to '
        'any texture you need.',
    note: 'Start with a thin moong dal water, then the dal itself.',
  ),
  _Food(
    name: 'Khichdi',
    aliases: ['khichri', 'rice and dal'],
    fromMonths: 6,
    why: 'A complete first meal, and the same pot the family eats from.',
  ),
  _Food(
    name: 'Ghee',
    aliases: ['clarified butter'],
    fromMonths: 6,
    why: 'Good fat and good calories, which a small stomach needs. A little in '
        'his dal or khichdi is right.',
    note: 'A teaspoon or so a day is plenty. It is not a tonic.',
  ),
  _Food(
    name: 'Curd',
    aliases: ['dahi', 'yoghurt', 'yogurt'],
    fromMonths: 6,
    why: 'Plain, unsweetened curd is fine from six months. It is cow milk as a '
        'DRINK that waits until one, not dairy in food.',
  ),
  _Food(
    name: 'Egg',
    aliases: ['anda', 'eggs'],
    fromMonths: 6,
    why: 'Well cooked, yolk and white together, from about six months. Early '
        'introduction lowers the chance of an egg allergy rather than raising '
        'it.',
  ),
  _Food(
    name: 'Fish',
    aliases: ['machli', 'macch', 'meen'],
    fromMonths: 6,
    why: 'Well cooked and carefully deboned, from about six months. Good for '
        'his brain.',
    note: 'Stick to smaller fish and avoid the large predatory ones, which '
        'carry more mercury.',
  ),
  _Food(
    name: 'Chicken and meat',
    aliases: ['chicken', 'mutton', 'meat', 'murgi'],
    fromMonths: 6,
    why: 'Iron he can absorb easily. Cooked soft and shredded or minced fine.',
  ),
  _Food(
    name: 'Ragi',
    aliases: ['nachni', 'finger millet'],
    fromMonths: 6,
    why: 'Calcium and iron, and it makes an easy porridge. A standard Indian '
        'first food for good reason.',
  ),
  _Food(
    name: 'Banana',
    aliases: ['kela'],
    fromMonths: 6,
    why: 'Mashed, from six months. Easy, filling and almost never a problem.',
  ),
  _Food(
    name: 'Water',
    aliases: ['pani', 'paani'],
    fromMonths: 6,
    why: 'Not before six months: it fills him up and takes the place of milk he '
        'needs. From six months, small sips with meals.',
    note: 'In real heat before six months, feed more often rather than giving '
        'water.',
  ),
  _Food(
    name: 'Spices',
    aliases: ['masala', 'jeera', 'haldi', 'turmeric', 'cumin'],
    fromMonths: 6,
    why: 'Mild spices are fine and are how he learns to eat your food. It is '
        'chilli heat and salt that wait.',
  ),
];

class PpBabyFoodCheckScreen extends StatefulWidget {
  const PpBabyFoodCheckScreen({super.key});

  @override
  State<PpBabyFoodCheckScreen> createState() => _PpBabyFoodCheckScreenState();
}

class _PpBabyFoodCheckScreenState extends State<PpBabyFoodCheckScreen> {
  /// Derived from the profile, and changeable. See the note in the fever check.
  late int _months = ppMonthsSinceBirth;
  String _query = '';

  List<_Food> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _foods;
    return [
      for (final f in _foods)
        if (f.name.toLowerCase().contains(q) ||
            f.aliases.any((a) => a.contains(q) || q.contains(a)))
          f,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final results = _results;
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ppV3Back(context, p),
                  const SizedBox(height: 16),
                  Text('Can he eat this?',
                      style: pvFraunces(fontSize: 27, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
                  const SizedBox(height: 9),
                  Text(
                      'The answer depends on his age, so pick that first. Type '
                      'the food in English or in Hindi.',
                      style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink2)),
                  const SizedBox(height: 18),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      for (final b in kPpChildFoodBands) ...[
                        _AgeChip(
                          label: b.$1,
                          selected: _months >= b.$2 && _months < b.$3,
                          onTap: () => setState(() => _months = b.$2),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, height: 1.55, color: p.ink1),
                    decoration: InputDecoration(
                      hintText: 'honey, dal, cow milk, namak...',
                      hintStyle: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, height: 1.55, color: p.ink3),
                      filled: true,
                      fillColor: p.surface,
                      prefixIcon: Icon(Icons.search_rounded,
                          size: 20, color: p.ink3),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: p.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: p.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: p.action),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                if (results.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: p.surfaceAlt,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                        'Not in the list yet. If it is an ordinary home-cooked '
                        'food with no added salt or sugar, it is almost '
                        'certainly fine once he has started solids. Ask your '
                        'paediatrician about anything you are unsure of.',
                        style: pvManrope(fontSize: 14, fontWeight: FontWeight.w500, height: 1.6, color: p.ink2)),
                  ),
                for (final f in results) ...[
                  _FoodCard(food: f, months: _months),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

/// (label, fromMonths, toMonths). Mirrors the Feeding section's own bands.
// REQUIRED_REVIEW: these boundaries should stay in step with kPpFeedingBands.
const List<(String, int, int)> kPpChildFoodBands = [
  ('Under 6 months', 0, 6),
  ('6 to 8 months', 6, 8),
  ('8 to 12 months', 8, 12),
  ('1 to 2 years', 12, 24),
  ('Over 2 years', 24, 999),
];

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.food, required this.months});
  final _Food food;
  final int months;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final v = food.verdictAt(months);
    // ⚠️ NOT-YET IS AMBER, NOT RED. See the header: a red badge on everything a
    // baby cannot eat yet turns the first year into a minefield.
    final (bg, edge, label, icon) = switch (v) {
      _Verdict.yes => (
          const Color(0xFFEAF6EE),
          const Color(0xFFBFE0CB),
          'YES, AT THIS AGE',
          Icons.check_circle_outline_rounded
        ),
      _Verdict.notYet => (
          const Color(0xFFFFF6E6),
          const Color(0xFFE8D6AC),
          'NOT YET',
          Icons.schedule_rounded
        ),
      _Verdict.avoid => (
          ppAlertTint(p),
          ppAlertInk(p).withValues(alpha: 0.4),
          'BEST AVOIDED',
          Icons.block_rounded
        ),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: edge),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: p.ink1),
          const SizedBox(width: 9),
          Expanded(
            child: Text(food.name, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: p.ink1)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(label,
            style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w800, height: 1.55, color: p.ink2)
                .copyWith(letterSpacing: 0.9)),
        // ⚠️ "NOT YET" ALWAYS SAYS WHEN. Without the date it is just a no, and a
        // no with no end gets asked again next month or ignored entirely.
        if (v == _Verdict.notYet) ...[
          const SizedBox(height: 6),
          Text(_fromLabel(food.fromMonths),
              style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.55, color: p.ink1)),
        ],
        const SizedBox(height: 8),
        Text(food.why, style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink1)),
        if (food.note != null) ...[
          const SizedBox(height: 9),
          Text(food.note!, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w500, height: 1.55, color: p.ink2)),
        ],
      ]),
    );
  }

  String _fromLabel(int m) {
    if (m >= 60) return 'From about 5 years';
    if (m >= 24) return 'From about 2 years';
    if (m == 12) return 'From his first birthday';
    return 'From about $m months';
  }
}

class _AgeChip extends StatelessWidget {
  const _AgeChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) =>
            _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? p.action : p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? p.action : p.line),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? Colors.white : p.ink2)),
        ),
      );
}
