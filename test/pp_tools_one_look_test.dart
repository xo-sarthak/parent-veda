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
  'pp_emergency_card', // the Wallet card, shared with the Health Wallet
  'pp_health_home', // the health record dashboard
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final g in ppToolGroups()) {
    for (final tool in g.tools) {
      if (_shared.contains(tool.surfaceId)) continue;
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
