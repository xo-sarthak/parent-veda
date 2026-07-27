// =============================================================================
//  Ask Veda × TTC — routing and the partner privacy rule
// -----------------------------------------------------------------------------
//  The TTC Ask Veda work shipped without tests. Two of its rules are exactly
//  the kind that erode quietly, because breaking either one still compiles,
//  still runs, and still shows a plausible answer:
//
//   1. The FAB must open the TTC Ask Veda inside the TTC stack. Before the
//      three-way branch existed it opened the PREGNANCY one and passed a week
//      number that means nothing to a couple who are not pregnant. Nothing
//      about that failure looks broken on screen.
//
//   2. Her cycle day must never leave the PARTNER's device. The data model
//      enforces this in Postgres (ttc_cycles is own-row, he has no read policy
//      and sees only the chapter she publishes) - but the Ask Veda call is a
//      client-side path that could route around the database rule entirely.
//      Today it is guarded by `widget.partnerMode` and a comment asking the
//      next person not to simplify it away. A comment is not an enforcement.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_askveda_screen.dart';
import 'package:parentveda/screens/ttc/ttc_chapter_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_chapter_data.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/widgets/global_ask_fab.dart';

Future<void> pumpTall(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcPartnerMode.instance.on = false;
    TtcLang.instance.hinglish = false;
  });

  tearDown(() => TtcPartnerMode.instance.on = false);

  // ===========================================================================
  group('the FAB knows which stage it is standing in', () {
    test('the TTC root route constant matches the shell anchor', () {
      // Two files have to agree on this string or the branch silently misses.
      expect(kTtcRootRoute, ttcHomeRoute);
    });

    test('the three stage anchors are distinct', () {
      expect({kTtcRootRoute, kParentingRootRoute}.length, 2);
    });

    Route<void> routed(String? name) => MaterialPageRoute<void>(
          settings: RouteSettings(name: name),
          builder: (_) => const SizedBox(),
        );

    test('inside the TTC stack it reports TTC, not pregnancy', () {
      final observer = FabRouteObserver();
      observer.didPush(routed('/'), null);
      expect(FabState.instance.inTtc, isFalse);

      observer.didPush(routed(kTtcRootRoute), null);
      expect(FabState.instance.inTtc, isTrue,
          reason: 'the FAB would open the pregnancy Ask Veda inside TTC');
      expect(FabState.instance.inParenting, isFalse);
    });

    test('leaving TTC clears it', () {
      final observer = FabRouteObserver();
      final ttcRoute = routed(kTtcRootRoute);
      observer.didPush(routed('/'), null);
      observer.didPush(ttcRoute, null);
      expect(FabState.instance.inTtc, isTrue);
      observer.didPop(ttcRoute, null);
      expect(FabState.instance.inTtc, isFalse);
    });

    test('a deep TTC route still counts as being in TTC', () {
      // The stage anchor stays on the stack while a tool is open on top.
      final observer = FabRouteObserver();
      observer.didPush(routed(kTtcRootRoute), null);
      observer.didPush(routed('ttc/tools'), null);
      expect(FabState.instance.inTtc, isTrue);
    });

    test('the FAB hides itself over the Ask Veda screen', () {
      final observer = FabRouteObserver();
      observer.didPush(routed(kTtcRootRoute), null);
      FabState.instance.markAppLive();
      expect(FabState.instance.visible, isTrue);
      observer.didPush(routed(kAskVedaRoute), null);
      expect(FabState.instance.visible, isFalse);
    });

    test('the TTC Ask Veda route is named so the FAB can suppress it', () {
      final source =
          File('lib/screens/ttc/ttc_askveda_screen.dart').readAsStringSync();
      expect(source.contains('kAskVedaRoute'), isTrue,
          reason: 'the FAB would float over its own Ask Veda screen');
    });
  });

  // ===========================================================================
  group('her cycle day never leaves the partner\'s device', () {
    final source =
        File('lib/screens/ttc/ttc_askveda_screen.dart').readAsStringSync();

    test('the cycle day is guarded by partner mode', () {
      // The wire body cannot be observed without a live server, so the guard
      // itself is pinned. If someone "simplifies" this to a bare
      // `cycleDay: s.today.cycleDay`, this fails.
      expect(source.contains('widget.partnerMode ? null :'), isTrue,
          reason:
              'the partner-mode guard on cycleDay is gone - his device would '
              'send her cycle day and route around the database rule');
    });

    test('the chapter comes from the partner-safe accessor', () {
      // displayChapter falls back to the chapter SHE publishes, rather than
      // deriving one from a cycle his account cannot see.
      expect(source.contains('displayChapter'), isTrue);
      expect(source.contains('today.chapter'), isFalse,
          reason: 'that would derive his chapter from cycle data he must not '
              'have');
    });

    testWidgets('his door opens in partner mode', (tester) async {
      late BuildContext ctx;
      await pumpTall(
        tester,
        Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        }),
      );
      openTtcAskVeda(ctx, partnerMode: true);
      await tester.pumpAndSettle();

      final screen =
          tester.widget<TtcAskVedaScreen>(find.byType(TtcAskVedaScreen));
      expect(screen.partnerMode, isTrue);
    });

    testWidgets('her door does not', (tester) async {
      late BuildContext ctx;
      await pumpTall(
        tester,
        Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        }),
      );
      openTtcAskVeda(ctx);
      await tester.pumpAndSettle();

      final screen =
          tester.widget<TtcAskVedaScreen>(find.byType(TtcAskVedaScreen));
      expect(screen.partnerMode, isFalse);
    });

    test('the partner screen passes partnerMode when it opens Ask Veda', () {
      final partner =
          File('lib/screens/ttc/ttc_partner_screen.dart').readAsStringSync();
      expect(partner.contains('openTtcAskVeda(context, partnerMode: true)'),
          isTrue,
          reason: 'his Ask Veda card would open in HER mode and send her '
              'cycle day');
    });
  });

  // ===========================================================================
  group('stage context is framing, never a filter', () {
    final service =
        File('lib/services/remote/ask_veda_service.dart').readAsStringSync();

    test('every TTC context field is optional on the wire', () {
      // `if (x != null)` on each one - so a missing field never becomes a
      // gate, and one journey stays one journey.
      for (final field in [
        "if (stage != null) 'stage'",
        "if (chapter != null) 'chapter'",
        "if (cycleDay != null) 'cycle_day'",
        "if (ttcPath != null) 'ttc_path'",
        "if (monthsTrying != null) 'months_trying'",
      ]) {
        expect(service.contains(field), isTrue, reason: 'missing: $field');
      }
    });

    test('domain gating is still not used by TTC', () {
      final ttc =
          File('lib/screens/ttc/ttc_askveda_screen.dart').readAsStringSync();
      expect(ttc.contains('domain:'), isFalse,
          reason: 'a domain filter would gate answers by stage - the one '
              'thing the master document forbids');
    });
  });

  // ===========================================================================
  group('the chapter suggestions are wired', () {
    test('every chapter still offers questions in both languages', () {
      for (final c in TtcChapter.values) {
        final content = ttcChapterContent[c]!;
        expect(content.askVeda(false), isNotEmpty, reason: '$c');
        expect(content.askVeda(true).length, content.askVeda(false).length,
            reason: '$c');
      }
    });

    testWidgets('tapping one opens Ask Veda with that question', (tester) async {
      const chapter = TtcChapter.preparingTogether;
      final question = ttcChapterContent[chapter]!.askVeda(false).first;

      await pumpTall(tester, const TtcChapterScreen(chapter: chapter));
      await tester.tap(find.text(question));
      await tester.pumpAndSettle();

      final screen =
          tester.widget<TtcAskVedaScreen>(find.byType(TtcAskVedaScreen));
      expect(screen.initialQuery, question,
          reason: 'the suggestion opened Ask Veda empty');
      // And from her side, so the cycle day is allowed.
      expect(screen.partnerMode, isFalse);
    });
  });
}
