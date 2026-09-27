// =============================================================================
//  The app speaks first: the five messages
// -----------------------------------------------------------------------------
//  What this file holds, in order of how much it would hurt to lose:
//
//    1. A clinic-owned cycle is never told a fertile window or a late period,
//       through the rules AND through the live stores. The window message is
//       the first ovulation notification the app has ever sent, and
//       `TtcPathwayBehaviour.sendsOvulationReminders` was written before it
//       existed so that it could not ship without meeting this rule.
//    2. Each message is sent once. A delivered message is frozen; a pending one
//       is rebuilt, so correcting a date corrects the message.
//    3. Every message opens something real (the wiring gate).
//    4. No message states a chance.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/chats/ttc_chat.dart';
import 'package:parentveda/screens/ttc/ttc_content_prefs_sheet.dart'
    show TtcSwitchRow;
import 'package:parentveda/screens/ttc/ttc_messages_screen.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/ttc_surfaces.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_fertility_help_rules.dart';
import 'package:parentveda/ttc/ttc_fertility_help_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

/// Records what would have gone to the phone.
class _FakePhone implements TtcMessagePhone {
  final Map<int, DateTime> scheduled = {};
  final Map<int, String> titles = {};

  @override
  Future<void> schedule(
      {required int id,
      required String title,
      required String body,
      required DateTime when}) async {
    scheduled[id] = when;
    titles[id] = title;
  }

  @override
  Future<void> cancel(int id) async {
    scheduled.remove(id);
    titles.remove(id);
  }
}

DateTime _d(int y, int m, int d, [int h = 0]) => DateTime(y, m, d, h);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late _FakePhone phone;

  setUpAll(() async {
    // Touch every singleton and let its constructor's async load finish, so a
    // late load cannot wipe what a test logs after `resetForTest`.
    CycleStore.instance;
    TtcStore.instance;
    LifeStageStore.instance;
    TtcLogStore.instance;
    TtcTreatmentStore.instance;
    await TtcFertilityHelpStore.instance.load();
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  });

  setUp(() async {
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    LifeStageStore.instance
      ..resetForTest()
      ..setStage(LifeStage.tryingToConceive);
    await TtcFertilityHelpStore.instance.reset();
    TtcMessagesStore.instance.resetForTest();
    phone = _FakePhone();
    TtcMessagesStore.instance.phone = phone;
  });

  // ===========================================================================
  group('the rules, on plain facts', () {
    final now = _d(2026, 9, 10, 7); // 7am
    TtcMessage? find(List<TtcMessage> list, TtcMessageKind k) =>
        list.where((m) => m.kind == k).firstOrNull;

    test('natural cycle: the window message lands at 8am on the day it opens',
        () {
      final list = ttcMessageCandidates(
        TtcMessageFacts(
          periodStarts: [_d(2026, 9, 1)],
          windowOpens: _d(2026, 9, 10),
          windowCloses: _d(2026, 9, 16),
        ),
        now,
      );
      final w = find(list, TtcMessageKind.windowOpens);
      expect(w, isNotNull);
      expect(w!.at, _d(2026, 9, 10, 8));
      expect(w.body, contains('Wed 16 Sep'));
    });

    test('a window that opened on an earlier day is not announced late', () {
      final list = ttcMessageCandidates(
        TtcMessageFacts(
          windowOpens: _d(2026, 9, 8),
          windowCloses: _d(2026, 9, 14),
        ),
        now,
      );
      expect(find(list, TtcMessageKind.windowOpens), isNull);
    });

    for (final owner in [
      TimingOwnership.clinicGuided,
      TimingOwnership.clinicControlled,
    ]) {
      test('${owner.name}: no window and no late message, even if a date '
          'leaks into the facts', () {
        final list = ttcMessageCandidates(
          TtcMessageFacts(
            ownership: owner,
            sendsOvulationReminders:
                TtcPathwayBehaviour(owner).sendsOvulationReminders,
            // Deliberately wrong inputs: the rules must refuse on ownership,
            // not rely on the caller having nulled the window.
            windowOpens: _d(2026, 9, 12),
            windowCloses: _d(2026, 9, 18),
            periodStarts: [
              _d(2026, 7, 7),
              _d(2026, 8, 4),
              _d(2026, 9, 1),
            ].map((d) => d.subtract(const Duration(days: 20))).toList(),
            cycleLengths: const [28, 28],
            usualLength: 28,
            journeyStart: _d(2024, 1, 1),
          ),
          now,
        );
        expect(find(list, TtcMessageKind.windowOpens), isNull);
        expect(find(list, TtcMessageKind.lateByOne), isNull);
        // On a clinic path she is already in care: no "first check" either.
        expect(find(list, TtcMessageKind.tryingLong), isNull);
      });
    }

    test('late by a day: the morning after it was due, natural and regular',
        () {
      // Last start 12 Aug, usual 28, so due 9 Sep and a day past it on the 10th.
      final list = ttcMessageCandidates(
        TtcMessageFacts(
          periodStarts: [_d(2026, 6, 17), _d(2026, 7, 15), _d(2026, 8, 12)],
          cycleLengths: const [28, 28],
          usualLength: 28,
        ),
        now,
      );
      final late = find(list, TtcMessageKind.lateByOne);
      expect(late, isNotNull);
      expect(late!.at, _d(2026, 9, 10, 9));
      expect(late.body, contains('Wed 9 Sep'));
    });

    test('no late message without two agreeing cycles', () {
      TtcMessageFacts facts({List<int> lengths = const [28], bool irr = false}) =>
          TtcMessageFacts(
            periodStarts: [_d(2026, 7, 15), _d(2026, 8, 12)],
            cycleLengths: lengths,
            usualLength: 28,
            irregular: irr,
          );
      expect(
          find(ttcMessageCandidates(facts(), now), TtcMessageKind.lateByOne),
          isNull);
      expect(
          find(ttcMessageCandidates(facts(lengths: const [24, 34], irr: true),
              now), TtcMessageKind.lateByOne),
          isNull);
    });

    test('period came: only a new cycle, in the evening', () {
      final one = ttcMessageCandidates(
          TtcMessageFacts(periodStarts: [_d(2026, 9, 10)]), now);
      expect(find(one, TtcMessageKind.periodCame), isNull,
          reason: 'the first period ever logged is usually onboarding');

      final two = ttcMessageCandidates(
          TtcMessageFacts(periodStarts: [_d(2026, 8, 13), _d(2026, 9, 10)]),
          now);
      final m = find(two, TtcMessageKind.periodCame);
      expect(m, isNotNull);
      expect(m!.at, _d(2026, 9, 10, 19));
    });

    test('cycle report: the morning after a new cycle starts', () {
      final list = ttcMessageCandidates(
          TtcMessageFacts(periodStarts: [_d(2026, 8, 13), _d(2026, 9, 9)]),
          now);
      final r = find(list, TtcMessageKind.cycleReport);
      expect(r, isNotNull);
      expect(r!.at, _d(2026, 9, 10, 9));
      expect(r.body, contains('27 days'));
    });

    test('trying: twelve months by default, six from 35 or irregular', () {
      final base = TtcMessageFacts(journeyStart: _d(2025, 1, 5));
      expect(base.monthsBeforeCheck, 12);
      final t12 = find(
          ttcMessageCandidates(base, now), TtcMessageKind.tryingLong);
      expect(t12!.id, 'trying:12');
      expect(t12.at, _d(2026, 1, 5, 10));

      final older = TtcMessageFacts(
          journeyStart: _d(2026, 3, 1),
          ageBand: FertilityAgeBand.thirtyFiveTo37);
      expect(older.monthsBeforeCheck, 6);
      expect(
          find(ttcMessageCandidates(older, now), TtcMessageKind.tryingLong)!.at,
          _d(2026, 9, 1, 10));

      const irregular = TtcMessageFacts(cyclesVaryOrPcos: true);
      expect(irregular.monthsBeforeCheck, 6);

      final inCare =
          TtcMessageFacts(journeyStart: _d(2024, 1, 1), alreadyInCare: true);
      expect(find(ttcMessageCandidates(inCare, now), TtcMessageKind.tryingLong),
          isNull);
    });

    test('nothing at all after a positive test, or outside the stage', () {
      final full = TtcMessageFacts(
        periodStarts: [_d(2026, 8, 13), _d(2026, 9, 10)],
        windowOpens: _d(2026, 9, 20),
        windowCloses: _d(2026, 9, 26),
        journeyStart: _d(2024, 1, 1),
      );
      expect(ttcMessageCandidates(full, now), isNotEmpty);
      expect(
          ttcMessageCandidates(
              TtcMessageFacts(
                pregnancyConfirmed: true,
                periodStarts: full.periodStarts,
                windowOpens: full.windowOpens,
                windowCloses: full.windowCloses,
                journeyStart: full.journeyStart,
              ),
              now),
          isEmpty);
      expect(
          ttcMessageCandidates(
              TtcMessageFacts(
                inTtcStage: false,
                periodStarts: full.periodStarts,
                journeyStart: full.journeyStart,
              ),
              now),
          isEmpty);
    });
  });

  // ===========================================================================
  group('sent once', () {
    final store = TtcMessagesStore.instance;
    TtcMessage msg(String id, DateTime at,
            {TtcMessageKind kind = TtcMessageKind.windowOpens}) =>
        TtcMessage(id: id, kind: kind, at: at, title: 't', body: 'b');

    test('a moment already passed is delivered now, once', () {
      final now = _d(2026, 9, 10, 12);
      store.apply([msg('window:2026-09-10', _d(2026, 9, 10, 8))], now);
      expect(store.delivered(now: now), hasLength(1));
      expect(store.delivered(now: now).single.at, now);
      // Same candidate again: nothing new.
      expect(store.apply([msg('window:2026-09-10', _d(2026, 9, 10, 8))], now),
          isFalse);
      expect(store.delivered(now: now), hasLength(1));
    });

    test('a pending message is rebuilt when the date moves', () {
      final now = _d(2026, 9, 1, 12);
      store.apply([msg('window:2026-09-10', _d(2026, 9, 10, 8))], now);
      expect(store.pending(now: now).single.id, 'window:2026-09-10');
      store.apply([msg('window:2026-09-11', _d(2026, 9, 11, 8))], now);
      expect(store.pending(now: now).map((m) => m.id), ['window:2026-09-11']);
      expect(store.delivered(now: now), isEmpty);
    });

    test('a pending message keeps the moment it was first given', () {
      final day1 = _d(2026, 9, 10, 10);
      store.apply([
        msg('period:2026-09-10', _d(2026, 9, 10, 19),
            kind: TtcMessageKind.periodCame)
      ], day1);
      // Recomputed later with a new evening: the first moment stands.
      store.apply([
        msg('period:2026-09-10', _d(2026, 9, 11, 19),
            kind: TtcMessageKind.periodCame)
      ], _d(2026, 9, 10, 11));
      expect(store.pending(now: day1).single.at, _d(2026, 9, 10, 19));
    });

    test('the first-check message is once in a lifetime', () {
      final now = _d(2026, 9, 10, 12);
      store.apply([
        msg('trying:6', _d(2026, 9, 1, 10), kind: TtcMessageKind.tryingLong)
      ], now);
      store.apply([
        msg('trying:12', _d(2026, 9, 2, 10), kind: TtcMessageKind.tryingLong)
      ], now);
      expect(
          store
              .delivered(now: now)
              .where((m) => m.kind == TtcMessageKind.tryingLong),
          hasLength(1));
    });

    test('a switched-off kind is not added', () async {
      await store.setOn(TtcMessageKind.windowOpens, false);
      final now = _d(2026, 9, 10, 12);
      store.apply([msg('window:2026-09-10', _d(2026, 9, 10, 8))], now);
      expect(store.delivered(now: now), isEmpty);
      await store.setOn(TtcMessageKind.windowOpens, true);
    });
  });

  // ===========================================================================
  group('through the live stores', () {
    /// Two clean 28-day cycles and today on day 4, so the window opens in
    /// five days' time.
    void natural() {
      final now = DateTime.now();
      CycleStore.instance
        ..logPeriodStart(now.subtract(const Duration(days: 59)))
        ..logPeriodStart(now.subtract(const Duration(days: 31)))
        ..logPeriodStart(now.subtract(const Duration(days: 3)));
    }

    test('natural: the window is scheduled on the phone', () async {
      natural();
      await TtcMessagesStore.instance.refresh();
      final id = TtcMessageKind.windowOpens.notificationId;
      expect(phone.scheduled.containsKey(id), isTrue);
      expect(phone.scheduled[id]!.hour, 8);
    });

    test('IVF: nothing about a window, on the phone or in the list', () async {
      natural();
      TtcStore.instance.setPath(TtcPath.ivf);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      await TtcMessagesStore.instance.refresh();
      expect(
          phone.scheduled
              .containsKey(TtcMessageKind.windowOpens.notificationId),
          isFalse);
      final all = [
        ...TtcMessagesStore.instance.pending(),
        ...TtcMessagesStore.instance.delivered(),
      ];
      expect(all.where((m) => m.kind == TtcMessageKind.windowOpens), isEmpty);
      expect(all.where((m) => m.kind == TtcMessageKind.lateByOne), isEmpty);
    });

    test('monitored IUI (clinic-guided): no window either', () async {
      natural();
      TtcStore.instance
        ..setPath(TtcPath.iui)
        ..setClinicMonitors(true)
        ..setMedicationControlsOvulation(false);
      // 2026-09-26: a clinic owns the timing only with a real date from
      // her clinic for this cycle in the treatment tracker, never on the
      // pathway label alone. Kept for revert: the label alone did it.
      TtcTreatmentStore.instance.setDate(TtcTreatmentStep.betaTest,
          DateTime.now().add(const Duration(days: 20)));
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      expect(TtcStore.instance.ownership, TimingOwnership.clinicGuided);
      await TtcMessagesStore.instance.refresh();
      expect(
          phone.scheduled
              .containsKey(TtcMessageKind.windowOpens.notificationId),
          isFalse);
    });

    test('phone off: the list still fills, the phone gets nothing', () async {
      natural();
      await TtcMessagesStore.instance.setPhoneOn(false);
      await TtcMessagesStore.instance.refresh();
      expect(phone.scheduled, isEmpty);
      expect(TtcMessagesStore.instance.pending(), isNotEmpty);
    });

    test('a message survives a round trip through storage', () async {
      final now = DateTime.now();
      TtcMessagesStore.instance.apply([
        TtcMessage(
            id: 'report:x',
            kind: TtcMessageKind.cycleReport,
            at: now.subtract(const Duration(hours: 1)),
            title: 'Your cycle report is ready',
            body: 'b'),
      ], now);
      expect(TtcMessagesStore.instance.unreadCount, 1);
      TtcMessagesStore.instance.markRead('report:x');
      expect(TtcMessagesStore.instance.unreadCount, 0);
      final json = TtcMessagesStore.instance.delivered().single.toJson();
      final back = TtcMessage.fromJson(json)!;
      expect(back.kind, TtcMessageKind.cycleReport);
      expect(back.read, isTrue);
    });
  });

  // ===========================================================================
  group('the wiring gate', () {
    test('every message opens something real', () {
      for (final k in TtcMessageKind.values) {
        expect(ttcFirstOpenable(k.destinations), isNotNull,
            reason: '${k.name} opens nothing');
      }
    });

    test('the new surfaces resolve and carry labels', () {
      for (final id in const [
        'ttc_messages',
        'ttc_chat/should_test',
        'ttc_chat/period_came',
        'ttc_chat/cycle_report',
        'ttc_cycle_report',
        'ttc_door/ttc_mind_body',
      ]) {
        expect(ttcScreenForSurface(id), isNotNull, reason: id);
      }
      for (final id in const [
        'ttc_messages',
        'ttc_chat/should_test',
        'ttc_chat/period_came',
        'ttc_chat/cycle_report',
        'ttc_cycle_report',
      ]) {
        expect(ttcSurfaceLabel(id, hinglish: false), isNotNull, reason: id);
      }
      expect(ttcScreenForSurface('ttc_door/not_a_door'), isNull);
    });

    test('the notification ids stay clear of the trigger reminders', () {
      final ids = TtcMessageKind.values.map((k) => k.notificationId).toSet();
      expect(ids, hasLength(TtcMessageKind.values.length));
      // The treatment block, 918201 upwards, overlaps nothing.
      final all = [for (final k in TtcMessageKind.values) ...k.phoneIds];
      expect(all.toSet(), hasLength(all.length));
      expect(TtcMessageKind.treatment.phoneIds.first, 918201);
      expect(ids.contains(TtcTreatmentStore.triggerNotificationId), isFalse);
      expect(ids.contains(TtcTreatmentStore.triggerPrepNotificationId), isFalse);
    });
  });

  // ===========================================================================
  group('the words', () {
    test('no message states a chance, and none uses a dash or a shout', () {
      final now = _d(2026, 9, 10, 7);
      final texts = <String>[
        for (final f in [
          TtcMessageFacts(
            periodStarts: [_d(2026, 6, 17), _d(2026, 7, 15), _d(2026, 8, 12)],
            cycleLengths: const [28, 28],
            usualLength: 28,
            windowOpens: _d(2026, 9, 10),
            windowCloses: _d(2026, 9, 16),
            journeyStart: _d(2025, 1, 1),
          ),
          TtcMessageFacts(
            periodStarts: [_d(2026, 8, 13), _d(2026, 9, 10)],
            journeyStart: _d(2026, 3, 1),
            ageBand: FertilityAgeBand.over40,
          ),
          TtcMessageFacts(
              journeyStart: _d(2026, 3, 1), cyclesVaryOrPcos: true),
        ])
          for (final m in ttcMessageCandidates(f, now)) ...[m.title, m.body],
        for (final k in TtcMessageKind.values) ...[k.label, k.when],
      ];
      expect(texts, isNotEmpty);
      final banned = RegExp(
          r'chance|probabil|odds|%|per cent|success rate|—|–| - |!',
          caseSensitive: false);
      for (final t in texts) {
        expect(banned.hasMatch(t), isFalse, reason: t);
      }
    });
  });

  // ===========================================================================
  group('the Messages screen', () {
    testWidgets('empty: says what will arrive, with a switch for each',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TtcMessagesScreen()));
      await tester.pumpAndSettle();
      // 2026-09-26 (review M1): a value statement, not an absence, and one
      // pill to the switches. Kept for revert: 'Nothing here yet'.
      expect(find.text(kTtcMessagesEmptyTitle), findsOneWidget);
      expect(find.text('Nothing here yet'), findsNothing);
      expect(find.byKey(const ValueKey('ttc-messages-choose')), findsOneWidget);
      // M3: one switch style, shared with the content-prefs sheet.
      expect(find.byType(TtcSwitchRow),
          findsNWidgets(TtcMessageKind.values.length + 1));
      for (final k in TtcMessageKind.values) {
        expect(find.text(k.label), findsOneWidget);
      }
      expect(find.byType(Switch), findsNWidgets(TtcMessageKind.values.length + 1));
    });

    testWidgets('a delivered message shows, unread, newest first',
        (tester) async {
      // Two refreshes at two moments. A message whose moment has passed is
      // stamped with the refresh that delivered it, so one refresh would give
      // both the same time and no order to test.
      final now = DateTime.now();
      final then = now.subtract(const Duration(days: 3));
      final olderMsg = TtcMessage(
          id: 'report:a',
          kind: TtcMessageKind.cycleReport,
          at: then,
          title: 'Older one',
          body: 'b');
      TtcMessagesStore.instance.apply([olderMsg], then);
      TtcMessagesStore.instance.apply([
        olderMsg,
        TtcMessage(
            id: 'period:b',
            kind: TtcMessageKind.periodCame,
            at: now.subtract(const Duration(hours: 2)),
            title: 'Newer one',
            body: 'b'),
      ], now);
      await tester.pumpWidget(const MaterialApp(home: TtcMessagesScreen()));
      await tester.pumpAndSettle();
      expect(find.text(kTtcMessagesEmptyTitle), findsNothing);
      expect(find.byKey(const ValueKey('ttc-message-unread')), findsNWidgets(2));
      final newer = tester.getTopLeft(find.text('Newer one')).dy;
      final older = tester.getTopLeft(find.text('Older one')).dy;
      expect(newer, lessThan(older));
    });
  });

  // ===========================================================================
  //  Treatment messages (2026-09-26, docs/TTC-TREATMENT-FLOW.md §3d, B6):
  //  computed from her round's dates, never queued, so moving a date moves
  //  the message; nothing natural fires while a clinic owns the cycle.
  // ===========================================================================
  group('treatment messages', () {
    // Her clinic's IVF dates, with today the 1st of October.
    final now = _d(2026, 10, 1, 8);
    TtcTreatmentCycle round({DateTime? collection, TtcRoundKind kind = TtcRoundKind.ivfFresh}) =>
        TtcTreatmentCycle(
          dates: {
            TtcTreatmentStep.baselineScan: _d(2026, 10, 2),
            TtcTreatmentStep.stimStart: _d(2026, 10, 3),
            TtcTreatmentStep.trigger: DateTime(2026, 10, 13, 22, 15),
            TtcTreatmentStep.retrieval: collection ?? _d(2026, 10, 15),
            TtcTreatmentStep.transfer: _d(2026, 10, 20),
            TtcTreatmentStep.betaTest: _d(2026, 10, 31),
          },
          scans: [_d(2026, 10, 8), _d(2026, 10, 10)],
          kind: kind,
          id: 'r1',
        );
    TtcMessage? byId(List<TtcMessage> l, String id) =>
        l.where((m) => m.id == id).firstOrNull;

    test('each clinic date gives its message, at its moment', () {
      final l = ttcTreatmentMessages(round(), null, now);
      expect(l.every((m) => m.kind == TtcMessageKind.treatment), isTrue);
      final base = byId(l, 'treat:baseline:2026-10-02')!;
      expect(base.at, _d(2026, 10, 1, 19), reason: 'the evening before');
      expect(byId(l, 'treat:stims:2026-10-03')!.destinations.first,
          'ttc_medication',
          reason: 'injection times live in the Medication schedule');
      expect(byId(l, 'treat:scan:2026-10-08')!.at, _d(2026, 10, 7, 19));
      expect(byId(l, 'treat:scan:2026-10-10'), isNotNull);
      final trig = byId(l, 'treat:trigger:2026-10-13')!;
      expect(trig.quiet, isTrue, reason: 'the phone alerts are the store\'s');
      expect(trig.title, contains('10:15pm'));
      expect(trig.body, contains('34 to 36 hours'));
      expect(byId(l, 'treat:collection:2026-10-15')!.body,
          contains('No food or drink'));
      expect(byId(l, 'treat:rest:2026-10-15')!.at, _d(2026, 10, 16, 9));
      expect(byId(l, 'treat:transfer:2026-10-20')!.at, _d(2026, 10, 19, 19));
      expect(byId(l, 'treat:middle:2026-10-20')!.at, _d(2026, 10, 25, 10));
      final beta = byId(l, 'treat:beta:2026-10-31')!;
      expect(beta.at, _d(2026, 10, 30, 19));
      expect(beta.title, 'Your blood test is tomorrow');
      final ask = byId(l, 'treat:ask_result:2026-10-31')!;
      expect(ask.quiet, isTrue);
      expect(ask.at, _d(2026, 11, 2, 9));
      expect(ask.destinations.first, 'ttc_treatment/result');
    });

    test('move a date and the message moves with it', () {
      final before = ttcTreatmentMessages(round(), null, now);
      final after = ttcTreatmentMessages(
          round(collection: _d(2026, 10, 16)), null, now);
      expect(byId(before, 'treat:collection:2026-10-15'), isNotNull);
      expect(byId(after, 'treat:collection:2026-10-15'), isNull);
      expect(byId(after, 'treat:collection:2026-10-16')!.at,
          _d(2026, 10, 15, 19));
      expect(byId(after, 'treat:rest:2026-10-16')!.at, _d(2026, 10, 17, 9));
      // Through the store: the pending message is rebuilt, never stacked.
      final store = TtcMessagesStore.instance;
      store.apply(before, now);
      store.apply(after, now);
      final ids = store.pending(now: now).map((m) => m.id).toList();
      expect(ids, contains('treat:collection:2026-10-16'));
      expect(ids, isNot(contains('treat:collection:2026-10-15')));
    });

    test('ids are stable: the same dates give the same ids', () {
      final a = ttcTreatmentMessages(round(), null, now).map((m) => m.id);
      final b = ttcTreatmentMessages(round(), null, now).map((m) => m.id);
      expect(a.toList(), b.toList());
      expect(a.toSet(), hasLength(a.length), reason: 'no two share an id');
      for (final id in a) {
        expect(id, matches(RegExp(r'^treat:[a-z_]+:\d{4}-\d{2}-\d{2}$')));
      }
    });

    test('an evening-before message is not sent on the day itself', () {
      final l = ttcTreatmentMessages(round(), null, _d(2026, 10, 2, 7));
      expect(byId(l, 'treat:baseline:2026-10-02'), isNull);
      expect(byId(l, 'treat:stims:2026-10-03'), isNotNull);
    });

    test('an IUI round: its own words, no egg collection', () {
      final iui = TtcTreatmentCycle(dates: {
        TtcTreatmentStep.stimStart: _d(2026, 10, 3),
        TtcTreatmentStep.trigger: DateTime(2026, 10, 12, 21),
        TtcTreatmentStep.iui: _d(2026, 10, 14),
        TtcTreatmentStep.betaTest: _d(2026, 10, 28),
      }, kind: TtcRoundKind.iui);
      final l = ttcTreatmentMessages(iui, null, now);
      expect(l.where((m) => m.id.startsWith('treat:collection')), isEmpty);
      expect(byId(l, 'treat:iui:2026-10-14')!.body, contains('sample'));
      expect(byId(l, 'treat:middle:2026-10-14'), isNotNull);
      expect(byId(l, 'treat:beta:2026-10-28')!.title,
          'Your pregnancy test is tomorrow');
      expect(byId(l, 'treat:trigger:2026-10-12')!.body,
          isNot(contains('34 to 36')));
    });

    test('"Not this time": a follow-up two days later, in the app only', () {
      final closed = round().closed(TtcRoundOutcome.negative, _d(2026, 11, 1));
      final l = ttcTreatmentMessages(null, closed, _d(2026, 11, 1, 12));
      final m = byId(l, 'treat:after_negative:2026-11-01')!;
      expect(m.at, _d(2026, 11, 3, 10));
      expect(m.quiet, isTrue);
      expect(m.destinations.first,
          'ttc_read/ttc_read_tx_negative_after_treatment');
      expect(ttcFirstOpenable(m.destinations), isNotNull);
      // A positive or a pause gets no such message.
      for (final o in [TtcRoundOutcome.positive, TtcRoundOutcome.paused]) {
        expect(
            ttcTreatmentMessages(
                null, round().closed(o, _d(2026, 11, 1)), _d(2026, 11, 1, 12)),
            isEmpty,
            reason: o.name);
      }
    });

    test('nothing natural fires while a clinic owns the cycle', () {
      final list = ttcMessageCandidates(
        TtcMessageFacts(
          ownership: TimingOwnership.clinicControlled,
          sendsOvulationReminders: false,
          // Deliberately leaky facts: every natural rule would fire on these.
          periodStarts: [_d(2026, 8, 3), _d(2026, 8, 31), _d(2026, 9, 30)],
          cycleLengths: const [28, 28],
          usualLength: 28,
          windowOpens: _d(2026, 10, 10),
          windowCloses: _d(2026, 10, 16),
          journeyStart: _d(2024, 1, 1),
          round: round(),
        ),
        now,
      );
      expect(list, isNotEmpty);
      expect(list.map((m) => m.kind).toSet(), {TtcMessageKind.treatment},
          reason: 'no window, period came, late, cycle report or first check');
    });

    test('the first period after a round: its own words, no cycle report', () {
      final list = ttcMessageCandidates(
        TtcMessageFacts(
          periodStarts: [_d(2026, 9, 2), _d(2026, 10, 1)],
          lastCycleWasRound: true,
        ),
        now,
      );
      final p = list.where((m) => m.kind == TtcMessageKind.periodCame).single;
      expect(p.body, isNot(contains('hoping this month')));
      expect(p.destinations.first, 'ttc_door/ttc_infertility');
      expect(list.where((m) => m.kind == TtcMessageKind.cycleReport), isEmpty);
    });

    test('every treatment message opens something real', () {
      final all = [
        ...ttcTreatmentMessages(round(), null, now),
        ...ttcTreatmentMessages(
            null,
            round().closed(TtcRoundOutcome.negative, _d(2026, 11, 1)),
            _d(2026, 11, 1, 12)),
      ];
      for (final m in all) {
        expect(ttcFirstOpenable(m.destinations), isNotNull, reason: m.id);
      }
    });

    test('the words: no chance, no dash, no shout', () {
      final banned = RegExp(
          r'chance|probabil|odds|%|per cent|success rate|—|–| - |!',
          caseSensitive: false);
      for (final m in [
        ...ttcTreatmentMessages(round(), null, now),
        ...ttcTreatmentMessages(
            null,
            round().closed(TtcRoundOutcome.negative, _d(2026, 11, 1)),
            _d(2026, 11, 1, 12)),
      ]) {
        expect(banned.hasMatch('${m.title} ${m.body}'), isFalse, reason: m.id);
      }
    });

    test('a quiet message survives storage and never reaches the phone',
        () async {
      final back = TtcMessage.fromJson(
          ttcTreatmentMessages(round(), null, now)
              .firstWhere((m) => m.quiet)
              .toJson())!;
      expect(back.quiet, isTrue);
      expect(back.to, isNotNull);

      // Through the live stores: a round two days out.
      final today = DateTime.now();
      DateTime at(int n) => DateTime(today.year, today.month, today.day + n);
      TtcStore.instance.setPath(TtcPath.ivf);
      TtcTreatmentStore.instance.startRound(
        kind: TtcRoundKind.ivfFresh,
        dates: {
          TtcTreatmentStep.baselineScan: at(2),
          TtcTreatmentStep.stimStart: at(3),
          TtcTreatmentStep.retrieval: at(15),
          TtcTreatmentStep.betaTest: at(30),
        },
        scans: [at(8)],
      );
      addTearDown(TtcTreatmentStore.instance.resetForTest);
      // Let any refresh the store changes queued finish first: a refresh
      // called while one runs returns that run and reruns after it.
      for (var i = 0; i < 5; i++) {
        await TtcMessagesStore.instance.refresh();
        await Future<void>.delayed(Duration.zero);
      }
      final ids = phone.scheduled.keys
          .where((id) => TtcMessageKind.treatment.phoneIds.contains(id))
          .toList();
      expect(ids, isNotEmpty, reason: 'the evening-before messages ring');
      final pending = TtcMessagesStore.instance
          .pending()
          .where((m) => m.kind == TtcMessageKind.treatment && !m.quiet)
          .length;
      expect(ids.length, pending);
      // Switched off: nothing pending, nothing on the phone.
      await TtcMessagesStore.instance.setOn(TtcMessageKind.treatment, false);
      for (var i = 0; i < 5; i++) {
        await TtcMessagesStore.instance.refresh();
        await Future<void>.delayed(Duration.zero);
      }
      expect(
          phone.scheduled.keys
              .where((id) => TtcMessageKind.treatment.phoneIds.contains(id)),
          isEmpty);
      await TtcMessagesStore.instance.setOn(TtcMessageKind.treatment, true);
    });
  });
}
