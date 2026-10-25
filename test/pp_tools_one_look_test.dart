// =============================================================================
//  Every parenting tool wears the one ParentVeda tool shell (2026-10-07)
// -----------------------------------------------------------------------------
//  The user: "for parenting the tools section is also very inconsistent ...
//  make that consistent". Each tool on the Tools tab is opened at 360dp and
//  1.5x text and must draw PregToolScaffold (the TTC/pregnancy tool shell),
//  or be one of the shared screens named below, and must not overflow.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tools_tab.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

/// Shared screens with their own, already-common chrome.
const Set<String> _shared = {
  'pp_product_guide', // the unified store
  // Both moved onto the tool shell on 2026-10-21 (Wave 3), so the shell is
  // now checked on them too. Were exempt:
  // 'pp_emergency_card', // the Wallet card, shared with the Health Wallet
  // 'pp_health_home', // the health record dashboard
};

/// ⚠️ OWED, NOT EXEMPT. Door-only tools until 2026-10-24 (tools pass C1), so
/// this test never saw them. Listing them showed they never moved onto the
/// shell. Each moves at its own turn in docs/pp-tool-plans/ and comes off
/// this list then; the test below fails if one wears the shell while still
/// listed, so the list can only shrink.
const Set<String> _owedShell = {
  'pp_sleep_sounds',
  // 'pp_fever_check', // on the shell since 2026-10-25 (tools pass, Health)
  // 'pp_doctor_visit', // on the shell since 2026-10-25 (Wave 3, Health)
  // 'pp_leaps', // not a tool any more: reading, out of the Tools tab (tools pass D4, 2026-10-25)
  'pp_scripts',
  'pp_food_chart',
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final g in ppToolGroups()) {
    for (final tool in g.tools) {
      if (_shared.contains(tool.surfaceId)) continue;
      if (_owedShell.contains(tool.surfaceId)) {
        testWidgets('${tool.title} (${tool.surfaceId}) is still owed the tool shell', (t) async {
          ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 120)));
          t.view.physicalSize = const Size(360 * 3, 2400 * 3);
          t.view.devicePixelRatio = 3;
          addTearDown(t.view.reset);
          await t.pumpWidget(MaterialApp(home: ppScreenForSurface(tool.surfaceId)!));
          await t.pump(const Duration(milliseconds: 600));
          expect(find.byType(PregToolScaffold), findsNothing,
              reason: '${tool.surfaceId} wears the shell now: take it off _owedShell');
          // Only the shell is checked here. Other faults (the doctor visit row
          // overflows at 360dp) are logged in docs/pp-tool-plans/00-MASTER.md
          // for their turns, and come back under the full check above once
          // they move off this list. Sleep Sounds arms the shared player's
          // 20-minute sleep timer on purpose; it outlives the screen, so wait
          // past it.
          t.takeException();
          await t.pumpWidget(const SizedBox());
          await t.pump(const Duration(minutes: 21));
        });
        continue;
      }
      testWidgets('${tool.title} (${tool.surfaceId}) wears the tool shell', (t) async {
        ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 120)));
        t.view.physicalSize = const Size(360 * 3, 2400 * 3);
        t.view.devicePixelRatio = 3;
        addTearDown(t.view.reset);
        await t.pumpWidget(MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: MaterialApp(home: ppScreenForSurface(tool.surfaceId)!),
        ));
        await t.pump(const Duration(milliseconds: 600));
        expect(find.byType(PregToolScaffold), findsWidgets, reason: tool.surfaceId);
        expect(t.takeException(), isNull, reason: tool.surfaceId);
      });
    }
  }
}
