// P1 D1 (docs/preg-ttc-tool-plans/P1-lookups-records.md, 2026-10-28): a
// reading in the call-today range opens one calm sheet after the save. The
// thresholds are proposals on a BEFORE-LAUNCH clinician line.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/tools/readings_log_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/readings_store.dart';

Reading _bp(int s, int d) =>
    Reading(id: 'x', kind: ReadingKind.bloodPressure, at: DateTime(2026, 10, 28), systolic: s, diastolic: d);
Reading _sugar(int v) => Reading(id: 'x', kind: ReadingKind.sugar, at: DateTime(2026, 10, 28), mgdl: v);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('readingConcern', () {
    test('blood pressure: each edge of the two tiers', () {
      expect(readingConcern(_bp(139, 89)), ReadingConcern.none);
      expect(readingConcern(_bp(140, 80)), ReadingConcern.sameDay);
      expect(readingConcern(_bp(120, 90)), ReadingConcern.sameDay);
      expect(readingConcern(_bp(159, 109)), ReadingConcern.sameDay);
      expect(readingConcern(_bp(160, 100)), ReadingConcern.urgent);
      expect(readingConcern(_bp(150, 110)), ReadingConcern.urgent);
    });

    test("her doctor's target quiets the call-today tier, never the call-now one", () {
      const t = ReadingTargets(sysUnder: 150, diaUnder: 100);
      expect(readingConcern(_bp(145, 95), targets: t), ReadingConcern.none);
      expect(readingConcern(_bp(152, 95), targets: t), ReadingConcern.sameDay);
      expect(readingConcern(_bp(165, 95), targets: t), ReadingConcern.urgent);
    });

    test('sugar: under 70 or 200 and above, whatever the context', () {
      expect(readingConcern(_sugar(69)), ReadingConcern.sameDay);
      expect(readingConcern(_sugar(70)), ReadingConcern.none);
      expect(readingConcern(_sugar(199)), ReadingConcern.none);
      expect(readingConcern(_sugar(200)), ReadingConcern.sameDay);
    });

    test('a typing slip is not a concern (plausibility comes first)', () {
      expect(readingConcern(_bp(1600, 90)), ReadingConcern.none);
      expect(readingConcern(_sugar(900)), ReadingConcern.none);
    });
  });

  group('the screen', () {
    late PregnancyController c;
    setUp(() => c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140))));

    Future<void> add(WidgetTester t, ReadingsStore s, String sys, String dia) async {
      await t.pumpWidget(MaterialApp(home: ReadingsLogScreen(controller: c, store: s)));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('readings_add_first')));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const ValueKey('reading_sys')), sys);
      await t.enterText(find.byKey(const ValueKey('reading_dia')), dia);
      await t.tap(find.byKey(const ValueKey('reading_save')));
      await t.pumpAndSettle();
    }

    testWidgets('an ordinary reading: a toast that names it, and no sheet', (t) async {
      final s = ReadingsStore.forTest();
      await add(t, s, '118', '76');
      expect(find.textContaining('Saved: 118/76 mmHg'), findsOneWidget);
      expect(find.byKey(const ValueKey('reading_concern_sameDay')), findsNothing);
      expect(find.byKey(const ValueKey('reading_concern_urgent')), findsNothing);
    });

    testWidgets('160/110 opens the call-now sheet, with no condition named', (t) async {
      final s = ReadingsStore.forTest();
      await add(t, s, '162', '112');
      expect(find.byKey(const ValueKey('reading_concern_urgent')), findsOneWidget);
      expect(find.text('Call your doctor now'), findsOneWidget);
      expect(find.byKey(const ValueKey('reading_concern_call')), findsOneWidget);
      expect(find.textContaining('not a diagnosis'), findsOneWidget);
      for (final word in ['preeclampsia', 'Pre-eclampsia', 'hypertension', 'High blood pressure']) {
        expect(find.textContaining(word), findsNothing, reason: word);
      }
      await t.tap(find.byKey(const ValueKey('reading_concern_later')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('reading_concern_urgent')), findsNothing);
      expect(s.of(ReadingKind.bloodPressure).single.valueText, '162/112', reason: 'the reading is kept');
    });

    testWidgets('a delete can be undone, with the same id', (t) async {
      final s = ReadingsStore.forTest();
      final id = s.add(kind: ReadingKind.bloodPressure, at: DateTime.now(), systolic: 118, diastolic: 76).id;
      // The ask card now sits above the list; a phone-tall view keeps the row
      // on screen.
      t.view.physicalSize = const Size(800, 1800);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(home: ReadingsLogScreen(controller: c, store: s)));
      await t.pumpAndSettle();
      await t.tap(find.byKey(ValueKey('reading_row_$id')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('reading_delete')));
      await t.pumpAndSettle();
      expect(s.of(ReadingKind.bloodPressure), isEmpty);
      expect(find.textContaining('Reading removed'), findsOneWidget);
      await t.tap(find.text('Undo'));
      await t.pumpAndSettle();
      expect(s.of(ReadingKind.bloodPressure).single.id, id);
    });

    testWidgets('the target sheet checks the numbers and keeps a draft', (t) async {
      final s = ReadingsStore.forTest();
      await t.pumpWidget(MaterialApp(home: ReadingsLogScreen(controller: c, store: s)));
      await t.pumpAndSettle();
      await t.tap(find.text("Add your doctor's target"));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const ValueKey('target_sys')), '1400');
      await t.tap(find.byKey(const ValueKey('target_save')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('target_error')), findsOneWidget);
      expect(s.targets.isEmpty, isTrue);

      await t.enterText(find.byKey(const ValueKey('target_sys')), '140');
      // Close without saving: the typing comes back next time.
      await t.tapAt(const Offset(10, 10));
      await t.pumpAndSettle();
      await t.tap(find.text("Add your doctor's target"));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('target_draft_line')), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('target_save')));
      await t.pumpAndSettle();
      expect(s.targets.sysUnder, 140);
      expect(find.textContaining('Target saved'), findsOneWidget);
    });
  });
}
