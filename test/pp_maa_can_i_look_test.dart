// =============================================================================
//  "Can I...?" for the mother, in the shared look (gap analysis P2)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_maa_can_i_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the tool shell, the store chips, a search that answers; 360 at 1.5x', (t) async {
    t.view.physicalSize = const Size(360 * 3, 2400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MaterialApp(home: PpMaaCanIScreen(initialQuery: 'chai'))));
    await t.pumpAndSettle();
    expect(find.byType(PregToolScaffold), findsOneWidget);
    expect(find.byType(PvChip), findsWidgets);
    expect(find.textContaining('Can I '), findsWidgets);
    expect(t.takeException(), isNull);
  });
}
