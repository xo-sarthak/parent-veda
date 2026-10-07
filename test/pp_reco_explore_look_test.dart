// =============================================================================
//  Recommendations (RecoExploreScreen) in the one ParentVeda look (2026-10-07)
// -----------------------------------------------------------------------------
//  RecoExploreScreen and its "See all" page moved onto PregToolScaffold. No
//  star rating or "Expert pick" badge is drawn (no real rating stands behind
//  them), a card still saves through RecoStore, search still finds, "See all"
//  still opens the section, and nothing overflows at 360dp and 1.5x text.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_reco_data.dart';
import 'package:parentveda/screens/post_pregnancy/reco_explore_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester t, double scale, Widget home) async {
    t.view.physicalSize = const Size(360 * 3, 2400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      builder: (c, child) =>
          MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
      home: home,
    ));
    await t.pumpAndSettle();
  }

  for (final scale in [1.0, 1.5]) {
    testWidgets('360dp, ${scale}x: home builds, no ratings, search finds', (t) async {
      await pump(t, scale, const RecoExploreScreen());
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(find.text('Expert pick'), findsNothing);
      expect(find.text('Recommended for you'), findsOneWidget);
      expect(t.takeException(), isNull);

      final first = kReco.first;
      await t.enterText(find.byKey(const ValueKey('reco_search')), first.title);
      await t.pumpAndSettle();
      expect(find.byKey(ValueKey('reco_row_${first.id}')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('360dp, ${scale}x: See all page, list and grid', (t) async {
      final section = kRecoSections.firstWhere((s) => s.items.isNotEmpty);
      await pump(t, scale, RecoCategoryScreen(section: section));
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(find.text('Top rated'), findsNothing);
      expect(t.takeException(), isNull);
      await t.tap(find.byKey(const ValueKey('reco_view_toggle')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  }
}
