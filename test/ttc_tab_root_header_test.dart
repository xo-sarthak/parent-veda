// =============================================================================
//  TTC: the four tab roots' titles sit at one y, one size (2026-09-29, build 19)
// -----------------------------------------------------------------------------
//  The user: "If you click on Tools from the bottom navigation, you can see
//  the header of Tools aligned at the very top. But when you see the same
//  thing for Learn, it's not aligned at that very top." Measured before the
//  fix, in the tab host at 360x800 with a 24dp status bar, the title's top
//  was Learn 40.5, Tools 36, More 38, and Products had no title at all.
//  Learn's place was chosen as the spec ("I would say the Learn header is the
//  optimal"); lib/screens/ttc/ttc_tab_root_header.dart has the mechanism.
//
//  What this file holds:
//    1. In the host, Learn, Products, Tools and More draw their title with
//       the same top, the same height and the same style, at 1x and 1.5x
//       text, and at 1x the top is the safe area + 12 + (42 - 33) / 2.
//    2. The intro line (where there is one) starts at one y on every tab,
//       and the first content (a search) sits 14 under what is above it.
//    3. A button beside the title never moves it: none, one or three.
//    4. No overflow from the header at 360dp and 1.5x text.
//    5. Wiring gate: each of the four screens draws `TtcTabRootHeader`.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/doors/pv_live_search.dart';
import 'package:parentveda/screens/products/pv_hero_band.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart';
import 'package:parentveda/screens/products/pv_store_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_learn_screen.dart';
import 'package:parentveda/screens/ttc/ttc_more_tab.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tab_host.dart';
import 'package:parentveda/screens/ttc/ttc_tab_root_header.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/widgets/global_ask_fab.dart';

/// Tab index → the screen that tab shows.
const Map<int, Type> _screens = {
  1: TtcLearnScreen,
  2: PvStoreScreen,
  3: TtcToolsScreen,
  4: TtcMoreTab,
};

const double _statusBar = 24;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'ttc_intro_seen_v1': true});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcPartnerMode.instance.on = false;
    TtcHomeVersionStore.instance.set(TtcHomeVersion.v3);
    TtcLearnRecents.instance.resetForTest();
    TtcToolRecents.instance.resetForTest();
    TtcTabs.instance.resetForTest();
  });

  /// A 360x800 phone, three pixels to the dp, a 24dp status bar.
  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding =
        const FakeViewPadding(top: _statusBar * 3, bottom: 72);
    tester.view.viewPadding =
        const FakeViewPadding(top: _statusBar * 3, bottom: 72);
    addTearDown(tester.view.reset);
  }

  Future<void> pumpHost(WidgetTester tester, double scale) async {
    await tester.pumpWidget(MaterialApp(
      key: UniqueKey(),
      navigatorObservers: [fabRouteObserver],
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        settings: const RouteSettings(name: ttcHomeRoute),
        builder: (_) => const TtcTabHost(today: SizedBox()),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> show(WidgetTester tester, int tab) async {
    TtcTabs.instance.select(tab);
    await tester.pumpAndSettle();
  }

  Finder inTab(int tab, Finder f) =>
      find.descendant(of: find.byType(_screens[tab]!), matching: f);

  Finder titleOf(int tab) => inTab(tab, find.byKey(kTtcTabRootTitleKey));

  /// Runs [body] and returns every Flutter error it raised, without failing
  /// on them: the caller decides which are the header's.
  Future<List<FlutterErrorDetails>> collectErrors(
      Future<void> Function() body) async {
    final errors = <FlutterErrorDetails>[];
    final old = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await body();
    } finally {
      FlutterError.onError = old;
    }
    return errors;
  }

  // ===========================================================================
  for (final scale in [1.0, 1.5]) {
    testWidgets(
        'at ${scale}x the four titles share one top, height and style',
        (tester) async {
      phone(tester);
      final rects = <int, Rect>{};
      final styles = <int, TextStyle?>{};
      final texts = <int, String?>{};
      final errors = await collectErrors(() async {
        await pumpHost(tester, scale);
        for (final tab in _screens.keys) {
          await show(tester, tab);
          expect(titleOf(tab), findsOneWidget,
              reason: 'tab $tab draws no tab-root title');
          rects[tab] = tester.getRect(titleOf(tab));
          final t = tester.widget<Text>(titleOf(tab));
          styles[tab] = t.style;
          texts[tab] = t.data;
        }
      });
      // Other parts of a page (a rail tile, a section head) may still
      // overflow at 1.5x; those are the pages' own and written down in the
      // report. The header must not be one of them.
      final mine = errors
          .where((e) => e.toString().contains('ttc_tab_root_header.dart'))
          .toList();
      expect(mine, isEmpty, reason: 'the tab-root header overflowed');

      expect(texts, {1: 'Learn', 2: 'Products', 3: 'Tools', 4: 'More'});
      final learn = rects[1]!;
      for (final e in rects.entries) {
        expect(e.value.top, learn.top,
            reason: 'tab ${e.key} title top ${e.value.top} vs Learn ${learn.top}');
        // ⚠️ AND ONE x (2026-09-29): More and Products sat on a 20dp gutter
        // while Learn and Tools sat on the stage's 18, so the title jumped
        // 2dp sideways between tabs.
        expect(e.value.left, learn.left,
            reason: 'tab ${e.key} title x ${e.value.left} vs Learn ${learn.left}');
        expect(e.value.left, kTtcTabRootGutter);
        expect(e.value.height, learn.height,
            reason: 'tab ${e.key} title is a different height');
        final s = styles[e.key]!;
        final l = styles[1]!;
        expect(s.fontSize, 30);
        expect(s.fontSize, l.fontSize);
        expect(s.fontWeight, l.fontWeight);
        expect(s.fontFamily, l.fontFamily);
        expect(s.height, l.height);
        expect(s.color, l.color);
      }
      if (scale == 1.0) {
        // Learn's place, the spec: the safe area, 12, then the 33dp title
        // centred in a 42dp row.
        expect(learn.top, _statusBar + kTtcTabRootTopInset + (42 - 33) / 2);
        expect(learn.height, 33);
      }
    });
  }

  testWidgets('the intro starts at one y, and the search sits 14 under',
      (tester) async {
    phone(tester);
    await pumpHost(tester, 1);
    final introTops = <int, double>{};
    // Products gained its intro line on 2026-09-29 (the store pass), so its
    // search now sits 14 under the intro like Learn's and Tools', not 14
    // under the title row. Kept for revert: no entry for tab 2.
    const intros = {
      1: 'Everything we', // Learn
      2: 'What to buy while', // Products
      3: 'Tools to track', // Tools
      4: 'Experts, courses', // More
    };
    for (final tab in _screens.keys) {
      await show(tester, tab);
      final title = tester.getRect(titleOf(tab));
      final rowBottom = title.center.dy + kTtcTabRootRowHeight / 2;
      if (intros[tab] != null) {
        final intro =
            inTab(tab, find.textContaining(intros[tab]!));
        final r = tester.getRect(intro.first);
        introTops[tab] = r.top;
        expect(r.top, rowBottom + kTtcTabRootIntroGap,
            reason: 'tab $tab intro is not 6 under the title row');
        final t = tester.widget<Text>(intro.first);
        expect(t.style?.fontSize, 14);
        expect(t.style?.color, pvStorePalette.ink2);
      }
      // The first content: Learn's and Tools' live search, Products' pill.
      final search = tab == 2
          ? inTab(tab, find.byType(PvSearchPill))
          : inTab(tab, find.byType(PvLiveSearchField));
      if (tab == 4) {
        expect(search, findsNothing, reason: 'More has no search');
        continue;
      }
      final above = intros[tab] != null
          ? tester
              .getRect(inTab(
                  tab, find.textContaining(intros[tab]!))
                  .first)
              .bottom
          : rowBottom;
      expect(tester.getRect(search.first).top, above + kTtcTabRootBelowGap,
          reason: 'tab $tab search is not 14 under what is above it');
    }
    expect(introTops.values.toSet().length, 1,
        reason: 'the intro lines start at different heights: $introTops');
  });

  testWidgets('More and Products: the content starts on the title\'s edge',
      (tester) async {
    // The gutter moved with the title (2026-09-29): More's section headings
    // and the storefront's hero band start at the same x as the title.
    phone(tester);
    await pumpHost(tester, 1);
    await show(tester, 4);
    final moreTitle = tester.getRect(titleOf(4)).left;
    final section = inTab(
        4,
        find.byWidgetPredicate((w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('ttc_more_section_')));
    expect(section, findsWidgets);
    final heading = find.descendant(
        of: section.first, matching: find.byType(Text));
    expect(tester.getRect(heading.first).left, moreTitle,
        reason: "More's first heading is not on the title's edge");

    await show(tester, 2);
    final productsTitle = tester.getRect(titleOf(2)).left;
    final pill = inTab(2, find.byType(PvSearchPill));
    expect(tester.getRect(pill.first).left, productsTitle,
        reason: "the storefront's search is not on the title's edge");
    final band = inTab(2, find.byType(PvHeroBand));
    if (band.evaluate().isNotEmpty) {
      expect(tester.getRect(band.first).left, productsTitle,
          reason: "the storefront's hero band is not on the title's edge");
    }
  });

  // ===========================================================================
  testWidgets('a button beside the title never moves it', (tester) async {
    phone(tester);
    Widget circle() => const SizedBox.square(dimension: kTtcTabRootRowHeight);
    final tops = <int, double>{};
    for (final n in [0, 1, 3]) {
      await tester.pumpWidget(MaterialApp(
        key: UniqueKey(),
        home: Scaffold(
          body: TtcTabRootHeader(
            title: 'Products',
            trailing: [for (var i = 0; i < n; i++) circle()],
          ),
        ),
      ));
      tops[n] = tester.getRect(find.byKey(kTtcTabRootTitleKey)).top;
    }
    expect(tops.values.toSet().length, 1, reason: '$tops');
  });

  testWidgets('the header alone does not overflow at 360dp and 1.5x',
      (tester) async {
    phone(tester);
    await tester.pumpWidget(MaterialApp(
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.5)),
        child: child!,
      ),
      home: Scaffold(
        body: ListView(children: [
          TtcTabRootHeader(
            title: 'Products',
            gutter: 20,
            trailing: [
              for (var i = 0; i < 3; i++)
                PvRoundIcon(
                    icon: Icons.favorite_border_rounded,
                    onTap: () {},
                    badge: 12,
                    size: kTtcTabRootRowHeight),
            ],
            intro: Text(
                'Experts, courses and groups, and what you have booked. Your '
                'profile and settings are behind your picture on Today.',
                style: ttcTabRootIntroStyle()),
            below: const PvSearchPill(child: Text('Search')),
          ),
        ]),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  // ===========================================================================
  testWidgets('wiring gate: each tab root draws the shared header',
      (tester) async {
    phone(tester);
    await pumpHost(tester, 1);
    for (final tab in _screens.keys) {
      await show(tester, tab);
      expect(inTab(tab, find.byType(TtcTabRootHeader)), findsOneWidget,
          reason: '${_screens[tab]} does not use TtcTabRootHeader');
    }
  });

  testWidgets('the other storefronts keep their own header', (tester) async {
    phone(tester);
    await tester.pumpWidget(MaterialApp(
      home: const PvStoreScreen(
          chrome: PvStoreChrome.none, initialStage: LifeStage.pregnancy),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(TtcTabRootHeader), findsNothing);
    expect(find.byType(PvSearchPill), findsOneWidget);
  });
}
