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
      await tapText(step < options.length - 1 ? 'Continue' : 'See what it might be' /* was 'See the likely cause' (tools pass 2026-10-25) */, 120);
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

  // ⚠️ REWRITTEN 2026-10-25 (tools pass H1): this test locked in a fever
  // answer that contradicted Fever check (a 2-month-old at 37.2 C: urgent
  // here, "no fever" there). Fever now hands over to Fever check, so the red
  // flag is held on a concern that keeps its own rules: green vomit.
  testWidgets('A red-flag answer routes to an urgent "see a doctor now" result, with 112 and 108', (tester) async {
    bigView(tester);
    final vomit = wcById('vomiting')!;
    await tester.pumpWidget(MaterialApp(home: WcFlowScreen(concern: vomit)));
    await tester.pumpAndSettle();

    await walk(tester, const [
      'Green or yellow',
      'Yes, plenty',
      'Once or twice',
    ]);

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Vomit that needs a doctor now'), -200, scrollable: scrollable, maxScrolls: 30);
    expect(find.text('Vomit that needs a doctor now'), findsOneWidget);
    expect(find.text('SEE A DOCTOR NOW'), findsWidgets);
    expect(find.byKey(const ValueKey('wc_flow_emergency')), findsOneWidget);
  });

  test('fever hands over to Fever check, the one fever judge', () {
    expect(kWcHandOff['low_fever'], 'pp_fever_check');
    expect(kWcRules.containsKey('low_fever'), isFalse, reason: 'the old fever rules no longer run');
  });
}
