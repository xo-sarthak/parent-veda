// =============================================================================
//  Trying again with a child, and Parenting on its own (2026-10-29): moments
//  always ring, nothing rings together, TTC arms exactly as on its own
// -----------------------------------------------------------------------------
//  docs/NOTIFICATIONS-PLAN.md, "As built: trying again with a child". The
//  rules are pure (`parentingPhonePlan`, `spacePhoneRings`), so most of this
//  is plain values; the last group holds the wiring.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/family_phone_plan.dart';
import 'package:parentveda/services/pp_messages_store.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';

class _PpPhone implements PpMessagePhone {
  final Map<int, (DateTime, String)> armed = {};
  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    armed[id] = (when, title);
  }

  @override
  Future<void> cancel(int id) async => armed.remove(id);
}

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // Monday 2 November 2026, 7 in the morning.
  final now = DateTime(2026, 11, 2, 7);
  final d = _day(now);
  DateTime at(int h, [int m = 0]) => d.add(Duration(hours: h, minutes: m));

  PpMessage pp(PpMessageKind k, int h, [int m = 0, String id = '']) =>
      PpMessage(
        id: '${k.name}$h$m$id',
        kind: k,
        at: at(h, m),
        title: k.name,
        body: '',
      );

  DateTime movedTo(PpMessage m, List<DateTime> ttc) =>
      spacePhoneRings([(1, m)], keepClearOf: ttc, now: now).single.$2.at;

  group('A · a child\'s ring steps out of TTC\'s way', () {
    test('the worked examples from the plan', () {
      // The tip and the day line, both 8:30: the tip goes to 9:30.
      expect(movedTo(pp(PpMessageKind.tip, 8, 30), [at(8, 30)]), at(9, 30));
      // An age at 9 and the cycle report at 9: the age goes to 10.
      expect(movedTo(pp(PpMessageKind.age, 9), [at(9)]), at(10));
      // An offer at 7 pm, the check-in at 7:30: the offer goes to 6:30.
      expect(movedTo(pp(PpMessageKind.offer, 19), [at(19, 30)]), at(18, 30));
      // Two offers at 7 pm: a tie, later first, 8 pm.
      expect(movedTo(pp(PpMessageKind.offer, 19), [at(19)]), at(20));
    });

    test('with a new stage at 6 pm too, the offer goes to 8:30 pm', () {
      final out = spacePhoneRings(
        [
          (1, pp(PpMessageKind.milestones, 18)),
          (2, pp(PpMessageKind.offer, 19)),
        ],
        keepClearOf: [at(19, 30)],
        now: now,
      );
      expect(out.map((r) => r.$2.at), [at(18), at(20, 30)]);
    });

    test('clear already: nothing moves, the same message comes back', () {
      final m = pp(PpMessageKind.age, 9);
      final out = spacePhoneRings(
        [(1, m)],
        keepClearOf: [at(8, 0), at(19, 30)],
        now: now,
      );
      expect(identical(out.single.$2, m), isTrue);
    });

    test('never before 8, never after 9 pm, never in the past', () {
      expect(
        movedTo(pp(PpMessageKind.tip, 8, 30), [at(8, 30), at(9, 30)]),
        at(10, 30),
      );
      expect(movedTo(pp(PpMessageKind.offer, 21), [at(21)]), at(20));
      final late = DateTime(2026, 11, 2, 9, 10);
      final out = spacePhoneRings(
        [(1, pp(PpMessageKind.age, 10))],
        keepClearOf: [at(10)],
        now: late,
      );
      expect(out.single.$2.at.isAfter(late), isTrue);
      expect(out.single.$2.at, at(11));
    });

    test('no clear time that day: it rings at its own time, never dropped', () {
      final full = [for (var h = 8; h <= 21; h++) at(h)];
      final m = pp(PpMessageKind.vaccine, 10);
      final out = spacePhoneRings([(1, m)], keepClearOf: full, now: now);
      expect(out.single.$2.at, at(10));
    });

    test(
      'only the phone time moves: the id, title and kind are the message\'s',
      () {
        final m = pp(PpMessageKind.age, 9);
        final moved = spacePhoneRings(
          [(929101, m)],
          keepClearOf: [at(9)],
          now: now,
        ).single;
        expect(moved.$1, 929101);
        expect(moved.$2.id, m.id);
        expect(moved.$2.title, m.title);
        expect(moved.$2.kind, m.kind);
        expect(m.at, at(9), reason: 'the stored message keeps its own time');
      },
    );
  });

  group('B · Parenting with no pregnancy: moments always ring', () {
    test(
      'an age, a vaccine visit and a sibling\'s age, one morning: all three ring, an hour apart',
      () {
        final plan = parentingPhonePlan(
          pp: [
            pp(PpMessageKind.age, 9),
            pp(PpMessageKind.age, 9, 0, 'b'),
            pp(PpMessageKind.vaccine, 10),
            pp(PpMessageKind.tip, 8, 30),
          ],
          now: now,
        );
        final kinds = plan.map((r) => r.$2.kind).toList();
        expect(kinds.where((k) => k == PpMessageKind.age), hasLength(2));
        expect(kinds, contains(PpMessageKind.vaccine));
        // The tip is daily, and this morning has a moment: Messages only.
        expect(kinds, isNot(contains(PpMessageKind.tip)));
        final times = plan.map((r) => r.$2.at).toList()..sort();
        for (var i = 1; i < times.length; i++) {
          expect(
            times[i].difference(times[i - 1]) >= kFamilyRingGap,
            isTrue,
            reason: '$times',
          );
        }
      },
    );

    test('a free morning: the tip rings; a free evening: one daily kind', () {
      final plan = parentingPhonePlan(
        pp: [
          pp(PpMessageKind.tip, 8, 30),
          pp(PpMessageKind.offer, 19),
          pp(PpMessageKind.offer, 19, 0, 'b'),
        ],
        now: now,
      );
      expect(plan.map((r) => r.$2.kind), [
        PpMessageKind.tip,
        PpMessageKind.offer,
      ]);
    });

    test('a moment in the evening keeps the offer off the phone', () {
      final plan = parentingPhonePlan(
        pp: [pp(PpMessageKind.milestones, 18), pp(PpMessageKind.offer, 19)],
        now: now,
      );
      expect(plan.map((r) => r.$2.kind), [PpMessageKind.milestones]);
    });

    test('each ring takes its own kind\'s ids, soonest first', () {
      final plan = parentingPhonePlan(
        pp: [pp(PpMessageKind.age, 9, 0, 'b'), pp(PpMessageKind.age, 9)],
        now: now,
      );
      expect(plan.map((r) => r.$1).toSet(), {929101, 929102});
    });
  });

  group('C · trying again with a child', () {
    // Two weeks of TTC: the day line every morning, the check-in every other
    // evening, a cycle report at 9, a period came at 7 pm, a clinic scan
    // reminder at 7 pm.
    final ttcPending = <TtcMessage>[
      for (var i = 0; i < 14; i++) ...[
        TtcMessage(
          id: 'tday:$i',
          kind: TtcMessageKind.dayLine,
          at: d.add(Duration(days: i, hours: 8, minutes: 30)),
          title: '',
          body: '',
        ),
        if (i.isOdd)
          TtcMessage(
            id: 'tcheck:$i',
            kind: TtcMessageKind.checkIn,
            at: d.add(Duration(days: i, hours: 19, minutes: 30)),
            title: '',
            body: '',
          ),
      ],
      TtcMessage(
        id: 'report',
        kind: TtcMessageKind.cycleReport,
        at: at(9),
        title: '',
        body: '',
      ),
      TtcMessage(
        id: 'came',
        kind: TtcMessageKind.periodCame,
        at: d.add(const Duration(days: 2, hours: 19)),
        title: '',
        body: '',
      ),
      TtcMessage(
        id: 'treat:scan',
        kind: TtcMessageKind.treatment,
        at: d.add(const Duration(days: 3, hours: 19)),
        title: '',
        body: '',
      ),
    ];

    final child = PpMessageFacts(
      dob: DateTime(2025, 11, 2),
      name: 'Aarav',
      realChild: true,
    );

    test(
      'TTC arms exactly ttcPhonePlan; every ring is an hour clear; no child ring is dropped',
      () {
        final ttc = ttcPhonePlan(ttcPending);
        final ttcAt = [for (final (_, m) in ttc) m.at];
        final ppAll = ppMessageCandidates(
          child,
          now,
        ).where((m) => m.at.isAfter(now)).toList();
        final unspaced = parentingPhonePlan(pp: ppAll, now: now);
        final plan = parentingPhonePlan(
          pp: ppAll,
          keepClearOf: ttcAt,
          now: now,
        );

        expect(plan.length, unspaced.length, reason: 'moved, never dropped');
        expect(
          plan.map((r) => r.$2.id).toSet(),
          unspaced.map((r) => r.$2.id).toSet(),
        );
        // A treatment reminder is among TTC's rings, never capped.
        expect(
          ttc.where((r) => r.$2.kind == TtcMessageKind.treatment),
          hasLength(1),
        );
        final all = [...ttcAt, for (final (_, m) in plan) m.at]..sort();
        for (var i = 1; i < all.length; i++) {
          final gap = all[i].difference(all[i - 1]);
          // Two TTC rings may sit as TTC puts them; ours never crowd anything.
          final ttcPair = ttcAt.contains(all[i]) && ttcAt.contains(all[i - 1]);
          expect(
            ttcPair || gap >= kFamilyRingGap,
            isTrue,
            reason: '${all[i - 1]} and ${all[i]}',
          );
        }
        // More than two a day is fine now, and does happen.
        final perDay = <DateTime, int>{};
        for (final t in all) {
          perDay[_day(t)] = (perDay[_day(t)] ?? 0) + 1;
        }
        expect(perDay.values.any((n) => n > 2), isTrue, reason: '$perDay');
      },
    );
  });

  group('wiring', () {
    test(
      'Parenting on its own, through the store: rings an hour apart, moments all armed',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s = PpMessagesStore.instance..resetForTest();
        final phone = _PpPhone();
        s.phone = phone;
        await s.refresh(now: now, facts: child2());
        final times = [for (final (t, _) in phone.armed.values) t]..sort();
        expect(times, isNotEmpty);
        for (var i = 1; i < times.length; i++) {
          expect(
            times[i].difference(times[i - 1]) >= kFamilyRingGap,
            isTrue,
            reason: '$times',
          );
        }
      },
    );

    test(
      'the call sites: TTC hands over after arming, from one definition; FamilyPhone reads it',
      () {
        final ttc = _code('lib/ttc/ttc_messages_store.dart');
        expect(ttc, contains('for (final (id, m) in phonePlanned(now: now))'));
        expect(ttc, contains('await FamilyPhone.instance.rearm(now: now);'));
        expect(
          ttc.indexOf('phonePlanned(now: now))'),
          lessThan(ttc.indexOf('FamilyPhone.instance.rearm(')),
        );
        final fam = _code(
          'lib/services/family_phone_plan.dart',
        ).replaceAll(RegExp(r'\s+'), '');
        expect(fam, contains('ttc.phonePlanned(now:now)'));
        expect(
          fam,
          contains(
            'parentingPhonePlan(pp:ppList,childIds:ids,keepClearOf:ttcRings,now:now,)',
          ),
        );
        // Pregnant: the PP 11 cap, unchanged.
        expect(
          fam,
          contains('familyPhonePlan(preg:pregList,pp:ppList,childIds:ids)'),
        );
      },
    );
  });
}

/// A child of one year this week: an age message and its visit are ahead.
PpMessageFacts child2() =>
    PpMessageFacts(dob: DateTime(2025, 11, 4), name: 'Meera', realChild: true);
