// =============================================================================
//  The baby-name shortlist, compare and chosen pages in the one ParentVeda look
//  (2026-10-07)
// -----------------------------------------------------------------------------
//  All three moved onto PregToolScaffold (the naming home's shell). Nothing
//  overflows at 360dp and 1.5x text.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/name_journey_shortlist_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final pages = <String, Widget>{
    'shortlist': const NameJourneyShortlistScreen(),
    'compare': const NameCompareScreen(),
    'chosen': const NameChosenScreen(name: 'Aarav'),
  };

  for (final scale in [1.0, 1.5]) {
    pages.forEach((name, page) {
      testWidgets('$name, 360dp, ${scale}x: on the shell, no overflow', (t) async {
        t.view.physicalSize = const Size(360 * 3, 2400 * 3);
        t.view.devicePixelRatio = 3;
        addTearDown(t.view.reset);
        await t.pumpWidget(MaterialApp(
          builder: (c, child) => MediaQuery(
              data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
          home: page,
        ));
        await t.pumpAndSettle();
        expect(find.byType(PregToolScaffold), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    });
  }
}
