// =============================================================================
//  Products — shared widgets: the compare-aware product card + the floating
//  Compare button. Both listen to PpCompareStore so a tick in one place shows
//  up everywhere and the button reflects the running count. Used by the
//  category and subcategory screens. Isolated to the post_pregnancy module.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_products_data.dart';
import 'product_detail_screen.dart';
import 'products_compare_screen.dart';

const Color _bestRed = Color(0xFFC6295A);

/// A product card for the 2-column grids: image + badge, name, bestseller tag,
/// rating, price·retailer, and a Compare checkbox wired to PpCompareStore.
class PpProductCard extends StatelessWidget {
  const PpProductCard(this.product, {super.key});
  final PpProduct product;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PpCompareStore.instance,
      builder: (context, _) {
        final selected = PpCompareStore.instance.isSelected(product);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => ProductDetailScreen(product: product))),
            behavior: HitTestBehavior.opaque,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(children: [
                const PpStriped(height: 130, radius: 16, border: true),
                if (product.parentVeda)
                  Positioned(top: 8, left: 8, child: _badge('ParentVeda', ppBrown))
                else if (product.verified)
                  Positioned(top: 8, left: 8, child: _badge('✓ Verified', ppPurple)),
              ]),
              const SizedBox(height: 9),
              Text(product.name,
                  style: ppJakarta(14, w: FontWeight.w600).copyWith(height: 1.25),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              if (product.bestseller) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.emoji_events_outlined, size: 11, color: _bestRed),
                    const SizedBox(width: 4),
                    Text('Bestseller', style: ppBody(10, color: _bestRed, w: FontWeight.w700)),
                  ]),
                ),
              ],
              const SizedBox(height: 6),
              Row(children: [
                Text(product.ratingLabel, style: ppBody(11, color: ppCoral, w: FontWeight.w700)),
                const SizedBox(width: 6),
                Text('${product.reviews}', style: ppBody(11, color: ppMuted)),
              ]),
              const SizedBox(height: 3),
              Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                Flexible(child: Text(product.priceLabel, style: ppBody(14, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 5),
                Text(product.retailer, style: ppBody(10, color: ppMuted)),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => PpCompareStore.instance.toggle(product),
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? ppPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: selected ? null : Border.all(color: const Color(0xFFC7BBD6), width: 1.5),
                ),
                child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
              ),
              const SizedBox(width: 6),
              Text('Compare', style: ppBody(12, color: selected ? ppPurple : ppSoft, w: FontWeight.w600)),
            ]),
          ),
        ]);
      },
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: ppBody(9, color: color, w: FontWeight.w700)),
      );
}

/// Floating Compare button — appears once anything is selected, shows the count,
/// and opens the Compare screen when two are picked. Drop inside a Stack.
class PpCompareFab extends StatelessWidget {
  const PpCompareFab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PpCompareStore.instance,
      builder: (context, _) {
        final store = PpCompareStore.instance;
        if (store.count == 0) return const SizedBox.shrink();
        return Positioned(
          right: 18,
          bottom: 22,
          child: GestureDetector(
            onTap: () {
              if (store.ready) {
                Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => const ProductsCompareScreen()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tick one more to compare'), behavior: SnackBarBehavior.floating),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              decoration: BoxDecoration(
                color: ppPurple,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [BoxShadow(color: Color(0x996A30B6), blurRadius: 26, spreadRadius: -8, offset: Offset(0, 12))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.compare_arrows_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 9),
                Text('Compare', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                const SizedBox(width: 9),
                Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(999)),
                  child: Text('${store.count}', style: ppBody(12, color: Colors.white, w: FontWeight.w700)),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
