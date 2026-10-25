// =============================================================================
//  You, Maa: two questions, no score, nothing saved, crisis pinned (gap P2)
//  Tools 25-28 (2026-10-25): four questions (two on worry, D1), somewhere to go
//  after a yes, and "Remind me in two weeks" that keeps only a date (D2).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_mood_check_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/products/pv_store_chrome.dart' show PvSecondary;

Future<void> _pump(WidgetTester t, {double height = 2200}) async {
  t.view.physicalSize = Size(360 * 3, height * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(const MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
      child: MaterialApp(home: PpMoodCheckScreen())));
  await t.pumpAndSettle();
}

Future<void> _tap(WidgetTester t, String key) async {
  final f = find.byKey(ValueKey(key));
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the crisis path is there before any answer', (t) async {
    await _pump(t);
    expect(find.byKey(const ValueKey('pp_mood_crisis')), findsOneWidget);
    expect(find.textContaining('14416'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('one yes: talk to your doctor, never a number', (t) async {
    await _pump(t);
    await _tap(t, 'pp_mood_q0_yes');
    await _tap(t, 'pp_mood_q1_no');
    await _tap(t, 'pp_mood_q2_no');
    await _tap(t, 'pp_mood_q3_no');
    expect(find.byKey(const ValueKey('pp_mood_talk')), findsOneWidget);
    expect(find.textContaining(RegExp(r'\d+ ?(/|out of|points|score)')), findsNothing);
    // Somewhere to go (2026-10-25), and the page that fits what she said.
    expect(find.byKey(const ValueKey('pp_mood_help')), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_mood_read_low')), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_mood_read_worry')), findsNothing);
  });

  testWidgets('a yes on worry alone: talk to someone, and the anxiety page', (t) async {
    await _pump(t);
    expect(kPpMoodQuestions, hasLength(4));
    await _tap(t, 'pp_mood_q0_no');
    await _tap(t, 'pp_mood_q1_no');
    await _tap(t, 'pp_mood_q2_yes');
    await _tap(t, 'pp_mood_q3_no');
    expect(find.byKey(const ValueKey('pp_mood_talk')), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_mood_help')), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_mood_read_worry')), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_mood_read_low')), findsNothing);
  });

  testWidgets('all no: thank you, come back any time; no help row', (t) async {
    await _pump(t);
    for (var i = 0; i < 4; i++) {
      await _tap(t, 'pp_mood_q${i}_no');
    }
    expect(find.byKey(const ValueKey('pp_mood_ok')), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_mood_help')), findsNothing);
  });

  testWidgets('remind me in two weeks keeps only a date, and can be cancelled', (t) async {
    // Four questions at 1.5x text run past 2200: a taller phone for the foot.
    await _pump(t, height: 3400);
    for (var i = 0; i < 4; i++) {
      await _tap(t, 'pp_mood_q${i}_no');
    }
    // The foot sits under the shell's bottom inset in a test window, so the
    // button's own callback is called rather than a screen tap.
    t.widget<PvSecondary>(find.byKey(const ValueKey('pp_mood_remind'))).onTap!();
    await t.pump();
    await t.pump(const Duration(seconds: 5));
    expect(find.byKey(const ValueKey('pp_mood_remind_set'), skipOffstage: false), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {kPpMoodRemindAtKey}, reason: 'one key, and it is a date');
    final at = DateTime.parse(prefs.getString(kPpMoodRemindAtKey)!);
    expect(at.difference(DateTime.now()).inDays, inInclusiveRange(13, 14));
    t.widget<TextButton>(find.byKey(const ValueKey('pp_mood_remind_cancel'))).onPressed!();
    await t.pump();
    await t.pump(const Duration(seconds: 5));
    expect(prefs.getKeys(), isEmpty);
    expect(find.byKey(const ValueKey('pp_mood_remind')), findsOneWidget);
  });

  test('her answers are never saved, and it is reachable from the door', () {
    final src = File('lib/screens/post_pregnancy/pp_mood_check_screen.dart').readAsStringSync();
    final live = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
    // Was: no SharedPreferences at all. Since D2 the reminder's date lives
    // there, so the rule is now: one write, the date, and never an answer.
    expect(RegExp(r'prefs\.set\w+\(').allMatches(live).length, 1);
    expect(live, contains('prefs.setString(kPpMoodRemindAtKey, at.toIso8601String())'));
    expect(live.contains('SupabaseRepo'), isFalse);
    expect(live.contains('saveState'), isFalse);
    expect(ppScreenForSurface('pp_mood_check'), isA<PpMoodCheckScreen>());
    final door = ppDoorFor('parenting_maternal')!;
    expect(door.tabs.first.tools.map((x) => x.surfaceId), contains('pp_mood_check'));
    expect(door.tabs.first.redFlagPageId, 'you_route_scary', reason: 'the triage stays pinned');
  });
}
