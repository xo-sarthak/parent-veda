// =============================================================================
//  TtcCycleReportScreen — a month of logging, given back
// -----------------------------------------------------------------------------
//  ⚠️ REBUILT. The first version was unreadable and the note was fair: *"When I
//  see my cycle report I cannot understand what is this graph at all. If I
//  cannot understand it, being an educated person, no one will."*
//
//  Four things were wrong, and each has a general lesson worth keeping:
//
//    1. **The chart had no context.** A line and two axis numbers, floating.
//       A chart is only readable if it says what it is measuring, over what
//       span, against what — so it now carries its own title, its unit, date
//       ticks, the phase bands behind it, and marker rows underneath for
//       period, sex and tests. The line is the smallest part of a chart.
//    2. **Sections existed to explain their own emptiness.** "Changes during
//       the cycle → add a weight and a chart appears here" is a heading, a card
//       and a paragraph spent on nothing. Empty states belong INSIDE the thing
//       that is empty, not as a section of their own.
//    3. **Purple everywhere.** Same mistake as the logger: the stage's accent
//       used as its ground. Colour here comes from the cycle PHASES, which are
//       the only thing on the screen that colour actually means something about.
//    4. **The disclaimer ate the foot of the page.** It is an ⓘ in the header
//       now — reachable, not occupying the last screenful.
//
//  ⚠️ AND IT IS FOR HER, NOT FOR A CLINIC. Decided explicitly. That is why it
//  is four things readable in twenty seconds rather than a printable summary —
//  a doctor-facing export is a different document and would be denser, drier
//  and organised by system rather than by month.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_cycle_report.dart';
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

class TtcCycleReportScreen extends StatefulWidget {
  const TtcCycleReportScreen({super.key});

  @override
  State<TtcCycleReportScreen> createState() => _TtcCycleReportScreenState();
}

class _TtcCycleReportScreenState extends State<TtcCycleReportScreen> {
  int _index = 0;
  bool _showTemp = false;

  static const _m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static String _fmt(DateTime d) => '${d.day} ${_m[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final p = V2PaletteStore.instance.current;
    final r = ttcBuildCycleReport(index: _index);

    return Scaffold(
      backgroundColor: ttcBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              ttcGutter, 6, ttcGutter, ttcBottomInset),
          children: [
            // ---- header, with the disclaimer behind an ⓘ ----------------
            Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: ttcTitleInk,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(child: Text(t.reportTitle, style: ttcJakarta(18))),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, size: 21),
                color: ttcMuted,
                onPressed: () => _showDisclaimer(context, t),
              ),
            ]),
            const SizedBox(height: 6),

            if (r.state == TtcReportState.noPeriod) ...[
              _Empty(title: t.reportNoPeriod, body: t.reportNoPeriodBody),
            ] else ...[
              _CyclePicker(
                label: r.start == null
                    ? ''
                    : '${_fmt(r.start!)} – ${_fmt(r.end!)}',
                canGoBack: _index + 1 < r.cyclesAvailable,
                canGoForward: _index > 0,
                onBack: () => setState(() => _index++),
                onForward: () => setState(() => _index--),
              ),
              const SizedBox(height: 16),

              // ⚠️ A REFUSAL, NOT AN ERROR, AND IT LOOKS LIKE NEITHER A WARNING
              // NOR A GAP. Quiet panel, plain sentence, and the data below it
              // renders exactly as it would otherwise — minus the phase bands
              // that are not ours to draw.
              if (r.state == TtcReportState.clinicHeld ||
                  r.state == TtcReportState.noEstimate) ...[
                _Note(
                  title: r.state == TtcReportState.clinicHeld
                      ? t.reportClinicTitle
                      : t.reportNoEstimateTitle,
                  body: r.state == TtcReportState.clinicHeld
                      ? t.reportClinicBody
                      : t.reportNoEstimateBody,
                ),
                const SizedBox(height: 16),
              ],

              // ---- one card: the cycle, the chart, the markers ---------
              //
              // ⚠️ MERGED. These were three sections — the day strip, the
              // chart, and an empty "changes during the cycle". They are one
              // picture of one month, and splitting them meant three headings
              // for a thing the reader thinks of as one.
              _CycleCard(
                report: r,
                p: p,
                showTemp: _showTemp,
                onPickSeries: (v) => setState(() => _showTemp = v),
              ),
              const SizedBox(height: 18),

              // ---- what it adds up to ----------------------------------
              //
              // ⚠️ ABSENT BELOW A WEEK OF LOGGING, and absent when nothing
              // clustered. Silence is the correct output of a report with
              // nothing to report — see the note in `ttc_cycle_report.dart`.
              if (_notes(r).isNotEmpty) ...[
                ttcSectionTitle(t.reportWhatYouLogged),
                for (final f in _notes(r)) ...[
                  TtcCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.headline,
                              style: ttcFraunces(16,
                                  w: FontWeight.w600, color: ttcTitleInk)),
                          const SizedBox(height: 5),
                          Text(f.detail, style: ttcBody(13, h: 1.55)),
                        ]),
                  ),
                  const SizedBox(height: 10),
                ],
              ] else if (r.state == TtcReportState.thin) ...[
                _Note(title: t.reportThinTitle, body: t.reportThinBody),
              ],
            ],
          ],
        ),
      ),
    );
  }

  List<TtcFinding> _notes(TtcCycleReport r) {
    final length = ttcCycleLengthNote();
    return [...r.findings, ?length];
  }

  void _showDisclaimer(BuildContext context, TtcS t) => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(t.reportDisclaimer, style: ttcBody(14, h: 1.65)),
          ]),
        ),
      );
}

/// ◀ 23 Aug – 15 Sept ▶
class _CyclePicker extends StatelessWidget {
  const _CyclePicker({
    required this.label,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final String label;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) => Row(children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          color: canGoBack ? ttcTitleInk : ttcBorder,
          onPressed: canGoBack ? onBack : null,
        ),
        Expanded(
          child: Column(children: [
            Text(TtcS.current().reportChosenCycle,
                style: ttcBody(11, color: ttcMuted, w: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label, style: ttcJakarta(16)),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          color: canGoForward ? ttcTitleInk : ttcBorder,
          onPressed: canGoForward ? onForward : null,
        ),
      ]);
}

/// The whole month as one picture: phases, the line, and what happened.
class _CycleCard extends StatelessWidget {
  const _CycleCard({
    required this.report,
    required this.p,
    required this.showTemp,
    required this.onPickSeries,
  });

  final TtcCycleReport report;
  final V2Palette p;
  final bool showTemp;
  final void Function(bool) onPickSeries;

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final hasWeight = report.withWeight.length >= 2;
    final hasTemp = report.withTemp.length >= 2;
    final temp = showTemp && hasTemp;
    final series = temp ? report.withTemp : report.withWeight;
    final hasSeries = series.length >= 2;

    return TtcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ---- what this chart is ------------------------------------------
        Row(children: [
          Expanded(
            child: Text(
                hasSeries
                    ? (temp ? t.reportTemperature : t.reportWeight)
                    : t.reportThisCycle,
                style: ttcJakarta(16)),
          ),
          if (hasWeight && hasTemp)
            _Segment(
              left: t.reportWeight,
              right: t.reportTemperature,
              rightOn: temp,
              onPick: onPickSeries,
            ),
        ]),
        const SizedBox(height: 14),

        SizedBox(
          height: hasSeries ? 200 : 96,
          child: CustomPaint(
            painter: _ChartPainter(
              report: report,
              series: hasSeries ? series : const [],
              temp: temp,
              band: (phase) =>
                  v2BlockTint(phase.hue, p).withValues(alpha: 0.6),
              plain: ttcPanel,
              line: ttcTitleInk,
              axis: ttcMuted,
              markPeriod: ttcCoral,
              markOther: ttcTitleInk,
            ),
            size: Size.infinite,
          ),
        ),

        // ⚠️ THE INVITE LIVES INSIDE THE CHART CARD. It used to be its own
        // section with its own heading — a whole block of screen explaining
        // that a block of screen was empty.
        if (!hasSeries) ...[
          const SizedBox(height: 12),
          Text(t.reportNoNumbers, style: ttcBody(12.5, color: ttcMuted, h: 1.5)),
        ],

        const SizedBox(height: 14),
        ttcDivider(),
        const SizedBox(height: 12),

        // ---- the legend, which is what makes the bands mean anything ----
        Wrap(spacing: 14, runSpacing: 7, children: [
          for (final phase in TtcPhase.values)
            _Key(colour: v2BlockTint(phase.hue, p), label: phase.label),
          _Key(colour: ttcCoral, label: t.reportKeyPeriod, dot: true),
          _Key(colour: ttcTitleInk, label: t.reportKeyLogged, dot: true),
        ]),
      ]),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.colour, required this.label, this.dot = false});

  final Color colour;
  final String label;
  final bool dot;

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: dot ? 7 : 10,
          height: dot ? 7 : 10,
          decoration: BoxDecoration(
            color: colour,
            shape: dot ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: dot ? null : BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: ttcBody(11, color: ttcMuted, w: FontWeight.w700)),
      ]);
}

class _Segment extends StatelessWidget {
  const _Segment(
      {required this.left,
      required this.right,
      required this.rightOn,
      required this.onPick});

  final String left;
  final String right;
  final bool rightOn;
  final void Function(bool) onPick;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool on, VoidCallback tap) => GestureDetector(
          onTap: tap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: on ? ttcTitleInk : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: ttcBody(11,
                    color: on ? Colors.white : ttcMuted, w: FontWeight.w800)),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ttcPanel,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        seg(left, !rightOn, () => onPick(false)),
        seg(right, rightOn, () => onPick(true)),
      ]),
    );
  }
}

/// ⚠️ THE LINE IS THE SMALLEST PART OF THIS. What makes a chart readable is the
/// furniture around it — the unit on the axis, the dates along the bottom, the
/// bands saying where in the cycle each column falls, and the marker rows
/// saying what happened on those days. The first version drew a line and two
/// numbers and expected the reader to supply the rest.
class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.report,
    required this.series,
    required this.temp,
    required this.band,
    required this.plain,
    required this.line,
    required this.axis,
    required this.markPeriod,
    required this.markOther,
  });

  final TtcCycleReport report;
  final List<TtcReportDay> series;
  final bool temp;
  final Color Function(TtcPhase) band;
  final Color plain;
  final Color line;
  final Color axis;
  final Color markPeriod;
  final Color markOther;

  static const _rows = 2; // period · logged

  @override
  void paint(Canvas canvas, Size size) {
    final days = report.days;
    if (days.isEmpty) return;

    const leftGutter = 30.0;
    const rowHeight = 15.0;
    const tickHeight = 14.0;
    final markersTop = size.height - _rows * rowHeight;
    final ticksTop = markersTop - tickHeight;
    final plot = Rect.fromLTRB(leftGutter, 2, size.width, ticksTop - 4);

    final n = days.length;
    final colWidth = (size.width - leftGutter) / n;
    double xOf(int i) => leftGutter + colWidth * (i + 0.5);

    // ---- phase bands ------------------------------------------------------
    for (var i = 0; i < n; i++) {
      final phase = days[i].phase;
      canvas.drawRect(
        Rect.fromLTWH(leftGutter + colWidth * i, plot.top, colWidth + 0.5,
            plot.height),
        Paint()..color = phase == null ? plain.withValues(alpha: 0.5) : band(phase),
      );
    }

    // ---- the series -------------------------------------------------------
    if (series.length >= 2) {
      final values = series.map((d) => temp ? d.tempC! : d.weightKg!).toList();
      var lo = values.reduce((a, b) => a < b ? a : b);
      var hi = values.reduce((a, b) => a > b ? a : b);
      // A flat series still needs a range, or every point stacks on one line.
      if ((hi - lo).abs() < 0.001) {
        lo -= temp ? 0.3 : 1.0;
        hi += temp ? 0.3 : 1.0;
      } else {
        final pad = (hi - lo) * 0.22;
        lo -= pad;
        hi += pad;
      }
      double yOf(double v) => plot.bottom - plot.height * ((v - lo) / (hi - lo));

      // Axis: three values, and the UNIT on the top one so the number means
      // something without a caption.
      for (var i = 0; i <= 2; i++) {
        final v = lo + (hi - lo) * (i / 2);
        final y = yOf(v);
        canvas.drawLine(
            Offset(leftGutter, y),
            Offset(size.width, y),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.55)
              ..strokeWidth = 0.8);
        _text(
            canvas,
            temp ? v.toStringAsFixed(1) : v.toStringAsFixed(0),
            Offset(0, y - 6),
            9,
            axis,
            bold: true);
      }
      _text(canvas, temp ? '°C' : 'kg', Offset(0, plot.top - 1), 8.5, axis);

      final pts = <Offset>[];
      for (final d in series) {
        final i = days.indexWhere((x) => x.cycleDay == d.cycleDay);
        if (i < 0) continue;
        pts.add(Offset(xOf(i), yOf(temp ? d.tempC! : d.weightKg!)));
      }
      if (pts.length > 1) {
        final path = Path()..moveTo(pts.first.dx, pts.first.dy);
        for (final pt in pts.skip(1)) {
          path.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(
            path,
            Paint()
              ..color = line
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round);
      }
      for (final pt in pts) {
        canvas.drawCircle(pt, 4, Paint()..color = Colors.white);
        canvas.drawCircle(pt, 2.6, Paint()..color = line);
      }
    }

    // ---- date ticks -------------------------------------------------------
    for (var i = 0; i < n; i += (n / 6).ceil().clamp(1, 99)) {
      _text(canvas, '${days[i].date.day}', Offset(xOf(i) - 5, ticksTop + 1), 9,
          axis);
    }

    // ---- marker rows ------------------------------------------------------
    //
    // The rows the reference puts under its axis, and the reason they matter:
    // a weight line alone says nothing about a cycle. The same line with
    // "period here, and you logged on these days" underneath is a month.
    for (var row = 0; row < _rows; row++) {
      final y = markersTop + rowHeight * row + rowHeight / 2;
      for (var i = 0; i < n; i++) {
        final d = days[i];
        final on = row == 0
            ? d.phase == TtcPhase.period
            : d.symptoms.isNotEmpty;
        if (!on) continue;
        canvas.drawCircle(Offset(xOf(i), y), 3.2,
            Paint()..color = row == 0 ? markPeriod : markOther);
      }
    }
  }

  void _text(Canvas c, String s, Offset at, double size, Color colour,
      {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              fontSize: size,
              color: colour,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, at);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.series != series || old.temp != temp || old.report != report;
}

class _Note extends StatelessWidget {
  const _Note({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          // ⚠️ THE NEUTRAL PANEL. This was a pink-red wash, which made an
          // ordinary "not much yet" read like a warning.
          color: ttcPanel,
          borderRadius: BorderRadius.circular(ttcCardRadius),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: ttcFraunces(17, w: FontWeight.w600, color: ttcTitleInk)),
          const SizedBox(height: 7),
          Text(body, style: ttcBody(13, h: 1.6)),
        ]),
      );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 44),
        child: Column(children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(color: ttcPanel, shape: BoxShape.circle),
            child: const Icon(Icons.insights_rounded,
                size: 28, color: ttcTitleInk),
          ),
          const SizedBox(height: 18),
          Text(title,
              textAlign: TextAlign.center,
              style: ttcFraunces(20, w: FontWeight.w600, color: ttcTitleInk)),
          const SizedBox(height: 9),
          Text(body, textAlign: TextAlign.center, style: ttcBody(13.5, h: 1.6)),
        ]),
      );
}
