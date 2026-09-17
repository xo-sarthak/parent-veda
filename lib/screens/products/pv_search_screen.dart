// =============================================================================
//  PvSearchScreen — one search across all three stages
// -----------------------------------------------------------------------------
//  H&M's search result: `ALL [507] · WOMEN [271] · MEN [87] · BABY [21]`.
//  Search never hides a stage; the chips carry counts so she can see where
//  the answer lives. Opens on her current stage's chip when that stage has
//  hits, otherwise All. Empty query shows the shelves to jump to.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_product.dart';
import '../../services/life_stage_store.dart';
import '../../services/pv_catalog_store.dart';
import '../../theme/pv_fonts.dart';
import 'pv_shelf_screen.dart';
import '../v2/v2_palette.dart';
import 'pv_store_chrome.dart';

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
  LifeStage? _chip;
  bool _chipTouched = false;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final store = PvCatalogStore.instance;
    final q = _ctl.text;
    final res = store.search(q);
    // Default chip: her stage if it has hits, else All.
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
          Padding(
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
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: kPvLine),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, size: 20, color: p.ink2),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _ctl,
                            autofocus: widget.initialQuery.isEmpty,
                            textInputAction: TextInputAction.search,
                            onChanged: (_) => setState(() {}),
                            style: pvManrope(fontSize: 15, color: p.ink1),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Search products, brands, needs',
                              hintStyle: pvManrope(fontSize: 14, color: p.ink3),
                            ),
                          ),
                        ),
                        if (q.isNotEmpty)
                          InkWell(
                            onTap: () => setState(_ctl.clear),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: p.ink3,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (q.trim().isEmpty)
            Expanded(child: _shelves(p, store))
          else ...[
            SizedBox(
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
            Expanded(
              child: shown.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: PvWell(
                        child: Text(
                          res.all.isEmpty
                              ? 'Nothing for “$q” yet. Try a need — "sleep", "rash", "folic" — or a brand.'
                              : 'Nothing in ${chip?.shopLabel ?? 'this stage'} for “$q”. The other chips have ${res.all.length}.',
                          style: pvManrope(
                            fontSize: 13.5,
                            height: 1.5,
                            color: p.ink2,
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.56,
                          ),
                      itemCount: shown.length,
                      itemBuilder: (_, i) =>
                          PvProductCard(product: shown[i], heroScope: 'search'),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _shelves(V2Palette p, PvCatalogStore store) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
    children: [
      for (final s in PvStageCopy.shopStages) ...[
        Text(
          s.shopLabel.toUpperCase(),
          style: pvManrope(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: p.action,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in store.categoriesFor(s))
              PvChip(
                label: c.name,
                selected: false,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PvShelfScreen(categoryId: c.id),
                    settings: RouteSettings(name: 'store/shelf/${c.id}'),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
      ],
    ],
  );
}
