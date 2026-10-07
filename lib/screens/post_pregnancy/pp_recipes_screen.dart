// =============================================================================
//  Parenting · Recipes, in the one ParentVeda format (2026-10-07)
// -----------------------------------------------------------------------------
//  The user: "do a mobbin MCP usage over it to find out the most appropriate
//  representation of the recipes section". Two browse screens did one job
//  (RecipesScreen from the doors and Tools, RecipesExploreScreen from More),
//  both on the old chrome. This is the one, on the shell every TTC and
//  pregnancy tool wears; both entrances open it, the old two are kept for
//  revert.
//
//  Mobbin:
//   * search, then the filters as chips that read as a sentence, after Noom's
//     recipes (mobbin.com/screens/99817269-341f-4d2d-bf05-17162018a65b);
//   * one rail per meal, after Lifesum's Breakfast / Lunch rails
//     (mobbin.com/screens/c23fec59-8d81-4c2a-984c-4581ee26e0e4);
//   * the time on every card, after Kitchen Stories
//     (mobbin.com/screens/ec68f241-2fae-4090-aaf0-383f7bddb260).
//  The cards are the doors' shelf cards (kind: recipe), so a recipe here looks
//  like a recipe on a door.
//
//  "For <name> now" is on by default: the age is derived, never asked. A
//  sick-day doorway stays at the foot, as before.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart';
import '../doors/pv_shelf_card.dart';
import '../doors/pv_shelf_spec.dart' show PvShelfKind;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvChip, pvStorePalette;
import '../v2/v2_palette.dart';
import 'food_recipe_screen.dart';
import 'pp_child_profile.dart';
import 'pp_food_data.dart';
import 'sick_days_screen.dart';

/// The months an age tag covers ('6 to 12 mo', '12 mo+', '6+ mo'), or null.
(int, int)? ppRecipeAgeRange(String tag) {
  final t = tag.toLowerCase().replaceAll('–', ' to ').replaceAll('-', ' to ');
  final r = RegExp(r'(\d+)\s*to\s*(\d+)').firstMatch(t);
  if (r != null) return (int.parse(r.group(1)!), int.parse(r.group(2)!));
  final plus = RegExp(r'(\d+)\s*(mo)?\s*\+').firstMatch(t);
  if (plus != null) return (int.parse(plus.group(1)!), 999);
  return null;
}

bool ppRecipeSuits(FoodRecipe r, int months) {
  final range = ppRecipeAgeRange(r.ageTag);
  return range == null || (months >= range.$1 && months <= range.$2);
}

class PpRecipesScreen extends StatefulWidget {
  const PpRecipesScreen({super.key});

  @override
  State<PpRecipesScreen> createState() => _PpRecipesScreenState();
}

class _PpRecipesScreenState extends State<PpRecipesScreen> {
  final TextEditingController _q = TextEditingController();
  String _query = '';
  bool _forNow = true;
  String _diet = 'All'; // All | Veg | Non-veg

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _open(FoodRecipe r) {
    pvCommitFeedback();
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'pp/recipe/${r.id}'),
      builder: (_) => FoodRecipeScreen(recipe: r),
    ));
  }

  List<FoodRecipe> _pool(int months) => [
        for (final r in foodCatalog)
          if (!r.comfortOnly &&
              (!_forNow || ppRecipeSuits(r, months)) &&
              (_diet == 'All' || (_diet == 'Veg' ? r.veg : !r.veg)))
            r,
      ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: foodListenable,
      builder: (context, _) {
        final p = pvStorePalette;
        final c = ChildProfileStore.instance;
        final months = c.devAgeInMonths;
        final pool = _pool(months);
        final q = _query.trim().toLowerCase();
        final hits = q.isEmpty
            ? const <FoodRecipe>[]
            : [
                for (final r in pool)
                  if (r.title.toLowerCase().contains(q) ||
                      r.tags.any((t) => t.contains(q)) ||
                      r.ingredients.any((i) => i.toLowerCase().contains(q)))
                    r,
              ];
        return PregToolScaffold(
          hue: 96,
          eyebrow: 'Food',
          mark: IntentMark.cookMark,
          title: 'Recipes',
          intro: '${foodCatalog.length} Indian home recipes, each tagged for an age, with why it is good and '
              'how to make it.',
          children: [
            pregToolPad(TextField(
              key: const ValueKey('pp_recipes_search'),
              controller: _q,
              onChanged: (v) => setState(() => _query = v),
              style: pvManrope(fontSize: 15, fontWeight: FontWeight.w500, color: p.ink1),
              decoration: InputDecoration(
                hintText: 'khichdi, ragi, egg, dal...',
                hintStyle: pvManrope(fontSize: 15, color: p.ink3),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: p.ink3),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: p.ink1)),
              ),
            )),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                KeyedSubtree(
                  key: const ValueKey('pp_recipes_for_now'),
                  child: PvChip(
                    label: 'For ${c.nameMid} now',
                    selected: _forNow,
                    onTap: () => setState(() => _forNow = !_forNow),
                  ),
                ),
                for (final d in const ['All', 'Veg', 'Non-veg']) ...[
                  const SizedBox(width: 8),
                  KeyedSubtree(
                    key: ValueKey('pp_recipes_diet_$d'),
                    child: PvChip(label: d == 'All' ? 'Any diet' : d, selected: _diet == d, onTap: () => setState(() => _diet = d)),
                  ),
                ],
              ]),
            ),
            if (q.isNotEmpty) ...[
              const SizedBox(height: 18),
              if (hits.isEmpty)
                pregToolPad(Text('No recipe by that name. Try one ingredient, like ragi or dal.',
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)))
              else
                _grid(p, hits),
            ] else ...[
              for (final cat in kBrowseCategories)
                if (cat != 'All')
                  ..._rail(p, cat, [for (final r in pool) if (r.category == cat) r]),
              const SizedBox(height: 26),
              pregToolPad(PvRowGroup(p: p, children: [
                PvListRow(
                  key: const ValueKey('pp_recipes_sick'),
                  p: p,
                  leading: PvMarkWell(p: p, hue: 206, size: 40, icon: Icons.healing_outlined),
                  title: 'When ${c.nameMid} is unwell',
                  line: 'Gentle food for a cold, loose motions or constipation.',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SickDaysScreen())),
                ),
              ])),
            ],
          ],
        );
      },
    );
  }

  String _time(FoodRecipe r) => '${r.prepMin + r.cookMin} min';

  List<Widget> _rail(V2Palette p, String cat, List<FoodRecipe> items) {
    if (items.isEmpty) return const [];
    return [
      const SizedBox(height: 24),
      pregToolPad(Text(cat, style: pvFraunces(fontSize: 20, fontWeight: FontWeight.w600, color: p.ink1))),
      const SizedBox(height: 10),
      SizedBox(
        height: pvShelfRailHeight(MediaQuery.textScalerOf(context)),
        child: ListView.separated(
          key: ValueKey('pp_recipes_rail_$cat'),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) => _card(p, items[i], i),
        ),
      ),
    ];
  }

  Widget _card(V2Palette p, FoodRecipe r, int i, {double? width}) => PvShelfCard(
        key: ValueKey('pp_recipe_${r.id}'),
        p: p,
        hue: (80 + i * 26) % 360,
        kind: PvShelfKind.recipe,
        kindWord: r.ageTag,
        fact: _time(r),
        title: r.title,
        width: width ?? kPvShelfCardWidth,
        onTap: () => _open(r),
      );

  Widget _grid(V2Palette p, List<FoodRecipe> items) => LayoutBuilder(
        builder: (context, box) {
          final w = (box.maxWidth - 40 - 12) / 2;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(spacing: 12, runSpacing: 12, children: [
              for (var i = 0; i < items.length && i < 40; i++) _card(p, items[i], i, width: w),
            ]),
          );
        },
      );
}
