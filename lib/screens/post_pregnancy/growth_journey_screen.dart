// =============================================================================
//  GrowthJourneyScreen - "Growth Journey" tool (parenting · Tools)
// -----------------------------------------------------------------------------
//  The Growth Percentile tool rebuilt from the Claude Design prompt: a reassuring
//  growth companion, not a calculator. The percentile is one quiet data point -
//  the emotional headline is "growing consistently", never "65th percentile". A
//  Hero snapshot with a plain summary, a calm growth chart (a soft "typical range"
//  band + the child's own line) that toggles Weight / Height / Head, a percentile
//  *explanation*, the ParentVeda interpretation, AI insights, a measurement
//  timeline and an effortless Add-measurement sheet. Reads GrowthStore. Replaces
//  the older light HealthGrowthScreen (kept for revert).
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_health_data.dart';
import 'pp_growth_data.dart';
import 'pp_tools_kit.dart';

class GrowthJourneyScreen extends StatefulWidget {
  const GrowthJourneyScreen({super.key});

  @override
  State<GrowthJourneyScreen> createState() => _GrowthJourneyScreenState();
}

class _GrowthJourneyScreenState extends State<GrowthJourneyScreen> {
  final _store = GrowthStore.instance;
  GrowthMetric _metric = GrowthMetric.weight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _store,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 48),
              children: [
                ...ppToolHeader(
                  context,
                  title: 'Growth journey',
                  subtitle: 'Is $_childName growing in a healthy, expected way? That — not the number — is the question.',
                ),
                const SizedBox(height: 20),
                ppToolPad(_hero()),
                const SizedBox(height: 14),
                ppToolPad(ppLogButton('Add a measurement', _openAddSheet, icon: Icons.straighten_rounded)),

                if (!_store.isEmpty) ...[
                  const SizedBox(height: 24),
                  ppToolPad(_chartCard()),
                  const SizedBox(height: 20),
                  ppToolPad(_percentileCard()),
                  const SizedBox(height: 18),
                  ppToolPad(ppInsightCard(_store.interpretation, tag: 'What it means', icon: Icons.favorite_border_rounded)),
                  const SizedBox(height: 20),
                  ppToolPad(_insights()),
                  const SizedBox(height: 26),
                  ppToolPad(ppSectionHead('Growth timeline', trailing: '${_store.all.length} recorded')),
                  const SizedBox(height: 14),
                  ppToolPad(Column(children: [for (final m in _store.all) _timelineRow(m)])),
                ] else ...[
                  const SizedBox(height: 22),
                  ppToolPad(ppEmptyCard(Icons.show_chart_rounded, 'No measurements yet. Add $_childName\'s latest weight and height and we\'ll gently place them on the curve — no charts to read yourself.')),
                ],

                const SizedBox(height: 28),
                ppToolPad(ppLearnBlock(context, const [
                  'What does a growth percentile actually mean?',
                  'Why consistency matters more than a single number',
                  'What happens during a growth spurt?',
                  'How is my baby measured accurately?',
                ])),
              ],
            );
          },
        ),
      ),
    );
  }

  String get _childName => ChildProfileStore.instance.name;

  // ---- hero ---------------------------------------------------------------
  Widget _hero() {
    final m = _store.latest;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, ppStripeB]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ppHair),
        boxShadow: const [BoxShadow(color: Color(0x1A6A30B6), blurRadius: 30, spreadRadius: -20, offset: Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ppEyebrow('Growth snapshot · ${ChildProfileStore.instance.ageLabel}', color: ppPurple),
        const SizedBox(height: 10),
        Text(_store.headline, style: ppFraunces(26, color: ppPurple, h: 1.1)),
        const SizedBox(height: 14),
        if (m != null) ...[
          Row(children: [
            _stat('Weight', '${_trim(m.weightKg)} kg', _store.latestPercentilePhrase(GrowthMetric.weight)),
            _divider(),
            _stat('Height', '${_trim(m.heightCm)} cm', _store.latestPercentilePhrase(GrowthMetric.height)),
            if (m.headCm != null) ...[
              _divider(),
              _stat('Head', '${_trim(m.headCm!)} cm', _store.latestPercentilePhrase(GrowthMetric.head)),
            ],
          ]),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.spa_outlined, size: 15, color: ppPurple),
            const SizedBox(width: 9),
            Expanded(child: Text(_summaryLine(), style: ppBody(12.5, color: ppInk, h: 1.5))),
          ]),
        ),
      ]),
    );
  }

  String _summaryLine() {
    if (_store.isEmpty) return 'Add a measurement and we\'ll turn it into a calm, plain-language read on how $_childName is growing.';
    if (_store.all.length < 2) return 'A first point recorded. As you add more, the pattern — the part that really matters — comes to life.';
    return 'Growing consistently. Let\'s keep gently monitoring — the steady curve is the reassuring part.';
  }

  Widget _stat(String label, String value, String? pct) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ppBody(11, color: ppMuted, w: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: ppJakarta(16)),
          const SizedBox(height: 2),
          Text(pct == null ? '—' : '$pct pct', style: ppBody(10.5, color: ppSoft)),
        ]),
      );

  Widget _divider() => Container(width: 1, height: 40, color: ppHair, margin: const EdgeInsets.symmetric(horizontal: 14));

  // ---- chart --------------------------------------------------------------
  Widget _chartCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: ppHair)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_metric.axisLabel, style: ppJakarta(15)),
        const SizedBox(height: 4),
        Text('$_childName\'s own line, over a soft typical range.', style: ppBody(12, color: ppMuted)),
        const SizedBox(height: 14),
        // metric toggle
        Row(children: [
          for (final gm in GrowthMetric.values) ...[
            _metricChip(gm),
            if (gm != GrowthMetric.values.last) const SizedBox(width: 8),
          ],
        ]),
        const SizedBox(height: 18),
        SizedBox(
          height: 190,
          child: CustomPaint(
            painter: _GrowthChartPainter(_store, _metric),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Flexible(child: _legendDot(const Color(0xFFEADCF6), 'Typical range')),
          const SizedBox(width: 14),
          Flexible(child: _legendDot(ppPurple, _childName)),
          const SizedBox(width: 10),
          Flexible(child: Text('Age (months) →', textAlign: TextAlign.right, style: ppBody(10.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ]),
    );
  }

  Widget _metricChip(GrowthMetric gm) {
    final on = gm == _metric;
    // Head disabled when no head data present.
    final enabled = gm != GrowthMetric.head || _store.hasHead;
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? () => setState(() => _metric = gm) : null,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? ppPurple : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: on ? ppPurple : ppLine),
            ),
            child: Text(gm.label, style: ppBody(12.5, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color c, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Flexible(child: Text(label, style: ppBody(10.5, color: ppSoft, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]);

  // ---- percentile explanation --------------------------------------------
  Widget _percentileCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.help_outline_rounded, size: 16, color: ppPurple),
            const SizedBox(width: 8),
            Expanded(child: Text('What does the percentile mean?', style: ppJakarta(15))),
          ]),
          const SizedBox(height: 10),
          Text(_store.percentileMeaning, style: ppBody(13.5, color: ppInk, h: 1.6)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
            child: Text('Percentiles here are a gentle estimate against WHO reference values — a guide for conversation, not a diagnosis.',
                style: ppBody(11.5, color: ppMuted, h: 1.5)),
          ),
        ]),
      );

  Widget _insights() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.insights_outlined, size: 16, color: ppPurple),
            const SizedBox(width: 8),
            Expanded(child: Text('Growth insights', style: ppJakarta(15))),
          ]),
          const SizedBox(height: 12),
          for (final s in _store.insights) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(margin: const EdgeInsets.only(top: 7), width: 5, height: 5, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(s, style: ppBody(13, color: ppInk, h: 1.55))),
            ]),
            const SizedBox(height: 10),
          ],
        ]),
      );

  // ---- timeline row -------------------------------------------------------
  Widget _timelineRow(GrowthMeasurement m) {
    final dob = ChildProfileStore.instance.dob;
    final ageM = m.ageMonthsAt(dob);
    final wp = _store.percentile(GrowthMetric.weight, m.weightKg, ageM);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
      child: Row(children: [
        Container(
          width: 46,
          alignment: Alignment.center,
          child: Column(children: [
            Text('${ageM.round()}', style: ppFraunces(22, color: ppPurple, h: 1.0)),
            Text(ageM.round() == 1 ? 'mo' : 'mos', style: ppBody(10, color: ppMuted)),
          ]),
        ),
        Container(width: 1, height: 42, color: ppHair, margin: const EdgeInsets.symmetric(horizontal: 12)),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${_trim(m.weightKg)} kg · ${_trim(m.heightCm)} cm${m.headCm != null ? ' · ${_trim(m.headCm!)} cm head' : ''}', style: ppJakarta(13.5)),
            const SizedBox(height: 3),
            Text('${ppShortDate(m.date)} · ${wp == null ? '' : 'around the ${(wp / 5).round() * 5}th centile · '}${m.note ?? 'measurement'}',
                style: ppBody(11.5, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => ppConfirmRemove(context, 'Remove this measurement?', () => _store.remove(m.id)),
          behavior: HitTestBehavior.opaque,
          child: const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.delete_outline_rounded, size: 20, color: ppMuted)),
        ),
      ]),
    );
  }

  // ---- add measurement sheet ----------------------------------------------
  void _openAddSheet() {
    final weight = TextEditingController();
    final height = TextEditingController();
    final head = TextEditingController();
    final note = TextEditingController();
    DateTime date = DateTime.now();

    ppLogSheet(
      context,
      title: 'Add a measurement',
      saveLabel: 'Save measurement',
      body: (setSheet) => [
        Text('Just the latest figures — we\'ll place them on the curve and update everything for you.', style: ppBody(13, h: 1.55)),
        const SizedBox(height: 16),
        ppFieldLabel('Measured on'),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: ChildProfileStore.instance.dob,
              lastDate: DateTime.now(),
            );
            if (picked != null) setSheet(() => date = picked);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 15, color: ppPurple),
              const SizedBox(width: 10),
              Text('${date.day} ${ppMonthsShort[date.month - 1]} ${date.year}', style: ppBody(14, color: ppInk, w: FontWeight.w600)),
            ]),
          ),
        ),
        Row(children: [
          Expanded(child: _decimalField(weight, 'Weight (kg)')),
          const SizedBox(width: 12),
          Expanded(child: _decimalField(height, 'Height (cm)')),
        ]),
        _decimalField(head, 'Head circumference (cm, optional)'),
        ppToolTextField(note, 'Note (optional)', maxLines: 2),
      ],
      onSave: () {
        final w = double.tryParse(weight.text.trim());
        final h = double.tryParse(height.text.trim());
        if (w == null || h == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Add at least a weight and height to save.'), behavior: SnackBarBehavior.floating));
          return;
        }
        _store.log(date: date, weightKg: w, heightCm: h, headCm: double.tryParse(head.text.trim()), note: note.text.trim().isEmpty ? null : note.text.trim());
        // Tells Health this parent has actually entered growth, so its section
        // stops showing the invitation and starts showing her figures.
        HealthStore.instance.markGrowthEntered();
      },
    );
  }

  Widget _decimalField(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppFieldLabel(label),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: c,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: ppBody(14, color: ppInk),
              decoration: const InputDecoration(isDense: true, filled: false, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ]),
      );

  // ---- helpers ------------------------------------------------------------
  String _trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}

// =============================================================================
//  The chart: a calm "typical range" band + the child's own connected line.
// =============================================================================
class _GrowthChartPainter extends CustomPainter {
  _GrowthChartPainter(this.store, this.metric);
  final GrowthStore store;
  final GrowthMetric metric;

  @override
  void paint(Canvas canvas, Size size) {
    final dob = ChildProfileStore.instance.dob;
    final pts = <Offset>[]; // (ageMonths, value)
    for (final m in store.chronological) {
      final v = m.value(metric);
      if (v != null) pts.add(Offset(m.ageMonthsAt(dob), v));
    }
    if (pts.isEmpty) return;

    // x-range: 0 .. max age (min 4 months of runway).
    final xMax = math.max(4.0, pts.map((p) => p.dx).reduce(math.max)).ceilToDouble();
    const xMin = 0.0;

    // Sample the band across whole months for the fill + median line.
    final loPts = <Offset>[], hiPts = <Offset>[], midPts = <Offset>[];
    for (double mth = xMin; mth <= xMax + 0.001; mth += 1) {
      final (lo, mid, hi) = store.band(metric, mth);
      loPts.add(Offset(mth, lo));
      hiPts.add(Offset(mth, hi));
      midPts.add(Offset(mth, mid));
    }

    // y-range from band + child's points, with a little padding.
    double yMin = double.infinity, yMax = -double.infinity;
    for (final o in [...loPts, ...hiPts, ...pts]) {
      yMin = math.min(yMin, o.dy);
      yMax = math.max(yMax, o.dy);
    }
    final pad = (yMax - yMin) * 0.12 + 0.5;
    yMin -= pad;
    yMax += pad;

    double dx(double age) => size.width * (age - xMin) / (xMax - xMin);
    double dy(double val) => size.height * (1 - (val - yMin) / (yMax - yMin));

    // baseline grid (a few faint horizontal lines)
    final grid = Paint()
      ..color = ppHair
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // typical-range band (fill between lo and hi)
    final band = Path()..moveTo(dx(loPts.first.dx), dy(loPts.first.dy));
    for (final o in loPts.skip(1)) {
      band.lineTo(dx(o.dx), dy(o.dy));
    }
    for (final o in hiPts.reversed) {
      band.lineTo(dx(o.dx), dy(o.dy));
    }
    band.close();
    canvas.drawPath(band, Paint()..color = const Color(0x33B98DE0)..style = PaintingStyle.fill);

    // median (dashed)
    final medPaint = Paint()
      ..color = const Color(0xFFB98DE0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    _dashedPolyline(canvas, [for (final o in midPts) Offset(dx(o.dx), dy(o.dy))], medPaint);

    // child's line
    final linePaint = Paint()
      ..color = ppPurple
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final childPath = Path()..moveTo(dx(pts.first.dx), dy(pts.first.dy));
    for (final p in pts.skip(1)) {
      childPath.lineTo(dx(p.dx), dy(p.dy));
    }
    canvas.drawPath(childPath, linePaint);

    // points
    for (final p in pts) {
      final c = Offset(dx(p.dx), dy(p.dy));
      canvas.drawCircle(c, 5, Paint()..color = Colors.white);
      canvas.drawCircle(c, 5, Paint()..color = ppPurple..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
    // emphasise the latest point
    final last = Offset(dx(pts.last.dx), dy(pts.last.dy));
    canvas.drawCircle(last, 5, Paint()..color = ppPurple);
  }

  void _dashedPolyline(Canvas canvas, List<Offset> points, Paint paint, {double dash = 5, double gap = 4}) {
    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i], b = points[i + 1];
      final total = (b - a).distance;
      if (total == 0) continue;
      final dir = (b - a) / total;
      double d = 0;
      while (d < total) {
        final start = a + dir * d;
        final end = a + dir * math.min(d + dash, total);
        canvas.drawLine(start, end, paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter old) => old.metric != metric || old.store != store;
}
