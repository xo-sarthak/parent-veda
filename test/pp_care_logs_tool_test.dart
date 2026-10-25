// =============================================================================
//  The care logs, tools pass 02-07 (2026-10-25): docs/pp-tool-plans/02-07-care-logs.md
// -----------------------------------------------------------------------------
//  Breastfeed timer, Nappies, Pumping, Sleep, Tummy time and The last 7 days.
//  Holds: one child's logs never show for another (all five stores kept
//  every child in one list and the reads never asked whose), the timer saves
//  to the child it started for, an edit keeps the row's id, the 24-hour
//  counts, Sleep's "Asleep now", and the empty share explaining itself.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_care_history_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_care_log_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_feeding_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_sleep_data.dart';
import 'package:parentveda/screens/post_pregnancy/sleep_journey_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.resetForTest();
    FeedingStore.instance.debugReset();
    NappyStore.instance.debugReset();
    PumpStore.instance.debugReset();
    TummyStore.instance.debugReset();
    SleepStore.instance.debugReset();
    BreastTimer.instance.debugReset();
  });

  Future<(String, String)> twins() async {
    final store = ChildProfileStore.instance;
    final dob = DateTime.now().subtract(const Duration(days: 40));
    final a = await store.addChild(name: 'Aarav', isBoy: true, dob: dob);
    final b = await store.addChild(name: 'Meera', isBoy: false, dob: dob);
    await store.switchTo(a.id);
    return (a.id, b.id);
  }

  test('twins: nappies, pumping, tummy time and sleep stay with their child', () async {
    final (a, b) = await twins();
    final now = DateTime.now();
    NappyStore.instance.log(time: now, kind: NappyKind.wet);
    PumpStore.instance.log(time: now, leftMl: 60);
    TummyStore.instance.log(start: now.subtract(const Duration(minutes: 3)), seconds: 120);
    SleepStore.instance.log(start: now.subtract(const Duration(hours: 1)), end: now);

    await ChildProfileStore.instance.switchTo(b);
    expect(NappyStore.instance.all, isEmpty);
    expect(PumpStore.instance.all, isEmpty);
    expect(TummyStore.instance.all, isEmpty);
    expect(SleepStore.instance.all, isEmpty);

    await ChildProfileStore.instance.switchTo(a);
    expect(NappyStore.instance.all, hasLength(1));
    expect(SleepStore.instance.all, hasLength(1));
  });

  test('the timer saves to the child it started for, even after a switch', () async {
    final (a, b) = await twins();
    final t0 = DateTime.now().subtract(const Duration(minutes: 10));
    BreastTimer.instance.tap(TimerSide.left, now: t0);
    await ChildProfileStore.instance.switchTo(b);
    expect(BreastTimer.instance.finish(now: t0.add(const Duration(minutes: 8))), isTrue);
    expect(FeedingStore.instance.all, isEmpty, reason: 'not Meera\'s feed');
    await ChildProfileStore.instance.switchTo(a);
    expect(FeedingStore.instance.all.single.side, FeedSideX.left);
  });

  test('edits keep the id: nappy, pumping session, sleep', () {
    final now = DateTime.now();
    NappyStore.instance.log(time: now, kind: NappyKind.wet);
    final n = NappyStore.instance.all.single;
    NappyStore.instance.update(NappyLog(id: n.id, time: n.time, kind: NappyKind.mixed));
    expect(NappyStore.instance.all.single.id, n.id);
    expect(NappyStore.instance.all.single.kind, NappyKind.mixed);

    PumpStore.instance.log(time: now, leftMl: 60);
    final p = PumpStore.instance.all.single;
    PumpStore.instance.update(PumpLog(id: p.id, time: p.time, leftMl: 60, rightMl: 40));
    expect(PumpStore.instance.all.single.totalMl, 100);

    SleepStore.instance.log(start: now.subtract(const Duration(hours: 2)), end: now);
    final s = SleepStore.instance.all.single;
    SleepStore.instance.update(SleepLog(id: s.id, start: s.start, end: now, kind: SleepKind.night));
    expect(SleepStore.instance.all.single.isNight, isTrue);
    expect(SleepStore.instance.all, hasLength(1));
  });

  test('24 hours: wet nappies, and a night that began before the window counts from its edge', () {
    final now = DateTime.now();
    NappyStore.instance.log(time: now.subtract(const Duration(hours: 23)), kind: NappyKind.wet);
    NappyStore.instance.log(time: now.subtract(const Duration(hours: 25)), kind: NappyKind.wet);
    expect(NappyStore.instance.wet24h, 1);

    SleepStore.instance.log(start: now.subtract(const Duration(hours: 26)), end: now.subtract(const Duration(hours: 22)));
    expect(SleepStore.instance.totalMinutes24h, closeTo(120, 1));
  });

  test('asleep now: one tap to start, one to save; under a minute saves nothing', () {
    final s = SleepStore.instance;
    final t0 = DateTime(2026, 10, 25, 21, 10);
    s.startAsleep(at: t0);
    expect(s.asleepSince, t0);
    final saved = s.wakeUp(at: t0.add(const Duration(hours: 3)));
    expect(saved, isNotNull);
    expect(saved!.isNight, isTrue, reason: 'began after 7 pm');
    expect(s.asleepSince, isNull);

    s.startAsleep(at: t0);
    expect(s.wakeUp(at: t0.add(const Duration(seconds: 30))), isNull);
  });

  testWidgets('the sleep screen: Asleep now, then Woke up', (t) async {
    t.view.physicalSize = const Size(360 * 3, 2800 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: SleepJourneyScreen()));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('pp_sleep_log')), findsOneWidget, reason: 'typing times afterwards stays');
    await t.tap(find.byKey(const ValueKey('pp_sleep_asleep')));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('pp_sleep_woke')), findsOneWidget);
    expect(find.byKey(const ValueKey('pp_sleep_asleep_line')), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('pp_sleep_cancel')));
    await t.pump(const Duration(seconds: 5));
    expect(find.byKey(const ValueKey('pp_sleep_asleep')), findsOneWidget);
  });

  testWidgets('the last 7 days: an empty share says why', (t) async {
    t.view.physicalSize = const Size(360 * 3, 2800 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: PpCareHistoryScreen()));
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.byKey(const ValueKey('pp_history_share')));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Nothing logged in the last 7 days yet'), findsOneWidget);
    await t.pump(const Duration(seconds: 6));
  });
}
