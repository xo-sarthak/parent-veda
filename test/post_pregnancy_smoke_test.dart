// Smoke test: the post-pregnancy My Child home must build without throwing
// (catches layout/overflow errors before running on a device).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/post_pregnancy/askveda_screen.dart';
import 'package:parentveda/screens/post_pregnancy/book_detail_screen.dart';
import 'package:parentveda/screens/post_pregnancy/cohort_courses_screen.dart';
import 'package:parentveda/screens/post_pregnancy/community_screen.dart';
import 'package:parentveda/screens/post_pregnancy/courses_screen.dart';
import 'package:parentveda/screens/post_pregnancy/explore_drawer.dart';
import 'package:parentveda/screens/post_pregnancy/growth_activity_screen.dart';
import 'package:parentveda/screens/post_pregnancy/guides_tools_screen.dart';
import 'package:parentveda/screens/post_pregnancy/health_guide_screen.dart';
import 'package:parentveda/screens/post_pregnancy/journal_screen.dart';
import 'package:parentveda/screens/post_pregnancy/masterclass_funnel_screen.dart';
import 'package:parentveda/screens/post_pregnancy/masterclasses_screen.dart';
import 'package:parentveda/screens/post_pregnancy/multichild_sheet.dart';
import 'package:parentveda/screens/post_pregnancy/nuskhe_screen.dart';
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
    'Dadi/Nani Nuskhe': const NuskheScreen(),
    'Remedy detail': const RemedyDetailScreen(),
    'Explore drawer': const ExploreDrawer(),
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
}
