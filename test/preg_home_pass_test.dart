// The home pass (2026-09-30, pregnancy gap analysis, "Home & daily"):
//   · "20 weeks to go" under the day, with an (i) on how weeks are counted
//   · past the due date the count keeps going ("40 weeks and 3 days")
//   · from week 37, "Has your baby arrived?" at the foot of the hero
//   · with nothing booked, the usual scan for her week on the insights rail
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/scan_appointment.dart';
import 'package:parentveda/screens/preg_daily_insights.dart';
import 'package:parentveda/screens/pregnancy/preg_hero_extras.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/screens/v2/v3_preg_hero.dart';
import 'package:parentveda/services/scans_store.dart';

String _code(String p) => File(p)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PregArrivalPrompt.instance.resetForTest();
  });

  group('time left', () {
    test('weeks, then days, then the day itself, then past it', () {
      // Week 20, day 1 is 146 days out: "20 weeks to go", as What to Expect says.
      expect(pregTimeLeft(146), '20 weeks to go');
      expect(pregTimeLeft(13), '1 week to go');
      expect(pregTimeLeft(3), '3 days to go');
      expect(pregTimeLeft(1), '1 day to go');
      expect(pregTimeLeft(0), 'Your due date is today');
      expect(pregTimeLeft(-2), 'Past your due date');
    });

    test('past the due date the count keeps going', () {
      expect(pregPastDueCount(5), isNull);
      expect(pregPastDueCount(0), isNull);
      expect(pregPastDueCount(-3), '40 weeks and 3 days');
      expect(pregPastDueCount(-1), '40 weeks and 1 day');
      expect(pregPastDueCount(-7), '41 weeks');
      expect(pregPastDueCount(-9), '41 weeks and 2 days');
    });
  });

  group('the hero', () {
    Future<void> pump(WidgetTester tester, V3PregHero hero) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: hero))));
      await tester.pump();
    }

    V3PregHero hero({
      String? timeLeft,
      String? pastDue,
      VoidCallback? onHow,
      VoidCallback? onDetails,
      VoidCallback? onPastDue,
      Widget? footer,
    }) =>
        V3PregHero(
          p: V2PaletteStore.instance.current,
          week: 20,
          day: 134,
          selected: DateTime(2026, 9, 30),
          today: DateTime(2026, 9, 30),
          daysBack: 30,
          onSelectDay: (_) {},
          markFor: (_, _) => null,
          initial: 'A',
          onDetails: onDetails,
          timeLeft: timeLeft,
          pastDueCount: pastDue,
          onHowCounted: onHow,
          onPastDue: onPastDue,
          footer: footer,
        );

    testWidgets('says the time left, and the (i) explains, not the week page', (tester) async {
      var how = 0, details = 0;
      await pump(tester, hero(timeLeft: '20 weeks to go', onHow: () => how++, onDetails: () => details++));
      expect(find.text('20 weeks to go'), findsOneWidget);
      expect(find.text('Day 1'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('preg_hero_time_left')));
      expect(how, 1);
      expect(details, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('past the due date: the count, and "what happens now"', (tester) async {
      var past = 0;
      await pump(tester, hero(timeLeft: 'Past your due date', pastDue: '40 weeks and 3 days', onPastDue: () => past++));
      expect(find.text('40 weeks and 3 days'), findsOneWidget);
      expect(find.text('Past your due date: what happens now'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('preg_hero_time_left')));
      expect(past, 1);
    });

    testWidgets('the arrival card sits at its foot', (tester) async {
      await pump(tester, hero(footer: PregArrivalCard(p: V2PaletteStore.instance.current)));
      expect(find.text('Has your baby arrived?'), findsOneWidget);
      expect(find.text('Yes, tell ParentVeda'), findsOneWidget);
      expect(find.text('Not yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('"Has your baby arrived?"', () {
    test('from week 37, and "Not yet" rests it for three days', () async {
      final prompt = PregArrivalPrompt.instance;
      final now = DateTime(2026, 9, 30, 10);
      expect(prompt.showsFor(36, now: now), isFalse);
      expect(prompt.showsFor(37, now: now), isTrue);
      await prompt.notYet(now: now);
      expect(prompt.showsFor(38, now: now.add(const Duration(days: 2))), isFalse);
      expect(prompt.showsFor(38, now: now.add(const Duration(days: 3))), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PregArrivalPrompt.kSnoozeKey), isNotNull, reason: 'survives a restart');
    });
  });

  group('the usual scan for her week', () {
    test('derived from the Scans door, routine ones only', () {
      final ids = {for (final w in pregScanWindows()) w.id};
      expect(ids, containsAll(['nt_scan', 'anomaly_scan', 'ogtt', 'growth_scan']));
      for (final optional in ['nipt', 'doppler', 'gbs']) {
        expect(ids, isNot(contains(optional)), reason: optional);
      }
      final a = pregScanWindows().firstWhere((w) => w.id == 'anomaly_scan');
      expect((a.from, a.to), (18, 22));
      expect(pregScanWindowFor(20)?.id, 'anomaly_scan');
      expect(pregScanWindowFor(12)?.id, 'nt_scan');
      expect(pregScanWindowFor(26)?.id, 'ogtt');
      expect(pregScanWindowFor(16), isNull);
    });

    List<PregInsight> cardsAt(DateTime today) => pregInsightsFor(
          date: today,
          today: today,
          day: 134,
          week: 20,
          homeDay: null,
          weekContent: null,
          reads: const [],
        );

    test('with nothing booked the rail says the window; with a booking, the booking', () async {
      final today = DateTime(2026, 9, 30);
      final store = ScansStore.instance;
      for (final a in [...store.appointments]) {
        await store.deleteAppointment(a.id);
      }
      final free = cardsAt(today);
      final w = free.where((c) => c.go == PregInsightGo.scanWindow).toList();
      expect(w, hasLength(1));
      expect(w.single.value, 'Anomaly scan');
      expect(w.single.caption, 'Weeks 18 to 22 · Add my date');

      await store.addAppointment(Appointment(
          id: 'ap_test', title: 'Anomaly scan', dateIso: today.add(const Duration(days: 30)).toIso8601String()));
      addTearDown(() => store.deleteAppointment('ap_test'));
      final booked = cardsAt(today);
      expect(booked.where((c) => c.go == PregInsightGo.scanWindow), isEmpty,
          reason: 'a scan booked a month out means she knows');
    });
  });

  test('the home wires all three', () {
    final src = _code('lib/screens/home_v3_screen.dart');
    expect(src, contains('timeLeft: pregTimeLeft('));
    expect(src, contains('pastDueCount: pregPastDueCount('));
    expect(src, contains('PregArrivalCard(p: p)'));
    expect(src, contains('case PregInsightGo.scanWindow:'));
  });
}
