// =============================================================================
//  PP 11 (2026-10-29): Parenting messages share one cap with Pregnancy, a
//  morning tip per child in turn, and offers the Pregnancy way
// -----------------------------------------------------------------------------
//  docs/NOTIFICATIONS-PLAN.md, "As built: Parenting". The rules are pure
//  (`familyPhonePlan`, `ppDailyCandidates`), so most of this is plain values;
//  the store tests hold the wiring: both stores together, two a day.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/models/pv_product.dart';
import 'package:parentveda/screens/post_pregnancy/pp_daily_tips.dart'
    show ageTipOn;
import 'package:parentveda/screens/post_pregnancy/pp_phases_data.dart'
    show ppFillChildFor;
import 'package:parentveda/services/family_phone_plan.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/pp_message_offers.dart';
import 'package:parentveda/services/pp_messages_store.dart';
import 'package:parentveda/services/preg_message_offers.dart' show PregOffer;
import 'package:parentveda/services/preg_messages_store.dart';

class _PpPhone implements PpMessagePhone {
  final Map<int, (DateTime, String)> armed = {};
  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    armed[id] = (when, title);
  }

  @override
  Future<void> cancel(int id) async => armed.remove(id);
}

class _PregPhone implements PregMessagePhone {
  final Map<int, (DateTime, String)> armed = {};
  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    armed[id] = (when, title);
  }

  @override
  Future<void> cancel(int id) async => armed.remove(id);
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

const _toy = PpOffer(
  ref: 'product:t1',
  name: 'Stacking Cups',
  ageLabel: '6-12 months',
);
const _toy2 = PpOffer(
  ref: 'product:t2',
  name: 'Shape Sorter',
  ageLabel: '9-12 months',
);
const _class = PpOffer(
  ref: 'learn:c1',
  name: 'First Foods',
  ageLabel: '5 months to 9 months',
  isClass: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  // Monday 2 November 2026, 7 in the morning: nothing of today has rung yet.
  final now = DateTime(2026, 11, 2, 7);
  final meera = DateTime(2026, 5, 10);
  final aarav = DateTime(2023, 8, 14);

  PpMessageFacts kid(
    DateTime dob,
    String name, {
    int index = 0,
    int count = 1,
    DateTime? due,
    List<PpOffer> offers = const [],
    Set<String> offered = const {},
    Set<String> had = const {},
  }) => PpMessageFacts(
    dob: dob,
    name: name,
    realChild: true,
    named: count > 1,
    idPrefix: index == 0 ? '' : 'child:c$index|',
    childIndex: index,
    childCount: count,
    pregDueDate: due,
    offers: offers,
    offered: offered,
    hadActivity: had,
  );

  // Week 22, day 1 today.
  final due = _day(now).add(const Duration(days: 280 - 154));
  PregMessageFacts preg({
    bool withChildren = false,
    Map<int, List<PregOffer>> offers = const {},
  }) => PregMessageFacts(
    dueDate: due,
    dueDateSet: true,
    withChildren: withChildren,
    offersByWeek: offers,
  );

  group('A · one cap across both stores', () {
    test('Pregnancy on its own: the family plan is pregPhonePlan exactly', () {
      final pending = [
        for (final m in pregMessageCandidates(
          preg(
            offers: {
              22: const [
                PregOffer(
                  ref: 'product:p',
                  title: 'For this week: a pillow',
                  body: 'x',
                ),
              ],
              23: const [
                PregOffer(
                  ref: 'product:p',
                  title: 'For this week: a pillow',
                  body: 'x',
                ),
              ],
            },
          ),
          now,
        ))
          if (m.at.isAfter(now)) m,
      ];
      final old = pregPhonePlan(pending);
      final fam = familyPhonePlan(preg: pending);
      expect(fam.pp, isEmpty);
      expect(
        [for (final (id, m) in fam.preg) '$id ${m.id}'],
        [for (final (id, m) in old) '$id ${m.id}'],
      );
    });

    test(
      'the ranks: a vaccine beats the new week, an age beats the new week, the week beats a tip',
      () {
        final d = DateTime(2026, 11, 10);
        PpMessage pp(PpMessageKind k, int h, [int m = 0]) => PpMessage(
          id: '${k.name}$h',
          kind: k,
          at: d.add(Duration(hours: h, minutes: m)),
          title: k.name,
          body: '',
        );
        PregMessage pr(PregMessageKind k, int h, [int m = 0]) => PregMessage(
          id: '${k.name}$h',
          kind: k,
          at: d.add(Duration(hours: h, minutes: m)),
          title: k.name,
          body: '',
        );

        expect(
          familyPhonePlan(
            preg: [pr(PregMessageKind.newWeek, 9)],
            pp: [pp(PpMessageKind.vaccine, 10)],
          ).pp,
          hasLength(1),
        );
        expect(
          familyPhonePlan(
            preg: [pr(PregMessageKind.newWeek, 9)],
            pp: [pp(PpMessageKind.age, 9)],
          ).pp,
          hasLength(1),
        );
        expect(
          familyPhonePlan(
            preg: [pr(PregMessageKind.newWeek, 9)],
            pp: [pp(PpMessageKind.tip, 8, 30)],
          ).preg,
          hasLength(1),
        );
        // A Pregnancy dated moment and a vaccine visit are both 1: the earlier wins.
        final both = familyPhonePlan(
          preg: [pr(PregMessageKind.glucoseTest, 10)],
          pp: [pp(PpMessageKind.vaccine, 9)],
        );
        expect(both.pp, hasLength(1));
        expect(both.preg, isEmpty);
        // An offer gives way to the check-in, in the evening.
        final pm = familyPhonePlan(
          preg: [pr(PregMessageKind.checkIn, 19, 30)],
          pp: [pp(PpMessageKind.offer, 19)],
        );
        expect(pm.preg, hasLength(1));
        expect(pm.pp, isEmpty);
      },
    );

    test(
      'a tie between the stores: the toddler on odd days, Pregnancy on even ones',
      () {
        for (var i = 0; i < 4; i++) {
          final d = DateTime(2026, 11, 2 + i);
          final at = d.add(const Duration(hours: 8, minutes: 30));
          final plan = familyPhonePlan(
            preg: [
              PregMessage(
                id: 'day',
                kind: PregMessageKind.dayLine,
                at: at,
                title: '',
                body: '',
              ),
            ],
            pp: [
              PpMessage(
                id: 'tip',
                kind: PpMessageKind.tip,
                at: at,
                title: '',
                body: '',
              ),
            ],
          );
          expect(plan.pp.length, ppDayNumber(d).isOdd ? 1 : 0, reason: '$d');
          expect(plan.preg.length, ppDayNumber(d).isOdd ? 0 : 1, reason: '$d');
        }
      },
    );

    test('a tie between two children: the one whose week it is', () {
      final d = DateTime(2026, 11, 4);
      final at = d.add(const Duration(hours: 9));
      final plan = familyPhonePlan(
        pp: [
          PpMessage(
            id: 'age:m6',
            kind: PpMessageKind.age,
            at: at,
            title: 'a',
            body: '',
          ),
          PpMessage(
            id: 'child:b|age:m40',
            kind: PpMessageKind.age,
            at: at,
            title: 'b',
            body: '',
          ),
        ],
        childIds: const ['a', 'b'],
      );
      final turn = ppWeekNumber(d) % 2;
      expect(plan.pp.single.$2.title, turn == 0 ? 'a' : 'b');
    });

    test(
      'pregnant again with a toddler: two a day across both, a loser still in Messages',
      () {
        final toddler = DateTime(2025, 5, 21);
        final f = kid(toddler, 'Aarav', due: due);
        final ppAll = ppMessageCandidates(
          f,
          now,
        ).where((m) => m.at.isAfter(now)).toList();
        final pregAll = pregMessageCandidates(
          preg(withChildren: true),
          now,
        ).where((m) => m.at.isAfter(now)).toList();
        final plan = familyPhonePlan(preg: pregAll, pp: ppAll);
        final rang = [
          for (final (_, m) in plan.preg) m.at,
          for (final (_, m) in plan.pp) m.at,
        ];
        final perDay = <DateTime, List<DateTime>>{};
        for (final at in rang) {
          perDay.putIfAbsent(_day(at), () => []).add(at);
        }
        for (final e in perDay.entries) {
          expect(
            e.value.where((t) => t.hour < 14).length,
            lessThanOrEqualTo(1),
            reason: '${e.key}',
          );
          expect(
            e.value.where((t) => t.hour >= 14).length,
            lessThanOrEqualTo(1),
            reason: '${e.key}',
          );
        }
        // Every candidate is still there to be delivered to Messages: the plan
        // only says which ring.
        expect(ppAll.length + pregAll.length, greaterThan(rang.length));
        // The toddler's tip only on odd days, and it wins its morning.
        for (final m in ppAll.where((m) => m.kind == PpMessageKind.tip)) {
          expect(ppDayNumber(m.at).isOdd, isTrue);
          final morning = [
            for (final (_, x) in plan.pp)
              if (_day(x.at) == _day(m.at) && x.at.hour < 14) x,
          ];
          final pregMorning = [
            for (final (_, x) in plan.preg)
              if (_day(x.at) == _day(m.at) && x.at.hour < 14) x,
          ];
          if (pregMorning.isNotEmpty) {
            expect(
              pregFamilyRank(pregMorning.single.kind),
              lessThan(4.5),
              reason: 'only a better rank beats the tip',
            );
          } else {
            expect(morning, isNotEmpty);
          }
        }
      },
    );

    test('Parenting phone ids stay in its own block, unique', () {
      final ids = [for (final k in PpMessageKind.values) ...k.phoneIds];
      expect(ids.toSet().length, ids.length);
      expect(ids.every((i) => i >= 929101 && i < 929200), isTrue);
    });
  });

  group('B · the morning tip', () {
    test('one child: every morning at 8:30, "Today\'s tip: <title>"', () {
      final tips = ppDailyCandidates(
        kid(meera, 'Meera'),
        now,
      ).where((m) => m.kind == PpMessageKind.tip).toList();
      expect(tips, hasLength(kPpDailyDays));
      for (final t in tips) {
        expect(t.at.hour, 8);
        expect(t.at.minute, 30);
        expect(t.title, startsWith("Today's tip: "));
      }
    });

    test('two children: one a day, in turn, each title names the child', () {
      final a = ppDailyCandidates(
        kid(meera, 'Meera', index: 0, count: 2),
        now,
      ).where((m) => m.kind == PpMessageKind.tip).toList();
      final b = ppDailyCandidates(
        kid(aarav, 'Aarav', index: 1, count: 2),
        now,
      ).where((m) => m.kind == PpMessageKind.tip).toList();
      expect(a.length + b.length, kPpDailyDays);
      expect(
        {
          for (final m in a) _day(m.at),
        }.intersection({for (final m in b) _day(m.at)}),
        isEmpty,
      );
      expect(a.first.title, startsWith("Today's tip for Meera: "));
      expect(b.first.title, startsWith("Today's tip for Aarav: "));
    });

    test(
      'the tip is the home\'s pick for that child and day, by corrected age',
      () {
        final early = PpMessageFacts(
          dob: meera,
          name: 'Meera',
          realChild: true,
          correctionWeeks: 8,
        );
        final t = ppDailyCandidates(
          early,
          now,
        ).firstWhere((m) => m.kind == PpMessageKind.tip);
        expect(t.title, contains(_titleOf(meera, 8, t.at)));
      },
    );

    test('no tip on a morning that child\'s activity speaks', () {
      final ms = ppMessageCandidates(kid(meera, 'Meera'), now);
      final acts = {
        for (final m in ms.where((m) => m.kind == PpMessageKind.activity))
          _day(m.at),
      };
      expect(acts, isNotEmpty);
      final tips = {
        for (final m in ms.where((m) => m.kind == PpMessageKind.tip))
          _day(m.at),
      };
      expect(acts.intersection(tips), isEmpty);
    });

    test('pregnant again: every other day', () {
      final tips = ppDailyCandidates(
        kid(meera, 'Meera', due: due),
        now,
      ).where((m) => m.kind == PpMessageKind.tip);
      expect(tips.length, kPpDailyDays ~/ 2);
      expect(tips.every((m) => ppDayNumber(m.at).isOdd), isTrue);
    });

    test('no check-in for Parenting', () {
      expect(
        PpMessageKind.values.map((k) => k.name),
        isNot(contains('checkIn')),
      );
    });
  });

  group('the two fixes', () {
    test('an activity is not sent again the week after', () {
      final acts =
          ppMessageCandidates(
              kid(meera, 'Meera'),
              now,
            ).where((m) => m.kind == PpMessageKind.activity).toList()
            ..sort((a, b) => a.at.compareTo(b.at));
      for (var i = 1; i < acts.length; i++) {
        final gap = acts[i].at.difference(acts[i - 1].at).inDays;
        if (gap <= 7) expect(acts[i].body, isNot(acts[i - 1].body));
      }
    });

    test('nor one she had in the last 7 days', () {
      final first = ppMessageCandidates(
        kid(meera, 'Meera'),
        now,
      ).firstWhere((m) => m.kind == PpMessageKind.activity);
      final again = ppMessageCandidates(
        kid(meera, 'Meera', had: {first.body}),
        now,
      ).where((m) => m.kind == PpMessageKind.activity);
      expect(again.map((m) => m.body), isNot(contains(first.body)));
    });

    test('no doubled title in any activity, at any age to six', () {
      final doubled = RegExp(r'^(.{6,}?): \1', caseSensitive: false);
      for (var m = 0; m <= 72; m++) {
        final dob = DateTime(now.year, now.month - m, now.day);
        for (final a in ppMessageCandidates(
          kid(dob, 'Meera'),
          now,
        ).where((x) => x.kind == PpMessageKind.activity)) {
          expect(
            doubled.hasMatch(a.body),
            isFalse,
            reason: '$m months: ${a.body}',
          );
        }
      }
    });
  });

  group('C · offers', () {
    test(
      'Wednesday and Saturday at 7 pm, "For this age: <toy>", with its age',
      () {
        final offers = ppDailyCandidates(
          kid(meera, 'Meera', offers: const [_toy, _toy2, _class]),
          now,
        ).where((m) => m.kind == PpMessageKind.offer).toList();
        expect(
          offers,
          hasLength(3),
          reason: 'two weeks: four days, three things to offer',
        );
        for (final m in offers) {
          expect([
            DateTime.wednesday,
            DateTime.saturday,
          ], contains(m.at.weekday));
          expect(m.at.hour, 19);
        }
        expect(offers.first.title, 'For this age: Stacking Cups');
        expect(
          offers.first.body,
          'Made for 6-12 months. See what parents pick, in the Store.',
        );
        expect(offers.first.ref, 'product:t1');
        expect(
          offers.last.body,
          'Made for 5 months to 9 months. See what it covers, in Learn.',
        );
      },
    );

    test('silent when nothing exists, and never twice the same thing', () {
      expect(
        ppDailyCandidates(
          kid(meera, 'Meera'),
          now,
        ).where((m) => m.kind == PpMessageKind.offer),
        isEmpty,
      );
      final seen = ppDailyCandidates(
        kid(
          meera,
          'Meera',
          offers: const [_toy, _toy2],
          offered: {'product:t1'},
        ),
        now,
      ).where((m) => m.kind == PpMessageKind.offer);
      expect(seen.map((m) => m.ref), ['product:t2']);
    });

    test('two children take turns, "For Meera now: <toy>"', () {
      final a = ppDailyCandidates(
        kid(meera, 'Meera', count: 2, offers: const [_toy, _toy2]),
        now,
      ).where((m) => m.kind == PpMessageKind.offer).toList();
      final b = ppDailyCandidates(
        kid(aarav, 'Aarav', index: 1, count: 2, offers: const [_toy, _toy2]),
        now,
      ).where((m) => m.kind == PpMessageKind.offer).toList();
      expect(a, hasLength(2));
      expect(b, hasLength(2));
      expect(
        {
          for (final m in a) _day(m.at),
        }.intersection({for (final m in b) _day(m.at)}),
        isEmpty,
      );
      expect(a.first.title, 'For Meera now: Stacking Cups');
    });

    test(
      'pregnant again: the stores take turns, Pregnancy day 3, the child day 6',
      () {
        const po = PregOffer(
          ref: 'product:p',
          title: 'For this week: a pillow',
          body: 'x',
        );
        final pregOffers = pregDailyCandidates(
          preg(
            withChildren: true,
            offers: {
              22: [po],
              23: [po],
            },
          ),
          now,
        ).where((m) => m.kind == PregMessageKind.offer);
        for (final m in pregOffers) {
          expect(
            _day(m.at).difference(pregWeekStart(due, m.week!)).inDays + 1,
            3,
          );
        }
        final kidOffers = ppDailyCandidates(
          kid(meera, 'Meera', due: due, offers: const [_toy, _toy2]),
          now,
        ).where((m) => m.kind == PpMessageKind.offer);
        expect(kidOffers, isNotEmpty);
        for (final m in kidOffers) {
          final w = pregWeekOn(due, m.at);
          expect(_day(m.at).difference(pregWeekStart(due, w)).inDays + 1, 6);
        }
        // On her own, as before: day 3 and day 6.
        final alone = pregDailyCandidates(
          preg(
            offers: {
              22: [po],
              23: [po],
            },
          ),
          now,
        ).where((m) => m.kind == PregMessageKind.offer);
        expect(alone.length, greaterThan(pregOffers.length));
      },
    );

    test('only a toy with a real age window: 0 to 72 is "no window"', () {
      PvProduct toy(int lo, int hi) => PvProduct(
        id: 'x',
        stage: LifeStage.parenting,
        categoryId: 'play_and_development',
        name: 'x',
        brand: 'b',
        priceNote: '',
        ageMinMonths: lo,
        ageMaxMonths: hi,
      );
      expect(ppToyHasAgeWindow(toy(0, 72)), isFalse);
      expect(ppToyHasAgeWindow(toy(0, 3)), isTrue);
      expect(ppToyHasAgeWindow(toy(48, 60)), isTrue);
    });

    test(
      'off until she says yes; both answers kept, locally and in the cloud row',
      () async {
        SharedPreferences.setMockInitialValues({});
        final s = PpMessagesStore.instance..resetForTest();
        s.phone = _PpPhone();
        expect(s.isOn(PpMessageKind.offer), isFalse);
        expect(s.offersAsked, isFalse);
        await s.answerOffers(true);
        expect(s.isOn(PpMessageKind.offer), isTrue);
        expect(s.cloudItems()['offers'], isTrue);
        expect(s.cloudItems()['offersAsked'], isTrue);
        final p = await SharedPreferences.getInstance();
        expect(p.getBool('pp_messages_offers'), isTrue);
        s.applyCloudItems({
          'offers': false,
          'offersAsked': true,
          'phone': true,
        });
        expect(s.isOn(PpMessageKind.offer), isFalse);
        expect(s.offersAsked, isTrue);
        await s.setOn(PpMessageKind.offer, true);
        expect(s.isOn(PpMessageKind.offer), isTrue);
      },
    );

    test('the tip is on by default, whatever topics she chose', () {
      final s = PpMessagesStore.instance..resetForTest();
      expect(s.isOn(PpMessageKind.tip), isTrue);
    });
  });

  group('wiring', () {
    test(
      'both stores arm through the one owner, and the phone rings two a day at most',
      () async {
        SharedPreferences.setMockInitialValues({});
        final pp = PpMessagesStore.instance..resetForTest();
        final pr = PregMessagesStore.instance..resetForTest();
        final ppPhone = _PpPhone(), prPhone = _PregPhone();
        pp.phone = ppPhone;
        pr.phone = prPhone;
        await pr.refresh(now: now, facts: preg(withChildren: true));
        await pp.refresh(
          now: now,
          facts: kid(DateTime(2025, 5, 21), 'Aarav', due: due),
        );
        final all = [...ppPhone.armed.values, ...prPhone.armed.values];
        expect(ppPhone.armed, isNotEmpty);
        expect(prPhone.armed, isNotEmpty);
        final perDay = <DateTime, int>{};
        for (final (at, _) in all) {
          perDay[_day(at)] = (perDay[_day(at)] ?? 0) + 1;
        }
        expect(perDay.values.every((n) => n <= 2), isTrue, reason: '$perDay');
        // The losers are still pending, so they are delivered to Messages.
        expect(
          pp.pending(now: now).length + pr.pending(now: now).length,
          greaterThan(all.length),
        );
      },
    );

    test(
      'the call sites: each store hands arming to FamilyPhone; the screen has the offers card',
      () {
        expect(
          _code('lib/services/pp_messages_store.dart'),
          contains('FamilyPhone.instance.rearm('),
        );
        expect(
          _code('lib/services/preg_messages_store.dart'),
          contains('FamilyPhone.instance.rearm('),
        );
        final screen = _code(
          'lib/screens/post_pregnancy/pp_messages_screen.dart',
        );
        expect(screen, contains('_OffersCard(p: p)'));
        expect(screen, contains('answerOffers(true)'));
        expect(screen, contains('answerOffers(false)'));
        expect(screen, contains('case PpMessageKind.offer:'));
        expect(screen, contains('case PpMessageKind.tip:'));
      },
    );
  });
}

/// The title of the home's tip for a child born on [dob], [corr] weeks early,
/// as the message words it (pronouns filled for a girl named Meera).
String _titleOf(DateTime dob, int corr, DateTime on) {
  final days = _day(on).difference(dob).inDays;
  final t = ageTipOn(on, days ~/ 7 - corr).tip.title;
  return ppFillChildFor(t, sexGiven: true, isBoy: true, name: 'Meera');
}
