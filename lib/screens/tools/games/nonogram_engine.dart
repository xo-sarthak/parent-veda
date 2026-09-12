// =============================================================================
//  Nonogram (picross) — pictures, clues, checking. Pure Dart, no widget.
// -----------------------------------------------------------------------------
//  Built for the Garbh Sanskar pillars brief (Buddhi), 12 Sep 2026: *"Logic
//  Puzzle: a light nonogram (picross) or a simple deduction grid, small
//  sizes, hints allowed."* Before this, "Logic Puzzle" was four multiple-
//  choice questions.
//
//  ⚠️ THE PICTURES ARE DRAWN BY HAND, NOT GENERATED. A random grid makes a
//  valid nonogram but not a satisfying one — most random 5×5s have several
//  solutions and no shape. These are small calm shapes: a heart, a leaf, a
//  moon, a cup. The clues are computed from them, never typed.
//
//  ⚠️ SOLVED MEANS THE CLUES ARE MET, NOT THAT THE PICTURE MATCHES. A few
//  hand-drawn pictures have a second filling that satisfies every clue; a
//  woman who finds it has solved the puzzle. "Hint" reveals a cell of the
//  drawn picture, which is always consistent with the clues.
//
//  Marks: 0 empty, 1 filled, 2 crossed (her "definitely not" note). Only 1s
//  count towards solving; crosses are hers.
// =============================================================================

import 'dart:math';

class NonogramPicture {
  const NonogramPicture(this.name, this.rows);

  final String name;

  /// One string per row, '#' filled, '.' empty. Square.
  final List<String> rows;

  int get size => rows.length;
}

/// Small, calm, and each one recognisable when filled.
const List<NonogramPicture> kNonogramPictures = [
  NonogramPicture('A heart', [
    '.#.#.',
    '#####',
    '#####',
    '.###.',
    '..#..',
  ]),
  NonogramPicture('A leaf', [
    '....#',
    '..###',
    '.####',
    '####.',
    '#....',
  ]),
  NonogramPicture('A cup', [
    '.....',
    '####.',
    '####.',
    '#####',
    '.###.',
  ]),
  NonogramPicture('A moon', [
    '..##.',
    '.#...',
    '#....',
    '.#...',
    '..##.',
  ]),
  NonogramPicture('A little house', [
    '..#..',
    '.###.',
    '#####',
    '#.#.#',
    '#####',
  ]),
  NonogramPicture('A flower', [
    '.#.#.#',
    '..###.',
    '.#####',
    '..###.',
    '...#..',
    '...#..',
  ]),
  NonogramPicture('A boat', [
    '...#..',
    '..##..',
    '.###..',
    '......',
    '######',
    '.####.',
  ]),
  NonogramPicture('A cloud', [
    '......',
    '..##..',
    '.####.',
    '######',
    '######',
    '......',
  ]),
  NonogramPicture('A tree', [
    '..##..',
    '.####.',
    '######',
    '..##..',
    '..##..',
    '..##..',
  ]),
  NonogramPicture('A bowl', [
    '......',
    '......',
    '######',
    '.####.',
    '..##..',
    '......',
  ]),
];

class NonogramPuzzle {
  NonogramPuzzle(this.picture)
      : size = picture.size,
        rowClues = [for (final r in picture.rows) cluesOf(_bits(r))],
        colClues = [
          for (var c = 0; c < picture.size; c++)
            cluesOf([for (final r in picture.rows) r[c] == '#'])
        ];

  final NonogramPicture picture;
  final int size;
  final List<List<int>> rowClues;
  final List<List<int>> colClues;

  static List<bool> _bits(String row) => [for (final ch in row.split('')) ch == '#'];

  /// The run lengths of a line: `#.##..#` → [1, 2, 1]. An empty line is [0].
  static List<int> cluesOf(List<bool> line) {
    final out = <int>[];
    var run = 0;
    for (final b in line) {
      if (b) {
        run++;
      } else if (run > 0) {
        out.add(run);
        run = 0;
      }
    }
    if (run > 0) out.add(run);
    return out.isEmpty ? const [0] : out;
  }

  bool solutionAt(int i) => picture.rows[i ~/ size][i % size] == '#';

  /// True when the filled cells (1s) satisfy every row and column clue.
  bool isSolved(List<int> marks) {
    for (var r = 0; r < size; r++) {
      final line = [for (var c = 0; c < size; c++) marks[r * size + c] == 1];
      if (!_same(cluesOf(line), rowClues[r])) return false;
    }
    for (var c = 0; c < size; c++) {
      final line = [for (var r = 0; r < size; r++) marks[r * size + c] == 1];
      if (!_same(cluesOf(line), colClues[c])) return false;
    }
    return true;
  }

  /// A row or column whose filled cells already meet its clue.
  bool rowDone(List<int> marks, int r) => _same(
      cluesOf([for (var c = 0; c < size; c++) marks[r * size + c] == 1]),
      rowClues[r]);
  bool colDone(List<int> marks, int c) => _same(
      cluesOf([for (var r = 0; r < size; r++) marks[r * size + c] == 1]),
      colClues[c]);

  /// One cell to reveal: a wrongly filled cell first (cleared), else an
  /// unfilled cell of the picture (filled). Null when nothing is left.
  int? hint(List<int> marks, Random rng) {
    final wrong = [
      for (var i = 0; i < marks.length; i++)
        if (marks[i] == 1 && !solutionAt(i)) i
    ];
    if (wrong.isNotEmpty) return wrong[rng.nextInt(wrong.length)];
    final missing = [
      for (var i = 0; i < marks.length; i++)
        if (marks[i] != 1 && solutionAt(i)) i
    ];
    if (missing.isEmpty) return null;
    return missing[rng.nextInt(missing.length)];
  }

  static bool _same(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
