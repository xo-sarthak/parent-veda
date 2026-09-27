// His side of trying to conceive on the home that ships (2026-09-27).
//
// On V3 he saw HER home: her symptoms button, her Sex log, her nine doors. Only
// V1's Today checked `TtcPartnerMode`. These hold the fix and the shape the user
// asked for: the hero and today's insights stay, her doors and her private
// actions do not, and his one door is his own.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_learn_screen.dart'
    show kTtcHisLearnFirst, ttcLearnTopics;
import 'package:parentveda/screens/ttc/ttc_partner_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';

Future<void> pumpTall(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1200, 7000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcJournalStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    TtcPartnerMode.instance.on = true;
  });
  tearDown(() => TtcPartnerMode.instance.on = false);

  test('the V3 home sends him to his own Today', () {
    final src =
        File('lib/screens/ttc/ttc_home_version.dart').readAsStringSync();
    expect(src, contains('if (TtcPartnerMode.instance.on)'));
    expect(src, contains('const TtcPartnerTodayScreen()'));
  });

  testWidgets('his Today: his insights, his one door, none of her actions',
      (tester) async {
    await pumpTall(tester, const TtcPartnerTodayScreen());
    expect(tester.takeException(), isNull);
    expect(find.text('FOR YOU TODAY'), findsOneWidget);
    expect(find.byKey(const ValueKey('ttc_partner_his_door')), findsOneWidget);
    // Her private quick actions and her door grid are not on his home.
    for (final hers in ['Symptoms', 'Sex', 'Start anywhere', 'Fertile window']) {
      expect(find.text(hers), findsNothing, reason: hers);
    }
  });

  test('his Tools: his and shared tools only, never her private logs', () {
    final his = [
      for (final g in ttcToolGroupsFor(him: true))
        for (final t in g.tools) t.id
    ];
    expect(his.toSet(), kTtcHisToolIds);
    for (final hers in ['cycle', 'symptoms', 'weight', 'pcos_check', 'mood']) {
      expect(his, isNot(contains(hers)), reason: hers);
    }
    for (final id in kTtcHisToolsStartIds) {
      expect(kTtcHisToolIds, contains(id));
    }
    // Search keeps to his set too.
    expect(ttcToolsMatching('symptom', false, him: true), isEmpty);
    expect(ttcToolsMatching('symptom', false), isNotEmpty);
    // His headings speak from his side: her window is not "Your body".
    final windowGroup = ttcToolGroupsFor(him: true)
        .firstWhere((g) => g.tools.any((t) => t.id == 'window'));
    expect(windowGroup.titleEn, 'Her cycle');
    // Hers is untouched.
    expect(ttcToolGroupsFor(him: false), same(ttcToolGroups));
  });

  test('his Learn: his own door leads the topics, hers keep their order', () {
    final his = ttcLearnTopics(him: true).map((x) => x.bracket.id).toList();
    final hers = ttcLearnTopics(him: false).map((x) => x.bracket.id).toList();
    expect(his.take(2), kTtcHisLearnFirst);
    expect(his.toSet(), hers.toSet());
    expect(hers.first, isNot('ttc_male_fertility'));
  });
}
