// =============================================================================
//  PvShelfScreen — a category's shelf: guidance, filters, the grid, compare
// -----------------------------------------------------------------------------
//  Etsy's listing shape (filter chips → sort → 2-column grid), with the two
//  things a marketplace does not have at the top of a shelf:
//
//    * the 20-second GUIDANCE card — what to look for, what to avoid —
//      authored per category (pregnancy) or per subcategory (parenting);
//    * the recommendation band on the card, "Generally not needed" included.
//
//  Sort defaults to "Recommended" — our band first, then review count — and
//  says so; "Top rated" and price sorts are one tap away, because a shopper
//  who wants the cheapest should not have to argue with us.
//
//  Filters live in a sheet (Etsy, Sephora), not inline: a full sheet with an
//  ink "Show N results" commit. The count updates as she ticks.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../services/cart_store.dart';
import '../../services/pv_catalog_store.dart';
import '../../services/pv_compare_store.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pv_cart_screen.dart';
import 'pv_compare_screen.dart';
import 'pv_store_chrome.dart';

enum PvSort { recommended, topRated, mostReviewed, priceLow, priceHigh }

extension PvSortCopy on PvSort {
  String get label => switch (this) {
    PvSort.recommended => 'Recommended',
    PvSort.topRated => 'Top rated',
    PvSort.mostReviewed => 'Most reviewed',
    PvSort.priceLow => 'Price: low to high',
    PvSort.priceHigh => 'Price: high to low',
  };
}

class PvShelfFilters {
  final Set<String> brands = {};
  int? priceMax;
  double minRating = 0;
  bool recommendedOnly = false;
  bool soldHereOnly = false;

  int get count =>
      brands.length +
      (priceMax != null ? 1 : 0) +
      (minRating > 0 ? 1 : 0) +
      (recommendedOnly ? 1 : 0) +
      (soldHereOnly ? 1 : 0);

  bool pass(PvProduct p) {
    if (brands.isNotEmpty && !brands.contains(p.brand)) return false;
    if (priceMax != null && p.price > priceMax!) return false;
    if (minRating > 0 && p.rating < minRating) return false;
    if (recommendedOnly && !p.recommends) return false;
    if (soldHereOnly && !p.soldHere) return false;
    return true;
  }

  void clear() {
    brands.clear();
    priceMax = null;
    minRating = 0;
    recommendedOnly = false;
    soldHereOnly = false;
  }
}

class PvShelfScreen extends StatefulWidget {
  const PvShelfScreen({super.key, required this.categoryId, this.subId});
  final String categoryId;
  final String? subId;

  @override
  State<PvShelfScreen> createState() => _PvShelfScreenState();
}

class _PvShelfScreenState extends State<PvShelfScreen> {
  late String? _sub = widget.subId;
  PvSort _sort = PvSort.recommended;
  final PvShelfFilters _f = PvShelfFilters();
  bool _guideOpen = false;

  PvCategory get _cat =>
      PvCatalogStore.instance.category(widget.categoryId) ??
      PvCategory(
        id: widget.categoryId,
        stage: PvCatalogStore.instance.all.first.stage,
        name: widget.categoryId,
        hue: 268,
      );

  List<PvProduct> _results() {
    final list = PvCatalogStore.instance
        .inCategory(widget.categoryId, subId: _sub)
        .where(_f.pass)
        .toList();
    switch (_sort) {
      case PvSort.recommended:
        list.sort((a, b) {
          final ra = a.reco?.band.rank ?? 9;
          final rb = b.reco?.band.rank ?? 9;
          if (ra != rb) return ra.compareTo(rb);
          return b.reviewCount.compareTo(a.reviewCount);
        });
      case PvSort.topRated:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case PvSort.mostReviewed:
        list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
      case PvSort.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case PvSort.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final cat = _cat;
    final items = _results();
    final guidance = cat.guidanceFor(_sub);
    return Scaffold(
      backgroundColor: p.ground,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _topBar(p, cat)),
              if (cat.subs.isNotEmpty) SliverToBoxAdapter(child: _subRow(cat)),
              if (guidance != null)
                SliverToBoxAdapter(child: _guidance(p, guidance)),
              SliverToBoxAdapter(child: _toolbar(p, items.length)),
              if (items.isEmpty)
                SliverToBoxAdapter(child: _empty(p))
              else
                // Rows sized to their content, one gap between them — the
                // fixed-ratio grid left a different slack under every card
                // (the user, 2026-09-20: "the spacing is not defined").
                // Kept for revert:
                //   SliverGrid(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //     crossAxisCount: 2, mainAxisSpacing: 18, crossAxisSpacing: 12, childAspectRatio: 0.52), …)
                PvProductGridSliver(products: items, compare: true, heroScope: 'grid'),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          const _CompareBar(),
        ],
      ),
    );
  }

  Widget _topBar(V2Palette p, PvCategory cat) => Padding(
    padding: EdgeInsets.fromLTRB(
      16,
      MediaQuery.of(context).padding.top + 10,
      16,
      6,
    ),
    child: Row(
      children: [
        PvRoundIcon(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cat.stage.shopLabel.toUpperCase(),
                style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: kPvInk,
                ),
              ),
              Text(
                cat.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvFraunces(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: p.ink1,
                ),
              ),
            ],
          ),
        ),
        ListenableBuilder(
          listenable: CartStore.instance,
          builder: (context, _) => PvRoundIcon(
            icon: Icons.shopping_bag_outlined,
            badge: CartStore.instance.count(kProductsCartId),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PvCartScreen(),
                settings: const RouteSettings(name: 'store/cart'),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _subRow(PvCategory cat) => SizedBox(
    height: 48,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      children: [
        PvChip(
          label: 'All',
          selected: _sub == null,
          onTap: () => setState(() => _sub = null),
        ),
        for (final s in cat.subs) ...[
          const SizedBox(width: 6),
          PvChip(
            label: s.shortName,
            selected: _sub == s.id,
            onTap: () => setState(() => _sub = s.id),
          ),
        ],
      ],
    ),
  );

  // ⚠️ RESTYLED 2026-09-20, the user's walk: the tinted well read as "the
  // purple tint background situation" and the green ticks / red crosses as
  // "very outdated … poor on a really good screen". The base UI's rule —
  // white ground, hairlines, ink, brand violet only on the eyebrow — now
  // holds here too: a white card, the eyebrow, the one line, and when open
  // two quiet lists headed LOOK FOR and SKIP with ink marks. The tinted
  // well and the coloured marks are kept for revert in `_guidanceClassic`.
  Widget _guidance(V2Palette p, PvGuidance g) {
    final hasMore = g.lookFor.isNotEmpty || g.avoid.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: InkWell(
        onTap: hasMore ? () => setState(() => _guideOpen = !_guideOpen) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPvLine),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '20-SECOND GUIDE',
                    style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: kPvInk,
                    ),
                  ),
                  const Spacer(),
                  if (hasMore)
                    AnimatedRotation(
                      turns: _guideOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(Icons.expand_more_rounded, size: 20, color: p.ink3),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                g.line,
                style: pvManrope(
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: p.ink1,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: !_guideOpen
                    ? const SizedBox(width: double.infinity)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (g.lookFor.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _guideHead(p, 'Look for'),
                            for (final l in g.lookFor) _mark(p, Icons.check_rounded, p.ink1, l),
                          ],
                          if (g.avoid.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _guideHead(p, 'Skip'),
                            for (final a in g.avoid) _mark(p, Icons.remove_rounded, p.ink3, a),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _guideHead(V2Palette p, String t) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Text(
      t.toUpperCase(),
      style: pvManrope(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
        color: p.ink3,
      ),
    ),
  );

  // The pre-2026-09-20 card: the tinted well, the bulb, coloured marks.
  // Kept for revert; nothing calls it.
  // ignore: unused_element
  Widget _guidanceClassic(V2Palette p, PvGuidance g) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
    child: InkWell(
      onTap: () => setState(() => _guideOpen = !_guideOpen),
      borderRadius: BorderRadius.circular(16),
      // A white card, not a slab (2026-09-29). Kept for revert: PvWell.
      child: PvCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 16, color: kPvInk),
                const SizedBox(width: 7),
                Text(
                  '20-SECOND GUIDE',
                  style: pvManrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: kPvInk),
                ),
                const Spacer(),
                if (g.lookFor.isNotEmpty || g.avoid.isNotEmpty)
                  Icon(_guideOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 20, color: p.ink3),
              ],
            ),
            const SizedBox(height: 6),
            Text(g.line, style: pvManrope(fontSize: 14, height: 1.45, fontWeight: FontWeight.w600, color: p.ink1)),
            if (_guideOpen) ...[
              const SizedBox(height: 10),
              for (final l in g.lookFor) _mark(p, Icons.check_rounded, pvToneColor(0), l),
              for (final a in g.avoid) _mark(p, Icons.close_rounded, pvToneColor(2), a),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _mark(V2Palette p, IconData icon, Color c, String text) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 15, color: c),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2),
          ),
        ),
      ],
    ),
  );

  Widget _toolbar(V2Palette p, int count) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
    child: Row(
      children: [
        PvChip(
          label: _f.count == 0 ? 'Filters' : 'Filters · ${_f.count}',
          leading: Icons.tune_rounded,
          selected: _f.count > 0,
          onTap: _openFilters,
        ),
        const SizedBox(width: 6),
        // "Price: high to low" plus the count is wider than a 390-px phone
        // once Filters has a count of its own — the sort chip shrinks.
        Flexible(
          child: PvChip(
            label: _sort.label,
            leading: Icons.swap_vert_rounded,
            selected: false,
            onTap: _openSort,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: pvManrope(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: p.ink3,
          ),
        ),
      ],
    ),
  );

  Widget _empty(V2Palette p) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
    // A white card, not a slab (2026-09-29). Kept for revert: PvWell.
    child: PvCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nothing matches those filters.',
            style: pvManrope(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: p.ink1,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => setState(_f.clear),
            child: Text(
              'Clear filters',
              style: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: kPvInk,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ---- sheets ------------------------------------------------------------------

  Future<void> _openSort() async {
    final p = pvStorePalette;
    final r = await showModalBottomSheet<PvSort>(
      context: context,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Text(
              'Sort by',
              style: pvFraunces(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: p.ink1,
              ),
            ),
            const SizedBox(height: 8),
            for (final s in PvSort.values)
              ListTile(
                title: Text(
                  s.label,
                  style: pvManrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: p.ink1,
                  ),
                ),
                trailing: s == _sort
                    ? Icon(Icons.check_rounded, color: p.ink1)
                    : null,
                onTap: () => Navigator.of(context).pop(s),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
    if (r != null && mounted) setState(() => _sort = r);
  }

  Future<void> _openFilters() async {
    final p = pvStorePalette;
    final brands =
        PvCatalogStore.instance
            .inCategory(widget.categoryId, subId: _sub)
            .map((e) => e.brand)
            .where((b) => b.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void both(VoidCallback f) {
            setSheet(f);
            setState(() {});
          }

          final n = _results().length;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Filters',
                        style: pvFraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: p.ink1,
                        ),
                      ),
                      const Spacer(),
                      if (_f.count > 0)
                        InkWell(
                          onTap: () => both(_f.clear),
                          child: Text(
                            'Clear all',
                            style: pvManrope(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: kPvInk,
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      PvRoundIcon(
                        icon: Icons.close_rounded,
                        size: 34,
                        onTap: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _label(p, 'ParentVeda'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      PvChip(
                        label: 'Recommended only',
                        leading: Icons.verified_rounded,
                        selected: _f.recommendedOnly,
                        onTap: () => both(
                          () => _f.recommendedOnly = !_f.recommendedOnly,
                        ),
                      ),
                      PvChip(
                        label: 'Ships from ParentVeda',
                        selected: _f.soldHereOnly,
                        onTap: () =>
                            both(() => _f.soldHereOnly = !_f.soldHereOnly),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _label(p, 'Price'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final (l, v) in const [
                        ('Under ₹500', 500),
                        ('Under ₹1,000', 1000),
                        ('Under ₹2,000', 2000),
                        ('Under ₹5,000', 5000),
                      ])
                        PvChip(
                          label: l,
                          selected: _f.priceMax == v,
                          onTap: () => both(
                            () => _f.priceMax = _f.priceMax == v ? null : v,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _label(p, 'Rating'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final (l, v) in const [
                        ('4.5 & up', 4.5),
                        ('4.0 & up', 4.0),
                      ])
                        PvChip(
                          label: l,
                          leading: Icons.star_rounded,
                          selected: _f.minRating == v,
                          onTap: () => both(
                            () => _f.minRating = _f.minRating == v ? 0 : v,
                          ),
                        ),
                    ],
                  ),
                  if (brands.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _label(p, 'Brand'),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final b in brands)
                          PvChip(
                            label: b,
                            selected: _f.brands.contains(b),
                            onTap: () => both(
                              () => _f.brands.contains(b)
                                  ? _f.brands.remove(b)
                                  : _f.brands.add(b),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  PvCommit(
                    label: 'Show $n ${n == 1 ? 'product' : 'products'}',
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _label(V2Palette p, String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t.toUpperCase(),
      style: pvManrope(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: p.ink3,
      ),
    ),
  );
}

/// The compare tray's bar: appears with the first tick, commits with the second.
class _CompareBar extends StatelessWidget {
  const _CompareBar();

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: PvCompareStore.instance,
      builder: (context, _) {
        final tray = PvCompareStore.instance;
        final two = tray.items.length == 2;
        // MOTION: the bar rises from below the edge on the first tick and
        // drops away on clear, rather than appearing.
        return Positioned(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween(
                begin: const Offset(0, 1.6),
                end: Offset.zero,
              ).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: tray.isEmpty
                ? const SizedBox.shrink(key: ValueKey('none'))
                : Container(
                    key: const ValueKey('bar'),
                    padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: kPvLine),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 18,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        for (final it in tray.items) ...[
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: PvProductImage(product: it, radius: 10),
                          ),
                          const SizedBox(width: 6),
                        ],
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            two ? 'Two selected' : 'Pick one more to compare',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pvManrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: p.ink2,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: tray.clear,
                          borderRadius: BorderRadius.circular(999),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: p.ink3,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: two
                              ? () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const PvCompareScreen(),
                                    settings: const RouteSettings(
                                      name: 'store/compare',
                                    ),
                                  ),
                                )
                              : null,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: two ? p.ink1 : p.surfaceAlt,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Compare',
                              style: pvManrope(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: two ? Colors.white : p.ink3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
