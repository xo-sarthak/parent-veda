// =============================================================================
//  Credits truth -- 0135 (docs/LEARNING-ARCHITECTURE.md §5, LA-35..LA-45)
// -----------------------------------------------------------------------------
//  A credit or a seat is spent once, returned once, never paid back twice, and
//  the phone is told what really happened.
//
//  The SQL half reads the LAST definition of each function across the whole
//  migration set, as test/learning_security_contract_test.dart does: a rule
//  pinned to one file keeps passing after a later `create or replace` has
//  dropped it (LA-2). Comment lines are stripped first, so a rule that
//  survives only as a comment does not count.
//
//  The app half drives BookingStore signed out, where the window is decided
//  on the phone exactly as the server decides it.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/booking/booking_store.dart';

List<File> _migrations() => Directory('supabase/migrations')
    .listSync()
    .whereType<File>()
    .where((f) => f.path.endsWith('.sql'))
    .toList()
  ..sort((a, b) => a.path.compareTo(b.path));

String _code(String sql) =>
    sql.split('\n').where((l) => !l.trimLeft().startsWith('--')).join('\n');

String _all() => _migrations().map((f) => _code(f.readAsStringSync())).join('\n');

({String file, String body}) _last(String name) {
  final head = 'create or replace function public.$name(';
  String? file;
  String? body;
  for (final f in _migrations()) {
    final code = _code(f.readAsStringSync());
    final at = code.lastIndexOf(head);
    if (at < 0) continue;
    final open = code.indexOf(r'$$', at);
    final close = code.indexOf(r'$$', open + 2);
    file = f.uri.pathSegments.last;
    body = code.substring(at, close);
  }
  if (body == null) fail('no definition of public.$name in supabase/migrations');
  return (file: file!, body: body);
}

String _src(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  group('LA-35 · a cancel says whether the credit came back', () {
    final d = _last('cancel_booking');

    test('returns the outcome, not void', () {
      expect(d.body, contains('returns jsonb'), reason: d.file);
      expect(d.body, contains("'credit_returned'"));
      expect(d.body, contains("'late_cancel'"));
    });

    test('the window is the policy row, and a late cancel keeps the credit', () {
      expect(d.body, contains('from public.booking_policy'));
      final free = d.body.indexOf('set booking_id = null, spent_at = null');
      final late = d.body.indexOf('if v_late then');
      expect(late, greaterThan(0));
      expect(free, greaterThan(late),
          reason: 'the credit is freed only on the in-time branch');
    });

    test('the window is readable by the app', () {
      expect(_last('booking_terms').body, contains('credit_return_hours'));
      expect(_all(),
          contains('grant execute on function public.booking_terms() to authenticated'));
    });
  });

  group('LA-36 · only an upcoming booking can be cancelled', () {
    test('cancel_booking guards on the status', () {
      final d = _last('cancel_booking');
      final guard = d.body.indexOf("if v_booking.status <> 'upcoming' then");
      final write = d.body.indexOf('update public.booking_bookings');
      expect(guard, greaterThan(0));
      expect(write, greaterThan(guard));
    });

    test('expert_cancel_booking guards on the status too', () {
      final d = _last('expert_cancel_booking');
      final guard = d.body.indexOf("if v_booking.status <> 'upcoming' then");
      final write = d.body.indexOf('update public.booking_bookings');
      expect(guard, greaterThan(0), reason: d.file);
      expect(write, greaterThan(guard));
      expect(d.body, contains("'expert_cancelled'"));
      expect(d.body, contains("return 'too_early'"));
    });
  });

  group('LA-37 · a move is one transaction, refused inside the window', () {
    final d = _last('reschedule_booking');

    test('refused inside the window', () {
      expect(d.body, contains("'inside_window'"));
    });

    test('release and claim share one savepoint', () {
      final begin = d.body.indexOf('  begin\n');
      final cancel = d.body.indexOf("cancel_reason = 'rescheduled'");
      final book = d.body.indexOf('public.book_slot(');
      final handler = d.body.indexOf('exception when others then');
      expect(begin, greaterThan(0));
      expect(cancel, greaterThan(begin));
      expect(book, greaterThan(cancel));
      expect(handler, greaterThan(book),
          reason: 'a failed claim must roll the release back with it');
    });
  });

  group('LA-38 · a refund compensates once', () {
    final d = _last('_refund_check');

    test('the host-missed rule is for classes this purchase paid for', () {
      expect(d.body, contains("p_purchase.kind in ('masterclass', 'cohort')"));
      expect(d.body, contains("bb.paid_by = 'purchase'"));
      expect(d.body, contains('public._slot_run(bb.slot_id) is not distinct from p_purchase.run_id'));
      expect(d.body, contains("bb.status in ('upcoming', 'attended')"),
          reason: 'not when she was already given another seat');
    });

    test('still checked before the window rule', () {
      expect(d.body.indexOf("'host_missed'"),
          lessThan(d.body.indexOf("'window_closed'")));
    });
  });

  group('LA-39 · a refund takes back only what it gave', () {
    test('_revoke_purchase cancels only seats this purchase paid for', () {
      final d = _last('_revoke_purchase');
      expect(d.body, contains("bb.paid_by = 'purchase'"), reason: d.file);
      expect(d.body, contains('c.source_ref = cp.id'));
      expect(d.body, contains("cancel_reason = 'refunded'"));
    });
  });

  group('LA-40 · a returned credit does not come back expired', () {
    for (final name in ['expert_cancel_booking', '_declare_host_missed']) {
      test(name, () {
        expect(_last(name).body, contains("now() + interval '30 days'"));
      });
    }
  });

  group('LA-41 · a closed slot cannot be booked', () {
    final d = _last('book_slot');

    test('book_slot refuses a started slot or one with an outcome', () {
      expect(d.body, contains("raise exception 'slot closed'"), reason: d.file);
      expect(d.body, contains('v_slot.starts_utc <= now() or v_slot.outcome is not null'));
    });

    test('the credit claim survived the copy-forward (LA-2)', () {
      expect(d.body, contains('for update skip locked'));
      expect(d.body, contains("set paid_by = 'credit'"));
    });
  });

  group('LA-42 · the host is seen by LiveKit, not by a tap', () {
    test('_host_seen prefers LiveKit rows when there are any', () {
      final d = _last('_host_seen');
      expect(d.body, contains("cs.role = 'expert'\n                    and cs.source = 'livekit'"));
    });
  });

  group('LA-43 / gap A · a slot nobody can vouch for waits for a person', () {
    test('_settle_slot holds while a host alert is open', () {
      final d = _last('_settle_slot');
      final hold = d.body.indexOf("a.kind in ('host_unknown', 'host_left')");
      final settle = d.body.indexOf('update public.booking_bookings');
      expect(hold, greaterThan(0));
      expect(settle, greaterThan(hold));
    });

    test('the sweep raises host_left', () {
      expect(_last('sweep_live_sessions').body, contains("'host_left'"));
    });

    test('resolve_host_alert is the service role\'s alone', () {
      final all = _all();
      expect(_last('resolve_host_alert').body, contains('_declare_host_missed('));
      expect(all, contains(
          'grant execute on function public.resolve_host_alert(text, boolean) to service_role'));
      expect(all, isNot(contains(
          'grant execute on function public.resolve_host_alert(text, boolean) to authenticated')));
    });
  });

  group('LA-44 · a late cancel that keeps the credit pays the doctor', () {
    test('the earnings trigger', () {
      final d = _last('expert_earning_from_booking');
      final late = d.body.indexOf("new.cancel_reason = 'late_cancel'");
      final reverse = d.body.indexOf('perform public.write_booking_reversal');
      expect(late, greaterThan(0), reason: d.file);
      expect(reverse, greaterThan(late), reason: 'checked before the reversal');
    });
  });

  group('contract · the 6-argument open_session_room is gone', () {
    test('dropped, and the app sends the slot id alone', () {
      expect(_all(), contains(
          'drop function if exists public.open_session_room(text, text, text, timestamptz, int, int)'));
      final s = _src('lib/booking/call_session.dart');
      final at = s.indexOf("invokeEdgeResult('livekit-token', {\n      'slotId': slot.id,");
      expect(at, greaterThan(0));
      expect(s.substring(at, s.indexOf('});', at)), isNot(contains("'startsUtc'")));
    });
  });

  group('the app', () {
    test('a cancel is local only after the server agreed', () {
      final s = _src('lib/booking/booking_store.dart');
      final ask = s.indexOf('final res = await SupabaseRepo.cancelBooking(bookingId);');
      final gate = s.indexOf("if (res['ok'] != true) {", ask);
      final local = s.indexOf('cancel(bookingId,\n        refundCredit: !late', ask);
      expect(ask, greaterThan(0));
      expect(gate, greaterThan(ask));
      expect(local, greaterThan(gate));
    });

    test('the sponsor card mirrors sponsor credits only (LA-45)', () {
      expect(_src('lib/services/sponsor_benefits.dart'),
          contains("CreditsStore.instance.fromSource('sponsor')"));
    });

    test('a refresh re-reads credits and the window', () {
      final s = _src('lib/booking/booking_store.dart');
      final at = s.indexOf('Future<void> refreshFromServer()');
      final end = s.indexOf('\n  }\n', at);
      final body = s.substring(at, end);
      expect(body, contains('CreditsStore.instance.refresh()'));
      expect(body, contains('_refreshTerms()'));
    });

    test('reschedule is the server move, not release then reserve', () {
      final s = _src('lib/screens/learn/pv_session_screen.dart');
      final at = s.indexOf('Future<Booking?> pvRescheduleBooking(');
      final body = _code(s.substring(at)).split('\nclass ').first;
      expect(body, contains('BookingStore.instance.reschedule(b, slot)'));
      expect(body.replaceAll(RegExp(r'//.*'), ''),
          isNot(contains('BookingStore.instance.release(')));
    });
  });

  group('the app, signed out, on a 4-class pack', () {
    final store = BookingStore.instance;
    setUp(store.resetAll);
    tearDown(store.resetAll);

    const pack = Offering(
      id: 'off_yoga',
      stage: ServiceStage.parenting,
      kind: OfferingKind.classPack,
      format: SessionFormat.liveGroup,
      catalogId: 'yoga_flow',
      title: 'Postnatal yoga · 4-class pack',
      expertId: 'exp_meera',
      priceMinor: 240000,
      grant: EntitlementGrant(credits: 4, validFor: Duration(days: 30)),
    );
    Slot slot(String id, Duration from) => Slot(
          id: id,
          offeringId: 'off_yoga',
          expertId: 'exp_meera',
          startsUtc: DateTime.now().toUtc().add(from),
          durationMin: 45,
          capacity: 20,
          booked: 0,
        );

    test('a cancel in time returns the credit', () async {
      store.purchase(pack);
      final b = store.book(slot('s1', const Duration(days: 2)))!;
      final r = await store.release(b.id);
      expect(r.ok, isTrue);
      expect(r.creditReturned, isTrue);
      expect(store.activeEntitlementFor('off_yoga')!.creditsLeft, 4);
    });

    test('a late cancel keeps it, and says so', () async {
      store.purchase(pack);
      final b = store.book(slot('s1', const Duration(hours: 1)))!;
      final r = await store.release(b.id);
      expect(r.ok, isTrue);
      expect(r.creditReturned, isFalse);
      expect(r.message, contains('stays with this session'));
      expect(r.message, isNot(contains('is back')));
      expect(store.activeEntitlementFor('off_yoga')!.creditsLeft, 3);
      expect(store.byId(b.id)!.keptCredit, isTrue);
    });

    test('a move inside the window is refused and changes nothing', () async {
      store.purchase(pack);
      final b = store.book(slot('s1', const Duration(hours: 1)))!;
      final r = await store.reschedule(b, slot('s2', const Duration(days: 3)));
      expect(r.booking, isNull);
      expect(r.message, contains('can no longer be moved'));
      expect(store.byId(b.id)!.isUpcoming, isTrue);
      expect(store.activeEntitlementFor('off_yoga')!.creditsLeft, 3);
    });

    test('a move outside it lands, and spends one credit in all', () async {
      store.purchase(pack);
      final b = store.book(slot('s1', const Duration(days: 2)))!;
      final r = await store.reschedule(b, slot('s2', const Duration(days: 3)));
      expect(r.booking, isNotNull);
      expect(store.byId(b.id)!.isUpcoming, isFalse);
      expect(store.activeEntitlementFor('off_yoga')!.creditsLeft, 3);
    });
  });
}
