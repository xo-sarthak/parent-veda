// =============================================================================
//  HealthGrowthScreen - growth, gently visualised
// -----------------------------------------------------------------------------
//  Current measurements, a simple weight/length trend (no overwhelming clinical
//  charts), percentiles and a plain-language interpretation. "Following his own
//  curve" is the message, not a wall of graphs.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_health_data.dart';

class HealthGrowthScreen extends StatelessWidget {
  const HealthGrowthScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final now = kGrowth.last;
    final labels = kGrowth.map((g) => g.ageLabel).toList();
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Health')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('Growth', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('Growing at his own pace', style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 18),

            _pad(Row(children: [
              Expanded(child: _statCard('Weight', '${now.weightKg} kg', '${now.weightPct}th centile')),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Length', '${now.heightCm.toInt()} cm', '48th centile')),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Head', '${now.headCm.toInt()} cm', '52nd centile')),
            ])),

            const SizedBox(height: 22),
            _pad(_chartCard('Weight', 'kg', kGrowth.map((g) => g.weightKg).toList(), labels, ppPurple)),
            const SizedBox(height: 14),
            _pad(_chartCard('Length', 'cm', kGrowth.map((g) => g.heightCm).toList(), labels, ppCoral)),

            const SizedBox(height: 20),
            _pad(Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.trending_up_rounded, size: 18, color: ppPurple),
                const SizedBox(width: 12),
                Expanded(child: Text(kGrowthInterpretation, style: ppBody(13.5, color: ppInk, h: 1.55))),
              ]),
            )),
            const SizedBox(height: 12),
            _pad(Text('Following his OWN curve over time matters far more than any single number or comparison.', style: ppBody(11.5, color: ppMuted, h: 1.5))),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, String sub) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: ppBody(9, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.5)),
          const SizedBox(height: 7),
          Text(value, style: ppJakarta(16), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(sub, style: ppBody(10.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      );

  Widget _chartCard(String title, String unit, List<double> values, List<String> labels, Color color) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title, style: ppJakarta(15)),
            const Spacer(),
            Text('${values.first.toStringAsFixed(title == 'Weight' ? 1 : 0)} → ${values.last.toStringAsFixed(title == 'Weight' ? 1 : 0)} $unit', style: ppBody(12, color: ppMuted, w: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),
          SizedBox(height: 90, child: CustomPaint(size: Size.infinite, painter: _SparkPainter(values, color))),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            for (final l in labels) Text(l, style: ppBody(10, color: ppMuted)),
          ]),
        ]),
      );
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.color);
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : (maxV - minV);
    final dx = size.width / (values.length - 1);
    Offset pt(int i) => Offset(i * dx, size.height - ((values[i] - minV) / range) * (size.height - 12) - 6);

    // area fill
    final fill = Path()..moveTo(0, size.height);
    for (int i = 0; i < values.length; i++) {
      fill.lineTo(pt(i).dx, pt(i).dy);
    }
    fill
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.08));

    // line
    final line = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (int i = 1; i < values.length; i++) {
      line.lineTo(pt(i).dx, pt(i).dy);
    }
    canvas.drawPath(line, Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    // dots
    for (int i = 0; i < values.length; i++) {
      canvas.drawCircle(pt(i), 4, Paint()..color = Colors.white);
      canvas.drawCircle(pt(i), 4, Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.values != values || old.color != color;
}
