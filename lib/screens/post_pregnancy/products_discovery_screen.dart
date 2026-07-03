// =============================================================================
//  ProductsDiscoveryScreen — Products · home / discovery (parenting app)
// -----------------------------------------------------------------------------
//  The Products tab landing: AskVeda-in-products, discovery entry points,
//  problem chips, a ParentVeda-ranked list, and a labelled sponsored slot.
//  Faithful build of Claude Design "post pregnancy app.dc.html" · S3. Tapping a
//  product opens the product detail. Isolated — no pregnancy imports.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'product_detail_screen.dart';

class ProductsDiscoveryScreen extends StatelessWidget {
  const ProductsDiscoveryScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _openDetail(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const ProductDetailScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 116),
            children: [
              // header
              _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Products', style: ppJakarta(24)),
                    const SizedBox(height: 3),
                    Text("Research first. Buy when you're sure.", style: ppBody(13)),
                  ]),
                ),
                const PpStriped(height: 36, width: 36, radius: 999, border: true),
              ])),

              // AskVeda-in-products
              const SizedBox(height: 20),
              _pad(GestureDetector(
                onTap: () => _soon(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ppLine),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A6A30B6), blurRadius: 22, spreadRadius: -12, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Row(children: [
                    const Text('✨', style: TextStyle(color: ppPurple, fontSize: 15)),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text('"My 2-year-old has red rashes — what should I buy?"',
                          style: ppBody(13, color: ppMuted, h: 1.35)),
                    ),
                  ]),
                ),
              )),
              const SizedBox(height: 8),
              _pad(Text('Ask in plain words — AskVeda ranks products with reasons.',
                  style: ppBody(11, color: ppMuted))),

              // discovery entry points (2x2)
              const SizedBox(height: 22),
              _pad(Column(children: [
                Row(children: [
                  Expanded(child: _entry(context, '🎯', 'By problem', 'Rashes, colic, sleep, teething.')),
                  const SizedBox(width: 12),
                  Expanded(child: _entry(context, '🌱', 'By life-stage', 'Right for Aarav at 4 months.')),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _entry(context, '🗂', 'Categories', 'Skincare, food, sleep, toys.')),
                  const SizedBox(width: 12),
                  Expanded(child: _entry(context, '⚖️', 'Compare', 'Any two, side by side.')),
                ]),
              ])),

              // problem chips
              const SizedBox(height: 20),
              _chips(),

              // ranked list
              const SizedBox(height: 28),
              _pad(Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(child: Text('For poor sleep', style: ppJakarta(18), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 10),
                  Text('Ranked by ParentVeda', style: ppBody(12, color: ppMuted)),
                ],
              )),
              const SizedBox(height: 6),
              _pad(Text('Every pick has an expert summary and named-mother reviews.', style: ppBody(12))),
              const SizedBox(height: 14),
              _pad(_productRow(context, '1', 'Dozy White-Noise Soother', '✓ Verified', ppPurple,
                  '★ 4.8 · 214', '₹1,499', 'on Amazon', ppMuted, top: true)),
              _pad(_productRow(context, '2', 'Hush Blackout Curtains', 'ParentVeda', ppBrown,
                  '★ 4.7 · 96', '₹1,299', 'In-app', ppPurple)),
              _pad(_productRow(context, '3', 'SnuggleSack Sleep Bag', '✓ Verified', ppPurple,
                  '★ 4.6 · 143', '₹899', 'on FirstCry', ppMuted, bottom: true)),

              // sponsored
              const SizedBox(height: 22),
              _pad(_sponsored()),

              const SizedBox(height: 22),
              _pad(Text(
                  'Named, verified-mother reviews on every product. Sponsored slots are always labelled. Your research stays on ParentVeda.',
                  textAlign: TextAlign.center,
                  style: ppBody(12, color: ppMuted, h: 1.55))),
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

  Widget _entry(BuildContext context, String emoji, String title, String desc) => GestureDetector(
        onTap: () => _soon(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppLine)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
              child: Text(emoji, style: const TextStyle(fontSize: 17)),
            ),
            const SizedBox(height: 12),
            Text(title, style: ppJakarta(15)),
            const SizedBox(height: 3),
            Text(desc, style: ppBody(12, h: 1.4)),
          ]),
        ),
      );

  Widget _chips() {
    Widget chip(String label, {bool active = false}) => Container(
          margin: const EdgeInsets.only(right: 9),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
              color: active ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
          child: Text(label,
              style: ppBody(12, color: active ? Colors.white : ppSoft, w: active ? FontWeight.w700 : FontWeight.w600)),
        );
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          chip('Poor sleep', active: true),
          chip('Rashes'),
          chip('Colic'),
          chip('Teething'),
          chip('Dry skin'),
        ],
      ),
    );
  }

  Widget _productRow(BuildContext context, String rank, String title, String badge, Color badgeColor,
      String rating, String price, String source, Color sourceColor,
      {bool top = false, bool bottom = false}) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          SizedBox(width: 16, child: Text(rank, style: ppJakarta(14, color: ppPurple))),
          const SizedBox(width: 14),
          const PpStriped(height: 56, width: 56, radius: 16, border: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppJakarta(15, w: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                  child: Text(badge, style: ppBody(11, color: badgeColor, w: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Flexible(child: Text(rating, style: ppBody(12, color: ppMuted), overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(source, style: ppBody(10, color: sourceColor, w: sourceColor == ppMuted ? FontWeight.w400 : FontWeight.w600)),
          ]),
        ]),
      ),
    );
  }

  Widget _sponsored() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFECE5F2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ppEyebrow('Sponsored', color: ppMuted, spacing: 0.8),
        const SizedBox(height: 12),
        Row(children: [
          const PpStriped(height: 56, width: 56, radius: 16, border: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mamaearth Mineral Baby Lotion', style: ppJakarta(15)),
              const SizedBox(height: 3),
              Text('Still gets a ParentVeda summary & real reviews.', style: ppBody(12)),
            ]),
          ),
        ]),
      ]),
    );
  }
}
