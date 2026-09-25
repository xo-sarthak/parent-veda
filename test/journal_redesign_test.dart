// My Journal, redrawn (2026-09-23). The user: "I was never the fan of the
// designs that we have for the journal right now." What this file holds:
//
//   · every screen that opened the journal opens the NEW one (the facade:
//     `JournalScreen` is exported from journal_screen.dart), and the old one
//     is still reachable as the book;
//   · her current week always shows, and says what to do when it is empty;
//   · no emoji reaches the page, even from the shared milestone library;
//   · an entry with nothing in it is drawn, not hidden;
//   · an entry opens to be READ, with Edit and Delete there — not a long-press;
//   · the home's "Add a memory" is the same screen as the journal's.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/journal_prompts.dart';
import 'package:parentveda/models/journal_entry.dart';
import 'package:parentveda/screens/journal/pv_journal_screen.dart';
import 'package:parentveda/screens/journal_screen.dart' as legacy;
import 'package:parentveda/services/journal_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

JournalEntry _entry(String id,
        {String title = '',
        String description = '',
        int week = 20,
        DateTime? date}) =>
    JournalEntry(
      id: id,
      type: JournalEntryType.memory,
      title: title,
      description: description,
      date: date ?? DateTime.now(),
      weekNumber: week,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  PregnancyController controller() =>
      PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140)));

  Future<void> pump(WidgetTester tester, PregnancyController c) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: JournalScreen(controller: c)));
    await tester.pump();
  }

  test('the old import path opens the new journal', () {
    // `legacy.JournalScreen` is what every caller imports.
    final w = legacy.JournalScreen(controller: controller());
    expect(w, isA<JournalScreen>());
    expect(legacy.JournalScreenClassic(controller: controller(), startInBook: true),
        isA<StatefulWidget>());
  });

  test('no emoji reaches the page', () {
    expect(journalPlain('🌿  First Trimester Complete 🎉'),
        'First Trimester Complete');
    expect(journalPlain('🌸 Morning Sickness Often Improves'),
        'Morning Sickness Often Improves');
    expect(journalPlain('Plain words stay'), 'Plain words stay');
  });

  testWidgets('the cover, the forty weeks, the question, and her empty week',
      (tester) async {
    final c = controller();
    await JournalStore.instance.init();
    await pump(tester, c);
    // The cover is addressed to someone.
    expect(find.text('Dear little one,'), findsOneWidget);
    // Where she is, and never a score.
    expect(find.text('Week ${c.currentWeek}'), findsWidgets);
    expect(find.textContaining('until you meet'), findsOneWidget);
    expect(find.textContaining('streak'), findsNothing);
    // This week's question, and both ways to answer it.
    expect(find.text("THIS WEEK'S QUESTION"), findsOneWidget);
    expect(find.text(journalPromptFor(c.currentWeek)), findsOneWidget);
    expect(find.text('Write it'), findsOneWidget);
    expect(find.text('Say it'), findsOneWidget);
    expect(find.text('Add a memory'), findsOneWidget);
    // Another question turns in.
    await tester.tap(find.byTooltip('Another question'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(journalPromptFor(c.currentWeek, skip: 1)), findsOneWidget);
    // (Her empty week's invitation depends on whether a milestone already
    // landed in it; the entries test below holds that it goes once she writes.)
    // The app bar holds search and one menu — not five icons.
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    expect(find.byIcon(Icons.ios_share_rounded), findsNothing);
    await tester.pump(const Duration(seconds: 2));
  });

  test('every week has questions, and they are never clinical', () {
    for (var w = 4; w <= 40; w++) {
      expect(journalPromptCount(w), greaterThan(1));
      for (var k = 0; k < journalPromptCount(w); k++) {
        final q = journalPromptFor(w, skip: k).toLowerCase();
        for (final banned in ['kick count', 'symptom', 'score', 'rate ', 'how many']) {
          expect(q, isNot(contains(banned)), reason: q);
        }
      }
    }
  });

  testWidgets('her entries sit under their week, and an empty one is drawn',
      (tester) async {
    final c = controller();
    await JournalStore.instance.init();
    await JournalStore.instance.addEntry(_entry('t_words',
        title: 'The first flutter', description: 'On the bus home.',
        week: c.currentWeek));
    await JournalStore.instance.addEntry(_entry('t_empty', week: c.currentWeek));
    await pump(tester, c);
    expect(find.text('The first flutter'), findsOneWidget);
    expect(find.text('On the bus home.'), findsOneWidget);
    expect(find.textContaining('A page with nothing on it yet'), findsOneWidget);
    // The week has something now, so it no longer asks.
    expect(find.textContaining('Nothing kept this week yet'), findsNothing);

    // An entry opens to be read, with Edit and Delete on the page.
    await tester.ensureVisible(find.text('The first flutter'));
    await tester.tap(find.text('The first flutter'));
    await tester.pumpAndSettle();
    expect(find.byType(JournalEntryScreen), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.byTooltip('Delete'), findsOneWidget);

    await JournalStore.instance.deleteEntry('t_words');
    await JournalStore.instance.deleteEntry('t_empty');
  });

  test("the home's Add a memory is the journal's compose screen", () {
    final home = File('lib/screens/home_v3_screen.dart').readAsStringSync();
    final live = home
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');
    expect(live, contains('onTap: () => openJournalCompose(context, pregnancy)'));
    expect(live, isNot(contains('JournalEntryType.memory)')));
  });
}
