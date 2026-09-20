// =============================================================================
//  Offering content — what the KIND puts into the fixed page, as data
// -----------------------------------------------------------------------------
//  `PvOfferingScreen` has ten sections in one order and never switches on
//  kind. This file is where a course, a masterclass, a cohort, a consult and
//  a class pack differ: the three trust rows, the name of the structure
//  block, the "how it works" steps a consult shows instead of a curriculum,
//  and the one verb on the sticky bar in each ownership state.
//
//  The audit's table (docs/LEARNING-AUDIT.md §4.2), in code. Add a kind here
//  and the page grows a column; add a section and every kind gets it.
//
//  ⚠️ STATE COMES FROM THE ENGINE, NOT FROM SEED STATUS. The old programmes
//  carried `status: reserveOpen | available | ongoing | completed` as data,
//  so a page could say "you're in" to someone who had bought nothing. Here
//  "owned" means an entitlement with credits, "booked" means an upcoming
//  booking, "watching" means she owns the recording or the thing is free.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../data/learn/pv_learn_view.dart';
import '../../services/pv_learn_progress_store.dart';

/// Where she stands with this thing.
enum PvLearnState {
  /// Nothing bought. The verb sells.
  none,

  /// Bought, with a seat or credit still to spend. The verb books.
  owned,

  /// A seat is booked and upcoming. The verb opens the session.
  booked,

  /// Free, or the recording is hers. The verb plays.
  watching,
}

PvLearnState pvLearnStateFor(PvOfferingView v) {
  final o = v.offering;
  if (o == null) return PvLearnState.watching;
  final store = BookingStore.instance;
  final booked = store.upcoming().any((b) => b.offeringId == o.id);
  if (booked) return PvLearnState.booked;
  if (v.isRecorded && v.kind != PvLearnKind.classPack) {
    return store.ownsRecording(o.id) || v.isFree
        ? PvLearnState.watching
        : PvLearnState.none;
  }
  final ent = store.activeEntitlementFor(o.id);
  if (ent != null && ent.canBook) return PvLearnState.owned;
  return PvLearnState.none;
}

/// The next upcoming booking for this thing, if any.
Booking? pvLearnBookingFor(PvOfferingView v) {
  final id = v.offering?.id;
  if (id == null) return null;
  for (final b in BookingStore.instance.upcoming()) {
    if (b.offeringId == id) return b;
  }
  return null;
}

/// What the sticky bar says and does.
enum PvCommitAction { buyThenPlay, play, pickSlot, buyPack, openSession }

class PvLearnVerb {
  const PvLearnVerb(this.verb, this.action, {this.note});
  final String verb;
  final PvCommitAction action;
  final String? note;
}

PvLearnVerb pvCommitFor(
  PvOfferingView v,
  PvLearnState state, {
  Booking? booking,
}) {
  final progress = PvLearnProgressStore.instance;
  switch (v.kind) {
    case PvLearnKind.course:
      if (state == PvLearnState.watching) {
        final done = progress.doneCount(v.id);
        final left = v.lessons.length - done;
        if (done == 0) {
          return const PvLearnVerb('Start the course', PvCommitAction.play);
        }
        if (left <= 0) {
          return const PvLearnVerb(
            'Watch again',
            PvCommitAction.play,
            note: 'All lessons done',
          );
        }
        return PvLearnVerb(
          'Continue',
          PvCommitAction.play,
          note: left == 1 ? '1 lesson left' : '$left lessons left',
        );
      }
      return const PvLearnVerb(
        'Start the course',
        PvCommitAction.buyThenPlay,
        note: 'Yours to keep',
      );
    case PvLearnKind.masterclass:
      if (state == PvLearnState.booked && booking != null) {
        return PvLearnVerb(
          'Your seat',
          PvCommitAction.openSession,
          note: _when(booking),
        );
      }
      if (v.isRecorded) {
        return state == PvLearnState.watching
            ? const PvLearnVerb('Watch', PvCommitAction.play)
            : const PvLearnVerb(
                'Get the class',
                PvCommitAction.buyThenPlay,
                note: 'Recording, yours to keep',
              );
      }
      if (state == PvLearnState.owned) {
        return const PvLearnVerb(
          'Pick your seat',
          PvCommitAction.pickSlot,
          note: 'Paid · choose a date',
        );
      }
      return PvLearnVerb(
        'Reserve a seat',
        PvCommitAction.pickSlot,
        note: v.recordingIncluded ? 'Recording included' : 'Live, in the app',
      );
    case PvLearnKind.cohort:
      if (state == PvLearnState.booked && booking != null) {
        return PvLearnVerb(
          'Your cohort',
          PvCommitAction.openSession,
          note: 'Starts ${_when(booking)}',
        );
      }
      if (state == PvLearnState.owned) {
        return const PvLearnVerb(
          'Pick a start date',
          PvCommitAction.pickSlot,
          note: 'Paid · choose your run',
        );
      }
      return PvLearnVerb(
        'Join the cohort',
        PvCommitAction.pickSlot,
        note: v.seatsLeft != null ? '${v.seatsLeft} seats left' : 'Small group',
      );
    case PvLearnKind.consult:
      if (state == PvLearnState.booked && booking != null) {
        return PvLearnVerb(
          'Your session',
          PvCommitAction.openSession,
          note: _when(booking),
        );
      }
      if (state == PvLearnState.owned) {
        return const PvLearnVerb(
          'Pick a time',
          PvCommitAction.pickSlot,
          note: 'Paid · one session',
        );
      }
      return const PvLearnVerb(
        'See availability',
        PvCommitAction.pickSlot,
        note: 'Pay after you pick a time',
      );
    case PvLearnKind.classPack:
      if (state == PvLearnState.booked && booking != null) {
        return PvLearnVerb(
          'Next class',
          PvCommitAction.openSession,
          note: _when(booking),
        );
      }
      if (state == PvLearnState.owned) {
        final ent = BookingStore.instance.activeEntitlementFor(v.offering!.id);
        final left = ent?.creditsLeft ?? 0;
        return PvLearnVerb(
          'Book a class',
          PvCommitAction.pickSlot,
          note: left == 1 ? '1 class left' : '$left classes left',
        );
      }
      return const PvLearnVerb(
        'Get the pack',
        PvCommitAction.buyPack,
        note: '4 classes · use within 30 days',
      );
  }
}

String _when(Booking b) {
  final d = b.startsUtc.toLocal();
  const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final mm = d.minute.toString().padLeft(2, '0');
  return '${w[d.weekday - 1]} ${d.day} · $h:$mm ${d.hour < 12 ? 'am' : 'pm'}';
}

/// The three trust rows. The middle one is always the money rule, said
/// once, in one line — no "guarantee" band.
List<PvLearnTrust> pvTrustRowsFor(PvOfferingView v) {
  final reviewer = v.expert.expert != null
      ? 'by ${v.expert.name}'
      : 'by our clinical panel';
  switch (v.kind) {
    case PvLearnKind.course:
      return [
        PvLearnTrust(
          Icons.verified_outlined,
          'Reviewed $reviewer',
          'Every lesson is checked against current guidance before it goes live.',
        ),
        PvLearnTrust(
          Icons.replay_rounded,
          v.isFree ? 'Free, always' : 'Full refund within 7 days',
          v.isFree
              ? 'Nothing here is locked or upsold.'
              : 'If it is not for you, say so and the money comes back.',
        ),
        const PvLearnTrust(
          Icons.all_inclusive_rounded,
          'Yours to keep',
          'Watch again whenever you like, on any phone you sign into.',
        ),
      ];
    case PvLearnKind.masterclass:
      return [
        PvLearnTrust(
          Icons.verified_outlined,
          'Reviewed $reviewer',
          'What is taught is checked against current guidance.',
        ),
        const PvLearnTrust(
          Icons.replay_rounded,
          'Full refund up to 24 hours before',
          'Cancel from the app; the seat goes back to someone else.',
        ),
        PvLearnTrust(
          Icons.videocam_outlined,
          v.recordingIncluded ? 'Recording included' : 'Live, in the app',
          v.recordingIncluded
              ? 'Miss it and it is still yours.'
              : 'Cameras optional. Questions in the thread.',
        ),
      ];
    case PvLearnKind.cohort:
      return [
        PvLearnTrust(
          Icons.verified_outlined,
          'Led $reviewer',
          'A small group, the same faces every call.',
        ),
        const PvLearnTrust(
          Icons.replay_rounded,
          'Full refund before the first call',
          'After it starts, the seat is yours and so is the thread.',
        ),
        const PvLearnTrust(
          Icons.groups_outlined,
          'Small group, capped',
          'Seats close when the run starts. The number on this page is real.',
        ),
      ];
    case PvLearnKind.consult:
      return [
        const PvLearnTrust(
          Icons.verified_outlined,
          'Verified clinician',
          'Registration checked before they are listed.',
        ),
        const PvLearnTrust(
          Icons.replay_rounded,
          'Free cancellation up to 24 hours before',
          'Later than that and the session is spent — the doctor held the time.',
        ),
        const PvLearnTrust(
          Icons.health_and_safety_outlined,
          'Never a diagnosis from us',
          'The consult is theirs; ParentVeda only arranges the time.',
        ),
      ];
    case PvLearnKind.classPack:
      return [
        PvLearnTrust(
          Icons.verified_outlined,
          'Taught $reviewer',
          'Pregnancy-safe and postnatal-safe by design.',
        ),
        const PvLearnTrust(
          Icons.replay_rounded,
          'Unused classes refunded',
          'Change your mind before the first class and the pack comes back in full.',
        ),
        const PvLearnTrust(
          Icons.calendar_month_outlined,
          'Four classes, your calendar',
          'Book each one when it suits; skip a week without losing it.',
        ),
      ];
  }
}

/// The structure block's heading — the one line the kind changes most.
String pvStructureTitle(PvOfferingView v) => switch (v.kind) {
  PvLearnKind.course => v.lessons.length == 1 ? 'The class' : 'The lessons',
  PvLearnKind.masterclass => v.isRecorded ? 'In the recording' : 'The evening',
  PvLearnKind.cohort => 'Week by week',
  PvLearnKind.consult => 'How it works',
  PvLearnKind.classPack => 'The rhythm',
};

/// What a consult (or a pack) shows in place of a curriculum.
List<PvLearnSession> pvHowItWorks(PvOfferingView v) => switch (v.kind) {
  PvLearnKind.consult => const [
    PvLearnSession(
      label: 'Step 1',
      title: 'Pick a time',
      when: '',
      points: [
        'Real availability from their own calendar. Pay once you have picked.',
      ],
    ),
    PvLearnSession(
      label: 'Step 2',
      title: 'Join in the app',
      when: '',
      points: [
        'A video room opens ten minutes before. Nothing to install, no link to find.',
      ],
    ),
    PvLearnSession(
      label: 'Step 3',
      title: 'Notes afterwards',
      when: '',
      points: ['What was said and what comes next, saved to your records.'],
    ),
  ],
  PvLearnKind.classPack => [
    for (var i = 0; i < v.rhythm.length; i++)
      PvLearnSession(label: 'Live', title: v.rhythm[i]),
    const PvLearnSession(
      label: 'Then',
      title: 'Book each class when it suits',
      points: ['Four credits, thirty days, any of the live times.'],
    ),
  ],
  _ => const [],
};

/// The FAQ every kind carries when the source has none.
List<PvLearnFaq> pvDefaultFaqs(PvOfferingView v) => switch (v.kind) {
  PvLearnKind.course => const [
    PvLearnFaq(
      'Do I have to watch in order?',
      'No. The order is the one that makes most sense, not a lock.',
    ),
    PvLearnFaq(
      'Can my partner watch too?',
      'Yes — sign in on his phone and it is there.',
    ),
  ],
  PvLearnKind.masterclass => const [
    PvLearnFaq(
      'What if I miss it?',
      'If the recording is included, it appears under Your learning the next day. If not, the next run is listed here.',
    ),
    PvLearnFaq(
      'Can I ask questions?',
      'Yes, in the thread during and after the class.',
    ),
  ],
  PvLearnKind.cohort => const [
    PvLearnFaq(
      'How big is the group?',
      'Capped, and the cap is the number on this page. Usually eight to twelve.',
    ),
    PvLearnFaq(
      'What if I miss a week?',
      'The call is recorded for the group, and the thread keeps going.',
    ),
  ],
  PvLearnKind.consult => const [
    PvLearnFaq(
      'Is this a replacement for my own doctor?',
      'No. It is a second pair of eyes and a calm half hour. Your own clinician\'s word comes first.',
    ),
    PvLearnFaq(
      'Can my partner join the call?',
      'Yes — the room allows two from one booking.',
    ),
  ],
  PvLearnKind.classPack => const [
    PvLearnFaq(
      'What do I need?',
      'A mat, some floor, and clothes you can move in.',
    ),
    PvLearnFaq(
      'Is it safe in my trimester?',
      'Every class is pregnancy-safe by design, and the teacher asks at the start. If your doctor has said to rest, rest.',
    ),
  ],
};

/// Whether a partner can join her booked session from his own phone.
/// Group things and consults: yes, on her booking. A pack: no — one mat.
bool pvPartnerMayJoin(PvOfferingView v) => v.kind != PvLearnKind.classPack;
