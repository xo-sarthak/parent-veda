// =============================================================================
//  The development check-in escalates (gap analysis P1, Behind · Health & safety)
// -----------------------------------------------------------------------------
//  "Our check-in gives six 'not yet's at 20 months the same 'these can bloom any
//  week now' as one." Now: any act-early sign not yet, a lost skill, or three
//  or more not-yets says "It is worth asking your paediatrician ... Early help
//  works best." One or two ordinary not-yets stay reassuring.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/development_checkin_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => ChildProfileStore.instance.resetForTest());

  final band = checkInsForAge(20);
  bool? Function(String) answers(Map<String, bool> m) => (t) => m[t];

  test('every band has act-early questions and ends with the lost-skill one', () {
    for (final m in [3, 8, 20, 30, 48]) {
      final qs = checkInsForAge(m);
      expect(qs.last, same(kCheckInLostSkill), reason: '$m months');
      expect(qs.where((q) => q.redFlag && !q.yesIsConcern), isNotEmpty, reason: '$m months');
    }
  });

  test('one ordinary not-yet: no escalation', () {
    final ordinary = band.firstWhere((q) => !q.redFlag);
    final m = {for (final q in band) q.text: !q.yesIsConcern};
    m[ordinary.text] = false;
    expect(checkInWorthAsking(band, answers(m)), isFalse);
  });

  test('an act-early sign not yet escalates on its own', () {
    final flag = band.firstWhere((q) => q.redFlag && !q.yesIsConcern);
    final m = {for (final q in band) q.text: !q.yesIsConcern};
    m[flag.text] = false;
    expect(checkInWorthAsking(band, answers(m)), isTrue);
  });

  test('a lost skill escalates; three ordinary not-yets escalate', () {
    final m = {for (final q in band) q.text: !q.yesIsConcern};
    m[kCheckInLostSkill.text] = true;
    expect(checkInWorthAsking(band, answers(m)), isTrue);
    final m2 = {for (final q in band) q.text: !q.yesIsConcern};
    for (final q in band.where((q) => !q.redFlag).take(3)) {
      m2[q.text] = false;
    }
    expect(checkInWorthAsking(band, answers(m2)), isTrue);
  });

  testWidgets('on screen, at 360dp and 1.5x, the worth-asking card shows', (tester) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 610)));
    ChildProfileStore.instance.active
      ..isBoy = false
      ..sexGiven = true;
    final qs = checkInsForAge(ChildProfileStore.instance.ageInMonths);
    for (final q in qs) {
      DevStore.instance.setCheckIn(q.text, q.yesIsConcern ? false : !q.redFlag);
    }
    tester.view.physicalSize = const Size(360, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(360, 3000), textScaler: TextScaler.linear(1.5)),
        child: DevelopmentCheckinScreen(),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('checkin_result_ask')), findsOneWidget);
    expect(find.textContaining('Early help works best'), findsOneWidget);
    expect(find.textContaining(RegExp(r'\b(he|his|him)\b')), findsNothing, reason: 'filled for the child');
  });
}
