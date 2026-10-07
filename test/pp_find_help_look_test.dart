// =============================================================================
//  Find help (ProblemSolverScreen) in the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  Moved onto PregToolScaffold. The needs list, a search with matches and a
//  search with none all render without overflow at 360dp and 1.5x text, and a
//  need still opens its results.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_experts_data.dart';
import 'package:parentveda/screens/post_pregnancy/problem_solver_screen.dart';
import 'package:parentveda/screens/post_pregnancy/provider_results_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final scale in [1.0, 1.5]) {
    testWidgets('360dp, ${scale}x: needs, matches, no match, a need opens', (t) async {
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
        home: const ProblemSolverScreen(),
      ));
      await t.pumpAndSettle();
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(find.text(kFindHelpNeeds.first.label), findsOneWidget);
      expect(t.takeException(), isNull);

      final search = find.byKey(const ValueKey('find_help_search'));
      await t.enterText(search, 'a');
      await t.pumpAndSettle();
      expect(find.textContaining('MATCHING EXPERT'), findsOneWidget);
      expect(t.takeException(), isNull);

      await t.enterText(search, 'zzzzqq');
      await t.pumpAndSettle();
      expect(find.textContaining('No experts match'), findsOneWidget);
      expect(t.takeException(), isNull);

      await t.enterText(search, '');
      await t.pumpAndSettle();
      final need = find.byKey(ValueKey('find_help_need_${kFindHelpNeeds.first.category}'));
      await t.ensureVisible(need);
      await t.pumpAndSettle();
      await t.tap(need);
      await t.pumpAndSettle();
      expect(find.byType(ProviderResultsScreen), findsOneWidget);
    });
  }
}
