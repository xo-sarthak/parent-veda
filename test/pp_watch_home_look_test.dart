// =============================================================================
//  The parenting films library in the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  WatchHomeScreen (More > All films) is drawn as pregnancy's Watch library
//  (WatchLearnScreen): serif title, section headings, white hairline cards,
//  ink chips and an ink "Watch now". Quick / Deep still switches the picks;
//  nothing overflows at 360dp and 1.5x text.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/watch_home_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final scale in [1.0, 1.5]) {
    testWidgets('360dp, ${scale}x: no overflow, Quick Learn switches the picks', (t) async {
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
        home: const WatchHomeScreen(),
      ));
      await t.pumpAndSettle();
      expect(find.text('Learn something today'), findsOneWidget);
      expect(find.text('Watch now'), findsOneWidget);
      expect(t.takeException(), isNull);

      await t.scrollUntilVisible(find.text('Expert collections'), 300,
          scrollable: find.byType(Scrollable).first, maxScrolls: 40);
      expect(t.takeException(), isNull);

      await t.scrollUntilVisible(find.text('Quick Learn'), -300,
          scrollable: find.byType(Scrollable).first, maxScrolls: 40);
      await t.tap(find.text('Quick Learn'));
      await t.pumpAndSettle();
      await t.scrollUntilVisible(find.text('Quick lessons for you'), 300,
          scrollable: find.byType(Scrollable).first, maxScrolls: 40);
      expect(t.takeException(), isNull);
    });
  }
}
