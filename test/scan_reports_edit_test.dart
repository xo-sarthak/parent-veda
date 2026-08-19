// =============================================================================
//  My reports — a stored report can be looked at, and renamed
// -----------------------------------------------------------------------------
//  The door stored reports and deleted reports and could not SHOW one. That is
//  a wiring-gate failure of the purest kind: `ScanReportsStore` was complete —
//  `update()` had shipped and had never once been called — and the list read
//  back three fields of a model that holds six.
//
//  ⚠️ THE TESTS THAT MATTER MOST HERE ARE THE TWO ABOUT `scanId`.
//
//  `title` is what she calls a report; `scanId` is what it IS, and `forScan()`
//  reads the latter to surface a report on its scan's page. A rename that
//  silently dropped the link would break a connection she cannot see on any
//  screen and would never think to restore — no crash, no failing test, and
//  the only symptom is a report that stops appearing somewhere she was not
//  watching. So both directions are pinned: a rename keeps the link, and
//  unlinking actually unlinks.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/brackets/scan_report_edit_screen.dart';
import 'package:parentveda/screens/brackets/scan_report_viewer_screen.dart';
import 'package:parentveda/screens/brackets/scan_reports_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/scan_reports_store.dart';

ScanReport _report({
  String id = 'rep_1',
  String title = 'Report',
  String? scanId,
  String note = '',
  List<ReportFile> files = const [],
}) =>
    ScanReport(
      id: id,
      title: title,
      dateIso: DateTime(2026, 3, 4).toIso8601String(),
      scanId: scanId,
      note: note,
      files: files,
    );

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(1200, 3200);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late PregnancyController pregnancy;

  setUp(() {
    ScanReportsStore.instance.resetForTest();
    pregnancy = PregnancyController();
  });
  tearDown(() => pregnancy.dispose());

  // ===========================================================================
  //  The model can express what the editor needs to say
  // ===========================================================================

  group('copyWith can unlink a report, not only relink it', () {
    test('a rename keeps the scan link', () {
      final r = _report(title: 'Dating scan', scanId: 'dating_scan');
      final renamed = r.copyWith(title: 'Dating scan — Apollo, Dr Rao');

      // ⚠️ THE ONE THAT WOULD HAVE BEEN LOST SILENTLY. She renamed it; she did
      // not say it was no longer a dating scan.
      expect(renamed.scanId, 'dating_scan');
      expect(renamed.title, 'Dating scan — Apollo, Dr Rao');
    });

    test('clearScanId actually clears it', () {
      final r = _report(title: 'Dating scan', scanId: 'dating_scan');
      expect(r.copyWith(clearScanId: true).scanId, isNull);
    });

    test('without the flag, a null scanId means "unchanged", not "clear"', () {
      // ⚠️ THIS IS WHY THE FLAG EXISTS AT ALL. With a nullable field the two
      // intentions arrive identically, so the ambiguity has to be resolved by
      // a second parameter or it is resolved by accident.
      final r = _report(scanId: 'nt_scan');
      expect(r.copyWith(title: 'x').scanId, 'nt_scan');
    });

    test('files are never touched by a details edit', () {
      final r = _report(
          scanId: 'ogtt',
          files: const [ReportFile(path: '/a.jpg', name: 'a.jpg')]);
      final edited =
          r.copyWith(title: 'Sugar test', note: 'recheck in 4 weeks');
      expect(edited.files.length, 1);
      expect(edited.files.first.path, '/a.jpg');
    });
  });

  // ===========================================================================
  //  The list opens the report
  // ===========================================================================

  group('a row is a door, not a label with a bin next to it', () {
    testWidgets('tapping a report opens the viewer', (t) async {
      await ScanReportsStore.instance
          .add(_report(title: 'Anomaly scan', scanId: 'anomaly_scan'));

      await _pump(t, ScanReportsScreen(pregnancy: pregnancy));
      expect(find.text('Anomaly scan'), findsOneWidget);

      await t.tap(find.text('Anomaly scan'));
      await t.pumpAndSettle();

      // ⚠️ THE ASSERTION IS THAT A DIFFERENT SCREEN IS ON TOP. Before this
      // change the tap did nothing at all — there was no gesture on the row —
      // and "nothing happened" is exactly the failure a screenshot review
      // misses, because the list still looks correct afterwards.
      expect(find.byType(ScanReportViewerScreen), findsOneWidget);
    });

    testWidgets('delete is still one tap from the list', (t) async {
      await ScanReportsStore.instance.add(_report(title: 'Growth scan'));
      await _pump(t, ScanReportsScreen(pregnancy: pregnancy));

      // Adding a way in must not cost the way that already worked.
      expect(find.byTooltip('Remove'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  The viewer shows the report and reaches the editor
  // ===========================================================================

  group('the viewer', () {
    testWidgets('shows the title, the date and the linked scan', (t) async {
      await ScanReportsStore.instance.add(_report(
          title: 'Dating scan',
          scanId: 'dating_scan',
          note: 'Dr Rao: recheck in four weeks'));

      await _pump(
          t,
          ScanReportViewerScreen(reportId: 'rep_1', pregnancy: pregnancy));

      expect(find.text('Dating scan'), findsWidgets);
      expect(find.text('Dr Rao: recheck in four weeks'), findsOneWidget);
      expect(find.textContaining('4 Mar 2026'), findsOneWidget);
    });

    testWidgets('a report with no files says so rather than showing blank',
        (t) async {
      await ScanReportsStore.instance.add(_report(title: 'Bloods'));
      await _pump(
          t,
          ScanReportViewerScreen(reportId: 'rep_1', pregnancy: pregnancy));

      // The repo's own rule: an empty section renders an explanation, never a
      // gap that reads as a broken screen.
      expect(find.text('This report has no files attached.'), findsOneWidget);
    });

    testWidgets('Edit reaches the editor', (t) async {
      await ScanReportsStore.instance.add(_report(title: 'Bloods'));
      await _pump(
          t,
          ScanReportViewerScreen(reportId: 'rep_1', pregnancy: pregnancy));

      await t.tap(find.byTooltip('Edit'));
      await t.pumpAndSettle();
      expect(find.byType(ScanReportEditScreen), findsOneWidget);
    });

    testWidgets('a deleted report does not crash the screen still showing it',
        (t) async {
      await ScanReportsStore.instance.add(_report(title: 'Bloods'));
      await _pump(
          t,
          ScanReportViewerScreen(reportId: 'rep_1', pregnancy: pregnancy));

      // ⚠️ THE ONE-FRAME WINDOW. The store notifies before the route pops, so
      // this screen is asked to draw a report that no longer exists. Reading
      // the store by id (rather than holding a value) is what makes that a
      // blank frame instead of a crash.
      //
      // `takeException` is the assertion and not `find`: a build that throws
      // is swallowed by the framework, so the screen would still satisfy an
      // ordinary finder while having failed.
      await ScanReportsStore.instance.remove('rep_1');
      await t.pump();
      expect(t.takeException(), isNull);
    });
  });

  // ===========================================================================
  //  Both naming paths, which is the actual ask
  // ===========================================================================

  group('a report can be renamed two ways', () {
    testWidgets('typed: a free-text name is saved', (t) async {
      await ScanReportsStore.instance.add(_report(title: 'Report'));
      await _pump(
          t, ScanReportEditScreen(reportId: 'rep_1', pregnancy: pregnancy));

      await t.enterText(
          find.byType(TextField).first, 'Thyroid panel, Dr Rao');
      await t.pump();
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();

      expect(ScanReportsStore.instance.reports.first.title,
          'Thyroid panel, Dr Rao');
    });

    testWidgets('picked: choosing a scan renames AND links', (t) async {
      await ScanReportsStore.instance.add(_report(title: 'Report'));
      await _pump(
          t, ScanReportEditScreen(reportId: 'rep_1', pregnancy: pregnancy));

      await t.tap(find.text('Anomaly Scan').first);
      await t.pump();
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();

      final saved = ScanReportsStore.instance.reports.first;
      expect(saved.scanId, 'anomaly_scan');
      expect(saved.title, isNot('Report'));
    });

    testWidgets('typing after picking keeps the link', (t) async {
      await ScanReportsStore.instance
          .add(_report(title: 'Report', scanId: 'anomaly_scan'));
      await _pump(
          t, ScanReportEditScreen(reportId: 'rep_1', pregnancy: pregnancy));

      await t.enterText(find.byType(TextField).first, 'TIFFA at Cloudnine');
      await t.pump();
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();

      final saved = ScanReportsStore.instance.reports.first;
      expect(saved.title, 'TIFFA at Cloudnine');
      // ⚠️ THE WHOLE POINT OF SPLITTING THE TWO CONTROLS.
      expect(saved.scanId, 'anomaly_scan');
    });

    testWidgets('"Not a scan on this list" unlinks and keeps the typed name',
        (t) async {
      await ScanReportsStore.instance
          .add(_report(title: 'Referral letter', scanId: 'nt_scan'));
      await _pump(
          t, ScanReportEditScreen(reportId: 'rep_1', pregnancy: pregnancy));

      await t.tap(find.text('Not a scan on this list'));
      await t.pump();
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();

      final saved = ScanReportsStore.instance.reports.first;
      expect(saved.scanId, isNull);
      expect(saved.title, 'Referral letter');
    });

    testWidgets('an emptied name falls back rather than saving blank',
        (t) async {
      await ScanReportsStore.instance.add(_report(title: 'Bloods'));
      await _pump(
          t, ScanReportEditScreen(reportId: 'rep_1', pregnancy: pregnancy));

      await t.enterText(find.byType(TextField).first, '   ');
      await t.pump();
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();

      // A row that names nothing is worse than a row named generically: the
      // list then has a card she cannot identify at all.
      expect(ScanReportsStore.instance.reports.first.title, 'Report');
    });

    testWidgets('the note is saved, and it is the thing paper never holds',
        (t) async {
      await ScanReportsStore.instance.add(_report(title: 'Growth scan'));
      await _pump(
          t, ScanReportEditScreen(reportId: 'rep_1', pregnancy: pregnancy));

      await t.enterText(
          find.byType(TextField).last, 'Baby measuring 32w. Recheck in 3.');
      await t.pump();
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();

      expect(ScanReportsStore.instance.reports.first.note,
          'Baby measuring 32w. Recheck in 3.');
    });

    testWidgets('Save is disabled until something actually changes', (t) async {
      await ScanReportsStore.instance.add(_report(title: 'Bloods'));
      await _pump(
          t, ScanReportEditScreen(reportId: 'rep_1', pregnancy: pregnancy));

      final btn = t.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNull);
    });
  });
}
