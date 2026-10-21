// =============================================================================
//  Ready-to-Try plan — the answers, and the plan they turn into
// -----------------------------------------------------------------------------
//  The podcast pitch at Q2 (2026-10-17): a short questionnaire a couple fills
//  in together, and back comes THEIR plan: the tests worth asking a doctor
//  about, when folic acid starts against their own month, food for their
//  kitchen and region, and what to do this month, next month and so on until
//  the month they start trying.
//
//  ⚠️ A PERSONAL VIEW OVER THE CHECKLIST, NOT A SECOND CHECKLIST. Every step
//  below names a `PrecheckItem` id, and its tick IS that item's tick in
//  `TtcPrecheckStore`. Two lists with two sets of ticks would drift the first
//  week: she ticks "folic acid" here, the checklist still says "Not looked
//  at", and the home's "Your next step" asks her for it again. Trade-off: the
//  plan cannot invent a step the checklist does not have. What it buys is one
//  truth, and the checklist's summary-for-the-doctor reading her plan's ticks
//  for free. `test/ttc_ready_plan_test.dart` fails if a step names an id the
//  checklist does not hold.
//
//  ⚠️ PURE AND DATED FROM OUTSIDE. `buildReadyPlan` takes `now`, reads no
//  store and writes nothing, so the whole month logic is testable on any date
//  and the screen cannot hold an opinion the function does not.
//
//  ⚠️ WHAT THIS MAY NOT SAY, the same rules as the checklist it sits over:
//    · never that she is, or is not, ready to conceive, and no score;
//    · never a dose: every folic acid line sends the dose to her doctor;
//    · a test is "worth asking about", never "you need";
//    · never "delay trying". A month that is close compresses the plan; it
//      does not move her date. Only a live vaccine can, and that is her
//      doctor's call, said as such.
//  Every clinical sentence here is lifted from a read or a checklist item
//  that already carries its review note; nothing new is claimed. The two
//  that are new framing (the blood group line, the regional foods) are in
//  `docs/DOOR-CONTENT-OWED.md` for the doctor and the dietitian.
//
//  English only (CLAUDE.md, "New work is English").
// =============================================================================

import 'ttc_fertility_help_rules.dart' show FertilityAgeBand;
import 'ttc_meal_week_data.dart' show TtcKitchen;
import 'ttc_ready_plan_regions.dart';

// -----------------------------------------------------------------------------
//  The answers
// -----------------------------------------------------------------------------

/// How she eats. Picks her week of meals and which tests lead.
///
/// ⚠️ THE NAME IS PERSISTED (`TtcReadyPlanStore`). Rename a value and a saved
/// answer falls back to unanswered.
enum ReadyDiet { veg, eggs, nonVeg, jain }

extension ReadyDietCopy on ReadyDiet {
  // Plain words (walk 2026-10-20). Kept for revert: 'Veg with eggs',
  // 'Non-veg'.
  String get label => switch (this) {
    ReadyDiet.veg => 'Vegetarian',
    ReadyDiet.eggs => 'Vegetarian + eggs',
    ReadyDiet.nonVeg => 'Non-vegetarian',
    ReadyDiet.jain => 'Jain',
  };

  /// The food tool's own kitchen, so the week she opens is the one her plan
  /// names.
  TtcKitchen get kitchen => switch (this) {
    ReadyDiet.veg => TtcKitchen.noEggs,
    ReadyDiet.eggs => TtcKitchen.vegEggs,
    ReadyDiet.nonVeg => TtcKitchen.nonVeg,
    ReadyDiet.jain => TtcKitchen.jain,
  };

  /// B12 is the shortfall that follows a plate without meat or fish.
  bool get b12Matters => this != ReadyDiet.nonVeg;
}

/// What a doctor has already told her about. Recorded only; nothing here is
/// inferred from a symptom or from the PCOS self-read.
enum ReadyCondition { pcos, thyroid, diabetes, anaemia }

extension ReadyConditionCopy on ReadyCondition {
  String get label => switch (this) {
    ReadyCondition.pcos => 'PCOS',
    ReadyCondition.thyroid => 'Thyroid',
    ReadyCondition.diabetes => 'Diabetes',
    ReadyCondition.anaemia => 'Anaemia',
  };
}

/// Is she taking folic acid? Read from, and written to, the checklist's own
/// `folate` item, so the two can never disagree.
enum ReadyFolic { yes, notYet, notSure }

extension ReadyFolicCopy on ReadyFolic {
  String get label => switch (this) {
    ReadyFolic.yes => 'Yes',
    ReadyFolic.notYet => 'Not yet',
    ReadyFolic.notSure => 'Not sure',
  };
}

/// His age, in the two bands that change one line of his part.
enum HisAge { under40, fortyOrOver }

extension HisAgeCopy on HisAge {
  String get label => switch (this) {
    HisAge.under40 => 'Under 40',
    HisAge.fortyOrOver => '40 or over',
  };
}

/// The three things with evidence behind them for him (the checklist's
/// `partner_health` and `partner_meds` items).
enum HisHabit { tobacco, alcohol, medicines }

extension HisHabitCopy on HisHabit {
  String get label => switch (this) {
    HisHabit.tobacco => 'Tobacco, in any form',
    HisHabit.alcohol => 'Drinks most weeks',
    // ⚠️ A MEDICINE THAT MATTERS, NAMED (walk 2026-10-20: "anyone can take
    // any medicine ... if he takes paracetamol, how are we helping?"). The
    // examples are the kinds known to affect sperm; picking it now puts his
    // medicine list on the check-up and offers the male fertility consult.
    // Kept for revert: 'Takes regular medicines'.
    HisHabit.medicines =>
      'A daily medicine (e.g. for BP, sugar, hair loss, testosterone, steroids)',
  };
}

// ---- her everyday, so the plan fits a real day (2026-10-21) -----------------
//
// ⚠️ EVERY ANSWER FEEDS SOMETHING. Each of these sets a habit, its time or a
// "help with this" card in `buildReadyPlan`; a question that fed nothing
// would be cut. The names are persisted, like the enums above.

/// Time she can give to movement on most days.
enum ReadyMove { five, fifteen, thirty, notNow }

extension ReadyMoveCopy on ReadyMove {
  String get label => switch (this) {
    ReadyMove.five => '5 min',
    ReadyMove.fifteen => '15 min',
    ReadyMove.thirty => '30 min',
    ReadyMove.notNow => 'Not right now',
  };
}

/// When suits her. Sets every reminder's time; she can change each one.
enum ReadyWhen { morning, evening, lateNight }

extension ReadyWhenCopy on ReadyWhen {
  String get label => switch (this) {
    ReadyWhen.morning => 'Morning',
    ReadyWhen.evening => 'Evening',
    ReadyWhen.lateNight => 'Late night',
  };

  /// Minutes after midnight for her own time of day.
  int get minutes => switch (this) {
    ReadyWhen.morning => 7 * 60,
    ReadyWhen.evening => 19 * 60 + 30,
    ReadyWhen.lateNight => 22 * 60,
  };
}

/// How trying has felt lately.
enum ReadyMood { calm, someStress, aLot }

extension ReadyMoodCopy on ReadyMood {
  String get label => switch (this) {
    ReadyMood.calm => 'Calm',
    ReadyMood.someStress => 'Some stress',
    ReadyMood.aLot => 'A lot',
  };
}

/// Preconception garbh sanskar, a few minutes a week.
enum ReadyGarbh { yes, later }

extension ReadyGarbhCopy on ReadyGarbh {
  String get label => switch (this) {
    ReadyGarbh.yes => 'Yes',
    ReadyGarbh.later => 'Maybe later',
  };
}

/// A check-up in the last year.
enum ReadyCheckup { yes, no, notSure }

extension ReadyCheckupCopy on ReadyCheckup {
  String get label => switch (this) {
    ReadyCheckup.yes => 'Yes',
    ReadyCheckup.no => 'No',
    ReadyCheckup.notSure => 'Not sure',
  };
}

/// Everything the questionnaire holds. Mutable, because the form edits it in
/// place; the store keeps a copy.
class ReadyPlanAnswers {
  ReadyPlanAnswers();

  /// The first day of the month they want to start trying. Null until she
  /// picks one.
  DateTime? target;

  /// "We're already trying": the plan is not for her, the checklist is.
  bool alreadyTrying = false;

  /// Her age band, shared with every TTC tool that asks
  /// (`TtcFertilityHelpStore.ageBand`).
  FertilityAgeBand? age;

  ReadyDiet? diet;
  ReadyRegion? region;

  final Set<ReadyCondition> conditions = {};

  /// She answered the conditions question (an empty set then means "none").
  bool conditionsAnswered = false;
  bool conditionsUnsure = false;

  ReadyFolic? folic;

  ReadyMove? move;
  ReadyWhen? when;
  ReadyMood? mood;
  ReadyGarbh? garbh;
  ReadyCheckup? checkup;

  // ---- his part, optional and never waited for ----------------------------
  HisAge? hisAge;
  final Set<HisHabit> hisHabits = {};

  /// He answered the habits question (an empty set then means "none").
  bool hisHabitsAnswered = false;

  /// True once anything of his has been given. Until then his section is the
  /// general version, labelled as not yet his.
  bool get hisGiven => hisAge != null || hisHabitsAnswered;

  ReadyPlanAnswers copy() => ReadyPlanAnswers.fromJson(toJson());

  Map<String, Object?> toJson() => {
    'target': target?.toIso8601String(),
    'already': alreadyTrying,
    'age': age?.name,
    'diet': diet?.name,
    'region': region?.name,
    'conditions': [for (final c in conditions) c.name],
    'conditionsAnswered': conditionsAnswered,
    'conditionsUnsure': conditionsUnsure,
    'folic': folic?.name,
    'move': move?.name,
    'when': when?.name,
    'mood': mood?.name,
    'garbh': garbh?.name,
    'checkup': checkup?.name,
    'hisAge': hisAge?.name,
    'hisHabits': [for (final h in hisHabits) h.name],
    'hisHabitsAnswered': hisHabitsAnswered,
  };

  /// ⚠️ EVERY ENUM IS READ BY NAME AND AN UNKNOWN NAME IS DROPPED, never
  /// thrown on: a value renamed in a later build must leave a question
  /// unanswered, not crash the plan of someone who answered it.
  factory ReadyPlanAnswers.fromJson(Map<String, Object?> j) {
    T? byName<T extends Enum>(List<T> values, Object? name) {
      for (final v in values) {
        if (v.name == name) return v;
      }
      return null;
    }

    final a = ReadyPlanAnswers()
      ..target = DateTime.tryParse(j['target'] as String? ?? '')
      ..alreadyTrying = j['already'] == true
      ..age = byName(FertilityAgeBand.values, j['age'])
      ..diet = byName(ReadyDiet.values, j['diet'])
      ..region = byName(ReadyRegion.values, j['region'])
      ..conditionsAnswered = j['conditionsAnswered'] == true
      ..conditionsUnsure = j['conditionsUnsure'] == true
      ..folic = byName(ReadyFolic.values, j['folic'])
      ..move = byName(ReadyMove.values, j['move'])
      ..when = byName(ReadyWhen.values, j['when'])
      ..mood = byName(ReadyMood.values, j['mood'])
      ..garbh = byName(ReadyGarbh.values, j['garbh'])
      ..checkup = byName(ReadyCheckup.values, j['checkup'])
      ..hisAge = byName(HisAge.values, j['hisAge'])
      ..hisHabitsAnswered = j['hisHabitsAnswered'] == true;
    for (final n in (j['conditions'] as List?) ?? const []) {
      final c = byName(ReadyCondition.values, n);
      if (c != null) a.conditions.add(c);
    }
    for (final n in (j['hisHabits'] as List?) ?? const []) {
      final h = byName(HisHabit.values, n);
      if (h != null) a.hisHabits.add(h);
    }
    return a;
  }
}

// -----------------------------------------------------------------------------
//  The plan
// -----------------------------------------------------------------------------

/// One thing to do, and the checklist item whose tick it shares.
class ReadyStep {
  const ReadyStep({
    required this.precheckId,
    required this.title,
    required this.why,
    this.surfaceId,
    this.readId,
  });

  /// A `kPrecheckItems` id. The tick on this row IS that item's tick.
  final String precheckId;
  final String title;
  final String why;

  /// Where "Open" goes: a surface, else a read.
  final String? surfaceId;
  final String? readId;
}

/// One month of the plan.
class ReadyMonth {
  const ReadyMonth({
    required this.month,
    required this.steps,
    this.isTarget = false,
  });

  /// The first day of the month.
  final DateTime month;
  final List<ReadyStep> steps;

  /// The month they start trying.
  final bool isTarget;
}

/// One test worth asking a doctor about.
class ReadyTest {
  const ReadyTest({
    required this.name,
    required this.why,
    this.forBoth = false,
    this.emphasis,
    this.testId,
    this.readId,
  });

  final String name;
  final String why;

  /// Thalassaemia carrier screening only means something for the two of
  /// them together.
  final bool forBoth;

  /// Why this one matters more for HER, from her answers. Null when it does
  /// not.
  final String? emphasis;

  /// An entry in the test library (`ttcTests`), when there is one.
  final String? testId;

  /// The read that explains it, when the library has no entry.
  final String? readId;
}

/// One small daily (or weekly) thing in "Your week" (2026-10-21).
///
/// ⚠️ A SMALLER VERSION, ALWAYS. The user: "if she can't do it, at least
/// recommend a bare minimum". [minimum] is what still counts on a busy day;
/// "Make it smaller" swaps it in. No streaks: missing a day is silent.
class ReadyHabit {
  const ReadyHabit({
    required this.id,
    required this.title,
    required this.minimum,
    required this.minutes,
    this.weekday,
    this.surfaceId,
  });

  /// Stable: the store keeps her time and choices under it.
  final String id;
  final String title;
  final String minimum;

  /// Suggested time, minutes after midnight. She can change it.
  final int minutes;

  /// Null for every day; 1-7 (Mon-Sun) for once a week.
  final int? weekday;

  /// Where tapping the habit goes.
  final String? surfaceId;
}

/// A calm "help with this" card: one of our own offerings, chosen by her
/// answers. Rules live here, in code (CLAUDE.md: behaviour rules are not
/// content), and there are never more than two.
class ReadyPitch {
  const ReadyPitch({required this.offeringId, required this.why});

  /// A `ttcOfferings` id. The test pins that every one exists.
  final String offeringId;

  /// One line on why it fits her.
  final String why;
}

class ReadyPlan {
  const ReadyPlan({
    required this.target,
    required this.monthsAway,
    required this.months,
    required this.thisMonth,
    required this.tests,
    required this.folicLine,
    required this.kitchen,
    required this.region,
    required this.hisLines,
    required this.hisPersonal,
    required this.notes,
    this.habits = const [],
    this.pitches = const [],
  });

  final DateTime target;

  /// Whole calendar months from this month to the target month. Zero is
  /// "this month"; below zero, the month has passed.
  final int monthsAway;

  /// From this month up to and including the target month.
  final List<ReadyMonth> months;

  /// What to do now: this month's steps, or, once her month has come, the
  /// ones that still matter while trying.
  final List<ReadyStep> thisMonth;

  final List<ReadyTest> tests;
  final String folicLine;
  final TtcKitchen? kitchen;
  final ReadyRegion? region;

  final List<String> hisLines;

  /// False while his part is the general version.
  final bool hisPersonal;

  /// Short lines that come from her answers and change nothing structural
  /// (her age, a condition).
  final List<String> notes;

  /// "Your week": the small things, each with a time.
  final List<ReadyHabit> habits;

  /// At most two of our offerings that fit her answers.
  final List<ReadyPitch> pitches;

  /// Her month has come (or gone).
  bool get arrived => monthsAway <= 0;
}

/// The first day of the month [d] falls in.
DateTime readyMonthOf(DateTime d) => DateTime(d.year, d.month);

/// The getting-ready hero's small line (2026-10-18): "4 months to go ·
/// Ready-to-Try plan". Months, never days: a month is what they planned.
String ttcGettingReadyLine(DateTime month, {DateTime? now}) {
  final at = now ?? DateTime.now();
  final n = (month.year - at.year) * 12 + month.month - at.month;
  final left = n <= 1 ? 'Next month' : '$n months to go';
  return '$left  ·  Ready-to-Try plan';
}

/// Whole calendar months from [from]'s month to [to]'s month.
int readyMonthsBetween(DateTime from, DateTime to) =>
    (to.year - from.year) * 12 + (to.month - from.month);

const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "March 2027".
String readyMonthLabel(DateTime d) => '${_monthNames[d.month - 1]} ${d.year}';

/// "Mar 2027", for the month picker where three sit in a row.
String readyMonthShort(DateTime d) =>
    '${_monthNames[d.month - 1].substring(0, 3)} ${d.year}';

/// "in 5 months", "next month", "this month". Never "remaining": a count to
/// her own date is an appointment she has, not time she is serving
/// (STILL-OPEN, the next-milestone card's rule).
String readyCountLabel(int monthsAway) => switch (monthsAway) {
  < 0 => 'your month has come',
  0 => 'this month',
  1 => 'next month',
  _ => 'in $monthsAway months',
};

// -----------------------------------------------------------------------------
//  The steps
// -----------------------------------------------------------------------------
//  Each one's words are the checklist item's own claim, shortened, with the
//  item's review note standing behind it.

const ReadyStep _folate = ReadyStep(
  precheckId: 'folate',
  title: 'Start folic acid',
  why:
      'It needs to be in your body before you conceive, so it starts before '
      'trying. Ask your doctor which dose is right for you.',
  surfaceId: 'ttc_supplements',
  readId: 'ttc_read_folic_acid',
);

const ReadyStep _visit = ReadyStep(
  precheckId: 'preconception_visit',
  title: 'Book a check-up before trying',
  why:
      'One visit can look at your medicines, immunity and family history '
      'together. A gynaecologist or a GP can do it.',
  surfaceId: 'ttc_prepare',
  readId: 'ttc_read_first_gyn_visit',
);

const ReadyStep _cycles = ReadyStep(
  precheckId: 'cycle_tracking',
  title: 'Write down your period dates',
  why:
      'Three months of dates is the most useful thing to take to a first '
      'appointment. Just the first day of each period is enough.',
  surfaceId: 'ttc_cycle',
);

const ReadyStep _tests = ReadyStep(
  precheckId: 'baseline_tests',
  title: 'Ask about the blood tests on your plan',
  why:
      'One blood draw usually covers them. Your doctor decides which ones '
      'apply to you.',
  surfaceId: 'ttc_tests',
  readId: 'ttc_read_preconception_tests',
);

const ReadyStep _carrier = ReadyStep(
  precheckId: 'family_history',
  title: 'Ask about thalassaemia carrier screening, for both of you',
  why:
      'Carriers have no symptoms, and the result only means something when '
      'you look at both of you.',
  readId: 'ttc_read_carrier_screening',
);

const ReadyStep _vaccines = ReadyStep(
  precheckId: 'vaccines',
  title: 'Check your rubella immunity',
  why:
      "If you need the vaccine, it needs about a month's wait before you "
      "conceive. It's the one item here with a deadline, so it goes early.",
  surfaceId: 'ttc_vaccinations',
);

const ReadyStep _medicines = ReadyStep(
  precheckId: 'medication_review',
  title: 'Have your medicines and supplements looked at',
  why:
      'Take a list of everything you take, herbal and ayurvedic included. '
      'Do not stop a prescribed medicine on your own.',
  surfaceId: 'ttc_medication',
);

const ReadyStep _food = ReadyStep(
  precheckId: 'nutrition',
  title: 'Cook from your kitchen list',
  why:
      'Not a diet. A little more protein, and the foods you already know '
      'that carry iron, B12 and folate.',
  surfaceId: 'ttc_nutrition',
);

const ReadyStep _dental = ReadyStep(
  precheckId: 'dental',
  title: 'Book a dental check',
  why:
      "A routine cleaning now is easy. It's the item people forget most "
      'before pregnancy.',
);

const ReadyStep _his = ReadyStep(
  precheckId: 'partner_health',
  title: 'His part: habits and a check-up',
  why:
      'Sperm take about three months to develop, so what he changes now '
      'shows up about three months later.',
  readId: 'ttc_read_heat_habits',
);

const ReadyStep _window = ReadyStep(
  precheckId: 'fertile_window',
  title: 'Learn your fertile days',
  why:
      'About six days a cycle, and the two before ovulation matter most. '
      'Nothing to buy.',
  surfaceId: 'ttc_window',
  readId: 'ttc_read_timing_myths',
);

const ReadyStep _whenHelp = ReadyStep(
  precheckId: 'when_to_seek_help',
  title: "Agree when you'd ask for help",
  why:
      'It helps to agree on a point in advance, instead of deciding one hard '
      'month at a time.',
  readId: 'ttc_read_when_to_seek_help',
);

ReadyStep _conditionsStep(Set<ReadyCondition> c) => ReadyStep(
  precheckId: 'conditions',
  title:
      'Tell the doctor who treats your '
      '${_joinAnd([for (final x in c) x.label])} that you are planning',
  why:
      'For some conditions the treatment needs a look before you try. '
      'That one sentence is all you need to do.',
);

String _joinAnd(List<String> xs) => switch (xs.length) {
  0 => '',
  1 => xs.first,
  _ => '${xs.sublist(0, xs.length - 1).join(', ')} and ${xs.last}',
};

// -----------------------------------------------------------------------------
//  The tests
// -----------------------------------------------------------------------------

List<ReadyTest> _testsFor(ReadyPlanAnswers a) {
  final diet = a.diet;
  final pcos = a.conditions.contains(ReadyCondition.pcos);
  final diabetes = a.conditions.contains(ReadyCondition.diabetes);
  return [
    ReadyTest(
      name: 'Haemoglobin (a complete blood count)',
      why: "Anaemia is common in India and easy to treat once it's found.",
      emphasis: a.conditions.contains(ReadyCondition.anaemia)
          ? "You've been told about anaemia, so ask whether it needs "
                'checking again.'
          : null,
      readId: 'ttc_read_iron_before_pregnancy',
    ),
    ReadyTest(
      name: 'Thyroid (TSH)',
      why:
          'Often off with no clear symptoms, and usually treated with one '
          'tablet a day.',
      emphasis: a.conditions.contains(ReadyCondition.thyroid)
          ? 'You have a thyroid condition, so ask whether your treatment '
                'needs a look before trying.'
          : null,
      testId: 'tsh',
    ),
    ReadyTest(
      name: 'Blood sugar (HbA1c)',
      why:
          'Sugar control matters in the first weeks, before most women know '
          "they're pregnant.",
      emphasis: pcos || diabetes
          ? 'Worth asking about especially with '
                '${pcos ? 'PCOS' : 'diabetes'}.'
          : null,
      testId: 'hba1c',
    ),
    ReadyTest(
      name: 'Vitamin B12',
      why: 'A common shortfall in India, linked to ovulation problems.',
      emphasis: diet != null && diet.b12Matters
          ? 'Worth asking about especially because you eat '
                '${diet == ReadyDiet.jain ? 'Jain' : 'vegetarian'}.'
          : null,
      testId: 'b12',
    ),
    const ReadyTest(
      name: 'Vitamin D',
      why:
          'Most Indian adults are low. Test before starting a supplement, '
          'not after.',
      testId: 'vitd',
    ),
    const ReadyTest(
      name: 'Rubella immunity (rubella IgG)',
      why:
          "If you aren't immune, the vaccine needs about a month's wait "
          'before you conceive.',
      readId: 'ttc_read_preconception_tests',
    ),
    const ReadyTest(
      name: 'Thalassaemia carrier screening',
      why:
          'Advised for couples in India whatever the family history. '
          'Carriers have no symptoms.',
      forBoth: true,
      readId: 'ttc_read_carrier_screening',
    ),
    const ReadyTest(
      name: 'Blood group and Rh',
      why:
          'Good to know before pregnancy. If you are Rh negative, your '
          'doctor plans for it.',
      readId: 'ttc_read_preconception_tests',
    ),
  ];
}

// -----------------------------------------------------------------------------
//  The months
// -----------------------------------------------------------------------------

/// Which steps go in which month.
///
/// ⚠️ THE ORDER IS THE ORDER OF CONSEQUENCE, the checklist's own rule: what
/// has to start before conceiving (folic acid), then the check-up and the
/// vaccine that needs a month's gap, then everyday things, then the window.
///
/// ⚠️ A CLOSE MONTH COMPRESSES; IT NEVER MOVES. With one month to go the same
/// steps sit in fewer months. Nothing here tells her to wait.
List<List<ReadyStep>> _allocate(int prepMonths, ReadyPlanAnswers a) {
  final early = [_folate, _visit, _cycles];
  final checks = [
    _vaccines,
    _tests,
    _carrier,
    _medicines,
    if (a.conditions.isNotEmpty) _conditionsStep(a.conditions),
  ];
  final everyday = [_food, _dental, _his];
  final last = [_window, _whenHelp];

  switch (prepMonths) {
    case <= 0:
      return const [];
    case 1:
      return [
        [...early, ...checks, ...everyday, ...last],
      ];
    case 2:
      return [
        [...early, ...checks],
        [...everyday, ...last],
      ];
    case 3:
      return [
        early,
        checks,
        [...everyday, ...last],
      ];
    default:
      // Four or more: the everyday steps spread over the middle months, one
      // or two a month, so no month is a wall and none is empty.
      final middle = prepMonths - 3;
      final spread = List.generate(middle, (_) => <ReadyStep>[]);
      for (var i = 0; i < everyday.length; i++) {
        spread[i % middle].add(everyday[i]);
      }
      return [early, checks, ...spread, last];
  }
}

/// The plan for these answers, as of [now].
///
/// Null when there is no plan to make: no month picked, or she is already
/// trying (her checklist is the better fit then).
ReadyPlan? buildReadyPlan(ReadyPlanAnswers a, {required DateTime now}) {
  final target = a.target;
  if (target == null || a.alreadyTrying) return null;
  final t = readyMonthOf(target);
  final start = readyMonthOf(now);
  final away = readyMonthsBetween(start, t);

  final buckets = _allocate(away, a);
  final months = <ReadyMonth>[
    for (var i = 0; i < buckets.length; i++)
      ReadyMonth(
        month: DateTime(start.year, start.month + i),
        steps: buckets[i],
      ),
    if (away >= 0) ReadyMonth(month: t, steps: const [], isTarget: true),
  ];

  // ⚠️ ONCE HER MONTH HAS COME, "THIS MONTH" IS WHAT STILL MATTERS WHILE
  // TRYING, not an empty card. Folic acid and the check-up do not stop
  // mattering because a date passed.
  final thisMonth = away <= 0
      ? [
          _folate,
          _visit,
          _window,
          if (a.conditions.isNotEmpty) _conditionsStep(a.conditions),
          _whenHelp,
        ]
      : buckets.first;

  return ReadyPlan(
    target: t,
    monthsAway: away,
    months: months,
    thisMonth: thisMonth,
    tests: _testsFor(a),
    folicLine: _folicLine(a, away),
    kitchen: a.diet?.kitchen,
    region: a.region,
    hisLines: _hisLines(a),
    hisPersonal: a.hisGiven,
    notes: _notes(a),
    habits: readyHabitsFor(a),
    pitches: readyPitchesFor(a),
  );
}

/// "Your week" for these answers. Pure, so the test reads it directly.
List<ReadyHabit> readyHabitsFor(ReadyPlanAnswers a) {
  final at = a.when?.minutes;
  // Movement is suggested at her time; the morning is the usual best.
  final moveAt = at ?? 7 * 60;
  final veg = a.diet != ReadyDiet.nonVeg;
  return [
    ReadyHabit(
      id: 'folic',
      title: 'Folic acid',
      minimum: 'Every day. Just the tablet.',
      minutes: 9 * 60,
      surfaceId: 'ttc_medication',
    ),
    switch (a.move) {
      ReadyMove.thirty || ReadyMove.fifteen => ReadyHabit(
          id: 'move',
          title:
              'Move for ${a.move == ReadyMove.thirty ? 30 : 15} minutes',
          minimum: 'Busy day? 5 minutes of stretching still counts.',
          minutes: moveAt,
          surfaceId: 'ttc_practice/mb_walk',
        ),
      ReadyMove.five => ReadyHabit(
          id: 'move',
          title: '5 minutes of stretching',
          minimum: 'Even 2 minutes counts.',
          minutes: moveAt,
          surfaceId: 'ttc_practice/mb_loosen',
        ),
      // No time now: the bare minimum, never nothing.
      _ => ReadyHabit(
          id: 'move',
          title: '2 minutes of stretching',
          minimum: 'A few stretches when you wake up.',
          minutes: 7 * 60,
          surfaceId: 'ttc_practice/mb_loosen',
        ),
    },
    ReadyHabit(
      id: 'iron',
      title: 'Something iron-rich at lunch',
      minimum: veg
          ? 'One bowl of dal, chana or greens is enough.'
          : 'Eggs, fish or a bowl of dal is enough.',
      minutes: 13 * 60,
      surfaceId: 'ttc_nutrition',
    ),
    if (a.mood == ReadyMood.someStress || a.mood == ReadyMood.aLot)
      ReadyHabit(
        id: 'calm',
        title: '5 calm minutes',
        minimum: 'Or 3 slow breaths before sleep.',
        minutes: a.when == ReadyWhen.morning ? 21 * 60 + 30 : (at ?? 22 * 60),
        surfaceId: 'ttc_mind_today',
      ),
    if (a.garbh == ReadyGarbh.yes)
      const ReadyHabit(
        id: 'garbh',
        title: 'Garbh sanskar, 10 minutes',
        minimum: 'Or one track while you rest.',
        minutes: 8 * 60,
        weekday: DateTime.sunday,
        surfaceId: 'ttc_garbh_course',
      ),
  ];
}

/// The "help with this" cards: at most two, most useful first.
List<ReadyPitch> readyPitchesFor(ReadyPlanAnswers a) {
  final out = <ReadyPitch>[
    if (a.checkup == ReadyCheckup.no || a.checkup == ReadyCheckup.notSure)
      const ReadyPitch(
          offeringId: 'ttc_consult_gynae',
          why: 'A check-up before trying, by video call.'),
    if (a.mood == ReadyMood.aLot)
      const ReadyPitch(
          offeringId: 'ttc_psych_consult',
          why: 'Someone to talk to, who understands trying.'),
    if (a.conditions.contains(ReadyCondition.pcos))
      const ReadyPitch(
          offeringId: 'ttc_course_pcos',
          why: 'A short course on trying with PCOS.'),
    if (a.hisHabits.contains(HisHabit.medicines))
      const ReadyPitch(
          offeringId: 'ttc_consult_androl',
          why: 'For him: what his medicines mean for trying.'),
    const ReadyPitch(
        offeringId: 'ttc_course_basics',
        why: 'The basics of trying, in short lessons.'),
  ];
  return out.take(2).toList();
}

String _folicLine(ReadyPlanAnswers a, int away) {
  const dose = 'Ask your doctor which dose is right for you.';
  if (a.folic == ReadyFolic.yes) {
    return "You're already taking it. Keep going through the first twelve "
        'weeks of pregnancy. $dose';
  }
  final unsure = a.folic == ReadyFolic.notSure
      ? 'Not sure? Look at what you take, or ask a pharmacist. '
      : '';
  if (away <= 1) {
    return '${unsure}Start it now. It should be in your body at least a month '
        'before you conceive, and your doctor can say whether the timing '
        'changes anything. $dose';
  }
  return '${unsure}Start it this month. It should be in your body at least a '
      'month before you conceive, and starting ${readyCountLabel(away)} '
      'ahead covers that comfortably. $dose';
}

List<String> _hisLines(ReadyPlanAnswers a) {
  if (!a.hisGiven) {
    // The checklist item's own words: the general version, said as such.
    return const [
      'Tobacco, alcohol and heat are the three things with evidence behind '
          'them. Anything he changes shows up about three months later.',
      'Several ordinary medicines affect sperm production. Worth him '
          "mentioning what he takes at any appointment. It's not a reason to "
          'stop anything on his own.',
    ];
  }
  final h = a.hisHabits;
  return [
    if (h.contains(HisHabit.tobacco))
      'Stopping tobacco, in any form, is the change with the clearest '
          'evidence for him too, and its effects reverse when he stops.',
    if (h.contains(HisHabit.alcohol))
      'Heavy drinking affects sperm. Cutting right back now shows up about '
          'three months later.',
    if (h.contains(HisHabit.medicines))
      'Some daily medicines affect sperm, like those for hair loss, '
          'testosterone or steroids. Take a list of what he takes to the '
          "check-up. It's not a reason to stop anything on his own.",
    if (a.hisAge == HisAge.fortyOrOver)
      'His age is worth mentioning at a check-up too. It is one of the '
          'things a doctor weighs.',
    if (a.hisHabitsAnswered && h.isEmpty)
      'Nothing in his answers needs changing. Keeping heat away (long hot '
          'baths, a laptop on his lap) is the one easy habit.',
    'Sperm take about three months to develop, so the months you are '
        'getting ready are his months too.',
  ];
}

List<String> _notes(ReadyPlanAnswers a) => [
  // The onboarding's own shipped line for this age, word for word, so
  // the app gives one answer to one question.
  if (a.age != null && a.age != FertilityAgeBand.under35)
    "If you're over 35, six months of trying is a good time to see a "
        "doctor. It's a calm check, not an emergency.",
  if (a.conditionsUnsure)
    "You weren't sure about any conditions. That's worth one question at "
        'your check-up.',
];
