// The app speaks first, in pregnancy (2026-09-30, gap analysis P1), and the
// due date is changed where it is shown (P1).
//
// ⚠️ THE ARITHMETIC IS HELD AGAINST THE CONTROLLER, DAY BY DAY. A weekly note
// that says "Week 21 starts today" on a day the home says week 20 is the
// failure this whole feature would be judged by, and it is exactly the kind of
// off-by-one two separate derivations make (docs/BACKEND-PATTERNS.md §16n).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/pregnancy/preg_due_date_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_messages_screen.dart';
import 'package:parentveda/screens/pregnancy/preg_more_screen.dart';
import 'package:parentveda/screens/tools/due_date_calculator_screen.dart' show DdcMethod;
import 'package:parentveda/services/preg_messages_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

class _Phone implements PregMessagePhone {
  final Map<int, DateTime> armed = {};
  final Set<int> cancelled = {};

  @override
  Future<void> schedule(
      {required int id, required String title, required String body, required DateTime when}) async {
    armed[id] = when;
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    armed.remove(id);
  }
}

String _code(String p) => File(p)
    .readAsStringSync()
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

PregMessageFacts _facts(DateTime due, {bool set = true, bool ended = false, bool preg = true, bool partner = false}) =>
    PregMessageFacts(dueDate: due, dueDateSet: set, ended: ended, inPregnancy: preg, partner: partner);

/// A due date that puts [now] at the start of week [w], day 1.
DateTime _dueFor(int w, DateTime now) =>
    DateTime(now.year, now.month, now.day).add(Duration(days: 7 * (40 - w) + 6));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 10, 1, 12);
  late _Phone phone;
  final store = PregMessagesStore.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    phone = _Phone();
    store.phone = phone;
    store.resetForTest();
  });

  group('the weeks agree with the controller', () {
    test('on every day of a pregnancy, and each week starts on the right day', () {
      final due = DateTime(2027, 3, 10);
      for (var d = 0; d < 300; d++) {
        final day = DateTime(2026, 6, 1).add(Duration(days: d));
        final c = PregnancyController(dueDate: due, now: day);
        final w = pregWeekOn(due, day);
        if (w >= 4 && w <= 40) {
          expect(c.currentWeek, w, reason: '$day');
        }
      }
      for (var w = 5; w <= 40; w++) {
        final s = pregWeekStart(due, w);
        expect(PregnancyController(dueDate: due, now: s).currentWeek, w, reason: 'start of $w');
        expect(PregnancyController(dueDate: due, now: s.subtract(const Duration(days: 1))).currentWeek, w - 1,
            reason: 'the day before $w');
      }
    });
  });

  group('who is spoken to', () {
    test('no due date, a pregnancy that ended, the partner, or another stage: nothing', () {
      final due = _dueFor(20, now);
      expect(pregMessageCandidates(_facts(due, set: false), now), isEmpty);
      expect(pregMessageCandidates(_facts(due, ended: true), now), isEmpty);
      expect(pregMessageCandidates(_facts(due, partner: true), now), isEmpty);
      expect(pregMessageCandidates(_facts(due, preg: false), now), isEmpty);
      expect(pregMessageCandidates(_facts(due), now), isNotEmpty);
    });
  });

  group('what is said, and when', () {
    test('at week 10: the next weeks at 9, and every moment on its week', () {
      final due = _dueFor(10, now);
      final c = pregMessageCandidates(_facts(due), now);
      final weeks = [for (final m in c) if (m.kind == PregMessageKind.newWeek) m.week];
      expect(weeks, [10, 11, 12, 13, 14]);
      for (final m in c) {
        if (m.kind == PregMessageKind.newWeek) {
          expect(m.at, DateTime(pregWeekStart(due, m.week!).year, pregWeekStart(due, m.week!).month,
              pregWeekStart(due, m.week!).day, 9));
          expect(m.title, 'Week ${m.week} starts today');
        }
      }
      final byKind = {for (final m in c) m.kind: m};
      for (final (k, w) in [
        (PregMessageKind.ntScan, 11),
        (PregMessageKind.anomalyScan, 18),
        (PregMessageKind.tdap, 27),
        (PregMessageKind.movements, 28),
        (PregMessageKind.hospitalBag, 34),
        (PregMessageKind.babyArrived, 37),
      ]) {
        final m = byKind[k];
        expect(m, isNotNull, reason: k.name);
        expect(pregWeekOn(due, m!.at), w, reason: k.name);
        expect(m.at.hour, 10);
      }
    });

    test('a moment is offered only while it can help', () {
      final at15 = pregMessageCandidates(_facts(_dueFor(15, now)), now).map((m) => m.kind).toSet();
      expect(at15, isNot(contains(PregMessageKind.ntScan)));
      expect(at15, contains(PregMessageKind.anomalyScan));
      final at23 = pregMessageCandidates(_facts(_dueFor(23, now)), now).map((m) => m.kind).toSet();
      expect(at23, isNot(contains(PregMessageKind.anomalyScan)));
      final at39 = pregMessageCandidates(_facts(_dueFor(39, now)), now).map((m) => m.kind).toSet();
      expect(at39, isNot(contains(PregMessageKind.hospitalBag)));
      expect(at39, contains(PregMessageKind.babyArrived));
    });

    test('the clinical lines remind and defer; none says "you need" or "you must"', () {
      for (final m in pregMessageCandidates(_facts(_dueFor(10, now)), now)) {
        final b = m.body.toLowerCase();
        expect(b, isNot(contains('you need')), reason: m.id);
        expect(b, isNot(contains('you must')), reason: m.id);
        expect(m.body, isNot(contains('!')), reason: m.id);
        expect(m.body, isNot(contains('—')), reason: m.id);
      }
    });
  });

  group('sent once, and moving with the date', () {
    test('a first launch at week 20 delivers this week and the anomaly line, nothing older', () async {
      final due = _dueFor(20, now).subtract(const Duration(days: 2)); // day 3 of week 20
      await store.refresh(now: now, facts: _facts(due));
      final got = store.delivered(now: now);
      expect(got.where((m) => m.kind == PregMessageKind.newWeek).map((m) => m.week), [20]);
      expect(got.map((m) => m.kind), contains(PregMessageKind.anomalyScan));
      expect(got.map((m) => m.kind), isNot(contains(PregMessageKind.ntScan)));
      // Late ones go to the inbox only: nothing armed for a moment in the past.
      for (final when in phone.armed.values) {
        expect(when.isAfter(now), isTrue);
      }
    });

    test('a corrected due date moves what is pending and never re-sends what arrived', () async {
      final due = _dueFor(20, now);
      await store.refresh(now: now, facts: _facts(due));
      final tdap = store.pending(now: now).firstWhere((m) => m.kind == PregMessageKind.tdap).at;
      // A dating scan moves the date a week later.
      final later = due.add(const Duration(days: 7));
      await store.refresh(now: now, facts: _facts(later));
      final moved = store.pending(now: now).firstWhere((m) => m.kind == PregMessageKind.tdap).at;
      expect(moved.difference(tdap).inDays, 7);
      // Week 20 was delivered; the new date makes it week 19 today and week
      // 20 next week, and week 20 is not sent a second time.
      expect(store.pending(now: now).where((m) => m.id == 'week:20'), isEmpty);
      expect(store.delivered(now: now).where((m) => m.id == 'week:20').length, 1);
    });

    test('ending the pregnancy drops everything pending, and keeps what she read', () async {
      final due = _dueFor(20, now);
      await store.refresh(now: now, facts: _facts(due));
      final kept = store.delivered(now: now).length;
      await store.refresh(now: now, facts: _facts(due, ended: true));
      expect(store.pending(now: now), isEmpty);
      expect(store.delivered(now: now).length, kept);
      expect(phone.armed, isEmpty);
    });
  });

  group('her choices, and the phone', () {
    test('only our own ids, the weekly block of four, cancelled every refresh', () async {
      await store.refresh(now: now, facts: _facts(_dueFor(10, now)));
      final ours = {for (final k in PregMessageKind.values) ...k.phoneIds};
      expect(phone.armed.keys.every(ours.contains), isTrue);
      expect(phone.cancelled, ours);
      final weekIds = PregMessageKind.newWeek.phoneIds;
      expect(phone.armed.keys.where(weekIds.contains).length, lessThanOrEqualTo(kPregWeekPhoneSlots));
      // No other feature's id space is touched (the TTC block, the reminders).
      expect(ours.any((id) => id >= 918000 && id < 919000), isFalse);
    });

    test('a switch off drops that kind; the phone off keeps the inbox', () async {
      final due = _dueFor(10, now);
      await store.refresh(now: now, facts: _facts(due));
      await store.setOn(PregMessageKind.tdap, false);
      await store.refresh(now: now, facts: _facts(due));
      expect(store.pending(now: now).where((m) => m.kind == PregMessageKind.tdap), isEmpty);
      await store.setPhoneOn(false);
      await store.refresh(now: now, facts: _facts(due));
      expect(phone.armed, isEmpty);
      expect(store.pending(now: now), isNotEmpty);
    });

    test('a tap on one of ours opens it and marks it read; any other id is not ours', () async {
      PregMessage? opened;
      PregMessagesStore.phoneTapOpener = (m) => opened = m;
      addTearDown(() => PregMessagesStore.phoneTapOpener = null);
      // The real clock: a tap is handled "now". Day 3 of week 20.
      final due = _dueFor(20, DateTime.now()).subtract(const Duration(days: 2));
      await store.refresh(facts: _facts(due));
      expect(store.handlePhoneTap(918101), isFalse, reason: "TTC's id, not ours");
      expect(opened, isNull);
      expect(store.handlePhoneTap(PregMessageKind.newWeek.notificationId), isTrue);
      expect(opened?.id, 'week:20');
      expect(store.delivered().firstWhere((m) => m.id == 'week:20').read, isTrue);
    });
  });

  group('wiring', () {
    test('the store starts after the reminders wipe, and taps are routed', () {
      final main = _code('lib/main.dart');
      final r = main.indexOf('ReminderStore.instance');
      final m = main.indexOf('PregMessagesStore.instance.init()');
      expect(r, greaterThan(0));
      expect(m, greaterThan(r));
      expect(main, contains('PregMessagesStore.phoneTapOpener = pregOpenMessageFromPhone'));
    });

    test('Reminders holds the switches; More holds the inbox; You opens the date editor', () {
      expect(_code('lib/screens/reminders_screen.dart'), contains('PregMessageSwitches('));
      expect(_code('lib/screens/pregnancy/preg_more_screen.dart'), contains('openPregMessages('));
      expect(_code('lib/screens/profile/pv_you_content.dart'), contains('openPregDueDate('));
    });
  });

  group('the inbox and the date editor draw', () {
    late PregnancyController c;
    setUp(() async {
      c = PregnancyController(dueDate: _dueFor(20, DateTime.now()));
      await c.load();
    });

    testWidgets('Messages lists what arrived, with an unread mark', (tester) async {
      tester.view.physicalSize = const Size(360, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      // Day 3 of week 20, so its 9 am note has arrived whatever the clock says.
      final due = _dueFor(20, DateTime.now()).subtract(const Duration(days: 2));
      await tester.runAsync(() => store.refresh(facts: _facts(due)));
      await tester.pumpWidget(MaterialApp(home: PregMessagesScreen(pregnancy: c)));
      await tester.pump();
      expect(find.text('Messages'), findsOneWidget);
      expect(find.byKey(const ValueKey('preg_msg_week:20')), findsOneWidget);
      expect(find.text('Choose what we send'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('More has a Messages row', (tester) async {
      tester.view.physicalSize = const Size(360, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: PregMoreScreen(pregnancy: c))));
      await tester.pump();
      expect(find.byKey(const ValueKey('preg_more_messages')), findsOneWidget);
    });

    testWidgets('the date editor leads with Scan date after week 12, and draws', (tester) async {
      tester.view.physicalSize = const Size(360, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: PregDueDateScreen(pregnancy: c)));
      await tester.pump();
      expect(find.text('Your due date'), findsOneWidget);
      final first = tester.getTopLeft(find.byKey(const ValueKey('preg_due_way_ultrasound')));
      final lmp = tester.getTopLeft(find.byKey(const ValueKey('preg_due_way_lmp')));
      expect(first.dx < lmp.dx || first.dy < lmp.dy, isTrue);
      // The scan asks how far along it said.
      expect(find.text('HOW FAR ALONG THE SCAN SAID'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('the date editor rules', () {
    test('Scan date leads from week 12; Last period before it', () {
      expect(pregDueDateOrder(8).first, DdcMethod.lmp);
      expect(pregDueDateOrder(12).first, DdcMethod.ultrasound);
      expect(pregDueDateOrder(12).toSet(), kPregDueDateWays.keys.toSet());
    });

    test("our date over a clinic's is flagged; a clinic's over ours is not", () {
      expect(pregDueDateOverridesClinic(DueDateSource.scan, DdcMethod.lmp), isTrue);
      expect(pregDueDateOverridesClinic(DueDateSource.clinician, DdcMethod.lmp), isTrue);
      expect(pregDueDateOverridesClinic(DueDateSource.scan, DdcMethod.ultrasound), isFalse);
      expect(pregDueDateOverridesClinic(DueDateSource.lastPeriod, DdcMethod.lmp), isFalse);
      expect(pregDueDateOverridesClinic(DueDateSource.lastPeriod, DdcMethod.ultrasound), isFalse);
    });
  });
}
