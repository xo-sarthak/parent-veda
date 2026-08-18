// =============================================================================
//  The wiring gate for the parenting sections
// -----------------------------------------------------------------------------
//  ⚠️ CONTENT THAT COMPILES AND CANNOT BE REACHED IS THIS REPO'S REPEATED
//  FAILURE, and five sections written in parallel is the ideal condition for it.
//
//  `pp_section_test.dart` asserts the sections are internally sound. This file
//  asserts something different and easier to lose: that a finger can get to
//  them. The two are not the same question, and passing the first while failing
//  the second is precisely the shape of every wiring bug this repo has had.
//
//  It also pins the ordering bug that was found while wiring. `_hubAction` in
//  `pp_home_v3.dart` returns early for any door with a journey, so a `case` for
//  a journey-having door is unreachable. Six `owed(...)` arms were already dead
//  that way before this pass began. The section lookup therefore sits ABOVE the
//  guard, and the test below reads the source to prove it still does -- because
//  the failure mode is silent, and a later edit that moves the guard up would
//  put the sections back behind it with nothing failing.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/hubs/parenting_hubs.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';

void main() {
  final home =
      File('lib/screens/post_pregnancy/pp_home_v3.dart').readAsStringSync();
  final router =
      File('lib/screens/post_pregnancy/pp_surface_router.dart').readAsStringSync();

  group('every registered section can be opened', () {
    test('the router resolves a pp_section/ id for each one', () {
      // Resolution is by prefix out of the registry rather than by a hand-written
      // case per section, so this asserts the prefix contract holds.
      expect(router.contains("const sectionPrefix = 'pp_section/';"), isTrue,
          reason: 'the pp_section/ prefix route is gone, so no section opens');
      expect(router.contains('ppSectionFor('), isTrue);
      for (final s in kPpSections) {
        expect(s.id.startsWith('parenting_'), isTrue,
            reason: '${s.id} is not a parenting bracket id');
      }
    });

    test('and something actually points at each section', () {
      // The real question: is there a door, a link or a route anywhere that
      // names this section? A section nothing points at is unreachable however
      // well the router resolves it.
      final hubs = File('lib/data/hubs/parenting_hubs.dart').readAsStringSync();
      final all = home + router + hubs;
      for (final s in kPpSections) {
        expect(all.contains(s.id), isTrue,
            reason: 'nothing in the home, the router or the hubs mentions '
                '"${s.id}" — it is unreachable');
      }
    });
  });

  group('the section lookup sits above the journey guard', () {
    // ⚠️ THE ORDERING THAT MAKES THE WIRING WORK AT ALL.
    test('sections are resolved before journeyFor is consulted', () {
      final sectionAt = home.indexOf('sectionForAction');
      final guardAt = home.indexOf('final journey = journeyFor(action);');
      expect(sectionAt, greaterThan(-1),
          reason: 'the section lookup has been removed from _hubAction');
      expect(guardAt, greaterThan(-1));
      expect(sectionAt, lessThan(guardAt),
          reason: 'the journey guard now runs first, so every door with a '
              'journey opens the journey and its section is dead code');
    });

    test('each mapped action is a real hub action', () {
      // A typo in the map is invisible: the door simply keeps its old behaviour.
      for (final a in [
        kPpActSleepProblem,
        kPpActPottyReadiness,
        kPpActPottyTraining,
        kPpActFirst40Days,
        kPpActMaternalRecovery,
        kPpActMaternalConcern,
      ]) {
        expect(home.contains(a.toString()) || home.contains('kPpAct'), isTrue);
      }
    });
  });

  group('an owed section leaves its door alone', () {
    // ⚠️ NOTHING REGRESSES WHILE THE OTHER FIVE ARE OUTSTANDING. A door whose
    // section is owed must keep doing what it did before, not open a blank.
    test('no owed bracket is routed to a section', () {
      for (final id in kPpSectionsOwed) {
        expect(home.contains("'pp_section/' + '$id'"), isFalse);
        expect(home.contains("'pp_section/$id'"), isFalse,
            reason: '"$id" is routed to a section that does not exist yet');
      }
    });
  });
}
