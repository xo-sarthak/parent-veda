// =============================================================================
//  FoodMealPlanScreen — dynamic meal plans (Today / 3-Day / Weekly)
// -----------------------------------------------------------------------------
//  Not a static plan — regenerate while keeping the five-slot balance. Each day
//  shows Breakfast → Dinner; tap any meal to open the recipe. Reached from the
//  Food home ("Meal plan →").
// =============================================================================

import 'package:flutter/material.dart';

import 'food_common.dart';
import 'food_recipe_screen.dart';
import 'pp_common.dart';
import 'pp_food_data.dart';

class FoodMealPlanScreen extends StatefulWidget {
  const FoodMealPlanScreen({super.key});

  @override
  State<FoodMealPlanScreen> createState() => _FoodMealPlanScreenState();
}

class _FoodMealPlanScreenState extends State<FoodMealPlanScreen> {
  int _days = 1; // 1 = Today, 3 = 3-Day, 7 = Weekly
  int _regen = 0;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

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
            _pad(ppEyebrow('Meal plan', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('A balanced few days', style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 6),
            _pad(Text('Regenerate any time — the nutrition stays balanced across the day.', style: ppBody(14, h: 1.5))),

            const SizedBox(height: 18),
            _pad(_rangeToggle()),
            const SizedBox(height: 16),
            _pad(_regenButton()),

            const SizedBox(height: 22),
            for (int d = 0; d < _days; d++) ...[
              _pad(_dayHeader(d)),
              const SizedBox(height: 10),
              _pad(_dayCard(d)),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rangeToggle() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          _seg('Today', 1),
          _seg('3-Day', 3),
          _seg('Weekly', 7),
        ]),
      );

  Widget _seg(String label, int days) {
    final on = _days == days;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _days = days),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: on ? const [BoxShadow(color: Color(0x146A30B6), blurRadius: 10, offset: Offset(0, 3))] : null,
          ),
          child: Text(label, style: ppBody(13, color: on ? ppPurple : ppSoft, w: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _regenButton() => GestureDetector(
        onTap: () => setState(() => _regen++),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppBorder)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.refresh_rounded, size: 17, color: ppPurple),
            const SizedBox(width: 8),
            Text('Regenerate', style: ppBody(13.5, color: ppPurple, w: FontWeight.w700)),
          ]),
        ),
      );

  Widget _dayHeader(int d) => Text(
        d == 0 ? 'Today' : 'Day ${d + 1}',
        style: ppJakarta(16),
      );

  Widget _dayCard(int d) {
    final plan = planForDay(d + _regen * 7);
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        for (int i = 0; i < kFoodSlots.length; i++) _slotRow(kFoodSlots[i], plan[kFoodSlots[i]]!, last: i == kFoodSlots.length - 1),
      ]),
    );
  }

  Widget _slotRow(String slot, FoodRecipe r, {bool last = false}) => GestureDetector(
        onTap: () => _push(FoodRecipeScreen(recipe: r)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: last ? BorderSide.none : const BorderSide(color: ppHair))),
          child: Row(children: [
            SizedBox(width: 66, child: FoodThumb(seed: r.seed, height: 48)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(slot.toUpperCase(), style: ppBody(9, color: ppCoral, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
                const SizedBox(height: 2),
                Text(r.title, style: ppBody(13.5, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 8),
            Text('${r.totalMin}m', style: ppBody(11.5, color: ppMuted, w: FontWeight.w600)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
          ]),
        ),
      );
}
