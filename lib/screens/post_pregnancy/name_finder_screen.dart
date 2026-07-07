// =============================================================================
//  NameFinderScreen - Baby Name Finder · quiz (parenting · S27)
// -----------------------------------------------------------------------------
//  The taste quiz that opens the Name Finder: who you're naming, the feel you
//  want, and an optional birth-star. Then both parents swipe - only mutual
//  yeses ever surface. Faithful build of Claude Design "post pregnancy -
//  content.dc.html" · S27. Reached from the Tools hub "Baby names" tracker row.
// =============================================================================

import 'package:flutter/material.dart';

import 'name_swipe_screen.dart';
import 'pp_common.dart';

const List<(IconData, String)> _genders = [
  (Icons.male_rounded, 'Boy'),
  (Icons.female_rounded, 'Girl'),
  (Icons.auto_awesome_outlined, 'Surprise'),
];

const List<String> _feels = ['Rooted & traditional', 'Modern & fresh', 'Rare & unique', 'Devotional'];

class NameFinderScreen extends StatefulWidget {
  const NameFinderScreen({super.key});

  @override
  State<NameFinderScreen> createState() => _NameFinderScreenState();
}

class _NameFinderScreenState extends State<NameFinderScreen> {
  int _gender = 0;
  int _feel = 0;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(top: 60, bottom: 108),
          children: [
            _pad(ppCircleBack(context, eyebrow: 'Together, in 30 seconds')),

            const SizedBox(height: 20),
            _pad(Text.rich(TextSpan(children: [
              const TextSpan(text: 'Find the name '),
              TextSpan(text: 'you both love.', style: ppFraunces(37, color: ppPurple, h: 1.08).copyWith(fontStyle: FontStyle.italic)),
            ]), style: ppFraunces(37, h: 1.08))),
            const SizedBox(height: 14),
            _pad(Text.rich(TextSpan(children: [
              TextSpan(text: 'A quick taste quiz, then you each swipe. We only show you the names you ', style: ppBody(15)),
              TextSpan(text: 'both', style: ppBody(15, w: FontWeight.w700).copyWith(fontStyle: FontStyle.italic)),
              TextSpan(text: " adore - nobody ever sees the other's no.", style: ppBody(15)),
            ]))),

            // Q1 - who
            const SizedBox(height: 22),
            _pad(Text('Question 1 of 6', style: ppBody(12, color: ppMuted, w: FontWeight.w600))),
            const SizedBox(height: 8),
            _pad(Text('Who are we naming?', style: ppJakarta(19))),
            const SizedBox(height: 16),
            _pad(Row(children: [
              for (var i = 0; i < _genders.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _genderCard(i)),
              ],
            ])),

            // Q2 - feel
            const SizedBox(height: 28),
            _pad(Text('The feel you want', style: ppJakarta(19))),
            const SizedBox(height: 16),
            _pad(Wrap(spacing: 10, runSpacing: 10, children: [
              for (var i = 0; i < _feels.length; i++) _feelChip(i),
            ])),

            // optional nakshatra
            const SizedBox(height: 26),
            _pad(GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You can add the birth star later'), behavior: SnackBarBehavior.floating),
              ),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.star_border_rounded, size: 18, color: ppPurple),
                    const SizedBox(width: 8),
                    Text('Birth star (optional)', style: ppJakarta(14)),
                  ]),
                  const SizedBox(height: 8),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: "Know the baby's nakshatra or rashi? Pick it and we'll favour names with the right starting sound. ", style: ppBody(13, h: 1.55)),
                    TextSpan(text: 'Tap to skip.', style: ppBody(13, color: ppMuted, h: 1.55)),
                  ])),
                ]),
              ),
            )),
          ],
        ),

        // top fade
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 52,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)]),
              ),
            ),
          ),
        ),

        // sticky CTA
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg]),
            ),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NameSwipeScreen())),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ppPurple,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 28, spreadRadius: -10, offset: Offset(0, 12))],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Start swiping', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                  const SizedBox(width: 8),
                  const Text('→', style: TextStyle(color: Colors.white, fontSize: 16)),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _genderCard(int i) {
    final on = i == _gender;
    return GestureDetector(
      onTap: () => setState(() => _gender = i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
        decoration: BoxDecoration(
          color: on ? ppStripeB : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: on ? ppPurple : ppLine, width: on ? 2 : 1),
        ),
        child: Column(children: [
          Icon(_genders[i].$1, size: 24, color: on ? ppPurple : ppSoft),
          const SizedBox(height: 8),
          Text(_genders[i].$2, style: ppJakarta(13)),
        ]),
      ),
    );
  }

  Widget _feelChip(int i) {
    final on = i == _feel;
    return GestureDetector(
      onTap: () => setState(() => _feel = i),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: on ? ppPurple : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: on ? null : Border.all(color: ppLine),
        ),
        child: Text(_feels[i], style: ppBody(13, color: on ? Colors.white : ppInk, w: on ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }
}
