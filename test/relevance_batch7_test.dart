// Relevance Batch 7, notifications, for Pregnancy and TTC (2026-10-28).
//
// PREGNANCY-GAP 11: weeks 4 to 10 said nothing but "a new week", and the
// sugar test and the growth scan were never mentioned. Four kinds now fill
// those gaps, on the Scans door's own weeks, and the dating scan stays quiet
// when her clinic already gave the date (the user's call).
//
// TTC: a natural cycle had nothing between the window and a late period. The
// wait message comes the morning after her window closes, and is read from
// THIS cycle's window even after the window tool has rolled on to the next.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/doors/pv_door_data.dart' show PvDoorLibrary;
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart' show pvDoorEntryScreen;
import 'package:parentveda/screens/pregnancy/preg_messages_screen.dart';
import 'package:parentveda/screens/ttc/chats/ttc_chat.dart' show ttcFirstOpenable;
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/preg_messages_store.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_care_pathway.dart';
import 'package:parentveda/ttc/ttc_fertile_window.dart';
import 'package:parentveda/ttc/ttc_fertility_help_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';

/// A due date that puts [now] at the start of week [w], day 1.
DateTime _dueFor(int w, DateTime now) =>
    DateTime(now.year, now.month, now.day).add(Duration(days: 7 * (40 - w) + 6));

PregMessageFacts _facts(DateTime due, {bool clinic = false}) =>
    PregMessageFacts(dueDate: due, dueDateSet: true, dueDateFromClinic: clinic);

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final now = DateTime(2026, 10, 1, 7);

  group('Pregnancy: the four new moments (PREG 11)', () {
    Map<PregMessageKind, PregMessage> byKind(List<PregMessage> l) =>
        {for (final m in l) m.kind: m};

    test('at week 5: first visit at week 6, dating scan at week 7, 10am on day two', () {
      final due = _dueFor(5, now);
      final k = byKind(pregMessageCandidates(_facts(due), now));
      for (final (kind, w) in [
        (PregMessageKind.firstVisit, 6),
        (PregMessageKind.datingScan, 7),
        (PregMessageKind.glucoseTest, 24),
        (PregMessageKind.growthScan, 32),
      ]) {
        final m = k[kind];
        expect(m, isNotNull, reason: kind.name);
        expect(pregWeekOn(due, m!.at), w, reason: kind.name);
        expect(m.at, pregWeekStart(due, w).add(const Duration(days: 1, hours: 10)),
            reason: kind.name);
        expect(m.id, kind.name, reason: 'the id is the moment, so it moves with the date');
      }
    });

    test('the dating scan is skipped when a scan, doctor or transfer gave the date', () {
      final due = _dueFor(5, now);
      final k = byKind(pregMessageCandidates(_facts(due, clinic: true), now));
      expect(k[PregMessageKind.datingScan], isNull);
      expect(k[PregMessageKind.firstVisit], isNotNull,
          reason: 'the first visit still helps after a clinic date');
    });

    test('each is offered only while it can still help', () {
      bool has(int week, PregMessageKind kind) =>
          byKind(pregMessageCandidates(_facts(_dueFor(week, now)), now)).containsKey(kind);
      expect(has(10, PregMessageKind.firstVisit), isTrue);
      expect(has(11, PregMessageKind.firstVisit), isFalse);
      expect(has(9, PregMessageKind.datingScan), isTrue);
      expect(has(10, PregMessageKind.datingScan), isFalse);
      expect(has(28, PregMessageKind.glucoseTest), isTrue);
      expect(has(29, PregMessageKind.glucoseTest), isFalse);
      expect(has(36, PregMessageKind.growthScan), isTrue);
      expect(has(37, PregMessageKind.growthScan), isFalse);
    });

    test('the growth scan says "if advised", never that she needs one', () {
      final m = byKind(pregMessageCandidates(_facts(_dueFor(20, now)), now))[
          PregMessageKind.growthScan]!;
      expect(m.title, contains('if advised'));
      expect(m.body, contains('If your doctor has suggested'));
    });

    test('a first launch at week 9 delivers both early moments at once, in the app only', () async {
      final store = PregMessagesStore.instance..resetForTest();
      final due = _dueFor(9, now);
      store.apply(pregMessageCandidates(_facts(due), now), now);
      final ids = store.delivered(now: now).map((m) => m.id).toSet();
      expect(ids, containsAll(['firstVisit', 'datingScan']));
      expect(store.pending(now: now).map((m) => m.kind),
          isNot(contains(PregMessageKind.firstVisit)));
    });

    test('every kind has its own phone id, label and line', () {
      final ids = [for (final k in PregMessageKind.values) ...k.phoneIds];
      expect(ids.toSet().length, ids.length);
      expect(ids.every((id) => id >= 919101 && id <= 919199), isTrue,
          reason: "inside Pregnancy's own block, clear of TTC's 918xxx");
      expect(PregMessageKind.values.map((k) => k.label).toSet().length,
          PregMessageKind.values.length);
      for (final k in PregMessageKind.values) {
        expect(k.when, isNotEmpty, reason: k.name);
      }
    });

    test('wiring gate: each new message opens a page that exists', () {
      final c = PregnancyController(dueDate: _dueFor(20, now), now: now);
      expect(pregnancyReadById('preg_scan_read_first_visit'), isNotNull);
      for (final k in [
        PregMessageKind.datingScan,
        PregMessageKind.glucoseTest,
        PregMessageKind.growthScan,
      ]) {
        final id = pregMessageScanId(k);
        expect(id, isNotNull, reason: k.name);
        expect(pvDoorEntryScreen(PvDoorLibrary.scan, id!, c), isNotNull, reason: k.name);
      }
    });
  });

  group('TTC: the two-week wait', () {
    final morning = DateTime(2026, 10, 20, 7);
    final wait = DateTime(2026, 10, 21);
    TtcMessage? find(TtcMessageFacts f, DateTime at) => ttcMessageCandidates(f, at)
        .where((m) => m.kind == TtcMessageKind.waitStarts)
        .firstOrNull;

    test('the morning after the window closes, at 9, once', () {
      final m = find(TtcMessageFacts(waitStarts: wait), morning);
      expect(m, isNotNull);
      expect(m!.at, DateTime(2026, 10, 21, 9));
      expect(m.id, 'wait:2026-10-21');
    });

    test('worth saying for three days, then not', () {
      final f = TtcMessageFacts(waitStarts: wait);
      expect(find(f, DateTime(2026, 10, 23, 20)), isNotNull);
      expect(find(f, DateTime(2026, 10, 24, 7)), isNull);
    });

    test('never on a clinic cycle, without window reminders, or once pregnant', () {
      expect(
          find(TtcMessageFacts(waitStarts: wait, ownership: TimingOwnership.clinicGuided),
              morning),
          isNull);
      expect(find(TtcMessageFacts(waitStarts: wait, sendsOvulationReminders: false), morning),
          isNull);
      expect(find(TtcMessageFacts(waitStarts: wait, pregnancyConfirmed: true), morning),
          isNull);
      expect(find(const TtcMessageFacts(), morning), isNull);
    });

    test('it opens the two-week wait read', () {
      expect(ttcFirstOpenable(TtcMessageKind.waitStarts.destinations),
          'ttc_read/ttc_read_two_week_wait');
      final ids = [for (final k in TtcMessageKind.values) ...k.phoneIds];
      expect(ids.toSet().length, ids.length);
    });

    group('from the live stores', () {
      setUpAll(() async {
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
      });

      void cyclesEndingDaysAgo(int daysAgo) {
        final t = DateTime.now();
        CycleStore.instance
          ..logPeriodStart(t.subtract(Duration(days: daysAgo + 56)))
          ..logPeriodStart(t.subtract(Duration(days: daysAgo + 28)))
          ..logPeriodStart(t.subtract(Duration(days: daysAgo)));
      }

      test("before the window: the wait day is this cycle's close plus one", () {
        cyclesEndingDaysAgo(3);
        final w = ttcFertileWindowNow()!;
        expect(w.cyclesAhead, 0);
        final f = TtcMessageFacts.fromStores();
        expect(f.waitStarts, _day(w.closesOn).add(const Duration(days: 1)));
      });

      test('after the window closed: still THIS cycle, though the tool rolled on', () {
        cyclesEndingDaysAgo(18);
        final w = ttcFertileWindowNow()!;
        expect(w.cyclesAhead, 1, reason: 'the tool now shows next cycle');
        final f = TtcMessageFacts.fromStores();
        expect(f.windowCloses, isNull, reason: 'why closesOn could not be used');
        final start = _day(CycleStore.instance.lastPeriodStart!);
        expect(f.waitStarts, start.add(Duration(days: w.closesCycleDay)));
        expect(f.waitStarts!.isBefore(_day(DateTime.now())), isTrue);
      });
    });
  });
}
