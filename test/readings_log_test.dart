// The blood pressure and sugar log (2026-09-30, gap analysis P2): it keeps her
// numbers, shows them back, shares them, and never judges one.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/tools/readings_log_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/readings_store.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the store', () {
    test('keeps readings newest first and mints its own ids', () {
      final s = ReadingsStore.forTest();
      final a = s.add(kind: ReadingKind.bloodPressure, at: DateTime(2026, 9, 1, 8), systolic: 118, diastolic: 76);
      final b = s.add(kind: ReadingKind.bloodPressure, at: DateTime(2026, 9, 2, 8), systolic: 122, diastolic: 80);
      expect(s.of(ReadingKind.bloodPressure).map((r) => r.id), [b.id, a.id]);
      expect(a.id, startsWith('rd_'));
      expect(a.id, isNot(b.id));
      expect(s.of(ReadingKind.sugar), isEmpty);
    });

    test('a sugar reading with no context is filed as Other, a pressure one has none', () {
      final s = ReadingsStore.forTest();
      expect(s.add(kind: ReadingKind.sugar, at: DateTime.now(), mgdl: 100).context, SugarContext.other);
      expect(s.add(kind: ReadingKind.bloodPressure, at: DateTime.now(), systolic: 110, diastolic: 70).context, isNull);
    });

    test('a value no person has is not plausible; a real emergency reading still is', () {
      Reading bp(int s, int d) =>
          Reading(id: 'x', kind: ReadingKind.bloodPressure, at: DateTime.now(), systolic: s, diastolic: d);
      expect(bp(1180, 76).plausible, isFalse, reason: 'a slipped finger');
      expect(bp(76, 118).plausible, isFalse, reason: 'numbers the wrong way round');
      expect(bp(118, 76).plausible, isTrue);
      expect(bp(180, 120).plausible, isTrue, reason: 'a severe reading must be loggable');
      Reading sugar(int v) => Reading(id: 'x', kind: ReadingKind.sugar, at: DateTime.now(), mgdl: v);
      expect(sugar(5).plausible, isFalse);
      expect(sugar(96).plausible, isTrue);
      expect(sugar(380).plausible, isTrue);
    });

    test('round-trips through json, and one bad row does not lose the rest', () {
      final s = ReadingsStore.forTest();
      s.add(kind: ReadingKind.sugar, at: DateTime(2026, 9, 3, 7), mgdl: 92, context: SugarContext.fasting, note: 'before tea');
      s.setTargets(const ReadingTargets(sysUnder: 140, diaUnder: 90, fastingUnder: 95));
      final blob = jsonDecode(jsonEncode(s.cloudData())) as Map;
      (blob['entries'] as List).add({'nonsense': true});
      final t = ReadingsStore.forTest()..applyCloudData(blob);
      expect(t.of(ReadingKind.sugar).single.note, 'before tea');
      expect(t.of(ReadingKind.sugar).single.context, SugarContext.fasting);
      expect(t.targets.pressureLine, 'Under 140/90');
    });

    test("the doctor's target is printed as hers and compared with nothing", () {
      const t = ReadingTargets(fastingUnder: 95, afterFoodUnder: 140);
      expect(t.sugarLine, 'Fasting under 95, after food under 140 (mg/dL)');
      expect(const ReadingTargets().pressureLine, isNull);
      expect(const ReadingTargets().isEmpty, isTrue);
    });

    test('the summary for her doctor lists the numbers and adds no verdict', () {
      final s = ReadingsStore.forTest()
        ..setTargets(const ReadingTargets(sysUnder: 140, diaUnder: 90))
        ..add(kind: ReadingKind.bloodPressure, at: DateTime(2026, 9, 1, 8, 5), systolic: 118, diastolic: 76, note: 'rested');
      final text = s.summary(ReadingKind.bloodPressure);
      expect(text, contains('118/76'));
      expect(text, contains('01/09/2026 08:05'));
      expect(text, contains('rested'));
      expect(text.toLowerCase(), contains('the target my doctor gave me: under 140/90'));
      for (final verdict in ['high', 'low', 'normal', 'abnormal', 'healthy', 'dangerous', 'good', 'bad']) {
        expect(text.toLowerCase(), isNot(contains(verdict)), reason: verdict);
      }
    });
  });

  group('the screen', () {
    late PregnancyController c;
    setUp(() => c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140))));

    Future<void> pump(WidgetTester t, ReadingsStore s) async {
      t.view.physicalSize = const Size(360, 1400);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(home: ReadingsLogScreen(controller: c, store: s)));
      await t.pump(const Duration(milliseconds: 300));
    }

    testWidgets('empty: an invitation that says what it is for, with one way to add', (t) async {
      await pump(t, ReadingsStore.forTest());
      expect(find.byKey(const ValueKey('readings_empty')), findsOneWidget);
      expect(find.byKey(const ValueKey('readings_add_first')), findsOneWidget);
      expect(find.byKey(const ValueKey('preg_tool_header_mark')), findsOneWidget);
      expect(find.textContaining('builds the record your doctor'), findsOneWidget);
      expect(find.text('Share with my doctor'), findsNothing, reason: 'nothing to share yet');
      expect(t.takeException(), isNull);
    });

    testWidgets('adding a pressure reading shows it back in ink, with no verdict', (t) async {
      final s = ReadingsStore.forTest();
      await pump(t, s);
      await t.tap(find.byKey(const ValueKey('readings_add_first')));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const ValueKey('reading_sys')), '124');
      await t.enterText(find.byKey(const ValueKey('reading_dia')), '82');
      await t.tap(find.byKey(const ValueKey('reading_save')));
      await t.pumpAndSettle();
      expect(s.of(ReadingKind.bloodPressure).single.valueText, '124/82');
      expect(find.byKey(const ValueKey('readings_latest')), findsOneWidget);
      expect(find.text('124/82'), findsWidgets);
      expect(find.text('Share with my doctor'), findsOneWidget);
      expect(find.text('Signs to get help the same day'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('a slipped-finger number is asked about, not saved', (t) async {
      final s = ReadingsStore.forTest();
      await pump(t, s);
      await t.tap(find.byKey(const ValueKey('readings_add_first')));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const ValueKey('reading_sys')), '1240');
      await t.enterText(find.byKey(const ValueKey('reading_dia')), '82');
      await t.tap(find.byKey(const ValueKey('reading_save')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('reading_error')), findsOneWidget);
      expect(s.of(ReadingKind.bloodPressure), isEmpty);
    });

    testWidgets('sugar takes a context, and the doctor target sits beside the last reading', (t) async {
      final s = ReadingsStore.forTest()..setTargets(const ReadingTargets(fastingUnder: 95));
      await pump(t, s);
      await t.tap(find.byKey(const ValueKey('readings_kind_sugar')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('readings_add_first')));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const ValueKey('reading_sugar')), '101');
      await t.tap(find.byKey(const ValueKey('reading_ctx_afterFood')));
      await t.tap(find.byKey(const ValueKey('reading_save')));
      await t.pumpAndSettle();
      final r = s.of(ReadingKind.sugar).single;
      expect(r.mgdl, 101);
      expect(r.context, SugarContext.afterFood);
      expect(find.textContaining("Your doctor's target: fasting under 95"), findsOneWidget);
      expect(find.text('Signs to get help the same day'), findsNothing, reason: 'a pressure link, not a sugar one');
    });

    testWidgets('tapping a row edits it and it can be deleted', (t) async {
      final s = ReadingsStore.forTest();
      final r = s.add(kind: ReadingKind.bloodPressure, at: DateTime.now(), systolic: 110, diastolic: 70);
      await pump(t, s);
      await t.tap(find.byKey(ValueKey('reading_row_${r.id}')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('reading_delete')));
      await t.pumpAndSettle();
      expect(s.of(ReadingKind.bloodPressure), isEmpty);
    });

    testWidgets('fits at 320 wide with large text', (t) async {
      final s = ReadingsStore.forTest()
        ..add(kind: ReadingKind.bloodPressure, at: DateTime.now(), systolic: 118, diastolic: 76, note: 'after a long walk to the clinic and back');
      t.view.physicalSize = const Size(320, 900);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        home: MediaQuery(
            data: const MediaQueryData(size: Size(320, 900), textScaler: TextScaler.linear(1.3)),
            child: ReadingsLogScreen(controller: c, store: s)),
      ));
      await t.pump(const Duration(milliseconds: 300));
      expect(t.takeException(), isNull);
    });
  });

  group('it is reachable, and never judges', () {
    test('the Complications door and the Tools list both open it', () {
      final tiles = kComplicationsDoor.allTiles;
      expect(tiles.whereType<PvDoorToolTile>().any((t) => t.surfaceId == kCondSurfaceReadings), isTrue);
      expect(pvDoorSurfaceResolves(kCondSurfaceReadings), isTrue);
      expect(_code('lib/screens/doors/pv_door_router.dart'), contains('kCondSurfaceReadings => ReadingsLogScreen('));
      expect(_code('lib/screens/tools_hub_screen.dart'), contains('ReadingsLogScreen(controller: controller)'));
    });

    test('nothing in the log colours or names a reading as high, low or normal', () {
      for (final f in ['lib/screens/tools/readings_log_screen.dart', 'lib/services/readings_store.dart']) {
        final src = _code(f).toLowerCase();
        for (final banned in ['colors.red', 'colors.green', 'secondary600', "'high'", "'low'", "'normal'", 'abnormal']) {
          expect(src, isNot(contains(banned)), reason: '$f: $banned');
        }
      }
    });
  });
}
