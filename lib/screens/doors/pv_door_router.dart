// =============================================================================
//  Where a door's tiles and surfaces go
// -----------------------------------------------------------------------------
//  ⚠️ THE SCREEN NEVER IMPORTS A DESTINATION, AND THE DATA NEVER NAMES A
//  WIDGET. This file is the join, and it is the only thing in the door engine
//  that knows what a `ScanTimelineScreen` is.
//
//  That split is what makes the next seven briefs a data change rather than a
//  screen change: a door declares surface ids, this file resolves them, and
//  `pv_door_screen.dart` renders whatever comes back without knowing what it
//  is looking at.
//
//  ---------------------------------------------------------------------------
//  ⚠️ EVERY PUSH CARRIES A ROUTE NAME, AND THE NAME IS LOAD-BEARING
//  ---------------------------------------------------------------------------
//
//  `global_ask_fab.dart` reads the route name to decide which Ask Veda opens
//  and what context it receives. The brief's one instruction about Ask Veda is
//  that a scan page and a result page must pass their context — and the
//  mechanism for that is already built and already works, provided the route
//  has a name.
//
//  So an anonymous `MaterialPageRoute` here would not fail, crash or log. The
//  screen would open, look right, and the sparkle button in the corner would
//  quietly ask the wrong brain. That is the shape of failure this repo has hit
//  before, which is why the ids are constants in the data file rather than
//  literals typed twice.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NULL IS A REAL ANSWER
//  ---------------------------------------------------------------------------
//
//  An unknown surface id returns null and opens nothing, rather than guessing
//  at the nearest screen. A wrong destination is worse than none: it looks like
//  it worked. `test/pv_door_scans_test.dart` walks every tile on every door and
//  asserts that each one resolves, so the null branch is unreachable from
//  anything that ships — which is the point of having it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_data.dart';
import '../../data/reads/pregnancy_reads.dart';
import '../../data/tests_scans_reports_data.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import '../../data/conditions_data.dart';
import '../../data/belly_skin_data.dart';
import '../../data/nutrition_data.dart';
import '../../data/report_findings_data.dart';
import '../belly_skin/bs_article_screen.dart';
import '../belly_skin/bs_itching_screen.dart';
import '../belly_skin/ingredient_checker_screen.dart';
import '../belly_skin/bump_ritual_screen.dart';
import '../conditions/condition_detail_screen.dart';
import '../nutrition/diet_charts_screen.dart';
import '../nutrition/can_i_eat_body.dart';
import '../nutrition/fasting_screen.dart';
import '../nutrition/nutrients_screen.dart';
import '../nutrition/nutrition_recipes_screen.dart';
// ⚠️ PREFIXED, BECAUSE `ConditionDetailScreen` EXISTS TWICE IN THIS APP. One is
// the Complications page ("my doctor said I have X"); the other is the DIET
// page for the same condition ("what to eat for it"). Two real screens with one
// name — a pre-existing clash this file is simply the first to import both
// sides of. See `docs/PREGNANCY-DOOR-BUILD.md` §4a for why both exist.
import '../nutrition/nutrition_stage_screen.dart' as diet;
import '../conditions/conditions_home_screen.dart';
import '../brackets/same_day_signs_screen.dart';
import '../brackets/scan_detail_screen.dart';
import '../brackets/scan_next_screen.dart';
import '../../data/checklists/pv_checklist.dart';
import '../brackets/pv_checklist_screen.dart';
import '../brackets/scan_reports_screen.dart';
import '../brackets/scan_timeline_screen.dart';
import '../brackets/scan_urgent_screen.dart';
import '../pregnancy/birth_plan_screen.dart';
import '../../data/doors/pv_door_mind.dart';
import '../../data/mind_mood_data.dart';
import '../mind_mood/mm_article_screen.dart';
import '../mind_mood/mm_breathing_screen.dart';
import '../mind_mood/mm_crisis_path.dart';
import '../mind_mood/mm_door_surfaces.dart';
import '../mind_mood/mm_feel_tab.dart' show mmSosFlowScreen;
import '../mind_mood/mm_talk_tab.dart' show MmScreenerScreen;
import '../mind_mood/mm_track_tab.dart';
import '../../data/mind_mood_extras.dart' show kMmPartnerArticle;
import '../../services/bracket_resolver.dart' show bracketById;
import 'pv_door_chrome.dart' show PvDoorToolScaffold;
import 'pv_door_screen.dart' show PvDoorScreen;
import '../prepare/birthing_classes_screen.dart';
import '../prepare/consultations_screen.dart';
import '../tools/contraction_tracker_screen.dart';
import '../tools/ready_for_birth_screen.dart';
import '../reader/pv_reader_screen.dart';
import '../report_screen.dart';
import '../tools/tests_scans_reports_screen.dart';

/// The screen a door surface opens, or null when nothing does.
Widget? pvDoorScreenFor(String id, PregnancyController c) => switch (id) {
      kScansSurfaceTimeline => ScanTimelineScreen(pregnancy: c),
      kScansSurfaceNext => ScanNextScreen(pregnancy: c),
      kScansSurfaceReports => ScanReportsScreen(pregnancy: c),
      kScansSurfaceDecoder => ReportScreen(controller: c),
      kScansSurfaceUrgent => const ScanUrgentScreen(),
      // ⚠️ THE GENERIC CHECKLIST SCREEN, GIVEN THIS DOOR'S HUE. The list knows
      // what it is about (it reads `ScansStore` itself); the door decides what
      // colour it wears, so a checklist opened from Scans is blue and the same
      // widget opened from Complications is teal.
      kScansSurfaceQuestions => PvChecklistScreen(
          checklist: pvChecklistById('scan_questions')!,
          hue: 206,
          pregnancy: c),
      kScansSurfaceConsult => ConsultationsScreen(lang: c.language),

      // ⚠️ THE RESLOT, AND IT IS THE SAME TOOL — NOT A COPY OF IT.
      //
      // "Your report, line by line" is the parameter table inside a scan page:
      // every reading, the usual range, and what it means when hers sits
      // outside it. The brief moves it to My reports and says twice that it
      // must stay single-source — "if it is opened from a scan page too, it is
      // the same tool, not a copy."
      //
      // A scan page reaches it with a scan already chosen. From My reports
      // there is no scan yet, so the library asks which report she is holding
      // and then opens exactly the same screen with `openParameters` set. The
      // scan pages are untouched and still open it directly.
      //
      // ⚠️ THE LIBRARY IS REUSED RATHER THAN A PICKER BEING BUILT.
      // `TestsScansReportsScreen` already lists every test and scan with
      // trimester filters and already opens `TestScanDetailScreen`. Building a
      // second list would have been a second place for the scan library to
      // drift, to answer a question this screen already answers.
      kScansSurfaceParameters => TestsScansReportsScreen(
          controller: c,
          openParameters: true,
          testsOnly: true,
          title: 'Your report, line by line',
          intro: 'Which report are you holding? Open it to see every reading, '
              'the usual range, and what it means when yours sits outside it.',
        ),

      // ---- Complications & conditions -------------------------------------
      kCondSurfaceFind => ConditionsHomeScreen(pregnancy: c),
      kCondSurfaceSameDay => SameDaySignsScreen(pregnancy: c),

      // ⚠️ "Add a condition to my journey" OPENS THE SEARCH, AND THAT IS THE
      // REUSE THE BRIEF ASKS FOR. Its words: *"reuse the existing 'Add to my
      // journey' action"* — and that action lives ON a condition page, because
      // adding one requires having chosen one. From a door there is no
      // condition yet, so the honest route is the screen that picks one, where
      // the button then does exactly what it always did. Building a second
      // adder here would be a second way to write the same set.
      kCondSurfaceJourney => ConditionsHomeScreen(pregnancy: c),

      // ---- Labour prep ----------------------------------------------------
      //
      // ⚠️ ALL FOUR ARE THE STAGE'S OWN SURFACES, already resolved by
      // `surface_router.dart` for the hub that used to open them. Naming them
      // again here rather than delegating keeps the door's list explicit — the
      // wiring test walks it, and a surface that quietly stopped resolving
      // upstream would otherwise fail on a phone rather than in CI.
      kLabourSurfaceTimer => ContractionTrackerScreen(controller: c),
      kLabourSurfaceBag => ReadyForBirthScreen(controller: c),
      kLabourSurfaceCourse => BirthingClassesScreen(lang: c.language),
      kLabourSurfaceBirthPlan => BirthPlanScreen(pregnancy: c),

      // ---- Belly & skin ---------------------------------------------------
      kBsSurfaceChecker => const IngredientCheckerScreen(),
      kBsSurfaceItching => BsItchingScreen(pregnancy: c),
      kBsSurfaceRitual => BumpRitualScreen(controller: c),

      // ---- Nutrition & diet -----------------------------------------------
      // ⚠️ THE SAME BODY THE TAB RENDERS, GIVEN A SCAFFOLD. A door surface has
      // to resolve to a pushable screen as well as to an inline body — the
      // wiring test builds both — and for this one the screen is the body plus
      // chrome. `FoodCheckScreen` is still the standalone checker; this is the
      // folded pair the brief asks for.
      kDietSurfaceCanIEat => _CanIEatScreen(pregnancy: c),
      kDietSurfaceRecipes => const NutritionRecipesScreen(),
      kDietSurfaceCharts => DietChartsScreen(pregnancy: c),
      kDietSurfaceFasting => const FastingScreen(),
      kDietSurfaceBigger => const NutrientsScreen(),
      kDietSurfaceExperts => const _DieticiansScreen(),
      kDietSurfaceQuestions => PvChecklistScreen(
          checklist: pvChecklistById('diet_questions')!,
          hue: 104,
          pregnancy: c),

      kCondSurfaceQuestions => PvChecklistScreen(
          checklist: pvChecklistById('condition_questions')!,
          hue: 186,
          pregnancy: c),

      // ---- Mind & mood ----------------------------------------------------
      // ⚠️ THE AREA'S OWN SCREENS, REUSED WHOLE. The breathing circle, the
      // grounding flow, the screener and the crisis path are shipped and keep
      // their chrome; only the four in `mm_door_surfaces.dart` are new, and
      // each of those wraps something that already existed.
      kMindSurfaceReset => const MmHardDayResetScreen(),
      kMindSurfaceCalmNote => mmSosFlowScreen(),
      kMindSurfaceAffirmations => const MmAffirmationsScreen(),
      kMindSurfaceTrack => _MindTrackScreen(pregnancy: c),
      kMindSurfaceCheckIn => const MmScreenerScreen(),
      kMindSurfaceCrisis => const MmCrisisPathScreen(),
      kMindSurfaceHelplines => const MmHelplinesScreen(),
      _ when id.startsWith('mind/breathe/') => _mindBreathe(id),
      _ when id.startsWith('mind/offer/') => _mindOffer(id),

      _ => null,
    };

/// Open one condition page directly. Used by a pinned flag's per-line taps.
void openPvDoorConditionPage(
    BuildContext context, String conditionId, PregnancyController c) {
  final screen =
      pvDoorEntryScreen(PvDoorLibrary.condition, conditionId, c);
  if (screen == null) return;
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: 'conditions/$conditionId'),
    builder: (_) => screen,
  ));
}

/// The tool a group renders IN PLACE, or null when it is not an inline tool.
///
/// ⚠️ INLINE MEANS A BODY, NOT A SCREEN. Every widget returned here is a
/// `Column` with no `Scaffold` and no app bar — see `ScanTimelineBody`. A
/// `Scaffold` nested inside the door's `ListView` would bring a second
/// background, a second safe area and an unbounded height.
Widget? pvDoorInlineToolFor(String id, PregnancyController c) => switch (id) {
      kScansSurfaceTimeline => ScanTimelineBody(pregnancy: c, showFooter: false),
      kScansSurfaceReports => ScanReportsBody(pregnancy: c),
      // ⚠️ A FLAG RATHER THAN A BODY WIDGET, and the reason is on
      // `ReportScreen.embedded`: the decoder's content is inseparable from its
      // filter state, so a body would either duplicate that state or wrap it.
      kScansSurfaceDecoder => ReportScreen(controller: c, embedded: true),
      // ⚠️ THE SEARCH SCREEN *AND* THE TWO-WAY DOOR. `ConditionsHomeBody`
      // renders the gate when she has not answered it yet, which is right: the
      // question changes what the whole area offers, and a door that skipped it
      // would bypass something the screen exists to ask.
      kCondSurfaceFind => ConditionsHomeBody(pregnancy: c),
      // ⚠️ THE FOOD CHECKER AND CRAVINGS, FOLDED. The brief's own call — same
      // "can I have this" question, two kinds of object. See `CanIEatBody`.
      kDietSurfaceCanIEat => CanIEatBody(pregnancy: c),
      // ⚠️ THE FOUR PAID TIERS, RENDERED RATHER THAN RE-CARDED. Keeping the
      // tiers exactly as they are is easiest to guarantee by not retyping them.
      kDietSurfaceExperts => const diet.ExpertOptionsBlock(),
      // ⚠️ THE KEEPSAKE IS THE TAB. `BumpJourneyScreen` is a Scaffold, so the
      // inline form is its body — see `BumpJourneyBody`.
      kBsSurfaceRitual => BumpRitualBody(controller: c),
      // ⚠️ THE TRACK TAB IS THE TOOL. "Do-it screens, not rails." The same
      // widget the old landing showed, as a Column.
      kMindSurfaceTrack => const MmTrackTab(embedded: true),

      _ => null,
    };

/// Push a surface, named.
void openPvDoorSurface(
    BuildContext context, String id, PregnancyController c) {
  final screen = pvDoorScreenFor(id, c);
  if (screen == null) return; // null is a real answer; see the header
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: id),
    builder: (_) => screen,
  ));
}

/// Open whatever a tile is.
///
/// ⚠️ EVERY BRANCH PUSHES A SCREEN. No bottom sheets: a sheet caps the content
/// at half a screen and tells the reader that what she tapped was minor, and
/// she cannot see which she is getting before she taps. Tapping a piece of
/// content opens that piece of content, full screen, every time.
///
/// ⚠️ AND THE SWITCH IS EXHAUSTIVE OVER A SEALED TYPE. Adding an eighth tile
/// format makes this fail to compile and names the file that has not handled
/// it — rather than the app rendering a card that does nothing.
void openPvDoorTile(
    BuildContext context, PvDoorTile tile, PregnancyController c) {
  // ⚠️ A COMING-SOON CARD IS NOT TAPPABLE AT ALL, and the card draws itself
  // that way. This is the second gate rather than the first: the honest
  // treatment is on the card, and this exists so a route can never be reached
  // by a stray semantics tap or a test driving the tile directly.
  if (tile.comingSoon) return;

  switch (tile) {
    case PvDoorToolTile(:final surfaceId):
      openPvDoorSurface(context, surfaceId, c);

    case PvDoorChecklistTile(:final surfaceId):
      openPvDoorSurface(context, surfaceId, c);

    case PvDoorTalkTile(:final surfaceId):
      openPvDoorSurface(context, surfaceId, c);

    case PvDoorReadTile(:final surfaceId):
      // Null only on the coming-soon form, which returned above.
      if (surfaceId != null) openPvDoorSurface(context, surfaceId, c);

    // ---- one page from a library the app already ships ---------------------
    //
    // ⚠️ ONE CASE FOR NINE LIBRARIES. This replaced three near-identical cases
    // and stopped six more being written — see `PvDoorLibrary`. The route name
    // is the page's own, unchanged from however it was reached before, because
    // Ask Veda's stage routing and the FAB's suppression list both read it.
    case PvDoorEntryTile(:final library, :final entryId):
      final screen = pvDoorEntryScreen(library, entryId, c);
      if (screen == null) return; // caught by the wiring test, never by a user
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: pvDoorEntryRoute(library, entryId)),
        builder: (_) => screen,
      ));

    // ---- a film that does not exist yet ------------------------------------
    //
    // ⚠️ UNREACHABLE, AND DELIBERATELY PRESENT. `comingSoon` is true on every
    // video tile, so `openPvDoorTile` returns before the switch. The case
    // exists because the union is sealed and the compiler demands it — and
    // because the day a film lands, this is where it plays.
    case PvDoorVideoTile():
      return;

    // Same as a film: the four calming tracks have no file yet.
    case PvDoorAudioTile():
      return;

    // ---- reading ------------------------------------------------------------
    case PvDoorGuideTile(:final readId, :final atHeading):
      openPvDoorRead(context, readId, c, atHeading: atHeading);

    case PvDoorMythTile(:final readId):
      openPvDoorRead(context, readId, c);
  }
}

/// Open a pregnancy read in the shared reader.
///
/// ⚠️ THE READER IS STAGE-NEUTRAL AND STAYS THAT WAY. It takes `openRead`,
/// `openSurface` and `readTitle` as callbacks precisely so it never has to hold
/// a stage's library — which is what let pregnancy start its own without
/// touching TTC's. Passing pregnancy's lookups here is the whole of the
/// wiring.
void openPvDoorRead(
  BuildContext context,
  String readId,
  PregnancyController c, {
  String? atHeading,
}) {
  final read = pregnancyReadById(readId);
  if (read == null) return; // the wiring test makes this unreachable
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: 'read/$readId'),
    builder: (_) => PvReaderScreen(
      read: read,
      // ⚠️ THE STAGE'S OWN LANGUAGE, NOT A GLOBAL. Pregnancy's flag lives on
      // the controller; reading TTC's would render Devanagari inside an English
      // shell. The reader does not guess and must not.
      lang: c.language,
      openAtHeading: atHeading,
      readTitle: pregnancyReadTitle,
      openRead: (ctx, id) => openPvDoorRead(ctx, id, c),
      openSurface: (ctx, id) => openPvDoorSurface(ctx, id, c),
    ),
  ));
}

/// The screen one library entry opens, or null when the id is not in it.
///
/// ⚠️ NULL IS A REAL ANSWER AND THE WIRING TEST MAKES IT UNREACHABLE. A bad id
/// opens nothing rather than guessing at a near match — a wrong page is worse
/// than none, because it looks like it worked.
Widget? pvDoorEntryScreen(
    PvDoorLibrary library, String id, PregnancyController c) {
  switch (library) {
    case PvDoorLibrary.scan:
      for (final s in kTestsScans) {
        if (s.id == id) return ScanDetailScreen(scan: s, pregnancy: c);
      }
    case PvDoorLibrary.condition:
      for (final e in kAllConditions) {
        if (e.id == id) return ConditionDetailScreen(entry: e, pregnancy: c);
      }
    case PvDoorLibrary.finding:
      for (final f in kReportFindings) {
        if (f.id == id) {
          return ReportArticleScreen(finding: f, controller: c);
        }
      }
    case PvDoorLibrary.nutrient:
      for (final n in kNutrientGuides) {
        if (n.id == id) return NutrientDetailScreen(guide: n);
      }
    case PvDoorLibrary.dietStage:
      for (final g in kTrimesterGuides) {
        if (g.id == id) return diet.StageDetailScreen(guide: g);
      }
    case PvDoorLibrary.dietCondition:
      for (final g in kConditionGuides) {
        if (g.id == id) {
          return diet.ConditionDetailScreen(guide: g, pregnancy: c);
        }
      }
    case PvDoorLibrary.recipe:
      for (final r in kRecipes) {
        if (r.id == id) return RecipeDetailScreen(recipe: r);
      }
    case PvDoorLibrary.dietChart:
      for (final ch in kDietCharts) {
        if (ch.id == id) return DietChartScreen(chart: ch);
      }
    // ⚠️ THE ONLY LIBRARY WITH NO PER-ENTRY PAGE, AND THE BRIEF SAID TO SAY SO
    // RATHER THAN BUILD ONE. `kFastingByOccasion` and `kFastingGeneral` are
    // eight title-and-paragraph rows rendered INLINE on `FastingScreen`; they
    // are not tappable and no detail screen exists.
    //
    // So the id is validated (a typo still fails the wiring test) and every
    // fasting tile opens the screen that shows all eight. Eight cards each
    // opening the same screen would be eight promises with one destination, so
    // the door carries ONE card — see `pv_door_nutrition.dart`.
    case PvDoorLibrary.bellySkin:
      for (final page in kBsPages) {
        if (page.id == id) return BsArticleScreen(page: page);
      }
    // ⚠️ THE READ CARRIES ITS OWN LINK AND ITS OWN "TALK" FOOT, and both are
    // injected here rather than imported by the screen — the article screen
    // must not know how to open a door. The partner piece is not in
    // `kMmArticles` (it is written to him, not her) so it is looked up
    // separately, which is also why it cannot appear on a rail by accident.
    case PvDoorLibrary.mindRead:
      final a = id == kMmPartnerArticle.id ? kMmPartnerArticle : mmArticleById(id);
      if (a == null) return null;
      return MmArticleScreen(
        article: a,
        onOpenLink: a.linkLabel == null
            ? null
            : (ctx) {
                if (a.linkArticleId case final aid?) {
                  final screen = pvDoorEntryScreen(PvDoorLibrary.mindRead, aid, c);
                  if (screen == null) return;
                  Navigator.of(ctx).push(MaterialPageRoute<void>(
                    settings: RouteSettings(
                        name: pvDoorEntryRoute(PvDoorLibrary.mindRead, aid)),
                    builder: (_) => screen,
                  ));
                } else if (a.linkDoor case final door?) {
                  openPvDoorPage(ctx, door, c, group: a.linkGroup);
                }
              },
        onTalk: (ctx) => openPvDoorSurface(
            ctx, mindSurfaceOffer('perinatal_counselling'), c),
      );
    case PvDoorLibrary.fasting:
      for (final t in [...kFastingByOccasion, ...kFastingGeneral]) {
        if (t.id == id) return const FastingScreen();
      }
  }
  return null;
}

/// The route name one library entry keeps.
///
/// ⚠️ EACH ONE IS THE PAGE'S OWN NAME FROM BEFORE THE DOORS EXISTED, because
/// `global_ask_fab.dart` reads route names to pick which stage's Ask Veda opens
/// and to suppress itself. Renaming one here would move the FAB's behaviour
/// without anything failing.
String pvDoorEntryRoute(PvDoorLibrary library, String id) =>
    switch (library) {
      PvDoorLibrary.scan => 'scans/detail',
      PvDoorLibrary.condition => 'conditions/$id',
      PvDoorLibrary.finding => 'report/$id',
      PvDoorLibrary.nutrient => 'nutrition/nutrient/$id',
      PvDoorLibrary.dietStage => 'nutrition/stage/$id',
      PvDoorLibrary.dietCondition => 'nutrition/condition/$id',
      PvDoorLibrary.recipe => 'nutrition/recipe/$id',
      PvDoorLibrary.dietChart => 'nutrition/chart/$id',
      PvDoorLibrary.fasting => 'nutrition/fasting/$id',
      PvDoorLibrary.bellySkin => 'belly_skin/$id',
      PvDoorLibrary.mindRead => 'mind/read/$id',
    };

/// Whether a library id resolves at all. Used by the wiring test, which cannot
/// build widgets for every entry on every door without a tester.
bool pvDoorEntryResolves(PvDoorLibrary library, String id) => switch (library) {
      PvDoorLibrary.scan => kTestsScans.any((e) => e.id == id),
      PvDoorLibrary.condition => kAllConditions.any((e) => e.id == id),
      PvDoorLibrary.finding => kReportFindings.any((e) => e.id == id),
      PvDoorLibrary.nutrient => kNutrientGuides.any((e) => e.id == id),
      PvDoorLibrary.dietStage => kTrimesterGuides.any((e) => e.id == id),
      PvDoorLibrary.dietCondition => kConditionGuides.any((e) => e.id == id),
      PvDoorLibrary.recipe => kRecipes.any((e) => e.id == id),
      PvDoorLibrary.dietChart => kDietCharts.any((e) => e.id == id),
      PvDoorLibrary.fasting =>
        [...kFastingByOccasion, ...kFastingGeneral].any((e) => e.id == id),
      PvDoorLibrary.bellySkin => kBsPages.any((e) => e.id == id),
      PvDoorLibrary.mindRead =>
        id == kMmPartnerArticle.id || mmArticleById(id) != null,
    };

/// Whether a surface id opens anything at all. Used by the wiring test.
bool pvDoorSurfaceResolves(String id) => switch (id) {
      kScansSurfaceTimeline ||
      kScansSurfaceNext ||
      kScansSurfaceReports ||
      kScansSurfaceDecoder ||
      kScansSurfaceUrgent ||
      kScansSurfaceQuestions ||
      kScansSurfaceConsult ||
      kScansSurfaceParameters ||
      kCondSurfaceFind ||
      kCondSurfaceSameDay ||
      kCondSurfaceJourney ||
      kCondSurfaceQuestions ||
      kDietSurfaceCanIEat ||
      kDietSurfaceRecipes ||
      kDietSurfaceCharts ||
      kDietSurfaceFasting ||
      kDietSurfaceBigger ||
      kDietSurfaceExperts ||
      kDietSurfaceQuestions ||
      kBsSurfaceChecker ||
      kBsSurfaceItching ||
      kBsSurfaceRitual ||
      kLabourSurfaceTimer ||
      kLabourSurfaceBag ||
      kLabourSurfaceCourse ||
      kLabourSurfaceBirthPlan ||
      kMindSurfaceReset ||
      kMindSurfaceCalmNote ||
      kMindSurfaceAffirmations ||
      kMindSurfaceTrack ||
      kMindSurfaceCheckIn ||
      kMindSurfaceCrisis ||
      kMindSurfaceHelplines =>
        true,
      _ when id.startsWith('mind/breathe/') =>
        kMmBreathingExercises.any((e) => mindSurfaceBreathe(e.id) == id),
      _ when id.startsWith('mind/offer/') =>
        kMmTalkOfferings.any((o) => mindSurfaceOffer(o.id) == id),
      _ => false,
    };

/// `mind/breathe/<id>` → the shared breathing circle on that exercise.
Widget? _mindBreathe(String id) {
  final exId = id.substring('mind/breathe/'.length);
  for (final ex in kMmBreathingExercises) {
    if (ex.id == exId) return MmBreathingScreen(exercise: ex);
  }
  return null;
}

/// `mind/offer/<id>` → one paid offering, price on its face.
Widget? _mindOffer(String id) {
  final oId = id.substring('mind/offer/'.length);
  for (final o in kMmTalkOfferings) {
    if (o.id == oId) return MmOfferingScreen(offering: o);
  }
  return null;
}

/// Open a door by bracket id, optionally on a tab. Used by a read that links
/// across to another area — "Fear of labour" to Labour prep's birth tab.
void openPvDoorPage(BuildContext context, String bracketId, PregnancyController c,
    {String? group}) {
  final page = pvDoorPageFor(bracketId);
  final bracket = bracketById(bracketId);
  if (page == null || bracket == null) return;
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: 'door/$bracketId'),
    builder: (_) => PvDoorScreen(
        page: page, bracket: bracket, pregnancy: c, initialGroup: group),
  ));
}

/// The Track tab as a pushable screen — a surface has to resolve both ways.
class _MindTrackScreen extends StatelessWidget {
  const _MindTrackScreen({required this.pregnancy});
  final PregnancyController pregnancy;
  @override
  Widget build(BuildContext context) => PvDoorToolScaffold(
        hue: 160,
        eyebrow: 'Mind & mood',
        title: 'How are you feeling today?',
        intro: 'A mood word, never a score. Nothing here is graded and '
            'nothing is shared.',
        children: const [MmTrackTab(embedded: true)],
      );
}


// -----------------------------------------------------------------------------
//  Two small shells
// -----------------------------------------------------------------------------
//  ⚠️ THEY EXIST BECAUSE A SURFACE MUST RESOLVE BOTH WAYS. A door surface can
//  be rendered inline on a tab AND pushed as a screen — the wiring test builds
//  both for every surface a tile names — and two of the nutrition surfaces are
//  bodies rather than screens. These give them chrome without giving them
//  content: neither adds a word that is not already in the widget it wraps.

class _CanIEatScreen extends StatelessWidget {
  const _CanIEatScreen({required this.pregnancy});

  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          return Scaffold(
            backgroundColor: p.ground,
            appBar: AppBar(
              backgroundColor: p.ground,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              foregroundColor: p.ink1,
              title: Text('Can I eat this?',
                  style: pvFraunces(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: p.ink1)),
            ),
            body: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
                children: [CanIEatBody(pregnancy: pregnancy)],
              ),
            ),
          );
        },
      );
}

class _DieticiansScreen extends StatelessWidget {
  const _DieticiansScreen();

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: V2PaletteStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          return Scaffold(
            backgroundColor: p.ground,
            appBar: AppBar(
              backgroundColor: p.ground,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              foregroundColor: p.ink1,
              title: Text('Our dieticians',
                  style: pvFraunces(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: p.ink1)),
            ),
            body: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                children: const [diet.ExpertOptionsBlock()],
              ),
            ),
          );
        },
      );
}
