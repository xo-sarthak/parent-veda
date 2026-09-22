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
import '../../data/reads/nutrition_reads.dart';
import '../../data/reads/symptom_reads.dart';
import '../../data/symptoms/symptom_library.dart' show symptomById;
import '../symptoms/door/symptoms_widgets.dart' show symptomLineMark;
import '../../data/symptoms/symptom_normal.dart' show normalQuestionById;
import '../../data/doors/pv_door_symptoms.dart';
import '../symptoms/door/symptoms_today_body.dart'
    show SymptomsTodayBody, symptomReader;
import '../symptoms/door/symptoms_week_body.dart' show SymptomsWeekBody;
import '../symptoms/door/symptoms_screens.dart';
import '../can_i_screen.dart' show CanIScreen;
import '../../models/pv_read.dart';
import '../nutrition/door/nutrition_today_body.dart';
import '../nutrition/door/nutrition_talk_body.dart';
import '../nutrition/door/nutrition_door.dart' show NutritionDoorScreen;
import '../nutrition/door/recipe_cook_screen.dart';
import '../nutrition/door/diet_chart_browse_screen.dart';
import '../nutrition/door/diet_chart_plan_screen.dart';
import '../nutrition/door/recipes_screen.dart';
import '../nutrition/door/shopping_list_screen.dart';
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
// import '../nutrition/diet_charts_screen.dart'; // the filter form, kept for revert (2026-09-20)
import '../nutrition/can_i_eat_body.dart';
import '../nutrition/fasting_screen.dart';
import '../nutrition/nutrients_screen.dart';
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
import '../../data/doors/pv_door_garbh.dart';
import '../../data/garbh_data.dart' show kPuzzles, shravanById;
import '../../data/read_to_baby_data.dart'
    show kReadAloudPieces, kRtbAffirmations;
import '../../models/garbh_content.dart' show GarbhKind, GarbhPrompt;
import '../../data/kriya_relaxation_data.dart' show kKriyaBodyAwareness;
import '../garbh_shravan_surfaces.dart' show ShravanCreditsScreen;
import '../garbh_door_surfaces.dart';
import '../garbh_journal_screen.dart';
import '../garbh_relaxation_screen.dart';
import '../garbh_ritual_screen.dart';
import '../garbh_samvad_daily.dart';
import '../garbh_screen.dart'
    show
        KriyaScreen,
        SamvadScreen,
        ShravanDetailScreen,
        ShravanScreen,
        gameForPuzzle;
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

/// A tile's OWN drawn mark, where the door has something better than its
/// format's. Null means "the format mark", which is the rule everywhere else.
///
/// ⚠️ THIS LIVES IN THE ROUTER, NOT THE DOOR ENGINE. The engine must not know
/// that symptoms exist; the router already knows every door's data, and it is
/// the one place a door's specifics are allowed. The engine asks, the router
/// answers, and a door that has nothing to say gets null.
///
/// Why it exists: By symptom is thirty-three reads, so every row wore
/// `pageMark` and the tab read as thirty-three identical brown documents (the
/// user, walking it 2026-09-22: *"we need images for this tab"*). Each row now
/// wears the symptom's own mark — the same hand as the check-in, so the two
/// tabs are visibly the same thirty-three things.
Widget? pvDoorTileArt(PvDoorTile tile, Color ink) {
  if (tile is PvDoorEntryTile && tile.library == PvDoorLibrary.symptom) {
    final s = symptomById(tile.entryId);
    if (s != null) return symptomLineMark(s, size: 22, ink: ink);
  }
  return null;
}

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
    pregnancy: c,
  ),
  // ⚠️ THE DOOR'S OWN WORDS, CARRIED IN — 2026-09-22. This passed
  // nothing, so a tile reading "Have a doctor go through it with you"
  // opened a screen titled "Learn" listing every 1:1 on the stage,
  // yoga coaching included. The tile promises a gynaecologist; the
  // role it names is now the selected filter and the sentence it
  // makes is the screen's lead.
  kScansSurfaceConsult => ConsultationsScreen(
    lang: c.language,
    onlyRole: kScanConsultRole,
    title: 'Talk it through',
    lead:
        'A gynaecologist can read the report with you, say what the '
        'numbers mean and whether anything needs doing.',
  ),

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
    intro:
        'Which report are you holding? Open it to see every reading, '
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
  kDietSurfaceRecipes => RecipesScreen(pregnancy: c), // base UI, 2026-09-20
  kDietSurfaceList => const ShoppingListScreen(),
  // Pushed forms of the two inline surfaces: the day as its own screen
  // (the standalone door from earlier that night), the rail as the grid.
  kDietSurfaceToday => NutritionDoorScreen(pregnancy: c),
  kDietSurfaceRecipeRail => RecipesScreen(pregnancy: c),
  // A door tile that points at the Is it safe? door.
  'can_i' => CanIScreen(controller: c),
  // The browser (diet_chart_browse_screen.dart). `DietChartsScreen`, the
  // filter form, is kept for revert.
  kDietSurfaceCharts => DietChartBrowseScreen(pregnancy: c),
  // The Symptoms door's pushed pages (2026-09-22).
  kSymSurfaceWeek => SymptomsWeekScreen(pregnancy: c),
  kSymSurfaceSend => SymptomsSendScreen(pregnancy: c),
  kSymSurfaceUrgent => SymptomsNormalScreen(pregnancy: c),
  kSymSurfaceCalling => const SymptomsCallingScreen(),
  kDietSurfaceFasting => const FastingScreen(),
  kDietSurfaceBigger => const NutrientsScreen(),
  kDietSurfaceExperts => const _DieticiansScreen(),
  kDietSurfaceQuestions => PvChecklistScreen(
    checklist: pvChecklistById('diet_questions')!,
    hue: 104,
    pregnancy: c,
  ),

  kCondSurfaceQuestions => PvChecklistScreen(
    checklist: pvChecklistById('condition_questions')!,
    hue: 186,
    pregnancy: c,
  ),

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

  // ---- Garbh Sanskar -------------------------------------------------
  // ⚠️ EVERY ONE OF THESE EXISTED BEFORE THE DOOR. The area's screens,
  // reused whole; two of them made public and one given a parameter so a
  // card can open the thing it names. The pillars brief rebuilds what is
  // BEHIND these ids and leaves the ids alone.
  kGarbhSurfaceRitual => GarbhRitualScreen(controller: c),
  kGarbhSurfaceListenToday => ShravanScreen(controller: c, daily: true),
  kGarbhSurfaceReadToday => GarbhSamvadDailyScreen(
    controller: c,
    onOpenLibrary: () {}, // the door's own rail is the library
  ),
  // ⚠️ THE SESSION ITSELF, since the pillars build — script, narration,
  // figure. Not the practice detail in front of it.
  kGarbhSurfaceRelax => GarbhRelaxationScreen(pregnancy: c),
  kGarbhSurfaceKriya => KriyaScreen(controller: c, daily: true),
  kGarbhSurfaceJournal => const GarbhJournalScreen(),
  kGarbhSurfaceCredits => const ShravanCreditsScreen(),
  _ when id.startsWith('garbh/listen/') => _garbhListen(id, c),
  _ when id.startsWith('garbh/read/piece/') => _garbhPiece(id, c),
  _ when id.startsWith('garbh/read/shelf/') => _garbhShelf(id, c),
  _ when id.startsWith('garbh/play/') => _garbhGame(id, c),

  _ => null,
};

/// Open one condition page directly. Used by a pinned flag's per-line taps.
void openPvDoorConditionPage(
  BuildContext context,
  String conditionId,
  PregnancyController c,
) {
  final screen = pvDoorEntryScreen(PvDoorLibrary.condition, conditionId, c);
  if (screen == null) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: 'conditions/$conditionId'),
      builder: (_) => screen,
    ),
  );
}

/// A nutrition read in the one reader: the nutrition resolver for read-next,
/// and the one action a diet-for-a-condition page carries (its condition).
Widget _nutritionReader(PvRead read, PregnancyController c) => PvReaderScreen(
  read: read,
  lang: c.language,
  resolveRead: nutritionReadById,
  openRead: (context, id) {
    final r = nutritionReadById(id);
    if (r == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: 'read/$id'),
        builder: (_) => _nutritionReader(r, c),
      ),
    );
  },
  openAction: (context, action) {
    if (action.startsWith('condition:')) {
      final cid = action.substring('condition:'.length);
      final e = kAllConditions.where((x) => x.id == cid).firstOrNull;
      if (e != null) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'conditions/detail'),
            builder: (_) => ConditionDetailScreen(entry: e, pregnancy: c),
          ),
        );
      }
    }
  },
);

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
  // ⚠️ THE DAY IS THE FIRST TAB — 2026-09-20. The plate, the ticks, the
  // glasses and the cravings as one inline body, the way My scans is the
  // timeline. See nutrition_today_body.dart.
  kDietSurfaceToday => NutritionTodayBody(pregnancy: c),
  // The dieticians, in the base UI: the nutritionist's own card and the
  // four things she can do, booked through the same sheet as every
  // consult. The old violet block (`ExpertOptionsBlock`) stays for revert.
  kDietSurfaceExperts => NutritionTalkBody(pregnancy: c),
  // The Recipes tab's tool: the library as a lead card + need chips +
  // a photo grid (recipes_screen.dart). `NutritionRecipeRail` was the
  // rail form, kept for revert.
  kDietSurfaceRecipeRail => RecipesGridBody(pregnancy: c),
  // The Symptoms door: the check-in is the first tab, the week the
  // fourth (2026-09-22).
  kSymSurfaceToday => SymptomsTodayBody(pregnancy: c),
  kSymSurfaceWeek => SymptomsWeekBody(
    pregnancy: c,
    onSend: null,
  ), // the section's Send tile does it
  kSymSurfaceNormal => SymptomsNormalBody(pregnancy: c),
  // ⚠️ THE KEEPSAKE IS THE TAB. `BumpJourneyScreen` is a Scaffold, so the
  // inline form is its body — see `BumpJourneyBody`.
  kBsSurfaceRitual => BumpRitualBody(controller: c),
  // ⚠️ THE TRACK TAB IS THE TOOL. "Do-it screens, not rails." The same
  // widget the old landing showed, as a Column.
  kMindSurfaceTrack => const MmTrackTab(embedded: true),

  // Garbh Sanskar: the journal IS the last tab; the ritual rail is the
  // one section on Today that reads a store.
  kGarbhSurfaceJournal => const GarbhJournalScreen(embedded: true),
  kGarbhSurfaceRitualRail => GarbhRitualRail(pregnancy: c),

  _ => null,
};

/// Push a surface, named.
void openPvDoorSurface(BuildContext context, String id, PregnancyController c) {
  final screen = pvDoorScreenFor(id, c);
  if (screen == null) return; // null is a real answer; see the header
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: id),
      builder: (_) => screen,
    ),
  );
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
  BuildContext context,
  PvDoorTile tile,
  PregnancyController c,
) {
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
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: pvDoorEntryRoute(library, entryId)),
          builder: (_) => screen,
        ),
      );

    // ---- a film that does not exist yet ------------------------------------
    //
    // ⚠️ UNREACHABLE, AND DELIBERATELY PRESENT. `comingSoon` is true on every
    // video tile, so `openPvDoorTile` returns before the switch. The case
    // exists because the union is sealed and the compiler demands it — and
    // because the day a film lands, this is where it plays.
    case PvDoorVideoTile():
      return;

    // A track: Mind & mood's four are coming-soon (returned above); Garbh
    // Sanskar's open their player.
    case PvDoorAudioTile(:final surfaceId):
      if (surfaceId != null) openPvDoorSurface(context, surfaceId, c);

    case PvDoorGameTile(:final surfaceId):
      openPvDoorSurface(context, surfaceId, c);

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
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: 'read/$readId'),
      builder: (_) => PvReaderScreen(
        read: read,
        // ⚠️ THE STAGE'S OWN LANGUAGE, NOT A GLOBAL. Pregnancy's flag lives on
        // the controller; reading TTC's would render Devanagari inside an English
        // shell. The reader does not guess and must not.
        lang: c.language,
        openAtHeading: atHeading,
        readTitle: pregnancyReadTitle,
        resolveRead: pregnancyReadById,
        openRead: (ctx, id) => openPvDoorRead(ctx, id, c),
        openSurface: (ctx, id) => openPvDoorSurface(ctx, id, c),
      ),
    ),
  );
}

/// The screen one library entry opens, or null when the id is not in it.
///
/// ⚠️ NULL IS A REAL ANSWER AND THE WIRING TEST MAKES IT UNREACHABLE. A bad id
/// opens nothing rather than guessing at a near match — a wrong page is worse
/// than none, because it looks like it worked.
Widget? pvDoorEntryScreen(
  PvDoorLibrary library,
  String id,
  PregnancyController c,
) {
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
    // ⚠️ THE NUTRITION LIBRARY OPENS IN THE ONE READER — 2026-09-20, the
    // consistency pass. `NutrientDetailScreen`, `StageDetailScreen`,
    // `ConditionDetailScreen` and `RecipeDetailScreen` were the old kit
    // (violet buttons, tinted boxes); they stay in their files for revert
    // and nothing reaches them. See lib/data/reads/nutrition_reads.dart.
    case PvDoorLibrary.nutrient:
      for (final n in kNutrientGuides) {
        if (n.id == id) return _nutritionReader(pvReadFromNutrient(n), c);
      }
    case PvDoorLibrary.dietStage:
      for (final g in kTrimesterGuides) {
        if (g.id == id) return _nutritionReader(pvReadFromStage(g), c);
      }
    case PvDoorLibrary.dietCondition:
      for (final g in kConditionGuides) {
        if (g.id == id) return _nutritionReader(pvReadFromDietCondition(g), c);
      }
    case PvDoorLibrary.recipe:
      for (final r in kRecipes) {
        if (r.id == id) return RecipeCookScreen(recipe: r, pregnancy: c);
      }
    case PvDoorLibrary.dietChart:
      for (final ch in kDietCharts) {
        if (ch.id == id) return DietChartPlanScreen(pregnancy: c, chart: ch);
      }
    // Fasting: eight pages at last (STILL-OPEN §35.6 → §69). Each topic is a
    // read; the general three ride as read-next on every occasion.
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
      final a = id == kMmPartnerArticle.id
          ? kMmPartnerArticle
          : mmArticleById(id);
      if (a == null) return null;
      return MmArticleScreen(
        article: a,
        onOpenLink: a.linkLabel == null
            ? null
            : (ctx) {
                if (a.linkArticleId case final aid?) {
                  final screen = pvDoorEntryScreen(
                    PvDoorLibrary.mindRead,
                    aid,
                    c,
                  );
                  if (screen == null) return;
                  Navigator.of(ctx).push(
                    MaterialPageRoute<void>(
                      settings: RouteSettings(
                        name: pvDoorEntryRoute(PvDoorLibrary.mindRead, aid),
                      ),
                      builder: (_) => screen,
                    ),
                  );
                } else if (a.linkDoor case final door?) {
                  openPvDoorPage(ctx, door, c, group: a.linkGroup);
                }
              },
        onTalk: (ctx) => openPvDoorSurface(
          ctx,
          mindSurfaceOffer('perinatal_counselling'),
          c,
        ),
      );
    case PvDoorLibrary.fasting:
      for (final t in [...kFastingByOccasion, ...kFastingGeneral]) {
        if (t.id == id) return _nutritionReader(pvReadFromFasting(t), c);
      }
    case PvDoorLibrary.dietQuestion:
      for (final q in kNutritionPracticalCards) {
        if (q.id == id) return _nutritionReader(pvReadFromDietQuestion(q), c);
      }
    // The Symptoms door (2026-09-22): both kinds open in the one reader with
    // the door's own read-next resolved.
    case PvDoorLibrary.symptom:
      final s = symptomById(id);
      if (s != null) return symptomReader(pvReadFromSymptom(s), c);
    case PvDoorLibrary.symptomNormal:
      final q = normalQuestionById(id);
      if (q != null) return symptomReader(pvReadFromNormal(q), c);
  }
  return null;
}

/// The route name one library entry keeps.
///
/// ⚠️ EACH ONE IS THE PAGE'S OWN NAME FROM BEFORE THE DOORS EXISTED, because
/// `global_ask_fab.dart` reads route names to pick which stage's Ask Veda opens
/// and to suppress itself. Renaming one here would move the FAB's behaviour
/// without anything failing.
String pvDoorEntryRoute(PvDoorLibrary library, String id) => switch (library) {
  PvDoorLibrary.scan => 'scans/detail',
  PvDoorLibrary.condition => 'conditions/$id',
  PvDoorLibrary.finding => 'report/$id',
  PvDoorLibrary.nutrient => 'nutrition/nutrient/$id',
  PvDoorLibrary.dietStage => 'nutrition/stage/$id',
  PvDoorLibrary.dietCondition => 'nutrition/condition/$id',
  PvDoorLibrary.recipe => 'nutrition/recipe/$id',
  PvDoorLibrary.dietChart => 'nutrition/chart/$id',
  PvDoorLibrary.fasting => 'nutrition/fasting/$id',
  PvDoorLibrary.dietQuestion => 'nutrition/question/$id',
  PvDoorLibrary.bellySkin => 'belly_skin/$id',
  PvDoorLibrary.mindRead => 'mind/read/$id',
  PvDoorLibrary.symptom => 'symptoms/read/$id',
  PvDoorLibrary.symptomNormal => 'symptoms/normal/$id',
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
  PvDoorLibrary.fasting => [
    ...kFastingByOccasion,
    ...kFastingGeneral,
  ].any((e) => e.id == id),
  PvDoorLibrary.dietQuestion => kNutritionPracticalCards.any((e) => e.id == id),
  PvDoorLibrary.bellySkin => kBsPages.any((e) => e.id == id),
  PvDoorLibrary.mindRead =>
    id == kMmPartnerArticle.id || mmArticleById(id) != null,
  PvDoorLibrary.symptom => symptomById(id) != null,
  PvDoorLibrary.symptomNormal => normalQuestionById(id) != null,
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
  kDietSurfaceToday ||
  kDietSurfaceRecipeRail ||
  kDietSurfaceList ||
  'can_i' ||
  kDietSurfaceRecipes ||
  kDietSurfaceCharts ||
  kDietSurfaceFasting ||
  kDietSurfaceBigger ||
  kDietSurfaceExperts ||
  kDietSurfaceQuestions ||
  kSymSurfaceToday ||
  kSymSurfaceWeek ||
  kSymSurfaceNormal ||
  kSymSurfaceSend ||
  kSymSurfaceUrgent ||
  kSymSurfaceCalling ||
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
  kMindSurfaceHelplines => true,
  _ when id.startsWith('mind/breathe/') => kMmBreathingExercises.any(
    (e) => mindSurfaceBreathe(e.id) == id,
  ),
  _ when id.startsWith('mind/offer/') => kMmTalkOfferings.any(
    (o) => mindSurfaceOffer(o.id) == id,
  ),
  kGarbhSurfaceRitual ||
  kGarbhSurfaceListenToday ||
  kGarbhSurfaceReadToday ||
  kGarbhSurfaceRelax ||
  kGarbhSurfaceKriya ||
  kGarbhSurfaceJournal ||
  kGarbhSurfaceCredits => true,
  _ when id.startsWith('garbh/listen/') =>
    shravanById(id.substring('garbh/listen/'.length)) != null,
  _ when id.startsWith('garbh/read/piece/') => _garbhPieceFor(id) != null,
  _ when id.startsWith('garbh/read/shelf/') => _garbhShelfFor(id) != null,
  _ when id.startsWith('garbh/play/') => _garbhPuzzleFor(id) != null,
  // ⚠️ A TAB OF THE SAME DOOR. The screen switches to it and nothing is
  // pushed; the door's own test checks the tab exists on that page.
  _ when id.startsWith(kPvDoorTabSurface) => true,
  _ => false,
};

// -----------------------------------------------------------------------------
//  Garbh Sanskar lookups
// -----------------------------------------------------------------------------

/// `garbh/listen/<id>` → that track on its player. The guided track is a
/// narrated script, so it opens the session, not a player.
Widget? _garbhListen(String id, PregnancyController c) {
  final a = shravanById(id.substring('garbh/listen/'.length));
  if (a == null) return null;
  if (a.kind == GarbhKind.guided) {
    return GarbhRelaxationScreen(pregnancy: c, session: kKriyaBodyAwareness);
  }
  return ShravanDetailScreen(audio: a, controller: c);
}

/// The affirmation a `garbh/read/piece/<slug>` names, as the prompt the
/// record-first screen takes. Slug from the English title — an identity.
GarbhPrompt? _garbhPieceFor(String id) {
  final slug = id.substring('garbh/read/piece/'.length);
  for (final p in kReadAloudPieces) {
    if (p.category != kRtbAffirmations) continue;
    if (garbhSlug(p.title.en) == slug) {
      return GarbhPrompt('rtb_$slug', p.title, p.body);
    }
  }
  return null;
}

Widget? _garbhPiece(String id, PregnancyController c) {
  final piece = _garbhPieceFor(id);
  if (piece == null) return null;
  return GarbhSamvadDailyScreen(controller: c, piece: piece);
}

/// `garbh/read/shelf/<n>` → 0..3, or null for anything else.
int? _garbhShelfFor(String id) {
  final n = int.tryParse(id.substring('garbh/read/shelf/'.length));
  return (n == null || n < 0 || n > 3) ? null : n;
}

/// `garbh/read/shelf/<n>` → the library open on that shelf.
Widget? _garbhShelf(String id, PregnancyController c) {
  final n = _garbhShelfFor(id);
  if (n == null) return null;
  return SamvadScreen(controller: c, initialTab: n);
}

/// `garbh/play/<slug>` → one of the four puzzles, by its English title.
({String slug, int index})? _garbhPuzzleFor(String id) {
  final slug = id.substring('garbh/play/'.length);
  for (var i = 0; i < kPuzzles.length; i++) {
    if (garbhSlug(kPuzzles[i].title.en) == slug) return (slug: slug, index: i);
  }
  return null;
}

Widget? _garbhGame(String id, PregnancyController c) {
  final hit = _garbhPuzzleFor(id);
  if (hit == null) return null;
  // ⚠️ `markComplete: false`. The door keeps no score — the old landing's
  // "Nothing here keeps score" — and a game opened from a rail is not "today's
  // practice done".
  return gameForPuzzle(kPuzzles[hit.index], c, markComplete: false);
}

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
void openPvDoorPage(
  BuildContext context,
  String bracketId,
  PregnancyController c, {
  String? group,
}) {
  final page = pvDoorPageFor(bracketId);
  final bracket = bracketById(bracketId);
  if (page == null || bracket == null) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: 'door/$bracketId'),
      builder: (_) => PvDoorScreen(
        page: page,
        bracket: bracket,
        pregnancy: c,
        initialGroup: group,
      ),
    ),
  );
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
    intro:
        'A mood word, never a score. Nothing here is graded and '
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
          title: Text(
            'Can I eat this?',
            style: pvFraunces(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: p.ink1,
            ),
          ),
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
          title: Text(
            'Our dieticians',
            style: pvFraunces(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: p.ink1,
            ),
          ),
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
