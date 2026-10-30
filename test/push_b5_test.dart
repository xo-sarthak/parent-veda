// Phase 6b, B5 (2026-10-30): the phone gives a booked evening to the campaign,
// shows tonight's campaign in Messages, shows a push that arrives while the
// app is open, creates "Offers and news", and records a tap.
// docs/NOTIFICATIONS-6B-PLAN.md, "As built: B5".
//
// The planner rule this file holds: A BOOKED EVENING NEVER RINGS TWO. On an
// evening the server booked a campaign for, nothing the two-a-day cap governs
// rings; what the cap never governed (a TTC treatment message, a child's
// moment with no pregnancy) still does, because an offer never silences care.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/family_phone_plan.dart';
import 'package:parentveda/services/pp_messages_store.dart';
import 'package:parentveda/services/preg_messages_store.dart';
import 'package:parentveda/services/push_audience.dart';
import 'package:parentveda/services/push_bookings.dart';
import 'package:parentveda/services/push_service.dart';
import 'package:parentveda/services/push_wire.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';
import 'package:parentveda/widgets/pv_campaign_tonight.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

const _migration = 'supabase/migrations/0146_push_channel_and_tap.sql';

/// The newest migration that (re)defines [fn]: the one the database runs.
String _latestDefining(String fn) {
  final files = Directory('supabase/migrations')
      .listSync()
      .whereType<File>()
      .map((f) => f.path.replaceAll('\\', '/'))
      .where((p) => p.endsWith('.sql'))
      .toList()
    ..sort();
  String? last;
  for (final p in files) {
    if (_read(p).contains('create or replace function public.$fn(')) last = p;
  }
  return last!;
}

/// The body of `create or replace function public.<fn>(` up to its `$$;`.
String _fnBody(String src, String fn) {
  final start = src.indexOf('create or replace function public.$fn(');
  expect(start, greaterThanOrEqualTo(0), reason: '$fn is defined');
  final end = src.indexOf('\$\$;', src.indexOf('\$\$', start) + 2);
  return src.substring(start, end);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A day with a booking, and the day after with none.
  final booked = DateTime(2026, 11, 10);
  final free = DateTime(2026, 11, 11);
  final bookedSet = {booked};

  PregMessage pr(PregMessageKind k, DateTime d, int h, [int m = 0]) =>
      PregMessage(
        id: '${k.name}${d.day}$h',
        kind: k,
        at: d.add(Duration(hours: h, minutes: m)),
        title: k.name,
        body: '',
      );
  PpMessage pp(PpMessageKind k, DateTime d, int h, [int m = 0]) => PpMessage(
    id: '${k.name}${d.day}$h',
    kind: k,
    at: d.add(Duration(hours: h, minutes: m)),
    title: k.name,
    body: '',
  );
  TtcMessage ttc(TtcMessageKind k, DateTime d, int h, [int m = 0]) =>
      TtcMessage(
        id: '${k.name}${d.day}$h',
        kind: k,
        at: d.add(Duration(hours: h, minutes: m)),
        title: k.name,
        body: '',
      );

  bool evening(DateTime at) => at.hour >= kPregEveningFromHour;
  bool on(DateTime at, DateTime day) =>
      at.year == day.year && at.month == day.month && at.day == day.day;

  group('the planners: a booked evening never rings two', () {
    test('Pregnancy (and a child with her): the evening goes to Messages', () {
      final preg = [
        pr(PregMessageKind.dayLine, booked, 8, 30),
        pr(PregMessageKind.offer, booked, 19),
        pr(PregMessageKind.checkIn, booked, 19, 30),
        pr(PregMessageKind.dayLine, free, 8, 30),
        pr(PregMessageKind.checkIn, free, 19, 30),
      ];
      final kids = [pp(PpMessageKind.tip, booked, 17)];
      final plan = familyPhonePlan(
          preg: preg, pp: kids, bookedEvenings: bookedSet);
      final rings = [
        for (final (_, m) in plan.preg) m.at,
        for (final (_, m) in plan.pp) m.at,
      ];
      expect(rings.where((t) => on(t, booked) && evening(t)), isEmpty,
          reason: 'the campaign is that evening\'s one');
      expect(rings.where((t) => on(t, booked) && !evening(t)), hasLength(1),
          reason: 'the morning is untouched');
      expect(rings.where((t) => on(t, free) && evening(t)), hasLength(1),
          reason: 'an evening with no booking rings as before');
    });

    test('with no booking the plan is exactly what it was', () {
      final preg = [
        pr(PregMessageKind.dayLine, booked, 8, 30),
        pr(PregMessageKind.checkIn, booked, 19, 30),
      ];
      final before = familyPhonePlan(preg: preg);
      final after = familyPhonePlan(preg: preg, bookedEvenings: const {});
      expect([for (final (i, m) in after.preg) '$i ${m.id}'],
          [for (final (i, m) in before.preg) '$i ${m.id}']);
    });

    test('a moment still rings on a booked evening: an offer never silences care',
        () {
      final plan = familyPhonePlan(
        preg: [pr(PregMessageKind.tdap, booked, 20)],
        bookedEvenings: bookedSet,
      );
      expect(plan.preg, hasLength(1));
    });

    test('Parenting alone: dailies give way, moments ring clear of 19:00', () {
      final plan = parentingPhonePlan(
        pp: [
          pp(PpMessageKind.offer, booked, 19),
          pp(PpMessageKind.tip, booked, 18),
          pp(PpMessageKind.vaccine, booked, 19),
          pp(PpMessageKind.tip, booked, 8, 30),
        ],
        bookedEvenings: bookedSet,
        now: booked,
      );
      final kinds = [for (final (_, m) in plan) m.kind];
      expect(kinds, isNot(contains(PpMessageKind.offer)));
      expect(kinds.where((k) => k == PpMessageKind.tip), hasLength(1),
          reason: 'the morning tip stays; the evening one gives way');
      final vaccine =
          plan.firstWhere((e) => e.$2.kind == PpMessageKind.vaccine).$2.at;
      final campaign = DateTime(booked.year, booked.month, booked.day, kPushCampaignHour);
      expect(vaccine.difference(campaign).abs() >= kFamilyRingGap, isTrue,
          reason: 'the moment rings, but not on top of the campaign');
    });

    test('TTC: the capped evening gives way, a treatment message still rings',
        () {
      final plan = ttcPhonePlan([
        ttc(TtcMessageKind.dayLine, booked, 8, 30),
        ttc(TtcMessageKind.checkIn, booked, 19, 30),
        ttc(TtcMessageKind.treatment, booked, 20),
        ttc(TtcMessageKind.checkIn, free, 19, 30),
      ], bookedEvenings: bookedSet);
      final got = [for (final (_, m) in plan) '${m.kind.name}@${m.at.day}'];
      expect(got, containsAll(['dayLine@10', 'treatment@10', 'checkIn@11']));
      expect(got, isNot(contains('checkIn@10')));
    });
  });

  group('the busy-evenings upload, once a campaign takes an evening', () {
    test('the booked evening drops out; the other evenings are unchanged', () {
      final preg = [
        pr(PregMessageKind.checkIn, booked, 19, 30),
        pr(PregMessageKind.checkIn, free, 19, 30),
      ];
      final plan = familyPhonePlan(preg: preg, bookedEvenings: bookedSet);
      final busy = pushBusyEvenings([for (final (_, m) in plan.preg) m.at],
          booked.add(const Duration(hours: 9)));
      expect(busy, [free],
          reason: 'nothing of the phone\'s own rings that evening; the '
              'server holds it with the one-an-evening index, not this list');
    });

    test('FamilyPhone tells the server what it armed, after the bookings', () {
      final src = _read('lib/services/family_phone_plan.dart');
      expect(src, contains('PushBookings.instance.bookedEvenings(now: now)'));
      expect('bookedEvenings: booked,'.allMatches(src).length, 2,
          reason: 'both branches: the capped plan and Parenting alone');
      expect(src, contains('_tellServer(now, [\n        for (final (_, m) in plan.preg) m.at,'));
    });
  });

  group('bookings', () {
    test('only queued and sent hold an evening, and only from today', () {
      PushBooking b(String s, DateTime d) =>
          PushBooking(rowId: '$s${d.day}', day: d, status: s);
      final got = pushBookedEvenings([
        b('queued', booked),
        b('sent', free),
        b('skipped', DateTime(2026, 11, 12)),
        b('failed', DateTime(2026, 11, 13)),
        b('queued', DateTime(2026, 11, 9)),
      ], booked.add(const Duration(hours: 9)));
      expect(got, {booked, free});
    });

    test('a row reads with the campaign embedded as a map or a list', () {
      final r1 = PushBooking.fromRow({
        'id': 'r1',
        'send_on': '2026-11-10',
        'status': 'queued',
        'push_campaigns': {
          'title': 'A calm class',
          'body': 'Tap to see it.',
          'link_kind': 'course',
          'link_id': 'c1',
        },
      })!;
      expect(r1.day, booked);
      expect(r1.showable, isTrue);
      expect(r1.link?.kind, 'course');
      final r2 = PushBooking.fromRow({
        'id': 'r2',
        'send_on': '2026-11-10',
        'status': 'sent',
        'push_campaigns': [
          {'title': 'T', 'body': 'B', 'link_kind': 'read', 'link_id': 'x'},
        ],
      })!;
      expect(r2.title, 'T');
      final hidden = PushBooking.fromRow(
          {'id': 'r3', 'send_on': '2026-11-10', 'status': 'queued'})!;
      expect(hidden.showable, isFalse,
          reason: 'a campaign RLS hides still holds the evening, shows nothing');
      expect(hidden.link, isNull);
      expect(PushBooking.fromRow({'id': 'r4'}), isNull);
    });

    test('refresh: reads, caches, re-arms once; a failure keeps the cache',
        () async {
      SharedPreferences.setMockInitialValues({});
      final store = PushBookings.instance..debugReset();
      final oldUser = PushWire.userId;
      final oldFetch = PushWire.bookings;
      final oldRearm = PushBookings.rearm;
      var rearms = 0;
      String? askedFrom;
      PushWire.userId = () => 'u1';
      PushBookings.rearm = () async => rearms++;
      PushWire.bookings = (from) async {
        askedFrom = from;
        return [
          {
            'id': 'r1',
            'send_on': '2026-11-10',
            'status': 'queued',
            'push_campaigns': {'title': 'T', 'body': 'B', 'link_kind': 'read', 'link_id': 'x'},
          },
        ];
      };
      addTearDown(() {
        PushWire.userId = oldUser;
        PushWire.bookings = oldFetch;
        PushBookings.rearm = oldRearm;
        store.debugReset();
      });

      final now = booked.add(const Duration(hours: 9));
      await store.refresh(now: now);
      expect(askedFrom, '2026-11-10');
      expect(store.bookedEvenings(now: now), {booked});
      expect(rearms, 1);
      final cached = jsonDecode(
          (await SharedPreferences.getInstance()).getString(PushBookings.prefsKey)!);
      expect(cached['user'], 'u1');

      await store.refresh(now: now);
      expect(rearms, 1, reason: 'nothing changed, nothing re-armed');

      PushWire.bookings = (_) async => throw Exception('offline');
      await store.refresh(now: now);
      expect(store.bookedEvenings(now: now), {booked},
          reason: 'a cloud failure keeps what is cached');

      PushWire.userId = () => null;
      PushWire.bookings = (_) async => fail('no read while signed out');
      await store.refresh(now: now);
    });

    test('Messages shows the campaign from 19:00 or once sent, on its day only',
        () {
      final q = PushBooking(rowId: 'r', day: booked, status: 'queued', title: 'T');
      expect(pvCampaignShowsNow(q, booked.add(const Duration(hours: 18, minutes: 59))), isFalse);
      expect(pvCampaignShowsNow(q, booked.add(const Duration(hours: 19))), isTrue);
      final s = PushBooking(rowId: 'r', day: booked, status: 'sent', title: 'T');
      expect(pvCampaignShowsNow(s, booked.add(const Duration(hours: 12))), isTrue);

      final store = PushBookings.instance..debugSet([q]);
      addTearDown(store.debugReset);
      expect(store.tonight(now: booked.add(const Duration(hours: 20)))?.rowId, 'r');
      expect(store.tonight(now: free.add(const Duration(hours: 20))), isNull);
    });
  });

  group('the tap', () {
    late List<(String, Map<String, dynamic>)> calls;
    late Future<dynamic> Function(String, Map<String, dynamic>) oldCall;
    late String? Function() oldUser;

    setUp(() {
      calls = [];
      oldCall = PushWire.call;
      oldUser = PushWire.userId;
      PushWire.call = (fn, params) async {
        calls.add((fn, params));
        return true;
      };
      PushWire.userId = () => 'u1';
    });
    tearDown(() {
      PushWire.call = oldCall;
      PushWire.userId = oldUser;
    });

    test('a campaign tap calls pv_push_tapped with its row id', () {
      expect(PushService.recordTap({'queue': 'push_sends', 'row_id': 'r1'}), isTrue);
      expect(calls.single.$1, 'pv_push_tapped');
      expect(calls.single.$2, {'p_row_id': 'r1'});
    });

    test('a test tap, a stage message and a signed-out phone record nothing', () {
      expect(PushService.recordTap({'queue': 'push_tests', 'row_id': 'r1'}), isFalse);
      expect(PushService.recordTap({'link_kind': 'preg_message', 'link_id': 'x'}), isFalse);
      expect(PushService.recordTap({'queue': 'push_sends', 'row_id': ''}), isFalse);
      PushWire.userId = () => null;
      expect(PushService.recordTap({'queue': 'push_sends', 'row_id': 'r1'}), isFalse);
      expect(calls, isEmpty);
    });

    test('a foreground push carries the push data as its payload, so its tap records too',
        () {
      PushService.recordTapPayload(
          jsonEncode({'queue': 'push_sends', 'row_id': 'r9', 'link_kind': 'read', 'link_id': 'x'}));
      PushService.recordTapPayload('not json');
      PushService.recordTapPayload(jsonEncode({'link_kind': 'ttc_message', 'link_id': 'w'}));
      expect(calls.map((c) => c.$2['p_row_id']), ['r9']);
    });

    test('a background tap records, then opens', () {
      final src = _read('lib/services/push_service.dart');
      final handle = src.substring(src.indexOf('static void handleTap('));
      expect(handle.indexOf('recordTap(data);'),
          lessThan(handle.indexOf('NotificationService.instance.openLink(link);')));
    });
  });

  group('the foreground push and the channel', () {
    test('the id is stable, in its own band, and the same push replaces itself', () {
      final a = PushService.foregroundIdOffset('row-1');
      expect(a, PushService.foregroundIdOffset('row-1'));
      for (final t in ['', 'x', 'a much longer tag than the others, to wrap']) {
        final o = PushService.foregroundIdOffset(t);
        expect(o, inInclusiveRange(0, 999));
      }
      expect(PushService.foregroundIdBase, 939000,
          reason: 'clear of the stage blocks (9191xx, 9291xx) and the diagnostics');
    });

    test('the channel id is one value on both sides', () {
      expect(PushService.offersChannel, 'offers_news');
      expect(PushService.offersChannelName, 'Offers and news');
      final live = _latestDefining('pv_push_due');
      final due = _fnBody(_read(live), 'pv_push_due');
      expect("'offers_news'::text".allMatches(due).length,
          greaterThanOrEqualTo(2),
          reason: '$live: push_sends and push_tests both on the channel; a '
              'later branch copied from 0144 would put it back to null');
    });

    test('wired: channel first, then taps, the foreground, the bookings', () {
      final src = _read('lib/services/push_service.dart');
      final init = src.substring(src.indexOf('Future<void> init() async'),
          src.indexOf('Future<void> onSignedIn()'));
      final order = [
        'createChannel(',
        'onPayloadTapped = recordTapPayload',
        'listenForTaps(handleTap)',
        'listenForeground(showForeground)',
        'PushBookings.instance.init()',
      ].map(init.indexOf).toList();
      expect(order.every((i) => i >= 0), isTrue, reason: '$order');
      expect([...order]..sort(), order);
      expect(src, contains('FirebaseMessaging.onMessage.listen('));
      expect(src, contains('if (_ready) unawaited(PushBookings.instance.refresh());'));
      final ns = _read('lib/services/notification_service.dart');
      expect(ns, contains('onPayloadTapped?.call(payload);'));
      expect(ns, contains('createNotificationChannel(AndroidNotificationChannel('));
    });

    test('Messages: every stage draws tonight\'s campaign', () {
      for (final f in [
        'lib/screens/pregnancy/preg_messages_screen.dart',
        'lib/screens/post_pregnancy/pp_messages_screen.dart',
        'lib/screens/ttc/ttc_messages_screen.dart',
      ]) {
        expect(_read(f), contains('PvCampaignTonight('), reason: f);
      }
      expect(_read('lib/ttc/ttc_messages_store.dart'),
          contains('bookedEvenings: PushBookings.instance.bookedEvenings(now: now)'));
    });
  });

  group('contract: 0146 and the phone agree', () {
    final sql = _read(_migration);

    test('pv_push_tapped takes exactly the keys the phone sends', () {
      final sig = RegExp(r'create or replace function public\.pv_push_tapped\(([^)]*)\)')
          .firstMatch(sql)!
          .group(1)!;
      final names = [
        for (final p in sig.split(',')) p.trim().split(RegExp(r'\s+')).first,
      ];
      expect(names, PushWire.tappedParams('x').keys.toList());
      expect(PushWire.tapped, 'pv_push_tapped');
    });

    test('her own row, once, no status check, the app may call it, anon may not', () {
      final body = _fnBody(sql, 'pv_push_tapped');
      expect(body, contains('s.user_id = v_uid'));
      expect(body, contains('s.tapped_at is null'));
      expect(body, contains('security definer'));
      expect(body, isNot(contains('status')));
      expect(sql, contains('revoke all on function public.pv_push_tapped(uuid) from public, anon;'));
      expect(sql, contains('grant execute on function public.pv_push_tapped(uuid) to authenticated;'));
      expect(sql, contains('revoke all on function public.pv_push_due(int) from public, anon, authenticated;'));
    });

    test('the bookings read names real columns, and holds the agreed statuses', () {
      final t = _read('supabase/migrations/0143_push_campaigns_and_sends.sql');
      for (final c in ['id', 'send_on', 'status']) {
        expect(RegExp('^  $c\\s', multiLine: true).hasMatch(t), isTrue, reason: c);
      }
      for (final c in ['kind', 'title', 'body', 'link_kind', 'link_id']) {
        expect(t, contains('  $c '), reason: c);
      }
      expect(PushWire.bookingsSelect,
          'id, send_on, status, push_campaigns(kind, title, body, link_kind, link_id)');
      expect(PushWire.bookingsTable, 'push_sends');
      expect(PushWire.bookingsHolding, ['queued', 'sent']);
      expect(t, contains('create policy push_sends_own_select'));
      expect(t, contains('create policy push_campaigns_booked_select'));
    });

    test('the bookings cache forgets the person on sign-out', () {
      final src = _read('lib/services/push_bookings.dart');
      expect(src, contains('SyncRegistry.registerReset(_forget)'));
      expect(src, contains("j['user'] != uid"));
    });
  });
}
