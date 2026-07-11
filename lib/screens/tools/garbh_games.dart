// =============================================================================
//  Garbh Sanskar - Vichara "Brain Fitness" mini-games
// -----------------------------------------------------------------------------
//  Four gentle, calming games for "a few quiet minutes of focused calm" - never
//  competitive: no countdown timers, no scores, no harsh fail states. Completing
//  any one marks the Vichara pillar done for the day. Each game is self-contained
//  (hand-picked data; word grids placed at runtime so they're always solvable).
// =============================================================================

import 'dart:math';

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../services/garbh_store.dart';
import '../../services/pregnancy_controller.dart';

// Vichara palette (mirrors garbh_screen.dart's _accVichara + warm tokens).
const Color _acc = Color(0xFF6E8C74); // muted green
const Color _accDeep = Color(0xFF4F6B55);
const Color _ink = Color(0xFF4A463E);
const Color _muted = Color(0xFF8C857A);
const Color _line = Color(0xFFE9E0D2);
const Color _cream = Color(0xFFFBF6EE);
const Color _surface = Color(0xFFFFFFFF);
const Color _softRed = Color(0xFFC07A6A);

// ---------------------------------------------------------------------------
//  Shared chrome - warm Scaffold + the completion state
// ---------------------------------------------------------------------------
class _GameChrome extends StatelessWidget {
  const _GameChrome({
    required this.title,
    required this.controller,
    required this.done,
    required this.onAgain,
    required this.child,
    this.onReload,
    this.onNewPuzzle,
    this.onNext,
  });
  final String title;
  final PregnancyController controller;
  final bool done;
  final VoidCallback onAgain;
  final Widget child;

  /// In-game controls (shown as AppBar actions while playing):
  ///   onReload    - restart the CURRENT puzzle (clears progress, same board).
  ///   onNewPuzzle - generate a fresh RANDOM puzzle.
  ///   onNext      - advance to the NEXT puzzle in sequence.
  final VoidCallback? onReload;
  final VoidCallback? onNewPuzzle;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final hinglish = controller.language.isHinglish;
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        foregroundColor: _accDeep,
        elevation: 0,
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w800, color: _ink)),
        actions: done
            ? null
            : [
                if (onReload != null)
                  IconButton(
                    tooltip: hinglish ? 'Dobara shuru' : 'Reload',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: onReload,
                  ),
                if (onNewPuzzle != null)
                  IconButton(
                    tooltip: hinglish ? 'Naya puzzle' : 'New puzzle',
                    icon: const Icon(Icons.casino_outlined),
                    onPressed: onNewPuzzle,
                  ),
                if (onNext != null)
                  IconButton(
                    tooltip: hinglish ? 'Agla puzzle' : 'Next puzzle',
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: onNext,
                  ),
              ],
      ),
      body: SafeArea(
        child: done ? _completion(context, s) : child,
      ),
    );
  }

  Widget _completion(BuildContext context, S s) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🌿', style: TextStyle(fontSize: 58)),
            const SizedBox(height: 16),
            Text(s.gsGameDone,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: _acc,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                onPressed: onAgain,
                child: Text(s.gsPlayAgain,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.gsGameClose,
                  style: const TextStyle(
                      color: _muted, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );
}

Widget _howCard(String text) => Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _acc.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _acc.withValues(alpha: 0.20)),
      ),
      child: Row(children: [
        const Icon(Icons.spa_rounded, size: 18, color: _accDeep),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, color: _ink, height: 1.4))),
      ]),
    );

// ===========================================================================
//  1 · WORD SEARCH
// ===========================================================================
class WordSearchGame extends StatefulWidget {
  const WordSearchGame(
      {super.key, required this.controller, this.markComplete = true});
  final PregnancyController controller;

  /// When false (opened from the Tools library), finishing does NOT mark the
  /// Vichara ritual done for today - it's just play, not "today's Sanskar".
  final bool markComplete;
  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  static const int _n = 9;
  static const List<String> _wordPool = [
    'CALM', 'PEACE', 'LOVE', 'REST', 'GENTLE', 'BLOOM', 'BREATHE', 'KIND'
  ];
  final Random _rng = Random();

  late List<List<String>> _grid;
  late List<String> _words;
  final Set<String> _found = {};
  final Set<int> _foundCells = {};
  int? _first;
  bool _done = false;

  int _rot = 0; // rotation offset for deterministic "next puzzle"

  @override
  void initState() {
    super.initState();
    _newPuzzle();
  }

  // Re-place the CURRENT word set and clear progress (Reload).
  void _reload() {
    _grid = _generate(_words, _n, _rng);
    _found.clear();
    _foundCells.clear();
    _first = null;
    setState(() => _done = false);
  }

  // Fresh RANDOM set of six words (New puzzle). Max length 7 fits a 9-grid.
  void _newPuzzle() {
    final pool = [..._wordPool]..shuffle(_rng);
    _words = pool.take(6).toList();
    _reload();
  }

  // The NEXT set of six words by rotating the pool (Next puzzle).
  void _next() {
    _rot = (_rot + 1) % _wordPool.length;
    final rotated = [..._wordPool.sublist(_rot), ..._wordPool.sublist(0, _rot)];
    _words = rotated.take(6).toList();
    _reload();
  }

  // Place each word H/V at a non-conflicting spot, then fill with letters.
  List<List<String>> _generate(List<String> words, int n, Random rng) {
    const az = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (var attempt = 0; attempt < 60; attempt++) {
      final g = List.generate(n, (_) => List.filled(n, ''));
      var ok = true;
      for (final w in words) {
        var placed = false;
        for (var t = 0; t < 300 && !placed; t++) {
          final horizontal = rng.nextBool();
          final len = w.length;
          if (len > n) {
            ok = false;
            break;
          }
          final r = horizontal ? rng.nextInt(n) : rng.nextInt(n - len + 1);
          final c = horizontal ? rng.nextInt(n - len + 1) : rng.nextInt(n);
          var fits = true;
          for (var k = 0; k < len; k++) {
            final rr = horizontal ? r : r + k;
            final cc = horizontal ? c + k : c;
            final cur = g[rr][cc];
            if (cur != '' && cur != w[k]) {
              fits = false;
              break;
            }
          }
          if (!fits) continue;
          for (var k = 0; k < len; k++) {
            final rr = horizontal ? r : r + k;
            final cc = horizontal ? c + k : c;
            g[rr][cc] = w[k];
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
    return List.generate(
        n, (_) => List.generate(n, (_) => az[rng.nextInt(26)]));
  }

  List<int>? _lineCells(int a, int b) {
    final r1 = a ~/ _n, c1 = a % _n, r2 = b ~/ _n, c2 = b % _n;
    final cells = <int>[];
    if (r1 == r2) {
      final step = c2 >= c1 ? 1 : -1;
      for (var c = c1;; c += step) {
        cells.add(r1 * _n + c);
        if (c == c2) break;
      }
      return cells;
    }
    if (c1 == c2) {
      final step = r2 >= r1 ? 1 : -1;
      for (var r = r1;; r += step) {
        cells.add(r * _n + c1);
        if (r == r2) break;
      }
      return cells;
    }
    return null;
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
    if (cells != null) {
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
    }
    setState(() => _first = null);
    if (_found.length == _words.length && !_done) {
      if (widget.markComplete) GarbhStore.instance.markDone('vichara');
      setState(() => _done = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    return _GameChrome(
      title: 'Word Search',
      controller: widget.controller,
      done: _done,
      onAgain: _newPuzzle,
      onReload: _reload,
      onNewPuzzle: _newPuzzle,
      onNext: _next,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          _howCard(s.gsWordSearchHow),
          Padding(
            padding: const EdgeInsets.all(18),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _n, mainAxisSpacing: 3, crossAxisSpacing: 3),
                itemCount: _n * _n,
                itemBuilder: (context, i) {
                  final found = _foundCells.contains(i);
                  final selected = _first == i;
                  return GestureDetector(
                    onTap: () => _tap(i),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: found
                            ? _acc.withValues(alpha: 0.85)
                            : selected
                                ? _acc.withValues(alpha: 0.28)
                                : _surface,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: _line),
                      ),
                      child: Text(
                        _grid[i ~/ _n][i % _n],
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: found ? Colors.white : _ink),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(s.gsWordsFound(_found.length, _words.length),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: _muted)),
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
                          ? _acc.withValues(alpha: 0.14)
                          : _surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _line),
                    ),
                    child: Text(
                      w,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: _found.contains(w) ? _accDeep : _ink,
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
}

// ===========================================================================
//  2 · SUDOKU (gentle 4×4)
// ===========================================================================
class SudokuGame extends StatefulWidget {
  const SudokuGame(
      {super.key, required this.controller, this.markComplete = true});
  final PregnancyController controller;
  final bool markComplete;
  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  // Each is 16 givens (0 = empty); all are subsets of a valid solution, so each
  // is solvable. Validity (not equality) is checked, so any correct fill wins.
  static const List<List<int>> _puzzles = [
    [1, 0, 3, 0, 0, 4, 0, 2, 2, 0, 4, 0, 0, 3, 0, 1],
    [3, 0, 1, 0, 0, 2, 0, 4, 4, 0, 2, 0, 0, 1, 0, 3],
    [4, 0, 2, 0, 0, 1, 0, 3, 3, 0, 1, 0, 0, 2, 0, 4],
  ];
  final Random _rng = Random();

  late List<int> _cells;
  late List<bool> _given;
  int? _sel;
  bool _done = false;

  int _pIndex = 0;

  @override
  void initState() {
    super.initState();
    _load(_rng.nextInt(_puzzles.length));
  }

  void _load(int i) {
    _pIndex = i % _puzzles.length;
    final p = _puzzles[_pIndex];
    _cells = [...p];
    _given = [for (final v in p) v != 0];
    _sel = null;
    setState(() => _done = false);
  }

  void _reload() => _load(_pIndex); // restart current board
  void _newPuzzle() => _load(_rng.nextInt(_puzzles.length)); // random board
  void _next() => _load(_pIndex + 1); // next board in sequence

  bool _conflict(int idx) {
    final v = _cells[idx];
    if (v == 0) return false;
    final r = idx ~/ 4, c = idx % 4;
    for (var k = 0; k < 4; k++) {
      if (k != c && _cells[r * 4 + k] == v) return true; // row
      if (k != r && _cells[k * 4 + c] == v) return true; // col
    }
    final br = (r ~/ 2) * 2, bc = (c ~/ 2) * 2; // 2×2 box
    for (var dr = 0; dr < 2; dr++) {
      for (var dc = 0; dc < 2; dc++) {
        final j = (br + dr) * 4 + (bc + dc);
        if (j != idx && _cells[j] == v) return true;
      }
    }
    return false;
  }

  bool get _solved {
    if (_cells.contains(0)) return false;
    for (var i = 0; i < 16; i++) {
      if (_conflict(i)) return false;
    }
    return true;
  }

  void _put(int v) {
    if (_sel == null || _given[_sel!]) return;
    setState(() => _cells[_sel!] = v);
    if (_solved && !_done) {
      if (widget.markComplete) GarbhStore.instance.markDone('vichara');
      setState(() => _done = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    return _GameChrome(
      title: 'Sudoku',
      controller: widget.controller,
      done: _done,
      onAgain: _newPuzzle,
      onReload: _reload,
      onNewPuzzle: _newPuzzle,
      onNext: _next,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          _howCard(s.gsSudokuHow),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 18),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: _surface,
                  border: Border.all(color: _accDeep, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    for (var r = 0; r < 4; r++)
                      Expanded(
                        child: Row(children: [
                          for (var c = 0; c < 4; c++) _cell(r, c),
                        ]),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // 1–4 pad + clear.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var v = 1; v <= 4; v++) _padBtn('$v', () => _put(v)),
                _padBtn('⌫', () => _put(0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(int r, int c) {
    final i = r * 4 + c;
    final v = _cells[i];
    final given = _given[i];
    final sel = _sel == i;
    final bad = !given && _conflict(i);
    return Expanded(
      child: GestureDetector(
        onTap: given ? null : () => setState(() => _sel = i),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sel ? _acc.withValues(alpha: 0.18) : Colors.transparent,
            border: Border(
              right: BorderSide(
                  color: c == 1 ? _accDeep : _line, width: c == 1 ? 2 : 1),
              bottom: BorderSide(
                  color: r == 1 ? _accDeep : _line, width: r == 1 ? 2 : 1),
            ),
          ),
          child: Text(
            v == 0 ? '' : '$v',
            style: TextStyle(
              fontSize: 24,
              fontWeight: given ? FontWeight.w900 : FontWeight.w600,
              color: bad ? _softRed : (given ? _ink : _accDeep),
            ),
          ),
        ),
      ),
    );
  }

  Widget _padBtn(String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _line),
            ),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: _ink)),
          ),
        ),
      );
}

// ===========================================================================
//  3 · LOGIC (gentle one-screen brain-teasers)
// ===========================================================================
class _LogicQ {
  const _LogicQ(this.prompt, this.options, this.answer);
  final String prompt;
  final List<String> options;
  final int answer;
}

const List<_LogicQ> _kLogic = [
  _LogicQ('What comes next?\n2 · 4 · 6 · 8 · __', ['9', '10', '11', '12'], 1),
  _LogicQ('Which one is the odd one out?',
      ['🍎 Apple', '🍌 Banana', '🥕 Carrot', '🍊 Orange'], 2),
  _LogicQ('What comes next?\n🌙 ☀️ 🌙 ☀️ __', ['☀️', '🌙', '⭐', '☁️'], 1),
  _LogicQ('Which is the biggest?',
      ['🐜 Ant', '🐈 Cat', '🐘 Elephant', '🐭 Mouse'], 2),
  _LogicQ('What comes next?\nA · B · C · D · __', ['F', 'E', 'G', 'Z'], 1),
];

class LogicGame extends StatefulWidget {
  const LogicGame(
      {super.key, required this.controller, this.markComplete = true});
  final PregnancyController controller;
  final bool markComplete;
  @override
  State<LogicGame> createState() => _LogicGameState();
}

class _LogicGameState extends State<LogicGame> {
  final Random _rng = Random();
  int _i = 0;
  bool _nudge = false;
  bool _done = false;

  // Reload: restart from the first question.
  void _reload() {
    _i = 0;
    _nudge = false;
    setState(() => _done = false);
  }

  // New puzzle: start from a random question.
  void _newPuzzle() {
    _i = _rng.nextInt(_kLogic.length);
    _nudge = false;
    setState(() => _done = false);
  }

  // Next puzzle: skip to the next question.
  void _next() {
    _i = (_i + 1) % _kLogic.length;
    setState(() => _nudge = false);
  }

  void _choose(int opt) {
    final q = _kLogic[_i];
    if (opt == q.answer) {
      if (_i == _kLogic.length - 1) {
        if (widget.markComplete) GarbhStore.instance.markDone('vichara');
        setState(() => _done = true);
      } else {
        setState(() {
          _i++;
          _nudge = false;
        });
      }
    } else {
      setState(() => _nudge = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final q = _kLogic[_i];
    return _GameChrome(
      title: 'Logic Puzzle',
      controller: widget.controller,
      done: _done,
      onAgain: _reload,
      onReload: _reload,
      onNewPuzzle: _newPuzzle,
      onNext: _next,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
        children: [
          _howCard(s.gsLogicHow),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(s.gsLogicProgress(_i + 1, _kLogic.length),
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: _muted)),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _line),
            ),
            child: Text(q.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 21,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: _ink)),
          ),
          const SizedBox(height: 18),
          for (var o = 0; o < q.options.length; o++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _choose(o),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 18),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _line),
                  ),
                  child: Text(q.options[o],
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _ink)),
                ),
              ),
            ),
          if (_nudge)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Center(
                child: Text(s.gsLogicNudge,
                    style: const TextStyle(
                        color: _softRed, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  4 · MEMORY MATCH (4×4, 8 calming pairs)
// ===========================================================================
class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame(
      {super.key, required this.controller, this.markComplete = true});
  final PregnancyController controller;
  final bool markComplete;
  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  static const List<String> _faces = [
    '🌸', '🌿', '🌙', '⭐', '🍃', '🦋', '🕊️', '🌷'
  ];
  final Random _rng = Random();

  late List<String> _cards;
  final Set<int> _matched = {};
  int? _first;
  int? _second;
  bool _busy = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _cards = [..._faces, ..._faces]..shuffle(_rng);
    _matched.clear();
    _first = null;
    _second = null;
    _busy = false;
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
    setState(() => _second = i);
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
    return _GameChrome(
      title: 'Memory Match',
      controller: widget.controller,
      done: _done,
      onAgain: _reset,
      // One calming face set, so every control simply reshuffles the board.
      onReload: _reset,
      onNewPuzzle: _reset,
      onNext: _reset,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          _howCard(s.gsMemoryHow),
          Padding(
            padding: const EdgeInsets.all(18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10),
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
                          ? _acc.withValues(alpha: 0.18)
                          : up
                              ? _surface
                              : _acc.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: matched ? _acc : _line,
                          width: matched ? 1.6 : 1),
                    ),
                    child: Text(
                      up ? _cards[i] : '',
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
