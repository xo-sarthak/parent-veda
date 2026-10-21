// =============================================================================
//  PpTabHost: the five parenting tabs in one route (2026-10-21)
// -----------------------------------------------------------------------------
//  The user: the parenting tab switch "just looks very jittery", and it should
//  be the one effect the other stages use. Each tab used to be a pushed route,
//  so a tap ran popUntil + push: two transitions, the page sliding with its own
//  copy of the bar, and the tab rebuilt from scratch, losing its scroll.
//
//  Now, as in TTC (ttc_tab_host.dart): every tab lives in this one route, the
//  switch is the shared 300ms fade-through (PvTabFadeStack), and ONE bar sits
//  over the pages. Each page's own PpBottomNav stands down inside PpTabScope.
//
//  The host sits inside PpHomeScreen, so the route every caller pushes is
//  still 'pp/my_child': the Ask Veda button and the toast read that name.
//  The cost: a tab stays in memory after its first visit (a few screens).
// =============================================================================

import 'package:flutter/material.dart';

import '../../widgets/pv_tab_fade.dart';
import 'pp_brain_tab.dart';
import 'pp_common.dart';
import 'pp_more_screen.dart';
import 'products_discovery_screen.dart';
import 'tools_hub_screen.dart';

class PpTabHost extends StatefulWidget {
  const PpTabHost({super.key, required this.home});

  /// Tab 0, the parenting home (V3, or the classic one).
  final Widget home;

  @override
  State<PpTabHost> createState() => _PpTabHostState();
}

class _PpTabHostState extends State<PpTabHost> {
  /// One scroll controller per tab: five pages in one route would otherwise
  /// share the route's PrimaryScrollController, and the first scroll-to-top
  /// would assert (the TTC host's finding).
  final List<ScrollController> _scrolls = List.generate(PpTab.values.length, (_) => ScrollController());

  @override
  void initState() {
    super.initState();
    PpTabs.instance.attach();
    PpTabs.instance.addListener(_onSelect);
  }

  @override
  void dispose() {
    PpTabs.instance.removeListener(_onSelect);
    PpTabs.instance.detach();
    for (final c in _scrolls) {
      c.dispose();
    }
    super.dispose();
  }

  void _onSelect() {
    if (mounted) setState(() {});
  }

  Widget _page(PpTab t) => switch (t) {
        PpTab.home => widget.home,
        PpTab.products => const ProductsDiscoveryScreen(),
        PpTab.tools => const ToolsHubScreen(),
        PpTab.brain => const PpBrainTabScreen(),
        PpTab.more => const PpMoreScreen(),
      };

  @override
  Widget build(BuildContext context) {
    final tab = PpTabs.instance.tab;
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;
    return PopScope(
      // Back on another tab goes Home, as it did when back popped the tab's
      // route; back on Home leaves as before.
      canPop: tab == PpTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && tab != PpTab.home) PpTabs.instance.select(PpTab.home);
      },
      child: ColoredBox(
        color: Colors.white,
        child: Stack(fit: StackFit.expand, children: [
          PvTabFadeStack(
            index: PpTab.values.indexOf(tab),
            count: PpTab.values.length,
            keyPrefix: 'pp_tab',
            builder: (context, i) => _page(PpTab.values[i]),
            wrap: (i, page) => PrimaryScrollController(
              controller: _scrolls[i],
              child: PpTabScope(ownsBar: false, child: page),
            ),
          ),
          // ONE BAR, the geometry every parenting tab already drew it at.
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Offstage(
              offstage: keyboardUp,
              child: PpTabScope(ownsBar: true, child: PpBottomNav(key: const ValueKey('pp_tab_host_bar'), active: tab)),
            ),
          ),
        ]),
      ),
    );
  }
}
