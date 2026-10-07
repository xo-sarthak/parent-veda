// =============================================================================
//  Parenting Tools tab in the one ParentVeda format (2026-10-07)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/doors/pv_list_row.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tools_tab.dart';
import 'package:parentveda/screens/ttc/ttc_tab_root_header.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('every tool opens a real screen, and no tool is listed twice', () {
    final ids = [for (final g in ppToolGroups()) for (final t in g.tools) t.surfaceId];
    expect(ids.toSet().length, ids.length);
    for (final id in ids) {
      expect(ppScreenForSurface(id), isNotNull, reason: id);
    }
  });

  testWidgets('the TTC tab header, rows with drawn marks; 360 at 1.5x', (t) async {
    t.view.physicalSize = const Size(360 * 3, 2600 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MaterialApp(home: ToolsHubScreen())));
    await t.pumpAndSettle();
    expect(find.byType(TtcTabRootHeader), findsOneWidget);
    expect(find.byType(PvListRow), findsWidgets);
    expect(find.byKey(const ValueKey('pp_tool_pp_vaccines')), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('search by another word finds the tool', (t) async {
    t.view.physicalSize = const Size(1080, 2400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: ToolsHubScreen()));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).first, 'diaper');
    await t.pumpAndSettle();
    expect(find.text('Nappies'), findsOneWidget);
  });
}
