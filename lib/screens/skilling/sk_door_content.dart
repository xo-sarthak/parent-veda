// =============================================================================
//  SkDoorContent — everything one skill door holds, in one typed record
// -----------------------------------------------------------------------------
//  The parenting `PpSection` is seven areas of pages. A skill door is a
//  different shape, fixed by the Coding v2 brief and repeated by every brief
//  after it: a lesson library in SETS, an activity set per band built on the
//  door's own six thinking skills, an AI-literacy (or door-specific) set
//  across bands, a parent note, a course shelf and a product shelf. So the
//  record has those slots by name, and the door screen draws each of the
//  brief's five child surfaces from the matching slot. "Every other door
//  becomes content, not engineering" — a new door is one of these and a
//  `SkDoor` shell over it.
//
//  ⚠️ COURSES AND PRODUCTS CARRY THE NO-OUTCOME FLAG AS DATA. The brief's
//  one line held firm on: "a course here can teach brilliantly and it can be
//  paid, but it cannot sell an outcome." `noOutcomeClaims` is `true` on the
//  type — it cannot be constructed false — so the flag is not a promise, it
//  is a statement the test can check copy against: `test/sk_doors_sanity_
//  test.dart` scans every course and product string for the banned phrases.
//
//  ⚠️ THE PRODUCT SHELF IS SKILLING'S OWN. The user's call (2026-09-14,
//  question 6): build alone on the skilling side; the shop engines will be
//  unified later. So `SkProduct` is a small record and its card opens a
//  parent-side sheet, not `pp_products`.
// =============================================================================

import 'sk_content.dart';

/// A group of lessons: Coding's unplugged / blocks / projects / ai. The
/// Lessons tab draws one rail per set in her band; the door names which set
/// is the cross-band one (`SkDoorContent.crossBandSetId`).
class SkLessonSet {
  const SkLessonSet({
    required this.id,
    required this.title,
    required this.blurb,
    this.bands = const [],
  });
  final String id;
  final String title;
  final String blurb;

  /// Empty means every band.
  final List<String> bands;

  bool inBand(String band) => bands.isEmpty || bands.contains(band);
}

enum SkCourseMode { live, recorded }

/// One leveled class the parent can enrol in. Placeholder now.
class SkCourse {
  const SkCourse({
    required this.id,
    required this.title,
    required this.level,
    required this.mode,
    this.blurb = '',
    this.priceInr,
    this.priceUsd,
    this.comingSoon = false,
  });
  final String id;
  final String title;

  /// A `kSkBands` id — the level the class is pitched at.
  final String level;
  final SkCourseMode mode;
  final String blurb;

  /// Placeholder prices. Money is decided server-side; these are the shelf's
  /// display until a real programme exists.
  final int? priceInr;
  final int? priceUsd;
  final bool comingSoon;

  /// Cannot be false. See the header.
  bool get noOutcomeClaims => true;

  String get modeLabel =>
      mode == SkCourseMode.live ? 'Live class' : 'Recorded';
}

enum SkProductKind { kit, robotics, book, game, other }

/// One related thing a parent can buy. Placeholder now.
class SkProduct {
  const SkProduct({
    required this.id,
    required this.title,
    required this.kind,
    this.bands = const [],
    this.blurb = '',
    this.priceInr,
    this.comingSoon = false,
  });
  final String id;
  final String title;
  final SkProductKind kind;

  /// Age-tagged. Empty means every band.
  final List<String> bands;
  final String blurb;
  final int? priceInr;
  final bool comingSoon;

  bool get noOutcomeClaims => true;
  bool inBand(String band) => bands.isEmpty || bands.contains(band);

  String get kindLabel => switch (kind) {
        SkProductKind.kit => 'Kit',
        SkProductKind.robotics => 'Robotics',
        SkProductKind.book => 'Book',
        SkProductKind.game => 'Game',
        SkProductKind.other => 'Product',
      };
}

/// One free tool a band's activities run in — the 8 to 11 task's ACCESS
/// RAIL, "built once, parent-gated, reused by all 12", extended by the 11 to
/// 14 task. Added at the fill (2026-09-14) because the structure pass had no
/// slot for it; the task said STOP and list, and this is the listed shape.
///
/// ⚠️ FREE, AND NEVER AN AD TO A CHILD. The rail is drawn behind the
/// grown-up gate (`sk_access/<door>`), and the tools are the task's own
/// list: offline and no-account first. ParentVeda hosts no editor and
/// collects nothing; any account is the parent's choice under the existing
/// consent.
class SkAccessTool {
  const SkAccessTool({
    required this.name,
    required this.line,
    required this.bands,
    this.url,
    this.offline = false,
    this.noAccount = false,
  });
  final String name;

  /// The task's own words for it.
  final String line;
  final List<String> bands;

  /// Opened through the gate, in the browser. Null for "a supervised look
  /// at a real AI tool" — the parent's choice, not a link.
  final String? url;
  final bool offline;
  final bool noAccount;

  bool inBand(String band) => bands.contains(band);
}

/// A one-to-one coach the parent books. Placeholder now: the Confidence
/// brief un-holds Consult ("the only door naming a real role with real
/// supply") and the user's call (2026-09-16, question 1a) is a placeholder
/// row behind the gate until a real coach is onboarded, with the booking
/// engine (`lib/booking/`) as the named next pass. Same guardrail as a
/// course: teaches, promises nothing.
class SkCoach {
  const SkCoach({
    required this.id,
    required this.title,
    this.blurb = '',
    this.priceInr,
    this.priceUsd,
    this.comingSoon = true,
  });
  final String id;
  final String title;
  final String blurb;
  final int? priceInr;
  final int? priceUsd;
  final bool comingSoon;
  bool get noOutcomeClaims => true;
}

/// One skill door's content.
class SkDoorContent {
  const SkDoorContent({
    required this.doorId,
    required this.bandNames,
    required this.skills,
    required this.lessonSets,
    required this.lessons,
    required this.activities,
    required this.courses,
    required this.products,
    required this.parentNote,
    this.crossBandSetId,
    this.access = const [],
    this.boundaryNote,
    this.voiceKeepsake = false,
    this.voiceSelfReview = false,
    this.voiceTitle = 'Your voice, saved',
    this.coach,
  });

  /// The keepsake screen's title, in the door's own words — Communication's
  /// "Your voice, saved", Confidence's "Your talks, saved".
  final String voiceTitle;

  /// "Hear yourself back … notice one thing you did." After listen-back the
  /// record sheet shows one prompt and stores nothing — the noticing is
  /// hers (the user's call, 2026-09-16, question 4a). Confidence only.
  final bool voiceSelfReview;

  /// The one-to-one coach row on the grown-up screen. Null for a door whose
  /// Consult is held.
  final SkCoach? coach;

  /// One honest line out to a professional, on the parent side — the
  /// Communication brief's "if speech itself is the worry (stammer, delay)".
  /// Held as a single line, never a course and never a "fix her speech"
  /// product; drawn as a card on the grown-up screen. Null for a door
  /// without one.
  final SkPage? boundaryNote;

  /// The door records her voice: "Your voice, saved". The activity screen
  /// shows a record row, and the keepsake screen lists the clips beside the
  /// practised words. On this phone only — see `sk_voice_keepsake.dart`.
  final bool voiceKeepsake;

  /// The bracket id — `skilling_coding`.
  final String doorId;

  /// The door's own name for each rung, keyed by `kSkBands` id:
  /// Coding: 6-8 → Unplugged, 8-11 → Blocks, 11-14 → Projects.
  final Map<String, String> bandNames;

  /// The door's six real thinking skills.
  final List<SkSkillPurpose> skills;

  final List<SkLessonSet> lessonSets;

  /// Every lesson page, tagged to a set and to bands.
  final List<SkPage> lessons;

  /// The heart. A full set per band.
  final List<SkActivity> activities;

  final List<SkCourse> courses;
  final List<SkProduct> products;

  /// The parent note — parent voice, behind the gate.
  final SkPage parentNote;

  /// The set that spans every band and gets its own tab (Coding's AI set).
  final String? crossBandSetId;

  /// The access rail: the free tools her band's activities run in. Empty
  /// for a band that needs nothing (Coding's Unplugged), in which case the
  /// door draws no card for it.
  final List<SkAccessTool> access;

  List<SkAccessTool> accessFor(String band) =>
      [for (final t in access) if (t.inBand(band)) t];

  String bandName(String bandId) => bandNames[bandId] ?? bandId;

  SkSkillPurpose? skillById(String id) {
    for (final s in skills) {
      if (s.id == id) return s;
    }
    return null;
  }

  SkLessonSet? setById(String id) {
    for (final s in lessonSets) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// The lesson sets a band sees on the Lessons tab — the cross-band set
  /// excluded, since it has its own tab.
  List<SkLessonSet> lessonSetsFor(String band) => [
        for (final s in lessonSets)
          if (s.id != crossBandSetId && s.inBand(band)) s,
      ];

  List<SkPage> lessonsIn(String setId, String band) => [
        for (final l in lessons)
          if (l.set == setId && l.inBand(band)) l,
      ];

  List<SkActivity> activitiesFor(String band) =>
      [for (final a in activities) if (a.band == band) a];

  List<SkActivity> activitiesForSkill(String band, String skill) => [
        for (final a in activities)
          if (a.band == band && a.skillPurpose == skill) a,
      ];

  List<SkCourse> coursesFor(String? band) =>
      [for (final c in courses) if (band == null || c.level == band) c];

  List<SkProduct> productsFor(String? band) =>
      [for (final p in products) if (band == null || p.inBand(band)) p];

  /// "Today's thing to try": one activity from her band, chosen by the day
  /// so it changes daily and is the same all day. Derived, never asked, and
  /// never recorded — it is a function of the date, not of the child.
  SkActivity? todayFor(String band, {DateTime? now}) {
    final list = activitiesFor(band);
    if (list.isEmpty) return null;
    final d = now ?? DateTime.now();
    final day = d.difference(DateTime(d.year)).inDays;
    return list[day % list.length];
  }

  /// Every page with an id — lessons and the note — for the router and
  /// the wiring tests.
  List<SkPage> get allPages => [...lessons, parentNote, ?boundaryNote];

  SkPage? pageById(String id) {
    for (final p in allPages) {
      if (p.id == id) return p;
    }
    return null;
  }

  SkActivity? activityById(String id) {
    for (final a in activities) {
      if (a.id == id) return a;
    }
    return null;
  }
}
