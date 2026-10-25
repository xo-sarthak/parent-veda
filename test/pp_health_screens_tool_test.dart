// =============================================================================
//  The Health group's own UX, Wave 3 (2026-10-25)
// -----------------------------------------------------------------------------
//  docs/pp-tool-plans/08-16-health.md, "Wave 3". Holds:
//   · Before you see the doctor: on the tool shell, no overflow at 360dp and
//     1.5x text, a visible "not a diagnosis" line, and "The last 7 days" in the
//     text a doctor receives (with "QUESTIONS TO ASK" only when there are some).
//   · Home remedies: no remedy claims an approval ("Vaidya-approved"), the five
//     avoid entries exist with the avoid verdict, hing and the garlic rub are
//     not green, and a remedy above the child's age says "Not for <name> yet"
//     (shown, not hidden).
//   · Health guide: the invented history and forecast are gone from the source.
//   · Growth: the range checks, and the grams guess.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/growth_journey_screen.dart' show ppGrowthCheck;
import 'package:parentveda/screens/post_pregnancy/health_doctor_visit_screen.dart';
import 'package:parentveda/screens/post_pregnancy/nuskhe_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_care_log_data.dart' show PpCareDay;
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_health_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_nuskhe_data.dart';
import 'package:parentveda/screens/pregnancy/preg_tool_chrome.dart' show PregToolScaffold;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.resetForTest();
  });

  group('Before you see the doctor', () {
    testWidgets('on the shell, no overflow at 360dp and 1.5x text, not-a-diagnosis line shown', (t) async {
      ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 120)));
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: const MaterialApp(home: HealthDoctorVisitScreen()),
      ));
      await t.pump(const Duration(milliseconds: 600));
      expect(find.byType(PregToolScaffold), findsOneWidget);
      expect(find.byKey(const ValueKey('pp_doctor_visit_last7')), findsOneWidget);
      expect(find.text(kPpDoctorVisitNotDiagnosis, skipOffstage: false), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    test('the shared text carries the last 7 days, and hides an empty questions heading', () {
      final day = PpCareDay(DateTime.now())
        ..feeds = 7
        ..wet = 6;
      final text = ppDoctorVisitShareText(days: [day]);
      expect(text, contains('THE LAST 7 DAYS'));
      expect(text, contains('Feeds: 7.0'));
      expect(text, contains(kPpDoctorVisitNotDiagnosis));
      if (HealthStore.instance.questions.isEmpty) {
        expect(text, isNot(contains('QUESTIONS TO ASK')));
      }
    });

    test('symptoms sort newest first; an undated one keeps its place after', () {
      const list = [
        SymptomEntry('Rash', '3 Jan 2026', ''),
        SymptomEntry('Cough', 'sometime', ''),
        SymptomEntry('Fever', '12 Jun 2026', ''),
      ];
      expect(ppSymptomsNewestFirst(list).map((s) => s.name).toList(), ['Fever', 'Rash', 'Cough']);
    });
  });

  group('Home remedies', () {
    test('no remedy claims an approval that does not exist', () {
      for (final r in kRemedies) {
        expect(r.pillLabel, isNot('Vaidya-approved'), reason: r.id);
      }
    });

    test('the five avoid entries exist with the avoid verdict', () {
      for (final id in const [
        'avoid_janam_ghutti',
        'avoid_kajal_surma',
        'avoid_oil_ears_nose',
        'avoid_gripe_water',
        'avoid_honey_under_one',
      ]) {
        final r = remedyById(id);
        expect(r, isNotNull, reason: id);
        expect(r!.verdict, NuskheVerdict.avoid, reason: id);
        expect(r.pillLabel, 'Avoid', reason: id);
        expect(r.redFlags, isNotEmpty, reason: id);
        expect(r.whenToUse, isNotEmpty, reason: '$id says what to do instead');
      }
    });

    test('hing and the garlic rub are not green, and hing is not promoted', () {
      for (final id in const ['hing_paste', 'mustard_garlic_rub']) {
        final r = remedyById(id)!;
        expect(r.verdict, isNot(NuskheVerdict.helps), reason: id);
        expect(r.isCaution, isTrue, reason: id);
      }
      expect(remedyById('hing_paste')!.popular, isFalse);
      expect(remedyById('ajwain_potli')!.ageWarning, contains('Burn'));
    });

    testWidgets('a remedy above the child\'s age says "Not for <name> yet", and is still shown', (t) async {
      ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 60)));
      t.view.physicalSize = const Size(360 * 3, 2400 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: NuskheScreen()));
      await t.pumpAndSettle();
      final gated = popularRemedies.firstWhere((r) => r.notYetFor(ChildProfileStore.instance.ageInMonths));
      expect(find.byKey(ValueKey('nuskhe_row_${gated.id}'), skipOffstage: false), findsOneWidget);
      expect(find.byKey(ValueKey('nuskhe_not_yet_${gated.id}'), skipOffstage: false), findsOneWidget);
      expect(find.textContaining('Not for', skipOffstage: false), findsWidgets);
      expect(t.takeException(), isNull);
    });
  });

  test('the health guide no longer invents a history or a forecast', () {
    final src = File('lib/screens/post_pregnancy/health_guide_screen.dart').readAsStringSync();
    expect(src, isNot(contains('forecast next week')));
    // The invented lines survive only as comments, kept for revert.
    for (final line in src.split('\n')) {
      final code = line.trimLeft();
      if (code.startsWith('//')) continue;
      expect(code, isNot(contains('Dr. Ananya Rao')), reason: line);
      expect(code, isNot(contains('Last winter')), reason: line);
    }
  });

  test('growth range checks: a calm line, and grams read as grams', () {
    expect(ppGrowthCheck(weightKg: 6.4, heightCm: 63), isNull);
    expect(ppGrowthCheck(weightKg: 3400, heightCm: 50), 'That looks like grams. Did you mean 3.4 kg?');
    expect(ppGrowthCheck(weightKg: 0.1, heightCm: 50), contains('between 0.3 and 40 kg'));
    expect(ppGrowthCheck(weightKg: 6, heightCm: 200), contains('between 30 and 130 cm'));
    expect(ppGrowthCheck(weightKg: 6, heightCm: 60, headCm: 80), contains('between 25 and 60 cm'));
    expect(ppGrowthCheck(weightKg: null, heightCm: 60), isNotNull);
  });
}
