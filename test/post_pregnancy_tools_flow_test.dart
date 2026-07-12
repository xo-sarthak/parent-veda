// Functional test: the "What Changed?" hub opens a concern, walks its
// (concern-specific) questions, and lands on the likely-cause result.
// (Content scrolls, so we scroll each target into view first.)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/what_changed_screen.dart';

void main() {
  testWidgets('What Changed? opens a concern and reaches the result', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: WhatChangedScreen()));
    await tester.pump();

    // The hub lists concerns; open the common "waking every 2 hours" one.
    // (Its label appears under both "Most common" and its area — tap the first.)
    final open = find.text('Waking every 2 hours at night').first;
    await tester.ensureVisible(open);
    await tester.tap(open);
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    Future<void> tapText(String t, double delta) async {
      await tester.scrollUntilVisible(find.text(t), delta, scrollable: scrollable, maxScrolls: 30);
      await tester.tap(find.text(t));
      await tester.pump();
    }

    expect(find.text('A developmental sleep regression'), findsNothing);

    const firstOptions = [
      'Yes — a new food or formula',
      'Yes — travel or a new routine',
      'Yes — travel, guests, or a move',
      'Yes — a runny nose or cough',
      'Yes — much clingier',
    ];

    for (var step = 0; step < 5; step++) {
      await tapText(firstOptions[step], -120); // option is above; scroll up to it
      await tapText(step < 4 ? 'Continue' : 'See the likely cause', 120); // button is below
    }

    await tester.scrollUntilVisible(find.text('A developmental sleep regression'), -200,
        scrollable: scrollable, maxScrolls: 30);
    expect(find.text('A developmental sleep regression'), findsOneWidget);

    // escalation lives further down the result - scroll it into view
    await tester.scrollUntilVisible(find.text('Still worried?'), 150, scrollable: scrollable, maxScrolls: 30);
    expect(find.text('Still worried?'), findsOneWidget);
  });
}
