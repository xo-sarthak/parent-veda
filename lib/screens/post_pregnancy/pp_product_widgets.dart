// =============================================================================
//  Products - shared widgets: the compare-aware product card + the floating
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
            onTap: () => _onToggle(context),
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
              Text(selected ? 'Added' : 'Compare',
                  style: ppBody(12, color: selected ? ppPurple : ppSoft, w: FontWeight.w600)),
            ]),
          ),
        ]);
      },
    );
  }

  // Toggle this product in/out of the comparison and, when a tap is blocked by
  // a rule, explain why (never a silent no-op).
  void _onToggle(BuildContext context) {
    final r = PpCompareStore.instance.toggle(product);
    final messenger = ScaffoldMessenger.of(context);
    if (r == PpCompareResult.wrongCategory) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Products can only be compared within the same category.'),
        behavior: SnackBarBehavior.floating,
      ));
    } else if (r == PpCompareResult.full) {
      messenger.showSnackBar(const SnackBar(
        content: Text('You can compare up to 3 - remove one to swap in another.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: ppBody(9, color: color, w: FontWeight.w700)),
      );
}

/// Floating Compare bar - appears the moment the first product is added and
/// follows the parent through the Products ecosystem. Shows the running count
/// AND the category (so the comparison never feels detached), and opens the
/// Compare screen on tap - which builds itself from whatever is selected. Once
/// two are picked it gives a gentle pulse to signal "ready to compare". Drop
/// inside a Stack.
class PpCompareFab extends StatefulWidget {
  const PpCompareFab({super.key});

  @override
  State<PpCompareFab> createState() => _PpCompareFabState();
}

class _PpCompareFabState extends State<PpCompareFab> with SingleTickerProviderStateMixin {
  // Created eagerly in initState (not lazily) so the ticker is bound to a live
  // context - a lazy `late final` would first initialise inside dispose() when
  // the bar was never shown, and createTicker on a defunct context crashes.
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  bool _wasReady = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 620));
    _scale = Tween<double>(begin: 1.0, end: 1.045).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _wasReady = PpCompareStore.instance.ready;
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  // A short, bounded nudge (two gentle bounces) - not an endless animation, so
  // it never blocks the widget tree from settling. Guarded against the widget
  // being disposed mid-pulse.
  Future<void> _bump() async {
    try {
      for (var i = 0; i < 2 && mounted; i++) {
        await _pulse.forward(from: 0);
        if (!mounted) return;
        await _pulse.reverse();
      }
    } catch (_) {/* controller disposed mid-pulse */}
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PpCompareStore.instance,
      builder: (context, _) {
        final store = PpCompareStore.instance;
        final ready = store.ready;
        // Fire the pulse the moment the parent has enough to compare.
        if (ready && !_wasReady) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _bump();
          });
        }
        _wasReady = ready;
        if (store.count == 0) return const SizedBox.shrink();

        final bar = GestureDetector(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (_) => const ProductsCompareScreen())),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
            decoration: BoxDecoration(
              color: ppPurple,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [BoxShadow(color: Color(0x996A30B6), blurRadius: 26, spreadRadius: -8, offset: Offset(0, 12))],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.compare_arrows_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 10),
              Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Compare (${store.count})', style: ppBody(13.5, color: Colors.white, w: FontWeight.w800)),
                if (store.category != null)
                  Text(ready ? store.category! : '${store.category!} · add one more',
                      style: ppBody(10, color: Colors.white.withValues(alpha: 0.82))),
              ]),
              const SizedBox(width: 12),
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ready ? Colors.white : Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_rounded, size: 16, color: ready ? ppPurple : Colors.white),
              ),
            ]),
          ),
        );

        return Positioned(
          right: 18,
          bottom: 22,
          child: ScaleTransition(scale: _scale, child: bar),
        );
      },
    );
  }
}
