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
import '../../localization/app_language.dart';
import '../../data/diet_chart_content.dart';
import '../../data/nutrition_data.dart';
import '../../services/diet_chart_pdf.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'door/diet_chart_plan_screen.dart';

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
                      // ⚠️ WAS "Available in Hindi" WHILE NOTHING WAS. The
                      // label is unchanged in meaning and now true, because
                      // what it filters on is derived from the text rather
                      // than typed beside it.
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
                              color: p.ink1)),
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
                                    color: p.ink1)),
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
                              builder: (_) => DietChartPlanScreen(pregnancy: widget.pregnancy, chart: chart))),
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
        // Ink and a hairline since 2026-09-20 (was a violet tint under
        // text — the one thing the base UI forbids).
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.my_location_rounded, size: 16, color: p.ink1),
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
                    color: p.ink1)),
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
                      color: selected ? p.ink1 : p.surface,
                      borderRadius: BorderRadius.circular(999),
                      border:
                          Border.all(color: selected ? p.ink1 : p.line),
                    ),
                    child: Text(text,
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                            color: selected ? p.ground : p.ink2)),
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

// =============================================================================
//  A diet chart, with the chart in it
// -----------------------------------------------------------------------------
//  ⚠️ WHAT WAS HERE BEFORE. The title, the one-line description, a grey box
//  that DESCRIBED the chart — "a breakfast, lunch, one or two snacks and a
//  dinner for each day" — and a Download button that called an empty function
//  and raised a snackbar reading "Download starting shortly. It will also be
//  saved in your account."
//
//  So the section had fifteen charts and not one chart. Every screen rendered,
//  every filter worked, every test passed, and a mother who tapped through
//  three filters to find the right chart arrived at a paragraph telling her
//  what the chart she could not see would have contained.
//
//  ⚠️ WHY IT SURVIVED SO LONG IS THE INTERESTING PART. The grey box read as
//  content. It was well-written, it sat where content sits, and it described
//  something specific. Reviewing this screen, the eye reports "yes, there is a
//  chart here" — the absence only becomes visible if you ask what she would
//  actually eat tomorrow. A placeholder written well enough is harder to spot
//  than no placeholder at all.
//
//  ⚠️ AND THE BUTTON WAS THE WORSE HALF. Not dead — dead teaches her the app is
//  unfinished and she moves on. It CONFIRMED, which sent her to look for a file
//  that never existed and spent a little of the trust that every other
//  confirmation in the app depends on.
// =============================================================================

class DietChartScreen extends StatefulWidget {
  const DietChartScreen({super.key, required this.chart});
  final DietChart chart;

  @override
  State<DietChartScreen> createState() => _DietChartScreenState();
}

class _DietChartScreenState extends State<DietChartScreen> {
  bool _busy = false;

  Future<void> _export(ChartContent content) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await DietChartPdf.build(
        chart: widget.chart,
        content: content,
        // ⚠️ `S.current` IS THE SAME SOURCE `.now` READS. Taking the
        // language from anywhere else would let the PDF come out in a
        // different language from the screen that produced it.
        lang: S.current,
      );
      if (!mounted) return;
      if (bytes == null) {
        // ⚠️ THE ONE CASE WORTH HANDLING LOUDLY. `PdfFontSet` fetches its fonts
        // over the network and falls back to Helvetica, which carries no
        // Devanagari — so an offline Hindi export would be a document full of
        // empty rectangles. She might print that and take it to a doctor.
        // Saying "not right now" is the honest failure; a blank chart is not.
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not prepare the file. Please try again on a '
              'connection.'),
        ));
        return;
      }
      await DietChartPdf.present(chart: widget.chart, bytes: bytes);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chart = widget.chart;
    final content = kChartContent[chart.id];

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
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
              children: [
                Text(chart.description.now,
                    style: pvManrope(
                        fontSize: 14, height: 1.55, color: p.ink1)),
                const SizedBox(height: 20),

                // ⚠️ A CHART WITH NO CONTENT SAYS SO. It cannot happen — a test
                // asserts every chart has an entry — but the branch exists
                // rather than a `!`, because the alternative to this paragraph
                // is a crash on a screen a mother reached looking for food.
                if (content == null)
                  _MissingContent(p: p)
                else ...[
                  Text(content.focus.now,
                      style: pvManrope(
                          fontSize: 13.5, height: 1.6, color: p.ink2)),
                  const SizedBox(height: 22),

                  for (final d in content.days) _DayCard(day: d, p: p),

                  _ChartList(
                    title: 'Swaps',
                    // The line that turns three days into a month, said where
                    // she will look for it rather than in a footnote.
                    subtitle: 'Three days is a pattern, not a prescription. '
                        'These keep it going.',
                    items: content.swaps,
                    p: p,
                  ),
                  _ChartList(
                    title: 'Go easy on',
                    // ⚠️ NOT "AVOID". Almost nothing in an Indian kitchen is
                    // forbidden in pregnancy, and a forbidden list produces the
                    // guilt this whole section exists to reduce.
                    subtitle: null,
                    items: content.limits,
                    p: p,
                  ),

                  if (content.doctorNote != null) ...[
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: p.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: p.line, width: 1),
                      ),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.medical_information_outlined,
                                size: 18, color: p.ink2),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(content.doctorNote!.now,
                                  style: pvManrope(
                                      fontSize: 12.5,
                                      height: 1.55,
                                      color: p.ink2)),
                            ),
                          ]),
                    ),
                  ],

                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: p.line, width: 1.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                      ),
                      onPressed: _busy ? null : () => _export(content),
                      icon: _busy
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: p.ink2))
                          : Icon(Icons.ios_share_rounded,
                              size: 18, color: p.ink2),
                      // ⚠️ "SAVE OR SHARE", NOT "DOWNLOAD". One sheet offers
                      // print, save-as-PDF and send-to-any-app, and on a phone
                      // "download" names the least likely of the three. The
                      // mother who wants it on her fridge, the one who wants it
                      // in her files and the one sending it to her mother-in-law
                      // on WhatsApp all get what they came for.
                      label: Text(_busy ? 'Preparing…' : 'Save or share this chart',
                          style: pvManrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: p.ink2)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One worked day.
class _DayCard extends StatelessWidget {
  const _DayCard({required this.day, required this.p});
  final ChartDay day;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(day.label.now,
                style: pvFraunces(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: p.ink1)),
          ),
          for (final m in day.meals)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Fixed-width meal column so the eye can run down it. She is
                // looking for "lunch", not reading the day as prose.
                SizedBox(
                  width: 86,
                  child: Text(m.meal.now,
                      style: pvManrope(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                          color: p.ink3)),
                ),
                Expanded(
                  child: Text(m.items.now,
                      style: pvManrope(
                          fontSize: 13, height: 1.5, color: p.ink1)),
                ),
              ]),
            ),
          const SizedBox(height: 4),
        ]),
      );
}

class _ChartList extends StatelessWidget {
  const _ChartList(
      {required this.title,
      required this.subtitle,
      required this.items,
      required this.p});
  final String title;
  final String? subtitle;
  final List<LocalizedText> items;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: pvFraunces(
                  fontSize: 16, fontWeight: FontWeight.w600, color: p.ink1)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
          ],
          const SizedBox(height: 10),
          for (final t in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, right: 10),
                  decoration:
                      BoxDecoration(color: p.ink3, shape: BoxShape.circle),
                ),
                Expanded(
                  child: Text(t.now,
                      style: pvManrope(
                          fontSize: 13, height: 1.55, color: p.ink2)),
                ),
              ]),
            ),
          const SizedBox(height: 6),
        ]),
      );
}

/// Unreachable while the test below holds, and kept anyway — see its call site.
class _MissingContent extends StatelessWidget {
  const _MissingContent({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: p.surfaceAlt, borderRadius: BorderRadius.circular(16)),
        child: Text(
            'This chart is still being written. The others in the list are '
            'ready.',
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
      );
}

