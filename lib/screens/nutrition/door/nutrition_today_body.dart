// =============================================================================
//  Nutrition — the Today tab's tool: plate, ticks, glasses, cravings
// -----------------------------------------------------------------------------
//  2026-09-20, the consistency pass. The day view built earlier that night
//  (`nutrition_door.dart`) stood outside the door language — its own hero,
//  its own scroll, its own foot — and the user called it: "make it
//  consistent, like Scans & tests and Complications". So the day is now the
//  FIRST TAB'S INLINE TOOL on the ordinary five-tab door, the way My scans
//  is the timeline and Complications' first tab is the search: a body, no
//  Scaffold, drawn above the tab's sections (`PvDoorGroup.inlineSurfaceId`).
//
//  Everything the day did, it still does, in the door's own gutters and
//  headings. Recipes moved to their own tab (a rail), the list and the
//  preferences to rows under it, the library to its tabs.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/conditions_data.dart' show ConditionsStore;
import '../../../data/cravings_data.dart';
import '../../../data/diet_chart_facets.dart' show ChartCondition;
import '../../../data/diet_chart_content.dart' show kChartContent;
import '../../../data/nutrition/nutrition_plate.dart';
import '../../../data/nutrition/food_values.dart';
import '../../../data/nutrition_data.dart' show kDietCharts;
import '../../../services/family_profile.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../brackets/hub/hub_intent_art.dart';
import '../../doors/pv_door_chrome.dart';
import '../../v2/v2_palette.dart';
import '../craving_detail_screen.dart';
import 'diet_chart_plan_screen.dart';
import 'meal_sheet.dart';
import 'need_screen.dart';
import 'nutrition_widgets.dart';
import 'preference_sheet.dart';

/// The craving chips: a kind → the craving page it opens.
const List<(String, String, String)> kCravingChips = [
  ('sweet', 'Something sweet', 'sweets'),
  ('sour', 'Sour / imli', 'imli'),
  ('spicy', 'Spicy', 'spicy'),
  ('salty', 'Salty / achar', 'pickle'),
  ('chaat', 'Golgappa / chaat', 'golgappa'),
  ('ice', 'Ice', 'ice_chewing'),
  ('other', 'Something odd', 'non_food'),
];

class NutritionTodayBody extends StatefulWidget {
  const NutritionTodayBody({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  State<NutritionTodayBody> createState() => _NutritionTodayBodyState();
}

class _NutritionTodayBodyState extends State<NutritionTodayBody> {
  // Always today since the chips went (2026-09-20); the getter keeps the shape.
  static const int _dayOffset = 0;

  @override
  void initState() {
    super.initState();
    NutritionDayStore.instance.init();
  }

  DateTime get _date => DateTime.now().add(const Duration(days: _dayOffset));

  static const _kDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _kMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String _dateWord(DateTime d) => '${_kDays[d.weekday - 1]} ${d.day} ${_kMonths[d.month - 1]}';

  ChartCondition? get _condition {
    final c = ConditionsStore.instance;
    if (c.isAddedToJourney('gdm')) return ChartCondition.gestationalDiabetes;
    if (c.isAddedToJourney('anemia')) return ChartCondition.anaemia;
    return null;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          V2PaletteStore.instance,
          NutritionDayStore.instance,
          FamilyProfileStore.instance,
          ConditionsStore.instance,
        ]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final store = NutritionDayStore.instance;
          final day = store.day(_date);
          // A chart she pinned on its own page wins over the one that fits
          // her; a pinned id that no longer exists falls through.
          final pinned = store.pinnedChartId == null
              ? null
              : kDietCharts.where((c) => c.id == store.pinnedChartId && kChartContent.containsKey(c.id)).firstOrNull;
          final plate = plateFor(
            _date,
            week: widget.pregnancy.currentWeek,
            diet: FamilyProfileStore.instance.diet,
            region: store.region,
            condition: _condition,
            chart: pinned,
          );
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ---- the plate ----------------------------------------------
            // ⚠️ "TODAY" ONCE. The tab is called Today; the heading used to say
            // "Your plate today" and a Today / Tomorrow chip row sat under it
            // — three Todays down the screen, and a Tomorrow with no reason
            // to stop there (the user, 2026-09-20: "why not day after
            // tomorrow?"). The heading is the plate, the date is its sub-line,
            // and looking ahead is what the chart's week is for — the "See
            // the week" line under the plate opens every day of it.
            pvDoorPad(nutritionHeading(p, 'Your plate',
                sub: '${_dateWord(_date)}. Swap anything; "not today" is a real answer.')),
            const SizedBox(height: 10),
            // ---- how she eats: the two chips that steer the plate ---------
            //
            // "Eating your way" was a section of its own at the foot of the
            // tab (the user, 2026-09-22: "do we even need this section? …
            // it's just like a filter"). It is not a section; it is the
            // plate's settings, so it sits under the plate's heading, where
            // the thing it changes is. The old section is commented out
            // below, kept for revert. The Recipes tab shows the same two
            // and opens the same sheet.
            pvDoorPad(NutritionPreferenceRow(p: p, store: store)),
            const SizedBox(height: 6),
            // The Today / Tomorrow chip row — retired 2026-09-20, kept for revert:
            // pvDoorPad(Row(children: [
            //   // The chips scale down rather than overflow on a narrow phone
            //   // (or the test's square-glyph font).
            //   Expanded(
            //     child: FittedBox(
            //       fit: BoxFit.scaleDown,
            //       alignment: Alignment.centerLeft,
            //       child: Row(mainAxisSize: MainAxisSize.min, children: [
            //         NutritionChip(
            //             label: 'Today', p: p, selected: _dayOffset == 0, onTap: () => setState(() => _dayOffset = 0)),
            //         const SizedBox(width: 8),
            //         NutritionChip(
            //             label: 'Tomorrow', p: p, selected: _dayOffset == 1, onTap: () => setState(() => _dayOffset = 1)),
            //       ]),
            //     ),
            //   ),
            //   // "The chart" sat here as a text button in the chips' row and
            //   // read as a stray (the user, 2026-09-20). The chart's name is a
            //   // line under the plate now — see `_chartLine`.
            // ])),
            const SizedBox(height: 4),
            pvDoorPad(Column(children: [
              for (var i = 0; i < plate.meals.length; i++)
                Builder(builder: (context) {
                  final m = plate.meals[i];
                  final swapped = day.swaps[m.key];
                  return PlateRow(
                    p: p,
                    slot: m.slot,
                    items: swapped ?? m.items,
                    swapped: swapped != null,
                    skipped: day.skipped.contains(m.key),
                    last: i == plate.meals.length - 1,
                    onTap: () => showMealSheet(context, plate: plate, meal: m, date: _date, pregnancy: widget.pregnancy),
                    // Its own sheet since 2026-09-22 — "clicking on swap …
                    // opens the same screen as if you have clicked on it to
                    // view it" (the user). Kept for revert:
                    //   showMealSheet(…, swapFirst: true)
                    onSwap: () => showSwapSheet(context, plate: plate, meal: m, date: _date),
                  );
                }),
            ])),
            // ---- the day, added up -----------------------------------------
            // What the plate comes to, from what is on it now (swaps in,
            // not-today out). A fact about the food; the reference sits by
            // the ticks, in the word "roughly", and nowhere as a bar.
            Builder(builder: (context) {
              var total = NutritionValues.zero;
              var any = false;
              for (final m in plate.meals) {
                if (day.skipped.contains(m.key)) continue;
                final v = estimateMeal(day.swaps[m.key] ?? m.items);
                if (v == null) continue;
                total = total + v;
                any = true;
              }
              if (!any) return const SizedBox.shrink();
              // The same six tiles a meal gets, for the day — a Σ line sat
              // here for an hour and read as maths (the user, 2026-09-20).
              return Padding(
                padding: const EdgeInsets.only(top: 18),
                child: pvDoorPad(NutritionValuesGrid(p: p, values: total, title: 'Your whole plate, estimated')),
              );
            }),
            const SizedBox(height: 10),
            // ---- the chart this day comes from ----------------------------
            // One quiet line, where the eye lands after the last row: which
            // chart, and the way to the whole week. It replaced a "The chart"
            // text button that sat in the Today / Tomorrow chip row.
            // The chart's name in the heading hand, not a grey line (the user,
            // 2026-09-22: "highlight the from the non-vegetarian chart
            // better"). The drawn calendar mark in a well, the chart as the
            // title, the way to the week under it.
            pvDoorPad(InkWell(
              onTap: () {
                pvCommitFeedback();
                Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'nutrition/chart'),
                  builder: (_) => DietChartPlanScreen(chart: plate.chart, pregnancy: widget.pregnancy),
                ));
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration: BoxDecoration(
                    color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
                child: Row(children: [
                  nutritionMarkWell(p, IntentMark.calendarDay, size: 44, radius: 13),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(pinned != null ? 'YOUR CHART' : 'THIS PLATE FOLLOWS',
                          style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: p.ink3)),
                      const SizedBox(height: 2),
                      Text(plate.chart.title.en,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
                      const SizedBox(height: 2),
                      Text('See the week', style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: p.ink2)),
                    ]),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 20, color: p.ink2),
                ]),
              ),
            )),
            const SizedBox(height: 22),

            // ---- did you get… -------------------------------------------
            pvDoorPad(nutritionHeading(p, 'Did you get…', sub: _needsLine(store))),
            const SizedBox(height: 14),
            // ⚠️ THE REFERENCE MOVED UNDER EACH TICK (2026-09-22). A paragraph
            // spelling out "60 g protein, 27 mg iron, 1000 mg calcium and
            // 30 g fibre (ICMR-NIN)" sat above the row — "text heavy, but
            // essential info" (the user). The same numbers are one small
            // line under each name now: a number, never a bar. Kept for
            // revert:
            //   pvDoorPad(Text(pregnancyReferenceLine(), …)),
            //
            // ⚠️ AND ACROSS THE WIDTH. The row was inside a FittedBox, which
            // hands its child unbounded width — so the Row shrank to its
            // content and the five tiles huddled at the left ("very much
            // left aligned"). Five Expanded cells fill the gutter instead.
            pvDoorPad(Row(children: [
              for (final n in kPlateNeeds)
                Expanded(
                  child: Center(
                    child: NeedTile(
                      p: p,
                      label: n.label,
                      icon: nutritionNeedIcon(n.id),
                      needId: n.id,
                      amount: pregnancyReferenceFor(n.id),
                      ticked: store.ticked(_date, n.id),
                      onTick: () => store.toggleTick(_date, n.id),
                      onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: const RouteSettings(name: 'nutrition/need'),
                        builder: (_) => NeedScreen(need: n, pregnancy: widget.pregnancy),
                      )),
                    ),
                  ),
                ),
            ])),
            const SizedBox(height: 10),
            pvDoorPad(Text('Roughly what a day in pregnancy asks for (ICMR-NIN). Food covers most of it; the tablet covers the rest.',
                style: pvManrope(fontSize: 11.5, height: 1.45, color: p.ink3))),
            const SizedBox(height: 26),

            // ---- water --------------------------------------------------
            pvDoorPad(nutritionHeading(p, 'Water',
                sub: day.water >= NutritionDayStore.kGlasses
                    ? 'Eight glasses. Done for today.'
                    : day.water == 0
                        ? 'Tap a glass each time you finish one.'
                        : '${day.water} of ${NutritionDayStore.kGlasses}. Sip through the day, not all at once.')),
            const SizedBox(height: 14),
            pvDoorPad(GlassesRow(
              p: p,
              filled: day.water,
              total: NutritionDayStore.kGlasses,
              onTap: (i) => store.tapGlass(_date, i),
            )),
            const SizedBox(height: 26),

            // ---- craving? -----------------------------------------------
            ..._cravings(p, store),
            const SizedBox(height: 26),

            // ---- eating your way — FOLDED INTO THE PLATE'S HEADING ---------
            // (2026-09-22, see `NutritionPreferenceRow` above.) Kept for revert:
            // pvDoorPad(nutritionHeading(p, 'Eating your way', sub: 'One row that steers the plate, the swaps and the recipes.')),
            // const SizedBox(height: 12),
            // pvDoorPad(Wrap(spacing: 8, runSpacing: 8, children: [
            //   NutritionChip(label: diet, leading: plate mark, onTap: showPreferenceSheet),
            //   NutritionChip(label: region, leading: compass mark, onTap: showPreferenceSheet(region: true)),
            // ])),
            const SizedBox(height: 8),
          ]);
        },
      );

  String _needsLine(NutritionDayStore store) {
    final ticked = kPlateNeeds.where((n) => store.ticked(_date, n.id)).length;
    if (ticked == 0) return 'Tap what you had today. Hold one to see what counts.';
    if (ticked == kPlateNeeds.length) return 'All five today. That is a good day for the baby.';
    return '$ticked of ${kPlateNeeds.length} today — every one helps.';
  }

  // `nutritionNeedIcon` (nutrition_widgets.dart) — shared with the dish
  // marks since 2026-09-21.

  List<Widget> _cravings(V2Palette p, NutritionDayStore store) {
    final pattern = store.cravingPattern();
    final chipFor = pattern == null ? null : kCravingChips.where((c) => c.$1 == pattern.kind).firstOrNull;
    return [
      pvDoorPad(nutritionHeading(p, 'Craving something?',
          sub: chipFor == null
              ? 'Tap it. Cravings are normal; most have a kind answer.'
              : '${chipFor.$2} has come up ${pattern!.times} times this week — here is what helps.')),
      const SizedBox(height: 12),
      SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
          itemCount: kCravingChips.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final (kind, label, itemId) = kCravingChips[i];
            return NutritionChip(
              label: label,
              p: p,
              onTap: () {
                store.logCraving(kind);
                final item = cravingById(itemId);
                if (item == null) return;
                Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'nutrition/craving'),
                  builder: (_) => CravingDetailScreen(item: item, pregnancy: widget.pregnancy),
                ));
              },
            );
          },
        ),
      ),
    ];
  }
}

/// The two chips that steer the plate, the swaps and the recipes — her diet
/// and her region — with the drawn marks, opening the preference sheet.
/// Under the plate's heading on Today and under "What are you after?" on
/// Recipes, so the customisation is findable where it bites (the user,
/// 2026-09-22: "if I want to change then how do I change it?").
class NutritionPreferenceRow extends StatelessWidget {
  const NutritionPreferenceRow({super.key, required this.p, required this.store});
  final V2Palette p;
  final NutritionDayStore store;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        NutritionChip(
          label: FamilyProfileStore.instance.diet?.label.en ?? 'Diet: not set',
          p: p,
          leading: SizedBox(width: 16, height: 16, child: HubIntentArt(mark: IntentMark.plate, tint: nutritionMarkTint(p))),
          onTap: () => showPreferenceSheet(context),
        ),
        NutritionChip(
          label: store.region == null ? 'Region: any' : plateRegionLabel(store.region!),
          p: p,
          leading: SizedBox(width: 16, height: 16, child: HubIntentArt(mark: IntentMark.compassMark, tint: nutritionMarkTint(p))),
          onTap: () => showPreferenceSheet(context, region: true),
        ),
        Text('Tap to change', style: pvManrope(fontSize: 11.5, color: p.ink3)),
      ]);
}
