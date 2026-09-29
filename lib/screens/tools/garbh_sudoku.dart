// =============================================================================
//  Sudoku — 9×9 easy by default, a gentle 6×6, pencil notes, check, hint
// -----------------------------------------------------------------------------
//  Buddhi to final, from the Garbh Sanskar pillars brief, 12 Sep 2026. The
//  engine is `games/sudoku_engine.dart`; this is the board and the keys.
//
//  ⚠️ NO TIMER, NO SCORE. "Do not show a pressuring timer." Nothing on this
//  screen counts anything. The one thing it says about her progress is which
//  cells clash, and only when she asks (Check) or types a clash.
//
//  ⚠️ PENCIL NOTES ARE HERS. In pencil mode a key toggles a small candidate
//  in the cell; a real entry clears the cell's notes. Nothing here fills
//  notes for her — that would be solving the puzzle on her behalf, which is
//  the opposite of a few quiet minutes.
//
//  ⚠️ HINT FILLS ONE CELL WITH THE ANSWER. The selected empty cell if there
//  is one, else a random empty one. Because every generated puzzle has one
//  solution, the hint is the truth for that cell, not a guess.
//
//  ⚠️ CHECK MARKS, AND DOES NOT JUDGE. Wrong cells go soft red until she
//  changes them. No count, no "3 mistakes".
//
//  ⚠️ NONE OF THIS SAVES ANYWHERE. Not to My Journal, not to prefs. A
//  puzzle abandoned is a puzzle gone, which is fine: the next one is a tap.
// =============================================================================

import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/garbh_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import 'games/game_chrome.dart';
import 'games/sudoku_engine.dart';

class SudokuGame extends StatefulWidget {
  const SudokuGame(
      {super.key, required this.controller, this.markComplete = true});
  final PregnancyController controller;

  /// When false (opened from a library or the door), finishing does NOT mark
  /// the pillar done for today — it is just play.
  final bool markComplete;

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  final Random _rng = Random();
  late final SudokuEngine _engine = SudokuEngine(_rng);

  int _size = 9;
  late SudokuPuzzle _puzzle;
  late List<int> _board;
  late List<Set<int>> _notes;
  int? _sel;
  bool _pencil = false;
  Set<int> _wrong = const {};
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _newPuzzle();
  }

  void _newPuzzle() {
    _puzzle = _engine.generate(size: _size);
    _reload();
  }

  void _reload() {
    _board = List<int>.of(_puzzle.givens);
    _notes = List.generate(_puzzle.cells, (_) => <int>{});
    _sel = null;
    _pencil = false;
    _wrong = const {};
    setState(() => _done = false);
  }

  void _setSize(int size) {
    if (size == _size) return;
    _size = size;
    _newPuzzle();
  }

  bool _given(int i) => _puzzle.givens[i] != 0;

  void _put(int v) {
    final i = _sel;
    if (i == null || _given(i)) return;
    setState(() {
      if (_pencil && v != 0) {
        if (_board[i] == 0) {
          if (!_notes[i].remove(v)) _notes[i].add(v);
        }
      } else {
        _board[i] = v;
        _notes[i].clear();
        _wrong = _wrong.difference({i});
      }
    });
    if (SudokuEngine.isComplete(_board, _size) && !_done) {
      if (widget.markComplete) GarbhStore.instance.markDone('vichara');
      setState(() => _done = true);
    }
  }

  void _check() {
    setState(() {
      _wrong = {
        for (var i = 0; i < _board.length; i++)
          if (_board[i] != 0 && !_given(i) && _board[i] != _puzzle.solution[i])
            i,
      };
    });
  }

  void _hint() {
    var i = _sel;
    if (i == null || _board[i] != 0) {
      final empties = [
        for (var k = 0; k < _board.length; k++)
          if (_board[k] == 0) k
      ];
      if (empties.isEmpty) return;
      i = empties[_rng.nextInt(empties.length)];
    }
    setState(() {
      _sel = i;
      _pencil = false;
    });
    _put(_puzzle.solution[i]);
  }

  @override
  Widget build(BuildContext context) {
    final conflicts = SudokuEngine.conflicts(_board, _size);
    return GarbhGameChrome(
      title: 'Sudoku',
      controller: widget.controller,
      done: _done,
      onAgain: _newPuzzle,
      onReload: _reload,
      onNewPuzzle: _newPuzzle,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          garbhHowCard(_size == 9
              ? 'Fill 1–9 so every row, column and 3×3 box has no repeats. '
                  'Pencil in the maybes. Nothing is timed.'
              : 'Fill 1–6 so every row, column and 2×3 box has no repeats. '
                  'Pencil in the maybes. Nothing is timed.'),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            child: Row(children: [
              _SizeChip(
                  label: '9 × 9',
                  selected: _size == 9,
                  onTap: () => _setSize(9)),
              const SizedBox(width: 8),
              _SizeChip(
                  label: '6 × 6, gentler',
                  selected: _size == 6,
                  onTap: () => _setSize(6)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: kGameSurface,
                  border: Border.all(color: kGameAccentDeep, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(children: [
                  for (var r = 0; r < _size; r++)
                    Expanded(
                      child: Row(children: [
                        for (var c = 0; c < _size; c++)
                          _cell(r, c, conflicts),
                      ]),
                    ),
                ]),
              ),
            ),
          ),
          _pad(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(children: [
              GarbhGameKey(
                  label: 'Pencil',
                  icon: Icons.edit_outlined,
                  selected: _pencil,
                  width: 56,
                  onTap: () => setState(() => _pencil = !_pencil)),
              const SizedBox(width: 8),
              Expanded(
                child: _TextKey(label: 'Check', onTap: _check),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TextKey(label: 'Hint', onTap: _hint),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _pad() {
    final keys = <Widget>[
      for (var v = 1; v <= _size; v++)
        GarbhGameKey(label: '$v', onTap: () => _put(v)),
      GarbhGameKey(
          label: '', icon: Icons.backspace_outlined, onTap: () => _put(0)),
    ];
    // ⚠️ A WRAP, NOT A SCROLL. The first version scrolled the ten keys in
    // one row; on the phone the 8 and 9 sat under the Ask Veda FAB, and a
    // keypad that needs scrolling is a keypad she cannot type on. Two rows
    // fit 360dp with the right-hand keys clear of the FAB.
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 84, 0),
      child: Wrap(spacing: 6, runSpacing: 6, children: keys),
    );
  }

  Widget _cell(int r, int c, Set<int> conflicts) {
    final i = r * _size + c;
    final v = _board[i];
    final given = _given(i);
    final sel = _sel == i;
    final bad = _wrong.contains(i) || (!given && conflicts.contains(i));
    final br = _puzzle.boxRows, bc = _puzzle.boxCols;
    final thickRight = (c + 1) % bc == 0 && c != _size - 1;
    final thickBottom = (r + 1) % br == 0 && r != _size - 1;
    final sameNumber = v != 0 && _sel != null && _board[_sel!] == v && !sel;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sel = i),
        child: Container(
          decoration: BoxDecoration(
            color: sel
                ? kGameAccent.withValues(alpha: 0.22)
                : sameNumber
                    ? kGameAccent.withValues(alpha: 0.08)
                    : Colors.transparent,
            border: Border(
              right: BorderSide(
                  color: thickRight ? kGameAccentDeep : kGameLine,
                  width: thickRight ? 1.6 : 0.6),
              bottom: BorderSide(
                  color: thickBottom ? kGameAccentDeep : kGameLine,
                  width: thickBottom ? 1.6 : 0.6),
            ),
          ),
          alignment: Alignment.center,
          child: v != 0
              ? Text('$v',
                  style: pvManrope(
                      fontSize: _size == 9 ? 17 : 22,
                      fontWeight: given ? FontWeight.w800 : FontWeight.w500,
                      color: bad
                          ? kGameSoftRed
                          : given
                              ? kGameInk
                              : kGameAccentDeep))
              : _notes[i].isEmpty
                  ? null
                  : _NoteGrid(notes: _notes[i], size: _size),
        ),
      ),
    );
  }
}

/// Pencil marks: the candidates she noted, small, in a 3-wide grid.
class _NoteGrid extends StatelessWidget {
  const _NoteGrid({required this.notes, required this.size});
  final Set<int> notes;
  final int size;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var row = 0; row < (size / 3).ceil(); row++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var k = 1; k <= 3; k++)
                    SizedBox(
                      width: 9,
                      child: Text(
                        notes.contains(row * 3 + k) ? '${row * 3 + k}' : '',
                        textAlign: TextAlign.center,
                        style: pvManrope(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: kGameMuted),
                      ),
                    ),
                ],
              ),
          ],
        ),
      );
}

class _SizeChip extends StatelessWidget {
  const _SizeChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? kGameAccent.withValues(alpha: 0.16) : kGameSurface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? kGameAccent : kGameLine),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? kGameAccentDeep : kGameInk)),
        ),
      );
}

class _TextKey extends StatelessWidget {
  const _TextKey({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kGameSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGameLine),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 14, fontWeight: FontWeight.w700, color: kGameInk)),
        ),
      );
}
