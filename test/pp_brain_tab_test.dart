// =============================================================================
//  The Brain activities tab in the one ParentVeda format (2026-10-07)
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_brain_tab.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_common.dart';
import 'package:parentveda/screens/post_pregnancy/pp_grow_data.dart';
import 'package:parentveda/screens/ttc/ttc_tab_root_header.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('header, today, chips, rail and the bottom bar; 360 at 1.5x', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 300)));
    t.view.physicalSize = const Size(360 * 3, 3200 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MaterialApp(home: PpBrainTabScreen())));
    await t.pumpAndSettle();
    expect(find.byType(TtcTabRootHeader), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_brain_today')), findsOneWidget);
    expect(find.byType(PpBottomNav), findsOneWidget, reason: 'the bar was missing on this tab');
    final second = kGrowCapabilities[1];
    await t.tap(find.byKey(ValueKey('pp_brain_cap_${second.id}')));
    await t.pumpAndSettle();
    expect(find.text(second.promise), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  test('the tab opens the new screen; no review-only version pill', () {
    final src = File('lib/screens/post_pregnancy/pp_common.dart').readAsStringSync();
    expect(src, contains('const PpBrainTabScreen()'));
    expect(File('lib/screens/post_pregnancy/pp_brain_tab.dart').readAsStringSync().contains('GrowVersionPill('), isFalse);
  });
}
