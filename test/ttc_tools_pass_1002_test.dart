// =============================================================================
//  The TTC tools pass of 2 October 2026: what the user listed after walking
//  Supplements, Medication, Records, Appointments, the doctor question, Medical
//  tests, Vaccinations and the PCOS check.
//
//   1. Supplements and Medication: the article is at the foot (the reader's
//      "Read next" rail), each tool's gateway to the other wears the other's
//      own drawn mark, and "Commonly taken" is a line a row with the full note
//      one tap away.
//   2. Records: "Type in a result" says what is typed, and the explainer under
//      "What your records become" is gone.
//   3. Appointments: the date and time are plain fields, not ink-bordered; the
//      reminder is a rule that cannot promise a time already gone, and says so.
//   4. The doctor question: "No particular visit", and a line that says where
//      the tick is.
//   5. Medical tests: a row is a name, one line, and a short "when".
//   6. Vaccinations: the eyebrow is not violet.
//   7. PCOS: the last-check card has a slim version.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/reader/pv_read_tile.dart';
import 'package:parentveda/screens/ttc/ttc_appointments_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart' show ttcTitleInk;
import 'package:parentveda/screens/ttc/ttc_doctor_question_screen.dart';
import 'package:parentveda/screens/ttc/ttc_medication_screen.dart';
import 'package:parentveda/screens/ttc/ttc_records_v2.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_supplements_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tests_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tool_chrome.dart';
import 'package:parentveda/screens/ttc/ttc_tool_marks.dart';
import 'package:parentveda/screens/ttc/ttc_vaccines_screen.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';
import 'package:parentveda/ttc/ttc_doctor_questions_store.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';
import 'package:parentveda/ttc/ttc_supplements_store.dart';
import 'package:parentveda/ttc/ttc_vaccine_store.dart';

Future<void> pump(
  WidgetTester t,
  Widget child, {
  double width = 390,
  double height = 8000,
}) async {
  t.view.physicalSize = Size(width, height);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await t.pump();
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final scheduled = <({DateTime when, String title})>[];

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await TtcRecordsStore.instance.ensureLoaded();
  });

  setUp(() {
    TtcSupplementsStore.instance.resetForTest();
    TtcRecordsStore.instance.resetForTest();
    TtcAppointmentsStore.instance.resetForTest();
    TtcDoctorQuestionsStore.instance.resetForTest();
    TtcVaccineStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    scheduled.clear();
    TtcAppointmentsStore.schedulePhone = ({
      required int id,
      required String title,
      required String body,
      required DateTime when,
    }) async {
      scheduled.add((when: when, title: title));
    };
    TtcAppointmentsStore.cancelPhone = (id) async {};
  });

  // ===========================================================================
  group('1. supplements and medication', () {
    testWidgets('the article is the last thing, as the reader\'s Read next',
        (t) async {
      await pump(t, const TtcSupplementsScreen());
      expect(t.takeException(), isNull);
      expect(find.byKey(const ValueKey('ttc_supp_read')), findsNothing);
      expect(find.byKey(const ValueKey('ttc_supp_read_next')), findsOneWidget);
      expect(find.text('Read next'), findsOneWidget);
      expect(find.byType(PvReadTile), findsOneWidget);
      final rail = t.getTopLeft(find.byKey(const ValueKey('ttc_supp_read_next'))).dy;
      expect(rail, greaterThan(t.getTopLeft(find.text('Commonly taken')).dy));
      expect(
          rail,
          greaterThan(
              t.getTopLeft(find.byKey(const ValueKey('ttc_supp_to_medication'))).dy),
          reason: 'under the Medication gateway: the article closes the page');
    });

    testWidgets('the gateway to Medication wears the Medication mark',
        (t) async {
      await pump(t, const TtcSupplementsScreen());
      final mark = find.descendant(
          of: find.byKey(const ValueKey('ttc_supp_to_medication')),
          matching: find.byWidgetPredicate(
              (w) => w is TtcToolArt && w.mark == TtcToolMark.medication));
      expect(mark, findsOneWidget);
    });

    testWidgets('Medication: the article at the foot, and the Supplements mark',
        (t) async {
      await pump(t, const TtcMedicationScreen());
      expect(t.takeException(), isNull);
      expect(find.byKey(const ValueKey('ttc_med_read')), findsNothing);
      expect(find.byKey(const ValueKey('ttc_med_read_next')), findsOneWidget);
      final mark = find.descendant(
          of: find.byKey(const ValueKey('ttc_med_to_supplements')),
          matching: find.byWidgetPredicate(
              (w) => w is TtcToolArt && w.mark == TtcToolMark.supplements));
      expect(mark, findsOneWidget);
      expect(
          t.getTopLeft(find.byKey(const ValueKey('ttc_med_read_next'))).dy,
          greaterThan(t
              .getTopLeft(find.byKey(const ValueKey('ttc_med_to_supplements')))
              .dy));
    });

    testWidgets('Commonly taken: a line a row, the whole note one tap away',
        (t) async {
      await pump(t, const TtcSupplementsScreen());
      final folic = ttcSuggestedSupplements.first;
      final sentences = folic.noteEn.split(RegExp(r'(?<=[.!?])\s+'));
      expect(sentences.length, greaterThan(1));
      expect(find.text(sentences.first), findsOneWidget);
      expect(find.textContaining(sentences[1]), findsNothing,
          reason: 'the rest of the note is behind More');
      await t.ensureVisible(
          find.byKey(const ValueKey('ttc_supp_more_link_Folic acid')));
      await t.tap(find.byKey(const ValueKey('ttc_supp_more_link_Folic acid')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const ValueKey('ttc_supp_more_Folic acid')), findsOneWidget);
      expect(find.textContaining(sentences[1]), findsOneWidget);
      // Add from the sheet.
      await t.tap(find.text('Add to my list'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(TtcSupplementsStore.instance.forAuthor(TtcAuthor.me).map((e) => e.name),
          contains('Folic acid'));
      await t.pumpAndSettle(const Duration(seconds: 4));
    });

    testWidgets('both holds at 320pt and 1.5x text', (t) async {
      for (final w in [320.0, 360.0]) {
        t.view.physicalSize = Size(w, 8000);
        t.view.devicePixelRatio = 1.0;
        addTearDown(t.view.reset);
        for (final screen in [const TtcSupplementsScreen(), const TtcMedicationScreen()]) {
          await t.pumpWidget(MaterialApp(
            key: UniqueKey(),
            home: MediaQuery(
              data: MediaQueryData(size: Size(w, 8000), textScaler: const TextScaler.linear(1.5)),
              child: screen,
            ),
          ));
          await t.pump();
          await t.pump(const Duration(milliseconds: 600));
          expect(t.takeException(), isNull, reason: '${screen.runtimeType} at $w');
        }
      }
    });
  });

  // ===========================================================================
  group('2. records says what it means', () {
    testWidgets('"Type in a result", and no explainer under a heading',
        (t) async {
      await pump(
          t, const Scaffold(body: SingleChildScrollView(child: TtcRecordsEmpty())));
      expect(find.text('Type in a result'), findsOneWidget);
      expect(find.text('Type a number instead'), findsNothing);
      expect(find.text('What your records become'), findsNothing);
      expect(find.text('The same test, twice'), findsNothing);
      expect(find.text('Photograph a report'), findsOneWidget);
      expect(find.textContaining('yours or his'), findsOneWidget,
          reason: 'the one idea the cards added is a sentence in the panel');
    });
  });

  // ===========================================================================
  group('3. appointments', () {
    final now = DateTime(2026, 10, 1, 22, 0);

    test('the rule: evening before, else 2 hours, else 30 minutes, else none', () {
      // A visit in five days: the evening before.
      var p = ttcApptReminderPlan(DateTime(2026, 10, 6, 10), now: now);
      expect(p.kind, TtcApptReminderKind.eveningBefore);
      expect(p.at, DateTime(2026, 10, 5, 19));
      // Tomorrow 10 am, set at 10 pm tonight: 7 pm has gone. The user's case.
      p = ttcApptReminderPlan(DateTime(2026, 10, 2, 10), now: now);
      expect(p.kind, TtcApptReminderKind.twoHoursBefore);
      expect(p.at, DateTime(2026, 10, 2, 8));
      // In 90 minutes: 2 hours before is gone, 30 minutes is not.
      p = ttcApptReminderPlan(DateTime(2026, 10, 1, 23, 30), now: now);
      expect(p.kind, TtcApptReminderKind.thirtyMinutesBefore);
      expect(p.at, DateTime(2026, 10, 1, 23, 0));
      // In 20 minutes: nothing is left to ring.
      p = ttcApptReminderPlan(DateTime(2026, 10, 1, 22, 20), now: now);
      expect(p.kind, TtcApptReminderKind.none);
      expect(p.at, isNull);
    });

    test('the screen never promises a time that is gone', () {
      expect(ttcApptReminderLine(DateTime(2026, 10, 6, 10), now: now),
          'At 7 pm on ${ttcApptDay(DateTime(2026, 10, 5, 19))}, the evening before.');
      final soon = ttcApptReminderLine(DateTime(2026, 10, 2, 10), now: now);
      expect(soon, contains('evening before has passed'));
      expect(soon, contains('2 hours before'));
      expect(soon, isNot(contains('7 pm')));
      expect(ttcApptReminderLine(DateTime(2026, 10, 1, 22, 20), now: now),
          contains('too soon'));
    });

    test('saving a visit that is too soon switches the reminder off, '
        'and a near one rings the same day', () {
      final store = TtcAppointmentsStore.instance;
      final n = DateTime.now();
      // 3 hours from now: the evening before has gone (unless it is the
      // small hours, where it is still ahead); either way it rings, and says
      // today when it is the same day.
      final near = store.add(
        title: 'Scan',
        startsLocal: n.add(const Duration(hours: 3)),
        remindEveningBefore: true,
      );
      expect(near.remindEveningBefore, isTrue);
      expect(near.remindAtUtc, isNotNull);
      expect(near.reminderAt.isAfter(n), isTrue);
      expect(scheduled, hasLength(1));
      expect(scheduled.single.when, near.reminderAt);
      expect(scheduled.single.title.startsWith('Today:'), isTrue,
          reason: 'a same-day reminder is not "Tomorrow"');
      scheduled.clear();
      // 10 minutes from now: too soon for any.
      final tooSoon = store.add(
        title: 'Blood test',
        startsLocal: n.add(const Duration(minutes: 10)),
        remindEveningBefore: true,
      );
      expect(tooSoon.remindEveningBefore, isFalse);
      expect(tooSoon.remindAtUtc, isNull);
      expect(scheduled.where((x) => x.title.contains('Blood test')), isEmpty,
          reason: 'nothing is set for a visit with no time left');
    });

    test('a visit in some days keeps the evening before, and "Tomorrow"', () {
      final store = TtcAppointmentsStore.instance;
      final start = DateTime.now().add(const Duration(days: 4));
      final a = store.add(
        title: 'Consultation',
        startsLocal: DateTime(start.year, start.month, start.day, 11),
        remindEveningBefore: true,
      );
      expect(a.reminderKind, TtcApptReminderKind.eveningBefore);
      expect(a.reminderAt.hour, 19);
      expect(scheduled.single.title.startsWith('Tomorrow:'), isTrue);
    });

    test('saving again does not move a time that has settled', () {
      final store = TtcAppointmentsStore.instance;
      final a = store.add(
        title: 'Scan',
        startsLocal: DateTime.now().add(const Duration(hours: 5)),
        remindEveningBefore: true,
      );
      final first = a.remindAtUtc;
      store.update(a.copyWith(title: 'Scan, in the morning'));
      final again = store.all.firstWhere((x) => x.id == a.id);
      expect(again.remindAtUtc, first,
          reason: 'a reminder that has rung is not followed by a fresh one');
    });

    test('the settled time survives a reload from storage', () {
      final a = TtcAppointment(
        id: 'x',
        title: 'Scan',
        startsUtc: DateTime.utc(2026, 10, 2, 4, 30),
        remindEveningBefore: true,
        remindAtUtc: DateTime.utc(2026, 10, 2, 2, 30),
      );
      final back = TtcAppointment.fromJson(a.toJson())!;
      expect(back.remindAtUtc, a.remindAtUtc);
      expect(back.reminderKind, TtcApptReminderKind.twoHoursBefore);
      // An old row with no settled time keeps the old rule.
      final old = TtcAppointment.fromJson({
        'id': 'y',
        'title': 'Old',
        'at': DateTime.utc(2026, 10, 9, 5).toIso8601String(),
        'remind': true,
      })!;
      expect(old.remindAtUtc, isNull);
      expect(old.reminderAt.hour, 19);
    });

    testWidgets('date and time are hairline fields, and the reminder line is true',
        (t) async {
      await pump(t, const TtcAppointmentEditScreen());
      expect(t.takeException(), isNull);
      for (final k in ['ttc_appt_day', 'ttc_appt_time']) {
        final boxes = t.widgetList<Container>(find.descendant(
            of: find.byKey(ValueKey(k)), matching: find.byType(Container)));
        final ink = boxes.any((c) {
          final d = c.decoration;
          return d is BoxDecoration &&
              d.border is Border &&
              (d.border as Border).top.color == ttcTitleInk &&
              (d.border as Border).top.width > 1.3;
        });
        expect(ink, isFalse, reason: '$k drew an ink border while untouched');
      }
      final tomorrow10 = () {
        final d = DateTime.now().add(const Duration(days: 1));
        return DateTime(d.year, d.month, d.day, 10);
      }();
      expect(find.text(ttcApptReminderLine(tomorrow10)), findsOneWidget);
      expect(find.text('Remind me before the visit'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('4. the doctor question', () {
    testWidgets('"No particular visit", and a line that says where the tick is',
        (t) async {
      TtcAppointmentsStore.instance.add(
        title: 'Follicle scan',
        startsLocal: DateTime.now().add(const Duration(days: 3)),
      );
      await pump(t, const TtcDoctorQuestionScreen());
      expect(t.takeException(), isNull);
      expect(find.text('No particular visit'), findsOneWidget);
      expect(find.text('Whichever visit comes next'), findsNothing);
      // A visit is chosen by default: the line names it and the circle.
      expect(find.textContaining('tap the circle beside it'), findsOneWidget);
      expect(find.textContaining('If it is not ticked'), findsNothing);
      // The general choice says what it does.
      await t.tap(find.byKey(const ValueKey('ttc_question_visit_next')));
      await t.pump();
      expect(find.textContaining('Not tied to one visit'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('5. medical tests', () {
    testWidgets('a row is a name, one line and a short "when"', (t) async {
      await pump(t, const TtcTestsScreen());
      expect(t.takeException(), isNull);
      expect(find.text('Day 2 or 3 of your cycle'), findsOneWidget);
      expect(find.text('In the morning'), findsOneWidget);
      expect(find.text('Any day'), findsWidgets);
      // The long sentences are on the test's page, not in the list.
      expect(find.textContaining('has to be repeated'), findsNothing);
      expect(find.textContaining('because all of these raise it'), findsNothing);
    });

    test('every test has a short when, and it is short', () {
      for (final test in ttcTestsInOrder(him: false) + ttcTestsInOrder(him: true)) {
        final s = ttcTestWhenShort(test, false);
        expect(s, isNotEmpty, reason: test.id);
        expect(s.length, lessThan(46), reason: '${test.id}: "$s"');
      }
    });
  });

  // ===========================================================================
  group('6. vaccinations', () {
    testWidgets('the eyebrow is the tools\' grey, not violet', (t) async {
      await pump(t, const TtcVaccinesScreen());
      final f = find.text('START WITH ONE BLOOD TEST');
      expect(f, findsOneWidget);
      final color = t.widget<Text>(f).style!.color;
      final p = V2PaletteStore.instance.current;
      expect(color, p.ink3);
      expect(color, isNot(p.action));
    });
  });

  // ===========================================================================
  group('7. the last-check card is one collapsible row everywhere', () {
    Widget card({bool open = false, String line = 'Short.'}) => Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: TtcToolLastCheck(
              key: const ValueKey('card'),
              initiallyOpen: open,
              at: DateTime(2026, 9, 28),
              line: line,
              seeLabel: 'See it',
              onSee: () {},
              againLabel: 'Clear',
              onAgain: () {},
            ),
          ),
        );

    testWidgets('collapsed, it is one row of one height whatever it says',
        (t) async {
      await pump(t, card(line: 'Short.'), height: 900);
      final a = t.getSize(find.byKey(const ValueKey('card'))).height;
      await pump(
          t,
          card(
              line: 'A much longer sentence about what was filled in, which '
                  'runs over several lines on a narrow phone, and says nothing '
                  'more than the short one.'),
          height: 900);
      final b = t.getSize(find.byKey(const ValueKey('card'))).height;
      expect(a, b, reason: 'the row is the same size on every tool');
      expect(a, lessThan(64));
      expect(find.text('See it'), findsNothing, reason: 'closed until opened');
    });

    testWidgets('a tap opens it, and the actions are inside', (t) async {
      await pump(t, card(), height: 900);
      await t.tap(find.byKey(const ValueKey('ttc_tool_last_toggle')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('Short.'), findsOneWidget);
      expect(find.text('See it'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('ttc_tool_last_toggle')));
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('See it'), findsNothing);
      expect(t.takeException(), isNull);
    });

    test('all three tools use the one card, with no flag of their own', () {
      for (final f in [
        'lib/screens/ttc/ttc_pcos_stand_screen.dart',
        'lib/screens/ttc/ttc_ivf_readiness_screen.dart',
        'lib/screens/ttc/ttc_bmi_screen.dart',
      ]) {
        final live = File(f)
            .readAsStringSync()
            .split('\n')
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        expect(live, contains('TtcToolLastCheck('), reason: f);
        expect(live, isNot(contains('compact:')), reason: f);
      }
    });
  });
}
