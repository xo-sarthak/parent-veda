// =============================================================================
//  The care logs, as a parent meets them (gap analysis P1, Behind · Logging)
// -----------------------------------------------------------------------------
//  Nappies, the breastfeed timer, pumping, tummy time, the 7-day history, the
//  redrawn Feeding and Sleep journeys, the home strip and the wet count on
//  "Is my baby OK?". Every screen at a 360dp phone with 1.5x text; the
//  behaviours the gap analysis named; the routes; and the tummy-time table's
//  contract with its store (writes are fire-and-forget, so a column mismatch
//  would fail silently).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/feeding_journey_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_baby_ok_check_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_breast_timer_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_care_history_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_care_log_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_feeding_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_home_quick.dart';
import 'package:parentveda/screens/post_pregnancy/pp_nappy_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_pump_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/pp_tummy_time_screen.dart';
import 'package:parentveda/screens/post_pregnancy/sleep_journey_screen.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';

void _ageMonths(int months) {
  ChildProfileStore.instance
      .debugSetDob(DateTime.now().subtract(Duration(days: (months * 30.44).round() + 3)));
}

Future<void> _pump(WidgetTester tester, Widget w, {double h = 2600}) async {
  tester.view.physicalSize = Size(360, h);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: Size(360, h), textScaler: const TextScaler.linear(1.5)),
      child: w,
    ),
  ));
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NappyStore.instance.debugReset();
    PumpStore.instance.debugReset();
    TummyStore.instance.debugReset();
    BreastTimer.instance.debugReset();
    _ageMonths(2);
  });
  tearDown(() => ChildProfileStore.instance.resetForTest());

  group('every screen renders at 360dp and 1.5x text', () {
    for (final (name, screen) in [
      ('nappies', const PpNappyScreen()),
      ('timer', const PpBreastTimerScreen()),
      ('pump', const PpPumpScreen()),
      ('tummy', const PpTummyTimeScreen()),
      ('history', const PpCareHistoryScreen()),
      ('feeding journey', const FeedingJourneyScreen()),
      ('sleep journey', const SleepJourneyScreen()),
    ]) {
      testWidgets(name, (tester) async {
        await _pump(tester, screen);
        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey('preg_tool_back')), findsOneWidget, reason: 'the shared tool shell');
      });
    }
  });

  testWidgets('one tap logs a wet nappy and says so, with Undo', (tester) async {
    await _pump(tester, const PpNappyScreen());
    await tester.tap(find.byKey(const ValueKey('pp_nappy_quick_wet')));
    await tester.pump();
    expect(NappyStore.instance.wetToday, 1);
    expect(find.textContaining('Wet nappy saved'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  test('red, pale, and black after the first days are "today"', () {
    expect(ppNappyColourUrgent(NappyColour.red, ageDays: 30), isTrue);
    expect(ppNappyColourUrgent(NappyColour.pale, ageDays: 30), isTrue);
    expect(ppNappyColourUrgent(NappyColour.black, ageDays: 2), isFalse, reason: 'meconium');
    expect(ppNappyColourUrgent(NappyColour.black, ageDays: 10), isTrue);
    expect(ppNappyColourUrgent(NappyColour.green, ageDays: 10), isFalse);
    expect(kPpNappyUrgentLine, 'Show this to your doctor today. Take a photo of the nappy if you can.');
  });

  testWidgets('the details sheet shows the urgent line for red', (tester) async {
    await _pump(tester, const PpNappyScreen());
    await tester.ensureVisible(find.byKey(const ValueKey('pp_nappy_details')));
    await tester.tap(find.byKey(const ValueKey('pp_nappy_details')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pp_nappy_colour_red')));
    await tester.pump();
    expect(find.byKey(const ValueKey('pp_nappy_urgent')), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_care_when')), findsOneWidget, reason: 'a time she can change');
  });

  test('the timer writes one ordinary feed with the side it ended on', () {
    // FeedingStore has no reset; this feed is found by its own start time
    // and removed after, as pp_care_log_test does.
    final t0 = DateTime(2026, 10, 7, 3, 0);
    BreastTimer.instance.tap(TimerSide.left, now: t0);
    BreastTimer.instance.tap(TimerSide.right, now: t0.add(const Duration(minutes: 8)));
    expect(BreastTimer.instance.finish(now: t0.add(const Duration(minutes: 15))), isTrue);
    final f = FeedingStore.instance.all.firstWhere((f) => f.time == t0);
    addTearDown(() => FeedingStore.instance.remove(f.id));
    expect(f.kind, FeedKind.breast);
    expect(f.side, FeedSideX.both);
    expect(f.note, contains('ended on right'));
    if (FeedingStore.instance.all.first.id == f.id) {
      expect(ppLastSideLine(now: t0.add(const Duration(minutes: 20))), startsWith('Last side: Right'));
    }
  });

  testWidgets('"Log a feed" has a time row and Pump as a fourth choice', (tester) async {
    await _pump(tester, const FeedingJourneyScreen());
    await tester.tap(find.byKey(const ValueKey('pp_feed_log')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('pp_care_when')), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_feed_kind_pump')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pp_feed_kind_pump')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('pp_feed_left_plus')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('pp_care_save')));
    await tester.pumpAndSettle();
    expect(PumpStore.instance.mlToday, 10, reason: 'a pump session goes to the pump log');
  });

  test('tummy time: a session under ten seconds is a mis-tap; no target anywhere', () {
    expect(TummyStore.instance.log(start: DateTime.now(), seconds: 5), isFalse);
    expect(TummyStore.instance.log(start: DateTime.now(), seconds: 120), isTrue);
    expect(TummyStore.instance.secondsToday, 120);
    final src = File('lib/screens/post_pregnancy/pp_tummy_time_screen.dart').readAsStringSync().toLowerCase();
    for (final w in ['goal', 'streak', 'target:']) {
      expect(src.contains("'$w"), isFalse, reason: w);
    }
  });

  testWidgets('the home strip shows under one, and not after the first birthday', (tester) async {
    final p = V2PaletteStore.instance.current;
    await _pump(tester, Scaffold(body: PpHomeQuick(p: p, onSurface: (_) {})), h: 800);
    expect(find.byKey(const ValueKey('pp_home_search')), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_home_quick_feed')), findsOneWidget);
    expect(find.text('Search sleep, rashes, food, anything'), findsOneWidget);
    _ageMonths(14);
    await tester.pump();
    expect(find.byKey(const ValueKey('pp_home_quick_feed')), findsNothing);
    expect(find.byKey(const ValueKey('pp_home_search')), findsOneWidget, reason: 'search is for every age');
  });

  testWidgets('"Is my baby OK?" shows the wet count from the log', (tester) async {
    NappyStore.instance.log(time: DateTime.now(), kind: NappyKind.wet);
    NappyStore.instance.log(time: DateTime.now(), kind: NappyKind.mixed);
    await _pump(tester, const PpBabyOkCheckScreen(), h: 4000);
    expect(find.textContaining('2 wet in the last 24 hours'), findsOneWidget);
  });

  test('every care log is a route, and the doors and journeys reach them', () {
    for (final id in ['pp_nappies', 'pp_pump', 'pp_feed_timer', 'pp_care_history', 'pp_tummy_time', 'pp_search', 'pp_maa_can_i']) {
      expect(ppScreenForSurface(id), isNotNull, reason: id);
    }
    final feeding = File('lib/data/doors/pp_door_feeding.dart').readAsStringSync();
    for (final id in ['pp_feed_timer', 'pp_nappies', 'pp_pump', 'pp_care_history']) {
      expect(feeding, contains("surfaceId: '$id'"), reason: id);
    }
    expect(File('lib/data/doors/pp_door_development.dart').readAsStringSync(), contains("surfaceId: 'pp_tummy_time'"));
    expect(File('lib/data/doors/pp_door_sleep.dart').readAsStringSync(), contains("surfaceId: 'pp_care_history'"));
    expect(File('lib/data/doors/pp_door_first40.dart').readAsStringSync(), contains("surfaceId: 'pp_nappies'"));
    expect(File('lib/main.dart').readAsStringSync(), contains('TummyStore.instance.init()'));
  });

  test('the tummy-time table matches what the store writes', () {
    final sql = File('supabase/migrations/0094_pp_nappy_pump_tummy.sql').readAsStringSync();
    expect(sql, contains('create table public.pp_tummy_logs'));
    final row = TummyStore.toRow(TummyLog(id: 'x', time: DateTime.now(), seconds: 60));
    final block = sql.substring(sql.indexOf('create table public.pp_tummy_logs'));
    for (final col in row.keys) {
      expect(block, contains('$col '), reason: 'column $col');
    }
    expect(TummyStore.table, 'pp_tummy_logs');
    expect(sql, contains('pp_tummy_logs child insert'));
  });
}
