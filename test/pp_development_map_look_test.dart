// =============================================================================
//  The Development Map in the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  DevelopmentMapScreen moved onto PregToolScaffold. "You are here" still
//  marks the current band, a band still opens its sheet, and nothing overflows
//  at 360dp and 1.5x text.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/development_map_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final scale in [1.0, 1.5]) {
    testWidgets('360dp, ${scale}x: no overflow, a band opens its sheet', (t) async {
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
        home: const DevelopmentMapScreen(),
      ));
      await t.pumpAndSettle();
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(find.text('YOU ARE HERE'), findsOneWidget);
      expect(t.takeException(), isNull);

      final band = find.byKey(const ValueKey('devmap_band_7'));
      await t.ensureVisible(band);
      await t.pumpAndSettle(); // the scroll lands on the next frame
      await t.tap(band);
      await t.pumpAndSettle();
      expect(find.text('What tends to blossom'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
