// =============================================================================
//  Products - shared widgets: the compare-aware product card + the floating
//  Compare button. Both listen to PpCompareStore so a tick in one place shows
//  up everywhere and the button reflects the running count. Used by the
//  category and subcategory screens. Isolated to the post_pregnancy module.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../product_guide/product_guide_chooser.dart';
import 'pp_common.dart';
import 'pp_products_data.dart';
import 'product_detail_screen.dart';
import 'products_compare_screen.dart';

const Color _bestRed = Color(0xFFC6295A);
const Color _guideGreen = Color(0xFF1F8A5B);
const Color _guideRed = Color(0xFFD64545);

// Shared compare toggle behaviour - toggles the product in/out of the running
// comparison and, when a rule blocks the tap, explains why (never silent).
void ppToggleCompare(BuildContext context, PpProduct product) {
  final r = PpCompareStore.instance.toggle(product);
  final messenger = ScaffoldMessenger.of(context);
  if (r == PpCompareResult.wrongCategory) {
    messenger.showSnackBar(const SnackBar(
      content: Text('Products can only be compared within the same category.'),
      behavior: SnackBarBehavior.floating,
    ));
  } else if (r == PpCompareResult.full) {
    messenger.showSnackBar(const SnackBar(
      content: Text('You can compare up to two - remove one to swap in another.'),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

// Route a buy tap: affiliate products open their retailer's site; ParentVeda's
// own (in-app) products stay in the app (mock checkout for now).
Future<void> ppLaunchBuy(BuildContext context, PpProduct p) async {
  final messenger = ScaffoldMessenger.of(context);
  if (!ppIsAffiliate(p)) {
    messenger.showSnackBar(SnackBar(
      content: Text('Buying ${p.name} in-app - checkout opens soon.'),
      behavior: SnackBarBehavior.floating,
    ));
    return;
  }
  bool ok;
  try {
    ok = await launchUrl(Uri.parse(ppBuyUrl(p)), mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok) {
    messenger.showSnackBar(SnackBar(
      content: Text('Could not open ${p.retailer} - please try again.'),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

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
            onTap: () => openProductWithGuideCheck(context,
                id: product.id,
                name: product.name,
                onOpenNormal: () => Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => ProductDetailScreen(product: product)))),
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

// ===========================================================================
//  ParentVeda Guidance card - the "20-second" education layer that leads a
//  subcategory page: a guidance one-liner + LOOK FOR (green checks) + AVOID
//  (red x). Mirrors the pregnancy app's ParentVeda Guidance card in pp tokens.
// ===========================================================================
class PpGuidanceCard extends StatelessWidget {
  const PpGuidanceCard(this.guide, {super.key});
  final PpGuide guide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ppPurple.withValues(alpha: 0.10), ppBg],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ppPurple.withValues(alpha: 0.18)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.favorite_border_rounded, size: 15, color: ppPurple),
          const SizedBox(width: 8),
          Text('ParentVeda Guidance', style: ppJakarta(13.5, color: ppPurple)),
        ]),
        const SizedBox(height: 10),
        Text(guide.line, style: ppBody(14.5, color: ppInk, h: 1.5)),
        const SizedBox(height: 16),
        ppEyebrow('Look for', color: ppMuted, spacing: 0.6),
        const SizedBox(height: 8),
        for (final l in guide.lookFor) _row(Icons.check_rounded, _guideGreen, l),
        const SizedBox(height: 12),
        ppEyebrow('Avoid', color: ppMuted, spacing: 0.6),
        const SizedBox(height: 8),
        for (final a in guide.avoid) _row(Icons.close_rounded, _guideRed, a),
      ]),
    );
  }

  Widget _row(IconData icon, Color color, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 15, color: color)),
          const SizedBox(width: 9),
          Expanded(child: Text(t, style: ppBody(13.5, color: ppInk, h: 1.45))),
        ]),
      );
}

// ===========================================================================
//  A small, shareable "Compare / Added" toggle wired to PpCompareStore. Used on
//  the rich snapshot card; kept separate so any surface can drop it in.
// ===========================================================================
class PpCompareToggle extends StatelessWidget {
  const PpCompareToggle(this.product, {super.key});
  final PpProduct product;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PpCompareStore.instance,
      builder: (context, _) {
        final selected = PpCompareStore.instance.isSelected(product);
        return GestureDetector(
          onTap: () => ppToggleCompare(context, product),
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
        );
      },
    );
  }
}

// ===========================================================================
//  Rich product SNAPSHOT card - one per row on a subcategory page. Carries the
//  badge, name + summary, rating, "Best for", "Why ParentVeda recommends"
//  (green checks), "Things to consider" (red dots), and price + a routed Buy
//  (affiliate → retailer, in-app → ParentVeda). Tapping the body opens detail;
//  the Compare toggle keeps the side-by-side flow working. Full width.
// ===========================================================================
class PpProductSnapshotCard extends StatelessWidget {
  const PpProductSnapshotCard(this.product, {super.key});
  final PpProduct product;

  @override
  Widget build(BuildContext context) {
    final badge = product.badge;
    final affiliate = ppIsAffiliate(product);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ppHair),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // badge + provenance tag + compare toggle (Wrap keeps the left group
        // from overflowing the compare toggle under wide-font fallbacks)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (badge.isNotEmpty) _badgeChip(badge),
              _provenanceTag(affiliate),
            ]),
          ),
          const SizedBox(width: 8),
          PpCompareToggle(product),
        ]),
        const SizedBox(height: 14),

        // image + name + summary (tap → detail)
        GestureDetector(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (_) => ProductDetailScreen(product: product))),
          behavior: HitTestBehavior.opaque,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(width: 62, child: PpStriped(height: 62, radius: 14, border: true)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name,
                    style: ppJakarta(15.5).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(ppSummaryOf(product),
                    style: ppBody(12.5, h: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),

        // rating + best for
        Row(children: [
          _ratingPill(product),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Best for  ', style: ppBody(12, color: ppMuted, w: FontWeight.w700)),
                TextSpan(text: ppBestForOf(product), style: ppBody(12, color: ppInk, w: FontWeight.w600)),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        const SizedBox(height: 14),

        // why ParentVeda recommends
        ppEyebrow('Why ParentVeda recommends', color: ppMuted, spacing: 0.4),
        const SizedBox(height: 8),
        for (final w in ppProsOf(product).take(3)) _whyRow(w),

        // things to consider
        const SizedBox(height: 10),
        ppEyebrow('Things to consider', color: ppMuted, spacing: 0.4),
        const SizedBox(height: 8),
        for (final c in ppConsOf(product).take(2)) _considerRow(c),
        const SizedBox(height: 14),

        // price + buy
        Row(children: [
          Flexible(child: Text(product.priceLabel, style: ppJakarta(18), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 10),
          const Spacer(),
          GestureDetector(
            onTap: () => ppLaunchBuy(context, product),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (affiliate) ...[
                  const Icon(Icons.open_in_new_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(ppBuyLabel(product), style: ppBody(13, color: Colors.white, w: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _badgeChip(String badge) {
    final c = ppBadgeColor(badge);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(ppBadgeEmoji(badge), style: const TextStyle(fontSize: 11.5)),
        const SizedBox(width: 5),
        Text(badge, style: ppBody(11, color: c, w: FontWeight.w700)),
      ]),
    );
  }

  Widget _provenanceTag(bool affiliate) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(affiliate ? Icons.open_in_new_rounded : Icons.verified_outlined,
              size: 11, color: affiliate ? ppBrown : ppPurple),
          const SizedBox(width: 4),
          Text(affiliate ? product.retailer : 'ParentVeda',
              style: ppBody(10, color: affiliate ? ppBrown : ppPurple, w: FontWeight.w700)),
        ]),
      );

  Widget _ratingPill(PpProduct p) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.star_rounded, size: 14, color: ppCoral),
          const SizedBox(width: 4),
          Text(p.rating.toStringAsFixed(1), style: ppBody(12, color: ppInk, w: FontWeight.w800)),
          const SizedBox(width: 5),
          Text('· ${p.reviews}', style: ppBody(11, color: ppMuted)),
        ]),
      );

  Widget _whyRow(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.only(top: 1), child: Icon(Icons.check_rounded, size: 15, color: _guideGreen)),
          const SizedBox(width: 9),
          Expanded(child: Text(t, style: ppBody(13, color: ppInk, h: 1.45))),
        ]),
      );

  Widget _considerRow(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: _guideRed, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(t, style: ppBody(13, color: ppSoft, h: 1.45))),
        ]),
      );
}
