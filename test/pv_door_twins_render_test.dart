// Twins and more is not a home tile (2026-09-29), so the door-wide render
// tests that walk kPvDoorPages never draw it. This does, tab by tab, and holds
// that Scans & tests and Labour prep both reach it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/doors/pv_door_twins.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController pregnancy;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    pregnancy = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140)));
    await pregnancy.load();
  });

  testWidgets('every tab draws in the rail format', (tester) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    for (final g in kTwinsDoor.groups) {
      await tester.pumpWidget(MaterialApp(
          home: PvDoorScreen(
              key: ValueKey(g.id),
              page: kTwinsDoor,
              bracket: kPregTwinsBracket,
              pregnancy: pregnancy,
              initialGroup: g.id)));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull, reason: g.id);
    }
    expect(kPvDoorRailDoors.contains(kPregTwinsBracket.id), isTrue);
  });

  test('Scans & tests and Labour prep both open it', () {
    bool reaches(PvDoorPage d) => d.allTiles
        .whereType<PvDoorToolTile>()
        .any((t) => t.surfaceId == kTwinsSurfaceDoor);
    expect(reaches(kScansDoor), isTrue);
    expect(reaches(kLabourDoor), isTrue);
    expect(pvDoorScreenFor(kTwinsSurfaceDoor, pregnancy), isNotNull);
  });
}
