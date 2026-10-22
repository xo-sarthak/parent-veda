// =============================================================================
//  ttc_temp_parts.dart - her morning temperature, on the Ovulation tests page
// =============================================================================
//
// The approved prototype (2026-10-21, https://claude.ai/artifact/RDvyCezff124mqKKoiSqRN)
// in widgets. Four parts, each used once by `ttc_ovulation_screen.dart`:
//
//   * [showTtcTempLogSheet] - one sheet for "Log today" and "Add an earlier
//     day": a strip of real dates, a 0.05 °C stepper (°F on a switch), the
//     time she took it, Save. The value goes to the BBT tracker that already
//     exists (`TtcLogStore`, 'bbt' / 'celsius'), so the cycle report and the
//     log screen read the same reading. One store, never a second.
//   * [TtcTempMiniChart] - this cycle's readings, the line her rise is
//     measured against, and the higher mornings filled.
//   * [showTtcTempWhySheet] - "Why log your temperature?", three short lines.
//   * [TtcBuyRow] - one product row into the unified store.
//
// Mobbin (MOBBIN-DISCOVERY): Fitbit "Add blood glucose" (value, date and time
// on one sheet) and Stardust "Add daily temperature" (cycle day in the
// header). Declined: a free text field, because a stepper cannot produce 3.65.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_cycle_report.dart'
    show TtcPhase, kTtcTempTracker, kTtcTempField;
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_temp_rise.dart';
import '../../widgets/pv_feedback.dart' show PvPress, pvCommitFeedback;
import 'ttc_common.dart';
import 'ttc_cycle_palette.dart';
import 'ttc_shop_v3.dart' show openTtcProductPage, ttcProductById;

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

const _wk = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _mo = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Sun 18 Oct".
String ttcTempDay(DateTime d) =>
    '${_wk[d.weekday - 1]} ${d.day} ${_mo[d.month - 1]}';

/// This cycle's readings, as (cycle day, °C), from the one BBT tracker.
List<TtcTempReading> ttcTempReadingsSince(DateTime start) {
  final s = _dayOnly(start);
  return [
    for (final v in TtcLogStore.instance.history(
      kTtcTempTracker,
      kTtcTempField,
    ))
      if (!v.day.isBefore(s))
        (cycleDay: _dayOnly(v.day).difference(s).inDays + 1, celsius: v.value),
  ];
}

// ---------------------------------------------------------------------------
//  The log sheet
// ---------------------------------------------------------------------------

/// Opens the log sheet on [initialDay]. Returns true when a reading was saved.
Future<bool> showTtcTempLogSheet(
  BuildContext context, {
  required DateTime initialDay,
  required DateTime cycleStart,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    routeSettings: const RouteSettings(name: 'ttc/ovulation/temp_log'),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (_) =>
        _TempLogSheet(initialDay: initialDay, cycleStart: cycleStart),
  );
  return saved ?? false;
}

class _TempLogSheet extends StatefulWidget {
  const _TempLogSheet({required this.initialDay, required this.cycleStart});
  final DateTime initialDay;
  final DateTime cycleStart;

  @override
  State<_TempLogSheet> createState() => _TempLogSheetState();
}

class _TempLogSheetState extends State<_TempLogSheet> {
  // Never before this cycle began: on day 1 "an earlier day" opens on today.
  late DateTime _day =
      _dayOnly(widget.initialDay).isBefore(_dayOnly(widget.cycleStart))
      ? _dayOnly(widget.cycleStart)
      : _dayOnly(widget.initialDay);
  bool _f = false;
  TimeOfDay? _at;
  late double _c = _start();

  /// What the stepper opens on: that day's reading if there is one, else her
  /// last reading, else a usual waking temperature.
  double _start() {
    final log = TtcLogStore.instance;
    final on = log.valueFor(kTtcTempTracker, kTtcTempField, on: _day);
    if (on != null) return on.value;
    return log.latest(kTtcTempTracker, kTtcTempField)?.value ?? 36.40;
  }

  void _step(double by) => setState(() {
    _c = ((_c + by).clamp(35.0, 38.0) * 100).roundToDouble() / 100;
  });

  String get _shown =>
      _f ? (_c * 9 / 5 + 32).toStringAsFixed(1) : _c.toStringAsFixed(2);

  void _save() {
    pvCommitFeedback();
    final note = _at == null
        ? null
        : 'at ${_at!.hour.toString().padLeft(2, '0')}:${_at!.minute.toString().padLeft(2, '0')}';
    TtcLogStore.instance.log(
      kTtcTempTracker,
      kTtcTempField,
      _c,
      on: _day,
      note: note,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final today = _dayOnly(DateTime.now());
    final start = _dayOnly(widget.cycleStart);
    // The last ten mornings, never before this cycle began, today last.
    final days = <DateTime>[
      for (var back = 9; back >= 0; back--)
        if (!today.subtract(Duration(days: back)).isBefore(start))
          today.subtract(Duration(days: back)),
    ];
    final had =
        TtcLogStore.instance.valueFor(
          kTtcTempTracker,
          kTtcTempField,
          on: _day,
        ) !=
        null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          16,
          18,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              same(_day, today)
                  ? "This morning's temperature"
                  : 'Temperature on ${ttcTempDay(_day)}',
              style: pvFraunces(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: ttcTitleInk,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 66,
              child: ListView.separated(
                key: const ValueKey('ttc_temp_log_days'),
                scrollDirection: Axis.horizontal,
                reverse: true,
                itemCount: days.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final d = days[days.length - 1 - i];
                  final on = same(d, _day);
                  final logged =
                      TtcLogStore.instance.valueFor(
                        kTtcTempTracker,
                        kTtcTempField,
                        on: d,
                      ) !=
                      null;
                  return PvPress(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _day = d;
                        _c = _start();
                      }),
                      child: Container(
                        width: 52,
                        decoration: BoxDecoration(
                          color: on ? ttcTitleInk : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: on ? ttcTitleInk : ttcBorder,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              same(d, today) ? 'Today' : _wk[d.weekday - 1],
                              style: ttcBody(
                                10,
                                color: on ? Colors.white : ttcSoft,
                              ),
                            ),
                            Text(
                              '${d.day}',
                              style: ttcBody(
                                15,
                                color: on ? Colors.white : ttcTitleInk,
                                w: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'day ${d.difference(start).inDays + 1}',
                              style: ttcBody(
                                9.5,
                                color: on ? Colors.white : ttcSoft,
                              ),
                            ),
                            SizedBox(
                              height: 6,
                              child: logged
                                  ? Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: on
                                            ? Colors.white
                                            : TtcCycleColours.ovulation,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Round(
                  key: const ValueKey('ttc_temp_log_minus'),
                  icon: Icons.remove_rounded,
                  label: 'Lower by 0.05',
                  onTap: () => _step(-0.05),
                ),
                const SizedBox(width: 18),
                SizedBox(
                  width: 130,
                  child: Text(
                    '$_shown°',
                    key: const ValueKey('ttc_temp_log_value'),
                    textAlign: TextAlign.center,
                    style: pvFraunces(
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                      color: ttcTitleInk,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                _Round(
                  key: const ValueKey('ttc_temp_log_plus'),
                  icon: Icons.add_rounded,
                  label: 'Raise by 0.05',
                  onTap: () => _step(0.05),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Unit(
                  label: '°C',
                  on: !_f,
                  onTap: () => setState(() => _f = false),
                ),
                const SizedBox(width: 8),
                _Unit(
                  label: '°F',
                  on: _f,
                  onTap: () => setState(() => _f = true),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text('Taken at', style: ttcBody(13.5, color: ttcSoft)),
                ),
                PvPress(
                  child: GestureDetector(
                    key: const ValueKey('ttc_temp_log_time'),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime:
                            _at ?? const TimeOfDay(hour: 6, minute: 30),
                      );
                      if (t != null && mounted) setState(() => _at = t);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: ttcBorder),
                      ),
                      child: Text(
                        _at == null ? 'Add the time' : _at!.format(context),
                        style: ttcBody(
                          13,
                          color: ttcTitleInk,
                          w: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TtcInkPill(
              key: const ValueKey('ttc_temp_log_save'),
              label: had ? 'Save the change' : 'Save',
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }

  static bool same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Round extends StatelessWidget {
  const _Round({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: PvPress(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ttcBorder),
            color: Colors.white,
          ),
          child: Icon(icon, color: ttcTitleInk, size: 22),
        ),
      ),
    ),
  );
}

class _Unit extends StatelessWidget {
  const _Unit({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PvPress(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: on ? ttcTitleInk : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? ttcTitleInk : ttcBorder),
        ),
        child: Text(
          label,
          style: ttcBody(
            12.5,
            color: on ? Colors.white : ttcTitleInk,
            w: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

/// The house ink pill, full width.
class TtcInkPill extends StatelessWidget {
  const TtcInkPill({
    super.key,
    required this.label,
    required this.onTap,
    this.outlined = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) => Material(
    color: outlined ? Colors.white : ttcTitleInk,
    shape: StadiumBorder(
      side: outlined
          ? const BorderSide(color: ttcTitleInk, width: 1.4)
          : BorderSide.none,
    ),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: pvManrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: outlined ? ttcTitleInk : Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
//  The chart
// ---------------------------------------------------------------------------

/// This cycle's readings as a line, the cover line dashed, higher mornings
/// filled. Draws nothing below two readings.
class TtcTempMiniChart extends StatelessWidget {
  const TtcTempMiniChart({
    super.key,
    required this.readings,
    this.riseDay,
    this.line,
    this.riseLabel,
  });
  final List<TtcTempReading> readings;
  final int? riseDay;
  final double? line;

  /// The rise day, named on the chart ("Rose · Sun 18 Oct"), once she has
  /// marked it (Mobbin 2026-10-21: Flo shades the day, Oura pins it).
  final String? riseLabel;

  @override
  Widget build(BuildContext context) {
    if (readings.length < 2) return const SizedBox.shrink();
    return SizedBox(
      key: const ValueKey('ttc_ov_temp_chart'),
      height: 150,
      width: double.infinity,
      child: CustomPaint(
        painter: _ChartPainter(readings, riseDay, line, riseLabel),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.r, this.rise, this.line, this.label);
  final List<TtcTempReading> r;
  final int? rise;
  final double? line;
  final String? label;

  @override
  void paint(Canvas canvas, Size size) {
    final pts = [...r]..sort((a, b) => a.cycleDay.compareTo(b.cycleDay));
    final vals = pts.map((x) => x.celsius);
    final lo = (vals.reduce(math.min) - 0.1);
    final hi = (vals.reduce(math.max) + 0.1);
    const left = 34.0, bottom = 20.0;
    final top = label == null ? 8.0 : 26.0; // room for the pin
    final w = size.width - left - 6, h = size.height - bottom - top;
    final d0 = pts.first.cycleDay, d1 = math.max(pts.last.cycleDay, d0 + 1);
    double x(int d) => left + w * (d - d0) / (d1 - d0);
    double y(double c) => top + h * (1 - (c - lo) / (hi - lo));
    final grid = Paint()
      ..color = ttcBorder
      ..strokeWidth = 1;
    void text(String s, Offset at, {bool right = false}) {
      final tp = TextPainter(
        text: TextSpan(
          text: s,
          style: ttcBody(9.5, color: ttcSoft),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, right ? at - Offset(tp.width, tp.height / 2) : at);
    }

    for (var i = 0; i <= 2; i++) {
      final c = lo + (hi - lo) * i / 2;
      canvas.drawLine(Offset(left, y(c)), Offset(size.width - 6, y(c)), grid);
      text('${c.toStringAsFixed(1)}°', Offset(left - 4, y(c)), right: true);
    }
    if (line case final l?) {
      final p = Paint()
        ..color = TtcCycleColours.mark(TtcPhase.beforeWindow)
        ..strokeWidth = 1.4;
      for (var sx = left; sx < size.width - 6; sx += 8) {
        canvas.drawLine(Offset(sx, y(l)), Offset(sx + 4, y(l)), p);
      }
    }
    // The marked day: a light band behind it and a pin above it.
    if ((rise, label) case (final d?, final l?) when d >= d0 && d <= d1) {
      final cx = x(d);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 9, top - 4, 18, h + 8),
          const Radius.circular(4),
        ),
        Paint()..color = TtcCycleColours.fertileTint,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: l,
          style: pvManrope(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final pw = tp.width + 16;
      final px = (cx - pw / 2).clamp(left, size.width - 6 - pw).toDouble();
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(px, 0, pw, 18),
          const Radius.circular(9),
        ),
        Paint()..color = ttcTitleInk,
      );
      tp.paint(canvas, Offset(px + 8, 9 - tp.height / 2));
    }
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final o = Offset(x(pts[i].cycleDay), y(pts[i].celsius));
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = TtcCycleColours.ovulation
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (final p in pts) {
      final high = rise != null && p.cycleDay >= rise!;
      final o = Offset(x(p.cycleDay), y(p.celsius));
      canvas.drawCircle(
        o,
        high ? 4.5 : 3.5,
        Paint()..color = high ? TtcCycleColours.ovulation : Colors.white,
      );
      canvas.drawCircle(
        o,
        high ? 4.5 : 3.5,
        Paint()
          ..color = TtcCycleColours.ovulation
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      text('${p.cycleDay}', Offset(o.dx - 4, size.height - bottom + 5));
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.r != r || old.rise != rise || old.line != line || old.label != label;
}

// ---------------------------------------------------------------------------
//  Why log it
// ---------------------------------------------------------------------------

/// ⚠️ WHY IT MATTERS, IN HER WORDS (the user, 2026-10-21: "tell the user why
/// it's important ... so they monitor it more ... simple, warm language").
/// Three short lines with line icons (the app-must-explain-itself rule), a
/// tip, and nothing that sounds like a chance.
Future<void> showTtcTempWhySheet(BuildContext context) {
  Widget line(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: TtcCycleColours.fertileTint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: TtcCycleColours.fertileInk),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: ttcBody(14, color: ttcTitleInk, h: 1.45)),
        ),
      ],
    ),
  );
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    routeSettings: const RouteSettings(name: 'ttc/ovulation/temp_why'),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          key: const ValueKey('ttc_ov_temp_why_sheet'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Why log your temperature?',
              style: pvFraunces(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: ttcTitleInk,
              ),
            ),
            line(
              Icons.thermostat_outlined,
              'Your temperature goes up a little after you ovulate. Logging it shows us it happened.',
            ),
            line(
              Icons.event_available_outlined,
              'When we see the rise, your fertile days follow your body, not just our estimate.',
            ),
            line(
              Icons.insights_outlined,
              'After 2 or 3 cycles it shows your own pattern. That is useful to show your doctor.',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              // Kept for revert (2026-10-22, no tinted slab, no lavender):
              //   color: ttcPanel,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: ttcLine),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Tip: take it at the same time each morning, before you get up or have a sip of water.',
                style: ttcBody(12.5, h: 1.45),
              ),
            ),
            const SizedBox(height: 16),
            TtcInkPill(label: 'Got it', onTap: () => Navigator.of(ctx).pop()),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
//  A product row
// ---------------------------------------------------------------------------

/// One product, one tap into its page in the unified store (2026-10-21: "we
/// can pitch the products ... buy ovulation strips"). Draws nothing when the
/// product is not in the catalogue, so a removed product never leaves a
/// dead row.
class TtcBuyRow extends StatelessWidget {
  const TtcBuyRow({
    super.key,
    required this.productId,
    required this.title,
    required this.icon,
    this.cta = 'Buy',
  });
  final String productId;
  final String title;
  final IconData icon;
  final String cta;

  @override
  Widget build(BuildContext context) {
    final p = ttcProductById(productId);
    if (p == null) return const SizedBox.shrink();
    return PvPress(
      child: GestureDetector(
        key: ValueKey('ttc_buy_$productId'),
        behavior: HitTestBehavior.opaque,
        onTap: () {
          pvCommitFeedback();
          openTtcProductPage(context, productId);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ttcBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: TtcCycleColours.fertileTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: TtcCycleColours.fertileInk, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ttcBody(
                        13.5,
                        color: ttcTitleInk,
                        w: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${p.brand} · ${p.size} · ${p.price}',
                      style: ttcBody(12, color: ttcSoft),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ttcTitleInk,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  cta,
                  style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
