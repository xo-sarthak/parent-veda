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
import '../../ttc/ttc_fertile_window.dart';
import '../../ttc/ttc_store.dart';
import 'ttc_common.dart';
import 'ttc_cycle_companion.dart';
import 'ttc_strings.dart';
import 'ttc_today_screen.dart' show logTtcPeriod;
import 'ttc_treatment_screen.dart';

// =============================================================================
//  Cycle Companion
// =============================================================================

// ⚠️ THE ENTRY, AND NOTHING MORE. `ttc_cycle` is opened from twelve places —
// the TTC home (four call sites), the fertility-help screen, the PCOS door's
// Track group, a hub, two journey steps and two brackets — and the surface id
// is read as a route name by `global_ask_fab.dart`. So the class stays exactly
// where it was and the rebuild happens behind it.
//
// ⚠️ THE OLD BODY IS COMMENTED OUT BELOW, NOT DELETED, per CLAUDE.md. It was
// two numbers and a list with no picture of a cycle on it, and its degradation
// was genuinely good — one cycle is not an average, one observation is not a
// range, an untrustworthy history shows no numbers at all. All three rules
// survive in `_RhythmCard` and the refusal body; the old code is kept so the
// comparison can be made rather than remembered.
class TtcCycleScreen extends StatelessWidget {
  const TtcCycleScreen({super.key});

  @override
  Widget build(BuildContext context) => const TtcCycleCompanionScreen();
}

/*
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
        final state = TtcStore.instance.state();
        final irregular = engine.isIrregular(state);
        // The engine has already decided this history cannot carry an estimate.
        // Today says so out loud; this screen used to print "Average length 54
        // days · Range 54-54" anyway, from a single gap that was itself a month
        // nobody logged. Two screens, one dataset, opposite verdicts - and the
        // confident one was wrong.
        final untrustworthy = engine.hasUnreliableHistory(state);

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
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
                if (untrustworthy) ...[
                  // Word for word what Today shows, from the same strings, so
                  // the two can never drift into disagreeing again.
                  ttcSectionTitle(t.yourRhythm),
                  TtcCard(
                    color: ttcPanel,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.noEstHistoryOffTitle, style: ttcJakarta(15)),
                          const SizedBox(height: 8),
                          Text(t.noEstHistoryOffBody,
                              style: ttcBody(12.5, h: 1.55)),
                        ]),
                  ),
                  const SizedBox(height: 20),
                ] else if (lengths.isNotEmpty) ...[
                  ttcSectionTitle(t.yourRhythm),
                  TtcCard(
                    child: Column(children: [
                      Row(children: [
                        Expanded(
                          child: _stat(
                              // One cycle is not an average. Calling it one
                              // invites her to plan around a single month.
                              lengths.length == 1
                                  ? t.cycleFirstFull
                                  : t.cycleAverage,
                              '${engine.cycleLengthFor(state)} ${t.cycleDays}'),
                        ),
                        // A "range" needs two points. "54-54 days" was the app
                        // dressing one observation up as a spread.
                        if (lengths.length > 1) ...[
                          Container(width: 1, height: 34, color: ttcLine),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _stat(t.cycleRange,
                                '${lengths.reduce((a, b) => a < b ? a : b)} to ${lengths.reduce((a, b) => a > b ? a : b)} ${t.cycleDays}'),
                          ),
                        ] else
                          const Spacer(),
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
                    // The row derives its own length and verdict from the store
                    // - see `cycleFrom`. Passing a length in from here is what
                    // let the two drift apart.
                    _PeriodRow(start: cycle.periodStarts[i], t: t),
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
          colors: [ttcPurple, ttcPurpleDeep],
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
  const _PeriodRow({required this.start, required this.t});

  final DateTime start;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    // The length AND the verdict, from one call.
    //
    // They used to come from two: the number was the cycle that began on this
    // date, the verdict was about the cycle before it. So a row could read
    // "54 days · Not counted · too close to the entry before it" - both halves
    // true, about different cycles - while a four-day gap sat there marked as
    // counted, contradicting the average printed inches above it.
    //
    // The stats card and this list have to agree, and the only reliable way to
    // make two things agree is to stop computing them twice.
    final cycle = CycleStore.instance.cycleFrom(start);
    final length = cycle?.days;
    final uncounted = cycle != null && !cycle.counted;

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
            Text(t.cycleDayCount(length),
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
              child: Text(t.notCountedWhy(cycle.days),
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

*/

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
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
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
  // ⚠️ "SEE THE WHOLE CYCLE" IS GONE — `_wholeCycleOpen` and its fold went with
  // it. Kept as a comment rather than deleted, with the strings, because the
  // argument for it was never silly: some people do want the whole month.
  //
  // What killed it is that it was answering a question this screen is not for.
  // The screen is "when are my days"; the whole cycle is "what does every day
  // score", and on real data forty-odd of those rows say "Low". A scrollable
  // list of Low is what an anxious reader sees as a list of days she failed.
  // The cycle companion and the calendar both still show the full month.
  //
  // bool _wholeCycleOpen = false;

  /// How many cycles forward she has paged, via the arrow on the summary.
  ///
  /// ⚠️ ZERO IS "THE ONE SHE CAN ACT ON", NOT "THIS CALENDAR MONTH". The
  /// projection resolves to the window that is open now or the next one — never
  /// one that has closed — so paging forward from zero means the cycle after
  /// the soonest useful one. See `ttc_fertile_window.dart`.
  int _cyclesAhead = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final store = TtcStore.instance;
        final today = store.today;
        // The engine and the journey state used to be read here to score every
        // day of the cycle inline. Both moved behind `ttcFertilityOnDate`, so
        // the two halves of this screen can no longer disagree about which days
        // are in the window — which they could, and briefly did.

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
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
                    //
                    // ⚠️ NEVER A WINDOW THAT HAS CLOSED. `ttcFertileWindowNow`
                    // rolls forward when this cycle's has passed - the long
                    // reason is at the head of `ttc_fertile_window.dart`, and
                    // the short one is that a passed window is a chance she
                    // missed, drawn in exactly the same shape as one she can
                    // still use.
                    _WindowSummary(
                      t: t,
                      cyclesAhead: _cyclesAhead,
                      onStep: (delta) => setState(() {
                        // Six ahead, per the note on the arrow. Clamped rather
                        // than wrapped: paging past the end should stop, not
                        // silently return her to this month.
                        _cyclesAhead = (_cyclesAhead + delta).clamp(0, 5);
                      }),
                    ),
                    const SizedBox(height: 18),

                    // The window itself, as one picture. Keeping that idea from
                    // the original - "the width is the point" is the reassuring
                    // fact here - but seven adjacent bars show width, where
                    // fifty-four bury it.
                    //
                    // ⚠️ THE ROWS NOW COVER EXACTLY THE RANGE THE SUMMARY NAMES
                    // ABOVE THEM, and are labelled with the same dates. Before
                    // this they were cycle-day numbers filtered by "not Low",
                    // which is a different set arrived at a different way - so
                    // the card could legitimately start on a day the headline
                    // did not mention, and nothing on screen explained why.
                    ttcSectionTitle(t.fertilityAcross),
                    _WindowBars(cyclesAhead: _cyclesAhead, t: t),
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
  const _WindowSummary({
    required this.t,
    required this.cyclesAhead,
    required this.onStep,
  });

  final TtcS t;

  /// How many cycles past the soonest actionable one she has paged.
  final int cyclesAhead;

  /// +1 / -1 from the arrows.
  final void Function(int delta) onStep;

  static const _m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static String _fmt(DateTime d) => '${d.day} ${_m[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final window = ttcWindowAhead(cyclesAhead);
    if (window == null) return const SizedBox.shrink();

    // ⚠️ THE CHIP NEVER SAYS "CLOSED" ANY MORE, because a closed window is
    // never what is on screen. It says open-now, or how long until this one
    // opens, or — once she has paged forward — that she is looking at a
    // projection rather than at this cycle.
    final status = window.cyclesAhead > 0
        ? t.windowExpected
        : window.openNow
            ? t.windowOpenNow
            : t.windowOpensIn(window.daysUntilOpen);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ttcCardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ttcPurple, ttcPurpleDeep],
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
        Row(children: [
          Expanded(
            child: Text(
                t.windowRange(_fmt(window.opensOn), _fmt(window.closesOn)),
                style: ttcFraunces(24, w: FontWeight.w600, color: Colors.white)),
          ),
          // ---- the arrows ------------------------------------------------
          //
          // ⚠️ SIX CYCLES AND NO FURTHER. Each step forward multiplies one
          // assumption — that her next cycle is the same length as her usual —
          // by another, so the tenth projected window is arithmetic rather than
          // information. Six months is already the horizon most people plan
          // over, and stopping there is honest about what the estimate is worth.
          _StepArrow(
            icon: Icons.chevron_left_rounded,
            enabled: cyclesAhead > 0,
            semantic: t.windowPrevCycle,
            onTap: () => onStep(-1),
          ),
          const SizedBox(width: 2),
          _StepArrow(
            icon: Icons.chevron_right_rounded,
            enabled: cyclesAhead < 5,
            semantic: t.windowNextCycle,
            onTap: () => onStep(1),
          ),
        ]),
        const SizedBox(height: 8),
        Text('${t.windowPeakDay} · ${_fmt(window.peakOn)}',
            style: ttcBody(12.5,
                color: Colors.white.withValues(alpha: 0.92),
                w: FontWeight.w700)),
        // ⚠️ A PROJECTION SAYS SO, IN WORDS, ON THE CARD. Not only in the chip
        // — a chip is read once and then stops being read, and these dates look
        // exactly as confident as the current cycle's.
        if (window.cyclesAhead > 0) ...[
          const SizedBox(height: 10),
          Text(t.windowProjectedNote,
              style: ttcBody(11.5,
                  color: Colors.white.withValues(alpha: 0.82), h: 1.45)),
        ],
      ]),
    );
  }
}

/// One of the two paging arrows on the summary.
class _StepArrow extends StatelessWidget {
  const _StepArrow({
    required this.icon,
    required this.enabled,
    required this.semantic,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final String semantic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        enabled: enabled,
        label: semantic,
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: enabled ? 0.2 : 0.07),
            ),
            child: Icon(icon,
                size: 20,
                color: Colors.white.withValues(alpha: enabled ? 1 : 0.35)),
          ),
        ),
      );
}

/// The window, one row per date.
///
/// ⚠️ DATES AND WEEKDAYS, NOT CYCLE DAYS. "Day 17" is how the engine thinks and
/// it is nearly useless for planning a week — she has to count forward from a
/// period start to place it. "22 Aug (Wed)" is the same fact in the units she
/// already lives in, and it is what the summary above already speaks in, so the
/// two halves of the screen finally agree.
class _WindowBars extends StatelessWidget {
  const _WindowBars({required this.cyclesAhead, required this.t});

  final int cyclesAhead;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final window = ttcWindowAhead(cyclesAhead);
    if (window == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return TtcCard(
      child: Column(children: [
        for (final date in window.days)
          if (ttcFertilityOnDate(window, date) case final level?)
            _DayBar(
              date: date,
              level: level,
              // ⚠️ ONLY THE REAL TODAY. On a projected window no row is today,
              // and marking one would be a small lie that reads as a large one.
              isToday: window.cyclesAhead == 0 &&
                  date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day,
              isOvulation: date.year == window.peakOn.year &&
                  date.month == window.peakOn.month &&
                  date.day == window.peakOn.day,
              t: t,
            ),
      ]),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.date,
    required this.level,
    required this.isToday,
    required this.isOvulation,
    required this.t,
  });

  final DateTime date;
  final FertilityLevel level;
  final bool isToday;
  final bool isOvulation;
  final TtcS t;

  static const _m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
        // ⚠️ THE DATE IS WIDER THAN THE NUMBER IT REPLACED, and that is the
        // cost of the change: "22 Aug (Wed)" needs 76px where "17" needed 26,
        // so the bar itself is shorter. Worth it — the bar shows relative
        // width, which survives being narrower, and the label is the half she
        // actually plans around.
        SizedBox(
          width: 76,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${date.day} ${_m[date.month - 1]}',
                style: ttcBody(12,
                    color: isToday ? ttcPurple : ttcInk,
                    w: isToday ? FontWeight.w900 : FontWeight.w700)),
            Text(_wd[(date.weekday - 1) % 7],
                style: ttcBody(10.5,
                    color: isToday ? ttcPurple : ttcMuted,
                    w: FontWeight.w600)),
          ]),
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

