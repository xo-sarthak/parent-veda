// =============================================================================
//  Consultation call — the guards that keep 1:1 fixed and groups untouched
// -----------------------------------------------------------------------------
//  These assert PRESENCE, not absence. That distinction has cost this codebase
//  a shipped dead feature before: `booking_wiring_test` checks that one-to-one
//  support carries NO discussion thread, and nothing anywhere checks that the
//  discussion thread exists for the things that do sell one — so
//  `ownsDiscussion()` and `ownsRecording()` reached production with zero call
//  sites and the buy sheet advertising both. An absence test passes just as
//  happily when the whole feature is missing.
//
//  So each test below names a behaviour a user would notice, and fails if it
//  stops happening.
//
//  THE OTHER HALF OF THE JOB is the group guard. Every behaviour added in the
//  consultation pass is gated on `capacity == 1`, and these lock that a
//  non-consult still takes the old path — because "we did not break the
//  masterclass" is a claim, and a claim in a commit message is worth nothing
//  next to a test.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/booking/booking_models.dart';
import 'package:parentveda/booking/call_session.dart';
import 'package:parentveda/booking/prescription.dart';
import 'package:parentveda/booking/prescription_bridge.dart';
import 'package:parentveda/screens/post_pregnancy/pp_experts_data.dart';

CallJoin _join({required int capacity, CallRole role = CallRole.parent}) =>
    CallJoin(
      url: 'wss://example',
      token: 'tok',
      room: 'bkroom_s1',
      role: role,
      capacity: capacity,
      startsUtc: DateTime.utc(2026, 8, 23, 10),
      endsUtc: DateTime.utc(2026, 8, 23, 10, 30),
    );

Booking _booking({
  required DateTime startsUtc,
  int durationMin = 30,
  BookingStatus status = BookingStatus.upcoming,
}) =>
    Booking(
      id: 'bkg_1',
      offeringId: 'off_1',
      slotId: 'slot_1',
      stage: ServiceStage.parenting,
      title: 'Consult · Dr. Neha Sharma',
      startsUtc: startsUtc,
      durationMin: durationMin,
      status: status,
      bookedUtc: DateTime.utc(2026, 8, 1),
    );

void main() {
  group('the consult guard', () {
    test('capacity 1 is a consult; a class is not', () {
      expect(_join(capacity: 1).isConsult, isTrue);
      expect(_join(capacity: 50).isConsult, isFalse);
    });

    test('an unknown capacity is treated as NOT a consult', () {
      // 0 is what the pre-0076 fallback path produces. It must take the OLD
      // behaviour rather than acquire consult rules it has never been tested
      // under — the safe direction, and the deliberate one.
      expect(_join(capacity: 0).isConsult, isFalse);
    });

    test('the session carries a role, and the role has a label', () {
      // The whole defect in one assertion: before 0076 a join could not answer
      // "who am I", so the call screen could not label anybody.
      expect(_join(capacity: 1, role: CallRole.expert).role.isExpert, isTrue);
      expect(CallRole.expert.label, 'Doctor');
      expect(CallRole.parent.label, 'Parent');
    });

    test('an unknown role renders no label rather than a guessed one', () {
      // A group session and the fallback path both land here. A wrong badge on
      // a clinician is worse than no badge.
      expect(CallRole.unknown.label, isEmpty);
    });

    test('role is parsed from server metadata, and junk costs only the badge',
        () {
      expect(
        CallSession.roleFromMetadata('{"role":"expert","capacity":1}'),
        CallRole.expert,
      );
      expect(CallSession.roleFromMetadata(null), CallRole.unknown);
      expect(CallSession.roleFromMetadata('not json'), CallRole.unknown);
      expect(CallSession.roleFromMetadata('{"role":"pirate"}'),
          CallRole.unknown);
    });

    test('the sold length of the session is known to the call', () {
      // What the five-minutes-left warning counts against.
      expect(_join(capacity: 1).scheduledLength, const Duration(minutes: 30));
    });
  });

  group('the join window', () {
    // joinableAt() has described the right window since the engine was built
    // and had NO callers: the screen used `b.isUpcoming`, which is a pure
    // status check, so every upcoming booking showed a live "Join now" —
    // including one three weeks out.
    final starts = DateTime.utc(2026, 8, 23, 10);
    final b = _booking(startsUtc: starts);

    test('shut three weeks early', () {
      expect(b.joinableAt(starts.subtract(const Duration(days: 21))), isFalse);
    });

    test('shut eleven minutes early, open at nine', () {
      expect(b.joinableAt(starts.subtract(const Duration(minutes: 11))), isFalse);
      expect(b.joinableAt(starts.subtract(const Duration(minutes: 9))), isTrue);
    });

    test('open during, shut after the end', () {
      expect(b.joinableAt(starts.add(const Duration(minutes: 15))), isTrue);
      expect(b.joinableAt(starts.add(const Duration(minutes: 31))), isFalse);
    });

    test('a cancelled booking is never joinable', () {
      final c = _booking(startsUtc: starts, status: BookingStatus.cancelled);
      expect(c.joinableAt(starts), isFalse);
    });

    test('isUpcoming still ignores the clock — which is why it was wrong', () {
      // Pinned deliberately. If someone "fixes" isUpcoming to consider time,
      // the group path silently gains a window it was never meant to have.
      expect(b.isUpcoming, isTrue);
    });
  });

  group('a doctor closing an appointment', () {
    test('cancelled and missed are different words on the wire', () {
      // The money differs, so the outcome must not collapse into one call.
      expect(DoctorOutcome.cancelled.wire, 'cancelled');
      expect(DoctorOutcome.missed.wire, 'missed');
    });

    test('BookingStatus.missed exists to be written', () {
      // It was declared when the engine was built and set by nothing at all,
      // because attendance was inferred from the clock.
      expect(BookingStatus.values, contains(BookingStatus.missed));
    });
  });

  group('naming a prescriber', () {
    test('a known id resolves to that expert', () {
      final first = kExperts.first;
      expect(expertByIdOrNull(first.id)?.name, first.name);
    });

    test('an unknown id resolves to NOBODY, not to the first doctor', () {
      // The critical one. expertById() falls back to kExperts.first, so using
      // it on a prescription would attribute the script to a real clinician
      // who never wrote it.
      expect(expertByIdOrNull('no_such_expert'), isNull);
      expect(expertByIdOrNull(''), isNull);
      expect(expertById('no_such_expert').id, kExperts.first.id); // unchanged
    });
  });

  group('the prescription bridge', () {
    final rx = Prescription(
      id: 'rx_77',
      bookingId: 'bkg_9',
      expertId: 'no_such_expert',
      items: const [
        RxItem(medicine: 'Paracetamol', dosage: '5ml twice a day', duration: '3 days'),
        RxItem(medicine: 'ORS', dosage: 'after each loose stool'),
        RxItem(medicine: '   '), // blank rows must not become medications
      ],
      advice: 'Fluids and rest.',
      createdUtc: DateTime.utc(2026, 8, 20, 9),
    );

    test('ids are derived from the prescription, so saving twice saves once',
        () {
      // Idempotence by construction, the same reasoning as client-minted
      // booking ids: a second tap writes the same ids rather than a duplicate.
      expect(PrescriptionBridge.recordId(rx), 'presrx_rx_77');
      expect(PrescriptionBridge.medicationId(rx, 0), 'medrx_rx_77_0');
      expect(PrescriptionBridge.recordId(rx), PrescriptionBridge.recordId(rx));
    });

    test('two different prescriptions never collide', () {
      final other = Prescription(
        id: 'rx_78',
        bookingId: 'bkg_9',
        expertId: '',
        items: const [],
        advice: '',
        createdUtc: DateTime.utc(2026, 8, 21),
      );
      expect(PrescriptionBridge.recordId(rx),
          isNot(PrescriptionBridge.recordId(other)));
    });
  });

  group('prescription refusals are told apart', () {
    test('only the recoverable ones offer a retry', () {
      // "Your consultation opens at 4:50 PM" and "you are offline" want
      // different buttons. Collapsing every refusal into one message is the
      // failure 0075's header is about.
      expect(const CallJoinFailure(CallRefusal.offline).retryable, isTrue);
      expect(const CallJoinFailure(CallRefusal.serverError).retryable, isTrue);
      expect(const CallJoinFailure(CallRefusal.tooEarly).retryable, isFalse);
      expect(const CallJoinFailure(CallRefusal.ended).retryable, isFalse);
      expect(const CallJoinFailure(CallRefusal.notYours).retryable, isFalse);
    });

    test('too-early carries the time the door opens', () {
      final f = CallJoinFailure(
        CallRefusal.tooEarly,
        opensUtc: DateTime.utc(2026, 8, 23, 9, 50),
      );
      expect(f.opensUtc, isNotNull);
    });
  });
}
