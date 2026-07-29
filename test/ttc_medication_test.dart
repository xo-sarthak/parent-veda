// =============================================================================
//  She can finally write down what her clinic put her on
// -----------------------------------------------------------------------------
//  The widest gap in the stage, and it sat directly under the most careful
//  thinking in it. The care pathway asks her, in these words, whether
//  medication has taken over WHEN ovulation happens - and the answer decides
//  whether we predict a fertile window or defer to her clinic entirely.
//
//  Then the "Medication" tile opened a curated supplement list with `+` buttons
//  and no text field anywhere. She could add folic acid FROM OUR LIST. She could
//  not write down Letrozole 2.5mg, days 3 to 7.
//
//  What these assert is mostly that the thing is REACHABLE and that it does not
//  quietly become advice.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/medication.dart';
import 'package:parentveda/screens/ttc/ttc_medication_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() => TtcLang.instance.hinglish = false);

  Future<void> pumpTall(WidgetTester tester, Widget w) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: w));
    await tester.pumpAndSettle();
  }

  // ===========================================================================
  group('it is reachable', () {
    // The wiring gate. A medication record nobody can open is the same as no
    // medication record, and this stage has shipped that mistake before.
    test('Tools has its own Medication tile', () {
      final tile = [
        for (final g in ttcToolGroups)
          for (final t in g.tools) t
      ].firstWhere((t) => t.id == 'medication');
      expect(tile.built, isTrue);
      expect(tile.nameEn, 'Medication');
    });

    test('and it opens the medication screen, not the supplement list', () {
      final src =
          File('lib/screens/ttc/ttc_tools_screen.dart').readAsStringSync();
      expect(src, contains('open: openTtcMedication'));
    });

    testWidgets('the screen builds and invites when empty', (tester) async {
      await pumpTall(tester, const TtcMedicationScreen());
      expect(tester.takeException(), isNull);
      // A feature is never hidden - the empty state is the advertisement.
      expect(find.text(const TtcS(false).medEmptyTitle), findsOneWidget);
      expect(find.text(const TtcS(false).medAdd), findsOneWidget);
    });
  });

  // ===========================================================================
  group('it holds a real prescription, not a picked suggestion', () {
    test('the shared model carries everything a protocol needs', () {
      // Reusing MedicineStore is the whole reason this needed no new table:
      // name, dose, schedule, notes and real alarms already existed.
      const m = Medication(
        id: 'x',
        name: 'Letrozole',
        type: MedType.medication,
        dose: '2.5 mg',
        frequency: 'Days 3 to 7, once a day',
        notes: 'Prescribed by Dr Rao',
        startDateIso: '2026-07-01T00:00:00.000',
        alarms: [
          MedAlarm(id: 'a', times: [480, 1200], repeat: MedAlarmRepeat.daily),
        ],
      );
      expect(m.dose, isNotEmpty);
      expect(m.frequency, isNotEmpty);
      expect(m.alarms.single.times, [480, 1200],
          reason: 'several times a day is ONE alarm, not several');
    });

    test('it is typed as a medication, not a supplement', () {
      // The distinction is not cosmetic - it is what the care pathway reasons
      // about, and what separates "we suggested this" from "a clinic
      // prescribed this".
      final src = File('lib/screens/ttc/ttc_medication_screen.dart')
          .readAsStringSync();
      expect(src, contains('type: MedType.medication'));
    });
  });

  // ===========================================================================
  group('it never becomes advice', () {
    test('the screen says what it will not do, where she can read it', () {
      const t = TtcS(false);
      final s = t.medNoAdvice.toLowerCase();
      expect(s, contains('do not check doses'));
      expect(s, contains('your doctor'));

      final src = File('lib/screens/ttc/ttc_medication_screen.dart')
          .readAsStringSync();
      expect(src, contains('t.medNoAdvice'),
          reason: 'the promise is written but never rendered');
    });

    test('nothing infers a condition from a drug name', () {
      // Seeing "Letrozole" must not let us decide she has PCOS. That is a
      // diagnosis, it would be wrong often, and it is not ours to make.
      final src = File('lib/screens/ttc/ttc_medication_screen.dart')
          .readAsStringSync()
          .toLowerCase();
      for (final drug in ['letrozole', 'clomid', 'metformin', 'gonal']) {
        // The hint text is allowed to show one as an EXAMPLE; branching on one
        // is not. No conditional may mention a drug.
        expect(RegExp('if.*$drug').hasMatch(src), isFalse,
            reason: 'branching on "$drug" is a diagnosis');
      }
    });

    test('and it carries the standing disclaimer like every other tool', () {
      final src = File('lib/screens/ttc/ttc_medication_screen.dart')
          .readAsStringSync();
      expect(src, contains('TtcDisclaimer'));
    });
  });

  // ===========================================================================
  group('local-first, with no backend at all', () {
    test('it adds no store and no table of its own', () {
      // The point of using MedicineStore: `medications` and `medication_logs`
      // already exist, every cloud call in it is gated on isLoggedIn, and
      // signed out it is a purely local record that behaves identically.
      final src = File('lib/screens/ttc/ttc_medication_screen.dart')
          .readAsStringSync();
      expect(src, contains('MedicineStore.instance'));
      expect(src, isNot(contains('extends ChangeNotifier')),
          reason: 'a parallel store reappeared');

      // Checked against the IMPORTS, not the file text - an earlier version of
      // this test matched the word `SupabaseRepo` inside the header comment
      // explaining why the screen does not use it, and failed on its own
      // documentation. Assert the dependency, not the vocabulary.
      final imports = src
          .split('\n')
          .where((l) => l.trimLeft().startsWith('import '))
          .join('\n');
      expect(imports, isNot(contains('remote/')),
          reason: 'the screen should not reach the backend directly');
      expect(imports, contains('services/medicine_store.dart'));
    });

    test('every strings entry is bilingual', () {
      const en = TtcS(false);
      const hi = TtcS(true);
      for (final pair in [
        (en.medTitle, hi.medTitle),
        (en.medAdd, hi.medAdd),
        (en.medEmptyTitle, hi.medEmptyTitle),
        (en.medEmptyBody, hi.medEmptyBody),
        (en.medName, hi.medName),
        (en.medFrequency, hi.medFrequency),
        (en.medRemindersNote, hi.medRemindersNote),
        (en.medNoAdvice, hi.medNoAdvice),
      ]) {
        expect(pair.$1, isNotEmpty);
        expect(pair.$2, isNotEmpty);
        expect(pair.$1, isNot(pair.$2), reason: 'never translated: ${pair.$1}');
      }
    });
  });
}
