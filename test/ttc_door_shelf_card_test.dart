// The door's shelf card and quiet hero (2026-09-29, the user on build 22 with
// Flo's "How to get pregnant" beside our Fertile window door: minimal, a
// picture with its title and one line under it, a film known by its play
// button, and no random photos). See `TtcShelfCard` in ttc_kind_cards.dart and
// the table in ttc_card_art.dart.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/ttc/doors/ttc_card_art.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_hero.dart'
    show ttcDoorHeroArtAsset;
import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart';
import 'package:parentveda/screens/ttc/doors/ttc_kind_cards.dart';
import 'package:parentveda/screens/ttc/ttc_focus_screen.dart'
    show ttcTilePhotoId;
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';

Iterable<TtcTile> _allTiles() sync* {
  for (final page in kTtcFocusPages) {
    for (final s in page.sections) {
      yield* s.tiles;
    }
  }
}

TtcFocusPage get _fertile =>
    kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_conceiving');

Future<void> _pumpCard(WidgetTester tester, TtcTile t, {double scale = 1}) {
  final kind = ttcCardKindOf(t)!;
  return tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: ttcShelfRailHeight(TextScaler.linear(scale)),
              child: TtcShelfCard(
                tile: t,
                kind: kind,
                p: V2PaletteStore.instance.current,
                hue: 344,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() => HttpOverrides.global = null);

  group('the grey line says what the thing is', () {
    test('every kind has plain words, never a blank', () {
      for (final t in _allTiles()) {
        final kind = ttcCardKindOf(t);
        if (kind == null) continue;
        final m = ttcShelfMeta(t, kind);
        expect(m.trim(), isNotEmpty, reason: t.title);
      }
    });

    test('an unmade film says Video, and the picture says Coming soon', () {
      final unmade = _allTiles().firstWhere(
        (t) => t is TtcVideoTile && ttcTileIsUnmadeFilm(t),
      );
      // The preview (kTtcShelfFilmPreview, the user on build 23) gives it a
      // made-up length. Kept for the day the preview is off:
      //   expect(ttcShelfMeta(unmade, TtcCardKind.video), 'Video');
      expect(
        ttcShelfMeta(unmade, TtcCardKind.video),
        kTtcShelfFilmPreview ? endsWith('min watch') : 'Video',
      );
    });

    test('a myth and a read say so', () {
      final myth = _allTiles().whereType<TtcMythTile>().first;
      expect(ttcShelfMeta(myth, TtcCardKind.myth), 'Myth or fact');
      final read = _allTiles().whereType<TtcArticleTile>().first;
      expect(ttcShelfMeta(read, TtcCardKind.read), startsWith('Article'));
    });
  });

  group('a film is known by its play button, and only a made one', () {
    testWidgets('an unmade film: Coming soon, no play button', (tester) async {
      final unmade = _allTiles().firstWhere(
        (t) => t is TtcVideoTile && ttcTileIsUnmadeFilm(t),
      );
      await _pumpCard(tester, unmade);
      if (kTtcShelfFilmPreview) {
        // ⚠️ THE PREVIEW (the user on build 23): Flo's triangle and a
        // made-up length on every film. Must be off before launch.
        expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
        expect(find.text(kTtcFilmComingSoon), findsNothing);
        return;
      }
      expect(find.text(kTtcFilmComingSoon), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    test('the preview length is fixed by the title, 0:30 to 4:59', () {
      for (final t in _allTiles().whereType<TtcVideoTile>()) {
        final a = ttcShelfPreviewSeconds(t.title);
        expect(a, ttcShelfPreviewSeconds(t.title));
        expect(a, inInclusiveRange(30, 299));
      }
    });

    testWidgets('a made film: the play button and its length', (tester) async {
      final made = _allTiles().where(
        (t) => t is TtcVideoTile && !ttcTileIsUnmadeFilm(t),
      );
      if (made.isEmpty) return; // no film is made yet; nothing to show
      await _pumpCard(tester, made.first);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.text(kTtcFilmComingSoon), findsNothing);
    });

    testWidgets('no other kind carries a play button', (tester) async {
      final read = _allTiles().whereType<TtcArticleTile>().first;
      await _pumpCard(tester, read);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });
  });

  group('no random photos (the Fertile window door, judged by eye)', () {
    final ids = {
      for (final s in _fertile.sections)
        for (final t in s.tiles) ttcTilePhotoId(t),
    };

    test('every id in the table is a card on the door (a rename fails here)',
        () {
      for (final id in {...kTtcCardPhotoOff, ...kTtcCardMarks.keys}) {
        expect(ids, contains(id), reason: '$id is on no card');
      }
    });

    test('a card whose photo is off has a drawn object chosen for it', () {
      for (final id in kTtcCardPhotoOff) {
        expect(kTtcCardMarks, contains(id), reason: id);
      }
    });

    test('no drawn object twice in one section', () {
      for (final s in _fertile.sections) {
        final marks = [
          for (final t in s.tiles) ?kTtcCardMarks[ttcTilePhotoId(t)],
        ];
        expect(marks.toSet().length, marks.length, reason: s.heading);
      }
    });

    testWidgets('a photo that misses its subject is drawn instead',
        (tester) async {
      final t = _fertile.sections
          .expand((s) => s.tiles)
          .firstWhere((t) => ttcTilePhotoId(t) ==
              'ttc_tile_which_days_can_you_get_pregnant');
      await _pumpCard(tester, t);
      expect(find.byKey(ttcKindDrawingKey(t.title)), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });

  testWidgets('a tool and a chat carry the corner badge; a read does not',
      (tester) async {
    final tool = _allTiles().firstWhere(
      (t) => ttcCardKindOf(t) == TtcCardKind.tool,
    );
    await _pumpCard(tester, tool);
    expect(find.byKey(ttcKindToolBarKey(tool.title)), findsOneWidget);
    expect(find.byIcon(Icons.build_outlined), findsOneWidget);
    final chat = _allTiles().firstWhere(
      (t) => ttcCardKindOf(t) == TtcCardKind.chat,
    );
    await _pumpCard(tester, chat);
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
    final read = _allTiles().whereType<TtcArticleTile>().first;
    await _pumpCard(tester, read);
    expect(find.byKey(ttcKindToolBarKey(read.title)), findsNothing);
  });

  testWidgets('a paid card shows its corner mark; a free read does not',
      (tester) async {
    final consult = _allTiles().firstWhere(
      (t) => ttcCardKindOf(t) == TtcCardKind.consult && ttcShelfPrice(t) != null,
    );
    // No prices on the picture since 2026-09-30 (the user). Kept for revert:
    //   expect(find.byKey(ttcKindPriceKey(consult.title)), findsOneWidget);
    //   expect(find.text(ttcShelfPrice(consult)!), findsOneWidget);
    await _pumpCard(tester, consult);
    expect(find.byKey(ttcKindPriceKey(consult.title)), findsNothing);
    expect(find.text(ttcShelfPrice(consult)!), findsNothing);
    final product = _allTiles().firstWhere(
      (t) => ttcCardKindOf(t) == TtcCardKind.product,
    );
    await _pumpCard(tester, product);
    expect(find.byKey(ttcKindPriceKey(product.title)), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    final course = _allTiles().firstWhere(
      (t) => ttcCardKindOf(t) == TtcCardKind.course,
    );
    await _pumpCard(tester, course);
    expect(find.text(kTtcCourseEnroll), findsOneWidget);
    expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    final read = _allTiles().whereType<TtcArticleTile>().first;
    await _pumpCard(tester, read);
    expect(find.byKey(ttcKindPriceKey(read.title)), findsNothing);
    // A course card's photo starts a network load; let it settle.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  test('a consult names a real roster person, never a role', () {
    for (final t in _allTiles()) {
      if (ttcCardKindOf(t) != TtcCardKind.consult) continue;
      final who = ttcShelfPerson(t);
      if (who == null) continue;
      expect(who.startsWith('A '), isFalse, reason: t.title);
      expect(ttcShelfMeta(t, TtcCardKind.consult), who);
    }
  });

  testWidgets('the card holds its shape at 1.5x text', (tester) async {
    for (final t in _fertile.sections.expand((s) => s.tiles)) {
      if (ttcCardKindOf(t) == null) continue;
      await _pumpCard(tester, t, scale: 1.5);
      expect(tester.takeException(), isNull, reason: t.title);
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  group('the quiet hero', () {
    test('it is on, and the Fertile window art is light and bundled', () {
      expect(kTtcDoorHeroQuiet, isTrue);
      expect(kTtcDoorHeroLightArt, contains('ttc_conceiving'));
      for (final id in kTtcDoorHeroLightArt) {
        final asset = ttcDoorHeroArtAsset(id);
        expect(asset, isNotNull, reason: id);
        expect(File(asset!).existsSync(), isTrue, reason: asset);
      }
    });
  });
}
