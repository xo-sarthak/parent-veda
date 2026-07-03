// =============================================================================
//  ProductsCompareScreen — Products · compare (parenting app · S3·compare)
// -----------------------------------------------------------------------------
//  Two picks side by side: product heads, a spec table (price, rating, sound,
//  timer, volume-lock, power), and ParentVeda's verdict. Faithful build of
//  Claude Design S3·compare. Reached from Products home / subcategory / detail.
//  "View" opens the detail. No bottom nav.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'product_detail_screen.dart';

class ProductsCompareScreen extends StatelessWidget {
  const ProductsCompareScreen({super.key});

  static const Color _green = Color(0xFF1F8A5B);
  static const Color _red = Color(0xFFC0392B);

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: c);

  void _openDetail(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductDetailScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              behavior: HitTestBehavior.opaque,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.arrow_back, size: 20, color: ppSoft),
                const SizedBox(width: 10),
                Text('Compare soothers', style: ppBody(14, color: ppSoft)),
              ]),
            )),

            const SizedBox(height: 18),
            _pad(Text('Two picks, side by side', style: ppFraunces(27, h: 1.15))),
            const SizedBox(height: 8),
            _pad(Text("ParentVeda's honest read on both — so you choose once, and right.", style: ppBody(13, h: 1.55))),

            // heads
            const SizedBox(height: 20),
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _head('Dozy White-Noise Soother', '✓ Verified', ppPurple)),
              const SizedBox(width: 12),
              Expanded(child: _head('Lull Portable Soother', 'Popular', ppBrown)),
            ])),

            // spec table
            const SizedBox(height: 22),
            _pad(Column(children: [
              _spec('Price', _val('₹1,499', w: FontWeight.w700, size: 15), _val('₹999', w: FontWeight.w700, size: 15)),
              _spec('Rating', _rating('★ 4.8', '214'), _rating('★ 4.5', '88')),
              _spec('Sound', _val('True continuous white noise', size: 13),
                  _valRich('Looping tracks', ' (short loop)', size: 13)),
              _spec('Timer', _val('✓ Auto-off', color: _green, w: FontWeight.w600, size: 13),
                  _val('✓ Auto-off', color: _green, w: FontWeight.w600, size: 13)),
              _spec('Volume lock', _val('✕ None', color: _red, w: FontWeight.w600, size: 13),
                  _val('✓ Yes', color: _green, w: FontWeight.w600, size: 13)),
              _spec('Power', _val('USB + power bank', size: 13), _val('Rechargeable battery', size: 13), last: true),
            ])),

            // verdict
            const SizedBox(height: 22),
            _pad(Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow("ParentVeda's verdict", color: ppPurple, spacing: 0.8),
                const SizedBox(height: 10),
                _verdict('Dozy', 'Best true white noise — pick it for a noisy joint-family home.'),
                const SizedBox(height: 10),
                _verdict('Lull', 'Cheaper with a volume lock — great for travel and grandparents.'),
              ]),
            )),

            // CTAs
            const SizedBox(height: 20),
            _pad(Row(children: [
              Expanded(child: _cta(context, 'View Dozy', filled: true)),
              const SizedBox(width: 12),
              Expanded(child: _cta(context, 'View Lull', filled: false)),
            ])),

            const SizedBox(height: 20),
            _pad(Text("Same honest lens on both. We only compare what we'd consider for our own kids.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.5))),
          ],
        ),
      ),
    );
  }

  Widget _head(String name, String badge, Color badgeColor) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PpStriped(height: 96, radius: 16, border: true),
        const SizedBox(height: 10),
        Text(name, style: ppJakarta(14, w: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
          child: Text(badge, style: ppBody(10, color: badgeColor, w: FontWeight.w700)),
        ),
      ]);

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

  Widget _valRich(String main, String muted, {double size = 13}) => Text.rich(TextSpan(children: [
        TextSpan(text: main, style: TextStyle(color: ppInk)),
        TextSpan(text: muted, style: const TextStyle(color: ppMuted)),
      ]), style: ppBody(size, h: 1.4));

  Widget _rating(String stars, String count) => Text.rich(TextSpan(children: [
        TextSpan(text: stars, style: const TextStyle(color: ppCoral, fontWeight: FontWeight.w700)),
        TextSpan(text: '  · $count', style: const TextStyle(color: ppMuted, fontSize: 12)),
      ]), style: ppBody(14, color: ppInk));

  Widget _verdict(String name, String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 52, child: Text(name, style: ppBody(13, color: ppInk, w: FontWeight.w700))),
        const SizedBox(width: 11),
        Expanded(child: Text(text, style: ppBody(13, color: ppInk, h: 1.5))),
      ]);

  Widget _cta(BuildContext context, String label, {required bool filled}) => GestureDetector(
        onTap: () => _openDetail(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? ppPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: filled ? null : Border.all(color: ppPurple),
          ),
          child: Text(label, style: ppBody(14, color: filled ? Colors.white : ppPurple, w: FontWeight.w700)),
        ),
      );
}
