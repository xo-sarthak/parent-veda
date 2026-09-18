// The per-scan note (2026-09-18): saved locally, shown on the Up-next card
// and on the scan's row, survives a reload, and deleting clears it. The user
// asked for a second button on the card that "actually helps the user do
// something else… it should be a working feature, not static."

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/tests_scans_reports_data.dart';
import 'package:parentveda/screens/brackets/scan_timeline_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/scans_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

PregnancyController _at(int week) {
  final now = DateTime(2026, 1, 1);
  return PregnancyController(
    now: now,
    dueDate: now.add(Duration(days: (40 - week) * 7)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ScansStore.instance.init();
    for (final s in kTestsScans) {
      await ScansStore.instance.setNote(s.id, '');
    }
  });

  test('a note is saved, read back, and cleared', () async {
    final store = ScansStore.instance;
    expect(store.noteFor('anomaly_scan'), isNull);
    await store.setNote('anomaly_scan', '  Dr Mehta said bring the NT report.  ');
    expect(store.noteFor('anomaly_scan'), 'Dr Mehta said bring the NT report.');
    // Persisted — the prefs hold it under the store's own key.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('scans_notes'), contains('Dr Mehta'));
    await store.setNote('anomaly_scan', '');
    expect(store.noteFor('anomaly_scan'), isNull);
  });

  testWidgets('the card offers a note, and a saved note shows on card and row',
      (t) async {
    final c = _at(21);
    addTearDown(c.dispose);
    await t.pumpWidget(MaterialApp(home: ScanTimelineScreen(pregnancy: c)));
    await t.pumpAndSettle();

    expect(find.text('Add a note'), findsOneWidget);

    await ScansStore.instance.setNote('anomaly_scan', 'Ask about the placenta.');
    await t.pumpAndSettle();

    expect(find.text('Edit the note'), findsOneWidget);
    // On the card AND on the run's row for the same scan.
    expect(find.text('Ask about the placenta.'), findsNWidgets(2));
  });

  testWidgets('the sheet saves what she typed', (t) async {
    final c = _at(21);
    addTearDown(c.dispose);
    await t.pumpWidget(MaterialApp(home: ScanTimelineScreen(pregnancy: c)));
    await t.pumpAndSettle();

    await t.tap(find.text('Add a note'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'Report number 4471');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();

    expect(ScansStore.instance.noteFor('anomaly_scan'), 'Report number 4471');
    expect(find.text('Report number 4471'), findsWidgets);
  });
}
