// =============================================================================
//  The journal's capture screens on the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  The user: "My journal section when clicked opens up with the old UI,
//  everything purple." Everything reached from the journal (the add sheet,
//  Guided / Quick capture / Story / Letter, the entry sheet) now wears the tool
//  shell or a white sheet. These pin: each screen draws on the shell with no
//  overflow at 360dp, 1x and 1.5x; the new builds carry no purple or old
//  pp-fonts (source scan); a save still lands in PpJournalStore; a partner's
//  memory still shows the note and no Delete.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/journal_entry.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/journal_capture_screens.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/jv2_data.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/jv2_store.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/pp_journal_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';
import 'package:parentveda/services/journal_store.dart';

const _capture = 'lib/screens/post_pregnancy/journal_v2/journal_capture_screens.dart';
const _list = 'lib/screens/post_pregnancy/journal_v2/pp_journal_screen.dart';

void _phone(WidgetTester t) {
  t.view.physicalSize = const Size(360 * 3, 2400 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
}

/// The real view's size (a bottom sheet sizes itself from it) at [scale].
Widget _app(Widget home, double scale) => Builder(
      builder: (c) => MediaQuery(
        data: MediaQueryData.fromView(View.of(c)).copyWith(textScaler: TextScaler.linear(scale)),
        child: MaterialApp(home: home),
      ),
    );

/// The new (non-revert) builds of a source file: every `Widget build(` up to
/// the next "Kept for revert" marker, plus any extra [from]..[to] spans.
String _newBuilds(String src, List<(String, String)> spans) {
  final out = StringBuffer();
  var i = 0;
  while (true) {
    final b = src.indexOf('Widget build(BuildContext context) {', i);
    if (b < 0) break;
    final end = src.indexOf('Kept for revert (2026-10-07)', b);
    out.writeln(src.substring(b, end < 0 ? src.length : end));
    i = b + 1;
  }
  for (final (from, to) in spans) {
    final a = src.indexOf(from);
    final z = src.indexOf(to, a);
    expect(a, greaterThanOrEqualTo(0), reason: 'marker $from');
    expect(z, greaterThan(a), reason: 'marker $to');
    out.writeln(src.substring(a, z));
  }
  return out.toString();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PpJournalStore.instance.debugReset();
  });

  final screens = <String, Widget Function()>{
    'Guided': () => const GuidedMemoryScreen(),
    'Quick': () => const QuickCaptureScreen(),
    'Quick with a prompt': () => const QuickCaptureScreen(prompt: 'First Day at School'),
    'Story': () => const WriteStoryScreen(),
    'Letter': () => const LetterScreen(),
  };

  for (final scale in [1.0, 1.5]) {
    for (final s in screens.entries) {
      testWidgets('${s.key} draws on the tool shell, no overflow at 360dp ${scale}x', (t) async {
        _phone(t);
        await t.pumpWidget(_app(s.value(), scale));
        await t.pumpAndSettle();
        expect(find.byType(PregToolScaffold), findsOneWidget);
        expect(find.byType(PregToolBack), findsOneWidget, reason: 'a round back, not an X');
        expect(find.byIcon(Icons.close_rounded), findsNothing);
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('the add sheet is white rows with marks, and each row opens its screen (${scale}x)', (t) async {
      _phone(t);
      await t.pumpWidget(_app(
          Builder(
              builder: (c) => Scaffold(
                  body: Center(child: TextButton(onPressed: () => showAddMemorySheet(c), child: const Text('open'))))),
          scale));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      for (final k in ['jv_add_guided', 'jv_add_quick', 'jv_add_story', 'jv_add_letter']) {
        expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
      }
      expect(t.takeException(), isNull);
      await t.tap(find.byKey(const ValueKey('jv_add_letter')));
      await t.pumpAndSettle();
      expect(find.byType(LetterScreen), findsOneWidget);
    });
  }

  testWidgets('a guided prompt opens Quick capture with that prompt as the title', (t) async {
    _phone(t);
    await t.pumpWidget(_app(const GuidedMemoryScreen(), 1));
    await t.pumpAndSettle();
    final first = jvGuided.first.title;
    await t.tap(find.byKey(ValueKey('jv_guided_$first')));
    await t.pumpAndSettle();
    expect(find.byType(QuickCaptureScreen), findsOneWidget);
    expect(find.text(first), findsWidgets);
  });

  testWidgets('a story still saves to PpJournalStore', (t) async {
    _phone(t);
    await t.pumpWidget(_app(const WriteStoryScreen(), 1));
    await t.pumpAndSettle();
    await t.enterText(find.descendant(of: find.byKey(const ValueKey('jv_story_title')), matching: find.byType(TextField)), 'Bath time');
    await t.enterText(find.descendant(of: find.byKey(const ValueKey('jv_story_body')), matching: find.byType(TextField)), 'So many splashes.');
    await t.tap(find.byKey(const ValueKey('jv_story_save')));
    await t.pumpAndSettle();
    final e = PpJournalStore.instance.entries.single;
    expect(e.kind, JvKind.story);
    expect(e.title, 'Bath time');
    expect(e.body, 'So many splashes.');
  });

  testWidgets('a letter still saves to PpJournalStore', (t) async {
    _phone(t);
    await t.pumpWidget(_app(const LetterScreen(), 1));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'One day you will read this.');
    await t.tap(find.byKey(const ValueKey('jv_letter_save')));
    await t.pumpAndSettle();
    final e = PpJournalStore.instance.entries.single;
    expect(e.kind, JvKind.letter);
    expect(e.body, 'One day you will read this.');
  });

  testWidgets('a quick capture still saves to PpJournalStore', (t) async {
    _phone(t);
    await t.pumpWidget(_app(const QuickCaptureScreen(prompt: 'A moment from today'), 1));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'Found both feet.');
    await t.tap(find.byKey(const ValueKey('jv_quick_save')));
    await t.pumpAndSettle();
    final e = PpJournalStore.instance.entries.single;
    expect(e.kind, JvKind.moment);
    expect(e.title, 'A moment from today');
  });

  for (final scale in [1.0, 1.5]) {
    testWidgets('the entry sheet is white and offers Delete on her own memory (${scale}x)', (t) async {
      _phone(t);
      await PpJournalStore.instance.add(kind: JvKind.story, title: 'Bath time', body: 'So many splashes.');
      await t.pumpWidget(_app(const PpJournalScreen(), scale));
      await t.pumpAndSettle();
      await t.tap(find.text('Bath time'));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('pp_journal_entry_sheet')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_journal_delete')), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_journal_partner_note')), findsNothing);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('a partner memory shows the note and no Delete', (t) async {
    _phone(t);
    final child = ChildProfileStore.instance.activeChildId ?? 'local';
    JournalStore.instance.partnerChildEntriesForTest([
      JournalEntry(
        id: 'pj1',
        type: JournalEntryType.memory,
        title: 'Rolled over on the mat',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['$kPpChildTag$child', '${kPpKindTag}moment'],
        isPartner: true,
      ),
    ]);
    addTearDown(() => JournalStore.instance.partnerChildEntriesForTest(const []));
    await t.pumpWidget(_app(const PpJournalScreen(), 1));
    await t.pumpAndSettle();
    await t.tap(find.text('Rolled over on the mat'));
    await t.pumpAndSettle();
    expect(find.text('Added by your partner. Only they can change it.'), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_journal_delete')), findsNothing);
  });

  test('the new builds carry no purple and no old pp fonts (source scan)', () {
    const banned = ['ppPurple', 'ppCoral', 'ppPanel', 'ppJakarta', 'ppFraunces', 'ppBody(', 'jvPaper', 'ppBg'];
    final capture = _newBuilds(File(_capture).readAsStringSync(), [
      ('THE ONE PARENTVEDA LOOK', 'Kept for revert (2026-10-07): the purple-welled sheet'),
    ]);
    final list = _newBuilds(File(_list).readAsStringSync(), [
      ('the entry sheet, the one look', 'void _openBeforeShell('),
    ]);
    for (final (name, src) in [('capture', capture), ('list', list)]) {
      expect(src.length, greaterThan(500), reason: '$name: the scan found the new builds');
      for (final b in banned) {
        expect(src.contains(b), isFalse, reason: '$name new build uses $b');
      }
    }
  });
}
