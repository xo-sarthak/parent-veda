// =============================================================================
//  Yoga & classes (YogaHomeScreen) in the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  YogaHomeScreen moved onto PregToolScaffold, for both its parenting entrance
//  and the pregnancy Prepare tab's filtered one. The Live / Recorded and Group /
//  1:1 modes still switch the rails, search still finds a class, no star rating
//  is drawn, and nothing overflows at 360dp and 1.5x text.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_yoga_data.dart';
import 'package:parentveda/screens/post_pregnancy/yoga_home_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester t, double scale, Widget home) async {
    t.view.physicalSize = const Size(360 * 3, 2400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      builder: (c, child) =>
          MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
      home: home,
    ));
    await t.pumpAndSettle();
  }

  for (final scale in [1.0, 1.5]) {
    testWidgets('360dp, ${scale}x: no overflow, modes switch, search finds', (t) async {
      await pump(t, scale, const YogaHomeScreen());
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(t.takeException(), isNull);

      for (final k in ['yoga_mode_1to1', 'yoga_mode_recorded', 'yoga_mode_live']) {
        await t.tap(find.byKey(ValueKey(k)));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: k);
      }

      final first = kYogaClasses.first;
      await t.enterText(find.byKey(const ValueKey('yoga_search')), first.title.split(' ').first);
      await t.pumpAndSettle();
      expect(find.byKey(ValueKey('yoga_row_${first.id}')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('360dp, ${scale}x: the pregnancy Prepare entrance builds', (t) async {
      await pump(t, scale, const YogaHomeScreen(categoryFilter: kPregnancyYogaCategories));
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
