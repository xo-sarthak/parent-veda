// =============================================================================
//  Care logs: nappies, pumping, the breastfeed timer, and history
// -----------------------------------------------------------------------------
//  What fails silently here: a toRow column the migration does not have (the
//  cloud write is fire-and-forget), the timer losing time because it counted
//  ticks instead of timestamps, an empty day dragging the doctor's average
//  down, and the four screens built but unreachable.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_breast_timer_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_care_history_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_care_log_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_nappy_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_pump_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_feeding_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_sleep_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';

Set<String> _columns(String sql, String table) {
  final m = RegExp('create table public\\.$table \\((.*?)\\n\\);', dotAll: true).firstMatch(sql)!;
  return {
    for (final line in m.group(1)!.split('\n'))
      if (RegExp(r'^\s{2}([a-z_]+)\s').hasMatch(line)) RegExp(r'^\s{2}([a-z_]+)\s').firstMatch(line)!.group(1)!,
  };
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('schema contract', () {
    final sql = File('supabase/migrations/0094_pp_nappy_pump_tummy.sql').readAsStringSync();

    test('every nappy column the client writes exists', () {
      final row = NappyStore.toRow(NappyLog(id: 'x', time: DateTime(2026), kind: NappyKind.mixed));
      expect(_columns(sql, NappyStore.table), containsAll(row.keys));
      expect(NappyStore.table, 'pp_nappy_logs');
    });

    test('every pump column the client writes exists', () {
      final row = PumpStore.toRow(PumpLog(id: 'x', time: DateTime(2026), leftMl: 40));
      expect(_columns(sql, PumpStore.table), containsAll(row.keys));
      expect(PumpStore.table, 'pp_pump_logs');
    });

    test('the SQL check lists match the enum names exactly', () {
      for (final e in [...NappyKind.values, ...NappyColour.values, ...NappyTexture.values]) {
        expect(sql.contains("'${e.name}'"), isTrue, reason: e.name);
      }
    });

    test('round trip keeps every field', () {
      final n = NappyLog(id: 'n1', time: DateTime.utc(2026, 9, 1, 3), kind: NappyKind.dirty, colour: NappyColour.pale, texture: NappyTexture.soft, note: 'x');
      final back = NappyStore.fromRow(NappyStore.toRow(n));
      expect([back.kind, back.colour, back.texture, back.note], [n.kind, n.colour, n.texture, n.note]);
      final p = PumpLog(id: 'p1', time: DateTime.utc(2026, 9, 1), leftMl: 60, rightMl: 45, durationMin: 15);
      expect(PumpStore.fromRow(PumpStore.toRow(p)).totalMl, 105);
    });
  });

  group('the timer', () {
    setUp(() => BreastTimer.instance.debugReset());

    test('counts by timestamps: switching banks the first side', () {
      final t = BreastTimer.instance;
      final t0 = DateTime(2026, 10, 2, 3, 0, 0);
      t.tap(TimerSide.left, now: t0);
      t.tap(TimerSide.right, now: t0.add(const Duration(minutes: 7)));
      final at = t0.add(const Duration(minutes: 12));
      expect(t.secondsFor(TimerSide.left, now: at), 7 * 60);
      expect(t.secondsFor(TimerSide.right, now: at), 5 * 60);
      expect(t.running, TimerSide.right);
      t.tap(TimerSide.right, now: at);
      expect(t.running, isNull, reason: 'tapping the running side pauses it');
    });

    test('finish writes one breast feed with both sides and the side it ended on', () {
      final t = BreastTimer.instance;
      final before = FeedingStore.instance.all.length;
      final t0 = DateTime.now().subtract(const Duration(minutes: 20));
      t.tap(TimerSide.left, now: t0);
      t.tap(TimerSide.right, now: t0.add(const Duration(minutes: 10)));
      expect(t.finish(now: t0.add(const Duration(minutes: 18))), isTrue);
      final f = FeedingStore.instance.all.firstWhere((f) => f.time == t0);
      expect(FeedingStore.instance.all.length, before + 1);
      expect(f.kind, FeedKind.breast);
      expect(f.side, FeedSideX.both);
      expect(f.durationMin, 18);
      expect(f.note, contains('ended on right'));
      expect(t.isActive, isFalse);
      expect(ppNextBreastSide()!.suggestion, contains('ended on the right'));
      FeedingStore.instance.remove(f.id);
    });

    test('a tap-and-done with no time logs nothing', () {
      final t = BreastTimer.instance;
      final now = DateTime.now();
      t.tap(TimerSide.left, now: now);
      expect(t.finish(now: now), isFalse);
    });
  });

  group('history', () {
    final now = DateTime(2026, 10, 2, 20);

    test('buckets by calendar day, and empty days stay out of the doctor average', () {
      final days = PpCareHistory.days(
        7,
        now: now,
        feeds: [
          FeedLog(id: 'a', time: DateTime(2026, 10, 2, 6), kind: FeedKind.breast),
          FeedLog(id: 'b', time: DateTime(2026, 10, 2, 9), kind: FeedKind.bottle, amountMl: 90),
          FeedLog(id: 'c', time: DateTime(2026, 10, 1, 9), kind: FeedKind.breast),
          FeedLog(id: 'old', time: DateTime(2026, 9, 1, 9), kind: FeedKind.breast),
        ],
        sleeps: [SleepLog(id: 's', start: DateTime(2026, 10, 1, 21), end: DateTime(2026, 10, 2, 5), kind: SleepKind.night)],
        nappies: [
          NappyLog(id: 'n1', time: DateTime(2026, 10, 2, 7), kind: NappyKind.mixed),
          NappyLog(id: 'n2', time: DateTime(2026, 10, 2, 8), kind: NappyKind.wet),
        ],
        pumps: [PumpLog(id: 'p', time: DateTime(2026, 10, 2, 11), leftMl: 50, rightMl: 30)],
      );
      expect(days, hasLength(7));
      expect(days.first.date, DateTime(2026, 10, 2));
      expect([days[0].feeds, days[0].bottleMl, days[0].wet, days[0].dirty, days[0].pumpedMl], [2, 90, 2, 1, 80]);
      expect(days[1].nightSleepMin, 8 * 60, reason: 'sleep belongs to the day it started');
      expect(days.where((d) => !d.isEmpty), hasLength(2));

      final text = PpCareHistory.doctorSummary(days, childName: 'Aarav', ageLabel: '3 weeks');
      expect(text, startsWith('Aarav (3 weeks): the last 7 days'));
      expect(text, contains('- Feeds: 1.5'), reason: 'two logged days, not seven');
      expect(text, contains('- Nappies: 2.0 wet'));
      expect(text, contains('2 Oct: 2 feeds (90 ml bottle)'));
      expect(text.contains('—'), isFalse, reason: 'no em dashes in copy');
    });

    test('nothing logged says so plainly', () {
      final text = PpCareHistory.doctorSummary(
          PpCareHistory.days(7, now: now, feeds: const [], sleeps: const [], nappies: const [], pumps: const []),
          childName: 'Baby');
      expect(text, contains('Nothing logged in this period.'));
    });
  });

  group('nappy colour notes route to a doctor where they must', () {
    test('pale, red and late black say call today; early black is expected', () {
      for (final c in [NappyColour.pale, NappyColour.red]) {
        expect(nappyColourNote(c, ageDays: 20), contains('paediatrician today'), reason: c.name);
      }
      expect(nappyColourNote(NappyColour.black, ageDays: 2), contains('expected'));
      expect(nappyColourNote(NappyColour.black, ageDays: 20), contains('paediatrician today'));
    });
  });

  group('wiring', () {
    test('the four surfaces resolve', () {
      for (final s in ['pp_feed_timer', 'pp_nappies', 'pp_pump', 'pp_care_history']) {
        expect(ppScreenForSurface(s), isNotNull, reason: s);
      }
    });

    test('the Feeding and Sleep journeys link to them, and the stores boot at start', () {
      final feeding = File('lib/screens/post_pregnancy/feeding_journey_screen.dart').readAsStringSync();
      for (final s in ['PpBreastTimerScreen()', 'PpNappyScreen()', 'PpPumpScreen()', 'PpCareHistoryScreen()']) {
        expect(feeding.contains(s), isTrue, reason: s);
      }
      expect(File('lib/screens/post_pregnancy/sleep_journey_screen.dart').readAsStringSync(), contains('PpCareHistoryScreen('));
      final main = File('lib/main.dart').readAsStringSync();
      for (final s in ['NappyStore.instance.init()', 'PumpStore.instance.init()', 'BreastTimer.instance.init()']) {
        expect(main.contains(s), isTrue, reason: s);
      }
    });
  });

  group('the screens render at phone width', () {
    for (final (name, screen) in [
      ('timer', const PpBreastTimerScreen()),
      ('nappies', const PpNappyScreen()),
      ('pump', const PpPumpScreen()),
      ('history', const PpCareHistoryScreen()),
    ]) {
      testWidgets(name, (tester) async {
        tester.view.physicalSize = const Size(360, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(home: screen));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }

    testWidgets('a nappy tap logs one wet nappy', (tester) async {
      NappyStore.instance.debugReset();
      tester.view.physicalSize = const Size(360, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: PpNappyScreen()));
      await tester.tap(find.text('Wet').first);
      await tester.pump();
      expect(NappyStore.instance.wetToday, 1);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
