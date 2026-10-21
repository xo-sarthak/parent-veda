// =============================================================================
//  The parenting V3 home still builds
// -----------------------------------------------------------------------------
//  ⚠️ WRITTEN AFTER A BLANK SCREEN THAT COULD NOT BE REPRODUCED BY HAND.
//
//  Three edits landed on this screen in one pass -- the hero was reordered, a
//  phase explainer was inserted into the sheet, and the snapshot stopped
//  truncating its domains -- and the phone then showed the field with no sheet
//  on it. `flutter analyze` was clean and logcat carried no exception, which
//  left "is it broken?" unanswerable by looking.
//
//  A build test answers it in two seconds and keeps answering it. That is worth
//  more here than on most screens: this one is assembled from ten data sources,
//  so a null in any of them takes the whole home down and every one of them is
//  edited by someone else.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_home_v3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('the parenting V3 home builds and shows its sheet',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PpHomeV3()));
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull,
        reason: 'the V3 home threw while building');

    // The sheet's own sections, not the hero: a field with no sheet on it was
    // exactly the failure this test was written for.
    // Was 'Right now' (the snapshot's title until 2026-10-22); Explore by
    // topic is the first sheet section under the hero since Wave 6.
    expect(find.textContaining('Explore by topic', skipOffstage: false), findsWidgets,
        reason: 'the sheet is missing');
  });

  // Since 2026-10-22 (Wave 6) the phase explainer is the phase page, one tap
  // from the painted hero; the home carries the painting and the way in.
  testWidgets('and the painted hero opens the phase', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PpHomeV3()));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('pp_hero_painting')), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_hero_open_phase')), findsOneWidget);
    expect(find.textContaining('This phase, explained', skipOffstage: false), findsNothing);
    expect(tester.takeException(), isNull);
  });

  // Kept for revert: the explainer on the home.
  // ignore: unused_element
  void keptExplainer() => testWidgets('and the phase explainer is on it', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PpHomeV3()));
    await tester.pump(const Duration(milliseconds: 400));

    // ⚠️ SCROLL FIRST. A `ListView` only builds what is near the viewport, so a
    // section below the fold is genuinely absent from the tree rather than
    // merely off-screen. Asserting without scrolling tests the scroll position,
    // not the screen.
    // The heading is pregnancy's "This phase, explained" since 2026-10-07 (no eyebrow).
    for (var i = 0; i < 4; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -700));
      await tester.pump(const Duration(milliseconds: 250));
      if (find
          .textContaining('This phase, explained', skipOffstage: false)
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    expect(find.textContaining('This phase, explained', skipOffstage: false),
        findsWidgets,
        reason: 'the section added for Current/V3 symmetry is not rendering');
    expect(tester.takeException(), isNull);
  });
}
