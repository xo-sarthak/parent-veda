// =============================================================================
//  ProductDetailScreen — Products · detail (parenting app · S3·detail)
// -----------------------------------------------------------------------------
//  Trust-first product page: an explain-first "what's inside & how it works",
//  the ParentVeda take, what's-good / consider, "choose this if…", named
//  verified-parent reviews, a compare link, and a hybrid buy. Faithful build of
//  Claude Design S3·detail (enhanced). Pushed from the subcategory list.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'products_compare_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _openCompare(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsCompareScreen()));

  @override
  Widget build(BuildContext context) {
    Widget pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
    Widget divider({double top = 22, double bottom = 22}) =>
        Padding(padding: EdgeInsets.only(top: top, bottom: bottom), child: ppDivider());

    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 116),
            children: [
              pad(Text.rich(TextSpan(children: const [
                TextSpan(text: 'Sleep '),
                TextSpan(text: '› ', style: TextStyle(color: Color(0xFFC7BBD6))),
                TextSpan(text: 'Soothers'),
              ]), style: ppBody(12, color: ppMuted))),

              const SizedBox(height: 16),
              pad(PpStriped(
                height: 230,
                radius: 22,
                border: true,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(padding: const EdgeInsets.all(14), child: Text('product shot', style: ppBody(10, color: ppMuted))),
                ),
              )),

              const SizedBox(height: 18),
              pad(Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('✓', style: TextStyle(color: ppPurple, fontSize: 11)),
                    const SizedBox(width: 6),
                    Text('ParentVeda Verified', style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
                  ]),
                ),
              )),
              const SizedBox(height: 12),
              pad(Text('Dozy White-Noise & Sleep Soother', style: ppFraunces(29, h: 1.15))),

              // what's inside & how it works
              divider(),
              pad(ppEyebrow("What's inside & how it works", color: ppSoft, spacing: 1.2)),
              const SizedBox(height: 6),
              pad(Text("New to sound soothers? Here's what each part does, so you know what you're actually buying.",
                  style: ppBody(13, h: 1.55))),
              const SizedBox(height: 8),
              pad(_feature(Icons.volume_up_outlined, 'White-noise speaker',
                  'Plays a steady “shhh” that masks door slams and traffic — the sounds that jolt a baby out of light sleep.',
                  top: true)),
              pad(_feature(Icons.timer_outlined, 'Auto-off timer',
                  'Runs 30/60 min then fades out on its own — no getting up to switch it off.',
                  top: true)),
              pad(_feature(Icons.bedtime_outlined, 'Soft night-light',
                  'A dim amber glow for feeds and nappy changes, without fully waking the room.',
                  top: true)),
              pad(_feature(Icons.battery_charging_full_outlined, 'USB power / power-bank',
                  "No fixed socket needed — works on a power bank, so it travels for holidays and nani's house.",
                  top: true, bottom: true)),
              const SizedBox(height: 14),
              pad(Text.rich(TextSpan(children: [
                TextSpan(text: 'In short: ', style: TextStyle(color: ppInk, fontWeight: FontWeight.w700)),
                const TextSpan(
                    text:
                        "a small bedside box that makes a room calmer and darker for sleep, and turns itself off — that's the whole job."),
              ]), style: ppBody(13, color: ppInk, h: 1.55))),

              divider(),
              pad(ppEyebrow('The ParentVeda take', color: ppSoft, spacing: 1.2)),
              const SizedBox(height: 10),
              pad(Text(
                  'A no-frills soother that actually helps during the 4-month regression. Steady white noise — not looping lullabies — masks household sound in Indian joint homes. Simple, timer-based, and cheap enough to justify.',
                  style: ppBody(15, color: ppInk, h: 1.65))),

              divider(),
              pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("What's good", style: ppBody(12, color: ppInk, w: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _point('True continuous white noise'),
                    _point('Auto-off timer'),
                    _point('Runs on a power bank'),
                  ]),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Consider', style: ppBody(12, color: ppInk, w: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _point('No volume lock'),
                    _point('Plasticky dial'),
                  ]),
                ),
              ])),

              const SizedBox(height: 22),
              pad(Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ppEyebrow('Choose this if…', color: ppBrown, spacing: 0.8),
                  const SizedBox(height: 7),
                  Text("you're in a noisy joint-family home and want the simplest thing that works.",
                      style: ppBody(14, color: ppInk, h: 1.55)),
                ]),
              )),

              divider(top: 24, bottom: 18),
              pad(Text('From verified parents', style: ppJakarta(16))),
              const SizedBox(height: 6),
              pad(Text('Named, with child & age — never anonymous.', style: ppBody(12, color: ppMuted))),
              const SizedBox(height: 16),
              pad(_review('Priya', 'mother of Aarav (4 mo)', '★★★★★',
                  '"The only thing that got us through the regression. On within the routine, off by morning."',
                  top: true)),
              pad(_review('Deepti', 'mother of Mehr (2.5 yr)', '★★★★☆', '"Still using it two years later."')),

              pad(GestureDetector(
                onTap: () => _openCompare(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: ppHair), bottom: BorderSide(color: ppHair))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Compare with 2 alternatives', style: ppBody(14, color: ppInk, w: FontWeight.w600)),
                    const Text('→', style: TextStyle(color: ppMuted)),
                  ]),
                ),
              )),

              const SizedBox(height: 22),
              pad(GestureDetector(
                onTap: () => _soon(context),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                  child: Text('Buy on Amazon · ₹1,499', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                ),
              )),
              const SizedBox(height: 12),
              pad(Center(
                child: Text.rich(TextSpan(children: [
                  const TextSpan(text: 'Also on '),
                  TextSpan(text: 'FirstCry', style: ppBody(13, color: ppPurple, w: FontWeight.w600)),
                ]), style: ppBody(13)),
              )),

              const SizedBox(height: 20),
              pad(Text('Reviews are from verified ParentVeda parents. No anonymous reviews, ever.',
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.5))),
            ],
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: SizedBox(
              height: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)]),
                ),
              ),
            ),
          ),
        ),
        const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 3)),
      ]),
    );
  }

  Widget _feature(IconData icon, String title, String desc, {bool top = false, bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 19, color: ppPurple),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppBody(14, color: ppInk, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(desc, style: ppBody(13, h: 1.5)),
            ]),
          ),
        ]),
      );

  Widget _point(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: ppBody(13, h: 1.5)));

  Widget _review(String who, String childAge, String stars, String quote, {bool top = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(border: Border(top: top ? const BorderSide(color: ppHair) : BorderSide.none)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(
              child: Text.rich(TextSpan(children: [
                TextSpan(text: who, style: TextStyle(color: ppInk, fontWeight: FontWeight.w700, fontSize: 14)),
                TextSpan(text: ' · $childAge', style: const TextStyle(color: ppSoft, fontSize: 14)),
              ]), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 10),
            Text(stars, style: const TextStyle(color: ppCoral, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          Text(quote, style: ppBody(14, h: 1.55)),
        ]),
      );
}
