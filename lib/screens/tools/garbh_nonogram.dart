// =============================================================================
//  Logic Puzzle — a light nonogram (picross), 5×5 and 6×6, hints allowed
// -----------------------------------------------------------------------------
//  Buddhi to final, from the Garbh Sanskar pillars brief, 12 Sep 2026. The
//  class is still `LogicGame` because `gameForPuzzle` dispatches on it and
//  the puzzle list names it "Logic Puzzle"; what is behind the name changed
//  from four multiple-choice questions to a picture puzzle. The old quiz is
//  in `garbh_games.dart`, commented, kept for revert.
//
//  ⚠️ FILL OR CROSS, HER CHOICE. Two modes: fill a cell, or cross it as
//  "definitely empty". Crosses are her working; only fills count towards the
//  picture. A completed row or column dims its clue, which is the only
//  feedback the board gives unasked.
//
//  ⚠️ HINT REVEALS ONE CELL. A wrongly filled cell is cleared first (that is
//  where she is stuck); otherwise one empty cell of the picture is filled.
//
//  ⚠️ THE PICTURE IS NAMED ON FINISH, NOT BEFORE. "A heart" as a title would
//  be the puzzle's answer.
// =============================================================================

import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/garbh_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import 'games/game_chrome.dart';
import 'games/nonogram_engine.dart';

class LogicGame extends StatefulWidget {
  const LogicGame(
      {super.key, required this.controller, this.markComplete = true, this.startAt});
  final PregnancyController controller;
  final bool markComplete;

  /// The picture to open on. Null: a random one, as she sees it. Set by the
  /// test that draws every picture (a random pick once hid an overflow that
  /// only some pictures had, 2026-09-30).
  final int? startAt;

  @override
  State<LogicGame> createState() => _LogicGameState();
}

class _LogicGameState extends State<LogicGame> {
  final Random _rng = Random();
  int _which = 0;
  late NonogramPuzzle _puzzle;
  late List<int> _marks;
  bool _cross = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _which = widget.startAt ?? _rng.nextInt(kNonogramPictures.length);
    _load();
  }

  void _load() {
    _puzzle = NonogramPuzzle(kNonogramPictures[_which]);
    _marks = List<int>.filled(_puzzle.size * _puzzle.size, 0);
    _cross = false;
    setState(() => _done = false);
  }

  void _reload() => _load();

  void _newPuzzle() {
    var next = _rng.nextInt(kNonogramPictures.length);
    if (kNonogramPictures.length > 1 && next == _which) {
      next = (next + 1) % kNonogramPictures.length;
    }
    _which = next;
    _load();
  }

  void _next() {
    _which = (_which + 1) % kNonogramPictures.length;
    _load();
  }

  void _tap(int i) {
    setState(() {
      final want = _cross ? 2 : 1;
      _marks[i] = _marks[i] == want ? 0 : want;
    });
    _checkDone();
  }

  void _hint() {
    final i = _puzzle.hint(_marks, _rng);
    if (i == null) return;
    setState(() => _marks[i] = _puzzle.solutionAt(i) ? 1 : 0);
    _checkDone();
  }

  void _checkDone() {
    if (_done || !_puzzle.isSolved(_marks)) return;
    if (widget.markComplete) GarbhStore.instance.markDone('vichara');
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final n = _puzzle.size;
    // The widest row clue decides the gutter; column clues take a fixed
    // strip up top.
    final rowClueWidth = 14.0 *
        _puzzle.rowClues.map((c) => c.length).reduce(max).clamp(1, 3) +
        10;
    const colClueHeight = 44.0;

    return GarbhGameChrome(
      title: 'Logic Puzzle',
      controller: widget.controller,
      done: _done,
      onAgain: _newPuzzle,
      onReload: _reload,
      onNewPuzzle: _newPuzzle,
      onNext: _next,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          garbhHowCard('The numbers say how many cells in a row are filled, '
              'in order, with at least one gap between runs. Fill the cells '
              "you're sure of, and cross out the ones that must be empty."),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: LayoutBuilder(builder: (context, box) {
              final side = box.maxWidth - rowClueWidth;
              final cell = side / n;
              return Column(children: [
                // column clues
                Row(children: [
                  SizedBox(width: rowClueWidth),
                  for (var c = 0; c < n; c++)
                    SizedBox(
                      width: cell,
                      height: colClueHeight,
                      // ⚠️ SHRINK TO FIT, NEVER SPILL (2026-09-30). The strip
                      // is a fixed height and the gutter is capped at three
                      // clues' width, so a picture with a longer run of clues,
                      // or a two-digit one, overflowed by a fraction of a
                      // pixel. Which picture opens is random, so it failed on
                      // some runs only. Scale down only: short clues keep
                      // their size.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            for (final k in _puzzle.colClues[c])
                              Text('$k',
                                  style: _clue(_puzzle.colDone(_marks, c))),
                          ],
                        ),
                      ),
                    ),
                ]),
                for (var r = 0; r < n; r++)
                  Row(children: [
                    SizedBox(
                      width: rowClueWidth,
                      height: cell,
                      // Shrink to fit, as the column clues above.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            for (final k in _puzzle.rowClues[r])
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text('$k',
                                    style:
                                        _clue(_puzzle.rowDone(_marks, r))),
                              ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                    for (var c = 0; c < n; c++) _cellBox(r * n + c, cell),
                  ]),
              ]);
            }),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(children: [
              GarbhGameKey(
                  label: 'Fill',
                  icon: Icons.square_rounded,
                  selected: !_cross,
                  width: 56,
                  onTap: () => setState(() => _cross = false)),
              const SizedBox(width: 8),
              GarbhGameKey(
                  label: 'Cross',
                  icon: Icons.close_rounded,
                  selected: _cross,
                  width: 56,
                  onTap: () => setState(() => _cross = true)),
              const Spacer(),
              GarbhGameKey(
                  label: 'Hint',
                  icon: Icons.lightbulb_outline_rounded,
                  width: 56,
                  onTap: _hint),
            ]),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
                _cross
                    ? "Tap to cross out a cell you're sure is empty."
                    : 'Tap to fill a cell. Switch to Cross to mark the '
                        'empties.',
                style: pvManrope(fontSize: 12, color: kGameMuted)),
          ),
        ],
      ),
    );
  }

  TextStyle _clue(bool done) => pvManrope(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: done ? kGameMuted.withValues(alpha: 0.5) : kGameInk);

  Widget _cellBox(int i, double cell) {
    final m = _marks[i];
    return GestureDetector(
      onTap: () => _tap(i),
      child: Container(
        width: cell,
        height: cell,
        decoration: BoxDecoration(
          color: m == 1 ? kGameAccent : kGameSurface,
          border: Border.all(color: kGameLine, width: 0.8),
        ),
        alignment: Alignment.center,
        child: m == 2
            ? Icon(Icons.close_rounded,
                size: cell * 0.5, color: kGameMuted.withValues(alpha: 0.7))
            : null,
      ),
    );
  }
}
