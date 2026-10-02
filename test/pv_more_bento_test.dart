// =============================================================================
//  TTC's More tab: the bento (2026-09-28)
// -----------------------------------------------------------------------------
//  The user: "the last option in bottom navigation pill should be 'more' not
//  you, and in that ... for each heading follow bento design ... like CRED
//  does, then when you click on each tab you see what's listed for it."
//
//  What this file holds:
//    1. THE BAR says More on trying to conceive; the other stages' You screen
//       still says You and draws its eight sections.
//    2. EVERY ROW THE TTC LIST HAD is reachable through exactly one tile, and
//       every tile opens its list (tapped, not read from the source: the
//       wiring gate in CLAUDE.md is about what a thumb reaches).
//    3. IT HOLDS at 360dp and at 1.5x text, the grid and every page behind it.
//    4. A SCREEN READER hears one button per tile, with its title and caption.
//
//  ⚠️ RETIRED 2026-09-29. The user found the bento "poor", and the More tab
//  and the avatar showed the same screen. More is its own screen of offerings
//  (lib/screens/ttc/ttc_more_tab.dart) and the avatar opens her profile with
//  one Settings row; both are held by test/ttc_more_profile_test.dart. The
//  bento's code is kept for revert (`kPvTtcMoreBento`), so this file now
//  holds that it is retired, that the kept grid still lays out, and that the
//  other stages are untouched. The bento's own tests are kept below as a
//  block comment, for the day the flag flips back.
// =============================================================================

// The helpers and imports below serve the kept-for-revert block comment.
// ignore_for_file: unused_import, unused_element, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/profile/pv_more_bento.dart';
import 'package:parentveda/screens/profile/pv_you_content.dart';
import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_more_tab.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/widgets/pv_nav_bar.dart';

/// The tiles, in the grid's order.
const _tileIds = [
  'your_health',
  'things',
  'your_app',
  'journey',
  'family',
  // New on 2026-09-28 (Tools holds only tools): what left Tools because it
  // is not a tool. Kept for revert: absent.
  'experts_and_courses',
  'bookings_and_orders',
  'preferences',
  'support',
  'account',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcHomeVersionStore.instance.set(TtcHomeVersion.v3);
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    double width = 392,
    double height = 3000,
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        builder: (c, w) => MediaQuery(
          data: MediaQuery.of(
            c,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: w!,
        ),
        home: child,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  const ttcMore = PvYouScreen(
    stage: LifeStage.tryingToConceive,
    bottomNav: TtcBottomNav(active: 4, v3: true),
  );

  Finder tile(String id) => find.byKey(ValueKey('pv_more_tile_$id'));

  /// Opens a tile, returns every text on its page, and comes back.
  Future<Set<String>> openAndRead(WidgetTester tester, String id) async {
    await tester.ensureVisible(tile(id));
    await tester.tap(tile(id));
    await tester.pumpAndSettle();
    expect(
      find.byType(PvMoreGroupScreen),
      findsOneWidget,
      reason: 'the "$id" tile did not open its list',
    );
    final texts = <String>{
      for (final e
          in find
              .descendant(
                of: find.byType(PvMoreGroupScreen),
                matching: find.byType(Text),
              )
              .evaluate())
        if ((e.widget as Text).data != null) (e.widget as Text).data!,
    };
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).last);
    await tester.pumpAndSettle();
    expect(find.byType(PvMoreGroupScreen), findsNothing);
    return texts;
  }

  // ===========================================================================
  group('the bar', () {
    testWidgets('TTC: the last pill says More, with the grid glyph', (
      tester,
    ) async {
      await pump(
        tester,
        const Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: TtcBottomNav(active: 0, v3: true),
          ),
        ),
      );
      final bar = tester.widget<PvNavBar>(find.byType(PvNavBar));
      expect(bar.items.last.label, 'More');
      expect(bar.items.last.icon, Icons.grid_view_outlined);
      expect(
        bar.items.map((i) => i.label),
        isNot(contains('You')),
        reason: 'You became More on the TTC bar',
      );
    });

    // Kept for revert (2026-09-29): 'More opens the bento, lit on its tab',
    // which expected PvYouScreen and PvBentoGrid.
    testWidgets('More opens the More tab, lit on its tab', (tester) async {
      await pump(
        tester,
        const Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: TtcBottomNav(active: 0, v3: true),
          ),
        ),
      );
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      // Kept for revert:
      //   expect(find.byType(PvYouScreen), findsOneWidget);
      //   expect(find.byType(PvBentoGrid), findsOneWidget);
      expect(find.byType(TtcMoreTab), findsOneWidget);
      expect(find.byType(PvYouScreen), findsNothing);
      expect(find.byType(PvBentoGrid), findsNothing);
      expect(
        tester.widget<PvNavBar>(find.byType(PvNavBar).last).activeIndex,
        4,
      );
      // The route keeps its name: the lit-tab map reads it.
      expect(kTtcMoreRoute, kTtcYouRoute);
      expect(ttcV3ActiveFor(kTtcMoreRoute, 0), 4);
    });
  });

  // ===========================================================================
  group('retired, not deleted', () {
    test('the flags: the profile is on, the bento is off', () {
      expect(kPvTtcProfileV2, isTrue);
      expect(kPvTtcMoreBento, isFalse);
    });

    testWidgets('TTC You draws the profile, not the bento', (tester) async {
      await pump(tester, const PvYouScreen(stage: LifeStage.tryingToConceive));
      expect(find.byType(PvBentoGrid), findsNothing);
      expect(find.text('Profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final (w, scale) in [(360.0, 1.0), (360.0, 1.5)]) {
      testWidgets('the kept grid still lays out at ${w.toInt()}dp, ${scale}x',
          (tester) async {
        final tiles = [
          for (var i = 0; i < 5; i++)
            PvBentoTileData(
              id: 't$i',
              title: 'Tile $i',
              caption: 'What is inside tile $i, in one line',
              icon: Icons.bookmark_outline_rounded,
              hue: 150,
              onTap: () {},
            ),
        ];
        await pump(
          tester,
          Scaffold(body: ListView(children: [PvBentoGrid(tiles: tiles)])),
          width: w,
          textScale: scale,
        );
        expect(tester.takeException(), isNull);
        expect(tile('t0'), findsOneWidget);
      });
    }
  });

  /* Kept for revert (2026-09-29): the bento's own tests, from when the TTC
     More tab was this grid. They pump `ttcMore` (PvYouScreen with the TTC
     bar), which now draws the profile.

  // ===========================================================================
  group('the bento', () {
    testWidgets('the identity card, then one tile per heading, in order', (
      tester,
    ) async {
      await pump(tester, ttcMore);
      expect(tester.takeException(), isNull);
      expect(find.text('More'), findsWidgets);
      final ys = <double>[];
      for (final id in _tileIds) {
        expect(tile(id), findsOneWidget, reason: 'no "$id" tile');
        ys.add(tester.getTopLeft(tile(id)).dy);
      }
      // Reading order: never further up than the tile before it.
      for (var i = 1; i < ys.length; i++) {
        expect(
          ys[i],
          greaterThanOrEqualTo(ys[i - 1]),
          reason: '${_tileIds[i]} is out of order',
        );
      }
      // The list's section eyebrows are gone from the top level.
      for (final eyebrow in ['YOUR JOURNEY', 'FAMILY', 'PREFERENCES']) {
        expect(find.text(eyebrow), findsNothing, reason: eyebrow);
      }
    });

    testWidgets('mixed sizes: health is tall, the journey is full width', (
      tester,
    ) async {
      await pump(tester, ttcMore);
      final health = tester.getSize(tile('your_health'));
      final things = tester.getSize(tile('things'));
      final journey = tester.getSize(tile('journey'));
      final family = tester.getSize(tile('family'));
      expect(health.height, greaterThan(things.height));
      expect(journey.width, greaterThan(family.width * 1.8));
    });

    testWidgets('every tile opens its list', (tester) async {
      await pump(tester, ttcMore);
      for (final id in _tileIds) {
        final texts = await openAndRead(tester, id);
        expect(texts, isNotEmpty, reason: id);
      }
    });

    testWidgets('every row the TTC list had is behind exactly one tile', (
      tester,
    ) async {
      final content = pvYouContentFor(LifeStage.tryingToConceive);
      // The rows as they were on the grouped list (2026-09-27), read from
      // the content table so a row added there is held here too.
      final rows = <String>[
        for (final t in content.tiles) t.title,
        for (final g in content.groups!)
          for (final t in g.things) t.title,
        // The journey's own rows (2026-09-28: the journey map).
        for (final t in content.journeyThings) t.title,
        // The sections the screen draws itself.
        'I got a positive test',
        'Your partner',
        'Language',
        'Reminders',
        'WhatsApp updates',
        // Not on this stage since 2026-09-28: it opened Your details, which
        // "Your answers" under Your health already opens (no random
        // repetition). Kept for revert:
        // 'Personalise ParentVeda',
        'Help',
        'Invite a friend',
        'Employer benefits',
        'About ParentVeda',
        'Not signed in',
        'Data and privacy',
        'Delete account',
      ];
      await pump(tester, ttcMore);
      final pages = <String, Set<String>>{
        for (final id in _tileIds) id: await openAndRead(tester, id),
      };
      for (final row in rows) {
        final homes = [
          for (final e in pages.entries)
            if (e.value.contains(row)) e.key,
        ];
        expect(
          homes.length,
          1,
          reason: '"$row" is behind ${homes.length} tiles: $homes',
        );
      }
    });

    testWidgets('a row on a page lands where it did', (tester) async {
      final names = <String?>[];
      tester.view.physicalSize = const Size(392, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(navigatorObservers: [_Names(names.add)], home: ttcMore),
      );
      await tester.pump();
      await tester.ensureVisible(tile('bookings_and_orders'));
      await tester.tap(tile('bookings_and_orders'));
      await tester.pumpAndSettle();
      expect(names.last, 'you/more/bookings_and_orders');
      await tester.tap(find.text('Bookings'));
      await tester.pumpAndSettle();
      expect(names.last, 'bookings');
    });

    // The language lives in the You screen's state and a store, not in the
    // page; the page must still show the new value the moment it changes.
    // (The WhatsApp switch would be the same test, but its save reaches for
    // Supabase, which a widget test has not initialised.)
    testWidgets('a choice made on a page repaints that page', (tester) async {
      addTearDown(() => TtcLang.instance.hinglish = false);
      await pump(tester, ttcMore);
      await tester.tap(tile('preferences'));
      await tester.pumpAndSettle();
      expect(find.text('English'), findsOneWidget);
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('हिंदी').last);
      await tester.pumpAndSettle();
      expect(find.byType(PvMoreGroupScreen), findsOneWidget);
      expect(
        find.text('हिंदी'),
        findsOneWidget,
        reason: 'the Language row still says English',
      );
    });

    testWidgets('a screen reader hears one button per tile', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, ttcMore);
      final content = pvYouContentFor(LifeStage.tryingToConceive);
      final health = content.groups!.first;
      final node = tester.getSemantics(tile('your_health'));
      expect(node.label, contains(health.title));
      expect(node.label, contains(health.caption!));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });
  });

  // ===========================================================================
  group('it holds', () {
    for (final (w, scale) in [(360.0, 1.0), (360.0, 1.5), (392.0, 1.5)]) {
      testWidgets('${w.toInt()}dp at ${scale}x: the grid and every page', (
        tester,
      ) async {
        await pump(tester, ttcMore, width: w, height: 4000, textScale: scale);
        expect(tester.takeException(), isNull);
        for (final id in _tileIds) {
          await openAndRead(tester, id);
          expect(tester.takeException(), isNull, reason: id);
        }
      });
    }
  });

  */

  // ===========================================================================
  group('the other stages', () {
    // Pregnancy left this list on 2026-10-01: it draws the short profile now
    // (test/pv_you_pregnancy_test.dart). Kept for revert: it was the first of
    // these three.
    for (final stage in [
      LifeStage.parenting,
      LifeStage.skilling,
    ]) {
      testWidgets('${stage.name}: You, its sections, no bento', (tester) async {
        await pump(tester, PvYouScreen(stage: stage), height: 9000);
        expect(find.byType(PvBentoGrid), findsNothing);
        expect(find.text('More'), findsNothing);
        expect(find.text('YOUR JOURNEY'), findsOneWidget);
        expect(find.text('PREFERENCES'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      });
    }
  });
}

class _Names extends NavigatorObserver {
  _Names(this.onName);
  final void Function(String?) onName;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onName(route.settings.name);
}
