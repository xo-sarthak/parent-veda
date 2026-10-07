// =============================================================================
//  Vaccines: which schedule, and the day it was given (gap analysis P1)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart';
import 'package:parentveda/screens/post_pregnancy/vax_tracker_screen.dart';
import 'package:parentveda/services/family_profile.dart';

VaxVisit _v(String id) => kVaxVisits.firstWhere((v) => v.id == id);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('government schedule: a private-only visit is optional, never next', () {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 740)));
    final store = VaxStore.instance;
    FamilyProfileStore.instance.setVaxSchedule(VaxSchedule.uip);
    expect(store.isOptionalVisit(_v('yr2')), isTrue, reason: 'typhoid + hep A');
    expect(store.isOptionalVisit(_v('mo12')), isFalse, reason: 'PCV is government too');
    expect(store.nextVisit?.id, isNot('yr2'));
    FamilyProfileStore.instance.setVaxSchedule(VaxSchedule.iap);
    expect(store.isOptionalVisit(_v('yr2')), isFalse);
  });

  test('the day it was given is kept, and cleared when unticked', () {
    final store = VaxStore.instance;
    store.markDone('wk6', on: DateTime(2026, 8, 10, 15));
    expect(store.givenOn('wk6'), DateTime(2026, 8, 10));
    store.markNotDone('wk6');
    expect(store.givenOn('wk6'), isNull);
  });

  testWidgets('the tracker on a 360 phone at 1.5x text: schedule, next visit, every visit', (tester) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 50)));
    tester.view.physicalSize = const Size(360 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MaterialApp(home: VaxTrackerScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Which schedule does your paediatrician follow?'), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_vax_schedule_VaxSchedule.uip')), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('pp_vax_mark_given')), 200);
    expect(find.byKey(const ValueKey('pp_vax_mark_given')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
