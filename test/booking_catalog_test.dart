// =============================================================================
//  BookingCatalog — the bridge produces real, future, bookable slots
// -----------------------------------------------------------------------------
//  The whole point of the bridge is that it replaced string dates with real
//  ones. These lock that: every generated slot is in the future, capacity is
//  honoured, both stages are covered, and an offering round-trips to a booking.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_catalog.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/booking/booking_store.dart';

void main() {
  final cat = BookingCatalog.instance;
  final store = BookingStore.instance;
  setUp(store.resetAll);
  tearDown(store.resetAll);

  test('derivation covers every bookable kind, and skips recorded', () {
    final kinds = cat.offerings().map((o) => o.kind).toSet();
    expect(kinds, containsAll([
      OfferingKind.masterclass,
      OfferingKind.consult,
      OfferingKind.cohort,
      OfferingKind.classPack,
    ]));
    // Recorded items must NOT be bridged — they play, they aren't booked.
    expect(kinds.contains(OfferingKind.subscription), isFalse);
    expect(cat.offerings(), isNotEmpty);
  });

  test('every generated slot is in the future and not full', () {
    final now = DateTime.now().toUtc();
    for (final o in cat.offerings()) {
      for (final s in cat.slotsFor(o.id)) {
        expect(s.startsUtc.isAfter(now), isTrue,
            reason: '${o.id} produced a past slot — the string-date bug');
        expect(s.isFull, isFalse, reason: 'full slots must be filtered out');
        expect(s.seatsLeft, greaterThan(0));
      }
    }
  });

  test('slots come back soonest-first', () {
    final o = cat.offeringForCatalog('y_flow_am')!; // liveGroup class-pack
    final s = cat.slotsFor(o.id);
    expect(s.length, greaterThan(1));
    for (var i = 1; i < s.length; i++) {
      expect(s[i - 1].startsUtc.isBefore(s[i].startsUtc), isTrue);
    }
  });

  test('a 1:1 offering generates capacity-1 calendar slots', () {
    final o = cat.offeringForCatalog('y_1to1')!; // liveOneToOne consult
    final slots = cat.slotsFor(o.id);
    expect(slots, isNotEmpty);
    for (final s in slots) {
      expect(s.capacity, 1);
    }
  });

  test('recorded/unknown offering yields no slots', () {
    // An unbridged id returns empty rather than throwing.
    expect(cat.slotsFor('off_does_not_exist'), isEmpty);
    // A recorded yoga class is not bridged at all.
    expect(cat.offeringForCatalog('y_evening_recorded'), isNull);
  });

  test('an offering flows through purchase -> book end to end', () {
    final o = cat.offeringForCatalog('y_flow_am')!;
    store.purchase(o);
    final slot = cat.slotsFor(o.id).first;
    final b = store.book(slot);
    expect(b, isNotNull);
    expect(b!.stage, ServiceStage.parenting);
    expect(b.startsUtc, slot.startsUtc);
    expect(store.upcoming().single.id, b.id);
    expect(store.activeEntitlementFor(o.id)!.creditsLeft, 3);
  });
}
