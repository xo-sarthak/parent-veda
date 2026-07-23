// =============================================================================
//  Booking wiring — the two representative screens reach a real offering
// -----------------------------------------------------------------------------
//  The bridge only helps if the actual catalogue ids on the wired screens map
//  to offerings. These lock that the yoga class (y_flow_am) and the masterclass
//  (mc_sleepreg) each resolve to one, and that buying then booking through the
//  engine works for both — so the sheet is never opened on a dead offering.
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

  test('the wired yoga class resolves to a class-pack offering', () {
    final o = cat.offeringForCatalog('y_flow_am');
    expect(o, isNotNull);
    expect(o!.kind, OfferingKind.classPack);
    expect(cat.slotsFor(o.id), isNotEmpty);
  });

  test('the wired masterclass resolves to a masterclass offering', () {
    final o = cat.offeringForCatalog('mc_sleepreg');
    expect(o, isNotNull);
    expect(o!.kind, OfferingKind.masterclass);
    expect(o.grant.recordingAccess, isTrue,
        reason: 'a masterclass grants the recording');
  });

  test('a doctor with availability is an in-app consult (Practo dropped)', () {
    // Dr. Neha Sharma has timings, so she books in-app now.
    final o = cat.offeringForCatalog('neha'); // expert id
    expect(o, isNotNull, reason: 'a bookable doctor must derive a consult');
    expect(o!.kind, OfferingKind.consult);
    expect(o.format, SessionFormat.liveOneToOne);
    final slots = cat.slotsFor(o.id);
    expect(slots, isNotEmpty, reason: 'the calendar case must produce times');
    expect(slots.every((s) => s.capacity == 1), isTrue);
  });

  test('a pregnancy specialist is an in-app consult, tagged pregnancy', () {
    final o = cat.offeringForCatalog('sp_ob'); // pregnancy obstetrician
    expect(o, isNotNull);
    expect(o!.stage, ServiceStage.pregnancy);
    expect(o.kind, OfferingKind.consult);
    expect(cat.slotsFor(o.id), isNotEmpty);
  });

  test('one engine spans both stages', () {
    final preg = cat.offerings(stage: ServiceStage.pregnancy);
    final par = cat.offerings(stage: ServiceStage.parenting);
    expect(preg, isNotEmpty, reason: 'pregnancy Prepare is bridged');
    expect(par, isNotEmpty, reason: 'parenting is bridged');
  });

  test('buy then book works end to end for the masterclass', () async {
    final o = cat.offeringForCatalog('mc_sleepreg')!;
    store.purchase(o);
    final slot = cat.slotsFor(o.id).first;
    final b = await store.reserve(slot);
    expect(b, isNotNull);
    expect(store.upcoming().single.title, o.title);
    expect(store.ownsRecording(o.id), isTrue);
  });
}
