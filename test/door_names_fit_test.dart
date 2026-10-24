// =============================================================================
//  Door names are never cut off
// -----------------------------------------------------------------------------
//  The user, 2026-10-24, on a tab card that read "When will my baby...": "make
//  sure to keep names in such a way that this doesn't happen". Two ways a name
//  ends in dots on screen, and one test each:
//   1. the name itself ends in "..." or "…", so it reads as cut off even when
//      it fits. Scanned in the source of every door, both stages' kinds.
//      Only names (`label:`): a heading that leads into a list, like Garbh's
//      "Stop and call your doctor today if...", is a sentence, not a name.
//   2. the name is too long for the carousel card (156 wide, 13 padding each
//      side, Fraunces 16, two lines, ellipsis). The font loads at run time
//      from google_fonts, so a test cannot measure it; this wraps at 15
//      characters a line, which is what the card holds on a phone.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';

/// Lines a name takes when wrapped word by word at [width] characters.
int _lines(String s, int width) {
  var lines = 1;
  var cur = 0;
  for (final word in s.split(' ')) {
    if (cur == 0) {
      cur = word.length;
    } else if (cur + 1 + word.length <= width) {
      cur += 1 + word.length;
    } else {
      lines++;
      cur = word.length;
    }
  }
  return lines;
}

void main() {
  test('no door name ends in dots', () {
    final named = RegExp(r"""^\s*(label):\s*'([^']*)'""");
    final bad = <String>[];
    for (final f in Directory('lib/data/doors').listSync().whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      for (final line in f.readAsLinesSync()) {
        final m = named.firstMatch(line);
        if (m == null) continue;
        final v = m.group(2)!.trimRight();
        if (v.endsWith('...') || v.endsWith('…')) bad.add('${f.path}: $v');
      }
    }
    expect(bad, isEmpty, reason: 'a name ending in dots reads as cut off');
  });

  test('every parenting tab name fits its card in two lines', () {
    final tooLong = [
      for (final d in kPpDoors)
        for (final t in d.tabs)
          if (_lines(t.label, 15) > 2) '${d.sectionId}: ${t.label}',
    ];
    expect(tooLong, isEmpty, reason: 'the card cuts a third line with dots');
  });
}
