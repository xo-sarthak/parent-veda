// =============================================================================
//  Trust fixes from the parenting gap analysis (P1, 2026-10-02)
// -----------------------------------------------------------------------------
//  Each of these showed one family's data to every parent, or reassured
//  regardless of the facts. Nothing failed while they were wrong, which is
//  why each is pinned here.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_growth_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart';

String _live(String path) =>
    File(path).readAsStringSync().split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('vaccine reminders fall on this child\'s dates', () {
    final dob = DateTime(2026, 3, 1);
    ChildProfileStore.instance.debugSetDob(dob);
    final v = kVaxVisits.firstWhere((v) => v.id == 'mo9');
    final when = vaxVisitDate(v)!;
    final expected = dob.add(Duration(days: v.ageDays));
    expect([when.year, when.month, when.day, when.hour], [expected.year, expected.month, expected.day, 9]);
  });

  test('the Tools subtitle is computed, not "Next due in 3 weeks"', () {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 30)));
    expect(VaxStore.instance.nextVisitSubtitle, isNot('Next due in 3 weeks'));
    expect(_live('lib/screens/post_pregnancy/tools_hub_screen.dart').contains("'Next due in 3 weeks'"), isFalse);
  });

  test('You > Vaccinations opens the real tracker, not the Aarav demo', () {
    final src = _live('lib/screens/profile/pv_child_screen.dart');
    expect(src.contains('VaccinationScreen()'), isFalse);
    expect(src.contains('VaxTrackerScreen()'), isTrue);
  });

  test('growth no longer reassures whatever the number', () {
    expect(_live('lib/screens/post_pregnancy/pp_growth_data.dart').contains('comfortably within the healthy range'), isFalse);
    final store = GrowthStore.instance..resetForTest();
    final child = ChildProfileStore.instance;
    child.debugSetDob(DateTime.now().subtract(const Duration(days: 365)));
    // A one-year-old at 6.5 kg is far below the 3rd centile for either sex.
    store.log(date: DateTime.now(), weightKg: 6.5, heightCm: 74, headCm: 45.5);
    expect(store.worthShowing, contains(GrowthMetric.weight));
    expect(store.insights.first, contains('paediatrician'));
    store.resetForTest();
    // At the median: nothing flagged.
    store.log(date: DateTime.now(), weightKg: child.isBoy ? 9.6 : 8.9, heightCm: child.isBoy ? 75.7 : 74.0, headCm: child.isBoy ? 46.1 : 44.9);
    expect(store.worthShowing, isEmpty);
    store.resetForTest();
  });
}
