// =============================================================================
//  Nutrients — what each one does, and whether you need a supplement
// -----------------------------------------------------------------------------
//  A scrollable list of nutrient cards, followed by practical whole-diet
//  cards ("is my thali enough?"), and closing with a dietician explainer
//  video and the Expert options block — the third of the three places that
//  block is allowed, per `nutrition_stage_screen.dart`'s header.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/nutrition_data.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_placeholders.dart';
import '../v2/v2_palette.dart';
import 'nutrition_stage_screen.dart';

class NutrientsScreen extends StatelessWidget {
  const NutrientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text('Nutrients', style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                Text('What each one does for you and your baby, and the everyday '
                    'Indian foods that give it to you.',
                    style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
                const SizedBox(height: 18),
                for (final n in kNutrientGuides) ...[
                  _NutrientRow(
                    p: p,
                    guide: n,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => NutrientDetailScreen(guide: n),
                    )),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 16),
                Text('The bigger questions',
                    style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
                const SizedBox(height: 4),
                Text('Whole-diet questions mothers ask most.',
                    style: pvManrope(fontSize: 12.5, color: p.ink3)),
                const SizedBox(height: 12),
                for (final c in kNutritionPracticalCards) ...[
                  _PracticalCard(p: p, card: c),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 20),
                const PvVideoPlaceholder(
                  title: 'Do I actually need supplements?',
                  subtitle: 'A dietician walks through what food covers, and what it usually does not.',
                  hue: 104,
                ),
                const SizedBox(height: 20),
                const ExpertOptionsBlock(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({required this.p, required this.guide, required this.onTap});
  final V2Palette p;
  final NutrientGuide guide;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
          child: Row(children: [
            Expanded(
              child: Text(guide.name.now, style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

class _PracticalCard extends StatelessWidget {
  const _PracticalCard({required this.p, required this.card});
  final V2Palette p;
  final NutritionPracticalCard card;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(card.title.now, style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1)),
        const SizedBox(height: 6),
        Text(card.body.now, style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
      ]),
    );
  }
}

class NutrientDetailScreen extends StatelessWidget {
  const NutrientDetailScreen({super.key, required this.guide});
  final NutrientGuide guide;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(guide.name.now, style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
              children: [
                _Section(p: p, title: 'What it does for you and baby', body: guide.whatItDoes.now),
                const SizedBox(height: 20),
                Text('Everyday foods that give you this',
                    style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, color: p.ink1)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final f in guide.foods)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: p.line),
                        ),
                        child: Text(f.now, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                _Section(p: p, title: 'Do I need a supplement?', body: guide.supplementNote.now),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.p, required this.title, required this.body});
  final V2Palette p;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, color: p.ink1)),
      const SizedBox(height: 8),
      Text(body, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink1)),
    ]);
  }
}
