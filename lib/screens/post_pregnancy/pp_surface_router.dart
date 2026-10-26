// =============================================================================
//  Parenting surface router — the parenting half of what app_structure lacks
// -----------------------------------------------------------------------------
//  Sibling of `lib/services/surface_router.dart`, which does the same job for
//  pregnancy. Separate file rather than more cases in that switch, for the
//  reason the whole stage separation exists: the pregnancy router imports
//  `lib/screens/tools/*` and this one imports `post_pregnancy/*`, and merging
//  them would make every pregnancy build compile the parenting tree.
//
//  ⚠️ EVERY ENTRY IS A SCREEN THAT ALREADY SHIPS. Nothing here is new. The
//  bracket rows were doing nothing at all until this file existed — deliberately
//  nothing rather than something wrong, because a door that opens the WRONG
//  screen teaches her the app is unreliable and costs more than one that has not
//  opened yet.
//
//  NULL IS A REAL ANSWER. A few surfaces are hubs with no single screen, and a
//  router that invented a destination for them would be worse than one that
//  admits it.
// =============================================================================

import 'package:flutter/material.dart';
// import 'recipes_screen.dart'; // kept for revert with the pp_food line

import 'pp_section_registry.dart';
import 'pp_section_screen.dart';
import 'askveda_screen.dart';
// import 'leap_calendar_screen.dart'; // retired 2026-10-14, kept for revert
import 'phase_map_screen.dart';
import '../memories/memories_home_screen.dart';
import 'health_doctor_visit_screen.dart';
// import 'health_emergency_screen.dart'; // kept for revert with the pp_emergency_card route
import 'wallet_v2_screens.dart' show WalletEmergencyCardScreen;
import 'pp_mood_check_screen.dart';
import 'health_home_screen.dart';
import 'pp_baby_food_check_screen.dart';
import 'pp_maa_can_i_screen.dart';
import 'pp_search.dart';
import 'pp_nappy_screen.dart';
import 'pp_pump_screen.dart';
import 'pp_breast_timer_screen.dart';
import 'pp_care_history_screen.dart';
import 'pp_tummy_time_screen.dart';
import 'pp_month_checklist_screen.dart';
import 'pp_baby_ok_check_screen.dart';
import 'pp_fever_check_screen.dart';
import 'pp_crisis_path_screen.dart';
import 'pp_age_bands.dart';
import 'pp_chart_browser_screen.dart';
// import 'pp_feeding_content.dart'; // only the chooser version needs it (kept for revert)
import 'products_compare_screen.dart';
// import 'pp_products_data.dart' show ppPreloadCompare; // kept for revert
import '../../data/products/pv_catalog_adapters.dart' show pvSlug;
import '../../data/products/pv_sheet_products.dart'
    show SheetToy, kSheetToyCategoryId, sheetToySubId;
import '../../data/products/sheet/toys.dart' show kSheetToys;
import 'learning_detail_screen.dart' show LearningDetailScreen;
import 'pp_child_profile.dart' show ChildProfileStore;
import 'pp_learning_data.dart' show kLearningPrograms, programById;
import '../../services/pv_catalog_store.dart';
import '../../widgets/pv_toast.dart';
import '../products/pv_shelf_screen.dart' show PvShelfScreen;
import '../../services/pv_compare_store.dart';
import 'pp_sounds_screen.dart';
import 'pp_wake_windows_screen.dart';
import 'pp_what_to_feed_screen.dart';
import 'remedy_list_screen.dart';
import '../../data/doors/pp_door_data.dart';
import 'doors/pp_door_screen.dart';

// import '../product_guide/product_guide_hub_screen.dart'; // kept for revert (tools pass 32): pp_product_guide opens the guides
import 'baby_naming_home_screen.dart';
import 'development_home_screen.dart';
import 'feeding_journey_screen.dart';
import 'growth_journey_screen.dart';
import 'learning_home_screen.dart';
import 'milestone_journey_screen.dart';
import 'nuskhe_screen.dart';
import 'problem_solver_screen.dart';
import 'products_discovery_screen.dart';
import 'pp_experts_data.dart' show kFindHelpNeeds, categoryIsSeededOnly;
import 'pp_yoga_data.dart' show kYogaClasses, kYogaAfterCheckIds, yogaClassById;
import 'yoga_class_screen.dart' show YogaClassScreen;
import '../../data/mind_mood_data.dart' show kCrisisHelplineName, kCrisisHelplineNumber;
import 'pp_community_detail_screen.dart';
import 'community_screen.dart';
import '../../data/community_data.dart' show kParentingCommunities;
import '../../data/kids_books.dart' show KidsBookRank, kKidsBooks;
import 'development_all_activities_screen.dart';
import 'pp_development_data.dart' show kDevAreas;
// import 'on_track_checklist_screen.dart'; // merged into the journey, kept for revert
import 'development_checkin_screen.dart';
import 'scripts_library_screen.dart';
import 'find_help_triage_screen.dart';
import 'provider_results_screen.dart';
import 'reading_home_screen.dart';
import 'reading_reader_screen.dart' show ReadingReaderScreen;
import 'pp_reading_data.dart' show readArticleById;
import '../../data/book_companions.dart' show kBookDocsByShelfId;
import 'sleep_journey_screen.dart';
import 'vax_tracker_screen.dart';
import 'watch_home_screen.dart';
import 'what_changed_screen.dart';
import 'yoga_home_screen.dart';
import 'pp_recipes_screen.dart';
import 'pp_buying_guides_screen.dart';
// The one tool shared with pregnancy: Kegel Care reads the stage itself and
// runs its after-birth mode here (2026-10-16).
import '../tools/kegel_care_screen.dart' show KegelCareScreen;

/// ⚠️ A SECTION IS A SURFACE TOO, AND IT RESOLVES BEFORE THE HAND-WRITTEN LIST.
///
/// The eleven parenting content sections live in `kPpSections`, keyed by their
/// bracket id. Rather than adding eleven near-identical `case`s below, any id of
/// the form `pp_section/<bracketId>` resolves straight out of the registry --
/// so registering a section is the whole of wiring it, and the wiring gate
/// cannot be half-satisfied by someone who added the data and forgot the route.
///
/// The section screen needs to open surfaces itself (its links and tools point
/// at real screens), so it is handed this same function. That recursion is fine
/// and bounded: a section never contains another section.
// =============================================================================
//  ⚠️ NO SILENT TAP (step 0 · S8, 2026-10-25). The user: "if some action is
//  not able to take place due to unavailability ... make sure user gets a
//  toast notification, so that the user can understand why a tap didn't
//  work." Every parenting opener used to end `if (screen == null) return;`,
//  so a link to something not built yet did nothing at all. They all call
//  this now: it pushes the screen, or says in plain words why it can't and
//  what happens next.
//
//  Three cases are decided before the router is asked, because the router
//  would answer them with the wrong screen rather than none:
//    S8b  an expert type we don't have yet (`pp_experts/<category>` that is
//         not in `kFindHelpNeeds`): the router's unfiltered roster would be
//         the wrong list. The notice names the nearest one we do have, with
//         a pill to it.
//    S8c  a shop shelf (`pp_products/<shelf>`): opens that shelf when it has
//         products, else says we're still choosing.
//    S8d  a class or course by id (`pp_class/<name>`) that isn't open: says
//         so, with Tell me.
// =============================================================================

/// Where an expert type we don't have yet sends her instead (S8b). The
/// master plan's nearest map.
const Map<String, String> kPpNearestExpert = {
  'Dentist': 'Pediatrician',
  'Paediatric dentist': 'Pediatrician',
  'Eye': 'Pediatrician',
  'Ophthalmologist': 'Pediatrician',
  'ENT': 'Pediatrician',
  'Audiologist': 'Pediatrician',
  'Allergist': 'Pediatrician',
  'Chest': 'Pediatrician',
  'Hormone': 'Pediatrician',
  'Developmental paediatrician': 'Pediatrician',
  'Feeding therapist': 'Speech therapist',
  'Occupational therapist': 'Special needs expert',
  // Was 'Physiotherapist': her postnatal physios, never a baby's (DV7).
  'Paediatric physio': 'Pediatrician',
};

/// ⚠️ THE OWED SPECIALISTS, IN WORDS A PARENT READS (Health H5, 2026-10-25).
/// The notice lowercased the category and added an "s", which made "ENT"
/// into "ents" and "Eye" into "eyes". The seven roles Health's pages point
/// at before real profiles exist, named the way an Indian parent is
/// referred: no invented people, only the invitation.
const Map<String, String> kPpOwedExpertPlural = {
  'Paediatric dentist': 'paediatric dentists',
  'Dentist': 'paediatric dentists',
  'Ophthalmologist': "children's eye doctors",
  'Eye': "children's eye doctors",
  'ENT': "children's ENT doctors",
  'Audiologist': 'audiologists',
  'Allergist': "children's allergy doctors",
  'Chest': "children's chest doctors",
  'Hormone': "children's hormone doctors",
  // Development's Sit, crawl, walk row and the movement-signs page (DV7).
  'Paediatric physio': 'paediatric physios',
};

/// ⚠️ A SHELF THAT IS NOT OURS TO STOCK YET, SAID PLAINLY (Health §11). For
/// small equipment any chemist has, "we're still choosing" reads as "wait
/// for us", which is wrong when the parent needs it tonight.
const Map<String, String> kPpShelfNotYet = {
  'Underarm thermometers': "We haven't picked an underarm thermometer yet. "
      'Any digital one with a flexible tip works.',
  'Nasal aspirators': 'Not in our shop yet. A chemist will have one.',
  'Oral syringes': 'Not in our shop yet. A chemist will have one.',
  'Mosquito nets': 'Not in our shop yet. A chemist will have one.',
  'Finger toothbrushes': 'Not in our shop yet. A chemist will have one.',
  'Baby nail clippers': 'Not in our shop yet. A chemist will have one.',
  'Lice combs': 'Not in our shop yet. A chemist will have one.',
  'Sun hats and sunscreen': 'Not in our shop yet. A chemist will have one.',
  'Health record folders': 'Not in our shop yet. Any plastic folder works.',
  // Potty (PT4): the shop has no potty yet, so the tap carries the page's tip.
  'Potties': "We haven't picked potties yet. Look for a wide, stable base, "
      'feet flat on the floor, and no splash-guard edge that pinches.',
  'Travel potties': "We haven't picked travel potties yet. A folding one that "
      'fits a bag, and a stool for the squat, are the two to look for.',
  // First 40 (FD5, FD12): no oil and no belt are stocked. The oil words
  // match the page they point to (`f40_which_oil`, the one source).
  'Baby massage oils': "We haven't picked oils yet. A plain, fragrance-free "
      "coconut or sunflower oil from your kitchen is fine. See 'Which "
      "massage oil?'.",
  'Postpartum belts': 'Not in our shop yet. Ask your doctor first after a '
      'C-section.',
  // Sleep (SL5): none stocked, so the tap carries the page's tip.
  'Night lights': "We haven't picked night lights yet. A dim, warm-coloured "
      'one, low down and out of reach, is the kind to look for.',
  'Room thermometers': "We haven't picked room thermometers yet. Any simple "
      'digital one works. A room comfortable for you in light clothes is '
      'about right.',
};

/// ⚠️ A TARGET WE HAVE NOT BUILT, NAMED FOR WHAT IT IS (Potty PT4). The
/// generic "This isn't ready yet" is true and useless; these say what is
/// missing and where the help is meanwhile. Surface id -> the words.
Map<String, String> get kPpNotYetWords => {
      'pp_product_guide/Potties': "We haven't written the potty guide yet. "
          'What to check is on this page: a low potty, and feet flat on the '
          'floor.',
      // There is a book list but no screen for it yet; name two from it.
      // 'pp_books/Potty': "We haven't put picture books in the app yet. "
      //     '${_bookPair('Potty')} are two that children like.', // kept for revert (tools pass 33)
      // ⚠️ IT SAID "NO PICTURE BOOKS" WHILE 285 SAT ON THE READING SHELF.
      // There is no potty shelf of its own yet, and that is all it now says.
      'pp_books/Potty': 'Picture books are on the Reading shelf, under More. '
          'For potty time, ${_bookPair('Potty')} are two that children like.',
      // Behaviour BH5: the kids library, by its goal, in the same words.
      'pp_books/Worry': 'Picture books are on the Reading shelf, under More. '
          'For worries, ${_bookPairForGoal('Anxiety')} are two that children '
          'like.',
      'pp_books/New sibling': 'Picture books are on the Reading shelf, under '
          'More. For a new baby, ${_bookPairForGoal('New Sibling')} are two '
          'that children like.',
    };

/// The same as [_bookPair], by the list's goal rather than its theme: the
/// worry books are themed "Emotions" or "Connection" but share one goal.
String _bookPairForGoal(String goal) {
  final titles = [
    for (final b in kKidsBooks)
      if (b.goals.contains(goal) && b.rank == KidsBookRank.essential) b.title,
  ];
  return titles.length < 2 ? 'The ones in any bookshop' : '${titles[0]} and ${titles[1]}';
}

/// Two titles from the book list for a theme: "Once Upon a Potty and Potty
/// for Me!". The list is the source, so a title is never invented.
String _bookPair(String theme) {
  final titles = [
    for (final b in kKidsBooks)
      if (b.theme == theme && b.rank == KidsBookRank.essential) b.title,
  ];
  return titles.length < 2 ? 'The ones in any bookshop' : '${titles[0]} and ${titles[1]}';
}

/// ⚠️ A ROSTER OF PLACEHOLDERS ONLY, SAID PLAINLY (You, Maa §12, M6,
/// 2026-10-25). Her physio and counsellor rows open categories whose people
/// are all `Expert.seeded` today. Opening them showed made-up profiles to a
/// mother asking for real help. Until a real person joins, the tap says so
/// and points at the gynaecologists, who are real. The counsellor line
/// names the free helpline first, as every mind page does (M5). Category ->
/// (words, where the pill goes).
const Map<String, (String, String)> kPpJoiningSoon = {
  'Physiotherapist': (
    "Our women's health physios are joining soon. A gynaecologist can help "
        'today.',
    'Gynecologist',
  ),
  'Maternal mental health': (
    'Our perinatal counsellors are joining soon. $kCrisisHelplineName on '
        '$kCrisisHelplineNumber is free, any hour. A gynaecologist can help '
        'today.',
    'Gynecologist',
  ),
  // Development's On track row (DV7): the developmental paediatricians are
  // placeholder profiles until real people join.
  'Development expert': (
    'Our developmental paediatricians are joining soon. A paediatrician can '
        'check this first.',
    'Pediatrician',
  ),
};

/// "Toys for this age" (Development DV6). `pp_toys/<category>` opens one
/// kind, by the toy sheet's own category name.
const String kPpToys = 'pp_toys';

/// ⚠️ "TOYS AND CRAYONS", THE SHELF EARLY LEARNING PROMISED (EL7, built in
/// the tools pass, 33). `pp_recos` opened the whole Products tab over the
/// door, with no back button, under a name that promised story boxes nobody
/// stocks. It keeps its id (the brackets name it) and opens one toy shelf of
/// the six kinds EL7 named, his age first, the store's own chips for the six.
const List<String> kPpToysAndCrayonsKinds = [
  'Montessori', 'Crayons', 'Language & Literacy', 'Play Dough', 'Craft Kits', 'Puzzles',
];

Widget ppToysAndCrayonsScreen() => PvShelfScreen(
      categoryId: kSheetToyCategoryId,
      title: 'Toys and crayons',
      subIds: {
        for (final t in kSheetToys)
          if (kPpToysAndCrayonsKinds.contains(t.category)) sheetToySubId(t),
      },
    );

/// The toys the sheet gives an age that fits his (corrected) age. A toy with
/// no age on the sheet suits every child and is not counted: "toys for this
/// age" must mean toys someone picked for it.
List<SheetToy> ppToysForAge([int? months]) {
  final m = months ?? ChildProfileStore.instance.devAgeInMonths;
  return [
    for (final t in kSheetToys)
      if (t.ageMin != null && t.ageMax != null && m >= t.ageMin! && m <= t.ageMax!) t,
  ];
}

/// The card "10 minutes for you today" on You, Maa's Today tab (M1).
const String kPpMaaTenMinutes = 'pp_maa_ten_minutes';

/// The one session picked for her week (plan §1). Breath and a walk before
/// her six-week check; the pelvic floor, then the deep core; then strength.
String ppMaaTenMinutesTarget() =>
    switch (kPpPostpartumBands.active.id) {
      'pp_0_6w' => 'pp_page/parenting_maternal/pf_ex_breathing',
      'pp_6w_3m' => 'pp_yoga/co_pelvic_rec',
      'pp_3_6m' => 'pp_yoga/co_deepcore_rec',
      _ => 'pp_page/parenting_maternal/move_getting_stronger',
    };

/// The words a tap says when its target is not there yet (S8). Null when the
/// target is there. Pure, so a test can hold every case.
String? ppSurfaceUnavailable(String id) {
  // An after-check class for a mother still in her first six weeks (You,
  // Maa §12). The Yoga hub labels them; a direct link must say it too.
  const yogaPrefix = 'pp_yoga/';
  if (id.startsWith(yogaPrefix) &&
      kYogaAfterCheckIds.contains(id.substring(yogaPrefix.length)) &&
      kPpPostpartumBands.active.id == 'pp_0_6w') {
    return 'This class opens after your six-week check. Breathing and short '
        'walks are the right start for now.';
  }
  if (id == kPpMaaTenMinutes) return ppSurfaceUnavailable(ppMaaTenMinutesTarget());
  const expertPrefix = 'pp_experts/';
  if (id.startsWith(expertPrefix)) {
    final category = id.substring(expertPrefix.length);
    if (kPpJoiningSoon[category] case (final words, _)
        when categoryIsSeededOnly(category)) {
      return words;
    }
    if (kFindHelpNeeds.any((n) => n.category == category)) return null;
    final near = kPpNearestExpert[category] ?? 'Pediatrician';
    final nearLabel = kFindHelpNeeds
            .where((n) => n.category == near)
            .map((n) => n.label)
            .firstOrNull ??
        'Paediatrician';
    final who = kPpOwedExpertPlural[category] ?? '${category.toLowerCase()}s';
    return "We're adding $who. A ${nearLabel.toLowerCase()} can check this first.";
  }
  // A guide not written yet (tools pass 32, S8): says so, never silent.
  const guidePrefix = 'pp_buying_guides/';
  if (id.startsWith(guidePrefix) && ppBuyingGuideScreen(id.substring(guidePrefix.length)) == null) {
    return "We haven't written that guide yet. The others are in the Product guide.";
  }
  const shopPrefix = 'pp_products/';
  if (id.startsWith(shopPrefix)) {
    final shelf = id.substring(shopPrefix.length);
    final subId = pvSlug(shelf);
    final stocked = PvCatalogStore.instance.all.any((p) => p.subId == subId);
    if (stocked) return null;
    return kPpShelfNotYet[shelf] ??
        "We're still choosing good ${shelf.toLowerCase()}. They'll be in the Store soon.";
  }
  // Toys for his age (Development DV6, S8c). An age with no toy picked says
  // so, and points at the house instead of an empty shelf.
  if (id == kPpToys && ppToysForAge().isEmpty) {
    return "We're still choosing toys for this age. Everyday things at home "
        'work just as well.';
  }
  const toysPrefix = '$kPpToys/';
  if (id.startsWith(toysPrefix) &&
      !kSheetToys.any((t) => t.category == id.substring(toysPrefix.length))) {
    return "We're still choosing toys for this age. Everyday things at home "
        'work just as well.';
  }
  // A course by id (S8d): one that does not exist says so.
  const learnPrefix = 'pp_learn/';
  if (id.startsWith(learnPrefix) &&
      !kLearningPrograms.any((p) => p.id == id.substring(learnPrefix.length))) {
    return "This course isn't open yet. We're adding it to ParentVeda soon.";
  }
  const classPrefix = 'pp_class/';
  if (id.startsWith(classPrefix)) {
    return "This class isn't open yet. Tap Tell me and we'll let you know.";
  }
  if (kPpNotYetWords[id] case final words?) return words;
  if (ppScreenForSurface(id) == null) {
    return "This isn't ready yet. We're adding it to ParentVeda soon.";
  }
  return null;
}

/// Opens a parenting surface, or says why it can't (S8). The one opener.
void ppPushSurface(BuildContext context, String surfaceId) {
  final why = ppSurfaceUnavailable(surfaceId);
  if (why != null) {
    const expertPrefix = 'pp_experts/';
    if (kPpJoiningSoon[surfaceId.replaceFirst(expertPrefix, '')]
        case (_, final near) when surfaceId.startsWith(expertPrefix)) {
      pvToast(context, why,
          action: 'See one',
          onAction: () => ppPushSurface(context, '$expertPrefix$near'));
    } else if (surfaceId.startsWith('pp_yoga/')) {
      pvToast(context, why,
          action: 'Breathing',
          onAction: () => ppPushSurface(
              context, 'pp_page/parenting_maternal/pf_ex_breathing'));
    } else if (surfaceId.startsWith(expertPrefix)) {
      final near =
          kPpNearestExpert[surfaceId.substring(expertPrefix.length)] ??
              'Pediatrician';
      pvToast(context, why,
          action: 'See them',
          onAction: () => ppPushSurface(context, '$expertPrefix$near'));
    } else if (surfaceId.startsWith('pp_class/')) {
      pvToast(context, why,
          action: 'Tell me',
          onAction: () => pvToast(context, "We'll let you know when it opens.",
              kind: PvToastKind.done));
    } else {
      pvToast(context, why);
    }
    return;
  }
  final screen = ppScreenForSurface(surfaceId);
  if (screen == null) return; // unreachable: ppSurfaceUnavailable said so
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: surfaceId),
    builder: (_) => screen,
  ));
}

Widget? ppScreenForSurface(String id) {
  // `pp_activities/<areaId>` opens Activities on that area's chip (tools pass,
  // Development, 2026-10-25): "Talking activities for this age" used to land
  // on the top of every area.
  const activitiesPrefix = 'pp_activities/';
  if (id.startsWith(activitiesPrefix)) {
    final area = id.substring(activitiesPrefix.length);
    if (!kDevAreas.any((a) => a.id == area)) return const DevelopmentAllActivitiesScreen();
    return DevelopmentAllActivitiesScreen(area: area);
  }

  // ⚠️ `pp_food/<preset>` LANDS ON THAT FILTER (tools pass, Food, D6,
  // 2026-10-25). "Sick day recipes" and "Recipes for 9 to 12 months" opened
  // the top of Recipes. The preset shows as a chip she can clear; one nobody
  // wrote falls back to the plain screen (`ppRecipePreset` returns null).
  const foodPrefix = 'pp_food/';
  if (id.startsWith(foodPrefix)) {
    return PpRecipesScreen(preset: id.substring(foodPrefix.length));
  }

  // ⚠️ `pp_products/<shelf>` OPENS THAT SHELF (S8c, 2026-10-25). It used to
  // fall through to nothing. An unstocked shelf is caught by
  // `ppSurfaceUnavailable` before this is asked.
  const shopPrefix = 'pp_products/';
  if (id.startsWith(shopPrefix)) {
    final subId = pvSlug(id.substring(shopPrefix.length));
    final hit = PvCatalogStore.instance.all.where((p) => p.subId == subId).firstOrNull;
    if (hit == null) return null;
    return PvShelfScreen(categoryId: hit.categoryId, subId: subId);
  }

  // ⚠️ `pp_experts/<category>` OPENS THE ROSTER ALREADY FILTERED.
  //
  // Feedback: "Talk to a lactation expert should land user to 1 on 1 call with
  // lactation expert filter applied." It was opening the whole roster — the
  // paediatrician, the sleep coach, the child psychologist and the lactation
  // consultants together — from a door that had just named one of them. This
  // is the same defect the pregnancy side fixed on its scan and nutrition
  // consults, and it is worth stating the general form: landing on the right
  // SCREEN with the wrong LIST is a failure the wiring gate does not catch,
  // because the tap works.
  //
  // An unknown category falls through to the unfiltered roster rather than a
  // blank screen — wrong-but-useful beats right-but-empty, and
  // `test/pp_consult_filter_test.dart` fails on a category that matches no
  // expert, so a typo is caught in CI and not by a parent.
  const expertPrefix = 'pp_experts/';
  if (id.startsWith(expertPrefix)) {
    final category = id.substring(expertPrefix.length);
    for (final n in kFindHelpNeeds) {
      if (n.category == category) return ProviderResultsScreen(need: n);
    }
    return const ProviderResultsScreen();
  }

  // ⚠️ `pp_page/<sectionId>/<pageId>` OPENS ONE PAGE OF ANOTHER SECTION.
  //
  // The Health rebuild makes the choking response canonical in Health and
  // has Feeding link to it. A `PpLink(pageId:)` resolves only within its own
  // section, so a cross-section reference needs a surface — and it should
  // land on the PAGE, not on the other door's tab, or the parent reading
  // about choking at the table gets a selector to work through first.
  // `pp_scripts/<id>` opens What to say on that script (tools pass 29, BH2).
  // The six Behaviour page links opened the whole tool and left her to find
  // the one they named. An unknown id opens the tool as it always did.
  const scriptsPrefix = 'pp_scripts/';
  if (id.startsWith(scriptsPrefix)) {
    return ScriptsLibraryScreen(initialScriptId: id.substring(scriptsPrefix.length));
  }

  // `pp_buying_guides/<key>` opens one "how to choose" guide in the reader,
  // with its "Shop this" (tools pass 32). Feeding's "Compare breast pumps"
  // uses it. A guide not written yet is answered by `ppSurfaceUnavailable`.
  const guidePrefix = 'pp_buying_guides/';
  if (id.startsWith(guidePrefix)) {
    return ppBuyingGuideScreen(id.substring(guidePrefix.length));
  }

  // `pp_book/<shelf id>` opens one book summary in the Reading shelf's own
  // reader, which hands a book to its companion (Behaviour BH5). An unknown
  // id is null, never the reader's fallback article, so a typo fails the
  // link gate instead of opening the wrong book.
  const bookPrefix = 'pp_book/';
  if (id.startsWith(bookPrefix)) {
    final shelfId = id.substring(bookPrefix.length);
    return kBookDocsByShelfId.containsKey(shelfId)
        ? ReadingReaderScreen(article: readArticleById(shelfId))
        : null;
  }

  const pagePrefix = 'pp_page/';
  if (id.startsWith(pagePrefix)) {
    final rest = id.substring(pagePrefix.length);
    final slash = rest.indexOf('/');
    if (slash > 0) {
      final section = ppSectionFor(rest.substring(0, slash));
      final page = section?.pageById(rest.substring(slash + 1));
      if (section != null && page != null) {
        if (page.toolSurfaceId case final tool?) return ppScreenForSurface(tool);
        return ppPageScreen(section, page, onSurface: ppPushSurface); // was a silent opener (S8)
      }
    }
    return null;
  }

  // `pp_maa_can_i/<category>` opens Can I...? on one chip (tools 25-28,
  // 2026-10-25), beside `pp_food/<preset>`. The door's medicines page said
  // "Search more" and landed on all 340 answers. An unknown category opens
  // the plain screen.
  const canIPrefix = 'pp_maa_can_i/';
  if (id.startsWith(canIPrefix)) {
    final cat = id.substring(canIPrefix.length);
    return PpMaaCanIScreen(
        initialCategory: kPpMaaCanICategories.contains(cat) ? cat : null);
  }

  // ⚠️ `pp_yoga/<classId>` OPENS ONE CLASS (You, Maa §6, 2026-10-25). A
  // page that says "the Pelvic-Floor Daily Ten" used to open the whole Yoga
  // hub, and Feeding owed the same route (FD13). An unknown id opens the hub
  // rather than `yogaClassById`'s silent first class.
  const yogaPrefix = 'pp_yoga/';
  if (id.startsWith(yogaPrefix)) {
    final classId = id.substring(yogaPrefix.length);
    if (!kYogaClasses.any((c) => c.id == classId)) {
      return const YogaHomeScreen(backLabel: 'Back');
    }
    return YogaClassScreen(cls: yogaClassById(classId));
  }

  // ⚠️ `pp_toys` OPENS THE TOY SHELF, `pp_toys/<category>` ONE KIND OF TOY
  // (Development DV6, 2026-10-25). The shop ranks his age first; an age or
  // a kind with nothing picked is answered by `ppSurfaceUnavailable` (S8c).
  if (id == kPpToys) {
    return const PvShelfScreen(categoryId: kSheetToyCategoryId);
  }
  if (id.startsWith('$kPpToys/')) {
    final kind = id.substring(kPpToys.length + 1);
    final toy = kSheetToys.where((t) => t.category == kind).firstOrNull;
    if (toy == null) return null;
    return PvShelfScreen(categoryId: kSheetToyCategoryId, subId: sheetToySubId(toy));
  }

  // ⚠️ `pp_learn/<programId>` OPENS ONE COURSE (Development DV7). "Play and
  // Brain" opened the whole Learn home; a course that is opening soon opens
  // its own page, which says so and offers Reserve.
  const learnPrefix = 'pp_learn/';
  if (id.startsWith(learnPrefix)) {
    final pid = id.substring(learnPrefix.length);
    if (!kLearningPrograms.any((p) => p.id == pid)) return null;
    return LearningDetailScreen(program: programById(pid));
  }

  // ⚠️ "10 MINUTES FOR YOU TODAY" OPENS THE SESSION FOR HER WEEK (You, Maa
  // M1). One card, one target that follows her band, rather than four cards
  // of the same name of which three would sit folded at the foot.
  if (id == kPpMaaTenMinutes) {
    return ppScreenForSurface(ppMaaTenMinutesTarget());
  }

  // ⚠️ `pp_community/<roomId>` OPENS ONE ROOM. The You, Maa section's
  // "open your circle" links were `null` surfaces for want of this; the
  // room is data in `community_data.dart`, the screen is the one every
  // room uses.
  const roomPrefix = 'pp_community/';
  if (id.startsWith(roomPrefix)) {
    final roomId = id.substring(roomPrefix.length);
    for (final c in kParentingCommunities) {
      if (c.id == roomId) return PpCommunityDetailScreen(community: c);
    }
    return const CommunityScreen();
  }
  // ⚠️ `pp_compare/<shelf>` ARRIVES WITH THE SHELF LOADED. Seven links across
  // Health and First 40 Days said "compare swaddles" and opened the compare
  // tray empty, because the route took no argument. The tray is the Compare
  // Manager's state, so the router seeds it: that shelf's products, up to the
  // tray's limit, replacing whatever was there. The bare `pp_compare` keeps
  // its empty state. (The What to buy brief, 2026-09-14.)
  const comparePrefix = 'pp_compare/';
  if (id.startsWith(comparePrefix)) {
    final shelf = id.substring(comparePrefix.length);
    // The unified tray, seeded from the unified shelf. `shelf` arrives as the
    // sub's display name ('Soothers & white noise'); the unified ids are its
    // slug. Kept for revert: ppPreloadCompare(shelf).
    final subId = pvSlug(shelf);
    PvCompareStore.instance.preload(
        PvCatalogStore.instance.all.where((p) => p.subId == subId));
    return const ProductsCompareScreen();
  }
  // ⚠️ `pp_nuskhe/<category>` OPENS THE REMEDIES ALREADY FILTERED. The Health
  // brief single-sources home remedies: "every per-illness remedy card
  // elsewhere references this, filtered." The old per-illness card pages
  // were second copies of the same remedies.
  const nuskhePrefix = 'pp_nuskhe/';
  // ⚠️ `pp_what_changed/<entry>` OPENS THE ONE CHECKER PRE-FILTERED. The
  // Behaviour door's tool lands on the Behaviour and Mood concerns with the
  // full list one tap away, which is what the home's dead switch arm meant
  // to do and never could (the section guard returns first). One checker,
  // an entry context, no copy.
  const whatChangedPrefix = 'pp_what_changed/';
  if (id.startsWith(whatChangedPrefix)) {
    final entry = id.substring(whatChangedPrefix.length);
    return switch (entry) {
      'behaviour' => const WhatChangedScreen(
          initialCategories: ['Behaviour', 'Mood']),
      _ => const WhatChangedScreen(),
    };
  }
  if (id.startsWith(nuskhePrefix)) {
    return RemedyListScreen(category: id.substring(nuskhePrefix.length));
  }

  const sectionPrefix = 'pp_section/';

  // ⚠️ A SECTION WITH A DOOR OPENS ITS DOOR, NOT ITS LIBRARY. Every link that
  // named the Sleep library (`pp_section/parenting_sleep`, or one of its
  // areas) now lands on the door, on the tab that holds that area. The
  // library screen stays the engine for the nine sections without a door;
  // for Sleep it is unreachable rather than deleted, so a second shell never
  // sits behind the first.
  if (id.startsWith(sectionPrefix)) {
    final rest = id.substring(sectionPrefix.length);
    final slash = rest.indexOf('/');
    final sectionId = slash > 0 ? rest.substring(0, slash) : rest;
    final door = ppDoorFor(sectionId);
    if (door != null) {
      final area = slash > 0 ? rest.substring(slash + 1) : null;
      return PpDoorScreen(
        door: door,
        initialTabId: area == null ? null : door.tabFor(area)?.id,
        onSurface: ppPushSurface, // was a silent opener (S8)
      );
    }
  }

  if (id.startsWith(sectionPrefix)) {
    // ⚠️ `pp_section/<bracketId>/<areaId>` OPENS STRAIGHT INTO ONE AREA.
    //
    // Added because Potty's two hub doors — "Is she ready yet?" and "Start and
    // manage potty training" — both resolved to the bare section id and
    // therefore to the same landing. Third time this review has found that
    // shape, and always the same cause: the section was addressable and the
    // area was not.
    final rest = id.substring(sectionPrefix.length);
    final slash = rest.indexOf('/');
    if (slash > 0) {
      final section = ppSectionFor(rest.substring(0, slash));
      if (section != null) {
        return PpSectionScreen(
          section: section,
          // Same handler the bare-section branch below uses. Kept inline
          // rather than hoisted, because hoisting it would mean a top-level
          // function that pushes routes, and the two call sites are twelve
          // lines apart.
          onSurface: ppPushSurface, // was a silent opener (S8)
          initialAreaId: rest.substring(slash + 1),
        );
      }
    }
  }
  if (id.startsWith(sectionPrefix)) {
    final section = ppSectionFor(id.substring(sectionPrefix.length));
    if (section == null) return null;
    return PpSectionScreen(
      section: section,
      onSurface: ppPushSurface, // was a silent opener (S8)
    );
  }
  return _ppScreenFor(id);
}

Widget? _ppScreenFor(String id) => switch (id) {
      // ---- New surfaces the sections need -----------------------------------
      'pp_sleep_sounds' => const PpSoundsScreen(),
      // The Sleep door rebuild's one new tool. Opens on her window and asks
      // for nothing — see the screen's own header for why it is not a timer.
      'pp_wake_windows' => const PpWakeWindowsScreen(),
      // ⚠️ BOTH OF THESE ARE THE SAME SCREEN. They read their own section's
      // chart cards rather than holding a second copy of numbers that are marked
      // REQUIRED_REVIEW and expected to be corrected. Two bespoke screens would
      // have drifted the first time either was touched.
      'pp_sleep_check' => PpChartBrowserScreen(
          sectionId: 'parenting_sleep',
          bands: kPpSleepBands,
          title: 'How much sleep does she need?',
          intro: 'Pick an age. These are ranges, not targets, and the range is '
              'wide on purpose.',
          reassurance: 'Plenty of perfectly healthy babies sit outside these '
              'ranges. If she wakes rested and is growing and feeding well, she '
              'is getting what she needs.',
        ),
      // ⚠️ THE MERGED, AUTO-SCOPED TOOL. Was a `PpChartBrowserScreen` with an
      // age chooser; the Feeding door rebuild merged the chart collection and
      // the "is he getting enough?" signs into it and took the chooser away.
      // The chooser version is kept below for revert.
      'pp_food_chart' => const PpWhatToFeedScreen(),
      /*
      'pp_food_chart' => PpChartBrowserScreen(
          sectionId: 'parenting_feeding',
          bands: kPpFeedingBands,
          title: 'What to feed at this age',
          intro: 'Pick an age. Portions are a guide, not a quota, and no two '
              'days look the same.',
          reassurance: 'Appetite swings wildly from day to day and week to week. '
              'What matters is the pattern over a fortnight, not what he ate at '
              'lunch.',
        ),
      */

      // ---- surfaces the sections named before they existed -------------------
      //
      // ⚠️ THESE WERE ALL DEAD LINKS. `test/pp_sleep_check_test.dart` walks every
      // PpLink in every section and resolves it, which is how they were found:
      // eighteen in-page links across three sections pointing at ids the router
      // had never heard of. Each one rendered as a live, tappable row that did
      // nothing. Nothing compiled wrong and nothing failed.
      // The old Wonder Weeks leaps are retired (the user, 2026-10-14): the
      // surface id stays (door tools and reads link it) and lands on the
      // phases, which the Drive docs feed. Was: const LeapCalendarScreen().
      'pp_leaps' => const PhaseMapScreen(),
      'pp_ask_veda' => const AskVedaScreen(),
      'pp_compare' => const ProductsCompareScreen(),
      'pp_crisis_path' => const PpCrisisPathScreen(),
      // ⚠️ ONE SYMPTOM TOOL (tools pass H2, 2026-10-25): "Is my baby OK?" is
      // the all-ages checker now; the newborn feeding check it used to be keeps
      // its own id. Kept for revert: 'pp_baby_ok_check' => const PpBabyOkCheckScreen(),
      'pp_baby_ok_check' => const WhatChangedScreen(),
      'pp_newborn_feeding' => const PpBabyOkCheckScreen(),
      // Already built and already reachable from Explore and Profile; it simply
      // had no surface id, so four Traditions links pointed at nothing.
      'pp_memories' => const MemoriesHomeScreen(),

      // ⚠️ THREE SCREENS THAT ALREADY SHIPPED AND HAD NO SURFACE ID.
      //
      // All three are reachable from the Explore drawer today, so nobody noticed
      // they were unaddressable -- until the Health section tried to link to
      // them by name and the links resolved to nothing. Reachable from one place
      // is not the same as routable.
      'pp_health_home' => const HealthHomeScreen(),
      // The Wallet card, with its real QR (gap analysis P1, 2026-10-07); its
      // Edit opens the editor. Kept for revert:
      // 'pp_emergency_card' => const HealthEmergencyScreen(),
      'pp_emergency_card' => const WalletEmergencyCardScreen(),
      // You, Maa: the two-question mood check-in (2026-10-07).
      'pp_mood_check' => const PpMoodCheckScreen(),
      // What to buy › How to choose (2026-10-07).
      'pp_buying_guides' => const PpBuyingGuidesScreen(),
      'pp_doctor_visit' => const HealthDoctorVisitScreen(),
      'pp_fever_check' => const PpFeverCheckScreen(),
      'pp_baby_food_check' => const PpBabyFoodCheckScreen(),
      // The mother's "Can I...? while feeding" (fork 2026-10-02, taken 2026-10-07).
      'pp_maa_can_i' => const PpMaaCanIScreen(),
      // The whole-stage search (pp_search.dart, 2026-10-07).
      'pp_search' => const PpSearchScreen(),
      // The care logs (gap analysis P1, 2026-10-07): nappies, pumping, the
      // breastfeed timer, the 7-day history and tummy time. Stores and
      // backend from the fork's f3e0a27 (0094); screens on the shared shell.
      'pp_nappies' => const PpNappyScreen(),
      'pp_pump' => const PpPumpScreen(),
      'pp_feed_timer' => const PpBreastTimerScreen(),
      'pp_care_history' => const PpCareHistoryScreen(),
      'pp_tummy_time' => const PpTummyTimeScreen(),
      // Kegel Care after birth: no controller, so it reads weeks since birth
      // (breathe first to six weeks, then gentle kegels). Linked from the
      // pelvic floor pages in "You, Maa" (2026-10-16).
      'pp_kegel' => const KegelCareScreen(),
      // Everything for this month on one page (gap analysis P1, 2026-10-07).
      'pp_month_checklist' => const PpMonthChecklistScreen(),

      // ⚠️ AN ALIAS, ON PURPOSE. First 40 Days links to "You, Maa" eight times
      // and naturally wrote `pp_you_maa`. The section's real id is
      // 'pp_section/parenting_maternal'. Rewriting eight call sites to say the
      // longer thing would be the wrong fix: `pp_you_maa` is the name a person
      // reaches for, and an alias costs one line.
      'pp_you_maa' => ppScreenForSurface('pp_section/parenting_maternal'),
      // ---- Journeys and trackers -------------------------------------------
      'pp_sleep' => const SleepJourneyScreen(),
      'pp_feeding' => const FeedingJourneyScreen(),
      // ⚠️ WAS FoodHomeScreen, WHICH THE CODEBASE ITSELF MARKS RETIRED.
      // Its own header says "superseded by the unified RecipesScreen... do not
      // wire this back as a live screen" — and this router was doing exactly
      // that, while the Explore drawer, the parenting home and the nutrition
      // screen had all already moved.
      //
      // Nothing failed, which is why it survived: the retired screen still
      // compiles and still works. A deprecation that only lives in a comment is
      // a deprecation the next router entry will ignore.
      // One recipes browse (2026-10-07, pp_recipes_screen.dart). Kept for revert:
      // 'pp_food' => const RecipesScreen(),
      'pp_food' => const PpRecipesScreen(),
      'pp_growth' => const GrowthJourneyScreen(),
      'pp_vaccines' => const VaxTrackerScreen(),
      'pp_what_changed' => const WhatChangedScreen(),

      // `pp_health` deliberately opens What Changed rather than the records
      // screen: HealthRecordsScreen requires a category, and dropping her into
      // an arbitrary one is the "wrong screen" failure this router exists to
      // avoid. The records live one tap deeper, correctly.
      'pp_health' => const WhatChangedScreen(),

      // ---- Development ------------------------------------------------------
      // ⚠️ STILL THE ACTIVITY ENGINE, DELIBERATELY.
      //
      // The Development review said "I dont like what you have built", and the
      // rebuilt thing is the SECTION, reached at 'pp_section/parenting_development'
      // and opened by the hub door. This id keeps pointing at the old screen
      // because the section links here from six pages: the activity engine and
      // the milestone data inside it are real, reused, and were never the part
      // being complained about. Repointing this id would have turned those six
      // links into a section that opens itself.
      'pp_development' => const DevelopmentHomeScreen(),
      'pp_milestones' => const MilestoneJourneyScreen(),
      // ⚠️ THE CHECKLIST THE AREA'S TITLE PROMISES. "Is my child on track?"
      // opened four articles; this is the answer. Separate from
      // `pp_milestones` on purpose — that screen is about noticing and
      // celebrating one skill, this one is about seeing the whole shape at a
      // glance, and merging them would make both worse.
      // ⚠️ MERGED INTO THE JOURNEY, 2026-09-12, on the Development brief:
      // "two milestone screens that show the same list two ways. Make it
      // one." The journey gained the "usually settled by now" group this
      // one had and this one lacked the flip-cards and the search. The id
      // stays so every link into it still lands. Kept for revert.
      // 'pp_on_track' => const OnTrackChecklistScreen(),
      'pp_on_track' => const MilestoneJourneyScreen(),
      // The gentle check-in had no surface of its own; the hub pushed it
      // directly. The door needs one.
      'pp_dev_checkin' => const DevelopmentCheckinScreen(),
      // ⚠️ THE BEHAVIOUR SECTION'S STANDOUT TOOL, and until now the section
      // had NO tools at all — its own file header claimed "nine areas plus
      // three tools" while the section registered four areas and none. The
      // header was describing the spec, not the build.
      'pp_scripts' => const ScriptsLibraryScreen(),
      // ⚠️ WAS ALSO `DevelopmentHomeScreen`, WHICH MADE TWO DIFFERENT LINKS
      // ONE DESTINATION. On "How play builds the brain", "Things to do
      // together today" (pp_development) and "More activities, by area"
      // (pp_activities) sat one line apart and opened the same screen —
      // reported as exactly that. Two labels with one answer teach a reader
      // that the labels do not mean anything.
      //
      // The by-area screen now exists, so the id finally has its own home:
      // grouped by the four ways he is growing, filtered to his age.
      'pp_activities' => const DevelopmentAllActivitiesScreen(),

      // ---- Learn ------------------------------------------------------------
      'pp_read' => const ReadingHomeScreen(),
      'pp_watch' => const WatchHomeScreen(),
      'pp_courses' => const LearningHomeScreen(),

      // ---- Commerce ---------------------------------------------------------
      'pp_products' => const ProductsDiscoveryScreen(),
      // 'pp_product_guide' => const ProductGuideHubScreen(), // kept for revert (tools pass 32): the storefront
      // ⚠️ THE GUIDE OPENS THE GUIDES (tools pass 32, O4). "What is worth
      // buying, and what to skip" opened the Products tab again. Pregnancy's
      // tile keeps its own route (`surface_router.dart`), untouched.
      'pp_product_guide' => const PpBuyingGuidesScreen(),
      // 'pp_recos' => const ProductsDiscoveryScreen(), // kept for revert (tools pass 33): the whole store
      'pp_recos' => ppToysAndCrayonsScreen(),

      // ---- People -----------------------------------------------------------
      'pp_experts' => const ProviderResultsScreen(),
      'pp_find_help' => const ProblemSolverScreen(),
      // ⚠️ THE QUESTIONS VERSION. `pp_find_help` stays exactly as it was —
      // it is the Explore drawer's entry and a search box is the right thing
      // there. This is the surface a link may use when it promised to NARROW
      // rather than to search.
      'pp_find_help_triage' => const FindHelpTriageScreen(),

      // ---- Mother -----------------------------------------------------------
      // The same yoga screen the Explore drawer opens, filtered to the
      // postnatal categories. Not a second yoga screen.
      // 2026-10-16: the one Yoga & fitness hub; its For you is the
      // after-birth view. Kept for revert:
      //   const YogaHomeScreen(backLabel: 'Back', eyebrow: 'ParentVeda Yoga',
      //       heroTitle: 'Recovery & movement'),
      'pp_yoga' => const YogaHomeScreen(backLabel: 'Back'),

      // ---- Tradition --------------------------------------------------------
      'pp_nuskhe' => const NuskheScreen(),
      'pp_names' => const BabyNamingHomeScreen(),

      _ => null,
    };
