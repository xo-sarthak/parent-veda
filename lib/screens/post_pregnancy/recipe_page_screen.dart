// =============================================================================
//  RecipePageScreen — Recipe page (parenting app · S15·detail)
// -----------------------------------------------------------------------------
//  A full recipe with the ParentVeda depth: nutrition, why-it's-good, frequency
//  + cautions, ingredients + method, and a "customise for baby" block. Faithful
//  build of Claude Design S15·detail. Reached from Recipes → any recipe.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class RecipePageScreen extends StatefulWidget {
  const RecipePageScreen({super.key});

  @override
  State<RecipePageScreen> createState() => _RecipePageScreenState();
}

class _RecipePageScreenState extends State<RecipePageScreen> {
  bool _healthier = true;

  static const Color _warnBg = Color(0xFFFFF7EE);

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    Widget pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
    Widget divider() => const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: SizedBox(height: 1, child: ColoredBox(color: ppLine)));

    return Scaffold(
      backgroundColor: ppBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // video hero
          SizedBox(
            height: 230,
            child: Stack(children: [
              const PpStriped(height: 230, colorA: Color(0xFFEFE7F5), colorB: ppStripeB),
              Positioned(
                top: 52,
                left: 20,
                right: 20,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, size: 16, color: ppInk),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                    child: Text('Healthier version · on', style: ppBody(11, color: ppBrown, w: FontWeight.w700)),
                  ),
                ]),
              ),
              Center(
                child: GestureDetector(
                  onTap: _soon,
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, color: ppPurple, size: 26),
                  ),
                ),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                  child: Text('2 yrs+', style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Flexible(
                    child: Text('15 min · easy · serves 2',
                        style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 12),
              Text('Veggie Maggi, the smarter way', style: ppFraunces(29, h: 1.15)),

              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() => _healthier = !_healthier),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Healthier version', style: ppJakarta(14)),
                        const SizedBox(height: 2),
                        Text('Carrots, peas + a ghee swap. Toggle off for plain.', style: ppBody(12)),
                      ]),
                    ),
                    const SizedBox(width: 13),
                    ppSwitch(_healthier),
                  ]),
                ),
              ),
            ]),
          ),

          pad(divider()),

          // nutrition
          pad(Text('Nutrition per serving', style: ppJakarta(17))),
          const SizedBox(height: 12),
          pad(Row(children: [
            _macro('180', 'kcal'),
            const SizedBox(width: 10),
            _macro('6g', 'protein'),
            const SizedBox(width: 10),
            _macro('4g', 'fibre'),
          ])),
          const SizedBox(height: 12),
          pad(Column(children: [
            _nutriRow('Vitamin A', ' (from carrots)', '35% RDA', top: true),
            _nutriRow('Iron', '', '12% RDA', top: true),
          ])),

          pad(divider()),
          pad(Text("Why it's good", style: ppJakarta(17))),
          const SizedBox(height: 10),
          pad(Text(
              'The veg boost adds fibre and vitamin A to a food kids already love, and the ghee swap makes it gentler than the packet masala alone. A comfort meal that quietly does more.',
              style: ppBody(14, h: 1.6))),

          pad(divider()),
          pad(Row(children: [
            Expanded(child: _note('Frequency', 'Once a week is plenty.', ppPurple)),
            const SizedBox(width: 12),
            Expanded(child: _note('Watch for', 'Still salty — use half the masala.', ppBrown)),
          ])),

          pad(divider()),
          pad(Text("You'll need", style: ppJakarta(17))),
          const SizedBox(height: 12),
          pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            _Ingredient('1 pack whole-wheat noodles'),
            _Ingredient('½ carrot, grated'),
            _Ingredient('2 tbsp peas'),
            _Ingredient('½ tsp ghee'),
            _Ingredient('Half the masala sachet'),
          ])),

          const SizedBox(height: 22),
          pad(Text('Method', style: ppJakarta(17))),
          const SizedBox(height: 12),
          pad(_method('1', 'Sauté carrot and peas in ghee for two minutes.', top: true)),
          pad(_method('2', 'Add noodles, water and half the masala; simmer.', top: true)),
          pad(_method('3', 'Cook till soft, cool a little, and serve.', top: true, bottom: true)),

          // customise for baby
          const SizedBox(height: 24),
          pad(Container(
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
              Text('Make the same dish safe and easy for a younger one — Aarav will be ready around 8 months.',
                  style: ppBody(13, h: 1.55)),
              const SizedBox(height: 16),
              _custom('Form', 'Chop noodles small or blend to a soft mash — no long strands.'),
              const SizedBox(height: 11),
              _custom('Ingredients', 'Skip the masala entirely; flavour with a pinch of jeera and the veggies alone.'),
              const SizedBox(height: 11),
              _custom('How to give', "Soft spoonfuls, cooled to lukewarm. Let him self-feed a few once he's grabbing."),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: _warnBg, borderRadius: BorderRadius.circular(12)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: ppBrown),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text('Introduce one new ingredient at a time, and only after solids have started.',
                        style: ppBody(12, color: ppBrown, h: 1.5)),
                  ),
                ]),
              ),
            ]),
          )),

          const SizedBox(height: 22),
          pad(Text('Nutrition, frequency and cautions on every recipe. Reviewed by a paediatric nutritionist.',
              textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
        ]),
      ),
    );
  }

  Widget _macro(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Text(value, style: ppJakarta(16), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(label, style: ppBody(10, color: ppMuted)),
          ]),
        ),
      );

  Widget _nutriRow(String name, String muted, String value, {bool top = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(border: Border(top: top ? const BorderSide(color: ppHair) : BorderSide.none)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: name, style: const TextStyle(color: ppSoft)),
              if (muted.isNotEmpty) TextSpan(text: muted, style: const TextStyle(color: ppMuted)),
            ]), style: ppBody(13)),
          ),
          const SizedBox(width: 10),
          Text(value, style: ppBody(13, color: ppInk, w: FontWeight.w600)),
        ]),
      );

  Widget _note(String label, String text, Color color) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppEyebrow(label, color: color, spacing: 0.6),
          const SizedBox(height: 6),
          Text(text, style: ppBody(14, color: ppInk, h: 1.5)),
        ]),
      );

  Widget _method(String n, String text, {bool top = false, bool bottom = false}) => Container(
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

  Widget _custom(String pill, String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 78,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
          child: Text(pill, style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
        ),
        const SizedBox(width: 11),
        Expanded(child: Text(text, style: ppBody(13, color: ppInk, h: 1.5))),
      ]);
}

class _Ingredient extends StatelessWidget {
  const _Ingredient(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
          ),
          const SizedBox(width: 11),
          Expanded(child: Text(text, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );
}
