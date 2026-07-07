// =============================================================================
//  RecipePageScreen - Recipe page (parenting · S15·detail v2)
// -----------------------------------------------------------------------------
//  A full recipe with ParentVeda depth: video hero, nutrition per serving with
//  key-nutrient RDAs, why-it's-good, ingredients + equipment, method, frequency
//  + cautions, and a "customise for baby" block. Faithful build of Claude Design
//  · S15·detail v2. The Veggie Maggi recipe carries the full designed page; other
//  recipes show the header + nutrition (full treatment on the way). Reached from
//  Recipes / Sick-day meals → any recipe.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_recipes_data.dart';

class RecipePageScreen extends StatelessWidget {
  const RecipePageScreen({super.key, this.recipe});
  final RecipeItem? recipe;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  Widget _div() => _pad(const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: SizedBox(height: 1, child: ColoredBox(color: ppLine)),
      ));

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    final r = recipe ?? kRecipes.firstWhere((e) => e.id == 'maggi');
    final full = r.id == 'maggi';

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            // video hero
            GestureDetector(
              onTap: () => _soon(context),
              child: SizedBox(
                height: 230,
                child: Stack(children: [
                  const PpStriped(height: 230),
                  Positioned(
                    top: 14,
                    left: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, size: 18, color: ppInk),
                      ),
                    ),
                  ),
                  if (r.healthier)
                    Positioned(
                      top: 16,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                        child: Text('Healthier version · on', style: ppBody(11, color: ppBrown, w: FontWeight.w700)),
                      ),
                    ),
                  const Positioned.fill(child: Center(child: _Play(56))),
                ]),
              ),
            ),

            // meta + title
            const SizedBox(height: 22),
            _pad(Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                child: Text("Right for Aarav's stage", style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text('${r.minutes} min · ${r.difficulty.toLowerCase()} · serves ${r.serves}',
                    style: ppBody(13, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ])),
            const SizedBox(height: 12),
            _pad(Text(r.title, style: ppFraunces(29, h: 1.15))),
            const SizedBox(height: 12),
            _pad(Text(r.description, style: ppBody(14, h: 1.6))),

            _div(),

            // nutrition
            _pad(Text('Nutrition per serving', style: ppJakarta(17))),
            const SizedBox(height: 12),
            _pad(Row(children: [
              _nutTile('${r.kcal}', 'kcal'),
              const SizedBox(width: 10),
              _nutTile('${r.protein}g', 'protein'),
              const SizedBox(width: 10),
              _nutTile('${r.fibre}g', 'fibre'),
            ])),

            if (full) ...[
              const SizedBox(height: 12),
              _pad(Column(children: [
                _nutrient('Vitamin A', '(from carrots)', '35% RDA',
                    'Builds his immunity and eyesight - important now as he explores and mouths everything.'),
                _nutrient('Iron', '', '12% RDA',
                    'His birth iron stores run low around now, and iron fuels the brain growth of these months.'),
                _nutrient('Fibre', '(peas + wheat)', '4g',
                    'Keeps digestion gentle as he moves from purées to firmer foods.'),
              ])),

              _div(),
              _pad(Text("Why it's good", style: ppJakarta(17))),
              const SizedBox(height: 10),
              _pad(Text(
                  'The veg boost adds fibre and vitamin A to a food kids already love, and the ghee swap makes it gentler than the packet masala alone. A comfort meal that quietly does more.',
                  style: ppBody(14, h: 1.6))),

              _div(),
              _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Ingredients', style: ppJakarta(15)),
                    const SizedBox(height: 12),
                    _bullet('1 pack whole-wheat noodles'),
                    _bullet('½ carrot, grated'),
                    _bullet('2 tbsp peas'),
                    _bullet('½ tsp ghee'),
                    _bullet('Half the masala sachet'),
                  ]),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Equipment', style: ppJakarta(15)),
                    const SizedBox(height: 12),
                    _bullet('Small saucepan or kadhai', brown: true),
                    _bullet('Grater', brown: true),
                    _bullet('Blender (for the baby portion)', brown: true),
                  ]),
                ),
              ])),

              const SizedBox(height: 22),
              _pad(Text('Method', style: ppJakarta(17))),
              const SizedBox(height: 6),
              _pad(Column(children: [
                _step('1', 'Sauté carrot and peas in ghee for two minutes.', top: true),
                _step('2', 'Add noodles, water and half the masala; simmer.', top: true),
                _step('3', 'Cook till soft, cool a little, and serve.', top: true, bottom: true),
              ])),

              const SizedBox(height: 24),
              _pad(Row(children: [
                Expanded(child: _panel('Frequency', ppPurple, 'Once a week is plenty.')),
                const SizedBox(width: 12),
                Expanded(child: _panel('Watch for', ppBrown, 'Still salty - use half the masala.')),
              ])),

              const SizedBox(height: 24),
              _pad(_customise(context)),
            ] else ...[
              const SizedBox(height: 22),
              _pad(Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.auto_awesome_outlined, size: 18, color: ppPurple),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                        'Full ingredients, method and baby-customisation for this recipe are on the way - every recipe gets the ParentVeda treatment.',
                        style: ppBody(13, color: ppInk, h: 1.5)),
                  ),
                ]),
              )),
            ],

            const SizedBox(height: 22),
            _pad(Text('Nutrition, frequency and cautions on every recipe. Reviewed by a paediatric nutritionist.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _nutTile(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Text(value, style: ppJakarta(16)),
            const SizedBox(height: 2),
            Text(label, style: ppBody(10, color: ppMuted)),
          ]),
        ),
      );

  Widget _nutrient(String name, String note, String value, String desc) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text.rich(TextSpan(children: [
                TextSpan(text: name, style: ppBody(13, color: ppInk, w: FontWeight.w600)),
                if (note.isNotEmpty) TextSpan(text: ' $note', style: ppBody(13, color: ppMuted)),
              ])),
            ),
            const SizedBox(width: 10),
            Text(value, style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
          ]),
          const SizedBox(height: 4),
          Text(desc, style: ppBody(12, h: 1.5)),
        ]),
      );

  Widget _bullet(String t, {bool brown = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: brown ? ppBrown : ppPurple, shape: BoxShape.circle),
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(t, style: ppBody(13, color: ppInk, h: 1.45))),
        ]),
      );

  Widget _step(String n, String text, {bool top = false, bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n, style: ppBody(14, color: ppPurple, w: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );

  Widget _panel(String label, Color color, String text) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppEyebrow(label, color: color, spacing: 0.6),
          const SizedBox(height: 6),
          Text(text, style: ppBody(14, color: ppInk, h: 1.5)),
        ]),
      );

  Widget _customise(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(22)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
              child: const Icon(Icons.child_care_rounded, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 9),
            Flexible(child: Text('Customise for baby', style: ppJakarta(17), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 6),
          Text('Make the same dish safe and easy for a younger one - Aarav will be ready around 8 months.',
              style: ppBody(13, h: 1.55)),
          const SizedBox(height: 16),
          _cust('Form', 'Chop noodles small or blend to a soft mash - no long strands.'),
          const SizedBox(height: 11),
          _cust('Ingredients', 'Skip the masala entirely; flavour with a pinch of jeera and the veggies alone.'),
          const SizedBox(height: 11),
          _cust('How to give', "Soft spoonfuls, cooled to lukewarm. Let him self-feed a few once he's grabbing."),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFFFF7EE), borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.warning_amber_rounded, size: 15, color: ppBrown),
              const SizedBox(width: 9),
              Expanded(
                child: Text('Introduce one new ingredient at a time, and only after solids have started.',
                    style: ppBody(12, color: ppBrown, h: 1.5)),
              ),
            ]),
          ),
        ]),
      );

  Widget _cust(String label, String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 78,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
          child: Text(label, style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
        ),
        const SizedBox(width: 11),
        Expanded(child: Text(text, style: ppBody(13, color: ppInk, h: 1.5))),
      ]);
}

class _Play extends StatelessWidget {
  const _Play(this.size);
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), shape: BoxShape.circle),
        child: Icon(Icons.play_arrow_rounded, color: ppPurple, size: size * 0.5),
      );
}
