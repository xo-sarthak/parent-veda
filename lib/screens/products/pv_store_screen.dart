// =============================================================================
//  PvStoreScreen — the storefront. "The app opening in itself."
// -----------------------------------------------------------------------------
//  The first screen of every shopping app she already uses, in this order
//  (Amazon, Target, Blinkit, H&M — docs/PRODUCTS-AUDIT.md §2):
//
//    search bar + cart · the department switch · category shortcuts ·
//    a "for you" rail · the editorial rail · shelves by category
//
//  and the one thing that is ours, in the second slot where H&M puts
//  `WOMEN +`: the STAGE SWITCH. It opens on her stage — a pregnant mother
//  sees pregnancy — and the other two are one tap away, because there is one
//  store, not three. Switching changes what leads; it never removes anything.
//
//  ⚠️ TAB ROOT IN THREE SHELLS. Pregnancy embeds it (the scaffold owns the
//  bar); parenting and TTC push it with their own bar. `chrome` says which.
//  The screen itself is identical — that is the point.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../services/cart_store.dart';
import '../../services/life_stage_store.dart';
import '../../services/pv_catalog_store.dart';
import '../../services/pv_order_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../../widgets/pv_nav_bar.dart';
import '../doors/pv_list_row.dart';
import 'pv_cart_screen.dart';
import 'pv_hero_band.dart';
import 'pv_orders_screen.dart';
import 'pv_search_screen.dart';
import 'pv_wishlist_screen.dart';
import '../../services/saved_store.dart';
import 'pv_shelf_screen.dart';
import '../v2/v2_palette.dart';
import 'pv_store_chrome.dart';
import 'pv_store_marks.dart';
// The TTC tab root's shared header (2026-09-29); only the TTC chrome uses it.
import '../ttc/ttc_tab_root_header.dart'
    show
        TtcTabRootHeader,
        kTtcTabRootGutter,
        kTtcTabRootRowHeight,
        ttcTabRootIntroStyle;

class PvStoreScreen extends StatefulWidget {
  const PvStoreScreen({super.key, required this.chrome, this.initialStage});
  final PvStoreChrome chrome;

  /// Which storefront opens first. Null = her stage.
  final LifeStage? initialStage;

  @override
  State<PvStoreScreen> createState() => _PvStoreScreenState();
}

class _PvStoreScreenState extends State<PvStoreScreen> {
  late LifeStage _stage;

  /// Whether the stage switch is drawn in full (H11, 2026-09-28). On the
  /// Trying to conceive storefront it starts folded to a quiet "Other
  /// stages" link, so another stage's shop is not on her screen by default.
  // Kept for revert (2026-10-02): the "Other stages" link's state, no longer read.
  // ignore: unused_field
  final bool _showStages = false;

  @override
  void initState() {
    super.initState();
    _stage =
        (widget.initialStage ??
                LifeStageStore.instance.stage ??
                LifeStage.pregnancy)
            .shopStage;
    CartStore.instance.init();
    PvOrderStore.instance.init();
  }

  void _openShelf(PvCategory c, {String? subId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PvShelfScreen(categoryId: c.id, subId: subId),
        settings: RouteSettings(name: 'store/shelf/${c.id}'),
      ),
    );
  }

  void _openWishlist() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PvWishlistScreen(stage: _stage),
      settings: const RouteSettings(name: 'store/wishlist'),
    ),
  );

  void _openSearch() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PvSearchScreen(stage: _stage),
      settings: const RouteSettings(name: 'store/search'),
    ),
  );

  void _openCart() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const PvCartScreen(),
      settings: const RouteSettings(name: 'store/cart'),
    ),
  );

  // Nothing on the store top opens this since 2026-09-29 (orders are on her
  // profile). Kept for revert with the two commented circles.
  // ignore: unused_element
  void _openOrders() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const PvOrdersScreen(),
      settings: const RouteSettings(name: 'store/orders'),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final store = PvCatalogStore.instance;
    return ListenableBuilder(
      listenable: Listenable.merge([
        store,
        CartStore.instance,
        PvOrderStore.instance,
      ]),
      builder: (context, _) {
        final cats = store.categoriesFor(_stage);
        final ttc = _stage == LifeStage.tryingToConceive;
        // ⚠️ ON THE TTC STOREFRONT, ONE PRODUCT ONCE ABOVE THE FOLD (launch
        // sanity PR3, 2026-09-28). Folic acid was the hero, the first card of
        // "Where most couples start" and the first card of Supplements: the
        // store looked like one product. The hero's products leave the
        // for-you rail, and shelves of one item fold into one "Also useful"
        // rail until they grow. Other storefronts are unchanged. Kept for
        // revert: `final forYou = store.forYou(_stage);`.
        final heroIds = ttc ? pvHeroProductIds(_stage) : const <String>{};
        final forYou = store
            .forYou(_stage)
            .where((p) => !heroIds.contains(p.id))
            .toList();
        // Never the same product twice on one screen (Amazon's rule): what
        // the for-you rail already shows is dropped from the recommends rail.
        final shown = {...forYou.map((p) => p.id), ...heroIds};
        final reco = store
            .recommended(_stage, limit: 12)
            .where((p) => !shown.contains(p.id))
            .take(8)
            .toList();
        final singles = ttc
            ? [
                for (final c in cats)
                  if (store.inCategory(c.id).length == 1) c,
              ]
            : const <PvCategory>[];
        final shelves = [
          for (final c in cats)
            if (!singles.contains(c)) c,
        ];
        final alsoUseful = [
          for (final c in singles) ...store.inCategory(c.id),
        ];
        final clock = store.clockLabel(_stage);
        final hasBar = widget.chrome != PvStoreChrome.none;
        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(
            children: [
              // MOTION: switching stage cross-fades and slides the storefront
              // (H&M's department switch), keyed by stage; the header and the
              // switch itself stay put so the tap target does not move.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, ?current],
                ),
                child: CustomScrollView(
                  key: ValueKey(_stage),
                  slivers: [
                    SliverToBoxAdapter(child: _header(p)),
                    SliverToBoxAdapter(child: _stageRow(p)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(_g, 12, _g, 4),
                        child: PvHeroBand(
                          key: ValueKey('hero_$_stage'),
                          slides: pvHeroSlidesFor(_stage),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: _categories(p, cats)),
                    // TTC's storefront only: shop by need (CVS's "Feeling
                    // queasy?" cards). Every other storefront is unchanged.
                    if (_stage == LifeStage.tryingToConceive)
                      SliverToBoxAdapter(child: _ttcNeeds(p)),
                    if (forYou.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _rail(
                          eyebrow: clock.isEmpty
                              ? 'For you'
                              : 'For you · $clock',
                          title: switch (_stage) {
                            LifeStage.pregnancy => 'What helps around now',
                            LifeStage.parenting => 'What you need at this age',
                            _ => 'Where most couples start',
                          },
                          products: forYou,
                          scope: 'foryou',
                        ),
                      ),
                    if (reco.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _rail(
                          eyebrow: 'ParentVeda recommends',
                          title: 'The ones we would buy ourselves',
                          lead:
                              'Not every product — a few, with the reason and the '
                              'name of who reviewed it. Some are ours, some are '
                              'affiliate links; each page says which.',
                          products: reco,
                          scope: 'reco',
                        ),
                      ),
                    // Kept for revert (PR3): `for (final c in cats)`.
                    for (final c in shelves)
                      SliverToBoxAdapter(
                        child: _shelf(p, c, store.inCategory(c.id)),
                      ),
                    if (alsoUseful.isNotEmpty)
                      SliverToBoxAdapter(
                        child: KeyedSubtree(
                          key: const ValueKey('pv_store_also_useful'),
                          child: _rail(
                            eyebrow: [for (final c in singles) c.name]
                                .join(' · '),
                            title: 'Also useful',
                            products: alsoUseful,
                            scope: 'also',
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(child: _honestyStrip(p)),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: hasBar ? pvNavClearance(context) : 40,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasBar) PvStoreNav(chrome: widget.chrome),
            ],
          ),
        );
      },
    );
  }

  // ---- the side gutter -----------------------------------------------------------

  /// The storefront's side gutter.
  ///
  /// ⚠️ 18 ON THE TTC TAB ROOT, 20 EVERYWHERE ELSE (2026-09-29). Learn and
  /// Tools sit on the stage's 18 (`kTtcTabRootGutter`), and the Products tab
  /// sat on the storefront's 20, so the titles jumped 2dp sideways between
  /// tabs. Keyed on the CHROME, not on the stage shown: it is the TTC tab
  /// root's edge, and "Other stages" on that tab keeps it. Pregnancy's and
  /// parenting's storefronts are unchanged. Kept for revert (2026-09-29):
  /// every `_g` in this file was a literal 20 (`const EdgeInsets.fromLTRB(20,
  /// …, 20, …)`, `const EdgeInsets.symmetric(horizontal: 20)`, `gutter: 20`)
  /// and the rails took PvCardRail's default 20.
  ///
  /// ⚠️ PREGNANCY'S PRODUCTS TAB TOO (2026-10-02, the user: make Products
  /// match TTC's): the embedded chrome wears the same tab-root header, so it
  /// takes the same 18. Parenting's storefront stays on 20.
  double get _g => widget.chrome == PvStoreChrome.ttc ||
          widget.chrome == PvStoreChrome.embedded
      ? kTtcTabRootGutter
      : 20;

  // ---- header: search + cart + orders -----------------------------------------

  Widget _header(V2Palette p) {
    // TTC's tab root wears the stage's one tab-root header; the pregnancy
    // and parenting storefronts keep theirs below, unchanged.
    // ⚠️ AND PREGNANCY'S (2026-10-02, the user: "make the products section of
    // pregnancy consistent with TTC"). It was the old pill-first header, so
    // leaving Learn for Products swapped a serif title for a grey pill. Now
    // the title, the intro and the search pill are TTC's, and the stage
    // switch (Trying / Pregnancy / Parenting) stays, drawn UNDER the search
    // (`_stageRow`). Kept for revert: `if (widget.chrome == PvStoreChrome.ttc)`.
    if (widget.chrome == PvStoreChrome.ttc ||
        widget.chrome == PvStoreChrome.embedded) {
      return _ttcHeader(p);
    }
    final cartCount = CartStore.instance.count(kProductsCartId);
    // Kept for revert (2026-09-29, the Orders circle is off the store top):
    //   final hasOrders = PvOrderStore.instance.orders.isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 14,
        20,
        6,
      ),
      child: Row(
        children: [
          // ⚠️ THE SAME PILL AS THE SEARCH SCREEN'S, Hero-linked — 2026-09-20.
          // It was a look-alike Container here and a TextField in another
          // Container there, at a different x and y, so tapping it made a
          // second shape appear under the first. One widget, one geometry,
          // and the pill she tapped slides up as the keyboard rises.
          Expanded(
            child: PvSearchPill(
              hero: true,
              onTap: _openSearch,
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 20, color: p.ink2),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pvSearchHintFor(_stage),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 14, color: p.ink3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // The wishlist: where the heart puts things (Myntra's header heart
          // with a count). It replaces the notice the heart used to show.
          ListenableBuilder(
            listenable: SavedStore.instance,
            builder: (context, _) => PvRoundIcon(
              icon: Icons.favorite_border_rounded,
              onTap: _openWishlist,
              badge: SavedStore.instance.items(kind: SavedKind.product).length,
              size: 46,
            ),
          ),
          const SizedBox(width: 8),
          // ⚠️ THE STORE TOP IS CART AND WISHLIST ONLY (2026-09-29). Orders
          // and bookings live on her profile (the avatar), where Ro,
          // Deliveroo, Instacart and Etsy keep "your orders": pregnancy and
          // parenting You already carry an Orders tile, and the confirmation
          // after checkout offers "See your orders". Kept for revert:
          //   if (hasOrders) ...[
          //     PvRoundIcon(icon: Icons.receipt_long_outlined,
          //         onTap: _openOrders, size: 46),
          //     const SizedBox(width: 8),
          //   ],
          PvRoundIcon(
            icon: Icons.shopping_bag_outlined,
            onTap: _openCart,
            badge: cartCount,
            size: 46,
          ),
        ],
      ),
    );
  }

  /// ⚠️ THE TTC TAB ROOT'S HEADER (2026-09-29, build 19). The user found the
  /// four tabs' headers at four heights. Products had no title at all: its
  /// first line was the search pill at the safe area + 14, beside 46dp
  /// circles, so leaving Learn for Products swapped a serif "Learn" for a
  /// grey pill in the same place. On the TTC storefront it now wears the
  /// stage's one header (`TtcTabRootHeader`, ttc_tab_root_header.dart): the
  /// title "Products" at the same y and size as Learn, Tools and More, the
  /// wishlist, orders and cart beside it at the row's 42dp, and the same
  /// Hero-linked search pill as its first content. The gutter stays 20, the
  /// storefront's edge, so the pill lines up with the hero band under it.
  /// Nothing she could tap is gone; the pill moved under the title.
  Widget _ttcHeader(V2Palette p) {
    final cartCount = CartStore.instance.count(kProductsCartId);
    // Kept for revert (2026-09-29, the Orders circle is off the store top):
    //   final hasOrders = PvOrderStore.instance.orders.isNotEmpty;
    return Padding(
      // The old header's 6 above the stage row, kept.
      padding: const EdgeInsets.only(bottom: 6),
      child: TtcTabRootHeader(
        title: 'Products',
        // Kept for revert (2026-09-29): gutter: 20. See `_g`.
        gutter: _g,
        // One plain line, like the other tabs' intros (2026-09-29).
        intro: Text(
          // The sentence follows the stage shown, so the switch under the
          // search changes it. Kept for revert (TTC's, the only one before):
          // "What to buy while you're trying, and why each one helps."
          switch (_stage) {
            LifeStage.pregnancy =>
              "What to buy while you're expecting, and why each one helps.",
            LifeStage.parenting =>
              'What to buy for your baby, and why each one helps.',
            _ => "What to buy while you're trying, and why each one helps.",
          },
          style: ttcTabRootIntroStyle(),
        ),
        trailing: [
          ListenableBuilder(
            listenable: SavedStore.instance,
            builder: (context, _) => PvRoundIcon(
              icon: Icons.favorite_border_rounded,
              onTap: _openWishlist,
              badge: SavedStore.instance.items(kind: SavedKind.product).length,
              size: kTtcTabRootRowHeight,
              semanticLabel: 'Wishlist',
            ),
          ),
          // Cart and wishlist only (2026-09-29): orders and bookings are on
          // her profile. Kept for revert:
          //   if (hasOrders)
          //     PvRoundIcon(icon: Icons.receipt_long_outlined,
          //         onTap: _openOrders, size: kTtcTabRootRowHeight,
          //         semanticLabel: 'Orders'),
          PvRoundIcon(
            icon: Icons.shopping_bag_outlined,
            onTap: _openCart,
            badge: cartCount,
            size: kTtcTabRootRowHeight,
            semanticLabel: 'Cart',
          ),
        ],
        below: PvSearchPill(
          hero: true,
          onTap: _openSearch,
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 20, color: p.ink2),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pvSearchHintFor(_stage),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 14, color: p.ink3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⚠️ THE TRYING STORE DOES NOT OPEN ON OTHER STAGES' SHOPS (launch sanity
  // H11, 2026-09-28). The walk found Pregnancy and Parenting tabs beside
  // Trying on her screen. On the TTC storefront the switch folds to a quiet
  // "Other stages" link that opens it; every other storefront keeps the
  // switch as it was. Kept for revert: the PvStageSwitch alone.
  Widget _stageRow(V2Palette p) {
    // ⚠️ NO "OTHER STAGES" ON THE TRYING STORE (2026-09-30, the user: it sits
    // "at a very abrupt position", and the store should simply open on trying
    // to conceive). Nothing at all is drawn here now. Kept for revert: the
    // quiet link below, behind `!_showStages`.
    //
    // ⚠️ THE SWITCH IS BACK, VISIBLE (2026-10-02, the user, on the TTC product
    // section: "under the search bar we don't have the Trying, Pregnancy,
    // Parenting options to switch stores"). What felt abrupt on 2026-09-30 was
    // the HIDING, not the switch: a quiet "Other stages" link that, once tapped,
    // revealed the other stores. So the Trying store now draws the same
    // `PvStageSwitch` as every other store, under the search pill, always there;
    // the other two stores are one tap away ("never hidden", the reason there is
    // one store). Kept for revert, the line that drew nothing:
    // if (_stage == LifeStage.tryingToConceive) return const SizedBox.shrink();
    // Kept for revert (2026-10-02): the "Other stages" link, now never drawn.
    // // ignore: dead_code
    // if (_stage == LifeStage.tryingToConceive && !_showStages) {
    //   return Padding(
    //     padding: EdgeInsets.fromLTRB(_g, 6, _g, 0),
    //     child: Align(
    //       alignment: Alignment.centerRight,
    //       child: TextButton(
    //         key: const ValueKey('pv_store_other_stages'),
    //         onPressed: () => setState(() => _showStages = true),
    //         style: TextButton.styleFrom(
    //           foregroundColor: p.ink2,
    //           padding: const EdgeInsets.symmetric(horizontal: 6),
    //           minimumSize: const Size(44, 36),
    //         ),
    //         child: Text(
    //           'Other stages',
    //           style: pvManrope(
    //             fontSize: 12.5,
    //             fontWeight: FontWeight.w700,
    //             color: p.ink2,
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // ⚠️ UNDER THE SEARCH PILL, AND WHY (2026-10-02, Mobbin: Glovo and Yami
    // draw the search pill first with the scoping chips and tabs directly
    // beneath it; Ro puts its tabs above content). The stage is a filter on
    // what the shop shows, so it follows the search, and the search then
    // sits at the same height as TTC's, which has no switch at all (its
    // store opens on trying, 2026-09-30). Gutter follows `_g`: 14 in 20 on
    // the old edge, 12 in 18 here.
    return Padding(
      padding: EdgeInsets.fromLTRB(_g - 6, 10, _g, 4),
      child: PvStageSwitch(
        stage: _stage,
        onChanged: (s) => setState(() => _stage = s),
      ),
    );
  }

  // ---- category shortcuts ------------------------------------------------------

  Widget _categories(V2Palette p, List<PvCategory> cats) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: SizedBox(
      // 72-px photo tiles (were 64-px icon wells) plus a two-line label.
      // The label's two lines grow with her text size (2026-09-29): a fixed
      // 112 clipped the tiles by 9px at 1.5x on a 360dp phone. At 1.0x this
      // is the old 112. Kept for revert: height: 112.
      height: 79 + MediaQuery.textScalerOf(context).scale(11.5) * 1.2 * 2 + 5,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // 4 inside the gutter, as it was (16 in 20). Kept for revert
        // (2026-09-29): const EdgeInsets.symmetric(horizontal: 16).
        padding: EdgeInsets.symmetric(horizontal: _g - 4),
        itemCount: cats.length,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) =>
            PvCategoryTile(category: cats[i], onTap: () => _openShelf(cats[i])),
      ),
    ),
  );

  // ---- rails -------------------------------------------------------------------

  Widget _rail({
    required String eyebrow,
    required String title,
    String? lead,
    required List<PvProduct> products,
    required String scope,
  }) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _g),
            child: PvSectionHead(eyebrow: eyebrow, title: title),
          ),
          if (lead != null)
            Padding(
              padding: EdgeInsets.fromLTRB(_g, 6, _g, 0),
              child: Text(
                lead,
                style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
              ),
            ),
          const SizedBox(height: 12),
          PvCardRail(products: products, scope: scope, gutter: _g),
        ],
      ),
    );
  }

  Widget _shelf(V2Palette p, PvCategory c, List<PvProduct> items) {
    if (items.isEmpty) {
      // A feature is never hidden: an empty category is an invitation.
      return Padding(
        padding: EdgeInsets.fromLTRB(_g, 18, _g, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PvSectionHead(title: c.name),
            const SizedBox(height: 8),
            // One quiet line, no slab (2026-09-29). Kept for revert: the
            // same Text inside a PvWell.
            const PvQuietLine(
              'Nothing on this shelf yet. When it fills, it lands here first.',
            ),
          ],
        ),
      );
    }
    final sorted = [...items]
      ..sort((a, b) {
        final ra = a.reco?.band.rank ?? 9;
        final rb = b.reco?.band.rank ?? 9;
        if (ra != rb) return ra.compareTo(rb);
        return b.reviewCount.compareTo(a.reviewCount);
      });
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _g),
            child: PvSectionHead(
              title: c.name,
              // Just "See all" (the user, 2026-09-29): a count beside it grows
              // meaningless as a shelf grows ("See all 1000"). The heading
              // beside it already names the shelf. Kept for revert:
              //   action: 'See all ${items.length}',
              action: 'See all',
              onAction: () => _openShelf(c),
            ),
          ),
          if (c.subs.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(_g, 8, _g, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in c.subs)
                    PvChip(
                      label: s.shortName,
                      selected: false,
                      onTap: () => _openShelf(c, subId: s.id),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          PvCardRail(
            products: sorted.take(6).toList(),
            scope: 'shelf_${c.id}',
            gutter: _g,
          ),
        ],
      ),
    );
  }

  // ---- shop by need (TTC's storefront only) ---------------------------------------
  //
  // ⚠️ ADDED 2026-09-26 FROM THE MOBBIN PRODUCTS BRIEF, AND GATED TO TTC. CVS
  // leads its health aisle with the need ("Feeling queasy?", "Add fiber"),
  // not the product type, and that is how a woman trying to conceive arrives
  // at a shop: she has just read about folic acid, or wants to find her
  // fertile days. Five rows, each to the one product or the one shelf that
  // answers it. Category names stay the index; this is the way in.
  //
  // Gated on the storefront being shown, not on who is looking, so a
  // pregnancy parent who switches to the TTC storefront sees the same shop.
  // Pregnancy and parenting storefronts are untouched.

  static const List<(IconData, String, String, String)> _kTtcNeeds = [
    (
      Icons.eco_outlined,
      'Starting folic acid',
      'The one supplement to begin before you try',
      'product:ttc_folic',
    ),
    (
      Icons.wb_twilight_rounded,
      'Finding your fertile days',
      'Ovulation kits and a thermometer, and when each helps',
      'shelf:ttc_kits',
    ),
    (
      Icons.science_outlined,
      'Taking a pregnancy test',
      'Which test to buy, and how early it can tell',
      'shelf:ttc_tests',
    ),
    (
      Icons.medication_outlined,
      'Supplements, sorted',
      "What's worth taking, and what isn't",
      'shelf:ttc_supplements',
    ),
    (
      Icons.menu_book_outlined,
      'Something for the waiting',
      'Books written for the long weeks',
      'shelf:ttc_books',
    ),
  ];

  /// Each need's drawn mark, by its target (2026-09-29). The icons in
  /// [_kTtcNeeds] stay as data, kept for revert; nothing draws them.
  static const Map<String, PvStoreMark> _kTtcNeedMarks = {
    'product:ttc_folic': PvStoreMark.folicTablet,
    'shelf:ttc_kits': PvStoreMark.fertileCalendar,
    'shelf:ttc_tests': PvStoreMark.pregnancyTest,
    'shelf:ttc_supplements': PvStoreMark.capsules,
    'shelf:ttc_books': PvStoreMark.books,
  };

  /// Whether a need's row leads anywhere (review S3, 2026-09-26). A row
  /// whose product AND fallback shelf are both gone would be a dead row, so
  /// it is not drawn; the check runs at build, against the live catalogue.
  static bool ttcNeedResolves(String target) {
    final store = PvCatalogStore.instance;
    final i = target.indexOf(':');
    final kind = target.substring(0, i);
    final id = target.substring(i + 1);
    if (kind == 'product') {
      return store.byId(id) != null ||
          store.category('ttc_supplements') != null;
    }
    return store.category(id) != null;
  }

  void _openNeed(String target) {
    pvCommitFeedback();
    final store = PvCatalogStore.instance;
    final i = target.indexOf(':');
    final kind = target.substring(0, i);
    final id = target.substring(i + 1);
    if (kind == 'product') {
      final prod = store.byId(id);
      if (prod != null) {
        pvOpenProduct(context, prod);
        return;
      }
      // A product the catalogue no longer carries opens its shelf instead.
      final c = store.category('ttc_supplements');
      if (c != null) _openShelf(c);
      return;
    }
    final c = store.category(id);
    if (c != null) _openShelf(c);
  }

  // ⚠️ UNBOXED (review S1, S2, 2026-09-26). The five rows sat in a white
  // rounded box with its own inset, which DESIGN-SYSTEM §4.13 forbids; they
  // are now the shared `PvRowGroup` + `PvListRow` that Learn and Tools use,
  // pressing like every row. Mobbin: Hers "goals", needs as plain rows
  // (HERS-GOALS, https://mobbin.com/screens/fb081800-9205-4ad5-acd4-b0753e8677e4).
  // Kept for revert: a Container (white, radius 16, kPvLine border) holding
  // InkWell rows split by inset Dividers, each with a 38pt surfaceAlt well.
  Widget _ttcNeeds(V2Palette p) {
    final needs = [
      for (final n in _kTtcNeeds)
        if (ttcNeedResolves(n.$4)) n,
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(_g, 22, _g, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PvSectionHead(
            eyebrow: 'Shop by need',
            title: 'Start from what you need',
          ),
          const SizedBox(height: 8),
          PvRowGroup(p: p, children: [
            for (final n in needs)
              PvListRow(
                key: ValueKey('pv_store_need_${n.$4}'),
                p: p,
                // ⚠️ A DRAWN MARK, NOT A LINE ICON (2026-09-29, the icon
                // rule: rows that take her somewhere wear drawn marks, line
                // icons are for controls). Each need has its own object in
                // the door family's hand, all in the store's one tint
                // (pv_store_marks.dart). Kept for revert: a 40pt surfaceAlt
                // square holding `Icon(n.$1, size: 19, color: p.ink1)`.
                leading: SizedBox(
                  key: ValueKey('pv_store_need_mark_${n.$4}'),
                  width: 44,
                  height: 44,
                  child: PvStoreArt(
                    mark: _kTtcNeedMarks[n.$4] ?? PvStoreMark.capsules,
                    tint: v2BlockTint(kPvStoreMarkHue, p),
                  ),
                ),
                title: n.$2,
                line: n.$3,
                lineMaxLines: 2,
                onTap: () => _openNeed(n.$4),
              ),
          ]),
        ],
      ),
    );
  }

  // ---- the honesty strip ---------------------------------------------------------

  // ⚠️ ON WHITE UNDER A HAIRLINE, NOT IN A SLAB (2026-09-29). It sat in a
  // lavender-grey PvWell with a violet tick; the store's closing words now
  // read like the footnote they are, and the tick is ink. Kept for revert:
  // `child: PvWell(child: Column(...))` and `color: p.action` on the tick.
  Widget _honestyStrip(V2Palette p) => Padding(
    padding: EdgeInsets.fromLTRB(_g, 26, _g, 0),
    child: Container(
      padding: const EdgeInsets.only(top: 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kPvLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, size: 16, color: kPvInk),
              const SizedBox(width: 7),
              Text(
                'How ParentVeda sells',
                style: pvManrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: p.ink1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Some products are ours and ship from us; some are affiliate links '
            'that open the retailer\'s page, and we may earn a small commission. '
            'Every product page says which. "ParentVeda recommends" appears on '
            'a few products only, with the reason and the reviewer\'s name — '
            'and "Generally not needed" is printed just as large. Ratings are '
            'from parents; experts are named. Nothing here is medical advice; '
            'your own doctor\'s word comes first.',
            style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink2),
          ),
        ],
      ),
    ),
  );
}
