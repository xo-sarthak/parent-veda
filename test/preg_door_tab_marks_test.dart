// Every pregnancy door tab draws a mark, and no two tabs on one rail draw the
// same one (user, 2026-10-22: Labour prep, Mind & mood and Belly & skin showed
// plain Material icons, and Nutrition, Garbh and Work & money repeated a mark).
//
// The rail picks its glyph in pv_door_rail.dart: the TTC-family mark for the
// tab's IntentMark, else the older drawn mark, else Icon(g.icon). A null
// `mark` is what let the plain icon through, so that is what this holds.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/screens/brackets/hub/hub_intent_art.dart' show IntentMark;
import 'package:parentveda/screens/ttc/ttc_tool_marks.dart';

/// What the rail actually draws for a mark: the TTC-family object when there
/// is one, else the pregnancy mark itself. Two marks that map to one object
/// look identical on the rail, so they count as the same.
String _drawn(IntentMark mark) {
  final w = ttcFamilyMarkForIntent(mark, Colors.black, forDoor: true);
  if (w is TtcMarkLeading) return '${w.tab ?? w.tool}';
  return '$mark';
}

void main() {
  for (final door in kPvDoorPages) {
    test('${door.bracketId}: every tab has a drawn mark, none repeated', () {
      final seen = <String, String>{};
      for (final g in door.groups) {
        expect(g.mark, isNotNull, reason: '${door.bracketId} tab "${g.label}" falls back to a Material icon');
        final key = _drawn(g.mark!);
        expect(seen.containsKey(key), isFalse,
            reason: '${door.bracketId}: "${g.label}" draws the same mark as "${seen[key]}"');
        seen[key] = g.label;
      }
    });
  }
}
