// =============================================================================
//  The pregnancy doors wear the trying-to-conceive door format (2026-10-02).
//
//  The user: "make the door view of each door in pregnancy the same as TTC
//  doors; TTC doors have a new format, so follow that. For now keep the images
//  the pregnancy door hero has; update the UI of the pregnancy doors."
//
//  What changed, and what this pins:
//    · the QUIET HERO: the door's name is the title, the headline sentence the
//      one line under it, the white search pill; one height on every door,
//      matching TTC's;
//    · the QUIET TAB RAIL: 150 x 112, a 38 mark, a ring that is one pixel, no
//      count line, matching TTC's;
//    · every section a SHELF of cards (`PvShelfCard`), 148 wide with a 128
//      picture, matching TTC's, whatever its tiles are;
//    · one vertical rhythm, 24 between blocks and 12 under a heading.
//
//  ⚠️ THE NUMBERS ARE HELD EQUAL TO TTC'S, NOT RETYPED. `PvShelfCard` and the
//  rail are copies of the TTC look typed on pregnancy's model (the repo's
//  mirror-don't-merge rule), so a copy can drift. These assertions are what
//  stops that: change a TTC number and this fails until pregnancy follows.
//
//  NOT PINNED, ON PURPOSE: the pregnancy red-flag banner is NOT folded into a
//  collapsed row as TTC's is. Labour and complication warning signs staying in
//  view is a clinical-safety call that is the user's to make, not a layout
//  detail.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/screens/doors/pv_door_rail.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart';
import 'package:parentveda/screens/doors/pv_shelf_card.dart';
import 'package:parentveda/screens/doors/pv_shelf_spec.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_rail.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart';
import 'package:parentveda/screens/ttc/doors/ttc_kind_cards.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

Future<void> _pump(WidgetTester t, String id,
    {double scale = 1.0, Size size = const Size(360, 780)}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: PvDoorScreen(
      page: pvDoorPageFor(id)!,
      bracket: bracketById(id)!,
      pregnancy: PregnancyController(),
    ),
  ));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the numbers are TTC\'s', () {
    test('the shelf card', () {
      expect(kPvShelfCardWidth, kTtcShelfCardWidth);
      expect(kPvShelfPictureHeight, kTtcShelfPictureHeight);
      for (final s in [1.0, 1.3, 1.6]) {
        expect(pvShelfRailHeight(TextScaler.linear(s)),
            ttcShelfRailHeight(TextScaler.linear(s)),
            reason: 'the rail grows with the text exactly as TTC\'s does');
      }
    });

    test('the quiet hero', () {
      expect(kPvDoorHeroQuietHeight, kTtcDoorHeroQuietHeight);
      expect(kPvDoorHeroQuiet, isTrue);
    });

    test('the tab rail', () {
      expect(PvDoorRail.cardWidth, TtcDoorRail.cardWidth);
      expect(PvDoorRail.cardHeight, TtcDoorRail.cardHeight);
      expect(PvDoorRail.markSize, TtcDoorRail.markSize);
      expect(PvDoorRail.overlap, TtcDoorRail.overlap);
      expect(kPvDoorRailQuiet, kTtcDoorRailQuiet);
    });

    test('the rhythm and the one switch', () {
      expect(kPvDoorBlockGap, 24);
      expect(kPvDoorHeadingGap, 12);
      expect(kPvDoorShelf, isTrue);
    });
  });

  group('every pregnancy door', () {
    for (final door in kPvDoorPages) {
      testWidgets('${door.bracketId}: quiet hero, quiet rail, no overflow at '
          '360dp and at 1.5x text', (t) async {
        for (final scale in [1.0, 1.5]) {
          await _pump(t, door.bracketId, scale: scale);
          // The door's own name is the title, and the search pill is there.
          expect(find.byKey(kPvDoorHeroTitleKey), findsOneWidget);
          expect(find.byKey(kPvDoorSearchKey), findsOneWidget);
          // The headline sentence is the line under the name; the blurb that
          // used to follow it is not drawn.
          expect(find.text(door.heroTitle), findsOneWidget);
          expect(find.text(door.heroBlurb), findsNothing,
              reason: 'the blurb is dropped by the quiet hero');
          // The rail is the quiet card: no "N things" count line.
          expect(find.textContaining(RegExp(r'^\d+ things?$')), findsNothing);
          expect(t.takeException(), isNull,
              reason: '${door.bracketId} at ${scale}x overflows at 360dp');
        }
      });
    }
  });

  group('the shelf card says what each thing is, as TTC\'s does', () {
    Widget card({
      PvShelfKind kind = PvShelfKind.read,
      String? fact,
      bool paid = false,
      bool live = false,
      bool soon = false,
    }) =>
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PvShelfCard(
                p: V2PaletteStore.instance.current,
                hue: 200,
                kind: kind,
                fact: fact,
                paid: paid,
                live: live,
                title: 'What a dating scan checks',
                comingSoon: soon,
                onTap: () {},
              ),
            ),
          ),
        );

    testWidgets('title, then the word and one fact on one grey line',
        (t) async {
      await t.pumpWidget(card(fact: '9 min read'));
      expect(find.text('What a dating scan checks'), findsOneWidget);
      expect(find.text('Article · 9 min read'), findsOneWidget);
      expect(t.getSize(find.byType(PvShelfCard)).width, kPvShelfCardWidth);
    });

    for (final (kind, icon, word) in [
      (PvShelfKind.tool, Icons.build_outlined, 'Tool'),
      (PvShelfKind.read, Icons.article_outlined, 'Article'),
      (PvShelfKind.myth, Icons.balance_rounded, 'Myth or fact'),
      (PvShelfKind.video, Icons.videocam_outlined, 'Video'),
      (PvShelfKind.talk, Icons.forum_outlined, 'Talk to an expert'),
      (PvShelfKind.recipe, Icons.restaurant_outlined, 'Recipe'),
    ]) {
      testWidgets('${kind.name}: the badge and the word are TTC\'s',
          (t) async {
        await t.pumpWidget(card(kind: kind));
        final badge = find.byKey(pvShelfBadgeKey('What a dating scan checks'));
        expect(badge, findsOneWidget);
        expect(find.descendant(of: badge, matching: find.byIcon(icon)),
            findsOneWidget);
        expect(find.text(word), findsOneWidget);
      });
    }

    testWidgets('what costs money wears a rupee in the badge\'s place',
        (t) async {
      await t.pumpWidget(card(kind: PvShelfKind.talk, paid: true));
      final badge = find.byKey(pvShelfBadgeKey('What a dating scan checks'));
      expect(find.descendant(of: badge, matching: find.byIcon(Icons.currency_rupee_rounded)),
          findsOneWidget);
      expect(find.descendant(of: badge, matching: find.byIcon(Icons.forum_outlined)),
          findsNothing, reason: 'at most two marks on a card');
    });

    testWidgets('a one-to-one session has TTC\'s red-dot pill', (t) async {
      await t.pumpWidget(card(kind: PvShelfKind.talk, live: true));
      expect(find.byKey(pvShelfLiveKey('What a dating scan checks')), findsOneWidget);
      expect(find.text(kPvShelfLive), findsOneWidget);
      await t.pumpWidget(card(kind: PvShelfKind.talk));
      expect(find.text(kPvShelfLive), findsNothing);
    });

    testWidgets('a card that is not made yet says so, keeps its badge and '
        'does not tap', (t) async {
      var taps = 0;
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: PvShelfCard(
              p: V2PaletteStore.instance.current,
              hue: 200,
              kind: PvShelfKind.video,
              fact: '2 min watch',
              title: 'Not yet',
              comingSoon: true,
              onTap: () => taps++,
            ),
          ),
        ),
      ));
      expect(find.text('Coming soon'), findsOneWidget);
      expect(find.byKey(pvShelfBadgeKey('Not yet')), findsOneWidget);
      expect(find.text('Video · 2 min watch'), findsOneWidget);
      await t.tap(find.byKey(pvShelfCardKey('Not yet')));
      expect(taps, 0);
    });
  });

  group('the identification is TTC\'s, held equal', () {
    test('the icons and the words match TTC\'s kinds', () {
      for (final (pv, ttc) in [
        (PvShelfKind.tool, TtcCardKind.tool),
        (PvShelfKind.read, TtcCardKind.read),
        (PvShelfKind.myth, TtcCardKind.myth),
        (PvShelfKind.video, TtcCardKind.video),
        (PvShelfKind.talk, TtcCardKind.consult),
        (PvShelfKind.recipe, TtcCardKind.recipe),
      ]) {
        expect(pvShelfKindIcon(pv), ttcCardKindIcon(ttc), reason: pv.name);
      }
      // The words: TTC says "Myth vs fact" in its pill and "Myth or fact" on
      // the grey line; the line is what a card shows.
      expect(pvShelfKindWord(PvShelfKind.tool), ttcCardKindWord(TtcCardKind.tool));
      expect(pvShelfKindWord(PvShelfKind.read), ttcCardKindWord(TtcCardKind.read));
      expect(pvShelfKindWord(PvShelfKind.video), ttcCardKindWord(TtcCardKind.video));
      expect(pvShelfKindWord(PvShelfKind.recipe), ttcCardKindWord(TtcCardKind.recipe));
      expect(pvShelfKindWord(PvShelfKind.talk), ttcCardKindWord(TtcCardKind.consult));
      expect(pvShelfKindWord(PvShelfKind.myth), 'Myth or fact');
      expect(kPvShelfLive, kTtcConsultLive);
    });

    test('every card on every door says what it is', () {
      var total = 0;
      final kinds = <PvShelfKind, int>{};
      for (final page in kPvDoorPages) {
        for (final t in page.allTiles) {
          final spec = pvShelfSpecFor(t);
          kinds[spec.kind] = (kinds[spec.kind] ?? 0) + 1;
          expect(spec.kind, pvShelfKindOf(t.format), reason: t.title);
          total++;
        }
      }
      expect(total, greaterThan(400));
      // Each of the kinds the doors use is present, so none fell through.
      for (final k in [PvShelfKind.tool, PvShelfKind.read, PvShelfKind.myth,
          PvShelfKind.video, PvShelfKind.talk, PvShelfKind.audio]) {
        expect(kinds[k] ?? 0, greaterThan(0), reason: '${k.name} has no card');
      }
    });

    test('a guide says a week range or a reading time, never nothing', () {
      var guides = 0, said = 0;
      for (final page in kPvDoorPages) {
        for (final t in page.allTiles) {
          if (t is! PvDoorGuideTile) continue;
          guides++;
          if (pvShelfSpecFor(t).fact != null) said++;
        }
      }
      expect(guides, greaterThan(100));
      // A very short read claims no time (TTC's rule), so not every guide has
      // one; nearly all must.
      expect(said / guides, greaterThan(0.9),
          reason: 'most guides should carry a fact on their line');
    });

    test('what costs money is marked, and only one-to-ones are live', () {
      var paidTalks = 0;
      for (final page in kPvDoorPages) {
        for (final t in page.allTiles) {
          if (t is! PvDoorTalkTile) continue;
          final spec = pvShelfSpecFor(t);
          if ((t.meta ?? '').contains('₹')) {
            expect(spec.paid, isTrue, reason: t.title);
            paidTalks++;
          }
        }
      }
      expect(paidTalks, greaterThan(0));
    });

    test('a film says its length in TTC\'s words, and a loud meta goes quiet',
        () {
      const film = PvDoorVideoTile(title: 'x', blurb: 'y', meta: '2 MIN');
      expect(pvShelfSpecFor(film).fact, '2 min watch');
      const loop = PvDoorAudioTile.comingSoon(
          title: 'x', blurb: 'y', meta: '30 MIN LOOP');
      expect(pvShelfSpecFor(loop).fact, '30 min loop');
    });

    test('the picture is untouched: the adapter still passes the tile\'s own '
        'photo and mark', () {
      final src = _code('lib/screens/doors/pv_door_screen.dart');
      expect(src, contains('imageUrl: tile.comingSoon ? null : pvDoorTilePhoto(tile)'));
      expect(src, contains('mark: pvDoorTileMark(tile) ?? pvDoorFormatMark(tile.format)'));
    });
  });

  group('wiring (a source check, since reachability is the claim)', () {
    test('the door screen builds the shelf and the quiet hero, and no longer '
        'builds a count on the rail', () {
      final src = _code('lib/screens/doors/pv_door_screen.dart');
      expect(src, contains('else if (kPvDoorShelf)'));
      expect(src, contains('PvShelfCard('));
      expect(src, contains('kPvDoorHeroQuiet ? _quiet(context)'));
      final rail = _code('lib/screens/doors/pv_door_rail.dart');
      expect(rail, contains('!kPvDoorRailQuiet && count.isNotEmpty'));
    });

    test('the warning signs are folded into one row that opens the whole '
        'block, which is still built', () {
      // The user, 2026-10-02: "the warning signs can be folded". Folded, not
      // removed: the sheet carries the same `_PinnedRedFlag` block, every sign
      // (test/pv_door_renders_test.dart opens it on every door and checks).
      final src = _code('lib/screens/doors/pv_door_screen.dart');
      expect(kPvDoorFlagFolded, isTrue);
      expect(src, contains('_PinnedRedFlagRow('));
      expect(src, contains('showTtcDoorFlagSheet('));
      expect(src, contains('_PinnedRedFlag('),
          reason: 'the full block must still be built, for the sheet');
    });

    test('a tool drawn inside a door wears the shelf card, not the tall rail '
        'card', () {
      for (final f in [
        'lib/screens/garbh_door_surfaces.dart',
        'lib/screens/garbh_journal_screen.dart',
        'lib/screens/nutrition/door/nutrition_recipe_rail.dart',
      ]) {
        final src = _code(f);
        expect(src, contains('PvShelfCard('), reason: f);
        expect(src, isNot(contains('PvDoorRailCard(')), reason: f);
      }
    });
  });
}
