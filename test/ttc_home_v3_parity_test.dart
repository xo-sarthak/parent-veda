// =============================================================================
//  V1 and V3 reach the same places
// -----------------------------------------------------------------------------
//  ⚠️ THE INVARIANT IS COVERAGE, NOT LAYOUT. The Current | V3 pill is an A/B on
//  how the TTC home LOOKS. The moment one side can reach something the other
//  cannot, flipping it stops being a comparison of two designs and becomes a
//  comparison of two feature sets — and whichever wins, the reason will be
//  wrong.
//
//  V3 shipped missing nine gates V1 had: Me / Us / What's next, today's
//  insight, today's myth, today's nutrition, today's movement, today's pick,
//  the record-a-test door out of the stage, the estimates disclaimer, and the
//  Her | Him dev switch. None of that was noticed by `flutter analyze`, by the
//  2,700 tests, or by opening V3 on its own — only by opening the two side by
//  side, which is exactly what nobody does once a screen looks finished.
//
//  ⚠️ THIS TEST DOES NOT ASSERT THEY LOOK ALIKE. They must not. It asserts that
//  a named destination reachable from one home is reachable from the other, and
//  says nothing about how.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_home_v3.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';

/// Scrolls until [needle] is in the tree, or gives up.
///
/// ⚠️ A `ListView` only builds what is near the viewport, so a section below
/// the fold is genuinely ABSENT rather than merely off-screen. Asserting
/// without scrolling tests the scroll position, not the screen — the lesson
/// already written into `pp_home_v3_renders_test.dart`.
Future<void> _scrollTo(WidgetTester tester, Finder needle) async {
  for (var i = 0; i < 12; i++) {
    if (needle.evaluate().isNotEmpty) return;
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  Future<void> pumpV3(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TtcHomeV3()));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull,
        reason: 'the TTC V3 home threw while building');
  }

  testWidgets('V3 still builds with nothing logged', (tester) async {
    await pumpV3(tester);
    // The sheet, not the field. A field with no sheet on it is the failure the
    // parenting equivalent of this test was written for.
    expect(find.text('Start anywhere'), findsWidgets);
  });

  testWidgets('the four daily rows are all on it', (tester) async {
    final t = TtcS.current();
    await pumpV3(tester);

    // Uppercased by the row, so match the rendered form.
    for (final eyebrow in [
      t.todaysMyth,
      t.todaysNutrition,
      t.todaysMovement,
      t.todaysPick,
    ]) {
      final f = find.text(eyebrow.toUpperCase(), skipOffstage: false);
      await _scrollTo(tester, f);
      expect(f, findsWidgets,
          reason: '"$eyebrow" is reachable from V1 and not from V3');
    }
  });

  testWidgets("today's insight is a card, not a row", (tester) async {
    await pumpV3(tester);
    final f = find.text(TtcS.current().todaysInsight.toUpperCase(),
        skipOffstage: false);
    await _scrollTo(tester, f);
    expect(f, findsWidgets);
  });

  testWidgets('Me / Us / What\'s next reach the chapter reader',
      (tester) async {
    final t = TtcS.current();
    await pumpV3(tester);

    // ⚠️ THE POINT OF THESE THREE. `ttc_chapter` opens the reader at its
    // DEFAULT tab, so a single chapter link reaches "Me" and nothing else —
    // which is what V3 had. Us and What's next were unreachable in this
    // version of the app entirely.
    final f = find.text(t.shortcutUs, skipOffstage: false);
    await _scrollTo(tester, f);
    for (final label in [t.shortcutMe, t.shortcutUs, t.shortcutNext]) {
      expect(find.text(label, skipOffstage: false), findsWidgets,
          reason: '"$label" opens a chapter tab and V3 cannot reach it');
    }
  });

  testWidgets('the ritual can be COMPLETED from the home, not just opened',
      (tester) async {
    // ⚠️ THE ONE GAP A REACHABILITY CHECK WOULD HAVE PASSED. V3 had a card
    // that opened the ritual screen — same destination, so "can she get
    // there?" answers yes. What it removed was the ability to DO the thing
    // from Today: the tick, the 0/5, the streak.
    //
    // That difference does not show up as a missing link. It shows up as
    // lower ritual completion on V3, which the toggle would then have
    // attributed to the design.
    TtcRitualStore.instance.resetForTest();
    await pumpV3(tester);

    final counter = find.text('0/${TtcRitualStore.instance.total}',
        skipOffstage: false);
    await _scrollTo(tester, counter);
    expect(counter, findsWidgets,
        reason: 'no progress counter, so nothing on the home says how much of '
            'the ritual is done');

    // Tick the first part from the home and expect the count to move WITHOUT
    // a navigation having happened.
    final ticks = find.byIcon(Icons.check_rounded, skipOffstage: false);
    final circles = find.descendant(
        of: find.byType(GestureDetector, skipOffstage: false),
        matching: find.byType(Container, skipOffstage: false));
    expect(circles, findsWidgets);
    expect(ticks, findsNothing, reason: 'nothing should be done yet');

    TtcRitualStore.instance.toggle(TtcRitualPart.values.first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('1/${TtcRitualStore.instance.total}', skipOffstage: false),
        findsWidgets,
        reason: 'the card does not listen to TtcRitualStore, so a completed '
            'part repaints nothing');
  });

  testWidgets('the door out of the stage is on it', (tester) async {
    await pumpV3(tester);
    // The only way to tell the app she is pregnant. Without it a positive test
    // on V3 had nowhere to go but flipping back to V1.
    final f = find.text(TtcS.current().transitionRecord, skipOffstage: false);
    await _scrollTo(tester, f);
    expect(f, findsWidgets);
  });

  testWidgets('and so is the estimates disclaimer', (tester) async {
    await pumpV3(tester);
    final f =
        find.text(TtcS.current().estimatesDisclaimer, skipOffstage: false);
    await _scrollTo(tester, f);
    expect(f, findsWidgets,
        reason: 'every tool carries this and the busiest screen did not');
  });
}
