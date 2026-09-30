// =============================================================================
//  Buddhi's four games — the engines, and the promises the brief made
// -----------------------------------------------------------------------------
//  "All are for HER, no score pressure, each skippable, and NONE saves to My
//  Journal." The engines are pure Dart and tested as such; the screens are
//  pumped at 360dp and driven far enough to finish.
// =============================================================================

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/tools/games/nonogram_engine.dart';
import 'package:parentveda/screens/tools/games/sudoku_engine.dart';
import 'package:parentveda/screens/tools/garbh_games.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('sudoku engine', () {
    test('a 9×9 has one solution, about forty givens, and a valid answer', () {
      final p = SudokuEngine(Random(7)).generate();
      expect(p.size, 9);
      expect(p.givenCount, inInclusiveRange(38, 48));
      expect(SudokuEngine.countSolutions(p.givens, 9, limit: 2), 1);
      expect(SudokuEngine.isComplete(p.solution, 9), isTrue);
      for (var i = 0; i < 81; i++) {
        if (p.givens[i] != 0) expect(p.givens[i], p.solution[i]);
      }
    });

    test('a 6×6 is gentler: fewer cells, 2×3 boxes, still unique', () {
      final p = SudokuEngine(Random(3)).generate(size: 6);
      expect(p.size, 6);
      expect(p.boxRows, 2);
      expect(p.givenCount, inInclusiveRange(14, 22));
      expect(SudokuEngine.countSolutions(p.givens, 6, limit: 2), 1);
      expect(SudokuEngine.isComplete(p.solution, 6), isTrue);
    });

    test('conflicts name both cells of a clash, in row, column and box', () {
      final b = List<int>.filled(36, 0);
      b[0] = 4;
      b[5] = 4; // same row
      expect(SudokuEngine.conflicts(b, 6), {0, 5});
      b[5] = 0;
      b[30] = 4; // same column
      expect(SudokuEngine.conflicts(b, 6), {0, 30});
      b[30] = 0;
      b[8] = 4; // same 2×3 box (row 1, col 2)
      expect(SudokuEngine.conflicts(b, 6), {0, 8});
    });

    test('candidates are what fits', () {
      final p = SudokuEngine(Random(11)).generate(size: 6);
      final empty = p.givens.indexOf(0);
      final c = SudokuEngine.candidates(p.givens, 6, empty);
      expect(c, contains(p.solution[empty]));
    });

    test('different seeds, different puzzles', () {
      final a = SudokuEngine(Random(1)).generate(size: 6);
      final b = SudokuEngine(Random(2)).generate(size: 6);
      expect(a.solution, isNot(equals(b.solution)));
    });
  });

  group('nonogram engine', () {
    test('clues are run lengths; an empty line is [0]', () {
      expect(NonogramPuzzle.cluesOf([true, false, true, true, false, true]),
          [1, 2, 1]);
      expect(NonogramPuzzle.cluesOf([false, false]), [0]);
      expect(NonogramPuzzle.cluesOf([true, true, true]), [3]);
    });

    test('every picture is square, small, and solved by itself', () {
      for (final pic in kNonogramPictures) {
        expect(pic.size, inInclusiveRange(5, 6), reason: pic.name);
        for (final row in pic.rows) {
          expect(row.length, pic.size, reason: pic.name);
        }
        final p = NonogramPuzzle(pic);
        final marks = [
          for (var i = 0; i < pic.size * pic.size; i++) p.solutionAt(i) ? 1 : 0
        ];
        expect(p.isSolved(marks), isTrue, reason: pic.name);
        expect(p.isSolved(List.filled(marks.length, 0)), isFalse,
            reason: pic.name);
      }
    });

    test('a hint clears a wrong cell first, then fills a missing one', () {
      final p = NonogramPuzzle(kNonogramPictures.first);
      final marks = List<int>.filled(25, 0);
      final wrong = [for (var i = 0; i < 25; i++) if (!p.solutionAt(i)) i].first;
      marks[wrong] = 1;
      expect(p.hint(marks, Random(1)), wrong);
      marks[wrong] = 0;
      final h = p.hint(marks, Random(1))!;
      expect(p.solutionAt(h), isTrue);
      // Hints alone solve it.
      var guard = 0;
      while (!p.isSolved(marks) && guard++ < 50) {
        final i = p.hint(marks, Random(guard))!;
        marks[i] = p.solutionAt(i) ? 1 : 0;
      }
      expect(p.isSolved(marks), isTrue);
    });

    test('crosses do not count towards the picture', () {
      final p = NonogramPuzzle(kNonogramPictures.first);
      final marks = [
        for (var i = 0; i < 25; i++) p.solutionAt(i) ? 1 : 2
      ];
      expect(p.isSolved(marks), isTrue);
    });
  });

  group('word search', () {
    test('every word is placed, across, down or diagonally', () {
      final rng = Random(5);
      for (var round = 0; round < 10; round++) {
        final pool = [...kWordSearchPool]..shuffle(rng);
        final words = pool.take(7).toList();
        final g = generateWordSearch(words, 10, rng);
        for (final w in words) {
          expect(_contains(g, w), isTrue, reason: '$w not in grid');
        }
      }
    });

    test('the pool fits the grid and is calm', () {
      for (final w in kWordSearchPool) {
        expect(w.length, lessThanOrEqualTo(10));
        expect(w, matches(RegExp(r'^[A-Z]+$')));
      }
      expect(kWordSearchPool.toSet().length, kWordSearchPool.length);
    });
  });

  test('no game feeds My Journal', () {
    for (final f in [
      'lib/screens/tools/garbh_games.dart',
      'lib/screens/tools/garbh_sudoku.dart',
      'lib/screens/tools/garbh_nonogram.dart',
      'lib/screens/tools/games/game_chrome.dart',
    ]) {
      final src = File(f).readAsStringSync();
      expect(src, isNot(contains('GarbhJournalStore')), reason: f);
      expect(src, isNot(contains('garbh_rebuild_data')), reason: f);
    }
  });

  group('the screens, at 360dp', () {
    Future<void> pump(WidgetTester tester, Widget w) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: w));
      await tester.pump();
    }

    testWidgets('Sudoku: 9×9 by default, 6×6 on a tap, hint fills a cell, '
        'nothing overflows', (tester) async {
      await pump(tester,
          SudokuGame(controller: PregnancyController(), markComplete: false));
      expect(find.text('9 × 9'), findsOneWidget);
      expect(find.text('Pencil'), findsNothing); // an icon key, no label
      expect(find.text('Check'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('6 × 6, gentler'));
      await tester.pump();
      expect(find.textContaining('Fill 1–6'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Hint after hint solves it, softly.
      for (var i = 0; i < 40; i++) {
        if (find.text('Play again').evaluate().isNotEmpty) break;
        await tester.tap(find.text('Hint'));
        await tester.pump();
      }
      expect(find.text('Play again'), findsOneWidget);
      expect(find.textContaining('mistake'), findsNothing);
    });

    // ⚠️ EVERY PICTURE, NOT THE ONE THE DICE PICK (2026-09-30). The test
    // below opens a random picture, and one of them overflowed its clue strip
    // by 0.75px, so the suite failed on some runs only. This draws each.
    testWidgets('Logic Puzzle: every picture draws its clues without spilling',
        (tester) async {
      for (var i = 0; i < kNonogramPictures.length; i++) {
        await pump(tester,
            LogicGame(key: ValueKey(i), controller: PregnancyController(), markComplete: false, startAt: i));
        expect(tester.takeException(), isNull, reason: 'picture $i');
      }
    });

    testWidgets('Logic Puzzle: a nonogram that hints to a finish',
        (tester) async {
      await pump(tester,
          LogicGame(controller: PregnancyController(), markComplete: false));
      expect(find.byIcon(Icons.lightbulb_outline_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
      for (var i = 0; i < 40; i++) {
        if (find.text('Play again').evaluate().isNotEmpty) break;
        await tester.tap(find.byIcon(Icons.lightbulb_outline_rounded));
        await tester.pump();
      }
      expect(find.text('Play again'), findsOneWidget);
    });

    testWidgets('Word Search and Memory Match build, no timer anywhere',
        (tester) async {
      await pump(
          tester,
          WordSearchGame(
              controller: PregnancyController(), markComplete: false));
      expect(find.textContaining('0 of 7'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await pump(
          tester,
          MemoryMatchGame(
              controller: PregnancyController(), markComplete: false));
      expect(find.textContaining('0 of 8 pairs'), findsOneWidget);
      expect(find.textContaining('0 moves'), findsOneWidget);
      expect(find.textContaining(':'), findsNothing); // no clock
      expect(tester.takeException(), isNull);
    });
  });
}

bool _contains(List<List<String>> g, String w) {
  final n = g.length;
  for (var r = 0; r < n; r++) {
    for (var c = 0; c < n; c++) {
      for (final (dr, dc) in [(0, 1), (1, 0), (1, 1), (0, -1), (-1, 0), (-1, -1), (1, -1), (-1, 1)]) {
        var ok = true;
        for (var k = 0; k < w.length; k++) {
          final rr = r + dr * k, cc = c + dc * k;
          if (rr < 0 || cc < 0 || rr >= n || cc >= n || g[rr][cc] != w[k]) {
            ok = false;
            break;
          }
        }
        if (ok) return true;
      }
    }
  }
  return false;
}
