// =============================================================================
//  Garbh Sanskar — Buddhi's four games: "a few quiet minutes that are yours"
// -----------------------------------------------------------------------------
//  Four gentle games, never competitive: no countdown, no score, no fail
//  state. Buddhi to final, from the Garbh Sanskar pillars brief, 12 Sep 2026:
//
//    · Word Search — 10×10, a themed pool of forty calm words, tap-drag or
//      tap-tap to select, a new grid every open. Here, custom.
//    · Sudoku — 9×9 easy, a gentle 6×6, pencil notes, check, hint. In
//      `garbh_sudoku.dart` on `games/sudoku_engine.dart`, custom.
//    · Logic Puzzle — a light nonogram, 5×5 and 6×6, hints. In
//      `garbh_nonogram.dart` on `games/nonogram_engine.dart`, custom.
//    · Memory Match — 8 pairs of line icons, moves counted quietly. Here.
//
//  ⚠️ NO PACKAGE FOR ANY OF THEM. The brief allows packages "where they exist
//  and fit". A Sudoku generator with a uniqueness check is ~120 lines of pure
//  Dart and tested; a nonogram is smaller. A dependency for either would buy
//  its author's idea of difficulty and lose the 6×6. Custom, stated.
//
//  ⚠️ NONE OF THESE FEEDS MY JOURNAL. `test/garbh_games_engine_test.dart`
//  greps these four files for the journal store's name. Finishing one may
//  mark the pillar done for today (`markComplete`), and that is all it
//  records.
//
//  ⚠️ THE OLD 4×4 SUDOKU AND THE FOUR-QUESTION LOGIC QUIZ are at the foot of
//  this file, commented, kept for revert. Their class names live on in the
//  new files so `gameForPuzzle` did not change.
//
//  ⚠️ THE CHROME IS SHARED — `games/game_chrome.dart` — and it is on V3's
//  neutrals with Buddhi's accent now; see that file's header.
// =============================================================================

import 'dart:math';

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/garbh_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import 'games/game_chrome.dart';

export 'garbh_nonogram.dart' show LogicGame;
export 'garbh_sudoku.dart' show SudokuGame;

// ===========================================================================
//  1 · WORD SEARCH
// ===========================================================================

/// Forty calm words, none longer than the grid. Nature, rest, small good
/// things — nothing to do with pregnancy, because these minutes are hers.
const List<String> kWordSearchPool = [
  'CALM', 'PEACE', 'LOVE', 'REST', 'GENTLE', 'BLOOM', 'BREATHE', 'KIND',
  'QUIET', 'RIVER', 'MOON', 'CLOUD', 'GARDEN', 'PETAL', 'WARM', 'SOFT',
  'STILL', 'LIGHT', 'OCEAN', 'LEAF', 'RAIN', 'SUNRISE', 'MEADOW', 'HONEY',
  'LOTUS', 'BREEZE', 'PEBBLE', 'NEST', 'FEATHER', 'WILLOW', 'TULSI',
  'JASMINE', 'MANGO', 'MONSOON', 'DAWN', 'DUSK', 'SMILE', 'CRADLE', 'SHADE',
  'LULLABY',
];

class WordSearchGame extends StatefulWidget {
  const WordSearchGame(
      {super.key, required this.controller, this.markComplete = true});
  final PregnancyController controller;

  /// When false (opened from a library or the door), finishing does NOT mark
  /// the pillar done for today — it is just play.
  final bool markComplete;

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  static const int _n = 10;
  static const int _count = 7;
  final Random _rng = Random();
  late List<List<String>> _grid;
  late List<String> _words;
  final Set<String> _found = {};
  final Set<int> _foundCells = {};

  /// Tap-tap: the first end. Drag: the anchor.
  int? _first;

  /// The cells under a drag in progress, for the highlight.
  List<int> _drag = const [];
  bool _done = false;
  int _rot = 0;

  @override
  void initState() {
    super.initState();
    _newPuzzle();
  }

  // Re-place the CURRENT word set and clear progress (Reload).
  void _reload() {
    _grid = generateWordSearch(_words, _n, _rng);
    _found.clear();
    _foundCells.clear();
    _first = null;
    _drag = const [];
    setState(() => _done = false);
  }

  // A fresh RANDOM set (New puzzle) — and what every open starts with.
  void _newPuzzle() {
    final pool = [...kWordSearchPool]..shuffle(_rng);
    _words = pool.take(_count).toList();
    _reload();
  }

  // The NEXT set by rotating the pool (Next puzzle).
  void _next() {
    _rot = (_rot + _count) % kWordSearchPool.length;
    final rotated = [
      ...kWordSearchPool.sublist(_rot),
      ...kWordSearchPool.sublist(0, _rot)
    ];
    _words = rotated.take(_count).toList();
    _reload();
  }

  /// The cells on a straight line from [a] to [b] — row, column or diagonal
  /// — or null when they are not in line.
  List<int>? _lineCells(int a, int b) {
    final r1 = a ~/ _n, c1 = a % _n, r2 = b ~/ _n, c2 = b % _n;
    final dr = r2 - r1, dc = c2 - c1;
    if (dr != 0 && dc != 0 && dr.abs() != dc.abs()) return null;
    final steps = max(dr.abs(), dc.abs());
    final sr = dr.sign, sc = dc.sign;
    return [for (var k = 0; k <= steps; k++) (r1 + sr * k) * _n + (c1 + sc * k)];
  }

  void _try(List<int> cells) {
    final letters = cells.map((x) => _grid[x ~/ _n][x % _n]).join();
    final reversed = letters.split('').reversed.join();
    String? hit;
    for (final w in _words) {
      if (!_found.contains(w) && (w == letters || w == reversed)) {
        hit = w;
        break;
      }
    }
    if (hit != null) {
      _found.add(hit);
      _foundCells.addAll(cells);
    }
    if (_found.length == _words.length && !_done) {
      if (widget.markComplete) GarbhStore.instance.markDone('vichara');
      _done = true;
    }
  }

  void _tap(int i) {
    if (_first == null) {
      setState(() => _first = i);
      return;
    }
    if (_first == i) {
      setState(() => _first = null);
      return;
    }
    final cells = _lineCells(_first!, i);
    if (cells != null) _try(cells);
    setState(() => _first = null);
  }

  // ---- drag: anchor on down, highlight the line, evaluate on up ----------

  int? _cellAt(Offset local, double cell) {
    final c = (local.dx / cell).floor(), r = (local.dy / cell).floor();
    if (r < 0 || c < 0 || r >= _n || c >= _n) return null;
    return r * _n + c;
  }

  void _dragStart(int? i) {
    if (i == null) return;
    setState(() {
      _first = i;
      _drag = [i];
    });
  }

  void _dragUpdate(int? i) {
    final a = _first;
    if (a == null || i == null) return;
    final cells = _lineCells(a, i);
    if (cells != null) setState(() => _drag = cells);
  }

  void _dragEnd() {
    if (_drag.length > 1) _try(_drag);
    setState(() {
      _first = null;
      _drag = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    return GarbhGameChrome(
      title: S.now.uiWordSearch,
      controller: widget.controller,
      done: _done,
      onAgain: _newPuzzle,
      onReload: _reload,
      onNewPuzzle: _newPuzzle,
      onNext: _next,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          garbhHowCard('Drag across a hidden word, or tap its first and last '
              'letter. Across, down, or diagonal.'),
          Padding(
            padding: const EdgeInsets.all(18),
            child: AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(builder: (context, box) {
                final cell = box.maxWidth / _n;
                return GestureDetector(
                  onPanStart: (d) =>
                      _dragStart(_cellAt(d.localPosition, cell)),
                  onPanUpdate: (d) =>
                      _dragUpdate(_cellAt(d.localPosition, cell)),
                  onPanEnd: (_) => _dragEnd(),
                  onPanCancel: _dragEnd,
                  child: Column(children: [
                    for (var r = 0; r < _n; r++)
                      Expanded(
                        child: Row(children: [
                          for (var c = 0; c < _n; c++) _letter(r * _n + c),
                        ]),
                      ),
                  ]),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(s.gsWordsFound(_found.length, _words.length),
                style: pvManrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: kGameMuted)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final w in _words)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _found.contains(w)
                          ? kGameAccent.withValues(alpha: 0.14)
                          : kGameSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kGameLine),
                    ),
                    child: Text(
                      w,
                      style: pvManrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: _found.contains(w) ? kGameAccentDeep : kGameInk,
                        decoration: _found.contains(w)
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _letter(int i) {
    final found = _foundCells.contains(i);
    final live = _drag.contains(i) || _first == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tap(i),
        child: Container(
          margin: const EdgeInsets.all(1.5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: found
                ? kGameAccent.withValues(alpha: 0.85)
                : live
                    ? kGameAccent.withValues(alpha: 0.28)
                    : kGameSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kGameLine),
          ),
          child: Text(
            _grid[i ~/ _n][i % _n],
            style: pvManrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: found ? Colors.white : kGameInk),
          ),
        ),
      ),
    );
  }
}

/// Place each word across, down or diagonally at a non-conflicting spot, then
/// fill the rest with letters. Public so the test can prove every word is
/// findable in what it makes.
List<List<String>> generateWordSearch(List<String> words, int n, Random rng) {
  const az = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  for (var attempt = 0; attempt < 60; attempt++) {
    final g = List.generate(n, (_) => List.filled(n, ''));
    var ok = true;
    for (final w in words) {
      var placed = false;
      for (var t = 0; t < 300 && !placed; t++) {
        final len = w.length;
        if (len > n) {
          ok = false;
          break;
        }
        // 0 across, 1 down, 2 diagonal down-right.
        final dir = rng.nextInt(3);
        final dr = dir == 0 ? 0 : 1, dc = dir == 1 ? 0 : 1;
        final r = rng.nextInt(n - dr * (len - 1));
        final c = rng.nextInt(n - dc * (len - 1));
        var fits = true;
        for (var k = 0; k < len; k++) {
          final cur = g[r + dr * k][c + dc * k];
          if (cur != '' && cur != w[k]) {
            fits = false;
            break;
          }
        }
        if (!fits) continue;
        for (var k = 0; k < len; k++) {
          g[r + dr * k][c + dc * k] = w[k];
        }
        placed = true;
      }
      if (!placed) {
        ok = false;
        break;
      }
    }
    if (!ok) continue;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (g[r][c] == '') g[r][c] = az[rng.nextInt(26)];
      }
    }
    return g;
  }
  // Extremely unlikely fallback: a filled grid (words may be absent).
  return List.generate(n, (_) => List.generate(n, (_) => az[rng.nextInt(26)]));
}

// ===========================================================================
//  4 · MEMORY MATCH (4×4, 8 calm pairs, moves counted quietly)
// ===========================================================================

/// Eight line icons — the app's rule, no decorative emoji — each a small
/// calm thing.
const List<IconData> kMemoryFaces = [
  Icons.spa_outlined,
  Icons.nightlight_outlined,
  Icons.star_outline_rounded,
  Icons.eco_outlined,
  Icons.water_drop_outlined,
  Icons.cloud_outlined,
  Icons.favorite_border_rounded,
  Icons.wb_sunny_outlined,
];

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame(
      {super.key, required this.controller, this.markComplete = true});
  final PregnancyController controller;
  final bool markComplete;

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  final Random _rng = Random();
  late List<int> _cards; // index into kMemoryFaces
  final Set<int> _matched = {};
  int? _first;
  int? _second;
  bool _busy = false;
  bool _done = false;

  /// "Count moves quietly." A move is a pair turned over. Shown small,
  /// never compared to anything.
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _cards = [
      for (var i = 0; i < kMemoryFaces.length; i++) ...[i, i]
    ]..shuffle(_rng);
    _matched.clear();
    _first = null;
    _second = null;
    _busy = false;
    _moves = 0;
    setState(() => _done = false);
  }

  bool _faceUp(int i) =>
      _matched.contains(i) || _first == i || _second == i;

  void _tap(int i) {
    if (_busy || _matched.contains(i) || i == _first) return;
    if (_first == null) {
      setState(() => _first = i);
      return;
    }
    setState(() {
      _second = i;
      _moves++;
    });
    if (_cards[_first!] == _cards[i]) {
      setState(() {
        _matched.addAll([_first!, i]);
        _first = null;
        _second = null;
      });
      if (_matched.length == _cards.length && !_done) {
        if (widget.markComplete) GarbhStore.instance.markDone('vichara');
        setState(() => _done = true);
      }
    } else {
      _busy = true;
      Future.delayed(const Duration(milliseconds: 750), () {
        if (!mounted) return;
        setState(() {
          _first = null;
          _second = null;
          _busy = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    return GarbhGameChrome(
      title: S.now.uiMemoryMatch,
      controller: widget.controller,
      done: _done,
      onAgain: _reset,
      // One face set, so every control simply reshuffles the board.
      onReload: _reset,
      onNewPuzzle: _reset,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          garbhHowCard(s.gsMemoryHow),
          Padding(
            padding: const EdgeInsets.all(18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemCount: _cards.length,
              itemBuilder: (context, i) {
                final up = _faceUp(i);
                final matched = _matched.contains(i);
                return GestureDetector(
                  onTap: () => _tap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: matched
                          ? kGameAccent.withValues(alpha: 0.18)
                          : up
                              ? kGameSurface
                              : kGameAccent.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: matched ? kGameAccent : kGameLine,
                          width: matched ? 1.6 : 1),
                    ),
                    child: up
                        ? Icon(kMemoryFaces[_cards[i]],
                            size: 30,
                            color: matched ? kGameAccentDeep : kGameInk)
                        : null,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
                '${_matched.length ~/ 2} of ${kMemoryFaces.length} pairs · '
                '$_moves ${_moves == 1 ? 'move' : 'moves'}',
                style: pvManrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: kGameMuted)),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  Kept for revert: the 4×4 Sudoku with three boards, and the four-question
//  logic quiz that "Logic Puzzle" used to be. Buddhi to final, 2026-09-12.
//  They referenced the private chrome this file had (`_GameChrome`,
//  `_howCard`, the old palette), which is `games/game_chrome.dart` now.
// ===========================================================================
// // ===========================================================================
// //  2 · SUDOKU (gentle 4×4)
// // ===========================================================================
// class SudokuGame extends StatefulWidget {
//   const SudokuGame(
//       {super.key, required this.controller, this.markComplete = true});
//   final PregnancyController controller;
//   final bool markComplete;
//   @override
//   State<SudokuGame> createState() => _SudokuGameState();
// }
//
// class _SudokuGameState extends State<SudokuGame> {
//   // Each is 16 givens (0 = empty); all are subsets of a valid solution, so each
//   // is solvable. Validity (not equality) is checked, so any correct fill wins.
//   static const List<List<int>> _puzzles = [
//     [1, 0, 3, 0, 0, 4, 0, 2, 2, 0, 4, 0, 0, 3, 0, 1],
//     [3, 0, 1, 0, 0, 2, 0, 4, 4, 0, 2, 0, 0, 1, 0, 3],
//     [4, 0, 2, 0, 0, 1, 0, 3, 3, 0, 1, 0, 0, 2, 0, 4],
//   ];
//   final Random _rng = Random();
//
//   late List<int> _cells;
//   late List<bool> _given;
//   int? _sel;
//   bool _done = false;
//
//   int _pIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _load(_rng.nextInt(_puzzles.length));
//   }
//
//   void _load(int i) {
//     _pIndex = i % _puzzles.length;
//     final p = _puzzles[_pIndex];
//     _cells = [...p];
//     _given = [for (final v in p) v != 0];
//     _sel = null;
//     setState(() => _done = false);
//   }
//
//   void _reload() => _load(_pIndex); // restart current board
//   void _newPuzzle() => _load(_rng.nextInt(_puzzles.length)); // random board
//   void _next() => _load(_pIndex + 1); // next board in sequence
//
//   bool _conflict(int idx) {
//     final v = _cells[idx];
//     if (v == 0) return false;
//     final r = idx ~/ 4, c = idx % 4;
//     for (var k = 0; k < 4; k++) {
//       if (k != c && _cells[r * 4 + k] == v) return true; // row
//       if (k != r && _cells[k * 4 + c] == v) return true; // col
//     }
//     final br = (r ~/ 2) * 2, bc = (c ~/ 2) * 2; // 2×2 box
//     for (var dr = 0; dr < 2; dr++) {
//       for (var dc = 0; dc < 2; dc++) {
//         final j = (br + dr) * 4 + (bc + dc);
//         if (j != idx && _cells[j] == v) return true;
//       }
//     }
//     return false;
//   }
//
//   bool get _solved {
//     if (_cells.contains(0)) return false;
//     for (var i = 0; i < 16; i++) {
//       if (_conflict(i)) return false;
//     }
//     return true;
//   }
//
//   void _put(int v) {
//     if (_sel == null || _given[_sel!]) return;
//     setState(() => _cells[_sel!] = v);
//     if (_solved && !_done) {
//       if (widget.markComplete) GarbhStore.instance.markDone('vichara');
//       setState(() => _done = true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final s = S(widget.controller.language);
//     return _GameChrome(
//       title: S.now.uiSudoku,
//       controller: widget.controller,
//       done: _done,
//       onAgain: _newPuzzle,
//       onReload: _reload,
//       onNewPuzzle: _newPuzzle,
//       onNext: _next,
//       child: ListView(
//         padding: const EdgeInsets.only(bottom: 28),
//         children: [
//           _howCard(s.gsSudokuHow),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(28, 18, 28, 18),
//             child: AspectRatio(
//               aspectRatio: 1,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: _surface,
//                   border: Border.all(color: _accDeep, width: 2),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   children: [
//                     for (var r = 0; r < 4; r++)
//                       Expanded(
//                         child: Row(children: [
//                           for (var c = 0; c < 4; c++) _cell(r, c),
//                         ]),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // 1–4 pad + clear.
//           //
//           // ⚠️ FIVE 56dp KEYS PLUS PADDING OVERFLOWED BY 26px ON A 360dp
//           // PHONE (seen 2026-09-12). A scroll view lets the row keep its key
//           // size on a narrow screen and centres it on a wide one.
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 18),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 for (var v = 1; v <= 4; v++) _padBtn('$v', () => _put(v)),
//                 _padBtn('⌫', () => _put(0)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _cell(int r, int c) {
//     final i = r * 4 + c;
//     final v = _cells[i];
//     final given = _given[i];
//     final sel = _sel == i;
//     final bad = !given && _conflict(i);
//     return Expanded(
//       child: GestureDetector(
//         onTap: given ? null : () => setState(() => _sel = i),
//         child: Container(
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: sel ? _acc.withValues(alpha: 0.18) : Colors.transparent,
//             border: Border(
//               right: BorderSide(
//                   color: c == 1 ? _accDeep : _line, width: c == 1 ? 2 : 1),
//               bottom: BorderSide(
//                   color: r == 1 ? _accDeep : _line, width: r == 1 ? 2 : 1),
//             ),
//           ),
//           child: Text(
//             v == 0 ? '' : '$v',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: given ? FontWeight.w900 : FontWeight.w600,
//               color: bad ? _softRed : (given ? _ink : _accDeep),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _padBtn(String label, VoidCallback onTap) => Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 5),
//         child: GestureDetector(
//           onTap: onTap,
//           child: Container(
//             width: 56,
//             height: 56,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: _surface,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: _line),
//             ),
//             child: Text(label,
//                 style: const TextStyle(
//                     fontSize: 20, fontWeight: FontWeight.w800, color: _ink)),
//           ),
//         ),
//       );
// }
//
// // ===========================================================================
// //  3 · LOGIC (gentle one-screen brain-teasers)
// // ===========================================================================
// class _LogicQ {
//   const _LogicQ(this.prompt, this.options, this.answer);
//   final String prompt;
//   final List<String> options;
//   final int answer;
// }
//
// const List<_LogicQ> _kLogic = [
//   _LogicQ('What comes next?\n2 · 4 · 6 · 8 · __', ['9', '10', '11', '12'], 1),
//   _LogicQ('Which one is the odd one out?',
//       ['🍎 Apple', '🍌 Banana', '🥕 Carrot', '🍊 Orange'], 2),
//   _LogicQ('What comes next?\n🌙 ☀️ 🌙 ☀️ __', ['☀️', '🌙', '⭐', '☁️'], 1),
//   _LogicQ('Which is the biggest?',
//       ['🐜 Ant', '🐈 Cat', '🐘 Elephant', '🐭 Mouse'], 2),
//   _LogicQ('What comes next?\nA · B · C · D · __', ['F', 'E', 'G', 'Z'], 1),
// ];
//
// class LogicGame extends StatefulWidget {
//   const LogicGame(
//       {super.key, required this.controller, this.markComplete = true});
//   final PregnancyController controller;
//   final bool markComplete;
//   @override
//   State<LogicGame> createState() => _LogicGameState();
// }
//
// class _LogicGameState extends State<LogicGame> {
//   final Random _rng = Random();
//   int _i = 0;
//   bool _nudge = false;
//   bool _done = false;
//
//   // Reload: restart from the first question.
//   void _reload() {
//     _i = 0;
//     _nudge = false;
//     setState(() => _done = false);
//   }
//
//   // New puzzle: start from a random question.
//   void _newPuzzle() {
//     _i = _rng.nextInt(_kLogic.length);
//     _nudge = false;
//     setState(() => _done = false);
//   }
//
//   // Next puzzle: skip to the next question.
//   void _next() {
//     _i = (_i + 1) % _kLogic.length;
//     setState(() => _nudge = false);
//   }
//
//   void _choose(int opt) {
//     final q = _kLogic[_i];
//     if (opt == q.answer) {
//       if (_i == _kLogic.length - 1) {
//         if (widget.markComplete) GarbhStore.instance.markDone('vichara');
//         setState(() => _done = true);
//       } else {
//         setState(() {
//           _i++;
//           _nudge = false;
//         });
//       }
//     } else {
//       setState(() => _nudge = true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final s = S(widget.controller.language);
//     final q = _kLogic[_i];
//     return _GameChrome(
//       title: S.now.uiLogicPuzzle,
//       controller: widget.controller,
//       done: _done,
//       onAgain: _reload,
//       onReload: _reload,
//       onNewPuzzle: _newPuzzle,
//       onNext: _next,
//       child: ListView(
//         padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
//         children: [
//           _howCard(s.gsLogicHow),
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: Text(s.gsLogicProgress(_i + 1, _kLogic.length),
//                 style: const TextStyle(
//                     fontSize: 12, fontWeight: FontWeight.w800, color: _muted)),
//           ),
//           const SizedBox(height: 14),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
//             decoration: BoxDecoration(
//               color: _surface,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: _line),
//             ),
//             child: Text(q.prompt,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                     fontSize: 21,
//                     height: 1.4,
//                     fontWeight: FontWeight.w700,
//                     color: _ink)),
//           ),
//           const SizedBox(height: 18),
//           for (var o = 0; o < q.options.length; o++)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 10),
//               child: GestureDetector(
//                 onTap: () => _choose(o),
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 16, horizontal: 18),
//                   decoration: BoxDecoration(
//                     color: _surface,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: _line),
//                   ),
//                   child: Text(q.options[o],
//                       style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: _ink)),
//                 ),
//               ),
//             ),
//           if (_nudge)
//             Padding(
//               padding: const EdgeInsets.only(top: 6),
//               child: Center(
//                 child: Text(s.gsLogicNudge,
//                     style: const TextStyle(
//                         color: _softRed, fontWeight: FontWeight.w700)),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
