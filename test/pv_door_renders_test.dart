// =============================================================================
//  The Scans door actually builds
// -----------------------------------------------------------------------------
//  ⚠️ THE OTHER HALF OF THE WIRING GATE, AND `pv_door_scans_test.dart` CANNOT
//  DO THIS. That file proves the DATA is correct: five tabs declared, every id
//  resolving, every section owned by a group. All of it stays true if the
//  screen never renders a tab at all.
//
//  This drives the real widget. If the carousel is not built, if a tool tab
//  draws no tool, or if a rail overflows at phone width, it fails here and
//  nowhere else.
//
//  ⚠️ EVERYTHING RUNS AT 360×780. Every overflow this app has shipped was found
//  at phone width or not at all — 360dp is the standard Android baseline and
//  the width most budget Indian handsets report. The default test surface is
//  800×600, which is a shape no user has.
//
//  Widget tests also render with a fallback font far wider than Manrope, which
//  is a feature here: it surfaces missing `Flexible` before a device does.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/screens/doors/pv_door_carousel.dart';
import 'package:parentveda/screens/doors/pv_door_chips.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart';
import 'package:parentveda/screens/doors/pv_door_rail.dart';
import 'package:parentveda/screens/doors/pv_door_tiles.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

/// The narrowest screen this app is designed against.
const Size _phone = Size(360, 780);

/// Reach tab [i] on a door — through its dot on the deck, or its chip.
Finder _tab(String bracketId, int i) => kPvDoorChipDoors.contains(bracketId)
    ? find.byKey(pvDoorChipKey(i))
    : find.byKey(pvDoorDotKey(i));

/// Reach tab [i]. On a chip door: scroll the chip into view and tap it. On
/// the deck (no dots since 2026-09-18): step the ring through its side
/// zones, one tap at a time — the way a thumb does it.
Future<void> _goTab(WidgetTester tester, String bracketId, int i) async {
  if (kPvDoorRailDoors.contains(bracketId)) {
    final f = find.byKey(pvDoorRailCardKey(i));
    await tester.ensureVisible(f);
    await tester.pump();
    await tester.tap(f);
    await tester.pump();
    return;
  }
  if (kPvDoorTileDoors.contains(bracketId)) {
    final f = find.byKey(pvDoorTileKey(i));
    await tester.ensureVisible(f);
    await tester.pump();
    await tester.tap(f);
    await tester.pump();
    return;
  }
  if (kPvDoorChipDoors.contains(bracketId)) {
    final f = _tab(bracketId, i);
    await tester.ensureVisible(f);
    await tester.pump();
    await tester.tap(f);
    await tester.pump();
    return;
  }
  final door = pvDoorPageFor(bracketId)!;
  var at = _selectedOf(tester);
  final n = door.groups.length;
  // Shortest way round the ring.
  var forward = (i - at) % n;
  var back = (at - i) % n;
  final dir = forward <= back ? 1 : -1;
  var steps = forward <= back ? forward : back;
  while (steps-- > 0) {
    await tester.tap(find.byKey(pvDoorZoneKey(dir)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }
}

int _selectedOf(WidgetTester tester) =>
    tester.widget<PvDoorCarousel>(find.byType(PvDoorCarousel)).selected;

Future<void> _pump(WidgetTester tester,
    [String bracketId = 'pregnancy_scans_tests']) async {
  tester.view.physicalSize = _phone;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final door = pvDoorPageFor(bracketId)!;
  final bracket = bracketById(bracketId)!;

  await tester.pumpWidget(MaterialApp(
    home: PvDoorScreen(
      page: door,
      bracket: bracket,
      pregnancy: PregnancyController(),
    ),
  ));
  // ⚠️ `pump`, NOT `pumpAndSettle`. The hero loads a network image, which in a
  // test never resolves, and the carousel's settle controller can be mid-glide
  // — `pumpAndSettle` would wait for a frame that is not coming.
  await tester.pump();
}

void main() {
  _everyDoor();

  testWidgets('the door opens on My scans, with the timeline on it',
      (tester) async {
    await _pump(tester);

    // The hero line the brief asks to keep.
    expect(find.text('Your scans, in one place.'), findsOneWidget);

    // The bracket's own name is still on screen, above it — which is what
    // answers the "tapped one name, landed on another" objection.
    expect(find.text('SCANS & TESTS'), findsOneWidget);

    // ⚠️ THE TIMELINE ITSELF, NOT A CARD THAT OPENS IT. "WHERE YOU ARE" is the
    // timeline body's own eyebrow and appears nowhere else in the app, so
    // finding it proves the tool is rendered in place rather than linked to.
    // Since the 2026-09-18 redraw the timeline opens on its "Up next" card.
    expect(find.textContaining('UP NEXT'), findsOneWidget);

    // And the footer line the brief says to keep unchanged.
    expect(find.textContaining('the usual run, not a rule'), findsWidgets);
  });

  testWidgets('the selector is the carousel, with a dot per tab',
      (tester) async {
    // Complications is on the tile row (2026-09-18); the deck is judged on a
    // door that still has it.
    await _pump(tester, 'pregnancy_nutrition');

    // ⚠️ THE WIDGET, NOT THE DATA. A test can prove the door declares five
    // groups and prove nothing at all about which control draws them.
    expect(find.byKey(kPvDoorCarouselKey), findsOneWidget);

    // No dots since 2026-09-18 — the neighbours peek, which is the indicator.
    expect(find.byKey(pvDoorDotKey(0)), findsNothing);

    // Both side targets exist. Without them the track is a picture — the cards
    // are under an IgnorePointer and cannot be tapped.
    expect(find.byKey(pvDoorZoneKey(-1)), findsOneWidget);
    expect(find.byKey(pvDoorZoneKey(1)), findsOneWidget);
  });

  testWidgets('every tab can be reached and draws its own content',
      (tester) async {
    await _pump(tester);
    final door = pvDoorPageFor('pregnancy_scans_tests')!;

    for (var i = 1; i < door.groups.length; i++) {
      // The dot is the one-tap route to any tab, including the back pair.
      await _goTab(tester, 'pregnancy_scans_tests', i);
      await tester.pump(const Duration(milliseconds: 500)); // the settle

      final g = door.groups[i];
      for (final s in door.sectionsOf(g.id)) {
        expect(find.text(s.heading), findsOneWidget,
            reason: 'tab "${g.label}" is open and its section '
                '"${s.heading}" is not on screen.');
      }
    }
  });

  testWidgets('the Talk tab shows the red flag whole, above everything',
      (tester) async {
    await _pump(tester);
    final door = pvDoorPageFor('pregnancy_scans_tests')!;
    final talk = door.groups.indexWhere((g) => g.id == kScansTabTalk);

    await _goTab(tester, 'pregnancy_scans_tests', talk);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Call your doctor if'), findsOneWidget);

    // ⚠️ EVERY LINE, NOT A SELECTION. Shoulder-tip pain is the classic sign of
    // a ruptured ectopic and is the entry a layout compromise drops first.
    for (final line in kScanUrgentSignsEn) {
      expect(find.text(line.text), findsOneWidget,
          reason: 'a red-flag line is missing: ${line.text}');
    }
  });

  testWidgets('a coming-soon card is drawn and is not tappable',
      (tester) async {
    await _pump(tester);
    final door = pvDoorPageFor('pregnancy_scans_tests')!;
    final scan = door.groups.indexWhere((g) => g.id == kScansTabScan);

    await _goTab(tester, 'pregnancy_scans_tests', scan);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // The section it lives in is on screen.
    expect(find.text('Before any scan'), findsOneWidget);

    // ⚠️ IT HOLDS ITS PLACE AT FULL SIZE. The rule at the head of
    // `pv_placeholders.dart`: a placeholder occupies the real geometry, so
    // nothing on the rail moves the day the piece lands.
    final card = find.ancestor(
      of: find.text('What the scan person can and cannot tell you'),
      matching: find.byType(InkWell),
    );
    expect(card, findsWidgets);

    // Tapping it must not push anything.
    await tester.tap(card.first, warnIfMissed: false);
    await tester.pump();
    expect(find.text('Your scans, in one place.'), findsOneWidget,
        reason: 'a coming-soon card navigated away.');
  });

  testWidgets('nothing overflows at 360dp on any tab', (tester) async {
    await _pump(tester);
    final door = pvDoorPageFor('pregnancy_scans_tests')!;

    // ⚠️ A RENDER OVERFLOW IS AN EXCEPTION, NOT A FAILED EXPECTATION. It paints
    // a yellow stripe and reports through `FlutterError.onError`, so a widget
    // test that never asks will pass over a broken layout.
    for (var i = 0; i < door.groups.length; i++) {
      if (i > 0) {
        await _goTab(tester, 'pregnancy_scans_tests', i);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(tester.takeException(), isNull,
          reason: 'tab "${door.groups[i].label}" overflows at 360dp.');
    }
  });
}

// =============================================================================
//  Every door, not just the first
// -----------------------------------------------------------------------------
//  ⚠️ THESE WALK `kPvDoorPages`, so a door registered later inherits them
//  without anybody remembering. The data tests already do that; this is the
//  same guarantee for the things only a real build can show — a tab that draws
//  nothing, or a rail that overflows at phone width.
// =============================================================================

void _everyDoor() {
  for (final door in kPvDoorPages) {
    final name = door.bracketId;

    testWidgets('$name opens on its first tab and draws it', (tester) async {
      await _pump(tester, name);
      expect(find.text(door.heroTitle), findsOneWidget);
      // The selector is the deck, or — on the doors in `kPvDoorChipDoors`
      // (the §2.8 comparison, 2026-09-18) — the chip row. Either way every
      // tab has one tappable handle.
      final rail = kPvDoorRailDoors.contains(name);
      final tiles = kPvDoorTileDoors.contains(name);
      final chips = kPvDoorChipDoors.contains(name);
      expect(
          find.byKey(rail
              ? kPvDoorRailKey
              : tiles
                  ? kPvDoorTilesKey
                  : chips
                      ? kPvDoorChipsKey
                      : kPvDoorCarouselKey),
          findsOneWidget);
      if (rail) {
        for (var i = 0; i < door.groups.length; i++) {
          expect(find.byKey(pvDoorRailCardKey(i)), findsOneWidget);
        }
      } else if (tiles) {
        for (var i = 0; i < door.groups.length; i++) {
          expect(find.byKey(pvDoorTileKey(i)), findsOneWidget);
        }
      } else if (chips) {
        for (var i = 0; i < door.groups.length; i++) {
          expect(find.byKey(pvDoorChipKey(i)), findsOneWidget);
        }
      } else {
        expect(find.byKey(pvDoorZoneKey(-1)), findsOneWidget);
        expect(find.byKey(pvDoorZoneKey(1)), findsOneWidget);
      }
    });

    testWidgets('$name: every tab draws its own sections', (tester) async {
      await _pump(tester, name);
      for (var i = 0; i < door.groups.length; i++) {
        if (i > 0) {
          await _goTab(tester, name, i);
          await tester.pump(const Duration(milliseconds: 500));
        }
        final g = door.groups[i];
        for (final s in door.sectionsOf(g.id)) {
          expect(find.text(s.heading), findsOneWidget,
              reason: '$name / "${g.label}": section "${s.heading}" is not on '
                  'screen while that tab is open.');
        }
      }
    });

    testWidgets('$name: a written section is a list, a mixed one is a rail',
        (tester) async {
      // ⚠️ THE LAYOUT RULE, 2026-09-19 (it replaced 2026-09-11's "every
      // section is a rail, even a section of one"). A section whose tiles
      // are ALL written — article, guide, read, myth-fact — draws as a
      // vertical list of rows with a thumbnail; a section with a tool, a
      // film, a checklist or a person in it keeps the rail. Decided on the
      // phone from Complications' three rails of identical "Article" cards,
      // against Mobbin (Equinox, Alan, Gentler Streak, Liven list same-kind
      // articles; Clue and Atoms rail mixed content). So the number of
      // horizontal ListViews on a tab is the number of MIXED sections, and
      // every written section is present as its rows.
      await _pump(tester, name);
      for (var i = 0; i < door.groups.length; i++) {
        if (i > 0) {
          await _goTab(tester, name, i);
          await tester.pump(const Duration(milliseconds: 500));
        }
        final g = door.groups[i];
        final sections = door.sectionsOf(g.id);
        final mixed = sections.where((s) =>
            s.inlineSurfaceId == null &&
            s.tiles.isNotEmpty &&
            !s.tiles.every(pvDoorTileIsWritten));
        // An inline tool may draw a horizontal list of its own (Garbh's
        // ritual rail does); it is counted as at most one per inline
        // section, and never as a section rail.
        final inlineRails = sections.where((s) => s.inlineSurfaceId != null).length;
        final rails = find.byWidgetPredicate((w) =>
            w is ListView && w.scrollDirection == Axis.horizontal);
        final n = tester.widgetList(rails).length;
        expect(n >= mixed.length && n <= mixed.length + inlineRails, isTrue,
            reason: '$name / "${g.label}": ${mixed.length} mixed sections must '
                'draw ${mixed.length} rails (found $n, with $inlineRails inline '
                'tools that may add one each).');
        // And every written section is rows: its first tile's title is on
        // the page as a row title, not inside a horizontal list.
        for (final sec in sections) {
          if (sec.inlineSurfaceId != null || sec.tiles.isEmpty) continue;
          if (!sec.tiles.every(pvDoorTileIsWritten)) continue;
          final first = sec.tilesFor(20).first;
          final inRail = find.descendant(of: rails, matching: find.text(first.title));
          expect(inRail, findsNothing,
              reason: '$name / "${g.label}" / "${sec.heading}" is all written '
                  'and must be a list, not a rail.');
        }
      }
    });

    testWidgets('$name: nothing overflows at 360dp on any tab',
        (tester) async {
      await _pump(tester, name);
      for (var i = 0; i < door.groups.length; i++) {
        if (i > 0) {
          await _goTab(tester, name, i);
          await tester.pump(const Duration(milliseconds: 500));
        }
        expect(tester.takeException(), isNull,
            reason: '$name / "${door.groups[i].label}" overflows at 360dp.');
      }
    });

    testWidgets('$name: every pinned flag renders every line', (tester) async {
      await _pump(tester, name);
      for (var i = 0; i < door.groups.length; i++) {
        final flag = door.groups[i].pinnedRedFlag;
        if (flag == null) continue;
        if (i > 0) {
          await _goTab(tester, name, i);
          await tester.pump(const Duration(milliseconds: 500));
        }
        expect(find.text(flag.title), findsOneWidget);
        for (final line in flag.lines) {
          expect(find.text(line.text), findsOneWidget,
              reason: '$name: a red-flag line is missing: ${line.text}');
        }
      }
    });
  }
}
