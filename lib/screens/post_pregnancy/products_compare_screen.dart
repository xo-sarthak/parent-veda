// =============================================================================
//  ProductsCompareScreen — Products · compare (parenting · S3·compare)
// -----------------------------------------------------------------------------
//  The two ticked picks, side by side: heads, a spec table (price, rating,
//  brand, retailer + soother specs), and a data-driven verdict. Reads the live
//  PpCompareStore selection. If fewer than two are ticked, shows a gentle
//  prompt. Faithful build of Claude Design S3·compare, made functional.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_products_data.dart';
import 'product_detail_screen.dart';

class ProductsCompareScreen extends StatelessWidget {
  const ProductsCompareScreen({super.key});

  static const Color _green = Color(0xFF1F8A5B);
  static const Color _red = Color(0xFFC0392B);

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: PpCompareStore.instance,
          builder: (context, _) {
            final picks = PpCompareStore.instance.selected;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.arrow_back, size: 20, color: ppSoft),
                      const SizedBox(width: 10),
                      Text('Compare', style: ppBody(14, color: ppSoft)),
                    ]),
                  ),
                  const Spacer(),
                  if (picks.isNotEmpty)
                    GestureDetector(
                      onTap: PpCompareStore.instance.clear,
                      child: Text('Clear', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                    ),
                ])),
                const SizedBox(height: 18),
                if (picks.length < 2) ..._empty(picks.length) else ..._table(context, picks[0], picks[1]),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- empty / prompt state ---------------------------------------------
  List<Widget> _empty(int count) => [
        _pad(Text('Two picks, side by side', style: ppFraunces(27, h: 1.15))),
        const SizedBox(height: 10),
        _pad(Text("Tick $count of 2. On any product, tap Compare — pick two and they line up here for ParentVeda's honest read.",
            style: ppBody(14, h: 1.55))),
        const SizedBox(height: 22),
        _pad(Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            const Icon(Icons.compare_arrows_rounded, size: 22, color: ppPurple),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                  count == 0
                      ? 'Nothing ticked yet — open a category and tick Compare on two products.'
                      : 'One ticked. Tick one more and come back.',
                  style: ppBody(13, color: ppInk, h: 1.5)),
            ),
          ]),
        )),
      ];

  // ---- full comparison ---------------------------------------------------
  List<Widget> _table(BuildContext context, PpProduct a, PpProduct b) {
    final specs = <(String, Widget, Widget)>[
      ('Price', _val(a.priceLabel, w: FontWeight.w700, size: 15), _val(b.priceLabel, w: FontWeight.w700, size: 15)),
      ('Rating', _rating(a), _rating(b)),
      ('Brand', _val(a.brand, size: 13), _val(b.brand, size: 13)),
      ('Buy from', _val(a.retailer, size: 13), _val(b.retailer, size: 13)),
    ];
    if (a.sound != null && b.sound != null) {
      specs.add(('Sound', _val(a.sound!, size: 13), _val(b.sound!, size: 13)));
    }
    if (a.autoOff != null && b.autoOff != null) {
      specs.add(('Timer', _bool(a.autoOff!, 'Auto-off', 'No timer'), _bool(b.autoOff!, 'Auto-off', 'No timer')));
    }
    if (a.volumeLock != null && b.volumeLock != null) {
      specs.add(('Volume lock', _bool(a.volumeLock!, 'Yes', 'None'), _bool(b.volumeLock!, 'Yes', 'None')));
    }
    if (a.power != null && b.power != null) {
      specs.add(('Power', _val(a.power!, size: 13), _val(b.power!, size: 13)));
    }
    final rows = [
      for (int i = 0; i < specs.length; i++) _spec(specs[i].$1, specs[i].$2, specs[i].$3, last: i == specs.length - 1),
    ];

    return [
      _pad(Text('Two picks, side by side', style: ppFraunces(27, h: 1.15))),
      const SizedBox(height: 8),
      _pad(Text("ParentVeda's honest read on both — so you choose once, and right.", style: ppBody(13, h: 1.55))),

      const SizedBox(height: 20),
      _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _head(a)),
        const SizedBox(width: 12),
        Expanded(child: _head(b)),
      ])),

      const SizedBox(height: 22),
      _pad(Column(children: rows)),

      const SizedBox(height: 22),
      _pad(Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppEyebrow("ParentVeda's verdict", color: ppPurple, spacing: 0.8),
          const SizedBox(height: 10),
          _verdict(a.brand, _verdictText(a, b)),
          const SizedBox(height: 10),
          _verdict(b.brand, _verdictText(b, a)),
        ]),
      )),

      const SizedBox(height: 20),
      _pad(Row(children: [
        Expanded(child: _cta(context, a, filled: true)),
        const SizedBox(width: 12),
        Expanded(child: _cta(context, b, filled: false)),
      ])),

      const SizedBox(height: 20),
      _pad(Text("Same honest lens on both. We only compare what we'd consider for our own kids.",
          textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.5))),
    ];
  }

  String _verdictText(PpProduct p, PpProduct o) {
    final priceRel = p.price < o.price
        ? 'the cheaper pick'
        : p.price > o.price
            ? 'the pricier pick'
            : 'same price';
    final rateRel = p.rating > o.rating
        ? 'higher rated'
        : p.rating < o.rating
            ? 'lower rated'
            : 'evenly rated';
    return '${p.priceLabel} · ${p.ratingLabel} from ${p.reviews} parents — $priceRel, $rateRel.';
  }

  Widget _head(PpProduct p) {
    final badge = p.bestseller
        ? ('Bestseller', ppCoral)
        : p.parentVeda
            ? ('ParentVeda', ppBrown)
            : p.verified
                ? ('✓ Verified', ppPurple)
                : (p.retailer, ppMuted);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const PpStriped(height: 96, radius: 16, border: true),
      const SizedBox(height: 10),
      Text(p.name, style: ppJakarta(14, w: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(badge.$1, style: ppBody(10, color: badge.$2, w: FontWeight.w700)),
      ),
    ]);
  }

  Widget _spec(String label, Widget a, Widget b, {bool last = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: ppEyebrow(label, color: ppMuted, spacing: 0.6),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: last ? Colors.transparent : ppHair))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: a),
              const SizedBox(width: 12),
              Expanded(child: b),
            ]),
          ),
        ],
      );

  Widget _val(String text, {Color color = ppInk, FontWeight w = FontWeight.w400, double size = 14}) =>
      Text(text, style: ppBody(size, color: color, w: w, h: 1.4));

  Widget _bool(bool yes, String yesLabel, String noLabel) => Text(yes ? '✓ $yesLabel' : '✕ $noLabel',
      style: ppBody(13, color: yes ? _green : _red, w: FontWeight.w600, h: 1.4));

  Widget _rating(PpProduct p) => Text.rich(TextSpan(children: [
        TextSpan(text: p.ratingLabel, style: const TextStyle(color: ppCoral, fontWeight: FontWeight.w700)),
        TextSpan(text: '  · ${p.reviews}', style: const TextStyle(color: ppMuted, fontSize: 12)),
      ]), style: ppBody(14, color: ppInk));

  Widget _verdict(String name, String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 66, child: Text(name, style: ppBody(13, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 11),
        Expanded(child: Text(text, style: ppBody(13, color: ppInk, h: 1.5))),
      ]);

  Widget _cta(BuildContext context, PpProduct p, {required bool filled}) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProductDetailScreen(product: p))),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? ppPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: filled ? null : Border.all(color: ppPurple),
          ),
          child: Text('View ${p.brand}',
              style: ppBody(14, color: filled ? Colors.white : ppPurple, w: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      );
}
