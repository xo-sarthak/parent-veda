// =============================================================================
//  Onboarding asks about the birth; a baby born early is read by corrected age
// -----------------------------------------------------------------------------
//  Gap analysis P1/P2 (Behind · Onboarding, 2026-10-07): how the baby was born,
//  born early and the weeks, who is filling it in; corrected age to 24 months
//  for development only.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/services/family_profile.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  void ageWeeks(int w) =>
      ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(Duration(days: w * 7 + 1)));

  test('born at 32 weeks: eight weeks off, for development only', () {
    final f = FamilyProfileStore.instance;
    f.setBirthDetails(mode: BirthMode.cSection, early: true, bornWeeks: 32, role: CareRole.father);
    expect(f.birthMode, BirthMode.cSection);
    expect(f.role, CareRole.father);
    ageWeeks(26); // about 6 months
    final c = ChildProfileStore.instance;
    expect(c.correctionWeeks, 8);
    expect(c.devAgeInMonths, lessThan(c.ageInMonths));
    expect(c.ageLabelWithCorrection, contains('corrected'));
  });

  test('no correction when not early, at term, or past two years', () {
    final f = FamilyProfileStore.instance;
    final c = ChildProfileStore.instance;
    f.setBirthDetails(early: false);
    ageWeeks(26);
    expect(c.correctionWeeks, isNull);
    expect(c.devAgeInMonths, c.ageInMonths);
    f.setBirthDetails(early: true, bornWeeks: 30);
    ageWeeks(110); // past 24 months
    expect(c.correctionWeeks, isNull);
  });

  test('onboarding asks the three birth questions and saves them', () {
    final src = File('lib/screens/auth/onboarding/onboarding_flow.dart').readAsStringSync();
    expect(src, contains("born? Optional"));
    expect(src, contains("born early? Optional"));
    expect(src, contains("Who are you to"));
    expect(src, contains('FamilyProfileStore.instance.setBirthDetails('));
  });

  test('vaccines and growth stay on the birthday', () {
    for (final f in [
      'lib/screens/post_pregnancy/pp_vaccine_data.dart',
      'lib/screens/post_pregnancy/pp_growth_data.dart',
    ]) {
      expect(File(f).readAsStringSync().contains('devAgeInMonths'), isFalse, reason: f);
    }
  });
}
