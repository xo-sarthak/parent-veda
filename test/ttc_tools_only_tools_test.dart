// =============================================================================
//  Tools holds only tools; More holds everything else (2026-09-28)
// -----------------------------------------------------------------------------
//  The user: "under Tools I should only be seeing tools, that's all. And
//  instead of the You button in the bottom navigation pill I want a More
//  button, and that button should have everything else that was extra inside
//  Tools, except tools, so that it's very clear and evident what the More
//  button is doing."
//
//  A tool, as ttc_tools_screen.dart defines it: something she uses to record,
//  track, calculate, check or plan her own data. What this file holds:
//
//    1. EVERY TOOLS ROW IS A TOOL, by the classification in `kTtcToolKinds`,
//       for her and for him. A new row fails here until someone decides.
//    2. EVERY NON-TOOL THAT LEFT TOOLS is on exactly one More tile, tapped the
//       way her thumb taps it, for her and for him.
//    3. NO TOOL IS INSIDE MORE: no More row is named like a Tools row.
//    4. NO DESTINATION TWICE across the bar, Tools and More, by route name,
//       with a reasoned allow-list (empty today).
//    5. IT HOLDS at 360dp and at 1.5x text: the Tools hub, hers and his, and
//       the More grid with the two tiles that changed.
//
//  ⚠️ 2026-09-29: MORE IS ITS OWN SCREEN (lib/screens/ttc/ttc_more_tab.dart),
//  headed sections of what the app offers, not the You screen's bento. The
//  rules above hold unchanged; the finders read More's rows and links
//  instead of the bento's tiles and pages. The bento versions are kept below
//  as block comments.
// =============================================================================

// The bento helpers serve the kept-for-revert block comments.
// ignore_for_file: unused_element, unused_local_variable, unused_import

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/learn/pv_learn_screen.dart';
import 'package:parentveda/screens/profile/pv_more_bento.dart';
import 'package:parentveda/screens/profile/pv_you_chrome.dart';
import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_learn_screen.dart'
    show kTtcLearnRoute;
import 'package:parentveda/screens/ttc/ttc_more_tab.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

class _NoNet extends HttpOverrides {}

/// The More tiles whose rows lead to her things. Preferences, Support,
/// Account and Family are settings, help and pairing: they open shared
/// screens (language, sign-in, the partner page) that no tool or tab opens,
/// and several of them reach for Supabase, which a widget test has not
/// initialised. They are covered for layout by pv_more_bento_test.dart.
const _destinationTiles = [
  'your_health',
  'things',
  'your_app',
  'journey',
  'experts_and_courses',
  'bookings_and_orders',
];

/// Every More tile, in the grid's order.
const _allTiles = [
  'your_health',
  'things',
  'your_app',
  'journey',
  'family',
  'experts_and_courses',
  'bookings_and_orders',
  'preferences',
  'support',
  'account',
];

/// The bar's five destinations.
const _barRoutes = {
  ttcHomeRoute,
  kTtcLearnRoute,
  'ttc/products',
  'ttc/tools',
  kTtcYouRoute,
};

/// Route names allowed to be reached from more than one place, with why.
/// Empty: every destination has one home. Add a reason, never just a name.
const Map<String, String> _allowedTwice = {};

class _Names extends NavigatorObserver {
  final names = <String?>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      names.add(route.settings.name);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => HttpOverrides.global = _NoNet());

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcHomeVersionStore.instance.set(TtcHomeVersion.v3);
    TtcToolRecents.instance.resetForTest();
    TtcPartnerMode.instance.on = false;
  });
  tearDown(() => TtcPartnerMode.instance.on = false);

  const ttcMore = PvYouScreen(
    stage: LifeStage.tryingToConceive,
    bottomNav: TtcBottomNav(active: 4, v3: true),
  );

  Future<_Names> pump(
    WidgetTester tester,
    Widget child, {
    double width = 1200,
    double height = 6000,
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final obs = _Names();
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        navigatorObservers: [obs],
        builder: (c, w) => MediaQuery(
          data: MediaQuery.of(c)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: w!,
        ),
        home: child,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return obs;
  }

  Finder tile(String id) => find.byKey(ValueKey('pv_more_tile_$id'));

  Future<void> openTile(WidgetTester tester, String id) async {
    await tester.ensureVisible(tile(id));
    await tester.tap(tile(id));
    await tester.pumpAndSettle();
    expect(find.byType(PvMoreGroupScreen), findsOneWidget, reason: id);
  }

  /// The row titles on one More page: texts inside its rows only, so the
  /// page's own title is not mistaken for a row.
  Future<Set<String>> rowTexts(WidgetTester tester, String id) async {
    await pump(tester, ttcMore);
    await openTile(tester, id);
    return {
      for (final e in find
          .descendant(
              of: find.byType(PvYouRow), matching: find.byType(Text))
          .evaluate())
        if ((e.widget as Text).data != null) (e.widget as Text).data!,
    };
  }

  /// The More tab (2026-09-29), with the bar.
  const newMore = TtcMoreTab(bottomNav: TtcBottomNav(active: 4, v3: true));

  /// Every row name and link on More: texts inside its rows and links, so
  /// the page title and the section headings are not mistaken for rows.
  Set<String> moreTexts(WidgetTester tester) {
    final scopes = find.byWidgetPredicate((w) {
      final k = w.key;
      return k is ValueKey<String> &&
          (k.value.startsWith('ttc_more_row_') ||
              k.value.startsWith('ttc_more_link_') ||
              k.value == 'ttc_more_all_programmes');
    });
    return {
      for (final e in find
          .descendant(of: scopes, matching: find.byType(Text))
          .evaluate())
        if ((e.widget as Text).data != null) (e.widget as Text).data!,
    };
  }

  /// Every row and link on More, as (key, label).
  List<(String, String)> moreTargets() => [
        for (final sct in ttcMoreSections(partner: false))
          for (final r in sct.rows) ('ttc_more_row_${r.id}', r.title),
        ('ttc_more_link_experts', kTtcMoreSeeAllConsults),
        ('ttc_more_all_programmes', kTtcMoreAllProgrammes),
      ];

  List<TtcTool> toolsFor({required bool him}) => [
        for (final g in ttcToolGroupsFor(him: him)) ...g.tools,
      ];

  // ===========================================================================
  group('1. every Tools row is a tool', () {
    for (final him in [false, true]) {
      test(him ? 'his Tools' : 'her Tools', () {
        for (final t in toolsFor(him: him)) {
          expect(kTtcToolKinds.containsKey(t.id), isTrue,
              reason: '"${t.id}" is on Tools and nobody has said whether '
                  'it is a tool (kTtcToolKinds)');
          expect(kTtcToolKinds[t.id], isTrue,
              reason: '"${t.id}" is on Tools but is not a tool');
        }
      });
    }

    test('what moved is classified as not a tool, and is not on Tools', () {
      final ids = {for (final t in toolsFor(him: false)) t.id};
      for (final m in ttcMovedToMore) {
        expect(kTtcToolKinds[m.id], isFalse, reason: m.id);
        expect(ids, isNot(contains(m.id)), reason: m.id);
        expect(kTtcMovedToMoreTile[m.id], isNotNull, reason: m.id);
      }
      expect({for (final m in ttcMovedToMore) m.id},
          {'expert', 'courses', 'map'});
    });

    test('the treatment cycle came in, for both of them', () {
      expect(ttcToolById('treatment'), isNotNull);
      expect(toolsFor(him: true).map((t) => t.id), contains('treatment'));
    });

    test('the definition is written at the top of the hub', () {
      final src = File('lib/screens/ttc/ttc_tools_screen.dart')
          .readAsStringSync();
      expect(src, contains('WHAT A TOOL IS, IN ONE SENTENCE'));
    });
  });

  // ===========================================================================
  group('2 and 3. More holds what left Tools, and no tool', () {
    for (final him in [false, true]) {
      testWidgets(him ? 'his More' : 'her More', (tester) async {
        TtcPartnerMode.instance.on = him;
        await pump(tester, newMore);
        final texts = moreTexts(tester);
        // 2. Every non-tool that left Tools is on More exactly once, under
        // the words the ledger gives it.
        for (final m in ttcMovedToMore) {
          final label = kTtcFormerYouRows[m.nameEn]!.$2;
          expect(find.text(label), findsOneWidget,
              reason: '"${m.nameEn}" (as "$label") is not on More once');
          expect(texts, contains(label));
        }
        // The Tools search note names More's real section.
        final headings = {
          kTtcMoreExpertsHeading,
          kTtcMoreCoursesHeading,
          kTtcMoreJourneyHeading,
        };
        for (final m in ttcMovedToMore) {
          expect(headings, contains(kTtcMovedToMoreTile[m.id]), reason: m.id);
        }
        // 3. No tool is inside More, by her names and by his.
        final toolNames = {
          for (final t in toolsFor(him: false)) t.nameEn,
          for (final t in toolsFor(him: true))
            kTtcHisToolWords[t.id]?.$1 ?? t.nameEn,
        };
        final tools = texts.intersection(toolNames);
        expect(tools, isEmpty, reason: 'More holds tools: $tools');
      });
    }

    testWidgets('the expert link on More lands on the consults, lit More',
        (tester) async {
      await pump(tester, newMore);
      await tester.tap(find.byKey(const ValueKey('ttc_more_link_experts')));
      await tester.pumpAndSettle();
      expect(find.byType(PvLearnScreen), findsOneWidget);
      expect(ttcV3ActiveFor('ttc/consults', 0), 4);
    });

    /* Kept for revert (2026-09-29), the bento versions:
    for (final him in [false, true]) {
      testWidgets(him ? 'his More' : 'her More', (tester) async {
        TtcPartnerMode.instance.on = him;
        final pages = <String, Set<String>>{
          for (final id in _allTiles) id: await rowTexts(tester, id),
        };
        // 2. Every non-tool that left Tools is behind exactly one tile.
        for (final m in ttcMovedToMore) {
          final homes = [
            for (final e in pages.entries)
              if (e.value.contains(m.nameEn)) e.key,
          ];
          expect(homes.length, 1,
              reason: '"${m.nameEn}" is behind ${homes.length} tiles: $homes');
        }
        expect(pages['experts_and_courses'],
            containsAll(['Talk to an expert', 'Courses']));
        expect(pages['journey'], contains('Journey map'));
        // 3. No tool is inside More, by her names and by his.
        final toolNames = {
          for (final t in toolsFor(him: false)) t.nameEn,
          for (final t in toolsFor(him: true))
            kTtcHisToolWords[t.id]?.$1 ?? t.nameEn,
        };
        for (final e in pages.entries) {
          final tools = e.value.intersection(toolNames);
          expect(tools, isEmpty,
              reason: 'the "${e.key}" tile holds tools: $tools');
        }
      });
    }

    testWidgets('the expert row on More lands on the consults, lit More',
        (tester) async {
      await pump(tester, ttcMore);
      await openTile(tester, 'experts_and_courses');
      await tester.tap(find.text('Talk to an expert'));
      await tester.pumpAndSettle();
      expect(find.byType(PvLearnScreen), findsOneWidget);
      expect(ttcV3ActiveFor('ttc/consults', 0), 4);
    });
    */
  });

  // ===========================================================================
  group('4. no destination twice across the bar, Tools and More', () {
    testWidgets('by route name', (tester) async {
      final where = <String, List<String>>{};
      void add(String? route, String from) {
        if (route == null) return; // a sheet or a dialog, not a page
        (where[route] ??= []).add(from);
      }

      for (final r in _barRoutes) {
        add(r, 'bar');
      }

      // Tools: every row, hers (his is a subset of hers).
      for (final t in toolsFor(him: false)) {
        final obs = await pump(tester, const TtcToolsScreen());
        final row = find.byKey(ValueKey('ttc_tool_row_${t.id}'));
        await tester.ensureVisible(row);
        await tester.tap(row);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        tester.takeException();
        add(obs.names.length > 1 ? obs.names.last : null, 'Tools › ${t.id}');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 2));
        tester.takeException();
      }

      // More (2026-09-29): every row and link on the More tab.
      for (final (key, label) in moreTargets()) {
        if (key == 'ttc_more_row_addresses') continue; // a sheet
        final obs = await pump(tester, newMore);
        final before = obs.names.length;
        final row = find.byKey(ValueKey(key));
        await tester.ensureVisible(row);
        await tester.tap(row);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        tester.takeException();
        add(obs.names.length > before ? obs.names.last : null,
            'More › $label');
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 2));
        tester.takeException();
      }

      /* Kept for revert (2026-09-29): the bento's pages.
      // More: every row on the tiles that lead to her things.
      for (final id in _destinationTiles) {
        await pump(tester, ttcMore);
        await openTile(tester, id);
        final n = find
            .descendant(
                of: find.byType(PvMoreGroupScreen),
                matching: find.byType(PvYouRow))
            .evaluate()
            .length;
        for (var i = 0; i < n; i++) {
          final obs = await pump(tester, ttcMore);
          await openTile(tester, id);
          final before = obs.names.length;
          final row = find
              .descendant(
                  of: find.byType(PvMoreGroupScreen),
                  matching: find.byType(PvYouRow))
              .at(i);
          final label = (tester.widget<PvYouRow>(row)).title;
          await tester.ensureVisible(row);
          await tester.tap(row);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          tester.takeException();
          add(obs.names.length > before ? obs.names.last : null,
              'More › $id › $label');
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 2));
          tester.takeException();
        }
      }
      */

      final twice = {
        for (final e in where.entries)
          if (e.value.length > 1 && !_allowedTwice.containsKey(e.key))
            e.key: e.value,
      };
      // Every Tools row really opened a page of its own (none a sheet).
      final toolsSeen = [
        for (final v in where.values)
          for (final f in v)
            if (f.startsWith('Tools › ')) f,
      ];
      expect(toolsSeen.length, toolsFor(him: false).length);
      expect(twice, isEmpty, reason: 'one destination, two ways in: $twice');
      // The moved rows really were tapped. Kept for revert (the bento):
      //   ['More › experts_and_courses › Talk to an expert'],
      //   ['More › experts_and_courses › Courses'],
      //   ['More › journey › Journey map']
      expect(where['ttc/consults'], ['More › $kTtcMoreSeeAllConsults']);
      expect(where['ttc/courses'], ['More › Preconception garbh sanskar']);
      expect(where['ttc/map'], ['More › Journey map']);
    });
  });

  // ===========================================================================
  group('5. it holds', () {
    for (final (w, scale) in [(360.0, 1.0), (360.0, 1.5)]) {
      for (final him in [false, true]) {
        testWidgets(
            '${him ? 'his' : 'her'} Tools at ${w.toInt()}dp, ${scale}x',
            (tester) async {
          TtcPartnerMode.instance.on = him;
          await pump(tester, const TtcToolsScreen(),
              width: w, height: 5000, textScale: scale);
          expect(tester.takeException(), isNull);
          // A search for a moved row says where it went, and holds too.
          await tester.enterText(find.byType(TextField), 'expert');
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull);
          expect(
              find.text(ttcMovedNote(ttcMovedToMoreById('expert')!)),
              findsOneWidget);
        });
      }
      // 2026-09-29: the More tab, hers and his.
      testWidgets('More, hers and his, at ${w.toInt()}dp, ${scale}x',
          (tester) async {
        for (final him in [false, true]) {
          TtcPartnerMode.instance.on = him;
          await pump(tester, newMore,
              width: w, height: 5000, textScale: scale);
          expect(tester.takeException(), isNull, reason: him ? 'his' : 'hers');
        }
      });
      /* Kept for revert (2026-09-29), the bento:
      testWidgets('More and its changed tiles at ${w.toInt()}dp, ${scale}x',
          (tester) async {
        await pump(tester, ttcMore, width: w, height: 5000, textScale: scale);
        expect(tester.takeException(), isNull);
        for (final id in ['your_health', 'journey', 'experts_and_courses',
            'bookings_and_orders']) {
          await openTile(tester, id);
          expect(tester.takeException(), isNull, reason: id);
          await tester.tap(find.byIcon(Icons.arrow_back_rounded).last);
          await tester.pumpAndSettle();
        }
      });
      */
    }
  });
}
