// =============================================================================
//  One journal, two stages (2026-10-17)
// -----------------------------------------------------------------------------
//  The user: the pregnancy and parenting journals "look as separate things…
//  it looks like something else was built." They now draw one book from
//  widgets/journal/journal_keepsake.dart. These pin it so they cannot drift
//  apart again:
//    · both homes use the shared V3JournalSection card (live code, not a
//      commented-out line);
//    · both journals draw the shared cover, dot strip, question card and rows;
//    · a parenting memory opens as a page by name (`pp/journal/entry`), not a
//      sheet — the wiring gate, checked by tapping;
//    · the parenting questions use no he/she, so they read right for any child.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/pp_journal_prompts.dart';
import 'package:parentveda/data/reads/read_images.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/jv2_data.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/jv2_store.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/pp_journal_screen.dart';

/// The source with every `//` comment line dropped, so a commented-out call
/// does not count as wired.
String _live(String path) => File(path)
    .readAsLinesSync()
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

class _Names extends NavigatorObserver {
  final names = <String?>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => names.add(route.settings.name);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PpJournalStore.instance.debugReset();
  });

  test('both homes use the one journal card', () {
    final preg = _live('lib/screens/home_v3_screen.dart');
    final pp = _live('lib/screens/post_pregnancy/pp_home_v3.dart');
    expect(preg, contains('V3JournalSection('));
    expect(pp, contains('V3JournalSection('));
    expect(pp.contains('_pad(_JournalInvite('), isFalse, reason: 'the parenting-only card is retired');
    // Every tile reaches the page it names.
    for (final s in ['showAddMemorySheet(context)', 'GuidedMemoryScreen()', "'A photo from today'", 'LetterScreen()']) {
      expect(pp, contains(s), reason: s);
    }
    expect(preg, contains("RouteSettings(name: 'journal')"), reason: 'the pregnancy journal is named');
  });

  test('both journals draw the same keepsake', () {
    final preg = _live('lib/screens/journal/pv_journal_screen.dart');
    final pp = _live('lib/screens/post_pregnancy/journal_v2/pp_journal_screen.dart');
    for (final w in ['JournalCover(', 'JournalDotStrip(', 'JournalQuestionCard(', 'JournalSectionHead(', 'JournalPageRow(', 'kJournalPaper']) {
      expect(preg, contains(w), reason: 'pregnancy: $w');
      expect(pp, contains(w), reason: 'parenting: $w');
    }
    final capture = _live('lib/screens/post_pregnancy/journal_v2/journal_capture_screens.dart');
    expect(RegExp('return JournalPaperScaffold\\(').allMatches(capture).length, 4,
        reason: 'Guided, Quick capture, Story and Letter are written on paper');
  });

  testWidgets('a parenting memory opens as a page, by name', (t) async {
    t.view.physicalSize = const Size(360 * 3, 2400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await PpJournalStore.instance.add(kind: JvKind.story, title: 'First giggle', body: 'At the ceiling fan.');
    final obs = _Names();
    await t.pumpWidget(MaterialApp(home: const PpJournalScreen(), navigatorObservers: [obs]));
    await t.pumpAndSettle();
    await t.tap(find.text('First giggle'));
    await t.pumpAndSettle();
    expect(obs.names, contains('pp/journal/entry'));
    expect(find.byType(PpJournalEntryScreen), findsOneWidget);
    expect(find.text('At the ceiling fan.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  test('every journal painting resolves to our own copy, with a credit', () {
    for (final band in [1, 2, 3]) {
      for (final id in ['journal_cover_t$band', 'journal_question_t$band', 'pp_journal_cover_b$band', 'pp_journal_question_b$band']) {
        expect(readImageFor(id), '$kReadImageBase$id.jpg', reason: id);
        expect(kReadImageCredits[id], isNotNull, reason: '$id has no credit');
      }
    }
  });

  test('the parenting questions never assume he or she', () {
    final pronoun = RegExp(r'\b(he|she|his|her|him|hers)\b', caseSensitive: false);
    for (final b in kPpPromptBands) {
      for (final q in [...b.questions, b.note]) {
        expect(pronoun.hasMatch(q), isFalse, reason: q);
      }
    }
    // The band follows the age, and "another" turns to a different question.
    expect(ppPromptBandFor(4).fromMonths, 3);
    expect(ppPromptBandFor(30).fromMonths, 24);
    expect(ppJournalPromptFor(4), isNot(ppJournalPromptFor(4, skip: 1)));
  });
}
