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
//
//  NAMED LISTS (2026-10-28, the user: "like Amazon does, name your own wish
//  list"). A row of chips over the grid: All · each of her lists · New list.
//  "All" is every hearted product AND everything in any list, so nothing
//  she kept is out of sight. A list's chip shows only that list, with Edit
//  (rename, delete). The lists live in PvListStore.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../services/life_stage_store.dart';
import '../../services/pv_catalog_store.dart';
import '../../services/pv_list_store.dart';
import '../../services/saved_store.dart';
import '../../theme/pv_fonts.dart';
import 'pv_list_sheet.dart';
import 'pv_store_chrome.dart';

class PvWishlistScreen extends StatefulWidget {
  const PvWishlistScreen({super.key, required this.stage});
  final LifeStage stage;

  @override
  State<PvWishlistScreen> createState() => _PvWishlistScreenState();
}

class _PvWishlistScreenState extends State<PvWishlistScreen> {
  /// The chip she picked: null = All.
  String? _listId;

  LifeStage get stage => widget.stage;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      // Kept for revert: listenable: SavedStore.instance.
      listenable: Listenable.merge([SavedStore.instance, PvListStore.instance]),
      builder: (context, _) {
        final lists = PvListStore.instance.lists;
        final picked = _listId == null
            ? null
            : PvListStore.instance.byId(_listId!);
        // All = hearted + everything in any list, once each. Kept for
        // revert: the hearted items alone.
        final ids = picked != null
            ? picked.productIds
            : {
                for (final it in SavedStore.instance.items(
                  kind: SavedKind.product,
                ))
                  it.itemId,
                ...PvListStore.instance.allProductIds,
              }.toList();
        final products = <PvProduct>[
          for (final id in ids) ?PvCatalogStore.instance.byId(id),
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
              SliverToBoxAdapter(child: _chips(lists, picked)),
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
                              picked != null
                                  ? 'Nothing in "${picked.name}" yet. On any product, tap Save to a list and tick this one.'
                                  : 'Nothing here yet. The heart on any product keeps it here, across every stage, and Save to a list sorts it into lists you name.',
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

  Widget _chips(List<PvProductList> lists, PvProductList? picked) =>
      SingleChildScrollView(
        key: const ValueKey('pv_wishlist_chips'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
        child: Row(
          children: [
            PvChip(
              label: 'All',
              selected: picked == null,
              onTap: () => setState(() => _listId = null),
            ),
            for (final l in lists) ...[
              const SizedBox(width: 8),
              PvChip(
                key: ValueKey('pv_wishlist_chip_${l.id}'),
                label: '${l.name} · ${l.productIds.length}',
                selected: picked?.id == l.id,
                onTap: () => setState(() => _listId = l.id),
              ),
            ],
            const SizedBox(width: 8),
            if (picked != null)
              PvChip(
                key: const ValueKey('pv_wishlist_edit_list'),
                label: 'Edit list',
                selected: false,
                onTap: () async {
                  await showPvEditListSheet(context, picked);
                  if (mounted && PvListStore.instance.byId(picked.id) == null) {
                    setState(() => _listId = null);
                  }
                },
              )
            else
              PvChip(
                key: const ValueKey('pv_wishlist_new_list'),
                label: '+ New list',
                selected: false,
                onTap: () => _newList(),
              ),
          ],
        ),
      );

  Future<void> _newList() async {
    final name = TextEditingController();
    final made = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('New list'),
        content: TextField(
          controller: name,
          autofocus: true,
          maxLength: PvListStore.maxNameLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'e.g. Hospital bag'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(d).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(d).pop(name.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    // After the dialog's exit animation: its TextField still listens until then.
    Future<void>.delayed(const Duration(milliseconds: 600), name.dispose);
    if (made == null || !mounted) return;
    final l = PvListStore.instance.create(made);
    if (l == null) {
      pvSnack(
        context,
        made.trim().isEmpty
            ? 'A list needs a name.'
            : 'You already have a list called "${made.trim()}".',
      );
      return;
    }
    setState(() => _listId = l.id);
    pvSnack(context, 'List "${l.name}" made. Add products from any product page.');
  }
}
