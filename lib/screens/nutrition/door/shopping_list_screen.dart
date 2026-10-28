// =============================================================================
//  Nutrition — the list
// -----------------------------------------------------------------------------
//  What she added from recipes, grouped by recipe, ticked as she buys.
//  Ticked lines fall to the foot and can be cleared in one tap. Share sends
//  it as text — to the partner who does the shopping, which is the whole
//  reason a list on a phone is worth having.
//
//  P4 (2026-10-28), the food shopping list:
//   · S1: the screen reads the store itself. Only the Nutrition door and the
//     Today body called `init`, so opened from a recipe or the Tools row the
//     list read empty.
//   · S5: clearing, removing a group and removing one line each say what went
//     and offer Undo; she can add her own items ("Your own"); the title says
//     what it is; the shared tool look (`PregToolScaffold`), as every Tools
//     row. Kept for revert: `PvDoorToolScaffold`, `pvDoorPad`, the outlined
//     buttons, and the silent removals.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/nutrition/chart_ingredients.dart';
import '../../../data/nutrition_data.dart';
import '../../../services/nutrition_day_store.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../../widgets/pv_toast.dart';
import '../../brackets/hub/hub_intent_art.dart' show IntentMark;
// import '../../doors/pv_door_chrome.dart'; // kept for revert (P4 S5): PvDoorToolScaffold, pvDoorPad
import '../../pregnancy/preg_tool_chrome.dart'
    show PregToolScaffold, pregToolPad;
import '../../products/pv_store_chrome.dart' show PvCommit, PvSecondary;
import '../../v2/v2_palette.dart';
import 'nutrition_widgets.dart';

/// What a group on the list is called: a recipe's name, or "Vegetarian chart ·
/// Day 2" for the things a chart day asked for (2026-09-30), "Your own" for
/// what she typed herself (P4 S5), else the id itself.
String shoppingGroupTitle(String rid) {
  if (rid == kOwnListId) return 'Your own';
  final c = parseChartListId(rid);
  if (c != null) {
    final chart = kDietCharts.where((x) => x.id == c.chartId).firstOrNull;
    final name = chart?.title.en ?? c.chartId;
    return c.dayIndex == null
        ? '$name · every day'
        : '$name · Day ${c.dayIndex! + 1}';
  }
  return kRecipes.where((x) => x.id == rid).firstOrNull?.name.en ?? rid;
}

/// The page's title, shared with the Tools row's search and the tests.
const String kShoppingListTitle = 'Your shopping list';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _own = TextEditingController();

  @override
  void initState() {
    super.initState();
    // S1: the list reads its own store, whichever way she came in.
    NutritionDayStore.instance.init();
  }

  @override
  void dispose() {
    _own.dispose();
    super.dispose();
  }

  String _text(List<ShoppingItem> items) {
    final b = StringBuffer('Shopping list, from ParentVeda\n');
    for (final rid in items.map((s) => s.recipeId).toSet()) {
      b.writeln('\n${shoppingGroupTitle(rid)}');
      for (final s in items.where((s) => s.recipeId == rid && !s.done)) {
        b.writeln('  · ${s.name}');
      }
    }
    return b.toString();
  }

  void _undoToast(String text, List<ShoppingLine> gone) {
    if (gone.isEmpty) return;
    pvToast(
      context,
      text,
      kind: PvToastKind.undo,
      action: 'Undo',
      onAction: () => NutritionDayStore.instance.restoreLines(gone),
    );
  }

  static String _items(int n) => n == 1 ? '1 item' : '$n items';

  void _addOwn() {
    final name = _own.text.trim();
    if (name.isEmpty) {
      pvToast(context, 'Type what you need first, then add it.');
      return;
    }
    pvCommitFeedback();
    final added = NutritionDayStore.instance.addOwnItem(name);
    if (added) {
      _own.clear();
      pvToast(
        context,
        'Added "$name" to your list, under Your own.',
        kind: PvToastKind.done,
      );
    } else {
      pvToast(context, '"$name" is already on your list.');
    }
  }

  @override
  Widget build(BuildContext context) => PregToolScaffold(
    hue: 104,
    // Kept for revert (P4 S5): eyebrow 'Nutrition · Your list', title 'Your list'.
    eyebrow: 'Nutrition',
    title: kShoppingListTitle,
    mark: IntentMark.forkMark,
    intro:
        'Ingredients from the recipes and diet chart days you picked, and anything you add '
        'yourself. Tick them off at the shop, or send the list to whoever is going.',
    children: [
      ListenableBuilder(
        listenable: NutritionDayStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final store = NutritionDayStore.instance;
          final items = store.shopping;
          final recipes = items.map((s) => s.recipeId).toSet().toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              pregToolPad(_OwnField(controller: _own, p: p, onAdd: _addOwn)),
              const SizedBox(height: 22),
              if (items.isEmpty)
                pregToolPad(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      nutritionHeading(p, 'Nothing on it yet'),
                      const SizedBox(height: 8),
                      Text(
                        'Open a recipe or a diet chart day and tap "Add to my list". What it needs lands here, '
                        'grouped by dish or day. Anything else you need, add above.',
                        style: pvManrope(
                          fontSize: 14,
                          height: 1.5,
                          color: p.ink2,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                pregToolPad(
                  Row(
                    children: [
                      Expanded(
                        child: PvCommit(
                          key: const ValueKey('shop_send'),
                          label: 'Send the list',
                          icon: Icons.ios_share_rounded,
                          onTap: () {
                            pvCommitFeedback();
                            Share.share(_text(items));
                          },
                        ),
                      ),
                      if (items.any((s) => s.done)) ...[
                        const SizedBox(width: 10),
                        PvSecondary(
                          key: const ValueKey('shop_clear_bought'),
                          label: 'Clear bought',
                          onTap: () {
                            pvCommitFeedback();
                            final gone = store.clearBought();
                            _undoToast(
                              'Cleared ${_items(gone.length)} you bought.',
                              gone,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                for (final rid in recipes) ...[
                  pregToolPad(
                    Row(
                      children: [
                        Expanded(
                          child: nutritionHeading(p, shoppingGroupTitle(rid)),
                        ),
                        IconButton(
                          tooltip: 'Remove this group',
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: p.ink3,
                          ),
                          onPressed: () {
                            pvCommitFeedback();
                            final gone = store.removeRecipeFromList(rid);
                            _undoToast(
                              'Removed ${shoppingGroupTitle(rid)} from your list (${_items(gone.length)}).',
                              gone,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  pregToolPad(
                    Column(
                      children: [
                        for (final s in [
                          ...items.where((s) => s.recipeId == rid && !s.done),
                          ...items.where((s) => s.recipeId == rid && s.done),
                        ])
                          _Line(
                            item: s,
                            p: p,
                            onTap: () {
                              pvCommitFeedback();
                              store.toggleBought(s);
                            },
                            onRemove: () {
                              pvCommitFeedback();
                              final gone = store.removeItem(s);
                              if (gone != null) {
                                _undoToast(
                                  'Removed ${s.name} from your list.',
                                  [gone],
                                );
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ],
            ],
          );
        },
      ),
    ],
  );
}

// Kept for revert (P4 S5, 2026-10-28): the page before, on the door chrome,
// with silent removals and no own items.
//   Widget build(BuildContext context) => PvDoorToolScaffold(
//         hue: 104,
//         eyebrow: 'Nutrition · Your list',
//         title: 'Your list',
//         intro: 'Ingredients from the recipes and diet chart days you picked. Tick them off at the shop, or send the list to whoever is going.',
//         children: [
//           ListenableBuilder(
//             listenable: NutritionDayStore.instance,
//             builder: (context, _) {
//               ...
//               if (items.isEmpty) { /* 'Nothing on it yet' */ }
//               return Column(children: [
//                 pvDoorPad(Row(children: [
//                   Expanded(child: OutlinedButton.icon(
//                     onPressed: () { pvCommitFeedback(); Share.share(_text(items)); },
//                     icon: const Icon(Icons.ios_share_rounded, size: 18),
//                     label: const Text('Send the list'))),
//                   if (items.any((s) => s.done)) OutlinedButton(
//                     onPressed: () { pvCommitFeedback(); store.clearBought(); },
//                     child: const Text('Clear bought')),
//                 ])),
//                 for (final rid in recipes) ...[
//                   pvDoorPad(Row(children: [
//                     Expanded(child: nutritionHeading(p, shoppingGroupTitle(rid))),
//                     IconButton(tooltip: 'Remove this group',
//                       onPressed: () { pvCommitFeedback(); store.removeRecipeFromList(rid); }),
//                   ])),
//                   // each line: InkWell(onTap: toggleBought) with the round tick and the name,
//                   // vertical padding 9, no remove
//                 ],
//               ]);
//             },
//           ),
//         ],
//       );

/// One line: tap to tick it bought, the small cross to take it off.
class _Line extends StatelessWidget {
  const _Line({
    required this.item,
    required this.p,
    required this.onTap,
    required this.onRemove,
  });
  final ShoppingItem item;
  final V2Palette p;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final s = item;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.done ? p.ink1 : p.surface,
                border: Border.all(color: s.done ? p.ink1 : p.line, width: 1.4),
              ),
              child: s.done
                  ? Icon(Icons.check_rounded, size: 14, color: p.ground)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s.name,
                style: pvManrope(
                  fontSize: 14.5,
                  color: s.done ? p.ink3 : p.ink1,
                  decoration: s.done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            IconButton(
              key: ValueKey('shop_remove_${s.key}'),
              tooltip: 'Remove ${s.name}',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.close_rounded, size: 16, color: p.ink3),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Add your own item": one line of text and an add button.
class _OwnField extends StatelessWidget {
  const _OwnField({
    required this.controller,
    required this.p,
    required this.onAdd,
  });
  final TextEditingController controller;
  final V2Palette p;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: p.line),
    ),
    padding: const EdgeInsets.only(left: 14, right: 4),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            key: const ValueKey('shop_own_field'),
            controller: controller,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => onAdd(),
            style: pvManrope(fontSize: 15, color: p.ink1),
            decoration: InputDecoration(
              isDense: true,
              // The theme fills every input grey; this box draws its own.
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'Add your own item',
              hintStyle: pvManrope(fontSize: 15, color: p.ink3),
            ),
          ),
        ),
        IconButton(
          key: const ValueKey('shop_own_add'),
          tooltip: 'Add to your list',
          icon: Icon(Icons.add_rounded, color: p.ink1),
          onPressed: onAdd,
        ),
      ],
    ),
  );
}
