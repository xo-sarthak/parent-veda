// =============================================================================
//  pp_learning_data - unified "Courses & Masterclasses" catalogue (parenting)
// -----------------------------------------------------------------------------
//  One content model behind the merged Learning section. It folds the three old,
//  separate funnels - documentary/focused Courses, live Cohort Courses, and
//  Masterclasses - into a single `LearningProgram` list, keyed to a named
//  instructor (Expert) so tapping any face opens their profile and any card can
//  show "more by this instructor".
//
//  The old `Course`/`CourseLesson` model (pp_courses_data.dart) is KEPT and
//  WRAPPED: a recorded course program carries a `courseId`, so the rich lesson
//  detail (CourseDetailScreen / CourseLessonScreen) still works unchanged and the
//  "Go deeper · Course" rows keep resolving. This file only adds the unified
//  layer on top. Local/mock data; no store needed (catalogue is fixed).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_courses_data.dart';
import 'pp_experts_data.dart';

// ---- kinds & lifecycle ------------------------------------------------------

/// The three things a parent can learn from - the merge of the old three tabs.
enum LearningKind { liveCohort, recordedCourse, masterclass }

/// Where a program sits in its selling / delivery lifecycle. Drives the CTA.
///   reserveOpen - not started, reserve a seat / pre-book
///   available   - buyable now, or (recorded) ready to watch, or (cohort) joined & started
///   ongoing     - a live cohort mid-run: seats closed, "in progress"
///   completed   - a live event that has already happened (recording flow)
enum LearningStatus { reserveOpen, available, ongoing, completed }

extension LearningKindX on LearningKind {
  String get label => switch (this) {
        LearningKind.liveCohort => 'Live cohort',
        LearningKind.recordedCourse => 'Recorded course',
        LearningKind.masterclass => 'Masterclass',
      };

  /// Short label for the filter pills.
  String get filterLabel => switch (this) {
        LearningKind.liveCohort => 'Live cohorts',
        LearningKind.recordedCourse => 'Recorded courses',
        LearningKind.masterclass => 'Masterclasses',
      };
}

// ---- schedule ---------------------------------------------------------------

/// One live block in a program's schedule (a cohort week, or a masterclass
/// evening). Only live programs populate these.
class LearningSession {
  const LearningSession({
    required this.label,
    required this.title,
    required this.when,
    this.points = const [],
  });

  final String label; // "Week 1" / "Session"
  final String title; // "Foundations"
  final String when; // "Mon 21 & Thu 24 Jul · 8-9pm"
  final List<String> points;
}

// ---- the program ------------------------------------------------------------

class LearningProgram {
  const LearningProgram({
    required this.id,
    required this.kind,
    required this.instructorId,
    required this.title,
    required this.subtitle,
    required this.topics,
    required this.accent,
    required this.price,
    required this.status,
    this.priceNote = 'free on ParentVeda+',
    this.isLiveScheduled = false,
    this.startLabel,
    this.sessionTimes = const [],
    this.sessions = const [],
    this.seatsLeft,
    this.courseId,
    this.durationLabel = '',
    this.about = '',
    this.rating = 4.9,
    this.reviewsLabel = '',
    this.covers = const [],
    this.takeaways = const [],
    this.featured = false,
    this.recency = 0,
  });

  final String id;
  final LearningKind kind;
  final String instructorId; // -> Expert (pp_experts_data)

  final String title;
  final String subtitle;
  final List<String> topics; // common topic tags, also drive the chip filters
  final Color accent;

  final String price; // "₹1,499"
  final String priceNote; // "free on ParentVeda+" etc.
  final LearningStatus status;

  /// Live scheduling. When true the program "runs live week-on-week, and the
  /// recording is only for parents who joined live" - so there is no
  /// buy-recorded-later path (the CTA becomes "Join live").
  final bool isLiveScheduled;
  final String? startLabel; // "Next cohort · Sun 21 Jul" / "LIVE · Sun 13 Jul, 8pm"
  final List<String> sessionTimes; // the live rhythm ("Mon & Thu · 8-9pm IST")
  final List<LearningSession> sessions; // week-by-week / session breakdown
  final int? seatsLeft; // cohorts only

  /// Recorded courses wrap the old `Course` model for their lesson detail.
  final String? courseId;

  final String durationLabel; // "90 min live" / "2 weeks" / "5 lessons · ~50 min"
  final String about;
  final double rating;
  final String reviewsLabel; // "1,020 parents"
  final List<String> covers; // "what this covers"
  final List<String> takeaways; // "what you'll walk away with"

  final bool featured; // pinned to the top of the grid
  final int recency; // higher = newer; ties broken by list order

  // --- derived -----------------------------------------------------------
  Expert get instructor => expertById(instructorId);

  /// The wrapped focused course, when this is a recorded course with lessons.
  Course? get course => courseId == null ? null : courseById(courseId!);

  bool get isCohort => kind == LearningKind.liveCohort;

  /// True for anything that happens live (a cohort, or a live-scheduled class).
  bool get isLive => kind == LearningKind.liveCohort || isLiveScheduled;

  /// Short tag shown on the thumbnail corner.
  String get heroTag {
    if (kind == LearningKind.liveCohort) return startLabel ?? 'Live cohort';
    if (isLiveScheduled) return startLabel ?? 'Live';
    return durationLabel.isNotEmpty ? durationLabel : 'Recorded';
  }
}

// ---- CTA business logic -----------------------------------------------------

/// The resolved primary action for a program, so a screen never hand-rolls the
/// rules. Encodes the full lifecycle across the three kinds.
class LearningCta {
  const LearningCta(
    this.label, {
    this.enabled = true,
    this.watch = false,
    this.showReschedule = false,
    this.note,
  });

  final String label;
  final bool enabled; // false = locked (e.g. cohort in progress)
  final bool watch; // "Watch now" = play flow, not a pay sheet
  final bool showReschedule; // live programs offer a reschedule affordance
  final String? note; // small caption under the button
}

/// The single source of truth for "what button does this program show".
LearningCta ctaFor(LearningProgram p) {
  switch (p.kind) {
    // ---- live cohorts -----------------------------------------------------
    case LearningKind.liveCohort:
      switch (p.status) {
        case LearningStatus.reserveOpen:
          return const LearningCta('Reserve your seat', showReschedule: true, note: 'Pick a start date that suits you');
        case LearningStatus.available:
          return const LearningCta('Start', showReschedule: true, note: "You're in - your cohort has begun");
        case LearningStatus.ongoing:
          return const LearningCta('Cohort in progress', enabled: false, note: 'This run has started - reserve the next one');
        case LearningStatus.completed:
          return const LearningCta('View recordings', watch: true, note: 'Yours to keep');
      }

    // ---- masterclasses ----------------------------------------------------
    case LearningKind.masterclass:
      if (p.isLiveScheduled) {
        // Runs live; recordings only for parents who joined live -> no buy-recorded.
        switch (p.status) {
          case LearningStatus.reserveOpen:
            return const LearningCta('Reserve', showReschedule: true, note: 'Live seat - the recording is only for attendees');
          case LearningStatus.available:
          case LearningStatus.ongoing:
            return const LearningCta('Join live', showReschedule: true, note: 'Recording goes only to parents who join live');
          case LearningStatus.completed:
            return const LearningCta('Live only - missed', enabled: false, note: 'This was live-only; catch the next live run');
        }
      }
      // Recorded masterclass: reserve -> buy -> buy recorded.
      switch (p.status) {
        case LearningStatus.reserveOpen:
          return const LearningCta('Reserve', note: 'Pre-book before it opens');
        case LearningStatus.available:
        case LearningStatus.ongoing:
          return const LearningCta('Buy', note: 'Recording lands in your library');
        case LearningStatus.completed:
          return const LearningCta('Buy recorded', note: 'Watch anytime, yours forever');
      }

    // ---- recorded courses -------------------------------------------------
    case LearningKind.recordedCourse:
      switch (p.status) {
        case LearningStatus.reserveOpen:
          return const LearningCta('Reserve', note: 'Notify me when it opens');
        case LearningStatus.available:
        case LearningStatus.ongoing:
        case LearningStatus.completed:
          return const LearningCta('Watch now', watch: true, note: 'Free with ParentVeda+ · lifetime access');
      }
  }
}

// ---- the catalogue ----------------------------------------------------------

const Color _violet = Color(0xFF6A30B6);
const Color _amber = Color(0xFFC98A2B);
const Color _rose = Color(0xFFFF5A79);
const Color _blue = Color(0xFF3E6DA6);
const Color _teal = Color(0xFF2E8B8B);
const Color _plum = Color(0xFF8E4585);

/// The common topic vocabulary - these back the clickable filter chips on the
/// home. Every program tags itself from this list so the chips actually filter.
const List<String> kLearningTopics = [
  'Sleep',
  'Feeding & Solids',
  'Development',
  'Play & Brain',
  'Language',
  'Motor Skills',
  'Safety',
  'Mindfulness',
  'Newborn',
];

const List<LearningProgram> kLearningPrograms = [
  // ===== FLAGSHIP recorded course (documentary) ==========================
  LearningProgram(
    id: 'flagship',
    kind: LearningKind.recordedCourse,
    instructorId: 'ananya',
    title: 'The Complete Parenting Guide',
    subtitle: 'Pregnancy through age 12 - every stage, taught properly, once.',
    topics: ['Development', 'Newborn', 'Sleep'],
    accent: _violet,
    price: '₹4,999',
    status: LearningStatus.available,
    durationLabel: '140+ modules',
    about:
        'A documentary-style course that unlocks as your child grows and stays yours for life. You only ever see the modules for your child\'s stage; earlier and later ones are always a tap away. Told through ParentVeda\'s own animated guides, scripted from research and approved by paediatricians & child psychologists.',
    rating: 4.9,
    reviewsLabel: '1,240 parents',
    covers: [
      "Read your baby's development, stage by stage",
      'Handle sleep, feeding and fussiness with real confidence',
      'Tell a normal phase from a genuine red flag',
      'Build language, play and secure attachment early',
    ],
    featured: true,
    recency: 100,
  ),

  // ===== LIVE MASTERCLASS (the featured live event) =======================
  LearningProgram(
    id: 'mc_sleepreg',
    kind: LearningKind.masterclass,
    instructorId: 'ananya',
    title: 'The 4-Month Sleep Regression, Solved',
    subtitle: "Why it happens, why it's temporary, and exactly what to do tonight.",
    topics: ['Sleep', 'Development'],
    accent: _rose,
    price: '₹1,499',
    status: LearningStatus.reserveOpen,
    isLiveScheduled: true,
    startLabel: 'LIVE · Sun 13 Jul, 8pm',
    sessionTimes: ['Sun 13 Jul · 8:00-9:30pm IST'],
    sessions: [
      LearningSession(
        label: 'Live evening',
        title: 'One focused sitting + live Q&A',
        when: 'Sun 13 Jul · 8:00-9:30pm IST',
        points: [
          'Why sleep cycles mature at 4 months - the science, simply',
          'Building a wind-down routine that actually sticks',
          'A live Q&A - bring your exact situation',
        ],
      ),
    ],
    durationLabel: '90 min live',
    about:
        "One focused evening that gives you a plan for your baby's upside-down sleep. Gentle, responsive settling - never cry-it-out. The live session is in English; the recording (for attendees) includes a Hindi voiceover.",
    rating: 4.9,
    reviewsLabel: '1,020 parents',
    covers: [
      'Why sleep cycles mature at 4 months - the science, simply.',
      'The link between the 4-month shift and the sleep regression.',
      'Building a wind-down routine that actually sticks.',
      'Drowsy-but-awake, and gentle no-cry-it-out settling.',
      'Night wakings and naps in Indian joint-family homes.',
      'A live Q&A - bring your exact situation.',
    ],
    takeaways: [
      'A calm, repeatable bedtime routine you can start tonight.',
      'The reassurance that this phase is normal - and ends.',
      'A printable one-page plan, yours to keep.',
    ],
    featured: true,
    recency: 99,
  ),

  // ===== LIVE COHORT (featured) ===========================================
  LearningProgram(
    id: 'co_sleep',
    kind: LearningKind.liveCohort,
    instructorId: 'meher',
    title: 'Sleep Bootcamp',
    subtitle: 'Two guided weeks with a small group of parents at exactly your stage.',
    topics: ['Sleep'],
    accent: _blue,
    price: '₹8,999',
    priceNote: 'or ParentVeda+ Pro',
    status: LearningStatus.reserveOpen,
    startLabel: 'Next cohort · Sun 21 Jul',
    seatsLeft: 8,
    sessionTimes: ['Mondays & Thursdays · 8-9pm IST'],
    sessions: [
      LearningSession(
        label: 'Week 1',
        title: 'Foundations',
        when: 'Mon 21 & Thu 24 Jul · 8-9pm',
        points: [
          "How your baby's sleep actually works at this age",
          'Building a wind-down routine that sticks',
          'The sleep environment - light, sound, temperature',
        ],
      ),
      LearningSession(
        label: 'Week 2',
        title: 'Practice & troubleshoot',
        when: 'Mon 28 & Thu 31 Jul · 8-9pm',
        points: [
          'Drowsy-but-awake, and gentle settling',
          'Night wakings and early mornings',
          "Your baby's personal plan - reviewed live",
        ],
      ),
    ],
    durationLabel: '2 weeks · live',
    about:
        'A real plan for your baby, built together with a paediatric sleep consultant and other parents at exactly your stage - never alone at 2am. Four live group calls (all recorded and yours to keep), a plan built around your baby, and a private group that stays with you after.',
    rating: 4.9,
    reviewsLabel: '640 parents',
    takeaways: [
      'A sleep plan built around your baby, not a template.',
      'Four live calls, recorded and yours to keep.',
      'A private group that stays with you after it ends.',
    ],
    featured: true,
    recency: 98,
  ),

  // ===== MORE LIVE COHORTS ================================================
  LearningProgram(
    id: 'co_weaning',
    kind: LearningKind.liveCohort,
    instructorId: 'ritu',
    title: 'Confident Weaning',
    subtitle: 'Four weeks from first tastes to family meals, Indian-first.',
    topics: ['Feeding & Solids'],
    accent: _amber,
    price: '₹12,999',
    priceNote: 'or ParentVeda+ Pro',
    status: LearningStatus.reserveOpen,
    startLabel: 'Starts 1 Aug · opens at 6 months',
    seatsLeft: 14,
    sessionTimes: ['Tuesdays · 7-8pm IST'],
    durationLabel: '4 weeks · live',
    about:
        'A calm, mess-friendly path through starting solids with a paediatric nutritionist and a small group. Indian-first foods, an allergy-safe order, and portions that suit real joint kitchens.',
    rating: 4.8,
    reviewsLabel: '350 parents',
    recency: 90,
  ),
  LearningProgram(
    id: 'co_calm',
    kind: LearningKind.liveCohort,
    instructorId: 'kabir',
    title: 'Calm Parent, Calm Baby',
    subtitle: 'Six weeks of mindfulness for the fourth trimester.',
    topics: ['Mindfulness'],
    accent: _plum,
    price: '₹24,999',
    priceNote: 'or ParentVeda+ Pro',
    status: LearningStatus.reserveOpen,
    startLabel: 'Starts 18 Aug',
    seatsLeft: 20,
    sessionTimes: ['Saturdays · 10-11am IST'],
    durationLabel: '6 weeks · live',
    about:
        'A gentle six-week group for the fourth trimester - nervous-system basics, guilt-free rest, and a calmer home. Led with a child psychologist, in a small, honest circle of parents.',
    rating: 4.9,
    reviewsLabel: '210 parents',
    recency: 85,
  ),
  // an in-progress cohort - demonstrates the locked "Cohort in progress" CTA
  LearningProgram(
    id: 'co_gentlenights',
    kind: LearningKind.liveCohort,
    instructorId: 'meher',
    title: 'Gentle Nights · July cohort',
    subtitle: 'A running cohort - seats are closed until the next intake.',
    topics: ['Sleep'],
    accent: _blue,
    price: '₹8,999',
    status: LearningStatus.ongoing,
    startLabel: 'In progress · started 7 Jul',
    seatsLeft: 0,
    sessionTimes: ['Mondays & Thursdays · 8-9pm IST'],
    durationLabel: '2 weeks · live',
    about:
        'This cohort has already begun, so seats are closed. Reserve the next Sleep Bootcamp intake to join a fresh small group at your stage.',
    rating: 4.9,
    reviewsLabel: '640 parents',
    recency: 60,
  ),

  // ===== RECORDED MASTERCLASSES ==========================================
  LearningProgram(
    id: 'mc_solids',
    kind: LearningKind.masterclass,
    instructorId: 'ritu',
    title: 'Starting solids without the stress',
    subtitle: 'Indian-first foods, an allergy-safe order, and real portions.',
    topics: ['Feeding & Solids'],
    accent: _amber,
    price: '₹999',
    status: LearningStatus.available,
    durationLabel: '75 min',
    about:
        'A recorded masterclass that makes first solids calm and mess-friendly - no fads, just a clear, allergy-safe order and portions that suit real families.',
    rating: 4.8,
    reviewsLabel: '350 parents',
    covers: [
      'When your baby is truly ready for solids.',
      'An Indian-first, allergy-safe order to introduce foods.',
      'Portions and textures, stage by stage.',
      'Gagging vs choking - what to actually do.',
    ],
    recency: 80,
  ),
  LearningProgram(
    id: 'mc_wonderweeks',
    kind: LearningKind.masterclass,
    instructorId: 'kabir',
    title: 'Understanding the fussy stretches',
    subtitle: 'Why a hard week often comes before a new skill, in plain language.',
    topics: ['Development'],
    accent: _violet,
    price: '₹2,499',
    status: LearningStatus.available,
    durationLabel: '2 hr',
    about:
        'A recorded masterclass on why babies often have a hard few days before a new skill appears - what is well evidenced, what is not, and how to tell an ordinary fussy stretch from something worth a call to your paediatrician.',
    rating: 4.8,
    reviewsLabel: '410 parents',
    covers: [
      'Why fussiness often spikes before a new skill.',
      'Why fixed "leap" week charts do not hold up.',
      'How to support - not push - each phase.',
      'Telling an ordinary hard week from something to watch.',
    ],
    recency: 78,
  ),
  LearningProgram(
    id: 'mc_babyproof',
    kind: LearningKind.masterclass,
    instructorId: 'meera',
    title: 'Baby-proofing for joint families',
    subtitle: 'A room-by-room plan that works in a shared Indian home.',
    topics: ['Safety'],
    accent: _teal,
    price: '₹1,299',
    status: LearningStatus.available,
    durationLabel: '60 min',
    about:
        'A recorded, practical walkthrough of making a home safe - room by room, jargon-free, and built for joint-family setups where not everyone childproofs the same way.',
    rating: 4.7,
    reviewsLabel: '280 parents',
    covers: [
      'The room-by-room checklist you can use this weekend.',
      'Stairs, kitchens and balconies in Indian homes.',
      'Getting grandparents on the same page.',
      'A simple first-aid corner every home needs.',
    ],
    recency: 76,
  ),
  // a completed recorded masterclass - demonstrates the "Buy recorded" CTA
  LearningProgram(
    id: 'mc_first40',
    kind: LearningKind.masterclass,
    instructorId: 'neha',
    title: 'The First 40 Days',
    subtitle: 'A recorded evening on surviving - and savouring - the newborn weeks.',
    topics: ['Newborn'],
    accent: _rose,
    price: '₹1,199',
    status: LearningStatus.completed,
    durationLabel: '80 min',
    about:
        'This was a live evening; the recording is now in the library. Feeding rhythms, safe sleep basics, and the honest emotional map of the fourth trimester - gentle and reassuring.',
    rating: 4.9,
    reviewsLabel: '312 parents',
    covers: [
      'Feeding rhythms in the first six weeks.',
      'Safe sleep, simply.',
      'Recovery for the mother, too.',
      'When to call your paediatrician.',
    ],
    recency: 55,
  ),

  // ===== RECORDED FOCUSED COURSES (wrap the old Course model) =============
  LearningProgram(
    id: 'rc_playbrain',
    kind: LearningKind.recordedCourse,
    instructorId: 'ananya',
    title: 'Play & Brain',
    subtitle: 'How the right play grows a four-month-old mind.',
    topics: ['Play & Brain', 'Development'],
    accent: _violet,
    price: '₹1,499',
    status: LearningStatus.available,
    courseId: 'playbrain',
    durationLabel: '5 lessons · ~50 min',
    about:
        'A short, practical course on what your baby is working out right now - cause and effect, object permanence, hand-eye coordination - and the simple, everyday play that supports each one.',
    rating: 4.9,
    reviewsLabel: '820 parents',
    recency: 74,
  ),
  LearningProgram(
    id: 'rc_motor',
    kind: LearningKind.recordedCourse,
    instructorId: 'meher',
    title: 'Motor Skills',
    subtitle: 'The road from tummy time to those first steps.',
    topics: ['Motor Skills', 'Development'],
    accent: _amber,
    price: '₹1,499',
    status: LearningStatus.available,
    courseId: 'motor',
    durationLabel: '4 lessons · ~42 min',
    about:
        'Every big movement builds on the last. This course walks the physical journey - head control, rolling, sitting, crawling - with the gentle, joyful practice that helps each one arrive in its own time.',
    rating: 4.8,
    reviewsLabel: '540 parents',
    recency: 72,
  ),
  LearningProgram(
    id: 'rc_language',
    kind: LearningKind.recordedCourse,
    instructorId: 'kabir',
    title: 'Language & Communication',
    subtitle: 'The conversation that starts long before the first word.',
    topics: ['Language', 'Development'],
    accent: _rose,
    price: '₹1,499',
    status: LearningStatus.available,
    courseId: 'language',
    durationLabel: '4 lessons · ~38 min',
    about:
        'Your baby is learning language now, in the everyday back-and-forth. This course shows how narration, "serve and return", and simple songs wire the brain for talking - months before real words appear.',
    rating: 4.8,
    reviewsLabel: '470 parents',
    recency: 70,
  ),
  LearningProgram(
    id: 'rc_sleep',
    kind: LearningKind.recordedCourse,
    instructorId: 'meher',
    title: 'Baby Sleep, Understood',
    subtitle: 'A calm, no-cry course through the science of infant sleep.',
    topics: ['Sleep'],
    accent: _blue,
    price: '₹1,499',
    status: LearningStatus.available,
    courseId: 'sleep',
    durationLabel: '4 lessons · ~53 min',
    about:
        'A calm, no-cry course through the science of infant sleep and the 4-month shift. Learn what is actually happening, what genuinely helps, and how to build a wind-down your baby can rely on. (The self-paced companion to the live Sleep Bootcamp cohort.)',
    rating: 4.9,
    reviewsLabel: '910 parents',
    recency: 68,
  ),

  // ===== RECORDED COURSE, pre-launch - demonstrates the "Reserve" CTA =====
  LearningProgram(
    id: 'rc_specialneeds',
    kind: LearningKind.recordedCourse,
    instructorId: 'kabir',
    title: 'Parenting a Child with Special Needs',
    subtitle: 'An autism-focused course, made with developmental specialists.',
    topics: ['Development'],
    accent: _plum,
    price: '₹4,999',
    status: LearningStatus.reserveOpen,
    durationLabel: 'Opening soon',
    about:
        'An autism-focused course built with developmental specialists - with ADHD & learning differences coming next. Reserve now to be notified the moment it opens.',
    rating: 4.9,
    reviewsLabel: 'New',
    recency: 50,
  ),
];

// ---- lookups & helpers ------------------------------------------------------

/// A program by id; falls back to the flagship so callers never crash.
LearningProgram programById(String id) =>
    kLearningPrograms.firstWhere((p) => p.id == id, orElse: () => kLearningPrograms.first);

/// Every program by a given instructor, newest first - for the "More by
/// {instructor}" footer on a detail page, and for the Watch channel linkage.
/// Pass [exclude] to drop the program you're already looking at.
List<LearningProgram> programsByInstructor(String instructorId, {String? exclude}) {
  final list = kLearningPrograms.where((p) => p.instructorId == instructorId && p.id != exclude).toList();
  list.sort((a, b) => b.recency.compareTo(a.recency));
  return list;
}

/// The full catalogue in display order (featured first, then by recency).
List<LearningProgram> learningCatalogue() {
  final list = [...kLearningPrograms];
  list.sort((a, b) {
    if (a.featured != b.featured) return a.featured ? -1 : 1;
    return b.recency.compareTo(a.recency);
  });
  return list;
}

/// Filter the catalogue by an optional kind, topic, instructor and free-text
/// query. Any argument left null is ignored. Preserves display order.
List<LearningProgram> filterLearning({
  LearningKind? kind,
  String? topic,
  String? instructorId,
  String? query,
}) {
  final q = (query ?? '').trim().toLowerCase();
  return learningCatalogue().where((p) {
    if (kind != null && p.kind != kind) return false;
    if (topic != null && !p.topics.contains(topic)) return false;
    if (instructorId != null && p.instructorId != instructorId) return false;
    if (q.isNotEmpty) {
      final hay = [
        p.title,
        p.subtitle,
        p.instructor.name,
        ...p.topics,
      ].join(' ').toLowerCase();
      if (!hay.contains(q)) return false;
    }
    return true;
  }).toList();
}
