// Pee Safe demo, item 11: every Showcase "Show me" opens its REAL screen.
// Taps each card's button (and each placement row) and asserts the route that
// was pushed, by its RouteSettings name, plus the screen type where the screen
// is ours. The wiring gate, run as a tap rather than a grep.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/brand_models.dart';
import 'package:parentveda/brand/brand_page_screen.dart';
import 'package:parentveda/brand/brand_studio.dart';
import 'package:parentveda/brand/brand_store.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_brand.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_partner.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_recovery_kit_screen.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_showcase_screen.dart';
import 'package:parentveda/brand/premiere_screen.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';

class _Routes extends NavigatorObserver {
  final names = <String?>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => names.add(route.settings.name);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    BrandStudio.instance.allowInTests = true;
    BrandStudio.instance.enabled = true;
    BrandStudio.instance.resetCampaigns();
    BrandStudioStore.instance.resetAll();
    RecoveryKitTicks.instance.debugUnload();
  });

  tearDown(() {
    PeeSafeStoreQr.reset();
    BrandStudioStore.instance.resetAll();
    BrandStudio.instance.demoMode = false;
    BrandStudio.instance.allowInTests = false;
  });

  Future<_Routes> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final routes = _Routes();
    await tester.pumpWidget(MaterialApp(navigatorObservers: [routes], home: const PeeSafeShowcaseScreen()));
    await tester.pump();
    routes.names.clear();
    return routes;
  }

  // Lets a screen build without waiting on films, timers or toasts forever.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> tapShow(WidgetTester tester, PeeSafeShowcaseKind kind) async {
    await tester.tap(find.byKey(ValueKey('ps_showcase_show_${kind.name}')));
    await settle(tester);
  }

  testWidgets('1. premiere replays the Pee Safe Premiere', (tester) async {
    final r = await open(tester);
    await tapShow(tester, PeeSafeShowcaseKind.premiere);
    expect(r.names, contains('premiere'));
  });

  testWidgets('2. brand page opens BrandPageScreen', (tester) async {
    final r = await open(tester);
    await tapShow(tester, PeeSafeShowcaseKind.brandPage);
    expect(r.names, contains(kBrandPageRoute));
    expect(find.byType(BrandPageScreen), findsOneWidget);
  });

  testWidgets('3. reading shelf opens a read in the one reader', (tester) async {
    final r = await open(tester);
    await tapShow(tester, PeeSafeShowcaseKind.reads);
    expect(r.names, isNotEmpty);
    expect(find.byType(PvReaderScreen), findsOneWidget);
  });

  testWidgets('4. kit opens the recovery kit', (tester) async {
    final r = await open(tester);
    await tapShow(tester, PeeSafeShowcaseKind.kit);
    expect(r.names, contains(kPeeSafeKitRoute));
    expect(find.byType(PeeSafeRecoveryKitScreen), findsOneWidget);
  });

  // The live store's shelves (2026-11-03), not the old Recommendations screens.
  for (final row in const {
    'recovery': 'products/shelf',
    'hygiene': 'products/shelf',
    'travel': 'products/shelf',
  }.entries) {
    testWidgets('5. placements: ${row.key} opens ${row.value}', (tester) async {
      final r = await open(tester);
      await tapShow(tester, PeeSafeShowcaseKind.placements);
      await tester.tap(find.byKey(ValueKey('ps_showcase_place_${row.key}')));
      await settle(tester);
      expect(r.names, contains(row.value));
    });
  }

  testWidgets('5. placements: bag without a pregnancy says so, never an empty screen', (tester) async {
    final r = await open(tester);
    await tapShow(tester, PeeSafeShowcaseKind.placements);
    r.names.clear();
    await tester.tap(find.byKey(const ValueKey('ps_showcase_place_bag')));
    await tester.pump();
    expect(r.names, isNot(contains('tools/hospital_bag')));
    expect(find.text('Open a pregnancy profile to see the hospital bag.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5)); // let the toast go
  });

  testWidgets('6. notifications send now and say so', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const ValueKey('ps_showcase_show_notifications')));
    // The OS send is a platform call; let it complete off the fake clock.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('Sent: '), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  // ---- item 11: the launch film as the app opens, once per phone ----------

  Future<_Routes> openAtLaunch(WidgetTester tester) async {
    final routes = _Routes();
    await tester.pumpWidget(MaterialApp(
      navigatorObservers: [routes],
      home: Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => showPeeSafePremiereAtOpen(ctx, stage: BrandStage.parenting),
            child: const Text('open the app'),
          ),
        ),
      ),
    ));
    routes.names.clear();
    return routes;
  }

  Future<void> launchAndClose(WidgetTester tester) async {
    await tester.tap(find.text('open the app'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await settle(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    if (nav.canPop()) nav.pop();
    await settle(tester);
  }

  testWidgets('app open: the Pee Safe Premiere plays once, and demo mode cannot repeat it', (tester) async {
    final r = await openAtLaunch(tester);
    await launchAndClose(tester);
    expect(r.names.where((n) => n == 'premiere').length, 1);
    expect(BrandStudioStore.instance.impressions(kPeeSafePremiereId), 1);

    BrandStudio.instance.demoMode = true; // the Showcase leaves this on
    r.names.clear();
    await launchAndClose(tester);
    expect(r.names, isNot(contains('premiere')), reason: 'once per phone, even with caps relaxed');
  });

  testWidgets('Reset demo re-arms the app-open Premiere', (tester) async {
    final r = await openAtLaunch(tester);
    await launchAndClose(tester);
    await resetPeeSafeDemo();
    expect(BrandStudioStore.instance.impressions(kPeeSafePremiereId), 0);
    r.names.clear();
    await launchAndClose(tester);
    expect(r.names, contains('premiere'));
  });

  test('every stage calls it as the app opens (the wiring gate)', () {
    for (final f in const [
      'lib/screens/main_scaffold.dart', // pregnancy
      'lib/screens/post_pregnancy/pp_home_version.dart', // parenting (the shell both homes sit in)
      'lib/screens/ttc/ttc_home_version.dart', // TTC
    ]) {
      expect(File(f).readAsStringSync(), contains('showPeeSafePremiereAtOpen('), reason: f);
    }
    // The general app-open Premiere stays off (2026-09-17).
    final scaffold = File('lib/screens/main_scaffold.dart').readAsStringSync();
    expect(scaffold, contains('//   showPremiereIfAny('));
  });
}
