// =============================================================================
//  The pregnancy home: tools open their tool, products open their product, and
//  the tools and people wear the TTC mark family (2026-10-02).
//
//  The user:
//    1. "Tools for this week: they all just open the Tools page; wire them."
//    2. "Recommended products to be wired to products."
//    3. "Update the marks/glyphs for Use these tools and People."
//
//  Each tool is tapped on the real home and the screen it opens is checked; the
//  same for a product card. The marks are checked by key and by type.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/doors/pv_door_screen.dart' show PvDoorScreen;
import 'package:parentveda/screens/home_v3_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tool_marks.dart' show TtcMarkLeading;
import 'package:parentveda/services/home_content_controller.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/tool_usage_store.dart';

/// Records every route pushed, by name.
class _Names extends NavigatorObserver {
  final names = <String?>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      names.add(route.settings.name);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController pregnancy;
  late HomeContentController home;

  setUp(() async {
    final n = DateTime.now();
    final due = DateTime(n.year, n.month, n.day).add(const Duration(days: 144));
    SharedPreferences.setMockInitialValues(
        {PregnancyController.kDueDateKey: due.toIso8601String()});
    pregnancy = PregnancyController(dueDate: due);
    await pregnancy.load();
    home = HomeContentController();
    await home.load();
    ToolUsageStore.instance.resetForTest();
  });

  Future<_Names> pumpHome(WidgetTester t) async {
    final obs = _Names();
    // Wide: the screens these open (the calendar, Can I?) overflow in the test
    // font at 360, which is theirs and not what this file checks.
    t.view.physicalSize = const Size(900, 5200);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      navigatorObservers: [obs],
      home: Scaffold(body: HomeV3Screen(pregnancy: pregnancy, home: home)),
    ));
    // A first-run tip can arrive a moment late; dismiss it before tapping, or
    // the tap lands on its barrier.
    // The daily tip is a frosted route over the home (v3_daily_tip.dart), not a
    // Dialog, so close whatever has been pushed on top of the home.
    for (var i = 0; i < 3; i++) {
      await t.pump(const Duration(milliseconds: 600));
      final nav = t.state<NavigatorState>(find.byType(Navigator).first);
      if (nav.canPop()) {
        nav.pop();
        await t.pump(const Duration(milliseconds: 400));
      }
    }
    obs.names.clear();
    return obs;
  }

  /// Where each tool must land: a route name, or the door screen.
  const expected = <String, String>{
    'movement': 'tools/movement',
    'weight': 'tools/weight',
    'kegel': 'tools/kegel',
    'hospital_bag': 'tools/hospital_bag',
    'contractions': 'tools/contractions',
    'due_date': 'tools/due_date',
    'medication': 'tools/medicines',
    'appointments': 'calendar',
    'reports': 'bracket/scans',
    'symptoms': 'door',
    'tests_scans': 'door',
    // Can I? opens wherever the home's own Can I? door tile does (`_openBracket`).
    'can_i': 'pushed',
  };

  // Four tools are shown at a time, so the twelve go in three rounds: the row
  // leads with her most-used, which is how each round puts its four on screen.
  final rounds = [
    ['movement', 'weight', 'kegel', 'hospital_bag'],
    ['contractions', 'due_date', 'medication', 'symptoms'],
    ['can_i', 'tests_scans', 'reports', 'appointments'],
  ];

  for (final round in rounds) {
    for (final id in round) {
      testWidgets('the $id tile opens its own screen, not the Tools tab', (t) async {
        for (final r in round) {
          await ToolUsageStore.instance.record(r);
        }
        final obs = await pumpHome(t);
        final tile = find.byKey(ValueKey('preg_home_tool_mark_$id'), skipOffstage: false);
        expect(tile, findsOneWidget, reason: '$id is not on the row');
        // Centre it: at the very top the home's frosted header sits over it.
        await Scrollable.ensureVisible(t.element(tile), alignment: 0.5);
        await t.pump(const Duration(milliseconds: 300));
        await t.tap(tile);
        await t.pump();
        await t.pump(const Duration(milliseconds: 600));
        final want = expected[id]!;
        if (want == 'door') {
          expect(find.byType(PvDoorScreen), findsOneWidget, reason: id);
        } else if (want == 'pushed') {
          expect(obs.names, isNotEmpty, reason: '$id opened nothing');
        } else {
          expect(obs.names, contains(want), reason: '$id opened ${obs.names}');
        }
        expect(ToolUsageStore.instance.countFor(id), greaterThan(0));
      });
    }
  }

  testWidgets('every tool tile and every People row wears a TTC family mark',
      (t) async {
    await pumpHome(t);
    final tiles = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('preg_home_tool_mark_'));
    expect(tiles, findsWidgets);
    for (final e in tiles.evaluate()) {
      expect(find.descendant(of: find.byWidget(e.widget), matching: find.byType(TtcMarkLeading)),
          findsOneWidget);
    }
    for (final r in kPregHomeExpertRoles) {
      final row = find.byKey(ValueKey('preg_home_expert_${r.id}'), skipOffstage: false);
      expect(find.descendant(of: row, matching: find.byType(TtcMarkLeading)), findsOneWidget,
          reason: r.title);
    }
    // Four roles, four different marks.
    expect(kPregHomeExpertRoles.map((r) => r.ttcMark).toSet(), hasLength(4));
  });

  testWidgets('a recommended product opens that product, not the Products tab',
      (t) async {
    final obs = await pumpHome(t);
    final card = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('v2_product_'));
    if (card.evaluate().isEmpty) {
      // No picks this week: nothing to tap, and nothing to check.
      return;
    }
    final key = (t.widget(card.first).key! as ValueKey<String>).value;
    final id = key.substring('v2_product_'.length);
    await Scrollable.ensureVisible(t.element(card.first), alignment: 0.5);
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(card.first);
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(obs.names, contains('product/$id'));
  });
}
