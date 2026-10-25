// =============================================================================
//  NameAstrologyScreen + NameNumerologyScreen - the two tile deep-dives
// -----------------------------------------------------------------------------
//  Opened from the "Astrology" and "Numerology" tiles on the name detail page.
//  Both are derived (no per-name astro data): the name's Chaldean number maps to
//  a ruling planet and vibe (kNumerology / numProfile), and the name already
//  carries a nakshatra-fit line. Offered gently as tradition, never as fact.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../pregnancy/preg_chrome.dart' show PregNote;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show pvStorePalette;
import '../v2/v2_palette.dart';
import 'pp_common.dart';
import 'pp_names_data.dart';

// ⚠️ TRADITION, SAID AS TRADITION (tools pass 31, O7). These pages stated
// custom as fact: "RULING PLANET", "Auspicious for Aanya", a lucky day, and a
// paragraph about the CHILD ("a child who likes to do things their own way").
// A name cannot tell a parent who her child will be, and the app must not
// sound as if it can. The tiles stay, because families ask for them; every
// line now says whose belief it is, and the note that says so comes FIRST,
// not at the foot. The pages also move onto the tools' shell: no lavender, no
// purple gradient. The pages before are `_buildBeforeShell`, kept for revert.
const String _kAstroNote = 'A family tradition, not a prediction. A name does not '
    'decide who your child will be. For a chart, a family astrologer works from '
    'the exact birth time and place.';

Widget _astroRow(V2Palette p, String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: p.ink3)),
        const SizedBox(height: 4),
        Text(value, style: pvManrope(fontSize: 15, height: 1.5, color: p.ink1)),
      ]),
    );

Widget _astroCard(V2Palette p, List<Widget> rows) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );

class NameAstrologyScreen extends StatelessWidget {
  const NameAstrologyScreen({super.key, required this.name});
  final String name;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final n = babyNameByName(name);
    final num = numProfile(n.numerology);
    final p = pvStorePalette;
    return PregToolScaffold(
      hue: 268,
      eyebrow: 'Astrology · a family tradition',
      title: 'The stars for ${n.name}',
      intro: 'What families who follow jyotish link with this name, offered the way an elder might.',
      children: [
        pregToolPad(PregNote(_kAstroNote, icon: Icons.info_outline_rounded)),
        const SizedBox(height: 16),
        pregToolPad(_astroCard(p, [
          _astroRow(p, 'Traditionally linked to', '${num.planet}, through name-number ${n.numerology}'),
          _astroRow(p, 'Nakshatra and sound', n.nakshatra),
        ])),
        const SizedBox(height: 16),
        pregToolPad(Text('Families who follow this say', style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1))),
        const SizedBox(height: 8),
        pregToolPad(_astroCard(p, [
          _astroRow(p, 'Day', num.luckyDay),
          _astroRow(p, 'Element', num.element),
          _astroRow(p, 'Colours', num.luckyColour),
        ])),
      ],
    );
  }

  // Kept for revert (tools pass 31): the page before the shell and the hedged words.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    final n = babyNameByName(name);
    final p = numProfile(n.numerology);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, n.name)),
            const SizedBox(height: 18),
            _pad(ppEyebrow('Astrology · a gentle tradition', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('The stars for ${n.name}', style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 8),
            _pad(Text('Offered the way an elder might - warmly, and never as the last word.', style: ppBody(13.5, h: 1.55))),

            // ruling planet hero
            const SizedBox(height: 22),
            _pad(Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF5A3E8A), Color(0xFF2A2733)]),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(children: [
                Container(width: 56, height: 56, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), shape: BoxShape.circle), child: const Icon(Icons.brightness_5_rounded, size: 26, color: Colors.white)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('RULING PLANET', style: ppBody(10, color: Colors.white.withValues(alpha: 0.75), w: FontWeight.w700).copyWith(letterSpacing: 1.0)),
                  const SizedBox(height: 4),
                  Text(p.planet, style: ppFraunces(26, color: Colors.white, h: 1.0)),
                  const SizedBox(height: 4),
                  Text('A ${p.vibe.toLowerCase()} influence, from name-number ${n.numerology}.', style: ppBody(12.5, color: Colors.white.withValues(alpha: 0.9), h: 1.4)),
                ])),
              ]),
            )),

            // nakshatra fit
            const SizedBox(height: 18),
            _pad(_card(Icons.star_border_rounded, 'Nakshatra & sound', n.nakshatra)),

            // lucky elements
            const SizedBox(height: 18),
            _pad(Text('Auspicious for ${n.name}', style: ppJakarta(16))),
            const SizedBox(height: 12),
            _pad(Row(children: [
              Expanded(child: _tile('Lucky day', p.luckyDay, Icons.today_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _tile('Element', p.element, Icons.spa_outlined)),
            ])),
            const SizedBox(height: 10),
            _pad(_tile('Lucky colours', p.luckyColour, Icons.palette_outlined, wide: true)),

            const SizedBox(height: 22),
            _pad(Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: ppSoft),
                const SizedBox(width: 10),
                Expanded(child: Text('This is a warm tradition, not a prediction. For a precise chart, your family astrologer works from the exact birth time and place.', style: ppBody(12.5, color: ppSoft, h: 1.5))),
              ]),
            )),
          ],
        ),
      ),
    );
  }

  Widget _card(IconData icon, String label, String body) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 16, color: ppPurple), const SizedBox(width: 8), Text(label, style: ppJakarta(14))]),
          const SizedBox(height: 8),
          Text(body, style: ppBody(13.5, h: 1.55)),
        ]),
      );

  Widget _tile(String label, String value, IconData icon, {bool wide = false}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
        child: Row(children: [
          Icon(icon, size: 18, color: ppPurple),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
            const SizedBox(height: 3),
            Text(value, style: ppJakarta(13.5), maxLines: wide ? 2 : 1, overflow: TextOverflow.ellipsis),
          ])),
        ]),
      );
}

class NameNumerologyScreen extends StatelessWidget {
  const NameNumerologyScreen({super.key, required this.name});
  final String name;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final n = babyNameByName(name);
    final num = numProfile(n.numerology);
    final p = pvStorePalette;
    return PregToolScaffold(
      hue: 268,
      eyebrow: 'Numerology · a family tradition',
      title: "${n.name}'s number is ${n.numerology}",
      intro: "Worked out from the Chaldean values of the name's letters, added and reduced to one digit.",
      children: [
        pregToolPad(PregNote(_kAstroNote, icon: Icons.info_outline_rounded)),
        const SizedBox(height: 16),
        // The blurb about the CHILD ("a child who likes to do things their own
        // way") is not shown: it predicts a person from a name. Kept in the data.
        pregToolPad(_astroCard(p, [
          _astroRow(p, 'In numerology, ${n.numerology} is linked with', '${num.vibe} (${num.planet})'),
          _astroRow(p, 'The words the tradition uses', num.traits),
          _astroRow(p, 'Day and colours it is linked with', '${num.luckyDay} · ${num.luckyColour}'),
        ])),
      ],
    );
  }

  // Kept for revert (tools pass 31): the page before the shell and the hedged words.
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
    final n = babyNameByName(name);
    final p = numProfile(n.numerology);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, n.name)),
            const SizedBox(height: 18),
            _pad(ppEyebrow('Numerology · Chaldean', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text("${n.name}'s number is ${n.numerology}", style: ppFraunces(30, h: 1.1))),

            // number hero
            const SizedBox(height: 20),
            _pad(Row(children: [
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8A63C8), ppPurple]), shape: BoxShape.circle),
                child: Text('${n.numerology}', style: ppFraunces(40, color: Colors.white, h: 1.0)),
              ),
              const SizedBox(width: 18),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.vibe, style: ppFraunces(24, h: 1.05)),
                const SizedBox(height: 4),
                Text('Ruled by ${p.planet}', style: ppBody(13.5, color: ppPurple, w: FontWeight.w700)),
              ])),
            ])),

            const SizedBox(height: 20),
            _pad(Text(p.blurb, style: ppBody(14.5, color: ppInk, h: 1.65))),

            const SizedBox(height: 18),
            _pad(Text('Often described as', style: ppJakarta(15))),
            const SizedBox(height: 10),
            _pad(Wrap(spacing: 8, runSpacing: 8, children: [
              for (final t in p.traits.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                  child: Text(t, style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
                ),
            ])),

            const SizedBox(height: 20),
            _pad(Row(children: [
              Expanded(child: _tile('Lucky day', p.luckyDay, Icons.today_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _tile('Lucky colours', p.luckyColour, Icons.palette_outlined)),
            ])),

            const SizedBox(height: 22),
            _pad(Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.calculate_outlined, size: 16, color: ppSoft),
                const SizedBox(width: 10),
                Expanded(child: Text('The number comes from the Chaldean values of the name\'s letters, added and reduced to a single digit. A lovely tradition to sit with - never a rule to be bound by.', style: ppBody(12.5, color: ppSoft, h: 1.5))),
              ]),
            )),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value, IconData icon) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
        child: Row(children: [
          Icon(icon, size: 18, color: ppPurple),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
            const SizedBox(height: 3),
            Text(value, style: ppJakarta(13.5), maxLines: 2, overflow: TextOverflow.ellipsis),
          ])),
        ]),
      );
}
