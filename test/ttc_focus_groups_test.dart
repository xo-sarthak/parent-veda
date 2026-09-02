// =============================================================================
//  The grouped PCOS door
// -----------------------------------------------------------------------------
//  ⚠️ THE FAILURE THIS GUARDS IS A SECTION THAT BELONGS TO NO GROUP, and it is
//  invisible without a test. A grouped page renders `sections.where((s) =>
//  s.group == selected.id)`, so a section whose group id is misspelt, or left
//  null, or pointing at a group that was renamed simply **never appears** —
//  no error, no blank card, no gap. It is the content version of this repo's
//  standing defect: correct code that nothing can reach.
//
//  The tile-level version of that is already held by `ttc_focus_page_test.dart`,
//  which walks `page.allTiles` and resolves every id. That test keeps working
//  unchanged here, because grouping decides what is on screen at once and does
//  not move content into a second structure — which is exactly why it was built
//  that way.
//
//  ⚠️ AND PCOS IS THE ONLY GROUPED DOOR ON PURPOSE. The last group asserts the
//  others are untouched, so a later session cannot roll this out to five doors
//  as a tidy-up without the suite saying something changed.
// =============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/screens/ttc/ttc_focus_screen.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';

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

  final pcos = kTtcFocusPages.firstWhere((p) => p.bracketId == 'ttc_pcos');

  // ===========================================================================
  group('every section reaches a group, and every group reaches content', () {
    test('PCOS is grouped, and names five', () {
      expect(pcos.groups, isNotNull);
      expect(pcos.groups!.length, 5);
      expect(pcos.groups!.first.label, 'Understand',
          reason: 'Understand must be first — it is the default landing group');
    });

    test('no section is orphaned', () {
      final ids = pcos.groups!.map((g) => g.id).toSet();
      for (final s in pcos.sections) {
        expect(s.group, isNotNull,
            reason: '"${s.heading}" has no group, so it renders nowhere');
        expect(ids, contains(s.group),
            reason: '"${s.heading}" points at group "${s.group}", which does '
                'not exist — the section is unreachable and nothing throws');
      }
    });

    test('no group is empty', () {
      for (final g in pcos.groups!) {
        final owned = pcos.sections.where((s) => s.group == g.id).length;
        if (g.toolSurfaceId != null) {
          // ⚠️ A TOOL GROUP HOLDS NO SECTIONS. If one gained sections they
          // would be silently invisible, because the tool branch wins.
          expect(owned, 0,
              reason: '"${g.label}" shows a tool AND owns $owned section(s), '
                  'which will never render');
        } else {
          expect(owned, greaterThan(0),
              reason: '"${g.label}" is a card that opens onto nothing');
        }
      }
    });

    test('no tab repeats the heading directly under it', () {
      // ⚠️ THE ONE THAT ALMOST SHIPPED. The design's mock data names the last
      // tab "Keep track of it", which is also that group's only section
      // heading — so the tab and the heading beneath it would have said the
      // same words twice, which is what deleting the group heading fixed.
      for (final g in pcos.groups!) {
        final headings =
            pcos.sections.where((s) => s.group == g.id).map((s) => s.heading);
        expect(headings, isNot(contains(g.label)),
            reason: '"${g.label}" is both a tab and a heading under itself');
      }
    });

    test('every tab has a mark for its well', () {
      for (final g in pcos.groups!) {
        expect(g.icon, isNotNull, reason: '"${g.label}" has an empty well');
      }
      expect(pcos.groups!.map((g) => g.icon).toSet().length, pcos.groups!.length,
          reason: 'two tabs share a mark, so the well stops identifying them');
    });

    test('an infographic is exactly one frame', () {
      // ⚠️ THE FORMAT'S ONLY RULE, HELD IN CODE. "Infographic only consists of
      // 1 slide — in one slide provide required info." The model has nowhere to
      // put a second frame, so what is left to guard is the frame getting too
      // full: a fifth point down a half-width column is the moment it stopped
      // being one look and became a list.
      final tiles = kTtcFocusPages
          .expand((p) => p.allTiles)
          .whereType<TtcInfographicTile>();
      expect(tiles, isNotEmpty);
      for (final t in tiles) {
        for (final col in [t.left, t.right]) {
          expect(col.points.length, inInclusiveRange(2, 4),
              reason: '"${t.title}" / "${col.label}" has '
                  '${col.points.length} points — past four this is a carousel');
          expect(col.label.length, lessThanOrEqualTo(30),
              reason: 'a column label that long will wrap past its box');
        }
        expect(t.headline, isNot(t.title),
            reason: '"${t.title}" repeats its own title as the headline, which '
                "spends the reader's first look on nothing");
      }
    });

    test('the group ids are unique', () {
      final ids = pcos.groups!.map((g) => g.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  // ===========================================================================
  group('the inline tool actually resolves', () {
    test('every toolSurfaceId returns a widget', () {
      // ⚠️ THE WIRING GATE, ON THE ONE ID THAT HAS NO VISIBLE FAILURE. A
      // surface id the inline map does not know renders as an empty group —
      // a card you tap that opens onto blank page.
      for (final g in pcos.groups!.where((g) => g.toolSurfaceId != null)) {
        expect(ttcInlineToolFor(g.toolSurfaceId!), isNotNull,
            reason: '"${g.label}" points at "${g.toolSurfaceId}", which '
                'ttcInlineToolFor does not know');
      }
    });

    test('and it still resolves as a full screen too', () {
      // The same tool is reachable from the Tools hub and a journey step, which
      // push it. Splitting it into a body must not have broken that.
      for (final g in pcos.groups!.where((g) => g.toolSurfaceId != null)) {
        expect(ttcScreenForSurface(g.toolSurfaceId!), isNotNull);
      }
    });

    test('an unknown surface gets null, not a guess', () {
      expect(ttcInlineToolFor('ttc_not_a_real_tool'), isNull);
    });
  });

  // ===========================================================================
  group('the hero swapped a film for a photograph', () {
    test('the photo and its sentence are both there', () {
      expect(pcos.heroImageUrl, isNotNull);
      expect(pcos.heroBlurb, isNotNull);
      expect(pcos.heroBlurb!.length, greaterThan(40),
          reason: 'the blurb has to define the condition, not greet her');
    });

    test('and the film is not in two places at once', () {
      expect(pcos.heroVideoSlot, isNull,
          reason: 'the same slot was the hero and the first tile, so the page '
              'opened on a coming-soon placeholder and offered the identical '
              'placeholder again two sections later');
      // It survives as a tile, which is where the brief lists it.
      final slots = [
        for (final t in pcos.allTiles)
          if (t is TtcVideoTile) t.slotId,
      ];
      expect(slots, contains('ttc_pcos_intro'));
    });
  });

  // ===========================================================================
  group('the other doors are untouched', () {
    test('only PCOS is grouped', () {
      for (final page in kTtcFocusPages) {
        if (page.bracketId == 'ttc_pcos') continue;
        expect(page.groups, isNull,
            reason: '${page.bracketId} was grouped too. This shape is being '
                'checked on PCOS first, on purpose — see the head of '
                'ttc_focus_pcos.dart');
        expect(page.sections.every((s) => s.group == null), isTrue,
            reason: '${page.bracketId} has sections tagged with a group but no '
                'groups to render them, so they draw in the plain order and '
                'the tag is a lie waiting to be believed');
      }
    });
  });

  // ===========================================================================
  group('it renders at phone width, and the cards switch it', () {
    setUp(() => HttpOverrides.global = _StubHttpOverrides());
    tearDown(() => HttpOverrides.global = null);

    /// ⚠️ TWO WIDTHS, AND THE REASON IS A REAL PROPERTY OF THE RAIL RATHER THAN
    /// A TEST CONVENIENCE. A horizontal `ListView` does not build children that
    /// are off screen, so at 360 the finder for a later tab returns nothing and
    /// `ensureVisible` throws "No element" — which reads as "the tab is
    /// missing" when it means "the tab has not been scrolled to yet".
    ///
    /// So layout is checked at 360, the narrowest real phone, where every
    /// overflow this stage has shipped was found. Behaviour is checked wide
    /// enough that all five tabs are mounted, because what is under test there
    /// is that a tap swaps the content — not that a rail scrolls, which is
    /// Flutter's job.
    Future<void> pump(WidgetTester tester, {double width = 360}) async {
      tester.view.physicalSize = Size(width, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final bracket = bracketById('ttc_pcos')!;
      await tester.pumpWidget(
          MaterialApp(home: TtcFocusScreen(page: pcos, bracket: bracket)));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    }

    testWidgets('it opens on Understand', (tester) async {
      await pump(tester);
      // ⚠️ THE TAB IS THE ONLY PLACE THE GROUP IS NAMED. A heading repeating
      // it under the rail was removed — tapping "Understand" and then reading
      // the word "Understand" tells her nothing she did not just do, and on the
      // tool group it pushed the second question off the bottom of the screen.
      expect(find.text('Understand'), findsOneWidget);
      expect(find.text('What is PCOS, really?'), findsOneWidget);
      // And nothing from another group is on screen.
      expect(find.text('What should I be eating?'), findsNothing,
          reason: 'a section from "What helps" rendered while Understand was '
              'selected — the group filter is not filtering');
    });

    testWidgets('tapping a tab swaps what is below it', (tester) async {
      await pump(tester, width: 820);
      await tester.tap(find.text('What helps').first);
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);

      expect(find.text('What should I be eating?'), findsOneWidget);
      expect(find.text('What is PCOS, really?'), findsNothing);
    });

    testWidgets('and "Where do I stand" shows the tool, not a card',
        (tester) async {
      await pump(tester, width: 820);
      await tester.tap(find.text('Where do I stand').first);
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);

      // The first question, rendered in place.
      expect(find.text('How long are your cycles usually?'), findsOneWidget);
      // ⚠️ AND NOT THE TILE THAT USED TO OPEN IT. A card in front of a tool,
      // inside a group whose only content is that tool, is a door in front of
      // a door — the thing this change removed.
      expect(find.text('A read of your own pattern'), findsNothing);
    });

    testWidgets('the chosen tab is told apart by colour, not by an outline',
        (tester) async {
      // ⚠️ ASSERTED ON THE LABEL'S COLOUR, BECAUSE THAT IS WHAT INVERTS. The
      // chosen tab fills with its own hue at full depth and sets white type;
      // the rest stay pale with ink. No purple in either state — the accent
      // means "this is the action", and the open tab is the one thing on the
      // rail that is not.
      await pump(tester, width: 820);

      Color? labelColour(String label) =>
          tester.widget<Text>(find.text(label)).style?.color;

      expect(labelColour('Understand'), Colors.white,
          reason: 'the open tab did not take white type');
      expect(labelColour('What helps'), isNot(Colors.white));

      await tester.tap(find.text('What helps').first);
      await tester.pump(const Duration(milliseconds: 300));

      expect(labelColour('What helps'), Colors.white);
      expect(labelColour('Understand'), isNot(Colors.white),
          reason: 'two tabs read as open at once');
    });

    testWidgets('the hero keeps the door name, not the group name',
        (tester) async {
      await pump(tester);
      final bracket = bracketById('ttc_pcos')!;
      expect(find.text(bracket.label.en), findsWidgets,
          reason: 'the hero has one job: say which door she is standing in. '
              'If it renamed itself on every card tap it could not do it');
    });
  });
}
