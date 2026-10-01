// =============================================================================
//  The TTC doors in the new door language (TtcDoorScreen, 2026-09-26)
// -----------------------------------------------------------------------------
//  What this holds, and why each one is a test rather than a look:
//
//    · every door builds at 360pt, on every tab, with nothing overflowing.
//      Every overflow this stage has shipped was found at phone width or not
//      at all.
//    · every tab carries a DRAWN mark. A tab without one falls back to a stock
//      glyph, which beside drawn marks reads as the placeholder nobody
//      replaced, and nothing else would notice.
//    · a section of only written pieces draws as rows; anything mixed draws as
//      a rail, and a rail runs edge to edge (its own padding is the gutter,
//      never a wall on the left and right).
//    · a pinned red flag renders, from the read's own words.
//    · the search field is there, and typing finds things.
//    · the WIRING GATE: the home, the semen report and a door-to-door tile all
//      open this screen, not the old one. Correct code nobody can reach is the
//      failure this repo keeps having.
// =============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/doors/pv_live_search.dart'
    show PvLiveSearchField;
import 'package:parentveda/screens/ttc/doors/ttc_door_card.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_hero.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_rail.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_search.dart';
import 'package:parentveda/screens/ttc/doors/ttc_kind_cards.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart' show TtcS;
import 'package:parentveda/screens/ttc/ttc_treatment_round_screens.dart'
    show
        TtcStartTreatmentCard,
        TtcIvfRoundPanel,
        TtcIvfPanel,
        ttcIvfPanelNow,
        ttcIvfRoundLeads;

// ---- `Image.network` needs a client that answers, or layout throws ---------
class _StubHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? _) => _StubClient();
}

class _StubClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _StubRequest();
}

class _StubRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _StubHeaders();

  @override
  Future<HttpClientResponse> close() async => _StubResponse();
}

class _StubHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

final _kPixel = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

class _StubResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kPixel.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(_kPixel).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
}

String _src(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// The body of a top-level or member function, from its signature to the
/// next line that closes at two-space indentation.
String _fn(String src, String signature) {
  final start = src.indexOf(signature);
  expect(start, greaterThanOrEqualTo(0), reason: '$signature is gone');
  final end = src.indexOf('\n  }\n', start);
  return src.substring(start, end < 0 ? src.length : end);
}

/// Lines that are code, not comments.
Iterable<String> _live(String body) =>
    body.split('\n').where((l) => !l.trimLeft().startsWith('//'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() => HttpOverrides.global = _StubHttpOverrides());
  tearDown(() => HttpOverrides.global = null);

  Future<void> pumpDoor(
    WidgetTester tester,
    TtcFocusPage page, {
    double width = 360,
    double height = 2400,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final bracket = bracketById(page.bracketId)!;
    await tester.pumpWidget(
      MaterialApp(
        home: TtcDoorScreen(page: page, bracket: bracket),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester.takeException(),
      isNull,
      reason: '${page.bracketId} threw while building',
    );
  }

  Future<void> pickTab(WidgetTester tester, int i) async {
    final card = find.byKey(ttcDoorRailCardKey(i));
    await tester.ensureVisible(card);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(card, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
  }

  // ===========================================================================
  group('the data every door needs', () {
    // Nine since 2026-09-26 (was seven): the gap plan's Body and cycle and
    // "Trying, but not pregnant yet?".
    test('nine doors, each with a sentence for a headline', () {
      expect(kTtcFocusPages, hasLength(9));
      for (final page in kTtcFocusPages) {
        expect(page.heroTitle, isNotNull, reason: page.bracketId);
        expect(
          page.heroTitle!.contains('—'),
          isFalse,
          reason: 'no dashes in her copy (TTC-VOICE rule 8)',
        );
        expect(bracketById(page.bracketId), isNotNull, reason: page.bracketId);
      }
    });

    test('every tab has a drawn mark', () {
      for (final page in kTtcFocusPages) {
        for (final g in page.groups!) {
          expect(
            g.mark,
            isNotNull,
            reason:
                '${page.bracketId} / ${g.id} has no drawn mark, so its '
                'rail card falls back to a stock glyph',
          );
        }
      }
    });

    test('community is held back for launch', () {
      for (final page in kTtcFocusPages) {
        final rooms = page.allTiles.whereType<TtcCommunityTile>().where(
          (t) => t.surfaceId == 'ttc_community',
        );
        expect(rooms, isEmpty, reason: '${page.bracketId} still offers a room');
      }
    });
  });

  // ===========================================================================
  group('every door builds at 360pt, on every tab', () {
    for (final page in kTtcFocusPages) {
      testWidgets(page.bracketId, (tester) async {
        await pumpDoor(tester, page);
        expect(find.byKey(kTtcDoorRailKey), findsOneWidget);
        expect(find.text(page.heroTitle!), findsOneWidget);
        for (var i = 0; i < page.groups!.length; i++) {
          await pickTab(tester, i);
          expect(
            tester.takeException(),
            isNull,
            reason:
                '${page.bracketId}, tab ${page.groups![i].id}, '
                'overflowed or threw at 360pt',
          );
        }
      });
    }
  });

  // ===========================================================================
  //  ONE FORMAT since 2026-09-27 (the user, walking build 13: rows and cards
  //  in one tab read as random). Every section is a rail of the one card,
  //  edge to edge, on every door. Kept for revert, the old split:
  //    if (ttcDoorSectionIsRows(s.tiles)) expect rows key, else expect rail;
  //    and "at least one section of each kind exists, or the rule is
  //    untested" (expected both kinds to exist in the data).
  group(
    'sections: every one is a rail that runs edge to edge, never rows',
    () {
      for (final page in kTtcFocusPages) {
        testWidgets(page.bracketId, (tester) async {
          await pumpDoor(tester, page, height: 12000);
          for (var i = 0; i < page.groups!.length; i++) {
            await pickTab(tester, i);
            final g = page.groups![i];
            for (final s in page.sections.where((s) => s.group == g.id)) {
              expect(
                find.byKey(ttcDoorRowsKey(s.heading), skipOffstage: false),
                findsNothing,
                reason: '"${s.heading}" drew as rows again',
              );
              // Launch sanity D13, MB20 (2026-09-28): a section of ONE piece
              // is the one card at full width, and a way to another door is a
              // link row. Both hold here instead of the rail.
              for (final t in s.tiles.whereType<TtcDoorTile>()) {
                expect(
                  find.byKey(ttcDoorLinkKey(t.bracketId), skipOffstage: false),
                  findsWidgets,
                  reason: '"${t.title}" is not a link row',
                );
              }
              final railTiles = ttcDoorRailTiles(s.tiles);
              if (railTiles.isEmpty) continue;
              // Since 2026-09-29 a one-piece section is a shelf of one Flo
              // block too, so it falls through to the rail check below.
              // Kept for revert:
              //   if (railTiles.length == 1) { expect wide key; continue; }
              final rail = find.byKey(
                ttcDoorSectionRailKey(s.heading),
                skipOffstage: false,
              );
              expect(
                rail,
                findsOneWidget,
                reason: '"${s.heading}" is not a rail',
              );
              // Edge to edge: the rail is the full screen wide and starts at
              // the screen's edge; its own padding is the gutter.
              expect(
                tester.getSize(rail).width,
                360,
                reason: '"${s.heading}" is padded in from the edge',
              );
              expect(tester.getTopLeft(rail).dx, 0);
              // The one card, and only it, in the rail. Since 2026-09-28 a
              // door in `kTtcDoorsWithKindCards` (the Fertile window door)
              // draws one look per kind instead; `ttc_door_kind_cards_test`
              // holds that door. Kept for revert, the expectation on every
              // door:
              //   expect(find.descendant(of: rail,
              //       matching: find.byType(TtcDoorSectionCard)),
              //       findsWidgets, reason: ...);
              // Since 2026-09-29 every door draws the one card family
              // (`TtcKindCard`), and only it. Kept for revert (2026-09-28):
              //   matching: find.byType(ttcDoorDrawsKinds(page.bracketId)
              //       ? TtcKindCard : TtcDoorSectionCard),
              // Since 2026-09-29 (the user on build 21) the shelves are Flo's
              // small blocks, `TtcFloCard`. Kept for revert:
              //   matching: find.byType(TtcKindCard)
              // Since 2026-09-29 (the user on build 22) the shelf card:
              // a picture, its title and one grey line. Kept for revert:
              //   matching: find.byType(TtcFloCard)
              expect(
                find.descendant(of: rail, matching: find.byType(TtcShelfCard)),
                findsWidgets,
                reason: '"${s.heading}" draws some other card',
              );
              expect(
                find.descendant(
                  of: rail,
                  matching: find.byType(TtcDoorSectionCard),
                ),
                findsNothing,
                reason: '"${s.heading}" still draws the old photo card',
              );
            }
          }
        });
      }

      test('the screen no longer chooses rows for any section', () {
        final src = _src('lib/screens/ttc/doors/ttc_door_screen.dart');
        final build = _fn(src, 'Widget build(BuildContext context) {');
        final live = _live(build).join('\n');
        expect(live.contains('ttcDoorSectionIsRows('), isFalse);
        expect(live.contains('_ArticleList('), isFalse);
        expect(live.contains('PvDoorRailCard('), isFalse,
            reason: 'the shared pregnancy card is back on a TTC rail');
        // 2026-09-29: the rail draws the one card family. Kept for revert:
        //   expect(live.contains('TtcDoorSectionCard('), isTrue);
        // 2026-09-29: Flo's blocks. Kept for revert: 'TtcKindCard('.
        expect(live.contains('TtcFloCard('), isTrue);
        // 2026-09-29 (build 22): the shelf card leads.
        expect(live.contains('TtcShelfCard('), isTrue);
      });

      testWidgets('a card with no photo is typographic, not a ghost shape',
          (tester) async {
        tester.view.physicalSize = const Size(360, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final p = V2PaletteStore.instance.current;
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Row(children: [
              TtcDoorSectionCard(
                p: p,
                hue: 200,
                mark: ttcDoorFormatMark(TtcTileFormat.article),
                kind: 'Article',
                title: 'A long title that runs on to fill four lines of '
                    'the card and then some more words after that',
                meta: '4 min read',
              ),
            ]),
          ),
        ));
        expect(tester.takeException(), isNull);
        expect(find.text('Article · 4 min read'), findsOneWidget);
        expect(find.byType(Image), findsNothing);
        expect(tester.getSize(find.byType(TtcDoorSectionCard)),
            const Size(kTtcDoorCardWidth, kTtcDoorCardHeight));
        // The title sits at the foot, over the kind and minutes, not under
        // the mark with the space below it empty (the user, 2026-09-28).
        final card = tester.getRect(find.byType(TtcDoorSectionCard));
        final title = tester.getRect(find.textContaining('A long title'));
        final foot = tester.getRect(find.text('Article · 4 min read'));
        expect(title.top, greaterThan(card.top + card.height / 3),
            reason: 'the title leads again, with the space under it empty');
        expect(foot.top - title.bottom, lessThanOrEqualTo(8),
            reason: 'a gap opened between the title and its foot');
      });
    },
  );

  // ===========================================================================
  //  The hero is one height on every door (2026-09-27, the user: "the hero
  //  image height differs door to door").
  // ⚠️ SUPERSEDED 2026-09-29 (build 20, the hero for flat art): the hero is
  // no longer the fixed 344, the photograph no longer parallaxes and the
  // field is no longer glass. Kept for revert, the old group:
  // group('the hero', () {
  //   testWidgets('is the same height on all nine doors', (tester) async {
  //     final heights = <String, double>{};
  //     for (final page in kTtcFocusPages) {
  //       await pumpDoor(tester, page);
  //       heights[page.bracketId] =
  //           tester.getSize(find.byKey(kTtcDoorHeroKey)).height;
  //     }
  //     expect(heights.values.toSet(), {kTtcDoorHeroHeight},
  //         reason: 'hero heights differ: $heights');
  //   });
  //
  //   testWidgets('the photo parallaxes: it climbs slower than the page',
  //       (tester) async {
  //     final page = kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_pcos');
  //     await pumpDoor(tester, page, height: 800);
  //     final photo = find.descendant(
  //         of: find.byKey(kTtcDoorHeroKey), matching: find.byType(Image));
  //     final hero0 = tester.getTopLeft(find.byKey(kTtcDoorHeroKey)).dy;
  //     final photo0 = tester.getTopLeft(photo.first).dy;
  //     await tester.drag(find.byType(ListView).first, const Offset(0, -200));
  //     await tester.pump();
  //     final heroMoved = hero0 - tester.getTopLeft(find.byKey(kTtcDoorHeroKey)).dy;
  //     final photoMoved = photo0 - tester.getTopLeft(photo.first).dy;
  //     expect(heroMoved, greaterThan(100));
  //     expect(photoMoved, lessThan(heroMoved * 0.7),
  //         reason: 'the photo scrolls with the page, no parallax');
  //     expect(photoMoved, greaterThan(0));
  //   });
  //
  //   testWidgets('the field on a photograph is glass, and still a field',
  //       (tester) async {
  //     final page = kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_pcos');
  //     await pumpDoor(tester, page);
  //     expect(
  //         find.descendant(
  //             of: find.byKey(kTtcDoorSearchKey),
  //             matching: find.byType(BackdropFilter)),
  //         findsOneWidget);
  //     expect(tester.getSize(find.byKey(kTtcDoorSearchKey)).height,
  //         TtcDoorGlassSearchField.height);
  //   });
  // });

  // ===========================================================================
  //  The hero for flat art (2026-09-29, the user on build 20: "the image must
  //  be visible, the heading must be visible", and the search "feels like a
  //  fit-to-fill" against the cards; the lead: never crop the art).
  // RETIRED 2026-09-29: the user chose the photograph hero again (Flo's door,
  // the words and search on the picture), so the flat-art layout's tests are
  // skipped, kept for the day `TtcDoorHero` comes back.
  group('the hero (flat-art layout, retired)',
      skip: 'the user chose the photograph hero again (2026-09-29)', () {
    Future<void> pumpScaled(
      WidgetTester tester,
      TtcFocusPage page, {
      double scale = 1.5,
    }) async {
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: TtcDoorScreen(
              page: page, bracket: bracketById(page.bracketId)!),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('is the same height on all nine doors', (tester) async {
      final heights = <String, double>{};
      for (final page in kTtcFocusPages) {
        await pumpDoor(tester, page);
        heights[page.bracketId] =
            tester.getSize(find.byKey(kTtcDoorHeroKey)).height;
      }
      // Kept for revert: {kTtcDoorHeroHeight}.
      expect(heights.values.toSet(), {ttcDoorHeroHeight(360, 0)},
          reason: 'hero heights differ: $heights');
    });

    testWidgets(
        'the art frame is 3:2 and full width, and the picture is contained: '
        'rendered aspect == source aspect, never cropped', (tester) async {
      for (final page in kTtcFocusPages) {
        await pumpDoor(tester, page);
        final frame = tester.getSize(find.byKey(kTtcDoorHeroArtKey));
        expect(frame.width, 360, reason: page.bracketId);
        expect(frame.width / frame.height,
            closeTo(kTtcDoorHeroArtAspect, 0.001),
            reason: page.bracketId);
        final img = find.descendant(
            of: find.byKey(kTtcDoorHeroArtKey), matching: find.byType(Image));
        expect(img, findsOneWidget, reason: '${page.bracketId}: no picture');
        expect(tester.widget<Image>(img).fit, BoxFit.contain,
            reason: '${page.bracketId}: cover crops the art');
        expect(tester.getSize(img), frame, reason: page.bracketId);
      }
      // The arithmetic the frame relies on: the whole source is drawn, and
      // a 3:2 source fills the 3:2 frame exactly, for the art and for the
      // photographs (1200 x 800) that stand in for it.
      const frame = Size(360, 240);
      for (final src in [kTtcDoorHeroArtSize, const Size(1200, 800)]) {
        final fit = applyBoxFit(BoxFit.contain, src, frame);
        expect(fit.source, src, reason: 'part of the picture is cut');
        expect(fit.destination, frame, reason: 'the picture is letterboxed');
      }
    });

    testWidgets('no parallax: the frame scrolls with the page',
        (tester) async {
      final page = kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_pcos');
      await pumpDoor(tester, page, height: 800);
      final art = find.byKey(kTtcDoorHeroArtKey);
      final hero0 = tester.getTopLeft(find.byKey(kTtcDoorHeroKey)).dy;
      final art0 = tester.getTopLeft(art).dy;
      await tester.drag(find.byType(ListView).first, const Offset(0, -200));
      await tester.pump();
      final heroMoved =
          hero0 - tester.getTopLeft(find.byKey(kTtcDoorHeroKey)).dy;
      expect(heroMoved, greaterThan(100));
      expect(art0 - tester.getTopLeft(art).dy, heroMoved);
    });

    testWidgets(
        'on every door the words sit below the art, never on it, and the '
        'search has its own row', (tester) async {
      for (final page in kTtcFocusPages) {
        await pumpDoor(tester, page);
        final art = tester.getRect(find.byKey(kTtcDoorHeroArtKey));
        for (final k in [
          kTtcDoorHeroEyebrowKey,
          kTtcDoorHeroTitleKey,
          kTtcDoorHeroIntroKey,
        ]) {
          final r = tester.getRect(find.byKey(k));
          expect(r.top, greaterThanOrEqualTo(art.bottom),
              reason: '${page.bracketId}: $k is on the picture');
        }
        final intro = tester.getRect(find.byKey(kTtcDoorHeroIntroKey));
        final field = tester.getRect(find.byKey(kTtcDoorSearchKey));
        final rail = tester.getRect(find.byKey(kTtcDoorRailKey));
        expect(field.top - intro.bottom, greaterThanOrEqualTo(12),
            reason: '${page.bracketId}: the search is against the intro');
        expect(rail.top - field.bottom, greaterThanOrEqualTo(12),
            reason: '${page.bracketId}: the search is against the rail');
        expect(
            rail.top,
            greaterThanOrEqualTo(
                tester.getRect(find.byKey(kTtcDoorHeroKey)).bottom),
            reason: '${page.bracketId}: the rail rides over the hero');
      }
    });

    testWidgets('the search is the white pill of Learn, named for the door',
        (tester) async {
      final page = kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_pcos');
      await pumpDoor(tester, page);
      expect(
          find.descendant(
              of: find.byKey(kTtcDoorSearchKey),
              matching: find.byType(BackdropFilter)),
          findsNothing);
      expect(tester.widget(find.byKey(kTtcDoorSearchKey)),
          isA<PvLiveSearchField>());
      expect(tester.getSize(find.byKey(kTtcDoorSearchKey)).height,
          kTtcDoorHeroSearchHeight);
      expect(find.text('Search PCOS'), findsOneWidget);
    });

    testWidgets('the headline and intro are ink on a ground they pass on',
        (tester) async {
      for (final page in kTtcFocusPages) {
        await pumpDoor(tester, page);
        final ground = (tester
                .widget<AnimatedContainer>(find.byKey(kTtcDoorHeroGroundKey))
                .decoration! as BoxDecoration)
            .color!;
        for (final k in [kTtcDoorHeroTitleKey, kTtcDoorHeroIntroKey]) {
          final c = tester.widget<Text>(find.byKey(k)).style!.color!;
          expect(ttcContrast(c, ground), greaterThanOrEqualTo(7),
              reason: '${page.bracketId}: $k at '
                  '${ttcContrast(c, ground).toStringAsFixed(2)}:1');
        }
      }
    });

    test('the ground keeps a pastel as it is and lifts a dark edge', () {
      const ink = Color(0xFF201C24);
      // The onboarding set's grounds: kept, so art and page are one colour.
      for (final pastel in const [
        Color(0xFFE6CFAF),
        Color(0xFFD5C2E0),
        Color(0xFFE5B3B6),
      ]) {
        expect(ttcDoorHeroGround(pastel, ink), pastel);
      }
      // The door photographs' left edges, sampled 2026-09-29: lifted.
      for (final edge in const [
        Color(0xFFA98B4C),
        Color(0xFF785037),
        Color(0xFF9C7557),
      ]) {
        final g = ttcDoorHeroGround(edge, ink);
        expect(ttcContrast(ink, g), greaterThanOrEqualTo(7));
      }
    });

    testWidgets('no overflow at 360 and 1.5x text on any door',
        (tester) async {
      for (final page in kTtcFocusPages) {
        await pumpScaled(tester, page);
        expect(tester.takeException(), isNull, reason: page.bracketId);
        final art = tester.getRect(find.byKey(kTtcDoorHeroArtKey));
        expect(tester.getRect(find.byKey(kTtcDoorHeroTitleKey)).top,
            greaterThanOrEqualTo(art.bottom),
            reason: page.bracketId);
      }
    });

    testWidgets('until the art exists, the door photograph fills the frame',
        (tester) async {
      for (final page in kTtcFocusPages) {
        await pumpDoor(tester, page);
        await tester.pump(const Duration(milliseconds: 100));
        final asset = ttcDoorHeroArtAsset(page.bracketId)!;
        final img = tester.widget<Image>(find.descendant(
            of: find.byKey(kTtcDoorHeroArtKey), matching: find.byType(Image)));
        var provider = img.image;
        if (provider is ResizeImage) provider = provider.imageProvider;
        if (File(asset).existsSync()) {
          expect(provider, isA<AssetImage>(), reason: page.bracketId);
          expect((provider as AssetImage).assetName, asset);
        } else {
          expect(provider, isA<NetworkImage>(), reason: page.bracketId);
          expect((provider as NetworkImage).url, page.heroImageUrl);
        }
      }
    });

    test('every door has an art slot, and any art present is 3:2', () {
      expect(kTtcDoorHeroArtSlug.keys.toSet(),
          {for (final p in kTtcFocusPages) p.bracketId});
      expect(kTtcDoorHeroArtSlug.values.toSet(), hasLength(9));
      final dir = Directory('assets/doors');
      if (!dir.existsSync()) return;
      for (final f in dir.listSync().whereType<File>()) {
        final name = f.uri.pathSegments.last;
        if (!name.startsWith('hero_')) continue;
        final size = _jpegSize(f.readAsBytesSync());
        expect(size, isNotNull, reason: '$name is not a JPEG');
        expect(size!.width / size.height, closeTo(1.5, 0.01),
            reason: '$name is ${size.width}x${size.height}, not 3:2: the '
                'frame would letterbox it');
        expect(kTtcDoorHeroArtSlug.values,
            contains(name.substring(5, name.length - 4)),
            reason: '$name has no door');
      }
    });
  });

  // ===========================================================================
  //  One heading style (2026-09-27, the user: "don't add random fonts").
  group('one heading style', () {
    testWidgets('every section heading on every tab of every door',
        (tester) async {
      final want = ttcDoorHeadingStyle(V2PaletteStore.instance.current);
      var checked = 0;
      for (final page in kTtcFocusPages) {
        await pumpDoor(tester, page, height: 12000);
        for (var i = 0; i < page.groups!.length; i++) {
          await pickTab(tester, i);
          final g = page.groups![i];
          for (final s in page.sections.where((s) => s.group == g.id)) {
            final styles = find
                .text(s.heading, skipOffstage: false)
                .evaluate()
                .map((e) => (e.widget as Text).style);
            expect(
                styles.any((st) =>
                    st?.fontSize == want.fontSize &&
                    st?.fontFamily == want.fontFamily &&
                    st?.fontWeight == want.fontWeight),
                isTrue,
                reason: '${page.bracketId} / "${s.heading}" is not the '
                    'door heading style');
            checked++;
          }
        }
      }
      expect(checked, greaterThan(20));
    });

    testWidgets("Mind and body's Today panel uses it too", (tester) async {
      final want = ttcDoorHeadingStyle(V2PaletteStore.instance.current);
      final page =
          kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_mind_body');
      await pumpDoor(tester, page, height: 6000);
      // "Today's breath" since 2026-09-28 (launch sanity MB18, the Sanskar's
      // name for the same card). Kept for revert: "Today's breathing".
      for (final h in ["Today's movement", "Today's breath",
          'Two small things']) {
        final st = tester.widget<Text>(find.text(h)).style!;
        expect(st.fontFamily, want.fontFamily, reason: h);
        expect(st.fontSize, want.fontSize, reason: h);
      }
    });
  });

  // ===========================================================================
  group('the pinned red flag, in the new form', () {
    testWidgets(
      'After a loss opens on the hospital flag, the read\'s own words',
      (tester) async {
        final page = kTtcFocusPages.firstWhere(
          (p) => p.bracketId == 'ttc_after_loss',
        );
        await pumpDoor(tester, page);
        final rid = page.groups!.first.pinnedRedFlagReadIds.first;
        expect(find.byKey(ttcDoorFlagKey(rid)), findsOneWidget);
        final read = ttcReadById(rid)!;
        // The quiet row (2026-09-30) says "When to go to hospital"; the read's
        // own title heads the list it opens. Kept for revert:
        //   expect(find.text(read.whenToSeeSomeone.title.en), findsOneWidget);
        expect(find.text(kTtcDoorFlagQuietTitle), findsOneWidget);
        // FOLDED since 2026-09-27: the tab shows one compact row with the
        // read's own title; the lines open in a sheet from it. Kept for
        // revert: the lines were on the tab itself, before any tap.
        expect(find.byType(TtcDoorFlagRow), findsOneWidget);
        await tester.tap(find.byKey(ttcDoorFlagKey(rid)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        // Whole, not an excerpt: one line per sentence since 2026-09-26
        // (review D2), every sentence the read's own, in order. Kept for
        // revert: find.text(read.whenToSeeSomeone.body.en), findsOneWidget.
        final lines = ttcFlagLines(read.whenToSeeSomeone.body.en);
        expect(lines, isNotEmpty);
        for (final l in lines) {
          expect(find.text(l), findsOneWidget, reason: l);
        }
        for (final para in ttcFlagProse(read.whenToSeeSomeone.body.en)) {
          expect(find.text(para), findsOneWidget, reason: para);
        }
      },
    );

    // ⚠️ SINCE 2026-09-28 (the user's option B) ONLY THE TABS IN
    // `kTtcDoorFlagTabs` OPEN ON A SAFETY LINE, and there as one short line.
    // This used to walk Mind & body, whose Hard days and Talk tabs both
    // carried the folded row; they no longer do (test/ttc_get_help_test.dart
    // holds that). Kept for revert, the old walk:
    //   page = mind_body; for each tab with pinnedRedFlagReadIds: pick it,
    //   expect the row findsOneWidget, height < 90, above every heading.
    testWidgets('the folded flag is compact and sits above the content',
        (tester) async {
      final page =
          kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_after_loss');
      await pumpDoor(tester, page, height: 6000);
      var seen = 0;
      for (var i = 0; i < page.groups!.length; i++) {
        final g = page.groups![i];
        if (g.pinnedRedFlagReadIds.isEmpty) continue;
        if (!ttcDoorShowsFlag(page.bracketId, g.id)) continue;
        await pickTab(tester, i);
        for (final rid in g.pinnedRedFlagReadIds) {
          final row = find.byKey(ttcDoorFlagKey(rid), skipOffstage: false);
          expect(row, findsOneWidget, reason: rid);
          // One short row (2026-09-28); two quiet lines since 2026-09-30.
          // Kept for revert: lessThan(90), then lessThan(60).
          expect(tester.getSize(row).height, lessThan(90),
              reason: '$rid: the flag is a block again, not a line');
          seen++;
        }
        // ⚠️ AFTER THE FIRST SHELF SINCE 2026-09-30 (the user: "is it
        // necessary to be on the top?"): below the tab's first heading and
        // above its second. Kept for revert: above every section heading.
        final flagTop = tester
            .getTopLeft(find.byKey(ttcDoorFlagKey(g.pinnedRedFlagReadIds.first),
                skipOffstage: false))
            .dy;
        final heads = [
          for (final s in page.sections.where((s) => s.group == g.id))
            tester.getTopLeft(find.text(s.heading, skipOffstage: false).first).dy,
        ];
        expect(heads.first, lessThan(flagTop),
            reason: '${g.id}: the flag sits above the first shelf');
        if (heads.length > 1) {
          expect(heads[1], greaterThan(flagTop),
              reason: '${g.id}: the flag is not right after the first shelf');
        }
      }
      expect(seen, greaterThan(0));
    });

    // Reversed 2026-09-28 (the user's option B): Talk opens on its content,
    // and both reads keep their lists in their own "When to see someone".
    // Kept for revert: expect(find.byKey(ttcDoorFlagKey(rid), ...),
    // findsOneWidget) for each of Talk's two pinned reads.
    testWidgets('Mind and body Talk no longer opens on its two flags',
        (tester) async {
      final page = kTtcFocusPages.firstWhere(
        (p) => p.bracketId == 'ttc_mind_body',
      );
      await pumpDoor(tester, page, height: 6000);
      final talk = page.groups!.indexWhere((g) => g.id == 'talk');
      await pickTab(tester, talk);
      expect(page.groups![talk].pinnedRedFlagReadIds, isNotEmpty,
          reason: 'the data keeps the pin, so turning it back on is one line');
      for (final rid in page.groups![talk].pinnedRedFlagReadIds) {
        expect(
          find.byKey(ttcDoorFlagKey(rid), skipOffstage: false),
          findsNothing,
          reason: rid,
        );
      }
    });
  });

  // ===========================================================================
  group('search', () {
    testWidgets('the field is in every door, and typing finds pieces', (
      tester,
    ) async {
      final page = kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_pcos');
      await pumpDoor(tester, page, height: 4000);
      expect(find.byKey(kTtcDoorSearchKey), findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: find.byKey(kTtcDoorSearchKey),
          matching: find.byType(TextField),
        ),
        'pcos',
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      expect(find.byKey(ttcDoorSearchHitKey(0)), findsOneWidget);
      expect(find.text('Ask Veda about "pcos"'), findsOneWidget);
    });

    test('the index holds this door first, then the library', () {
      final page = kTtcFocusPages.firstWhere(
        (p) => p.bracketId == 'ttc_conceiving',
      );
      final b = bracketById(page.bracketId)!;
      final index = ttcDoorSearchIndex(page, b, AppLanguage.english);
      expect(index.first.tile, isNotNull);
      expect(
        index.any((h) => h.readId != null),
        isTrue,
        reason: 'the rest of the TTC library is not searchable from a door',
      );
    });

    test('a word matches where a word starts', () {
      final page = kTtcFocusPages.firstWhere(
        (p) => p.bracketId == 'ttc_conceiving',
      );
      final index = ttcDoorSearchIndex(
        page,
        bracketById(page.bracketId)!,
        AppLanguage.english,
      );
      expect(ttcDoorSearch('ovulation', index), isNotEmpty);
      expect(ttcDoorSearch('zzzqqq', index), isEmpty);
    });
  });

  // ===========================================================================
  group('the wiring gate: every door opener opens the new door', () {
    testWidgets('openTtcDoor pushes TtcDoorScreen under the old route name', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      String? pushed;
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [_Names((n) => pushed = n)],
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => openTtcDoor(context, 'ttc_pcos'),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(TtcDoorScreen), findsOneWidget);
      expect(pushed, 'ttc/focus/ttc_pcos');
      expect(tester.takeException(), isNull);
    });

    test('an unknown bracket opens nothing', () {
      expect(ttcFocusPageFor('ttc_nowhere'), isNull);
    });

    test('the home opens the new door', () {
      final body = _fn(
        _src('lib/screens/ttc/ttc_home_v3.dart'),
        'void _openBracket(BuildContext context, String id)',
      );
      final live = _live(body).join('\n');
      expect(
        live.contains('openTtcDoor(context, id)'),
        isTrue,
        reason: 'the home no longer opens doors through openTtcDoor',
      );
      expect(
        live.contains('TtcFocusScreen('),
        isFalse,
        reason: 'the home pushes the old door again',
      );
    });

    test('the semen report and a door-to-door tile open the new door', () {
      final semen = _live(
        _src('lib/screens/ttc/ttc_semen_report_screen.dart'),
      ).join('\n');
      expect(semen.contains('openTtcDoor(context, _kIvfBracket)'), isTrue);
      expect(semen.contains('TtcFocusScreen('), isFalse);

      final focus = _live(_src('lib/screens/ttc/ttc_focus_screen.dart'));
      final pushes = focus.where(
        (l) => l.contains('builder: (_) => TtcFocusScreen('),
      );
      expect(pushes, isEmpty, reason: 'something still pushes the old door');
      expect(
        // A door tile may name the tab it opens on (2026-09-27), so the call
        // carries `initialGroup:`. Kept for revert: 'openTtcDoor(context, bracketId)'.
        focus.any((l) => l.contains('openTtcDoor(context, bracketId')),
        isTrue,
      );
    });
  });

  // ===========================================================================
  //  "Starting treatment?" on the IVF & IUI door (2026-09-26,
  //  docs/TTC-TREATMENT-FLOW.md §2b): the obvious way into a round, above the
  //  tabs, only while no round is saved, and every tab still in its place.
  // ===========================================================================
  group('the IVF door leads with "Starting treatment?"', () {
    setUp(() => TtcTreatmentStore.instance.resetForTest());

    testWidgets('while no round is saved, and not once one is',
        (tester) async {
      final page = ttcFocusPageFor(kTtcIvfBracketId)!;
      await pumpDoor(tester, page);
      expect(find.byType(TtcStartTreatmentCard), findsOneWidget);
      final tabs = page.groups!.length;
      expect(find.byType(TtcDoorRail), findsOneWidget,
          reason: 'additive: the rail and its $tabs tabs stay');

      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.stimStart: DateTime.now()});
      await tester.pump();
      expect(find.byType(TtcStartTreatmentCard), findsNothing);
    });

    testWidgets('no other door carries it', (tester) async {
      final other = kTtcFocusPages
          .firstWhere((p) => p.bracketId != kTtcIvfBracketId);
      await pumpDoor(tester, other);
      expect(find.byType(TtcStartTreatmentCard), findsNothing);
    });
  });

  // ===========================================================================
  //  The review fixes (2026-09-26, Mobbin review D1, D2, D3, D5)
  // ===========================================================================
  group('the review fixes', () {
    test('D2: every pinned flag splits into its own sentences, words untouched',
        () {
      String norm(String x) => x.replaceAll(RegExp(r'\s+'), ' ').trim();
      var checked = 0;
      for (final page in kTtcFocusPages) {
        for (final g in page.groups ?? const <TtcFocusGroup>[]) {
          for (final rid in g.pinnedRedFlagReadIds) {
            final read = ttcReadById(rid);
            if (read == null) continue;
            final body = read.whenToSeeSomeone.body.en;
            final lines = ttcFlagLines(body);
            // Signs as lines, the closing advice as paragraphs (2026-09-27):
            // together still exactly the read's own words.
            final prose = ttcFlagProse(body);
            expect(norm([...lines, ...prose].join(' ')), norm(body),
                reason: '$rid: the lines must be the read\'s own words');
            // One sentence per line. A sentence is never cut: the longest
            // today is one 52-word list in when_to_seek_help, and shortening
            // it is the read's job, not the door's (owed, see the report).
            for (final l in lines) {
              expect(l.split(' ').length, lessThan(60), reason: '$rid: $l');
            }
            checked++;
          }
        }
      }
      expect(checked, greaterThan(0));
      expect(ttcFlagLines('See Dr. Rao today. Then rest.'),
          ['See Dr. Rao today.', 'Then rest.']);
      expect(ttcFlagLines('Call 112. or go now.'), ['Call 112. or go now.']);
    });

    testWidgets('D1: a door that predicts nothing says "not medical advice"',
        (tester) async {
      final page = kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_mind_body');
      await pumpDoor(tester, page, height: 8000);
      expect(find.text(TtcS.current().doorDisclaimer, skipOffstage: false),
          findsOneWidget);
      expect(
          find.textContaining('These are estimates', skipOffstage: false),
          findsNothing);
      expect(ttcDoorDisclaimerFor('ttc_conceiving'),
          contains('These are estimates'),
          reason: 'the door that estimates keeps the estimates line');
      expect(ttcDoorDisclaimerFor('ttc_conceiving'), contains('not medical advice'));
    });

    // Launch sanity D5 (2026-09-28): the estimates line only under the tabs
    // that estimate. Kept for revert: the door-wide expectation above only.
    test('D5: the estimates line sits only under tabs that estimate', () {
      expect(ttcDoorDisclaimerFor('ttc_conceiving', 'trying'),
          contains('These are estimates'));
      expect(ttcDoorDisclaimerFor('ttc_conceiving', 'waiting'),
          contains('These are estimates'));
      for (final tab in ['sex', 'his', 'hers', 'doctor']) {
        expect(ttcDoorDisclaimerFor('ttc_conceiving', tab),
            isNot(contains('These are estimates')),
            reason: 'Fertile window › $tab estimates nothing');
        expect(ttcDoorDisclaimerFor('ttc_conceiving', tab),
            contains('not medical advice'));
      }
      // Every tab named in the rule is a real tab of its door.
      for (final e in kTtcDoorEstimateTabs.entries) {
        final ids = {for (final g in ttcFocusPageFor(e.key)!.groups!) g.id};
        expect(ids.containsAll(e.value), isTrue, reason: e.key);
      }
    });

    test('D3: the Search key with no match no longer jumps into Ask Veda', () {
      final src = _src('lib/screens/ttc/doors/ttc_door_screen.dart');
      final start = src.indexOf('onSubmitted: (q) {');
      final body = src.substring(start, src.indexOf('},', start));
      expect(
          _live(body).any((l) => l.contains('openTtcAskVeda(')), isFalse,
          reason: 'a silent jump into AI on the keyboard key');
    });

    testWidgets('D5: the whole flag opens its read', (tester) async {
      final page =
          kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_after_loss');
      final names = <String?>[];
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [_Names(names.add)],
        home: TtcDoorScreen(
            page: page, bracket: bracketById(page.bracketId)!),
      ));
      await tester.pump(const Duration(milliseconds: 400));
      final rid = page.groups!.first.pinnedRedFlagReadIds.first;
      // The quiet row carries its own title (2026-09-30). Kept for revert:
      //   await tester.tap(find.text(ttcReadById(rid)!.whenToSeeSomeone.title.en));
      final row = find.byKey(ttcDoorFlagKey(rid));
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      expect(names.length, greaterThan(1), reason: 'the flag opened nothing');
      // Folded since 2026-09-27: the row opens the sheet, and the sheet's
      // "Read the full piece" (a 44pt row) opens the read. Kept for revert:
      // the tap on the title opened the read directly, and the size check
      // below was the whole of the second half.
      final size = tester.getSize(find.text('Read the full piece'));
      expect(size.height, greaterThan(0));
      final before = names.length;
      await tester.tap(find.text('Read the full piece'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(names.length, greaterThan(before),
          reason: 'the sheet did not open the read');
    });
  });

  // ===========================================================================
  //  The IVF door, first thing (2026-09-26, docs/TTC-TREATMENT-FLOW.md §3f, B7)
  // ===========================================================================
  group('the IVF door follows the round', () {
    setUp(() => TtcTreatmentStore.instance.resetForTest());
    tearDown(() => TtcTreatmentStore.instance.resetForTest());

    DateTime day(int n) {
      final t = DateTime.now();
      return DateTime(t.year, t.month, t.day + n);
    }

    void running() => TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {
            TtcTreatmentStep.baselineScan: day(-6),
            TtcTreatmentStep.stimStart: day(-5),
            TtcTreatmentStep.retrieval: day(4),
            TtcTreatmentStep.betaTest: day(20),
          },
          scans: [day(1)],
        );

    testWidgets('a running round: "Your round" first, its tabs lead',
        (tester) async {
      running();
      expect(ttcIvfPanelNow(), TtcIvfPanel.round);
      expect(ttcIvfRoundLeads(), isTrue);
      final page = ttcFocusPageFor(kTtcIvfBracketId)!;
      await pumpDoor(tester, page);
      expect(find.byKey(const ValueKey('ttc_ivf_panel_round')), findsOneWidget);
      expect(find.byType(TtcStartTreatmentCard), findsNothing);
      expect(find.text('See the whole plan'), findsOneWidget);
      expect(find.textContaining('Next: Monitoring scan'), findsOneWidget);
      // Order only: "Going through it" then "Track" lead, every tab stays.
      final ordered = ttcDoorOrderedGroups(page.groups!,
          bracketId: kTtcIvfBracketId, ageBand: null, roundRunning: true);
      expect(ordered.take(2).map((g) => g.id), kTtcIvfRoundTabsFirst);
      expect(ordered.map((g) => g.id).toSet(),
          page.groups!.map((g) => g.id).toSet());
      // Kept for revert (2026-09-28, explicit names): 'Going through it'.
      expect(find.text('During a round'), findsWidgets);
      final going = tester.getTopLeft(find.byKey(ttcDoorRailCardKey(0)));
      expect(going.dx, lessThan(100));
    });

    testWidgets('no round: "Starting treatment?", the usual order',
        (tester) async {
      expect(ttcIvfPanelNow(), TtcIvfPanel.start);
      expect(ttcIvfRoundLeads(), isFalse);
      final page = ttcFocusPageFor(kTtcIvfBracketId)!;
      final same = ttcDoorOrderedGroups(page.groups!,
          bracketId: kTtcIvfBracketId, ageBand: null);
      expect(identical(same, page.groups), isTrue);
      await pumpDoor(tester, page);
      expect(find.byType(TtcStartTreatmentCard), findsOneWidget);
    });

    testWidgets('after "Not this time": "Between rounds", its reads, the next round',
        (tester) async {
      running();
      TtcTreatmentStore.instance.closeRound(TtcRoundOutcome.negative);
      expect(ttcIvfPanelNow(), TtcIvfPanel.between);
      expect(ttcIvfRoundLeads(), isFalse,
          reason: 'the usual order is back once the round closes');
      final page = ttcFocusPageFor(kTtcIvfBracketId)!;
      await pumpDoor(tester, page);
      expect(find.byKey(const ValueKey('ttc_ivf_panel_between')), findsOneWidget);
      for (final id in const [
        'ttc_read_tx_negative_after_treatment',
        'ttc_read_tx_review_appointment',
        'ttc_read_month_after_month',
      ]) {
        expect(ttcReadById(id), isNotNull, reason: id);
        expect(find.byKey(ValueKey('ttc_ivf_panel_read_$id')), findsOneWidget,
            reason: id);
      }
      expect(find.text('Start the next round'), findsOneWidget);
    });

    testWidgets('a paused round: between rounds, without the negative read',
        (tester) async {
      running();
      TtcTreatmentStore.instance.closeRound(TtcRoundOutcome.paused);
      final page = ttcFocusPageFor(kTtcIvfBracketId)!;
      await pumpDoor(tester, page);
      expect(
          find.byKey(const ValueKey(
              'ttc_ivf_panel_read_ttc_read_tx_negative_after_treatment')),
          findsNothing);
    });

    testWidgets('a positive round: the way to Pregnancy', (tester) async {
      running();
      TtcTreatmentStore.instance.closeRound(TtcRoundOutcome.positive);
      expect(ttcIvfPanelNow(), TtcIvfPanel.positive);
      final page = ttcFocusPageFor(kTtcIvfBracketId)!;
      await pumpDoor(tester, page);
      expect(find.byKey(const ValueKey('ttc_ivf_panel_positive')), findsOneWidget);
      expect(find.text('Move to Pregnancy'), findsOneWidget);
    });

    testWidgets('every panel fits at 360pt', (tester) async {
      for (final setup in <void Function()>[
        () {},
        running,
        () {
          running();
          TtcTreatmentStore.instance.closeRound(TtcRoundOutcome.negative);
        },
      ]) {
        TtcTreatmentStore.instance.resetForTest();
        setup();
        await tester.pumpWidget(MaterialApp(
          key: UniqueKey(),
          home: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(18),
              child: TtcIvfRoundPanel(),
            ),
          ),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });
  });
  // ===========================================================================
  //  Launch sanity, 2026-09-28 (docs/TTC-LAUNCH-SANITY.md, the doors rows)
  // ===========================================================================
  group('launch sanity', () {
    testWidgets('D2: a bar pins with back and the name once the hero goes',
        (tester) async {
      final page = kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_pcos');
      await pumpDoor(tester, page, height: 800);
      final bar = find.byKey(kTtcDoorPinnedBarKey);
      expect(bar, findsOneWidget);
      double opacity() => tester
          .widget<Opacity>(
              find.descendant(of: bar, matching: find.byType(Opacity)).first)
          .opacity;
      expect(opacity(), 0, reason: 'at the top the hero is the header');
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(opacity(), 1, reason: 'scrolled, the bar is in');
      expect(
          find.descendant(of: bar, matching: find.byTooltip('Back')),
          findsOneWidget);
      expect(
          find.descendant(
              of: bar, matching: find.text(bracketById('ttc_pcos')!.label.en)),
          findsOneWidget);
    });

    test('D3: an unmade film never promises minutes, and goes last', () {
      var films = 0;
      for (final page in kTtcFocusPages) {
        for (final s in page.sections) {
          for (final t in s.tiles.whereType<TtcVideoTile>()) {
            if (!ttcTileIsUnmadeFilm(t)) continue;
            films++;
            expect(ttcDoorTileMeta(t), kTtcFilmComingSoon, reason: t.title);
          }
          final rail = ttcDoorRailTiles(s.tiles);
          final firstUnmade = rail.indexWhere(ttcTileIsUnmadeFilm);
          if (firstUnmade >= 0) {
            expect(rail.skip(firstUnmade).every(ttcTileIsUnmadeFilm), isTrue,
                reason: '${s.heading}: a finished piece sits after a film '
                    'that is not made');
          }
        }
      }
      expect(films, greaterThan(0), reason: 'the rule is untested');
    });

    testWidgets('D3: an unmade film card wears a clock, not a play mark',
        (tester) async {
      final p = V2PaletteStore.instance.current;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Row(children: [
            TtcDoorSectionCard(
              p: p,
              hue: 200,
              mark: ttcDoorFormatMark(TtcTileFormat.video),
              icon: Icons.schedule_rounded,
              kind: 'Video',
              title: 'A film',
              meta: kTtcFilmComingSoon,
            ),
          ]),
        ),
      ));
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
      expect(find.text('Video · Coming soon'), findsOneWidget);
    });

    test('D6: search finds words inside a read, and brand names', () {
      final page =
          kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_conceiving');
      final b = bracketById(page.bracketId)!;
      final index = ttcDoorSearchIndex(page, b, AppLanguage.english,
          hideIntimate: false);
      expect(ttcDoorSearch('clomid', index), isNotEmpty,
          reason: 'Clomid is clomiphene');
      expect(ttcDoorSearch('duphaston', index), isNotEmpty,
          reason: 'Duphaston is a progesterone');
      expect(ttcDoorSearch('letroz', index), isNotEmpty);
      // A title match still leads a body match.
      final hits = ttcDoorSearch('ovulation', index);
      expect(hits.first.title.toLowerCase(), contains('ovulat'));
      // Two-letter words never search the body.
      expect(ttcDoorSearch('zq', index), isEmpty);
    });

    testWidgets('D6: no result offers words that find something',
        (tester) async {
      final page = kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_pcos');
      await pumpDoor(tester, page, height: 4000);
      await tester.enterText(
        find.descendant(
          of: find.byKey(kTtcDoorSearchKey),
          matching: find.byType(TextField),
        ),
        'zzqqxx',
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(kTtcDoorSearchEmptyKey), findsOneWidget);
      final b = bracketById(page.bracketId)!;
      final index = ttcDoorSearchIndex(page, b, AppLanguage.english,
          hideIntimate: false);
      for (final w in kTtcDoorSearchSuggestions) {
        // findsWidgets: "PCOS" is also the pinned bar's (hidden) title.
        expect(find.text(w), findsWidgets);
        expect(ttcDoorSearch(w, index), isNotEmpty,
            reason: 'the suggestion "$w" finds nothing');
      }
    });

    testWidgets('D10: the IVF round panel only on the tabs about a round',
        (tester) async {
      TtcTreatmentStore.instance.resetForTest();
      final page = ttcFocusPageFor(kTtcIvfBracketId)!;
      await pumpDoor(tester, page, height: 6000);
      for (var i = 0; i < page.groups!.length; i++) {
        await pickTab(tester, i);
        final id = page.groups![i].id;
        expect(find.byType(TtcIvfRoundPanel, skipOffstage: false),
            kTtcIvfPanelTabs.contains(id) ? findsOneWidget : findsNothing,
            reason: id);
      }
    });

    // RETIRED 2026-09-29: every shelf is Flo's small blocks now, a section
    // of one piece included (the user on build 21).
    testWidgets('D13: a section of one piece is one wide card',
        skip: true,
        (tester) async {
      final page = kTtcFocusPages
          .firstWhere((p) => p.bracketId == 'ttc_male_fertility');
      await pumpDoor(tester, page, height: 6000);
      final improve = page.groups!.indexWhere((g) => g.id == 'improve');
      await pickTab(tester, improve);
      final wide = find.byKey(
          ttcDoorSectionWideKey('Keep track of what he changes'),
          skipOffstage: false);
      expect(wide, findsOneWidget);
      expect(tester.getSize(wide).width, greaterThan(kTtcDoorCardWidth * 1.5));
      expect(page.groups!.any((g) => g.id == 'track'), isFalse,
          reason: 'the two-tool Track tab folded into its neighbours');
    });

    testWidgets('D15: the urgent sheet can call the emergency number',
        (tester) async {
      final page =
          kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_after_loss');
      final dialled = <String>[];
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: TtcDoorScreen(
          page: page,
          bracket: bracketById(page.bracketId)!,
          initialGroup: 'body',
          dial: (n) async => dialled.add(n),
        ),
      ));
      await tester.pumpAndSettle();
      final rid = page.groups!
          .firstWhere((g) => g.id == 'body')
          .pinnedRedFlagReadIds
          .first;
      await tester.tap(find.byKey(ttcDoorFlagKey(rid)));
      await tester.pumpAndSettle();
      final call = find.byKey(ttcDoorCallKey('112'));
      expect(call, findsOneWidget);
      await tester.ensureVisible(call);
      await tester.tap(call);
      await tester.pumpAndSettle();
      expect(dialled, ['112']);
      // And 108 for an ambulance, under it (2026-09-28).
      final amb = find.byKey(ttcDoorCallKey('108'));
      expect(amb, findsOneWidget);
      expect(find.text('Call 108 for an ambulance'), findsOneWidget);
      await tester.ensureVisible(amb);
      await tester.tap(amb);
      await tester.pumpAndSettle();
      expect(dialled, ['112', '108']);
    });

    test('D14: every myth card is titled as a question', () {
      for (final page in kTtcFocusPages) {
        for (final s in page.sections) {
          for (final t in s.tiles.whereType<TtcMythTile>()) {
            expect(t.title.trim().endsWith('?'), isTrue,
                reason: '${page.bracketId}: "${t.title}" under a Myth vs fact '
                    'chip reads as a statement');
          }
        }
      }
    });

    test('D16: a tool card on a door uses the tool\'s own name', () {
      final page =
          kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_body_cycle');
      final titles = {
        for (final s in page.sections)
          for (final t in s.tiles.whereType<TtcToolTile>()) t.surfaceId: t.title,
      };
      expect(titles['ttc_cycle'], 'Cycle companion');
      expect(titles['ttc_symptom_log'], 'Symptoms and mood');
    });

    test('D17: See a doctor leads with the doctor', () {
      final page =
          kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_body_cycle');
      final first = page.sections.firstWhere((s) => s.group == 'doctor');
      expect(first.tiles.single, isA<TtcTalkTile>());
    });

    test('MB16: an Article chip always wears the page mark', () {
      expect(ttcDoorFormatMark(TtcTileFormat.guide),
          ttcDoorFormatMark(TtcTileFormat.article));
    });

    test('MB20: no tab shares its name with a door', () {
      final doors = {for (final p in kTtcFocusPages) bracketById(p.bracketId)!.label.en};
      for (final page in kTtcFocusPages) {
        for (final g in page.groups!) {
          expect(doors.contains(g.label), isFalse,
              reason: '${page.bracketId} › "${g.label}" is also a door');
        }
      }
    });

    testWidgets('MB9: the closing line leads in the hero, not at every foot',
        (tester) async {
      final page =
          kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_mind_body');
      expect(page.heroBlurb, contains(page.closingLine!));
      await pumpDoor(tester, page, height: 8000);
      for (var i = 1; i < page.groups!.length; i++) {
        await pickTab(tester, i);
        // Once, in the hero; never again at the foot of a tab.
        expect(find.text(page.closingLine!, skipOffstage: false), findsNothing,
            reason: page.groups![i].id);
      }
    });

    test('MB15: a practice says Practice, how long, and its own kind', () {
      final page =
          kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_mind_body');
      final practices = [
        for (final s in page.sections)
          for (final t in s.tiles)
            if (ttcTilePractice(t) != null) t,
      ];
      expect(practices, isNotEmpty);
      for (final t in practices) {
        expect(ttcDoorChip(t), 'Practice');
        expect(ttcDoorTileMeta(t), contains('min'), reason: t.title);
      }
      final marks = {for (final t in practices) ttcDoorTileMark(t)};
      expect(marks, containsAll([IntentMark.stepsMark, IntentMark.windMark]),
          reason: 'a movement and a breath wear different marks');
    });
  });
}

class _Names extends NavigatorObserver {
  _Names(this.onPush);
  final void Function(String?) onPush;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onPush(route.settings.name);
}

/// A JPEG's pixel size, from its first start-of-frame marker.
Size? _jpegSize(List<int> b) {
  if (b.length < 4 || b[0] != 0xFF || b[1] != 0xD8) return null;
  var i = 2;
  while (i + 9 < b.length) {
    if (b[i] != 0xFF) return null;
    final m = b[i + 1];
    final len = (b[i + 2] << 8) | b[i + 3];
    if (m >= 0xC0 && m <= 0xCF && m != 0xC4 && m != 0xC8 && m != 0xCC) {
      final h = (b[i + 5] << 8) | b[i + 6];
      final w = (b[i + 7] << 8) | b[i + 8];
      return Size(w.toDouble(), h.toDouble());
    }
    i += 2 + len;
  }
  return null;
}
