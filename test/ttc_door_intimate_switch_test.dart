// =============================================================================
//  The shared-phone switch, on the doors
// -----------------------------------------------------------------------------
//  "Hide sex and intimacy content" (`TtcContentPrefs.hideIntimate`, TTC gap
//  plan, "Behind — Settings"). When it is on, the door must leave out the Sex
//  and closeness tab and every tile that opens an intimate read, and the door's
//  search must not bring either back.
//
//  ⚠️ WHY THE SEARCH HALF IS HERE AT ALL. A filter that lives only where the
//  tabs are drawn passes a visual check and fails the first time she types
//  "lubricant" into the field on a shared phone. Both halves go through one
//  function (`ttcDoorVisiblePage`), and this file holds both.
//
//  ⚠️ AND WHY IT IS A LIVE TEST. The door listens to the prefs, so turning
//  the switch on in You updates a door already open underneath. A door that
//  read the flag once in initState would pass every data test here.
// =============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_search.dart';
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/ttc/ttc_content_prefs.dart';
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

class _StubResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 404;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => const Stream<List<int>>.empty().listen(
    onData,
    onError: onError,
    onDone: onDone,
  );
}

/// Every read id a tile opens, including the "more" read behind a sheet.
Iterable<String> _readsOf(TtcTile t) sync* {
  switch (t) {
    case TtcArticleTile(:final readId, :final moreReadId):
      if (readId != null) yield readId;
      if (moreReadId != null) yield moreReadId;
    case TtcGuideTile(:final readId):
      yield readId;
    default:
      break;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TtcContentPrefs.instance.resetForTest();
    HttpOverrides.global = _StubHttpOverrides();
  });
  tearDown(() {
    TtcContentPrefs.instance.resetForTest();
    HttpOverrides.global = null;
  });

  final conceiving = ttcFocusPageFor('ttc_conceiving')!;

  // ===========================================================================
  group('the data behind the switch is real', () {
    test('Fertile window has the tab the switch names', () {
      // If the tab's id drifts from `kTtcIntimateGroupId`, the switch silently
      // stops hiding anything. This is the line that notices.
      expect(
        conceiving.groups!.map((g) => g.id),
        contains(kTtcIntimateGroupId),
      );
    });

    test('every intimate read is placed on some door', () {
      final placed = {
        for (final p in kTtcFocusPages)
          for (final t in p.allTiles) ..._readsOf(t),
      };
      for (final id in kTtcIntimateReadIds) {
        expect(placed, contains(id), reason: '$id is on no door');
      }
    });
  });

  // ===========================================================================
  group('ttcDoorVisiblePage', () {
    test('switch off: the page is returned untouched', () {
      for (final p in kTtcFocusPages) {
        expect(ttcDoorVisiblePage(p, hideIntimate: false), same(p));
      }
    });

    test('switch on: no intimate tab, section or tile on any door', () {
      for (final p in kTtcFocusPages) {
        final v = ttcDoorVisiblePage(p, hideIntimate: true);
        expect(
          v.groups!.map((g) => g.id),
          isNot(contains(kTtcIntimateGroupId)),
          reason: '${p.bracketId} still shows the Sex and closeness tab',
        );
        for (final s in v.sections) {
          expect(s.group, isNot(kTtcIntimateGroupId));
          expect(s.tiles, isNotEmpty, reason: '"${s.heading}" is left empty');
          for (final t in s.tiles) {
            for (final id in _readsOf(t)) {
              expect(
                kTtcIntimateReadIds,
                isNot(contains(id)),
                reason: '${p.bracketId}: "${t.title}" still opens $id',
              );
            }
          }
        }
        // And no tab is left opening onto nothing.
        for (final g in v.groups!) {
          final hasTool = (g.inlineSurfaceId ?? g.toolSurfaceId) != null;
          expect(
            hasTool || v.sections.any((s) => s.group == g.id),
            isTrue,
            reason: '${p.bracketId} / ${g.id} is an empty tab',
          );
        }
      }
    });

    test('switch on: only intimate pieces go, everything else stays', () {
      for (final p in kTtcFocusPages) {
        final v = ttcDoorVisiblePage(p, hideIntimate: true);
        final kept = v.allTiles.toSet();
        for (final s in p.sections) {
          if (s.group == kTtcIntimateGroupId) continue;
          for (final t in s.tiles) {
            if (ttcTileIsIntimate(t)) continue;
            expect(
              kept,
              contains(t),
              reason: '${p.bracketId}: "${t.title}" was hidden and is not intimate',
            );
          }
        }
      }
    });

    test('His side keeps its Talk tab, without the one intimate piece', () {
      final his = ttcFocusPageFor('ttc_male_fertility')!;
      final v = ttcDoorVisiblePage(his, hideIntimate: true);
      expect(v.groups!.map((g) => g.id), contains('talk'));
      final titles = v.allTiles.map((t) => t.title);
      expect(titles, isNot(contains('When sex is hard for him under pressure')));
      expect(titles, contains('Talk to an andrologist'));
    });
  });

  // ===========================================================================
  group('the door search cannot bring them back', () {
    final bracket = bracketById('ttc_conceiving')!;

    test('switch off: typing finds the piece', () {
      final index = ttcDoorSearchIndex(
        conceiving,
        bracket,
        AppLanguage.english,
        hideIntimate: false,
      );
      expect(ttcDoorSearch('lubricants', index), isNotEmpty);
    });

    test('switch on: neither the tile nor the library read is indexed', () {
      final index = ttcDoorSearchIndex(
        conceiving,
        bracket,
        AppLanguage.english,
        hideIntimate: true,
      );
      for (final h in index) {
        if (h.tile case final t?) {
          expect(ttcTileIsIntimate(t), isFalse, reason: h.title);
        }
        expect(kTtcIntimateReadIds, isNot(contains(h.readId)), reason: h.title);
      }
      expect(ttcDoorSearch('lubricants', index), isEmpty);
      expect(ttcDoorSearch('vaginismus', index), isEmpty);
      // Timing is not the private part, and stays findable.
      expect(ttcDoorSearch('ovulation', index), isNotEmpty);
    });

    test('with no argument, the index follows her saved choice', () async {
      await TtcContentPrefs.instance.setHideIntimate(true);
      final index = ttcDoorSearchIndex(
        conceiving,
        bracket,
        AppLanguage.english,
      );
      expect(ttcDoorSearch('lubricants', index), isEmpty);
    });
  });

  // ===========================================================================
  group('the open door updates when the switch moves', () {
    Future<void> pumpDoor(WidgetTester tester, {String? initialGroup}) async {
      // Wide, so every rail card is mounted and findable by its label.
      tester.view.physicalSize = const Size(1400, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: TtcDoorScreen(
            page: conceiving,
            bracket: bracketById('ttc_conceiving')!,
            initialGroup: initialGroup,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    }

    testWidgets('the tab leaves the rail, and comes back', (tester) async {
      await pumpDoor(tester);
      expect(find.text('Sex and closeness'), findsOneWidget);

      await TtcContentPrefs.instance.setHideIntimate(true);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.text('Sex and closeness'), findsNothing);
      expect(find.text('Waiting and testing'), findsOneWidget);

      await TtcContentPrefs.instance.setHideIntimate(false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Sex and closeness'), findsOneWidget);
    });

    testWidgets('the open tab stays open when a tab before it goes', (
      tester,
    ) async {
      // 'his' sits after 'sex' on the rail. By index, hiding 'sex' would slide
      // the next tab under her finger; by id, she stays where she was.
      await pumpDoor(tester, initialGroup: 'his');
      expect(find.text('What can he do for his fertility?'), findsOneWidget);

      await TtcContentPrefs.instance.setHideIntimate(true);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('What can he do for his fertility?'), findsOneWidget);
    });

    testWidgets('a door opened on the hidden tab lands on the first one', (
      tester,
    ) async {
      await TtcContentPrefs.instance.setHideIntimate(true);
      await pumpDoor(tester, initialGroup: kTtcIntimateGroupId);
      expect(find.text('When trying changes your sex life'), findsNothing);
      expect(find.text('When should we have sex?'), findsOneWidget);
    });
  });
}
