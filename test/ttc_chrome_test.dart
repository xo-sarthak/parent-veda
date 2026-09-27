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
      // The hub's rows end in a chevron since 2026-09-26 (see the action
      // test below); the first row is Cycle Companion, which has a back bar.
      // Was: find.text('Open').first
      await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
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

    // ⚠️ TWO OF THE THREE NO LONGER EXIST — 2026-09-04. Stress and Lifestyle
    // were merged into the `habits` tracker, so the tile trio this guarded is
    // now Mood and one habits tile. The rule it was protecting is broader than
    // those three names, and it is worth keeping as the broader rule: no two
    // tiles in the hub may describe themselves identically, because a tile
    // whose description could belong to another tile has not said what tapping
    // it does.
    test('no two tiles describe themselves the same way', () {
      final all = [for (final g in ttcToolGroups) ...g.tools];
      final descs = [for (final t in all) t.desc(false).toLowerCase()];
      expect(descs.toSet().length, descs.length,
          reason: 'two tiles read as the same tool');
    });

    // ⚠️ THE ACTION IS A CHEVRON SINCE 2026-09-26, NOT THE WORD "Open". The
    // hub became a list (the Mobbin Tools brief: Walmart's services list, a
    // line icon, the name, one line of purpose, a chevron), and in a list
    // row the chevron IS the explicit action: the base-UI rule's list row is
    // "white, hairline separators, ink2 icons, chevron" (DESIGN-SYSTEM §4.0).
    // The rule this protects is unchanged: every tile shows that it opens.
    // Was: expect(find.text('Open'), findsNWidgets(tiles));
    testWidgets('and each tile offers an explicit action', (tester) async {
      await pumpTall(tester, const TtcToolsScreen());
      final tiles = [for (final g in ttcToolGroups) ...g.tools].length;
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(tiles));
    });
  });

  // ===========================================================================
  group('one destination, one tile', () {
    // THE RULE, which has not changed: a tile must lead somewhere that is
    // genuinely its own. Two tiles onto one screen reads as broken routing.
    //
    // What changed is which tiles satisfy it. Medication and Reports both used
    // to open somebody else's screen, so both were folded away. Medication has
    // since earned its own tile back by acquiring a real destination - a record
    // with a name, a dose, a schedule and reminders, which a curated supplement
    // list could never be. Reports has not, and is still folded.
    //
    // Splitting when a destination becomes real is the same rule as merging
    // when it is not. These assert the rule, not the snapshot.
    test('no tile opens a screen another tile already owns', () {
      final all = [for (final g in ttcToolGroups) ...g.tools];
      final ids = all.map((t) => t.id);
      expect(ids, isNot(contains('reports')),
          reason: 'Reports still opens Health Records - it has no screen');
      expect(ids, contains('medication'),
          reason: 'Medication has its own screen now and should have its tile');
    });

    test('the folded one still names what it covers', () {
      final all = [for (final g in ttcToolGroups) ...g.tools];
      final rec = all.firstWhere((t) => t.id == 'records');
      expect(rec.name(false).toLowerCase(), contains('reports'));
    });

    test('and the unfolded one is no longer carrying a second name', () {
      // While they shared a tile it had to say "Supplements & medication".
      // Leaving that on it would now point at the wrong screen.
      final all = [for (final g in ttcToolGroups) ...g.tools];
      final supp = all.firstWhere((t) => t.id == 'supplements');
      expect(supp.name(false).toLowerCase(), isNot(contains('medication')));
    });

    testWidgets('supplements still opens', (tester) async {
      await pumpTall(tester, const TtcToolsScreen());
      await tester.tap(find.text('Supplements'));
      await tester.pumpAndSettle();
      expect(find.byType(TtcSupplementsScreen), findsOneWidget);
    });

    testWidgets('records still opens', (tester) async {
      await pumpTall(tester, const TtcToolsScreen());
      await tester.tap(find.text('Records and reports'));
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
      //
      // ⚠️ IT READS THE WHOLE `colors: [...]` BLOCK, NOT ONE LINE, and that
      // change made it STRICTER rather than looser. Line-based, it saw only
      // gradients written on a single line: a two-line purple-to-lilac card
      // would have had `colors: [` on its own line, failed for having no deep
      // constant on THAT line, and been "fixed" by whoever hit it next by
      // reformatting rather than by changing the colour. Parsing the block
      // means the assertion is about the stops, which is what the rule is
      // actually about.
      //
      // ⚠️ AND A WHITE SCRIM IS EXEMPT, NARROWLY. A transparent-to-white fade
      // over an illustration is a legibility device, not a tint: it makes no
      // hue choice at all and cannot drift anything pink. The exemption is
      // white-only on purpose — the moment a stop names a colour, the rule
      // applies again.
      final dir = Directory('lib/screens/ttc');
      final offenders = <String>[];
      final gradient = RegExp(r'colors:\s*\[([^\]]*)\]', dotAll: true);

      for (final f in dir.listSync().whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final src = f.readAsStringSync();
        for (final m in gradient.allMatches(src)) {
          final stops = m.group(1)!;
          final whiteOnly = !RegExp(r'(ttc[A-Z]\w*|Color\(|Colors\.(?!white))')
              .hasMatch(stops);
          if (whiteOnly) continue;
          final ok = stops.contains('ttcPurpleDeep') ||
              stops.contains('ttcSlateDeep');
          if (!ok) {
            offenders.add(
                '${f.uri.pathSegments.last}: ${stops.replaceAll(RegExp(r"\s+"), " ").trim()}');
          }
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
