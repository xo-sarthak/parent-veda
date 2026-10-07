// =============================================================================
//  Grow: the "We did it" acknowledgement in the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  GrowCompletedScreen moved onto PregToolScaffold. Both readings (V2's streak,
//  V3's week) render without overflow at 360dp and 1.5x text, and tomorrow's
//  activity still opens.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/grow_v2_screens.dart';
import 'package:parentveda/screens/post_pregnancy/pp_grow_data.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => GrowVersionStore.instance.setVersion(GrowVersion.v1));

  for (final v in [GrowVersion.v2, GrowVersion.v3]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('$v at 360dp, ${scale}x: no overflow, tomorrow opens', (t) async {
        GrowVersionStore.instance.setVersion(v);
        t.view.physicalSize = const Size(360 * 3, 2400 * 3);
        t.view.devicePixelRatio = 3;
        addTearDown(t.view.reset);
        await t.pumpWidget(MaterialApp(
          builder: (c, child) => MediaQuery(
              data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
          home: GrowCompletedScreen(activity: kGrowActivities.first),
        ));
        await t.pumpAndSettle();
        expect(find.byType(PregToolScaffold), findsOneWidget);
        expect(t.takeException(), isNull);
        expect(find.text(v == GrowVersion.v2 ? 'Great job' : "That's done"), findsOneWidget);

        final row = find.byKey(const ValueKey('grow_completed_tomorrow'));
        await t.ensureVisible(row);
        await t.pumpAndSettle();
        await t.tap(row);
        await t.pumpAndSettle();
        expect(find.byType(GrowActivityScreen), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    }
  }
}
