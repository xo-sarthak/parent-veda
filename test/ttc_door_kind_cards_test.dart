// =============================================================================
//  One card family on every TTC door (2026-09-29, the user's reference picture)
// -----------------------------------------------------------------------------
//  What this holds (`ttc_kind_cards.dart`, DESIGN-SYSTEM §4.0f):
//    * all nine doors draw `TtcKindCard` for every piece, and nothing else:
//      no old photo card, no old wide card, no 2026-09-28 kind card;
//    * each kind renders its own tint and its pill, found by key;
//    * a tool and a chat are drawn, never a stock photo; a carousel shows
//      its slides stacked; a video, an article and a product show a photo;
//      a consult's picture is an object, never a face;
//    * a film that is not made never shows a play glyph, and says
//      "Coming soon" on its fact pill;
//    * "Paid" only where an offering has a price, never on a product;
//    * a read says its minutes only at 200 words or more (the reader's rule);
//    * one card height per door, and no overflow at 360pt at 1.0 and 1.5,
//      on the rail, in the grid width, and on every tab of every door;
//    * every tap lands where it did;
//    * every piece has a stable id, and the photo keys on it.
//
//  The 2026-09-28 tests (one SHAPE per kind, the Fertile window door only)
//  are kept at the foot of this file as comments, for revert.
// =============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/reads/read_images.dart' show readImageFor;
import 'package:parentveda/screens/ttc/doors/ttc_door_card.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_rail.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart';
import 'package:parentveda/screens/ttc/doors/ttc_kind_cards.dart';
import 'package:parentveda/screens/ttc/ttc_focus_screen.dart'
    show openTtcFocusTile, photoForTile, ttcTilePhotoId;
import 'package:parentveda/screens/ttc/ttc_tool_marks.dart' show TtcToolArt;
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';

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

/// Every piece a door draws as a card, on every door, with its tab.
List<(TtcFocusPage page, String group, String heading, TtcTile tile)>
_allPieces() => [
  for (final page in kTtcFocusPages)
    for (final s in page.sections)
      for (final t in ttcDoorRailTiles(s.tiles)) (page, s.group!, s.heading, t),
];

/// One piece of each kind, from whichever door has it first.
Map<TtcCardKind, TtcTile> _oneOfEachKind() {
  final out = <TtcCardKind, TtcTile>{};
  for (final (_, _, _, t) in _allPieces()) {
    out.putIfAbsent(ttcCardKindOf(t)!, () => t);
  }
  return out;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The one-time shared-phone offer (ttc_intimate_offer.dart) would open a
  // sheet over the door on the Sex and closeness tab; it is offered already.
  SharedPreferences.setMockInitialValues({'ttc_hide_intimate_offered': true});

  setUp(() => HttpOverrides.global = _StubHttpOverrides());
  tearDown(() => HttpOverrides.global = null);

  Future<void> pumpDoor(
    WidgetTester tester,
    TtcFocusPage page, {
    double width = 360,
    double height = 2400,
    double textScale = 1.0,
    List<NavigatorObserver> observers = const [],
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: observers,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: TtcDoorScreen(page: page, bracket: bracketById(page.bracketId)!),
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

  Future<void> pumpCard(
    WidgetTester tester,
    TtcTile t, {
    double textScale = 1.0,
    double width = kTtcKindCardWidth,
  }) async {
    tester.view.physicalSize = const Size(360, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final p = V2PaletteStore.instance.current;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: TtcKindCard(
              tile: t,
              kind: ttcCardKindOf(t)!,
              p: p,
              width: width,
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  // ===========================================================================
  group('one card family on all nine doors', () {
    test('the gate is gone: every piece on every door has a kind', () {
      expect(kTtcFocusPages.length, 9);
      final none = [
        for (final (page, _, h, t) in _allPieces())
          if (ttcCardKindOf(t) == null) '${page.bracketId} › $h › ${t.title}',
      ];
      expect(none, isEmpty, reason: 'pieces with no card: $none');
      // Only a way to another door has no card: it is a link row.
      expect(
        ttcCardKindOf(
          const TtcDoorTile(title: 'x', blurb: '', bracketId: 'ttc_pcos'),
        ),
        isNull,
      );
    });

    test('every kind has its own tint, and the reference\'s words', () {
      final grounds = {
        for (final k in TtcCardKind.values) ttcCardKindGround(k),
      };
      expect(
        grounds.length,
        TtcCardKind.values.length,
        reason: 'two kinds share a ground',
      );
      expect(ttcCardKindWord(TtcCardKind.video), 'Video');
      expect(ttcCardKindWord(TtcCardKind.read), 'Article');
      expect(ttcCardKindWord(TtcCardKind.story), 'Carousel');
      expect(ttcCardKindWord(TtcCardKind.product), 'Product');
      expect(ttcCardKindWord(TtcCardKind.tool), 'Tool');
      expect(ttcCardKindWord(TtcCardKind.consult), 'Talk to an expert');
      // Soft, never loud: every ground is paler than 90% lightness.
      for (final k in TtcCardKind.values) {
        expect(
          HSLColor.fromColor(ttcCardKindGround(k)).lightness,
          greaterThan(0.9),
          reason: k.name,
        );
      }
      // The reference's families: video rose, article blue, carousel lilac,
      // product green, tool amber, talk to an expert teal.
      expect(ttcCardKindHue(TtcCardKind.video), inInclusiveRange(330, 359));
      expect(ttcCardKindHue(TtcCardKind.read), inInclusiveRange(200, 225));
      expect(ttcCardKindHue(TtcCardKind.story), inInclusiveRange(255, 285));
      expect(ttcCardKindHue(TtcCardKind.product), inInclusiveRange(110, 150));
      expect(ttcCardKindHue(TtcCardKind.tool), inInclusiveRange(30, 50));
      expect(ttcCardKindHue(TtcCardKind.consult), inInclusiveRange(165, 190));
    });

    test('the doors carry the six kinds of the reference', () {
      expect(
        _oneOfEachKind().keys,
        containsAll(<TtcCardKind>{
          TtcCardKind.video,
          TtcCardKind.read,
          TtcCardKind.story,
          TtcCardKind.product,
          TtcCardKind.tool,
          TtcCardKind.consult,
        }),
      );
    });

    for (final page in kTtcFocusPages) {
      testWidgets('${page.bracketId}: every tab draws the family, only it', (
        tester,
      ) async {
        // Wide, so every card in every rail is built (a rail is lazy).
        await pumpDoor(tester, page, width: 1800, height: 9000);
        final groups = page.groups ?? const <TtcFocusGroup>[];
        for (var i = 0; i < groups.length; i++) {
          await pickTab(tester, i);
          for (final (pg, g, h, t) in _allPieces()) {
            if (pg != page || g != groups[i].id) continue;
            final kind = ttcCardKindOf(t)!;
            expect(
              find.byKey(ttcKindCardKey(kind, t.title), skipOffstage: false),
              findsOneWidget,
              reason: '$h › ${t.title} is not drawn as a ${kind.name}',
            );
          }
          expect(
            find.byType(TtcDoorSectionCard),
            findsNothing,
            reason: 'tab ${groups[i].id} still draws the old photo card',
          );
          expect(
            find.byType(TtcDoorWideCard),
            findsNothing,
            reason: 'tab ${groups[i].id} still draws the old wide card',
          );
          expect(find.byType(TtcKindCardV1), findsNothing);
          expect(tester.takeException(), isNull);
        }
      });
    }
  });

  // ===========================================================================
  group('each kind: its tint and its pill', () {
    for (final kind in TtcCardKind.values) {
      testWidgets(kind.name, (tester) async {
        final t = _oneOfEachKind()[kind];
        if (t == null) return; // a kind no door uses today
        await pumpCard(tester, t);
        final card = find.byKey(ttcKindCardKey(kind, t.title));
        expect(card, findsOneWidget);
        expect(tester.widget<Material>(card).color, ttcCardKindGround(kind));
        final pill = find.byKey(ttcKindPillKey(kind, t.title));
        expect(pill, findsOneWidget);
        expect(
          find.descendant(of: pill, matching: find.text(ttcCardKindWord(kind))),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: pill,
            matching: find.byIcon(ttcCardKindIcon(kind)),
          ),
          findsOneWidget,
        );
        // A serif title, a caption and a chevron on every card.
        expect(
          find.descendant(of: card, matching: find.text(t.title)),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: card,
            matching: find.byIcon(Icons.chevron_right_rounded),
          ),
          findsOneWidget,
        );
      });
    }
  });

  // ===========================================================================
  group('the picture follows the kind', () {
    testWidgets('a tool and a chat are drawn, never a stock photo', (
      tester,
    ) async {
      final drawn = [
        for (final (_, _, _, t) in _allPieces())
          if (ttcKindDrawsNoPhoto(ttcCardKindOf(t)!)) t,
      ];
      expect(drawn, isNotEmpty);
      for (final t in drawn) {
        await pumpCard(tester, t);
        final card = find.byKey(ttcKindCardKey(ttcCardKindOf(t)!, t.title));
        expect(
          find.descendant(of: card, matching: find.byType(Image)),
          findsNothing,
          reason: '${t.title} draws a photo',
        );
        expect(
          find.byKey(ttcKindDrawingKey(t.title)),
          findsOneWidget,
          reason: '${t.title} has no drawing',
        );
      }
    });

    testWidgets('a tool wears the Tools tab\'s own mark', (tester) async {
      final t = _allPieces()
          .map((e) => e.$4)
          .whereType<TtcToolTile>()
          .firstWhere((t) => t.surfaceId == 'ttc_window');
      await pumpCard(tester, t);
      expect(find.byType(TtcToolArt), findsOneWidget);
    });

    testWidgets('a carousel shows its slides stacked', (tester) async {
      final t = _allPieces()
          .map((e) => e.$4)
          .whereType<TtcCarouselTile>()
          .first;
      await pumpCard(tester, t);
      expect(find.byKey(ttcKindDeckKey(t.title)), findsOneWidget);
      expect(find.text('1. ${t.cards.first.title}'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(ttcKindMetaKey(t.title)),
          matching: find.text('${t.cards.length} slides'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a video, an article and a product show their photo', (
      tester,
    ) async {
      for (final kind in [
        TtcCardKind.video,
        TtcCardKind.read,
        TtcCardKind.product,
      ]) {
        final t = _oneOfEachKind()[kind]!;
        expect(photoForTile(t), isNotNull, reason: t.title);
        await pumpCard(tester, t);
        expect(
          find.descendant(
            of: find.byKey(ttcKindCardKey(kind, t.title)),
            matching: find.byType(Image),
          ),
          findsWidgets,
          reason: '${t.title} shows no photo',
        );
      }
    });

    testWidgets('a consult shows no face: its picture is an object', (
      tester,
    ) async {
      // The roster has no photographs yet (STILL-OPEN, the expert table), so
      // every consult picture is an object, never a stranger presented as
      // our expert. The ids are the ones looked at on 2026-09-29.
      const objects = {
        'ttc_tile_talk_to_a_doctor', // a stethoscope and a phone
        'ttc_tile_talk_to_a_pcos_specialist', // a stethoscope
        'ttc_tile_speak_to_a_fertility_specialist', // two stethoscopes
        'ttc_tile_talk_to_someone_before_you_start', // a shelf, a cup
        'ttc_tile_talk_to_a_nutritionist', // fruit on a board
        'ttc_tile_have_the_report_read_properly', // a report on a desk
        'ttc_tile_talk_to_an_andrologist', // a stethoscope
        'ttc_tile_someone_who_knows_this_kind_of_loss', // a cup held
        'ttc_tile_talk_to_a_psychologist', // a garden bench
        'ttc_tile_talk_to_a_fertility_doctor', // a stethoscope
      };
      final consults = [
        for (final (_, _, _, t) in _allPieces())
          if (ttcCardKindOf(t) == TtcCardKind.consult) t,
      ];
      expect(consults, isNotEmpty);
      for (final t in consults) {
        expect(
          objects,
          contains(t.id),
          reason: '${t.title} has a picture nobody checked for a face',
        );
      }
    });
  });

  // ===========================================================================
  group('no play glyph on a film that is not made', () {
    testWidgets('every film on every door', (tester) async {
      final films = [
        for (final (_, _, _, t) in _allPieces())
          if (t is TtcVideoTile) t,
      ];
      expect(films, isNotEmpty);
      for (final t in films) {
        await pumpCard(tester, t);
        final card = find.byKey(ttcKindCardKey(TtcCardKind.video, t.title));
        expect(card, findsOneWidget);
        if (!ttcTileIsUnmadeFilm(t)) continue;
        for (final icon in [
          Icons.play_arrow_rounded,
          Icons.play_circle_outline_rounded,
          Icons.play_circle_filled_rounded,
        ]) {
          expect(
            find.descendant(of: card, matching: find.byIcon(icon)),
            findsNothing,
            reason: '${t.title} is not made and shows play',
          );
        }
        final meta = find.byKey(ttcKindMetaKey(t.title));
        expect(
          find.descendant(of: meta, matching: find.text(kTtcFilmComingSoon)),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: meta,
            matching: find.byIcon(Icons.schedule_rounded),
          ),
          findsOneWidget,
        );
      }
    });
  });

  // ===========================================================================
  group('"Paid" only where there is a price', () {
    test('the rule on every piece of every door', () {
      var paid = 0;
      for (final (page, _, _, t) in _allPieces()) {
        final says = ttcCardMeta(t) == kTtcCardPaid;
        expect(
          says,
          ttcCardIsPaid(t),
          reason: '${page.bracketId} › ${t.title}',
        );
        if (says) {
          paid++;
          expect(
            t is TtcTalkTile || t is TtcBookingTile || t is TtcMasterclassTile,
            isTrue,
            reason: '${t.title} is not an offering and says Paid',
          );
        }
        // A product is something we do not sell (2026-09-03): never Paid.
        if (t is TtcProductTile) expect(says, isFalse, reason: t.title);
      }
      expect(paid, greaterThan(0), reason: 'the rule is untested');
    });

    testWidgets('a paid consult says Paid with a lock; a product does not', (
      tester,
    ) async {
      final consult = _allPieces()
          .map((e) => e.$4)
          .whereType<TtcTalkTile>()
          .firstWhere(ttcCardIsPaid);
      await pumpCard(tester, consult);
      final meta = find.byKey(ttcKindMetaKey(consult.title));
      expect(
        find.descendant(of: meta, matching: find.text(kTtcCardPaid)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: meta,
          matching: find.byIcon(Icons.lock_outline_rounded),
        ),
        findsOneWidget,
      );
      final product = _oneOfEachKind()[TtcCardKind.product]!;
      await pumpCard(tester, product);
      expect(find.text(kTtcCardPaid), findsNothing);
    });
  });

  // ===========================================================================
  group('a read says minutes only at 200 words or more', () {
    test('every read on every door follows the reader\'s rule', () {
      var checked = 0;
      for (final (_, _, _, t) in _allPieces()) {
        final id = switch (t) {
          TtcArticleTile(:final readId) => readId,
          TtcGuideTile(:final readId) => readId,
          _ => null,
        };
        if (id == null) continue;
        final r = ttcReadById(id)!;
        final words =
            r.wordCount +
            (r.shortAnswer?.en ?? '').split(RegExp(r'\s+')).length;
        expect(
          ttcCardMeta(t),
          words >= 200 ? '${r.minutes} min read' : isNull,
          reason: t.title,
        );
        checked++;
      }
      expect(checked, greaterThan(0));
    });

    testWidgets('a read with no words behind it has no fact pill', (
      tester,
    ) async {
      const t = TtcArticleTile(
        title: 'A read with nothing behind it',
        blurb: '',
        readId: 'no_such_read',
      );
      expect(ttcCardReadMinutes(t), isNull);
      await pumpCard(tester, t);
      expect(find.text('Article'), findsOneWidget);
      expect(find.byKey(ttcKindMetaKey(t.title)), findsNothing);
      expect(find.textContaining('min read'), findsNothing);
    });

    testWidgets('a long read says its minutes on the card', (tester) async {
      final t = _allPieces()
          .map((e) => e.$4)
          .whereType<TtcArticleTile>()
          .firstWhere((t) => ttcCardReadMinutes(t) != null);
      await pumpCard(tester, t);
      expect(
        find.descendant(
          of: find.byKey(ttcKindMetaKey(t.title)),
          matching: find.text(ttcCardReadMinutes(t)!),
        ),
        findsOneWidget,
      );
    });
  });

  // ===========================================================================
  group('one size, and no overflow at 360pt and text scale 1.5', () {
    test('every card on a door is one height, grown with the text', () {
      const s1 = TextScaler.linear(1);
      const s15 = TextScaler.linear(1.5);
      expect(ttcKindCardHeight(s15), greaterThan(ttcKindCardHeight(s1)));
      // A one-piece section's wide card keeps the rail's height.
      expect(
        ttcKindCardHeight(
          s1,
          width: 328,
          imageHeight: ttcKindCardImageHeight(),
        ),
        ttcKindCardHeight(s1),
      );
    });

    for (final scale in [1.0, 1.5]) {
      testWidgets('every card alone, on the rail and in the grid, at $scale', (
        tester,
      ) async {
        for (final (page, _, h, t) in _allPieces()) {
          for (final width in [kTtcKindCardWidth, (360 - 32 - 12) / 2]) {
            await pumpCard(tester, t, textScale: scale, width: width);
            expect(
              tester.takeException(),
              isNull,
              reason:
                  '${page.bracketId} › $h › ${t.title} overflowed at '
                  '$width wide, text scale $scale',
            );
            expect(
              tester.getSize(find.byType(TtcKindCard)).height,
              moreOrLessEquals(
                ttcKindCardHeight(TextScaler.linear(scale), width: width),
              ),
            );
          }
        }
      });
    }

    for (final page in kTtcFocusPages) {
      testWidgets('${page.bracketId}, every tab, at 1.5', (tester) async {
        await pumpDoor(tester, page, textScale: 1.5, height: 9000);
        final groups = page.groups ?? const <TtcFocusGroup>[];
        for (var i = 0; i < groups.length; i++) {
          await pickTab(tester, i);
          expect(
            tester.takeException(),
            isNull,
            reason: '${page.bracketId} › ${groups[i].id} overflowed at 1.5',
          );
        }
      });
    }
  });

  // ===========================================================================
  group('every tap still lands where it did', () {
    // (door, tab, kind, card title, the route it pushes), the Fertile window
    // list as it was, then one of each kind from the other doors.
    const taps = [
      (
        'ttc_conceiving',
        'trying',
        TtcCardKind.story,
        'How the body shows the right days',
        'ttc/story',
      ),
      // Kept for revert (2026-09-28, explicit names): 'Do positions matter?'.
      (
        'ttc_conceiving',
        'trying',
        TtcCardKind.myth,
        'Do sex positions matter?',
        'ttc/story',
      ),
      (
        'ttc_conceiving',
        'trying',
        TtcCardKind.tool,
        'Your best days this month',
        'ttc_window',
      ),
      (
        'ttc_conceiving',
        'waiting',
        TtcCardKind.chat,
        'Should I test?',
        'ttc_chat/should_test',
      ),
      (
        'ttc_conceiving',
        'doctor',
        TtcCardKind.consult,
        // Kept for revert (2026-09-28): 'Talk to a doctor',
        'Talk to a gynaecologist',
        'ttc/offering/ttc_consult_gynae',
      ),
      ('ttc_pcos', 'track', TtcCardKind.tool, 'Cycle companion', 'ttc_cycle'),
      (
        'ttc_infertility',
        'track',
        TtcCardKind.tool,
        'Keep your reports together',
        'ttc_records',
      ),
      (
        'ttc_male_fertility',
        'talk',
        TtcCardKind.consult,
        'Talk to an andrologist',
        'ttc/offering/ttc_consult_androl',
      ),
    ];
    for (final (door, tab, kind, title, route) in taps) {
      testWidgets('$door › ${kind.name}: $title', (tester) async {
        final page = kTtcFocusPages.firstWhere((p) => p.bracketId == door);
        final pushed = <String?>[];
        await pumpDoor(
          tester,
          page,
          width: 1800,
          height: 9000,
          observers: [_Recorder(pushed)],
        );
        await pickTab(tester, page.groups!.indexWhere((g) => g.id == tab));
        pushed.clear();
        final f = find.byKey(ttcKindCardKey(kind, title), skipOffstage: false);
        await tester.ensureVisible(f);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(f, warnIfMissed: false);
        expect(pushed, [route]);
      });
    }

    // Every other kind: the card's tap pushes exactly what the door's one
    // opener pushes for that tile (`openTtcFocusTile`), which is what the old
    // card called.
    for (final kind in [
      TtcCardKind.video,
      TtcCardKind.read,
      TtcCardKind.product,
      TtcCardKind.practice,
      TtcCardKind.course,
      TtcCardKind.recipe,
      TtcCardKind.infographic,
    ]) {
      testWidgets('${kind.name}: the card opens what the opener opens', (
        tester,
      ) async {
        final (page, tab, _, t) = _allPieces().firstWhere(
          (e) => ttcCardKindOf(e.$4) == kind,
        );
        final bracket = bracketById(page.bracketId)!;
        // What the opener pushes.
        final expected = <String?>[];
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [_Recorder(expected)],
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => openTtcFocusTile(context, t, bracket.hue),
                child: const Text('open'),
              ),
            ),
          ),
        );
        expected.clear();
        await tester.tap(find.text('open'));
        expect(expected, hasLength(1));
        // A fresh tree, so the opened page is not left over the door.
        await tester.pumpWidget(const SizedBox());
        // What the card pushes.
        final pushed = <String?>[];
        await pumpDoor(
          tester,
          page,
          width: 1800,
          height: 9000,
          observers: [_Recorder(pushed)],
        );
        await pickTab(tester, page.groups!.indexWhere((g) => g.id == tab));
        pushed.clear();
        final f = find.byKey(
          ttcKindCardKey(kind, t.title),
          skipOffstage: false,
        );
        await tester.ensureVisible(f);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(f, warnIfMissed: false);
        expect(pushed, expected, reason: '${page.bracketId} › ${t.title}');
      });
    }
  });

  // ===========================================================================
  group('a photo keys on the tile\'s stable id, not its title', () {
    test('every piece on every door has an id, and it is the photo key', () {
      for (final (page, _, _, t) in _allPieces()) {
        expect(t.id, isNotNull, reason: '${page.bracketId} › ${t.title}');
        expect(ttcTilePhotoId(t), t.id);
      }
    });

    test('a retitled tile keeps its photo; one without an id loses it', () {
      final tool = _allPieces()
          .map((e) => e.$4)
          .whereType<TtcToolTile>()
          .firstWhere((t) => readImageFor(t.id!) != null);
      final before = photoForTile(tool);
      expect(before, isNotNull);
      final retitled = TtcToolTile(
        id: tool.id,
        title: 'A brand new name for the same tool',
        blurb: tool.blurb,
        surfaceId: tool.surfaceId,
      );
      expect(photoForTile(retitled), before);
      final noId = TtcToolTile(
        title: 'A brand new name for the same tool',
        blurb: tool.blurb,
        surfaceId: tool.surfaceId,
      );
      expect(photoForTile(noId), isNull, reason: 'the title fallback');
    });

    test('a tile with no id still keys on its title', () {
      const t = TtcMythTile(
        title: 'Every day or not?',
        blurb: '',
        myth: '',
        fact: '',
      );
      expect(ttcTilePhotoId(t), 'ttc_tile_every_day_or_not');
      expect(ttcTileTitleKey('Every day or not?'), 'ttc_tile_every_day_or_not');
    });
  });
}

class _Recorder extends NavigatorObserver {
  _Recorder(this.names);
  final List<String?> names;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      names.add(route.settings.name);
}

// =============================================================================
//  Kept for revert (2026-09-29): the 2026-09-28 tests, one shape per kind on
//  the Fertile window door alone, with the gate `ttcDoorDrawsKinds`.
// =============================================================================
// /// Every piece the Fertile window door puts on a rail, with its tab.
// List<(String group, String heading, TtcTile tile)> _railPieces(
//   TtcFocusPage page,
// ) => [
//   for (final s in page.sections)
//     for (final t in ttcDoorRailTiles(s.tiles)) (s.group!, s.heading, t),
// ];
//
// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();
//   // The one-time shared-phone offer (ttc_intimate_offer.dart) would open a
//   // sheet over the door on the Sex and closeness tab; it is offered already.
//   SharedPreferences.setMockInitialValues({'ttc_hide_intimate_offered': true});
//
//   setUp(() => HttpOverrides.global = _StubHttpOverrides());
//   tearDown(() => HttpOverrides.global = null);
//
//   const page = kTtcConceivingFocus;
//
//   Future<void> pumpDoor(
//     WidgetTester tester,
//     TtcFocusPage page, {
//     double width = 360,
//     double height = 2400,
//     double textScale = 1.0,
//     List<NavigatorObserver> observers = const [],
//   }) async {
//     tester.view.physicalSize = Size(width, height);
//     tester.view.devicePixelRatio = 1.0;
//     addTearDown(tester.view.reset);
//     await tester.pumpWidget(
//       MaterialApp(
//         navigatorObservers: observers,
//         builder: (context, child) => MediaQuery(
//           data: MediaQuery.of(
//             context,
//           ).copyWith(textScaler: TextScaler.linear(textScale)),
//           child: child!,
//         ),
//         home: TtcDoorScreen(page: page, bracket: bracketById(page.bracketId)!),
//       ),
//     );
//     await tester.pump(const Duration(milliseconds: 400));
//     expect(
//       tester.takeException(),
//       isNull,
//       reason: '${page.bracketId} threw while building',
//     );
//   }
//
//   Future<void> pickTab(WidgetTester tester, int i) async {
//     final card = find.byKey(ttcDoorRailCardKey(i));
//     await tester.ensureVisible(card);
//     await tester.pump(const Duration(milliseconds: 300));
//     await tester.tap(card, warnIfMissed: false);
//     await tester.pump(const Duration(milliseconds: 400));
//   }
//
//   Future<void> pumpCard(
//     WidgetTester tester,
//     TtcTile t, {
//     double textScale = 1.0,
//   }) async {
//     tester.view.physicalSize = const Size(360, 400);
//     tester.view.devicePixelRatio = 1.0;
//     addTearDown(tester.view.reset);
//     final p = V2PaletteStore.instance.current;
//     await tester.pumpWidget(
//       MaterialApp(
//         builder: (context, child) => MediaQuery(
//           data: MediaQuery.of(
//             context,
//           ).copyWith(textScaler: TextScaler.linear(textScale)),
//           child: child!,
//         ),
//         home: Scaffold(
//           body: Align(
//             alignment: Alignment.topLeft,
//             child: TtcKindCard(
//               tile: t,
//               kind: ttcCardKindOf(t)!,
//               p: p,
//               hue: 344,
//               onTap: () {},
//             ),
//           ),
//         ),
//       ),
//     );
//     await tester.pump(const Duration(milliseconds: 100));
//   }
//
//   // ===========================================================================
//   group('the gate', () {
//     test('the Fertile window door alone draws one look per kind', () {
//       expect(kTtcDoorsWithKindCards, {'ttc_conceiving'});
//       expect(ttcDoorDrawsKinds(page.bracketId), isTrue);
//       for (final other in kTtcFocusPages) {
//         if (other.bracketId == page.bracketId) continue;
//         expect(
//           ttcDoorDrawsKinds(other.bracketId),
//           isFalse,
//           reason: other.bracketId,
//         );
//       }
//     });
//
//     test('every piece on the Fertile window door has a look of its own', () {
//       final none = [
//         for (final (_, h, t) in _railPieces(page))
//           if (ttcCardKindOf(t) == null) '$h › ${t.title}',
//       ];
//       expect(none, isEmpty, reason: 'pieces still on the old card: $none');
//     });
//
//     test('the door carries all the kinds the language was designed on', () {
//       final kinds = {
//         for (final (_, _, t) in _railPieces(page)) ttcCardKindOf(t),
//       };
//       expect(
//         kinds,
//         containsAll(<TtcCardKind>{
//           TtcCardKind.video,
//           TtcCardKind.story,
//           TtcCardKind.read,
//           TtcCardKind.myth,
//           TtcCardKind.tool,
//           TtcCardKind.chat,
//           TtcCardKind.consult,
//           TtcCardKind.product,
//         }),
//       );
//     });
//
//     test('"Should I test?" is a chat, "Your best days" a tool', () {
//       final all = {for (final (_, _, t) in _railPieces(page)) t.title: t};
//       expect(ttcCardKindOf(all['Should I test?']!), TtcCardKind.chat);
//       expect(
//         ttcCardKindOf(all['Your best days this month']!),
//         TtcCardKind.tool,
//       );
//       expect(ttcCardKindOf(all['Talk to a gynaecologist']!), TtcCardKind.consult);
//     });
//   });
//
//   // ===========================================================================
//   group('on the door, every piece is its own kind of card', () {
//     testWidgets('each tab: every piece is found by its kind key', (
//       tester,
//     ) async {
//       // Wide, so every card in every rail is built (a rail is a lazy list).
//       await pumpDoor(tester, page, width: 1800, height: 9000);
//       final groups = page.groups!;
//       for (var i = 0; i < groups.length; i++) {
//         await pickTab(tester, i);
//         for (final (g, h, t) in _railPieces(page)) {
//           if (g != groups[i].id) continue;
//           final kind = ttcCardKindOf(t)!;
//           expect(
//             find.byKey(ttcKindCardKey(kind, t.title), skipOffstage: false),
//             findsOneWidget,
//             reason: '$h › ${t.title} is not drawn as a ${kind.name}',
//           );
//         }
//         expect(
//           find.byType(TtcDoorSectionCard),
//           findsNothing,
//           reason: 'tab ${groups[i].id} still draws the old card',
//         );
//         expect(tester.takeException(), isNull);
//       }
//     });
//
//     testWidgets('no film that is not made shows a play glyph', (tester) async {
//       final films = [
//         for (final (_, _, t) in _railPieces(page))
//           if (t is TtcVideoTile) t,
//       ];
//       expect(films, isNotEmpty);
//       for (final t in films) {
//         await pumpCard(tester, t);
//         final card = find.byKey(ttcKindCardKey(TtcCardKind.video, t.title));
//         expect(card, findsOneWidget);
//         if (ttcTileIsUnmadeFilm(t)) {
//           expect(
//             find.descendant(
//               of: card,
//               matching: find.byIcon(Icons.play_arrow_rounded),
//             ),
//             findsNothing,
//             reason: '${t.title} is not made and shows a play glyph',
//           );
//           expect(
//             find.descendant(
//               of: card,
//               matching: find.byIcon(Icons.schedule_rounded),
//             ),
//             findsOneWidget,
//           );
//           expect(
//             find.descendant(of: card, matching: find.text(kTtcFilmComingSoon)),
//             findsOneWidget,
//           );
//           expect(
//             find.descendant(
//               of: card,
//               matching: find.text('Video · Coming soon'),
//             ),
//             findsOneWidget,
//           );
//         }
//       }
//     });
//
//     testWidgets('a film thumbnail is 16:9', (tester) async {
//       final t = _railPieces(
//         page,
//       ).map((e) => e.$3).whereType<TtcVideoTile>().first;
//       await pumpCard(tester, t);
//       final ratio = tester.widget<AspectRatio>(
//         find.descendant(
//           of: find.byKey(ttcKindCardKey(TtcCardKind.video, t.title)),
//           matching: find.byType(AspectRatio),
//         ),
//       );
//       expect(ratio.aspectRatio, 16 / 9);
//     });
//
//     testWidgets('a tool card has no photo, an icon and a verb', (tester) async {
//       final tools = [
//         for (final (_, _, t) in _railPieces(page))
//           if (ttcCardKindOf(t) == TtcCardKind.tool) t as TtcToolTile,
//       ];
//       expect(tools, isNotEmpty);
//       for (final t in tools) {
//         // The data still has a photo for it; the card chooses not to draw
//         // one, so a tool never reads as something to read.
//         await pumpCard(tester, t);
//         final card = find.byKey(ttcKindCardKey(TtcCardKind.tool, t.title));
//         expect(
//           find.descendant(of: card, matching: find.byType(Image)),
//           findsNothing,
//           reason: '${t.title} draws a photo',
//         );
//         expect(
//           find.descendant(of: card, matching: find.text('Tool')),
//           findsOneWidget,
//         );
//         expect(
//           find.descendant(
//             of: card,
//             matching: find.text(ttcToolVerb(t.surfaceId)),
//           ),
//           findsOneWidget,
//         );
//       }
//       expect(ttcToolVerb('ttc_window'), 'See your best days');
//     });
//
//     testWidgets('a story shows one tick per slide and says how many', (
//       tester,
//     ) async {
//       final t = _railPieces(
//         page,
//       ).map((e) => e.$3).whereType<TtcCarouselTile>().first;
//       await pumpCard(tester, t);
//       expect(find.text('Story · ${t.cards.length} slides'), findsOneWidget);
//     });
//
//     testWidgets('a myth says it is one, and what people say', (tester) async {
//       final t = _railPieces(
//         page,
//       ).map((e) => e.$3).whereType<TtcMythTile>().first;
//       await pumpCard(tester, t);
//       expect(find.text('Myth vs fact'), findsOneWidget);
//       expect(find.textContaining(t.myth), findsOneWidget);
//       expect(find.byType(Image), findsNothing);
//     });
//
//     testWidgets('a consult is a person card with a price and no face', (
//       tester,
//     ) async {
//       final t = _railPieces(
//         page,
//       ).map((e) => e.$3).whereType<TtcTalkTile>().first;
//       await pumpCard(tester, t);
//       final o = ttcOfferingById(t.action)!;
//       expect(find.text('Consult'), findsOneWidget);
//       expect(find.text('Video call · ${o.priceLabel}'), findsOneWidget);
//       expect(find.byType(Image), findsNothing, reason: 'a stock face');
//       expect(find.text('See times and book'), findsOneWidget);
//     });
//   });
//
//   // ===========================================================================
//   group('a read says minutes only at 200 words or more', () {
//     test('every read on the door follows the reader\'s rule', () {
//       var checked = 0;
//       for (final (_, _, t) in _railPieces(page)) {
//         if (t is! TtcArticleTile) continue;
//         final r = ttcReadById(t.readId!)!;
//         final words =
//             r.wordCount +
//             (r.shortAnswer?.en ?? '').split(RegExp(r'\s+')).length;
//         expect(
//           ttcCardReadMinutes(t),
//           words >= 200 ? '${r.minutes} min read' : isNull,
//           reason: t.title,
//         );
//         checked++;
//       }
//       expect(checked, greaterThan(0));
//     });
//
//     testWidgets('a read with no words behind it says Article alone', (
//       tester,
//     ) async {
//       const t = TtcArticleTile(
//         title: 'A read with nothing behind it',
//         blurb: '',
//         readId: 'no_such_read',
//       );
//       expect(ttcCardReadMinutes(t), isNull);
//       await pumpCard(tester, t);
//       expect(find.text('Article'), findsOneWidget);
//       expect(find.textContaining('min read'), findsNothing);
//     });
//
//     testWidgets('a long read says its minutes on the card', (tester) async {
//       final t = _railPieces(page)
//           .map((e) => e.$3)
//           .whereType<TtcArticleTile>()
//           .firstWhere((t) => ttcCardReadMinutes(t) != null);
//       await pumpCard(tester, t);
//       expect(find.text('Article · ${ttcCardReadMinutes(t)}'), findsOneWidget);
//     });
//   });
//
//   // ===========================================================================
//   group('no overflow at 360pt and text scale 1.5', () {
//     for (final scale in [1.0, 1.5]) {
//       testWidgets('every card on the door, alone, at $scale', (tester) async {
//         for (final (_, h, t) in _railPieces(page)) {
//           await pumpCard(tester, t, textScale: scale);
//           expect(
//             tester.takeException(),
//             isNull,
//             reason: '$h › ${t.title} overflowed at text scale $scale',
//           );
//         }
//       });
//     }
//
//     testWidgets('the whole door, every tab, at 1.5', (tester) async {
//       await pumpDoor(tester, page, textScale: 1.5, height: 9000);
//       for (var i = 0; i < page.groups!.length; i++) {
//         await pickTab(tester, i);
//         expect(
//           tester.takeException(),
//           isNull,
//           reason: 'tab ${page.groups![i].id} overflowed at 1.5',
//         );
//       }
//     });
//   });
//
//   // ===========================================================================
//   group('every tap still lands where it did', () {
//     // (tab, kind, card title, the route it pushes)
//     const taps = [
//       (
//         'trying',
//         TtcCardKind.story,
//         'How the body shows the right days',
//         'ttc/story',
//       ),
//       // Kept for revert (2026-09-28, explicit names): 'Do positions matter?'.
//       ('trying', TtcCardKind.myth, 'Do sex positions matter?', 'ttc/story'),
//       ('trying', TtcCardKind.tool, 'Your best days this month', 'ttc_window'),
//       ('waiting', TtcCardKind.chat, 'Should I test?', 'ttc_chat/should_test'),
//       (
//         'doctor',
//         TtcCardKind.consult,
//         // Kept for revert (2026-09-28): 'Talk to a doctor',
//         'Talk to a gynaecologist',
//         'ttc/offering/ttc_consult_gynae',
//       ),
//     ];
//     for (final (tab, kind, title, route) in taps) {
//       testWidgets('${kind.name}: $title', (tester) async {
//         final pushed = <String?>[];
//         await pumpDoor(
//           tester,
//           page,
//           width: 1800,
//           height: 9000,
//           observers: [_Recorder(pushed)],
//         );
//         await pickTab(tester, page.groups!.indexWhere((g) => g.id == tab));
//         pushed.clear();
//         final f = find.byKey(ttcKindCardKey(kind, title), skipOffstage: false);
//         await tester.ensureVisible(f);
//         await tester.pump(const Duration(milliseconds: 300));
//         await tester.tap(f, warnIfMissed: false);
//         expect(pushed, [route]);
//       });
//     }
//   });
//
//   // ===========================================================================
//   group('other doors are unchanged', () {
//     for (final other in kTtcFocusPages) {
//       if (other.bracketId == page.bracketId) continue;
//       testWidgets(other.bracketId, (tester) async {
//         await pumpDoor(tester, other);
//         for (var i = 0; i < other.groups!.length; i++) {
//           await pickTab(tester, i);
//           expect(
//             find.byType(TtcKindCard),
//             findsNothing,
//             reason: '${other.bracketId} draws a kind card',
//           );
//         }
//       });
//     }
//   });
//
//   // ===========================================================================
//   group('a photo keys on the tile\'s stable id, not its title', () {
//     test('every id on the door names a photo that exists', () {
//       for (final (_, _, t) in _railPieces(page)) {
//         if (t.id == null) continue;
//         expect(ttcTilePhotoId(t), t.id);
//         expect(
//           readImageFor(t.id!),
//           isNotNull,
//           reason: '${t.title} has id ${t.id} and no photo under it',
//         );
//       }
//     });
//
//     test('a retitled tile keeps its photo; one without an id loses it', () {
//       final tool = _railPieces(page)
//           .map((e) => e.$3)
//           .whereType<TtcToolTile>()
//           .firstWhere((t) => t.id != null);
//       final before = photoForTile(tool);
//       expect(before, isNotNull);
//       final retitled = TtcToolTile(
//         id: tool.id,
//         title: 'A brand new name for the same tool',
//         blurb: tool.blurb,
//         surfaceId: tool.surfaceId,
//       );
//       expect(photoForTile(retitled), before);
//       final noId = TtcToolTile(
//         title: 'A brand new name for the same tool',
//         blurb: tool.blurb,
//         surfaceId: tool.surfaceId,
//       );
//       expect(photoForTile(noId), isNull, reason: 'the title fallback');
//     });
//
//     test('a tile with no id still keys on its title', () {
//       const t = TtcMythTile(
//         title: 'Every day or not?',
//         blurb: '',
//         myth: '',
//         fact: '',
//       );
//       expect(ttcTilePhotoId(t), 'ttc_tile_every_day_or_not');
//     });
//   });
// }
//
