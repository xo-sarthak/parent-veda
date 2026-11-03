// Pee Safe demo, item 10: the Showcase in You. Seven cards in the voice-note
// order, "Reset demo" clears the store-QR switch and the kit's ticks, and the
// You row is wired (asserted on the source: the wiring gate).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/brand/brand_studio.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_partner.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_recovery_kit_screen.dart';
import 'package:parentveda/brand/pee_safe/pee_safe_showcase_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    RecoveryKitTicks.instance.debugUnload();
  });

  tearDown(() {
    PeeSafeStoreQr.reset();
    BrandStudio.instance.demoMode = false;
  });

  test('seven steps, in the voice-note order', () {
    expect(kPeeSafeShowcaseSteps.map((s) => s.kind).toList(), [
      PeeSafeShowcaseKind.premiere,
      PeeSafeShowcaseKind.brandPage,
      PeeSafeShowcaseKind.reads,
      PeeSafeShowcaseKind.kit,
      PeeSafeShowcaseKind.placements,
      PeeSafeShowcaseKind.notifications,
      PeeSafeShowcaseKind.partner,
    ]);
  });

  testWidgets('renders seven numbered cards top to bottom, demo mode on', (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PeeSafeShowcaseScreen()));
    await tester.pump();

    expect(BrandStudio.instance.demoMode, isTrue);
    expect(find.text('Reset demo'), findsOneWidget);
    expect(find.text('Show me ›'), findsNWidgets(7));

    var lastY = -1.0;
    for (var i = 0; i < kPeeSafeShowcaseSteps.length; i++) {
      final s = kPeeSafeShowcaseSteps[i];
      expect(find.text('${i + 1}. ${s.title}'), findsOneWidget);
      expect(find.text('In the app: ${s.where}'), findsOneWidget);
      final y = tester.getTopLeft(find.byKey(ValueKey('ps_showcase_card_${s.kind.name}'))).dy;
      expect(y, greaterThan(lastY), reason: 'card ${i + 1} out of order');
      lastY = y;
    }
  });

  testWidgets('partner "Show me" turns the store QR on and returns to the screen below', (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Stand-in for You: the Showcase is pushed on top of it.
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(ctx).push(PeeSafeShowcaseScreen.route()),
            child: const Text('You'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    expect(PeeSafeStoreQr.on, isFalse);

    await tester.tap(find.byKey(const ValueKey('ps_showcase_show_partner')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5)); // let the toast go

    expect(PeeSafeStoreQr.on, isTrue, reason: 'the room sees the offer without hunting for the switch');
    expect(find.byType(PeeSafeShowcaseScreen), findsNothing, reason: 'back on You, where the offer card renders');
  });

  testWidgets('Reset demo clears the store QR switch and the kit ticks', (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await RecoveryKitTicks.instance.load();
    await RecoveryKitTicks.instance.toggle(kRecoveryKitItems.first.id);
    PeeSafeStoreQr.set(true);
    expect(PeeSafeStoreQr.on, isTrue);
    expect(RecoveryKitTicks.instance.count, 1);

    await tester.pumpWidget(const MaterialApp(home: PeeSafeShowcaseScreen()));
    await tester.tap(find.byKey(const ValueKey('ps_showcase_reset')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5)); // let the toast go

    expect(PeeSafeStoreQr.on, isFalse);
    expect(RecoveryKitTicks.instance.count, 0);
  });

  test('the You row is wired, behind kPeeSafeDemo, under its route name', () {
    final you = File('lib/screens/profile/pv_you_screen.dart').readAsStringSync();
    expect(you, contains('PeeSafeShowcaseScreen.route()'));
    expect(you, contains("ValueKey('pv_profile_pee_safe_showcase')"));
    expect(
      RegExp(r'if \(kPeeSafeDemo\)\s*PvProfileRow\(\s*key: const ValueKey\(.pv_profile_pee_safe_showcase.\)')
          .hasMatch(you),
      isTrue,
    );
    final screen = File('lib/brand/pee_safe/pee_safe_showcase_screen.dart').readAsStringSync();
    expect(screen, contains("kPeeSafeShowcaseRoute = 'pee_safe_showcase'"));
    expect(screen, contains('RouteSettings(name: kPeeSafeShowcaseRoute)'));
  });
}
