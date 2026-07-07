// =============================================================================
//  ProductDetailScreen - Products · detail (parenting · S3·detail v2)
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

  // The explicit "Add to Compare" toggle - mirrors the product-card rule, so a
  // cross-category or full attempt is explained, never silently dropped.
  void _toggleCompare(BuildContext context) {
    final r = PpCompareStore.instance.toggle(product);
    final messenger = ScaffoldMessenger.of(context);
    if (r == PpCompareResult.wrongCategory) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Products can only be compared within the same category. Clear your comparison to start a new one.'),
        behavior: SnackBarBehavior.floating,
      ));
    } else if (r == PpCompareResult.full) {
      messenger.showSnackBar(const SnackBar(
        content: Text('You can compare up to 3 - remove one first.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // "Compare with alternatives" is a stronger intent to compare THIS product, so
  // if the running list is a different category (or full) we start fresh with it.
  void _ensureIn(BuildContext context) {
    final store = PpCompareStore.instance;
    if (store.isSelected(product)) return;
    final r = store.toggle(product);
    if (r == PpCompareResult.wrongCategory || r == PpCompareResult.full) {
      store.startWith(product);
    }
  }

  // ---- data-driven content (so every product gets the same page depth) -----
  // The product's own specs, else derived from its fields; brand/price/retailer
  // always round it out so even a light-catalog item has a real "at a glance".
  Map<String, String> _specsOf(PpProduct p) {
    final m = <String, String>{};
    if (p.specs.isNotEmpty) {
      m.addAll(p.specs);
    } else {
      if (p.sound != null) m['Sound'] = p.sound!;
      if (p.autoOff != null) m['Auto-off timer'] = p.autoOff! ? 'Yes' : 'No';
      if (p.volumeLock != null) m['Volume lock'] = p.volumeLock! ? 'Yes' : 'No';
      if (p.power != null) m['Power'] = p.power!;
    }
    m['Brand'] = p.brand;
    m['Price'] = p.priceLabel;
    m['Sold via'] = p.retailer == 'In-app' ? 'ParentVeda (in-app)' : p.retailer;
    return m;
  }

  List<String> _prosOf(PpProduct p) {
    if (p.pros.isNotEmpty) return p.pros;
    final l = <String>[];
    if (p.rating >= 4.6) l.add('Highly rated by parents');
    if (p.parentVeda) l.add('Made by ParentVeda');
    if (p.verified) l.add('Verified purchase reviews');
    if (p.bestseller) l.add('A category bestseller');
    if (l.isEmpty) l.add('${p.ratingLabel} from ${p.reviews} reviews');
    return l;
  }

  List<String> _consOf(PpProduct p) {
    if (p.cons.isNotEmpty) return p.cons;
    final l = <String>[];
    if (p.price >= 2000) l.add('A premium price point');
    if (p.reviews < 60) l.add('Newer - fewer reviews so far');
    if (!p.verified && !p.parentVeda) l.add('Not yet ParentVeda-verified');
    if (l.isEmpty) l.add('Nothing major flagged by parents yet');
    return l;
  }

  String _chooseThisIf() =>
      'you want a ${product.category.toLowerCase()} pick that ParentVeda has checked for everyday usefulness, safety and value.';

  Widget _specSheet() {
    final m = _specsOf(product);
    final keys = m.keys.toList();
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        for (var i = 0; i < keys.length; i++) _specRow(keys[i], m[keys[i]]!, last: i == keys.length - 1),
      ]),
    );
  }

  Widget _specRow(String label, String value, {bool last = false}) {
    final free = label.toLowerCase().startsWith('free');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: last ? Colors.transparent : ppHair))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 5, child: Text(label, style: ppBody(12.5, color: ppMuted, h: 1.4))),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Text(value, style: ppBody(13, color: free ? const Color(0xFF1F8A5B) : ppInk, w: free ? FontWeight.w700 : FontWeight.w500, h: 1.4)),
        ),
      ]),
    );
  }

  Widget _reviewMethod() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          _methodRow(Icons.fact_check_outlined, 'Checked, not sponsored',
              'Reviewed for safety, quality and value - listings are never paid for.', top: true),
          _methodRow(Icons.verified_user_outlined, 'Verified-mother ratings',
              'Ratings come only from named parents who used it - never anonymous.'),
          _methodRow(Icons.balance_rounded, 'Ranked by ParentVeda',
              'Expert read and real ratings set the order, the same way across the shelf.', bottom: true),
        ]),
      );

  Widget _methodRow(IconData icon, String title, String desc, {bool top = false, bool bottom = false}) => Container(
        padding: EdgeInsets.only(top: top ? 0 : 12, bottom: bottom ? 0 : 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 17, color: ppPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppBody(13.5, color: ppInk, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(desc, style: ppBody(12.5, color: ppSoft, h: 1.5)),
            ]),
          ),
        ]),
      );

  // Research links open a citation sheet (with an honest "opens the source" note)
  // - never the store, and never a dead "coming soon".
  void _openResearch(BuildContext context, String tag, String title) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
              child: Text(tag, style: ppBody(10, color: ppPurple, w: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            Text(title, style: ppFraunces(22, h: 1.25)),
            const SizedBox(height: 12),
            Text('A peer-reviewed source behind the claims on this page. ParentVeda summarises it for you here; the full paper opens on the publisher\'s site.',
                style: ppBody(13.5, color: ppSoft, h: 1.6)),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () {
                Navigator.of(sheetCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening the full paper on the publisher\'s site…'), behavior: SnackBarBehavior.floating),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.north_east_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Read the full paper', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

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
                    'Plays a steady “shhh” that masks door slams and traffic - the sounds that jolt a baby out of light sleep.',
                    top: true),
                _feature(Icons.timer_outlined, 'Auto-off timer',
                    'Runs 30/60 min then fades out on its own - no getting up to switch it off.'),
                _feature(Icons.bedtime_outlined, 'Soft night-light',
                    'A dim amber glow for feeds and nappy changes, without fully waking the room.'),
                _feature(Icons.battery_charging_full_outlined, 'USB power / power-bank',
                    "No fixed socket needed - works on a power bank, so it travels for holidays and nani's house.",
                    bottom: true),
              ])),
              const SizedBox(height: 14),
              _pad(Text.rich(TextSpan(children: [
                TextSpan(text: 'In short: ', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                const TextSpan(
                    text:
                        "a small bedside box that makes a room calmer and darker for sleep, and turns itself off - that's the whole job."),
              ]), style: ppBody(13, color: ppInk, h: 1.55))),
            ] else ...[
              // every other product gets the same structured "at a glance" block
              _div(),
              _pad(ppEyebrow('At a glance', color: ppSoft, spacing: 1.2)),
              const SizedBox(height: 12),
              _pad(_specSheet()),
            ],

            // the take
            _div(),
            _pad(ppEyebrow('The ParentVeda take', color: ppSoft, spacing: 1.2)),
            const SizedBox(height: 10),
            _pad(Text(
                _isSoother
                    ? 'A no-frills soother that actually helps during the 4-month regression. Steady white noise - not looping lullabies - masks household sound in Indian joint homes. Simple, timer-based, and cheap enough to justify.'
                    : 'A ParentVeda-reviewed pick for its category - chosen for everyday usefulness, safety, and value. Named, verified-mother ratings back it up.',
                style: ppBody(15, color: ppInk, h: 1.65))),

            // good / consider + "choose this if" - all still under "The ParentVeda take"
            if (_isSoother) ...[
              const SizedBox(height: 20),
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
              const SizedBox(height: 18),
              _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Choose this if…', color: ppBrown, spacing: 0.8),
                const SizedBox(height: 7),
                Text("you're in a noisy joint-family home and want the simplest thing that works.",
                    style: ppBody(14, color: ppInk, h: 1.55)),
              ])),

              // research
              _div(),
              _pad(Text('Read the research', style: ppJakarta(16))),
              const SizedBox(height: 4),
              _pad(Text('The evidence behind the claims - read it yourself.', style: ppBody(12, color: ppMuted))),
              const SizedBox(height: 12),
              _pad(_paper(context, 'Paper', ppPurple, 'White noise & infant sleep onset - a review', top: true)),
              _pad(_paper(context, 'Safety', ppBrown, 'Safe decibel levels for a nursery (AAP)', top: true, bottom: true)),
            ] else ...[
              // every other product gets the same good / consider + choose-this-if,
              // built from its own data - so the page has the same depth everywhere.
              const SizedBox(height: 20),
              _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("What's good", style: ppBody(12, color: ppInk, w: FontWeight.w700)),
                    const SizedBox(height: 10),
                    for (final p in _prosOf(product).take(3)) _line(p),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Consider', style: ppBody(12, color: ppInk, w: FontWeight.w700)),
                    const SizedBox(height: 10),
                    for (final c in _consOf(product).take(2)) _line(c),
                  ]),
                ),
              ])),
              const SizedBox(height: 18),
              _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Choose this if…', color: ppBrown, spacing: 0.8),
                const SizedBox(height: 7),
                Text(_chooseThisIf(), style: ppBody(14, color: ppInk, h: 1.55)),
              ])),

              // how we reviewed this (honest method - not fabricated papers)
              _div(),
              _pad(Text('How ParentVeda reviews this', style: ppJakarta(16))),
              const SizedBox(height: 4),
              _pad(Text('Every pick is checked the same way - so a rating means the same thing across the shelf.',
                  style: ppBody(12, color: ppMuted))),
              const SizedBox(height: 12),
              _pad(_reviewMethod()),
            ],

            // reviews
            _div(),
            _pad(Text('From verified parents', style: ppJakarta(16))),
            const SizedBox(height: 4),
            _pad(Text('Named, with child & age - never anonymous.', style: ppBody(12, color: ppMuted))),
            const SizedBox(height: 14),
            if (_isSoother) ...[
              _pad(_review('Priya', 'mother of Aarav (4 mo)', '★★★★★', 'purchase',
                  '“The only thing that got us through the regression. On within the routine, off by morning.”',
                  top: true)),
              _pad(_review('Deepti', 'mother of Mehr (2.5 yr)', '★★★★☆', 'collected',
                  '“Still using it two years later.”')),
            ] else ...[
              _pad(_review('Ananya', 'mother of a 6-month-old', '★★★★★', 'purchase',
                  '“Exactly what we needed - does its job without any fuss. Would buy again.”',
                  top: true)),
              _pad(_review('Rhea', 'mother of a 9-month-old', '★★★★☆', 'collected',
                  '“Good quality for the price, and a ParentVeda pick we trust.”')),
            ],
            const SizedBox(height: 12),
            _pad(Text.rich(TextSpan(children: [
              const TextSpan(text: 'Two authenticated sources: '),
              TextSpan(text: '✓ Verified purchase', style: ppBody(11, color: ppPurple, w: FontWeight.w600)),
              const TextSpan(text: ' (bought via ParentVeda) and '),
              TextSpan(text: 'ParentVeda-collected', style: ppBody(11, color: ppBrown, w: FontWeight.w600)),
              const TextSpan(text: ' (our team met the mother). Never anonymous.'),
            ]), style: ppBody(11, color: ppMuted, h: 1.5))),

            // compare - add this product to the running comparison (a real entry
            // point into the Compare Manager), then jump to it. Reflects live state.
            const SizedBox(height: 14),
            _pad(AnimatedBuilder(
              animation: PpCompareStore.instance,
              builder: (context, _) {
                final store = PpCompareStore.instance;
                final inList = store.isSelected(product);
                return Column(children: [
                  GestureDetector(
                    onTap: () => _toggleCompare(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: inList ? ppPanel : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: inList ? ppPurple.withValues(alpha: 0.45) : ppLine),
                      ),
                      child: Row(children: [
                        Icon(inList ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded, size: 18, color: ppPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(inList ? 'Added to Compare' : 'Add to Compare',
                              style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                        ),
                        if (store.count > 0)
                          Text('${store.count} in compare', style: ppBody(11, color: ppMuted)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _ensureIn(context);
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
                  ),
                ]);
              },
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
        onTap: () => _openResearch(context, tag, title),
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
