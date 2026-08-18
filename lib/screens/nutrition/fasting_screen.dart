// =============================================================================
//  Fasting — plain, safe, non-preachy
// -----------------------------------------------------------------------------
//  Named fasts first, since that is what she searched for; general safety
//  guidance after, so it reads as support for a choice already being made
//  rather than a gate in front of it. Nothing here tells her whether to fast —
//  see `should_i_fast` in `nutrition_data.dart`, which says so outright.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/nutrition_data.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';

class FastingScreen extends StatelessWidget {
  const FastingScreen({super.key});

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
            title: Text('Fasting', style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                Text('Fasting in pregnancy is a personal choice. Here is how to make '
                    'it a safer one, whatever you decide.',
                    style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
                const SizedBox(height: 18),
                Text('By occasion',
                    style: pvManrope(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: p.ink3)),
                const SizedBox(height: 10),
                for (final f in kFastingByOccasion) ...[
                  _FastingCard(p: p, topic: f),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 12),
                Text('General guidance',
                    style: pvManrope(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: p.ink3)),
                const SizedBox(height: 10),
                for (final f in kFastingGeneral) ...[
                  _FastingCard(p: p, topic: f),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FastingCard extends StatelessWidget {
  const _FastingCard({required this.p, required this.topic});
  final V2Palette p;
  final FastingTopic topic;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(topic.title.now, style: pvFraunces(fontSize: 16, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 7),
        Text(topic.body.now, style: pvManrope(fontSize: 13.5, height: 1.55, color: p.ink2)),
      ]),
    );
  }
}
