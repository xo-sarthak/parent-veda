// =============================================================================
//  Nutrition — the door, as a day
// -----------------------------------------------------------------------------
//  2026-09-20. The home tile "Nutrition" opens this. Before it, the door was
//  five tabs of card rails over the same nineteen charts, seventeen recipes
//  and twelve guides — a catalogue. Every one of those still exists and is
//  still reachable from here; what changed is that the door now opens on
//  TODAY (research in MOBBIN-DISCOVERY §12, the proposal in STILL-OPEN §69):
//
//    hero        "What's on your plate today" · week · the chart it came from
//    the plate   her meals for today as photo rows, each with Swap and
//                "not today"; tomorrow a chip away
//    did you get five ticks — iron, calcium, protein, folate, fibre — a
//                ring each, a soft burst on tick, foods behind a long press
//    water       eight glasses to tap
//    craving?    chips; a tap logs it and opens the craving's page
//    recipes     hers (diet respected), a Cook button on each
//    your list   the shopping list, N items
//    eating your way   diet · region, the one row that steers everything
//    the library charts · fasting · nutrients — what used to be the door
//    dieticians  the paid tiers, unchanged
//
//  For a pregnant reader who may be nauseous, tired, or simply not hungry:
//  nothing here is red, nothing counts a miss, "not today" is one tap, and
//  the only numbers are glasses.
//
//  Is it safe? sits next door and is not duplicated: the old "Can I eat
//  this?" tab is retired; a food question here points there (§69.2).
// =============================================================================

import 'package:flutter/material.dart';

import '../../../data/cravings_data.dart';
import '../../../data/diet_chart_facets.dart' show ChartCondition;
import '../../../data/nutrition/nutrition_photos.dart';
import '../../../data/nutrition/nutrition_plate.dart';
import '../../../data/nutrition_data.dart';
import '../../../data/conditions_data.dart' show ConditionsStore;
import '../../../services/bracket_resolver.dart';
import '../../../services/family_profile.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../../data/doors/pv_door_nutrition.dart' show kNutritionDoor;
import '../../can_i_screen.dart' show CanIScreen;
import '../../doors/pv_door_screen.dart' show PvDoorScreen;
import '../../doors/pv_door_chrome.dart';
import '../../v2/v2_palette.dart';
import '../../v2/v3_hero_field.dart';
import '../craving_detail_screen.dart';
import '../diet_charts_screen.dart';
import '../fasting_screen.dart';
import '../nutrients_screen.dart';
import '../nutrition_stage_screen.dart' show ExpertOptionsBlock;
import 'meal_sheet.dart';
import 'need_screen.dart';
import 'nutrition_widgets.dart';
import 'preference_sheet.dart';
import 'recipe_cook_screen.dart';
import 'recipes_screen.dart';
import 'shopping_list_screen.dart';

const String kNutritionBracketId = 'pregnancy_nutrition';
const String kNutritionDoorRoute = 'bracket/scans'; // the FAB reads it; unchanged from every door

/// Which door the Nutrition tile opens. TRUE = this (the day). FALSE = the
/// five-tab `PvDoorScreen` over `kNutritionDoor`, kept for revert.
const bool kNutritionDoorAsDay = false; // the day is the door's first tab now (2026-09-20)

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

class NutritionDoorScreen extends StatefulWidget {
  const NutritionDoorScreen({super.key, required this.pregnancy});
  final PregnancyController pregnancy;

  @override
  State<NutritionDoorScreen> createState() => _NutritionDoorScreenState();
}

class _NutritionDoorScreenState extends State<NutritionDoorScreen> {
  /// 0 = today, 1 = tomorrow. Yesterday is not offered: a plate she did not
  /// eat is not something to look back at.
  int _dayOffset = 0;

  @override
  void initState() {
    super.initState();
    NutritionDayStore.instance.init();
  }

  DateTime get _date => DateTime.now().add(Duration(days: _dayOffset));

  ChartCondition? get _condition {
    final c = ConditionsStore.instance;
    if (c.isAddedToJourney('gdm')) return ChartCondition.gestationalDiabetes;
    if (c.isAddedToJourney('anemia')) return ChartCondition.anaemia;
    return null;
  }

  NutritionPlate _plate() => plateFor(
        _date,
        week: widget.pregnancy.currentWeek,
        diet: FamilyProfileStore.instance.diet,
        region: NutritionDayStore.instance.region,
        condition: _condition,
      );

  @override
  Widget build(BuildContext context) {
    final bracket = bracketById(kNutritionBracketId);
    final hue = bracket?.hue ?? 104;
    return AnimatedBuilder(
      animation: Listenable.merge([
        V2PaletteStore.instance,
        NutritionDayStore.instance,
        FamilyProfileStore.instance,
        ConditionsStore.instance,
        widget.pregnancy,
      ]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final tint = v2BlockTint(hue, p);
        final plate = _plate();
        final store = NutritionDayStore.instance;
        final day = store.day(_date);
        final diet = FamilyProfileStore.instance.diet;
        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(children: [
            Positioned.fill(child: V3HeroField(accent: tint, ground: p.ground, variant: 1, chroma: v3FieldChroma(hue))),
            ListView(
              padding: EdgeInsets.zero,
              children: [
                _hero(p, plate),
                PvDoorSheet(p: p, minHeightFactor: 0.8, children: [
                  const SizedBox(height: 22),
                  ..._plateSection(p, plate, day),
                  const SizedBox(height: 28),
                  ..._needsSection(p),
                  const SizedBox(height: 28),
                  ..._waterSection(p, day),
                  const SizedBox(height: 28),
                  ..._cravingSection(p),
                  const SizedBox(height: 28),
                  ..._recipesSection(p, diet),
                  const SizedBox(height: 28),
                  ..._listSection(p),
                  const SizedBox(height: 28),
                  ..._preferenceSection(p, diet),
                  const SizedBox(height: 28),
                  ..._librarySection(p),
                  const SizedBox(height: 28),
                  // The block brings its own heading ("Want a real person
                  // on this?"); a second one above it read twice on the phone.
                  const ExpertOptionsBlock(),
                  const SizedBox(height: 24),
                  pvDoorPad(PvDoorDisclaimer(
                      p: p,
                      text: 'General guidance for a healthy pregnancy, not a prescription. If you are managing '
                          'a condition, your doctor\'s or dietician\'s plan comes first.')),
                ]),
              ],
            ),
          ]),
        );
      },
    );
  }

  // ---- hero -----------------------------------------------------------------

  Widget _hero(V2Palette p, NutritionPlate plate) {
    final week = widget.pregnancy.currentWeek;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 22, 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Material(
            color: Colors.white.withValues(alpha: 0.55),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: SizedBox(width: 38, height: 38, child: Icon(Icons.arrow_back_rounded, size: 19, color: p.ink1)),
            ),
          ),
          const SizedBox(height: 18),
          Text('NUTRITION', style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.ink2)),
          const SizedBox(height: 8),
          Text(_dayOffset == 0 ? 'What\'s on your plate today' : 'Tomorrow\'s plate',
              style: pvFraunces(fontSize: 27, fontWeight: FontWeight.w600, height: 1.15, letterSpacing: -0.6, color: p.ink1)),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text('Week $week · ${plate.chart.title.en}. ${plate.content.focus.en}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2)),
          ),
          const SizedBox(height: 14),
          Row(children: [
            NutritionChip(label: 'Today', p: p, selected: _dayOffset == 0, onTap: () => setState(() => _dayOffset = 0)),
            const SizedBox(width: 8),
            NutritionChip(label: 'Tomorrow', p: p, selected: _dayOffset == 1, onTap: () => setState(() => _dayOffset = 1)),
          ]),
        ]),
      ),
    );
  }

  // ---- the plate ------------------------------------------------------------

  List<Widget> _plateSection(V2Palette p, NutritionPlate plate, NutritionDay day) => [
        pvDoorPad(nutritionHeading(p, 'Your plate',
            sub: 'Swap anything. Skip anything. "Not today" is a real answer.',
            trailing: TextButton(
              onPressed: () {
                pvCommitFeedback();
                Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'nutrition/chart'),
                  builder: (_) => DietChartScreen(chart: plate.chart),
                ));
              },
              child: Text('The chart', style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
            ))),
        const SizedBox(height: 6),
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
                onTap: () => showMealSheet(context, plate: plate, meal: m, date: _date),
                onSwap: () => showMealSheet(context, plate: plate, meal: m, date: _date, swapFirst: true),
              );
            }),
        ])),
      ];

  // ---- the needs ------------------------------------------------------------

  List<Widget> _needsSection(V2Palette p) {
    final store = NutritionDayStore.instance;
    final ticked = kPlateNeeds.where((n) => store.ticked(_date, n.id)).length;
    final line = ticked == 0
        ? 'Tap what you had today. Hold one to see what counts.'
        : ticked == kPlateNeeds.length
            ? 'All five today. That\'s a good day for your baby.'
            : '$ticked of ${kPlateNeeds.length} today. Every one helps.';
    return [
      pvDoorPad(nutritionHeading(p, 'Did you get…', sub: line)),
      const SizedBox(height: 16),
      pvDoorPad(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final n in kPlateNeeds)
            NeedTile(
              p: p,
              label: n.label,
              icon: _needIcon(n.id),
              ticked: store.ticked(_date, n.id),
              onTick: () => store.toggleTick(_date, n.id),
              onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'nutrition/need'),
                builder: (_) => NeedScreen(need: n, pregnancy: widget.pregnancy),
              )),
            ),
        ],
      )),
      if (_dayOffset == 0 && store.daysTicked('iron') >= 3) ...[
        const SizedBox(height: 12),
        pvDoorPad(Text('Iron on ${store.daysTicked('iron')} of the last seven days.',
            style: pvManrope(fontSize: 12.5, color: p.ink3))),
      ],
    ];
  }

  IconData _needIcon(String id) => switch (id) {
        'iron' => Icons.spa_outlined,
        'calcium' => Icons.local_drink_outlined,
        'protein' => Icons.egg_alt_outlined,
        'folic_acid' => Icons.eco_outlined,
        _ => Icons.grass_outlined,
      };

  // ---- water ----------------------------------------------------------------

  List<Widget> _waterSection(V2Palette p, NutritionDay day) => [
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
          onTap: (i) => NutritionDayStore.instance.tapGlass(_date, i),
        )),
      ];

  // ---- cravings -------------------------------------------------------------

  List<Widget> _cravingSection(V2Palette p) {
    final pattern = NutritionDayStore.instance.cravingPattern();
    final chipFor = pattern == null ? null : kCravingChips.where((c) => c.$1 == pattern.kind).firstOrNull;
    return [
      pvDoorPad(nutritionHeading(p, 'Craving something?',
          sub: chipFor == null
              ? 'Tap it. Cravings are normal, and most have a kind answer.'
              : '${chipFor.$2} has come up ${pattern!.times} times this week. Here\'s what helps.')),
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
                NutritionDayStore.instance.logCraving(kind);
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

  // ---- recipes --------------------------------------------------------------

  List<Widget> _recipesSection(V2Palette p, DietPreference? diet) {
    final store = NutritionDayStore.instance;
    // Hers, and the ones that feed an unticked need first.
    final unticked = kPlateNeeds.where((n) => !store.ticked(_date, n.id)).map((n) => n.recipeTag).toSet();
    final mine = [for (final r in kRecipes) if (recipeSuits(r, diet)) r]
      ..sort((a, b) {
        final ah = a.tags.any(unticked.contains) ? 0 : 1;
        final bh = b.tags.any(unticked.contains) ? 0 : 1;
        return ah.compareTo(bh);
      });
    return [
      pvDoorPad(nutritionHeading(p, 'Recipes for you',
          sub: diet == null ? 'From an everyday Indian kitchen.' : '${diet.label.en}, from an everyday Indian kitchen.',
          trailing: TextButton(
            onPressed: () {
              pvCommitFeedback();
              Navigator.of(context).push(MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'nutrition/recipes'),
                builder: (_) => RecipesScreen(pregnancy: widget.pregnancy),
              ));
            },
            child: Text('All ${mine.length}', style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
          ))),
      const SizedBox(height: 12),
      SizedBox(
        height: 196,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: kPvDoorGutter),
          itemCount: mine.length.clamp(0, 8),
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) => RecipeCard(
            p: p,
            recipeId: mine[i].id,
                  minutes: mine[i].minutes,
                  name: mine[i].name.en,
            line: mine[i].whyNow.en,
            url: nutritionRecipePhoto(mine[i].id, mine[i].name.en),
            onTap: () => openRecipe(context, mine[i], widget.pregnancy),
          ),
        ),
      ),
    ];
  }

  // ---- the list -------------------------------------------------------------

  List<Widget> _listSection(V2Palette p) {
    final items = NutritionDayStore.instance.shopping;
    final left = items.where((s) => !s.done).length;
    return [
      pvDoorPad(PvPress(
        child: Material(
          color: p.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: p.line)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              pvCommitFeedback();
              Navigator.of(context).push(MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'nutrition/list'),
                builder: (_) => const ShoppingListScreen(),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
              child: Row(children: [
                Icon(Icons.shopping_basket_outlined, size: 22, color: p.ink1),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(items.isEmpty ? 'Your list' : 'Your list  ·  $left to buy',
                        style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                    const SizedBox(height: 2),
                    Text(
                        items.isEmpty
                            ? 'Add a recipe\'s ingredients and they wait here for the shop.'
                            : 'From ${items.map((s) => s.recipeId).toSet().length} recipe${items.map((s) => s.recipeId).toSet().length == 1 ? '' : 's'}.',
                        style: pvManrope(fontSize: 12.5, color: p.ink2)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
              ]),
            ),
          ),
        ),
      )),
    ];
  }

  // ---- preference -----------------------------------------------------------

  List<Widget> _preferenceSection(V2Palette p, DietPreference? diet) {
    final region = NutritionDayStore.instance.region;
    return [
      pvDoorPad(nutritionHeading(p, 'Eating your way', sub: 'One row that steers the plate, the swaps and the recipes.')),
      const SizedBox(height: 12),
      pvDoorPad(Wrap(spacing: 8, runSpacing: 8, children: [
        NutritionChip(
          label: diet?.label.en ?? 'Diet: not set',
          p: p,
          leading: Icon(Icons.restaurant_outlined, size: 14, color: p.ink1),
          onTap: () => showPreferenceSheet(context),
        ),
        NutritionChip(
          label: region == null ? 'Region: any' : plateRegionLabel(region),
          p: p,
          leading: Icon(Icons.place_outlined, size: 14, color: p.ink1),
          onTap: () => showPreferenceSheet(context, region: true),
        ),
      ])),
    ];
  }

  // ---- the library ----------------------------------------------------------

  List<Widget> _librarySection(V2Palette p) {
    Widget row(IconData icon, String title, String sub, Widget Function() screen, String route, {bool last = false}) =>
        InkWell(
          onTap: () {
            pvCommitFeedback();
            Navigator.of(context).push(MaterialPageRoute<void>(settings: RouteSettings(name: route), builder: (_) => screen()));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: p.line))),
            child: Row(children: [
              Icon(icon, size: 20, color: p.ink1),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
                  const SizedBox(height: 2),
                  Text(sub, style: pvManrope(fontSize: 12.5, color: p.ink2)),
                ]),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ]),
          ),
        );
    return [
      pvDoorPad(nutritionHeading(p, 'The library', sub: 'Everything the plate is built from.')),
      const SizedBox(height: 6),
      pvDoorPad(Column(children: [
        row(Icons.event_note_outlined, 'All diet charts', '${kDietCharts.length} charts · stage, diet, condition, region',
            () => DietChartsScreen(pregnancy: widget.pregnancy), 'nutrition/charts'),
        row(Icons.nightlight_outlined, 'Fasting, done safely', 'Navratri, Karva Chauth, Ramzan and the rest',
            () => const FastingScreen(), 'nutrition/fasting'),
        row(Icons.science_outlined, 'What your body needs', '${kNutrientGuides.length} nutrients, in everyday foods',
            () => const NutrientsScreen(), 'nutrition/nutrients'),
        row(Icons.help_outline_rounded, 'Is this food safe?', 'Papaya, paneer, street food. The Is it safe? door',
            () => CanIScreen(controller: widget.pregnancy), 'can_i'),
        // THE DOOR AS IT WAS — the user's ask on the phone, 2026-09-20: "a
        // version toggle, just in case, for us to see what was before". The
        // five-tab PvDoorScreen over kNutritionDoor, one tap away for the
        // comparison; Back returns here. Retire once the day door is judged.
        row(Icons.history_rounded, 'The door as it was', 'The five-tab version, kept for comparison',
            () {
              final b = bracketById(kNutritionBracketId);
              return b == null
                  ? CanIScreen(controller: widget.pregnancy)
                  : PvDoorScreen(page: kNutritionDoor, bracket: b, pregnancy: widget.pregnancy);
            }, 'bracket/scans',
            last: true),
      ])),
    ];
  }
}
