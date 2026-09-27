// =============================================================================
//  When is her period due, and what can a test tell her today?
// -----------------------------------------------------------------------------
//  ONE ANSWER, READ BY TWO PLACES. The "late by a day" message in
//  `ttc_messages_store.dart` and the "Should I test?" chat both need the same
//  date. If each worked it out inline, the message could say "your period was
//  due on the 12th" and the chat it opens could say the 13th, and she would be
//  right to stop trusting both. So the arithmetic lives here, pure, and both
//  callers pass in what they know.
//
//  ---------------------------------------------------------------------------
//  ⚠️ A CLINIC CYCLE NEVER GETS A DUE DATE FROM US
//  ---------------------------------------------------------------------------
//
//  `TtcPathwayBehaviour.countsToPeriod` is false whenever a clinic is involved,
//  because luteal support delays the period and "your period is late" on a
//  treatment cycle means nothing and reads as hope. The first branch below is
//  that rule, checked before any date is looked at, so no caller can reach the
//  arithmetic on a clinic-owned cycle however it asks.
//
//  ---------------------------------------------------------------------------
//  ⚠️ A DATE, NEVER A CHANCE
//  ---------------------------------------------------------------------------
//
//  Everything here is a timing fact about when a home test becomes reliable.
//  Nothing may grow a field that reads as how likely a positive is. CLAUDE.md's
//  clinical invariants, and `test/ttc_chats_test.dart` scans the chat copy for
//  the words that would give it away.
// =============================================================================

import 'ttc_care_pathway.dart';
import 'ttc_chapter.dart' show TtcChapterEngine;

/// Which part of the "Should I test?" conversation applies today.
enum TtcTestBranch {
  /// A clinic owns the timing. Their blood test is the answer.
  clinic,

  /// No period logged, so there is nothing to count from.
  noDates,

  /// A period is logged but we have no cycle length to count with.
  needCycleLength,

  /// The period is not due yet. A test may miss an early pregnancy.
  early,

  /// The period is due today. A home test is reliable from today.
  dueToday,

  /// The period was due on an earlier day and none has been logged.
  late,
}

/// The whole answer for one day.
class TtcTestAdvice {
  const TtcTestAdvice({
    required this.branch,
    this.due,
    this.daysUntil = 0,
    this.daysLate = 0,
    this.rough = false,
  });

  final TtcTestBranch branch;

  /// The day her period is due. Null on the clinic and no-dates branches.
  final DateTime? due;

  /// Days from today until [due]. Only meaningful on [TtcTestBranch.early].
  final int daysUntil;

  /// Days since [due]. Only meaningful on [TtcTestBranch.late].
  final int daysLate;

  /// Her cycles vary a lot, so the due date is a rough one and the chat says
  /// so. Never hidden: a rough date said plainly beats no date at all.
  final bool rough;

  /// Late by so much that a missed log is more likely than a late period. The
  /// chat asks her to log any period she has had since, instead of treating
  /// three months as three months late.
  ///
  /// ⚠️ THE ENGINE'S OWN BOUNDARY SINCE 2026-09-26 (consistency pass). This
  /// was `daysLate > 14`, one day after the engine stops estimating
  /// (`TtcChapterEngine.isCurrentCycleOverdue`: past her usual length by a
  /// whole luteal phase, which is 14 days after the due day). On that one day
  /// the hero had already gone to "not enough logged" while the home's "Time
  /// to test" and this chat still called the period plainly late. Now all
  /// three turn on the same morning. Kept for revert:
  ///   bool get looksStale => branch == TtcTestBranch.late && daysLate > 14;
  bool get looksStale =>
      branch == TtcTestBranch.late &&
      daysLate >= TtcChapterEngine.lutealPhaseDays;
}

/// The day a period is due, counting [cycleLength] days from [lastStart].
DateTime ttcPeriodDueOn(DateTime lastStart, int cycleLength) => DateTime(
    lastStart.year, lastStart.month, lastStart.day + cycleLength);

/// The branch for [today], from what she has told us.
///
/// [cycleLength] is her usual length, or null when she has none on record and
/// has not told the chat one. [irregular] only softens the wording.
TtcTestAdvice ttcTestAdvice({
  required TimingOwnership ownership,
  required DateTime today,
  DateTime? lastStart,
  int? cycleLength,
  bool irregular = false,
}) {
  // ⚠️ FIRST, AND BEFORE ANY DATE IS READ. See the header.
  if (!TtcPathwayBehaviour(ownership).countsToPeriod) {
    return const TtcTestAdvice(branch: TtcTestBranch.clinic);
  }
  if (lastStart == null) {
    return const TtcTestAdvice(branch: TtcTestBranch.noDates);
  }
  if (cycleLength == null || cycleLength < 1) {
    return const TtcTestAdvice(branch: TtcTestBranch.needCycleLength);
  }
  final day = DateTime(today.year, today.month, today.day);
  final due = ttcPeriodDueOn(lastStart, cycleLength);
  final gap = due.difference(day).inDays;
  if (gap > 0) {
    return TtcTestAdvice(
        branch: TtcTestBranch.early,
        due: due,
        daysUntil: gap,
        rough: irregular);
  }
  if (gap == 0) {
    return TtcTestAdvice(
        branch: TtcTestBranch.dueToday, due: due, rough: irregular);
  }
  return TtcTestAdvice(
      branch: TtcTestBranch.late, due: due, daysLate: -gap, rough: irregular);
}

// ---- dates, the way the stage writes them -----------------------------------

const List<String> _kWeekday = [
  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', //
];
const List<String> _kMonth = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Fri 20 Sep". Weekday first, because "is that this Friday?" is the first
/// thing anyone asks of a date in a message.
String ttcDayDate(DateTime d) =>
    '${_kWeekday[d.weekday - 1]} ${d.day} ${_kMonth[d.month - 1]}';

/// "20 Sep", for the places a weekday would crowd the line.
String ttcShortDay(DateTime d) => '${d.day} ${_kMonth[d.month - 1]}';

/// "1 day" or "5 days".
String ttcDays(int n) => n == 1 ? '1 day' : '$n days';
