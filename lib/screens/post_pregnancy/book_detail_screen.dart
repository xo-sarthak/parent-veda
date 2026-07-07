// =============================================================================
//  BookDetailScreen - Recommendations · book detail (parenting · S16·book)
// -----------------------------------------------------------------------------
//  A single recommended book: the ParentVeda take, what's good / consider,
//  who it's for, verified-parent reviews, and buy links. Reached from
//  Recommendations → Books → any book. Faithful build of Claude Design ·
//  S16·book. Pushed screen (no bottom nav).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  static const Color _green = Color(0xFF1F8A5B);

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening the store soon'), behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Recommendations')),

            // cover
            const SizedBox(height: 22),
            Center(
              child: Container(
                width: 140,
                height: 182,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ppBorder),
                  boxShadow: ppCardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: const PpStriped(height: 190),
              ),
            ),

            const SizedBox(height: 20),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFEAF6EF), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_rounded, size: 12, color: _green),
                const SizedBox(width: 5),
                Text('ParentVeda pick', style: ppBody(11, color: _green, w: FontWeight.w700)),
              ]),
            )),
            const SizedBox(height: 12),
            _pad(Text("That's Not My Tiger", style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 6),
            _pad(Text('Fiona Watt · touch-and-feel board book', style: ppBody(14))),
            const SizedBox(height: 12),
            _pad(Row(children: [
              Text('★★★★★', style: ppBody(13, color: ppCoral, w: FontWeight.w700)),
              const SizedBox(width: 8),
              Flexible(child: Text('4.8 · 176 parents', style: ppBody(13, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                child: Text('0–1 yr', style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
              ),
            ])),

            // the take
            const SizedBox(height: 26),
            _pad(Text('The ParentVeda take', style: ppJakarta(18))),
            const SizedBox(height: 8),
            _pad(Text(
                "One of the best first books you can own. The high-contrast pages hold a 4-month-old's gaze, and the textured patches give little hands their first reason to reach and explore - exactly the Leap 4 skill Aarav's building now. Sturdy enough to survive being chewed.",
                style: ppBody(15, h: 1.6))),

            // what's good / consider
            const SizedBox(height: 24),
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ppEyebrow("What's good", color: _green, spacing: 0.6),
                  const SizedBox(height: 10),
                  _good('Bold, high-contrast art'),
                  _good('Real textures to touch'),
                  _good('Thick, chew-proof pages'),
                ]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ppEyebrow('Consider', color: ppMuted, spacing: 0.6),
                  const SizedBox(height: 10),
                  _con('Very short - read on repeat'),
                  _con('Grows out of it by ~2'),
                ]),
              ),
            ])),

            // choose this if
            const SizedBox(height: 24),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Choose this if…', color: ppBrown, spacing: 0.8),
                const SizedBox(height: 8),
                Text(
                    "you want a first book that's as much a toy as a story - for reaching, touching and gazing.",
                    style: ppBody(14, color: ppInk, h: 1.55)),
              ]),
            )),

            // reviews
            const SizedBox(height: 28),
            _pad(Text('From verified parents', style: ppJakarta(18))),
            const SizedBox(height: 4),
            _pad(Text('Named, with child & age - never anonymous.', style: ppBody(12))),
            const SizedBox(height: 14),
            _pad(_review('Priya', 'mother of Aarav (4 mo)', '★★★★★',
                '“The only book that makes him go still and stare. The fuzzy patches get the biggest reaction.”',
                top: true)),
            _pad(_review('Ritu', 'mother of Vivaan (9 mo)', '★★★★☆',
                '“Survived six months of chewing. Worth every rupee.”',
                bottom: true)),

            // buy
            const SizedBox(height: 24),
            _pad(GestureDetector(
              onTap: () => _soon(context),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                child: Text('Buy on Amazon · ₹299', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
              ),
            )),
            const SizedBox(height: 14),
            _pad(Row(children: [
              Text('Also on', style: ppBody(13, color: ppMuted)),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(spacing: 10, runSpacing: 8, children: [
                  _store(context, 'FirstCry'),
                  _store(context, 'Crossword'),
                ]),
              ),
            ])),

            const SizedBox(height: 22),
            _pad(Text('Reviews are from verified ParentVeda parents. No anonymous reviews, ever.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _good(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check_rounded, size: 16, color: _green),
          const SizedBox(width: 8),
          Expanded(child: Text(t, style: ppBody(13, color: ppInk, h: 1.4))),
        ]),
      );

  Widget _con(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(color: ppMuted, shape: BoxShape.circle),
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(t, style: ppBody(13, color: ppInk, h: 1.4))),
        ]),
      );

  Widget _review(String name, String who, String stars, String quote,
          {bool top = false, bool bottom = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '$name ', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                  TextSpan(text: '· $who', style: ppBody(13, color: ppMuted)),
                ]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(stars, style: ppBody(12, color: ppCoral, w: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Text(quote, style: ppBody(14, color: ppInk, h: 1.55)),
        ]),
      );

  Widget _store(BuildContext context, String label) => GestureDetector(
        onTap: () => _soon(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: ppBorder)),
          child: Text(label, style: ppBody(12, color: ppInk, w: FontWeight.w700)),
        ),
      );
}
