// =============================================================================
//  Group sessions — a class is a broadcast, and the code should know it
// -----------------------------------------------------------------------------
//  PRESENCE, not absence — the rule this repo learned the hard way when
//  `ownsRecording()` and `ownsDiscussion()` shipped with zero call sites while
//  the buy sheet advertised both, and the only test in the area asserted that
//  one-to-one support had NO discussion thread. An absence test passes just as
//  happily when the entire feature is missing.
//
//  So each test below names something a host or an attendee would notice, and
//  fails if it stops being true.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_catalog.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/booking/call_session.dart';
import 'package:parentveda/booking/server_slots.dart';

CallJoin _join({
  required int capacity,
  required CallRole role,
  bool canPublish = true,
}) =>
    CallJoin(
      url: 'wss://example',
      token: 'tok',
      room: 'bkroom_s1',
      slotId: 's1',
      role: role,
      canPublish: canPublish,
      capacity: capacity,
    );

void main() {
  group('a class and a consult are different products', () {
    test('capacity separates them, in both directions', () {
      final consult = _join(capacity: 1, role: CallRole.parent);
      final klass = _join(capacity: 100, role: CallRole.attendee);

      expect(consult.isConsult, isTrue);
      expect(consult.isGroup, isFalse);
      expect(klass.isGroup, isTrue);
      expect(klass.isConsult, isFalse);
    });

    test('an unknown capacity is neither, so nothing new applies to it', () {
      // 0 is the pre-0076 fallback shape. It must not accidentally acquire
      // consult rules OR class rules.
      final unknown = _join(capacity: 0, role: CallRole.unknown);
      expect(unknown.isConsult, isFalse);
      expect(unknown.isGroup, isFalse);
    });
  });

  group('four roles, because a class is not a conversation', () {
    test('all four exist and parse off the wire', () {
      expect(CallSession.roleFromMetadata('{"role":"host"}'), CallRole.host);
      expect(CallSession.roleFromMetadata('{"role":"attendee"}'),
          CallRole.attendee);
      expect(CallSession.roleFromMetadata('{"role":"expert"}'),
          CallRole.expert);
      expect(CallSession.roleFromMetadata('{"role":"parent"}'),
          CallRole.parent);
    });

    test('the host and the doctor are the ones who lead a room', () {
      // What the layout gives the stage to.
      expect(CallRole.host.leadsTheRoom, isTrue);
      expect(CallRole.expert.leadsTheRoom, isTrue);
      expect(CallRole.attendee.leadsTheRoom, isFalse);
      expect(CallRole.parent.leadsTheRoom, isFalse);
    });

    test('Host is labelled; attendee deliberately is not', () {
      // Labelling forty tiles "Attendee" says nothing anyone needed and turns
      // the one label that matters into noise.
      expect(CallRole.host.label, 'Host');
      expect(CallRole.attendee.label, isEmpty);
      expect(CallRole.unknown.label, isEmpty);
    });

    test('junk metadata costs a badge, never the session', () {
      expect(CallSession.roleFromMetadata('not json'), CallRole.unknown);
      expect(CallSession.roleFromMetadata('{"role":"pirate"}'),
          CallRole.unknown);
      expect(CallSession.roleFromMetadata(null), CallRole.unknown);
    });
  });

  group('an attendee arrives silent', () {
    test('the join carries a publish right, and it can be false', () {
      // The whole fix for "fifty mothers joined a masterclass and fifty were
      // broadcasting". Enforced by the token; this is the mirror the screen
      // lays itself out from.
      final attendee =
          _join(capacity: 100, role: CallRole.attendee, canPublish: false);
      final host = _join(capacity: 100, role: CallRole.host);

      expect(attendee.canPublish, isFalse);
      expect(host.canPublish, isTrue);
    });

    test('both parties of a consult still publish', () {
      // The 1:1 product must be untouched by any of this.
      expect(_join(capacity: 1, role: CallRole.parent).canPublish, isTrue);
      expect(_join(capacity: 1, role: CallRole.expert).canPublish, isTrue);
    });

    test('a join with no stated permission defaults to publishing', () {
      // The pre-0079 shape. Degrading to old behaviour beats locking everyone
      // out of a room because a migration has not been applied.
      const j = CallJoin(url: 'u', token: 't', room: 'r');
      expect(j.canPublish, isTrue);
    });
  });

  group('the room is addressed by its slot', () {
    test('the join carries the slot id moderation needs', () {
      // A host has no booking, so moderation cannot be addressed to one. The
      // server echoes the slot rather than making the client parse it back out
      // of "bkroom_<id>".
      expect(_join(capacity: 100, role: CallRole.host).slotId, 's1');
    });
  });

  group('seat counts come from the ledger, not from a hash', () {
    final cat = BookingCatalog.instance;

    setUp(ServerSlotStore.instance.resetAll);
    tearDown(ServerSlotStore.instance.resetAll);

    test('a masterclass with no server row shows nobody booked', () {
      // It used to show `40 + seed % 45` — a stable function of the offering
      // id, convincing precisely because it never changed, and unrelated to
      // whether one person had booked or none had.
      final o = cat.offeringForCatalog('mc_sleepreg');
      expect(o, isNotNull, reason: 'the wired masterclass must resolve');
      final slots = cat.slotsFor(o!.id);
      expect(slots, isNotEmpty);
      expect(slots.first.booked, 0,
          reason: 'no server row means no bookings, which is zero, not 43');
    });

    test('a real count from the server wins', () {
      final o = cat.offeringForCatalog('mc_sleepreg')!;
      final id = cat.slotsFor(o.id).first.id;
      ServerSlotStore.instance.seed({id: const ServerSlot(booked: 7, startsUtc: null)});

      final after = cat.slotsFor(o.id).first;
      expect(after.booked, 7);
      expect(after.seatsLeft, after.capacity - 7);
    });

    test('a full slot disappears from what is offered', () {
      final o = cat.offeringForCatalog('mc_sleepreg')!;
      final slot = cat.slotsFor(o.id).first;
      ServerSlotStore.instance
          .seed({slot.id: ServerSlot(booked: slot.capacity, startsUtc: null)});

      expect(cat.slotsFor(o.id), isEmpty,
          reason: 'a sold-out class must not be offered');
    });

    test('a count is never allowed to exceed the cap', () {
      final o = cat.offeringForCatalog('mc_sleepreg')!;
      final slot = cat.slotsFor(o.id).first;
      ServerSlotStore.instance.seed(
          {slot.id: ServerSlot(booked: slot.capacity + 50, startsUtc: null)});
      // Still simply full, not negative-seats-left.
      expect(cat.slotsFor(o.id), isEmpty);
    });
  });

  group('a class needs a date that stays still', () {
    final cat = BookingCatalog.instance;
    setUp(ServerSlotStore.instance.resetAll);
    tearDown(ServerSlotStore.instance.resetAll);

    test('the ledger date wins over the generated one', () {
      // THE BUG THIS PINS. A one-off class is generated as `now + 5..8 days`,
      // recomputed on every read — so asked on the 23rd it fell on the 28th,
      // and asked on the 24th the SAME SLOT fell on the 29th. The class never
      // arrived, and a host's start-time was permanently in the future, which
      // is why "Start session" could never light up.
      final o = cat.offeringForCatalog('mc_sleepreg')!;
      final id = cat.sessionSlotsFor(o.id).first.id;
      final real = DateTime.utc(2026, 9, 1, 14, 30);
      ServerSlotStore.instance.seed({id: ServerSlot(booked: 3, startsUtc: real)});

      final onThe23rd =
          cat.sessionSlotsFor(o.id, now: DateTime.utc(2026, 8, 23)).first;
      final onThe24th =
          cat.sessionSlotsFor(o.id, now: DateTime.utc(2026, 8, 24)).first;

      expect(onThe23rd.startsUtc, real);
      expect(onThe24th.startsUtc, real,
          reason: 'a booked class must not move overnight');
    });

    test('without a ledger row the date is still a placeholder', () {
      // Honest about where the product is: nobody has booked, so there is
      // nothing to contradict, and the host may go live whenever.
      final o = cat.offeringForCatalog('mc_sleepreg')!;
      final id = cat.sessionSlotsFor(o.id).first.id;
      expect(ServerSlotStore.instance.isReal(id), isFalse);
    });
  });

  group('a host can find their own session', () {
    final cat = BookingCatalog.instance;
    setUp(ServerSlotStore.instance.resetAll);
    tearDown(ServerSlotStore.instance.resetAll);

    test('a sold-out class is still visible to the person teaching it', () {
      // slotsFor drops full slots, which is right for a buyer and would take a
      // host's session away from them entirely.
      final o = cat.offeringForCatalog('mc_sleepreg')!;
      final slot = cat.sessionSlotsFor(o.id).first;
      ServerSlotStore.instance
          .seed({slot.id: ServerSlot(booked: slot.capacity, startsUtc: null)});

      expect(cat.slotsFor(o.id), isEmpty, reason: 'not offered to a buyer');
      expect(cat.sessionSlotsFor(o.id), isNotEmpty,
          reason: 'but the host still has to turn up to it');
    });

    test('a class already running is still visible to the host', () {
      final o = cat.offeringForCatalog('mc_sleepreg')!;
      final slot = cat.sessionSlotsFor(o.id).first;
      final started = DateTime.utc(2026, 9, 1, 14, 30);
      ServerSlotStore.instance
          .seed({slot.id: ServerSlot(booked: 5, startsUtc: started)});

      // Ten minutes into the class.
      final during = started.add(const Duration(minutes: 10));
      expect(cat.slotsFor(o.id, now: during), isEmpty,
          reason: 'a started class is not bookable');
      expect(cat.sessionSlotsFor(o.id, now: during), isNotEmpty,
          reason: 'the host must not lose the room the moment it begins');
    });
  });

  group('the offerings a host can actually run', () {
    test('a masterclass and a cohort are group formats', () {
      final mc = BookingCatalog.instance.offeringForCatalog('mc_sleepreg');
      expect(mc, isNotNull);
      expect(mc!.kind, OfferingKind.masterclass);
      // capacity > 1 is what every guard keys on, server and client alike.
      final slot = BookingCatalog.instance.slotsFor(mc.id).first;
      expect(slot.capacity, greaterThan(1));
    });
  });
}
