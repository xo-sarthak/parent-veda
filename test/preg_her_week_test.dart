// =============================================================================
//  P3, her week: the behaviour the family changed, pinned
// -----------------------------------------------------------------------------
//  docs/preg-ttc-tool-plans/P3-her-week.md (2026-10-28). One due-date tool,
//  one scan id, the retired appointments screen gone into the Calendar, the
//  movement red flag on screen in a live session, a backdated weigh-in's week,
//  appointment reminders, and every P3 tool staying after a loss with its baby
//  wording dropped.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/scan_appointment.dart';
import 'package:parentveda/screens/pregnancy/preg_after_loss_note.dart';
import 'package:parentveda/screens/pregnancy/preg_due_date_screen.dart';
import 'package:parentveda/screens/tools/due_date_calculator_screen.dart';
import 'package:parentveda/screens/tools/weight_tracker_screen.dart' show weightWeekOn;
import 'package:parentveda/services/appointment_reminders.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/pregnancy_ended_store.dart';
import 'package:parentveda/services/scans_store.dart';
import 'package:parentveda/services/tools_store.dart';

/// Source with comment lines dropped, so a "kept for revert" line never
/// satisfies or fails a check.
String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController c;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PregnancyEndedStore.instance.resetForTest();
    c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140)));
    await c.load();
  });

  tearDown(() => PregnancyEndedStore.instance.resetForTest());

  Future<void> pump(WidgetTester t, Widget w) async {
    t.view.physicalSize = const Size(400, 3000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: w));
    await t.pump(const Duration(milliseconds: 300));
  }

  group('one due-date tool (D1)', () {
    testWidgets('the calculator opens the one due-date screen', (t) async {
      await c.setDueDate(DateTime.now().add(const Duration(days: 140)),
          source: DueDateSource.scan);
      await pump(t, DueDateCalculatorScreen(controller: c));
      expect(find.byType(PregDueDateScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('preg_due_save')), findsOneWidget);
      // The trimester roadmap from the saved date.
      expect(find.byKey(const ValueKey('preg_due_trimesters')), findsOneWidget);
    });

    test('Conception date is the fifth way, and our own count', () {
      expect(pregDueDateOrder(8), contains(DdcMethod.conception));
      expect(pregDueDateOrder(20).toSet(), kPregDueDateWays.keys.toSet());
      expect(ddcSourceFor(DdcMethod.conception).clinicOwned, isFalse);
      final d = DateTime(2026, 3, 1);
      expect(ddcComputeEdd(method: DdcMethod.conception, conception: d),
          d.add(const Duration(days: 266)));
    });

    test('trimesters begin at weeks 14 and 28', () {
      final edd = DateTime(2027, 1, 1);
      final start = edd.subtract(const Duration(days: 280));
      final (second, third) = pregTrimesterStarts(edd);
      expect(second, start.add(const Duration(days: 91)));
      expect(third, start.add(const Duration(days: 189)));
    });

    test('nothing opens the old calculator', () {
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        if (f.path.replaceAll('\\', '/').endsWith('tools/due_date_calculator_screen.dart')) continue;
        expect(_code(f.path).contains('DueDateCalculatorClassicScreen('), isFalse, reason: f.path);
      }
    });
  });

  group('the retired appointments screen (PG2 / D3)', () {
    test('its name opens the Calendar, and nothing opens the old one', () {
      expect(_code('lib/screens/tools/scans_appointments_screen.dart'),
          contains('=> CalendarScreen(controller: controller)'));
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        if (f.path.replaceAll('\\', '/').endsWith('tools/scans_appointments_screen.dart')) continue;
        expect(_code(f.path).contains('ScansAppointmentsClassicScreen('), isFalse, reason: f.path);
      }
    });

    test("the Calendar's own row opens her scans, not itself", () {
      final sheets = _code('lib/screens/pregnancy/calendar/preg_cal_sheets.dart');
      expect(sheets, contains("'calendar/scans', (_) => ScanTimelineScreen(pregnancy: p)"));
    });
  });

  group('one scan id (CA3)', () {
    setUp(() async {
      await ScansStore.instance.init();
      await ScansStore.instance.clearAllForTesting();
    });

    test('done in the Calendar is done in the timeline, and back', () async {
      final s = ScansStore.instance;
      await s.markCompleted(scanId: 'm_nt', journalTitle: 'NT scan', week: 12);
      expect(s.isCompleted('nt_scan'), isTrue);
      expect(s.isCompleted('m_nt'), isTrue);
      expect(s.completed.single.scanId, 'nt_scan', reason: 'written under the one id');
      await s.unmarkCompleted('nt_scan');
      expect(s.isCompleted('m_nt'), isFalse);
    });

    test('every milestone twin is a scan the timeline knows', () {
      final timeline = _code('lib/screens/brackets/scan_timeline_screen.dart');
      for (final id in ScansStore.kScanIdTwins.values) {
        expect(timeline, contains("('$id',"), reason: id);
      }
    });
  });

  group('appointment reminders (D7)', () {
    Appointment appt(String day, {String time = '', String status = 'upcoming'}) =>
        Appointment(id: 'ap_1', title: 'Anomaly scan', dateIso: day, time: time, status: status);

    test('7 pm the evening before', () {
      final w = AppointmentReminders.whenFor(appt('2026-11-10'), DateTime(2026, 11, 5, 9));
      expect(w, DateTime(2026, 11, 9, 19));
    });

    test('too late for the evening: 8 am on the day, if before the appointment', () {
      final now = DateTime(2026, 11, 9, 21);
      expect(AppointmentReminders.whenFor(appt('2026-11-10', time: '11:30'), now),
          DateTime(2026, 11, 10, 8));
      expect(AppointmentReminders.whenFor(appt('2026-11-10', time: '7:30 AM'), now), isNull);
    });

    test('a past or completed appointment has none', () {
      final now = DateTime(2026, 11, 12);
      expect(AppointmentReminders.whenFor(appt('2026-11-10'), now), isNull);
      expect(AppointmentReminders.whenFor(appt('2026-11-20', status: 'completed'), now), isNull);
    });

    test('the notification id is derived, stable and clear of the reminder range', () {
      final a = AppointmentReminders.notificationId('ap_123');
      expect(a, AppointmentReminders.notificationId('ap_123'));
      expect(a, isNot(AppointmentReminders.notificationId('ap_124')));
      expect(a >= 0x40000000 && a <= 0x7fffffff, isTrue);
    });

    test('the store arms and clears them, and Reminders lists them', () {
      final store = _code('lib/services/scans_store.dart');
      expect(RegExp(r'AppointmentReminders\.instance\.kick\(a\)').allMatches(store).length, 2,
          reason: 'add and update both arm the reminder');
      expect(store, contains('AppointmentReminders.instance.cancelFor(id)'));
      expect(_code('lib/screens/reminders_screen.dart'), contains('_ApptReminders(controller: controller)'));
    });
  });

  group('baby movement', () {
    test('the red flag is not behind `if (!active)` (M2)', () {
      final src = _code('lib/screens/tools/baby_movement_screen.dart');
      final flag = src.indexOf("'Fewer, weaker or different movements? Call the same day'");
      expect(flag, greaterThan(0));
      final before = src.substring(flag - 600, flag);
      expect(before.contains('if (!active) ...['), isFalse);
      expect(before, contains("keyPrefix: 'bm_fold'"));
    });

    test('a mis-tap can be taken back, and a session removed and restored (M6)', () async {
      final st = ToolsStore.instance;
      await st.init();
      await st.endMovementSession();
      await st.logMovement();
      await st.logMovement();
      expect(st.currentSessionMovements.length, 2);
      expect(await st.undoLastMovement(), isTrue);
      expect(st.currentSessionMovements.length, 1);
      await st.endMovementSession();
      final id = st.movementSessionHistory.first.id;
      final gone = await st.deleteMovementSession(id);
      expect(gone, isNotNull);
      expect(st.movementSessionHistory.any((r) => r.id == id), isFalse);
      await st.restoreMovementSession(gone!);
      expect(st.movementSessionHistory.any((r) => r.id == id), isTrue);
    });

    test('the Tools and Ask Veda lines no longer say "Count kicks" (M1)', () {
      expect(_code('lib/screens/tools_hub_screen.dart'), isNot(contains('Count kicks')));
      expect(_code('lib/ask_veda/pv_veda_links.dart'), isNot(contains('Count kicks')));
    });
  });

  test('a backdated weigh-in carries the week of its own day (W3)', () {
    final due = c.dueDate;
    final tenWeeksAgo = DateTime.now().subtract(const Duration(days: 70));
    final then = weightWeekOn(c, tenWeeksAgo);
    final now = weightWeekOn(c, DateTime.now());
    expect(now - then, 10);
    expect(weightWeekOn(c, due.subtract(const Duration(days: 280))), 1);
  });

  group('after a loss, every P3 tool stays (D5)', () {
    test('the hub no longer hides Movement, Weight or the due date', () {
      final hub = _code('lib/screens/tools_hub_screen.dart');
      for (final row in ['s.babyMovementTracker', 's.toolWeightTitle', 's.ddcToolTitle']) {
        expect(RegExp('if \\(!_ended\\)\\s*\\n\\s*_Tool\\($row'.replaceAll('.', '\\.')).hasMatch(hub),
            isFalse, reason: row);
      }
      expect(hub, contains("_open('calendar', () => CalendarScreen(controller: controller))"),
          reason: 'C1: the Calendar is a Tools row');
    });

    testWidgets('the note shows only after a loss', (t) async {
      await pump(t, const Scaffold(body: PregAfterLossNote(kAfterLossMovement)));
      expect(find.byKey(const ValueKey('preg_after_loss_note')), findsNothing);
      await PregnancyEndedStore.instance.markEnded();
      await t.pump();
      expect(find.byKey(const ValueKey('preg_after_loss_note')), findsOneWidget);
    });

    test('each tool that needs a pregnancy carries the note or drops the words', () {
      expect(_code('lib/screens/tools/baby_movement_screen.dart'), contains('PregAfterLossNote(kAfterLossMovement)'));
      expect(_code('lib/screens/pregnancy/preg_due_date_screen.dart'), contains('PregAfterLossNote(kAfterLossDueDate)'));
      expect(_code('lib/screens/pregnancy/calendar/preg_calendar_hub.dart'), contains('PregAfterLossNote(kAfterLossCalendar'));
      expect(_code('lib/screens/brackets/scan_timeline_screen.dart'), contains('PregAfterLossNote(kAfterLossScans'));
      final kegel = _code('lib/screens/tools/kegel_care_screen.dart');
      expect(kegel, contains('math.min(c!.currentWeek, 28)'), reason: 'no "Preparing for birth"');
      expect(_code('lib/screens/tools/weight_tracker_screen.dart'), contains('if (!ended) ...['));
    });
  });
}
