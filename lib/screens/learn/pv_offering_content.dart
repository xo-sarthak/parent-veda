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

import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../data/learn/pv_learn_view.dart';
import '../../services/life_stage_store.dart' show LifeStage;
import 'pv_learn_art.dart';
import 'pv_learn_catalog.dart' show pvLearnHasNoNamedPerson;
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
enum PvCommitAction {
  buyThenPlay,
  play,
  pickSlot,
  buyPack,
  openSession,
  /// A consult with nobody named to run it yet (the user, 2026-09-28): it
  /// shows, never hidden, but it cannot be booked. Tapping says so.
  comingSoon,
}

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
      // ⚠️ NO BOOKING WITHOUT A NAMED PERSON (launch sanity H16, the user,
      // 2026-09-28). The andrologist consult has a role and no one on the
      // roster to run it; taking money for a call nobody is set to take would
      // be the worst kind of broken. It stays on the shelf as an honest
      // "Coming soon" and lifts itself the day `_ttcRosterFor` names someone.
      // A booking already made is still shown, whatever the roster says.
      if (booking == null &&
          state == PvLearnState.none &&
          pvLearnHasNoNamedPerson(v)) {
        return const PvLearnVerb(
          'Coming soon',
          PvCommitAction.comingSoon,
          note: "We're adding a specialist",
        );
      }
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

/// Whether the Trying to conceive experts' registrations have been checked
/// AND the check is recorded somewhere a reviewer could see (launch sanity
/// H17, 2026-09-28). Flip to true when it is; the consult page then says
/// "Verified clinician" again.
const bool kTtcRegistrationChecksRecorded = false;

/// The three trust rows. The middle one is always the money rule, said
/// once, in one line — no "guarantee" band.
///
/// ⚠️ ON TRYING TO CONCEIVE, NO REVIEW CLAIMED (launch sanity, H14's
/// follow-up, 2026-09-28). The TTC offerings carry no roster record, so the
/// first row fell through to "Reviewed by our clinical panel", "Led by our
/// clinical panel" or "Taught by our clinical panel" with the seal-and-tick
/// mark: a panel that does not exist, and a review nobody did. The user's
/// rule for reads applies here too: no "Reviewed by" and no tick until an
/// expert signs the piece off. The consult row is H17's and stays as it is.
/// Other stages are unchanged (a decision for the user).
List<PvLearnTrust> pvTrustRowsFor(PvOfferingView v) {
  final rows = _pvTrustRowsFor(v);
  if (v.stage != LifeStage.tryingToConceive ||
      v.kind == PvLearnKind.consult) {
    return rows;
  }
  return [pvTtcLeadTrustRow(v), ...rows.skip(1)];
}

/// The first trust row on a Trying to conceive course, masterclass, group or
/// class pack: who made it or who teaches it, said as a fact, never a review.
PvLearnTrust pvTtcLeadTrustRow(PvOfferingView v) {
  if (v.kind == PvLearnKind.course) {
    return const PvLearnTrust(
      PvLearnMark.note,
      'Written by the ParentVeda team',
      'Each lesson is written from current guidance.',
    );
  }
  final named = !pvLearnHasNoNamedPerson(v) &&
      !v.expert.name.toLowerCase().contains('parentveda');
  // "An andrologist" reads as "Taught by an andrologist".
  final who = named
      ? v.expert.name
      : v.expert.name.replaceFirstMapped(
          RegExp(r'^An? '), (m) => m[0]!.toLowerCase());
  final verb = v.kind == PvLearnKind.cohort ? 'Led' : 'Taught';
  return PvLearnTrust(
    PvLearnMark.learn,
    '$verb by $who',
    named
        ? 'You see who ${v.kind == PvLearnKind.cohort ? 'leads' : 'teaches'} '
            'it before you book.'
        : 'Live, with time for your questions.',
  );
}

List<PvLearnTrust> _pvTrustRowsFor(PvOfferingView v) {
  final reviewer = v.expert.expert != null
      ? 'by ${v.expert.name}'
      : 'by our clinical panel';
  switch (v.kind) {
    case PvLearnKind.course:
      return [
        PvLearnTrust(
          PvLearnMark.reviewed,
          'Reviewed $reviewer',
          'Every lesson is checked against current guidance before it goes live.',
        ),
        PvLearnTrust(
          PvLearnMark.refund,
          v.isFree ? 'Free, always' : 'Full refund within 7 days',
          v.isFree
              ? 'Nothing here is locked or upsold.'
              : 'If it is not for you, say so and the money comes back.',
        ),
        const PvLearnTrust(
          PvLearnMark.keep,
          'Yours to keep',
          'Watch again whenever you like, on any phone you sign into.',
        ),
      ];
    case PvLearnKind.masterclass:
      return [
        PvLearnTrust(
          PvLearnMark.reviewed,
          'Reviewed $reviewer',
          'What is taught is checked against current guidance.',
        ),
        const PvLearnTrust(
          PvLearnMark.refund,
          'Full refund up to 24 hours before',
          'Cancel from the app; the seat goes back to someone else.',
        ),
        PvLearnTrust(
          PvLearnMark.recording,
          v.recordingIncluded ? 'Recording included' : 'Live, in the app',
          v.recordingIncluded
              ? 'Miss it and it is still yours.'
              : 'Cameras optional. Questions in the thread.',
        ),
      ];
    case PvLearnKind.cohort:
      return [
        PvLearnTrust(
          PvLearnMark.reviewed,
          'Led $reviewer',
          'A small group, the same faces every call.',
        ),
        const PvLearnTrust(
          PvLearnMark.refund,
          'Full refund before the first call',
          'After it starts, the seat is yours and so is the thread.',
        ),
        const PvLearnTrust(
          PvLearnMark.group,
          'Small group, capped',
          'Seats close when the run starts. The number on this page is real.',
        ),
      ];
    case PvLearnKind.consult:
      return [
        // ⚠️ ON TRYING TO CONCEIVE, NO CLAIM WITHOUT A RECORD (launch sanity
        // H17, 2026-09-28). "Registration checked before they are listed"
        // had nothing behind it on screen, and the stage has no recorded
        // registration check yet. Until `kTtcRegistrationChecksRecorded` is
        // true the row says only what is true: she sees who she is booking.
        // Other stages are unchanged (a decision for the user).
        if (v.stage == LifeStage.tryingToConceive &&
            !kTtcRegistrationChecksRecorded)
          const PvLearnTrust(
            PvLearnMark.reviewed,
            'A named clinician',
            'You see who you are booking, and what they do, before you pay.',
          )
        else
          const PvLearnTrust(
            PvLearnMark.reviewed,
            'Verified clinician',
            'Registration checked before they are listed.',
          ),
        const PvLearnTrust(
          PvLearnMark.refund,
          'Free cancellation up to 24 hours before',
          'Later than that and the session is spent — the doctor held the time.',
        ),
        const PvLearnTrust(
          PvLearnMark.notOurs,
          'Never a diagnosis from us',
          'The consult is theirs; ParentVeda only arranges the time.',
        ),
      ];
    case PvLearnKind.classPack:
      return [
        PvLearnTrust(
          PvLearnMark.reviewed,
          'Taught $reviewer',
          'Pregnancy-safe and postnatal-safe by design.',
        ),
        const PvLearnTrust(
          PvLearnMark.refund,
          'Unused classes refunded',
          'Change your mind before the first class and the pack comes back in full.',
        ),
        const PvLearnTrust(
          PvLearnMark.calendar,
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

/// ⚠️ EIGHT QUESTIONS, NOT TWO (2026-09-30, the user, on Talk to an expert,
/// Courses and Cohorts: "the FAQs are very less… questions should be more.
/// This page should be converting"). A page that asks someone to book,
/// enrol or pay has to answer what stops them: is it for me, what happens,
/// what if I cannot go, what if it is not for me, is it medical advice.
/// Every answer here repeats only what the page's own trust rows already
/// promise (7-day refund on a course, 24 hours on a masterclass or consult,
/// before the first call on a cohort, no diagnosis from ParentVeda); no new
/// policy is invented in a question. The two questions each kind had before
/// come first and are unchanged.
const int kPvFaqMax = 8;

/// What the page shows: the source's own questions first, then these, with
/// no question said twice, at most [kPvFaqMax].
List<PvLearnFaq> pvFaqsFor(PvOfferingView v) {
  final out = <PvLearnFaq>[...v.faqs];
  final seen = {for (final f in out) f.q.toLowerCase()};
  for (final f in pvDefaultFaqs(v)) {
    if (seen.add(f.q.toLowerCase())) out.add(f);
  }
  return out.take(kPvFaqMax).toList();
}

/// The FAQ every kind carries, after the source's own.
List<PvLearnFaq> pvDefaultFaqs(PvOfferingView v) => switch (v.kind) {
  PvLearnKind.course => [
    const PvLearnFaq(
      'Do I have to watch in order?',
      'No. The order is the one that makes most sense, not a lock.',
    ),
    const PvLearnFaq(
      'Can my partner watch too?',
      'Yes — sign in on his phone and it is there.',
    ),
    const PvLearnFaq(
      'Who is it for?',
      'Anyone at the stage it is written for who wants it explained calmly, in order. No medical background needed.',
    ),
    const PvLearnFaq(
      'How long will it take?',
      'Each lesson is short, and the minutes are next to it. Most people do one a day or one a week. There is no deadline.',
    ),
    const PvLearnFaq(
      'Can I watch again later?',
      'Yes. It is yours to keep, on any phone you sign into.',
    ),
    PvLearnFaq(
      'What if it is not for me?',
      v.isFree
          ? 'It is free, so there is nothing to lose. Stop whenever you like.'
          : 'Say so within 7 days and the money comes back in full.',
    ),
    const PvLearnFaq(
      'Is this medical advice?',
      "No. It explains what is known and helps you prepare for a conversation with your doctor. Your own clinician's word always comes first.",
    ),
    const PvLearnFaq(
      'Will it remember where I stopped?',
      'Yes. Your place is kept, and it follows you to any phone you sign into.',
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
    PvLearnFaq(
      'Do I have to switch my camera on?',
      'No. Cameras are optional, and you can ask in the thread instead.',
    ),
    PvLearnFaq(
      'Can I get a refund?',
      'Yes. A full refund up to 24 hours before it starts. Cancel from the app and the seat goes back to someone else.',
    ),
    PvLearnFaq(
      'What do I need to join?',
      'Just your phone and the app. The time and length are at the top of this page, and you join from the same place you booked.',
    ),
    PvLearnFaq(
      'Can my partner join too?',
      'Yes. A partner can join from their own phone on your booking.',
    ),
    PvLearnFaq(
      'Is it for beginners?',
      'Yes. It starts from the beginning and assumes no background.',
    ),
    PvLearnFaq(
      'Is this medical advice?',
      "No. It is teaching, not treatment. For anything about your own health, your doctor's word comes first.",
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
    PvLearnFaq(
      'What happens each week?',
      'A live call, something short to read or watch beforehand, and a thread for the group in between. "Week by week" on this page has the plan.',
    ),
    PvLearnFaq(
      'Do I have to speak on the calls?',
      'Speak as much as you like. The thread is there if you would rather write.',
    ),
    PvLearnFaq(
      'Can I get a refund?',
      'Yes, in full before the first call. After it starts, the seat is yours and so is the thread.',
    ),
    PvLearnFaq(
      'Who else is in the group?',
      'People at the same stage as you, a small group with the same faces every call. Seats close when the run starts.',
    ),
    PvLearnFaq(
      'Can my partner join too?',
      'Yes, on your booking.',
    ),
    PvLearnFaq(
      'Does a cohort replace my doctor?',
      "No. It is support and teaching from someone qualified, in company. Your own clinician's word comes first.",
    ),
  ],
  PvLearnKind.consult => const [
    PvLearnFaq(
      'Is this a replacement for my own doctor?',
      "No. It is a second pair of eyes and a calm half hour. Your own clinician's word comes first.",
    ),
    PvLearnFaq(
      'Can my partner join the call?',
      'Yes — the room allows two from one booking.',
    ),
    PvLearnFaq(
      'What can I ask?',
      'Anything about the stage you are in: your dates, your tests, whether to see a specialist, what a report means. A few questions written down beforehand make the half hour go further.',
    ),
    PvLearnFaq(
      'Who will I be talking to?',
      'A named clinician. You see who they are and what they do before you book.',
    ),
    PvLearnFaq(
      'Will I get a diagnosis or a prescription?',
      "The consult is the clinician's, and any advice is theirs. ParentVeda only arranges the time and never gives a diagnosis. If they think you need tests or treatment, they will say so.",
    ),
    PvLearnFaq(
      'What if I need to cancel?',
      'Free up to 24 hours before. Later than that the session is spent, because the doctor held the time.',
    ),
    PvLearnFaq(
      'How does the call work?',
      'You choose a time, and at that time you join from the app. "How it works" on this page goes through the steps.',
    ),
    PvLearnFaq(
      'Should I bring anything?',
      'Your dates, and any reports or test results you have. Having them to hand saves time.',
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
    PvLearnFaq(
      'What if I cannot make a class?',
      'Book each one when it suits; skip a week without losing it.',
    ),
    PvLearnFaq(
      'Can I get a refund?',
      'Unused classes are refunded. Change your mind before the first class and the pack comes back in full.',
    ),
    PvLearnFaq(
      'Do I need any experience?',
      'No. The teacher starts from the basics and shows an easier way for each move.',
    ),
    PvLearnFaq(
      'Is it live?',
      'Yes, with the teacher, at the times listed on this page.',
    ),
  ],
};

// Kept for revert (2026-09-30): the two-question version.
// /// The FAQ every kind carries when the source has none.
// List<PvLearnFaq> pvDefaultFaqs(PvOfferingView v) => switch (v.kind) {
//   PvLearnKind.course => const [
//     PvLearnFaq(
//       'Do I have to watch in order?',
//       'No. The order is the one that makes most sense, not a lock.',
//     ),
//     PvLearnFaq(
//       'Can my partner watch too?',
//       'Yes — sign in on his phone and it is there.',
//     ),
//   ],
//   PvLearnKind.masterclass => const [
//     PvLearnFaq(
//       'What if I miss it?',
//       'If the recording is included, it appears under Your learning the next day. If not, the next run is listed here.',
//     ),
//     PvLearnFaq(
//       'Can I ask questions?',
//       'Yes, in the thread during and after the class.',
//     ),
//   ],
//   PvLearnKind.cohort => const [
//     PvLearnFaq(
//       'How big is the group?',
//       'Capped, and the cap is the number on this page. Usually eight to twelve.',
//     ),
//     PvLearnFaq(
//       'What if I miss a week?',
//       'The call is recorded for the group, and the thread keeps going.',
//     ),
//   ],
//   PvLearnKind.consult => const [
//     PvLearnFaq(
//       'Is this a replacement for my own doctor?',
//       'No. It is a second pair of eyes and a calm half hour. Your own clinician\'s word comes first.',
//     ),
//     PvLearnFaq(
//       'Can my partner join the call?',
//       'Yes — the room allows two from one booking.',
//     ),
//   ],
//   PvLearnKind.classPack => const [
//     PvLearnFaq(
//       'What do I need?',
//       'A mat, some floor, and clothes you can move in.',
//     ),
//     PvLearnFaq(
//       'Is it safe in my trimester?',
//       'Every class is pregnancy-safe by design, and the teacher asks at the start. If your doctor has said to rest, rest.',
//     ),
//   ],
// };

/// Whether a partner can join her booked session from his own phone.
/// Group things and consults: yes, on her booking. A pack: no — one mat.
bool pvPartnerMayJoin(PvOfferingView v) => v.kind != PvLearnKind.classPack;
