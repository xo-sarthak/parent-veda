// =============================================================================
//  The gentle check-in is safe at every age (tools pass 17-21, 2026-10-25)
// -----------------------------------------------------------------------------
//  The 0-6 month questions started at birth, so a two-week-old honestly got
//  "Not yet" on smiling back and turning to voices (both act-early signs), and
//  her mother read "Worth a word with your doctor". Its ages also disagreed
//  with the milestones data (sit and babble flagged at 6 months against "by
//  around 9"; words at 12 against "by about 16"). Now a question is asked from
//  [CheckInQ.askFrom] and counts as a sign only from [CheckInQ.flagFrom], and
//  those months come from the milestones' "mention it by" line.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/development_checkin_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_milestones_data.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DevStore.instance.applyCloudItems(const {});
  });
  tearDown(() => ChildProfileStore.instance.resetForTest());

  bool? Function(String) allNotYet(List<CheckInQ> qs) =>
      (t) => qs.firstWhere((q) => q.text == t).yesIsConcern ? false : false;

  test('the first weeks ask nothing; at 2 months nothing can escalate', () {
    expect(checkInsForAge(0), isEmpty);
    expect(checkInsForAge(1), isEmpty);
    final two = checkInsForAge(2);
    expect(two, isNotEmpty);
    // Every honest "not yet" at 2 months: no act-early sign is due yet, and
    // the few questions asked cannot add up to three.
    expect(checkInWorthAsking(two, allNotYet(two), months: 2), isFalse);
  });

  test('no question is asked before it is fair, nor counted before it is due', () {
    for (var m = 0; m <= 60; m++) {
      for (final q in checkInsForAge(m)) {
        expect(m, greaterThanOrEqualTo(q.askFrom), reason: '${q.text} at $m months');
        expect(q.countsFrom, greaterThanOrEqualTo(q.askFrom), reason: q.text);
      }
    }
  });

  test('a red flag counts only from its month', () {
    final smile = kCheckIns0to6.firstWhere((q) => q.text.contains('smile back'));
    bool? notYet(String t) => t == smile.text ? false : null;
    expect(checkInWorthAsking([smile], notYet, months: 2), isFalse);
    expect(checkInWorthAsking([smile], notYet, months: 3), isTrue);
  });

  test('the check-in flags no earlier than the milestones say to mention it', () {
    // The milestones' "mention it ... by around N months" month for each
    // flagged question that has a matching milestone.
    int mention(String id) {
      final m = kMilestones.firstWhere((x) => x.id == id);
      final hit = RegExp(r'by (?:around |about )?(\d+)').firstMatch(m.discuss) ??
          RegExp(r'by about two years').firstMatch(m.discuss);
      if (hit == null) fail('no month in ${m.id}: ${m.discuss}');
      return hit.groupCount >= 1 && hit.group(1) != null ? int.parse(hit.group(1)!) : 24;
    }

    final pairs = <String, String>{
      'smile back': _id((m) => m.discuss.contains('social smile')),
      'sit without': _id((m) => m.discuss.contains('sitting with support')),
      'babble strings': _id((m) => m.discuss.contains('no babbling')),
      'a few words': _id((m) => m.discuss.contains('no words at all')),
      'two words together': _id((m) => m.discuss.contains('two-word phrases')),
    };
    final all = [...kCheckIns0to6, ...kCheckIns6to12, ...kCheckIns1to2, ...kCheckIns2to3, ...kCheckIns3plus];
    pairs.forEach((words, id) {
      final q = all.firstWhere((q) => q.text.contains(words));
      expect(q.flagFrom, mention(id), reason: '"${q.text}" and milestone $id');
    });
  });

  testWidgets('a two-week-old: the early card, never "worth a word"', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 14)));
    t.view.physicalSize = const Size(360 * 3, 1800 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: DevelopmentCheckinScreen()));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('checkin_too_early')), findsOneWidget);
    expect(find.byKey(const ValueKey('checkin_result_ask')), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('a lost skill shows the result at once, before the rest', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 400)));
    t.view.physicalSize = const Size(360 * 3, 2600 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: DevelopmentCheckinScreen()));
    await t.pumpAndSettle();
    DevStore.instance.setCheckIn(kCheckInLostSkill.text, true);
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('checkin_result_ask')), findsOneWidget);
    expect(find.byKey(const ValueKey('checkin_not_a_diagnosis')), findsOneWidget);
  });

  testWidgets('start again clears the answers, and Undo brings them back', (t) async {
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 400)));
    t.view.physicalSize = const Size(360 * 3, 2600 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final q = checkInsForAge(13).first;
    DevStore.instance.setCheckIn(q.text, true);
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: DevelopmentCheckinScreen())));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('checkin_start_again')));
    await t.pumpAndSettle();
    expect(DevStore.instance.checkInAnswer(q.text), isNull);
    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect(DevStore.instance.checkInAnswer(q.text), isTrue);
  });
}

String _id(bool Function(Milestone) where) => kMilestones.firstWhere(where).id;
