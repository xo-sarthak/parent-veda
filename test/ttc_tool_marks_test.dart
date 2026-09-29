// =============================================================================
//  The Tools tab draws the doors' marks (2026-09-29)
// -----------------------------------------------------------------------------
//  The user on build 18: "in Tools you have used icons, but what we are using
//  is marks, that glyph, very evidently visible as the thumbnail for the doors
//  and inside the doors ... it looks like a different side of the application."
//
//  What this file holds:
//    1. every tool id on the hub (hers and his) and every row that moved to
//       More has a mark, and no two hub rows share one;
//    2. every mark paints, at the row's size and the rail's, without throwing;
//    3. every Tools row renders its drawn mark (found by key) and no Material
//       glyph leads a row: the only Icon in a row is its chevron;
//    4. the hub holds at 360dp and 1.5x text, hers and his;
//    5. the door surfaces that are tools map to the same mark as the hub row;
//    6. every tool's page, opened from its row (hers and his), shows the same
//       mark in its header, and that header holds at 360dp and 1.5x text;
//    7. a TtcToolScaffold with no toolId draws no mark (details and non-tools
//       keep the header they had).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/doors/pv_list_row.dart' show PvMarkWell;
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tool_marks.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

class _NoNet extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => HttpOverrides.global = _NoNet());

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcHomeVersionStore.instance.set(TtcHomeVersion.v3);
    TtcToolRecents.instance.resetForTest();
    TtcPartnerMode.instance.on = false;
  });
  tearDown(() => TtcPartnerMode.instance.on = false);

  List<String> hubIds({required bool him}) => [
        for (final g in ttcToolGroupsFor(him: him))
          for (final t in g.tools) t.id
      ];

  // ---- 1 ---------------------------------------------------------------------
  test('every tool id, hers and his, has a mark', () {
    for (final him in [false, true]) {
      for (final id in hubIds(him: him)) {
        expect(ttcToolMarkFor(id), isNotNull,
            reason: '${him ? 'his' : 'her'} Tools row "$id" has no drawn mark');
      }
    }
    for (final t in ttcMovedToMore) {
      expect(ttcToolMarkFor(t.id), isNotNull,
          reason: 'moved row "${t.id}" has no mark for More to draw');
    }
  });

  test('no two rows on the hub share a mark', () {
    final marks = [for (final id in hubIds(him: false)) ttcToolMarkFor(id)];
    expect(marks.toSet().length, marks.length, reason: '$marks');
  });

  // ---- 2 ---------------------------------------------------------------------
  testWidgets('every mark paints at the row size and the rail size',
      (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Wrap(children: [
        for (final m in TtcToolMark.values)
          for (final (hue, side) in [(172.0, 44.0), (206.0, 48.0), (104.0, 120.0)])
            SizedBox(
              width: side,
              height: side,
              child: TtcToolArt(
                mark: m,
                tint: HSLColor.fromAHSL(1, hue, 0.30, 0.88).toColor(),
              ),
            ),
      ]),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(TtcToolArt),
        findsNWidgets(TtcToolMark.values.length * 3));
  });

  // ---- 3 and 4 ----------------------------------------------------------------
  Future<void> pumpHub(WidgetTester tester,
      {double width = 1200, double textScale = 1.0}) async {
    tester.view.physicalSize = Size(width, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      key: UniqueKey(),
      builder: (c, w) => MediaQuery(
        data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(textScale)),
        child: w!,
      ),
      home: const TtcToolsScreen(),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  for (final him in [false, true]) {
    final who = him ? 'his' : 'her';

    testWidgets('$who rows lead with the drawn mark, never a Material glyph',
        (tester) async {
      TtcPartnerMode.instance.on = him;
      await pumpHub(tester);
      final ids = hubIds(him: him);
      expect(ids, isNotEmpty);
      for (final id in ids) {
        final row = find.byKey(ValueKey('ttc_tool_row_$id'));
        expect(row, findsOneWidget, reason: id);
        expect(
            find.descendant(
                of: row, matching: find.byKey(ValueKey('ttc_tool_mark_$id'))),
            findsOneWidget,
            reason: '$id: no drawn mark in its row');
        expect(
            find.descendant(of: row, matching: find.byType(TtcToolArt)),
            findsOneWidget,
            reason: id);
        // The old square well with a line glyph is gone from every row.
        expect(find.descendant(of: row, matching: find.byType(PvMarkWell)),
            findsNothing,
            reason: id);
        // The only Icon left in a row is its chevron (the row's action).
        final icons = tester
            .widgetList<Icon>(
                find.descendant(of: row, matching: find.byType(Icon)))
            .map((i) => i.icon)
            .toList();
        expect(icons, [Icons.chevron_right_rounded], reason: id);
      }
    });

    for (final scale in [1.0, 1.5]) {
      testWidgets('$who hub holds at 360dp, ${scale}x text', (tester) async {
        TtcPartnerMode.instance.on = him;
        await pumpHub(tester, width: 360, textScale: scale);
        expect(tester.takeException(), isNull);
        for (final id in hubIds(him: him)) {
          final mark = find.byKey(ValueKey('ttc_tool_mark_$id'));
          expect(mark, findsOneWidget, reason: id);
          // The disc keeps its size at any text scale.
          expect(tester.getSize(mark), const Size(44, 44), reason: id);
        }
      });
    }
  }

  // ---- 5 ---------------------------------------------------------------------
  test('a door tool card and the hub row draw the same mark', () {
    const bySurface = {
      'ttc_cycle': 'cycle',
      'ttc_window': 'window',
      'ttc_ovulation': 'ovulation',
      'ttc_symptom_log': 'symptoms',
      'ttc_pcos_check': 'pcos_check',
      'ttc_fertility_help': 'fertility_help',
      'ttc_supplements': 'supplements',
      'ttc_medication': 'medication',
      'ttc_tests': 'tests',
      'ttc_vaccinations': 'vaccinations',
      'ttc_records': 'records',
      'ttc_appointments': 'appointments',
      'ttc_treatment': 'treatment',
      'ttc_treatment/start': 'treatment',
      'ttc_nutrition': 'nutrition',
      'ttc_can_i': 'canI',
      'ttc_precheck': 'precheck',
    };
    bySurface.forEach((surface, id) {
      expect(ttcToolMarkForSurface(surface), ttcToolMarkFor(id),
          reason: surface);
    });
    // Not tools: the door keeps its own drawing.
    for (final s in ['ttc_chat/should_test', 'ttc_read/x', 'ttc_shop']) {
      expect(ttcToolMarkForSurface(s), isNull, reason: s);
    }
  });

  // ---- 6 ---------------------------------------------------------------------
  for (final him in [false, true]) {
    final who = him ? 'his' : 'her';
    for (final (width, scale) in [(1200.0, 1.0), (360.0, 1.5)]) {
      testWidgets(
          '$who tool pages show the mark in the header '
          '(${width.toInt()}dp, ${scale}x)', (tester) async {
        final failures = <String>[];
        for (final id in hubIds(him: him)) {
          TtcPartnerMode.instance.on = him;
          await pumpHub(tester, width: width, textScale: scale);
          final row = find.byKey(ValueKey('ttc_tool_row_$id'));
          await tester.ensureVisible(row);
          await tester.tap(row);
          await tester.pumpAndSettle();
          final err = tester.takeException();
          if (err != null) failures.add('$id threw: $err');
          final mark = find.byKey(ValueKey('ttc_tool_header_mark_$id'));
          if (mark.evaluate().length != 1) {
            failures.add('$id: no header mark on its page');
            continue;
          }
          expect(tester.getSize(mark), const Size(40, 40), reason: id);
          // In the header: the top of the page, not somewhere in the sheet.
          expect(tester.getTopLeft(mark).dy, lessThan(200), reason: id);
        }
        expect(failures, isEmpty);
      });
    }
  }

  // ---- 7 ---------------------------------------------------------------------
  testWidgets('a scaffold without a toolId draws no mark', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: TtcToolScaffold(
        hue: 206,
        eyebrow: 'One medicine',
        title: 'A detail page',
        intro: 'About one item.',
        children: [SizedBox(height: 40)],
      ),
    ));
    await tester.pump();
    expect(find.byType(TtcToolArt), findsNothing);
    await tester.pumpWidget(const MaterialApp(
      home: TtcToolScaffold(
        hue: 206,
        toolId: 'medication',
        eyebrow: 'Medication',
        title: 'The front page',
        intro: 'The tool itself.',
        children: [SizedBox(height: 40)],
      ),
    ));
    await tester.pump();
    expect(find.byKey(const ValueKey('ttc_tool_header_mark_medication')),
        findsOneWidget);
  });
}
