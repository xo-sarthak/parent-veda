// =============================================================================
//  Every diet chart — the browser
// -----------------------------------------------------------------------------
//  2026-09-20. "Browse every chart" opened a filter form: five rows of
//  dropdown-ish pills inside an 18pt margin, results as text rows — "a very
//  generic static screen … looks bad" (the user). The library's browse
//  screens do not filter with a form: Tempo's Training plans, Blue Apron and
//  HelloFresh all put ONE OR TWO CHIP ROWS over FULL-WIDTH CARDS, each card
//  an image, a title, one line and three facts, with facet tags the way
//  Blinkit tags a dish. So:
//
//    hero (the tool scaffold) → two chip rails that run edge to edge
//    (diet · stage, then condition · region; a tap narrows, a second tap
//    clears) → the charts as cards: a real dish from the chart's own first
//    day as the picture, the title, the focus line, "3 days · Vegetarian ·
//    Second trimester", and a mark on the chart she pinned. Tap → the plan.
//
//  The door's "Ready-made diet charts" rail shows the first eight and its
//  heading's "View all" opens this; the old "Browse every chart" tool card
//  is retired (kept for revert in pv_door_nutrition.dart), as is
//  `DietChartsScreen` (diet_charts_screen.dart), unreached.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/diet_chart_content.dart';
import '../../../data/diet_chart_facets.dart';
import '../../../data/nutrition/nutrition_photos.dart';
import '../../../data/nutrition_data.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../doors/pv_door_chrome.dart';
import '../../v2/v2_palette.dart';
import 'diet_chart_plan_screen.dart';
import 'nutrition_widgets.dart';

class DietChartBrowseScreen extends StatefulWidget {
  const DietChartBrowseScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  State<DietChartBrowseScreen> createState() => _DietChartBrowseScreenState();
}

class _DietChartBrowseScreenState extends State<DietChartBrowseScreen> {
  ChartDiet? _diet;
  ChartStage? _stage;
  ChartCondition? _condition;
  ChartRegion? _region;

  List<DietChart> get _charts => [
        for (final c in kDietCharts)
          if (facetsFor(c.id).satisfies(
              ChartFilter(diet: _diet, stage: _stage, condition: _condition, region: _region)))
            c
      ];

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([V2PaletteStore.instance, NutritionDayStore.instance]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final charts = _charts;
          final pinned = NutritionDayStore.instance.pinnedChartId;
          return PvDoorToolScaffold(
            hue: 104,
            eyebrow: 'Nutrition · Diet charts',
            title: 'Every chart',
            intro: 'Nineteen ready-made weeks. Narrow by how you eat and where you are; '
                'tap one to see its days and make it yours.',
            children: [
              // ---- diet · stage ------------------------------------------
              _rail(p, [
                for (final d in ChartDiet.values)
                  (d.label.en, _diet == d, () => setState(() => _diet = _diet == d ? null : d)),
                for (final s in ChartStage.values)
                  (s.label.en, _stage == s, () => setState(() => _stage = _stage == s ? null : s)),
              ]),
              const SizedBox(height: 8),
              // ---- condition · region -------------------------------------
              _rail(p, [
                for (final c in ChartCondition.values)
                  (c.label.en, _condition == c, () => setState(() => _condition = _condition == c ? null : c)),
                for (final r in ChartRegion.values)
                  (r.label.en, _region == r, () => setState(() => _region = _region == r ? null : r)),
              ]),
              const SizedBox(height: 18),
              pvDoorPad(Text(
                  charts.length == kDietCharts.length
                      ? 'All ${charts.length} charts'
                      : charts.isEmpty
                          ? 'No chart fits all of that yet'
                          : '${charts.length} of ${kDietCharts.length} charts',
                  style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink3))),
              const SizedBox(height: 10),
              if (charts.isEmpty)
                pvDoorPad(Text(
                    'Loosen one of the chips — a regional chart is rarely also a condition chart. '
                    'The Full month Indian chart fits everyone.',
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
              else
                for (final (i, url) in _photosFor(charts).indexed) ...[
                  pvDoorPad(_ChartCard(
                    p: p,
                    chart: charts[i],
                    url: url,
                    mine: charts[i].id == pinned,
                    onTap: () {
                      pvCommitFeedback();
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: const RouteSettings(name: 'nutrition/chart'),
                        builder: (_) => DietChartPlanScreen(chart: charts[i], pregnancy: widget.pregnancy),
                      ));
                    },
                  )),
                  if (i < charts.length - 1) const SizedBox(height: 12),
                ],
              const SizedBox(height: 12),
            ],
          );
        },
      );

  /// One photo per card, and no two cards the same: each chart takes the
  /// first dish on its days that no earlier card has used (three charts
  /// open with poha, and three poha cards in a row read as one chart).
  List<String?> _photosFor(List<DietChart> charts) {
    final used = <String>{};
    final out = <String?>[];
    for (final c in charts) {
      String? pick;
      String? first;
      final content = kChartContent[c.id];
      if (content != null) {
        for (final d in content.days) {
          for (final m in d.meals) {
            final u = nutritionPhotoFor(m.items.en);
            if (u == null) continue;
            first ??= u;
            if (!used.contains(u)) {
              pick = u;
              break;
            }
          }
          if (pick != null) break;
        }
      }
      pick ??= first;
      if (pick != null) used.add(pick);
      out.add(pick);
    }
    return out;
  }

  /// A chip rail that runs edge to edge — the chips scroll under the gutter,
  /// never against a wall.
  Widget _rail(V2Palette p, List<(String, bool, VoidCallback)> chips) => SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
          itemCount: chips.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) => NutritionChip(label: chips[i].$1, p: p, selected: chips[i].$2, onTap: chips[i].$3),
        ),
      );
}

/// One chart: its own first-day dish as the picture, the title, the focus
/// line, three facts. Tempo's plan card, Blinkit's tags, in the base UI.
class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.p, required this.chart, required this.url, required this.mine, required this.onTap});
  final V2Palette p;
  final DietChart chart;
  final String? url;
  final bool mine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = kChartContent[chart.id];
    final f = facetsFor(chart.id);
    final facts = [
      if (content != null) '${content.days.length} days',
      if (f.diet case final d?) d.label.en,
      if (f.stage case final s?) s.label.en,
      if (f.condition case final c?) c.label.en,
      if (f.region case final r?) r.label.en,
    ];
    return PvPress(
      child: Material(
        color: p.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18), side: BorderSide(color: mine ? p.ink1 : p.line, width: mine ? 1.5 : 1)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(fit: StackFit.expand, children: [
                NutritionPhoto(url: url, p: p, icon: Icons.calendar_view_week_outlined, iconSize: 36),
                if (mine)
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: p.ink1, borderRadius: BorderRadius.circular(999)),
                      child: Text('Your chart',
                          style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, color: p.ground)),
                    ),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(chart.title.en,
                    style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
                const SizedBox(height: 6),
                Text(content?.focus.en ?? chart.description.en,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
                const SizedBox(height: 10),
                Text(facts.join('  ·  '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: p.ink3)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
