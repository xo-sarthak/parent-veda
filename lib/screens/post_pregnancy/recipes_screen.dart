// =============================================================================
//  RecipesScreen - Recipes (parenting · S15 v2, under "Explore")
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
import 'pp_section_extras.dart';
import 'sick_days_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String _diet = 'All'; // 'All' | 'veg' | 'vegan' | 'nonveg'
  bool _immunity = false;
  bool _healthier = true;
  String _category = 'All';

  final TextEditingController _searchCtl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    var list = normalRecipes(diet: _diet, category: _category, immunity: _immunity);
    if (q.isNotEmpty) list = list.where((r) => r.title.toLowerCase().contains(q)).toList();
    final dietLabel = kRecipeDiets.firstWhere((d) => d.$2 == _diet, orElse: () => kRecipeDiets.first).$1;
    final catWord = _category == 'All' ? 'recipes' : _category.toLowerCase();
    final sectionTitle = '${_diet == 'All' ? 'All' : dietLabel} $catWord${_immunity ? ' · immunity boosters' : ''}';

    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
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
            _pad(Text('Every recipe age-tagged, with the nutrition context you actually need - and a healthier twist built in.',
                style: ppBody(15))),

            // search (recipe title)
            const SizedBox(height: 16),
            _pad(ppSearchField(
              controller: _searchCtl,
              hint: 'Search recipes…',
              onChanged: (v) => setState(() => _query = v),
            )),

            // diet filter (All / Veg / Vegan / Non-veg) + immunity - no scroll
            const SizedBox(height: 20),
            _pad(Row(children: [
              for (int i = 0; i < kRecipeDiets.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _dietSeg(kRecipeDiets[i].$1, kRecipeDiets[i].$2)),
              ],
            ])),
            const SizedBox(height: 10),
            _pad(Align(alignment: Alignment.centerLeft, child: _immunityChip())),

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

            // category chips (wrap - all visible, no horizontal scroll)
            _pad(Wrap(spacing: 9, runSpacing: 9, children: [for (final c in kRecipeCategories) _chip(c)])),

            // list
            const SizedBox(height: 26),
            _pad(Text(sectionTitle, style: ppJakarta(16))),
            const SizedBox(height: 14),
            if (list.isEmpty)
              _pad(Container(
                padding: const EdgeInsets.symmetric(vertical: 28),
                alignment: Alignment.center,
                child: Text(q.isNotEmpty ? 'No matches for "$_query" - try another dish.' : 'No recipes match these filters yet - try another combination.',
                    textAlign: TextAlign.center, style: ppBody(13, color: ppMuted)),
              ))
            else
              _pad(Column(children: [
                for (int i = 0; i < list.length; i++)
                  PpRecipeRow(list[i], top: i > 0, bottom: i == list.length - 1),
              ])),

            const SizedBox(height: 22),
            _pad(Text("Every recipe is age-tagged, with nutrition, frequency and cautions - in ParentVeda's voice.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
      const PpAskVedaFab(),
      ]),
    );
  }

  Widget _dietSeg(String label, String code) {
    final on = _diet == code;
    return GestureDetector(
      onTap: () => setState(() => _diet = code),
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(12)),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(12.5, color: on ? Colors.white : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }

  Widget _immunityChip() {
    final on = _immunity;
    const amber = Color(0xFFC98A2B);
    return GestureDetector(
      onTap: () => setState(() => _immunity = !_immunity),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(color: on ? amber : Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: on ? amber : ppLine)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.shield_moon_outlined, size: 15, color: on ? Colors.white : amber),
          const SizedBox(width: 6),
          Text('Immunity boosters', style: ppBody(12.5, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _chip(String c) {
    final on = _category == c;
    return GestureDetector(
      onTap: () => setState(() => _category = c),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: on ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(c, style: ppBody(12, color: on ? Colors.white : ppSoft, w: on ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }
}
