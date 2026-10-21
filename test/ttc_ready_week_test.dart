// The Ready-to-Try plan V2 (2026-10-21): "Your week", help cards, reminders.
// See lib/ttc/ttc_ready_plan.dart (readyHabitsFor, readyPitchesFor) and
// lib/ttc/ttc_ready_habits_store.dart.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/reminder.dart';
import 'package:parentveda/ttc/ttc_prepare_data.dart' show ttcOfferingById;
import 'package:parentveda/ttc/ttc_practice_data.dart' show ttcPracticeById;
import 'package:parentveda/ttc/ttc_ready_habits_store.dart';
import 'package:parentveda/ttc/ttc_ready_plan.dart';

ReadyPlanAnswers _a() => ReadyPlanAnswers()
  ..target = DateTime(2027, 1)
  ..diet = ReadyDiet.veg
  ..folic = ReadyFolic.yes;

void main() {
  group('every answer feeds the week', () {
    test('movement time sets the habit, and "not now" still has a minimum', () {
      final thirty = readyHabitsFor(_a()..move = ReadyMove.thirty);
      expect(thirty.firstWhere((h) => h.id == 'move').title,
          'Move for 30 minutes');
      final none = readyHabitsFor(_a()..move = ReadyMove.notNow);
      expect(none.firstWhere((h) => h.id == 'move').title,
          '2 minutes of stretching');
    });

    test('her time of day sets movement; calm only when it would help', () {
      final evening = readyHabitsFor(_a()
        ..move = ReadyMove.fifteen
        ..when = ReadyWhen.evening);
      expect(evening.firstWhere((h) => h.id == 'move').minutes, 19 * 60 + 30);
      expect(evening.any((h) => h.id == 'calm'), isFalse);
      expect(readyHabitsFor(_a()..mood = ReadyMood.someStress)
          .any((h) => h.id == 'calm'), isTrue);
    });

    test('garbh sanskar is weekly, on Sunday', () {
      final g = readyHabitsFor(_a()..garbh = ReadyGarbh.yes)
          .firstWhere((h) => h.id == 'garbh');
      expect(g.weekday, DateTime.sunday);
    });

    test('every habit has a smaller version and opens something real', () {
      final all = readyHabitsFor(_a()
        ..move = ReadyMove.thirty
        ..mood = ReadyMood.aLot
        ..garbh = ReadyGarbh.yes);
      for (final h in all) {
        expect(h.minimum, isNotEmpty, reason: h.id);
        final s = h.surfaceId!;
        if (s.startsWith('ttc_practice/')) {
          expect(ttcPracticeById(s.substring('ttc_practice/'.length)),
              isNotNull, reason: s);
        }
      }
    });
  });

  group('help with this', () {
    test('never more than two, and every one is a real offering', () {
      final a = _a()
        ..checkup = ReadyCheckup.no
        ..mood = ReadyMood.aLot
        ..conditions.add(ReadyCondition.pcos)
        ..hisHabits.add(HisHabit.medicines);
      final p = readyPitchesFor(a);
      expect(p.length, 2);
      expect(p.first.offeringId, 'ttc_consult_gynae');
      for (final x in [
        ...p,
        ...readyPitchesFor(_a()),
        ...readyPitchesFor(_a()..hisHabits.add(HisHabit.medicines)),
        ...readyPitchesFor(_a()..conditions.add(ReadyCondition.pcos)),
      ]) {
        expect(ttcOfferingById(x.offeringId), isNotNull, reason: x.offeringId);
      }
    });
  });

  group('answers survive a save', () {
    test('the new answers round-trip by name', () {
      final a = _a()
        ..move = ReadyMove.five
        ..when = ReadyWhen.lateNight
        ..mood = ReadyMood.calm
        ..garbh = ReadyGarbh.later
        ..checkup = ReadyCheckup.notSure;
      final b = ReadyPlanAnswers.fromJson(a.toJson());
      expect(b.move, ReadyMove.five);
      expect(b.when, ReadyWhen.lateNight);
      expect(b.mood, ReadyMood.calm);
      expect(b.garbh, ReadyGarbh.later);
      expect(b.checkup, ReadyCheckup.notSure);
    });

    test('the medicines option names what matters', () {
      expect(HisHabit.medicines.label, contains('testosterone'));
    });
  });

  group('reminders at her time', () {
    setUp(TtcReadyHabitsStore.instance.resetForTest);

    test('a habit reminds at its suggested time, weekly ones weekly', () {
      final habits = readyHabitsFor(_a()
        ..move = ReadyMove.fifteen
        ..when = ReadyWhen.evening
        ..garbh = ReadyGarbh.yes);
      final move = habits.firstWhere((h) => h.id == 'move');
      final r = TtcReadyHabitsStore.instance.reminderFor(move);
      expect((r.hour, r.minute), (19, 30));
      expect(r.repeat, ReminderRepeat.daily);
      final g = TtcReadyHabitsStore.instance
          .reminderFor(habits.firstWhere((h) => h.id == 'garbh'));
      expect(g.repeat, ReminderRepeat.weekly);
      expect(g.weekday, DateTime.sunday);
      expect(TtcReadyHabitsStore.weeklyReminder.weekday, DateTime.sunday);
    });
  });

  group('wiring gate', () {
    test('the plan screen draws the week, the help cards and the PDF', () {
      final s = File('lib/screens/ttc/ttc_ready_plan_screen.dart')
          .readAsStringSync();
      expect(s, contains('TtcReadyWeek(habits: plan.habits)'));
      expect(s, contains('TtcReadyHelpCards(pitches: plan.pitches)'));
      expect(s, contains('shareTtcReadyPlanPdf(context, plan)'));
      expect(s, contains('TtcToolChoice<ReadyMove>'));
      expect(s, contains('TtcToolChoice<ReadyCheckup>'));
    });
  });
}
