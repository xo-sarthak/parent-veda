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
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
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

/// Opens the folded warning-signs row into its sheet, and returns the finder
/// for the sheet (2026-10-02: the signs are folded, as TTC's doors fold them).
Future<Finder> _openFlag(WidgetTester tester) async {
  final row = find.byKey(kPvDoorFlagRowKey);
  await tester.ensureVisible(row);
  await tester.pump();
  await tester.tap(row);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  return find.byType(BottomSheet);
}

/// Closes the sheet again, by its route, so the next tab can be reached.
Future<void> _closeSheet(WidgetTester tester) async {
  Navigator.of(tester.element(find.byType(BottomSheet))).pop();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

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
    // The quiet hero (2026-10-02) draws the door's name as its title, in the
    // case the tile has it. Kept for revert: the caps eyebrow 'SCANS & TESTS'.
    expect(find.byKey(kPvDoorHeroTitleKey), findsOneWidget);
    expect(find.text('Scans & tests'), findsWidgets);

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
    // Complications is on the tile row (2026-09-18) and Nutrition joined the
    // rail doors (2026-09-20); the deck is judged on a door that still has it.
    //
    // 2026-09-29, the structure pass: Belly & skin, Labour and Mind & mood
    // moved to the rail, which left no pregnancy door on the deck. The deck
    // stays built (kept for revert), so this judges it on whichever door is
    // put back on it, and until then holds the other half of the promise:
    // every door is on the benchmark rail. Was: _pump(tester, 'pregnancy_belly_skin').
    final onDeck = [
      for (final d in kPvDoorPages)
        if (!kPvDoorRailDoors.contains(d.bracketId) &&
            !kPvDoorTileDoors.contains(d.bracketId) &&
            !kPvDoorChipDoors.contains(d.bracketId))
          d.bracketId,
    ];
    if (onDeck.isEmpty) {
      for (final d in kPvDoorPages) {
        expect(kPvDoorRailDoors.contains(d.bracketId), isTrue, reason: d.bracketId);
      }
      return;
    }
    await _pump(tester, onDeck.first);

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
        expect(
            s.folded
                ? find.text('${s.heading}  ·  ${s.tiles.length}')
                : find.text(s.heading),
            findsOneWidget,
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

    // Folded (2026-10-02): the tab opens on one row, first on the tab, and
    // the sheet it opens carries the whole flag.
    expect(find.text('Call your doctor if'), findsOneWidget);
    expect(find.byKey(kPvDoorFlagRowKey), findsOneWidget);

    // ⚠️ EVERY LINE, NOT A SELECTION. Shoulder-tip pain is the classic sign of
    // a ruptured ectopic and is the entry a layout compromise drops first.
    final sheet = await _openFlag(tester);
    for (final line in kScanUrgentSignsEn) {
      expect(find.descendant(of: sheet, matching: find.text(line.text)),
          findsOneWidget,
          reason: 'a red-flag line is missing: ${line.text}');
    }
  });

  testWidgets('a coming-soon card is drawn and is not tappable',
      (tester) async {
    // ⚠️ 2026-09-29: the Scans door's own coming-soon card ("What the scan
    // person can and cannot tell you") was written and is now a live read
    // (see the next test). The rule this test holds is about the TILE KIND,
    // not that one card, so it now draws the Scans door with a stand-in
    // coming-soon card in the same section and checks the same things.
    tester.view.physicalSize = _phone;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final real = pvDoorPageFor('pregnancy_scans_tests')!;
    const stand = 'A piece still being written';
    final page = PvDoorPage(
      bracketId: real.bracketId,
      heroTitle: real.heroTitle,
      heroBlurb: real.heroBlurb,
      heroImageUrl: real.heroImageUrl,
      closingLine: real.closingLine,
      groups: real.groups,
      sections: [
        for (final s in real.sections)
          if (s.heading == 'Before any scan')
            PvDoorSection(
              group: s.group,
              heading: s.heading,
              tiles: [
                const PvDoorReadTile.comingSoon(
                    title: stand, blurb: 'Held in place until it lands.'),
                ...s.tiles,
              ],
            )
          else
            s,
      ],
    );
    await tester.pumpWidget(MaterialApp(
      home: PvDoorScreen(
        page: page,
        bracket: bracketById(real.bracketId)!,
        pregnancy: PregnancyController(),
      ),
    ));
    await tester.pump();
    final scan = page.groups.indexWhere((g) => g.id == kScansTabScan);

    await _goTab(tester, 'pregnancy_scans_tests', scan);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // The page's ListView is lazy: drag until the heading is built.
    Future<void> dragTo(Finder f) async {
      for (var i = 0; i < 12 && f.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
        await tester.pump();
      }
      expect(f, findsWidgets);
    }
    await dragTo(find.text('Before any scan'));
    await dragTo(find.text(stand));

    // ⚠️ IT HOLDS ITS PLACE AT FULL SIZE. The rule at the head of
    // `pv_placeholders.dart`: a placeholder occupies the real geometry, so
    // nothing on the rail moves the day the piece lands.
    final card = find.ancestor(
      of: find.text(stand),
      matching: find.byType(InkWell),
    );
    expect(card, findsWidgets);

    // Tapping it must not push anything. (A coming-soon row has no onTap, so
    // it is not itself hit-testable — that is the point, not a failure.)
    await tester.tap(card.first, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(card, findsWidgets, reason: 'a coming-soon card navigated away.');
    expect(find.byType(PvReaderScreen), findsNothing);
  });

  testWidgets('the scan-person card, written 2026-09-29, opens its read',
      (tester) async {
    await _pump(tester);
    final door = pvDoorPageFor('pregnancy_scans_tests')!;
    final scan = door.groups.indexWhere((g) => g.id == kScansTabScan);
    await _goTab(tester, 'pregnancy_scans_tests', scan);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    const title = 'What the scan person can and cannot tell you';
    final f = find.text(title);
    for (var i = 0; i < 12 && f.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pump();
    }
    expect(f, findsWidgets);
    await tester.ensureVisible(f.first);
    await tester.pump();
    await tester.tap(f.first, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(PvReaderScreen), findsOneWidget,
        reason: 'the finished card does not open its read.');
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
          // A folded section's heading carries its count ("Before any scan
          // · 4"); the plain heading is the rest.
          expect(
              s.folded
                  ? find.text('${s.heading}  ·  ${s.tiles.length}')
                  : find.text(s.heading),
              findsOneWidget,
              reason: '$name / "${g.label}": section "${s.heading}" is not on '
                  'screen while that tab is open.');
        }
      }
    });

    // ⚠️ THE LAYOUT RULE CHANGED AGAIN, 2026-10-02 (the user: make the
    // pregnancy doors the same as TTC's). 2026-09-19's "a written section is a
    // list, a mixed one is a rail" is retired: every section that is not an
    // inline tool is ONE rail of shelf cards (`PvShelfCard`, TTC's door
    // format), written or mixed. The old test is kept below, commented, for
    // revert (`kPvDoorShelf = false` restores the behaviour it described).
    testWidgets('$name: every section is one shelf of cards',
        (tester) async {
      await _pump(tester, name);
      for (var i = 0; i < door.groups.length; i++) {
        if (i > 0) {
          await _goTab(tester, name, i);
          await tester.pump(const Duration(milliseconds: 500));
        }
        final g = door.groups[i];
        for (final sec in door.sectionsOf(g.id)) {
          if (sec.inlineSurfaceId != null || sec.tiles.isEmpty) continue;
          if (sec.folded) continue; // folds until she opens it
          expect(
              find.byKey(pvDoorSectionShelfKey(sec.heading), skipOffstage: false),
              findsOneWidget,
              reason: '$name / "${g.label}" / "${sec.heading}" must be one '
                  'shelf of cards, written or mixed.');
          // And its first piece is a card on that shelf, not a list row.
          final first = sec.tilesFor(20).first;
          expect(
              find.descendant(
                  of: find.byKey(pvDoorSectionShelfKey(sec.heading),
                      skipOffstage: false),
                  matching: find.text(first.title, skipOffstage: false)),
              findsOneWidget,
              reason: '$name / "${g.label}" / "${sec.heading}": the first '
                  'piece, "${first.title}", is not a card on the shelf.');
        }
      }
    });

    //     testWidgets('$name: a written section is a list, a mixed one is a rail',
    //         (tester) async {
    //       // ⚠️ THE LAYOUT RULE, 2026-09-19 (it replaced 2026-09-11's "every
    //       // section is a rail, even a section of one"). A section whose tiles
    //       // are ALL written — article, guide, read, myth-fact — draws as a
    //       // vertical list of rows with a thumbnail; a section with a tool, a
    //       // film, a checklist or a person in it keeps the rail. Decided on the
    //       // phone from Complications' three rails of identical "Article" cards,
    //       // against Mobbin (Equinox, Alan, Gentler Streak, Liven list same-kind
    //       // articles; Clue and Atoms rail mixed content). So the number of
    //       // horizontal ListViews on a tab is the number of MIXED sections, and
    //       // every written section is present as its rows.
    //       await _pump(tester, name);
    //       for (var i = 0; i < door.groups.length; i++) {
    //         if (i > 0) {
    //           await _goTab(tester, name, i);
    //           await tester.pump(const Duration(milliseconds: 500));
    //         }
    //         final g = door.groups[i];
    //         final sections = door.sectionsOf(g.id);
    //         final mixed = sections.where((s) =>
    //             s.inlineSurfaceId == null &&
    //             s.tiles.isNotEmpty &&
    //             !pvDoorSectionIsRows(s.tiles));
    //         // An inline tool may draw a horizontal list of its own (Garbh's
    //         // ritual rail does); it is counted as at most one per inline
    //         // section, and never as a section rail.
    //         final inlineRails = sections.where((s) => s.inlineSurfaceId != null).length;
    //         final rails = find.byWidgetPredicate((w) =>
    //             w is ListView && w.scrollDirection == Axis.horizontal);
    //         final n = tester.widgetList(rails).length;
    //         // A tab whose whole body is a tool (`group.inlineSurfaceId`, e.g.
    //         // Nutrition's Today: the plate, the cravings chips) draws what the
    //         // tool needs; only the floor holds there.
    //         final toolTab = g.inlineSurfaceId != null;
    //         expect(n >= mixed.length && (toolTab || n <= mixed.length + inlineRails), isTrue,
    //             reason: '$name / "${g.label}": ${mixed.length} mixed sections must '
    //                 'draw ${mixed.length} rails (found $n, with $inlineRails inline '
    //                 'tools that may add one each).');
    //         // And every written section is rows: its first tile's title is on
    //         // the page as a row title, not inside a horizontal list.
    //         for (final sec in sections) {
    //           if (sec.inlineSurfaceId != null || sec.tiles.isEmpty) continue;
    //           if (!pvDoorSectionIsRows(sec.tiles)) continue; // written, or all tracks
    //           final first = sec.tilesFor(20).first;
    //           final inRail = find.descendant(of: rails, matching: find.text(first.title));
    //           expect(inRail, findsNothing,
    //               reason: '$name / "${g.label}" / "${sec.heading}" is all written '
    //                   'is rows (written or all tracks) and must be a list, not a rail.');
    //         }
    //       }
    //     });

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

    testWidgets('$name: every rail runs edge to edge on every tab', (tester) async {
      // ⚠️ THE GUTTER MISTAKE, MADE ONCE AND NOT AGAIN. The door wrapped its
      // inline tools in the 18pt gutter and the Nutrition bodies padded
      // themselves too: text sat 36pt in and every horizontal rail was
      // clipped at the gutter — "a wall on the left and right" (the user,
      // 2026-09-20). A rail scrolls UNDER the gutter: its box starts at the
      // screen's left edge and its own padding makes the first card sit in.
      await _pump(tester, name);
      for (var i = 0; i < door.groups.length; i++) {
        if (i > 0) {
          await _goTab(tester, name, i);
          await tester.pump(const Duration(milliseconds: 500));
        }
        final rails = find.byWidgetPredicate((w) => w is ListView && w.scrollDirection == Axis.horizontal);
        for (final e in rails.evaluate()) {
          final box = e.renderObject as RenderBox?;
          if (box == null || !box.hasSize) continue;
          final left = box.localToGlobal(Offset.zero).dx;
          final width = box.size.width;
          expect(left, closeTo(0, 0.5),
              reason: '$name / "${door.groups[i].label}": a rail starts ${left}pt in — it is inside a gutter.');
          expect(width, closeTo(tester.view.physicalSize.width / tester.view.devicePixelRatio, 0.5),
              reason: '$name / "${door.groups[i].label}": a rail is narrower than the screen.');
        }
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
        // ⚠️ FOLDED, NOT REMOVED (2026-10-02, the user: the warning signs can
        // be folded): the tab shows ONE quiet row with the door's own title,
        // and the sheet it opens holds every sign, whole. Kept for revert (the
        // block open on the tab): expect(find.text(flag.title), findsOneWidget)
        // and every line findsOneWidget on the page itself.
        expect(find.byKey(kPvDoorFlagRowKey), findsOneWidget,
            reason: '$name / "${door.groups[i].label}": the flag row is gone');
        expect(find.text(flag.title), findsOneWidget);
        final sheet = await _openFlag(tester);
        expect(find.descendant(of: sheet, matching: find.text(flag.title)),
            findsOneWidget);
        for (final line in flag.lines) {
          expect(find.descendant(of: sheet, matching: find.text(line.text)),
              findsOneWidget,
              reason: '$name: a red-flag line is missing from the sheet: '
                  '${line.text}');
        }
        await _closeSheet(tester);
      }
    });
  }
}
