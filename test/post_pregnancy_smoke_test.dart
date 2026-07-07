// Smoke test: the post-pregnancy My Child home must build without throwing
// (catches layout/overflow errors before running on a device).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/article_archive_screen.dart';
import 'package:parentveda/screens/post_pregnancy/article_reader_screen.dart';
import 'package:parentveda/screens/post_pregnancy/askveda_screen.dart';
import 'package:parentveda/screens/post_pregnancy/astrology_screen.dart';
import 'package:parentveda/screens/post_pregnancy/book_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/cohort_courses_screen.dart';
import 'package:parentveda/screens/post_pregnancy/cohort_funnel_screen.dart';
import 'package:parentveda/screens/post_pregnancy/community_screen.dart';
import 'package:parentveda/screens/post_pregnancy/course_funnel_screen.dart';
import 'package:parentveda/screens/post_pregnancy/development_activity_screen.dart';
import 'package:parentveda/screens/post_pregnancy/development_area_screen.dart';
import 'package:parentveda/screens/post_pregnancy/development_checkin_screen.dart';
import 'package:parentveda/screens/post_pregnancy/development_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/development_map_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/courses_screen.dart';
import 'package:parentveda/screens/post_pregnancy/explore_drawer.dart';
import 'package:parentveda/screens/post_pregnancy/food_builder_screen.dart';
import 'package:parentveda/screens/post_pregnancy/food_category_screen.dart';
import 'package:parentveda/screens/post_pregnancy/food_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/food_mealplan_screen.dart';
import 'package:parentveda/screens/post_pregnancy/food_nutrition_screen.dart';
import 'package:parentveda/screens/post_pregnancy/food_recipe_screen.dart';
import 'package:parentveda/screens/post_pregnancy/food_saved_screen.dart';
import 'package:parentveda/screens/post_pregnancy/food_shopping_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_data.dart';
import 'package:parentveda/screens/post_pregnancy/growth_activity_screen.dart';
import 'package:parentveda/screens/post_pregnancy/guides_tools_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_doctor_visit_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_emergency_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_growth_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_guide_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_records_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_timeline_screen.dart';
import 'package:parentveda/screens/post_pregnancy/investments_screen.dart';
import 'package:parentveda/screens/post_pregnancy/journal_screen.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/journal_capture_screens.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/journal_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/journal_moments_screens.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/journal_settings_screens.dart';
import 'package:parentveda/screens/post_pregnancy/journal_v2/journal_storybook_screens.dart';
import 'package:parentveda/screens/post_pregnancy/masterclass_funnel_screen.dart';
import 'package:parentveda/screens/post_pregnancy/masterclasses_screen.dart';
import 'package:parentveda/screens/post_pregnancy/multichild_sheet.dart';
import 'package:parentveda/screens/post_pregnancy/my_child_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_finder_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_matches_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_swipe_screen.dart';
import 'package:parentveda/screens/post_pregnancy/nuskhe_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_experts_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reading_data.dart';
import 'package:parentveda/screens/post_pregnancy/reading_collection_screen.dart';
import 'package:parentveda/screens/post_pregnancy/reading_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/reading_library_screen.dart';
import 'package:parentveda/screens/post_pregnancy/reading_reader_screen.dart';
import 'package:parentveda/screens/post_pregnancy/post_pregnancy_home.dart';
import 'package:parentveda/screens/post_pregnancy/problem_solver_screen.dart';
import 'package:parentveda/screens/post_pregnancy/product_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/products_category_screen.dart';
import 'package:parentveda/screens/post_pregnancy/products_compare_screen.dart';
import 'package:parentveda/screens/post_pregnancy/products_discovery_screen.dart';
import 'package:parentveda/screens/post_pregnancy/products_subcategory_screen.dart';
import 'package:parentveda/screens/post_pregnancy/provider_profile_screen.dart';
import 'package:parentveda/screens/post_pregnancy/provider_results_screen.dart';
import 'package:parentveda/screens/post_pregnancy/recipe_page_screen.dart';
import 'package:parentveda/screens/post_pregnancy/recipes_screen.dart';
import 'package:parentveda/screens/post_pregnancy/recommendations_screen.dart';
import 'package:parentveda/screens/post_pregnancy/remedy_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/sick_days_screen.dart';
import 'package:parentveda/screens/post_pregnancy/sleep_better_screen.dart';
import 'package:parentveda/screens/post_pregnancy/snapshot_expanded_screen.dart';
import 'package:parentveda/screens/post_pregnancy/solve_problem_screen.dart';
import 'package:parentveda/screens/post_pregnancy/tools_hub_screen.dart';
import 'package:parentveda/screens/post_pregnancy/vaccination_compare_screen.dart';
import 'package:parentveda/screens/post_pregnancy/vaccination_screen.dart';
import 'package:parentveda/screens/post_pregnancy/vaccine_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_category_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_collection_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_library_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_player_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_quicklearn_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_watch_data.dart';
import 'package:parentveda/screens/post_pregnancy/what_changed_screen.dart';
import 'package:parentveda/screens/post_pregnancy/wonder_week_screen.dart';

void main() {
  final screens = <String, Widget>{
    'My Child home': const PostPregnancyHome(),
    'AskVeda': const AskVedaScreen(),
    'Community': const CommunityScreen(),
    'Products home/categories': const ProductsDiscoveryScreen(),
    'Products category': const ProductsCategoryScreen(),
    'Products subcategory': const ProductsSubcategoryScreen(),
    'Product detail': const ProductDetailScreen(),
    'Products compare': const ProductsCompareScreen(),
    'Health Guide': const HealthGuideScreen(),
    'Sleep Better': const SleepBetterScreen(),
    'Snapshot expanded': const SnapshotExpandedScreen(),
    'My Child profile': const MyChildScreen(),
    'Watch home': const WatchHomeScreen(),
    'Watch player': WatchPlayerScreen(video: watchVideoById('sleep4mo')),
    'Watch Quick Learn': const QuickLearnScreen(),
    'Watch category': const WatchCategoryScreen(category: 'Sleep'),
    'Watch collection': WatchCollectionScreen(collection: watchCollectionById('firstyear')),
    'Watch library': const WatchLibraryScreen(),
    'Food home': const FoodHomeScreen(),
    'Food recipe': FoodRecipeScreen(recipe: foodRecipeById('ragipancake')),
    'Food builder': const FoodBuilderScreen(),
    'Food nutrition': FoodNutritionScreen(focus: focusById('iron')),
    'Food meal plan': const FoodMealPlanScreen(),
    'Food category': const FoodCategoryScreen(category: 'Breakfast'),
    'Food shopping': const FoodShoppingScreen(),
    'Food saved': const FoodSavedScreen(),
    'Learn home': const ReadingHomeScreen(),
    'Learn reader': ReadingReaderScreen(article: readArticleById('fever')),
    'Learn collection': ReadingCollectionScreen(collection: readCollectionById('sleep')),
    'Learn library': const ReadingLibraryScreen(),
    'Health home': const HealthHomeScreen(),
    'Health timeline': const HealthTimelineScreen(),
    'Health growth': const HealthGrowthScreen(),
    'Health records': const HealthRecordsScreen(category: 'reports'),
    'Health doctor visit': const HealthDoctorVisitScreen(),
    'Health emergency': const HealthEmergencyScreen(),
    'Development home': const DevelopmentHomeScreen(),
    'Development area': DevelopmentAreaScreen(area: devAreaById('gross_motor')),
    'Development activity': DevelopmentActivityScreen(activity: devActivityById('peekaboo')),
    'Development map': const DevelopmentMapScreen(),
    'Development check-in': const DevelopmentCheckinScreen(),
    'Solve Problem': const SolveProblemScreen(),
    'Growth activity': const GrowthActivityScreen(),
    'Journal': const MyChildJournalScreen(),
    'Multi-child sheet': const MultiChildSheet(),
    'Recipes': const RecipesScreen(),
    'Recipe page': const RecipePageScreen(),
    'Sick Days': const SickDaysScreen(),
    'Masterclasses': const MasterclassesScreen(),
    'Masterclass funnel': const MasterclassFunnelScreen(),
    'Cohort Courses': const CohortCoursesScreen(),
    'Guides & Tools': const GuidesToolsScreen(),
    'Courses': const CoursesScreen(),
    'Recommendations': const RecommendationsScreen(),
    'Book detail': const BookDetailScreen(),
    'Problem Solver': const ProblemSolverScreen(),
    'Provider results': const ProviderResultsScreen(),
    'Provider profile': const ProviderProfileScreen(),
    'Expert profile (Ananya)': ProviderProfileScreen(expert: expertById('ananya')),
    'Expert profile (Meera)': ProviderProfileScreen(expert: expertById('meera')),
    'Dadi/Nani Nuskhe': const NuskheScreen(),
    'Remedy detail': const RemedyDetailScreen(),
    'Article archive': const ArticleArchiveScreen(),
    'Article reader': const ArticleReaderScreen(),
    'Cohort funnel': const CohortFunnelScreen(),
    'Course funnel': const CourseFunnelScreen(),
    'Tools hub': const ToolsHubScreen(),
    'What Changed': const WhatChangedScreen(),
    'Wonder Week': const WonderWeekScreen(),
    'Vaccination home': const VaccinationScreen(),
    'Vaccination compare': const VaccinationCompareScreen(),
    'Vaccine detail': const VaccineDetailScreen(),
    'Name finder quiz': const NameFinderScreen(),
    'Name swipe deck': const NameSwipeScreen(),
    'Name detail': const NameDetailScreen(),
    'Name matches': const NameMatchesScreen(),
    'Investments & Savings': const InvestmentsScreen(),
    'Astrology & Numerology': const AstrologyScreen(),
    'Explore drawer': const ExploreDrawer(),
    // My Journal V2
    'Journal · Welcome': const JournalWelcomeScreen(),
    'Journal · Empty': const JournalEmptyScreen(),
    'Journal · Home': const JournalV2Home(),
    'Journal · Guided': const GuidedMemoryScreen(),
    'Journal · Quick Capture': const QuickCaptureScreen(),
    'Journal · Write Story': const WriteStoryScreen(),
    'Journal · Letter': const LetterScreen(),
    'Journal · Memory Detail': const MemoryDetailScreen(),
    'Journal · Timeline': const TimelineScreen(),
    'Journal · Search': const SearchScreen(),
    'Journal · Letters': const LettersScreen(),
    'Journal · Storybook Library': const StorybookLibraryScreen(),
    'Journal · Storybook': const StorybookScreen(),
    'Journal · Reader': const StorybookReaderScreen(),
    'Journal · Customize': const HardcoverCustomizationScreen(),
    'Journal · Print': const PrintStorybookScreen(),
    'Journal · Settings': const JournalSettingsScreen(),
  };

  screens.forEach((name, screen) {
    testWidgets('$name builds without throwing', (tester) async {
      // Size close to a real phone so rail/overflow behaviour is realistic.
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(home: screen));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // The home is now a single-scroll "Today" daily briefing (no tabs). Let the
  // staggered reveal settle, then scroll the whole briefing — hero, What Matters,
  // Continue, Discover, Looking Ahead, Snapshot, Focus, Tiny Wins, Quick Actions —
  // to confirm every section (and its horizontal rails) builds without overflow.
  testWidgets('My Child home: daily-briefing sections render', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PostPregnancyHome()));
    await tester.pumpAndSettle(); // let the reveal animation finish

    // Scroll the whole briefing top-to-bottom, building every section + rail.
    await tester.scrollUntilVisible(
      find.text('Quick actions'),
      400,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 40,
    );
    expect(find.text('Quick actions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // The "Deals for the day" commerce shelf sits at the very bottom of the home
  // (below the fold, lazily built) — scroll to it and confirm it renders clean.
  testWidgets('My Child home: deals-for-the-day renders at the bottom', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PostPregnancyHome()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Deals for the day'),
      400,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 40,
    );
    expect(find.text('Deals for the day'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Tapping the child's photo opens the details bottom sheet (not the Snapshot
  // screen) — faithful to S1 v2's data-detailsmodal.
  testWidgets('My Child home: photo opens the child-details sheet', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PostPregnancyHome()));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('child-photo')));
    await tester.pumpAndSettle();

    expect(find.text("Aarav's details"), findsOneWidget);
    expect(find.text('Date of birth'), findsOneWidget);
    expect(find.text('8 March 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // The "My Child" living profile is a long single-scroll flow (Identity ->
  // Snapshot -> Journey -> Growth -> Health -> Memories -> Looking Ahead). Let
  // the reveal settle, then scroll it end-to-end so every section + rail builds
  // without overflow.
  testWidgets('My Child profile: all sections render', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MyChildScreen()));
    await tester.pumpAndSettle();

    expect(find.text('CURIOUS EXPLORER'), findsOneWidget); // AI personality (hero)

    await tester.scrollUntilVisible(
      find.text("What's coming for Aarav"),
      400,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 60,
    );
    expect(find.text("What's coming for Aarav"), findsOneWidget); // final section reached
    expect(tester.takeException(), isNull);
  });

  // The home's Child Snapshot card + "My Child ->" link must open the profile
  // (understanding-oriented), keeping the whole flow connected.
  testWidgets('My Child home: snapshot card opens the My Child profile', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PostPregnancyHome()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Child snapshot'),
      400,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 40,
    );
    // Pull the "My Child →" link clear of the floating bottom nav before tapping.
    await tester.ensureVisible(find.text('My Child →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Child →'));
    await tester.pumpAndSettle();

    expect(find.byType(MyChildScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // The parenting Ask Veda is now a REAL search on the shared engine (not the
  // old static mock): entering a question renders the shared 7-section
  // VedaResultView with a grounded answer from the parenting corpus.
  testWidgets('Ask Veda (parenting): a question renders a real answer', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: AskVedaScreen()));
    await tester.pumpAndSettle();

    // empty state offers suggestions
    expect(find.text('Why does he wake every 2 hours at night?'), findsOneWidget);

    await tester.tap(find.text('Why does he wake every 2 hours at night?'));
    await tester.pumpAndSettle();

    // the shared result view renders the answer hero (eyebrow is uppercased)
    expect(find.text('VEDA ANSWER'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Watch home renders and opening the hero lands in the Deep Learn player,
  // which shows the signature "Learn next" chain (not autoplay / comments).
  testWidgets('Watch: home opens a video into the player', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: WatchHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Today for Aarav'), findsOneWidget);
    await tester.ensureVisible(find.text('Watch now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Watch now'));
    await tester.pumpAndSettle();

    expect(find.byType(WatchPlayerScreen), findsOneWidget); // opened the player
    expect(tester.takeException(), isNull);
  });

  // The Quick/Deep mode toggle re-points the personalised picks.
  testWidgets('Watch: the Quick/Deep mode toggle switches picks', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: WatchHomeScreen()));
    await tester.pumpAndSettle();

    // the toggle sits near the top; tapping Quick Learn re-points the picks
    await tester.tap(find.text('Quick Learn'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Quick lessons for you'), 300,
        scrollable: find.byType(Scrollable).first, maxScrolls: 20);
    expect(find.text('Quick lessons for you'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Food: the recipe page's signature Healthier Version toggle flips the framing.
  testWidgets('Food: recipe Healthier Version toggle switches framing', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: FoodRecipeScreen(recipe: foodRecipeById('ragipancake'))));
    await tester.pumpAndSettle();

    expect(find.text('HEALTHIER VERSION'), findsOneWidget); // eyebrow (uppercased)
    await tester.ensureVisible(find.text('Everyday'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Everyday'));
    await tester.pumpAndSettle();
    expect(find.textContaining('usually made'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Food: the Smart Meal Builder returns suggestions for the seeded pantry.
  testWidgets('Food: Smart Meal Builder suggests meals', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: FoodBuilderScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Suggest meals'), 200,
        scrollable: find.byType(Scrollable).first, maxScrolls: 30);
    await tester.ensureVisible(find.text('Suggest meals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suggest meals'));
    await tester.pumpAndSettle();

    // the seeded pantry (milk/banana/oats, Breakfast, 15 min) surfaces this one
    await tester.scrollUntilVisible(find.text('Ragi & banana pancakes'), 200,
        scrollable: find.byType(Scrollable).first, maxScrolls: 30);
    expect(find.text('Ragi & banana pancakes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Community (parenting): carried forward from pre-birth with parenting-stage
  // rooms; the real feed + an auto-joined room render.
  testWidgets('Community (parenting): rooms + feed render', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: CommunityScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('now for this stage'), findsOneWidget); // subline
    expect(find.text('0–1 Year'), findsWidgets); // parenting room chip + post tag

    // scroll the whole feed (building every post) to the labelled sponsored slot
    await tester.scrollUntilVisible(find.text('Nunu — breathable muslin swaddles'), 300,
        scrollable: find.byType(Scrollable).first, maxScrolls: 40);
    expect(find.text('Nunu — breathable muslin swaddles'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Learn: the premium reader renders long-form with an expandable ParentVeda
  // tip (the reading experience, not a plain article).
  testWidgets('Learn: the reader renders and a tip expands', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: ReadingReaderScreen(article: readArticleById('fever'))));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.textContaining('ParentVeda tip'), 250,
        scrollable: find.byType(Scrollable).first, maxScrolls: 40);
    expect(find.textContaining('ParentVeda tip'), findsOneWidget);
    await tester.tap(find.textContaining('ParentVeda tip'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  // Health: the ecosystem home renders and the Emergency Card opens (a key
  // differentiator), integrating the existing Vaccination module as a summary.
  testWidgets('Health: home renders and the Emergency Card opens', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HealthHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Healthy'), findsWidgets); // snapshot

    // the integrated Vaccination module appears as a summary on the way down
    await tester.scrollUntilVisible(find.text('Open Vaccination Tracker'), 300,
        scrollable: find.byType(Scrollable).first, maxScrolls: 40);
    expect(find.text('Open Vaccination Tracker'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Emergency Card'), 300,
        scrollable: find.byType(Scrollable).first, maxScrolls: 40);
    await tester.tap(find.text('Emergency Card'));
    await tester.pumpAndSettle();
    expect(find.byType(HealthEmergencyScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Development: the companion home opens the birth-to-five Development Map,
  // which marks the child's current stage ("you are here") — not a checklist.
  testWidgets('Development: home opens the Development Map', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: DevelopmentHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Help Aarav grow'), findsOneWidget);
    await tester.ensureVisible(find.text('The Development Map'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('The Development Map'));
    await tester.pumpAndSettle();

    expect(find.byType(DevelopmentMapScreen), findsOneWidget);
    expect(find.text('YOU ARE HERE'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  // The Astrology reading is behind an opt-in toggle (off by default), so pump
  // the ON state too and confirm the readings render cleanly.
  testWidgets('Astrology readings render when toggled on', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: AstrologyScreen()));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('astro-toggle')));
    await tester.pump();
    expect(find.text("Aarav's cosmic notes"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
