// =============================================================================
//  What changed: the question flow and its result in the one ParentVeda look
//  (2026-10-07)
// -----------------------------------------------------------------------------
//  WcFlowScreen moved onto PregToolScaffold. It must still say it is not a
//  diagnosis, a red flag must still say "see a doctor now" and route to Find
//  help, and nothing may overflow at 360dp and 1.5x text, through every
//  question and the result.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_what_changed_data.dart';
import 'package:parentveda/screens/post_pregnancy/problem_solver_screen.dart';
import 'package:parentveda/screens/post_pregnancy/what_changed_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('the shell build still carries the disclaimer and the doctor route', () {
    final src = File('lib/screens/post_pregnancy/what_changed_screen.dart').readAsStringSync();
    final flow = src.substring(src.indexOf('class _WcFlowScreenState'), src.indexOf('Widget _buildBeforeShell(BuildContext context)'));
    expect(flow, contains('PregToolScaffold('));
    expect(flow, contains('not a diagnosis'));
    expect(flow, contains("'SEE A DOCTOR NOW'"));
    expect(flow, contains('const ProblemSolverScreen()'));
  });

  for (final scale in [1.0, 1.5]) {
    testWidgets('a red-flag walk at 360dp, ${scale}x: no overflow, urgent, routes to a doctor', (t) async {
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
        home: WcFlowScreen(concern: wcById('low_fever')!),
      ));
      await t.pumpAndSettle();
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(t.takeException(), isNull);

      final scrollable = find.byType(Scrollable).first;
      Future<void> tap(String text) async {
        await t.scrollUntilVisible(find.text(text), 120, scrollable: scrollable, maxScrolls: 40);
        await t.tap(find.text(text));
        await t.pump();
      }

      const answers = ['Under 38°C', 'Under 3 months', 'Just a bit warm and clingy'];
      for (var i = 0; i < answers.length; i++) {
        await t.scrollUntilVisible(find.text(answers[i]), -120, scrollable: scrollable, maxScrolls: 40);
        await t.tap(find.text(answers[i]));
        await t.pump();
        expect(t.takeException(), isNull);
        await tap(i < answers.length - 1 ? 'Continue' : 'See the likely cause');
      }
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.text('SEE A DOCTOR NOW'), findsOneWidget);
      expect(find.textContaining('not a diagnosis'), findsOneWidget);

      await tap('Find a paediatrician or urgent care');
      await t.pumpAndSettle();
      expect(find.byType(ProblemSolverScreen), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
