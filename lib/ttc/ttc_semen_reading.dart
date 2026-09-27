// =============================================================================
//  "Read your semen report" — the logic, with no widgets in it
// -----------------------------------------------------------------------------
//  Part 2 of `his_side_rebuild.pdf`. He types in what his report says; this
//  turns it into plain English against the WHO 2021 limits and routes him
//  somewhere sensible.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE ONE PRINCIPLE EVERYTHING ELSE FOLLOWS FROM
//  ---------------------------------------------------------------------------
//
//  **A single result is never a verdict.** Semen parameters vary enormously
//  between samples from the same man — a fortnight apart, the same person can
//  produce results either side of a reference line — so a first low number is a
//  reason to repeat, not a reason to conclude.
//
//  Every branch below leans toward "book the repeat and have both read
//  properly", and the strongest thing this file is ever allowed to say is
//  "worth seeing a specialist soon".
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THIS FILE MAY NEVER PRODUCE
//  ---------------------------------------------------------------------------
//
//  No score. No percentage. No "you are fertile", no "you are infertile", no
//  estimate of whether they will conceive. It explains numbers; it does not
//  diagnose, and it never replaces the andrologist it routes to.
//
//  That is the same rule the rest of this stage runs on — `Inferable` is
//  default-deny, ParentVeda's own calculation sits second from the bottom of
//  `TruthSource` — and it is enforced here structurally: the outcome is a
//  sealed set of five routes and there is no field anywhere in it that could
//  hold a score.
//
//  ⚠️ AND THE REFERENCE LIMITS ARE NOT IN THIS FILE. They live in
//  `ttc_semen_limits.dart`, shared with the article that first published them.
//  See the header there for why a second copy is the actual risk.
// =============================================================================

import 'ttc_semen_limits.dart';

/// Everything he can tell us. All optional — he types what his report shows,
/// and a blank is a blank.
///
/// ⚠️ NOTHING IS EVER GUESSED. A missing value produces a line saying it was
/// not entered, never an inferred one. The brief: *"never guess a missing
/// value."*
class TtcSemenEntry {
  const TtcSemenEntry({
    this.values = const {},
    this.volumeMl,
    this.isRepeat = false,
    this.abstinenceDays,
    this.noSpermFound = false,
    this.redFlags = const {},
  });

  /// Keyed by `TtcSemenLimit.id`.
  final Map<String, double> values;

  /// Reported, and deliberately NOT compared to a limit — see the note on
  /// `kTtcSemenLimits`.
  final double? volumeMl;

  final bool isRepeat;
  final int? abstinenceDays;

  /// Azoospermia. Its own input rather than "concentration = 0", because a
  /// report that says no sperm were found is a different statement from a
  /// concentration somebody typed as zero.
  final bool noSpermFound;

  /// Ids from [kTtcSemenRedFlags].
  final Set<String> redFlags;

  TtcSemenEntry copyWith({
    Map<String, double>? values,
    double? volumeMl,
    bool? isRepeat,
    int? abstinenceDays,
    bool? noSpermFound,
    Set<String>? redFlags,
    bool clearVolume = false,
    bool clearAbstinence = false,
  }) =>
      TtcSemenEntry(
        values: values ?? this.values,
        volumeMl: clearVolume ? null : (volumeMl ?? this.volumeMl),
        isRepeat: isRepeat ?? this.isRepeat,
        abstinenceDays:
            clearAbstinence ? null : (abstinenceDays ?? this.abstinenceDays),
        noSpermFound: noSpermFound ?? this.noSpermFound,
        redFlags: redFlags ?? this.redFlags,
      );

  bool get anyEntered => values.isNotEmpty || volumeMl != null || noSpermFound;
}

/// ⚠️ FOUR THINGS THAT MEAN "SEE SOMEBODY BEFORE YOU REPEAT ANYTHING", and each
/// is here for a specific reason rather than as general caution.
///
/// A lump or pain in a testis can be a torsion or a tumour and is time-
/// critical. Very little or no semen can indicate an obstruction or retrograde
/// ejaculation. Erectile or ejaculatory difficulty changes what the test even
/// means. And testosterone — including the "for gym" kind sold without a
/// prescription — SUPPRESSES sperm production, which surprises almost everyone
/// who takes it and is the single most reversible cause on this list.
const List<({String id, String label})> kTtcSemenRedFlags = [
  (id: 'lump', label: 'Pain, swelling or a lump in a testis'),
  (id: 'volume', label: 'Very little or no semen when you ejaculate'),
  (id: 'function', label: 'Trouble with erections or with ejaculating'),
  (id: 'testosterone', label: 'You take testosterone or anabolic steroids'),
];

/// One number, read against its limit.
class TtcSemenLine {
  const TtcSemenLine({
    required this.limit,
    required this.value,
    required this.below,
  });

  final TtcSemenLimit limit;

  /// Null when he did not enter it.
  final double? value;
  final bool below;

  bool get entered => value != null;

  String get valueText {
    final v = value;
    if (v == null) return 'Not entered';
    final n = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return '$n ${limit.unit}';
  }

  /// The design's one line per number, exactly as the brief words it.
  String get sentence {
    if (!entered) {
      return 'You have not entered your ${limit.name.toLowerCase()}.';
    }
    return 'Your ${limit.name.toLowerCase()} is $valueText. '
        'The reference line is ${limit.limitText}. '
        '${below ? 'Below the line.' : 'In the usual range.'}';
  }
}

/// Which of the five paths he is on. First match wins, top to bottom.
enum TtcSemenRoute {
  /// Something that needs a doctor before anything else.
  urgent,

  /// No sperm found — a specialist, not a repeat.
  azoospermia,

  /// Something under the line on a first test — repeat, then read together.
  repeatFirst,

  /// Everything at or above the line.
  usualRange,

  /// Not enough entered to say anything useful.
  tooLittle,
}

class TtcSemenReading {
  const TtcSemenReading({
    required this.route,
    required this.lines,
    required this.headline,
    required this.body,
    this.abstinenceNote,
    this.extra,
    this.volumeMl,
    this.coupleReadiness = false,
  });

  final TtcSemenRoute route;
  final List<TtcSemenLine> lines;

  /// Reported, never compared. See the note on `kTtcSemenLimits`.
  final double? volumeMl;

  /// What the screen says about volume, when he entered it.
  ///
  /// ⚠️ NO THRESHOLD, ON PURPOSE. WHO publishes a fifth-percentile volume too,
  /// and it is deliberately not in `kTtcSemenLimits` — a low volume on its own
  /// is a reason to mention it, not a fifth line to fall below. So this
  /// sentence reports the number and says exactly that.
  String? get volumeSentence {
    final v = volumeMl;
    if (v == null) return null;
    final n = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return 'Your volume is $n ml. The lab reports volume, but it is not one '
        'of the four numbers with a reference line, so nothing here rates it. '
        'A very low volume on its own is worth mentioning to a doctor.';
  }

  /// True only on the usual-range path: the brief says that when everything
  /// is at or above the line and trying has taken a while, point to the
  /// couple-level readiness read in the IVF and IUI area. The tool does not
  /// ask how long they have been trying — it says "if", and opens the door.
  final bool coupleReadiness;

  /// Short. Never a verdict.
  final String headline;
  final String body;

  /// Shown when the sample was produced outside the standard window.
  final String? abstinenceNote;

  /// A second paragraph where the route has one.
  final String? extra;

  List<TtcSemenLine> get entered =>
      lines.where((l) => l.entered).toList();
  List<TtcSemenLine> get belowLine =>
      lines.where((l) => l.entered && l.below).toList();
  bool get anyBelow => belowLine.isNotEmpty;
}

/// The whole tool, in one pure function.
///
/// ⚠️ ORDER IS THE SAFETY. The brief says "read top to bottom, first match
/// wins", and the order is not arbitrary: a man with a lump who also has a low
/// count must be told to see somebody about the lump, and a repeat suggested
/// first would delay that. Reordering these branches is a clinical change, not
/// a refactor.
TtcSemenReading ttcReadSemenReport(TtcSemenEntry e) {
  final lines = [
    for (final l in kTtcSemenLimits)
      TtcSemenLine(
        limit: l,
        value: e.values[l.id],
        below: e.values[l.id] != null && e.values[l.id]! < l.limit,
      ),
  ];

  // ⚠️ THE ABSTINENCE NOTE IS ATTACHED TO EVERY ROUTE, NOT TO ONE. A sample
  // produced after twelve days or after twelve hours is not comparable to the
  // reference limits at all, and that has to be said whatever the numbers came
  // out as — including when they came out fine.
  String? abstinence;
  final d = e.abstinenceDays;
  if (d != null && (d < kTtcAbstinenceMinDays || d > kTtcAbstinenceMaxDays)) {
    abstinence = 'This sample was given after $d '
        '${d == 1 ? 'day' : 'days'}. The standard window is '
        '$kTtcAbstinenceMinDays to $kTtcAbstinenceMaxDays days. Outside it, the '
        'numbers may not be reliable, so a repeat within the standard window '
        'is worth having, whatever this one says.';
  }

  if (e.redFlags.isNotEmpty) {
    return TtcSemenReading(
      route: TtcSemenRoute.urgent,
      lines: lines,
      volumeMl: e.volumeMl,
      abstinenceNote: abstinence,
      headline: 'See a doctor rather than repeating first.',
      body: "What you've ticked is worth a doctor looking at before another "
          'sample is arranged. None of it means something is badly wrong. A '
          'few of these are simple to sort out, and one of them can be '
          "reversed. But they're looked at first, not after a repeat.",
      // ⚠️ SAID ON THIS PATH ALWAYS, because testosterone is one of the four
      // flags and "stop taking it" is exactly what a man reads into this.
      extra: 'Do not stop any prescribed medicine because of anything here. '
          'Take it to the person who prescribed it.',
    );
  }

  if (e.noSpermFound) {
    return TtcSemenReading(
      route: TtcSemenRoute.azoospermia,
      lines: lines,
      volumeMl: e.volumeMl,
      abstinenceNote: abstinence,
      headline: 'This one needs a specialist rather than a repeat.',
      // ⚠️ AND IT SAYS THE HOPEFUL PART OUT LOUD, FIRST. "No sperm found" is
      // read as the end of the road by almost everybody who sees it, and it
      // very often is not: obstruction is treatable and retrieval is frequently
      // possible. Withholding that until an appointment would be accurate and
      // cruel.
      body: 'A report finding no sperm is not the end of the road. It\'s the '
          'one result that goes straight to an andrologist rather than to a '
          'second sample. Sperm can often be retrieved directly, and sometimes '
          'the cause is a blockage that can be treated.',
      extra: "There's a piece in this section about exactly this. Read it "
          'before anything else you find tonight.',
    );
  }

  if (lines.every((l) => !l.entered)) {
    return TtcSemenReading(
      route: TtcSemenRoute.tooLittle,
      lines: lines,
      volumeMl: e.volumeMl,
      abstinenceNote: abstinence,
      headline: 'Take the whole report to someone who reads these.',
      body: "There isn't enough here to say anything useful, and guessing at "
          'a number nobody entered would be worse than saying so. Take the '
          'printed report itself. An andrologist reads the values together '
          'and in context, which no list of lines can do.',
    );
  }

  final below = lines.where((l) => l.entered && l.below).toList();

  if (below.isNotEmpty) {
    // ⚠️ THE SAME ADVICE WHETHER IT IS HIS FIRST TEST OR HIS THIRD, WITH A
    // DIFFERENT REASON. On a first test the answer is "repeat before deciding",
    // because one sample is not a pattern. On a repeat the answer is "take both
    // to somebody", because two samples ARE worth reading together — and
    // telling a man on his second low result to go and have a third would be
    // the app stalling rather than helping.
    return TtcSemenReading(
      route: TtcSemenRoute.repeatFirst,
      lines: lines,
      volumeMl: e.volumeMl,
      abstinenceNote: abstinence,
      headline: e.isRepeat
          ? 'Worth having both reports read together.'
          : 'The usual next step is a repeat, not a decision.',
      body: e.isRepeat
          ? "You have more than one sample now, and that's what makes a "
              'pattern readable. Two reports read side by side by an '
              "andrologist say far more than either one alone. That's the "
              'appointment worth making.'
          : 'Results vary a lot between samples from the same man. The same '
              'person can land on either side of a line a fortnight apart. '
              'So one number below the line is a reason to repeat, not a '
              'reason to conclude anything. Book the repeat, then have both '
              'read together.',
      extra: kTtcSemenBelowLineNote,
    );
  }

  return TtcSemenReading(
    route: TtcSemenRoute.usualRange,
    lines: lines,
    volumeMl: e.volumeMl,
    abstinenceNote: abstinence,
    coupleReadiness: true,
    headline: 'These are in the usual range.',
    // ⚠️ "DOES NOT GUARANTEE ANYTHING" IS NOT HEDGING. A normal semen analysis
    // rules out the commonest male causes and rules out nothing else, and a man
    // who reads it as "my side is fine" stops looking — which is how a couple
    // spends another year on her.
    body: 'A normal result rules out the most common male causes, and that '
        "is worth having. It does not guarantee anything, and it doesn't mean "
        "the question is closed if you've been trying for a while.",
  );
}

// =============================================================================
//  Saving it — what "Keep his reports with yours" actually writes
// -----------------------------------------------------------------------------
//  ⚠️ THE BUTTON USED TO OPEN THE FOLDER AND SAVE NOTHING. The brief says the
//  action "saves it so a second opinion is quick", and a man who tapped it,
//  saw the folder, and found it empty had been told a small lie by the app.
//
//  A `TtcRecord` holds one `value` string per result — the folder was built
//  for an AMH or a TSH, one number each. A semen analysis is four numbers and
//  a volume in one result, so the value is the four lines joined, in the
//  order the report prints them, and the note carries the context an
//  andrologist would want next to them: first test or repeat, and the
//  abstinence window. Pure functions, so the test can assert what is written
//  without a store.
// =============================================================================

/// The record's `value` — every number he entered, in report order.
String ttcSemenRecordValue(TtcSemenEntry e) {
  if (e.noSpermFound) return 'No sperm found (azoospermia)';
  final parts = <String>[
    for (final l in kTtcSemenLimits)
      if (e.values[l.id] case final v?)
        '${l.name} ${_num(v)} ${l.unit}',
    if (e.volumeMl case final v?) 'Volume ${_num(v)} ml',
  ];
  return parts.isEmpty ? 'Report saved without numbers' : parts.join(' · ');
}

/// The record's `note` — the context that makes the numbers readable later.
String ttcSemenRecordNote(TtcSemenEntry e) {
  final d = e.abstinenceDays;
  return [
    e.isRepeat ? 'Repeat test' : 'First test',
    if (d != null) '$d ${d == 1 ? 'day' : 'days'} since last ejaculation',
    'Saved from Read your semen report',
  ].join(' · ');
}

String _num(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
