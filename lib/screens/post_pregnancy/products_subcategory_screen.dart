// =============================================================================
//  ProductsSubcategoryScreen — Products · subcategory (parenting · S3·subcat)
// -----------------------------------------------------------------------------
//  A subcategory (Soothers & white noise): what-to-look-for + a ParentVeda-
//  ranked product list, with a compare shortcut. Faithful build of Claude
//  Design S3·subcategory. Product rows open the detail. No bottom nav.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'product_detail_screen.dart';
import 'products_compare_screen.dart';

class ProductsSubcategoryScreen extends StatelessWidget {
  const ProductsSubcategoryScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _openDetail(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductDetailScreen()));

  void _openCompare(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsCompareScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            // breadcrumb
            _pad(Text.rich(TextSpan(children: [
              TextSpan(text: 'Products', style: TextStyle(color: ppPurple, fontWeight: FontWeight.w600)),
              const TextSpan(text: '  ›  ', style: TextStyle(color: Color(0xFFC7BBD6))),
              TextSpan(text: 'Sleep', style: TextStyle(color: ppPurple, fontWeight: FontWeight.w600)),
              const TextSpan(text: '  ›  ', style: TextStyle(color: Color(0xFFC7BBD6))),
              const TextSpan(text: 'Soothers'),
            ]), style: ppBody(12, color: ppMuted))),

            const SizedBox(height: 16),
            _pad(Text('Soothers & white noise', style: ppFraunces(28, h: 1.15))),
            const SizedBox(height: 12),
            _pad(Text(
                'Steady white noise — not looping lullabies — masks the household sounds that pull a baby out of light sleep. Look for true continuous sound, an auto-off timer, and a volume you can keep gentle. Below, ranked by ParentVeda.',
                style: ppBody(15, h: 1.65))),

            const SizedBox(height: 16),
            _pad(Wrap(spacing: 8, runSpacing: 8, children: [
              _chip('✓ Safe-sleep checked', fg: ppPurple, w: FontWeight.w700),
              _chip('0–12 months', fg: ppSoft, w: FontWeight.w600),
            ])),

            // product list
            const SizedBox(height: 26),
            _pad(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('4 soothers', style: ppJakarta(17)),
                Text('Ranked', style: ppBody(12, color: ppMuted)),
              ],
            )),
            const SizedBox(height: 6),
            _pad(_row(context, '1', 'Dozy White-Noise Soother', '✓ Verified', ppPurple, '★ 4.8 · 214',
                '₹1,499', 'on Amazon', top: true)),
            _pad(_row(context, '2', 'Lull Portable Soother', 'Popular', ppBrown, '★ 4.5 · 88', '₹999',
                'on FirstCry')),
            _pad(_row(context, '3', 'Hush Mini Sound Machine', '✓ Verified', ppPurple, '★ 4.4 · 61',
                '₹749', 'on Amazon')),
            _pad(_row(context, '4', 'CloudTunes Soother', null, ppMuted, '★ 4.1 · 34', '₹599',
                'on FirstCry', bottom: true)),

            // compare
            const SizedBox(height: 20),
            _pad(GestureDetector(
              onTap: () => _openCompare(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
                child: Row(children: [
                  const Icon(Icons.compare_arrows_rounded, color: ppPurple, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Compare the top two', style: ppJakarta(14)),
                      const SizedBox(height: 1),
                      Text('Dozy vs Lull, side by side.', style: ppBody(12)),
                    ]),
                  ),
                  const Text('→', style: TextStyle(color: ppPurple)),
                ]),
              ),
            )),

            const SizedBox(height: 22),
            _pad(Text(
                "Ranked by ParentVeda's own testing + verified-mother reviews. Buy links are transparent about where they go.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, {required Color fg, required FontWeight w}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: ppBody(11, color: fg, w: w)),
      );

  Widget _row(BuildContext context, String rank, String title, String? badge, Color badgeColor,
      String rating, String price, String source,
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
              Text(title, style: ppJakarta(15, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Row(children: [
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                    child: Text(badge, style: ppBody(11, color: badgeColor, w: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(child: Text(rating, style: ppBody(12, color: ppMuted), overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(source, style: ppBody(10, color: ppMuted)),
          ]),
        ]),
      ),
    );
  }
}
