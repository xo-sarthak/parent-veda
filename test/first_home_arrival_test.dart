// The first home after onboarding (2026-10-18): the welcome, the getting-ready
// home, the intro film as a card, and the wiring that makes each reachable.
// See lib/widgets/pv_home_arrival.dart and STILL-OPEN §62.6.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parentveda/screens/ttc/ttc_intro_flow.dart';
import 'package:parentveda/ttc/ttc_home_situation.dart';
import 'package:parentveda/ttc/ttc_phase.dart';
import 'package:parentveda/ttc/ttc_ready_plan.dart';
import 'package:parentveda/ttc/ttc_ready_plan_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/widgets/pv_home_arrival.dart';

String _src(String path) => File(path).readAsStringSync();

Widget _home({required Widget child}) => MaterialApp(
      home: Scaffold(body: PvHomeArrival(child: child)),
    );

void main() {
  setUp(PvFirstHome.resetForTest);

  group('the welcome is owed once, by onboarding', () {
    test('nothing is owed until onboarding says so', () {
      expect(PvFirstHome.claim(), isNull);
      expect(PvFirstHome.thisLaunch, isFalse);
    });

    test('owed, it is claimed once and marks this launch', () {
      PvFirstHome.owe();
      expect(PvFirstHome.claim(), isNotNull);
      expect(PvFirstHome.claim(), isNull);
      expect(PvFirstHome.thisLaunch, isTrue);
    });
  });

  group('the home arrives in order, only the first time', () {
    testWidgets('a section starts hidden and settles in', (tester) async {
      PvFirstHome.owe();
      await tester.pumpWidget(_home(
          child: const PvArrive(
              delay: PvArriveAt.sections, child: Text('Explore by topic'))));
      final opacity = tester.widget<Opacity>(find.ancestor(
          of: find.text('Explore by topic'), matching: find.byType(Opacity)));
      expect(opacity.opacity, lessThan(0.01));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 500));
      final settled = tester.widget<Opacity>(find.ancestor(
          of: find.text('Explore by topic'), matching: find.byType(Opacity)));
      expect(settled.opacity, 1.0);
      // The note, then gone.
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('every other open is just the page', (tester) async {
      await tester.pumpWidget(_home(
          child: const PvArrive(child: Text('Explore by topic'))));
      expect(
          find.ancestor(
              of: find.text('Explore by topic'), matching: find.byType(Opacity)),
          findsNothing);
    });

    testWidgets('the note says where it came from, once', (tester) async {
      PvFirstHome.owe();
      await tester.pumpWidget(_home(child: const SizedBox()));
      expect(find.text(kPvFirstHomeNote), findsNothing);
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(kPvFirstHomeNote), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('the big number counts up, then reads as written',
        (tester) async {
      PvFirstHome.owe();
      await tester.pumpWidget(_home(
          child: PvArriveCount(text: 'Week 14', builder: (s) => Text(s))));
      expect(find.text('Week 0'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('Week 14'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    test('the sections are timed, the spacers pass through', () {
      const gap = SizedBox(height: 26);
      final out = pvArriveEach(const [gap, Text('a'), gap, Text('b')]);
      expect(out[0], same(gap));
      expect((out[1] as PvArrive).delay, PvArriveAt.sections);
      expect((out[3] as PvArrive).delay, PvArriveAt.sections + PvArriveAt.step);
    });
  });

  group('getting ready: her month leads until it comes', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      TtcStore.instance.resetForTest();
      await TtcReadyPlanStore.instance.load();
    });

    test('a month ahead is getting ready; this month is not', () async {
      final now = DateTime.now();
      final ahead = DateTime(now.year, now.month + 4);
      await TtcReadyPlanStore.instance.setPlannedStart(ahead);
      expect(TtcReadyPlanStore.instance.gettingReadyFor(), ahead);
      // "We've started trying" sets this month: the ordinary home returns.
      await TtcReadyPlanStore.instance.setPlannedStart(readyMonthOf(now));
      expect(TtcReadyPlanStore.instance.gettingReadyFor(), isNull);
    });

    test('the small line counts months, never days', () {
      final now = DateTime(2026, 10, 18);
      expect(ttcGettingReadyLine(DateTime(2027, 2), now: now),
          '4 months to go  ·  Ready-to-Try plan');
      expect(ttcGettingReadyLine(DateTime(2026, 11), now: now),
          'Next month  ·  Ready-to-Try plan');
    });

    test('"Getting ready" is the first door; a clinic still leads', () {
      const ids = ['other', kTtcDoorFertileWindow, kTtcDoorGettingReady, kTtcDoorIvf];
      expect(
          ttcHomeDoorOrder(ids,
                  clinicPathway: false,
                  tryingLong: false,
                  phase: TtcDayPhase.beforeWindow,
                  gettingReady: true)
              .first,
          kTtcDoorGettingReady);
      expect(
          ttcHomeDoorOrder(ids,
                  clinicPathway: true,
                  tryingLong: false,
                  phase: TtcDayPhase.beforeWindow,
                  gettingReady: true)
              .first,
          kTtcDoorIvf);
    });

    test('the hero and the rail read it; no fertile words before her month',
        () {
      final home = _src('lib/screens/ttc/ttc_home_v3.dart');
      expect(home, contains('TtcReadyPlanStore.instance.gettingReadyFor()'));
      expect(home, contains("'Your month to start'"));
      // The chance card waits for her month.
      expect(home, contains("readyFor == null || c.id != 'chance'"));
      // The way out, announced, with an Undo.
      expect(home, contains('_StartedTryingCard'));
      expect(home, contains("action: 'Undo'"));
    });
  });

  group('the intro film is a card for her first week', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await TtcIntroGate.resetForTest();
    });

    test('offered for a week, gone once opened', () async {
      expect(TtcIntroGate.cardShowing(), isFalse);
      await TtcIntroGate.offerCard();
      expect(TtcIntroGate.cardShowing(), isTrue);
      expect(
          TtcIntroGate.cardShowing(
              now: DateTime.now().add(const Duration(days: 8))),
          isFalse);
      await TtcIntroGate.loadCard();
      expect(TtcIntroGate.cardShowing(), isTrue);
      await TtcIntroGate.cardOpened();
      expect(TtcIntroGate.cardShowing(), isFalse);
    });
  });

  group('wiring gate', () {
    test('onboarding owes the welcome and clears the film gate', () {
      final flow = _src('lib/screens/auth/onboarding/onboarding_flow.dart');
      expect(flow, contains('PvFirstHome.owe();'));
      expect(flow, contains('await TtcIntroGate.markSeen();'));
      expect(flow, contains('await TtcIntroGate.offerCard();'));
    });

    test('all four homes welcome her', () {
      for (final f in [
        'lib/screens/ttc/ttc_home_v3.dart',
        'lib/screens/home_v3_screen.dart',
        'lib/screens/post_pregnancy/pp_home_v3.dart',
        'lib/screens/skilling/skilling_preview_screen.dart',
      ]) {
        final s = _src(f);
        expect(s, contains('PvHomeArrival('), reason: f);
        expect(s, contains('PvArrive.field('), reason: f);
        if (!f.endsWith('home_v3_screen.dart')) {
          expect(s, contains('pvArriveEach(children)'), reason: f);
        }
      }
      // Pregnancy's sheet lives with its hero.
      expect(_src('lib/screens/v2/v3_preg_hero.dart'),
          contains('pvArriveEach(children)'));
    });

    test('no daily tip over the first home', () {
      expect(_src('lib/screens/v2/v3_daily_tip.dart'),
          contains('if (PvFirstHome.thisLaunch) return;'));
    });

    test('the film card opens the film; his home carries his code', () {
      final home = _src('lib/screens/ttc/ttc_home_v3.dart');
      expect(home, contains('case TtcInsightGo.introFilm:'));
      expect(home, contains('TtcIntroGate.cardShowing()'));
      expect(home, contains('TtcHisLinkCard(p: p)'));
    });
  });
}
