// =============================================================================
//  The parenting journal on the shared tool shell (2026-10-07)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/journal_v2/pp_journal_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final scale in [1.0, 1.5]) {
    testWidgets('shell, the ink add button, no overflow at 360dp ${scale}x', (t) async {
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: const MaterialApp(home: PpJournalScreen())));
      await t.pumpAndSettle();
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_journal_add')), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing, reason: 'no purple floating button');
      expect(t.takeException(), isNull);
    });
  }
}
