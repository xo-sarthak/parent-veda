// The Ready-to-Try plan's reminders end where her month begins, and are set
// again after every launch (2026-10-21). See the header of
// lib/ttc/ttc_ready_habits_store.dart.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/life_stage_store.dart' show LifeStage;
import 'package:parentveda/ttc/ttc_ready_habits_store.dart';
import 'package:parentveda/ttc/ttc_ready_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

ReadyPlanAnswers _a(DateTime target) => ReadyPlanAnswers()
  ..target = target
  ..diet = ReadyDiet.veg
  ..folic = ReadyFolic.yes
  ..move = ReadyMove.fifteen;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final store = TtcReadyHabitsStore.instance;
  const ttc = LifeStage.tryingToConceive;
  final now = DateTime(2026, 10, 21);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store.resetForTest();
  });

  Future<List<ReadyHabit>> allOn(ReadyPlanAnswers a) async {
    final habits = readyHabitsFor(a);
    for (final h in habits) {
      await store.setRemind(h, true);
    }
    await store.setWeekly(true);
    return habits;
  }

  test('when the plan is over', () {
    expect(readyPlanEnded(_a(DateTime(2027, 1)), ttc, now), isFalse);
    expect(readyPlanEnded(_a(DateTime(2026, 10)), ttc, now), isTrue,
        reason: 'her month has come (also "We have started trying")');
    expect(readyPlanEnded(_a(DateTime(2026, 8)), ttc, now), isTrue);
    expect(readyPlanEnded(_a(DateTime(2027, 1)), LifeStage.pregnancy, now),
        isTrue);
    expect(
        readyPlanEnded(_a(DateTime(2027, 1))..alreadyTrying = true, ttc, now),
        isTrue);
    expect(readyPlanEnded(null, ttc, now), isFalse);
  });

  test('before her month, everything she turned on stays on', () async {
    final a = _a(DateTime(2027, 1));
    final habits = await allOn(a);
    await store.applyFor(a, ttc, now);
    expect(habits.every(store.reminds), isTrue);
    expect(store.weekly, isTrue);
    expect(store.retired, isFalse);
  });

  test('her month: everything stops once, folic acid keeps going', () async {
    final a = _a(DateTime(2026, 10));
    final habits = await allOn(a);
    await store.applyFor(a, ttc, now);
    for (final h in habits) {
      expect(store.reminds(h), h.id == 'folic', reason: h.id);
    }
    expect(store.weekly, isFalse);
    expect(store.retired, isTrue);

    // Her choice after the stop sticks: the next launch does not undo it.
    final move = habits.firstWhere((h) => h.id == 'move');
    await store.setRemind(move, true);
    await store.applyFor(a, ttc, now, arm: true);
    expect(store.reminds(move), isTrue);
  });

  test('pregnancy stops folic acid too (her pregnancy reminders take over)',
      () async {
    final a = _a(DateTime(2027, 1));
    final habits = await allOn(a);
    await store.applyFor(a, LifeStage.pregnancy, now);
    expect(habits.any(store.reminds), isFalse);
  });

  test('wiring: re-armed after the launch wipe, and she is told', () {
    final main = File('lib/main.dart').readAsStringSync();
    final wipe = main.indexOf('ReminderStore.instance');
    expect(wipe, greaterThan(0));
    for (final call in [
      'TtcReadyPlanStore.instance.rearmAfterStartup()',
      'TtcReadyHabitsStore.instance.rearmAfterStartup()',
    ]) {
      expect(main.indexOf(call), greaterThan(wipe), reason: call);
    }
    final week =
        File('lib/screens/ttc/ttc_ready_week.dart').readAsStringSync();
    expect(week, contains('_store.retired'));
  });
}
