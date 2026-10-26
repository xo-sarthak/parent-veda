// =============================================================================
//  Moment paintings (2026-10-26, stage transitions item 4)
// -----------------------------------------------------------------------------
//  Every celebration page (PvCelebrationScreen) borrowed a phase painting: the
//  birth, trying again and a new pregnancy all showed phase 1, turning six
//  showed phase 20, and a milestone showed the child's own phase. Each moment
//  now has a painting of its own, in the house style of the twenty phase
//  paintings, from the prompts in docs/MOMENT-PAINTING-PROMPTS.md.
//
//  ⚠️ A PAGE NEVER LOADS A PICTURE THAT IS NOT THERE (the activity paintings'
//  rule, pp_activity_paintings.dart). A moment shows its painting only once it
//  is in kMomentPaintings; until then the page keeps the phase painting it had.
//  Adding one is: drop the file in assets/moments/<file>.webp (1024 square,
//  like assets/phases/) and add the moment here. The pubspec entry is already
//  there. The errorBuilder is a second net, not the switch.
//
//  The positive test keeps its own page (TtcPositiveTestScreen) and is not a
//  moment here.
// =============================================================================

import 'package:flutter/material.dart';

/// The moments a celebration page marks, each with its file name.
enum PvMoment {
  birth('birth'),
  tryAgain('try_again'),
  newPregnancy('new_pregnancy'),
  turningSix('turning_six'),
  milestone('milestone');

  const PvMoment(this.file);

  /// The file name under assets/moments/, without `.webp`.
  final String file;

  String get assetPath => 'assets/moments/$file.webp';
}

/// The moments whose painting is in assets/moments/. All five landed
/// 2026-10-26 (made by the user from docs/MOMENT-PAINTING-PROMPTS.md).
const Set<PvMoment> kMomentPaintings = {
  PvMoment.birth,
  PvMoment.tryAgain,
  PvMoment.newPregnancy,
  PvMoment.turningSix,
  PvMoment.milestone,
};

/// The painting a celebration page shows for [moment], or [fallback] (the
/// phase painting it borrowed until now) while the file is not there.
class PvMomentPainting extends StatelessWidget {
  const PvMomentPainting({
    super.key,
    required this.moment,
    required this.fallback,
  });

  final PvMoment moment;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    if (!kMomentPaintings.contains(moment)) return fallback;
    return Image.asset(
      moment.assetPath,
      key: ValueKey('pv_moment_${moment.file}'),
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
