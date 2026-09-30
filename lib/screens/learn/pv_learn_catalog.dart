// =============================================================================
//  PvLearnCatalog — every learnable thing, as one shape, from three catalogues
// -----------------------------------------------------------------------------
//  The adapters. Each takes a source model the stages already own and builds
//  a `PvOfferingView`; the catalogue merges them and answers three questions
//  the screens ask: everything for a stage, one by id, everything by an
//  expert.
//
//  Sits in `screens/` rather than `data/` because two adapters hold
//  `BuildContext` closures (the TTC garbh course's sessions open their own
//  practice players) — a file that pushes routes is screen code, the same
//  reason `pv_you_content.dart` lives where it does.
//
//  ⚠️ NOTHING HERE IS A SECOND CATALOGUE. The source lists stay the truth:
//  `mergedLearningPrograms()` (bundled + Directus), `kPrepPrograms`,
//  `kYogaClasses`, `mergedExperts()`, `kSpecialists`, `ttcOfferings`, the
//  garbh course. Add a programme there and it is on the Learn home with
//  nothing to wire — the same promise `BookingCatalog` makes for money.
//
//  ⚠️ THE ENGINE OFFERING IS LOOKED UP, NEVER REBUILT. `offering:` comes from
//  `BookingCatalog.instance.offeringForCatalog(id)`, so the price a page
//  shows is the price the engine charges, by construction.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_catalog.dart';
import '../../booking/booking_models.dart';
import '../../data/learn/pv_learn_images.dart';
import '../../data/learn/pv_learn_view.dart';
import '../../data/prepare_data.dart';
import '../../models/pv_product.dart' show PvStageCopy;
import '../../services/expert_store.dart';
import '../../services/life_stage_store.dart';
import '../../ttc/ttc_garbh_course.dart';
import '../../ttc/ttc_prepare_data.dart';
import '../post_pregnancy/pp_courses_data.dart';
import '../post_pregnancy/pp_experts_data.dart';
import '../post_pregnancy/pp_learning_data.dart';
import '../post_pregnancy/pp_yoga_data.dart';
import '../ttc/ttc_garbh_course_screen.dart' show TtcCourseSessionScreen;

/// The free garbh course's id IS the TTC catalogue's — `kTtcOfferingGarbhCourse`
/// — so the four places that push `TtcOfferingScreen` for it land on the
/// same view as the course tile, and the id never has two spellings.
const String kPvTtcGarbhCourseId = kTtcOfferingGarbhCourse;

class PvLearnCatalog {
  PvLearnCatalog._();
  static final PvLearnCatalog instance = PvLearnCatalog._();

  List<PvOfferingView>? _cache;

  /// Rebuilt on demand — Directus programmes and experts merge in at
  /// runtime, so this cannot be a const.
  List<PvOfferingView> get _all {
    if (_cache != null) return _cache!;
    final out = <PvOfferingView>[];
    for (final p in mergedLearningPrograms()) {
      out.add(_fromLearning(p));
    }
    for (final p in kPrepPrograms) {
      out.add(_fromPrep(p));
    }
    for (final y in kYogaClasses) {
      out.add(_fromYoga(y));
    }
    for (final e in mergedExperts()) {
      final v = _fromExpert(e);
      if (v != null) out.add(v);
    }
    for (final s in kSpecialists) {
      out.add(_fromSpecialist(s));
    }
    for (final o in ttcOfferings) {
      // The free course is the taught course, not a ₹0 masterclass.
      out.add(
        o.id == kTtcOfferingGarbhCourse ? _ttcGarbhCourse() : _fromTtc(o),
      );
    }
    return _cache = out;
  }

  /// Drop the cache when a source store changes (Directus merge landed).
  void invalidate() => _cache = null;

  List<PvOfferingView> all({LifeStage? stage, PvLearnKind? kind}) => _all
      .where((v) => stage == null || v.stage == stage.shopStage)
      .where((v) => kind == null || v.kind == kind)
      .toList(growable: false);

  PvOfferingView? byId(String id) {
    for (final v in _all) {
      if (v.id == id) return v;
    }
    return null;
  }

  /// By the engine's offering id — a booking row knows only that.
  PvOfferingView? byOfferingId(String offeringId) {
    for (final v in _all) {
      if (v.offering?.id == offeringId) return v;
    }
    return null;
  }

  /// What one person offers — the Expert page's tabs.
  List<PvOfferingView> forExpert(String expertId) => _all
      .where((v) => v.expert.id == expertId || v.expert.expert?.id == expertId)
      .toList(growable: false);

  // ---- adapters ---------------------------------------------------------------

  static double _hueOf(Color c) => HSLColor.fromColor(c).hue;

  static Offering? _engine(String catalogId) =>
      BookingCatalog.instance.offeringForCatalog(catalogId);

  static PvLearnExpert _expertFrom(
    Expert? e, {
    required String fallbackId,
    required String name,
    String role = '',
    String bio = '',
  }) {
    if (e != null) {
      return PvLearnExpert(
        id: e.id,
        name: e.name,
        role: e.credential,
        bio: e.why,
        expert: e,
      );
    }
    return PvLearnExpert(id: fallbackId, name: name, role: role, bio: bio);
  }

  static List<PvLearnReview> _expertReviews(Expert e) => [
    for (final r in e.reviews)
      PvLearnReview(name: r.$1, who: r.$2, quote: r.$3),
  ];

  /// ⚠️ THE NUMBER ONLY. The strip prints a value over its label, so
  /// "4 lessons" over "lessons" said it twice — the walk, 2026-09-22. The
  /// full phrase is still what a one-line card needs, so both exist.
  static String _lessonsFact(int n) => '$n';
  static String _lessonsLine(int n) => n == 1 ? '1 lesson' : '$n lessons';

  static String _minutesFact(int m) =>
      m >= 60 ? '${(m / 60).toStringAsFixed(m % 60 == 0 ? 0 : 1)} h' : '$m min';

  /// Parenting: `LearningProgram` (+ its `Course` for the curriculum).
  static PvOfferingView _fromLearning(LearningProgram p) {
    final kind = switch (p.kind) {
      LearningKind.recordedCourse => PvLearnKind.course,
      LearningKind.masterclass => PvLearnKind.masterclass,
      LearningKind.liveCohort => PvLearnKind.cohort,
    };
    final expert = expertByIdOrNull(p.instructorId);
    final course = p.courseId == null ? null : courseById(p.courseId!);
    final lessons = <PvLearnLesson>[
      if (course != null)
        for (var i = 0; i < course.lessons.length; i++)
          PvLearnLesson(
            id: '${course.id}_$i',
            title: course.lessons[i].title,
            minutes: course.lessons[i].minutes,
            locked: course.lessons[i].locked,
          )
      // A recorded course written as an outline only ("what this covers")
      // still has a structure: each line is a lesson, untimed. The flagship
      // guide is this today; the day its modules land, they replace this.
      else if (kind == PvLearnKind.course)
        for (var i = 0; i < p.covers.length; i++)
          PvLearnLesson(id: '${p.id}_c$i', title: p.covers[i]),
    ];
    final sessions = [
      for (final s in p.sessions)
        PvLearnSession(
          label: s.label,
          title: s.title,
          when: s.when,
          points: s.points,
        ),
    ];
    final live = p.isLiveScheduled || kind == PvLearnKind.cohort;
    final engine = _engine(p.id);
    final total = lessons.fold(0, (a, l) => a + l.minutes);
    final facts = switch (kind) {
      PvLearnKind.course => [
        PvLearnFact(
          lessons.isEmpty ? p.durationLabel : _lessonsFact(lessons.length),
          'lessons',
        ),
        if (total > 0) PvLearnFact(_minutesFact(total), 'in all'),
        const PvLearnFact('Recorded', 'watch anytime'),
        if (course != null) PvLearnFact(course.ageTag, 'for'),
      ],
      PvLearnKind.masterclass => [
        PvLearnFact(
          live ? (p.startLabel ?? 'Live') : 'Recorded',
          live ? 'when' : 'format',
        ),
        PvLearnFact(p.durationLabel, 'length'),
        if (p.seatsLeft != null)
          PvLearnFact('${p.seatsLeft}', 'seats left')
        else
          const PvLearnFact('Recording', 'included'),
        const PvLearnFact('English', 'language'),
      ],
      _ => [
        PvLearnFact(p.durationLabel, 'long'),
        if (p.sessionTimes.isNotEmpty)
          PvLearnFact(p.sessionTimes.first, 'live calls'),
        if (p.startLabel != null) PvLearnFact(p.startLabel!, 'starts'),
        if (p.seatsLeft != null) PvLearnFact('${p.seatsLeft}', 'seats left'),
      ],
    };
    return PvOfferingView(
      id: p.id,
      stage: LifeStage.parenting,
      kind: kind,
      title: p.title,
      subtitle: p.subtitle,
      about: p.about,
      expert: _expertFrom(
        expert,
        fallbackId: p.instructorId,
        name: p.instructorId,
      ),
      hue: _hueOf(p.accent),
      cover: pvLearnCoverFor(p.id, p.topics, kind),
      offering: engine,
      priceMinor: engine?.priceMinor ?? _minorOf(p.price),
      priceNote: p.priceNote.isEmpty ? null : p.priceNote,
      topics: p.topics,
      facts: facts.take(4).toList(),
      takeaways: p.takeaways.isNotEmpty ? p.takeaways : p.covers,
      lessons: lessons,
      sessions: sessions,
      rhythm: p.sessionTimes,
      startLabel: p.startLabel,
      seatsLeft: p.seatsLeft,
      durationLabel: p.durationLabel.isNotEmpty
          ? p.durationLabel
          : (kind == PvLearnKind.course && lessons.isNotEmpty
                ? _lessonsLine(lessons.length)
                : ''),
      rating: p.rating > 0 ? p.rating : null,
      reviewsLabel: p.reviewsLabel,
      reviews: expert == null ? const [] : _expertReviews(expert),
      recordingIncluded: kind == PvLearnKind.masterclass && !live,
      featured: p.featured,
      recency: p.recency,
    );
  }

  /// Pregnancy: `PrepProgram`. `LocalizedText.en` for identity, `.now` for
  /// display — the page shows what she reads, the id never moves.
  static PvOfferingView _fromPrep(PrepProgram p) {
    final kind = switch (p.kind) {
      PrepKind.course => PvLearnKind.course,
      PrepKind.masterclass => PvLearnKind.masterclass,
      PrepKind.cohort => PvLearnKind.cohort,
    };
    final expert = expertByName(p.instructorName.en);
    final lessons = [
      for (var i = 0; i < p.lessons.length; i++)
        PvLearnLesson(
          id: '${p.id}_$i',
          title: p.lessons[i].title.now,
          minutes: p.lessons[i].minutes,
          locked: p.lessons[i].locked,
        ),
      if (p.lessons.isEmpty && kind == PvLearnKind.course)
        for (var i = 0; i < p.covers.length; i++)
          PvLearnLesson(id: '${p.id}_c$i', title: p.covers[i].now),
    ];
    final sessions = [
      for (final s in p.sessions)
        PvLearnSession(
          label: s.label.now,
          title: s.title.now,
          when: s.when.now,
          points: [for (final x in s.points) x.now],
        ),
    ];
    final engine = _engine(p.id);
    final total = lessons.fold(0, (a, l) => a + l.minutes);
    final facts = switch (kind) {
      PvLearnKind.course => [
        PvLearnFact(
          lessons.isEmpty ? p.durationLabel.now : _lessonsFact(lessons.length),
          'lessons',
        ),
        if (total > 0) PvLearnFact(_minutesFact(total), 'in all'),
        const PvLearnFact('Recorded', 'watch anytime'),
        // Kept for revert: PvLearnFact('Pregnancy', 'for'). A pregnancy
        // course on the pregnancy stage telling her it is for pregnancy
        // spends a quarter of the strip on nothing.
      ],
      PvLearnKind.masterclass => [
        PvLearnFact(
          p.isLiveScheduled ? (p.startLabel?.now ?? 'Live') : 'Recorded',
          p.isLiveScheduled ? 'when' : 'format',
        ),
        PvLearnFact(p.durationLabel.now, 'length'),
        if (p.seatsLeft != null)
          PvLearnFact('${p.seatsLeft}', 'seats left')
        else
          const PvLearnFact('Recording', 'included'),
        const PvLearnFact('English', 'language'),
      ],
      _ => [
        PvLearnFact(p.durationLabel.now, 'long'),
        if (p.sessionTimes.isNotEmpty)
          PvLearnFact(p.sessionTimes.first.now, 'live calls'),
        if (p.startLabel != null) PvLearnFact(p.startLabel!.now, 'starts'),
        if (p.seatsLeft != null) PvLearnFact('${p.seatsLeft}', 'seats left'),
      ],
    };
    return PvOfferingView(
      id: p.id,
      stage: LifeStage.pregnancy,
      kind: kind,
      title: p.title.now,
      subtitle: p.subtitle.now,
      about: p.about.now,
      expert: _expertFrom(
        expert,
        fallbackId: p.instructorName.en,
        name: p.instructorName.now,
        role: p.instructorRole.now,
        bio: p.instructorBio.now,
      ),
      hue: _hueOf(p.accent),
      cover: pvLearnCoverFor(p.id, [for (final t in p.topics) t.en], kind),
      offering: engine,
      priceMinor: engine?.priceMinor ?? _minorOf(p.price),
      priceNote: p.priceNote.now.isEmpty ? null : p.priceNote.now,
      topics: [for (final t in p.topics) t.now],
      facts: facts.take(4).toList(),
      takeaways: p.takeaways.isNotEmpty
          ? [for (final t in p.takeaways) t.now]
          : [for (final t in p.covers) t.now],
      lessons: lessons,
      sessions: sessions,
      rhythm: [for (final t in p.sessionTimes) t.now],
      startLabel: p.startLabel?.now,
      seatsLeft: p.seatsLeft,
      durationLabel: p.durationLabel.now.isNotEmpty
          ? p.durationLabel.now
          : (kind == PvLearnKind.course && lessons.isNotEmpty
                ? _lessonsLine(lessons.length)
                : ''),
      rating: p.rating > 0 ? p.rating : null,
      reviewsLabel: p.reviewsLabel.now,
      reviews: [
        for (final r in p.reviews)
          PvLearnReview(name: r.who.now, who: r.when.now, quote: r.quote.now),
      ],
      recordingIncluded: kind == PvLearnKind.masterclass && !p.isLiveScheduled,
      featured: p.featured,
      recency: p.recency,
    );
  }

  /// Yoga: a live group class is a pack, a live 1:1 is a consult, a recorded
  /// one plays as a one-lesson course.
  static PvOfferingView _fromYoga(YogaClass y) {
    final kind = switch (y.mode) {
      YogaMode.liveGroup => PvLearnKind.classPack,
      YogaMode.liveOneToOne => PvLearnKind.consult,
      YogaMode.recorded => PvLearnKind.course,
    };
    final expert = expertByName(y.instructorName);
    final engine = _engine(y.id);
    final stage = (y.category == 'prenatal' || y.category == 'breathing')
        ? LifeStage.pregnancy
        : LifeStage.parenting;
    final facts = switch (kind) {
      PvLearnKind.classPack => [
        const PvLearnFact('4 classes', 'in the pack'),
        PvLearnFact(y.durationLabel, 'each'),
        PvLearnFact(y.schedule.replaceFirst('Live · ', ''), 'live'),
        PvLearnFact(y.level, 'level'),
      ],
      PvLearnKind.consult => [
        PvLearnFact(y.durationLabel, 'session'),
        const PvLearnFact('Video', 'in the app'),
        PvLearnFact(y.level, 'level'),
        const PvLearnFact('1:1', 'just you'),
      ],
      _ => [
        const PvLearnFact('1 class', 'recorded'),
        PvLearnFact(y.durationLabel, 'long'),
        PvLearnFact(y.level, 'level'),
        const PvLearnFact('Anytime', 'watch'),
      ],
    };
    return PvOfferingView(
      id: y.id,
      stage: stage,
      kind: kind,
      title: y.title,
      subtitle: y.tagline.isNotEmpty ? y.tagline : y.schedule,
      about: y.about,
      expert: _expertFrom(
        expert,
        fallbackId: _slug(y.instructorName),
        name: y.instructorName,
        role: y.instructorCredential,
        bio: y.instructorBio,
      ),
      hue: 150 + (y.seed % 5) * 20,
      cover: pvLearnCoverFor(y.id, [y.category, 'yoga'], kind),
      offering: engine,
      priceMinor: engine?.priceMinor ?? _minorOf(y.price),
      priceNote: y.price.contains('free on') ? 'free on ParentVeda+' : null,
      topics: [y.category, 'yoga'],
      facts: facts,
      takeaways: y.instructorFocus,
      lessons: kind == PvLearnKind.course
          ? [
              PvLearnLesson(
                id: '${y.id}_0',
                title: y.title,
                minutes: _minutesOf(y.durationLabel),
              ),
            ]
          : const [],
      rhythm: kind == PvLearnKind.classPack ? [y.schedule] : const [],
      durationLabel: y.durationLabel,
      rating: y.rating > 0 ? y.rating : null,
      reviewsLabel: y.reviewsCount > 0 ? '${y.reviewsCount} parents' : '',
      reviews: [
        for (final r in y.reviews)
          PvLearnReview(name: r.author, who: r.note, quote: '', stars: r.stars),
      ],
      prepare: const [
        'A mat and a little floor space',
        'Water within reach',
        'Loose clothes you can move in',
      ],
    );
  }

  /// A roster expert who takes consults. Null when they do not — an
  /// organisation that only teaches is not a 1:1.
  static PvOfferingView? _fromExpert(Expert e) {
    final engine = _engine(e.id);
    if (engine == null) return null;
    return PvOfferingView(
      id: e.id,
      stage: LifeStage.parenting,
      kind: PvLearnKind.consult,
      title: 'Consult with ${e.name}',
      subtitle: e.credential,
      about: e.why,
      expert: PvLearnExpert(
        id: e.id,
        name: e.name,
        role: e.credential,
        bio: e.why,
        expert: e,
      ),
      hue: 268,
      cover: pvLearnCoverFor(e.id, e.tags, PvLearnKind.consult),
      offering: engine,
      priceMinor: engine.priceMinor,
      topics: e.tags,
      facts: [
        const PvLearnFact('30 min', 'video session'),
        PvLearnFact(
          e.experience.isEmpty ? e.credential : e.experience,
          'experience',
        ),
        PvLearnFact(_languagesOf(e.tags), 'speaks'),
        PvLearnFact(e.rating, 'rated'),
      ],
      takeaways: const [
        'Her questions answered, in order',
        'Notes saved to her records afterwards',
        'A clear next step, or reassurance that none is needed',
      ],
      rating: double.tryParse(e.rating),
      reviewsLabel: e.reviewsCount,
      reviews: _expertReviews(e),
      prepare: const [
        'Her latest reports or readings, if any',
        'The two or three questions that matter most',
        'A quiet room and a charged phone',
      ],
    );
  }

  /// A pregnancy specialist. Linked to the roster by name when a profile
  /// exists (the other terminal's `expertByName` move, 2026-09-19).
  static PvOfferingView _fromSpecialist(Specialist s) {
    final expert = expertByName(s.name.en);
    final engine = _engine(s.id);
    return PvOfferingView(
      id: s.id,
      stage: LifeStage.pregnancy,
      kind: PvLearnKind.consult,
      title: 'Consult with ${s.name.now}',
      subtitle: s.role.now,
      about: s.about.now,
      expert: _expertFrom(
        expert,
        fallbackId: s.id,
        name: s.name.now,
        role: '${s.role.now} · ${s.cred.now}',
        bio: s.about.now,
      ),
      hue: 268,
      cover: pvLearnCoverFor(s.id, [s.role.en, 'doctor'], PvLearnKind.consult),
      offering: engine,
      priceMinor: engine?.priceMinor ?? _minorOf(s.consultPrice),
      topics: [s.role.now],
      facts: [
        const PvLearnFact('30 min', 'video session'),
        PvLearnFact(s.cred.now, 'qualified'),
        const PvLearnFact('English', 'speaks'),
        PvLearnFact(s.rating.replaceAll('★', '').trim(), 'rated'),
      ],
      takeaways: [for (final h in s.helps) h.now],
      rating: double.tryParse(s.rating.replaceAll('★', '').trim()),
      reviews: [
        for (final r in s.reviews)
          PvLearnReview(name: r.who.now, who: r.when.now, quote: r.quote.now),
      ],
      prepare: const [
        'Her latest scan or blood report, if any',
        'The questions that matter most, written down',
        'A quiet room and a charged phone',
      ],
    );
  }

  /// Trying to conceive: `TtcOffering`. No roster record — a role instead.
  static PvOfferingView _fromTtc(TtcOffering o) {
    final kind = switch (o.kind) {
      'consult' => PvLearnKind.consult,
      'cohort' => PvLearnKind.cohort,
      'classPack' => PvLearnKind.classPack,
      _ => PvLearnKind.masterclass,
    };
    final engine = _engine(o.id);
    // ⚠️ THE ROSTER, BY NAME (TTC launch walk, 2026-09-27; the user: "put them
    // for now", from the expert roster in MASTER-CONTENT-PLAN-v3.xlsx). The
    // rows read "A fertility specialist" twice at two prices with nothing to
    // tell them apart. Kept for revert: final who = _ttcExpertName(o.expertId);
    final (who, qualification) = _ttcRosterFor(o);
    final facts = switch (kind) {
      PvLearnKind.consult => [
        const PvLearnFact('45 min', 'video session'),
        PvLearnFact(o.forCouple ? 'Both of you' : 'Just you', 'who joins'),
        const PvLearnFact('English', 'speaks'),
        const PvLearnFact('Notes', 'saved after'),
      ],
      PvLearnKind.cohort => [
        PvLearnFact('${o.sessions} sessions', 'live'),
        const PvLearnFact('Small group', 'max 12'),
        PvLearnFact(o.forCouple ? 'Couples' : 'Women', 'for'),
        const PvLearnFact('Thread', 'between calls'),
      ],
      _ => [
        const PvLearnFact('90 min', 'live'),
        PvLearnFact(o.forCouple ? 'Both of you' : 'One seat', 'who joins'),
        const PvLearnFact('Recording', 'included'),
        const PvLearnFact('English', 'language'),
      ],
    };
    return PvOfferingView(
      id: o.id,
      stage: LifeStage.tryingToConceive,
      kind: kind,
      title: o.titleEn,
      // ⚠️ WHAT IT IS, IN ONE PLAIN LINE (2026-09-27, the tools pass): titles
      // like "The half nobody talks about" said nothing until opened. The
      // person stays on the expert block below. Kept for revert: subtitle: who.
      subtitle: ttcOfferingPlainLine(o.id) ?? who,
      about: o.bodyEn,
      // Kept for revert: role: 'ParentVeda expert',
      expert: PvLearnExpert(
        id: o.expertId,
        name: who,
        role: qualification,
      ),
      hue: 344,
      cover: pvLearnCoverFor(o.id, [o.category, 'trying'], kind),
      offering: engine,
      priceMinor: engine?.priceMinor ?? o.priceMinor,
      // ⚠️ NOT A GLUM FACE ON HELP (launch sanity MB21, 2026-09-28). The
      // category "mental" drew `IntentMark.moodArc`, a flat-mouthed face, as
      // the hero of the psychologist consult: the wrong tone for someone
      // reaching out, and it reads as the emoji the app avoids. For TTC only,
      // the topic says what the offerings are ("Mental support"), which draws
      // the cupped hands (support offered, not instructions given) through
      // `pvLearnMarkFor`. Other stages keep "mental". Kept for revert:
      //   topics: [o.category],
      topics: [o.category == 'mental' ? 'mental support' : o.category],
      facts: facts,
      takeaways: const [],
      sessions: kind == PvLearnKind.cohort
          ? [
              for (var i = 1; i <= o.sessions; i++)
                PvLearnSession(
                  label: 'Session $i',
                  title: i == 1 ? 'Where you both are' : 'Live call $i',
                ),
            ]
          : const [],
      recordingIncluded: kind == PvLearnKind.masterclass,
      prepare: o.forCouple
          ? const [
              'Both of you, if you can',
              'Any test results you already have',
              'The questions you keep coming back to',
            ]
          : const [
              'Any test results you already have',
              'The questions you keep coming back to',
            ],
    );
  }

  /// The free preconception course — eight taught sessions that run the real
  /// practice players. Price 0, so nothing on the page sells; each lesson
  /// opens its own session screen.
  static PvOfferingView _ttcGarbhCourse() => PvOfferingView(
    id: kPvTtcGarbhCourseId,
    stage: LifeStage.tryingToConceive,
    kind: PvLearnKind.course,
    title: 'Preconception garbh sanskar',
    subtitle: 'Eight sessions, taught properly rather than described',
    about: kTtcCourseHow,
    expert: const PvLearnExpert(
      id: 'parentveda',
      name: 'ParentVeda',
      role: 'The practice, in eight sittings',
    ),
    hue: 120,
    cover: pvLearnCoverFor(kPvTtcGarbhCourseId, const [
      'calm',
      'mind',
    ], PvLearnKind.course),
    // The engine's ₹0 row, so a history row can find this page; isFree keeps
    // the page from selling anything.
    offering: _engine(kTtcOfferingGarbhCourse),
    priceMinor: 0,
    topics: const ['mind', 'calm'],
    facts: [
      PvLearnFact('${kTtcCourseSessions.length} sessions', 'taught'),
      const PvLearnFact('Free', 'always'),
      const PvLearnFact('Together', 'or alone'),
      const PvLearnFact('No order', 'enforced'),
    ],
    takeaways: const [
      'The long out-breath, taught by doing it',
      'A daily sitting you can actually keep',
      'What to say to each other, and when',
      'What this cannot promise, said plainly',
    ],
    lessons: [
      for (final s in kTtcCourseSessions)
        PvLearnLesson(
          id: s.id,
          title: s.title,
          minutes: _minutesOf(s.duration),
          blurb: s.setting,
          open: (c) => Navigator.of(c).push(
            MaterialPageRoute<void>(
              settings: RouteSettings(name: 'ttc/course/${s.id}'),
              builder: (_) => TtcCourseSessionScreen(session: s),
            ),
          ),
        ),
    ],
    faqs: const [
      PvLearnFaq(
        'Do we have to do it together?',
        'No. Four sessions say they are better together, and that is a line of text, not a lock.',
      ),
      PvLearnFaq('Does it improve our chances?', kTtcCourseNever),
    ],
  );

  // ---- small helpers -----------------------------------------------------------

  /// Who runs a TTC offering, from the expert roster (2026-09-27): the
  /// offering first where one role has two people, then the role. A role the
  /// roster has nobody for (an andrologist) stays a role.
  /// The roster person behind a TTC offering, for a door card (2026-09-29):
  /// the same answer the Learn rows give, so one person has one name.
  static (String, String) ttcRosterFor(TtcOffering o) => _ttcRosterFor(o);

  static (String, String) _ttcRosterFor(TtcOffering o) => switch (o.id) {
        'ttc_consult_fertility' ||
        'ttc_ivf_prep' =>
          ('Dr Surbhi Sharma', 'IVF gynaecologist, Bloom IVF'),
        // A person with two consults is told apart by what each one is: the
        // row shows the role up to its first "·", so the consult leads.
        'ttc_assessment_couple' =>
          ('Dr Ruchika Sood', 'Couple assessment · IVF gynaecologist'),
        'ttc_consult_gynae' ||
        'ttc_course_basics' ||
        'ttc_course_pcos' =>
          ('Dr Ruchika Sood', 'IVF gynaecologist'),
        _ => switch (o.expertId) {
            'ttc_dr_fertility' => ('Dr Surbhi Sharma', 'IVF gynaecologist, Bloom IVF'),
            'ttc_dr_gynae' => ('Dr Ruchika Sood', 'IVF gynaecologist'),
            'ttc_nutritionist' =>
              ('Akanksha Srivastava', 'Maternal and child nutritionist'),
            'ttc_psychologist' => ('Parmeshwari', 'Clinical psychologist'),
            'ttc_yoga_lead' =>
              ('Dr Kajal Sharma', 'Ayurvedic garbh sanskar and yoga'),
            _ => (_ttcExpertName(o.expertId), 'ParentVeda expert'),
          },
      };

  static String _ttcExpertName(String id) => switch (id) {
    'ttc_dr_fertility' => 'A fertility specialist',
    'ttc_dr_gynae' => 'A gynaecologist',
    'ttc_dr_androl' => 'An andrologist',
    _ => 'A ParentVeda expert',
  };

  // Kept for the day a language is a promise we can keep — see
  // `_languagesOf`.
  // ignore: unused_field
  static const _langs = {
    'Hindi',
    'English',
    'Gujarati',
    'Marathi',
    'Tamil',
    'Telugu',
    'Kannada',
    'Bengali',
    'Punjabi',
    'Malayalam',
  };

  /// ⚠️ ENGLISH ONLY, FOR NOW — the user, 2026-09-22. The roster carries
  /// languages per expert and the pregnancy specialists were written as
  /// "English · हिंदी", but nothing yet promises a consult will actually be
  /// held in Hindi — no clinician has confirmed it and no booking asks.
  /// A language on a doctor's row is a promise about the half hour she
  /// pays for, so until it is one we say only what we can keep. The real
  /// list is one line away when the roster earns it:
  ///   final l = tags.where(_langs.contains).toList();
  ///   return l.isEmpty ? 'English' : l.take(2).join(' · ');
  static String _languagesOf(List<String> tags) => 'English';

  static int _minorOf(String price) {
    final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? 0 : int.parse(digits) * 100;
  }

  static int _minutesOf(String label) {
    final m = RegExp(r'(\d+)').firstMatch(label);
    return m == null ? 0 : int.parse(m.group(1)!);
  }

  static String _slug(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

/// A Trying to conceive consult whose expert is a ROLE, not a person ("An
/// andrologist", "A ParentVeda expert"): the roster has nobody named for it
/// yet (TTC launch sanity H16, 2026-09-28). The consult list titles such a row
/// by what the consult is instead of drawing initials for a nameless person.
/// It stops matching the day `_ttcRosterFor` names someone.
bool pvLearnHasNoNamedPerson(PvOfferingView v) =>
    v.stage == LifeStage.tryingToConceive &&
    RegExp(r'^An? ').hasMatch(v.expert.name);
