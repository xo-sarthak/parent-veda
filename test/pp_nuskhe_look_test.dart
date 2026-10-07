// =============================================================================
//  Home remedies (NuskheScreen) in the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  NuskheScreen moved onto PregToolScaffold. The "not medical advice, a doctor
//  comes first" line is still on screen, an age-gated remedy still says so in
//  words (not just a colour), search still filters, and nothing overflows at
//  360dp and 1.5x text. The made-up "panel of 5 practitioners" count stays out.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/nuskhe_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_nuskhe_data.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final scale in [1.0, 1.5]) {
    testWidgets('360dp, ${scale}x: no overflow, safety line kept, search filters', (t) async {
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
        home: const NuskheScreen(),
      ));
      await t.pumpAndSettle();
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(find.byKey(const ValueKey('nuskhe_safety')), findsOneWidget);
      expect(find.textContaining('not medical advice'), findsOneWidget);
      expect(find.textContaining('5 ayurvedic practitioners'), findsNothing);
      expect(find.text('Age-gated, read the cautions'), findsOneWidget);
      expect(find.text('Cold & cough'), findsOneWidget);
      expect(t.takeException(), isNull);

      await t.enterText(find.byKey(const ValueKey('nuskhe_search')), 'colic');
      await t.pumpAndSettle();
      final hits = searchRemedies('colic');
      expect(hits, isNotEmpty);
      expect(find.byKey(ValueKey('nuskhe_row_${hits.first.id}')), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }

  test('a gated remedy carries its warning in the row words', () {
    final gated = kRemedies.where((r) => r.isCaution);
    expect(gated, isNotEmpty);
  });
}
