// =============================================================================
//  AstrologyScreen - Astrology & Numerology · opt-in (parenting · S23)
// -----------------------------------------------------------------------------
//  An explicitly optional, off-by-default section. The toggle reveals Aarav's
//  "cosmic notes" - a monthly horoscope card and a life-path numerology card -
//  framed as culture, not medical guidance. Faithful build of Claude Design
//  "post pregnancy - content.dc.html" · S23 (both OFF + ON states in one
//  screen). Reached from the Explore drawer.
//
//  ON THE ONE PARENTVEDA LOOK (2026-10-07). The shared tool shell
//  (`PregToolScaffold`): the field, the round back, a drawn lamp (the
//  ritual-and-tradition mark), eyebrow, serif title, the intro, the sheet. The
//  switch sits on its own white row; the readings are white hairline cards.
//
//  ⚠️ TRADITION, NOT PREDICTION, AND NOTHING MADE UP. The new build:
//   · labels the readings "A sample reading" and "What the tradition says",
//     and rewrites the two readings without "expect" (a forecast) and without
//     "him/his" (the child may be a girl);
//   · leaves out the invented birth line ("Born 8 March 2026 · 6:42 am · New
//     Delhi"), the invented "last updated 1 July", "AI readings" and
//     "AI-generated" (nothing is generated: the text is fixed), and the claim
//     that switching it on adds an Astrology tab to the child's profile (no such
//     tab exists, and the switch is not saved);
//   · keeps every "culture, not medical guidance / not advice" line.
//  The old build is kept below as `_buildBeforeShell`, for revert only.
//
//  Mobbin: BitePal's "Enable fasting" — the one switch on its own white row
//  above what it turns on
//  https://mobbin.com/screens/2bd8b69c-9702-4d31-9470-c000e8fd7058
//  and Tinder Astrology's "About You" — a small coloured label ("Sun in
//  Pisces") over a bold heading and a short paragraph
//  https://mobbin.com/screens/cce1e97e-da86-4a13-836a-3014f279cd62
//  Taken: the switch row, the label-heading-paragraph reading. Not taken:
//  Tinder's purple starfield (no purple; the field is our tint).
// =============================================================================

import 'package:flutter/material.dart';
import 'pp_child_profile.dart';

import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart' show PvMarkWell;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show kPvLine, pvStorePalette;
import 'pp_care_parts.dart' show ppCareHeading;
import 'pp_common.dart';
import '../../widgets/pv_feedback.dart' show PvPress;

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

  // ---- the one-ParentVeda build (2026-10-07) --------------------------------

  static const double _hue = 262;

  Widget _eyebrowV2(String t) => Text(t.toUpperCase(),
      style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: pvStorePalette.action));

  Widget _cardV2({Key? key, required Widget child}) => Container(
        key: key,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPvLine),
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final child = ChildProfileStore.instance;
    final body = pvManrope(fontSize: 13.5, height: 1.6, color: p.ink2);
    return PregToolScaffold(
      hue: _hue,
      mark: IntentMark.lampMark,
      eyebrow: 'Optional section',
      title: 'Astrology & Numerology',
      intro:
          "Off by default. Turn it on to add cosmic notes to ${child.nameMid}'s world - you can switch it off anytime.",
      children: [
        // The switch, on its own row.
        pregToolPad(_cardV2(
          child: Row(children: [
            PvMarkWell(p: p, hue: _hue, size: 40, mark: IntentMark.lampMark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Show cosmic notes',
                    style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
                const SizedBox(height: 2),
                Text("Notes from the tradition for ${child.nameMid}, if you'd like them.",
                    style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
              ]),
            ),
            const SizedBox(width: 8),
            Switch(
              key: const ValueKey('astro-toggle'),
              value: _on,
              onChanged: (v) => setState(() => _on = v),
            ),
          ]),
        )),

        const SizedBox(height: 12),
        pregToolPad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline_rounded, size: 16, color: p.ink3),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('For those who value it. ParentVeda treats it as culture, not medical guidance.',
                style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2)),
          ),
        ])),

        if (!_on)
          pregToolPad(Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text('Switch it on to preview a sample reading.',
                style: pvManrope(fontSize: 12.5, color: p.ink3)),
          ))
        else ...[
          const SizedBox(height: 28),
          pregToolPad(_eyebrowV2('A sample reading')),
          const SizedBox(height: 8),
          pregToolPad(ppCareHeading("${child.name}'s cosmic notes")),
          const SizedBox(height: 6),
          pregToolPad(Text('What the tradition says, for those who value it. A tradition, not a prediction.',
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2))),

          const SizedBox(height: 16),
          pregToolPad(_cardV2(
            key: const ValueKey('astro_sign_card'),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _eyebrowV2('Sun sign · Pisces'),
              const SizedBox(height: 6),
              Text('What the tradition says this month',
                  style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, height: 1.25, color: p.ink1)),
              const SizedBox(height: 8),
              Text(
                  'Tradition reads a Pisces month as gentle and watery: a time for extra cuddles, soft routines and calm evenings.',
                  style: body),
            ]),
          )),

          const SizedBox(height: 12),
          pregToolPad(_cardV2(
            key: const ValueKey('astro_number_card'),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kPvLine),
                  ),
                  child: Text('3', style: pvFraunces(fontSize: 24, fontWeight: FontWeight.w600, color: p.ink1)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Life-path number 3',
                        style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
                    const SizedBox(height: 2),
                    Text('From the full date of birth', style: pvManrope(fontSize: 12.5, color: p.ink2)),
                  ]),
                ),
              ]),
              const SizedBox(height: 12),
              Text(
                  'In numerology, 3 is the number of expression and joy, traditionally read as sociable, creative and chatty. Room to make noise and play suits every child.',
                  style: body),
            ]),
          )),

          const SizedBox(height: 18),
          pregToolPad(Text(
              'For cultural interest - not advice, and never a guide to health or development. Switch it off here any time.',
              style: pvManrope(fontSize: 12, height: 1.55, color: p.ink3))),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  // ---- the purple build, before the one-ParentVeda look ---------------------
  // Kept for revert (2026-10-07). It carries the invented birth line, the
  // "AI" wording and he/him readings that the new build leaves out.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
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
          _pad(Text("Off by default. Turn it on to add cosmic notes to ${ChildProfileStore.instance.nameMid}'s world - you can switch it off anytime.",
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
                      Text("AI readings for ${ChildProfileStore.instance.nameMid}, if you'd like them.", style: ppBody(12)),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  PvPress(child: GestureDetector(
                      key: const ValueKey('astro-toggle'),
                      onTap: () => setState(() => _on = !_on),
                      behavior: HitTestBehavior.opaque,
                      child: ppSwitch(_on))),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  // The page subtitle a few lines up already says "off by
                  // default … switch it off anytime". Repeating it verbatim
                  // inside the card read as the app not trusting you to have
                  // read its own first paragraph. This says the one thing the
                  // subtitle does not: WHERE the section shows up once it is on.
                  child: Text('Turn this on and an Astrology tab appears on ${ChildProfileStore.instance.nameMid}\'s profile.',
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
            _pad(Text("${ChildProfileStore.instance.name}'s cosmic notes", style: ppFraunces(30, h: 1.14))),
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
