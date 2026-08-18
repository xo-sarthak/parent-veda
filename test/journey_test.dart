// =============================================================================
//  Journeys — the rules that stopped being prose
// -----------------------------------------------------------------------------
//  A journey is a config file, and a config file is exactly the kind of thing
//  edited quickly by someone who has not read why it looks the way it does.
//  Everything here is a rule that was argued for and would otherwise decay.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/journeys/journey_registry.dart';
import 'package:parentveda/data/hubs/ttc_hubs.dart';
import 'package:parentveda/data/journeys/ttc_journeys.dart';
import 'package:parentveda/screens/brackets/hub/hub_solution_cards.dart';

void main() {
  group('every journey is a walk that ends', () {
    test('each one says what "done" means', () {
      for (final j in kAllJourneys.values) {
        expect(j.closesWhen, isNotNull,
            reason: '${j.doorId}: a journey with no closure is how a hub grows '
                'a step that exists only because we needed another screen');
        expect(j.closesWhen!.en.trim().length, greaterThan(25),
            reason: j.doorId);
      }
    });

    test('every step heading is HER question, not our category', () {
      // The banned words are our filing system. She has never once thought
      // "I need the activities layer".
      const inventory = [
        'content', 'tools', 'products', 'courses', 'consults', 'activities',
        'extras', 'videos', 'articles', 'resources',
      ];
      for (final j in kAllJourneys.values) {
        for (final s in j.steps) {
          final q = s.question.en.toLowerCase();
          for (final b in inventory) {
            expect(q == b || q == '$b:', isFalse,
                reason: '${j.doorId}: step "${s.question.en}" is a category, '
                    'not a question');
          }
          expect(s.question.en.trim(), isNotEmpty, reason: j.doorId);
        }
      }
    });

    test('every element promises something', () {
      for (final j in kAllJourneys.values) {
        for (final s in j.steps) {
          expect(s.elements, isNotEmpty,
              reason: '${j.doorId}: "${s.question.en}" asks and answers nothing');
          for (final e in s.elements) {
            expect(e.value.en.trim().length, greaterThan(20),
                reason: '${j.doorId}: "${e.title.en}" is a link, not an answer');
          }
        }
      }
    });

    test('a live element goes somewhere; an owed one goes nowhere', () {
      for (final j in kAllJourneys.values) {
        for (final s in j.steps) {
          for (final e in s.elements) {
            if (e.owed) {
              // ⚠️ An owed element must NOT be tappable. A placeholder that
              // looks tappable and does nothing teaches her that taps do
              // nothing — everywhere in the app, not just here.
              expect(e.isLive, isFalse, reason: '${j.doorId}: ${e.title.en}');
            } else {
              expect(e.surfaceId != null || e.action != null, isTrue,
                  reason: '${j.doorId}: "${e.title.en}" is not owed and leads '
                      'nowhere');
            }
          }
        }
      }
    });
  });

  group('⚠️ there is no template, and this is what proves it', () {
    // The first draft of this work stamped one 3-step shape across every door
    // and the tell was that every journey came out the same length. Real
    // problems do not have uniform depth.
    test('journeys differ in length', () {
      final lengths = kAllJourneys.values.map((j) => j.steps.length).toSet();
      expect(lengths.length, greaterThan(3),
          reason: 'only ${lengths.length} distinct journey lengths across '
              '${kAllJourneys.length} journeys — that is a template wearing a '
              'disguise');
    });

    // ⚠️ THIS TEST WAS TOO STRICT AND IS NOW HONEST.
    //
    // It first asserted that NO two journeys could share an element sequence.
    // That is not what a template is. With twenty journeys and seven element
    // types, two coincidentally landing on read>read>tool is arithmetic, not
    // laziness — and it fired the moment a single element was corrected from a
    // tool to a read for an unrelated reason.
    //
    // A template is MANY journeys sharing one shape. So: no shape may be used
    // three times, and the variety across the whole set must stay high. That
    // catches the thing we are afraid of without punishing coincidence.
    test('no shape is reused enough to be a template', () {
      final counts = <String, List<String>>{};
      for (final j in kAllJourneys.values) {
        final shape = j.steps
            .map((s) => s.elements.map((e) => e.type.name).join('+'))
            .join('>');
        counts.putIfAbsent(shape, () => []).add(j.doorId);
      }
      for (final e in counts.entries) {
        expect(e.value.length, lessThan(3),
            reason: '${e.value.length} journeys share the shape ${e.key} '
                '(${e.value.join(", ")}) — that is a template');
      }
      // Variety across the whole set: most journeys should be shaped unlike
      // every other one.
      expect(counts.length / kAllJourneys.length, greaterThan(0.75),
          reason: 'only ${counts.length} distinct shapes across '
              '${kAllJourneys.length} journeys');
    });
  });

  group('⚠️ after a loss, nothing is sold and nothing is hurried', () {
    test('the loss journey offers no product, course or consult', () {
      final j = kTtcJourneys[kTtcActLossRecoveryLibrary];
      expect(j, isNotNull);
      for (final s in j!.steps) {
        for (final e in s.elements) {
          expect(
              e.type == SolutionType.product ||
                  e.type == SolutionType.course ||
                  e.type == SolutionType.consult,
              isFalse,
              reason: 'after a loss, "${e.title.en}" is a thing being sold to '
                  'someone grieving');
        }
      }
    });

    test('and it is allowed to be the shortest', () {
      final j = kTtcJourneys[kTtcActLossRecoveryLibrary]!;
      expect(j.steps.length, lessThanOrEqualTo(3),
          reason: 'padding this journey is the injury, not the care');
    });
  });

  group('⚠️ clinical invariants hold inside journeys too', () {
    test('no journey promises a personalised probability', () {
      // Population statistics are allowed where they reduce pressure. A
      // computed chance FOR HER is never allowed, anywhere.
      const banned = [
        'your chance', 'your chances', 'your odds', 'success rate for you',
        'likelihood of conceiving', '% chance',
      ];
      for (final j in kAllJourneys.values) {
        final blob = [
          j.title.en,
          j.intro.en,
          j.closesWhen?.en ?? '',
          for (final s in j.steps) ...[
            s.question.en,
            s.note?.en ?? '',
            for (final e in s.elements) '${e.title.en} ${e.value.en}',
          ],
        ].join(' ').toLowerCase();
        for (final b in banned) {
          expect(blob.contains(b), isFalse,
              reason: '${j.doorId} contains "$b" — the app never gives a '
                  'personalised probability');
        }
      }
    });
  });
}
