// =============================================================================
//  The TTC door tab marks (`TtcTabArt`, 2026-09-27)
// -----------------------------------------------------------------------------
//  The rail's cards wore shared pregnancy intent marks and read as stock (the
//  user: "very random"). This holds the replacement family:
//    · every tab on every door carries a TTC tab mark, so no card falls back;
//    · no two tabs on ONE door share a mark, or the mark stops telling them
//      apart (reuse across doors is by meaning and is allowed);
//    · every mark in the family paints at the rail's size without throwing;
//    · the rail draws the family, not the fallback.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_rail.dart';
import 'package:parentveda/screens/ttc/doors/ttc_tab_art.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';

void main() {
  test('every tab on every door has a TTC tab mark', () {
    var n = 0;
    for (final page in kTtcFocusPages) {
      for (final g in page.groups ?? const <TtcFocusGroup>[]) {
        n++;
        expect(g.tabMark, isNotNull,
            reason: '${page.bracketId} / ${g.id} ("${g.label}") has no tab '
                'mark, so its rail card falls back to a shared intent mark');
        // The fallback stays set, so losing a tab mark never empties a well.
        expect(g.mark, isNotNull, reason: '${page.bracketId} / ${g.id}');
      }
    }
    expect(n, greaterThan(40), reason: 'nine doors, about forty-seven tabs');
  });

  test('no two tabs on one door share a mark', () {
    for (final page in kTtcFocusPages) {
      final marks = [for (final g in page.groups!) g.tabMark];
      expect(marks.toSet().length, marks.length,
          reason: '${page.bracketId}: $marks');
    }
  });

  testWidgets('every mark paints at the rail size without throwing',
      (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Wrap(children: [
        for (final m in TtcTabMark.values)
          for (final hue in [42.0, 206.0])
            SizedBox(
              width: TtcDoorRail.markSize,
              height: TtcDoorRail.markSize,
              child: TtcTabArt(
                mark: m,
                tint: HSLColor.fromAHSL(1, hue, 0.30, 0.88).toColor(),
              ),
            ),
      ]),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(TtcTabArt), findsNWidgets(TtcTabMark.values.length * 2));
  });

  testWidgets('the rail draws the TTC family on every card', (tester) async {
    final page = kTtcFocusPages.first;
    final groups = page.groups!;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TtcDoorRail(
          groups: groups,
          counts: const [],
          selected: 0,
          p: kV2Palettes.first,
          onPick: (_) {},
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(TtcTabArt), findsNWidgets(groups.length));
    for (var i = 0; i < groups.length; i++) {
      final art = tester.widget<TtcTabArt>(find.descendant(
          of: find.byKey(ttcDoorRailCardKey(i)),
          matching: find.byType(TtcTabArt)));
      expect(art.mark, groups[i].tabMark);
    }
  });
}
