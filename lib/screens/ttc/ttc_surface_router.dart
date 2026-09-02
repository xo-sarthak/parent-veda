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
// ⚠️ `ttc_pcos_check_screen.dart` IS NOT IMPORTED ANY MORE, and reverting the
// retired checker therefore needs two lines rather than one: this import back,
// and the commented case below uncommented. Keeping an unused import to make it
// one line would have meant an analyzer warning living in the tree forever to
// save someone five seconds — and a warning nobody can fix is how a project
// learns to stop reading warnings.
import 'ttc_ivf_readiness_screen.dart';
import 'ttc_pcos_stand_screen.dart';
import 'ttc_bmi_screen.dart';
import '../../ttc/ttc_precheck_data.dart';
import 'ttc_precheck_screen.dart';
import 'ttc_prepare_screen.dart';
import 'ttc_products_screen.dart';
import 'ttc_records_screen.dart';
import 'ttc_strings.dart';
import 'ttc_symptom_log_screen.dart';
import 'ttc_ritual_screen.dart';
import 'ttc_supplements_screen.dart';
import 'ttc_tests_screen.dart';
import 'ttc_tools_screen.dart';
import 'ttc_treatment_screen.dart';
import 'ttc_vaccines_screen.dart';
import 'ttc_window_screen.dart';

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

  // ---- the checklist, opened on a named section ---------------------------
  //
  // Same prefix pattern as `ttc_read/` and parenting's `pp_section/`, resolved
  // against the enum rather than accepting the suffix blindly — so a door
  // naming a section that does not exist still fails.
  const precheckPrefix = 'ttc_precheck/';
  if (id.startsWith(precheckPrefix)) {
    final name = id.substring(precheckPrefix.length);
    final match = PrecheckSection.values.where((s) => s.name == name);
    if (match.isEmpty) return null;
    return TtcPrecheckScreen(openSection: match.first);
  }

  return _ttcStaticSurface(id);
}

/// Opens a surface by id from anywhere in the stage.
///
/// The Tools hub uses this rather than naming screen classes itself. The reason
/// is one-definition-of-where: a door in `ttc_hubs.dart`, a step in
/// `ttc_journeys.dart` and a tile in the Tools hub all mean the same
/// destination, and if each constructs its own `MaterialPageRoute` then the
/// route *name* — which `global_ask_fab.dart` reads to decide which Ask Veda to
/// open — drifts between them. Routing every entrance through one function
/// means the surface id IS the route name, always.
void openTtcSurface(BuildContext context, String surfaceId) =>
    _push(context, surfaceId);

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
      // ⚠️ THE DESIGNED SCREEN. Built from `Fertility Window.dc.html` in the
      // "fertile window tool" design project — structure 1b, with 1a's ranked
      // day list as the default graphic behind a toggle.
      //
      // ⚠️ `TtcFertilityWindowScreen` IN `ttc_cycle_screens.dart` IS NO LONGER
      // REACHED, and is left in place rather than deleted. It is the pre-design
      // version and it still holds the reasoning for two rules the new screen
      // keeps — never showing a window that has closed, and replacing the whole
      // six-day model on a clinic-run cycle. Read those notes before changing
      // either behaviour here.
      'ttc_window' => const TtcWindowScreen(),
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
      //
      // ⚠️ THE ID NOW OPENS "WHERE DO I STAND", NOT THE 20-QUESTION CHECKER.
      //
      // The id is kept rather than replaced because it is an IDENTITY: it is
      // named by `ttc_brackets.dart`, a journey step, the Tools hub and
      // `ttc_surfaces.dart`, and it is the route name `global_ask_fab.dart`
      // reads. Renaming it would mean touching five files to change nothing a
      // user can see.
      //
      // What changed is what it opens. The short flow asks eight questions
      // instead of twenty and writes its answers into the SAME
      // `TtcPcosCheckStore` — see `PcosStandAnswers.writeThrough` — so the BMI
      // screen, the pre-check rules and the fertility-help store all keep
      // reading a check that is still there.
      //
      // ⚠️ THE OLD SCREEN IS COMMENTED, NOT DELETED, per CLAUDE.md. Its data,
      // rules, store and result screen are all untouched on disk. To revert:
      // restore the `ttc_pcos_check_screen.dart` import and swap the two lines
      // below.
      //
      // 'ttc_pcos_check' => const TtcPcosCheckScreen(),
      'ttc_pcos_check' => const TtcPcosStandScreen(),
      // The workbook's Getting-ready Tools cell. Reads across CycleStore, the
      // PCOS checker, the vaccination list, supplements and medicines, so it
      // opens knowing what she has already done.
      'ttc_precheck' => const TtcPrecheckScreen(),
      // ⚠️ SOUTH ASIAN THRESHOLDS ARE PRIMARY HERE. See the head of
      // `ttc_bmi_rules.dart` — reading an Indian woman against European
      // cut-offs is the specific thing `ttc_read_three_months_before` already
      // tells her is wrong.
      'ttc_bmi' => const TtcBmiScreen(),
      // The Tools hub — 21 built tiles, including the Sleep, Movement, Stress
      // and Lifestyle trackers the Getting-ready habits step hands her to.
      'ttc_tools' => const TtcToolsScreen(),
      // The Infertility Tools cell. A readiness read, never a probability: see
      // `ttc_fertility_help_rules`.
      //
      // ⚠️ THE ID NOW OPENS THE REBUILT FLOW, AND THE ENGINE UNDERNEATH IS THE
      // SAME ONE. Same pattern as `ttc_pcos_check`: the surface id is an
      // identity — named by `ttc_brackets.dart`, a journey step and the Tools
      // hub, and read as a route name by `global_ask_fab.dart` — so it stays.
      //
      // What changed is the front and the output. `TtcIvfReadinessScreen` asks
      // six questions including two the old flow never did (his semen test, and
      // a cycle answer she can see and correct), and it reads
      // `FertilityHelpContext` — the shipped assembly of what the app already
      // knows — rather than rebuilding it.
      //
      // ⚠️ THE BRIEF ASKED FOR A FULL REPLACEMENT ON A FALSE PREMISE. It
      // describes the shipped tool as a three-question check missing age and
      // duration. On disk it asks age and derives duration from
      // `TtcStore.daysTrying`, and its rules file carries a NICE-cited referral
      // threshold and an urgent fertility-preservation route. Throwing that away
      // to satisfy a description of it would have lost reviewed clinical work.
      //
      // ⚠️ OLD SCREEN COMMENTED, NOT DELETED, per CLAUDE.md. To revert: restore
      // the `ttc_fertility_help_screen.dart` import and swap the two lines.
      // `TtcFertilityHelpSummary` goes with it — nothing else reaches it.
      //
      // 'ttc_fertility_help' => const TtcFertilityHelpScreen(),
      'ttc_fertility_help' => const TtcIvfReadinessScreen(),
      // ⚠️ ADDED SO A TILE CAN NAME THE LOGGER. It was reachable only by a
      // direct `MaterialPageRoute` from the home's "Check symptoms" button, so
      // a focus-page tile that wanted it had nothing to point at — and the PCOS
      // door's "Log your symptoms" tile ended up pointing at the Tools HUB
      // instead. A tile whose title names one screen and whose id opens another
      // is the wrong-screen failure this stage keeps writing tests about, and I
      // wrote it.
      //
      // Registering it here also means the route NAME is the surface id, which
      // is what `global_ask_fab.dart` reads to decide which Ask Veda opens.
      'ttc_symptom_log' => const TtcSymptomLogScreen(),
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

/// The same tool, with no frame of its own, for a page that shows it in place.
///
/// ⚠️ A SECOND MAP AND NOT A FLAG ON THE FIRST, BECAUSE THESE ANSWER DIFFERENT
/// QUESTIONS. `ttcScreenForSurface` returns something you can push — it owns a
/// Scaffold, a background and a way out. This returns something you can drop
/// into a page that already has all three. A tool that has been split into a
/// frame and a body appears in both; a tool that has not appears only in the
/// first, and gets null here rather than an unusable screen embedded in a page.
///
/// ⚠️ NULL IS THE NORMAL ANSWER, and callers must handle it. Twenty-odd
/// surfaces exist and exactly one has been split so far.
///
/// ⚠️ AND IT LIVES HERE RATHER THAN IN THE FOCUS SCREEN so that surface ids are
/// resolved in one file. A second place that maps `'ttc_pcos_check'` to a
/// widget is a second place for that string to go stale — and a stale id here
/// fails the way this repo's worst bugs fail: the tile renders, and nothing
/// happens.
Widget? ttcInlineToolFor(String surfaceId) => switch (surfaceId) {
      'ttc_pcos_check' => const TtcPcosStandBody(),
      _ => null,
    };
