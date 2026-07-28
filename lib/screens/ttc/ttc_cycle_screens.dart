// =============================================================================
//  TTC - Cycle Companion · Ovulation Companion · Fertility Window
// -----------------------------------------------------------------------------
//  The three engine-backed tools. All three read the SAME TtcChapterEngine that
//  drives Today's hero, so the fertile day shown here and the chapter shown
//  there can never disagree - they are one calculation displayed three ways.
//
//      "Cycle Companion. Not called Cycle Tracker. Purpose: understand
//       patterns. Not predict perfection."                - TTC master, §3.4
//
//  Kept in one file because they are one idea at three depths, and splitting
//  them invites the copy to drift apart.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_store.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';
import 'ttc_today_screen.dart' show logTtcPeriod;
import 'ttc_treatment_screen.dart';

// =============================================================================
//  Cycle Companion
// =============================================================================

class TtcCycleScreen extends StatelessWidget {
  const TtcCycleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final cycle = CycleStore.instance;
        final today = TtcStore.instance.today;
        final lengths = cycle.cycleLengths;
        const engine = TtcChapterEngine();
        final irregular = engine.isIrregular(TtcStore.instance.state());

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
                TtcBackBar(title: t.cycleCompanion),
                const SizedBox(height: 16),

                if (today.cycleDay == null)
                  TtcEmpty(
                    icon: Icons.favorite_border_rounded,
                    title: t.logPeriodTitle,
                    body: t.logPeriodBody,
                    cta: t.logPeriodCta,
                    onTap: () => logTtcPeriod(context),
                  )
                else
                  _CycleHero(t: t, today: today),

                const SizedBox(height: 20),

                // ---- what we know about her rhythm ------------------------
                if (lengths.isNotEmpty) ...[
                  ttcSectionTitle(t.yourRhythm),
                  TtcCard(
                    child: Column(children: [
                      Row(children: [
                        Expanded(
                          child: _stat(
                              t.cycleAverage,
                              '${engine.cycleLengthFor(TtcStore.instance.state())} ${t.cycleDays}'),
                        ),
                        Container(width: 1, height: 34, color: ttcLine),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _stat(t.cycleRange,
                              '${lengths.reduce((a, b) => a < b ? a : b)}–${lengths.reduce((a, b) => a > b ? a : b)} ${t.cycleDays}'),
                        ),
                      ]),
                      if (irregular) ...[
                        const SizedBox(height: 16),
                        ttcDivider(),
                        const SizedBox(height: 12),
                        // Named plainly rather than flagged in red. Irregular
                        // cycles are common and are not a failing.
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  size: 16, color: ttcBrown),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(t.cycleIrregularNote,
                                    style: ttcBody(12.5,
                                        color: ttcBrown, h: 1.5)),
                              ),
                            ]),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 20),
                ] else if (today.cycleDay != null) ...[
                  TtcCard(
                    color: ttcPanel,
                    child: Text(t.cycleNeedMore, style: ttcBody(13.5, h: 1.55)),
                  ),
                  const SizedBox(height: 20),
                ],

                // ---- the logged periods -----------------------------------
                ttcSectionTitle(t.cycleHistory,
                    trailing: GestureDetector(
                      onTap: () => logTtcPeriod(context),
                      behavior: HitTestBehavior.opaque,
                      child: Text(t.logPeriodCta,
                          style: ttcBody(12,
                              color: ttcPurple, w: FontWeight.w800)),
                    )),
                if (cycle.periodStarts.isEmpty)
                  TtcEmpty(
                    icon: Icons.history_rounded,
                    title: t.trackerEmptyTitle,
                    body: t.trackerEmptyBody,
                  )
                else
                  for (var i = cycle.periodStarts.length - 1; i >= 0; i--) ...[
                    _PeriodRow(
                      start: cycle.periodStarts[i],
                      // The length of the cycle that BEGAN on this date, which
                      // only exists once the next period has been logged.
                      length: i + 1 < cycle.periodStarts.length
                          ? cycle.periodStarts[i + 1]
                              .difference(cycle.periodStarts[i])
                              .inDays
                          : null,
                      t: t,
                    ),
                    const SizedBox(height: 10),
                  ],

                const SizedBox(height: 14),
                TtcDisclaimer(t: t),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: ttcBody(9.5, color: ttcMuted, w: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(value, style: ttcJakarta(17)),
        ],
      );
}

class _CycleHero extends StatelessWidget {
  const _CycleHero({required this.t, required this.today});

  final TtcS t;
  final TtcToday today;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ttcCardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ttcPurple, Color(0xFF8B4FD0)],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.whichCycleDay(today.cycleDay!),
            style: ttcBody(12,
                color: Colors.white.withValues(alpha: 0.85),
                w: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(today.chapter.title(hi),
            style: ttcFraunces(24, w: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 14),
        TtcProgressBar(
            value: today.cycleLength <= 0
                ? 0
                : (today.cycleDay! / today.cycleLength).clamp(0.0, 1.0)),
        const SizedBox(height: 10),
        // Prediction language belongs only where we actually predict. On a
        // clinic path "based on your cycles so far" contradicts the page next
        // door, which has just promised we defer to them.
        Text(
            today.behaviour.predictsOvulation
                ? today.confidence.phrase(hi)
                : t.clinicGuidingTiming,
            style:
                ttcBody(12, color: Colors.white.withValues(alpha: 0.9))),
      ]),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({required this.start, required this.length, required this.t});

  final DateTime start;
  final int? length;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    // Whether this gap reached the average at all.
    //
    // The stats card and this list used to disagree in plain sight: "Average
    // 54 days · Range 54-54" sitting directly above gaps of 1, 2, 3 and 6.
    // The stats were right - every short gap had been discarded - but nothing
    // said so, so the screen simply looked wrong.
    final gap = CycleStore.instance.gapBefore(start);
    final uncounted = gap != null && !gap.counted;

    return TtcCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.circle,
              size: 9, color: uncounted ? ttcLine : ttcCoral),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_fmt(start),
                style: ttcBody(13.5,
                    color: uncounted ? ttcMuted : ttcInk,
                    w: FontWeight.w600)),
          ),
          if (length != null)
            Text(t.cycleDayCount(length!),
                style: ttcBody(12.5, color: ttcMuted, w: FontWeight.w700)),
          GestureDetector(
            onTap: () => CycleStore.instance.removePeriodStart(start),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(Icons.close_rounded, size: 16, color: ttcMuted),
            ),
          ),
        ]),
        if (uncounted) ...[
          const SizedBox(height: 9),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ttcPanel,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(t.notCountedChip,
                  style: ttcBody(10.5, color: ttcSoft, w: FontWeight.w800)),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(t.notCountedWhy,
                  style: ttcBody(11, color: ttcMuted, h: 1.45)),
            ),
          ]),
        ],
      ]),
    );
  }

  static String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

// =============================================================================
//  Ovulation Companion
// =============================================================================

class TtcOvulationScreen extends StatelessWidget {
  const TtcOvulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final today = TtcStore.instance.today;
        final cycle = CycleStore.instance;

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
                TtcBackBar(title: t.ovulationCompanion),
                const SizedBox(height: 16),

                // A clinic-run cycle gets no calendar estimate at all - the
                // engine refuses to publish one, and this says why.
                if (today.clinicInvolved)
                  TtcTreatmentEntryCard(t: t)

                // The estimate, always with its confidence. Never "you WILL
                // ovulate tomorrow" - confidence replaces certainty.
                else
                  TtcCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (today.estimatedOvulationDay == null) ...[
                          Text(t.noEstimateYet, style: ttcJakarta(16)),
                          const SizedBox(height: 8),
                          Text(
                              today.cycleDay == null
                                  ? t.ovulationNotYet
                                  : t.noEstimateBody,
                              style: ttcBody(13.5, h: 1.55)),
                        ] else ...[
                          Text(
                              t.estimatedOvulation(
                                  today.estimatedOvulationDay!),
                              style: ttcJakarta(18)),
                          const SizedBox(height: 8),
                          Text(today.confidence.phrase(hi),
                              style: ttcBody(13.5, h: 1.5)),
                          if (today.fertility != null) ...[
                            const SizedBox(height: 14),
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 6),
                                decoration: BoxDecoration(
                                  color: ttcFertilityTint(today.fertility!),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(today.fertility!.label(hi),
                                    style: ttcBody(12,
                                        color:
                                            ttcFertilityInk(today.fertility!),
                                        w: FontWeight.w800)),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                  child: Text(t.chanceLabel,
                                      style: ttcBody(12.5))),
                            ]),
                          ],
                        ],
                      ]),
                ),
                const SizedBox(height: 20),

                // ---- her own signals --------------------------------------
                //  Offered whenever her own body still decides the moment -
                //  which INCLUDES the clinic-guided tier. On a natural-cycle
                //  FET or an IUI timed to her surge, her LH is precisely what
                //  the clinic is acting on, so logging it is more useful there
                //  than anywhere.
                //
                //  Dropped only on a fully medicated cycle, where the surge is
                //  caused by a trigger and a strip tells us nothing we would
                //  act on. Asking for data we intend to ignore is the one thing
                //  the product refuses to do.
                if (today.behaviour.logsBodySignals) ...[
                  ttcSectionTitle(t.ovulationSignals),
                  TtcCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.ovulationSignalNote,
                              style: ttcBody(13, h: 1.55)),
                          const SizedBox(height: 16),
                          _SignalRow(
                            label: t.ovulationLh,
                            what: t.ovulationLhWhat,
                            day: cycle.lhPositiveDay,
                            enabled: today.cycleDay != null,
                            currentDay: today.cycleDay,
                            onSet: CycleStore.instance.logLhPositive,
                            t: t,
                          ),
                          const SizedBox(height: 14),
                          ttcDivider(),
                          const SizedBox(height: 14),
                          _SignalRow(
                            label: t.ovulationBbt,
                            what: t.ovulationBbtWhat,
                            day: cycle.temperatureShiftDay,
                            enabled: today.cycleDay != null,
                            currentDay: today.cycleDay,
                            onSet: CycleStore.instance.logTemperatureShift,
                            t: t,
                          ),
                        ]),
                  ),
                  const SizedBox(height: 16),
                ],
                TtcDisclaimer(t: t),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Today, or one of the last few days.
///
/// Deliberately not a full date picker: a signal recorded against a day weeks
/// back is a guess, and this stage does not trade in those.
Future<int?> _pickSignalDay(BuildContext context, int today, TtcS t) {
  final options = <int>[
    for (var back = 0; back < 4; back++)
      if (today - back >= 1) today - back
  ];
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(t.ovulationWhichDay, style: ttcJakarta(16)),
          const SizedBox(height: 16),
          for (final d in options)
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(d),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ttcPanel,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  d == today ? t.ovulationToday : t.whichCycleDay(d),
                  style: ttcBody(13.5, color: ttcInk, w: FontWeight.w700),
                ),
              ),
            ),
        ]),
      ),
    ),
  );
}

class _SignalRow extends StatelessWidget {
  const _SignalRow({
    required this.label,
    required this.what,
    required this.day,
    required this.enabled,
    required this.currentDay,
    required this.onSet,
    required this.t,
  });

  final String label;

  /// What the signal actually is, and - for the temperature - that it confirms
  /// ovulation AFTER it happens rather than predicting it. The screen named
  /// both of these and explained neither.
  final String what;

  final int? day;
  final bool enabled;
  final int? currentDay;
  final void Function(int?) onSet;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final on = day != null;
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ttcBody(13.5, color: ttcInk, w: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(what, style: ttcBody(11.5, color: ttcSoft, h: 1.5)),
          if (on) ...[
            const SizedBox(height: 5),
            Text(t.whichCycleDay(day!),
                style: ttcBody(12, color: ttcPurple, w: FontWeight.w700)),
          ],
        ]),
      ),
      const SizedBox(width: 12),
      GestureDetector(
        // Today by default, but the last few days are offered too.
        //
        // The original restricted this to today on the grounds that it is "the
        // only day a woman can honestly report a reading from". That holds for
        // inventing a day; it does not hold for remembering on Tuesday that
        // Sunday's strip was positive. The range is kept short so the guard
        // survives.
        onTap: !enabled
            ? null
            : () async {
                if (on) {
                  onSet(null);
                  return;
                }
                final picked = await _pickSignalDay(context, currentDay!, t);
                if (picked != null) onSet(picked);
              },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: !enabled
                ? ttcPanel
                : on
                    ? ttcPurple
                    : ttcPanel,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            on ? t.trackerClear : t.ovulationRecordIt,
            style: ttcBody(12.5,
                color: !enabled
                    ? ttcMuted
                    : on
                        ? Colors.white
                        : ttcPurple,
                w: FontWeight.w800),
          ),
        ),
      ),
    ]);
  }
}

// =============================================================================
//  Fertility Window
// =============================================================================

class TtcFertilityWindowScreen extends StatefulWidget {
  const TtcFertilityWindowScreen({super.key});

  @override
  State<TtcFertilityWindowScreen> createState() =>
      _TtcFertilityWindowScreenState();
}

class _TtcFertilityWindowScreenState extends State<TtcFertilityWindowScreen> {
  bool _wholeCycleOpen = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final store = TtcStore.instance;
        final today = store.today;
        const engine = TtcChapterEngine();
        final state = store.state();

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
                TtcBackBar(title: t.fertilityWindow),
                const SizedBox(height: 16),

                // On a clinic-run cycle the six-day-window explanation is not
                // just unhelpful, it is the wrong model - so it is replaced
                // rather than shown alongside a caveat.
                if (!today.behaviour.showsFertilityWindow) ...[
                  TtcTreatmentEntryCard(t: t),
                ] else ...[
                  TtcCard(
                    color: ttcPanel,
                    child:
                        Text(t.fertilityWindowNote, style: ttcBody(13.5, h: 1.6)),
                  ),
                  const SizedBox(height: 20),
                  if (today.estimatedOvulationDay == null)
                  TtcEmpty(
                    icon: Icons.wb_twilight_rounded,
                    title: t.noEstimateYet,
                    body: today.cycleDay == null
                        ? t.ovulationNotYet
                        : t.noEstimateBody,
                    cta: today.cycleDay == null ? t.logPeriodCta : null,
                    onTap: today.cycleDay == null
                        ? () => logTtcPeriod(context)
                        : null,
                  )
                  else ...[
                    // The answer, stated. This screen used to open with the
                    // whole cycle a day at a time - fifty-four rows on real
                    // data, of which seven carried information and the rest
                    // said "Low". For an anxious reader that is a scrollable
                    // list of failure, and the one sentence she came for was
                    // never written down anywhere.
                    _WindowSummary(today: today, t: t),
                    const SizedBox(height: 18),

                    // The window itself, as one picture. Keeping that idea from
                    // the original - "the width is the point" is the reassuring
                    // fact here - but seven adjacent bars show width, where
                    // fifty-four bury it.
                    ttcSectionTitle(t.fertilityAcross),
                    TtcCard(
                      child: Column(children: [
                        for (var day = 1; day <= today.cycleLength; day++)
                          if (engine.fertilityFor(state, day) != null &&
                              engine.fertilityFor(state, day) !=
                                  FertilityLevel.low)
                            _DayBar(
                              day: day,
                              level: engine.fertilityFor(state, day)!,
                              isToday: day == today.cycleDay,
                              isOvulation: day == today.estimatedOvulationDay,
                              t: t,
                            ),
                      ]),
                    ),
                    const SizedBox(height: 14),

                    // The rest of the cycle is still available - some people
                    // want to see it - but folded, so it is a choice rather
                    // than the first thing she meets.
                    GestureDetector(
                      onTap: () =>
                          setState(() => _wholeCycleOpen = !_wholeCycleOpen),
                      behavior: HitTestBehavior.opaque,
                      child: Row(children: [
                        Text(
                            _wholeCycleOpen
                                ? t.windowHideWhole
                                : t.windowSeeWhole,
                            style: ttcBody(12.5,
                                color: ttcPurple, w: FontWeight.w800)),
                        const SizedBox(width: 3),
                        Icon(
                            _wholeCycleOpen
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 18,
                            color: ttcPurple),
                      ]),
                    ),
                    if (_wholeCycleOpen) ...[
                      const SizedBox(height: 12),
                      TtcCard(
                        child: Column(children: [
                          for (var day = 1; day <= today.cycleLength; day++)
                            if (engine.fertilityFor(state, day) != null)
                              _DayBar(
                                day: day,
                                level: engine.fertilityFor(state, day)!,
                                isToday: day == today.cycleDay,
                                isOvulation:
                                    day == today.estimatedOvulationDay,
                                t: t,
                              ),
                        ]),
                      ),
                    ],
                  ],
                ],
                const SizedBox(height: 16),
                TtcDisclaimer(t: t),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The answer, before the picture.
///
/// Stated in DATES, not cycle days. "Days 35 to 41" is how the engine thinks;
/// "12 to 18 August" is how someone plans a week.
class _WindowSummary extends StatelessWidget {
  const _WindowSummary({required this.today, required this.t});

  final TtcToday today;
  final TtcS t;

  static const _m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static String _fmt(DateTime d) => '${d.day} ${_m[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final start = CycleStore.instance.lastPeriodStart;
    final ov = today.estimatedOvulationDay;
    if (start == null || ov == null) return const SizedBox.shrink();

    // Sperm survive about five days, the egg about one.
    final opensDay = ov - 5;
    final closesDay = ov + 1;
    DateTime dateOf(int cycleDay) =>
        start.add(Duration(days: cycleDay - 1));

    final cycleDay = today.cycleDay ?? 0;
    final status = cycleDay > closesDay
        ? t.windowClosed
        : cycleDay >= opensDay
            ? t.windowOpenNow
            : t.windowOpensIn(opensDay - cycleDay);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ttcCardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ttcPurple, Color(0xFF8B4FD0)],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(t.windowYourDays,
                style: ttcBody(11.5,
                    color: Colors.white.withValues(alpha: 0.85),
                    w: FontWeight.w800)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(status,
                style: ttcBody(10.5, color: Colors.white, w: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 9),
        Text(t.windowRange(_fmt(dateOf(opensDay)), _fmt(dateOf(closesDay))),
            style: ttcFraunces(24, w: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Text('${t.windowPeakDay} · ${_fmt(dateOf(ov))}',
            style: ttcBody(12.5,
                color: Colors.white.withValues(alpha: 0.92),
                w: FontWeight.w700)),
      ]),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.day,
    required this.level,
    required this.isToday,
    required this.isOvulation,
    required this.t,
  });

  final int day;
  final FertilityLevel level;
  final bool isToday;
  final bool isOvulation;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    // Intensity, not hue: the low days are a wash and the peak days are solid.
    // A greyscale screenshot still reads correctly, and so does a colour-blind
    // eye - which a green-to-red traffic light would not.
    final width = switch (level) {
      FertilityLevel.low => 0.18,
      FertilityLevel.medium => 0.45,
      FertilityLevel.high => 0.72,
      FertilityLevel.peak => 1.0,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
          width: 26,
          child: Text('$day',
              style: ttcBody(11.5,
                  color: isToday ? ttcPurple : ttcMuted,
                  w: isToday ? FontWeight.w900 : FontWeight.w600)),
        ),
        Expanded(
          child: Stack(children: [
            Container(
              height: 16,
              decoration: BoxDecoration(
                  color: ttcPanel, borderRadius: BorderRadius.circular(999)),
            ),
            FractionallySizedBox(
              widthFactor: width,
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: ttcFertilityTint(level),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 92,
          child: Text(
            isOvulation
                ? (hi ? 'Ovulation' : 'Ovulation')
                : level.label(hi),
            style: ttcBody(11,
                color: isOvulation ? ttcCoral : ttcMuted,
                w: FontWeight.w700),
          ),
        ),
      ]),
    );
  }
}

// ---- shared -----------------------------------------------------------------

