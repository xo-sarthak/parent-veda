// =============================================================================
//  Your birth plan — the model, the store, and the page she hands over
// -----------------------------------------------------------------------------
//  Three things worth holding:
//
//    · **The data is a preference, never an instruction.** That is a property
//      of strings, and nothing about a demand fails to compile.
//    · **Single means single.** The store enforces it, not the screen — a
//      screen that had to know would be a second copy of the model.
//    · **The summary is the page's order with the gaps closed.** What she
//      skipped is absent, not "not answered".
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/birth_plan_data.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/pregnancy/birth_plan_screen.dart';
import 'package:parentveda/services/birth_plan_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  setUp(() => BirthPlanStore.instance.debugRestore(const {}));

  group('the questions', () {
    test('ids are unique across sections, questions and choices', () {
      final sections = kBirthPlanSections.map((s) => s.id).toList();
      expect(sections.toSet().length, sections.length);
      final questions = kBirthPlanQuestions.map((q) => q.id).toList();
      expect(questions.toSet().length, questions.length);
      for (final q in kBirthPlanQuestions) {
        final ids = q.choices.map((c) => c.id).toList();
        expect(ids.toSet().length, ids.length, reason: q.id);
      }
    });

    test('every choice question has at least two choices; text has none', () {
      for (final q in kBirthPlanQuestions) {
        if (q.kind == BpKind.text) {
          expect(q.choices, isEmpty, reason: q.id);
          expect(q.hint, isNotNull, reason: '${q.id} needs a hint');
        } else {
          expect(q.choices.length, greaterThanOrEqualTo(2), reason: q.id);
        }
      }
    });

    test('no choice reads as an instruction to the hospital', () {
      // ⚠️ THE ONE RULE THAT MATTERS MOST AND COMPILES LEAST. Every option is
      // phrased as what she would prefer. A choice that starts with an
      // imperative aimed at the team is a demand, and Indian hospitals do not
      // take those.
      const demands = ['do not ', "don't ", 'must ', 'you will ', 'no one '];
      for (final q in kBirthPlanQuestions) {
        for (final c in q.choices) {
          final l = c.label.toLowerCase();
          for (final d in demands) {
            expect(l.startsWith(d), isFalse,
                reason: '"${c.label}" reads as an instruction.');
          }
        }
      }
    });

    test('nothing on the plan gives medical advice', () {
      const leaning = ['safer', 'recommended', 'best for', 'you should'];
      final strings = <String>[
        for (final s in kBirthPlanSections) ...[s.title, s.lead],
        for (final q in kBirthPlanQuestions) ...[
          q.prompt,
          ?q.hint,
          for (final c in q.choices) c.label,
        ],
      ];
      for (final s in strings) {
        for (final w in leaning) {
          expect(s.toLowerCase(), isNot(contains(w)),
              reason: '"$s" leans.');
        }
      }
    });

    test('the pain section links the primer that exists', () {
      final pain = kBirthPlanSections.firstWhere((s) => s.id == 'pain');
      expect(pain.readId, 'preg_labour_read_pain_relief');
    });
  });

  group('the store', () {
    test('single-choice replaces, multi-choice toggles', () async {
      final s = BirthPlanStore.instance;
      await s.toggle('pain_pref', 'epidural');
      await s.toggle('pain_pref', 'on_the_day');
      expect(s.choices('pain_pref'), {'on_the_day'});

      await s.toggle('atmosphere', 'quiet');
      await s.toggle('atmosphere', 'music');
      expect(s.choices('atmosphere'), {'quiet', 'music'});
      await s.toggle('atmosphere', 'quiet');
      expect(s.choices('atmosphere'), {'music'});
    });

    test('tapping the chosen single choice clears it', () async {
      final s = BirthPlanStore.instance;
      await s.toggle('skin', 'straight_away');
      await s.toggle('skin', 'straight_away');
      expect(s.choices('skin'), isEmpty);
    });

    test('an unknown question or a text question is ignored by toggle',
        () async {
      final s = BirthPlanStore.instance;
      await s.toggle('nope', 'x');
      await s.toggle('team_notes', 'x');
      expect(s.isEmpty, isTrue);
    });

    test('empty means empty, and discussed alone is not empty', () async {
      final s = BirthPlanStore.instance;
      expect(s.isEmpty, isTrue);
      await s.setText('team_notes', '   ');
      expect(s.isEmpty, isTrue, reason: 'whitespace is not an answer');
      await s.setDiscussed('who', true);
      expect(s.isEmpty, isFalse);
    });

    test('round-trips through its snapshot', () async {
      final s = BirthPlanStore.instance;
      await s.toggle('support_person', 'partner');
      await s.toggle('support_person', 'mother');
      await s.setText('support_name', 'Rohan, 98xxx');
      await s.setDiscussed('pain', true);
      final snap = s.debugSnapshot();

      s.debugRestore(const {});
      expect(s.isEmpty, isTrue);
      s.debugRestore(snap);
      expect(s.choices('support_person'), {'partner', 'mother'});
      expect(s.text('support_name'), 'Rohan, 98xxx');
      expect(s.isDiscussed('pain'), isTrue);
    });

    test('a corrupt snapshot leaves an empty plan, not a crash', () {
      final s = BirthPlanStore.instance;
      s.debugRestore({'choices': 'garbage', 'texts': 7, 'discussed': null});
      expect(s.isEmpty, isTrue);
    });
  });

  group('the page she hands over', () {
    test('leads with the voice line and skips what she skipped', () async {
      final s = BirthPlanStore.instance;
      await s.toggle('pain_pref', 'try_without');
      await s.toggle('first_feed', 'breast');
      await s.setDiscussed('after', true);

      final text = s.summary();
      final lines = text.split('\n');
      expect(lines.first, 'My birth plan');
      expect(lines[1], kBirthPlanVoice);
      expect(text, contains('PAIN RELIEF'));
      expect(text, contains("• I'd like to try without, and ask if I want it"));
      expect(text, contains('RIGHT AFTER BIRTH'));
      expect(text, contains('• Help me breastfeed in the first hour'));
      expect(text, contains('(Talked this through with my doctor.)'));
      expect(text, isNot(contains('WHO IS WITH ME')));
      expect(text, isNot(contains('DURING LABOUR')));
      expect(text, isNot(contains('not answered')));
    });

    test('is in the page order, not tap order', () async {
      final s = BirthPlanStore.instance;
      await s.setText('team_notes', 'Allergic to penicillin.');
      await s.toggle('support_person', 'sister');
      final text = s.summary();
      expect(text.indexOf('WHO IS WITH ME'),
          lessThan(text.indexOf('THINGS THE TEAM SHOULD KNOW')));
    });
  });

  group('it is on the door and it opens', () {
    test('the Labour prep rail carries the tool', () {
      final door = pvDoorPageFor('pregnancy_labour')!;
      final tile = door.allTiles.firstWhere((t) => t.title == 'Your birth plan');
      expect(tile, isA<PvDoorToolTile>());
      expect((tile as PvDoorToolTile).surfaceId, kLabourSurfaceBirthPlan);
      expect(pvDoorScreenFor(kLabourSurfaceBirthPlan, PregnancyController()),
          isA<BirthPlanScreen>());
    });

    testWidgets('renders every section and answers a tap', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BirthPlanScreen(pregnancy: PregnancyController()),
      ));
      await tester.pumpAndSettle();
      for (final s in kBirthPlanSections) {
        expect(find.text(s.title), findsOneWidget, reason: s.title);
      }
      // Nothing answered: the share bar is absent and the invitation is there.
      expect(find.text('Share my plan'), findsNothing);
      expect(find.textContaining('two answers is a plan'), findsOneWidget);

      // A tall page on the 800x600 test surface: bring the chip fully into
      // view before tapping, or the tap lands below the render tree.
      final chip = find.text("I'll decide on the day");
      await tester.scrollUntilVisible(chip, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(BirthPlanStore.instance.choices('pain_pref'), {'on_the_day'});
      expect(find.text('Share my plan'), findsOneWidget);
    });

    testWidgets('never shows a count or a progress state', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BirthPlanScreen(pregnancy: PregnancyController()),
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining(RegExp(r'\d+ of \d+')), findsNothing);
      expect(find.textContaining('%'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
