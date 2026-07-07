// =============================================================================
//  SleepBetterScreen - "Sleep Better" · Preparation Journey (parenting · S5)
// -----------------------------------------------------------------------------
//  The commerce-as-preparation flow: a 4-step guided journey (understand → set
//  routine → fix environment [with explained products] → track), plus a soft
//  cohort upsell. Faithful build of Claude Design S5. Reached from the Home
//  "Sleep Better" card → Take a look. Pushed screen (no bottom nav).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class SleepBetterScreen extends StatelessWidget {
  const SleepBetterScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
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
            _pad(_back(context, 'Back')),

            // header + ring
            const SizedBox(height: 24),
            _pad(Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ppEyebrow('Preparation journey'),
                  const SizedBox(height: 8),
                  Text('Sleep Better', style: ppFraunces(32, h: 1.12)),
                  const SizedBox(height: 8),
                  Text('A gentle 2-week plan for the 4-month regression.', style: ppBody(14, h: 1.45)),
                ]),
              ),
              const SizedBox(width: 18),
              SizedBox(
                width: 74,
                height: 74,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox(
                    width: 74,
                    height: 74,
                    child: CircularProgressIndicator(
                      value: 3 / 14,
                      strokeWidth: 8,
                      valueColor: const AlwaysStoppedAnimation(ppPurple),
                      backgroundColor: const Color(0xFFECE5F2),
                    ),
                  ),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('Day 3', style: ppJakarta(16)),
                    Text('of 14', style: ppBody(10, color: ppMuted)),
                  ]),
                ]),
              ),
            ])),

            _pad(_gap()),

            // steps
            _pad(_step(
              _dot(done: true),
              _content('Understand what\'s happening',
                  Text.rich(TextSpan(children: [
                    const TextSpan(text: 'A short read and 3-min video on why the regression hits now. '),
                    TextSpan(text: 'Done', style: TextStyle(color: ppPurple, fontWeight: FontWeight.w600)),
                  ]), style: ppBody(13, h: 1.55))),
            )),
            _pad(_step(
              _dot(inProgress: true),
              _content('Set the wind-down routine', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your 3 steps, same order every night.', style: ppBody(13, h: 1.55)),
                const SizedBox(height: 12),
                Text('✓ Feed  ·  ✓ Dim the lights  ·  ○ Cuddle & put down drowsy',
                    style: ppBody(13, color: ppInk, h: 1.5)),
                const SizedBox(height: 12),
                Text('In progress', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
              ])),
            )),
            _pad(_step(
              _dot(),
              _content('Fix the sleep environment', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Two small changes make the biggest difference. We explain each - add only if it helps.',
                    style: ppBody(13, h: 1.55)),
                const SizedBox(height: 14),
                _productCard(context, 'Blackout curtains',
                    'His room is too bright for the maturing cycles - light is pulling him out of lighter sleep.', '₹1,299'),
                const SizedBox(height: 12),
                _productCard(context, 'White-noise soother',
                    "Masks joint-home noise so a slammed door doesn't wake him mid-cycle.", '₹1,499'),
              ])),
            )),
            _pad(_step(
              _dot(),
              _content('Track & adjust',
                  Text("A simple night-log - jot each waking, and we'll help you read the pattern.",
                      style: ppBody(13, h: 1.55))),
              line: false,
            )),

            _pad(_gap()),

            // upsell
            _pad(Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: const Color(0xFFECE5F2), borderRadius: BorderRadius.circular(22)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Want a human in your corner?', style: ppJakarta(17)),
                const SizedBox(height: 8),
                Text.rich(TextSpan(children: [
                  const TextSpan(text: 'The 2-week Sleep Bootcamp cohort, with a real sleep consultant - '),
                  TextSpan(text: 'included with ParentVeda+', style: TextStyle(color: ppInk, fontWeight: FontWeight.w600)),
                  const TextSpan(text: '.'),
                ]), style: ppBody(14, h: 1.6)),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => _soon(context),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                    child: Text('See the cohort', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ]),
            )),

            const SizedBox(height: 20),
            _pad(Text('We suggest only what fits this stage, and we explain why. Preparation before products.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _back(BuildContext context, String label) => GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.arrow_back, size: 20, color: ppSoft),
          const SizedBox(width: 12),
          Text(label, style: ppBody(14, color: ppSoft)),
        ]),
      );

  Widget _gap() => const Padding(padding: EdgeInsets.symmetric(vertical: 26), child: SizedBox(height: 1, child: ColoredBox(color: ppLine)));

  Widget _dot({bool done = false, bool inProgress = false}) {
    if (done) {
      return Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
        child: const Text('✓', style: TextStyle(color: Colors.white, fontSize: 12)),
      );
    }
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: ppBg,
        shape: BoxShape.circle,
        border: Border.all(color: inProgress ? ppPurple : ppLine, width: 2),
      ),
    );
  }

  Widget _step(Widget indicator, Widget content, {bool line = true}) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Column(children: [
            indicator,
            if (line)
              Expanded(child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 4), color: ppLine)),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Padding(padding: EdgeInsets.only(bottom: line ? 24 : 0), child: content)),
        ]),
      );

  Widget _content(String title, Widget body) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: ppJakarta(17)),
        const SizedBox(height: 6),
        body,
      ]);

  Widget _productCard(BuildContext context, String title, String desc, String price) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: ppJakarta(14)),
          const SizedBox(height: 5),
          Text(desc, style: ppBody(13, h: 1.5)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
            GestureDetector(
              onTap: () => _soon(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: ppPurple)),
                child: Text('Add', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
              ),
            ),
          ]),
        ]),
      );
}
