// =============================================================================
//  "Useful at this age": the Parenting product rails, from the Store's own
//  catalogue (relevance PP 3 and PP 5, 2026-10-28)
// -----------------------------------------------------------------------------
//  The home and the phase page used to read the 24 products typed into
//  `pp_products_data.dart`, and padded a rail of six with products that did
//  not suit the age. The Store reads `PvCatalogStore`: the same 24 under the
//  same ids, plus every product the store sheet adds. Two lists drift, so now
//  there is one: these rails read the catalogue, keep only what suits the age,
//  and show fewer cards rather than a bottle for a five-year-old.
//
//  ⚠️ THE STORE'S RULE, AT ANY AGE. The home's rail is the Store's "For you"
//  (`PvCatalogStore.forYou`) re-ordered by her situation. The phase page asks
//  the same question about a phase that may not have started, so the rule takes
//  the age as an argument instead of reading the child. `forYou` reads the
//  child itself; test/pp_relevance_batch2_test.dart holds the two in step for
//  the child on screen, so the Store and the home cannot quietly disagree.
// =============================================================================
import 'package:flutter/material.dart';
import '../../models/pv_product.dart';
import '../../services/life_stage_store.dart';
import '../../services/pv_catalog_store.dart';
import '../../theme/pv_fonts.dart';
import '../products/pv_product_screen.dart';
import '../products/pv_store_chrome.dart' show PvProductImage;
import '../v2/v2_palette.dart';
import 'pp_relevance.dart';

/// Up to [limit] catalogue products that suit a child of [months]: one per
/// category, the Store's order (its recommendation band, then reviews), with
/// her situation's products first when [situation] is given. Never pads with a
/// product outside the age.
List<PvProduct> ppCatalogProducts(int months,
    {int limit = 6, PpSituation? situation}) {
  final cat = PvCatalogStore.instance;
  final fit = [
    // A "Coming soon" place-holder is a gap, never a pick for her child
    // (2026-10-28, pv_coming_soon.dart), the same rule as the Store's rails.
    // Kept for revert: if (!p.reviewOnly && p.suitsAge(months)) p
    for (final p in cat.forStage(LifeStage.parenting))
      if (!p.reviewOnly && !p.comingSoon && p.suitsAge(months)) p
  ]..sort((a, b) {
      // The same order as `PvCatalogStore.forYou`.
      final ra = a.reco?.band.rank ?? 9;
      final rb = b.reco?.band.rank ?? 9;
      if (ra != rb) return ra.compareTo(rb);
      return b.reviewCount.compareTo(a.reviewCount);
    });
  // Her situation before the one-per-category cut, so a bottle set can stand
  // for Feeding when she formula-feeds. commerce: an urgent "Something
  // changed?" never lifts a product (Wave 8).
  final ordered = situation == null
      ? fit
      : ppRelevanceOrder(fit,
          situation: situation,
          text: (p) => '${p.name} ${cat.category(p.categoryId)?.name ?? ''}',
          commerce: true);
  final seen = <String>{};
  return [for (final p in ordered) if (seen.add(p.categoryId)) p]
      .take(limit)
      .toList();
}

/// Opens the Store's product page, under the Parenting route name the home
/// always used (`pp/product/<id>`), so the Ask button still knows the stage.
void ppOpenCatalogProduct(BuildContext context, PvProduct p) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'pp/product/${p.id}'),
        builder: (_) => PvProductScreen(productId: p.id)));

/// The rail of cards: the photo (or the Store's honest cover block) and the
/// name, no price. One widget for the home (132 wide) and the phase page (112).
class PpCatalogRail extends StatelessWidget {
  const PpCatalogRail({
    super.key,
    required this.items,
    required this.p,
    this.cardWidth = 132,
    this.imageHeight = 108,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
    this.itemKey = 'pp_product_',
  });

  final List<PvProduct> items;
  final V2Palette p;
  final double cardWidth;
  final double imageHeight;
  final EdgeInsets padding;

  /// Prefix of each card's key, followed by the product id.
  final String itemKey;

  @override
  Widget build(BuildContext context) {
    final grow =
        ((MediaQuery.textScalerOf(context).scale(10) / 10) - 1).clamp(0.0, 1.0);
    return SizedBox(
      height: imageHeight + 64 + grow * 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final it = items[i];
          return SizedBox(
            width: cardWidth,
            child: InkWell(
              key: ValueKey('$itemKey${it.id}'),
              onTap: () => ppOpenCatalogProduct(context, it),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: cardWidth,
                        height: imageHeight,
                        child: PvProductImage(product: it)),
                    const SizedBox(height: 8),
                    Text(it.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvJakarta(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            color: p.ink1)),
                  ]),
            ),
          );
        },
      ),
    );
  }
}
