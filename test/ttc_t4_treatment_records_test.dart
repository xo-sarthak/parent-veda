// T4: TTC treatment and records (docs/preg-ttc-tool-plans/T4-treatment-records.md).
//
// One test per decision the build made, named by its finding id. The sync
// fixes (B1, B2, B3, W12) are tested on the pure functions the stores now
// call, because the network calls around them cannot run here; the source
// checks that follow prove each pure function is the one the store calls.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/medication.dart';
import 'package:parentveda/screens/ttc/ttc_appointments_screen.dart';
import 'package:parentveda/screens/ttc/ttc_calendar_screen.dart'
    show ttcCalendarClinicLines;
import 'package:parentveda/screens/ttc/ttc_medication_screen.dart'
    show ttcMedRepeatLine, ttcMedChangeToast;
import 'package:parentveda/screens/ttc/ttc_records_v2.dart';
import 'package:parentveda/screens/ttc/ttc_round_strings.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart'
    show kTtcHisToolIds;
import 'package:parentveda/screens/ttc/ttc_treatment_screen.dart';
import 'package:parentveda/services/notification_service.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';
import 'package:parentveda/ttc/ttc_semen_limits.dart';
import 'package:parentveda/ttc/ttc_semen_reading.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_round.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

const _old = '2020-01-01T00:00:00.000Z';
const _new = '2100-01-01T00:00:00.000Z';

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _plus(int n) {
  final t = _today();
  return DateTime(t.year, t.month, t.day + n);
}

String _src(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// [s] without its comment lines, so a "kept for revert" line is not code.
String _live(String s) => s
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

/// The body of one Dart member, from its signature to the next blank-line
/// member at the same depth. Good enough for "this guard is in that method".
String _member(String body, String signature) {
  final i = body.indexOf(signature);
  expect(i, greaterThan(-1), reason: 'no $signature');
  final end = body.indexOf('\n  }\n', i);
  return body.substring(i, end < 0 ? body.length : end);
}

Map<String, dynamic> _recordRow(String id,
        {String owner = 'her',
        Object? files,
        bool forPartner = false,
        String at = _new}) =>
    {
      'id': id,
      'user_id': owner,
      'label': 'AMH',
      'value': '2.1',
      'unit': 'ng/mL',
      'taken_on': '2026-09-06',
      'for_partner': forPartner,
      'updated_at': at,
      'removed_at': null,
      'files': ?files,
    };

Medication _med({
  bool active = true,
  String? start,
  String title = '',
  MedAlarmRepeat repeat = MedAlarmRepeat.daily,
  List<int> weekdays = const [],
}) =>
    Medication(
      id: 'ttcm_1',
      name: 'Letrozole',
      type: MedType.medication,
      dose: '2.5 mg',
      startDateIso: DateTime.now().toIso8601String(),
      isActive: active,
      alarms: [
        MedAlarm(
          id: 'a1',
          title: title,
          times: const [23 * 60 + 59],
          repeat: repeat,
          weekdays: weekdays,
          startDateIso: start,
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(360, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: child));
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull, reason: 'threw or overflowed');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    await TtcRecordsStore.instance.ensureLoaded();
  });

  setUp(() {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    TtcRecordsStore.instance.resetForTest();
    TtcAppointmentsStore.instance.resetForTest();
    TtcPartnerMode.instance.on = false;
    TtcLang.instance.hinglish = false;
  });

  tearDown(() => TtcPartnerMode.instance.on = false);

  // ===========================================================================
  group('B1 and B2: one writer for the round', () {
    // His row is the newer one, which is exactly how his stale copy won.
    final rows = [
      {'user_id': 'him', 'cycle': {'kind': 'ivfFresh'}, 'updated_at': _new},
      {'user_id': 'her', 'cycle': {'kind': 'iui'}, 'updated_at': _old},
    ];

    test('her phone reads her row, though his is newer', () {
      final r = ttcPickTreatmentRow(rows, myId: 'her', partnerMode: false);
      expect(r?['user_id'], 'her');
    });

    test('his phone reads her row too, never his own', () {
      final r = ttcPickTreatmentRow(rows, myId: 'him', partnerMode: true);
      expect(r?['user_id'], 'her');
    });

    test('her phone with no row of its own takes nothing', () {
      final r = ttcPickTreatmentRow([rows.first],
          myId: 'her', partnerMode: false);
      expect(r, isNull);
    });

    test('the store calls the picker, never pushes or arms on his side', () {
      final body = _src('lib/ttc/ttc_treatment_store.dart');
      expect(_member(body, 'Future<void> pullFromCloud()'),
          contains('ttcPickTreatmentRow('));
      expect(_live(_member(body, 'Future<void> pullFromCloud()')),
          isNot(contains('rows.first')));
      expect(_member(body, 'Future<void> pushToCloud()'),
          contains('if (TtcPartnerMode.instance.on) return;'));
      final arm = _member(body, 'Future<void> _rescheduleTrigger()');
      // The cancels come first, so switching sides clears a held alarm.
      expect(arm.indexOf('cancel(triggerNotificationId)'),
          lessThan(arm.indexOf('if (TtcPartnerMode.instance.on) return;')));
    });
  });

  // ===========================================================================
  group('B3: the scans travel with the record', () {
    final store = TtcRecordsStore.instance;

    test('a cloud row with files gives the record its files', () {
      store.applyCloudRows(
          [_recordRow('ttcr_a', files: ['media/her/ttc_record/1.jpg'])]);
      expect(store.records.single.attachments, ['media/her/ttc_record/1.jpg']);
    });

    test('a sign-out, then the pull, keeps the attachments', () {
      store.applyCloudRows([_recordRow('ttcr_a', files: ['media/her/x.pdf'])]);
      store.resetLocal(); // what a sign-out does to the store's memory
      expect(store.records, isEmpty);
      store.applyCloudRows([_recordRow('ttcr_a', files: ['media/her/x.pdf'])]);
      expect(store.records.single.attachments, ['media/her/x.pdf']);
    });

    test('a row from before 0127 (null files) keeps the local list', () {
      final r = store.add(label: 'AMH', takenOn: DateTime(2026, 9, 6));
      store.replace(r.copyWith(attachments: ['local/scan.pdf']));
      store.applyCloudRows([_recordRow(r.id, owner: 'me')]);
      expect(store.records.single.attachments, ['local/scan.pdf']);
    });

    test('an empty list from the cloud clears them', () {
      expect(ttcFilesFromCloud(const []), isEmpty);
      expect(ttcFilesFromCloud(null), isNull);
    });

    test('the push sends `files`, and the migration adds it', () {
      final body = _src('lib/ttc/ttc_records_store.dart');
      expect(_member(body, 'static Map<String, dynamic> _cloudColumns(TtcRecord r)'),
          contains("'files': r.attachments,"));
      final sql = _src(
          'supabase/migrations/0127_ttc_records_files_and_own_writes.sql');
      expect(sql, contains('add column if not exists files jsonb'));
    });
  });

  // ===========================================================================
  group('Q2 in the database: each partner writes only their own', () {
    final sql =
        _src('supabase/migrations/0127_ttc_records_files_and_own_writes.sql');

    test('the couple-wide ALL policy goes, four own-row policies come', () {
      expect(sql, contains('drop policy if exists ttc_records_couple'));
      expect(sql, contains('for select using (auth.uid() = user_id or '
          'user_id = public.my_partner_id())'));
      expect(sql, contains('for insert with check (auth.uid() = user_id)'));
      expect(sql, contains('for update using (auth.uid() = user_id) '
          'with check (auth.uid() = user_id)'));
      expect(sql, contains('for delete using (auth.uid() = user_id)'));
    });

    test('the app never sends a row the other account owns', () {
      final push = _member(_src('lib/ttc/ttc_records_store.dart'),
          'Future<void> pushToCloud()');
      expect(push, contains('if (owner != null && owner != uid)'));
    });
  });

  // ===========================================================================
  group('W12: a removed scan leaves storage once the removal is final', () {
    const day = 24 * 60 * 60 * 1000;
    final now = DateTime.utc(2026, 10, 29).millisecondsSinceEpoch;

    test('an old removal deletes its files; a fresh one waits', () {
      final due = ttcFilesDueForSweep({
        'old': (at: now - 81 * day, files: ['media/her/a.jpg']),
        'new': (at: now - 2 * day, files: ['media/her/b.jpg']),
      }, liveIds: const {}, nowMs: now);
      expect(due.delete, ['media/her/a.jpg']);
      expect(due.drop, {'old'});
    });

    test('a removal that was undone deletes nothing', () {
      final due = ttcFilesDueForSweep({
        'back': (at: now - 81 * day, files: ['media/her/a.jpg']),
      }, liveIds: const {'back'}, nowMs: now);
      expect(due.delete, isEmpty);
      expect(due.drop, {'back'});
    });

    test('remove queues the files; Undo takes them off the queue', () {
      final store = TtcRecordsStore.instance;
      final r = store.add(label: 'AMH', takenOn: DateTime(2026, 9, 6));
      store.replace(r.copyWith(attachments: ['media/her/c.jpg']));
      final kept = store.records.single;
      store.remove(r.id);
      expect(store.sweepForTest.keys, contains(r.id));
      store.restore([kept]);
      expect(store.sweepForTest.keys, isNot(contains(r.id)));
    });
  });

  // ===========================================================================
  group('W6, W7, Q4: what a medicine rings', () {
    final now = DateTime.now();

    String due(String name, String dose) => 'Take $name $dose';

    test('a stopped medicine rings nothing', () {
      expect(
          NotificationService.medicationOccurrences(_med(active: false), now,
              dueBody: due),
          isEmpty);
      expect(
          NotificationService.medicationOccurrences(_med(), now, dueBody: due),
          isNotEmpty);
    });

    test('nothing rings before the first day', () {
      final start = _plus(5);
      final occ = NotificationService.medicationOccurrences(
          _med(start: start.toIso8601String()), now,
          dueBody: due);
      expect(occ, isNotEmpty);
      expect(occ.every((o) => !o.when.isBefore(start)), isTrue);
    });

    test('a TTC-saved alarm names no medicine, title or body', () {
      final occ = NotificationService.medicationOccurrences(
          _med(title: kPrivateMedAlarmTitle), now,
          dueBody: due);
      expect(occ.first.title, 'Time for your medicine');
      expect(occ.first.title, isNot(contains('Letrozole')));
      expect(occ.first.body, isNot(contains('Letrozole')));
    });

    test('Pregnancy keeps its own titles and names', () {
      final occ =
          NotificationService.medicationOccurrences(_med(), now, dueBody: due);
      expect(occ.first.title, 'Letrozole');
      expect(occ.first.body, contains('Letrozole'));
    });

    test('the TTC sheet writes the private title and the first day', () {
      final sheet = _src('lib/screens/ttc/ttc_medication_screen.dart');
      expect(sheet, contains('title: kPrivateMedAlarmTitle,'));
      expect(sheet, contains('startDateIso: firstIso,'));
      expect(sheet, contains("'Reminders start on "));
    });

    test('W9: the page says the alarm\'s own repeat', () {
      expect(ttcMedRepeatLine(_med()), 'every day');
      expect(
          ttcMedRepeatLine(_med(
              repeat: MedAlarmRepeat.weekly, weekdays: const [1, 4])),
          'on Mondays and Thursdays');
    });

    test('K7: an edit says what changed', () {
      final a = _med();
      final b = Medication(
          id: a.id,
          name: a.name,
          type: a.type,
          dose: '5 mg',
          startDateIso: a.startDateIso,
          alarms: a.alarms);
      expect(ttcMedChangeToast(a, b), 'Dose changed.');
    });
  });

  // ===========================================================================
  group('W10 and Q3: whose, from the side the phone is on', () {
    test('his result reads "You" on his phone, "Partner" on hers', () {
      expect(ttcWhoseFor(true, true), 'You');
      expect(ttcWhoseFor(true, false), 'Partner');
      expect(ttcWhoseFor(false, true), 'Partner');
      expect(ttcWhoseFor(false, true, long: true), "Your partner's");
    });

    test('"Yours" on his phone files for_partner true', () {
      TtcPartnerMode.instance.on = true;
      expect(ttcMineFlag(), isTrue);
      TtcPartnerMode.instance.on = false;
      expect(ttcMineFlag(), isFalse);
    });

    test('his Tools carry his own Medication', () {
      expect(kTtcHisToolIds, contains('medication'));
    });
  });

  // ===========================================================================
  group('W11: he reads her results and changes only his own', () {
    testWidgets('her result on his phone has no Change or Remove',
        (tester) async {
      TtcPartnerMode.instance.on = true;
      TtcRecordsStore.instance
          .applyCloudRows([_recordRow('ttcr_hers', owner: 'her')]);
      await _pump(tester, const TtcRecordDetailScreen(recordId: 'ttcr_hers'));
      expect(find.byKey(const ValueKey('ttc_rec_detail_remove')), findsNothing);
      expect(find.byKey(const ValueKey('ttc_rec_edit')), findsNothing);
      expect(find.text(kTtcHersToChange), findsOneWidget);
    });

    testWidgets('a result made on this phone keeps both', (tester) async {
      final r = TtcRecordsStore.instance
          .add(label: 'AMH', takenOn: DateTime(2026, 9, 6), value: '2');
      await _pump(tester, TtcRecordDetailScreen(recordId: r.id));
      expect(find.byKey(const ValueKey('ttc_rec_detail_remove')),
          findsOneWidget);
    });
  });

  // ===========================================================================
  group('Q1: her round on his phone, read-only', () {
    testWidgets('no edit is drawn, and the one control says why',
        (tester) async {
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {
            TtcTreatmentStep.stimStart: _plus(-3),
            TtcTreatmentStep.retrieval: _plus(8),
          });
      TtcPartnerMode.instance.on = true;
      await _pump(tester, const TtcTreatmentScreen());
      expect(find.byKey(const ValueKey('ttc_round_his_view')), findsOneWidget);
      expect(find.text(kTtcPartnerRoundEyebrow), findsWidgets);
      for (final k in [
        'ttc_round_remove',
        'ttc_round_plan_changed',
        'ttc_round_pause',
        'ttc_round_clinic',
        'ttc_round_tell_result',
      ]) {
        expect(find.byKey(ValueKey(k)), findsNothing, reason: k);
      }
      await tester.tap(find.byKey(const ValueKey('ttc_round_his_note')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(kTtcHersToChange), findsOneWidget);
      // Let the toast's timer run out inside the test.
      await tester.pump(const Duration(seconds: 6));
    });
  });

  // ===========================================================================
  group('TTC-GAP 25: the title names today\'s step', () {
    final store = TtcTreatmentStore.instance;
    String title() =>
        ttcTreatmentTitle(store.cycle, store, DateTime.now(), partner: false);

    test('no round', () {
      expect(title(), "Your clinic's dates, in one place.");
    });

    test('a kind and no dates', () {
      store.startRound(kind: TtcRoundKind.ivfFresh);
      expect(title(), 'No dates yet.');
    });

    test('planned', () {
      store.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.stimStart: _plus(4)});
      expect(title(), startsWith('Starts '));
    });

    test('stimulation, with its day', () {
      store.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.stimStart: _plus(-5)});
      expect(title(), 'Stimulation, day 6.');
    });

    test('the wait, with its day', () {
      store.startRound(kind: TtcRoundKind.ivfFresh, dates: {
        TtcTreatmentStep.stimStart: _plus(-20),
        TtcTreatmentStep.retrieval: _plus(-8),
        TtcTreatmentStep.transfer: _plus(-3),
        TtcTreatmentStep.betaTest: _plus(6),
      });
      expect(title(), startsWith('The wait'));
    });

    test('test day, then waiting to hear', () {
      store.startRound(kind: TtcRoundKind.ivfFresh, dates: {
        TtcTreatmentStep.stimStart: _plus(-25),
        TtcTreatmentStep.transfer: _plus(-10),
        TtcTreatmentStep.betaTest: _today(),
      });
      expect(title(), 'Test day.');
      store.setDate(TtcTreatmentStep.betaTest, _plus(-1));
      expect(title(), 'Waiting to hear.');
    });

    test('an older round with no kind keeps the old title', () {
      store.setDate(TtcTreatmentStep.retrieval, _plus(3));
      expect(store.cycle.kind, isNull);
      expect(title(), 'The dates your clinic gave you.');
    });

    test('after a close: between rounds, or a break', () {
      store.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.stimStart: _plus(-20)});
      store.closeRound(TtcRoundOutcome.negative);
      expect(title(), 'Between rounds.');
      store.undoClose();
      store.closeRound(TtcRoundOutcome.paused);
      expect(title(), 'Taking a break.');
    });

    test('his phone: "Her round", and never a result', () {
      store.startRound(kind: TtcRoundKind.ivfFresh, dates: {
        TtcTreatmentStep.stimStart: _plus(-25),
        TtcTreatmentStep.betaTest: _plus(-1),
      });
      expect(
          ttcTreatmentTitle(store.cycle, store, DateTime.now(), partner: true),
          'Her round');
      // Waiting to hear: his line is null, so the intro names no result.
      final intro = ttcPartnerTreatmentIntro(store.cycle, DateTime.now());
      expect(intro.toLowerCase(), isNot(contains('positive')));
      expect(intro.toLowerCase(), isNot(contains('negative')));
      expect(intro, contains('hers to share'));
    });
  });

  // ===========================================================================
  group('W2, W3, W4, W5: the words match what happens', () {
    test('W2: an IUI round is "Medicines and scans"', () {
      expect(ttcRoundPhaseName(TtcRoundPhase.stimulation, TtcRoundKind.iui),
          'Medicines and scans');
    });

    test('W3: a round with no kind names no egg collection', () {
      final b = ttcTriggerPrepBody(null, DateTime(2026, 10, 29, 22, 15));
      expect(b, contains('10:15pm'));
      expect(b.toLowerCase(), isNot(contains('egg collection')));
    });

    test('W4: the reads promise what is there', () {
      expect(_live(_src('lib/ttc/reads/ttc_reads_age.dart')),
          isNot(contains("_en('Scans, sizes and the trigger, in one place.')")));
      expect(_src('lib/ttc/reads/ttc_reads_ivf.dart'),
          contains('shared with him to see.'));
    });

    test('W5: the reminder line only while one is to come', () {
      final at = DateTime.now().add(const Duration(hours: 6));
      var r = TtcTreatmentCycle(
          dates: {TtcTreatmentStep.trigger: at}, kind: TtcRoundKind.ivfFresh);
      expect(ttcTriggerReminderLine(r, DateTime.now()), contains('4 hours'));
      r = TtcTreatmentCycle(
          dates: {TtcTreatmentStep.trigger: at},
          kind: TtcRoundKind.ivfFresh,
          triggerTaken: true);
      expect(ttcTriggerReminderLine(r, DateTime.now()),
          'Taken. Reminders are off.');
      r = TtcTreatmentCycle(dates: {
        TtcTreatmentStep.trigger:
            DateTime.now().subtract(const Duration(hours: 1)),
      }, kind: TtcRoundKind.ivfFresh);
      expect(ttcTriggerReminderLine(r, DateTime.now()), isNull);
      final soon = TtcTreatmentCycle(dates: {
        TtcTreatmentStep.trigger: DateTime.now().add(const Duration(hours: 2)),
      }, kind: TtcRoundKind.ivfFresh);
      expect(ttcTriggerReminderLine(soon, DateTime.now()),
          contains('15 minutes before'));
      expect(ttcTriggerReminderLine(soon, DateTime.now()),
          isNot(contains('4 hours')));
    });
  });

  // ===========================================================================
  group('K1, K2, K3, K4: the round after a close, a removal, OHSS, today', () {
    testWidgets('K1: after a close the tool shows Between rounds',
        (tester) async {
      final store = TtcTreatmentStore.instance;
      store.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.stimStart: _plus(-20)});
      store.closeRound(TtcRoundOutcome.negative);
      await _pump(tester, const TtcTreatmentScreen());
      expect(find.text('Between rounds.'), findsOneWidget);
      expect(find.byKey(const ValueKey('ttc_ivf_panel_between')),
          findsOneWidget);
    });

    test('K2: removing the dates keeps the round, apart from history', () {
      final store = TtcTreatmentStore.instance;
      store.startRound(
          kind: TtcRoundKind.iui,
          dates: {TtcTreatmentStep.stimStart: _plus(2)});
      final id = store.cycle.id;
      store.clearCycle();
      expect(store.cycle.isEmpty, isTrue);
      expect(store.history, isEmpty, reason: 'a mistake is not a past round');
      expect(store.clearedForTest.single.id, id);
      expect(store.undoClear(), isTrue);
      expect(store.cycle.id, id);
      expect(store.cycle[TtcTreatmentStep.stimStart], _plus(2));
    });

    test('K3: the red-flag line shows in the wait, and not for an IUI', () {
      final ivf = TtcTreatmentCycle(dates: {
        TtcTreatmentStep.retrieval: _plus(-6),
        TtcTreatmentStep.transfer: _plus(-1),
        TtcTreatmentStep.betaTest: _plus(8),
      }, kind: TtcRoundKind.ivfFresh);
      expect(ttcShowOhssLine(ivf, DateTime.now()), isTrue);
      final iui = TtcTreatmentCycle(
          dates: {TtcTreatmentStep.retrieval: _plus(-2)},
          kind: TtcRoundKind.iui);
      expect(ttcShowOhssLine(iui, DateTime.now()), isFalse);
      expect(kTtcOhssLine, contains('go to hospital'));
    });

    test('K4: a step dated today is still next', () {
      final r = TtcTreatmentCycle(
          dates: {TtcTreatmentStep.retrieval: _today()},
          kind: TtcRoundKind.ivfFresh);
      expect(r.next?.$1, TtcTreatmentStep.retrieval);
    });

    test('K4: an IUI with a trigger and no IUI date reaches the wait', () {
      final r = TtcTreatmentCycle(dates: {
        TtcTreatmentStep.stimStart: _plus(-12),
        TtcTreatmentStep.trigger: _plus(-4),
      }, kind: TtcRoundKind.iui);
      expect(ttcTreatmentPhase(r, DateTime.now()), TtcRoundPhase.waiting);
    });
  });

  // ===========================================================================
  group('K9: one line per visit', () {
    test('an appointment of the same type on the day wins on the Calendar',
        () {
      final store = TtcTreatmentStore.instance;
      final day = _plus(5);
      store.startRound(kind: TtcRoundKind.ivfFresh, dates: {
        TtcTreatmentStep.stimStart: _plus(-5),
        TtcTreatmentStep.retrieval: day,
      });
      expect(ttcCalendarClinicLines(day), hasLength(1));
      TtcAppointmentsStore.instance.add(
          title: 'Egg collection',
          startsLocal: DateTime(day.year, day.month, day.day, 8));
      expect(ttcCalendarClinicLines(day), isEmpty);
    });

    test('round dates show on Appointments, and the typed one wins', () {
      final store = TtcTreatmentStore.instance;
      final day = _plus(5);
      store.startRound(kind: TtcRoundKind.ivfFresh, dates: {
        TtcTreatmentStep.stimStart: _plus(-5),
        TtcTreatmentStep.retrieval: day,
        TtcTreatmentStep.transfer: _plus(10),
      });
      final round = ttcRoundApptEntries();
      expect(round.map((e) => e.roundStep),
          containsAll([TtcTreatmentStep.retrieval, TtcTreatmentStep.transfer]));
      expect(round.map((e) => e.roundStep),
          isNot(contains(TtcTreatmentStep.stimStart)),
          reason: 'a first injection is at home, not a visit');
      expect(round.every((e) => e.detail == kTtcApptFromRound), isTrue);
      TtcAppointmentsStore.instance.add(
          title: 'Egg collection',
          startsLocal: DateTime(day.year, day.month, day.day, 8));
      expect(ttcRoundApptEntries().map((e) => e.roundStep),
          isNot(contains(TtcTreatmentStep.retrieval)));
    });
  });

  // ===========================================================================
  group('W13, W14, K12: the semen report', () {
    test('W13: the volume sentence names WHO\'s 1.4 ml', () {
      final r = ttcReadSemenReport(
          const TtcSemenEntry(values: {'concentration': 20}, volumeMl: 2));
      expect(r.volumeSentence, contains('1.4 ml'));
      expect(kTtcSemenLimits, hasLength(4), reason: 'the four lines stay four');
    });

    test('W14: no "stays on your phone" on the form', () {
      final body = _src('lib/screens/ttc/ttc_semen_report_screen.dart');
      final live = body
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(live, isNot(contains('const TtcToolPrivacyLine()')));
      expect(live, contains('Kept in your records, which you both can see.'));
    });

    test('K12: keep checks for the same report first', () {
      final keep = _member(_src('lib/screens/ttc/ttc_semen_report_screen.dart'),
          'Future<void> _keep()');
      expect(keep, contains("r.testId == 'semen'"));
      expect(keep, contains('r.value == value'));
    });

    test('K12: the azoospermia line links its read', () {
      final r = ttcReadSemenReport(const TtcSemenEntry(noSpermFound: true));
      expect(r.readId, 'ttc_read_azoospermia');
    });

    test('K12: no overclaim, and morphology is "the usual range"', () {
      final r = ttcReadSemenReport(const TtcSemenEntry(values: {
        'concentration': 40,
        'total_motility': 60,
        'progressive_motility': 45,
        'morphology': 6,
      }));
      expect(r.body, contains('less likely'));
      expect(r.body, isNot(contains('rules out')));
      expect(ttcSemenLimit('morphology')!.note, contains('usual range'));
      expect(ttcSemenLimit('morphology')!.note, isNot(contains('is normal')));
    });

    test('K12: the abstinence note changes the headline', () {
      final r = ttcReadSemenReport(const TtcSemenEntry(values: {
        'concentration': 40,
        'total_motility': 60,
        'progressive_motility': 45,
        'morphology': 6,
      }, abstinenceDays: 12));
      expect(r.headline, 'These look in the usual range, but read the note first.');
    });
  });

  // ===========================================================================
  group('the wiring gate', () {
    test('every new reader has a caller', () {
      final checks = <String, String>{
        'lib/screens/ttc/ttc_treatment_screen.dart': 'ttcTreatmentTitle(',
        'lib/screens/ttc/ttc_records_v2.dart': 'TtcRecordReadOnlyNote()',
        'lib/screens/ttc/ttc_record_edit_screen.dart': 'ttcMineFlag()',
        'lib/screens/ttc/ttc_appointments_screen.dart':
            'ttcApptEntries(withRound: true)',
        'lib/screens/ttc/ttc_calendar_screen.dart': 'dedupe: true',
        'lib/screens/ttc/ttc_medication_screen.dart':
            'const TtcMedAfterLossCard()',
        'lib/services/ttc_surfaces.dart': "TtcSurface('ttc_semen_report'",
      };
      checks.forEach((file, call) {
        expect(_src(file), contains(call), reason: '$file calls $call');
      });
      expect(
          _member(_src('lib/services/notification_service.dart'),
              'Future<void> scheduleMedicationAlarms(Medication m)'),
          contains('medicationOccurrences('));
    });
  });
}
