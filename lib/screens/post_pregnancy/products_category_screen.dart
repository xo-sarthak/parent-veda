// =============================================================================
//  ProductsCategoryScreen - Products · category (parenting · S3·category v2)
// -----------------------------------------------------------------------------
//  A curated category (e.g. Sleep): intro + an ⓘ stage-relevance reveal,
//  subcategory filter chips, and its subcategories shown as compare-tickable
//  product grids. Faithful build of Claude Design · S3·category v2. Pushed from
//  Products home; opens a subcategory or a product. No bottom nav.
// =============================================================================

import 'package:flutter/material.dart';
import 'pp_child_profile.dart';

import 'pp_common.dart';
import 'pp_product_widgets.dart';
import 'pp_products_data.dart';
import 'products_subcategory_screen.dart';

class ProductsCategoryScreen extends StatefulWidget {
  const ProductsCategoryScreen({super.key, this.category = 'Sleep'});
  final String category;

  @override
  State<ProductsCategoryScreen> createState() => _ProductsCategoryScreenState();
}

class _ProductsCategoryScreenState extends State<ProductsCategoryScreen> {
  bool _noteOpen = false;
  String _activeSub = 'All';

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  PpCategory get _cat => categoryByName(widget.category);

  String get _intro => widget.category == 'Sleep'
      ? 'Good sleep is built, not bought - but a few well-chosen things genuinely help. At 4 months, when cycles are maturing, the right environment does more than any gadget.'
      : 'A curated ${widget.category.toLowerCase()} shelf - every pick reviewed by ParentVeda, ranked by expert read and verified-mother ratings.';

  String get _note => widget.category == 'Sleep'
      ? "Relevant for ${ChildProfileStore.instance.name} now - he's in the 4-month regression, so soothers and blackout matter most this month."
      : 'These picks are chosen for ${ChildProfileStore.instance.name}\'s stage right now - curated and safety-checked by ParentVeda.';

  @override
  Widget build(BuildContext context) {
    // subs that actually have products, honouring the active filter chip
    final subs = _cat.subs
        .where((s) => productsInSub(_cat.name, s.name).isNotEmpty)
        .where((s) => _activeSub == 'All' || s.name == _activeSub)
        .toList();

    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(top: 58, bottom: 40),
          children: [
            _pad(_breadcrumb(context)),

            // intro
            const SizedBox(height: 16),
            _pad(Row(children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
                child: Icon(_cat.icon, size: 24, color: ppPurple),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(_cat.name, style: ppFraunces(30, h: 1.1))),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _noteOpen = !_noteOpen),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: ppCoralTint, shape: BoxShape.circle),
                  child: const Icon(Icons.info_outline, size: 17, color: ppCoral),
                ),
              ),
            ])),
            const SizedBox(height: 14),
            _pad(Text(_intro, style: ppBody(14))),

            if (_noteOpen) ...[
              const SizedBox(height: 14),
              _pad(Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(16)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.lightbulb_outline_rounded, size: 17, color: ppCoral),
                  const SizedBox(width: 11),
                  Expanded(child: Text(_note, style: ppBody(13, color: ppInk, h: 1.5))),
                ]),
              )),
            ],

            // subcategory filter chips
            const SizedBox(height: 22),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _chip('All'),
                  for (final s in _cat.subs) _chip(s.name),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _pad(Text('Tick Compare on two to see them side by side.', style: ppBody(12))),

            // sections
            for (final s in subs) ...[
              const SizedBox(height: 18),
              _pad(Row(children: [
                Expanded(child: Text(s.name, style: ppJakarta(17), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _openSub(s.name),
                  child: Text('View all →', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
                ),
              ])),
              const SizedBox(height: 14),
              _pad(_grid(productsInSub(_cat.name, s.name))),
            ],

            const SizedBox(height: 24),
            _pad(Text('Every product is curated and reviewed by ParentVeda - named, verified-mother ratings on each.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),

        _topFade(),
        const PpCompareFab(),
      ]),
    );
  }

  Widget _breadcrumb(BuildContext context) => Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Text('Products', style: ppBody(12, color: ppPurple, w: FontWeight.w600)),
        ),
        const SizedBox(width: 6),
        const Text('›', style: TextStyle(color: Color(0xFFC7BBD6))),
        const SizedBox(width: 6),
        Flexible(child: Text(_cat.name, style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]);

  Widget _chip(String label) {
    final on = _activeSub == label;
    return GestureDetector(
      onTap: () => setState(() => _activeSub = label),
      child: Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: ppBody(12, color: on ? Colors.white : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }

  Widget _grid(List<PpProduct> items) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(Padding(
        padding: EdgeInsets.only(top: i == 0 ? 0 : 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: PpProductCard(items[i])),
          const SizedBox(width: 14),
          Expanded(child: i + 1 < items.length ? PpProductCard(items[i + 1]) : const SizedBox()),
        ]),
      ));
    }
    return Column(children: rows);
  }

  Widget _topFade() => Positioned(
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
      );

  void _openSub(String sub) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => ProductsSubcategoryScreen(category: _cat.name, sub: sub)));
}
