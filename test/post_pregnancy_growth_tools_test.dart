// Smoke tests for the four "Journey" tools rebuilt from the Claude Design
// prompts (Growth · Feeding · Sleep · Milestone). Each opens the screen and
// exercises its primary action, so a build/wiring regression fails loudly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/feeding_journey_screen.dart';
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
    await tester.pumpWidget(const MaterialApp(home: MilestoneJourneyScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Development journey'), findsOneWidget);
    expect(find.text('Emerging now'), findsOneWidget);

    // Scroll an emerging milestone card into view and tap it to open the detail
    // sheet; confirm its "Why it matters" section renders.
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Rolling over'), 220, scrollable: scrollable, maxScrolls: 30);
    // ensureVisible: nothing is pre-observed now, so the emerging list sits
    // differently and the card can be only partly on screen when tapped.
    await tester.ensureVisible(find.text('Rolling over'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rolling over'));
    await tester.pumpAndSettle();
    expect(find.text('Why it matters'), findsOneWidget);
  });
}
