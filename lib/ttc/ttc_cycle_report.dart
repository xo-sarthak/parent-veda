// =============================================================================
//  The cycle report — what a month of logging adds up to
// -----------------------------------------------------------------------------
//  ⚠️ THE BRIEF THIS ANSWERS, AND THE SENTENCE IN IT THAT MATTERS MOST:
//
//    "We don't want the user to just log the symptom and be like hey it's of
//     no use. The user won't do that then."
//
//  That is the whole problem with a logger. Recording is a cost paid today
//  against a benefit that arrives never, unless something gives it back. This
//  file is the giving-back, and it is deliberately a separate, pure layer: it
//  reads the stores, decides what can honestly be said, and returns a
//  structure. It draws nothing and it knows about no widgets.
//
//  ---------------------------------------------------------------------------
//  ⚠️ EVERY STATE IS ENUMERATED, BECAUSE THE EMPTY ONES ARE THE COMMON ONES
//  ---------------------------------------------------------------------------
//
//  The brief asked for the edge cases up front — "so that you are prepared for
//  all situations, when to show what to each user" — and that is exactly right,
//  because a report is a feature whose FAILURE states are what most people see:
//
//    · Most users on any given day have logged nothing.
//    · Many have logged a period but no symptoms.
//    · Many are three days into their first cycle with the app.
//    · Some are on a clinic-run cycle where we may not draw phases at all.
//    · Some have a gap the engine will not estimate across.
//
//  A report that assumes data and degrades badly is a report that is broken for
//  the majority. So [TtcReportState] is a closed set, the screen switches on it
//  exhaustively, and each one has its own honest thing to say. "A feature is
//  never hidden" — CLAUDE.md — the empty state is the feature's advertisement.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IT DESCRIBES. IT NEVER INTERPRETS, PREDICTS OR SCORES.
//  ---------------------------------------------------------------------------
//
//  "You logged cramping on four days, three of them in the week before your
//  period" is a description of her own data and is allowed.
//
//  "Your cramping suggests endometriosis" is a diagnosis. "Your chance this
//  cycle was higher because you logged egg-white mucus" is a personalised
//  probability. Both are forbidden — CLAUDE.md's clinical invariants, and
//  `test/ttc_clinical_review_test.dart` scans source rather than trusting this
//  comment. Every finding in this file is a count or a position, never a cause.
// =============================================================================

import 'ttc_chapter.dart';
import 'cycle_store.dart';
import 'ttc_day_context.dart' show ttcLookBackOvulationDay;
import 'ttc_fertile_window.dart';
import 'ttc_log_store.dart';
import 'ttc_store.dart';
import 'ttc_symptom_data.dart';

/// The tracker ids the report reads numbers from.
const String kTtcWeightTracker = 'weight';
const String kTtcWeightField = 'kg';
const String kTtcTempTracker = 'bbt';
const String kTtcTempField = 'celsius';

/// Where a day sits in the cycle. Used to group findings, never to predict.
enum TtcPhase { period, beforeWindow, fertileWindow, afterWindow }

extension TtcPhaseCopy on TtcPhase {
  String get label => switch (this) {
        TtcPhase.period => 'Period',
        TtcPhase.beforeWindow => 'Before your window',
        TtcPhase.fertileWindow => 'Fertile days',
        TtcPhase.afterWindow => 'The waiting days',
      };

  double get hue => switch (this) {
        TtcPhase.period => 344,
        TtcPhase.beforeWindow => 206,
        TtcPhase.fertileWindow => 160,
        TtcPhase.afterWindow => 268,
      };
}

/// Days of bleeding assumed when she has not told us.
///
/// ⚠️ FOR DRAWING A BAND, AND FOR NOTHING ELSE. It is never shown as a number,
/// never fed to the engine, and never presented as her period length. It exists
/// so the first stretch on a picture has an edge.
///
/// ⚠️ AND IT IS NOW A FALLBACK RATHER THAN THE RULE. `CycleStore.bleedDaysFor`
/// holds what she actually recorded, and every caller here prefers it. This
/// number is what the picture uses on a cycle she logged before the question
/// existed, or chose not to answer — which is most of them today and fewer of
/// them every month.
const int kTtcAssumedBleedDays = 5;

/// The bleed length to band a cycle with: hers if she said, the assumption if
/// not, and the assumption while a period is still going.
///
/// ⚠️ "STILL ON" FALLS BACK RATHER THAN DRAWING A BAND THAT GROWS. A period she
/// has marked ongoing has no length yet, and painting one that lengthens each
/// morning would be the app inventing a fact it is waiting for.
int ttcBleedDaysFor(DateTime start) {
  final logged = CycleStore.instance.bleedDaysFor(start);
  if (logged == null || logged == kBleedStillOn || logged < 1) {
    return kTtcAssumedBleedDays;
  }
  return logged;
}

/// Which stretch a cycle day falls in.
///
/// ⚠️ ONE PREDICATE, BECAUSE THREE PICTURES NOW DRAW THE SAME FOUR STRETCHES.
/// The day-by-day list, the ring and the timeline each need this answer, and
/// three inline copies of `ov - 5` is precisely how the fertile-window header
/// and its door screen once disagreed about the same week — see the note at the
/// head of `ttc_fertile_window.dart`, whose constants this borrows rather than
/// restating.
///
/// ⚠️ THE ORDER OF THE TESTS IS LOAD-BEARING. Period wins first. On a short
/// cycle the assumed bleed days and the window can overlap, and a day that is
/// both must read as the period — a picture that paints day 4 as fertile while
/// she is bleeding is one she will not trust again.
TtcPhase ttcPhaseForCycleDay(
  int cycleDay,
  int ovulationDay, {
  int bleedDays = kTtcAssumedBleedDays,
}) {
  if (cycleDay <= bleedDays) return TtcPhase.period;
  if (cycleDay >= ovulationDay - ttcWindowOpensBeforeOvulation &&
      cycleDay <= ovulationDay + ttcWindowClosesAfterOvulation) {
    return TtcPhase.fertileWindow;
  }
  if (cycleDay < ovulationDay - ttcWindowOpensBeforeOvulation) {
    return TtcPhase.beforeWindow;
  }
  return TtcPhase.afterWindow;
}

/// Which report she gets. Closed, and the screen must handle all of them.
enum TtcReportState {
  /// Nothing logged at all. The invitation.
  noPeriod,

  /// A clinic is running the cycle, so we do not draw our own phases.
  ///
  /// ⚠️ THE ONE STATE THAT IS A REFUSAL RATHER THAN A SHORTAGE. She may have
  /// months of data; we still may not lay our phase bands over a cycle a
  /// clinician is directing. Her logged days are shown, unbanded.
  clinicHeld,

  /// The engine will not estimate — a gap long enough to be an unlogged cycle,
  /// or too little history. Days are shown without phases.
  noEstimate,

  /// A period is logged and phases are known, but almost nothing else is.
  thin,

  /// Enough to describe.
  ready,
}

/// One day, as the report sees it.
class TtcReportDay {
  const TtcReportDay({
    required this.date,
    required this.cycleDay,
    required this.phase,
    required this.symptoms,
    this.weightKg,
    this.tempC,
  });

  final DateTime date;
  final int cycleDay;

  /// Null when phases are not ours to draw — clinic-held or no estimate.
  final TtcPhase? phase;

  final List<String> symptoms;
  final double? weightKg;
  final double? tempC;

  bool get hasAnything =>
      symptoms.isNotEmpty || weightKg != null || tempC != null;
}

/// One sentence the report is entitled to say.
class TtcFinding {
  const TtcFinding({required this.headline, required this.detail});

  /// Short, and always a count or a position.
  final String headline;

  /// The same fact with its context. Never a cause.
  final String detail;
}

/// A whole report for one cycle.
class TtcCycleReport {
  const TtcCycleReport({
    required this.state,
    required this.days,
    required this.findings,
    this.start,
    this.end,
    this.cyclesAvailable = 0,
    this.index = 0,
  });

  final TtcReportState state;
  final List<TtcReportDay> days;
  final List<TtcFinding> findings;

  final DateTime? start;
  final DateTime? end;

  /// How many past cycles she can page back through.
  final int cyclesAvailable;

  /// 0 = the current cycle, 1 = the one before it.
  final int index;

  List<TtcReportDay> get logged =>
      days.where((d) => d.hasAnything).toList();

  List<TtcReportDay> get withWeight =>
      days.where((d) => d.weightKg != null).toList();

  List<TtcReportDay> get withTemp =>
      days.where((d) => d.tempC != null).toList();

  int get loggedCount => logged.length;
}

/// Builds the report for the cycle [index] back from the current one.
///
/// ⚠️ IT DECIDES THE STATE FIRST AND GATHERS DATA SECOND. The tempting shape is
/// to gather everything, then check whether it is enough — which quietly means
/// the clinic-held case computes a set of phase bands it is not allowed to show
/// and relies on the screen remembering not to draw them. Deciding first means
/// the refusal is structural: `phase` is simply null on every day.
TtcCycleReport ttcBuildCycleReport({int index = 0}) {
  final cycle = CycleStore.instance;
  final store = TtcStore.instance;
  final starts = [...cycle.periodStarts]..sort();

  if (starts.isEmpty) {
    return const TtcCycleReport(
        state: TtcReportState.noPeriod, days: [], findings: []);
  }

  // Which cycle. index 0 is the one containing today.
  final pos = starts.length - 1 - index;
  if (pos < 0) {
    return const TtcCycleReport(
        state: TtcReportState.noPeriod, days: [], findings: []);
  }
  final start = _dayOnly(starts[pos]);

  final today = _dayOnly(DateTime.now());
  final bleed = ttcBleedDaysFor(start);
  final nextStart = pos + 1 < starts.length ? _dayOnly(starts[pos + 1]) : null;
  final length = store.today.cycleLength;
  var end = nextStart?.subtract(const Duration(days: 1)) ??
      start.add(Duration(days: length - 1));
  if (end.isAfter(today)) end = today;

  // ---- may we draw phases at all? -----------------------------------------
  const engine = TtcChapterEngine();
  // ⚠️ THE CURRENT CYCLE IS ASKED ABOUT TODAY (2026-09-26, consistency pass).
  // `end` stops at her usual length, so a cycle that has run a fortnight past
  // it was asked about its last "usual" day, where the engine still estimates,
  // and drew phase bands under a hero saying "not enough logged". Today's
  // state is the one every other surface reads (`ttcDayContext`). An earlier
  // cycle is still asked about its own end. Kept for revert:
  //   final state = store.state(on: end);
  //
  // ⚠️ AN EARLIER CYCLE IS DRAWN FROM ITS OWN LENGTH SINCE 2026-09-26 (the
  // user's decision: earlier cycles show their fertile days, looking back).
  // It used to be asked of the engine on its last day, which answers with the
  // CURRENT history's average, so every past cycle was banded as if it had
  // been her usual length. `ttcLookBackOvulationDay` is the one look-back the
  // calendar and the hero read too. Kept for revert:
  //   final state = index == 0 ? store.state() : store.state(on: end);
  //   final ov = engine.estimatedOvulationDay(state);
  //   final clinic = !store.today.behaviour.showsFertilityWindow;
  final ov = index == 0 || nextStart == null
      ? engine.estimatedOvulationDay(store.state())
      : ttcLookBackOvulationDay(start, nextStart);
  // A clinic cycle is refused whether it is the one she is in or an earlier
  // one whose own dates show her clinic ran it (`TtcStore.ownershipOfCycle`).
  //
  // ⚠️ AN EARLIER CYCLE ANSWERS FOR ITS OWN DATES ONLY, SINCE 2026-09-26 (the
  // treatment flow's resolver decision): during a round, the cycles from
  // before treatment keep their look-back window on every surface, this
  // report included. Kept for revert:
  //   final clinic = !store.today.behaviour.showsFertilityWindow ||
  //       (nextStart != null && store.ownershipOfCycle(...) != parentveda);
  final clinic = (index == 0 || nextStart == null)
      ? !store.today.behaviour.showsFertilityWindow
      : store.ownershipOfCycle(start, nextStart: nextStart) !=
          TimingOwnership.parentveda;

  TtcReportState reportState;
  if (clinic) {
    reportState = TtcReportState.clinicHeld;
  } else if (ov == null) {
    reportState = TtcReportState.noEstimate;
  } else {
    reportState = TtcReportState.ready;
  }

  TtcPhase? phaseFor(int cycleDay) {
    if (reportState == TtcReportState.clinicHeld ||
        reportState == TtcReportState.noEstimate ||
        ov == null) {
      return null;
    }
    return ttcPhaseForCycleDay(cycleDay, ov, bleedDays: bleed);
  }

  // ---- gather --------------------------------------------------------------
  final log = TtcLogStore.instance;
  final days = <TtcReportDay>[];
  for (var d = start;
      !d.isAfter(end);
      d = DateTime(d.year, d.month, d.day + 1)) {
    final key = TtcLogStore.dayKey(d);
    final symptoms = log
        .valuesOn(kTtcSymptomTracker, key)
        .where((v) => v.value > 0)
        .map((v) => v.field)
        .toList();
    days.add(TtcReportDay(
      date: d,
      cycleDay: d.difference(start).inDays + 1,
      phase: phaseFor(d.difference(start).inDays + 1),
      symptoms: symptoms,
      weightKg: log.valueFor(kTtcWeightTracker, kTtcWeightField, on: d)?.value,
      tempC: log.valueFor(kTtcTempTracker, kTtcTempField, on: d)?.value,
    ));
  }

  final loggedDays = days.where((d) => d.hasAnything).length;
  if (reportState == TtcReportState.ready && loggedDays < 3) {
    reportState = TtcReportState.thin;
  }

  return TtcCycleReport(
    state: reportState,
    days: days,
    findings: _findings(days, reportState),
    start: start,
    end: end,
    cyclesAvailable: starts.length,
    index: index,
  );
}

/// The sentences the data supports — and silence when it supports none.
///
/// ⚠️ REWRITTEN AFTER SHIPPING ARITHMETIC AS INSIGHT. The first version opened
/// with "You logged on 1 of 1 days", which is not a finding, it is a division
/// the reader could have done herself and did not ask for. The objection was
/// exact: *"you logged on one of one days. So if I do it on day two, then what?
/// Why are you doing such a complex and dumb user interface?"*
///
/// Two rules came out of that and both are load-bearing:
///
///   1. **A finding must say something the chart above it cannot.** A count of
///      logged days is already visible as dots on the strip. Restating it in a
///      sentence is not a second piece of information, it is the same one
///      costing another card.
///   2. **Below a week, say nothing at all.** Three days cannot show where in a
///      cycle something falls, and a sentence that pretends otherwise is worse
///      than an empty section — it teaches her the report is padding.
///
/// ⚠️ AND EVERY ONE IS STILL A COUNT OR A POSITION. Never a cause, never a
/// projection. `test/ttc_cycle_report_test.dart` scans the rendered text for
/// "because", "suggests", "indicates" and "chance" precisely because that line
/// is easy to cross under pressure to sound useful.
List<TtcFinding> _findings(List<TtcReportDay> days, TtcReportState state) {
  if (state == TtcReportState.noPeriod) return const [];

  final logged = days.where((d) => d.hasAnything).toList();

  // ⚠️ THE FLOOR. Seven days is roughly where "most of them fell in X" stops
  // being an accident of when she happened to open the app.
  if (logged.length < 7) return const [];

  final out = <TtcFinding>[];

  // ---- which symptoms came up, and roughly where -------------------------
  final counts = <String, int>{};
  final byPhase = <String, Map<TtcPhase, int>>{};
  for (final d in logged) {
    for (final sym in d.symptoms) {
      counts[sym] = (counts[sym] ?? 0) + 1;
      if (d.phase != null) {
        byPhase.putIfAbsent(sym, () => {});
        byPhase[sym]![d.phase!] = (byPhase[sym]![d.phase!] ?? 0) + 1;
      }
    }
  }

  final ranked = counts.entries.where((e) => e.value >= 3).toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (final e in ranked.take(3)) {
    final symptom = ttcSymptomById(e.key);
    if (symptom == null) continue;

    final phases = byPhase[e.key];
    if (phases == null || phases.isEmpty) continue;

    final top = phases.entries.reduce((a, b) => a.value >= b.value ? a : b);

    // ⚠️ ONLY WHEN IT ACTUALLY CLUSTERED. If the days are spread evenly across
    // the cycle there is nothing to say, and saying "recorded on 4 days" alone
    // is the arithmetic this rewrite removed.
    if (top.value * 2 <= e.value) continue;

    out.add(TtcFinding(
      headline: symptom.label,
      detail: '${e.value} days this cycle, mostly in '
          '${top.key.label.toLowerCase()}.',
    ));
  }

  // ---- weight, as a range -------------------------------------------------
  final weights = days.map((d) => d.weightKg).whereType<double>().toList();
  if (weights.length >= 4) {
    final lo = weights.reduce((a, b) => a < b ? a : b);
    final hi = weights.reduce((a, b) => a > b ? a : b);
    final span = hi - lo;
    // Under about half a kilo is scale noise, not a movement worth a sentence.
    if (span >= 0.5) {
      out.add(TtcFinding(
        headline: 'Weight moved ${span.toStringAsFixed(1)} kg',
        detail: '${lo.toStringAsFixed(1)} to ${hi.toStringAsFixed(1)} kg '
            'across the cycle.',
      ));
    }
  }

  return out;
}

/// How this cycle's length compares with her usual.
///
/// ⚠️ ONLY WITH REAL HISTORY BEHIND IT, and only as a comparison — never as a
/// verdict. "Two days shorter than your usual 29" is a fact about her own
/// record. "Your cycles are irregular" is a clinical judgement and is not ours
/// to make.
TtcFinding? ttcCycleLengthNote() {
  final lengths = CycleStore.instance.cycleLengths;
  if (lengths.length < 3) return null;

  final recent = lengths.length <= 6
      ? lengths
      : lengths.sublist(lengths.length - 6);
  final usual =
      (recent.reduce((a, b) => a + b) / recent.length).round();
  final last = lengths.last;
  final diff = last - usual;

  if (diff.abs() <= 1) {
    return TtcFinding(
      headline: '$last days, about your usual',
      detail: 'Your recent cycles have averaged $usual days.',
    );
  }
  return TtcFinding(
    headline: '$last days, ${diff.abs()} '
        '${diff.abs() == 1 ? 'day' : 'days'} '
        '${diff > 0 ? 'longer' : 'shorter'} than usual',
    detail: 'Your recent cycles have averaged $usual days. Cycles vary, and '
        'a few days either way is normal.',
  );
}

// =============================================================================
//  The four stretches, as a whole cycle
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS A DIFFERENT QUESTION FROM [TtcCycleReport.days], AND CONFLATING
//  THE TWO COST A ROUND TRIP. The day list is *what she logged*, so it stops at
//  today — you cannot plot a weight nobody has stood on a scale for. The four
//  stretches are *the shape of the cycle*, which is known in full the moment a
//  period is logged, because it is arithmetic on two numbers the engine already
//  has: the estimated ovulation day and the cycle length.
//
//  So the last stretch being in the future is not a shortage of data. Today's
//  date does exactly one job here — it decides which stretch carries "You are
//  here". Everything else is the same before and after it happens.
//
//  ⚠️ IT IS A TIMING ESTIMATE AND NEVER A PROBABILITY. Dates and lengths only.
//  Nothing in [TtcPhaseSpan] may grow a field that reads as a chance, a score
//  or a ranking of one stretch against another — CLAUDE.md's clinical
//  invariants, and the same rule stated at the head of `ttc_fertile_window.dart`
//  whose window constants this shares.
//
//  ⚠️ AND IT REFUSES ON THE SAME TERMS THE REPORT DOES. Empty when a clinic
//  holds the cycle or the engine will not estimate, so a caller cannot draw
//  bands we are not entitled to draw. Structural, not a flag to remember.
// =============================================================================

/// Where a stretch sits relative to today.
enum TtcSpanStatus { done, here, ahead }

extension TtcSpanStatusCopy on TtcSpanStatus {
  /// The word on the meta line, after the dates and the length.
  String get label => switch (this) {
        TtcSpanStatus.done => 'done',
        TtcSpanStatus.here => 'now',
        TtcSpanStatus.ahead => 'ahead',
      };
}

/// One stretch of a cycle, with real dates at both ends.
class TtcPhaseSpan {
  const TtcPhaseSpan({
    required this.phase,
    required this.firstDay,
    required this.lastDay,
    required this.firstCycleDay,
    required this.lastCycleDay,
    required this.status,
    this.dayInto,
  });

  final TtcPhase phase;
  final DateTime firstDay;
  final DateTime lastDay;
  final int firstCycleDay;
  final int lastCycleDay;
  final TtcSpanStatus status;

  /// 1-based position of today inside this stretch. Null unless [status] is
  /// [TtcSpanStatus.here] — "day 3 of 7" is only meaningful while she is in it.
  final int? dayInto;

  int get days => lastCycleDay - firstCycleDay + 1;
}

/// The four stretches of the cycle [index] back from the current one.
///
/// Empty when phases are not ours to draw. Fewer than four is a legitimate
/// answer, not a bug: on a short cycle the assumed bleed days can swallow
/// "Before your window" entirely, and drawing a stretch of zero days to keep
/// the count at four would be inventing one.
List<TtcPhaseSpan> ttcCyclePhaseSpans({int index = 0}) {
  final cycle = CycleStore.instance;
  final store = TtcStore.instance;
  final starts = [...cycle.periodStarts]..sort();
  if (starts.isEmpty) return const [];

  final pos = starts.length - 1 - index;
  if (pos < 0) return const [];
  final start = _dayOnly(starts[pos]);

  // ⚠️ THE SAME REFUSALS AS THE REPORT, READ THE SAME WAY. Asked at the END of
  // the cycle being drawn rather than today, so paging back to a cycle that was
  // clinic-run answers about that cycle rather than about this morning.
  final nextStart = pos + 1 < starts.length ? _dayOnly(starts[pos + 1]) : null;
  final length = nextStart != null
      ? nextStart.difference(start).inDays
      : store.today.cycleLength;
  if (length < 1) return const [];

  // Kept for revert: `last`, which only the old ov line below read.
  //   final last = start.add(Duration(days: length - 1));
  const engine = TtcChapterEngine();
  // The current cycle is asked about today, like the report above and every
  // other surface (2026-09-26). An earlier cycle is drawn from its own length,
  // looking back, with the report's own look-back (2026-09-26, the user's
  // decision). Kept for revert:
  //   final ov = engine.estimatedOvulationDay(store.state(on: last));
  //   final ov = engine.estimatedOvulationDay(
  //       index == 0 ? store.state() : store.state(on: last));
  final ov = index == 0 || nextStart == null
      ? engine.estimatedOvulationDay(store.state())
      : ttcLookBackOvulationDay(start, nextStart);
  if (ov == null) return const [];
  // The cycle she is in only (2026-09-26): an earlier cycle's own clinic
  // dates already refused its look-back above. Kept for revert:
  //   if (!store.today.behaviour.showsFertilityWindow) return const [];
  if ((index == 0 || nextStart == null) &&
      !store.today.behaviour.showsFertilityWindow) {
    return const [];
  }

  // Where today falls. Outside the cycle entirely is the ordinary case for a
  // cycle she has paged back to.
  final todayCycleDay = _dayOnly(DateTime.now()).difference(start).inDays + 1;

  // ---- consecutive runs of one phase -------------------------------------
  final out = <TtcPhaseSpan>[];
  final bleed = ttcBleedDaysFor(start);
  var runStart = 1;
  var runPhase = ttcPhaseForCycleDay(1, ov, bleedDays: bleed);

  void close(int runEnd) {
    final TtcSpanStatus status;
    int? into;
    if (todayCycleDay < runStart) {
      status = TtcSpanStatus.ahead;
    } else if (todayCycleDay > runEnd) {
      status = TtcSpanStatus.done;
    } else {
      status = TtcSpanStatus.here;
      into = todayCycleDay - runStart + 1;
    }
    out.add(TtcPhaseSpan(
      phase: runPhase,
      firstDay: start.add(Duration(days: runStart - 1)),
      lastDay: start.add(Duration(days: runEnd - 1)),
      firstCycleDay: runStart,
      lastCycleDay: runEnd,
      status: status,
      dayInto: into,
    ));
  }

  for (var day = 2; day <= length; day++) {
    final phase = ttcPhaseForCycleDay(day, ov, bleedDays: bleed);
    if (phase == runPhase) continue;
    close(day - 1);
    runStart = day;
    runPhase = phase;
  }
  close(length);

  return out;
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
