// =============================================================================
//  TTC - Tools
// -----------------------------------------------------------------------------
//  "This becomes the largest feature after Today. Tools help. Tools do not
//   judge. Every tool exists even if unused."          - TTC master, §2.7
//
//  Every tile below is listed from day one, used or not - the same rule the
//  pregnancy Tools tab follows. A tool she has never opened must still teach
//  her it exists, so the grid never shrinks to "what you use".
//
//  Where a tile is not built yet it says so on tap rather than doing nothing.
//  The `built` flag on each entry is what the wiring test asserts against, so
//  a tile cannot quietly claim to work.
//
//  ⚠️ THE REVIEW PASS, 2026-09-26 (reviewer MR, scratchpad mobbin_review.md
//  §2b). What changed:
//    T1  the V3 tab header, the one Learn uses: a large display title and one
//        line, no wordmark, no coral eyebrow. The profile circle stays ONLY on
//        V1, whose bar has no You tab; on V3 the bar's You is the way there.
//        Mobbin: Apple Health Search, a large title then the list (AH-SEARCH,
//        https://mobbin.com/screens/cd8919aa-c470-48b8-8716-54343395eab2).
//    T2  the lists are unboxed: `PvRowGroup` + `PvListRow`, the row Learn and
//        the store use (DESIGN-SYSTEM §4.13 "Lists are not boxed").
//    T3  each group has a hue and every tool's glyph sits in that tint's well
//        in the tint's own ink, instead of 25 identical violet glyphs (violet
//        is for eyebrows, links, switches and progress only, §4.0). The hue is
//        the matching door's, so a colour means one subject across the stage.
//        Mobbin: AH-SEARCH (category colour on each glyph) and Fresha search
//        (https://mobbin.com/screens/86a0b800-40fe-4cbe-a1b6-1355f84bd38d).
//        ⚠️ 2026-09-29: the glyph in a square well became each tool's DRAWN
//        MARK on a disc of the same tint, the family the door rails draw
//        (`ttc_tool_marks.dart`). Same hue rule, same place in the row.
//    T4  the field is `PvLiveSearchField` on a `PvLiveSearch`, the flow every
//        door and Learn use (focus rides the field up, Back twice), not a
//        third copy of the pill. Matching is the doors' word-prefix rule.
//    T5  every search ends on "Ask Veda about …", as Learn and the doors do.
//    E11 a search also lists what the library has on it, from the same index
//        Learn searches (`ttcLibraryIndex`): "HSG" offers the read as well as
//        any tool. Tools stays the tools list first.
//    T6  rows and the quick cards press (`PvPress`) and answer with a haptic.
//    T7  "See a specialist?" wears a compass, not the headset "Talk to an
//        expert" already wears.
//    Y2  "Cycle companion", "Fertility window" and "Records and reports" are
//        spelt here once and the You tab reads them from `ttcToolById`, so
//        the two tabs cannot drift. The cycle and window tiles open the same
//        surfaces You and the doors open (`ttc_cycle`, `ttc_window`); the
//        window tile used to open the pre-design screen the surface router
//        calls unreached.
//
//  ⚠️ TOOLS HOLDS ONLY TOOLS (2026-09-28, the user: "under Tools I should
//  only be seeing tools, that's all ... the More button should have
//  everything else that was extra inside Tools").
//
//  WHAT A TOOL IS, IN ONE SENTENCE: a tool is something she uses to record,
//  track, calculate, check or plan her own data (her cycle, her logs, her
//  medicines, her results, her visits, her treatment dates, her questions).
//
//  NOT a tool, and so not on this page: booking a consult or an expert,
//  courses and classes, the store, reads and Learn, community, messages,
//  Saved, help and support pages, the care circle and pairing, the journey
//  map and its timeline (views of her journey, not her data), and settings.
//  Those live under the bar's More tab (the bento, pv_more_bento.dart) or on
//  the bar itself. `kTtcToolKinds` below is the classification, and
//  `test/ttc_tools_only_tools_test.dart` fails the build if a row here is not
//  a tool, or if a tool sits under More.
//
//  What moved (2026-09-28): "Talk to an expert" and "Courses" went to More's
//  "Experts and courses" tile; "Journey map" went to More's "Your journey"
//  tile. "Treatment cycle" came IN from More (it records her clinic's dates),
//  and "Records and reports" left More, where it had been a second door to
//  the row already here. The moved entries are kept, whole, in
//  `ttcMovedToMore`, so More prints the same name, line and destination.
//  Shape: MacroFactor's tabs are the working tools and its More holds the
//  roadmap and the knowledge base
//  (https://mobbin.com/screens/6f2fa44b-9e5a-4df3-9c6d-4ec214c9f0d9);
//  American Airlines' More holds booking and help, never a tool
//  (https://mobbin.com/screens/71e3fc57-af3c-446a-863e-a76f4088e03a).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_content_prefs.dart';
import '../../ttc/ttc_log_store.dart';
import '../../widgets/global_ask_fab.dart' show FabState, kAskVedaRoute;
import '../../widgets/pv_feedback.dart';
import '../../widgets/pv_nav_bar.dart' show pvNavClearance;
import '../doors/pv_list_row.dart';
import '../doors/pv_live_search.dart';
import '../products/pv_store_chrome.dart' show PvRoundIcon, pvStorePalette;
import '../v2/v2_palette.dart';
import 'doors/ttc_door_search.dart' show TtcDoorHit, TtcDoorHitRow, openTtcDoorHit;
import 'ttc_askveda_screen.dart';
import 'ttc_home_version.dart';
import 'ttc_learn_screen.dart' show ttcLibraryIndex, ttcLibrarySearch;
import 'ttc_profile_screen.dart' show openTtcProfile;
import '../../ttc/ttc_records_store.dart';
import '../../services/medicine_store.dart';
import '../../ttc/ttc_supplements_store.dart';
import '../../ttc/ttc_trackers_data.dart';
import '../../ttc/ttc_treatment_store.dart';
import 'ttc_appointments_screen.dart';
import 'ttc_can_i_screen.dart';
import 'ttc_ivf_readiness_screen.dart' show kTtcFertilityHelpName;
import 'ttc_tool_hues.dart';
import 'ttc_tool_marks.dart';
import 'ttc_common.dart';
import 'ttc_cycle_screens.dart';
// Kept for revert (2026-09-28, journal out of TTC):
// import 'ttc_journal_screen.dart';
import 'ttc_journey_map_screen.dart';
import 'ttc_nutrition_screen.dart';
import 'ttc_prepare_screen.dart';
// Only the Products row used it, and that row is commented out (T1,
// 2026-09-28). Kept for revert: import 'ttc_products_screen.dart';
import 'ttc_records_screen.dart';
import 'ttc_strings.dart';
import 'ttc_medication_screen.dart';
import 'ttc_supplements_screen.dart';
import 'ttc_surface_router.dart';
import 'ttc_tab_root_header.dart';
import 'ttc_tests_screen.dart';
import 'ttc_tracker_screen.dart';

/// One tile in the hub.
class TtcTool {
  const TtcTool({
    required this.id,
    required this.icon,
    required this.nameEn,
    required this.nameHi,
    required this.open,
    this.descEn = '',
    this.descHi = '',
    this.built = true,
  });

  final String id;

  /// The Material glyph this tool wore on the hub until 2026-09-29. The hub
  /// now draws the tool's mark (`kTtcToolMarks`, `ttc_tool_marks.dart`); the
  /// glyph stays because the You tab's rows still read it (Y2).
  final IconData icon;
  final String nameEn;
  final String nameHi;

  /// Three or four words on what the tool is for.
  ///
  /// Bare labels left the hub unreadable: nothing distinguished Mood from
  /// Stress from Lifestyle, and the whitespace for a line of explanation was
  /// already sitting there unused. Shown only until the tile has something of
  /// hers in it - after that the state line is the more useful thing to say.
  final String descEn;
  final String descHi;

  String desc(bool hi) => hi ? descHi : descEn;

  /// What tapping it does. Never null - a tile that does nothing reads as a bug.
  final void Function(BuildContext) open;

  /// False for tiles whose destination arrives in a later phase. Pinned by test
  /// so a tile cannot silently pretend to be finished.
  final bool built;

  String name(bool hi) => hi ? nameHi : nameEn;
}

class TtcToolGroup {
  const TtcToolGroup({
    required this.titleEn,
    required this.titleHi,
    required this.tools,
    this.hue = 268,
  });

  final String titleEn;
  final String titleHi;
  final List<TtcTool> tools;

  /// The tint of every well in the group (T3). Each is the hue of the door
  /// that holds the same subject (`kTtcBrackets`), so a colour keeps one
  /// meaning across the stage.
  final double hue;

  String title(bool hi) => hi ? titleHi : titleEn;
}

/// The tools named in the master document, §2.7, plus the five checks the
/// level-map checklist added later, grouped the way the pregnancy hub groups
/// its own.
///
/// The count is not the invariant - findability is. See `ttc_tools_test.dart`.
final List<TtcToolGroup> ttcToolGroups = [
  TtcToolGroup(
    titleEn: 'Your body',
    titleHi: 'Aapka body',
    // Body and cycle's hue. The same constant every tool in this group wears
    // in its header (launch sanity T6, ttc_tool_hues.dart). Was: 172.
    hue: kTtcToolHueBody,
    tools: [
      // ⚠️ Y2 (2026-09-26): one name, one icon, one line and one destination
      // for this tool on both tabs. You reads all four from here. Kept for
      // revert: icon favorite_outline_rounded, 'Cycle Companion',
      // 'Your periods, and what they say', and a push of TtcCycleScreen at
      // 'ttc/cycle'.
      TtcTool(
        id: 'cycle',
        icon: Icons.timeline_rounded,
        nameEn: 'Cycle companion',
        nameHi: 'Cycle Companion',
        // Plain line, 2026-09-27 (simplicity pass). Kept for revert: 'Your periods, and what they tell you'.
        descEn: 'Log your period dates and see your cycle',
        descHi: 'Aapke periods, aur unka matlab',
        open: (c) => openTtcSurface(c, 'ttc_cycle'),
      ),
      TtcTool(
        id: 'ovulation',
        icon: Icons.egg_outlined,
        // What it is, not an invented word (2026-09-28): the screen became a
        // test log in the tool rebuild. Kept for revert: 'Ovulation companion'.
        nameEn: 'Ovulation tests',
        nameHi: 'Ovulation Companion',
        // Plain line, 2026-09-27 (simplicity pass). Kept for revert: 'Signs your body gives'.
        descEn: 'Log ovulation tests and signs from your body',
        descHi: 'Body ke ishaare',
        open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
            builder: (_) => const TtcOvulationScreen(),
            settings: const RouteSettings(name: 'ttc/ovulation'))),
      ),
      // ⚠️ Y2: the designed window screen, through the surface every other
      // entrance uses. This tile alone still pushed the pre-design
      // `TtcFertilityWindowScreen`, which `ttc_surface_router.dart` records
      // as no longer reached. Kept for revert: 'Fertility Window',
      // 'The days that matter most', a push of TtcFertilityWindowScreen at
      // 'ttc/window'.
      TtcTool(
        id: 'window',
        icon: Icons.wb_twilight_rounded,
        // One name (2026-09-27); kept for revert: 'Fertility window'.
        nameEn: 'Fertile window',
        nameHi: 'Fertility Window',
        // Plain line, 2026-09-27 (simplicity pass). Kept for revert: 'The days that count most this cycle'.
        descEn: "The six days you're most likely to get pregnant",
        descHi: 'Sabse ahem din',
        open: (c) => openTtcSurface(c, 'ttc_window'),
      ),
      TtcTool(
        id: 'symptoms',
        icon: Icons.healing_outlined,
        // ⚠️ ONE TILE FOR THE ONE LOGGER (2026-09-27, build 11 on the phone):
        // "Symptom companion" and "Mood" both opened this same screen, which
        // logs feelings and body together. One tile, named for both. Kept for
        // revert: 'Symptom companion', 'Log how your body feels each day'.
        nameEn: 'Symptoms and mood',
        nameHi: 'Symptom Companion',
        // Plain line, 2026-09-27 (simplicity pass). Kept for revert: 'Notice patterns, never diagnose'.
        descEn: 'How you feel and what your body does, each day',
        descHi: 'Pattern dekhein, diagnose nahi',
        // ⚠️ THE NEW LOGGER, the one the home's Symptoms opens (launch walk,
        // 2026-09-27): this row still opened the retired five-point tracker,
        // so one job had two screens. Same `symptoms` store underneath.
        // Kept for revert: open: (c) => openTtcTracker(c, 'symptoms'),
        open: (c) => openTtcSurface(c, 'ttc_symptom_log'),
      ),
      TtcTool(
        id: 'weight',
        icon: Icons.monitor_weight_outlined,
        nameEn: 'Weight',
        nameHi: 'Wazan',
        // ⚠️ ONE WEIGHT TOOL (launch sanity T1/T2, 2026-09-28). "Weight" and
        // "Weight and fertility" were two rows for one subject; the BMI read
        // now opens from the Weight page, so this line names it and a search
        // for "BMI" still lands here. Kept for revert:
        // descEn: 'Just a number, not a judgement',
        descEn: 'Log your weight and see your BMI',
        descHi: 'Ek number, faisla nahi',
        open: (c) => openTtcTracker(c, 'weight'),
      ),
      // ⚠️ ONE TILE WHERE THERE WERE FOUR — 2026-09-04. Sleep, Stress,
      // Lifestyle and Movement each had their own tile and their own tracker;
      // they are one `habits` tracker now, so four tiles pointing at four
      // screens would be four doors into one room. The three commented out
      // below are kept for revert, and reverting them means removing
      // `kTtcHabitMerge` too — see the note on it.
      TtcTool(
        id: 'habits',
        icon: Icons.self_improvement_outlined,
        nameEn: "What you're working on",
        nameHi: 'Aap jis par kaam kar rahe hain',
        // ⚠️ THE DESCRIPTION NAMES ALL FOUR, AND THAT IS A FINDABILITY RULE
        // RATHER THAN A STYLE CHOICE. `ttc_tools_test.dart` asserts that every
        // capability the master document names stays findable by the word she
        // would look for — and merging four trackers into one removed the
        // words Sleep, Stress, Lifestyle and Movement from the hub entirely.
        // The capabilities did not go anywhere; they are fields now. So the
        // tile has to say so.
        descEn: 'Sleep, movement, stress and lifestyle',
        descHi: 'Neend, movement, stress aur lifestyle',
        open: (c) => openTtcTracker(c, 'habits'),
      ),
      /*
      TtcTool(
        id: 'sleep',
        icon: Icons.bedtime_outlined,
        nameEn: 'Sleep',
        nameHi: 'Neend',
        descEn: 'Hours, and how they felt',
        descHi: 'Ghante, aur kaisa laga',
        open: (c) => openTtcTracker(c, 'sleep'),
      ),
      */
      // ---- the four checks, listed where she goes looking for them ---------
      //
      // These were reachable only from inside a journey step. That is the
      // contextual entrance and it is the better one - she meets the checker
      // at the moment the question occurs to her. But it is not the only way
      // anyone arrives: a woman who has been told "you might have PCOS" opens
      // Tools and searches for the word, and finding nothing concludes we do
      // not have it. The hub is the INDEX; the journey is the recommendation.
      // Both must exist, and the hub's own rule at the top of this file
      // already said so - "a tool she has never opened must still teach her it
      // exists".
      TtcTool(
        id: 'pcos_check',
        icon: Icons.checklist_rtl_rounded,
        nameEn: 'PCOS symptom check',
        nameHi: 'PCOS symptom check',
        descEn: 'Questions worth taking to a doctor',
        descHi: 'Doctor ko dikhane layak sawaal',
        open: (c) => openTtcSurface(c, 'ttc_pcos_check'),
      ),
      // ⚠️ FOLDED INTO WEIGHT (launch sanity T1/T2, 2026-09-28): the BMI
      // page opens from the Weight page, so a second row for the same
      // subject is gone from the hub. Kept for revert (2026-09-28):
      // TtcTool(
      //   id: 'bmi',
      //   // Deliberately NOT the same destination as the Weight tracker beside
      //   // it: that one logs a series over months, this one reads a single
      //   // number against South Asian cut-offs and says what it does and does
      //   // not mean for fertility. Two tiles, two pages, two questions.
      //   icon: Icons.straighten_rounded,
      //   nameEn: 'Weight and fertility',
      //   nameHi: 'Wazan aur fertility',
      //   descEn: "What BMI does and doesn't tell you",
      //   descHi: 'BMI kya kehta hai, kya nahi',
      //   open: (c) => openTtcSurface(c, 'ttc_bmi'),
      // ),
      // ⚠️ MOVED TO "CARE AND MEDICINES" (launch sanity T1/T6/D18,
      // 2026-09-28), beside Talk to an expert: it is about when to see a
      // doctor, and its screen already wore the clinic colour, so the row
      // and the header now agree. One name with its door card and screen.
      // Kept for revert (2026-09-28):
      // TtcTool(
      //   id: 'fertility_help',
      //   // T7: a compass. The headset is "Talk to an expert"'s.
      //   icon: Icons.explore_outlined,
      //   nameEn: 'See a specialist?',
      //   nameHi: 'Specialist se milein?',
      //   // Plain line, 2026-09-27 (simplicity pass). Kept for revert: 'Is it time yet?'.
      //   descEn: "Check if it's time to see a fertility doctor",
      //   descHi: 'Kya ab waqt hai',
      //   open: (c) => openTtcSurface(c, 'ttc_fertility_help'),
      // ),
    ],
  ),
  TtcToolGroup(
    titleEn: 'Both of you',
    titleHi: 'Aap dono',
    // His side's hue (T6: ttc_tool_hues.dart). Was: 186.
    hue: kTtcToolHueBoth,
    tools: [
      TtcTool(
        id: 'partner_health',
        icon: Icons.male_rounded,
        nameEn: 'Partner health',
        nameHi: 'Partner ki sehat',
        // Plain line, 2026-09-27 (simplicity pass). Kept for revert: 'His half of this'.
        descEn: 'His health, tests and habits',
        descHi: 'Unka aadha hissa',
        open: (c) => openTtcTracker(c, 'partner_health'),
      ),
      // The Mood tile opened the same logger as "Symptoms and mood" above
      // (2026-09-27), so it is folded into that one. Kept for revert:
      // TtcTool(
      //   id: 'mood',
      //   icon: Icons.mood_outlined,
      //   nameEn: 'Mood',
      //   nameHi: 'Mood',
      //   descEn: "Log how you're feeling today",
      //   descHi: 'Din asal mein kaisa tha',
      //   open: (c) => openTtcSurface(c, 'ttc_symptom_log'),
      // ),
      /*
      TtcTool(
        id: 'stress',
        icon: Icons.spa_outlined,
        nameEn: 'Stress',
        nameHi: 'Stress',
        descEn: "What's weighing on you",
        descHi: 'Kya bojh mehsoos ho raha',
        open: (c) => openTtcTracker(c, 'stress'),
      ),
      */
      /*
      TtcTool(
        id: 'lifestyle',
        icon: Icons.wb_sunny_outlined,
        nameEn: 'Lifestyle',
        nameHi: 'Lifestyle',
        descEn: 'Habits worth a small change',
        descHi: 'Aadatein jinme chhota badlaav',
        open: (c) => openTtcTracker(c, 'lifestyle'),
      ),
      */
      // Kept for revert (2026-09-28, journal out of TTC): the user took the
      // journal out of the stage, for her and for him. A saved "recent" of
      // 'journal' resolves to nothing in `ttcToolById` and is skipped.
      // TtcTool(
      //   id: 'journal',
      //   icon: Icons.edit_note_rounded,
      //   // The page's own name (2026-09-27). Kept for revert: 'Journal'.
      //   nameEn: 'Our journal',
      //   nameHi: 'Journal',
      //   descEn: 'Both of you can write here',
      //   descHi: 'Aap dono yahan likh sakte hain',
      //   open: openTtcJournal,
      // ),
    ],
  ),
  TtcToolGroup(
    titleEn: 'Care and medicines',
    titleHi: 'Dekhbhaal aur dawaiyan',
    // IVF and IUI's hue, the clinic door (T6: ttc_tool_hues.dart). Was: 206.
    hue: kTtcToolHueCare,
    tools: [
      // ⚠️ TALK TO AN EXPERT LEFT THE BAR — 2026-09-26. The V3 bar became
      // Today · Learn · Products · Tools · You, and the consults it opened
      // are this tile now (the home keeps its Talk to experts rail). Same
      // screen, same route name, so `ttcV3ActiveFor` lights Tools for it.
      // 24 -> 25.
      // ⚠️ MOVED TO MORE (2026-09-28, the user: Tools holds only tools).
      // Booking a consult is not a tool; the row lives, word for word, in
      // `ttcMovedToMore` below and More's "Experts and courses" tile reads
      // it from there. Kept for revert (2026-09-28):
      // TtcTool(
      //   id: 'expert',
      //   icon: Icons.support_agent_outlined,
      //   nameEn: 'Talk to an expert',
      //   nameHi: 'Talk to an expert',
      //   // ⚠️ NOT A DUPLICATE OF A TAB (launch sanity T1, 2026-09-28): the V3
      //   // bar has no consults tab, so this row IS where booking lives on
      //   // Tools. Its line says it is a booking. Kept for revert:
      //   // descEn: 'A private video call with a specialist',
      //   descEn: 'Book a private video call with a specialist',
      //   descHi: 'A private video call with a specialist',
      //   open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
      //       builder: (_) => const TtcPrepareScreen(onlyCategory: 'consults'),
      //       settings: const RouteSettings(name: 'ttc/consults'))),
      // ),
      // The specialist check, here since 2026-09-28 (see the note where it
      // was). Same id, same surface, so recents and tests still find it.
      TtcTool(
        id: 'fertility_help',
        icon: Icons.explore_outlined,
        nameEn: kTtcFertilityHelpName,
        nameHi: kTtcFertilityHelpName,
        descEn: "Check if it's time to see a fertility doctor",
        descHi: 'Kya ab waqt hai',
        open: (c) => openTtcSurface(c, 'ttc_fertility_help'),
      ),
      // Two tiles, because they are two different things and the single
      // "Supplements & medication" tile could only ever do one of them.
      //
      // A supplement here is something WE suggested, from a curated list with
      // a `+`. A medication is something a CLINIC prescribed and she is
      // reporting to us - free text, her dose, her schedule. Collapsing them
      // meant the stage asked "has medication taken over your timing?" and then
      // offered her nowhere to write the medication down.
      TtcTool(
        id: 'supplements',
        icon: Icons.eco_outlined,
        nameEn: 'Supplements',
        nameHi: 'Supplements',
        // ⚠️ THE DIFFERENCE IS SAID IN THE TWO ROWS (2026-09-27): a
        // supplement is something you choose to take; a medication is what a
        // doctor prescribed. Kept for revert: "What's worth taking, and why".
        descEn: 'What you choose to take, like folic acid',
        descHi: 'Kya lena theek hai, aur kyun',
        open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
            builder: (_) => const TtcSupplementsScreen(),
            settings: const RouteSettings(name: 'ttc/supplements'))),
      ),
      TtcTool(
        id: 'medication',
        icon: Icons.medication_outlined,
        nameEn: 'Medication',
        nameHi: 'Dawaiyan',
        // Kept for revert: 'What your clinic put you on'.
        descEn: 'Medicines your doctor prescribed for you',
        descHi: 'Clinic ne jo shuru karwaya',
        open: openTtcMedication,
      ),
      TtcTool(
        id: 'tests',
        icon: Icons.biotech_outlined,
        nameEn: 'Medical tests',
        nameHi: 'Medical Tests',
        // Change 5 (2026-09-28). Kept for revert: 'What each one tells you'.
        descEn: 'What each fertility test tells you',
        descHi: 'Har test kya batata hai',
        open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
            builder: (_) => const TtcTestsScreen(),
            settings: const RouteSettings(name: 'ttc/tests'))),
      ),
      TtcTool(
        id: 'vaccinations',
        icon: Icons.vaccines_outlined,
        nameEn: 'Vaccinations',
        nameHi: 'Vaccinations',
        // Plain line, 2026-09-27 (simplicity pass). Kept for revert: 'What to sort before, not during'.
        descEn: 'Jabs to have before you get pregnant',
        descHi: 'Pehle nipta lein, baad mein nahi',
        open: (c) => openTtcSurface(c, 'ttc_vaccinations'),
      ),
      TtcTool(
        id: 'records',
        icon: Icons.folder_shared_outlined,
        // Y2. Kept for revert: 'Records & reports'.
        nameEn: 'Records and reports',
        nameHi: 'Records aur reports',
        descEn: 'Both your results, in one place',
        descHi: 'Dono ke results, ek jagah',
        open: openTtcRecords,
      ),
      TtcTool(
        id: 'appointments',
        icon: Icons.event_note_outlined,
        nameEn: 'Appointments',
        nameHi: 'Appointments',
        descEn: 'Visits, and what to ask',
        descHi: 'Visits, aur kya poochhna hai',
        open: openTtcAppointments,
      ),
      // ⚠️ IN FROM MORE (2026-09-28, Tools holds only tools): the round
      // records her clinic's dates and reminds her before each step, so it
      // is a tool. It sat under More's "Your health" as "Treatment"; this is
      // now its one row on Tools and More. Named with the page's own eyebrow
      // ("Your treatment cycle"), and it wears this group's colour because
      // its header already does (`kIvfHue` is 206, `kTtcToolHueCare`).
      TtcTool(
        id: 'treatment',
        icon: Icons.event_repeat_outlined,
        nameEn: 'Treatment cycle',
        nameHi: 'Treatment cycle',
        descEn: "Your clinic's dates for IUI or IVF, step by step",
        descHi: "Your clinic's dates for IUI or IVF, step by step",
        open: (c) => openTtcSurface(c, 'ttc_treatment'),
      ),
    ],
  ),
  TtcToolGroup(
    // ⚠️ "LEARN" LEFT WITH THE COURSES (2026-09-28): what is left here plans
    // (food ideas, the checklist) and checks (Can I...?). Kept for revert:
    //   titleEn: 'Plan and learn', titleHi: 'Plan aur seekhein',
    titleEn: 'Plan and check',
    titleHi: 'Plan and check',
    // Getting ready's hue (T6: ttc_tool_hues.dart). Was: 104.
    hue: kTtcToolHuePlan,
    tools: [
      // ⚠️ COURSES LEFT THE BAR — 2026-09-17. Slot 2 of the V3 bar became the
      // unified store (docs/PRODUCTS-AUDIT.md); the courses hub is the first
      // tile of this group so it is one tap further, never hidden. 23 → 24.
      // ⚠️ AND LEFT TOOLS FOR MORE (2026-09-28): a course is not a tool. It
      // is More's "Experts and courses" tile now, read from `ttcMovedToMore`.
      // Kept for revert (2026-09-28):
      // TtcTool(
      //   id: 'courses',
      //   icon: Icons.school_outlined,
      //   nameEn: 'Courses',
      //   nameHi: 'Courses',
      //   // Plain line, 2026-09-27 (simplicity pass). Kept for revert: 'Guided, by people who know'.
      //   // ⚠️ SAYS WHAT IS THERE (launch sanity T9, 2026-09-28): the page
      //   // holds one free course and no expert classes, and with one course
      //   // "Courses" now opens it directly. Kept for revert:
      //   // descEn: 'Classes from experts, and one free course',
      //   descEn: 'One free course: Preconception garbh sanskar',
      //   descHi: 'Guided, jaankaar logon se',
      //   open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
      //       builder: (_) => const TtcPrepareScreen(onlyCategory: 'courses'),
      //       settings: const RouteSettings(name: 'ttc/courses'))),
      // ),
      /*
      TtcTool(
        id: 'exercise',
        icon: Icons.directions_walk_rounded,
        nameEn: 'Movement',
        nameHi: 'Movement',
        descEn: 'Movement that helps',
        descHi: 'Jo movement madad kare',
        open: (c) => openTtcTracker(c, 'exercise'),
      ),
      */
      TtcTool(
        id: 'nutrition',
        icon: Icons.restaurant_outlined,
        // One name with its page (2026-09-27): the page is "This week's
        // food ideas" since the tools pass; it never planned anything.
        // Kept for revert: 'Nutrition planner'.
        nameEn: "This week's food ideas",
        nameHi: 'Nutrition Planner',
        descEn: 'A week of ideas, not a plan',
        descHi: 'Hafte bhar ke ideas, plan nahi',
        open: openTtcNutrition,
      ),
      // ⚠️ MOVED TO MORE (2026-09-28): the map and its family timeline are a
      // view of her journey, not a tool. More's "Your journey" tile holds the
      // row now, read from `ttcMovedToMore`. Kept for revert (2026-09-28):
      // TtcTool(
      //   id: 'map',
      //   icon: Icons.map_outlined,
      //   nameEn: 'Journey map',
      //   nameHi: 'Journey Map',
      //   // Plain line, 2026-09-27 (simplicity pass). Kept for revert: 'Everything so far, at a glance'.
      //   descEn: 'Where you are this month, and what comes next',
      //   descHi: 'Poora safar, ek nazar mein',
      //   open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
      //       builder: (_) => const TtcJourneyMapScreen(),
      //       settings: const RouteSettings(name: 'ttc/map'))),
      // ),
      TtcTool(
        id: 'canI',
        icon: Icons.help_outline_rounded,
        nameEn: 'Can I...?',
        nameHi: 'Kya main...?',
        descEn: 'Quick answers to everyday worries',
        descHi: 'Rozmarra ki chinta, hal',
        open: openTtcCanI,
      ),
      TtcTool(
        id: 'precheck',
        icon: Icons.fact_check_outlined,
        nameEn: 'Pre-pregnancy checklist',
        nameHi: 'Pre-pregnancy checklist',
        // Plain line, 2026-09-27 (simplicity pass). Kept for revert: 'The three months before'.
        // Change 5 (2026-09-28). Kept for revert: '…three months before'.
        descEn: 'What to sort in the three months before trying',
        descHi: 'Pehle ke teen mahine',
        open: (c) => openTtcSurface(c, 'ttc_precheck'),
      ),
      // ⚠️ OFF THE HUB (launch sanity T1, 2026-09-28): it opened the same
      // store as the bar's Products tab (V3) and the Prepare tab (V1), so
      // it was a link to a tab she can already see, not a tool. Kept for
      // revert (2026-09-28):
      // TtcTool(
      //   id: 'guide',
      //   icon: Icons.verified_outlined,
      //   // ⚠️ SAYS WHAT IT IS (2026-09-27). "Worth knowing about" never said
      //   // it was the products page, and it opens the same store as the bar's
      //   // Products tab, so it takes that one name. Kept for revert:
      //   // nameEn: 'Worth knowing about', descEn: 'Read first, buy later'.
      //   nameEn: 'Products',
      //   nameHi: 'Jaanne layak',
      //   descEn: "What's worth buying, and what to skip",
      //   descHi: 'Pehle research, phir kharid',
      //   open: openTtcProducts,
      // ),
    ],
  ),
];

// ---- what is a tool, and what moved to More (2026-09-28) ---------------------

/// More's tile for booking an expert and the courses (pv_you_content.dart
/// titles its group with this, so the Tools search note and the tile agree).
const String kTtcMoreExpertsTitle = 'Experts and courses';

/// More's journey tile (pv_you_screen.dart draws it under this title).
const String kTtcMoreJourneyTitle = 'Your journey';

/// The rows that left Tools because they are not tools, whole, so More prints
/// them with the same name, line, icon and destination they had here (the Y2
/// rule: one thing, one name, on every tab).
final List<TtcTool> ttcMovedToMore = [
  TtcTool(
    id: 'expert',
    icon: Icons.support_agent_outlined,
    nameEn: 'Talk to an expert',
    nameHi: 'Talk to an expert',
    descEn: 'Book a private video call with a specialist',
    descHi: 'A private video call with a specialist',
    open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
        builder: (_) => const TtcPrepareScreen(onlyCategory: 'consults'),
        settings: const RouteSettings(name: 'ttc/consults'))),
  ),
  TtcTool(
    id: 'courses',
    icon: Icons.school_outlined,
    nameEn: 'Courses',
    nameHi: 'Courses',
    descEn: 'One free course: Preconception garbh sanskar',
    descHi: 'Guided, jaankaar logon se',
    open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
        builder: (_) => const TtcPrepareScreen(onlyCategory: 'courses'),
        settings: const RouteSettings(name: 'ttc/courses'))),
  ),
  // ⚠️ THE JOURNEY MAP LEFT MORE TOO (2026-09-30, the user; see
  // ttc_more_tab.dart), so a Tools search no longer says it is there. Kept
  // for revert:
  // TtcTool(
  //   id: 'map',
  //   icon: Icons.map_outlined,
  //   nameEn: 'Journey map',
  //   nameHi: 'Journey Map',
  //   // Names the timeline too: it opens from the map, and the map is where
  //   // she now finds it.
  //   descEn: 'Where you are this month, what comes next, and your family timeline',
  //   descHi: 'Poora safar, ek nazar mein',
  //   open: (c) => Navigator.of(c).push(MaterialPageRoute<void>(
  //       builder: (_) => const TtcJourneyMapScreen(),
  //       settings: const RouteSettings(name: 'ttc/map'))),
  // ),
];

/// Which More tile each moved row sits under, for the note a Tools search
/// shows when she looks for one by its old place.
///
/// 2026-09-29 (the More tab is headed sections, ttc_more_tab.dart): the
/// names are More's section headings now. Kept for revert:
///   'expert': kTtcMoreExpertsTitle, 'courses': kTtcMoreExpertsTitle,
///   'map': kTtcMoreJourneyTitle,
const Map<String, String> kTtcMovedToMoreTile = {
  'expert': 'Talk to an expert', // kTtcMoreExpertsHeading
  'courses': 'Courses and masterclasses', // kTtcMoreCoursesHeading
  // Off More since 2026-09-30. Kept for revert:
  // 'map': kTtcMoreJourneyTitle, // 'Your journey', kTtcMoreJourneyHeading
};

TtcTool? ttcMovedToMoreById(String id) {
  for (final t in ttcMovedToMore) {
    if (t.id == id) return t;
  }
  return null;
}

/// What each row that is, or was, on this hub IS: `true` for a tool (she
/// records, tracks, calculates, checks or plans her own data with it),
/// `false` for something that is not. `test/ttc_tools_only_tools_test.dart`
/// fails if a Tools row is missing here or marked `false`. Adding a row to
/// the hub means deciding, here, in one word, which it is.
const Map<String, bool> kTtcToolKinds = {
  // Your body: her cycle, her logs, her checks.
  'cycle': true, // records her period dates, tracks her cycle
  'ovulation': true, // logs ovulation tests and signs
  'window': true, // calculates her fertile days from her dates
  'symptoms': true, // logs symptoms and mood
  'weight': true, // tracks weight, calculates BMI
  'habits': true, // tracks sleep, movement, stress, lifestyle
  'pcos_check': true, // a check she answers
  // Both of you.
  'partner_health': true, // his own tracker
  // Care and medicines.
  'fertility_help': true, // a check: is it time to see a specialist
  'supplements': true, // records what she takes
  'medication': true, // records prescriptions, reminds
  'tests': true, // looks up a result and adds it to her records
  'vaccinations': true, // records when each was given
  'records': true, // keeps her results
  'appointments': true, // plans visits and the questions for them
  'treatment': true, // records her clinic's dates, reminds
  // Plan and check.
  'nutrition': true, // plans the week's food, keeps her swaps
  'canI': true, // checks an everyday worry
  'precheck': true, // plans the three months before, ticked off
  // NOT tools: moved to More on 2026-09-28.
  'expert': false, // booking a consult
  'courses': false, // a course
  'map': false, // a view of her journey, with the family timeline
  // NOT tools: left the hub earlier (kept so the list is the whole history).
  'guide': false, // the store; the bar's Products tab
  // The journal left the stage on 2026-09-28 and is named nowhere live in
  // TTC (test/ttc_journal_out_test.dart), so it has no entry here either.
};

/// Moved rows whose name or line matches [query], by the hub's own
/// word-prefix rule, so a search for "expert" says where it went instead of
/// finding nothing.
List<TtcTool> ttcMovedMatching(String query) {
  final words = query
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return const [];
  return [
    for (final t in ttcMovedToMore)
      if (words.every((q) => '${t.nameEn} ${t.descEn}'
          .toLowerCase()
          .split(RegExp(r'[^a-z0-9]+'))
          .any((w) => w.startsWith(q))))
        t,
  ];
}

/// The note a search shows for a moved row. Names the row and the tile.
/// A row whose section bears its own name says so, rather than "Talk to an
/// expert is under More, in Talk to an expert" (2026-09-29).
String ttcMovedNote(TtcTool t) => kTtcMovedToMoreTile[t.id] == t.nameEn
    ? '${t.nameEn} is a section of More now.'
    : '${t.nameEn} is under More, in ${kTtcMovedToMoreTile[t.id]}.';

/// Which tools she opened last, newest first. Local only: a tapping
/// shortcut, not history anyone else needs.
///
/// ⚠️ ORDER, NEVER STRUCTURE. This only decides which three tools sit in the
/// strip at the top. Every group below still lists every tool, in its fixed
/// place, whether she has used it or not (CLAUDE.md: personalisation changes
/// order, never structure; a feature is never hidden).
class TtcToolRecents extends ChangeNotifier {
  TtcToolRecents._();
  static final TtcToolRecents instance = TtcToolRecents._();

  static const String kKey = 'ttc_tools_recent';
  static const int _max = 3;

  List<String> _ids = const [];
  bool _loaded = false;
  List<String> get ids => _ids;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final p = await SharedPreferences.getInstance();
      _ids = p.getStringList(kKey) ?? const [];
      notifyListeners();
    } catch (_) {/* local-first: none is a fine answer */}
  }

  Future<void> touch(String id) async {
    _ids = [id, ..._ids.where((x) => x != id)].take(_max).toList();
    notifyListeners();
    try {
      await (await SharedPreferences.getInstance()).setStringList(kKey, _ids);
    } catch (_) {}
  }

  @visibleForTesting
  void resetForTest() {
    _ids = const [];
    _loaded = false;
  }
}

/// The heading over library hits in a tools search (E11). English only
/// (CLAUDE.md, "New work is English").
const String kTtcToolsFromLibrary = 'From the library';

/// Her hub's opening line: what this page is, first (2026-09-27).
const String kTtcToolsBody =
    'Tools to track your cycle, check a worry and keep your records. '
    'Tap one to open it. None of them are required.';

/// Where someone who has opened nothing yet usually starts.
const List<String> kTtcToolsStartIds = ['cycle', 'window', 'precheck'];

// ⚠️ HIS SIDE OF TOOLS (2026-09-27). Viewed as him, the hub showed all of her
// private logs: her period, her symptoms, her weight, a PCOS check. Flo for
// Partners draws the line we copy: he sees what is shared and what is his, and
// never logs or edits hers. So his hub is his own health, her window to read,
// the journal they share, and the care they book and keep together.

/// The tools he sees, in the order the groups already hold them.
const Set<String> kTtcHisToolIds = {
  'window',
  'partner_health',
  // Kept for revert (2026-09-28, journal out of TTC): 'journal',
  // Kept for revert (2026-09-28, Tools holds only tools): 'expert',
  // 'courses' and 'map' left for More, which he opens from the same bar.
  'tests',
  'records',
  'appointments',
  // In from More (2026-09-28): the round is the couple's (B10), and More's
  // "Treatment" row, which he could open, is now this Tools row.
  'treatment',
};

/// Where he starts when he has opened nothing yet.
// Kept for revert (2026-09-28, journal out of TTC): the journal was his third
// start. Appointments takes its place: the other thing the two of them keep
// together.
//   const List<String> kTtcHisToolsStartIds = ['partner_health', 'window', 'journal'];
const List<String> kTtcHisToolsStartIds = [
  'partner_health',
  'window',
  'appointments',
];

/// A tool's name and line said to him, where hers would be wrong from his
/// side ("Partner health · His half of this" names him in the third person).
const Map<String, (String, String)> kTtcHisToolWords = {
  // Change 5 (2026-09-28): "half of this" named nothing. Kept for revert:
  //   ('Your health', 'Your tests, habits and half of this'),
  'partner_health': ('Your health', 'Your health, tests and habits'),
  // Kept for revert: 'The days that count most this cycle'.
  'window': ('Her fertile window', "The six days she's most likely to get pregnant"),
};

/// A group's heading said to him, where hers would be wrong from his side
/// ("Your body" over her fertile window).
const Map<String, String> kTtcHisGroupTitles = {'Your body': 'Her cycle'};

/// His hub's opening line. Hers lists her cycle, mood and supplements.
const String kTtcHisToolsBody =
    'Her window to read, your own health, and what the two of you share.';

/// The groups for whoever is looking: all of them for her, his subset for him,
/// with any group left empty dropped.
List<TtcToolGroup> ttcToolGroupsFor({required bool him}) => !him
    ? ttcToolGroups
    : [
        for (final g in ttcToolGroups)
          if (g.tools.any((t) => kTtcHisToolIds.contains(t.id)))
            TtcToolGroup(
              titleEn: kTtcHisGroupTitles[g.titleEn] ?? g.titleEn,
              titleHi: kTtcHisGroupTitles[g.titleEn] ?? g.titleHi,
              hue: g.hue,
              tools: [
                for (final t in g.tools)
                  if (kTtcHisToolIds.contains(t.id)) t,
              ],
            ),
      ];

TtcTool? ttcToolById(String id) {
  for (final g in ttcToolGroups) {
    for (final t in g.tools) {
      if (t.id == id) return t;
    }
  }
  return null;
}

/// Tools whose name, purpose or group has a word starting with every word
/// of [query]: the doors' rule (T4), so "sleep" finds the habits tool by its
/// purpose line and "ppointment" does not find "Appointments".
List<TtcTool> ttcToolsMatching(String query, bool hi, {bool him = false}) {
  final words = query
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return const [];
  bool hasAll(String hay) {
    final ws = hay.toLowerCase().split(RegExp(r'[^a-z0-9]+'));
    return words.every((q) => ws.any((w) => w.startsWith(q)));
  }

  return [
    for (final g in ttcToolGroupsFor(him: him))
      for (final tool in g.tools)
        if (hasAll('${tool.nameEn} ${tool.descEn} ${tool.name(hi)} '
            '${tool.desc(hi)} ${g.title(hi)} ${g.titleEn}'))
          tool,
  ];
}

class TtcToolsScreen extends StatefulWidget {
  const TtcToolsScreen({super.key});

  /// Total tile count, asserted in tests against the master document's 22.
  static int get toolCount =>
      ttcToolGroups.fold(0, (n, g) => n + g.tools.length);

  @override
  State<TtcToolsScreen> createState() => _TtcToolsScreenState();
}

class _TtcToolsScreenState extends State<TtcToolsScreen> {
  // ⚠️ 2026-09-26, FROM THE MOBBIN TOOLS BRIEF. The hub was a wall of two-up
  // cards with no way to find one by name. Three things changed, the ones the
  // good "all services" screens share (Binance's search on top, Apple Health's
  // pinned row, Walmart's list with a purpose line):
  //   · a field that filters by name AND purpose ("sleep" finds the habits
  //     tool, whose name does not say sleep);
  //   · a strip of the three she opened last, or three good first tools when
  //     she has opened none (never empty, never a count);
  //   · each group as a list: the line icon in its well, the name, one line
  //     of what it is for, and her own state when it holds something of hers.
  // The two-up grid is kept for revert as `_tile` below, unreached.
  // T4: the shared search flow. Kept for revert: a bare
  // `TextEditingController _q` behind the local `_SearchField` pill.
  final PvLiveSearch _search = PvLiveSearch();

  /// The library index for E11, rebuilt only when her content choice or the
  /// language changes.
  List<(TtcDoorHit, double)>? _index;
  (bool, bool)? _indexFor;

  @override
  void initState() {
    super.initState();
    TtcToolRecents.instance.load();
    // `TtcPage` did this, and this screen no longer sits in `TtcPage`: the
    // Ask button appears only once something marks the app live, and a
    // woman can land here first. Deferred a frame for the reason on TtcPage.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FabState.instance.markAppLive());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(BuildContext context, TtcTool tool) {
    pvCommitFeedback();
    TtcToolRecents.instance.touch(tool.id);
    tool.open(context);
  }

  void _askVeda(String q) => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => TtcAskVedaScreen(initialQuery: q),
        settings: const RouteSettings(name: kAskVedaRoute),
      ));

  static double _hueOf(TtcTool tool) {
    for (final g in ttcToolGroups) {
      if (g.tools.contains(tool)) return g.hue;
    }
    return 268;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _search,
        TtcLang.instance,
        TtcLogStore.instance,
        TtcSupplementsStore.instance,
        // Without this the medication count under the tile would be whatever it
        // was when the hub was last built - the badge would go stale the moment
        // she added one and came back.
        MedicineStore.instance,
        TtcRecordsStore.instance,
        TtcAppointmentsStore.instance,
        // The treatment row's state line (2026-09-28).
        TtcTreatmentStore.instance,
        TtcToolRecents.instance,
        TtcHomeVersionStore.instance,
        TtcPartnerMode.instance,
      ]),
      builder: (context, _) {
        final p = pvStorePalette;
        final t = TtcS.current();
        final hi = t.hinglish;
        return PvLiveSearchScope(
          search: _search,
          child: Scaffold(
            backgroundColor: p.ground,
            body: Stack(children: [
              Positioned.fill(
                child: ListView(
                  // ⚠️ THE HEADER CARRIES THE SAFE-AREA INSET (2026-09-29,
                  // TtcTabRootHeader), so every tab root's title sits at one
                  // y. Kept for revert:
                  //   padding: EdgeInsets.fromLTRB(0,
                  //       MediaQuery.of(context).padding.top + 12, 0,
                  //       pvNavClearance(context)),
                  padding:
                      EdgeInsets.fromLTRB(0, 0, 0, pvNavClearance(context)),
                  children: [
                    _header(p, t),
                    // The search is the header's `below` now. Kept for revert:
                    //   const SizedBox(height: 14),
                    //   _pad(PvLiveSearchField(search: _search, p: p,
                    //       hint: t.toolsSearchHint)),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: pvLiveSearchSheetMin(context, _search)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _search.searching
                            ? _results(context, p, t, hi)
                            : _page(context, p, t, hi),
                      ),
                    ),
                  ],
                ),
              ),
              // A V1 index (2 = Tools): the bar translates it on V3 and keeps
              // it on V1, as `TtcPage` did.
              const Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: SafeArea(top: false, child: TtcBottomNav(active: 2)),
              ),
            ]),
          ),
        );
      },
    );
  }

  static const double _g = 18;

  Widget _pad(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: _g), child: child);

  /// T1: Learn's header. Kept for revert, the classic chrome:
  ///   TtcPage(tab: 2, header: const TtcHeader(), children: [
  ///     ttcSectionTitle(t.toolsTitle, eyebrow: t.tabTools),
  ///     Text(t.toolsBody, style: ttcBody(14, h: 1.6)), ...])
  ///
  /// ⚠️ ONE TAB-ROOT HEADER (2026-09-29, build 19). The user: "Tools at the
  /// very top, Learn a little lower". On V3 this row had no button, so it
  /// was only as tall as the title and the title sat 4.5dp above Learn's.
  /// `TtcTabRootHeader` holds the row at 42dp with or without a button
  /// (ttc_tab_root_header.dart has the measurements).
  Widget _header(V2Palette p, TtcS t) {
    final v1 = TtcHomeVersionStore.instance.version == TtcHomeVersion.v1;
    return TtcTabRootHeader(
      title: t.tabTools,
      trailing: [
        // V1's bar has no You tab, so on V1 the profile stays one tap away
        // here. On V3 the bar's You is that tap, and a second door to the
        // same place would be the duplicate the review found.
        if (v1)
          PvRoundIcon(
            icon: Icons.person_outline_rounded,
            onTap: () => openTtcProfile(context),
            size: kTtcTabRootRowHeight,
          ),
      ],
      intro: PvLiveSearchWords(
        search: _search,
        // Kept for revert: `t.toolsBody` (a list of seven things that did
        // not say what the page is for).
        child: Text(_him ? kTtcHisToolsBody : kTtcToolsBody,
            style: ttcTabRootIntroStyle()),
      ),
      below: PvLiveSearchField(
        search: _search,
        p: p,
        hint: t.toolsSearchHint,
      ),
    );
  }
  // Kept for revert (2026-09-29), Tools' own header:
  // Widget _header(V2Palette p, TtcS t) {
  //   final v1 = TtcHomeVersionStore.instance.version == TtcHomeVersion.v1;
  //   return _pad(Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(children: [
  //         Expanded(
  //           child: Text(t.tabTools,
  //               style: pvFraunces(
  //                   fontSize: 30,
  //                   fontWeight: FontWeight.w500,
  //                   height: 1.1,
  //                   color: p.ink1)),
  //         ),
  //         if (v1)
  //           PvRoundIcon(
  //             icon: Icons.person_outline_rounded,
  //             onTap: () => openTtcProfile(context),
  //             size: 42,
  //           ),
  //       ]),
  //       const SizedBox(height: 6),
  //       PvLiveSearchWords(
  //         search: _search,
  //         child: Text(_him ? kTtcHisToolsBody : kTtcToolsBody,
  //             style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)),
  //       ),
  //     ],
  //   ));
  // }

  Widget _eyebrow(V2Palette p, String s) => Text(s.toUpperCase(),
      style: pvManrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: p.action));

  bool get _him => TtcPartnerMode.instance.on;

  String _name(TtcTool tool, bool hi) =>
      (_him ? kTtcHisToolWords[tool.id]?.$1 : null) ?? tool.name(hi);

  String _desc(TtcTool tool, bool hi) =>
      (_him ? kTtcHisToolWords[tool.id]?.$2 : null) ?? tool.desc(hi);

  List<Widget> _page(BuildContext context, V2Palette p, TtcS t, bool hi) {
    // ⚠️ NO STRIP ABOVE THE LIST (2026-09-28, the user: "no random
    // repetition", and the brief named "a tool listed twice in the hub").
    // The three tiles on top ("Recently used", or "Good places to start" when
    // she had opened none) were three tools the list below also carries, so
    // every one of them was on the page twice. The list is the one place for
    // a tool; the search field above finds any tool by name or purpose, and
    // `TtcToolRecents` still records what she opens. Kept for revert:
    //   final recent = [
    //     for (final id in TtcToolRecents.instance.ids)
    //       if (!_him || kTtcHisToolIds.contains(id)) ?ttcToolById(id)
    //   ];
    //   final strip = recent.isNotEmpty
    //       ? recent
    //       : [
    //           for (final id in _him ? kTtcHisToolsStartIds : kTtcToolsStartIds)
    //             ?ttcToolById(id)
    //         ];
    return [
      // const SizedBox(height: 22),
      // _pad(_eyebrow(p, recent.isNotEmpty ? t.toolsRecent : t.toolsStartWith)),
      // const SizedBox(height: 11),
      // // IntrinsicHeight so three names of different lengths still line up; a
      // // bare stretch inside a ListView cannot lay out.
      // _pad(IntrinsicHeight(
      //   child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      //     for (var i = 0; i < 3; i++) ...[
      //       if (i > 0) const SizedBox(width: 10),
      //       Expanded(
      //         child: i < strip.length
      //             ? _quick(context, p, strip[i], hi)
      //             : const SizedBox(),
      //       ),
      //     ],
      //   ]),
      // )),
      for (final group in ttcToolGroupsFor(him: _him)) ...[
        const SizedBox(height: 28),
        _pad(_eyebrow(p, group.title(hi))),
        const SizedBox(height: 6),
        _pad(PvRowGroup(p: p, children: [
          for (final tool in group.tools) _row(context, p, tool, hi, group.hue),
        ])),
      ],
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _results(BuildContext context, V2Palette p, TtcS t, bool hi) {
    final q = _search.query;
    final tools = ttcToolsMatching(q, hi, him: _him);
    final key = (
      TtcContentPrefs.instance.hideIntimate,
      TtcLang.instance.hinglish,
    );
    if (_index == null || _indexFor != key) {
      _index = ttcLibraryIndex(
          lang: key.$2 ? AppLanguage.hinglish : AppLanguage.english,
          hideIntimate: key.$1);
      _indexFor = key;
    }
    final library = ttcLibrarySearch(q, _index!).take(6).toList();
    // A row that moved to More is named with where it went (2026-09-28): a
    // feature is never hidden, only moved. Words, not a second door: the
    // bar's More is the one way in.
    final moved = ttcMovedMatching(q);
    return [
      const SizedBox(height: 14),
      for (final m in moved)
        _pad(Padding(
          key: ValueKey('ttc_tool_moved_${m.id}'),
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(ttcMovedNote(m),
              style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)),
        )),
      if (tools.isEmpty && library.isEmpty && moved.isEmpty)
        _pad(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(t.toolsNoMatch,
              style: pvManrope(fontSize: 14, height: 1.45, color: p.ink2)),
        )),
      if (tools.isNotEmpty)
        _pad(PvRowGroup(p: p, children: [
          for (final tool in tools) _row(context, p, tool, hi, _hueOf(tool)),
        ])),
      if (library.isNotEmpty) ...[
        const SizedBox(height: 22),
        _pad(_eyebrow(p, kTtcToolsFromLibrary)),
        const SizedBox(height: 6),
        for (final (h, hue) in library)
          TtcDoorHitRow(
            p: p,
            hit: h,
            onTap: () => openTtcDoorHit(context, h, hue: hue),
          ),
      ],
      const SizedBox(height: 12),
      _pad(PvLiveSearchWayOn(
        p: p,
        icon: Icons.auto_awesome_outlined,
        title: t.learnAskVeda(q),
        line: t.learnAskVedaLine,
        onTap: () => _askVeda(q),
      )),
    ];
  }

  /// The quick strip: the group's well and the name. Three across. A white
  /// card with one hairline (§4.0's card), pressing like every tile.
  // Kept for revert (2026-09-28): the strip's tile, unreached since the strip
  // left the hub (see `_page`).
  // ignore: unused_element
  Widget _quick(BuildContext context, V2Palette p, TtcTool tool, bool hi) =>
      PvPress(
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: p.line)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _open(context, tool),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PvMarkWell(
                        p: p, hue: _hueOf(tool), size: 38, icon: tool.icon),
                    const SizedBox(height: 10),
                    Text(_name(tool, hi),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: p.ink1)),
                  ]),
            ),
          ),
        ),
      );

  /// One row of a group: the well in the group's hue, the name, what it is
  /// for, and her own state as the small line when it holds something of hers.
  Widget _row(BuildContext context, V2Palette p, TtcTool tool, bool hi,
          double hue) =>
      PvListRow(
        key: ValueKey('ttc_tool_row_${tool.id}'),
        p: p,
        // A quiet marker of what has been logged, so an opened tool feels
        // different from an untouched one, without ever becoming a score.
        // ⚠️ THE DOORS' HAND, NOT A MATERIAL GLYPH (2026-09-29, the user:
        // "in Tools you have used icons ... it looks like a different side of
        // the application"). Each tool's own drawn object on a disc of its
        // group's tint, the family the door rails draw (`ttc_tool_marks.dart`,
        // Noom's All tools:
        // https://mobbin.com/screens/a4710a2a-449c-4014-aca2-ce8501600a11).
        // 44, the disc being the well, where the square well was 40.
        // Kept for revert (2026-09-29):
        //   leading: PvMarkWell(p: p, hue: hue, size: 40, icon: tool.icon),
        leading: TtcToolMarkLeading(
            toolId: tool.id, tint: v2BlockTint(hue % 360, p)),
        title: _name(tool, hi),
        line: _desc(tool, hi),
        lineMaxLines: 2,
        meta: _subtitleFor(tool, hi),
        onTap: () => _open(context, tool),
      );

  // Kept for revert: the two-up card grid that drew `_tile`. Not reached.
  //   for (final group in ttcToolGroups) ...[
  //     ttcEyebrow(group.title(hi), color: ttcPurple),
  //     for (var i = 0; i < group.tools.length; i += 2)
  //       IntrinsicHeight(child: Row(children: [
  //         Expanded(child: _tile(context, group.tools[i], hi, t)),
  //         Expanded(child: _tile(context, group.tools[i + 1], hi, t)),
  //       ])),
  //   ],
  // ignore: unused_element
  Widget _tile(BuildContext context, TtcTool tool, bool hi, TtcS t) {
    // A quiet marker of what has been logged, so an opened tool feels different
    // from an untouched one - without ever becoming a score.
    final subtitle = _subtitleFor(tool, hi);
    // A tile she has used says what is in it; one she has not says what it is
    // for. Both beat a bare label with empty space under it.
    final under = subtitle ?? (tool.desc(hi).isEmpty ? null : tool.desc(hi));

    return TtcCard(
      onTap: () => tool.open(context),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // The icon sits in a tinted chip, the way the pregnancy hub does
            // it. A bare glyph on white gave every tool the same weight and
            // made the grid read as a list of words.
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ttcPanel,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tool.icon, size: 20, color: ttcPurple),
            ),
            const SizedBox(height: 11),
            Text(tool.name(hi),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ttcJakarta(13.5)),
            if (under != null) ...[
              const SizedBox(height: 4),
              Text(under,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ttcBody(10.5, color: ttcMuted, w: FontWeight.w600, h: 1.35)),
            ],
            const SizedBox(height: 10),
            // An explicit action, like pregnancy's "Open →". The whole card was
            // already tappable; nothing on it said so.
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(t.openTool,
                  style: ttcBody(11, color: ttcPurple, w: FontWeight.w800)),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_forward_rounded,
                  size: 13, color: ttcPurple),
            ]),
          ]),
    );
  }

  /// A quiet line under a tile once there is something to say about it. Never a
  /// count of what is missing, never a percentage, never a nudge - just a sign
  /// that the tool holds something of theirs.
  String? _subtitleFor(TtcTool tool, bool hi) {
    if (!tool.built) return hi ? 'Jald' : 'Soon';
    switch (tool.id) {
      case 'supplements':
        final n = TtcSupplementsStore.instance.items.length;
        if (n == 0) return null;
        return hi ? '$n add kiye' : '$n added';
      // Its own count now. While the two shared a tile this fell through to the
      // supplement total, which would have put HER supplement count under the
      // medication her clinic prescribed.
      case 'medication':
        final n = MedicineStore.instance.activeMeds.length;
        if (n == 0) return null;
        return hi ? '$n dawai' : '$n recorded';
      case 'reports':
      case 'records':
        final n = TtcRecordsStore.instance.count;
        if (n == 0) return null;
        return hi ? '$n record' : '$n saved';
      case 'appointments':
        final n = TtcAppointmentsStore.instance.upcoming.length;
        if (n == 0) return null;
        return hi ? '$n aage' : '$n upcoming';
      // The state More's "Your health" tile used to carry (2026-09-28).
      case 'treatment':
        return TtcTreatmentStore.instance.hasDates
            ? 'A round is in progress'
            : null;
      default:
        // The tracker tiles share one store, so one lookup covers all of them.
        if (ttcTrackerById(tool.id) == null) return null;
        final days = TtcLogStore.instance.daysLogged(tool.id).length;
        if (days == 0) return null;
        // "1 days logged" (2026-09-27). Kept for revert: '$days days logged'.
        return hi
            ? '$days din log kiye'
            : '$days ${days == 1 ? 'day' : 'days'} logged';
    }
  }
}

// ⚠️ KEPT FOR REVERT (T2, T3, T4 — 2026-09-26): the violet glyph in the
// stage's one well, the radius-26 boxed list, and the third copy of the
// search pill. `PvMarkWell`, `PvRowGroup`/`PvListRow` and `PvLiveSearchField`
// replaced them.
// /// The line icon in the stage's quiet well.
// class _Well extends StatelessWidget {
//   const _Well({required this.icon});
//   final IconData icon;
//
//   @override
//   Widget build(BuildContext context) => Container(
//         width: 38,
//         height: 38,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: ttcPanel,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(icon, size: 20, color: ttcPurple),
//       );
// }
//
// /// White, one hairline, rows split by hairlines (DESIGN-SYSTEM §4.0 list row).
// class _ListBox extends StatelessWidget {
//   const _ListBox({required this.children});
//   final List<Widget> children;
//
//   @override
//   Widget build(BuildContext context) => Container(
//         clipBehavior: Clip.antiAlias,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(ttcCardRadius),
//           border: Border.all(color: ttcLine),
//         ),
//         child: Column(children: [
//           for (var i = 0; i < children.length; i++) ...[
//             if (i > 0)
//               const Divider(
//                   height: 1,
//                   thickness: 1,
//                   color: ttcLine,
//                   indent: 14,
//                   endIndent: 14),
//             children[i],
//           ],
//         ]),
//       );
// }
//
// /// The find field: the base-UI search pill (48 high, white, hairline).
// class _SearchField extends StatelessWidget {
//   const _SearchField({required this.controller, required this.hint});
//   final TextEditingController controller;
//   final String hint;
//
//   @override
//   Widget build(BuildContext context) => Container(
//         height: 48,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(999),
//           border: Border.all(color: ttcLine),
//         ),
//         child: Row(children: [
//           const SizedBox(width: 14),
//           const Icon(Icons.search_rounded, size: 19, color: ttcSoft),
//           const SizedBox(width: 8),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               textInputAction: TextInputAction.search,
//               style: ttcBody(15, color: ttcInk),
//               cursorColor: ttcInk,
//               decoration: InputDecoration(
//                 isDense: true,
//                 hintText: hint,
//                 hintStyle: ttcBody(15, color: ttcMuted),
//                 border: InputBorder.none,
//                 enabledBorder: InputBorder.none,
//                 focusedBorder: InputBorder.none,
//                 disabledBorder: InputBorder.none,
//                 errorBorder: InputBorder.none,
//                 focusedErrorBorder: InputBorder.none,
//                 filled: false,
//                 contentPadding: EdgeInsets.zero,
//               ),
//             ),
//           ),
//           if (controller.text.isNotEmpty)
//             IconButton(
//               onPressed: controller.clear,
//               icon: const Icon(Icons.close_rounded, size: 18, color: ttcSoft),
//               visualDensity: VisualDensity.compact,
//             )
//           else
//             const SizedBox(width: 14),
//         ]),
//       );
// }
