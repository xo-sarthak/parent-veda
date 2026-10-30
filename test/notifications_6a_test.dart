// Notifications Phase 6a (2026-10-28, docs/NOTIFICATIONS-PLAN.md).
//
// The user's shape, held here:
//   * every type stays silent until what it points to exists;
//   * care is on by default, offers are off until she says yes;
//   * at most two on her phone a day, one morning, one evening, care first;
//     what loses its slot still lands in Messages;
//   * never on a loss path.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pv_door_symptoms.dart' show kSymptomsBracketId;
import 'package:parentveda/data/preg_daily_tips.dart';
import 'package:parentveda/screens/doors/pv_door_screen.dart' show pvDoorScreenForBracket;
import 'package:parentveda/screens/ttc/chats/ttc_chat.dart' show ttcFirstOpenable;
import 'package:parentveda/services/preg_message_offers.dart';
import 'package:parentveda/services/preg_messages_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart' show ttcAllInsights;
import 'package:parentveda/ttc/ttc_message_offers.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';

DateTime _dueFor(int w, DateTime now) =>
    DateTime(now.year, now.month, now.day).add(Duration(days: 7 * (40 - w) + 6));

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

class _Phone implements PregMessagePhone {
  final Map<int, DateTime> armed = {};
  @override
  Future<void> schedule(
      {required int id, required String title, required String body, required DateTime when, String? payload}) async {
    armed[id] = when;
  }

  @override
  Future<void> cancel(int id) async => armed.remove(id);
}

const _offer = PregOffer(ref: 'product:p1', title: 'For this week: a pillow', body: 'In the Store.');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final now = DateTime(2026, 10, 1, 7); // 7 am, day 1 of her week

  PregMessageFacts facts(int week,
          {bool checked = false, Map<int, List<PregOffer>> offers = const {}, bool ended = false}) =>
      PregMessageFacts(
          dueDate: _dueFor(week, now),
          dueDateSet: true,
          ended: ended,
          checkedInToday: checked,
          offersByWeek: offers);

  List<PregMessage> of(List<PregMessage> l, PregMessageKind k) => [for (final m in l) if (m.kind == k) m];

  group('Pregnancy: the daily kinds', () {
    test("a tip every morning for two weeks, at 8:30, the week's own tip", () {
      final tips = of(pregDailyCandidates(facts(22), now), PregMessageKind.dayLine);
      expect(tips, hasLength(kPregDailyDays));
      expect(tips.first.at, DateTime(2026, 10, 1, 8, 30));
      expect(tips.first.body, pregDailyTipFor(22, 1));
      expect(tips[8].body, pregDailyTipFor(23, 2), reason: 'day 9 is week 23, day 2');
      expect(tips.first.id, 'day:22:1', reason: 'week and day, so a new due date moves it');
    });

    test('the check-in: every other evening, not once she has logged, never late', () {
      final f = facts(22);
      final checks = of(pregDailyCandidates(f, now), PregMessageKind.checkIn);
      expect(checks.length, inInclusiveRange(6, 7));
      for (final m in checks) {
        expect(m.at.hour, 19);
        expect(m.at.minute, 30);
      }
      final gaps = [for (var i = 1; i < checks.length; i++) checks[i].at.difference(checks[i - 1].at).inDays];
      expect(gaps.every((g) => g == 2), isTrue);

      final tonight = checks.where((m) => _day(m.at) == _day(now));
      if (tonight.isNotEmpty) {
        expect(of(pregDailyCandidates(facts(22, checked: true), now), PregMessageKind.checkIn)
                .where((m) => _day(m.at) == _day(now)),
            isEmpty);
      }
      final lateNight = DateTime(2026, 10, 1, 21);
      expect(of(pregDailyCandidates(f, lateNight), PregMessageKind.checkIn)
              .where((m) => _day(m.at) == _day(now)),
          isEmpty);
    });

    test('silent until it exists: no offer with nothing to offer', () {
      expect(of(pregDailyCandidates(facts(22), now), PregMessageKind.offer), isEmpty);
    });

    test('with something real: day 3 and day 6 of her week, at 7 pm', () {
      final f = facts(22, offers: {22: [_offer], 23: [_offer]});
      final offers = of(pregDailyCandidates(f, now), PregMessageKind.offer);
      expect(offers, isNotEmpty);
      for (final m in offers) {
        expect(m.at.hour, 19);
        final dow = _day(m.at).difference(pregWeekStart(f.dueDate, m.week!)).inDays + 1;
        expect([3, 6], contains(dow));
        expect(m.ref, 'product:p1');
      }
    });

    test('offers are off until she says yes; then they arrive', () async {
      final store = PregMessagesStore.instance..resetForTest();
      store.phone = _Phone();
      expect(store.isOn(PregMessageKind.offer), isFalse);
      expect(store.isOn(PregMessageKind.dayLine), isTrue);
      final f = facts(22, offers: {22: [_offer], 23: [_offer]});
      await store.refresh(now: now, facts: f);
      expect(store.pending(now: now).where((m) => m.kind == PregMessageKind.offer), isEmpty);
      await store.answerOffers(true);
      expect(store.offersAsked, isTrue);
      await store.refresh(now: now, facts: f);
      expect(store.pending(now: now).where((m) => m.kind == PregMessageKind.offer), isNotEmpty);
    });

    test('never after a loss', () {
      expect(pregDailyCandidates(facts(22, ended: true), now), isEmpty);
    });
  });

  group('Pregnancy: two a day, care first', () {
    test('at most one morning and one evening a day, across a whole week', () async {
      final store = PregMessagesStore.instance..resetForTest();
      final phone = _Phone();
      store.phone = phone;
      await store.answerOffers(true);
      await store.refresh(now: now, facts: facts(17, offers: {17: [_offer], 18: [_offer], 19: [_offer]}));
      final perDay = <DateTime, List<DateTime>>{};
      for (final at in phone.armed.values) {
        perDay.putIfAbsent(_day(at), () => []).add(at);
      }
      for (final e in perDay.entries) {
        expect(e.value.length, lessThanOrEqualTo(2), reason: '${e.key}');
        expect(e.value.where((t) => t.hour < kPregEveningFromHour).length, lessThanOrEqualTo(1));
        expect(e.value.where((t) => t.hour >= kPregEveningFromHour).length, lessThanOrEqualTo(1));
      }
    });

    test('a dated moment beats the new week beats the tip; the check-in beats an offer', () {
      PregMessage m(PregMessageKind k, DateTime at) =>
          PregMessage(id: '${k.name}${at.hour}', kind: k, at: at, title: k.name, body: '');
      final d = DateTime(2026, 10, 5);
      final plan = pregPhonePlan([
        m(PregMessageKind.dayLine, d.add(const Duration(hours: 8, minutes: 30))),
        m(PregMessageKind.newWeek, d.add(const Duration(hours: 9))),
        m(PregMessageKind.anomalyScan, d.add(const Duration(hours: 10))),
        m(PregMessageKind.offer, d.add(const Duration(hours: 19))),
        m(PregMessageKind.checkIn, d.add(const Duration(hours: 19, minutes: 30))),
      ]);
      expect(plan.map((e) => e.$2.kind), [PregMessageKind.anomalyScan, PregMessageKind.checkIn]);
      final ids = plan.map((e) => e.$1).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('what loses its slot still reaches Messages when its moment comes', () {
      final store = PregMessagesStore.instance..resetForTest();
      final f = facts(22);
      store.apply(pregMessageCandidates(f, now), now);
      final later = DateTime(2026, 10, 1, 10);
      store.apply(pregMessageCandidates(f, later), later);
      final kinds = store.delivered(now: later).map((m) => m.kind).toSet();
      expect(kinds, containsAll([PregMessageKind.newWeek, PregMessageKind.dayLine]),
          reason: 'the tip lost the 9 am slot to the new week but is in Messages');
    });

    test('daily kinds leave Messages after two weeks; dated moments stay', () {
      final store = PregMessagesStore.instance..resetForTest();
      final old = DateTime(2026, 9, 1, 9);
      store.apply([
        PregMessage(id: 'day:18:1', kind: PregMessageKind.dayLine, at: old, title: 't', body: ''),
        PregMessage(id: 'anomalyScan', kind: PregMessageKind.anomalyScan, at: old, title: 'a', body: ''),
      ], old.add(const Duration(hours: 1)));
      store.apply(const [], now);
      final ids = store.delivered(now: now).map((m) => m.id).toSet();
      expect(ids, {'anomalyScan'});
    });

    test('wiring gate: the check-in opens the Symptoms door', () {
      final c = PregnancyController(dueDate: _dueFor(22, now), now: now);
      expect(pvDoorScreenForBracket(kSymptomsBracketId, c), isNotNull);
    });

    test('every kind keeps its own phone ids, none shared', () {
      final ids = [for (final k in PregMessageKind.values) ...k.phoneIds];
      expect(ids.toSet().length, ids.length);
    });
  });

  group('TTC', () {
    final sep1 = DateTime(2026, 9, 1, 7);
    TtcMessageFacts steady({TimingOwnership owner = TimingOwnership.parentveda, DateTime? start}) =>
        TtcMessageFacts(
          ownership: owner,
          periodStarts: [DateTime(2026, 6, 17), DateTime(2026, 7, 15), DateTime(2026, 8, 12)],
          cycleLengths: const [28, 28],
          usualLength: 28,
          cycleStart: start ?? DateTime(2026, 8, 12),
          ovulationDay: 14,
          cycleLength: 28,
        );
    List<TtcMessage> kind(List<TtcMessage> l, TtcMessageKind k) => [for (final m in l) if (m.kind == k) m];

    test('period soon: two days before it is due, 9 am, and not on the day itself', () {
      final soon = kind(ttcMessageCandidates(steady(), sep1), TtcMessageKind.periodSoon);
      expect(soon, hasLength(1));
      expect(soon.single.at, DateTime(2026, 9, 7, 9));
      expect(kind(ttcMessageCandidates(steady(), DateTime(2026, 9, 9, 7)), TtcMessageKind.periodSoon),
          isEmpty);
    });

    test('a line each morning on her own cycle, opening a real insight', () {
      final lines = kind(ttcDailyCandidates(steady(), sep1), TtcMessageKind.dayLine);
      expect(lines, isNotEmpty);
      final ids = {for (final i in ttcAllInsights) i.id};
      for (final m in lines) {
        expect(m.at.hour, 8);
        final to = m.destinations.first;
        expect(to.startsWith('ttc_insight/'), isTrue);
        expect(ids, contains(to.substring('ttc_insight/'.length)));
      }
    });

    test('no lines on a clinic cycle; nothing daily after a loss until her period', () {
      expect(kind(ttcDailyCandidates(steady(owner: TimingOwnership.clinicGuided), sep1),
              TtcMessageKind.dayLine),
          isEmpty);
      const afterLoss = TtcMessageFacts(cycleLength: 28, ovulationDay: 14);
      expect(ttcDailyCandidates(afterLoss, sep1), isEmpty);
    });

    test('no daily lines more than a week past the cycle: a missed log, not a wait', () {
      final f = steady(start: DateTime(2026, 7, 20));
      expect(ttcDailyCandidates(f, sep1), isEmpty);
    });

    test('offers: none without something real; before the window and before it is due with', () {
      final base = steady();
      expect(kind(ttcDailyCandidates(base, sep1), TtcMessageKind.offer), isEmpty);
      const kit = TtcOffer(to: 'product/k1', title: 'Tests', body: 'In the Store.');
      final f = TtcMessageFacts(
        periodStarts: base.periodStarts,
        cycleLengths: base.cycleLengths,
        usualLength: 28,
        cycleStart: base.cycleStart,
        ovulationDay: 14,
        cycleLength: 28,
        windowOpens: DateTime(2026, 9, 15),
        windowCloses: DateTime(2026, 9, 20),
        offersBeforeWindow: const [kit],
        offersBeforeDue: const [kit],
      );
      final offers = kind(ttcDailyCandidates(f, sep1), TtcMessageKind.offer);
      expect(offers.map((m) => m.at), containsAll([DateTime(2026, 9, 12, 19), DateTime(2026, 9, 7, 19)]));
      expect(offers.first.destinations.first, 'product/k1');
    });

    test('offers start off; care kinds start on', () {
      final store = TtcMessagesStore.instance..resetForTest();
      expect(store.isOn(TtcMessageKind.offer), isFalse);
      expect(store.isOn(TtcMessageKind.dayLine), isTrue);
      expect(store.isOn(TtcMessageKind.periodSoon), isTrue);
    });

    test('two a day, care first; treatment is her clinic’s and never capped', () {
      TtcMessage m(TtcMessageKind k, DateTime at, [String? id]) =>
          TtcMessage(id: id ?? '${k.name}${at.hour}', kind: k, at: at, title: k.name, body: '');
      final d = DateTime(2026, 9, 7);
      final plan = ttcPhonePlan([
        m(TtcMessageKind.dayLine, d.add(const Duration(hours: 8, minutes: 30))),
        m(TtcMessageKind.periodSoon, d.add(const Duration(hours: 9))),
        m(TtcMessageKind.offer, d.add(const Duration(hours: 19))),
        m(TtcMessageKind.checkIn, d.add(const Duration(hours: 19, minutes: 30))),
        m(TtcMessageKind.treatment, d.add(const Duration(hours: 20)), 'treat:a'),
        m(TtcMessageKind.treatment, d.add(const Duration(hours: 7)), 'treat:b'),
      ]);
      expect(plan.map((e) => e.$2.kind).toList(), [
        TtcMessageKind.treatment,
        TtcMessageKind.periodSoon,
        TtcMessageKind.checkIn,
        TtcMessageKind.treatment,
      ]);
    });

    test('the new kinds open pages that exist', () {
      expect(ttcFirstOpenable(TtcMessageKind.periodSoon.destinations), isNotNull);
      expect(ttcFirstOpenable(TtcMessageKind.checkIn.destinations), isNotNull);
      expect(ttcFirstOpenable(TtcMessageKind.offer.destinations), isNotNull);
      final ids = [for (final k in TtcMessageKind.values) ...k.phoneIds];
      expect(ids.toSet().length, ids.length);
    });
  });
}
