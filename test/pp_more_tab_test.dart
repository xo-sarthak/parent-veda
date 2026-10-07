// =============================================================================
//  The parenting More tab in the one ParentVeda format (2026-10-07)
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_common.dart';
import 'package:parentveda/screens/post_pregnancy/pp_more_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_chrome.dart';
import 'package:parentveda/screens/ttc/ttc_tab_root_header.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('tab header, pregnancy sections and rows, the bar lit on More; 360 at 1.5x', (t) async {
    t.view.physicalSize = const Size(360 * 3, 4200 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MaterialApp(home: PpMoreScreen())));
    await t.pumpAndSettle();
    expect(find.byType(TtcTabRootHeader), findsOneWidget);
    for (final id in ['experts', 'courses', 'groups', 'read_watch', 'journey']) {
      expect(find.byKey(ValueKey('pp_more_$id')), findsOneWidget, reason: id);
    }
    expect(find.byType(PregOfferRow), findsWidgets);
    expect(find.text('Community'), findsNothing);
    expect(find.byType(PpBottomNav), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  test('More is a tab screen with the grid glyph, as in TTC and pregnancy', () {
    final src = File('lib/screens/post_pregnancy/pp_common.dart').readAsStringSync();
    expect(src, contains('const PpMoreScreen()'));
    expect(src, contains("(PpTab.more, Icons.grid_view_outlined, 'More')"));
  });
}
