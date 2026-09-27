// =============================================================================
//  The logger's gap work — the words and the small rules it added
// -----------------------------------------------------------------------------
//  From the TTC gap analysis, "Behind — Logging" (2026-09-26):
//
//    1. Four feelings that belong to trying, and one gentle line when the
//       heavy three show up three days running.
//    2. A way from "Faint line" to the read that explains a faint line.
//    3. Kegels and breathing in "The rest of the day" (ids in
//       `ttc_symptom_data.dart`).
//    4. The morning temperature as one whole cycle, not fourteen dots.
//
//  ⚠️ THE COPY LIVES HERE, NOT IN `ttc_strings.dart`. That file was being
//  rewritten by another helper at the same time, and two hands in one file of
//  1,500 lines is how a merge eats a sentence. New copy is English only
//  (CLAUDE.md, "New work is English"), so it needs no `_p` pair anyway.
//
//  ⚠️ NOTHING HERE INTERPRETS. The three-days line notices a pattern in what
//  she TAPPED, the way a friend would say "you've mentioned this a few times",
//  and offers a read. It never names a condition and never counts out loud.
//  The chart shades days we are already allowed to shade elsewhere, and draws
//  an average of her own readings. It never marks "ovulation happened here".
// =============================================================================

import 'ttc_cycle_report.dart';
import 'ttc_day_context.dart';
// Kept for revert: the window came from `ttcFertileWindowNow`.
// import 'ttc_fertile_window.dart';
import 'ttc_log_store.dart';
import 'ttc_store.dart';
import 'ttc_symptom_data.dart';

// ---- 1. the feelings that belong to trying -----------------------------------

/// The three feelings that, logged three days running, bring up the gentle
/// line. "Hopeful" is deliberately not one of them.
///
/// ⚠️ IDENTITIES. These are the persisted symptom ids, so they must match
/// `kTtcSymptomGroups` exactly; `test/ttc_logging_gap_test.dart` holds that.
const Set<String> kTtcHardThoughtIds = {
  'guilty',
  'cant_stop_thinking',
  'hard_on_myself',
};

/// How many days in a row before the line shows.
const int kTtcHardThoughtDays = 3;

/// True when at least one of [kTtcHardThoughtIds] was logged on [day] and on
/// each of the two days before it.
///
/// ⚠️ ENDING ON THE DAY SHE IS LOOKING AT, not on today. The logger can step
/// back through days, and a line that appears on today's page because of what
/// she logged last week would be a line about a different day.
bool ttcHardThoughtsRunOn(DateTime day, {TtcLogStore? store}) {
  final log = store ?? TtcLogStore.instance;
  for (var i = 0; i < kTtcHardThoughtDays; i++) {
    final d = DateTime(day.year, day.month, day.day - i);
    final any = log
        .valuesOn(kTtcSymptomTracker, TtcLogStore.dayKey(d))
        .any((v) => v.value > 0 && kTtcHardThoughtIds.contains(v.field));
    if (!any) return false;
  }
  return true;
}

/// The line, and where it goes.
const String kTtcHardThoughtsLine =
    'Trying can take over your thoughts. This might help.';

/// The Hard days read about trying taking over. Opened only when it resolves
/// through `ttcReadById`; until then the Mind & body door is the fallback.
const String kTtcHardThoughtsReadId = 'ttc_read_trying_takes_over';

/// The Mind & body door, the fallback when the read is not registered.
const String kTtcMindBodyBracket = 'ttc_mind_body';

// ---- 2. the faint line ------------------------------------------------------

/// Under the pregnancy test card.
const String kTtcFaintLineLink = 'What a faint line means';

/// The read in `lib/ttc/reads/ttc_reads_waiting.dart`.
const String kTtcFaintLineReadId = 'ttc_read_faint_line';

/// The card the link sits under. An identity, like every group id.
const String kTtcPregnancyTestGroup = 'pregnancy_test';

// ---- 4. the morning temperature chart ---------------------------------------

const String kTtcTempChartTitle = 'Your morning temperature';
const String kTtcTempChartAxis = 'Cycle day';
const String kTtcTempLegendPeriod = 'Period';
const String kTtcTempLegendFertile = 'Fertile days';
// G3 (review, 2026-09-26): the day is our estimate, so the legend says so
// ("prediction language only where we predict", CLAUDE.md). Kept for revert:
//   'Your average before ovulation'
const String kTtcTempLegendAverage =
    'Your average before the estimated ovulation day';

/// The small line when she taps a reading (G2): "Day 14 · 36.52 °C".
String ttcTempTooltip(int cycleDay, double celsius) =>
    'Day $cycleDay · ${celsius.toStringAsFixed(2)} °C';

/// Under the chart's key, the one word for the thin line at today (G2).
const String kTtcTempLegendToday = 'Today';

/// The one line under the chart. Education, not a reading of her chart.
const String kTtcTempChartNote =
    'A lasting rise of about 0.2 °C usually means ovulation has already '
    "happened. It confirms, it doesn't predict.";

/// No period logged, so there is no cycle to lay the readings on.
const String kTtcTempChartNoCycle =
    'Log the first day of your period, and your morning temperatures will '
    'line up with your cycle here.';

/// A cycle, but no readings in it yet.
const String kTtcTempChartNoReadings =
    'Take your temperature first thing, before you get up. Each morning '
    'adds a dot here.';

/// A clinic is guiding the timing, so we do not shade days.
const String kTtcTempChartClinic =
    "Your clinic is guiding this cycle, so we show your readings without "
    'marking any days.';

/// The engine will not estimate, so we do not shade days.
const String kTtcTempChartNoEstimate =
    "We can't mark your fertile days yet, so these are your readings on "
    'their own.';

/// The small card in the logger points down to the chart.
const String kTtcTempChartBelow = 'Your cycle chart is below.';

/// One reading, placed on its cycle day.
class TtcTempPoint {
  const TtcTempPoint(this.cycleDay, this.celsius);
  final int cycleDay;
  final double celsius;
}

/// Everything the chart draws, decided away from any widget.
///
/// ⚠️ THE REFUSAL IS STRUCTURAL, THE SAME WAY THE REPORT'S IS. When a clinic
/// holds the timing, or the engine will not estimate, [fertileFrom] and
/// [periodTo] are null and the painter has nothing to shade. It does not rely
/// on the screen remembering not to.
class TtcTempChart {
  const TtcTempChart({
    required this.state,
    required this.days,
    required this.points,
    this.periodTo,
    this.fertileFrom,
    this.fertileTo,
    this.ovulationDay,
    this.averageBefore,
    this.todayDay,
  });

  /// Which message goes with the chart. Reuses the report's closed set.
  final TtcReportState state;

  /// How many cycle days the x axis spans. Zero when there is no cycle.
  final int days;

  /// Her readings in this cycle, in day order.
  final List<TtcTempPoint> points;

  /// Last day of the period band (the band starts on day 1). Null = no bands.
  final int? periodTo;

  /// The fertile band, inclusive. Null = no band.
  final int? fertileFrom;
  final int? fertileTo;

  /// The estimated ovulation day the average is cut at. Never drawn.
  final int? ovulationDay;

  /// The mean of her readings before [ovulationDay]. Null below three.
  final double? averageBefore;

  /// Today's cycle day, for the thin line at today (G2). Null when the cycle
  /// on the chart is not the one she is in.
  final int? todayDay;

  bool get hasCycle => days > 0;
  bool get shaded => periodTo != null;
}

/// Readings needed before the average line is drawn. Two points make a
/// "line" out of a coincidence.
const int kTtcTempAverageMinReadings = 3;

/// The current cycle's temperature chart.
///
/// ⚠️ THE WHOLE CYCLE, INCLUDING THE DAYS THAT HAVE NOT HAPPENED. The x axis
/// runs to her usual cycle length (or further, if this cycle already has), so
/// the fertile band shows where it falls even before she reaches it. The dots
/// stop at today, because only today has happened.
TtcTempChart ttcBuildTempChart() {
  final report = ttcBuildCycleReport();
  final start = report.start;
  if (report.state == TtcReportState.noPeriod || start == null) {
    return const TtcTempChart(
        state: TtcReportState.noPeriod, days: 0, points: []);
  }

  final points = [
    for (final d in report.days)
      if (d.tempC != null) TtcTempPoint(d.cycleDay, d.tempC!),
  ];

  final usual = TtcStore.instance.today.cycleLength;
  final days = report.days.length > usual ? report.days.length : usual;

  // The report's days run from the period to today, so the last one is today
  // when the cycle on the chart is the current one.
  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);
  final int? todayDay =
      report.days.isNotEmpty && report.days.last.date == todayDate
          ? report.days.last.cycleDay
          : null;

  // ---- may we shade? ------------------------------------------------------
  //
  // Only on the two states where the report itself draws phases. The window
  // then comes from `ttcFertileWindowNow`, which refuses on its own when a
  // clinic owns the timing; both have to agree before anything is shaded.
  final phasesAllowed = report.state == TtcReportState.ready ||
      report.state == TtcReportState.thin;
  //
  // ⚠️ FROM `ttcDayContext` SINCE 2026-09-26, the resolver the hero, the
  // calendar and the cards read, so the band on this chart is the window the
  // hero names. Kept for revert:
  //   final window = phasesAllowed ? ttcFertileWindowNow() : null;
  final ctx = ttcDayContext(DateTime.now());
  final opensDay = phasesAllowed ? ctx.windowOpensCycleDay : null;
  final closesDay = phasesAllowed ? ctx.windowClosesCycleDay : null;
  if (opensDay == null || closesDay == null || !ctx.isCurrentCycle) {
    return TtcTempChart(
        state: report.state == TtcReportState.clinicHeld
            ? TtcReportState.clinicHeld
            : (phasesAllowed ? TtcReportState.noEstimate : report.state),
        days: days,
        points: points,
        todayDay: todayDay);
  }

  // ⚠️ PERIOD WINS AN OVERLAP, the same rule as `ttcPhaseForCycleDay`. On a
  // short cycle the bleed days and the window can touch, and a day she was
  // bleeding must never be painted fertile.
  final bleed = ttcBleedDaysFor(start);
  final periodTo = bleed.clamp(1, days);
  final from = opensDay > periodTo ? opensDay : periodTo + 1;
  final to = closesDay.clamp(1, days);
  final ov = ctx.ovulationDay!;

  final before = [for (final p in points) if (p.cycleDay < ov) p.celsius];
  final avg = before.length >= kTtcTempAverageMinReadings
      ? before.reduce((a, b) => a + b) / before.length
      : null;

  return TtcTempChart(
    state: report.state,
    days: days,
    points: points,
    periodTo: periodTo,
    fertileFrom: from <= to ? from : null,
    fertileTo: from <= to ? to : null,
    ovulationDay: ov,
    averageBefore: avg,
    todayDay: todayDay,
  );
}
