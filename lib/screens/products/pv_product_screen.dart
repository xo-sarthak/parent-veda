// =============================================================================
//  PvProductScreen — the product page
// -----------------------------------------------------------------------------
//  The order of blocks is the order the audit found on every page that
//  converts (docs/PRODUCTS-AUDIT.md §4), with our two blocks inserted where
//  they earn their place:
//
//    gallery (swipe · dots · 1/3 · tap to zoom)
//    brand · name · stars · badge
//    price · MRP · % off · where it ships from
//    variants
//    ▶ PARENTVEDA RECOMMENDS — reason, before-you-buy, reviewed by      (ours)
//    what's good · worth considering · best for
//    details ▾ · ingredients ▾ · the research ▾
//    ratings from parents — number, would-buy-again, pros/cons, reviews
//    ▶ WHAT EXPERTS SAY — named, with credentials                       (ours)
//    compare with similar · you might also like
//    sticky bar: Add to cart | Buy now  (or Buy on <retailer> ↗, or nothing)
//
//  ⚠️ THE 2026-09-29 PASS (the one-app pass on the store), checked against
//  Mobbin's shops and pharmacies. What changed, and why:
//    · PACK SIZE NEXT TO THE PRICE. Alan puts "30 lenses · €29 per box" under
//      the name; Thrive Market "12.75 oz bottle · $0.39/oz". Ours is derived
//      (the chosen size, else the spec that names the pack), never stored.
//      https://mobbin.com/screens/378fe975-ed29-4298-b6ed-128cb7e3afa8
//      https://mobbin.com/screens/17688e81-264e-4df3-9aa5-9136dad2013c
//    · SHORT SECTIONS, NOT TWO CRAMPED COLUMNS. Superpower answers "How to
//      take this?" and "Things to know" as a heading and a few lines each;
//      Hims "What it is / What it does". So: Why it helps (the good points),
//      How to use (the specs that say when and how), Worth knowing (the
//      watch-outs), and a Safety note that keeps the clinical copy word for
//      word. At 360dp the old two columns wrapped every line to three words.
//      https://mobbin.com/screens/60e81a73-3dfd-4b4a-8310-e2ddb31cba21
//      https://mobbin.com/screens/195c3c99-f6eb-4ede-8ef5-1b78bbb4e476
//    · ONE INK BUTTON IN THE STICKY BAR. On (price left, one black "Add to
//      bag"), Yami and 1mg: one primary. "Add to bag" + "Buy now" were two
//      pills of equal size in one bar; now the price and one ink "Add to
//      cart", and once it is in her cart the same button says "Go to cart",
//      which is Buy now's path (Nykaa and Blinkit). The store's one name is
//      "cart" (the header's Cart, the cart screen's title).
//      https://mobbin.com/screens/0e97c9e0-6577-4942-b142-8d9f288cf253
//      https://mobbin.com/screens/0e3f3992-52a7-4a77-8ce0-5075d93332b2
//    · RELATED PRODUCTS LAST, the safety note before them.
//    · No violet: the verified tick, "Read reviews" and the eyebrows are ink.
//    · No slab behind text: empty states are one quiet line, studies sit on a
//      white card with a hairline.
//
//  ⚠️ THREE KINDS OF BUY BAR, DECIDED BY THE DATA, NOT THE SCREEN.
//  `soldHere` → cart + checkout here. Affiliate → the retailer's page, after
//  a one-line interstitial that says we may earn a commission (the honesty
//  the user asked for, and the law in several markets). `reviewOnly` → no
//  buy control at all (IMS Act); the bar says "Information only".
// =============================================================================

import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart'; // kept for revert: the buy link now goes through openOutbound

import '../../data/products/pv_affiliate.dart'
    show pvAffiliatePriceNote, pvApiPricedRetailer;
import '../../data/products/pv_product_extras.dart' show kPvIllustrativePhotoIds;
import '../../data/book_companions.dart' show bookReadItem;
import '../../data/products/pv_sheet_products.dart' show sheetBookCompanionFor;
import '../book_companion_screen.dart' show BookCompanionScreen;
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_tool_marks.dart' show TtcMarkLeading;
import 'pv_shortlist_block.dart';
import '../../models/pv_product.dart';
import '../../services/cart_store.dart';
import '../../services/life_stage_store.dart';
import '../../services/pv_catalog_store.dart';
import '../../services/pv_compare_store.dart';
import '../../services/bought_store.dart';
import '../../services/pv_review_store.dart';
import '../../services/pv_list_store.dart';
import 'pv_list_sheet.dart';
import '../../services/saved_store.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pv_cart_screen.dart';
import 'pv_checkout_screen.dart';
import 'pv_compare_screen.dart';
import 'pv_gallery_screen.dart';
import 'pv_review_block.dart';
import 'pv_shelf_screen.dart';
import '../../data/products/pv_coming_soon.dart' show kPvComingSoonLine;
import 'pv_reviews_screen.dart';
import 'pv_store_chrome.dart';
import 'pv_store_marks.dart' show kPvStoreMarkHue;
import '../../brand/outbound.dart' show openOutbound, kPvCommissionLine;

/// The pack size, for the line under the price (2026-09-29). Derived, never
/// stored: the size she picked, else the first size (whose price is shown),
/// else the spec whose name says pack, size,
/// count or contents ("Typical pack · 25 strips"). Null when the product
/// says nothing about it, and then nothing is drawn: no guessed "1 unit".
String? pvPackSize(PvProduct p, [PvVariant? chosen]) {
  if (chosen != null) return chosen.label;
  // The price line shows the first size's price until she picks one, so the
  // pack beside it is that size's (the same rule as `_priceOf`).
  if (p.variants.isNotEmpty) return p.variants.first.label;
  for (final (k, v) in p.specs) {
    final key = k.toLowerCase();
    if (key.contains('pack') ||
        key.contains('size') ||
        key.contains('count') ||
        key.contains('contents')) {
      return v;
    }
  }
  return null;
}

/// The specs that say HOW to use a product: when, how much, how long, how
/// often (2026-09-29, the "How to use" section). The rest of the specs stay
/// under Product details, so nothing is said twice.
List<(String, String)> pvHowToUse(PvProduct p) => [
  for (final (k, v) in p.specs)
    if (_kHowWords.any(k.toLowerCase().startsWith) ||
        k.toLowerCase().contains('dose'))
      (k, v),
];

const List<String> _kHowWords = [
  'when',
  'how',
  'use',
  'take',
  'apply',
  'wash',
  'standard dose',
];

class PvProductScreen extends StatefulWidget {
  const PvProductScreen({super.key, required this.productId, this.heroTag});
  final String productId;

  /// The tapped card's Hero tag, so the first frame flies from it.
  final String? heroTag;

  @override
  State<PvProductScreen> createState() => _PvProductScreenState();
}

class _PvProductScreenState extends State<PvProductScreen>
    with WidgetsBindingObserver {
  final PageController _pages = PageController();
  final ScrollController _scroll = ScrollController();
  bool _pastGallery = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // "Did you buy it?" is asked when she comes BACK from the retailer, so
    // the screen listens for the app returning to the foreground.
    WidgetsBinding.instance.addObserver(this);
    // Other parents' approved reviews of this product (0119).
    PvReviewStore.instance.loadFor(widget.productId);
    _scroll.addListener(() {
      final past =
          _scroll.offset > MediaQuery.of(context).size.width * 1.05 - 120;
      if (past != _pastGallery) setState(() => _pastGallery = past);
    });
  }

  PvVariant? _variant;
  final Set<String> _open = {'details'};

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pages.dispose();
    _scroll.dispose();
    super.dispose();
  }

  PvProduct? get _product => PvCatalogStore.instance.byId(widget.productId);

  int _priceOf(PvProduct p) =>
      _variant?.price ??
      (p.variants.isNotEmpty ? p.variants.first.price : p.price);

  // ---- actions -------------------------------------------------------------------

  Future<bool> _ensureVariant(PvProduct p) async {
    if (p.variants.isEmpty || _variant != null) return true;
    final v = await _pickVariant(p);
    if (v == null) return false;
    setState(() => _variant = v);
    return true;
  }

  Future<PvVariant?> _pickVariant(PvProduct p) {
    final pal = pvStorePalette;
    return showModalBottomSheet<PvVariant>(
      context: context,
      backgroundColor: pal.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a size',
                style: pvFraunces(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: pal.ink1,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in p.variants)
                    PvChip(
                      label: '${v.label} · ₹${PvProduct.groupRupees(v.price)}',
                      selected: false,
                      onTap: () => Navigator.of(context).pop(v),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart(PvProduct p, {bool thenCheckout = false}) async {
    if (!await _ensureVariant(p)) return;
    if (!mounted) return;
    CartStore.instance.add(
      kProductsCartId,
      productId: p.id,
      name: p.name,
      unitPrice: _priceOf(p).toDouble(),
      size: _variant?.label ?? '',
      image: p.images.isNotEmpty ? p.images.first : '',
    );
    if (thenCheckout) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const PvCheckoutScreen(),
          settings: const RouteSettings(name: 'store/checkout'),
        ),
      );
      return;
    }
    // "Cart", the store's one name for it (2026-09-29). Kept for revert:
    // 'Added to your bag', action: 'View bag'.
    pvSnack(
      context,
      'Added to your cart',
      action: 'View cart',
      onAction: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const PvCartScreen(),
          settings: const RouteSettings(name: 'store/cart'),
        ),
      ),
    );
  }

  Future<void> _buyAffiliate(PvProduct p) async {
    final pal = pvStorePalette;
    final go = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: pal.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leaving ParentVeda',
                style: pvFraunces(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: pal.ink1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This opens ${p.retailer.isEmpty ? 'the retailer' : p.retailer}. The price and delivery are theirs, '
                'and we may earn a small commission if you buy — it never changes what we recommend.',
                style: pvManrope(fontSize: 14, height: 1.5, color: pal.ink2),
              ),
              const SizedBox(height: 16),
              PvCommit(
                label:
                    'Continue to ${p.retailer.isEmpty ? 'retailer' : p.retailer}',
                icon: Icons.open_in_new_rounded,
                onTap: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Not now',
                    style: pvManrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: pal.ink2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (go != true || !mounted) return;
    final url = p.buyUrl ?? '';
    // Through the one door out (2026-10-07): it adds the partner tag and the
    // click event, so the commission line under the button is true. Kept for
    // revert: launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).
    final ok = await openOutbound(url, productId: p.id);
    if (!ok && mounted) {
      pvSnack(context, 'Could not open ${p.retailer}. Please try again.');
    }
    // Asked once she is back (didChangeAppLifecycleState), and only if she
    // has not already told us.
    if (ok && !BoughtStore.instance.isBought(p.id)) _awaitingBuy = p.id;
  }

  // ---- "Did you buy it?" and her review (store Track A, 2026-10-28) ---------
  //
  // The launch store is affiliate only, so the purchase happens on Amazon or
  // Flipkart and we never see it. When she comes back we ask, once. A yes
  // marks it bought (BoughtStore: her checklists show it as got) and offers
  // a rating. Her word is all we have, so the review says so: "Bought on
  // Amazon, says the parent", never "Verified purchase".

  /// The product whose retailer page she went to, until we have asked.
  String? _awaitingBuy;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final id = _awaitingBuy;
    _awaitingBuy = null;
    if (id == null || !mounted) return;
    final p = PvCatalogStore.instance.byId(id);
    if (p != null) _askBought(p);
  }

  String _shopOf(PvProduct p) => p.retailer.isNotEmpty
      ? p.retailer.replaceAll('.in', '')
      : (pvApiPricedRetailer(p) ?? 'the retailer');

  Future<void> _askBought(PvProduct p) async {
    final pal = pvStorePalette;
    final shop = _shopOf(p);
    final yes = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: pal.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            key: const ValueKey('pv_product_did_you_buy'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Did you buy it on $shop?',
                style: pvFraunces(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: pal.ink1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If you did, we will mark it as bought in your lists, so you '
                'do not buy it twice. You can rate it for other parents too.',
                style: pvManrope(fontSize: 14, height: 1.5, color: pal.ink2),
              ),
              const SizedBox(height: 16),
              PvCommit(
                label: 'Yes, I bought it',
                onTap: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 8),
              PvSecondary(
                label: 'Not yet',
                onTap: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    if (yes != true || !mounted) return;
    BoughtStore.instance.markBought(p.id);
    await _rate(p);
  }

  /// Stars in one tap, a few words if she wants. Also opened by the "Rate
  /// it" link under Ratings from parents, which is her saying she bought it.
  Future<void> _rate(PvProduct p) async {
    final pal = pvStorePalette;
    final shop = p.soldHere ? '' : _shopOf(p);
    final mine = PvReviewStore.instance.mineFor(p.id);
    var stars = mine?.rating ?? 0;
    final words = TextEditingController(text: mine?.body ?? '');
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: pal.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheet).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Column(
                key: const ValueKey('pv_product_rate_sheet'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mine == null ? 'How was it?' : 'Edit your review',
                    style: pvFraunces(
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      color: pal.ink1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Only rate what you bought and used. Other parents see '
                    'your review once we have checked it.',
                    style: pvManrope(
                      fontSize: 13.5,
                      height: 1.45,
                      color: pal.ink2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          key: ValueKey('pv_rate_star_$i'),
                          tooltip: '$i out of 5',
                          onPressed: () => setSheet(() => stars = i),
                          icon: Icon(
                            i <= stars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 34,
                            color: kPvStar,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: words,
                    maxLines: 4,
                    minLines: 2,
                    maxLength: 2000,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'What should another parent know? (optional)',
                      hintStyle: pvManrope(fontSize: 14, color: pal.ink3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    style: pvManrope(fontSize: 14.5, color: pal.ink1),
                  ),
                  const SizedBox(height: 10),
                  PvCommit(
                    label: stars == 0 ? 'Tap a star to rate' : 'Save review',
                    onTap: stars == 0
                        ? null
                        : () => Navigator.of(sheet).pop(true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final body = words.text;
    // After the sheet's exit animation: its TextField still listens until then.
    Future<void>.delayed(const Duration(milliseconds: 600), words.dispose);
    if (saved != true || !mounted) return;
    BoughtStore.instance.markBought(p.id);
    await PvReviewStore.instance.save(
      productId: p.id,
      rating: stars,
      body: body,
      boughtAt: shop,
    );
    if (!mounted) return;
    pvSnack(
      context,
      'Thank you. You can see your review now; other parents will once it is checked.',
    );
  }

  // ---- build ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final product = _product;
    if (product == null) return _gone(p);
    // A "Coming soon" place-holder (2026-10-28, pv_coming_soon.dart): no
    // price, no buy bar, nothing invented.
    if (product.comingSoon) return _comingSoon(p, product);
    // A shortlisted book that has a full ParentVeda companion opens the
    // companion, not a thin product page (2026-10-13).
    if (sheetBookCompanionFor(product) case final d?) {
      return BookCompanionScreen(item: bookReadItem(d));
    }
    final related = PvCatalogStore.instance.related(product);
    final similar = PvCatalogStore.instance
        .inCategory(product.categoryId)
        .where((o) => o.id != product.id)
        .take(6)
        .toList();
    return Scaffold(
      backgroundColor: p.ground,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(child: _gallery(p, product)),
              SliverToBoxAdapter(child: _title(p, product)),
              SliverToBoxAdapter(child: _price(p, product)),
              // The team's shortlist (2026-10-13): its score, age, skills,
              // buy-by week and what the team looked for — only the sheet's facts.
              if (product.shortlist)
                SliverToBoxAdapter(child: PvShortlistBlock(p: p, product: product)),
              if (product.variants.isNotEmpty)
                SliverToBoxAdapter(child: _variants(p, product)),
              if (product.reco != null)
                SliverToBoxAdapter(child: _recommend(p, product)),
              if (product.evidence != null)
                SliverToBoxAdapter(child: _evidence(p, product)),
              // Kept for revert (2026-09-29): the two-column
              //   SliverToBoxAdapter(child: _goodAndConsider(p, product)),
              if (product.goods.isNotEmpty)
                SliverToBoxAdapter(
                  child: _shortSection(
                    p,
                    'why',
                    'Why it helps',
                    product.goods,
                    Icons.check_rounded,
                  ),
                ),
              if (pvHowToUse(product).isNotEmpty)
                SliverToBoxAdapter(child: _howToUse(p, product)),
              if (product.watchOuts.isNotEmpty)
                SliverToBoxAdapter(
                  child: _shortSection(
                    p,
                    'worth',
                    'Worth knowing',
                    product.watchOuts,
                    Icons.remove_rounded,
                  ),
                ),
              if (product.bestFor.isNotEmpty)
                SliverToBoxAdapter(child: _bestFor(p, product)),
              // Amazon's own "About this item", only from its API (0120),
              // labelled as Amazon's (store Track A, 2026-10-28).
              if (product.extFeatures.isNotEmpty)
                SliverToBoxAdapter(child: _extFeatures(p, product)),
              SliverToBoxAdapter(child: _accordions(p, product)),
              // Listens to the review store so her own review lands the
              // moment she saves it. Kept for revert: child: _ratings(p, product).
              SliverToBoxAdapter(
                child: ListenableBuilder(
                  listenable: PvReviewStore.instance,
                  builder: (_, _) => _ratings(p, product),
                ),
              ),
              if (product.experts.isNotEmpty || product.expertsPct != null)
                SliverToBoxAdapter(child: _experts(p, product)),
              // The safety note before the rails, so related products are
              // last (2026-09-29). Kept for revert: it sat after both rails.
              SliverToBoxAdapter(child: _disclaimer(p)),
              if (similar.isNotEmpty)
                SliverToBoxAdapter(child: _similar(p, product, similar)),
              if (related.isNotEmpty)
                SliverToBoxAdapter(
                  child: _rail(p, 'You might also like', related),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          _topButtons(product),
          // Listens to the cart, so "Add to cart" becomes "Go to cart" the
          // moment it lands (2026-09-29).
          ListenableBuilder(
            listenable: CartStore.instance,
            builder: (context, _) => _stickyBar(p, product),
          ),
        ],
      ),
    );
  }

  /// ⚠️ A GAP, NOT A PRODUCT (2026-10-28, the user: "wherever a product or
  /// category is essential and the sheet does not cover it, have it, but
  /// say Coming soon on it"). The shelf's cover, the plain name, the pill,
  /// what belongs here, and one calm line. No brand, price, rating, review,
  /// spec or buy bar: there is no product behind it yet. The heart stays
  /// (saving it costs nothing), and the shelf it stands on is one tap away.
  Widget _comingSoon(V2Palette p, PvProduct product) {
    final cat = PvCatalogStore.instance.category(product.categoryId);
    return Scaffold(
      backgroundColor: p.ground,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(child: _gallery(p, product)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: pvFraunces(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          height: 1.15,
                          color: p.ink1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const PvComingSoonPill(size: 15),
                      if (product.summary.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          product.summary,
                          style: pvManrope(
                            fontSize: 14.5,
                            height: 1.5,
                            color: p.ink1,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        kPvComingSoonLine,
                        key: const ValueKey('pv_coming_soon_line'),
                        style: pvManrope(
                          fontSize: 14,
                          height: 1.5,
                          color: p.ink2,
                        ),
                      ),
                      if (cat != null) ...[
                        const SizedBox(height: 18),
                        PvSecondary(
                          label: 'See the ${cat.name} shelf',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  PvShelfScreen(categoryId: cat.id),
                              settings: RouteSettings(
                                name: 'store/shelf/${cat.id}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          _topButtons(product),
        ],
      ),
    );
  }

  Widget _gone(V2Palette p) => Scaffold(
    backgroundColor: p.ground,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PvRoundIcon(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 24),
            Text(
              'This product is no longer listed.',
              style: pvFraunces(fontSize: 22, color: p.ink1),
            ),
            const SizedBox(height: 8),
            Text(
              'It may have been withdrawn or renamed. The shelf it was on still is.',
              style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
            ),
          ],
        ),
      ),
    ),
  );

  // ---- gallery -------------------------------------------------------------------

  Widget _gallery(V2Palette p, PvProduct product) {
    final n = product.images.isEmpty ? 1 : product.images.length;
    final side = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(
          width: side,
          height: side * 1.05,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pages,
                itemCount: n,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: product.images.isEmpty
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PvGalleryScreen(
                              product: product,
                              initial: i,
                              frameZeroTag: widget.heroTag,
                            ),
                            settings: const RouteSettings(
                              name: 'store/gallery',
                            ),
                          ),
                        ),
                  child: Hero(
                    tag: i == 0 && widget.heroTag != null
                        ? widget.heroTag!
                        : 'pv_img_${product.id}_$i',
                    child: PvProductImage(
                      product: product,
                      index: i,
                      radius: 0,
                    ),
                  ),
                ),
              ),
              if (n > 1)
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_page + 1}/$n',
                      style: pvManrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (n > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < n; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _page ? Colors.white : Colors.white70,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                ),
              if (product.images.isNotEmpty)
                Positioned(
                  right: 14,
                  top: MediaQuery.of(context).padding.top + 60,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: kPvLine),
                    ),
                    child: Icon(Icons.zoom_in_rounded, size: 18, color: p.ink1),
                  ),
                ),
            ],
          ),
        ),
        if (product.images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              // A generic object standing in for the product says so
              // (2026-09-29, kPvIllustrativePhotoIds). Kept for revert: the
              // one "Representative photo" line for every product.
              child: Text(
                kPvIllustrativePhotoIds.contains(product.id)
                    ? 'Illustrative photo, not this product. The pack you '
                        'receive will look different.'
                    : 'Representative photo — the pack you receive may look different.',
                style: pvManrope(fontSize: 11, color: p.ink3),
              ),
            ),
          ),
      ],
    );
  }

  /// Floating over the gallery; on a white bar once the gallery has scrolled
  /// away, so the buttons never sit on top of the page's own text (found on
  /// the phone: the bag and heart over the size chips).
  Widget _topButtons(PvProduct product) => Positioned(
    left: 0,
    right: 0,
    top: 0,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        10,
      ),
      decoration: BoxDecoration(
        color: _pastGallery ? Colors.white : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: _pastGallery ? kPvLine : Colors.transparent,
          ),
        ),
      ),
      child: Row(
        children: [
          PvRoundIcon(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          ListenableBuilder(
            listenable: CartStore.instance,
            builder: (context, _) => PvRoundIcon(
              icon: Icons.shopping_bag_outlined,
              badge: CartStore.instance.count(kProductsCartId),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PvCartScreen(),
                  settings: const RouteSettings(name: 'store/cart'),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PvHeart(product: product, size: 40),
        ],
      ),
    ),
  );

  // ---- title + price ---------------------------------------------------------------

  Widget _title(V2Palette p, PvProduct product) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Flexible (2026-10-02): a long brand beside the badge ran off a
            // narrow phone at a large text size.
            if (product.brand.isNotEmpty)
              Flexible(
                child: Text(
                  product.brand.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: p.ink3,
                  ),
                ),
              ),
            const Spacer(),
            if (product.badge.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: p.ink1,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  product.badge,
                  style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          product.name,
          style: pvFraunces(
            fontSize: 25,
            fontWeight: FontWeight.w500,
            height: 1.15,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 8),
        // A Wrap (2026-10-02): at a large text size on a narrow phone "Read
        // reviews" moves under the stars instead of running off the edge.
        // Kept for revert: Row.
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          children: [
            PvStars(
              rating: product.rating,
              count: product.reviewCount,
              size: 13.5,
            ),
            if (product.rating > 0 && product.reviews.isNotEmpty) ...[
              const SizedBox(width: 10),
              InkWell(
                onTap: () => _openReviews(product),
                child: Text(
                  'Read reviews',
                  // Ink (2026-09-29). Kept for revert: color: p.action.
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kPvInk,
                  ),
                ),
              ),
            ],
          ],
        ),
        // ⚠️ AMAZON'S RATING, LABELLED AS AMAZON'S (walk 2026-10-20,
        // pv_affiliate.dart). Never folded into the parents' stars above,
        // and the review text stays on Amazon: we link, we never copy.
        if (product.extRating > 0) ...[
          const SizedBox(height: 6),
          Wrap(
            key: const ValueKey('pv_product_ext_rating'),
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 4,
            children: [
              Text(
                '${product.extRating.toStringAsFixed(1)} on Amazon'
                '${product.extReviewCount > 0 ? ' · ${PvProduct.groupRupees(product.extReviewCount)} ratings' : ''}',
                style: pvManrope(fontSize: 13, color: p.ink2),
              ),
              InkWell(
                key: const ValueKey('pv_product_ext_reviews'),
                onTap: () => _buyAffiliate(product),
                child: Text(
                  'Read reviews on Amazon',
                  style: pvManrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kPvInk,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (product.summary.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            product.summary,
            style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink2),
          ),
        ],
      ],
    ),
  );

  Widget _price(V2Palette p, PvProduct product) {
    final ships = product.reviewOnly
        ? 'Information only — no buying here (IMS Act)'
        : product.soldHere
        ? 'Ships from ParentVeda · free delivery over ₹999'
        : 'Sold by ${product.retailer.isEmpty ? 'a partner retailer' : product.retailer} · opens their page';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!product.reviewOnly)
            PvPriceLine(
              product: product,
              size: 24,
              price: product.variants.isNotEmpty ? _priceOf(product) : null,
            ),
          // The pack size beside the price (Alan, Thrive Market), derived.
          if (pvPackSize(product, _variant) case final pack?) ...[
            const SizedBox(height: 4),
            Text(
              pack,
              key: const ValueKey('pv_product_pack'),
              style: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: p.ink2,
              ),
            ),
          ],
          // Whose price this is (walk 2026-10-20). A number read off the exact
          // listing carries its date; otherwise it is our guide price and the
          // retailer's page has today's.
          if (pvAffiliatePriceNote(product) case final note?) ...[
            const SizedBox(height: 4),
            Text(
              note,
              key: const ValueKey('pv_product_price_asof'),
              style: pvManrope(fontSize: 12.5, color: p.ink3),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                product.reviewOnly
                    ? Icons.info_outline_rounded
                    : product.soldHere
                    ? Icons.local_shipping_outlined
                    : Icons.storefront_outlined,
                size: 15,
                color: p.ink3,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ships,
                  style: pvManrope(fontSize: 12.5, color: p.ink3),
                ),
              ),
            ],
          ),
          // Her own named lists, Amazon's "Add to List" (2026-10-28). On
          // every product, so the flow is the same everywhere; says which
          // lists already hold it.
          ListenableBuilder(
            listenable: PvListStore.instance,
            builder: (context, _) {
              final inLists = PvListStore.instance.listsWith(product.id);
              return InkWell(
                key: const ValueKey('pv_product_add_to_list'),
                onTap: () => showPvAddToListSheet(context, product),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        inLists.isEmpty
                            ? Icons.playlist_add_rounded
                            : Icons.playlist_add_check_rounded,
                        size: 18,
                        color: kPvInk,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          inLists.isEmpty
                              ? 'Save to a list'
                              : inLists.length == 1
                              ? 'In your list "${inLists.first.name}" · change'
                              : 'In ${inLists.length} of your lists · change',
                          style: pvManrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: kPvInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _extFeatures(V2Palette p, PvProduct product) => Padding(
    key: const ValueKey('pv_product_ext_features'),
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PvSectionHead(title: 'About this item, from ${product.retailer}'),
        const SizedBox(height: 10),
        for (final f in product.extFeatures)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 10),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.ink3,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    f,
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
                  ),
                ),
              ],
            ),
          ),
        if (product.priceCheckedAt case final at?)
          Text(
            'As listed on ${product.retailer}, ${at.day}/${at.month}/${at.year}',
            style: pvManrope(fontSize: 12, color: p.ink3),
          ),
      ],
    ),
  );

  Widget _variants(V2Palette p, PvProduct product) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SIZE',
          style: pvManrope(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: p.ink3,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in product.variants)
              PvChip(
                label: v.label,
                selected: _variant?.id == v.id,
                onTap: () => setState(() => _variant = v),
              ),
          ],
        ),
      ],
    ),
  );

  // ---- ours: ParentVeda recommends ------------------------------------------------------

  // ⚠️ A SIGNATURE, NOT A BOX — 2026-09-20, the user's call after the walk
  // ("I don't like this purple thing popping up in the centre"). Mobbin:
  // Liven marks an expert review with the expert's avatar, name and
  // credential and a small EXPERT REVIEWED pill; Amazon's Choice and
  // Udemy's Bestseller are tags, not bands. So: a white card with a
  // hairline, the violet eyebrow (the one place the brand colour is
  // allowed), the reason in plain ink, "before you buy" as a quiet second
  // paragraph, and the reviewer AS A PERSON — initials disc, name,
  // credential, the verified mark. It converts because a named clinician
  // vouches, and it follows the base UI. The old tinted well is
  // `_recommendClassic`.
  //
  // The two cautionary bands ("Generally not needed", "Skip") keep the
  // same card; their word replaces the eyebrow and the tone dot stands
  // where the verified mark would — a caution is not a signature.
  Widget _recommend(V2Palette p, PvProduct product) {
    final r = product.reco!;
    final recommends = r.band.recommends;
    final tone = pvToneColor(r.band.tone);
    final who = r.reviewerName.isEmpty
        ? 'The ParentVeda editorial team'
        : r.reviewerName;
    final initials = who
        .replaceAll('Dr. ', '')
        .replaceAll('Dr ', '')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPvLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The eyebrow: the verdict, in the brand's one allowed place.
            Row(
              children: [
                // Ink, not the brand violet (2026-09-29, no purple chrome).
                // Kept for revert: color: p.action.
                // Blue (2026-09-30). Kept for revert: color: kPvInk.
                if (recommends)
                  const Icon(Icons.verified_rounded,
                      size: 15, color: kPvRecommendedBlue)
                else
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tone,
                    ),
                  ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    (recommends ? 'ParentVeda recommends' : r.band.label)
                        .toUpperCase(),
                    style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: recommends ? kPvInk : p.ink2,
                    ),
                  ),
                ),
                if (recommends)
                  Text(
                    r.band.label,
                    style: pvManrope(fontSize: 11.5, color: p.ink3),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // The reason, in plain ink — the sentence that does the work.
            Text(
              r.reason,
              style: pvFraunces(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: p.ink1,
              ),
            ),
            if (r.beforeYouBuy.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                r.beforeYouBuy,
                style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2),
              ),
            ],
            const SizedBox(height: 14),
            Divider(height: 1, thickness: 1, color: kPvLine),
            const SizedBox(height: 12),
            // The signature: a person, not a label.
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.surfaceAlt,
                  ),
                  child: Text(
                    initials,
                    style: pvManrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: p.ink1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              who,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pvManrope(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: p.ink1,
                              ),
                            ),
                          ),
                          if (recommends && r.reviewerName.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: kPvInk,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        r.reviewerRole.isEmpty
                            ? (recommends
                                  ? 'Reviewed this pick'
                                  : 'Reviewed this call')
                            : r.reviewerRole,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(fontSize: 12, color: p.ink2),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'REVIEWED',
                    style: pvManrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: p.ink1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // The pre-2026-09-20 band: a tinted well. Kept for revert; nothing calls it.
  /* Commented out 2026-09-29 (a tinted well is the slab the store no longer draws); kept for revert:
  Widget _recommendClassic(V2Palette p, PvProduct product) {
    final r = product.reco!;
    final tone = pvToneColor(r.band.tone);
    // Off the violet even in the kept body (2026-09-29): a revert must not
    // bring purple chrome back. Was v2BlockTint(268, p) and p.action.
    final tint = r.band.recommends
        ? v2BlockTint(kPvStoreMarkHue, p)
        : HSLColor.fromAHSL(
            1,
            r.band.tone == 2 ? 345 : 40,
            0.32,
            0.93,
          ).toColor();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: PvWell(
        tint: tint,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Blue (2026-09-30). Kept for revert: color: kPvInk.
                if (r.band.recommends)
                  const Icon(Icons.verified_rounded,
                      size: 18, color: kPvRecommendedBlue)
                else
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tone,
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      Text(
                        r.band.recommends
                            ? 'ParentVeda recommends'
                            : r.band.label,
                        style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: p.ink1,
                        ),
                      ),
                      if (r.band.recommends)
                        Text(
                          '· ${r.band.label}',
                          style: pvManrope(fontSize: 12.5, color: p.ink2),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              r.reason,
              style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink1),
            ),
            if (r.beforeYouBuy.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'BEFORE YOU BUY',
                style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                r.beforeYouBuy,
                style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: kPvLine),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: p.ink2,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: pvManrope(fontSize: 12.5, color: p.ink2),
                      children: [
                        const TextSpan(text: 'Reviewed by '),
                        TextSpan(
                          text: r.reviewerName.isEmpty
                              ? 'the ParentVeda editorial team'
                              : r.reviewerName,
                          style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: p.ink1,
                          ),
                        ),
                        if (r.reviewerRole.isNotEmpty)
                          TextSpan(text: ' · ${r.reviewerRole}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  */

  Widget _evidence(V2Palette p, PvProduct product) {
    final e = product.evidence!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Icon(Icons.science_outlined, size: 16, color: p.ink2),
          const SizedBox(width: 7),
          Text(
            e.label,
            style: pvManrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: p.ink1,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(switch (e) {
              PvEvidence.strong =>
                '— good trials, repeated, pointing the same way.',
              PvEvidence.mixed => '— some real evidence, some disagreement.',
              PvEvidence.thin =>
                '— nobody has properly shown it does anything.',
            }, style: pvManrope(fontSize: 12.5, color: p.ink3)),
          ),
        ],
      ),
    );
  }

  // Kept for revert (2026-09-29): the two columns that became "Why it
  // helps" and "Worth knowing". Nothing calls it.
  // ignore: unused_element
  Widget _goodAndConsider(V2Palette p, PvProduct product) {
    if (product.goods.isEmpty && product.watchOuts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _list(
              p,
              'What\'s good',
              Icons.check_rounded,
              pvToneColor(0),
              product.goods,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _list(
              p,
              'Worth considering',
              Icons.remove_rounded,
              pvToneColor(1),
              product.watchOuts,
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(
    V2Palette p,
    String title,
    IconData icon,
    Color c,
    List<String> items,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: pvManrope(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: p.ink1,
        ),
      ),
      const SizedBox(height: 6),
      if (items.isEmpty)
        Text(
          'Nothing noted yet.',
          style: pvManrope(fontSize: 12.5, color: p.ink3),
        )
      else
        for (final t in items.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 14, color: c),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t,
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.4,
                      color: p.ink2,
                    ),
                  ),
                ),
              ],
            ),
          ),
    ],
  );

  Widget _bestFor(V2Palette p, PvProduct product) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Best for',
            style: pvManrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: p.ink3,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final b in product.bestFor.take(5))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    b,
                    style: pvManrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: p.ink1,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  // ---- accordions ---------------------------------------------------------------------

  Widget _accordions(V2Palette p, PvProduct product) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
    child: Column(
      children: [
        _acc(p, 'details', 'Product details', _details(p, product)),
        if (product.ingredients.isNotEmpty)
          _acc(p, 'inside', 'What\'s inside', _ingredients(p, product)),
        if (product.studies.isNotEmpty)
          _acc(p, 'research', 'The research', _studies(p, product)),
        if (product.soldHere)
          _acc(p, 'delivery', 'Delivery and returns', _delivery(p)),
      ],
    ),
  );

  Widget _acc(V2Palette p, String key, String title, Widget body) {
    final open = _open.contains(key);
    return Column(
      children: [
        InkWell(
          onTap: () =>
              setState(() => open ? _open.remove(key) : _open.add(key)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: kPvLine)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: pvManrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: p.ink1,
                    ),
                  ),
                ),
                Icon(
                  open ? Icons.remove_rounded : Icons.add_rounded,
                  size: 20,
                  color: p.ink2,
                ),
              ],
            ),
          ),
        ),
        if (open)
          Padding(padding: const EdgeInsets.only(bottom: 16), child: body),
      ],
    );
  }

  // The specs "How to use" already shows are left out here (2026-09-29),
  // so one fact is said once. Kept for revert: `for (final (k, v) in
  // product.specs)`.
  Widget _details(V2Palette p, PvProduct product) {
    final how = pvHowToUse(product);
    final specs = [
      for (final s in product.specs)
        if (!how.contains(s)) s,
    ];
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (product.summary.isNotEmpty)
        Text(
          product.summary,
          style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
        ),
      if (specs.isNotEmpty) ...[
        const SizedBox(height: 10),
        for (final (k, v) in specs)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(k, style: pvManrope(fontSize: 13, color: p.ink3)),
                ),
                Expanded(
                  child: Text(
                    v,
                    style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.ink1,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
      if (product.summary.isEmpty && specs.isEmpty)
        Text(
          'Details are being written for this product.',
          style: pvManrope(fontSize: 13.5, color: p.ink3),
        ),
    ],
  );
  }

  Widget _ingredients(V2Palette p, PvProduct product) => Column(
    children: [
      for (final i in product.ingredients)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    i.name,
                    style: pvManrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      i.purpose,
                      style: pvManrope(fontSize: 12.5, color: p.ink3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                i.note,
                style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
              ),
              if (i.caution.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    'Caution: ${i.caution}',
                    style: pvManrope(
                      fontSize: 12.5,
                      height: 1.4,
                      color: pvToneColor(1),
                    ),
                  ),
                ),
            ],
          ),
        ),
    ],
  );

  Widget _studies(V2Palette p, PvProduct product) => Column(
    children: [
      for (final s in product.studies)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          // A white card, not a slab (2026-09-29). Kept for revert: PvWell.
          child: PvCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.topic,
                  style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  s.summary,
                  style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
                ),
                const SizedBox(height: 6),
                Text(
                  'What it means: ${s.meaning}',
                  style: pvManrope(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: p.ink1,
                  ),
                ),
                if (s.source.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${s.source}${s.byMaker ? ' · published by the maker' : ''}',
                    style: pvManrope(fontSize: 11.5, color: p.ink3),
                  ),
                ],
              ],
            ),
          ),
        ),
    ],
  );

  Widget _delivery(V2Palette p) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _row(
        p,
        Icons.local_shipping_outlined,
        'Delivered in 3–6 days across India. Free over ₹999, otherwise ₹49.',
      ),
      _row(
        p,
        Icons.replay_rounded,
        'Unopened items can be returned within 7 days.',
      ),
      _row(
        p,
        Icons.lock_outline_rounded,
        'Paid through Razorpay — UPI, cards, net banking. We never see your card.',
      ),
    ],
  );

  Widget _row(V2Palette p, IconData i, String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(i, size: 16, color: p.ink2),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            t,
            style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2),
          ),
        ),
      ],
    ),
  );

  // ---- ratings from parents -------------------------------------------------------------

  void _openReviews(PvProduct product) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PvReviewsScreen(product: product),
      settings: const RouteSettings(name: 'store/reviews'),
    ),
  );

  Widget _ratings(V2Palette p, PvProduct product) {
    // Parents' own reviews from the app (0119): hers whatever its status,
    // other parents' once approved. Kept for revert: the line without
    // `live`, `has` from the seed alone.
    final live = PvReviewStore.instance.shownFor(product.id);
    final mine = PvReviewStore.instance.mineFor(product.id);
    final has =
        product.rating > 0 || product.reviews.isNotEmpty || live.isNotEmpty;
    // The headline when the seed has no number: the plain mean of the
    // reviews held, labelled with how few there are, never a measured-looking
    // figure on its own.
    final liveMean = live.isEmpty
        ? 0.0
        : live.map((r) => r.rating).reduce((a, b) => a + b) / live.length;
    final headline = product.rating > 0 ? product.rating : liveMean;
    final countLine = product.reviewCount > 0
        ? '${product.reviewCount} ratings'
        : live.isNotEmpty
        ? '${live.length} ${live.length == 1 ? 'parent' : 'parents'} on ParentVeda'
        : '${product.reviews.length} reviews';
    // Rate it: an affiliate item she can buy elsewhere. A sold-here item
    // waits for a delivered order (Track B), so it gets no link yet.
    final canRate = product.canBuy && !product.soldHere;
    // ⚠️ THE PADDING MOVED INSIDE. This section used to wrap everything in
    // one 20pt gutter, which was right while it held only text and boxes and
    // wrong the moment it grew a rail: a horizontal list inside a gutter
    // stops 20pt short of the screen on both sides and reads as walled in.
    // Everything but the rail is padded by hand; the rail pads itself.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PvSectionHead(
                title: 'Ratings from parents',
                // Kept for revert (2026-09-28): 'See all'. The link says
                // how many ratings it opens.
                action: product.reviews.length > 2
                    ? 'See all ${product.reviews.length} ratings'
                    : null,
                onAction: () => _openReviews(product),
              ),
              const SizedBox(height: 12),
              // One quiet line, no slab (2026-09-29). Kept for revert: the
              // same words inside a PvWell.
              if (!has)
                const PvQuietLine(
                  'No parent ratings yet. When parents on ParentVeda rate this, the number, the reasons and their words land here — never a figure we made up.',
                )
              else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (headline > 0)
                      Text(
                        headline.toStringAsFixed(1),
                        style: pvFraunces(
                          fontSize: 44,
                          fontWeight: FontWeight.w500,
                          height: 1,
                          color: p.ink1,
                        ),
                      ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (headline > 0)
                          Row(
                            children: [
                              for (var i = 1; i <= 5; i++)
                                Icon(
                                  i <= headline.round()
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 18,
                                  color: kPvStar,
                                ),
                            ],
                          ),
                        // Kept for revert: the two-way count without
                        // the app's own reviews.
                        Text(
                          countLine,
                          style: pvManrope(fontSize: 12.5, color: p.ink3),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (product.parentsPct != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${product.parentsPct}%',
                            style: pvFraunces(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              height: 1,
                              color: p.ink1,
                            ),
                          ),
                          Text(
                            'would buy again',
                            style: pvManrope(fontSize: 11.5, color: p.ink3),
                          ),
                        ],
                      ),
                  ],
                ),
                // Best Buy's pros/cons chips are aggregated review TAGS with counts;
                // ours would only repeat the two lists above, truncated. Dropped
                // on the phone walk. Kept for revert: _prosCon(...).
              ],
              if (canRate) ...[
                const SizedBox(height: 12),
                InkWell(
                  key: const ValueKey('pv_product_rate_link'),
                  onTap: () => _rate(product),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      mine == null
                          ? 'Bought this? Rate it for other parents'
                          : 'Edit your review',
                      style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: kPvInk,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // The words, on the rail every other review section in the app now
        // uses. Kept for revert, the stack this replaced:
        //   for (final r in product.reviews.take(2)) PvReviewCard(review: r),
        if (has && (product.reviews.isNotEmpty || live.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 14),
            // The store's one hue, not the violet (2026-09-29). Kept for
            // revert: hue: 268.
            child: PvReviewRail(
              hue: kPvStoreMarkHue,
              voices: [
                // The app's own first: hers, then approved ones (0119).
                for (final r in live)
                  PvReviewVoice(
                    name: r.id == mine?.id
                        ? 'You'
                        : (r.authorLabel.isEmpty
                              ? 'A ParentVeda parent'
                              : r.authorLabel),
                    context: r.id == mine?.id && !r.approved
                        ? '${pvReviewSourceLine(r)} · only you see this until it is checked'
                        : pvReviewSourceLine(r),
                    quote: r.body.isEmpty
                        ? 'Rated it ${r.rating} out of 5.'
                        : r.body,
                    stars: r.rating,
                  ),
                for (final r in product.reviews.take(6))
                  PvReviewVoice(
                    name: r.author,
                    context: r.context,
                    quote: r.text,
                    stars: r.stars,
                    note: r.watchOut,
                    endorsed: r.wouldBuyAgain,
                    endorsedLabel: 'Would buy again',
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /* kept for revert — the pros/cons chips dropped on the phone walk
  Widget _prosCon(V2Palette p, String t, bool pro) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: kPvLine),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          pro ? Icons.thumb_up_alt_outlined : Icons.thumb_down_alt_outlined,
          size: 13,
          color: pro ? pvToneColor(0) : pvToneColor(1),
        ),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            t,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: pvManrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: p.ink1,
            ),
          ),
        ),
      ],
    ),
  );
  */

  // ---- ours: what experts say -----------------------------------------------------------

  Widget _experts(V2Palette p, PvProduct product) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PvSectionHead(
          eyebrow: 'What experts say',
          title: 'Named, with their credentials',
        ),
        const SizedBox(height: 12),
        if (product.expertsPct != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  '${product.expertsPct}%',
                  style: pvFraunces(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'of the experts we asked would buy this for their own family',
                    style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2),
                  ),
                ),
              ],
            ),
          ),
        for (final x in product.experts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kPvLine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // A person wears initials, never a stock figure, and no
                      // violet (2026-09-29). Kept for revert: a v2BlockTint(268)
                      // disc holding Icons.person_rounded.
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: p.surfaceAlt,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _initials(x.name),
                          style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: p.ink1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  x.name,
                                  style: pvManrope(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: p.ink1,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 14,
                                  color: kPvInk,
                                ),
                              ],
                            ),
                            Text(
                              x.role,
                              style: pvManrope(fontSize: 12, color: p.ink3),
                            ),
                          ],
                        ),
                      ),
                      if (x.videoId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: kPvLine),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                size: 14,
                                color: p.ink1,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                x.duration.isEmpty ? 'Watch' : x.duration,
                                style: pvManrope(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: p.ink1,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '“${x.quote}”',
                    style: pvManrope(
                      fontSize: 14,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      color: p.ink1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (product.experts.isEmpty)
          const PvQuietLine(
            'An expert video for this product is being recorded.',
          ),
      ],
    ),
  );

  // ---- compare + rails ------------------------------------------------------------------

  Widget _similar(V2Palette p, PvProduct product, List<PvProduct> similar) =>
      Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListenableBuilder(
                listenable: PvCompareStore.instance,
                builder: (context, _) {
                  final tray = PvCompareStore.instance;
                  return Row(
                    children: [
                      const Expanded(
                        child: PvSectionHead(title: 'Compare with similar'),
                      ),
                      PvChip(
                        label: tray.contains(product.id)
                            ? 'In compare'
                            // Kept for revert (2026-09-28): 'Add this'.
                            : 'Add to compare',
                        leading: Icons.compare_arrows_rounded,
                        selected: tray.contains(product.id),
                        onTap: () {
                          final r = tray.toggle(product);
                          if (r == PvCompareResult.wrongCategory) {
                            pvSnack(context, 'Compare within one category.');
                          }
                        },
                      ),
                      if (tray.items.length == 2) ...[
                        const SizedBox(width: 6),
                        PvChip(
                          label: 'Compare',
                          selected: true,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PvCompareScreen(),
                              settings: const RouteSettings(
                                name: 'store/compare',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            PvCardRail(products: similar, compare: true, scope: 'similar'),
          ],
        ),
      );

  Widget _rail(V2Palette p, String title, List<PvProduct> items) => Padding(
    padding: const EdgeInsets.only(top: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PvSectionHead(title: title),
        ),
        const SizedBox(height: 12),
        PvCardRail(products: items, scope: 'related'),
      ],
    ),
  );

  // ⚠️ A SAFETY NOTE WITH A NAME (2026-09-29). The same words as before,
  // never a diagnosis and never against her doctor, now under their own
  // heading beside an (i), so she finds them rather than scrolling past
  // 11.5pt grey. Kept for revert: the bare Text at fontSize 11.5, ink3.
  Widget _disclaimer(V2Palette p) => Padding(
    key: const ValueKey('pv_product_safety'),
    padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 17, color: p.ink1),
            const SizedBox(width: 8),
            Text(
              'Safety note',
              style: pvManrope(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: p.ink1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'ParentVeda\'s recommendations are general guidance, not medical advice. If your doctor has told you something different, your doctor is right.',
          style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2),
        ),
      ],
    ),
  );

  static String _initials(String name) {
    final parts = name
        .replaceAll('Dr. ', '')
        .replaceAll('Dr ', '')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((w) => w[0].toUpperCase()).join();
  }

  // ---- short sections (2026-09-29) --------------------------------------------------

  /// A heading and a few short lines, each with an ink mark. Superpower's
  /// "Things to know": no box, no second column.
  Widget _shortSection(
    V2Palette p,
    String key,
    String title,
    List<String> items,
    IconData mark,
  ) => Padding(
    key: ValueKey('pv_product_section_$key'),
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: pvFraunces(
            fontSize: 19,
            fontWeight: FontWeight.w500,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 8),
        for (final t in items.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(mark, size: 16, color: p.ink1),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t,
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
      ],
    ),
  );

  /// How to use: the specs that say when, how much and how long, as label
  /// and value (the stats rule: a plain label and the value, on white).
  Widget _howToUse(V2Palette p, PvProduct product) => Padding(
    key: const ValueKey('pv_product_section_how'),
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to use',
          style: pvFraunces(
            fontSize: 19,
            fontWeight: FontWeight.w500,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 6),
        for (final (k, v) in pvHowToUse(product))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k, style: pvManrope(fontSize: 12.5, color: p.ink3)),
                const SizedBox(height: 1),
                Text(
                  v,
                  style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: p.ink1,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  // ---- sticky bar ---------------------------------------------------------------------

  Widget _stickyBar(V2Palette p, PvProduct product) {
    Widget body;
    if (product.reviewOnly) {
      body = Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: p.ink2),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Information only. India\'s IMS Act does not allow us to sell or link this — the honest facts above are why you came.',
              style: pvManrope(fontSize: 12, height: 1.4, color: p.ink2),
            ),
          ),
        ],
      );
    } else if (product.shortlist && !product.soldHere && (product.buyUrl ?? '').isEmpty) {
      // ⚠️ A FOURTH BAR, DECIDED BY THE DATA (2026-10-13). A shortlisted pick
      // with no price or link yet: say so plainly instead of a button that
      // goes nowhere (the affiliate branch below would open an empty URL).
      body = Row(
        key: const ValueKey('pv_shortlist_bar'),
        children: [
          TtcMarkLeading(tab: TtcTabMark.checklist, tint: p.ink2, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "On ParentVeda's shortlist. Price and where to buy are being added.",
              style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2),
            ),
          ),
        ],
      );
    } else if (product.soldHere) {
      // ⚠️ ONE INK BUTTON (2026-09-29). The price, then one primary: "Add to
      // cart", or "Go to cart" once this product (in the chosen size) is in
      // it, which is where "Buy now" used to take her. Kept for revert, the
      // two equal pills after the price column:
      //   Expanded(child: PvSecondary(label: 'Add to bag',
      //       onTap: () => _addToCart(product))),
      //   const SizedBox(width: 8),
      //   Expanded(child: PvCommit(label: 'Buy now',
      //       onTap: () => _addToCart(product, thenCheckout: true))),
      final inCart = CartStore.instance
          .items(kProductsCartId)
          .any(
            (i) =>
                i.productId == product.id &&
                (product.variants.isEmpty || i.size == _variant?.label),
          );
      // The price, then the two buttons. At a large text size on a narrow
      // phone the three do not fit one line, so the price goes above them.
      final priceCol = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹${PvProduct.groupRupees(_priceOf(product))}',
                style: pvManrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: p.ink1,
                ),
              ),
              Text(
                _variant?.label ??
                    (product.variants.isNotEmpty
                        ? 'choose a size'
                        : 'incl. taxes'),
                style: pvManrope(fontSize: 11, color: p.ink3),
              ),
            ],
          );
      final buttonRow = Row(children: [
          // ⚠️ BUY NOW IS BACK (2026-10-02, the user: "don't remove the Buy now
          // button from the product page, I can only see Add to cart"). Two
          // buttons again: Add to cart (Go to cart once it is in) as the outlined
          // one, Buy now as the one ink, which adds it and goes straight to
          // checkout. Kept for revert (2026-09-29): Add to cart alone as the ink.
          Expanded(
            child: PvSecondary(
              key: const ValueKey('pv_product_primary'),
              label: inCart ? 'Go to cart' : 'Add to cart',
              onTap: inCart
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PvCartScreen(),
                        settings: const RouteSettings(name: 'store/cart'),
                      ),
                    )
                  : () => _addToCart(product),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PvCommit(
              key: const ValueKey('pv_product_buy_now'),
              label: 'Buy now',
              onTap: () => _addToCart(product, thenCheckout: true),
            ),
          ),
      ]);
      body = MediaQuery.textScalerOf(context).scale(10) > 12.5
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [priceCol, const SizedBox(height: 10), buttonRow],
            )
          : Row(children: [
              priceCol,
              const SizedBox(width: 12),
              Expanded(child: buttonRow),
            ]);
    } else if (product.canBuy) {
      body = Row(
        children: [
          if (product.hasPrice) ...[
            Text(
              product.priceLabel,
              style: pvManrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: p.ink1,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              PvCommit(
                key: const ValueKey('pv_product_primary'),
                label:
                    'Buy on ${product.retailer.isEmpty ? 'retailer' : product.retailer}',
                icon: Icons.open_in_new_rounded,
                onTap: () => _buyAffiliate(product),
              ),
              const SizedBox(height: 6),
              Text(kPvCommissionLine,
                  key: const ValueKey('pv_product_commission'),
                  textAlign: TextAlign.center,
                  style: pvManrope(fontSize: 11, height: 1.4, color: p.ink3)),
            ]),
          ),
        ],
      );
    } else {
      body = Row(
        children: [
          Expanded(
            child: Text(
              product.priceNote.isEmpty
                  ? 'Available at pharmacies and online.'
                  : product.priceNote,
              style: pvManrope(fontSize: 13, color: p.ink2),
            ),
          ),
          const SizedBox(width: 12),
          // ⚠️ IT SAVES NOW (2026-09-29): this "Save" had `onTap: () {}`, a
          // button that did nothing. It is the heart's own toggle, through
          // SavedStore, and says Saved once it is. Kept for revert: the same
          // PvSecondary with an empty onTap.
          ListenableBuilder(
            listenable: SavedStore.instance,
            builder: (context, _) {
              final saved = SavedStore.instance.isSaved(
                SavedKind.product,
                product.id,
              );
              return PvSecondary(
                key: const ValueKey('pv_product_save'),
                label: saved ? 'Saved' : 'Save',
                icon: saved
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                onTap: () => SavedStore.instance.toggle(
                  SavedKind.product,
                  product.id,
                  title: product.name,
                  subtitle: product.brand,
                  stage: product.stage.id,
                ),
              );
            },
          ),
        ],
      );
    }
    // MOTION: the commit bar rises into place a beat after the page lands
    // (Sephora's basket bar), so the eye reads the product first, the ask
    // second.
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: 0),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) =>
            FractionalTranslation(translation: Offset(0, t), child: child),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: kPvLine)),
          ),
          child: body,
        ),
      ),
    );
  }
}

/// One parent's review — used on the page and on the all-reviews screen.
class PvReviewCard extends StatelessWidget {
  const PvReviewCard({super.key, required this.review});
  final PvParentReview review;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPvLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  Icon(
                    i <= review.stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 15,
                    color: kPvStar,
                  ),
                const SizedBox(width: 8),
                if (review.wouldBuyAgain)
                  Row(
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: pvToneColor(0),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Would buy again',
                        style: pvManrope(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: pvToneColor(0),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.text,
              style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1),
            ),
            if (review.watchOut.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Watch out: ${review.watchOut}',
                style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${review.author} · ${review.context}',
              style: pvManrope(fontSize: 12, color: p.ink3),
            ),
          ],
        ),
      ),
    );
  }
}
