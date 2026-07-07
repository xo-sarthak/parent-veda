// =============================================================================
//  ProductsDiscoveryScreen - Products · home / categories (parenting · S3 v2)
// -----------------------------------------------------------------------------
//  "Research first. Buy when you're sure." A search/ask bar, a marketplace-style
//  Filters + Sort bar (a Filters BUTTON opens a full filter sheet, not inline
//  toggles), the four discovery entry points from the Products brief -
//  Concern / Age-stage / Category / Compare - plus Brand · Price · Rating and
//  sort. With no filter set it shows the browse-by-category list; once anything
//  is set it shows a ranked results grid. The Products hero tab.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_product_widgets.dart';
import 'pp_products_data.dart';
import 'products_category_screen.dart';
import 'products_compare_screen.dart';
import 'products_subcategory_screen.dart';

// Price / rating filter options (label, threshold).
const List<(String, int)> _priceBands = [('Under ₹500', 500), ('Under ₹1,000', 1000), ('Under ₹2,000', 2000)];
const List<(String, double)> _ratingBands = [('4.5★ & up', 4.5), ('4.0★ & up', 4.0)];
const List<String> _sorts = ['Top rated', 'Most reviewed', 'Price: low to high', 'Price: high to low'];

class ProductsDiscoveryScreen extends StatefulWidget {
  const ProductsDiscoveryScreen({super.key});

  @override
  State<ProductsDiscoveryScreen> createState() => _ProductsDiscoveryScreenState();
}

class _ProductsDiscoveryScreenState extends State<ProductsDiscoveryScreen> {
  // applied filters
  final Set<String> _concerns = {};
  String? _stage;
  final Set<String> _cats = {};
  final Set<String> _brands = {};
  int? _priceMax;
  double _minRating = 0;
  String _sort = 'Top rated';

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _openCategory(String name) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProductsCategoryScreen(category: name)));

  void _openSub(String category, String sub) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => ProductsSubcategoryScreen(category: category, sub: sub)));

  int get _activeCount =>
      _concerns.length + (_stage != null ? 1 : 0) + _cats.length + _brands.length + (_priceMax != null ? 1 : 0) + (_minRating > 0 ? 1 : 0);

  bool get _active => _activeCount > 0;

  void _clearAll() => setState(() {
        _concerns.clear();
        _stage = null;
        _cats.clear();
        _brands.clear();
        _priceMax = null;
        _minRating = 0;
      });

  // Apply the discovery filters, then sort.
  List<PpProduct> _results() {
    var list = kPpProducts.toList();
    if (_concerns.isNotEmpty) {
      final cats = <String>{for (final c in kPpConcerns) if (_concerns.contains(c.$1)) ...c.$3};
      list = list.where((p) => cats.contains(p.category)).toList();
    }
    if (_stage != null) {
      final cats = kPpStages.firstWhere((s) => s.$1 == _stage).$2;
      list = list.where((p) => cats.contains(p.category)).toList();
    }
    if (_cats.isNotEmpty) list = list.where((p) => _cats.contains(p.category)).toList();
    if (_brands.isNotEmpty) list = list.where((p) => _brands.contains(p.brand)).toList();
    if (_priceMax != null) list = list.where((p) => p.price <= _priceMax!).toList();
    if (_minRating > 0) list = list.where((p) => p.rating >= _minRating).toList();
    switch (_sort) {
      case 'Most reviewed':
        list.sort((a, b) => b.reviews.compareTo(a.reviews));
        break;
      case 'Price: low to high':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: high to low':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      default:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final results = _active ? _results() : const <PpProduct>[];
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
                child: Row(children: [
                  const Icon(Icons.auto_awesome_outlined, size: 15, color: ppPurple),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Search or ask AskVeda…', style: ppBody(13, color: ppMuted))),
                  const Icon(Icons.search_rounded, size: 16, color: ppMuted),
                ]),
              ),
            )),

            // filters + sort bar
            const SizedBox(height: 14),
            _pad(Row(children: [
              Expanded(child: _filterButton()),
              const SizedBox(width: 10),
              Expanded(child: _sortButton()),
            ])),

            // active-filter chips
            if (_active) ...[
              const SizedBox(height: 14),
              _pad(_activeChips()),
            ],

            if (_active) ...[
              // results
              const SizedBox(height: 18),
              _pad(Row(children: [
                Expanded(child: Text('${results.length} ${results.length == 1 ? "product" : "products"}', style: ppJakarta(16))),
                GestureDetector(onTap: _clearAll, behavior: HitTestBehavior.opaque, child: Text('Clear all', style: ppBody(12, color: ppPurple, w: FontWeight.w700))),
              ])),
              const SizedBox(height: 16),
              if (results.isEmpty)
                _pad(Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  alignment: Alignment.center,
                  child: Column(children: [
                    const Icon(Icons.search_off_rounded, size: 30, color: ppMuted),
                    const SizedBox(height: 12),
                    Text('No products match those filters yet.', textAlign: TextAlign.center, style: ppBody(13)),
                  ]),
                ))
              else
                _pad(_grid(results)),
            ] else ...[
              // browse by category
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
            ],

            // compare shortcut
            const SizedBox(height: 24),
            _pad(GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProductsCompareScreen())),
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
            _pad(Text('Named, verified-mother reviews on every product. Sponsored slots are always labelled. Your research stays on ParentVeda.',
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
        const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 4)),
      ]),
    );
  }

  // ---- filter / sort buttons ---------------------------------------------
  Widget _filterButton() => GestureDetector(
        onTap: _openFilterSheet,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _active ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _active ? ppPurple : ppLine),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.tune_rounded, size: 16, color: _active ? Colors.white : ppInk),
            const SizedBox(width: 8),
            Text('Filters', style: ppBody(14, color: _active ? Colors.white : ppInk, w: FontWeight.w700)),
            if (_active) ...[
              const SizedBox(width: 7),
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(999)),
                child: Text('$_activeCount', style: ppBody(12, color: Colors.white, w: FontWeight.w700)),
              ),
            ],
          ]),
        ),
      );

  Widget _sortButton() => GestureDetector(
        onTap: _openSortSheet,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.swap_vert_rounded, size: 16, color: ppInk),
            const SizedBox(width: 8),
            Flexible(child: Text(_sort, style: ppBody(13, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ),
      );

  Widget _activeChips() {
    final chips = <Widget>[];
    void add(String label, VoidCallback remove) => chips.add(GestureDetector(
          onTap: remove,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
              const SizedBox(width: 6),
              const Icon(Icons.close_rounded, size: 13, color: ppPurple),
            ]),
          ),
        ));
    for (final c in _concerns.toList()) {
      add(c, () => setState(() => _concerns.remove(c)));
    }
    if (_stage != null) add(_stage!, () => setState(() => _stage = null));
    for (final c in _cats.toList()) {
      add(c, () => setState(() => _cats.remove(c)));
    }
    for (final b in _brands.toList()) {
      add(b, () => setState(() => _brands.remove(b)));
    }
    if (_priceMax != null) {
      add(_priceBands.firstWhere((p) => p.$2 == _priceMax).$1, () => setState(() => _priceMax = null));
    }
    if (_minRating > 0) {
      add(_ratingBands.firstWhere((r) => r.$2 == _minRating).$1, () => setState(() => _minRating = 0));
    }
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  // ---- results grid ------------------------------------------------------
  Widget _grid(List<PpProduct> items) => Column(children: [
        for (var i = 0; i < items.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: PpProductCard(items[i])),
              const SizedBox(width: 16),
              Expanded(child: i + 1 < items.length ? PpProductCard(items[i + 1]) : const SizedBox()),
            ]),
          ),
      ]);

  // ---- filter sheet ------------------------------------------------------
  void _openFilterSheet() {
    final tmpConcerns = {..._concerns};
    var tmpStage = _stage;
    final tmpCats = {..._cats};
    final tmpBrands = {..._brands};
    var tmpPrice = _priceMax;
    var tmpRating = _minRating;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetCtx) {
        return StatefulBuilder(builder: (sheetCtx, setSheet) {
          Widget chip(String label, bool on, VoidCallback onTap, {IconData? icon}) => GestureDetector(
                onTap: () => setSheet(onTap),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: on ? ppPurple : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: on ? null : Border.all(color: ppLine),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (icon != null) ...[
                      Icon(icon, size: 14, color: on ? Colors.white : ppSoft),
                      const SizedBox(width: 6),
                    ],
                    Text(label, style: ppBody(13, color: on ? Colors.white : ppInk, w: on ? FontWeight.w700 : FontWeight.w600)),
                  ]),
                ),
              );

          Widget section(String title, Widget body) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                Text(title, style: ppJakarta(15)),
                const SizedBox(height: 12),
                body,
              ]);

          // preview count
          final preview = _previewCount(tmpConcerns, tmpStage, tmpCats, tmpBrands, tmpPrice, tmpRating);

          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetCtx).size.height * 0.82),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: 10),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
                    child: Row(children: [
                      Expanded(child: Text('Filters', style: ppFraunces(24, h: 1.1))),
                      GestureDetector(
                        onTap: () => setSheet(() {
                          tmpConcerns.clear();
                          tmpStage = null;
                          tmpCats.clear();
                          tmpBrands.clear();
                          tmpPrice = null;
                          tmpRating = 0;
                        }),
                        behavior: HitTestBehavior.opaque,
                        child: Text('Reset', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      children: [
                        section("What's the concern?", Wrap(spacing: 9, runSpacing: 9, children: [
                          for (final c in kPpConcerns)
                            chip(c.$1, tmpConcerns.contains(c.$1), () => tmpConcerns.contains(c.$1) ? tmpConcerns.remove(c.$1) : tmpConcerns.add(c.$1), icon: c.$2),
                        ])),
                        section('Age & stage', Wrap(spacing: 9, runSpacing: 9, children: [
                          for (final s in kPpStages) chip(s.$1, tmpStage == s.$1, () => tmpStage = tmpStage == s.$1 ? null : s.$1),
                        ])),
                        section('Category', Wrap(spacing: 9, runSpacing: 9, children: [
                          for (final c in kPpCategories) chip(c.name, tmpCats.contains(c.name), () => tmpCats.contains(c.name) ? tmpCats.remove(c.name) : tmpCats.add(c.name)),
                        ])),
                        section('Brand', Wrap(spacing: 9, runSpacing: 9, children: [
                          for (final b in ppBrands()) chip(b, tmpBrands.contains(b), () => tmpBrands.contains(b) ? tmpBrands.remove(b) : tmpBrands.add(b)),
                        ])),
                        section('Price', Wrap(spacing: 9, runSpacing: 9, children: [
                          for (final p in _priceBands) chip(p.$1, tmpPrice == p.$2, () => tmpPrice = tmpPrice == p.$2 ? null : p.$2),
                        ])),
                        section('Rating', Wrap(spacing: 9, runSpacing: 9, children: [
                          for (final r in _ratingBands) chip(r.$1, tmpRating == r.$2, () => tmpRating = tmpRating == r.$2 ? 0 : r.$2),
                        ])),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair))),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _concerns
                            ..clear()
                            ..addAll(tmpConcerns);
                          _stage = tmpStage;
                          _cats
                            ..clear()
                            ..addAll(tmpCats);
                          _brands
                            ..clear()
                            ..addAll(tmpBrands);
                          _priceMax = tmpPrice;
                          _minRating = tmpRating;
                        });
                        Navigator.of(sheetCtx).pop();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                        child: Text('Show $preview ${preview == 1 ? "product" : "products"}', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          );
        });
      },
    );
  }

  int _previewCount(Set<String> concerns, String? stage, Set<String> cats, Set<String> brands, int? priceMax, double minRating) {
    var list = kPpProducts.toList();
    if (concerns.isNotEmpty) {
      final cs = <String>{for (final c in kPpConcerns) if (concerns.contains(c.$1)) ...c.$3};
      list = list.where((p) => cs.contains(p.category)).toList();
    }
    if (stage != null) {
      final cs = kPpStages.firstWhere((s) => s.$1 == stage).$2;
      list = list.where((p) => cs.contains(p.category)).toList();
    }
    if (cats.isNotEmpty) list = list.where((p) => cats.contains(p.category)).toList();
    if (brands.isNotEmpty) list = list.where((p) => brands.contains(p.brand)).toList();
    if (priceMax != null) list = list.where((p) => p.price <= priceMax).toList();
    if (minRating > 0) list = list.where((p) => p.rating >= minRating).toList();
    return list.length;
  }

  // ---- sort sheet --------------------------------------------------------
  void _openSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999))),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
            child: Align(alignment: Alignment.centerLeft, child: Text('Sort by', style: ppFraunces(24, h: 1.1))),
          ),
          for (final s in _sorts)
            GestureDetector(
              onTap: () {
                setState(() => _sort = s);
                Navigator.of(sheetCtx).pop();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(children: [
                  Expanded(child: Text(s, style: ppBody(15, color: ppInk, w: _sort == s ? FontWeight.w700 : FontWeight.w500))),
                  if (_sort == s) const Icon(Icons.check_rounded, size: 18, color: ppPurple),
                ]),
              ),
            ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  // ---- category browse block ---------------------------------------------
  // Category header (tap → category page) with its subcategories always shown,
  // laid out as an even 3-up row of tiles (tap → subcategory) - no dropdown.
  Widget _catRow(PpCategory cat) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => _openCategory(cat.name),
          behavior: HitTestBehavior.opaque,
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
              child: Icon(cat.icon, size: 20, color: ppPurple),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(cat.name, style: ppJakarta(16))),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward, size: 16, color: ppMuted),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          for (int i = 0; i < cat.subs.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: _subTile(cat.name, cat.subs[i])),
          ],
        ]),
      ]);

  Widget _subTile(String category, PpSub s) => GestureDetector(
        onTap: () => _openSub(category, s.name),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            const PpStriped(height: 62),
            SizedBox(
              height: 40,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(s.short,
                      textAlign: TextAlign.center,
                      style: ppBody(11.5, color: ppInk, w: FontWeight.w600).copyWith(height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
          ]),
        ),
      );
}
