// =============================================================================
//  Sudoku — generator, solver, validator. Pure Dart, no widget.
// -----------------------------------------------------------------------------
//  Built for the Garbh Sanskar pillars brief (Buddhi), 12 Sep 2026: *"9x9
//  with an easy default and a gentle 6x6 option. Include a generator,
//  validator, pencil notes, check and a hint."* Before this, Sudoku was a 4×4
//  with three hand-typed boards.
//
//  ⚠️ CUSTOM, NOT A PACKAGE. The brief allows either. A generator with a
//  uniqueness check is ~120 lines and every line of it is testable without a
//  device; a package would be a dependency for the same 120 lines, with its
//  own idea of difficulty and no 6×6. Written here, held by
//  `test/garbh_games_engine_test.dart`.
//
//  ⚠️ EVERY PUZZLE HAS EXACTLY ONE SOLUTION. Cells are removed from a full
//  grid one at a time and each removal is kept only if the solver still finds
//  a single solution. That is what makes "Hint" honest — it reveals THE
//  answer for that cell, not an answer — and what lets "Check" say a cell is
//  wrong rather than merely inconsistent.
//
//  ⚠️ "ANY CORRECT FILL WINS" is still the completion rule the screen uses:
//  it checks for a full board with no conflicts, not equality with the stored
//  solution. With a unique solution the two agree; the rule is kept because
//  it is the honest one if uniqueness is ever relaxed.
//
//  Sizes: 9 (boxes 3×3) and 6 (boxes 2 rows × 3 columns). Cells are stored
//  row-major, 0 for empty.
// =============================================================================

import 'dart:math';

class SudokuPuzzle {
  const SudokuPuzzle({
    required this.size,
    required this.givens,
    required this.solution,
  });

  /// 9 or 6.
  final int size;

  /// The starting board: 0 where she fills.
  final List<int> givens;

  /// The one solution.
  final List<int> solution;

  int get boxRows => size == 9 ? 3 : 2;
  int get boxCols => 3;
  int get cells => size * size;
  int get givenCount => givens.where((v) => v != 0).length;
}

class SudokuEngine {
  SudokuEngine([Random? rng]) : _rng = rng ?? Random();
  final Random _rng;

  /// A puzzle of [size] with about [givens] filled cells. "Easy" for 9×9 is
  /// the default; 6×6 is gentle by construction.
  SudokuPuzzle generate({int size = 9, int? givens}) {
    assert(size == 9 || size == 6);
    final target = givens ?? (size == 9 ? 40 : 16);
    final full = _fullGrid(size);
    final board = List<int>.of(full);
    final order = List<int>.generate(size * size, (i) => i)..shuffle(_rng);
    var filled = size * size;
    for (final i in order) {
      if (filled <= target) break;
      final keep = board[i];
      board[i] = 0;
      if (countSolutions(board, size, limit: 2) == 1) {
        filled--;
      } else {
        board[i] = keep;
      }
    }
    return SudokuPuzzle(size: size, givens: board, solution: full);
  }

  List<int> _fullGrid(int size) {
    final g = List<int>.filled(size * size, 0);
    final ok = _fill(g, size, 0);
    assert(ok);
    return g;
  }

  bool _fill(List<int> g, int size, int i) {
    if (i == size * size) return true;
    if (g[i] != 0) return _fill(g, size, i + 1);
    final vals = List<int>.generate(size, (k) => k + 1)..shuffle(_rng);
    for (final v in vals) {
      if (_fits(g, size, i, v)) {
        g[i] = v;
        if (_fill(g, size, i + 1)) return true;
        g[i] = 0;
      }
    }
    return false;
  }

  static bool _fits(List<int> g, int size, int i, int v) {
    final r = i ~/ size, c = i % size;
    for (var k = 0; k < size; k++) {
      if (g[r * size + k] == v) return false;
      if (g[k * size + c] == v) return false;
    }
    final br = size == 9 ? 3 : 2, bc = 3;
    final r0 = (r ~/ br) * br, c0 = (c ~/ bc) * bc;
    for (var rr = r0; rr < r0 + br; rr++) {
      for (var cc = c0; cc < c0 + bc; cc++) {
        if (g[rr * size + cc] == v) return false;
      }
    }
    return true;
  }

  /// How many solutions [board] has, stopping at [limit].
  static int countSolutions(List<int> board, int size, {int limit = 2}) {
    final g = List<int>.of(board);
    var count = 0;
    bool step(int i) {
      while (i < size * size && g[i] != 0) {
        i++;
      }
      if (i == size * size) {
        count++;
        return count >= limit;
      }
      for (var v = 1; v <= size; v++) {
        if (_fits(g, size, i, v)) {
          g[i] = v;
          if (step(i + 1)) return true;
          g[i] = 0;
        }
      }
      return false;
    }

    step(0);
    return count;
  }

  /// The cells that clash with another cell in their row, column or box.
  static Set<int> conflicts(List<int> board, int size) {
    final out = <int>{};
    final br = size == 9 ? 3 : 2, bc = 3;
    for (var i = 0; i < board.length; i++) {
      final v = board[i];
      if (v == 0) continue;
      final r = i ~/ size, c = i % size;
      for (var k = 0; k < size; k++) {
        final ri = r * size + k, ci = k * size + c;
        if (ri != i && board[ri] == v) out..add(i)..add(ri);
        if (ci != i && board[ci] == v) out..add(i)..add(ci);
      }
      final r0 = (r ~/ br) * br, c0 = (c ~/ bc) * bc;
      for (var rr = r0; rr < r0 + br; rr++) {
        for (var cc = c0; cc < c0 + bc; cc++) {
          final j = rr * size + cc;
          if (j != i && board[j] == v) out..add(i)..add(j);
        }
      }
    }
    return out;
  }

  /// Full and conflict-free: the completion rule.
  static bool isComplete(List<int> board, int size) =>
      !board.contains(0) && conflicts(board, size).isEmpty;

  /// The numbers that could go in [i] given the board — the pencil-note
  /// helper and the basis of "check".
  static Set<int> candidates(List<int> board, int size, int i) => {
        for (var v = 1; v <= size; v++)
          if (_fits(board, size, i, v)) v,
      };
}
