// =============================================================================
//  How long she has been trying, and how the app knows (T1, 2026-10-27)
// -----------------------------------------------------------------------------
//  The user, 2026-10-27, on what counts after a loss: "option A, but be precise
//  … show an option like want to edit … handle the wording". Spec:
//  docs/preg-ttc-tool-plans/00-MASTER.md, TT1.
//
//  ⚠️ ONE NUMBER, EVERYWHERE. Before this file the doctor check, the PCOS
//  check, the checklist, the home check card, the "trying a while" message,
//  Ask Veda and You each worked out months from the start date in their own
//  way, and after a loss every one of them counted the months she was
//  pregnant as months of trying. Now they all read [TtcStore.tryingTime].
//
//  ⚠️ A FACT AND A BASIS, NEVER A REWRITTEN FACT. Her start date is kept as
//  she gave it. What she picks in "Change" is stored as a BASIS (first start,
//  started again, her own date) and the number is derived from it. Overwriting
//  the start would lose January the day she changed her mind.
//
//  Pure: no stores, no clock. [TtcStore.tryingTime] feeds it.
// =============================================================================

/// What she picked under "Change". Null means the default: [first].
enum TtcTryingBasis { first, again, own }

/// Where the start the number counts from came from, so the line can say so.
enum TtcTryingSource {
  /// "From a different date": her own pick.
  own,

  /// "Since I started again", or the day she came back to trying from the
  /// family side.
  again,

  /// A start she gave, or a Ready-to-Try month that has passed.
  stated,

  /// Her onboarding answer to "How long have you been trying?".
  answer,

  /// Nothing else known: the day she joined the stage.
  joined,

  /// His phone: the start her phone published.
  partner,
}

/// One pregnancy, as the count sees it. [to] null = it ended but the app was
/// never told when.
typedef TtcPregnancySpan = ({DateTime from, DateTime? to});

/// One run of days left out of the count.
typedef TtcTryingGap = ({DateTime from, DateTime to});

class TtcTryingTime {
  const TtcTryingTime({
    required this.start,
    required this.source,
    required this.days,
    required this.today,
    this.gaps = const [],
    this.unknownEnd = false,
    this.plannedAhead = false,
  });

  /// The day the count runs from (before gaps are left out).
  final DateTime start;
  final TtcTryingSource source;

  /// Days of trying: start to today, minus every day in [gaps]. Never below 0.
  final int days;
  final DateTime today;

  /// The pregnancies left out, merged and clipped to [start]..[today].
  final List<TtcTryingGap> gaps;

  /// A pregnancy in range ended on a day the app does not know, so it could
  /// not be left out. Counting it leans toward the doctor conversation, the
  /// rule at `ttc_fertility_help_rules.dart:74`.
  final bool unknownEnd;

  /// A Ready-to-Try month still to come: they have not started.
  final bool plannedAhead;

  /// The start that gives [days] with nothing left out. Published to his
  /// phone and handed to date-based readers (the "trying a while" message),
  /// so a reader that counts calendar months still agrees with [days].
  DateTime get effectiveStart =>
      DateTime(today.year, today.month, today.day - days);

  int get months => (days / 30.44).round();

  /// "about 7 months". Never a raw day count (§17), the same words as
  /// `FertilityHelpContext.tryingLabel`.
  String get label {
    final m = months;
    if (m < 1) return 'less than a month';
    if (m == 1) return 'about a month';
    if (m < 12) return 'about $m months';
    final y = m ~/ 12;
    if (m % 12 == 0) return y == 1 ? 'about a year' : 'about $y years';
    return 'about $m months';
  }

  /// The heading: "About 7 months of trying".
  String get heading => plannedAhead
      ? 'Not started yet'
      : '${label[0].toUpperCase()}${label.substring(1)} of trying';

  /// The line under it, saying exactly what was counted.
  String get line {
    if (plannedAhead) return 'You plan to start in ${ttcMonthYear(start)}.';
    final from = switch (source) {
      TtcTryingSource.own => 'Counted from ${ttcDayMonthYear(start)}, the date you chose',
      TtcTryingSource.again =>
        'Counted from ${ttcDayMonthYear(start)}, when you started trying again',
      TtcTryingSource.stated => 'Counted from ${ttcMonthYear(start)}',
      TtcTryingSource.answer =>
        'Counted from ${ttcMonthYear(start)}, from what you told us when you joined',
      TtcTryingSource.joined =>
        'Counted from ${ttcDayMonthYear(start)}, when you joined',
      TtcTryingSource.partner => 'Counted from ${ttcMonthYear(start)}, the same as on her phone',
    };
    final left = gaps.isEmpty
        ? ''
        : ', leaving out ${_joinAnd([for (final g in gaps) ttcSpan(g.from, g.to)])}, '
            'when you were pregnant';
    final unknown = unknownEnd
        ? " We couldn't tell when one pregnancy ended, so it isn't left out."
        : '';
    return '$from$left.$unknown';
  }

  /// Whether the "Add when you really started" way on should show.
  bool get startIsAGuess =>
      source == TtcTryingSource.answer || source == TtcTryingSource.joined;
}

/// The count. [basis] and [basisDate] are her "Change" pick; [defaultStart]
/// and [defaultSource] are the start `TtcStore.journeyStart` resolves to.
TtcTryingTime ttcTryingTime({
  required DateTime now,
  required DateTime defaultStart,
  required TtcTryingSource defaultSource,
  TtcTryingBasis? basis,
  DateTime? basisDate,
  List<TtcPregnancySpan> pregnancies = const [],
}) {
  final today = _day(now);
  var start = _day(defaultStart);
  var source = defaultSource;
  if ((basis == TtcTryingBasis.again || basis == TtcTryingBasis.own) &&
      basisDate != null) {
    start = _day(basisDate);
    source = basis == TtcTryingBasis.own
        ? TtcTryingSource.own
        : TtcTryingSource.again;
  }
  if (start.isAfter(today)) {
    return TtcTryingTime(
        start: start, source: source, days: 0, today: today, plannedAhead: true);
  }

  // Clip each ended pregnancy to start..today, then merge overlaps.
  var unknownEnd = false;
  final clipped = <TtcTryingGap>[];
  for (final p in pregnancies) {
    final to = p.to;
    final from = _day(p.from);
    if (to == null) {
      if (!from.isAfter(today) && !from.isBefore(start)) unknownEnd = true;
      continue;
    }
    final a = from.isBefore(start) ? start : from;
    final b = _day(to).isAfter(today) ? today : _day(to);
    if (b.isBefore(a)) continue;
    clipped.add((from: a, to: b));
  }
  clipped.sort((x, y) => x.from.compareTo(y.from));
  final merged = <TtcTryingGap>[];
  for (final g in clipped) {
    if (merged.isNotEmpty && !g.from.isAfter(merged.last.to)) {
      final last = merged.removeLast();
      merged.add((from: last.from, to: g.to.isAfter(last.to) ? g.to : last.to));
    } else {
      merged.add(g);
    }
  }
  final total = _daysBetween(start, today);
  final left = merged.fold<int>(0, (s, g) => s + _daysBetween(g.from, g.to));
  final days = total - left;
  return TtcTryingTime(
    start: start,
    source: source,
    days: days < 0 ? 0 : days,
    today: today,
    gaps: merged,
    unknownEnd: unknownEnd,
  );
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Calendar days from [a] to [b], counted on the date (not the clock), so a
/// daylight-saving hour never loses a day.
int _daysBetween(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day)
        .difference(DateTime.utc(a.year, a.month, a.day))
        .inDays;

const _kMonths = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December',
];

String ttcMonthYear(DateTime d) => '${_kMonths[d.month - 1]} ${d.year}';
String ttcDayMonthYear(DateTime d) =>
    '${d.day} ${_kMonths[d.month - 1]} ${d.year}';

/// "April to June 2025", "December 2024 to February 2025", "May 2025".
String ttcSpan(DateTime a, DateTime b) {
  if (a.year == b.year && a.month == b.month) return ttcMonthYear(a);
  if (a.year == b.year) return '${_kMonths[a.month - 1]} to ${ttcMonthYear(b)}';
  return '${ttcMonthYear(a)} to ${ttcMonthYear(b)}';
}

String _joinAnd(List<String> parts) {
  if (parts.length == 1) return parts.first;
  return '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
}
