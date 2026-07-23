// =============================================================================
//  Booking engine — the domain model (one engine, both stages)
// -----------------------------------------------------------------------------
//  ParentVeda's paid services — masterclasses, 1:1 consults, cohorts, yoga
//  packs, subscriptions — were five static "layers": a catalogue entry, a price
//  string, and a booked-id set. No real time, no seats, no credits, no history.
//  This file is the shared BOOKING layer that turns them into one working
//  system, built around a single idea every one of those services reduces to:
//
//        you buy an ENTITLEMENT, then you spend it on SLOTS.
//
//  It deliberately does NOT replace the display models (LearningProgram /
//  PrepProgram / YogaClass). Those still answer "what is this thing" — title,
//  blurb, cover, trailer. This layer answers "when does it happen, how many
//  seats, what did buying give me, what have I booked". An [Offering] points at
//  a catalogue item by id; the engine itself is content-agnostic, which is why
//  the SAME engine serves a pregnancy masterclass and a parenting yoga pack.
//
//  THE STAGE TAG is the reason there is one engine and not two. Every offering
//  and every booking carries [ServiceStage]. A mother who books a birthing
//  class while pregnant and a postnatal-yoga pack a year later sees BOTH in one
//  history — filterable, but one list. Two engines would split that in half,
//  which is exactly what makes an app feel like two apps.
//
//  THE LIVE CALL is one nullable field ([Slot.joinUrl]). Zoom vs Meet vs a
//  recorded URL is a pluggable detail we have not settled yet; the whole spine
//  is built without it, and it slots in later touching nothing else.
//
//  TIME IS REAL. Every moment here is a UTC [DateTime], stored UTC and shown
//  local. The old layers used literal strings ("Sun 13 Jul", "Next: today 6pm")
//  which is why nothing could ever remind a parent about a class — there was no
//  time to compare against. This is the field that makes "your class starts in
//  an hour" possible.
// =============================================================================

import 'package:flutter/foundation.dart';

/// The tag that lets one history span pregnancy AND parenting. Mirrors the
/// existing BrandStage split so the whole app talks about stage the same way.
enum ServiceStage { pregnancy, parenting }

/// What KIND of thing is being booked. Drives the entitlement shape and the
/// booking UX — a consult spends one credit on one slot from an expert's
/// calendar; a class pack spends one of several credits on a recurring class.
enum OfferingKind {
  /// One-to-many teaching, live or recorded, bought once. Group-capped.
  masterclass,

  /// 1:1 with an expert — pick a slot from THEIR availability. Capacity 1.
  consult,

  /// A dated group program over several weeks, seat-capped, with a thread.
  cohort,

  /// Buy N credits (e.g. 4 yoga classes) and spend them on slots over a window
  /// ("redeem any time this month"). The flexible one.
  classPack,

  /// Recurring access — a recorded library or an all-you-can-join membership.
  subscription,
}

/// How a session reaches the parent. Recorded offerings have no slots.
enum SessionFormat { liveGroup, liveOneToOne, recorded }

/// The lifecycle of one booked slot, from the parent's point of view. This is
/// what a history row shows, and what "you have an upcoming class" keys off.
enum BookingStatus { upcoming, attended, missed, cancelled }

// ---------------------------------------------------------------------------
//  Offering — the booking-layer view of a catalogue item
// ---------------------------------------------------------------------------

/// What a purchase GRANTS. The contract between paying and being able to book.
///
/// A pure recording grants [credits] 0 + [recordingAccess] true. A consult
/// grants 1 credit. A yoga pack grants 4 credits with a 30-day [validFor]. This
/// is where "4 classes, redeem any time in a month" is actually expressed.
@immutable
class EntitlementGrant {
  const EntitlementGrant({
    this.credits = 0,
    this.validFor,
    this.recordingAccess = false,
    this.discussionThread = false,
  });

  /// Bookable sessions this purchase provides. 0 = nothing to book (a pure
  /// recording or a read-only membership).
  final int credits;

  /// How long the credits stay spendable from the moment of purchase. Null =
  /// no expiry. `Duration(days: 30)` is the "any time this month" case.
  final Duration? validFor;

  /// Grants the recording / replay library for this offering.
  final bool recordingAccess;

  /// Unlocks the offering's private discussion thread (a cohort perk).
  final bool discussionThread;
}

/// A bookable offering — the SELLABLE unit. Points at a display-layer catalogue
/// item ([catalogId]) rather than duplicating its copy; the engine only needs
/// enough to sell, schedule and record it.
@immutable
class Offering {
  const Offering({
    required this.id,
    required this.stage,
    required this.kind,
    required this.format,
    required this.catalogId,
    required this.title,
    required this.expertId,
    required this.priceMinor,
    required this.grant,
  });

  final String id;

  /// The tag. Which side of the app this belongs to — and how a booking made
  /// from it is filed in the one history.
  final ServiceStage stage;

  final OfferingKind kind;
  final SessionFormat format;

  /// The display model this wraps — a LearningProgram / PrepProgram / YogaClass
  /// id. The screens keep rendering the rich catalogue entry; the engine keys
  /// off this to know which thing was sold.
  final String catalogId;

  /// Denormalised title, so a history row and a reminder can be built without a
  /// catalogue lookup (and still read correctly if the catalogue later changes).
  final String title;

  final String expertId;

  /// Price in the minor unit (paise), a real integer — NOT the old cosmetic
  /// "₹799" label. Money that can be summed, discounted and charged.
  final int priceMinor;

  /// What buying this grants.
  final EntitlementGrant grant;

  /// Convenience: does buying this let you book live slots at all?
  bool get isBookable => format != SessionFormat.recorded && grant.credits > 0;
}

// ---------------------------------------------------------------------------
//  Slot — a concrete bookable time (REAL DateTime)
// ---------------------------------------------------------------------------

/// One time you can book into. Shared, server-authoritative data: [booked] is
/// the true seat count and only the backend may increment it (two mothers must
/// not both claim the last seat). Recorded offerings have no slots.
@immutable
class Slot {
  const Slot({
    required this.id,
    required this.offeringId,
    required this.expertId,
    required this.startsUtc,
    required this.durationMin,
    required this.capacity,
    required this.booked,
    this.joinUrl,
  });

  final String id;
  final String offeringId;
  final String expertId;

  /// Stored UTC, shown in the parent's local zone. The field that makes
  /// scheduling and reminders real.
  final DateTime startsUtc;

  final int durationMin;

  /// Seat cap. 1 for a 1:1 consult; 50/100 for a group class.
  final int capacity;

  /// How many seats are taken. Server-authoritative — the client only reads it.
  final int booked;

  /// The live-call link. NULL for now, on purpose: the meeting provider (Zoom
  /// vs Meet vs …) is an open decision, and everything is built so that filling
  /// this in later is the only change needed to go live.
  final String? joinUrl;

  bool get isFull => booked >= capacity;
  int get seatsLeft => (capacity - booked).clamp(0, capacity);
  DateTime get endsUtc => startsUtc.add(Duration(minutes: durationMin));

  Map<String, Object?> toMap() => {
        'id': id,
        'offeringId': offeringId,
        'expertId': expertId,
        'startsUtc': startsUtc.toUtc().toIso8601String(),
        'durationMin': durationMin,
        'capacity': capacity,
        'booked': booked,
        'joinUrl': joinUrl,
      };

  static Slot fromMap(Map data) => Slot(
        id: (data['id'] ?? '').toString(),
        offeringId: (data['offeringId'] ?? '').toString(),
        expertId: (data['expertId'] ?? '').toString(),
        startsUtc: DateTime.parse(data['startsUtc'].toString()).toUtc(),
        durationMin: (data['durationMin'] as num?)?.toInt() ?? 0,
        capacity: (data['capacity'] as num?)?.toInt() ?? 1,
        booked: (data['booked'] as num?)?.toInt() ?? 0,
        joinUrl: data['joinUrl']?.toString(),
      );
}

// ---------------------------------------------------------------------------
//  Entitlement — what the mother owns (her side of a purchase)
// ---------------------------------------------------------------------------

/// The parent's OWN record of a purchase and how much of it is left. This is
/// user-owned state, synced as part of her booking blob — the seat counts it
/// does NOT touch live on the shared slots.
@immutable
class Entitlement {
  const Entitlement({
    required this.id,
    required this.offeringId,
    required this.stage,
    required this.title,
    required this.creditsTotal,
    required this.creditsUsed,
    required this.purchasedUtc,
    this.expiresUtc,
    this.recordingAccess = false,
    this.discussionThread = false,
  });

  final String id;
  final String offeringId;
  final ServiceStage stage;
  final String title;

  /// Credits granted at purchase and how many are spent. "2 of 4 left" is
  /// creditsTotal 4, creditsUsed 2.
  final int creditsTotal;
  final int creditsUsed;

  final DateTime purchasedUtc;

  /// When unspent credits lapse. Null = never. This is what a "expires 30 Jun"
  /// line reads from, and what makes lost value visible instead of silent.
  final DateTime? expiresUtc;

  final bool recordingAccess;
  final bool discussionThread;

  int get creditsLeft => (creditsTotal - creditsUsed).clamp(0, creditsTotal);
  bool get isExpired =>
      expiresUtc != null && DateTime.now().toUtc().isAfter(expiresUtc!);

  /// Can she book another slot against this right now?
  bool get canBook => creditsLeft > 0 && !isExpired;

  Entitlement copyWith({int? creditsUsed}) => Entitlement(
        id: id,
        offeringId: offeringId,
        stage: stage,
        title: title,
        creditsTotal: creditsTotal,
        creditsUsed: creditsUsed ?? this.creditsUsed,
        purchasedUtc: purchasedUtc,
        expiresUtc: expiresUtc,
        recordingAccess: recordingAccess,
        discussionThread: discussionThread,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'offeringId': offeringId,
        'stage': stage.name,
        'title': title,
        'creditsTotal': creditsTotal,
        'creditsUsed': creditsUsed,
        'purchasedUtc': purchasedUtc.toUtc().toIso8601String(),
        'expiresUtc': expiresUtc?.toUtc().toIso8601String(),
        'recordingAccess': recordingAccess,
        'discussionThread': discussionThread,
      };

  static Entitlement fromMap(Map data) => Entitlement(
        id: (data['id'] ?? '').toString(),
        offeringId: (data['offeringId'] ?? '').toString(),
        stage: _stageFrom(data['stage']),
        title: (data['title'] ?? '').toString(),
        creditsTotal: (data['creditsTotal'] as num?)?.toInt() ?? 0,
        creditsUsed: (data['creditsUsed'] as num?)?.toInt() ?? 0,
        purchasedUtc: DateTime.parse(data['purchasedUtc'].toString()).toUtc(),
        expiresUtc: data['expiresUtc'] == null
            ? null
            : DateTime.parse(data['expiresUtc'].toString()).toUtc(),
        recordingAccess: data['recordingAccess'] == true,
        discussionThread: data['discussionThread'] == true,
      );
}

// ---------------------------------------------------------------------------
//  Booking — one claimed slot (a row in her history)
// ---------------------------------------------------------------------------

/// One slot the parent has claimed. Denormalised on purpose — title and start
/// time are copied in so the history and reminders survive the catalogue
/// changing underneath them, and so "my bookings" needs no joins to render.
@immutable
class Booking {
  const Booking({
    required this.id,
    required this.offeringId,
    required this.slotId,
    required this.stage,
    required this.title,
    required this.startsUtc,
    required this.durationMin,
    required this.status,
    required this.bookedUtc,
    this.joinUrl,
  });

  final String id;
  final String offeringId;
  final String slotId;

  /// The tag — how this row is filed in the one cross-stage history.
  final ServiceStage stage;

  final String title;
  final DateTime startsUtc;
  final int durationMin;
  final BookingStatus status;
  final DateTime bookedUtc;

  /// Copied from the slot at booking time. Null until the live-call provider is
  /// wired; a UI shows "link coming" rather than a dead button.
  final String? joinUrl;

  DateTime get endsUtc => startsUtc.add(Duration(minutes: durationMin));
  bool get isUpcoming => status == BookingStatus.upcoming;

  /// True in the window where a "Join" affordance should be live — from ten
  /// minutes before start until the session ends.
  bool joinableAt(DateTime now) {
    final u = now.toUtc();
    return status == BookingStatus.upcoming &&
        u.isAfter(startsUtc.subtract(const Duration(minutes: 10))) &&
        u.isBefore(endsUtc);
  }

  Booking copyWith({BookingStatus? status, String? joinUrl}) => Booking(
        id: id,
        offeringId: offeringId,
        slotId: slotId,
        stage: stage,
        title: title,
        startsUtc: startsUtc,
        durationMin: durationMin,
        status: status ?? this.status,
        bookedUtc: bookedUtc,
        joinUrl: joinUrl ?? this.joinUrl,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'offeringId': offeringId,
        'slotId': slotId,
        'stage': stage.name,
        'title': title,
        'startsUtc': startsUtc.toUtc().toIso8601String(),
        'durationMin': durationMin,
        'status': status.name,
        'bookedUtc': bookedUtc.toUtc().toIso8601String(),
        'joinUrl': joinUrl,
      };

  static Booking fromMap(Map data) => Booking(
        id: (data['id'] ?? '').toString(),
        offeringId: (data['offeringId'] ?? '').toString(),
        slotId: (data['slotId'] ?? '').toString(),
        stage: _stageFrom(data['stage']),
        title: (data['title'] ?? '').toString(),
        startsUtc: DateTime.parse(data['startsUtc'].toString()).toUtc(),
        durationMin: (data['durationMin'] as num?)?.toInt() ?? 0,
        status: BookingStatus.values.firstWhere(
          (s) => s.name == data['status'],
          orElse: () => BookingStatus.upcoming,
        ),
        bookedUtc: DateTime.parse(data['bookedUtc'].toString()).toUtc(),
        joinUrl: data['joinUrl']?.toString(),
      );
}

ServiceStage _stageFrom(Object? v) => ServiceStage.values.firstWhere(
      (s) => s.name == v,
      orElse: () => ServiceStage.parenting,
    );
