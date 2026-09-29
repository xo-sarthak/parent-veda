// =============================================================================
//  PvWishlistScreen — where the heart puts things
// -----------------------------------------------------------------------------
//  The user's walk (2026-09-20): "I am able to wishlist the items but where
//  is the wishlist?" It existed — under You → Saved → Products — three taps
//  from the store, unsigned from the store itself. Every marketplace keeps
//  the wishlist one tap from the heart (Myntra's header heart, Blinkit's
//  saved list): this is that, reached from the heart in the store's header
//  with a count on it.
//
//  Reads `SavedStore` (kind: product) through the catalogue, so the same
//  heart lights on the shelf, on the page and here; a product that has left
//  the catalogue is dropped quietly rather than rendered as a blank card.
//  The word is "wishlist" — the user's word.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../services/life_stage_store.dart';
import '../../services/pv_catalog_store.dart';
import '../../services/saved_store.dart';
import '../../theme/pv_fonts.dart';
import 'pv_store_chrome.dart';

class PvWishlistScreen extends StatelessWidget {
  const PvWishlistScreen({super.key, required this.stage});
  final LifeStage stage;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: SavedStore.instance,
      builder: (context, _) {
        final items = SavedStore.instance.items(kind: SavedKind.product);
        final products = <PvProduct>[
          for (final it in items) ?PvCatalogStore.instance.byId(it.itemId),
        ];
        // Hers first, then the other stages — the wishlist spans the journey.
        final mine = products.where((x) => x.stage == stage.shopStage).toList();
        final rest = products.where((x) => x.stage != stage.shopStage).toList();
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + 10,
                    16,
                    6,
                  ),
                  child: Row(
                    children: [
                      PvRoundIcon(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STORE',
                              style: pvManrope(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: kPvInk,
                              ),
                            ),
                            Text(
                              'Wishlist',
                              style: pvFraunces(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: p.ink1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (products.isNotEmpty)
                        Text(
                          products.length == 1
                              ? '1 item'
                              : '${products.length} items',
                          style: pvManrope(fontSize: 13, color: p.ink3),
                        ),
                    ],
                  ),
                ),
              ),
              if (products.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kPvLine),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 22,
                            color: p.ink1,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Nothing here yet. The heart on any product keeps it here, across every stage.',
                              style: pvManrope(
                                fontSize: 13.5,
                                height: 1.45,
                                color: p.ink2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                if (mine.isNotEmpty)
                  PvProductGridSliver(
                    products: mine,
                    heroScope: 'wishlist',
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  ),
                if (rest.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
                      child: Text(
                        mine.isEmpty
                            ? 'From your other chapters'
                            : 'From other chapters',
                        style: pvFraunces(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: p.ink1,
                        ),
                      ),
                    ),
                  ),
                  PvProductGridSliver(
                    products: rest,
                    heroScope: 'wishlist-rest',
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  ),
                ],
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }
}
