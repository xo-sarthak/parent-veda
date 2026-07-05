// =============================================================================
//  ProductsDiscoveryScreen — Products · home / categories (parenting · S3 v2)
// -----------------------------------------------------------------------------
//  "Research first. Buy when you're sure." A search/ask bar, quick filter
//  presets, and an expandable category list (tap a category to open it, or the
//  chevron to peek its subcategories). Faithful build of Claude Design · S3 v2.
//  The Products hero tab. Nothing here imports pregnancy code.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_products_data.dart';
import 'products_category_screen.dart';
import 'products_compare_screen.dart';
import 'products_subcategory_screen.dart';

class ProductsDiscoveryScreen extends StatefulWidget {
  const ProductsDiscoveryScreen({super.key});

  @override
  State<ProductsDiscoveryScreen> createState() => _ProductsDiscoveryScreenState();
}

class _ProductsDiscoveryScreenState extends State<ProductsDiscoveryScreen> {
  final Set<String> _filters = {};
  final Set<String> _expanded = {};

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _openCategory(String name) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProductsCategoryScreen(category: name)));

  void _openSub(String category, String sub) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => ProductsSubcategoryScreen(category: category, sub: sub)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(top: 58, bottom: 116),
          children: [
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Products', style: ppJakarta(24)),
                  const SizedBox(height: 3),
                  Text("Research first. Buy when you're sure.", style: ppBody(13)),
                ]),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                clipBehavior: Clip.antiAlias,
                child: const PpStriped(height: 40),
              ),
            ])),

            // search / ask bar
            const SizedBox(height: 18),
            _pad(GestureDetector(
              onTap: _soon,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
                child: Row(children: [
                  const Icon(Icons.auto_awesome_outlined, size: 15, color: ppPurple),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Search or ask AskVeda…', style: ppBody(13, color: ppMuted))),
                  const Icon(Icons.search_rounded, size: 16, color: ppMuted),
                ]),
              ),
            )),

            // filter chips
            const SizedBox(height: 14),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  GestureDetector(
                    onTap: _soon,
                    child: Container(
                      margin: const EdgeInsets.only(right: 9),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                      decoration: BoxDecoration(color: ppInk, borderRadius: BorderRadius.circular(999)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.tune_rounded, size: 13, color: Colors.white),
                        const SizedBox(width: 5),
                        Text('Filters', style: ppBody(12, color: Colors.white, w: FontWeight.w700)),
                      ]),
                    ),
                  ),
                  _filterChip("For Aarav's age"),
                  _filterChip('Verified', check: true),
                  _filterChip('Under ₹1,000'),
                  _filterChip('Top rated'),
                  _filterChip('In-app'),
                ],
              ),
            ),

            // categories
            const SizedBox(height: 26),
            _pad(Text('Shop by category', style: ppJakarta(18))),
            const SizedBox(height: 4),
            _pad(Text('Tap a category to open its subcategories.', style: ppBody(12))),
            const SizedBox(height: 16),
            for (int i = 0; i < kPpCategories.length; i++) ...[
              _pad(_catRow(kPpCategories[i])),
              if (i < kPpCategories.length - 1)
                _pad(const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(height: 1, child: ColoredBox(color: ppHair)),
                )),
            ],

            // compare shortcut
            const SizedBox(height: 24),
            _pad(GestureDetector(
              onTap: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProductsCompareScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
                child: Row(children: [
                  const Icon(Icons.compare_arrows_rounded, size: 20, color: ppPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Compare any two', style: ppJakarta(14)),
                      const SizedBox(height: 1),
                      Text("Side by side, ParentVeda's honest read.", style: ppBody(12)),
                    ]),
                  ),
                  const SizedBox(width: 10),
                  const Text('→', style: TextStyle(color: ppPurple)),
                ]),
              ),
            )),

            const SizedBox(height: 22),
            _pad(Text(
                'Named, verified-mother reviews on every product. Sponsored slots are always labelled. Your research stays on ParentVeda.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)]),
              ),
            ),
          ),
        ),
        const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 3)),
      ]),
    );
  }

  Widget _filterChip(String label, {bool check = false}) {
    final on = _filters.contains(label);
    return GestureDetector(
      onTap: () => setState(() => on ? _filters.remove(label) : _filters.add(label)),
      child: Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (check) ...[
            Icon(Icons.check, size: 12, color: on ? Colors.white : ppSoft),
            const SizedBox(width: 4),
          ],
          Text(label, style: ppBody(12, color: on ? Colors.white : ppSoft, w: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _catRow(PpCategory cat) {
    final open = _expanded.contains(cat.name);
    return Column(children: [
      Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _openCategory(cat.name),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
                child: Icon(cat.icon, size: 21, color: ppPurple),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(cat.name, style: ppJakarta(16)),
                  const SizedBox(height: 2),
                  Text(cat.subs.map((s) => s.short).join(' · '),
                      style: ppBody(12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => setState(() => open ? _expanded.remove(cat.name) : _expanded.add(cat.name)),
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: ppLine)),
            child: AnimatedRotation(
              turns: open ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: ppPurple),
            ),
          ),
        ),
      ]),
      if (open) ...[
        const SizedBox(height: 14),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final s in cat.subs)
                GestureDetector(
                  onTap: () => _openSub(cat.name, s.name),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 82,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                        clipBehavior: Clip.antiAlias,
                        child: const PpStriped(height: 70),
                      ),
                      const SizedBox(height: 7),
                      Text(s.short,
                          textAlign: TextAlign.center,
                          style: ppBody(11, color: ppInk, w: FontWeight.w600).copyWith(height: 1.25),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ],
    ]);
  }
}
