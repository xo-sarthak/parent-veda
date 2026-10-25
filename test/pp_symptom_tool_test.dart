// =============================================================================
//  Is my baby OK?, one symptom tool for every age (tools pass H1-H3, 2026-10-25)
// -----------------------------------------------------------------------------
//  docs/pp-tool-plans/08-16-health.md, Wave 2. Holds: one Tools row and the
//  router aliases, the list ordered by the child's age with "Other ages" kept,
//  the age question answered from the profile, fever handed to Fever check
//  (the one fever judge) and its fixed branches, the newborn feeding check
//  under its own name with log counts only after a yes, and "ask once" before
//  anything she tells the tool is kept.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_baby_ok_check_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_changes_store.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_feeding_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_fever_check_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tools_tab.dart';
import 'package:parentveda/screens/post_pregnancy/pp_what_changed_data.dart';
import 'package:parentveda/screens/post_pregnancy/what_changed_screen.dart';
import 'package:parentveda/services/pp_use_consent.dart';

void big(WidgetTester t) {
  t.view.physicalSize = const Size(400 * 3, 3200 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.resetForTest();
    PpUseConsent.instance.debugReset();
    PpChangesStore.instance.debugReset();
    FeedingStore.instance.debugReset();
  });

  test('one Tools row, and every old id lands on the right screen', () {
    final tools = [for (final g in ppToolGroups()) ...g.tools];
    final ok = tools.where((t) => t.title == 'Is my baby OK?').toList();
    expect(ok, hasLength(1));
    expect(ok.single.surfaceId, 'pp_what_changed');
    expect(tools.where((t) => t.title == 'Something changed?'), isEmpty);
    expect(ppScreenForSurface('pp_baby_ok_check'), isA<WhatChangedScreen>());
    expect(ppScreenForSurface('pp_what_changed'), isA<WhatChangedScreen>());
    expect(ppScreenForSurface('pp_newborn_feeding'), isA<PpBabyOkCheckScreen>());
  });

  test('it knows the age: newborn things fit a newborn, tantrums a toddler', () {
    final enough = wcById('enough_milk')!;
    final tantrums = wcById('sudden_tantrums')!;
    expect(wcFitsAge(enough, 1), isTrue);
    expect(wcFitsAge(enough, 8), isFalse);
    expect(wcFitsAge(tantrums, 1), isFalse);
    expect(wcFitsAge(tantrums, 20), isTrue);
    expect(wcFitsAge(wcById('cough')!, 30), isTrue, reason: 'no age range fits every age');
  });

  testWidgets('the list: what fits first, the rest under Other ages (shown, not hidden)', (t) async {
    big(t);
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 20)));
    await t.pumpWidget(const MaterialApp(home: WhatChangedScreen()));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Is my baby OK?'), findsWidgets);
    expect(find.text('OTHER AGES'), findsOneWidget);
    expect(find.byKey(const ValueKey('wc_row_sudden_tantrums')), findsOneWidget);
    expect(find.byKey(const ValueKey('wc_row_enough_milk')), findsWidgets);
  });

  testWidgets('fever opens Fever check', (t) async {
    big(t);
    await t.pumpWidget(const MaterialApp(home: WhatChangedScreen()));
    await t.pump(const Duration(milliseconds: 600));
    final row = find.byKey(const ValueKey('wc_row_low_fever')).first;
    await t.ensureVisible(row);
    await t.tap(row);
    await t.pumpAndSettle();
    expect(find.byType(PpFeverCheckScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_fever_emergency')), findsOneWidget, reason: '112 / 108 pinned on top');
  });

  testWidgets('the age question is answered from the profile, never asked', (t) async {
    big(t);
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(const Duration(days: 300)));
    await t.pumpWidget(MaterialApp(home: WcFlowScreen(concern: wcById('separation_upset')!)));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('Roughly how old'), findsNothing);
    expect(find.text('Is it also with familiar people?'), findsOneWidget);
  });

  Future<void> walkTo(WidgetTester t, List<String> answers) async {
    for (final a in answers) {
      final opt = find.text(a).first;
      await t.ensureVisible(opt);
      await t.tap(opt);
      await t.pump();
      final next = find.byKey(const ValueKey('wc_flow_next'));
      await t.ensureVisible(next);
      await t.tap(next);
      await t.pump(const Duration(milliseconds: 300));
    }
  }

  testWidgets('ask once: nothing is kept until she says yes', (t) async {
    big(t);
    await t.pumpWidget(MaterialApp(home: WcFlowScreen(concern: wcById('cough')!)));
    await t.pump(const Duration(milliseconds: 600));
    await walkTo(t, const ['Normally, just coughing', 'A normal cold cough', 'A few days']);
    final ask = find.byKey(const ValueKey('pp_use_ask_changes'));
    await t.ensureVisible(ask);
    expect(ask, findsOneWidget);
    expect(PpChangesStore.instance.active(), isEmpty, reason: 'not kept before a yes');
    final yes = find.byKey(const ValueKey('pp_use_yes_changes'));
    await t.ensureVisible(yes);
    await t.tap(yes);
    await t.pump(const Duration(milliseconds: 300));
    expect(PpChangesStore.instance.active(), hasLength(1));
    expect(find.byKey(const ValueKey('wc_flow_keep')), findsOneWidget);
    await t.pump(const Duration(seconds: 6));
  });

  test('a no means saved changes are never read', () {
    PpChangesStore.instance.note(wcById('cough')!, WcTone.calm);
    PpUseConsent.instance.set(PpUseKind.changes, false);
    expect(PpChangesStore.instance.active(), isEmpty);
    PpUseConsent.instance.set(PpUseKind.changes, true);
    expect(PpChangesStore.instance.active(), hasLength(1));
  });

  Future<void> fever(WidgetTester t, {required int days, required String temp}) async {
    big(t);
    ChildProfileStore.instance.debugSetDob(DateTime.now().subtract(Duration(days: days)));
    await t.pumpWidget(const MaterialApp(home: PpFeverCheckScreen()));
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('None of these'));
    await t.pump();
    final opt = find.text(temp);
    await t.ensureVisible(opt);
    await t.tap(opt);
    await t.pump();
  }

  testWidgets('fever: a low reading over 3 months is no longer "not a fever"', (t) async {
    await fever(t, days: 130, temp: 'Below 36.5 C  (below 97.7 F)');
    expect(find.text('A low reading: take it again'), findsOneWidget);
    expect(find.text('That is not a fever'), findsNothing);
  });

  testWidgets('fever: under 3 months at 38 C or more is seen now, today', (t) async {
    await fever(t, days: 40, temp: '38 to 39 C  (100.4 to 102.2 F)');
    expect(find.textContaining('seen now, today'), findsOneWidget);
  });

  testWidgets('fever: the low band is listed first', (t) async {
    big(t);
    await t.pumpWidget(const MaterialApp(home: PpFeverCheckScreen()));
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('None of these'));
    await t.pump();
    final low = t.getTopLeft(find.text('Below 36.5 C  (below 97.7 F)')).dy;
    final mid = t.getTopLeft(find.text('36.5 to 38 C  (97.7 to 100.4 F)')).dy;
    expect(low, lessThan(mid));
  });

  testWidgets('the newborn check: its own name, and the feed count only after a yes', (t) async {
    big(t);
    for (var i = 0; i < 8; i++) {
      FeedingStore.instance.log(time: DateTime.now().subtract(Duration(hours: i * 2)), kind: FeedKind.breast);
    }
    await t.pumpWidget(const MaterialApp(home: PpBabyOkCheckScreen()));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Getting enough milk?'), findsWidgets);
    expect(find.textContaining('Your feed log:'), findsNothing, reason: 'not read before a yes');
    PpUseConsent.instance.set(PpUseKind.feeds, true);
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Your feed log: 8 feeds in the last 24 hours.'), findsOneWidget);
  });
}
