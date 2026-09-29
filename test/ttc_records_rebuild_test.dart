// =============================================================================
//  Records and reports + Read your semen report: the tool rebuild (2026-09-27)
// -----------------------------------------------------------------------------
//  The user, walking build 13:
//   1. "When you click on Add at the top right … two screens open to add: one
//      the old UI, and behind that, the new UI."
//   2. "The last report added… 6 September, no sperm found. Now I cannot
//      delete it."
//   3. "That whole UI is so bad, it's old UI… the usability is all old."
//  Each is pinned here: first open, add, edit, remove with confirm and undo,
//  a whole test removed, the always-there way to a doctor, the semen report's
//  date, and the 360pt phone.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_record_edit_screen.dart';
import 'package:parentveda/screens/ttc/ttc_records_screen.dart';
import 'package:parentveda/screens/ttc/ttc_records_v2.dart';
import 'package:parentveda/screens/ttc/ttc_semen_report_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {Size size = const Size(1200, 8000)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump();
}

/// "Keep" awaits the store's first load, a future made outside the test's
/// fake clock, so its continuation runs on the real event loop. One real
/// turn lets it land; then the frames settle.
Future<void> _letTheSaveLand(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pumpAndSettle();
}

/// Lets any notice time out, so no timer outlives the test.
Future<void> _drain(WidgetTester tester) =>
    tester.pumpAndSettle(const Duration(seconds: 5));

TtcRecord _noSperm() => TtcRecordsStore.instance.add(
      label: 'Semen analysis',
      testId: 'semen',
      value: 'No sperm found (azoospermia)',
      note: 'First test · Saved from Read your semen report',
      takenOn: DateTime(2026, 9, 6),
      forPartner: true,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // ⚠️ LET THE STORE'S FIRST LOAD FINISH BEFORE ANY TEST. The store loads in
  // its constructor and that load ends with `_items.clear()` then the cached
  // rows. Left racing, it can land in the middle of a test and wipe what the
  // test just added (a group of two came back as one). Awaited here, on the
  // real clock, it lands once and before everything.
  setUpAll(() async {
    await TtcRecordsStore.instance.ensureLoaded();
  });

  setUp(() {
    TtcRecordsStore.instance.resetForTest();
    TtcAppointmentsStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('first open', () {
    testWidgets('empty: the paper-in-hand invitation with both ways in',
        (tester) async {
      await _pump(tester, const TtcRecordsScreen());
      expect(find.byType(TtcRecordsEmpty), findsOneWidget);
      expect(find.text('Photograph a report'), findsOneWidget);
      expect(find.text('Type a number instead'), findsOneWidget);
      expect(find.text('Your test results, in one place.'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('defect 1: Add opens ONE flow', () {
    testWidgets('the top-right Add pushes one page and no sheet',
        (tester) async {
      _noSperm();
      await _pump(tester, const TtcRecordsScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_rec_add')));
      await tester.pumpAndSettle();

      expect(find.byType(TtcRecordEditScreen), findsOneWidget);
      // The mechanism of the defect was a sheet that opened a second, older
      // sheet on its first frame. Neither exists now.
      expect(find.byType(BottomSheet), findsNothing);
      // The three ways to bring the report in are rows on the page.
      expect(find.text('Take a photo'), findsOneWidget);
      expect(find.text('Choose from your photos'), findsOneWidget);
      expect(find.text('Choose a PDF'), findsOneWidget);
    });

    testWidgets('"Photograph a report" also lands on the one page',
        (tester) async {
      await _pump(tester, const TtcRecordsScreen());
      await tester.tap(find.text('Photograph a report'));
      await tester.pumpAndSettle();
      // The phone's camera is not available under test; the page is.
      expect(find.byType(TtcRecordEditScreen), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
    });

    test('the live add never opens the old attachment chooser', () {
      final src = File('lib/screens/ttc/ttc_records_v2.dart')
          .readAsStringSync();
      final fn = src.substring(src.indexOf('Future<void> showTtcRecordAdd('));
      final body = fn.substring(0, fn.indexOf(';\n'));
      expect(body, contains('openTtcRecordEdit'));
      expect(body, isNot(contains('showModalBottomSheet')));
      final page = File('lib/screens/ttc/ttc_record_edit_screen.dart')
          .readAsStringSync()
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(page, isNot(contains('showTtcAttachmentPicker(')));
      expect(page, isNot(contains('showModalBottomSheet(')));
    });
  });

  // ===========================================================================
  group('adding', () {
    testWidgets('a typed result saves with whose, date and note',
        (tester) async {
      await _pump(tester, const TtcRecordsScreen());
      await tester.tap(find.text('Type a number instead'));
      await tester.pumpAndSettle();

      expect(find.text('Add a photo or the test name to save.'),
          findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('ttc_rec_label')), 'Thyroid panel');
      await tester.enterText(find.byKey(const ValueKey('ttc_rec_value')), '3.4');
      await tester.enterText(find.byKey(const ValueKey('ttc_rec_unit')), 'mIU/L');
      await tester.enterText(
          find.byKey(const ValueKey('ttc_rec_note')), 'Repeat in 3 months');
      await tester.tap(find.text("Your partner's"));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_rec_save')));
      await tester.pumpAndSettle();

      final r = TtcRecordsStore.instance.records.single;
      expect(r.label, 'Thyroid panel');
      expect(r.value, '3.4');
      expect(r.unit, 'mIU/L');
      expect(r.note, 'Repeat in 3 months');
      expect(r.forPartner, isTrue);
      // Back on the folder, with the row and a word that it saved.
      expect(find.byType(TtcRecordEditScreen), findsNothing);
      expect(find.text('Thyroid panel'), findsOneWidget);
      expect(find.text('Saved to your reports.'), findsOneWidget);
      await _drain(tester);
    });

    testWidgets('a "not added" test carries its own Add', (tester) async {
      _noSperm();
      await _pump(tester, const TtcRecordsScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_rec_cover_add_amh')));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(
          find.byKey(const ValueKey('ttc_rec_label')));
      expect(field.controller!.text, 'AMH');
    });
  });

  // ===========================================================================
  group('defect 2: every saved result can be changed and removed', () {
    testWidgets('the 6 September "no sperm found" report can be removed',
        (tester) async {
      final r = _noSperm();
      await _pump(tester, const TtcRecordsScreen());
      // .first: the row; the coverage list below names the test too.
      await tester.tap(find.text('Semen analysis').first);
      await tester.pumpAndSettle();
      expect(find.byType(TtcRecordDetailScreen), findsOneWidget);

      // Asked first; "Keep it" keeps it.
      await tester.tap(find.byKey(const ValueKey('ttc_rec_detail_remove')));
      await tester.pumpAndSettle();
      expect(find.text('Remove Semen analysis, 6 Sep 2026?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_no')));
      await tester.pumpAndSettle();
      expect(TtcRecordsStore.instance.records, hasLength(1));

      // Yes removes it and goes back to the folder.
      await tester.tap(find.byKey(const ValueKey('ttc_rec_detail_remove')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_yes')));
      await tester.pumpAndSettle();
      expect(TtcRecordsStore.instance.records, isEmpty);
      expect(find.byType(TtcRecordDetailScreen), findsNothing);
      expect(find.text('Result removed.'), findsOneWidget);

      // And Undo brings back the same row, same id.
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(TtcRecordsStore.instance.records.single.id, r.id);
      await _drain(tester);
    });

    testWidgets('Edit changes a saved result in place', (tester) async {
      final r = _noSperm();
      await _pump(tester, TtcRecordDetailScreen(recordId: r.id));
      await tester.tap(find.byKey(const ValueKey('ttc_rec_edit')));
      await tester.pumpAndSettle();
      expect(find.text('Change this result'), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('ttc_rec_label')), 'Semen analysis, repeat');
      await tester.tap(find.byKey(const ValueKey('ttc_rec_save')));
      await tester.pumpAndSettle();

      final now = TtcRecordsStore.instance.records.single;
      expect(now.id, r.id, reason: 'an edit, not a delete and re-add');
      expect(now.label, 'Semen analysis, repeat');
      expect(now.forPartner, isTrue, reason: 'whose is kept');
      expect(now.takenOn, DateTime(2026, 9, 6), reason: 'the date is kept');
      await _drain(tester);
    });

    testWidgets('the edit page removes too, and closes the result behind it',
        (tester) async {
      final r = _noSperm();
      await _pump(tester, TtcRecordDetailScreen(recordId: r.id));
      await tester.tap(find.byKey(const ValueKey('ttc_rec_edit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_rec_remove')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_yes')));
      await tester.pumpAndSettle();
      expect(TtcRecordsStore.instance.records, isEmpty);
      expect(find.byType(TtcRecordEditScreen), findsNothing);
      await _drain(tester);
    });

    testWidgets('a whole test (every reading) is removed together, with Undo',
        (tester) async {
      TtcRecordsStore.instance
        ..add(label: 'AMH', testId: 'amh', value: '2.1', unit: 'ng/mL',
            takenOn: DateTime(2025, 3, 4))
        ..add(label: 'AMH', testId: 'amh', value: '1.2', unit: 'ng/mL',
            takenOn: DateTime(2026, 8, 18));
      await _pump(tester, const TtcRecordsScreen());
      await tester.tap(find.text('AMH').first);
      await tester.pumpAndSettle();
      expect(find.byType(TtcRecordTrendScreen), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('ttc_rec_trend_remove')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_yes')));
      await tester.pumpAndSettle();
      expect(TtcRecordsStore.instance.records, isEmpty);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(TtcRecordsStore.instance.records, hasLength(2));
      await _drain(tester);
    });

    testWidgets('a group page adds the next reading as the same test',
        (tester) async {
      TtcRecordsStore.instance
        ..add(label: 'AMH', testId: 'amh', value: '2.1',
            takenOn: DateTime(2025, 3, 4))
        ..add(label: 'AMH', testId: 'amh', value: '1.2',
            takenOn: DateTime(2026, 8, 18));
      await _pump(tester, const TtcRecordTrendScreen(groupKey: 'amh'));
      await tester.tap(find.byKey(const ValueKey('ttc_rec_trend_add')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('ttc_rec_value')), '0.9');
      await tester.tap(find.byKey(const ValueKey('ttc_rec_save')));
      await tester.pumpAndSettle();
      final amh =
          TtcRecordsStore.instance.records.where((r) => r.testId == 'amh');
      expect(amh, hasLength(3), reason: 'it joins the group, not a new one');
      await _drain(tester);
    });
  });

  // ===========================================================================
  group('the way to a doctor is always there', () {
    testWidgets('with no appointment booked, the card and the PDF still open',
        (tester) async {
      _noSperm();
      await _pump(tester, const TtcRecordsScreen());
      expect(find.byKey(const ValueKey('ttc_rec_share_row')), findsOneWidget);
      expect(find.text('Show or send your results'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_rec_share_row')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_rec_pdf')), findsOneWidget);
      expect(find.text('Make a PDF to print or send'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the store, additively', () {
    test('an edit keeps the id; clearTestId drops a stale test', () {
      final r = _noSperm();
      final e = r.copyWith(label: 'Other', clearTestId: true,
          takenOn: DateTime(2026, 3, 1, 15, 30));
      expect(e.id, r.id);
      expect(e.testId, isNull);
      expect(e.takenOn, DateTime(2026, 3, 1), reason: 'a date, not a time');
    });

    test('two results added in one clock tick still get two ids', () {
      final ids = {
        for (var i = 0; i < 50; i++)
          TtcRecordsStore.instance
              .add(label: 'AMH', takenOn: DateTime(2026, 1, 1))
              .id,
      };
      expect(ids, hasLength(50),
          reason: 'a shared id made remove take both and Undo return one');
    });

    test('restore puts back the same rows once, never twice', () {
      final r = _noSperm();
      TtcRecordsStore.instance.remove(r.id);
      TtcRecordsStore.instance.restore([r]);
      TtcRecordsStore.instance.restore([r]);
      expect(TtcRecordsStore.instance.records.single.id, r.id);
    });
  });

  // ===========================================================================
  group('Read your semen report', () {
    testWidgets('asks the date on the report, and files under it',
        (tester) async {
      // The save awaits the store's first load; let it finish on real time.
      await tester.runAsync(TtcRecordsStore.instance.ensureLoaded);
      await _pump(tester, const TtcSemenReportScreen());
      expect(find.byKey(const ValueKey('ttc_semen_date')), findsOneWidget);
      expect(find.text('Date on the report'), findsOneWidget);

      await tester.tap(find.text('Read my report back to me'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep the report in your records'));
      await _letTheSaveLand(tester);
      final saved = TtcRecordsStore.instance.records.single;
      final now = DateTime.now();
      expect(saved.takenOn, DateTime(now.year, now.month, now.day));
      await _drain(tester);
    });

    testWidgets('a kept report removed in Records can be kept again',
        (tester) async {
      // The save awaits the store's first load; let it finish on real time.
      await tester.runAsync(TtcRecordsStore.instance.ensureLoaded);
      await _pump(tester, const TtcSemenReportScreen());
      await tester.tap(find.text('Read my report back to me'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep the report in your records'));
      await _letTheSaveLand(tester);
      // The folder opened on top; come back.
      Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
      await tester.pumpAndSettle();
      expect(find.text('Kept with your reports. Open the folder'),
          findsOneWidget);

      TtcRecordsStore.instance
          .remove(TtcRecordsStore.instance.records.single.id);
      await tester.pumpAndSettle();
      expect(find.text('Keep the report in your records'), findsOneWidget,
          reason: 'it no longer claims to be kept');
      await _drain(tester);
    });
  });

  // ===========================================================================
  group('a 360pt phone', () {
    testWidgets('folder, result, group and add page lay out without overflow',
        (tester) async {
      final r = _noSperm();
      TtcRecordsStore.instance
        ..add(label: 'AMH', testId: 'amh', value: '2.1', unit: 'ng/mL',
            takenOn: DateTime(2025, 3, 4))
        ..add(label: 'AMH', testId: 'amh', value: '1.2', unit: 'ng/mL',
            takenOn: DateTime(2026, 8, 18));
      const phone = Size(360, 800);
      await _pump(tester, const TtcRecordsScreen(), size: phone);
      expect(tester.takeException(), isNull);
      await _pump(tester, TtcRecordDetailScreen(recordId: r.id), size: phone);
      expect(tester.takeException(), isNull);
      await _pump(tester, const TtcRecordTrendScreen(groupKey: 'amh'),
          size: phone);
      expect(tester.takeException(), isNull);
      await _pump(tester, TtcRecordEditScreen(record: r), size: phone);
      expect(tester.takeException(), isNull);
      await _pump(tester, const TtcRecordEditScreen(), size: phone);
      expect(tester.takeException(), isNull);
      await _pump(tester, const TtcSemenReportScreen(), size: phone);
      expect(tester.takeException(), isNull);
    });
  });
}
