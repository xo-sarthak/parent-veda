// =============================================================================
//  TTC - Ovulation tests (the Tools tile "Ovulation companion")
// -----------------------------------------------------------------------------
//  Rebuilt 2026-09-27 in the tool rebuild. The user, walking build 13: "old
//  tools in new clothes… poor functionality… is it a real tool or a read?"
//
//  WHAT IT WAS. `TtcOvulationScreen` (kept for revert in
//  `ttc_cycle_screens.dart` as `TtcOvulationScreenClassic`): a V1 card with
//  our estimate, and two rows, "Positive ovulation strip" and "Temperature
//  rise seen", each with a "Record it" button that kept ONE day per cycle.
//  Neither a log nor a read:
//    * She could not log a strip a day. Most women test once a day for a
//      week; the screen kept one date and forgot every negative.
//    * The daily log's "Ovulation test" card (`ovulation_test` in
//      `ttc_symptom_data.dart`) logged strips too, under other keys, and the
//      two never met: a positive logged there did not move her fertile days,
//      and nothing logged there showed here.
//    * It never said when to start testing, the most common mistake the gap
//      analysis names (P1, "Ovulation kits: do they help?").
//
//  WHAT IT IS NOW: A REAL TOOL, the strip log fertility apps build (a strip a
//  day, a mark per cycle day, the first positive moving the estimate):
//    * A strip of this cycle's days with a mark on each test, and today's
//      (or any day's) result in one tap. The SAME keys the daily log writes
//      (`symptoms/ov_positive|ov_negative|ov_none/<day>`), so one truth
//      whichever screen she logs on.
//    * The first positive of the cycle is what moves her fertile days
//      (`CycleStore.logLhPositive`, the call "Record it" made). It is never
//      silent: the change is said in a notice with Undo, and a positive
//      logged elsewhere is OFFERED here ("Use it for your fertile days?"),
//      never adopted behind her back (the user's rule: tell her before
//      anything changes).
//    * When to start testing, from her own estimate, using the rule the
//      reads already teach ("about three days before the earliest day you
//      might ovulate"; 17 from a 28-day cycle is day 11). Only on a cycle we
//      estimate with some confidence and before she has a positive.
//    * The temperature rise stays as the second sign, with Change and Remove.
//
//  Kept exactly: who may log (a fully medicated cycle logs nothing, a
//  clinic-guided one keeps logging, see `logsBodySignals`), the clinic card,
//  every estimate the engine makes and refuses, and the two explanations.
//
//  Mobbin (2026-09-27):
//    Clue log, a day strip above the day's answers
//      https://mobbin.com/screens/061215bd-34ed-4f9d-909e-e4481b6faafb
//    Bevel Journal, a week strip with a mark per logged day
//      https://mobbin.com/screens/be4c91e4-d0a8-4840-9654-6834039006b0
//    Flo "BBT and ovulation", a cycle's days along the bottom with the
//    ovulation marks on them
//      https://mobbin.com/screens/0fd74099-e552-42ef-a439-b5bf63a1cb3d
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_reads_data.dart' show ttcReadById;
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_symptom_data.dart' show kTtcSymptomTracker;
import '../products/pv_store_chrome.dart' show pvSnack;
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_focus_screen.dart' show openTtcArticle;
import 'ttc_round_strings.dart' show ttcRoundDate;
import 'ttc_strings.dart';
import 'ttc_today_screen.dart' show logTtcPeriod;
import 'ttc_tool_chrome.dart';
import 'ttc_tools_screen.dart' show ttcToolById;
import 'ttc_treatment_screen.dart' show TtcTreatmentEntryCard;

// ---- the keys: the daily log's own, never a second truth ----------------------

const String kTtcOvPositive = 'ov_positive';
const String kTtcOvNegative = 'ov_negative';
const String kTtcOvNone = 'ov_none';
const List<String> _kOvIds = [kTtcOvPositive, kTtcOvNegative, kTtcOvNone];

/// The hue of the tool's group on Tools ("Your body").
const double kTtcOvHue = 172;

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// The strip result logged for [day], by the daily log or here. Null when
/// nothing is logged.
String? ttcOvResultOn(DateTime day) {
  final key = TtcLogStore.dayKey(day);
  for (final v in TtcLogStore.instance.valuesOn(kTtcSymptomTracker, key)) {
    if (v.value > 0 && _kOvIds.contains(v.field)) return v.field;
  }
  return null;
}

/// Sets the result for [day]; null clears it. Single-choice, as the daily
/// log's card is: the other two are cleared first.
void ttcOvSetResult(DateTime day, String? id) {
  final log = TtcLogStore.instance;
  for (final other in _kOvIds) {
    if (other != id &&
        log.valueFor(kTtcSymptomTracker, other, on: day) != null) {
      log.clear(kTtcSymptomTracker, other, on: day);
    }
  }
  if (id != null) log.log(kTtcSymptomTracker, id, 1, on: day);
}

/// The first cycle day with a positive strip logged, for the cycle that began
/// on [start], up to [today].
int? ttcOvFirstPositiveDay(DateTime start, DateTime today) {
  final s = _dayOnly(start), t = _dayOnly(today);
  for (var d = s; !d.isAfter(t); d = d.add(const Duration(days: 1))) {
    if (ttcOvResultOn(d) == kTtcOvPositive) {
      return d.difference(s).inDays + 1;
    }
  }
  return null;
}

/// The cycle day to start testing, from an ovulation estimate: three days
/// before, the rule the reads teach ("Which day should I start testing?" in
/// `ttc_read_ovulation_kits`). Null below day 1.
int? ttcOvStartTestingDay(int? ovulationDay) {
  if (ovulationDay == null) return null;
  final d = ovulationDay - 3;
  return d < 1 ? null : d;
}

// ---- words --------------------------------------------------------------------

const String kTtcOvTitle = 'Your ovulation tests.';
const String kTtcOvIntro =
    'Log each ovulation test strip here. A positive means your body will '
    'likely release an egg (ovulate) in the next day or two.';
const String kTtcOvTestsHeading = 'Your tests this cycle';
const String kTtcOvLegend = 'Filled dot: positive. Ring: negative.';
const String kTtcOvNegativeLabel = 'Negative';
const String kTtcOvPositiveLabel = 'Positive';
const String kTtcOvMoved = 'Your fertile days now follow this test.';
const String kTtcOvBack = 'Your fertile days go back to our calendar estimate.';
const String kTtcOvTempHeading = 'Temperature rise';
const String kTtcOvTempAdd = 'Add the day it rose';
const String kTtcOvNoPeriod =
    'Log the first day of your last period first. Then each test sits on '
    'the right day of your cycle.';
const String kTtcOvLogPeriod = 'Log my period';
const String kTtcOvMedicated =
    "Your clinic's medicines time this cycle, so there are no strips to log "
    'here. Your round has your dates.';

String ttcOvResultLine(DateTime day, int cycleDay, String? result) {
  final when = '${ttcRoundDate(day)}, day $cycleDay of your cycle';
  return switch (result) {
    kTtcOvPositive => '$when: positive.',
    kTtcOvNegative => '$when: negative.',
    kTtcOvNone => "$when: you noted you didn't test.",
    _ => '$when: nothing logged yet. Tap a result.',
  };
}

// =============================================================================

class TtcOvulationTestsScreen extends StatefulWidget {
  const TtcOvulationTestsScreen({super.key});

  @override
  State<TtcOvulationTestsScreen> createState() =>
      _TtcOvulationTestsScreenState();
}

class _TtcOvulationTestsScreenState extends State<TtcOvulationTestsScreen> {
  DateTime _day = _dayOnly(DateTime.now());

  // ---- writes, each one said out loud ---------------------------------------

  void _setResult(DateTime start, DateTime day, String? result) {
    final cycle = CycleStore.instance;
    final today = _dayOnly(DateTime.now());
    final cd = day.difference(start).inDays + 1;
    final prevChip = ttcOvResultOn(day);
    final prevLh = cycle.lhPositiveDay;
    final wasPositive = prevChip == kTtcOvPositive || prevLh == cd;

    ttcOvSetResult(day, result);

    void undo() {
      ttcOvSetResult(day, prevChip);
      cycle.logLhPositive(prevLh);
    }

    if (result == kTtcOvPositive) {
      if (prevLh == null || cd < prevLh) {
        cycle.logLhPositive(cd);
        pvSnack(
          context,
          kTtcOvMoved,
          icon: Icons.check_rounded,
          lift: 24,
          action: 'Undo',
          onAction: undo,
        );
      }
      return;
    }
    if (wasPositive && prevLh == cd) {
      final next = ttcOvFirstPositiveDay(start, today);
      cycle.logLhPositive(next);
      pvSnack(
        context,
        next == null
            ? kTtcOvBack
            : 'Your fertile days now follow your positive on day $next.',
        icon: Icons.check_rounded,
        lift: 24,
        action: 'Undo',
        onAction: undo,
      );
    }
  }

  void _adopt(int cd) {
    final cycle = CycleStore.instance;
    final prev = cycle.lhPositiveDay;
    cycle.logLhPositive(cd);
    pvSnack(
      context,
      kTtcOvMoved,
      icon: Icons.check_rounded,
      lift: 24,
      action: 'Undo',
      onAction: () => cycle.logLhPositive(prev),
    );
  }

  Future<void> _pickTempDay(int currentDay, TtcS t) async {
    final options = <int>[
      for (var back = 0; back < 4; back++)
        if (currentDay - back >= 1) currentDay - back,
    ];
    final p = V2PaletteStore.instance.current;
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      routeSettings: const RouteSettings(name: 'ttc/ovulation/temp_day'),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Which morning did it go up and stay up?',
                style: pvFraunces(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: p.ink1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Today or one of the last few days.',
                style: pvManrope(fontSize: 13, color: p.ink2),
              ),
              const SizedBox(height: 14),
              TtcToolOptions(
                p: p,
                hue: kTtcOvHue,
                items: [
                  for (final d in options)
                    TtcToolOption(
                      label: d == currentDay ? 'Today' : 'Day $d',
                      on: false,
                      onTap: () => Navigator.of(ctx).pop(d),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    CycleStore.instance.logTemperatureShift(picked);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TtcStore.instance,
        CycleStore.instance,
        TtcLogStore.instance,
        TtcLang.instance,
      ]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final p = V2PaletteStore.instance.current;
        final today = TtcStore.instance.today;
        final cycle = CycleStore.instance;
        final start = cycle.lastPeriodStart == null
            ? null
            : _dayOnly(cycle.lastPeriodStart!);
        final now = _dayOnly(DateTime.now());
        final logs = today.behaviour.logsBodySignals;

        return TtcToolScaffold(
          hue: kTtcOvHue,
          eyebrow: ttcToolById('ovulation')?.name(hi) ?? t.ovulationCompanion,
          title: kTtcOvTitle,
          intro: kTtcOvIntro,
          children: [
            const SizedBox(height: 22),

            // A clinic-run cycle: the clinic card, as before.
            if (today.clinicInvolved) ...[
              ttcToolPad(TtcTreatmentEntryCard(t: t)),
              const SizedBox(height: 18),
            ],
            if (!logs) ...[
              ttcToolPad(
                Text(
                  kTtcOvMedicated,
                  key: const ValueKey('ttc_ov_medicated'),
                  style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2),
                ),
              ),
              const SizedBox(height: 18),
            ],

            // No period yet: the one thing that makes this work, with its
            // button right there.
            if (logs && start == null) ...[
              ttcToolPad(TtcToolBlock(text: kTtcOvNoPeriod, hue: kTtcOvHue)),
              const SizedBox(height: 12),
              ttcToolPad(
                TtcToolPrimary(
                  key: const ValueKey('ttc_ov_log_period'),
                  label: kTtcOvLogPeriod,
                  onTap: () => logTtcPeriod(context),
                ),
              ),
              const SizedBox(height: 22),
            ],

            // Our estimate, and when to start testing, on her own cycle.
            if (!today.clinicInvolved && start != null) ...[
              ttcToolPad(_EstimateCard(today: today, start: start, now: now)),
              const SizedBox(height: 22),
            ],

            if (logs && start != null) ...[
              ttcToolPad(
                Text(
                  kTtcOvTestsHeading,
                  style: pvFraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: p.ink1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _CycleStrip(
                start: start,
                today: now,
                selected: _day.isBefore(start) ? now : _day,
                lhDay: cycle.lhPositiveDay,
                onPick: (d) => setState(() => _day = d),
              ),
              const SizedBox(height: 8),
              ttcToolPad(
                Text(
                  kTtcOvLegend,
                  style: pvManrope(fontSize: 11.5, color: p.ink3),
                ),
              ),
              const SizedBox(height: 16),
              ..._resultBlock(start, now, p),
              const SizedBox(height: 14),
              ..._adoptCard(start, now, p),
              ttcToolPad(
                Text(
                  t.ovulationLhWhat,
                  style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink2),
                ),
              ),
              const SizedBox(height: 26),
              ttcToolPad(Container(height: 1, color: p.line)),
              const SizedBox(height: 22),
              ..._tempBlock(start, now, t, p),
            ],

            const SizedBox(height: 24),
            for (final id in const [
              'ttc_read_ovulation_kits',
              'ttc_read_ovulation_tests_irregular',
            ])
              if (ttcReadById(id) case final r?) ...[
                ttcToolPad(
                  _ReadRow(
                    key: ValueKey('ttc_ov_read_$id'),
                    title: r.title.en,
                    onTap: () => openTtcArticle(context, id, hue: kTtcOvHue),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            const SizedBox(height: 14),
            ttcToolPad(
              Text(
                t.estimatesDisclaimer,
                style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3),
              ),
            ),
            const SizedBox(height: 28),
          ],
        );
      },
    );
  }

  List<Widget> _resultBlock(DateTime start, DateTime now, V2Palette p) {
    final day = _day.isBefore(start) ? now : _day;
    final cd = day.difference(start).inDays + 1;
    final lh = CycleStore.instance.lhPositiveDay;
    var result = ttcOvResultOn(day);
    // A positive recorded the old way ("Record it") has no strip entry; it
    // still shows as the positive it is.
    if (result == null && lh == cd) result = kTtcOvPositive;
    return [
      ttcToolPad(
        Text(
          ttcOvResultLine(day, cd, result),
          key: const ValueKey('ttc_ov_day_line'),
          style: pvManrope(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            height: 1.4,
            color: p.ink1,
          ),
        ),
      ),
      const SizedBox(height: 10),
      ttcToolPad(
        TtcToolOptions(
          p: p,
          hue: kTtcOvHue,
          items: [
            TtcToolOption(
              label: kTtcOvNegativeLabel,
              on: result == kTtcOvNegative,
              onTap: () => _setResult(
                start,
                day,
                result == kTtcOvNegative ? null : kTtcOvNegative,
              ),
            ),
            TtcToolOption(
              label: kTtcOvPositiveLabel,
              on: result == kTtcOvPositive,
              onTap: () => _setResult(
                start,
                day,
                result == kTtcOvPositive ? null : kTtcOvPositive,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      ttcToolPad(
        Text(
          'Tap the chosen one again to clear it.',
          style: pvManrope(fontSize: 11.5, color: p.ink3),
        ),
      ),
    ];
  }

  /// A positive logged in the daily log, not yet moving her fertile days:
  /// offered, never adopted silently.
  List<Widget> _adoptCard(DateTime start, DateTime now, V2Palette p) {
    final cycle = CycleStore.instance;
    if (cycle.lhPositiveDay != null) return const [];
    final first = ttcOvFirstPositiveDay(start, now);
    if (first == null) return const [];
    final on = start.add(Duration(days: first - 1));
    return [
      ttcToolPad(
        Container(
          key: const ValueKey('ttc_ov_adopt'),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ttcTitleInk, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You logged a positive test on ${ttcRoundDate(on)} (day $first). '
                'Use it for your fertile days?',
                style: pvManrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  color: p.ink1,
                ),
              ),
              const SizedBox(height: 12),
              TtcToolPrimary(
                key: const ValueKey('ttc_ov_adopt_yes'),
                label: 'Use it',
                onTap: () => _adopt(first),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
    ];
  }

  List<Widget> _tempBlock(DateTime start, DateTime now, TtcS t, V2Palette p) {
    final cycle = CycleStore.instance;
    final shift = cycle.temperatureShiftDay;
    final currentDay = now.difference(start).inDays + 1;
    return [
      ttcToolPad(
        Text(
          kTtcOvTempHeading,
          style: pvFraunces(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: p.ink1,
          ),
        ),
      ),
      const SizedBox(height: 8),
      ttcToolPad(
        Text(
          t.ovulationBbtWhat,
          style: pvManrope(fontSize: 12.5, height: 1.55, color: p.ink2),
        ),
      ),
      const SizedBox(height: 12),
      if (shift != null)
        ttcToolPad(
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recorded: day $shift, '
                  '${ttcRoundDate(start.add(Duration(days: shift - 1)))}.',
                  key: const ValueKey('ttc_ov_temp_line'),
                  style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: p.ink1,
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('ttc_ov_temp_change'),
                onPressed: () => _pickTempDay(currentDay, t),
                child: Text(
                  'Change',
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: ttcTitleInk,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('ttc_ov_temp_remove'),
                onPressed: () {
                  cycle.logTemperatureShift(null);
                  pvSnack(
                    context,
                    'Temperature rise removed.',
                    icon: Icons.check_rounded,
                    lift: 24,
                    action: 'Undo',
                    onAction: () => cycle.logTemperatureShift(shift),
                  );
                },
                child: Text(
                  'Remove',
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: ttcTitleInk,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        )
      else
        ttcToolPad(
          TtcToolSecondary(
            key: const ValueKey('ttc_ov_temp_add'),
            label: kTtcOvTempAdd,
            onTap: () => _pickTempDay(currentDay, t),
          ),
        ),
    ];
  }
}

/// Our estimate, said plainly, and when to start testing.
class _EstimateCard extends StatelessWidget {
  const _EstimateCard({
    required this.today,
    required this.start,
    required this.now,
  });

  final TtcToday today;
  final DateTime start;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final hi = t.hinglish;
    final p = V2PaletteStore.instance.current;
    final cycle = CycleStore.instance;
    final ov = today.estimatedOvulationDay;
    final cd = today.cycleDay;

    if (ov == null) {
      return Container(
        key: const ValueKey('ttc_ov_estimate'),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ttcLine, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.noEstimateYet,
              style: pvManrope(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: p.ink1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cd == null ? t.ovulationNotYet : t.noEstimateBody,
              style: pvManrope(fontSize: 13, height: 1.55, color: p.ink2),
            ),
          ],
        ),
      );
    }

    final ovDate = start.add(Duration(days: ov - 1));
    final fromTest = cycle.lhPositiveDay != null;
    final fromTemp = !fromTest && cycle.temperatureShiftDay != null;
    final startDay = ttcOvStartTestingDay(ov);
    String? startLine;
    if (!fromTest &&
        !fromTemp &&
        today.confidence != OvulationConfidence.low &&
        cd != null &&
        startDay != null &&
        cd <= ov + 1) {
      final on = start.add(Duration(days: startDay - 1));
      startLine = cd <= startDay
          ? 'Start testing around day $startDay (${ttcRoundDate(on)}). Test '
                'once a day, in the afternoon, until you get a positive.'
          : 'Test once a day, in the afternoon, until you get a positive.';
    }

    return Container(
      key: const ValueKey('ttc_ov_estimate'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ttcLine, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR LIKELY OVULATION DAY',
            style: pvManrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: p.ink3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Day $ov, ${ttcRoundDate(ovDate)}',
            style: pvFraunces(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: p.ink1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fromTest
                ? 'From your positive test on day ${cycle.lhPositiveDay}.'
                : fromTemp
                ? 'From the day your temperature rose.'
                : today.confidence.phrase(hi),
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2),
          ),
          if (startLine != null) ...[
            const SizedBox(height: 12),
            Divider(color: p.line, height: 1),
            const SizedBox(height: 12),
            Text(
              startLine,
              key: const ValueKey('ttc_ov_start_line'),
              style: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                height: 1.5,
                color: p.ink1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// This cycle's days, today on the right. A filled dot for a positive, a ring
/// for a negative, nothing for a day with no test.
class _CycleStrip extends StatelessWidget {
  const _CycleStrip({
    required this.start,
    required this.today,
    required this.selected,
    required this.lhDay,
    required this.onPick,
  });

  final DateTime start;
  final DateTime today;
  final DateTime selected;
  final int? lhDay;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final n = today.difference(start).inDays + 1;
    // A long gap since the last period would be a very long strip; the last
    // 45 days is more than any cycle a strip is used in.
    final from = n > 45 ? n - 44 : 1;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          for (var cd = from; cd <= n; cd++)
            Builder(
              builder: (_) {
                final d = start.add(Duration(days: cd - 1));
                final on = d == selected;
                var r = ttcOvResultOn(d);
                if (r == null && lhDay == cd) r = kTtcOvPositive;
                return Semantics(
                  button: true,
                  selected: on,
                  label:
                      'Day $cd, ${ttcRoundDate(d)}'
                      '${r == kTtcOvPositive
                          ? ', positive'
                          : r == kTtcOvNegative
                          ? ', negative'
                          : ''}',
                  excludeSemantics: true,
                  onTap: () => onPick(d),
                  child: GestureDetector(
                    key: ValueKey('ttc_ov_day_$cd'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onPick(d),
                    child: Container(
                      width: 44,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: on ? ttcTitleInk : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: on ? ttcTitleInk : ttcLine,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            d == today ? 'Today' : 'Day $cd',
                            maxLines: 1,
                            style: pvManrope(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: on ? Colors.white : p.ink3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${d.day}',
                            style: pvManrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: on ? Colors.white : ttcTitleInk,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: r == kTtcOvPositive
                                  ? (on ? Colors.white : ttcTitleInk)
                                  : Colors.transparent,
                              border: r == kTtcOvNegative || r == kTtcOvPositive
                                  ? Border.all(
                                      color: on ? Colors.white : ttcTitleInk,
                                      width: 1.4,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ReadRow extends StatelessWidget {
  const _ReadRow({super.key, required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: ttcLine, width: 1.2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.article_outlined,
                  size: 16,
                  color: ttcTitleInk,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: ttcTitleInk,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
