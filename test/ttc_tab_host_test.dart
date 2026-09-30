// =============================================================================
//  TTC V3: one bar, in one place, and a tab switch that is not a push
//  (2026-09-28, build 17)
// -----------------------------------------------------------------------------
//  The user: Today to Products, Tools or More played "something overlapping"
//  and jittery, while Today to Learn was smooth; and on Products the bar sat
//  lower than on Today and Tools. Both came from every tab being a pushed
//  route with its own copy of the bar (lib/screens/ttc/ttc_tab_host.dart has
//  the mechanism). What this file holds:
//
//    1. ONE BAR, ONE RECT. The bar's rectangle is identical on all five tabs,
//       with a real system inset, and exactly one bar is on screen.
//    2. NO ROUTE. A tab switch pushes nothing: the Navigator's history is the
//       home route alone before and after five switches, and mid-switch both
//       tabs are on screen (the fade through), not two routes.
//    3. THE FAB STILL KNOWS WHERE IT IS. The 'ttc/today' route stays on the
//       stack, so the Ask Veda FAB opens the TTC Ask Veda; the tab's name is
//       `TtcTabs.routeName`, the same strings the routes carried.
//    4. THE STANDALONE PUSHES MATCH TOO. Products pushed on its own sits
//       where Tools pushed on its own sits (the SafeArea it lacked).
//    5. Back on a tab goes to Today, the keyboard hides the bar, the lit tab
//       scrolls its page to the top, and nothing overflows at 360dp.
//    6. THE WIRING GATE: the real TTC home hosts the tabs.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/products/pv_store_chrome.dart';
import 'package:parentveda/screens/products/pv_store_screen.dart';
// Kept for revert (2026-09-29): More was the You screen.
// import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_learn_screen.dart';
import 'package:parentveda/screens/ttc/ttc_more_tab.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tab_host.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/widgets/global_ask_fab.dart';
import 'package:parentveda/widgets/pv_nav_bar.dart';

/// Every route the Navigator pushes, by name.
class _Pushes extends NavigatorObserver {
  final List<String?> names = [];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      names.add(route.settings.name);
}

/// Stands in for her home: a page that carries its own copy of the bar, as
/// the real V3 home does, so the test sees that copy stand down.
class _Today extends StatelessWidget {
  const _Today();
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: ttcBg,
        body: Stack(children: [
          ListView(children: [
            for (var i = 0; i < 40; i++)
              SizedBox(height: 80, child: Text('today row $i')),
          ]),
          const Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: SafeArea(
                top: false, child: TtcBottomNav(active: 0, v3: true)),
          ),
        ]),
      );
}

const _tabs = ['Today', 'Learn', 'Products', 'Tools', 'More'];

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

  /// A phone: [width] dp wide, three pixels to the dp, with a gesture-nav
  /// inset of 24dp at the foot, which is what separated the two bars.
  void phone(WidgetTester tester, {double width = 392, double height = 860}) {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(top: 72, bottom: 72);
    tester.view.viewPadding = const FakeViewPadding(top: 72, bottom: 72);
    addTearDown(tester.view.reset);
  }

  /// The host on the home route, named as the app names it.
  Future<_Pushes> pumpHost(WidgetTester tester,
      {Widget today = const _Today()}) async {
    final pushes = _Pushes();
    await tester.pumpWidget(MaterialApp(
      key: UniqueKey(),
      navigatorObservers: [pushes, fabRouteObserver],
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        settings: const RouteSettings(name: ttcHomeRoute),
        builder: (_) => TtcTabHost(today: today),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return pushes;
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.descendant(
        of: find.byKey(kTtcTabBarKey), matching: find.text(label)));
    await tester.pumpAndSettle();
  }

  int lit(WidgetTester tester) =>
      tester.widget<PvNavBar>(find.byType(PvNavBar)).activeIndex;

  // ===========================================================================
  testWidgets('one bar, at one rect, on all five tabs', (tester) async {
    phone(tester);
    await pumpHost(tester);
    final rects = <String, Rect>{};
    for (final t in [..._tabs.skip(1), 'Today']) {
      await tapTab(tester, t);
      expect(find.byType(PvNavBar), findsOneWidget,
          reason: '$t drew a second bar');
      expect(lit(tester), _tabs.indexOf(t), reason: '$t lit the wrong tab');
      rects[t] = tester.getRect(find.byType(PvNavBar));
      expect(tester.takeException(), isNull);
    }
    final first = rects.values.first;
    for (final e in rects.entries) {
      expect(e.value, first, reason: 'the bar moved on ${e.key}');
    }
    // Above the gesture inset, 14dp clear of it, as Today always was.
    expect(first.bottom, closeTo(860 - 24 - 14, 0.01));
  });

  testWidgets('each tab shows its own screen', (tester) async {
    phone(tester, height: 1600);
    await pumpHost(tester);
    const screens = {
      'Learn': TtcLearnScreen,
      'Products': PvStoreScreen,
      'Tools': TtcToolsScreen,
      // 2026-09-29: More is its own screen of offerings; the profile is the
      // avatar's (test/ttc_more_profile_test.dart). Kept for revert:
      //   'More': PvYouScreen,
      'More': TtcMoreTab,
    };
    for (final e in screens.entries) {
      await tapTab(tester, e.key);
      expect(find.byType(e.value), findsOneWidget,
          reason: '${e.key} did not show ${e.value}');
      expect(find.text('today row 0'), findsNothing,
          reason: 'Today stayed on screen under ${e.key}');
    }
    await tapTab(tester, 'Today');
    expect(find.text('today row 0'), findsOneWidget);
  });

  // ===========================================================================
  testWidgets('a tab switch pushes no route; it fades through in place',
      (tester) async {
    phone(tester);
    final pushes = await pumpHost(tester);
    expect(pushes.names, [ttcHomeRoute]);

    // Mid-switch: the two tabs share one route, one fading out, one in.
    await tester.tap(find.descendant(
        of: find.byKey(kTtcTabBarKey), matching: find.text('Products')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('today row 0'), findsOneWidget,
        reason: 'Today should still be fading out');
    expect(find.byType(PvStoreScreen), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('today row 0'), findsNothing);

    for (final t in ['Tools', 'More', 'Learn', 'Today', 'Products']) {
      await tapTab(tester, t);
    }
    expect(pushes.names, [ttcHomeRoute],
        reason: 'a tab switch must not push a route');
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    expect(nav.canPop(), isFalse, reason: 'the home route is alone');
  });

  testWidgets('a page opened from a tab is still a route', (tester) async {
    phone(tester, height: 1600);
    final pushes = await pumpHost(tester);
    await tapTab(tester, 'Learn');
    await tester.tap(find.text(ttcLearnStartHere().first.title.en).first);
    await tester.pumpAndSettle();
    expect(pushes.names.length, 2,
        reason: 'a read opened from a tab keeps its page transition');
    expect(find.byType(PvReaderScreen), findsOneWidget);
  });

  // ===========================================================================
  testWidgets('the FAB still detects the stage, and the tab has its name',
      (tester) async {
    phone(tester);
    await pumpHost(tester);
    for (var i = 0; i < _tabs.length; i++) {
      await tapTab(tester, _tabs[(i + 1) % _tabs.length]);
      expect(FabState.instance.inTtc, isTrue,
          reason: 'the FAB would open the pregnancy Ask Veda');
      expect(TtcTabs.instance.routeName,
          kTtcTabRoutes[(i + 1) % _tabs.length]);
    }
    // The names are the ones the routes carried, so the lit-tab map agrees.
    for (var i = 0; i < kTtcTabRoutes.length; i++) {
      expect(ttcV3ActiveFor(kTtcTabRoutes[i], 0), i);
    }
  });

  // ===========================================================================
  testWidgets('standalone, Products sits where Tools sits', (tester) async {
    phone(tester, height: 1600);
    await tester.pumpWidget(MaterialApp(
        key: UniqueKey(),
        home: const PvStoreScreen(
            chrome: PvStoreChrome.ttc,
            initialStage: LifeStage.tryingToConceive)));
    await tester.pump(const Duration(milliseconds: 300));
    final store = tester.getRect(find.byType(PvNavBar));
    await tester.pumpWidget(
        MaterialApp(key: UniqueKey(), home: const TtcToolsScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    final tools = tester.getRect(find.byType(PvNavBar));
    expect(store, tools, reason: 'Products drew its bar somewhere else');
  });

  // ===========================================================================
  testWidgets('back on a tab goes to Today, not out of the stage',
      (tester) async {
    phone(tester);
    await pumpHost(tester);
    await tapTab(tester, 'Tools');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(TtcTabs.instance.index, 0);
    expect(find.text('today row 0'), findsOneWidget);
  });

  testWidgets('the keyboard hides the bar, and it comes back', (tester) async {
    phone(tester);
    await pumpHost(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    await tester.pump();
    expect(find.byType(PvNavBar), findsNothing);
    tester.view.resetViewInsets();
    await tester.pump();
    expect(find.byType(PvNavBar), findsOneWidget);
  });

  testWidgets('the lit tab scrolls its own page to the top', (tester) async {
    phone(tester);
    await pumpHost(tester);
    await tapTab(tester, 'Learn');
    final list = find.descendant(
        of: find.byType(TtcLearnScreen), matching: find.byType(Scrollable));
    await tester.drag(list.first, const Offset(0, -900));
    await tester.pumpAndSettle();
    final pos = tester.state<ScrollableState>(list.first).position;
    expect(pos.pixels, greaterThan(0));
    await tapTab(tester, 'Learn');
    expect(pos.pixels, 0);
  });

  testWidgets('nothing overflows at 360dp on any tab', (tester) async {
    phone(tester, width: 360);
    await pumpHost(tester);
    for (final t in [..._tabs.skip(1), 'Today']) {
      await tapTab(tester, t);
      final ex = tester.takeException();
      // ⚠️ PRODUCTS IS EXCUSED, AND ONLY FOR A KNOWN CAUSE: its hero band
      // (pv_hero_band.dart, the Rows at lines ~300 and ~353) overflows at
      // 360dp under the test font whether or not it is inside the host;
      // pushed on its own it does the same. It is the store's, not the
      // host's, and is written down for the store's owner. The bar and the
      // host must be clean on every tab, Products included, so nothing else
      // is excused.
      // The hero band's two Rows were made Flexible on 2026-09-28, so
      // Products is held to the same rule now. Kept for revert:
      // if (t == 'Products') continue;
      expect(ex, isNull, reason: '$t overflowed');
    }
  });

  // ===========================================================================
  testWidgets('the real TTC home hosts the tabs (wiring gate)',
      (tester) async {
    phone(tester, height: 1600);
    final pushes = _Pushes();
    await tester.pumpWidget(MaterialApp(
      key: UniqueKey(),
      navigatorObservers: [pushes],
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        settings: const RouteSettings(name: ttcHomeRoute),
        builder: (_) => const TtcHomeScreen(),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TtcTabHost), findsOneWidget);
    expect(find.byType(PvNavBar), findsOneWidget,
        reason: 'the home drew its own bar over the host\'s');
    await tapTab(tester, 'Products');
    expect(find.byType(PvStoreScreen), findsOneWidget);
    expect(pushes.names, [ttcHomeRoute]);
  });
}
