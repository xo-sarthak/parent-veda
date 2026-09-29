// =============================================================================
//  Nutrition — the list
// -----------------------------------------------------------------------------
//  What she added from recipes, grouped by recipe, ticked as she buys.
//  Ticked lines fall to the foot and can be cleared in one tap. Share sends
//  it as text — to the partner who does the shopping, which is the whole
//  reason a list on a phone is worth having.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/nutrition_data.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../doors/pv_door_chrome.dart';
import '../../v2/v2_palette.dart';
import 'nutrition_widgets.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  String _text(List<ShoppingItem> items) {
    final b = StringBuffer('Shopping list, from ParentVeda\n');
    for (final rid in items.map((s) => s.recipeId).toSet()) {
      final r = kRecipes.where((x) => x.id == rid).firstOrNull;
      b.writeln('\n${r?.name.en ?? rid}');
      for (final s in items.where((s) => s.recipeId == rid && !s.done)) {
        b.writeln('  · ${s.name}');
      }
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) => PvDoorToolScaffold(
        hue: 104,
        eyebrow: 'Nutrition · Your list',
        title: 'Your list',
        intro: 'Ingredients from the recipes you picked. Tick them off at the shop, or send the list to whoever is going.',
        children: [
          ListenableBuilder(
            listenable: NutritionDayStore.instance,
            builder: (context, _) {
              final p = V2PaletteStore.instance.current;
              final store = NutritionDayStore.instance;
              final items = store.shopping;
              final recipes = items.map((s) => s.recipeId).toSet().toList();
              if (items.isEmpty) {
                return pvDoorPad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  nutritionHeading(p, 'Nothing on it yet'),
                  const SizedBox(height: 8),
                  Text('Open any recipe and tap "Add to my list". Its ingredients land here, grouped by dish.',
                      style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
                ]));
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                pvDoorPad(Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        pvCommitFeedback();
                        Share.share(_text(items));
                      },
                      icon: const Icon(Icons.ios_share_rounded, size: 18),
                      label: const Text('Send the list'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                    ),
                  ),
                  if (items.any((s) => s.done)) ...[
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        pvCommitFeedback();
                        store.clearBought();
                      },
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 46)),
                      child: const Text('Clear bought'),
                    ),
                  ],
                ])),
                const SizedBox(height: 22),
                for (final rid in recipes) ...[
                  pvDoorPad(Row(children: [
                    Expanded(child: nutritionHeading(p, kRecipes.where((x) => x.id == rid).firstOrNull?.name.en ?? rid)),
                    IconButton(
                      tooltip: 'Remove this recipe',
                      icon: Icon(Icons.close_rounded, size: 18, color: p.ink3),
                      onPressed: () {
                        pvCommitFeedback();
                        store.removeRecipeFromList(rid);
                      },
                    ),
                  ])),
                  const SizedBox(height: 4),
                  pvDoorPad(Column(children: [
                    for (final s in [...items.where((s) => s.recipeId == rid && !s.done), ...items.where((s) => s.recipeId == rid && s.done)])
                      InkWell(
                        onTap: () {
                          pvCommitFeedback();
                          store.toggleBought(s);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Row(children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: s.done ? p.ink1 : p.surface,
                                border: Border.all(color: s.done ? p.ink1 : p.line, width: 1.4),
                              ),
                              child: s.done ? Icon(Icons.check_rounded, size: 14, color: p.ground) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(s.name,
                                  style: pvManrope(
                                      fontSize: 14.5,
                                      color: s.done ? p.ink3 : p.ink1,
                                      decoration: s.done ? TextDecoration.lineThrough : null)),
                            ),
                          ]),
                        ),
                      ),
                  ])),
                  const SizedBox(height: 18),
                ],
              ]);
            },
          ),
        ],
      );
}
