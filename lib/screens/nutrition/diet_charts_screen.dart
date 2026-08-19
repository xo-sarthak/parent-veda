// =============================================================================
//  Diet charts — five independent filters, and she starts where she is
// -----------------------------------------------------------------------------
//  ⚠️ REBUILT FROM THE MODEL UP. See `diet_chart_facets.dart` for the reasoning
//  — the short version is that stage / diet / condition / region / language
//  were five mutually-exclusive SHELVES, so a chart could only be one of them
//  and a mother had to abandon four of her five questions to browse. "In Hindi"
//  as a shelf is the clearest symptom: a language is not a kind of diet chart.
//
//  ⚠️ SHE ARRIVES WITH HER OWN TRIMESTER ALREADY SELECTED. Review: "since we
//  know their condition, we should show — say if they are in third trimester —
//  you are here, so this screen is not un-customised."
//
//  Two things make that safe rather than presumptuous, and both are the same
//  rule the report decoder follows one section over:
//
//    · the banner SAYS what has been pre-selected and why, so nothing is
//      hidden happening;
//    · one tap clears it, and every other trimester is on screen the whole
//      time. Personalisation changes what is FIRST, never what exists.
//
//  ⚠️ ENGLISH ONLY FOR NOW.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/diet_chart_facets.dart';
import '../../data/nutrition_data.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';

class DietChartsScreen extends StatefulWidget {
  const DietChartsScreen({super.key, required this.pregnancy});

  final PregnancyController pregnancy;

  @override
  State<DietChartsScreen> createState() => _DietChartsScreenState();
}

class _DietChartsScreenState extends State<DietChartsScreen> {
  late ChartFilter _filter;

  /// What we pre-selected for her, so the banner can name it and the "show
  /// everything" affordance knows what it is undoing.
  ChartStage? _presetStage;

  @override
  void initState() {
    super.initState();
    // ⚠️ SEEDED ONCE, THEN HERS. Read here rather than in `build` so that
    // clearing the chip stays cleared — a preset re-applied on every rebuild
    // is a filter she cannot get out of.
    _presetStage = stageForWeek(widget.pregnancy.currentWeek);
    _filter = ChartFilter(stage: _presetStage);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final week = widget.pregnancy.currentWeek;

        // ⚠️ SURVIVES THE FILTER, THEN RANKS BY SPECIFICITY — it never hides.
        // A chart tagged to her exact trimester should sit above one that
        // works for any, but both are answers and both stay on the page.
        final shown = kDietCharts
            .where((c) => facetsFor(c.id).satisfies(_filter))
            .toList()
          ..sort((a, b) => facetsFor(b.id)
              .specificity(_filter)
              .compareTo(facetsFor(a.id).specificity(_filter)));

        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text('Diet charts',
                style: pvFraunces(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                Text('Every chart here is free to view or download.',
                    style: pvManrope(
                        fontSize: 13.5, height: 1.45, color: p.ink2)),
                const SizedBox(height: 14),

                if (_presetStage != null)
                  _YouAreHere(
                    week: week,
                    stage: _presetStage!,
                    active: _filter.stage == _presetStage,
                    p: p,
                    onShowAll: () =>
                        setState(() => _filter = const ChartFilter()),
                    onRestore: () => setState(
                        () => _filter = ChartFilter(stage: _presetStage)),
                  ),

                const SizedBox(height: 18),

                // ---- the five axes, each its own row ----------------------
                //
                // ⚠️ ONE ROW PER AXIS IS THE WHOLE POINT. A single wrapped
                // blob of nineteen chips is what "they all mix with each
                // other" means in practice: nothing tells her that Vegetarian
                // and Bengali are different KINDS of choice, so selecting one
                // feels like it should deselect the other.
                _AxisRow(
                  label: 'Stage',
                  p: p,
                  chips: [
                    for (final s in ChartStage.values)
                      (s.label.now, _filter.stage == s,
                          () => setState(() => _filter = _filter.withStage(s))),
                  ],
                ),
                _AxisRow(
                  label: 'Diet',
                  p: p,
                  chips: [
                    for (final d in ChartDiet.values)
                      (d.label.now, _filter.diet == d,
                          () => setState(() => _filter = _filter.withDiet(d))),
                  ],
                ),
                _AxisRow(
                  label: 'Condition',
                  p: p,
                  chips: [
                    for (final c in ChartCondition.values)
                      (
                        c.label.now,
                        _filter.condition == c,
                        () => setState(
                            () => _filter = _filter.withCondition(c))
                      ),
                  ],
                ),
                _AxisRow(
                  label: 'Region',
                  p: p,
                  chips: [
                    for (final r in ChartRegion.values)
                      (
                        r.label.now,
                        _filter.region == r,
                        () => setState(() => _filter = _filter.withRegion(r))
                      ),
                  ],
                ),
                _AxisRow(
                  label: 'Language',
                  p: p,
                  chips: [
                    (
                      'Available in Hindi',
                      _filter.inHindi,
                      () => setState(
                          () => _filter = _filter.withHindi(!_filter.inHindi))
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                if (!_filter.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _filter = const ChartFilter()),
                      child: Text('Clear all filters',
                          style: pvManrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: p.action)),
                    ),
                  ),
                const SizedBox(height: 8),

                Text(
                    shown.length == kDietCharts.length
                        ? 'All ${shown.length} charts'
                        : '${shown.length} of ${kDietCharts.length} charts',
                    style: pvManrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: p.ink3)),
                const SizedBox(height: 12),

                if (shown.isEmpty)
                  // ⚠️ AN EMPTY RESULT EXPLAINS ITSELF AND OFFERS THE WAY OUT.
                  // With fourteen charts and five axes some combinations
                  // genuinely have nothing behind them, and a blank screen
                  // there reads as a broken app rather than as an answer.
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                    decoration: BoxDecoration(
                      color: p.surfaceAlt,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'No single chart covers all of that yet. Drop one '
                              'filter and you will usually find two that cover '
                              'it between them.',
                              style: pvManrope(
                                  fontSize: 13.5,
                                  height: 1.5,
                                  color: p.ink2)),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => setState(
                                () => _filter = const ChartFilter()),
                            child: Text('Show everything',
                                style: pvManrope(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: p.action)),
                          ),
                        ]),
                  )
                else
                  for (final chart in shown) ...[
                    _ChartRow(
                      p: p,
                      chart: chart,
                      facets: facetsFor(chart.id),
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              settings: RouteSettings(
                                  name: 'nutrition/chart/${chart.id}'),
                              builder: (_) => DietChartScreen(chart: chart))),
                    ),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The "you are here" line. Names what was pre-selected, and undoes it.
class _YouAreHere extends StatelessWidget {
  const _YouAreHere({
    required this.week,
    required this.stage,
    required this.active,
    required this.p,
    required this.onShowAll,
    required this.onRestore,
  });

  final int week;
  final ChartStage stage;
  final bool active;
  final V2Palette p;
  final VoidCallback onShowAll;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
        decoration: BoxDecoration(
          color: p.action.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.my_location_rounded, size: 16, color: p.action),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  active
                      ? 'You are in week $week — showing ${stage.label.now.toLowerCase()} charts first.'
                      : 'You are in week $week — your ${stage.label.now.toLowerCase()}.',
                  style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: p.ink1)),
            ),
          ]),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: active ? onShowAll : onRestore,
            child: Text(
                active
                    ? 'Show every stage instead'
                    : 'Back to my stage',
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: p.action)),
          ),
        ]),
      );
}

/// One filter axis: a label and its own horizontally-scrolling chip row.
class _AxisRow extends StatelessWidget {
  const _AxisRow({required this.label, required this.p, required this.chips});

  final String label;
  final V2Palette p;

  /// (label, selected, onTap)
  final List<(String, bool, VoidCallback)> chips;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: p.ink3)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final (text, selected, onTap) in chips) ...[
                GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? p.action : p.surface,
                      borderRadius: BorderRadius.circular(999),
                      border:
                          Border.all(color: selected ? p.action : p.line),
                    ),
                    child: Text(text,
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                            color: selected ? p.onAction : p.ink2)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ]),
          ),
        ]),
      );
}

class _ChartRow extends StatelessWidget {
  const _ChartRow(
      {required this.p,
      required this.chart,
      required this.facets,
      required this.onTap});

  final V2Palette p;
  final DietChart chart;
  final ChartFacets facets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // ⚠️ THE TAGS ARE SHOWN ON THE ROW, and that is what makes the filters
    // legible. Without them a filtered list is a shorter list with no visible
    // reason — she cannot tell why these four survived and the other ten did
    // not, which makes the filters feel unreliable even when they are right.
    final tags = <String>[
      if (facets.stage != null) facets.stage!.label.now,
      if (facets.diet != null) facets.diet!.label.now,
      if (facets.condition != null) facets.condition!.label.now,
      if (facets.region != null) facets.region!.label.now,
      if (facets.inHindi) 'हिन्दी',
    ];

    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 13, 12, 13),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.line)),
          child: Row(children: [
            Icon(Icons.receipt_long_outlined, size: 20, color: p.ink3),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chart.title.now,
                        style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: p.ink1)),
                    const SizedBox(height: 3),
                    Text(chart.description.now,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 12, height: 1.35, color: p.ink3)),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final t in tags)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: p.surfaceAlt,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(t,
                                  style: pvManrope(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: p.ink3)),
                            ),
                        ],
                      ),
                    ],
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
            title: Text(chart.title.now,
                style: pvFraunces(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                Text(chart.description.now,
                    style: pvManrope(
                        fontSize: 14, height: 1.55, color: p.ink1)),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: p.surfaceAlt,
                      borderRadius: BorderRadius.circular(18)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.description_outlined,
                              size: 18, color: p.ink2),
                          const SizedBox(width: 8),
                          Text('What this chart covers',
                              style: pvManrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: p.ink1)),
                        ]),
                        const SizedBox(height: 10),
                        Text(
                            'A week of meals built around this chart\'s focus: '
                            'a breakfast, lunch, one or two snacks and a dinner '
                            'for each day, in the same plain, everyday style as '
                            'the rest of Nutrition.',
                            style: pvManrope(
                                fontSize: 13, height: 1.5, color: p.ink2)),
                      ]),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: p.line, width: 1.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                    ),
                    onPressed: () {
                      downloadDietChartPlaceholder(chart.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Download starting shortly. It will also be saved in your account.'),
                      ));
                    },
                    icon: Icon(Icons.download_rounded, size: 18, color: p.ink2),
                    label: Text('Download this chart',
                        style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: p.ink2)),
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
