// =============================================================================
//  ParentVeda Products ❤️ (Tools card) - a trust-first decision engine
// -----------------------------------------------------------------------------
//  Recommended (stage-aware) / Browse all / Saved. Each category leads with a
//  20-second guidance card, then ParentVeda Picks (scored, trust visible on the
//  card), then browse. Product detail adds the verdict, week-relevance timeline,
//  review summary and structured parent reviews. Buy Now is future affiliate.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/product_data.dart';
import '../localization/app_language.dart';
import '../models/product_models.dart';
import '../services/pregnancy_controller.dart';
import '../services/product_store.dart';
import '../services/cart_store.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'product_guide/product_guide_chooser.dart';
import 'product_guide/product_guide_data.dart';
import 'tools/product_checklist_screen.dart';

const Color _score = Color(0xFFE6A817); // warm gold for the score
const Color _accent = AppTheme.primary500;

void _push(BuildContext c, Widget w) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

({String emoji, Color color, String key}) _badgeVisual(ProductBadge b) {
  switch (b) {
    case ProductBadge.bestOverall:
      return (emoji: '🏆', color: const Color(0xFFE6A817), key: 'bestOverall');
    case ProductBadge.bestBudget:
      return (emoji: '💰', color: const Color(0xFF3FA56A), key: 'bestBudget');
    case ProductBadge.bestPremium:
      return (emoji: '✨', color: const Color(0xFF7A4FC2), key: 'bestPremium');
    case ProductBadge.sensitiveSkin:
      return (emoji: '🌿', color: const Color(0xFF6E8C74), key: 'sensitiveSkin');
    case ProductBadge.newborns:
      return (emoji: '👶', color: const Color(0xFFEF6F8E), key: 'newborns');
    case ProductBadge.none:
      return (emoji: '', color: AppTheme.neutral500, key: '');
  }
}

// ===========================================================================
//  Home - 3 tabs
// ===========================================================================

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.scaffoldBackground,
          elevation: 0,
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(s.prTitle), const Text(' ❤️'),
          ]),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => showSearch<void>(
                  context: context,
                  delegate: _ProductSearchDelegate(controller)),
            ),
            cartIconButton(context, controller,
                cartId: kProductsCartId, title: s.cartProductsTitle),
          ],
          bottom: TabBar(
            labelColor: _accent,
            unselectedLabelColor: AppTheme.neutral500,
            indicatorColor: _accent,
            tabs: [
              Tab(text: s.prTabRecommended),
              Tab(text: s.prTabBrowse),
              Tab(text: s.prTabSaved),
            ],
          ),
        ),
        body: TabBarView(children: [
          _RecommendedTab(controller: controller),
          _BrowseTab(controller: controller),
          _SavedTab(controller: controller),
        ]),
      ),
    );
  }
}

class _RecommendedTab extends StatelessWidget {
  const _RecommendedTab({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final week = controller.currentWeek;
    var cats = recommendedCategories(week);
    if (cats.isEmpty) cats = kProductCategories;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text(s.prRecommendedFor(week),
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(s.prRecommendedSub,
            style: text.bodyMedium?.copyWith(color: AppTheme.neutral600, height: 1.4)),
        const SizedBox(height: 16),
        for (final c in cats) ...[
          _CategoryCard(category: c, controller: controller, relevant: true),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// A category entry - emoji + name + a guidance preview, opening the category
/// page (with the full ParentVeda guidance). Shared by Recommended + Browse.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.controller,
    this.relevant = false,
  });
  final ProductCategory category;
  final PregnancyController controller;
  final bool relevant;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => _push(context, ProductCategoryScreen(category: category, controller: controller)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(category.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(category.name,
                      style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                ),
                if (relevant) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3FA56A).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(s.prRelevantNow,
                        style: text.labelSmall?.copyWith(
                            color: const Color(0xFF2E7D4F), fontWeight: FontWeight.w800)),
                  ),
                ],
              ]),
              const SizedBox(height: 4),
              Text(category.guidance,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: AppTheme.neutral600, height: 1.35)),
              const SizedBox(height: 8),
              Row(children: [
                Text(s.prPicks,
                    style: text.labelMedium?.copyWith(color: _accent, fontWeight: FontWeight.w800)),
                const Icon(Icons.arrow_forward_rounded, size: 15, color: _accent),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _BrowseTab extends StatelessWidget {
  const _BrowseTab({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      itemCount: kProductCategories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) =>
          _CategoryCard(category: kProductCategories[i], controller: controller),
    );
  }
}

class _SavedTab extends StatelessWidget {
  const _SavedTab({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: ProductStore.instance,
      builder: (context, _) {
        final saved = ProductStore.instance.savedIds
            .map(productById)
            .whereType<Product>()
            .toList();
        if (saved.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.favorite_border_rounded, size: 44, color: AppTheme.neutral400),
                const SizedBox(height: 14),
                Text(s.prSavedEmpty,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: AppTheme.neutral500)),
              ]),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [for (final p in saved) _ProductCard(product: p, controller: controller)],
        );
      },
    );
  }
}

// ===========================================================================
//  Product card (trust visible on the card)
// ===========================================================================

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.controller});
  final Product product;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final bv = _badgeVisual(product.badge);
    return GestureDetector(
      onTap: () => _push(context, ProductDetailScreen(product: product, controller: controller)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (product.badge != ProductBadge.none)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bv.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${bv.emoji} ${s.prBadge(bv.key)}',
                    style: text.labelSmall?.copyWith(color: bv.color, fontWeight: FontWeight.w800)),
              ),
            if (productIsAffiliate(product)) ...[
              if (product.badge != ProductBadge.none) const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9900).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.open_in_new_rounded,
                      size: 11, color: Color(0xFFB36B00)),
                  const SizedBox(width: 4),
                  Text(s.prAffiliate,
                      style: text.labelSmall?.copyWith(
                          color: const Color(0xFFB36B00),
                          fontWeight: FontWeight.w800)),
                ]),
              ),
            ],
            const Spacer(),
            _SaveHeart(id: product.id),
          ]),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(product.emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name,
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(product.summary,
                    style: text.bodyMedium?.copyWith(color: AppTheme.neutral600, height: 1.35)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _scorePill(product.score),
            const SizedBox(width: 10),
            Expanded(
              child: Text('${s.prBestFor}: ${product.bestFor}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelMedium?.copyWith(color: AppTheme.neutral600)),
            ),
          ]),
          const SizedBox(height: 12),
          // Trust on the card - always with its heading.
          if (product.why.isNotEmpty) ...[
            _trustHeading(context, s.prWhy),
            const SizedBox(height: 6),
            for (final w in product.why) _whyRow(context, w),
          ],
          if (product.consider.isNotEmpty) ...[
            const SizedBox(height: 10),
            _trustHeading(context, s.prConsider),
            const SizedBox(height: 6),
            for (final c in product.consider) _considerRow(context, c),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Text(product.price,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: productIsAffiliate(product)
                    ? const Color(0xFFFF9900)
                    : _accent,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              ),
              onPressed: () {
                if (productIsAffiliate(product)) {
                  launchUrl(Uri.parse(amazonSearchUrl(product)),
                      mode: LaunchMode.externalApplication);
                } else {
                  showSingleItemBuyNow(context, controller, product);
                }
              },
              child: Text(
                  productIsAffiliate(product) ? s.prBuyOnAmazon : s.prBuyNow,
                  style: text.labelLarge?.copyWith(color: Colors.white)),
            ),
          ]),
        ]),
      ),
    );
  }
}

Widget _scorePill(double score) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _score.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.star_rounded, size: 15, color: _score),
        const SizedBox(width: 4),
        Text('${score.toStringAsFixed(1)}/10',
            style: const TextStyle(
                color: Color(0xFF9A7A14), fontWeight: FontWeight.w800, fontSize: 12)),
      ]),
    );

Widget _trustHeading(BuildContext context, String label) => Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.neutral500, fontWeight: FontWeight.w800, letterSpacing: 0.2),
    );

Widget _whyRow(BuildContext context, String t) {
  final text = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.check_rounded, size: 16, color: Color(0xFF3FA56A)),
      const SizedBox(width: 8),
      Expanded(child: Text(t, style: text.bodySmall?.copyWith(height: 1.35))),
    ]),
  );
}

Widget _considerRow(BuildContext context, String t) {
  final text = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        margin: const EdgeInsets.only(top: 5),
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: Color(0xFFD64545), shape: BoxShape.circle),
      ),
      const SizedBox(width: 9),
      Expanded(
          child: Text(t,
              style: text.bodySmall?.copyWith(color: AppTheme.neutral600, height: 1.35))),
    ]),
  );
}

class _SaveHeart extends StatelessWidget {
  const _SaveHeart({required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ProductStore.instance,
      builder: (context, _) {
        final saved = ProductStore.instance.isSaved(id);
        return InkResponse(
          radius: 22,
          onTap: () => ProductStore.instance.toggleSave(id),
          child: Icon(saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: saved ? const Color(0xFFEF6F8E) : AppTheme.neutral400, size: 22),
        );
      },
    );
  }
}

// ===========================================================================
//  Guidance card + week timeline
// ===========================================================================

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.category, required this.lang});
  final ProductCategory category;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accent.withValues(alpha: 0.10), AppTheme.surface],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _accent.withValues(alpha: 0.18)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('${s.prGuidance} ', style: text.titleSmall?.copyWith(
              color: _accent, fontWeight: FontWeight.w800)),
          const Text('❤️', style: TextStyle(fontSize: 14)),
        ]),
        const SizedBox(height: 8),
        Text(category.guidance, style: text.bodyLarge?.copyWith(height: 1.45)),
        const SizedBox(height: 14),
        Text(s.prLookFor.toUpperCase(),
            style: text.labelSmall?.copyWith(
                color: AppTheme.neutral500, letterSpacing: 0.6, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        for (final l in category.lookFor)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check_rounded, size: 16, color: Color(0xFF3FA56A)),
              const SizedBox(width: 8),
              Expanded(child: Text(l, style: text.bodyMedium)),
            ]),
          ),
        const SizedBox(height: 10),
        Text(s.prAvoid.toUpperCase(),
            style: text.labelSmall?.copyWith(
                color: AppTheme.neutral500, letterSpacing: 0.6, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        for (final a in category.avoid)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.close_rounded, size: 16, color: Color(0xFFD64545)),
              const SizedBox(width: 8),
              Expanded(child: Text(a, style: text.bodyMedium)),
            ]),
          ),
      ]),
    );
  }
}

class _WeekTimeline extends StatelessWidget {
  const _WeekTimeline({
    required this.fromWeek,
    required this.toWeek,
    required this.toLabel,
    required this.currentWeek,
    required this.lang,
  });
  final int fromWeek;
  final int toWeek;
  final String toLabel;
  final int currentWeek;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final inWindow = currentWeek >= fromWeek && currentWeek <= toWeek;
    final laterFrom = fromWeek > currentWeek; // product becomes useful later
    final axisStart = laterFrom ? currentWeek : fromWeek;
    final span = (toWeek - axisStart) <= 0 ? 1 : (toWeek - axisStart);
    final youFrac = ((currentWeek - axisStart) / span).clamp(0.0, 1.0);
    final fromFrac = ((fromWeek - axisStart) / span).clamp(0.0, 1.0);
    const green = Color(0xFF2E7D4F);

    Widget pill(String label, Color color, double width) => SizedBox(
          width: width,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        );
    Widget dot(Color color) => Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.schedule_rounded, size: 16, color: _accent),
        const SizedBox(width: 6),
        Text(s.prWhenHelps,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: (inWindow ? green : _score).withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(inWindow ? Icons.check_circle_rounded : Icons.upcoming_rounded,
              size: 14, color: inWindow ? green : _score),
          const SizedBox(width: 5),
          Text(inWindow ? s.prRelevantNow : s.prComingUp(fromWeek),
              style: text.labelSmall?.copyWith(
                  color: inWindow ? green : _score, fontWeight: FontWeight.w800)),
        ]),
      ),
      const SizedBox(height: 10),
      Text(s.prHelpsSentence(fromWeek, toLabel),
          style: text.bodyMedium?.copyWith(color: AppTheme.neutral700, height: 1.4)),
      const SizedBox(height: 22),
      LayoutBuilder(builder: (context, cons) {
        final w = cons.maxWidth;
        const youW = 92.0;
        const fromW = 54.0;
        final youLeft = (w * youFrac - youW / 2).clamp(0.0, w - youW);
        final fromLeft = (w * fromFrac - fromW / 2).clamp(0.0, w - fromW);
        final youDotL = (w * youFrac - 7).clamp(0.0, w - 14);
        final fromDotL = (w * fromFrac - 7).clamp(0.0, w - 14);
        return SizedBox(
          height: 54,
          child: Stack(children: [
            Positioned(left: youLeft, top: 0, child: pill(s.prYouWeek(currentWeek), _accent, youW)),
            if (laterFrom)
              Positioned(left: fromLeft, top: 0, child: pill('Wk $fromWeek', _score, fromW)),
            // grey track
            Positioned(
              left: 0, right: 0, top: 40,
              child: Container(height: 8, decoration: BoxDecoration(
                color: AppTheme.outlineVariant, borderRadius: BorderRadius.circular(8))),
            ),
            // active (gold) window: fromWeek → end
            Positioned(
              left: w * fromFrac, top: 40,
              child: Container(width: w * (1 - fromFrac), height: 8, decoration: BoxDecoration(
                color: _score, borderRadius: BorderRadius.circular(8))),
            ),
            if (laterFrom) Positioned(left: fromDotL, top: 37, child: dot(_score)),
            Positioned(left: youDotL, top: 37, child: dot(_accent)),
          ]),
        );
      }),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Week $axisStart',
            style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
        Text(toLabel, style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
      ]),
    ]);
  }
}

// ===========================================================================
//  Category page (guidance → picks → browse all)
// ===========================================================================

class ProductCategoryScreen extends StatelessWidget {
  const ProductCategoryScreen({super.key, required this.category, required this.controller});
  final ProductCategory category;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final picks = productsForCategory(category.id);
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(category.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _GuidanceCard(category: category, lang: lang),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: _WeekTimeline(
              fromWeek: category.fromWeek,
              toWeek: category.toWeek,
              toLabel: category.toLabel,
              currentWeek: controller.currentWeek,
              lang: lang,
            ),
          ),
          const SizedBox(height: 20),
          Text(s.prPicks, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final p in picks) _ProductCard(product: p, controller: controller),
          const SizedBox(height: 4),
          Center(
            child: Text(s.prBrowseAllCount(category.totalCount),
                style: text.labelLarge?.copyWith(color: _accent, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Product detail
// ===========================================================================

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product, required this.controller});
  final Product product;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final bv = _badgeVisual(product.badge);
    final category = productCategoryById(product.categoryId);
    final related =
        productsForCategory(product.categoryId).where((p) => p.id != product.id).toList();
    final sum = product.reviewSummary;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: s.pclAddToChecklist,
            icon: const Icon(Icons.playlist_add_rounded),
            onPressed: () =>
                showAddToChecklistSheet(context, controller, product),
          ),
          cartIconButton(context, controller,
              cartId: kProductsCartId, title: s.cartProductsTitle),
          _SaveHeart(id: product.id),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // If this product has a ParentVeda Product Guide, offer it up top.
          ...() {
            final g = guideForProduct(id: product.id, name: product.name);
            return g == null
                ? const <Widget>[]
                : [productGuideBanner(context, g, padding: EdgeInsets.zero), const SizedBox(height: 14)];
          }(),
          // Hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Column(children: [
              Text(product.emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 10),
              if (productIsAffiliate(product)) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9900).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.open_in_new_rounded,
                        size: 13, color: Color(0xFFB36B00)),
                    const SizedBox(width: 5),
                    Text(s.prAffiliate,
                        style: text.labelMedium?.copyWith(
                            color: const Color(0xFFB36B00),
                            fontWeight: FontWeight.w800)),
                  ]),
                ),
                const SizedBox(height: 8),
              ],
              if (product.badge != ProductBadge.none)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: bv.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${bv.emoji} ${s.prBadge(bv.key)}',
                      style: text.labelMedium?.copyWith(color: bv.color, fontWeight: FontWeight.w800)),
                ),
              const SizedBox(height: 10),
              Text(product.name,
                  textAlign: TextAlign.center,
                  style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(product.summary,
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(color: AppTheme.neutral600, height: 1.4)),
            ]),
          ),
          const SizedBox(height: 16),
          // Verdict
          _sectionCard(context, [
            Row(children: [
              Text(s.prVerdict, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              _scorePill(product.score),
            ]),
            const SizedBox(height: 8),
            Text('${s.prBestFor}: ${product.bestFor}',
                style: text.bodyMedium?.copyWith(color: AppTheme.neutral700)),
            Text(product.price,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          // Week timeline
          if (category != null) ...[
            const SizedBox(height: 12),
            _sectionCard(context, [
              _WeekTimeline(
                fromWeek: category.fromWeek,
                toWeek: category.toWeek,
                toLabel: category.toLabel,
                currentWeek: controller.currentWeek,
                lang: lang,
              ),
            ]),
          ],
          // Why
          const SizedBox(height: 12),
          _sectionCard(context, [
            Text(s.prWhy, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final w in product.why)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check_rounded, size: 17, color: Color(0xFF3FA56A)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(w, style: text.bodyMedium?.copyWith(height: 1.4))),
                ]),
              ),
            if (product.consider.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(s.prConsider, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final c in product.consider)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 8,
                      height: 8,
                      decoration:
                          const BoxDecoration(color: Color(0xFFD64545), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(c,
                          style: text.bodyMedium?.copyWith(color: AppTheme.neutral600, height: 1.4)),
                    ),
                  ]),
                ),
            ],
          ]),
          // Review summary
          if (sum != null) ...[
            const SizedBox(height: 12),
            _sectionCard(context, [
              Row(children: [
                Text(s.prReviewSummary, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const Text(' ❤️'),
              ]),
              const SizedBox(height: 10),
              _summaryRow(context, s.prMostLoved, sum.mostLoved),
              _summaryRow(context, s.prPraise, sum.praise),
              _summaryRow(context, s.prDrawback, sum.drawback),
              const SizedBox(height: 6),
              Row(children: [
                Text('${s.prWouldBuyAgain}: ',
                    style: text.bodyMedium?.copyWith(color: AppTheme.neutral600)),
                Text('${sum.wouldBuyAgainPct}%',
                    style: text.titleMedium?.copyWith(
                        color: const Color(0xFF3FA56A), fontWeight: FontWeight.w800)),
              ]),
            ]),
          ],
          // Reviews
          if (product.reviews.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(s.prReviews, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final r in product.reviews) _reviewCard(context, r, s),
          ],
          // Buy actions - affiliate (Amazon only) vs ParentVeda (cart + buy now).
          const SizedBox(height: 16),
          if (productIsAffiliate(product)) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9900),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.open_in_new_rounded,
                    size: 18, color: Colors.white),
                label: Text(s.prBuyOnAmazon,
                    style: text.titleSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                onPressed: () => launchUrl(Uri.parse(amazonSearchUrl(product)),
                    mode: LaunchMode.externalApplication),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(s.prAffiliateNote,
                  style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
            ),
          ] else
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    side: BorderSide(color: _accent.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: Text(s.cartAddToCart,
                      style: text.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  onPressed: () =>
                      showAddToCartFlow(context, controller, product),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  // ParentVeda Buy now → a real (mock) single-item checkout.
                  onPressed: () =>
                      showSingleItemBuyNow(context, controller, product),
                  child: Text(s.cartBuyNow,
                      style: text.titleSmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
          // Related
          if (related.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(s.prRelated, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            for (final p in related) _ProductCard(product: p, controller: controller),
          ],
        ],
      ),
    );
  }
}

Widget _sectionCard(BuildContext context, List<Widget> children) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );

Widget _summaryRow(BuildContext context, String label, String value) {
  final text = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: text.labelSmall?.copyWith(color: AppTheme.neutral500, fontWeight: FontWeight.w700)),
      Text(value, style: text.bodyMedium?.copyWith(height: 1.35)),
    ]),
  );
}

Widget _reviewCard(BuildContext context, ProductReview r, S s) {
  final text = Theme.of(context).textTheme;
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTheme.outlineVariant),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: _accent.withValues(alpha: 0.12),
          child: Text(r.author.isNotEmpty ? r.author[0] : '🙂',
              style: const TextStyle(fontWeight: FontWeight.w800, color: _accent)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.author, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            Text(r.role, style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
          ]),
        ),
        if (r.wouldBuyAgain)
          const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF3FA56A)),
      ]),
      const SizedBox(height: 10),
      _reviewLine(context, s.prUsedDuring, r.usedDuring),
      _reviewLine(context, s.prLiked, r.liked),
      _reviewLine(context, s.prWatchOut, r.watchOut),
    ]),
  );
}

Widget _reviewLine(BuildContext context, String label, String value) {
  final text = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: text.labelSmall?.copyWith(color: AppTheme.neutral500, fontWeight: FontWeight.w700)),
      Text(value, style: text.bodyMedium?.copyWith(height: 1.35)),
    ]),
  );
}

// ===========================================================================
//  Search (guidance-led: categories then products)
// ===========================================================================

class _ProductSearchDelegate extends SearchDelegate<void> {
  _ProductSearchDelegate(this.controller);
  final PregnancyController controller;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => query = ''),
      ];
  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded), onPressed: () => close(context, null));
  @override
  Widget buildResults(BuildContext context) => _results(context);
  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    if (query.trim().isEmpty) return const SizedBox.shrink();
    final cats = categorySearch(query);
    final prods = productSearch(query);
    final text = Theme.of(context).textTheme;
    return ListView(children: [
      for (final c in cats)
        ListTile(
          leading: Text(c.emoji, style: const TextStyle(fontSize: 22)),
          title: Text(c.name),
          subtitle: Text(c.guidance,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
          onTap: () {
            close(context, null);
            _push(context, ProductCategoryScreen(category: c, controller: controller));
          },
        ),
      for (final p in prods)
        ListTile(
          leading: Text(p.emoji, style: const TextStyle(fontSize: 22)),
          title: Text(p.name),
          subtitle: Text(p.summary,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
          onTap: () {
            close(context, null);
            _push(context, ProductDetailScreen(product: p, controller: controller));
          },
        ),
    ]);
  }
}
