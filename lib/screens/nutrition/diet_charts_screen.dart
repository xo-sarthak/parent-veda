// =============================================================================
//  Diet charts — free, viewable and downloadable
// -----------------------------------------------------------------------------
//  Every chart is open. "Viewable" is a real page here (`DietChartScreen`),
//  built from the same guidance the rest of Nutrition already carries rather
//  than a separate document; "downloadable" is a clearly-named stub —
//  `downloadDietChartPlaceholder` in `nutrition_data.dart` — since producing
//  and hosting an actual PDF per chart is a follow-up piece of work, not
//  something to fake convincingly inside a one-pass content build.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/nutrition_data.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';

String _categoryLabel(DietChartCategory c) => switch (c) {
      DietChartCategory.stage => 'By stage',
      DietChartCategory.diet => 'By diet',
      DietChartCategory.condition => 'By condition',
      DietChartCategory.regional => 'Regional',
      DietChartCategory.language => 'In Hindi',
    };

class DietChartsScreen extends StatelessWidget {
  const DietChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final byCategory = <DietChartCategory, List<DietChart>>{};
        for (final c in kDietCharts) {
          byCategory.putIfAbsent(c.category, () => []).add(c);
        }
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text('Diet charts', style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                Text('Every chart here is free to view or download.',
                    style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
                const SizedBox(height: 18),
                for (final entry in byCategory.entries) ...[
                  Text(_categoryLabel(entry.key),
                      style: pvManrope(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: p.ink3)),
                  const SizedBox(height: 10),
                  for (final chart in entry.value) ...[
                    _ChartRow(
                      p: p,
                      chart: chart,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => DietChartScreen(chart: chart),
                      )),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChartRow extends StatelessWidget {
  const _ChartRow({required this.p, required this.chart, required this.onTap});
  final V2Palette p;
  final DietChart chart;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 13, 12, 13),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
          child: Row(children: [
            Icon(Icons.receipt_long_outlined, size: 20, color: p.ink3),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(chart.title.now, style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
                const SizedBox(height: 3),
                Text(chart.description.now,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 12, height: 1.35, color: p.ink3)),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

class DietChartScreen extends StatelessWidget {
  const DietChartScreen({super.key, required this.chart});
  final DietChart chart;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(chart.title.now, style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                Text(chart.description.now, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink1)),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(18)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.description_outlined, size: 18, color: p.ink2),
                      const SizedBox(width: 8),
                      Text('What this chart covers',
                          style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800, color: p.ink1)),
                    ]),
                    const SizedBox(height: 10),
                    Text(
                        'A week of meals built around this chart\'s focus: a breakfast, '
                        'lunch, one or two snacks and a dinner for each day, in the same '
                        'plain, everyday style as the rest of Nutrition.',
                        style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
                  ]),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: p.line, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    onPressed: () {
                      downloadDietChartPlaceholder(chart.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Download starting shortly. It will also be saved in your account.'),
                      ));
                    },
                    icon: Icon(Icons.download_rounded, size: 18, color: p.ink2),
                    label: Text('Download this chart',
                        style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink2)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
