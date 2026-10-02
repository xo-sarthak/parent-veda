// =============================================================================
//  Kegel Care, redrawn for a glance (2026-10-02).
//
//  The user: "could you do a Mobbin check for the Kegel care screen as well."
//
//  What this holds, on the real screens:
//    · the routine is three big numbers, not a table of label rows;
//    · what / why / how are folded behind a line each, and the SAFETY list is
//      never folded;
//    · the session shows a dot a rep, one ink Pause button and a quiet Exit, and
//      its close carries no emoji (the shipped title's heart is not drawn);
//    · the Care Journey leads with three numbers and a seven-day dot strip, and
//      nothing in it is a streak, a target or a "missed" day;
//    · the guided hold / relax logic and what is saved are as they were.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/tools/kegel_care_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/tools_store.dart';

bool _isEmoji(int r) =>
    r >= 0x1F000 || r == 0xFE0F || (r >= 0x2600 && r <= 0x27BF && r != 0x2713 && r != 0x2714);

List<String> _emojiTexts(WidgetTester t) => [
      for (final w in t.widgetList<Text>(find.byType(Text, skipOffstage: false)))
        if ((w.data ?? w.textSpan?.toPlainText() ?? '').runes.any(_isEmoji))
          w.data ?? w.textSpan!.toPlainText(),
    ];

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .map((l) => l.contains('//') ? l.substring(0, l.indexOf('//')) : l)
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController c;
  late S s;
  final store = ToolsStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 120)));
    await c.load();
    s = S(c.language);
    await store.init();
    await store.setKegelCustomRoutine(hold: 2, relax: 2, reps: 3);
  });

  Future<void> pump(WidgetTester t, {double scale = 1.0, double width = 900}) async {
    t.view.physicalSize = Size(width, 3200);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: KegelCareScreen(controller: c),
    ));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
  }

  Future<void> done(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump();
  }

  group('the front page', () {
    testWidgets('the routine is three numbers, with its time under them',
        (t) async {
      await pump(t);
      expect(find.byKey(const ValueKey('kg_routine_numbers')), findsOneWidget);
      final nums = find.descendant(
          of: find.byKey(const ValueKey('kg_routine_numbers')),
          matching: find.byType(Text));
      expect(nums, findsNWidgets(6)); // three values, three captions
      expect(find.text('2'), findsWidgets);
      expect(find.text('3'), findsWidgets);
      expect(find.byKey(const ValueKey('kg_routine_time')), findsOneWidget);
      expect(find.byKey(const ValueKey('kg_start')), findsOneWidget);
      expect(_emojiTexts(t), isEmpty);
      expect(t.takeException(), isNull);
      await done(t);
    });

    testWidgets('what, why and how are folded; their words open on a tap',
        (t) async {
      await pump(t);
      for (final f in ['what', 'why', 'how']) {
        expect(find.byKey(ValueKey('kg_fold_$f')), findsOneWidget, reason: f);
      }
      expect(find.textContaining('sling of muscles'), findsNothing);
      await t.ensureVisible(find.byKey(const ValueKey('kg_fold_toggle_what')));
      await t.tap(find.byKey(const ValueKey('kg_fold_toggle_what')));
      await t.pumpAndSettle();
      expect(find.textContaining('sling of muscles'), findsOneWidget);
      await done(t);
    });

    testWidgets('the safety list is open on the page, never folded', (t) async {
      await pump(t);
      for (final line in [
        s.kegelSafetyTitle,
        s.kegelSafetyPain,
        s.kegelSafetyBleeding,
        s.kegelSafetyDizziness,
        s.kegelSafetyContractions,
      ]) {
        expect(find.text(line, skipOffstage: false), findsOneWidget, reason: line);
      }
      await done(t);
    });

    testWidgets('holds at 1.5x text on a narrow phone', (t) async {
      await pump(t, scale: 1.5, width: 360);
      expect(t.takeException(), isNull);
      await done(t);
    });
  });

  // FIRST ON PURPOSE: `ToolsStore` is a singleton, so once any test below saves a
  // session the journey is no longer empty. File order is run order.
  group('the Care Journey before any session', () {
    testWidgets('three numbers at zero, seven plain rings, the invitation',
        (t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('kegel_care_journey_row')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('kg_journey_numbers')), findsOneWidget);
      expect(find.text('0'), findsWidgets);
      expect(find.text(s.neverWord), findsOneWidget);
      expect(find.byKey(const ValueKey('kg_week_dots')), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      expect(find.text(s.historyEmptyNote), findsOneWidget);
      expect(t.takeException(), isNull);
      await done(t);
    });
  });

  group('a session', () {
    Future<void> start(WidgetTester t) async {
      await t.ensureVisible(find.byKey(const ValueKey('kg_start')));
      await t.tap(find.byKey(const ValueKey('kg_start')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
    }

    testWidgets('a dot a rep, a cue, one ink Pause and a quiet Exit', (t) async {
      await pump(t);
      await start(t);
      expect(find.byKey(const ValueKey('kg_rep_dots')), findsOneWidget);
      expect(find.byKey(const ValueKey('kg_cue')), findsOneWidget);
      expect(find.text('Gently squeeze and lift'), findsOneWidget);
      expect(find.byKey(const ValueKey('kg_pause')), findsOneWidget);
      expect(find.byKey(const ValueKey('kg_exit')), findsOneWidget);
      expect(find.text(s.repOf(1, 3)), findsOneWidget);
      // Pause turns into Resume, and back.
      await t.tap(find.byKey(const ValueKey('kg_pause')));
      await t.pump();
      expect(find.text(s.resumeLabel), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('kg_pause')));
      await t.pump();
      expect(find.text(s.pauseLabel), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.tap(find.byKey(const ValueKey('kg_exit')));
      await t.pumpAndSettle();
      await done(t);
    });

    testWidgets('the cue changes with the phase', (t) async {
      await pump(t);
      await start(t);
      await t.pump(const Duration(seconds: 2));
      await t.pump(const Duration(milliseconds: 200));
      expect(find.text('Let everything go soft'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('kg_exit')));
      await t.pumpAndSettle();
      await done(t);
    });

    testWidgets('through to the close: no emoji, three numbers, and a choice saves',
        (t) async {
      await pump(t);
      final before = store.kegelSessions;
      await start(t);
      // 3 reps of (2s hold + 2s relax).
      for (var i = 0; i < 26; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      expect(find.byKey(const ValueKey('kg_done_title')), findsOneWidget);
      final title = t.widget<Text>(find.byKey(const ValueKey('kg_done_title'))).data!;
      expect(title.runes.any(_isEmoji), isFalse, reason: 'the heart is drawn: "$title"');
      expect(title.trim(), isNotEmpty);
      expect(find.byKey(const ValueKey('kg_done_numbers')), findsOneWidget);
      expect(_emojiTexts(t), isEmpty);
      // One tap on a choice records the session and goes back.
      await t.tap(find.byKey(const ValueKey('kg_fb_comfortable')));
      await t.pumpAndSettle();
      expect(store.kegelSessions, before + 1);
      expect(store.kegelHistory.first.repetitions, 3);
      expect(store.kegelHistory.first.feedback, 'comfortable');
      expect(t.takeException(), isNull);
      await done(t);
    });

    testWidgets('the close holds at 1.5x text on a narrow phone', (t) async {
      await pump(t, scale: 1.5, width: 360);
      await start(t);
      for (var i = 0; i < 26; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      expect(find.byKey(const ValueKey('kg_done_title')), findsOneWidget);
      expect(t.takeException(), isNull);
      await done(t);
    });
  });

  group('the Care Journey', () {
    Future<void> open(WidgetTester t) async {
      await pump(t);
      await t.tap(find.byKey(const ValueKey('kegel_care_journey_row')));
      await t.pumpAndSettle();
    }

    testWidgets('a session today fills today\'s dot and nothing else', (t) async {
      await store.recordKegelSession(
          holdSeconds: 5, relaxSeconds: 5, repetitions: 10, feedback: 'easy');
      await open(t);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('1'), findsWidgets);
      expect(t.takeException(), isNull);
      await done(t);
    });

    testWidgets('no streak, target or missed day anywhere on it', (t) async {
      await store.recordKegelSession(
          holdSeconds: 5, relaxSeconds: 5, repetitions: 10, feedback: 'easy');
      await open(t);
      expect(find.textContaining(RegExp(r'streak|goal|target|missed|keep it up',
              caseSensitive: false), skipOffstage: false), findsNothing);
      expect(_emojiTexts(t), isEmpty);
      await done(t);
    });

    testWidgets('holds at 1.5x text on a narrow phone', (t) async {
      await store.recordKegelSession(
          holdSeconds: 5, relaxSeconds: 5, repetitions: 10, feedback: 'easy');
      await pump(t, scale: 1.5, width: 360);
      await t.tap(find.byKey(const ValueKey('kegel_care_journey_row')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await done(t);
    });
  });

  group('wiring', () {
    test('the live code uses the numbers, the folds and the dots; the old '
        'pieces are kept but not built', () {
      final live = _code('lib/screens/tools/kegel_care_screen.dart');
      expect(live, contains('_BigStats('));
      expect(live, contains('PregFoldRow('));
      expect(live, contains('_RepDots('));
      expect(live, contains('_WeekDots('));
      // Defined once and never called.
      for (final old in ['_IntroCard(', '_Expandable(', '_routineRow(']) {
        expect(RegExp(RegExp.escape(old)).allMatches(live).length, 1,
            reason: '$old is built again');
      }
      // The save rule is untouched: three full repetitions or nothing.
      expect(live, contains('kMinRepsToSave = 3'));
    });
  });
}
