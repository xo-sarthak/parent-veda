// =============================================================================
//  PvSearchScreen — one search across all three stages
// -----------------------------------------------------------------------------
//  H&M's search result: `ALL [507] · WOMEN [271] · MEN [87] · BABY [21]`.
//  Search never hides a stage; the chips carry counts so she can see where
//  the answer lives. Opens on her current stage's chip when that stage has
//  hits, otherwise All.
//
//  REWORKED 2026-09-20 after the user's walk: "when I click on the search
//  bar a screen pops up … the search panel looks very empty … if you are
//  taking us to a new screen, that screen should be worked upon." Two
//  things were wrong and one was missing:
//
//    · TWO PILLS. The home drew a pill; this screen drew a second one at a
//      different x and y, so the eye saw a rectangle appear under the first.
//      Now the pill is ONE widget (`PvSearchPill`) with one geometry on both
//      screens and a `Hero` between them — it slides into place and the
//      keyboard rises under it. Nothing appears; the thing she tapped moves.
//    · AN EMPTY PANEL. It listed category chips per stage and nothing else.
//      Every marketplace opens search on what she is likely to type
//      (Mobbin 2026-09-20 — eBay, UNIQLO, StubHub: recent searches with a
//      clear; On, Gymshark: suggested searches; Gojek: photo category tiles
//      "you might like these"). So: Recent · Try · Shop by category, the
//      last one with the same photo tiles as the home.
//    · AS SHE TYPES (SKIMS): matching categories first as "looking for…"
//      rows, then the results grid with the stage chips.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../services/life_stage_store.dart';
import '../../services/pv_catalog_store.dart';
import '../../services/pv_search_history.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pv_shelf_screen.dart';
import 'pv_store_chrome.dart';

/// Words she is likely to type, per stage — needs, not product names. A
/// starting point, not a chart; every word here returns results today.
List<String> pvSearchTriesFor(LifeStage stage) => switch (stage.shopStage) {
  LifeStage.pregnancy => const [
    'pillow',
    'belly',
    'sleep',
    'nursing',
    'swaddle',
  ],
  LifeStage.parenting => const [
    'sleep',
    'rash',
    'bottle',
    'stroller',
    'thermometer',
  ],
  _ => const ['folic', 'ovulation', 'test', 'book'],
};

class PvSearchScreen extends StatefulWidget {
  const PvSearchScreen({
    super.key,
    required this.stage,
    this.initialQuery = '',
  });
  final LifeStage stage;
  final String initialQuery;

  @override
  State<PvSearchScreen> createState() => _PvSearchScreenState();
}

class _PvSearchScreenState extends State<PvSearchScreen> {
  late final TextEditingController _ctl = TextEditingController(
    text: widget.initialQuery,
  );
  final FocusNode _focus = FocusNode();
  LifeStage? _chip;
  bool _chipTouched = false;

  @override
  void initState() {
    super.initState();
    PvSearchHistory.instance.init();
    // Focus after the Hero has landed, so the keyboard rises under the pill
    // rather than racing it.
    if (widget.initialQuery.isEmpty) {
      Future.delayed(const Duration(milliseconds: 320), () {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _use(String q) {
    _ctl.text = q;
    _ctl.selection = TextSelection.collapsed(offset: q.length);
    PvSearchHistory.instance.add(q);
    setState(() {});
  }

  void _openShelf(PvCategory c) {
    if (_ctl.text.trim().isNotEmpty) PvSearchHistory.instance.add(_ctl.text);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PvShelfScreen(categoryId: c.id),
        settings: RouteSettings(name: 'store/shelf/${c.id}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final store = PvCatalogStore.instance;
    final q = _ctl.text;
    final res = store.search(q);
    final chip = _chipTouched
        ? _chip
        : (res.count(widget.stage.shopStage) > 0
              ? widget.stage.shopStage
              : null);
    final shown = chip == null ? res.all : (res.byStage[chip] ?? const []);
    return Scaffold(
      backgroundColor: p.ground,
      body: Column(
        children: [
          // ---- the one pill --------------------------------------------------------
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 14,
              20,
              6,
            ),
            child: Row(
              children: [
                Expanded(
                  child: PvSearchPill(
                    hero: true,
                    child: Row(
                      children: [
                        // Back lives INSIDE the pill (UNIQLO, SKIMS), so the pill
                        // keeps the home's x and width and the Hero is a slide,
                        // not a shrink.
                        InkWell(
                          onTap: () => Navigator.of(context).maybePop(),
                          borderRadius: BorderRadius.circular(999),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                              color: p.ink1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _ctl,
                            focusNode: _focus,
                            textInputAction: TextInputAction.search,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (v) => PvSearchHistory.instance.add(v),
                            style: pvManrope(fontSize: 14.5, color: p.ink1),
                            cursorColor: p.ink1,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              filled: false,
                              hintText: pvSearchHintFor(widget.stage),
                              hintStyle: pvManrope(fontSize: 14, color: p.ink3),
                            ),
                          ),
                        ),
                        if (q.isNotEmpty)
                          InkWell(
                            onTap: () => setState(_ctl.clear),
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: p.ink3,
                              ),
                            ),
                          )
                        else
                          Icon(Icons.search_rounded, size: 20, color: p.ink2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (q.trim().isEmpty)
            Expanded(child: _panel(p, store))
          else
            Expanded(child: _results(p, store, res, chip, shown, q)),
        ],
      ),
    );
  }

  // ---- before typing: recent · try · shop by category ------------------------------

  Widget _panel(V2Palette p, PvCatalogStore store) => ListenableBuilder(
    listenable: PvSearchHistory.instance,
    builder: (context, _) {
      final recent = PvSearchHistory.instance.recent;
      final tries = pvSearchTriesFor(widget.stage);
      final mine = widget.stage.shopStage;
      final others = PvStageCopy.shopStages.where((s) => s != mine).toList();
      return ListView(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 40),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          if (recent.isNotEmpty) ...[
            _head(
              p,
              'Recent',
              action: 'Clear',
              onAction: PvSearchHistory.instance.clear,
            ),
            for (final r in recent)
              InkWell(
                onTap: () => _use(r),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded, size: 18, color: p.ink3),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          r,
                          style: pvManrope(fontSize: 14.5, color: p.ink1),
                        ),
                      ),
                      InkWell(
                        onTap: () => PvSearchHistory.instance.remove(r),
                        borderRadius: BorderRadius.circular(999),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: p.ink3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          _head(p, recent.isEmpty ? 'Try' : 'Or try'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in tries)
                  PvChip(
                    label: t,
                    leading: Icons.search_rounded,
                    selected: false,
                    onTap: () => _use(t),
                  ),
              ],
            ),
          ),
          _head(p, 'Shop by category'),
          _tiles(p, store.categoriesFor(mine)),
          for (final s in others) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(
                s.shopLabel.toUpperCase(),
                style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink3,
                ),
              ),
            ),
            _tiles(p, store.categoriesFor(s)),
          ],
        ],
      );
    },
  );

  Widget _head(
    V2Palette p,
    String title, {
    String? action,
    VoidCallback? onAction,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: pvFraunces(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: p.ink1,
            ),
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action,
              style: pvManrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: p.ink2,
              ),
            ),
          ),
      ],
    ),
  );

  /// Gojek's "you might like these": the home's photo tiles, four to a row.
  Widget _tiles(V2Palette p, List<PvCategory> cats) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Wrap(
      spacing: 8,
      runSpacing: 14,
      children: [
        for (final c in cats)
          PvCategoryTile(category: c, onTap: () => _openShelf(c)),
      ],
    ),
  );

  // ---- as she types: looking for… · the stage chips · the grid ------------------------

  Widget _results(
    V2Palette p,
    PvCatalogStore store,
    PvSearchResult res,
    LifeStage? chip,
    List<PvProduct> shown,
    String q,
  ) {
    final needle = q.trim().toLowerCase();
    final cats = <PvCategory>[
      for (final s in PvStageCopy.shopStages)
        for (final c in store.categoriesFor(s))
          if (c.name.toLowerCase().contains(needle)) c,
    ].take(3).toList();
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        if (cats.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              children: [
                for (final c in cats)
                  InkWell(
                    onTap: () => _openShelf(c),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 9,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, size: 18, color: p.ink3),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: c.name,
                                    style: pvManrope(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: p.ink1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '  in ${c.stage.shopLabel}',
                                    style: pvManrope(
                                      fontSize: 12.5,
                                      color: p.ink3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            Icons.north_west_rounded,
                            size: 16,
                            color: p.ink3,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              children: [
                PvChip(
                  label: 'All',
                  count: res.all.length,
                  selected: chip == null,
                  onTap: () => setState(() {
                    _chip = null;
                    _chipTouched = true;
                  }),
                ),
                for (final s in PvStageCopy.shopStages) ...[
                  const SizedBox(width: 6),
                  PvChip(
                    label: s.shopLabel,
                    count: res.count(s),
                    selected: chip == s,
                    onTap: () => setState(() {
                      _chip = s;
                      _chipTouched = true;
                    }),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (shown.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: PvWell(
                child: Text(
                  res.all.isEmpty
                      ? 'Nothing for “$q” yet. Try a need — "sleep", "rash", "folic" — or a brand.'
                      : 'Nothing in ${chip?.shopLabel ?? 'this stage'} for “$q”. The other chips have ${res.all.length}.',
                  style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2),
                ),
              ),
            ),
          )
        else
          PvProductGridSliver(
            products: shown,
            heroScope: 'search',
            onOpen: (_) => PvSearchHistory.instance.add(q),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}
