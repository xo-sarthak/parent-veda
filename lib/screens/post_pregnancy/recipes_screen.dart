// =============================================================================
//  RecipesScreen — Recipes (parenting · S15 v2, under "Explore")
// -----------------------------------------------------------------------------
//  Indian food for Indian kids: a Sick-mode doorway, a "Recommended" carousel,
//  a "Healthier version" default, veg/non-veg + category filters, and a recipe
//  list. Faithful build of Claude Design · S15 v2. Reached from the Explore
//  drawer; opens a Recipe page or Sick-day meals. Pushed (back → Explore).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_recipe_widgets.dart';
import 'pp_recipes_data.dart';
import 'sick_days_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  bool _veg = true;
  bool _healthier = true;
  String _category = 'All';

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final list = normalRecipes(veg: _veg, category: _category);
    final sectionTitle = '${_veg ? 'Veg' : 'Non-veg'} ${_category == 'All' ? 'recipes' : _category.toLowerCase()}';

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ppBack(context, 'Explore'),
              ppLangToggle(),
            ])),

            // header + sick mode
            const SizedBox(height: 22),
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ppEyebrow('Indian food, for Indian kids'),
                  const SizedBox(height: 10),
                  Text('Recipes', style: ppFraunces(33, h: 1.12)),
                ]),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SickDaysScreen())),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.local_cafe_outlined, size: 18, color: ppPurple),
                    const SizedBox(height: 5),
                    Text('Sick mode', style: ppBody(10, color: ppPurple, w: FontWeight.w700)),
                  ]),
                ),
              ),
            ])),
            const SizedBox(height: 12),
            _pad(Text('Every recipe age-tagged, with the nutrition context you actually need — and a healthier twist built in.',
                style: ppBody(15))),

            // veg / non-veg
            const SizedBox(height: 20),
            _pad(Row(children: [
              Expanded(child: _seg('Veg', _veg, () => setState(() => _veg = true))),
              const SizedBox(width: 10),
              Expanded(child: _seg('Non-veg', !_veg, () => setState(() => _veg = false))),
            ])),

            // recommended carousel
            const SizedBox(height: 22),
            _pad(Text('Recommended for Aarav', style: ppJakarta(16))),
            const SizedBox(height: 12),
            SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: recommendedRecipes.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, i) => PpRecipeCard(recommendedRecipes[i]),
              ),
            ),

            // healthier toggle
            const SizedBox(height: 18),
            _pad(GestureDetector(
              onTap: () => setState(() => _healthier = !_healthier),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  Expanded(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: 'Healthier version', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                      TextSpan(text: ' · ParentVeda twist', style: ppBody(13, color: ppSoft)),
                    ])),
                  ),
                  const SizedBox(width: 10),
                  ppSwitch(_healthier),
                ]),
              ),
            )),

            _pad(const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: SizedBox(height: 1, child: ColoredBox(color: ppLine)),
            )),

            // category chips
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [for (final c in kRecipeCategories) _chip(c)],
              ),
            ),

            // list
            const SizedBox(height: 26),
            _pad(Text(sectionTitle, style: ppJakarta(16))),
            const SizedBox(height: 14),
            if (list.isEmpty)
              _pad(Container(
                padding: const EdgeInsets.symmetric(vertical: 28),
                alignment: Alignment.center,
                child: Text('No ${_veg ? 'veg' : 'non-veg'} recipes here yet — try another category.',
                    textAlign: TextAlign.center, style: ppBody(13, color: ppMuted)),
              ))
            else
              _pad(Column(children: [
                for (int i = 0; i < list.length; i++)
                  PpRecipeRow(list[i], top: i > 0, bottom: i == list.length - 1),
              ])),

            const SizedBox(height: 22),
            _pad(Text("Every recipe is age-tagged, with nutrition, frequency and cautions — in ParentVeda's voice.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _seg(String label, bool on, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Text(label, style: ppBody(13, color: on ? Colors.white : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
        ),
      );

  Widget _chip(String c) {
    final on = _category == c;
    return GestureDetector(
      onTap: () => setState(() => _category = c),
      child: Container(
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(c, style: ppBody(12, color: on ? Colors.white : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }
}
