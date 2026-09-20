// =============================================================================
//  Search over the doors — the index is the doors, a hit opens like a tile
// -----------------------------------------------------------------------------
//  Holds the two promises `pv_search_screen.dart` makes: nothing is typed
//  twice (the index is built from `kPvDoorPages`, so a tile added to a door
//  is searchable with no other change), and a miss is never a dead end (the
//  Ask Veda row is there under results and under none). Plus the wiring
//  gate — the bar is on the home and the button on every door.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart';
import 'package:parentveda/screens/search/pv_search_screen.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pv_search_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _phone = Size(360, 780);

Future<void> _pump(WidgetTester tester, {PvDoorPage? door}) async {
  tester.view.physicalSize = _phone;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: PvSearchScreen(pregnancy: PregnancyController(), door: door),
  ));
  await tester.pump();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the index', () {
    test('is every tile on every pregnancy door, plus the doors', () {
      final index = pvSearchIndex();
      final tiles = kPvDoorPages.fold<int>(
          0,
          (n, page) =>
              n +
              page.groups.fold<int>(
                  0,
                  (m, g) =>
                      m +
                      page
                          .sectionsOf(g.id)
                          .expand((s) => s.tiles)
                          .where((t) =>
                              !t.comingSoon && pvDoorTabTarget(t) == null)
                          .length));
      expect(index.where((h) => h.tile == null && h.open == null).length,
          kPvDoorPages.length);
      expect(index.where((h) => h.tile != null).length, tiles);
      expect(tiles, greaterThan(100));
      // The scans door's libraries — findings and report parameters — are
      // in the index since their own search bars went.
      expect(index.where((h) => h.open != null).length, greaterThan(40));
      expect(pvSearch('placenta', index).any((h) => h.open != null), isTrue);
      expect(pvSearch('haemoglobin', index).any((h) => h.open != null), isTrue);
    });

    test('a title match outranks a blurb match, and a door is a hit', () {
      final hits = pvSearch('nt scan', pvSearchIndex());
      expect(hits, isNotEmpty);
      expect(hits.first.title.toLowerCase(), contains('nt'));
      final door = pvSearch('nutrition', pvSearchIndex())
          .firstWhere((h) => h.tile == null);
      expect(door.page.bracketId, 'pregnancy_nutrition');
    });

    test('every word must match; nonsense finds nothing', () {
      expect(pvSearch('zzqx', pvSearchIndex()), isEmpty);
      expect(pvSearch('', pvSearchIndex()), isEmpty);
    });
  });

  group('the screen', () {
    testWidgets('opens on the field with places to start, no purple button',
        (tester) async {
      await _pump(tester);
      expect(find.byKey(kPvSearchFieldKey), findsOneWidget);
      expect(find.text('START WITH'), findsOneWidget);
      // The doors are the places to start on the stage.
      final first = bracketById(kPvDoorPages.first.bracketId)!.label.now;
      expect(find.text(first), findsWidgets);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('typing lists hits, and Ask Veda is the last row',
        (tester) async {
      await _pump(tester);
      await tester.enterText(find.byKey(kPvSearchFieldKey), 'scan');
      await tester.pump();
      expect(find.byKey(pvSearchHitKey(0)), findsOneWidget);
      await tester.dragUntilVisible(find.byKey(kPvSearchAskKey),
          find.byType(ListView), const Offset(0, -300));
      expect(find.byKey(kPvSearchAskKey), findsOneWidget);
    });

    testWidgets('a miss shows the way on, not a dead end', (tester) async {
      await _pump(tester);
      await tester.enterText(find.byKey(kPvSearchFieldKey), 'zzqx');
      await tester.pump();
      expect(find.byKey(pvSearchHitKey(0)), findsNothing);
      expect(find.textContaining('Nothing written'), findsOneWidget);
      expect(find.byKey(kPvSearchAskKey), findsOneWidget);
    });

    testWidgets('from a door it searches that door first, then everywhere',
        (tester) async {
      final door = pvDoorPageFor('pregnancy_scans_tests')!;
      await _pump(tester, door: door);
      expect(find.text('In Scans & tests'), findsOneWidget);
      await tester.enterText(find.byKey(kPvSearchFieldKey), 'sleep');
      await tester.pump();
      // Sleep is not a scans thing — the miss offers the wider search.
      expect(find.text('Search everywhere'), findsOneWidget);
      await tester.tap(find.text('Search everywhere'));
      await tester.pump();
      expect(find.byKey(pvSearchHitKey(0)), findsOneWidget);
    });

    testWidgets('a tapped hit is remembered and opens a screen',
        (tester) async {
      await _pump(tester);
      await tester.enterText(find.byKey(kPvSearchFieldKey), 'scan');
      await tester.pump();
      await tester.tap(find.byKey(pvSearchHitKey(0)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      // The Navigator keeps the search mounted under the pushed route, so
      // the field still exists — it just cannot be reached.
      expect(find.byKey(kPvSearchFieldKey).hitTestable(), findsNothing,
          reason: 'a hit pushes a screen over the search');
      expect(PvSearchStore.instance.recent, contains('scan'));
    });
  });

  group('the wiring', () {
    testWidgets('every door carries the search button', (tester) async {
      tester.view.physicalSize = _phone;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      for (final page in kPvDoorPages) {
        await tester.pumpWidget(MaterialApp(
          home: PvDoorScreen(
            page: page,
            bracket: bracketById(page.bracketId)!,
            pregnancy: PregnancyController(),
          ),
        ));
        await tester.pump();
        expect(find.byKey(kPvDoorSearchKey), findsOneWidget,
            reason: page.bracketId);
      }
    });

    test('the home does NOT mount the bar; every door does', () {
      // The user's call (2026-09-18): search belongs in the door, under its
      // blurb — not between "Start anywhere" and the grid.
      final home = _read('lib/screens/home_v3_screen.dart');
      expect(home, isNot(contains(RegExp(r'^\s+PvSearchBar\(', multiLine: true))));
      final door = _read('lib/screens/doors/pv_door_screen.dart');
      // LIVE since 2026-09-20 (pv_live_search.dart): the field is the door's
      // own, results draw in the sheet, and the pushed screen is the way on
      // ("Search everywhere"). The bar that pushed is a comment now.
      expect(door, contains('PvLiveSearchField('));
      expect(door, contains('openPvSearch(context, widget.pregnancy, query: q)'));
      expect(door, isNot(contains(RegExp(r'^\s+PvSearchBar\(', multiLine: true))));
    });
  });
}

String _read(String path) => File(path).readAsStringSync();
