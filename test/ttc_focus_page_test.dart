// =============================================================================
//  The conceiving focus page
// -----------------------------------------------------------------------------
//  ⚠️ THE RISK ON A PAGE LIKE THIS IS TWENTY-FIVE TILES THAT LOOK FINE AND OPEN
//  NOTHING. Every tile is a title, a blurb and a chip; none of that fails to
//  render if the id underneath it is wrong. A read id with a typo, a product
//  that was renamed, an offering that moved category — all four render a
//  perfect tile and do nothing when tapped, and the only way to find them by
//  hand is to tap all twenty-five.
//
//  So the first group resolves every id against the data it points into. That
//  is the wiring gate in CLAUDE.md, applied to content rather than to screens.
//
//  The second group holds the structure the page was specified with — section
//  order, the three-level hierarchy, and which tiles cost money. Those are
//  product decisions, and a product decision that nothing asserts is a
//  suggestion.
// =============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/data/hubs/hub_registry.dart';
import 'package:parentveda/data/hubs/ttc_hubs.dart';
import 'package:parentveda/screens/ttc/ttc_focus_screen.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_prepare_data.dart';
import 'package:parentveda/data/nutrition_data.dart' show kRecipes;
import 'package:parentveda/ttc/ttc_products_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

/// ⚠️ WITHOUT THIS, ANY SCREEN WITH AN `Image.network` FAILS ITS WIDGET TEST.
///
/// `flutter_test` installs an HTTP client that returns 400 for every request,
/// so a real image URL throws during layout and the whole pump fails — which
/// reads as "the page is broken" rather than "the test has no network". The
/// convention is to override the client with one that returns a 1x1 PNG.
///
/// The fallback path is worth testing on its own one day: `TtcHeroArt` is
/// supposed to draw the illustration when a photo cannot load, and that is the
/// behaviour a real user on a train actually gets.
class _StubHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? _) =>
      _StubClient();
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

/// A 1x1 transparent PNG — the smallest thing `Image.network` will decode.
final _kPixel = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
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
  }) =>
      Stream<List<int>>.value(_kPixel).listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  HttpOverrides.global = _StubHttpOverrides();

  final page = kTtcConceivingFocus;

  // ===========================================================================
  //  ⚠️ THIS GROUP RUNS OVER EVERY FOCUS PAGE, NOT JUST CONCEIVING.
  //
  //  It was written for one page and pinned to `kTtcConceivingFocus`, which was
  //  correct while there was one. The moment PCOS became the second, that
  //  pinning turned into a silent hole: a whole page of tiles could ship with
  //  dead read ids, a renamed product and a missing offering, and this file
  //  would still pass — because it was not looking.
  //
  //  A reachability test that names the thing it checks stops being a gate the
  //  first time someone adds a second thing. Iterating `kTtcFocusPages` means a
  //  third page is covered on the day it is added rather than on the day
  //  someone remembers to widen the test.
  //
  //  The structural group further down stays pinned to conceiving on purpose:
  //  section order and which tiles cost money are decisions about THAT page.
  for (final page in kTtcFocusPages) {
    group('every tile opens something real — ${page.bracketId}', () {
    test('the tool points at a surface the router knows', () {
      for (final tile in page.allTiles.whereType<TtcToolTile>()) {
        expect(ttcScreenForSurface(tile.surfaceId), isNotNull,
            reason: '"${tile.title}" opens surface "${tile.surfaceId}", which '
                'the router does not resolve — the tile is dead');
      }
    });

    test('every read id exists in the library', () {
      final ids = <String>[];
      for (final tile in page.allTiles.whereType<TtcArticleTile>()) {
        if (tile.readId != null) ids.add(tile.readId!);
        if (tile.moreReadId != null) ids.add(tile.moreReadId!);
      }
      expect(ids, isNotEmpty, reason: 'no article points at a real read');
      for (final id in ids) {
        expect(ttcReadById(id), isNotNull,
            reason: '"$id" is not in kTtcReads');
      }
    });

    test('every product id exists in the catalogue', () {
      for (final tile in page.allTiles.whereType<TtcProductTile>()) {
        expect(ttcProducts.any((p) => p.id == tile.productId), isTrue,
            reason: '"${tile.title}" points at product "${tile.productId}"');
      }
    });

    test('every recipe id exists in the catalogue', () {
      // ⚠️ THE NEWEST ID AND THEREFORE THE LIKELIEST TO ROT. A recipe tile
      // renders a perfect card from its own title and blurb whatever is
      // underneath it; `openTtcFocusTile` then throws on the tap. Better here
      // than on a phone.
      for (final tile in page.allTiles.whereType<TtcRecipeTile>()) {
        expect(kRecipes.any((r) => r.id == tile.recipeId), isTrue,
            reason: '"${tile.title}" points at recipe "${tile.recipeId}", '
                'which is not in kRecipes');
      }
    });

    test('the masterclass points at a real paid offering', () {
      for (final tile in page.allTiles.whereType<TtcMasterclassTile>()) {
        final offering = ttcOfferingById(tile.offeringId);
        expect(offering, isNotNull,
            reason: '"${tile.title}" points at "${tile.offeringId}"');
        // ⚠️ AND IT ACTUALLY COSTS MONEY. A "paid" tile pointing at a free
        // item would be a worse lie than the reverse.
        expect(offering!.priceMinor, greaterThan(0));
      }
    });

    test('the booking uses the shared consult action, not a new flow', () {
      final bookings = page.allTiles.whereType<TtcBookingTile>().toList();
      expect(bookings, hasLength(1));
      expect(bookings.first.action, kTtcActConsult,
          reason: 'a second booking action means a second booking flow');
    });

    test('an article without a read has a body, and never both empty', () {
      for (final tile in page.allTiles.whereType<TtcArticleTile>()) {
        final hasSomething = tile.readId != null || tile.body.isNotEmpty;
        expect(hasSomething, isTrue,
            reason: '"${tile.title}" opens an empty sheet');
      }
    });

    test('every carousel has cards, and every card has both halves', () {
      final carousels = page.allTiles.whereType<TtcCarouselTile>().toList();
      expect(carousels, isNotEmpty);
      for (final tile in carousels) {
        expect(tile.cards, isNotEmpty, reason: '"${tile.title}" is empty');
        for (final card in tile.cards) {
          expect(card.title, isNotEmpty);
          expect(card.body, isNotEmpty);
        }
      }
    });

    test('every myth tile states both the claim and the truth', () {
      for (final tile in page.allTiles.whereType<TtcMythTile>()) {
        expect(tile.myth, isNotEmpty);
        expect(tile.fact, isNotEmpty);
        expect(tile.myth, isNot(tile.fact));
      }
    });

    test('every video declares the slot a file will be mapped to', () {
      final videos = page.allTiles.whereType<TtcVideoTile>().toList();
      expect(videos, isNotEmpty);
      final slots = videos.map((v) => v.slotId).toList();
      expect(slots.toSet().length, slots.length,
          reason: 'two films share a slot, so one can never be delivered');
    });

    test('and every tile has a blurb — a title alone is not a tile', () {
      for (final tile in page.allTiles) {
        expect(tile.blurb, isNotEmpty, reason: tile.title);
        expect(tile.title, isNotEmpty);
      }
    });
  });

  }

  // ===========================================================================
  group('the page is shaped the way it was specified', () {
    test('there is no middle menu — the bracket has no hub any more', () {
      // ⚠️ THE ACTUAL MERGE, ASSERTED. If `kTtcConceiving` is ever put back
      // into `kTtcHubs` without removing the focus page, `_openBracket` still
      // prefers the page and the hub becomes a second, invisible description of
      // the same area.
      expect(hubFor('ttc_conceiving'), isNull,
          reason: 'the conceiving hub is registered again, so there are two '
              'descriptions of one area');
      expect(ttcFocusPageFor('ttc_conceiving'), isNotNull);
    });

    test('the tool is the first tile of the first section', () {
      // It used to be one of three cards on a menu in front of this page.
      expect(page.sections.first.tiles.first, isA<TtcToolTile>());
    });

    test('the sections are in the specified order', () {
      expect(page.sections.map((s) => s.heading).toList(), [
        'When should we have sex?',
        'How many times should we try?',
        'Which sex position is best?',
        'What he should do',
        'What she should do',
        'Does stress stop pregnancy?',
        'When should we see a doctor?',
      ]);
    });

    test('every section heading is a plain question or a plain phrase, '
        'never a format name', () {
      // ⚠️ THE HIERARCHY RULE. The moment "Articles" or "Videos" becomes a
      // heading, the page is organised by how it was built rather than by what
      // she wants to know.
      final formatWords =
          TtcTileFormat.values.map((f) => f.label.toLowerCase()).toSet();
      for (final section in page.sections) {
        expect(formatWords.contains(section.heading.toLowerCase()), isFalse,
            reason: '"${section.heading}" is a format, not a question');
      }
    });

    test('exactly two tiles cost money, and both are marked', () {
      final paid =
          page.allTiles.where((t) => t.format.isPaid).toList();
      expect(paid, hasLength(2));
      expect(paid.whereType<TtcMasterclassTile>(), hasLength(1));
      expect(paid.whereType<TtcProductTile>(), hasLength(1));
    });

    test('the masterclass sits above every section', () {
      expect(page.headline, isNotNull);
      expect(page.allTiles.first, same(page.headline));
    });

    test('the page closes on a person, not on a price', () {
      // Same call as the V3 home. The last thing she reads is that there is
      // someone to talk to.
      expect(page.sections.last.tiles.last, isA<TtcBookingTile>());
    });

    test('the heading is the bracket label, so it matches the tile tapped', () {
      // ⚠️ THE BUG THIS REPLACES. The page carried its own title, "Getting
      // pregnant", behind a tile reading "Fertile window" — she tapped one name
      // and arrived at another, which reads as landing on the wrong screen.
      // There is no page title any more; the screen uses `bracket.label`, so
      // the two are one string and cannot be edited apart.
      final bracket = bracketById(page.bracketId);
      expect(bracket, isNotNull);
      expect(bracket!.label.en, isNotEmpty);
    });
  });

  // ===========================================================================
  //  Tapping a piece of content opens that piece of content
  // ---------------------------------------------------------------------------
  //  ⚠️ A SOURCE SCAN, BECAUSE THE FAILURE IS INVISIBLE PER-TILE. Articles and
  //  carousels opened bottom sheets; myth-vs-fact was then missed for a whole
  //  round because it is the shortest content on the page and a sheet felt
  //  right for it. Each individual sheet looks fine. What is wrong is that two
  //  tiles carrying the same kind of chip behave differently, and no screenshot
  //  of one tile can show that.
  group('no format opens a bottom sheet', () {
    test('only the video still does, and that is the agreed exception', () {
      final src =
          File('lib/screens/ttc/ttc_focus_screen.dart').readAsStringSync();
      // Comments explaining the retirements are fine; a call is not.
      final calls = RegExp(r'^\s*showTtcRowSheet\(', multiLine: true)
          .allMatches(src)
          .length;

      // ⚠️ ONE, NOT ZERO, AND THE NUMBER IS THE ASSERTION. Article, carousel
      // and myth-vs-fact all open screens. The video placeholder deliberately
      // still opens a sheet — that was accepted explicitly while the video
      // treatment is still being decided.
      //
      // Pinning it at exactly one is what makes this useful in both
      // directions: it fails if a fourth format regresses to a sheet, AND it
      // fails when the video is finally converted, which is the moment someone
      // should come back and delete this test rather than leave a stale
      // exemption behind.
      expect(calls, 1,
          reason: calls > 1
              ? 'a tile is opening a sheet again — main content gets a screen'
              : 'the video no longer opens a sheet, so this exception is '
                  'stale: delete this test');
    });
  });

  // ===========================================================================
  group('it builds', () {
    testWidgets('the whole page renders, and the headings are on it',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 14000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final bracket = bracketById('ttc_conceiving');
      await tester.pumpWidget(MaterialApp(
          home: TtcFocusScreen(page: page, bracket: bracket!)));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);

      // The heading is the tile's own words.
      expect(find.text(bracket.label.en), findsWidgets);
      // ⚠️ THE INTRO LINE IS NO LONGER RENDERED. It sat between the film and
      // the paid tile saying what the film had just said, and both together
      // held the top of the page without earning it. The string stays on the
      // model — the sentiment is the stage's posture and wants a home again —
      // so this asserts the opposite of what it used to.
      expect(find.text(page.intro), findsNothing);
      for (final section in page.sections) {
        expect(find.text(section.heading), findsOneWidget,
            reason: '"${section.heading}" did not render');
      }
    });
  });
}
