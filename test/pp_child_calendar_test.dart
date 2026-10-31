// =============================================================================
//  A child's calendar (STAGE-TRANSITIONS F7, 2026-10-25)
// -----------------------------------------------------------------------------
//  Read from the owners, write to the owners, store nothing: vaccines from the
//  vaccine tracker, visits from Health, an added appointment is a Health
//  visit. The usual check-up is a window. The evening-before reminder has its
//  own id block and survives the launch wipe.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/calendar/pp_cal_data.dart';
import 'package:parentveda/screens/post_pregnancy/calendar/pp_child_calendar_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_health_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_vaccine_data.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

HealthEvent _visit(String id, String date, {bool upcoming = false, HealthEventType type = HealthEventType.doctorVisit}) =>
    HealthEvent(id: id, type: type, date: date, title: 'Visit $id', summary: '11:00', sortKey: 1000, upcoming: upcoming);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final dob = DateTime(2026, 3, 10);
  final today = DateTime(2026, 10, 25);

  group('the items, from the owners', () {
    List<PpCalItem> items({Set<String> given = const {}, Map<String, DateTime> on = const {}, List<HealthEvent> visits = const []}) =>
        ppCalItems(
          dob: dob,
          today: today,
          vaxVisits: kVaxVisits,
          isGiven: given.contains,
          givenOn: (id) => on[id],
          visits: visits,
        );

    test('a vaccine visit falls on the birthday plus its age, or on the day it was given', () {
      final v = kVaxVisits.firstWhere((x) => x.ageDays == 182);
      final plain = items().firstWhere((x) => x.vaxVisitId == v.id);
      expect(plain.day, DateTime(2026, 3, 10).add(const Duration(days: 182)));
      final given = items(given: {v.id}, on: {v.id: DateTime(2026, 9, 12)}).firstWhere((x) => x.vaxVisitId == v.id);
      expect(given.day, DateTime(2026, 9, 12));
      expect(given.status, 'Given');
    });

    test('past and not given is Due, never overdue; ahead is Coming', () {
      final all = items();
      final past = all.firstWhere((x) => x.kind == PpCalKind.vaccine && x.day.isBefore(today));
      expect(past.status, 'Due');
      final ahead = all.firstWhere((x) => x.kind == PpCalKind.vaccine && x.day.isAfter(today));
      expect(ahead.status, 'Coming');
      expect(all.map((x) => x.status), isNot(contains('Overdue')));
    });

    test('Health visits: a future appointment is Booked, a past one Seen; notes and illnesses are not on it', () {
      final all = items(visits: [
        _visit('a', '29 Oct 2026', upcoming: true),
        _visit('b', '8 Oct 2026'),
        _visit('c', '2 Jun 2026', type: HealthEventType.illness),
        _visit('d', 'not a date', upcoming: true),
      ]);
      final v = all.where((x) => x.kind == PpCalKind.visit).toList();
      expect(v.map((x) => x.healthId), ['b', 'a']);
      expect(v.last.status, 'Booked');
      expect(v.first.status, 'Seen');
    });

    test('Coming up is what is ahead and not done, nearest first', () {
      final all = items(visits: [_visit('a', '29 Oct 2026', upcoming: true)]);
      final soon = ppCalComingUp(all, today);
      expect(soon.first.healthId, 'a');
      expect(soon.every((x) => !x.done && !x.day.isBefore(today)), isTrue);
    });

    test('the day view is the items on that day', () {
      final all = items(visits: [_visit('a', '29 Oct 2026', upcoming: true)]);
      expect(ppCalOn(all, DateTime(2026, 10, 29)).single.healthId, 'a');
      expect(ppCalOn(all, DateTime(2026, 10, 30)), isEmpty);
    });
  });

  group('the usual check-up is a window', () {
    test('the next one whose window is open, a week before to three weeks after', () {
      final next = ppNextCheckups(dob, today, const []).single;
      expect(next.c.ageDays, 274); // 9 months
      final at = DateTime(2026, 3, 10).add(const Duration(days: 274));
      expect(next.from, at.subtract(const Duration(days: 7)));
      expect(next.to, at.add(const Duration(days: 21)));
      expect(next.booked, isFalse);
    });

    test('a booked visit inside the window marks it booked', () {
      final at = DateTime(2026, 3, 10).add(const Duration(days: 274));
      final items = [
        PpCalItem(kind: PpCalKind.visit, day: at, title: '9-month check-up', detail: '', status: 'Booked', healthId: 'x'),
      ];
      expect(ppNextCheckups(dob, today, items).single.booked, isTrue);
    });

    test('its line explains, never diagnoses', () {
      expect(kPpCheckupLine.toLowerCase(), isNot(contains('normal')));
      expect(kPpCheckupLine, contains('weight'));
    });
  });

  group('the evening-before reminder', () {
    final scheduled = <(int, DateTime)>[];
    final cancelled = <int>[];
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      PpApptReminders.instance.debugReset();
      scheduled.clear();
      cancelled.clear();
      PpApptReminders.schedule = ({required int id, required String title, String? body, required DateTime when, String? payload}) async =>
          scheduled.add((id, when));
      PpApptReminders.cancelPhone = (id) async => cancelled.add(id);
    });
    tearDown(() => PpApptReminders.instance.debugReset());

    test('its own id block, apart from the TTC appointments (0x3A)', () {
      final id = ppApptReminderId('v_added_1');
      expect(id & 0xFF000000, 0x3B000000);
      expect(ppApptReminderId('v_added_1'), id);
      expect(ppApptReminderId('v_added_2'), isNot(id));
    });

    test('7 pm the evening before; none once that has passed', () {
      expect(ppEveningBefore(DateTime(2026, 10, 29, 11), DateTime(2026, 10, 25)), DateTime(2026, 10, 28, 19));
      expect(ppEveningBefore(DateTime(2026, 10, 29, 11), DateTime(2026, 10, 28, 20)), isNull);
    });

    test('remind, then forget', () async {
      final at = await PpApptReminders.instance
          .remind('v1', DateTime(2026, 10, 29, 11), title: 'Tomorrow: Visit', body: 'Aarav, at 11:00.', now: DateTime(2026, 10, 25));
      expect(at, DateTime(2026, 10, 28, 19));
      expect(scheduled.single, (ppApptReminderId('v1'), DateTime(2026, 10, 28, 19)));
      expect(PpApptReminders.instance.isOn('v1'), isTrue);
      await PpApptReminders.instance.forget('v1');
      expect(cancelled, [ppApptReminderId('v1')]);
      expect(PpApptReminders.instance.isOn('v1'), isFalse);
    });

    test('re-armed after the launch wipe, from what this phone kept; past ones dropped', () async {
      await PpApptReminders.instance
          .remind('v1', DateTime(2026, 10, 29, 11), title: 't', body: 'b', now: DateTime(2026, 10, 25));
      await PpApptReminders.instance
          .remind('v2', DateTime(2026, 10, 26, 11), title: 't', body: 'b', now: DateTime(2026, 10, 25));
      // A new run: memory empty, the phone's record read back.
      PpApptReminders.instance.debugReset();
      PpApptReminders.schedule = ({required int id, required String title, String? body, required DateTime when, String? payload}) async =>
          scheduled.add((id, when));
      scheduled.clear();
      await PpApptReminders.instance.rearmAfterStartup(now: DateTime(2026, 10, 26, 8));
      expect(scheduled.map((x) => x.$1), [ppApptReminderId('v1')]);
    });
  });

  group('the screen', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      ChildProfileStore.instance.resetForTest();
      HealthStore.instance.debugReset();
      PpApptReminders.instance.debugReset();
      PpApptReminders.schedule = ({required int id, required String title, String? body, required DateTime when, String? payload}) async {};
      await ChildProfileStore.instance.addChild(name: 'Aarav', isBoy: true, dob: dob);
    });
    tearDown(() => PpApptReminders.instance.debugReset());

    Future<void> pump(WidgetTester t) async {
      t.view.physicalSize = const Size(360, 2400);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(home: PpChildCalendarScreen(today: today)));
      await t.pump();
    }

    testWidgets("it is the child's: the name, the month, Coming up, the usual check-up", (t) async {
      await pump(t);
      expect(t.takeException(), isNull);
      expect(find.text("Aarav's calendar"), findsOneWidget);
      expect(find.text('October 2026'), findsOneWidget);
      expect(find.text('COMING UP'), findsOneWidget);
      expect(find.text('9-month check-up'), findsOneWidget);
      expect(find.text('Add the date'), findsOneWidget);
    });

    testWidgets('an appointment added here is a Health visit, marked upcoming', (t) async {
      await pump(t);
      await t.tap(find.text('Add an appointment'));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const ValueKey('pp_cal_what')), 'Paediatrician');
      await t.tap(find.text('Save appointment'));
      await t.pumpAndSettle();
      final v = HealthStore.instance.visits.firstWhere((x) => x.title == 'Paediatrician');
      expect(v.upcoming, isTrue);
      expect(v.type, HealthEventType.doctorVisit);
      expect(find.text("Saved to Aarav's health records."), findsOneWidget);
    });

    testWidgets('no name, no save, and it says why', (t) async {
      await pump(t);
      await t.tap(find.text('Add an appointment'));
      await t.pumpAndSettle();
      await t.tap(find.text('Save appointment'));
      await t.pump();
      expect(find.textContaining('Give it a name first'), findsOneWidget);
    });
  });

  group('wiring (the wiring gate)', () {
    test("the parenting header's Calendar opens it", () {
      expect(_code('lib/screens/post_pregnancy/pp_home_v3.dart'), contains('onCalendar: () => openPpChildCalendar(context)'));
    });

    test('its reminders are re-armed after the launch wipe, beside the TTC ones', () {
      final main = _code('lib/main.dart');
      final ttc = main.indexOf('TtcAppointmentsStore.instance.rearmAfterStartup()');
      final mine = main.indexOf('PpApptReminders.instance.rearmAfterStartup()');
      expect(mine, greaterThan(ttc));
      expect(ttc, greaterThan(-1));
    });

    test('it stores no records of its own (read the owners, write the owners)', () {
      final screen = _code('lib/screens/post_pregnancy/calendar/pp_child_calendar_screen.dart');
      expect(screen, contains('HealthStore.instance.addVisit(v)'));
      expect(screen, isNot(contains('SharedPreferences')));
    });
  });
}
