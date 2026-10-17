// =============================================================================
//  The pregnancy calendar, rebuilt as one hub (2026-10-17)
// -----------------------------------------------------------------------------
//  Holds what the rebuild promised (plan: the approved prototype at
//  claude.ai/artifact/N6Y95pDA2i5dkQQbFaAF26):
//    · the facts: weeks and days, trimester boundaries, the usual-check
//      windows, and the four fixes the fact check found (GTT, GBS, Td, NT);
//    · every screen lays out at 360dp, the first view answers "where am I";
//    · an empty day invites, a future day says what waits for the day;
//    · his side adds nothing;
//    · the wiring: the old CalendarScreen opens the hub, and the hub reaches
//      Coming up, Whole journey and the shared appointment form.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/scan_schedule.dart';
import 'package:parentveda/models/scan_appointment.dart';
import 'package:parentveda/screens/pregnancy/calendar/preg_cal_data.dart';
import 'package:parentveda/screens/pregnancy/calendar/preg_cal_journey_screen.dart';
import 'package:parentveda/screens/pregnancy/calendar/preg_cal_sheets.dart';
import 'package:parentveda/screens/pregnancy/calendar/preg_cal_upcoming_screen.dart';
import 'package:parentveda/screens/pregnancy/calendar/preg_calendar_hub.dart';
import 'package:parentveda/services/calendar_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/scans_store.dart';

final DateTime _today = DateTime(2026, 10, 17);
final DateTime _due = DateTime(2027, 3, 4); // 138 days on: 20 weeks 2 days

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController p;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    p = PregnancyController(dueDate: _due, now: _today);
    await ScansStore.instance.clearAllForTesting();
    for (final e in [...CalendarStore.instance.personal]) {
      await CalendarStore.instance.deletePersonal(e.id);
    }
  });

  Future<void> pump(WidgetTester t, Widget w, {double height = 740}) async {
    t.view.physicalSize = Size(360, height);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: w));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
  }

  group('the facts', () {
    test('weeks and days count from the due date', () {
      expect(pregGaDays(_due, _today), 142);
      expect(pregCompletedWeeks(_due, _today), 20);
      expect(pregWeekOf(_due, _today), 21);
      expect(pregGaDays(_due, _due), 280);
      // Week 21 starts on the day 20 completed weeks are reached.
      expect(pregGaDays(_due, pregWeekStart(_due, 21)), 140);
    });

    test('trimester boundaries: 13w6d is the first, 14w0d the second, 28w0d the third', () {
      expect(pregTrimesterFor(13), 1);
      expect(pregTrimesterFor(14), 2);
      expect(pregTrimesterFor(27), 2);
      expect(pregTrimesterFor(28), 3);
    });

    test('usual checks are windows from the milestones', () {
      final byId = {for (final c in pregChecks()) c.id: c};
      expect(byId['m_nt']!.fromWeek, 11);
      expect(byId['m_nt']!.toWeek, 13);
      expect(byId['m_anomaly']!.windowLabel, 'Around weeks 18–22');
      expect(byId['m_glucose']!.windowLabel, 'Around weeks 24–28');
    });

    test('the four fact-check fixes are in the data', () {
      final byId = {for (final c in pregChecks()) c.id: c};
      // GTT: India often tests at the first visit too (MoHFW, DIPSI).
      expect(byId['m_glucose']!.timing, contains('first visit'));
      // GBS: risk-based in India, so "if advised".
      expect(byId['m_gbs']!.title, contains('if advised'));
      expect(byId['m_gbs']!.timing, contains('if your doctor advises'));
      // Td: present, with its own words instead of a week window.
      expect(byId['m_td'], isNotNull);
      expect(byId['m_td']!.windowLabel, 'At booking, then 4 weeks later');
      expect(byId['m_td']!.trimester, 1);
      expect(scansDueAt(12).map((m) => m.id), contains('m_td'));
      // NT: the window closes at 13 weeks 6 days.
      expect(byId['m_nt']!.timing, contains('13 weeks 6 days'));
    });

    test('a check booked under its own name reads as booked', () async {
      final nt = pregChecks().firstWhere((c) => c.id == 'm_glucose');
      expect(pregCheckStatus(nt).state, PregCheckState.open);
      await ScansStore.instance.addAppointment(Appointment(
          id: 'ap_t1', title: nt.title, dateIso: DateTime(2026, 11, 20).toIso8601String()));
      expect(pregCheckStatus(nt).state, PregCheckState.booked);
    });

    test('kick counts wait for week 28 and for the day; weight waits for the day', () {
      final tomorrow = _today.add(const Duration(days: 1));
      expect(pregCalAddBlocked(PregCalKind.kicks, _today, _today, _due), contains('week 28'));
      expect(pregCalAddBlocked(PregCalKind.weight, tomorrow, _today, _due), isNotNull);
      expect(pregCalAddBlocked(PregCalKind.weight, _today, _today, _due), isNull);
      expect(pregCalAddBlocked(PregCalKind.appointment, tomorrow, _today, _due), isNull);
      expect(pregCalAddBlocked(PregCalKind.note, tomorrow, _today, _due), isNull);
    });
  });

  group('the hub', () {
    testWidgets('first view: where she is and this month, at 360 x 740', (t) async {
      await pump(t, PregCalendarHub(controller: p, today: _today));
      expect(find.text('20 weeks 2 days'), findsOneWidget);
      expect(find.text('Second trimester · week 21 of 40'), findsOneWidget);
      expect(find.textContaining('138 days to go'), findsOneWidget);
      final month = find.text('October 2026');
      expect(month, findsOneWidget);
      expect(t.getBottomLeft(month).dy, lessThan(740));
      expect(t.takeException(), isNull);
    });

    testWidgets('an empty future day invites, and says what waits for the day', (t) async {
      await pump(t, PregCalendarHub(controller: p, today: _today), height: 2400);
      await t.tap(find.bySemanticsLabel(RegExp(r'^Tue 27 Oct')));
      await t.pumpAndSettle();
      expect(find.text('Nothing planned for this day yet.'), findsOneWidget);
      expect(find.text('Add to 27 Oct'), findsOneWidget);
      expect(find.textContaining('logged on the day'), findsOneWidget);
    });

    testWidgets('a note on a day shows as its row, and in Coming up', (t) async {
      await CalendarStore.instance.addPersonal(
          title: 'Baby shower planning', date: DateTime(2026, 10, 30));
      await pump(t, PregCalendarHub(controller: p, today: _today), height: 2400);
      expect(find.text('Baby shower planning'), findsOneWidget); // Coming up preview
      await t.tap(find.bySemanticsLabel(RegExp(r'^Fri 30 Oct')));
      await t.pumpAndSettle();
      expect(find.text('Baby shower planning'), findsNWidgets(2)); // + the day card
    });

    testWidgets('his side adds and changes nothing', (t) async {
      await pump(t, PregCalendarHub(controller: p, today: _today, readOnly: true), height: 2400);
      expect(find.textContaining('Shared from her calendar'), findsOneWidget);
      expect(find.text('Change'), findsNothing);
      expect(find.textContaining('Add to'), findsNothing);
      expect(find.text('Add date'), findsNothing);
      expect(find.text('Scans & appointments'), findsNothing);
    });

    testWidgets('the add sheet lists five rows and blocks what must wait', (t) async {
      await pump(t, PregCalendarHub(controller: p, today: _today), height: 2400);
      await t.tap(find.text('Add to 17 Oct'));
      await t.pumpAndSettle();
      expect(find.text('Add to Sat 17 Oct'), findsOneWidget);
      for (final l in ['Appointment', 'Weight', 'Symptom', 'Kick count', 'Note']) {
        expect(find.descendant(of: find.byType(BottomSheet), matching: find.text(l)),
            findsOneWidget);
      }
      expect(find.textContaining('start around week 28'), findsOneWidget);
    });
  });

  group('the other screens', () {
    testWidgets('Coming up lays out at 360 and shows open checks as windows', (t) async {
      await pump(t, PregCalUpcomingScreen(controller: p, today: _today), height: 1600);
      expect(find.text('Coming up'), findsWidgets);
      expect(find.text('Sugar test'), findsOneWidget);
      expect(find.text('WK'), findsWidgets);
      expect(t.takeException(), isNull);
    });

    testWidgets('Whole journey opens with this week marked', (t) async {
      await pump(t, PregCalJourneyScreen(controller: p, today: _today));
      expect(find.text('You are here'), findsOneWidget);
      expect(find.text('Week 21'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('the source', () {
    const dir = 'lib/screens/pregnancy/calendar';
    final files = Directory(dir)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    test('no text under 11pt anywhere in the calendar', () {
      final re = RegExp(r'(?:fontSize|size):\s*(\d+(?:\.\d+)?)');
      for (final f in files) {
        final src = _code(f.path);
        for (final m in re.allMatches(src)) {
          final line = src.substring(src.lastIndexOf('\n', m.start) + 1, m.start);
          if (line.contains('Icon(') || line.contains('icon') || line.contains('Mark')) continue;
          final v = double.parse(m.group(1)!);
          // Sizes above 30 are marks, wells and buttons, not text.
          if (v > 30) continue;
          expect(v, greaterThanOrEqualTo(11), reason: '${f.path}: ${m.group(0)}');
        }
      }
    });

    test('a usual check is never stated as her date', () {
      for (final f in files) {
        final src = _code(f.path).toLowerCase();
        expect(src.contains('your scan is on'), isFalse, reason: f.path);
        expect(src.contains('your test is on'), isFalse, reason: f.path);
      }
    });

    test('wired: CalendarScreen opens the hub, the hub reaches every screen', () {
      expect(_code('lib/screens/calendar_screen.dart'), contains('PregCalendarHub('));
      final hub = _code('$dir/preg_calendar_hub.dart');
      expect(hub, contains('PregCalUpcomingScreen('));
      expect(hub, contains('PregCalJourneyScreen('));
      expect(hub, contains('showPregCalAdd('));
      final sheets = _code('$dir/preg_cal_sheets.dart');
      expect(sheets, contains('showPregAppointmentSheet('));
      expect(_code('lib/screens/tools/scans_appointments_screen.dart'),
          contains('showPregAppointmentSheet(context)'));
      // His More row is no longer hidden.
      expect(_code('lib/screens/pregnancy/preg_more_screen.dart'),
          contains('Her appointments and what is coming up, to see'));
    });
  });
}
