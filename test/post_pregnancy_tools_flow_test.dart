// Functional tests: the "What Changed?" diagnostic is ANSWER-AWARE — the parent's
// answers change the diagnosis, and red-flag answers route to an urgent result.
// (Content scrolls, so we scroll each target into view first.)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/pp_what_changed_data.dart';
import 'package:parentveda/screens/post_pregnancy/what_changed_screen.dart';

void main() {
  void bigView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  // Walk a flow: for each question, tap the given option then the advance button.
  Future<void> walk(WidgetTester tester, List<String> options) async {
    final scrollable = find.byType(Scrollable).first;
    Future<void> tapText(String t, double delta) async {
      await tester.scrollUntilVisible(find.text(t), delta, scrollable: scrollable, maxScrolls: 30);
      await tester.tap(find.text(t));
      await tester.pump();
    }

    for (var step = 0; step < options.length; step++) {
      await tapText(options[step], -120);
      await tapText(step < options.length - 1 ? 'Continue' : 'See the likely cause', 120);
    }
  }

  testWidgets('An answer changes the diagnosis (runny nose -> a cold, not a regression)', (tester) async {
    bigView(tester);
    await tester.pumpWidget(const MaterialApp(home: WhatChangedScreen()));
    await tester.pump();

    final open = find.text('Waking every 2 hours at night').first;
    await tester.ensureVisible(open);
    await tester.tap(open);
    await tester.pumpAndSettle();

    // Answering "a runny nose or cough" on the illness question should route to a
    // cold result — NOT the default developmental regression.
    await walk(tester, const [
      'Yes — a new food or formula',
      'Yes — travel or a new routine',
      'Yes — travel, guests, or a move',
      'Yes — a runny nose or cough',
      'Yes — much clingier',
    ]);

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('A cold behind the broken nights'), -200, scrollable: scrollable, maxScrolls: 30);
    expect(find.text('A cold behind the broken nights'), findsOneWidget);
    expect(find.text('A developmental sleep regression'), findsNothing);
  });

  testWidgets('A red-flag answer routes to an urgent "see a doctor now" result', (tester) async {
    bigView(tester);
    final fever = wcById('low_fever')!;
    await tester.pumpWidget(MaterialApp(home: WcFlowScreen(concern: fever)));
    await tester.pumpAndSettle();

    // Under 3 months with a fever is a red flag -> urgent, regardless of the
    // other (benign) answers chosen.
    await walk(tester, const [
      'Under 38°C',
      'Under 3 months',
      'Just a bit warm and clingy',
    ]);

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('This needs a doctor now'), -200, scrollable: scrollable, maxScrolls: 30);
    expect(find.text('This needs a doctor now'), findsOneWidget);
    expect(find.text('SEE A DOCTOR NOW'), findsWidgets);
  });
}
