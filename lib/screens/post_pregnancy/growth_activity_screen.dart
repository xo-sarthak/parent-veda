// =============================================================================
//  GrowthActivityScreen — Growth · activity detail (parenting app · S8)
// -----------------------------------------------------------------------------
//  A play, fully explained: why it works → how to play (numbered) → mark-done →
//  optional extensions → go-deeper. Faithful build of Claude Design S8. Reached
//  from Home → Today's play → How to play.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class GrowthActivityScreen extends StatefulWidget {
  const GrowthActivityScreen({super.key});

  @override
  State<GrowthActivityScreen> createState() => _GrowthActivityScreenState();
}

class _GrowthActivityScreenState extends State<GrowthActivityScreen> {
  bool _done = false;
  bool _liked = false;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, "Today's play")),

            const SizedBox(height: 24),
            _pad(ppEyebrow('Grow · 5 min')),
            const SizedBox(height: 10),
            _pad(Text('Peekaboo, slow and silly', style: ppFraunces(31, h: 1.15))),

            const SizedBox(height: 20),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Why it works', color: ppPurple, spacing: 0.8),
                const SizedBox(height: 8),
                Text(
                    "Leap 4 is all about cause and effect. Hiding your face and reappearing teaches Aarav that you still exist when you vanish — the very first seed of object permanence, and a gentle antidote to this month's clinginess.",
                    style: ppBody(14, color: ppInk, h: 1.6)),
              ]),
            )),

            _pad(ppSectionDivider()),
            _pad(ppEyebrow('How to play', color: ppSoft, spacing: 1.2)),
            const SizedBox(height: 6),
            _pad(_step('01', 'Cover your face with your hands, or a light muslin cloth.', top: true)),
            _pad(_step('02', 'Pause a beat — let him wonder where you went.', top: true)),
            _pad(_step('03', 'Reappear with a bright "peekaboo!" and a big smile.', top: true)),
            _pad(_step('04', "Repeat while he's delighted; stop before he tires.", top: true, bottom: true)),

            const SizedBox(height: 22),
            _pad(Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _done = !_done),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _done ? ppPanel : ppPurple,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ppPurple),
                    ),
                    child: Text(_done ? 'Done ✓' : 'Mark as done',
                        style: ppBody(15, color: _done ? ppPurple : Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _liked = !_liked),
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppLine)),
                  child: Text(_liked ? '♥' : '♡', style: TextStyle(color: _liked ? ppCoral : ppMuted, fontSize: 20)),
                ),
              ),
            ])),

            _pad(ppSectionDivider()),
            _pad(Text('To extend the play', style: ppJakarta(16))),
            const SizedBox(height: 6),
            _pad(Text('Optional — the game needs nothing but you.', style: ppBody(12, color: ppMuted))),
            const SizedBox(height: 14),
            _pad(ppProductRow(context, 'Curious Cubs · peekaboo cloth book', 'Flaps that hide and reveal.', '₹399', top: true)),
            _pad(ppProductRow(context, 'Soft baby mirror', 'Tummy-time faces to reappear into.', '₹549', top: true, bottom: true)),

            _pad(ppSectionDivider()),
            _pad(Text('Go deeper', style: ppJakarta(16))),
            const SizedBox(height: 14),
            _pad(ppDeeperRow(context, 'FAQ', 'When does object permanence develop?', top: true)),
            _pad(ppDeeperRow(context, 'Course', 'Play & Brain · Leap 4 activities', top: true)),
            _pad(ppDeeperRow(context, 'Room', 'Boy moms · favourite 4-month games', top: true, bottom: true)),
          ],
        ),
      ),
    );
  }

  Widget _step(String n, String text, {bool top = false, bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n, style: ppBody(14, color: ppPurple, w: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );
}
