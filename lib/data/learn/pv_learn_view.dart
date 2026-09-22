// =============================================================================
//  PvOfferingView — the ONE shape every learning page reads
// -----------------------------------------------------------------------------
//  Built 2026-09-20 from the Mobbin learning audit (docs/LEARNING-AUDIT.md).
//
//  The booking engine (`lib/booking/`) already reduces every paid thing to one
//  `Offering`. What it does not carry is what a PAGE needs to show one — the
//  blurb, the expert, the curriculum, the week cards, the facts, the proof.
//  That lived in three display models (`LearningProgram`, `PrepProgram`,
//  `YogaClass`) plus `Expert`, `Specialist`, `TtcOffering` and the TTC garbh
//  course, each with its own page. Twenty-four screens for four kinds.
//
//  This file is the display contract. The adapters in `pv_learn_adapters.dart`
//  build one of these from any source model; the screens in
//  `lib/screens/learn/` read only this. A new source (a Directus row, a
//  doctor-hosted class from ParentVeda+) is one more adapter, never one more
//  page.
//
//  ⚠️ `kind` IS A DISPLAY FACT, NOT THE ENGINE'S. `OfferingKind` decides money
//  and slots (a recorded course is not bookable). `PvLearnKind` decides what
//  the page shows (a recorded course has a curriculum). They agree most of the
//  time and the adapter is where they are reconciled.
//
//  The same move as the store (`PvProduct` over three catalogues) and You (the
//  stage changes a section's content, never the skeleton).
// =============================================================================

import 'package:flutter/widgets.dart';

import '../../booking/booking_models.dart';
import '../../screens/learn/pv_learn_art.dart';
import '../../experts/expert.dart';
import '../../services/life_stage_store.dart';

/// The four things a parent can learn from, plus the pack (yoga: buy N,
/// spend on classes). Five words, one page.
enum PvLearnKind { course, masterclass, cohort, consult, classPack }

extension PvLearnKindCopy on PvLearnKind {
  /// Singular, as a tag on a card.
  String get label => switch (this) {
    PvLearnKind.course => 'Course',
    PvLearnKind.masterclass => 'Masterclass',
    PvLearnKind.cohort => 'Cohort',
    PvLearnKind.consult => '1:1 consult',
    PvLearnKind.classPack => 'Class pack',
  };

  /// Plural, as a filter pill.
  String get plural => switch (this) {
    PvLearnKind.course => 'Courses',
    PvLearnKind.masterclass => 'Masterclasses',
    PvLearnKind.cohort => 'Cohorts',
    PvLearnKind.consult => 'Consults',
    PvLearnKind.classPack => 'Class packs',
  };

  /// The one verb on the sticky bar when she does not own it yet. The audit's
  /// §4.2 row J — a course starts, a seat is reserved, a cohort is joined, a
  /// consult shows availability.
  String get verb => switch (this) {
    PvLearnKind.course => 'Start the course',
    PvLearnKind.masterclass => 'Reserve a seat',
    PvLearnKind.cohort => 'Join the cohort',
    PvLearnKind.consult => 'See availability',
    PvLearnKind.classPack => 'Get the pack',
  };
}

/// One lesson of a recorded thing. `open` overrides the default player — the
/// TTC garbh course teaches by running its practice players, so its sessions
/// open their own screen rather than a film.
class PvLearnLesson {
  const PvLearnLesson({
    required this.id,
    required this.title,
    this.minutes = 0,
    this.blurb,
    this.locked = false,
    this.videoUrl,
    this.open,
  });
  final String id;
  final String title;
  final int minutes;
  final String? blurb;
  final bool locked;

  /// The film, when one exists. None does yet (the video engine is per
  /// watch-library id); kept so the day it does is a data edit.
  final String? videoUrl;
  final void Function(BuildContext)? open;
}

/// One live block — a cohort week, a masterclass evening, a pack's rhythm.
class PvLearnSession {
  const PvLearnSession({
    required this.label,
    required this.title,
    this.when = '',
    this.points = const [],
  });
  final String label;
  final String title;
  final String when;
  final List<String> points;
}

/// One of the four facts under the title. Label small, value large.
class PvLearnFact {
  const PvLearnFact(this.value, this.label);
  final String value;
  final String label;
}

/// One trust row: a drawn mark, a bold line, a quiet line. Three per page.
///
/// ⚠️ A MARK, NOT AN `IconData` — 2026-09-22. These rows shipped with
/// Material glyphs and the user caught it on the walk: every other area of
/// this app draws its own (`PvLearnArt`, and the six families before it).
class PvLearnTrust {
  const PvLearnTrust(this.mark, this.title, this.line);
  final PvLearnMark mark;
  final String title;
  final String line;
}

class PvLearnReview {
  const PvLearnReview({
    required this.name,
    required this.who,
    required this.quote,
    this.stars = 5,
  });
  final String name;
  final String who;
  final String quote;
  final int stars;
}

class PvLearnFaq {
  const PvLearnFaq(this.q, this.a);
  final String q;
  final String a;
}

/// Who teaches or sees her. `expert` is the roster record when one exists —
/// then the card opens the one doctor page (`openExpertProfile`). Without
/// it the card is informational: a name and a role, no door.
class PvLearnExpert {
  const PvLearnExpert({
    required this.id,
    required this.name,
    required this.role,
    this.bio = '',
    this.expert,
  });
  final String id;
  final String name;
  final String role;
  final String bio;
  final Expert? expert;

  String get firstName {
    final n = name.replaceAll('Dr. ', '').replaceAll('Dr ', '').trim();
    return n.isEmpty ? name : n.split(' ').first;
  }
}

@immutable
class PvOfferingView {
  const PvOfferingView({
    required this.id,
    required this.stage,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.about,
    required this.expert,
    required this.hue,
    this.cover,
    this.offering,
    this.priceMinor = 0,
    this.priceNote,
    this.topics = const [],
    this.facts = const [],
    this.takeaways = const [],
    this.lessons = const [],
    this.sessions = const [],
    this.rhythm = const [],
    this.startLabel,
    this.seatsLeft,
    this.durationLabel = '',
    this.rating,
    this.reviewsLabel = '',
    this.reviews = const [],
    this.faqs = const [],
    this.prepare = const [],
    this.recordingIncluded = false,
    this.featured = false,
    this.recency = 0,
  });

  /// The catalogue id — what facades look up by, and what `Offering.catalogId`
  /// points at. Stable across sources.
  final String id;
  final LifeStage stage;
  final PvLearnKind kind;
  final String title;
  final String subtitle;
  final String about;
  final PvLearnExpert expert;

  /// The cover tint when there is no photo, and the tint behind one.
  final double hue;

  /// A photo of the subject, or null for the honest cover block.
  final String? cover;

  /// The engine's view of the same thing. Null for a free recorded thing
  /// (nothing to buy, nothing to book) — the page then only plays.
  final Offering? offering;
  final int priceMinor;
  final String? priceNote;
  final List<String> topics;

  /// The four under the title. The adapter fills them per kind.
  final List<PvLearnFact> facts;
  final List<String> takeaways;

  /// Recorded structure — courses and recorded masterclasses.
  final List<PvLearnLesson> lessons;

  /// Live structure — cohort weeks, a masterclass agenda.
  final List<PvLearnSession> sessions;

  /// The live rhythm in words ("Mon and Thu · 8–9 pm IST").
  final List<String> rhythm;
  final String? startLabel;
  final int? seatsLeft;
  final String durationLabel;
  final double? rating;
  final String reviewsLabel;
  final List<PvLearnReview> reviews;
  final List<PvLearnFaq> faqs;

  /// What to have ready — the Booked page's "prepare" list.
  final List<String> prepare;
  final bool recordingIncluded;
  final bool featured;
  final int recency;

  bool get isFree => priceMinor <= 0;
  bool get isLive =>
      kind == PvLearnKind.cohort ||
      kind == PvLearnKind.consult ||
      kind == PvLearnKind.classPack ||
      (kind == PvLearnKind.masterclass && sessions.isNotEmpty);
  bool get isRecorded => !isLive;
  int get totalMinutes => lessons.fold(0, (a, l) => a + l.minutes);

  String get priceLabel {
    if (isFree) return 'Free';
    final r = priceMinor ~/ 100;
    final s = r.toString();
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '₹${parts.join(',')},$last3';
  }

  /// "per session" / "per class" / "once" — what the price buys.
  String get priceUnit => switch (kind) {
    PvLearnKind.consult => 'per session',
    PvLearnKind.classPack => 'for the pack',
    _ => 'once',
  };
}
