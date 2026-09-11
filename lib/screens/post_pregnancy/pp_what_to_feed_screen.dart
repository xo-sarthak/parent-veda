// =============================================================================
//  PpWhatToFeedScreen — what to feed at this age, for his age, in one place
// -----------------------------------------------------------------------------
//  The Feeding rebuild's merge: "What to feed at this age exists as a landing
//  tool, a 2-page library collection, and the 'Is he getting enough?' signs
//  screen. Collapse to one auto-scoped tool; the library links to it."
//
//  ⚠️ ONE SOURCE, THREE THINGS SHOWN. Nothing on this screen is written here:
//
//    * **His day of food** is the Feeding section's own `age_charts` pages for
//      his band (`ppChartPagesForBand`), rendered block for block through
//      `PpBlockView` — the same code path the pages use, so the tool and the
//      section cannot drift.
//    * **The regional and non-veg swaps** are the collection's one all-ages
//      page, rendered after his own.
//    * **The signs he is getting enough** are the `bf_how_often` page's chart
//      card, found by id. It was already structured rows precisely so a tool
//      could read it.
//
//  ⚠️ THE AGE RULE. No chips, no picker: the screen opens on his band and says
//  so once. `PpChartBrowserScreen` (with its chooser) is what this replaces
//  for Feeding; Sleep's old checker route still uses it, unreached.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';
import 'pp_content.dart';
import 'pp_feeding_content.dart' show kPpFeedingBands;
import 'pp_section_registry.dart';
import 'pp_surface_router.dart';

/// The `age_charts` pages that fit a band, in authored order.
///
/// Public so a test can assert every Feeding band has at least one, which is
/// the guarantee this screen rests on.
List<PpPage> ppChartPagesForBand(String band) {
  final section = ppSectionFor('parenting_feeding');
  if (section == null) return const [];
  for (final area in section.areas) {
    if (area.id != 'age_charts') continue;
    return [for (final p in area.pages) if (p.inBand(band)) p];
  }
  return const [];
}

class PpWhatToFeedScreen extends StatelessWidget {
  const PpWhatToFeedScreen({super.key});

  static const String _reassurance =
      'Portions are a guide, not a quota, and no two days look the same. '
      'Appetite swings wildly from day to day and week to week. What matters '
      'is the pattern over a fortnight, not what he ate at lunch.';

  void _open(BuildContext context, String surfaceId) {
    final screen = ppScreenForSurface(surfaceId);
    if (screen == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: surfaceId),
      builder: (_) => screen,
    ));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(
            [ChildProfileStore.instance, V2PaletteStore.instance]),
        builder: (context, _) => _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final child = ChildProfileStore.instance;
    final band = kPpFeedingBands.active;
    final section = ppSectionFor('parenting_feeding')!;

    // His pages, then the all-ages swaps page (the one with no band tag).
    final all = ppChartPagesForBand(band.id);
    final his = [for (final x in all) if (x.bands.isNotEmpty) x];
    final swaps = [for (final x in all) if (x.bands.isEmpty) x];
    final signs = section
        .pageById('bf_how_often')
        ?.blocks
        .whereType<PpChartCard>()
        .firstOrNull;

    Widget heading(String t) => Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 14),
          child: Text(t,
              style: pvFraunces(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -0.45,
                  color: p.ink1)),
        );

    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
          children: [
            ppV3Back(context, p),
            const SizedBox(height: 18),
            Text('What to feed at this age',
                style: pvFraunces(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.4,
                    color: p.ink1)),
            const SizedBox(height: 9),
            Text(
                'His portions, a day of food, the signs he is getting enough, '
                'and the swaps for how your house eats.',
                style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                    color: p.ink2)),
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.child_care_outlined, size: 14, color: p.action),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    'FOR ${child.nameMid.toUpperCase()}  ·  '
                    '${band.label.toUpperCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: p.action)),
              ),
            ]),
            const SizedBox(height: 18),

            // ---- his day of food, page by page ---------------------------
            for (final page in his) ...[
              heading(page.title),
              for (final b in page.orderedBlocks) ...[
                PpBlockView(block: b, onSurface: _open),
                SizedBox(height: b is PpIntro ? 18 : 20),
              ],
            ],

            // ---- the signs he is getting enough --------------------------
            if (signs != null) ...[
              heading('Is he getting enough?'),
              PpBlockView(block: signs),
              const SizedBox(height: 20),
            ],

            // ---- regional and non-veg swaps ------------------------------
            for (final page in swaps) ...[
              heading(page.title),
              for (final b in page.orderedBlocks) ...[
                PpBlockView(block: b, onSurface: _open),
                SizedBox(height: b is PpIntro ? 18 : 20),
              ],
            ],

            Container(
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.line),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.favorite_border_rounded, size: 17, color: p.action),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(_reassurance,
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                          color: p.ink1)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
