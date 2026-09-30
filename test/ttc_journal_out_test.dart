// The journal is out of Trying to Conceive (2026-09-28, the user's call).
//
// "Our journal" (lib/screens/ttc/ttc_journal_screen.dart and its store) is no
// longer reachable anywhere on the TTC side, for her or for his side. Every
// entrance is COMMENTED OUT, not deleted, so it can come back.
//
// ⚠️ AND SINCE LATER THE SAME DAY, THE JOURNAL ITSELF IS COMMENTED OUT
// COMPLETELY (the user: "it can be commented out completely... question for
// your doctor stays on appointments... they are not part of the journal").
// The page, the store, its load and its cloud sync are all comment lines now;
// nothing builds `TtcJournalStore.instance`, so nothing loads or syncs it. Its
// old local cache and cloud rows are left alone, not wiped.
//
// Kept for revert (2026-09-28), the rule this test held until then:
//   ONE WRITER SURVIVES, FOR ONE JOB. Questions for the doctor are kept in
//   the journal's store and written from the Appointments page through
//   `writeTtcEntry(kind: TtcEntryKind.question)`.
// Questions for the doctor now have their own store and writer
// (lib/ttc/ttc_doctor_questions_store.dart,
// lib/screens/ttc/ttc_doctor_question_screen.dart), and the scan below fails
// if that flow ever touches the journal again.
//
// Two halves, because a source scan and a pumped screen fail differently: the
// scan catches an entrance on a screen no test pumps; the pump catches a
// journal tile that arrives through data rather than a named call.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_doctor_question_screen.dart';
import 'package:parentveda/screens/ttc/ttc_home_v3.dart';
// Kept for revert (2026-09-28, the journal is commented out completely):
// import 'package:parentveda/screens/ttc/ttc_journal_screen.dart';
import 'package:parentveda/screens/ttc/ttc_partner_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/ttc_surfaces.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_doctor_questions_store.dart';
// Kept for revert (2026-09-28): import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_milestones.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_sync.dart';

/// A file's code with its comments taken out: whole-line `//` comments and
/// `/* ... */` blocks. A commented-out entrance is the kept-for-revert copy,
/// which is exactly what this test wants to allow.
String _code(String path) {
  final noBlocks = File(path)
      .readAsStringSync()
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return noBlocks
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('//'))
      .join('\n');
}

/// Everything a TTC user can reach: the stage's screens and data, and the
/// TTC branches of the shared places (the You and partner pages, the surface
/// list, the brackets).
List<String> _ttcFiles() {
  final out = <String>[];
  for (final dir in ['lib/screens/ttc', 'lib/ttc']) {
    for (final f in Directory(dir).listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final p = f.path.replaceAll(r'\', '/');
      // Kept for revert (2026-09-28): the journal's own two files were
      // skipped while they were live code. They are comment lines now, so
      // `_code` of them is empty and they are scanned like everything else.
      //   if (p.endsWith('/ttc_journal_screen.dart') ||
      //       p.endsWith('/ttc_journal_store.dart')) {
      //     continue;
      //   }
      out.add(p);
    }
  }
  return out
    ..addAll([
      'lib/services/ttc_surfaces.dart',
      'lib/data/brackets/ttc_brackets.dart',
      'lib/screens/profile/pv_you_content.dart',
      'lib/screens/profile/pv_partner_screen.dart',
    ]);
}

/// What counts as a live way into the journal.
final Map<String, RegExp> _entrances = {
  'opens the journal page': RegExp(r'\bopenTtcJournal\('),
  'builds the journal page': RegExp(r'\bTtcJournalScreen\('),
  'names the journal surface': RegExp(r"'ttc_journal'"),
  'names the journal route': RegExp(r"'ttc/journal'"),
  'a journal tool id': RegExp(r"'journal'"),
  "the home's journal tiles": RegExp(r'[^\s]_TtcJournalTiles\('),
  'a journal card': RegExp(r'\b_JournalCard\('),
  "the chapter's write card": RegExp(r'\b_WriteAboutIt\('),
  'the ritual link': RegExp(r'Write about it in our journal'),
  'the timeline or map link': RegExp(r'Write in the journal'),
  'the pairing promise': RegExp(r'The shared journal|Your private journal'),
  'the care circle promise': RegExp(r'You share the journal'),
  // Since 2026-09-28 the journal's code is gone from live code altogether.
  'uses the journal store': RegExp(r'\bTtcJournalStore\b'),
  'uses a journal entry': RegExp(r'\bTtcJournalEntry\b'),
  'uses the journal kinds': RegExp(r'\bTtcEntryKind\b'),
  "the journal's writer": RegExp(r'\bwriteTtcEntry\w*\('),
  "the journal's entry page": RegExp(r'\bopenTtcJournalEntry\('),
  'imports the journal':
      RegExp(r"import '[^']*ttc_journal_(store|screen)\.dart'"),
};

/// Every live Dart file in the app, for the checks that must hold everywhere
/// (start-up, the sync registry, the shared places), not only in TTC.
List<String> _allLibFiles() => [
      for (final f in Directory('lib').listSync(recursive: true))
        if (f is File && f.path.endsWith('.dart'))
          f.path.replaceAll(r'\', '/'),
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // ===========================================================================
  group('no live entrance in the source', () {
    test('no TTC file opens, names or promises the journal', () {
      final hits = <String>[];
      for (final path in _ttcFiles()) {
        final code = _code(path);
        for (final e in _entrances.entries) {
          // `'ttc_journal'` is also the cloud TABLE name, which sync keeps
          // for the entries already written. That is storage, not a way in.
          if (e.key == 'names the journal surface' &&
              path.endsWith('lib/ttc/ttc_sync.dart')) {
            continue;
          }
          // The questions store reads the journal's old CACHE KEY once, to
          // move her questions across (and never writes or clears it). That
          // is the one-time migration, not a way in.
          if (e.key == 'names the journal surface' &&
              path.endsWith('lib/ttc/ttc_doctor_questions_store.dart')) {
            continue;
          }
          // A bare 'journal' id is only a TTC question inside the stage's
          // own folders; the shared You page also carries the pregnancy
          // journal's row under that name, which is not ours to touch.
          if (e.key == 'a journal tool id' && path.startsWith('lib/screens/profile/')) {
            continue;
          }
          if (e.value.hasMatch(code)) hits.add('$path: ${e.key}');
        }
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });

    // Kept for revert (2026-09-28): 'the one writer left writes only a
    // question for the doctor' allowed `writeTtcEntry(kind:
    // TtcEntryKind.question)` and nothing else. There is no journal writer
    // left at all now; the entrance list above refuses any call to it.

    test('no live code anywhere loads or syncs the journal store', () {
      // Start-up (main.dart), the sync registry, the shared places: the
      // store is built lazily by the first `TtcJournalStore.instance`, and
      // building it is what loads its cache and registers its sync. So "no
      // reference in live code" is exactly "never loaded, never synced".
      final hits = <String>[];
      final uses = RegExp(r'\bTtcJournalStore\b|\bTtcTables\.journal\b');
      for (final path in _allLibFiles()) {
        if (uses.hasMatch(_code(path))) hits.add(path);
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
      // And the journal's own files hold no live code at all.
      expect(_code('lib/ttc/ttc_journal_store.dart').trim(), isEmpty);
      expect(_code('lib/screens/ttc/ttc_journal_screen.dart').trim(), isEmpty);
    });

    test('the questions for the doctor do not touch the journal', () {
      final journal = RegExp(r'TtcJournal|TtcEntryKind|writeTtcEntry|'
          r'openTtcJournal|ttc_journal_(store|screen)|TtcTables\.journal');
      for (final path in [
        'lib/ttc/ttc_doctor_questions_store.dart',
        'lib/screens/ttc/ttc_doctor_question_screen.dart',
        'lib/screens/ttc/ttc_appointments_screen.dart',
      ]) {
        expect(journal.hasMatch(_code(path)), isFalse, reason: path);
      }
      // The one-time move READS the old cache key and never writes or
      // clears it: the journal is commented out, not wiped.
      final store = _code('lib/ttc/ttc_doctor_questions_store.dart');
      expect(store, contains('getStringList(kOldJournalKey)'));
      expect(store, isNot(contains('setStringList(kOldJournalKey')));
      expect(store, isNot(contains('remove(kOldJournalKey')));
      expect(TtcDoctorQuestionsStore.table, isNot(TtcTables.journal));
    });

    test('no surface, route or milestone reaches it', () {
      expect(kTtcSurfaces.map((s) => s.id), isNot(contains('ttc_journal')));
      expect(ttcScreenForSurface('ttc_journal'), isNull);
      expect(ttcMilestones.map((m) => m.id),
          isNot(contains('wrote_something')));
      expect(ttcToolById('journal'), isNull);
      expect(kTtcHisToolIds, isNot(contains('journal')));
      expect(kTtcHisToolsStartIds, isNot(contains('journal')));
    });

    test('the journal is kept, not deleted', () {
      // Comment out, never delete: the screen and the store stay, so it can
      // come back in one change.
      expect(File('lib/screens/ttc/ttc_journal_screen.dart').existsSync(),
          isTrue);
      expect(File('lib/ttc/ttc_journal_store.dart').existsSync(), isTrue);
      // Kept for revert (2026-09-28): the page was live code then.
      //   expect(_code('lib/screens/ttc/ttc_journal_screen.dart'),
      //       contains('class TtcJournalScreen'));
      // Now it is kept whole, as comment lines.
      expect(File('lib/screens/ttc/ttc_journal_screen.dart').readAsStringSync(),
          contains('// class TtcJournalScreen'));
      expect(File('lib/ttc/ttc_journal_store.dart').readAsStringSync(),
          contains('// class TtcJournalStore'));
      // And the stored entries are not wiped anywhere on the way out.
      for (final path in _ttcFiles()) {
        expect(_code(path), isNot(contains('TtcJournalStore.instance.clear')),
            reason: path);
      }
    });
  });

  // ===========================================================================
  group('no journal on screen', () {
    setUp(() async {
      CycleStore.instance.resetForTest();
      TtcStore.instance.resetForTest();
      // Kept for revert (2026-09-28): TtcJournalStore.instance.resetForTest();
      LifeStageStore.instance
        ..resetForTest()
        ..setStage(LifeStage.tryingToConceive);
      // Kept for revert (2026-09-28): an old entry was added to the store
      // here. The store is commented out; old entries sit only in the cache.
      //   TtcJournalStore.instance.add(kind: TtcEntryKind.memory, text: 'kept');
      TtcPartnerMode.instance.on = false;
    });
    tearDown(() => TtcPartnerMode.instance.on = false);

    Future<void> pump(WidgetTester tester, Widget child,
        {double height = 20000, double width = 390}) async {
      tester.view.physicalSize = Size(width, height);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
      await tester.pump(const Duration(milliseconds: 400));
    }

    /// Any visible text that says "journal", in either case.
    Finder journalText() => find.byWidgetPredicate((w) {
          final s = w is Text
              ? (w.data ?? w.textSpan?.toPlainText())
              : w is RichText
                  ? w.text.toPlainText()
                  : null;
          return s != null && s.toLowerCase().contains('journal');
        });

    testWidgets('her home has no journal section', (tester) async {
      await pump(tester, const TtcHomeV3());
      // The page was built to its end: the section after where the journal
      // sat is on screen.
      expect(find.text('Talk to experts'), findsWidgets);
      for (final key in [
        'ttc_home_journal_noticed',
        'ttc_home_journal_felt',
        'ttc_home_journal_doctor',
      ]) {
        expect(find.byKey(ValueKey(key)), findsNothing, reason: key);
      }
      // Kept for revert: the heading was TtcS.journalTitle over this line.
      expect(find.text('Keep something from today'), findsNothing);
      expect(find.text(const TtcS(false).journalTitle), findsNothing);
      expect(journalText(), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('her tools hub has no journal tile', (tester) async {
      await pump(tester, const TtcToolsScreen(), height: 6000);
      expect(find.text('Our journal'), findsNothing);
      expect(journalText(), findsNothing);
    });

    testWidgets('his tools hub has no journal tile', (tester) async {
      TtcPartnerMode.instance.on = true;
      await pump(tester, const TtcToolsScreen(), height: 6000);
      expect(find.text('Our journal'), findsNothing);
      expect(journalText(), findsNothing);
    });

    testWidgets("his home has no shared journal card", (tester) async {
      TtcPartnerMode.instance.on = true;
      // 1200 wide, as the partner tests pump it: at 390 his home overflows
      // by 61px on the right, which predates this change (see the report).
      await pump(tester, const TtcPartnerTodayScreen(),
          height: 7000, width: 1200);
      expect(tester.takeException(), isNull);
      expect(find.text(const TtcS(false).partnerJournal), findsNothing);
      expect(journalText(), findsNothing);
    });
  });

  // Kept for revert (2026-09-28): the journal's writer, opened for a
  // question. The journal is commented out; the new writer is below.
  // // ===========================================================================
  // group('the question writer names where the words go', () {
  //   testWidgets('opened for a question: no kind to change, no journal named',
  //       (tester) async {
  //     TtcJournalStore.instance.resetForTest();
  //     tester.view.physicalSize = const Size(390, 1600);
  //     tester.view.devicePixelRatio = 1.0;
  //     addTearDown(tester.view.reset);
  //     // Opened the way the Appointments page opens it, so Save has a page
  //     // to go back to and the notice has somewhere to show.
  //     await tester.pumpWidget(MaterialApp(
  //       home: Scaffold(
  //         body: Builder(
  //           builder: (context) => TextButton(
  //             onPressed: () =>
  //                 writeTtcEntry(context, kind: TtcEntryKind.question),
  //             child: const Text('open'),
  //           ),
  //         ),
  //       ),
  //     ));
  //     await tester.tap(find.text('open'));
  //     await tester.pumpAndSettle();
  //     expect(find.byType(TtcJournalWriteScreen), findsOneWidget);
  //     expect(find.text('A question for your doctor'), findsOneWidget);
  //     expect(find.text('What is this?'), findsNothing);
  //     expect(find.text('Write in your journal'), findsNothing);
  //     await tester.enterText(find.byType(TextField), 'Ask about AMH');
  //     await tester.pump();
  //     await tester.tap(find.text('Save'));
  //     await tester.pumpAndSettle();
  //     expect(find.text('Saved to your questions for the doctor.'),
  //         findsOneWidget);
  //     expect(TtcJournalStore.instance.doctorQuestions.single.text,
  //         'Ask about AMH');
  //   });
  // });

  // ===========================================================================
  group('the question writer is its own, and names where the words go', () {
    testWidgets('no kind to choose, no journal named, saves to the questions',
        (tester) async {
      TtcDoctorQuestionsStore.instance.resetForTest();
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => writeTtcDoctorQuestion(context),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(TtcDoctorQuestionScreen), findsOneWidget);
      expect(find.text('A question for your doctor'), findsOneWidget);
      expect(find.text('What is this?'), findsNothing);
      expect(find.text('Write in your journal'), findsNothing);
      expect(find.textContaining('journal'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Ask about AMH');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Saved to your questions for the doctor.'),
          findsOneWidget);
      expect(TtcDoctorQuestionsStore.instance.questions.single.text,
          'Ask about AMH');
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
