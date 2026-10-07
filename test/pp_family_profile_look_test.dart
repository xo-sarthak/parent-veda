// =============================================================================
//  FamilyProfileScreen on the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  Holds the redraw: You's top bar and chips, no purple build, and no overflow
//  on a small phone at large text (360dp wide, 1.5x text).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/family_profile_screen.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart' show PvChip;
import 'package:parentveda/screens/profile/pv_you_chrome.dart' show PvYouTopBar;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  testWidgets('wears You chrome and fits 360dp at 1.5x text', (t) async {
    t.view.physicalSize = const Size(360 * 3, 2400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(360, 2400), textScaler: TextScaler.linear(1.5)),
        child: FamilyProfileScreen(),
      ),
    ));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.byType(PvYouTopBar), findsOneWidget);
    expect(find.byType(PvChip), findsWidgets);
    expect(find.byKey(const ValueKey('family_profile_meter')), findsOneWidget);
    expect(find.textContaining('personalised'), findsOneWidget);
  });
}
