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
import 'dart:io';

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
  _durability();
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

// =============================================================================
//  Durability, dates and names — the three things My Reports quietly lacked
// -----------------------------------------------------------------------------
//  ⚠️ THE DEFECT THESE EXIST FOR WAS INVISIBLE FROM THE APP. Reports listed,
//  opened and survived a restart, because `shared_preferences` plus a local
//  file path is enough for everything except a new phone. Meanwhile the screen
//  imported `pp_attachments.dart` (for the picker), never called
//  `uploadAttachments`, and both this store and that screen carried comments
//  saying durability was handled.
//
//  So there is no test here that could have been written by reading one file.
//  Each one below crosses a boundary: a claim in a comment against a call that
//  is or is not made, a stored path against what it means, a load order against
//  what it would destroy.
// =============================================================================

void _durability() {
  group('a report knows whether it is safe', () {
    test('a file that is really on this disk means not backed up', () {
      // ⚠️ A REAL FILE, BECAUSE `isRemoteRef` ASKS THE FILESYSTEM. It is
      // `ref.isNotEmpty && !File(ref).existsSync()` - "not an existing local
      // file" is what makes something remote. So this needs a path that
      // genuinely exists, not a plausible-looking camera path.
      //
      // ⚠️ MY FIRST VERSION OF THIS TEST ASSERTED THE IMPLEMENTATION BACK AT
      // ITSELF - `expect(r.needsBackup, r.files.any((f) => !File(f.path)
      // .existsSync()))` - which is not a test, it is the same expression
      // twice. It only surfaced because it also happened to be wrong.
      final dir = Directory.systemTemp.createTempSync('pv_report_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final f = File('${dir.path}/scan.jpg')..writeAsStringSync('x');

      final r = ScanReport(
        id: 'r1',
        title: 'Growth scan',
        dateIso: '2026-08-01T10:00:00.000',
        files: [ReportFile(path: f.path, name: 'scan.jpg')],
      );
      expect(r.needsBackup, isTrue,
          reason: 'the bytes are still only on this device');
    });

    test('a storage reference means backed up', () {
      // What `StorageService.upload` returns on success: `<uid>/<type>/<name>`,
      // which is not a path on this disk.
      const r = ScanReport(
        id: 'r2',
        title: 'Growth scan',
        dateIso: '2026-08-01T10:00:00.000',
        files: [
          ReportFile(path: 'abc-uid/report/scan.jpg', name: 'scan.jpg'),
        ],
      );
      expect(r.needsBackup, isFalse);
    });

    test('the known weakness of a path-based signal, stated', () {
      // ⚠️ A LOCAL FILE THAT HAS BEEN DELETED READS AS "REMOTE", because
      // `isRemoteRef` cannot tell a storage key from a path to something that
      // is no longer there. So a report whose photo the OS cleaned up stops
      // showing "Only on this phone" - it looks safe, and it is gone.
      //
      // This is pinned rather than fixed because the fix is worse than the bug
      // at this size: distinguishing them properly means a marker on
      // `ReportFile` saying which kind of string it holds, written at upload
      // time - which is a stored flag, and stored flags are what the derived
      // signal exists to avoid. If report files ever start disappearing, THIS
      // is the trade-off to revisit, and the answer is probably to have
      // `StorageService.upload` return a tagged value rather than a bare
      // String.
      const r = ScanReport(
        id: 'r3',
        title: 'Gone',
        dateIso: '2026-08-01T10:00:00.000',
        files: [
          ReportFile(path: '/no/such/dir/vanished.jpg', name: 'vanished.jpg'),
        ],
      );
      expect(r.needsBackup, isFalse,
          reason: 'documents the limitation; not a desirable behaviour');
    });

    test('a report with no files is not flagged', () {
      // Metadata rides the cloud blob, so a fileless report is not "unbacked".
      // Flagging it would put "Only on this phone" on a row where the words are
      // false and there is nothing she could do about it.
      const r = ScanReport(
          id: 'r2', title: 'Note to self', dateIso: '2026-08-01T10:00:00.000');
      expect(r.needsBackup, isFalse);
    });
  });

  group('two dates, and the old rows still read correctly', () {
    test('a report written before the field existed falls back', () {
      // ⚠️ THE MIGRATION-SAFETY ASSERTION. Every report already on a phone has
      // no `reportDateIso` key. If the fallback broke, their dates would read
      // as empty and the list would reorder itself under her.
      final r = ScanReport.fromJson({
        'id': 'old',
        'title': 'Anomaly scan',
        'dateIso': '2026-03-04T09:00:00.000',
        'files': const [],
      });
      expect(r.reportDateOrNull, isNull);
      expect(r.reportDateIso, '2026-03-04T09:00:00.000');
    });

    test('an untouched report round-trips to the exact same json', () {
      // The field is written only when set, so nothing rewrites a stored blob
      // just by being read - which matters because the blob now also syncs.
      final json = {
        'id': 'old',
        'title': 'Anomaly scan',
        'dateIso': '2026-03-04T09:00:00.000',
        'scanId': null,
        'note': '',
        'files': const [],
      };
      final out = ScanReport.fromJson(json).toJson();
      expect(out.containsKey('reportDateIso'), isFalse);
    });

    test('a set report date is kept and preferred', () {
      final r = ScanReport.fromJson({
        'id': 'new',
        'title': 'Old blood panel',
        'dateIso': '2026-08-20T18:00:00.000',
        'reportDateIso': '2026-02-11T00:00:00.000',
        'files': const [],
      });
      expect(r.reportDateIso, '2026-02-11T00:00:00.000');
      expect(r.dateIso, '2026-08-20T18:00:00.000',
          reason: 'when she added it is a separate fact and must survive');
    });

    test('the list sorts on the report date, newest first', () async {
      final store = ScanReportsStore.instance;
      store.resetForTest();
      // Added in one order, dated in another - the exact case that motivated
      // the field: photographing a stack of old reports in whatever order they
      // came off the pile.
      await store.add(const ScanReport(
          id: 'a',
          title: 'A',
          dateIso: '2026-08-20T10:00:00.000',
          reportDateIso: '2026-01-05T00:00:00.000'));
      await store.add(const ScanReport(
          id: 'b',
          title: 'B',
          dateIso: '2026-08-20T10:00:01.000',
          reportDateIso: '2026-06-05T00:00:00.000'));
      await store.add(const ScanReport(
          id: 'c',
          title: 'C',
          dateIso: '2026-08-20T10:00:02.000',
          reportDateIso: '2026-03-05T00:00:00.000'));
      expect(store.reports.map((r) => r.id).toList(), ['b', 'c', 'a']);
      store.resetForTest();
    });

    test('same-day reports break the tie on when she added them', () async {
      final store = ScanReportsStore.instance;
      store.resetForTest();
      // Several rows share a report date when she photographs a stack. Within
      // that day the most recently added belongs on top - it is the one she is
      // looking at.
      await store.add(const ScanReport(
          id: 'first',
          title: 'first',
          dateIso: '2026-08-20T10:00:00.000',
          reportDateIso: '2026-05-05T00:00:00.000'));
      await store.add(const ScanReport(
          id: 'second',
          title: 'second',
          dateIso: '2026-08-20T10:05:00.000',
          reportDateIso: '2026-05-05T00:00:00.000'));
      expect(store.reports.first.id, 'second');
      store.resetForTest();
    });
  });

  group('the cloud contract', () {
    test('the blob round-trips through the store', () async {
      final store = ScanReportsStore.instance;
      store.resetForTest();
      await store.add(const ScanReport(
          id: 'x',
          title: 'Thyroid panel',
          dateIso: '2026-08-01T10:00:00.000',
          reportDateIso: '2026-07-30T00:00:00.000',
          note: 'Recheck in 4 weeks'));
      final blob = store.cloudData();

      store.resetForTest();
      expect(store.reports, isEmpty);
      store.applyCloudData(blob);

      expect(store.reports.length, 1);
      final r = store.reports.single;
      expect(r.id, 'x');
      expect(r.title, 'Thyroid panel');
      expect(r.note, 'Recheck in 4 weeks');
      expect(r.reportDateIso, '2026-07-30T00:00:00.000',
          reason: 'the report date must survive the round trip, or a synced '
              'library re-sorts itself on the next device');
      store.resetForTest();
    });

    test('the blob carries file references, never bytes', () async {
      final store = ScanReportsStore.instance;
      store.resetForTest();
      await store.add(const ScanReport(
        id: 'y',
        title: 'Scan',
        dateIso: '2026-08-01T10:00:00.000',
        files: [ReportFile(path: 'uid/report/img.jpg', name: 'img.jpg')],
      ));
      final blob = store.cloudData() as List;
      final files = (blob.single as Map)['files'] as List;
      expect((files.single as Map)['path'], 'uid/report/img.jpg');
      // A photographed report inside a JSON blob would be enormous and the
      // wrong place for a medical image.
      expect((files.single as Map).containsKey('bytes'), isFalse);
      store.resetForTest();
    });

    test('the cloud key is stable', () {
      // ⚠️ THE KEY IS IDENTITY. Renaming it strands every report already synced
      // under the old one - they are not deleted, they simply stop being found,
      // which is worse because nothing reports it.
      expect(ScanReportsStore.instance.cloudKey, 'scan_reports');
    });
  });
}
