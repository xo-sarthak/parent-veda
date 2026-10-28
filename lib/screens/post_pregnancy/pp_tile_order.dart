// =============================================================================
//  The order of the home's door tiles (2026-10-07)
// -----------------------------------------------------------------------------
//  Gap analysis P2 (The home, and onboarding's "keep the promises"): "Order
//  tiles by age band and by her priorities." Personalisation changes ORDER,
//  never structure (CLAUDE.md): every tile is always there; only the sequence
//  moves.
//
//  A score per door, highest first, ties keep the authored order:
//    * the age:  First 40 days leads in the first six weeks; Potty, Behaviour
//      and Early learning rise after the first birthday; Sleep and Feeding
//      lead in the first two years.
//    * her priorities from setup (each matching door rises).
//    * a C-section birth: You, Maa rises for the first three months, so she
//      is led to her own recovery pages.
// =============================================================================

import '../../services/family_profile.dart';
import 'pp_relevance.dart' show PpSignal;

/// ON since 2026-10-07 evening (the user: "You can turn that switch on").
/// Before that it waited: on 2026-09-18 they asked for the doors in
/// registry order ("like the way it was"). Flip to true to order by age and
/// her priorities. Read by PpHomeV3._tilesOrder.
const bool kPpTileOrderByAge = true;

const Map<Priority, String> _kPriorityDoor = {
  Priority.sleep: 'parenting_sleep',
  Priority.feeding: 'parenting_feeding',
  Priority.nutrition: 'parenting_feeding',
  Priority.development: 'parenting_development',
  Priority.milestones: 'parenting_development',
  Priority.brain: 'parenting_development',
  Priority.behaviour: 'parenting_behaviour',
  Priority.learning: 'parenting_early_learning',
  Priority.play: 'parenting_early_learning',
  Priority.health: 'parenting_health',
};

int _ageScore(String id, int days) {
  final months = days ~/ 30;
  return switch (id) {
    'parenting_first_40' => days <= 45 ? 50 : (months < 3 ? 5 : -20),
    'parenting_sleep' || 'parenting_feeding' => months < 24 ? 20 : 5,
    'parenting_health' => 15,
    'parenting_development' => months < 36 ? 12 : 6,
    'parenting_potty' => months >= 18 && months < 48 ? 18 : -15,
    'parenting_behaviour' => months >= 12 ? 14 : -5,
    'parenting_early_learning' => months >= 12 ? 12 : 0,
    'parenting_safety' => months >= 5 && months < 36 ? 10 : 4,
    _ => 0,
  };
}

/// Door ids in the order the home shows them.
List<String> ppTileOrder(
  List<String> ids, {
  required int ageInDays,
  Set<Priority> priorities = const {},
  BirthMode? birthMode,
  Set<PpSignal> signals = const {},
}) {
  final want = {for (final p in priorities) _kPriorityDoor[p]};
  int score(String id) {
    var s = _ageScore(id, ageInDays);
    if (want.contains(id)) s += 25;
    if (id == 'parenting_maternal' && birthMode == BirthMode.cSection && ageInDays < 90) s += 30;
    // The relevance brain's signals (2026-10-21, Wave 4, pp_relevance.dart):
    // born early lifts Development (corrected age lives there), and how she
    // feeds lifts Feeding while it is the daily question.
    if (id == 'parenting_development' && signals.contains(PpSignal.bornEarly)) s += 20;
    if (id == 'parenting_feeding' &&
        ageInDays < 365 &&
        (signals.contains(PpSignal.formula) || signals.contains(PpSignal.breastfeeding))) {
      s += 10;
    }
    return s;
  }

  final indexed = [for (var i = 0; i < ids.length; i++) (i, ids[i])];
  indexed.sort((a, b) {
    final d = score(b.$2).compareTo(score(a.$2));
    return d != 0 ? d : a.$1.compareTo(b.$1);
  });
  return [for (final x in indexed) x.$2];
}

/// Why the grid is not in the age order (relevance PP 9, 2026-10-28): one
/// line for the highest tile HER answers lifted, in item 12's words. Null
/// when only age moved tiles: every child that age sees that order, so there
/// is nothing about her to explain. [label] names a door id on screen.
///
/// A tile can only rise through its own bonus (every bonus is positive), so a
/// tile that sits earlier than it would by age alone was lifted by her.
String? ppTileWhy(
  List<String> ids, {
  required int ageInDays,
  required String Function(String id) label,
  Set<Priority> priorities = const {},
  BirthMode? birthMode,
  Set<PpSignal> signals = const {},
}) {
  final hers = ppTileOrder(ids,
      ageInDays: ageInDays, priorities: priorities, birthMode: birthMode, signals: signals);
  final byAge = ppTileOrder(ids, ageInDays: ageInDays);
  for (var i = 0; i < hers.length; i++) {
    final id = hers[i];
    if (i >= byAge.indexOf(id)) continue;
    final because = _tileBecause(id, ageInDays, priorities, birthMode, signals);
    if (because == null) continue;
    // A grid has no single "here", so the tile is named: item 12's words with
    // the door in front ("Sleep is first here, because ...").
    return i == 0
        ? '${label(id)} is first here, because $because.'
        : '${label(id)} moved up, because $because.';
  }
  return null;
}

String? _tileBecause(String id, int days, Set<Priority> priorities, BirthMode? birthMode, Set<PpSignal> signals) {
  for (final p in priorities) {
    if (_kPriorityDoor[p] == id) return 'you chose ${p.label.toLowerCase()} in your family setup';
  }
  if (id == 'parenting_maternal' && birthMode == BirthMode.cSection && days < 90) {
    return 'you are recovering from a C-section';
  }
  if (id == 'parenting_development' && signals.contains(PpSignal.bornEarly)) {
    return 'your baby was born early';
  }
  if (id == 'parenting_feeding' &&
      days < 365 &&
      (signals.contains(PpSignal.formula) || signals.contains(PpSignal.breastfeeding))) {
    return 'of how your baby feeds';
  }
  return null;
}
