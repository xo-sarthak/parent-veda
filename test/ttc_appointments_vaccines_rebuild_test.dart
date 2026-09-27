// =============================================================================
//  TTC tool rebuild (2026-09-27, night): Appointments and Vaccinations
// -----------------------------------------------------------------------------
//  The user walked build 13 and called the tools "old tools in new clothes".
//  These pin the rebuilt experience, tap by tap:
//
//   Appointments: first open empty, add (quick name, notes, separate time),
//   the next visit said as "Tomorrow", Coming up and Past as two choices, a
//   visit's own page with its questions and every empty line fillable,
//   change, remove behind a confirm with Undo, leaving a half-filled form
//   asks first, and a saved question opens.
//
//   Vaccinations: the tests box leads until she starts, the India note said
//   once, an answered card says its answer (not four buttons), Change brings
//   the choices back, "I need this" carries "I've had it now", the "clear to
//   try from" date is on the card, clearing has Undo, "live" is a sentence,
//   and "More about this" opens the details.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_appointments_screen.dart';
import 'package:parentveda/screens/ttc/ttc_journal_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart';
import 'package:parentveda/screens/ttc/ttc_vaccines_screen.dart';
import 'package:parentveda/ttc/ttc_journal_store.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';
import 'package:parentveda/ttc/ttc_vaccine_store.dart';
import 'package:parentveda/ttc/ttc_vaccines_data.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {double width = 1200, double height = 8000}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump();
}

/// Lets a snackbar's timer run out so no timer is left pending.
Future<void> _drainSnack(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

DateTime _inDays(int d, {int hour = 10}) {
  final t = DateTime.now().add(Duration(days: d));
  return DateTime(t.year, t.month, t.day, hour);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcAppointmentsStore.instance.resetForTest();
    TtcJournalStore.instance.resetForTest();
    TtcVaccineStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcAppointmentsStore.schedulePhone = ({
      required int id,
      required String title,
      required String body,
      required DateTime when,
    }) async {};
    TtcAppointmentsStore.cancelPhone = (id) async {};
  });

  // ===========================================================================
  group('appointments: the list', () {
    testWidgets('first open: an invitation with its button, no Past switch',
        (tester) async {
      await _pump(tester, const TtcAppointmentsScreen());
      expect(find.text(const TtcS(false).appointmentsEmptyTitle),
          findsOneWidget);
      expect(find.text('Add an appointment'), findsOneWidget,
          reason: 'the empty state carries its own action');
      expect(find.textContaining('Past ·'), findsNothing,
          reason: 'nothing to switch to until a visit has passed');
      expect(find.text('Write a question'), findsOneWidget);
    });

    testWidgets('the next visit is said as how soon it is', (tester) async {
      TtcAppointmentsStore.instance
          .add(title: 'Follicle scan', startsLocal: _inDays(1));
      TtcAppointmentsStore.instance
          .add(title: 'Blood test', startsLocal: _inDays(5));
      await _pump(tester, const TtcAppointmentsScreen());
      expect(find.text('NEXT'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('Follicle scan'), findsOneWidget);
      expect(find.text('Blood test'), findsOneWidget);
    });

    testWidgets('Coming up and Past are two choices, not one scroll',
        (tester) async {
      TtcAppointmentsStore.instance
          .add(title: 'Old consult', startsLocal: _inDays(-10));
      TtcAppointmentsStore.instance
          .add(title: 'Day 12 scan', startsLocal: _inDays(3));
      await _pump(tester, const TtcAppointmentsScreen());
      expect(find.text('Day 12 scan'), findsOneWidget);
      expect(find.text('Old consult'), findsNothing,
          reason: 'the past does not sit under what is next');
      await tester.tap(find.text('Past · 1'));
      await tester.pumpAndSettle();
      expect(find.text('Old consult'), findsOneWidget);
      expect(find.text('Day 12 scan'), findsNothing);
    });

    testWidgets('a saved question opens to be changed', (tester) async {
      TtcJournalStore.instance
          .add(kind: TtcEntryKind.question, text: 'Should we test AMH?');
      await _pump(tester, const TtcAppointmentsScreen());
      await tester.tap(find.text('Should we test AMH?'));
      await tester.pumpAndSettle();
      expect(find.byType(TtcJournalEntryScreen), findsOneWidget);
    });
  });

  // ===========================================================================
  group('appointments: adding', () {
    testWidgets('a quick name, a note, and it lands on the list',
        (tester) async {
      await _pump(tester, const TtcAppointmentsScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_appt_add')));
      await tester.pumpAndSettle();
      expect(find.text('Add an appointment'), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing,
          reason: 'one page, never a sheet stacked on the list');

      await tester.tap(find.text('Follicle scan'));
      await tester.pump();
      await tester.enterText(find.byKey(const ValueKey('ttc_appt_note')),
          'Come with a full bladder');
      await tester.tap(find.byKey(const ValueKey('ttc_appt_save')));
      await tester.pumpAndSettle();

      final a = TtcAppointmentsStore.instance.all.single;
      expect(a.title, 'Follicle scan');
      expect(a.note, 'Come with a full bladder');
      expect(find.text('Follicle scan'), findsOneWidget);
      expect(find.text('Added to your appointments.'), findsOneWidget);
      await _drainSnack(tester);
    });

    testWidgets('Save with no name says so and saves nothing',
        (tester) async {
      await _pump(tester, const TtcAppointmentsScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_appt_add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_appt_save')));
      await tester.pumpAndSettle();
      expect(find.text('Add what it is to save.'), findsOneWidget);
      expect(TtcAppointmentsStore.instance.all, isEmpty);
    });

    testWidgets('the time is its own tap, and closing it keeps the time',
        (tester) async {
      await _pump(tester, const TtcAppointmentsScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_appt_add')));
      await tester.pumpAndSettle();
      expect(find.text('10:00am'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_appt_time')));
      await tester.pumpAndSettle();
      expect(
          find.textContaining(
              RegExp('time of the appointment', caseSensitive: false)),
          findsOneWidget,
          reason: 'every picker says what it is for');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('10:00am'), findsOneWidget,
          reason: 'a closed picker never invents a time');
    });

    testWidgets('leaving a half-filled form asks first', (tester) async {
      await _pump(tester, const TtcAppointmentsScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_appt_add')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('ttc_appt_title')), 'IUI');
      await tester.pump();
      await tester.tap(find.byType(TtcToolClose));
      await tester.pumpAndSettle();
      expect(find.text('Discard this?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_appt_keep_editing')));
      await tester.pumpAndSettle();
      expect(find.byType(TtcAppointmentEditScreen), findsOneWidget);

      await tester.tap(find.byType(TtcToolClose));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_appt_discard')));
      await tester.pumpAndSettle();
      expect(find.byType(TtcAppointmentEditScreen), findsNothing);
      expect(TtcAppointmentsStore.instance.all, isEmpty);
    });
  });

  // ===========================================================================
  group("appointments: one visit's page", () {
    testWidgets('it opens with its questions and fillable empty lines',
        (tester) async {
      TtcAppointmentsStore.instance
          .add(title: 'Consultation', startsLocal: _inDays(2));
      TtcJournalStore.instance
          .add(kind: TtcEntryKind.question, text: 'Is my AMH low?');
      await _pump(tester, const TtcAppointmentsScreen());
      expect(find.text('1 question to take'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_appt_next')));
      await tester.pumpAndSettle();

      expect(find.text('APPOINTMENT'), findsOneWidget);
      expect(find.text('Questions to take'), findsOneWidget);
      expect(find.text('Is my AMH low?'), findsOneWidget);
      expect(find.text("Add who it's with"), findsOneWidget);

      await tester.tap(find.text("Add who it's with"));
      await tester.pumpAndSettle();
      expect(find.text('Change this appointment'), findsOneWidget,
          reason: 'an empty line opens the form, not a dead end');
    });

    testWidgets('change keeps the id and shows on the page', (tester) async {
      final a = TtcAppointmentsStore.instance
          .add(title: 'Scan', startsLocal: _inDays(4));
      await _pump(tester, const TtcAppointmentsScreen());
      await tester.tap(find.text('Scan'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_appt_change')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('ttc_appt_title')), 'Day 10 scan');
      await tester.enterText(
          find.byKey(const ValueKey('ttc_appt_who')), 'Dr Mehta');
      await tester.tap(find.byKey(const ValueKey('ttc_appt_save')));
      await tester.pumpAndSettle();

      final now = TtcAppointmentsStore.instance.all.single;
      expect(now.id, a.id, reason: 'an edit, not a delete and re-add');
      expect(now.title, 'Day 10 scan');
      expect(find.text('Dr Mehta'), findsOneWidget,
          reason: "the visit's page reads the store fresh");
      await _drainSnack(tester);
    });

    testWidgets('the reminder switch works from the page', (tester) async {
      TtcAppointmentsStore.instance.add(
          title: 'IUI', startsLocal: _inDays(3), remindEveningBefore: true);
      await _pump(tester, const TtcAppointmentsScreen());
      await tester.tap(find.text('IUI'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_appt_remind')));
      await tester.pumpAndSettle();
      expect(TtcAppointmentsStore.instance.all.single.remindEveningBefore,
          isFalse);
    });

    testWidgets('remove asks, then offers Undo with the same id',
        (tester) async {
      final a = TtcAppointmentsStore.instance
          .add(title: 'Blood test', startsLocal: _inDays(2));
      await _pump(tester, const TtcAppointmentsScreen());
      await tester.tap(find.text('Blood test'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('ttc_appt_remove')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_no')));
      await tester.pumpAndSettle();
      expect(TtcAppointmentsStore.instance.all, hasLength(1));

      await tester.tap(find.byKey(const ValueKey('ttc_appt_remove')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_yes')));
      await tester.pumpAndSettle();
      expect(TtcAppointmentsStore.instance.all, isEmpty);
      expect(find.text('Appointment removed.'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(TtcAppointmentsStore.instance.all.single.id, a.id);
      await _drainSnack(tester);
    });
  });

  // ===========================================================================
  group('appointments: words for dates', () {
    test('relative days are counted on calendar days', () {
      final now = DateTime(2026, 9, 27, 22);
      expect(ttcApptRelative(DateTime(2026, 9, 27, 23), now: now), 'Today');
      expect(ttcApptRelative(DateTime(2026, 9, 28, 9), now: now), 'Tomorrow',
          reason: 'under 24 hours away is still tomorrow');
      expect(ttcApptRelative(DateTime(2026, 9, 30), now: now), 'In 3 days');
      expect(ttcApptRelative(DateTime(2026, 10, 12), now: now), 'In 2 weeks');
      expect(ttcApptRelative(DateTime(2026, 9, 26), now: now), 'Yesterday');
      expect(ttcApptRelative(DateTime(2026, 9, 22), now: now), '5 days ago');
    });
  });

  group('appointments: 360dp', () {
    testWidgets('list, page and form lay out without overflow',
        (tester) async {
      TtcAppointmentsStore.instance.add(
          title: 'Hysterosalpingography at the city clinic',
          withWhom: 'Dr Anjali Deshpande, Sunrise Fertility Centre',
          startsLocal: _inDays(2),
          remindEveningBefore: true);
      TtcAppointmentsStore.instance
          .add(title: 'Old', startsLocal: _inDays(-3));
      await _pump(tester, const TtcAppointmentsScreen(),
          width: 360, height: 3000);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('ttc_appt_next')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('ttc_appt_change')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  group('vaccinations', () {
    testWidgets('first open: the tests box leads, the India note said once',
        (tester) async {
      await _pump(tester, const TtcVaccinesScreen());
      final ask = tester.getTopLeft(find.text('Ask for these tests by name'));
      final group = tester.getTopLeft(find.text('BEFORE YOU START TRYING'));
      expect(ask.dy, lessThan(group.dy));
      expect(find.textContaining("India's public programme"), findsOneWidget);
      expect(find.text("YOU'LL NEED TO ASK"), findsNothing,
          reason: 'folded into the tests box');
      expect(find.byKey(const ValueKey('ttc_vax_mmr_immune')), findsOneWidget);
    });

    testWidgets('an answered card says its answer, and Change brings the '
        'choices back', (tester) async {
      await _pump(tester, const TtcVaccinesScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_vax_mmr_immune')));
      await tester.pumpAndSettle();
      expect(
          tester.widget<Text>(find.byKey(const ValueKey('ttc_vax_mmr_answer')))
              .data,
          'Already immune');
      expect(find.byKey(const ValueKey('ttc_vax_mmr_immune')), findsNothing,
          reason: 'done reads as done, not as four buttons');
      // Once started, the tests box is reference and moves under the cards.
      final ask = tester.getTopLeft(find.text('Ask for these tests by name'));
      final group = tester.getTopLeft(find.text('BEFORE YOU START TRYING'));
      expect(ask.dy, greaterThan(group.dy));

      await tester.tap(find.byKey(const ValueKey('ttc_vax_mmr_change')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_vax_mmr_needed')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_vax_mmr_keep')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_vax_mmr_answer')), findsOneWidget);
    });

    testWidgets('"I need this" carries the next step and the clear date',
        (tester) async {
      await _pump(tester, const TtcVaccinesScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_vax_varicella_needed')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ttc_vax_varicella_had_now')),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_vax_varicella_had_now')));
      await tester.pumpAndSettle();
      expect(find.text('When did you have it?'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(TtcVaccineStore.instance.statusOf('varicella'),
          TtcVaccineStatus.done);
      expect(find.textContaining('Clear to try from'), findsOneWidget,
          reason: 'the date the wait ends sits on the card');
      expect(find.byKey(const ValueKey('ttc_vax_varicella_date')),
          findsOneWidget);
    });

    testWidgets('clearing an answer offers Undo, date and all',
        (tester) async {
      final had = DateTime.now().subtract(const Duration(days: 10));
      await TtcVaccineStore.instance
          .set('mmr', TtcVaccineStatus.done, on: had);
      await _pump(tester, const TtcVaccinesScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_vax_mmr_change')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_vax_mmr_clear')));
      await tester.pumpAndSettle();
      expect(TtcVaccineStore.instance.statusOf('mmr'),
          TtcVaccineStatus.unknown);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(TtcVaccineStore.instance.statusOf('mmr'), TtcVaccineStatus.done);
      expect(TtcVaccineStore.instance.doneOn('mmr'), had);
      await _drainSnack(tester);
    });

    testWidgets('"live" is a sentence, and More about this opens the card',
        (tester) async {
      await _pump(tester, const TtcVaccinesScreen());
      expect(find.textContaining('-DAY WAIT'), findsNothing);
      final live = ttcLiveVaccines.length;
      expect(find.textContaining('Live vaccine: wait'), findsNWidgets(live));
      expect(find.text('WHY IT MATTERS'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('ttc_vax_mmr_more')));
      await tester.pumpAndSettle();
      expect(find.text('WHY IT MATTERS'), findsOneWidget);
      expect(find.text('Show less'), findsOneWidget);
    });

    testWidgets('answered cards lay out at 360dp', (tester) async {
      await TtcVaccineStore.instance.set('mmr', TtcVaccineStatus.done,
          on: DateTime.now().subtract(const Duration(days: 3)));
      await TtcVaccineStore.instance
          .set('varicella', TtcVaccineStatus.needed);
      await _pump(tester, const TtcVaccinesScreen(), width: 360, height: 5000);
      expect(tester.takeException(), isNull);
    });
  });
}
