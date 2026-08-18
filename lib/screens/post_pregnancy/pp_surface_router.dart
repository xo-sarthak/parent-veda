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
import 'recipes_screen.dart';

import 'pp_section_registry.dart';
import 'pp_section_screen.dart';
import 'askveda_screen.dart';
import 'leap_calendar_screen.dart';
import '../memories/memories_home_screen.dart';
import 'health_doctor_visit_screen.dart';
import 'health_emergency_screen.dart';
import 'health_home_screen.dart';
import 'pp_baby_food_check_screen.dart';
import 'pp_baby_ok_check_screen.dart';
import 'pp_fever_check_screen.dart';
import 'pp_crisis_path_screen.dart';
import 'pp_age_bands.dart';
import 'pp_chart_browser_screen.dart';
import 'pp_feeding_content.dart';
import 'products_compare_screen.dart';
import 'pp_sounds_screen.dart';

import '../product_guide/product_guide_hub_screen.dart';
import 'baby_naming_home_screen.dart';
import 'development_home_screen.dart';
import 'feeding_journey_screen.dart';
import 'growth_journey_screen.dart';
import 'learning_home_screen.dart';
import 'milestone_journey_screen.dart';
import 'nuskhe_screen.dart';
import 'problem_solver_screen.dart';
import 'products_discovery_screen.dart';
import 'provider_results_screen.dart';
import 'reading_home_screen.dart';
import 'sleep_journey_screen.dart';
import 'vax_tracker_screen.dart';
import 'watch_home_screen.dart';
import 'what_changed_screen.dart';
import 'yoga_home_screen.dart';

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
Widget? ppScreenForSurface(String id) {
  const sectionPrefix = 'pp_section/';
  if (id.startsWith(sectionPrefix)) {
    final section = ppSectionFor(id.substring(sectionPrefix.length));
    if (section == null) return null;
    return PpSectionScreen(
      section: section,
      onSurface: (context, surfaceId) {
        final screen = ppScreenForSurface(surfaceId);
        if (screen == null) return;
        Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: surfaceId),
          builder: (_) => screen,
        ));
      },
    );
  }
  return _ppScreenFor(id);
}

Widget? _ppScreenFor(String id) => switch (id) {
      // ---- New surfaces the sections need -----------------------------------
      'pp_sleep_sounds' => const PpSoundsScreen(),
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

      // ---- surfaces the sections named before they existed -------------------
      //
      // ⚠️ THESE WERE ALL DEAD LINKS. `test/pp_sleep_check_test.dart` walks every
      // PpLink in every section and resolves it, which is how they were found:
      // eighteen in-page links across three sections pointing at ids the router
      // had never heard of. Each one rendered as a live, tappable row that did
      // nothing. Nothing compiled wrong and nothing failed.
      'pp_leaps' => const LeapCalendarScreen(),
      'pp_ask_veda' => const AskVedaScreen(),
      'pp_compare' => const ProductsCompareScreen(),
      'pp_crisis_path' => const PpCrisisPathScreen(),
      'pp_baby_ok_check' => const PpBabyOkCheckScreen(),
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
      'pp_emergency_card' => const HealthEmergencyScreen(),
      'pp_doctor_visit' => const HealthDoctorVisitScreen(),
      'pp_fever_check' => const PpFeverCheckScreen(),
      'pp_baby_food_check' => const PpBabyFoodCheckScreen(),

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
      'pp_food' => const RecipesScreen(),
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
      'pp_activities' => const DevelopmentHomeScreen(),

      // ---- Learn ------------------------------------------------------------
      'pp_read' => const ReadingHomeScreen(),
      'pp_watch' => const WatchHomeScreen(),
      'pp_courses' => const LearningHomeScreen(),

      // ---- Commerce ---------------------------------------------------------
      'pp_products' => const ProductsDiscoveryScreen(),
      'pp_product_guide' => const ProductGuideHubScreen(),
      'pp_recos' => const ProductsDiscoveryScreen(),

      // ---- People -----------------------------------------------------------
      'pp_experts' => const ProviderResultsScreen(),
      'pp_find_help' => const ProblemSolverScreen(),

      // ---- Mother -----------------------------------------------------------
      // The same yoga screen the Explore drawer opens, filtered to the
      // postnatal categories. Not a second yoga screen.
      'pp_yoga' => const YogaHomeScreen(
          backLabel: 'Back',
          eyebrow: 'ParentVeda Yoga',
          heroTitle: 'Recovery & movement',
        ),

      // ---- Tradition --------------------------------------------------------
      'pp_nuskhe' => const NuskheScreen(),
      'pp_names' => const BabyNamingHomeScreen(),

      _ => null,
    };
