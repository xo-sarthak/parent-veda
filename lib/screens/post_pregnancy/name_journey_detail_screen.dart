// =============================================================================
//  NameJourneyDetailScreen — V2 "Deep Dive" (every name's beautiful page)
// -----------------------------------------------------------------------------
//  The star of the journey: meaning, pronunciation, origin, script, mythology,
//  numerology, nakshatra and similar names, PLUS the three V2 heroes — the AI
//  Name Story (the name's personality, beautifully written), the ParentVeda
//  Perspective (educate, never influence), the Decision Companion ("help me
//  decide": why parents choose it, alternatives, nicknames, international
//  pronunciation), and a Name Preview (seeing the name in the child's world).
//  Parents should leave feeling "I now understand this name."
// =============================================================================

import 'package:flutter/material.dart';

import 'name_journey_shortlist_screen.dart';
import 'pp_common.dart';
import 'pp_names_data.dart';
import 'pp_names_v2_data.dart';

class NameJourneyDetailScreen extends StatelessWidget {
  const NameJourneyDetailScreen({super.key, required this.name});
  final String name;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    final n = babyNameByName(name);
    final v2 = nameV2(n);
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 120),
            children: [
              _pad(ppBack(context, 'Back')),
              const SizedBox(height: 14),
              nameJourneyRibbon(active: 1),

              // hero
              const SizedBox(height: 24),
              _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: _tag(n.feel, ppPurple)),
                  const SizedBox(width: 8),
                  Flexible(child: _tag(n.popularity, ppCoral)),
                ]),
                const SizedBox(height: 16),
                Text(n.name, style: ppFraunces(46, h: 1.0)),
                const SizedBox(height: 4),
                Text(n.script, style: ppFraunces(26, color: ppPurple, h: 1.1)),
                const SizedBox(height: 14),
                Row(children: [
                  Container(width: 34, height: 34, alignment: Alignment.center, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle), child: const Icon(Icons.volume_up_rounded, size: 17, color: Colors.white)),
                  const SizedBox(width: 10),
                  Text(n.pron, style: ppBody(14, color: ppInk, w: FontWeight.w600)),
                ]),
                const SizedBox(height: 16),
                Text('“${n.meaningFull}”', style: ppFraunces(18, h: 1.45)),
              ])),

              // AI Name Story
              _sectionDivider(),
              _pad(_iconHead(Icons.auto_awesome_rounded, 'The story of this name')),
              const SizedBox(height: 12),
              _pad(Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF6F1FC), Color(0xFFF3ECF8)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(v2.aiStory, style: ppBody(14.5, color: ppInk, h: 1.65)),
              )),

              // ParentVeda perspective
              const SizedBox(height: 16),
              _pad(Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ppEyebrow('The ParentVeda perspective', color: ppPurple, spacing: 0.8),
                  const SizedBox(height: 8),
                  Text(n.perspective, style: ppBody(13.5, color: ppInk, h: 1.6)),
                ]),
              )),

              // facts
              _sectionDivider(),
              _pad(_iconHead(Icons.info_outline_rounded, 'The essentials')),
              const SizedBox(height: 14),
              _pad(Row(children: [
                Expanded(child: _fact('Origin', n.origin)),
                const SizedBox(width: 10),
                Expanded(child: _fact('Syllables', '${n.syllables}')),
              ])),
              const SizedBox(height: 10),
              _pad(Row(children: [
                Expanded(child: _fact('Numerology', '${n.numerology} · tradition')),
                const SizedBox(width: 10),
                Expanded(child: _fact('Popularity', n.popularity)),
              ])),
              const SizedBox(height: 14),
              _pad(_softRow(Icons.menu_book_outlined, 'Mythology & history', n.famous)),
              const SizedBox(height: 10),
              _pad(_softRow(Icons.star_border_rounded, 'Nakshatra fit', n.nakshatra)),

              // Decision Companion
              _sectionDivider(),
              _pad(_iconHead(Icons.compare_arrows_rounded, 'Help me decide')),
              const SizedBox(height: 6),
              _pad(Text('The Decision Companion helps you feel confident — it never chooses for you.', style: ppBody(12.5, color: ppMuted))),
              const SizedBox(height: 14),
              _pad(_softRow(Icons.favorite_border, 'Why parents choose ${n.name}', v2.decisionWhy)),
              if (v2.nicknames.isNotEmpty) ...[
                const SizedBox(height: 10),
                _pad(_chipsRow('Sweet nicknames', v2.nicknames)),
              ],
              if (v2.intlPron.isNotEmpty) ...[
                const SizedBox(height: 10),
                _pad(_softRow(Icons.public_rounded, 'Around the world', v2.intlPron)),
              ],
              if (v2.alternatives.isNotEmpty) ...[
                const SizedBox(height: 14),
                _pad(Text('If you love ${n.name}, you might also love', style: ppBody(13, color: ppSoft, w: FontWeight.w700))),
                const SizedBox(height: 10),
                _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final a in v2.alternatives) _linkChip(context, a),
                ])),
              ],

              // Name Preview
              _sectionDivider(),
              _pad(_iconHead(Icons.auto_stories_outlined, 'Picture the name')),
              const SizedBox(height: 6),
              _pad(Text('See ${n.name} the way you soon will — everywhere, every day.', style: ppBody(12.5, color: ppMuted))),
              const SizedBox(height: 16),
              _previewRail(n.name),
            ],
          ),
        ),

        // sticky actions
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
            decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg])),
            child: AnimatedBuilder(
              animation: NameMatchStore.instance,
              builder: (context, _) {
                final liked = NameMatchStore.instance.isLiked(n.name);
                return Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => NameMatchStore.instance.like(n.name),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: liked ? ppPurple : ppLine)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(liked ? Icons.favorite : Icons.favorite_border, size: 18, color: ppPurple),
                          const SizedBox(width: 8),
                          Flexible(child: Text(liked ? 'In your shortlist' : 'Add to shortlist', maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(14, color: ppPurple, w: FontWeight.w700))),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        NameMatchStore.instance.crown(n.name);
                        _push(context, NameChosenScreen(name: n.name));
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 24, spreadRadius: -10, offset: Offset(0, 10))]),
                        child: Text('Choose this name', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ),
      ]),
    );
  }

  Widget _sectionDivider() => const Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24), child: SizedBox(height: 1, child: ColoredBox(color: ppLine)));

  Widget _iconHead(IconData icon, String title) => Row(children: [
        Icon(icon, size: 19, color: ppPurple),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: ppJakarta(17))),
      ]);

  Widget _tag(String t, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(color: fg.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
        child: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(10.5, color: fg, w: FontWeight.w700)),
      );

  Widget _fact(String label, String value) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
          const SizedBox(height: 6),
          Text(value, style: ppJakarta(14).copyWith(height: 1.25)),
        ]),
      );

  Widget _softRow(IconData icon, String label, String value) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 15, color: ppPurple), const SizedBox(width: 8), Text(label, style: ppJakarta(13.5))]),
          const SizedBox(height: 7),
          Text(value, style: ppBody(13, h: 1.55)),
        ]),
      );

  Widget _chipsRow(String label, List<String> chips) => Row(children: [
        Text('$label:', style: ppBody(13, color: ppSoft, w: FontWeight.w700)),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in chips)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                child: Text(c, style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
              ),
          ]),
        ),
      ]);

  Widget _linkChip(BuildContext context, String otherName) => GestureDetector(
        onTap: () => _push(context, NameJourneyDetailScreen(name: otherName)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: ppBorder)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(otherName, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward, size: 13, color: ppPurple),
          ]),
        ),
      );

  // ---- name preview rail (seeing the name in the child's world) -----------
  Widget _previewRail(String name) {
    const items = <(String, IconData, List<Color>)>[
      ('Journal cover', Icons.menu_book_outlined, [Color(0xFFF1EAF8), Color(0xFFE6D8F1)]),
      ('Storybook', Icons.auto_stories_outlined, [Color(0xFFFFF1F4), Color(0xFFF7E9EF)]),
      ('Birthday card', Icons.cake_outlined, [Color(0xFFFDF3E7), Color(0xFFF6ECD9)]),
      ('Announcement', Icons.celebration_outlined, [Color(0xFFEAF4EE), Color(0xFFDCEDE3)]),
      ('Namkaran invite', Icons.temple_hindu_outlined, [Color(0xFFF3ECF8), Color(0xFFEBDDF3)]),
    ];
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final it = items[i];
          return Container(
            width: 150,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
            clipBehavior: Clip.antiAlias,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: it.$3)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(it.$2, size: 20, color: ppPurple.withValues(alpha: 0.7)),
                      const SizedBox(height: 8),
                      Text(name, textAlign: TextAlign.center, style: ppFraunces(24, h: 1.05), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(it.$1, style: ppBody(12, color: ppSoft, w: FontWeight.w700)),
              ),
            ]),
          );
        },
      ),
    );
  }
}
