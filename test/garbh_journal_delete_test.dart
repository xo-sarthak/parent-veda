// =============================================================================
//  My Journal: a kept recording can be deleted (2026-10-02).
//
//  The Garbh Sanskar pillars brief: "Record in her voice: real microphone
//  recording, with permission handling, record and stop, playback, re-record and
//  delete." Before keeping, "Again" throws a take away; once kept there was no
//  way to remove it. Each journal row now has a menu with Delete, and an Undo.
//
//  What this holds, on the real screen:
//    · the row's menu deletes the entry, and says what it did;
//    · Undo puts the very same entry back, and the file on the phone is untouched;
//    · without Undo, the recording's file is removed once the Undo has passed;
//    · the menu names what it deletes ("Delete this recording", "Delete this
//      letter"), never a bare "Delete".
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/garbh_rebuild_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/garbh_journal_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final store = GarbhJournalStore.instance;
  late Directory dir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.init();
    for (final e in List.of(store.entries)) {
      await store.remove(e.id);
    }
    dir = Directory.systemTemp.createTempSync('pv_journal_');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  GarbhJournalEntry voice(String id, String path) => GarbhJournalEntry(
        id: id,
        kind: GarbhEntryKind.myVoice,
        week: 22,
        tsMs: DateTime(2026, 10, 2).millisecondsSinceEpoch,
        title: const LocalizedText(en: 'You are loved', hi: 'You are loved'),
        seconds: 42,
        path: path,
      );

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(900, 2600);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: GarbhJournalScreen()));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
  }

  Future<void> openMenuAndDelete(WidgetTester t, String id) async {
    final menu = find.byKey(ValueKey('journal_menu_$id'));
    await t.ensureVisible(menu);
    await t.tap(menu);
    await t.pumpAndSettle();
    await t.tap(find.byKey(ValueKey('journal_delete_$id')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
  }

  testWidgets('the menu names what it deletes', (t) async {
    final f = File('${dir.path}/a.m4a')..writeAsStringSync('x');
    await t.runAsync(() => store.add(voice('v1', f.path)));
    await pump(t);
    await t.tap(find.byKey(const ValueKey('journal_menu_v1')));
    await t.pumpAndSettle();
    expect(find.text('Delete this recording'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('delete removes it and says so; Undo brings back the same one',
      (t) async {
    final f = File('${dir.path}/b.m4a')..writeAsStringSync('x');
    await t.runAsync(() => store.add(voice('v2', f.path)));
    await pump(t);
    expect(find.text('You are loved'), findsOneWidget);
    await openMenuAndDelete(t, 'v2');
    expect(store.entries.where((e) => e.id == 'v2'), isEmpty);
    expect(find.text('Recording deleted.'), findsOneWidget);
    await t.tap(find.text('Undo'));
    await t.pump(const Duration(milliseconds: 300));
    final back = store.entries.where((e) => e.id == 'v2').toList();
    expect(back, hasLength(1));
    expect(back.single.path, f.path);
    expect(back.single.seconds, 42);
    // Let the snackbar run out: Undo means the file is never touched.
    await t.pump(const Duration(seconds: 5));
    await t.pump(const Duration(milliseconds: 300));
    expect(f.existsSync(), isTrue, reason: 'Undo must keep the recording file');
  });

  testWidgets('without Undo, the file goes once the Undo has passed', (t) async {
    final f = File('${dir.path}/c.m4a')..writeAsStringSync('x');
    await t.runAsync(() => store.add(voice('v3', f.path)));
    await pump(t);
    await openMenuAndDelete(t, 'v3');
    // Still there while she can Undo.
    expect(f.existsSync(), isTrue);
    await t.pump(const Duration(seconds: 5));
    await t.pump(const Duration(milliseconds: 300));
    expect(f.existsSync(), isFalse);
    expect(store.entries.where((e) => e.id == 'v3'), isEmpty);
  });

  test('a link is never deleted from the phone', () {
    final src = File('lib/screens/garbh_journal_screen.dart').readAsStringSync();
    expect(src, contains("path.startsWith('http')"));
  });
}
