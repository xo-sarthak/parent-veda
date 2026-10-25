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
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_tool_chrome.dart';
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';
import 'pp_content.dart';
import 'pp_feeding_content.dart' show kPpFeedingBands;
import 'pp_food_safety.dart';
import 'pp_phases_data.dart' show ppFillChild;
import 'pp_section_registry.dart';
import 'pp_section_screen.dart' show ppOpenPage;
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

  // Opens a link, or says why it can't (S8, 2026-10-25). Was a silent
  // `if (screen == null) return;`.
  void _open(BuildContext context, String surfaceId) =>
      ppPushSurface(context, surfaceId);

  // ⚠️ PAGE LINKS WERE DEAD (tools pass, Food, 2026-10-25). `PpBlockView` got
  // `onSurface` and no `onPage`, so every link to a page (choking safety
  // among them) drew "SOON" and did nothing. They open in the section's own
  // reader now, the way the door does.
  static void _openPage(BuildContext context, String pageId) {
    final section = ppSectionFor('parenting_feeding');
    final page = section?.pageById(pageId);
    if (section == null || page == null) {
      ppPushSurface(context, 'parenting_feeding');
      return;
    }
    ppOpenPage(context, section, page, onSurface: (c, id) => ppPushSurface(c, id));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(
            [ChildProfileStore.instance, V2PaletteStore.instance]),
        builder: (context, _) => _body(context, V2PaletteStore.instance.current),
      );

  // ---- the shared tool shell (tools pass, Food, 2026-10-25) -----------------
  //  Was `ppV3Back` and a ListView (kept below as `_bodyBeforeShell`). Also:
  //   * corrected age picks the band, as Recipes does (a baby born early got
  //     First foods by the birthday);
  //   * the newborn "getting enough" signs show only in the bands its page is
  //     for (milk, first foods): a five-year-old's parent saw them;
  //   * the solids swaps wait until solids start;
  //   * past three, an honest line, because the pages stop at three.
  Widget _body(BuildContext context, V2Palette p) {
    final child = ChildProfileStore.instance;
    final months = child.devAgeInMonths;
    final band = kPpFeedingBands.bandFor(months);
    final section = ppSectionFor('parenting_feeding')!;

    final all = ppChartPagesForBand(band.id);
    final his = [for (final x in all) if (x.bands.isNotEmpty) x];
    final swaps = band.id == 'milk' ? const <PpPage>[] : [for (final x in all) if (x.bands.isEmpty) x];
    final signsPage = section.pageById('bf_how_often');
    final signs = signsPage != null && signsPage.inBand(band.id)
        ? signsPage.blocks.whereType<PpChartCard>().firstOrNull
        : null;

    Widget heading(String t) => pregToolPad(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 14),
          child: Text(t,
              style: pvFraunces(fontSize: 21, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.45, color: p.ink1)),
        ));
    Widget block(PpBlock b) =>
        pregToolPad(PpBlockView(block: b, onSurface: _open, onPage: _openPage));

    return PregToolScaffold(
      hue: 96,
      eyebrow: 'Food',
      mark: IntentMark.plate,
      title: 'What to feed at this age',
      intro: ppFillChild('Portions for his age, a day of food, and the swaps for how your house eats.'),
      children: [
        // Wraps instead of cutting a long name off.
        pregToolPad(Text('FOR ${child.nameMid.toUpperCase()}  ·  ${band.label.toUpperCase()}',
            key: const ValueKey('pp_food_chart_band'),
            style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.action))),
        if (child.correctionWeeks != null && months < 7) ...[
          const SizedBox(height: 8),
          pregToolPad(Text(
              'Shown for ${child.nameMid}\'s corrected age. For a baby born early, your doctor decides when solids start.',
              style: pvManrope(fontSize: 13, height: 1.55, color: p.ink2))),
        ],
        const SizedBox(height: 18),

        // ---- his day of food, page by page ---------------------------------
        for (final page in his) ...[
          heading(page.title),
          for (final b in page.orderedBlocks) ...[
            block(b),
            SizedBox(height: b is PpIntro ? 18 : 20),
          ],
        ],

        // ---- past three: the pages stop at three, so say so ------------------
        if (months >= 36) ...[
          heading('From three years'),
          pregToolPad(Text(
              ppFillChild('He can eat the family\'s food now, in a child-sized portion: a fist of grain, a '
                  'palm of dal or protein, and vegetables or fruit at most meals. Keep whole nuts, popcorn '
                  'and hard round foods cut or crushed until about five.'),
              key: const ValueKey('pp_food_chart_past_three'),
              style: pvManrope(fontSize: 14, height: 1.6, color: p.ink1))),
          const SizedBox(height: 12),
          block(const PpLink('Recipes for this age', surfaceId: 'pp_food', blurb: 'Family dishes, made mild.')),
          const SizedBox(height: 10),
          block(const PpLink('Can my baby eat this?', surfaceId: 'pp_baby_food_check',
              blurb: 'One food at a time, with the reason.')),
          const SizedBox(height: 20),
        ],

        // ---- the signs he is getting enough (newborn months only) -----------
        if (signs != null) ...[
          heading(ppFillChild('Is he getting enough?')),
          block(signs),
          const SizedBox(height: 20),
        ],

        // ---- regional and non-veg swaps (once solids start) ------------------
        for (final page in swaps) ...[
          heading(page.title),
          for (final b in page.orderedBlocks) ...[
            block(b),
            SizedBox(height: b is PpIntro ? 18 : 20),
          ],
        ],

        pregToolPad(Container(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Text(ppFillChild(_reassurance),
              style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.6, color: p.ink1)),
        )),
        const SizedBox(height: 14),
        pregToolPad(const PpFoodDisclaimer()),
      ],
    );
  }

  // Kept for revert (2026-10-25): the page before the shared shell.
  // ignore: unused_element
  Widget _bodyBeforeShell(BuildContext context, V2Palette p) {
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
