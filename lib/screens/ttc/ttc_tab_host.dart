// =============================================================================
//  TtcTabHost: the five V3 tabs in one place, under ONE bar (2026-09-28)
// -----------------------------------------------------------------------------
//  The user, on build 17: Today to Learn is a smooth, basic motion, but Today
//  to Products, Tools or More plays "something overlapping" that is jittery;
//  and on Products the bar sits lower than on Today and Tools.
//
//  ⚠️ THE MECHANISM, because both bugs had one root.
//
//  Every tab was its own PUSHED ROUTE (`openTtcTabV3` popped to Today, then
//  `Navigator.push(MaterialPageRoute(...))`), and every tab screen drew its
//  OWN COPY of the bar in its own Stack. So a tab switch was a page
//  transition: on Android, fade-forwards (450ms; the new page slides in 25%
//  from the right and fades in over the first three quarters, the old page
//  slides 25% left and fades out). For those 450ms two whole pages are on
//  screen, each with its own header and its own bar, sliding in opposite
//  directions: the "overlap". Leaving a tab for another tab was worse, a pop
//  and a push at once, two transitions running over each other.
//
//  How loud the overlap was depended on the tab:
//    · Products drew its bar at a different place (`PvStoreNav`: bottom 18,
//      left 16, and NO SafeArea, where every other tab used bottom 14 inside
//      a SafeArea). With gesture navigation the SafeArea adds ~24dp, so the
//      Products bar sat lower, and mid-transition two bars at two heights
//      crossed each other. The second bug is that same line of code.
//    · Products, Tools and More are the heavy first builds (a storefront with
//      network photos, a hub listening to ten stores, the bento), so the
//      first frames of their transition were the ones that dropped.
//    · Going back to Today was a POP, which only fades a page away over a
//      page that is already built; that is why "anything to home" was fine.
//
//  ⚠️ THE FIX: a tab switch is not navigation, so it no longer uses the
//  Navigator. The home route ('ttc/today') hosts all five tabs; switching
//  keeps the route stack as it is and plays Material 3's FADE THROUGH (the
//  motion the guidance gives bottom-navigation destinations: the old tab fades
//  out in the first 30%, the new one fades in and settles from 97% scale over
//  the rest; no slide). The bar is ONE widget owned here, at one position, and
//  never moves. Screens pushed FROM a tab (a tool, a read, a product) are still
//  routes and keep their normal page transition.
//    https://m3.material.io/styles/motion/transitions/transition-patterns
//    (fade through: "UI elements that do not have a strong relationship to
//    each other ... tapping destinations in a bottom navigation bar")
//
//  ⚠️ WHAT THE ROUTE NAMES GAVE, KEPT. Two things read the tab's route name:
//    · the lit tab (`ttcV3ActiveFor`), which now reads `TtcTabScope`'s name
//      first and the route's second, so 'ttc/products' still lights Products;
//    · the Ask Veda FAB, which reads the STACK for 'ttc/today' to know it is
//      in this stage. That route is still there (it is the host), so the FAB
//      still opens the TTC Ask Veda. The tab she is on is `TtcTabs.routeName`.
//
//  ⚠️ THE PER-SCREEN BARS ARE NOT DELETED, THEY STAND DOWN. The same screens
//  are still pushed on their own elsewhere (Classic's Tools tab, the surface
//  router's 'ttc_shop' / 'ttc_tools' / 'ttc_learn', `openTtcShop`), where they
//  need their bar. So `TtcBottomNav` draws nothing inside a tab of this host,
//  and only the host's own bar (`ownsBar`) draws. Commenting them out would
//  have left those pushes with no way home.
//
//  Trade-offs, named:
//    · A tab keeps its state (scroll, a half-typed search) while she is on
//      another tab, as Instagram, Airbnb and Material's own guidance do. The
//      cost is memory: up to five pages alive at once. Tabs are built the
//      first time they are opened, not at launch, so a woman who never opens
//      Products never pays for it.
//    · System back on a tab other than Today goes to Today (Android's rule
//      for the start destination) instead of leaving the stage; before, back
//      popped the tab's route, which also landed on Today, so nothing she
//      knows changes.
//
//  Hide-on-scroll was considered and NOT built; see `TtcTabHost` below.
// =============================================================================

import 'package:flutter/material.dart';

// Kept for revert (2026-09-29, More is its own screen, not the You screen):
// import '../../services/father_preview.dart';
// import '../../services/life_stage_store.dart' show LifeStage;
// import '../profile/pv_you_screen.dart' show PvYouScreen;
import 'ttc_common.dart';
import 'ttc_learn_screen.dart';
import 'ttc_more_tab.dart' show TtcMoreTab;
import 'ttc_shop_v3.dart' show TtcShopScreen;
import 'ttc_strings.dart' show TtcPartnerMode;
import 'ttc_tools_screen.dart';

/// Each tab's name, in the bar's order. The same strings the pushed routes
/// carried, so every map keyed on them (the lit tab, the tests) still reads.
const List<String> kTtcTabRoutes = [
  ttcHomeRoute, // Today
  kTtcLearnRoute, // Learn
  'ttc/products', // Products
  'ttc/tools', // Tools
  kTtcYouRoute, // More (the route kept its old name; see kTtcMoreRoute)
];

/// How long one tab switch takes. Material 3's fade through is 300ms.
const Duration kTtcTabSwitch = Duration(milliseconds: 300);

/// The host's bar, for tests that measure it.
const Key kTtcTabBarKey = ValueKey('ttc_tab_host_bar');

/// Which V3 tab is showing. A singleton store, the codebase's shape for
/// shared state: the bar writes it, the host listens.
class TtcTabs extends ChangeNotifier {
  TtcTabs._();
  static final TtcTabs instance = TtcTabs._();

  int _index = 0;
  int _hosts = 0;

  /// 0 Today · 1 Learn · 2 Products · 3 Tools · 4 More.
  int get index => _index;

  /// The tab's name: what `ModalRoute.settings.name` said when tabs were
  /// routes. Read this, not the route, to know which tab she is on.
  String get routeName => kTtcTabRoutes[_index];

  /// Whether a host is on the stack. `openTtcTabV3` switches in place when
  /// one is, and falls back to pushing when none is (a screen pumped on its
  /// own in a test, or Classic).
  bool get hosted => _hosts > 0;

  void select(int i) {
    if (i < 0 || i >= kTtcTabRoutes.length || i == _index) return;
    _index = i;
    notifyListeners();
  }

  // Called from initState/dispose, so no notify: nothing else is listening
  // to a host that does not exist yet.
  void _attach() {
    _hosts++;
    _index = 0;
  }

  void _detach() {
    _hosts = _hosts > 0 ? _hosts - 1 : 0;
    if (_hosts == 0) _index = 0;
  }

  @visibleForTesting
  void resetForTest() {
    _hosts = 0;
    _index = 0;
  }
}

/// Tells a widget it is inside a tab of the host, and which one.
///
/// Every tab page sits under one with `ownsBar: false`, which is how their
/// own copy of `TtcBottomNav` knows to draw nothing. The host's bar sits under
/// one with `ownsBar: true`, carrying the showing tab, which is how it lights.
class TtcTabScope extends InheritedWidget {
  const TtcTabScope({
    super.key,
    required this.index,
    required this.ownsBar,
    required super.child,
  });

  final int index;
  final bool ownsBar;

  String get routeName => kTtcTabRoutes[index];

  static TtcTabScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TtcTabScope>();

  @override
  bool updateShouldNotify(TtcTabScope old) =>
      old.index != index || old.ownsBar != ownsBar;
}

/// The V3 home route's body: Today plus the other four tabs, and one bar.
///
/// ⚠️ NO HIDE-ON-SCROLL, ON PURPOSE (checked on Mobbin, 2026-09-28). The
/// floating pill bars of content apps stay on screen mid-scroll: Ro
/// (https://mobbin.com/screens/2d8fc3d8-f848-493c-8850-aaf743067355), Substack
/// (https://mobbin.com/flows/d6e37651-3c73-4333-83cf-58c695d9620b), Oura
/// (https://mobbin.com/screens/0ffe05f5-fc89-47f9-8856-ce81d86e817a), Cosmos
/// (https://mobbin.com/screens/76b8e77b-cd77-4b8e-b20c-55eb17bd9167), Shop
/// (https://mobbin.com/screens/d3158271-a0e5-4672-bea0-44ef4aebcb1c). Material
/// offers hiding as an option of the bottom APP bar, not a default of the
/// navigation bar. And the user's complaint was motion she did not ask for;
/// a bar that slides away is more of it. Content already clears the bar
/// (`pvNavClearance`). If it is ever wanted, one
/// `NotificationListener<ScrollNotification>` around the Stack below is the
/// place.
class TtcTabHost extends StatefulWidget {
  const TtcTabHost({super.key, required this.today});

  /// Tab 0: her V3 home, or his Today when the partner side is on.
  final Widget today;

  @override
  State<TtcTabHost> createState() => _TtcTabHostState();
}

class _TtcTabHostState extends State<TtcTabHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade =
      AnimationController(vsync: this, duration: kTtcTabSwitch, value: 1)
        ..addStatusListener((s) {
          // The tab that faded out goes offstage once the fade is done.
          if (s == AnimationStatus.completed && mounted) setState(() {});
        });

  // Fade through: out in the first 30%, in (and settling from 97%) after.
  late final Animation<double> _in = CurvedAnimation(
      parent: _fade, curve: const Interval(0.3, 1, curve: Curves.easeOutCubic));
  late final Animation<double> _out = ReverseAnimation(CurvedAnimation(
      parent: _fade, curve: const Interval(0, 0.3, curve: Curves.easeIn)));
  late final Animation<double> _scale =
      Tween<double>(begin: 0.97, end: 1).animate(_in);

  /// One scroll controller per tab. ⚠️ NOT OPTIONAL: when tabs were routes,
  /// each had its route's PrimaryScrollController to itself. Five pages in one
  /// route would all attach their lists to the SAME one, and the first
  /// scroll-to-top would assert. It is also what a tap on the lit tab scrolls.
  final List<ScrollController> _scrolls =
      List.generate(kTtcTabRoutes.length, (_) => ScrollController());

  /// Tabs she has opened. A tab is built the first time, then kept.
  final Set<int> _built = {0};

  int _from = 0;
  int _to = 0;

  // Kept for revert (2026-09-29): the More tab was the You screen, and the
  // "View as" pill swapped its viewer here. More is its own screen now and
  // reads his side from TtcPartnerMode; the pill lives on the profile, which
  // is a pushed route again.
  //   /// Whether the More tab shows his view (the "View as" pill). On a
  //   /// pushed You screen the pill swapped the route; here it swaps this.
  //   bool _youAsFather = false;

  @override
  void initState() {
    super.initState();
    TtcTabs.instance._attach();
    TtcTabs.instance.addListener(_onSelect);
  }

  @override
  void dispose() {
    TtcTabs.instance.removeListener(_onSelect);
    TtcTabs.instance._detach();
    _fade.dispose();
    for (final c in _scrolls) {
      c.dispose();
    }
    super.dispose();
  }

  void _onSelect() {
    final next = TtcTabs.instance.index;
    if (next == _to || !mounted) return;
    // A field on the tab she is leaving must not keep the keyboard up.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _from = _to;
      _to = next;
      _built.add(next);
    });
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _fade.value = 1;
    } else {
      _fade.forward(from: 0);
    }
  }

  Widget _page(int i) => switch (i) {
        0 => widget.today,
        1 => const TtcLearnScreen(),
        2 => const TtcShopScreen(),
        3 => const TtcToolsScreen(),
        // ⚠️ MORE IS ITS OWN SCREEN (2026-09-29, the user: the fifth tab and
        // the avatar showed the same thing). What the app offers beyond the
        // four tabs, in headed sections (ttc_more_tab.dart); the profile and
        // its Settings are the avatar's. Its bar stands down inside the host
        // (see TtcTabScope), like every tab's. Kept for revert:
        //   _ => PvYouScreen(
        //       stage: LifeStage.tryingToConceive,
        //       father: _youAsFather,
        //       bottomNav: const TtcBottomNav(active: 4, v3: true),
        //       onSwitchViewer: () {
        //         FatherPreview.instance.on = !FatherPreview.instance.on;
        //         setState(() => _youAsFather = FatherPreview.instance.on);
        //       },
        //     ),
        _ => const TtcMoreTab(bottomNav: TtcBottomNav(active: 4, v3: true)),
      };

  Widget _tab(int i) {
    if (!_built.contains(i)) return const SizedBox.shrink();
    final active = i == _to;
    final leaving = !active && i == _from && _fade.isAnimating;
    final shown = active || leaving;
    // ⚠️ THE SAME WRAPPERS IN EVERY STATE. Adding or removing a transition
    // widget when a tab goes on or off stage would change the tree above the
    // page, and Flutter would throw the page's state away with it.
    return Offstage(
      offstage: !shown,
      child: TickerMode(
        enabled: shown,
        child: HeroMode(
          // Only the showing tab's photos may fly to a pushed page.
          enabled: active,
          child: IgnorePointer(
            ignoring: !active,
            child: ExcludeSemantics(
              excluding: !active,
              child: FadeTransition(
                opacity: active
                    ? _in
                    : leaving
                        ? _out
                        : kAlwaysCompleteAnimation,
                child: ScaleTransition(
                  scale: active ? _scale : kAlwaysCompleteAnimation,
                  child: PrimaryScrollController(
                    controller: _scrolls[i],
                    child: TtcTabScope(
                      index: i,
                      ownsBar: false,
                      child: _page(i),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The bar steps aside for the keyboard on every tab (Learn's rule L4,
    // launch sanity 2026-09-28, now one rule instead of one screen's).
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;
    return PopScope(
      // Back on another tab goes to Today, as it did when back popped the
      // tab's route; back on Today leaves as before.
      canPop: _to == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _to != 0) TtcTabs.instance.select(0);
      },
      child: ColoredBox(
        // The ground between the two halves of the fade.
        color: ttcBg,
        child: Stack(fit: StackFit.expand, children: [
          for (var i = 0; i < kTtcTabRoutes.length; i++)
            KeyedSubtree(key: ValueKey('ttc_tab_$i'), child: _tab(i)),
          // ⚠️ ONE BAR, ONE PLACE: the geometry Today and Tools always had
          // (14 from each side, 14 above the system inset).
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Offstage(
              offstage: keyboardUp,
              child: SafeArea(
                top: false,
                child: PrimaryScrollController(
                  controller: _scrolls[_to],
                  child: TtcTabScope(
                    index: _to,
                    ownsBar: true,
                    child: ListenableBuilder(
                      listenable: TtcPartnerMode.instance,
                      builder: (context, _) => TtcBottomNav(
                        key: kTtcTabBarKey,
                        active: _to,
                        v3: true,
                        // His Today drew the slate bar; now every tab of his
                        // side does, instead of slate on one and violet on four.
                        slate: TtcPartnerMode.instance.on,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
