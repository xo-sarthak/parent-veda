// =============================================================================
//  PvCompareScreen — two products, side by side, the rows that differ first
// -----------------------------------------------------------------------------
//  Best Buy / lululemon's two-column table with the product heads pinned and
//  a "Shop" button under each. Ours leads with the row a marketplace cannot
//  print — the ParentVeda band — then price, rating, the category's compare
//  facts, and the two honest lists. Rows where both say the same thing sink
//  to the bottom, so the differences are what she reads first.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../services/pv_compare_store.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pv_store_chrome.dart';

class PvCompareScreen extends StatelessWidget {
  const PvCompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: PvCompareStore.instance,
      builder: (context, _) {
        final items = PvCompareStore.instance.items;
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + 10,
                    16,
                    8,
                  ),
                  child: Row(
                    children: [
                      PvRoundIcon(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Compare',
                          style: pvFraunces(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: p.ink1,
                          ),
                        ),
                      ),
                      if (items.isNotEmpty)
                        InkWell(
                          onTap: PvCompareStore.instance.clear,
                          child: Text(
                            'Clear',
                            style: pvManrope(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: p.action,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (items.length < 2)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: PvWell(
                      child: Text(
                        items.isEmpty
                            ? 'Tick "Compare" on two products from one shelf and they line up here.'
                            : 'One picked — tick one more from the same shelf.',
                        style: pvManrope(
                          fontSize: 14,
                          height: 1.5,
                          color: p.ink2,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: _table(context, p, items[0], items[1]),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  Widget _table(BuildContext context, V2Palette p, PvProduct a, PvProduct b) {
    String band(PvProduct x) => x.reco?.band.label ?? '—';
    String rating(PvProduct x) => x.rating > 0
        ? '${x.rating.toStringAsFixed(1)} ★ (${x.reviewCount})'
        : '—';
    String price(PvProduct x) =>
        x.hasPrice ? x.priceLabel : (x.priceNote.isEmpty ? '—' : x.priceNote);
    String ships(PvProduct x) => x.reviewOnly
        ? 'Information only'
        : x.soldHere
        ? 'ParentVeda'
        : (x.retailer.isEmpty ? 'Retailer' : x.retailer);
    String pct(int? v) => v == null ? '—' : '$v%';

    final rows = <(String, String, String)>[
      ('ParentVeda says', band(a), band(b)),
      ('Price', price(a), price(b)),
      ('Rating', rating(a), rating(b)),
      ('Ships from', ships(a), ships(b)),
      if (a.parentsPct != null || b.parentsPct != null)
        ('Would buy again', pct(a.parentsPct), pct(b.parentsPct)),
      if (a.expertsPct != null || b.expertsPct != null)
        ('Experts say buy', pct(a.expertsPct), pct(b.expertsPct)),
      if (a.evidence != null || b.evidence != null)
        ('Evidence', a.evidence?.label ?? '—', b.evidence?.label ?? '—'),
      for (final k in {...a.compare.keys, ...b.compare.keys})
        (k, a.compare[k] ?? '—', b.compare[k] ?? '—'),
      ('Best for', a.bestFor.take(2).join(', '), b.bestFor.take(2).join(', ')),
    ];
    // Differences first, ties last — keep the first row (the band) pinned.
    final head = rows.first;
    final rest = rows.skip(1).toList()
      ..sort((x, y) {
        final dx = x.$2 == x.$3 ? 1 : 0;
        final dy = y.$2 == y.$3 ? 1 : 0;
        return dx.compareTo(dy);
      });

    Widget headCell(PvProduct x) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: PvProductImage(product: x, radius: 14),
          ),
          const SizedBox(height: 8),
          if (x.brand.isNotEmpty)
            Text(
              x.brand.toUpperCase(),
              style: pvManrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: p.ink3,
              ),
            ),
          Text(
            x.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: pvManrope(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: p.ink1,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => pvOpenProduct(context, x),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.ink1, width: 1.2),
                ),
                child: Text(
                  'Open',
                  style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget row((String, String, String) r, {bool first = false}) {
      final same = r.$2 == r.$3;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: kPvLine)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.$1.toUpperCase(),
              style: pvManrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: first ? p.action : p.ink3,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    r.$2,
                    style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: same ? FontWeight.w500 : FontWeight.w700,
                      height: 1.35,
                      color: same ? p.ink2 : p.ink1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    r.$3,
                    style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: same ? FontWeight.w500 : FontWeight.w700,
                      height: 1.35,
                      color: same ? p.ink2 : p.ink1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget lists(
      String title,
      List<String> la,
      List<String> lb,
      IconData icon,
      Color c,
    ) => Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: kPvLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: pvManrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: p.ink3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final l in [la, lb]) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final t in l.take(3))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(icon, size: 13, color: c),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  t,
                                  style: pvManrope(
                                    fontSize: 12.5,
                                    height: 1.35,
                                    color: p.ink2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (l == la) const SizedBox(width: 12),
              ],
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [headCell(a), const SizedBox(width: 12), headCell(b)],
          ),
          const SizedBox(height: 16),
          row(head, first: true),
          for (final r in rest) row(r),
          lists(
            'What\'s good',
            a.goods,
            b.goods,
            Icons.check_rounded,
            pvToneColor(0),
          ),
          lists(
            'Worth considering',
            a.watchOuts,
            b.watchOuts,
            Icons.remove_rounded,
            pvToneColor(1),
          ),
        ],
      ),
    );
  }
}
