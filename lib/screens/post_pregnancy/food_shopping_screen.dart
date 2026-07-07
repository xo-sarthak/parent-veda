// =============================================================================
//  FoodShoppingScreen - the auto-generated shopping list
// -----------------------------------------------------------------------------
//  Ingredients added from recipes (and the Smart Meal Builder's "buy missing")
//  gather here as a checklist. Mark purchased, clear the bought, future-ready for
//  grocery integrations. Reflects the FoodStore live.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_food_data.dart';

class FoodShoppingScreen extends StatelessWidget {
  const FoodShoppingScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: FoodStore.instance,
          builder: (context, _) {
            final store = FoodStore.instance;
            final lines = store.shopping.keys.toList();
            final left = store.shoppingLeft;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Food')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('Shopping list', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('What to pick up', style: ppFraunces(30, h: 1.1))),
                const SizedBox(height: 6),
                _pad(Text(lines.isEmpty ? 'Add ingredients from any recipe and they’ll gather here.' : '$left of ${lines.length} still to buy', style: ppBody(13))),
                const SizedBox(height: 20),

                if (lines.isEmpty)
                  _pad(Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
                    child: Row(children: [
                      const Icon(Icons.shopping_basket_outlined, size: 22, color: ppMuted),
                      const SizedBox(width: 14),
                      Expanded(child: Text('Your list is empty. Open a recipe and tap “Add ingredients to shopping list”.', style: ppBody(13.5, h: 1.5))),
                    ]),
                  ))
                else ...[
                  _pad(Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(children: [
                      for (int i = 0; i < lines.length; i++) _row(lines[i], store.shopping[lines[i]]!, last: i == lines.length - 1),
                    ]),
                  )),
                  const SizedBox(height: 16),
                  if (lines.length - left > 0)
                    _pad(GestureDetector(
                      onTap: store.clearPurchased,
                      behavior: HitTestBehavior.opaque,
                      child: Row(children: [
                        const Icon(Icons.delete_sweep_outlined, size: 18, color: ppSoft),
                        const SizedBox(width: 8),
                        Text('Clear ${lines.length - left} purchased', style: ppBody(13, color: ppSoft, w: FontWeight.w700)),
                      ]),
                    )),
                  const SizedBox(height: 16),
                  _pad(Text('Grocery delivery integration is coming - for now this is your checklist.', style: ppBody(11.5, color: ppMuted, h: 1.5))),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(String line, bool purchased, {bool last = false}) => GestureDetector(
        onTap: () => FoodStore.instance.togglePurchased(line),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(border: Border(bottom: last ? BorderSide.none : const BorderSide(color: ppHair))),
          child: Row(children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: purchased ? ppPurple : Colors.transparent,
                shape: BoxShape.circle,
                border: purchased ? null : Border.all(color: const Color(0xFFC7BBD6), width: 1.5),
              ),
              child: purchased ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(line,
                  style: ppBody(14, color: purchased ? ppMuted : ppInk, w: FontWeight.w500).copyWith(decoration: purchased ? TextDecoration.lineThrough : null)),
            ),
          ]),
        ),
      );
}
