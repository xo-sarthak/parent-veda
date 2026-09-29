// =============================================================================
//  Records and reports, walked end to end after the one-app pass (2026-09-29)
// -----------------------------------------------------------------------------
//  The user, on build 20: "Make sure this whole page works correctly and
//  perfectly fine, and elevate the UI, because it still seems a bit different
//  from our application", and "1 result · all Partner" reads oddly.
//
//  Pinned here: the count line in plain words; one group per test PER PERSON
//  (her TSH and his TSH were one group, and the trend did arithmetic across
//  two people); the first-check list as clean rows (a tick and a value, or a
//  quiet line with Add result) and its Add opening the add page on that test,
//  his test as his; add, edit, remove and Undo from the folder; the drawn mark
//  per kind of test; the unit on the number; no overflow at 360dp and 1.5x.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_record_edit_screen.dart';
import 'package:parentveda/screens/ttc/ttc_records_screen.dart';
import 'package:parentveda/screens/ttc/ttc_records_v2.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/ttc_records_grouping.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';
import 'package:parentveda/ttc/ttc_tests_data.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {Size size = const Size(1200, 8000), double scale = 1.0}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    key: UniqueKey(),
    builder: (context, c) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: c!,
    ),
    home: child,
  ));
  await tester.pump();
}

Future<void> _drain(WidgetTester tester) =>
    tester.pumpAndSettle(const Duration(seconds: 5));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    await TtcRecordsStore.instance.ensureLoaded();
  });

  setUp(() {
    TtcRecordsStore.instance.resetForTest();
    TtcAppointmentsStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  group('the count line says whose in words', () {
    test('"1 result · your partner\'s", never "all Partner"', () {
      expect(ttcRecordsCountLine(1, 1), "1 result · your partner's");
      expect(ttcRecordsCountLine(4, 4), "4 results · all your partner's");
      expect(ttcRecordsCountLine(3, 1), "3 results · 2 yours, 1 your partner's");
      expect(ttcRecordsCountLine(2, 0), '2 results');
    });

    testWidgets('on the page, under "Your results"', (tester) async {
      TtcRecordsStore.instance.add(
          label: 'Semen analysis',
          testId: 'semen',
          value: 'No sperm found',
          takenOn: DateTime(2026, 9, 6),
          forPartner: true);
      await _pump(tester, const TtcRecordsScreen());
      expect(find.text("1 result · your partner's"), findsOneWidget);
      expect(find.textContaining('all Partner'), findsNothing);
      final heading = tester.getTopLeft(find.text('Your results')).dy;
      final count = tester
          .getTopLeft(find.byKey(const ValueKey('ttc_rec_count_line')))
          .dy;
      expect(count, greaterThan(heading),
          reason: 'the count describes the section, so it sits under it');
    });
  });

  group('one group per test per person', () {
    test("her TSH and his TSH are two groups, and no trend spans both", () {
      TtcRecordsStore.instance
        ..add(label: 'TSH (thyroid)', testId: 'tsh', value: '2.1',
            takenOn: DateTime(2025, 3, 4))
        ..add(label: 'TSH (thyroid)', testId: 'tsh', value: '1.2',
            takenOn: DateTime(2026, 8, 18), forPartner: true);
      final groups = ttcGroupedRecords();
      expect(groups, hasLength(2));
      final hers = groups.firstWhere((g) => !g.forPartner);
      final his = groups.firstWhere((g) => g.forPartner);
      expect(hers.key, 'tsh', reason: 'hers keep the bare key');
      expect(his.key, 'partner:tsh');
      expect(hers.repeated, isFalse);
      expect(his.readings.every((r) => r.forPartner), isTrue);
      expect(hers.testKey, his.testKey);
    });

    testWidgets('the filter finds each person\'s result', (tester) async {
      TtcRecordsStore.instance
        ..add(label: 'TSH (thyroid)', testId: 'tsh', value: '2.1',
            takenOn: DateTime(2025, 3, 4))
        ..add(label: 'TSH (thyroid)', testId: 'tsh', value: '1.2',
            takenOn: DateTime(2026, 8, 18), forPartner: true);
      await _pump(tester, const TtcRecordsScreen());
      await tester.tap(find.text("Your partner's").first);
      await tester.pumpAndSettle();
      expect(find.textContaining('1.2'), findsWidgets);
      await tester.tap(find.text('Yours').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('2.1'), findsWidgets);
    });
  });

  group('what a first check usually covers', () {
    test("his thyroid result does not tick her thyroid line", () {
      TtcRecordsStore.instance.add(
          label: 'TSH (thyroid)', testId: 'tsh', value: '1.2',
          takenOn: DateTime(2026, 8, 18), forPartner: true);
      final c = ttcRecordCoverage();
      expect(c.added.any((t) => t.id == 'tsh'), isFalse);
    });

    test('a typed "semen analysis" of his counts as the semen analysis', () {
      TtcRecordsStore.instance.add(
          label: 'Semen analysis', takenOn: DateTime(2026, 8, 18),
          forPartner: true);
      final c = ttcRecordCoverage();
      expect(c.added.any((t) => t.id == 'semen'), isTrue);
    });

    testWidgets('a filed test is a tick, whose and its value, and opens it',
        (tester) async {
      TtcRecordsStore.instance.add(label: 'AMH', testId: 'amh', value: '1.2',
          unit: 'ng/mL', takenOn: DateTime(2026, 8, 18));
      await _pump(tester, const TtcRecordsScreen());
      final done = find.byKey(const ValueKey('ttc_rec_cover_done_amh'));
      expect(done, findsOneWidget);
      expect(
          find.descendant(
              of: done, matching: find.byIcon(Icons.check_rounded)),
          findsOneWidget);
      expect(
          find.descendant(
              of: done,
              matching: find.text('Yours · 1.2 ng/mL · 18 Aug 2026')),
          findsOneWidget);
      await tester.tap(done);
      await tester.pumpAndSettle();
      expect(find.byType(TtcRecordDetailScreen), findsOneWidget);
    });

    testWidgets('every test not filed carries one "Add result"',
        (tester) async {
      TtcRecordsStore.instance.add(label: 'AMH', testId: 'amh', value: '1.2',
          takenOn: DateTime(2026, 8, 18));
      await _pump(tester, const TtcRecordsScreen());
      for (final t in ttcTests.where((t) => t.id != 'amh')) {
        expect(find.byKey(ValueKey('ttc_rec_cover_add_${t.id}')),
            findsOneWidget, reason: t.id);
      }
      expect(find.byKey(const ValueKey('ttc_rec_cover_add_amh')), findsNothing);
      expect(find.text('Add result'), findsNWidgets(ttcTests.length - 1));
      expect(find.textContaining('not added'), findsWidgets);
    });

    testWidgets("his test's Add opens the page on it, as his, and saves there",
        (tester) async {
      TtcRecordsStore.instance.add(label: 'AMH', testId: 'amh', value: '1.2',
          takenOn: DateTime(2026, 8, 18));
      await _pump(tester, const TtcRecordsScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_rec_cover_add_semen')));
      await tester.pumpAndSettle();
      expect(find.byType(TtcRecordEditScreen), findsOneWidget);
      final field = tester.widget<TextField>(
          find.byKey(const ValueKey('ttc_rec_label')));
      expect(field.controller!.text, 'Semen analysis');
      await tester.enterText(
          find.byKey(const ValueKey('ttc_rec_value')), 'Normal');
      await tester.tap(find.byKey(const ValueKey('ttc_rec_save')));
      await tester.pumpAndSettle();
      final r = TtcRecordsStore.instance.records
          .firstWhere((r) => r.testId == 'semen');
      expect(r.forPartner, isTrue, reason: 'a semen analysis is never hers');
      expect(find.byKey(const ValueKey('ttc_rec_cover_done_semen')),
          findsOneWidget);
      await _drain(tester);
    });
  });

  group('add, edit, remove and Undo, from the folder', () {
    testWidgets('the whole round trip', (tester) async {
      await _pump(tester, const TtcRecordsScreen());
      await tester.tap(find.text('Type a number instead'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('ttc_rec_label')), 'AMH');
      await tester.enterText(find.byKey(const ValueKey('ttc_rec_value')), '2.1');
      await tester.enterText(
          find.byKey(const ValueKey('ttc_rec_unit')), 'ng/mL');
      await tester.tap(find.byKey(const ValueKey('ttc_rec_save')));
      await tester.pumpAndSettle();
      final id = TtcRecordsStore.instance.records.single.id;
      expect(TtcRecordsStore.instance.records.single.testId, 'amh',
          reason: 'a typed name that is a library test files under it');

      // Edit from the result's page.
      await tester.tap(find.text('AMH').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_rec_edit')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('ttc_rec_value')), '1.9');
      await tester.tap(find.byKey(const ValueKey('ttc_rec_save')));
      await tester.pumpAndSettle();
      expect(TtcRecordsStore.instance.records.single.value, '1.9');
      expect(TtcRecordsStore.instance.records.single.id, id);

      // Remove, asked first, then Undo.
      await tester.tap(find.byKey(const ValueKey('ttc_rec_detail_remove')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_yes')));
      await tester.pumpAndSettle();
      expect(TtcRecordsStore.instance.records, isEmpty);
      expect(find.byType(TtcRecordsEmpty), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(TtcRecordsStore.instance.records.single.id, id);
      await _drain(tester);
    });
  });

  group('the look', () {
    test('a drawn mark per kind of test', () {
      expect(ttcRecordKindOf('amh', 'AMH'), TtcRecordKind.blood);
      expect(ttcRecordKindOf('hsg', 'HSG (tube test)'), TtcRecordKind.imaging);
      expect(ttcRecordKindOf('semen', 'Semen analysis'), TtcRecordKind.semen);
      expect(ttcRecordKindOf('thyroid panel', 'Thyroid panel'),
          TtcRecordKind.blood);
      expect(ttcRecordKindOf('follicle scan', 'Follicle scan'),
          TtcRecordKind.imaging);
      expect(ttcRecordKindOf('clinic letter', 'Clinic letter'),
          TtcRecordKind.other);
    });

    testWidgets('each result row draws its mark', (tester) async {
      TtcRecordsStore.instance
        ..add(label: 'AMH', testId: 'amh', value: '1.2',
            takenOn: DateTime(2026, 8, 18))
        ..add(label: 'Pelvic ultrasound', testId: 'ultrasound',
            value: 'Normal', takenOn: DateTime(2026, 7, 2));
      await _pump(tester, const TtcRecordsScreen());
      expect(find.byKey(const ValueKey('ttc_rec_mark_blood')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('ttc_rec_mark_imaging')), findsOneWidget);
    });

    test('the unit sits on the number: "0.9 ng/mL lower"', () {
      expect(ttcSpanWithUnit('0.9 lower', 'ng/mL'), '0.9 ng/mL lower');
      expect(ttcSpanWithUnit('unchanged', 'ng/mL'), 'unchanged');
      expect(ttcSpanWithUnit('3 higher', ''), '3 higher');
    });

    testWidgets('no tinted slab behind the trend stat', (tester) async {
      TtcRecordsStore.instance
        ..add(label: 'AMH', testId: 'amh', value: '2.1', unit: 'ng/mL',
            takenOn: DateTime(2025, 3, 4))
        ..add(label: 'AMH', testId: 'amh', value: '1.2', unit: 'ng/mL',
            takenOn: DateTime(2026, 8, 18));
      await _pump(tester, const TtcRecordTrendScreen(groupKey: 'amh'));
      expect(find.textContaining('0.9 ng/mL lower'), findsOneWidget);
      final slab = find.ancestor(
          of: find.text('BETWEEN THE FIRST AND THE LATEST'),
          matching: find.byWidgetPredicate((w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).color != null &&
              (w.decoration! as BoxDecoration).color != Colors.white &&
              (w.decoration! as BoxDecoration).color!.a > 0));
      expect(slab, findsNothing);
    });
  });

  group('a 360dp phone at 1.5x text', () {
    testWidgets('folder, result, trend and add page lay out', (tester) async {
      final semen = TtcRecordsStore.instance.add(
          label: 'Semen analysis',
          testId: 'semen',
          value: 'Concentration 12 million per ml · Progressive motility '
              '28.5 per cent',
          takenOn: DateTime(2026, 9, 6),
          forPartner: true);
      TtcRecordsStore.instance
        ..add(label: 'AMH', testId: 'amh', value: '2.1', unit: 'ng/mL',
            takenOn: DateTime(2025, 3, 4))
        ..add(label: 'AMH', testId: 'amh', value: '1.2', unit: 'ng/mL',
            takenOn: DateTime(2026, 8, 18))
        ..add(label: 'Thyroid panel', takenOn: DateTime(2026, 1, 8));
      const phone = Size(360, 900);
      for (final page in <Widget>[
        const TtcRecordsScreen(),
        TtcRecordDetailScreen(recordId: semen.id),
        const TtcRecordTrendScreen(groupKey: 'amh'),
        TtcRecordEditScreen(record: semen),
        const TtcRecordEditScreen(testId: 'semen'),
      ]) {
        await _pump(tester, page, size: phone, scale: 1.5);
        expect(tester.takeException(), isNull, reason: '$page');
      }
      TtcRecordsStore.instance.resetForTest();
      await _pump(tester, const TtcRecordsScreen(), size: phone, scale: 1.5);
      expect(tester.takeException(), isNull, reason: 'empty folder');
    });
  });
}
