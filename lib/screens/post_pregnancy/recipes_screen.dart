// =============================================================================
//  RecipesScreen — Recipes (parenting app · S15, under "Explore")
// -----------------------------------------------------------------------------
//  Indian food for Indian kids: veg/non-veg, a "Healthier version" default,
//  category chips, a featured recipe and a list. Faithful build of Claude
//  Design S15. Reached from the Explore drawer; opens a Recipe page. Pushed
//  screen (back → Explore).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'recipe_page_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  bool _healthier = true;
  bool _veg = true;
  int _cat = 0;

  static const List<String> _cats = ['Snacks', 'Breakfast', 'Lunch', 'Dinner', 'Travel', 'Bland (for sick days)'];

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _open() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecipePageScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.arrow_back, size: 20, color: ppSoft),
                  const SizedBox(width: 12),
                  Text('Explore', style: ppBody(14, color: ppSoft)),
                ]),
              ),
              ppLangToggle(),
            ])),

            const SizedBox(height: 22),
            _pad(ppEyebrow('Indian food, for Indian kids')),
            const SizedBox(height: 10),
            _pad(Text('Recipes', style: ppFraunces(33, h: 1.12))),
            const SizedBox(height: 12),
            _pad(Text('Every recipe age-tagged, with the nutrition context you actually need — and a healthier twist built in.',
                style: ppBody(15, h: 1.6))),

            // veg / non-veg
            const SizedBox(height: 20),
            _pad(Row(children: [
              Expanded(child: _seg('Veg', _veg, () => setState(() => _veg = true))),
              const SizedBox(width: 10),
              Expanded(child: _seg('Non-veg', !_veg, () => setState(() => _veg = false))),
            ])),

            // healthier toggle
            const SizedBox(height: 16),
            _pad(GestureDetector(
              onTap: () => setState(() => _healthier = !_healthier),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Healthier version', style: ppJakarta(14)),
                      const SizedBox(height: 2),
                      Text('The ParentVeda twist — veggies in, a smart ghee swap. On by default.', style: ppBody(12, h: 1.45)),
                    ]),
                  ),
                  const SizedBox(width: 13),
                  ppSwitch(_healthier),
                ]),
              ),
            )),

            // category chips
            const SizedBox(height: 20),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _cats.length,
                separatorBuilder: (_, _) => const SizedBox(width: 9),
                itemBuilder: (_, i) => _chip(_cats[i], i == _cat, () => setState(() => _cat = i)),
              ),
            ),

            // featured
            const SizedBox(height: 22),
            _pad(GestureDetector(
              onTap: _open,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: ppBorder),
                  boxShadow: ppCardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Stack(children: [
                    const PpStriped(height: 160),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.play_arrow_rounded, size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('3-min video', style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
                        ]),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                        child: Text('Healthier', style: ppBody(10, color: ppBrown, w: FontWeight.w700)),
                      ),
                    ),
                  ]),
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Veggie Maggi, the smarter way', style: ppJakarta(19)),
                      const SizedBox(height: 6),
                      Text('Same comfort noodles — with carrots, peas and a small ghee swap.', style: ppBody(13, h: 1.5)),
                      const SizedBox(height: 12),
                      Row(children: [
                        _agePill('2 yrs+'),
                        const SizedBox(width: 8),
                        Text('15 min · easy', style: ppBody(12, color: ppMuted)),
                      ]),
                    ]),
                  ),
                ]),
              ),
            )),

            // list
            const SizedBox(height: 28),
            _pad(Text('Quick veg snacks', style: ppJakarta(16))),
            const SizedBox(height: 14),
            _pad(_recipeRow('Ragi & banana pancakes', '10 min · iron + calcium', '1 yr+', top: true)),
            _pad(_recipeRow('Paneer & veg cutlets', '20 min · protein-rich', '18 mo+', top: true)),
            _pad(_recipeRow('Curd rice, travel-friendly', '5 min · gut-friendly', '10 mo+', top: true, bottom: true)),

            const SizedBox(height: 22),
            _pad(Text("Every recipe is age-tagged, with nutrition, frequency and cautions — in ParentVeda's voice.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _seg(String label, bool active, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: active ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Text(label, style: ppBody(13, color: active ? Colors.white : ppSoft, w: active ? FontWeight.w700 : FontWeight.w600)),
        ),
      );

  Widget _chip(String label, bool active, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: active ? ppPurple : ppPanel, borderRadius: BorderRadius.circular(999)),
          child: Text(label, style: ppBody(12, color: active ? Colors.white : ppSoft, w: active ? FontWeight.w700 : FontWeight.w600)),
        ),
      );

  Widget _agePill(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
      );

  Widget _recipeRow(String name, String meta, String age, {bool top = false, bool bottom = false}) => GestureDetector(
        onTap: _open,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              top: top ? const BorderSide(color: ppHair) : BorderSide.none,
              bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
            ),
          ),
          child: Row(children: [
            const PpStriped(height: 58, width: 58, radius: 16, border: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: ppBody(15, color: ppInk, w: FontWeight.w600, h: 1.3)),
                const SizedBox(height: 3),
                Text(meta, style: ppBody(12, color: ppMuted)),
              ]),
            ),
            const SizedBox(width: 10),
            _agePill(age),
          ]),
        ),
      );
}
