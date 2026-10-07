// =============================================================================
//  TTC: the home, Cycle companion and the Cycle report say the same thing
// -----------------------------------------------------------------------------
//  2026-10-07. The user: the home hero said "fertile days open in N days"
//  while Cycle companion and the Cycle report said nothing about fertile
//  days. All three now lead with one sentence (ttc_cycle_headline.dart).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_cycle_headline.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_report_screen.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_screens.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
  });

  DateTime ago(int days) {
    final n = DateTime.now().subtract(Duration(days: days));
    return DateTime(n.year, n.month, n.day);
  }

  // Cycles of 28 days, the last period five days ago: before the window.
  void dayFive() {
    CycleStore.instance
      ..logPeriodStart(ago(60))
      ..logPeriodStart(ago(32))
      ..logPeriodStart(ago(4));
  }

  Future<void> pump(WidgetTester t, Widget w) async {
    t.view.physicalSize = const Size(400, 3000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: w));
    await t.pump(const Duration(milliseconds: 400));
  }

  test('on day five the headline is the fertile-days countdown, with dates', () {
    dayFive();
    final h = ttcCycleHeadline();
    expect(h, isNotNull);
    expect(h!.toLowerCase(), contains('fertile'));
    expect(h, contains(' to '));
  });

  test('nothing logged: no sentence, each screen keeps its invitation', () {
    expect(ttcCycleHeadline(), isNull);
  });

  testWidgets('Cycle companion leads with the same sentence', (t) async {
    dayFive();
    final h = ttcCycleHeadline()!;
    await pump(t, const TtcCycleScreen());
    expect(find.textContaining(h), findsWidgets);
  });

  testWidgets('the Cycle report leads with the same sentence', (t) async {
    dayFive();
    final h = ttcCycleHeadline()!;
    await pump(t, const TtcCycleReportScreen());
    expect(find.textContaining(h), findsWidgets);
  });
}
