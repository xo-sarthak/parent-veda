// PREGNANCY-GAP 21 (2026-10-28): every Pregnancy door tab name fits its card.
//
// The card leaves about 100pt for the name: about 11 Manrope letters at 15,
// now on two lines, wrapped at spaces. The same rule TTC's doors are held to
// (test/ttc_doors_explicit_names_test.dart). A name that fails here would end
// in an ellipsis on a phone.
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/doors/pv_door_data.dart';

bool _fits(String label, {int perLine = 11, int lines = 2}) {
  var used = 1, line = 0;
  for (final w in label.split(' ')) {
    if (w.length > perLine) return false;
    final next = line == 0 ? w.length : line + 1 + w.length;
    if (next <= perLine) {
      line = next;
    } else {
      used++;
      line = w.length;
    }
  }
  return used <= lines;
}

void main() {
  test('every Pregnancy door tab name fits two lines of its card', () {
    final bad = [
      for (final page in kPvDoorPages)
        for (final g in page.groups)
          if (!_fits(g.label)) '${page.bracketId}: "${g.label}"',
    ];
    expect(bad, isEmpty, reason: bad.join('\n'));
  });
}
