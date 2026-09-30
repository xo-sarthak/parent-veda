// =============================================================================
//  The order of the pregnancy home's door tiles — 2026-09-30
// -----------------------------------------------------------------------------
//  From the pregnancy gap analysis, "Order the door tiles by her week and her
//  answers" (P2): the tiles never moved, although onboarding asks "What would
//  you most like help with?" and promises "Your home will lead with these".
//  What to Expect changes its topic chips by trimester.
//
//  THE RULE, in the PDF's order:
//    1. What she chose in onboarding, first.
//    2. Then what her trimester needs: first trimester leads with Symptoms,
//       Is it safe? and Scans & tests; from week 32 Labour prep leads.
//    3. Then everything else, in the table's own order.
//
//  ⚠️ THIS IS RANKING, NEVER STRUCTURE. The function returns EVERY bracket it
//  was given, once, so it cannot hide a door; the grid keeps its shape and its
//  four columns; nothing is added. That is the personalisation rule in
//  CLAUDE.md ("changes content, ranking and order — never structure"), and it
//  is the same contract as `FamilyProfileStore.orderByPregPriority`.
//
//  ⚠️ THE TABLE ORDER STAYS THE DEFAULT AND THE TIE-BREAKER. `pregnancy_
//  brackets.dart` ranks its doors by demand (Scans & tests is the
//  highest-volume entry point in the product), so a mother with no answers and
//  a week in the second trimester sees exactly what she saw before. Inside each
//  tier the sort is stable, so two chosen doors keep their table order rather
//  than a new one somebody would have to defend.
//
//  ⚠️ IT TAKES THE WEEK SHE IS IN, NOT THE DAY SHE IS BROWSING. The home's day
//  strip lets her look at other days; if the tiles followed the strip they
//  would shuffle under her thumb. The caller passes `PregnancyController.
//  currentWeek`, which moves once a week.
//
//  It is a pure function on purpose: the order is a rule with a week and a set
//  of answers going in and a list coming out, so a test can pin every case
//  without building a screen. A rule that only exists inside a build method can
//  only be tested by looking at pixels.
// =============================================================================

import '../models/bracket.dart';
import 'family_profile.dart';

/// The door each onboarding answer points at. Not every answer has an obvious
/// door, and where it does not the answer is the nearest honest one:
///  - sleep lands on Symptoms, where the night-time complaints live;
///  - "how the baby's growing" lands on Scans & tests, where she sees it.
const Map<PregPriority, String> kPregPriorityDoor = {
  PregPriority.nutrition: 'pregnancy_nutrition',
  PregPriority.sleep: 'pregnancy_symptoms',
  PregPriority.anxiety: 'pregnancy_mental_health',
  PregPriority.birthPrep: 'pregnancy_labour',
  PregPriority.fitness: 'pregnancy_fitness',
  PregPriority.babyDevelopment: 'pregnancy_scans_tests',
  PregPriority.symptoms: 'pregnancy_symptoms',
};

/// From this week the birth is close enough that Labour prep leads.
const int kPregLabourLeadsFromWeek = 32;

/// The last week of the first trimester.
const int kPregFirstTrimesterEnd = 13;

/// Doors the trimester puts forward, in the order they lead.
///
/// The PDF names the first trimester (Symptoms, Is it safe?, Scans) and the
/// third from week 32 (Labour prep). The second trimester, and weeks 28 to 31,
/// name nothing, so they lead with nothing: the table's own order stands.
List<String> pregTrimesterLeads(int week) {
  if (week <= kPregFirstTrimesterEnd) {
    return const [
      'pregnancy_symptoms',
      'pregnancy_is_it_safe',
      'pregnancy_scans_tests',
    ];
  }
  if (week >= kPregLabourLeadsFromWeek) return const ['pregnancy_labour'];
  return const [];
}

/// [all] in the order the home shows it for a mother in [week] who chose
/// [priorities]. Returns every bracket in [all], once each.
List<Bracket> orderPregnancyTiles(
  List<Bracket> all, {
  required int week,
  required Set<PregPriority> priorities,
}) {
  final chosen = {for (final p in priorities) kPregPriorityDoor[p]!};
  final leads = pregTrimesterLeads(week);

  int tier(Bracket b) {
    if (chosen.contains(b.id)) return 0;
    if (leads.contains(b.id)) return 1;
    return 2;
  }

  final scored = <(int, int, int, Bracket)>[
    for (var i = 0; i < all.length; i++)
      (
        tier(all[i]),
        // Inside the trimester tier the PDF's own order leads; inside the other
        // two the table's order does (see the note at the top).
        tier(all[i]) == 1 ? leads.indexOf(all[i].id) : i,
        i,
        all[i],
      ),
  ];
  scored.sort((a, b) {
    if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
    if (a.$2 != b.$2) return a.$2.compareTo(b.$2);
    return a.$3.compareTo(b.$3);
  });
  return [for (final s in scored) s.$4];
}
