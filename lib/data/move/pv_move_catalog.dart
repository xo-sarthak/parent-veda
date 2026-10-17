// =============================================================================
//  The Yoga & fitness catalogue: one list for all three stages
// -----------------------------------------------------------------------------
//  Built 2026-10-16 after the Yog4Lyf comparison, when the user walked the app
//  and found yoga scattered over a retired month-tab screen, a class marketplace
//  and per-stage lists. Like the store (`pv_catalog_adapters.dart`), this does
//  not move any content. It FOLDS four existing sources into one shape, with
//  the stage as a tag, so the hub can show "For you" and "All" from one list:
//
//    kYogaClasses   (pp_yoga_data.dart)    the 27 classes, live and recorded
//    kYogaSessions  (prepare_data.dart)    the 21 month-by-month sessions
//    the TTC move practices (ttc_practice_data.dart), six of them
//    the TTC fertility yoga pack (ttc_prepare_data.dart, a Learn offering)
//
//  Each item keeps its source object, so a tap opens exactly what it opened
//  before. Nothing here decides what is safe; it only says which stage an item
//  belongs to. "After your six-week check" lives on the class
//  (`YogaClass.afterCheck`).
// =============================================================================

import '../../screens/post_pregnancy/pp_yoga_data.dart';
import '../../services/life_stage_store.dart';
import '../../ttc/ttc_practice_data.dart';
import '../../models/pv_video.dart';
import '../garbh_data.dart' show garbhMonth;
import '../prepare_data.dart';

/// The chips of the hub's All view, in order. `fertility` takes the post-IVF
/// classes and the TTC practices; the rest are the class categories as they
/// were.
const List<(String, String)> kPvMoveChips = [
  ('all', 'All'),
  ('yoga', 'Yoga'),
  ('fertility', 'Fertility'),
  ('prenatal', 'Prenatal'),
  ('postnatal', 'Postnatal'),
  ('core', 'Core'),
  ('breathing', 'Breathing'),
  ('meditation', 'Meditation'),
];

/// The id of the TTC fertility yoga pack (a Learn offering).
const String kPvMoveTtcPackId = 'ttc_yoga_pack';

enum PvMoveKind { yogaClass, session, practice, offering }

class PvMoveItem {
  const PvMoveItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.meta,
    required this.chip,
    required this.mode,
    this.stage,
    this.yogaClass,
    this.session,
    this.practice,
  });

  final String id;
  final PvMoveKind kind;
  final String title;

  /// "18 min · Month 3", "45 min · Teacher name", "Live · 8 classes".
  final String meta;

  /// One of [kPvMoveChips]' ids, never 'all'.
  final String chip;

  /// Live group, 1:1 or recorded. Sessions and practices are self-guided, so
  /// they count as recorded.
  final YogaMode mode;

  /// Null means it suits every stage (general yoga, breathing, meditation).
  final LifeStage? stage;

  final YogaClass? yogaClass;
  final YogaSession? session;
  final TtcPractice? practice;

  bool get afterCheck => yogaClass?.afterCheck ?? false;

  /// The small label on a card in the All view, so a mixed list never confuses
  /// whose class it is.
  String? get stageLabel => switch (stage) {
    LifeStage.tryingToConceive => 'Fertility',
    LifeStage.pregnancy => 'Pregnancy',
    LifeStage.parenting => 'After birth',
    _ => null,
  };
}

LifeStage? _stageForCategory(String cat) => switch (cat) {
  'prenatal' => LifeStage.pregnancy,
  'postnatal' || 'core' => LifeStage.parenting,
  'postivf' => LifeStage.tryingToConceive,
  _ => null,
};

PvMoveItem pvMoveFromClass(YogaClass c) => PvMoveItem(
  id: c.id,
  kind: PvMoveKind.yogaClass,
  title: c.title,
  meta: '${c.durationLabel} · ${c.instructorName}',
  chip: c.category == 'postivf' ? 'fertility' : c.category,
  mode: c.mode,
  stage: _stageForCategory(c.category),
  yogaClass: c,
);

PvMoveItem pvMoveFromSession(YogaSession s) => PvMoveItem(
  id: s.id,
  kind: PvMoveKind.session,
  title: s.title.now,
  meta: '${s.duration.now} · Month ${s.month}',
  chip: 'prenatal',
  mode: YogaMode.recorded,
  stage: LifeStage.pregnancy,
  session: s,
);

PvMoveItem pvMoveFromPractice(TtcPractice p) => PvMoveItem(
  id: p.id,
  kind: PvMoveKind.practice,
  title: p.title,
  meta: '${p.duration} · ${p.setting}',
  chip: 'fertility',
  mode: YogaMode.recorded,
  stage: LifeStage.tryingToConceive,
  practice: p,
);

const PvMoveItem kPvMoveTtcPack = PvMoveItem(
  id: kPvMoveTtcPackId,
  kind: PvMoveKind.offering,
  title: 'Fertility yoga, eight classes',
  meta: 'Live · small group · 8 classes',
  chip: 'fertility',
  mode: YogaMode.liveGroup,
  stage: LifeStage.tryingToConceive,
);

/// Everything, in a stable order: classes, then the month sessions, then the
/// TTC pack and practices.
List<PvMoveItem> pvMoveCatalog() => [
  for (final c in kYogaClasses) pvMoveFromClass(c),
  for (final s in kYogaSessions) pvMoveFromSession(s),
  kPvMoveTtcPack,
  for (final p in ttcPracticesOfKind(TtcPracticeKind.move))
    pvMoveFromPractice(p),
];

/// The All view's list for one chip, narrowed by the Filter sheet's modes
/// (empty = every mode) and by a free-text query.
List<PvMoveItem> pvMoveFiltered({
  String chip = 'all',
  Set<YogaMode> modes = const {},
  String query = '',
}) {
  final q = query.trim().toLowerCase();
  return pvMoveCatalog()
      .where((i) => chip == 'all' || i.chip == chip)
      .where((i) => modes.isEmpty || modes.contains(i.mode))
      .where(
        (i) =>
            q.isEmpty ||
            i.title.toLowerCase().contains(q) ||
            i.meta.toLowerCase().contains(q) ||
            i.chip.contains(q) ||
            (i.stageLabel?.toLowerCase().contains(q) ?? false),
      )
      .toList(growable: false);
}

/// A month session as a film, so it opens the house film page
/// (`V3FilmScreen`) like every other film (2026-10-17). Its weeks are the
/// weeks of its pregnancy month, by the same [garbhMonth] the hub uses.
PvVideo pvSessionFilm(YogaSession s) {
  final weeks = [
    for (var w = 1; w <= 40; w++)
      if (garbhMonth(w) == s.month) w,
  ];
  return PvVideo(
    id: s.id,
    title: s.title,
    reason: s.blurb,
    duration: s.duration.en,
    category: VideoCategory.skill,
    weekStart: weeks.isEmpty ? 4 : weeks.first,
    weekEnd: weeks.isEmpty ? 40 : weeks.last,
  );
}
