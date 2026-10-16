// =============================================================================
//  The Yoga & fitness hub (YogaHomeScreen) in the one ParentVeda look
// -----------------------------------------------------------------------------
//  2026-10-07: YogaHomeScreen moved onto PregToolScaffold.
//  2026-10-16: it became the ONE Yoga & fitness hub for all three stages. The
//  inline Live / Recorded and Group / 1:1 toggles became the floating Filter
//  pill and its sheet (Peloton, Tonal), and For you / All came in. This holds:
//  every stage's For you builds, All switches chips, the filter narrows and
//  clears, search finds a class, no star rating is drawn, and nothing overflows
//  at 360dp and 1.5x text.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_yoga_data.dart';
import 'package:parentveda/screens/post_pregnancy/yoga_home_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart';
import 'package:parentveda/services/life_stage_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LifeStageStore.instance.resetForTest();
  });

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
    testWidgets('360dp, ${scale}x: All, chips, filter, search', (t) async {
      await pump(t, scale, const YogaHomeScreen(startOnAll: true));
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(find.byKey(const ValueKey('move_filter_pill')), findsOneWidget);
      expect(t.takeException(), isNull);

      for (final k in ['move_chip_prenatal', 'move_chip_fertility', 'move_chip_core', 'move_chip_all']) {
        await t.ensureVisible(find.byKey(ValueKey(k)));
        await t.tap(find.byKey(ValueKey(k)));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: k);
      }

      // The filter sheet narrows, and "Clear all" brings everything back.
      await t.tap(find.byKey(const ValueKey('move_filter_pill')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('move_filter_liveOneToOne')));
      await t.pumpAndSettle();
      await t.tap(find.textContaining('Show '));
      await t.pumpAndSettle();
      expect(find.text('Filter · 1'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('move_clear_all')));
      await t.pumpAndSettle();
      expect(find.text('Filter'), findsOneWidget);
      expect(t.takeException(), isNull);

      final first = kYogaClasses.first;
      await t.enterText(find.byKey(const ValueKey('yoga_search')), first.title.split(' ').first);
      await t.pumpAndSettle();
      expect(find.byKey(ValueKey('move_row_${first.id}')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    for (final stage in [LifeStage.tryingToConceive, LifeStage.pregnancy, LifeStage.parenting]) {
      testWidgets('360dp, ${scale}x: For you builds for ${stage.name}', (t) async {
        LifeStageStore.instance.setStage(stage);
        await pump(t, scale, const YogaHomeScreen());
        expect(find.byType(PregToolScaffold), findsOneWidget);
        expect(find.byKey(const ValueKey('move_seg_foryou')), findsOneWidget);
        expect(t.takeException(), isNull);
        if (stage == LifeStage.tryingToConceive) {
          expect(find.byKey(const ValueKey('move_today_card')), findsOneWidget);
        }
        if (stage == LifeStage.pregnancy) {
          // No due date in a test: month 1, and it says so rather than guessing.
          expect(find.textContaining('Add your due date to see your month'), findsOneWidget);
        }
        if (stage == LifeStage.parenting) {
          expect(find.byKey(const ValueKey('move_tool_kegel'), skipOffstage: false), findsOneWidget);
        }
      });
    }
  }
}
