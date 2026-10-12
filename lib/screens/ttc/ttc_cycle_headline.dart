// =============================================================================
//  TTC · one sentence about where she is in her cycle, for every screen
// -----------------------------------------------------------------------------
//  2026-10-07. The user: the home hero says one thing ("fertile days open in
//  18 days", "period phase, day 5"), Cycle companion and the Cycle report say
//  another, and the fertile days are not mentioned on either. "Make sure these
//  things are in sync."
//
//  The numbers already came from one engine (CycleStore -> ttcDayContext);
//  what differed was the WORDS: only the home turned the state into a
//  countdown. This is that sentence, built from the same `ttcHomeHeroLine`
//  and the same strings the home uses, so the three screens cannot drift.
//
//  Only the window and the wait produce a sentence. Every refusal (nothing
//  logged, a clinic holding the cycle, no estimate) returns null and each
//  screen keeps its own refusal wording, as before: we predict only where we
//  predict (CLAUDE.md, clinical invariants). Never a chance or a level.
// =============================================================================

import '../../ttc/ttc_day_context.dart';
import '../../ttc/ttc_home_hero.dart';
import 'ttc_strings.dart';

const List<String> _kShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String _fmt(DateTime d) => '${d.day} ${_kShort[d.month - 1]}';

/// "Fertile days open in 18 days (23 Oct to 28 Oct)", "Your period may start
/// in 6 days", ... for [on] (today when null), or null when we do not predict.
String? ttcCycleHeadline({DateTime? on}) {
  final day = on ?? DateTime.now();
  final t = TtcS.current();
  final line = ttcHomeHeroLine(on: day);
  String join(String lead, String big) => '$lead $big'.replaceAll(RegExp(r'\s+'), ' ').trim();
  String dates() {
    final ctx = ttcDayContext(day);
    final opens = ctx.windowOpensOn;
    final closes = ctx.windowClosesOn;
    if (opens == null || closes == null) return '';
    return ' (${_fmt(opens)} to ${_fmt(closes)})';
  }

  return switch (line.state) {
    TtcHeroState.windowOpensIn => join(t.leadFertileDays + t.headerOpenVerb, t.bigInDays(line.days)) + dates(),
    TtcHeroState.windowOpen => join(t.leadFertileDays + t.headerAreVerb, t.bigTodayAndMore(line.days)) + dates(),
    TtcHeroState.windowLastDay => join(t.leadFertileDays, t.bigEndToday),
    TtcHeroState.waiting => join(t.leadPeriodMayStart, t.bigInDays(line.days)),
    TtcHeroState.periodDue => join(t.leadPeriodMayStart, t.bigToday),
    TtcHeroState.periodLate => join(t.leadPastUsual, t.bigDays(line.days)),
    TtcHeroState.onPeriod => join(t.leadYourPeriod, t.bigPeriodDay(line.days).toLowerCase()),
    _ => null,
  };
}
