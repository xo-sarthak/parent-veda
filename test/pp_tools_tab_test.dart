// =============================================================================
//  Parenting Tools tab in the one ParentVeda format (2026-10-07)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/doors/pv_list_row.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tools_tab.dart';
import 'package:parentveda/screens/ttc/ttc_tab_root_header.dart';
import 'package:parentveda/screens/ttc/ttc_tool_marks.dart' show TtcMarkLeading;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('every tool opens a real screen, and no tool is listed twice', () {
    final ids = [for (final g in ppToolGroups()) for (final t in g.tools) t.surfaceId];
    expect(ids.toSet().length, ids.length);
    for (final id in ids) {
      expect(ppScreenForSurface(id), isNotNull, reason: id);
    }
  });

  // The user, 2026-10-24 (tools pass C1): "doors should not cover a new tool
  // that isn't listed in tools section". A door may show a tool; it may never
  // be the only way to find it.
  test('every door tool is also in the Tools tab', () {
    final listed = {for (final g in ppToolGroups()) for (final t in g.tools) t.surfaceId};
    bool allowed(String id) =>
        id == 'pp_recos' || // a shop card, not a tool: Early learning's "Toys and crayons" shelf (tools pass 33; was "reached from Product guide", which it never was)
        id == 'pp_leaps' || // reading in the shared reader, not a tool (tools pass D4, 2026-10-25)
        // You, Maa's "10 minutes for you today" (door 3, M1): it opens a page
        // or a class picked for her week, not a tool of its own.
        id == 'pp_maa_ten_minutes' ||
        id.startsWith('pp_what_changed/'); // the same checker, pre-filtered
    final missing = {
      for (final d in kPpDoors)
        for (final tab in d.tabs)
          for (final t in tab.tools)
            if (!listed.contains(t.surfaceId) && !allowed(t.surfaceId)) '${d.sectionId}: ${t.surfaceId}',
    };
    expect(missing, isEmpty, reason: 'a door offers a tool the Tools tab does not list');
  });

  // The user, 2026-10-25: "make sure the tools section the UI is consistent
  // with marks/glyphs". Every row wears its own drawn mark: none falls back to
  // a disc with an icon, and no two tools share a glyph.
  test('every tool wears its own drawn mark, and no two share one', () {
    final tools = [for (final g in ppToolGroups()) ...g.tools];
    final undrawn = [for (final t in tools) if (t.tab == null && t.tool == null) t.title];
    expect(undrawn, isEmpty, reason: 'a row without a drawn mark falls back to an icon in a disc');
    final seen = <Object, String>{};
    final twice = <String>[];
    for (final t in tools) {
      final key = (t.tab ?? t.tool)!;
      final other = seen[key];
      if (other != null) twice.add('${t.title} and $other');
      seen[key] = t.title;
    }
    expect(twice, isEmpty, reason: 'two tools wear the same glyph');
  });

  testWidgets('every row draws its mark, never a Material icon', (t) async {
    t.view.physicalSize = const Size(360 * 3, 4200 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: ToolsHubScreen()));
    await t.pumpAndSettle();
    final rows = find.byType(PvListRow);
    expect(rows, findsWidgets);
    expect(find.descendant(of: rows, matching: find.byType(TtcMarkLeading)).evaluate().length,
        rows.evaluate().length);
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
