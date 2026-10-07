// =============================================================================
//  "Boy or girl" left unanswered is not a boy (gap analysis P1, 2026-10-07)
// -----------------------------------------------------------------------------
//  Onboarding saved a skipped answer as `isBoy: true`, and every parenting
//  page then said "him". The child now carries `sexGiven`; the pronoun getters
//  fall back to the name (or "your baby"), the cloud row never names the new
//  column before its migration runs, and an older local cache reads as given.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';

Child _child({bool sexGiven = true, bool isBoy = true, String name = 'Meera'}) => Child(
      id: 'c1',
      name: name,
      isBoy: isBoy,
      dob: DateTime(2026, 6, 29),
      weightKg: 0,
      heightCm: 0,
      headCm: 0,
      sexGiven: sexGiven,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => ChildProfileStore.instance.resetForTest());

  test('local JSON round-trips sexGiven, and an old cache reads as given', () {
    final j = _child(sexGiven: false).toJson();
    expect(Child.fromJson(j).sexGiven, isFalse);
    j.remove('sexGiven');
    expect(Child.fromJson(j).sexGiven, isTrue);
  });

  test('the cloud row does not name sex_given until the migration flag flips', () {
    final row = _child(sexGiven: false).toRow();
    expect(row.containsKey('sex_given'), kChildSexGivenColumn);
    expect(Child.fromRow({'id': 'c1', 'name': 'Meera', 'is_boy': true, 'dob': '2026-06-29'}).sexGiven, isTrue);
    expect(Child.fromRow({'id': 'c1', 'name': 'Meera', 'is_boy': true, 'sex_given': false, 'dob': '2026-06-29'}).sexGiven,
        isFalse);
  });

  test('pronouns use the name when the sex was not given', () {
    final s = ChildProfileStore.instance;
    s.debugSetDob(DateTime(2026, 6, 29));
    s.active
      ..name = 'Meera'
      ..sexGiven = false;
    expect([s.they, s.their, s.them, s.theyCap, s.theirCap, s.sexLabel],
        ['Meera', "Meera's", 'Meera', 'Meera', "Meera's", 'Not given']);
    s.active
      ..sexGiven = true
      ..isBoy = false;
    expect([s.they, s.their, s.them, s.theyCap, s.sexLabel], ['she', 'her', 'her', 'She', 'Girl']);
  });

  test('with no name yet, the fallback is "your baby", lower case mid-sentence', () {
    final s = ChildProfileStore.instance;
    s.debugSetDob(DateTime(2026, 6, 29));
    s.active
      ..name = Child.placeholder
      ..sexGiven = false;
    expect(s.they, 'your baby');
    expect(s.their, "your baby's");
    expect(s.theyCap, 'Your baby');
  });

  test('onboarding stores a skipped answer as not given', () {
    final src = File('lib/screens/auth/onboarding/onboarding_flow.dart').readAsStringSync();
    expect('sexGiven: _childIsBoy != null'.allMatches(src).length, 2);
  });

  test('a migration exists for the column the flag waits on', () {
    expect(File('supabase/migrations/0093_children_sex_given.sql').readAsStringSync(), contains('sex_given'));
  });
}
