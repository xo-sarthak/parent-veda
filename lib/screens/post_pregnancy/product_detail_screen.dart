// =============================================================================
//  ProductDetailScreen — Products · detail (parenting · S3·detail v2)
// -----------------------------------------------------------------------------
//  Trust-first product page: for a soother, an explain-first "what's inside &
//  how it works", the ParentVeda take, good / consider, "choose this if…", the
//  research behind the claims, provenance-tagged reviews, a compare link, and a
//  hybrid buy. Faithful build of Claude Design · S3·detail v2. Product-aware;
//  the deep soother content shows for soothers, a lighter page for the rest.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_products_data.dart';
import 'products_compare_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, this.product = _fallback});
  final PpProduct product;

  static const PpProduct _fallback = PpProduct(
    id: 'dozy',
    name: 'Dozy White-Noise & Sleep Soother',
    brand: 'Dozy',
    category: 'Sleep',
    sub: 'Soothers & white noise',
    rating: 4.8,
    reviews: 214,
    price: 1499,
    retailer: 'Amazon',
    verified: true,
    bestseller: true,
    sound: 'True continuous white noise',
    autoOff: true,
    volumeLock: false,
    power: 'USB + power bank',
  );

  bool get _isSoother => product.sound != null;
  String get _subShort {
    final cat = categoryByName(product.category);
    final m = cat.subs.where((s) => s.name == product.sub);
    return m.isEmpty ? product.sub : m.first.short;
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  Widget _div() => _pad(const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: SizedBox(height: 1, child: ColoredBox(color: ppLine)),
      ));

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening the store soon'), behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    final otherRetailer = product.retailer == 'Amazon' ? 'FirstCry' : 'Amazon';
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: const Icon(Icons.arrow_back, size: 20, color: ppSoft),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text('${product.category} › $_subShort',
                    style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ])),

            // product shot
            const SizedBox(height: 16),
            _pad(const PpStriped(height: 230, radius: 22, border: true)),

            // badge + title
            const SizedBox(height: 18),
            if (product.verified || product.parentVeda)
              _pad(Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check, size: 13, color: ppPurple),
                    const SizedBox(width: 6),
                    Text(product.parentVeda ? 'ParentVeda' : 'ParentVeda Verified',
                        style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
                  ]),
                ),
              )),
            const SizedBox(height: 12),
            _pad(Text(product.name, style: ppFraunces(29, h: 1.15))),
            const SizedBox(height: 10),
            _pad(Row(children: [
              Text(product.ratingLabel, style: ppBody(13, color: ppCoral, w: FontWeight.w700)),
              const SizedBox(width: 8),
              Text('${product.reviews} reviews', style: ppBody(13, color: ppMuted)),
            ])),

            // what's inside (soothers only)
            if (_isSoother) ...[
              _div(),
              _pad(ppEyebrow("What's inside & how it works", color: ppSoft, spacing: 1.2)),
              const SizedBox(height: 6),
              _pad(Text("New to sound soothers? Here's what each part does, so you know what you're actually buying.",
                  style: ppBody(13, h: 1.55))),
              _pad(Column(children: [
                _feature(Icons.volume_up_outlined, 'White-noise speaker',
                    'Plays a steady “shhh” that masks door slams and traffic — the sounds that jolt a baby out of light sleep.',
                    top: true),
                _feature(Icons.timer_outlined, 'Auto-off timer',
                    'Runs 30/60 min then fades out on its own — no getting up to switch it off.'),
                _feature(Icons.bedtime_outlined, 'Soft night-light',
                    'A dim amber glow for feeds and nappy changes, without fully waking the room.'),
                _feature(Icons.battery_charging_full_outlined, 'USB power / power-bank',
                    "No fixed socket needed — works on a power bank, so it travels for holidays and nani's house.",
                    bottom: true),
              ])),
              const SizedBox(height: 14),
              _pad(Text.rich(TextSpan(children: [
                TextSpan(text: 'In short: ', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                const TextSpan(
                    text:
                        "a small bedside box that makes a room calmer and darker for sleep, and turns itself off — that's the whole job."),
              ]), style: ppBody(13, color: ppInk, h: 1.55))),
            ],

            // the take
            _div(),
            _pad(ppEyebrow('The ParentVeda take', color: ppSoft, spacing: 1.2)),
            const SizedBox(height: 10),
            _pad(Text(
                _isSoother
                    ? 'A no-frills soother that actually helps during the 4-month regression. Steady white noise — not looping lullabies — masks household sound in Indian joint homes. Simple, timer-based, and cheap enough to justify.'
                    : 'A ParentVeda-reviewed pick for its category — chosen for everyday usefulness, safety, and value. Named, verified-mother ratings back it up.',
                style: ppBody(15, color: ppInk, h: 1.65))),

            // good / consider (soothers only)
            if (_isSoother) ...[
              _div(),
              _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("What's good", style: ppBody(12, color: ppInk, w: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _line('True continuous white noise'),
                    _line('Auto-off timer'),
                    _line('Runs on a power bank'),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Consider', style: ppBody(12, color: ppInk, w: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _line('No volume lock'),
                    _line('Plasticky dial'),
                  ]),
                ),
              ])),
              const SizedBox(height: 22),
              _pad(Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ppEyebrow('Choose this if…', color: ppBrown, spacing: 0.8),
                  const SizedBox(height: 7),
                  Text('you’re in a noisy joint-family home and want the simplest thing that works.',
                      style: ppBody(14, color: ppInk, h: 1.55)),
                ]),
              )),

              // research
              _div(),
              _pad(Text('Read the research', style: ppJakarta(16))),
              const SizedBox(height: 4),
              _pad(Text('The evidence behind the claims — read it yourself.', style: ppBody(12, color: ppMuted))),
              const SizedBox(height: 12),
              _pad(_paper(context, 'Paper', ppPurple, 'White noise & infant sleep onset — a review', top: true)),
              _pad(_paper(context, 'Safety', ppBrown, 'Safe decibel levels for a nursery (AAP)', top: true, bottom: true)),
            ],

            // reviews
            _div(),
            _pad(Text('From verified parents', style: ppJakarta(16))),
            const SizedBox(height: 4),
            _pad(Text('Named, with child & age — never anonymous.', style: ppBody(12, color: ppMuted))),
            const SizedBox(height: 14),
            _pad(_review('Priya', 'mother of Aarav (4 mo)', '★★★★★', 'purchase',
                '“The only thing that got us through the regression. On within the routine, off by morning.”',
                top: true)),
            _pad(_review('Deepti', 'mother of Mehr (2.5 yr)', '★★★★☆', 'collected',
                '“Still using it two years later.”')),
            const SizedBox(height: 12),
            _pad(Text.rich(TextSpan(children: [
              const TextSpan(text: 'Two authenticated sources: '),
              TextSpan(text: '✓ Verified purchase', style: ppBody(11, color: ppPurple, w: FontWeight.w600)),
              const TextSpan(text: ' (bought via ParentVeda) and '),
              TextSpan(text: 'ParentVeda-collected', style: ppBody(11, color: ppBrown, w: FontWeight.w600)),
              const TextSpan(text: ' (our team met the mother). Never anonymous.'),
            ]), style: ppBody(11, color: ppMuted, h: 1.5))),

            // compare
            const SizedBox(height: 14),
            _pad(GestureDetector(
              onTap: () {
                if (!PpCompareStore.instance.isSelected(product)) PpCompareStore.instance.toggle(product);
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProductsCompareScreen()));
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: ppHair), bottom: BorderSide(color: ppHair))),
                child: Row(children: [
                  Expanded(child: Text('Compare with alternatives', style: ppBody(14, color: ppInk, w: FontWeight.w600))),
                  const Text('→', style: TextStyle(color: ppMuted)),
                ]),
              ),
            )),

            // buy
            const SizedBox(height: 22),
            _pad(GestureDetector(
              onTap: () => _soon(context),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                child: Text('Buy on ${product.retailer} · ${product.priceLabel}',
                    style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
              ),
            )),
            const SizedBox(height: 12),
            _pad(Center(
              child: Text.rich(TextSpan(children: [
                const TextSpan(text: 'Also on '),
                TextSpan(text: otherRetailer, style: ppBody(13, color: ppPurple, w: FontWeight.w600)),
              ]), style: ppBody(13)),
            )),

            const SizedBox(height: 20),
            _pad(Text('Reviews are from verified ParentVeda parents. No anonymous reviews, ever.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.5))),
          ],
        ),
      ),
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
            child: Icon(icon, size: 18, color: ppPurple),
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

  Widget _line(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: ppBody(13, h: 1.5)),
      );

  Widget _paper(BuildContext context, String tag, Color tagColor, String title, {bool top = false, bool bottom = false}) =>
      GestureDetector(
        onTap: () => _soon(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border(
              top: top ? const BorderSide(color: ppHair) : BorderSide.none,
              bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
            ),
          ),
          child: Row(children: [
            Container(
              width: 66,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
              child: Text(tag, style: ppBody(10, color: tagColor, w: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: ppBody(14, color: ppInk, h: 1.4))),
            const SizedBox(width: 8),
            const Icon(Icons.north_east_rounded, size: 15, color: ppMuted),
          ]),
        ),
      );

  Widget _review(String name, String who, String stars, String source, String quote,
      {bool top = false, bool bottom = false}) {
    final collected = source == 'collected';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: ppHair) : BorderSide.none,
          bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Flexible(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '$name ', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
              TextSpan(text: '· $who', style: ppBody(14, color: ppSoft)),
            ]), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Text(stars, style: ppBody(13, color: ppCoral, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(collected ? Icons.handshake_outlined : Icons.check,
                size: 12, color: collected ? ppBrown : ppPurple),
            const SizedBox(width: 5),
            Text(collected ? 'ParentVeda-collected' : 'Verified purchase',
                style: ppBody(10, color: collected ? ppBrown : ppPurple, w: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 8),
        Text(quote, style: ppBody(14, h: 1.55)),
      ]),
    );
  }
}
