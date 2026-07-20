// =============================================================================
//  Baby Naming Journey (V2) - Shortlist -> Compare -> Chosen -> Story
// -----------------------------------------------------------------------------
//  The closing arc of the journey:
//   • NameJourneyShortlistScreen - "Names We Both Love" (auto from matches).
//   • NameCompareScreen - a calm side-by-side (meaning, origin, say-it, length,
//     popularity, feel, numerology, nakshatra). We help parents SEE the
//     differences; we never recommend one.
//   • NameChosenScreen - "You've chosen Aarav" -> "A beautiful name deserves a
//     beautiful story" -> Begin the story, which opens the Journal to write
//     "The Story Behind My Name" as Chapter One.
// =============================================================================

import 'package:flutter/material.dart';

import 'journal_v2/journal_capture_screens.dart';
import 'name_journey_detail_screen.dart';
import 'pp_common.dart';
import 'pp_names_data.dart';
import 'pp_names_v2_data.dart';

class NameJourneyShortlistScreen extends StatelessWidget {
  const NameJourneyShortlistScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: NameMatchStore.instance,
          builder: (context, _) {
            final store = NameMatchStore.instance;
            final names = store.liked.map(babyNameByName).toList();
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Baby Names')),
                const SizedBox(height: 14),
                nameJourneyRibbon(active: 3),
                const SizedBox(height: 22),
                _pad(ppEyebrow('Names you love', color: ppPurple)),
                const SizedBox(height: 10),
                _pad(Text('Your shortlist', style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 6),
                _pad(Text('Every name you swiped right on gathers here - no manual saving. Compare them, then choose.', style: ppBody(14, h: 1.55))),

                const SizedBox(height: 22),
                if (names.isEmpty)
                  _pad(_empty())
                else ...[
                  _pad(Column(children: [for (final n in names) _nameRow(context, n, crowned: n.name == store.crowned)])),
                  const SizedBox(height: 18),
                  if (names.length >= 2)
                    _pad(GestureDetector(
                      onTap: () => _push(context, const NameCompareScreen()),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: ppInk, borderRadius: BorderRadius.circular(15)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.compare_arrows_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Compare these names', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                        ]),
                      ),
                    )),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _empty() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          const Icon(Icons.favorite_border, size: 28, color: ppPurple),
          const SizedBox(height: 12),
          Text('Nothing here yet', style: ppJakarta(16)),
          const SizedBox(height: 6),
          Text('Head back and swipe a few names you love - the ones you like will appear here.', textAlign: TextAlign.center, style: ppBody(13, h: 1.5)),
        ]),
      );

  Widget _nameRow(BuildContext context, BabyName n, {required bool crowned}) => GestureDetector(
        onTap: () => _push(context, NameJourneyDetailScreen(name: n.name)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: crowned ? ppPurple : ppHair, width: crowned ? 1.5 : 1),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(n.name, style: ppFraunces(22, h: 1.05)),
                  const SizedBox(width: 8),
                  Text(n.script, style: ppFraunces(16, color: ppPurple)),
                  if (crowned) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded, size: 16, color: ppCoral),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(n.meaningShort, style: ppBody(13, h: 1.4), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}

// =============================================================================
//  NameCompareScreen - a calm side-by-side (never a recommendation)
// =============================================================================
class NameCompareScreen extends StatelessWidget {
  const NameCompareScreen({super.key});

  static const double _labelW = 92;
  static const double _colW = 150;
  static const double _rowH = 74;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  static final List<(String, String Function(BabyName))> _dims = [
    ('Meaning', (n) => n.meaningShort),
    ('Origin', (n) => n.origin),
    ('Say it', (n) => n.pron),
    ('Length', (n) => '${n.syllables} syllables'),
    ('Popularity', (n) => n.popularity),
    ('Feel', (n) => n.feel),
    ('Numerology', (n) => '${n.numerology}'),
    ('Nakshatra', (n) => n.nakshatra),
  ];

  @override
  Widget build(BuildContext context) {
    final names = NameMatchStore.instance.liked.map(babyNameByName).take(6).toList();
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Shortlist')),
            const SizedBox(height: 14),
            nameJourneyRibbon(active: 4),
            const SizedBox(height: 22),
            _pad(ppEyebrow('Compare', color: ppPurple)),
            const SizedBox(height: 10),
            _pad(Text('See them side by side', style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 8),
            _pad(Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(15)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.auto_awesome, size: 15, color: ppPurple),
                const SizedBox(width: 10),
                Expanded(child: Text(decisionCompare(names), style: ppBody(12.5, h: 1.5))),
              ]),
            )),
            const SizedBox(height: 20),
            if (names.length < 2)
              _pad(Text('Add at least two names to your shortlist to compare them.', style: ppBody(13, color: ppMuted)))
            else
              _table(names),
          ],
        ),
      ),
    );
  }

  Widget _table(List<BabyName> names) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // fixed dimension labels
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 44), // aligns with the name header row
            for (final d in _dims)
              SizedBox(
                width: _labelW,
                height: _rowH,
                child: Align(alignment: Alignment.centerLeft, child: Text(d.$1.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.5))),
              ),
          ]),
          // scrollable name columns
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final n in names)
                  Container(
                    width: _colW,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(
                        height: 44,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Align(alignment: Alignment.centerLeft, child: Text(n.name, style: ppFraunces(20, h: 1.0), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ),
                      ),
                      for (final d in _dims)
                        Container(
                          width: _colW,
                          height: _rowH,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair))),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(d.$2(n), style: ppBody(12, color: ppInk, h: 1.35), maxLines: 3, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                    ]),
                  ),
              ]),
            ),
          ),
        ]),
      );
}

// =============================================================================
//  NameChosenScreen - the final selection, flowing into the Journal
// =============================================================================
class NameChosenScreen extends StatelessWidget {
  const NameChosenScreen({super.key, required this.name});
  final String name;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final n = babyNameByName(name);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Back')),
            const SizedBox(height: 14),
            nameJourneyRibbon(active: 5),
            const SizedBox(height: 30),
            _pad(Center(child: Column(children: [
              const Icon(Icons.favorite, size: 30, color: ppCoral),
              const SizedBox(height: 16),
              Text("You've chosen", style: ppBody(14, color: ppSoft, w: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(n.name, textAlign: TextAlign.center, style: ppFraunces(52, h: 1.0)),
              const SizedBox(height: 4),
              Text(n.script, style: ppFraunces(26, color: ppPurple)),
              const SizedBox(height: 12),
              Text('“${n.meaningFull}”', textAlign: TextAlign.center, style: ppFraunces(17, h: 1.45)),
            ]))),

            const SizedBox(height: 30),
            _pad(Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFE6D8F1)]),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('A beautiful name deserves a beautiful story.', style: ppFraunces(20, h: 1.3)),
                const SizedBox(height: 8),
                Text('Write why you chose ${n.name} - what it means to your family, who suggested it, the memory behind it. It becomes Chapter One of ${n.name}\'s journal.', style: ppBody(13.5, h: 1.6)),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WriteStoryScreen())),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                    decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.edit_note_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Flexible(child: Text("Begin ${n.name}'s story", maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(14, color: Colors.white, w: FontWeight.w700))),
                    ]),
                  ),
                ),
              ]),
            )),

            const SizedBox(height: 16),
            _pad(Row(children: [
              const Icon(Icons.check_circle_outline_rounded, size: 16, color: ppPurple),
              const SizedBox(width: 10),
              Expanded(child: Text('${n.name} will gently flow through ParentVeda - Child Profile, Journal, Storybook and Namkaran - so you never enter it again.', style: ppBody(12.5, color: ppSoft, h: 1.5))),
            ])),
          ],
        ),
      ),
    );
  }
}
