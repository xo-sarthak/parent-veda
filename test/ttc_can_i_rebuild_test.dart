// =============================================================================
//  TTC "Can I...?" rebuilt as a tool (2026-09-29, tools heading by heading)
// -----------------------------------------------------------------------------
//  The user: "the vaguest of all tools... everything is black text... it all
//  looks the same unless you read it carefully." Each group pins one thing
//  she can now do or see:
//
//    · every answer shows a tinted verdict tag (mark + word), the limit as a
//      chip, and "About him" where the answer is his;
//    · the four tints are distinct, and ink and the mark pass contrast;
//    · topic chips filter, search narrows, an empty search offers Ask Veda;
//    · recently checked sits on top, survives a restart, and clears;
//    · the shared-phone switch hides the intimacy answer, search included;
//    · no overflow at 360dp, at 1.5x text, in both languages.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/screens/ttc/ttc_can_i_parts.dart';
import 'package:parentveda/screens/ttc/ttc_can_i_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart' show ttcInk;
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/ttc_can_i_data.dart';
import 'package:parentveda/ttc/ttc_can_i_recent_store.dart';
import 'package:parentveda/ttc/ttc_content_prefs.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {Size size = const Size(420, 4000), double textScale = 1}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    key: UniqueKey(),
    builder: (context, c) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: c!,
    ),
    home: child,
  ));
  await tester.pumpAndSettle();
}

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double _contrast(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

Future<void> _settlePrefs() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TtcCanIRecentStore.instance.resetForTest();
    TtcContentPrefs.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });
  tearDown(() => TtcLang.instance.hinglish = false);

  // ===========================================================================
  group('the answer is visible before it is read', () {
    testWidgets('every row has a verdict tag; limits and "About him" as chips',
        (tester) async {
      await _pump(tester, const TtcCanIScreen());
      expect(find.byType(TtcVerdictTag), findsNWidgets(ttcCanI.length));
      for (final e in ttcCanI) {
        final row = find.byKey(ValueKey('ttc_can_i_row_${e.id}'));
        expect(row, findsOneWidget, reason: e.id);
        expect(
            find.descendant(
                of: row, matching: find.text(e.verdict.label(false))),
            findsOneWidget,
            reason: '${e.id} shows its verdict word');
        final limit = e.limit(false);
        if (limit != null) {
          expect(
              find.descendant(
                  of: row, matching: find.text(ttcCanILimitLabel(limit))),
              findsOneWidget,
              reason: '${e.id} shows its limit as a chip');
        }
        expect(
            find.descendant(of: row, matching: find.text(kTtcCanIAboutHim)),
            e.forPartner ? findsOneWidget : findsNothing,
            reason: e.id);
      }
      expect(find.text('Limit: about 200mg of caffeine a day'),
          findsOneWidget);
    });

    test('four distinct tints; ink words and deep marks pass contrast', () {
      final tints = {for (final v in TtcVerdict.values) ttcVerdictTint(v)};
      expect(tints.length, TtcVerdict.values.length);
      for (final v in TtcVerdict.values) {
        expect(_contrast(ttcInk, ttcVerdictTint(v)), greaterThan(4.5),
            reason: 'the word on the $v tag');
        expect(_contrast(ttcVerdictDeep(v), ttcVerdictTint(v)),
            greaterThan(3.0),
            reason: 'the mark on the $v tag');
      }
    });

    testWidgets('the tag announces itself as an answer', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const TtcCanIScreen());
      // The row merges it into one announcement with its question.
      expect(find.bySemanticsLabel(RegExp('Answer: No, best to stop')),
          findsOneWidget);
      handle.dispose();
    });
  });

  // ===========================================================================
  group('filter, search, ask', () {
    testWidgets('a topic chip narrows the list, All brings it back',
        (tester) async {
      await _pump(tester, const TtcCanIScreen());
      await tester
          .tap(find.byKey(const ValueKey('ttc_can_i_topic_Food and drink')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_can_i_row_chai')), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_can_i_row_smoking')), findsNothing);
      expect(find.byKey(const ValueKey('ttc_can_i_row_xray')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('ttc_can_i_topic_all')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_can_i_row_smoking')),
          findsOneWidget);
    });

    testWidgets('search narrows; nothing found offers Ask Veda her words',
        (tester) async {
      await _pump(tester, const TtcCanIScreen());
      await tester.enterText(find.byType(TextField), 'henna');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_can_i_row_hair_dye')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_can_i_row_chai')), findsNothing);
      await tester.enterText(find.byType(TextField), 'zzqx');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_can_i_ask_veda')), findsOneWidget);
      expect(find.text('Ask Veda: "zzqx"'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('recently checked', () {
    testWidgets('an opened answer sits on top; Clear takes the list away',
        (tester) async {
      await _pump(tester, const TtcCanIScreen());
      expect(find.text('Recently checked'), findsNothing,
          reason: 'nothing checked yet, nothing to show');
      await tester.tap(find.byKey(const ValueKey('ttc_can_i_row_chai')));
      await tester.pumpAndSettle();
      expect(find.byType(PvReaderScreen), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      expect(find.text('Recently checked'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_can_i_recent_chai')),
          findsOneWidget);
      // Typing hides it: she is looking for something else.
      await tester.enterText(find.byType(TextField), 'papaya');
      await tester.pumpAndSettle();
      expect(find.text('Recently checked'), findsNothing);
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_can_i_recent_clear')));
      await tester.pumpAndSettle();
      expect(find.text('Recently checked'), findsNothing);
      expect(find.byKey(const ValueKey('ttc_can_i_row_chai')), findsOneWidget,
          reason: 'Clear takes the list, never the answer');
    });

    test('kept across a restart, newest first, capped, unknown ids skipped',
        () async {
      final s = TtcCanIRecentStore.instance;
      await s.init();
      for (final id in ['chai', 'papaya', 'xray', 'travel', 'smoking',
          'alcohol', 'chai']) {
        s.touch(id);
      }
      await _settlePrefs();
      s.resetForTest();
      expect(s.recent, isEmpty);
      await s.init();
      expect([for (final e in s.recent) e.id],
          ['chai', 'alcohol', 'smoking', 'travel', 'xray']);

      SharedPreferences.setMockInitialValues({
        'ttc_can_i_recent_v1': ['gone_from_data', 'papaya'],
      });
      s.resetForTest();
      await s.init();
      expect([for (final e in s.recent) e.id], ['papaya']);
    });
  });

  // ===========================================================================
  group('the shared-phone switch', () {
    testWidgets('hides the intimacy answer, from the list and from search',
        (tester) async {
      await TtcContentPrefs.instance.setHideIntimate(true);
      await _pump(tester, const TtcCanIScreen());
      expect(find.byKey(const ValueKey('ttc_can_i_row_sex_frequency')),
          findsNothing);
      await tester.enterText(find.byType(TextField), 'sex');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_can_i_row_sex_frequency')),
          findsNothing);
      await TtcContentPrefs.instance.setHideIntimate(false);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_can_i_row_sex_frequency')),
          findsOneWidget);
    });
  });

  // ===========================================================================
  group('no overflow', () {
    for (final hindi in const [false, true]) {
      for (final scale in const [1.0, 1.5]) {
        testWidgets('360dp at ${scale}x (${hindi ? 'Hindi' : 'English'})',
            (tester) async {
          TtcLang.instance.hinglish = hindi;
          await TtcCanIRecentStore.instance.init();
          TtcCanIRecentStore.instance
            ..touch('hot_bath')
            ..touch('chai')
            ..touch('smoking');
          await _pump(tester, const TtcCanIScreen(),
              size: const Size(360, 6000), textScale: scale);
          expect(tester.takeException(), isNull);
          final chip =
              find.byKey(const ValueKey('ttc_can_i_topic_Body and habits'));
          await tester.ensureVisible(chip);
          await tester.pumpAndSettle();
          await tester.tap(chip);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
