// =============================================================================
//  The Trying store has the stage switch under its search bar (2026-10-02).
//
//  The user, on the TTC product section: "under the search bar we don't have the
//  Trying, Pregnancy, Parenting options available to switch stores."
//
//  The Trying store used to draw nothing there (the 2026-09-30 decision, after the
//  "Other stages" link was called abrupt). It now draws the same `PvStageSwitch`
//  as every other store, so whichever stage she is on, the other two stores are one
//  tap away. This holds that on the real screen, at every entry the TTC app has to
//  its store, and that the switch really switches.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/pv_product.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart';
import 'package:parentveda/screens/products/pv_store_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pv_catalog_store.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> pump(WidgetTester t, Widget w, {double width = 390, double scale = 1}) async {
    t.view.physicalSize = Size(width * 2, 2600 * 2);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      onGenerateRoute: (s) => MaterialPageRoute<void>(
        settings: s,
        builder: (c) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
          child: w,
        ),
      ),
    ));
    await t.pump(const Duration(milliseconds: 500));
    await t.pump(const Duration(milliseconds: 500));
  }

  final trying = LifeStage.tryingToConceive.shopLabel;
  final preg = LifeStage.pregnancy.shopLabel;
  final parent = LifeStage.parenting.shopLabel;

  group('every way into the Trying store shows the three stages', () {
    final entries = <String, Widget>{
      'embedded (the app tab)': const PvStoreScreen(
          chrome: PvStoreChrome.embedded, initialStage: LifeStage.tryingToConceive),
      'the TTC chrome': const PvStoreScreen(chrome: PvStoreChrome.ttc),
      'no chrome, opened on Trying': const PvStoreScreen(
          chrome: PvStoreChrome.none, initialStage: LifeStage.tryingToConceive),
    };
    for (final e in entries.entries) {
      testWidgets(e.key, (t) async {
        await pump(t, e.value);
        expect(find.byType(PvStageSwitch), findsOneWidget);
        for (final w in [trying, preg, parent]) {
          expect(find.text(w), findsWidgets, reason: 'no "$w" in the switch');
        }
        // The old quiet link is not what draws.
        expect(find.byKey(const ValueKey('pv_store_other_stages')), findsNothing);
        expect(t.takeException(), isNull);
      });
    }
  });

  testWidgets('it sits under the search pill, not above it', (t) async {
    await pump(t, const PvStoreScreen(chrome: PvStoreChrome.ttc));
    final sw = t.getTopLeft(find.byType(PvStageSwitch)).dy;
    // The search pill says what it searches; it is the first thing above the switch.
    final search = find.byWidgetPredicate((w) =>
        w is Text && (w.data ?? '').toLowerCase().startsWith('search'));
    expect(search, findsWidgets);
    expect(t.getTopLeft(search.first).dy, lessThan(sw));
  });

  testWidgets('tapping Pregnancy switches the store, and Trying switches back',
      (t) async {
    await pump(t, const PvStoreScreen(
        chrome: PvStoreChrome.ttc, initialStage: LifeStage.tryingToConceive));
    final before = t.widget<PvStageSwitch>(find.byType(PvStageSwitch)).stage;
    expect(before, LifeStage.tryingToConceive);
    await t.tap(find.descendant(
        of: find.byType(PvStageSwitch), matching: find.text(preg)));
    // The store cross-fades, so two switches are briefly in the tree: let it finish.
    await t.pump(const Duration(milliseconds: 500));
    await t.pump(const Duration(milliseconds: 800));
    expect(t.widget<PvStageSwitch>(find.byType(PvStageSwitch)).stage,
        LifeStage.pregnancy);
    await t.tap(find.descendant(
        of: find.byType(PvStageSwitch), matching: find.text(trying)));
    // The store cross-fades, so two switches are briefly in the tree: let it finish.
    await t.pump(const Duration(milliseconds: 500));
    await t.pump(const Duration(milliseconds: 800));
    expect(t.widget<PvStageSwitch>(find.byType(PvStageSwitch)).stage,
        LifeStage.tryingToConceive);
    expect(t.takeException(), isNull);
  });

  testWidgets('the other stores are unchanged: pregnancy and parenting keep it',
      (t) async {
    await pump(t, const PvStoreScreen(chrome: PvStoreChrome.none, initialStage: LifeStage.pregnancy));
    expect(find.byType(PvStageSwitch), findsOneWidget);
    await pump(t, const PvStoreScreen(chrome: PvStoreChrome.none, initialStage: LifeStage.parenting));
    expect(find.byType(PvStageSwitch), findsOneWidget);
  });

  testWidgets('holds at 1.5x text on a narrow phone', (t) async {
    await pump(t, const PvStoreScreen(chrome: PvStoreChrome.ttc), width: 360, scale: 1.5);
    expect(find.byType(PvStageSwitch), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  test('the early return that drew nothing for Trying is not live code', () {
    final live = _code('lib/screens/products/pv_store_screen.dart');
    expect(live, isNot(contains('if (_stage == LifeStage.tryingToConceive) return const SizedBox.shrink();')));
    expect(live, isNot(contains("ValueKey('pv_store_other_stages')")));
    expect(live, contains('PvStageSwitch('));
    // Keep the catalogue import honest: this test needs the store loaded.
    expect(PvCatalogStore.instance, isNotNull);
    expect(LifeStageStore.instance, isNotNull);
  });
}
