// =============================================================================
//  AstrologyScreen - Astrology & Numerology · opt-in (parenting · S23)
// -----------------------------------------------------------------------------
//  An explicitly optional, off-by-default section. The toggle reveals Aarav's
//  "cosmic notes" - a monthly horoscope card and a life-path numerology card -
//  framed as culture, not medical guidance. Faithful build of Claude Design
//  "post pregnancy - content.dc.html" · S23 (both OFF + ON states in one
//  screen). Reached from the Explore drawer.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

const Color _starTop = Color(0xFF4A3A6B);
const Color _moon = Color(0xFFC9C3CF);

class AstrologyScreen extends StatefulWidget {
  const AstrologyScreen({super.key});

  @override
  State<AstrologyScreen> createState() => _AstrologyScreenState();
}

class _AstrologyScreenState extends State<AstrologyScreen> {
  bool _on = false;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 58, bottom: 40),
        children: [
          _pad(ppBack(context, 'Explore')),

          const SizedBox(height: 22),
          _pad(ppEyebrow('Optional section', color: ppMuted, spacing: 1.2)),
          const SizedBox(height: 10),
          _pad(Text('Astrology & Numerology', style: ppFraunces(30, h: 1.12))),
          const SizedBox(height: 8),
          _pad(Text("Off by default. Turn it on to add cosmic notes to Aarav's world - you can switch it off anytime.",
              style: ppBody(15))),

          // toggle card
          const SizedBox(height: 22),
          _pad(Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppLine)),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.auto_awesome_outlined, size: 19, color: ppPurple),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Astrology & Numerology', style: ppJakarta(15)),
                      const SizedBox(height: 2),
                      Text("AI readings for Aarav, if you'd like them.", style: ppBody(12)),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                      key: const ValueKey('astro-toggle'),
                      onTap: () => setState(() => _on = !_on),
                      behavior: HitTestBehavior.opaque,
                      child: ppSwitch(_on)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Off by default. Turn on to add an Astrology tab to Aarav\'s profile. You can switch it off anytime.',
                      style: ppBody(12, color: ppMuted, h: 1.55)),
                ),
              ),
            ]),
          )),

          // culture note
          const SizedBox(height: 22),
          _pad(Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.lock_outline, size: 16, color: ppSoft),
              const SizedBox(width: 10),
              Expanded(child: Text('For those who value it. ParentVeda treats it as culture, not medical guidance.', style: ppBody(12, h: 1.5))),
            ]),
          )),

          if (!_on)
            _pad(Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(child: Text('Toggle it on to preview the reading →', style: ppBody(12, color: const Color(0xFFC7BBD6)))),
            ))
          else ...[
            _pad(ppSectionDivider()),

            _pad(ppEyebrow('Astrology & Numerology', color: ppBrown, spacing: 1.2)),
            const SizedBox(height: 10),
            _pad(Text("Aarav's cosmic notes", style: ppFraunces(30, h: 1.14))),
            const SizedBox(height: 8),
            _pad(Text('Born 8 March 2026 · 6:42 am · New Delhi', style: ppBody(13))),

            // horoscope card
            const SizedBox(height: 20),
            _pad(Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Color(0x802F2C30), blurRadius: 34, spreadRadius: -18, offset: Offset(0, 14))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(children: [
                  _starHero(),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ppEyebrow('This month', color: ppPurple, spacing: 0.8),
                      const SizedBox(height: 8),
                      Text(
                          'A gentle, watery month for your little Piscean. Expect him to be especially cuddly and tuned in to your moods - soft routines and calm evenings suit him best right now.',
                          style: ppBody(14, color: ppInk, h: 1.65)),
                    ]),
                  ),
                ]),
              ),
            )),

            // numerology
            const SizedBox(height: 16),
            _pad(Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(22)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Text('3', style: ppFraunces(24, color: ppPurple, h: 1.0)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Life-path number 3', style: ppJakarta(16)),
                      const SizedBox(height: 2),
                      Text('From his full date of birth', style: ppBody(12)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 14),
                Text('The number of expression and joy - a signal of a sociable, creative, chatty child. Give him room to make noise and play.',
                    style: ppBody(14, color: ppInk, h: 1.6)),
              ]),
            )),

            const SizedBox(height: 16),
            _pad(Row(children: [
              const Icon(Icons.autorenew_rounded, size: 14, color: ppMuted),
              const SizedBox(width: 8),
              Text('Refreshed monthly · last updated 1 July', style: ppBody(12, color: ppMuted)),
            ])),

            const SizedBox(height: 22),
            _pad(Text('AI-generated from date, time & place of birth. For cultural interest - not advice. Turn off anytime in Settings.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ],
      ),
    );
  }

  Widget _starHero() => SizedBox(
        height: 120,
        child: Stack(children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(center: Alignment(-0.4, -0.4), radius: 1.1, colors: [_starTop, ppInk]),
              ),
              child: CustomPaint(painter: _StarPainter()),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 14,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Pisces', style: ppFraunces(20, color: Colors.white, h: 1.0)),
                const SizedBox(width: 8),
                const Icon(Icons.water_drop_outlined, size: 15, color: Colors.white70),
              ]),
              const SizedBox(height: 3),
              Text('Sun sign · Moon in Taurus', style: ppBody(11, color: _moon)),
            ]),
          ),
        ]),
      );
}

// A scatter of tiny stars over the horoscope hero (fixed positions).
class _StarPainter extends CustomPainter {
  static const List<(double, double, double)> _stars = [
    (0.20, 0.35, 1.5),
    (0.60, 0.20, 1.5),
    (0.80, 0.55, 1.0),
    (0.45, 0.68, 1.0),
    (0.70, 0.42, 2.0),
    (0.30, 0.75, 1.2),
    (0.90, 0.28, 1.2),
    (0.12, 0.60, 1.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (final (fx, fy, r) in _stars) {
      canvas.drawCircle(Offset(fx * size.width, fy * size.height), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) => false;
}
