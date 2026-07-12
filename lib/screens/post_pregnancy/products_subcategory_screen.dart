// =============================================================================
//  ProductsSubcategoryScreen - Products · subcategory (parenting · S3·subcat v2)
// -----------------------------------------------------------------------------
//  A subcategory (e.g. Soothers & white noise): what-to-look-for, working brand
//  + sort filters, and a ParentVeda-ranked compare-tickable product grid.
//  Faithful build of Claude Design · S3·subcategory v2. Product cards open the
//  detail; two ticks open Compare. No bottom nav.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_product_widgets.dart';
import 'pp_products_data.dart';

class ProductsSubcategoryScreen extends StatefulWidget {
  const ProductsSubcategoryScreen({super.key, this.category = 'Sleep', this.sub = 'Soothers & white noise'});
  final String category;
  final String sub;

  @override
  State<ProductsSubcategoryScreen> createState() => _ProductsSubcategoryScreenState();
}

class _ProductsSubcategoryScreenState extends State<ProductsSubcategoryScreen> {
  String _brand = 'All brands';
  String _sort = 'Top rated'; // 'Top rated' | 'Price'
  bool _underK = false;
  bool _inApp = false;
  bool _expanded = false; // "Browse all" reveals the full ranked list

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  // The first N picks lead; the rest sit behind a "Browse all (N)" affordance.
  static const int _previewCount = 4;

  String get _shortSub {
    final cat = categoryByName(widget.category);
    final match = cat.subs.where((s) => s.name == widget.sub);
    return match.isEmpty ? widget.sub : match.first.short;
  }

  List<PpProduct> get _all => productsInSub(widget.category, widget.sub);

  List<PpProduct> get _filtered {
    var items = _all;
    if (_brand != 'All brands') items = items.where((p) => p.brand == _brand).toList();
    if (_underK) items = items.where((p) => p.price < 1000).toList();
    if (_inApp) items = items.where((p) => p.retailer == 'In-app').toList();
    items = [...items]..sort((a, b) => _sort == 'Price' ? a.price.compareTo(b.price) : b.rating.compareTo(a.rating));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final brands = ['All brands', ...{for (final p in _all) p.brand}];
    final items = _filtered;

    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(top: 58, bottom: 40),
          children: [
            _pad(_breadcrumb(context)),

            const SizedBox(height: 16),
            _pad(Text(widget.sub, style: ppFraunces(28, h: 1.15))),

            const SizedBox(height: 14),
            _pad(Wrap(spacing: 8, runSpacing: 8, children: [
              _infoPill(widget.category == 'Sleep' ? '✓ Safe-sleep checked' : '✓ ParentVeda-checked', ppPurple),
              _infoPill('0–12 months', ppSoft),
            ])),

            // the 20-second buying guidance - education before the picks
            const SizedBox(height: 16),
            _pad(PpGuidanceCard(ppGuideFor(widget.category, widget.sub))),

            // brand filter
            const SizedBox(height: 22),
            _pad(ppEyebrow('Filter by brand', color: ppMuted, spacing: 0.6)),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [for (final b in brands) _brandChip(b)],
              ),
            ),

            // sort chips
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _sortChip('Top rated', active: _sort == 'Top rated', leadingSort: true, onTap: () => setState(() => _sort = 'Top rated')),
                  _sortChip('Price', active: _sort == 'Price', onTap: () => setState(() => _sort = 'Price')),
                  _sortChip('Under ₹1,000', active: _underK, onTap: () => setState(() => _underK = !_underK)),
                  _sortChip('In-app only', active: _inApp, onTap: () => setState(() => _inApp = !_inApp)),
                ],
              ),
            ),

            // products
            const SizedBox(height: 26),
            _pad(Row(children: [
              Expanded(child: Text('All ${_shortSub.toLowerCase()}', style: ppJakarta(17), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 10),
              Text('Ranked', style: ppBody(12, color: ppMuted)),
            ])),
            const SizedBox(height: 6),
            _pad(Text('Tick Compare on two to see them side by side.', style: ppBody(12))),
            const SizedBox(height: 14),
            if (items.isEmpty)
              _pad(Container(
                padding: const EdgeInsets.symmetric(vertical: 28),
                alignment: Alignment.center,
                child: Text('No matches - try loosening a filter.', style: ppBody(13, color: ppMuted)),
              ))
            else
              _pad(_snapshotList(items)),

            const SizedBox(height: 24),
            _pad(Text('Ranked by ParentVeda from expert review and verified-mother ratings.',
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
        const PpCompareFab(),
      ]),
    );
  }

  Widget _breadcrumb(BuildContext context) => Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).popUntil((r) => r.settings.name == 'pp/my_child' || r.isFirst),
          child: Text('Products', style: ppBody(12, color: ppPurple, w: FontWeight.w600)),
        ),
        const SizedBox(width: 6),
        const Text('›', style: TextStyle(color: Color(0xFFC7BBD6))),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Text(widget.category, style: ppBody(12, color: ppPurple, w: FontWeight.w600)),
        ),
        const SizedBox(width: 6),
        const Text('›', style: TextStyle(color: Color(0xFFC7BBD6))),
        const SizedBox(width: 6),
        Flexible(child: Text(_shortSub, style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]);

  Widget _infoPill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: ppBody(11, color: color, w: FontWeight.w700)),
      );

  Widget _brandChip(String b) {
    final on = _brand == b;
    return GestureDetector(
      onTap: () => setState(() => _brand = b),
      child: Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(b, style: ppBody(12, color: on ? Colors.white : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }

  Widget _sortChip(String label, {required bool active, bool leadingSort = false, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 9),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: active ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: active ? ppPurple : ppLine),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (leadingSort) ...[
              Icon(Icons.swap_vert_rounded, size: 14, color: active ? Colors.white : ppSoft),
              const SizedBox(width: 4),
            ],
            Text(label, style: ppBody(12, color: active ? Colors.white : ppSoft, w: FontWeight.w600)),
          ]),
        ),
      );

  // One rich snapshot card per row. The first [_previewCount] lead; the rest
  // sit behind a "Browse all (N)" affordance until the parent taps to reveal.
  Widget _snapshotList(List<PpProduct> items) {
    final showAll = _expanded || items.length <= _previewCount;
    final visible = showAll ? items : items.take(_previewCount).toList();
    return Column(children: [
      for (final p in visible) PpProductSnapshotCard(p),
      if (!showAll)
        GestureDetector(
          onTap: () => setState(() => _expanded = true),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: ppBorder)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Browse all ${items.length} ${_shortSub.toLowerCase()}',
                  style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 15, color: ppPurple),
            ]),
          ),
        ),
    ]);
  }
}
