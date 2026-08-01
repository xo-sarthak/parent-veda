// =============================================================================
//  Grow — three versions of one feature, held apart by tests.
// -----------------------------------------------------------------------------
//  The point of building three is to compare them. That only works if each one
//  keeps being what it claims to be, so these tests pin the CLAIMS rather than
//  the pixels:
//
//    * V1 is untouched — the eight original activities, still eight.
//    * The brief's five capabilities cannot reach every activity. That is
//      arithmetic, not an opinion, so it is asserted rather than argued.
//    * V3's six can reach all of them.
//    * The streak breaks and the week ribbon does not — the one real
//      behavioural disagreement between V2 and V3.
//    * Every age tag parses, so no activity is silently unreachable.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_grow_activities.dart';
import 'package:parentveda/screens/post_pregnancy/pp_grow_data.dart';

void main() {
  reachability();
  docReading();
  group('V1 is genuinely untouched', () {
    test('the original library still has exactly its eight activities', () {
      // If this fails, someone "improved" V1 while adding to V2/V3 and the
      // comparison is no longer against what ships.
      expect(kDevActivities, hasLength(8));
    });

    test('the widened library contains every original one, unchanged', () {
      for (final a in kDevActivities) {
        expect(kGrowActivities.contains(a), isTrue,
            reason: '"${a.title}" was dropped or edited on the way into Grow');
      }
    });

    test('the eight areas are all still there', () {
      expect(kDevAreas, hasLength(8));
    });
  });

  group('the content gap the brief did not mention', () {
    test('the library is now big enough for a daily habit', () {
      // The brief asks for a 14-day streak. Eight activities cannot support
      // that: a parent sees a repeat on day nine.
      expect(kGrowActivities.length, greaterThanOrEqualTo(30),
          reason: 'a daily feature needs more days of content than it has days '
              'of streak');
    });

    test('every part of birth-to-five has something', () {
      // The original eight were ALL infant activities. A five-year-old had
      // nothing at all.
      for (final months in [1, 6, 12, 18, 30, 42, 54]) {
        final forAge =
            kGrowActivities.where((a) => growSuitsAge(a, months)).toList();
        expect(forAge, isNotEmpty,
            reason: 'nothing in the library suits a $months-month-old');
      }
    });

    test('every age tag parses', () {
      // A tag the parser cannot read makes an activity unreachable from every
      // age band, and nothing looks broken. So it fails here instead.
      for (final a in kGrowActivities) {
        expect(growAgeRange(a), isNotNull,
            reason: '"${a.title}" has an unreadable ageTag: "${a.ageTag}"');
      }
    });

    test('an age range is never inverted', () {
      for (final a in kGrowActivities) {
        final r = growAgeRange(a)!;
        expect(r.$1, lessThan(r.$2),
            reason: '"${a.title}" spans ${r.$1}..${r.$2} months');
      }
    });
  });

  group('capabilities', () {
    test("the brief's five leave activities unreachable", () {
      // NOT a criticism dressed as a test — a count. The brief lists five
      // capabilities, the library has eight areas, and self-care maps to none
      // of the five. This is the number.
      final orphaned = orphanedUnder(kDocCapabilities);
      expect(orphaned, isNotEmpty,
          reason: 'if this ever passes, the mapping changed and V3 no longer '
              'has a problem to solve — delete the sixth capability');
      expect(orphaned.every((a) => a.areaId == 'selfcare'), isTrue,
          reason: 'self-care was the known gap; something else is orphaned now');
    });

    test("V3's six reach everything", () {
      expect(orphanedUnder(kGrowCapabilities), isEmpty);
    });

    test('every capability covers at least one real area', () {
      final areaIds = kDevAreas.map((a) => a.id).toSet();
      for (final c in kGrowCapabilities) {
        expect(c.areaIds, isNotEmpty, reason: '${c.label} covers nothing');
        for (final id in c.areaIds) {
          expect(areaIds.contains(id), isTrue,
              reason: '${c.label} points at area "$id", which does not exist');
        }
      }
    });

    test('no area is claimed by two capabilities', () {
      // Overlap would double-count an activity on the hero and make the
      // "supports" chips misleading.
      final seen = <String, String>{};
      for (final c in kGrowCapabilities) {
        for (final id in c.areaIds) {
          expect(seen.containsKey(id), isFalse,
              reason: 'area "$id" is in both ${seen[id]} and ${c.label}');
          seen[id] = c.label;
        }
      }
    });

    test('every capability has activities a parent can actually open', () {
      // A feature is never hidden — but an empty capability tile is a hidden
      // feature with a label on it.
      for (final c in kGrowCapabilities) {
        expect(c.activities, isNotEmpty, reason: '${c.label} has none');
      }
    });

    test('V2 gets five, V3 gets six', () {
      expect(capabilitiesFor(GrowVersion.v2), hasLength(5));
      expect(capabilitiesFor(GrowVersion.v3), hasLength(6));
      expect(capabilitiesFor(GrowVersion.v1), hasLength(6));
    });
  });

  group("today's pick", () {
    test('is stable for a given day', () {
      // "The best activity for today" that reshuffles on every open was never
      // a recommendation.
      final d = DateTime(2026, 8, 1);
      final a = growPickFor(d, ageMonths: 8);
      for (var i = 0; i < 5; i++) {
        expect(growPickFor(d, ageMonths: 8).id, a.id);
      }
    });

    test('moves on the next day', () {
      final a = growPickFor(DateTime(2026, 8, 1), ageMonths: 8);
      final b = growPickFor(DateTime(2026, 8, 2), ageMonths: 8);
      expect(a.id, isNot(b.id));
    });

    test('does not repeat inside a fortnight, at any age', () {
      // The specific failure the eight-activity library would have had — and
      // the one a strict age filter reintroduces even with 47 activities,
      // because only four of them suit a 30-month-old exactly.
      for (final months in [1, 8, 18, 30, 48, 60]) {
        final seen = <String>{};
        for (var i = 0; i < 14; i++) {
          final a = growPickFor(DateTime(2026, 8, 1).add(Duration(days: i)),
              ageMonths: months);
          expect(seen.add(a.id), isTrue,
              reason: 'at $months mo, "${a.title}" came round again on '
                  'day ${i + 1}');
        }
      }
    });

    test('the pool is never thinner than a fortnight', () {
      for (var m = 0; m <= 72; m++) {
        expect(growActivitiesForAge(m).length, greaterThanOrEqualTo(14),
            reason: 'only ${growActivitiesForAge(m).length} to draw on at $m mo');
      }
    });

    test('suits the age it was picked for', () {
      for (final months in [2, 8, 14, 26, 40, 56]) {
        final a = growPickFor(DateTime(2026, 8, 1), ageMonths: months);
        final pool = growActivitiesForAge(months);
        expect(pool.contains(a), isTrue);
      }
    });

    test('never returns nothing, at any age', () {
      // Including ages past the library's range: an empty feature is not an
      // acceptable answer.
      for (var m = 0; m <= 72; m++) {
        expect(growActivitiesForAge(m), isNotEmpty, reason: 'empty at $m mo');
      }
    });
  });

  group('the habit loop — where V2 and V3 disagree', () {
    test('a streak breaks on a gap and the week ribbon does not', () {
      // Simulated directly against the same date maths both readings use,
      // rather than by driving the store, so the disagreement is visible in
      // one place.
      final days = <String>{};
      final now = DateTime.now();
      String k(int back) =>
          GrowStore.key(now.subtract(Duration(days: back)));

      // Did something today, yesterday, then a gap, then two more.
      days..add(k(0))..add(k(1))..add(k(3))..add(k(4));

      var streak = 0;
      for (var i = 0; days.contains(k(i)); i++) {
        streak++;
      }
      final week = [for (var i = 0; i < 7; i++) if (days.contains(k(i))) 1].length;

      expect(streak, 2, reason: 'the streak stops at the gap');
      expect(week, 4, reason: 'the week counts all four regardless of the gap');
      expect(week, greaterThan(streak),
          reason: 'this difference IS the argument between V2 and V3');
    });

    test('the week pattern is always seven slots', () {
      expect(GrowStore.instance.weekPattern, hasLength(7));
    });

    test('a date key is stable and sortable', () {
      expect(GrowStore.key(DateTime(2026, 8, 1)), '2026-08-01');
      expect(GrowStore.key(DateTime(2026, 12, 25)), '2026-12-25');
      // Zero-padded so string sort equals date sort — recentlyCompleted()
      // relies on it.
      expect('2026-08-01'.compareTo('2026-12-25'), lessThan(0));
    });
  });

  group('content rules the brief set', () {
    test('every new activity carries all ten required fields', () {
      for (final a in kGrowExtraActivities) {
        expect(a.title.trim(), isNotEmpty);
        expect(a.minutes, greaterThan(0));
        expect(a.ageTag.trim(), isNotEmpty);
        expect(a.difficulty.trim(), isNotEmpty);
        expect(a.materials, isNotEmpty, reason: '${a.title}: materials');
        expect(a.steps, isNotEmpty, reason: '${a.title}: steps');
        expect(a.safety, isNotEmpty, reason: '${a.title}: safety');
        expect(a.benefit.trim(), isNotEmpty, reason: '${a.title}: why it works');
        expect(a.skills, isNotEmpty, reason: '${a.title}: skills');
      }
    });

    test('ids are unique across the whole library', () {
      final ids = <String>{};
      for (final a in kGrowActivities) {
        expect(ids.add(a.id), isTrue, reason: 'duplicate id: ${a.id}');
      }
    });

    test('every activity belongs to a real area', () {
      final areaIds = kDevAreas.map((a) => a.id).toSet();
      for (final a in kGrowActivities) {
        expect(areaIds.contains(a.areaId), isTrue,
            reason: '"${a.title}" is in area "${a.areaId}", which does not exist');
      }
    });

    test('no decorative emoji anywhere in the capability layer', () {
      // The brief's framework is emoji-led. App rule is line icons in chrome.
      final emoji = RegExp(
          r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]',
          unicode: true);
      for (final c in kGrowCapabilities) {
        expect(emoji.hasMatch(c.label), isFalse, reason: c.label);
        expect(emoji.hasMatch(c.promise), isFalse, reason: c.label);
        for (final a in c.abilities) {
          expect(emoji.hasMatch(a), isFalse, reason: '${c.label}: $a');
        }
      }
    });
  });

  group('the version switch', () {
    test('opens on what ships, not on a proposal', () {
      expect(GrowVersionStore.instance.version, GrowVersion.v1);
    });

    test('switches and notifies', () {
      final store = GrowVersionStore.instance;
      var fired = 0;
      void listener() => fired++;
      store.addListener(listener);

      store.setVersion(GrowVersion.v3);
      expect(store.version, GrowVersion.v3);
      expect(fired, 1);

      // Setting the same version again must not notify — a rebuild storm on
      // every tap of the already-selected segment.
      store.setVersion(GrowVersion.v3);
      expect(fired, 1);

      store.removeListener(listener);
      store.setVersion(GrowVersion.v1); // leave it as found
    });

    test('every version has a caption a reviewer can read', () {
      for (final v in GrowVersion.values) {
        GrowVersionStore.instance.setVersion(v);
        expect(GrowVersionStore.instance.label.trim(), isNotEmpty);
      }
      GrowVersionStore.instance.setVersion(GrowVersion.v1);
    });
  });

  group('why-today never claims to have assessed the child', () {
    test('it describes the age, not this child', () {
      // The repo's clinical rule: no personalised assessment. A warm sentence
      // is still an assessment if it asserts something about one child.
      for (final a in kGrowActivities.take(12)) {
        final s = growWhyToday(a, ageMonths: 9).toLowerCase();
        for (final banned in [
          'your baby is ready',
          'he is ready',
          'she is ready',
          'your child needs',
          'is behind',
          'ahead of',
          '% ',
        ]) {
          expect(s.contains(banned), isFalse,
              reason: '"${a.title}" why-today claims: $banned');
        }
      }
    });
  });

  group('wiring', () {
    test('capability icons are real and distinct', () {
      final icons = <IconData>{};
      for (final c in kGrowCapabilities) {
        expect(icons.add(c.icon), isTrue,
            reason: '${c.label} reuses another capability\'s icon');
      }
    });

    test('growActivityById resolves every id in the library', () {
      for (final a in kGrowActivities) {
        expect(growActivityById(a.id).id, a.id);
      }
    });
  });
}

// =============================================================================
//  Reachability, asserted against the source.
// -----------------------------------------------------------------------------
//  The failure this repo has actually hit is correct code nobody can reach, and
//  a passing unit test says nothing about whether a screen is on a route. These
//  read the files, the same way the other reachability tests here do.
// =============================================================================

void reachability() {
  final drawer =
      File('lib/screens/post_pregnancy/explore_drawer.dart').readAsStringSync();
  final wrapper =
      File('lib/screens/post_pregnancy/grow_home_screen.dart').readAsStringSync();
  final main = File('lib/main.dart').readAsStringSync();

  group('the feature is actually reachable', () {
    test('Explore opens the wrapper', () {
      expect(drawer.contains('const GrowHomeScreen()'), isTrue,
          reason: 'nothing opens Grow; the Explore row still goes straight to V1');
    });

    test('the old row is commented, not deleted', () {
      // House rule: supersede by commenting out, with a revert note.
      expect(
          drawer.contains(
              "// _section(context, Icons.emoji_objects_outlined, 'Skill Development',"),
          isTrue,
          reason: 'the previous row should still be present, commented');
    });

    test('all three versions are constructed in the wrapper', () {
      for (final s in [
        'const DevelopmentHomeScreen()',
        'const GrowV2Home()',
        'const GrowV3Home()',
      ]) {
        expect(wrapper.contains(s), isTrue, reason: '$s is never built');
      }
    });

    test('V1 is the real screen, not a reimplementation', () {
      // If someone ever copies V1 into a GrowV1Home, the comparison stops
      // being against what ships.
      expect(wrapper.contains('DevelopmentHomeScreen'), isTrue);
      expect(File('lib/screens/post_pregnancy/grow_v3_screens.dart')
              .readAsStringSync()
              .contains('class GrowV1Home'),
          isFalse);
    });

    test('GrowStore is initialised at startup', () {
      // A store only booted from a screen loses everything it saved. This one's
      // whole job is remembering yesterday.
      expect(main.contains('GrowStore.instance.init()'), isTrue);
    });

    test('V3 keeps the Map and the check-in reachable', () {
      final v3 = File('lib/screens/post_pregnancy/grow_v3_screens.dart')
          .readAsStringSync();
      expect(v3.contains('DevelopmentMapScreen()'), isTrue,
          reason: 'V3 claims to keep the Map one tap down');
      expect(v3.contains('DevelopmentCheckinScreen()'), isTrue);
      expect(v3.contains('DevelopmentAreaScreen('), isTrue,
          reason: 'the eight area journeys must stay reachable under the '
              'capability names');
    });

    test('V2 genuinely drops them, as the brief asked', () {
      // Not an oversight — the difference being compared.
      final v2 = File('lib/screens/post_pregnancy/grow_v2_screens.dart')
          .readAsStringSync();
      expect(v2.contains('DevelopmentMapScreen'), isFalse);
      expect(v2.contains('DevelopmentCheckinScreen'), isFalse);
    });

    test('nothing was deleted from the shipped feature', () {
      for (final f in [
        'development_home_screen.dart',
        'development_map_screen.dart',
        'development_area_screen.dart',
        'development_activity_screen.dart',
        'development_checkin_screen.dart',
      ]) {
        expect(File('lib/screens/post_pregnancy/$f').existsSync(), isTrue,
            reason: '$f is gone — it was supposed to be reused, not replaced');
      }
    });
  });
}

// =============================================================================
//  How the brief's two conflicting instructions were read.
// -----------------------------------------------------------------------------
//  The brief says both of these, four lines apart:
//
//      "Include ● Daily streaks ● Progress animations ● Activity completion
//       celebration ● Gentle encouragement"
//      "Avoid gamification that feels childish."
//
//  The reading taken: the guardrail names a KIND of gamification — badges,
//  confetti, cartoon mascots, points, levels — not gamification itself. So the
//  explicit include-list stands, and the guardrail is enforced against the
//  childish devices specifically.
//
//  A reading is a decision, and a decision that lives only in a comment gets
//  quietly reversed. These hold it.
// =============================================================================

/// Strip comment lines before asserting a word is ABSENT.
///
/// These files explain at length what they deliberately do not do, and quote
/// the brief's own guardrail — "badges, confetti, cartoon mascots" — while
/// ruling those out. A naive search then fails on the file that documented the
/// decision best, which is exactly backwards. Same helper, same reason, as
/// partner_parity_test.dart.
String _code(String src) => src
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void docReading() {
  final v2 = _code(File('lib/screens/post_pregnancy/grow_v2_screens.dart')
      .readAsStringSync());
  final v3 = _code(File('lib/screens/post_pregnancy/grow_v3_screens.dart')
      .readAsStringSync());

  group('V2 includes what the brief explicitly asked for', () {
    test('the streak is there', () {
      expect(v2.contains('streakDays'), isTrue);
      expect(v2.contains('day streak'), isTrue);
    });

    test('there is a progress animation', () {
      expect(v2.contains('TweenAnimationBuilder'), isTrue,
          reason: '"progress animations" is on the brief\'s include-list');
    });

    test('there is a completion celebration', () {
      expect(v2.contains("'Great job'"), isTrue);
    });
  });

  group('V2 avoids the childishness the guardrail actually points at', () {
    test('no badges, confetti, mascots, points or levels', () {
      for (final banned in [
        'confetti',
        'Confetti',
        'badge',
        'Badge',
        'mascot',
        'Mascot',
        'trophy',
        'Trophy',
        'Level ',
        'XP',
      ]) {
        expect(v2.contains(banned), isFalse,
            reason: '"$banned" is the kind of gamification the brief rules out');
      }
    });

    test('no decorative emoji in the UI strings', () {
      // The brief draws its capabilities in emoji; the app-wide rule is line
      // icons. Comments may quote the brief — the rendered strings may not.
      final emoji = RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true);
      for (final line in v2.split('\n')) {
        expect(emoji.hasMatch(line), isFalse, reason: line.trim());
      }
    });
  });

  group('the streak explains itself before it punishes', () {
    test('there is an info affordance on the streak', () {
      expect(v2.contains('showStreakInfo'), isTrue);
      expect(v2.contains('Icons.info_outline_rounded'), isTrue);
    });

    test('it states the reset plainly', () {
      // The one rule a parent cannot see until it has already happened to her.
      expect(v2.contains('A missed day sets it back to zero.'), isTrue,
          reason: 'the reset must be stated, not implied');
    });

    test('it does not soften the reset with a reassurance that contradicts it',
        () {
      // "Don't worry if you miss a day!" sitting above a counter that resets
      // is a lie, and a cheerful explanation of a punishing rule reads worse
      // than the rule alone.
      for (final soft in [
        "Don't worry if you miss",
        'No pressure!',
        'it never resets',
      ]) {
        expect(v2.contains(soft), isFalse, reason: soft);
      }
    });

    test('it says what IS still true — the days are kept', () {
      expect(v2.contains('still recorded'), isTrue);
    });
  });

  group('V3 still refuses the streak, and that is the comparison', () {
    test('V3 shows no streak count anywhere', () {
      expect(v3.contains('streakDays'), isFalse,
          reason: 'V3 exists to be the version without a breakable number');
    });

    test('V3 uses the week ribbon instead', () {
      expect(v3.contains('daysThisWeek'), isTrue);
      expect(v3.contains('weekPattern'), isTrue);
    });
  });
}
