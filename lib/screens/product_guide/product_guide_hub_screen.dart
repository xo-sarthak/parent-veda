// =============================================================================
//  Product Guide hub — browse the products worth researching
// -----------------------------------------------------------------------------
//  The Tools-tab entry for the Product Guide (both apps use it identically). A
//  calm, searchable list grouped by category; tapping one opens its full Guide.
//  Only products parents actively research before buying appear here.
// =============================================================================

import 'package:flutter/material.dart';

import 'product_guide_data.dart';
import 'product_guide_screen.dart';
import 'product_guide_style.dart';

class ProductGuideHubScreen extends StatefulWidget {
  const ProductGuideHubScreen({super.key});

  @override
  State<ProductGuideHubScreen> createState() => _ProductGuideHubScreenState();
}

class _ProductGuideHubScreenState extends State<ProductGuideHubScreen> {
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: c);

  void _open(ProductGuide g) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProductGuideScreen(guide: g)));

  List<ProductGuide> get _matches {
    final t = _q.trim().toLowerCase();
    if (t.isEmpty) return const [];
    return kProductGuides.where((g) =>
        g.name.toLowerCase().contains(t) ||
        g.category.toLowerCase().contains(t) ||
        g.brand.toLowerCase().contains(t) ||
        g.bestFor.any((b) => b.toLowerCase().contains(t))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final searching = _q.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: pgBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(Row(children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34, height: 34, alignment: Alignment.center,
                  decoration: const BoxDecoration(color: pgPanel, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, size: 16, color: pgInk),
                ),
              ),
              Expanded(child: Center(child: Text('PRODUCT GUIDE', style: pgEyebrow(pgMuted)))),
              const SizedBox(width: 34),
            ])),
            const SizedBox(height: 22),
            _pad(Text.rich(TextSpan(children: [
              const TextSpan(text: 'Decide with '),
              TextSpan(text: 'confidence.', style: pgSerif(30, c: pgPurple, h: 1.2)),
            ]), style: pgSerif(30, h: 1.2))),
            const SizedBox(height: 10),
            _pad(Text('Honest, evidence-informed guides for the products parents actually research — understand in 10 seconds, go deeper only if you want to.',
                style: pgBody(14, h: 1.55))),
            const SizedBox(height: 20),
            _pad(_searchBar()),
            const SizedBox(height: 22),

            if (searching) ..._searchResults() else ..._browse(),

            const SizedBox(height: 20),
            _pad(Text('Guidance to help you choose — never a substitute for your doctor\'s advice.',
                textAlign: TextAlign.center, style: pgBody(11.5, color: pgMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: pgHair)),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 20, color: pgMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _q = v),
              style: pgBody(15, color: pgInk),
              cursorColor: pgPurple,
              decoration: InputDecoration(
                isDense: true, border: InputBorder.none,
                hintText: 'Search — lotion, diapers, stroller…',
                hintStyle: pgBody(14.5, color: pgMuted),
              ),
            ),
          ),
          if (_q.isNotEmpty)
            GestureDetector(
              onTap: () {
                _search.clear();
                setState(() => _q = '');
                FocusScope.of(context).unfocus();
              },
              child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.close_rounded, size: 18, color: pgMuted)),
            ),
        ]),
      );

  List<Widget> _searchResults() {
    final results = _matches;
    if (results.isEmpty) {
      return [
        _pad(Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: pgPanel, borderRadius: BorderRadius.circular(18)),
          child: Column(children: [
            const Icon(Icons.search_off_rounded, size: 26, color: pgMuted),
            const SizedBox(height: 10),
            Text('No guide for “$_q” yet.', textAlign: TextAlign.center, style: pgBody(14, color: pgInk, w: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('We only guide products worth researching — more are on the way.',
                textAlign: TextAlign.center, style: pgBody(12.5, color: pgMuted, h: 1.5)),
          ]),
        )),
      ];
    }
    return [
      _pad(Text('${results.length} guide${results.length == 1 ? '' : 's'}', style: pgEyebrow(pgPurple))),
      const SizedBox(height: 12),
      for (final g in results) _pad(_row(g)),
    ];
  }

  List<Widget> _browse() {
    final out = <Widget>[];
    for (final cat in pgCategories) {
      out.add(_pad(Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: pgPanel, borderRadius: BorderRadius.circular(999)),
          child: Text(cat, style: pgBody(11.5, color: pgPurple, w: FontWeight.w700)),
        ),
      ])));
      out.add(const SizedBox(height: 10));
      for (final g in pgInCategory(cat)) {
        out.add(_pad(_row(g)));
      }
      out.add(const SizedBox(height: 16));
    }
    return out;
  }

  Widget _row(ProductGuide g) {
    final rc = pgRecoColor(g.reco.tone);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _open(g),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: pgHair)),
          child: Row(children: [
            Container(
              width: 46, height: 46, alignment: Alignment.center,
              decoration: BoxDecoration(color: pgPanel, borderRadius: BorderRadius.circular(13)),
              child: Icon(g.icon, size: 22, color: pgPurple),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(g.name, style: pgTitle(14.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  Container(width: 7, height: 7, decoration: BoxDecoration(color: rc, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Flexible(child: Text(g.reco.label, style: pgBody(11.5, color: rc, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Icon(Icons.star_rounded, size: 12, color: pgPurple),
                  const SizedBox(width: 2),
                  Text(g.rating.parentveda.toStringAsFixed(1), style: pgBody(11.5, color: pgSoft, w: FontWeight.w700)),
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFC7BBD6)),
          ]),
        ),
      ),
    );
  }
}
