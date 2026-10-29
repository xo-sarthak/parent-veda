// =============================================================================
//  T3, TTC getting ready (tools pass, 2026-10-29)
// -----------------------------------------------------------------------------
//  Pins the findings T3 fixed (docs/preg-ttc-tool-plans/T3-getting-ready.md):
//  the clinical lines (W1-W3, W10, W15), the one age rule across three
//  screens (W9, K1), the privacy rule shared by Can I and stage search (W4),
//  the Jain plate (W5), the food tool's one name (W6), the plan's habit and
//  reminder (W7, W8), whose supplement it is on his phone (W11), folic acid
//  from both lists (W12), the second varicella dose (W13, W14), and the
//  smaller K items that change behaviour (K5, K8, K12, K14).
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/family_profile.dart' show DietPreference;
import 'package:parentveda/screens/ttc/ttc_can_i_screen.dart';
import 'package:parentveda/screens/ttc/ttc_nutrition_screen.dart';
import 'package:parentveda/screens/ttc/ttc_stage_search.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart'
    show kTtcHisToolIds;
import 'package:parentveda/ttc/ttc_author.dart';
import 'package:parentveda/ttc/ttc_can_i_data.dart';
import 'package:parentveda/ttc/ttc_content_prefs.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/ttc/ttc_lookup_reads.dart';
import 'package:parentveda/ttc/ttc_meal_week_data.dart';
import 'package:parentveda/ttc/ttc_precheck_data.dart';
import 'package:parentveda/ttc/ttc_precheck_rules.dart';
import 'package:parentveda/ttc/ttc_ready_habits_store.dart';
import 'package:parentveda/ttc/ttc_ready_plan.dart';
import 'package:parentveda/ttc/ttc_supplements_store.dart';
import 'package:parentveda/ttc/ttc_vaccine_store.dart';
import 'package:parentveda/ttc/ttc_vaccines_data.dart';

final _now = DateTime(2026, 10, 29);

PrecheckContext _ctx({int? daysTrying, FertilityAgeBand? age}) =>
    PrecheckContext(
      loggedCycles: 0,
      cyclesLookIrregular: false,
      ranPcosCheck: false,
      pcosLevelAtLeastDiscuss: false,
      medicineCount: 0,
      supplementCount: 0,
      takesFolate: false,
      vaccinesRecorded: 0,
      liveVaccineOutstanding: false,
      daysTrying: daysTrying,
      ageBand: age,
    );

ReadyPlan _plan({FertilityAgeBand? age, bool clinic = false}) {
  final a = ReadyPlanAnswers()
    ..target = DateTime(_now.year, _now.month + 5)
    ..age = age;
  return buildReadyPlan(a, now: _now, clinicTiming: clinic)!;
}

/// A source file's lines without its `//` comments, which keep the old
/// words for revert on purpose.
List<String> _live(String path) => [
      for (final l in File(path).readAsLinesSync())
        if (!l.trimLeft().startsWith('//')) l,
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ===========================================================================
  group('W1, W2, W3, W10, W15: the clinical lines', () {
    test('alcohol is none while trying', () {
      final e = ttcCanIById('alcohol')!;
      expect(e.verdict, TtcVerdict.avoid);
      expect(e.limitEn, isNull);
      expect(e.indianEn.toLowerCase(), isNot(contains('as normal')));
      // The Hindi side said the same wrong thing, so English shows.
      expect(e.short(true), e.shortEn);
    });

    test('one fish list, with king mackerel to avoid, in Can I and food', () {
      expect(kTtcFishLine, contains('Avoid shark, swordfish'));
      expect(kTtcFishLine, contains('king mackerel'));
      expect(ttcCanIById('fish')!.indianEn, kTtcFishLine);
      expect(kTtcNonVegNote, contains(kTtcFishLine));
    });

    test('the tobacco answer gives the quitline, not Tele-MANAS', () {
      final v = ttcCanIById('vaping')!;
      expect(v.indianEn, isNot(contains('Tele-MANAS')));
      expect(v.indianEn, contains('1800-11-2356'));
    });

    test('the checklist caffeine line says under 200 mg', () {
      final what = precheckItemById('caffeine')!.whatToDo.en;
      expect(what, contains('200 mg'));
      expect(what, isNot(contains('two to three cups')));
    });

    test('Hep B immunity is anti-HBs', () {
      final h = ttcVaccineById('hepb')!.howChecked.en;
      expect(h, contains('anti-HBs'));
      expect(kTtcVaccineAsks.join(' '), contains('anti-HBs'));
    });

    test('no lubricant answer suggests coconut oil', () {
      expect(ttcCanIById('lubricant')!.indianEn.toLowerCase(),
          isNot(contains('coconut')));
    });
  });

  // ===========================================================================
  group('W4: one hide rule for Can I and stage search', () {
    test('with hideIntimate on, search finds no sex_frequency', () async {
      final q = ttcCanIById('sex_frequency')!.questionEn;
      await TtcContentPrefs.instance.setHideIntimate(false);
      expect(
          ttcStageSearch(q, perKind: 20)
              .where((h) => h.kind == TtcStageHitKind.canI)
              .map((h) => h.title),
          contains(q),
          reason: 'found while the switch is off');
      await TtcContentPrefs.instance.setHideIntimate(true);
      expect(
          ttcStageSearch(q, perKind: 20)
              .where((h) => h.kind == TtcStageHitKind.canI)
              .map((h) => h.title),
          isNot(contains(q)));
      await TtcContentPrefs.instance.setHideIntimate(false);
    });

    test('the helper is the screen rule', () {
      final sex = ttcCanIById('sex_frequency')!;
      expect(ttcCanIShown(sex, hideIntimate: true), isFalse);
      expect(ttcCanIShown(sex, hideIntimate: false), isTrue);
      expect(ttcCanIShown(ttcCanIById('chai')!, hideIntimate: true), isTrue);
    });
  });

  // ===========================================================================
  group('W5, W6: the food tool', () {
    test('every Jain dish that names onion gets a swap', () {
      for (final m in kTtcPlanMeals) {
        final dish = m.dishFor(TtcKitchen.jain);
        if (dish.toLowerCase().contains('onion')) {
          expect(ttcJainSwapFor(dish), isNotNull, reason: dish);
        }
      }
    });

    test('no TTC read or journey calls the food tool a meal plan', () {
      for (final path in [
        'lib/ttc/reads/ttc_reads_meal_plan.dart',
        'lib/ttc/reads/ttc_reads_pcos.dart',
        'lib/data/journeys/ttc_journeys.dart',
      ]) {
        final lines = _live(path);
        for (var i = 0; i < lines.length; i++) {
          if (!lines[i].contains("surfaceId: 'ttc_nutrition'")) continue;
          final step = lines
              .sublist(i < 6 ? 0 : i - 6, i)
              .join(' ')
              .toLowerCase();
          expect(step, isNot(contains('meal plan')), reason: '$path:$i');
        }
      }
    });
  });

  // ===========================================================================
  group('W7, W8: the Ready plan', () {
    test('the folic acid habit opens Supplements', () {
      final folic = readyHabitsFor(ReadyPlanAnswers())
          .firstWhere((h) => h.id == 'folic');
      expect(folic.surfaceId, 'ttc_supplements');
    });

    test('the weekly reminder names no number', () {
      final body = TtcReadyHabitsStore.weeklyReminder.body.toLowerCase();
      for (final n in ['three', 'four', 'five', '3', '4', '5']) {
        expect(RegExp('\\b$n\\b').hasMatch(body), isFalse, reason: body);
      }
    });

    test('K5: a clinic couple is not told to learn their fertile days', () {
      bool hasWindow(ReadyPlan p) => [
            for (final m in p.months) ...m.steps,
            ...p.thisMonth,
          ].any((s) => s.title == 'Learn your fertile days');
      expect(hasWindow(_plan()), isTrue);
      expect(hasWindow(_plan(clinic: true)), isFalse);
    });
  });

  // ===========================================================================
  group('W9 and K1: one age rule across plan, checklist and doctor check', () {
    final cases = <(String, FertilityAgeBand)>[
      ('34', FertilityAgeBand.under35),
      ('35', FertilityAgeBand.thirtyFiveTo37),
      ('41', FertilityAgeBand.over40),
    ];
    Set<String> fired(FertilityAgeBand age, int days) => {
          for (final r in firedRules(
              FertilityHelpContext(ageBand: age, daysTrying: days)))
            r.id,
        };
    bool doctorSays(FertilityAgeBand age, int days) => fired(age, days)
        .intersection({'twelve_months', 'age_at_presentation', 'age_forty'})
        .isNotEmpty;

    for (final (label, age) in cases) {
      for (final days in [0, 182, 365]) {
        test('age $label, $days days: checklist agrees with the doctor check',
            () {
          expect(_ctx(daysTrying: days, age: age).pastTimeToAsk,
              doctorSays(age, days));
        });
      }
    }

    test('K1: 35 and over after six months surfaces "when to ask for help"',
        () {
      final c = _ctx(daysTrying: 182, age: FertilityAgeBand.thirtyFiveTo37);
      final item = precheckItemById('when_to_seek_help')!;
      expect(precheckEvidenceFor(item, c)!.en, contains('six months'));
      expect(
          precheckPriorities(c, (_) => PrecheckStatus.untouched)
              .map((p) => p.item.id),
          contains('when_to_seek_help'));
      // Under 35 at six months: not yet.
      expect(
          precheckEvidenceFor(
              item, _ctx(daysTrying: 182, age: FertilityAgeBand.under35)),
          isNull);
    });

    test('the plan notes say 35 or over, and before trying over 40', () {
      expect(_plan(age: FertilityAgeBand.under35).notes.join(' '),
          isNot(contains('six months')));
      expect(_plan(age: FertilityAgeBand.thirtyFiveTo37).notes.join(' '),
          contains('35 or over, six months'));
      expect(_plan(age: FertilityAgeBand.over40).notes.join(' '),
          contains('before you start trying'));
    });

    test('the checklist text gives the same three thresholds', () {
      final why = precheckItemById('when_to_seek_help')!.why.en;
      expect(why, contains("under 35"));
      expect(why, contains("35 or over"));
      expect(why, contains('over 40'));
      expect(why, isNot(contains('36')));
    });
  });

  // ===========================================================================
  group('W11: whose supplement, on his phone', () {
    setUp(() => TtcSupplementsStore.instance.resetForTest());

    Map<String, dynamic> row(String id, String owner, bool forPartner) => {
          'id': id,
          'user_id': owner,
          'for_partner': forPartner,
          'name': 'Folic acid',
          'dose': '',
          'updated_at': '2026-10-29T00:00:00Z',
          'removed_at': null,
        };

    test('a row she wrote for herself reads as the partner\'s on his phone',
        () {
      final store = TtcSupplementsStore.instance;
      store.applyCloudRows([row('ttcs_1', 'her', false)], const [], me: 'him');
      expect(store.items.single.author, TtcAuthor.partner);
    });

    test('a row she wrote for him reads as his own on his phone', () {
      final store = TtcSupplementsStore.instance;
      store.applyCloudRows([row('ttcs_2', 'her', true)], const [], me: 'him');
      expect(store.items.single.author, TtcAuthor.me);
    });

    test('on her own phone nothing changes', () {
      expect(TtcSupplementsStore.authorOf(row('a', 'her', false), 'her'),
          TtcAuthor.me);
      expect(TtcSupplementsStore.authorOf(row('a', 'her', true), 'her'),
          TtcAuthor.partner);
    });

    test('K8: Supplements is on his Tools tab', () {
      expect(kTtcHisToolIds, contains('supplements'));
    });
  });

  // ===========================================================================
  group('W12: folic acid from both lists, never self-ticked', () {
    test('the folate item never ticks from records', () {
      expect(kPrecheckFromRecords, isNot(contains('folate')));
    });

    test('the context reads Medication as well as Supplements', () {
      final src = File('lib/ttc/ttc_precheck_rules.dart').readAsStringSync();
      expect(src, contains('MedicineStore.instance.all) m.name'));
    });
  });

  // ===========================================================================
  group('W13, W14: the second varicella dose', () {
    final store = TtcVaccineStore.instance;
    setUp(() => store.resetForTest());

    test('dose 1 only is "dose 2 due", not clear to try', () async {
      final d1 = DateTime.now().subtract(const Duration(days: 10));
      await store.set('varicella', TtcVaccineStatus.done, on: d1);
      final v = ttcVaccineById('varicella')!;
      expect(store.secondDoseOwed.map((e) => e.id), ['varicella']);
      expect(store.secondDoseDueFrom(v),
          d1.add(const Duration(days: TtcVaccine.doseGapDays)));
      expect(store.clearToTryFrom(), isNull,
          reason: 'no wait is counted until the course is done');
    });

    test('even long after dose 1, it is not clear with dose 2 owed', () async {
      await store.set('varicella', TtcVaccineStatus.done,
          on: DateTime.now().subtract(const Duration(days: 200)));
      expect(store.secondDoseOwed, isNotEmpty);
    });

    test('the wait counts from dose 2', () async {
      final d1 = DateTime.now().subtract(const Duration(days: 30));
      final d2 = DateTime.now().subtract(const Duration(days: 2));
      await store.set('varicella', TtcVaccineStatus.done, on: d1);
      await store.setSecondDose('varicella', d2);
      expect(store.secondDoseOwed, isEmpty);
      expect(store.clearToTryFrom(), d2.add(const Duration(days: 28)));
    });

    test('clearing dose 1 clears dose 2', () async {
      await store.set('varicella', TtcVaccineStatus.done,
          on: DateTime.now().subtract(const Duration(days: 30)));
      await store.setSecondDose('varicella', DateTime.now());
      await store.set('varicella', TtcVaccineStatus.unknown);
      expect(store.secondDoseOn('varicella'), isNull);
    });

    test('the cloud round-trip carries <id>_2', () async {
      final d1 = DateTime(2026, 9, 1);
      final d2 = DateTime(2026, 9, 29);
      await store.set('varicella', TtcVaccineStatus.done, on: d1);
      await store.setSecondDose('varicella', d2);
      final items = jsonDecode(jsonEncode(store.cloudItems()))
          as Map<String, Object?>;
      expect(items.keys, containsAll(['v|varicella', 'v|varicella_2']));
      store.resetForTest();
      store.applyCloudItems(items);
      expect(store.doneOn('varicella'), d1);
      expect(store.secondDoseOn('varicella'), d2);
    });

    test('W13: the wait line names an outstanding varicella', () {
      final src = File('lib/screens/ttc/ttc_vaccines_screen.dart')
          .readAsStringSync();
      expect(src, contains(r'$outstandingNames still needs doing.'));
    });
  });

  // ===========================================================================
  group('K12: the food tool reads her', () {
    test('a vegetarian profile opens on the no-eggs kitchen', () {
      expect(ttcKitchenForDiet(DietPreference.vegetarian), TtcKitchen.noEggs);
      expect(ttcKitchenForDiet(DietPreference.jain), TtcKitchen.jain);
      expect(ttcDietForKitchen(TtcKitchen.noEggs, DietPreference.vegan),
          DietPreference.vegan);
    });

    test('Today shows her swapped idea', () async {
      final rotation = ttcPickForToday(ttcNutrition, now: _now, offset: 1);
      final other = ttcNutrition.firstWhere((n) => n.id != rotation.id);
      SharedPreferences.setMockInitialValues({
        kTtcFoodSwapsKey: jsonEncode({ttcFoodDayKey(_now): other.id}),
      });
      expect((await ttcFoodIdeaToday(now: _now)).id, other.id);
      SharedPreferences.setMockInitialValues({});
      expect((await ttcFoodIdeaToday(now: _now)).id, rotation.id);
    });

    test('the folate idea says food does not replace the tablet', () {
      final f = ttcNutrition.firstWhere((n) => n.id == 'folate_greens');
      expect(f.whyEn, contains('does not replace'));
    });
  });

  // ===========================================================================
  group('K14: Can I on a clinic cycle', () {
    bool hasClinicLine(String id, {required bool clinic}) =>
        ttcCanIAsRead(ttcCanIById(id)!, clinicCycle: clinic)
            .sections
            .any((s) => s.tip?.body.en == kTtcCanIClinicFirstLine);

    test('the exercise answer opens with the clinic line', () {
      expect(hasClinicLine('exercise', clinic: true), isTrue);
      expect(hasClinicLine('exercise', clinic: false), isFalse);
      expect(hasClinicLine('chai', clinic: true), isFalse);
    });

    test('short answers fit three lines, so nothing is cut', () {
      for (final e in ttcCanI) {
        expect(e.shortEn.length, lessThanOrEqualTo(130), reason: e.id);
      }
    });
  });
}
