// =============================================================================
//  The "all phases" screen — PhaseMapScreen, redesigned 2026-10-15
// -----------------------------------------------------------------------------
//  The user: the list was "very bland … random stuff listed, not intuitive".
//  What fails silently here: a phase falling out of its chapter, the screen
//  opening on text instead of the child's own phase, a missing painting
//  breaking the page, and a narrow phone or a tablet overflowing.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/phase_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/phase_map_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart';

void _ageMonths(int months) => ChildProfileStore.instance.debugSetDob(
    DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));

Future<void> _pump(WidgetTester t, double width) async {
  t.view.physicalSize = Size(width, 2400);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(const MaterialApp(home: PhaseMapScreen()));
  await t.pump();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('chapters', () {
    test('every phase lands in exactly one of five chapters, in order', () {
      final chapters = [for (final p in kPhases) phaseChapterOf(p)];
      expect(chapters.toSet(), {0, 1, 2, 3, 4});
      for (var i = 1; i < chapters.length; i++) {
        expect(chapters[i], greaterThanOrEqualTo(chapters[i - 1]), reason: 'phase ${i + 1} went back a chapter');
      }
      expect(phaseChapterOf(kPhases.first), 0);
      expect(phaseChapterOf(kPhases.last), 4);
    });

    test('a painting path per phase', () {
      expect(phasePaintingPath(1), 'assets/phases/phase_01.webp');
      expect(phasePaintingPath(20), 'assets/phases/phase_20.webp');
    });
  });

  group('the screen', () {
    testWidgets('opens on the child\'s own phase, then five chapters of stops', (t) async {
      _ageMonths(8);
      await _pump(t, 390);
      final now = kPhases[phaseIndexForMonths(ChildProfileStore.instance.ageInMonths.toDouble())];
      expect(find.textContaining('PHASE ${now.number} ·'), findsOneWidget);
      expect(find.text('Open this phase'), findsOneWidget);
      for (final c in kPhaseChapters) {
        expect(find.text(c.name), findsWidgets, reason: '${c.name} chapter missing');
      }
      for (final p in kPhases) {
        expect(find.byKey(ValueKey('phase-stop-${p.number}')), findsOneWidget);
      }
    });

    // Kept for revert: written before any painting existed (2026-10-15).
    // testWidgets('no painting yet: the number disc stands in, nothing breaks', (t) async {
    //   _ageMonths(2);
    //   await _pump(t, 390);
    //   await t.pumpAndSettle();
    //   expect(find.byKey(const ValueKey('phase-fallback-1')), findsWidgets);
    //   expect(t.takeException(), isNull);
    // });

    test('every phase has its painting on disk (2026-10-17)', () {
      for (var n = 1; n <= 20; n++) {
        expect(File(phasePaintingPath(n)).existsSync(), isTrue,
            reason: 'missing ${phasePaintingPath(n)}');
      }
    });

    testWidgets('a stop opens its phase', (t) async {
      _ageMonths(2);
      await _pump(t, 390);
      await t.ensureVisible(find.byKey(const ValueKey('phase-stop-5')));
      await t.tap(find.byKey(const ValueKey('phase-stop-5')));
      await t.pumpAndSettle();
      expect(find.byType(PhaseDetailScreen), findsOneWidget);
    });

    testWidgets('Open this phase opens the current one', (t) async {
      _ageMonths(14);
      await _pump(t, 390);
      await t.tap(find.text('Open this phase'));
      await t.pumpAndSettle();
      expect(find.byType(PhaseDetailScreen), findsOneWidget);
    });

    for (final w in [320.0, 390.0, 800.0]) {
      testWidgets('lays out at $w wide without overflow', (t) async {
        _ageMonths(30);
        await _pump(t, w);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      });
    }
  });
}
