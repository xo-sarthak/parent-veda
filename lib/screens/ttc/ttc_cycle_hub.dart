// =============================================================================
//  The cycle hub: her whole cycle on one screen (2026-10-17)
// -----------------------------------------------------------------------------
//  The user, holding our cycle screens next to Clue's, Flo's and Withings'
//  (Mobbin eed61cd1, 785854fd, 4bbe6258, a9b24b05): theirs are "stunning,
//  understandable, simple yet efficient, and everything is there under a
//  single screen"; ours was "something here, something there", and "very
//  bland… even the ring, the calendar".
//
//  So the Cycle companion became one screen, top to bottom:
//
//    · a week strip, each day in its part of the cycle (Flo, Apple Health);
//    · the ring, with the one useful sentence in its middle ("Period in 5
//      days") and the day she is on as a bubble on the ring (Clue);
//    · the predictions card: fertile days, ovulation, next period, and the
//      line that says WHERE they come from (no competitor says it; the user
//      was lost because we did not either);
//    · the month, drawn here, with dots for what she logged (Clue);
//    · what was tracked on the day she picked, with one Log button (Clue);
//    · rows to the three things that need a room of their own.
//
//  ⚠️ ONE DRAWING. The Calendar screen draws its month with [TtcHubMonth] too,
//  so the two cannot disagree about a day. Every colour comes from
//  `TtcCycleColours`; every fact about a day from `ttcFactsFor`, the resolver
//  the home's hero reads, so the hub and the home cannot disagree either.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/family_timeline.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/cycle_store.dart';
import 'ttc_cycle_companion.dart' show showTtcPeriodLogSheet;
import '../../ttc/ttc_chapter.dart' show FertilityLevel, TtcChapterEngine;
import '../../ttc/ttc_fertile_window.dart'
    show ttcWindowClosesAfterOvulation, ttcWindowOpensBeforeOvulation;
import '../../ttc/ttc_cycle_report.dart';
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_records_store.dart' show TtcAppointmentsStore;
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_treatment_store.dart';
import '../../ttc/ttc_symptom_data.dart';
import 'ttc_calendar_screen.dart'
    show ttcFactsFor; // kept for revert: TtcEstimateStripes, kTtcCalendarEstimateKey
import '../../widgets/pv_feedback.dart' show PvPress;
import 'ttc_common.dart';
import 'ttc_cycle_palette.dart';
import 'ttc_cycle_headline.dart' show ttcCycleHeadline;
import 'ttc_cycle_report_v3.dart' show ttcComingUpRows;
import 'ttc_ovulation_screen.dart'
    show
        TtcOvulationTestsScreen,
        kTtcOvNegative,
        kTtcOvPositive,
        ttcOvResultOn,
        ttcWindowSourceLine;
import 'ttc_strings.dart' show TtcLang, TtcPartnerMode;
import 'ttc_symptom_log_screen.dart' show TtcSymptomLogScreen;
import 'ttc_window_screen.dart' show ttcWindowForHim;

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
bool _same(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _short = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
// Sunday first, as the rest of the app (the pregnancy calendar, the TTC
// grid) starts a week.
const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

/// The Sunday on or before [d].
DateTime _sundayOf(DateTime d) =>
    DateTime(d.year, d.month, d.day - d.weekday % 7);

String _d(DateTime d) => '${d.day} ${_short[d.month - 1]}';

/// His side speaks about her (the same swaps every cycle screen uses).
String _voice(String s) => TtcPartnerMode.instance.on ? ttcWindowForHim(s) : s;

// =============================================================================
//  What a day is, for drawing
// =============================================================================

/// One day as the hub draws it. Resolved from `ttcFactsFor` plus the next
/// period's predicted days, which no other resolver names.
class TtcHubDay {
  const TtcHubDay({
    required this.date,
    required this.bleed,
    required this.predictedPeriod,
    required this.fertile,
    required this.ovulation,
    required this.ahead,
    required this.spotting,
    required this.testPositive,
    required this.testNegative,
    required this.otherLog,
    this.due = false,
    this.phase,
  });

  final DateTime date;

  /// A logged bleeding day (the start or a day after it).
  final bool bleed;

  /// One of the next period's expected days (drawn lighter, never solid).
  final bool predictedPeriod;
  final bool fertile;
  final bool ovulation;

  /// The part of THIS cycle the day is in, or null outside it.
  final TtcPhase? phase;

  /// After today: an estimate, so drawn lighter with stripes.
  final bool ahead;

  final bool spotting;
  final bool testPositive;
  final bool testNegative;

  /// Anything else she logged that day (feelings, body, sex, a test…).
  final bool otherLog;

  /// The day the next period is expected to start: "Due" under the number.
  final bool due;

  bool get hasDots => spotting || testPositive || testNegative || otherLog;
}

/// The next period's first day and its expected length, or null.
({DateTime first, int days})? ttcHubNextPeriod() {
  final start = CycleStore.instance.lastPeriodStart;
  final length = TtcStore.instance.today.cycleLength;
  if (start == null || length <= 0) return null;
  final first = DateTime(start.year, start.month, start.day + length);
  final bleed = ttcBleedDaysFor(_dayOnly(start));
  return (first: first, days: bleed.clamp(3, 7));
}

/// The part of the current cycle [d] falls in, from the spans every cycle
/// picture reads.
TtcPhase? _phaseOf(DateTime d) {
  for (final s in ttcCyclePhaseSpans()) {
    if (!d.isBefore(s.firstDay) && !d.isAfter(s.lastDay)) return s.phase;
  }
  return null;
}

/// The NEXT cycle's fertile days, counted from the next period the way the
/// predictions card counts them (`ttcComingUpRows`): ovulation 14 days
/// before the period after next. The day resolver only knows the cycle she
/// is in, so without this the card named 24-29 Oct and the month showed
/// nothing there (the device walk, 2026-10-17).
({DateTime opens, DateTime ov})? ttcHubNextWindow() {
  final next = ttcHubNextPeriod();
  final length = TtcStore.instance.today.cycleLength;
  if (next == null || length <= 0) return null;
  final ovDay = length - TtcChapterEngine.lutealPhaseDays;
  if (ovDay < 1) return null;
  final ov = DateTime(next.first.year, next.first.month,
      next.first.day + ovDay - 1 + ttcWindowClosesAfterOvulation);
  return (
    opens: DateTime(ov.year, ov.month, ov.day - ttcWindowOpensBeforeOvulation),
    ov: DateTime(ov.year, ov.month, ov.day - ttcWindowClosesAfterOvulation),
  );
}

/// Every store a day on the cycle screens is read from, as one thing to
/// listen to (2026-10-18).
///
/// ⚠️ ONE LIST, NEXT TO THE READER. The Cycle companion listened to four
/// stores and the Calendar to six, each list written on its own screen, apart
/// from [ttcHubDay] and `ttcFactsFor`, which read eight. A symptom is saved
/// in [TtcLogStore], which the companion did not listen to, so its month and
/// its "tracked" card kept the old day until she opened the screen again (the
/// user, 2026-10-18). A store added to the reader belongs here, and both
/// screens hear it. Built per call, not cached: tests reset the singletons.
Listenable ttcCycleViewChanges() => Listenable.merge([
      CycleStore.instance,
      TtcStore.instance,
      TtcLogStore.instance,
      TtcAppointmentsStore.instance,
      TtcTreatmentStore.instance,
      FamilyTimeline.instance,
      TtcLang.instance,
      TtcPartnerMode.instance,
    ]);

TtcHubDay ttcHubDay(DateTime day) {
  final d = _dayOnly(day);
  final today = _dayOnly(DateTime.now());
  final f = ttcFactsFor(d);
  final next = ttcHubNextPeriod();
  final nextWindow = next != null && !d.isBefore(next.first)
      ? ttcHubNextWindow()
      : null;
  final inNextWindow = nextWindow != null &&
      !d.isBefore(nextWindow.opens) &&
      !d.isAfter(nextWindow.ov);
  final predicted = next != null &&
      d.isAfter(today) &&
      !d.isBefore(next.first) &&
      d.difference(next.first).inDays < next.days;
  final key = TtcLogStore.dayKey(d);
  final logged = TtcLogStore.instance.valuesOn(kTtcSymptomTracker, key);
  final ov = ttcOvResultOn(d);
  final spotting = logged.any((v) => v.field == 'disch_spotting' && v.value > 0);
  final other = f.loggedTrackers.isNotEmpty &&
      logged.any((v) =>
          v.value > 0 &&
          v.field != 'disch_spotting' &&
          v.field != kTtcOvPositive &&
          v.field != kTtcOvNegative);
  return TtcHubDay(
    date: d,
    bleed: f.isPeriodStart || f.isBleedDay,
    predictedPeriod: predicted || (f.isExpectedPeriod && d.isAfter(today)),
    // ⚠️ "LOW" IS NOT A FERTILE DAY. Every day of a cycle carries a grade,
    // and the first build drew all of them teal (the device walk,
    // 2026-10-17). The calendar's band rule (`TtcFertileBand.isFertile`).
    fertile: (f.fertility != null && f.fertility != FertilityLevel.low) ||
        inNextWindow,
    ovulation: f.isOvulation ||
        (nextWindow != null && _same(d, nextWindow.ov)),
    ahead: d.isAfter(today),
    spotting: spotting,
    testPositive: ov == kTtcOvPositive,
    testNegative: ov == kTtcOvNegative,
    otherLog: other ||
        (f.loggedTrackers.isNotEmpty &&
            f.loggedTrackers.any((t) => t != kTtcSymptomTracker)),
    phase: _phaseOf(d),
    due: f.isExpectedPeriod ||
        (next != null && d.isAfter(today) && _same(d, next.first)),
  );
}

// =============================================================================
//  1. The week strip
// =============================================================================

/// Seven days around the picked one, each in its part of the cycle. A swipe
/// moves a week; the calendar mark at the end opens the month.
class TtcHubWeekStrip extends StatelessWidget {
  const TtcHubWeekStrip({
    super.key,
    required this.selected,
    required this.onPick,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final monday = _sundayOf(selected); // the week's first day
    final today = _dayOnly(DateTime.now());
    return GestureDetector(
      key: const ValueKey('ttc_hub_week'),
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (e) {
        final v = e.primaryVelocity ?? 0;
        if (v.abs() < 200) return;
        onPick(_dayOnly(selected).add(Duration(days: v < 0 ? 7 : -7)));
      },
      // ⚠️ A STRIP THAT SAYS WHAT IT IS (2026-10-17, the user: "make it so
      // that the user can understand"). Seven numbers under a back arrow
      // read as decoration. Now the month sits above them, each day wears
      // its part of the cycle, and one line under them names the picked day
      // and its part, so the colours explain themselves.
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('${_months[selected.month - 1]} ${selected.year}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvFraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ttcTitleInk)),
          ),
          if (!_same(_dayOnly(selected), today))
            PvPress(child: GestureDetector(
              key: const ValueKey('ttc_hub_week_today'),
              onTap: () => onPick(today),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('Back to today',
                    style: ttcBody(12,
                        color: ttcTitleInk, w: FontWeight.w800)),
              ),
            )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: _WeekDay(
                day: ttcHubDay(monday.add(Duration(days: i))),
                label: _weekdays[i],
                isToday: _same(monday.add(Duration(days: i)), today),
                selected: _same(monday.add(Duration(days: i)), selected),
                onTap: () => onPick(monday.add(Duration(days: i))),
              ),
            ),
        ]),
        const SizedBox(height: 10),
        _WeekCaption(day: ttcHubDay(selected)),
      ]),
    );
  }
}

/// "Sat 17 Oct · The waiting days · day 18", under the strip: the picked
/// day, its part of the cycle and its cycle day.
class _WeekCaption extends StatelessWidget {
  const _WeekCaption({required this.day});
  final TtcHubDay day;

  @override
  Widget build(BuildContext context) {
    final start = CycleStore.instance.periodStarts
        .where((s) => !_dayOnly(s).isAfter(day.date))
        .fold<DateTime?>(null, (a, s) => a == null || s.isAfter(a) ? s : a);
    final cycleDay =
        start == null ? null : day.date.difference(_dayOnly(start)).inDays + 1;
    final part = day.bleed
        ? TtcPhase.period
        : day.fertile
            ? TtcPhase.fertileWindow
            : day.phase;
    final words = [
      '${_weekdays[day.date.weekday % 7]} ${_d(day.date)}',
      if (day.predictedPeriod) 'Period expected',
      if (!day.predictedPeriod && part != null) part.label,
      if (cycleDay != null && cycleDay > 0 && !day.predictedPeriod)
        'day $cycleDay',
    ];
    // ⚠️ THE SMALL-MARK COLOUR, WITH A WHITE EDGE (2026-10-18, the user:
    // the dot by "The waiting days" "isn't visible"). It used the phase's big
    // fill, a pale sand, on a hero that is washed in the same sand. `mark` is
    // the same hue a step deeper, made for dots; the white edge keeps it off
    // any hero colour. An expected period is hollow, as it is everywhere.
    // Kept for revert: a 10px disc in ttcLine / periodTint / fill(part).
    return Row(key: const ValueKey('ttc_hub_week_caption'), children: [
      Container(
        key: const ValueKey('ttc_hub_week_caption_dot'),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: day.predictedPeriod
              ? Colors.white
              : part == null
                  ? ttcMuted
                  : TtcCycleColours.mark(part),
          shape: BoxShape.circle,
          border: Border.all(
              color: day.predictedPeriod
                  ? TtcCycleColours.period
                  : Colors.white,
              width: 2),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(_voice(words.join(' · ')),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ttcBody(13, color: ttcTitleInk, w: FontWeight.w700)),
      ),
    ]);
  }
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({
    required this.day,
    required this.label,
    required this.isToday,
    required this.selected,
    required this.onTap,
  });

  final TtcHubDay day;
  final String label;
  final bool isToday;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (fill, ink) = _dayColours(day);
    return Semantics(
      button: true,
      selected: selected,
      label: '${_d(day.date)}${isToday ? ', today' : ''}',
      child: PvPress(child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(isToday ? 'TODAY' : label.toUpperCase(),
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isToday ? TtcCycleColours.today : ttcMuted)),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 38,
            height: 38,
            alignment: Alignment.center,
            // Today and the picked day are both ink (2026-10-17): today is
            // a ring, the picked day a filled disc, the way the home's strip
            // draws them.
            decoration: BoxDecoration(
              color: selected && !isToday ? ttcTitleInk : fill,
              shape: BoxShape.circle,
              border: isToday
                  ? Border.all(
                      color: TtcCycleColours.today, width: selected ? 3 : 1.8)
                  : null,
            ),
            child: Text('${day.date.day}',
                style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: selected && !isToday ? Colors.white : ink)),
          ),
          const SizedBox(height: 5),
          _Dots(day: day),
        ]),
      )),
    );
  }
}

/// The fill and the numeral colour for a day circle.
(Color, Color) _dayColours(TtcHubDay day) {
  if (day.bleed) return (TtcCycleColours.period, Colors.white);
  if (day.ovulation) {
    return day.ahead
        ? (TtcCycleColours.fertile.withValues(alpha: 0.55), Colors.white)
        : (TtcCycleColours.ovulation, Colors.white);
  }
  if (day.fertile) {
    return (
      day.ahead ? TtcCycleColours.fertileTint : TtcCycleColours.fertileLevel(
          // A past or present fertile day is a step stronger than a predicted
          // one.
          FertilityLevel.high),
      TtcCycleColours.fertileInk,
    );
  }
  if (day.predictedPeriod) {
    return (TtcCycleColours.periodTint, TtcCycleColours.periodInk);
  }
  // The quiet parts wear their own soft colour (2026-10-17), so a week in
  // the wait reads as the wait, not as seven blank numbers.
  if (day.phase case final phase?) {
    return (Colors.white.withValues(alpha: 0.75), TtcCycleColours.ink(phase));
  }
  return (Colors.transparent, ttcTitleInk);
}

/// Up to three small dots: spotting, an ovulation test, anything else.
class _Dots extends StatelessWidget {
  const _Dots({required this.day});
  final TtcHubDay day;

  @override
  Widget build(BuildContext context) {
    final dots = <Color>[
      if (day.spotting) TtcCycleColours.period,
      if (day.testPositive) TtcCycleColours.ovulation,
      if (day.testNegative) TtcCycleColours.before,
      if (day.otherLog) TtcCycleColours.logged,
    ];
    return SizedBox(
      height: 5,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < dots.length && i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: dots[i], shape: BoxShape.circle),
          ),
        ],
      ]),
    );
  }
}

// =============================================================================
//  2. The ring
// =============================================================================

/// The one sentence for the middle of the ring, for today: what is happening
/// and how long until the next thing. Never a chance, never "late".
({String small, String big, String part})? ttcHubHeadline() {
  final today = _dayOnly(DateTime.now());
  final cycleDay = TtcStore.instance.today.cycleDay;
  if (cycleDay == null) return null;
  final spans = ttcCyclePhaseSpans();
  final here = spans.where((s) => s.status == TtcSpanStatus.here).firstOrNull;
  final window = ttcCycleWindowSpan();
  final next = ttcHubNextPeriod();
  final small = '${_weekdays[today.weekday % 7].toUpperCase()}, '
      '${_d(today).toUpperCase()} · DAY $cycleDay';
  final part = here?.phase.label ?? '';

  // ⚠️ THE HOME'S OWN SENTENCE FIRST (`ttcCycleHeadline`, 2026-10-07): the
  // home, the hub and the report say one thing in one set of words. Its
  // dates are dropped here; the predictions card right under the ring
  // carries them. The lines below are the fallback for states it leaves
  // to the screen.
  final shared = ttcCycleHeadline();
  if (shared != null) {
    return (
      small: small,
      big: shared.replaceAll(RegExp(r' \(.*\)$'), ''),
      part: part,
    );
  }

  if (ttcHubDay(today).bleed) {
    return (small: small, big: 'Period, day ${here?.dayInto ?? cycleDay}',
        part: part);
  }
  if (window != null &&
      !today.isBefore(window.firstDay) &&
      !today.isAfter(window.lastDay)) {
    final left = window.lastDay.difference(today).inDays;
    return (
      small: small,
      big: left == 0
          ? 'Last fertile day today'
          : 'Fertile days, $left more after today',
      part: TtcPhase.fertileWindow.label,
    );
  }
  if (window != null && today.isBefore(window.firstDay)) {
    final n = window.firstDay.difference(today).inDays;
    return (
      small: small,
      big: n == 1 ? 'Fertile days start tomorrow' : 'Fertile days in $n days',
      part: part,
    );
  }
  if (next != null) {
    final n = next.first.difference(today).inDays;
    return (
      small: small,
      big: n > 1
          ? 'Period in $n days'
          : n == 1
              ? 'Period may start tomorrow'
              : n == 0
                  ? 'Period may start today'
                  : '${-n} ${-n == 1 ? 'day' : 'days'} past the usual length',
      part: part,
    );
  }
  return (small: small, big: 'Day $cycleDay', part: part);
}

/// One cycle as one turn, day 1 at the top. Period and fertile days are drawn
/// on a soft track; the day she is on rides the ring as a bubble.
class TtcHubRing extends StatefulWidget {
  const TtcHubRing({super.key});

  @override
  State<TtcHubRing> createState() => _TtcHubRingState();
}

class _TtcHubRingState extends State<TtcHubRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 750));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion: the ring is simply there.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _c.value = 1;
    } else if (_c.value == 0 && !_c.isAnimating) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spans = ttcCyclePhaseSpans();
    if (spans.isEmpty) return const SizedBox.shrink();
    final length = spans.last.lastCycleDay;
    final window = ttcCycleWindowSpan();
    final here = spans.where((s) => s.status == TtcSpanStatus.here).firstOrNull;
    final todayDay =
        here == null ? null : here.firstCycleDay + here.dayInto! - 1;
    final head = ttcHubHeadline();
    final hereColour =
        here == null ? ttcTitleInk : TtcCycleColours.ink(here.phase);

    // ⚠️ THE RING NAMES ITS PARTS (walk 2026-10-20, approved prototype
    // 2026-10-21). Each stretch carries its name and dates outside the ring,
    // and a legend sits under it, so the first view reads without help.
    // Kept for revert: maxWidth 300, centre padding 76, no labels, no legend.
    final ring = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(builder: (context, box) => AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    key: const ValueKey('ttc_hub_ring'),
                    painter: _HubRingPainter(
                      spans: spans,
                      window: window,
                      length: length,
                      todayDay: todayDay,
                      progress: Curves.easeOutCubic.transform(_c.value),
                      labels: true,
                    ),
                  ),
                ),
                if (head != null)
                  Padding(
                    // Clear of the day bubble, which rides the ring's inner
                    // edge (the device walk, 2026-10-17). Scales with the
                    // ring now that a label band sits outside it.
                    padding: EdgeInsets.symmetric(
                        horizontal: box.maxWidth * 0.29),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(head.small,
                          textAlign: TextAlign.center,
                          style: pvManrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: ttcMuted)),
                      const SizedBox(height: 6),
                      Text(_voice(head.big),
                          key: const ValueKey('ttc_hub_headline'),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: pvFraunces(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.12,
                              letterSpacing: -0.6,
                              color: ttcTitleInk)),
                      if (head.part.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: here == null
                                ? ttcPanel
                                : TtcCycleColours.tint(here.phase),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(_voice(head.part),
                              style: pvManrope(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: hereColour)),
                        ),
                      ],
                    ]),
                  ),
              ],
            ),
          )),
        ),
      ),
    );
    return Column(mainAxisSize: MainAxisSize.min, children: [
      ring,
      const SizedBox(height: 10),
      const _RingLegend(),
      if (ttcHubEstimateNote() case final note?) ...[
        const SizedBox(height: 12),
        _EstimateNote(note: note),
      ],
    ]);
  }
}

/// ⚠️ "IT GETS BETTER AS YOU LOG", SAID PLAINLY (walk 2026-10-20, the user:
/// "they should understand the predictions will get better once we get to
/// know your cycles"). Counts what the estimate stands on, never a chance.
/// Null when a test or temperature set the window: the source line under
/// the predictions already names that sign.
({String bold, String rest})? ttcHubEstimateNote() {
  if (ttcWindowSourceLine()?.fromTest ?? false) return null;
  final n = CycleStore.instance.completedCycles;
  if (n >= 2) {
    return (
      bold: 'Based on your last $n cycles.',
      rest: ' Still an estimate. An ovulation test or your morning '
          'temperature makes it more accurate.',
    );
  }
  return (
    bold: 'An early estimate, from your period dates so far.',
    rest: ' Each period you log makes these dates more accurate.',
  );
}

class _EstimateNote extends StatelessWidget {
  const _EstimateNote({required this.note});
  final ({String bold, String rest}) note;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('ttc_hub_estimate_note'),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        // Kept for revert (2026-10-22, no tinted slab, no lavender):
        //   color: ttcPanel, borderRadius: BorderRadius.circular(14)),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: ttcLine),
            borderRadius: BorderRadius.circular(14)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.trending_up_rounded, size: 16, color: ttcSoft),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: _voice(note.bold),
                    style: ttcBody(12.5,
                        color: ttcTitleInk, w: FontWeight.w800, h: 1.45)),
                TextSpan(text: _voice(note.rest)),
              ]),
              style: ttcBody(12.5, h: 1.45),
            ),
          ),
        ]),
      );
}

/// The ring's key, every stretch by the name the rest of the app uses.
class _RingLegend extends StatelessWidget {
  const _RingLegend();

  @override
  Widget build(BuildContext context) {
    Widget item(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Flexible(child: Text(label, style: ttcBody(11.5, h: 1.2))),
          ],
        );
    return Wrap(
      key: const ValueKey('ttc_hub_ring_legend'),
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 6,
      children: [
        item(TtcCycleColours.period, TtcPhase.period.label),
        item(TtcCycleColours.mark(TtcPhase.beforeWindow),
            TtcPhase.beforeWindow.label),
        item(TtcCycleColours.fertile, TtcPhase.fertileWindow.label),
        item(TtcCycleColours.ovulation, 'Ovulation'),
        item(TtcCycleColours.mark(TtcPhase.afterWindow),
            TtcPhase.afterWindow.label),
      ],
    );
  }
}

class _HubRingPainter extends CustomPainter {
  _HubRingPainter({
    required this.spans,
    required this.window,
    required this.length,
    required this.todayDay,
    required this.progress,
    this.labels = false,
  });

  final List<TtcPhaseSpan> spans;
  final TtcPhaseSpan? window;
  final int length;
  final int? todayDay;
  final double progress;
  final bool labels;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final stroke = size.shortestSide * (labels ? 0.072 : 0.085);
    // A band outside the ring for the names and dates (2026-10-21).
    final band = labels ? size.shortestSide * 0.15 : 0.0;
    final radius =
        (size.shortestSide - stroke) / 2 - stroke * 0.9 - band;
    final rect = Rect.fromCircle(center: centre, radius: radius);
    double angle(double day) => -math.pi / 2 + math.pi * 2 * (day / length);
    final sweepTo = progress * length;

    // The track: the whole cycle, quiet.
    canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..color = const Color(0xFFF1EEF4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke);

    void arc(double from, double to, Color colour, {double width = 1}) {
      final end = math.min(to, sweepTo);
      if (end <= from) return;
      canvas.drawArc(
          rect,
          angle(from),
          angle(end) - angle(from),
          false,
          Paint()
            ..color = colour
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = stroke * width);
    }

    // The two quiet parts, as a soft wash on the track.
    for (final s in spans) {
      if (s.phase == TtcPhase.beforeWindow || s.phase == TtcPhase.afterWindow) {
        arc(s.firstCycleDay - 1 + 0.5, s.lastCycleDay - 0.5,
            TtcCycleColours.tint(s.phase));
      }
    }
    // The fertile days, whole, then the period over them where they share
    // days (it is still the period on a bleeding day).
    final w = window;
    if (w != null) {
      arc(w.firstCycleDay - 1 + 0.5, w.lastCycleDay - 0.5,
          TtcCycleColours.fertile);
    }
    for (final s in spans) {
      if (s.phase == TtcPhase.period) {
        arc(s.firstCycleDay - 1 + 0.5, s.lastCycleDay - 0.5,
            TtcCycleColours.period);
      }
    }
    // Ovulation: a white dot in the deepest teal.
    if (w != null && progress > 0.98) {
      final ov = w.lastCycleDay; // the window closes on ovulation day
      final at = angle(ov - 0.5);
      final p = centre + Offset(math.cos(at) * radius, math.sin(at) * radius);
      canvas.drawCircle(p, stroke * 0.62,
          Paint()..color = TtcCycleColours.ovulation);
      canvas.drawCircle(p, stroke * 0.26, Paint()..color = Colors.white);
    }

    // "Day 1" at the top, so the loop has a beginning.
    final label = TextPainter(
      text: TextSpan(
          text: 'DAY 1',
          style: pvManrope(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: ttcMuted)),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas,
        Offset(centre.dx - label.width / 2, centre.dy - radius - stroke * 1.55));

    // Today: a white bubble on the ring with the day number in it.
    final t = todayDay;
    if (t != null && progress > 0.98) {
      final at = angle(t - 0.5);
      final p = centre + Offset(math.cos(at) * radius, math.sin(at) * radius);
      final r = stroke * 0.95;
      canvas.drawCircle(
          p,
          r + 2,
          Paint()
            ..color = Colors.black.withValues(alpha: 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawCircle(p, r, Paint()..color = Colors.white);
      canvas.drawCircle(
          p,
          r,
          Paint()
            ..color = TtcCycleColours.today
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2);
      final n = TextPainter(
        text: TextSpan(
            text: '$t',
            style: pvManrope(
                fontSize: r * 0.9,
                fontWeight: FontWeight.w800,
                color: TtcCycleColours.today)),
        textDirection: TextDirection.ltr,
      )..layout();
      n.paint(canvas, p - Offset(n.width / 2, n.height / 2));
    }

    if (labels && progress > 0.98) {
      _paintLabels(canvas, size, centre, radius + stroke / 2 + 8, angle);
    }
  }

  /// Name and dates for each stretch, just outside its middle. A label that
  /// would sit on top of the one before is pushed outward, and every label
  /// is kept inside the card's padding.
  void _paintLabels(Canvas canvas, Size size, Offset centre, double r,
      double Function(double) angle) {
    String d(DateTime x) => '${x.day} ${_mon[x.month - 1]}';
    String range(DateTime a, DateTime b) =>
        a.month == b.month ? '${a.day}–${d(b)}' : '${d(a)} – ${d(b)}';
    final items = <(double, String, String, Color)>[];
    for (final s in spans) {
      if (s.phase == TtcPhase.fertileWindow) continue;
      final mid = (s.firstCycleDay - 1 + s.lastCycleDay) / 2;
      final name = switch (s.phase) {
        TtcPhase.period => 'Period',
        TtcPhase.beforeWindow => 'Before fertile',
        TtcPhase.afterWindow => 'Waiting days',
        TtcPhase.fertileWindow => '',
      };
      final ink = switch (s.phase) {
        TtcPhase.period => TtcCycleColours.periodInk,
        _ => TtcCycleColours.quietInk,
      };
      items.add((mid, name, range(s.firstDay, s.lastDay), ink));
    }
    final w = window;
    if (w != null) {
      items.add((
        (w.firstCycleDay - 1 + w.lastCycleDay - 1) / 2,
        'Fertile days',
        range(w.firstDay, w.lastDay),
        TtcCycleColours.fertileInk,
      ));
      items.add((
        w.lastCycleDay - 0.2,
        'Ovulation',
        '~${d(w.lastDay)}',
        TtcCycleColours.ovulation,
      ));
    }
    if (spans.isNotEmpty) {
      final next = spans.last.lastDay.add(const Duration(days: 1));
      items.add((length - 0.6, 'Next period', '~${d(next)}',
          TtcCycleColours.periodInk));
    }
    items.sort((a, b) => a.$1.compareTo(b.$1));
    final placed = <Rect>[];
    for (final (day, name, dates, ink) in items) {
      if (name.isEmpty) continue;
      final tp = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          TextSpan(
              text: '$name\n',
              style: pvManrope(
                  fontSize: 9.5, fontWeight: FontWeight.w800, color: ink)),
          TextSpan(
              text: dates,
              style: pvManrope(
                  fontSize: 9, fontWeight: FontWeight.w600, color: ttcSoft)),
        ]),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 74);
      final a = angle(day);
      var rr = r;
      late Rect rect;
      for (var tries = 0; tries < 4; tries++) {
        final p = centre + Offset(math.cos(a) * rr, math.sin(a) * rr);
        // Anchor by side: to the right of the ring the label grows out to
        // the right, on the left out to the left, top and bottom centred.
        final c = math.cos(a), sn = math.sin(a);
        final dx = c > 0.35 ? 0.0 : (c < -0.35 ? -tp.width : -tp.width / 2);
        final dy = sn > 0.35 ? 0.0 : (sn < -0.35 ? -tp.height : -tp.height / 2);
        rect = Rect.fromLTWH(p.dx + dx, p.dy + dy, tp.width, tp.height);
        if (!placed.any((o) => o.inflate(2).overlaps(rect))) break;
        rr += 12;
      }
      // Never past the card's inner padding.
      final shift = Offset(
          rect.left < -14
              ? -14 - rect.left
              : (rect.right > size.width + 14 ? size.width + 14 - rect.right : 0),
          0);
      rect = rect.shift(shift);
      placed.add(rect);
      tp.paint(canvas, rect.topLeft);
    }
  }

  static const _mon = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  bool shouldRepaint(covariant _HubRingPainter old) =>
      old.progress != progress ||
      old.length != length ||
      old.todayDay != todayDay ||
      old.spans != spans;
}

// =============================================================================
//  3. Predictions, and where they come from
// =============================================================================

class TtcHubPredictions extends StatelessWidget {
  const TtcHubPredictions({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = ttcComingUpRows();
    final source = ttcWindowSourceLine();
    final overlap = ttcCycleWindowStartsInPeriod();
    if (rows.isEmpty) return const SizedBox.shrink();
    return _HubCard(
      key: const ValueKey('ttc_hub_predictions'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Cycle predictions',
            style: pvFraunces(
                fontSize: 19, fontWeight: FontWeight.w600, color: ttcTitleInk)),
        const SizedBox(height: 6),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: ttcLine),
          _PredictionRow(
            phase: rows[i].phase,
            label: _voice(rows[i].label),
            dates: rows[i].dates,
            when: rows[i].when,
            ovulation: rows[i].ovulation,
          ),
        ],
        if (overlap) ...[
          const SizedBox(height: 8),
          Text(
              _voice('With a shorter cycle, your fertile days can begin '
                  'before your period ends. Both are shown.'),
              style: ttcBody(12.5, h: 1.45)),
        ],
        if (source != null) ...[
          const SizedBox(height: 10),
          _SourceLine(source: source),
        ],
      ]),
    );
  }
}

class _PredictionRow extends StatelessWidget {
  const _PredictionRow({
    required this.phase,
    required this.label,
    required this.dates,
    required this.when,
    this.ovulation = false,
  });

  final TtcPhase phase;
  final String label;
  final String dates;
  final String when;
  final bool ovulation;

  @override
  Widget build(BuildContext context) {
    final colour =
        ovulation ? TtcCycleColours.ovulation : TtcCycleColours.fill(phase);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        // A ring in the part's colour (Withings' "Cycle predictions").
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colour, width: ovulation ? 6 : 3.5),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ttcBody(14, color: ttcTitleInk, w: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(dates,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ttcBody(13, color: ttcSoft)),
          ]),
        ),
        const SizedBox(width: 8),
        Text(when,
            style: ttcBody(12.5,
                color: TtcCycleColours.ink(phase), w: FontWeight.w800)),
      ]),
    );
  }
}

/// "Estimated from your period dates", or "Based on your positive ovulation
/// test on 1 Oct · Change". The line the user went looking for (2026-10-17).
class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.source});
  final ({String line, bool fromTest}) source;

  @override
  Widget build(BuildContext context) {
    final him = TtcPartnerMode.instance.on;
    return Row(
      key: const ValueKey('ttc_hub_source'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
              source.fromTest
                  ? Icons.science_outlined
                  : Icons.event_note_outlined,
              size: 15,
              color: ttcSoft),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: _voice(source.line)),
              if (source.fromTest && !him)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: PvPress(child: GestureDetector(
                    key: const ValueKey('ttc_hub_source_change'),
                    onTap: () => openTtcOvulationTests(context),
                    child: Text(' · Change',
                        style: ttcBody(12.5,
                            color: ttcTitleInk, w: FontWeight.w800)),
                  )),
                ),
            ]),
            style: ttcBody(12.5, h: 1.45),
          ),
        ),
      ],
    );
  }
}

void openTtcOvulationTests(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ttc/ovulation'),
      builder: (_) => const TtcOvulationTestsScreen(),
    ));

// =============================================================================
//  4. The month
// =============================================================================

/// One month, paged sideways, the period and the fertile days as capsules and
/// what she logged as dots. The hub and the Calendar screen both draw it.
class TtcHubMonth extends StatefulWidget {
  const TtcHubMonth({
    super.key,
    required this.selected,
    required this.onPick,
    this.titleKey = const ValueKey('ttc_hub_month_title'),
  });

  final DateTime selected;
  final ValueChanged<DateTime> onPick;
  final Key titleKey;

  /// How far she can page, either way.
  static const int span = 12;

  @override
  State<TtcHubMonth> createState() => _TtcHubMonthState();
}

class _TtcHubMonthState extends State<TtcHubMonth> {
  late final DateTime _origin;
  late final PageController _pages;
  late int _page;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _origin = DateTime(now.year, now.month);
    _page = TtcHubMonth.span + _offset(widget.selected);
    _pages = PageController(initialPage: _page);
  }

  int _offset(DateTime d) =>
      (d.year - _origin.year) * 12 + d.month - _origin.month;

  @override
  void didUpdateWidget(TtcHubMonth old) {
    super.didUpdateWidget(old);
    // A pick in the week strip that lands in another month follows here.
    final want = TtcHubMonth.span + _offset(widget.selected);
    if (want != _page && _pages.hasClients) {
      _page = want.clamp(0, TtcHubMonth.span * 2);
      _pages.animateToPage(_page,
          duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  DateTime _monthAt(int page) =>
      DateTime(_origin.year, _origin.month + page - TtcHubMonth.span);

  void _step(int by) {
    final to = (_page + by).clamp(0, TtcHubMonth.span * 2);
    _pages.animateToPage(to,
        duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final month = _monthAt(_page);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text('${_months[month.month - 1]} ${month.year}',
              key: widget.titleKey,
              style: pvFraunces(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  color: ttcTitleInk)),
        ),
        _Arrow(
            key: const ValueKey('ttc_hub_month_back'),
            icon: Icons.chevron_left_rounded,
            label: 'Previous month',
            onTap: _page > 0 ? () => _step(-1) : null),
        const SizedBox(width: 6),
        _Arrow(
            key: const ValueKey('ttc_hub_month_forward'),
            icon: Icons.chevron_right_rounded,
            label: 'Next month',
            onTap: _page < TtcHubMonth.span * 2 ? () => _step(1) : null),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        for (final w in _weekdays)
          Expanded(
            child: Center(
              child: Text(w.substring(0, 1),
                  style: pvManrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: ttcMuted)),
            ),
          ),
      ]),
      const SizedBox(height: 6),
      SizedBox(
        height: _kRow * 6,
        child: PageView.builder(
          key: const ValueKey('ttc_hub_month_pages'),
          controller: _pages,
          itemCount: TtcHubMonth.span * 2 + 1,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (context, i) => _MonthPage(
            month: _monthAt(i),
            selected: widget.selected,
            onPick: widget.onPick,
          ),
        ),
      ),
      const SizedBox(height: 10),
      const _MonthKey(),
    ]);
  }
}

const double _kRow = 50;

class _Arrow extends StatelessWidget {
  const _Arrow(
      {super.key, required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(side: BorderSide(color: ttcLine)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(icon,
                  size: 22, color: onTap == null ? ttcLine : ttcTitleInk),
            ),
          ),
        ),
      );
}

class _MonthPage extends StatelessWidget {
  const _MonthPage({
    required this.month,
    required this.selected,
    required this.onPick,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final start = _sundayOf(first);
    final today = _dayOnly(DateTime.now());
    final days = [
      for (var i = 0; i < 42; i++) ttcHubDay(start.add(Duration(days: i))),
    ];
    return Column(children: [
      for (var r = 0; r < 6; r++)
        SizedBox(
          height: _kRow,
          child: Row(children: [
            for (var c = 0; c < 7; c++)
              Expanded(
                child: _MonthCell(
                  day: days[r * 7 + c],
                  before: c > 0 ? days[r * 7 + c - 1] : null,
                  after: c < 6 ? days[r * 7 + c + 1] : null,
                  inMonth: days[r * 7 + c].date.month == month.month,
                  isToday: _same(days[r * 7 + c].date, today),
                  selected: _same(days[r * 7 + c].date, selected),
                  onTap: () => onPick(days[r * 7 + c].date),
                ),
              ),
          ]),
        ),
    ]);
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.day,
    required this.before,
    required this.after,
    required this.inMonth,
    required this.isToday,
    required this.selected,
    required this.onTap,
  });

  final TtcHubDay day;
  final TtcHubDay? before;
  final TtcHubDay? after;
  final bool inMonth;
  final bool isToday;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(999);
    BorderRadius ends(bool joinLeft, bool joinRight) => BorderRadius.only(
          topLeft: joinLeft ? Radius.zero : r,
          bottomLeft: joinLeft ? Radius.zero : r,
          topRight: joinRight ? Radius.zero : r,
          bottomRight: joinRight ? Radius.zero : r,
        );

    // The fertile capsule: wider, behind; the period capsule over it.
    Widget? fertile;
    if (day.fertile) {
      final colour = day.ahead
          ? TtcCycleColours.fertileTint
          : TtcCycleColours.fertileLevel(FertilityLevel.high);
      fertile = Container(
        key: const ValueKey('ttc_hub_fertile_band'),
        width: double.infinity,
        height: 38,
        decoration: BoxDecoration(
          color: colour,
          borderRadius:
              ends(before?.fertile ?? false, after?.fertile ?? false),
        ),
        // ⚠️ NO STRIPES (the user, 2026-10-21: "everything is an estimate,
        // so this adds a layer of repetitiveness"). The lighter tint still
        // tells days ahead from days gone. Kept for revert:
        //   child: day.ahead ? ClipRRect(borderRadius: ends(...),
        //       child: const CustomPaint(
        //           key: ValueKey('ttc_cal_estimate_stripes'),
        //           painter: TtcEstimateStripes(), size: Size.infinite))
        //     : null,
      );
    } else if (!day.bleed &&
        !day.predictedPeriod &&
        (day.phase == TtcPhase.beforeWindow ||
            day.phase == TtcPhase.afterWindow)) {
      // The two quiet stretches get their soft wash too (2026-10-21), so the
      // month names every part of the cycle the ring does.
      bool joins(TtcHubDay? o) =>
          o != null &&
          o.phase == day.phase &&
          !o.fertile &&
          !o.bleed &&
          !o.predictedPeriod;
      fertile = Container(
        key: const ValueKey('ttc_hub_quiet_band'),
        width: double.infinity,
        height: 38,
        decoration: BoxDecoration(
          color: TtcCycleColours.tint(day.phase!),
          borderRadius: ends(joins(before), joins(after)),
        ),
      );
    }
    Widget? period;
    if (day.bleed || day.predictedPeriod) {
      final joinL = (before?.bleed ?? false) == day.bleed &&
          ((before?.bleed ?? false) || (before?.predictedPeriod ?? false));
      final joinR = (after?.bleed ?? false) == day.bleed &&
          ((after?.bleed ?? false) || (after?.predictedPeriod ?? false));
      period = Container(
        width: double.infinity,
        height: 30,
        margin: EdgeInsets.only(left: joinL ? 0 : 3, right: joinR ? 0 : 3),
        decoration: BoxDecoration(
          color: day.bleed ? TtcCycleColours.period : TtcCycleColours.periodTint,
          borderRadius: ends(joinL, joinR),
        ),
      );
    }
    final ink = day.bleed
        ? Colors.white
        : day.predictedPeriod
            ? TtcCycleColours.periodInk
            : day.fertile
                ? TtcCycleColours.fertileInk
                : ttcTitleInk;

    return Opacity(
      opacity: inMonth ? 1 : 0.35,
      child: PvPress(child: GestureDetector(
        key: ValueKey('ttc_hub_day_${TtcLogStore.dayKey(day.date)}'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          button: true,
          selected: selected,
          label: _d(day.date),
          child: Column(children: [
            // The full cell width, or the stack sizes to the numeral and
            // the bands shrink to slivers (the device walk, 2026-10-17).
            SizedBox(
              height: 40,
              width: double.infinity,
              child: Stack(alignment: Alignment.center, children: [
                if (fertile != null) Positioned.fill(child: Center(child: fertile)),
                if (period != null) Positioned.fill(child: Center(child: period)),
                if (day.ovulation)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: day.ahead
                          ? Colors.white
                          : TtcCycleColours.ovulation,
                      border: Border.all(
                          color: TtcCycleColours.ovulation, width: 2),
                    ),
                  ),
                if (selected || isToday)
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: TtcCycleColours.today,
                          width: selected ? 2.8 : 1.6),
                    ),
                  ),
                Text('${day.date.day}',
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: day.ovulation && !day.ahead
                            ? Colors.white
                            : ink)),
              ]),
            ),
            const SizedBox(height: 1),
            if (day.due && !day.hasDots)
              Text('Due',
                  key: const ValueKey('ttc_cal_due_mark'),
                  style: pvManrope(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: TtcCycleColours.periodInk))
            else
              _Dots(day: day),
          ]),
        ),
      )),
    );
  }
}

class _MonthKey extends StatelessWidget {
  const _MonthKey();

  @override
  Widget build(BuildContext context) {
    Widget key(Widget swatch, String label) =>
        Row(mainAxisSize: MainAxisSize.min, children: [
          swatch,
          const SizedBox(width: 6),
          // Flexible (2026-10-18): the estimate key is a whole phrase, and
          // with large text it wraps instead of running off the card.
          Flexible(
            child: Text(_voice(label),
                style: ttcBody(11.5, color: ttcMuted, w: FontWeight.w700)),
          ),
        ]);
    Widget pill(Color c) => Container(
          width: 16,
          height: 10,
          decoration:
              BoxDecoration(color: c, borderRadius: BorderRadius.circular(99)),
        );
    Widget dot(Color c) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle));
    // ⚠️ THE ONLY KEY ON THE CALENDAR (2026-10-18, the user: "same above and
    // below"). The Calendar screen kept its own key under this one, so the
    // marks were named twice. That key's rules move here: a mark is named only
    // when this calendar can draw it. A clinic path draws no fertile days and
    // counts to no period, and an engine that refused to estimate draws no
    // window, so their keys would promise colours the grid never shows.
    final store = TtcStore.instance;
    final behaviour = store.behaviour;
    final window = behaviour.showsFertilityWindow &&
        const TtcChapterEngine().estimatedOvulationDay(store.state()) != null;
    return Wrap(
      key: const ValueKey('ttc_hub_month_key'),
      spacing: 14,
      runSpacing: 8,
      children: [
        key(pill(TtcCycleColours.period), 'Period'),
        if (behaviour.countsToPeriod)
          key(pill(TtcCycleColours.periodTint), 'Expected period'),
        if (window) ...[
          key(pill(TtcCycleColours.fertileLevel(FertilityLevel.high)),
              'Fertile days'),
          key(
              Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                      color: TtcCycleColours.ovulation,
                      shape: BoxShape.circle)),
              'Ovulation'),
          // Kept for revert (2026-10-21, no stripes):
          // key(ClipRRect(... TtcEstimateStripes() ...), kTtcCalendarEstimateKey),
        ],
        key(pill(TtcCycleColours.tint(TtcPhase.beforeWindow)),
            TtcPhase.beforeWindow.label),
        key(pill(TtcCycleColours.tint(TtcPhase.afterWindow)),
            TtcPhase.afterWindow.label),
        key(dot(TtcCycleColours.period), 'Spotting'),
        key(dot(TtcCycleColours.ovulation), 'Positive test'),
        key(dot(TtcCycleColours.logged), 'Logged'),
      ],
    );
  }
}

// =============================================================================
//  5. What was tracked on the picked day
// =============================================================================

class TtcHubTracked extends StatelessWidget {
  const TtcHubTracked({super.key, required this.day});
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final d = _dayOnly(day);
    final hub = ttcHubDay(d);
    final start = CycleStore.instance.periodStarts
        .where((s) => !_dayOnly(s).isAfter(d))
        .fold<DateTime?>(null, (a, s) => a == null || s.isAfter(a) ? s : a);
    final cycleDay = start == null ? null : d.difference(_dayOnly(start)).inDays + 1;
    final key = TtcLogStore.dayKey(d);
    final logged = TtcLogStore.instance
        .valuesOn(kTtcSymptomTracker, key)
        .where((v) => v.value > 0)
        .map((v) => ttcSymptomById(v.field))
        .whereType<TtcSymptom>()
        .toList();
    final him = TtcPartnerMode.instance.on;
    final today = _dayOnly(DateTime.now());

    final rows = <(Color, String, String)>[
      if (hub.bleed)
        (TtcCycleColours.period, 'Period', cycleDay == null ? '' : 'Day $cycleDay of the cycle'),
      if (hub.predictedPeriod)
        (TtcCycleColours.periodTint, 'Period expected', 'An estimate'),
      if (hub.ovulation)
        (TtcCycleColours.ovulation, d.isAfter(today) ? 'Ovulation, estimated' : 'Ovulation, estimated', ''),
      if (hub.fertile && !hub.ovulation)
        (TtcCycleColours.fertile, 'A fertile day', d.isAfter(today) ? 'An estimate' : ''),
      if (hub.spotting) (TtcCycleColours.period, 'Spotting', 'Does not start a new cycle'),
      if (hub.testPositive) (TtcCycleColours.ovulation, 'Ovulation test: positive', ''),
      if (hub.testNegative) (TtcCycleColours.before, 'Ovulation test: negative', ''),
      for (final s in logged)
        if (s.id != 'disch_spotting' &&
            s.id != kTtcOvPositive &&
            s.id != kTtcOvNegative)
          (TtcCycleColours.logged, ttcGroupOf(s.id)?.title ?? 'Logged', s.label),
    ];

    return _HubCard(
      key: const ValueKey('ttc_hub_tracked'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(
                _same(d, today) ? 'Today, ${_d(d)}' : 'Tracked on ${_d(d)}',
                style: pvFraunces(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: ttcTitleInk)),
          ),
          if (cycleDay != null && cycleDay > 0)
            Text('Cycle day $cycleDay',
                style: ttcBody(12.5, color: ttcMuted, w: FontWeight.w800)),
        ]),
        const SizedBox(height: 8),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
                d.isAfter(today)
                    ? 'Nothing is expected on this day.'
                    : 'Nothing logged on this day.',
                style: ttcBody(13.5)),
          ),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: r.$1, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: r.$2,
                      style: ttcBody(14,
                          color: ttcTitleInk, w: FontWeight.w800)),
                  if (r.$3.isNotEmpty)
                    TextSpan(text: '  ${r.$3}', style: ttcBody(13)),
                ])),
              ),
            ]),
          ),
        if (!him && !d.isAfter(today)) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('ttc_hub_log'),
              style: FilledButton.styleFrom(
                backgroundColor: ttcTitleInk,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
                shape: const StadiumBorder(),
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  settings: const RouteSettings(name: 'ttc/log'),
                  builder: (_) => TtcSymptomLogScreen(day: d))),
              child: Text(
                  rows.isEmpty ? 'Log this day' : 'Add or change',
                  style: pvManrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
          // ⚠️ T2 K1 (2026-10-29): logging a period took four taps or more,
          // because "Log this day" opens the symptom log and the hub had no
          // period action. This opens the period sheet already on the picked
          // day (today, unless she picked another), so it is one tap and
          // Save. Not on a day that already starts a period.
          if (!CycleStore.instance.periodStarts.any((s) =>
              s.year == d.year && s.month == d.month && s.day == d.day)) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: const ValueKey('ttc_hub_period_started'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ttcTitleInk,
                  side: const BorderSide(color: ttcLine),
                  minimumSize: const Size.fromHeight(46),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => showTtcPeriodLogSheet(context, initial: d),
                child: Text(
                    d.year == today.year &&
                            d.month == today.month &&
                            d.day == today.day
                        ? 'My period started today'
                        : 'My period started this day',
                    style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: ttcTitleInk)),
              ),
            ),
          ],
        ],
      ]),
    );
  }
}

// =============================================================================
//  Shared
// =============================================================================

/// A hub card: white, a hairline, a soft lift.
class _HubCard extends StatelessWidget {
  const _HubCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ttcLine),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4)),
          ],
        ),
        child: child,
      );
}

/// A white hub card around any child, for the screen's other blocks.
class TtcHubCard extends StatelessWidget {
  const TtcHubCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => _HubCard(child: child);
}
