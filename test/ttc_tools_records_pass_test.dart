// =============================================================================
//  TTC tools pass (2026-09-27): records, tests, vaccines, supplements,
//  medication and appointments
// -----------------------------------------------------------------------------
//  One test per behaviour fixed in docs/TTC-TOOLS-UX-NOTES.md for this area.
//  Every one of them was a tap that did nothing, did the wrong thing without a
//  word, or destroyed something without asking. Those failures are silent by
//  nature, so they are pinned here rather than trusted to a phone walk.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/medication.dart';
import 'package:parentveda/screens/ttc/ttc_appointments_screen.dart';
import 'package:parentveda/screens/ttc/ttc_medication_screen.dart';
import 'package:parentveda/screens/ttc/ttc_records_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_supplements_screen.dart';
import 'package:parentveda/screens/ttc/ttc_tests_screen.dart';
import 'package:parentveda/screens/ttc/ttc_vaccines_screen.dart';
import 'package:parentveda/services/medicine_store.dart';
// Kept for revert (2026-09-28, the user: no journal in trying to conceive).
// import 'package:parentveda/ttc/ttc_journal_store.dart';
// TtcAuthor moved to its own file.
import 'package:parentveda/ttc/ttc_author.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';
import 'package:parentveda/ttc/ttc_supplements_store.dart';
import 'package:parentveda/ttc/ttc_vaccine_store.dart';
import 'package:parentveda/ttc/ttc_vaccines_data.dart';

Future<void> pumpTall(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1200, 8000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump();
}

/// The phone calls the appointments store would have made.
final _scheduled = <({int id, String title, DateTime when})>[];
final _cancelled = <int>[];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcRecordsStore.instance.resetForTest();
    TtcAppointmentsStore.instance.resetForTest();
    // Kept for revert (2026-09-28): TtcJournalStore.instance.resetForTest();
    TtcSupplementsStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    _scheduled.clear();
    _cancelled.clear();
    TtcAppointmentsStore.schedulePhone = ({
      required int id,
      required String title,
      required String body,
      required DateTime when,
    }) async =>
        _scheduled.add((id: id, title: title, when: when));
    TtcAppointmentsStore.cancelPhone = (id) async => _cancelled.add(id);
  });

  // ===========================================================================
  group('records: Save is never a dead tap', () {
    testWidgets('with nothing to save, the button says why', (tester) async {
      await pumpTall(tester, const TtcRecordsScreen());
      await tester.tap(find.text('Type a number instead'));
      await tester.pumpAndSettle();

      expect(find.text('Add a photo or the test name to save.'),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_rec_save')));
      await tester.pumpAndSettle();
      expect(TtcRecordsStore.instance.records, isEmpty);
    });

    testWidgets('typing a name offers the library test, and saves under it',
        (tester) async {
      await pumpTall(tester, const TtcRecordsScreen());
      await tester.tap(find.text('Type a number instead'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'am');
      await tester.pump();
      // The reason goes as soon as there is something to save.
      expect(find.text('Add a photo or the test name to save.'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('ttc_rec_suggest_amh')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_rec_save')));
      await tester.pumpAndSettle();

      final r = TtcRecordsStore.instance.records.single;
      expect(r.testId, 'amh',
          reason: '"Amh test" and "AMH" must land in one group');
      expect(r.label, 'AMH');
    });

    testWidgets('whose it is is a visible two-way switch', (tester) async {
      await pumpTall(tester, const TtcRecordsScreen());
      await tester.tap(find.text('Type a number instead'));
      await tester.pumpAndSettle();
      // The add page (tool rebuild, 2026-09-27) asks it as a question.
      // Was: expect(find.text('WHOSE RESULT IS THIS'), findsOneWidget);
      expect(find.text('Whose result is this?'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Thyroid');
      await tester.tap(find.text("Your partner's"));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_rec_save')));
      await tester.pumpAndSettle();
      expect(TtcRecordsStore.instance.records.single.forPartner, isTrue);
    });
  });

  // ===========================================================================
  group('test library: reading turns into doing', () {
    testWidgets('"Add my result" opens Records with that test chosen',
        (tester) async {
      await pumpTall(tester, const TtcTestsScreen(focusId: 'amh'));
      // ⚠️ LET THE SCROLL TO THE FOCUSED CARD FINISH (2026-09-27). On the
      // tool shell (hero plus a full-height sheet) the page always has room
      // to scroll, so the focus scroll now runs, and a scrollable ignores
      // taps while it animates. Kept for revert: the tap came straight after
      // pumpTall.
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_test_add_amh')));
      await tester.pumpAndSettle();

      // The add form is open on the folder, with AMH already filled in.
      // One add page since the tool rebuild (2026-09-27), titled for what
      // it does. Was: expect(find.text('Type in your result.'), ...);
      expect(find.text('Add a result'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_rec_save')));
      await tester.pumpAndSettle();
      expect(TtcRecordsStore.instance.records.single.testId, 'amh');
    });

    test('her tests start with the everyday blood tests, HSG last', () {
      final ids = ttcTestsInOrder(him: false).map((t) => t.id).toList();
      expect(ids.first, 'tsh');
      expect(ids.last, 'hsg');
    });

    testWidgets('his tab points on to the semen report reader',
        (tester) async {
      await pumpTall(tester, const TtcTestsScreen(focusId: 'semen'));
      expect(find.textContaining('semen analysis report'), findsOneWidget);
    });
  });

  // ===========================================================================
  group('vaccines: "Had it" asks when', () {
    testWidgets('closing the date picker records nothing', (tester) async {
      await pumpTall(tester, const TtcVaccinesScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_vax_mmr_done')));
      await tester.pumpAndSettle();
      // Change 5 (2026-09-28). Was: 'When did you have it?'
      expect(find.text('When did you have the MMR jab?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(TtcVaccineStore.instance.statusOf('mmr'),
          isNot(TtcVaccineStatus.done),
          reason: 'a closed picker must not quietly save today');
    });

    testWidgets('choosing a date records it', (tester) async {
      await pumpTall(tester, const TtcVaccinesScreen());
      await tester.tap(find.byKey(const ValueKey('ttc_vax_varicella_done')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(TtcVaccineStore.instance.statusOf('varicella'),
          TtcVaccineStatus.done);
      final on = TtcVaccineStore.instance.doneOn('varicella')!;
      final now = DateTime.now();
      expect(DateTime(on.year, on.month, on.day),
          DateTime(now.year, now.month, now.day));
      // Tidy up for the next test: this store has no reset.
      await TtcVaccineStore.instance
          .set('varicella', TtcVaccineStatus.unknown);
    });

    testWidgets('the buttons show without opening the card', (tester) async {
      await pumpTall(tester, const TtcVaccinesScreen());
      expect(find.byKey(const ValueKey('ttc_vax_mmr_immune')), findsOneWidget);
      expect(find.text('ONLY IF A RISK APPLIES'), findsOneWidget,
          reason: 'hepatitis B is advised only with a risk');
    });
  });

  // ===========================================================================
  group('supplements: free entry, edit, and ask before removing', () {
    testWidgets('she can add her own, for herself or for him',
        (tester) async {
      await pumpTall(tester, const TtcSupplementsScreen());
      await tester.tap(find.text('Add your own'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Your partner's"));
      await tester.enterText(find.byType(TextField).first, 'Selenium');
      await tester.enterText(find.byType(TextField).last, '50 mcg');
      await tester.tap(find.byKey(const ValueKey('ttc_supp_save')));
      await tester.pumpAndSettle();

      final s = TtcSupplementsStore.instance.items.single;
      expect(s.name, 'Selenium');
      expect(s.dose, '50 mcg');
      expect(s.author, TtcAuthor.partner);
    });

    testWidgets('an empty name says so instead of doing nothing',
        (tester) async {
      await pumpTall(tester, const TtcSupplementsScreen());
      await tester.tap(find.text('Add your own'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_supp_save')));
      await tester.pumpAndSettle();
      expect(find.text('Add a name to save.'), findsOneWidget);
    });

    testWidgets('the dose can be changed, and removing asks first',
        (tester) async {
      final s = TtcSupplementsStore.instance
          .add('Vitamin D', dose: 'As advised');
      TtcSupplementsStore.instance.toggleTaken(s.id);
      await pumpTall(tester, const TtcSupplementsScreen());

      // Rebuilt 2026-09-27 (tool rebuild): the name opens the supplement's
      // own page, and change and remove live there. Kept for revert:
      // await tester.tap(find.text('Edit'));
      await tester.tap(find.text('Vitamin D'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_supp_change')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '1000 IU daily');
      await tester.tap(find.byKey(const ValueKey('ttc_supp_save')));
      await tester.pumpAndSettle();
      final now = TtcSupplementsStore.instance.items.single;
      expect(now.dose, '1000 IU daily');
      expect(TtcSupplementsStore.instance.isTaken(now.id), isTrue,
          reason: 'an edit keeps the id, so it keeps the ticks');

      // Kept for revert (2026-09-27): await tester.tap(find.text('Edit'));
      // The page is still open after the change sheet closed.
      await tester.tap(find.text('Remove from the list'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_no')));
      await tester.pumpAndSettle();
      expect(TtcSupplementsStore.instance.items, hasLength(1));

      await tester.tap(find.text('Remove from the list'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_yes')));
      await tester.pumpAndSettle();
      expect(TtcSupplementsStore.instance.items, isEmpty);
    });

    testWidgets('his CoQ10 can be added after hers', (tester) async {
      TtcSupplementsStore.instance.add('CoQ10');
      await pumpTall(tester, const TtcSupplementsScreen());
      // Two CoQ10 suggestions: hers (already added) and his.
      await tester.tap(find.text('CoQ10').last);
      await tester.pump();
      expect(
          TtcSupplementsStore.instance.forAuthor(TtcAuthor.partner)
              .map((e) => e.name),
          ['CoQ10']);
      expect(find.text("Added to your partner's list"), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });

  // ===========================================================================
  group('medication: a short course stops, an empty name speaks', () {
    // ⚠️ NOT AWAITED, ON PURPOSE. MedicineStore arms real OS alarms after it
    // updates its list, and under flutter_test that platform call never
    // answers inside the fake-async zone, so an `await` hangs the test. The
    // list itself changes synchronously before that call, which is all these
    // tests read.
    tearDown(() {
      for (final m in [...MedicineStore.instance.all]) {
        MedicineStore.instance.deleteMed(m.id);
      }
    });

    testWidgets('Save with no name says so', (tester) async {
      await pumpTall(tester, const TtcMedicationScreen());
      await tester.tap(find.text(const TtcS(false).medAdd));
      await tester.pumpAndSettle();
      await tester.tap(find.text(const TtcS(false).medSave));
      await tester.pumpAndSettle();
      expect(find.text('Add a name to save.'), findsOneWidget);
      expect(MedicineStore.instance.all, isEmpty);
    });

    testWidgets('reminders can be given a last day', (tester) async {
      MedicineStore.instance.addMed(const Medication(
        id: 'm1',
        name: 'Letrozole',
        type: MedType.medication,
        startDateIso: '2026-09-01T00:00:00.000',
        alarms: [
          MedAlarm(id: 'a1', times: [540], repeat: MedAlarmRepeat.daily),
        ],
      ));
      await pumpTall(tester, const TtcMedicationScreen());
      await tester.tap(find.text('Letrozole'));
      await tester.pumpAndSettle();
      // Rebuilt 2026-09-27 (tool rebuild): the name opens the medicine's own
      // page; the form is one tap further, behind "Change". Before, the name
      // opened the form directly.
      await tester.tap(find.byKey(const ValueKey('ttc_med_change')));
      await tester.pumpAndSettle();
      expect(find.text('Every day, no end date'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_med_last_day')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(const TtcS(false).medSave));
      await tester.pumpAndSettle();

      final m = MedicineStore.instance.all.single;
      expect(m.alarms.single.endDateIso, isNotNull,
          reason: 'NotificationService stops the alarm after this day');
    });

    testWidgets('removing asks first', (tester) async {
      MedicineStore.instance.addMed(const Medication(
          id: 'm2',
          name: 'Metformin',
          type: MedType.medication,
          startDateIso: '2026-09-01T00:00:00.000'));
      await pumpTall(tester, const TtcMedicationScreen());
      await tester.tap(find.text('Metformin'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(const TtcS(false).medDelete));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_no')));
      await tester.pumpAndSettle();
      expect(MedicineStore.instance.all, hasLength(1));
    });

    test('the example note names no doctor', () {
      expect(const TtcS(false).medNotesHint, isNot(contains('Rao')));
    });
  });

  // ===========================================================================
  group('appointments: change, remind, ask before removing', () {
    testWidgets('a tap opens it to change, and the change saves',
        (tester) async {
      final a = TtcAppointmentsStore.instance.add(
          title: 'Follicle scan',
          startsLocal: DateTime.now().add(const Duration(days: 3)));
      await pumpTall(tester, const TtcAppointmentsScreen());
      await tester.tap(find.text('Follicle scan'));
      await tester.pumpAndSettle();
      // Tool rebuild (2026-09-27): a tap opens the visit's own page, and
      // "Change details" there opens the form. Was: the tap opened the form.
      await tester.tap(find.byKey(const ValueKey('ttc_appt_change')));
      await tester.pumpAndSettle();
      expect(find.text('Change this appointment'), findsOneWidget);
      // Was: find.text('WHAT IS IT') (the old sheet's capitalised label).
      // Renamed 2026-09-28 (change 5). Kept for revert:
      //   expect(find.text('What is it?'), findsOneWidget,
      expect(find.text('What kind of visit?'), findsOneWidget,
          reason: 'each box keeps its label once she has typed');
      await tester.enterText(find.byType(TextField).first, 'Day 12 scan');
      await tester.tap(find.byKey(const ValueKey('ttc_appt_save')));
      await tester.pumpAndSettle();

      final now = TtcAppointmentsStore.instance.all.single;
      expect(now.id, a.id, reason: 'an edit, not a delete and re-add');
      expect(now.title, 'Day 12 scan');
    });

    testWidgets('Save with no title says so', (tester) async {
      await pumpTall(tester, const TtcAppointmentsScreen());
      // Launch sanity T13 (2026-09-28): an empty list has one Add, the empty
      // card's, under the same key. Was:
      //   await tester.tap(find.text(const TtcS(false).appointmentsAdd).first);
      await tester.tap(find.byKey(const ValueKey('ttc_appt_add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_appt_save')));
      await tester.pumpAndSettle();
      expect(find.text('Add what it is to save.'), findsOneWidget);
      expect(TtcAppointmentsStore.instance.all, isEmpty);
    });

    testWidgets('removing asks first', (tester) async {
      TtcAppointmentsStore.instance.add(
          title: 'Blood test',
          startsLocal: DateTime.now().add(const Duration(days: 2)));
      await pumpTall(tester, const TtcAppointmentsScreen());
      await tester.tap(find.text('Blood test'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove this appointment'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_no')));
      await tester.pumpAndSettle();
      expect(TtcAppointmentsStore.instance.all, hasLength(1));
      await tester.tap(find.text('Remove this appointment'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_confirm_yes')));
      await tester.pumpAndSettle();
      expect(TtcAppointmentsStore.instance.all, isEmpty);
    });

    test('the evening-before reminder rings at 7 pm the day before', () {
      final at = DateTime.now().add(const Duration(days: 5));
      final a = TtcAppointmentsStore.instance.add(
          title: 'IUI',
          startsLocal: DateTime(at.year, at.month, at.day, 9, 30),
          remindEveningBefore: true);
      final want = DateTime(at.year, at.month, at.day)
          .subtract(const Duration(days: 1))
          .add(const Duration(hours: 19));
      expect(_scheduled.single.when, want);
      expect(_scheduled.single.id, ttcAppointmentReminderId(a.id));
      expect(_scheduled.single.title, 'Tomorrow: IUI');
    });

    test('moving it moves the reminder; removing cancels it', () {
      final at = DateTime.now().add(const Duration(days: 5));
      final a = TtcAppointmentsStore.instance.add(
          title: 'Scan', startsLocal: at, remindEveningBefore: true);
      final later = at.add(const Duration(days: 2));
      TtcAppointmentsStore.instance.update(a.copyWith(startsLocal: later));
      expect(_scheduled, hasLength(2));
      expect(_scheduled.last.when.day,
          later.subtract(const Duration(days: 1)).day);

      TtcAppointmentsStore.instance.remove(a.id);
      expect(_cancelled.last, ttcAppointmentReminderId(a.id));
    });

    test('the reminder switch is local, and survives a save to disk', () {
      final a = TtcAppointmentsStore.instance.add(
          title: 'x',
          startsLocal: DateTime.now().add(const Duration(days: 3)),
          remindEveningBefore: true);
      final back = TtcAppointment.fromJson(a.toJson())!;
      expect(back.remindEveningBefore, isTrue);
    });

    test('the reminder id is stable for the same appointment', () {
      expect(ttcAppointmentReminderId('ttca_1'),
          ttcAppointmentReminderId('ttca_1'));
      expect(ttcAppointmentReminderId('ttca_1'),
          isNot(ttcAppointmentReminderId('ttca_2')));
    });
  });

  // ===========================================================================
  group('supplements and medication say which is which', () {
    testWidgets('each screen points to the other', (tester) async {
      await pumpTall(tester, const TtcSupplementsScreen());
      expect(find.textContaining('That goes in Medication'), findsOneWidget);
      await pumpTall(tester, const TtcMedicationScreen());
      expect(find.textContaining('Those go in Supplements'), findsOneWidget);
    });
  });
}
