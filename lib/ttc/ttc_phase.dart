// =============================================================================
//  TTC - where she is in her cycle, for choosing today's cards and reads
// -----------------------------------------------------------------------------
//  TTC gap analysis, "Behind: Home & daily", P1: the home's daily cards and its
//  four reads rotated by DATE alone, so "your period came" could land in the
//  fertile window. Every daily item now carries the phases it fits, and the
//  pickers (`ttcInsightsForPhase`, `ttcReadIdsForPhase`) prefer those.
//
//  ⚠️ WHY `TtcDayPhase` AND NOT `TtcPhase`. `ttc_cycle_report.dart` already
//  declares `TtcPhase { period, beforeWindow, fertileWindow, afterWindow }` for
//  drawing the cycle picture, and the home imports files on both sides. Two
//  enums with one name compile until the first file that uses both, and then
//  fail as an ambiguous import. So this one has its own name, and
//  [ttcDayPhaseForCycleDay] maps from the picture's stretches, so the cards and
//  the picture can never disagree about which stretch today is in.
//
//  ⚠️ CONTENT CHOICE, NEVER A PREDICTION SHOWN TO HER. The phase picks which
//  card is on top. It is never printed as a claim ("you are ovulating today"),
//  and a clinic-run cycle is not phased by us at all (see
//  [ttcDayPhaseForCycleDay]).
// =============================================================================

import 'ttc_care_pathway.dart' show TimingOwnership;
import 'ttc_cycle_report.dart'
    show TtcPhase, ttcPhaseForCycleDay, kTtcAssumedBleedDays;

/// Which stretch of her cycle today is, for choosing content.
enum TtcDayPhase {
  /// The days of a logged period: cycle days 1 to 5, or her own recorded
  /// bleed length when she gave one (the same rule the cycle picture uses).
  period,

  /// After the period, before the fertile window opens.
  beforeWindow,

  /// The fertile window: about six days ending on the estimated ovulation
  /// day, plus the day after (`ttc_fertile_window.dart` owns the edges).
  window,

  /// After the window until the day the next period is expected: the
  /// two-week wait.
  waiting,

  /// From the day AFTER her period was due (cycle day usual length + 2) with
  /// no new period logged. The due day itself is still [waiting]: the hero,
  /// the calendar and the "Should I test?" chat all call it "due today".
  late,

  /// Fits any day. Also the answer whenever the phase is unknown: no period
  /// logged yet, or a cycle a clinic is timing (we do not phase those).
  any,
}

/// Today's phase from cycle arithmetic, or [TtcDayPhase.any] when it is not
/// ours to say.
///
/// * [cycleDay] is 1 on the first day of the last logged period.
/// * [ovulationDay] is the estimated ovulation day of this cycle.
/// * [usualLength] is her usual cycle length in days. The period is due on
///   cycle day `usualLength + 1`; a cycle day past THAT, with no new period
///   logged, is [TtcDayPhase.late]. The window is checked first, so a late
///   ovulation signal is never read as a late period.
///
/// ⚠️ THE LIVE SCREENS DO NOT CALL THIS ANY MORE (2026-09-26). They ask
/// `ttcDayContext` (`ttc_day_context.dart`), which applies the same rules plus
/// the ones this pure helper cannot know: whether her history can carry the
/// word "late", whether the day has happened, and which cycle a date is in.
/// Kept, and kept in step, because it is the arithmetic in its smallest form.
/// * [ownership]: anything but [TimingOwnership.parentveda] returns
///   [TtcDayPhase.any]. When a clinic is timing the cycle, the clinic's scan
///   beats our arithmetic, so we do not choose content as if we knew.
TtcDayPhase ttcDayPhaseForCycleDay({
  required int cycleDay,
  required int ovulationDay,
  required int usualLength,
  int bleedDays = kTtcAssumedBleedDays,
  TimingOwnership ownership = TimingOwnership.parentveda,
}) {
  if (ownership != TimingOwnership.parentveda) return TtcDayPhase.any;
  if (cycleDay < 1) return TtcDayPhase.any;
  // Kept for revert. It made the expected-period day itself "late", one day
  // ahead of every other surface, and it ran before the window check:
  //   if (cycleDay > usualLength) return TtcDayPhase.late;
  return switch (ttcPhaseForCycleDay(cycleDay, ovulationDay,
      bleedDays: bleedDays)) {
    TtcPhase.period => TtcDayPhase.period,
    TtcPhase.beforeWindow => TtcDayPhase.beforeWindow,
    TtcPhase.fertileWindow => TtcDayPhase.window,
    TtcPhase.afterWindow =>
      cycleDay > usualLength + 1 ? TtcDayPhase.late : TtcDayPhase.waiting,
  };
}
