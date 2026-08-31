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
  final nextStart = pos + 1 < starts.length ? _dayOnly(starts[pos + 1]) : null;
  final length = store.today.cycleLength;
  var end = nextStart?.subtract(const Duration(days: 1)) ??
      start.add(Duration(days: length - 1));
  if (end.isAfter(today)) end = today;

  // ---- may we draw phases at all? -----------------------------------------
  const engine = TtcChapterEngine();
  final state = store.state(on: end);
  final ov = engine.estimatedOvulationDay(state);
  final clinic = !store.today.behaviour.showsFertilityWindow;

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
        reportState == TtcReportState.noEstimate) {
      return null;
    }
    // Five days of bleeding is the working assumption for banding only. It is
    // never shown as a number and never used by the engine.
    if (cycleDay <= 5) return TtcPhase.period;
    if (ov != null && cycleDay >= ov - 5 && cycleDay <= ov + 1) {
      return TtcPhase.fertileWindow;
    }
    if (ov != null && cycleDay < ov - 5) return TtcPhase.beforeWindow;
    return TtcPhase.afterWindow;
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
        'a few days either way is ordinary.',
  );
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
