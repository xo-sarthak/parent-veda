// Smoke test: every Prepare screen must build without throwing. Confirms the
// runtime "Null is not a subtype of Specialist" seen after a hot-reload is a
// stale-instance artifact (fixed by hot restart), not a code bug.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/prepare_data.dart';
import 'package:parentveda/screens/prepare/birthing_classes_screen.dart';
import 'package:parentveda/screens/prepare/cohort_detail_screen.dart';
import 'package:parentveda/screens/prepare/cohorts_screen.dart';
import 'package:parentveda/screens/prepare/consultation_detail_screen.dart';
import 'package:parentveda/screens/prepare/consultations_screen.dart';
import 'package:parentveda/screens/prepare/masterclass_detail_screen.dart';
import 'package:parentveda/screens/prepare/masterclasses_screen.dart';
import 'package:parentveda/screens/prepare/courses_cohorts_screen.dart';
import 'package:parentveda/screens/prepare/nutrition_screen.dart';
import 'package:parentveda/screens/post_pregnancy/yoga_home_screen.dart';
import 'package:parentveda/screens/prepare/prepare_hub_screen.dart';
import 'package:parentveda/screens/prepare/program_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final screens = <String, Widget>{
    'hub': const PrepareHubScreen(),
    'masterclasses': const MasterclassesScreen(),
    'consultations': const ConsultationsScreen(),
    'cohorts': const CohortsScreen(),
    // Yoga now uses the shared cult.fit screen, filtered to pregnancy categories.
    'yoga': const YogaHomeScreen(categoryFilter: kPregnancyYogaCategories),
    'birthing': const BirthingClassesScreen(),
    'masterclass detail': MasterclassDetailScreen(m: kMasterclasses.first),
    'consultation detail': ConsultationDetailScreen(specialist: kSpecialists.first),
    'cohort detail': CohortDetailScreen(cohort: kCohorts.first),
    'courses & cohorts': const CoursesCohortsScreen(),
    'program detail': ProgramDetailScreen(program: kPrepPrograms.first),
    'nutrition': const NutritionScreen(),
    'nutrition plans': const NutritionPlansScreen(goalId: 'gd'),
    'nutrition trailer': NutritionTrailerScreen(plan: kNutritionPlans.first),
    'nutrition diet plan': NutritionDietPlanScreen(plan: kNutritionPlans.first),
  };

  screens.forEach((name, screen) {
    testWidgets('$name builds without throwing', (tester) async {
      await tester.pumpWidget(MaterialApp(home: screen));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
