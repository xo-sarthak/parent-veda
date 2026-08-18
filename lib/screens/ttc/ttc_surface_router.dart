// =============================================================================
//  TTC surface router — surface id to the screen that already ships
// -----------------------------------------------------------------------------
//  Third sibling, after `services/surface_router.dart` (pregnancy) and
//  `post_pregnancy/pp_surface_router.dart`.
//
//  ⚠️ EVERY ENTRY IS A SCREEN THAT ALREADY EXISTS. Nothing here is new work.
//  The TTC stage is the most completely built of the three, which is why nearly
//  every surface resolves — the bracket doors are giving existing screens a
//  second, problem-shaped way in, not creating destinations.
//
//  NULL IS A REAL ANSWER, and it stays that way. A door that opens the WRONG
//  screen teaches her the app is unreliable, and that costs more than a door
//  that has not opened yet.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_store.dart';
import 'ttc_appointments_screen.dart';
import 'ttc_calendar_screen.dart';
import 'ttc_can_i_screen.dart';
import 'ttc_care_circle_screen.dart';
import 'ttc_chapter_screen.dart';
import 'ttc_community_screen.dart';
import 'ttc_cycle_screens.dart';
import 'ttc_journal_screen.dart';
import 'ttc_medication_screen.dart';
import 'ttc_nutrition_screen.dart';
import 'ttc_partner_screen.dart';
import 'ttc_prepare_screen.dart';
import 'ttc_products_screen.dart';
import 'ttc_records_screen.dart';
import 'ttc_ritual_screen.dart';
import 'ttc_supplements_screen.dart';
import 'ttc_tests_screen.dart';
import 'ttc_treatment_screen.dart';

Widget? ttcScreenForSurface(String id) => switch (id) {
      // ---- The cycle spine ---------------------------------------------------
      'ttc_cycle' => const TtcCycleScreen(),
      'ttc_ovulation' => const TtcOvulationScreen(),
      'ttc_window' => const TtcFertilityWindowScreen(),
      'ttc_calendar' => const TtcCalendarScreen(),

      // ---- Learning ----------------------------------------------------------
      // The chapter screen shows the chapter she is actually in, which is the
      // only honest answer — a bracket cannot know better than the engine.
      'ttc_chapter' => TtcChapterScreen(chapter: TtcStore.instance.today.chapter),
      'ttc_can_i' => const TtcCanIScreen(),

      // ---- Body and health ---------------------------------------------------
      'ttc_tests' => const TtcTestsScreen(),
      'ttc_nutrition' => const TtcNutritionScreen(),
      'ttc_supplements' => const TtcSupplementsScreen(),
      // `ttc_tracker` is deliberately absent: `TtcTrackerScreen` requires a
      // specific tracker and there is no single "the tracker". Dropping her
      // into an arbitrary one is exactly the wrong-screen failure this router
      // exists to prevent — the same call `pp_health` makes.

      // ---- Treatment ---------------------------------------------------------
      'ttc_treatment' => const TtcTreatmentScreen(),
      'ttc_records' => const TtcRecordsScreen(),
      'ttc_medication' => const TtcMedicationScreen(),
      'ttc_appointments' => const TtcAppointmentsScreen(),

      // ---- Mind and body -----------------------------------------------------
      'ttc_ritual' => TtcRitualScreen(chapter: TtcStore.instance.today.chapter),
      'ttc_journal' => const TtcJournalScreen(),

      // ---- Partner -----------------------------------------------------------
      // ⚠️ HER view of the partner material, not his door into the app. The
      // partner's own account has a separate root and a separate privacy
      // contract — see the note on `TtcStore.partnerChapter`. Routing a bracket
      // at his screen would be a privacy defect, not a convenience.
      'ttc_partner' => const TtcPartnerTodayScreen(),

      // ---- People ------------------------------------------------------------
      'ttc_prepare' => const TtcPrepareScreen(),
      'ttc_community' => const TtcCommunityScreen(),
      'ttc_care_circle' => const TtcCareCircleScreen(),

      // ---- Commerce ----------------------------------------------------------
      'ttc_products' => const TtcProductsScreen(),

      _ => null,
    };
