// Smoke test: the post-pregnancy My Child home must build without throwing
// (catches layout/overflow errors before running on a device).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/article_archive_screen.dart';
import 'package:parentveda/screens/post_pregnancy/article_reader_screen.dart';
import 'package:parentveda/screens/post_pregnancy/askveda_screen.dart';
import 'package:parentveda/screens/post_pregnancy/astrology_screen.dart';
import 'package:parentveda/screens/post_pregnancy/baby_naming_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_journey_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_journey_feed_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_journey_shortlist_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_list_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_names_v2_data.dart';
import 'package:parentveda/screens/post_pregnancy/book_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/cohort_courses_screen.dart';
import 'package:parentveda/screens/post_pregnancy/cohort_funnel_screen.dart';
import 'package:parentveda/screens/post_pregnancy/community_screen.dart';
import 'package:parentveda/screens/post_pregnancy/course_funnel_screen.dart';
import 'package:parentveda/screens/post_pregnancy/development_activity_screen.dart';
import 'package:parentveda/screens/post_pregnancy/development_area_screen.dart';
import 'package:parentveda/screens/post_pregnancy/dev_stage_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/leap_calendar_screen.dart';
import 'package:parentveda/screens/post_pregnancy/leap_definition_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_leaps_data.dart';
import 'package:parentveda/screens/post_pregnancy/name_astro_screens.dart';
import 'package:parentveda/screens/post_pregnancy/feeding_tracker_screen.dart';
import 'package:parentveda/screens/post_pregnancy/sleep_tracker_screen.dart';
import 'package:parentveda/screens/post_pregnancy/baby_documents_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_reco_data.dart';
import 'package:parentveda/screens/post_pregnancy/reco_common.dart';
import 'package:parentveda/screens/post_pregnancy/reco_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/reco_category_screen.dart';
import 'package:parentveda/screens/post_pregnancy/reco_collection_screen.dart';
import 'package:parentveda/screens/post_pregnancy/reco_search_screen.dart';
import 'package:parentveda/screens/post_pregnancy/reco_library_screen.dart';
import 'package:parentveda/screens/post_pregnancy/development_checkin_screen.dart';
import 'package:parentveda/screens/post_pregnancy/development_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/development_map_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_development_data.dart';
import 'package:parentveda/screens/post_pregnancy/course_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/course_lesson_screen.dart';
import 'package:parentveda/screens/post_pregnancy/courses_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_courses_data.dart';
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
import 'package:parentveda/screens/post_pregnancy/doctor_record_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_doctor_visit_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_emergency_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_growth_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_guide_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_records_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_timeline_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_health_data.dart';
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
import 'package:parentveda/screens/post_pregnancy/vaccine_learn_screen.dart';
import 'package:parentveda/screens/post_pregnancy/vax_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/vax_timeline_screen.dart';
import 'package:parentveda/screens/post_pregnancy/vax_tracker_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_category_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_collection_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_library_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_player_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_quicklearn_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_watch_data.dart';
import 'package:parentveda/screens/post_pregnancy/what_changed_screen.dart';
import 'package:parentveda/screens/post_pregnancy/wonder_week_screen.dart';
// New sections from the parenting review batch:
import 'package:parentveda/screens/post_pregnancy/yoga_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/yoga_class_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_yoga_data.dart';
import 'package:parentveda/screens/post_pregnancy/learning_home_screen.dart';
import 'package:parentveda/screens/post_pregnancy/learning_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_learning_data.dart';
import 'package:parentveda/screens/post_pregnancy/remedy_list_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_nuskhe_data.dart';
import 'package:parentveda/screens/post_pregnancy/watch_channel_screen.dart';
import 'package:parentveda/screens/post_pregnancy/watch_shorts_screen.dart';

void main() {
  final screens = <String, Widget>{
    'My Child home': const MyChildScreen(home: true),
    'Today (retired briefing)': const PostPregnancyHome(),
    'Leap calendar': const LeapCalendarScreen(),
    'Leap definition (Leap 4)': LeapDefinitionScreen(leap: leapByNumber(4)),
    'Dev stage detail (skill)': DevStageDetailScreen(area: devAreaById('cognitive'), stage: devAreaById('cognitive').journey[2]),
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
    'Watch channel (Ananya)': const WatchChannelScreen(expertId: 'ananya'),
    'Watch shorts': const WatchShortsScreen(),
    'Yoga home': const YogaHomeScreen(),
    'Yoga class (live group)': YogaClassScreen(cls: yogaClassById('pn_group')),
    'Yoga class (recorded)': YogaClassScreen(cls: yogaClassById('md_sleep_rec')),
    'Courses & Masterclasses': const LearningHomeScreen(),
    'Learning detail (cohort)': LearningDetailScreen(program: programById('co_sleep')),
    'Learning detail (masterclass)': LearningDetailScreen(program: programById('mc_solids')),
    'Learning detail (recorded course)': LearningDetailScreen(program: programById('rc_playbrain')),
    'Remedy list (Cold & cough)': const RemedyListScreen(category: 'Cold & cough'),
    'Remedy detail (data)': RemedyDetailScreen(remedy: remedyById('jaiphal_pinch')),
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
    'Course detail (Play & Brain)': CourseDetailScreen(course: courseById('playbrain')),
    'Course detail (Sleep Bootcamp)': CourseDetailScreen(course: courseById('sleep')),
    'Course lesson (Sleep · Module 2)': CourseLessonScreen(course: courseById('sleep'), index: 1),
    'Recommendations': const RecommendationsScreen(),
    'Reco detail': RecoDetailScreen(item: recoById('bk_indianfaces')),
    'Reco category (Books)': const RecoCategoryScreen(category: 'Books'),
    'Reco collection (Sensory)': RecoCollectionScreen(collection: recoCollectionById('sensory')),
    'Reco search': const RecoSearchScreen(),
    'Reco library': const RecoLibraryScreen(),
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
    'Vaccine Learn (why)': const VaccineLearnScreen(),
    'Doctor-ready record': const DoctorRecordScreen(),
    'Vax tracker (redesign)': const VaxTrackerScreen(),
    'Vax timeline': const VaxTimelineScreen(),
    'Vax detail (due · PCV)': const VaxDetailScreen(visitId: 'wk14'),
    'Vax detail (MMR)': const VaxDetailScreen(visitId: 'mo9'),
    'Health records (medications)': const HealthRecordsScreen(category: 'medications'),
    'Health records (allergies)': const HealthRecordsScreen(category: 'allergies'),
    'Health records (visits)': const HealthRecordsScreen(category: 'visits'),
    'Health records (prescriptions)': const HealthRecordsScreen(category: 'prescriptions'),
    'Baby documents': const BabyDocumentsScreen(),
    'Name finder quiz': const NameFinderScreen(),
    'Name swipe deck': const NameSwipeScreen(),
    'Name detail': const NameDetailScreen(),
    'Name matches': const NameMatchesScreen(),
    'Baby Naming front door (V2)': const BabyNamingHomeScreen(),
    'Name Journey feed': const NameJourneyFeedScreen(),
    'Name Journey detail': const NameJourneyDetailScreen(name: 'Aarav'),
    'Name astrology': const NameAstrologyScreen(name: 'Aarav'),
    'Name numerology': const NameNumerologyScreen(name: 'Aarav'),
    'Feeding tracker': const FeedingTrackerScreen(),
    'Sleep tracker': const SleepTrackerScreen(),
    'Name Journey shortlist': const NameJourneyShortlistScreen(),
    'Name list (browse)': const NameListScreen(),
    'Name compare (V2)': const NameCompareScreen(),
    'Name chosen (V2)': const NameChosenScreen(name: 'Aarav'),
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
  // staggered reveal settle, then scroll the whole briefing - hero, What Matters,
  // Continue, Discover, Looking Ahead, Snapshot, Focus, Tiny Wins, Quick Actions -
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
  // (below the fold, lazily built) - scroll to it and confirm it renders clean.
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
  // screen) - faithful to S1 v2's data-detailsmodal.
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

  // The new My Child home is a single-scroll, leap-first flow (Leap header ->
  // Identity + Growth -> Daily tip -> Leap video + description -> Snapshot ->
  // Milestones -> Journal -> Watch -> Learn -> Looking ahead). Scroll it
  // end-to-end so every section + horizontal rail builds without overflow.
  testWidgets('My Child profile: all sections render', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MyChildScreen()));
    await tester.pumpAndSettle();

    expect(find.text('LIVE NOW'), findsOneWidget); // leap header
    expect(find.text('Aarav'), findsWidgets); // identity

    await tester.scrollUntilVisible(
      find.text('LOOKING AHEAD'),
      400,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 60,
    );
    expect(find.text('LOOKING AHEAD'), findsOneWidget); // final section reached
    expect(tester.takeException(), isNull);
  });

  // The new home's inline growth "Edit" opens the profile/growth sheet (the
  // edit is NOT behind the photo tap any more).
  testWidgets('My Child home: growth Edit opens the profile sheet', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MyChildScreen(home: true)));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Edit').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();

    expect(find.text('Edit profile & growth'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // A Milestone row opens its detail (skill/milestone), data-driven from the
  // child's current + emerging stages.
  testWidgets('My Child home: a milestone opens its detail', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MyChildScreen(home: true)));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Rolling'),
      300,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 40,
    );
    await tester.ensureVisible(find.text('Rolling'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rolling'));
    await tester.pumpAndSettle();

    expect(find.byType(DevStageDetailScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // The Explore drawer (hamburger) carries the new Leap Calendar entry, which
  // opens the calendar.
  testWidgets('My Child home: Explore drawer opens the Leap Calendar', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MyChildScreen(home: true)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Leap Calendar'), findsOneWidget);

    await tester.tap(find.text('Leap Calendar'));
    await tester.pumpAndSettle();
    expect(find.byType(LeapCalendarScreen), findsOneWidget);
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

    // type a question into the pinned search pill and submit
    await tester.enterText(find.byType(TextField), 'the 4-month sleep regression');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // the pregnancy-style result page renders with the 'Veda Answer' card
    expect(find.text('Veda Answer'), findsOneWidget);
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

    // The feed's sponsored slot used to be a hardcoded brand card ("Nunu -
    // breathable muslin swaddles") written straight into the build method. It
    // now resolves through BrandStudio, which is inert under test — so the slot
    // renders nothing and no brand name reaches the feed at all.
    expect(find.text('Nunu - breathable muslin swaddles'), findsNothing);

    // Still scroll the whole feed, building every post, to catch layout breaks.
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 30; i++) {
      await tester.drag(scrollable, const Offset(0, -400));
      await tester.pump();
    }
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

  // Health: doctor visits are no longer read-only - a parent can add one, and it
  // shows in the list (the "Add a visit" affordance now exists for visits).
  testWidgets('Health: a parent-added doctor visit shows in the visits list', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    HealthStore.instance.addVisit(const HealthEvent(
      id: 't_visit', type: HealthEventType.doctorVisit, date: '7 Jul 2026',
      title: 'Six-month check', summary: 'All well.', sortKey: 1000));
    addTearDown(() => HealthStore.instance.removeVisit(0));

    await tester.pumpWidget(const MaterialApp(home: HealthRecordsScreen(category: 'visits')));
    await tester.pump();

    expect(find.text('Add a visit'), findsOneWidget); // the add affordance exists
    expect(find.text('Six-month check'), findsOneWidget); // the added visit renders
  });

  // Learn: the reading filters narrow the library to a single kind.
  testWidgets('Learn: the Book Summaries filter narrows the list', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: ReadingHomeScreen()));
    await tester.pumpAndSettle();

    // the type filter now lives in the Collections section, below the editorial start
    await tester.scrollUntilVisible(find.text('Book Summaries'), 300,
        scrollable: find.byType(Scrollable).first, maxScrolls: 40);
    await tester.tap(find.text('Book Summaries'));
    await tester.pumpAndSettle();

    // jump back up, then scroll the narrowed list to the expected book summary
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.textContaining('Big feelings in a small body'), 300,
        scrollable: find.byType(Scrollable).first, maxScrolls: 40);

    // a book-summary-tagged article appears once the filter is applied
    expect(find.textContaining('Big feelings in a small body'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  // Vaccination: the completed section expands to show every completed vaccine
  // (the count "13 completed" now matches a full 13-item list).
  testWidgets('Vaccination: the completed list expands to all 13', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: VaccinationScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('13 completed'), 300,
        scrollable: find.byType(Scrollable).first, maxScrolls: 40);
    await tester.tap(find.text('13 completed'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('BCG'), 300,
        scrollable: find.byType(Scrollable).first, maxScrolls: 40);
    expect(find.text('BCG'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Vaccination redesign: the tracker opens a vaccine's Learn-Why + After-Care.
  testWidgets('Vaccination redesign: tracker opens a vaccine detail', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: VaxTrackerScreen()));
    await tester.pumpAndSettle();

    // the Due-Today card spotlights PCV at 14 weeks
    expect(find.text('PCV · 14 weeks'), findsWidgets);
    await tester.tap(find.text('PCV · 14 weeks').first);
    await tester.pumpAndSettle();

    // the PCV detail (Learn Why + After-Care) opens
    expect(find.text('Pneumococcal (PCV)'), findsWidgets);
    await tester.scrollUntilVisible(find.text('After the shot'), 300,
        scrollable: find.byType(Scrollable).first, maxScrolls: 40);
    expect(find.text('After the shot'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Redirect audit: a product row opens exactly the product it names.
  testWidgets('Product rows open the product they name', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: GrowthActivityScreen()));
    await tester.pumpAndSettle();

    // the row shows the real catalogue product (name comes from the catalog now)
    await tester.scrollUntilVisible(find.text('Peekaboo Cloth Book'), 250,
        scrollable: find.byType(Scrollable).first, maxScrolls: 30);
    await tester.tap(find.text('Peekaboo Cloth Book'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailScreen), findsOneWidget);
    expect(find.text('Peekaboo Cloth Book'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  // Redirect audit: a "Go deeper · FAQ" answers inline instead of redirecting.
  testWidgets('Go-deeper FAQ answers inline', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: GrowthActivityScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('When does object permanence develop?'), 250,
        scrollable: find.byType(Scrollable).first, maxScrolls: 30);
    await tester.tap(find.text('When does object permanence develop?'));
    await tester.pumpAndSettle();

    // the FAQ answer sheet appears (with a follow-up option), not a full redirect
    expect(find.text('Ask a follow-up in Ask Veda'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Redirect audit: a "Go deeper · Course" opens the matching focused course.
  testWidgets('Go-deeper Course opens the matching course', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: GrowthActivityScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Play & Brain · Leap 4 activities'), 250,
        scrollable: find.byType(Scrollable).first, maxScrolls: 30);
    await tester.tap(find.text('Play & Brain · Leap 4 activities'));
    await tester.pumpAndSettle();

    // opens the matching course, with the named lesson marked "Start here"
    expect(find.byType(CourseDetailScreen), findsOneWidget);
    expect(find.text('Play & Brain'), findsWidgets);
    expect(find.text('Start here'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // A lesson opens its own module page INSIDE the right course (marked as a
  // preview) - never the flagship "Complete Parenting Guide" funnel.
  testWidgets('Course lesson opens inside the right course, not the flagship funnel', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: CourseDetailScreen(course: courseById('sleep'))));
    await tester.pumpAndSettle();

    final lesson = find.text('Module 2 · The 4-month regression');
    await tester.scrollUntilVisible(lesson, 200, scrollable: find.byType(Scrollable).first, maxScrolls: 30);
    await tester.ensureVisible(lesson);
    await tester.pumpAndSettle();
    await tester.tap(lesson);
    await tester.pumpAndSettle();

    expect(find.byType(CourseLessonScreen), findsOneWidget);
    expect(find.text('Preview lesson'), findsOneWidget); // honest in-review marker
    expect(find.text('The Complete Parenting Guide'), findsNothing); // not the flagship
    expect(tester.takeException(), isNull);
  });

  // Baby names: the V1|V2 header toggle switches the whole experience.
  testWidgets('Baby names: the V1|V2 toggle switches versions', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    addTearDown(() => NameVersionStore.instance.setVersion(NameVersion.v2));

    await tester.pumpWidget(const MaterialApp(home: BabyNamingHomeScreen()));
    await tester.pumpAndSettle();

    // defaults to V2 - the Journey
    expect(find.text('Begin the journey'), findsOneWidget);

    await tester.tap(find.text('V1'));
    await tester.pumpAndSettle();
    expect(find.text('Open the Name Finder'), findsOneWidget);

    await tester.tap(find.text('V2'));
    await tester.pumpAndSettle();
    expect(find.text('Begin the journey'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Baby names V2: quiz -> primer (sets the mental model) -> swipe deck.
  testWidgets('Baby names V2: quiz -> primer -> swipe deck renders', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: NameJourneyFeedScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Start discovering'), 200,
        scrollable: find.byType(Scrollable).first, maxScrolls: 20);
    await tester.tap(find.text('Start discovering'));
    await tester.pumpAndSettle();

    // the transitional primer sets the mental model
    expect(find.text('Discover names one by one'), findsOneWidget);
    await tester.scrollUntilVisible(find.text("Let's begin"), 200,
        scrollable: find.byType(Scrollable).first, maxScrolls: 20);
    await tester.tap(find.text("Let's begin"));
    await tester.pumpAndSettle();

    // the swipe deck, with a labelled tap alternative
    expect(find.text('Tap for the full story'), findsOneWidget);
    expect(find.text('We like this'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Baby names: the no-swipe "Just show me names" path opens a browsable list.
  testWidgets('Baby names: Just show me names opens the browse list', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: NameJourneyFeedScreen()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Just show me names'), 200,
        scrollable: find.byType(Scrollable).first, maxScrolls: 20);
    await tester.tap(find.text('Just show me names'));
    await tester.pumpAndSettle();

    expect(find.byType(NameListScreen), findsOneWidget);
    expect(find.text('Take your time'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Development: the companion home opens the birth-to-five Development Map,
  // which marks the child's current stage ("you are here") - not a checklist.
  testWidgets('Development: home opens the Development Map', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: DevelopmentHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Help Aarav grow'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('The Development Map'), 250,
        scrollable: find.byType(Scrollable).first, maxScrolls: 20);
    await tester.tap(find.text('The Development Map'));
    await tester.pumpAndSettle();

    expect(find.byType(DevelopmentMapScreen), findsOneWidget);
    expect(find.text('YOU ARE HERE'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  // Recommendations: opening a pick shows the ParentVeda take (the whole point -
  // a reason + what to consider, not marketing copy).
  testWidgets('Recommendations: a pick opens its detail with the ParentVeda take', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: RecoCategoryScreen(category: 'Books')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(RecoRow).first);
    await tester.pumpAndSettle();

    expect(find.byType(RecoDetailScreen), findsOneWidget);
    expect(find.text('THINGS TO CONSIDER'), findsOneWidget);
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
