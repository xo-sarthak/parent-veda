// =============================================================================
//  Which fertile window to show, and when it is
// -----------------------------------------------------------------------------
//  ONE PROJECTION, READ BY THREE SCREENS. The Today header, the Find-my-
//  fertile-window door and the cycle companion all need the same answer to the
//  same question: *which* window are we talking about, and what dates is it on.
//  Before this file each of them worked it out inline from `ov - 5` and
//  `ov + 1`, which is how the header and the door screen could disagree about
//  the same week.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY THIS NEVER RETURNS A WINDOW THAT HAS ALREADY CLOSED
//  ---------------------------------------------------------------------------
//
//  A closed window is information she cannot act on. Worse, it is information
//  she cannot act on presented in the same shape as information she can — the
//  screen reads "your fertile days: 12–18 August" whether that is next week or
//  last week, and the only thing distinguishing them is a small status chip she
//  has no reason to read twice.
//
//  On a stage built to remove pressure, showing a passed window is showing her
//  a chance she missed. So [ttcFertileWindowNow] rolls forward: when this
//  cycle's window has closed, the answer is the NEXT one, labelled honestly as
//  a projection.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT THIS IS NOT ALLOWED TO BECOME
//  ---------------------------------------------------------------------------
//
//  A window is a TIMING estimate, which this app is permitted to make. It is
//  not a probability, and nothing in this file may ever grow a field that reads
//  as one — no "chance this cycle", no score, no ranking of one window against
//  another. See CLAUDE.md's clinical invariants and
//  `test/ttc_clinical_review_test.dart`, which scans source rather than a seed
//  list precisely so a new field like that is caught here.
//
//  And it defers. When `TimingOwnership` says a clinic holds the timing, or the
//  engine has refused to estimate, this returns **null** and the caller must
//  say so in words rather than draw an empty week. Returning a "best guess"
//  here would put ParentVeda's calculation above a treating clinician, which is
//  six places higher than it belongs — see `lib/services/truth_hierarchy.dart`.
// =============================================================================

import 'ttc_chapter.dart';
import 'cycle_store.dart';
import 'ttc_store.dart';

/// Sperm survive about five days; the egg about one. The window is the five
/// days before ovulation and ovulation itself: SIX DAYS ENDING ON OVULATION
/// (ASRM), the user's decision of 2026-09-26.
///
/// ⚠️ IT WAS SEVEN (the day after too) until the launch walk of 2026-09-27
/// found the app saying both: every read and the window screen's words said
/// six days, while the home hero ("today and 6 more days") and the Companion
/// ("Fertile days · 7 days") counted seven from this constant. Kept for revert:
/// `const int ttcWindowClosesAfterOvulation = 1;`
///
/// These two live here rather than in each screen because they were already
/// duplicated in `ttc_cycle_screens.dart` and about to be duplicated again.
const int ttcWindowOpensBeforeOvulation = 5;
const int ttcWindowClosesAfterOvulation = 0;

/// A fertile window, resolved to real dates.
///
/// Cycle days AND dates, deliberately. The engine thinks in cycle days; a woman
/// planning a week thinks in dates; the bar chart needs both on the same row.
class TtcFertileWindow {
  const TtcFertileWindow({
    required this.opensOn,
    required this.peakOn,
    required this.closesOn,
    required this.opensCycleDay,
    required this.peakCycleDay,
    required this.closesCycleDay,
    required this.cyclesAhead,
    required this.openNow,
    required this.daysUntilOpen,
  });

  final DateTime opensOn;
  final DateTime peakOn;
  final DateTime closesOn;

  /// Cycle days *within the cycle this window belongs to*. For a projected
  /// window (`cyclesAhead > 0`) these are the day numbers of that future cycle,
  /// not an ever-growing count from the last logged period.
  final int opensCycleDay;
  final int peakCycleDay;
  final int closesCycleDay;

  /// 0 = the cycle she is in now. 1 = the next one, and so on.
  ///
  /// ⚠️ CALLERS MUST SAY THIS OUT LOUD when it is not zero. A projected window
  /// is a guess built on a guess — an assumed cycle length applied to an
  /// estimated ovulation day — and presenting it with the same confidence as
  /// the current one is the "ovulation around day 40" failure that
  /// `TtcNoEstimate` was added to stop.
  final int cyclesAhead;

  /// True when today falls inside it.
  final bool openNow;

  /// Days from today until it opens. Zero when it is already open.
  final int daysUntilOpen;

  /// How many days it spans, inclusive. Seven on the default model.
  int get lengthInDays => closesOn.difference(opensOn).inDays + 1;

  /// Every date in the window, in order. What the day-by-day bars iterate.
  List<DateTime> get days => [
        for (var i = 0; i < lengthInDays; i++)
          DateTime(opensOn.year, opensOn.month, opensOn.day + i),
      ];
}

/// The window she can still act on: the one that is open now, or the next one.
///
/// Never a window that has closed — see the header note. Returns null when the
/// app is not entitled to an estimate at all, which is a real answer and must
/// be rendered as words rather than as an empty chart.
/// [ignoreOwnership] skips refusal (1) ONLY.
///
/// ⚠️ NO CALLERS SINCE 2026-09-26 (consistency pass). The home hero was the
/// one caller described below; it now reads `ttcDayContext`, which refuses on
/// a clinic cycle like every other surface (see the note in
/// `ttc_home_hero.dart`). The parameter is kept, unused, for revert.
///
/// ⚠️ ONE CALLER, AND IT IS A PRODUCT DECISION RATHER THAN A CLINICAL ONE —
/// 2026-09-05. The home hero passes it. Asked for directly and repeatedly, after
/// four rounds of the hero showing a clinic refusal instead of a cycle message:
/// *"I don't want hero section to display what it was displaying… not that IVF
/// and everything. Because it's not happening right now and we will figure out
/// a way about it."*
///
/// The reasoning behind that is sound and worth writing down rather than
/// arguing with: `ownership` is derived from `path.defaultMedicated`, which is
/// a guess from a LABEL she tapped once, and `setPath` clears both of her real
/// answers so the guess always wins. The flag says "a clinic is running this
/// cycle" on the strength of a tap, not on anything anybody told us. The hero
/// is being asked not to act on a guess.
///
/// ⚠️ WHAT IT DOES **NOT** CHANGE, AND THIS IS THE PART THAT MATTERS. Nothing
/// else in the app passes it. The cycle companion still refuses, the calendar
/// still refuses, `Inferable` is untouched, and the whole clinical suite — the
/// 36 tests that correctly rejected a global version of this change on the same
/// day — still runs green. And the hero still leads on her clinic's own dates
/// wherever they exist, because those outrank everything we compute.
///
/// ⚠️ THE PROPER FIX IS AT THE DOOR, NOT HERE: ownership should follow her
/// ANSWERS, never a pathway default. That is `docs/STILL-OPEN.md` §30 and it is
/// the reason this parameter is a named exception with one call site rather
/// than a change to the rule.
///
/// ⚠️ RETIRED 2026-09-26, FULLY. The exception existed because `ownership`
/// came from a label she tapped once. It now comes from real clinic dates in
/// the treatment tracker (`ttcTimingOwnershipFromEvidence` in
/// `ttc_care_pathway.dart`), so a label alone never reaches refusal (1) and
/// there is nothing left to bypass. Kept for revert:
///   TtcFertileWindow? ttcFertileWindowNow(
///       {DateTime? on, bool ignoreOwnership = false}) {
TtcFertileWindow? ttcFertileWindowNow({DateTime? on}) {
  final store = TtcStore.instance;
  final today = store.today;

  // ⚠️ THE THREE REFUSALS, IN ORDER OF AUTHORITY.
  //
  //   1. A clinic owns the timing → we do not run numbers alongside theirs.
  //   2. The engine declined to estimate → there is nothing to project FROM.
  //   3. Nothing logged → there is no cycle to sit inside.
  //
  // All three are `null`, not a fallback, because the difference between them
  // is a difference in what to SAY, and only the caller knows the screen.
  // Kept for revert: `if (!ignoreOwnership && ...)`.
  if (!today.behaviour.showsFertilityWindow) return null;
  // ⚠️ THE GATE IS IN TWO PLACES, AND THE FIRST ATTEMPT ONLY MOVED ONE.
  // `showsFertilityWindow` above is the obvious one; `estimatedOvulationDay` is
  // the real one — the engine computes `ov`, then publishes null whenever a
  // clinic owns the timing. Skipping the first check alone changed nothing, and
  // the test suite said so by continuing to pass.
  // Kept for revert:
  //   final ov =
  //       ignoreOwnership ? today.rawOvulationDay ?? today.estimatedOvulationDay
  //                       : today.estimatedOvulationDay;
  final ov = today.estimatedOvulationDay;
  final start = CycleStore.instance.lastPeriodStart;
  if (ov == null || start == null) return null;

  final cycleDay = today.cycleDay;
  if (cycleDay == null) return null;

  final length = today.cycleLength;
  if (length <= 0) return null;

  final opensDay = ov - ttcWindowOpensBeforeOvulation;
  final closesDay = ov + ttcWindowClosesAfterOvulation;

  // Roll forward a whole cycle at a time until the window has not yet closed.
  //
  // A loop rather than arithmetic because the arithmetic is only correct while
  // the window sits inside one cycle length, and a short luteal phase on a long
  // assumed cycle can put `opensDay` at a negative offset. Six iterations is
  // already six months out; the cap stops a pathological cycle length from
  // spinning here.
  var ahead = 0;
  while (cycleDay > closesDay + (ahead * length) && ahead < 24) {
    ahead++;
  }

  final shift = ahead * length;
  final dayZero = DateTime(start.year, start.month, start.day);
  DateTime dateOf(int day) =>
      DateTime(dayZero.year, dayZero.month, dayZero.day + day - 1);

  final opensAbsolute = opensDay + shift;
  final untilOpen = opensAbsolute - cycleDay;

  return TtcFertileWindow(
    opensOn: dateOf(opensAbsolute),
    peakOn: dateOf(ov + shift),
    closesOn: dateOf(closesDay + shift),
    opensCycleDay: opensDay,
    peakCycleDay: ov,
    closesCycleDay: closesDay,
    cyclesAhead: ahead,
    openNow: untilOpen <= 0,
    daysUntilOpen: untilOpen < 0 ? 0 : untilOpen,
  );
}

/// The window [step] cycles past the soonest actionable one.
///
/// `step: 0` is exactly [ttcFertileWindowNow]. Paging is expressed relative to
/// that rather than to the calendar so the first tap of the forward arrow means
/// "the one after the one I am looking at" no matter which cycle she opened the
/// screen in.
///
/// ⚠️ EVERY STEP COMPOUNDS ONE ASSUMPTION. A projected window applies her usual
/// cycle length to an estimated ovulation day; the second applies it twice, and
/// so on. Callers cap this — the fertile-window screen stops at six — and must
/// label anything with `cyclesAhead > 0` as expected rather than known.
TtcFertileWindow? ttcWindowAhead(int step) {
  final base = ttcFertileWindowNow();
  if (base == null || step <= 0) return base;

  final today = TtcStore.instance.today;
  final length = today.cycleLength;
  if (length <= 0) return base;

  final shift = Duration(days: length * step);
  return TtcFertileWindow(
    opensOn: base.opensOn.add(shift),
    peakOn: base.peakOn.add(shift),
    closesOn: base.closesOn.add(shift),
    opensCycleDay: base.opensCycleDay,
    peakCycleDay: base.peakCycleDay,
    closesCycleDay: base.closesCycleDay,
    cyclesAhead: base.cyclesAhead + step,
    // A future window is never open now, and "days until" is measured from
    // today so it keeps growing as she pages.
    openNow: false,
    daysUntilOpen: base.daysUntilOpen + (length * step),
  );
}

/// The fertility level for a date inside a projected window.
///
/// The engine reasons in cycle days of the CURRENT cycle, so a date in next
/// month's window has to be mapped back onto the equivalent day of this one
/// before it can be scored. Doing that here rather than at the call site is
/// what stops a projected bar chart quietly reading every day as "Low".
FertilityLevel? ttcFertilityOnDate(TtcFertileWindow window, DateTime date) {
  final store = TtcStore.instance;
  const engine = TtcChapterEngine();
  final offsetFromOpen = date.difference(window.opensOn).inDays;
  final dayInOwnCycle = window.opensCycleDay + offsetFromOpen;
  return engine.fertilityFor(store.state(), dayInOwnCycle);
}
