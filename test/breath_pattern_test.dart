// =============================================================================
//  One breathing circle — the pattern engine and the three conversions
// -----------------------------------------------------------------------------
//  The Garbh pillars brief: "build it once and reuse it everywhere breath
//  appears." Three areas convert their own phase models to `BreathPattern`;
//  these hold that each conversion says the same thing the area's screen used
//  to, and that the circle draws the word and the count from the clock alone.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/garbh_data.dart';
import 'package:parentveda/data/mind_mood_data.dart';
import 'package:parentveda/models/breath_pattern.dart';
import 'package:parentveda/models/garbh_content.dart';
import 'package:parentveda/ttc/ttc_practice_data.dart';
import 'package:parentveda/widgets/breathing_circle.dart';

void main() {
  const box = BreathPattern([
    BreathStep('Breathe in', 4, BreathKind.expand),
    BreathStep('Hold', 4, BreathKind.hold),
    BreathStep('Breathe out', 4, BreathKind.contract),
    BreathStep('Rest', 4, BreathKind.holdEmpty),
  ]);

  group('the engine', () {
    test('a cycle is the sum of its steps and wraps', () {
      expect(box.cycleSeconds, 16);
      expect(box.at(0).index, 0);
      expect(box.at(3.9).index, 0);
      expect(box.at(4).index, 1);
      expect(box.at(15.9).index, 3);
      expect(box.at(16).index, 0);
      expect(box.at(16).cycle, 2);
      expect(box.at(0).cycle, 1);
    });

    test('the count counts up, one-based, the way a breath is counted', () {
      expect(box.at(0).count, 1);
      expect(box.at(0.9).count, 1);
      expect(box.at(1).count, 2);
      expect(box.at(3.99).count, 4);
      expect(box.at(4).count, 1); // the next step starts again
    });

    test('the shape grows on expand, holds large, shrinks, rests small', () {
      expect(BreathPattern.scaleAt(box.steps[0], 0), 0);
      expect(BreathPattern.scaleAt(box.steps[0], 1), 1);
      expect(BreathPattern.scaleAt(box.steps[0], 0.5), closeTo(0.5, 0.01));
      expect(BreathPattern.scaleAt(box.steps[1], 0.3), 1);
      expect(BreathPattern.scaleAt(box.steps[2], 0), 1);
      expect(BreathPattern.scaleAt(box.steps[2], 1), 0);
      expect(BreathPattern.scaleAt(box.steps[3], 0.7), 0);
    });

    test('a negative elapsed is the start', () {
      expect(box.at(-3).index, 0);
      expect(box.at(-3).count, 1);
    });
  });

  group('the three conversions', () {
    test('Garbh: kinds are read off the scale sequence', () {
      final p = kriyaById('box')!.toBreathPattern();
      expect(p.steps.map((s) => s.kind), [
        BreathKind.expand,
        BreathKind.hold,
        BreathKind.contract,
        BreathKind.holdEmpty,
      ]);
      expect(p.steps.map((s) => s.seconds), [4, 4, 4, 4]);
      final calm = kriyaById('calm')!.toBreathPattern();
      expect(calm.steps.first.kind, BreathKind.expand);
      expect(calm.steps.last.kind, BreathKind.contract);
      // Every practice converts, and every label is a word on screen.
      for (final k in kKriya) {
        final bp = k.toBreathPattern();
        expect(bp.cycleSeconds, greaterThan(0));
        for (final s in bp.steps) {
          expect(s.label.trim(), isNotEmpty);
        }
      }
    });

    test('Mind & mood: a hold after the in-breath stays large', () {
      for (final ex in kMmBreathingExercises) {
        final bp = ex.toBreathPattern();
        expect(bp.steps.length, ex.phases.length);
        var large = false;
        for (var i = 0; i < ex.phases.length; i++) {
          final ph = ex.phases[i];
          final st = bp.steps[i];
          expect(st.seconds, ph.seconds);
          switch (ph.action) {
            case MmBreathAction.expand:
              expect(st.kind, BreathKind.expand);
              large = true;
            case MmBreathAction.contract:
              expect(st.kind, BreathKind.contract);
              large = false;
            case MmBreathAction.hold:
              expect(st.kind,
                  large ? BreathKind.hold : BreathKind.holdEmpty);
          }
        }
      }
    });

    test('TTC: zero holds are omitted, not zero-length steps', () {
      const plain = TtcBreathAnim(inhale: 4, exhale: 6, seconds: 60);
      expect(plain.toBreathPattern().steps.length, 2);
      const square = TtcBreathAnim(
          inhale: 4, hold: 4, exhale: 4, holdEmpty: 4, seconds: 60,
          square: true);
      final bp = square.toBreathPattern();
      expect(bp.steps.length, 4);
      expect(bp.cycleSeconds, square.cycle);
      expect(bp.steps.map((s) => s.label),
          ['Breathe in', 'Hold', 'Breathe out', 'Hold empty']);
    });
  });

  group('the circle', () {
    testWidgets('draws the word and the count for the moment it is given',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: PvBreathingCircle(
              pattern: box,
              elapsed: 5.5, // 1.5 s into "Hold"
              tint: Colors.teal,
              ink: Colors.black,
            ),
          ),
        ),
      ));
      expect(find.text('Hold'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('before it starts it rests and says Ready', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PvBreathingCircle(
            pattern: box,
            elapsed: 0,
            running: false,
            tint: Colors.teal,
            ink: Colors.black,
          ),
        ),
      ));
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Breathe in'), findsNothing);
    });

    testWidgets('the ticker drives it, and resets when running turns on again',
        (tester) async {
      var running = true;
      late StateSetter set;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(builder: (context, setState) {
            set = setState;
            return PvBreathTicker(
              running: running,
              builder: (context, t) => PvBreathingCircle(
                pattern: box,
                elapsed: t,
                tint: Colors.teal,
                ink: Colors.black,
              ),
            );
          }),
        ),
      ));
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Hold'), findsOneWidget);
      set(() => running = false);
      await tester.pump();
      set(() => running = true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Breathe in'), findsOneWidget);
    });
  });
}
