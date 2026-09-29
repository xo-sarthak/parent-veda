// "If your pregnancy has ended" (2026-09-29, pregnancy gap analysis, "Behind
// · After a loss", P1): the You row exists, confirming swaps her Today for the
// After a loss page and keeps nothing hidden behind a dead end, the undo
// brings the baby home back, and the door is reachable from Complications.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pv_door_after_loss.dart';
import 'package:parentveda/data/doors/pv_door_complications.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_ended_screen.dart';
import 'package:parentveda/screens/profile/pv_you_content.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController pregnancy;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PregnancyEndedStore.instance.resetForTest();
    await PregnancyEndedStore.instance.load();
    pregnancy = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140)));
    await pregnancy.load();
  });

  test('the store persists, and undo clears it', () async {
    expect(PregnancyEndedStore.instance.ended, isFalse);
    await PregnancyEndedStore.instance.markEnded();
    expect(PregnancyEndedStore.instance.ended, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(PregnancyEndedStore.kEndedKey), isTrue);
    PregnancyEndedStore.instance.resetForTest();
    await PregnancyEndedStore.instance.load();
    expect(PregnancyEndedStore.instance.ended, isTrue, reason: 'survives a restart');
    await PregnancyEndedStore.instance.undo();
    expect(PregnancyEndedStore.instance.ended, isFalse);
    expect(prefs.getBool(PregnancyEndedStore.kEndedKey), isFalse);
  });

  test('the row is in the pregnancy You, and nowhere else', () {
    bool has(LifeStage s) =>
        pvYouContentFor(s).things.any((t) => t.title == kPregEndedRowTitle);
    expect(has(LifeStage.pregnancy), isTrue);
    expect(has(LifeStage.tryingToConceive), isFalse);
  });

  testWidgets('confirming shows the After a loss page, with every tab', (tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: PregEndedConfirmScreen(pregnancy: pregnancy)));
    await tester.pump();
    expect(find.text(kPregEndedTitle), findsOneWidget);
    await tester.tap(find.text(kPregEndedConfirm));
    await tester.pumpAndSettle();
    expect(PregnancyEndedStore.instance.ended, isTrue);
    expect(find.byType(PregEndedHome), findsOneWidget);
    expect(find.text(kPregEndedHomeTitle), findsOneWidget);
    for (final g in kAfterLossDoor.groups) {
      expect(find.text(g.label), findsOneWidget, reason: g.id);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('opened again, the same screen offers the undo', (tester) async {
    await PregnancyEndedStore.instance.markEnded();
    await tester.pumpWidget(MaterialApp(home: PregEndedConfirmScreen(pregnancy: pregnancy)));
    await tester.pump();
    expect(find.text(kPregEndedUndoTitle), findsOneWidget);
    await tester.tap(find.text(kPregEndedUndoConfirm));
    await tester.pumpAndSettle();
    expect(PregnancyEndedStore.instance.ended, isFalse);
  });

  test('Complications reaches the door, and every new surface resolves', () {
    final tiles = kComplicationsDoor.allTiles;
    expect(tiles.whereType<PvDoorToolTile>().any((t) => t.surfaceId == kCondSurfaceAfterLoss), isTrue);
    for (final id in [kCondSurfaceAfterLoss, kAfterLossSurfaceTryAgain]) {
      expect(pvDoorSurfaceResolves(id), isTrue, reason: id);
      expect(pvDoorScreenFor(id, pregnancy), isNotNull, reason: id);
    }
  });

  testWidgets('the After a loss door draws every tab in the rail format', (tester) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    for (final g in kAfterLossDoor.groups) {
      await tester.pumpWidget(MaterialApp(
          home: PvDoorScreen(
              key: ValueKey(g.id),
              page: kAfterLossDoor,
              bracket: kPregAfterLossBracket,
              pregnancy: pregnancy,
              initialGroup: g.id)));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull, reason: g.id);
      expect(find.text(kAfterLossDoor.heroTitle, skipOffstage: false), findsWidgets, reason: g.id);
    }
    expect(kPvDoorRailDoors.contains(kPregAfterLossBracket.id), isTrue);
  });
}
