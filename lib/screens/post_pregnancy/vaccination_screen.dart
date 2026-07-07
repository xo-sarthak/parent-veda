// =============================================================================
//  VaccinationScreen - Vaccination Tracker · home (parenting · S26)
// -----------------------------------------------------------------------------
//  Aarav's immunisation record: a progress ring, the dose due this month, his
//  timeline (upcoming + a collapsible "completed" list), a three-way cost
//  compare link, and a doctor-ready export. Faithful build of Claude Design
//  "post pregnancy - content.dc.html" · S26. Reached from the Tools hub's
//  "Vaccination schedule" tracker row. Informational, not medical advice.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'doctor_record_screen.dart';
import 'pp_common.dart';
import 'vaccination_compare_screen.dart';
import 'vaccine_detail_screen.dart';
import 'vaccine_learn_screen.dart';

// Local status palette (green = free/done, brown = private-cost).
const Color _green = Color(0xFF1F8A5B);
const Color _greenTint = Color(0xFFEAF4EE);
const Color _ringTrack = Color(0xFFECE5F2);

// Aarav's completed first-year vaccines (all 13 - the count and the list match).
const List<(String, String)> _completedVaccines = [
  ('PCV - dose 2', '10 wk · 14 Jun'),
  ('Pentavalent - dose 2', '10 wk · 14 Jun'),
  ('Rotavirus - dose 2', '10 wk · 14 Jun'),
  ('IPV - dose 2', '10 wk · 14 Jun'),
  ('PCV - dose 1', '6 wk · 19 Apr'),
  ('Pentavalent - dose 1', '6 wk · 19 Apr'),
  ('Rotavirus - dose 1', '6 wk · 19 Apr'),
  ('IPV - dose 1', '6 wk · 19 Apr'),
  ('OPV - dose 1', '6 wk · 19 Apr'),
  ('Hepatitis B - birth', 'Birth · 8 Mar'),
  ('OPV - 0 (birth)', 'Birth · 8 Mar'),
  ('BCG', 'Birth · 8 Mar'),
  ('Vitamin K', 'Birth · 8 Mar'),
];

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  bool _showCompleted = false;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 60, bottom: 40),
        children: [
          _pad(ppCircleBack(context, eyebrow: 'Vaccinations')),

          // editorial header
          const SizedBox(height: 22),
          _pad(ppEyebrow('Aarav · 4 months', color: ppMuted, spacing: 1.4)),
          const SizedBox(height: 8),
          _pad(Text.rich(TextSpan(children: [
            const TextSpan(text: 'On track, '),
            TextSpan(text: 'and protected.', style: ppFraunces(34, color: ppPurple, h: 1.1).copyWith(fontStyle: FontStyle.italic)),
          ]), style: ppFraunces(34, h: 1.1))),

          // progress ring summary
          const SizedBox(height: 22),
          _pad(Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: ppHair),
              boxShadow: const [BoxShadow(color: Color(0x1A6A30B6), blurRadius: 30, spreadRadius: -20, offset: Offset(0, 12))],
            ),
            child: Row(children: [
              _ring(done: 13, total: 18),
              const SizedBox(width: 18),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Aarav's had 13 of his first-year vaccines.", style: ppBody(14, color: ppInk, w: FontWeight.w600, h: 1.5)),
                  const SizedBox(height: 4),
                  Text('1 due this month · 0 overdue', style: ppBody(12)),
                ]),
              ),
            ]),
          )),

          // educational insight
          const SizedBox(height: 14),
          _pad(GestureDetector(
            onTap: () => _push(const VaccineLearnScreen()),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.lightbulb_outline, size: 18, color: ppPurple),
                const SizedBox(width: 11),
                Expanded(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: 'Why now? At 14 weeks the primary series wraps up - the window his immunity is built. ', style: ppBody(13, color: ppInk, h: 1.55)),
                    TextSpan(text: 'Learn why →', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                  ])),
                ),
              ]),
            ),
          )),

          // DUE THIS MONTH
          const SizedBox(height: 28),
          _pad(_railLabel('Due this month', color: ppPurple)),
          const SizedBox(height: 14),
          _pad(GestureDetector(
            onTap: () => _push(const VaccineDetailScreen()),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, ppStripeB]),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: ppBorder),
                boxShadow: const [BoxShadow(color: Color(0x1F6A30B6), blurRadius: 32, spreadRadius: -18, offset: Offset(0, 14))],
              ),
              child: Column(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('PCV - dose 3', style: ppJakarta(18)),
                      const SizedBox(height: 3),
                      Text('Protects against pneumonia, meningitis', style: ppBody(12)),
                    ]),
                  ),
                  const SizedBox(width: 10),
                  _pill('Due 22 Jul', fg: ppPurple, bg: const Color(0xFFEDE6F5)),
                ]),
                const SizedBox(height: 14),
                const Divider(height: 1, color: ppHair),
                const SizedBox(height: 14),
                Row(children: [
                  Flexible(child: _pill('Free at govt centre', fg: _green, bg: _greenTint)),
                  const SizedBox(width: 8),
                  Flexible(child: Text('Private ₹3,800–5,500', style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  const Spacer(),
                  Text('View →', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                ]),
              ]),
            ),
          )),

          // timeline
          const SizedBox(height: 26),
          _pad(_railLabel('His timeline', color: ppSoft, trailing: GestureDetector(
            onTap: () => _push(const VaccinationCompareScreen()),
            behavior: HitTestBehavior.opaque,
            child: Text('Compare all →', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
          ))),
          const SizedBox(height: 14),
          _pad(Column(children: [
            _timelineRow('MMR-1 · MR', 'at 9 months · upcoming'),
            _timelineRow('Typhoid conjugate (TCV)', '9–12 months · upcoming', last: true),
          ])),

          // completed (collapsible)
          _pad(Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair), bottom: BorderSide(color: ppHair))),
            child: Column(children: [
              GestureDetector(
                onTap: () => setState(() => _showCompleted = !_showCompleted),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: _greenTint, shape: BoxShape.circle),
                      child: const Text('✓', style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 11),
                    Expanded(child: Text('13 completed', style: ppJakarta(15))),
                    AnimatedRotation(
                      turns: _showCompleted ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: ppMuted),
                    ),
                  ]),
                ),
              ),
              if (_showCompleted)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(children: [
                    for (final v in _completedVaccines) _CompletedRow(v.$1, v.$2),
                  ]),
                ),
            ]),
          )),

          // export
          const SizedBox(height: 18),
          _pad(GestureDetector(
            onTap: () => _push(const DoctorRecordScreen()),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: ppHair),
                boxShadow: const [BoxShadow(color: Color(0x146A30B6), blurRadius: 20, spreadRadius: -18, offset: Offset(0, 8))],
              ),
              child: Row(children: [
                const Icon(Icons.description_outlined, size: 22, color: ppPurple),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Doctor-ready record', style: ppJakarta(14)),
                    const SizedBox(height: 1),
                    Text('A clean summary to share at the next visit', style: ppBody(12, color: ppMuted)),
                  ]),
                ),
                const SizedBox(width: 10),
                const Text('→', style: TextStyle(color: Color(0xFFC7BBD6))),
              ]),
            ),
          )),

          const SizedBox(height: 22),
          _pad(Text(
            'A reminder & record tool, not medical advice. Your paediatrician designs any catch-up. Reviewed by Dr. Ananya Rao · schedule v2026.1',
            textAlign: TextAlign.center,
            style: ppBody(12, color: ppMuted, h: 1.55),
          )),
        ],
      ),
    );
  }

  // ---- pieces ----------------------------------------------------------------
  Widget _ring({required int done, required int total}) => SizedBox(
        width: 78,
        height: 78,
        child: CustomPaint(
          painter: _RingPainter(total == 0 ? 0 : done / total),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$done/$total', style: ppJakarta(17)),
              Text('done', style: ppBody(9, color: ppMuted)),
            ]),
          ),
        ),
      );

  Widget _railLabel(String t, {required Color color, Widget? trailing}) => Row(children: [
        Text(t.toUpperCase(), style: ppBody(11, color: color, w: FontWeight.w700).copyWith(letterSpacing: 1.0)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: ppHair)),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ]);

  Widget _pill(String t, {required Color fg, required Color bg}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(t, style: ppBody(11, color: fg, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
      );

  Widget _timelineRow(String title, String sub, {bool last = false}) => GestureDetector(
        onTap: () => _push(const VaccineDetailScreen()),
        behavior: HitTestBehavior.opaque,
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: ppBg, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC7BBD6), width: 2)),
              ),
              if (!last) Expanded(child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 4), color: ppHair)),
            ]),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: ppJakarta(15)),
                  const SizedBox(height: 2),
                  Text(sub, style: ppBody(12, color: ppMuted)),
                ]),
              ),
            ),
          ]),
        ),
      );
}

class _CompletedRow extends StatelessWidget {
  const _CompletedRow(this.title, this.date);
  final String title;
  final String date;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppPanel))),
        child: Row(children: [
          const Text('✓', style: TextStyle(color: _green, fontSize: 13)),
          const SizedBox(width: 11),
          Expanded(child: Text(title, style: ppBody(14, color: ppSoft))),
          Text(date, style: ppBody(12, color: ppMuted)),
        ]),
      );
}

// Progress ring: a green arc over a soft track, centre left transparent.
class _RingPainter extends CustomPainter {
  _RingPainter(this.frac);
  final double frac;

  @override
  void paint(Canvas canvas, Size size) {
    const width = 9.0;
    final center = size.center(Offset.zero);
    final radius = (size.width - width) / 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = _ringTrack;
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = _green;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, frac * 2 * math.pi, false, fill);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.frac != frac;
}
