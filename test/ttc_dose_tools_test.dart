// =============================================================================
//  Supplements and Medication, rebuilt (2026-09-27, tool rebuild, night)
// -----------------------------------------------------------------------------
//  The user walked build 13 and called these "old tools in new clothes". The
//  rebuild gave both one set of parts (`ttc_dose_parts.dart`) and filled the
//  gaps in the job itself. Each group below is one of those gaps, walked the
//  way she would: first open, add, tick, a forgotten day, the item's page,
//  change, remove, and the two defects a real list already had (two "Folic
//  acid" rows; a five-day course that sat on today's list for ever).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/medication.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart' show ttcReadById;
import 'package:parentveda/screens/ttc/ttc_dose_parts.dart';
import 'package:parentveda/screens/ttc/ttc_medication_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_supplements_screen.dart';
import 'package:parentveda/services/medicine_store.dart';
import 'package:parentveda/ttc/ttc_journal_store.dart' show TtcAuthor;
import 'package:parentveda/ttc/ttc_supplements_store.dart';

Future<void> pumpTall(WidgetTester tester, Widget child,
    {double width = 1200, double height = 8000}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump();
}

/// Lets any confirmation snack time out, so no timer outlives the test.
Future<void> settleSnacks(WidgetTester tester) =>
    tester.pumpAndSettle(const Duration(seconds: 4));

DateTime get today => ttcDoseDay(DateTime.now());
DateTime daysAgo(int n) => today.subtract(Duration(days: n));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcSupplementsStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('supplements: first open', () {
    testWidgets('invites, with the button right there, and a read',
        (tester) async {
      await pumpTall(tester, const TtcSupplementsScreen());
      expect(tester.takeException(), isNull);
      expect(find.text(const TtcS(false).supplementsEmptyTitle), findsOneWidget);
      expect(find.text('Add your own'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_supp_read')), findsOneWidget,
          reason: 'What to Expect opens its vitamin log with a read');
      // No day strip over an empty list: there is nothing to tick yet.
      expect(find.byType(TtcDayStrip), findsNothing);
      // Every suggestion shows while nothing is added.
      expect(find.text('Zinc'), findsOneWidget);
    });

    testWidgets('the hero Add opens the sheet, and the new row lands',
        (tester) async {
      await pumpTall(tester, const TtcSupplementsScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_dose_hero_add')));
      await tester.pumpAndSettle();
      expect(find.text('Add a supplement'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Vitamin B12');
      await tester.tap(find.byKey(const ValueKey('ttc_supp_save')));
      await tester.pumpAndSettle();
      expect(find.text('Vitamin B12'), findsWidgets);
      expect(find.text('Added to your list'), findsOneWidget);
      await settleSnacks(tester);
    });
  });

  // ===========================================================================
  group('supplements: ticking', () {
    testWidgets('the circle ticks today, and the count says what it counts',
        (tester) async {
      final s = TtcSupplementsStore.instance.add('Iron');
      await pumpTall(tester, const TtcSupplementsScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_dose_tick_Iron')));
      await tester.pump();
      expect(TtcSupplementsStore.instance.isTaken(s.id), isTrue);
      expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('ttc_supp_count')))
              .textSpan!
              .toPlainText(),
          contains('1 of 1 taken'));
      // A second tap is the undo.
      await tester.tap(find.byKey(const ValueKey('ttc_dose_tick_Iron')));
      await tester.pump();
      expect(TtcSupplementsStore.instance.isTaken(s.id), isFalse);
    });

    testWidgets('a forgotten day can be ticked from the strip',
        (tester) async {
      final s = TtcSupplementsStore.instance.add('Folic acid');
      await pumpTall(tester, const TtcSupplementsScreen());
      // Yesterday is one in from the right.
      await tester.tap(find.byKey(const ValueKey('ttc_dose_day_1')));
      await tester.pump();
      expect(find.text('Tick what you took that day.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_dose_tick_Folic acid')));
      await tester.pump();
      expect(TtcSupplementsStore.instance.isTaken(s.id, on: daysAgo(1)),
          isTrue);
      expect(TtcSupplementsStore.instance.isTaken(s.id), isFalse,
          reason: "yesterday's tick is not today's");
    });

    testWidgets('a suggestion already on the list is not offered again',
        (tester) async {
      TtcSupplementsStore.instance.add('Zinc', author: TtcAuthor.partner);
      await pumpTall(tester, const TtcSupplementsScreen());
      // On his list once; no second "Zinc" down in the suggestions.
      expect(find.text('Zinc'), findsOneWidget);
    });
  });

  // ===========================================================================
  group("supplements: the item's own page", () {
    testWidgets('opens on the name, ticks today and corrects a past day',
        (tester) async {
      final s = TtcSupplementsStore.instance
          .add('Vitamin D', dose: '1000 IU daily');
      await pumpTall(tester, const TtcSupplementsScreen());
      await tester.tap(find.text('Vitamin D'));
      await tester.pumpAndSettle();
      expect(find.byType(TtcSupplementDetailScreen), findsOneWidget);
      expect(find.text('1000 IU daily On your list.'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('ttc_dose_today')));
      await tester.pump();
      expect(TtcSupplementsStore.instance.isTaken(s.id), isTrue);
      expect(find.text('Taken today'), findsOneWidget);

      final d = daysAgo(2);
      await tester
          .tap(find.byKey(ValueKey('ttc_dose_hist_${d.month}_${d.day}')));
      await tester.pump();
      expect(TtcSupplementsStore.instance.isTaken(s.id, on: d), isTrue);
    });

    testWidgets('a future day in the history cannot be ticked',
        (tester) async {
      // Only meaningful when this week still has days to come.
      final s = TtcSupplementsStore.instance.add('Omega-3');
      await pumpTall(tester, TtcSupplementDetailScreen(id: s.id));
      if (today.weekday == DateTime.sunday) return;
      final d = today.add(const Duration(days: 1));
      await tester
          .tap(find.byKey(ValueKey('ttc_dose_hist_${d.month}_${d.day}')));
      await tester.pump();
      expect(TtcSupplementsStore.instance.isTaken(s.id, on: d), isFalse);
    });

    testWidgets('remove asks, and Keep it keeps it', (tester) async {
      final s = TtcSupplementsStore.instance.add('CoQ10');
      TtcSupplementsStore.instance.toggleTaken(s.id);
      await pumpTall(tester, const TtcSupplementsScreen());
      await tester.tap(find.text('CoQ10').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_dose_remove')));
      await tester.pumpAndSettle();
      expect(find.text('Remove CoQ10?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_no')));
      await tester.pumpAndSettle();
      expect(TtcSupplementsStore.instance.items, hasLength(1));

      await tester.tap(find.byKey(const ValueKey('ttc_dose_remove')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_yes')));
      await tester.pumpAndSettle();
      expect(TtcSupplementsStore.instance.items, isEmpty);
      // Back on the list, which now invites again.
      expect(find.byType(TtcSupplementDetailScreen), findsNothing);
      expect(find.text(const TtcS(false).supplementsEmptyTitle), findsOneWidget);
      await settleSnacks(tester);
    });
  });

  // ===========================================================================
  group('supplements: two rows of one name, from before the one-name rule', () {
    void seedDuplicates() {
      final store = TtcSupplementsStore.instance;
      store.addRawForTest(const TtcSupplement(
          id: 'a', name: 'Folic acid', dose: 'As advised'));
      store.addRawForTest(const TtcSupplement(
          id: 'b', name: 'folic acid ', dose: '400 mcg daily'));
      store.toggleTaken('a', on: daysAgo(3));
      store.toggleTaken('b', on: daysAgo(1));
    }

    test('the store finds the pair and merges it, keeping every tick', () {
      seedDuplicates();
      final store = TtcSupplementsStore.instance;
      final groups = store.duplicates();
      expect(groups, hasLength(1));
      final kept = store.merge(groups.single)!;
      expect(store.items, hasLength(1));
      expect(kept.id, 'a', reason: 'the oldest row stays');
      expect(kept.dose, '400 mcg daily',
          reason: 'a real dose wins over "As advised"');
      expect(store.isTaken('a', on: daysAgo(3)), isTrue);
      expect(store.isTaken('a', on: daysAgo(1)), isTrue,
          reason: "the other row's tick moved, it was not lost");
      expect(store.duplicates(), isEmpty);
    });

    test('his and hers of one name are not a duplicate', () {
      final store = TtcSupplementsStore.instance;
      store.add('CoQ10');
      store.add('CoQ10', author: TtcAuthor.partner);
      expect(store.duplicates(), isEmpty);
    });

    testWidgets('the screen names the pair and merges only on her tap',
        (tester) async {
      seedDuplicates();
      await pumpTall(tester, const TtcSupplementsScreen());
      expect(find.text('Folic acid is on your list twice'), findsOneWidget);
      // Nothing changes by being shown.
      expect(TtcSupplementsStore.instance.items, hasLength(2));
      await tester.tap(find.byKey(const ValueKey('ttc_supp_merge_a')));
      await tester.pump();
      expect(TtcSupplementsStore.instance.items, hasLength(1));
      expect(find.text('Folic acid is on your list twice'), findsNothing);
      expect(find.text('Folic acid is one row now'), findsOneWidget);
      await settleSnacks(tester);
    });

    test('no row is ever removed without her asking', () {
      // The notice is the only caller of `merge` in the app.
      final src = File('lib/screens/ttc/ttc_supplements_screen.dart')
          .readAsStringSync()
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect('instance.merge('.allMatches(src).length, 1);
      expect(src, contains("label: 'Merge them'"));
    });
  });

  // ===========================================================================
  group('medication', () {
    // ⚠️ NOT AWAITED, ON PURPOSE (as in ttc_tools_records_pass_test.dart):
    // MedicineStore arms real OS alarms after it updates its list, and under
    // flutter_test that platform call never answers.
    tearDown(() {
      for (final m in [...MedicineStore.instance.all]) {
        MedicineStore.instance.deleteMed(m.id);
      }
    });

    testWidgets('first open invites, and a common time is one tap',
        (tester) async {
      await pumpTall(tester, const TtcMedicationScreen());
      expect(find.text(const TtcS(false).medEmptyTitle), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_med_read')), findsOneWidget);
      await tester.tap(find.text(const TtcS(false).medAdd));
      await tester.pumpAndSettle();
      expect(find.text('Add a medicine'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Letrozole');
      await tester.tap(find.byKey(const ValueKey('ttc_med_quick_480')));
      await tester.pump();
      expect(find.byKey(const ValueKey('ttc_med_time_480')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_med_save')));
      await tester.pumpAndSettle();

      final m = MedicineStore.instance.all.single;
      expect(m.type, MedType.medication);
      expect(m.alarms.single.times, [480]);
      expect(find.text('Reminds you at 8:00 am'), findsOneWidget);
      await settleSnacks(tester);
    });

    testWidgets('a closed clock adds no time', (tester) async {
      await pumpTall(tester, const TtcMedicationScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_dose_hero_add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_med_add_time')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_med_time_540')), findsNothing);
      expect(find.byKey(const ValueKey('ttc_med_quick_480')), findsOneWidget,
          reason: 'still no time, so the quick times still show');
    });

    testWidgets('the same name twice is said before it is saved',
        (tester) async {
      MedicineStore.instance.addMed(const Medication(
          id: 'm1',
          name: 'Metformin',
          type: MedType.medication,
          startDateIso: '2026-09-01T00:00:00.000'));
      await pumpTall(tester, const TtcMedicationScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_dose_hero_add')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'metformin');
      await tester.tap(find.byKey(const ValueKey('ttc_med_save')));
      await tester.pumpAndSettle();
      expect(find.textContaining('is already on your list'), findsOneWidget);
      expect(MedicineStore.instance.all, hasLength(1));
      // A second Save keeps both: one drug can come at two doses.
      await tester.tap(find.byKey(const ValueKey('ttc_med_save')));
      await tester.pumpAndSettle();
      expect(MedicineStore.instance.all, hasLength(2));
      await settleSnacks(tester);
    });

    testWidgets('a forgotten day can be ticked, on the list and on its page',
        (tester) async {
      MedicineStore.instance.addMed(const Medication(
          id: 'm2',
          name: 'Progesterone',
          type: MedType.medication,
          startDateIso: '2026-09-01T00:00:00.000'));
      await pumpTall(tester, const TtcMedicationScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_dose_day_1')));
      await tester.pump();
      await tester
          .tap(find.byKey(const ValueKey('ttc_dose_tick_Progesterone')));
      await tester.pump();
      final store = MedicineStore.instance;
      expect(store.isTakenOn('m2', MedicineStore.dateKey(daysAgo(1))), isTrue);
      expect(store.isTakenToday('m2'), isFalse);

      await tester.tap(find.text('Progesterone'));
      await tester.pumpAndSettle();
      expect(find.byType(TtcMedicineDetailScreen), findsOneWidget);
      expect(find.textContaining('No reminders'), findsOneWidget);
      final d = daysAgo(3);
      await tester
          .tap(find.byKey(ValueKey('ttc_dose_hist_${d.month}_${d.day}')));
      await tester.pump();
      expect(store.isTakenOn('m2', MedicineStore.dateKey(d)), isTrue);
    });

    testWidgets('a course past its last day moves to Finished, and comes back',
        (tester) async {
      MedicineStore.instance.addMed(Medication(
        id: 'm3',
        name: 'Clomiphene',
        type: MedType.medication,
        startDateIso: daysAgo(9).toIso8601String(),
        endDateIso: daysAgo(3).toIso8601String(),
        alarms: [
          MedAlarm(
              id: 'a3',
              times: const [1260],
              endDateIso: daysAgo(3).toIso8601String()),
        ],
      ));
      await pumpTall(tester, const TtcMedicationScreen());
      expect(find.text('FINISHED COURSES'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_dose_tick_Clomiphene')),
          findsNothing,
          reason: 'no tick for a course that has ended');
      expect(find.textContaining("Nothing on today's list"), findsOneWidget);

      await tester.tap(find.text('Clomiphene'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Reminders stopped after'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_med_again')));
      await tester.pumpAndSettle();
      // "Take it again" opens with the old last day gone.
      expect(find.text('Every day, no end date'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_med_save')));
      await tester.pumpAndSettle();
      final m = MedicineStore.instance.all.single;
      expect(m.endDateIso, isNull);
      expect(m.alarms.single.endDateIso, isNull);
      expect(m.alarms.single.times, [1260], reason: 'her time is kept');
      expect(ttcMedFinished(m), isFalse);
      await settleSnacks(tester);
    });

    testWidgets('a change that leaves the schedule alone keeps its alarms',
        (tester) async {
      // Pregnancy's tracker can hold weekday alarms; the TTC sheet writes one
      // daily alarm, so it must not flatten a schedule she did not touch.
      MedicineStore.instance.addMed(const Medication(
        id: 'm4',
        name: 'Iron',
        type: MedType.supplement,
        startDateIso: '2026-09-01T00:00:00.000',
        alarms: [
          MedAlarm(
              id: 'w',
              times: [600],
              repeat: MedAlarmRepeat.weekly,
              weekdays: [1, 4]),
        ],
      ));
      await pumpTall(tester, const TtcMedicationScreen());
      await tester.tap(find.text('Iron'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_med_change')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(1), '60 mg');
      await tester.tap(find.byKey(const ValueKey('ttc_med_save')));
      await tester.pumpAndSettle();
      final m = MedicineStore.instance.all.single;
      expect(m.dose, '60 mg');
      expect(m.alarms.single.repeat, MedAlarmRepeat.weekly);
      expect(m.alarms.single.weekdays, [1, 4]);
      expect(m.type, MedType.supplement, reason: 'its type is not ours');
    });

    testWidgets('remove asks first, then goes back to the list',
        (tester) async {
      MedicineStore.instance.addMed(const Medication(
          id: 'm5',
          name: 'Aspirin',
          type: MedType.medication,
          startDateIso: '2026-09-01T00:00:00.000'));
      await pumpTall(tester, const TtcMedicationScreen());
      await tester.tap(find.text('Aspirin'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(const TtcS(false).medDelete));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_yes')));
      await tester.pumpAndSettle();
      expect(MedicineStore.instance.all, isEmpty);
      expect(find.byType(TtcMedicineDetailScreen), findsNothing);
      await settleSnacks(tester);
    });
  });

  // ===========================================================================
  group('one shape for both tools', () {
    test('the read under each list exists', () {
      // A read link to an unknown id opens nothing: a dead tap.
      expect(ttcReadById(kTtcSupplementsRead), isNotNull);
      expect(ttcReadById(kTtcMedicationRead), isNotNull);
    });

    testWidgets('the read opens in the one reader', (tester) async {
      await pumpTall(tester, const TtcMedicationScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_med_read')));
      await tester.pumpAndSettle();
      expect(find.byType(PvReaderScreen), findsOneWidget);
    });

    test('neither draws the V1 card or the purple tick any more', () {
      for (final f in [
        'lib/screens/ttc/ttc_supplements_screen.dart',
        'lib/screens/ttc/ttc_medication_screen.dart',
      ]) {
        final live = File(f)
            .readAsStringSync()
            .split('\n')
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        expect(live, isNot(contains('TtcCard(')), reason: f);
        expect(live, isNot(contains('ttcPurple')), reason: f);
        expect(live, contains('TtcDoseRow('), reason: f);
        expect(live, contains('TtcDoseHistory('), reason: f);
        expect(live, contains('TtcDoseHeroAdd('), reason: f);
      }
    });
  });

  // ===========================================================================
  group('no overflow at 360dp', () {
    tearDown(() {
      for (final m in [...MedicineStore.instance.all]) {
        MedicineStore.instance.deleteMed(m.id);
      }
    });

    testWidgets('supplements, full list and its page', (tester) async {
      final store = TtcSupplementsStore.instance;
      final s = store.add('Methylcobalamin (vitamin B12)',
          dose: 'One tablet after breakfast, as my doctor said');
      store.add('Zinc', author: TtcAuthor.partner);
      store.addRawForTest(const TtcSupplement(id: 'x', name: 'zinc', dose: ''));
      await pumpTall(tester, const TtcSupplementsScreen(),
          width: 360, height: 3200);
      expect(tester.takeException(), isNull);
      await pumpTall(tester, TtcSupplementDetailScreen(id: s.id),
          width: 360, height: 2000);
      expect(tester.takeException(), isNull);
    });

    testWidgets('medication, list, page and sheet', (tester) async {
      MedicineStore.instance.addMed(const Medication(
        id: 'm6',
        name: 'Progesterone vaginal gel',
        type: MedType.medication,
        dose: '90 mg',
        frequency: 'Every night from the day after transfer',
        startDateIso: '2026-09-01T00:00:00.000',
        alarms: [
          MedAlarm(id: 'a6', times: [480, 840, 1260]),
        ],
      ));
      await pumpTall(tester, const TtcMedicationScreen(),
          width: 360, height: 3000);
      expect(tester.takeException(), isNull);
      await pumpTall(tester, const TtcMedicineDetailScreen(id: 'm6'),
          width: 360, height: 2400);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('ttc_med_change')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
