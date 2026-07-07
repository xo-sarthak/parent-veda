// =============================================================================
//  FoodRecipeScreen — a recipe as a food companion page (not a blog post)
// -----------------------------------------------------------------------------
//  Ingredients + steps, yes — but wrapped in understanding: a Nutrition
//  Breakdown, the signature Healthier-Version toggle (everyday ⇄ ParentVeda,
//  with what changed & why), why it's good, how often to serve, storage, common
//  mistakes, substitutions, and links out to the article/video/product/community/
//  Ask Veda. Add-to-shopping-list generates the checklist. pp-themed, no emojis.
// =============================================================================

import 'package:flutter/material.dart';

import 'article_reader_screen.dart';
import 'food_common.dart';
import 'food_shopping_screen.dart';
import 'pp_common.dart';
import 'pp_food_data.dart';
import 'pp_products_data.dart';
import 'pp_watch_data.dart';
import 'product_detail_screen.dart';
import 'watch_player_screen.dart';
import 'watch_quicklearn_screen.dart';

class FoodRecipeScreen extends StatefulWidget {
  const FoodRecipeScreen({super.key, required this.recipe});
  final FoodRecipe recipe;

  @override
  State<FoodRecipeScreen> createState() => _FoodRecipeScreenState();
}

class _FoodRecipeScreenState extends State<FoodRecipeScreen> {
  bool _healthier = true; // false = "everyday" framing, true = ParentVeda

  FoodRecipe get r => widget.recipe;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            _hero(),
            const SizedBox(height: 18),
            _pad(Text(r.title, style: ppFraunces(25, h: 1.15))),
            const SizedBox(height: 6),
            _pad(Text(r.subtitle, style: ppBody(14, h: 1.5))),
            const SizedBox(height: 16),
            _pad(_statStrip()),
            const SizedBox(height: 20),
            _pad(_healthierCard()),
            const SizedBox(height: 22),
            _pad(_ingredients()),
            const SizedBox(height: 22),
            _pad(_steps()),
            const SizedBox(height: 8),
            _pad(_addToShopping()),
            const SizedBox(height: 8),
            _pad(ppSectionDivider()),
            _pad(_nutrition()),
            const SizedBox(height: 22),
            _pad(_why()),
            const SizedBox(height: 22),
            _pad(_bulletsSection('Good to know', [
              ('How often', r.frequency),
              for (final s in r.storage) ('Storage', s),
            ], Icons.info_outline_rounded)),
            const SizedBox(height: 22),
            _pad(_mistakes()),
            const SizedBox(height: 22),
            if (r.substitutions.isNotEmpty) ...[_pad(_subs()), const SizedBox(height: 22)],
            _pad(_related()),
          ],
        ),
      ),
    );
  }

  // ---- hero ---------------------------------------------------------------
  Widget _hero() => Stack(children: [
        FoodThumb(seed: r.seed, height: 240, radius: 0),
        Positioned(
          top: 8,
          left: 12,
          child: _round(Icons.arrow_back, () => Navigator.of(context).maybePop()),
        ),
        Positioned(
          top: 8,
          right: 12,
          child: AnimatedBuilder(
            animation: FoodStore.instance,
            builder: (context, _) {
              final saved = FoodStore.instance.isSaved(r.id);
              return _round(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, () => FoodStore.instance.toggleSave(r.id));
            },
          ),
        ),
      ]);

  Widget _round(IconData i, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8)]),
          child: Icon(i, size: 19, color: ppInk),
        ),
      );

  // ---- stat strip ---------------------------------------------------------
  Widget _statStrip() => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          _stat('Prep', '${r.prepMin} min'),
          _div(),
          _stat('Cook', r.cookMin == 0 ? 'No-cook' : '${r.cookMin} min'),
          _div(),
          _stat('Level', r.difficulty),
          _div(),
          _stat('Age', r.ageTag),
        ]),
      );

  Widget _stat(String label, String value) => Expanded(
        child: Column(children: [
          Text(value, style: ppJakarta(13.5), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(label.toUpperCase(), style: ppBody(9, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.5)),
        ]),
      );

  Widget _div() => Container(width: 1, height: 26, color: ppLine);

  // ---- healthier version (signature) --------------------------------------
  Widget _healthierCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFF6ECEF)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.volunteer_activism_outlined, size: 16, color: ppPurple),
            const SizedBox(width: 8),
            ppEyebrow('Healthier version', color: ppPurple, spacing: 1.0),
          ]),
          const SizedBox(height: 14),
          // toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
            child: Row(children: [
              _seg('Everyday', !_healthier, () => setState(() => _healthier = false)),
              _seg('ParentVeda', _healthier, () => setState(() => _healthier = true)),
            ]),
          ),
          const SizedBox(height: 14),
          if (_healthier)
            Text(r.healthierNote, style: ppBody(13.5, color: ppInk, h: 1.55))
          else
            Text(
              'The way it’s usually made leans on sugar, refined flour or deep-frying. Tap “ParentVeda” to see the small changes that make the same dish genuinely better for your baby — without losing what he loves.',
              style: ppBody(13.5, color: ppSoft, h: 1.55),
            ),
        ]),
      );

  Widget _seg(String label, bool on, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: on ? ppPurple : Colors.transparent, borderRadius: BorderRadius.circular(999)),
            child: Text(label, style: ppBody(12.5, color: on ? Colors.white : ppSoft, w: FontWeight.w700)),
          ),
        ),
      );

  // ---- ingredients + steps ------------------------------------------------
  Widget _ingredients() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ingredients', style: ppJakarta(17)),
        const SizedBox(height: 12),
        for (final ing in r.ingredients)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(margin: const EdgeInsets.only(top: 7), width: 6, height: 6, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(child: Text(ing, style: ppBody(14, color: ppInk, h: 1.4))),
            ]),
          ),
      ]);

  Widget _steps() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('How to make it', style: ppJakarta(17)),
        const SizedBox(height: 14),
        for (int i = 0; i < r.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                child: Text('${i + 1}', style: ppBody(12.5, color: ppPurple, w: FontWeight.w800)),
              ),
              const SizedBox(width: 13),
              Expanded(child: Text(r.steps[i], style: ppBody(14, color: ppInk, h: 1.5))),
            ]),
          ),
      ]);

  Widget _addToShopping() => GestureDetector(
        onTap: () {
          FoodStore.instance.addRecipeToShopping(r);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Ingredients added to your shopping list'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: 'View', onPressed: () => _push(const FoodShoppingScreen())),
          ));
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.add_shopping_cart_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text('Add ingredients to shopping list', style: ppBody(13.5, color: Colors.white, w: FontWeight.w700)),
          ]),
        ),
      );

  // ---- nutrition breakdown ------------------------------------------------
  Widget _nutrition() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Nutrition breakdown', style: ppJakarta(17)),
        const SizedBox(height: 4),
        Text('What’s in it, and why it helps him — no calorie counting.', style: ppBody(12.5, color: ppMuted)),
        const SizedBox(height: 14),
        for (final n in r.nutrients)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: ppHair)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(n.name, style: ppJakarta(14)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                      child: Text(n.amount, style: ppBody(10.5, color: ppPurple, w: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 5),
                  Text(n.note, style: ppBody(12.5, h: 1.4)),
                ]),
              ),
            ]),
          ),
      ]);

  Widget _why() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppEyebrow('Why this is good for him', color: ppPurple, spacing: 0.8),
          const SizedBox(height: 10),
          Text(r.why, style: ppBody(14, color: ppInk, h: 1.6)),
        ]),
      );

  Widget _bulletsSection(String title, List<(String, String)> rows, IconData icon) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: ppJakarta(17)),
        const SizedBox(height: 12),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, size: 16, color: ppPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: '${row.$1}: ', style: ppBody(13.5, color: ppInk, w: FontWeight.w700)),
                  TextSpan(text: row.$2, style: ppBody(13.5, color: ppSoft)),
                ]), style: const TextStyle(height: 1.5)),
              ),
            ]),
          ),
      ]);

  Widget _mistakes() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Watch out for', style: ppJakarta(17)),
        const SizedBox(height: 12),
        for (final m in r.mistakes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.error_outline_rounded, size: 16, color: ppCoral),
              const SizedBox(width: 12),
              Expanded(child: Text(m, style: ppBody(13.5, color: ppInk, h: 1.5))),
            ]),
          ),
      ]);

  Widget _subs() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Swaps & substitutions', style: ppJakarta(17)),
        const SizedBox(height: 12),
        for (final e in r.substitutions.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '${e.key} ', style: ppBody(13.5, color: ppInk, w: FontWeight.w700)),
              TextSpan(text: '→ ${e.value}', style: ppBody(13.5, color: ppSoft)),
            ]), style: const TextStyle(height: 1.5)),
          ),
      ]);

  // ---- related (ecosystem) ------------------------------------------------
  Widget _related() {
    final rows = <(IconData, String, String, VoidCallback)>[
      if (r.relatedArticle != null) (Icons.menu_book_outlined, 'Article', r.relatedArticle!, () => _push(const ArticleReaderScreen())),
      if (r.relatedVideoId != null)
        (Icons.play_circle_outline, 'Watch', watchVideoById(r.relatedVideoId!).title, () {
          final v = watchVideoById(r.relatedVideoId!);
          _push(v.quick ? QuickLearnScreen(startId: v.id) : WatchPlayerScreen(video: v));
        }),
      if (r.relatedProductId != null) (Icons.shopping_bag_outlined, 'Product', productById(r.relatedProductId!).name, () => _push(ProductDetailScreen(product: productById(r.relatedProductId!)))),
      if (r.relatedCommunity != null) (Icons.groups_outlined, 'Community', r.relatedCommunity!, () => openPpTab(context, 3)),
      (Icons.auto_awesome_outlined, 'Ask Veda', 'Ask about feeding at ${r.ageTag}', () => openPpTab(context, 1)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Connected in ParentVeda', style: ppJakarta(17)),
      const SizedBox(height: 14),
      for (final row in rows)
        GestureDetector(
          onTap: row.$4,
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: ppHair)),
            child: Row(children: [
              Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)), child: Icon(row.$1, size: 18, color: ppPurple)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(row.$2.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
                  const SizedBox(height: 3),
                  Text(row.$3, style: ppBody(13.5, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
            ]),
          ),
        ),
    ]);
  }
}
