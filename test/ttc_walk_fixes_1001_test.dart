// =============================================================================
//  Fixes from the user's walk of the trying-to-conceive app (2026-10-01).
//
//  Eight things the user listed; this holds the ones that are code:
//   1. "I got a positive test" is near the top of the profile, not the bottom.
//   3. An ovulation-test day with nothing logged has no dead band under it.
//   4. A notice has a shadow and an edge you can see (it blended in).
//   5. The ovulation page offers its two reads as the reader does at the foot
//      of an article: a "Read next" rail of the same tiles.
//   7. (PCOS check button: waiting for a screenshot, nothing changed.)
//   8. The "should I seek fertility help" result is one colour family: no
//      empty disc on a heading, no stray mustard.
//  (2, the delete-account crash, is test/pv_delete_account_flow_test.dart.)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/products/pv_store_chrome.dart';
import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/screens/reader/pv_read_tile.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_screens.dart';
import 'package:parentveda/screens/ttc/ttc_ivf_readiness_screen.dart';
import 'package:parentveda/screens/ttc/ttc_ovulation_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_ivf_readiness.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _plus(int n) {
  final t = _today();
  return DateTime(t.year, t.month, t.day + n);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    PregnancyEndedStore.instance.resetForTest();
    await PregnancyEndedStore.instance.load();
    final c = PregnancyController(
      dueDate: DateTime.now().add(const Duration(days: 140)),
    );
    await c.load();
    await c.setDueDate(
      DateTime.now().add(const Duration(days: 140)),
      source: DueDateSource.scan,
    );
    PregnancyController.current = c;
  });

  Future<void> pump(
    WidgetTester t,
    Widget child, {
    double width = 390,
    double height = 3000,
  }) async {
    t.view.physicalSize = Size(width, height);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
    // Fixed pumps, not pumpAndSettle: a screen with a looping animation never
    // settles and would hang the run.
    await t.pump();
    await t.pump(const Duration(milliseconds: 700));
  }

  void cycles({int dayNow = 13}) {
    CycleStore.instance
      ..logPeriodStart(_plus(-(dayNow - 1) - 56))
      ..logPeriodStart(_plus(-(dayNow - 1) - 28))
      ..logPeriodStart(_plus(-(dayNow - 1)));
  }

  double top(WidgetTester t, String key) =>
      t.getTopLeft(find.byKey(ValueKey(key))).dy;

  // ===========================================================================
  group('1. the journey row is near the top of the profile', () {
    testWidgets('trying: under the hero, above orders, her answers and the rest',
        (t) async {
      await pump(t, const PvYouScreen(stage: LifeStage.tryingToConceive),
          height: 6000);
      final hero = top(t, 'pv_profile_hero');
      final journey = top(t, 'pv_profile_journey');
      expect(journey, greaterThan(hero));
      for (final below in [
        'pv_profile_purchases',
        'pv_profile_glance',
        'pv_profile_answers',
        'pv_profile_doctor',
        'pv_profile_family',
        'pv_profile_things',
      ]) {
        expect(journey, lessThan(top(t, below)), reason: 'journey is above $below');
      }
      expect(find.text('I got a positive test'), findsOneWidget);
    });

    testWidgets('pregnancy: the arrival row moves up too; the quiet row stays low',
        (t) async {
      // The controller and the ended store are loaded in setUp (real async
      // work cannot complete inside a testWidgets body).
      await pump(t, const PvYouScreen(stage: LifeStage.pregnancy), height: 6000);
      expect(top(t, 'pv_profile_journey'),
          lessThan(top(t, 'pv_profile_answers')));
      final quiet = top(t, 'pv_profile_quiet');
      expect(quiet, greaterThan(top(t, 'pv_profile_things')),
          reason: 'the quiet row is below everything she uses');
      expect(quiet, lessThan(t.getTopLeft(find.byKey(kPvProfileSettingsRowKey)).dy));
    });
  });

  // ===========================================================================
  group('3 and 5. the ovulation tests page', () {
    testWidgets('every day is one height, and an empty day has no result mark',
        (t) async {
      cycles();
      ttcOvSetResult(_plus(-2), kTtcOvNegative);
      await pump(t, const TtcOvulationScreen());
      final logged = t.getSize(find.byKey(const ValueKey('ttc_ov_day_11'))).height;
      final empty = t.getSize(find.byKey(const ValueKey('ttc_ov_day_12'))).height;
      final today = t.getSize(find.byKey(const ValueKey('ttc_ov_day_13'))).height;
      expect(empty, logged, reason: 'a day with no result is the same height');
      expect(today, logged);
      // A 9pt result mark exists only on the one day that has a result.
      final marks = find.byWidgetPredicate((w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).shape == BoxShape.circle &&
          w.constraints?.maxWidth == 9);
      expect(marks, findsOneWidget);
    });

    testWidgets('the foot is the reader\'s: a rule, "Read next", the same tiles',
        (t) async {
      cycles();
      await pump(t, const TtcOvulationScreen(), height: 5000);
      expect(find.text('Read next'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_ov_read_next')), findsOneWidget);
      expect(find.byType(PvReadTile), findsNWidgets(2));
      // No bordered text rows of its own any more.
      expect(find.byKey(const ValueKey('ttc_ov_read_ttc_read_ovulation_kits')),
          findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('a tile opens its read', (t) async {
      cycles();
      await pump(t, const TtcOvulationScreen(), height: 5000);
      await t.ensureVisible(find.byType(PvReadTile).first);
      await t.tap(find.byType(PvReadTile).first);
      await t.pump();
      await t.pump(const Duration(milliseconds: 700));
      expect(find.byType(PvReaderScreen), findsOneWidget);
    });
  });

  // ===========================================================================
  group('4. a notice you can see', () {
    testWidgets('it has an edge and a real shadow', (t) async {
      await pump(t, Scaffold(body: Builder(builder: (ctx) {
        return Center(
          child: TextButton(
            onPressed: () => pvSnack(ctx, 'Saved'),
            child: const Text('go'),
          ),
        );
      })));
      await t.tap(find.text('go'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      final card = find.byWidgetPredicate((w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).boxShadow != null &&
          (w.decoration as BoxDecoration).boxShadow!.length >= 2);
      expect(card, findsWidgets);
      final d = t.widget<Container>(card.first).decoration as BoxDecoration;
      expect(d.border, isNotNull, reason: 'a hairline edge');
      final deepest = d.boxShadow!
          .map((s) => s.color.a)
          .reduce((a, b) => a > b ? a : b);
      expect(deepest, greaterThanOrEqualTo(0.2),
          reason: 'it was 0.10, which read as no shadow on a white page');
    });
  });

  // ===========================================================================
  group('8. the readiness result is one colour family', () {
    for (final verdict in [IvfVerdict.soon, IvfVerdict.keepTrying]) {
      testWidgets('${verdict.name}: no empty disc, three blocks, one hue',
          (t) async {
        await pump(
          t,
          TtcIvfReadinessResultScreen(
            result: IvfReadinessResult(
              verdict: verdict,
              where: 'Where she is.',
              timing: 'What it means for timing.',
              openDoor: 'What to do next.',
              checklist: const [],
            ),
          ),
          height: 4000,
        );
        expect(t.takeException(), isNull);
        // No empty 30pt disc beside a heading.
        final discs = find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle &&
            w.constraints?.maxWidth == 30);
        expect(discs, findsNothing);
        final blocks = t.widgetList<TtcToolBlock>(find.byType(TtcToolBlock)).toList();
        expect(blocks.length, 3);
        expect(blocks.map((b) => b.hue).toSet(), {kIvfHue},
            reason: 'was blue, mustard and green');
        // The one emphasis left: the hairline on the timing block, and only
        // when the answer is to talk to someone.
        expect(blocks.where((b) => b.outlined).length,
            verdict.pushesToSpecialist ? 1 : 0);
      });
    }
  });
}
