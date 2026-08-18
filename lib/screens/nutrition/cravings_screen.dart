// =============================================================================
//  Cravings — short, reassuring cards
// -----------------------------------------------------------------------------
//  No verdicts, no tags. This is the calmest page in the section on purpose:
//  cravings are near-universal and mostly harmless, and the page should read
//  that way at a glance rather than making her hunt for reassurance.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/nutrition_data.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';

class CravingsScreen extends StatelessWidget {
  const CravingsScreen({super.key});

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
            title: Text('Cravings', style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                Text('Wanting strange things, and not wanting favourite things, are '
                    'both completely normal here.',
                    style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
                const SizedBox(height: 18),
                for (final c in kCravingCards) ...[
                  _CravingCardView(p: p, card: c),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CravingCardView extends StatelessWidget {
  const _CravingCardView({required this.p, required this.card});
  final V2Palette p;
  final CravingCard card;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(card.title.now, style: pvFraunces(fontSize: 16, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 7),
        Text(card.body.now, style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2)),
      ]),
    );
  }
}
