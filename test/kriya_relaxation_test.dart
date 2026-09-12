// =============================================================================
//  Guided Relaxation — the script's promises, and a session that runs
// -----------------------------------------------------------------------------
//  The pillars brief's two hard lines: make NO claim that any of this helps
//  the baby, and keep the safety block visible. And the one thing the door
//  owed (G11 in DOOR-CONTENT-OWED): a real eight-minute session, not a
//  breathing pattern named relax.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_garbh.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/kriya_relaxation_data.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/garbh_relaxation_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the script', () {
    const s = kKriyaRelaxation;

    test('is eight minutes, head to toe', () {
      expect(s.totalSeconds, 480);
      // The body steps run downwards; settling, whole-body and return sit
      // at the middle and are not part of the run.
      final body = s.steps.where((st) => st.part != 0.5).toList();
      expect(body.length, greaterThanOrEqualTo(8));
      for (var i = 1; i < body.length; i++) {
        expect(body[i].part, greaterThan(body[i - 1].part),
            reason: '${body[i].title} is above ${body[i - 1].title}');
      }
      expect(body.first.part, lessThan(0.1)); // the face
      expect(body.last.part, greaterThan(0.9)); // the feet
    });

    test('opens on the side or propped, never flat', () {
      final first = s.steps.first.script.toLowerCase();
      expect(first, contains('side'));
      expect(first, contains('not flat on your back'));
    });

    test('makes no claim about the baby', () {
      const forbidden = [
        'smarter',
        'cleverer',
        'intelligen',
        'iq',
        'brain',
        'healthier',
        'calmer baby',
        'good for the baby',
        'helps your baby',
        'develop',
      ];
      for (final st in s.steps) {
        final t = '${st.title} ${st.script}'.toLowerCase();
        for (final w in forbidden) {
          expect(t, isNot(contains(w)),
              reason: '"${st.title}" says "$w"');
        }
      }
      expect(s.intro.toLowerCase(), isNot(contains('baby')));
    });

    test("every step has a unique manifest key under the session's prefix",
        () {
      final keys = s.steps.map(s.narrationKeyFor).toList();
      expect(keys.toSet().length, keys.length);
      for (final k in keys) {
        expect(k, startsWith('kriya.relax.'));
      }
    });

    test('the belly step names the baby once, and promises nothing', () {
      final belly = s.steps.firstWhere((st) => st.id == 'belly');
      expect(belly.script, contains('Your baby is right here'));
      expect(belly.script, contains('Nothing here has to help anyone'));
    });
  });

  group('the wiring', () {
    test('the door opens the session, not the practice detail', () {
      final w = pvDoorScreenFor(kGarbhSurfaceRelax, PregnancyController());
      expect(w, isA<GarbhRelaxationScreen>());
    });

    test('Mind & mood links to it and does not rebuild it', () {
      final mind = pvDoorPageFor('pregnancy_mental_health')!;
      final links = mind.allTiles
          .whereType<PvDoorToolTile>()
          .where((t) => t.surfaceId == kGarbhSurfaceRelax);
      expect(links.length, 1);
      // And nothing on Mind & mood is its own relaxation.
      for (final t in mind.allTiles) {
        if (t is PvDoorToolTile && t.surfaceId == kGarbhSurfaceRelax) continue;
        expect(t.title.toLowerCase(), isNot(contains('relaxation')));
      }
    });
  });

  group('the session', () {
    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: GarbhRelaxationScreen(pregnancy: PregnancyController()),
      ));
      await tester.pump();
    }

    // The scaffold's scroll: Begin is below the flag, a screen down.
    Future<void> begin(WidgetTester tester) async {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
      await tester.pump();
      await tester.tap(find.text('Begin'));
      await tester.pump();
    }

    testWidgets('the intro shows the safety line, the flag whole, and Begin',
        (tester) async {
      await pump(tester);
      expect(find.text('Begin'), findsOneWidget);
      expect(find.text('Quiet'), findsOneWidget);
      expect(find.text('Morning Calm Raga'), findsOneWidget);
      expect(find.textContaining('Bleeding, or fluid leaking'), findsOneWidget);
      expect(find.textContaining('moving noticeably less'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Begin starts step one; time moves it down the body; it ends',
        (tester) async {
      await pump(tester);
      await begin(tester);
      expect(find.text('Settle in'), findsOneWidget);
      expect(find.text('1 of 13'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);

      // 45 s later: the face.
      await tester.pump(const Duration(seconds: 46));
      expect(find.text('Your face'), findsOneWidget);
      expect(find.text('2 of 13'), findsOneWidget);

      // The whole eight minutes, and it finishes on its own.
      await tester.pump(const Duration(seconds: 440));
      await tester.pump();
      expect(find.textContaining('That is the whole thing'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pause holds the clock; resume continues from there',
        (tester) async {
      await pump(tester);
      await begin(tester);
      await tester.pump(const Duration(seconds: 20));
      await tester.tap(find.text('Pause'));
      await tester.pump();
      expect(find.text('Resume'), findsOneWidget);
      // A minute paused changes nothing.
      await tester.pump(const Duration(seconds: 60));
      expect(find.text('Settle in'), findsOneWidget);
      await tester.tap(find.text('Resume'));
      await tester.pump();
      // 20 s in + 26 s = past the first step's 45.
      await tester.pump(const Duration(seconds: 26));
      expect(find.text('Your face'), findsOneWidget);
      // End returns to the intro.
      await tester.tap(find.text('End'));
      await tester.pump();
      expect(find.text('Begin'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
