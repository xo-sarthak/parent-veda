// The week page, grown 2026-09-29 from the pregnancy gap analysis ("Behind ·
// Week by week"): month and trimester, her body this week, do and skip,
// Asked this week, myth or fact, call your doctor if, for your partner,
// where this comes from, and pages for weeks 1 to 3, 41 and 42.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/preg_week_extras.dart';
import 'package:parentveda/screens/preg_week_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController pregnancy;

  setUpAll(() async {
    final now = _dayOnly(DateTime.now());
    final due = now.add(const Duration(days: 144)); // week 20
    SharedPreferences.setMockInitialValues({
      PregnancyController.kDueDateKey: due.toIso8601String(),
    });
    pregnancy = PregnancyController(dueDate: due);
    await pregnancy.load();
  });

  Future<void> pumpWeek(WidgetTester tester, int week) async {
    tester.view.physicalSize = const Size(360, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: PregWeekScreen(key: ValueKey(week), pregnancy: pregnancy, week: week)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  }

  Finder t(String s) => find.text(s, skipOffstage: false);
  Finder tc(String s) => find.textContaining(s, skipOffstage: false);

  group('month and trimester', () {
    test('the boundaries the page prints', () {
      expect(pregMonthFor(4), 1);
      expect(pregMonthFor(20), 5);
      expect(pregMonthFor(40), 9);
      expect(pregTrimesterFor(12), 'First trimester');
      expect(pregTrimesterFor(13), 'Second trimester');
      expect(pregTrimesterFor(27), 'Second trimester');
      expect(pregTrimesterFor(28), 'Third trimester');
    });
  });

  group('a week from 4 to 40 shows everything the week data holds', () {
    testWidgets('week 20', (tester) async {
      await pumpWeek(tester, 20);
      expect(t('What happens in week 20'), findsOneWidget);
      expect(t('Week 20 · Month 5 · Second trimester'), findsOneWidget);
      expect(t('Your body this week'), findsOneWidget);
      expect(t('For you this week'), findsOneWidget);
      expect(t('DO THIS'), findsOneWidget);
      expect(t('SKIP THIS'), findsOneWidget);
      expect(t('MYTH OR FACT'), findsOneWidget);
      expect(t('CALL YOUR DOCTOR IF'), findsOneWidget);
      expect(t('For your partner'), findsOneWidget);
      expect(t('Asked this week'), findsOneWidget);
      expect(t('Where this comes from'), findsOneWidget);
      // Every symptom of the week is drawn.
      final w = pregnancy.weekData(20)!;
      for (final s in w.mom.commonSymptoms) {
        expect(t(s.en.trim()), findsOneWidget, reason: s.en);
      }
    });

    testWidgets('every week from 4 to 40 draws without an error', (tester) async {
      for (var w = 4; w <= 40; w++) {
        await pumpWeek(tester, w);
        expect(t('What happens in week $w'), findsOneWidget, reason: 'week $w');
        expect(t('CALL YOUR DOCTOR IF'), findsOneWidget, reason: 'week $w');
      }
    });
  });

  group('weeks 1 to 3, 41 and 42 have pages', () {
    testWidgets('each special page draws its title and its doctor card',
        (tester) async {
      for (final page in kPregSpecialWeekPages) {
        await pumpWeek(tester, page.weeks.last);
        expect(t(page.title), findsOneWidget, reason: page.id);
        expect(t('THE SHORT ANSWER'), findsOneWidget, reason: page.id);
        if (page.callYourDoctor != null) {
          expect(t('CALL YOUR DOCTOR IF'), findsOneWidget, reason: page.id);
        }
      }
    });

    testWidgets('the chips name them', (tester) async {
      // The chip row builds lazily around the open week, so each end is
      // checked from a week beside it.
      await pumpWeek(tester, 4);
      expect(tc('1 to 3 weeks'), findsOneWidget);
      await pumpWeek(tester, 40);
      expect(tc('41 weeks'), findsOneWidget);
      expect(tc('42 weeks'), findsOneWidget);
    });
  });
}
