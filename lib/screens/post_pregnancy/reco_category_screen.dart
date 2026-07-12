// =============================================================================
//  RecoCategoryScreen - one recommendation category, filtered + age-ranked
// -----------------------------------------------------------------------------
//  A calm vertical list of the picks in a single category (Books, Toys, ...),
//  already sorted by the engine for this child's age + stage. Reached from the
//  Recommendations home's category chips. Category-appropriate FILTERS and
//  sub-filters (driven off each item's facets) narrow the list by type - format,
//  language, theme, skill, material, length, and so on - plus a universal age
//  band. A "Deals of the day" rail closes every category view. Each row opens
//  the full detail page.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_reco_data.dart';
import 'reco_common.dart';
import 'reco_detail_screen.dart';

class RecoCategoryScreen extends StatefulWidget {
  const RecoCategoryScreen({super.key, required this.category});
  final String category;

  @override
  State<RecoCategoryScreen> createState() => _RecoCategoryScreenState();
}

class _RecoCategoryScreenState extends State<RecoCategoryScreen> {
  // dim -> selected values (OR within a dim, AND across dims).
  final Map<String, Set<String>> _selected = {};

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open(RecoItem it) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RecoDetailScreen(item: it)),
      );

  bool _passes(RecoItem it) {
    for (final e in _selected.entries) {
      if (e.value.isEmpty) continue;
      final ok = e.value.any((v) => recoMatchesFacet(it, e.key, v));
      if (!ok) return false;
    }
    return true;
  }

  int get _activeCount => _selected.values.fold(0, (a, s) => a + s.length);

  void _toggle(String dim, String value) => setState(() {
        final set = _selected.putIfAbsent(dim, () => <String>{});
        set.contains(value) ? set.remove(value) : set.add(value);
      });

  void _clear() => setState(_selected.clear);

  String _countLine(int shown, int total) {
    if (shown == total) return '$total ${total == 1 ? 'pick' : 'picks'}, tuned to his stage';
    return '$shown of $total ${total == 1 ? 'pick' : 'picks'} match your filters';
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final pool = topForCategory(category);
    final groups = recoFacetGroupsFor(category, pool);
    final filtered = pool.where(_passes).toList();

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 44),
          children: [
            _pad(ppBack(context, 'Recommendations')),
            const SizedBox(height: 18),
            _pad(Row(children: [
              Icon(recoCatIcon(category), size: 18, color: ppPurple),
              const SizedBox(width: 8),
              ppEyebrow('Recommendations', color: ppPurple),
            ])),
            const SizedBox(height: 10),
            _pad(Text(category, style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 8),
            _pad(Text(
              pool.isEmpty ? 'Fresh picks for this are on the way.' : _countLine(filtered.length, pool.length),
              style: ppBody(13.5, h: 1.5),
            )),
            const SizedBox(height: 18),

            // ---- filters + sub-filters ----
            if (groups.isNotEmpty) ...[
              for (final g in groups) ...[
                _pad(_facetGroup(g)),
                const SizedBox(height: 14),
              ],
              if (_activeCount > 0)
                _pad(GestureDetector(
                  onTap: _clear,
                  behavior: HitTestBehavior.opaque,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.close_rounded, size: 15, color: ppPurple),
                    const SizedBox(width: 6),
                    Text('Clear filters ($_activeCount)', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
                  ]),
                )),
              _pad(ppSectionDivider()),
            ],

            // ---- the list ----
            if (pool.isEmpty)
              _pad(_recoCategoryEmpty())
            else if (filtered.isEmpty)
              _pad(_noMatch())
            else
              _pad(Column(children: [
                for (final r in filtered) RecoRow(item: r, onTap: () => _open(r)),
              ])),

            // ---- deals of the day ----
            const SizedBox(height: 26),
            recoDealsSection(category),
          ],
        ),
      ),
    );
  }

  Widget _facetGroup(RecoFacetGroup g) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ppEyebrow(g.label, color: ppMuted),
        const SizedBox(height: 9),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final o in g.options) _chip(g.dim, o.$1, o.$2)]),
      ]);

  Widget _chip(String dim, String value, String label) {
    final on = _selected[dim]?.contains(value) ?? false;
    return GestureDetector(
      onTap: () => _toggle(dim, value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: on ? ppPurple : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? ppPurple : ppHair),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (on) ...[const Icon(Icons.check_rounded, size: 13, color: Colors.white), const SizedBox(width: 5)],
          Text(label, style: ppBody(12.5, color: on ? Colors.white : ppInk, w: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _noMatch() => Container(
        padding: const EdgeInsets.symmetric(vertical: 34),
        alignment: Alignment.center,
        child: Column(children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
            child: const Icon(Icons.filter_alt_off_outlined, size: 24, color: ppPurple),
          ),
          const SizedBox(height: 14),
          Text('No picks match these filters', textAlign: TextAlign.center, style: ppJakarta(15.5)),
          const SizedBox(height: 8),
          Text('Try removing a filter to see more.', textAlign: TextAlign.center, style: ppBody(12.5, color: ppMuted, h: 1.5)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _clear,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(12)),
              child: Text('Clear filters', style: ppBody(13, color: Colors.white, w: FontWeight.w700)),
            ),
          ),
        ]),
      );
}

Widget _recoCategoryEmpty() => Container(
      padding: const EdgeInsets.symmetric(vertical: 44),
      alignment: Alignment.center,
      child: Column(children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
          child: const Icon(Icons.auto_awesome_outlined, size: 26, color: ppPurple),
        ),
        const SizedBox(height: 16),
        Text('Nothing here just yet', textAlign: TextAlign.center, style: ppJakarta(16)),
        const SizedBox(height: 8),
        Text('We are still curating picks for this stage. Do check back soon.',
            textAlign: TextAlign.center, style: ppBody(13, color: ppMuted, h: 1.5)),
      ]),
    );
