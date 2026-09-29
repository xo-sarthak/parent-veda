// =============================================================================
//  Safety lines on the TTC doors, and the one "Get help now" page (2026-09-28)
// -----------------------------------------------------------------------------
//  The user's option B for the emergency callouts at the top of the door tabs:
//
//    1. The folded flag row comes off the top of every tab, EXCEPT where the
//       topic can be a real emergency: After a loss › Your body (heavy
//       bleeding, severe pain, the ectopic sign in the shoulder). The rule is
//       a list in code, `kTtcDoorFlagTabs`, and this file pins it.
//    2. The guidance is not gone: every pinned read still has its "When to see
//       someone" section in the reader, and is still a tile on its door.
//    3. One calm page, "Get help now": Tele-MANAS, 112 and her own doctor,
//       with a Call pill that dials the number already in the app.
//    4. The WIRING GATE: the end of Mind & body › Hard days, the end of its
//       Today tab and You › Your health all open it, by a tap.
// =============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/mind_mood_data.dart';
import 'package:parentveda/models/pv_read.dart';
import 'package:parentveda/screens/doors/pv_door_chrome.dart'
    show kPvUrgentTint;
import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_card.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_rail.dart';
import 'package:parentveda/screens/ttc/doors/ttc_door_screen.dart';
// Kept for revert (2026-09-29): the TTC bar was pumped with the You screen.
// import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_get_help_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart' show TtcLang;
import 'package:parentveda/services/bracket_resolver.dart';
import 'package:parentveda/services/life_stage_store.dart';
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

// A 1x1 transparent PNG.
const _kPixel = <int>[
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
  }) => Stream<List<int>>.value(_kPixel).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
}

class _Names extends NavigatorObserver {
  _Names(this.onPush);
  final void Function(String?) onPush;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onPush(route.settings.name);
}

String _src(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// Lines that are code, not comments.
String _live(String src) => src
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

TtcFocusPage _door(String id) =>
    kTtcFocusPages.firstWhere((p) => p.bracketId == id);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    HttpOverrides.global = _StubHttpOverrides();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });
  tearDown(() => HttpOverrides.global = null);

  Future<List<String?>> pumpDoor(
    WidgetTester tester,
    TtcFocusPage page, {
    double height = 6000,
  }) async {
    tester.view.physicalSize = Size(360, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final names = <String?>[];
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [_Names(names.add)],
        home: TtcDoorScreen(page: page, bracket: bracketById(page.bracketId)!),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
    return names;
  }

  Future<void> pickTab(WidgetTester tester, int i) async {
    final card = find.byKey(ttcDoorRailCardKey(i));
    await tester.ensureVisible(card);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(card, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
  }

  // ===========================================================================
  group('the safety line stays only where it can be an emergency', () {
    test('the rule is one tab: After a loss, Your body', () {
      expect(kTtcDoorFlagTabs, {
        'ttc_after_loss': {'body'},
      });
      expect(ttcDoorShowsFlag('ttc_after_loss', 'body'), isTrue);
      expect(ttcDoorShowsFlag('ttc_after_loss', 'support'), isFalse);
      expect(ttcDoorShowsFlag('ttc_mind_body', 'hard'), isFalse);
      expect(ttcDoorShowsFlag('ttc_mind_body', 'talk'), isFalse);
    });

    test("and that tab's line is about bleeding, pain and the ectopic sign",
        () {
      final body = _door('ttc_after_loss')
          .groups!
          .firstWhere((g) => g.id == 'body');
      final flag =
          ttcReadById(body.pinnedRedFlagReadIds.single)!.whenToSeeSomeone;
      final words = flag.body.en.toLowerCase();
      expect(flag.title.en.toLowerCase(), contains('hospital'));
      expect(words, contains('pads'), reason: 'heavy bleeding');
      expect(words, contains('severe pain'));
      expect(words, contains('shoulder'), reason: 'the ectopic sign');
    });

    for (final page in kTtcFocusPages) {
      testWidgets('${page.bracketId}: no flag row outside the rule',
          (tester) async {
        await pumpDoor(tester, page);
        for (var i = 0; i < page.groups!.length; i++) {
          final g = page.groups![i];
          await pickTab(tester, i);
          final rows = find.byType(TtcDoorFlagRow, skipOffstage: false);
          final wanted = ttcDoorShowsFlag(page.bracketId, g.id) &&
              g.pinnedRedFlagReadIds.isNotEmpty;
          expect(rows, wanted ? findsOneWidget : findsNothing,
              reason: '${page.bracketId} / ${g.id}');
        }
      });
    }

    testWidgets('After a loss › Your body opens on one compact line',
        (tester) async {
      final page = _door('ttc_after_loss');
      await pumpDoor(tester, page);
      final rid = page.groups!.first.pinnedRedFlagReadIds.first;
      final row = find.byKey(ttcDoorFlagKey(rid));
      expect(row, findsOneWidget);
      expect(tester.widget<TtcDoorFlagRow>(row).compact, isTrue);
      expect(tester.getSize(row).height, lessThan(60));
      expect(find.text('Tap to see the signs'), findsNothing,
          reason: 'one line, not two');
      // Still opens the whole list.
      await tester.tap(row);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Read the full piece'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('the guidance is not gone', () {
    test('the reader always draws "When to see someone"', () {
      final reader = _live(_src('lib/screens/reader/pv_reader_screen.dart'));
      expect(reader.contains('_callout(s, a.whenToSeeSomeone)'), isTrue);
    });

    test('every pinned read resolves, is urgent, and is a tile on its door',
        () {
      var checked = 0;
      for (final page in kTtcFocusPages) {
        final onDoor = {
          for (final t in page.allTiles)
            ?switch (t) {
              TtcArticleTile(:final readId) => readId,
              TtcGuideTile(:final readId) => readId,
              _ => null,
            },
        };
        for (final g in page.groups ?? const <TtcFocusGroup>[]) {
          for (final rid in g.pinnedRedFlagReadIds) {
            final read = ttcReadById(rid);
            expect(read, isNotNull, reason: rid);
            expect(read!.whenToSeeSomeone.tone, PvCalloutTone.urgent);
            expect(read.whenToSeeSomeone.body.en.trim(), isNotEmpty);
            expect(onDoor, contains(rid),
                reason: '${page.bracketId}: $rid is no longer reachable '
                    'from its door, so its list is not either');
            checked++;
          }
        }
      }
      expect(checked, greaterThan(5));
    });
  });

  // ===========================================================================
  group('the Get help now page', () {
    Future<List<String>> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final dialled = <String>[];
      await tester.pumpWidget(MaterialApp(
        home: TtcGetHelpScreen(dial: (n) async => dialled.add(n)),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'overflow at 360');
      return dialled;
    }

    testWidgets('three rows, the numbers already in the app, calls that dial',
        (tester) async {
      final dialled = await pumpPage(tester);
      expect(find.text(kTtcGetHelpTitle), findsOneWidget);
      expect(
          find.text("If you're struggling or something feels wrong right "
              "now, you don't have to wait."),
          findsOneWidget);

      expect(kCrisisHelplineNumber, '14416');
      expect(kEmergencyNumber, '112');
      expect(find.text('Tele-MANAS, 14416'), findsOneWidget);
      expect(find.text('Emergency, 112'), findsOneWidget);
      expect(find.text('Your doctor or clinic'), findsOneWidget);
      expect(find.textContaining('1-800-891-4416'), findsOneWidget);

      // A Call pill on the two lines with a number; none on the doctor's.
      expect(find.byKey(ttcGetHelpCallKey('14416')), findsOneWidget);
      expect(find.byKey(ttcGetHelpCallKey('112')), findsOneWidget);
      expect(find.text('Call 14416'), findsOneWidget);
      expect(find.text('Call 112'), findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('ttc-get-help-doctor')),
              matching: find.textContaining('Call ')),
          findsOneWidget,
          reason: 'only the "Call them for..." line, no pill');
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('ttc-get-help-doctor')),
              matching: find.byIcon(Icons.call_outlined)),
          findsNothing);

      // When to use which, one line each.
      expect(find.textContaining('thoughts of harming yourself'),
          findsOneWidget);
      expect(find.text('Call if you or someone is in danger.'), findsOneWidget);
      expect(find.text('Call them for pregnancy or treatment worries.'),
          findsOneWidget);

      await tester.tap(find.byKey(ttcGetHelpCallKey('14416')));
      await tester.tap(find.byKey(ttcGetHelpCallKey('112')));
      await tester.tap(find.byKey(ttcGetHelpCallKey(kCrisisHelplineNumberAlt)));
      // 108 for an ambulance, on the 112 row's second line (2026-09-28).
      expect(kAmbulanceNumber, '108');
      expect(find.text('For an ambulance, you can also call 108.'),
          findsOneWidget);
      await tester.ensureVisible(find.byKey(ttcGetHelpCallKey('108')));
      await tester.tap(find.byKey(ttcGetHelpCallKey('108')));
      await tester.pump();
      // Kept for revert: expect(dialled, ['14416', '112', kCrisisHelplineNumberAlt]);
      expect(dialled, ['14416', '112', kCrisisHelplineNumberAlt, '108']);
    });

    testWidgets('calm: no red on the page', (tester) async {
      await pumpPage(tester);
      final colours = tester
          .widgetList<Material>(find.byType(Material))
          .map((m) => m.color)
          .whereType<Color>();
      expect(colours, isNot(contains(kPvUrgentTint)));
      expect(find.byIcon(Icons.priority_high_rounded), findsNothing);
    });

    test('its words carry no dashes', () {
      final code = _live(_src('lib/screens/ttc/ttc_get_help_screen.dart'));
      expect(code.contains('—'), isFalse);
      expect(code.contains('–'), isFalse);
    });

    test('the dialler is the app\'s own tel: launch', () {
      final code = _live(_src('lib/screens/ttc/ttc_get_help_screen.dart'));
      expect(code.contains("Uri(scheme: 'tel', path: number)"), isTrue);
      expect(code.contains("RouteSettings(name: kTtcGetHelpRoute)"), isTrue);
      expect(kTtcGetHelpRoute, 'ttc/get_help');
    });
  });

  // ===========================================================================
  group('the wiring gate: three ways in, each by a tap', () {
    Future<void> openFrom(
        WidgetTester tester, String tabId, List<String?> names) async {
      final page = _door('ttc_mind_body');
      final i = page.groups!.indexWhere((g) => g.id == tabId);
      if (i > 0) await pickTab(tester, i);
      final row = find.byKey(kTtcGetHelpRowKey, skipOffstage: false);
      expect(row, findsOneWidget, reason: '$tabId has no Get help row');
      expect(find.text(kTtcGetHelpAsk, skipOffstage: false), findsOneWidget);
      await tester.ensureVisible(row);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(row);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(TtcGetHelpScreen), findsOneWidget);
      expect(names.last, kTtcGetHelpRoute);
    }

    testWidgets('the end of Mind & body › Hard days', (tester) async {
      final names = await pumpDoor(tester, _door('ttc_mind_body'));
      await openFrom(tester, 'hard', names);
    });

    testWidgets('the end of Mind & body › Today, the tab it opens on',
        (tester) async {
      final names =
          await pumpDoor(tester, _door('ttc_mind_body'), height: 9000);
      await openFrom(tester, 'today', names);
    });

    testWidgets('the row sits after the content, never above it',
        (tester) async {
      final page = _door('ttc_mind_body');
      await pumpDoor(tester, page);
      final hard = page.groups!.indexWhere((g) => g.id == 'hard');
      await pickTab(tester, hard);
      final rowTop = tester
          .getTopLeft(find.byKey(kTtcGetHelpRowKey, skipOffstage: false))
          .dy;
      for (final s in page.sections.where((s) => s.group == 'hard')) {
        expect(
            tester.getTopLeft(find.text(s.heading, skipOffstage: false).first)
                .dy,
            lessThan(rowTop),
            reason: '"${s.heading}" sits under the Get help row');
      }
    });

    testWidgets('no other door or tab ends on it', (tester) async {
      for (final page in kTtcFocusPages) {
        await pumpDoor(tester, page);
        for (var i = 0; i < page.groups!.length; i++) {
          final g = page.groups![i];
          await pickTab(tester, i);
          expect(find.byKey(kTtcGetHelpRowKey, skipOffstage: false),
              ttcDoorEndsOnGetHelp(page.bracketId, g.id)
                  ? findsOneWidget
                  : findsNothing,
              reason: '${page.bracketId} / ${g.id}');
        }
      }
    });

    // 2026-09-29: the profile's one Settings row, then Support (Co-Star
    // keeps its crisis lines in Settings' Support the same way). Kept for
    // revert: 'You › Your health › Get help now', through the bento tile.
    testWidgets('Profile › Settings › Get help now', (tester) async {
      tester.view.physicalSize = const Size(1200, 9000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final names = <String?>[];
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [_Names(names.add)],
        // Kept for revert: PvYouScreen with the TTC bar (the More tab).
        home: const PvYouScreen(stage: LifeStage.tryingToConceive),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // ⚠️ SINCE 2026-09-28 THE TAB IS MORE, A BENTO: the row is behind the
      // Your health tile. Kept for revert: the row was on the tab itself.
      //   await tester.tap(
      //       find.byKey(const ValueKey('pv_more_tile_your_health')));
      await tester.tap(find.byKey(kPvProfileSettingsRowKey));
      await tester.pumpAndSettle();
      final row = find.text(kTtcGetHelpTitle);
      expect(row, findsOneWidget);
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(TtcGetHelpScreen), findsOneWidget);
      expect(names.last, kTtcGetHelpRoute);
    });

    test('the three call sites, in the source', () {
      final door = _live(_src('lib/screens/ttc/doors/ttc_door_screen.dart'));
      expect(door.contains('openTtcGetHelp(context)'), isTrue);
      final you = _live(_src('lib/screens/profile/pv_you_content.dart'));
      expect(you.contains('openTtcGetHelp(c)'), isTrue);
    });
  });
}
