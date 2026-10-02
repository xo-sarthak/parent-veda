// =============================================================================
//  Settings > Preferences: "Ask Veda button" shows or hides the floating
//  button for the whole app (2026-10-02).
//
//  The user: "add a button in settings to hide it, same for the whole app on
//  each side, especially TTC and pregnancy."
//
//  One Settings page serves every stage, so one switch. This holds: the switch is
//  on Settings for pregnancy and for trying to conceive; turning it off hides the
//  button (FabState.visible) and is remembered on the phone; turning it on shows
//  it again.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/profile/pv_settings_screen.dart';
import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/widgets/global_ask_fab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    PregnancyEndedStore.instance.resetForTest();
    await PregnancyEndedStore.instance.load();
    final pregnancy = PregnancyController(
        dueDate: DateTime.now().add(const Duration(days: 140)));
    await pregnancy.load();
    PregnancyController.current = pregnancy;
    await FabState.instance.setHiddenByHer(false);
  });

  Future<void> openSettings(WidgetTester t, LifeStage stage) async {
    t.view.physicalSize = const Size(390, 9000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(key: UniqueKey(), home: PvYouScreen(stage: stage)));
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(kPvProfileSettingsRowKey));
    await t.tap(find.byKey(kPvProfileSettingsRowKey));
    await t.pumpAndSettle();
    expect(find.byType(PvSettingsScreen), findsOneWidget);
  }

  for (final stage in [LifeStage.pregnancy, LifeStage.tryingToConceive]) {
    testWidgets('${stage.name}: the switch is in Settings and hides the button',
        (t) async {
      FabState.instance.markAppLive();
      await openSettings(t, stage);
      final row = find.byKey(const ValueKey('pv_settings_ask_veda_button'));
      expect(row, findsOneWidget);
      expect(find.text('Ask Veda button'), findsOneWidget);
      expect(FabState.instance.visible, isTrue);

      final sw = find.descendant(of: row, matching: find.byType(Switch));
      await t.ensureVisible(sw);
      await t.tap(sw);
      await t.pump(const Duration(milliseconds: 300));
      expect(FabState.instance.hiddenByHer, isTrue);
      expect(FabState.instance.visible, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(FabState.kHiddenKey), isTrue);

      await t.tap(sw);
      await t.pump(const Duration(milliseconds: 300));
      expect(FabState.instance.visible, isTrue);
      expect(prefs.getBool(FabState.kHiddenKey), isFalse);
      await t.pump(const Duration(seconds: 5));
    });
  }
}
