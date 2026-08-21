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

import '../../localization/app_language.dart';
import '../../ttc/ttc_reads_data.dart';
import '../../ttc/ttc_store.dart';
import '../../ttc/ttc_videos_data.dart';
import '../reader/pv_reader_screen.dart';
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
import 'ttc_pcos_check_screen.dart';
import 'ttc_precheck_screen.dart';
import 'ttc_prepare_screen.dart';
import 'ttc_products_screen.dart';
import 'ttc_records_screen.dart';
import 'ttc_strings.dart';
import 'ttc_ritual_screen.dart';
import 'ttc_supplements_screen.dart';
import 'ttc_tests_screen.dart';
import 'ttc_treatment_screen.dart';
import 'ttc_vaccines_screen.dart';

/// The prefix that opens a long-form read.
///
/// ⚠️ A PREFIX RATHER THAN ONE CASE PER ARTICLE, and that is the whole point.
/// The library grows by roughly twenty pieces and every other stage's router
/// would have grown twenty `case` lines, each of which is a place to typo an id
/// that then routes nowhere. Here the id IS the lookup: adding an article to
/// `ttc_reads_data.dart` makes it reachable with no router change at all.
const String kTtcReadPrefix = 'ttc_read/';

Widget? ttcScreenForSurface(String id) {
  // ---- long-form reads ------------------------------------------------------
  if (id.startsWith(kTtcReadPrefix)) {
    final read = ttcReadById(id.substring(kTtcReadPrefix.length));
    // Null is a real answer here too — an unknown article id opens nothing
    // rather than opening the wrong article. `ArticleReaderScreen` (parenting)
    // does the opposite: handed nothing it renders a sleep piece under whatever
    // title was tapped, and no fault is reported anywhere.
    if (read == null) return null;
    return PvReaderScreen(
      read: read,
      // ⚠️ TTC's OWN LANGUAGE FLAG, not the pregnancy `AppLanguage` store. The
      // two are separate on purpose — this stage is still Hinglish and
      // pregnancy is Devanagari, and reading the wrong one would render
      // Devanagari inside a Hinglish shell.
      lang: TtcLang.instance.hinglish
          ? AppLanguage.hinglish
          : AppLanguage.english,
      resolveVideo: ttcVideoBySlot,
      readTitle: ttcReadTitle,
      openRead: (context, readId) =>
          _push(context, kTtcReadPrefix + readId),
      openSurface: _push,
    );
  }

  return _ttcStaticSurface(id);
}

/// Pushes another surface from inside the reader.
///
/// Lives here rather than in the reader because the reader is stage-neutral and
/// must not know how any one stage names its routes.
void _push(BuildContext context, String surfaceId) {
  final screen = ttcScreenForSurface(surfaceId);
  if (screen == null) return;
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: surfaceId),
    builder: (_) => screen,
  ));
}

Widget? _ttcStaticSurface(String id) => switch (id) {
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
      // ⚠️ SEPARATE FROM `ttc_tests`, DELIBERATELY. That screen is the
      // fertility work-up library — AMH, HSG, semen analysis. Vaccination is a
      // different errand at a different moment with a different consequence
      // (a live vaccine delays trying; a blood test never does). Folding it in
      // would bury the one item on the preconception list that has a deadline.
      'ttc_vaccinations' => const TtcVaccinesScreen(),
      // The workbook's PCOS Tools cell, other half. `ttc_cycle` was always the
      // tracker; this is the checker that sat beside it as notReady.
      'ttc_pcos_check' => const TtcPcosCheckScreen(),
      // The workbook's Getting-ready Tools cell. Reads across CycleStore, the
      // PCOS checker, the vaccination list, supplements and medicines, so it
      // opens knowing what she has already done.
      'ttc_precheck' => const TtcPrecheckScreen(),
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
