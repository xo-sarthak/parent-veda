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
import 'package:parentveda/data/mind_mood_data.dart';

void main() {
  _mindMood();
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

// =============================================================================
//  Mind & Mood — the fourth wiring gate of this review
// -----------------------------------------------------------------------------
//  `mm_talk_tab.dart` carried a comment saying "wire this to lib/booking/ when
//  this section is ready" and built its own booking sheet in the meantime. So
//  the app had two booking flows, and the parallel one scheduled nothing while
//  showing a warm confirmation.
//
//  ⚠️ NOTHING COULD HAVE CAUGHT THAT. The placeholder compiled, rendered and
//  read correctly. These tests are the thing that would have: they assert the
//  ids the screen actually looks up resolve to real offerings, so the day
//  somebody renames an id in `mind_mood_data.dart`, a test fails instead of a
//  booking silently falling back to the dead sheet.
// =============================================================================

void _mindMood() {
  final cat = BookingCatalog.instance;

  // The screen builds this string. If the prefix here and the prefix there ever
  // disagree, every Mind & Mood booking silently degrades to the old sheet.
  String idFor(String catalogId) => 'off_mm_$catalogId';

  test('every Mind & Mood offering the screen can open resolves', () {
    for (final o in kMmTalkOfferings) {
      final real = cat.offeringById(idFor(o.id));
      expect(real, isNotNull,
          reason: 'mm offering ${o.id} has no catalogue entry, so the Talk tab '
              'falls back to the placeholder sheet that books nothing');
      expect(real!.stage, ServiceStage.pregnancy);
      expect(cat.slotsFor(real.id), isNotEmpty,
          reason: 'a sheet with no slots is a dead end for a woman who has '
              'just decided she needs to talk to someone');
    }
  });

  test('the ongoing check-in is a pack of four, not a subscription', () {
    final pack = cat.offeringById(idFor('ongoing_checkin'));
    expect(pack, isNotNull);
    expect(pack!.kind, OfferingKind.classPack);
    expect(pack.grant.credits, 4);
    // ⚠️ THE POINT OF THE 120 DAYS. A month's validity would take back what she
    // paid for as a penalty for having a good few weeks. Assert the floor, not
    // the exact number, so tuning the window does not fail the test but
    // shortening it below a pregnancy-shaped horizon does.
    //
    // ⚠️ AND `validFor` IS NULLABLE, WHERE NULL MEANS NEVER EXPIRES. So the
    // null check is not defensive noise - it is the difference between a pack
    // that lasts four months and one we accidentally gave away forever.
    expect(pack.grant.validFor, isNotNull);
    expect(pack.grant.validFor!.inDays, greaterThanOrEqualTo(90));
  });

  test('one-to-one support carries no discussion thread', () {
    for (final o in kMmTalkOfferings) {
      final real = cat.offeringById(idFor(o.id))!;
      // A persistent thread here would be an unmonitored channel carrying
      // exactly the disclosures that need a human on the other end.
      expect(real.grant.discussionThread, isFalse, reason: real.title);
    }
  });

  test('price survives the rupee-to-minor-unit conversion', () {
    for (final o in kMmTalkOfferings) {
      expect(cat.offeringById(idFor(o.id))!.priceMinor, o.priceInr * 100,
          reason: '${o.id} is charged the wrong amount');
    }
  });
}
