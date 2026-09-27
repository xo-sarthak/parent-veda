// =============================================================================
//  Where she is on a given date — ONE answer, read by every TTC surface
// -----------------------------------------------------------------------------
//  Added 2026-09-26 for the consistency pass. The brief, in the user's words:
//  "The whole trying-to-conceive side must be personalised to the user by the
//  date of her cycle, and CONSISTENT. The hero section and today's insights
//  must match the date of her cycle; age must be handled the same everywhere."
//
//  ⚠️ WHY THIS FILE EXISTS. Every surface used to work out "where is she" for
//  itself, from the same stores, with slightly different rules:
//
//    * the home's content phase called the expected-period day itself "late",
//      while the hero, the calendar and the "Should I test?" chat all call it
//      "due today" and only the day AFTER it late;
//    * the hero said "past your usual length" on a first cycle (no usual
//      length exists) while the cards below it said "the waiting days";
//    * the calendar and the "chance" card shaded a fertile window into past
//      cycles, from THIS cycle's estimate, while the hero said in words that
//      we do not work out fertile days for an earlier cycle;
//    * the hero's window dates rolled forward to next cycle's window while the
//      big line was counting to this cycle's, whenever the strip stood before
//      the window and today stood after it;
//    * the calendar counted "next period in N days" from the clock with a
//      time in it, so it said one day fewer than the hero most of the day.
//
//  Each was right in its own file and wrong on the screen. The fix is not five
//  patches, it is one function every surface asks: [ttcDayContext].
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE RULES, ONCE, IN THE ORDER THEY ARE APPLIED
//  ---------------------------------------------------------------------------
//
//  1. THE CYCLE A DATE BELONGS TO is the latest logged period start on or
//     before it. The current cycle is the one opened by her latest start.
//  2. A CLINIC CYCLE (`TimingOwnership` other than `parentveda`) gets no phase,
//     no window, no due date and no late. Cycle day is still hers (it is her
//     logged period subtracted from the date, not a prediction). The phase is
//     `any`. Her clinic's own dates lead where they exist (the hero).
//
//     ⚠️ WHAT MAKES A CYCLE A CLINIC CYCLE CHANGED ON 2026-09-26 (the user's
//     decision): real clinic dates for that cycle in the treatment tracker,
//     not the pathway label she tapped (`TtcStore.ownership`,
//     `ttcTimingOwnershipFromEvidence`). A label with no dates is her own
//     cycle on every surface. While the cycle she is in IS clinic-owned, no
//     cycle shows a window, earlier ones included: the whole app follows the
//     clinic.
//
//     ⚠️ TWO REFINEMENTS, 2026-09-26 (docs/TTC-TREATMENT-FLOW.md, B2). A
//     treatment ROUND owns the cycle she is in from its first treatment date
//     until she closes it (`TtcStore.ownership`, `ttcTreatmentActive`), and
//     a planned round's dates for next month do not. And the refusal is for
//     the cycle she is in and the cycles a round ran in: the earlier cycles
//     from before treatment KEEP their look-back window (rule 3), the lead's
//     decision for consistency. The sentence above is kept for the history.
//  3. AN EARLIER CYCLE shows the fertile days it had, WORKED OUT LOOKING BACK
//     from that cycle's own length (DECIDED 2026-09-26, "as competitor
//     calendars do"): ovulation about 14 days before the period she logged
//     next (`TtcChapterEngine.lookBackOvulationDay`), the window ovulation-5
//     to ovulation+1 as for the current cycle. It is two facts and one
//     subtraction, labelled as looking back ([TtcDayContext.lookingBack]),
//     never a prediction: no due date, never late. None for a cycle that looks
//     like a missed log (the engine's own refusal), for one whose own dates
//     show her clinic ran it, or while the current cycle is clinic-owned. Its
//     days are phased period / before / window / waiting from that window.
//
//     Kept for revert, the rule before: "AN EARLIER CYCLE gets no window: we
//     estimate ovulation for the cycle she is in, from that cycle's signals.
//     Its logged period days are still her period (a fact); every other day
//     is `any`."
//  4. PERIOD DAYS are cycle days 1 to her logged bleed length for that start,
//     else [kTtcAssumedBleedDays] (`ttcBleedDaysFor`). They win an overlap
//     with the window, the same rule the cycle pictures use.
//  5. THE WINDOW is the engine's published estimate for the CURRENT cycle:
//     cycle days ovulation-5 to ovulation+1 (`ttc_fertile_window.dart`), on
//     the dates of this cycle. Null whenever the engine refuses (nothing
//     logged, a gap that looks like a missed log, a cycle run past where her
//     history says it ends) — and then there is no due date either, because
//     both rest on the same usual length.
//  6. THE PERIOD IS DUE on the current start plus her usual length
//     (`ttcPeriodDueOn`), which is cycle day length + 1: the day the calendar
//     marks, the hero calls "may start today" and the chat calls "due today".
//  7. WAITING runs from the day after the window closes to the due day
//     INCLUSIVE. The due day is still the wait: nothing is late yet.
//  8. LATE starts the day AFTER the due day, only on a day that has happened,
//     and only with a history that can carry the word
//     (`ttcLateHistoryReliable`: two completed cycles, regular, no gap that
//     looks like a missed log). Without one, a past-due day stays `waiting`
//     and the hero says the period "may have started" rather than "late".
//     Late ends where the engine stops estimating (the cycle overdue by its
//     own luteal length), which is also where the chat's "that's a while"
//     starts (`TtcTestAdvice.looksStale`).
//
//  ⚠️ NOTHING HERE IS A CHANCE. Dates, days and stretches only. The fertility
//  level is the engine's own position-in-cycle band, the same one the calendar
//  has always drawn; no field may grow that reads as how likely conception is.
//  `test/ttc_clinical_review_test.dart` scans this file like every other.
//
//  `test/ttc_date_consistency_test.dart` walks every scenario day by day and
//  asserts the hero, the insights phase, the reads, the calendar, the window,
//  the messages, the chat and the temperature chart all agree with this.
// =============================================================================

import 'cycle_store.dart';
import 'ttc_chapter.dart';
import 'ttc_cycle_report.dart' show ttcBleedDaysFor;
import 'ttc_fertile_window.dart'
    show ttcWindowOpensBeforeOvulation, ttcWindowClosesAfterOvulation;
import 'ttc_fertility_help_rules.dart' show FertilityAgeBand;
import 'ttc_fertility_help_store.dart';
import 'ttc_messages_store.dart' show TtcMessageFacts, ttcLateHistoryReliable;
import 'ttc_period_due.dart' show ttcPeriodDueOn;
import 'ttc_phase.dart';
import 'ttc_store.dart';
import 'ttc_treatment_round.dart' show ttcFirstTreatmentDate;
import 'ttc_treatment_store.dart';

export 'ttc_phase.dart' show TtcDayPhase;

/// Everything a TTC surface needs to know about one date, resolved together.
class TtcDayContext {
  const TtcDayContext({
    required this.date,
    required this.today,
    required this.ownership,
    required this.usualLength,
    required this.hasOwnLength,
    required this.confidence,
    required this.noEstimate,
    required this.lateReliable,
    required this.phase,
    this.cycleOwnership = TimingOwnership.parentveda,
    this.cycleStart,
    this.isCurrentCycle = false,
    this.cycleDay,
    this.bleedDays = 0,
    this.ovulationDay,
    this.windowOpensOn,
    this.windowPeakOn,
    this.windowClosesOn,
    this.periodDueOn,
    this.fertility,
    this.ageBand,
  });

  /// The date described, at midnight.
  final DateTime date;

  /// Today, at midnight. Every "future" and "late" is measured from this.
  final DateTime today;

  /// Who owns the timing. Anything but `parentveda` refuses rules 5 to 8.
  final TimingOwnership ownership;

  /// The logged period start that opened the cycle [date] is in. Null before
  /// anything is logged, or for a date earlier than every logged start.
  final DateTime? cycleStart;

  /// True when [cycleStart] is her latest logged start.
  final bool isCurrentCycle;

  /// 1 on the first day of [cycleStart]. Null when there is no cycle.
  final int? cycleDay;

  /// Her usual cycle length (her recent average, else the engine's default).
  final int usualLength;

  /// True once she has one completed cycle, so [usualLength] is hers.
  final bool hasOwnLength;

  /// Days of bleeding for [cycleStart]: hers when logged, else the stated
  /// default. 0 when there is no cycle.
  final int bleedDays;

  /// Ovulation, as a cycle day of the cycle [date] is in: the engine's
  /// estimate for the current cycle, the look-back for an earlier one (rule
  /// 3). Null on a clinic cycle and whenever the engine refuses.
  final int? ovulationDay;

  final OvulationConfidence confidence;
  final TtcNoEstimate noEstimate;

  /// The fertile window of the cycle [date] is in, on real dates. Null exactly
  /// when [ovulationDay] is. For an earlier cycle it is the look-back window
  /// ([lookingBack]).
  final DateTime? windowOpensOn;
  final DateTime? windowPeakOn;
  final DateTime? windowClosesOn;

  /// The day the current cycle's period is expected. Null exactly when the
  /// window is (same usual length, same refusals), and on an earlier cycle.
  final DateTime? periodDueOn;

  /// Whether her history can carry the word "late" (rule 8).
  final bool lateReliable;

  /// Which stretch [date] is in, for choosing content. See the rules above.
  final TtcDayPhase phase;

  /// The engine's position band for [date]. Null wherever there is no window.
  /// On an earlier cycle it is the same grading of the look-back window, for
  /// the calendar's shading; surfaces that put a band into words (the
  /// "chance" card) show it for the current cycle only ([lookingBack]).
  final FertilityLevel? fertility;

  /// Who owns the timing of the cycle [date] is in. The same as [ownership]
  /// for the current cycle; an earlier cycle answers for its own dates.
  final TimingOwnership cycleOwnership;

  /// Her age band: the ONE saved answer (`TtcFertilityHelpStore.ageBand`),
  /// the same getter the messages' six-or-twelve months, the home's check
  /// card, the IVF door's tab order and the help tool read, each through
  /// `FertilityAgeBand.refersAtPresentation` for "35 and over".
  final FertilityAgeBand? ageBand;

  // ---- derived ---------------------------------------------------------------

  bool get isToday => date == today;
  bool get isFuture => date.isAfter(today);
  bool get clinicOwned => ownership != TimingOwnership.parentveda;
  bool get isPastCycle => cycleStart != null && !isCurrentCycle;
  bool get hasWindow => windowOpensOn != null;

  /// True when the window shown is an earlier cycle's, worked out looking back
  /// (rule 3). Every surface that names it says so.
  bool get lookingBack => isPastCycle && hasWindow;

  /// True when the cycle [date] is in was run by a clinic.
  bool get cycleClinicOwned => cycleOwnership != TimingOwnership.parentveda;

  /// Window edges as cycle days of the cycle [date] is in.
  int? get windowOpensCycleDay => ovulationDay == null
      ? null
      : ovulationDay! - ttcWindowOpensBeforeOvulation;
  int? get windowClosesCycleDay => ovulationDay == null
      ? null
      : ovulationDay! + ttcWindowClosesAfterOvulation;

  /// True on the logged (or default-length) bleed days of [cycleStart].
  bool get isPeriodDay => cycleDay != null && cycleDay! <= bleedDays;

  /// True inside the displayed window (a bleed day can be both; see rule 4).
  ///
  /// Any cycle with a window since 2026-09-26 (rule 3). Kept for revert, the
  /// current-cycle-only test: `isCurrentCycle && o != null && ...`.
  bool get inWindow {
    final o = windowOpensCycleDay, c = windowClosesCycleDay, d = cycleDay;
    return o != null && c != null && d != null && d >= o && d <= c;
  }

  bool get isOvulationDay => ovulationDay != null && cycleDay == ovulationDay;
  // Kept for revert:
  //   isCurrentCycle && ovulationDay != null && cycleDay == ovulationDay;

  bool get isExpectedPeriodDay => periodDueOn != null && date == periodDueOn;

  /// Days from the due day to [date]. Positive = past it. Null with no due.
  int? get daysPastDue =>
      periodDueOn == null ? null : date.difference(periodDueOn!).inDays;

  /// Days of window left including [date], when [date] is inside the CURRENT
  /// cycle's window. A count is for a window she is in, never a past one.
  int? get windowDaysLeft => isCurrentCycle && inWindow
      ? windowClosesCycleDay! - cycleDay! + 1
      : null;

  /// Days until the window opens, when [date] is before it this cycle.
  int? get daysUntilWindow {
    final o = windowOpensCycleDay, d = cycleDay;
    if (!isCurrentCycle || o == null || d == null || d >= o) return null;
    return o - d;
  }
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Ovulation for the EARLIER cycle that began on [start] and ended the day
/// before [next], worked out looking back from its own length (rule 3), or
/// null when that cycle is not ours to draw.
///
/// ⚠️ THE ONE LOOK-BACK, READ BY EVERY SURFACE THAT DRAWS AN EARLIER CYCLE:
/// this resolver (hero, insights, calendar), the cycle report's phases and
/// the companion's phase bands (`ttc_cycle_report.dart`). Each used to have
/// its own answer for a past cycle — none, or THIS cycle's estimate — which
/// is how the calendar once shaded last month from this month's arithmetic.
///
/// Null when: the current cycle is clinic-owned (the whole app follows the
/// clinic); the earlier cycle held clinic dates of its own; its length is
/// outside the plausible range `CycleStore` counts; or it looks like a missed
/// log (`TtcChapterEngine.looksLikeMissedLog`).
int? ttcLookBackOvulationDay(DateTime start, DateTime next,
    [List<int>? lengths]) {
  final store = TtcStore.instance;
  // ⚠️ NOT WHILE THE CURRENT CYCLE IS HELD, ANY MORE (2026-09-26, the
  // treatment flow's resolver decision): an earlier cycle from before any
  // round keeps its look-back fertile days during a round, and only a cycle
  // a round ran in hides them (the `ownershipOfCycle` check below). Kept for
  // revert:
  //   if (store.ownership != TimingOwnership.parentveda) return null;
  final from = _dayOnly(start), to = _dayOnly(next);
  if (store.ownershipOfCycle(from, nextStart: to) !=
      TimingOwnership.parentveda) {
    return null;
  }
  final ranFor = to.difference(from).inDays;
  if (ranFor < CycleStore.minPlausibleCycleDays ||
      ranFor > CycleStore.maxPlausibleCycleDays) {
    return null;
  }
  return const TtcChapterEngine().lookBackOvulationDay(
      ranFor, lengths ?? CycleStore.instance.cycleLengths);
}

/// THE resolver. Every TTC surface that shows a cycle day, a phase, a window,
/// an expected period or "late" asks this, for the date it is showing.
///
/// [now] exists for tests; the app always passes nothing.
TtcDayContext ttcDayContext(DateTime day, {DateTime? now}) {
  final store = TtcStore.instance;
  final cycle = CycleStore.instance;
  const engine = TtcChapterEngine();

  final date = _dayOnly(day);
  final today = _dayOnly(now ?? DateTime.now());
  final state = store.state(on: today);
  final resolved = engine.resolve(state);
  final ownership = resolved.ownership;

  // ---- rule 8's history test, from the ONE function the messages use -------
  final lengths = cycle.cycleLengths;
  final usual = resolved.cycleLength;
  final lateReliable = ttcLateHistoryReliable(TtcMessageFacts(
    cycleLengths: lengths,
    usualLength: lengths.isEmpty ? null : usual,
    irregular: engine.isIrregular(state),
    historyLooksOff: engine.hasUnreliableHistory(state),
  ));

  // ---- rule 1: which cycle ---------------------------------------------------
  final starts = [...cycle.periodStarts.map(_dayOnly)]..sort();
  DateTime? opened;
  for (final s in starts) {
    if (!s.isAfter(date)) opened = s;
  }
  final current = opened != null && opened == starts.last;
  final cycleDay = opened == null ? null : date.difference(opened).inDays + 1;
  final bleed = opened == null ? 0 : ttcBleedDaysFor(opened);

  TtcDayContext build({
    required TtcDayPhase phase,
    int? ov,
    FertilityLevel? fertility,
    DateTime? due,
    TimingOwnership? cycleOwnership,
  }) {
    DateTime? on(int cd) => opened == null
        ? null
        : DateTime(opened.year, opened.month, opened.day + cd - 1);
    return TtcDayContext(
      date: date,
      today: today,
      ownership: ownership,
      cycleStart: opened,
      isCurrentCycle: current,
      cycleDay: cycleDay,
      usualLength: usual,
      hasOwnLength: lengths.isNotEmpty,
      bleedDays: bleed,
      ovulationDay: ov,
      confidence: resolved.confidence,
      noEstimate: resolved.noEstimate,
      windowOpensOn: ov == null ? null : on(ov - ttcWindowOpensBeforeOvulation),
      windowPeakOn: ov == null ? null : on(ov),
      windowClosesOn:
          ov == null ? null : on(ov + ttcWindowClosesAfterOvulation),
      periodDueOn: due,
      lateReliable: lateReliable,
      phase: phase,
      fertility: fertility,
      cycleOwnership: cycleOwnership ?? ownership,
      ageBand: TtcFertilityHelpStore.instance.ageBand,
    );
  }

  // Nothing logged, or a date before everything logged.
  if (opened == null || cycleDay == null) {
    return build(phase: TtcDayPhase.any);
  }

  // ---- rule 2: a clinic cycle -------------------------------------------------
  // ⚠️ THE CYCLE SHE IS IN, SINCE 2026-09-26. While a round holds it, an
  // earlier cycle is answered by rule 3 for its own dates, so the cycles
  // before treatment keep their look-back window. Kept for revert:
  //   if (ownership != TimingOwnership.parentveda) {
  if (current && ownership != TimingOwnership.parentveda) {
    return build(phase: TtcDayPhase.any);
  }

  // ---- rule 2b: a planned round's own days (2026-09-26, B5) -----------------
  // A round saved for later leaves the cycle she is in hers until its first
  // treatment date (decision 1). But a date ON or after that first date is
  // the clinic's day, not a day of ours: no window, no expected period and
  // no late are drawn there, even while today is still her own cycle. So the
  // calendar never puts "period expected" on the morning of a baseline scan.
  if (current) {
    final round = TtcTreatmentStore.instance.cycle;
    final first = round.isEmpty || round.isClosed
        ? null
        : ttcFirstTreatmentDate(round);
    // Only a round still AHEAD of today: one already started holds the cycle
    // by rule 2, and a legacy round's past dates are answered by the
    // evidence rule for the cycle they fall in.
    if (first != null && first.isAfter(today) && !date.isBefore(first)) {
      return build(phase: TtcDayPhase.any);
    }
  }

  final periodPhase =
      cycleDay <= bleed ? TtcDayPhase.period : TtcDayPhase.any;

  // ---- rule 3: an earlier cycle, looking back ----------------------------------
  if (!current) {
    // Kept for revert: `if (!current) return build(phase: periodPhase);`
    final from = opened;
    final next = starts.firstWhere((s) => s.isAfter(from));
    final own = store.ownershipOfCycle(from, nextStart: next);
    if (own != TimingOwnership.parentveda) {
      return build(phase: TtcDayPhase.any, cycleOwnership: own);
    }
    final ov = ttcLookBackOvulationDay(from, next, lengths);
    // `cycleOwnership: own` (2026-09-26): this earlier cycle is hers even
    // while a round holds the current one, and says so.
    if (ov == null) return build(phase: periodPhase, cycleOwnership: own);
    final opens = ov - ttcWindowOpensBeforeOvulation;
    final closes = ov + ttcWindowClosesAfterOvulation;
    final TtcDayPhase past;
    if (cycleDay <= bleed) {
      past = TtcDayPhase.period; // rule 4, as for the current cycle
    } else if (cycleDay >= opens && cycleDay <= closes) {
      past = TtcDayPhase.window;
    } else if (cycleDay < opens) {
      past = TtcDayPhase.beforeWindow;
    } else {
      past = TtcDayPhase.waiting; // she logged the next period: never late
    }
    return build(
        phase: past,
        ov: ov,
        fertility: ttcFertilityForOffset(cycleDay - ov),
        cycleOwnership: own);
  }

  // ---- rule 5: the current cycle's window, or the engine's refusal -----------
  final ov = resolved.estimatedOvulationDay;
  if (ov == null || usual <= 0) return build(phase: periodPhase);

  final due = ttcPeriodDueOn(opened, usual);
  final fertility = engine.fertilityFor(state, cycleDay);

  final TtcDayPhase phase;
  final opens = ov - ttcWindowOpensBeforeOvulation;
  final closes = ov + ttcWindowClosesAfterOvulation;
  if (cycleDay <= bleed) {
    phase = TtcDayPhase.period; // rule 4: period wins an overlap
  } else if (cycleDay >= opens && cycleDay <= closes) {
    phase = TtcDayPhase.window;
  } else if (cycleDay < opens) {
    phase = TtcDayPhase.beforeWindow;
  } else if (!date.isAfter(due)) {
    phase = TtcDayPhase.waiting; // rule 7: the due day is still the wait
  } else if (date.isAfter(today) || !lateReliable) {
    phase = TtcDayPhase.waiting; // rule 8: never late ahead of time, or on a guess
  } else {
    phase = TtcDayPhase.late;
  }

  return build(phase: phase, ov: ov, fertility: fertility, due: due);
}
