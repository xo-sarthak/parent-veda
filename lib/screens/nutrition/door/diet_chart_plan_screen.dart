// =============================================================================
//  A diet chart as a plan — the day strip, the meals with photos, hers to keep
// -----------------------------------------------------------------------------
//  2026-09-20, the Nutrition deep dive. The chart screen was "a week of text
//  in grey boxes at 13pt" (the user, on the phone), and the library does not
//  show a plan that way: Centr, Crouton, Wabi and Cherrypick all show a DAY
//  STRIP and, for the chosen day, MEAL ROWS WITH PHOTOS. Which is exactly what
//  our Today plate already is — a chart day IS a plate — so this screen draws
//  a chart with the plate's own rows, and the two can never drift apart.
//
//  Then the three things a plan owes beyond its days, in the reader's type
//  (16 over 1.55, headings in Newsreader), not in boxes: the swaps that turn
//  three days into a month, what to go easy on, and the doctor's note as a
//  quiet rule-left block where a clinician owns the numbers.
//
//  "Make this my chart" is the customisation that matters at this level: it
//  pins the chart so Today follows it (`NutritionDayStore.pinnedChartId`),
//  which is what "I want the Bengali one" means. Unpinning returns Today to
//  the chart that fits her.
//
//  `DietChartScreen` in diet_charts_screen.dart (the boxed form) is kept for
//  revert; the router opens this one.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/diet_chart_content.dart';
import '../../../data/nutrition/nutrition_photos.dart';
import '../../../data/nutrition/food_values.dart';
import '../../../data/nutrition_data.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../doors/pv_door_chrome.dart';
import '../../v2/v2_palette.dart';
import '../../../localization/app_language.dart' show S;
import '../../../services/diet_chart_pdf.dart';
import 'meal_sheet.dart';
import '../../../data/nutrition/nutrition_plate.dart';
import 'nutrition_widgets.dart';

class DietChartPlanScreen extends StatefulWidget {
  const DietChartPlanScreen({super.key, required this.chart, this.pregnancy});
  final DietChart chart;
  final PregnancyController? pregnancy;

  @override
  State<DietChartPlanScreen> createState() => _DietChartPlanScreenState();
}

class _DietChartPlanScreenState extends State<DietChartPlanScreen> {
  int _day = 0;
  bool _busy = false;

  Future<void> _export(ChartContent content) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await DietChartPdf.build(chart: widget.chart, content: content, lang: S.current);
      if (!mounted) return;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not prepare the file. Please try again on a connection.'),
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
      animation: Listenable.merge([V2PaletteStore.instance, NutritionDayStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final store = NutritionDayStore.instance;
        final mine = store.pinnedChartId == chart.id;
        return PvDoorToolScaffold(
          hue: 104,
          eyebrow: 'Nutrition · Diet chart',
          title: chart.title.en,
          intro: content?.focus.en ?? chart.description.en,
          children: content == null
              ? [pvDoorPad(Text('This chart is still being written.', style: _body(p)))]
              : [
                  // ---- the week at a glance --------------------------------
                  // What "a diet chart" means to her before she has read a
                  // word: the table on the fridge — days across, meals down
                  // (the user, 2026-09-21). One glance says the whole week;
                  // a tap on a day column opens that day's rows under it.
                  _WeekGrid(p: p, content: content, day: _day, onDay: (i) => setState(() => _day = i)),
                  const SizedBox(height: 22),
                  // The Day 1·2·3 chip strip sat here; the week grid's header does
                  // the same job (the user's call, 2026-09-21). Kept for revert:
                  // // ---- the day strip ------------------------------------
                  // SizedBox(
                  //   height: 40,
                  //   child: ListView(
                  //     scrollDirection: Axis.horizontal,
                  //     padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
                  //     children: [
                  //       for (var i = 0; i < content.days.length; i++) ...[
                  //         if (i > 0) const SizedBox(width: 8),
                  //         NutritionChip(
                  //             label: content.days[i].label.en,
                  //             p: p,
                  //             selected: _day == i,
                  //             onTap: () => setState(() => _day = i)),
                  //       ],
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 6),
                  // ---- that day, as the plate draws a day -----------------
                  pvDoorPad(Column(children: [
                    for (var i = 0; i < content.days[_day].meals.length; i++)
                      PlateRow(
                        p: p,
                        slot: content.days[_day].meals[i].meal.en,
                        items: content.days[_day].meals[i].items.en,
                        swapped: false,
                        skipped: false,
                        showSwap: false,
                        photoUrl: nutritionPhotoFor(content.days[_day].meals[i].items.en),
                        // A dish on a chart's day opens the same sheet a dish
                        // on the plate does — the numbers, what is on it, a
                        // recipe where there is one (the user, 2026-09-22:
                        // "I cannot click on them"). Read-only: the sheet's
                        // swap and not-today act on today's plate, so here
                        // they are hidden by passing no date to act on.
                        onTap: () => showMealSheet(context,
                            plate: NutritionPlate(chart: widget.chart, content: content, dayIndex: _day, meals: const []),
                            meal: PlateMeal(
                                slot: content.days[_day].meals[i].meal.en,
                                items: content.days[_day].meals[i].items.en,
                                chartId: widget.chart.id,
                                dayIndex: _day,
                                slotIndex: i),
                            date: DateTime.now(),
                            pregnancy: widget.pregnancy,
                            readOnly: true),
                        onSwap: () {},
                        last: i == content.days[_day].meals.length - 1,
                      ),
                  ])),
                  Builder(builder: (context) {
                    var total = NutritionValues.zero;
                    for (final m in content.days[_day].meals) {
                      total = total + (estimateMeal(m.items.en) ?? NutritionValues.zero);
                    }
                    if (total.isEmpty) return const SizedBox(height: 18);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(kPvDoorGutter, 18, kPvDoorGutter, 22),
                      child: NutritionValuesGrid(p: p, values: total, title: '${content.days[_day].label.en}, estimated'),
                    );
                  }),
                  // ---- make it hers ---------------------------------------
                  pvDoorPad(mine
                      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          OutlinedButton.icon(
                            style: _pill(p),
                            onPressed: () {
                              pvCommitFeedback();
                              store.setPinnedChart(null);
                            },
                            icon: Icon(Icons.check_rounded, size: 18, color: p.ink1),
                            label: Text('Your chart  ·  tap to let Today choose again',
                                style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
                          ),
                        ])
                      : FilledButton(
                          style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
                          onPressed: () {
                            pvCommitFeedback();
                            store.setPinnedChart(chart.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Today follows this chart now.')));
                          },
                          child: const Text('Make this my chart'),
                        )),
                  const SizedBox(height: 6),
                  pvDoorPad(Text(
                      mine
                          ? 'Your plate on the Today tab is drawn from these days.'
                          : 'Your plate on the Today tab will follow these days, with swaps and not-today as usual.',
                      style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink3))),
                  const SizedBox(height: 30),
                  // ---- swaps, go easy on — the reader's lists ------------
                  pvDoorPad(_heading(p, 'Swaps', sub: 'Three days is a pattern, not a prescription. These keep it going.')),
                  const SizedBox(height: 12),
                  pvDoorPad(_bullets(p, [for (final s in content.swaps) s.en])),
                  const SizedBox(height: 26),
                  pvDoorPad(_heading(p, 'Go easy on')),
                  const SizedBox(height: 12),
                  pvDoorPad(_bullets(p, [for (final s in content.limits) s.en])),
                  if (content.doctorNote != null) ...[
                    const SizedBox(height: 26),
                    // The reader's note: a rule at the left, no fill, no box.
                    pvDoorPad(Container(
                      padding: const EdgeInsets.only(left: 14),
                      decoration: BoxDecoration(border: Border(left: BorderSide(color: p.ink1, width: 2))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Your doctor sets the numbers',
                            style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800, color: p.ink1)),
                        const SizedBox(height: 6),
                        Text(content.doctorNote!.en, style: _body(p, color: p.ink2)),
                      ]),
                    )),
                  ],
                  const SizedBox(height: 30),
                  pvDoorPad(OutlinedButton.icon(
                    style: _pill(p),
                    onPressed: _busy ? null : () => _export(content),
                    icon: _busy
                        ? SizedBox(
                            width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: p.ink2))
                        : Icon(Icons.ios_share_rounded, size: 18, color: p.ink2),
                    label: Text(_busy ? 'Preparing…' : 'Save or share this chart',
                        style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink2)),
                  )),
                  const SizedBox(height: 12),
                ],
        );
      },
    );
  }

  ButtonStyle _pill(V2Palette p) => OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: p.line, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      );

  TextStyle _body(V2Palette p, {Color? color}) => pvManrope(fontSize: 16, height: 1.55, color: color ?? p.ink1);

  Widget _heading(V2Palette p, String text, {String? sub}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(text, style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
        if (sub != null) ...[
          const SizedBox(height: 4),
          Text(sub, style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
        ],
      ]);

  Widget _bullets(V2Palette p, List<String> items) => Column(children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                    width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: p.ink2)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(items[i], style: _body(p))),
            ]),
          ),
      ]);
}

/// The week as a table: a column per day, a row per meal slot, the dish's
/// first words in each cell. Scrolls sideways under the gutter; the chosen
/// day's column is ink. Days run to seven where the chart has them.
class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.p, required this.content, required this.day, required this.onDay});
  final V2Palette p;
  final ChartContent content;
  final int day;
  final ValueChanged<int> onDay;

  static const double _col = 104;
  static const double _slotCol = 78;

  @override
  Widget build(BuildContext context) {
    // The slots, in the order the first day names them; a day that lacks a
    // slot shows a dash rather than shifting the row.
    final slots = <String>[];
    for (final d in content.days) {
      for (final m in d.meals) {
        if (!slots.contains(m.meal.en)) slots.add(m.meal.en);
      }
    }
    String cell(ChartDay d, String slot) {
      for (final m in d.meals) {
        if (m.meal.en == slot) {
          final t = m.items.en.split(RegExp('[—–,(]')).first.trim();
          return t;
        }
      }
      return '—';
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // header: the day names, tappable
        Row(children: [
          const SizedBox(width: _slotCol),
          for (var i = 0; i < content.days.length; i++)
            SizedBox(
              width: _col,
              child: InkWell(
                onTap: () {
                  pvCommitFeedback();
                  onDay(i);
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(content.days[i].label.en,
                      textAlign: TextAlign.center,
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: i == day ? p.ink1 : p.ink3,
                          decoration: i == day ? TextDecoration.underline : null)),
                ),
              ),
            ),
        ]),
        for (var r = 0; r < slots.length; r++)
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: p.line))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: _slotCol,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 8, 10),
                  child: Text(slots[r].toUpperCase(),
                      style: pvManrope(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: p.ink3)),
                ),
              ),
              for (var i = 0; i < content.days.length; i++)
                SizedBox(
                  width: _col,
                  child: InkWell(
                    onTap: () {
                      pvCommitFeedback();
                      onDay(i);
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
                      child: Text(cell(content.days[i], slots[r]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 12,
                              height: 1.3,
                              fontWeight: i == day ? FontWeight.w700 : FontWeight.w500,
                              color: i == day ? p.ink1 : p.ink2)),
                    ),
                  ),
                ),
            ]),
          ),
      ]),
    );
  }
}
