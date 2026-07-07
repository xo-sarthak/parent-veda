// =============================================================================
//  FoodBuilderScreen - the Smart Meal Builder (signature)
// -----------------------------------------------------------------------------
//  Reduces decision fatigue: the parent says the meal, the time they have and
//  what's in the kitchen; ParentVeda suggests 3–5 recipes that fit, explains why
//  each suits his stage, and offers to add any missing ingredients to the
//  shopping list. Personalisation over a static catalogue.
// =============================================================================

import 'package:flutter/material.dart';

import 'food_common.dart';
import 'food_recipe_screen.dart';
import 'food_shopping_screen.dart';
import 'pp_common.dart';
import 'pp_food_data.dart';

class FoodBuilderScreen extends StatefulWidget {
  const FoodBuilderScreen({super.key});

  @override
  State<FoodBuilderScreen> createState() => _FoodBuilderScreenState();
}

class _FoodBuilderScreenState extends State<FoodBuilderScreen> {
  String _meal = 'Breakfast';
  int _minutes = 15;
  final Set<String> _has = {'milk', 'banana', 'oats'};
  List<MealSuggestion>? _results;

  static const List<int> _times = [10, 15, 20, 30];

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  void _build() => setState(() => _results = buildMeals(meal: _meal, maxMinutes: _minutes, has: _has));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Food')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('Smart Meal Builder', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('Let’s figure out this meal together', style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 6),
            _pad(Text('Tell us three things - we’ll suggest what fits, and why.', style: ppBody(14, h: 1.5))),

            const SizedBox(height: 12),
            _pad(_childChip()),

            const SizedBox(height: 22),
            _pad(_label('1 · Which meal?')),
            const SizedBox(height: 10),
            _pad(_chips(kFoodSlots, (s) => _meal == s, (s) => setState(() => _meal = s))),

            const SizedBox(height: 22),
            _pad(_label('2 · How much time?')),
            const SizedBox(height: 10),
            _pad(_chips(_times.map((t) => '$t min').toList(), (s) => '$_minutes min' == s, (s) => setState(() => _minutes = int.parse(s.split(' ').first)))),

            const SizedBox(height: 22),
            _pad(_label('3 · What’s in the kitchen?')),
            const SizedBox(height: 10),
            _pad(_chips(foodIngredientLibrary(), _has.contains, (s) => setState(() => _has.contains(s) ? _has.remove(s) : _has.add(s)))),

            const SizedBox(height: 24),
            _pad(GestureDetector(
              onTap: _build,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppInk, borderRadius: BorderRadius.circular(14)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Suggest meals', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                ]),
              ),
            )),

            if (_results != null) ...[
              const SizedBox(height: 28),
              _pad(Text(_results!.isEmpty ? 'Nothing fits those exactly' : 'Here’s what fits', style: ppJakarta(18))),
              const SizedBox(height: 6),
              _pad(Text(
                  _results!.isEmpty
                      ? 'Try more time, another meal, or add an ingredient - feeding is flexible, not perfect.'
                      : 'Best matches for your kitchen and time, newest-friendly first.',
                  style: ppBody(12.5, color: ppMuted))),
              const SizedBox(height: 16),
              for (final s in _results!) _pad(_suggestion(s)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _childChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.child_care_outlined, size: 15, color: ppPurple),
          const SizedBox(width: 7),
          Text('Aarav · from 6 months', style: ppBody(12.5, color: ppInk, w: FontWeight.w600)),
        ]),
      );

  Widget _label(String t) => Text(t, style: ppJakarta(14.5));

  Widget _chips(List<String> options, bool Function(String) on, void Function(String) tap) => Wrap(
        spacing: 9,
        runSpacing: 9,
        children: [
          for (final o in options)
            GestureDetector(
              onTap: () => tap(o),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: on(o) ? ppPurple : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: on(o) ? ppPurple : ppHair),
                ),
                child: Text(o, style: ppBody(12.5, color: on(o) ? Colors.white : ppInk, w: FontWeight.w600)),
              ),
            ),
        ],
      );

  Widget _suggestion(MealSuggestion s) {
    final r = s.recipe;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => _push(FoodRecipeScreen(recipe: r)),
          behavior: HitTestBehavior.opaque,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 96, child: FoodThumb(seed: r.seed, height: 68)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.title, style: ppJakarta(14.5).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                foodMeta(r),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Text('Why it fits: ${r.why}', style: ppBody(12.5, h: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.check_circle_outline_rounded, size: 15, color: ppPurple),
          const SizedBox(width: 6),
          Flexible(child: Text('Uses ${s.matched} of your ${s.matched == 1 ? 'ingredient' : 'ingredients'}', style: ppBody(12, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        if (s.missing.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Still need: ${s.missing.join(', ')}', style: ppBody(12.5, color: ppSoft)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              FoodStore.instance.addLines(s.missing);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Missing ingredients added to your shopping list'),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(label: 'View', onPressed: () => _push(const FoodShoppingScreen())),
              ));
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.add_shopping_cart_rounded, size: 15, color: ppPurple),
                const SizedBox(width: 6),
                Text('Add missing to list', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}
