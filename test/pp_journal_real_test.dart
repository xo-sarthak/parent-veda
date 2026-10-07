// =============================================================================
//  The parenting journal saves what she writes, and shows only her child
// -----------------------------------------------------------------------------
//  Gap analysis P1: "Record a memory" said "Memory saved to the story" and
//  stored nothing, then the journal greeted "Priya" with another family's
//  memories. These tests hold both halves.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/journal_v2/journal_capture_screens.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/jv2_data.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/jv2_store.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/pp_journal_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PpJournalStore.instance.debugReset();
  });

  test('an empty memory is not saved; a written one is', () async {
    expect(await PpJournalStore.instance.add(kind: JvKind.moment, body: '   '), isFalse);
    expect(PpJournalStore.instance.entries, isEmpty);
    expect(await PpJournalStore.instance.add(kind: JvKind.story, title: 'First giggle', body: 'At the fan.'), isTrue);
    expect(PpJournalStore.instance.entries.single.title, 'First giggle');
  });

  test('age on the day reads naturally', () {
    final dob = DateTime(2026, 1, 10);
    expect(ppAgeOn(DateTime(2026, 1, 15), dob), '5 days');
    expect(ppAgeOn(DateTime(2026, 2, 20), dob), '5 weeks');
    expect(ppAgeOn(DateTime(2026, 7, 10), dob), '6 months');
    expect(ppAgeOn(DateTime(2028, 4, 12), dob), '2 years 3 months');
  });

  testWidgets('typing in Quick capture and tapping Save writes one memory', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: QuickCaptureScreen(prompt: 'A moment from today'))));
    await tester.enterText(find.byType(TextField), 'He found his feet today.');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(PpJournalStore.instance.entries.single.body, 'He found his feet today.');
    expect(find.textContaining("saved to"), findsOneWidget);
  });

  testWidgets('the journal starts empty with an invitation, never a stranger', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: PpJournalScreen()));
    await tester.pump();
    expect(find.textContaining('goes here.'), findsOneWidget);
    expect(find.textContaining('Priya'), findsNothing);
    expect(find.textContaining('Puppy'), findsNothing);
    await PpJournalStore.instance.add(kind: JvKind.moment, title: 'Bath time', body: 'So many splashes.');
    await tester.pump();
    expect(find.text('Bath time'), findsOneWidget);
  });

  test('nothing opens the demo journal any more', () {
    for (final f in [
      'lib/screens/post_pregnancy/pp_home_v3.dart',
      'lib/screens/post_pregnancy/my_child_screen.dart',
      'lib/screens/post_pregnancy/post_pregnancy_home.dart',
    ]) {
      final live = File(f).readAsStringSync().split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
      expect(RegExp(r'(?<!\/\* was )JournalV2Home\(\)').hasMatch(live.replaceAll('/* was JournalV2Home (demo), kept for revert */', '')), isFalse, reason: f);
      expect(live.contains('PpJournalScreen()'), isTrue, reason: f);
    }
    final capture = File('lib/screens/post_pregnancy/journal_v2/journal_capture_screens.dart').readAsStringSync();
    expect(capture.contains('PpJournalStore.instance.add('), isTrue);
  });
}
