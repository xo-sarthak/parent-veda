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
import 'package:parentveda/screens/ttc/doors/ttc_door_rail.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_search.dart';
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
  group(
    'sections: written is rows, mixed is a rail that runs edge to edge',
    () {
      for (final page in kTtcFocusPages) {
        testWidgets(page.bracketId, (tester) async {
          await pumpDoor(tester, page, height: 12000);
          for (var i = 0; i < page.groups!.length; i++) {
            await pickTab(tester, i);
            final g = page.groups![i];
            for (final s in page.sections.where((s) => s.group == g.id)) {
              if (ttcDoorSectionIsRows(s.tiles)) {
                expect(
                  find.byKey(ttcDoorRowsKey(s.heading), skipOffstage: false),
                  findsOneWidget,
                  reason: '"${s.heading}" is all written and is not rows',
                );
              } else {
                final rail = find.byKey(
                  ttcDoorSectionRailKey(s.heading),
                  skipOffstage: false,
                );
                expect(
                  rail,
                  findsOneWidget,
                  reason: '"${s.heading}" is mixed and is not a rail',
                );
                // Edge to edge: the rail is the full screen wide and starts at
                // the screen's edge; its own padding is the gutter.
                expect(
                  tester.getSize(rail).width,
                  360,
                  reason: '"${s.heading}" is padded in from the edge',
                );
                expect(tester.getTopLeft(rail).dx, 0);
              }
            }
          }
        });
      }

      test(
        'at least one section of each kind exists, or the rule is untested',
        () {
          final all = [for (final p in kTtcFocusPages) ...p.sections];
          expect(all.where((s) => ttcDoorSectionIsRows(s.tiles)), isNotEmpty);
          expect(all.where((s) => !ttcDoorSectionIsRows(s.tiles)), isNotEmpty);
        },
      );
    },
  );

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
        expect(find.text(read.whenToSeeSomeone.title.en), findsOneWidget);
        // Whole, not an excerpt: one line per sentence since 2026-09-26
        // (review D2), every sentence the read's own, in order. Kept for
        // revert: find.text(read.whenToSeeSomeone.body.en), findsOneWidget.
        final lines = ttcFlagLines(read.whenToSeeSomeone.body.en);
        expect(lines, isNotEmpty);
        for (final l in lines) {
          expect(find.text(l), findsOneWidget, reason: l);
        }
      },
    );

    testWidgets('Mind and body Talk carries both flags', (tester) async {
      final page = kTtcFocusPages.firstWhere(
        (p) => p.bracketId == 'ttc_mind_body',
      );
      await pumpDoor(tester, page, height: 6000);
      final talk = page.groups!.indexWhere((g) => g.id == 'talk');
      await pickTab(tester, talk);
      for (final rid in page.groups![talk].pinnedRedFlagReadIds) {
        expect(
          find.byKey(ttcDoorFlagKey(rid), skipOffstage: false),
          findsOneWidget,
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
        focus.any((l) => l.contains('openTtcDoor(context, bracketId)')),
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
            expect(norm(lines.join(' ')), norm(body),
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
      final title = ttcReadById(rid)!.whenToSeeSomeone.title.en;
      await tester.tap(find.text(title));
      await tester.pump(const Duration(milliseconds: 400));
      expect(names.length, greaterThan(1), reason: 'the flag opened nothing');
      final size = tester.getSize(find.text('Read the full piece'));
      expect(size.height, greaterThan(0));
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
      expect(find.text('Going through it'), findsWidgets);
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
}

class _Names extends NavigatorObserver {
  _Names(this.onPush);
  final void Function(String?) onPush;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onPush(route.settings.name);
}
