// =============================================================================
//  TTC chrome - the things that made the stage look like a different app
// -----------------------------------------------------------------------------
//  None of these is a defect on its own. Together they are why TTC read as a
//  near-miss of the app it lives in:
//
//    * a circular back chip nothing else in the product uses
//    * tiles that were tappable with nothing saying so, and bare labels that
//      left Mood, Stress and Lifestyle indistinguishable
//    * four tiles leading to two destinations, deliberately but invisibly
//    * an ordered five-point scale that wrapped 4 + 1, so the far end of the
//      scale looked like a separate control
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_records_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_supplements_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tracker_screen.dart';
import 'package:parentveda/ttc/ttc_trackers_data.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  Future<void> pumpTall(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1200, 8000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
    await tester.pumpAndSettle();
  }

  // ===========================================================================
  group('the back bar matches the rest of the app', () {
    testWidgets('a bare arrow, not a chip', (tester) async {
      await pumpTall(tester,
          Scaffold(body: TtcBackBar(title: 'Anything', key: UniqueKey())));
      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_back));
      expect(icon.size, 22, reason: 'the chip-sized 17px arrow is back');

      // The circle was the thing that made it look invented. Nothing in the
      // pregnancy stage draws one.
      final circles = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.decoration is BoxDecoration)
          .map((c) => c.decoration as BoxDecoration)
          .where((d) => d.shape == BoxShape.circle);
      expect(circles, isEmpty);
    });

    testWidgets('and it still pops', (tester) async {
      await pumpTall(tester, const TtcToolsScreen());
      await tester.tap(find.text('Open').first);
      await tester.pumpAndSettle();
      expect(find.byType(TtcToolsScreen), findsNothing);
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();
      expect(find.byType(TtcToolsScreen), findsOneWidget);
    });
  });

  // ===========================================================================
  group('every tile says what it is and what tapping does', () {
    test('all of them carry a description in both languages', () {
      for (final g in ttcToolGroups) {
        for (final tool in g.tools) {
          expect(tool.desc(false), isNotEmpty, reason: '${tool.id} English');
          expect(tool.desc(true), isNotEmpty, reason: '${tool.id} Hinglish');
        }
      }
    });

    test('the three that were indistinguishable no longer are', () {
      final all = [for (final g in ttcToolGroups) ...g.tools];
      String d(String id) => all.firstWhere((t) => t.id == id).desc(false);
      expect({d('mood'), d('stress'), d('lifestyle')}.length, 3,
          reason: 'these read as the same tool three times');
    });

    testWidgets('and each tile offers an explicit action', (tester) async {
      await pumpTall(tester, const TtcToolsScreen());
      final tiles = [for (final g in ttcToolGroups) ...g.tools].length;
      expect(find.text('Open'), findsNWidgets(tiles));
    });
  });

  // ===========================================================================
  group('one destination, one tile', () {
    test('the duplicates are gone', () {
      final ids = [for (final g in ttcToolGroups) ...g.tools].map((t) => t.id);
      // Medication opened Supplements; Reports opened Health Records. Correct
      // in code - "one list rather than two that disagree" - and unexplained on
      // screen, so it read as broken routing.
      expect(ids, isNot(contains('medication')));
      expect(ids, isNot(contains('reports')));
    });

    test('and the survivors say they cover both', () {
      final all = [for (final g in ttcToolGroups) ...g.tools];
      final supp = all.firstWhere((t) => t.id == 'supplements');
      final rec = all.firstWhere((t) => t.id == 'records');
      expect(supp.name(false).toLowerCase(), contains('medication'));
      expect(rec.name(false).toLowerCase(), contains('reports'));
    });

    testWidgets('supplements still opens', (tester) async {
      await pumpTall(tester, const TtcToolsScreen());
      await tester.tap(find.text('Supplements & medication'));
      await tester.pumpAndSettle();
      expect(find.byType(TtcSupplementsScreen), findsOneWidget);
    });

    testWidgets('records still opens', (tester) async {
      await pumpTall(tester, const TtcToolsScreen());
      await tester.tap(find.text('Records & reports'));
      await tester.pumpAndSettle();
      expect(find.byType(TtcRecordsScreen), findsOneWidget);
    });

    test('the tile name matches the screen it opens', () {
      // The tile said "Product Guide"; the screen says "Worth knowing about".
      final all = [for (final g in ttcToolGroups) ...g.tools];
      expect(all.firstWhere((t) => t.id == 'guide').name(false),
          'Worth knowing about');
    });
  });

  // ===========================================================================
  group('an ordered scale reads as one scale', () {
    testWidgets('all five options share a single row', (tester) async {
      await pumpTall(tester, TtcTrackerScreen(tracker: ttcTrackerById('symptoms')!));
      // None / A little / Some / A lot / Severe used to wrap 4 + 1, which made
      // the far end of the scale look like a separate control.
      final none = tester.getTopLeft(find.text('None').first);
      final severe = tester.getTopLeft(find.text('Severe').first);
      expect(severe.dy, closeTo(none.dy, 1.0),
          reason: '"Severe" dropped to its own line again');
      expect(severe.dx, greaterThan(none.dx));
    });

    testWidgets('and choosing one still records it', (tester) async {
      await pumpTall(tester, TtcTrackerScreen(tracker: ttcTrackerById('symptoms')!));
      await tester.tap(find.text('Some').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  group('no card lightens toward the bottom of a gradient', () {
    test('every TTC gradient runs toward the deeper shade', () {
      // Seven surfaces ran purple to a LIGHTER purple, and two ran all the way
      // to coral - which is what made TTC read pink beside pregnancy, whose
      // hero runs primary500 to primary700. One constant now, so the next card
      // cannot quietly pick its own.
      final dir = Directory('lib/screens/ttc');
      final offenders = <String>[];
      for (final f in dir.listSync().whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        for (final line in f.readAsLinesSync()) {
          if (!line.contains('colors: [')) continue;
          final ok = line.contains('ttcPurpleDeep') ||
              line.contains('ttcSlateDeep');
          if (!ok) offenders.add('${f.uri.pathSegments.last}: ${line.trim()}');
        }
      }
      expect(offenders, isEmpty,
          reason: 'a gradient is picking its own far colour again');
    });

    test('and coral never appears as a gradient stop', () {
      // It is an accent - eyebrows, the period marker, one soft circle behind
      // the hero. As a gradient stop it turned whole cards pink.
      final dir = Directory('lib/screens/ttc');
      for (final f in dir.listSync().whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        for (final line in f.readAsLinesSync()) {
          if (line.contains('colors: [')) {
            expect(line.contains('ttcCoral'), isFalse,
                reason: '${f.uri.pathSegments.last}: ${line.trim()}');
          }
        }
      }
    });
  });
}
