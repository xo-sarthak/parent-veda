// =============================================================================
//  ProductsCompareScreen - Products · compare (parenting · S3·compare v2 premium)
// -----------------------------------------------------------------------------
//  Compare as a first-class TOOL, and now a pure PRESENTATION layer over the
//  Compare Manager (PpCompareStore). It holds no products of its own - it builds
//  itself from whatever the parent has picked while browsing:
//    · 0 picked  → an elegant empty state that sends them to browse Products
//    · 1 picked  → the current product + smart same-category suggestions
//    · 2-3       → a full, per-product differentiated side-by-side
//  Everything is dynamic: add, remove, replace or clear and the screen refreshes
//  instantly (it listens to the store). Every section is per-product - ratings
//  up top, a spec sheet built from each product's own specs, and "The ParentVeda
//  take" one card PER product. No hardcoded pair, no generic shared copy.
// =============================================================================

import 'package:flutter/material.dart';

import '../../brand/brand_models.dart';
import '../../brand/needs_attention.dart';
import '../../brand/presented_by.dart';
import 'pp_common.dart';
import 'pp_products_data.dart';

class ProductsCompareScreen extends StatelessWidget {
  const ProductsCompareScreen({super.key});

  static const Color _green = Color(0xFF1F8A5B);
  static const Color _amberBg = Color(0xFFFFF6EE);
  static const Color _greenBg = Color(0xFFEAF4EE);

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening the store soon'), behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    // The screen is a live view of the Compare Manager - any add/remove/replace
    // refreshes it in place.
    return AnimatedBuilder(
      animation: PpCompareStore.instance,
      builder: (context, _) {
        final sel = PpCompareStore.instance.selected;
        if (sel.isEmpty) return _emptyScaffold(context);
        if (sel.length == 1) return _oneScaffold(context, sel.first);
        return _comparisonScaffold(context, sel);
      },
    );
  }

  // ---- back row (shared) --------------------------------------------------
  Widget _backRow(BuildContext context, String eyebrow, {bool showClear = false}) => _pad(Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, size: 16, color: ppInk),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: ppEyebrow(eyebrow, color: ppMuted, spacing: 1.2)),
        if (showClear)
          GestureDetector(
            onTap: () => PpCompareStore.instance.clear(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text('Clear', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
            ),
          ),
      ]));

  // =========================================================================
  //  0 PRODUCTS - empty state (no placeholder products)
  // =========================================================================
  Widget _emptyScaffold(BuildContext context) => Scaffold(
        backgroundColor: ppBg,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 40),
            children: [
              _backRow(context, 'Compare'),
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                  child: const Icon(Icons.compare_arrows_rounded, size: 42, color: ppPurple),
                ),
              ),
              const SizedBox(height: 26),
              _pad(Text('No products selected yet.', textAlign: TextAlign.center, style: ppFraunces(25, h: 1.15))),
              const SizedBox(height: 12),
              _pad(Text(
                  'Add products while browsing ParentVeda to compare them side by side - tap "Compare" on any product card, or "Add to Compare" on a product page.',
                  textAlign: TextAlign.center,
                  style: ppBody(14, color: ppSoft, h: 1.6))),
              const SizedBox(height: 28),
              _pad(GestureDetector(
                onTap: () => openPpTab(context, 4),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                  child: Text('Browse Products', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                ),
              )),
              const SizedBox(height: 22),
              _pad(Text('Only products in the same category can be compared, so every comparison stays meaningful.',
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),
        ),
      );

  // =========================================================================
  //  1 PRODUCT - current pick + smart same-category suggestions
  // =========================================================================
  Widget _oneScaffold(BuildContext context, PpProduct p) {
    final suggestions = PpCompareStore.instance.suggestions();
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _backRow(context, 'Compare · ${p.category}', showClear: true),
            const SizedBox(height: 20),
            _pad(Text('Add one more to compare.', style: ppFraunces(29, h: 1.14))),
            const SizedBox(height: 10),
            _pad(Text('You have one ${p.category.toLowerCase()} product picked. Add another (up to three) to see them side by side.',
                style: ppBody(14, color: ppSoft, h: 1.55))),

            // the current pick
            const SizedBox(height: 22),
            _pad(ppEyebrow('Your pick', color: ppMuted, spacing: 0.8)),
            const SizedBox(height: 10),
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _overview(context, p)),
              const SizedBox(width: 12),
              Expanded(child: _addSlot(context)),
            ])),

            // education carries over so the wait is useful
            const SizedBox(height: 22),
            _pad(_beforeYouCompare(p)),

            // smart suggestions - same category, tap to add
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 26),
              _pad(Text('Compare with similar ${_categoryNoun(p.category)}', style: ppJakarta(16))),
              const SizedBox(height: 4),
              _pad(Text('Same category, so the comparison stays meaningful. Tap to add.', style: ppBody(12))),
              const SizedBox(height: 14),
              for (final s in suggestions) _pad(_suggestionRow(context, s)),
            ],

            const SizedBox(height: 22),
            _pad(Text("ParentVeda's take is evidence-based, neutral and never promotional.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  // an "Add another" placeholder that sits next to the single pick
  Widget _addSlot(BuildContext context) => GestureDetector(
        onTap: () => _openPicker(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 232,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ppPanel.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ppBorder),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.add_rounded, size: 24, color: ppPurple),
            ),
            const SizedBox(height: 12),
            Text('Add another', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('up to 3', style: ppBody(11, color: ppMuted)),
          ]),
        ),
      );

  Widget _suggestionRow(BuildContext context, PpProduct p) => GestureDetector(
        onTap: () => PpCompareStore.instance.toggle(p),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
          child: Row(children: [
            const SizedBox(width: 54, child: PpStriped(height: 54, radius: 12)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, style: ppJakarta(13.5).copyWith(height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 13, color: ppCoral),
                  const SizedBox(width: 3),
                  Text(p.rating.toStringAsFixed(1), style: ppBody(11.5, color: ppInk, w: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Flexible(child: Text(p.priceLabel, style: ppBody(11.5, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ]),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.add_rounded, size: 14, color: ppPurple),
                const SizedBox(width: 4),
                Text('Add', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
              ]),
            ),
          ]),
        ),
      );

  // =========================================================================
  //  2-3 PRODUCTS - the full, dynamic side-by-side
  // =========================================================================
  Widget _comparisonScaffold(BuildContext context, List<PpProduct> ps) {
    final sameSub = ps.every((x) => x.sub == ps.first.sub);
    final eyebrow = 'Compare · ${sameSub ? ps.first.sub : ps.first.category}';
    final noun = sameSub ? ps.first.sub.toLowerCase() : '${ps.first.category.toLowerCase()} products';

    // union of spec keys across every selected product
    final specMaps = [for (final p in ps) _specsOf(p)];
    final specKeys = <String>[];
    for (final m in specMaps) {
      for (final k in m.keys) {
        if (!specKeys.contains(k)) specKeys.add(k);
      }
    }
    final canAddMore = ps.length < PpCompareStore.maxItems && PpCompareStore.instance.suggestions().isNotEmpty;

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 108),
            children: [
              _backRow(context, eyebrow, showClear: true),

              const SizedBox(height: 20),
              _pad(Text('${_title(ps)}.', style: ppFraunces(30, h: 1.14))),

              // child context - the comparison is personalised to his stage
              const SizedBox(height: 14),
              _pad(Row(children: [
                const Icon(Icons.child_care_outlined, size: 15, color: ppPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Comparing ${ps.length} $noun for Aarav · 4 months - tuned to his stage.',
                      style: ppBody(12.5, color: ppSoft, h: 1.4)),
                ),
              ])),

              // the differentiator: education BEFORE the comparison
              const SizedBox(height: 18),
              _pad(_beforeYouCompare(ps.first)),
              _pad(_compareSponsor(ps)),

              // overview cards - rating up top, plus per-card remove / replace
              const SizedBox(height: 22),
              _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (var i = 0; i < ps.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: _overview(context, ps[i], manage: true)),
                ],
              ])),

              // add another (up to 3)
              if (canAddMore) ...[
                const SizedBox(height: 14),
                _pad(GestureDetector(
                  onTap: () => _openPicker(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ppBorder),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add_rounded, size: 16, color: ppPurple),
                      const SizedBox(width: 8),
                      Text('Add another product', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                    ]),
                  ),
                )),
              ],

              // one fully column-divided comparison table: a header row of
              // product names, the spec rows, what parents rated & loved, and -
              // last - the ParentVeda take (the verdict sits at the bottom).
              const SizedBox(height: 22),
              _pad(Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
                clipBehavior: Clip.antiAlias,
                child: Column(children: [
                  _tRow(null, [for (final p in ps) Text(p.name, style: ppJakarta(13.5).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis)], header: true),
                  for (final k in specKeys)
                    _tRow(k, [for (final m in specMaps) _specCell(k, m[k] ?? '-')]),
                  _tRow('Parents rated', [for (final p in ps) _ratedCell(p)]),
                  _tRow('Parents loved', [for (final p in ps) _lovedCell(p)]),
                  _tRow('The ParentVeda take', [for (final p in ps) _takeCell(p)], last: true),
                ]),
              )),

              const SizedBox(height: 22),
              _pad(Text("ParentVeda's take is evidence-based, neutral and never promotional.",
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),

          // sticky buy bar (one per product, dynamic)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg], stops: [0, 0.26]),
              ),
              child: Row(children: [
                for (var i = 0; i < ps.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: _buyBtn(context, ps[i], primary: i == 0)),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // The editorial headline: "A vs B" for two, "A, B & C" for three. Uses the
  // brand when brands differ, else the product name.
  String _title(List<PpProduct> ps) {
    final sameBrand = ps.every((x) => x.brand == ps.first.brand);
    final labels = [for (final p in ps) sameBrand ? p.name : p.brand];
    if (labels.length == 2) return '${labels[0]} vs ${labels[1]}';
    return '${labels.sublist(0, labels.length - 1).join(', ')} & ${labels.last}';
  }

  String _categoryNoun(String category) => category == 'Sleep' ? 'sleep products' : '${category.toLowerCase()} products';

  String _summaryOf(PpProduct p) => p.summary.isNotEmpty ? p.summary : '${p.brand} · ${p.sub}';

  // Each product's spec sheet - its own `specs`, else derived from its fields -
  // with the rating appended as its own row, up front in the table.
  Map<String, String> _specsOf(PpProduct p) {
    final m = <String, String>{};
    if (p.specs.isNotEmpty) {
      m.addAll(p.specs);
    } else {
      if (p.sound != null) m['Sound'] = p.sound!;
      if (p.autoOff != null) m['Auto-off timer'] = p.autoOff! ? 'Yes' : 'No';
      if (p.volumeLock != null) m['Volume lock'] = p.volumeLock! ? 'Yes' : 'No';
      if (p.power != null) m['Power'] = p.power!;
      m['Price'] = p.priceLabel;
      m['Sold via'] = p.retailer;
    }
    m['Rating'] = '★ ${p.rating.toStringAsFixed(1)} · ${p.reviews} reviews';
    return m;
  }

  List<String> _prosOf(PpProduct p) {
    if (p.pros.isNotEmpty) return p.pros;
    final l = <String>[];
    if (p.rating >= 4.6) l.add('Highly rated - ${p.ratingLabel} from ${p.reviews} reviews');
    if (p.parentVeda) l.add('Made by ParentVeda');
    if (p.verified) l.add('ParentVeda-verified purchase reviews');
    if (p.bestseller) l.add('A bestseller in its category');
    if (l.isEmpty) l.add('${p.ratingLabel} from ${p.reviews} reviews');
    return l;
  }

  List<String> _consOf(PpProduct p) {
    if (p.cons.isNotEmpty) return p.cons;
    final l = <String>[];
    if (p.price >= 2000) l.add('A premium price point');
    if (p.reviews < 60) l.add('Fewer reviews so far - newer to the shelf');
    if (!p.verified && !p.parentVeda) l.add('Not yet ParentVeda-verified');
    if (l.isEmpty) l.add('Nothing major flagged by parents yet');
    return l;
  }

  // ---- product picker sheet (add / replace, same category only) ----------
  void _openPicker(BuildContext context, {PpProduct? replace}) {
    final options = PpCompareStore.instance.suggestions();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetCtx).size.height * 0.72),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999))),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(replace == null ? 'Add a product' : 'Replace ${replace.brand}', style: ppFraunces(23, h: 1.1)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Same category, so the comparison stays meaningful.', style: ppBody(12.5, color: ppSoft)),
              ),
            ),
            if (options.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Text('No other ${PpCompareStore.instance.category?.toLowerCase() ?? ''} products to add yet.',
                    style: ppBody(13, color: ppMuted)),
              )
            else
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  children: [
                    for (final o in options)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            if (replace != null) {
                              PpCompareStore.instance.replace(replace, o);
                            } else {
                              PpCompareStore.instance.toggle(o);
                            }
                            Navigator.of(sheetCtx).pop();
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
                            child: Row(children: [
                              const SizedBox(width: 48, child: PpStriped(height: 48, radius: 10)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(o.name, style: ppJakarta(13.5).copyWith(height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 3),
                                  Row(children: [
                                    const Icon(Icons.star_rounded, size: 13, color: ppCoral),
                                    const SizedBox(width: 3),
                                    Text(o.rating.toStringAsFixed(1), style: ppBody(11.5, color: ppInk, w: FontWeight.w700)),
                                    const SizedBox(width: 8),
                                    Flexible(child: Text(o.priceLabel, style: ppBody(11.5, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  ]),
                                ]),
                              ),
                              const SizedBox(width: 10),
                              Icon(replace == null ? Icons.add_circle_outline_rounded : Icons.swap_horiz_rounded, size: 20, color: ppPurple),
                            ]),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ]),
        ),
      ),
    );
  }

  // ---- before you compare (education first - the differentiator) ---------
  /// FLAGGED: a sponsor on the most decision-shaping screen in the app. The
  /// table above is untouched — no spec, no rating, no ordering — and a brand
  /// can never sponsor a comparison it is one of the two products in.
  Widget _compareSponsor(List<PpProduct> compared) {
    final brands = compared.map((p) => p.brand.toLowerCase()).toSet();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PresentedBy(
        slot: BrandSlot.compareGuide,
        stage: BrandStage.parenting,
        // Hard rule: a brand cannot sponsor a comparison it is IN. A bogus key
        // resolves to nothing, so the line simply does not render.
        placementKey: brands.contains('tinytoes') ? 'self_blocked' : null,
        padding: const EdgeInsets.only(top: 4),
      ),
      const NeedsAttentionFlag(flag: BrandFlag.compareSponsorship, padding: EdgeInsets.only(top: 8)),
    ]);
  }

  Widget _beforeYouCompare(PpProduct a) {
    final g = compareGuideFor(a.category);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFF6EEF9)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.school_outlined, size: 17, color: ppPurple),
          const SizedBox(width: 8),
          ppEyebrow('Before you compare', color: ppPurple, spacing: 0.8),
        ]),
        const SizedBox(height: 12),
        Text('What actually matters', style: ppJakarta(14.5)),
        const SizedBox(height: 9),
        for (final w in g.whatMatters)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.check_circle_outline_rounded, size: 15, color: ppPurple)),
              const SizedBox(width: 9),
              Expanded(child: Text(w, style: ppBody(13, color: ppInk, h: 1.5))),
            ]),
          ),
        const SizedBox(height: 6),
        _guideLine(Icons.remove_circle_outline, 'Often doesn\'t matter', g.oftenSkip),
        const SizedBox(height: 8),
        _guideLine(Icons.error_outline_rounded, 'A common mistake', g.mistake),
        if (g.contextTip != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.child_care_outlined, size: 15, color: ppPurple),
              const SizedBox(width: 9),
              Expanded(child: Text(g.contextTip!, style: ppBody(12.5, color: ppInk, h: 1.5))),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _guideLine(IconData icon, String label, String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 15, color: ppSoft)),
        const SizedBox(width: 9),
        Expanded(
          child: Text.rich(TextSpan(children: [
            TextSpan(text: '$label: ', style: ppBody(13, color: ppInk, w: FontWeight.w700, h: 1.5)),
            TextSpan(text: text, style: ppBody(13, color: ppSoft, h: 1.5)),
          ])),
        ),
      ]);

  // ---- overview (rating prominent; manage = remove / replace controls) ---
  Widget _overview(BuildContext context, PpProduct p, {bool manage = false}) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (manage) ...[
            Row(children: [
              const Spacer(),
              _miniIcon(Icons.swap_horiz_rounded, () => _openPicker(context, replace: p)),
              const SizedBox(width: 6),
              _miniIcon(Icons.close_rounded, () => PpCompareStore.instance.remove(p)),
            ]),
            const SizedBox(height: 4),
          ],
          const PpStriped(height: 76, radius: 12),
          const SizedBox(height: 10),
          Text(p.brand, style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(p.name, style: ppJakarta(13.5).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          // rating first - it matters most
          Row(children: [
            const Icon(Icons.star_rounded, size: 15, color: ppCoral),
            const SizedBox(width: 3),
            Text(p.rating.toStringAsFixed(1), style: ppBody(14, color: ppInk, w: FontWeight.w800)),
            const SizedBox(width: 5),
            Flexible(child: Text('${p.reviews}', style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 6),
          Text(p.priceLabel, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(_summaryOf(p), style: ppBody(12, h: 1.45), maxLines: 3, overflow: TextOverflow.ellipsis),
        ]),
      );

  Widget _miniIcon(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
          child: Icon(icon, size: 15, color: ppSoft),
        ),
      );

  // ---- unified comparison table (2 divided columns, one row per attribute) -
  Widget _tRow(String? label, List<Widget> cells, {bool last = false, bool header = false}) => Container(
        decoration: BoxDecoration(
          color: header ? ppPanel : (last ? const Color(0xFFF7F2FC) : Colors.white),
          border: Border(bottom: BorderSide(color: last ? Colors.transparent : const Color(0xFFF3EEF7))),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (label != null) ...[
            ppEyebrow(label, color: last ? ppPurple : ppMuted, spacing: 0.6),
            const SizedBox(height: 8),
          ],
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (var i = 0; i < cells.length; i++) ...[
                if (i > 0) Container(width: 1, color: const Color(0xFFF0EAF6), margin: const EdgeInsets.symmetric(horizontal: 12)),
                Expanded(child: cells[i]),
              ],
            ]),
          ),
        ]),
      );

  Widget _specCell(String label, String value) {
    final free = label.toLowerCase().startsWith('free');
    final rating = label == 'Rating';
    return Text(value, style: ppBody(13, color: rating ? ppCoral : (free ? _green : ppInk), w: (rating || free) ? FontWeight.w700 : FontWeight.w400, h: 1.4));
  }

  Widget _ratedCell(PpProduct p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.star_rounded, size: 16, color: ppCoral), const SizedBox(width: 3), Text(p.rating.toStringAsFixed(1), style: ppJakarta(17))]),
        const SizedBox(height: 2),
        Text('${p.reviews} parents', style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]);

  Widget _lovedCell(PpProduct p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.check_rounded, size: 14, color: _green), const SizedBox(width: 6), Expanded(child: Text(_prosOf(p).first, style: ppBody(12.5, color: ppInk, h: 1.45)))]),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.info_outline, size: 14, color: ppBrown), const SizedBox(width: 6), Expanded(child: Text(_consOf(p).first, style: ppBody(12.5, color: ppSoft, h: 1.45)))]),
      ]);

  Widget _takeCell(PpProduct p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _takeBlock("What's right", _green, _greenBg, Icons.check_rounded, _prosOf(p)),
        const SizedBox(height: 10),
        _takeBlock('Worth knowing', ppBrown, _amberBg, Icons.info_outline, _consOf(p)),
      ]);

  Widget _takeBlock(String title, Color fg, Color bg, IconData icon, List<String> items) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(), style: ppBody(10, color: fg, w: FontWeight.w700).copyWith(letterSpacing: 0.8)),
          const SizedBox(height: 9),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(icon, size: 15, color: fg),
                const SizedBox(width: 9),
                Expanded(child: Text(items[i], style: ppBody(13, color: ppInk, h: 1.5))),
              ]),
            ),
        ]),
      );

  Widget _buyBtn(BuildContext context, PpProduct p, {required bool primary}) => GestureDetector(
        onTap: () => _soon(context),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: primary ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: primary ? null : Border.all(color: ppLine),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Buy ${p.brand}',
                style: ppBody(11.5, color: primary ? Colors.white.withValues(alpha: 0.85) : ppSoft, w: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 1),
            Text(p.priceLabel,
                style: ppBody(14, color: primary ? Colors.white : ppInk, w: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );
}
