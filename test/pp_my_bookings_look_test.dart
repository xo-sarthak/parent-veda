// =============================================================================
//  MyBookingsScreen on the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  `MyBookingsScreen` is a facade over the unified `PvMyLearningScreen` since
//  2026-09-20, which already wears the shared look; the purple body survives
//  only as `MyBookingsScreenClassic`, kept for revert and pushed by nothing.
//  This holds that the push still lands on the unified screen and that it fits
//  a small phone at large text.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/learn/pv_my_learning_screen.dart';
import 'package:parentveda/screens/post_pregnancy/my_bookings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  testWidgets('lands on the unified screen and fits 360dp at 1.5x', (t) async {
    t.view.physicalSize = const Size(360 * 3, 2400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(360, 2400), textScaler: TextScaler.linear(1.5)),
        child: MyBookingsScreen(),
      ),
    ));
    await t.pump(const Duration(milliseconds: 500));
    expect(t.takeException(), isNull);
    expect(find.byType(PvMyLearningScreen), findsOneWidget);
    expect(find.byType(MyBookingsScreenClassic), findsNothing);
  });
}
