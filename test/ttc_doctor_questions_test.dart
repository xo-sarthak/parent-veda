// =============================================================================
//  Questions for the doctor: their own store, their own writer (2026-09-28)
// -----------------------------------------------------------------------------
//  The questions used to be journal entries of kind `question`. The journal
//  was commented out of Trying to Conceive, and the questions stayed on the
//  Appointments page as a feature of their own (TtcDoctorQuestionsStore,
//  TtcDoctorQuestionScreen). These tests hold:
//
//   · the store: add, edit (hers only), delete with undo, and persistence
//     across a cold start;
//   · the one-time move of her old questions out of the journal's cache, run
//     twice with no second copy, leaving the old cache untouched;
//   · the Appointments page: a question is written, shown, changed and
//     removed with an Undo, without the journal anywhere.
//
//  The schema half is in test/ttc_schema_contract_test.dart and "the journal
//  is fully off" in test/ttc_journal_out_test.dart.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/profile/pv_doctor_notes_screen.dart';
import 'package:parentveda/screens/ttc/ttc_appointments_screen.dart';
import 'package:parentveda/screens/ttc/ttc_doctor_question_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_visit_today_card.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/ttc_doctor_questions_store.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';

/// What the appointments store asked the phone to schedule.
final _scheduled = <({int id, String title, String body, DateTime when})>[];

/// An entry exactly as the journal wrote it to `ttc_journal`.
String _oldEntry(String id, String kind, String text,
        {String author = 'me', String date = '2026-08-01T21:30:00.000'}) =>
    jsonEncode({
      'id': id,
      'date': date,
      'kind': kind,
      'author': author,
      'text': text,
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final store = TtcDoctorQuestionsStore.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store.resetForTest();
    TtcAppointmentsStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcPartnerMode.instance.on = false;
    _scheduled.clear();
    // The phone, watched: every question change re-arms the visits'
    // evening-before reminders now (2026-09-28).
    TtcAppointmentsStore.schedulePhone = ({
      required int id,
      required String title,
      required String body,
      required DateTime when,
    }) async =>
        _scheduled.add((id: id, title: title, body: body, when: when));
    TtcAppointmentsStore.cancelPhone = (_) async {};
  });

  // ===========================================================================
  group('the store', () {
    test('add: trimmed words, a fresh app id, newest first', () {
      final a = store.add('  Should we test AMH?  ',
          now: DateTime(2026, 9, 1, 10))!;
      store.add('Is my thyroid fine?', now: DateTime(2026, 9, 2, 10));
      expect(a.text, 'Should we test AMH?');
      expect(a.id, startsWith('ttcq_'));
      expect(store.count, 2);
      expect(store.questions.first.text, 'Is my thyroid fine?');
      expect(store.add('   '), isNull, reason: 'empty words are not saved');
      expect(store.count, 2);
    });

    test('edit keeps the id and the written date, and refuses no-ops', () {
      final q = store.add('Ask about AMH', now: DateTime(2026, 9, 1))!;
      expect(store.update(q.id, 'Ask about AMH and FSH'), isTrue);
      final after = store.questions.single;
      expect(after.id, q.id);
      expect(after.writtenAt, q.writtenAt);
      expect(after.text, 'Ask about AMH and FSH');
      expect(after.updatedAt.isAfter(q.updatedAt), isTrue,
          reason: 'the merge clock moves on an edit');
      expect(store.update(q.id, 'Ask about AMH and FSH'), isFalse);
      expect(store.update(q.id, '   '), isFalse);
      expect(store.update('nope', 'x'), isFalse);
    });

    test('delete with undo: the same question comes back', () {
      final q = store.add('Ask about AMH')!;
      final gone = store.remove(q.id);
      expect(gone, isNotNull);
      expect(store.count, 0);
      expect(store.questions, isEmpty);
      expect(store.byId(q.id), isNull);
      store.restore(q.id);
      expect(store.count, 1);
      expect(store.questions.single.id, q.id);
      expect(store.questions.single.text, 'Ask about AMH');
      expect(store.remove('nope'), isNull);
    });

    test('a removed question is kept as a stamped row, so the removal syncs',
        () async {
      final q = store.add('Ask about AMH')!;
      store.remove(q.id);
      await Future<void>.delayed(Duration.zero);
      final p = await SharedPreferences.getInstance();
      final saved = p
          .getStringList('ttc_doctor_questions')!
          .map(TtcDoctorQuestion.decode)
          .single!;
      expect(saved.id, q.id);
      expect(saved.isRemoved, isTrue);
    });

    test('persists across a cold start', () async {
      final q = store.add('Should we test AMH?')!;
      store.add('Is my thyroid fine?');
      final r = store.add('Gone')!;
      store.remove(r.id);
      await Future<void>.delayed(Duration.zero);
      await store.reloadForTest();
      expect(store.count, 2);
      expect(store.questions.map((e) => e.text).toSet(),
          {'Should we test AMH?', 'Is my thyroid fine?'});
      expect(store.byId(q.id)!.writtenAt, q.writtenAt);
      expect(store.byId(r.id), isNull, reason: 'a removal survives a restart');
    });

    test('free text survives encoding; a corrupt row is dropped', () {
      const nasty = 'She said "maybe next month",\nand I wrote: सब ठीक है | ok';
      final q = store.add(nasty)!;
      expect(TtcDoctorQuestion.decode(q.encode())!.text, nasty);
      expect(TtcDoctorQuestion.decode('not json at all'), isNull);
      expect(TtcDoctorQuestion.decode('{"id":1}'), isNull);
    });
  });

  // ===========================================================================
  group('the one-time move out of the journal', () {
    Future<void> seedOldJournal({bool moved = false}) async {
      SharedPreferences.setMockInitialValues({
        TtcDoctorQuestionsStore.kOldJournalKey: [
          _oldEntry('ttcj_1', 'question', 'Should we test AMH?'),
          _oldEntry('ttcj_2', 'memory', 'A quiet evening'),
          _oldEntry('ttcj_3', 'question', 'His question',
              author: 'partner', date: '2026-08-05T09:00:00.000'),
          'not json at all',
        ],
        if (moved) TtcDoctorQuestionsStore.kMigratedFlag: true,
      });
    }

    test('her questions move across with their ids, words and dates',
        () async {
      await seedOldJournal();
      await store.reloadForTest();
      expect(store.count, 2, reason: 'questions only, not the memory');
      final q = store.byId('ttcj_1')!;
      expect(q.text, 'Should we test AMH?');
      expect(q.writtenAt, DateTime.parse('2026-08-01T21:30:00.000'));
      expect(q.isMine, isTrue);
      expect(store.byId('ttcj_3')!.author, TtcAuthor.partner);
      final p = await SharedPreferences.getInstance();
      expect(p.getBool(TtcDoctorQuestionsStore.kMigratedFlag), isTrue);
    });

    test('run twice, there is still one of each', () async {
      await seedOldJournal();
      await store.reloadForTest();
      await store.reloadForTest();
      expect(store.count, 2);
      // Even with the flag lost (say a restore that kept the cache but not
      // the flag), the move skips ids it already has.
      final p = await SharedPreferences.getInstance();
      await p.remove(TtcDoctorQuestionsStore.kMigratedFlag);
      expect(await store.migrateFromJournal(p), isFalse);
      expect(store.count, 2);
    });

    test('once the flag is set, it never runs again', () async {
      await seedOldJournal(moved: true);
      await store.reloadForTest();
      expect(store.count, 0);
    });

    test('a question she removed after the move does not come back',
        () async {
      await seedOldJournal();
      await store.reloadForTest();
      store.remove('ttcj_1');
      await Future<void>.delayed(Duration.zero);
      await store.reloadForTest();
      expect(store.byId('ttcj_1'), isNull);
      expect(store.count, 1);
    });

    test('the old journal cache is read, never changed', () async {
      await seedOldJournal();
      final p = await SharedPreferences.getInstance();
      final before = p.getStringList(TtcDoctorQuestionsStore.kOldJournalKey);
      await store.reloadForTest();
      expect(p.getStringList(TtcDoctorQuestionsStore.kOldJournalKey), before);
    });

    test("her partner's question is his: shown, not changed or removed",
        () async {
      await seedOldJournal();
      await store.reloadForTest();
      expect(store.update('ttcj_3', 'Changed'), isFalse);
      expect(store.remove('ttcj_3'), isNull);
      expect(store.byId('ttcj_3')!.text, 'His question');
    });
  });

  // ===========================================================================
  group('the Appointments page', () {
    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          MaterialApp(key: UniqueKey(), home: const TtcAppointmentsScreen()));
      await tester.pump();
    }

    Future<void> drainSnack(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    }

    testWidgets('adds a question and shows it', (tester) async {
      await pump(tester);
      expect(find.text('Questions for the doctor'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_appt_add_question')));
      await tester.pumpAndSettle();
      expect(find.byType(TtcDoctorQuestionScreen), findsOneWidget);
      expect(find.text('A question for your doctor'), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('ttc_question_text')), 'Is my AMH low?');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_question_save')));
      await tester.pumpAndSettle();
      expect(find.byType(TtcDoctorQuestionScreen), findsNothing);
      expect(find.text('Is my AMH low?'), findsOneWidget);
      expect(store.questions.single.text, 'Is my AMH low?');
      await drainSnack(tester);
    });

    testWidgets('a question opens to be changed, in place', (tester) async {
      final q = store.add('Is my AMH low?')!;
      await pump(tester);
      await tester.tap(find.byKey(ValueKey('ttc_appt_question_${q.id}')));
      await tester.pumpAndSettle();
      expect(find.text('Edit your question'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('ttc_question_text')),
          'Is my AMH low for my age?');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_question_save')));
      await tester.pumpAndSettle();
      expect(find.text('Is my AMH low for my age?'), findsOneWidget);
      expect(store.count, 1);
      expect(store.questions.single.id, q.id);
      await drainSnack(tester);
    });

    testWidgets('delete asks first, then offers an Undo that brings it back',
        (tester) async {
      final q = store.add('Is my AMH low?')!;
      await pump(tester);
      await tester.tap(find.byKey(ValueKey('ttc_appt_question_${q.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ttc_question_delete')));
      await tester.pumpAndSettle();
      expect(find.text('Delete this question?'), findsOneWidget);
      await tester
          .tap(find.byKey(const ValueKey('ttc_question_delete_confirm')));
      await tester.pumpAndSettle();
      expect(store.count, 0);
      expect(find.text('Is my AMH low?'), findsNothing);
      expect(find.text('Question deleted.'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(store.count, 1);
      expect(find.text('Is my AMH low?'), findsOneWidget);
      await drainSnack(tester);
    });
  });

  // ===========================================================================
  //  A question belongs to a visit, and is ticked when asked (2026-09-28)
  // ===========================================================================
  group('a question belongs to a visit', () {
    // Fixed dates far from today, so every answer is decided by the `now`
    // the test passes, never by the day the suite happens to run.
    final mon = DateTime(2030, 1, 7, 10); // Monday 10am
    final wed = DateTime(2030, 1, 9, 11); // Wednesday 11am
    final sun = DateTime(2030, 1, 6, 9); // the day before Monday
    TtcAppointment visit(String title, DateTime at) =>
        TtcAppointmentsStore.instance.add(title: title, startsLocal: at);

    test('a new question goes on her next visit by default', () {
      final a = visit('Scan', mon);
      visit('Consult', wed);
      final q = store.add('Is my lining thick enough?', now: sun)!;
      expect(q.appointmentId, a.id);
      expect(store.visitFor(q, now: sun), a.id);
      expect(store.openCountFor(a.id, now: sun), 1);
    });

    test('she can choose another visit, or whichever comes next', () {
      final a = visit('Scan', mon);
      final b = visit('Consult', wed);
      final onB = store.add('Ask about IUI', now: sun, visitId: b.id)!;
      final floating = store.add('Ask about AMH', now: sun, forNextVisit: true)!;
      expect(onB.appointmentId, b.id);
      expect(floating.appointmentId, isNull);
      expect(store.visitFor(floating, now: sun), a.id,
          reason: 'unpinned means the first visit still to come');
      expect(store.moveTo(onB.id, a.id), isTrue);
      expect(store.visitFor(store.byId(onB.id)!, now: sun), a.id);
      expect(store.moveTo(onB.id, a.id), isFalse, reason: 'no change');
    });

    test('with no visit coming, it waits for the next one she adds', () {
      final q = store.add('Ask about AMH', now: sun)!;
      expect(q.appointmentId, isNull);
      expect(store.waitingForAVisit(now: sun).single.id, q.id);
      final a = visit('Scan', mon);
      expect(store.visitFor(q, now: sun), a.id);
      expect(store.waitingForAVisit(now: sun), isEmpty);
    });

    test('it stays on its visit all day, then rolls to the next (derived)',
        () {
      final a = visit('Scan', mon);
      final b = visit('Consult', wed);
      final q = store.add('Ask about the lining', now: sun)!;
      // Monday evening, after the visit: still Monday's, to tick.
      expect(store.visitFor(q, now: DateTime(2030, 1, 7, 21)), a.id);
      // Tuesday: on Wednesday's visit, and nothing was written to move it.
      expect(store.visitFor(q, now: DateTime(2030, 1, 8, 8)), b.id);
      expect(store.byId(q.id)!.appointmentId, a.id,
          reason: 'the roll-forward is derived, never stored');
      expect(store.notTickedAfter(a.id, now: DateTime(2030, 1, 8, 8)),
          hasLength(1));
    });

    test('moving a visit moves its questions; into the past, they roll', () {
      final a = visit('Scan', mon);
      final b = visit('Consult', wed);
      final q = store.add('Ask about the lining', now: sun)!;
      // Moved later: the question follows the visit it belongs to.
      TtcAppointmentsStore.instance
          .update(a.copyWith(startsLocal: DateTime(2030, 1, 10, 9)));
      expect(store.visitFor(q, now: DateTime(2030, 1, 8)), a.id);
      // Moved into the past: its question rolls to the next visit.
      TtcAppointmentsStore.instance
          .update(a.copyWith(startsLocal: DateTime(2030, 1, 5, 9)));
      expect(store.visitFor(q, now: sun), b.id);
    });

    test('deleting a visit rolls its questions on; Undo brings them back',
        () {
      final a = visit('Scan', mon);
      final b = visit('Consult', wed);
      final q = store.add('Ask about the lining', now: sun)!;
      TtcAppointmentsStore.instance.remove(a.id);
      expect(store.visitFor(q, now: sun), b.id);
      TtcAppointmentsStore.instance.restore(a);
      expect(store.visitFor(q, now: sun), a.id,
          reason: 'the question never stopped naming its visit');
    });

    test('ask, unask and Undo', () {
      final a = visit('Scan', mon);
      final q = store.add('Ask about the lining', now: sun)!;
      final before = store.ask(q.id, visitId: a.id, now: mon)!;
      expect(store.byId(q.id)!.isAsked, isTrue);
      expect(store.openCountFor(a.id, now: mon), 0);
      expect(store.askedAt(a.id).single.id, q.id);
      expect(store.ask(q.id, visitId: a.id), isNull, reason: 'already asked');
      store.revert([before]);
      expect(store.byId(q.id)!.isAsked, isFalse);
      expect(store.openCountFor(a.id, now: mon), 1);
      store.ask(q.id, visitId: a.id, now: mon);
      expect(store.unask(q.id), isTrue);
      expect(store.byId(q.id)!.isAsked, isFalse);
      expect(store.unask(q.id), isFalse);
    });

    test('a rolled question ticked later folds under the visit it was asked at',
        () {
      final a = visit('Scan', mon);
      final b = visit('Consult', wed);
      final q = store.add('Ask about the lining', now: sun)!;
      store.ask(q.id, visitId: b.id, now: wed);
      expect(store.askedAt(b.id).single.id, q.id);
      expect(store.askedAt(a.id), isEmpty);
    });

    test('"Done" ticks what is left; "Keep for the next visit" unpins it',
        () {
      final a = visit('Scan', mon);
      visit('Consult', wed);
      final tue = DateTime(2030, 1, 8, 9);
      store.add('One', now: sun);
      store.add('Two', now: sun);
      expect(store.notTickedAfter(a.id, now: tue), hasLength(2));
      expect(store.notTickedAfter(a.id, now: mon), isEmpty,
          reason: 'not before the day after');

      final done = store.doneAt(a.id, now: tue);
      expect(done, hasLength(2));
      expect(store.askedAt(a.id), hasLength(2));
      expect(store.notTickedAfter(a.id, now: tue), isEmpty);
      store.revert(done);
      expect(store.notTickedAfter(a.id, now: tue), hasLength(2));

      final kept = store.keepForNextVisit(a.id, now: tue);
      expect(kept, hasLength(2));
      expect(store.notTickedAfter(a.id, now: tue), isEmpty);
      expect(store.questions.every((q) => q.appointmentId == null), isTrue);
      store.revert(kept);
      expect(store.notTickedAfter(a.id, now: tue), hasLength(2));
    });

    test('the visit and the tick survive a cold start', () async {
      final a = visit('Scan', mon);
      final q = store.add('Ask about the lining', now: sun)!;
      store.ask(q.id, visitId: a.id, now: mon);
      await Future<void>.delayed(Duration.zero);
      await store.reloadForTest();
      final back = store.byId(q.id)!;
      expect(back.appointmentId, a.id);
      expect(back.askedAt, mon);
    });

    test('a question written before today decodes as unpinned and unasked',
        () {
      final old = TtcDoctorQuestion.decode(jsonEncode({
        'id': 'ttcq_1',
        'text': 'Old',
        'written': '2026-08-01T10:00:00.000',
      }))!;
      expect(old.appointmentId, isNull);
      expect(old.isAsked, isFalse);
    });
  });

  // ===========================================================================
  group('his rows and hers', () {
    Future<void> seedPartner() async {
      SharedPreferences.setMockInitialValues({
        TtcDoctorQuestionsStore.kOldJournalKey: [
          _oldEntry('ttcj_his', 'question', 'Should I get a semen analysis?',
              author: 'partner'),
        ],
      });
      await store.reloadForTest();
    }

    test('both see both; each ticks, moves and edits only their own',
        () async {
      await seedPartner();
      final a = TtcAppointmentsStore.instance
          .add(title: 'Consult', startsLocal: DateTime(2030, 1, 7, 10));
      final mine = store.add('Is my AMH low?', now: DateTime(2030, 1, 6))!;
      expect(store.hasPartnerQuestions, isTrue);
      expect(store.openCountFor(a.id, now: DateTime(2030, 1, 6)), 2,
          reason: 'her visit counts his question too');
      expect(store.ask('ttcj_his', visitId: a.id), isNull);
      expect(store.moveTo('ttcj_his', a.id), isFalse);
      expect(store.update('ttcj_his', 'x'), isFalse);
      expect(store.ask(mine.id, visitId: a.id), isNotNull);
      // "Done" only touches her own.
      expect(
          store.openFor(a.id, now: DateTime(2030, 1, 6)).map((q) => q.id),
          ['ttcj_his']);
    });

    test('labels: Yours, and His on her phone, Hers on his', () async {
      await seedPartner();
      final mine = store.add('Is my AMH low?')!;
      final his = store.byId('ttcj_his')!;
      expect(ttcQuestionWhose(mine), 'Yours');
      expect(ttcQuestionWhose(his), 'His');
      TtcPartnerMode.instance.on = true;
      expect(ttcQuestionWhose(his), 'Hers',
          reason: 'on his phone her rows are hers');
    });

    testWidgets("his Appointments has Add a question, and it saves as his own",
        (tester) async {
      TtcPartnerMode.instance.on = true;
      tester.view.physicalSize = const Size(1200, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          MaterialApp(key: UniqueKey(), home: const TtcAppointmentsScreen()));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_appt_add_question')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('ttc_question_text')),
          'Should I stop cycling before the test?');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ttc_question_save')));
      await tester.pumpAndSettle();
      expect(store.questions.single.isMine, isTrue,
          reason: 'the phone that writes a question owns it');
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('a visit day: her rows have a tick, his do not',
        (tester) async {
      await seedPartner();
      final now = DateTime.now();
      final a = TtcAppointmentsStore.instance.add(
          title: 'Consult',
          startsLocal: DateTime(now.year, now.month, now.day, 23, 59));
      final mine = store.add('Is my AMH low?', visitId: a.id)!;
      tester.view.physicalSize = const Size(1200, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          key: UniqueKey(),
          home: TtcAppointmentScreen(
              entry: ttcApptEntries().firstWhere((e) => e.own?.id == a.id))));
      await tester.pump();
      expect(find.byKey(ValueKey('ttc_question_tick_${mine.id}')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_question_tick_ttcj_his')),
          findsNothing);
      expect(find.textContaining('Yours'), findsWidgets);
      expect(find.textContaining('His'), findsWidgets);

      await tester.tap(find.byKey(ValueKey('ttc_question_tick_${mine.id}')));
      await tester.pumpAndSettle();
      expect(store.byId(mine.id)!.isAsked, isTrue);
      expect(find.text('Asked · 1 question'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(store.byId(mine.id)!.isAsked, isFalse);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });

  // ===========================================================================
  group('the day after a visit', () {
    testWidgets('"Did you get your answers?" says where they moved, and Done',
        (tester) async {
      final now = DateTime.now();
      final y = now.subtract(const Duration(days: 1));
      final t = now.add(const Duration(days: 2));
      final a = TtcAppointmentsStore.instance.add(
          title: 'Follicle scan',
          startsLocal: DateTime(y.year, y.month, y.day, 10));
      TtcAppointmentsStore.instance.add(
          title: 'Blood test', startsLocal: DateTime(t.year, t.month, t.day, 9));
      store.add('Is my lining thick enough?', visitId: a.id);
      store.add('When do we trigger?', visitId: a.id);

      tester.view.physicalSize = const Size(1200, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          MaterialApp(key: UniqueKey(), home: const TtcAppointmentsScreen()));
      await tester.pump();
      // The quiet line on the list, and the rows now on the next visit.
      expect(find.byKey(const ValueKey('ttc_appt_follow_up_line')),
          findsOneWidget);
      expect(find.text('2 questions to ask'), findsOneWidget,
          reason: 'already on the next visit, derived');
      expect(find.textContaining('Moved from').evaluate().isEmpty, isTrue,
          reason: 'the list names the visit each is for, not where from');

      await tester.tap(find.byKey(const ValueKey('ttc_appt_follow_up_line')));
      await tester.pumpAndSettle();
      expect(find.text('Did you get your answers?'), findsOneWidget);
      expect(find.textContaining('moved to your next visit, Blood test'),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_appt_done')));
      await tester.pumpAndSettle();
      expect(store.askedAt(a.id), hasLength(2));
      expect(find.text('Did you get your answers?'), findsNothing);
      expect(find.text('2 questions marked as asked.'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(store.askedAt(a.id), isEmpty);

      await tester.tap(find.byKey(const ValueKey('ttc_appt_keep_next')));
      await tester.pumpAndSettle();
      expect(store.questions.every((q) => q.appointmentId == null), isTrue);
      expect(find.text('Did you get your answers?'), findsNothing);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });

  // ===========================================================================
  group('the evening-before reminder', () {
    test('says how many questions, and nothing new when there are none', () {
      final a = TtcAppointment(
          id: 'ttca_1',
          title: 'IUI',
          startsUtc: DateTime(2030, 1, 7, 9, 30).toUtc(),
          withWhom: 'Dr Rao');
      final none = TtcAppointmentsStore.reminderText(a);
      expect(none.title, 'Tomorrow: IUI');
      expect(none.body, 'At 9:30am, with Dr Rao.',
          reason: 'unchanged with no questions');
      final two = TtcAppointmentsStore.reminderText(a, questions: 2);
      expect(two.title, 'Tomorrow: IUI');
      expect(two.body, 'At 9:30am, with Dr Rao · 2 questions to ask.');
      expect(TtcAppointmentsStore.reminderText(a, questions: 1).body,
          'At 9:30am, with Dr Rao · 1 question to ask.');
    });

    test('updates when a question is added, ticked away or the visit moves',
        () {
      final at = DateTime.now().add(const Duration(days: 5));
      final a = TtcAppointmentsStore.instance.add(
          title: 'IUI',
          startsLocal: DateTime(at.year, at.month, at.day, 9, 30),
          remindEveningBefore: true);
      expect(_scheduled.last.body, 'At 9:30am.');
      final q = store.add('Is the timing right?')!;
      expect(q.appointmentId, a.id);
      expect(_scheduled.last.body, 'At 9:30am · 1 question to ask.');
      store.remove(q.id);
      expect(_scheduled.last.body, 'At 9:30am.');
      store.restore(q.id);
      TtcAppointmentsStore.instance.update(a.copyWith(
          startsLocal: DateTime(at.year, at.month, at.day, 11)));
      expect(_scheduled.last.body, 'At 11:00am · 1 question to ask.');
    });

    test("counts, as of the evening it rings, the previous visit's leftovers",
        () {
      final now = DateTime.now();
      final d1 = now.add(const Duration(days: 3));
      final d3 = now.add(const Duration(days: 5));
      final first = TtcAppointmentsStore.instance.add(
          title: 'Scan', startsLocal: DateTime(d1.year, d1.month, d1.day, 9));
      final second = TtcAppointmentsStore.instance.add(
          title: 'Consult',
          startsLocal: DateTime(d3.year, d3.month, d3.day, 9),
          remindEveningBefore: true);
      store.add('Left over from the scan', visitId: first.id);
      // The second visit's reminder rings the evening before it, after the
      // scan's day is over, so the unticked scan question is on it by then.
      expect(
          store.openCountFor(second.id, now: second.reminderAt), 1);
      expect(_scheduled.last.id, ttcAppointmentReminderId(second.id));
      expect(_scheduled.last.body, 'At 9:00am · 1 question to ask.');
    });
  });

  // ===========================================================================
  group('where the questions are needed', () {
    Future<void> pumpAt(WidgetTester tester, Widget w,
        {Size size = const Size(1200, 4000), double dpr = 1}) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = dpr;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: w));
      await tester.pump();
    }

    testWidgets('the home card shows only on the day of a visit',
        (tester) async {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      TtcAppointmentsStore.instance.add(
          title: 'Blood test',
          startsLocal:
              DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9));
      await pumpAt(tester, const Scaffold(body: TtcVisitTodayCard()));
      expect(find.byKey(const ValueKey('ttc_home_visit_today')), findsNothing,
          reason: 'no visit today, no card');

      final a = TtcAppointmentsStore.instance.add(
          title: 'Follicle scan',
          startsLocal: DateTime(now.year, now.month, now.day, 23, 30));
      store.add('Is my lining thick enough?', visitId: a.id);
      store.add('When do we trigger?', visitId: a.id);
      await tester.pump();
      expect(find.byKey(const ValueKey('ttc_home_visit_today')),
          findsOneWidget);
      expect(find.text('Follicle scan today at 11:30pm'), findsOneWidget);
      expect(find.text('2 questions to ask'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ttc_home_visit_today')));
      await tester.pumpAndSettle();
      expect(find.byType(TtcAppointmentScreen), findsOneWidget,
          reason: 'the card opens that visit');
    });

    test('the home card is wired into her home, and only hers', () {
      final home =
          File('lib/screens/ttc/ttc_home_v3.dart').readAsStringSync();
      expect(home, contains('_pad(const TtcVisitTodayCard())'));
      final his =
          File('lib/screens/ttc/ttc_partner_screen.dart').readAsStringSync();
      expect(his.contains('TtcVisitTodayCard'), isFalse);
    });

    testWidgets("the doctor's note ends with the questions to ask",
        (tester) async {
      final at = DateTime.now().add(const Duration(days: 4));
      final a = TtcAppointmentsStore.instance.add(
          title: 'Consultation',
          startsLocal: DateTime(at.year, at.month, at.day, 10));
      store.add('Should we test AMH?');
      final later = TtcAppointmentsStore.instance.add(
          title: 'Scan', startsLocal: at.add(const Duration(days: 3)));
      store.add('Not for this visit', visitId: later.id);
      await pumpAt(tester,
          const PvDoctorNotesScreen(stage: LifeStage.tryingToConceive),
          size: const Size(1200, 8000));
      final title =
          'Questions to ask at the Consultation, ${ttcApptDay(a.startsLocal)}';
      expect(find.text(title), findsOneWidget);
      expect(find.text('Should we test AMH?'), findsOneWidget);
      expect(find.text('Not for this visit'), findsNothing,
          reason: 'only the next visit');
      // Last of the sections: nothing titled after it but the disclaimer.
      final titles = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .toList();
      expect(titles.indexOf(title),
          greaterThan(titles.indexOf('Medicines and supplements')));
    });

    testWidgets("the doctor's note with none says where to write them",
        (tester) async {
      await pumpAt(tester,
          const PvDoctorNotesScreen(stage: LifeStage.tryingToConceive),
          size: const Size(1200, 8000));
      expect(find.text('Questions to ask'), findsOneWidget);
      expect(
          find.text(
              'No questions saved. Write them on Appointments, under Tools.'),
          findsOneWidget);
    });

    testWidgets('a visit is named once over its questions, never per row',
        (tester) async {
      final now = DateTime.now();
      final y = now.subtract(const Duration(days: 1));
      final t = now.add(const Duration(days: 3));
      final past = TtcAppointmentsStore.instance.add(
          title: 'Scan', startsLocal: DateTime(y.year, y.month, y.day, 10));
      final next = TtcAppointmentsStore.instance.add(
          title: 'Consult', startsLocal: DateTime(t.year, t.month, t.day, 10));
      store.add('One', visitId: next.id);
      store.add('Two', visitId: next.id);
      store.add('Three', visitId: past.id);
      store.add('Four', visitId: past.id);
      // The list: one heading for the Consult's four.
      await pumpAt(tester, const TtcAppointmentsScreen(),
          size: const Size(1200, 8000));
      expect(find.text('For the ${ttcVisitName(store.visitById(next.id)!)}'),
          findsOneWidget);
      // The Consult's page: its own two, then one "Moved from" heading over
      // the Scan's two.
      await pumpAt(
          tester,
          TtcAppointmentScreen(
              entry: ttcApptEntries().firstWhere((e) => e.own?.id == next.id)),
          size: const Size(1200, 8000));
      expect(
          find.text('Moved from the ${ttcVisitName(store.visitById(past.id)!)}'),
          findsOneWidget);
      for (final w in ['One', 'Two', 'Three', 'Four']) {
        expect(find.text(w), findsOneWidget);
      }
    });

    group('no overflow at 360dp', () {
      Future<void> at360(WidgetTester tester, Widget w) async {
        await pumpAt(tester, w, size: const Size(360 * 3, 800 * 3), dpr: 3);
        expect(tester.takeException(), isNull);
        final list = find.byType(Scrollable);
        if (list.evaluate().isNotEmpty) {
          for (var i = 0; i < 8; i++) {
            await tester.drag(list.first, const Offset(0, -400));
            await tester.pump(const Duration(milliseconds: 100));
            expect(tester.takeException(), isNull);
          }
        }
      }

      void seed() {
        final now = DateTime.now();
        final y = now.subtract(const Duration(days: 1));
        final soon = now.add(const Duration(days: 2));
        final past = TtcAppointmentsStore.instance.add(
            title: 'Follicle scan with a long name for a narrow phone',
            withWhom: 'Dr Radhika Venkataraman, Bloom Fertility Centre',
            startsLocal: DateTime(y.year, y.month, y.day, 10));
        TtcAppointmentsStore.instance.add(
            title: 'Consultation about the next round of treatment',
            startsLocal: DateTime(soon.year, soon.month, soon.day, 9),
            remindEveningBefore: true);
        store.add(
            'Is my lining thick enough for a transfer this month, or should '
            'we wait for the next cycle?',
            visitId: past.id);
        store.add('When do we take the trigger injection?');
      }

      testWidgets('the Appointments list', (tester) async {
        seed();
        await at360(tester, const TtcAppointmentsScreen());
      });

      testWidgets("a past visit's page with the follow-up card",
          (tester) async {
        seed();
        final e = ttcApptEntries().first;
        await at360(tester, TtcAppointmentScreen(entry: e));
        expect(find.text('Did you get your answers?'), findsOneWidget);
      });

      testWidgets('the writer with its visit choices', (tester) async {
        seed();
        await at360(tester, const TtcDoctorQuestionScreen());
        expect(find.text('For which visit?'), findsOneWidget);
      });

      testWidgets('the home card', (tester) async {
        final now = DateTime.now();
        final a = TtcAppointmentsStore.instance.add(
            title: 'Follicle scan with a long name for a narrow phone',
            startsLocal: DateTime(now.year, now.month, now.day, 23, 30));
        store.add('One', visitId: a.id);
        await at360(tester, const Scaffold(body: TtcVisitTodayCard()));
      });
    });
  });
}
