// =============================================================================
//  L2c — the app on the server's contract (LEARNING-ARCHITECTURE §7)
// -----------------------------------------------------------------------------
//  0126 moved money, receipts and the timetable to the server and left five
//  functions with no caller. This pass is the app moving onto them, and these
//  tests hold the move in place:
//
//    * what she owns is DERIVED from the server's receipts once she is signed
//      in; a row the phone minted does not count (LA-5);
//    * the phone sends no price (LA-4's client half) and never grants on
//      "not configured" by itself (LA-7);
//    * every 0126 function the app is meant to call has a call site in lib/
//      (the wiring gate: correct-but-unreachable is this repo's known failure);
//    * a recorded course is sellable under the id 0126 seeded (LA-14);
//    * a bundled consult with no server price is "opening soon" (LA-30).
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_catalog.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/booking/booking_store.dart';
import 'package:parentveda/booking/server_slots.dart';
import 'package:parentveda/screens/learn/pv_my_learning_screen.dart'
    show pvPurchaseLine, pvRupees;

String _src(String path) => File(path).readAsStringSync();

/// Every Dart file under lib/, as one string per file.
Map<String, String> _lib() => {
  for (final f in Directory('lib').listSync(recursive: true).whereType<File>())
    if (f.path.endsWith('.dart')) f.path.replaceAll(r'\', '/'): f.readAsStringSync(),
};

Map<String, Object?> _row(
  String id,
  String offeringId, {
  String status = 'active',
  String kind = 'masterclass',
  String provider = 'stub',
  String mode = 'stub',
  int amount = 149900,
  Map<String, Object?>? refund,
}) => {
  'id': id,
  'offering_id': offeringId,
  'programme_id': offeringId.replaceFirst(RegExp(r'^off_(pg_)?'), ''),
  'kind': kind,
  'title': 'Receipt $id',
  'stage': 'parenting',
  'amount_paise': amount,
  'status': status,
  'provider': provider,
  'mode': mode,
  'payment_id': provider == 'razorpay' ? 'pay_$id' : null,
  'paid_at': DateTime.now().toUtc().subtract(const Duration(days: 1)).toIso8601String(),
  'refund': refund ?? {'eligible': true, 'until': null, 'reason': 'not_scheduled'},
};

void main() {
  final store = BookingStore.instance;
  final cat = BookingCatalog.instance;
  setUp(() {
    store.resetAll();
    ServerSlotStore.instance.resetAll();
  });
  tearDown(() {
    store.resetAll();
    ServerSlotStore.instance.resetAll();
  });

  group('LA-5 · signed in, what she owns is the server\'s receipts', () {
    test('a receipt grants the offering, for this account only', () {
      final mc = cat.offeringForCatalog('mc_sleepreg')!;
      store.debugUid = 'u1';
      store.seedReceipts([_row('cp_1', mc.id)], uid: 'u1');
      expect(store.activeEntitlementFor(mc.id), isNotNull);
      expect(store.ownsRecording(mc.id), isTrue);

      // Another account signs in on the same phone: the cache is not theirs.
      store.debugUid = 'u2';
      expect(store.activeEntitlementFor(mc.id), isNull);
      expect(store.purchases, isEmpty);
    });

    test('a refunded receipt grants nothing (L.12: a refund revokes all)', () {
      final mc = cat.offeringForCatalog('mc_sleepreg')!;
      store.debugUid = 'u1';
      store.seedReceipts([_row('cp_1', mc.id, status: 'refund_requested')],
          uid: 'u1');
      expect(store.activeEntitlementFor(mc.id), isNull);
      expect(store.ownsRecording(mc.id), isFalse);
      expect(store.purchases.single.status, 'refund_requested');
    });

    test('a phone-minted entitlement does not count once signed in', () {
      final mc = cat.offeringForCatalog('mc_sleepreg')!;
      store.purchase(mc); // the pre-L2c local mint
      expect(store.activeEntitlementFor(mc.id), isNotNull,
          reason: 'signed out, the local seam still works (tests, offline)');
      store.debugUid = 'u1';
      expect(store.activeEntitlementFor(mc.id), isNull,
          reason: 'signed in, only the server can say she owns it');
    });

    test('credits used are counted from her bookings, not stored', () {
      final pack = cat.offeringForCatalog('y_flow_am')!; // 4-class pack
      store.debugUid = 'u1';
      store.seedReceipts(
          [_row('cp_p', pack.id, kind: 'class_pack', amount: 39900)],
          uid: 'u1');
      expect(store.activeEntitlementFor(pack.id)!.creditsLeft, 4);

      // A booking (signed-out seam books locally; the count is derived).
      store.debugUid = null;
      ServerSlotStore.instance.seed({
        'ps_a': ServerSlot(
          id: 'ps_a',
          offeringId: pack.id,
          booked: 0,
          startsUtc: DateTime.now().toUtc().add(const Duration(days: 3)),
          expertId: 'exp_host',
          durationMin: 45,
          capacity: 18,
        ),
      });
      store.purchase(pack);
      expect(store.book(cat.slotsFor(pack.id).first), isNotNull);

      store.debugUid = 'u1';
      expect(store.activeEntitlementFor(pack.id)!.creditsLeft, 3,
          reason: 'one booking spends one of the receipt\'s four');
    });

    test('a gift credit still counts when signed in (LA-23 is later)', () {
      store.grantFloatingCredit(sourceId: 'ref_1', title: 'A free consult');
      store.debugUid = 'u1';
      expect(store.entitlements().any((e) => e.id == 'ent_gift_ref_1'), isTrue);
    });
  });

  group('LA-4 / LA-7 · the phone sends no price and grants nothing itself', () {
    test('checkout sends only the offering id', () {
      final s = _src('lib/booking/payment_service.dart');
      expect(s, contains('sendAmount: false'));
      expect(s, contains("if (sendAmount) 'amountMinor': amountMinor"));
    });

    test('a refusal keeps its reason; only an absent backend is notConfigured',
        () {
      final s = _src('lib/booking/payment_service.dart');
      expect(s, contains("case 'already_owned':"));
      expect(s, contains("case 'unknown_offering':"));
      expect(s, contains('invokeEdgeResult'));
    });

    test('no screen grants on notConfigured or mints a purchase', () {
      for (final e in _lib().entries) {
        if (e.key.endsWith('booking/booking_store.dart')) continue;
        final live = e.value
            .split('\n')
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        expect(live, isNot(contains('BookingStore.instance.purchase(')),
            reason: '${e.key} mints a purchase on the phone');
        expect(live,
            isNot(contains('result.outcome == PaymentOutcome.notConfigured')),
            reason: '${e.key} grants on "not configured" by itself');
      }
    });

    test('book_slot is no longer sent the phone\'s price', () {
      final s = _src('lib/booking/booking_store.dart');
      final live = s
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(live, isNot(contains('priceMinor: BookingCatalog')));
    });
  });

  group('the wiring gate · every 0126 function the app owns has a caller', () {
    // 0126 left these with no caller; L2c is where they get one. A function
    // named only in a comment does not count.
    for (final fn in [
      'my_purchases',
      'record_stub_purchase',
      'claim_free_offering',
      'request_refund',
      'record_lesson_open',
    ]) {
      test(fn, () {
        final callers = _lib().entries.where((e) => e.value
            .split('\n')
            .where((l) => !l.trimLeft().startsWith('//'))
            .any((l) => l.contains("'$fn'")));
        expect(callers, isNotEmpty, reason: '$fn has no call site in lib/');
      });
    }

    test('acquire is what every buy path calls', () {
      for (final f in [
        'lib/screens/learn/pv_learn_flow.dart',
        'lib/screens/post_pregnancy/booking_sheet.dart',
        'lib/screens/ttc/ttc_prepare_screen.dart',
      ]) {
        expect(_src(f), contains('BookingStore.instance.acquire('), reason: f);
      }
    });

    test('the lesson player reports opens, and Your bookings has Payments', () {
      expect(_src('lib/screens/learn/pv_lesson_screen.dart'),
          contains('recordLessonOpen('));
      final mine = _src('lib/screens/learn/pv_my_learning_screen.dart');
      expect(mine, contains("'Payments'"));
      expect(mine, contains('requestRefund('));
    });
  });

  group('LA-10 · a class has the server\'s dates, and only those', () {
    test('no timetable, no slot; a ps_ row is the slot', () {
      final mc = cat.offeringForCatalog('mc_sleepreg')!;
      expect(cat.slotsFor(mc.id), isEmpty);
      final at = DateTime.now().toUtc().add(const Duration(days: 5));
      ServerSlotStore.instance.seed({
        'ps_s9': ServerSlot(
          id: 'ps_s9',
          offeringId: mc.id,
          booked: 2,
          startsUtc: at,
          expertId: 'exp_real',
          durationMin: 75,
          capacity: 60,
        ),
        // A consult's slot is not timetable, whatever its offering.
        'bk_x': ServerSlot(id: 'bk_x', offeringId: mc.id, booked: 0, startsUtc: at),
      });
      final s = cat.slotsFor(mc.id).single;
      expect(s.id, 'ps_s9');
      expect(s.expertId, 'exp_real');
      expect(s.capacity, 60);
      expect(s.startsUtc, at);
    });
  });

  group('LA-14 · a recorded course is sold, under the seeded id', () {
    test('the paid courses resolve to recorded, bought-once offerings', () {
      for (final (catalogId, offeringId) in [
        ('rc_sleep', 'off_rc_sleep'),
        ('flagship', 'off_flagship'),
        ('course_birthprep', 'off_pg_course_birthprep'),
      ]) {
        final o = cat.offeringForCatalog(catalogId);
        expect(o, isNotNull, reason: '$catalogId cannot be bought');
        expect(o!.id, offeringId);
        expect(o.format, SessionFormat.recorded);
        expect(o.grant.recordingAccess, isTrue);
        expect(o.priceMinor, greaterThan(0));
        expect(cat.slotsFor(o.id), isEmpty, reason: 'nothing to book');
      }
    });
  });

  group('LA-30 · no server price, opening soon', () {
    test('every bundled consult is unpriced; a real expert\'s is priced', () {
      final consults =
          cat.offerings().where((o) => o.kind == OfferingKind.consult);
      for (final o in consults) {
        expect(offeringHasServerPrice(o), o.id.startsWith('off_exp_'),
            reason: o.id);
      }
      for (final o in cat.offerings().where((o) => o.kind != OfferingKind.consult)) {
        expect(offeringHasServerPrice(o), isTrue, reason: o.id);
      }
    });
  });

  group('L.22 · the Payments line says what the server said', () {
    test('status and refund verdict, in her words', () {
      final p = Purchase.fromRow(_row('cp_1', 'off_mc_sleepreg',
          provider: 'razorpay', mode: 'live',
          refund: {'eligible': false, 'reason': 'window_closed'}));
      expect(pvPurchaseLine(p), 'Paid');
      final t = Purchase.fromRow(_row('cp_2', 'off_mc_sleepreg'));
      expect(pvPurchaseLine(t), 'Paid · test purchase · refundable');
      final r = Purchase.fromRow(_row('cp_3', 'off_mc_sleepreg', status: 'refunded'));
      expect(pvPurchaseLine(r), 'Refunded');
      expect(pvRupees(149900), '₹1,499');
      expect(pvRupees(2499900), '₹24,999');
      expect(pvRefundRefusal('lessons_opened'), contains('lesson 1'));
    });
  });
}
