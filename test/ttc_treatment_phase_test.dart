// =============================================================================
//  A treatment round, day by day (docs/TTC-TREATMENT-FLOW.md B1 and B2)
// -----------------------------------------------------------------------------
//  Holds the round model and its pure rules:
//    * every kind of round walked day by day through `ttcTreatmentPhase`;
//    * partial dates (she starts tracking mid-round), a rescheduled trigger;
//    * an old five-step blob loads unchanged, and round-trips;
//    * the switch: active from the first treatment date until closed, the
//      tier from the kind and the trigger;
//    * the check-in rules (7 quiet days, 30 days away), and that nothing ever
//      closes on its own;
//    * closing keeps the round in history, undo restores it exactly for 7
//      days, and everything survives a restart;
//    * each announcement is due exactly once;
//    * a date out of order, or far away, is flagged for her to check.
// =============================================================================

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_treatment_round.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

final DateTime b = DateTime(2026, 10, 1);
DateTime d(int n) => DateTime(b.year, b.month, b.day + n);

TtcTreatmentCycle round(TtcRoundKind? kind, Map<TtcTreatmentStep, DateTime> at,
        {List<DateTime> scans = const []}) =>
    TtcTreatmentCycle(dates: at, kind: kind, scans: scans, id: 'r1');

/// Walks [r] from day [from] to [to] and checks each day's phase against
/// [expect], a list of (first day, phase) runs.
void walk(TtcTreatmentCycle r, int from, int to,
    List<(int, TtcRoundPhase)> runs) {
  for (var n = from; n <= to; n++) {
    var want = TtcRoundPhase.ownCycle;
    for (final (start, p) in runs) {
      if (n >= start) want = p;
    }
    expect(ttcTreatmentPhase(r, d(n)), want,
        reason: '${r.kind?.name ?? 'legacy'}, day $n');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() => TtcTreatmentStore.instance.resetForTest());

  // ===========================================================================
  group('every kind, walked day by day', () {
    test('IVF with a fresh transfer', () {
      final r = round(TtcRoundKind.ivfFresh, {
        TtcTreatmentStep.baselineScan: d(0),
        TtcTreatmentStep.stimStart: d(1),
        TtcTreatmentStep.trigger: DateTime(2026, 10, 12, 21, 15),
        TtcTreatmentStep.retrieval: d(13),
        TtcTreatmentStep.progesteroneStart: d(13),
        TtcTreatmentStep.transfer: d(18),
        TtcTreatmentStep.betaTest: d(29),
        TtcTreatmentStep.repeatBeta: d(31),
      }, scans: [d(6), d(8)]);
      walk(r, -3, 35, [
        (-3, TtcRoundPhase.planned),
        (0, TtcRoundPhase.gettingReady),
        (1, TtcRoundPhase.stimulation),
        (11, TtcRoundPhase.trigger),
        (13, TtcRoundPhase.procedure),
        (14, TtcRoundPhase.embryoDays),
        (18, TtcRoundPhase.transfer),
        (19, TtcRoundPhase.waiting),
        (29, TtcRoundPhase.testDay),
      ]);
      expect(ttcRoundDayCount(r, TtcRoundPhase.stimulation, d(6))!.$1, 6,
          reason: 'injection day 6');
      expect(ttcRoundDayCount(r, TtcRoundPhase.embryoDays, d(16))!.$1, 3,
          reason: 'embryo day 3 (collection is day 0)');
      expect(ttcRoundDayCount(r, TtcRoundPhase.waiting, d(22))!.$1, 4,
          reason: 'day 4 after transfer');
      expect(ttcRoundNextAfter(r, d(5))!.$1, isNull, reason: 'next is a scan');
      expect(ttcRoundNextAfter(r, d(5))!.$2, d(6));
    });

    test('IVF, freezing all the embryos', () {
      final r = round(TtcRoundKind.ivfFreezeAll, {
        TtcTreatmentStep.baselineScan: d(0),
        TtcTreatmentStep.stimStart: d(1),
        TtcTreatmentStep.trigger: DateTime(2026, 10, 12, 22),
        TtcTreatmentStep.retrieval: d(13),
      });
      walk(r, -1, 20, [
        (-1, TtcRoundPhase.planned),
        (0, TtcRoundPhase.gettingReady),
        (1, TtcRoundPhase.stimulation),
        (11, TtcRoundPhase.trigger),
        (13, TtcRoundPhase.procedure),
        (14, TtcRoundPhase.embryoDays),
      ]);
    });

    test('IUI', () {
      final r = round(TtcRoundKind.iui, {
        TtcTreatmentStep.stimStart: d(2),
        TtcTreatmentStep.trigger: DateTime(2026, 10, 13, 21),
        TtcTreatmentStep.iui: d(14),
        TtcTreatmentStep.betaTest: d(28),
      }, scans: [d(9), d(11)]);
      walk(r, 0, 30, [
        (0, TtcRoundPhase.planned),
        (2, TtcRoundPhase.stimulation),
        (12, TtcRoundPhase.trigger),
        (14, TtcRoundPhase.procedure),
        (15, TtcRoundPhase.waiting),
        (28, TtcRoundPhase.testDay),
      ]);
      expect(ttcRoundDayCount(r, TtcRoundPhase.waiting, d(17))!.$2,
          TtcTreatmentStep.iui);
    });

    test('tablets with scans and a trigger', () {
      final r = round(TtcRoundKind.ovulationInduction, {
        TtcTreatmentStep.stimStart: d(2),
        TtcTreatmentStep.trigger: DateTime(2026, 10, 14, 20),
        TtcTreatmentStep.betaTest: d(29),
      }, scans: [d(10)]);
      walk(r, 0, 30, [
        (0, TtcRoundPhase.planned),
        (2, TtcRoundPhase.stimulation),
        (13, TtcRoundPhase.trigger),
        (15, TtcRoundPhase.waiting),
        (29, TtcRoundPhase.testDay),
      ]);
    });

    test('tablets with scans, her own surge (no trigger)', () {
      final r = round(TtcRoundKind.ovulationInduction, {
        TtcTreatmentStep.stimStart: d(2),
        TtcTreatmentStep.betaTest: d(30),
      }, scans: [d(10)]);
      walk(r, 0, 31, [
        (0, TtcRoundPhase.planned),
        (2, TtcRoundPhase.stimulation),
        (30, TtcRoundPhase.testDay),
      ]);
    });

    test('frozen transfer with medicines', () {
      final r = round(TtcRoundKind.fetMedicated, {
        TtcTreatmentStep.estrogenStart: d(2),
        TtcTreatmentStep.progesteroneStart: d(14),
        TtcTreatmentStep.transfer: d(19),
        TtcTreatmentStep.betaTest: d(29),
      }, scans: [d(12)]);
      walk(r, 0, 30, [
        (0, TtcRoundPhase.planned),
        (2, TtcRoundPhase.gettingReady),
        (19, TtcRoundPhase.transfer),
        (20, TtcRoundPhase.waiting),
        (29, TtcRoundPhase.testDay),
      ]);
      expect(ttcRoundDayCount(r, TtcRoundPhase.gettingReady, d(7))!,
          (6, TtcTreatmentStep.estrogenStart),
          reason: 'estrogen day 6');
    });

    test('frozen transfer in her natural cycle', () {
      final r = round(TtcRoundKind.fetNatural, {
        TtcTreatmentStep.trigger: DateTime(2026, 10, 13, 21),
        TtcTreatmentStep.transfer: d(19),
        TtcTreatmentStep.betaTest: d(28),
      }, scans: [d(9), d(11)]);
      walk(r, 7, 30, [
        (7, TtcRoundPhase.planned),
        (9, TtcRoundPhase.stimulation),
        (12, TtcRoundPhase.trigger),
        (13, TtcRoundPhase.gettingReady),
        (19, TtcRoundPhase.transfer),
        (20, TtcRoundPhase.waiting),
        (28, TtcRoundPhase.testDay),
      ]);
    });

    test('not sure yet takes the IVF shape, all steps optional', () {
      expect(ttcRoundRows(TtcRoundKind.notSure).length,
          ttcRoundRows(TtcRoundKind.ivfFresh).length);
      final r = round(TtcRoundKind.notSure, {
        TtcTreatmentStep.stimStart: d(1),
        TtcTreatmentStep.retrieval: d(13),
      });
      walk(r, 0, 16, [
        (0, TtcRoundPhase.planned),
        (1, TtcRoundPhase.stimulation),
        (13, TtcRoundPhase.procedure),
        (14, TtcRoundPhase.embryoDays),
      ]);
    });

    test('a closed round: result for a positive, between rounds otherwise', () {
      final r = round(TtcRoundKind.ivfFresh, {
        TtcTreatmentStep.stimStart: d(1),
        TtcTreatmentStep.betaTest: d(29),
      });
      final neg = r.closed(TtcRoundOutcome.negative, d(30));
      expect(ttcTreatmentPhase(neg, d(29)), TtcRoundPhase.testDay);
      expect(ttcTreatmentPhase(neg, d(30)), TtcRoundPhase.betweenRounds);
      final pos = r.closed(TtcRoundOutcome.positive, d(30));
      expect(ttcTreatmentPhase(pos, d(31)), TtcRoundPhase.result);
    });
  });

  // ===========================================================================
  group('partial dates and a rescheduled trigger', () {
    test('only the dates she knows: first treatment date is the earliest', () {
      final r = round(TtcRoundKind.ivfFresh, {
        TtcTreatmentStep.trigger: DateTime(2026, 10, 12, 21),
        TtcTreatmentStep.retrieval: d(13),
      });
      expect(ttcFirstTreatmentDate(r), d(11));
      walk(r, 9, 15, [
        (9, TtcRoundPhase.planned),
        (11, TtcRoundPhase.trigger),
        (13, TtcRoundPhase.procedure),
        (14, TtcRoundPhase.embryoDays),
      ]);
    });

    test('a review appointment alone is not treatment', () {
      final r = round(TtcRoundKind.ivfFresh,
          {TtcTreatmentStep.reviewAppointment: d(3)});
      expect(ttcFirstTreatmentDate(r), isNull);
      expect(ttcTreatmentActive(r, d(5)), isFalse);
    });

    test('no dates at all is her own cycle', () {
      const r = TtcTreatmentCycle(dates: {}, kind: TtcRoundKind.ivfFresh);
      expect(ttcTreatmentPhase(r, d(0)), TtcRoundPhase.ownCycle);
      expect(ttcTreatmentActive(r, d(0)), isFalse);
    });

    test('moving the trigger moves the step and un-ticks it', () {
      final store = TtcTreatmentStore.instance;
      store.startRound(kind: TtcRoundKind.ivfFresh, dates: {
        TtcTreatmentStep.stimStart: d(1),
        TtcTreatmentStep.trigger: DateTime(2026, 10, 12, 21),
        TtcTreatmentStep.retrieval: d(13),
      });
      store.setTriggerTaken(true);
      expect(ttcTreatmentPhase(store.cycle, d(11)), TtcRoundPhase.trigger);
      store.setDate(TtcTreatmentStep.trigger, DateTime(2026, 10, 13, 22, 30));
      expect(store.cycle.triggerTaken, isFalse,
          reason: 'the injection she took is not the one now booked');
      expect(ttcTreatmentPhase(store.cycle, d(11)), TtcRoundPhase.stimulation);
      expect(ttcTreatmentPhase(store.cycle, d(12)), TtcRoundPhase.trigger);
      expect(store.cycle[TtcTreatmentStep.trigger]!.minute, 30);
    });
  });

  // ===========================================================================
  group('an old five-step blob', () {
    const legacy = {
      'clinic': 'Nova',
      'triggerTaken': true,
      'dates': {
        'stimStart': '2026-08-01T00:00:00.000',
        'trigger': '2026-08-10T22:15:00.000',
        'betaTest': '2026-08-26T00:00:00.000',
      },
    };

    test('decodes exactly as before, as a legacy round', () {
      final c = TtcTreatmentCycle.fromJson(legacy);
      expect(c.kind, isNull);
      expect(c.id, isEmpty);
      expect(c.clinic, 'Nova');
      expect(c.triggerTaken, isTrue);
      expect(c[TtcTreatmentStep.trigger], DateTime(2026, 8, 10, 22, 15));
      expect(c.dates.length, 3);
      expect(c.scans, isEmpty);
      expect(c.outcome, isNull);
      // And re-encodes to the same original keys, nothing new added.
      expect(c.toJson(), {
        'clinic': 'Nova',
        'triggerTaken': true,
        'dates': {
          'stimStart': '2026-08-01T00:00:00.000',
          'trigger': '2026-08-10T22:15:00.000',
          'betaTest': '2026-08-26T00:00:00.000',
        },
      });
    });

    test('loads from the device unchanged', () async {
      SharedPreferences.setMockInitialValues(
          {'ttc_treatment': jsonEncode(legacy)});
      await TtcTreatmentStore.instance.reloadForTest();
      final c = TtcTreatmentStore.instance.cycle;
      expect(c.kind, isNull);
      expect(c.dates.length, 3);
      expect(TtcTreatmentStore.instance.history, isEmpty);
      SharedPreferences.setMockInitialValues({});
    });

    test('a blob with a step name it does not know skips that step', () {
      final c = TtcTreatmentCycle.fromJson({
        'dates': {'somethingNew': '2026-08-01', 'transfer': '2026-08-05'},
      });
      expect(c.dates.keys, [TtcTreatmentStep.transfer]);
    });

    test('a round round-trips every new field', () {
      final r = TtcTreatmentCycle(
        dates: {TtcTreatmentStep.transfer: d(18)},
        id: 'ttcround_1',
        kind: TtcRoundKind.fetMedicated,
        scans: [d(3), d(5)],
        embryoDay: 5,
        lastActivity: d(2),
        changedFrom: TtcRoundKind.ivfFresh,
      ).closed(TtcRoundOutcome.paused, d(20));
      final back = TtcTreatmentCycle.fromJson(jsonDecode(jsonEncode(r.toJson())));
      expect(back.toJson(), r.toJson());
      expect(back.scans, [d(3), d(5)]);
      expect(
          TtcTreatmentCycle.fromJson({
            'dates': {},
            'scans': ['2026-10-06', '2026-10-04'],
          }).scans,
          [d(3), d(5)],
          reason: 'scans are read in date order');
    });
  });

  // ===========================================================================
  group('the switch (decisions 1 and 2)', () {
    test('active from the first treatment date until closed', () {
      final r = round(TtcRoundKind.ivfFresh, {
        TtcTreatmentStep.baselineScan: d(0),
        TtcTreatmentStep.betaTest: d(29),
      });
      expect(ttcTreatmentActive(r, d(-1)), isFalse,
          reason: 'next month\'s dates do not switch this month off');
      expect(ttcTreatmentActive(r, d(0)), isTrue);
      expect(ttcTreatmentActive(r, d(60)), isTrue,
          reason: 'open until she closes it');
      final closed = r.closed(TtcRoundOutcome.ended, d(40));
      expect(ttcTreatmentActive(closed, d(39)), isTrue);
      expect(ttcTreatmentActive(closed, d(40)), isFalse);
    });

    test('the tier comes from the kind and the trigger', () {
      TimingOwnership tier(TtcRoundKind k, {bool trigger = false}) =>
          ttcRoundTier(round(k, {
            TtcTreatmentStep.stimStart: d(1),
            if (trigger) TtcTreatmentStep.trigger: d(10),
          }));
      for (final k in [
        TtcRoundKind.ivfFresh,
        TtcRoundKind.ivfFreezeAll,
        TtcRoundKind.fetMedicated,
        TtcRoundKind.notSure,
      ]) {
        expect(tier(k), TimingOwnership.clinicControlled, reason: k.name);
      }
      expect(tier(TtcRoundKind.iui), TimingOwnership.clinicGuided);
      expect(tier(TtcRoundKind.iui, trigger: true),
          TimingOwnership.clinicControlled);
      expect(tier(TtcRoundKind.ovulationInduction),
          TimingOwnership.clinicGuided);
      expect(tier(TtcRoundKind.ovulationInduction, trigger: true),
          TimingOwnership.clinicControlled);
      expect(tier(TtcRoundKind.fetNatural), TimingOwnership.clinicGuided);
    });

    test('a round owns the cycles it ran in, and only those', () {
      final r = round(TtcRoundKind.ivfFresh, {
        TtcTreatmentStep.downRegStart: d(-10),
        TtcTreatmentStep.stimStart: d(5),
        TtcTreatmentStep.betaTest: d(30),
      }).closed(TtcRoundOutcome.negative, d(31));
      // A cycle from before it, one it spans with no date in it, and one after.
      expect(ttcRoundRanDuring(r, d(-40), d(-12), d(40)), isFalse);
      expect(ttcRoundRanDuring(r, d(-12), d(3), d(40)), isTrue);
      expect(ttcRoundRanDuring(r, d(10), d(20), d(40)), isTrue,
          reason: 'a cycle inside the round with no date of its own');
      expect(ttcRoundRanDuring(r, d(33), null, d(40)), isFalse,
          reason: 'the cycle after it is hers');
    });
  });

  // ===========================================================================
  group('the check-in: never close, always ask (decision 3)', () {
    final r = round(TtcRoundKind.ivfFresh, {
      TtcTreatmentStep.stimStart: d(1),
      TtcTreatmentStep.betaTest: d(29),
    });

    test('7 quiet days with nothing ahead', () {
      expect(ttcTreatmentNeedsCheckIn(r, d(29)), isFalse,
          reason: 'the test day is today, not passed');
      expect(ttcTreatmentNeedsCheckIn(r, d(35)), isFalse, reason: '6 days');
      expect(ttcTreatmentNeedsCheckIn(r, d(36)), isTrue, reason: '7 days');
    });

    test('a date ahead, or something new, holds it back', () {
      final ahead = r.withDate(TtcTreatmentStep.reviewAppointment, d(50));
      expect(ttcTreatmentNeedsCheckIn(ahead, d(40)), isFalse);
      final touched = r.withActivity(d(33));
      expect(ttcTreatmentNeedsCheckIn(touched, d(39)), isFalse);
      expect(ttcTreatmentNeedsCheckIn(touched, d(40)), isTrue);
    });

    test('a closed round is never asked about', () {
      expect(
          ttcTreatmentNeedsCheckIn(
              r.closed(TtcRoundOutcome.negative, d(30)), d(60)),
          isFalse);
    });

    test('30 days away asks on return, 29 does not', () {
      expect(ttcTreatmentAskOnReturn(r, d(40), d(11)), isFalse);
      expect(ttcTreatmentAskOnReturn(r, d(40), d(10)), isTrue);
      expect(ttcTreatmentAskOnReturn(r, d(40), null), isFalse);
    });

    test('the store asks, snoozes gently, and never closes on its own', () {
      final store = TtcTreatmentStore.instance;
      store.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {
            TtcTreatmentStep.stimStart: d(1),
            TtcTreatmentStep.betaTest: d(29),
          },
          now: d(0));
      expect(store.checkInDue(now: d(30)), isFalse);
      expect(store.checkInDue(now: d(36)), isTrue);
      store.snoozeCheckIn(now: d(36));
      expect(store.checkInDue(now: d(38)), isFalse, reason: 'ask me later');
      expect(store.checkInDue(now: d(39)), isTrue,
          reason: 'at most once every few days, not never');
      // A hundred days on, nothing has closed it.
      expect(store.checkInDue(now: d(140)), isTrue);
      expect(store.cycle.isClosed, isFalse);
      expect(store.history, isEmpty);
      expect(ttcTreatmentActive(store.cycle, d(140)), isTrue);
      // "Still going" resets the clock.
      store.stillGoing(now: d(140));
      expect(store.checkInDue(now: d(146)), isFalse);
      expect(store.checkInDue(now: d(147)), isTrue);
    });

    test('a return after 30 days flags the store until she answers', () {
      final store = TtcTreatmentStore.instance;
      store.startRound(
          kind: TtcRoundKind.iui,
          dates: {TtcTreatmentStep.stimStart: d(1)},
          now: d(0));
      store.noteOpened(now: d(2));
      expect(store.askOnReturnPending, isFalse);
      store.noteOpened(now: d(31));
      expect(store.askOnReturnPending, isFalse, reason: '29 days');
      store.noteOpened(now: d(61));
      expect(store.askOnReturnPending, isTrue, reason: '30 days away');
      expect(store.checkInDue(now: d(61)), isTrue);
      store.stillGoing(now: d(61));
      expect(store.askOnReturnPending, isFalse);
    });
  });

  // ===========================================================================
  group('closing, history and undo', () {
    test('closing keeps the round in history; undo restores it exactly', () {
      final store = TtcTreatmentStore.instance;
      store.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.stimStart: d(1)},
          clinic: 'Bloom IVF',
          now: d(0));
      store.addScan(d(6));
      final before = store.cycle.toJson();
      store.closeRound(TtcRoundOutcome.negative, now: d(30));
      expect(store.cycle.isEmpty, isTrue);
      expect(store.history.single.outcome, TtcRoundOutcome.negative);
      expect(store.history.single.closedOn, d(30));
      expect(store.canUndoClose(now: d(37)), isTrue, reason: '7 days');
      expect(store.canUndoClose(now: d(38)), isFalse, reason: '8 days');
      expect(store.undoClose(now: d(35)), isTrue);
      expect(store.cycle.toJson(), before, reason: 'exactly as it was');
      expect(store.history, isEmpty);
    });

    test('starting a new round closes the open one into history', () {
      final store = TtcTreatmentStore.instance;
      store.startRound(
          kind: TtcRoundKind.iui,
          dates: {TtcTreatmentStep.stimStart: d(1)},
          now: d(0));
      final firstId = store.cycle.id;
      store.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.baselineScan: d(40)},
          now: d(35));
      expect(store.history.single.id, firstId);
      expect(store.history.single.outcome, TtcRoundOutcome.ended);
      expect(store.cycle.kind, TtcRoundKind.ivfFresh);
      expect(store.cycle.id, isNot(firstId));
    });

    test('a legacy round is adopted, its dates kept', () {
      final store = TtcTreatmentStore.instance;
      store.setDate(TtcTreatmentStep.transfer, d(18));
      expect(store.cycle.kind, isNull);
      store.startRound(
          kind: TtcRoundKind.fetMedicated,
          dates: {TtcTreatmentStep.estrogenStart: d(2)},
          now: d(0));
      expect(store.cycle.kind, TtcRoundKind.fetMedicated);
      expect(store.cycle[TtcTreatmentStep.transfer], d(18));
      expect(store.history, isEmpty, reason: 'adopted, not closed');
    });

    test('the plan changed keeps every date and remembers the old kind', () {
      final store = TtcTreatmentStore.instance;
      store.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.stimStart: d(1)},
          now: d(0));
      store.changeKind(TtcRoundKind.ivfFreezeAll);
      expect(store.cycle.kind, TtcRoundKind.ivfFreezeAll);
      expect(store.cycle.changedFrom, TtcRoundKind.ivfFresh);
      expect(store.cycle[TtcTreatmentStep.stimStart], d(1));
    });

    test('everything survives a restart', () async {
      final store = TtcTreatmentStore.instance;
      store.startRound(
          kind: TtcRoundKind.iui,
          dates: {TtcTreatmentStep.stimStart: d(1)},
          now: d(0));
      store.closeRound(TtcRoundOutcome.paused, now: d(20));
      store.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.baselineScan: d(40)},
          now: d(35));
      store.noteOpened(now: d(36));
      await Future<void>.delayed(Duration.zero);
      final cycle = store.cycle.toJson();
      final history = [for (final h in store.history) h.toJson()];
      await store.reloadForTest();
      expect(store.cycle.toJson(), cycle);
      expect([for (final h in store.history) h.toJson()], history);
    });
  });

  // ===========================================================================
  group('each announcement is due exactly once', () {
    test('"your home now follows your round" on its first treatment day', () {
      final store = TtcTreatmentStore.instance;
      store.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.baselineScan: d(5)},
          now: d(0));
      expect(store.activeAnnouncementDue(now: d(4)), isFalse,
          reason: 'not before the first treatment day');
      expect(store.activeAnnouncementDue(now: d(5)), isTrue);
      store.markActiveAnnounced();
      expect(store.activeAnnouncementDue(now: d(6)), isFalse);
    });

    test('saving a round that is already running counts as the announcement',
        () {
      final store = TtcTreatmentStore.instance;
      store.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {TtcTreatmentStep.stimStart: d(0)},
          now: d(3));
      expect(store.activeAnnouncementDue(now: d(3)), isFalse,
          reason: 'the start flow said it on the way in');
    });

    test('"your fertile days are back" once, never after a positive', () {
      final store = TtcTreatmentStore.instance;
      store.startRound(
          kind: TtcRoundKind.iui,
          dates: {TtcTreatmentStep.stimStart: d(1)},
          now: d(0));
      store.closeRound(TtcRoundOutcome.negative, now: d(30));
      expect(store.returnAnnouncementDue(ownCycleAgain: false), isFalse,
          reason: 'not until her own cycle is back');
      expect(store.returnAnnouncementDue(ownCycleAgain: true), isTrue);
      store.markReturnAnnounced();
      expect(store.returnAnnouncementDue(ownCycleAgain: true), isFalse);

      store.startRound(
          kind: TtcRoundKind.iui,
          dates: {TtcTreatmentStep.stimStart: d(40)},
          now: d(40));
      store.closeRound(TtcRoundOutcome.positive, now: d(70));
      expect(store.returnAnnouncementDue(ownCycleAgain: true), isFalse);
    });
  });

  // ===========================================================================
  group('dates that look wrong are checked, never refused', () {
    final r = round(TtcRoundKind.ivfFresh, {
      TtcTreatmentStep.trigger: DateTime(2026, 10, 12, 21),
      TtcTreatmentStep.retrieval: d(13),
    });

    test('collection on or before the trigger day', () {
      final p = ttcTreatmentDateProblem(r, TtcTreatmentStep.retrieval, d(11),
          now: d(0));
      expect(p?.kind, TtcDateProblemKind.beforeEarlierStep);
      expect(p?.other, TtcTreatmentStep.trigger);
    });

    test('a trigger after collection', () {
      final p = ttcTreatmentDateProblem(r, TtcTreatmentStep.trigger, d(14),
          now: d(0));
      expect(p?.kind, TtcDateProblemKind.afterLaterStep);
    });

    test('a transfer before collection', () {
      final p = ttcTreatmentDateProblem(r, TtcTreatmentStep.transfer, d(12),
          now: d(0));
      expect(p?.kind, TtcDateProblemKind.beforeEarlierStep);
      expect(p?.other, TtcTreatmentStep.retrieval);
    });

    test('in order and near: no problem', () {
      expect(
          ttcTreatmentDateProblem(r, TtcTreatmentStep.transfer, d(18),
              now: d(0)),
          isNull);
    });

    test('far in the past or future', () {
      expect(
          ttcTreatmentDateProblem(r, TtcTreatmentStep.reviewAppointment,
                  d(-100),
                  now: d(0))
              ?.kind,
          TtcDateProblemKind.farPast);
      expect(
          ttcTreatmentDateProblem(r, TtcTreatmentStep.reviewAppointment,
                  d(300),
                  now: d(0))
              ?.kind,
          TtcDateProblemKind.farFuture);
    });
  });
}
