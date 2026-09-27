// =============================================================================
//  TTC - which reads the home offers, by where she is in her cycle
// -----------------------------------------------------------------------------
//  The home's read rail (`_ReadRail` in `ttc_home_v3.dart`) takes four reads
//  from the whole library by day of the year, so "When to take a test" can sit
//  on a period day. This is the phase-aware picker for it, pure and with no
//  widget, so the home can swap its four picks for these without anything else
//  changing. Wiring it is the home's job, not this file's.
//
//  A table in code, not a tag on every read: the reads are long-lived content
//  and the phase choice is a presentation rule, so it lives in one place that
//  a reviewer can read top to bottom.
// =============================================================================

import 'ttc_daily_data.dart' show ttcDayIndex;
import 'ttc_phase.dart';
import 'ttc_reads_data.dart' show ttcReadById;

/// The reads that fit each stretch, best first. Every id must exist in
/// `kTtcReads` (`test/ttc_phase_daily_test.dart` holds it); one that is
/// removed later is skipped at pick time rather than shown as a dead card.
const Map<TtcDayPhase, List<String>> kTtcPhaseReadIds = {
  // Period days: the hard-days reads, and the ones about the cycle itself.
  TtcDayPhase.period: [
    'ttc_read_period_came',
    'ttc_read_month_after_month',
    'ttc_read_period_pain',
    'ttc_read_normal_cycle',
    'ttc_read_bleeding_kinds',
    'ttc_read_heavy_flow',
    'ttc_read_trying_takes_over',
  ],
  // After the period, before the window: getting ready, and knowing the cycle.
  TtcDayPhase.beforeWindow: [
    'ttc_read_how_conception_works',
    'ttc_read_normal_cycle',
    'ttc_read_three_months_before',
    'ttc_read_folic_acid',
    'ttc_read_discharge_guide',
    'ttc_read_ovulation_kits',
    'ttc_read_preconception_tests',
    'ttc_read_supplement_timing',
  ],
  // The window: timing, and keeping it close rather than clinical.
  TtcDayPhase.window: [
    'ttc_read_timing_myths',
    'ttc_read_how_conception_works',
    'ttc_read_sex_homework',
    'ttc_read_ovulation_kits',
    'ttc_read_keeping_close',
    'ttc_read_lubricants',
    'ttc_read_ovulation_pain',
  ],
  // The two-week wait: what is happening, and when a test means something.
  TtcDayPhase.waiting: [
    'ttc_read_two_week_wait',
    'ttc_read_when_to_test',
    'ttc_read_early_signs',
    'ttc_read_implantation_bleeding',
    'ttc_read_how_to_test',
    'ttc_read_sex_after_window',
  ],
  // Late: testing, and what a late negative means.
  TtcDayPhase.late: [
    'ttc_read_how_to_test',
    'ttc_read_late_negative',
    'ttc_read_late_period',
    'ttc_read_faint_line',
    'ttc_read_feeling_pregnant',
    'ttc_read_when_to_test',
  ],
  // Unknown or clinic-run: a broad set that is true on any day.
  TtcDayPhase.any: [
    'ttc_read_how_conception_works',
    'ttc_read_timing_myths',
    'ttc_read_three_months_before',
    'ttc_read_folic_acid',
    'ttc_read_stress_fertility',
    'ttc_read_sleep_trying',
    'ttc_read_whose_side',
    'ttc_read_semen_analysis',
    'ttc_read_how_long_it_takes',
    'ttc_read_when_to_seek_help',
    'ttc_read_meal_plan_week',
    'ttc_read_family_asking',
  ],
};

/// Up to [count] read ids for [phase] on [day].
///
/// The phase's own reads first, rotated by [day] so the rail is stable all day
/// and turns over tomorrow; then the `any` set, rotated the same way, if the
/// phase has fewer than [count]. No id twice, and never an id that does not
/// resolve to a read. Pure apart from reading the (const) library.
List<String> ttcReadIdsForPhase(
  TtcDayPhase phase,
  DateTime day, {
  int count = 4,
}) {
  if (count <= 0) return const [];
  final start = ttcDayIndex(day);

  List<String> rotated(List<String> ids) => [
        for (var i = 0; i < ids.length; i++) ids[(start + i) % ids.length],
      ];

  final own = kTtcPhaseReadIds[phase] ?? const <String>[];
  final broad = phase == TtcDayPhase.any
      ? const <String>[]
      : kTtcPhaseReadIds[TtcDayPhase.any] ?? const <String>[];

  final out = <String>[];
  for (final id in [...rotated(own), ...rotated(broad)]) {
    if (out.length >= count) break;
    if (out.contains(id) || ttcReadById(id) == null) continue;
    out.add(id);
  }
  return out;
}
