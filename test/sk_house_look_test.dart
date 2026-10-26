// =============================================================================
//  The skilling doors in the house look — the contract
// -----------------------------------------------------------------------------
//  2026-10-25, the user: "skilling right now doesn't look like it's from the
//  ParentVeda app". Doors 1 to 3 (Coding, Communication, Confidence) and the
//  shell all seven doors share were brought level with the parenting and
//  pregnancy doors: the flat tab rail, the shelf card, ink for actions, no
//  violet, no pink-purple tabs, no grey or tinted box behind words, the intro
//  video chip and search in the header. This file fails if any of it slips
//  back, and holds the mirrored numbers equal to the house originals.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parentveda/data/doors/sk_door_data.dart';
import 'package:parentveda/screens/doors/pv_door_rail.dart';
import 'package:parentveda/screens/doors/pv_shelf_card.dart';
import 'package:parentveda/screens/skilling/doors/sk_door_chrome.dart';
import 'package:parentveda/screens/skilling/doors/sk_door_screen.dart';
import 'package:parentveda/screens/skilling/sk_child_store.dart';
import 'package:parentveda/screens/skilling/sk_practice_store.dart';
import 'package:parentveda/screens/skilling/sk_surface_router.dart';
import 'package:parentveda/screens/skilling/skilling_preview_screen.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/widgets/pv_door_intro_chip.dart';

/// The source of a file with its comments removed, so a revert note that
/// names an old colour is not read as using it.
String _code(String path) {
  var s = File(path).readAsStringSync();
  s = s.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return s.split('\n').map((l) {
    final i = l.indexOf('//');
    return i < 0 ? l : l.substring(0, i);
  }).join('\n');
}

const _screens = [
  'lib/screens/skilling/doors/sk_door_screen.dart',
  'lib/screens/skilling/doors/sk_door_chrome.dart',
  'lib/screens/skilling/sk_content.dart',
  'lib/screens/skilling/sk_activity_screen.dart',
  'lib/screens/skilling/sk_keepsake_screen.dart',
  'lib/screens/skilling/sk_voice_keepsake.dart',
  'lib/screens/skilling/sk_grown_up_gate.dart',
  'lib/screens/skilling/sk_parent_gate_screen.dart',
  'lib/screens/skilling/sk_grown_up_screen.dart',
  'lib/screens/skilling/sk_access_screen.dart',
];

void main() {
  group('the source', () {
    test('no violet, no SnackBar on any screen the doors open', () {
      final hits = <String>[];
      for (final f in _screens) {
        final c = _code(f);
        for (final bad in ['p.action', '0xFF6A30B6', 'SnackBar(']) {
          if (c.contains(bad)) hits.add('$f: $bad');
        }
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });

    test('the door screen draws the house rail and shelf card, not the deck', () {
      final c = _code('lib/screens/skilling/doors/sk_door_screen.dart');
      expect(c.contains('SkDoorRail('), isTrue);
      expect(c.contains('SkShelfCard('), isTrue);
      expect(c.contains('SkDoorCarousel('), isFalse, reason: 'the coverflow deck is kept for revert only');
      expect(c.contains('PvDoorIntroChip('), isTrue);
      expect(c.contains('PvLiveSearchField('), isTrue);
    });

    test('every stage door header carries the intro chip', () {
      for (final f in [
        'lib/screens/doors/pv_door_screen.dart',
        'lib/screens/ttc/doors/ttc_door_screen.dart',
        'lib/screens/post_pregnancy/doors/pp_door_screen.dart',
        'lib/screens/skilling/doors/sk_door_screen.dart',
      ]) {
        expect(_code(f).contains('PvDoorIntroChip('), isTrue, reason: f);
      }
    });
  });

  group('the mirrored numbers', () {
    test('the rail is PvDoorRail, value for value', () {
      expect(SkDoorRail.cardWidth, PvDoorRail.cardWidth);
      expect(SkDoorRail.cardHeight, PvDoorRail.cardHeight);
      expect(SkDoorRail.markSize, PvDoorRail.markSize);
      expect(SkDoorRail.overlap, PvDoorRail.overlap);
      for (final s in [1.0, 1.3, 2.0]) {
        final scaler = TextScaler.linear(s);
        expect(SkDoorRail.heightFor(scaler), PvDoorRail.heightFor(scaler));
        expect(SkDoorRail.heightFor(scaler, withLine: true),
            PvDoorRail.heightFor(scaler, withLine: true));
      }
    });

    test('the shelf card is PvShelfCard, value for value', () {
      expect(kSkShelfCardWidth, kPvShelfCardWidth);
      expect(kSkShelfPictureHeight, kPvShelfPictureHeight);
      for (final s in [1.0, 1.3, 2.0]) {
        expect(skShelfRailHeight(TextScaler.linear(s)),
            pvShelfRailHeight(TextScaler.linear(s)));
      }
    });
  });

  group('the colours', () {
    test('no door paints a tab violet, purple or pink, and no two tabs share a hue', () {
      for (final d in kSkDoors) {
        final hues = skHouseHues([for (final t in d.tabs) t.hue]);
        for (final h in hues) {
          expect(h >= 250 && h <= 350, isFalse, reason: '${d.doorId}: $h');
        }
        expect(hues.toSet().length, hues.length, reason: '${d.doorId}: $hues');
      }
    });

    test('every tab of every door has a drawn mark', () {
      for (final d in kSkDoors) {
        for (final t in d.tabs) {
          expect(skTabMarkOn(d, t), isNotNull, reason: '${d.doorId}/${t.id}');
        }
      }
    });
  });

  group('on screen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      SkChildStore.instance.debugReset();
    });

    for (final id in ['skilling_coding', 'skilling_communication', 'skilling_confidence']) {
      testWidgets('$id: rail, shelf cards, intro chip and search; no violet text', (tester) async {
        tester.view.physicalSize = const Size(1200, 6000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        SkChildStore.instance.debugSetAgeYears(7, name: 'Aarav');
        final door = kSkDoors.firstWhere((d) => d.doorId == id);
        await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
        await tester.pumpAndSettle();

        expect(find.byType(SkDoorRail), findsOneWidget);
        expect(find.byType(SkShelfCard), findsWidgets);
        expect(find.byKey(kPvDoorIntroChipKey), findsOneWidget);
        expect(find.text('COMING SOON'), findsOneWidget);
        expect(find.byKey(const Key('sk-door-search')), findsOneWidget);

        const violet = Color(0xFF6A30B6);
        final violetText = tester
            .widgetList<Text>(find.byType(Text))
            .where((t) => t.style?.color == violet)
            .map((t) => t.data)
            .toList();
        expect(violetText, isEmpty);
      });
    }

    testWidgets('the intro chip says the video is being made, not nothing', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SkChildStore.instance.debugSetAgeYears(7, name: 'Aarav');
      final door = kSkDoors.firstWhere((d) => d.doorId == 'skilling_coding');
      await tester.pumpWidget(MaterialApp(home: SkDoorScreen(door: door, onSurface: (_, _) {})));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(kPvDoorIntroChipKey));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(kPvDoorIntroSoonLine), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });
  });

  // ===========================================================================
  //  THE HOME (2026-10-26, prototype 1wkwCdtNts4X1z9FYi4tek)
  // ===========================================================================
  group('the home', () {
    const home = 'lib/screens/skilling/skilling_preview_screen.dart';

    test('the house sections, not the design preview', () {
      final c = _code(home);
      for (final want in [
        "'My daily insights'",
        "'Explore by topic'",
        "'Right now'",
        "'For the grown-up'",
        'PvInsightRail(',
        'PvRowGroup(',
        'PvNavBar(',
        "meta: skDoorFor(b.id) == null ? 'Soon' : null",
        'v2BlockTint(skHouseHue(b.hue), p)',
        'v3FieldChroma(186)',
      ]) {
        expect(c.contains(want), isTrue, reason: want);
      }
      for (final gone in [
        'DESIGN PREVIEW',
        '_PreviewBanner(p: p)',
        '_CompassCard(p: p',
        "'Two things settled first'",
        'PLANNED  ·  NONE OF IT BUILT',
        'v3FieldChroma(258)',
      ]) {
        expect(c.contains(gone), isFalse, reason: gone);
      }
    });

    test('the bar has the five tabs, in order', () {
      final c = _code(home);
      var at = 0;
      for (final (icon, label) in [
        ('home_outlined', 'Today'),
        ('menu_book_outlined', 'Learn'),
        ('shopping_basket_outlined', 'Products'),
        ('handyman_outlined', 'Tools'),
        ('grid_view_outlined', 'More'),
      ]) {
        final i = c.indexOf("PvNavItem(Icons.$icon, '$label')", at);
        expect(i, greaterThan(-1), reason: label);
        at = i;
      }
    });

    test('no tile is violet, purple or pink, and no tile matches its neighbour', () {
      expect(skHouseHue(344), 56);
      expect(skHouseHue(268), 128);
      expect(skHouseHue(288), 146);
      expect(skHouseHue(320), 80);
      final hues = [for (final b in bracketsFor(LifeStage.skilling)) skHouseHue(b.hue)];
      expect(hues, hasLength(12));
      for (final h in hues) {
        expect(h >= 250 && h <= 350, isFalse, reason: '$h');
      }
      // Four to a row on the grid.
      for (var i = 0; i < hues.length; i++) {
        if (i % 4 != 3) expect(hues[i], isNot(hues[i + 1]), reason: 'tile $i');
        if (i + 4 < hues.length) expect(hues[i], isNot(hues[i + 4]), reason: 'tile $i');
      }
    });

    test('every row the tab pages open is a route that exists', () {
      for (final id in [
        'sk_settings/skilling_coding',
        'sk_record/skilling_confidence',
        'sk_voice/skilling_communication',
        'sk_keepsake/skilling_coding',
        'sk_lessons/skilling_coding',
        'sk_products/skilling_coding',
        'sk_grown_up/skilling_confidence',
      ]) {
        expect(skRouterKnows(id), isTrue, reason: id);
      }
    });

    group('on screen', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
        SkChildStore.instance.debugReset();
        SkPracticeStore.instance.debugReset();
      });

      Future<void> pumpHome(WidgetTester tester) async {
        tester.view.physicalSize = const Size(412, 3200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        SkChildStore.instance.debugSetAgeYears(7, name: 'Aarav');
        await tester.pumpWidget(const MaterialApp(home: SkillingPreviewScreen()));
        await tester.pump(const Duration(seconds: 2));
      }

      testWidgets('hero, today, the grid with Soon, the empty line, the grown-up rows', (tester) async {
        await pumpHome(tester);
        expect(find.text("Aarav's learning space"), findsOneWidget);
        expect(find.text('Age 7 · twelve skills to practise, nothing scored'), findsOneWidget);
        expect(find.text('MY DAILY INSIGHTS'), findsOneWidget);
        expect(find.text('Explore by topic'), findsOneWidget);
        for (final d in ['skilling_coding', 'skilling_communication', 'skilling_confidence']) {
          expect(find.byKey(ValueKey('sk_today_$d')), findsOneWidget, reason: d);
          expect(find.byKey(ValueKey('sk_grown_up_$d')), findsOneWidget, reason: d);
        }
        expect(find.text('Soon'), findsNWidgets(5));
        expect(find.byKey(const ValueKey('sk_tried_empty')), findsOneWidget);
        expect(find.text('What Aarav tried lately'), findsOneWidget);
        expect(find.text('Help Aarav at home'), findsOneWidget);
        expect(find.byKey(const ValueKey('sk_nav_bar')), findsOneWidget);
      });

      testWidgets('something tried shows as a row, in words', (tester) async {
        SkChildStore.instance.debugSetAgeYears(7, name: 'Aarav');
        SkPracticeStore.instance.record(
            doorId: 'skilling_coding', itemId: 'x1', title: 'Be My Robot', kind: SkPractice.tried);
        await pumpHome(tester);
        expect(find.byKey(const ValueKey('sk_tried_empty')), findsNothing);
        expect(find.text('Be My Robot'), findsOneWidget);
      });

      testWidgets('an unbuilt skill opens its plan sheet', (tester) async {
        await pumpHome(tester);
        await tester.tap(find.text('Focus'));
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('COMING SOON'), findsOneWidget);
        expect(find.text('What it will hold'), findsOneWidget);
      });

      testWidgets('the bar opens the four tab pages', (tester) async {
        await pumpHome(tester);
        final bar = find.byKey(const ValueKey('sk_nav_bar'));
        for (final (tab, title) in [
          ('Learn', 'Lessons for Aarav'),
          ('Products', 'Things that help'),
          ('Tools', 'Tools for practice'),
          ('More', "Aarav's space"),
        ]) {
          await tester.tap(find.descendant(of: bar, matching: find.text(tab)));
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.text(title), findsOneWidget, reason: tab);
        }
        await tester.tap(find.descendant(of: bar, matching: find.text('Today')));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text("Aarav's learning space"), findsOneWidget);
      });
    });
  });
}
