// =============================================================================
//  TTC treatment cycles - carrying the clinic's dates instead of inventing ours
// -----------------------------------------------------------------------------
//  The design this proves: on IVF / IUI / ovulation induction ParentVeda cannot
//  predict anything useful, so it stops competing with the clinic and carries
//  what the clinic said. Her dates are facts; ours would have been arithmetic
//  about a cycle that is not happening.
//
//  The defect fixed alongside it is the one worth reading twice. Chapter 4 and
//  the Calendar counted toward her next PERIOD. During a medicated cycle
//  progesterone support usually delays it - so the app was quietly telling
//  couples their period was late, which on a treatment cycle means nothing and
//  reads as hope.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_calendar_screen.dart';
import 'package:parentveda/screens/ttc/ttc_cycle_screens.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_today_screen.dart';
import 'package:parentveda/screens/ttc/ttc_treatment_screen.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_chapter.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

Future<void> pumpTall(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  void seedIvfCouple() {
    CycleStore.instance
      ..logPeriodStart(DateTime(2026, 5, 1))
      ..logPeriodStart(DateTime(2026, 5, 29))
      ..logPeriodStart(DateTime.now().subtract(const Duration(days: 12)));
    TtcStore.instance.setPath(TtcPath.ivf);
  }

  // ===========================================================================
  group('the cycle model', () {
    test('starts empty, and a partial cycle is normal', () {
      final store = TtcTreatmentStore.instance;
      expect(store.hasDates, isFalse);
      // Most couples know the next two dates and not the rest.
      store.setDate(TtcTreatmentStep.retrieval, DateTime(2026, 8, 10));
      expect(store.hasDates, isTrue);
      expect(store.cycle[TtcTreatmentStep.transfer], isNull);
    });

    test('"next" finds the soonest milestone still ahead', () {
      final store = TtcTreatmentStore.instance;
      final now = DateTime.now();
      store
        ..setDate(TtcTreatmentStep.stimStart,
            now.subtract(const Duration(days: 5))) // past
        ..setDate(TtcTreatmentStep.betaTest, now.add(const Duration(days: 20)))
        ..setDate(TtcTreatmentStep.retrieval, now.add(const Duration(days: 3)));
      expect(store.cycle.next!.$1, TtcTreatmentStep.retrieval);
    });

    test('"next" is null once the cycle is behind her', () {
      final store = TtcTreatmentStore.instance;
      store.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().subtract(const Duration(days: 2)));
      expect(store.cycle.next, isNull);
    });

    test('only the trigger carries a time', () {
      expect(TtcTreatmentStep.trigger.needsTime, isTrue);
      for (final s in TtcTreatmentStep.values
          .where((s) => s != TtcTreatmentStep.trigger)) {
        expect(s.needsTime, isFalse, reason: '$s');
      }
    });

    test('every step is bilingual and carries a practical note', () {
      for (final s in TtcTreatmentStep.values) {
        for (final hi in [true, false]) {
          expect(s.label(hi), isNotEmpty, reason: '$s');
          expect(s.note(hi), isNotEmpty, reason: '$s');
        }
        expect(s.note(true), isNot(s.note(false)), reason: '$s');
      }
    });

    test('a cycle round-trips through encoding, keeping the trigger time', () {
      final store = TtcTreatmentStore.instance;
      final trigger = DateTime(2026, 8, 7, 22, 15);
      store
        ..setDate(TtcTreatmentStep.trigger, trigger)
        ..setClinic('Rainbow Fertility');
      final back = TtcTreatmentCycle.fromJson(store.cycle.toJson());
      expect(back[TtcTreatmentStep.trigger], trigger);
      expect(back[TtcTreatmentStep.trigger]!.minute, 15,
          reason: 'the trigger minute is clinically significant');
      expect(back.clinic, 'Rainbow Fertility');
    });

    test('a corrupt blob decodes to an empty cycle, never a crash', () {
      expect(TtcTreatmentCycle.fromJson('nonsense').isEmpty, isTrue);
      expect(TtcTreatmentCycle.fromJson({'dates': 'wrong'}).isEmpty, isTrue);
    });

    test('clearing a cycle leaves the rest of her data alone', () {
      seedIvfCouple();
      TtcTreatmentStore.instance
          .setDate(TtcTreatmentStep.retrieval, DateTime(2026, 8, 10));
      TtcTreatmentStore.instance.clearCycle();
      expect(TtcTreatmentStore.instance.hasDates, isFalse);
      expect(CycleStore.instance.periodStarts.length, 3);
      expect(TtcStore.instance.path, TtcPath.ivf);
    });

    test('a date can be removed one at a time', () {
      final store = TtcTreatmentStore.instance;
      store.setDate(TtcTreatmentStep.transfer, DateTime(2026, 8, 15));
      store.setDate(TtcTreatmentStep.transfer, null);
      expect(store.cycle[TtcTreatmentStep.transfer], isNull);
    });
  });

  // ===========================================================================
  group('the countdown defect', () {
    test('the beta test is what the two-week wait actually ends on', () {
      final store = TtcTreatmentStore.instance;
      expect(store.cycle.betaTest, isNull);
      final beta = DateTime(2026, 8, 20);
      store.setDate(TtcTreatmentStep.betaTest, beta);
      expect(store.cycle.betaTest, beta);
    });

    testWidgets('a clinic path never shows a period countdown', (tester) async {
      seedIvfCouple();
      await pumpTall(tester, const TtcCalendarScreen());
      final t = const TtcS(false);
      // Progesterone support usually delays the period, so this countdown means
      // nothing here and reads as hope.
      expect(find.text(t.calendarNextPeriod), findsNothing);
    });

    testWidgets('with a beta date it counts to the blood test instead',
        (tester) async {
      seedIvfCouple();
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 9)));
      await pumpTall(tester, const TtcCalendarScreen());
      final t = const TtcS(false);
      expect(find.text(t.betaWaitTitle), findsOneWidget);
      expect(find.text(t.calendarNextPeriod), findsNothing);
    });

    testWidgets('a natural path still counts to her period', (tester) async {
      CycleStore.instance
        ..logPeriodStart(DateTime(2026, 5, 1))
        ..logPeriodStart(DateTime(2026, 5, 29))
        ..logPeriodStart(DateTime.now().subtract(const Duration(days: 12)));
      await pumpTall(tester, const TtcCalendarScreen());
      expect(find.text(const TtcS(false).calendarNextPeriod), findsOneWidget);
    });

    test('no "expected period" marker is drawn on a clinic path', () {
      seedIvfCouple();
      final last = CycleStore.instance.lastPeriodStart!;
      final expected = last.add(const Duration(days: 28));
      expect(ttcFactsFor(expected).isExpectedPeriod, isFalse,
          reason: 'a date her body has not agreed to and her clinic never '
              'mentioned');
    });
  });

  // ===========================================================================
  group('the clinic dates reach the surfaces', () {
    testWidgets("Today invites her to add them", (tester) async {
      seedIvfCouple();
      await pumpTall(tester, const TtcTodayScreen());
      expect(find.text(const TtcS(false).treatmentAddDates), findsOneWidget);
    });

    testWidgets('once added, Today shows the next milestone', (tester) async {
      seedIvfCouple();
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.retrieval,
          DateTime.now().add(const Duration(days: 4)));
      await pumpTall(tester, const TtcTodayScreen());
      final t = const TtcS(false);
      expect(find.text(t.treatmentNext.toUpperCase()), findsOneWidget);
      expect(find.text(t.treatmentAddDates), findsNothing);
    });

    testWidgets('the Fertility Window offers the same door', (tester) async {
      seedIvfCouple();
      await pumpTall(tester, const TtcFertilityWindowScreen());
      expect(find.text(TtcStore.instance.ownership.title(false)), findsOneWidget);
    });

    testWidgets('the treatment screen builds, empty and filled',
        (tester) async {
      await pumpTall(tester, const TtcTreatmentScreen());
      expect(tester.takeException(), isNull);
      TtcTreatmentStore.instance
        ..setDate(TtcTreatmentStep.trigger, DateTime(2026, 8, 7, 22, 15))
        ..setDate(TtcTreatmentStep.betaTest, DateTime(2026, 8, 20));
      await pumpTall(tester, const TtcTreatmentScreen());
      expect(tester.takeException(), isNull);
      expect(find.text(TtcTreatmentStep.trigger.label(false)), findsWidgets);
    });

    test('treatment dates land on the calendar day they fall on', () {
      seedIvfCouple();
      final day = DateTime.now().add(const Duration(days: 6));
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.retrieval, day);
      expect(ttcFactsFor(day).treatment, isNotEmpty);
      expect(ttcFactsFor(day).hasAnything, isTrue);
      expect(ttcFactsFor(day.add(const Duration(days: 1))).treatment, isEmpty);
    });

    test('the card only appears on a clinic path', () {
      expect(ttcShowTreatment(), isFalse);
      TtcStore.instance.setPath(TtcPath.iui);
      expect(ttcShowTreatment(), isTrue);
    });
  });

  // ===========================================================================
  group('the app still refuses to invent a date', () {
    test('adding clinic dates does not resurrect the fertility grade', () {
      // The whole point: her dates are carried, ours are still never computed.
      seedIvfCouple();
      TtcTreatmentStore.instance
          .setDate(TtcTreatmentStep.trigger, DateTime.now());
      final today = TtcStore.instance.today;
      expect(today.fertility, isNull);
      expect(today.estimatedOvulationDay, isNull);
      expect(today.clinicInvolved, isTrue);
    });

    test('switching back to natural restores the calendar', () {
      seedIvfCouple();
      expect(TtcStore.instance.today.fertility, isNull);
      TtcStore.instance.setPath(TtcPath.natural);
      expect(TtcStore.instance.today.fertility, isNotNull);
    });
  });
}
