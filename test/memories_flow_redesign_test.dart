// =============================================================================
//  The Memories flow on the current UI, start to finish (2026-10-02).
//
//  The user: "I need the whole flow for the memories to be in the updated new
//  UI." The home was redrawn first (test/memories_home_redesign_test.dart);
//  this holds the other two screens of the flow, Personalise and Preview, and
//  that none of the three still builds the old cream page.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/memories/memory_models.dart';
import 'package:parentveda/memories/memory_templates.dart';
import 'package:parentveda/screens/memories/memories_home_screen.dart';
import 'package:parentveda/screens/memories/memory_personalize_screen.dart';
import 'package:parentveda/screens/memories/memory_preview_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pump(WidgetTester t, Widget home, {double scale = 1.0}) async {
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(900, 2400);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: home,
    ));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
  }

  group('Personalise', () {
    testWidgets('wears the tool shell, with the photo and the words', (t) async {
      await pump(t, const MemoryPersonalizeScreen(type: MemoryType.expecting));
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(find.byKey(const ValueKey('preg_tool_back')), findsOneWidget);
      expect(find.text("We're Expecting"), findsWidgets);
      expect(find.byKey(const ValueKey('memory_photo_empty')), findsOneWidget);
      expect(find.byKey(const ValueKey('memory_pick_gallery')), findsOneWidget);
      expect(find.byKey(const ValueKey('memory_pick_camera')), findsOneWidget);
      // Labels are sentence case now, not caps.
      expect(find.text('Couple names'), findsOneWidget);
      expect(find.text('COUPLE NAMES'), findsNothing);
      expect(find.text('Due month'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('a birth card asks for the baby, not the couple', (t) async {
      await pump(t, const MemoryPersonalizeScreen(type: MemoryType.welcomeBaby));
      expect(find.text("Baby's name"), findsOneWidget);
      expect(find.text('Birth date'), findsOneWidget);
      expect(find.text('Couple names'), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('the one ink button is pinned and opens the preview with her '
        'words', (t) async {
      await pump(t, const MemoryPersonalizeScreen(type: MemoryType.expecting));
      await t.enterText(
          find.widgetWithText(TextField, '').first, 'Aarav & Meera');
      await t.pump();
      final button = find.byKey(const ValueKey('memory_preview_button'));
      expect(button, findsOneWidget);
      await t.tap(button);
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.byType(MemoryPreviewScreen), findsOneWidget);
      final screen =
          t.widget<MemoryPreviewScreen>(find.byType(MemoryPreviewScreen));
      expect(screen.data.coupleNames, 'Aarav & Meera');
    });

    testWidgets('holds at 1.5x text', (t) async {
      await pump(t, const MemoryPersonalizeScreen(type: MemoryType.welcomeBaby),
          scale: 1.5);
      expect(t.takeException(), isNull);
    });
  });

  group('Preview', () {
    MemoryData sample() => MemoryData(type: MemoryType.expecting)
      ..coupleNames = 'Priya & Arjun'
      ..dueMonth = 'March 2027';

    testWidgets('has a round back, a title, the design name, dots and the two '
        'pills', (t) async {
      await pump(t, MemoryPreviewScreen(type: MemoryType.expecting, data: sample()));
      expect(find.byKey(const ValueKey('memory_preview_back')), findsOneWidget);
      expect(find.text('Swipe to see your words in each design.'), findsOneWidget);
      final first = templatesFor(MemoryType.expecting).first;
      expect(find.byKey(const ValueKey('memory_preview_name')), findsOneWidget);
      expect(find.text(first.name), findsOneWidget);
      expect(find.byKey(const ValueKey('memory_save')), findsOneWidget);
      expect(find.byKey(const ValueKey('memory_share')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('swiping changes the design name', (t) async {
      final all = templatesFor(MemoryType.expecting);
      expect(all.length, greaterThan(1));
      await pump(t, MemoryPreviewScreen(type: MemoryType.expecting, data: sample()));
      await t.fling(find.byType(PageView), const Offset(-400, 0), 1500);
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text(all[1].name), findsOneWidget);
      expect(find.text(all.first.name), findsNothing);
    });

    testWidgets('holds at 1.5x text', (t) async {
      await pump(t, MemoryPreviewScreen(type: MemoryType.expecting, data: sample()),
          scale: 1.5);
      expect(t.takeException(), isNull);
    });
  });

  group('the whole flow', () {
    testWidgets('home -> Personalise -> Preview, all on the new UI', (t) async {
      await pump(t, const MemoriesHomeScreen());
      expect(find.byType(PregToolScaffold), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('memories_type_welcomeBaby')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.byType(MemoryPersonalizeScreen), findsOneWidget);
      expect(find.byType(PregToolScaffold), findsWidgets);
      await t.tap(find.byKey(const ValueKey('memory_preview_button')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.byType(MemoryPreviewScreen), findsOneWidget);
    });

    test('no screen of the flow still builds the cream page', () {
      for (final f in [
        'lib/screens/memories/memories_home_screen.dart',
        'lib/screens/memories/memory_personalize_screen.dart',
        'lib/screens/memories/memory_preview_screen.dart',
      ]) {
        final live = _code(f);
        expect(live, contains('_buildClassic'), reason: '$f keeps the old build');
        expect(RegExp(r'_buildClassic\(').allMatches(live).length, 1,
            reason: '$f: only the declaration, nothing calls the classic build');
      }
    });
  });
}
