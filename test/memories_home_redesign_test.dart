// =============================================================================
//  Profile > Memories on the current UI (2026-10-02).
//
//  The user: "inside profile -> memories it follows the old UI; fix it, use
//  Mobbin for the screen."
//
//  What changed and what this holds:
//    · it wears the shell every tool front page wears (the tinted field, a round
//      back, a mark, one serif title), not a cream page with a hand-made Back;
//    · the two milestones are rows with a picture of the card, not an emoji;
//    · "My memories" is ALWAYS there. Empty, it says what will be kept and where.
//      It used to vanish, so nobody found out cards are kept there until they
//      had made one (a feature is never hidden for being empty).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/memories/memory_models.dart';
import 'package:parentveda/screens/memories/memories_home_screen.dart';
import 'package:parentveda/screens/memories/memory_personalize_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pump(WidgetTester t, {double scale = 1.0}) async {
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(900, 2400);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: const MemoriesHomeScreen(),
    ));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
  }

  testWidgets('it wears the tool shell, with a round back and a title',
      (t) async {
    await pump(t);
    expect(find.byType(PregToolScaffold), findsOneWidget);
    expect(find.byKey(const ValueKey('preg_tool_back')), findsOneWidget);
    expect(find.text('Memories'), findsWidgets);
    expect(t.takeException(), isNull);
  });

  testWidgets('both milestones are rows with a picture of the card',
      (t) async {
    await pump(t);
    expect(find.byKey(const ValueKey('memories_type_expecting')), findsOneWidget);
    expect(find.byKey(const ValueKey('memories_type_welcomeBaby')), findsOneWidget);
    expect(find.text("We're Expecting"), findsOneWidget);
    expect(find.text('Welcome Baby'), findsOneWidget);
    expect(find.byKey(const ValueKey('memories_example')), findsNWidgets(2));
    // No decorative emoji any more.
    expect(find.text(MemoryType.expecting.emoji), findsNothing);
    expect(find.text(MemoryType.welcomeBaby.emoji), findsNothing);
  });

  testWidgets('"My memories" is there before she has made one, and says so',
      (t) async {
    await pump(t);
    expect(find.text('My memories'), findsOneWidget);
    expect(find.byKey(const ValueKey('memories_empty')), findsOneWidget);
    expect(find.text('Your cards are kept here'), findsOneWidget);
    expect(find.byKey(const ValueKey('memories_grid')), findsNothing);
  });

  testWidgets('a row opens its card maker', (t) async {
    await pump(t);
    await t.tap(find.byKey(const ValueKey('memories_type_expecting')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    expect(find.byType(MemoryPersonalizeScreen), findsOneWidget);
  });

  testWidgets('nothing overflows at 1.5x text', (t) async {
    await pump(t, scale: 1.5);
    expect(t.takeException(), isNull);
  });

  test('the old cream page and the vanishing grid are kept only as a record',
      () {
    final live = _code('lib/screens/memories/memories_home_screen.dart');
    // The live build is the shell; the cream colour appears only in the kept
    // classic build, which nothing calls.
    expect(live, contains('PregToolScaffold('));
    expect(live, contains('_buildClassic'));
    expect(RegExp(r'_buildClassic\(').allMatches(live).length, 1,
        reason: 'only its own declaration: nothing builds the classic screen');
  });
}
