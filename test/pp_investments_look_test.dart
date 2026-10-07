// =============================================================================
//  InvestmentsScreen on the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  Holds the redraw: the shared tool shell, every disclaimer still on the
//  page, none of the made-up progress ("2 of 6 done", "+10 XP"), the goal
//  chips still change the monthly figure, and no overflow at 360dp / 1.5x.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/investments_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart' show PregToolScaffold;

Future<void> _pump(WidgetTester t) async {
  t.view.physicalSize = const Size(360 * 3, 2400 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(const MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: Size(360, 2400), textScaler: TextScaler.linear(1.5)),
      child: InvestmentsScreen(),
    ),
  ));
  await t.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  testWidgets('shell, disclaimers, no made-up counts, fits 360dp at 1.5x', (t) async {
    await _pump(t);
    expect(t.takeException(), isNull);
    expect(find.byType(PregToolScaffold), findsOneWidget);
    expect(find.textContaining('not a SEBI-registered investment advisor', findRichText: true), findsOneWidget);
    expect(find.textContaining('not a guarantee or a recommendation'), findsOneWidget);
    expect(find.textContaining('referral fee'), findsOneWidget);
    expect(find.textContaining('ParentVeda never touches it', findRichText: true), findsOneWidget);
    expect(find.textContaining('of 6 done'), findsNothing);
    expect(find.textContaining('XP'), findsNothing);
  });

  testWidgets('a horizon chip changes the monthly figure', (t) async {
    await _pump(t);
    String figure() => t
        .widgetList<Text>(find.byType(Text))
        .map((w) => w.textSpan?.toPlainText() ?? w.data ?? '')
        .firstWhere((s) => s.endsWith('/mo'));
    final before = figure();
    await t.tap(find.text('5 years'));
    await t.pumpAndSettle();
    expect(figure(), isNot(before));
    expect(t.takeException(), isNull);
  });
}
