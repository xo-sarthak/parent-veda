// =============================================================================
//  A consult door must reach the person it names
// -----------------------------------------------------------------------------
//  ⚠️ THE FAILURE THIS GUARDS IS SILENT BY CONSTRUCTION, WHICH IS WHY IT NEEDS
//  A TEST RATHER THAN CARE.
//
//  `pp_experts/<category>` falls back to the unfiltered roster when the
//  category matches no expert. That fallback is the right runtime behaviour —
//  a full list beats a blank screen for a parent who needs somebody tonight —
//  but it means a TYPO LOOKS EXACTLY LIKE SUCCESS. The tap works, a screen of
//  real experts appears, and the only symptom is that the filter the label
//  promised was never applied.
//
//  It also caught a real gap the moment it was written: the Sleep hub says
//  "Talk to a sleep expert" and no sleep expert exists in the roster at all.
//  See D2 in docs/PARENTING-REVIEW.md.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/hubs/parenting_hubs.dart';
import 'package:parentveda/screens/brackets/hub/hub_config.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_experts_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';

void main() {
  const prefix = 'pp_experts/';

  /// Every parenting hub. All of them, not a chosen two — the first version
  /// of this file listed only Sleep and Feeding, which is why five hubs with
  /// no expert offer at all went unnoticed until somebody counted by hand.
  List<HubConfig> hubs() => [
        kPpSleep,
        kPpFeeding,
        kPpHealth,
        kPpDevelopment,
        kPpBehaviour,
        kPpPotty,
        kPpEarlyLearning,
        kPpFirst40,
        kPpMaternal,
        kPpTraditional,
      ];

  test('a filtered consult names a category that has experts behind it', () {
    for (final h in hubs()) {
      final id = h.closing?.surfaceId;
      if (id == null || !id.startsWith(prefix)) continue;

      final category = id.substring(prefix.length);

      // The category must be a real need...
      final need = kFindHelpNeeds.where((n) => n.category == category);
      expect(need, isNotEmpty,
          reason: '${h.bracketId} filters to "$category", which is not in '
              'kFindHelpNeeds. It would fall back to the full roster and look '
              'like it worked.');

      // ...and that need must have somebody in it. A category with an empty
      // roster is the worse half of this bug: the filter applies correctly and
      // she is shown nobody.
      expect(expertsForNeed(category), isNotEmpty,
          reason: '${h.bracketId} filters to "$category" and no expert has '
              'that category. She would land on an empty list.');
    }
  });

  test('the feeding consult reaches lactation, not the whole roster', () {
    // Named explicitly rather than left to the loop above, because this is the
    // one the feedback actually reported: "Talk to a lactation expert should
    // land user to 1 on 1 call with lactation expert filter applied."
    expect(kPpFeeding.closing?.surfaceId, 'pp_experts/Lactation expert');
    expect(expertsForNeed('Lactation expert').length, greaterThanOrEqualTo(2),
        reason: 'A filtered roster with one person in it reads as a broken '
            'filter rather than as a short list.');
  });

  test('an unfiltered consult is a decision, not an oversight', () {
    // ⚠️ THIS TEST EXISTS TO STOP THE SLEEP GAP BEING QUIETLY "FIXED".
    //
    // The symmetric change on the Sleep hub is one line, and the next person
    // to read these two hubs side by side will be tempted by it. It would
    // compile, pass the loop above only if a category existed, and otherwise
    // fall back invisibly. If sleep supply is ever seeded, this test fails and
    // makes you set the filter deliberately.
    final sleepHasSupply = kFindHelpExperts.any(
        (e) => e.category.toLowerCase().contains('sleep'));
    if (!sleepHasSupply) {
      expect(kPpSleep.closing?.surfaceId, isNull,
          reason: 'The sleep consult must stay unfiltered while no sleep '
              'expert exists, or it silently falls back to everyone.');
    } else {
      expect(kPpSleep.closing?.surfaceId, isNotNull,
          reason: 'Sleep supply now exists, so the door that names a sleep '
              'expert should filter to one. See D2.');
    }
  });

  test('a hub that names one kind of person filters to them', () {
    // ⚠️ THE FAILURE THIS CATCHES IS "THE LABEL AND THE LIST DISAGREE".
    // Every closing offer here names a profession in its own label. Opening
    // the full roster from it is not a crash and not an empty screen — it is
    // just a different person at the top of the list than the one she tapped
    // for.
    for (final h in hubs()) {
      final c = h.closing;
      if (c == null) continue;
      expect(c.surfaceId, isNotNull,
          reason: '${h.bracketId} offers a consult and does not say who. '
              'Every category now has supply, seeded or real, so there is no '
              'longer a reason to leave one unfiltered.');
    }
  });

  test('a one-door hub consult offer must name a surface', () {
    // ⚠️ THIS RULE INVERTED, AND THE ORIGINAL WAS RIGHT WHEN WRITTEN.
    //
    // It said a one-door hub must carry NO closing, because such a hub never
    // renders a hub screen — the tile opens its door's destination directly.
    // True of the hub, false of the bracket: the door lands on
    // `PpSectionScreen`, which now draws the closing (and the section's tools)
    // when it is the top screen. See `pp_section_tools_test.dart` for what that
    // fixed — seventeen tools that were declared and drawn by nothing.
    //
    // What survives is the narrower constraint: that screen has no `onAction`,
    // so a closing it draws has to route by SURFACE. A card whose tap does
    // nothing is worse than no card.
    for (final h in hubs()) {
      if (h.needs.length > 1) continue;
      final c = h.closing;
      if (c == null) continue;
      expect(c.surfaceId, isNotNull,
          reason: '${h.bracketId} has one door, so its consult offer is drawn '
              'by the section screen — which has no onAction and would render '
              'a card that does nothing when tapped.');
    }
  });

  test('a seeded category is still a real, non-empty list', () {
    // Seeding exists so the path works before supply does. A seeded category
    // with nobody in it would be the worst of both: the filter applies and she
    // meets an empty screen.
    for (final n in kFindHelpNeeds) {
      expect(expertsForNeed(n.category), isNotEmpty,
          reason: '"${n.category}" is offered as a need and has nobody in it.');
    }
  });

  test('every placeholder is findable in one place', () {
    // ⚠️ THIS IS THE TEST THAT MAKES SEEDING HONEST. Placeholder people are
    // only acceptable because they are labelled and enumerable — the day real
    // supply arrives, `kSeededExpertIds` is the list to work through. An
    // unflagged placeholder is indistinguishable from a real expert, which is
    // how a fake name ships.
    expect(kSeededExpertIds, isNotEmpty);
    for (final id in kSeededExpertIds) {
      expect(id.startsWith('seed_'), isTrue,
          reason: '"$id" is flagged seeded but is not named like a seed. '
              'The prefix is what makes them greppable without this list.');
    }
    // And nothing unflagged should be pretending.
    for (final e in kFindHelpExperts) {
      if (e.id.startsWith('seed_')) {
        expect(e.seeded, isTrue,
            reason: '"${e.id}" looks like a seed and is not flagged as one.');
      }
    }
  });

  group('a consult block reaches the person it names', () {
    List<PpConsult> allConsults() => [
          for (final s in kPpSections)
            for (final p in s.allPages)
              for (final b in p.blocks)
                if (b is PpConsult) b,
        ];

    test('every mapped role points at a category with experts behind it', () {
      for (final entry in kPpConsultRoleToCategory.entries) {
        expect(kFindHelpNeeds.any((n) => n.category == entry.value), isTrue,
            reason: 'role "${entry.key}" maps to "${entry.value}", which is '
                'not a FindHelpNeed. It would fall back to the full roster.');
        expect(expertsForNeed(entry.value), isNotEmpty,
            reason: 'role "${entry.key}" maps to "${entry.value}", which has '
                'no experts. She would land on an empty list.');
      }
    });

    test('a mapped consult actually resolves to a filtered surface', () {
      // ⚠️ ONLY CONSULTS THAT TARGET THE ROSTER. A `PpConsult` can point at
      // `pp_courses` — "the early learning masterclass" does — and carry a role
      // describing who teaches it. Rewriting that surface would send a parent
      // who wanted a recorded class to a list of people to book instead.
      //
      // The first version of this test asserted over every mapped role and
      // failed on exactly that block. The role is not wrong and the surface is
      // not wrong; the assertion was.
      final mapped = allConsults().where((c) =>
          c.surfaceId == 'pp_experts' &&
          kPpConsultRoleToCategory.containsKey(c.role));
      expect(mapped, isNotEmpty,
          reason: 'No consult carries a mapped role. Either the content lost '
              'its roles or the map went stale.');
      for (final c in mapped) {
        expect(c.surface, startsWith('pp_experts/'),
            reason: '"${c.title}" has role "${c.role}" and still opens the '
                'unfiltered roster.');
      }
    });

    test('unmapped roles are named, so the gap stays visible', () {
      // ⚠️ THIS TEST DOES NOT FAIL ON A GAP, AND THAT IS THE POINT.
      //
      // Ten of the fourteen roles in the parenting content — physio, sleep,
      // nutrition, maternal_mental_health, the group ones — have no expert in
      // the roster at all. Failing here would block every build over a supply
      // decision nobody can make in code. Printing keeps it in front of
      // whoever runs the suite instead of letting it disappear into a
      // fallback that looks like success.
      final unmapped = <String>{
        for (final c in allConsults())
          if (c.role != null && !kPpConsultRoleToCategory.containsKey(c.role))
            c.role!,
      };
      if (unmapped.isNotEmpty) {
        // ignore: avoid_print
        print('CONSULT ROLES WITH NO EXPERT SUPPLY: ${unmapped.toList()..sort()}');
      }
      expect(true, isTrue);
    });
  });
}
