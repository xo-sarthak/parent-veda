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
    expect(find.textContaining('Right now'), findsWidgets,
        reason: 'the child snapshot section is missing');
  });

  testWidgets('and the phase explainer is on it', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PpHomeV3()));
    await tester.pump(const Duration(milliseconds: 400));

    // ⚠️ SCROLL FIRST. A `ListView` only builds what is near the viewport, so a
    // section below the fold is genuinely absent from the tree rather than
    // merely off-screen. Asserting without scrolling tests the scroll position,
    // not the screen.
    // The eyebrow is rendered uppercase by the section head, so match on that.
    for (var i = 0; i < 4; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -700));
      await tester.pump(const Duration(milliseconds: 250));
      if (find
          .textContaining('THIS PHASE EXPLAINED', skipOffstage: false)
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    expect(find.textContaining('THIS PHASE EXPLAINED', skipOffstage: false),
        findsWidgets,
        reason: 'the section added for Current/V3 symmetry is not rendering');
    expect(tester.takeException(), isNull);
  });
}
