// =============================================================================
//  The WHO 2021 semen reference limits — one copy, read by everything
// -----------------------------------------------------------------------------
//  ⚠️ THIS FILE EXISTS BECAUSE THE NUMBERS WERE PROSE AND ARE NOW ALSO LOGIC.
//
//  Until now the four limits lived in exactly one place — a bullet list inside
//  `ttc_read_semen_analysis`, written by a doctor and reviewed as prose. That
//  was correct while nothing computed with them.
//
//  "Read your semen report" computes with them. The obvious move is to type
//  `16`, `42`, `30`, `4` into the tool, and it is the wrong one: there would
//  then be two copies of a clinical threshold in one app, and the day WHO
//  publishes a seventh edition somebody updates the article and ships a tool
//  that quietly disagrees with the page next to it. The brief says so in as
//  many words — *"pull the reference limits from the same doctor-reviewed
//  source the articles use, do not hardcode independent numbers."*
//
//  So the numbers move HERE and the article's bullets are generated from them.
//  One edit, both places, and `ttc_his_side_test.dart` asserts the article's
//  rendered text still contains each figure.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THESE NUMBERS ARE, BECAUSE MISREADING THEM IS THE WHOLE PROBLEM
//  ---------------------------------------------------------------------------
//
//  They are the **fifth percentile** of men whose partners conceived within a
//  year. One man in twenty who fathered a child naturally would score below
//  them. They are not a pass mark, they are not an average, and a number under
//  the line is a reason to look further rather than a conclusion.
//
//  That framing is not decoration on top of the data — it is the reason a tool
//  is allowed to show these numbers at all, and `belowLineNote` carries it so
//  no caller can render a comparison without it.
// =============================================================================

/// One reference limit, and how to say it.
class TtcSemenLimit {
  const TtcSemenLimit({
    required this.id,
    required this.name,
    required this.limit,
    required this.unit,
    required this.plain,
    this.note,
  });

  final String id;

  /// As the report prints it.
  final String name;

  /// At or above this is "in the usual range". Never "a pass".
  final double limit;

  final String unit;

  /// What the measurement actually is, in words somebody can use.
  final String plain;

  /// A framing that must travel with the number.
  final String? note;

  /// "16 million per ml".
  String get limitText => '${limit == limit.roundToDouble() ? limit.toStringAsFixed(0) : limit} $unit';
}

/// ⚠️ FOUR, AND VOLUME IS NOT ONE OF THEM. Volume is reported and is worth
/// recording, but a low volume on its own is not one of the four numbers the
/// reference limits are built from — and treating it as a fifth line to pass or
/// fail would invent a threshold WHO did not publish.
const List<TtcSemenLimit> kTtcSemenLimits = [
  TtcSemenLimit(
    id: 'concentration',
    name: 'Concentration',
    limit: 16,
    unit: 'million per ml',
    plain: 'How many sperm there are in each millilitre.',
  ),
  TtcSemenLimit(
    id: 'total_motility',
    name: 'Total motility',
    limit: 42,
    unit: 'per cent',
    plain: 'The share that are moving at all.',
  ),
  TtcSemenLimit(
    id: 'progressive_motility',
    name: 'Progressive motility',
    limit: 30,
    unit: 'per cent',
    plain: 'The share moving forwards rather than in place.',
    note: 'Usually the most informative single number on the report.',
  ),
  TtcSemenLimit(
    id: 'morphology',
    name: 'Normal forms (morphology)',
    limit: 4,
    unit: 'per cent',
    plain: 'The share with a textbook shape.',
    // ⚠️ THE MOST IMPORTANT SENTENCE IN THIS FILE. Four per cent looks
    // catastrophic to anybody who has not been told how it is measured, and a
    // man reading "5%" next to a line at "4%" concludes he has scraped past
    // something. He has not — 5 is normal, comfortably. The brief names this
    // explicitly: "do not let a low-looking morphology number read as bad".
    note: 'Measured strictly. 4 per cent or above is normal — so 5 per cent is '
        'a normal result, not a borderline one.',
  ),
];

TtcSemenLimit? ttcSemenLimit(String id) {
  for (final l in kTtcSemenLimits) {
    if (l.id == id) return l;
  }
  return null;
}

/// Where they come from, and what they are the fifth percentile OF.
const String kTtcSemenLimitsSource =
    'WHO laboratory manual for the examination and processing of human semen, '
    'sixth edition, 2021. The limits are the fifth percentile of roughly 3,500 '
    'men whose partners conceived within twelve months.';

/// The sentence that must travel with any number below a limit.
const String kTtcSemenBelowLineNote =
    'Below the line is a reason to look further, not a conclusion.';

/// What the limits are NOT, said once so every caller can say it the same way.
const String kTtcSemenNotAPassMark =
    'These are not a pass mark. One man in twenty who fathered a child '
    'naturally would score below them.';

/// The abstinence window a sample is supposed to be produced after.
const int kTtcAbstinenceMinDays = 2;
const int kTtcAbstinenceMaxDays = 7;
