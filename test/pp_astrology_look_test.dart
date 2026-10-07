// =============================================================================
//  AstrologyScreen on the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  Holds the redraw: the shared tool shell, the readings labelled as tradition
//  and as a sample, none of the invented birth details or "AI" wording, no
//  he/him in the readings, and no overflow at 360dp / 1.5x text, off and on.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/astrology_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart' show PregToolScaffold;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  testWidgets('off and on: tradition, not prediction; fits 360dp at 1.5x', (t) async {
    t.view.physicalSize = const Size(360 * 3, 2400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(360, 2400), textScaler: TextScaler.linear(1.5)),
        child: AstrologyScreen(),
      ),
    ));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.byType(PregToolScaffold), findsOneWidget);
    expect(find.textContaining('culture, not medical guidance'), findsOneWidget);

    await t.tap(find.byKey(const ValueKey('astro-toggle')));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.textContaining('A tradition, not a prediction'), findsOneWidget);
    expect(find.textContaining('not advice'), findsOneWidget);

    final all = t
        .widgetList<Text>(find.byType(Text))
        .map((w) => w.data ?? w.textSpan?.toPlainText() ?? '')
        .join('\n');
    expect(all, isNot(contains('Born 8 March')));
    expect(all, isNot(contains('last updated')));
    expect(all, isNot(contains('AI')));
    expect(all, isNot(matches(RegExp(r'\b(he|him|his)\b', caseSensitive: false))));
  });
}
