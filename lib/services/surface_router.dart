// =============================================================================
//  Surface router — the missing half of app_structure.dart
// -----------------------------------------------------------------------------
//  `app_structure.dart` answers "which TAB owns this surface". Nothing answered
//  "which SCREEN is this surface", which is why every hub in the app keeps its
//  own list: `tools_hub_screen.dart` has 14 rows, `explore_drawer.dart` has ~39,
//  and the two experimental home screens route by jumping to a tab index and
//  hoping she finds the row herself.
//
//  ⚠️ THAT GAP IS WHY THE BRACKET DOORS WOULD HAVE FELT WRONG. Tapping
//  "Appointments" inside a bracket and landing on the Tools TAB is not opening
//  something — it is pointing at a drawer and walking away. A door that lands
//  one screen short of the thing is the same defect as a door that opens
//  nothing, just harder to notice.
//
//  NOTHING HERE IS A NEW SCREEN. Every entry below is a screen that already
//  ships; this file only knows how to construct it. That is deliberate and it is
//  the whole point: the bracket work rewires what exists rather than rebuilding
//  it, so a screen improved later improves everywhere it is reachable from.
//
//  WHEN A SURFACE IS MISSING HERE, it returns null and the caller falls back to
//  the tab jump — which is what happens today, so an unmapped surface is no
//  worse than before rather than broken.
// =============================================================================

import 'package:flutter/material.dart';
import '../screens/garbh_daily_screen.dart';
import 'tool_usage_store.dart';

import '../localization/app_language.dart';
import '../screens/can_i_screen.dart';
import '../screens/post_pregnancy/masterclasses_screen.dart';
import '../screens/post_pregnancy/yoga_home_screen.dart';
import '../screens/prepare/birthing_classes_screen.dart';
import '../screens/prepare/cohorts_screen.dart';
import '../screens/prepare/consultations_screen.dart';
import '../screens/prepare/nutrition_screen.dart';
import '../screens/product_guide/product_guide_hub_screen.dart';
import '../screens/products_screen.dart';
import '../screens/read_next_screen.dart';
import '../screens/report_screen.dart';
import '../screens/tools/baby_movement_screen.dart';
import '../screens/tools/contraction_tracker_screen.dart';
import '../screens/tools/due_date_calculator_screen.dart';
import '../screens/tools/kegel_care_screen.dart';
import '../screens/tools/medicine_tracker_screen.dart';
import '../screens/tools/ready_for_birth_screen.dart';
import '../screens/tools/scans_appointments_screen.dart';
import '../screens/tools/symptom_companion_screen.dart';
import '../screens/tools/tests_scans_reports_screen.dart';
import '../screens/tools/weight_tracker_screen.dart';
import 'pregnancy_controller.dart';

/// The screen behind a surface id, or null if this surface has no single screen.
///
/// Null is a real answer, not a failure: `daily_reads` and `weekly_snapshot`
/// live inside the Today screen rather than standing alone, and a router that
/// invented a destination for them would be worse than one that admits it.
Widget? screenForSurface(String id, PregnancyController c, AppLanguage lang) {
  // ⚠️ USAGE IS RECORDED HERE, AT THE ONE CHOKEPOINT, AND NOWHERE ELSE.
  //
  // The home screen's tool row ranks by how often she opens each tool. If every
  // card that can open a tool had to remember to record it, the counts would be
  // wrong within a week — and wrong counts are worse than none, because the row
  // would confidently show her the tools she uses least.
  //
  // Fire-and-forget: a failed write must never block a screen from opening.
  ToolUsageStore.instance.record(id);
  return _screenFor(id, c, lang);
}

Widget? _screenFor(String id, PregnancyController c, AppLanguage lang) =>
    switch (id) {
      // ---- Tools -----------------------------------------------------------
      'tests_scans' => TestsScansReportsScreen(controller: c),
      'appointments' => ScansAppointmentsScreen(controller: c),
      'due_date' => DueDateCalculatorScreen(controller: c),
      'reports' => ReportScreen(controller: c),
      'can_i' => CanIScreen(controller: c),
      'symptoms' => SymptomCompanionScreen(controller: c),
      'movement' => BabyMovementScreen(controller: c),
      'weight' => WeightTrackerScreen(controller: c),
      'kegel' => KegelCareScreen(controller: c),
      'contractions' => ContractionTrackerScreen(controller: c),
      'hospital_bag' => ReadyForBirthScreen(controller: c),
      'medication' => MedicineTrackerScreen(controller: c),
      'product_guide' => const ProductGuideHubScreen(),

      // ---- Practice --------------------------------------------------------
      // ⚠️ `garbh_daily` NOW OPENS THE DAILY PRACTICE, NOT THE LIBRARY.
      //
      // It used to return `GarbhScreen`, whose own header says it is "a calm
      // LIBRARY (NO 'today' framing — that lives only in the daily Garbh
      // section on Home)". So a door promising "one short practice, ready to
      // start" opened a menu of three pillars and asked her to choose, then
      // browse a repository with mark-complete stripped out.
      //
      // The daily experience already existed — `ShravanScreen(daily: true)` —
      // and was reachable only from the Home screen. The surface id is called
      // `garbh_DAILY`; it now returns the daily thing.
      'garbh_daily' => GarbhDailyScreen(pregnancy: c),

      // ---- Prepare ---------------------------------------------------------
      'consults' => ConsultationsScreen(lang: lang),
      'cohorts' => CohortsScreen(lang: lang),
      'birthing_classes' => BirthingClassesScreen(lang: lang),
      'nutrition' => NutritionScreen(lang: lang),
      'masterclasses' => const MasterclassesScreen(),
      'shop' => ProductsScreen(controller: c),
      // Reuses the parenting yoga home filtered to pregnancy categories — the
      // arrangement that already ships from the Prepare hub. Not a second yoga
      // screen; the same one, told which classes to show.
      //
      // ⚠️ THE FILTER WAS MISSING AND THE COMMENT ABOVE CLAIMED IT WAS THERE.
      //
      // This entry passed a pregnancy title, a pregnancy eyebrow and no
      // `categoryFilter`. Null means "show every category", so a pregnant woman
      // opening "Practise safely today" was shown postnatal recovery, post-IVF
      // and core-recovery classes under a heading that said Prenatal.
      //
      // It looked right in every way that is easy to check: correct title,
      // correct screen, no error. `prepare_hub_screen.dart` had been passing
      // the filter correctly all along, which is what made the omission here
      // invisible — one call site was right, so the screen "worked".
      'yoga' => const YogaHomeScreen(
          categoryFilter: kPregnancyYogaCategories,
          backLabel: 'Back',
          eyebrow: 'ParentVeda Yoga',
          heroTitle: 'Prenatal yoga & movement',
        ),

      // ---- Reads -----------------------------------------------------------
      'daily_reads' => ReadNextScreen(controller: c),

      _ => null,
    };
