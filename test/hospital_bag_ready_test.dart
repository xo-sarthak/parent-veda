// Smoke tests for the "Ready for Birth" redesign (the Hospital Bag rebuilt as a
// readiness experience). Confirms the dashboard boots with its four categories,
// the emergency grab-list opens, and a category reveals its items.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/tools/ready_for_birth_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> boot(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: ReadyForBirthScreen(controller: PregnancyController())));
    await tester.pump(); // first frame (booting)
    // Pump until the async boot (store init + seed) finishes and the dashboard
    // renders — the persistent "Labour started?" bar is the ready marker.
    for (var i = 0; i < 40; i++) {
      if (find.text('Labour started?').evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 25));
    }
  }

  testWidgets('Dashboard boots with the four readiness categories', (tester) async {
    await boot(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Ready for Birth'), findsOneWidget); // app bar
    expect(find.text("Let's pack together"), findsWidgets); // primary CTA (near top)
    expect(find.text('Labour started?'), findsOneWidget); // persistent action
    // Category cards live lower in the lazy list — scroll them in.
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
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Documents'), 200, scrollable: scrollable, maxScrolls: 20);
    await tester.tap(find.text('Documents').first);
    await tester.pumpAndSettle();
    // On the category screen now — scroll the Add-your-own button into view.
    final catScroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Add your own'), 200, scrollable: catScroll, maxScrolls: 20);
    expect(find.text('Add your own'), findsOneWidget);
  });
}
