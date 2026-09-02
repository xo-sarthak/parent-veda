// =============================================================================
//  The cycle report's three quiet states
// -----------------------------------------------------------------------------
//  Built from turn 2 of the "Cycle Report" design project. The main state — a
//  cycle with a ring, a calendar and four stops — was turn 1 and ships already.
//  These are the three where there is no cycle to draw.
//
//  ⚠️ THEY ARE NOT EDGE CASES. Someone who has just installed the app sees
//  `noPeriod`. Someone three dates in with one long gap sees `noEstimate`.
//  Anyone on IUI or IVF sees `clinicHeld` every single time they open it. A
//  report that treats these as error paths is a report that is broken for most
//  of the people looking at it.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE TWO REFUSALS LOOK ALIKE AND MUST NOT SOUND ALIKE
//  ---------------------------------------------------------------------------
//
//  Both withhold the phases. The reasons have nothing in common:
//
//    · **No estimate** is *we cannot say*. One gap is long enough to be a month
//      she did not log, and averaging it in moves the fertile days by over a
//      week. This state exists because the app once printed "ovulation around
//      day 40" on a device off exactly that history.
//    · **Clinic-held** is *it is not ours to say*. Her data may be perfect; a
//      clinic is scanning her and choosing the dates, and our calculation sits
//      second from the bottom of the truth hierarchy — well below a treating
//      clinician.
//
//  One is about her data. The other is emphatically not, and phrasing it as a
//  data problem would blame a woman's logging for her clinic's involvement.
//
//  ⚠️ AND BOTH STILL SHOW HER OWN DAYS. Refusing to interpret is not refusing
//  to show. The grid renders with no phase colour at all — which is the refusal
//  made structural rather than a caption asking her to ignore the colours.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_care_pathway.dart';
import '../../ttc/ttc_cycle_report.dart';
import '../../ttc/ttc_store.dart';
import 'ttc_common.dart';
import 'ttc_cycle_companion.dart' show ttcShortDate;

/// Everything the three states need that the report itself does not carry.
///
/// ⚠️ GATHERED ONCE AND PASSED DOWN, rather than each card reaching into the
/// stores. Two of these numbers are used by both refusals and one of them —
/// the longest gap — is the entire reason `noEstimate` exists, so it is worth
/// having in one place where it can be read rather than recomputed.
class TtcReportFacts {
  const TtcReportFacts({
    required this.periods,
    required this.since,
    required this.shortestGap,
    required this.longestGap,
    required this.usualBleedDays,
  });

  factory TtcReportFacts.read() {
    final starts = [...CycleStore.instance.periodStarts]..sort();

    // ⚠️ EVERY GAP, NOT `cycleLengths`. That getter drops anything outside the
    // plausibility window, which is correct for an average and exactly wrong
    // here: the 46-day gap it discards is the thing this screen is explaining.
    final gaps = <int>[
      for (var i = 1; i < starts.length; i++)
        starts[i].difference(starts[i - 1]).inDays,
    ];

    final bleeds = <int>[
      for (final s in starts)
        if (CycleStore.instance.bleedDaysFor(s) case final d?)
          if (d != kBleedStillOn && d > 0) d,
    ];

    return TtcReportFacts(
      periods: starts.length,
      since: starts.isEmpty ? null : starts.first,
      shortestGap: gaps.isEmpty ? null : gaps.reduce((a, b) => a < b ? a : b),
      longestGap: gaps.isEmpty ? null : gaps.reduce((a, b) => a > b ? a : b),
      usualBleedDays: bleeds.isEmpty
          ? null
          : (bleeds.reduce((a, b) => a + b) / bleeds.length).round(),
    );
  }

  final int periods;
  final DateTime? since;
  final int? shortestGap;
  final int? longestGap;

  /// Null until she has answered the bleed-length question at least once.
  final int? usualBleedDays;
}

// =============================================================================
//  Nothing logged
// =============================================================================

/// The screen most people meet first.
///
/// ⚠️ IT TEACHES RATHER THAN APOLOGISES. The old empty state said the page
/// would fill in and left it there. This one draws the ring she is going to
/// get — empty, dashed, with the four stretches named beside it — and then says
/// what each of the first three dates buys her. An empty state that shows the
/// shape of the thing is an advertisement; one that only reports its own
/// emptiness is an error message in a nicer font.
class TtcReportEmptyBody extends StatelessWidget {
  const TtcReportEmptyBody({super.key, required this.onLog});

  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ttcSectionTitle('What this page becomes'),
          TtcCard(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('A picture of one month', style: ttcJakarta(16)),
                  const SizedBox(height: 8),
                  Text(
                      'A cycle is the time from the first day of one period to '
                      'the day before the next. Drawn as a ring, it splits '
                      'into four stretches. This is the shape — yours is empty '
                      'until you enter a date.',
                      style: ttcBody(13, h: 1.55)),
                  const SizedBox(height: 20),
                  const _EmptyRing(),
                  const SizedBox(height: 20),
                  for (final line in const [
                    'Period · the bleeding days',
                    'Before your window · nothing to watch for yet',
                    'Fertile days · when a pregnancy can begin',
                    'The waiting days · until the next period',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(children: [
                        // ⚠️ DASHED AND UNCOLOURED, LIKE THE RING. Colouring the
                        // legend of a cycle she has not logged would promise
                        // four stretches the page cannot yet place.
                        CustomPaint(
                          size: const Size(11, 11),
                          painter: _DashedSquare(),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(line,
                              style: ttcBody(12.5, color: ttcMuted)),
                        ),
                      ]),
                    ),
                ]),
          ),
          const SizedBox(height: 24),

          ttcSectionTitle('What one date gives you'),
          TtcCard(
            child: Column(children: [
              _Step(
                n: 1,
                title: 'Today gets a name',
                body: 'Enter the first day of your last period and this page '
                    'tells you which day of the cycle you are on.',
              ),
              ttcDivider(),
              _Step(
                n: 2,
                title: 'The four stretches appear',
                body: 'After two periods we can mark your fertile days on the '
                    'ring instead of describing them in words.',
              ),
              ttcDivider(),
              _Step(
                n: 3,
                title: 'One page to carry to a doctor',
                body: 'Your dates and how long your cycles run, in one place, '
                    'instead of remembered at the appointment.',
                last: true,
              ),
            ]),
          ),
          const SizedBox(height: 24),

          ttcSectionTitle('Your dates'),
          const TtcReportFact(
            label: 'Period dates',
            placeholder:
                'The days you mark as bleeding will be listed here, newest '
                'first.',
          ),
          const SizedBox(height: 10),
          const TtcReportFact(
            label: 'How long your cycles run',
            placeholder:
                'Two periods are enough for a first number. Three make it '
                'steadier.',
          ),
          const SizedBox(height: 22),

          TtcReportAction(
              label: 'Enter the first day of your period', onTap: onLog),
          const SizedBox(height: 10),
          TtcReportAction(
              label: 'My period was earlier — add a past date',
              muted: true,
              onTap: onLog),
          const SizedBox(height: 12),
          Text(
              'You can change or remove any date later. Nothing here is shared '
              'without you asking.',
              style: ttcBody(12, color: ttcMuted, h: 1.5)),
        ],
      );
}

class _EmptyRing extends StatelessWidget {
  const _EmptyRing();

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: 226,
          height: 226,
          child: Stack(alignment: Alignment.center, children: [
            const Positioned.fill(child: CustomPaint(painter: _RingOutline())),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Empty', style: ttcFraunces(22, color: ttcMuted)),
              const SizedBox(height: 3),
              Text('no days entered', style: ttcBody(11.5, color: ttcMuted)),
            ]),
          ]),
        ),
      );
}

class _RingOutline extends CustomPainter {
  const _RingOutline();

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 14;

    canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..color = ttcLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = 15);

    // ⚠️ A DOTTED TRACK, NOT A GREY ONE. A solid ring reads as a cycle of
    // length zero; a dotted one reads as a shape waiting to be filled, which
    // is the honest description of the state.
    final dot = Paint()
      ..color = ttcMuted.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    const step = 0.16;
    for (var a = -1.5708; a < 4.7124; a += step) {
      canvas.drawArc(Rect.fromCircle(center: centre, radius: radius), a, 0.012,
          false, dot);
    }

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
        Offset(centre.dx - label.width / 2, centre.dy - radius - 24));
  }

  @override
  bool shouldRepaint(covariant _RingOutline old) => false;
}

class _DashedSquare extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
        const Radius.circular(3));
    final paint = Paint()
      ..color = ttcMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // Four short strokes rather than a path effect: Flutter has no dashed
    // stroke, and three lines of manual dashing beats a package.
    final path = Path()..addRRect(r);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 2), paint);
        d += 4;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedSquare old) => false;
}

class _Step extends StatelessWidget {
  const _Step({
    required this.n,
    required this.title,
    required this.body,
    this.last = false,
  });

  final int n;
  final String title;
  final String body;
  final bool last;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: n == 1 ? 0 : 14, bottom: last ? 0 : 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ttcLine),
            ),
            child: Text('$n', style: ttcFraunces(14, color: ttcSoft)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ttcJakarta(14)),
                  const SizedBox(height: 3),
                  Text(body, style: ttcBody(12.5, h: 1.5)),
                ]),
          ),
        ]),
      );
}

// =============================================================================
//  The two refusals
// =============================================================================

/// Shared by `noEstimate` and `clinicHeld`: the reason, her days, her rhythm.
///
/// ⚠️ ONE BODY, TWO ARGUMENTS. The states differ in what they SAY and not in
/// what they show, so the words are parameters and the structure is not. Two
/// near-identical widgets is how the day grid ends up drawn one way on one
/// refusal and another way on the other.
class TtcReportRefusalBody extends StatelessWidget {
  const TtcReportRefusalBody({
    super.key,
    required this.report,
    required this.facts,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.body2,
    required this.actionLabel,
    required this.onAction,
    required this.footLabel,
    required this.onFoot,
    required this.footNote,
    this.note,
  });

  final TtcCycleReport report;
  final TtcReportFacts facts;
  final String eyebrow;
  final String title;
  final String body;
  final String body2;
  final String actionLabel;
  final VoidCallback onAction;
  final String footLabel;
  final VoidCallback onFoot;
  final String footNote;

  /// The quiet line under the action, where one state has more to say.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final since = facts.since;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ttcSectionTitle(eyebrow),
        TtcCard(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ttcJakarta(16)),
                const SizedBox(height: 8),
                Text(body, style: ttcBody(13, h: 1.55)),
                const SizedBox(height: 12),
                Text(body2, style: ttcBody(13, h: 1.55)),
                const SizedBox(height: 18),
                TtcReportAction(label: actionLabel, onTap: onAction),
                if (note != null) ...[
                  const SizedBox(height: 10),
                  Text(note!, style: ttcBody(12, color: ttcMuted, h: 1.5)),
                ],
              ]),
        ),
        const SizedBox(height: 24),

        ttcSectionTitle('The days you logged'),
        TtcCard(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    report.start == null || report.end == null
                        ? 'In order. Filled days are days you entered '
                            'something.'
                        : '${ttcShortDate(report.start!)} to '
                            '${ttcShortDate(report.end!)}, in order. Filled '
                            'days are days you entered something.',
                    style: ttcBody(12.5, h: 1.5)),
                const SizedBox(height: 14),
                _PlainGrid(report: report),
                const SizedBox(height: 14),
                Wrap(spacing: 18, runSpacing: 8, children: [
                  _Key(
                      alpha: 0.34,
                      label: 'Period you marked'),
                  _Key(alpha: 0.12, label: 'Something else logged'),
                ]),
              ]),
        ),
        const SizedBox(height: 24),

        // ⚠️ HER RHYTHM SURVIVES BOTH REFUSALS. These describe her history, not
        // this cycle, and they are exactly as true on the day the estimate is
        // withheld as they were the day before. Withholding them too would be
        // the app sulking.
        ttcSectionTitle('Your rhythm so far'),
        TtcReportFact(
          label: 'Periods recorded',
          value: since == null
              ? '${facts.periods}'
              : '${facts.periods} · since ${_month(since)}',
        ),
        const SizedBox(height: 10),
        TtcReportFact(
          label: 'Shortest and longest gap',
          value: facts.shortestGap == null
              ? null
              : '${facts.shortestGap} days and ${facts.longestGap} days',
          placeholder: 'Two periods give the first gap.',
        ),
        const SizedBox(height: 10),
        TtcReportFact(
          label: 'Period usually lasts',
          value: facts.usualBleedDays == null
              ? null
              : '${facts.usualBleedDays} days',
          placeholder: 'Say how long a period lasted when you log one.',
        ),
        const SizedBox(height: 22),

        TtcReportAction(label: footLabel, muted: true, onTap: onFoot),
        const SizedBox(height: 12),
        Text(footNote, style: ttcBody(12, color: ttcMuted, h: 1.5)),
      ],
    );
  }

  static String _month(DateTime d) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][d.month - 1];
}

/// Her days, with no phase colour anywhere.
///
/// ⚠️ THIS IS THE REFUSAL, DRAWN. Not a coloured grid with a caption telling
/// her to ignore the colours — an uncoloured one. Two inks only: the days she
/// marked as a period, and the days she logged anything else. Everything the
/// app inferred is absent, which is the whole point.
class _PlainGrid extends StatelessWidget {
  const _PlainGrid({required this.report});
  final TtcCycleReport report;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        children: [
          for (final day in report.days)
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ttcTitleInk.withValues(
                    alpha: day.cycleDay <= kTtcAssumedBleedDays
                        ? 0.34
                        : day.hasAnything
                            ? 0.12
                            : 0.05),
                borderRadius: BorderRadius.circular(11),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${day.date.day}',
                    style: ttcBody(11.5,
                        color: ttcTitleInk, w: FontWeight.w700)),
              ),
            ),
        ],
      );
}

class _Key extends StatelessWidget {
  const _Key({required this.alpha, required this.label});
  final double alpha;
  final String label;

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: ttcTitleInk.withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 7),
        Text(label, style: ttcBody(11.5, color: ttcSoft)),
      ]);
}

// =============================================================================
//  Small shared parts
// =============================================================================

/// A label over a value, or over an invitation where there is no value yet.
class TtcReportFact extends StatelessWidget {
  const TtcReportFact({
    super.key,
    required this.label,
    this.value,
    this.placeholder,
  });

  final String label;
  final String? value;
  final String? placeholder;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
        decoration: BoxDecoration(
            color: ttcPanel, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: ttcMuted)),
          const SizedBox(height: 5),
          Text(value ?? placeholder ?? '',
              style: value != null
                  ? ttcFraunces(17, w: FontWeight.w600, color: ttcTitleInk)
                  : ttcBody(12.5, h: 1.45)),
        ]),
      );
}

/// The stage's one button: white, a hairline, an ink label.
class TtcReportAction extends StatelessWidget {
  const TtcReportAction({
    super.key,
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: muted ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ttcLine),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: ttcBody(13.5,
                  color: muted ? ttcSoft : ttcTitleInk, w: FontWeight.w800)),
        ),
      );
}

/// The ⓘ panel, opened from the header.
///
/// ⚠️ AN INLINE PANEL, NOT A MODAL SHEET. It used to be a bottom sheet, which
/// covers the page to explain the page. Here it pushes the content down and can
/// be left open while she reads — and on the clinic state it says something
/// different, which a shared modal made awkward.
class TtcReportAbout extends StatelessWidget {
  const TtcReportAbout({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(17, 14, 17, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ttcCardRadius),
          border: Border.all(color: ttcLine),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ABOUT THIS PAGE',
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: ttcMuted)),
          const SizedBox(height: 6),
          Text(text, style: ttcBody(13, h: 1.55)),
        ]),
      );
}

/// What the ⓘ says. Two versions, because one of them is not about her data.
String ttcReportAboutText({required bool clinic}) => clinic
    ? 'Everything here comes from the dates you enter yourself. It is a '
        'record, not a medical test. While a clinic is treating you, their '
        'scans and their dates are the ones to follow.'
    : 'Everything here comes from the dates you enter yourself. It is a '
        'record, not a medical test, and it cannot tell you whether you are '
        'pregnant. For anything you are worried about, see a doctor.';

/// "IUI cycle · day 14", or just the cycle day where the path has no name.
String ttcClinicChip() {
  // `path` lives on the store, not on today's snapshot: the snapshot carries
  // what is true of the DAY, and the pathway is true of her.
  final path = TtcStore.instance.path;
  final day = TtcStore.instance.today.cycleDay;
  final name = path == TtcPath.natural ? null : path.label(false);
  if (name == null) return day == null ? 'This cycle' : 'Cycle day $day';
  return day == null ? '$name cycle' : '$name cycle · day $day';
}
