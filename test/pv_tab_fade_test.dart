// =============================================================================
//  One tab switch for every stage (2026-10-21): the shared fade-through, and
//  the parenting tabs in one host instead of a route per tab.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_common.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tab_host.dart';
import 'package:parentveda/widgets/pv_tab_fade.dart';

class _Counter extends StatefulWidget {
  const _Counter(this.label);
  final String label;
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int n = 0;
  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => setState(() => n++),
        child: Text('${widget.label} $n'),
      );
}

class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: [
          const Center(child: Text('home page')),
          // The page's own bar, as every parenting tab draws one.
          const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: PpTab.home)),
          Positioned(
            top: 40,
            left: 0,
            child: Builder(
              builder: (context) => TextButton(
                key: const ValueKey('go_tools'),
                onPressed: () => openPpTabTo(context, PpTab.tools),
                child: const Text('tools'),
              ),
            ),
          ),
        ]),
      );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PpTabs.instance.resetForTest();
  });

  testWidgets('a tab keeps its state across a switch, and fades in', (t) async {
    var index = 0;
    late StateSetter set;
    await t.pumpWidget(MaterialApp(
      home: StatefulBuilder(builder: (context, s) {
        set = s;
        return PvTabFadeStack(index: index, count: 2, builder: (_, i) => _Counter('tab$i'));
      }),
    ));
    await t.tap(find.text('tab0 0'));
    await t.pump();
    expect(find.text('tab0 1'), findsOneWidget);

    set(() => index = 1);
    await t.pump(const Duration(milliseconds: 150));
    // Mid-switch: the new tab is fading in, not yet fully shown.
    final fades = t.widgetList<FadeTransition>(find.ancestor(of: find.text('tab1 0'), matching: find.byType(FadeTransition)));
    expect(fades.first.opacity.value, lessThan(1));
    await t.pumpAndSettle();
    expect(find.text('tab1 0'), findsOneWidget);

    set(() => index = 0);
    await t.pumpAndSettle();
    // The count survived: the tab was kept, not rebuilt.
    expect(find.text('tab0 1'), findsOneWidget);
  });

  testWidgets('parenting: one bar, a tab switches in place, back returns home', (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: PpTabHost(home: _Home())));
    await t.pumpAndSettle();
    expect(PpTabs.instance.hosted, isTrue);
    // The page's own bar stands down; the host's is the one drawn.
    expect(find.byKey(const ValueKey('pp_tab_host_bar')), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await t.tap(find.byKey(const ValueKey('go_tools')));
    await t.pumpAndSettle();
    expect(PpTabs.instance.tab, PpTab.tools);
    // No route was pushed: the home page is still built, just offstage.
    expect(find.text('home page', skipOffstage: false), findsOneWidget);

    final popped = await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(popped, isTrue);
    expect(PpTabs.instance.tab, PpTab.home);
    expect(t.takeException(), isNull);
  });
}
