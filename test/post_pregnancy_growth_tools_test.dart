// Smoke tests for the four "Journey" tools rebuilt from the Claude Design
// prompts (Growth · Feeding · Sleep · Milestone). Each opens the screen and
// exercises its primary action, so a build/wiring regression fails loudly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/feeding_journey_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/growth_journey_screen.dart';
import 'package:parentveda/screens/post_pregnancy/milestone_journey_screen.dart';
import 'package:parentveda/screens/post_pregnancy/sleep_journey_screen.dart';

void main() {
  void bigView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('Growth journey opens and the Add-measurement sheet appears', (tester) async {
    bigView(tester);
    await tester.pumpWidget(const MaterialApp(home: GrowthJourneyScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Growth journey'), findsOneWidget);
    // Chart renders (custom-painted).
    expect(find.byType(CustomPaint), findsWidgets);

    final add = find.text('Add a measurement');
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.text('Save measurement'), findsOneWidget);
  });

  testWidgets('Feeding journey opens and the Log-a-feed sheet appears', (tester) async {
    bigView(tester);
    await tester.pumpWidget(const MaterialApp(home: FeedingJourneyScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Feeding journey'), findsOneWidget);

    final log = find.text('Log a feed');
    await tester.ensureVisible(log);
    await tester.tap(log);
    await tester.pumpAndSettle();
    expect(find.text('Save feed'), findsOneWidget);
  });

  testWidgets('Sleep journey opens and the Log-sleep sheet appears', (tester) async {
    bigView(tester);
    await tester.pumpWidget(const MaterialApp(home: SleepJourneyScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Sleep journey'), findsOneWidget);

    final log = find.text('Log sleep');
    await tester.ensureVisible(log);
    await tester.tap(log);
    await tester.pumpAndSettle();
    expect(find.text('Save sleep'), findsOneWidget);
  });

  testWidgets('Development journey opens and a milestone detail sheet appears', (tester) async {
    bigView(tester);
    // State the age this test needs. It used to inherit it from a placeholder
    // child that claimed to be four months old — so the test only passed while
    // the app was inventing a birthday, and would have gone green forever on a
    // fabrication. "Rolling over" is emerging at ~4 months, so say so here.
    // 18 weeks = 4 months (ageInMonths floors 18/4.345 to 4).
    ChildProfileStore.instance
        .debugSetDob(DateTime.now().subtract(const Duration(days: 7 * 18)));
    await tester.pumpWidget(const MaterialApp(home: MilestoneJourneyScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Development journey'), findsOneWidget);
    // ⚠️ `findsWidgets`, NOT `findsOneWidget`, AND THE REASON IS A LESSON
    // ABOUT LAZY LISTS RATHER THAN A LOOSENED ASSERTION.
    //
    // "Emerging now" has ALWAYS appeared twice on this screen: once as a
    // summary line in the snapshot hero, once as the section heading. This
    // used to pass because the heading sat below the fold, and a `ListView`
    // does not build children it has not scrolled to — so the finder saw one
    // widget because the other did not exist yet.
    //
    // The parenting feedback moved the emerging cards to the top of the page,
    // so the heading is now built on first frame and the count is two. The
    // screen did not get worse; the test was reading a viewport artefact as a
    // fact about the widget tree. Any `findsOneWidget` over a scrollable is
    // making the same bet.
    expect(find.text('Emerging now'), findsWidgets);

    // Scroll an emerging milestone card into view and tap it to open the detail
    // sheet; confirm its "Why it matters" section renders.
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Rolling over'), 220, scrollable: scrollable, maxScrolls: 30);
    // ensureVisible: nothing is pre-observed now, so the emerging list sits
    // differently and the card can be only partly on screen when tapped.
    await tester.ensureVisible(find.text('Rolling over'));
    await tester.pumpAndSettle();
    // ⚠️ TAPPING A CARD NOW FLIPS IT INSTEAD OF OPENING THE SHEET, which is
    // the parenting feedback's ask: "as user clicks it flips with details
    // about it". The detail sheet is still there, one step further in, behind
    // "Learn more" on the back face.
    //
    // Written as flip-then-open rather than jumping straight to the sheet,
    // because the two-step IS the behaviour under test. A test that reached
    // the sheet another way would pass while the flip was broken.
    await tester.tap(find.text('Rolling over'));
    await tester.pumpAndSettle();
    expect(find.text('What this looks like'), findsOneWidget,
        reason: 'the card did not turn over');

    await tester.tap(find.text('Learn more').first);
    await tester.pumpAndSettle();
    expect(find.text('Why it matters'), findsOneWidget);
  });
}
