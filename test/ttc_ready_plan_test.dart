// =============================================================================
//  The Ready-to-Try plan (2026-10-17)
// -----------------------------------------------------------------------------
//  What this holds, each named for the way it would go wrong:
//    · a step that names a checklist item the checklist does not have (its
//      tick would land nowhere), or a read or tool that does not open;
//    · a plan that says a dose, says she is ready, or tells her to wait;
//    · months that do not compress when her month is close, or a plan that
//      goes blank once her month has come;
//    · her answers not changing the plan (diet, conditions, age, his part);
//    · the plan being built and unreachable (the wiring gate).
//  All at 360dp for the one walk through the screen.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_nutrition_screen.dart'
    show kTtcFoodKitchenKey;
import 'package:parentveda/screens/ttc/ttc_precheck_parts.dart'
    show PrecheckTick;
import 'package:parentveda/screens/ttc/ttc_ready_plan_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/screens/ttc/ttc_tool_marks.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/focus/ttc_focus_getting_ready.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/ttc/ttc_fertility_help_store.dart';
import 'package:parentveda/ttc/ttc_focus_data.dart';
import 'package:parentveda/ttc/ttc_precheck_data.dart';
import 'package:parentveda/ttc/ttc_precheck_store.dart';
import 'package:parentveda/ttc/ttc_reads_data.dart';
import 'package:parentveda/ttc/ttc_ready_plan.dart';
import 'package:parentveda/ttc/ttc_ready_plan_regions.dart';
import 'package:parentveda/ttc/ttc_ready_plan_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_tests_data.dart';

final _now = DateTime(2026, 10, 17);

ReadyPlanAnswers _answers({
  int monthsAhead = 5,
  ReadyDiet? diet,
  ReadyRegion? region,
  Set<ReadyCondition> conditions = const {},
  FertilityAgeBand? age,
  ReadyFolic? folic,
  bool his = false,
}) {
  final a = ReadyPlanAnswers()
    ..target = DateTime(_now.year, _now.month + monthsAhead)
    ..diet = diet
    ..region = region
    ..age = age
    ..folic = folic;
  a.conditions.addAll(conditions);
  a.conditionsAnswered = conditions.isNotEmpty;
  if (his) {
    a.hisAge = HisAge.fortyOrOver;
    a.hisHabits.add(HisHabit.tobacco);
    a.hisHabitsAnswered = true;
  }
  return a;
}

/// Every plan a test below can produce, for the output-wide checks.
Iterable<ReadyPlan> _manyPlans() sync* {
  for (final ahead in [-2, 0, 1, 2, 3, 4, 6, 9]) {
    for (final diet in [null, ...ReadyDiet.values]) {
      for (final folic in [null, ...ReadyFolic.values]) {
        yield buildReadyPlan(
          _answers(
            monthsAhead: ahead,
            diet: diet,
            folic: folic,
            conditions: {ReadyCondition.pcos, ReadyCondition.thyroid},
            age: FertilityAgeBand.thirtyEightTo40,
            his: ahead.isEven,
          ),
          now: _now,
        )!;
      }
    }
  }
}

/// All the words a plan shows.
Iterable<String> _words(ReadyPlan p) sync* {
  for (final m in p.months) {
    for (final s in m.steps) {
      yield s.title;
      yield s.why;
    }
  }
  for (final s in p.thisMonth) {
    yield s.title;
    yield s.why;
  }
  for (final t in p.tests) {
    yield t.name;
    yield t.why;
    if (t.emphasis != null) yield t.emphasis!;
  }
  yield p.folicLine;
  yield* p.hisLines;
  yield* p.notes;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  group('every step, test and link lands somewhere real', () {
    final steps = <ReadyStep>{
      for (final p in _manyPlans()) ...[
        for (final m in p.months) ...m.steps,
        ...p.thisMonth,
      ],
    };

    test('every step ticks a real checklist item', () {
      for (final s in steps) {
        expect(
          precheckItemById(s.precheckId),
          isNotNull,
          reason:
              '"${s.title}" ticks "${s.precheckId}", which the '
              'checklist does not hold',
        );
      }
    });

    test('every step opens a real tool or read', () {
      for (final s in steps) {
        if (s.surfaceId != null) {
          expect(
            ttcScreenForSurface(s.surfaceId!),
            isNotNull,
            reason: '"${s.title}" opens ${s.surfaceId}',
          );
        }
        if (s.readId != null) {
          expect(
            ttcReadById(s.readId!),
            isNotNull,
            reason: '"${s.title}" opens read ${s.readId}',
          );
        }
      }
    });

    test('every test opens its library entry or its read', () {
      for (final t in buildReadyPlan(_answers(), now: _now)!.tests) {
        expect(t.testId != null || t.readId != null, isTrue, reason: t.name);
        if (t.testId != null) {
          expect(ttcTestById(t.testId!), isNotNull, reason: t.name);
        }
        if (t.readId != null) {
          expect(ttcReadById(t.readId!), isNotNull, reason: t.name);
        }
      }
    });

    test("the plan's kitchen key is the food tool's own", () {
      expect(kReadyKitchenPrefKey, kTtcFoodKitchenKey);
    });
  });

  // ===========================================================================
  group('what the plan may never say', () {
    final words = [for (final p in _manyPlans()) ..._words(p)];

    test('no dose, anywhere', () {
      final dose = RegExp(
        r'\d+\s*(mcg|mg|micrograms?|iu)\b',
        caseSensitive: false,
      );
      for (final w in words) {
        expect(dose.hasMatch(w), isFalse, reason: w);
      }
      // And every folic acid line sends the dose to her doctor.
      for (final p in _manyPlans()) {
        expect(p.folicLine, contains('Ask your doctor which dose'));
      }
    });

    test('never that she is ready, cleared, or should wait', () {
      final banned = RegExp(
        r"ready to conceive|you are ready|you're ready|cleared|"
        r'delay trying|put off trying|not ready|wait before trying',
        caseSensitive: false,
      );
      for (final w in words) {
        expect(banned.hasMatch(w), isFalse, reason: w);
      }
    });

    test('a test is worth asking about, never a must', () {
      final must = RegExp(
        // "all you need to do" is the checklist's own reassurance, kept.
        r'\byou must\b|(?<!all )\byou need to\b',
        caseSensitive: false,
      );
      for (final w in words) {
        expect(must.hasMatch(w), isFalse, reason: w);
      }
    });
  });

  // ===========================================================================
  group('the months', () {
    test('no month, or already trying, makes no plan', () {
      expect(buildReadyPlan(ReadyPlanAnswers(), now: _now), isNull);
      expect(
        buildReadyPlan(_answers()..alreadyTrying = true, now: _now),
        isNull,
      );
    });

    test('five months out: five months of steps, then her month', () {
      final p = buildReadyPlan(_answers(monthsAhead: 5), now: _now)!;
      expect(p.monthsAway, 5);
      expect(p.months, hasLength(6));
      expect(p.months.last.isTarget, isTrue);
      expect(p.months.first.month, DateTime(2026, 10));
      expect(
        p.thisMonth.map((s) => s.precheckId),
        contains('folate'),
        reason: 'folic acid starts in the first month',
      );
      expect(
        p.months[1].steps.map((s) => s.precheckId),
        contains('vaccines'),
        reason: "the vaccine with a month's wait comes early",
      );
      for (final m in p.months.where((m) => !m.isTarget)) {
        expect(m.steps, isNotEmpty, reason: 'no empty month');
      }
    });

    test(
      'one month out: the same steps, in one month; the date never moves',
      () {
        final far = buildReadyPlan(_answers(monthsAhead: 5), now: _now)!;
        final near = buildReadyPlan(_answers(monthsAhead: 1), now: _now)!;
        Set<String> ids(ReadyPlan p) => {
          for (final m in p.months)
            for (final s in m.steps) s.precheckId,
        };
        expect(ids(near), ids(far), reason: 'compressed, not cut');
        expect(near.months, hasLength(2));
        expect(near.target, DateTime(2026, 11));
      },
    );

    test('her month, or a month gone by: still a plan, never blank', () {
      for (final ahead in [0, -3]) {
        final p = buildReadyPlan(_answers(monthsAhead: ahead), now: _now)!;
        expect(p.arrived, isTrue);
        expect(
          p.thisMonth.map((s) => s.precheckId),
          containsAll(['folate', 'fertile_window']),
        );
      }
    });

    test('the count is an appointment, not a sentence', () {
      expect(readyCountLabel(5), 'in 5 months');
      expect(readyCountLabel(1), 'next month');
      expect(readyCountLabel(0), 'this month');
    });
  });

  // ===========================================================================
  group('her answers change her plan', () {
    ReadyTest testNamed(ReadyPlan p, String start) =>
        p.tests.firstWhere((t) => t.name.startsWith(start));

    test('B12 leads for a vegetarian or Jain plate, not a non-veg one', () {
      for (final d in [ReadyDiet.veg, ReadyDiet.jain, ReadyDiet.eggs]) {
        expect(
          testNamed(
            buildReadyPlan(_answers(diet: d), now: _now)!,
            'Vitamin B12',
          ).emphasis,
          isNotNull,
          reason: d.name,
        );
      }
      expect(
        testNamed(
          buildReadyPlan(_answers(diet: ReadyDiet.nonVeg), now: _now)!,
          'Vitamin B12',
        ).emphasis,
        isNull,
      );
    });

    test('PCOS puts blood sugar forward and adds the condition step', () {
      final p = buildReadyPlan(
        _answers(conditions: {ReadyCondition.pcos}),
        now: _now,
      )!;
      expect(testNamed(p, 'Blood sugar').emphasis, contains('PCOS'));
      expect(
        p.months.expand((m) => m.steps).map((s) => s.precheckId),
        contains('conditions'),
      );
    });

    test('a thyroid condition is named on the thyroid test', () {
      final p = buildReadyPlan(
        _answers(conditions: {ReadyCondition.thyroid}),
        now: _now,
      )!;
      expect(testNamed(p, 'Thyroid').emphasis, isNotNull);
    });

    test('over 35, the six-month line; under 35, none', () {
      expect(
        buildReadyPlan(
          _answers(age: FertilityAgeBand.thirtyFiveTo37),
          now: _now,
        )!.notes.join(),
        contains('six months'),
      );
      expect(
        buildReadyPlan(
          _answers(age: FertilityAgeBand.under35),
          now: _now,
        )!.notes,
        isEmpty,
      );
    });

    test('his part is general until he answers, then his', () {
      final general = buildReadyPlan(_answers(), now: _now)!;
      expect(general.hisPersonal, isFalse);
      final his = buildReadyPlan(_answers(his: true), now: _now)!;
      expect(his.hisPersonal, isTrue);
      expect(his.hisLines.join(), contains('tobacco'));
      expect(his.hisLines.join(), contains('age'));
    });

    test('the kitchen drops what is not on her plate', () {
      for (final r in ReadyRegion.values) {
        expect(kReadyKitchens[r], isNotNull, reason: r.name);
        final veg = readyFoodsFor(
          r,
          vegetarian: true,
          eggless: true,
          jain: false,
        );
        expect(veg.any((f) => f.meat || f.egg), isFalse, reason: r.name);
        final jain = readyFoodsFor(
          r,
          vegetarian: true,
          eggless: true,
          jain: true,
        );
        expect(jain.any((f) => f.root), isFalse, reason: r.name);
        expect(jain, isNotEmpty, reason: '${r.name}: an empty Jain kitchen');
      }
    });

    test('answers survive a save, and an unknown name is dropped', () {
      final a = _answers(
        diet: ReadyDiet.jain,
        region: ReadyRegion.gujarati,
        conditions: {ReadyCondition.pcos},
        age: FertilityAgeBand.under35,
        folic: ReadyFolic.notYet,
        his: true,
      );
      final back = ReadyPlanAnswers.fromJson(a.toJson());
      expect(back.toJson(), a.toJson());
      final odd = a.toJson()..['diet'] = 'pescatarian';
      expect(ReadyPlanAnswers.fromJson(odd).diet, isNull);
    });
  });

  // ===========================================================================
  group('the wiring gate: reachable, not just built', () {
    test('Getting ready carries the plan, and it opens', () {
      final tiles = [
        for (final s in kTtcGettingReadyFocus.sections) ...s.tiles,
      ].whereType<TtcToolTile>().where((t) => t.surfaceId == 'ttc_ready_plan');
      expect(tiles, hasLength(1));
      expect(ttcScreenForSurface('ttc_ready_plan'), isA<TtcReadyPlanScreen>());
      expect(ttcToolMarkForSurface('ttc_ready_plan'), TtcToolMark.precheck);
    });

    test('the door names it with the screen\'s own name', () {
      final src = File(
        'lib/ttc/focus/ttc_focus_getting_ready.dart',
      ).readAsStringSync();
      expect(src, contains("title: '$kReadyPlanName'"));
    });
  });

  // ===========================================================================
  //  The trying clock: a couple who are only planning have not started.
  // ===========================================================================
  group('the trying clock waits for the month they start', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      TtcStore.instance.resetForTest();
      await TtcReadyPlanStore.instance.load();
    });

    test('"planning" gives no start of its own', () {
      expect(ttcStartFromAnswer('planning', DateTime(2026, 10, 1)), isNull);
      expect(
        ttcStartFromAnswer('starting', DateTime(2026, 10, 1)),
        DateTime(2026, 10, 1),
      );
    });

    test(
      'a planned month is the journey start, and nothing counts before it',
      () async {
        final now = DateTime.now();
        final month = DateTime(now.year, now.month + 4);
        await TtcReadyPlanStore.instance.setPlannedStart(month);
        expect(TtcStore.instance.journeyStart, month);
        expect(
          TtcStore.instance.daysTrying,
          0,
          reason: 'the seek-help timing must not run before they try',
        );
        // Setting a month is an answer, not a plan: the home offers one.
        expect(TtcReadyPlanStore.instance.planOwed, isTrue);
        expect(TtcReadyPlanStore.instance.planFor(now), isNull);
      },
    );

    test('once her month has passed, the clock counts from it', () async {
      final now = DateTime.now();
      final month = DateTime(now.year, now.month - 2);
      await TtcReadyPlanStore.instance.setPlannedStart(month);
      expect(TtcStore.instance.daysTrying, now.difference(month).inDays);
    });

    test('"We\'re already trying" in the plan hands the clock back', () async {
      await TtcReadyPlanStore.instance.save(
        ReadyPlanAnswers()..alreadyTrying = true,
      );
      expect(TtcReadyPlanStore.instance.plannedStart, isNull);
    });

    test('onboarding and the first-run flow both offer it', () {
      expect(
        File(
          'lib/screens/auth/onboarding/onboarding_questions.dart',
        ).readAsStringSync(),
        contains("'planning',"),
      );
      final intro = File(
        'lib/screens/ttc/ttc_intro_flow.dart',
      ).readAsStringSync();
      expect(intro, contains('TtcTryingFor.planning'));
      expect(intro, contains('setPlannedStart'));
    });
  });

  // ===========================================================================
  group('the screen, at 360dp', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      CycleStore.instance.resetForTest();
      TtcStore.instance.resetForTest();
      TtcLang.instance.hinglish = false;
      TtcReadyPlanStore.instance.resetForTest();
      await TtcPrecheckStore.instance.load();
      await TtcPrecheckStore.instance.reset();
      await TtcFertilityHelpStore.instance.reset();
    });

    Future<void> tap(WidgetTester tester, Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    testWidgets('questions, then the plan, and its folic tick is the '
        "checklist's", (tester) async {
      tester.view.physicalSize = const Size(360, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: TtcReadyPlanScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'overflow at 360dp');

      // No month yet: the button says why rather than doing nothing.
      await tap(tester, find.byKey(const ValueKey('ttc_ready_plan_see')));
      expect(TtcReadyPlanStore.instance.answers, isNull);

      final month = DateTime(DateTime.now().year, DateTime.now().month + 3);
      await tap(tester, find.text(readyMonthShort(month)));
      await tap(tester, find.text('Jain'));
      await tap(tester, find.text('Gujarati'));
      await tap(tester, find.text('Not yet'));
      await tap(tester, find.byKey(const ValueKey('ttc_ready_plan_see')));

      expect(
        find.text('Trying from\n${readyMonthLabel(month)}.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull, reason: 'overflow at 360dp');
      expect(find.text('Tests to ask your doctor about'), findsOneWidget);
      expect(find.text('Jain · Gujarati'), findsOneWidget);
      expect(
        find.text(
          'He hasn\'t added his answers, so this is the general '
          'version.',
        ),
        findsOneWidget,
      );

      // "Not yet" was written through to the checklist's own item.
      expect(
        TtcPrecheckStore.instance.entryFor('folate')?.status,
        PrecheckStatus.needsAttention,
      );

      // Ticking it on the plan ticks the checklist.
      // The first row of This month is folic acid.
      await tap(tester, find.byType(PrecheckTick).first);
      expect(
        TtcPrecheckStore.instance.entryFor('folate')?.status,
        PrecheckStatus.done,
      );
    });
  });
}
