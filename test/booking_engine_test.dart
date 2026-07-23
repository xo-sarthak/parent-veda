// =============================================================================
//  Booking engine invariants
// -----------------------------------------------------------------------------
//  The rules the whole paid-services system rests on: you cannot book without a
//  credit, credits run out and expire, a full slot is refused, cancelling
//  refunds, and one history spans both stages. Locked here so a later refactor
//  (or the server RPC swap) cannot quietly break them.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/booking/booking_store.dart';

Offering _pack({
  String id = 'off_yoga',
  ServiceStage stage = ServiceStage.parenting,
  int credits = 4,
  Duration? validFor = const Duration(days: 30),
}) =>
    Offering(
      id: id,
      stage: stage,
      kind: OfferingKind.classPack,
      format: SessionFormat.liveGroup,
      catalogId: 'yoga_flow',
      title: 'Postnatal yoga · 4-class pack',
      expertId: 'exp_meera',
      priceMinor: 240000,
      grant: EntitlementGrant(credits: credits, validFor: validFor),
    );

Slot _slot(String id, DateTime startsUtc,
        {String offeringId = 'off_yoga', int capacity = 20, int booked = 0}) =>
    Slot(
      id: id,
      offeringId: offeringId,
      expertId: 'exp_meera',
      startsUtc: startsUtc,
      durationMin: 45,
      capacity: capacity,
      booked: booked,
    );

void main() {
  final store = BookingStore.instance;

  setUp(store.resetAll);
  tearDown(store.resetAll);

  final soon = DateTime.now().toUtc().add(const Duration(days: 2));

  test('you cannot book without buying first', () {
    expect(store.book(_slot('s1', soon)), isNull,
        reason: 'no entitlement means no credit to spend');
    expect(store.bookings(), isEmpty);
  });

  test('buying grants credits; booking spends them', () {
    store.purchase(_pack());
    final b = store.book(_slot('s1', soon));
    expect(b, isNotNull);
    expect(store.activeEntitlementFor('off_yoga')!.creditsLeft, 3,
        reason: 'one of four credits is now spent');
    expect(store.upcoming().length, 1);
  });

  test('credits run out — the fifth booking is refused', () {
    store.purchase(_pack(credits: 4));
    for (var i = 0; i < 4; i++) {
      expect(store.book(_slot('s$i', soon.add(Duration(days: i)))), isNotNull);
    }
    expect(store.book(_slot('s4', soon.add(const Duration(days: 9)))), isNull,
        reason: 'all four credits are spent');
    expect(store.upcoming().length, 4);
  });

  test('expired credits cannot be spent', () {
    // Bought 40 days ago on a 30-day pack.
    final past = DateTime.now().toUtc().subtract(const Duration(days: 40));
    store.purchase(_pack(), at: past);
    expect(store.activeEntitlementFor('off_yoga'), isNull,
        reason: 'the pack lapsed ten days ago');
    expect(store.book(_slot('s1', soon)), isNull);
  });

  test('a full slot is refused even with credits in hand', () {
    store.purchase(_pack());
    expect(store.book(_slot('s1', soon, capacity: 20, booked: 20)), isNull);
    expect(store.book(_slot('s2', soon, capacity: 1, booked: 0)), isNotNull);
  });

  test('the same slot cannot be double-booked', () {
    store.purchase(_pack());
    expect(store.book(_slot('s1', soon)), isNotNull);
    expect(store.book(_slot('s1', soon)), isNull,
        reason: 'she already holds this slot');
    expect(store.activeEntitlementFor('off_yoga')!.creditsLeft, 3,
        reason: 'the refused re-book must not spend a second credit');
  });

  test('cancelling refunds the credit', () {
    store.purchase(_pack());
    final b = store.book(_slot('s1', soon))!;
    expect(store.activeEntitlementFor('off_yoga')!.creditsLeft, 3);
    expect(store.cancel(b.id), isTrue);
    expect(store.activeEntitlementFor('off_yoga')!.creditsLeft, 4,
        reason: 'the credit comes back');
    expect(store.upcoming(), isEmpty);
  });

  test('one history spans both stages, and filters by stage', () {
    store.purchase(_pack(id: 'off_yoga', stage: ServiceStage.parenting));
    store.purchase(_pack(id: 'off_birth', stage: ServiceStage.pregnancy));
    store.book(_slot('s1', soon, offeringId: 'off_yoga'));
    store.book(_slot('s2', soon.add(const Duration(days: 1)),
        offeringId: 'off_birth'));

    expect(store.bookings().length, 2, reason: 'one combined history');
    expect(store.bookings(stage: ServiceStage.pregnancy).length, 1);
    expect(store.bookings(stage: ServiceStage.parenting).length, 1);
  });

  test('reserve() falls back to a local booking when logged out', () async {
    // No Supabase session in tests, so reserve() takes the offline path and
    // behaves exactly like book().
    store.purchase(_pack());
    final b = await store.reserve(_slot('s1', soon));
    expect(b, isNotNull);
    expect(store.upcoming().single.id, b!.id);
    expect(store.activeEntitlementFor('off_yoga')!.creditsLeft, 3);
  });

  test('a past session moves out of upcoming on reconcile', () {
    store.purchase(_pack());
    final over = DateTime.now().toUtc().subtract(const Duration(hours: 3));
    store.book(_slot('s1', over));
    // upcoming() already excludes ended sessions by time.
    expect(store.upcoming(), isEmpty);
    expect(store.bookings().single.startsUtc.isBefore(DateTime.now().toUtc()),
        isTrue);
  });
}
