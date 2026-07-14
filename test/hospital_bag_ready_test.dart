// Smoke tests for the "Ready for Birth" redesign (the Hospital Bag rebuilt as a
// readiness experience). Confirms the dashboard boots with its four categories,
// the emergency grab-list opens, a category reveals its items, an item can be
// set aside ("I don't need this"), "Need one?" opens the full options page, and
// "Start again" asks to confirm.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/hospital_bag_seed.dart';
import 'package:parentveda/screens/tools/ready_for_birth_screen.dart';
import 'package:parentveda/services/hospital_bag_store.dart';
import 'package:parentveda/services/hospital_bag_v2_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> boot(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    // Singletons persist across tests — reset to a clean default bag each time.
    try {
      await HospitalBagV2Store.instance.init();
    } catch (_) {/* offline in test */}
    await HospitalBagV2Store.instance.createBag(generateDefaultBag(DeliveryType.unsure), DeliveryType.unsure);

    await tester.pumpWidget(MaterialApp(home: ReadyForBirthScreen(controller: PregnancyController())));
    await tester.pump(); // first frame (booting)
    for (var i = 0; i < 40; i++) {
      if (find.text('Labour started?').evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 25));
    }
  }

  Future<void> openCategory(WidgetTester tester, String name) async {
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text(name), 200, scrollable: scrollable, maxScrolls: 20);
    await tester.tap(find.text(name).first);
    await tester.pumpAndSettle();
  }

  testWidgets('Dashboard boots with the four readiness categories', (tester) async {
    await boot(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Ready for Birth'), findsOneWidget); // app bar
    expect(find.text("Let's pack together"), findsWidgets); // primary CTA
    expect(find.text('Labour started?'), findsOneWidget); // persistent action
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Documents'), 200, scrollable: scrollable, maxScrolls: 20);
    expect(find.text('Documents'), findsWidgets);
  });

  testWidgets('Labour started? opens the calm emergency grab-list', (tester) async {
    await boot(tester);
    await tester.tap(find.text('Labour started?'));
    await tester.pumpAndSettle();
    expect(find.text('Take these first'), findsOneWidget);
    expect(find.text('Your hospital bag'), findsOneWidget);
  });

  testWidgets('A category opens its items with Add-your-own', (tester) async {
    await boot(tester);
    await openCategory(tester, 'Documents');
    final catScroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Add your own'), 200, scrollable: catScroll, maxScrolls: 20);
    expect(find.text('Add your own'), findsOneWidget);
  });

  testWidgets("'I don't need this' sets an item aside into Not-for-us", (tester) async {
    await boot(tester);
    await openCategory(tester, 'Documents');
    final notNeeded = find.text("I don't need this").first;
    await tester.ensureVisible(notNeeded);
    await tester.tap(notNeeded);
    await tester.pumpAndSettle();
    final catScroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Not for us'), 200, scrollable: catScroll, maxScrolls: 20);
    expect(find.text('Not for us'), findsOneWidget);
    expect(find.text('Add back'), findsWidgets);
  });

  testWidgets("'Need one?' opens the full options page (all choices)", (tester) async {
    await boot(tester);
    await openCategory(tester, 'Mom');
    final needOne = find.text('Need one?').first;
    await tester.ensureVisible(needOne);
    await tester.tap(needOne);
    await tester.pumpAndSettle();
    expect(find.text('How to choose'), findsOneWidget);
    expect(find.text('Our picks'), findsWidgets);
  });

  testWidgets("'Start again' asks for confirmation", (tester) async {
    await boot(tester);
    await tester.tap(find.byTooltip('Start again'));
    await tester.pumpAndSettle();
    expect(find.text('Start again?'), findsOneWidget);
  });
}
