// =============================================================================
//  You, Maa: two questions, no score, nothing saved, crisis pinned (gap P2)
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pp_door_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_mood_check_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';

Future<void> _pump(WidgetTester t) async {
  t.view.physicalSize = const Size(360 * 3, 2200 * 3);
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
    expect(find.byKey(const ValueKey('pp_mood_talk')), findsOneWidget);
    expect(find.textContaining(RegExp(r'\d+ ?(/|out of|points|score)')), findsNothing);
  });

  testWidgets('two no: thank you, come back any time', (t) async {
    await _pump(t);
    await _tap(t, 'pp_mood_q0_no');
    await _tap(t, 'pp_mood_q1_no');
    expect(find.byKey(const ValueKey('pp_mood_ok')), findsOneWidget);
  });

  test('nothing is saved, and it is reachable from the door', () {
    final src = File('lib/screens/post_pregnancy/pp_mood_check_screen.dart').readAsStringSync();
    final live = src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');
    expect(live.contains('SharedPreferences'), isFalse);
    expect(live.contains('SupabaseRepo'), isFalse);
    expect(ppScreenForSurface('pp_mood_check'), isA<PpMoodCheckScreen>());
    final door = ppDoorFor('parenting_maternal')!;
    expect(door.tabs.first.tools.map((x) => x.surfaceId), contains('pp_mood_check'));
    expect(door.tabs.first.redFlagPageId, 'you_route_scary', reason: 'the triage stays pinned');
  });
}
