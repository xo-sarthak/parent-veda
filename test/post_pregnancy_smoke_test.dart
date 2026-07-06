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
import 'package:parentveda/screens/post_pregnancy/courses_screen.dart';
import 'package:parentveda/screens/post_pregnancy/explore_drawer.dart';
import 'package:parentveda/screens/post_pregnancy/growth_activity_screen.dart';
import 'package:parentveda/screens/post_pregnancy/guides_tools_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_guide_screen.dart';
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
import 'package:parentveda/screens/post_pregnancy/name_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_finder_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_matches_screen.dart';
import 'package:parentveda/screens/post_pregnancy/name_swipe_screen.dart';
import 'package:parentveda/screens/post_pregnancy/nuskhe_screen.dart';
import 'package:parentveda/screens/post_pregnancy/pp_experts_data.dart';
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

  // The home's Solve/Grow panels aren't rendered on the default (Snapshot) tab,
  // so tap through all three tabs and confirm each renders without overflow.
  testWidgets('My Child home: all three tabs render', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PostPregnancyHome()));
    await tester.pump();
    expect(find.text('Snapshot'), findsOneWidget);

    await tester.tap(find.text('Solve'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Challenges to solve'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Grow'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Baby development opportunities'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // The "Deals for the day" commerce shelf sits at the very bottom of the home
  // (below the fold, lazily built) — scroll to it and confirm it renders clean.
  testWidgets('My Child home: deals-for-the-day renders at the bottom', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PostPregnancyHome()));
    await tester.pump();

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
