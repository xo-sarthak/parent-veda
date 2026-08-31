// =============================================================================
//  A horizontal rail has to LOOK scrollable
// -----------------------------------------------------------------------------
//  ⚠️ THIS ASSERTS AN ARITHMETIC RESULT NOBODY HAD WRITTEN DOWN. The focus
//  page's rails were sized so that "two whole cards and a slice of the third"
//  would show, and the intent was right while the sum was wrong — it counted
//  one gap where the layout has two:
//
//      18 gutter + 158 card + 11 gap + 158 card       = 345   (looks fine)
//      ... but the third card starts after ANOTHER gap = 356
//
//  leaving four points of a 360pt screen. Four points of a card does not read
//  as "there is more" — it reads as something clipped by mistake, which is
//  exactly how it was reported.
//
//  ⚠️ THE POINT IS THAT THE FAILURE WAS INVISIBLE TO EVERY OTHER CHECK. It is
//  not an overflow, so no exception. It is not a missing widget, so no
//  reachability test fires. It renders perfectly and is simply the wrong shape,
//  and the only reason anyone found it was someone holding a phone next to a
//  competitor's.
//
//  So the quantity that actually matters — how much of the next card a person
//  can see — is computed here rather than left implicit in three constants
//  scattered across two files.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/brackets/ttc_brackets.dart';
import 'package:parentveda/screens/ttc/ttc_focus_screen.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';

/// How much of the third card shows, on the narrowest screen we design for.
double _peek({required double gutter}) =>
    kPvNarrowestScreen -
    gutter -
    kTtcRailCardWidth -
    kTtcRailGap -
    kTtcRailCardWidth -
    kTtcRailGap;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('the third card is visibly there, not a four-point sliver', () {
    final peek = _peek(gutter: 18);

    // ⚠️ 20pt IS THE FLOOR AND IT IS NOT ARBITRARY. The reference shows about
    // 19pt of its third card and is legible at that; below roughly a finger's
    // width the eye reads a clipped edge rather than an object.
    expect(peek, greaterThanOrEqualTo(20),
        reason: 'only ${peek.toStringAsFixed(1)}pt of the third card shows — '
            'the rail will read as two clipped cards, not as scrollable');

    // ⚠️ AND AN UPPER BOUND, because the failure has two directions. Past about
    // half a card the rail stops reading as "two cards and a hint" and starts
    // reading as three cramped ones, which loses the thing the size was chosen
    // for: two cards big enough to compare at a glance.
    expect(peek, lessThan(kTtcRailCardWidth * 0.5),
        reason: 'the cards have shrunk far enough that three compete for '
            'attention instead of two');
  });

  test('the card keeps its proportions', () {
    // A card narrowed without being shortened is not a smaller card, it is a
    // different and worse shape. 1.24 is what the design was drawn at.
    final ratio = kTtcRailCardHeight / kTtcRailCardWidth;
    expect(ratio, closeTo(1.24, 0.06),
        reason: 'width and height moved independently: '
            '$kTtcRailCardWidth x $kTtcRailCardHeight');
  });

  testWidgets('and the page lays out at 360pt with the smaller cards',
      (tester) async {
    // ⚠️ NARROW ON PURPOSE. A 1200pt test surface fits anything; every overflow
    // this stage has shipped was found at phone width or not at all.
    tester.view.physicalSize = const Size(360, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: TtcFocusScreen(
        page: kTtcConceivingFocus,
        // ⚠️ THE REAL BRACKET, NOT A HAND-BUILT ONE. A fixture assembled in a
        // test is a fixture that keeps rendering after the shipped data stops
        // matching it — and this screen reads `bracket.label` for its heading
        // precisely so the tile and the page cannot diverge.
        bracket: kTtcBrackets.firstWhere((b) => b.id == 'ttc_conceiving'),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    for (var i = 0; i < 20; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -700));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull, reason: 'threw while scrolling');
    }
  });
}
